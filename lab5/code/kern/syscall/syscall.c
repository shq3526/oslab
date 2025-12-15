#include <unistd.h>
#include <proc.h>
#include <syscall.h>
#include <trap.h>
#include <stdio.h>
#include <pmm.h>
#include <assert.h>
#include <vmm.h>

/*调用链： 用户态 fork() -> ecall (触发 Trap) -> vector.S -> trap() -> trap_dispatch() -> syscall() -> sys_fork() -> do_fork()。

各函数简述：

sys_exec -> do_execve -> load_icode：加载新程序，替换当前进程内存。

sys_fork -> do_fork：复制当前进程（PCB、栈、内存）。

sys_wait -> do_wait：查找 ZOMBIE 子进程。如果有，回收资源；如果子进程还在跑，自己设为 SLEEPING 并 schedule()。

sys_exit -> do_exit：释放资源，变僵尸，通知父进程。

*/



/* [Syscall Handler] sys_exit
 * 功能：处理用户进程的主动退出请求。
 * 参数：arg[0] -> 错误码/退出码 (error_code)
 * 逻辑：直接调用内核核心函数 do_exit，该函数会回收资源并将进程状态置为 ZOMBIE。
 */
static int
sys_exit(uint64_t arg[]) {
    int error_code = (int)arg[0];
    return do_exit(error_code);
}

/* [Syscall Handler] sys_fork
 * 功能：创建子进程。
 * 逻辑：
 * 1. current->tf 是当前进程在进入内核态（执行 ecall）时保存的中断帧。
 * 2. tf->gpr.sp 是用户态的栈指针。
 * 3. do_fork 会复制父进程的内存布局（如果是 COW，则复制页表），并设置子进程的 trapframe。
 * 4. 返回值：父进程得到子进程 PID，子进程得到 0。
 */
static int
sys_fork(uint64_t arg[]) {
    struct trapframe *tf = current->tf;
    uintptr_t stack = tf->gpr.sp;
    return do_fork(0, stack, tf);
}

/* [Syscall Handler] sys_wait
 * 功能：等待子进程退出。
 * 参数：
 * arg[0] -> pid (等待特定的子进程，0表示任意子进程)
 * arg[1] -> store (用于存储子进程退出码的用户态地址)
 * 逻辑：调用 do_wait，如果子进程没退出，当前进程会进入 SLEEPING 状态等待唤醒。
 */
static int
sys_wait(uint64_t arg[]) {
    int pid = (int)arg[0];
    int *store = (int *)arg[1];
    return do_wait(pid, store);
}

/* [Syscall Handler] sys_exec
 * 功能：加载并执行新程序。
 * 参数：
 * arg[0] -> name (程序名)
 * arg[1] -> len (名字长度)
 * arg[2] -> binary (程序二进制代码在内存中的起始位置，Lab5 特有的 Link-in-Kernel 机制)
 * arg[3] -> size (二进制大小)
 * 逻辑：调用 do_execve 清空当前进程内存，加载新程序，并重置 trapframe 入口点 (epc)。
 */
static int
sys_exec(uint64_t arg[]) {
    const char *name = (const char *)arg[0];
    size_t len = (size_t)arg[1];
    unsigned char *binary = (unsigned char *)arg[2];
    size_t size = (size_t)arg[3];
    return do_execve(name, len, binary, size);
}

/* [Syscall Handler] sys_yield
 * 功能：主动让出 CPU。
 * 逻辑：调用 do_yield，设置 current->need_resched = 1，触发调度器选择下一个进程。
 */
static int
sys_yield(uint64_t arg[]) {
    return do_yield();
}

/* [Syscall Handler] sys_kill
 * 功能：杀死指定进程。
 * 参数：arg[0] -> pid (目标进程 ID)
 * 逻辑：do_kill 会给目标进程设置 PF_EXITING 标志，目标进程在下一次陷入内核或被调度时会退出。
 */
static int
sys_kill(uint64_t arg[]) {
    int pid = (int)arg[0];
    return do_kill(pid);
}

/* [Syscall Handler] sys_getpid
 * 功能：获取当前进程 ID。
 */
static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
}

/* [Syscall Handler] sys_putc
 * 功能：输出一个字符。
 * 逻辑：这是 printf 的底层实现，最终调用 SBI 接口输出到控制台。
 */
static int
sys_putc(uint64_t arg[]) {
    int c = (int)arg[0];
    cputchar(c);
    return 0;
}

/* [Syscall Handler] sys_pgdir
 * 功能：调试用，打印页目录信息（本实验中主要用于调试，这里为空实现）。
 */
static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}

/* [Challenge 1 Helper] sys_get_free_pages
 * 功能：获取当前系统空闲物理页数量。
 * 目的：用于 cow_mem.c 测试。
 * 逻辑：在 fork 前后调用此函数，计算差值。
 * 如果差值很小（如仅增加了页表开销），说明 COW 生效（没有复制物理内存）；
 * 如果差值很大（接近数据段大小），说明 COW 失败（发生了 Deep Copy）。
 */
static int
sys_get_free_pages(uint64_t arg[]) {
    // 调用 pmm.h 中声明的内核函数，获取当前空闲页数
    return (int)nr_free_pages();
}

/* [Challenge 1 / Dirty COW Helper] sys_set_cow_attack
 * 功能：控制内核中 Dirty COW 漏洞模拟代码的开关。
 * 参数：arg[0] -> enable (1 开启, 0 关闭)
 * 目的：用于 dirty_cow_test.c 测试。
 * 逻辑：
 * 1. 修改全局变量 TEST_DIRTY_COW_FLAG。
 * 2. 当开启时，do_pgfault (vmm.c) 会在页面复制后、建立映射前，故意清空 PTE，模拟竞态条件。
 */
// 【新增】实现控制攻击开关的系统调用
static int
sys_set_cow_attack(uint64_t arg[]) {
    int enable = (int)arg[0];
    TEST_DIRTY_COW_FLAG = (enable != 0);
    cprintf("[Kernel] Dirty COW Attack Simulation: %s\n", 
            TEST_DIRTY_COW_FLAG ? "ENABLED" : "DISABLED");
    return 0;
}

// 系统调用分发表
// 将系统调用号 (SYS_xxx) 映射到具体的处理函数
static int (*syscalls[])(uint64_t arg[]) = {
    [SYS_exit]              sys_exit,
    [SYS_fork]              sys_fork,
    [SYS_wait]              sys_wait,
    [SYS_exec]              sys_exec,
    [SYS_yield]             sys_yield,
    [SYS_kill]              sys_kill,
    [SYS_getpid]            sys_getpid,
    [SYS_putc]              sys_putc,
    [SYS_pgdir]             sys_pgdir,
    
    // 注册 Challenge 所需的系统调用
    [SYS_get_free_pages]    sys_get_free_pages,
    [SYS_set_cow_attack]    sys_set_cow_attack,
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

/* [Core Dispatcher] syscall
 * 功能：系统调用总入口。
 * 调用路径：user code (ecall) -> trap entry -> trap() -> exception_handler() -> syscall()
 * 逻辑：
 * 1. 从当前进程的中断帧 (trapframe) 中获取上下文。
 * 2. RISC-V 调用约定：
 * - a0: 保存系统调用号 (Input)，也保存返回值 (Output)。
 * - a1-a5: 保存系统调用的参数。
 * 3. 查表调用对应的 sys_xxx 函数。
 * 4. 将返回值写回 tf->gpr.a0，这样当 sret 返回用户态时，用户程序能拿到结果。
 */
void
syscall(void) {
    struct trapframe *tf = current->tf;
    uint64_t arg[5];
    
    // 获取系统调用号 (保存在寄存器 a0 中)
    int num = tf->gpr.a0;
    
    // 检查调用号是否合法
    if (num >= 0 && num < NUM_SYSCALLS) {
        if (syscalls[num] != NULL) {
            // 将寄存器参数 (a1-a5) 填入 arg 数组
            arg[0] = tf->gpr.a1;
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            
            // 执行具体的系统调用，并将返回值存回 a0 寄存器
            tf->gpr.a0 = syscalls[num](arg);
            return ;
        }
    }
    
    // 如果调用号未定义，打印中断帧并 Panic
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}