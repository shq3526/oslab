#include <defs.h>
#include <stdarg.h>
#include <stdio.h>
#include <ulib.h>
#include <error.h>

/* *
 * __panic - 用户态的 panic 处理函数
 * @file: 发生错误的文件名 (通常由编译器宏 __FILE__ 提供)
 * @line: 发生错误的行号 (通常由编译器宏 __LINE__ 提供)
 * @fmt: 格式化字符串
 * @...: 可变参数
 * * [功能]: 
 * 1. 打印错误位置 (文件名:行号) 和具体的错误信息。
 * 2. 调用 exit 系统调用，以错误码 -E_PANIC 终止当前进程。
 * * [注意]: 
 * 用户程序的 panic 不会让操作系统死机，只会让当前这个出了问题的进程退出。
 */
void
__panic(const char *file, int line, const char *fmt, ...) {
    // print the 'message'
    va_list ap;
    va_start(ap, fmt); // 初始化可变参数列表，指向 fmt 之后的第一个参数

    // 打印 "user panic at 文件名:行号:"
    cprintf("user panic at %s:%d:\n    ", file, line);
    
    // 打印用户传递的具体格式化错误信息
    vcprintf(fmt, ap);
    
    cprintf("\n");
    va_end(ap); // 结束可变参数处理

    // [关键]: 调用 exit 库函数 (最终调用 sys_exit 系统调用)
    // 使用 -E_PANIC (定义在 error.h) 作为退出码，告知父进程非正常退出
    exit(-E_PANIC);
}

/* *
 * __warn - 用户态的警告处理函数
 * @file: 文件名
 * @line: 行号
 * @fmt: 格式化字符串
 * @...: 可变参数
 * * [功能]: 
 * 仅打印警告信息，打印后程序**继续执行**，不会退出。
 * 用于提示非致命的错误或调试信息。
 */
void
__warn(const char *file, int line, const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);

    // 打印 "user warning at 文件名:行号:"
    cprintf("user warning at %s:%d:\n    ", file, line);
    
    // 打印具体警告信息
    vcprintf(fmt, ap);
    
    cprintf("\n");
    va_end(ap);
    // 注意：这里没有 exit()，函数返回后程序继续运行
}