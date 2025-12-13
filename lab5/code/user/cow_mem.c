#include <stdio.h>
#include <ulib.h>
#include <syscall.h>

// 定义 10MB 的数据量
#define SIZE (10 * 1024 * 1024)

// 【关键修改】使用全局数组替代 malloc
// 放在 main 外面，防止爆栈（用户栈很小），且属于 BSS 段
// volatile 关键字防止编译器优化掉读写操作
volatile char big_mem[SIZE];

int main(void) {
    cprintf("COW Memory Efficiency Test: Start\n");

    // 1. 强制写入内存，触发缺页异常，分配物理页
    // 步长设为 PGSIZE (4096)，确保覆盖每一个物理页
    for (int i = 0; i < SIZE; i += 4096) {
        big_mem[i] = 1; 
    }
    
    cprintf("Memory allocated and filled.\n");

    // 2. 记录 fork 前的空闲页数
    int free_before = sys_get_free_pages();
    cprintf("Free pages before fork: %d\n", free_before);

    int pid = fork();

    if (pid == 0) {
        // 子进程：暂时不写，只读
        // 如果 COW 生效，这里应该共享父进程的页，不消耗新物理页
        volatile char temp = big_mem[0];
        // 这一步是为了防止编译器把读取操作优化掉
        (void)temp; 
        exit(0);
    } else {
        // 父进程
        // 3. 记录 fork 后的空闲页数
        int free_after = sys_get_free_pages();
        cprintf("Free pages after fork: %d\n", free_after);

        int diff = free_before - free_after;
        cprintf("Pages consumed by fork: %d\n", diff);

        // 判定逻辑：
        // 10MB 内存大约对应 2560 个页 (10*1024*1024 / 4096)
        // 如果使用了 COW，fork 消耗的页应该远小于 2560 (通常只需几十页用于页表)
        // 如果没用 COW，diff 会接近 2560
        if (diff < 1000) { 
            cprintf("COW Memory Efficiency Test: PASSED\n");
            cprintf("Explanation: Only page tables were copied, not physical memory.\n");
        } else {
            cprintf("COW Memory Efficiency Test: FAILED\n");
            cprintf("Explanation: Massive memory consumption detected (Deep Copy).\n");
        }
        
        waitpid(pid, NULL);
    }
    return 0;
}