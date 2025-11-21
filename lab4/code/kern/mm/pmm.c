#include <default_pmm.h>
#include <defs.h>
#include <error.h>
#include <kmalloc.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <stdio.h>
#include <string.h>
#include <sync.h>
#include <vmm.h>
#include <riscv.h>
#include <dtb.h>

// [全局变量定义]
// 物理页数组的指针。系统启动后，这里会指向一个管理所有物理内存的 Page 结构体数组。
// 每一个物理页都有一个对应的 Page 结构体来描述它的状态。
struct Page *pages;

// 物理内存的总页数
size_t npage = 0;

// 虚拟地址与物理地址的线性偏移量 (VA = PA + va_pa_offset)
// 在 RISC-V ucore 中，通常是 0xFFFFFFFF40000000，用于内核空间的直接映射。
uint_t va_pa_offset;

// 物理内存起始页帧号 (0x80000000 / 4096)
// DRAM_BASE 是物理内存的起始地址。
const size_t nbase = DRAM_BASE / PGSIZE;

// 启动时页目录表的虚拟地址指针
pde_t *boot_pgdir_va = NULL;
// 启动时页目录表的物理地址
uintptr_t boot_pgdir_pa;

// 物理内存管理器实例指针 (默认使用 default_pmm_manager)
// 这是一个接口指针，可以指向不同的内存管理算法实现（如 First-Fit, Best-Fit 等）。
const struct pmm_manager *pmm_manager;

// 前置声明
static void check_alloc_page(void);
static void check_pgdir(void);
static void check_boot_pgdir(void);

// init_pmm_manager - 初始化物理内存管理器
static void init_pmm_manager(void)
{
    // 指定使用 default_pmm_manager (通常是 First-Fit 算法)
    pmm_manager = &default_pmm_manager;
    cprintf("memory management: %s\n", pmm_manager->name);
    // 调用管理器的初始化函数，初始化其内部数据结构（如空闲链表）
    pmm_manager->init();
}

// init_memmap - 初始化空闲内存块
// 调用 pmm_manager->init_memmap 来建立空闲页面的管理结构 (如空闲链表)
// base: 这块空闲内存的起始 Page 结构体
// n: 这块空闲内存包含的页数
static void init_memmap(struct Page *base, size_t n)
{
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - 分配 n 个连续的物理页
// 这是一个全局包装函数，负责加锁保护
struct Page *alloc_pages(size_t n)
{
    struct Page *page = NULL;
    bool intr_flag;
    // 1. 关中断 (进入临界区)
    // 因为物理内存分配器内部通常涉及全局链表操作，必须防止并发竞争
    // 如果在分配过程中发生中断并再次调用分配函数，可能会破坏链表结构。
    local_intr_save(intr_flag);
    {
        // 2. 调用具体管理器的分配函数
        page = pmm_manager->alloc_pages(n);
    }
    // 3. 恢复中断 (退出临界区)
    local_intr_restore(intr_flag);
    return page;
}

// free_pages - 释放 n 个连续的物理页
// base: 要释放的内存块的起始 Page 结构体
// n: 要释放的页数
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    // 同样需要关中断保护
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
    }
    local_intr_restore(intr_flag);
}

// nr_free_pages - 获取当前系统空闲页的总数
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

/* pmm_init - 物理内存管理初始化 (系统启动时的核心函数) */
static void page_init(void)
{
    extern char kern_entry[]; // 内核入口符号 (在链接脚本中定义)

    // 设置线性映射偏移量
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;

    // 获取物理内存探测结果 (通常来自设备树 DTB)
    uint64_t mem_begin = get_memory_base();
    uint64_t mem_size  = get_memory_size();
    if (mem_size == 0) {
        panic("DTB memory info not available");
    }
    uint64_t mem_end   = mem_begin + mem_size;

    cprintf("physcial memory map:\n");
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
            mem_end - 1);

    uint64_t maxpa = mem_end;

    // 限制最大物理地址不超过 KERNTOP (避免映射越界)
    if (maxpa > KERNTOP)
    {
        maxpa = KERNTOP;
    }

    extern char end[]; // 内核结束地址 (由链接脚本提供，表示内核代码和数据段的结束位置)

    // 计算总页数
    npage = maxpa / PGSIZE;
    
    // [Page 结构体数组的放置]
    // 我们把 Page 结构体数组放在内核代码结束后的第一个页开始的位置。
    // ROUNDUP 确保地址按页对齐。
    // 这个数组将占据内核之后的一段物理内存。
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    // 初始化所有 Page 结构体为 Reserved (保留状态)
    // 为什么？因为有些内存已经被内核代码占用了，有些是 IO 区域，不能被分配。
    // 我们先全部标记为保留，然后只把真正的空闲区域标记为 Free。
    for (size_t i = 0; i < npage - nbase; i++)
    {
        SetPageReserved(pages + i);
    }

    // 计算 Page 结构体数组本身占用了多少空间
    // freemem 是 Page 数组之后的第一个可用物理地址
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));

    // 对齐内存边界
    mem_begin = ROUNDUP(freemem, PGSIZE);
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
    
    // 将剩余的空闲内存注册到 PMM 中
    // init_memmap 会将这段内存标记为空闲，并加入到空闲链表中
    if (freemem < mem_end)
    {
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
    cprintf("vapaofset is %llu\n", va_pa_offset);
}

// 启用分页机制 (设置 satp 寄存器)
static void enable_paging(void)
{
    // 0x8000... 是设置 Sv39 模式位
    // boot_pgdir_pa >> RISCV_PGSHIFT 是将页目录表的物理地址转换为 PPN
    write_csr(satp, 0x8000000000000000 | (boot_pgdir_pa >> RISCV_PGSHIFT));
}

// boot_map_segment - 建立临时的段映射
// 参数:
//  pgdir: 页目录表基地址
//  la: 线性地址 (Linear Address) - 需要映射的虚拟地址起始点
//  size: 大小 - 映射区域的大小
//  pa: 物理地址 (Physical Address) - 映射到的物理地址起始点
//  perm: 权限 (Permission) - 页表项的权限位
static void boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size,
                             uintptr_t pa, uint32_t perm)
{
    assert(PGOFF(la) == PGOFF(pa));
    // 计算需要映射的页数
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    // 循环建立每一页的映射
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE)
    {
        pte_t *ptep = get_pte(pgdir, la, 1); // 获取/创建 PTE，参数 1 表示如果不存在则创建
        assert(ptep != NULL);
        *ptep = pte_create(pa >> PGSHIFT, PTE_V | perm); // 填写 PTE，设置 PPN 和权限
    }
}

// boot_alloc_page - 启动阶段的简易页分配
// 直接调用 alloc_page 获取一页，并转为内核虚拟地址 (KVA)
// 这个函数主要用于在构建页表时分配页表页
static void *boot_alloc_page(void)
{
    struct Page *p = alloc_page();
    if (p == NULL)
    {
        panic("boot_alloc_page failed.\n");
    }
    return page2kva(p);
}

// pmm_init - 物理内存管理初始化总入口
void pmm_init(void)
{
    // 1. 初始化 PMM 管理器 (设置函数指针等)
    init_pmm_manager();

    // 2. 探测物理内存，建立 Page 数组，初始化空闲链表
    // 这一步完成后，我们就可以使用 alloc_pages 分配物理页了
    page_init();

    // 3. 检查分配功能是否正常
    check_alloc_page();

    // 4. 设置启动页目录表 (boot_pgdir)
    // boot_page_table_sv39 在 entry.S 中定义，是内核早期使用的页表
    extern char boot_page_table_sv39[];
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
    boot_pgdir_pa = PADDR(boot_pgdir_va);

    check_pgdir();

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // 5. 检查基本虚拟内存映射是否正确
    check_boot_pgdir();

    // 6. 初始化 kmalloc (SLOB 分配器)
    // SLOB 分配器依赖于底层的 alloc_pages，所以必须在 PMM 初始化之后
    kmalloc_init();
}


// 在entry.S里，我们虽然构造了一个简单映射使得内核能够运行在虚拟空间上，但是这个映射是比较粗糙的。
// 我们知道一个程序通常含有下面几段：
// .text段：存放代码，需要是可读、可执行的，但不可写。
// .rodata 段：存放只读数据，顾名思义，需要可读，但不可写亦不可执行。
// .data 段：存放经过初始化的数据，需要可读、可写。
// .bss段：存放经过零初始化的数据，需要可读、可写。
// 与 .data 段的区别在于由于我们知道它被零初始化，
// 因此在可执行文件中可以只存放该段的开头地址和大小而不用存全为 0的数据。在执行时由操作系统进行处理。
// 我们看到各个段需要的访问权限是不同的。但是现在使用一个大大页(Giga Page)进行映射时，它们都拥有相同的权限，
// 那么在现在的映射下，我们甚至可以修改内核 .text 段的代码，因为我们通过一个标志位 W=1 的页表项就可以完成映射，但这显然会带来安全隐患。
// 因此，我们考虑对这些段分别进行重映射，使得他们的访问权限可以被正确设置。虽然还是每个段都还是映射以同样的偏移量映射到相同的地方，但实现过程需要更加精细。
// 对于我们最开始已经用特殊方式映射的一个大大页(Giga Page)，该怎么对那里面的地址重新进行映射？这个过程比较麻烦。
// 但大家可以基本理解为放弃现有的页表，直接新建一个页表，在新页表里面完成重映射，然后把satp指向新的页表，这样就实现了重新映射。


// get_pte - 获取页表项 (Page Table Entry)
// pgdir: 页目录表基地址 (KVA)
// la:    需要映射的线性地址 (虚拟地址)
// create: 如果页表不存在，是否创建？
// 返回值: 对应线性地址 la 的页表项指针 (KVA)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    // 1. 查找一级页目录 (PDX1 / VPN[2])
    // PDX1(la) 获取虚拟地址的一级索引
    pde_t *pdep1 = &pgdir[PDX1(la)];//找到对应的Giga Page
    
    // 如果一级页目录项无效 (即没有指向二级页表的指针)
    if (!(*pdep1 & PTE_V))//如果下一级页表不存在，那就给它分配一页，创造新页表
    {
        struct Page *page;
        // 如果不创建，直接返回 NULL
        if (!create || (page = alloc_page()) == NULL)
        {
            return NULL;
        }
        set_page_ref(page, 1); // 引用计数设为 1，表示被页目录引用
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE); // 新分配的页表页清零
        // 建立一级页目录指向二级页表的映射
        // 注意：这里指向的是下一级页表，所以权限通常比较宽松 (User | Valid)
        //我们现在在虚拟地址空间中，所以要转化为KADDR再memset.
        //不管页表怎么构造，我们确保物理地址和虚拟地址的偏移量始终相同，那么就可以用这种方式完成对物理内存的访问。
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }

    // 2. 查找二级页目录 (PDX0 / VPN[1])
    // PDE_ADDR(*pdep1) 获取二级页表的物理地址 -> KADDR 转为虚拟地址 -> 数组索引
    // PDX0(la) 获取虚拟地址的二级索引
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
    
    // 如果二级页目录项无效
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
        // 建立二级页目录指向页表 (Page Table) 的映射
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }

    // 3. 返回页表项 (PTX / VPN[0]) 的指针
    // 这里的指针指向的是物理页的 PTE，修改这个 PTE 就可以改变映射
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}

// get_page - 根据线性地址获取对应的 Page 结构体
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
    // 查找 PTE
    pte_t *ptep = get_pte(pgdir, la, 0); // create=0，只查不建
    if (ptep_store != NULL)
    {
        *ptep_store = ptep; // 如果提供了存储指针，返回 PTE 指针
    }
    // 如果 PTE 存在且有效
    if (ptep != NULL && *ptep & PTE_V)
    {
        // 将 PTE 中的 PPN (物理页帧号) 转换为 Page 结构体指针
        return pte2page(*ptep);
    }
    return NULL;
}

// page_remove_pte - 移除一个 PTE 映射，并释放对应的物理页
static inline void page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep)
{
    if (*ptep & PTE_V)
    { 
        struct Page *page = pte2page(*ptep); // 获取该 PTE 指向的物理页
        page_ref_dec(page);                  // 引用计数减 1
        
        // 如果引用计数归零，说明没有任何页表指向该页了，释放物理内存
        if (page_ref(page) == 0)
        { 
            free_page(page);
        }
        
        *ptep = 0;                 // 清空 PTE，标记为无效
        tlb_invalidate(pgdir, la); // 刷新 TLB，确保 CPU 不会使用旧的映射
    }
}

// page_remove - 移除虚拟地址 la 的映射
void page_remove(pde_t *pgdir, uintptr_t la) {
    pte_t *ptep = get_pte(pgdir, la, 0);//找到页表项所在位置
    if (ptep != NULL) {
        page_remove_pte(pgdir, la, ptep);//删除这个页表项的映射
    }
}

// page_insert - 建立映射：虚拟地址 la -> 物理页 page
// paramemters:
//  pgdir: 页目录表基地址
//  page:  要映射的物理页
//  la:    线性地址 (虚拟地址)
//  perm:  权限标志
// return value: 0 成功，-E_NO_MEM 内存不足
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm)
{
    //先找到对应页表项的位置，如果原先不存在，get_pte()会分配页表项的内存
    pte_t *ptep = get_pte(pgdir, la, 1);
    if (ptep == NULL)
    {
        return -E_NO_MEM;
    }
    
    page_ref_inc(page);//指向这个物理页面的虚拟地址增加了一个
    
    // 如果该 PTE 原本已经有效 (已经映射了某个页)
    if (*ptep & PTE_V) { //原先存在映射
        struct Page *p = pte2page(*ptep);
        if (p == page) {//如果这个映射原先就有
            page_ref_dec(page);
        } else {//如果原先这个虚拟地址映射到其他物理页面，那么需要删除映射
            page_remove_pte(pgdir, la, ptep);
        }
    }
    // 写入新的映射关系和权限
    *ptep = pte_create(page2ppn(page), PTE_V | perm);//构造页表项
    tlb_invalidate(pgdir, la); // 映射改变，刷新 TLB
    return 0;
}

// tlb_invalidate - 刷新 TLB
// 这里的 la 是虚拟地址，告诉 CPU 这个地址的映射可能变了
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    // sfence.vma 指令用于刷新 TLB
    // 0 参数表示刷新与 la 相关的 TLB 项 (如果硬件支持细粒度刷新)
    // 实际上在某些实现中可能会刷新整个 TLB
    asm volatile("sfence.vma %0" : : "r"(la));
}

// [检查函数] - 用于验证 PMM 是否工作正常
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
    //boot_pgdir是页表的虚拟地址
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
    //get_page()尝试找到虚拟内存0x0对应的页，现在当然是没有的，返回NULL


    struct Page *p1, *p2;
    p1 = alloc_page();//拿过来一个物理页面
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
    assert(page_ref(p1) == 1);

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
    //get_pte查找某个虚拟地址对应的页表项，如果不存在这个页表项，会为它分配各级的页表

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
    boot_pgdir_va[0] = 0;//清除测试的痕迹
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

// perm2str - 使用字符串 'u,r,w,-' 来表示权限
static const char *perm2str(int perm)
{
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
    str[1] = 'r';
    str[2] = (perm & PTE_W) ? 'w' : '-';
    str[3] = '\0';
    return str;
}

// get_pgtable_items - 在页目录表或页表的 [left, right] 范围内，查找一个连续的线性地址空间
//                  - (left_store*X_SIZE ~ right_store*X_SIZE)
//                  - 如果是 PDT，X_SIZE=PTSIZE=4M (Sv32) / 2M (Sv39)
//                  - 如果是 PT，X_SIZE=PGSIZE=4K
// paramemters:
//  left:        查找的起始索引 (貌似没有用到?)
//  right:       查找的结束索引
//  start:       当前开始查找的索引
//  table:       页表或页目录表的起始地址
//  left_store:  返回找到的连续范围的起始索引
//  right_store: 返回找到的连续范围的结束索引
//  return value: 0 - 无效范围, perm - 有效范围的权限
static int get_pgtable_items(size_t left, size_t right, size_t start,
                             uintptr_t *table, size_t *left_store,
                             size_t *right_store)
{
    if (start >= right)
    {
        return 0;
    }
    // 跳过无效的条目
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
        // 找到具有相同权限的连续条目
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