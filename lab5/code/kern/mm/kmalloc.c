#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <assert.h>
#include <kmalloc.h>
#include <sync.h>
#include <pmm.h>
#include <stdio.h>

/*
 * SLOB Allocator: Simple List Of Blocks
 *
 * Matt Mackall <mpm@selenic.com> 12/30/03
 *
 * 简述 SLOB 的工作原理:
 *
 * SLOB 的核心是一个传统的 K&R 风格的堆分配器，支持返回对齐的对象。
 * x86 上分配粒度是 8 字节。SLOB 堆是一个单向链表，链表中的节点是通过
 * __get_free_page 获取的页面。目前的分配策略是首次适应 (First-Fit)。
 *
 *在此之上实现了 kmalloc/kfree。
 * kmalloc 返回的块是 8 字节对齐的，并且包含一个 8 字节的头部 (slob_t)。
 * 如果申请的对象 >= PAGE_SIZE，它直接调用 __get_free_pages 获取页对齐的块，
 * 并维护一个 bigblock 链表来记录这些大对象的阶数 (order)。
 * kfree() 通过检查地址是否页对齐来区分这两种对象。
 */

// 辅助宏定义
// 保存中断状态并获取自旋锁 (防止分配过程中被中断打断导致死锁或数据破坏)
#define spin_lock_irqsave(l, f) local_intr_save(f)
// 恢复中断状态并释放自旋锁
#define spin_unlock_irqrestore(l, f) local_intr_restore(f)

// 假设锁变量在外部定义 (在本代码片段中未定义，通常在 sync.c 或全局变量中)
static lock_t slob_lock;  // 保护 SLOB 链表的锁
static lock_t block_lock; // 保护 Bigblock 链表的锁

typedef unsigned int gfp_t; // Get Free Page flags (uCore中暂时未深度使用)

#ifndef PAGE_SIZE
#define PAGE_SIZE PGSIZE    // 4096 字节
#endif

#ifndef L1_CACHE_BYTES
#define L1_CACHE_BYTES 64   // CPU L1 缓存行大小，用于对齐
#endif

#ifndef ALIGN
// 地址对齐宏：将 addr 向上对齐到 size 的倍数
#define ALIGN(addr, size) (((addr) + (size) - 1) & (~((size) - 1)))
#endif

// SLOB 块的头部结构 (小内存块元数据)
struct slob_block
{
    int units;              // 块的大小，以 SLOB_UNIT 为单位
    struct slob_block *next;// 指向下一个空闲块的指针
};
typedef struct slob_block slob_t;

// SLOB 单元大小，通常是结构体的大小 (例如 8 字节 或 16 字节)
#define SLOB_UNIT sizeof(slob_t)
// 将字节大小转换为 SLOB 单元数 (向上取整)
#define SLOB_UNITS(size) (((size) + SLOB_UNIT - 1) / SLOB_UNIT)
// 默认对齐大小
#define SLOB_ALIGN L1_CACHE_BYTES

// 大内存块的元数据结构 (用于 >= PAGE_SIZE 的分配)
struct bigblock
{
    int order;              // 分配的页数阶数 (2^order 页)
    void *pages;            // 指向实际分配的物理页的虚拟地址
    struct bigblock *next;  // 链表指针
};
typedef struct bigblock bigblock_t;

// 定义初始的 SLOB 堆头 (哨兵节点)
// .next 指向自己，表示链表为空；.units=1 只是占位
static slob_t arena = {.next = &arena, .units = 1};
// slobfree 指针始终指向空闲链表的头部 (通常是 arena)
static slob_t *slobfree = &arena;
// 大内存块链表头
static bigblock_t *bigblocks;

// __slob_get_free_pages - 底层页分配接口
// 调用 pmm.c 中的 alloc_pages 分配物理页，并转换为内核虚拟地址
static void *__slob_get_free_pages(gfp_t gfp, int order)
{
    struct Page *page = alloc_pages(1 << order);
    if (!page)
        return NULL;
    return page2kva(page);
}

// 申请单个页面的快捷宏
#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

// __slob_free_pages - 底层页释放接口
// 将虚拟地址转回 Page 结构体，并调用 free_pages
static inline void __slob_free_pages(unsigned long kva, int order)
{
    free_pages(kva2page((void *)kva), 1 << order);
}

// 前向声明
static void slob_free(void *b, int size);

// [核心函数] slob_alloc - 分配小内存块
// size: 请求的字节数
// gfp: 分配标志
// align: 对齐要求
static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
    // 断言：请求的大小加上头部必须小于一页，否则应该走 bigblock 路径
    assert((size + SLOB_UNIT) < PAGE_SIZE);

    slob_t *prev, *cur, *aligned = 0;
    // 计算需要的单元数 (SLOB_UNITS 会自动加上头部并转换单位)
    int delta = 0, units = SLOB_UNITS(size);
    unsigned long flags;

    // 1. 获取锁，保护 slobfree 链表
    spin_lock_irqsave(&slob_lock, flags);
    prev = slobfree;

    // 2. 遍历空闲链表 (First-Fit 算法)
    for (cur = prev->next;; prev = cur, cur = cur->next)
    {
        // 处理对齐要求
        if (align)
        {
            aligned = (slob_t *)ALIGN((unsigned long)cur, align);
            delta = aligned - cur; // 计算为了对齐需要跳过多少空间
        }
        
        // 3. 检查当前块是否足够大 (当前块大小 >= 需要的大小 + 对齐偏移)
        if (cur->units >= units + delta)
        { /* room enough? 空间足够 */
            
            // 3.1 如果需要对齐，且有偏移量，需要将头部切下来留在空闲链表中
            if (delta)
            { /* need to fragment head to align? */
                aligned->units = cur->units - delta; // 对齐后的部分的大小
                aligned->next = cur->next;
                cur->next = aligned;                 // 原块指向对齐后的部分
                cur->units = delta;                  // 原块缩小为偏移量大小
                prev = cur;                          // 移动指针
                cur = aligned;                       // cur 指向对齐后的有效起始位置
            }

            // 3.2 刚好合适 (Exact Fit)
            // 如果剩余空间正好等于需要的大小，直接从链表中移除该节点
            if (cur->units == units)    /* exact fit? */
                prev->next = cur->next; /* unlink */
            else
            { /* fragment */
                // 3.3 块太大，需要切割 (Splitting)
                // prev->next 指向剩余的空闲部分 (cur + units)
                prev->next = cur + units;
                // 设置剩余部分的元数据
                prev->next->units = cur->units - units;
                prev->next->next = cur->next;
                // 设置分配出去的块的大小
                cur->units = units;
            }

            // 更新空闲链表头指针，下次分配从这里开始查找 (Next-Fit 优化)
            slobfree = prev;
            spin_unlock_irqrestore(&slob_lock, flags);
            return cur; // 返回分配的块 (包含头部)
        }
        
        // 4. 如果遍历了一圈回到了起点 (slobfree)，说明当前堆中没有足够大的块
        if (cur == slobfree)
        {
            spin_unlock_irqrestore(&slob_lock, flags);

            // 如果请求的是整页大小且无法满足，这在 slob_alloc 中不应发生(前面有assert)
            if (size == PAGE_SIZE) /* trying to shrink arena? */
                return 0;

            // 5. 扩展堆：向底层申请一个新的物理页
            cur = (slob_t *)__slob_get_free_page(gfp);
            if (!cur)
                return 0; // 内存耗尽

            // 6. 将新申请的页通过 slob_free 注入到 SLOB 链表中
            // 这会自动处理合并逻辑，将新页作为空闲块加入
            slob_free(cur, PAGE_SIZE);
            
            // 重新获取锁，重置 prev 为 slobfree，准备重新扫描链表
            spin_lock_irqsave(&slob_lock, flags);
            cur = slobfree;
        }
    }
}

// [核心函数] slob_free - 释放小内存块
// block: 要释放的块指针 (指向 slob_t 头部)
// size: 块的大小 (如果是 0，则从 block->units 读取)
static void slob_free(void *block, int size)
{
    slob_t *cur, *b = (slob_t *)block;
    unsigned long flags;

    if (!block)
        return;

    // 如果指定了 size，更新头部信息 (通常在注入新页时使用)
    if (size)
        b->units = SLOB_UNITS(size);

    /* Find reinsertion point 寻找插入点 */
    // SLOB 链表是按地址排序的，我们需要找到 b 应该插入的位置
    spin_lock_irqsave(&slob_lock, flags);
    for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
        // 处理链表环的边界情况 (cur >= cur->next 表示链表尾部/头部交界处)
        if (cur >= cur->next && (b > cur || b < cur->next))
            break;

    // 此时，cur 是 b 的前一个节点 (地址小于 b)
    // cur->next 是 b 的后一个节点 (地址大于 b)

    // 1. 尝试与后一个块合并 (Coalescing with next)
    // 如果 b 的结束地址等于下一个块的起始地址
    if (b + b->units == cur->next)
    {
        b->units += cur->next->units; // 合并大小
        b->next = cur->next->next;    // 跳过下一个块
    }
    else
        b->next = cur->next;          // 否则直接链接

    // 2. 尝试与前一个块合并 (Coalescing with prev)
    // 如果 cur 的结束地址等于 b 的起始地址
    if (cur + cur->units == b)
    {
        cur->units += b->units;       // 合并大小
        cur->next = b->next;          // 跳过 b
    }
    else
        cur->next = b;                // 否则 cur 指向 b

    // 将 slobfree 指向当前操作的位置，利用局部性原理
    slobfree = cur;

    spin_unlock_irqrestore(&slob_lock, flags);
}



// slob_init - 初始化函数
void slob_init(void)
{
    cprintf("use SLOB allocator\n");
    // 初始化锁 (如果 lock_init 可用)
    lock_init(&slob_lock);
    lock_init(&block_lock);
}

// kmalloc_init - 对外暴露的初始化接口
inline void
kmalloc_init(void)
{
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}

// 统计已分配内存 (SLOB 版本暂未实现具体统计)
size_t
slob_allocated(void)
{
    return 0;
}

size_t
kallocated(void)
{
    return slob_allocated();
}

// find_order - 计算满足 size 大小的最小 2^order 页数
static int find_order(int size)
{
    int order = 0;
    // size 每次右移一位，直到 <= 4096 (1页)
    for (; size > 4096; size >>= 1)
        order++;
    return order;
}

// __kmalloc - kmalloc 的具体实现
static void *__kmalloc(size_t size, gfp_t gfp)
{
    slob_t *m;
    bigblock_t *bb;
    unsigned long flags;

    // 路径 1: 小内存分配 (< 1页 - 头部大小)
    if (size < PAGE_SIZE - SLOB_UNIT)
    {
        // 调用 slob_alloc 分配，不需要对齐
        m = slob_alloc(size + SLOB_UNIT, gfp, 0);
        // 返回跳过头部 (slob_t) 后的地址给用户
        return m ? (void *)(m + 1) : 0;
    }

    // 路径 2: 大内存分配 (>= 1页)
    
    // 首先，为 bigblock_t 结构体本身分配空间 (这是一个小内存分配!)
    bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
    if (!bb)
        return 0;

    // 计算需要的页数阶数
    bb->order = find_order(size);
    // 直接调用页分配器分配物理页
    bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);

    if (bb->pages)
    {
        // 将这个大块记录加入 bigblocks 链表
        spin_lock_irqsave(&block_lock, flags);
        bb->next = bigblocks;
        bigblocks = bb;
        spin_unlock_irqrestore(&block_lock, flags);
        // 返回实际的页面地址
        return bb->pages;
    }

    // 如果页分配失败，释放刚才申请的元数据块
    slob_free(bb, sizeof(bigblock_t));
    return 0;
}

// kmalloc - 内核通用内存分配接口
void *
kmalloc(size_t size)
{
    return __kmalloc(size, 0);
}

// kfree - 内核通用内存释放接口
void kfree(void *block)
{
    bigblock_t *bb, **last = &bigblocks;
    unsigned long flags;

    if (!block)
        return;

    // 1. 检查地址是否按页对齐
    // 如果是页对齐的，它可能是通过 bigblock 机制分配的大块
    if (!((unsigned long)block & (PAGE_SIZE - 1)))
    {
        /* might be on the big block list */
        spin_lock_irqsave(&block_lock, flags);
        // 遍历 bigblocks 链表查找该地址
        for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
        {
            if (bb->pages == block)
            {
                // 找到了！从链表中移除
                *last = bb->next;
                spin_unlock_irqrestore(&block_lock, flags);
                
                // 释放物理页
                __slob_free_pages((unsigned long)block, bb->order);
                // 释放元数据块 (slob_block)
                slob_free(bb, sizeof(bigblock_t));
                return;
            }
        }
        spin_unlock_irqrestore(&block_lock, flags);
        // 如果页对齐但不在 bigblocks 链表中，说明它可能是一个碰巧页对齐的小块
        // 继续向下执行小块释放逻辑
    }

    // 2. 释放小内存块
    // 指针回退 sizeof(slob_t) 找到头部，调用 slob_free
    // 第二个参数为 0，表示让 slob_free 自己查看头部里的 units 字段确定大小
    slob_free((slob_t *)block - 1, 0);
    return;
}

// ksize - 获取已分配块的大小
unsigned int ksize(const void *block)
{
    bigblock_t *bb;
    unsigned long flags;

    if (!block)
        return 0;

    // 1. 检查是否为大块 (页对齐)
    if (!((unsigned long)block & (PAGE_SIZE - 1)))
    {
        spin_lock_irqsave(&block_lock, flags);
        for (bb = bigblocks; bb; bb = bb->next)
            if (bb->pages == block)
            {
                spin_unlock_irqrestore(&slob_lock, flags); // 笔误? 这里应该是 block_lock
                return PAGE_SIZE << bb->order;
            }
        spin_unlock_irqrestore(&block_lock, flags);
    }

    // 2. 小块：读取头部 units 并转换回字节
    return ((slob_t *)block - 1)->units * SLOB_UNIT;
}