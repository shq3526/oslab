#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
#define local_intr_restore(x) __intr_restore(x);

#endif /* !__KERN_SYNC_SYNC_H__ */
// 当调用 local_intr_save(x); 时，发生了以下步骤：

// * 检查当前状态：系统首先通过 read_csr(sstatus) 读取当前的硬件状态。

// * 保存状态到变量：
  
//   * 如果当前中断是开启的：__intr_save 会调用 intr_disable() 关闭中断，并返回 1。变量 x 被赋值为 1。
//   * 如果当前中断是关闭的（例如已经在另一个临界区内）：__intr_save 不做任何硬件操作，直接返回 0。变量 x 被赋值为 0。

// * 执行临界区代码：此时，无论之前状态如何，现在的中断肯定是被禁用的，保证了操作的原子性。

// 当调用 local_intr_restore(x); 时：

// * 检查保存的变量：查看 x 的值。

// * 条件恢复：

//   * 如果 x 是 1：说明进入临界区前中断是开着的，因此现在调用 intr_enable() 恢复中断。

//   * 如果 x 是 0：说明进入临界区前中断本来就是关着的（嵌套调用），因此不执行开中断操作，继续保持关闭状态。