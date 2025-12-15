#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <defs.h>
#include <intr.h>
#include <sched.h>
#include <riscv.h>
#include <assert.h>

/* [原子性保护机制 1：开关中断]
 * 在单核操作系统中，并发问题主要由中断（Interrupt）引起（例如时钟中断触发调度）。
 * 为了保证一段代码（临界区）不被打断，我们需要在进入前关闭中断，退出后恢复中断。
 */

/* *
 * __intr_save - 保存当前中断状态并禁用中断
 * @return: 返回“禁用中断前”的中断状态 (bool)。
 * 1 (true)  -> 之前是开启中断的 (SSTATUS_SIE = 1)
 * 0 (false) -> 之前已经是关闭中断的
 * * 逻辑：
 * 1. 读取 sstatus 寄存器，检查 SIE (Supervisor Interrupt Enable) 位。
 * 2. 如果之前是开启的，调用 intr_disable() 关闭中断，并返回 1。
 * 3. 如果之前已经是关闭的，保持关闭状态，并返回 0。
 * * 为什么要返回状态？
 * 为了支持嵌套调用。如果函数 A 关了中断调用函数 B，函数 B 也尝试关中断。
 * B 结束后如果不看之前的状态直接开中断，A 的后续代码就会暴露在中断风险下。
 * 因此必须“恢复”到之前的状态，而不是盲目“开启”。
 */
static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
    {
        intr_disable();
        return 1;
    }
    return 0;
}

/* *
 * __intr_restore - 恢复中断状态
 * @flag: 由 __intr_save 返回的之前的状态
 * * 逻辑：
 * 只有当之前是开启状态 (flag=1) 时，才重新开启中断。
 */
static inline void __intr_restore(bool flag)
{
    if (flag)
    {
        intr_enable();
    }
}

/* [宏定义封装]
 * 使用示例：
 * bool intr_flag;
 * local_intr_save(intr_flag);
 * {
 * // 临界区代码 (Critical Section)
 * // 例如：修改 proc_list, hash_list 等共享链表
 * // 此时保证不会发生时钟中断，因此不会发生进程调度
 * }
 * local_intr_restore(intr_flag);
 */
#define local_intr_save(x) \
    do                     \
    {                      \
        x = __intr_save(); \
    } while (0)
#define local_intr_restore(x) __intr_restore(x);

/* [原子性保护机制 2：锁]
 * 简单的互斥锁实现。
 * volatile 关键字告诉编译器该变量可能在外部被修改，禁止优化读写操作。
 */
typedef volatile bool lock_t;

/* 初始化锁，设置为 0 (未锁定) */
static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
}

/* *
 * try_lock - 尝试获取锁
 * @return: true 表示获取成功，false 表示失败
 * * 核心机制：test_and_set_bit (位原子操作)
 * 这是一个原子指令 (Atomic Instruction)，在 RISC-V 中通常对应 amo (Atomic Memory Operation) 指令。
 * 它原子地完成：读取旧值 -> 设置新值(1) -> 返回旧值。
 * * 逻辑：
 * 尝试将 lock 的第 0 位设置为 1。
 * 如果之前是 0 (无锁)，设置成功，test_and_set_bit 返回 0，函数返回 true。
 * 如果之前是 1 (有锁)，设置后仍是 1，test_and_set_bit 返回 1，函数返回 false。
 */
static inline bool
try_lock(lock_t *lock)
{
    return !test_and_set_bit(0, lock);
}

/* *
 * lock - 获取锁（阻塞/等待式）
 * * 逻辑：
 * 这是一个 "Yielding Spinlock" (让权自旋锁)。
 * 1. 循环调用 try_lock 尝试加锁。
 * 2. 如果失败（锁被占用），调用 schedule() 主动让出 CPU。
 * * 为什么调用 schedule()？
 * 在单核系统中，如果持有锁的进程被抢占了，而等待锁的进程一直在死循环（忙等待），
 * 那么持有锁的进程永远没机会运行来释放锁，导致死锁或性能急剧下降。
 * 因此，获取失败时主动放弃 CPU，让持有锁的进程有机会运行并释放锁。
 */
static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
    {
        schedule();
    }
}

/* *
 * unlock - 释放锁
 * * 逻辑：
 * 使用原子操作 test_and_clear_bit 将锁置为 0。
 * 如果操作前锁的值已经是 0，说明逻辑错误（释放了一个没有被锁住的锁），触发 panic。
 */
static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
    {
        panic("Unlock failed.\n");
    }
}

#endif /* !__KERN_SYNC_SYNC_H__ */