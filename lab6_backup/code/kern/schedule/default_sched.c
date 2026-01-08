/**
 * default_sched.c - RR (Round Robin) 时间片轮转调度算法实现
 * 
 * RR调度算法是一种公平的抢占式调度算法：
 * - 所有就绪进程按照FIFO顺序排列在运行队列中
 * - 每个进程分配相同的时间片（MAX_TIME_SLICE）
 * - 当进程时间片用完时，被移到队列尾部，选择队首进程执行
 * - 保证了所有进程都能获得CPU时间，防止饥饿
 * 
 * 算法复杂度：
 * - 入队/出队: O(1)
 * - 选择下一进程: O(1)
 */

#include <defs.h>          // 基本类型定义
#include <list.h>          // 双向链表数据结构
#include <proc.h>          // 进程控制块定义
#include <assert.h>        // 断言宏
#include <default_sched.h> // 调度类声明

/*
 * RR_init initializes the run-queue rq with correct assignment for
 * member variables, including:
 *
 *   - run_list: should be an empty list after initialization.
 *   - proc_num: set to 0
 *   - max_time_slice: no need here, the variable would be assigned by the caller.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
/**
 * RR_init - 初始化RR调度器的运行队列
 * @rq: 指向运行队列的指针
 * 
 * 初始化运行队列的成员变量：
 * - run_list: 初始化为空的双向循环链表
 * - proc_num: 设置为0，表示队列中没有进程
 * - max_time_slice: 不在此处设置，由调用者(sched_init)设置
 */
static void
RR_init(struct run_queue *rq)
{
    // LAB6: 填写你在lab6中实现的代码
    // 2312580
    // 初始化运行队列链表，使其成为空的双向循环链表
    list_init(&(rq->run_list));
    // 初始化进程计数为0
    rq->proc_num = 0;
}

/*
 * RR_enqueue inserts the process ``proc'' into the tail of run-queue
 * ``rq''. The procedure should verify/initialize the relevant members
 * of ``proc'', and then put the ``run_link'' node into the queue.
 * The procedure should also update the meta data in ``rq'' structure.
 *
 * proc->time_slice denotes the time slices allocation for the
 * process, which should set to rq->max_time_slice.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
/**
 * RR_enqueue - 将进程加入运行队列尾部
 * @rq: 指向运行队列的指针
 * @proc: 要加入队列的进程控制块
 * 
 * 将进程插入到运行队列的尾部（FIFO顺序）：
 * 1. 验证进程的run_link为空（确保进程不在其他队列中）
 * 2. 将进程的run_link节点加入队列尾部
 * 3. 初始化/重置进程的时间片
 * 4. 设置进程的rq指针，指向当前运行队列
 * 5. 增加运行队列的进程计数
 * 
 * 注意：使用list_add_before(&run_list, ...)实现加入队尾
 * 因为run_list是哨兵节点，其prev指向队尾
 */
static void
RR_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
    // LAB6: 填写你在lab6中实现的代码
    // 2312580
    // 断言进程的run_link为空，确保进程不在任何队列中
    assert(list_empty(&(proc->run_link)));
    // 将进程加入队列尾部（run_list之前即为队尾）
    list_add_before(&(rq->run_list), &(proc->run_link));
    // 如果时间片为0或超过最大值，重置为最大时间片
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
        proc->time_slice = rq->max_time_slice;
    }
    // 设置进程所属的运行队列
    proc->rq = rq;
    // 增加队列中的进程计数
    rq->proc_num ++;
}

/*
 * RR_dequeue removes the process ``proc'' from the front of run-queue
 * ``rq'', the operation would be finished by the list_del_init operation.
 * Remember to update the ``rq'' structure.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
/**
 * RR_dequeue - 将进程从运行队列中移除
 * @rq: 指向运行队列的指针
 * @proc: 要移除的进程控制块
 * 
 * 将指定进程从运行队列中移除：
 * 1. 验证进程确实在队列中（run_link非空且rq匹配）
 * 2. 使用list_del_init移除节点并重新初始化run_link
 * 3. 减少运行队列的进程计数
 */
static void
RR_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
    // LAB6: 填写你在lab6中实现的代码
    // 2312580
    // 断言进程在队列中且属于当前运行队列
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
    // 从队列中移除进程，并重新初始化其run_link
    list_del_init(&(proc->run_link));
    // 减少队列中的进程计数
    rq->proc_num --;
}

/*
 * RR_pick_next picks the element from the front of ``run-queue'',
 * and returns the corresponding process pointer. The process pointer
 * would be calculated by macro le2proc, see kern/process/proc.h
 * for definition. Return NULL if there is no process in the queue.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
/**
 * RR_pick_next - 选择下一个要运行的进程
 * @rq: 指向运行队列的指针
 * @return: 返回队首进程的指针，队列为空时返回NULL
 * 
 * 从运行队列头部选择下一个要执行的进程：
 * 1. 获取队列中的第一个元素（run_list->next）
 * 2. 如果队列非空，使用le2proc宏将链表节点转换为进程指针
 * 3. 如果队列为空，返回NULL
 * 
 * le2proc宏通过container_of技术，从run_link成员地址
 * 计算出包含它的proc_struct结构体地址
 */
static struct proc_struct *
RR_pick_next(struct run_queue *rq)
{
    // LAB6: 填写你在lab6中实现的代码
    // 2312580
    // 获取队列中的第一个元素
    list_entry_t *le = list_next(&(rq->run_list));
    // 如果队列非空，返回对应的进程指针
    if (le != &(rq->run_list)) {
        return le2proc(le, run_link);
    }
    // 队列为空，返回NULL
    return NULL;
}

/*
 * RR_proc_tick works with the tick event of current process. You
 * should check whether the time slices for current process is
 * exhausted and update the proc struct ``proc''. proc->time_slice
 * denotes the time slices left for current process. proc->need_resched
 * is the flag variable for process switching.
 */
/**
 * RR_proc_tick - 处理时钟中断事件
 * @rq: 指向运行队列的指针
 * @proc: 当前正在运行的进程
 * 
 * 每次时钟中断时被调用，用于实现时间片轮转：
 * 1. 如果进程还有剩余时间片，将其减1
 * 2. 如果时间片减到0，设置need_resched=1触发调度
 * 
 * 这是RR调度算法实现抢占式调度的关键：
 * 通过时钟中断定期检查时间片，确保每个进程
 * 只能连续运行有限的时间，实现公平调度
 */
static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    // LAB6: 填写你在lab6中实现的代码
    // 2312580
    // 如果还有剩余时间片，减少1
    if (proc->time_slice > 0) {
        proc->time_slice --;
    }
    // 如果时间片用完，设置重调度标志
    if (proc->time_slice == 0) {
        proc->need_resched = 1;
    }
}

/**
 * default_sched_class - RR调度类实例
 * 
 * 定义RR调度算法的调度类结构体，将各个操作函数
 * 封装成统一的接口供调度器调用
 */
struct sched_class default_sched_class = {
    .name = "RR_scheduler",       // 调度器名称
    .init = RR_init,              // 初始化函数
    .enqueue = RR_enqueue,        // 入队函数
    .dequeue = RR_dequeue,        // 出队函数
    .pick_next = RR_pick_next,    // 选择下一进程函数
    .proc_tick = RR_proc_tick,    // 时钟处理函数
};
