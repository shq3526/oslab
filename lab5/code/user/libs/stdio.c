#include <defs.h>
#include <stdio.h>
#include <syscall.h>

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
/* [详细注释]
 * 功能: 输出单个字符的回调函数。
 * 参数:
 * c: 要输出的字符 ASCII 码。
 * cnt: 指向计数器的指针，用于统计已输出的字符数量。
 * 注意:
 * 这个函数通常作为函数指针传递给 vprintfmt。
 * 它不直接操作硬件，而是通过 sys_putc 发起系统调用，让内核去处理输出。
 */
static void
cputch(int c, int *cnt) {
    sys_putc(c); // 调用系统调用接口，陷入内核态打印字符
    (*cnt) ++;   // 递增计数器，记录打印字符的总数
}

/* *
 * vcprintf - format a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
/* [详细注释]
 * 功能: 格式化输出的核心函数（处理 va_list）。
 * 参数:
 * fmt: 格式化字符串 (如 "num: %d")。
 * ap: 已经初始化的参数列表指针 (va_list)。
 * 返回值: 实际输出的字符总数。
 */
int
vcprintf(const char *fmt, va_list ap) {
    int cnt = 0; // 初始化计数器
    // vprintfmt 是 libs/printfmt.c 中的通用格式化函数。
    // 它解析 %d, %s 等格式，每解析出一个字符，就调用一次 cputch。
    // (void*)cputch: 将输出函数的地址传进去。
    vprintfmt((void*)cputch, &cnt, fmt, ap);
    return cnt;
}

/* *
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
/* [详细注释]
 * 功能: 用户态的格式化打印函数 (类似于标准库的 printf)。
 * 参数:
 * fmt: 格式化字符串。
 * ...: 可变参数列表。
 * 返回值: 实际输出的字符总数。
 */
int
cprintf(const char *fmt, ...) {
    va_list ap;

    va_start(ap, fmt); // 初始化可变参数列表，指向 fmt 之后的第一个参数
    int cnt = vcprintf(fmt, ap); // 调用核心处理函数
    va_end(ap); // 清理可变参数列表

    return cnt;
}

/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
/* [详细注释]
 * 功能: 输出一个纯字符串并自动换行 (类似于标准库的 puts)。
 * 参数:
 * str: 字符串首地址。
 * 返回值: 实际输出的字符总数 (包含换行符)。
 */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    // 遍历字符串直到遇到结束符 '\0'
    while ((c = *str ++) != '\0') {
        cputch(c, &cnt); // 逐个字符调用 syscall 输出
    }
    cputch('\n', &cnt); // 最后追加一个换行符
    return cnt;
}