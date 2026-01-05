#include <defs.h>
#include <string.h>
#include <stdlib.h>
#include <list.h>
#include <stat.h>
#include <kmalloc.h>
#include <vfs.h>
#include <dev.h>
#include <sfs.h>
#include <inode.h>
#include <iobuf.h>
#include <bitmap.h>
#include <error.h>
#include <assert.h>

static const struct inode_ops sfs_node_dirops;  // dir operations 目录操作函数表
static const struct inode_ops sfs_node_fileops; // file operations 文件操作函数表

/*
 * lock_sin - lock the process of inode Rd/Wr
 * 获取 inode 的互斥锁，保护 inode 数据的一致性
 */
static void
lock_sin(struct sfs_inode *sin) {
    down(&(sin->sem));
}

/*
 * unlock_sin - unlock the process of inode Rd/Wr
 * 释放 inode 的互斥锁
 */
static void
unlock_sin(struct sfs_inode *sin) {
    up(&(sin->sem));
}

/*
 * sfs_get_ops - return function addr of fs_node_dirops/sfs_node_fileops
 * 根据 inode 类型返回对应的操作函数表
 */
static const struct inode_ops *
sfs_get_ops(uint16_t type) {
    switch (type) {
    case SFS_TYPE_DIR:
        return &sfs_node_dirops;
    case SFS_TYPE_FILE:
        return &sfs_node_fileops;
    }
    panic("invalid file type %d.\n", type);
}

/*
 * sfs_hash_list - return inode entry in sfs->hash_list
 * 计算哈希值，返回对应的哈希桶链表头
 */
static list_entry_t *
sfs_hash_list(struct sfs_fs *sfs, uint32_t ino) {
    return sfs->hash_list + sin_hashfn(ino);
}

/*
 * sfs_set_links - link inode sin in sfs->linked-list AND sfs->hash_link
 * 将 inode 加入到 SFS 的全局 inode 链表和哈希表中，便于管理和快速查找
 */
static void
sfs_set_links(struct sfs_fs *sfs, struct sfs_inode *sin) {
    list_add(&(sfs->inode_list), &(sin->inode_link));
    list_add(sfs_hash_list(sfs, sin->ino), &(sin->hash_link));
}

/*
 * sfs_remove_links - unlink inode sin in sfs->linked-list AND sfs->hash_link
 * 将 inode 从全局链表和哈希表中移除
 */
static void
sfs_remove_links(struct sfs_inode *sin) {
    list_del(&(sin->inode_link));
    list_del(&(sin->hash_link));
}

/*
 * sfs_block_inuse - check the inode with NO. ino inuse info in bitmap
 * 检查指定块号是否已被分配（通过查询位图）
 */
static bool
sfs_block_inuse(struct sfs_fs *sfs, uint32_t ino) {
    if (ino != 0 && ino < sfs->super.blocks) {
        return !bitmap_test(sfs->freemap, ino); // bitmap_test 返回 true 表示空闲，取反表示占用
    }
    panic("sfs_block_inuse: called out of range (0, %u) %u.\n", sfs->super.blocks, ino);
}

/*
 * sfs_block_alloc -  check and get a free disk block
 * 分配一个新的磁盘块
 * 1. 在位图中查找空闲位并标记为占用
 * 2. 减少超级块中的未使用块计数
 * 3. 将新块清零
 */
static int
sfs_block_alloc(struct sfs_fs *sfs, uint32_t *ino_store) {
    int ret;
    if ((ret = bitmap_alloc(sfs->freemap, ino_store)) != 0) {
        return ret;
    }
    assert(sfs->super.unused_blocks > 0);
    sfs->super.unused_blocks --, sfs->super_dirty = 1;
    assert(sfs_block_inuse(sfs, *ino_store));
    return sfs_clear_block(sfs, *ino_store, 1);
}

/*
 * sfs_block_free - set related bits for ino block to 1(means free) in bitmap, add sfs->super.unused_blocks, set superblock dirty *
 * 释放一个磁盘块
 * 1. 在位图中将对应位标记为空闲
 * 2. 增加超级块中的未使用块计数
 */
static void
sfs_block_free(struct sfs_fs *sfs, uint32_t ino) {
    assert(sfs_block_inuse(sfs, ino));
    bitmap_free(sfs->freemap, ino);
    sfs->super.unused_blocks ++, sfs->super_dirty = 1;
}

/*
 * sfs_create_inode - alloc a inode in memroy, and init din/ino/dirty/reclian_count/sem fields in sfs_inode in inode
 * 在内存中创建一个 inode 结构体并初始化
 */
static int
sfs_create_inode(struct sfs_fs *sfs, struct sfs_disk_inode *din, uint32_t ino, struct inode **node_store) {
    struct inode *node;
    if ((node = alloc_inode(sfs_inode)) != NULL) {
        vop_init(node, sfs_get_ops(din->type), info2fs(sfs, sfs));
        struct sfs_inode *sin = vop_info(node, sfs_inode);
        sin->din = din, sin->ino = ino, sin->dirty = 0, sin->reclaim_count = 1;
        sem_init(&(sin->sem), 1);
        *node_store = node;
        return 0;
    }
    return -E_NO_MEM;
}

/*
 * lookup_sfs_nolock - according ino, find related inode
 *
 * NOTICE: le2sin, info2node MACRO
 * 在内存哈希表中查找指定编号的 inode
 */
static struct inode *
lookup_sfs_nolock(struct sfs_fs *sfs, uint32_t ino) {
    struct inode *node;
    list_entry_t *list = sfs_hash_list(sfs, ino), *le = list;
    while ((le = list_next(le)) != list) {
        struct sfs_inode *sin = le2sin(le, hash_link);
        if (sin->ino == ino) {
            node = info2node(sin, sfs_inode);
            if (vop_ref_inc(node) == 1) { // 增加引用计数
                sin->reclaim_count ++;
            }
            return node;
        }
    }
    return NULL;
}

/*
 * sfs_load_inode - If the inode isn't existed, load inode related ino disk block data into a new created inode.
 * If the inode is in memory alreadily, then do nothing
 * 加载 inode：先在内存中查找，如果没找到则从磁盘读取
 */
int
sfs_load_inode(struct sfs_fs *sfs, struct inode **node_store, uint32_t ino) {
    lock_sfs_fs(sfs); // 加锁整个 SFS 结构，保护哈希表查找
    struct inode *node;
    if ((node = lookup_sfs_nolock(sfs, ino)) != NULL) {
        goto out_unlock;
    }

    int ret = -E_NO_MEM;
    struct sfs_disk_inode *din;
    if ((din = kmalloc(sizeof(struct sfs_disk_inode))) == NULL) {
        goto failed_unlock;
    }

    assert(sfs_block_inuse(sfs, ino));
    // 从磁盘读取 inode 数据块
    if ((ret = sfs_rbuf(sfs, din, sizeof(struct sfs_disk_inode), ino, 0)) != 0) {
        goto failed_cleanup_din;
    }

    assert(din->nlinks != 0);
    // 创建内存 inode 并初始化
    if ((ret = sfs_create_inode(sfs, din, ino, &node)) != 0) {
        goto failed_cleanup_din;
    }
    // 加入到全局链表和哈希表
    sfs_set_links(sfs, vop_info(node, sfs_inode));

out_unlock:
    unlock_sfs_fs(sfs);
    *node_store = node;
    return 0;

failed_cleanup_din:
    kfree(din);
failed_unlock:
    unlock_sfs_fs(sfs);
    return ret;
}

/*
 * sfs_bmap_get_sub_nolock - according entry pointer entp and index, find the index of indrect disk block
 * return the index of indrect disk block to ino_store. no lock protect
 * 处理一级间接索引块
 * @sfs:      sfs file system
 * @entp:     指向间接块索引的指针 (in/out)，如果原本为 0 且 create=true，会分配新块
 * @index:    在间接块内的索引 (0 ~ SFS_BLK_NENTRY-1)
 * @create:   是否分配
 * @ino_store: 返回实际的数据块号
 */
static int
sfs_bmap_get_sub_nolock(struct sfs_fs *sfs, uint32_t *entp, uint32_t index, bool create, uint32_t *ino_store) {
    assert(index < SFS_BLK_NENTRY);
    int ret;
    uint32_t ent, ino = 0;
    off_t offset = index * sizeof(uint32_t);  // the offset of entry in entry block
    // 如果间接块已经存在 (ent != 0)
    // if entry block is existd, read the content of entry block into  sfs->sfs_buffer
    if ((ent = *entp) != 0) {
        // 读取间接块中的内容，获取数据块号 ino
        if ((ret = sfs_rbuf(sfs, &ino, sizeof(uint32_t), ent, offset)) != 0) {
            return ret;
        }
        if (ino != 0 || !create) {
            goto out;
        }
    }
    else {
        if (!create) {
            goto out;
        }
        // 如果间接块不存在且需要创建，分配一个新的间接块
        // if entry block isn't existd, allocated a entry block (for indrect block)
        if ((ret = sfs_block_alloc(sfs, &ent)) != 0) {
            return ret;
        }
    }
    
    // 如果需要创建数据块
    if ((ret = sfs_block_alloc(sfs, &ino)) != 0) {
        goto failed_cleanup;
    }
    // 将新分配的数据块号写入间接块中
    if ((ret = sfs_wbuf(sfs, &ino, sizeof(uint32_t), ent, offset)) != 0) {
        sfs_block_free(sfs, ino);
        goto failed_cleanup;
    }

out:
    if (ent != *entp) {
        *entp = ent; // 如果分配了新的间接块，更新上层索引
    }
    *ino_store = ino;
    return 0;

failed_cleanup:
    if (ent != *entp) {
        sfs_block_free(sfs, ent);
    }
    return ret;
}

/*
 * sfs_bmap_get_nolock - according sfs_inode and index of block, find the NO. of disk block
 * no lock protect
 * 获取逻辑块号对应的物理块号。SFS 支持直接索引和一级间接索引。
 * @sfs:      sfs file system
 * @sin:      sfs inode in memory
 * @index:    文件内的逻辑块号 (0, 1, 2...)
 * @create:   如果块不存在，是否分配
 * @ino_store: 返回物理块号
 */
static int
sfs_bmap_get_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, uint32_t index, bool create, uint32_t *ino_store) {
    struct sfs_disk_inode *din = sin->din;
    int ret;
    uint32_t ent, ino;
    // 如果索引在直接索引范围内 (0 ~ 11)
    // the index of disk block is in the fist SFS_NDIRECT  direct blocks
    if (index < SFS_NDIRECT) {
        if ((ino = din->direct[index]) == 0 && create) {
            if ((ret = sfs_block_alloc(sfs, &ino)) != 0) {
                return ret;
            }
            din->direct[index] = ino;
            sin->dirty = 1;
        }
        goto out;
    }
    // 如果索引在间接索引范围内
    // the index of disk block is in the indirect blocks.
    index -= SFS_NDIRECT;
    if (index < SFS_BLK_NENTRY) {
        ent = din->indirect;
        // 调用辅助函数处理间接索引
        if ((ret = sfs_bmap_get_sub_nolock(sfs, &ent, index, create, &ino)) != 0) {
            return ret;
        }
        if (ent != din->indirect) {
            assert(din->indirect == 0);
            din->indirect = ent;
            sin->dirty = 1;
        }
        goto out;
    } else {
        panic ("sfs_bmap_get_nolock - index out of range");
    }
out:
    assert(ino == 0 || sfs_block_inuse(sfs, ino));
    *ino_store = ino;
    return 0;
}

/*
 * sfs_bmap_free_sub_nolock - set the entry item to 0 (free) in the indirect block
 * 释放间接块指向的某个数据块
 */
static int
sfs_bmap_free_sub_nolock(struct sfs_fs *sfs, uint32_t ent, uint32_t index) {
    assert(sfs_block_inuse(sfs, ent) && index < SFS_BLK_NENTRY);
    int ret;
    uint32_t ino, zero = 0;
    off_t offset = index * sizeof(uint32_t);
    // 读取间接块内容获取物理块号
    if ((ret = sfs_rbuf(sfs, &ino, sizeof(uint32_t), ent, offset)) != 0) {
        return ret;
    }
    if (ino != 0) {
        // 将间接块中的该条目置零
        if ((ret = sfs_wbuf(sfs, &zero, sizeof(uint32_t), ent, offset)) != 0) {
            return ret;
        }
        // 释放实际的数据块
        sfs_block_free(sfs, ino);
    }
    return 0;
}

/*
 * sfs_bmap_free_nolock - free a block with logical index in inode and reset the inode's fields
 * 释放 inode 指定逻辑索引的块
 */
static int
sfs_bmap_free_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, uint32_t index) {
    struct sfs_disk_inode *din = sin->din;
    int ret;
    uint32_t ent, ino;
    if (index < SFS_NDIRECT) {
        if ((ino = din->direct[index]) != 0) {
            // free the block
            sfs_block_free(sfs, ino);
            din->direct[index] = 0;
            sin->dirty = 1;
        }
        return 0;
    }

    index -= SFS_NDIRECT;
    if (index < SFS_BLK_NENTRY) {
        if ((ent = din->indirect) != 0) {
            // set the entry item to 0 in the indirect block
            if ((ret = sfs_bmap_free_sub_nolock(sfs, ent, index)) != 0) {
                return ret;
            }
        }
        return 0;
    }
    return 0;
}

/*
 * sfs_bmap_load_nolock - according to the DIR's inode and the logical index of block in inode, find the NO. of disk block.
 * 获取指定逻辑块对应的物理块号的封装函数，处理了文件扩容的情况 (index == din->blocks)
 * @sfs:      sfs file system
 * @sin:      sfs inode in memory
 * @index:    the logical index of disk block in inode
 * @ino_store:the NO. of disk block
 */
static int
sfs_bmap_load_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, uint32_t index, uint32_t *ino_store) {
    struct sfs_disk_inode *din = sin->din;
    assert(index <= din->blocks);
    int ret;
    uint32_t ino;
    // 如果 index 等于当前块数，说明需要扩容，create=true
    bool create = (index == din->blocks);
    if ((ret = sfs_bmap_get_nolock(sfs, sin, index, create, &ino)) != 0) {
        return ret;
    }
    assert(sfs_block_inuse(sfs, ino));
    if (create) {
        din->blocks ++;
    }
    if (ino_store != NULL) {
        *ino_store = ino;
    }
    return 0;
}

/*
 * sfs_bmap_truncate_nolock - free the disk block at the end of file
 * 截断文件，移除末尾的一个块
 */
static int
sfs_bmap_truncate_nolock(struct sfs_fs *sfs, struct sfs_inode *sin) {
    struct sfs_disk_inode *din = sin->din;
    assert(din->blocks != 0);
    int ret;
    if ((ret = sfs_bmap_free_nolock(sfs, sin, din->blocks - 1)) != 0) {
        return ret;
    }
    din->blocks --;
    sin->dirty = 1;
    return 0;
}

/*
 * sfs_dirent_read_nolock - read the file entry from disk block which contains this entry
 * 读取目录中的第 slot 个目录项 (sfs_disk_entry)
 * @sfs:      sfs file system
 * @sin:      sfs inode in memory (必须是目录类型)
 * @slot:     目录项的索引 (0, 1, 2...)
 * @entry:    输出缓冲区
 */
static int
sfs_dirent_read_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, int slot, struct sfs_disk_entry *entry) {
    assert(sin->din->type == SFS_TYPE_DIR && (slot >= 0 && slot < sin->din->blocks));
    int ret;
    uint32_t ino;
    // 目录文件的数据块中存储的是目录项数组。
    // 这里每个目录项占用一个 Block (这是简化设计，实际上会浪费空间)
    // according to the DIR's inode and the slot of file entry, find the index of disk block which contains this file entry
    if ((ret = sfs_bmap_load_nolock(sfs, sin, slot, &ino)) != 0) {
        return ret;
    }
    assert(sfs_block_inuse(sfs, ino));
    // read the content of file entry in the disk block 
    if ((ret = sfs_rbuf(sfs, entry, sizeof(struct sfs_disk_entry), ino, 0)) != 0) {
        return ret;
    }
    entry->name[SFS_MAX_FNAME_LEN] = '\0';
    return 0;
}

// 宏定义：用于检查 link/unlink 操作的错误
#define sfs_dirent_link_nolock_check(sfs, sin, slot, lnksin, name)                  \
    do {                                                                            \
        int err;                                                                    \
        if ((err = sfs_dirent_link_nolock(sfs, sin, slot, lnksin, name)) != 0) {    \
            warn("sfs_dirent_link error: %e.\n", err);                              \
        }                                                                           \
    } while (0)

#define sfs_dirent_unlink_nolock_check(sfs, sin, slot, lnksin)                      \
    do {                                                                            \
        int err;                                                                    \
        if ((err = sfs_dirent_unlink_nolock(sfs, sin, slot, lnksin)) != 0) {        \
            warn("sfs_dirent_unlink error: %e.\n", err);                            \
        }                                                                           \
    } while (0)

/*
 * sfs_dirent_search_nolock - read every file entry in the DIR, compare file name with each entry->name
 * If equal, then return slot and NO. of disk of this file's inode
 * 在目录中搜索指定文件名的条目
 * @sfs:        sfs file system
 * @sin:        sfs inode in memory (目录)
 * @name:       要搜索的文件名
 * @ino_store:  返回找到的文件的 inode 编号
 * @slot:       返回找到的目录项索引
 * @empty_slot: 返回第一个空的目录项索引 (用于创建新文件)
 */
static int
sfs_dirent_search_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, const char *name, uint32_t *ino_store, int *slot, int *empty_slot) {
    assert(strlen(name) <= SFS_MAX_FNAME_LEN);
    struct sfs_disk_entry *entry;
    if ((entry = kmalloc(sizeof(struct sfs_disk_entry))) == NULL) {
        return -E_NO_MEM;
    }

#define set_pvalue(x, v)            do { if ((x) != NULL) { *(x) = (v); } } while (0)
    int ret, i, nslots = sin->din->blocks;
    set_pvalue(empty_slot, nslots);
    for (i = 0; i < nslots; i ++) {
        if ((ret = sfs_dirent_read_nolock(sfs, sin, i, entry)) != 0) {
            goto out;
        }
        // 如果目录项的 inode 编号为 0，表示该项为空/已删除
        if (entry->ino == 0) {
            set_pvalue(empty_slot, i);
            continue ;
        }
        // 比较文件名
        if (strcmp(name, entry->name) == 0) {
            set_pvalue(slot, i);
            set_pvalue(ino_store, entry->ino);
            goto out;
        }
    }
#undef set_pvalue
    ret = -E_NOENT; // 未找到
out:
    kfree(entry);
    return ret;
}

/*
 * sfs_dirent_findino_nolock - read all file entries in DIR's inode and find a entry->ino == ino
 * 在目录中查找具有指定 inode 编号的条目
 */
static int
sfs_dirent_findino_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, uint32_t ino, struct sfs_disk_entry *entry) {
    int ret, i, nslots = sin->din->blocks;
    for (i = 0; i < nslots; i ++) {
        if ((ret = sfs_dirent_read_nolock(sfs, sin, i, entry)) != 0) {
            return ret;
        }
        if (entry->ino == ino) {
            return 0;
        }
    }
    return -E_NOENT;
}

/*
 * sfs_lookup_once - find inode corresponding the file name in DIR's sin inode 
 * 查找目录下的单层路径
 * @sfs:        sfs file system
 * @sin:        DIR sfs inode in memory
 * @name:       the file name in DIR
 * @node_store: the inode corresponding the file name in DIR (返回找到的 inode)
 * @slot:       the logical index of file entry
 */
static int
sfs_lookup_once(struct sfs_fs *sfs, struct sfs_inode *sin, const char *name, struct inode **node_store, int *slot) {
    int ret;
    uint32_t ino;
    lock_sin(sin);
    {   // find the NO. of disk block and logical index of file entry
        ret = sfs_dirent_search_nolock(sfs, sin, name, &ino, slot, NULL);
    }
    unlock_sin(sin);
    if (ret == 0) {
        // load the content of inode with the the NO. of disk block
        // 加载找到的 inode
        ret = sfs_load_inode(sfs, node_store, ino);
    }
    return ret;
}

// sfs_opendir - just check the opne_flags, now support readonly
// 打开目录：检查权限
static int
sfs_opendir(struct inode *node, uint32_t open_flags) {
    switch (open_flags & O_ACCMODE) {
    case O_RDONLY:
        break;
    case O_WRONLY:
    case O_RDWR:
    default:
        return -E_ISDIR;
    }
    if (open_flags & O_APPEND) {
        return -E_ISDIR;
    }
    return 0;
}

// sfs_openfile - open file (no use)
// 打开文件：目前不需要做额外操作
static int
sfs_openfile(struct inode *node, uint32_t open_flags) {
    return 0;
}

// sfs_close - close file
// 关闭文件：将 dirty 的 inode 刷回磁盘
static int
sfs_close(struct inode *node) {
    return vop_fsync(node);
}

/* * sfs_io_nolock - Rd/Wr a file contentfrom offset position to offset+ length  disk blocks<-->buffer (in memroy)
 * 核心 IO 函数 (无锁版)
 * 负责将 offset 到 offset+len 的数据在 磁盘块 和 内存 buffer 之间传输
 * @sfs:      sfs file system
 * @sin:      sfs inode in memory
 * @buf:      the buffer Rd/Wr
 * @offset:   the offset of file
 * @alenp:    the length need to read (is a pointer). and will RETURN the really Rd/Wr lenght
 * @write:    BOOL, 0 read, 1 write
 */
static int
sfs_io_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, void *buf, off_t offset, size_t *alenp, bool write) {
    struct sfs_disk_inode *din = sin->din;
    assert(din->type != SFS_TYPE_DIR);
    off_t endpos = offset + *alenp, blkoff;
    *alenp = 0;
    // calculate the Rd/Wr end position
    // 计算并检查边界
    if (offset < 0 || offset >= SFS_MAX_FILE_SIZE || offset > endpos) {
        return -E_INVAL;
    }
    if (offset == endpos) {
        return 0;
    }
    if (endpos > SFS_MAX_FILE_SIZE) {
        endpos = SFS_MAX_FILE_SIZE;
    }
    // 如果是读操作，不能超过文件实际大小
    if (!write) {
        if (offset >= din->size) {
            return 0;
        }
        if (endpos > din->size) {
            endpos = din->size;
        }
    }

    // 定义函数指针，统一处理读写差异
    int (*sfs_buf_op)(struct sfs_fs *sfs, void *buf, size_t len, uint32_t blkno, off_t offset);
    int (*sfs_block_op)(struct sfs_fs *sfs, void *buf, uint32_t blkno, uint32_t nblks);
    if (write) {
        sfs_buf_op = sfs_wbuf, sfs_block_op = sfs_wblock;
    }
    else {
        sfs_buf_op = sfs_rbuf, sfs_block_op = sfs_rblock;
    }

    int ret = 0;
    size_t size, alen = 0;
    uint32_t ino;
    uint32_t blkno = offset / SFS_BLKSIZE;          // The NO. of Rd/Wr begin block (起始逻辑块号)
    uint32_t nblks = endpos / SFS_BLKSIZE - blkno;  // The size of Rd/Wr blocks (涉及的完整块数)

  //LAB8:EXERCISE1 2312220 HINT: call sfs_bmap_load_nolock, sfs_rbuf, sfs_rblock,etc. read different kind of blocks in file
    /*
     * (1) If offset isn't aligned with the first block, Rd/Wr some content from offset to the end of the first block
     * NOTICE: useful function: sfs_bmap_load_nolock, sfs_buf_op
     * Rd/Wr size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset)
     * (2) Rd/Wr aligned blocks 
     * NOTICE: useful function: sfs_bmap_load_nolock, sfs_block_op
     * (3) If end position isn't aligned with the last block, Rd/Wr some content from begin to the (endpos % SFS_BLKSIZE) of the last block
     * NOTICE: useful function: sfs_bmap_load_nolock, sfs_buf_op    
    */
    // (1) 处理起始部分如果不按照块对齐的情况
    blkoff = offset % SFS_BLKSIZE;
    if (blkoff != 0) {
        // 如果 nblks != 0，说明操作跨越了当前块，本块只操作剩余部分
        // 如果 nblks == 0，说明操作在同一个块内结束，长度就是 endpos - offset
        size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset);
        
        // 获取/分配物理块号 (ino)
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        
        // 读/写数据
        // 注意最后一个参数 blkoff 是块内偏移
        if ((ret = sfs_buf_op(sfs, buf, size, ino, blkoff)) != 0) {
            goto out;
        }
        
        // 更新统计数据和指针
        alen += size;
        buf += size;
        
        // 如果就在这一块内完成了所有操作，直接退出
        if (nblks == 0) {
            goto out;
        }
        
        // 否则，准备处理后续块
        blkno++;
        nblks--;
    }

    // (2) 处理中间完整的块 (Aligned blocks)
    while (nblks > 0) {
        // 获取物理块号
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        
        // 对整块进行读写
        if ((ret = sfs_block_op(sfs, buf, ino, 1)) != 0) {
            goto out;
        }
        
        alen += SFS_BLKSIZE;
        buf += SFS_BLKSIZE;
        blkno++;
        nblks--;
    }

    // (3) 处理结束部分如果不按照块对齐的情况 (Last block)
    // 此时 offset 在块内肯定是 0
    if (endpos % SFS_BLKSIZE != 0) {
        size = endpos % SFS_BLKSIZE;
        
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        
        // 这里的块内偏移为 0
        if ((ret = sfs_buf_op(sfs, buf, size, ino, 0)) != 0) {
            goto out;
        }
        
        alen += size;
    }
    

out:
    *alenp = alen;
    // 如果是写操作且扩展了文件大小，更新 size 并标记 dirty
    if (offset + alen > sin->din->size) {
        sin->din->size = offset + alen;
        sin->dirty = 1;
    }
    return ret;
}

/*
 * sfs_io - Rd/Wr file. the wrapper of sfs_io_nolock
 * with lock protect
 * SFS 读写接口的包装器，负责加锁
 */
static inline int
sfs_io(struct inode *node, struct iobuf *iob, bool write) {
    struct sfs_fs *sfs = fsop_info(vop_fs(node), sfs);
    struct sfs_inode *sin = vop_info(node, sfs_inode);
    int ret;
    lock_sin(sin);
    {
        size_t alen = iob->io_resid;
        ret = sfs_io_nolock(sfs, sin, iob->io_base, iob->io_offset, &alen, write);
        if (alen != 0) {
            iobuf_skip(iob, alen); // 更新 iobuf 的状态 (offset, resid)
        }
    }
    unlock_sin(sin);
    return ret;
}

// sfs_read - read file
static int
sfs_read(struct inode *node, struct iobuf *iob) {
    return sfs_io(node, iob, 0);
}

// sfs_write - write file
static int
sfs_write(struct inode *node, struct iobuf *iob) {
    return sfs_io(node, iob, 1);
}

/*
 * sfs_fstat - Return nlinks/block/size, etc. info about a file. The pointer is a pointer to struct stat;
 * 获取文件状态信息 (如 ls -l)
 */
static int
sfs_fstat(struct inode *node, struct stat *stat) {
    int ret;
    memset(stat, 0, sizeof(struct stat));
    if ((ret = vop_gettype(node, &(stat->st_mode))) != 0) {
        return ret;
    }
    struct sfs_disk_inode *din = vop_info(node, sfs_inode)->din;
    stat->st_nlinks = din->nlinks;
    stat->st_blocks = din->blocks;
    stat->st_size = din->size;
    return 0;
}

/*
 * sfs_fsync - Force any dirty inode info associated with this file to stable storage.
 * 强制将 inode 的脏数据（元数据）写入磁盘
 */
static int
sfs_fsync(struct inode *node) {
    struct sfs_fs *sfs = fsop_info(vop_fs(node), sfs);
    struct sfs_inode *sin = vop_info(node, sfs_inode);
    int ret = 0;
    if (sin->dirty) {
        lock_sin(sin);
        {
            if (sin->dirty) {
                sin->dirty = 0;
                // 将内存中的 sfs_disk_inode 结构写入磁盘
                if ((ret = sfs_wbuf(sfs, sin->din, sizeof(struct sfs_disk_inode), sin->ino, 0)) != 0) {
                    sin->dirty = 1;
                }
            }
        }
        unlock_sin(sin);
    }
    return ret;
}

/*
 * sfs_namefile - Compute pathname relative to filesystem root of the file and copy to the specified io buffer.
 * 反向查找文件路径 (getcwd 的基础)
 * 这是一个比较复杂的操作：从当前节点不断查找 ".." (父目录)，直到根目录
 */
static int
sfs_namefile(struct inode *node, struct iobuf *iob) {
    struct sfs_disk_entry *entry;
    if (iob->io_resid <= 2 || (entry = kmalloc(sizeof(struct sfs_disk_entry))) == NULL) {
        return -E_NO_MEM;
    }

    struct sfs_fs *sfs = fsop_info(vop_fs(node), sfs);
    struct sfs_inode *sin = vop_info(node, sfs_inode);

    int ret;
    char *ptr = iob->io_base + iob->io_resid; // 从 buffer 末尾开始填充
    size_t alen, resid = iob->io_resid - 2;
    vop_ref_inc(node);
    while (1) {
        struct inode *parent;
        // 查找 ".." 获取父目录 inode
        if ((ret = sfs_lookup_once(sfs, sin, "..", &parent, NULL)) != 0) {
            goto failed;
        }

        uint32_t ino = sin->ino;
        vop_ref_dec(node);
        // 如果父目录就是自己，说明到达了根目录
        if (node == parent) {
            vop_ref_dec(node);
            break;
        }

        node = parent, sin = vop_info(node, sfs_inode);
        assert(ino != sin->ino && sin->din->type == SFS_TYPE_DIR);

        lock_sin(sin);
        {
            // 在父目录中查找自己的 inode number，从而获取自己的文件名
            ret = sfs_dirent_findino_nolock(sfs, sin, ino, entry);
        }
        unlock_sin(sin);

        if (ret != 0) {
            goto failed;
        }

        // 拼接路径字符串
        if ((alen = strlen(entry->name) + 1) > resid) {
            goto failed_nomem;
        }
        resid -= alen, ptr -= alen;
        memcpy(ptr, entry->name, alen - 1);
        ptr[alen - 1] = '/';
    }
    // 整理 buffer 内容，移动到起始位置
    alen = iob->io_resid - resid - 2;
    ptr = memmove(iob->io_base + 1, ptr, alen);
    ptr[-1] = '/', ptr[alen] = '\0';
    iobuf_skip(iob, alen);
    kfree(entry);
    return 0;

failed_nomem:
    ret = -E_NO_MEM;
failed:
    vop_ref_dec(node);
    kfree(entry);
    return ret;
}

/*
 * sfs_getdirentry_sub_noblock - get the content of file entry in DIR
 * 获取目录中第 slot 个非空闲的条目
 */
static int
sfs_getdirentry_sub_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, int slot, struct sfs_disk_entry *entry) {
    int ret, i, nslots = sin->din->blocks;
    for (i = 0; i < nslots; i ++) {
        if ((ret = sfs_dirent_read_nolock(sfs, sin, i, entry)) != 0) {
            return ret;
        }
        // 跳过空闲条目
        if (entry->ino != 0) {
            if (slot == 0) {
                return 0;
            }
            slot --;
        }
    }
    return -E_NOENT;
}

/*
 * sfs_getdirentry - according to the iob->io_offset, calculate the dir entry's slot in disk block,
 * get dir entry content from the disk 
 * 获取目录项内容 (ls 命令的基础)
 */
static int
sfs_getdirentry(struct inode *node, struct iobuf *iob) {
    struct sfs_disk_entry *entry;
    if ((entry = kmalloc(sizeof(struct sfs_disk_entry))) == NULL) {
        return -E_NO_MEM;
    }

    struct sfs_fs *sfs = fsop_info(vop_fs(node), sfs);
    struct sfs_inode *sin = vop_info(node, sfs_inode);

    int ret, slot;
    off_t offset = iob->io_offset;
    if (offset < 0 || offset % sfs_dentry_size != 0) {
        kfree(entry);
        return -E_INVAL;
    }
    if ((slot = offset / sfs_dentry_size) > sin->din->blocks) {
        kfree(entry);
        return -E_NOENT;
    }
    lock_sin(sin);
    if ((ret = sfs_getdirentry_sub_nolock(sfs, sin, slot, entry)) != 0) {
        unlock_sin(sin);
        goto out;
    }
    unlock_sin(sin);
    ret = iobuf_move(iob, entry->name, sfs_dentry_size, 1, NULL);
out:
    kfree(entry);
    return ret;
}

/*
 * sfs_reclaim - Free all resources inode occupied . Called when inode is no longer in use. 
 * 回收 inode。当 VFS 引用计数为 0 时调用。
 */
static int
sfs_reclaim(struct inode *node) {
    struct sfs_fs *sfs = fsop_info(vop_fs(node), sfs);
    struct sfs_inode *sin = vop_info(node, sfs_inode);

    int  ret = -E_BUSY;
    uint32_t ent;
    lock_sfs_fs(sfs);
    assert(sin->reclaim_count > 0);
    // 检查是否还有其他引用
    if ((-- sin->reclaim_count) != 0 || inode_ref_count(node) != 0) {
        goto failed_unlock;
    }
    // 如果硬链接数为 0，说明文件已被删除，需要释放数据块
    if (sin->din->nlinks == 0) {
        if ((ret = vop_truncate(node, 0)) != 0) {
            goto failed_unlock;
        }
    }
    if (sin->dirty) {
        if ((ret = vop_fsync(node)) != 0) {
            goto failed_unlock;
        }
    }
    sfs_remove_links(sin);
    unlock_sfs_fs(sfs);

    // 释放 inode 本身占用的块
    if (sin->din->nlinks == 0) {
        sfs_block_free(sfs, sin->ino);
        if ((ent = sin->din->indirect) != 0) {
            sfs_block_free(sfs, ent);
        }
    }
    kfree(sin->din);
    vop_kill(node);
    return 0;

failed_unlock:
    unlock_sfs_fs(sfs);
    return ret;
}

/*
 * sfs_gettype - Return type of file. The values for file types are in sfs.h.
 * 获取文件类型
 */
static int
sfs_gettype(struct inode *node, uint32_t *type_store) {
    struct sfs_disk_inode *din = vop_info(node, sfs_inode)->din;
    switch (din->type) {
    case SFS_TYPE_DIR:
        *type_store = S_IFDIR;
        return 0;
    case SFS_TYPE_FILE:
        *type_store = S_IFREG;
        return 0;
    case SFS_TYPE_LINK:
        *type_store = S_IFLNK;
        return 0;
    }
    panic("invalid file type %d.\n", din->type);
}

/* * sfs_tryseek - Check if seeking to the specified position within the file is legal.
 * 检查 seek 位置是否合法。如果超过文件大小，会进行文件扩容 (truncate)
 */
static int
sfs_tryseek(struct inode *node, off_t pos) {
    if (pos < 0 || pos >= SFS_MAX_FILE_SIZE) {
        return -E_INVAL;
    }
    struct sfs_inode *sin = vop_info(node, sfs_inode);
    if (pos > sin->din->size) {
        return vop_truncate(node, pos);
    }
    return 0;
}

/*
 * sfs_truncfile : reszie the file with new length
 * 调整文件大小 (通常用于截断或扩容)
 */
static int
sfs_truncfile(struct inode *node, off_t len) {
    if (len < 0 || len > SFS_MAX_FILE_SIZE) {
        return -E_INVAL;
    }
    struct sfs_fs *sfs = fsop_info(vop_fs(node), sfs);
    struct sfs_inode *sin = vop_info(node, sfs_inode);
    struct sfs_disk_inode *din = sin->din;

    int ret = 0;
    //new number of disk blocks of file
    uint32_t nblks, tblks = ROUNDUP_DIV(len, SFS_BLKSIZE);
    if (din->size == len) {
        assert(tblks == din->blocks);
        return 0;
    }

    lock_sin(sin);
    // old number of disk blocks of file
    nblks = din->blocks;
    if (nblks < tblks) {
        // try to enlarge the file size by add new disk block at the end of file
        // 扩容：循环分配新块
        while (nblks != tblks) {
            if ((ret = sfs_bmap_load_nolock(sfs, sin, nblks, NULL)) != 0) {
                goto out_unlock;
            }
            nblks ++;
        }
    }
    else if (tblks < nblks) {
        // try to reduce the file size 
        // 缩容：循环释放末尾块
        while (tblks != nblks) {
            if ((ret = sfs_bmap_truncate_nolock(sfs, sin)) != 0) {
                goto out_unlock;
            }
            nblks --;
        }
    }
    assert(din->blocks == tblks);
    din->size = len;
    sin->dirty = 1;

out_unlock:
    unlock_sin(sin);
    return ret;
}

/*
 * sfs_lookup - Parse path relative to the passed directory
 * DIR, and hand back the inode for the file it
 * refers to.
 * 目录查找接口
 */
static int
sfs_lookup(struct inode *node, char *path, struct inode **node_store) {
    struct sfs_fs *sfs = fsop_info(vop_fs(node), sfs);
    assert(*path != '\0' && *path != '/');
    vop_ref_inc(node);
    struct sfs_inode *sin = vop_info(node, sfs_inode);
    if (sin->din->type != SFS_TYPE_DIR) {
        vop_ref_dec(node);
        return -E_NOTDIR;
    }
    struct inode *subnode;
    // 目前仅支持单层查找 (path 中不含 /)，多层查找由 VFS 层处理
    int ret = sfs_lookup_once(sfs, sin, path, &subnode, NULL);

    vop_ref_dec(node);
    if (ret != 0) {
        return ret;
    }
    *node_store = subnode;
    return 0;
}


/* * sfs_dirent_link_nolock - create a new link (directory entry) pointing to an existing inode
 * @sfs:        sfs file system
 * @sin:        directory inode in memory
 * @name:       new file name
 * @ino:        existing inode number (target of the link)
 * 在目录下创建一个新的目录项，指向已存在的 inode (硬链接底层实现)
 */
static int
sfs_dirent_link_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, const char *name, uint32_t ino) {
    int ret, slot, empty_slot;
    uint32_t ino_store;
    
    // 1. Check if the name already exists
    // 检查文件名是否已存在
    if ((ret = sfs_dirent_search_nolock(sfs, sin, name, &ino_store, &slot, &empty_slot)) == 0) {
        return -E_EXISTS;
    }
    if (ret != -E_NOENT) {
        return ret;
    }
    
    // 2. Prepare the new entry
    // 准备新的目录项数据
    struct sfs_disk_entry *entry;
    if ((entry = kmalloc(sizeof(struct sfs_disk_entry))) == NULL) {
        return -E_NO_MEM;
    }
    memset(entry, 0, sizeof(struct sfs_disk_entry));
    strcpy(entry->name, name);
    entry->ino = ino;
    
    // 3. Get the disk block number for the empty slot (allocating if necessary)
    // 获取空槽位对应的物理块号，必要时分配新块
    uint32_t blkno;
    if ((ret = sfs_bmap_load_nolock(sfs, sin, empty_slot, &blkno)) != 0) {
        kfree(entry);
        return ret;
    }
    
    // 4. Write the entry to disk
    // 写入磁盘
    ret = sfs_wbuf(sfs, entry, sizeof(struct sfs_disk_entry), blkno, 0);
    
    kfree(entry);
    return ret;
}


/* * sfs_link - 创建硬链接
 * 逻辑：在目录中增加一个 entry，指向已有的 inode，并增加该 inode 的 nlinks
 */
static int
sfs_link(struct inode *node, const char *name, struct inode *link_node) {
    struct sfs_fs *sfs = fsop_info(vop_fs(node), sfs);
    struct sfs_inode *sin = vop_info(node, sfs_inode);
    struct sfs_inode *link_sin = vop_info(link_node, sfs_inode);
    int ret;

    // 1. 检查 link_node 是否属于同一个 fs
    if (vop_fs(node) != vop_fs(link_node)) {
        return -E_XDEV; // Cross-device link
    }
    // 2. 暂时不支持目录硬链接 (防止环路)
    if (link_sin->din->type == SFS_TYPE_DIR) {
        return -E_ISDIR;
    }

    lock_sfs_fs(sfs); // 锁整个文件系统或相关 inode
    
    // 3. 在目录下创建新条目 (link_sin->ino)
    if ((ret = sfs_dirent_link_nolock(sfs, sin, name, link_sin->ino)) == 0) {
        // 4. 增加引用计数
        link_sin->din->nlinks++;
        link_sin->dirty = 1;
    }
    
    unlock_sfs_fs(sfs);
    return ret;
}

/* * sfs_symlink - 创建软链接
 * 逻辑：创建一个新文件，类型为 LINK，内容为 path 字符串
 */
static int
sfs_symlink(struct inode *node, const char *name, const char *path) {
    struct sfs_fs *sfs = fsop_info(vop_fs(node), sfs);
    struct inode *new_node;
    int ret;

    // 1. 创建一个新文件 (inode)
    if ((ret = vop_create(node, name, 1, &new_node)) != 0) {
        return ret;
    }
    
    struct sfs_inode *new_sin = vop_info(new_node, sfs_inode);
    
    // 2. 修改类型为 LINK
    new_sin->din->type = SFS_TYPE_LINK;
    new_sin->dirty = 1;
    
    // 3. 写入路径字符串到数据块
    size_t len = strlen(path);
    struct iobuf __iob, *iob = iobuf_init(&__iob, (void *)path, len, 0);
    ret = vop_write(new_node, iob);
    
    vop_ref_dec(new_node);
    return ret;
}



// The sfs specific DIR operations correspond to the abstract operations on a inode.
// SFS 目录操作函数表
static const struct inode_ops sfs_node_dirops = {
    .vop_magic                      = VOP_MAGIC,
    .vop_open                       = sfs_opendir,
    .vop_close                      = sfs_close,
    .vop_fstat                      = sfs_fstat,
    .vop_fsync                      = sfs_fsync,
    .vop_namefile                   = sfs_namefile,
    .vop_getdirentry                = sfs_getdirentry,
    .vop_reclaim                    = sfs_reclaim,
    .vop_gettype                    = sfs_gettype,
    .vop_lookup                     = sfs_lookup,

    .vop_link = sfs_link,
    .vop_symlink = sfs_symlink,
};
/// The sfs specific FILE operations correspond to the abstract operations on a inode.
// SFS 文件操作函数表
static const struct inode_ops sfs_node_fileops = {
    .vop_magic                      = VOP_MAGIC,
    .vop_open                       = sfs_openfile,
    .vop_close                      = sfs_close,
    .vop_read                       = sfs_read,
    .vop_write                      = sfs_write,
    .vop_fstat                      = sfs_fstat,
    .vop_fsync                      = sfs_fsync,
    .vop_reclaim                    = sfs_reclaim,
    .vop_gettype                    = sfs_gettype,
    .vop_tryseek                    = sfs_tryseek,
    .vop_truncate                   = sfs_truncfile,
};