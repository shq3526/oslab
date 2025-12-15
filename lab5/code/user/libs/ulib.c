#include <defs.h>
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

/* *
 * exit - 终止当前进程
 * @error_code: 退出状态码 (0通常表示成功)
 * * [功能]: 
 * 请求内核销毁当前进程。正常情况下该函数不会返回。
 * * [逻辑]:
 * 1. 调用 sys_exit 陷入内核，执行 do_exit。
 * 2. 如果 sys_exit 返回了，说明内核没能成功杀掉进程，属于严重 Bug。
 * 3. 打印错误信息并死循环，防止程序继续执行未知指令。
 */
void
exit(int error_code) {
    sys_exit(error_code);
    cprintf("BUG: exit failed.\n");
    while (1);
}

/* *
 * fork - 创建子进程
 * * [功能]: 
 * 复制当前进程。
 * * [返回值]: 
 * - 父进程中返回子进程 PID (>0)。
 * - 子进程中返回 0。
 * - 失败返回负的错误码。
 */
int
fork(void) {
    return sys_fork();
}

/* *
 * wait - 等待任意子进程退出
 * * [功能]: 
 * 阻塞当前进程，直到任意一个子进程退出。
 * * [实现]: 
 * 实际上是对 sys_wait 的封装，pid=0 表示"任意子进程"，store=NULL 表示"不保存退出码"。
 */
int
wait(void) {
    return sys_wait(0, NULL);
}

/* *
 * waitpid - 等待指定子进程退出
 * @pid: 要等待的目标子进程 PID
 * @store: 指针，用于接收子进程的 exit_code (输出参数)
 * * [功能]: 
 * 阻塞当前进程，直到 PID 为 pid 的子进程退出。
 */
int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
}

/* *
 * yield - 主动让出 CPU
 * * [功能]: 
 * 进程主动放弃当前的 CPU 时间片，回到就绪队列，让调度器选择其他进程运行。
 */
void
yield(void) {
    sys_yield();
}

/* *
 * kill - 杀死指定进程
 * @pid: 目标进程 ID
 * * [功能]: 
 * 请求内核设置目标进程的 flags 为 PF_EXITING，使其在下次陷入内核时退出。
 */
int
kill(int pid) {
    return sys_kill(pid);
}

/* *
 * getpid - 获取当前进程 ID
 */
int
getpid(void) {
    return sys_getpid();
}

//print_pgdir - print the PDT&PT
/* *
 * print_pgdir - (调试用) 打印页表
 * * [功能]: 
 * 请求内核打印当前进程的页目录表和页表结构，用于调试虚拟内存映射。
 */
void
print_pgdir(void) {
    sys_pgdir();
}