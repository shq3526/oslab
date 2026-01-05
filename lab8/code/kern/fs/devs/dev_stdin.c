#include <defs.h>
#include <stdio.h>
#include <wait.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <dev.h>
#include <vfs.h>
#include <iobuf.h>
#include <inode.h>
#include <unistd.h>
#include <error.h>
#include <assert.h>

// 定义标准输入缓冲区大小为 4KB
#define STDIN_BUFSIZE               4096

// 环形缓冲区，用于暂存键盘输入的字符
static char stdin_buffer[STDIN_BUFSIZE];

// p_rpos: 读指针，表示进程已经读到了哪里
// p_wpos: 写指针，表示键盘输入已经写到了哪里
// 缓冲区中的有效数据量 = p_wpos - p_rpos
static off_t p_rpos, p_wpos;

// 等待队列，当缓冲区为空时，读取进程会在此队列上等待（睡眠）
static wait_queue_t __wait_queue, *wait_queue = &__wait_queue;

/*
 * dev_stdin_write - 生产者函数
 * 被底层控制台驱动（console.c）或中断处理程序调用。
 * 功能：将从键盘获取的字符 c 写入缓冲区，并唤醒等待的进程。
 */
void
dev_stdin_write(char c) {
    bool intr_flag;
    if (c != '\0') {
        // 关中断，保护共享的缓冲区指针 p_wpos 和 p_rpos
        // 因为此函数可能在中断上下文中运行，而读者在进程上下文中运行
        local_intr_save(intr_flag);
        {
            // 将字符写入环形缓冲区
            stdin_buffer[p_wpos % STDIN_BUFSIZE] = c;
            
            // 更新写指针。如果缓冲区未满（写指针领先读指针不超过缓冲区大小），则递增
            // 如果缓冲区已满，新字符会覆盖旧字符（视具体实现而定，这里主要是防止溢出逻辑）
            if (p_wpos - p_rpos < STDIN_BUFSIZE) {
                p_wpos ++;
            }
            
            // 如果有进程因为缓冲区空而正在等待（睡眠），则唤醒它
            // WT_KBD 表示等待键盘输入事件
            if (!wait_queue_empty(wait_queue)) {
                wakeup_queue(wait_queue, WT_KBD, 1);
            }
        }
        // 恢复中断状态
        local_intr_restore(intr_flag);
    }
}

/*
 * dev_stdin_read - 消费者函数
 * 被 sys_read -> ... -> stdin_io 调用。
 * 功能：从缓冲区读取 len 个字符到 buf 中。如果缓冲区空，则挂起当前进程。
 */
static int
dev_stdin_read(char *buf, size_t len) {
    int ret = 0;
    bool intr_flag;
    // 关中断，保证读取操作和等待队列操作的原子性
    local_intr_save(intr_flag);
    {
        // 循环读取，直到读够 len 个字符
        for (; ret < len; ret ++, p_rpos ++) {
        try_again:
            // 检查缓冲区是否有数据 (读指针 < 写指针)
            if (p_rpos < p_wpos) {
                // 有数据，直接从环形缓冲区取出一个字符
                *buf ++ = stdin_buffer[p_rpos % STDIN_BUFSIZE];
            }
            else {
                // 缓冲区为空，无法读取。需要让当前进程进入睡眠状态等待输入。
                wait_t __wait, *wait = &__wait;
                
                // 1. 将当前进程加入等待队列，设置等待原因为 WT_KBD
                wait_current_set(wait_queue, wait, WT_KBD);
                
                // 2. 开中断，允许调度器切换进程
                local_intr_restore(intr_flag);

                // 3. 主动让出 CPU，触发调度，切换到其他进程运行
                // 当 dev_stdin_write 被调用并执行 wakeup_queue 时，此进程会被唤醒并从这里继续执行
                schedule();

                // 4. 醒来后，再次关中断，将自己从等待队列中移除
                local_intr_save(intr_flag);
                wait_current_del(wait_queue, wait);
                
                // 5. 检查唤醒原因。如果是被键盘中断唤醒的 (WT_KBD)，则跳转回去再次尝试读取数据
                if (wait->wakeup_flags == WT_KBD) {
                    goto try_again;
                }
                // 如果是其他原因被唤醒（如被 kill），则退出循环
                break;
            }
        }
    }
    local_intr_restore(intr_flag);
    // 返回实际读取到的字符数
    return ret;
}

// 打开设备的钩子函数
// stdin 只允许只读打开 (O_RDONLY)
static int
stdin_open(struct device *dev, uint32_t open_flags) {
    if (open_flags != O_RDONLY) {
        return -E_INVAL;
    }
    return 0;
}

// 关闭设备的钩子函数
static int
stdin_close(struct device *dev) {
    return 0;
}

// stdin 的核心 IO 操作函数
// 对接 VFS 层的接口。如果是写请求，直接报错（stdin 不可写）
// 如果是读请求，调用 dev_stdin_read
static int
stdin_io(struct device *dev, struct iobuf *iob, bool write) {
    if (!write) {
        int ret;
        // 调用内部读取函数，将数据读到 io_base 指向的用户缓冲区
        if ((ret = dev_stdin_read(iob->io_base, iob->io_resid)) > 0) {
            // 更新 iobuf 剩余待读取的字节数
            iob->io_resid -= ret;
        }
        return ret;
    }
    // stdin 设备不支持写操作，返回参数无效错误
    return -E_INVAL;
}

// IO 控制接口，stdin 暂不支持ioctl
static int
stdin_ioctl(struct device *dev, int op, void *data) {
    return -E_INVAL;
}

// 初始化 stdin 设备结构的辅助函数
static void
stdin_device_init(struct device *dev) {
    dev->d_blocks = 0;       // 字符设备没有“块”的概念
    dev->d_blocksize = 1;    // 最小操作单位为 1 字节
    dev->d_open = stdin_open;
    dev->d_close = stdin_close;
    dev->d_io = stdin_io;
    dev->d_ioctl = stdin_ioctl;

    // 初始化读写指针和等待队列
    p_rpos = p_wpos = 0;
    wait_queue_init(wait_queue);
}

// 全局初始化函数：将 stdin 挂载到 VFS 中
void
dev_init_stdin(void) {
    struct inode *node;
    // 创建一个设备类型的 inode
    if ((node = dev_create_inode()) == NULL) {
        panic("stdin: dev_create_node.\n");
    }
    // 初始化该 inode 对应的设备结构体
    stdin_device_init(vop_info(node, device));

    int ret;
    // 将该设备添加到 VFS 设备列表，名称为 "stdin"
    // 参数 0 表示该设备不可挂载（它是字符流，不是文件系统）
    if ((ret = vfs_add_dev("stdin", node, 0)) != 0) {
        panic("stdin: vfs_add_dev: %e.\n", ret);
    }
}