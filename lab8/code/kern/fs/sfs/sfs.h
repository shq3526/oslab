#ifndef __KERN_FS_SFS_SFS_H__
#define __KERN_FS_SFS_SFS_H__

#include <defs.h>
#include <mmu.h>
#include <list.h>
#include <sem.h>
#include <unistd.h>

/*
 * Simple FS (SFS) definitions visible to ucore. This covers the on-disk format
 * and is used by tools that work on SFS volumes, such as mksfs.
 * SFS 定义：涵盖磁盘格式和内存结构。
 */

/* --- 1. SFS 磁盘布局常量 --- */

#define SFS_MAGIC                                   0x2f8dbe2a              /* magic number for sfs */
#define SFS_BLKSIZE                                 PGSIZE                  /* size of block: 4096 bytes */
#define SFS_NDIRECT                                 12                      /* # of direct blocks in inode: inode 直接索引的块数 */
#define SFS_MAX_INFO_LEN                            31                      /* max length of infomation: 超级块信息字符串最大长度 */
#define SFS_MAX_FNAME_LEN                           FS_MAX_FNAME_LEN        /* max length of filename: 文件名最大长度 */
#define SFS_MAX_FILE_SIZE                           (1024UL * 1024 * 128)   /* max file size (128M): 支持的最大文件大小 */
// 磁盘布局的关键块号
#define SFS_BLKN_SUPER                              0                       /* block the superblock lives in: 超级块位于 Block 0 */
#define SFS_BLKN_ROOT                               1                       /* location of the root dir inode: 根目录 inode 位于 Block 1 */
#define SFS_BLKN_FREEMAP                            2                       /* 1st block of the freemap: 空闲位图从 Block 2 开始 */

/* # of bits in a block: 一个块能存储多少个 bit (4096 * 8 = 32768) */
#define SFS_BLKBITS                                 (SFS_BLKSIZE * CHAR_BIT)

/* # of entries in a block: 一个块能存储多少个 uint32_t (4096 / 4 = 1024) */
/* 用于间接索引块，一个间接块可以存储 1024 个块号 */
#define SFS_BLK_NENTRY                              (SFS_BLKSIZE / sizeof(uint32_t))

/* file types: 文件类型 */
#define SFS_TYPE_INVAL                              0       /* Should not appear on disk */
#define SFS_TYPE_FILE                               1       /* 普通文件 */
#define SFS_TYPE_DIR                                2       /* 目录 */
#define SFS_TYPE_LINK                               3       /* 符号链接 */

/*
 * On-disk superblock
 * SFS 超级块结构（位于 Block 0）
 * 记录整个文件系统的全局元数据
 */
struct sfs_super {
    uint32_t magic;                                 /* magic number, should be SFS_MAGIC: 魔数，用于识别文件系统 */
    uint32_t blocks;                                /* # of blocks in fs: 文件系统总块数 */
    uint32_t unused_blocks;                         /* # of unused blocks in fs: 当前未使用的块数 */
    char info[SFS_MAX_INFO_LEN + 1];                /* infomation for sfs: 描述信息字符串 */
};

/* inode (on disk)
 * SFS 磁盘索引节点结构
 * 每一个文件或目录在磁盘上都对应一个 block，其中存储了这个结构体。
 * (简化设计：一个 inode 占用整整一个块，4KB，虽然实际数据远小于 4KB)
 */
struct sfs_disk_inode {
    uint32_t size;                                  /* size of the file (in bytes): 文件大小 */
    uint16_t type;                                  /* one of SYS_TYPE_* above: 文件类型 (FILE/DIR/LINK) */
    uint16_t nlinks;                                /* # of hard links to this file: 硬链接计数 */
    uint32_t blocks;                                /* # of blocks: 该文件占用的数据块总数 */
    uint32_t direct[SFS_NDIRECT];                   /* direct blocks: 直接索引表，存储前 12 个数据块的块号 */
    uint32_t indirect;                              /* indirect blocks: 一级间接索引块的块号 */
//    uint32_t db_indirect;                           /* double indirect blocks: 二级间接索引 (未实现) */
//   unused
};

/* file entry (on disk)
 * SFS 目录项结构
 * 目录的内容就是一个 sfs_disk_entry 的数组。
 */
struct sfs_disk_entry {
    uint32_t ino;                                   /* inode number: 该文件对应的 inode 块号 (0 表示该项为空) */
    char name[SFS_MAX_FNAME_LEN + 1];               /* file name: 文件名 */
};

/* 宏：计算目录项结构在磁盘上占用的实际大小 (为了对齐等可能不仅是 sizeof) */
#define sfs_dentry_size                             \
    sizeof(((struct sfs_disk_entry *)0)->name)

/* --- 2. SFS 内存数据结构 --- */

/* inode for sfs
 * SFS 内存索引节点结构
 * 这是 VFS 层 struct inode 中的私有数据部分 (vop_info 返回的结构)
 */
struct sfs_inode {
    struct sfs_disk_inode *din;                     /* on-disk inode: 指向内存中缓存的磁盘 inode 数据副本 */
    uint32_t ino;                                   /* inode number: 该 inode 的块号 (ID) */
    bool dirty;                                     /* true if inode modified: 脏标记，表示需要写回磁盘 */
    int reclaim_count;                              /* kill inode if it hits zero: 回收计数器，用于 vop_reclaim */
    semaphore_t sem;                                /* semaphore for din: 互斥锁，保护 inode 内容的读写 */
    list_entry_t inode_link;                        /* entry for linked-list in sfs_fs: 连接到 sfs_fs->inode_list */
    list_entry_t hash_link;                         /* entry for hash linked-list in sfs_fs: 连接到哈希表，用于快速查找 */
};

/* 宏：从链表节点获取 sfs_inode 结构指针 */
#define le2sin(le, member)                          \
    to_struct((le), struct sfs_inode, member)

/* filesystem for sfs
 * SFS 文件系统控制块
 * 每一个挂载的 SFS 实例对应一个此结构
 */
struct sfs_fs {
    struct sfs_super super;                         /* on-disk superblock: 内存中的超级块副本 */
    struct device *dev;                             /* device mounted on: 底层设备句柄 (如 disk0) */
    struct bitmap *freemap;                         /* blocks in use are mared 0: 空闲块位图 (1=Free, 0=Used) */
    bool super_dirty;                               /* true if super/freemap modified: 超级块或位图的脏标记 */
    void *sfs_buffer;                               /* buffer for non-block aligned io: 临时缓冲区，用于处理未对齐的 IO */
    semaphore_t fs_sem;                             /* semaphore for fs: 文件系统级互斥锁 (保护元数据) */
    semaphore_t io_sem;                             /* semaphore for io: IO 操作互斥锁 (保护 sfs_buffer 和 IO 序列) */
    semaphore_t mutex_sem;                          /* semaphore for link/unlink and rename: 互斥锁 (重命名/链接操作) */
    list_entry_t inode_list;                        /* inode linked-list: 所有已打开的 inode 链表 */
    list_entry_t *hash_list;                        /* inode hash linked-list: inode 哈希表 */
};

/* hash for sfs: Inode 哈希表相关定义 */
#define SFS_HLIST_SHIFT                             10
#define SFS_HLIST_SIZE                              (1 << SFS_HLIST_SHIFT)
#define sin_hashfn(x)                               (hash32(x, SFS_HLIST_SHIFT))

/* size of freemap (in bits): 根据总块数计算 Freemap 需要的位数 */
#define sfs_freemap_bits(super)                     ROUNDUP((super)->blocks, SFS_BLKBITS)

/* size of freemap (in blocks): 根据总块数计算 Freemap 需要占用的磁盘块数 */
#define sfs_freemap_blocks(super)                   ROUNDUP_DIV((super)->blocks, SFS_BLKBITS)

// 前向声明
struct fs;
struct inode;

/* --- 3. SFS 函数原型 --- */

// 初始化与挂载
void sfs_init(void);
int sfs_mount(const char *devname);

// 锁操作
void lock_sfs_fs(struct sfs_fs *sfs);
void lock_sfs_io(struct sfs_fs *sfs);
void unlock_sfs_fs(struct sfs_fs *sfs);
void unlock_sfs_io(struct sfs_fs *sfs);

// 块 I/O 操作 (底层)
int sfs_rblock(struct sfs_fs *sfs, void *buf, uint32_t blkno, uint32_t nblks);
int sfs_wblock(struct sfs_fs *sfs, void *buf, uint32_t blkno, uint32_t nblks);
int sfs_rbuf(struct sfs_fs *sfs, void *buf, size_t len, uint32_t blkno, off_t offset);
int sfs_wbuf(struct sfs_fs *sfs, void *buf, size_t len, uint32_t blkno, off_t offset);
int sfs_sync_super(struct sfs_fs *sfs);
int sfs_sync_freemap(struct sfs_fs *sfs);
int sfs_clear_block(struct sfs_fs *sfs, uint32_t blkno, uint32_t nblks);

// Inode 操作
int sfs_load_inode(struct sfs_fs *sfs, struct inode **node_store, uint32_t ino);

#endif /* !__KERN_FS_SFS_SFS_H__ */