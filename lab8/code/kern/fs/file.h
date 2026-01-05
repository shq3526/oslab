/*
 * kern/fs/file.h
 * * 详细功能说明：
 * 1. 定义了 struct file 结构体。这是进程文件描述符表 (fd_array) 中的基本元素。
 * 它记录了一个打开文件的状态信息，包括读写偏移量 (pos)、访问权限、引用计数等。
 * 2. 声明了管理文件描述符数组的函数 (fd_array_*)。
 * 3. 声明了内核态的文件操作接口 (file_*)。这些函数封装了对 struct file 的操作，
 * 并将请求转发给底层的 VFS inode 操作。
 * 4. 提供了管理 struct file 引用计数的内联函数。
 */

#ifndef __KERN_FS_FILE_H__
#define __KERN_FS_FILE_H__

//#include <types.h>
#include <fs.h>
#include <proc.h>
#include <atomic.h>
#include <assert.h>

struct inode;
struct stat;
struct dirent;

/*
 * File structure
 * 代表一个“打开的文件”。
 * 这种结构体通常由进程控制块 (proc_struct) 中的 files_struct->fd_array 数组持有。
 */
struct file {
    enum {
        FD_NONE,    // 未使用/空闲槽位
        FD_INIT,    // 正在初始化中 (已分配但未完全打开)
        FD_OPENED,  // 文件已成功打开且有效
        FD_CLOSED,  // 文件已关闭 (等待资源回收)
    } status;       // 文件描述符状态
    bool readable;  // 是否可读 (O_RDONLY 或 O_RDWR)
    bool writable;  // 是否可写 (O_WRONLY 或 O_RDWR)
    int fd;         // 文件描述符索引值 (自指，方便调试和反查)
    off_t pos;      // 当前文件读写指针 (Offset)。这是 struct file 最重要的状态之一，
                    // 使得不同进程或不同 fd 可以独立地读取同一个文件的不同位置。
    struct inode *node; // 指向底层的 VFS inode。
    int open_count;     // 打开计数/引用计数。
                        // 当 fork() 时，子进程继承父进程的 fd，open_count 会增加。
                        // 只有当 open_count 降为 0 时，才会真正释放 struct file 和关闭 inode。
};

/* --- fd_array 管理函数 (用于维护进程的打开文件表) --- */

// 初始化文件描述符数组 (在进程创建时调用)
void fd_array_init(struct file *fd_array);
// 增加文件对象的引用计数，标记为 OPENED (在 open 成功或 fork 时调用)
void fd_array_open(struct file *file);
// 减少文件对象的引用计数，若为 0 则清理 (在 close 时调用)
void fd_array_close(struct file *file);
// 复制文件描述符 (用于 dup/dup2)
// 将 'from' 的状态复制给 'to'，并增加底层 inode 的引用
void fd_array_dup(struct file *to, struct file *from);
// 检查 fd 是否具有指定的读/写权限
bool file_testfd(int fd, bool readable, bool writable);

/* --- file 操作接口 (对接系统调用层) --- */

// 打开文件：分配 fd，查找 inode，初始化 struct file
int file_open(char *path, uint32_t open_flags);
// 关闭文件
int file_close(int fd);
// 读文件：更新 pos
int file_read(int fd, void *base, size_t len, size_t *copied_store);
// 写文件：更新 pos
int file_write(int fd, void *base, size_t len, size_t *copied_store);
// 调整文件指针 pos
int file_seek(int fd, off_t pos, int whence);
// 获取文件状态信息
int file_fstat(int fd, struct stat *stat);
// 将文件内容同步到磁盘
int file_fsync(int fd);
// 获取目录项 (用于 ls)
int file_getdirentry(int fd, struct dirent *dirent);
// 复制文件描述符
int file_dup(int fd1, int fd2);
// 创建管道 (Challenge 1)
int file_pipe(int fd[]);
// 创建命名管道 (Challenge 1 扩展，通常 lab8 基础部分不强制要求)
int file_mkfifo(const char *name, uint32_t open_flags);

/* --- 内联函数：管理 struct file 的引用计数 --- */

// 获取当前引用计数
static inline int
fopen_count(struct file *file) {
    return file->open_count;
}

// 增加引用计数
static inline int
fopen_count_inc(struct file *file) {
    file->open_count += 1;
    return file->open_count;
}

// 减少引用计数
static inline int
fopen_count_dec(struct file *file) {
    file->open_count -= 1;
    return file->open_count;
}

#endif /* !__KERN_FS_FILE_H__ */