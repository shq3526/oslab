#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <riscv.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>

/* ------------- 进程/线程机制设计与实现 -------------
(一个简化的 Linux 风格进程/线程机制)

【简介】:
uCore 实现了一个简单的进程/线程机制。
- 进程 (Process): 拥有独立的内存空间 (mm_struct)，至少包含一个用于执行的线程，包含内核管理数据 (PCB)、处理器状态 (Context)、文件描述符等。
- 线程 (Thread): 在 uCore 中，线程被视为一种特殊的进程，它们共享同一个内存空间 (share process's memory)。

------------------------------
【进程状态 (Process State)】:
    PROC_UNINIT    : 未初始化。alloc_proc 分配了内存但未填充数据。
    PROC_SLEEPING  : 睡眠/等待状态。等待资源 (内存、IO) 或等待子进程退出 (do_wait)。
    PROC_RUNNABLE  : 就绪/运行状态。在就绪队列中等待调度，或正在 CPU 上运行。
    PROC_ZOMBIE    : 僵尸状态。进程已退出 (do_exit)，资源已释放，但 PCB 仍保留，等待父进程回收。

-----------------------------
【进程状态转换图】:

  alloc_proc                                  RUNNING (获得 CPU)
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                 +
                                           |      +--- do_exit --> PROC_ZOMBIE                      +
                                           +                                                        +
                                           -----------------------wakeup_proc------------------------

-----------------------------
【进程关系 (Process Relations)】:
uCore 维护了一个进程家族树：
- parent:          指向父进程
- cptr (Children): 指向最年轻（最近创建）的子进程
- yptr (Younger):  指向比自己“年轻”的下一个兄弟进程
- optr (Older):    指向比自己“年长”的上一个兄弟进程

-----------------------------
【相关系统调用 (System Calls)】:
SYS_exit        : 进程退出                           --> do_exit
SYS_fork        : 创建子进程 (复制内存/COW)          --> do_fork --> wakeup_proc
SYS_wait        : 等待子进程                         --> do_wait
SYS_exec        : 加载新程序覆盖当前进程              --> load_icode (重置 mm)
SYS_clone       : 创建子线程 (共享内存)               --> do_fork (带 CLONE_VM)
SYS_yield       : 主动让出 CPU                       --> proc->need_sched=1, 触发 schedule
SYS_kill        : 杀死进程                           --> do_kill --> 设置 PF_EXITING 标志
SYS_getpid      : 获取 PID
*/
// 进程状态转换图：展示 UNINIT -> RUNNABLE -> RUNNING -> SLEEPING -> ZOMBIE 的流转

// 【全局进程链表】: 系统中所有进程的 PCB 都在这个双向链表中
list_entry_t proc_list;

// 【PID 哈希表】: 用于通过 PID 快速查找进程 (find_proc)，避免遍历整个 proc_list
#define HASH_SHIFT 10
#define HASH_LIST_SIZE (1 << HASH_SHIFT)
#define pid_hashfn(x) (hash32(x, HASH_SHIFT))
static list_entry_t hash_list[HASH_LIST_SIZE];

// 【核心进程指针】
struct proc_struct *idleproc = NULL; // 0号进程 (空闲进程): 当就没有其他进程运行时，运行此死循环
struct proc_struct *initproc = NULL; // 1号进程 (初始化进程): 第一个内核线程，负责启动用户态 init，并回收孤儿进程
struct proc_struct *current = NULL;  // 当前占用 CPU 的进程

static int nr_process = 0; // 当前系统中的进程总数

void kernel_thread_entry(void);
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

/*
 * alloc_proc - 分配并初始化一个新的进程控制块 (PCB)
 * * [功能]:
 * 1. 从内核堆分配 struct proc_struct 的内存。
 * 2. 将所有字段初始化为默认值 (0, NULL, UNINIT)。
 */
static struct proc_struct *
alloc_proc(void)
{
    // 从内核堆分配 PCB 结构体内存
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL)
    {
        // LAB4:EXERCISE1 YOUR CODE
        // LAB5 YOUR CODE : 2312220(update LAB4 steps)
        
        // [1] 基本状态初始化
        proc->state = PROC_UNINIT;          // 初始状态设为未初始化
        proc->pid = -1;                     // PID 初始化为 -1 (无效)
        proc->runs = 0;                     // 运行时间/次数归零
        proc->kstack = 0;                   // 内核栈指针初始化为 0 (稍后在 setup_kstack 分配)
        proc->need_resched = 0;             // 初始不需要调度
        proc->parent = NULL;                // 父进程指针置空
        proc->mm = NULL;                    // 内存描述符置空 (内核线程不需要，用户进程在 do_fork/exec 时分配)
        
        // [2] 上下文与中断帧清零
        // context 用于进程切换 (switch_to)，保存 callee-saved 寄存器
        memset(&(proc->context), 0, sizeof(struct context)); 
        // tf 用于中断/系统调用返回 (sret)，保存中断现场
        proc->tf = NULL;                    
        
        // [3] 页表初始化
        // 初始指向内核页表基址，确保即使没有用户空间也能在内核运行
        proc->pgdir = boot_pgdir_pa;        
        
        proc->flags = 0;                    // 标志位清零
        memset(&(proc->name), 0, PROC_NAME_LEN + 1); // 进程名清零

        // [Lab 5 新增] 等待状态与进程关系链表
        proc->wait_state = 0; // 0 表示没有在等待，WT_CHILD 表示等待子进程
        
        // 初始化家族关系指针
        // cptr: 指向第一个(最年轻)子进程
        // yptr: 指向下一个(更年轻)兄弟进程
        // optr: 指向上一个(更年长)兄弟进程
        proc->cptr = proc->optr = proc->yptr = NULL;
        
        // [Lab 5 调度] 时间片初始化
        // 用于 Round-Robin 调度算法，初始为 0
        proc->time_slice = 0;
    }
    return proc;
}

// set_proc_name - 设置进程名 (用于调试显示)
char *
set_proc_name(struct proc_struct *proc, const char *name)
{
    memset(proc->name, 0, sizeof(proc->name));
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

// get_proc_name - 获取进程名
char *
get_proc_name(struct proc_struct *proc)
{
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

/*
 * set_links - 设置进程的家族关系链接
 * * [功能]:
 * 将新进程 proc 插入到全局链表和父进程的子链表中。
 */
static void
set_links(struct proc_struct *proc)
{
    // 将进程加入全局进程链表
    list_add(&proc_list, &(proc->list_link));
    
    proc->yptr = NULL; // 新进程是最年轻的，所以没有比它更年轻的弟弟 (yptr=NULL)
    
    // 如果父进程已经有子进程 (parent->cptr != NULL)
    if ((proc->optr = proc->parent->cptr) != NULL)
    {
        proc->optr->yptr = proc; // 让原来的子进程认这个新进程为弟弟
    }
    
    // 父进程的 cptr 始终指向最新的子进程
    proc->parent->cptr = proc; 
    
    // 进程总数加一
    nr_process++;
}

/*
 * remove_links - 移除进程的家族关系链接
 * * [功能]:
 * 当进程彻底退出 (被父进程回收) 时调用。
 */
static void
remove_links(struct proc_struct *proc)
{
    // 从全局进程链表移除
    list_del(&(proc->list_link));
    
    // 维护兄弟链表：如果我有哥哥 (optr)，让哥哥的弟弟指向我的弟弟
    if (proc->optr != NULL)
    {
        proc->optr->yptr = proc->yptr;
    }
    
    // 维护兄弟链表：如果我有弟弟 (yptr)，让弟弟的哥哥指向我的哥哥
    if (proc->yptr != NULL)
    {
        proc->yptr->optr = proc->optr;
    }
    else
    {
        // 如果我没有弟弟 (yptr == NULL)，说明我是父进程最年轻的儿子 (parent->cptr 指向我)
        // 既然我要走了，父进程的最年轻儿子就变成了我的哥哥 (optr)
        proc->parent->cptr = proc->optr;
    }
    
    // 进程总数减一
    nr_process--;
}

// get_pid - 分配一个唯一的 PID
// 算法：使用简单的线性搜索 + 标记法来寻找下一个可用的 PID
static int
get_pid(void)
{
    // 确保 PID 最大值大于最大进程数，否则 PID 肯定不够用
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    
    // last_pid 记录上次分配的 PID，next_safe 记录一段连续可用区间的末尾
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    
    // 尝试直接使用 last_pid + 1
    if (++last_pid >= MAX_PID)
    {
        last_pid = 1;
        goto inside; // 如果溢出，重新开始搜索
    }
    
    // 如果超过了安全区间，需要重新扫描链表寻找新的可用区间
    if (last_pid >= next_safe)
    {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        // 遍历所有现有进程
        while ((le = list_next(le)) != list)
        {
            proc = le2proc(le, list_link);
            // 如果 last_pid 已经被占用
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
                    goto repeat; // 重新搜索
                }
            }
            // 如果找到一个比 last_pid 大的 PID，说明 [last_pid, proc->pid) 之间可能有空隙
            else if (proc->pid > last_pid && next_safe > proc->pid)
            {
                next_safe = proc->pid; // 更新安全区间的上界
            }
        }
    }
    return last_pid;
}


// 上下文切换机制：展示 proc_run 如何切换页表 (SATP) 和 CPU 寄存器 (switch_to)
/*
 * proc_run - 进程切换的具体执行者
 * * [参数]: proc - 即将获得 CPU 的新进程
 */
void proc_run(struct proc_struct *proc)
{
    // 只有当目标进程不是当前进程时才进行切换
    if (proc != current)
    {
        // LAB4:EXERCISE3 2313547 2312220
        bool intr_flag;
        struct proc_struct *prev_proc = current;
        
        // [1] 关中断
        // 保证切换过程原子性，避免在切换中间被中断打断导致状态不一致
        local_intr_save(intr_flag);
        {
            // [2] 更新 current 指针
            current = proc;
            
            // [3] 切换页表
            // lsatp 指令写入 SATP 寄存器，切换虚拟地址空间，并刷新 TLB
            // 内核线程使用内核页表，用户进程使用自己的页表
            lsatp(proc->pgdir); 
            
            // [4] 上下文切换
            // 调用汇编函数 switch_to 保存 prev_proc 的寄存器，加载 proc 的寄存器
            // 这是一个“神奇”的调用：调用时是 prev_proc，返回时已经是 proc (如果 proc 之前也调用过 switch_to)
            switch_to(&(prev_proc->context), &(proc->context));
        }
        // [5] 开中断
        // 注意：这行代码是在 switch_to 返回后执行的。
        // 意味着此时已经是 proc 进程在运行，且 proc 之前在让出 CPU 时保存的 intr_flag 被恢复。
        local_intr_restore(intr_flag);
    }
}

// forkret - 新进程的第一个内核入口
// 当 switch_to 切换到一个新 fork 的进程时，context.ra 指向这里。
static void
forkret(void)
{
    // forkrets 位于 trapentry.S
    // 它将 tf (trapframe) 中的寄存器值恢复到 CPU，最后执行 sret 返回用户态/内核态
    forkrets(current->tf);
}

// hash_proc - 将进程加入 PID 哈希表
static void
hash_proc(struct proc_struct *proc)
{
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

// unhash_proc - 从 PID 哈希表中移除进程
static void
unhash_proc(struct proc_struct *proc)
{
    list_del(&(proc->hash_link));
}

// find_proc - 根据 PID 查找 PCB
struct proc_struct *
find_proc(int pid)
{
    if (0 < pid && pid < MAX_PID)
    {
        // 计算哈希桶索引
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        // 遍历哈希桶
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

/*
 * kernel_thread - 创建内核线程
 * * [原理]: 伪造一个 trapframe，假装线程是从内核态“陷入”的。
 */
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags)
{
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    
    // 设置寄存器，传递参数
    tf.gpr.s0 = (uintptr_t)fn;  // s0 存放函数指针 (kernel_thread_entry 会调用它)
    tf.gpr.s1 = (uintptr_t)arg; // s1 存放函数参数
    
    // 设置状态寄存器
    // SSTATUS_SPP = 1: Previous Privilege 是 Supervisor (内核态)
    // SSTATUS_SPIE = 1: Previous Interrupt Enable 是开启的
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
    
    // 设置入口地址
    // kernel_thread_entry 是汇编跳板，负责 call s0(s1)
    tf.epc = (uintptr_t)kernel_thread_entry;
    
    // CLONE_VM: 表示共享虚拟内存 (内核线程共享内核地址空间)
    // 调用 do_fork 创建进程
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}

// setup_kstack - 分配内核栈
// 每个进程/线程都需要一个内核栈 (通常 2页 = 8KB)，用于中断处理和内核函数调用。
static int
setup_kstack(struct proc_struct *proc)
{
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL)
    {
        // 获取物理页对应的内核虚拟地址
        proc->kstack = (uintptr_t)page2kva(page);
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

// setup_pgdir - 分配并初始化页目录表 (PDT)
static int
setup_pgdir(struct mm_struct *mm)
{
    struct Page *page = NULL;
    if ((page = alloc_page()) == NULL)
    {
        return -E_NO_MEM;
    }
    // 获取页目录表的虚拟地址
    pde_t *pgdir = page2kva(page);
    
    // [关键]: 复制内核页表 (boot_pgdir)
    // 所有进程的页表中，高地址部分必须映射内核空间，这样陷入内核时才能正常运行
    memcpy(pgdir, boot_pgdir_va, PGSIZE);

    mm->pgdir = pgdir;
    return 0;
}

// put_pgdir - 释放页目录表
static void
put_pgdir(struct mm_struct *mm)
{
    free_page(kva2page(mm->pgdir));
}

/*
 * copy_mm - 进程内存空间复制/共享
 * * [功能]:
 * 根据 clone_flags 决定是共享内存 (线程) 还是复制内存 (进程 Fork)。
 */
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc)
{
    struct mm_struct *mm, *oldmm = current->mm;

    /* 如果当前是内核线程 (mm == NULL)，无需复制用户空间 */
    if (oldmm == NULL)
    {
        return 0;
    }
    /* 如果是创建线程 (CLONE_VM)，直接共享 mm 指针 */
    if (clone_flags & CLONE_VM)
    {
        mm = oldmm;
        goto good_mm;
    }
    
    int ret = -E_NO_MEM;
    /* 创建新的 mm_struct */
    if ((mm = mm_create()) == NULL)
    {
        goto bad_mm;
    }
    /* 分配新的页目录表 */
    if (setup_pgdir(mm) != 0)
    {
        goto bad_pgdir_cleanup_mm;
    }
    
    /* 锁定旧内存，防止并发修改 */
    lock_mm(oldmm);
    {
        // [核心复制]: 调用 dup_mmap 复制 vma 和页表
        // 在 Lab 5 Challenge 中，这里 dup_mmap 内部会调用 copy_range
        // copy_range 会根据 share=1 启用 Copy-on-Write 机制 (只读映射+引用计数)
        ret = dup_mmap(mm, oldmm);
    }
    unlock_mm(oldmm);

    if (ret != 0)
    {
        goto bad_dup_cleanup_mmap;
    }

good_mm:
    // 增加 mm 的引用计数
    mm_count_inc(mm);
    proc->mm = mm;
    proc->pgdir = PADDR(mm->pgdir); // 设置 proc->pgdir 为物理地址 (用于 SATP)
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    return ret;
}

/*
 * copy_thread - 设置新进程的 TrapFrame 和内核栈布局
 * * [功能]: 构造新进程在第一次被调度执行时的“初始状态”。
 */
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf)
{
    // 在内核栈顶部分配空间给 trapframe
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
    // 复制父进程的 trapframe (寄存器状态快照)
    *(proc->tf) = *tf;

    // Set a0 to 0 so a child process knows it's just forked
    // 设置返回值 a0 为 0，这是子进程区分自己身份的关键
    proc->tf->gpr.a0 = 0;
    
    // 如果 esp 不为 0，说明是用户态 fork，sp 设为用户栈；
    // 如果 esp 为 0 (kernel_thread)，sp 指向内核栈的 trapframe (模拟从内核 trap)。
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;

    // 设置 switch_to 的返回地址：新进程第一次被调度时跳转到 forkret
    proc->context.ra = (uintptr_t)forkret;
    // 设置 switch_to 的栈指针：指向刚才构造的 trapframe
    proc->context.sp = (uintptr_t)(proc->tf);
}

// 
// Fork 系统调用流程图：alloc_proc -> setup_kstack -> copy_mm -> copy_thread -> hash_proc -> wakeup_proc

/*
 * do_fork - 创建新进程的主函数
 * * [功能]: 它是 fork(), clone(), kernel_thread() 的后端实现。
 础版 (Deep Copy)：

do_fork 调用 copy_mm -> dup_mmap -> copy_range。

copy_range 的作用是遍历父进程的页表，找到每一页，申请一个新的物理页，
然后调用 memcpy 把父进程的内容完全拷贝给子进程，最后建立映射。

核心：多了物理内存的申请 (alloc_page) 和 内容的拷贝 (memcpy)。

COW 版 (Challenge)：

copy_range 不再申请新内存，也不 memcpy。

它做的事情是：

找到父进程的 PTE。

取消写权限（PTE_W 置 0），标记为只读。

将子进程的 PTE 指向同一个物理页。

增加引用计数 (page_ref_inc)。

刷新 TLB。
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    // 检查是否超过最大进程数
    if (nr_process >= MAX_PROCESS)
    {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    
    // [1] 分配 PCB
    if ((proc = alloc_proc()) == NULL) {
        goto fork_out;
    }

    // 设置子进程的父进程为当前进程
    proc->parent = current;
    
    // 确保当前进程的 wait_state 为 0 (健壮性检查)
    assert(current->wait_state == 0);

    // [2] 分配内核栈
    if (setup_kstack(proc) != 0) {
        goto bad_fork_cleanup_proc;
    }

    // [3] 复制内存管理结构 (Copy-on-Write 触发点)
    // 如果是线程则共享，如果是进程则复制页表(COW)
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }

    // [4] 设置中断帧和上下文 (Context & TrapFrame)
    copy_thread(proc, stack, tf);

    // [5] 插入链表 (需要关中断保护)
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid(); // 获取唯一的 PID
        hash_proc(proc);       // 建立 hash 映射 (PID -> PCB)
        set_links(proc);       // 设置进程链接 (加入 proc_list, 维护父子兄弟链表)
    }
    local_intr_restore(intr_flag);

    // [6] 唤醒新进程 (将状态置为 PROC_RUNNABLE，加入调度队列)
    wakeup_proc(proc); 

    // [7] 返回新进程的 PID (父进程看到的返回值)
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}

/*
 * do_exit - 进程退出函数
 * * [功能]: 释放进程的大部分资源，通知父进程，自己变成僵尸进程 (ZOMBIE)。
 
当一个进程死掉时，它不能让它的子进程变成“孤儿”。

逻辑：

遍历当前进程 (current) 的子进程链表 (cptr)。

将所有子进程的 parent 指针修改为 initproc (1号进程)。

将这些子进程插入到 initproc 的子进程链表中（更新 cptr, yptr, optr）。

检查僵尸：如果被过继的子进程已经是 ZOMBIE 状态，需要向 initproc 发送唤醒信号 (wakeup_proc)，让 initproc 来回收它们。
 */
int do_exit(int error_code)
{
    // idleproc 和 initproc 不允许退出
    if (current == idleproc)
    {
        panic("idleproc exit.\n");
    }
    if (current == initproc)
    {
        panic("initproc exit.\n");
    }
    
    // [1] 释放内存空间 (mm_struct)
    struct mm_struct *mm = current->mm;
    if (mm != NULL)
    {
        // 必须切回内核页表，因为当前进程的页表即将被释放
        lsatp(boot_pgdir_pa); 
        // 引用计数减一，如果归零则彻底销毁 mm
        if (mm_count_dec(mm) == 0)
        {
            exit_mmap(mm);  // 释放 VMA 和映射
            put_pgdir(mm);  // 释放页目录表
            mm_destroy(mm); // 释放 mm 结构体
        }
        current->mm = NULL;
    }
    
    // [2] 设置状态为僵尸
    current->state = PROC_ZOMBIE;
    current->exit_code = error_code; // 保存退出码
    
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        // [3] 唤醒父进程
        proc = current->parent;
        // 如果父进程正在等待子进程 (WT_CHILD)，唤醒它
        if (proc->wait_state == WT_CHILD)
        {
            wakeup_proc(proc);
        }
        
        // [4] 处理子进程 (托孤给 initproc)
        // 遍历当前进程的所有子进程
        while (current->cptr != NULL)
        {
            proc = current->cptr;
            current->cptr = proc->optr; // 从当前子进程链表移除

            proc->yptr = NULL;
            // 将子进程插入 initproc 的子进程链表头部
            if ((proc->optr = initproc->cptr) != NULL)
            {
                initproc->cptr->yptr = proc;
            }
            proc->parent = initproc; // 认贼作父 (划掉) 认 initproc 为父
            initproc->cptr = proc;
            
            // 如果被过继的子进程已经是僵尸，需要通知新父亲(initproc)来回收它
            if (proc->state == PROC_ZOMBIE)
            {
                if (initproc->wait_state == WT_CHILD)
                {
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    
    // [5] 调度其他进程
    // 因为当前进程已经变成了 ZOMBIE，schedule 不会再调度它
    schedule();
    panic("do_exit will not return!! %d.\n", current->pid);
}

// 
// 进程虚拟地址空间布局：展示 load_icode 如何加载 Text, Data, BSS 以及建立 User Stack

/*
 * load_icode - 加载并解析一个处于内存中的ELF执行文件格式的应用程序
 * * [功能]: 这是 execve 的核心实现。加载程序并设置 TrapFrame。
 * * [调用流程]: kernel_execve -> load_icode
 * * [核心工作]:
 * 1. 创建新的内存管理结构 (mm)
 * 2. 创建页目录表 (pgdir)
 * 3. 解析 ELF 文件头，遍历 Program Headers
 * 4. 根据 ELF 段信息建立 VMA (虚拟内存区域)，分配物理内存并拷贝代码/数据
 * 5. 处理 BSS 段 (清零)
 * 6. 建立用户栈 (User Stack)
 * 7. 设置当前进程的 mm 和 cr3 (切换页表)
 * 8. 设置 TrapFrame (中断帧)，使得中断返回 (sret) 时能正确跳转到程序入口
 */
static int
load_icode(unsigned char *binary, size_t size)
{
    // execve 会先销毁旧的 mm，所以这里必须为 NULL
    if (current->mm != NULL)
    {
        panic("load_icode: current->mm must be empty.\n");
    }

    int ret = -E_NO_MEM;
    struct mm_struct *mm;
    // (1) 创建新的内存管理结构 mm_struct
    // 用于管理进程的虚拟内存空间 (VMA list 等)
    if ((mm = mm_create()) == NULL)
    {
        goto bad_mm;
    }
    // (2) 创建并初始化新的页目录表 (Page Directory)
    // 分配一页作为页目录，并映射内核空间的 2GB (0xC0000000以上)
    if (setup_pgdir(mm) != 0)
    {
        goto bad_pgdir_cleanup_mm;
    }
    
    // (3) 解析 ELF 并加载段
    struct Page *page = NULL;
    // binary 指向内存中 ELF 文件的起始地址
    struct elfhdr *elf = (struct elfhdr *)binary;
    // 获取 Program Header Table 的起始位置
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    
    // 检查 ELF 魔数，确保文件格式正确
    if (elf->e_magic != ELF_MAGIC)
    {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
    // 遍历所有 Program Header (程序段头)
    for (; ph < ph_end; ph++)
    {
        // 只加载 LOAD 类型的段 (代码段、数据段等需要加载到内存的段)
        if (ph->p_type != ELF_PT_LOAD)
        {
            continue;
        }
        // 检查文件大小是否超过了内存大小 (文件截断错误)
        if (ph->p_filesz > ph->p_memsz)
        {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0)
        {
            // 如果文件大小为0，可能是纯 BSS 段或者空段，继续处理以分配内存但不拷贝
            // continue ;
        }
        
        // (3.5) 设置 VMA 权限 (根据 ELF 段的 R/W/X 标志)
        // 初始化权限：用户态可访问 (PTE_U) | 有效 (PTE_V)
        vm_flags = 0, perm = PTE_U | PTE_V; 
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;  // 可执行
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE; // 可写
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;  // 可读
        
        // 设置页表项 (PTE) 的硬件权限位
        // 注意：RISC-V 中写权限通常隐含读权限，但在 uCore 中明确设置
        if (vm_flags & VM_READ) perm |= PTE_R;
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
        if (vm_flags & VM_EXEC) perm |= PTE_X;
        
        // 建立 VMA 映射 (虚拟地址区间记录)
        // 将 [ph->p_va, ph->p_va + ph->p_memsz] 这一段虚拟地址标记为合法
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
        {
            goto bad_cleanup_mmap;
        }
        
        // (3.6) 拷贝数据
        // 将 ELF 文件中的内容复制到分配的物理页中
        // 注意：Lab 5 这里是 Deep Copy，直接从 binary 指针处 memcpy 到新分配的页
        unsigned char *from = binary + ph->p_offset;
        size_t off, size;
        // start: 段的虚拟起始地址
        // la: 向下对齐到页边界的地址 (Linear Address)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);

        ret = -E_NO_MEM;
        end = ph->p_va + ph->p_filesz; // 拷贝数据的结束地址 (不包含 BSS)
        
        // 复制文件内容 (Text/Data 段)
        while (start < end)
        {
            // 为虚拟地址 la 分配物理页，如果不存在则分配并建立映射
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
            {
                goto bad_cleanup_mmap;
            }
            // 计算页内偏移 off 和本页需要拷贝的大小 size
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la)
            {
                size -= la - end; // 如果这是最后一页且未填满，调整 size
            }
            // 内存拷贝：从 ELF 数据源复制到新分配的物理页对应的内核虚拟地址
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }

        // (3.6.2) 处理 BSS 段 (初始化为 0)
        // memsz > filesz 的部分就是 BSS (未初始化数据段)，需要手动清零
        end = ph->p_va + ph->p_memsz; // 整个段的结束地址 (包含 BSS)
        
        // 如果之前那个页 (加载数据的最后一页) 还没填满，接着填 0
        if (start < la)
        {
            if (start == end)
            {
                continue;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la)
            {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        
        // 如果 BSS 跨越了多个新页，需要分配新页并全页清零
        while (start < end)
        {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
            {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la)
            {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    
    // (4) 建立用户栈
    // 栈有读写权限，且标记为 VM_STACK
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    // 建立栈的 VMA 记录: [USTACKTOP - USTACKSIZE, USTACKTOP]
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
    {
        goto bad_cleanup_mmap;
    }
    // 预分配 4 页的栈空间，并映射到用户态，避免访问栈时频繁触发 Page Fault
    // 注意：PTE_USER 宏包含了 PTE_U | PTE_R | PTE_W | PTE_V
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);

    // (5) 设置新进程的 mm 和页表基址
    mm_count_inc(mm); // 增加引用计数
    current->mm = mm;
    current->pgdir = PADDR(mm->pgdir); // 记录页目录物理地址
    lsatp(PADDR(mm->pgdir)); // 切换页表 (写入 satp 寄存器)，从此开始使用新空间

    // (6) 设置 TrapFrame
    // 这是让进程返回用户态的关键步骤，也是 Lab 5 练习 1 的核心
    struct trapframe *tf = current->tf;
    uintptr_t sstatus = tf->status; // 保存旧的状态
    // 清空 trapframe，防止残留数据影响
    memset(tf, 0, sizeof(struct trapframe));
    
    // LAB5:EXERCISE1 YOUR CODE 2312220
    /* 设置 TrapFrame 以便 sret 返回到用户态 */
    
    // 1. 设置 sp (Stack Pointer)
    // 用户程序从用户栈顶开始执行，USTACKTOP 是定义好的用户栈顶地址
    tf->gpr.sp = USTACKTOP;
    
    // 2. 设置 epc (Exception Program Counter)
    // 这是 sret 返回后 CPU 跳转执行的地址。
    // 对于 ELF 程序，这是 main 函数的入口地址 (e_entry)。
    tf->epc = elf->e_entry;
    
    // 3. 设置 status (SSTATUS 寄存器)
    // 这里的目的是为了欺骗 CPU，让它以为我们是从用户态陷入内核的，
    // 这样执行 sret 时，CPU 就会“返回”到用户态。
    //
    // - read_csr(sstatus): 读取当前的 sstatus 值
    // - & ~SSTATUS_SPP: 清除 SPP (Supervisor Previous Privilege) 位。
    //   SPP=1 表示之前是 S 态，SPP=0 表示之前是 U 态。
    //   我们将其置 0，表示返回后进入 U-Mode。
    // - | SSTATUS_SPIE: 设置 SPIE (Supervisor Previous Interrupt Enable) 位。
    //   确保回到用户态后，中断是开启的 (IE=1)，否则操作系统将失去控制权。
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
    
    ret = 0;
out:
    return ret;
bad_cleanup_mmap:
    exit_mmap(mm);
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
}

/*
 * do_execve - 执行新程序
 * * [功能]: 回收当前进程的内存空间，加载新程序。
 */
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size)
{
    struct mm_struct *mm = current->mm;
    // 检查 name 指针是否合法
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
    {
        return -E_INVAL;
    }
    if (len > PROC_NAME_LEN)
    {
        len = PROC_NAME_LEN;
    }

    // 复制进程名到内核栈 (因为原用户空间即将被销毁)
    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
    memcpy(local_name, name, len);

    // 清理旧内存
    if (mm != NULL)
    {
        cputs("mm != NULL");
        lsatp(boot_pgdir_pa); // 切回内核页表，因为当前页表即将销毁
        if (mm_count_dec(mm) == 0)
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
    }
    
    // 加载新程序
    int ret;
    if ((ret = load_icode(binary, size)) != 0)
    {
        goto execve_exit;
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret); // 加载失败，直接退出
    panic("already exit: %e.\n", ret);
}

// do_yield - 主动让出 CPU
int do_yield(void)
{
    current->need_resched = 1; // 标记需要调度，trap 返回时会处理
    return 0;
}

/*
 * do_wait - 等待子进程退出
 * * [功能]: 父进程调用此函数等待子进程变为 ZOMBIE，并回收其 PCB 和内核栈。
 */
int do_wait(int pid, int *code_store)
{
    struct mm_struct *mm = current->mm;
    // 检查 code_store 内存合法性
    if (code_store != NULL)
    {
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
        {
            return -E_INVAL;
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    // 查找目标子进程 (特定 PID 或任意子进程)
    if (pid != 0)
    {
        proc = find_proc(pid);
        if (proc != NULL && proc->parent == current)
        {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE)
            {
                goto found; // 找到僵尸子进程
            }
        }
    }
    else
    {
        // 遍历所有子进程
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr)
        {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE)
            {
                goto found; // 找到僵尸子进程
            }
        }
    }
    
    // 如果有子进程但都没死，自己进入睡眠
    if (haskid)
    {
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD; // 等待子进程状态
        schedule(); // 让出 CPU
        // 被唤醒后检查是否被 kill
        if (current->flags & PF_EXITING)
        {
            do_exit(-E_KILLED);
        }
        goto repeat; // 醒来后再次检查
    }
    return -E_BAD_PROC; // 没有符合条件的子进程

found:
    if (proc == idleproc || proc == initproc)
    {
        panic("wait idleproc or initproc.\n");
    }
    // 保存退出码
    if (code_store != NULL)
    {
        *code_store = proc->exit_code;
    }
    
    // 回收 PCB 资源
    local_intr_save(intr_flag);
    {
        unhash_proc(proc);   // 从哈希表移除
        remove_links(proc);  // 从进程链表移除
    }
    local_intr_restore(intr_flag);
    put_kstack(proc); // 释放内核栈
    kfree(proc);      // 释放 PCB 内存
    return 0;
}

// do_kill - 杀死进程 (设置 PF_EXITING 标志)
int do_kill(int pid)
{
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL)
    {
        if (!(proc->flags & PF_EXITING))
        {
            proc->flags |= PF_EXITING; // 设置正在退出标志
            // 如果进程在等待，唤醒它，让它在 trap 返回检查时发现 PF_EXITING 并自杀
            if (proc->wait_state & WT_INTERRUPTED)
            {
                wakeup_proc(proc);
            }
            return 0;
        }
        return -E_KILLED;
    }
    return -E_INVAL;
}

/*
 * kernel_execve - 内核态执行 exec 的 Hack 实现
 * * [技巧]: 使用 ebreak 指令触发断点异常，模拟系统调用。
 */
static int
kernel_execve(const char *name, unsigned char *binary, size_t size)
{
    int64_t ret = 0, len = strlen(name);
    //   ret = do_execve(name, len, binary, size);
    asm volatile(
        "li a0, %1\n"
        "lw a1, %2\n"
        "lw a2, %3\n"
        "lw a3, %4\n"
        "lw a4, %5\n"
        "li a7, 10\n"   // Magic number 10: 告诉 trap handler 这是 kernel_execve
        "ebreak\n"      // 触发断点异常，进入 trap 处理流程
        "sw a0, %0\n"
        : "=m"(ret)
        : "i"(SYS_exec), "m"(name), "m"(len), "m"(binary), "m"(size)
        : "memory");
    cprintf("ret = %d\n", ret);
    return ret;
}

// 宏定义：用于辅助调用 kernel_execve
#define __KERNEL_EXECVE(name, binary, size) ({           \
    cprintf("kernel_execve: pid = %d, name = \"%s\".\n", \
            current->pid, name);                         \
    kernel_execve(name, binary, (size_t)(size));         \
})

// 宏定义：获取链接在内核中的二进制文件符号
#define KERNEL_EXECVE(x) ({                                    \
    extern unsigned char _binary_obj___user_##x##_out_start[], \
        _binary_obj___user_##x##_out_size[];                   \
    __KERNEL_EXECVE(#x, _binary_obj___user_##x##_out_start,    \
                    _binary_obj___user_##x##_out_size);        \
})

#define __KERNEL_EXECVE2(x, xstart, xsize) ({   \
    extern unsigned char xstart[], xsize[];     \
    __KERNEL_EXECVE(#x, xstart, (size_t)xsize); \
})

#define KERNEL_EXECVE2(x, xstart, xsize) __KERNEL_EXECVE2(x, xstart, xsize)

/*
 * user_main - 用户主线程 (Kernel Thread)
 * * [功能]: 这是 initproc 创建的第一个子进程。调用 kernel_execve 加载第一个真正的用户程序。
 */
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    //KERNEL_EXECVE(spin);
    //KERNEL_EXECVE(cow_mem);
    //KERNEL_EXECVE(cow_data);
    //KERNEL_EXECVE(cow_stress);
    
    // [Challenge]: 运行 Dirty COW 测试程序
    KERNEL_EXECVE(dirty_cow_test); 
#endif
    panic("user_main execve failed.\n");
}

/*
 * init_main - Init 进程的主体函数 (PID = 1)
 * * [功能]: 这是系统的第一个内核线程，负责启动用户环境。
 * * [职责]: 
 * 1. 创建 user_main 内核线程（后续加载用户程序）。
 * 2. 作为“孤儿院”回收所有僵尸进程。
 * 3. 检查系统内存状态，确保无泄漏。
 */
static int
init_main(void *arg)
{
    // 记录初始时的空闲页数和内核已分配内存大小
    // 用于在所有子进程退出后对比，检查是否有内存泄漏
    size_t nr_free_pages_store = nr_free_pages();
    size_t kernel_allocated_store = kallocated();

    // 创建 user_main 内核线程
    // 注意：user_main 稍后会通过 kernel_execve 加载用户程序，从而“变身”为用户进程
    int pid = kernel_thread(user_main, NULL, 0);
    if (pid <= 0)
    {
        panic("create user_main failed.\n");
    }

    // 等待所有子进程结束
    // 逻辑说明：
    // 1. do_wait(0, NULL) 表示等待任意子进程退出。
    // 2. 如果返回 0，表示成功回收了一个僵尸子进程，循环继续。
    // 3. 如果返回非 0 (通常是 -E_BAD_PROC)，表示当前没有子进程了，循环结束。
    // 4. 由于 uCore 中所有孤儿进程（父进程先结束的进程）都会被过继给 initproc，
    //    因此这个循环实际上是在等待整个用户态环境运行结束。
    while (do_wait(0, NULL) == 0)
    {
        // 如果当前没有僵尸进程可回收，但还有子进程在运行，
        // 则让出 CPU (schedule) 等待下次调度
        schedule();
    }

    cprintf("all user-mode processes have quit.\n");
    
    // 验证系统状态：
    // 1. initproc 不应该还有任何子进程 (cptr)、弟弟 (yptr) 或 哥哥 (optr)
    // 2. 系统中应该只剩下两个进程：idleproc (PID 0) 和 initproc (PID 1)
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
    assert(nr_process == 2);
    // 3. 检查进程链表 proc_list 是否只包含 initproc (idleproc 通常不挂在链表上或作为链表头处理)
    assert(list_next(&proc_list) == &(initproc->list_link));
    assert(list_prev(&proc_list) == &(initproc->list_link));

    cprintf("init check memory pass.\n");
    return 0;
}

// proc_init - 进程子系统初始化
// * [功能]: 在内核启动阶段被调用，初始化进程管理所需的数据结构，并创建 idleproc 和 initproc
void proc_init(void)
{
    int i;

    // 初始化进程链表 (proc_list)
    list_init(&proc_list);
    // 初始化进程哈希表 (hash_list)，用于通过 PID 快速查找进程
    for (i = 0; i < HASH_LIST_SIZE; i++)
    {
        list_init(hash_list + i);
    }

    // [1] 创建 idleproc (0号进程)
    // idleproc 是一个特殊的内核线程，用于在 CPU 无事可做时运行
    if ((idleproc = alloc_proc()) == NULL)
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0; // 0号进程
    idleproc->state = PROC_RUNNABLE; // 永远是就绪的，随时可以运行
    idleproc->kstack = (uintptr_t)bootstack; // idle 使用启动时的栈 (entry.S 中定义的 bootstack)
    idleproc->need_resched = 1; // 标记需要调度，以便尽快让出 CPU 给 initproc
    set_proc_name(idleproc, "idle");
    nr_process++;

    // 设置当前运行进程为 idleproc
    current = idleproc;

    // [2] 创建 initproc (1号进程，运行 init_main)
    // kernel_thread 会创建一个新的内核线程，并将其加入调度队列
    int pid = kernel_thread(init_main, NULL, 0);
    if (pid <= 0)
    {
        panic("create init_main failed.\n");
    }

    // 通过 PID 找到刚刚创建的进程控制块 (PCB)
    initproc = find_proc(pid);
    set_proc_name(initproc, "init");

    // 最后的校验，确保 0号和 1号进程创建成功
    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}

// cpu_idle - 空闲循环 (PID = 0 的代码实体)
// * [功能]: 当调度器没有其他 RUNNABLE 进程可选时，会选择 idleproc 运行此函数
void cpu_idle(void)
{
    while (1)
    {
        // 这是一个死循环，idle 进程永远不会退出
        
        // 检查是否需要重新调度 (need_resched)
        // 通常在时钟中断处理程序中，会设置当前进程的 need_resched 标志
        if (current->need_resched)
        {
            schedule(); // 让出 CPU，尝试切换到其他进程
        }
        
        // 注意：在实际的 OS 中，这里通常会放入低功耗指令 (如 x86 的 hlt，RISC-V 的 wfi)
        // 以便在没有任务时降低 CPU 功耗。
    }
}