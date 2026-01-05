/*
 * kern/fs/vfs/inode.h
 * * 详细功能说明：
 * 1. 定义了 VFS 层的核心数据结构 struct inode，它是对文件的抽象表示。
 * 2. 提供了 inode 的类型定义、生命周期管理函数原型（分配、初始化、销毁、引用计数）。
 * 3. 定义了 struct inode_ops，这是文件操作的函数指针表（虚函数表），用于屏蔽不同文件系统的差异。
 * 4. 提供了 VOP_* 系列宏，封装了对 inode_ops 中函数的调用，实现了类似面向对象的多态调用。
 * 5. 包含了为了支持 Challenge（管道、软硬链接）而扩展的数据结构 struct pipe_info 和对应的操作接口。
 */

#ifndef __KERN_FS_VFS_INODE_H__
#define __KERN_FS_VFS_INODE_H__

#include <defs.h>
#include <dev.h>
#include <sfs.h>
#include <atomic.h>
#include <assert.h>

// 1. 定义管道缓冲区大小 (4KB)
// 这是 Challenge 1: UNIX PIPE 机制所需的定义
#define PIPE_SIZE  4096

// 创建管道的函数原型，通常在 pipe.c 中实现
extern int pipe_create(struct inode **node_store);

struct stat;
struct iobuf;

/*
 * A struct inode is an abstract representation of a file.
 *
 * It is an interface that allows the kernel's filesystem-independent 
 * code to interact usefully with multiple sets of filesystem code.
 */

/*
 * Abstract low-level file.
 *
 * Note: in_info is Filesystem-specific data, in_type is the inode type
 *
 * open_count is managed using VOP_INCOPEN and VOP_DECOPEN by
 * vfs_open() and vfs_close(). Code above the VFS layer should not
 * need to worry about it.
 */

// 2. 定义管道控制块
// 用于管理管道的内部状态，包括环形缓冲区和同步原语
struct pipe_info {
    char *p_buffer;          // 环形缓冲区指针，存储流经管道的数据
    off_t p_rpos;            // 读指针 (read head)，表示当前读取到的位置
    off_t p_wpos;            // 写指针 (write head)，表示当前写入到的位置
                             // 缓冲区有效数据量 = p_wpos - p_rpos
    semaphore_t mutex;       // 互斥锁：保护缓冲区操作的原子性，防止读写竞争
    wait_queue_t wait_queue; // 等待队列：
                             // 1. 当缓冲区空时，读者在此等待
                             // 2. 当缓冲区满时，写者在此等待
};

/*
 * Inode 结构体定义
 * 这是 VFS 中最重要的结构，代表一个“文件”（包括普通文件、目录、设备、管道等）。
 */
struct inode {
    union {
        // 使用 union 存储具体文件系统的私有数据
        struct device __device_info;      // 设备文件特定信息 (dev.h)
        struct sfs_inode __sfs_inode_info;// SFS 文件系统特定信息 (sfs.h)
        struct pipe_info __pipe_info;     // [新增] 管道特定信息
    } in_info;
    
    // inode 类型标识
    enum {
        inode_type_device_info = 0x1234,  // 设备文件
        inode_type_sfs_inode_info,        // SFS 文件
        inode_type_pipe_info_info,        // 管道文件
    } in_type;
    
    int ref_count;   // 引用计数：有多少个指针指向此 inode (dentry, file struct 等)
    int open_count;  // 打开计数：当前有多少个文件描述符打开了此文件
    
    struct fs *in_fs;              // 指向所属的文件系统控制块 (fs struct)
    const struct inode_ops *in_ops;// 指向操作函数表 (虚函数表)，定义了该文件的具体行为
};

// 宏：生成 inode 类型的枚举值
#define __in_type(type)                                             inode_type_##type##_info

// 宏：检查 inode 是否属于特定类型
#define check_inode_type(node, type)                                ((node)->in_type == __in_type(type))

// 宏：获取 inode 中包含的具体文件系统信息指针
// 例如：vop_info(node, sfs_inode) 返回 struct sfs_inode*
// 包含类型检查断言
#define __vop_info(node, type)                                      \
    ({                                                              \
        struct inode *__node = (node);                              \
        assert(__node != NULL && check_inode_type(__node, type));   \
        &(__node->in_info.__##type##_info);                         \
     })

#define vop_info(node, type)                                        __vop_info(node, type)

// 宏：从具体信息结构体指针反推 inode 指针
// 利用 container_of 原理 (to_struct)
#define info2node(info, type)                                       \
    to_struct((info), struct inode, in_info.__##type##_info)

// 分配 inode 的函数原型
struct inode *__alloc_inode(int type);

// 宏：分配指定类型的 inode
#define alloc_inode(type)                                           __alloc_inode(__in_type(type))

// inode 最大数量限制
#define MAX_INODE_COUNT                     0x10000

// Inode 引用计数和打开计数管理函数
int inode_ref_inc(struct inode *node);
int inode_ref_dec(struct inode *node);
int inode_open_inc(struct inode *node);
int inode_open_dec(struct inode *node);

// Inode 初始化和销毁函数
void inode_init(struct inode *node, const struct inode_ops *ops, struct fs *fs);
void inode_kill(struct inode *node);

// VOP 操作表的魔数，用于校验
#define VOP_MAGIC                           0x8c4ba476

/*
 * Abstract operations on a inode.
 *
 * Inode 操作函数表 (Vtable)。
 * 类似于 C++ 中的纯虚类，定义了文件系统必须实现的标准接口。
 *
 * 具体解释见下方详细注释。
 */
struct inode_ops {
    unsigned long vop_magic; // 魔数，确保结构体有效性
    
    // 打开文件：通常用于权限检查或初始化私有数据
    int (*vop_open)(struct inode *node, uint32_t open_flags);
    // 关闭文件：通常用于刷新缓存或释放资源
    int (*vop_close)(struct inode *node);
    // 读文件：从文件读取数据到 iobuf
    int (*vop_read)(struct inode *node, struct iobuf *iob);
    // 写文件：从 iobuf 写入数据到文件
    int (*vop_write)(struct inode *node, struct iobuf *iob);
    // 获取文件状态：如大小、类型、块数等 (ls -l)
    int (*vop_fstat)(struct inode *node, struct stat *stat);
    // 文件同步：强制将脏数据刷回磁盘
    int (*vop_fsync)(struct inode *node);
    // 获取文件名：反向查找路径 (getcwd)
    int (*vop_namefile)(struct inode *node, struct iobuf *iob);
    // 获取目录项：读取目录内容 (ls)
    int (*vop_getdirentry)(struct inode *node, struct iobuf *iob);
    // 回收 inode：当引用计数为 0 时调用，彻底销毁 inode
    int (*vop_reclaim)(struct inode *node);
    // 获取文件类型：(FILE, DIR, CHAR, BLOCK, LINK)
    int (*vop_gettype)(struct inode *node, uint32_t *type_store);
    // 尝试定位：检查 seek 操作是否合法
    int (*vop_tryseek)(struct inode *node, off_t pos);
    // 截断文件：改变文件大小 (ftruncate)
    int (*vop_truncate)(struct inode *node, off_t len);
    // 创建文件：在目录下创建新文件
    int (*vop_create)(struct inode *node, const char *name, bool excl, struct inode **node_store);
    // 查找文件：解析路径名获取 inode
    int (*vop_lookup)(struct inode *node, char *path, struct inode **node_store);
    // IO 控制：设备特定操作
    int (*vop_ioctl)(struct inode *node, int op, void *data);

   /* 添加了以下 Challenge 2 (软硬链接) 需要的新接口 */
    // 创建设备文件 (mknod)
    int (*vop_mkfile)(struct inode *node, const char *name, struct inode **node_store); // 如果需要
    // 创建硬链接：在目录下创建一个指向 link_node 的新条目
    int (*vop_link)(struct inode *node, const char *name, struct inode *link_node);
    // 重命名文件
    int (*vop_rename)(struct inode *node, const char *name, struct inode *new_node, const char *new_name);
    // 读取符号链接内容 (readlink)
    int (*vop_readlink)(struct inode *node, struct iobuf *iob); // 如果你想单独定义 readlink，或者复用 vop_read
    // 创建符号链接
    int (*vop_symlink)(struct inode *node, const char *name, const char *path);
    // 创建目录
    int (*vop_mkdir)(struct inode *node, const char *name);
    // 删除目录项 (unlink/rm)
    int (*vop_unlink)(struct inode *node, const char *name);
};

/*
 * Consistency check
 * 检查 inode 状态的一致性
 */
void inode_check(struct inode *node, const char *opstr);

/*
 * VOP 操作宏封装
 * 这些宏简化了对 inode_ops 函数指针的调用，并自动执行安全检查。
 * 形式：vop_foo(node, args) -> node->in_ops->vop_foo(node, args)
 */

// 核心宏：获取函数指针并执行检查
#define __vop_op(node, sym)                                                                             \
    ({                                                                                                  \
        struct inode *__node = (node);                                                                  \
        /* 确保 inode、操作表、具体函数指针均不为空 */                                                    \
        assert(__node != NULL && __node->in_ops != NULL && __node->in_ops->vop_##sym != NULL);          \
        /* 执行一致性检查 */                                                                             \
        inode_check(__node, #sym);                                                                      \
        /* 返回函数指针 */                                                                               \
        __node->in_ops->vop_##sym;                                                                      \
     })

// 各种 VOP 操作的快捷宏
#define vop_open(node, open_flags)                              (__vop_op(node, open)(node, open_flags))
#define vop_close(node)                                         (__vop_op(node, close)(node))
#define vop_read(node, iob)                                     (__vop_op(node, read)(node, iob))
#define vop_write(node, iob)                                    (__vop_op(node, write)(node, iob))
#define vop_fstat(node, stat)                                   (__vop_op(node, fstat)(node, stat))
#define vop_fsync(node)                                         (__vop_op(node, fsync)(node))
#define vop_namefile(node, iob)                                 (__vop_op(node, namefile)(node, iob))
#define vop_getdirentry(node, iob)                              (__vop_op(node, getdirentry)(node, iob))
#define vop_reclaim(node)                                       (__vop_op(node, reclaim)(node))
#define vop_ioctl(node, op, data)                               (__vop_op(node, ioctl)(node, op, data))
#define vop_gettype(node, type_store)                           (__vop_op(node, gettype)(node, type_store))
#define vop_tryseek(node, pos)                                  (__vop_op(node, tryseek)(node, pos))
#define vop_truncate(node, len)                                 (__vop_op(node, truncate)(node, len))
#define vop_create(node, name, excl, node_store)                (__vop_op(node, create)(node, name, excl, node_store))
#define vop_lookup(node, path, node_store)                      (__vop_op(node, lookup)(node, path, node_store))

/* 扩展功能的宏 */
#define vop_link(node, name, link_node)             (__vop_op(node, link)(node, name, link_node))
#define vop_symlink(node, name, path)               (__vop_op(node, symlink)(node, name, path))
#define vop_mkdir(node, name)                       (__vop_op(node, mkdir)(node, name))
#define vop_unlink(node, name)                      (__vop_op(node, unlink)(node, name))
#define vop_rename(old_node, old_name, new_node, new_name) \
    (__vop_op(old_node, rename)(old_node, old_name, new_node, new_name))


// 获取 inode 所属的文件系统
#define vop_fs(node)                                            ((node)->in_fs)
// 初始化 inode
#define vop_init(node, ops, fs)                                 inode_init(node, ops, fs)
// 销毁 inode
#define vop_kill(node)                                          inode_kill(node)

/*
 * Reference count manipulation (handled above filesystem level)
 * 引用计数操作宏
 */
#define vop_ref_inc(node)                                       inode_ref_inc(node)
#define vop_ref_dec(node)                                       inode_ref_dec(node)

/*
 * Open count manipulation (handled above filesystem level)
 * 打开计数操作宏
 * VOP_INCOPEN 由 vfs_open 调用，VOP_DECOPEN 由 vfs_close 调用。
 */
#define vop_open_inc(node)                                      inode_open_inc(node)
#define vop_open_dec(node)                                      inode_open_dec(node)


// 内联函数：获取当前引用计数
static inline int
inode_ref_count(struct inode *node) {
    return node->ref_count;
}

// 内联函数：获取当前打开计数
static inline int
inode_open_count(struct inode *node) {
    return node->open_count;
}

#endif /* !__KERN_FS_VFS_INODE_H__ */