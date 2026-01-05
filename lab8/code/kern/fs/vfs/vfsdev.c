/*
 * kern/fs/vfs/vfsdev.c
 * * 详细功能说明：
 * 1. 维护一个全局的双向链表 vdev_list，记录所有注册到 VFS 的设备和文件系统。
 * 2. 实现了设备的注册接口 (vfs_add_dev) 和文件系统的注册接口 (vfs_add_fs)。
 * 3. 实现了挂载 (mount) 和卸载 (unmount) 操作，负责建立设备与具体文件系统实例 (struct fs) 之间的关联。
 * 4. 提供了根据设备名查找根 inode 的接口 (vfs_get_root)。
 * - 对于挂载了文件系统的设备（如 disk0），返回该文件系统的根目录 inode。
 * - 对于不可挂载的设备（如 stdin），直接返回代表该设备的 inode。
 */

#include <defs.h>
#include <stdio.h>
#include <string.h>
#include <vfs.h>
#include <dev.h>
#include <inode.h>
#include <sem.h>
#include <list.h>
#include <kmalloc.h>
#include <unistd.h>
#include <error.h>
#include <assert.h>
#include <proc.h>

// device info entry in vdev_list 
// VFS 设备描述符结构体，用于在 vdev_list 链表中记录一个设备的信息
typedef struct {
    const char *devname;       // 设备名称，例如 "disk0", "stdin"
    struct inode *devnode;     // 设备对应的 inode 指针 (如果是 raw device)
    struct fs *fs;             // 挂载在此设备上的文件系统控制块指针 (如果已挂载)
    bool mountable;            // 是否可挂载：true 表示是块设备(如 disk0)，可以挂载 FS；
                               //             false 表示是字符设备(如 stdin)或虚拟 FS
    list_entry_t vdev_link;    // 链表节点，用于链接到全局 vdev_list
} vfs_dev_t;

// 宏：通过链表节点获取 vfs_dev_t 结构体指针
#define le2vdev(le, member)                         \
    to_struct((le), vfs_dev_t, member)

static list_entry_t vdev_list;     // device info list in vfs layer 全局设备链表头
static semaphore_t vdev_list_sem;  // 保护设备链表的互斥信号量

// 获取链表锁
static void
lock_vdev_list(void) {
    down(&vdev_list_sem);
}

// 释放链表锁
static void
unlock_vdev_list(void) {
    up(&vdev_list_sem);
}

// 初始化 VFS 设备列表机制
void
vfs_devlist_init(void) {
    list_init(&vdev_list);
    sem_init(&vdev_list_sem, 1);
}

// vfs_cleanup - finally clean (or sync) fs
// 清理/同步所有文件系统。通常在系统关闭或 panic 时调用。
void
vfs_cleanup(void) {
    if (!list_empty(&vdev_list)) {
        lock_vdev_list();
        {
            list_entry_t *list = &vdev_list, *le = list;
            while ((le = list_next(le)) != list) {
                vfs_dev_t *vdev = le2vdev(le, vdev_link);
                // 如果设备上挂载了文件系统，调用该文件系统的清理函数 (通常对应 sfs_sync)
                if (vdev->fs != NULL) {
                    fsop_cleanup(vdev->fs);
                }
            }
        }
        unlock_vdev_list();
    }
}

/*
 * vfs_get_root - Given a device name (stdin, stdout, etc.), hand
 * back an appropriate inode.
 * 根据设备名获取根 inode。这是路径解析的起点。
 * @devname: 设备名字符串 (如 "disk0", "stdin")
 * @node_store: 输出参数，返回找到的 inode
 */
int
vfs_get_root(const char *devname, struct inode **node_store) {
    assert(devname != NULL);
    int ret = -E_NO_DEV;
    if (!list_empty(&vdev_list)) {
        lock_vdev_list();
        {
            list_entry_t *list = &vdev_list, *le = list;
            while ((le = list_next(le)) != list) {
                vfs_dev_t *vdev = le2vdev(le, vdev_link);
                // 查找匹配的设备名
                if (strcmp(devname, vdev->devname) == 0) {
                    struct inode *found = NULL;
                    // 情况1: 设备上已挂载文件系统 (如 disk0)
                    if (vdev->fs != NULL) {
                        // 返回文件系统的根目录 inode
                        found = fsop_get_root(vdev->fs);
                    }
                    // 情况2: 设备不可挂载 (如 stdin/stdout 字符设备)
                    else if (!vdev->mountable) {
                        // 增加引用计数，直接返回设备本身的 inode
                        vop_ref_inc(vdev->devnode);
                        found = vdev->devnode;
                    }
                    // 情况3: 可挂载设备但未挂载 -> 错误 (E_NA_DEV: Device Not Available)
                    
                    if (found != NULL) {
                        ret = 0, *node_store = found;
                    }
                    else {
                        ret = -E_NA_DEV;
                    }
                    break;
                }
            }
        }
        unlock_vdev_list();
    }
    return ret;
}

/*
 * vfs_get_devname - Given a filesystem, hand back the name of the device it's mounted on.
 * 反向查找：根据 fs 结构体指针找到对应的设备名。
 */
const char *
vfs_get_devname(struct fs *fs) {
    assert(fs != NULL);
    list_entry_t *list = &vdev_list, *le = list;
    while ((le = list_next(le)) != list) {
        vfs_dev_t *vdev = le2vdev(le, vdev_link);
        if (vdev->fs == fs) {
            return vdev->devname;
        }
    }
    return NULL;
}

/*
 * check_devname_confilct - Is there alreadily device which has the same name?
 * 检查设备名冲突：遍历链表，确保新注册的设备名唯一。
 */
static bool
check_devname_conflict(const char *devname) {
    list_entry_t *list = &vdev_list, *le = list;
    while ((le = list_next(le)) != list) {
        vfs_dev_t *vdev = le2vdev(le, vdev_link);
        if (strcmp(vdev->devname, devname) == 0) {
            return 0; // Conflict found
        }
    }
    return 1; // No conflict
}


/*
* vfs_do_add - Add a new device to the VFS layer's device table.
* 内部函数：向 VFS 设备表添加新项。
*
* If "mountable" is set, the device will be treated as one that expects
* to have a filesystem mounted on it, and a raw device will be created
* for direct access.
*/
static int
vfs_do_add(const char *devname, struct inode *devnode, struct fs *fs, bool mountable) {
    assert(devname != NULL);
    // 约束检查：要么是 (无设备节点且不可挂载，用于纯逻辑FS)，要么是 (有设备节点且是设备类型)
    assert((devnode == NULL && !mountable) || (devnode != NULL && check_inode_type(devnode, device)));
    if (strlen(devname) > FS_MAX_DNAME_LEN) {
        return -E_TOO_BIG;
    }

    int ret = -E_NO_MEM;
    char *s_devname;
    // 复制设备名字符串
    if ((s_devname = strdup(devname)) == NULL) {
        return ret;
    }

    vfs_dev_t *vdev;
    // 分配 vfs_dev_t 结构体
    if ((vdev = kmalloc(sizeof(vfs_dev_t))) == NULL) {
        goto failed_cleanup_name;
    }

    ret = -E_EXISTS;
    lock_vdev_list();
    // 检查名字是否冲突
    if (!check_devname_conflict(s_devname)) {
        unlock_vdev_list();
        goto failed_cleanup_vdev;
    }
    // 初始化设备项
    vdev->devname = s_devname;
    vdev->devnode = devnode;
    vdev->mountable = mountable;
    vdev->fs = fs;

    // 加入全局链表
    list_add(&vdev_list, &(vdev->vdev_link));
    unlock_vdev_list();
    return 0;

failed_cleanup_vdev:
    kfree(vdev);
failed_cleanup_name:
    kfree(s_devname);
    return ret;
}

/*
 * vfs_add_fs - Add a new fs,  by name. See  vfs_do_add information for the description of
 * mountable.
 * 注册一个逻辑文件系统（不依赖具体物理设备，如 procfs，虽然 ucore 中暂未深入使用）。
 */
int
vfs_add_fs(const char *devname, struct fs *fs) {
    return vfs_do_add(devname, NULL, fs, 0);
}

/*
 * vfs_add_dev - Add a new device, by name. See  vfs_do_add information for the description of
 * mountable.
 * 注册一个具体设备（如 disk0, stdin）。
 * @devnode: 设备的 inode (由 dev_create_inode 创建)
 * @mountable: 是否可挂载文件系统
 */
int
vfs_add_dev(const char *devname, struct inode *devnode, bool mountable) {
    return vfs_do_add(devname, devnode, NULL, mountable);
}

/*
 * find_mount - Look for a mountable device named DEVNAME.
 * Should already hold vdev_list lock.
 * 查找指定名称的可挂载设备项。
 */
static int
find_mount(const char *devname, vfs_dev_t **vdev_store) {
    assert(devname != NULL);
    list_entry_t *list = &vdev_list, *le = list;
    while ((le = list_next(le)) != list) {
        vfs_dev_t *vdev = le2vdev(le, vdev_link);
        if (vdev->mountable && strcmp(vdev->devname, devname) == 0) {
            *vdev_store = vdev;
            return 0;
        }
    }
    return -E_NO_DEV;
}

/*
 * vfs_mount - Mount a filesystem. Once we've found the device, call MOUNTFUNC to
 * set up the filesystem and hand back a struct fs.
 *
 * The DATA argument is passed through unchanged to MOUNTFUNC.
 * 挂载操作的核心函数。
 * @devname: 目标设备名 (如 "disk0")
 * @mountfunc: 具体文件系统的挂载回调函数 (如 sfs_do_mount)
 */
int
vfs_mount(const char *devname, int (*mountfunc)(struct device *dev, struct fs **fs_store)) {
    int ret;
    lock_vdev_list();
    vfs_dev_t *vdev;
    // 1. 查找是否存在该名称的可挂载设备
    if ((ret = find_mount(devname, &vdev)) != 0) {
        goto out;
    }
    // 2. 检查该设备是否已经挂载了文件系统
    if (vdev->fs != NULL) {
        ret = -E_BUSY;
        goto out;
    }
    assert(vdev->devname != NULL && vdev->mountable);

    // 3. 从设备的 inode 中提取 struct device 指针
    struct device *dev = vop_info(vdev->devnode, device);
    // 4. 调用具体文件系统的挂载函数，初始化 fs 结构
    if ((ret = mountfunc(dev, &(vdev->fs))) == 0) {
        assert(vdev->fs != NULL);
        cprintf("vfs: mount %s.\n", vdev->devname);
    }

out:
    unlock_vdev_list();
    return ret;
}

/*
 * vfs_unmount - Unmount a filesystem/device by name.
 * First calls FSOP_SYNC on the filesystem; then calls FSOP_UNMOUNT.
 * 卸载文件系统。
 */
int
vfs_unmount(const char *devname) {
    int ret;
    lock_vdev_list();
    vfs_dev_t *vdev;
    // 1. 查找设备
    if ((ret = find_mount(devname, &vdev)) != 0) {
        goto out;
    }
    // 2. 检查是否挂载了 FS
    if (vdev->fs == NULL) {
        ret = -E_INVAL;
        goto out;
    }
    assert(vdev->devname != NULL && vdev->mountable);

    // 3. 先同步数据 (Sync)
    if ((ret = fsop_sync(vdev->fs)) != 0) {
        goto out;
    }
    // 4. 执行具体文件系统的卸载清理逻辑 (Unmount)
    if ((ret = fsop_unmount(vdev->fs)) == 0) {
        vdev->fs = NULL;
        cprintf("vfs: unmount %s.\n", vdev->devname);
    }

out:
    unlock_vdev_list();
    return ret;
}

/*
 * vfs_unmount_all - Global unmount function.
 * 卸载所有文件系统。通常在系统关机前调用，确保数据刷盘。
 */
int
vfs_unmount_all(void) {
    if (!list_empty(&vdev_list)) {
        lock_vdev_list();
        {
            list_entry_t *list = &vdev_list, *le = list;
            while ((le = list_next(le)) != list) {
                vfs_dev_t *vdev = le2vdev(le, vdev_link);
                // 遍历所有可挂载且已挂载的设备
                if (vdev->mountable && vdev->fs != NULL) {
                    int ret;
                    if ((ret = fsop_sync(vdev->fs)) != 0) {
                        cprintf("vfs: warning: sync failed for %s: %e.\n", vdev->devname, ret);
                        continue ;
                    }
                    if ((ret = fsop_unmount(vdev->fs)) != 0) {
                        cprintf("vfs: warning: unmount failed for %s: %e.\n", vdev->devname, ret);
                        continue ;
                    }
                    vdev->fs = NULL;
                    cprintf("vfs: unmount %s.\n", vdev->devname);
                }
            }
        }
        unlock_vdev_list();
    }
    return 0;
}