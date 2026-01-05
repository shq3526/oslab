/*
 * kern/fs/fs.c
 * * 详细功能说明：
 * 1. 文件系统子系统的顶层初始化入口 (fs_init)。
 * 2. 实现了进程控制块 (proc_struct) 中 files_struct 成员的生命周期管理。
 * 3. files_struct 维护了进程的：
 * - 当前工作目录 (pwd)
 * - 打开文件表 (fd_array)
 * - 保护该结构的互斥锁 (files_sem)
 * 4. 提供了进程创建 (files_create)、退出 (files_destroy)、Fork (dup_files) 和 Exec (files_closeall) 
 * 阶段对文件资源的处理逻辑。
 */

#include <defs.h>
#include <kmalloc.h>
#include <sem.h>
#include <vfs.h>
#include <dev.h>
#include <file.h>
#include <sfs.h>
#include <inode.h>
#include <assert.h>

//called when init_main proc start
/*
 * fs_init - 文件系统子系统初始化
 * 被 kern_init 调用。
 * 顺序非常重要：
 * 1. vfs_init: 初始化 VFS 核心数据结构 (bootfs_sem, vdev_list)。
 * 2. dev_init: 初始化并注册具体设备 (stdin, stdout, disk0) 到 VFS。
 * 3. sfs_init: 挂载 SFS 文件系统到 disk0 设备上。
 */
void
fs_init(void) {
    vfs_init();
    dev_init();
    sfs_init();
}

void
fs_cleanup(void) {
    vfs_cleanup();
}

/*
 * lock_files - 获取进程文件表的锁
 * 保护 files_struct 中的 pwd 和 fd_array 在多线程/中断环境下的一致性。
 */
void
lock_files(struct files_struct *filesp) {
    down(&(filesp->files_sem));
}

/*
 * unlock_files - 释放进程文件表的锁
 */
void
unlock_files(struct files_struct *filesp) {
    up(&(filesp->files_sem));
}

//Called when a new proc init
/*
 * files_create - 创建并初始化进程的文件结构
 * 通常由 do_fork -> copy_files 或 proc_alloc 调用。
 */
struct files_struct *
files_create(void) {
    //cprintf("[files_create]\n");
    //static_assert((int)FILES_STRUCT_NENTRY > 128);
    struct files_struct *filesp;
    // 分配内存：结构体本身大小 + fd 数组所需的缓冲区大小
    // filesp + 1 指向结构体之后的内存空间，用于存储 fd_array
    if ((filesp = kmalloc(sizeof(struct files_struct) + FILES_STRUCT_BUFSIZE)) != NULL) {
        filesp->pwd = NULL; // 初始时没有当前目录
        filesp->fd_array = (void *)(filesp + 1); // fd_array 指向紧随其后的内存
        filesp->files_count = 0;
        sem_init(&(filesp->files_sem), 1); // 初始化互斥锁
        fd_array_init(filesp->fd_array);   // 初始化文件描述符数组 (全部置为 FD_NONE)
    }
    return filesp;
}

//Called when a proc exit
/*
 * files_destroy - 销毁进程的文件结构
 * 通常由 do_exit 调用。
 * 1. 减少当前工作目录 (pwd) 的引用计数。
 * 2. 关闭所有已打开的文件描述符。
 * 3. 释放内存。
 */
void
files_destroy(struct files_struct *filesp) {
//    cprintf("[files_destroy]\n");
    assert(filesp != NULL && files_count(filesp) == 0); // 确保没有其他线程引用此结构
    
    // 释放当前目录的 inode 引用
    if (filesp->pwd != NULL) {
        vop_ref_dec(filesp->pwd);
    }
    
    int i;
    struct file *file = filesp->fd_array;
    // 遍历关闭所有文件
    for (i = 0; i < FILES_STRUCT_NENTRY; i ++, file ++) {
        if (file->status == FD_OPENED) {
            fd_array_close(file); // 减少 inode 引用，释放 file 槽位
        }
        assert(file->status == FD_NONE);
    }
    kfree(filesp);
}

/*
 * files_closeall - 关闭除标准输入/输出外的所有文件
 * 通常在 do_execve 中调用。
 * 当进程执行新程序时，通常需要清理之前打开的临时文件，但保留 stdin/stdout/stderr 以便 IO 重定向生效。
 */
void
files_closeall(struct files_struct *filesp) {
//    cprintf("[files_closeall]\n");
    assert(filesp != NULL && files_count(filesp) > 0);
    int i;
    struct file *file = filesp->fd_array;
    //skip the stdin & stdout
    // 从下标 2 开始遍历，跳过 0 (stdin) 和 1 (stdout)
    for (i = 2, file += 2; i < FILES_STRUCT_NENTRY; i ++, file ++) {
        if (file->status == FD_OPENED) {
            fd_array_close(file);
        }
    }
}

/*
 * dup_files - 复制文件表 (Fork 的核心逻辑)
 * @to: 子进程的文件结构
 * @from: 父进程的文件结构
 * * 功能：
 * 1. 继承父进程的当前工作目录 (pwd)。
 * 2. 复制父进程所有打开的文件描述符。这会导致相关 inode 的引用计数增加。
 */
int
dup_files(struct files_struct *to, struct files_struct *from) {
//    cprintf("[dup_fs]\n");
    assert(to != NULL && from != NULL);
    assert(files_count(to) == 0 && files_count(from) > 0);
    
    // 1. 复制当前工作目录，并增加引用计数
    if ((to->pwd = from->pwd) != NULL) {
        vop_ref_inc(to->pwd);
    }
    
    int i;
    struct file *to_file = to->fd_array, *from_file = from->fd_array;
    // 2. 遍历父进程的 fd_array
    for (i = 0; i < FILES_STRUCT_NENTRY; i ++, to_file ++, from_file ++) {
        if (from_file->status == FD_OPENED) {
            /* alloc_fd first */
            // 标记子进程对应的 fd 为初始化状态
            to_file->status = FD_INIT;
            // 执行复制：复制 pos、权限、并增加底层 inode 引用
            fd_array_dup(to_file, from_file);
        }
    }
    return 0;
}