#include <riscv.h>

.text
/*
 * switch_to - 上下文切换核心函数
 * * 函数原型: void switch_to(struct proc_struct* from, struct proc_struct* to)
 * * 参数:
 * a0: from (指向当前进程 proc_struct 的指针)
 * 注意: 虽然 C 语言声明是 proc_struct*，但实际上我们只需要访问其成员 context。
 * 在 proc_struct 定义中，context 是第 8 个成员 (前面有 state, pid, runs, kstack, need_resched, parent, mm)。
 * 但在 ucore 的实现中，switch_to 接收的其实是 **context 结构体的指针**！
 * * 让我们回顾 proc.c 中的调用:
 * switch_to(&(prev->context), &(proc->context));
 * * 因此:
 * a0 = &prev->context (保存旧进程状态的目标地址)
 * a1 = &proc->context (加载新进程状态的源地址)
 * * 核心原理:
 * RISC-V 调用约定 (Calling Convention) 将寄存器分为两类：
 * 1. Caller-Saved (调用者保存): ra, t0-t6, a0-a7。函数调用后这些值可能改变，编译器会自动处理。
 * 2. Callee-Saved (被调用者保存): sp, s0-s11。函数调用前后这些值必须保持不变。
 * * switch_to 本质上是一个函数调用。我们只需要保存 Callee-Saved 寄存器。
 * 当进程被切回来时，switch_to 返回，编译器生成的后续代码会以为“什么都没发生”，
 * 继续使用 s0-s11 中的值。
 * * ra (Return Address) 是个例外，它虽然通常由 caller 保存，但在这里我们需要保存它，
 * 以便 switch_to 返回时能跳回正确的地方 (通常是 forkret 或者 上次 switch_to 调用的下一条指令)。
 */
.globl switch_to
switch_to:
    
    /* --- 1. 保存当前进程 (from) 的上下文 --- */
    
    /* 保存返回地址 ra (x1) */
    /* 当进程再次被调度时，CPU 将跳转到这个地址继续执行 */
    STORE ra, 0*REGBYTES(a0)
    
    /* 保存栈指针 sp (x2) */
    /* 这是最重要的寄存器之一，恢复 sp 意味着切换到了新进程的内核栈 */
    STORE sp, 1*REGBYTES(a0)
    
    /* 保存被调用者保存寄存器 s0-s11 */
    /* s0 (x8) / Frame Pointer */
    STORE s0, 2*REGBYTES(a0)
    /* s1 (x9) */
    STORE s1, 3*REGBYTES(a0)
    /* s2 (x18) - s11 (x27) */
    STORE s2, 4*REGBYTES(a0)
    STORE s3, 5*REGBYTES(a0)
    STORE s4, 6*REGBYTES(a0)
    STORE s5, 7*REGBYTES(a0)
    STORE s6, 8*REGBYTES(a0)
    STORE s7, 9*REGBYTES(a0)
    STORE s8, 10*REGBYTES(a0)
    STORE s9, 11*REGBYTES(a0)
    STORE s10, 12*REGBYTES(a0)
    STORE s11, 13*REGBYTES(a0)

    /* --- 2. 恢复目标进程 (to) 的上下文 --- */
    
    /* 从 to->context 加载寄存器值 */
    
    /* 恢复 ra: switch_to 返回后跳转的地址 */
    /* 如果是新进程，这里通常是 forkret 的地址 */
    LOAD ra, 0*REGBYTES(a1)
    
    /* 恢复 sp: 切换到新进程的内核栈！ */
    /* 从这一刻起，任何栈操作 (如压栈、弹栈) 都在新进程的栈上进行了 */
    LOAD sp, 1*REGBYTES(a1)
    
    /* 恢复 s0-s11 */
    LOAD s0, 2*REGBYTES(a1)
    LOAD s1, 3*REGBYTES(a1)
    LOAD s2, 4*REGBYTES(a1)
    LOAD s3, 5*REGBYTES(a1)
    LOAD s4, 6*REGBYTES(a1)
    LOAD s5, 7*REGBYTES(a1)
    LOAD s6, 8*REGBYTES(a1)
    LOAD s7, 9*REGBYTES(a1)
    LOAD s8, 10*REGBYTES(a1)
    LOAD s9, 11*REGBYTES(a1)
    LOAD s10, 12*REGBYTES(a1)
    LOAD s11, 13*REGBYTES(a1)

    /* --- 3. 切换完成 --- */
    
    /* 返回 */
    /* 这里的 ret 指令实际上是 jalr x0, 0(ra) */
    /* 因为 ra 已经被恢复为目标进程的 ra，所以这跳指令会跳转到目标进程的代码中继续执行 */
    ret