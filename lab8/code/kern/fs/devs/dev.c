#include <defs.h>
#include <string.h>
#include <stat.h>
#include <dev.h>
#include <inode.h>
#include <unistd.h>
#include <error.h>

/*
 * dev_open - 通用设备打开函数
 * 对应 VFS 的 vop_open 接口。
 * * 1. 检查 open_flags: 设备文件通常不支持创建(O_CREAT)、截断(O_TRUNC)、
 * 互斥创建(O_EXCL)或追加(O_APPEND)等标志，如果包含则报错。
 * 2. 获取 device 指针: 从 inode 中提取出关联的 struct device 指针。
 * 3. 转发调用: 调用具体设备驱动的 dop_open 函数。
 */
static int
dev_open(struct inode *node, uint32_t open_flags) {
    if (open_flags & (O_CREAT | O_TRUNC | O_EXCL | O_APPEND)) {
        return -E_INVAL;
    }
    // vop_info 是一个宏，用于从 inode 的 union 结构中获取 device 数据
    struct device *dev = vop_info(node, device);
    // 转发给底层驱动的 d_open
    return dop_open(dev, open_flags);
}

/*
 * dev_close - 通用设备关闭函数
 * 对应 VFS 的 vop_close 接口。
 * 直接获取设备指针并调用底层的 d_close。
 */
static int
dev_close(struct inode *node) {
    struct device *dev = vop_info(node, device);
    return dop_close(dev);
}

/*
 * dev_read - 通用设备读取函数
 * 对应 VFS 的 vop_read 接口。
 * * 将 inode 操作转换为设备的 IO 操作。
 * iob (iobuf) 结构体封装了读写的缓冲区地址、长度和偏移量。
 * 最后一个参数 0 表示读取操作 (write = false)。
 */
static int
dev_read(struct inode *node, struct iobuf *iob) {
    struct device *dev = vop_info(node, device);
    return dop_io(dev, iob, 0);
}

/*
 * dev_write - 通用设备写入函数
 * 对应 VFS 的 vop_write 接口。
 * * 最后一个参数 1 表示写入操作 (write = true)。
 */
static int
dev_write(struct inode *node, struct iobuf *iob) {
    struct device *dev = vop_info(node, device);
    return dop_io(dev, iob, 1);
}

/*
 * dev_ioctl - 通用设备 IO 控制函数
 * 对应 VFS 的 vop_ioctl 接口。
 * 用于执行设备特定的控制指令（如设置终端波特率，但这在 ucore 简易版中通常未实现）。
 */
static int
dev_ioctl(struct inode *node, int op, void *data) {
    struct device *dev = vop_info(node, device);
    return dop_ioctl(dev, op, data);
}

/*
 * dev_fstat - 获取文件/设备状态
 * 对应 VFS 的 vop_fstat 接口。
 * * 填充 struct stat 结构体，让用户进程能获取设备信息（如 ls -l 显示的信息）。
 * 1. st_mode (类型): 调用 dev_gettype 区分是字符设备还是块设备。
 * 2. st_nlinks (硬链接数): 设备文件的链接数通常固定为 1。
 * 3. st_blocks (块数): 仅块设备有效 (dev->d_blocks)。
 * 4. st_size (大小): 总字节数 = 块数 * 块大小。
 */
static int
dev_fstat(struct inode *node, struct stat *stat) {
    int ret;
    memset(stat, 0, sizeof(struct stat));
    if ((ret = vop_gettype(node, &(stat->st_mode))) != 0) {
        return ret;
    }
    struct device *dev = vop_info(node, device);
    stat->st_nlinks = 1;
    stat->st_blocks = dev->d_blocks;
    stat->st_size = stat->st_blocks * dev->d_blocksize;
    return 0;
}

/*
 * dev_gettype - 获取设备类型
 * 对应 VFS 的 vop_gettype 接口。
 * * 依据:
 * - 如果 dev->d_blocks > 0 (有固定长度)，则认为是块设备 (S_IFBLK)，如 disk0。
 * - 否则认为是字符设备 (S_IFCHR)，如 stdin, stdout。
 */
static int
dev_gettype(struct inode *node, uint32_t *type_store) {
    struct device *dev = vop_info(node, device);
    *type_store = (dev->d_blocks > 0) ? S_IFBLK : S_IFCHR;
    return 0;
}

/*
 * dev_tryseek - 尝试设置文件指针位置 (lseek)
 * 对应 VFS 的 vop_tryseek 接口。
 * * 规则:
 * 1. 字符设备 (d_blocks == 0): 不支持 seek (如键盘流不能回退)，返回错误。
 * 2. 块设备 (d_blocks > 0): 
 * - 必须按块大小对齐 (pos % d_blocksize == 0)。
 * - 位置必须在合法范围内 (0 <= pos < total_size)。
 */
static int
dev_tryseek(struct inode *node, off_t pos) {
    struct device *dev = vop_info(node, device);
    if (dev->d_blocks > 0) {
        if ((pos % dev->d_blocksize) == 0) {
            if (pos >= 0 && pos < dev->d_blocks * dev->d_blocksize) {
                return 0;
            }
        }
    }
    return -E_INVAL;
}

/*
 * dev_lookup - 设备路径查找
 * 对应 VFS 的 vop_lookup 接口。
 * * 在 ucore 的设计中，设备文件本身就是叶子节点（例如 /dev/disk0），
 * 不包含子文件。
 * 因此，如果 path 参数不为空（试图查找子路径），则返回不存在。
 * 如果 path 为空，则返回设备本身的 inode，并增加引用计数。
 */
static int
dev_lookup(struct inode *node, char *path, struct inode **node_store) {
    if (*path != '\0') {
        return -E_NOENT;
    }
    vop_ref_inc(node);
    *node_store = node;
    return 0;
}

/*
 * 设备 Inode 的函数操作表
 * 当一个 inode 被识别为设备类型时，它的 inode_ops 就会指向这里。
 * 这样，VFS 层对该 inode 的调用（如 vop_read）就会映射到上面的 dev_read。
 */
static const struct inode_ops dev_node_ops = {
    .vop_magic                      = VOP_MAGIC,
    .vop_open                       = dev_open,
    .vop_close                      = dev_close,
    .vop_read                       = dev_read,
    .vop_write                      = dev_write,
    .vop_fstat                      = dev_fstat,
    .vop_ioctl                      = dev_ioctl,
    .vop_gettype                    = dev_gettype,
    .vop_tryseek                    = dev_tryseek,
    .vop_lookup                     = dev_lookup,
};

/* 宏定义，用于生成初始化具体的设备的函数调用 */
#define init_device(x)                                  \
    do {                                                \
        extern void dev_init_##x(void);                 \
        dev_init_##x();                                 \
    } while (0)

/*
 * dev_init - 初始化内置设备
 * 在文件系统初始化阶段被调用。
 * 依次初始化 stdin, stdout, disk0。
 */
void
dev_init(void) {
   // init_device(null); // null 设备未实现
    init_device(stdin);
    init_device(stdout);
    init_device(disk0);
}

/*
 * dev_create_inode - 创建一个通用的设备 Inode
 * 1. 分配一个新的 inode 内存空间。
 * 2. 使用 dev_node_ops 初始化该 inode，将其标记为设备文件。
 * * 这个函数通常被 dev_init_stdin/stdout/disk0 等具体初始化函数调用。
 */
struct inode *
dev_create_inode(void) {
    struct inode *node;
    if ((node = alloc_inode(device)) != NULL) {
        vop_init(node, &dev_node_ops, NULL);
    }
    return node;
}