/**
 * sched.h - 进程调度器头文件
 * 
 * 本文件定义了进程调度器的核心数据结构和接口函数
 * 包括调度类(sched_class)和运行队列(run_queue)的定义
 */
#ifndef __KERN_SCHEDULE_SCHED_H__
#define __KERN_SCHEDULE_SCHED_H__

#include <defs.h>      // 基本类型定义
#include <list.h>      // 双向链表数据结构
#include <skew_heap.h> // 斜堆数据结构，用于优先级队列实现

/**
 * MAX_TIME_SLICE - 最大时间片
 * 定义了进程在被调度出去之前可以运行的最大时钟节拍数
 * 在时间片轮转(RR)调度算法中使用
 */
#define MAX_TIME_SLICE 5

/* 前向声明 */
struct proc_struct;  // 进程控制块结构体，详细定义在 proc.h 中

struct run_queue;    // 运行队列结构体，在本文件下方定义

/**
 * struct sched_class - 调度类结构体
 * 
 * 调度类的引入借鉴自Linux内核设计，使得核心调度器具有很好的可扩展性
 * 这些调度类（调度模块）封装了具体的调度策略
 * 通过函数指针实现多态，可以方便地切换不同的调度算法
 * 
 * 支持的调度算法包括：
 * - RR (Round Robin): 时间片轮转调度
 * - FIFO (First In First Out): 先进先出调度
 * - SJF (Shortest Job First): 最短作业优先调度
 * - Stride: 步进调度算法
 */
// The introduction of scheduling classes is borrrowed from Linux, and makes the
// core scheduler quite extensible. These classes (the scheduler modules) encapsulate
// the scheduling policies.
struct sched_class
{
    /**
     * name - 调度类的名称
     * 用于标识当前使用的调度算法，如 "RR_scheduler", "stride_scheduler" 等
     */
    // the name of sched_class
    const char *name;
    
    /**
     * init - 初始化运行队列
     * @rq: 指向运行队列的指针
     * 
     * 初始化运行队列的各个成员变量，如链表头、进程计数等
     */
    // Init the run queue
    void (*init)(struct run_queue *rq);
    
    /**
     * enqueue - 将进程加入运行队列
     * @rq: 指向运行队列的指针
     * @proc: 指向待加入队列的进程控制块
     * 
     * 将指定进程放入运行队列中，调用此函数时必须持有rq_lock锁
     * 不同调度算法的入队策略不同：
     * - RR/FIFO: 加入队列尾部
     * - SJF: 按优先级排序插入
     * - Stride: 插入斜堆
     */
    // put the proc into runqueue, and this function must be called with rq_lock
    void (*enqueue)(struct run_queue *rq, struct proc_struct *proc);
    
    /**
     * dequeue - 将进程从运行队列中移除
     * @rq: 指向运行队列的指针
     * @proc: 指向待移除的进程控制块
     * 
     * 从运行队列中移除指定进程，调用此函数时必须持有rq_lock锁
     */
    // get the proc out runqueue, and this function must be called with rq_lock
    void (*dequeue)(struct run_queue *rq, struct proc_struct *proc);
    
    /**
     * pick_next - 选择下一个要运行的进程
     * @rq: 指向运行队列的指针
     * @return: 返回选中的进程控制块指针，如果队列为空则返回NULL
     * 
     * 根据调度策略从运行队列中选择下一个要执行的进程
     * - RR/FIFO: 选择队头进程
     * - SJF: 选择最短作业（队头即为最短）
     * - Stride: 选择stride值最小的进程
     */
    // choose the next runnable task
    struct proc_struct *(*pick_next)(struct run_queue *rq);
    
    /**
     * proc_tick - 处理时钟中断
     * @rq: 指向运行队列的指针
     * @proc: 当前正在运行的进程
     * 
     * 每次时钟中断时被调用，用于更新进程的时间片
     * 当时间片用完时，设置need_resched标志触发调度
     * - RR/Stride: 减少时间片，时间片为0时设置重调度标志
     * - FIFO/SJF: 非抢占式，不做任何操作
     */
    // dealer of the time-tick
    void (*proc_tick)(struct run_queue *rq, struct proc_struct *proc);
    
    /* for SMP support in the future
     *  load_balance
     *     void (*load_balance)(struct rq* rq);
     *  get some proc from this rq, used in load_balance,
     *  return value is the num of gotten proc
     *  int (*get_proc)(struct rq* rq, struct proc* procs_moved[]);
     */
};

/**
 * struct run_queue - 运行队列结构体
 * 
 * 运行队列用于管理所有处于就绪状态的进程
 * 支持两种数据结构来组织进程：
 * 1. 双向链表 (run_list): 用于RR、FIFO、SJF等调度算法
 * 2. 斜堆 (lab6_run_pool): 用于Stride调度算法，实现O(log n)的优先级队列
 */
struct run_queue
{
    /**
     * run_list - 运行队列的链表头
     * 使用双向循环链表管理就绪进程
     * 进程通过其proc_struct中的run_link成员链接到此链表
     */
    list_entry_t run_list;
    
    /**
     * proc_num - 运行队列中的进程数量
     * 记录当前在运行队列中等待调度的进程总数
     */
    unsigned int proc_num;
    
    /**
     * max_time_slice - 最大时间片
     * 进程被调度时分配的初始时间片大小
     * 通常设置为 MAX_TIME_SLICE (值为5)
     */
    int max_time_slice;
    
    /**
     * lab6_run_pool - 斜堆根节点指针 (仅用于LAB6)
     * 用于Stride调度算法的优先级队列实现
     * 斜堆是一种自调整的堆结构，支持高效的合并操作
     * 堆顶元素即为stride值最小的进程
     */
    // For LAB6 ONLY
    skew_heap_entry_t *lab6_run_pool;
};

/*===========================================================================*
 *                         调度器接口函数声明                                   *
 *===========================================================================*/

/**
 * sched_init - 初始化调度器
 * 
 * 在系统启动时调用，完成以下工作：
 * 1. 初始化定时器链表
 * 2. 设置当前使用的调度类（如stride_sched_class）
 * 3. 初始化全局运行队列
 */
void sched_init(void);

/**
 * wakeup_proc - 唤醒进程
 * @proc: 要唤醒的进程控制块指针
 * 
 * 将指定进程的状态设置为PROC_RUNNABLE（就绪态）
 * 并将其加入运行队列，等待调度器调度执行
 */
void wakeup_proc(struct proc_struct *proc);

/**
 * schedule - 进程调度函数
 * 
 * 核心调度函数，执行以下操作：
 * 1. 如果当前进程仍处于就绪态，将其重新加入运行队列
 * 2. 从运行队列中选择下一个要执行的进程
 * 3. 如果没有可运行进程，则运行idle进程
 * 4. 执行进程上下文切换
 */
void schedule(void);

/**
 * sched_class_proc_tick - 处理进程的时钟节拍
 * @proc: 当前正在运行的进程
 * 
 * 在每次时钟中断时被调用
 * 调用调度类的proc_tick方法来更新进程时间片
 * 对于idle进程，直接设置need_resched标志
 */
void sched_class_proc_tick(struct proc_struct *proc);

#endif /* !__KERN_SCHEDULE_SCHED_H__ */
