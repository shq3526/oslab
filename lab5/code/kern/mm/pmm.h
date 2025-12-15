#ifndef __KERN_MM_PMM_H__
#define __KERN_MM_PMM_H__

// 引入基本定义，如类型定义等
#include <defs.h>
// 引入内存管理单元(MMU)相关的硬件定义
#include <mmu.h>
// 引入内存布局相关的定义，如 KERNBASE 等
#include <memlayout.h>
// 引入原子操作定义
#include <atomic.h>
// 引入断言宏
#include <assert.h>

// pmm_manager is a physical memory management class. A special pmm manager - XXX_pmm_manager
// only needs to implement the methods in pmm_manager class, then XXX_pmm_manager can be used
// by ucore to manage the total physical memory space.
// pmm_manager 是物理内存管理器的抽象结构体（类似于面向对象中的接口或虚基类）。
// 具体的分配算法（如 First Fit, Best Fit）只需要实现这些函数指针。
struct pmm_manager
{
    // 物理内存管理器的名称（例如 "default_pmm_manager"）
    const char *name;
    
    // 初始化函数指针：初始化管理器的内部数据结构
    // 例如：初始化空闲链表头节点，重置空闲页计数器
    void (*init)(void);
    
    // 内存映射初始化函数指针：将一段空闲内存加入到管理器中
    // 参数 base: 空闲块的第一个 Page 结构体
    // 参数 n: 空闲块包含的页数
    void (*init_memmap)(struct Page *base, size_t n);
    
    // 分配页函数指针：请求分配 n 个连续的物理页
    // 返回值: 分配到的第一个页面的 Page 结构体指针，失败返回 NULL
    struct Page *(*alloc_pages)(size_t n);
    
    // 释放页函数指针：释放从 base 开始的 n 个连续物理页
    void (*free_pages)(struct Page *base, size_t n);
    
    // 获取空闲页数函数指针：返回当前系统总的空闲页数量
    size_t (*nr_free_pages)(void);
    
    // 检查函数指针：用于运行自检测试，验证分配器逻辑是否正确
    void (*check)(void);
};

// 外部引用的全局变量：指向当前使用的物理内存管理器实例
extern const struct pmm_manager *pmm_manager;
// 外部引用的全局变量：启动时的页目录表（一级页表）的虚拟地址
extern pde_t *boot_pgdir_va;
// 外部引用的全局变量：物理内存起始地址对应的页帧号（DRAM_BASE / PGSIZE）
extern const size_t nbase;
// 外部引用的全局变量：启动时的页目录表的物理地址
extern uintptr_t boot_pgdir_pa;

// 物理内存管理初始化函数（在 pmm.c 中实现）
void pmm_init(void);

// 核心分配函数：分配 n 个物理页
struct Page *alloc_pages(size_t n);
// 核心释放函数：释放 n 个物理页
void free_pages(struct Page *base, size_t n);
// 获取当前空闲页总数
size_t nr_free_pages(void);

// 宏定义：分配单个页面的便捷宏，实际上调用 alloc_pages(1)
#define alloc_page() alloc_pages(1)
// 宏定义：释放单个页面的便捷宏，实际上调用 free_pages(page, 1)
#define free_page(page) free_pages(page, 1)

// 获取页表项 (Page Table Entry)
// 参数 pgdir: 页目录基址
// 参数 la: 线性地址 (Linear Address / Virtual Address)
// 参数 create: 如果中间页表不存在，是否创建
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create);

// 获取线性地址对应的 Page 结构体
// 参数 ptep_store: 如果不为NULL，用于存储找到的 PTE 的地址
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store);

// 移除线性地址 la 的映射（解除映射并可能释放物理页）
void page_remove(pde_t *pgdir, uintptr_t la);

// 建立映射：将物理页 page 映射到线性地址 la，权限为 perm
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm);

// 加载页表基址到硬件寄存器（如 x86 的 cr3，RISC-V 的 satp）- 这里的命名 load_esp0 可能源自 x86 遗留，但在 RISC-V 中通常涉及上下文切换
void load_esp0(uintptr_t esp0);

// 刷新 TLB (Translation Lookaside Buffer)
void tlb_invalidate(pde_t *pgdir, uintptr_t la);

// 分配一个物理页并将其映射到指定线性地址（通常用于给页表自身分配空间）
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm);

// 取消一段地址范围的映射 [start, end)
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end);

// 退出进程时释放一段地址范围的页表和页面
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end);

// 复制一段内存映射（用于 fork），可选择是否共享内存（Copy on Write）
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share);

// 打印页目录表信息（调试用）
void print_pgdir(void);

/* *
 * PADDR - takes a kernel virtual address (an address that points above KERNBASE),
 * where the machine's maximum 256MB of physical memory is mapped and returns the
 * corresponding physical address.  It panics if you pass it a non-kernel virtual address.
 * */
// PADDR 宏：将内核虚拟地址 (KVA) 转换为物理地址 (PA)
// 仅适用于线性映射区域（即 KERNBASE 之上的地址）
#define PADDR(kva)                                                 \
    ({                                                             \
        uintptr_t __m_kva = (uintptr_t)(kva);                      \
        /* 检查是否是合法的内核虚拟地址 */                          \
        if (__m_kva < KERNBASE)                                    \
        {                                                          \
            panic("PADDR called with invalid kva %08lx", __m_kva); \
        }                                                          \
        /* 减去线性偏移量得到物理地址 */                            \
        __m_kva - va_pa_offset;                                    \
    })

/* *
 * KADDR - takes a physical address and returns the corresponding kernel virtual
 * address. It panics if you pass an invalid physical address.
 * */
// KADDR 宏：将物理地址 (PA) 转换为内核虚拟地址 (KVA)
// 仅适用于物理内存范围内的地址
#define KADDR(pa)                                                \
    ({                                                           \
        uintptr_t __m_pa = (pa);                                 \
        /* 获取物理页帧号 (PPN) */                                \
        size_t __m_ppn = PPN(__m_pa);                            \
        /* 检查页帧号是否超出物理内存范围 */                       \
        if (__m_ppn >= npage)                                    \
        {                                                        \
            panic("KADDR called with invalid pa %08lx", __m_pa); \
        }                                                        \
        /* 加上线性偏移量得到虚拟地址 */                           \
        (void *)(__m_pa + va_pa_offset);                         \
    })

// 外部引用的全局变量：所有物理页的 Page 结构体数组（类似于 Linux 的 mem_map）
extern struct Page *pages;
// 外部引用的全局变量：物理内存的总页数
extern size_t npage;
// 外部引用的全局变量：虚拟地址与物理地址的偏移量 (KERNBASE - DRAM_BASE)
extern uint_t va_pa_offset;

// page2ppn - 将 Page 结构体指针转换为物理页帧号 (Physical Page Number)
static inline ppn_t
page2ppn(struct Page *page)
{
    // 通过指针减法计算数组索引，再加上物理内存起始页号 (nbase)
    return page - pages + nbase;
}

// page2pa - 将 Page 结构体指针转换为物理地址 (Physical Address)
static inline uintptr_t
page2pa(struct Page *page)
{
    // 物理地址 = 页帧号 << 12 (4KB页面)
    return page2ppn(page) << PGSHIFT;
}

// pa2page - 将物理地址转换为对应的 Page 结构体指针
static inline struct Page *
pa2page(uintptr_t pa)
{
    // 检查物理页号是否越界
    if (PPN(pa) >= npage)
    {
        panic("pa2page called with invalid pa");
    }
    // 获取页结构体：索引为 (当前页号 - 起始页号)
    return &pages[PPN(pa) - nbase];
}

// page2kva - 将 Page 结构体指针转换为内核虚拟地址
// 作用：根据 struct Page 结构体指针，计算出该物理页对应的内核虚拟地址。

// 原理：

// uCore 中，物理内存是线性映射到内核高地址空间的。

// page2pa(page)：先算出物理地址（根据 page 在 pages 数组中的下标）。

// KADDR(pa)：物理地址 + 偏移量（0xFFFFFFFFC0000000 左右） = 内核虚拟地址。

// 为什么需要它：CPU 开启分页后，内核无法直接操作物理地址，必须通过虚拟地址访问内存（比如 memcpy 时）。

static inline void *
page2kva(struct Page *page)
{
    // 先转为物理地址，再调用 KADDR 转为虚拟地址
    return KADDR(page2pa(page));
}

// kva2page - 将内核虚拟地址转换为对应的 Page 结构体指针
static inline struct Page *
kva2page(void *kva)
{
    // 先调用 PADDR 转为物理地址，再转为 Page 结构体
    return pa2page(PADDR(kva));
}

// pte2page - 将页表项 (PTE) 转换为它指向的物理页的 Page 结构体
static inline struct Page *
pte2page(pte_t pte)
{
    // 检查 PTE 是否有效 (PTE_V 位)
    if (!(pte & PTE_V))
    {
        panic("pte2page called with invalid pte");
    }
    // PTE_ADDR(pte) 提取 PTE 中的物理地址部分，然后转为 Page 结构体
    return pa2page(PTE_ADDR(pte));
}

// pde2page - 将页目录项 (PDE) 转换为它指向的下一级页表的 Page 结构体
// 原理与 pte2page 相同
static inline struct Page *
pde2page(pde_t pde)
{
    return pa2page(PDE_ADDR(pde));
}

// page_ref - 获取页面的引用计数
static inline int
page_ref(struct Page *page)
{
    return page->ref;
}

// set_page_ref - 设置页面的引用计数
static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
}

// page_ref_inc - 增加页面的引用计数
static inline int
page_ref_inc(struct Page *page)
{
    page->ref += 1;
    return page->ref;
}

// page_ref_dec - 减少页面的引用计数
static inline int
page_ref_dec(struct Page *page)
{
    page->ref -= 1;
    return page->ref;
}

// flush_tlb - 刷新 TLB (Translation Lookaside Buffer)
// sfence.vma 是 RISC-V 特有的指令，用于刷新虚拟内存缓存
static inline void flush_tlb()
{
    asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
// pte_create - 根据物理页帧号 (ppn) 和权限位 (type) 构建一个 PTE 值
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    // 将 PPN 移动到 PTE 的正确位置，并或上标志位 (PTE_V 表示有效，type 包含 R/W/X/U 等)
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
}

// ptd_create - 创建一个指向下一级页表的页目录项
// 通常只需要 PPN 和有效位 V，中间页表项不需要 R/W/X 权限位
static inline pte_t ptd_create(uintptr_t ppn)
{
    return pte_create(ppn, PTE_V);
}

// 外部引用：内核栈的定义
extern char bootstack[], bootstacktop[];

#endif /* !__KERN_MM_PMM_H__ */