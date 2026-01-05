/*
 * kern/fs/sysfile.h
 * * 详细功能说明：
 * 1. 声明了所有文件系统相关的系统调用（Syscall）在内核态的实现函数。
 * 2. 这些函数通常由 syscall 分发器调用。
 * 3. 它们的主要职责是处理用户空间到内核空间的参数传递（如路径字符串拷贝、缓冲区检查），
 * 然后调用下层的 VFS 或 File 接口完成实际操作。
 */

#ifndef __KERN_FS_SYSFILE_H__
#define __KERN_FS_SYSFILE_H__

#include <defs.h>

struct stat;
struct dirent;

/* * 核心文件操作 
 * 对应 open, close, read, write, lseek, fstat, fsync 系统调用
 */
int sysfile_open(const char *path, uint32_t open_flags);        // Open or create a file. FLAGS/MODE per the syscall.
int sysfile_close(int fd);                                      // Close a vnode opened  
int sysfile_read(int fd, void *base, size_t len);               // Read file
int sysfile_write(int fd, void *base, size_t len);              // Write file
int sysfile_seek(int fd, off_t pos, int whence);                // Seek file  
int sysfile_fstat(int fd, struct stat *stat);                   // Stat file 
int sysfile_fsync(int fd);                                      // Sync file

/* * 目录与路径操作 
 * 对应 chdir, mkdir, link, rename, unlink, getcwd 系统调用
 */
int sysfile_chdir(const char *path);                            // change DIR  
int sysfile_mkdir(const char *path);                            // create DIR
int sysfile_link(const char *path1, const char *path2);         // set a path1's link as path2
int sysfile_rename(const char *path1, const char *path2);       // rename file
int sysfile_unlink(const char *path);                           // unlink a path
int sysfile_getcwd(char *buf, size_t len);                      // get current working directory

/* * 高级功能 
 * 对应 getdirentry (ls), dup, pipe, mkfifo 系统调用
 */
int sysfile_getdirentry(int fd, struct dirent *direntp);        // get the file entry in DIR 
int sysfile_dup(int fd1, int fd2);                              // duplicate file
int sysfile_pipe(int *fd_store);                                // build PIPE   
int sysfile_mkfifo(const char *name, uint32_t open_flags);      // build named PIPE

// 新增接口（Challenge 2）
int sysfile_symlink(const char *path1, const char *path2);
int sysfile_readlink(const char *path, char *buf, size_t len);

#endif /* !__KERN_FS_SYSFILE_H__ */