/**
 * default_sched_sjf.c - SJF (Shortest Job First) 最短作业优先调度算法实现
 * 
 * SJF调度算法是一种基于作业预估执行时间的调度算法：
 * - 优先选择预估执行时间最短的进程执行
 * - 使用lab6_priority字段存储作业长度（值越小，作业越短）
 * - 入队时按优先级排序插入，保持队列有序
 * - 出队时直接取队首元素（最短作业）
 * 
 * 算法特点：
 * - 平均等待时间最短（对于非抢占式SJF）
 * - 可能导致长作业饥饿
 * - 需要事先知道作业长度（在实际系统中通常需要预测）
 * 
 * 本实现为非抢占式SJF：
 * - 正在运行的进程不会被更短的新进程抢占
 * - 只有在当前进程主动放弃CPU时才会切换
 * 
 * 算法复杂度：
 * - 入队: O(n) - 需要遍历队列找到插入位置
 * - 出队: O(1)
 * - 选择下一进程: O(1)
 */

#include <defs.h>    // 基本类型定义
#include <list.h>    // 双向链表数据结构
#include <proc.h>    // 进程控制块定义
#include <sched.h>   // 调度器头文件
#include <assert.h>  // 断言宏

// --------------------------------------------------------------
// 1. 实现 SJF 自己的 Init (逻辑和 FIFO 一样)
// --------------------------------------------------------------
/**
 * sjf_init - 初始化SJF调度器的运行队列
 * @rq: 指向运行队列的指针
 * 
 * 初始化运行队列的成员变量：
 * - run_list: 初始化为空的双向循环链表
 * - proc_num: 设置为0，表示队列中没有进程
 */
static void
sjf_init(struct run_queue *rq) {
    // 初始化运行队列链表
    list_init(&(rq->run_list));
    // 初始化进程计数为0
    rq->proc_num = 0;
}

// --------------------------------------------------------------
// 2. 实现 SJF 的核心：Enqueue (按优先级排序插入)
// --------------------------------------------------------------
/**
 * sjf_enqueue - 将进程按作业长度有序插入运行队列
 * @rq: 指向运行队列的指针
 * @proc: 要加入队列的进程控制块
 * 
 * SJF调度的核心：按作业长度（lab6_priority）排序插入
 * - lab6_priority值越小，表示作业越短，应该排在前面
 * - 遍历队列找到第一个priority比当前进程大的位置
 * - 将当前进程插入到该位置之前
 * - 这样队列始终保持按priority从小到大排序
 * 
 * 时间复杂度：O(n)，需要遍历队列找到插入位置
 */
static void
sjf_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    // 断言进程的run_link为空，确保进程不在任何队列中
    assert(list_empty(&(proc->run_link)));
    
    // 获取队列头
    // 获取队列中的第一个元素
    list_entry_t *le = list_next(&(rq->run_list));
    
    // 遍历队列，找到第一个 priority 比当前进程大的节点
    // 从而实现：队列一直是按 priority 从小到大排序的
    // 遍历队列，寻找插入位置
    while (le != &(rq->run_list)) {
        // 获取当前链表节点对应的进程
        struct proc_struct *next_proc = le2proc(le, run_link);
        // 如果当前进程的priority更小，说明找到了插入位置
        if (proc->lab6_priority < next_proc->lab6_priority) {
            break;
        }
        // 继续检查下一个节点
        le = list_next(le);
    }
    
    // 将当前进程插在那个节点前面
    // 将进程插入到找到的位置
    list_add_before(le, &(proc->run_link));
    
    // 设置进程所属的运行队列
    proc->rq = rq;
    // 增加队列中的进程计数
    rq->proc_num++;
}

// --------------------------------------------------------------
// 3. 实现 SJF 自己的 Dequeue (逻辑和 FIFO 一样)
// --------------------------------------------------------------
/**
 * sjf_dequeue - 将进程从运行队列中移除
 * @rq: 指向运行队列的指针
 * @proc: 要移除的进程控制块
 * 
 * 从运行队列中移除指定进程：
 * - 验证进程确实在队列中
 * - 使用list_del_init移除节点并重新初始化
 * - 减少运行队列的进程计数
 */
static void
sjf_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    // 断言进程在队列中且属于当前运行队列
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
    // 从队列中移除进程
    list_del_init(&(proc->run_link));
    // 减少队列中的进程计数
    rq->proc_num--;
}

// --------------------------------------------------------------
// 4. Pick Next (取队头，就是最短作业)
// --------------------------------------------------------------
/**
 * sjf_pick_next - 选择下一个要运行的进程（最短作业）
 * @rq: 指向运行队列的指针
 * @return: 返回最短作业的进程指针，队列为空时返回NULL
 * 
 * 由于入队时已经按作业长度排序：
 * - 队首元素就是最短作业
 * - 直接返回队首进程即可
 * - 时间复杂度: O(1)
 */
static struct proc_struct *
sjf_pick_next(struct run_queue *rq) {
    // 如果队列为空，返回NULL
    if (rq->proc_num == 0) return NULL;
    // 因为 enqueue 时已经排序，直接取队头就是最短作业
    // 获取队列中的第一个元素（最短作业）
    list_entry_t *le = list_next(&(rq->run_list));
    // 返回对应的进程指针
    return le2proc(le, run_link);
}

// --------------------------------------------------------------
// 5. Tick (SJF 通常是非抢占的，这里留空即可)
// --------------------------------------------------------------
/**
 * sjf_proc_tick - 处理时钟中断事件
 * @rq: 指向运行队列的指针
 * @proc: 当前正在运行的进程
 * 
 * 非抢占式SJF调度：
 * - 不响应时钟中断
 * - 不设置need_resched标志
 * - 进程会一直运行直到主动放弃CPU
 * 
 * 这是与抢占式SJF（SRTF，最短剩余时间优先）的区别
 * SRTF会在新的更短作业到来时抢占当前进程
 */
static void
sjf_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    // 非抢占式调度，Tick 不做任何事，直到进程自己放弃 CPU
}

// --------------------------------------------------------------
// 6. 定义结构体
// --------------------------------------------------------------
/**
 * sjf_sched_class - SJF调度类实例
 * 
 * 定义SJF调度算法的调度类结构体
 * 将各个操作函数封装成统一的接口供调度器调用
 */
struct sched_class sjf_sched_class = {
    .name = "SJF_scheduler",      // 调度器名称
    .init = sjf_init,             // 改用 sjf_init // 初始化函数
    .enqueue = sjf_enqueue,       // 入队函数（按作业长度排序）
    .dequeue = sjf_dequeue,       // 改用 sjf_dequeue // 出队函数
    .pick_next = sjf_pick_next,   // 选择下一进程函数（取队首最短作业）
    .proc_tick = sjf_proc_tick,   // 时钟处理函数（空实现）
};