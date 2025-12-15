#include <riscv.h>

    .altmacro
    .align 2
    
    # =======================================================
    # 宏定义：SAVE_ALL
    # 作用：保存当前的寄存器上下文到栈上，构建TrapFrame。
    #       这是中断/异常处理的第一步。
    # =======================================================
    .macro SAVE_ALL
    LOCAL _restore_kernel_sp
    LOCAL _save_context

    # [栈切换逻辑]
    # 判断当前是从用户态(User Mode)进入还是内核态(Kernel Mode)进入。
    # 如果是从用户态进入：
    #   sscratch 寄存器保存着内核栈的栈顶指针。
    #   sp 寄存器保存着用户栈的栈顶指针。
    # 如果是从内核态进入（嵌套中断）：
    #   sscratch 寄存器为 0。
    #   sp 寄存器保存着当前的内核栈栈顶指针。
    
    # csrrw sp, sscratch, sp 指令的作用是原子交换 sp 和 sscratch 的值。
    # 1. 如果是从用户态进入：sp 变成了内核栈指针，sscratch 变成了用户栈指针。
    # 2. 如果是从内核态进入：sp 变成了 0，sscratch 变成了原来的 sp（内核栈）。
    csrrw sp, sscratch, sp
    
    # 检查交换后的 sp 是否为 0。
    # 如果 sp != 0，说明刚才 sscratch 里存的是内核栈地址，意味着我们是从用户态进来的。
    # 此时 sp 已经指向内核栈，可以跳转去保存上下文了。
    bnez sp, _save_context

_restore_kernel_sp:
    # 如果交换后的 sp == 0，说明刚才 sscratch 是 0，意味着我们本身就在内核态。
    # 我们刚才把 sp (内核栈指针) 换到了 sscratch 里，导致 sp 变成了 0。
    # 现在需要把 sp 恢复回来，即重新读取 sscratch 的值到 sp。
    csrr sp, sscratch

_save_context:
    # [分配栈空间]
    # 在当前栈（内核栈）上分配空间来存储 TrapFrame。
    # TrapFrame 结构体包含了 32 个通用寄存器 + 4 个 CSR 寄存器，共 36 个寄存器宽度。
    addi sp, sp, -36 * REGBYTES
    
    # [保存通用寄存器]
    # 保存 x0 - x31 寄存器到栈上对应的位置。
    # 这里的 STORE 是 sd (64位) 或 sw (32位) 的宏。
    STORE x0, 0*REGBYTES(sp)
    STORE x1, 1*REGBYTES(sp)   # ra
    STORE x3, 3*REGBYTES(sp)   # gp
    STORE x4, 4*REGBYTES(sp)   # tp
    STORE x5, 5*REGBYTES(sp)   # t0
    STORE x6, 6*REGBYTES(sp)   # t1
    STORE x7, 7*REGBYTES(sp)   # t2
    STORE x8, 8*REGBYTES(sp)   # s0/fp
    STORE x9, 9*REGBYTES(sp)   # s1
    STORE x10, 10*REGBYTES(sp) # a0
    STORE x11, 11*REGBYTES(sp) # a1
    STORE x12, 12*REGBYTES(sp) # a2
    STORE x13, 13*REGBYTES(sp) # a3
    STORE x14, 14*REGBYTES(sp) # a4
    STORE x15, 15*REGBYTES(sp) # a5
    STORE x16, 16*REGBYTES(sp) # a6
    STORE x17, 17*REGBYTES(sp) # a7
    STORE x18, 18*REGBYTES(sp) # s2
    STORE x19, 19*REGBYTES(sp) # s3
    STORE x20, 20*REGBYTES(sp) # s4
    STORE x21, 21*REGBYTES(sp) # s5
    STORE x22, 22*REGBYTES(sp) # s6
    STORE x23, 23*REGBYTES(sp) # s7
    STORE x24, 24*REGBYTES(sp) # s8
    STORE x25, 25*REGBYTES(sp) # s9
    STORE x26, 26*REGBYTES(sp) # s10
    STORE x27, 27*REGBYTES(sp) # s11
    STORE x28, 28*REGBYTES(sp) # t3
    STORE x29, 29*REGBYTES(sp) # t4
    STORE x30, 30*REGBYTES(sp) # t5
    STORE x31, 31*REGBYTES(sp) # t6

    # [保存特殊寄存器和原来的 SP]
    # 此时 sscratch 寄存器里保存的是进入中断前的 sp 值（用户栈指针或内核栈指针）。
    # csrrw s0, sscratch, x0 做了两件事：
    # 1. 读 sscratch 到 s0。
    # 2. 写 x0 (0) 到 sscratch。这很重要！标志着现在进入了内核态处理中断。
    #    这样如果发生递归异常，下次 SAVE_ALL 就能通过 sscratch==0 判断出是内核态。
    csrrw s0, sscratch, x0
    csrr s1, sstatus   # 读取状态寄存器 (包含中断使能、之前的特权级 SPP 等)
    csrr s2, sepc      # 读取异常程序计数器 (中断发生时的指令地址)
    csrr s3, 0x143     # 读取 stval (导致异常的地址，如缺页时的虚拟地址)
    csrr s4, scause    # 读取异常原因 (是系统调用、断点还是缺页等)

    STORE s0, 2*REGBYTES(sp)   # 保存原来的 sp 到 TrapFrame 的 x2 位置
    STORE s1, 32*REGBYTES(sp)  # 保存 sstatus
    STORE s2, 33*REGBYTES(sp)  # 保存 sepc
    STORE s3, 34*REGBYTES(sp)  # 保存 stval
    STORE s4, 35*REGBYTES(sp)  # 保存 scause
    .endm

    # =======================================================
    # 宏定义：RESTORE_ALL
    # 作用：从栈上的 TrapFrame 恢复寄存器上下文，准备返回。
    # =======================================================
    .macro RESTORE_ALL
    LOCAL _save_kernel_sp
    LOCAL _restore_context

    # 先从栈上读取 sstatus 和 sepc 到临时寄存器 s1, s2
    LOAD s1, 32*REGBYTES(sp)
    LOAD s2, 33*REGBYTES(sp)

    # [判断返回目标]
    # SSTATUS_SPP 位记录了进入中断前的特权级 (1=Supervisor, 0=User)。
    # 如果 SPP 位为 1，说明要返回内核态；为 0 说明要返回用户态。
    andi s0, s1, SSTATUS_SPP
    bnez s0, _restore_context

_save_kernel_sp:
    # [准备返回用户态]
    # 如果要返回用户态，我们需要把当前的内核栈顶地址保存到 sscratch 中。
    # 这样下次用户态发生中断时，SAVE_ALL 就能从 sscratch 拿到内核栈指针。
    # sp + 36 * REGBYTES 就是释放 TrapFrame 后的内核栈顶位置。
    addi s0, sp, 36 * REGBYTES
    csrw sscratch, s0
    
_restore_context:
    # [恢复 CSR 寄存器]
    csrw sstatus, s1
    csrw sepc, s2

    # [恢复通用寄存器]
    LOAD x1, 1*REGBYTES(sp)
    LOAD x3, 3*REGBYTES(sp)
    LOAD x4, 4*REGBYTES(sp)
    LOAD x5, 5*REGBYTES(sp)
    LOAD x6, 6*REGBYTES(sp)
    LOAD x7, 7*REGBYTES(sp)
    LOAD x8, 8*REGBYTES(sp)
    LOAD x9, 9*REGBYTES(sp)
    LOAD x10, 10*REGBYTES(sp)
    LOAD x11, 11*REGBYTES(sp)
    LOAD x12, 12*REGBYTES(sp)
    LOAD x13, 13*REGBYTES(sp)
    LOAD x14, 14*REGBYTES(sp)
    LOAD x15, 15*REGBYTES(sp)
    LOAD x16, 16*REGBYTES(sp)
    LOAD x17, 17*REGBYTES(sp)
    LOAD x18, 18*REGBYTES(sp)
    LOAD x19, 19*REGBYTES(sp)
    LOAD x20, 20*REGBYTES(sp)
    LOAD x21, 21*REGBYTES(sp)
    LOAD x22, 22*REGBYTES(sp)
    LOAD x23, 23*REGBYTES(sp)
    LOAD x24, 24*REGBYTES(sp)
    LOAD x25, 25*REGBYTES(sp)
    LOAD x26, 26*REGBYTES(sp)
    LOAD x27, 27*REGBYTES(sp)
    LOAD x28, 28*REGBYTES(sp)
    LOAD x29, 29*REGBYTES(sp)
    LOAD x30, 30*REGBYTES(sp)
    LOAD x31, 31*REGBYTES(sp)
    
    # 最后恢复 x2 (sp)。
    # 此时 sp 会被恢复为用户栈指针 (如果要回用户态的话)
    # 或者是之前的内核栈指针 (如果要回内核态的话)
    LOAD x2, 2*REGBYTES(sp)
    .endm

    # =======================================================
    # 中断入口点：__alltraps
    # CPU 发生中断/异常时，stvec 寄存器指向这里
    # =======================================================
    .globl __alltraps
__alltraps:
    SAVE_ALL            # 1. 保存当前上下文到栈上

    move  a0, sp        # 2. 将当前 sp (指向 TrapFrame 的首地址) 作为第一个参数 a0 传递给 C 函数
    jal trap            # 3. 跳转调用 C 语言的 trap 函数进行具体处理
                        #    sp 在 trap 函数返回后应该保持不变

    # =======================================================
    # 中断返回点：__trapret
    # =======================================================
    .globl __trapret
__trapret:
    RESTORE_ALL         # 4. 从栈上恢复上下文
    # return from supervisor call
    sret                # 5. 特权级切换指令。
                        #    将 pc 设置为 sepc，特权级切换回 sstatus.SPP 指定的模式

    # =======================================================
    # 新进程入口：forkrets
    # 用于 fork 或创建线程后，新进程第一次被调度时的入口
    # =======================================================
    .globl forkrets
forkrets:
    # 新进程被调度时，context.ra 指向 forkrets
    # a0 寄存器保存了新进程的 trapframe 指针 (在 copy_thread 中设置)
    move sp, a0         # 将 sp 指向新进程的 TrapFrame
    j __trapret         # 跳转到 __trapret，执行 RESTORE_ALL 并 sret 进入用户态

    # =======================================================
    # 内核 Execve 返回处理：kernel_execve_ret
    # 专门用于 kernel_execve 后的处理。
    # 当内核线程执行 exec 加载用户程序时，需要把临时构建的 trapframe
    # 从原来的位置复制到当前内核栈的顶部，然后伪装成从中断返回。
    # =======================================================
    .global kernel_execve_ret
kernel_execve_ret:
    # a0: 原来的 trapframe 地址
    # a1: 当前进程的 kstacktop (内核栈顶)

    # 调整 a1 向下预留 TrapFrame 的空间，a1 现在指向新 TrapFrame 的底部
    addi a1, a1, -36*REGBYTES

    # [复制 TrapFrame]
    # copy from previous trapframe (a0) to new trapframe (a1)
    # 将旧的 TrapFrame 内容逐个寄存器复制到新的栈顶位置
    LOAD s1, 35*REGBYTES(a0)
    STORE s1, 35*REGBYTES(a1)
    LOAD s1, 34*REGBYTES(a0)
    STORE s1, 34*REGBYTES(a1)
    LOAD s1, 33*REGBYTES(a0)
    STORE s1, 33*REGBYTES(a1)
    LOAD s1, 32*REGBYTES(a0)
    STORE s1, 32*REGBYTES(a1)
    LOAD s1, 31*REGBYTES(a0)
    STORE s1, 31*REGBYTES(a1)
    LOAD s1, 30*REGBYTES(a0)
    STORE s1, 30*REGBYTES(a1)
    LOAD s1, 29*REGBYTES(a0)
    STORE s1, 29*REGBYTES(a1)
    LOAD s1, 28*REGBYTES(a0)
    STORE s1, 28*REGBYTES(a1)
    LOAD s1, 27*REGBYTES(a0)
    STORE s1, 27*REGBYTES(a1)
    LOAD s1, 26*REGBYTES(a0)
    STORE s1, 26*REGBYTES(a1)
    LOAD s1, 25*REGBYTES(a0)
    STORE s1, 25*REGBYTES(a1)
    LOAD s1, 24*REGBYTES(a0)
    STORE s1, 24*REGBYTES(a1)
    LOAD s1, 23*REGBYTES(a0)
    STORE s1, 23*REGBYTES(a1)
    LOAD s1, 22*REGBYTES(a0)
    STORE s1, 22*REGBYTES(a1)
    LOAD s1, 21*REGBYTES(a0)
    STORE s1, 21*REGBYTES(a1)
    LOAD s1, 20*REGBYTES(a0)
    STORE s1, 20*REGBYTES(a1)
    LOAD s1, 19*REGBYTES(a0)
    STORE s1, 19*REGBYTES(a1)
    LOAD s1, 18*REGBYTES(a0)
    STORE s1, 18*REGBYTES(a1)
    LOAD s1, 17*REGBYTES(a0)
    STORE s1, 17*REGBYTES(a1)
    LOAD s1, 16*REGBYTES(a0)
    STORE s1, 16*REGBYTES(a1)
    LOAD s1, 15*REGBYTES(a0)
    STORE s1, 15*REGBYTES(a1)
    LOAD s1, 14*REGBYTES(a0)
    STORE s1, 14*REGBYTES(a1)
    LOAD s1, 13*REGBYTES(a0)
    STORE s1, 13*REGBYTES(a1)
    LOAD s1, 12*REGBYTES(a0)
    STORE s1, 12*REGBYTES(a1)
    LOAD s1, 11*REGBYTES(a0)
    STORE s1, 11*REGBYTES(a1)
    LOAD s1, 10*REGBYTES(a0)
    STORE s1, 10*REGBYTES(a1)
    LOAD s1, 9*REGBYTES(a0)
    STORE s1, 9*REGBYTES(a1)
    LOAD s1, 8*REGBYTES(a0)
    STORE s1, 8*REGBYTES(a1)
    LOAD s1, 7*REGBYTES(a0)
    STORE s1, 7*REGBYTES(a1)
    LOAD s1, 6*REGBYTES(a0)
    STORE s1, 6*REGBYTES(a1)
    LOAD s1, 5*REGBYTES(a0)
    STORE s1, 5*REGBYTES(a1)
    LOAD s1, 4*REGBYTES(a0)
    STORE s1, 4*REGBYTES(a1)
    LOAD s1, 3*REGBYTES(a0)
    STORE s1, 3*REGBYTES(a1)
    LOAD s1, 2*REGBYTES(a0)
    STORE s1, 2*REGBYTES(a1)
    LOAD s1, 1*REGBYTES(a0)
    STORE s1, 1*REGBYTES(a1)
    LOAD s1, 0*REGBYTES(a0)
    STORE s1, 0*REGBYTES(a1)

    // acutually adjust sp
    # 将栈指针指向新的 TrapFrame，并跳转到恢复流程
    # 这样看起来就像是从一个中断中返回一样，最终 sret 跳转到新程序的入口
    move sp, a1
    j __trapret