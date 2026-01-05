/*
 * kern/fs/sysfile.c
 * * 详细功能说明：
 * 1. 实现了文件系统相关的系统调用内核处理函数 (sysfile_*)。
 * 2. 负责用户空间与内核空间的数据交互。包括：
 * - 将用户态路径字符串拷贝到内核态 (copy_path)。
 * - 将用户态读写缓冲区映射或拷贝到内核态 (sysfile_read/write)。
 * - 将内核态返回的数据结构 (如 stat) 拷贝回用户态。
 * 3. 作为“胶水层”，调用 file.c (进程文件层) 和 vfs.c (虚拟文件系统层) 的接口完成实际工作。
 */

#include <defs.h>
#include <string.h>
#include <vmm.h>
#include <proc.h>
#include <kmalloc.h>
#include <vfs.h>
#include <file.h>
#include <iobuf.h>
#include <sysfile.h>
#include <stat.h>
#include <dirent.h>
#include <unistd.h>
#include <error.h>
#include <assert.h>

// 定义内核 IO 缓冲区大小 (4KB)
#define IOBUF_SIZE                          4096

/* copy_path - copy path name */
/* * 辅助函数：将用户空间的路径字符串拷贝到内核空间。
 * @to:   内核空间字符串指针的地址 (输出)
 * @from: 用户空间字符串地址
 */
static int
copy_path(char **to, const char *from) {
    struct mm_struct *mm = current->mm;
    char *buffer;
    // 分配内核缓冲区
    if ((buffer = kmalloc(FS_MAX_FPATH_LEN + 1)) == NULL) {
        return -E_NO_MEM;
    }
    lock_mm(mm); // 加锁保护用户内存访问
    // copy_string 会检查用户地址合法性并处理缺页
    if (!copy_string(mm, buffer, from, FS_MAX_FPATH_LEN + 1)) {
        unlock_mm(mm);
        goto failed_cleanup;
    }
    unlock_mm(mm);
    *to = buffer;
    return 0;

failed_cleanup:
    kfree(buffer);
    return -E_INVAL;
}

/* sysfile_open - open file */
// open 系统调用处理函数
int
sysfile_open(const char *__path, uint32_t open_flags) {
    int ret;
    char *path;
    // 1. 拷贝路径到内核
    if ((ret = copy_path(&path, __path)) != 0) {
        return ret;
    }
    // 2. 调用 file_open 执行打开操作
    ret = file_open(path, open_flags);
    // 3. 释放内核路径缓冲区
    kfree(path);
    return ret;
}

/* sysfile_close - close file */
// close 系统调用处理函数
int
sysfile_close(int fd) {
    return file_close(fd);
}

/* sysfile_read - read file */
// read 系统调用处理函数
int
sysfile_read(int fd, void *base, size_t len) {
    struct mm_struct *mm = current->mm;
    if (len == 0) {
        return 0;
    }
    // 检查 fd 是否可读
    if (!file_testfd(fd, 1, 0)) {
        return -E_INVAL;
    }
    
    // 分配内核临时缓冲区
    void *buffer;
    if ((buffer = kmalloc(IOBUF_SIZE)) == NULL) {
        return -E_NO_MEM;
    }

    int ret = 0;
    size_t copied = 0, alen;
    
    // 分块读取：每次最多读取 IOBUF_SIZE (4KB)
    while (len != 0) {
        if ((alen = IOBUF_SIZE) > len) {
            alen = len;
        }
        // 1. 从文件读取数据到内核 buffer
        ret = file_read(fd, buffer, alen, &alen);
        
        if (alen != 0) {
            lock_mm(mm);
            {
                // 2. 将内核 buffer 数据拷贝到用户空间 base
                if (copy_to_user(mm, base, buffer, alen)) {
                    assert(len >= alen);
                    // 更新指针和剩余长度
                    base += alen, len -= alen, copied += alen;
                }
                else if (ret == 0) {
                    ret = -E_INVAL; // 拷贝失败
                }
            }
            unlock_mm(mm);
        }
        // 如果出错或已读完 (EOF)，退出循环
        if (ret != 0 || alen == 0) {
            goto out;
        }
    }

out:
    kfree(buffer);
    if (copied != 0) {
        return copied; // 返回实际读取字节数
    }
    return ret;
}

/* sysfile_write - write file */
// write 系统调用处理函数
int
sysfile_write(int fd, void *base, size_t len) {
    struct mm_struct *mm = current->mm;
    if (len == 0) {
        return 0;
    }
    // 检查 fd 是否可写
    if (!file_testfd(fd, 0, 1)) {
        return -E_INVAL;
    }
    void *buffer;
    if ((buffer = kmalloc(IOBUF_SIZE)) == NULL) {
        return -E_NO_MEM;
    }

    int ret = 0;
    size_t copied = 0, alen;
    // 分块写入
    while (len != 0) {
        if ((alen = IOBUF_SIZE) > len) {
            alen = len;
        }
        
        lock_mm(mm);
        {
            // 1. 从用户空间 base 拷贝数据到内核 buffer
            if (!copy_from_user(mm, buffer, base, alen, 0)) {
                ret = -E_INVAL;
            }
        }
        unlock_mm(mm);
        
        if (ret == 0) {
            // 2. 将内核 buffer 数据写入文件
            ret = file_write(fd, buffer, alen, &alen);
            if (alen != 0) {
                assert(len >= alen);
                base += alen, len -= alen, copied += alen;
            }
        }
        if (ret != 0 || alen == 0) {
            goto out;
        }
    }

out:
    kfree(buffer);
    if (copied != 0) {
        return copied;
    }
    return ret;
}

/* sysfile_seek - seek file */
// lseek 系统调用处理函数
int
sysfile_seek(int fd, off_t pos, int whence) {
    return file_seek(fd, pos, whence);
}

/* sysfile_fstat - stat file */
// fstat 系统调用处理函数
int
sysfile_fstat(int fd, struct stat *__stat) {
    struct mm_struct *mm = current->mm;
    int ret;
    struct stat __local_stat, *stat = &__local_stat;
    
    // 1. 获取内核态 stat 结构
    if ((ret = file_fstat(fd, stat)) != 0) {
        return ret;
    }

    lock_mm(mm);
    {
        // 2. 拷贝 stat 到用户空间
        if (!copy_to_user(mm, __stat, stat, sizeof(struct stat))) {
            ret = -E_INVAL;
        }
    }
    unlock_mm(mm);
    return ret;
}

/* sysfile_fsync - sync file */
// fsync 系统调用处理函数
int
sysfile_fsync(int fd) {
    return file_fsync(fd);
}

/* sysfile_chdir - change dir */
// chdir 系统调用处理函数
int
sysfile_chdir(const char *__path) {
    int ret;
    char *path;
    if ((ret = copy_path(&path, __path)) != 0) {
        return ret;
    }
    // 调用 VFS 接口改变目录
    ret = vfs_chdir(path);
    kfree(path);
    return ret;
}

/* sysfile_link - link file */
// link 系统调用处理函数 (硬链接)
int
sysfile_link(const char *__path1, const char *__path2) {
    int ret;
    char *old_path, *new_path;
    if ((ret = copy_path(&old_path, __path1)) != 0) {
        return ret;
    }
    if ((ret = copy_path(&new_path, __path2)) != 0) {
        kfree(old_path);
        return ret;
    }
    ret = vfs_link(old_path, new_path);
    kfree(old_path), kfree(new_path);
    return ret;
}

/* sysfile_rename - rename file */
// rename 系统调用处理函数
int
sysfile_rename(const char *__path1, const char *__path2) {
    int ret;
    char *old_path, *new_path;
    if ((ret = copy_path(&old_path, __path1)) != 0) {
        return ret;
    }
    if ((ret = copy_path(&new_path, __path2)) != 0) {
        kfree(old_path);
        return ret;
    }
    ret = vfs_rename(old_path, new_path);
    kfree(old_path), kfree(new_path);
    return ret;
}

/* sysfile_unlink - unlink file */
// unlink 系统调用处理函数 (删除)
int
sysfile_unlink(const char *__path) {
    int ret;
    char *path;
    if ((ret = copy_path(&path, __path)) != 0) {
        return ret;
    }
    ret = vfs_unlink(path);
    kfree(path);
    return ret;
}

/* sysfile_get cwd - get current working directory */
// getcwd 系统调用处理函数
int
sysfile_getcwd(char *buf, size_t len) {
    struct mm_struct *mm = current->mm;
    if (len == 0) {
        return -E_INVAL;
    }

    int ret = -E_INVAL;
    lock_mm(mm);
    {
        // 检查用户缓冲区是否可写
        if (user_mem_check(mm, (uintptr_t)buf, len, 1)) {
            struct iobuf __iob, *iob = iobuf_init(&__iob, buf, len, 0);
            // vfs_getcwd 会直接将路径写入 iobuf 指向的用户空间
            ret = vfs_getcwd(iob);
        }
    }
    unlock_mm(mm);
    return ret;
}

/* sysfile_getdirentry - get the file entry in DIR */
// getdirentry 系统调用处理函数 (ls 核心)
int
sysfile_getdirentry(int fd, struct dirent *__direntp) {
    struct mm_struct *mm = current->mm;
    struct dirent *direntp;
    // 分配内核 dirent 缓冲区
    if ((direntp = kmalloc(sizeof(struct dirent))) == NULL) {
        return -E_NO_MEM;
    }

    int ret = 0;
    lock_mm(mm);
    {
        // 从用户空间读取 dirent.offset (当前读取位置)
        if (!copy_from_user(mm, &(direntp->offset), &(__direntp->offset), sizeof(direntp->offset), 1)) {
            ret = -E_INVAL;
        }
    }
    unlock_mm(mm);

    // 获取目录项
    if (ret != 0 || (ret = file_getdirentry(fd, direntp)) != 0) {
        goto out;
    }

    lock_mm(mm);
    {
        // 将结果拷贝回用户空间
        if (!copy_to_user(mm, __direntp, direntp, sizeof(struct dirent))) {
            ret = -E_INVAL;
        }
    }
    unlock_mm(mm);

out:
    kfree(direntp);
    return ret;
}

/* sysfile_dup -  duplicate fd1 to fd2 */
// dup 系统调用处理函数
int
sysfile_dup(int fd1, int fd2) {
    return file_dup(fd1, fd2);
}

// pipe 系统调用处理函数 (需在 sysfile.c 中实现对接)
int
sysfile_pipe(int *fd_store) {
    return -E_UNIMP; // 需实现：调用 file_pipe 并将 fd[2] copy_to_user
}

// mkfifo 系统调用处理函数
int
sysfile_mkfifo(const char *__name, uint32_t open_flags) {
    return -E_UNIMP;
}

// 新增 sysfile_symlink
// symlink 系统调用处理函数
int
sysfile_symlink(const char *__old_path, const char *__new_path) {
    int ret;
    char *old_path, *new_path;
    if ((ret = copy_path(&old_path, __old_path)) != 0) {
        return ret;
    }
    if ((ret = copy_path(&new_path, __new_path)) != 0) {
        kfree(old_path);
        return ret;
    }
    ret = vfs_symlink(old_path, new_path);
    kfree(old_path);
    kfree(new_path);
    return ret;
}

// sysfile_readlink
// readlink 系统调用处理函数
int
sysfile_readlink(const char *__path, char *__buf, size_t len) {
    struct mm_struct *mm = current->mm;
    char *path;
    int ret;
    if ((ret = copy_path(&path, __path)) != 0) {
        return ret;
    }
    
    // 分配内核缓冲区用于存储 link 内容
    void *buffer = kmalloc(len);
    if (buffer == NULL) { kfree(path); return -E_NO_MEM; }
    
    // iob->base 指向内核缓冲区
    struct iobuf __iob, *iob = iobuf_init(&__iob, buffer, len, 0);
    ret = vfs_readlink(path, iob);
    
    if (ret == 0) {
         lock_mm(mm);
         // 将内容拷贝到用户空间
         if (!copy_to_user(mm, __buf, buffer, iobuf_used(iob))) {
             ret = -E_INVAL;
         }
         unlock_mm(mm);
         ret = iobuf_used(iob); // 返回读取的字节数
    }
    
    kfree(buffer);
    kfree(path);
    return ret;
}