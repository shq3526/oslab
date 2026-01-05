/*
 * kern/fs/iobuf.h
 * * 详细功能说明：
 * 1. 定义了 I/O 缓冲区结构体 struct iobuf。
 * 2. 它是 VFS 系统中用于跟踪数据传输状态的核心结构。
 * 3. 在读写操作（read/write）过程中，iobuf 负责记录：
 * - 数据在内存中的位置 (io_base)
 * - 数据在文件/设备中的逻辑偏移 (io_offset)
 * - 剩余需要传输的长度 (io_resid)
 * 4. 提供了操作 iobuf 的辅助函数原型，用于数据的移动、填充和状态更新。
 */

#ifndef __KERN_FS_IOBUF_H__
#define __KERN_FS_IOBUF_H__

#include <defs.h>

/*
 * iobuf is a buffer Rd/Wr status record
 * I/O 缓冲区描述符。
 * 注意：iobuf 本身不持有 buffer 的所有权，它只是一个"游标"或"迭代器"。
 */
struct iobuf {
    void *io_base;     // the base addr of buffer (used for Rd/Wr)
                       // 当前内存缓冲区的起始地址。
                       // 随着读写进行，该指针会不断向后移动。
                       
    off_t io_offset;   // current Rd/Wr position in buffer, will have been incremented by the amount transferred
                       // 当前对应的文件/设备逻辑偏移量。
                       // 例如：正在读取文件的第 1024 字节。随着读写进行，该值会增加。
                       
    size_t io_len;     // the length of buffer  (used for Rd/Wr)
                       // 缓冲区的总长度 (初始请求长度)。
                       // 这个值通常在初始化后保持不变，用于计算已使用的量。
                       
    size_t io_resid;   // current resident length need to Rd/Wr, will have been decremented by the amount transferred.
                       // 剩余需要传输的字节数 (Residual)。
                       // 初始等于 io_len，传输完成时应为 0。
};

/* * 宏：计算已传输的数据量
 * Used = Total Length - Residual Length
 */
#define iobuf_used(iob)                         ((size_t)((iob)->io_len - (iob)->io_resid))

/* --- 接口函数原型 --- */

// 初始化 iobuf
// @base: 缓冲区的起始地址
// @len: 缓冲区的长度
// @offset: 对应的文件初始偏移量
struct iobuf *iobuf_init(struct iobuf *iob, void *base, size_t len, off_t offset);

// 在 iobuf 和外部数据 data 之间移动数据
// @iob: I/O 缓冲区描述符
// @data: 外部数据源或目的地址
// @len: 期望传输的长度
// @m2b: 方向标志 (Move to Buffer?)
//       true  (1): data -> iob (通常用于读操作：从磁盘读到 data，填入用户 buffer)
//       false (0): iob -> data (通常用于写操作：从用户 buffer 取出，写入磁盘 data)
// @copiedp: 返回实际传输的字节数
int iobuf_move(struct iobuf *iob, void *data, size_t len, bool m2b, size_t *copiedp);

// 向 iobuf 中填充零 (通常用于文件空洞或安全擦除)
int iobuf_move_zeros(struct iobuf *iob, size_t len, size_t *copiedp);

// 手动跳过 iobuf 中的 n 个字节 (不进行数据拷贝，仅更新指针和计数器)
void iobuf_skip(struct iobuf *iob, size_t n);

#endif /* !__KERN_FS_IOBUF_H__ */