#ifndef __KERN_MM_PMM_H__
#define __KERN_MM_PMM_H__

#include <defs.h>
#include <mmu.h>
#include <memlayout.h>
#include <atomic.h>
#include <assert.h>

/* do_fork 使用的克隆标志 (Clone Flags) */
#define CLONE_VM 0x00000100     // set if VM shared between processes
                                // 如果设置，子进程共享父进程的虚拟内存空间 (即 mm_struct)。
                                // 这通常用于创建线程 (Thread)，线程间共享代码段、数据段和堆。
                                
#define CLONE_THREAD 0x00000200 // thread group
                                // 如果设置，将子进程加入到父进程的线程组中。

// pmm_manager 是物理内存管理类 (接口定义)。
// 一个具体的 pmm manager (例如 default_pmm_manager) 只需要实现
// pmm_manager 类中定义的方法，ucore 就可以使用它来管理整个物理内存空间。
// 这是一种在 C 语言中实现面向对象"多态"特性的常见手法。
struct pmm_manager
{
    const char *name;                                 // 物理内存管理器的名称 (如 "default_pmm_manager")
    
    void (*init)(void);                               // 初始化内部描述和管理数据结构
                                                      // (例如：初始化空闲块链表，重置空闲块计数)
                                                      
    void (*init_memmap)(struct Page *base, size_t n); // 根据初始的空闲物理内存空间设置描述和管理数据结构
                                                      // base: 这块连续内存的起始 Page 结构体
                                                      // n: 页面的数量
                                                      
    struct Page *(*alloc_pages)(size_t n);            // 分配 >= n 个连续物理页
                                                      // 具体实现取决于分配算法 (First Fit, Best Fit 等)
                                                      
    void (*free_pages)(struct Page *base, size_t n);  // 释放 >= n 个物理页
                                                      // base: 要释放的内存块的起始 Page 结构体地址
                                                      
    size_t (*nr_free_pages)(void);                    // 返回当前系统中空闲页面的总数
    
    void (*check)(void);                              // 用于检查/验证分配器正确性的测试函数
};

// 外部全局变量声明
extern const struct pmm_manager *pmm_manager; // 指向当前正在使用的物理内存管理器
extern pde_t *boot_pgdir_va;                  // 启动时页目录表 (PDT) 的虚拟地址
extern const size_t nbase;                    // 物理内存起始地址 (0x80000000) 对应的 Page 数组索引偏移
extern uintptr_t boot_pgdir_pa;               // 启动时页目录表 (PDT) 的物理地址

void pmm_init(void); // 物理内存管理初始化入口

// 物理页分配的全局包装函数 (内部调用 pmm_manager->alloc_pages)
struct Page *alloc_pages(size_t n);
// 物理页释放的全局包装函数
void free_pages(struct Page *base, size_t n);
// 获取空闲页数量
size_t nr_free_pages(void);

// 辅助宏：分配/释放单个页面
#define alloc_page() alloc_pages(1)
#define free_page(page) free_pages(page, 1)

// --- 页表管理相关函数 ---

// 根据虚拟地址 la 获取对应的页表项 (PTE) 指针
// 如果页表不存在且 create=true，则会分配新的页表页
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create);

// 根据虚拟地址 la 获取对应的 Page 结构体
// 可选地通过 ptep_store 返回对应的 PTE 指针
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store);

// 取消虚拟地址 la 的映射，并释放相关的物理页
void page_remove(pde_t *pgdir, uintptr_t la);

// 建立虚拟地址 la 到物理页 page 的映射关系，并设置权限 perm
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm);

// 刷新 TLB (Translation Lookaside Buffer)
// 当页表被修改后，CPU 缓存的地址转换可能失效，必须调用此函数通知 CPU
void tlb_invalidate(pde_t *pgdir, uintptr_t la);

// 辅助函数：在页目录中分配一个页表页
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm);

void print_pgdir(void); // 打印页表结构 (调试用)

/* *
 * PADDR - 接收一个内核虚拟地址 (指向 KERNBASE 之上的地址)，
 * 该地址映射了机器的最大 256MB 物理内存，并返回对应的物理地址。
 * 如果传入非内核虚拟地址，它会 panic。
 * * 原理: 线性映射 (Direct Mapping / Linear Mapping)
 * 在 ucore 中，物理地址 (0x80000000) 被直接线性映射到内核虚拟地址 (0xFFFFFFFFC0000000)。
 * 它们之间只差一个固定的偏移量 va_pa_offset。
 * */
#define PADDR(kva)                                                     \
    ({                                                                 \
        uintptr_t __m_kva = (uintptr_t)(kva);                          \
        if (__m_kva < KERNBASE)                                        \
        {                                                              \
            panic("PADDR called with invalid kva %08lx", __m_kva);     \
        }                                                              \
        __m_kva - va_pa_offset;                                        \
    })

/* *
 * KADDR - 接收一个物理地址并返回对应的内核虚拟地址。
 * 如果传入无效的物理地址，它会 panic。
 * */
#define KADDR(pa)                                                      \
    ({                                                                 \
        uintptr_t __m_pa = (pa);                                       \
        size_t __m_ppn = PPN(__m_pa);                                  \
        if (__m_ppn >= npage)                                          \
        {                                                              \
            panic("KADDR called with invalid pa %08lx", __m_pa);       \
        }                                                              \
        (void *)(__m_pa + va_pa_offset);                               \
    })

extern struct Page *pages; // 指向管理所有物理页的 Page 结构体数组
extern size_t npage;       // 物理内存的总页数
extern uint_t va_pa_offset;// 虚拟地址与物理地址的偏移量

// --- Page 结构体与物理地址转换函数 ---

// 将 Page 结构体转换为物理页帧号 (PPN - Physical Page Number)
// 原理：pages 数组的索引对应物理内存的第几个页
static inline ppn_t
page2ppn(struct Page *page)
{
    // (当前 Page 指针 - 数组起始地址) = 数组索引
    // nbase 是物理内存起始地址 (0x80000000) 对应的页号偏移
    return page - pages + nbase;
}

// 将 Page 结构体转换为物理地址 (Physical Address)
static inline uintptr_t
page2pa(struct Page *page)
{
    // PPN 左移 12 位 (乘以 4096) 得到物理地址
    return page2ppn(page) << PGSHIFT;
}

// 将物理地址转换为对应的 Page 结构体
static inline struct Page *
pa2page(uintptr_t pa)
{
    if (PPN(pa) >= npage)
    {
        panic("pa2page called with invalid pa");
    }
    // PPN(pa) 获取页号，减去基准页号 nbase，得到 pages 数组下标
    return &pages[PPN(pa) - nbase];
}

// 将 Page 结构体转换为内核虚拟地址 (Kernel Virtual Address)
static inline void *
page2kva(struct Page *page)
{
    return KADDR(page2pa(page));
}

// 将内核虚拟地址转换为对应的 Page 结构体
static inline struct Page *
kva2page(void *kva)
{
    return pa2page(PADDR(kva));
}

// 将页表项 (PTE) 的值转换为它所指向的物理页的 Page 结构体
static inline struct Page *
pte2page(pte_t pte)
{
    if (!(pte & PTE_V))
    {
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte)); // PTE_ADDR 宏用于从 PTE 中提取 PPN
}

// 将页目录项 (PDE) 的值转换为它所指向的页表页的 Page 结构体
static inline struct Page *
pde2page(pde_t pde)
{
    return pa2page(PDE_ADDR(pde));
}

// --- 引用计数操作 ---
// page->ref 用于记录有多少个虚拟页映射到了这个物理页。
// 当 ref 降为 0 时，物理页可以被释放。

static inline int
page_ref(struct Page *page)
{
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
}

static inline int
page_ref_inc(struct Page *page)
{
    page->ref += 1;
    return page->ref;
}

static inline int
page_ref_dec(struct Page *page)
{
    page->ref -= 1;
    return page->ref;
}

// 刷新 TLB (Translation Lookaside Buffer)
// 使用 RISC-V 的 sfence.vma 指令。
// 这会清空处理器的地址转换缓存，强制 CPU 下次访问内存时重新查页表。
static inline void flush_tlb()
{
    asm volatile("sfence.vma");
}

// 构造 PTE (页表项)
// ppn: 物理页帧号
// type: 权限位 (如 PTE_R, PTE_W, PTE_X, PTE_U)
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    // 将 PPN 移到正确位置，并加上有效位 PTE_V 和权限位
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
}

// 构造 PTD (页目录项)
// 指向下一级页表，通常只需要 PTE_V 有效位
static inline pte_t ptd_create(uintptr_t ppn)
{
    return pte_create(ppn, PTE_V);
}

// 启动时的临时栈 (在 entry.S 中定义)
extern char bootstack[], bootstacktop[];

#endif /* !__KERN_MM_PMM_H__ */