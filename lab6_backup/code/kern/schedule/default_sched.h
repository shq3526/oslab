/**
 * default_sched.h - 调度类声明头文件
 * 
 * 本文件声明了系统中所有可用的调度类
 * 包括：
 * - default_sched_class: 默认调度类（RR时间片轮转调度）
 * - stride_sched_class:  步进调度类
 * - fifo_sched_class:    先进先出调度类
 * - sjf_sched_class:     最短作业优先调度类
 * 
 * 可以在sched.c的sched_init函数中选择使用哪种调度算法
 */
#ifndef __KERN_SCHEDULE_SCHED_RR_H__
#define __KERN_SCHEDULE_SCHED_RR_H__

#include <sched.h>  // 包含sched_class结构体定义

/* 调度类声明 */

/**
 * default_sched_class - 默认调度类（RR时间片轮转）
 * 实现在 default_sched.c 中
 * 特点：公平调度，每个进程分配相同的时间片
 */
extern struct sched_class default_sched_class;

/**
 * stride_sched_class - 步进调度类
 * 实现在 default_sched_stride.c 中
 * 特点：按优先级比例分配CPU时间，使用斜堆实现高效的优先级队列
 */
extern struct sched_class stride_sched_class;

/**
 * fifo_sched_class - 先进先出调度类
 * 实现在 default_sched_fifo.c 中
 * 特点：非抢占式，先到达的进程先执行，直到其主动放弃CPU
 */
extern struct sched_class fifo_sched_class;

/**
 * sjf_sched_class - 最短作业优先调度类
 * 实现在 default_sched_sjf.c 中
 * 特点：非抢占式，优先执行预估执行时间最短的进程
 */
extern struct sched_class sjf_sched_class;

#endif /* !__KERN_SCHEDULE_SCHED_RR_H__ */

