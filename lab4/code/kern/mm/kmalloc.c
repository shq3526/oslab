#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <assert.h>
#include <kmalloc.h>
#include <sync.h>
#include <pmm.h>
#include <stdio.h>

/*
 * SLOB Allocator: Simple List Of Blocks (简单块列表分配器)
 *
 * Matt Mackall <mpm@selenic.com> 12/30/03
 *
 * SLOB 的工作原理:
 *
 * SLOB 的核心是一个传统的 K&R 风格的堆分配器，支持返回对齐的对象。
 * 在 x86 上，该分配器的粒度是 8 字节，尽管如果认为值得的话，可能将其减少到 4 字节。
 * SLOB 堆是一个由 __get_free_page 获取的页面组成的单向链表，按需增长，
 * 并且堆的分配策略目前是首次适应 (first-fit) 算法。
 *
 * 在此之上是 kmalloc/kfree 的实现。kmalloc 返回的块是 8 字节对齐的，
 * 并且在前面预置了一个 8 字节的头 (header)。
 * 如果 kmalloc 请求的对象大小达到或超过 PAGE_SIZE，它直接调用 __get_free_pages，
 * 以便它可以返回页面对齐的块，并保留此类页面及其阶数 (order) 的链表。
 * 这些大对象在 kfree() 中通过其页面对齐特性被检测出来。
 *
 * SLAB 是通过简单地为每个 SLAB 分配调用构造函数和析构函数在 SLOB 之上模拟的。
 * 除非设置了 SLAB_MUST_HWCACHE_ALIGN 标志，否则返回的对象是 8 字节对齐的，
 * 在这种情况下，低级分配器将分割块以创建适当的对齐。
 * 同样，页面大小或更大的对象通过调用 __get_free_pages 来分配。
 * 由于 SLAB 对象知道它们的大小，不需要单独的大小记账，因此基本上没有分配空间开销。
 */

// 一些辅助定义
// 这里将自旋锁操作映射为 ucore 中的关中断操作，以保证在临界区内的原子性
#define spin_lock_irqsave(l, f) local_intr_save(f)
#define spin_unlock_irqrestore(l, f) local_intr_restore(f)
typedef unsigned int gfp_t; // Get Free Page flags 类型

#ifndef PAGE_SIZE
#define PAGE_SIZE PGSIZE
#endif

#ifndef L1_CACHE_BYTES
#define L1_CACHE_BYTES 64
#endif

#ifndef ALIGN
// 对齐宏：将 addr 向上对齐到 size 的倍数
#define ALIGN(addr, size) (((addr) + (size) - 1) & (~((size) - 1)))
#endif

// SLOB 块结构体 (小内存块的元数据头)
// 每个空闲块或者已分配块的前面都有这个结构
struct slob_block
{
    int units;              // 块的大小 (以 SLOB_UNIT 为单位)
    struct slob_block *next;// 指向下一个空闲块的指针 (仅在空闲链表中有效)
};
typedef struct slob_block slob_t;

// SLOB 单元大小，通常等于结构体大小
#define SLOB_UNIT sizeof(slob_t)
// 计算 size 需要多少个 SLOB 单元，向上取整
#define SLOB_UNITS(size) (((size) + SLOB_UNIT - 1) / SLOB_UNIT)
// SLOB 默认对齐大小
#define SLOB_ALIGN L1_CACHE_BYTES

// 大块内存结构体 (用于大于一页的分配)
struct bigblock
{
    int order;              // 页面的阶数 (2^order 个页面)
    void *pages;            // 指向实际分配的页面虚拟地址
    struct bigblock *next;  // 指向下一个大块的指针
};
typedef struct bigblock bigblock_t;

// slobfree 指向空闲链表的头部
// arena 是一个哨兵节点，用于简化链表操作
static slob_t arena = {.next = &arena, .units = 1};
static slob_t *slobfree = &arena;
// bigblocks 指向大块内存链表的头部
static bigblock_t *bigblocks;

// __slob_get_free_pages - 从底层页分配器 (pmm) 获取 2^order 个连续物理页
static void *__slob_get_free_pages(gfp_t gfp, int order)
{
    struct Page *page = alloc_pages(1 << order);
    if (!page)
        return NULL;
    return page2kva(page); // 返回内核虚拟地址
}

// 获取单个空闲页的宏
#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

// __slob_free_pages - 释放页面到底层页分配器
static inline void __slob_free_pages(unsigned long kva, int order)
{
    free_pages(kva2page(kva), 1 << order);
}

// 前置声明
static void slob_free(void *b, int size);

// slob_alloc - SLOB 核心分配函数
// size: 请求的大小 (字节)
// gfp: 分配标志 (在 ucore 简化版中未使用)
// align: 对齐要求
static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
    assert((size + SLOB_UNIT) < PAGE_SIZE); // 确保分配大小适合 SLOB 机制 (小于一页)

    slob_t *prev, *cur, *aligned = 0;
    int delta = 0, units = SLOB_UNITS(size); // 将字节转换为单元数
    unsigned long flags;

    // 进入临界区，关中断，防止并发修改空闲链表
    spin_lock_irqsave(&slob_lock, flags);
    
    prev = slobfree;
    // 遍历空闲链表 (First-Fit 首次适应算法)
    for (cur = prev->next;; prev = cur, cur = cur->next)
    {
        // 1. 处理对齐
        if (align)
        {
            // 计算当前块地址 cur 向上对齐后的地址
            aligned = (slob_t *)ALIGN((unsigned long)cur, align);
            // 计算对齐带来的偏移量 (需要跳过多少字节)
            delta = aligned - cur;
        }
        
        // 2. 检查当前块是否足够大 (包含数据所需的 units 和对齐所需的 delta)
        if (cur->units >= units + delta)
        { /* 空间足够? */
            
            // 如果需要对齐，且有偏移量
            if (delta)
            { /* 需要切分头部以满足对齐? */
                // 将对齐产生的空隙变成一个新的独立空闲块
                aligned->units = cur->units - delta; // 剩余部分的大小
                aligned->next = cur->next;           // 链接
                cur->next = aligned;                 // 插入链表
                cur->units = delta;                  // 头部碎片的大小
                prev = cur;                          // 更新 prev 指针
                cur = aligned;                       // cur 指向对齐后的有效起始位置
            }

            // 3. 决定是“完全占用”还是“切分剩余”
            if (cur->units == units)    /* 大小正好匹配? */
                prev->next = cur->next; /* 从空闲链表中移除 (Unlink) */
            else
            { /* 块比需求大，进行切分 (Fragment) */
                // prev->next 指向剩余的空闲部分 (cur + units)
                // 这里实际上是修改了链表，跳过了即将被分配出去的前半部分
                prev->next = cur + units;
                // 设置剩余部分的大小
                prev->next->units = cur->units - units;
                // 维持链表连接
                prev->next->next = cur->next;
                // 设置当前分配块的大小 (这将被记录在分配出的内存块头部)
                cur->units = units;
            }

            // 更新全局空闲链表指针，下次分配从这里开始查找 (优化查找速度)
            slobfree = prev;
            spin_unlock_irqrestore(&slob_lock, flags);
            return cur; // 返回分配的块地址
        }
        
        // 4. 如果遍历了一圈回到了起点 (或者链表为空时)，说明当前空闲链表中没有合适的块
        if (cur == slobfree)
        {
            spin_unlock_irqrestore(&slob_lock, flags); // 暂时开中断，因为申请页面可能耗时

            if (size == PAGE_SIZE) /* 如果请求正好是一页，不尝试扩展 arena */
                return 0;

            // 向底层 PMM 申请一个新的物理页
            cur = (slob_t *)__slob_get_free_page(gfp);
            if (!cur)
                return 0; // 内存耗尽

            // 将新页作为一个大的空闲块释放到 SLOB 管理器中
            // 这会自动将其合并到空闲链表里
            slob_free(cur, PAGE_SIZE);
            
            // 重新加锁，重置搜索指针，再次尝试分配
            spin_lock_irqsave(&slob_lock, flags);
            cur = slobfree;
        }
    }
}

// slob_free - 释放内存块
// block: 要释放的内存块地址
// size: 释放的大小 (如果是 0，则从 block->units 读取)
static void slob_free(void *block, int size)
{
    slob_t *cur, *b = (slob_t *)block;
    unsigned long flags;

    if (!block)
        return;

    // 如果指定了大小，则更新块头部的 units
    if (size)
        b->units = SLOB_UNITS(size);

    /* 寻找重新插入点 */
    spin_lock_irqsave(&slob_lock, flags);
    
    // 遍历链表，找到合适的插入位置，保持链表按地址顺序排列
    // 循环条件解释：
    // !(b > cur && b < cur->next) 表示还没有找到 b 应该在的位置 (即 cur < b < cur->next)
    // 同时要处理链表末尾回绕的情况
    for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
        if (cur >= cur->next && (b > cur || b < cur->next))
            break; // 找到了列表的断点 (末尾和头部的交界处)，且 b 就在这里

    // 尝试与后一个块合并
    // 如果 b 的结束地址等于下一个块的起始地址
    if (b + b->units == cur->next)
    {
        b->units += cur->next->units; // 合并大小
        b->next = cur->next->next;    // 跳过下一个块
    }
    else
        b->next = cur->next;          // 否则只是链接

    // 尝试与前一个块合并
    // 如果当前块 cur 的结束地址等于 b 的起始地址
    if (cur + cur->units == b)
    {
        cur->units += b->units;       // 合并大小
        cur->next = b->next;          // cur 直接指向 b 的下一个
    }
    else
        cur->next = b;                // 否则将 b 链接在 cur 后面

    // 更新全局指针，指向刚刚释放/合并的位置，利用局部性原理
    slobfree = cur;

    spin_unlock_irqrestore(&slob_lock, flags);
}

// slob_init - 初始化 SLOB 分配器
void slob_init(void)
{
    cprintf("use SLOB allocator\n");
}

// kmalloc_init - 初始化 kmalloc (实际上就是初始化 slob)
inline void
kmalloc_init(void)
{
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}

// 统计函数 (未实现)
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

// find_order - 计算 size 需要 2 的多少次幂的页
static int find_order(int size)
{
    int order = 0;
    for (; size > 4096; size >>= 1)
        order++;
    return order;
}

// __kmalloc - kmalloc 的内部实现
static void *__kmalloc(size_t size, gfp_t gfp)
{
    slob_t *m;
    bigblock_t *bb;
    unsigned long flags;

    // 情况 1: 小内存分配
    // 如果请求大小小于一页 (减去头部元数据大小)
    if (size < PAGE_SIZE - SLOB_UNIT)
    {
        // 调用 slob_alloc 分配，多分配一个单元用于存储头部信息
        m = slob_alloc(size + SLOB_UNIT, gfp, 0);
        // 返回跳过头部的指针 (用户实际可用的内存地址)
        return m ? (void *)(m + 1) : 0;
    }

    // 情况 2: 大内存分配 (大于等于一页)
    // 首先分配一个 bigblock_t 结构体来记录这次分配的元数据
    bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
    if (!bb)
        return 0;

    // 计算需要多少阶的页
    bb->order = find_order(size);
    // 直接向底层 PMM 申请连续物理页
    bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);

    if (bb->pages)
    {
        // 将这个大块记录添加到全局 bigblocks 链表中
        spin_lock_irqsave(&block_lock, flags);
        bb->next = bigblocks;
        bigblocks = bb;
        spin_unlock_irqrestore(&block_lock, flags);
        return bb->pages;
    }

    // 如果页分配失败，释放刚才分配的元数据块
    slob_free(bb, sizeof(bigblock_t));
    return 0;
}

// kmalloc - 内核内存分配公开接口
void *
kmalloc(size_t size)
{
    return __kmalloc(size, 0);
}

// kfree - 内核内存释放公开接口
void kfree(void *block)
{
    bigblock_t *bb, **last = &bigblocks;
    unsigned long flags;

    if (!block)
        return;

    // 检查地址是否页对齐
    // 如果地址是页对齐的 (低 12 位为 0)，那么它可能是一个大块分配
    if (!((unsigned long)block & (PAGE_SIZE - 1)))
    {
        /* 可能在大块链表中 */
        spin_lock_irqsave(&block_lock, flags);
        // 遍历大块链表寻找匹配的地址
        for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
        {
            if (bb->pages == block)
            {
                // 找到了，从链表中移除
                *last = bb->next;
                spin_unlock_irqrestore(&block_lock, flags);
                // 释放实际的物理页
                __slob_free_pages((unsigned long)block, bb->order);
                // 释放记录该大块信息的元数据块
                slob_free(bb, sizeof(bigblock_t));
                return;
            }
        }
        spin_unlock_irqrestore(&block_lock, flags);
    }

    // 如果不是大块，则是普通的 SLOB 块
    // block 指向的是用户数据区，需要回退一个单元找到头部信息 (slob_t)
    // 这里的 0 表示让 slob_free 自动从头部读取大小
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

    // 同样先检查是否是大块
    if (!((unsigned long)block & (PAGE_SIZE - 1)))
    {
        spin_lock_irqsave(&block_lock, flags);
        for (bb = bigblocks; bb; bb = bb->next)
            if (bb->pages == block)
            {
                spin_unlock_irqrestore(&slob_lock, flags);
                return PAGE_SIZE << bb->order;
            }
        spin_unlock_irqrestore(&block_lock, flags);
    }

    // 对于小块，读取头部的 units 字段并转换为字节
    return ((slob_t *)block - 1)->units * SLOB_UNIT;
}