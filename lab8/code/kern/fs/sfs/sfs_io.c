#include <defs.h>
#include <string.h>
#include <dev.h>
#include <sfs.h>
#include <iobuf.h>
#include <bitmap.h>
#include <assert.h>

//Basic block-level I/O routines
// 基础块级 I/O 例程

/* sfs_rwblock_nolock - Basic block-level I/O routine for Rd/Wr one disk block,
 * without lock protect for mutex process on Rd/Wr disk block
 * 最底层的单块读写函数 (无锁)
 * @sfs:   sfs_fs 对象
 * @buf:   读写缓冲区
 * @blkno: 磁盘块号 (Block Number)
 * @write: true=写, false=读
 * @check: 是否检查块号越界 (通常为 true，但在写 superblock 时可能为 false 或特殊处理)
 */
static int
sfs_rwblock_nolock(struct sfs_fs *sfs, void *buf, uint32_t blkno, bool write, bool check) {
    // 检查块号合法性：不能是 0 (除非不检查)，且必须小于总块数
    assert((blkno != 0 || !check) && blkno < sfs->super.blocks);
    // 初始化 iobuf，将 sfs 的块操作映射到设备的字节流操作
    struct iobuf __iob, *iob = iobuf_init(&__iob, buf, SFS_BLKSIZE, blkno * SFS_BLKSIZE);
    // 调用底层设备驱动的 d_io 函数
    return dop_io(sfs->dev, iob, write);
}

/* sfs_rwblock - Basic block-level I/O routine for Rd/Wr N disk blocks ,
 * with lock protect for mutex process on Rd/Wr disk block
 * 读写多个连续的磁盘块 (带 IO 锁)
 * @sfs:   sfs_fs which will be process
 * @buf:   the buffer uesed for Rd/Wr
 * @blkno: 起始块号
 * @nblks: 块数量
 * @write: BOOL: Read - 0 or Write - 1
 */
static int
sfs_rwblock(struct sfs_fs *sfs, void *buf, uint32_t blkno, uint32_t nblks, bool write) {
    int ret = 0;
    lock_sfs_io(sfs); // 获取 IO 锁，保证连续读写的原子性
    {
        while (nblks != 0) {
            // 逐块调用 sfs_rwblock_nolock
            if ((ret = sfs_rwblock_nolock(sfs, buf, blkno, write, 1)) != 0) {
                break;
            }
            blkno ++, nblks --;
            buf += SFS_BLKSIZE;
        }
    }
    unlock_sfs_io(sfs);
    return ret;
}

/* sfs_rblock - The Wrap of sfs_rwblock function for Rd N disk blocks ,
 * 读块封装函数
 * @sfs:   sfs_fs which will be process
 * @buf:   the buffer uesed for Rd/Wr
 * @blkno: the NO. of disk block
 * @nblks: Rd/Wr number of disk block
 */
int
sfs_rblock(struct sfs_fs *sfs, void *buf, uint32_t blkno, uint32_t nblks) {
    return sfs_rwblock(sfs, buf, blkno, nblks, 0); // 0 = Read
}

/* sfs_wblock - The Wrap of sfs_rwblock function for Wr N disk blocks ,
 * 写块封装函数
 * @sfs:   sfs_fs which will be process
 * @buf:   the buffer uesed for Rd/Wr
 * @blkno: the NO. of disk block
 * @nblks: Rd/Wr number of disk block
 */
int
sfs_wblock(struct sfs_fs *sfs, void *buf, uint32_t blkno, uint32_t nblks) {
    return sfs_rwblock(sfs, buf, blkno, nblks, 1); // 1 = Write
}

/* sfs_rbuf - The Basic block-level I/O routine for  Rd( non-block & non-aligned io) one disk block(using sfs->sfs_buffer)
 * with lock protect for mutex process on Rd/Wr disk block
 * 部分读 (Partial Read) 函数
 * 当不需要读取整块数据，或者数据未对齐时使用。
 * 逻辑：先读整块到内部缓冲区 sfs_buffer，再 memcpy 需要的部分。
 * @sfs:    sfs_fs which will be process
 * @buf:    用户缓冲区
 * @len:    读取长度
 * @blkno:  磁盘块号
 * @offset: 块内偏移量
 */
int
sfs_rbuf(struct sfs_fs *sfs, void *buf, size_t len, uint32_t blkno, off_t offset) {
    assert(offset >= 0 && offset < SFS_BLKSIZE && offset + len <= SFS_BLKSIZE);
    int ret;
    lock_sfs_io(sfs);
    {
        // 1. 读取整个块到 sfs->sfs_buffer (临时缓冲区)
        if ((ret = sfs_rwblock_nolock(sfs, sfs->sfs_buffer, blkno, 0, 1)) == 0) {
            // 2. 将需要的部分拷贝到用户 buf
            memcpy(buf, sfs->sfs_buffer + offset, len);
        }
    }
    unlock_sfs_io(sfs);
    return ret;
}

/* sfs_wbuf - The Basic block-level I/O routine for  Wr( non-block & non-aligned io) one disk block(using sfs->sfs_buffer)
 * with lock protect for mutex process on Rd/Wr disk block
 * 部分写 (Partial Write) 函数
 * 逻辑：读-改-写 (Read-Modify-Write)
 * 1. 读整块到缓冲区
 * 2. 修改缓冲区中对应部分
 * 3. 写回整块到磁盘
 * @sfs:    sfs_fs which will be process
 * @buf:    用户缓冲区
 * @len:    写入长度
 * @blkno:  磁盘块号
 * @offset: 块内偏移量
 */
int
sfs_wbuf(struct sfs_fs *sfs, void *buf, size_t len, uint32_t blkno, off_t offset) {
    assert(offset >= 0 && offset < SFS_BLKSIZE && offset + len <= SFS_BLKSIZE);
    int ret;
    lock_sfs_io(sfs);
    {
        // 1. 先读取旧数据 (Read)
        if ((ret = sfs_rwblock_nolock(sfs, sfs->sfs_buffer, blkno, 0, 1)) == 0) {
            // 2. 在缓冲区中覆盖新数据 (Modify)
            memcpy(sfs->sfs_buffer + offset, buf, len);
            // 3. 将修改后的块写回磁盘 (Write)
            ret = sfs_rwblock_nolock(sfs, sfs->sfs_buffer, blkno, 1, 1);
        }
    }
    unlock_sfs_io(sfs);
    return ret;
}

/*
 * sfs_sync_super - write sfs->super (in memory) into disk (SFS_BLKN_SUPER, 1) with lock protect.
 * 同步超级块 (Superblock) 到磁盘
 * 超级块固定在磁盘的 Block 0 (SFS_BLKN_SUPER)
 */
int
sfs_sync_super(struct sfs_fs *sfs) {
    int ret;
    lock_sfs_io(sfs);
    {
        memset(sfs->sfs_buffer, 0, SFS_BLKSIZE);
        memcpy(sfs->sfs_buffer, &(sfs->super), sizeof(sfs->super));
        // 这里的 check 参数为 0，因为 blkno 是 0
        ret = sfs_rwblock_nolock(sfs, sfs->sfs_buffer, SFS_BLKN_SUPER, 1, 0);
    }
    unlock_sfs_io(sfs);
    return ret;
}

/*
 * sfs_sync_freemap - write sfs bitmap into disk (SFS_BLKN_FREEMAP, nblks)  without lock protect.
 * 同步空闲位图 (Freemap) 到磁盘
 * Freemap 从 Block 2 (SFS_BLKN_FREEMAP) 开始
 */
int
sfs_sync_freemap(struct sfs_fs *sfs) {
    uint32_t nblks = sfs_freemap_blocks(&(sfs->super));
    // 直接获取 bitmap 原始数据指针并写入多个块
    return sfs_wblock(sfs, bitmap_getdata(sfs->freemap, NULL), SFS_BLKN_FREEMAP, nblks);
}

/*
 * sfs_clear_block - write zero info into disk (blkno, nblks)  with lock protect.
 * 清零磁盘块
 * 通常在分配新块时调用，防止新文件读取到旧数据的残留信息（安全隐患）
 * @sfs:   sfs_fs which will be process
 * @blkno: the NO. of disk block
 * @nblks: Rd/Wr number of disk block
 */
int
sfs_clear_block(struct sfs_fs *sfs, uint32_t blkno, uint32_t nblks) {
    int ret;
    lock_sfs_io(sfs);
    {
        // 准备一个全零的缓冲区
        memset(sfs->sfs_buffer, 0, SFS_BLKSIZE);
        while (nblks != 0) {
            // 将全零数据写入磁盘
            if ((ret = sfs_rwblock_nolock(sfs, sfs->sfs_buffer, blkno, 1, 1)) != 0) {
                break;
            }
            blkno ++, nblks --;
        }
    }
    unlock_sfs_io(sfs);
    return ret;
}