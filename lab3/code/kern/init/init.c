#include <clock.h>   // 包含时钟驱动头文件
#include <console.h> // 包含控制台驱动头文件
#include <defs.h>    // 包含基本定义
#include <intr.h>    // 包含中断使能/禁用的接口
#include <kdebug.h>  // 包含内核调试相关头文件
#include <kmonitor.h> // 包含内核监视器（monitor）头文件
#include <pmm.h>     // 包含物理内存管理（PMM）头文件
#include <stdio.h>   // 包含标准输入输出（cprintf等）
#include <string.h>  // 包含字符串处理（memset等）
#include <trap.h>    // 包含中断陷阱（Trap）处理头文件
#include <dtb.h>     // 包含设备树（DTB）处理头文件

// 声明内核初始化函数 kern_init，属性((noreturn))告诉编译器这个函数不会返回
int kern_init(void) __attribute__((noreturn));
// 声明用于调试的栈回溯函数
void grade_backtrace(void);


// kern_init 是 ucore 内核的 C 语言入口点（在 entry.S 之后被调用）
int kern_init(void) {
    // extern 关键字告诉编译器 edata 和 end 符号是在其他地方定义的（链接脚本 kernel.ld）
    // edata 是.data段（已初始化数据）的结束地址
    // end 是.bss段（未初始化数据）的结束地址
    extern char edata[], end[];

    // 清理 BSS 段：将 .data 段末尾到 .bss 段末尾的内存区域全部清零
    // 这是 C 语言标准要求的，确保所有未初始化的全局/静态变量默认为 0
    memset(edata, 0, end - edata);

    // [!] 注意：dtb_init() 在 memset 之后调用。
    // OpenSBI 将 DTB 地址传递给内核，内核需要解析它以获取硬件信息（如内存布局）
    // 实验指导中提到，这个函数用于读取并保存 DTB 的内存信息。
    dtb_init();

    cons_init(); // 初始化控制台（console），之后 cprintf 才能工作

    const char *message = "(THU.CST) os is loading ...\0";
    cputs(message); // 向控制台输出启动信息

    print_kerninfo(); // 打印内核信息（如内核占用的内存范围）

    // grade_backtrace(); // 用于调试栈回溯的函数调用（已注释）

    // idt_init (Interrupt Descriptor Table) 是 x86 的叫法
    // 在 RISC-V 中，这个函数（trap.c 中的 idt_init）实际上是初始化中断向量表
    // 主要是设置 stvec 寄存器，使其指向汇编入口 __alltraps
    idt_init();

    // 初始化物理内存管理器（PMM）
    // pmm_init 会调用 pmm_manager->init() 和 pmm_manager->init_memmap()
    // 来设置物理内存的空闲页链表（基于 dtb_init 获取的内存范围）
    pmm_init();

    // 再次调用 idt_init() [?] 备注：这里调用了两次，可能是遗留代码，但无害
    idt_init(); 
    
    // [!] 调用两个测试函数（在 trap.c 中实现），用于触发 Challenge 3 的异常处理
    test_breakpoint(); // 触发断点异常
    test_illegal();    // 触发非法指令异常

    // 初始化时钟中断（clock.c）
    // 1. 设置 sie 寄存器，使能 S 模式的时钟中断
    // 2. 调用 clock_set_next_event() 设置 *第一次* 时钟中断
    clock_init();
    
    // 使能中断（intr.c）
    // 设置 sstatus 寄存器的 SIE 位（Supervisor Interrupt Enable），
    // 允许 CPU 响 S 模式的中断请求
    intr_enable();

    /* do nothing */
    // 内核初始化完成，进入一个死循环
    // 此时 OS 变为由中断驱动，等待时钟中断或其他中断的发生
    while (1)
        ;
}
// 内核初始化函数kern_init()的执行流：(从kern/init/entry.S进入) -> 
// 输出一些信息说明正在初始化 -> 
// 设置中断向量表(stvec)跳转到的地方为kern/trap/trapentry.S里的一个标记 ->
// 在kern/driver/clock.c设置第一个时钟事件，使能时钟中断->
// 设置全局的S mode中断使能位-> 现在开始不断地触发时钟中断

// 产生一次时钟中断的执行流：
// set_sbi_timer()通过OpenSBI的时钟事件触发一个中断，跳转到kern/trap/trapentry.S的__alltraps标记 -> 
// 保存当前执行流的上下文，并通过函数调用，切换为kern/trap/trap.c的中断处理函数trap()的上下文，
// 进入trap()的执行流。切换前的上下文作为一个结构体，传递给trap()作为函数参数 -> 
// kern/trap/trap.c按照中断类型进行分发(trap_dispatch(), interrupt_handler())->
// 执行时钟中断对应的处理语句，累加计数器，设置下一次时钟中断->
// 完成处理，返回到kern/trap/trapentry.S->
// 恢复原先的上下文，中断处理结束。
// --- 以下是用于 `make grade` 测试栈回溯（backtrace）的代码 ---

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
    // 最终调用内核监视器中的 backtrace 函数
    mon_backtrace(0, NULL, NULL);
}

void __attribute__((noinline)) grade_backtrace1(int arg0, int arg1) {
    grade_backtrace2(arg0, (uintptr_t)&arg0, arg1, (uintptr_t)&arg1);
}

void __attribute__((noinline)) grade_backtrace0(int arg0, int arg1, int arg2) {
    grade_backtrace1(arg0, arg2);
}

void grade_backtrace(void) {
    // 构造一个函数调用栈来进行回溯测试
    grade_backtrace0(0, (uintptr_t)kern_init, 0xffff0000);
}
