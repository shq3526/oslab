#include <stdio.h>
#include <ulib.h>
#include <string.h>

int global_flag = 0;

int main(void) {
    cprintf("COW Data Isolation Test: Start\n");

    int pid = fork();

    if (pid == 0) {
        // 子进程
        cprintf("Child: Writing to global_flag...\n");
        // 这一步写入操作应该触发 Page Fault -> Copy on Write
        global_flag = 1; 
        cprintf("Child: global_flag = %d (Should be 1)\n", global_flag);
        if (global_flag != 1) {
             cprintf("Child: ERROR - Write failed\n");
             exit(-1);
        }
        exit(0);
    } else {
        // 父进程
        waitpid(pid, NULL); // 等待子进程写完并退出
        
        cprintf("Parent: global_flag = %d (Should be 0)\n", global_flag);
        
        if (global_flag == 0) {
            cprintf("COW Data Isolation Test: PASSED\n");
        } else {
            cprintf("COW Data Isolation Test: FAILED (Data corrupted)\n");
        }
    }
    return 0;
}