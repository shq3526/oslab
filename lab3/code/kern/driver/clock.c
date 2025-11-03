#include <clock.h>
#include <defs.h>
#include <sbi.h>    // 导入SBI（Supervisor Binary Interface）头文件，用于调用sbi_set_timer
#include <stdio.h>
#include <riscv.h>  // 导入RISC-V特定头文件，包含CSR（控制状态寄存器）读写宏和rdtime指令

/*
 * volatile 关键字告诉编译器，这个变量的值可能会在程序“意料之外”的地方被改变
 * （例如在中断服务程序中），因此编译器不应对其进行优化（如缓存到寄存器中）。
 * ticks 变量用于累计时钟中断发生的次数。
 */
volatile size_t ticks;

/*
 * get_cycles (或 get_time) - 读取RISC-V的 64 位 time 计数器
 * 这是一个内联汇编函数，用于安全地读取 time CSR。
 * 实验资料中提到：QEMU上的时钟频率是 10MHz，即 time 寄存器每秒增加 10,000,000。
 */
static inline uint64_t get_cycles(void) {
// __riscv_xlen 是 GCC 定义的宏，用于区分是64位还是32位架构
#if __riscv_xlen == 64
    // 64位架构：可以直接使用 rdtime 伪指令读取整个64位 time 寄存器
    uint64_t n;
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    return n;
#else
    // 32位架构：time 寄存器是64位的，但CPU只能一次读32位。
    // 必须使用特定序列来防止读取时发生（高32位）溢出。
    uint32_t lo, hi, tmp;
    __asm__ __volatile__(
        "1:\n"           // 循环标签
        "rdtimeh %0\n"   // 1. 读取高32位
        "rdtime %1\n"    // 2. 读取低32位
        "rdtimeh %2\n"   // 3. 再次读取高32位
        "bne %0, %2, 1b" // 4. 比较两次读取的高32位，如果不相等，说明在(2)期间发生了溢出，跳回(1)重试
        : "=&r"(hi), "=&r"(lo), "=&r"(tmp));
    // 组合高32位和低32位，形成一个64位无符号整数
    return ((uint64_t)hi << 32) | lo;
#endif
}

/*
 * timebase (时间基准) - 两次时钟中断之间的时间间隔（单位是 time 计数器的节拍数）
 * 实验资料中提到：
 * 1. QEMU 的时钟频率是 10MHz (10,000,000 节拍/秒)
 * 2. 实验要求每秒触发 100 次时钟中断（即 100 Hz）
 * * 计算 timebase: (10,000,000 节拍/秒) / (100 次中断/秒) = 100,000 节拍/次中断
 * * 这意味着我们希望每隔 100,000 个 time 节拍触发一次中断。
 */
static uint64_t timebase = 100000;

/*
 * clock_init - 初始化时钟中断
 * 1. 使能S模式的时钟中断
 * 2. 设置第一次时钟中断事件
 * 3. 初始化 ticks 计数器
 */
void clock_init(void) {
    /*
     * sie (Supervisor Interrupt Enable) 是一个 CSR，用于控制哪些中断可以上报给 S 模式。
     * set_csr 宏用于设置 sie 寄存器中的某一位。
     * MIP_STIP (定义在 riscv.h) 是 Supervisor Timer Interrupt Pending (STIP) 位的掩码。
     * 这行代码的作用是：使能S模式的时钟中断。
     */
    set_csr(sie, MIP_STIP);

    // 设置 *第一次* 时钟中断事件。
    // 中断处理程序（trap.c）将负责设置后续的中断。
    clock_set_next_event();

    // 初始化全局时钟中断计数器为 0
    ticks = 0;

    cprintf("++ setup timer interrupts\n"); // 打印初始化完成信息
}

/*
 * clock_set_next_event - 设置下一次时钟中断事件
 * 这是时钟中断机制的核心：RISC-V的时钟中断是“一次性”的，
 * 每次触发后都需要重新设置下一次触发的时间。
 */
void clock_set_next_event(void) {
    /*
     * sbi_set_timer 是一个 OpenSBI (M模式固件) 提供的标准调用接口。
     * 它告诉 M 模式：“请在 time 寄存器的值达到 X 时，向 S 模式触发一个时钟中断”。
     * * get_cycles()：获取当前 time 寄存器的值。
     * get_cycles() + timebase：计算出下一次中断的目标时间
     * （即：当前时间 + 100,000 节拍）。
     */
    sbi_set_timer(get_cycles() + timebase);
}
