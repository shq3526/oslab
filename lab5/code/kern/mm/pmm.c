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
// 所有物理页面的 Page 结构体数组的虚拟首地址
struct Page *pages;

// amount of physical memory (in pages)
// 物理内存的总页数
size_t npage = 0;

// The kernel image is mapped at VA=KERNBASE and PA=info.base
// 虚拟地址与物理地址之间的偏移量 (VA - PA)
uint_t va_pa_offset;

// memory starts at 0x80000000 in RISC-V
// RISC-V 的物理内存起始地址 (0x80000000) 对应的页框号
const size_t nbase = DRAM_BASE / PGSIZE;

// virtual address of boot-time page directory
// 启动时页目录表（一级页表）的内核虚拟地址
pde_t *boot_pgdir_va = NULL;

// physical address of boot-time page directory
// 启动时页目录表的物理地址
uintptr_t boot_pgdir_pa;

// physical memory management
// 物理内存管理器接口结构体指针（指向具体的分配算法，如 first_fit）
const struct pmm_manager *pmm_manager;

// 静态函数声明
static void check_alloc_page(void);
static void check_pgdir(void);
static void check_boot_pgdir(void);

// init_pmm_manager - initialize a pmm_manager instance
// 初始化物理内存管理器
static void init_pmm_manager(void)
{
    // 将 pmm_manager 指向默认的物理内存管理器（通常是 default_pmm_manager，使用 First Fit 算法）
    pmm_manager = &default_pmm_manager;
    // 打印当前使用的内存管理器名称
    cprintf("memory management: %s\n", pmm_manager->name);
    // 调用管理器的初始化函数
    pmm_manager->init();
}

// init_memmap - call pmm->init_memmap to build Page struct for free memory
// 初始化空闲内存块，建立 Page 结构体
static void init_memmap(struct Page *base, size_t n)
{
    // 调用具体管理器的 init_memmap 函数来管理从 base 开始的 n 个页
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
// 分配 n 个连续的物理页
struct Page *alloc_pages(size_t n)
{
    // 定义一个 Page 结构体指针，初始化为空
    struct Page *page = NULL;
    // 定义中断保存标志变量
    bool intr_flag;
    
    // 保存当前中断状态并禁用中断，进入临界区
    // 防止在分配内存修改空闲链表时发生中断导致数据竞争
    local_intr_save(intr_flag);
    {
        // 调用具体管理器的分配函数分配 n 页
        page = pmm_manager->alloc_pages(n);
    }
    // 恢复之前的中断状态，退出临界区
    local_intr_restore(intr_flag);
    
    // 返回分配到的第一个页面的 Page 结构体指针
    return page;
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
// 释放从 base 开始的 n 个连续物理页
void free_pages(struct Page *base, size_t n)
{
    // 定义中断保存标志变量
    bool intr_flag;
    
    // 保存中断状态并关中断，进入临界区
    local_intr_save(intr_flag);
    {
        // 调用具体管理器的释放函数
        pmm_manager->free_pages(base, n);
    }
    // 恢复中断状态，退出临界区
    local_intr_restore(intr_flag);
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory
// 获取当前系统空闲页面的总数
size_t nr_free_pages(void)
{
    size_t ret;
    bool intr_flag;
    
    // 关中断，防止在统计过程中链表发生变化
    local_intr_save(intr_flag);
    {
        // 调用管理器获取空闲页数
        ret = pmm_manager->nr_free_pages();
    }
    // 开中断
    local_intr_restore(intr_flag);
    
    // 返回空闲页数
    return ret;
}

/* pmm_init - initialize the physical memory management */
/* page_init - 检测物理内存并初始化 Page 结构体数组 */
static void page_init(void)
{
    // 引用外部符号，内核代码段的入口地址（未实际使用，但声明了）
    extern char kern_entry[];

    // 设置虚拟地址到物理地址的偏移量 (0xFFFFFFFFC0000000)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;

    // 获取物理内存的起始物理地址 (通常是 0x80000000)
    uint64_t mem_begin = get_memory_base();
    // 获取物理内存的大小
    uint64_t mem_size = get_memory_size();
    
    // 如果内存大小为0，说明设备树(DTB)信息获取失败，系统崩溃
    if (mem_size == 0)
    {
        panic("DTB memory info not available");
    }
    
    // 计算物理内存结束地址
    uint64_t mem_end = mem_begin + mem_size;

    // 打印物理内存映射信息
    cprintf("physcial memory map:\n");
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
            mem_end - 1);

    // 设置最大物理地址
    uint64_t maxpa = mem_end;

    // 如果实际物理内存超过了内核设定的最大支持范围 (KERNTOP)，则截断
    if (maxpa > KERNTOP)
    {
        maxpa = KERNTOP;
    }

    // 引用外部符号，内核代码/数据段的结束地址
    extern char end[];

    // 计算总的物理页数
    npage = maxpa / PGSIZE;
    
    // BBL (Berkeley Boot Loader) 将初始页表放在了内核结束后的第一个可用页面
    // 为了避开它，我们在 end 之后预留空间。
    // 将 pages 数组放置在内核结束地址向上取整到页边界的位置
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    // 遍历所有物理页对应的 Page 结构体 (从 0 到 npage - nbase)
    // 注意：risc-v 内存从 0x80000000 开始，所以索引要减去 nbase
    for (size_t i = 0; i < npage - nbase; i++)
    {
        // 将所有页面初始化为保留状态 (Reserved)，不可被分配
        SetPageReserved(pages + i);
    }

    // 计算放置完 pages 数组后，空闲内存的实际起始物理地址
    // 它是 pages 数组基址 + 所有 Page 结构体占用的空间，再转为物理地址
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));

    // 将空闲内存起始地址向上取整到页边界
    mem_begin = ROUNDUP(freemem, PGSIZE);
    // 将内存结束地址向下取整到页边界
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
    
    // 如果还有空闲内存
    if (freemem < mem_end)
    {
        // 初始化这部分空闲内存，将其加入到空闲页链表中
        // pa2page(mem_begin) 将物理地址转为对应的 Page 结构体指针
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
    // 打印调试信息：虚拟地址-物理地址偏移量
    cprintf("vapaofset is %llu\n", va_pa_offset);
}

// boot_map_segment - setup&enable the paging mechanism
// 建立一段内存的线性映射（用于启动阶段）
// parameters
//  la:   linear address (虚拟地址)
//  size: memory size
//  pa:   physical address
//  perm: permission
static void boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size,
                             uintptr_t pa, uint32_t perm)
{
    // 断言：虚拟地址和物理地址的页内偏移必须一致
    assert(PGOFF(la) == PGOFF(pa));
    
    // 计算需要映射的页数 n
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    
    // 将虚拟地址向下对齐到页边界
    la = ROUNDDOWN(la, PGSIZE);
    // 将物理地址向下对齐到页边界
    pa = ROUNDDOWN(pa, PGSIZE);
    
    // 循环 n 次，建立每一页的映射
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE)
    {
        // 获取 la 对应的页表项指针 (ptep)，如果不存在中间页表则创建 (第三个参数为 1)
        pte_t *ptep = get_pte(pgdir, la, 1);
        // 断言页表项指针获取成功
        assert(ptep != NULL);
        // 设置页表项：填入物理页号 (pa >> PGSHIFT) 和标志位 (有效位 PTE_V | 传入权限)
        *ptep = pte_create(pa >> PGSHIFT, PTE_V | perm);
    }
}

// boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// 启动阶段分配一个页，主要用于存放页目录表或页表
// return value: the kernel virtual address of this allocated page
static void *boot_alloc_page(void)
{
    // 调用分配函数申请一个物理页
    struct Page *p = alloc_page();
    // 如果分配失败，系统恐慌 (Panic)
    if (p == NULL)
    {
        panic("boot_alloc_page failed.\n");
    }
    // 返回该物理页对应的内核虚拟地址
    return page2kva(p);
}

// pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism
// 物理内存管理初始化主函数
void pmm_init(void)
{
    // 1. 初始化物理内存管理器 (如 first_fit)
    init_pmm_manager();

    // 2. 检测物理内存，预留已用空间（内核代码等），建立空闲页列表
    page_init();

    // 3. 检查分配/释放函数的正确性
    check_alloc_page();

    // 4. 设置启动时的页目录表 (boot_pgdir)
    // 引用外部定义的初始页表数据 (在 entry.S 或其他汇编中)
    extern char boot_page_table_sv39[];
    // 将其转换为 pte_t 指针作为虚拟地址
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
    // 计算其物理地址
    boot_pgdir_pa = PADDR(boot_pgdir_va);

    // 5. 检查页目录表的正确性
    check_pgdir();

    // 静态断言：确保 KERNBASE 和 KERNTOP 对齐到大页(PTSIZE)边界
    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // 6. 检查基本虚拟内存映射的正确性
    check_boot_pgdir();

    // 7. 初始化内核堆分配器 (slab/slub 等，用于 kmalloc)
    kmalloc_init();
}

// get_pte - get pte and return the kernel virtual address of this pte for la
// 查找虚拟地址 la 对应的页表项 (PTE) 的地址
// 这是一个三级页表查找过程 (SV39)
// pgdir: 页目录基地址 (一级页表)
// la: 线性地址
// create: 如果中间页表不存在，是否创建
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    // PDX1(la) 获取一级页表索引（Page Directory Index 1）
    // 获取一级页表项指针
    pde_t *pdep1 = &pgdir[PDX1(la)];
    
    // 检查一级页表项是否有效 (PTE_V)
    if (!(*pdep1 & PTE_V))
    {
        struct Page *page;
        // 如果不创建新页表，或者分配页面失败，返回 NULL
        if (!create || (page = alloc_page()) == NULL)
        {
            return NULL;
        }
        // 设置页面引用计数为 1
        set_page_ref(page, 1);
        // 获取分配页面的物理地址
        uintptr_t pa = page2pa(page);
        // 将新分配的页表内存清零 (非常重要)
        memset(KADDR(pa), 0, PGSIZE);
        // 设置一级页表项：指向新分配的二级页表物理页号，设置用户位和有效位
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }

    // 根据一级页表项的内容，找到二级页表 (Page Directory/Table Level 0) 的内核虚拟地址
    // 并通过 PDX0(la) 获取二级页表索引
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
    
    // 检查二级页表项是否有效
    if (!(*pdep0 & PTE_V))
    {
        struct Page *page;
        // 如果不创建或分配失败，返回 NULL
        if (!create || (page = alloc_page()) == NULL)
        {
            return NULL;
        }
        // 设置引用计数
        set_page_ref(page, 1);
        // 获取物理地址
        uintptr_t pa = page2pa(page);
        // 内存清零
        memset(KADDR(pa), 0, PGSIZE);
        // 设置二级页表项：指向新分配的三级页表（页表），设置权限
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    
    // 根据二级页表项，找到三级页表 (Page Table) 的地址
    // 并通过 PTX(la) 获取页表项索引，返回该 PTE 的内核虚拟地址
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}

// get_page - get related Page struct for linear address la using PDT pgdir
// 根据虚拟地址 la 获取对应的物理页结构体 Page
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
    // 查找 PTE，不创建新页表 (第三个参数为 0)
    pte_t *ptep = get_pte(pgdir, la, 0);
    
    // 如果调用者提供了存储 ptep 的指针，则保存找到的 PTE 地址
    if (ptep_store != NULL)
    {
        *ptep_store = ptep;
    }
    
    // 如果 PTE 存在且有效
    if (ptep != NULL && *ptep & PTE_V)
    {
        // 将 PTE 转换为对应的 Page 结构体指针并返回
        return pte2page(*ptep);
    }
    // 否则返回 NULL
    return NULL;
}

// page_remove_pte - free an Page sturct which is related linear address la
// 移除并释放与 la 关联的 PTE
// note: PT is changed, so the TLB need to be invalidate
static inline void page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep)
{
    // 如果 PTE 有效
    if (*ptep & PTE_V)
    {
        // 获取该 PTE 指向的物理页
        struct Page *page = pte2page(*ptep);
        // 减少该物理页的引用计数
        page_ref_dec(page);
        // 如果引用计数变为 0，说明没有进程使用该页，释放物理内存
        if (page_ref(page) == 0)
        {
            free_page(page);
        }
        // 清空 PTE (置 0)
        *ptep = 0;
        // 刷新 TLB (快表)，使 CPU 感知映射变化
        tlb_invalidate(pgdir, la);
    }
}

// unmap_range - 取消 [start, end) 范围内的所有映射
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
    // 断言地址按页对齐
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    // 断言在用户空间范围内
    assert(USER_ACCESS(start, end));

    do
    {
        // 获取 PTE
        pte_t *ptep = get_pte(pgdir, start, 0);
        // 如果 PTE 不存在 (对应的中间页表不存在)
        if (ptep == NULL)
        {
            // 跳过整个中间页表覆盖的范围 (PTSIZE)，加速遍历
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        // 如果 PTE 指向有效页，移除它
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        // 移动到下一页
        start += PGSIZE;
    } while (start != 0 && start < end);
}

// exit_range - 退出进程时释放页表占用的内存
// 这是一个深度清理，不仅释放数据页，还释放页表本身占用的页
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));

    uintptr_t d1start, d0start;
    int free_pt, free_pd0;
    pde_t *pd0, *pt, pde1, pde0;
    
    // 对齐到目录边界
    d1start = ROUNDDOWN(start, PDSIZE);
    d0start = ROUNDDOWN(start, PTSIZE);
    do
    {
        // 获取 Level 1 页目录项
        pde1 = pgdir[PDX1(d1start)];
        
        // 如果 Level 1 项有效，进入 Level 0
        if (pde1 & PTE_V)
        {
            // 获取 Level 0 页表的虚拟地址
            pd0 = page2kva(pde2page(pde1));
            // 标记变量：是否可以释放整个 Level 0 页表
            free_pd0 = 1;
            do
            {
                // 获取 Level 0 页目录项
                pde0 = pd0[PDX0(d0start)];
                if (pde0 & PTE_V)
                {
                    // 获取最底层页表的虚拟地址
                    pt = page2kva(pde2page(pde0));
                    // 标记变量：是否可以释放整个最底层页表
                    free_pt = 1;
                    // 遍历该页表中的所有 PTE
                    for (int i = 0; i < NPTEENTRY; i++)
                        if (pt[i] & PTE_V)
                        {
                            // 只要有一个 PTE 有效，就不能释放该页表
                            free_pt = 0;
                            break;
                        }
                    // 如果页表中所有条目都无效，释放该页表占用的物理页
                    if (free_pt)
                    {
                        free_page(pde2page(pde0));
                        pd0[PDX0(d0start)] = 0; // 清空父级条目
                    }
                }
                else
                    // 如果中间某个条目无效，显然不能断言整个上层表都可以被释放(逻辑上保持 free_pd0 为假可能更安全，或者是为了继续检查后续条目)
                    // 这里逻辑是：只要有一个有效的 pde0 存在且不能被释放，那么 free_pd0 就应该为 0。
                    // 此处 else free_pd0=0 的逻辑可能意味着如果某段没映射，就不尝试释放上层？(原逻辑保留)
                    free_pd0 = 0; 
                d0start += PTSIZE;
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
            
            // 如果 Level 0 页表中的所有 Level 0 条目都被清理了，释放 Level 0 页表本身
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

/* copy_range - copy content of memory (start, end) of one process A to another process B
 * 将进程 A (from) 的内存范围 [start, end) 复制给进程 B (to)
 * 包含了 Lab 5 的 Copy on Write (COW) 实现逻辑
 */
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share)
{
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    
    // copy content by page unit. 按页为单位进行复制
    do
    {
        // 1. 在源页表 (from) 中查找 start 对应的 PTE
        pte_t *ptep = get_pte(from, start, 0), *nptep;
        
        // 如果源 PTE 不存在
        if (ptep == NULL)
        {
            // 跳过整个页表范围，加速处理
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        
        // 如果源 PTE 有效 (存在映射)
        if (*ptep & PTE_V)
        {
            // 2. 在目标页表 (to) 中查找 start 对应的 PTE，如果不存在则创建页表
            if ((nptep = get_pte(to, start, 1)) == NULL)
            {
                return -E_NO_MEM; // 内存不足
            }
            
            // 获取源页面的权限（只取用户相关的位）
            uint32_t perm = (*ptep & PTE_USER);
            // 获取源 PTE 指向的物理页结构
            struct Page *page = pte2page(*ptep);
            int ret = 0;

            // LAB5 CHALLENGE: Copy on Write 逻辑
            // 如果启用了共享 (share = true, 通常用于 fork)
            if (share)
            {
                // 如果页面是可写的 (PTE_W)，需要将其标记为只读，以便父子进程共享
                // 只有写操作时才会触发 Page Fault 进行实际拷贝
                if (perm & PTE_W) {
                    // 清除写权限位
                    perm &= ~PTE_W;
                    // 修改父进程 (from) 的映射：去掉写权限
                    // page_insert 会自动处理引用计数(因为是同一个页，ref可能先加后减最终不变或根据逻辑调整)并刷新TLB
                    ret = page_insert(from, page, start, perm);
                    if (ret != 0) return ret;
                }
                
                // 将该物理页映射给子进程 (to)，权限与父进程一致（此时已变为只读）
                // page_insert 内部会自动增加物理页的引用计数 (ref++)
                ret = page_insert(to, page, start, perm);
                assert(ret == 0);
            }
            else
            {
                // --- 原有逻辑 (Deep Copy / 深拷贝) ---
                // 如果不共享 (如 spawn 等情况)，则分配新物理页并复制内容
                
                // alloc a page for process B
                // 我们将分配移到了这里，只有在非共享模式下才分配新页
                struct Page *npage = alloc_page();
                assert(page != NULL);
                assert(npage != NULL);
                
                /* LAB5:EXERCISE2 2312220 */
                // 1. 获取源页面的内核虚拟地址 (便于内核直接访问读取数据)
                void *kva_src = page2kva(page);
                // 2. 获取目标页面（新分配页）的内核虚拟地址 (便于内核写入数据)
                void *kva_dst = page2kva(npage);
                // 3. 复制内存内容 (复制一整页 4096 字节)
                memcpy(kva_dst, kva_src, PGSIZE);
                // 4. 建立目标进程虚拟地址 start 到新物理页 npage 的映射
                ret = page_insert(to, npage, start, perm);
                assert(ret == 0);
            }
        }
        // 处理下一页
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}

// page_remove - free an Page which is related linear address la and has an validated pte
// 移除 la 地址的映射
void page_remove(pde_t *pgdir, uintptr_t la)
{
    // 获取 PTE
    pte_t *ptep = get_pte(pgdir, la, 0);
    // 如果 PTE 存在，执行移除操作
    if (ptep != NULL)
    {
        page_remove_pte(pgdir, la, ptep);
    }
}

// page_insert - build the map of phy addr of an Page with the linear addr la
// 建立虚拟地址 la 到物理页 page 的映射
// paramemters:
//  pgdir: 页目录基址
//  page:  要映射的物理页结构体
//  la:    线性地址
//  perm:  权限标志
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm)
{
    // 获取 PTE，如果不存在则创建
    pte_t *ptep = get_pte(pgdir, la, 1);
    if (ptep == NULL)
    {
        return -E_NO_MEM;
    }
    
    // 增加物理页的引用计数 (预先增加，处理自映射的情况)
    page_ref_inc(page);
    
    // 如果该 PTE 原本就已经有效（已经映射了某个页）
    if (*ptep & PTE_V)
    {
        struct Page *p = pte2page(*ptep);
        // 如果原本映射的就是当前请求的这个页 (p == page)
        if (p == page)
        {
            // 引用计数减回去 (因为前面加了一次，这里不需要重复增加)
            // 这种情况通常只是修改权限
            page_ref_dec(page);
        }
        else
        {
            // 如果原本映射的是其他页，先移除旧的映射 (会减少旧页的引用计数)
            page_remove_pte(pgdir, la, ptep);
        }
    }
    // 设置 PTE：填入物理页号 (PPN)，设置有效位 (PTE_V) 和传入的权限
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
    // 刷新 TLB，确保新映射生效
    tlb_invalidate(pgdir, la);
    return 0;
}

// invalidate a TLB entry
// 刷新 TLB 条目
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    // 使用 RISC-V 汇编指令 sfence.vma 刷新与地址 la 相关的 TLB
    asm volatile("sfence.vma %0" : : "r"(la));
}

// pgdir_alloc_page - call alloc_page & page_insert functions
// 分配一个新页面并将其映射到指定的线性地址 la
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm)
{
    // 1. 分配物理页
    struct Page *page = alloc_page();
    if (page != NULL)
    {
        // 2. 建立映射
        if (page_insert(pgdir, page, la, perm) != 0)
        {
            // 如果映射失败，释放刚才分配的页
            free_page(page);
            return NULL;
        }
        // (可选) 记录页面对应的虚拟地址，用于页替换算法
        page->pra_vaddr = la;
        // 断言引用计数为 1
        assert(page_ref(page) == 1);
    }

    return page;
}

// 检查分配函数功能的静态测试函数
static void check_alloc_page(void)
{
    // 调用管理器的检查函数
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}

// 检查页目录功能的静态测试函数
static void check_pgdir(void)
{
    // 记录当前的空闲页数
    size_t nr_free_store;
    nr_free_store = nr_free_pages();

    // 一些断言检查
    assert(npage <= KERNTOP / PGSIZE);
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
    // 确保地址 0 还没被映射
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);

    // 分配页面 p1
    struct Page *p1, *p2;
    p1 = alloc_page();
    // 尝试将 p1 映射到地址 0x0
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);

    // 检查映射是否成功
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
    assert(page_ref(p1) == 1);

    // 检查页表结构的连续性假设
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);

    // 分配页面 p2 并映射到 PGSIZE (第二个页的位置)
    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
    assert(*ptep & PTE_U);
    assert(*ptep & PTE_W);
    assert(boot_pgdir_va[0] & PTE_U);
    assert(page_ref(p2) == 1);

    // 将 p1 重新映射到 PGSIZE (覆盖 p2)
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
    assert(page_ref(p1) == 2); // p1 现在被映射了两次 (0x0 和 PGSIZE)
    assert(page_ref(p2) == 0); // p2 被覆盖，引用归零
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
    assert((*ptep & PTE_U) == 0);

    // 移除 0x0 的映射
    page_remove(boot_pgdir_va, 0x0);
    assert(page_ref(p1) == 1);
    assert(page_ref(p2) == 0);

    // 移除 PGSIZE 的映射
    page_remove(boot_pgdir_va, PGSIZE);
    assert(page_ref(p1) == 0);
    assert(page_ref(p2) == 0);

    // 检查中间页表的引用计数
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);

    // 清理测试用的页表
    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
    flush_tlb();

    // 确保没有内存泄漏
    assert(nr_free_store == nr_free_pages());

    cprintf("check_pgdir() succeeded!\n");
}

// 检查启动页表的静态测试函数
static void check_boot_pgdir(void)
{
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    // 遍历内核空间，确保都建立了映射
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(boot_pgdir_va[0] == 0);

    // 测试读写映射
    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
    assert(page_ref(p) == 1);
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
    assert(page_ref(p) == 2);

    // 写入字符串测试
    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);

    *(char *)(page2kva(p) + 0x100) = '\0';
    assert(strlen((const char *)0x100) == 0);

    // 清理
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
// 将权限位转换为字符串显示 (用于调试)
static const char *perm2str(int perm)
{
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
    str[1] = 'r';
    str[2] = (perm & PTE_W) ? 'w' : '-';
    str[3] = '\0';
    return str;
}

// get_pgtable_items - In [left, right] range of PDT or PT, find a continuous linear addr space
// 统计页表中具有相同权限的连续映射项（用于打印页表信息）
static int get_pgtable_items(size_t left, size_t right, size_t start,
                             uintptr_t *table, size_t *left_store,
                             size_t *right_store)
{
    if (start >= right)
    {
        return 0;
    }
    // 跳过无效项
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
        // 获取第一个有效项的权限
        int perm = (table[start++] & PTE_USER);
        // 继续向后找具有相同权限的项
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