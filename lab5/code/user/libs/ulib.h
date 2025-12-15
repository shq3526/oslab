#ifndef __USER_LIBS_ULIB_H__
#define __USER_LIBS_ULIB_H__

#include <defs.h>

/* --- 内部错误处理函数声明 --- */
// 打印警告信息，程序继续执行
void __warn(const char *file, int line, const char *fmt, ...);
// 打印恐慌信息并终止程序 (__noreturn 表示该函数不会返回)
void __noreturn __panic(const char *file, int line, const char *fmt, ...);

/* --- 通用调试宏定义 --- */

// [宏] warn: 封装 __warn
// 自动注入当前文件名 (__FILE__) 和行号 (__LINE__)，方便定位警告位置
#define warn(...)                                       \
    __warn(__FILE__, __LINE__, __VA_ARGS__)

// [宏] panic: 封装 __panic
// 遇到不可恢复错误时调用，自动注入位置信息并终止进程
#define panic(...)                                      \
    __panic(__FILE__, __LINE__, __VA_ARGS__)

// [宏] assert: 运行时断言
// 逻辑：如果条件 x 为假 (0)，则调用 panic 报错并打印条件字符串 (#x)。
// do-while(0) 结构用于确保宏在 if-else 语句中展开时语法正确且作用域安全。
#define assert(x)                                       \
    do {                                                \
        if (!(x)) {                                     \
            panic("assertion failed: %s", #x);          \
        }                                               \
    } while (0)

// [宏] static_assert: 编译时断言
// 逻辑：利用 switch case 标签不能重复的特性。
// - 如果 x 为假 (0)：代码展开为 case 0: case 0: ...，产生"重复 case 标签"的编译错误。
// - 如果 x 为真 (非0)：代码展开为 case 0: case x: ...，编译通过。
// 用于在编译阶段检查常量表达式（如结构体大小对齐）。
// static_assert(x) will generate a compile-time error if 'x' is false.
#define static_assert(x)                                \
    switch (x) { case 0: case (x): ; }

/* --- 系统调用封装函数声明 (Wrappers) --- */
/* 这些函数在 ulib.c 中实现，通常直接调用 syscall() 发起 ecall */

// 退出当前进程
// error_code: 退出状态码，会被父进程 wait 捕获
void __noreturn exit(int error_code);

// 创建子进程 (fork)
// 返回值: 父进程得到子进程PID，子进程得到0，失败返回负数
int fork(void);

// 等待任意子进程退出 (sys_wait 的简化版)
int wait(void);

// 等待指定 PID 的子进程退出
// pid: 目标进程ID (0表示任意)
// store: 输出参数，用于存储子进程的退出码
int waitpid(int pid, int *store);

// 主动放弃 CPU，进程从 RUNNING 转为 RUNNABLE
void yield(void);

// 杀死指定进程
// pid: 目标进程ID
int kill(int pid);

// 获取当前进程 ID
int getpid(void);

// 打印当前进程的页目录表信息 (用于调试虚拟内存映射)
void print_pgdir(void);

#endif /* !__USER_LIBS_ULIB_H__ */