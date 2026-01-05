/*
 * user/libs/file.c
 * * 详细功能说明：
 * 1. 本文件是 ucore 操作系统用户态标准库的一部分，专门负责文件 I/O 操作。
 * 2. 它封装了底层的系统调用 (System Calls)。用户程序调用这里的 open/read/write，
 * 实际上是通过 syscall.c 中的接口陷入内核，最终由 kern/fs/sysfile.c 处理。
 * 3. 这种封装屏蔽了底层系统调用的细节（如中断号、寄存器传参），为用户提供了类似
 * 标准 C 库 (libc) 的编程接口。
 * 4. 此外，还包含了一些用于解析和打印文件状态信息 (struct stat) 的辅助函数。
 */

#include <defs.h>
#include <string.h>
#include <syscall.h>
#include <stdio.h>
#include <stat.h>
#include <error.h>
#include <unistd.h>

/*
 * open - 打开或创建文件
 * @path:       文件路径字符串
 * @open_flags: 打开标志 (如 O_RDONLY, O_WRONLY, O_CREAT 等)
 * @return:     成功返回文件描述符 (fd >= 0)，失败返回错误码 (< 0)
 * * 对应内核实现：sysfile_open -> file_open
 */
int
open(const char *path, uint32_t open_flags) {
    return sys_open(path, open_flags);
}

/*
 * close - 关闭文件描述符
 * @fd:     要关闭的文件描述符
 * @return: 成功返回 0，失败返回错误码
 * * 对应内核实现：sysfile_close -> file_close
 * 释放进程打开文件表中的对应项，并减少 inode 引用计数。
 */
int
close(int fd) {
    return sys_close(fd);
}

/*
 * read - 从文件读取数据
 * @fd:   文件描述符
 * @base: 用户空间的缓冲区地址，用于存储读取的数据
 * @len:  期望读取的字节数
 * @return: 实际读取的字节数，或者错误码
 * * 对应内核实现：sysfile_read -> file_read
 */
int
read(int fd, void *base, size_t len) {
    return sys_read(fd, base, len);
}

/*
 * write - 向文件写入数据
 * @fd:   文件描述符
 * @base: 包含待写入数据的用户缓冲区地址
 * @len:  期望写入的字节数
 * @return: 实际写入的字节数，或者错误码
 * * 对应内核实现：sysfile_write -> file_write
 */
int
write(int fd, void *base, size_t len) {
    return sys_write(fd, base, len);
}

/*
 * seek - 重新定位文件的读写指针 (Lseek)
 * @fd:     文件描述符
 * @pos:    偏移量
 * @whence: 基准位置 (LSEEK_SET: 文件头, LSEEK_CUR: 当前位置, LSEEK_END: 文件尾)
 * @return: 成功返回新的偏移量，失败返回错误码
 * * 对应内核实现：sysfile_seek -> file_seek
 */
int
seek(int fd, off_t pos, int whence) {
    return sys_seek(fd, pos, whence);
}

/*
 * fstat - 获取文件状态信息
 * @fd:   文件描述符
 * @stat: 指向 struct stat 的指针，用于接收内核返回的元数据
 * @return: 成功返回 0，失败返回错误码
 * * 对应内核实现：sysfile_fstat -> file_fstat
 * 获取的信息包括：inode号、文件类型、链接数、大小等。
 */
int
fstat(int fd, struct stat *stat) {
    return sys_fstat(fd, stat);
}

/*
 * fsync - 将文件缓存同步到磁盘
 * @fd:   文件描述符
 * @return: 成功返回 0，失败返回错误码
 * * 对应内核实现：sysfile_fsync -> file_fsync -> vop_fsync
 * 确保数据真正落盘，防止断电数据丢失。
 */
int
fsync(int fd) {
    return sys_fsync(fd);
}

/*
 * dup2 - 复制文件描述符
 * @fd1: 旧的文件描述符 (被复制者)
 * @fd2: 新的文件描述符 (目标)
 * @return: 成功返回新的 fd，失败返回错误码
 * * 对应内核实现：sysfile_dup -> file_dup
 * 如果 fd2 已经打开，会先将其关闭。通常用于重定向 (如 dup2(fd, STDOUT_NO))。
 */
int
dup2(int fd1, int fd2) {
    return sys_dup(fd1, fd2);
}

/*
 * transmode - 辅助函数：解析文件类型
 * @stat: 文件状态结构体
 * @return: 代表文件类型的字符
 * * 'r': Regular file (普通文件)
 * 'd': Directory (目录)
 * 'l': Symlink (符号链接)
 * 'c': Character device (字符设备)
 * 'b': Block device (块设备)
 * '-': Unknown
 */
static char
transmode(struct stat *stat) {
    uint32_t mode = stat->st_mode;
    if (S_ISREG(mode)) return 'r';
    if (S_ISDIR(mode)) return 'd';
    if (S_ISLNK(mode)) return 'l';
    if (S_ISCHR(mode)) return 'c';
    if (S_ISBLK(mode)) return 'b';
    return '-';
}

/*
 * print_stat - 辅助函数：格式化打印文件信息
 * @name: 文件名
 * @fd:   文件描述符
 * @stat: 文件状态结构体
 * * 用于调试或 ls 命令，输出文件的 fd、名称、类型、硬链接数、块数和大小。
 */
void
print_stat(const char *name, int fd, struct stat *stat) {
    cprintf("[%03d] %s\n", fd, name);
    cprintf("    mode    : %c\n", transmode(stat));
    cprintf("    links   : %lu\n", stat->st_nlinks);
    cprintf("    blocks  : %lu\n", stat->st_blocks);
    cprintf("    size    : %lu\n", stat->st_size);
}