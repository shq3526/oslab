#include <defs.h>
#include <mmu.h>
#include <memlayout.h>
#include <clock.h>
#include <trap.h>
#include <riscv.h>
#include <stdio.h>
#include <assert.h>
#include <console.h>
#include <vmm.h>
#include <kdebug.h>
#include <unistd.h>
#include <syscall.h>
#include <error.h>
#include <sched.h>
#include <sync.h>
#include <sbi.h>

#define TICK_NUM 100

static void print_ticks()
{
    cprintf("%d ticks\n", TICK_NUM);
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}

/* * idt_init - 初始化中断描述符表 (IDT) / 中断向量表
 * 这个函数在内核启动时被调用 (init.c)，用于配置 CPU 如何处理中断和异常。
 */
void idt_init(void)
{
    extern void __alltraps(void);
    
    /* * [RISC-V 硬件细节] 设置 sscratch 寄存器
     * sscratch 用于在陷阱发生时区分我们是从“用户态”进来的，还是从“内核态”进来的。
     * - 设置为 0：表示当前已经在内核态执行。
     * - 在 trapentry.S 中，会检查 sscratch：
     * - 如果是 0，说明发生中断前已经在内核，不需要切换栈。
     * - 如果非 0，说明发生中断前在用户态，sscratch 里存的是内核栈地址，需要交换 sp 切换到内核栈。
     */
    write_csr(sscratch, 0);
    
    /* * [中断入口] 设置 stvec (Supervisor Trap Vector Base Address)
     * 将中断向量表的基地址设置为 __alltraps (定义在 trapentry.S)。
     * 当任何中断或异常发生时，CPU 会自动跳转到 __alltraps 处的汇编代码开始执行。
     * __alltraps 负责保存所有寄存器 (Context Save) 并调用 trap() 函数。
     */
    write_csr(stvec, &__alltraps);
    
    /* * [内存权限] 设置 sstatus 寄存器
     * SSTATUS_SUM (Supervisor User Memory access):
     * 允许内核模式下的代码直接读取/写入用户模式的内存页。
     * 这在系统调用处理（如 sys_write）中读取用户传入的字符串参数时是必须的。
     */
    set_csr(sstatus, SSTATUS_SUM);
}

/* * trap_in_kernel - 判断陷阱是否发生在内核态
 * 根据 sstatus 寄存器的 SPP (Supervisor Previous Privilege) 位来判断。
 * SPP = 1: 之前的特权级是 Supervisor (内核态)
 * SPP = 0: 之前的特权级是 User (用户态)
 */
bool trap_in_kernel(struct trapframe *tf)
{
    return (tf->status & SSTATUS_SPP) != 0;
}

void print_trapframe(struct trapframe *tf)
{
    cprintf("trapframe at %p\n", tf);
    // cprintf("trapframe at 0x%x\n", tf);
    print_regs(&tf->gpr);
    cprintf("  status   0x%08x\n", tf->status);
    cprintf("  epc      0x%08x\n", tf->epc);
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
    cprintf("  ra       0x%08x\n", gpr->ra);
    cprintf("  sp       0x%08x\n", gpr->sp);
    cprintf("  gp       0x%08x\n", gpr->gp);
    cprintf("  tp       0x%08x\n", gpr->tp);
    cprintf("  t0       0x%08x\n", gpr->t0);
    cprintf("  t1       0x%08x\n", gpr->t1);
    cprintf("  t2       0x%08x\n", gpr->t2);
    cprintf("  s0       0x%08x\n", gpr->s0);
    cprintf("  s1       0x%08x\n", gpr->s1);
    cprintf("  a0       0x%08x\n", gpr->a0);
    cprintf("  a1       0x%08x\n", gpr->a1);
    cprintf("  a2       0x%08x\n", gpr->a2);
    cprintf("  a3       0x%08x\n", gpr->a3);
    cprintf("  a4       0x%08x\n", gpr->a4);
    cprintf("  a5       0x%08x\n", gpr->a5);
    cprintf("  a6       0x%08x\n", gpr->a6);
    cprintf("  a7       0x%08x\n", gpr->a7);
    cprintf("  s2       0x%08x\n", gpr->s2);
    cprintf("  s3       0x%08x\n", gpr->s3);
    cprintf("  s4       0x%08x\n", gpr->s4);
    cprintf("  s5       0x%08x\n", gpr->s5);
    cprintf("  s6       0x%08x\n", gpr->s6);
    cprintf("  s7       0x%08x\n", gpr->s7);
    cprintf("  s8       0x%08x\n", gpr->s8);
    cprintf("  s9       0x%08x\n", gpr->s9);
    cprintf("  s10      0x%08x\n", gpr->s10);
    cprintf("  s11      0x%08x\n", gpr->s11);
    cprintf("  t3       0x%08x\n", gpr->t3);
    cprintf("  t4       0x%08x\n", gpr->t4);
    cprintf("  t5       0x%08x\n", gpr->t5);
    cprintf("  t6       0x%08x\n", gpr->t6);
}

extern struct mm_struct *check_mm_struct;

/* * interrupt_handler - 中断处理函数
 * 处理所有的外部中断（Interrupts），如时钟中断、设备中断。
 * 这里的核心逻辑对应实验报告中的【时间片轮转调度 (RR)】实现。
 */
void interrupt_handler(struct trapframe *tf)
{
    // cause 最高位为1表示中断，去掉最高位得到具体的中断号
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause)
    {
    case IRQ_U_SOFT:
        cprintf("User software interrupt\n");
        break;
    case IRQ_S_SOFT:
        cprintf("Supervisor software interrupt\n");
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
        break;
        
    /* * [Lab 5 调度核心] 用户态时钟中断 (IRQ_U_TIMER)
     * 当 CPU 处于用户态执行程序时，时间到了触发此中断。
     */
    case IRQ_U_TIMER:
        // (1) 通过 OpenSBI 接口设置下一次时钟中断的时间点，维持系统心跳
        clock_set_next_event();

        // (2) 增加系统全局 tick 计数器，用于统计时间和系统运行状态
        ticks++;

        // (3) [进程调度逻辑] 时间片消耗
        // 如果当前有进程在运行，扣除其剩余的时间片 (time_slice)。
        // 这对应 sched.c 中的 Round-Robin 逻辑。
        if (current != NULL) {
            if (current->time_slice > 0) {
                current->time_slice--;
            }
            
            // 如果时间片用尽 (0)，设置 need_resched 标志。
            // 注意：这里只设置标志，不直接调用 schedule()。
            // 真正的 schedule() 调用发生在 trap() 函数即将返回用户态之前。
            // 这样做保证了中断处理的原子性和栈的整洁。
            if (current->time_slice == 0) {
                current->need_resched = 1;
            }
        }
        break;
        
    /* * [Lab 5 调度核心] 内核态时钟中断 (IRQ_S_TIMER)
     * 即使 CPU 正在内核态忙碌（例如处理系统调用），也需要响应时钟中断来扣除时间片。
     * 这防止了内核态程序死循环导致整个系统卡死，增强了系统的抢占性。
     */
    case IRQ_S_TIMER:
        // "All bits besides SSIP and USIP in the sip register are
        // read-only." -- privileged spec1.9.1, 4.1.4, p59
        // In fact, Call sbi_set_timer will clear STIP, or you can clear it
        // directly.
        // cprintf("Supervisor timer interrupt\n");
        /* LAB5 GRADE   YOUR CODE :  2312220*/
        /* 时间片轮转： 
        *(1) 设置下一次时钟中断（clock_set_next_event）
        *(2) ticks 计数器自增
        *(3) 每 TICK_NUM 次中断（如 100 次），进行判断当前是否有进程正在运行，
        如果有则标记该进程需要被重新调度（current->need_resched）
        */
        
        // (1) 设置下次时钟中断 (保持心跳)
        clock_set_next_event();

        // (2) 计数器（ticks）加一 (更新系统时间)
        ticks++;

        // (3) [进程调度逻辑] 检查时间片是否耗尽
        // 逻辑与 IRQ_U_TIMER 相同，确保无论处于何种特权级，时间片统计都是准确的。
        if (current != NULL) {
            if (current->time_slice > 0) {
                current->time_slice--;
            }
            
            // 当时间片耗尽时，标记需要调度
            if (current->time_slice <= 0) {
                current->need_resched = 1;
            }
        }
        break;
    case IRQ_H_TIMER:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_TIMER:
        cprintf("Machine software interrupt\n");
        break;
    case IRQ_U_EXT:
        cprintf("User software interrupt\n");
        break;
    case IRQ_S_EXT:
        cprintf("Supervisor external interrupt\n");
        break;
    case IRQ_H_EXT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_EXT:
        cprintf("Machine software interrupt\n");
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);

/* * exception_handler - 异常处理函数
 * 处理所有的同步异常（Exceptions），如系统调用、缺页异常、非法指令等。
 * 这里的逻辑包含了 Lab5 的两大核心功能：
 * 1. 系统调用分发 (System Call Dispatch)
 * 2. 缺页异常处理 (Page Fault Handling for COW)
 */
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
    {
    case CAUSE_MISALIGNED_FETCH:
        cprintf("Instruction address misaligned\n");
        break;
    case CAUSE_FETCH_ACCESS:
        cprintf("Instruction access fault\n");
        break;
    case CAUSE_ILLEGAL_INSTRUCTION:
        cprintf("Illegal instruction\n");
        break;
        
    /* * [Lab 5 初始化 Hack] 断点异常 (Breakpoint)
     * 这是一个特殊的逻辑，用于内核线程 (initproc) 启动第一个用户进程 (kernel_execve)。
     * 因为我们无法在内核态直接使用 ecall 来模仿用户态系统调用，
     * 所以使用了 ebreak 指令配合寄存器 a7=10 作为暗号。
     */
    case CAUSE_BREAKPOINT:
        cprintf("Breakpoint\n");
        if (tf->gpr.a7 == 10) // 检查是否是特定的 kernel_execve 调用
        {
            tf->epc += 4; // 跳过 ebreak 指令，否则返回后会死循环执行 ebreak
            syscall();    // 执行真正的系统调用逻辑 (sys_exec)
            
            // 这是一个极其特殊的返回函数，它不会正常返回。
            // 它会利用构造好的内核栈，伪造一个用户态的现场，直接 sret 到用户程序的入口。
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
        }
        break;
    case CAUSE_MISALIGNED_LOAD:
        cprintf("Load address misaligned\n");
        break;
    case CAUSE_LOAD_ACCESS:
        cprintf("Load access fault\n");
        break;
    case CAUSE_MISALIGNED_STORE:
        panic("AMO address misaligned\n");
        break;
    case CAUSE_STORE_ACCESS:
        cprintf("Store/AMO access fault\n");
        break;
        
    /* * [Lab 5 系统调用] 用户态系统调用 (User Ecall)
     * 当用户程序执行 `ecall` 指令时触发此异常。
     */
    case CAUSE_USER_ECALL:
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4; // 重要：sepc 指向发生异常的指令 (ecall)。
                      // 我们希望处理完后返回到 ecall 的下一条指令继续执行，所以 PC+4。
        syscall();    // 查表调用 sys_fork, sys_exit, sys_write 等
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_HYPERVISOR_ECALL:
        cprintf("Environment call from H-mode\n");
        break;
    case CAUSE_MACHINE_ECALL:
        cprintf("Environment call from M-mode\n");
        break;
        
    /* * [Lab 5 COW 核心机制] 缺页异常处理
     * 在 Lab 5 之前，缺页通常意味着程序错误 (Segfault)。
     * 在 Lab 5 中，缺页可能意味着：
     * 1. 栈空间增长 (Demand Paging)。
     * 2. 写时复制 (Copy-on-Write) 触发。
     */
    case CAUSE_FETCH_PAGE_FAULT:
        cprintf("Instruction page fault\n");
        // 调用 do_pgfault，这是实现 COW 的关键入口。
        // do_pgfault 会检查异常地址是否在 VMA 中，并判断是否是 COW 写的只读页。
        if (do_pgfault(current->mm, tf->cause, tf->tval) != 0) {
            print_trapframe(tf); // 如果处理失败（真是非法访问），则打印帧并杀进程
            if (current == NULL) {
                panic("handle_exception: page fault in kernel (current == NULL)");
            }
            do_exit(-E_KILLED);
        }
        break;

    case CAUSE_LOAD_PAGE_FAULT:
        cprintf("Load page fault\n");
        // 调用 do_pgfault 处理读缺页（通常是 Demand Paging 刚分配页表项时）
        if (do_pgfault(current->mm, tf->cause, tf->tval) != 0) {
            print_trapframe(tf);
            if (current == NULL) {
                panic("handle_exception: page fault in kernel (current == NULL)");
            }
            do_exit(-E_KILLED);
        }
        break;

    /* * [COW 触发点] 写缺页异常 (Store Page Fault)
     * 当进程尝试写入一个被标记为“只读”但 VMA 标记为“可写”的页面时触发。
     * 这正是 fork() 后父子进程共享物理页的情况。
     */
    case CAUSE_STORE_PAGE_FAULT:
        cprintf("Store/AMO page fault\n");
        // 调用 do_pgfault。
        // 如果是 COW，do_pgfault 会：
        // 1. 分配新物理页 2. 拷贝内容 3. 修改页表权限为可写 4. 刷新 TLB
        if (do_pgfault(current->mm, tf->cause, tf->tval) != 0) {
            print_trapframe(tf);
            if (current == NULL) {
                panic("handle_exception: page fault in kernel (current == NULL)");
            }
            do_exit(-E_KILLED);
        }
        break;
    default:
        print_trapframe(tf);
        break;
    }
}

static inline void trap_dispatch(struct trapframe *tf)
{
    if ((intptr_t)tf->cause < 0)
    {
        // interrupts (最高位为1)
        interrupt_handler(tf);
    }
    else
    {
        // exceptions (最高位为0)
        exception_handler(tf);
    }
}

/* *
 * trap - 通用陷阱处理入口
 * 所有的异常和中断最终都会走到这里。
 * 这里负责处理“嵌套陷阱”的逻辑，并决定何时进行进程调度。
 * */
/* 请替换 kern/trap/trap.c 末尾的 trap 函数 */
void trap(struct trapframe *tf) {
    // 1. 如果当前没有进程（如 OS 启动早期的中断），直接处理，不涉及进程调度
    if (current == NULL) {
        trap_dispatch(tf);
    }
    else {
        // 2. 保存旧的中断帧 (Nested Trap Support)
        // 这里的逻辑允许在处理中断时再次发生中断（虽然 uCore 简单实现中较少涉及复杂嵌套）
        // 实际上，current->tf 始终指向当前正在处理的 trapframe，便于 copy_thread 等函数获取上下文。
        struct trapframe *otf = current->tf;
        current->tf = tf;

        // 【关键逻辑】判断中断来源
        // 检查 SSTATUS_SPP 位：
        // 0 -> 用户态 (User Mode)，in_kernel = false
        // 1 -> 内核态 (Supervisor Mode)，in_kernel = true
        bool in_kernel = (tf->status & SSTATUS_SPP) != 0;

        // 3. 分发处理 (Dispatch)
        trap_dispatch(tf);

        // 4. 恢复旧的中断帧
        current->tf = otf;

        // 5. 进程调度决策点 (Scheduling Decision)
        // 只有当满足以下条件时，才触发调度：
        // (1) 中断来自用户态 (!in_kernel)。如果内核代码执行中被打断，通常不立即抢占，保证内核原子性。
        // (2) 调度器标记了需要调度 (need_resched == 1)，这通常是在 interrupt_handler 中时间片耗尽设置的。
        if (!in_kernel) {
            // 检查当前进程是否被标记为正在退出 (PF_EXITING)
            // 如果是，直接结束它，不再让它回用户态。
            if (current->flags & PF_EXITING) {
                do_exit(-E_KILLED);
            }
            
            // 【核心】时间片轮转调度的触发点
            // 如果时间片用完 (need_resched 被置位)，现在可以安全地挂起当前进程，
            // 切换到下一个 RUNNABLE 进程。
            if (current->need_resched) {
                schedule();
            }
        }
    }
}