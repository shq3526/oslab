/*
 * kern/fs/fs.h
 * * 详细功能说明：
 * 1. 定义了与文件系统相关的全局常量（扇区大小、设备编号）。
 * 2. 定义了进程级别的文件管理结构 struct files_struct。
 * 该结构体存储在 struct proc_struct 中，记录了进程的当前目录和打开的文件描述符表。
 * 3. 提供了管理 files_struct 的函数原型（创建、销毁、复制、加锁等）。
 * 4. 定义了文件描述符数组的内存布局策略（与 files_struct 存放在同一页中）。
 */

#ifndef __KERN_FS_FS_H__
#define __KERN_FS_FS_H__

#include <defs.h>
#include <mmu.h>
#include <sem.h>
#include <atomic.h>

/* 磁盘硬件参数定义 */
#define SECTSIZE            512             /* 扇区大小，通常为 512 字节 */
#define PAGE_NSECT          (PGSIZE / SECTSIZE) /* 一页内存包含多少个扇区 (4096/512 = 8) */

/* 设备编号定义 (对应 ide.c 中的设备索引) */
#define SWAP_DEV_NO         1               /* Swap 分区通常在 disk1 */
#define DISK0_DEV_NO        2               /* SFS 文件系统通常挂载在 disk0 */
#define DISK1_DEV_NO        3

/* 文件系统全局初始化与清理函数 */
void fs_init(void);
void fs_cleanup(void);

// 前向声明
struct inode;
struct file;

/*
 * process's file related informaction
 * 进程的文件相关信息结构体。
 * 每个进程控制块 (proc_struct) 中都有一个指向此结构的指针 (filesp)。
 */
struct files_struct {
    struct inode *pwd;      // inode of present working directory
                            // 当前工作目录的 inode 指针 (CWD)。
                            // 进程所有的相对路径查找都从这里开始。
                            
    struct file *fd_array;  // opened files array
                            // 已打开文件的数组指针。
                            // 数组的下标就是文件描述符 (fd)。
                            
    int files_count;        // the number of opened files
                            // 当前进程打开的文件总数 (引用计数，用于判断何销毁此结构)。
                            
    semaphore_t files_sem;  // lock protect sem
                            // 互斥信号量，保护 pwd 和 fd_array 的并发访问。
};

/* * 内存布局计算：
 * 为了内存分配的高效性，ucore 将 files_struct 结构体本身和 fd_array 数组
 * 放在同一个物理页 (4KB) 中。
 * * 布局示意图: [files_struct][file 0][file 1][file 2]...[file N] |<-- total 4KB -->|
 */

// 计算除去结构体头之后，一页内存还剩多少字节给 fd_array
#define FILES_STRUCT_BUFSIZE                       (PGSIZE - sizeof(struct files_struct))

// 计算剩下的空间能容纳多少个 struct file 条目 (即进程最大支持的 fd 数量)
// 在 ucore 中通常约为 100 左右
#define FILES_STRUCT_NENTRY                        (FILES_STRUCT_BUFSIZE / sizeof(struct file))

/* 锁操作接口 */
void lock_files(struct files_struct *filesp);
void unlock_files(struct files_struct *filesp);

/* 生命周期管理接口 */

// 创建新的 files_struct (用于 proc_alloc)
struct files_struct *files_create(void);

// 销毁 files_struct (用于 do_exit)
// 会关闭所有打开的文件并减少 pwd 的引用计数
void files_destroy(struct files_struct *filesp);

// 关闭除 stdin/stdout 以外的所有文件 (用于 do_execve)
// 执行新程序时，通常需要清理父进程遗留的 fd，但保留标准输入输出
void files_closeall(struct files_struct *filesp);

// 复制文件表 (用于 do_fork)
// 将父进程的文件表复制给子进程，增加对应 inode 的引用计数
int dup_files(struct files_struct *to, struct files_struct *from);

/* 内联辅助函数：操作打开文件计数 */

static inline int
files_count(struct files_struct *filesp) {
    return filesp->files_count;
}

static inline int
files_count_inc(struct files_struct *filesp) {
    filesp->files_count += 1;
    return filesp->files_count;
}

static inline int
files_count_dec(struct files_struct *filesp) {
    filesp->files_count -= 1;
    return filesp->files_count;
}

#endif /* !__KERN_FS_FS_H__ */