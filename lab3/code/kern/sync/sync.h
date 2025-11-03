#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <defs.h>       // 包含通用宏定义和类型
#include <intr.h>       // 包含中断相关的函数声明（如intr_disable/intr_enable）
#include <riscv.h>      // 包含RISC-V架构相关的寄存器定义（如sstatus、SSTATUS_SIE）

/*
 * __intr_save：保存当前中断使能状态并屏蔽中断
 * 功能：
 * 1. 读取sstatus寄存器（RISC-V的状态寄存器），判断全局中断使能位（SIE）是否开启
 * 2. 若SIE位为1（中断已使能），则关闭中断并返回1（表示需要后续恢复）
 * 3. 若SIE位为0（中断已关闭），则直接返回0（无需后续恢复）
 * 用途：在执行原子操作前调用，确保操作不被中断打断
 */
static inline bool __intr_save(void) {
    // 读取sstatus寄存器的值，与SSTATUS_SIE（中断使能位掩码）进行与运算
    // 若结果非0，说明当前中断是使能的
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();  // 关闭全局中断（屏蔽所有可屏蔽中断）
        return 1;        // 返回1，标记需要恢复中断
    }
    return 0;            // 返回0，标记无需恢复中断
}

/*
 * __intr_restore：根据之前保存的状态恢复中断使能
 * 参数：flag - __intr_save返回的标志（1表示需要恢复，0表示无需恢复）
 * 功能：若flag为1，则重新使能中断，确保不影响原有中断状态
 * 用途：原子操作完成后调用，恢复系统中断状态
 */
static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();   // 重新开启全局中断
    }
}

/*
 * local_intr_save：宏定义，封装__intr_save，保存中断状态到变量
 * 语法说明：do{}while(0)是为了确保宏在任何场景下（如if语句后不加{}）都能正确展开
 * 举例：若写成#define local_intr_save(x) x=__intr_save()，当用于
 *       if(cond) local_intr_save(x);
 *       会被展开为if(cond) x=__intr_save(); 看似正确，但如果用户写成
 *       if(cond)
 *           local_intr_save(x);
 *       else ... 则完全正确。而如果宏内有多个语句，do{}while(0)能保证作为一个整体执行
 * 功能：将中断状态保存到变量x中，并屏蔽中断
 */
#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)

/*
 * local_intr_restore：宏定义，封装__intr_restore，恢复中断状态
 * 功能：根据变量x保存的状态（由local_intr_save设置）恢复中断使能
 */
#define local_intr_restore(x) __intr_restore(x);

#endif /* !__KERN_SYNC_SYNC_H__ */