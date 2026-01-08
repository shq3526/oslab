/**
 * default_sched_stride.c - Stride 步进调度算法实现
 * 
 * Stride调度算法是一种基于优先级的比例共享调度算法：
 * - 每个进程有一个stride值（步进值）和pass值（累计步进值）
 * - stride = BIG_STRIDE / priority，优先级越高，stride越小
 * - 每次选择pass值最小的进程执行
 * - 执行后更新: pass += stride
 * 
 * 算法特点：
 * - 高优先级进程获得更多CPU时间（与优先级成正比）
 * - 使用斜堆(skew heap)实现高效的优先级队列
 * - 时间复杂度: O(log n) 的入队、出队和选择操作
 * 
 * 关于BIG_STRIDE的选择：
 * - 需要足够大以保证精度
 * - 需要防止溢出（使用有符号减法比较）
 * - 取值0x7FFFFFFF（32位有符号整数最大值）
 */

#include <defs.h>          // 基本类型定义
#include <list.h>          // 双向链表数据结构
#include <proc.h>          // 进程控制块定义
#include <assert.h>        // 断言宏
#include <default_sched.h> // 调度类声明
#include <stdio.h>         // 标准输入输出

/**
 * USE_SKEW_HEAP - 是否使用斜堆
 * 设为1使用斜堆实现优先级队列，设为0使用链表
 * 斜堆效率更高，时间复杂度为O(log n)
 */
#define USE_SKEW_HEAP 1

/* You should define the BigStride constant here*/
/* LAB6: 2312580 */
/**
 * BIG_STRIDE - 大步进常量
 * 
 * 用于计算每个进程的stride值: stride = BIG_STRIDE / priority
 * 
 * 取值为0x7FFFFFFF（32位有符号整数最大值）的原因：
 * 1. 需要足够大以保证不同优先级进程stride的精度差异
 * 2. 在比较pass值时使用有符号减法，可以正确处理溢出情况
 * 3. 只要两个pass值的差不超过BIG_STRIDE，比较结果就是正确的
 * 
 * 数学证明：
 * 对于任意两个进程i和j，执行一轮后pass值变化不超过stride_max
 * 只要 |pass_i - pass_j| < BIG_STRIDE，有符号比较就能正确工作
 */
#define BIG_STRIDE    0x7FFFFFFF /* you should give a value, and is ??? */

/**
 * proc_stride_comp_f - 斜堆节点比较函数
 * @a: 第一个斜堆节点指针
 * @b: 第二个斜堆节点指针
 * @return: a > b 返回1，a == b 返回0，a < b 返回-1
 * 
 * 比较两个进程的pass值（存储在lab6_stride中）
 * 使用有符号数减法来正确处理溢出情况
 * 
 * 为什么使用有符号减法：
 * 当pass值接近或超过最大值时会发生溢出
 * 使用有符号减法，只要两个值的差在[-BIG_STRIDE, BIG_STRIDE]范围内
 * 比较结果就是正确的
 */
/* The compare function for two skew_heap_node_t's and the
 * corresponding procs*/
static int
proc_stride_comp_f(void *a, void *b)
{
    // 使用le2proc宏从斜堆节点获取进程控制块指针
    struct proc_struct *p = le2proc(a, lab6_run_pool);
    struct proc_struct *q = le2proc(b, lab6_run_pool);
    // 使用有符号减法比较，正确处理溢出
    int32_t c = p->lab6_stride - q->lab6_stride;
    if (c > 0)
        return 1;   // p的pass值更大
    else if (c == 0)
        return 0;   // 相等
    else
        return -1;  // p的pass值更小
}

/*
 * stride_init initializes the run-queue rq with correct assignment for
 * member variables, including:
 *
 *   - run_list: should be a empty list after initialization.
 *   - lab6_run_pool: NULL
 *   - proc_num: 0
 *   - max_time_slice: no need here, the variable would be assigned by the caller.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
/**
 * stride_init - 初始化Stride调度器的运行队列
 * @rq: 指向运行队列的指针
 * 
 * 初始化运行队列的各个成员：
 * - run_list: 初始化为空链表（兼容链表实现方式）
 * - lab6_run_pool: 设为NULL（斜堆根节点为空）
 * - proc_num: 设为0（队列中没有进程）
 * - max_time_slice: 由调用者设置
 */
static void
stride_init(struct run_queue *rq)
{
    /* LAB6: 2312580
     * (1) init the ready process list: rq->run_list
     * (2) init the run pool: rq->lab6_run_pool
     * (3) set number of process: rq->proc_num to 0
     */
    // 初始化运行队列链表（兼容链表方式）
    list_init(&(rq->run_list));
    // 初始化斜堆根节点为NULL（空堆）
    rq->lab6_run_pool = NULL;
    // 初始化进程计数为0
    rq->proc_num = 0;
}

/*
 * stride_enqueue inserts the process ``proc'' into the run-queue
 * ``rq''. The procedure should verify/initialize the relevant members
 * of ``proc'', and then put the ``lab6_run_pool'' node into the
 * queue(since we use priority queue here). The procedure should also
 * update the meta date in ``rq'' structure.
 *
 * proc->time_slice denotes the time slices allocation for the
 * process, which should set to rq->max_time_slice.
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
/**
 * stride_enqueue - 将进程加入Stride调度器的运行队列
 * @rq: 指向运行队列的指针
 * @proc: 要加入队列的进程控制块
 * 
 * 将进程插入斜堆优先级队列：
 * 1. 调用skew_heap_insert将进程的lab6_run_pool节点插入斜堆
 * 2. 初始化/重置进程的时间片
 * 3. 设置进程的rq指针
 * 4. 增加运行队列的进程计数
 * 
 * 斜堆按lab6_stride（pass值）排序，堆顶是pass值最小的进程
 */
static void
stride_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
    /* LAB6: 2312580
     * (1) insert the proc into rq correctly
     * NOTICE: you can use skew_heap or list. Important functions
     *         skew_heap_insert: insert a entry into skew_heap
     *         list_add_before: insert  a entry into the last of list
     * (2) recalculate proc->time_slice
     * (3) set proc->rq pointer to rq
     * (4) increase rq->proc_num
     */
    // 将进程插入斜堆，返回新的堆根
    rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
    // 如果时间片为0或超过最大值，重置为最大时间片
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice)
    {
        proc->time_slice = rq->max_time_slice;
    }

    // 设置进程所属的运行队列
    proc->rq = rq;
    // 增加队列中的进程计数
    rq->proc_num++;
}

/*
 * stride_dequeue removes the process ``proc'' from the run-queue
 * ``rq'', the operation would be finished by the skew_heap_remove
 * operations. Remember to update the ``rq'' structure.
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
/**
 * stride_dequeue - 将进程从Stride调度器的运行队列中移除
 * @rq: 指向运行队列的指针
 * @proc: 要移除的进程控制块
 * 
 * 从斜堆中移除指定进程：
 * 1. 验证进程确实在当前队列中
 * 2. 调用skew_heap_remove从斜堆中移除进程节点
 * 3. 减少运行队列的进程计数
 */
static void
stride_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
    /* LAB6: 2312580
     * (1) remove the proc from rq correctly
     * NOTICE: you can use skew_heap or list. Important functions
     *         skew_heap_remove: remove a entry from skew_heap
     *         list_del_init: remove a entry from the  list
     */
    // 断言进程在当前队列中且队列非空
    assert(proc->rq == rq && rq->proc_num > 0);
    // 从斜堆中移除进程节点，返回新的堆根
    rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
    // 减少队列中的进程计数
    rq->proc_num--;
}
/*
 * stride_pick_next pick the element from the ``run-queue'', with the
 * minimum value of stride, and returns the corresponding process
 * pointer. The process pointer would be calculated by macro le2proc,
 * see kern/process/proc.h for definition. Return NULL if
 * there is no process in the queue.
 *
 * When one proc structure is selected, remember to update the stride
 * property of the proc. (stride += BIG_STRIDE / priority)
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
/**
 * stride_pick_next - 选择下一个要运行的进程
 * @rq: 指向运行队列的指针
 * @return: 返回pass值最小的进程，队列为空时返回NULL
 * 
 * Stride调度算法的核心：
 * 1. 从斜堆顶部获取pass值最小的进程（堆顶元素）
 * 2. 更新该进程的pass值: pass += stride = pass + BIG_STRIDE/priority
 * 3. 返回选中的进程
 * 
 * 注意：
 * - 斜堆自动维护堆顶为最小元素
 * - 更新pass值时需要处理优先级为0的特殊情况（设为1防止除0）
 * - lab6_stride变量存储的是pass值（累计步进值）
 */
static struct proc_struct *
stride_pick_next(struct run_queue *rq)
{
    /* LAB6: 2312580
     * (1) get a  proc_struct pointer p  with the minimum value of stride
            (1.1) If using skew_heap, we can use le2proc get the p from rq->lab6_run_pol
            (1.2) If using list, we have to search list to find the p with minimum stride value
     * (2) update p;s stride value: p->lab6_stride
     * (3) return p
     */
    // 如果斜堆为空，返回NULL
    if (rq->lab6_run_pool == NULL)
    {
        return NULL;
    }
    // 从堆顶获取pass值最小的进程
    struct proc_struct *proc = le2proc(rq->lab6_run_pool, lab6_run_pool);
    
    // LAB6: 增加对优先级为0的判断，防止除0错误
    // 获取进程优先级，如果为0则设为1
    uint32_t p = proc->lab6_priority;
    if (p == 0) p = 1; 

    // 更新 pass 值 (注意：uCore中通常用 lab6_stride 变量来存储 pass/accumulated stride)
    // pass值增加stride，stride = BIG_STRIDE / priority
    // 优先级越高，stride越小，pass增长越慢，被选中的机会越多
    proc->lab6_stride += BIG_STRIDE / p;
    
    return proc;
}

/*
 * stride_proc_tick works with the tick event of current process. You
 * should check whether the time slices for current process is
 * exhausted and update the proc struct ``proc''. proc->time_slice
 * denotes the time slices left for current
 * process. proc->need_resched is the flag variable for process
 * switching.
 */
/**
 * stride_proc_tick - 处理时钟中断事件
 * @rq: 指向运行队列的指针
 * @proc: 当前正在运行的进程
 * 
 * 每次时钟中断时被调用：
 * 1. 如果进程还有剩余时间片，将其减1
 * 2. 如果时间片减到0，设置need_resched=1触发调度
 * 
 * Stride调度也使用时间片来实现抢占式调度
 * 当时间片用完时，进程被重新加入运行队列
 * 下次调度时将选择pass值最小的进程
 */
static void
stride_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    // 如果还有剩余时间片，减少1
    if (proc->time_slice > 0)
    {
        proc->time_slice--;
    }
    // 如果时间片用完，设置重调度标志
    if (proc->time_slice == 0)
    {
        proc->need_resched = 1;
    }
}

/**
 * stride_sched_class - Stride调度类实例
 * 
 * 定义Stride调度算法的调度类结构体
 * 将各个操作函数封装成统一的接口供调度器调用
 */
struct sched_class stride_sched_class = {
    .name = "stride_scheduler",       // 调度器名称
    .init = stride_init,              // 初始化函数
    .enqueue = stride_enqueue,        // 入队函数
    .dequeue = stride_dequeue,        // 出队函数
    .pick_next = stride_pick_next,    // 选择下一进程函数
    .proc_tick = stride_proc_tick,    // 时钟处理函数
};