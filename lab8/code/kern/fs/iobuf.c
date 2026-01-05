/*
 * kern/fs/iobuf.c
 * * 详细功能说明：
 * 1. 实现了 I/O 缓冲区 (iobuf) 的操作接口。
 * 2. iobuf 是 VFS 层和具体文件系统/设备之间进行数据交换的标准载体。
 * 3. 提供了初始化 (init)、数据移动 (move)、清零 (move_zeros) 和 指针步进 (skip) 功能。
 * 4. iobuf_move 是核心函数，自动处理边界检查，并根据方向（读/写）在内部缓冲区和外部内存之间拷贝数据。
 */

#include <defs.h>
#include <string.h>
#include <iobuf.h>
#include <error.h>
#include <assert.h>

/* * iobuf_init - init io buffer struct.
 * 初始化 I/O 缓冲区结构体。
 * set up io_base to point to the buffer you want to transfer to, and set io_len to the length of buffer;
 * initialize io_offset as desired;
 * initialize io_resid to the total amount of data that can be transferred through this io.
 * * @iob:    需要初始化的 iobuf 指针
 * @base:   内存缓冲区的起始地址 (内核空间或用户空间地址)
 * @len:    缓冲区的长度
 * @offset: 操作对应的文件偏移量 (例如从文件的第 100 字节开始读写)
 */
struct iobuf *
iobuf_init(struct iobuf *iob, void *base, size_t len, off_t offset) {
    iob->io_base = base;       // 设置内存基址
    iob->io_offset = offset;   // 设置当前文件偏移
    iob->io_len = iob->io_resid = len; // 初始时，剩余待传输长度等于总长度
    return iob;
}

/* iobuf_move - move data  (iob->io_base ---> data OR  data --> iob->io.base) in memory
 * @copiedp:  the size of data memcopied
 *
 * iobuf_move may be called repeatedly on the same io to transfer
 * additional data until the available buffer space the io refers to
 * is exhausted.
 * * 核心数据传输函数：
 * @iob:     I/O 缓冲区描述符
 * @data:    外部数据指针 (源或目的)
 * @len:     期望传输的长度
 * @m2b:     传输方向标志 (Memory to Buffer?)
 * true  = 写操作 (data -> iob->io_base)
 * false = 读操作 (iob->io_base -> data)
 * @copiedp: 输出参数，返回实际传输的字节数
 */
int
iobuf_move(struct iobuf *iob, void *data, size_t len, bool m2b, size_t *copiedp) {
    size_t alen;
    // 计算实际可传输的长度：取 (剩余空间 io_resid) 和 (请求长度 len) 的较小值
    if ((alen = iob->io_resid) > len) {
        alen = len;
    }
    if (alen > 0) {
        // 默认方向：读操作 (iob -> data)
        void *src = iob->io_base, *dst = data;
        
        // 如果 m2b 为 true，交换源和目的，变为写操作 (data -> iob)
        if (m2b) {
            void *tmp = src;
            src = dst, dst = tmp;
        }
        // 执行内存拷贝
        memmove(dst, src, alen);
        // 更新 iobuf 的状态 (base 前移, offset 增加, resid 减少)
        iobuf_skip(iob, alen), len -= alen;
    }
    // 如果调用者需要知道实际拷贝了多少字节
    if (copiedp != NULL) {
        *copiedp = alen;
    }
    // 如果 len 变为 0，说明请求的所有数据都已传输完成，返回 0
    // 否则说明 iobuf 空间不足，返回 -E_NO_MEM
    return (len == 0) ? 0 : -E_NO_MEM;
}

/*
 * iobuf_move_zeros - set io buffer zero
 * 向 iobuf 中写入零 (通常用于文件空洞或安全擦除)。
 * @copiedp:  the size of data memcopied
 */
int
iobuf_move_zeros(struct iobuf *iob, size_t len, size_t *copiedp) {
    size_t alen;
    // 计算实际可填充的长度
    if ((alen = iob->io_resid) > len) {
        alen = len;
    }
    if (alen > 0) {
        // 将 iobuf 指向的内存区域清零
        memset(iob->io_base, 0, alen);
        // 更新 iobuf 状态
        iobuf_skip(iob, alen), len -= alen;
    }
    if (copiedp != NULL) {
        *copiedp = alen;
    }
    return (len == 0) ? 0 : -E_NO_MEM;
}

/*
 * iobuf_skip - change the current position of io buffer
 * 手动步进 iobuf 的指针。
 * 通常在直接操作了底层 buffer (例如直接通过 DMA 或 IDE 驱动读取了数据) 后调用，
 * 以便同步更新 iobuf 的状态。
 */
void
iobuf_skip(struct iobuf *iob, size_t n) {
    assert(iob->io_resid >= n); // 确保不会步进超出剩余长度
    iob->io_base += n;          // 内存指针前移
    iob->io_offset += n;        // 文件偏移增加
    iob->io_resid -= n;         // 剩余长度减少
}