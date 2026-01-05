#include <defs.h>
#include <stdio.h>
#include <string.h>
#include <kmalloc.h>
#include <list.h>
#include <fs.h>
#include <vfs.h>
#include <dev.h>
#include <sfs.h>
#include <inode.h>
#include <iobuf.h>
#include <bitmap.h>
#include <error.h>
#include <assert.h>
#include <proc.h>

/*
 * sfs_sync - sync sfs's superblock and freemap in memroy into disk
 * 将内存中 SFS 的状态同步回磁盘。
 * 1. 遍历内存中的所有 inode，将修改过的数据写入磁盘。
 * 2. 如果超级块被标记为 dirty，则将超级块和 freemap 写入磁盘。
 */
static int
sfs_sync(struct fs *fs) {
    struct sfs_fs *sfs = fsop_info(fs, sfs);
    lock_sfs_fs(sfs); // 加锁，保护 SFS 元数据
    {
        // 遍历 sfs->inode_list 链表，这个链表记录了所有当前被打开的 inode
        list_entry_t *list = &(sfs->inode_list), *le = list;
        while ((le = list_next(le)) != list) {
            struct sfs_inode *sin = le2sin(le, inode_link);
            // 对每个 inode 调用 vop_fsync，将其脏数据冲刷到磁盘
            vop_fsync(info2node(sin, sfs_inode));
        }
    }
    unlock_sfs_fs(sfs);

    int ret;
    // 如果文件系统的元数据（超级块或位图）被修改过
    if (sfs->super_dirty) {
        sfs->super_dirty = 0;
        // 将超级块信息写入磁盘 block 0
        if ((ret = sfs_sync_super(sfs)) != 0) {
            sfs->super_dirty = 1;
            return ret;
        }
        // 将空闲块位图（freemap）写入磁盘
        if ((ret = sfs_sync_freemap(sfs)) != 0) {
            sfs->super_dirty = 1;
            return ret;
        }
    }
    return 0;
}

/*
 * sfs_get_root - get the root directory inode  from disk (SFS_BLKN_ROOT,1)
 * 获取根目录的 inode。
 * SFS 规定根目录总是位于磁盘的 Block 1 (SFS_BLKN_ROOT)。
 */
static struct inode *
sfs_get_root(struct fs *fs) {
    struct inode *node;
    int ret;
    // 调用 sfs_load_inode 从磁盘加载编号为 SFS_BLKN_ROOT 的 inode
    if ((ret = sfs_load_inode(fsop_info(fs, sfs), &node, SFS_BLKN_ROOT)) != 0) {
        panic("load sfs root failed: %e", ret);
    }
    return node;
}

/*
 * sfs_unmount - unmount sfs, and free the memorys contain sfs->freemap/sfs_buffer/hash_liskt and sfs itself.
 * 卸载 SFS 文件系统。
 */
static int
sfs_unmount(struct fs *fs) {
    struct sfs_fs *sfs = fsop_info(fs, sfs);
    // 检查 inode_list，如果不为空，说明还有文件被打开，不能卸载，返回 E_BUSY
    if (!list_empty(&(sfs->inode_list))) {
        return -E_BUSY;
    }
    // 卸载前必须保证数据已同步
    assert(!sfs->super_dirty);
    // 释放内存中的位图
    bitmap_destroy(sfs->freemap);
    // 释放临时缓冲区
    kfree(sfs->sfs_buffer);
    // 释放 inode 哈希表
    kfree(sfs->hash_list);
    // 释放 sfs_fs 结构体本身
    kfree(sfs);
    return 0;
}

/*
 * sfs_cleanup - when sfs failed, then should call this function to sync sfs by calling sfs_sync
 * 清理函数。当 SFS 发生错误时尝试同步数据，避免数据丢失。
 * NOTICE: nouse now. 目前似乎未被大量使用。
 */
static void
sfs_cleanup(struct fs *fs) {
    struct sfs_fs *sfs = fsop_info(fs, sfs);
    uint32_t blocks = sfs->super.blocks, unused_blocks = sfs->super.unused_blocks;
    cprintf("sfs: cleanup: '%s' (%d/%d/%d)\n", sfs->super.info,
            blocks - unused_blocks, unused_blocks, blocks);
    int i, ret;
    // 尝试多次同步，确保数据写入
    for (i = 0; i < 32; i ++) {
        if ((ret = fsop_sync(fs)) == 0) {
            break;
        }
    }
    if (ret != 0) {
        warn("sfs: sync error: '%s': %e.\n", sfs->super.info, ret);
    }
}

/*
 * sfs_init_read - used in sfs_do_mount to read disk block(blkno, 1) directly.
 * 辅助函数：直接读取磁盘的一个块。
 *
 * @dev:        块设备句柄 (disk0)
 * @blkno:      要读取的磁盘块号
 * @blk_buffer: 数据存放的缓冲区
 *
 * (1) init iobuf: 初始化缓冲区描述符
 * (2) read dev into iobuf: 调用设备驱动读取数据
 */
static int
sfs_init_read(struct device *dev, uint32_t blkno, void *blk_buffer) {
    struct iobuf __iob, *iob = iobuf_init(&__iob, blk_buffer, SFS_BLKSIZE, blkno * SFS_BLKSIZE);
    return dop_io(dev, iob, 0); // 0 表示读取 (Read)
}

/*
 * sfs_init_freemap - used in sfs_do_mount to read freemap data info in disk block(blkno, nblks) directly.
 * 辅助函数：初始化 freemap。从磁盘读取空闲位图数据到内存 bitmap 结构中。
 *
 * @dev:        块设备
 * @bitmap:     内存中已分配的 bitmap 结构
 * @blkno:      freemap 在磁盘上的起始块号
 * @nblks:      freemap 占用的磁盘块数
 * @blk_buffer: 临时缓冲区
 */
static int
sfs_init_freemap(struct device *dev, struct bitmap *freemap, uint32_t blkno, uint32_t nblks, void *blk_buffer) {
    size_t len;
    // 获取 bitmap 内部数据存储区的指针
    void *data = bitmap_getdata(freemap, &len);
    assert(data != NULL && len == nblks * SFS_BLKSIZE);
    // 循环读取 freemap 占用的所有磁盘块
    while (nblks != 0) {
        int ret;
        // 每次读取一个块的数据到 bitmap->map 中
        if ((ret = sfs_init_read(dev, blkno, data)) != 0) {
            return ret;
        }
        blkno ++, nblks --, data += SFS_BLKSIZE;
    }
    return 0;
}

/*
 * sfs_do_mount - mount sfs file system.
 * SFS 挂载的核心逻辑。
 *
 * @dev:        包含 SFS 文件系统的块设备
 * @fs_store:   输出参数，返回构建好的 fs 结构体
 */
static int
sfs_do_mount(struct device *dev, struct fs **fs_store) {
    // 静态断言：确保 SFS 的关键数据结构都能放进一个磁盘块中
    static_assert(SFS_BLKSIZE >= sizeof(struct sfs_super));
    static_assert(SFS_BLKSIZE >= sizeof(struct sfs_disk_inode));
    static_assert(SFS_BLKSIZE >= sizeof(struct sfs_disk_entry));

    // 检查设备块大小是否符合 SFS 要求 (4096 字节)
    if (dev->d_blocksize != SFS_BLKSIZE) {
        return -E_NA_DEV;
    }

    /* allocate fs structure */
    // 分配 fs 和 sfs_fs 结构体的内存
    struct fs *fs;
    if ((fs = alloc_fs(sfs)) == NULL) {
        return -E_NO_MEM;
    }
    // fsop_info 将 generic fs 指针转换为 sfs_fs 指针
    struct sfs_fs *sfs = fsop_info(fs, sfs);
    sfs->dev = dev;

    int ret = -E_NO_MEM;

    // 分配临时缓冲区，用于读取 superblock 等元数据
    void *sfs_buffer;
    if ((sfs->sfs_buffer = sfs_buffer = kmalloc(SFS_BLKSIZE)) == NULL) {
        goto failed_cleanup_fs;
    }

    /* load and check superblock */
    // 1. 读取超级块 (Superblock)。SFS 规定它在磁盘的 Block 0。
    if ((ret = sfs_init_read(dev, SFS_BLKN_SUPER, sfs_buffer)) != 0) {
        goto failed_cleanup_sfs_buffer;
    }

    ret = -E_INVAL;

    struct sfs_super *super = sfs_buffer;
    // 检查魔数 (Magic Number)，确认这是合法的 SFS 文件系统
    if (super->magic != SFS_MAGIC) {
        cprintf("sfs: wrong magic in superblock. (%08x should be %08x).\n",
                super->magic, SFS_MAGIC);
        goto failed_cleanup_sfs_buffer;
    }
    // 检查文件系统的总块数是否超过了物理设备的容量
    if (super->blocks > dev->d_blocks) {
        cprintf("sfs: fs has %u blocks, device has %u blocks.\n",
                super->blocks, dev->d_blocks);
        goto failed_cleanup_sfs_buffer;
    }
    super->info[SFS_MAX_INFO_LEN] = '\0';
    sfs->super = *super; // 将超级块信息保存到 sfs 结构体中

    ret = -E_NO_MEM;

    uint32_t i;

    /* alloc and initialize hash list */
    // 初始化 Inode 哈希表，用于快速查找内存中已缓存的 Inode
    list_entry_t *hash_list;
    if ((sfs->hash_list = hash_list = kmalloc(sizeof(list_entry_t) * SFS_HLIST_SIZE)) == NULL) {
        goto failed_cleanup_sfs_buffer;
    }
    for (i = 0; i < SFS_HLIST_SIZE; i ++) {
        list_init(hash_list + i);
    }

    /* load and check freemap */
    // 2. 初始化空闲位图 (Freemap)。
    struct bitmap *freemap;
    // 计算 Freemap 需要多少位 (nbits)
    uint32_t freemap_size_nbits = sfs_freemap_bits(super);
    // 创建内存 bitmap 对象
    if ((sfs->freemap = freemap = bitmap_create(freemap_size_nbits)) == NULL) {
        goto failed_cleanup_hash_list;
    }
    // 计算 Freemap 占用多少个磁盘块
    uint32_t freemap_size_nblks = sfs_freemap_blocks(super);
    // 从磁盘读取 Freemap 数据 (SFS_BLKN_FREEMAP 是 Block 2，紧接在 Root Inode 后面)
    if ((ret = sfs_init_freemap(dev, freemap, SFS_BLKN_FREEMAP, freemap_size_nblks, sfs_buffer)) != 0) {
        goto failed_cleanup_freemap;
    }

    // 校验：统计位图中空闲位的数量，看是否与超级块中记录的 unused_blocks 一致
    uint32_t blocks = sfs->super.blocks, unused_blocks = 0;
    for (i = 0; i < freemap_size_nbits; i ++) {
        if (bitmap_test(freemap, i)) {
            unused_blocks ++;
        }
    }
    assert(unused_blocks == sfs->super.unused_blocks);

    /* and other fields */
    // 初始化其他 SFS 管理字段
    sfs->super_dirty = 0;
    sem_init(&(sfs->fs_sem), 1);    // 文件系统级互斥锁
    sem_init(&(sfs->io_sem), 1);    // IO 操作互斥锁
    sem_init(&(sfs->mutex_sem), 1); // 互斥锁
    list_init(&(sfs->inode_list));  // 初始化活动 inode 链表
    cprintf("sfs: mount: '%s' (%d/%d/%d)\n", sfs->super.info,
            blocks - unused_blocks, unused_blocks, blocks);

    /* link addr of sync/get_root/unmount/cleanup funciton  fs's function pointers*/
    // 3. 将 SFS 的具体实现函数绑定到 VFS 的抽象接口上
    fs->fs_sync = sfs_sync;
    fs->fs_get_root = sfs_get_root;
    fs->fs_unmount = sfs_unmount;
    fs->fs_cleanup = sfs_cleanup;
    
    // 返回初始化好的 fs 结构体
    *fs_store = fs;
    return 0;

// 错误处理路径：按分配顺序的逆序释放资源
failed_cleanup_freemap:
    bitmap_destroy(freemap);
failed_cleanup_hash_list:
    kfree(hash_list);
failed_cleanup_sfs_buffer:
    kfree(sfs_buffer);
failed_cleanup_fs:
    kfree(fs);
    return ret;
}

// SFS 挂载的对外接口
// 调用 VFS 层的 vfs_mount，并将 sfs_do_mount 作为回调函数传入
int
sfs_mount(const char *devname) {
    return vfs_mount(devname, sfs_do_mount);
}