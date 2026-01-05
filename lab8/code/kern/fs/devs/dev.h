#ifndef __KERN_FS_DEVS_DEV_H__
#define __KERN_FS_DEVS_DEV_H__

#include <defs.h>

// 前向声明，减少头文件依赖
struct inode;
struct iobuf;

/*
 * Filesystem-namespace-accessible device.
 * 文件系统命名空间可访问的设备抽象接口。
 * 所有的具体设备（如 disk0, stdin, stdout）都需要实现这个接口。
 *
 * d_io is for both reads and writes; the iobuf will indicates the direction.
 * d_io 函数同时负责读和写，具体方向由 iobuf 参数和 write 标志决定。
 */
struct device {
    // 设备包含的数据块总数。
    // 对于块设备（如硬盘），这是扇区数或块数。
    // 对于字符设备（如键盘 stdin），这个值通常为 0。
    size_t d_blocks;

    // 数据块的大小（字节）。
    // 对于块设备，通常是 4096 (PGSIZE) 或 512 (SECTSIZE)。
    // 对于字符设备，这个值通常为 1。
    size_t d_blocksize;

    // 打开设备的函数指针。
    // 对应 VFS 层的 vop_open。通常用于检查打开标志（如只读/只写）。
    int (*d_open)(struct device *dev, uint32_t open_flags);

    // 关闭设备的函数指针。
    // 对应 VFS 层的 vop_close。通常用于释放资源或刷新缓冲区。
    int (*d_close)(struct device *dev);

    // 执行设备 I/O 操作的核心函数指针。
    // @param dev: 设备句柄
    // @param iob: 缓冲区描述符，包含读写的数据地址、长度和偏移量
    // @param write: true 表示写操作 (Write)，false 表示读操作 (Read)
    int (*d_io)(struct device *dev, struct iobuf *iob, bool write);

    // 设备控制函数指针 (Input/Output Control)。
    // 用于执行不适合读/写模型的特定操作（如设置终端波特率、获取磁盘几何信息等）。
    // @param op: 操作码
    // @param data: 操作参数或数据指针
    int (*d_ioctl)(struct device *dev, int op, void *data);
};

/*
 * 辅助宏：用于方便地调用 device 结构体中的函数指针。
 * 这些宏简化了代码，避免了手动解引用函数指针的繁琐语法。
 */
#define dop_open(dev, open_flags)           ((dev)->d_open(dev, open_flags))
#define dop_close(dev)                      ((dev)->d_close(dev))
#define dop_io(dev, iob, write)             ((dev)->d_io(dev, iob, write))
#define dop_ioctl(dev, op, data)            ((dev)->d_ioctl(dev, op, data))

// 初始化所有的内置设备（stdin, stdout, disk0 等）
// 通常在文件系统初始化 (fs_init) 阶段调用
void dev_init(void);

// 为设备分配并初始化一个 inode
// 用于将 struct device 挂载到 VFS 的 inode树上
struct inode *dev_create_inode(void);

#endif /* !__KERN_FS_DEVS_DEV_H__ */