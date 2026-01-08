/**
 * default_sched_fifo.c - FIFO (First In First Out) 先进先出调度算法实现
 * 
 * FIFO调度算法是一种简单的非抢占式调度算法：
 * - 所有就绪进程按照到达顺序排列在运行队列中
 * - 先到达的进程先执行，直到其主动放弃CPU
 * - 进程只有在调用yield、exit或sleep等系统调用时才会让出CPU
 * - 不响应时钟中断进行强制切换
 * 
 * 算法特点：
 * - 实现简单，开销小
 * - 不公平：短作业可能等待很长时间
 * - 可能导致"护航效应"：长作业阻塞后续所有短作业
 * 
 * 算法复杂度：
 * - 入队/出队: O(1)
 * - 选择下一进程: O(1)
 */

#include <defs.h>    // 基本类型定义
#include <list.h>    // 双向链表数据结构
#include <proc.h>    // 进程控制块定义
#include <sched.h>   // 调度器头文件
#include <assert.h>  // 断言宏

/**
 * fifo_init - 初始化FIFO调度器的运行队列
 * @rq: 指向运行队列的指针
 * 
 * 初始化运行队列的成员变量：
 * - run_list: 初始化为空的双向循环链表
 * - proc_num: 设置为0，表示队列中没有进程
 */
static void
fifo_init(struct run_queue *rq) {
    // 初始化运行队列链表
    list_init(&(rq->run_list));
    // 初始化进程计数为0
    rq->proc_num = 0;
}

/**
 * fifo_enqueue - 将进程加入运行队列尾部
 * @rq: 指向运行队列的指针
 * @proc: 要加入队列的进程控制块
 * 
 * 将进程插入到运行队列的尾部（FIFO顺序）：
 * - 使用list_add_before将进程加入队尾
 * - 设置进程的rq指针
 * - 增加运行队列的进程计数
 * 
 * 注意：FIFO不使用时间片，所以不设置time_slice
 */
static void
fifo_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    // FIFO 也是加到队尾
    // 将进程加入队列尾部
    list_add_before(&(rq->run_list), &(proc->run_link));
    // 设置进程所属的运行队列
    proc->rq = rq;
    // 增加队列中的进程计数
    rq->proc_num++;
}

/**
 * fifo_dequeue - 将进程从运行队列中移除
 * @rq: 指向运行队列的指针
 * @proc: 要移除的进程控制块
 * 
 * 从运行队列中移除指定进程：
 * - 使用list_del_init移除节点并重新初始化
 * - 减少运行队列的进程计数
 */
static void
fifo_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    // 从队列中移除进程
    list_del_init(&(proc->run_link));
    // 减少队列中的进程计数
    rq->proc_num--;
}

/**
 * fifo_pick_next - 选择下一个要运行的进程
 * @rq: 指向运行队列的指针
 * @return: 返回队首进程的指针，队列为空时返回NULL
 * 
 * 从运行队列头部选择下一个要执行的进程：
 * - 如果队列为空，返回NULL
 * - 否则返回队列中的第一个进程（先到达的进程）
 */
static struct proc_struct *
fifo_pick_next(struct run_queue *rq) {
    // 如果队列为空，返回NULL
    if (rq->proc_num == 0) return NULL;
    // 永远取队头
    // 获取队列中的第一个元素
    list_entry_t *le = list_next(&(rq->run_list));
    // 返回对应的进程指针
    return le2proc(le, run_link);
}

/**
 * fifo_proc_tick - 处理时钟中断事件
 * @rq: 指向运行队列的指针
 * @proc: 当前正在运行的进程
 * 
 * FIFO调度算法的核心特性：非抢占式
 * - 在时钟中断时不减少时间片
 * - 不设置need_resched标志
 * - 进程会一直运行，直到主动放弃CPU
 * 
 * 这意味着：
 * - 长作业可能长时间占用CPU
 * - 短作业需要等待前面的作业完成
 * - 只有进程调用sys_yield、sys_exit或进入睡眠时才会切换
 */
static void
fifo_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    // FIFO 的核心：
    // 在时钟中断时，不要减少时间片，或者不要设置 need_resched。
    // 除非我们想实现"抢占式 FIFO"（即 RR），否则这里留空即可。
    // 但为了避免死循环，通常保留响应中断的能力，只是不强制切换。
    
    // 纯粹的 FIFO：这里什么都不做。
    // 进程会一直跑，直到它调用 sys_yield 或 sys_exit 或 sleep。
}

/**
 * fifo_sched_class - FIFO调度类实例
 * 
 * 定义FIFO调度算法的调度类结构体
 * 将各个操作函数封装成统一的接口供调度器调用
 */
struct sched_class fifo_sched_class = {
    .name = "FIFO_scheduler",     // 调度器名称
    .init = fifo_init,            // 初始化函数
    .enqueue = fifo_enqueue,      // 入队函数
    .dequeue = fifo_dequeue,      // 出队函数
    .pick_next = fifo_pick_next,  // 选择下一进程函数
    .proc_tick = fifo_proc_tick,  // 时钟处理函数（空实现）
};