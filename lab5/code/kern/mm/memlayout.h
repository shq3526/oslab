#ifndef __KERN_MM_MEMLAYOUT_H__
#define __KERN_MM_MEMLAYOUT_H__

/* This file contains the definitions for memory management in our OS. */

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
 * KERNBASE ------------> +---------------------------------+ 0xC0000000
 * |        Invalid Memory (*)       | --/--
 * USERTOP -------------> +---------------------------------+ 0xB0000000
 * |          User stack             |
 * +---------------------------------+
 * |                                 |
 * :                                 :
 * |         ~~~~~~~~~~~~~~~~        |
 * :                                 :
 * |                                 |
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * |       User Program & Heap       |
 * UTEXT ---------------> +---------------------------------+ 0x00800000
 * |        Invalid Memory (*)       | --/--
 * |  - - - - - - - - - - - - - - -  |
 * |    User STAB Data (optional)    |
 * USERBASE, USTAB------> +---------------------------------+ 0x00200000
 * |        Invalid Memory (*)       | --/--
 * 0 -------------------> +---------------------------------+ 0x00000000
 * (*) Note: The kernel ensures that "Invalid Memory" is *never* mapped.
 * "Empty Memory" is normally unmapped, but user programs may map pages
 * there if desired.
 *
 * [Memory Layout Interpretation / 内存布局解读]:
 * 1. KERNBASE (0xC0000000) 以上是内核空间，只有内核态 (Supervisor Mode) 可以访问。
 * 这里使用了“线性映射”，即虚拟地址 = 物理地址 + 偏移量。
 * 2. USERTOP (0x80000000) 以下是用户空间，用户态 (User Mode) 可以访问。
 * 3. USTACKTOP (== USERTOP) 是用户栈的栈底，栈向低地址增长。
 * 4. UTEXT (0x00800000) 是用户程序的入口地址 (Linker Script user.ld 中定义)。
 * */

/* [Kernel Space Definitions] */
/* All physical memory mapped at this address */
// 内核虚拟地址的基准。在 uCore 中，物理地址 0x80200000 映射到虚拟地址 0xFFFFFFFFC0200000 (SV39)
#define KERNBASE 0xFFFFFFFFC0200000
// 内核管理的物理内存最大值 (约 126MB)
#define KMEMSIZE 0x7E00000 // the maximum amount of physical memory
// 内核空间顶部
#define KERNTOP (KERNBASE + KMEMSIZE)

// 物理内存偏移量 (用于 pa2kva 和 kva2pa 转换)
#define PHYSICAL_MEMORY_OFFSET 0xFFFFFFFF40000000

/* *
 * Virtual page table. Entry PDX[VPT] in the PD (Page Directory) contains
 * a pointer to the page directory itself, thereby turning the PD into a page
 * table, which maps all the PTEs (Page Table Entry) containing the page mappings
 * for the entire virtual address space into that 4 Meg region starting at VPT.
 * [注意]：这是 x86 时代的遗留注释技巧 (自映射)，在 RISC-V SV39 中机制略有不同，但概念类似。
 * */

// [Kernel Stack]
// 内核栈大小定义。每个进程/线程都有自己的内核栈。
#define KSTACKPAGE 2                     // # of pages in kernel stack (2页)
#define KSTACKSIZE (KSTACKPAGE * PGSIZE) // sizeof kernel stack (8KB)

/* [User Space Definitions] - Lab 5 核心部分 */
// 用户空间顶端 (2GB)
#define USERTOP 0x80000000
// 用户栈顶 (栈向下增长)
#define USTACKTOP USERTOP
// 用户栈最大大小 (256页 = 1MB)
#define USTACKPAGE 256                   // # of pages in user stack
#define USTACKSIZE (USTACKPAGE * PGSIZE) // sizeof user stack

// 用户程序加载基址 (Lab 5 中其实 binary 直接链接在内核里，copy 到这里)
#define USERBASE 0x00200000
// 用户代码段起始地址 (text segment)
#define UTEXT 0x00800000 // where user programs generally begin
// 用户调试信息起始地址
#define USTAB USERBASE   // the location of the user STABS data structure

// 宏：检查地址范围是否在用户空间
#define USER_ACCESS(start, end) \
    (USERBASE <= (start) && (start) < (end) && (end) <= USERTOP)

// 宏：检查地址范围是否在内核空间
#define KERN_ACCESS(start, end) \
    (KERNBASE <= (start) && (start) < (end) && (end) <= KERNTOP)

#ifndef __ASSEMBLER__

#include <defs.h>
#include <atomic.h>
#include <list.h>

typedef uintptr_t pte_t; // Page Table Entry
typedef uintptr_t pde_t; // Page Directory Entry
typedef pte_t swap_entry_t; // Swap Entry (Lab 6 使用)

/* *
 * struct Page - 物理页描述符
 * * [重要]: 操作系统管理物理内存的核心结构。
 * 物理内存被划分为 4KB 的页帧 (Page Frame)，每一个页帧对应一个 `struct Page`。
 * 所有的 struct Page 存放在 `pages` 全局数组中。
 * */
struct Page
{
    int ref;                        // 引用计数 (Reference Counter)
                                    // 记录有多少个虚拟页映射到了这个物理页。
                                    // 0: 空闲页
                                    // 1: 被一个进程使用
                                    // >1: 被多个进程共享 (例如 fork 后的 COW 页，或共享库)
                                    // [Lab 5 COW]: 这是实现 Copy-on-Write 的关键。
    
    uint64_t flags;                 // 标志位 (Reserved, Property 等)
    
    unsigned int property;          // 空闲块大小 (仅用于 First-Fit 分配器中的空闲块头页)
                                    // 如果这个页是空闲块的第一页，记录块里有多少页。
    
    list_entry_t page_link;         // 链接到空闲链表 (free_list)
    
    list_entry_t pra_page_link;     // 页面置换算法 (Page Replacement Algorithm) 链表节点 (Lab 6)
    uintptr_t pra_vaddr;            // 被换出页对应的虚拟地址 (Lab 6)
};

/* Flags describing the status of a page frame */
// PG_reserved: 保留页 (内核代码段、数据段占用的物理页，不可用于分配)
#define PG_reserved 0 // if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0
// PG_property: 空闲块头页标志 (First-Fit 算法使用)
#define PG_property 1 // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.

// 位操作宏：设置、清除、测试页标志
#define SetPageReserved(page) set_bit(PG_reserved, &((page)->flags))
#define ClearPageReserved(page) clear_bit(PG_reserved, &((page)->flags))
#define PageReserved(page) test_bit(PG_reserved, &((page)->flags))
#define SetPageProperty(page) set_bit(PG_property, &((page)->flags))
#define ClearPageProperty(page) clear_bit(PG_property, &((page)->flags))
#define PageProperty(page) test_bit(PG_property, &((page)->flags))

// 辅助宏：将链表节点转换为 Page 结构体指针
#define le2page(le, member) \
    to_struct((le), struct Page, member)

/* free_area_t - 物理内存管理器使用的空闲列表结构 */
typedef struct
{
    list_entry_t free_list; // 双向链表头，链接所有空闲的 Page
    unsigned int nr_free;   // 当前空闲页的总数
} free_area_t;

#endif /* !__ASSEMBLER__ */

#endif /* !__KERN_MM_MEMLAYOUT_H__ */