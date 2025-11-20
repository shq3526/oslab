.text
.globl kernel_thread_entry

/*
 * kernel_thread_entry - 内核线程的入口汇编代码
 *
 * 当内核线程第一次被调度运行时，它会从这里开始执行。
 *
 * 上下文背景 (来自 kern/process/proc.c 中的 kernel_thread 函数):
 * 1. tf.epc = (uintptr_t)kernel_thread_entry;
 * -> 当 forkrets 执行 sret 指令时，CPU 跳转到 kernel_thread_entry。
 * 2. tf.gpr.s0 = (uintptr_t)fn;
 * -> s0 寄存器保存了要执行的函数指针。
 * 3. tf.gpr.s1 = (uintptr_t)arg;
 * -> s1 寄存器保存了传递给函数的参数。
 */
kernel_thread_entry:        # void kernel_thread(void)

    /* * 1. 准备参数
     * RISC-V 调用约定规定，第一个参数通过 a0 寄存器传递。
     * 我们将 s1 (保存了 arg) 的值移动到 a0。
     * 相当于: a0 = arg;
     */
    move a0, s1

    /*
     * 2. 调用内核线程的主体函数
     * 跳转到 s0 (保存了 fn) 指向的地址执行，并将返回地址保存在 ra 中。
     * 相当于: fn(arg);
     */
    jalr s0

    /*
     * 3. 线程退出
     * 当 fn(arg) 函数执行完毕返回后，代码会继续执行到这里。
     * 我们调用 do_exit 来清理进程资源并调度其他进程。
     * 这确保了内核线程执行完后能正常结束，而不是“跑飞”到未知的内存区域。
     * 相当于: do_exit(fn的返回值); // 实际上 a0 此时保存了 fn 的返回值
     */
    jal do_exit