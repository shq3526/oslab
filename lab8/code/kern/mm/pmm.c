/*
 * kern/mm/pmm.c
 *
 * 本文件实现了物理内存管理系统 (Physical Memory Management System)。
 * 主要职责包括：
 * 1. 初始化物理内存管理器 (pmm_manager)。
 * 2. 建立物理页的元数据结构 (struct Page *pages)。
 * 3. 提供物理页的分配 (alloc_pages) 和释放 (free_pages) 接口。
 * 4. 实现了 RISC-V SV39 页表机制，包括页表项的查找 (get_pte)、映射建立 (page_insert) 和解除 (page_remove)。
 * 5. 处理内核启动时的页表切换和内核栈保护。
 * 6. 提供内存拷贝功能 (copy_range)，用于进程复制。
 */

#include <default_pmm.h>
#include <defs.h>
#include <error.h>
#include <kmalloc.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <dtb.h>
#include <stdio.h>
#include <string.h>
#include <sync.h>
#include <vmm.h>
#include <riscv.h>

// virtual address of physical page array
// 所有物理页的元数据数组，pages[i] 对应物理内存的第 i 个页
struct Page *pages;
// amount of physical memory (in pages)
// 物理内存的总页数
size_t npage = 0;
// The kernel image is mapped at VA=KERNBASE and PA=info.base
// 虚拟地址与物理地址之间的线性偏移量 (VA - PA)
uint_t va_pa_offset;
// memory starts at 0x80000000 in RISC-V
// DRAM 物理内存起始页帧号
const size_t nbase = DRAM_BASE / PGSIZE;

// virtual address of boot-time page directory
// 启动时使用的页目录表的虚拟地址
pde_t *boot_pgdir_va = NULL;
// physical address of boot-time page directory
// 启动时使用的页目录表的物理地址
uintptr_t boot_pgdir_pa;

// physical memory management
// 物理内存管理器实例（定义了具体的分配算法，如 default_pmm_manager）
const struct pmm_manager *pmm_manager;

static void check_alloc_page(void);
static void check_pgdir(void);
static void check_boot_pgdir(void);

// init_pmm_manager - initialize a pmm_manager instance
// 初始化物理内存管理器，默认使用 default_pmm_manager
static void init_pmm_manager(void)
{
    pmm_manager = &default_pmm_manager;
    cprintf("memory management: %s\n", pmm_manager->name);
    pmm_manager->init();
}

// init_memmap - call pmm->init_memmap to build Page struct for free memory
// 初始化一块连续的空闲内存块，将其加入到空闲链表中
static void init_memmap(struct Page *base, size_t n)
{
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
// 分配 n 个连续的物理页。
// 注意：为了保证并发安全，这里使用了关中断 (local_intr_save) 来保护分配过程。
struct Page *alloc_pages(size_t n)
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag); // 关中断
    {
        page = pmm_manager->alloc_pages(n);
    }
    local_intr_restore(intr_flag); // 恢复中断
    return page;
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
// 释放从 base 开始的 n 个物理页。
// 同样需要关中断保护。
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
    }
    local_intr_restore(intr_flag);
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory
// 获取当前系统中剩余的空闲页总数。
size_t nr_free_pages(void)
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
    }
    local_intr_restore(intr_flag);
    return ret;
}

/* pmm_init - initialize the physical memory management */
// 物理内存初始化的核心函数。
// 负责探测物理内存大小，建立 pages 数组，并初始化空闲页列表。
static void page_init(void)
{
    extern char kern_entry[];

    // 设置虚拟地址和物理地址的偏移量
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;

    // 获取物理内存的起始地址和大小 (通常由 OpenSBI 传递的 DTB 决定)
    uint64_t mem_begin = get_memory_base();
    uint64_t mem_size = get_memory_size();
    if (mem_size == 0)
    {
        panic("DTB memory info not available");
    }
    uint64_t mem_end = mem_begin + mem_size;

    cprintf("physcial memory map:\n");
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
            mem_end - 1);

    uint64_t maxpa = mem_end;

    if (maxpa > KERNTOP)
    {
        maxpa = KERNTOP;
    }

    extern char end[]; // 链接脚本中定义的内核结束地址

    // 计算总的物理页数
    npage = maxpa / PGSIZE;
    
    // BBL has put the initial page table at the first available page after the
    // kernel
    // so stay away from it by adding extra offset to end
    // pages 数组存放所有的 struct Page 结构体。
    // 我们将其放置在内核代码段结束后的位置 (end)，并向上取整对齐。
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    // 初始化所有物理页为"保留"状态 (Reserved)，防止被意外分配
    for (size_t i = 0; i < npage - nbase; i++)
    {
        SetPageReserved(pages + i);
    }

    // 计算 pages 数组之后，真正可用的空闲内存起始地址
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));

    // 对齐内存边界
    mem_begin = ROUNDUP(freemem, PGSIZE);
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
    
    // 如果有空闲内存，调用管理器进行初始化，将其标记为可用 (Free)
    if (freemem < mem_end)
    {
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
    cprintf("vapaofset is %llu\n", va_pa_offset);
}

// boot_map_segment - setup&enable the paging mechanism
// parameters
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory
// 启动时的内存映射辅助函数。
// 将物理地址区间 [pa, pa+size] 映射到线性地址区间 [la, la+size]。
static void boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size,
                             uintptr_t pa, uint32_t perm)
{
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    // 循环映射每一页
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE)
    {
        // 获取或创建对应的页表项 (PTE)
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        // 设置 PTE 的物理页号 (PPN) 和权限 (V位和perm)
        *ptep = pte_create(pa >> PGSHIFT, PTE_V | perm);
    }
}

// boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// return value: the kernel virtual address of this allocated page
// note: this function is used to get the memory for PDT(Page Directory
// Table)&PT(Page Table)
// 启动时分配一个页，主要用于分配页目录表或页表所需的内存空间。
static void *boot_alloc_page(void)
{
    struct Page *p = alloc_page();
    if (p == NULL)
    {
        panic("boot_alloc_page failed.\n");
    }
    return page2kva(p);
}

/**
 * from transient boot pgdir switch to a new one and add some protection
 * 1. switch pgdir
 * 2. set refined permission(rx, rw...)
 * 3. set previous transient boot pgdir and another dedicated page
 * as guard pages for kernel stack
 */
// 切换内核内存布局。
// 从启动时的临时页表切换到正式的内核页表，并设置内核栈保护。
static void
switch_kernel_memorylayout()
{
    /**
     * Free intermediate here is uncessary because initially we use
     * big-big-big page such that not intermediate page is occupied
     */

    // new page directory
    // 1. 分配一个新的页目录表
    pde_t *kern_pgdir = (pde_t *)boot_alloc_page();
    memset(kern_pgdir, 0, PGSIZE);

    // insert kernel mappings
    // 2. 映射内核代码段 (TEXT)，权限为 可读(R) | 可执行(X)
    extern const char etext[];
    uintptr_t retext = ROUNDUP((uintptr_t)etext, PGSIZE);
    boot_map_segment(kern_pgdir, KERNBASE, retext - KERNBASE, PADDR(KERNBASE), PTE_R | PTE_X);
    
    // 3. 映射内核数据段 (DATA/BSS)，权限为 可读(R) | 可写(W)
    boot_map_segment(kern_pgdir, retext, KERNTOP - retext, PADDR(retext), PTE_R | PTE_W);

    // perform switch
    // 4. 切换页表基址寄存器 (satp)
    boot_pgdir_va = kern_pgdir;
    boot_pgdir_pa = PADDR(boot_pgdir_va);
    lsatp(boot_pgdir_pa);
    flush_tlb(); // 刷新 TLB
    cprintf("Page table directory switch succeeded!\n");

    /**
     * set up kernel stack guardian pages
     */
    // 5. 设置内核栈保护页 (Guard Page)
    // 防止内核栈溢出覆盖其他重要数据
    extern char bootstackguard[], boot_page_table_sv39[];
    if ((bootstackguard + PGSIZE == bootstack) && (bootstacktop == boot_page_table_sv39))
    {
        // check writeable and set 0
        memset(boot_page_table_sv39, 0, PGSIZE);
        bootstack[-1] = 0;
        bootstack[-PGSIZE] = 0;

        // set pages beneath and above the kernel stack as guardians
        // 将栈底下方和栈顶上方的页映射为不可访问 (无 PTE_V 或无 RWX 权限)
        boot_map_segment(boot_pgdir_va, bootstackguard, PGSIZE, PADDR(bootstackguard), 0);
        boot_map_segment(boot_pgdir_va, boot_page_table_sv39, PGSIZE, PADDR(boot_page_table_sv39), 0);
        flush_tlb();

        // the following four statements should all crash
        // bootstack[-1] = 0;
        // bootstack[-PGSIZE] = 0;
        // bootstacktop[0] = 0;
        // bootstacktop[PGSIZE-1] = 0;

        cprintf("Kernel stack guardians set succeeded!\n");
    }
}

// pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup
// paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
// PMM 模块总初始化入口
void pmm_init(void)
{
    // We need to alloc/free the physical memory (granularity is 4KB or other
    // size).
    // So a framework of physical memory manager (struct pmm_manager)is defined
    // in pmm.h
    // First we should init a physical memory manager(pmm) based on the
    // framework.
    // Then pmm can alloc/free the physical memory.
    // Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    // 1. 初始化物理内存管理器算法
    init_pmm_manager();

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    // 2. 初始化物理页数组 (pages)
    page_init();

    // use pmm->check to verify the correctness of the alloc/free function in a
    // pmm
    // 3. 检查分配算法是否正确
    check_alloc_page();

    // switch from transient boot page directory to refined kernel page directory
    // 4. 建立并切换到最终的内核页表
    switch_kernel_memorylayout();

    check_pgdir();

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // now the basic virtual memory map(see memalyout.h) is established.
    // check the correctness of the basic virtual memory map.
    check_boot_pgdir();

    kmalloc_init();
}



// get_pte - get pte and return the kernel virtual address of this pte for la
//        - if the PT contians this pte didn't exist, alloc a page for PT
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
// 获取线性地址 la 对应的页表项 (PTE) 指针。
// 如果对应层级的页表不存在且 create 为 true，则分配新页表。
// SV39 三级页表：Page Directory (Level 2) -> Page Directory (Level 1) -> Page Table (Level 0)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    // 1. 获取一级页目录项 (PDX1)
    pde_t *pdep1 = &pgdir[PDX1(la)];
    // 如果该项无效 (PTE_V 为 0)
    if (!(*pdep1 & PTE_V))
    {
        struct Page *page;
        // 如果不创建或者分配失败，返回 NULL
        if (!create || (page = alloc_page()) == NULL)
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE); // 清空新分配的页表页
        // 建立一级目录项，指向新分配的页表页 (二级页目录)
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }

    // 2. 获取二级页目录项 (PDX0)
    // PDE_ADDR 获取下一级页表的物理地址，KADDR 转换为内核虚拟地址
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V))
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        // 建立二级目录项，指向新分配的页表页 (最终的页表)
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    // 3. 返回最终页表项 (PTX) 的地址
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}

// get_page - get related Page struct for linear address la using PDT pgdir
// 根据虚拟地址 la 获取对应的物理页结构 struct Page。
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
    pte_t *ptep = get_pte(pgdir, la, 0); // 查找 PTE，不创建新页表
    if (ptep_store != NULL)
    {
        *ptep_store = ptep;
    }
    // 如果 PTE 存在且有效，转换出 struct Page
    if (ptep != NULL && *ptep & PTE_V)
    {
        return pte2page(*ptep);
    }
    return NULL;
}

// page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
// note: PT is changed, so the TLB need to be invalidate
// 移除一个 PTE 映射，并尝试释放对应的物理页。
static inline void page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep)
{
    if (*ptep & PTE_V)
    { //(1) check if this page table entry is valid
        struct Page *page =
            pte2page(*ptep); //(2) find corresponding page to pte
        page_ref_dec(page);  //(3) decrease page reference
        if (page_ref(page) ==
            0)
        { //(4) and free this page when page reference reachs 0
            free_page(page);
        }
        *ptep = 0;                 //(5) clear second page table entry
        tlb_invalidate(pgdir, la); //(6) flush tlb (映射改变，必须刷新快表)
    }
}

// 取消 [start, end) 区间的内存映射
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));

    do
    {
        pte_t *ptep = get_pte(pgdir, start, 0);
        if (ptep == NULL)
        {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
}

// 释放 [start, end) 区间的所有页表和物理页资源（用于进程退出）
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));

    uintptr_t d1start, d0start;
    int free_pt, free_pd0;
    pde_t *pd0, *pt, pde1, pde0;
    d1start = ROUNDDOWN(start, PDSIZE);
    d0start = ROUNDDOWN(start, PTSIZE);
    do
    {
        // level 1 page directory entry
        pde1 = pgdir[PDX1(d1start)];
        // if there is a valid entry, get into level 0
        // and try to free all page tables pointed to by
        // all valid entries in level 0 page directory,
        // then try to free this level 0 page directory
        // and update level 1 entry
        if (pde1 & PTE_V)
        {
            pd0 = page2kva(pde2page(pde1));
            // try to free all page tables
            free_pd0 = 1;
            do
            {
                pde0 = pd0[PDX0(d0start)];
                if (pde0 & PTE_V)
                {
                    pt = page2kva(pde2page(pde0));
                    // try to free page table
                    free_pt = 1;
                    for (int i = 0; i < NPTEENTRY; i++)
                        if (pt[i] & PTE_V)
                        {
                            free_pt = 0;
                            break;
                        }
                    // free it only when all entry are already invalid
                    if (free_pt)
                    {
                        free_page(pde2page(pde0));
                        pd0[PDX0(d0start)] = 0;
                    }
                }
                else
                    free_pd0 = 0;
                d0start += PTSIZE;
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
            // free level 0 page directory only when all pde0s in it are already invalid
            if (free_pd0)
            {
                free_page(pde2page(pde1));
                pgdir[PDX1(d1start)] = 0;
            }
        }
        d1start += PDSIZE;
        d0start = d1start;
    } while (d1start != 0 && d1start < end);
}
/* copy_range - copy content of memory (start, end) of one process A to another
 * process B
 * @to:    the addr of process B's Page Directory
 * @from:  the addr of process A's Page Directory
 * @share: flags to indicate to dup OR share. We just use dup method, so it
 * didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
// 复制内存区间的内容。通常用于 fork() 系统调用，将父进程的内存复制给子进程。
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end,
               bool share)
{
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    // copy content by page unit.
    do
    {
        // call get_pte to find process A's pte according to the addr start
        // 1. 获取源进程(from)在该地址的 PTE
        pte_t *ptep = get_pte(from, start, 0), *nptep;
        if (ptep == NULL)
        {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        // call get_pte to find process B's pte according to the addr start. If
        // pte is NULL, just alloc a PT
        // 2. 如果源 PTE 有效，则进行复制
        if (*ptep & PTE_V)
        {
            // 在目标进程(to)中查找或创建对应的 PTE
            if ((nptep = get_pte(to, start, 1)) == NULL)
            {
                return -E_NO_MEM;
            }
            uint32_t perm = (*ptep & PTE_USER);
            // get page from ptep
            // 3. 获取源物理页
            struct Page *page = pte2page(*ptep);
            // alloc a page for process B
            // 4. 为目标进程分配一个新的物理页
            struct Page *npage = alloc_page();
            assert(page != NULL);
            assert(npage != NULL);
            int ret = 0;
            /* LAB5:填写你在lab5中实现的代码
             * replicate content of page to npage, build the map of phy addr of
             * nage with the linear addr start
             *
             * Some Useful MACROs and DEFINEs, you can use them in below
             * implementation.
             * MACROs or Functions:
             * page2kva(struct Page *page): return the kernel vritual addr of
             * memory which page managed (SEE pmm.h)
             * page_insert: build the map of phy addr of an Page with the
             * linear addr la
             * memcpy: typical memory copy function
             *
             * (1) find src_kvaddr: the kernel virtual address of page
             * (2) find dst_kvaddr: the kernel virtual address of npage
             * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
             * (4) build the map of phy addr of  nage with the linear addr start
             */
            // 1. 获取源页面的内核虚拟地址 (便于内核直接访问读取数据)
            void *kva_src = page2kva(page);
            // 2. 获取目标页面（新分配页）的内核虚拟地址 (便于内核写入数据)
            void *kva_dst = page2kva(npage);
            // 3. 复制内存内容 (复制一整页 4096 字节)
            memcpy(kva_dst, kva_src, PGSIZE);
            // 4. 建立目标进程虚拟地址 start 到新物理页 npage 的映射
            //    这完成了 fork() 中父子进程内存空间的独立
            ret = page_insert(to, npage, start, perm);
            assert(ret == 0);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
// 移除并释放虚拟地址 la 对应的物理页
void page_remove(pde_t *pgdir, uintptr_t la)
{
    pte_t *ptep = get_pte(pgdir, la, 0);
    if (ptep != NULL)
    {
        page_remove_pte(pgdir, la, ptep);
    }
}

// page_insert - build the map of phy addr of an Page with the linear addr la
// paramemters:
//  pgdir: the kernel virtual base address of PDT
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
// 建立映射：将虚拟地址 la 映射到物理页 page，权限为 perm。
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm)
{
    // 获取 PTE，如果不存在则创建
    pte_t *ptep = get_pte(pgdir, la, 1);
    if (ptep == NULL)
    {
        return -E_NO_MEM;
    }
    page_ref_inc(page); // 增加物理页的引用计数
    // 如果 PTE 原本已经有效（已经映射了某个页）
    if (*ptep & PTE_V)
    {
        struct Page *p = pte2page(*ptep);
        // 如果映射的是同一个页，则只需减少刚才增加的引用计数（避免重复增加）
        if (p == page)
        {
            page_ref_dec(page);
        }
        else
        {
            // 如果映射的是不同的页，先移除旧的映射
            page_remove_pte(pgdir, la, ptep);
        }
    }
    // 设置新的映射：构造 PTE
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
    tlb_invalidate(pgdir, la); // 刷新 TLB
    return 0;
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
// 刷新 TLB 中的某个条目
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    // 使用 sfence.vma 指令刷新 TLB
    asm volatile("sfence.vma %0" : : "r"(la));
}

// pgdir_alloc_page - call alloc_page & page_insert functions to
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
// 辅助函数：分配一个页并映射到指定线性地址。
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm)
{
    struct Page *page = alloc_page();
    if (page != NULL)
    {
        if (page_insert(pgdir, page, la, perm) != 0)
        {
            free_page(page);
            return NULL;
        }
        // swap_map_swappable(check_mm_struct, la, page, 0);
        page->pra_vaddr = la;
        assert(page_ref(page) == 1);
        // cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x,
        // pra_link_next %x in pgdir_alloc_page\n", (page-pages),
        // page->pra_vaddr,page->pra_page_link.prev,
        // page->pra_page_link.next);
    }

    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}

static void check_pgdir(void)
{
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
    assert(page_ref(p1) == 1);

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
    assert(*ptep & PTE_U);
    assert(*ptep & PTE_W);
    assert(boot_pgdir_va[0] & PTE_U);
    assert(page_ref(p2) == 1);

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
    assert(page_ref(p1) == 2);
    assert(page_ref(p2) == 0);
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
    assert((*ptep & PTE_U) == 0);

    page_remove(boot_pgdir_va, 0x0);
    assert(page_ref(p1) == 1);
    assert(page_ref(p2) == 0);

    page_remove(boot_pgdir_va, PGSIZE);
    assert(page_ref(p1) == 0);
    assert(page_ref(p2) == 0);

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
    flush_tlb();

    assert(nr_free_store == nr_free_pages());

    cprintf("check_pgdir() succeeded!\n");
}

static void check_boot_pgdir(void)
{
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(boot_pgdir_va[0] == 0);

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
    assert(page_ref(p) == 1);
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
    assert(page_ref(p) == 2);

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);

    *(char *)(page2kva(p) + 0x100) = '\0';
    assert(strlen((const char *)0x100) == 0);

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
    flush_tlb();

    assert(nr_free_store == nr_free_pages());

    cprintf("check_boot_pgdir() succeeded!\n");
}

// perm2str - use string 'u,r,w,-' to present the permission
static const char *perm2str(int perm)
{
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
    str[1] = 'r';
    str[2] = (perm & PTE_W) ? 'w' : '-';
    str[3] = '\0';
    return str;
}

// get_pgtable_items - In [left, right] range of PDT or PT, find a continuous
// linear addr space
//                  - (left_store*X_SIZE~right_store*X_SIZE) for PDT or PT
//                  - X_SIZE=PTSIZE=4M, if PDT; X_SIZE=PGSIZE=4K, if PT
// paramemters:
//  left:        no use ???
//  right:       the high side of table's range
//  start:       the low side of table's range
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
//  return value: 0 - not a invalid item range, perm - a valid item range with
//  perm permission
static int get_pgtable_items(size_t left, size_t right, size_t start,
                             uintptr_t *table, size_t *left_store,
                             size_t *right_store)
{
    if (start >= right)
    {
        return 0;
    }
    while (start < right && !(table[start] & PTE_V))
    {
        start++;
    }
    if (start < right)
    {
        if (left_store != NULL)
        {
            *left_store = start;
        }
        int perm = (table[start++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm)
        {
            start++;
        }
        if (right_store != NULL)
        {
            *right_store = start;
        }
        return perm;
    }
    return 0;
}