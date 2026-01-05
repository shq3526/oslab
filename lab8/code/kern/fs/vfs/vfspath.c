/*
 * kern/fs/vfs/vfscwd.c
 * * 详细功能说明：
 * 1. 管理进程的当前工作目录 (Current Working Directory, CWD)。
 * 2. 提供了获取 (getcwd) 和设置 (chdir) 当前目录的 VFS 层接口。
 * 3. 维护了 CWD inode 的引用计数，确保在使用期间 inode 不会被回收。
 */

#include <defs.h>
#include <string.h>
#include <vfs.h>
#include <inode.h>
#include <iobuf.h>
#include <stat.h>
#include <proc.h>
#include <error.h>
#include <assert.h>

/*
 * get_cwd_nolock - retrieve current process's working directory. without lock protect
 * 内部辅助函数：直接读取当前进程的 pwd 指针，不加锁。
 */
static struct inode *
get_cwd_nolock(void) {
    return current->filesp->pwd;
}
/*
 * set_cwd_nolock - set current working directory.
 * 内部辅助函数：直接设置当前进程的 pwd 指针，不加锁。
 */
static void
set_cwd_nolock(struct inode *pwd) {
    current->filesp->pwd = pwd;
}

/*
 * lock_cfs - lock the fs related process on current process 
 * 对当前进程的文件结构 (files_struct) 加锁。
 * 防止多线程（如果支持）或并发操作导致 CWD 状态不一致。
 */
static void
lock_cfs(void) {
    lock_files(current->filesp);
}
/*
 * unlock_cfs - unlock the fs related process on current process 
 * 解锁当前进程的文件结构。
 */
static void
unlock_cfs(void) {
    unlock_files(current->filesp);
}

/*
 * vfs_get_curdir - Get current directory as a inode.
 * 获取当前工作目录的 inode。
 * @dir_store: 输出参数，存储 inode 指针
 */
int
vfs_get_curdir(struct inode **dir_store) {
    struct inode *node;
    // 获取当前目录 inode
    if ((node = get_cwd_nolock()) != NULL) {
        // 必须增加引用计数，因为我们要返回一个指向它的指针供外部使用
        vop_ref_inc(node);
        *dir_store = node;
        return 0;
    }
    return -E_NOENT;
}

/*
 * vfs_set_curdir - Set current directory as a inode.
 * The passed inode must in fact be a directory.
 * 设置当前工作目录。
 * @dir: 新的目录 inode
 */
int
vfs_set_curdir(struct inode *dir) {
    int ret = 0;
    lock_cfs(); // 加锁保护 files_struct
    struct inode *old_dir;
    
    // 检查新目录是否与旧目录不同
    if ((old_dir = get_cwd_nolock()) != dir) {
        if (dir != NULL) {
            // 1. 检查 dir 是否真的是一个目录
            uint32_t type;
            if ((ret = vop_gettype(dir, &type)) != 0) {
                goto out;
            }
            if (!S_ISDIR(type)) {
                ret = -E_NOTDIR;
                goto out;
            }
            // 2. 增加新目录 inode 的引用计数 (因为 pwd 指针将指向它)
            vop_ref_inc(dir);
        }
        // 3. 更新 pwd 指针
        set_cwd_nolock(dir);
        // 4. 减少旧目录 inode 的引用计数
        if (old_dir != NULL) {
            vop_ref_dec(old_dir);
        }
    }
out:
    unlock_cfs();
    return ret;
}

/*
 * vfs_chdir - Set current directory, as a pathname. Use vfs_lookup to translate
 * it to a inode.
 * 改变当前目录 (cd 命令的后端)。
 * @path: 目标路径字符串
 */
int
vfs_chdir(char *path) {
    int ret;
    struct inode *node;
    // 1. 解析路径，获取目标 inode
    if ((ret = vfs_lookup(path, &node)) == 0) {
        // 2. 将该 inode 设置为当前目录
        ret = vfs_set_curdir(node);
        // 3. vfs_lookup 返回时增加了一次引用，vfs_set_curdir 内部如果成功又增加了一次引用。
        // 这里我们需要释放 vfs_lookup 带来的引用。
        // 如果 set 成功，pwd 持有引用；如果 set 失败，node 被释放。
        vop_ref_dec(node);
    }
    return ret;
}

/*
 * vfs_getcwd - retrieve current working directory(cwd).
 * 获取当前工作目录的绝对路径字符串 (pwd 命令的后端)。
 * @iob: 输出缓冲区
 */
int
vfs_getcwd(struct iobuf *iob) {
    int ret;
    struct inode *node;
    // 1. 获取当前目录 inode
    if ((ret = vfs_get_curdir(&node)) != 0) {
        return ret;
    }
    assert(node->in_fs != NULL);

    // 2. 获取该文件系统对应的设备名 (例如 "disk0")
    const char *devname = vfs_get_devname(node->in_fs);
    if ((ret = iobuf_move(iob, (char *)devname, strlen(devname), 1, NULL)) != 0) {
        goto out;
    }
    // 3. 添加分隔符 ":"
    char colon = ':';
    if ((ret = iobuf_move(iob, &colon, sizeof(colon), 1, NULL)) != 0) {
        goto out;
    }
    // 4. 调用 inode 的 vop_namefile 方法，反向查找路径 (从 inode 找回 "/home/user")
    ret = vop_namefile(node, iob);

out:
    // 释放 vfs_get_curdir 获取的引用
    vop_ref_dec(node);
    return ret;
}