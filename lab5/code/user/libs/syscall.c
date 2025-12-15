#include <defs.h>
#include <unistd.h>
#include <stdarg.h>
#include <syscall.h>

#define MAX_ARGS            5

/*
 * syscall - 通用的系统调用接口函数
 * @num: 系统调用号 (Syscall Number)，定义在 unistd.h 中
 * @...: 可变参数，具体的系统调用参数
 * * [功能]: 
 * 1. 处理可变参数列表，将参数提取到数组中。
 * 2. 使用内联汇编将系统调用号和参数放入指定的 RISC-V 寄存器 (a0-a5)。
 * 3. 执行 ecall 指令，触发异常陷入内核态。
 * 4. 获取内核返回的结果。
 */
static inline int
syscall(int64_t num, ...) {
    va_list ap;
    va_start(ap, num); // 初始化可变参数列表，从 num 之后开始获取
    uint64_t a[MAX_ARGS];
    int i, ret;
    
    // 循环提取可变参数，存入临时数组 a 中
    // 注意：这里假设所有参数都是 64 位宽 (uint64_t)
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
    }
    va_end(ap); // 结束可变参数处理

    // [内联汇编核心逻辑]
    // 作用：根据 RISC-V 的调用约定 (ABI) 设置寄存器并触发中断
    asm volatile (
        "ld a0, %1\n"       // [输入]: 将系统调用号 num 加载到寄存器 a0
                            // 在 uCore 中，a0 既用于传参(syscall号)，也用于接收返回值
                            
        "ld a1, %2\n"       // [输入]: 将第1个参数 a[0] 加载到寄存器 a1
        "ld a2, %3\n"       // [输入]: 将第2个参数 a[1] 加载到寄存器 a2
        "ld a3, %4\n"       // [输入]: 将第3个参数 a[2] 加载到寄存器 a3
        "ld a4, %5\n"       // [输入]: 将第4个参数 a[3] 加载到寄存器 a4
        "ld a5, %6\n"       // [输入]: 将第5个参数 a[4] 加载到寄存器 a5
        
        "ecall\n"           // [关键指令]: Environment Call
                            // 1. CPU 停止顺序执行，触发同步异常。
                            // 2. 特权级从 User Mode (U) 切换到 Supervisor Mode (S)。
                            // 3. 跳转到 stvec 寄存器指向的中断处理入口 (通常是 trapentry.S)。
                            
        "sd a0, %0"         // [输出]: 系统调用返回后，内核会将结果存放在 a0 寄存器中
                            // 这里将 a0 的值保存到变量 ret 中
                            
        : "=m" (ret)        // 输出操作数列表: ret 变量对应 %0，"=m" 表示写内存
        : "m"(num),         // 输入操作数列表: num 对应 %1
          "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4]) // 对应 %2 ~ %6
        : "memory");        // Clobber 列表: 告知编译器汇编代码可能修改内存，防止过度优化
        
    return ret;
}

/* * 以下是各个具体系统调用的封装函数 
 * 它们只是简单地调用上面的 syscall 函数，并传入对应的系统调用号
 */

// sys_exit - 退出当前进程
// error_code: 退出码
int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
}

// sys_fork - 创建子进程
// 返回值: 父进程返回子进程PID，子进程返回0
int
sys_fork(void) {
    return syscall(SYS_fork);
}

// sys_wait - 等待子进程退出
// pid: 等待特定的子进程ID (0表示任意)
// store: 用于存储子进程退出码的地址
int
sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, store);
}

// sys_yield - 主动放弃 CPU
// 进程进入 RUNNABLE 状态，重新参与调度
int
sys_yield(void) {
    return syscall(SYS_yield);
}

// sys_kill - 杀死指定进程
// pid: 目标进程 ID
int
sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid);
}

// sys_getpid - 获取当前进程 ID
int
sys_getpid(void) {
    return syscall(SYS_getpid);
}

// sys_putc - 输出一个字符到控制台
// c: 要输出的字符
int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
}

// sys_pgdir - (调试用) 获取当前页目录表的物理地址或相关信息
int
sys_pgdir(void) {
    return syscall(SYS_pgdir);
}

// sys_get_free_pages - (统计用) 获取当前系统空闲的物理页数量
// 这里的调用号与 cow_mem.c 测试中的需求对应
int
sys_get_free_pages(void) {
    return syscall(SYS_get_free_pages);
}

// sys_set_cow_attack - (Challenge) 用于 Dirty COW 漏洞演示
// enable: 1 开启攻击模拟开关，0 关闭
int
sys_set_cow_attack(int enable) {
    return syscall(SYS_set_cow_attack, enable);
}