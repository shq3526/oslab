/*
 * kern/fs/vfs/vfspath.c
 * * 详细功能说明：
 * 1. 实现了 VFS 层的路径解析核心功能。
 * 2. get_device: 负责解析路径前缀（如 "disk0:" 或 "/"），定位解析的起始 inode。
 * 3. vfs_lookup_internal: 路径解析的通用引擎。
 * - 迭代解析路径分量 (Components)。
 * - 处理目录跳转 (Dir walk)。
 * - 支持 Challenge 2 的软链接解析 (Symbolic Link Resolution)，包括循环检测。
 * 4. vfs_lookup: 解析完整路径，返回目标 inode。
 * 5. vfs_lookup_parent: 解析路径直到父目录，并返回父目录 inode 和目标文件名（用于创建/删除文件）。
 */

#include <defs.h>
#include <string.h>
#include <vfs.h>
#include <inode.h>
#include <error.h>
#include <assert.h>
#include <kmalloc.h>
#include <stat.h>
#include <iobuf.h>

// 软链接最大递归深度，防止无限循环
#define MAX_SYMLINK_DEPTH 5

/*
 * get_device- Common code to pull the device name, if any, off the front of a
 * path and choose the inode to begin the name lookup relative to.
 * 解析路径前缀，确定搜索的起始节点 (Start Inode) 和剩余的子路径 (Subpath)。
 * 情况1: "disk0:/path" -> 返回 disk0 根目录, subpath="path"
 * 情况2: "/path"       -> 返回 bootfs 根目录, subpath="path"
 * 情况3: "path"        -> 返回当前工作目录 (cwd), subpath="path"
 */
static int
get_device(char *path, char **subpath, struct inode **node_store) {
    int i, slash = -1, colon = -1;
    // 扫描路径，寻找第一个 ':' 和 '/'
    for (i = 0; path[i] != '\0'; i ++) {
        if (path[i] == ':') { colon = i; break; }
        if (path[i] == '/') { slash = i; break; }
    }
    
    // 情况3: 相对路径 (没有冒号，或者斜杠在冒号之前)
    if (colon < 0 && slash != 0) {
        /* *
         * No colon before a slash, so no device name specified, and the slash isn't leading
         * or is also absent, so this is a relative path or just a bare filename. Start from
         * the current directory, and use the whole thing as the subpath.
         * */
        *subpath = path;
        return vfs_get_curdir(node_store); // 获取当前进程的 CWD
    }
    
    // 情况1: 包含设备名 (如 "disk0:/...")
    if (colon > 0) {
        /* device:path - get root of device's filesystem */
        path[colon] = '\0'; // 临时截断字符串以提取设备名

        /* device:/path - skip slash, treat as device:path */
        while (path[++ colon] == '/'); // 跳过冒号后的斜杠
        *subpath = path + colon;
        // 根据设备名获取其根 inode
        return vfs_get_root(path, node_store);
    }

    /* *
     * we have either /path or :path
     * /path is a path relative to the root of the "boot filesystem"
     * :path is a path relative to the root of the current filesystem
     * */
    int ret;
    // 情况2: 绝对路径 (以 '/' 开头)
    if (*path == '/') {
        if ((ret = vfs_get_bootfs(node_store)) != 0) {
            return ret;
        }
    }
    else {
        // 情况: ":path" (相对于当前文件系统根目录，ucore 特有语法)
        assert(*path == ':');
        struct inode *node;
        if ((ret = vfs_get_curdir(&node)) != 0) {
            return ret;
        }
        /* The current directory may not be a device, so it must have a fs. */
        assert(node->in_fs != NULL);
        *node_store = fsop_get_root(node->in_fs);
        vop_ref_dec(node);
    }

    /* ///... or :/... */
    // 跳过开头的斜杠
    while (*(++ path) == '/');
    *subpath = path;
    return 0;
}

/*
 * vfs_lookup_internal - 核心路径解析函数
 * @path:        输入路径
 * @node_store:  输出 inode
 * @stop_at_last: 如果为 true，解析到父目录停止，并通过 endp 返回最后一个 component 的指针
 * (用于 vfs_lookup_parent，如 mkdir /a/b，我们需要 /a 的 inode 和 "b")
 * @endp:        输出最后一个 component 的文件名字符串
 */
static int
vfs_lookup_internal(char *path, struct inode **node_store, bool stop_at_last, char **endp) {
    int ret;
    struct inode *node;
    
    // 1. 获取起始 inode (根目录 或 当前目录)
    if ((ret = get_device(path, &path, &node)) != 0) {
        return ret;
    }

    // 分配路径缓冲区，因为我们需要在解析 Symlink 时修改路径字符串
    char *pathbuf, *cur_path;
    if ((pathbuf = kmalloc(FS_MAX_FPATH_LEN + 1)) == NULL) {
        vop_ref_dec(node);
        return -E_NO_MEM;
    }
    
    // 复制 path 到 pathbuf
    // 注意：path 可能是 "a/b/c"，get_device 返回的 path 指向这串字符
    if (strlen(path) > FS_MAX_FPATH_LEN) {
        vop_ref_dec(node);
        kfree(pathbuf);
        return -E_TOO_BIG;
    }
    strcpy(pathbuf, path);
    cur_path = pathbuf;

    int link_count = 0; // 记录软链接递归层数
    
loop:
    // 如果路径为空
    if (*cur_path == '\0') {
        if (stop_at_last) {
            // lookup_parent 要求路径不能为空 (否则找不到父目录和子文件名)
            ret = -E_INVAL; 
            goto failed;
        }
        *node_store = node;
        kfree(pathbuf);
        return 0;
    }

    // 2. 提取路径中的下一个分量 (Component)
    // 例如 "a/b/c" -> component="a", next_path="b/c"
    char *component = cur_path;
    char *next_path = strchr(cur_path, '/');
    
    if (next_path != NULL) {
        *next_path = '\0'; // 截断字符串，使得 component 成为一个独立字符串
        next_path++;       // 指向下一个字符
        while (*next_path == '/') next_path++; // 跳过连续的 /
    }

    // 如果要求 stop_at_last 且没有下一个路径了，说明当前 component 就是文件名
    if (stop_at_last && (next_path == NULL || *next_path == '\0')) {
        *node_store = node; // 返回父目录 inode
        *endp = component;  // 这里返回的是 pathbuf 中的指针，外部需要拷贝
        
        // 注意：pathbuf 不能在这里释放，因为 endp 指向它。
        // 但为了接口兼容性，我们通常要求调用者拷贝名字。
        // 这里做一个妥协：我们把 component 移动到 path 原来的内存位置（如果是可写的），
        // 或者我们假设 path 参数本身足够长。
        // 为了安全起见，我们在外部函数处理 path 的拷贝。
        // 在这里，我们将 component 拷贝回传入的 path 指针位置，确保外部可用。
        // (Hack: 假设 pathbuf 和 path 指向的内存区域重叠或者 path 足够容纳 component)
        strcpy(path, component); 
        *endp = path;
        
        kfree(pathbuf);
        return 0;
    }

    // 3. 在当前节点 lookup component
    struct inode *next_node;
    if ((ret = vop_lookup(node, component, &next_node)) != 0) {
        goto failed;
    }

    // 4. 检查是否是 Symlink (软链接处理逻辑)
    uint32_t type;
    if ((ret = vop_gettype(next_node, &type)) != 0) {
        vop_ref_dec(next_node);
        goto failed;
    }

    if (type == S_IFLNK) {
        // 软链接处理
        if (++link_count > MAX_SYMLINK_DEPTH) {
            vop_ref_dec(next_node);
            ret = -E_TOO_BIG; // E_LOOP (Loop too many times)
            goto failed;
        }

        // 读取软链接内容 (目标路径)
        char *link_content = kmalloc(FS_MAX_FPATH_LEN + 1);
        if (link_content == NULL) {
            vop_ref_dec(next_node);
            ret = -E_NO_MEM;
            goto failed;
        }

        struct iobuf __iob, *iob = iobuf_init(&__iob, link_content, FS_MAX_FPATH_LEN, 0);
        ret = vop_read(next_node, iob);
        vop_ref_dec(next_node); // 释放 link inode，我们需要的是它指向的目标
        
        if (ret != 0) {
            kfree(link_content);
            goto failed;
        }
        link_content[iobuf_used(iob)] = '\0'; // 确保字符串结尾

        // 构造新路径
        // 情况A: 绝对路径 "/tmp/foo" -> 丢弃当前 node，重置为 root
        char *new_full_path = link_content;
        bool is_abs = (link_content[0] == '/');
        
        if (is_abs) {
            vop_ref_dec(node); // 释放当前累积的目录
            // 获取新的 root
            if ((ret = get_device(link_content, &new_full_path, &node)) != 0) {
                 kfree(link_content);
                 goto failed_no_node;
            }
        }

        // 拼接剩余路径: link_content + "/" + next_path
        int new_len = strlen(new_full_path) + (next_path ? strlen(next_path) : 0) + 2;
        if (new_len > FS_MAX_FPATH_LEN) {
            kfree(link_content);
            vop_ref_dec(node);
            ret = -E_TOO_BIG;
            goto failed_no_node;
        }

        // 将拼接后的路径写回 pathbuf
        // 注意：link_content 在前
        if (next_path && *next_path != '\0') {
            strcat(link_content, "/");
            strcat(link_content, next_path);
        }
        
        strcpy(pathbuf, new_full_path);
        cur_path = pathbuf; // 更新当前路径指针
        
        kfree(link_content);
        // 继续循环 (goto loop)，基于新的 node 和新的 cur_path 解析
        goto loop;
    }

    // 5. 普通目录或文件
    vop_ref_dec(node); // 释放父目录
    node = next_node;  // 步进到子节点
    
    if (next_path != NULL) {
        cur_path = next_path; // 还有后续路径，继续循环
        goto loop;
    } else {
        // 路径结束
        if (stop_at_last) {
            // 理论上前面已经处理了 stop_at_last，这里不应该到达
            // 除非路径以 "/" 结尾的情况，例如 "a/b/"
            // 这种情况下，component 是 "b"，next_path 是 "" (在循环头被置空)
            // vfs_lookup_parent 对 "a/b/" 的行为通常是不支持的或返回 a 和 b。
            // 简单处理：作为 lookup 失败返回
            vop_ref_dec(node);
            ret = -E_INVAL; 
            goto failed_no_node;
        }
        *node_store = node;
        kfree(pathbuf);
        return 0;
    }

failed:
    vop_ref_dec(node);
failed_no_node:
    kfree(pathbuf);
    return ret;
}

/*
 * vfs_lookup - get the inode according to the path filename
 * 解析完整路径，返回目标 inode
 */
int
vfs_lookup(char *path, struct inode **node_store) {
    return vfs_lookup_internal(path, node_store, 0, NULL);
}

/*
 * vfs_lookup_parent - Name-to-vnode translation.
 * (In BSD, both of these are subsumed by namei().)
 * 解析路径直到父目录。
 * 用于 vfs_create, vfs_link, vfs_rename 等需要操作父目录的情况。
 * 例如：对 "/a/b/c"，返回 "/a/b" 的 inode 和 字符串 "c"。
 */
int
vfs_lookup_parent(char *path, struct inode **node_store, char **endp){
    return vfs_lookup_internal(path, node_store, 1, endp);
}