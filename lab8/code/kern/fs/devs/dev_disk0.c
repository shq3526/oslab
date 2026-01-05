#include <defs.h>
#include <mmu.h>
#include <sem.h>
#include <ide.h>
#include <inode.h>
#include <kmalloc.h>
#include <dev.h>
#include <vfs.h>
#include <iobuf.h>
#include <error.h>
#include <assert.h>

// 定义 disk0 的块大小为一页（4KB），这是 SFS 文件系统的基本分配单位
#define DISK0_BLKSIZE                   PGSIZE
// 定义内部缓冲区大小为 4 个块（16KB），用于在内存和磁盘之间传输数据
#define DISK0_BUFSIZE                   (4 * DISK0_BLKSIZE)
// 定义一个逻辑块包含多少个物理扇区。通常扇区 512B，块 4096B，所以这里是 8
#define DISK0_BLK_NSECT                 (DISK0_BLKSIZE / SECTSIZE)

// 内部缓冲区指针，用于暂存从磁盘读出或写入磁盘的数据
static char *disk0_buffer;
// 用于 disk0 设备互斥访问的信号量，防止多个进程同时操作磁盘导致缓冲区数据混乱
static semaphore_t disk0_sem;

// 获取 disk0 的锁（P 操作），进入临界区
static void
lock_disk0(void) {
    down(&(disk0_sem));
}

// 释放 disk0 的锁（V 操作），离开临界区
static void
unlock_disk0(void) {
    up(&(disk0_sem));
}

// 打开设备的钩子函数，对于 disk0 这种简单的块设备，不需要特殊初始化操作
static int
disk0_open(struct device *dev, uint32_t open_flags) {
    return 0;
}

// 关闭设备的钩子函数，同样不需要特殊清理操作
static int
disk0_close(struct device *dev) {
    return 0;
}

// 实际读取磁盘数据的函数（不带锁，调用者必须持有锁）
// blkno: 起始逻辑块号
// nblks: 读取的块数量
static void
disk0_read_blks_nolock(uint32_t blkno, uint32_t nblks) {
    int ret;
    // 将逻辑块号转换为物理扇区号 (IDE 驱动层只认识扇区)
    uint32_t sectno = blkno * DISK0_BLK_NSECT, nsecs = nblks * DISK0_BLK_NSECT;
    // 调用底层的 IDE 驱动读取扇区数据到 disk0_buffer
    if ((ret = ide_read_secs(DISK0_DEV_NO, sectno, disk0_buffer, nsecs)) != 0) {
        panic("disk0: read blkno = %d (sectno = %d), nblks = %d (nsecs = %d): 0x%08x.\n",
                blkno, sectno, nblks, nsecs, ret);
    }
}

// 实际写入磁盘数据的函数（不带锁，调用者必须持有锁）
static void
disk0_write_blks_nolock(uint32_t blkno, uint32_t nblks) {
    int ret;
    // 将逻辑块号转换为物理扇区号
    uint32_t sectno = blkno * DISK0_BLK_NSECT, nsecs = nblks * DISK0_BLK_NSECT;
    // 调用底层的 IDE 驱动将 disk0_buffer 的数据写入扇区
    if ((ret = ide_write_secs(DISK0_DEV_NO, sectno, disk0_buffer, nsecs)) != 0) {
        panic("disk0: write blkno = %d (sectno = %d), nblks = %d (nsecs = %d): 0x%08x.\n",
                blkno, sectno, nblks, nsecs, ret);
    }
}

// disk0 的核心 IO 操作函数，实现了 struct device 接口中的 d_io
// iob: 包含读写缓冲区位置、剩余长度、偏移量等信息的结构体
// write: true 表示写操作，false 表示读操作
static int
disk0_io(struct device *dev, struct iobuf *iob, bool write) {
    off_t offset = iob->io_offset;    // 当前读写位置（相对于设备开头的偏移字节数）
    size_t resid = iob->io_resid;     // 还需要读写的字节数
    uint32_t blkno = offset / DISK0_BLKSIZE; // 计算起始块号
    uint32_t nblks = resid / DISK0_BLKSIZE;  // 计算涉及的块数量

    /* * 检查对齐：为了简化实现，disk0 设备要求 IO 操作必须是块对齐的。
     * 即偏移量和长度都必须是 DISK0_BLKSIZE (4096) 的整数倍。
     * 上层文件系统（SFS）需要保证这一点。
     */
    if ((offset % DISK0_BLKSIZE) != 0 || (resid % DISK0_BLKSIZE) != 0) {
        return -E_INVAL;
    }

    /* 检查边界：防止访问超出磁盘容量的范围 */
    if (blkno + nblks > dev->d_blocks) {
        return -E_INVAL;
    }

    /* 如果读写长度为 0，直接返回成功 */
    if (nblks == 0) {
        return 0;
    }

    // 获取设备锁，保证对 disk0_buffer 的独占访问
    lock_disk0();
    
    // 循环处理，直到所有数据处理完毕
    while (resid != 0) {
        size_t copied, alen = DISK0_BUFSIZE; // 单次操作的最大长度受限于 buffer 大小
        
        if (write) {
            // --- 写操作流程 ---
            // 1. 从 iobuf (用户数据源) 搬运数据到 disk0_buffer (内核缓冲区)
            //    iobuf_move 会自动更新 iobuf 内部的指针和计数器
            iobuf_move(iob, disk0_buffer, alen, 0, &copied);
            
            // 确保搬运的数据符合预期且块对齐
            assert(copied != 0 && copied <= resid && copied % DISK0_BLKSIZE == 0);
            
            // 计算本次搬运了多少个块
            nblks = copied / DISK0_BLKSIZE;
            
            // 2. 将内核缓冲区的数据真正写入磁盘
            disk0_write_blks_nolock(blkno, nblks);
        }
        else {
            // --- 读操作流程 ---
            // 1. 确定本次读取的长度，不能超过剩余需求，也不能超过 buffer 大小
            if (alen > resid) {
                alen = resid;
            }
            nblks = alen / DISK0_BLKSIZE;
            
            // 2. 先从磁盘读取数据到内核缓冲区 disk0_buffer
            disk0_read_blks_nolock(blkno, nblks);
            
            // 3. 将内核缓冲区的数据搬运到 iobuf (用户目标缓冲区)
            iobuf_move(iob, disk0_buffer, alen, 1, &copied);
            
            // 确保搬运的数据量正确
            assert(copied == alen && copied % DISK0_BLKSIZE == 0);
        }
        
        // 更新剩余字节数 resid 和当前块号 blkno，准备下一次循环
        resid -= copied, blkno += nblks;
    }
    
    // 释放设备锁
    unlock_disk0();
    return 0;
}

// IO 控制接口，目前 disk0 未实现特定的控制命令
static int
disk0_ioctl(struct device *dev, int op, void *data) {
    return -E_UNIMP;
}

// 初始化 disk0 设备结构的辅助函数
static void
disk0_device_init(struct device *dev) {
    // 静态断言：确保块大小是扇区大小的整数倍
    static_assert(DISK0_BLKSIZE % SECTSIZE == 0);
    
    // 检查底层的 IDE 硬件是否可用
    if (!ide_device_valid(DISK0_DEV_NO)) {
        panic("disk0 device isn't available.\n");
    }
    
    // 设置设备元数据
    dev->d_blocks = ide_device_size(DISK0_DEV_NO) / DISK0_BLK_NSECT; // 总块数
    dev->d_blocksize = DISK0_BLKSIZE; // 块大小
    dev->d_open = disk0_open;         // 绑定 open 函数
    dev->d_close = disk0_close;       // 绑定 close 函数
    dev->d_io = disk0_io;             // 绑定 IO 读写函数
    dev->d_ioctl = disk0_ioctl;       // 绑定 ioctl 函数
    
    // 初始化互斥信号量，初始值为 1 (二元信号量)
    sem_init(&(disk0_sem), 1);

    // 静态断言：确保缓冲区大小是块大小的整数倍
    static_assert(DISK0_BUFSIZE % DISK0_BLKSIZE == 0);
    
    // 为 disk0 分配内核缓冲区
    if ((disk0_buffer = kmalloc(DISK0_BUFSIZE)) == NULL) {
        panic("disk0 alloc buffer failed.\n");
    }
}

// 全局初始化函数：将 disk0 挂载到 VFS 中
void
dev_init_disk0(void) {
    struct inode *node;
    // 创建一个设备类型的 inode（内存中的索引节点）
    if ((node = dev_create_inode()) == NULL) {
        panic("disk0: dev_create_node.\n");
    }
    
    // 初始化该 inode 对应的设备结构体 (vop_info 获取 inode 中的 device 指针)
    disk0_device_init(vop_info(node, device));

    int ret;
    // 将该设备添加到 VFS 的设备列表中，名称为 "disk0"
    // 这样后续就可以通过 vfs_open("disk0:", ...) 来访问它了
    // 参数 1 表示该设备是可挂载的 (mountable)
    if ((ret = vfs_add_dev("disk0", node, 1)) != 0) {
        panic("disk0: vfs_add_dev: %e.\n", ret);
    }
}