/*
 * kern/fs/vfs/vfsfile.c
 * * 详细功能说明：
 * 1. 实现了 VFS 层基于路径的文件操作接口。这些接口通常直接对应于用户态的系统调用。
 * 2. 核心函数 vfs_open：负责打开或创建文件。它处理了 O_CREAT, O_EXCL, O_TRUNC 等标志，
 * 协调 vfs_lookup (查找) 和 vop_create (创建) 之间的逻辑。
 * 3. 实现了 vfs_close：关闭文件，减少引用计数。
 * 4. 实现了扩展功能的接口：
 * - vfs_link: 创建硬链接
 * - vfs_symlink: 创建符号链接
 * - vfs_readlink: 读取符号链接内容
 * - vfs_mkdir: 创建目录
 * - vfs_unlink: 删除文件
 * - vfs_rename: 重命名文件
 * 5. 这些函数的主要工作流程都是：解析路径 -> 获取 inode (或父目录 inode) -> 调用 inode 的 vop_* 操作 -> 释放 inode 引用。
 */

#include <defs.h>
#include <string.h>
#include <vfs.h>
#include <inode.h>
#include <unistd.h>
#include <error.h>
#include <assert.h>

// open file in vfs, get/create inode for file with filename path.
/*
 * vfs_open - 打开或创建文件
 * @path: 文件路径字符串
 * @open_flags: 打开标志 (O_RDONLY, O_CREAT, O_TRUNC 等)
 * @node_store: 输出参数，返回打开的 inode 指针
 */
int
vfs_open(char *path, uint32_t open_flags, struct inode **node_store) {
    bool can_write = 0;
    // 解析访问模式，检查是否允许写操作
    switch (open_flags & O_ACCMODE) {
    case O_RDONLY:
        break;
    case O_WRONLY:
    case O_RDWR:
        can_write = 1;
        break;
    default:
        return -E_INVAL;
    }

    // 如果要求截断文件 (O_TRUNC)，则必须有写权限
    if (open_flags & O_TRUNC) {
        if (!can_write) {
            return -E_INVAL;
        }
    }

    int ret;
    struct inode *node;
    bool excl = (open_flags & O_EXCL) != 0;
    bool create = (open_flags & O_CREAT) != 0;
    
    // 1. 尝试查找文件
    ret = vfs_lookup(path, &node);

    if (ret != 0) {
        // 如果文件不存在 (ret == -16, 即 -E_NOENT)，且设置了 O_CREAT 标志
        if (ret == -16 && (create)) {
            char *name;
            struct inode *dir;
            // 查找父目录 inode 和文件名的最后一部分
            if ((ret = vfs_lookup_parent(path, &dir, &name)) != 0) {
                return ret; // 父目录不存在，无法创建
            }
            // 在父目录下创建新文件
            ret = vop_create(dir, name, excl, &node);
        } else return ret; // 其他错误或未设置创建标志，直接返回错误
    } else if (excl && create) {
        // 如果文件已存在，且同时设置了 O_CREAT | O_EXCL，则返回错误
        return -E_EXISTS;
    }
    assert(node != NULL);

    // 2. 调用 inode 的打开钩子 (可能会检查权限或进行设备初始化)
    if ((ret = vop_open(node, open_flags)) != 0) {
        vop_ref_dec(node); // 打开失败，释放 inode 引用
        return ret;
    }

    // 3. 增加打开计数
    vop_open_inc(node);
    
    // 4. 处理 O_TRUNC (截断文件) 或 新创建的文件
    // 注意：新创建的文件通常大小为 0，truncate 也是 0，这步操作可以统一处理初始状态
    if (open_flags & O_TRUNC || create) {
        if ((ret = vop_truncate(node, 0)) != 0) {
            vop_open_dec(node);
            vop_ref_dec(node);
            return ret;
        }
    }
    *node_store = node;
    return 0;
}

// close file in vfs
/*
 * vfs_close - 关闭文件
 * 减少打开计数和引用计数。如果计数归零，底层资源将被释放。
 */
int
vfs_close(struct inode *node) {
    vop_open_dec(node);
    vop_ref_dec(node);
    return 0;
}

// unlink file
/*
 * vfs_unlink - 删除文件 (实际上是删除目录项)
 * @path: 文件路径
 */
int
vfs_unlink(char *path) {
    int ret;
    struct inode *dir;
    char *name;
    // 查找父目录
    if ((ret = vfs_lookup_parent(path, &dir, &name)) != 0) {
        return ret;
    }
    // 在父目录中删除指定名称的条目
    ret = vop_unlink(dir, name);
    vop_ref_dec(dir); // 释放父目录引用
    return ret;
}

// rename file
/*
 * vfs_rename - 重命名/移动文件
 * @old_path: 原路径
 * @new_path: 新路径
 */
int
vfs_rename(char *old_path, char *new_path) {
    int ret;
    struct inode *old_dir, *new_dir;
    char *old_name, *new_name;

    // 查找源文件的父目录和文件名
    if ((ret = vfs_lookup_parent(old_path, &old_dir, &old_name)) != 0) {
        return ret;
    }
    // 查找目标位置的父目录和文件名
    if ((ret = vfs_lookup_parent(new_path, &new_dir, &new_name)) != 0) {
        vop_ref_dec(old_dir);
        return ret;
    }
    
    // 调用底层的 rename 操作 (通常要求 old_dir 和 new_dir 在同一个文件系统)
    ret = vop_rename(old_dir, old_name, new_dir, new_name);
    
    vop_ref_dec(old_dir);
    vop_ref_dec(new_dir);
    return ret;
}

// link file (Hard Link)
/*
 * vfs_link - 创建硬链接
 * @old_path: 现有文件路径
 * @new_path: 新的硬链接路径
 */
int
vfs_link(char *old_path, char *new_path) {
    int ret;
    struct inode *old_node, *new_dir;
    char *new_name;

    // 查找现有文件的 inode
    if ((ret = vfs_lookup(old_path, &old_node)) != 0) {
        return ret;
    }
    // 查找新链接所在的目录
    if ((ret = vfs_lookup_parent(new_path, &new_dir, &new_name)) != 0) {
        vop_ref_dec(old_node);
        return ret;
    }
    
    // 在新目录下创建指向 old_node 的硬链接
    ret = vop_link(new_dir, new_name, old_node);
    
    vop_ref_dec(new_dir);
    vop_ref_dec(old_node);
    return ret;
}

// symlink file (Soft Link)
/*
 * vfs_symlink - 创建符号链接
 * @old_path: 链接指向的目标路径字符串 (内容)
 * @new_path: 符号链接文件的路径 (位置)
 */
int
vfs_symlink(char *old_path, char *new_path) {
    int ret;
    struct inode *dir;
    char *name;

    // 查找放置符号链接的目录
    if ((ret = vfs_lookup_parent(new_path, &dir, &name)) != 0) {
        return ret;
    }
    
    // 创建符号链接文件，内容为 old_path
    ret = vop_symlink(dir, name, old_path);
    
    vop_ref_dec(dir);
    return ret;
}

// readlink
/*
 * vfs_readlink - 读取符号链接的内容
 * @path: 符号链接路径
 * @iob: 输出缓冲区
 */
int
vfs_readlink(char *path, struct iobuf *iob) {
    int ret;
    struct inode *node;

    // 查找符号链接的 inode
    if ((ret = vfs_lookup(path, &node)) != 0) {
        return ret;
    }

    // 读取内容 (SFS 中 readlink 通常复用 read 接口)
    ret = vop_read(node, iob);

    vop_ref_dec(node);
    return ret;
}

// mkdir
/*
 * vfs_mkdir - 创建目录
 * @path: 新目录路径
 */
int
vfs_mkdir(char *path) {
    int ret;
    struct inode *dir;
    char *name;

    // 查找父目录
    if ((ret = vfs_lookup_parent(path, &dir, &name)) != 0) {
        return ret;
    }
    
    // 在父目录下创建新目录
    ret = vop_mkdir(dir, name);
    
    vop_ref_dec(dir);
    return ret;
}