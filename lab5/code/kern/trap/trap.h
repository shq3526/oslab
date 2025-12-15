#ifndef __KERN_TRAP_TRAP_H__
#define __KERN_TRAP_TRAP_H__

#include <defs.h>

/* *
 * struct pushregs - 保存通用寄存器 (General Purpose Registers, GPRs)
 * * [RISC-V 架构背景]
 * RISC-V 拥有 32 个通用整数寄存器 x0 - x31。
 * 当发生中断或异常时，为了保证 CPU 能在处理完事件后恢复之前的执行流，
 * 我们必须把这 32 个寄存器的值保存到内存（通常是内核栈）中。
 * * 这个结构体的布局必须与 kern/trap/trapentry.S 中的 SAVE_ALL 宏
 * 推栈 (push) 的顺序严格一致，否则会导致寄存器值恢复错乱。
 */
struct pushregs
{
    uintptr_t zero; // [x0] 硬连线为0 (Hard-wired zero)，写入无效，读取总为0
    uintptr_t ra;   // [x1] 返回地址 (Return address)，函数调用时保存返回点
    uintptr_t sp;   // [x2] 栈指针 (Stack pointer)，指向当前栈顶
    uintptr_t gp;   // [x3] 全局指针 (Global pointer)，用于访问全局数据
    uintptr_t tp;   // [x4] 线程指针 (Thread pointer)，用于线程局部存储 (TLS)
    uintptr_t t0;   // [x5] 临时寄存器 (Temporary)，调用者保存
    uintptr_t t1;   // [x6] 临时寄存器
    uintptr_t t2;   // [x7] 临时寄存器
    uintptr_t s0;   // [x8] 保存寄存器/帧指针 (Frame pointer)，被调用者保存
    uintptr_t s1;   // [x9] 保存寄存器
    uintptr_t a0;   // [x10] 函数参数/返回值 (Argument/Return value)
    uintptr_t a1;   // [x11] 函数参数/返回值
    uintptr_t a2;   // [x12] 函数参数
    uintptr_t a3;   // [x13] 函数参数
    uintptr_t a4;   // [x14] 函数参数
    uintptr_t a5;   // [x15] 函数参数
    uintptr_t a6;   // [x16] 函数参数
    uintptr_t a7;   // [x17] 函数参数 (在系统调用中用于存放 syscall number)
    uintptr_t s2;   // [x18] 保存寄存器
    uintptr_t s3;   // [x19] 保存寄存器
    uintptr_t s4;   // [x20] 保存寄存器
    uintptr_t s5;   // [x21] 保存寄存器
    uintptr_t s6;   // [x22] 保存寄存器
    uintptr_t s7;   // [x23] 保存寄存器
    uintptr_t s8;   // [x24] 保存寄存器
    uintptr_t s9;   // [x25] 保存寄存器
    uintptr_t s10;  // [x26] 保存寄存器
    uintptr_t s11;  // [x27] 保存寄存器
    uintptr_t t3;   // [x28] 临时寄存器
    uintptr_t t4;   // [x29] 临时寄存器
    uintptr_t t5;   // [x30] 临时寄存器
    uintptr_t t6;   // [x31] 临时寄存器
};

/* *
 * struct trapframe - 中断帧
 * * [核心概念]
 * 这是一个进程或线程在 "那一瞬间" 的完整快照。
 * 它不仅包含所有的通用寄存器 (pushregs)，还包含了发生异常时的
 * 关键控制状态寄存器 (CSRs)。
 * * 在 Lab 5 中：
 * 1. do_fork: 会复制父进程的 trapframe 给子进程，实现状态克隆。
 * 2. load_icode: 会伪造一个 trapframe，设置 sp=用户栈, epc=程序入口，
 * 从而让内核通过 sret 指令 "返回" 到一个新的用户程序开始执行。
 */
struct trapframe
{
    struct pushregs gpr; // 通用寄存器组 (x0-x31)
    
    // [Control Status Registers (CSRs)]
    // 以下寄存器在 trapentry.S 中通过 csrr 指令读取并保存到栈上

    uintptr_t status;    // [sstatus] Supervisor Status Register
                         // 包含中断使能位 (SIE/SPIE) 和特权级信息 (SPP)。
                         // 这里的 SPP 位决定了 sret 后 CPU 是回到用户态(0)还是内核态(1)。

    uintptr_t epc;       // [sepc] Supervisor Exception Program Counter
                         // 记录了发生异常/中断的那条指令的地址。
                         // 如果是系统调用 (ecall)，返回时通常需要 epc += 4。

    uintptr_t tval;      // [stval] Supervisor Trap Value
                         // 记录异常相关的附加信息。
                         // 例如在 Page Fault 时，这里存放的是导致错误的虚拟地址。

    uintptr_t cause;     // [scause] Supervisor Cause Register
                         // 记录异常发生的原因（是一个中断？还是异常？具体是哪种？）。
                         // 最高位为 1 表示中断 (Interrupt)，为 0 表示异常 (Exception)。
};

/* * 陷阱处理函数入口
 * 在 trapentry.S 保存完上下文后调用此函数。
 */
void trap(struct trapframe *tf);

/* * 初始化中断描述符表 (IDT)
 * 实际上在 RISC-V 中是设置 stvec (trap handler base address)。
 */
void idt_init(void);

/* * 打印中断帧信息
 * 用于调试，dump 出当前所有的寄存器状态。
 */
void print_trapframe(struct trapframe *tf);

/* * 打印通用寄存器信息
 */
void print_regs(struct pushregs *gpr);

/* * 判断异常是否发生在内核态
 * 通过检查 trapframe->status 中的 SPP 位来实现。
 */
bool trap_in_kernel(struct trapframe *tf);

#endif /* !__KERN_TRAP_TRAP_H__ */