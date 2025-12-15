#ifndef __KERN_PROCESS_PROC_H__
#define __KERN_PROCESS_PROC_H__

#include <defs.h>
#include <list.h>
#include <trap.h>
#include <memlayout.h>

// process's state in his life cycle
// [Report Context]: 对应实验报告中的“进程执行状态生命周期图”
enum proc_state
{
    PROC_UNINIT = 0, // uninitialized: alloc_proc 刚分配，尚未初始化完成
    PROC_SLEEPING,   // sleeping: 当进程调用 do_wait 等待子进程，或等待其他资源时
    PROC_RUNNABLE,   // runnable(maybe running): 
                     // 在 uCore 中，就绪态和运行态统称为 RUNNABLE。
                     // 调度器只从 RUNNABLE 的进程中选择。
    PROC_ZOMBIE,     // almost dead: 进程已调用 do_exit，释放了大部分资源（如 mm），
                     // 但 PCB 和内核栈尚未释放，等待父进程 do_wait 回收。
};

// [Context Switch]: 保存内核上下文
// 当发生进程切换（schedule -> proc_run -> switch_to）时，
// 被挂起进程的“内核态”寄存器会保存在这里。
// 注意：这与 trapframe 不同。trapframe 保存的是“中断前（可能是用户态）”的现场。
// context 保存的是“内核调度器切换前”的现场（通常是在 schedule 函数中）。
struct context
{
    uintptr_t ra; // Return Address (switch_to 返回后的地址)
    uintptr_t sp; // Kernel Stack Pointer (当前进程的内核栈顶)
    uintptr_t s0; // Saved Registers (Callee-saved 寄存器)
    uintptr_t s1; // 依据 RISC-V 调用约定，这些寄存器需要由被调用者保存
    uintptr_t s2;
    uintptr_t s3;
    uintptr_t s4;
    uintptr_t s5;
    uintptr_t s6;
    uintptr_t s7;
    uintptr_t s8;
    uintptr_t s9;
    uintptr_t s10;
    uintptr_t s11;
};

#define PROC_NAME_LEN 15
#define MAX_PROCESS 4096
#define MAX_PID (MAX_PROCESS * 2)

extern list_entry_t proc_list;

// [PCB]: 进程控制块 (Process Control Block)
// 这是 Lab 5 中最重要的数据结构。
struct proc_struct
{
    enum proc_state state;                      // Process state (UNINIT, SLEEPING, RUNNABLE, ZOMBIE)
    int pid;                                    // Process ID
    int runs;                                   // 统计进程被调度执行的次数 (调试用)
    uintptr_t kstack;                           // Process kernel stack
                                                // 每个线程/进程都有独立的内核栈。
                                                // 当从用户态陷入内核态时 (Trap)，CPU 栈指针 sp 会切换到这里。
    
    volatile bool need_resched;                 // [Scheduling]: 抢占标志位
                                                // 在 interrupt_handler 中，如果时间片耗尽，置为 1。
                                                // 在 trap 返回前检查此位，决定是否调用 schedule()。
    
    struct proc_struct *parent;                 // 父进程指针 (Fork 时设置)
                                                // 用于 exit 时通知父进程，或 wait 时查找子进程。
    
    struct mm_struct *mm;                       // [Memory Management]: 内存管理结构
                                                // 包含 vma 链表和页目录表指针。
                                                // Lab 5 中，用户进程拥有独立的 mm，内核线程 mm 为 NULL。
                                                // fork 时通过 copy_mm (COW) 复制，exec 时通过 exit_mmap 清空。
    
    struct context context;                     // [Context Switch]: 内核上下文
                                                // 用于 switch_to 汇编函数切换进程。
    
    struct trapframe *tf;                       // [Trap Handling]: 中断帧指针
                                                // 总是指向内核栈的特定位置。
                                                // 当进程在用户态被中断时，用户态寄存器保存在这里。
                                                // sys_fork/exec 等系统调用通过修改 tf 来控制返回用户态后的 PC、SP 和返回值。
    
    uintptr_t pgdir;                            // 页目录表 (Page Directory Table) 的内核虚拟地址 (vaddr)
                                                // 在进程切换 (proc_run) 时，通过 lcr3(padcr3) 将其物理地址加载到 SATP 寄存器。
    
    uint32_t flags;                             // Process flag (如 PF_EXITING)
    char name[PROC_NAME_LEN + 1];               // Process name
    
    list_entry_t list_link;                     // 链接到全局 proc_list
    list_entry_t hash_link;                     // 链接到全局 hash_list (用于 pid 快速查找)
    
    int exit_code;                              // [Exit]: 退出码
                                                // 当 do_exit 退出时设置，父进程通过 do_wait 获取此值。
    
    uint32_t wait_state;                        // [Wait]: 等待原因 (如 WT_CHILD)
                                                // 记录进程当前为什么在 SLEEPING (等待子进程？等待IO？)
    
    // [Process Family Tree]: 进程关系链表
    // 用于维护父子、兄弟关系，方便 do_exit 时将孤儿进程过继给 initproc。
    struct proc_struct *cptr;                   // Child Pointer: 指向最年轻（最近创建）的子进程
    struct proc_struct *yptr;                   // Younger Sibling Pointer: 指向比自己年轻的下一个兄弟进程
    struct proc_struct *optr;                   // Older Sibling Pointer: 指向比自己年长的上一个兄弟进程
    
    // [Lab 5 Scheduling]: 时间片 (Time Slice)
    // 初始化为 TICK_NUM (如 3)。
    // 每次时钟中断 (trap.c: interrupt_handler) 减 1。
    // 减为 0 时触发调度。在 schedule() 中被重置。
    int time_slice;
};

#define PF_EXITING 0x00000001 // 标记进程正在执行 do_exit，即将消亡

// [Wait State]: 等待状态标记
#define WT_CHILD (0x00000001 | WT_INTERRUPTED) // 正在等待子进程 (sys_wait)
#define WT_INTERRUPTED 0x80000000              // 等待可被中断 (本实验未深入使用)

#define le2proc(le, member) \
    to_struct((le), struct proc_struct, member)

extern struct proc_struct *idleproc, *initproc, *current;

// 初始化进程管理子系统 (proc.c)
void proc_init(void);
// 进程切换的具体执行者 (switch_to 的 C 封装)
void proc_run(struct proc_struct *proc);
// 创建内核线程 (Lab 4 基础)
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);

// 工具函数：设置/获取进程名
char *set_proc_name(struct proc_struct *proc, const char *name);
char *get_proc_name(struct proc_struct *proc);
// CPU 空闲时运行的循环 (idleproc 的执行体)
void cpu_idle(void) __attribute__((noreturn));

// 根据 PID 查找 PCB
struct proc_struct *find_proc(int pid);

// [Syscall Implementation]
// 以下函数对应 Lab 5 的四个核心系统调用，是练习 3 分析的重点：

// fork(): 创建子进程
// 1. alloc_proc 分配 PCB
// 2. setup_kstack 分配内核栈
// 3. copy_mm 复制内存 (COW 机制在这里触发)
// 4. copy_thread 设置 tf 和 context
// 5. 插入链表并唤醒
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);

// exit(): 退出进程
// 1. 释放虚拟内存 (mm)
// 2. 设为 ZOMBIE 状态
// 3. 唤醒父进程 (如果父进程在 wait)
// 4. 将子进程过继给 initproc
// 5. 调用 schedule() 让出 CPU
int do_exit(int error_code);

// yield(): 主动让出 CPU
// 设置 need_resched = 1 并调用 schedule()
int do_yield(void);

// execve(): 加载新程序
// 1. 检查参数合法性
// 2. 清空当前进程内存 (exit_mmap)
// 3. load_icode 加载二进制文件 (注意：Lab5 是 Link-in-Kernel，直接从内存拷贝)
// 4. 重置 trapframe (epc = entry point, sp = user stack)
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size);

// wait(): 等待子进程
// 1. 查找是否有 ZOMBIE 状态的子进程
// 2. 若有，回收其 PCB 和内核栈，返回退出码
// 3. 若无但有运行中的子进程，设置 wait_state = WT_CHILD 并 schedule() 睡眠
int do_wait(int pid, int *code_store);

// kill(): 杀进程
// 设置 PF_EXITING 标志，进程下次进入内核时会退出
int do_kill(int pid);

#endif /* !__KERN_PROCESS_PROC_H__ */