#include <defs.h>
#include <sem.h>
#include <sfs.h>


/*
 * lock_sfs_fs - lock the process of  SFS Filesystem Rd/Wr Disk Block
 *
 * called by: sfs_load_inode, sfs_sync, sfs_reclaim
 * 获取文件系统级互斥锁 (fs_sem)
 * 作用：
 * 1. 保护 SFS 的全局元数据结构（如 inode_list, hash_list）。
 * 2. 确保 sfs_sync（同步整个FS）和 sfs_load_inode（加载inode）等操作的互斥性。
 * 例如：防止两个进程同时加载同一个 inode 导致内存中出现两个副本。
 */
void
lock_sfs_fs(struct sfs_fs *sfs) {
    down(&(sfs->fs_sem));
}

/*
 * lock_sfs_io - lock the process of SFS File Rd/Wr Disk Block
 *
 * called by: sfs_rwblock, sfs_clear_block, sfs_sync_super
 * 获取 I/O 级互斥锁 (io_sem)
 * 作用：
 * 1. 保护底层块设备的读写序列，确保一次多块读写操作的原子性。
 * 2. 关键：保护 sfs->sfs_buffer 这个共享缓冲区。
 * 在 sfs_io.c 中，sfs_rbuf/sfs_wbuf 等函数会使用这个 buffer 进行 Read-Modify-Write 操作。
 * 如果不加锁，并发的 I/O 操作会互相覆盖 buffer 中的数据，导致严重的数据损坏。
 */
void
lock_sfs_io(struct sfs_fs *sfs) {
    down(&(sfs->io_sem));
}

/*
 * unlock_sfs_fs - unlock the process of  SFS Filesystem Rd/Wr Disk Block
 *
 * called by: sfs_load_inode, sfs_sync, sfs_reclaim
 * 释放文件系统级互斥锁
 */
void
unlock_sfs_fs(struct sfs_fs *sfs) {
    up(&(sfs->fs_sem));
}

/*
 * unlock_sfs_io - unlock the process of sfs Rd/Wr Disk Block
 *
 * called by: sfs_rwblock sfs_clear_block sfs_sync_super
 * 释放 I/O 级互斥锁
 */
void
unlock_sfs_io(struct sfs_fs *sfs) {
    up(&(sfs->io_sem));
}