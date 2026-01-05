/*
 * kern/fs/file.c
 * * 详细功能说明：
 * 1. 实现了进程级的文件描述符 (File Descriptor) 管理。
 * 2. 维护了 struct file 结构体，记录了进程打开文件的状态（如当前读写位置 pos、读写权限）。
 * 3. 提供了系统调用层所需的文件操作接口 (file_open, file_read, file_write 等)。
 * 这些接口将用户态的 fd 映射到内核态的 inode，并调用 VFS 层接口执行具体操作。
 * 4. 实现了管道 (Pipe) 的创建逻辑 file_pipe，用于进程间通信。
 */

#include <defs.h>
#include <string.h>
#include <vfs.h>
#include <proc.h>
#include <file.h>
#include <unistd.h>
#include <iobuf.h>
#include <inode.h>
#include <stat.h>
#include <dirent.h>
#include <error.h>
#include <assert.h>

#define testfd(fd)                          ((fd) >= 0 && (fd) < FILES_STRUCT_NENTRY)

// get_fd_array - get current process's open files table
// 获取当前进程的打开文件表数组
static struct file *
get_fd_array(void) {
    struct files_struct *filesp = current->filesp;
    assert(filesp != NULL && files_count(filesp) > 0);
    return filesp->fd_array;
}

// fd_array_init - initialize the open files table
// 初始化文件表：将所有项置为 FD_NONE (未使用)
void
fd_array_init(struct file *fd_array) {
    int fd;
    struct file *file = fd_array;
    for (fd = 0; fd < FILES_STRUCT_NENTRY; fd ++, file ++) {
        file->open_count = 0;
        file->status = FD_NONE, file->fd = fd;
    }
}

// fs_array_alloc - allocate a free file item (with FD_NONE status) in open files table
// 分配一个空闲的文件描述符
// 如果 fd 参数为 NO_FD (-1)，则自动查找第一个空闲位置。
// 如果指定了具体 fd，则尝试分配该位置（用于 dup2）。
static int
fd_array_alloc(int fd, struct file **file_store) {
//    panic("debug");
    struct file *file = get_fd_array();
    if (fd == NO_FD) {
        // 自动查找空闲位
        for (fd = 0; fd < FILES_STRUCT_NENTRY; fd ++, file ++) {
            if (file->status == FD_NONE) {
                goto found;
            }
        }
        return -E_MAX_OPEN;
    }
    else {
        // 指定位置分配
        if (testfd(fd)) {
            file += fd;
            if (file->status == FD_NONE) {
                goto found;
            }
            return -E_BUSY; // 该位置已被占用
        }
        return -E_INVAL;
    }
found:
    assert(fopen_count(file) == 0);
    file->status = FD_INIT, file->node = NULL; // 标记为正在初始化
    *file_store = file;
    return 0;
}

// fd_array_free - free a file item in open files table
// 释放文件描述符
static void
fd_array_free(struct file *file) {
    assert(file->status == FD_INIT || file->status == FD_CLOSED);
    assert(fopen_count(file) == 0);
    // 如果文件之前是关闭状态，说明 inode 已经处理过 close，这里只需要清理 file 结构
    if (file->status == FD_CLOSED) {
        vfs_close(file->node); // 减少 inode 引用计数
    }
    file->status = FD_NONE;
}

// 增加文件描述符的引用计数 (用于多线程共享 fd，虽然 ucore 简化版中主要是单线程)
static void
fd_array_acquire(struct file *file) {
    assert(file->status == FD_OPENED);
    fopen_count_inc(file);
}

// fd_array_release - file's open_count--; if file's open_count-- == 0 , then call fd_array_free to free this file item
// 释放文件描述符引用。如果引用归零，则彻底释放该 fd 项。
static void
fd_array_release(struct file *file) {
    assert(file->status == FD_OPENED || file->status == FD_CLOSED);
    assert(fopen_count(file) > 0);
    if (fopen_count_dec(file) == 0) {
        fd_array_free(file);
    }
}

// fd_array_open - file's open_count++, set status to FD_OPENED
// 将文件描述符状态设置为已打开
void
fd_array_open(struct file *file) {
    assert(file->status == FD_INIT && file->node != NULL);
    file->status = FD_OPENED;
    fopen_count_inc(file);
}

// fd_array_close - file's open_count--; if file's open_count-- == 0 , then call fd_array_free to free this file item
// 关闭文件描述符
void
fd_array_close(struct file *file) {
    assert(file->status == FD_OPENED);
    assert(fopen_count(file) > 0);
    file->status = FD_CLOSED; // 标记为已关闭
    if (fopen_count_dec(file) == 0) {
        fd_array_free(file);
    }
}

//fs_array_dup - duplicate file 'from'  to file 'to'
// 复制文件描述符 (dup/dup2 的核心逻辑)
// 让 to 指向与 from 相同的 inode，并共享读写位置 pos
void
fd_array_dup(struct file *to, struct file *from) {
    //cprintf("[fd_array_dup]from fd=%d, to fd=%d\n",from->fd, to->fd);
    assert(to->status == FD_INIT && from->status == FD_OPENED);
    to->pos = from->pos; // 共享偏移量 (注意：标准 UNIX dup 是共享 file table entry，这里是简化的拷贝)
    to->readable = from->readable;
    to->writable = from->writable;
    struct inode *node = from->node;
    
    // 增加 inode 的引用计数和打开计数
    vop_ref_inc(node), vop_open_inc(node);
    
    to->node = node;
    fd_array_open(to);
}

// fd2file - use fd as index of fd_array, return the array item (file)
// 根据 fd 索引获取 file 结构指针
static inline int
fd2file(int fd, struct file **file_store) {
    if (testfd(fd)) {
        struct file *file = get_fd_array() + fd;
        if (file->status == FD_OPENED && file->fd == fd) {
            *file_store = file;
            return 0;
        }
    }
    return -E_INVAL;
}

// file_testfd - test file is readble or writable?
// 检查 fd 的读写权限
bool
file_testfd(int fd, bool readable, bool writable) {
    int ret;
    struct file *file;
    if ((ret = fd2file(fd, &file)) != 0) {
        return 0;
    }
    if (readable && !file->readable) {
        return 0;
    }
    if (writable && !file->writable) {
        return 0;
    }
    return 1;
}

// open file
// 打开文件系统调用接口
int
file_open(char *path, uint32_t open_flags) {
    bool readable = 0, writable = 0;
    // 解析标志位
    switch (open_flags & O_ACCMODE) {
    case O_RDONLY: readable = 1; break;
    case O_WRONLY: writable = 1; break;
    case O_RDWR:
        readable = writable = 1;
        break;
    default:
        return -E_INVAL;
    }
    int ret;
    struct file *file;
    // 1. 分配文件描述符
    if ((ret = fd_array_alloc(NO_FD, &file)) != 0) {
        return ret;
    }
    
    // 2. 调用 VFS 接口打开 inode
    struct inode *node;
    if ((ret = vfs_open(path, open_flags, &node)) != 0) {
        fd_array_free(file); // 失败，回收 fd
        return ret;
    }
    
    // 3. 初始化 file 结构
    file->pos = 0;
    // 如果是追加模式，定位到文件末尾
    if (open_flags & O_APPEND) {
        struct stat __stat, *stat = &__stat;
        if ((ret = vop_fstat(node, stat)) != 0) {
            vfs_close(node);
            fd_array_free(file);
            return ret;
        }
        file->pos = stat->st_size;
    }
    file->node = node;
    file->readable = readable;
    file->writable = writable;
    fd_array_open(file);
    return file->fd;
}

// close file
// 关闭文件系统调用接口
int
file_close(int fd) {
    int ret;
    struct file *file;
    if ((ret = fd2file(fd, &file)) != 0) {
        return ret;
    }
    fd_array_close(file);
    return 0;
}

// read file
// 读文件系统调用接口
int
file_read(int fd, void *base, size_t len, size_t *copied_store) {
    int ret;
    struct file *file;
    *copied_store = 0;
    // 1. 获取 file 结构
    if ((ret = fd2file(fd, &file)) != 0) {
        return ret;
    }
    // 2. 检查读权限
    if (!file->readable) {
        return -E_INVAL;
    }
    fd_array_acquire(file); // 增加引用，防止操作期间被关闭

    // 3. 构建 iobuf
    struct iobuf __iob, *iob = iobuf_init(&__iob, base, len, file->pos);
    // 4. 调用 VFS 读接口
    ret = vop_read(file->node, iob);

    // 5. 更新文件指针 pos
    size_t copied = iobuf_used(iob);
    if (file->status == FD_OPENED) {
        file->pos += copied;
    }
    *copied_store = copied;
    fd_array_release(file); // 释放引用
    return ret;
}

// write file
// 写文件系统调用接口
int
file_write(int fd, void *base, size_t len, size_t *copied_store) {
    int ret;
    struct file *file;
    *copied_store = 0;
    if ((ret = fd2file(fd, &file)) != 0) {
        return ret;
    }
    if (!file->writable) {
        return -E_INVAL;
    }
    fd_array_acquire(file);

    struct iobuf __iob, *iob = iobuf_init(&__iob, base, len, file->pos);
    ret = vop_write(file->node, iob);

    size_t copied = iobuf_used(iob);
    if (file->status == FD_OPENED) {
        file->pos += copied;
    }
    *copied_store = copied;
    fd_array_release(file);
    return ret;
}

// seek file
// 文件定位系统调用接口 (lseek)
int
file_seek(int fd, off_t pos, int whence) {
    struct stat __stat, *stat = &__stat;
    int ret;
    struct file *file;
    if ((ret = fd2file(fd, &file)) != 0) {
        return ret;
    }
    fd_array_acquire(file);

    // 计算新的目标位置
    switch (whence) {
    case LSEEK_SET: break; // 绝对位置
    case LSEEK_CUR: pos += file->pos; break; // 相对当前位置
    case LSEEK_END:
        // 相对文件末尾
        if ((ret = vop_fstat(file->node, stat)) == 0) {
            pos += stat->st_size;
        }
        break;
    default: ret = -E_INVAL;
    }

    if (ret == 0) {
        // 尝试定位 (对于字符设备如 stdin，这会失败)
        if ((ret = vop_tryseek(file->node, pos)) == 0) {
            file->pos = pos;
        }
//    cprintf("file_seek, pos=%d, whence=%d, ret=%d\n", pos, whence, ret);
    }
    fd_array_release(file);
    return ret;
}

// stat file
// 获取文件信息系统调用接口
int
file_fstat(int fd, struct stat *stat) {
    int ret;
    struct file *file;
    if ((ret = fd2file(fd, &file)) != 0) {
        return ret;
    }
    fd_array_acquire(file);
    ret = vop_fstat(file->node, stat);
    fd_array_release(file);
    return ret;
}

// sync file
// 刷盘系统调用接口
int
file_fsync(int fd) {
    int ret;
    struct file *file;
    if ((ret = fd2file(fd, &file)) != 0) {
        return ret;
    }
    fd_array_acquire(file);
    ret = vop_fsync(file->node);
    fd_array_release(file);
    return ret;
}

// get file entry in DIR
// 获取目录项接口 (用于 getdirentry 系统调用，支持 ls)
int
file_getdirentry(int fd, struct dirent *direntp) {
    int ret;
    struct file *file;
    if ((ret = fd2file(fd, &file)) != 0) {
        return ret;
    }
    fd_array_acquire(file);

    struct iobuf __iob, *iob = iobuf_init(&__iob, direntp->name, sizeof(direntp->name), direntp->offset);
    if ((ret = vop_getdirentry(file->node, iob)) == 0) {
        direntp->offset += iobuf_used(iob); // 更新 offset，指向下一个目录项
    }
    fd_array_release(file);
    return ret;
}

// duplicate file
// 复制文件描述符接口 (dup/dup2)
int
file_dup(int fd1, int fd2) {
    int ret;
    struct file *file1, *file2;
    if ((ret = fd2file(fd1, &file1)) != 0) {
        return ret;
    }
    if ((ret = fd_array_alloc(fd2, &file2)) != 0) {
        return ret;
    }
    fd_array_dup(file2, file1);
    return file2->fd;
}


/*
 * file_pipe - 创建管道
 * Challenge 1 的核心接口。
 * @fd: 输出参数，返回两个文件描述符 fd[0] (读), fd[1] (写)
 */
int
file_pipe(int fd[]) {
    int ret, i;
    struct file *file[2] = {NULL, NULL};
    struct inode *node = NULL;
    
    // 1. 分配两个空闲的文件描述符
    if ((ret = fd_array_alloc(NO_FD, &file[0])) != 0) {
        return ret;
    }
    if ((ret = fd_array_alloc(NO_FD, &file[1])) != 0) {
        fd_array_free(file[0]);
        return ret;
    }
    
    // 2. 创建管道 Inode (申请内存、初始化信号量等)
    // 具体实现通常在 pipe.c 中
    if ((ret = pipe_create(&node)) != 0) {
        fd_array_free(file[0]);
        fd_array_free(file[1]);
        return ret;
    }
    
    // 3. 关联 file 结构与 inode
    // fd[0] 为读端：可读，不可写
    file[0]->node = node;
    file[0]->readable = 1;
    file[0]->writable = 0;
    file[0]->pos = 0;
    
    // fd[1] 为写端：不可读，可写
    file[1]->node = node;
    file[1]->readable = 0;
    file[1]->writable = 1;
    file[1]->pos = 0;
    
    // 4. 正确设置引用计数
    // pipe_create 中 alloc_inode 初始化 ref_count=1
    // 这里有两个 file 指向它，最终 ref_count 应为 2 (每个 file 持有一个引用)
    // alloc_inode 默认给了 1，我们再 vop_ref_inc 一次即可
    vop_ref_inc(node); 
    
    // 设置 open_count。有两个打开的文件实例。
    vop_open_inc(node); // 对应 file[0]
    vop_open_inc(node); // 对应 file[1]
    
    // 5. 激活文件描述符 (状态变为 FD_OPENED)
    fd_array_open(file[0]);
    fd_array_open(file[1]);
    
    // 6. 返回 fd 编号
    fd[0] = file[0]->fd;
    fd[1] = file[1]->fd;
    
    return 0;
}