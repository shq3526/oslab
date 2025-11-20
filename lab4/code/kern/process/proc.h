#ifndef __KERN_PROCESS_PROC_H__
#define __KERN_PROCESS_PROC_H__

#include <defs.h>
#include <list.h>
#include <trap.h>
#include <memlayout.h>

// process's state in his life cycle
// 进程生命周期中的状态枚举
enum proc_state
{
    PROC_UNINIT = 0, // uninitialized
                     // 未初始化状态：alloc_proc 刚分配了结构体，但尚未分配资源或初始化。
    PROC_SLEEPING,   // sleeping
                     // 睡眠/阻塞状态：进程正在等待某个事件（如 I/O 操作完成、子进程退出等），此时不占用 CPU。
    PROC_RUNNABLE,   // runnable(maybe running)
                     // 就绪/运行状态：进程已经准备好，可以被调度器选中在 CPU 上执行，或者当前正在执行。
    PROC_ZOMBIE,     // almost dead, and wait parent proc to reclaim his resource
                     // 僵尸状态：进程已退出（do_exit），但其父进程尚未通过 wait 回收其 PCB 资源。
};

// 进程上下文结构体
// 作用：保存进程切换（Context Switch）时需要持久化的寄存器状态。
// 原理：在 RISC-V 中，函数调用约定将寄存器分为 Caller-Saved（调用者保存）和 Callee-Saved（被调用者保存）。
// switch_to 函数在切换进程时，只需要保存 Callee-Saved 寄存器，因为 Caller-Saved 寄存器
// 已经被编译器在调用 switch_to 之前处理好了（或者在切换点不需要保持）。
struct context
{
    uintptr_t ra;  // Return Address: 函数返回地址。
                   // 当进程被切换回来时，CPU 将跳转到 ra 指向的地址继续执行（通常是 switch_to 的下一条指令或 forkret）。
    uintptr_t sp;  // Stack Pointer: 栈指针。
                   // 指向该进程的内核栈栈顶，恢复上下文时必须先恢复栈。
    uintptr_t s0;  // s0 -- s11: Callee-Saved Registers (被调用者保存寄存器)。
    uintptr_t s1;  // 这些寄存器在函数调用前后必须保持不变。
    uintptr_t s2;  // 因此，操作系统必须在切换进程时手动保存和恢复它们。
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

// 进程控制块 (Process Control Block, PCB)
// 操作系统管理进程的核心数据结构
struct proc_struct
{
    enum proc_state state;        // Process state
                                  // 进程当前状态 (UNINIT, SLEEPING, RUNNABLE, ZOMBIE)
    int pid;                      // Process ID
                                  // 进程唯一标识符
    int runs;                     // the running times of Proces
                                  // 进程运行次数（或时间片），调度器可利用此信息进行调度决策
    uintptr_t kstack;             // Process kernel stack
                                  // 进程的内核栈基地址。
                                  // 每个进程在内核态执行（如系统调用、中断处理）时都需要自己的栈。
                                  // 创建进程时通过 setup_kstack 分配（通常是 2 个物理页）。
    volatile bool need_resched;   // bool value: need to be rescheduled to release CPU?
                                  // 调度标志位：如果为 true，表示当前进程的时间片用完或被抢占，
                                  // 需要在适当的时机（如中断返回前）调用 schedule() 让出 CPU。
    struct proc_struct *parent;   // the parent process
                                  // 指向父进程的指针。用于构建进程树，以及子进程退出时通知父进程。
    struct mm_struct *mm;         // Process's memory management field
                                  // 内存管理结构指针（包含 VMA 链表、页表指针等）。
                                  // 重要区别：用户进程拥有独立的 mm；内核线程（如 idle, init）此字段为 NULL，
                                  // 因为内核线程直接共享内核的内存空间。
    struct context context;       // Switch here to run process
                                  // 进程上下文数据。
                                  // 保存了进程暂停时的寄存器状态（ra, sp, s0-s11），用于 switch_to 恢复执行。
    struct trapframe *tf;         // Trap frame for current interrupt
                                  // 中断帧指针。
                                  // 指向内核栈的某个位置，保存了进程从用户态陷入内核态（或发生中断）前的
                                  // 完整寄存器现场（包括 pc, sp, 通用寄存器等）。
                                  // 在创建新进程时，tf 用于伪造一个中断现场，使进程从 kernel_thread_entry 开始执行。
    uintptr_t pgdir;              // the base addr of Page Directroy Table(PDT)
                                  // 页目录表的物理基地址。
                                  // 进程运行时，该值会被加载到 SATP 寄存器，从而切换到该进程的虚拟地址空间。
    uint32_t flags;               // Process flag
                                  // 进程标志位（目前尚未大量使用，可用于标记特殊状态）。
    char name[PROC_NAME_LEN + 1]; // Process name
                                  // 进程名称，用于调试打印。
    list_entry_t list_link;       // Process link list
                                  // 全局进程链表节点。所有进程都通过此节点链接在 proc_list 中。
    list_entry_t hash_link;       // Process hash list
                                  // 进程哈希表节点。用于通过 PID 快速查找对应的 proc_struct。
};

// 宏：将链表节点 list_entry_t 转换为 proc_struct 指针
#define le2proc(le, member) \
    to_struct((le), struct proc_struct, member)

// 外部全局变量声明
extern struct proc_struct *idleproc, *initproc, *current;

// 函数声明
void proc_init(void);                                                    // 初始化进程子系统
void proc_run(struct proc_struct *proc);                                 // 调度并运行指定进程
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);   // 创建内核线程

char *set_proc_name(struct proc_struct *proc, const char *name);         // 设置进程名
char *get_proc_name(struct proc_struct *proc);                           // 获取进程名
void cpu_idle(void) __attribute__((noreturn));                           // idle 进程的主循环

struct proc_struct *find_proc(int pid);                                  // 根据 PID 查找进程
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf); // 创建新进程（核心实现）
int do_exit(int error_code);                                             // 退出当前进程

#endif /* !__KERN_PROCESS_PROC_H__ */