#include <defs.h>
#include <stdio.h>
#include <string.h>
#include <vfs.h>
#include <inode.h>
#include <sem.h>
#include <kmalloc.h>
#include <error.h>
#include <proc.h>

/* 全局变量：用于保护 bootfs_node 的互斥信号量 */
static semaphore_t bootfs_sem;
/* 全局变量：指向启动文件系统（根文件系统）的根目录 inode */
static struct inode *bootfs_node = NULL;

/* 声明外部函数：初始化设备链表 (在 vfsdev.c 中定义) */
extern void vfs_devlist_init(void);

// __alloc_fs - allocate memory for fs, and set fs type
/*
 * __alloc_fs - 分配 fs 结构体内存
 * 这是一个辅助函数，通常被具体文件系统（如 SFS）的挂载函数调用。
 * @type: 文件系统类型 (例如 fs_type_sfs_info)
 */
struct fs *
__alloc_fs(int type) {
    struct fs *fs;
    if ((fs = kmalloc(sizeof(struct fs))) != NULL) {
        fs->fs_type = type;
    }
    return fs;
}

// vfs_init -  vfs initialize
/*
 * vfs_init - VFS 子系统初始化
 * 被 kern_init -> fs_init 调用。
 * 1. 初始化用于保护 bootfs 的信号量。
 * 2. 初始化设备链表 (vdev_list)，以便后续注册 stdin/stdout/disk0 等设备。
 */
void
vfs_init(void) {
    sem_init(&bootfs_sem, 1); // 初始化为互斥锁 (binary semaphore)
    vfs_devlist_init();
}

// lock_bootfs - lock  for bootfs
/*
 * lock_bootfs - 获取 bootfs 的锁
 * 在读取或修改全局变量 bootfs_node 时必须调用，防止并发冲突。
 */
static void
lock_bootfs(void) {
    down(&bootfs_sem);
}

// ulock_bootfs - ulock for bootfs
/*
 * unlock_bootfs - 释放 bootfs 的锁
 */
static void
unlock_bootfs(void) {
    up(&bootfs_sem);
}

// change_bootfs - set the new fs inode 
/*
 * change_bootfs - 原子地更新 bootfs_node
 * @node: 新的根目录 inode
 * * 逻辑：
 * 1. 加锁。
 * 2. 保存旧节点，更新 bootfs_node 为新节点。
 * 3. 解锁。
 * 4. 如果存在旧节点，减少其引用计数（如果引用减为0，可能会触发回收）。
 */
static void
change_bootfs(struct inode *node) {
    struct inode *old;
    lock_bootfs();
    {
        old = bootfs_node, bootfs_node = node;
    }
    unlock_bootfs();
    if (old != NULL) {
        vop_ref_dec(old);
    }
}

// vfs_set_bootfs - change the dir of file system
/*
 * vfs_set_bootfs - 设置启动文件系统
 * @fsname: 设备名称字符串，例如 "disk0:"
 * * 逻辑：
 * 1. 解析参数，确保格式为 "devname:"。
 * 2. vfs_chdir: 切换当前进程（通常是 initproc 或内核线程）的当前目录到该设备。
 * 这会触发 vfs_lookup 找到设备的根 inode。
 * 3. vfs_get_curdir: 获取当前目录的 inode (即设备的根目录)。
 * 4. change_bootfs: 将该 inode 设置为全局的 bootfs_node。
 */
int
vfs_set_bootfs(char *fsname) {
    struct inode *node = NULL;
    if (fsname != NULL) {
        char *s;
        // 检查格式是否包含 ':'
        if ((s = strchr(fsname, ':')) == NULL || s[1] != '\0') {
            return -E_INVAL;
        }
        int ret;
        // 尝试切换目录到该设备 (例如 cd disk0:)
        if ((ret = vfs_chdir(fsname)) != 0) {
            return ret;
        }
        // 获取切换后的当前目录 inode
        if ((ret = vfs_get_curdir(&node)) != 0) {
            return ret;
        }
    }
    // 更新全局 bootfs 指针
    change_bootfs(node);
    return 0;
}

// vfs_get_bootfs - get the inode of bootfs
/*
 * vfs_get_bootfs - 获取启动文件系统的根 inode
 * @node_store: 输出参数，用于存储 inode 指针
 * * 逻辑：
 * 1. 加锁访问 bootfs_node。
 * 2. 如果存在，增加引用计数 (vop_ref_inc)。这是必须的，防止在使用期间被回收。
 * 3. 这里的引用计数增加对应于调用者的持有，调用者用完后必须调用 vop_ref_dec。
 */
int
vfs_get_bootfs(struct inode **node_store) {
    struct inode *node = NULL;
    if (bootfs_node != NULL) {
        lock_bootfs();
        {
            if ((node = bootfs_node) != NULL) {
                vop_ref_inc(bootfs_node);
            }
        }
        unlock_bootfs();
    }
    if (node == NULL) {
        return -E_NOENT;
    }
    *node_store = node;
    return 0;
}