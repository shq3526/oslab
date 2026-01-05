/*
 * kern/fs/vfs/vfs.h
 *
 * 详细功能说明：
 * 1. 定义了文件系统的抽象基类 struct fs。所有的具体文件系统（如 SFS）都必须“继承”这个结构
 * （通过包含私有数据成员），并实现其定义的接口函数（fs_sync, fs_get_root 等）。
 * 2. 声明了 VFS 层的核心 API。这些 API 处于内核的高层，向上对接系统调用（System Calls），
 * 向下调用具体文件系统的 inode 操作（vop_*）。
 * 3. 提供了挂载（Mount）、卸载（Unmount）、设备注册（Add Dev）等管理功能。
 * 4. 提供了路径名解析（Lookup）功能，将字符串路径转换为 Inode。
 */

#ifndef __KERN_FS_VFS_VFS_H__
#define __KERN_FS_VFS_VFS_H__

#include <defs.h>
#include <fs.h>
#include <sfs.h>

struct inode;   // abstract structure for an on-disk file (inode.h)
struct device;  // abstract structure for a device (dev.h)
struct iobuf;   // kernel or userspace I/O buffer (iobuf.h)

/*
 * Abstract filesystem. (Or device accessible as a file.)
 * 抽象文件系统结构体。（或者作为文件可访问的设备）
 *
 * Information:
 * fs_info   : filesystem-specific data (sfs_fs) - 具体文件系统的私有数据
 * fs_type   : filesystem type - 文件系统类型标识
 * Operations:
 * fs_sync       - Flush all dirty buffers to disk. - 同步元数据到磁盘
 * fs_get_root   - Return root inode of filesystem. - 获取该文件系统的根目录 inode
 * fs_unmount    - Attempt unmount of filesystem. - 卸载文件系统
 * fs_cleanup    - Cleanup of filesystem.??? - 清理操作
 *
 * fs_get_root should increment the refcount of the inode returned.
 * It should not ever return NULL.
 * fs_get_root 返回 inode 时必须增加引用计数。
 *
 * If fs_unmount returns an error, the filesystem stays mounted, and
 * consequently the struct fs instance should remain valid. On success,
 * however, the filesystem object and all storage associated with the
 * filesystem should have been discarded/released.
 */
struct fs {
    union {
        // 使用 union 实现多态，存储具体文件系统的数据
        struct sfs_fs __sfs_info;                   
    } fs_info;                                     // filesystem-specific data 
    enum {
        fs_type_sfs_info,
    } fs_type;                                     // filesystem type 
    
    // 函数指针表 (Vtable)
    int (*fs_sync)(struct fs *fs);                 // Flush all dirty buffers to disk 
    struct inode *(*fs_get_root)(struct fs *fs);   // Return root inode of filesystem.
    int (*fs_unmount)(struct fs *fs);              // Attempt unmount of filesystem.
    void (*fs_cleanup)(struct fs *fs);             // Cleanup of filesystem.???
};

// 宏：生成文件系统类型枚举值
#define __fs_type(type)                                             fs_type_##type##_info

// 宏：检查文件系统类型
#define check_fs_type(fs, type)                                     ((fs)->fs_type == __fs_type(type))

// 宏：获取具体文件系统的私有信息结构体指针
// 包含类型检查断言
#define __fsop_info(_fs, type) ({                                   \
            struct fs *__fs = (_fs);                                \
            assert(__fs != NULL && check_fs_type(__fs, type));      \
            &(__fs->fs_info.__##type##_info);                       \
        })

#define fsop_info(fs, type)                 __fsop_info(fs, type)

// 宏：从私有信息结构体指针反推 struct fs 指针
// 利用 container_of 原理
#define info2fs(info, type)                                         \
    to_struct((info), struct fs, fs_info.__##type##_info)

// 分配 fs 结构体的函数原型
struct fs *__alloc_fs(int type);

// 宏：分配指定类型的 fs
#define alloc_fs(type)                                              __alloc_fs(__fs_type(type))

// Macros to shorten the calling sequences.
// 调用 fs 操作函数的快捷宏
#define fsop_sync(fs)                       ((fs)->fs_sync(fs))
#define fsop_get_root(fs)                   ((fs)->fs_get_root(fs))
#define fsop_unmount(fs)                    ((fs)->fs_unmount(fs))
#define fsop_cleanup(fs)                    ((fs)->fs_cleanup(fs))

/*
 * Virtual File System layer functions.
 *
 * The VFS layer translates operations on abstract on-disk files or
 * pathnames to operations on specific files on specific filesystems.
 */
// VFS 子系统初始化
void vfs_init(void);
void vfs_cleanup(void);
// 设备链表初始化
void vfs_devlist_init(void);

/*
 * VFS layer low-level operations. 
 * See inode.h for direct operations on inodes.
 * See fs.h for direct operations on filesystems/devices.
 *
 * vfs_set_curdir   - change current directory of current thread by inode
 * vfs_get_curdir   - retrieve inode of current directory of current thread
 * vfs_get_root     - get root inode for the filesystem named DEVNAME
 * vfs_get_devname  - get mounted device name for the filesystem passed in
 */
// 设置当前进程的当前工作目录 (cd)
int vfs_set_curdir(struct inode *dir);
// 获取当前进程的当前工作目录 inode
int vfs_get_curdir(struct inode **dir_store);
// 根据设备名获取其根目录 inode
int vfs_get_root(const char *devname, struct inode **root_store);
// 获取文件系统对应的设备名
const char *vfs_get_devname(struct fs *fs);


/*
 * VFS layer high-level operations on pathnames
 * Because namei may destroy pathnames, these all may too.
 * VFS 层对路径名的高级操作。
 * 这些函数主要供系统调用层使用。它们接收字符串路径，内部调用 vfs_lookup 解析出 inode，
 * 然后调用 vop_* 函数执行具体操作。
 *
 * vfs_open         - Open or create a file. FLAGS/MODE per the syscall. 
 * vfs_close   - Close a inode opened with vfs_open. Does not fail.
 * (See vfspath.c for a discussion of why.)
 * vfs_link         - Create a hard link to a file.
 * vfs_symlink      - Create a symlink PATH containing contents CONTENTS.
 * vfs_readlink     - Read contents of a symlink into a uio.
 * vfs_mkdir        - Create a directory. MODE per the syscall.
 * vfs_unlink       - Delete a file/directory.
 * vfs_rename       - rename a file.
 * vfs_chdir   - Change current directory of current thread by name.
 * vfs_getcwd  - Retrieve name of current directory of current thread.
 *
 */
int vfs_open(char *path, uint32_t open_flags, struct inode **inode_store);
int vfs_close(struct inode *node);
int vfs_link(char *old_path, char *new_path);
int vfs_symlink(char *old_path, char *new_path);
int vfs_readlink(char *path, struct iobuf *iob);
int vfs_mkdir(char *path);
int vfs_unlink(char *path);
int vfs_rename(char *old_path, char *new_path);
int vfs_chdir(char *path);
int vfs_getcwd(struct iobuf *iob);


/*
 * VFS layer mid-level operations.
 * VFS 层中级操作：路径解析
 *
 * vfs_lookup     - Like VOP_LOOKUP, but takes a full device:path name,
 * or a name relative to the current directory, and
 * goes to the correct filesystem.
 * 核心函数：根据路径名找到对应的 inode。支持 "disk0:/path" 和相对路径。
 * vfs_lookparent - Likewise, for VOP_LOOKPARENT.
 * 找到目标路径的父目录 inode 以及目标文件名的最后一部分。
 * (用于创建、重命名、删除文件时)
 *
 * Both of these may destroy the path passed in.
 */
int vfs_lookup(char *path, struct inode **node_store);
int vfs_lookup_parent(char *path, struct inode **node_store, char **endp);

/*
 * Misc
 * 杂项管理函数
 *
 * vfs_set_bootfs - Set the filesystem that paths beginning with a
 * slash are sent to. If not set, these paths fail
 * with ENOENT. The argument should be the device
 * name or volume name for the filesystem (such as
 * "lhd0:") but need not have the trailing colon.
 * 设置根文件系统 (/)。
 *
 * vfs_get_bootfs - return the inode of the bootfs filesystem. 
 * 获取根文件系统的根 inode。
 *
 * vfs_add_fs     - Add a hardwired filesystem to the VFS named device
 * list. It will be accessible as "devname:". This is
 * intended for filesystem-devices like emufs, and
 * gizmos like Linux procfs or BSD kernfs, not for
 * mounting filesystems on disk devices.
 * 注册一个“虚拟”文件系统设备。
 *
 * vfs_add_dev    - Add a device to the VFS named device list. If
 * MOUNTABLE is zero, the device will be accessible
 * as "DEVNAME:". If the mountable flag is set, the
 * device will be accessible as "DEVNAMEraw:" and
 * mountable under the name "DEVNAME". Thus, the
 * console, added with MOUNTABLE not set, would be
 * accessed by pathname as "con:", and lhd0, added
 * with mountable set, would be accessed by
 * pathname as "lhd0raw:" and mounted by passing
 * "lhd0" to vfs_mount.
 * 注册一个设备。mountable 决定了它是否可以被 mount 一个文件系统。
 *
 * vfs_mount      - Attempt to mount a filesystem on a device. The
 * device named by DEVNAME will be looked up and 
 * passed, along with DATA, to the supplied function
 * MOUNTFUNC, which should create a struct fs and
 * return it in RESULT.
 * 挂载文件系统。
 *
 * vfs_unmount    - Unmount the filesystem presently mounted on the
 * specified device.
 * 卸载文件系统。
 *
 * vfs_unmountall - Unmount all mounted filesystems.
 */
int vfs_set_bootfs(char *fsname);
int vfs_get_bootfs(struct inode **node_store);

int vfs_add_fs(const char *devname, struct fs *fs);
int vfs_add_dev(const char *devname, struct inode *devnode, bool mountable);

int vfs_mount(const char *devname, int (*mountfunc)(struct device *dev, struct fs **fs_store));
int vfs_unmount(const char *devname);
int vfs_unmount_all(void);

#endif /* !__KERN_FS_VFS_VFS_H__ */