#include <default_pmm.h>       // 包含默认物理内存管理器实现
#include <best_fit_pmm.h>      // 包含最佳适配算法的物理内存管理器实现
#include <defs.h>              // 包含通用定义（如数据类型、宏等）
#include <error.h>             // 包含错误处理相关定义（如错误码）
#include <memlayout.h>         // 包含内存布局相关定义（如内核地址空间范围）
#include <mmu.h>               // 包含内存管理单元（MMU）相关定义（如页表项结构）
#include <pmm.h>               // 包含物理内存管理相关声明（如Page结构体、pmm_manager接口）
#include <sbi.h>               // 包含SBI（Supervisor Binary Interface）相关函数（用于与底层交互）
#include <stdio.h>             // 包含标准输入输出函数（如cprintf）
#include <string.h>            // 包含字符串处理函数
#include <../sync/sync.h>      // 包含同步机制相关定义（如中断开关操作）
#include <riscv.h>             // 包含RISC-V架构相关定义（如物理内存起始地址DRAM_BASE）
#include <dtb.h>               // 包含设备树（DTB）解析相关函数（用于获取内存信息）

// 物理页数组的虚拟地址，用于管理所有物理页的元数据（如是否被分配、引用计数等）
struct Page *pages;
// 物理内存的总页数（整个系统可管理的物理页数量）
size_t npage = 0;
// 内核镜像的虚拟地址与物理地址偏移量（VA = PA + va_pa_offset）
uint64_t va_pa_offset;
// RISC-V架构中内存起始地址为0x80000000（DRAM_BASE），nbase为起始地址对应的页索引（DRAM_BASE / 页大小）
const size_t nbase = DRAM_BASE / PGSIZE;

// 启动时页目录（页表）的虚拟地址
uintptr_t *satp_virtual = NULL;
// 启动时页目录（页表）的物理地址
uintptr_t satp_physical;

// 物理内存管理器，指向当前使用的内存管理算法实例（如首次适配、最佳适配等）
const struct pmm_manager *pmm_manager;


static void check_alloc_page(void);  // 声明物理内存分配检查函数（验证分配/释放功能正确性）

// init_pmm_manager - 初始化物理内存管理器实例
static void init_pmm_manager(void) {
    pmm_manager = &default_pmm_manager;  // 设置默认物理内存管理器（可切换为其他算法如最佳适配）
    cprintf("memory management: %s\n", pmm_manager->name);  // 打印使用的内存管理器名称
    pmm_manager->init();  // 调用管理器的初始化函数（初始化内部数据结构）
}

// init_memmap - 调用物理内存管理器的init_memmap函数，为空闲内存构建Page结构体数组
static void init_memmap(struct Page *base, size_t n) {
    pmm_manager->init_memmap(base, n);  // 委托给当前管理器实现（初始化n个连续物理页的元数据）
}

// alloc_pages - 调用pmm->alloc_pages分配n个连续的物理页（单位：页）
/*
 * alloc_pages：分配n个连续的物理页
 * 参数：n - 所需物理页的数量
 * 返回：成功则返回指向第一个物理页的指针，失败返回NULL
 * 设计思路：
 * 物理页分配涉及修改内存管理的数据结构（如空闲页链表），这些操作必须是原子的（不可被中断打断）
 * 因此通过关闭中断确保操作的原子性，操作完成后恢复原中断状态
 */
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;  // 用于存储分配到的物理页指针
    bool intr_flag;            // 用于保存中断状态的标志（1表示原中断开启，0表示原中断关闭）

    // 保存当前中断状态并关闭中断，确保后续分配操作不被打断
    local_intr_save(intr_flag);
    {
        // 调用内存管理器的分配函数实际执行分配（具体实现由pmm_manager指向的算法决定）
        page = pmm_manager->alloc_pages(n);
    }
    // 恢复中断状态（若原中断是开启的，则重新开启；否则保持关闭）
    local_intr_restore(intr_flag);

    return page;  // 返回分配到的物理页指针
}

/*
 * free_pages：释放n个连续的物理页
 * 参数：base - 待释放的第一个物理页的指针；n - 待释放的物理页数量
 * 设计思路：
 * 释放物理页同样需要修改内存管理数据结构，必须保证原子性
 * 因此通过关闭中断防止操作被中断打断，完成后恢复中断状态
 */
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;  // 用于保存中断状态的标志

    // 保存当前中断状态并关闭中断，确保释放操作不被打断
    local_intr_save(intr_flag);
    {
        // 调用内存管理器的释放函数实际执行释放
        pmm_manager->free_pages(base, n);
    }
    // 恢复中断状态
    local_intr_restore(intr_flag);
}

// nr_free_pages - 调用pmm->nr_free_pages获取当前空闲内存大小（单位：页）
size_t nr_free_pages(void) {
    size_t ret;               // 用于存储空闲页数的返回值
    bool intr_flag;           // 用于保存中断状态的标志
    local_intr_save(intr_flag);  // 关闭中断确保操作原子性
    {
        ret = pmm_manager->nr_free_pages();  // 委托给当前管理器获取空闲页数
    }
    local_intr_restore(intr_flag);  // 恢复中断状态
    return ret;  // 返回空闲页数
}

// page_init - 初始化物理内存映射，确定可用内存范围并标记已使用内存
static void page_init(void) {
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  // 设置虚拟地址与物理地址的偏移量（内核空间偏移）

    // 从设备树中获取物理内存的起始地址和大小（设备树包含硬件内存信息）
    uint64_t mem_begin = get_memory_base();
    uint64_t mem_size  = get_memory_size();
    if (mem_size == 0) {
        panic("DTB memory info not available");  // 若无法获取内存信息则触发panic（致命错误）
    }
    uint64_t mem_end   = mem_begin + mem_size;  // 计算内存结束地址

    // 打印物理内存映射信息（调试用，显示内存大小和地址范围）
    cprintf("physcial memory map:\n");
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
            mem_end - 1);

    // 确定物理内存的最大可管理地址（不超过内核地址空间上限KERNTOP）
    uint64_t maxpa = mem_end;
    if (maxpa > KERNTOP) {
        maxpa = KERNTOP;
    }

    extern char end[];  // 内核镜像结束位置的符号（由链接器脚本定义，标记内核代码/数据的结尾）

    // 计算总物理页数（最大可管理地址 / 页大小）
    npage = maxpa / PGSIZE;
    // 物理页数组pages从内核镜像结束位置向上对齐到页边界开始分配（避免跨页）
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    // 初始化所有物理页为"已保留"状态（默认不可分配，后续再标记空闲区域）
    for (size_t i = 0; i < npage - nbase; i++) {
        SetPageReserved(pages + i);
    }

    // 计算空闲内存的起始地址：pages数组之后的位置（pages数组本身的内存已被内核占用）
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));

    // 对齐空闲内存的起始和结束地址到页边界（确保按页管理）
    mem_begin = ROUNDUP(freemem, PGSIZE);
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
    // 若存在可用空闲内存，则初始化对应的物理页为空闲状态（加入空闲列表）
    if (freemem < mem_end) {
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - 初始化物理内存管理系统 */
void pmm_init(void) {
    // 物理内存管理以页（4KB或其他大小）为单位进行分配/释放
    // pmm.h中定义了物理内存管理器框架（struct pmm_manager）
    // 首先需要基于该框架初始化一个物理内存管理器实例
    // 之后通过该实例进行物理内存的分配和释放
    // 目前支持first_fit/best_fit/worst_fit/buddy_system等算法
    init_pmm_manager();

    // 探测物理内存空间，保留已使用的内存区域（如内核镜像、pages数组）
    // 然后调用pmm->init_memmap创建空闲页列表
    page_init();

    // 调用pmm->check验证内存管理器的分配/释放功能正确性
    check_alloc_page();

    extern char boot_page_table_sv39[];  // 启动时页表的符号（由链接器定义，存放初始页表）
    satp_virtual = (pte_t*)boot_page_table_sv39;  // 保存页表的虚拟地址
    satp_physical = PADDR(satp_virtual);  // 计算页表的物理地址（虚拟地址减去偏移量）
    // 打印页表的虚拟地址和物理地址（调试用）
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

// check_alloc_page - 检查物理内存分配功能的正确性
static void check_alloc_page(void) {
    pmm_manager->check();  // 调用当前内存管理器的检查函数（验证分配/释放逻辑）
    cprintf("check_alloc_page() succeeded!\n");  // 打印检查成功信息
}