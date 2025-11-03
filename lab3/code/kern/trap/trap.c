#include <assert.h>  // 包含断言宏
#include <clock.h>   // 包含时钟驱动头文件
#include <console.h> // 包含控制台驱动头文件
#include <defs.h>    // 包含基本定义
#include <kdebug.h>  // 包含内核调试相关头文件
#include <memlayout.h> // 包含内存布局定义
#include <mmu.h>     // 包含MMU（内存管理单元）相关定义
#include <riscv.h>   // 包含RISC-V特定定义（如CSR读写宏）
#include <stdio.h>   // 包含标准输入输出（cprintf等）
#include <trap.h>    // 包含陷阱（Trap）处理头文件
#include <sbi.h>     // 包含SBI（Supervisor Binary Interface）调用头文件

#define TICK_NUM 100 // 定义每100次时钟中断打印一次信息

/*
 * rv_next_step - (RISC-V Next Step)
 * 辅助函数，用于判断 RISC-V 指令的长度（用于异常处理后跳过异常指令）。
 * RISC-V 支持标准 32 位指令和 16 位压缩指令 (RVC)。
 * C 扩展指令的低两位（inst[1:0]）不为 0b11。
 * 32 位指令的低两位（inst[1:0]）必须为 0b11。
 * epc: 发生异常的指令地址 (Exception Program Counter)
 * 返回值: 指令的字节长度 (2 或 4)
 */
static inline uintptr_t rv_next_step(uintptr_t epc) {
    // 将 epc 强制转换为一个 16 位无符号短整型指针，并解引用
    unsigned short half = *(unsigned short *)epc;
    // 检查低两位是否为 0b11
    return ((half & 0x3) != 0x3) ? 2 : 4;
}

// 每次时钟中断计数器达到 TICK_NUM (100) 时调用的打印函数
static void print_ticks() {
    cprintf("%d ticks\n", TICK_NUM);
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}

// 静态全局变量，用于累计 "100 ticks" 信息的打印次数
static int print_num = 0;

/*
 * idt_init - 初始化中断描述符表（IDT）
 * [!] 注意：函数名 idt_init 和注释中的 IDT, SETGATE, lidt 都是 x86 架构的术语。
 * 在 RISC-V 架构下，这个函数的功能是初始化 S 模式的陷阱（Trap）处理。
 */
void idt_init(void) {
    /* LAB3 YOUR CODE : 2312220 */
    /* * 以下是 x86 的注释（保留，供参考）
     * (1) 每一个中断服务程序（ISR）的入口地址在哪里？
     * 所有 ISR 的入口地址都存储在 __vectors 中。 uintptr_t __vectors[] 在哪里？
     * __vectors[] 位于 kern/trap/vector.S 文件中，该文件由 tools/vector.c 生成。
     * （在 lab3 中尝试 "make" 命令，你会在 kern/trap 目录下找到 vector.S）
     * 你可以使用 "extern uintptr_t __vectors[];" 来定义这个稍后会用到的外部变量。
     * (2) 现在你应在中断描述符表（IDT）中设置 ISR 的条目。
     * 你能在这个文件中看到 idt[256] 吗？是的，它就是 IDT！你可以使用 SETGATE 宏来设置 IDT 的每一个条目。
     * (3) 设置好 IDT 的内容后，你需要使用 'lidt' 指令来告诉 CPU IDT 在哪里。
     * 你不知道这条指令的含义吗？Google 一下！并查看 libs/x86.h 来了解更多。
     * 注意：'lidt' 的参数是 idt_pd。试着找到它！
     */
         
    /*
     * 以下是 RISC-V 的实际初始化代码
     */

    // 声明在 trapentry.S 中定义的汇编入口点
    extern void __alltraps(void);
    
    /* * 设置 sscratch 寄存器为 0。
     * sscratch 是一个 S 模式 CSR，用于在 U/S 态切换时临时保存栈指针。
     * 在 ucore 的设计中，sscratch 为 0 表示当前在 S 模式（内核态）执行。
     * 当从 U 模式陷入时，__alltraps 会用 sscratch 保存的内核栈顶替换 sp。
     */
    write_csr(sscratch, 0);

    /* * 设置 stvec (Supervisor Trap Vector Base Address) 寄存器。
     * 这是 S 模式最重要的陷阱控制寄存器之一。
     * 它指向所有 S 模式中断和异常的唯一入口点。
     * 这里将其设置为汇编函数 __alltraps 的地址。
     */
    write_csr(stvec, &__alltraps);
}

/* * trap_in_kernel - 检查陷阱（Trap）是否发生在内核态（S 模式）
 * tf: 指向保存了 CPU 状态的陷阱帧（Trapframe）
 * * sstatus 寄存器中的 SPP (Supervisor Previous Privilege) 位
 * 记录了发生陷阱 *之前* 的特权级。
 * SSTATUS_SPP (1 << 8):
 * - 值为 1 (S_MODE) 表示陷阱发生在 S 模式
 * - 值为 0 (U_MODE) 表示陷阱发生在 U 模式
 */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
}

// 打印陷阱帧（Trapframe）的详细信息，用于调试
void print_trapframe(struct trapframe *tf) {
    cprintf("trapframe at %p\n", tf);
    print_regs(&tf->gpr); // 打印所有通用寄存器
    cprintf("   status   0x%08x\n", tf->status); // 打印 sstatus 寄存器 (S 模式状态)
    cprintf("   epc      0x%08x\n", tf->epc);    // 打印 sepc (S 模式异常程序计数器，即发生陷阱的指令地址)
    cprintf("   badvaddr 0x%08x\n", tf->badvaddr); // 打印 stval (S 模式陷阱值，通常是出错的地址或指令)
    cprintf("   cause    0x%08x\n", tf->cause);   // 打印 scause (S 模式陷阱原因)
}

// 打印通用寄存器组（gpr）的内容，用于调试
void print_regs(struct pushregs *gpr) {
    cprintf("   zero     0x%08x\n", gpr->zero); // x0 (硬编码为 0)
    cprintf("   ra       0x%08x\n", gpr->ra);   // x1 (返回地址, Return Address)
    cprintf("   sp       0x%08x\n", gpr->sp);   // x2 (栈指针, Stack Pointer)
    cprintf("   gp       0x%08x\n", gpr->gp);   // x3 (全局指针, Global Pointer)
    cprintf("   tp       0x%08x\n", gpr->tp);   // x4 (线程指针, Thread Pointer)
    cprintf("   t0       0x%08x\n", gpr->t0);   // x5 (临时寄存器 0, Temporary)
    cprintf("   t1       0x%08x\n", gpr->t1);   // x6 (临时寄存器 1)
    cprintf("   t2       0x%08x\n", gpr->t2);   // x7 (临时寄存器 2)
    cprintf("   s0       0x%08x\n", gpr->s0);   // x8 (保存寄存器 0 / 帧指针, Frame Pointer)
    cprintf("   s1       0x%08x\n", gpr->s1);   // x9 (保存寄存器 1, Saved Register)
    cprintf("   a0       0x%08x\n", gpr->a0);   // x10 (参数/返回值 0, Argument/Return Value)
    cprintf("   a1       0x%08x\n", gpr->a1);   // x11 (参数/返回值 1)
    cprintf("   a2       0x%08x\n", gpr->a2);   // x12 (参数 2)
    cprintf("   a3       0x%08x\n", gpr->a3);   // x13 (参数 3)
    cprintf("   a4       0x%08x\n", gpr->a4);   // x14 (参数 4)
    cprintf("   a5       0x%08x\n", gpr->a5);   // x15 (参数 5)
    cprintf("   a6       0x%08x\n", gpr->a6);   // x16 (参数 6)
    cprintf("   a7       0x%08x\n", gpr->a7);   // x17 (参数 7)
    cprintf("   s2       0x%08x\n", gpr->s2);   // x18 (保存寄存器 2)
    cprintf("   s3       0x%08x\n", gpr->s3);   // x19 (保存寄存器 3)
    cprintf("   s4       0x%08x\n", gpr->s4);   // x20 (保存寄存器 4)
    cprintf("   s5       0x%08x\n", gpr->s5);   // x21 (保存寄存器 5)
    cprintf("   s6       0x%08x\n", gpr->s6);   // x22 (保存寄存器 6)
    cprintf("   s7       0x%08x\n", gpr->s7);   // x23 (保存寄存器 7)
    cprintf("   s8       0x%08x\n", gpr->s8);   // x24 (保存寄存器 8)
    cprintf("   s9       0x%08x\n", gpr->s9);   // x25 (保存寄存器 9)
    cprintf("   s10      0x%08x\n", gpr->s10);  // x26 (保存寄存器 10)
    cprintf("   s11      0x%08x\n", gpr->s11);  // x27 (保存寄存器 11)
    cprintf("   t3       0x%08x\n", gpr->t3);   // x28 (临时寄存器 3)
    cprintf("   t4       0x%08x\n", gpr->t4);   // x29 (临时寄存器 4)
    cprintf("   t5       0x%08x\n", gpr->t5);   // x30 (临时寄存器 5)
    cprintf("   t6       0x%08x\n", gpr->t6);   // x31 (临时寄存器 6)
}

/*
 * interrupt_handler - 中断处理函数
 * 当 trap_dispatch 确定这是一个中断（而不是异常）时调用此函数
 */
void interrupt_handler(struct trapframe *tf) {
    // scause 寄存器的最高位是中断标志（1=中断, 0=异常）
    // (tf->cause << 1) >> 1 用于清除最高位，得到纯粹的中断原因码
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
        case IRQ_U_SOFT: // U 模式软件中断
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_SOFT: // S 模式软件中断
            cprintf("Supervisor software interrupt\n");
            break;
        case IRQ_H_SOFT: // H 模式软件中断
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT: // M 模式软件中断
            cprintf("Machine software interrupt\n");
            break;
        case IRQ_U_TIMER: // U 模式时钟中断
            cprintf("User Timer interrupt\n");
            break;
        case IRQ_S_TIMER: // S 模式时钟中断 (Lab3 练习 1 在此处理)
            // "sip 寄存器中除了 SSIP 和 USIP 之外的所有位都是只读的。" -- privileged spec1.9.1, 4.1.4, p59
            // 实际上，调用 sbi_set_timer 会清除 STIP（S 模式时钟中断挂起位），或者你也可以直接清除它。
            // cprintf("Supervisor timer interrupt\n");

            /* LAB3 EXERCISE1   YOUR CODE : 2312220 */
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
             * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
             */

            // (1) 设置下次时钟中断 (必须, 否则时钟中断只会触发一次)
            clock_set_next_event();

            // (2) 计数器（ticks）加一 (ticks 在 clock.c 中定义, clock.h 提供了声明)
            ticks++;

            // (3) 检查是否达到 TICK_NUM (100)
            if (ticks % TICK_NUM == 0) {
                // 输出 "100 ticks"
                print_ticks();
                
                // 打印次数（num）加一
                print_num++;

                // (4) 判断打印次数是否达到 10 次
                if (print_num == 10) {
                    // 关机 (通过 SBI 调用 M 模式固件来关闭系统)
                    sbi_shutdown();
                }
            }
            break; // 结束 S 模式时钟中断处理
        case IRQ_H_TIMER: // H 模式时钟中断
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_TIMER: // M 模式时钟中断
            cprintf("Machine software interrupt\n");
            break;
        case IRQ_U_EXT: // U 模式外部中断
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT: // S 模式外部中断 (例如来自 PLIC 的设备中断)
            cprintf("Supervisor external interrupt\n");
            break;
        case IRQ_H_EXT: // H 模式外部中断
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_EXT: // M 模式外部中断
            cprintf("Machine software interrupt\n");
            break;
        default: // 未知的中断类型
            print_trapframe(tf);
            break;
    }
}

/*
 * exception_handler - 异常处理函数
 * 当 trap_dispatch 确定这是一个异常（而不是中断）时调用此函数
 */
void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
        case CAUSE_MISALIGNED_FETCH: // 指令地址未对齐
            break;
        case CAUSE_FAULT_FETCH: // 指令访问故障（例如页表不存在或权限不足）
            break;
        case CAUSE_ILLEGAL_INSTRUCTION: // 非法指令 (Lab3 Challenge 3 在此处理)
            // 非法指令异常处理
            /* LAB3 CHALLENGE3   YOUR CODE :  2313547*/
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
             */
            cprintf("Exception type: Illegal instruction\n");
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc); // 打印发生异常的地址
            // 更新 tf->epc，使其指向下一条指令
            // 这样 sret 返回时就不会再次执行这条非法指令，避免了死循环
            // rv_next_step 会自动判断指令是 2 字节还是 4 字节长
            tf->epc += rv_next_step(tf->epc);
            break;
        case CAUSE_BREAKPOINT: // 断点异常 (由 ebreak 指令触发, Lab3 Challenge 3 在此处理)
            //断点异常处理
            /* LAB3 CHALLLENGE3   YOUR CODE :  2313547*/
            /*(1)输出指令异常类型（ breakpoint）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
             */
            cprintf("Exception type: breakpoint\n");
            cprintf("ebreak caught at 0x%08x\n", tf->epc); // 打印 ebreak 指令的地址
            // 同样，更新 tf->epc 以跳过 ebreak 指令
            tf->epc += rv_next_step(tf->epc);
            break;
        case CAUSE_MISALIGNED_LOAD: // Load 地址未对齐
            break;
        case CAUSE_FAULT_LOAD: // Load 访问故障（例如缺页）
            break;
        case CAUSE_MISALIGNED_STORE: // Store 地址未对齐
            break;
        case CAUSE_FAULT_STORE: // Store 访问故障（例如缺页）
            break;
        case CAUSE_USER_ECALL: // U 模式的 ecall (系统调用)
            break;
        case CAUSE_SUPERVISOR_ECALL: // S 模式的 ecall (例如向 M 模式请求服务)
            break;
        case CAUSE_HYPERVISOR_ECALL: // H 模式的 ecall
            break;
        case CAUSE_MACHINE_ECALL: // M 模式的 ecall
            break;
        default: // 未知的异常类型
            print_trapframe(tf);
            break;
    }
}

/*
 * trap_dispatch - 陷阱分发函数
 * 这是 C 语言中处理陷阱的第二级入口
 */
static inline void trap_dispatch(struct trapframe *tf) {
    // 检查 scause 寄存器的最高位（中断位）
    // (intptr_t)tf->cause < 0 表示最高位为 1，即这是一个中断
    if ((intptr_t)tf->cause < 0) {
        // interrupts
        interrupt_handler(tf); // 转到中断处理器
    } else {
        // exceptions
        exception_handler(tf); // 转到异常处理器
    }
}

/* *
 * trap - C 语言陷阱处理总入口
 * 当 trapentry.S 中的 __alltraps 汇编代码保存好上下文后，会调用此函数
 *
 * trap - 处理或分发一个异常/中断。当 trap() 返回时，
 * kern/trap/trapentry.S 中的代码会恢复 trapframe 中保存的旧 CPU 状态，
 * 然后使用 sret 指令从异常中返回。
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    // 根据发生的陷阱类型进行分发
    trap_dispatch(tf);
}


/*
 * test_breakpoint - 用于测试断点异常 (Challenge 3)
 * __attribute__((noinline)) 确保编译器不会将此函数内联，
 * 从而保证 ebreak 指令在一个独立的函数栈帧中执行。
 */
__attribute__((noinline)) void test_breakpoint(void) {
    cprintf("\n=== [TEST] breakpoint begin ===\n");
    // 嵌入汇编，执行 ebreak 指令，这将立即触发一个断点异常
    asm volatile("ebreak");
    // 如果 exception_handler 正确处理了异常并更新了 epc,
    // sret 后将返回到这里继续执行。
    cprintf("[TEST] breakpoint returned\n");
}

/*
 * test_illegal - 用于测试非法指令异常 (Challenge 3)
 */
__attribute__((noinline)) void test_illegal(void) {
    cprintf("\n=== [TEST] illegal begin (32-bit) ===\n");
    // 嵌入汇编，
    // .align 2 确保指令是 4 字节对齐的
    // .word 0xFFFFFFFF 插入一个 32 位的字，
    // 0xFFFFFFFF 在 RISC-V 中是一个保证非法的指令编码
    asm volatile(".align 2\n\t"
                 ".word 0xFFFFFFFF\n\t");
    // sret 后将返回到这里
    cprintf("[TEST] illegal 32-bit returned\n");

    cprintf("\n=== [TEST] illegal begin (16-bit) ===\n");
    // .2byte 0x0000 插入一个 16 位的字，
    // 0x0000 (C.ILLEGAL) 是 RVC 中的非法指令编码
    asm volatile(".2byte 0x0000\n\t");
    // sret 后将返回到这里
    cprintf("[TEST] illegal 16-bit returned\n");
}
