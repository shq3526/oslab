/**
 * sched.c - 进程调度器实现
 * 
 * 本文件实现了uCore操作系统的进程调度器核心功能
 * 包括调度器初始化、进程唤醒和调度切换等核心操作
 * 调度器采用可插拔的调度类设计，支持多种调度算法
 */

#include <list.h>          // 双向链表数据结构
#include <sync.h>          // 同步原语，用于关闭/恢复中断
#include <proc.h>          // 进程控制块定义
#include <sched.h>         // 调度器头文件
#include <stdio.h>         // 标准输入输出
#include <assert.h>        // 断言宏
#include <default_sched.h> // 默认调度类声明

/*===========================================================================*
 *                              全局变量定义                                   *
 *===========================================================================*/

/**
 * timer_list - 定时器链表
 * 用于管理系统中的所有定时器
 * 目前在调度器中未使用，保留供将来扩展
 */
// the list of timer
static list_entry_t timer_list;

/**
 * sched_class - 当前使用的调度类
 * 指向具体调度算法的实现（如stride_sched_class）
 * 通过此指针调用调度算法的各个操作函数
 */
static struct sched_class *sched_class;

/**
 * rq - 全局运行队列指针
 * 指向__rq，管理所有处于就绪状态的进程
 */
static struct run_queue *rq;

/*===========================================================================*
 *                           调度类包装函数                                    *
 *===========================================================================*/

/**
 * sched_class_enqueue - 将进程加入运行队列的包装函数
 * @proc: 要加入队列的进程控制块指针
 * 
 * 调用当前调度类的enqueue方法将进程加入运行队列
 * 注意：idle进程不会被加入运行队列，因为idle进程
 * 只在没有其他可运行进程时才会被执行
 */
static inline void
sched_class_enqueue(struct proc_struct *proc)
{
    if (proc != idleproc)  // idle进程不加入运行队列
    {
        sched_class->enqueue(rq, proc);
    }
}

/**
 * sched_class_dequeue - 将进程从运行队列中移除的包装函数
 * @proc: 要移除的进程控制块指针
 * 
 * 调用当前调度类的dequeue方法将进程从运行队列中移除
 * 当进程被选中执行时，需要先将其从运行队列中移除
 */
static inline void
sched_class_dequeue(struct proc_struct *proc)
{
    sched_class->dequeue(rq, proc);
}

/**
 * sched_class_pick_next - 选择下一个要运行的进程
 * @return: 返回选中的进程，如果队列为空则返回NULL
 * 
 * 调用当前调度类的pick_next方法从运行队列中选择
 * 下一个要执行的进程
 */
static inline struct proc_struct *
sched_class_pick_next(void)
{
    return sched_class->pick_next(rq);
}

/**
 * sched_class_proc_tick - 处理时钟中断的调度操作
 * @proc: 当前正在运行的进程
 * 
 * 每次时钟中断时由trap处理程序调用
 * 用于更新进程的时间片计数，并在时间片用完时
 * 设置need_resched标志，触发进程调度
 * 
 * 对于idle进程，直接设置need_resched=1
 * 使其立即让出CPU（因为idle进程只应在无其他进程时运行）
 */
void sched_class_proc_tick(struct proc_struct *proc)
{
    if (proc != idleproc)
    {
        // 调用调度类的proc_tick处理时钟事件
        sched_class->proc_tick(rq, proc);
    }
    else
    {
        // idle进程总是可以被调度出去
        proc->need_resched = 1;
    }
}

/*===========================================================================*
 *                              全局运行队列                                   *
 *===========================================================================*/

/**
 * __rq - 全局运行队列实例
 * 静态分配的运行队列，用于管理所有就绪进程
 */
static struct run_queue __rq;

/*===========================================================================*
 *                           调度器核心函数实现                                 *
 *===========================================================================*/

/**
 * sched_init - 初始化调度器
 * 
 * 在系统启动时由kern_init调用，完成调度器的初始化工作：
 * 1. 初始化定时器链表（为将来扩展预留）
 * 2. 选择并设置调度类（当前使用stride调度算法）
 * 3. 初始化全局运行队列
 * 4. 打印当前使用的调度类名称
 */
void sched_init(void)
{
    // 初始化定时器链表
    list_init(&timer_list);

    // 设置当前使用的调度类为stride调度
    // 可以修改为其他调度类：default_sched_class(RR), fifo_sched_class, sjf_sched_class
    sched_class = &stride_sched_class;

    // 初始化全局运行队列
    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;  // 设置最大时间片
    sched_class->init(rq);                 // 调用调度类的初始化函数

    // 打印调度器信息
    cprintf("sched class: %s\n", sched_class->name);
}

/**
 * wakeup_proc - 唤醒进程
 * @proc: 要唤醒的进程控制块指针
 * 
 * 将处于睡眠或新建状态的进程唤醒，使其变为就绪态
 * 并将其加入运行队列等待调度
 * 
 * 操作步骤：
 * 1. 检查进程不是僵尸态（僵尸进程不能被唤醒）
 * 2. 关闭中断，确保原子操作
 * 3. 如果进程不是就绪态，将其设为就绪态并加入运行队列
 * 4. 恢复中断
 * 
 * 注意：如果进程已经是就绪态，会打印警告信息
 */
void wakeup_proc(struct proc_struct *proc)
{
    // 断言：不能唤醒僵尸进程
    assert(proc->state != PROC_ZOMBIE);
    
    bool intr_flag;
    // 关闭中断，保证操作的原子性
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
        {
            // 将进程状态设置为就绪态
            proc->state = PROC_RUNNABLE;
            // 清除等待状态
            proc->wait_state = 0;
            // 如果不是当前进程，则加入运行队列
            if (proc != current)
            {
                sched_class_enqueue(proc);
            }
        }
        else
        {
            // 进程已经是就绪态，打印警告
            warn("wakeup runnable process.\n");
        }
    }
    // 恢复中断
    local_intr_restore(intr_flag);
}

/**
 * schedule - 进程调度函数（调度器的核心）
 * 
 * 选择下一个要运行的进程并执行上下文切换
 * 这是调度器的核心函数，在以下情况被调用：
 * 1. 当前进程时间片用完（need_resched = 1）
 * 2. 当前进程主动放弃CPU（调用yield系统调用）
 * 3. 当前进程退出或进入睡眠状态
 * 
 * 调度流程：
 * 1. 关闭中断，确保调度操作的原子性
 * 2. 清除当前进程的need_resched标志
 * 3. 如果当前进程仍然是就绪态，将其重新加入运行队列
 * 4. 从运行队列中选择下一个要执行的进程
 * 5. 将选中的进程从运行队列中移除
 * 6. 如果没有可运行进程，则选择idle进程
 * 7. 更新进程运行计数，执行上下文切换
 * 8. 恢复中断
 */
void schedule(void)
{
    bool intr_flag;
    struct proc_struct *next;
    
    // 关闭中断，保证调度操作的原子性
    local_intr_save(intr_flag);
    {
        // 清除当前进程的重调度标志
        current->need_resched = 0;
        
        // 如果当前进程仍是就绪态，将其重新加入运行队列
        // （用于时间片轮转等抢占式调度）
        if (current->state == PROC_RUNNABLE)
        {
            sched_class_enqueue(current);
        }
        
        // 选择下一个要运行的进程
        if ((next = sched_class_pick_next()) != NULL)
        {
            // 将选中的进程从运行队列中移除
            sched_class_dequeue(next);
        }
        
        // 如果没有可运行的进程，则运行idle进程
        if (next == NULL)
        {
            next = idleproc;
        }
        
        // 增加进程的运行计数（统计信息）
        next->runs++;
        
        // 如果选中的进程不是当前进程，执行上下文切换
        if (next != current)
        {
            proc_run(next);  // 执行进程切换
        }
    }
    // 恢复中断
    local_intr_restore(intr_flag);
}
