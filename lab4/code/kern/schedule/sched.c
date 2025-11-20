#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

/*
 * [进程唤醒函数]
 * 作用：将一个处于睡眠或未初始化状态的进程设置为可运行状态 (PROC_RUNNABLE)。
 * * 原理：
 * 当一个进程等待的事件发生时（例如等待的子进程退出了，或者等待的 I/O 完成了），
 * 内核会调用此函数。这会将进程标记为 "Ready"，调度器在下一次遍历时就能看到它并调度它执行。
 */
void
wakeup_proc(struct proc_struct *proc) {
    // 1. 完整性检查
    // 确保进程不是 PROC_ZOMBIE (僵尸状态，无法唤醒)
    // 确保进程不是 PROC_RUNNABLE (已经在运行队列中，无需重复唤醒)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    
    // 2. 修改状态
    // 将状态修改为 PROC_RUNNABLE，表示该进程现在可以被 CPU 执行了。
    // 注意：这里只是修改状态，并没有立即抢占 CPU。实际执行时机取决于调度器 schedule()。
    proc->state = PROC_RUNNABLE;
}

/*
 * [进程调度器主函数]
 * 作用：从进程链表中选择下一个要运行的进程，并进行上下文切换。
 * * 调度策略 (FIFO / Round Robin):
 * ucore 在 Lab 4 实现了一个简单的非抢占式 FIFO 调度器。
 * 它按照链表顺序，从当前进程的下一个位置开始搜索，找到第一个状态为 PROC_RUNNABLE 的进程。
 * 这保证了基本的公平性，所有可运行进程轮流使用 CPU。
 */
void
schedule(void) {
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    
    // 1. 禁用中断 (Critical Section Start)
    // 调度器是操作系统内核中最核心、最敏感的部分。
    // 在遍历和修改全局进程链表 (proc_list) 时，必须关闭中断。
    // 如果此时发生中断（如时钟中断）并触发嵌套调度，可能导致链表状态损坏或内核死锁。
    local_intr_save(intr_flag);
    {
        // 2. 清除当前进程的重新调度标记
        // 既然已经进入了 schedule()，说明当前进程已经响应了调度请求。
        current->need_resched = 0;
        
        // 3. 确定搜索起点
        // 如果当前进程是 idleproc (空闲进程)，则从链表头开始搜索。
        // 否则，从当前进程在链表中的位置开始，往后搜索。
        // 这种策略实现了轮转 (Round Robin)，避免总是选中链表头的进程，导致饥饿。
        last = (current == idleproc) ? &proc_list : &(current->list_link);
        le = last;
        
        // 4. 遍历进程链表 (寻找下一个 RUNNABLE 进程)
        do {
            // 获取下一个节点
            if ((le = list_next(le)) != &proc_list) {
                // 获取对应的进程控制块
                next = le2proc(le, list_link);
                
                // 找到目标：如果该进程状态是 PROC_RUNNABLE
                if (next->state == PROC_RUNNABLE) {
                    break; // 找到就停止搜索
                }
            }
            // 如果遍历了一圈回到了起点 (le == last)，说明没有其他可运行进程
        } while (le != last);
        
        // 5. 处理 "无进程可运" 的情况
        // 如果遍历完链表没找到 RUNNABLE 进程，或者找到的进程实际上不可运行 (双重检查)
        if (next == NULL || next->state != PROC_RUNNABLE) {
            // 调度 idleproc (空闲进程)
            // idleproc 通常执行死循环 (或 wfi 指令)，让 CPU 进入低功耗状态等待中断。
            next = idleproc;
        }
        
        // 6. 增加运行计数
        // 统计该进程被调度的次数 (用于调试或性能分析)
        next->runs ++;
        
        // 7. 执行进程切换
        // 只有当选中的 next 进程不是当前正在运行的 current 进程时，才需要切换。
        if (next != current) {
            // proc_run 是上下文切换的核心函数 (在 proc.c 中定义)。
            // 它会保存 current 的寄存器，加载 next 的寄存器，并更新页表。
            // 这里的函数调用不会立即返回，直到 current 进程再次被调度回来。
            proc_run(next);
        }
    }
    // 8. 恢复中断 (Critical Section End)
    // 恢复进入 schedule 前的中断状态。
    local_intr_restore(intr_flag);
}