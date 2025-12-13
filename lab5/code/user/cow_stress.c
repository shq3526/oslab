#include <stdio.h>
#include <ulib.h>
#include <string.h>

#define STACK_SIZE 4096

// 一个共享的大数组
int shared_arr[1000];

int main(void) {
    cprintf("COW Stress Test: Start\n");

    // 初始化
    for(int i=0; i<1000; i++) shared_arr[i] = i;

    int pid1 = fork();

    if (pid1 == 0) {
        // --- 子进程 1 ---
        // 此时 ref = 2 (父 + 子1)
        
        int pid2 = fork();
        
        if (pid2 == 0) {
            // --- 孙子进程 ---
            // 此时 ref = 3 (父 + 子1 + 孙)
            
            // 孙子进程修改，触发 COW
            // 孙子进程获得新页，ref: (父+子1)=2, (孙)=1
            shared_arr[500] = 9999; 
            cprintf("Grandchild: arr[500] = %d\n", shared_arr[500]);
            exit(0);
        }
        
        waitpid(pid2, NULL);
        
        // 子进程读取，应该还是旧值
        if (shared_arr[500] == 500) {
            cprintf("Child: Data intact after Grandchild exit.\n");
        } else {
            cprintf("Child: FAILED (Grandchild polluted data)\n");
        }
        
        // 子进程修改
        shared_arr[500] = 8888;
        exit(0);
    }

    waitpid(pid1, NULL);
    
    // 父进程检查
    if (shared_arr[500] == 500) {
        cprintf("COW Stress Test: PASSED\n");
    } else {
        cprintf("COW Stress Test: FAILED (Parent data corrupted)\n");
    }

    return 0;
}