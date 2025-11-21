#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

/* ------------- 进程/线程机制的设计与实现 -------------
(一个简化的 Linux 风格进程/线程机制)

简介:
  ucore 实现了一个简单的进程/线程机制。
  一个进程包含了：
    1. 独立的内存空间 (页表)
    2. 至少一个用于执行的线程
    3. 内核数据结构 (用于管理，如 proc_struct)
    4. 处理器状态 (用于上下文切换，如 context)
    5. 文件系统信息 (在 lab6 中涉及) 等等。
  ucore 需要高效地管理所有这些细节。
  在 ucore 中，线程本质上只是一类特殊的进程——它们共享同一个进程的内存空间（mm_struct）。

------------------------------
进程状态说明        :   含义                    -- 状态转换原因
    PROC_UNINIT     :   未初始化                -- alloc_proc (刚分配了控制块，还未分配资源)
    PROC_SLEEPING   :   睡眠中 (阻塞)           -- try_free_pages, do_wait, do_sleep (等待资源或事件)
    PROC_RUNNABLE   :   就绪/可运行             -- proc_init, wakeup_proc (准备好被调度，或正在运行)
    PROC_ZOMBIE     :   僵尸状态 (已退出)       -- do_exit (进程已结束，等待父进程回收 PCB)

-----------------------------
进程状态变迁图:

  alloc_proc                                 RUNNING (运行中，逻辑上属于 RUNNABLE)
      +                                   +--<----<--+
      +                                   + proc_run + (调度器选中执行)
      V                                   +-->---->--+
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  +
                                           -----------------------wakeup_proc----------------------------------
                                           (资源满足或事件发生，唤醒进程)
-----------------------------
进程亲属关系:
parent:           proc->parent  (指向当前进程的父进程)
children:         proc->cptr    (指向当前进程的第一个子进程)
older sibling:    proc->optr    (指向当前进程的哥哥/上一个兄弟)
younger sibling:  proc->yptr    (指向当前进程的弟弟/下一个兄弟)
-----------------------------
相关的系统调用 (System Calls):
SYS_exit        : 进程退出                                --> do_exit
SYS_fork        : 创建子进程, 复制内存空间                --> do_fork --> wakeup_proc
SYS_wait        : 等待子进程结束                          --> do_wait
SYS_exec        : fork 后, 用新程序覆盖当前进程内存       --> 加载程序并刷新 mm
SYS_clone       : 创建子线程 (共享内存)                   --> do_fork --> wakeup_proc
SYS_yield       : 进程主动放弃 CPU                        --> proc->need_sched=1, 调度器重新调度
SYS_sleep       : 进程睡眠一定时间                        --> do_sleep
SYS_kill        : 杀死进程                                --> do_kill --> proc->flags |= PF_EXITING
                                                                 --> wakeup_proc --> do_wait --> do_exit
SYS_getpid      : 获取进程的 pid

*/

// 进程集合链表 (所有存在的进程都挂在这个链表上)
list_entry_t proc_list;

// 哈希表配置
#define HASH_SHIFT 10
#define HASH_LIST_SIZE (1 << HASH_SHIFT)
#define pid_hashfn(x) (hash32(x, HASH_SHIFT))

// 基于 PID 的进程哈希表 (用于通过 PID 快速查找 proc_struct)
static list_entry_t hash_list[HASH_LIST_SIZE];

// idle proc (空闲进程)
// 这是内核启动时的第一个进程，pid=0。
// 当就绪队列为空时，调度器会调度 idleproc 运行 (通常是一个死循环)。
struct proc_struct *idleproc = NULL;

// idleproc 是操作系统中的第 0 号内核线程。它是系统启动后创建的第一个进程（或线程），也是系统中唯一一个永远不会被销毁的进程。

// idleproc 的主要作用
// 作为调度器的“兜底”进程：
// 当系统的就绪队列（Run Queue）为空时（即没有任何其他进程处于 PROC_RUNNABLE 状态）
// 调度器（schedule 函数）必须有一个进程可以运行，否则 CPU 将无事可做。
// 这时，调度器会选择运行 idleproc。
// idleproc 就像是一个“占位符”，保证 CPU 总是有代码在执行，而不是处于未定义状态。

// 节能与低功耗：
// 在现代操作系统中，idleproc 的循环体通常不仅仅是死循环，还会包含特殊的 CPU 指令（如 x86 的 hlt 或 RISC-V 的 wfi - Wait For Interrupt）。
// 这些指令会让 CPU 进入低功耗模式，暂停执行指令，直到下一个中断（如时钟中断或 I/O 中断）到来。
// 在 ucore 的 Lab 4 中，虽然实现比较简单，但在 cpu_idle 函数中通常会看到这种设计。

// 辅助调度：

// idleproc 在运行时，如果被中断打断（例如时钟中断），中断处理程序会检查是否有新的进程变为了就绪状态。
// 如果有，idleproc 的 need_resched 标志会被置位，促使调度器切换到新的进程。

// init proc (初始化进程)
// 这是第1个内核线程，pid=1。它是所有用户进程的祖先。

struct proc_struct *initproc = NULL;

// current proc (当前指针)
// 指向当前正在 CPU 上运行的进程的 proc_struct。
// 在中断处理、调度等内核代码中，current 非常重要。
struct proc_struct *current = NULL;

// 系统中当前的进程总数
static int nr_process = 0;

// 前置声明
void kernel_thread_entry(void);
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - 分配一个 proc_struct 结构并初始化所有字段
// 这是一个工厂函数，负责生产一个“干净”的进程控制块。
// 注意：它只分配 PCB 本身的内存，不分配内核栈或页表等资源。
static struct proc_struct *
alloc_proc(void)
{
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL)
    {
        // LAB4:EXERCISE1 2312220
        /*
         * 设计思路：
         * kmalloc 分配的内存包含未定义的垃圾数据，因此必须逐个字段初始化。
         * 对于指针，初始化为 NULL；对于数值，初始化为 0 或特定初始值。
         * * 关键字段说明：
         * - state: 初始状态必须是 UNINIT，防止被调度器错误调度。
         * - pid: -1 表示该进程尚未分配有效 ID。
         * - cr3/pgdir: 内核线程共享内核页表，因此指向 boot_pgdir_pa。
         * - context: 必须清零，否则 switch_to 时会从寄存器加载垃圾数据导致崩溃。
         */
         
        proc->state = PROC_UNINIT;          // 状态初始化为未初始化
        proc->pid = -1;                     // PID 初始化为 -1 (无效值)
        proc->runs = 0;                     // 运行时间/次数初始化为 0
        proc->kstack = 0;                   // 内核栈地址初始化为 0 (稍后在 setup_kstack 中分配)
        proc->need_resched = 0;             // 刚创建时不急于抢占 CPU
        proc->parent = NULL;                // 父进程指针初始化为空
        proc->mm = NULL;                    // 内存管理结构 (内核线程不需要 mm，因为它们直接使用内核空间)
        memset(&(proc->context), 0, sizeof(struct context)); //清零上下文结构
        proc->tf = NULL;                    // 中断帧指针初始化为空 (将在 copy_thread 中设置)
        proc->pgdir = boot_pgdir_pa;        // 页目录表基址：默认使用内核页表 (重要！否则无法访问内核代码)
        proc->flags = 0;                    // 标志位清零
        memset(&(proc->name), 0, PROC_NAME_LEN + 1); // 进程名清零
    }
    return proc;
}

// set_proc_name - 设置进程的名称 (用于调试和显示)
char *
set_proc_name(struct proc_struct *proc, const char *name)
{
    memset(proc->name, 0, sizeof(proc->name));
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

// get_proc_name - 获取进程的名称
char *
get_proc_name(struct proc_struct *proc)
{
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

// get_pid - 为新进程分配一个唯一的 PID
// 算法策略：
// 1. 简单的递增分配 (last_pid + 1)。
// 2. 如果递增超过了 MAX_PID，则回绕到 1。
// 3. 如果发现 PID 冲突 (last_pid 已被占用)，则遍历链表寻找下一个空闲的 PID。
// 4. next_safe 变量用于优化搜索：它记录了比当前 PID 大的最小已占用 PID，避免每次都遍历链表。
static int
get_pid(void)
{
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    
    // 尝试直接递增
    if (++last_pid >= MAX_PID)
    {
        last_pid = 1;
        goto inside;
    }
    
    // 如果递增后的值 >= next_safe，说明可能碰到了已占用的区域，需要重新搜索
    if (last_pid >= next_safe)
    {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        // 遍历所有进程链表
        while ((le = list_next(le)) != list)
        {
            proc = le2proc(le, list_link);
            // 如果发现 last_pid 已经被某个进程占用
            if (proc->pid == last_pid)
            {
                // 尝试下一个 PID
                if (++last_pid >= next_safe)
                {
                    if (last_pid >= MAX_PID)
                    {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat; // 重新开始搜索
                }
            }
            // 维护 next_safe：找到一个比 last_pid 大的最小 PID
            else if (proc->pid > last_pid && next_safe > proc->pid)
            {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}

// proc_run - 实现进程切换的核心函数
// 作用：将 CPU 控制权从 current 进程移交给 proc 进程
void proc_run(struct proc_struct *proc)
{
    // 只有当目标进程不是当前进程时才需要切换
    if (proc != current)
    {
        // LAB4:EXERCISE3 2313547 2312220
        /*
         * 设计思路：
         * 进程切换涉及三个核心步骤：
         * 1. 保护现场：禁用中断，防止切换过程中断导致状态不一致。
         * 2. 切换地址空间：让 CPU 看见新进程的内存映射 (页表)。
         * 3. 切换执行流：保存旧寄存器，加载新寄存器 (Context Switch)。
         */
         
        bool intr_flag;
        struct proc_struct *prev_proc = current;
        
        // 1. 禁用中断 (Critical Section Start)
        // 在切换过程中，如果发生时钟中断，调度器可能会再次尝试调度，导致死锁或数据损坏。
        local_intr_save(intr_flag);
        {
            // 2. 更新当前进程指针
            current = proc;
            
            // 3. 切换页表 (地址空间切换)
            // lsatp 指令会更新 RISC-V 的 SATP 寄存器 (包含页表基址 PPN)。
            // 这步之后，TLB 会被刷新，CPU 看到的虚拟地址将映射到新进程的物理内存。
            // 对于内核线程，proc->pgdir 指向内核通用页表；对于用户进程，指向其专属页表。
            lsatp(proc->pgdir); 
            
            // 4. 执行上下文切换 (控制流切换)
            // 调用汇编实现的 switch_to(from, to)。
            // - 保存：将当前 CPU 寄存器 (ra, sp, s0-s11) 保存到 prev_proc->context。
            // - 恢复：将 proc->context 中的值加载到 CPU 寄存器。
            // - 跳转：switch_to 的最后一条指令是 ret，它会跳转到 proc->context.ra 指向的地址。
            //   (如果是新进程，ra 是 forkret；如果是旧进程，ra 是它上次 switch_to 后面的地址)
            switch_to(&(prev_proc->context), &(proc->context));
        }
        // 5. 恢复中断 (Critical Section End)
        // 注意：这行代码实际上是在 switch_to 返回后执行的。
        // 也就是说，是在进程“下次”被调度回来时执行的。
        local_intr_restore(intr_flag);
    }
}

// forkret - 新进程的“第一声啼哭”
// 当 switch_to 跳转到 proc->context.ra 时，如果是新进程，就会来到这里。
static void
forkret(void)
{
    // forkrets(tf) 是一个汇编函数 (在 trapentry.S 中)。
    // 它的作用是：将 trapframe (中断帧) 中的所有寄存器值恢复到 CPU 中。
    // 
    // 为什么需要这步？
    // 因为内核线程 (kernel_thread) 的创建是“伪造”了一个中断现场。
    // 我们构造了一个 tf，把 tf->epc 设置为 kernel_thread_entry。
    // 当 forkrets 执行 sret (从中断返回) 指令时，硬件会将 PC 跳转到 tf->epc，
    // 从而开始执行 kernel_thread_entry。
    forkrets(current->tf);
}

// hash_proc - 将进程插入哈希表
static void
hash_proc(struct proc_struct *proc)
{
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

// find_proc - 根据 PID 查找进程
struct proc_struct *
find_proc(int pid)
{
    if (0 < pid && pid < MAX_PID)
    {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list)
        {
            struct proc_struct *proc = le2proc(le, hash_link);
            if (proc->pid == pid)
            {
                return proc;
            }
        }
    }
    return NULL;
}

// kernel_thread - 创建一个内核线程
// 参数:
//   fn: 线程要执行的函数指针
//   arg: 传递给函数的参数
//   clone_flags: 克隆标志 (如 CLONE_VM)
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags)
{
    // 1. 构造一个临时的 trapframe (中断帧)
    // 这个 tf 用来描述“线程开始执行时的寄存器状态”。
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    
    // 2. 设置通用寄存器
    tf.gpr.s0 = (uintptr_t)fn;       // s0 保存函数地址
    tf.gpr.s1 = (uintptr_t)arg;      // s1 保存函数参数
    
    // 3. 设置状态寄存器 (sstatus)
    // - SSTATUS_SPP: Previous Privilege 是 Supervisor 模式 (因为是内核线程)
    // - SSTATUS_SPIE: Previous Interrupt Enable 为 1 (启用中断)
    // - ~SSTATUS_SIE: 当前先关闭中断，直到 sret 返回后才开启
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
    
    // 4. 设置 EPC (Exception Program Counter)
    // 这是线程真正的入口点。当 forkret 执行 sret 时，PC 会跳到这里。
    tf.epc = (uintptr_t)kernel_thread_entry;
    
    // 5. 调用 do_fork 进行实际的创建
    // CLONE_VM 意味着新线程共享当前进程的内存空间 (mm)。
    // stack=0 表示这是内核线程，不需要用户栈。
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}

// setup_kstack - 分配内核栈
// 每个进程/线程都需要一个独立的内核栈，用于：
// 1. 保存中断/异常发生时的 trapframe。
// 2. 执行内核代码时的函数调用栈 (局部变量等)。
static int
setup_kstack(struct proc_struct *proc)
{
    struct Page *page = alloc_pages(KSTACKPAGE); // 分配 KSTACKPAGE (通常是2页) 大小的物理内存
    if (page != NULL)
    {
        proc->kstack = (uintptr_t)page2kva(page); // 获取内核虚拟地址
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - 释放内核栈
static void
put_kstack(struct proc_struct *proc)
{
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

// copy_mm - 处理内存管理结构 (mm_struct)
// 根据 clone_flags 决定是复制 (fork) 还是共享 (thread) 内存。
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc)
{
    assert(current->mm == NULL);
    /* * 在 Lab 4 中，我们只涉及内核线程。
     * 内核线程没有独立的用户空间内存 (mm 为 NULL)，它们共享内核的页表。
     * 因此这里不需要做任何实际的内存复制工作。
     * 到了 Lab 5 实现用户进程时，这里会变得复杂。
     */
    return 0;
}

// copy_thread - 设置新进程的上下文 (Context) 和中断帧 (Trapframe)
// 这是进程创建中最关键的一步：它定义了新进程“醒来”时是什么样子的。
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf)
{
    // 1. 在内核栈的顶端预留空间存放 trapframe
    // 内核栈通常是从高地址向低地址增长的。
    // proc->kstack 指向栈底 (低地址)，proc->kstack + KSTACKSIZE 指向栈顶 (高地址)。
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
    
    // 2. 复制 trapframe 内容
    // 将 kernel_thread 中构造的临时 tf (包含入口函数 fn, 参数 arg, epc 等) 复制到进程的内核栈顶。
    *(proc->tf) = *tf;

    // 3. 设置返回值 a0
    // 在 RISC-V 调用约定中，a0 寄存器用于存放函数返回值。
    // 对于子进程，fork 的返回值应该是 0。
    proc->tf->gpr.a0 = 0;
    
    // 4. 设置栈指针 sp
    // 如果 esp 为 0 (内核线程)，sp 指向刚刚设置好的 trapframe 顶部。
    // 如果 esp 不为 0 (用户进程 fork)，sp 指向父进程传入的用户栈 esp。
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;

    // 5. 设置上下文 (context) 用于 switch_to
    // 当调度器调用 switch_to(prev, next) 时，next->context 将被恢复。
    
    // 设置 context.ra (返回地址) 为 forkret 函数的地址。
    // 这意味着：当 switch_to 执行完 ret 指令后，CPU 会跳转到 forkret 函数。
    proc->context.ra = (uintptr_t)forkret;
    
    // 设置 context.sp (栈指针) 指向 proc->tf。
    // 这样 forkret 函数执行时，使用的是该进程自己的内核栈。
    proc->context.sp = (uintptr_t)(proc->tf);
}

/* do_fork - 创建新进程的主函数 (父进程调用)
 * @clone_flags: 克隆标志 (如 CLONE_VM, CLONE_THREAD)
 * @stack: 父进程的用户栈指针 (如果为0表示内核线程)
 * @tf: 父进程的 trapframe (用于复制给子进程)
 * 返回值: 子进程的 PID
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    
    // 1. 检查全局进程数量限制
    if (nr_process >= MAX_PROCESS)
    {
        goto fork_out;
    }
    ret = -E_NO_MEM;

    // LAB4:EXERCISE2 2312580 2312220
    /*
     * 实现思路：
     * 1. 分配内存 (alloc_proc)
     * 2. 分配资源 (内核栈 setup_kstack, 内存 copy_mm)
     * 3. 设置执行现场 (copy_thread)
     * 4. 纳入管理 (hash_proc, list_add)
     * 5. 唤醒执行 (wakeup_proc)
     */

    // 1. 调用 alloc_proc 分配并初始化一个 proc_struct
    // 此时得到了一个空的 PCB。
    if ((proc = alloc_proc()) == NULL) {
        goto fork_out;
    }

    // 2. 调用 setup_kstack 为子进程分配内核栈
    // 没有内核栈，进程无法处理中断或进行函数调用。
    if (setup_kstack(proc) != 0) {
        goto bad_fork_cleanup_proc;
    }

    // 3. 调用 copy_mm 复制或共享内存管理结构
    // Lab 4 中此函数为空，直接返回。
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }

    // 4. 调用 copy_thread 设置 trapframe 和 context
    // 这步决定了进程被调度后从哪里开始执行。
    copy_thread(proc, stack, tf);

    // 5. 将新进程加入全局列表
    // 这里没有加锁，其实在并发环境下是不安全的 (题目要求如此，但实际内核开发需要 local_intr_save)。
    proc->pid = get_pid(); // 获取唯一的 PID
    hash_proc(proc);       // 加入哈希表，以便通过 PID 查找
    list_add(&proc_list, &(proc->list_link)); // 加入全局链表，用于调度和统计
    nr_process++;          // 进程总数 +1

    // 6. 唤醒新进程
    // 将状态设置为 PROC_RUNNABLE。
    // 注意：此时进程还没运行，只是告诉调度器“我可以跑了”。
    wakeup_proc(proc);

    // 7. 返回新进程的 PID
    ret = proc->pid;

fork_out:
    return ret;

// 错误处理路径：
// 如果中间某步失败，必须释放之前分配的所有资源，防止内存泄漏。
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}

// do_exit - 进程退出函数 (Lab 5 涉及)
int do_exit(int error_code)
{
    panic("process exit!!.\n");
}

// init_main - init 进程的主体函数
// 这是系统创建的第二个内核线程 (PID=1)。
static int
init_main(void *arg)
{
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
    cprintf("To U: \"%s\".\n", (const char *)arg);
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
    return 0;
}

// proc_init - 进程子系统初始化
// 系统启动时由 kern_init 调用。
void proc_init(void)
{
    int i;

    // 初始化全局链表
    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
    {
        list_init(hash_list + i);
    }

    // 1. 手工创建 idle 进程 (PID 0)
    // idle 进程是特殊的，它不是 fork 出来的，而是直接构造的。
    if ((idleproc = alloc_proc()) == NULL)
    {
        panic("cannot alloc idleproc.\n");
    }

    // 校验 alloc_proc 是否正确初始化了所有字段
    int *context_mem = (int *)kmalloc(sizeof(struct context));
    memset(context_mem, 0, sizeof(struct context));
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));

    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
    memset(proc_name_mem, 0, PROC_NAME_LEN);
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);

    if (idleproc->pgdir == boot_pgdir_pa && idleproc->tf == NULL && !context_init_flag && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0 && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag)
    {
        cprintf("alloc_proc() correct!\n");
    }

    // 初始化 idle 进程的字段
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
    idleproc->kstack = (uintptr_t)bootstack; // idle 使用启动时的 bootstack 作为内核栈
    idleproc->need_resched = 1;              // 标记需要调度，以便尽快切换到 init 进程
    set_proc_name(idleproc, "idle");
    nr_process++;

    // 将当前进程设置为 idle
    current = idleproc;

    // 2. 创建 init 进程 (PID 1)
    // 通过 kernel_thread 创建，它会调用 do_fork。
    int pid = kernel_thread(init_main, "Hello world!!", 0);
    if (pid <= 0)
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}

// cpu_idle - idle 进程的执行循环
// 当没有其他进程可运行时，CPU 会在这里空转。
void cpu_idle(void)
{
    while (1)
    {
        if (current->need_resched)
        {
            schedule(); // 当检测到需要调度时，系统通过schedule()选择可运行的线程并进行线程切换
        }
    }
}