#ifndef __KERN_MM_MEMLAYOUT_H__
#define __KERN_MM_MEMLAYOUT_H__

/* 此文件包含我们操作系统中内存管理的定义。 */

/* *
 * Virtual memory map:                                          Permissions
 * kernel/user
 *
 * 4G ------------------> +---------------------------------+
 * |                                 |
 * |         Empty Memory (*)        |
 * |                                 |
 * +---------------------------------+ 0xFB000000
 * |   Cur. Page Table (Kern, RW)    | RW/-- PTSIZE
 * VPT -----------------> +---------------------------------+ 0xFAC00000
 * |        Invalid Memory (*)       | --/--
 * KERNTOP -------------> +---------------------------------+ 0xF8000000
 * |                                 |
 * |    Remapped Physical Memory     | RW/-- KMEMSIZE
 * |                                 |
 * KERNBASE ------------> +---------------------------------+ 0xC0000000 (RISC-V中是0xFFFFFFFFC0200000)
 * |                                 |
 * |                                 |
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * (*) 注意: 内核确保 "Invalid Memory" 永远不会被映射。
 * "Empty Memory" 通常未映射，但用户程序如果需要可以在那里映射页面。
 *
 * [RISC-V ucore 内存布局解析]
 * 虽然上面的 ASCII 图是基于 x86 32位的经典布局，但在 RISC-V 64位版本中，
 * ucore 采用了类似的线性映射策略，但地址范围有所不同。
 *
 * 1. 物理内存直接映射区 (Direct Mapping / Linear Mapping):
 * - KERNBASE: 内核虚拟地址的起始点。
 * - KMEMSIZE: 内核直接管理的物理内存最大大小。
 * - KERNTOP:  内核直接映射区的结束点。
 * - 这段区域虚拟地址 = 物理地址 + 偏移量。
 *
 * 2. 虚拟页表 (VPT):
 * - 用于自映射页表，方便内核直接访问页表内容 (Lab 2 以后可能会用到)。
 * */

/* 所有物理内存都映射到这个地址 */
// KERNBASE: 内核基地址。这是内核代码和数据段开始的地方。
// 在 Sv39 模式下，这是高 2GB 虚拟地址空间的一部分。
#define KERNBASE            0xFFFFFFFFC0200000

// KMEMSIZE: 物理内存的最大映射大小 (126MB)。
// 这限制了 ucore 能直接管理的物理内存大小。
#define KMEMSIZE            0x7E00000                  // the maximum amount of physical memory

// KERNTOP: 内核直接映射区的顶部。
#define KERNTOP             (KERNBASE + KMEMSIZE)

// PHYSICAL_MEMORY_OFFSET: 物理内存偏移量。
// 这是一个非常重要的常量。
// 物理地址 PA + PHYSICAL_MEMORY_OFFSET = 内核虚拟地址 VA
// 例如：物理地址 0x80200000 (RAM起始) -> 虚拟地址 0xFFFFFFFFC0200000
#define PHYSICAL_MEMORY_OFFSET      0xFFFFFFFF40000000


// 内核栈设置
#define KSTACKPAGE          2                           // 内核栈使用的页数 (2页 = 8KB)
#define KSTACKSIZE          (KSTACKPAGE * PGSIZE)       // 内核栈的总大小

#ifndef __ASSEMBLER__

#include <defs.h>
#include <atomic.h>
#include <list.h>

// 类型定义：为了代码可读性，定义页表项和页目录项的类型
typedef uintptr_t pte_t;
typedef uintptr_t pde_t;
typedef pte_t swap_entry_t; // 页表项也可以存储交换条目 (Swap Entry)

/* *
 * struct Page - 页面描述符结构体。
 * 每个 Page 结构体描述一个物理页 (Physical Page Frame)。
 * 在 kern/mm/pmm.h 中，你可以找到很多有用的函数将 Page 转换为其他数据类型，如物理地址。
 * * [重要]: 这个结构体是物理内存管理的核心。系统启动时，会为每一个物理页分配一个 Page 结构体。
 * 所有的 Page 结构体存储在一个全局数组 `pages` 中。
 * */
struct Page {
    int ref;                        // page frame's reference counter
                                    // 页面引用计数：
                                    // 0 表示该页空闲。
                                    // >0 表示该页被占用，数值表示有多少个地方引用了它 (例如多个进程共享同一物理页)。

    uint_t flags;                   // array of flags that describe the status of the page frame
                                    // 标志位数组：描述页面的状态 (如是否保留、是否为属性页等)。
                                    // 具体的位定义见下方 PG_reserved, PG_property。

    unsigned int property;          // the num of free block, used in first fit pm manager
                                    // 空闲块属性：仅在 PG_property=1 时有效。
                                    // 如果这个页是一个空闲块的头页 (Head Page)，property 记录了这个块包含的连续空闲页数。
                                    // 例如，如果这是一个 4页大小的空闲块的头，property = 4。

    list_entry_t page_link;         // free list link
                                    // 空闲链表链接：
                                    // 如果该页空闲，它通过这个链表节点挂在 `free_area_t` 的空闲链表中。

    list_entry_t pra_page_link;     // used for pra (page replace algorithm)
                                    // 页面置换算法链接：
                                    // 用于将已分配的页面链接起来，供页面置换算法 (如 Clock, FIFO) 遍历和选择换出页面。

    uintptr_t pra_vaddr;            // used for pra (page replace algorithm)
                                    // 记录该物理页对应的虚拟地址，用于页面置换时查找对应的 PTE。
};

/* Flags describing the status of a page frame */
/* 描述页帧状态的标志位定义 */

// PG_reserved: 保留位
// 如果 bit=1: 表示该页被内核保留 (例如内核代码段、页表本身占用的页)，不能用于 alloc/free_pages。
// 如果 bit=0: 表示该页可以被动态分配。
#define PG_reserved                 0       // if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0 

// PG_property: 属性位
// 如果 bit=1: 表示该页是一个空闲内存块的**头页** (Head Page)，并且 property 字段有效。
// 如果 bit=0: 表示该页不是头页，或者该页已经被分配出去了。
#define PG_property                 1       // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.

// [位操作宏]
// 使用原子操作或位运算来设置、清除和测试标志位。

// 设置保留位 (标记为保留)
#define SetPageReserved(page)       set_bit(PG_reserved, &((page)->flags))
// 清除保留位 (标记为非保留)
#define ClearPageReserved(page)     clear_bit(PG_reserved, &((page)->flags))
// 测试保留位 (检查是否保留)
#define PageReserved(page)          test_bit(PG_reserved, &((page)->flags))

// 设置属性位 (标记为空闲块头页)
#define SetPageProperty(page)       set_bit(PG_property, &((page)->flags))
// 清除属性位
#define ClearPageProperty(page)     clear_bit(PG_property, &((page)->flags))
// 测试属性位
#define PageProperty(page)          test_bit(PG_property, &((page)->flags))

// convert list entry to page
// 宏：将链表节点 list_entry_t 转换为 struct Page 指针
#define le2page(le, member)                 \
    to_struct((le), struct Page, member)

/* free_area_t - maintains a doubly linked list to record free (unused) pages */
/* free_area_t - 维护一个双向链表来记录空闲 (未使用) 的页面 */
// 这是物理内存管理器 (pmm_manager) 用来管理空闲内存的核心结构。
typedef struct {
    list_entry_t free_list;         // the list header
                                    // 空闲链表头：连接所有空闲内存块的头页 (Head Page)。
                                    
    unsigned int nr_free;           // # of free pages in this free list
                                    // 空闲页总数：链表中所有空闲块包含的页面总和。
} free_area_t;

#endif /* !__ASSEMBLER__ */

#endif /* !__KERN_MM_MEMLAYOUT_H__ */