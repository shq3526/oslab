#include <defs.h>
#include <stdio.h>
#include <dev.h>
#include <vfs.h>
#include <iobuf.h>
#include <inode.h>
#include <unistd.h>
#include <error.h>
#include <assert.h>

/*
 * stdout_open - 打开设备的钩子函数
 * 检查打开标志。stdout 设备只能被用于写入 (O_WRONLY)。
 * 如果尝试以读模式打开，返回参数无效错误。
 */
static int
stdout_open(struct device *dev, uint32_t open_flags) {
    if (open_flags != O_WRONLY) {
        return -E_INVAL;
    }
    return 0;
}

/*
 * stdout_close - 关闭设备的钩子函数
 * 由于 stdout 不需要维护状态或释放资源，直接返回成功。
 */
static int
stdout_close(struct device *dev) {
    return 0;
}

/*
 * stdout_io - 核心 IO 操作函数
 * 对应 VFS 层的读写请求。
 * dev: 设备句柄
 * iob: IO 缓冲区描述符
 * write: true 表示写操作，false 表示读操作
 */
static int
stdout_io(struct device *dev, struct iobuf *iob, bool write) {
    // 仅支持写操作
    if (write) {
        char *data = iob->io_base; // 获取用户数据缓冲区的起始地址
        
        // 循环处理，直到缓冲区中剩余待写字节数 (io_resid) 为 0
        for (; iob->io_resid != 0; iob->io_resid --) {
            // 取出一个字符并递增指针，调用内核控制台输出函数 cputchar
            // cputchar 会将字符输出到串口或显存，显示在屏幕上
            cputchar(*data ++);
        }
        return 0;
    }
    // 如果尝试对 stdout 进行读操作 (read)，返回无效参数错误
    return -E_INVAL;
}

/*
 * stdout_ioctl - IO 控制接口
 * stdout 暂不支持任何控制命令
 */
static int
stdout_ioctl(struct device *dev, int op, void *data) {
    return -E_INVAL;
}

/*
 * stdout_device_init - 初始化设备结构体
 * 设置 stdout 设备的基本属性和操作函数指针
 */
static void
stdout_device_init(struct device *dev) {
    dev->d_blocks = 0;       // 字符设备，非块设备
    dev->d_blocksize = 1;    // 最小操作单位为 1 字节
    dev->d_open = stdout_open;
    dev->d_close = stdout_close;
    dev->d_io = stdout_io;   // 绑定核心 IO 函数
    dev->d_ioctl = stdout_ioctl;
}

/*
 * dev_init_stdout - 全局初始化函数
 * 创建 stdout 对应的 inode 并将其注册到 VFS 中
 */
void
dev_init_stdout(void) {
    struct inode *node;
    // 创建一个设备类型的 inode
    if ((node = dev_create_inode()) == NULL) {
        panic("stdout: dev_create_node.\n");
    }
    // 初始化该 inode 对应的设备结构信息
    stdout_device_init(vop_info(node, device));

    int ret;
    // 将该设备添加到 VFS 设备列表，名称为 "stdout"
    // 参数 0 表示该设备不可挂载（不可像磁盘一样 mount）
    if ((ret = vfs_add_dev("stdout", node, 0)) != 0) {
        panic("stdout: vfs_add_dev: %e.\n", ret);
    }
}