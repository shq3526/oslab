#include <default_pmm.h>
#include <best_fit_pmm.h>
#include <buddy_system_pmm.h>
#include <defs.h>
#include <error.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <stdio.h>
#include <string.h>
#include <riscv.h>
#include <dtb.h>

// virtual address of physical page array
struct Page *pages;  
//  全局指针变量，指向管理所有物理页的 Page 数组（每页一个 Page 结构）

// amount of physical memory (in pages)
size_t npage = 0;    
//   系统中物理页的总数（即物理内存大小 / 每页大小）

// the kernel image is mapped at VA=KERNBASE and PA=info.base
uint64_t va_pa_offset;
//   VA-PA 偏移量，用于虚拟地址和物理地址的相互转换

// memory starts at 0x80000000 in RISC-V
// DRAM_BASE defined in riscv.h as 0x80000000
const size_t nbase = DRAM_BASE / PGSIZE;  
//   nbase 表示物理内存基址（0x80000000）所对应的页号，用于页号转换时的偏移

// virtual address of boot-time page directory
uintptr_t *satp_virtual = NULL;  
//   存储页表基址的虚拟地址（satp 寄存器的内核虚拟映射）

// physical address of boot-time page directory
uintptr_t satp_physical;  
//   对应页表基址的物理地址，用于写入 satp 寄存器

// physical memory management
const struct pmm_manager *pmm_manager;  
//   当前使用的物理内存管理器（可以是 first-fit、best-fit 等）

static void check_alloc_page(void);  
//   内部函数声明：用于验证内存分配与释放功能是否正确

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    //pmm_manager = &best_fit_pmm_manager;
    pmm_manager = &buddy_system_pmm_manager;
    //   指定当前使用的物理内存分配算法为 best-fit
    cprintf("memory management: %s\n", pmm_manager->name);  
    //   打印当前选用的内存管理器名称
    pmm_manager->init();  
    //   调用该管理器的初始化函数，初始化空闲链表等结构
}

// init_memmap - call pmm->init_memmap to build Page struct for free memory
static void init_memmap(struct Page *base, size_t n) {
    pmm_manager->init_memmap(base, n);  
    //   调用管理器的 init_memmap 接口，为 [base, base+n) 区间的页建立 Page 元数据
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);  
    //   调用管理器的分配函数，分配连续 n 页物理内存
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);  
    //   调用管理器的释放函数，将 [base, base+n) 区间的页重新加入空闲链表
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory
size_t nr_free_pages(void) {
    return pmm_manager->nr_free_pages();  
    //   返回当前空闲页的数量（不乘以页大小）
}
/*将页表内容进行初始化。首先，设置虚拟到物理地址的偏移，然后规定
物理内存的开始地址和结束地址，以及大小。然后打印物理内存的映射信息。*/
static void page_init(void) {
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  
    //   初始化虚拟地址与物理地址之间的偏移量

    uint64_t mem_begin = get_memory_base();  
    uint64_t mem_size  = get_memory_size();  
    //   从设备树（DTB）中获取物理内存的起始地址与大小
    if (mem_size == 0) {
        panic("DTB memory info not available");  
        //   若未能从 DTB 获取有效内存信息，则触发内核崩溃
    }
    uint64_t mem_end   = mem_begin + mem_size;  
    //   计算内存结束地址

    cprintf("physcial memory map:\n");
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
            mem_end - 1);
    //   打印物理内存映射信息，用于调试

    uint64_t maxpa = mem_end;

    if (maxpa > KERNTOP) {
        maxpa = KERNTOP;  
        //   限制最大物理地址不超过内核映射上限 KERNTOP
    }

    extern char end[];  
    //   声明链接脚本中定义的内核结束符号（即内核映像的结束地址）

    npage = maxpa / PGSIZE;
    //kernel在end[]结束, pages是剩下的页的开始
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
    //   Page 数组紧跟内核末尾对齐到页边界，为每个物理页建立 Page 元信息

    for (size_t i = 0; i < npage - nbase; i++) {
        SetPageReserved(pages + i);  
        //   默认将所有页标记为“已保留”（Reserved），防止误分配
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
    //   计算 pages 元数据结构占用的结束物理地址，之后的空间才是真正可分配区域

    mem_begin = ROUNDUP(freemem, PGSIZE);
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
    //   对齐空闲内存区域边界，使其满足页粒度

    if (freemem < mem_end) {
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
        //   初始化空闲页映射表，为 [mem_begin, mem_end) 区域建立 free list
    }
}

/* pmm_init - initialize the physical memory management 初始化物理内存管理*/
void pmm_init(void) {
    // We need to alloc/free the physical memory (granularity is 4KB or other size).
    // So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    // First we should init a physical memory manager(pmm) based on the framework.
    // Then pmm can alloc/free the physical memory.
    // Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    //   上面注释解释了物理内存管理的通用框架，支持多种算法，
    init_pmm_manager();  
    //   选择并初始化具体的物理内存管理算法（此处为 Best-Fit）

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();  
    //   检测并初始化整个物理内存空间，构建空闲页链表

    // use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();  
    //   调用管理器自带的测试函数，验证分配与释放逻辑是否正确

    extern char boot_page_table_sv39[];
    satp_virtual = (pte_t*)boot_page_table_sv39;  
    //   内核启动页表（SV39 模式）的虚拟地址
    satp_physical = PADDR(satp_virtual);  
    //   将虚拟地址转换为物理地址，用于写入 satp 寄存器
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
    //   打印页表基址信息，方便调试虚实地址映射
}

static void check_alloc_page(void) {
    pmm_manager->check();  
    //   调用内存管理器的自检函数（例如 best_fit_check），执行多轮分配/释放验证
    cprintf("check_alloc_page() succeeded!\n");
    //  若通过所有断言测试，则输出成功信息
}
