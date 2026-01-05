#include <defs.h>
#include <string.h>
#include <vfs.h>
#include <proc.h>
#include <file.h>
#include <unistd.h>
#include <iobuf.h>
#include <inode.h>
#include <stat.h>
#include <dirent.h>
#include <error.h>
#include <assert.h>
#include <kmalloc.h>
#include <sem.h>
#include <wait.h>
#include <sched.h>

/* 获取 pipe_info 的宏 */
#define vop_info_pipe(node) (&((node)->in_info.__pipe_info))

/* * pipe_read - VFS 读接口
 * 处理逻辑：
 * 1. 获取互斥锁。
 * 2. 循环检查缓冲区是否为空。
 * - 如果空且 open_count == 1 (说明写端已关闭)，返回 EOF (0)。
 * - 如果空但还有写端，释放锁并进入睡眠 (schedule)。
 * 3. 从环形缓冲区读取数据。
 * 4. 唤醒可能在等待写入的进程。
 * 5. 释放锁。
 */
static int
pipe_read(struct inode *node, struct iobuf *iob) {
    struct pipe_info *state = vop_info_pipe(node);
    int ret = 0;
    
    down(&(state->mutex));
    
    while (state->p_rpos == state->p_wpos) { // 缓冲区为空
        // 只有当前进程持有引用 (open_count==1)，说明写端已关闭 -> EOF
        if (inode_open_count(node) == 1) {
            ret = 0;
            goto out;
        }
        
        // 还有写者，等待数据
        wait_t __wait, *wait = &__wait;
        wait_current_set(&(state->wait_queue), wait, WT_KSEM);
        up(&(state->mutex)); // 睡眠前必须释放锁
        
        schedule();          // 调度，让出 CPU
        
        down(&(state->mutex)); // 醒来后重新获取锁
        wait_current_del(&(state->wait_queue), wait);
    }

    // 开始读取
    size_t size = state->p_wpos - state->p_rpos;
    if (size > iob->io_resid) {
        size = iob->io_resid;
    }
    
    // 简单的字节拷贝（未优化环形回绕，简化逻辑：ucore通常不处理极端的环形回绕效率问题，直接取模即可）
    // 为了严谨，逐字节拷贝或者分两段拷贝
    size_t i;
    char *buf = state->p_buffer;
    for (i = 0; i < size; i++) {
        char data = buf[(state->p_rpos + i) % PIPE_SIZE];
        iobuf_move(iob, &data, 1, 0, NULL);
    }
    
    state->p_rpos += size;
    
    // 读走了数据，缓冲区有空位了，唤醒写者
    wakeup_queue(&(state->wait_queue), WT_KSEM, 1);
    
out:
    up(&(state->mutex));
    return ret;
}

/* * pipe_write - VFS 写接口
 * 处理逻辑：
 * 1. 获取互斥锁。
 * 2. 如果 open_count == 1 (说明读端已关闭)，写入失败，返回 E_PIPE。
 * 3. 循环检查缓冲区是否已满。
 * - 如果满，释放锁并进入睡眠。
 * 4. 写入数据到环形缓冲区。
 * 5. 唤醒等待读取的进程。
 * 6. 释放锁。
 */
static int
pipe_write(struct inode *node, struct iobuf *iob) {
    struct pipe_info *state = vop_info_pipe(node);
    int ret = 0;
    
    down(&(state->mutex));
    
    // 只有当前进程持有 (open_count==1)，说明读端关闭 -> Broken Pipe
    if (inode_open_count(node) == 1) {
        ret = -E_PIPE;
        goto out;
    }

    size_t len = iob->io_resid;
    size_t i;
    char *buf = state->p_buffer;
    
    // 逐字节写入（处理等待逻辑）
    for (i = 0; i < len; i++) {
        // 检查满：(wpos - rpos) >= PIPE_SIZE
        while ((state->p_wpos - state->p_rpos) >= PIPE_SIZE) {
            // 再次检查读端是否关闭
            if (inode_open_count(node) == 1) {
                ret = -E_PIPE;
                goto out;
            }
            
            // 缓冲区满，等待
            wait_t __wait, *wait = &__wait;
            wait_current_set(&(state->wait_queue), wait, WT_KSEM);
            up(&(state->mutex));
            
            schedule();
            
            down(&(state->mutex));
            wait_current_del(&(state->wait_queue), wait);
        }
        
        // 写入一个字节
        char data;
        iobuf_move(iob, &data, 1, 0, NULL);
        buf[(state->p_wpos) % PIPE_SIZE] = data;
        state->p_wpos++;
        
        // 只要写入了数据，就可以唤醒读者（优化：可以写完一批再唤醒）
        wakeup_queue(&(state->wait_queue), WT_KSEM, 1);
    }

out:
    up(&(state->mutex));
    return ret;
}

/* * pipe_close - VFS 关闭接口
 * 每次 close(fd) 都会调用。
 */
static int
pipe_close(struct inode *node) {
    struct pipe_info *state = vop_info_pipe(node);
    
    // 唤醒所有在等待队列里的人（告知拓扑结构改变，如 EOF 或 Broken Pipe）
    wakeup_queue(&(state->wait_queue), WT_KSEM, 1);
    
    return 0;
}

/* * pipe_reclaim - 资源回收
 * 当 inode->ref_count 降为 0 时调用，释放内存
 */
static int
pipe_reclaim(struct inode *node) {
    struct pipe_info *state = vop_info_pipe(node);
    
    if (state->p_buffer != NULL) {
        kfree(state->p_buffer);
        state->p_buffer = NULL;
    }
    vop_kill(node);
    return 0;
}

static int
pipe_fstat(struct inode *node, struct stat *stat) {
    stat->st_mode = S_IFCHR; // 字符设备类型，或者定义新的 S_IFIFO
    return 0;
}

// 管道的操作函数表
static const struct inode_ops pipe_node_ops = {
    .vop_magic          = VOP_MAGIC,
    .vop_open           = NULL,
    .vop_close          = pipe_close,
    .vop_read           = pipe_read,
    .vop_write          = pipe_write,
    .vop_fstat          = pipe_fstat,
    .vop_fsync          = NULL,
    .vop_reclaim        = pipe_reclaim,
    // 其他不涉及的接口可留空或返回错误
};

/*
 * pipe_create - 创建一个管道 inode
 * 由 kern/fs/file.c 调用
 */
int
pipe_create(struct inode **node_store) {
    struct inode *node;
    if ((node = alloc_inode(pipe_info)) == NULL) {
        return -E_NO_MEM;
    }
    
    vop_init(node, &pipe_node_ops, NULL);
    
    struct pipe_info *state = vop_info_pipe(node);
    // 申请 4KB 内核缓冲区
    if ((state->p_buffer = kmalloc(PIPE_SIZE)) == NULL) {
        inode_kill(node);
        return -E_NO_MEM;
    }
    
    state->p_rpos = state->p_wpos = 0;
    sem_init(&(state->mutex), 1);
    wait_queue_init(&(state->wait_queue));
    
    *node_store = node;
    return 0;
}