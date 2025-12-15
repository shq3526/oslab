#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

/* *
 * wakeup_proc - 唤醒一个进程
 * 功能：将进程的状态从 PROC_SLEEPING (睡眠) 更改为 PROC_RUNNABLE (就绪)。
 * * 作用场景：
 * 1. 当父进程等待子进程退出时 (do_wait)，子进程退出后会唤醒父进程。
 * 2. 当进程等待某个事件/资源时，条件满足后被唤醒。
 */
void wakeup_proc(struct proc_struct *proc)
{
    // 只有非僵尸进程才能被唤醒。僵尸进程已经结束执行，等待回收，不能再运行。
    assert(proc->state != PROC_ZOMBIE);
    
    bool intr_flag;
    // 【关中断】
    // 进程状态的修改涉及共享数据（进程控制块），必须保证原子性。
    // 这里关闭中断，防止在修改过程中发生中断导致并发竞态问题。
    local_intr_save(intr_flag);
    {
        // 只有当进程状态不是 RUNNABLE 时才需要唤醒
        if (proc->state != PROC_RUNNABLE)
        {
            proc->state = PROC_RUNNABLE; // 设置为就绪态，可以被调度器选中
            proc->wait_state = 0;        // 清除等待标记
        }
        else
        {
            warn("wakeup runnable process.\n");
        }
    }
    // 【开中断】恢复中断状态
    local_intr_restore(intr_flag);
}

/* *
 * schedule - 进程调度函数
 * 功能：从进程链表中挑选一个合适的进程（PROC_RUNNABLE），并将 CPU 切换给它。
 * * 算法描述 (FIFO / Round-Robin)：
 * 1. 遍历进程链表 (proc_list)。
 * 2. 找到第一个状态为 PROC_RUNNABLE 的进程。
 * 3. 恢复该进程的时间片 (如果是因时间片耗尽而被抢占的)。
 * 4. 调用 proc_run 执行上下文切换。
 */
void schedule(void)
{
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    
    // 【关中断】
    // 调度过程涉及修改 current 指针、进程链表等核心数据结构，
    // 且 proc_run 进行上下文切换时必须处于关中断状态。
    local_intr_save(intr_flag);
    {
        // 清除当前进程的“需要调度”标记
        current->need_resched = 0;
        
        // 确定遍历的起点：
        // 如果当前是 idleproc (0号进程)，从链表头开始找；
        // 否则，从当前进程的下一个位置开始找 (实现 Round-Robin 轮转，保证公平)。
        last = (current == idleproc) ? &proc_list : &(current->list_link);
        le = last;
        
        // 遍历进程链表 proc_list
        do
        {
            // 获取下一个节点，并跳过链表头节点 (proc_list 本身不是进程)
            if ((le = list_next(le)) != &proc_list)
            {
                // 通过链表节点反解出对应的进程结构体指针
                next = le2proc(le, list_link);
                
                // 找到一个处于“就绪”状态的进程
                if (next->state == PROC_RUNNABLE)
                {
                    // 【关键修复点：重置时间片】
                    // 这是实现 Round-Robin (RR) 调度的关键。
                    // 场景：如果进程是因为时间片用完 (time_slice=0) 而被迫让出 CPU 的，
                    // 当它再次被调度器选中时，必须给它分配新的时间片（这里硬编码为 3 ticks）。
                    // 后果：如果不重置，它运行瞬间又会触发时间片耗尽，导致死循环式的频繁调度，系统瘫痪。
                    if (next->time_slice == 0) {
                         next->time_slice = 3;
                    }
                    
                    // 找到目标，跳出循环
                    break;
                }
            }
        } while (le != last); // 如果遍历了一圈回到原点，说明没有其他就绪进程
        
        // 如果没有找到可运行的进程 (next == NULL 或 next 不可运行)
        // 则运行 idleproc (空闲进程)，让 CPU 进入空闲循环
        if (next == NULL || next->state != PROC_RUNNABLE)
        {
            next = idleproc;
        }
        
        // 统计该进程的运行次数
        next->runs++;
        
        // 如果选出的进程不是当前正在运行的进程，则进行上下文切换
        if (next != current)
        {
            // proc_run 会完成以下工作：
            // 1. 切换页表 (lcr3)
            // 2. 切换内核栈 (switch_to)
            // 3. 更新 current 指针
            proc_run(next);
        }
    }
    // 【开中断】
    // 注意：当 proc_run 返回时，实际上已经是在“新进程”的上下文中了。
    // 这里的 local_intr_restore 恢复的是新进程之前保存的中断状态。
    local_intr_restore(intr_flag);
}