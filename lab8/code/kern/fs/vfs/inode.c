#include <defs.h>
#include <stdio.h>
#include <string.h>
#include <atomic.h>
#include <vfs.h>
#include <inode.h>
#include <error.h>
#include <assert.h>
#include <kmalloc.h>

/* *
 * __alloc_inode - alloc a inode structure and initialize in_type
 * 分配一个 inode 结构体的内存。
 * 通常由 alloc_inode 宏调用，用于创建具体类型的 inode（如 device 或 sfs_inode）。
 * @type: inode 的类型标识 (例如 inode_type_device_info 或 inode_type_sfs_inode_info)
 * */
struct inode *
__alloc_inode(int type) {
    struct inode *node;
    if ((node = kmalloc(sizeof(struct inode))) != NULL) {
        node->in_type = type;
    }
    return node;
}

/* *
 * inode_init - initialize a inode structure
 * invoked by vop_init
 * 初始化 inode 结构体。
 * @ops: 该 inode 对应的操作函数表 (inode_ops)，决定了 open/read/write 等的具体行为
 * @fs:  该 inode 所属的文件系统抽象对象 (fs)
 * 注意：初始化后，引用计数会被增加 1，因为调用者现在持有了该 inode 的指针。
 * */
void
inode_init(struct inode *node, const struct inode_ops *ops, struct fs *fs) {
    node->ref_count = 0;
    node->open_count = 0;
    node->in_ops = ops, node->in_fs = fs;
    vop_ref_inc(node); // 增加引用计数，表示该 inode 处于活跃状态
}

/* *
 * inode_kill - kill a inode structure
 * invoked by vop_kill
 * 销毁 inode 结构体，释放内存。
 * 必须确保引用计数和打开计数都为 0，否则说明还有人在使用，不能强制销毁。
 * 通常在 vop_reclaim 的最后阶段被调用。
 * */
void
inode_kill(struct inode *node) {
    assert(inode_ref_count(node) == 0);
    assert(inode_open_count(node) == 0);
    kfree(node);
}

/* *
 * inode_ref_inc - increment ref_count
 * invoked by vop_ref_inc
 * 增加 inode 的引用计数 (Reference Count)。
 * 引用计数表示有多少个内核对象（如 dentry, file 结构, 或者代码中的指针）持有该 inode。
 * */
int
inode_ref_inc(struct inode *node) {
    node->ref_count += 1;
    return node->ref_count;
}

/* *
 * inode_ref_dec - decrement ref_count
 * invoked by vop_ref_dec
 * calls vop_reclaim if the ref_count hits zero
 * 减少 inode 的引用计数。
 * 这是一个关键的资源回收触发点：
 * 当引用计数降为 0 时，意味着没有任何进程或缓存持有该 inode，
 * 此时调用 vop_reclaim 通知具体的文件系统（如 SFS）回收该 inode 关联的资源
 * (例如释放 sfs_inode 内存，断开与磁盘 inode 的关联等)。
 * */
int
inode_ref_dec(struct inode *node) {
    assert(inode_ref_count(node) > 0);
    int ref_count, ret;
    node->ref_count-= 1;
    ref_count = node->ref_count;
    if (ref_count == 0) {
        // 引用归零，回收 inode 资源
        if ((ret = vop_reclaim(node)) != 0 && ret != -E_BUSY) {
            cprintf("vfs: warning: vop_reclaim: %e.\n", ret);
        }
    }
    return ref_count;
}

/* *
 * inode_open_inc - increment the open_count
 * invoked by vop_open_inc
 * 增加 inode 的打开计数 (Open Count)。
 * 打开计数表示当前有多少个文件描述符 (fd) 正打开着这个文件。
 * 注意：open_count 总是 <= ref_count，因为打开文件隐含持有一个引用。
 * */
int
inode_open_inc(struct inode *node) {
    node->open_count += 1;
    return node->open_count;
}

/* *
 * inode_open_dec - decrement the open_count
 * invoked by vop_open_dec
 * calls vop_close if the open_count hits zero
 * 减少 inode 的打开计数。
 * 当打开计数降为 0 时，表示所有打开该文件的进程都关闭了它。
 * 此时调用 vop_close 通知底层文件系统执行关闭操作 (例如 SFS 会在此时将 dirty inode 刷回磁盘)。
 * */
int
inode_open_dec(struct inode *node) {
    assert(inode_open_count(node) > 0);
    int open_count, ret;
    node->open_count -= 1;
    open_count = node->open_count;
    if (open_count == 0) {
        // 打开计数归零，执行底层关闭逻辑
        if ((ret = vop_close(node)) != 0) {
            cprintf("vfs: warning: vop_close: %e.\n", ret);
        }
    }
    return open_count;
}

/* *
 * inode_check - check the various things being valid
 * called before all vop_* calls
 * 调试辅助函数：检查 inode 状态的一致性。
 * 1. 检查指针有效性。
 * 2. 检查魔数 (Magic Number)。
 * 3. 核心约束：ref_count 必须 >= open_count (打开文件必然持有引用)。
 * */
void
inode_check(struct inode *node, const char *opstr) {
    assert(node != NULL && node->in_ops != NULL);
    assert(node->in_ops->vop_magic == VOP_MAGIC);
    int ref_count = inode_ref_count(node), open_count = inode_open_count(node);
    assert(ref_count >= open_count && open_count >= 0);
    assert(ref_count < MAX_INODE_COUNT && open_count < MAX_INODE_COUNT);
}