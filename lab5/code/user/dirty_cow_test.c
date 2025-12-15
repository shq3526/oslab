#include <stdio.h>
#include <ulib.h>
#include <syscall.h>
#include <unistd.h>



volatile int data = 100;

void run_victim_process() {
    data = 200;
    int pid = fork();
    if (pid == 0) {
        // --- 孙子进程 (Attacker) ---
        
        // 直接调用库函数 sys_set_cow_attack
        sys_set_cow_attack(1); 
        cprintf("   [Child] Attacking...\n");
        
        data = 300; 
        
        cprintf("   [Child] Done. Exiting.\n");
        exit(0);
    }
    
    waitpid(pid, NULL);
    cprintf(" [Middle] Child exited. Middle process exiting now.\n");
    exit(0);
}

int main(void) {
    cprintf("Dirty COW Simulation: Start\n");
    
    // 直接调用库函数 sys_get_free_pages
    int free_baseline = sys_get_free_pages();
    cprintf("Baseline free pages: %d\n", free_baseline);
    
    int pid = fork();
    if (pid == 0) {
        run_victim_process();
    }
    
    waitpid(pid, NULL);
    
    // 再次调用库函数
    int free_final = sys_get_free_pages();
    cprintf("Final free pages:    %d\n", free_final);
    
    int diff = free_baseline - free_final;
    cprintf("Missing pages:       %d\n", diff);
    
    if (diff > 0) {
        cprintf("\nRESULT: MEMORY LEAK DETECTED!\n");
        cprintf("Explanation: The physical page was not freed after owner exited.\n");
        cprintf("Dirty COW Simulation: SUCCESS (Bug Reproduced)\n");
    } else {
        cprintf("\nRESULT: No leak detected. (Normal Behavior)\n");
        cprintf("Dirty COW Simulation: FAILED\n");
    }
    
    return 0;
}