#include <vmm.h>
#include <sync.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <error.h>
#include <pmm.h>
#include <riscv.h>
#include <kmalloc.h>

/*
  vmm design include two parts: mm_struct (mm) & vma_struct (vma)
  mm is the memory manager for the set of continuous virtual memory
  area which have the same PDT. vma is a continuous virtual memory area.
  There a linear link list for vma & a redblack link list for vma in mm.
---------------
  mm related functions:
   golbal functions
     struct mm_struct * mm_create(void)
     void mm_destroy(struct mm_struct *mm)
     int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr)
--------------
  vma related functions:
   global functions
     struct vma_struct * vma_create (uintptr_t vm_start, uintptr_t vm_end,...)
     void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
     struct vma_struct * find_vma(struct mm_struct *mm, uintptr_t addr)
   local functions
     inline void check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
---------------
   check correctness functions
     void check_vmm(void);
     void check_vma_struct(void);
     void check_pgfault(void);
*/

// 统计缺页异常发生的次数
volatile unsigned int pgfault_num = 0;
static void check_vmm(void);
static void check_vma_struct(void);

// mm_create -  alloc a mm_struct & initialize it.
// 创建并初始化一个内存描述符 mm_struct
struct mm_struct *
mm_create(void)
{
    // 在内核堆中分配 mm_struct 结构体的内存
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));

    if (mm != NULL)
    {
        // 初始化 VMA 链表头
        list_init(&(mm->mmap_list));
        // 初始化 mmap_cache（用于加速查找的缓存指针）
        mm->mmap_cache = NULL;
        // 页目录指针初始化为空
        mm->pgdir = NULL;
        // VMA 数量初始化为 0
        mm->map_count = 0;

        // 如果有交换管理器私有数据，可以在此初始化
        mm->sm_priv = NULL;

        // 设置引用计数为 0
        set_mm_count(mm, 0);
        // 初始化保护 mm_struct 的互斥锁（实验中可能未使用）
        lock_init(&(mm->mm_lock));
    }
    return mm;
}

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
// 创建一个虚拟内存区域描述符 vma_struct
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags)
{
    // 在内核堆中分配 vma_struct
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));

    if (vma != NULL)
    {
        // 设置区域起始地址
        vma->vm_start = vm_start;
        // 设置区域结束地址
        vma->vm_end = vm_end;
        // 设置区域标志位 (如 VM_READ, VM_WRITE, VM_EXEC)
        vma->vm_flags = vm_flags;
    }
    return vma;
}

// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
// 查找包含指定虚拟地址 addr 的 VMA
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr)
{
    struct vma_struct *vma = NULL;
    if (mm != NULL)
    {
        // 1. 尝试从缓存 (mmap_cache) 中查找，利用局部性原理加速
        vma = mm->mmap_cache;
        // 如果缓存为空，或者 addr 不在缓存指向的 VMA 范围内
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
        {
            // 2. 遍历 VMA 链表进行线性查找
            bool found = 0;
            list_entry_t *list = &(mm->mmap_list), *le = list;
            while ((le = list_next(le)) != list)
            {
                // 获取链表节点对应的 vma 结构体
                vma = le2vma(le, list_link);
                // 检查 addr 是否在当前 VMA 范围内
                if (vma->vm_start <= addr && addr < vma->vm_end)
                {
                    found = 1;
                    break;
                }
            }
            // 如果没找到，置空 vma
            if (!found)
            {
                vma = NULL;
            }
        }
        // 如果找到了 VMA，更新缓存，以便下次快速访问
        if (vma != NULL)
        {
            mm->mmap_cache = vma;
        }
    }
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
// 检查两个 VMA 是否重叠（断言检查）
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
{
    assert(prev->vm_start < prev->vm_end);
    // 前一个 VMA 的结束必须小于等于后一个 VMA 的开始
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
}

// insert_vma_struct -insert vma in mm's list link
// 将一个新的 VMA 插入到 mm 的链表中（按地址排序）
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

    // 寻找插入位置：找到第一个起始地址大于 vma->vm_start 的节点
    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
        {
            break;
        }
        le_prev = le;
    }

    le_next = list_next(le_prev);

    /* check overlap - 检查是否与前后节点重叠 */
    if (le_prev != list)
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
    }
    if (le_next != list)
    {
        check_vma_overlap(vma, le2vma(le_next, list_link));
    }

    // 设置 VMA 所属的 mm
    vma->vm_mm = mm;
    // 将 vma 插入到 le_prev 之后
    list_add_after(le_prev, &(vma->list_link));

    // 增加 mm 中的映射计数
    mm->map_count++;
}

// mm_destroy - free mm and mm internal fields
// 销毁 mm_struct 及其挂载的所有 vma_struct
void mm_destroy(struct mm_struct *mm)
{
    // 确保此时引用计数为 0
    assert(mm_count(mm) == 0);

    list_entry_t *list = &(mm->mmap_list), *le;
    // 遍历并删除所有 VMA
    while ((le = list_next(list)) != list)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // 释放 vma 结构体内存
    }
    kfree(mm); // 释放 mm 结构体内存
    mm = NULL;
}

// mm_map - 建立一段虚拟地址映射（创建 VMA 并插入）
int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
    // 地址对齐
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
    // 检查是否超出用户空间范围
    if (!USER_ACCESS(start, end))
    {
        return -E_INVAL;
    }

    assert(mm != NULL);

    int ret = -E_INVAL;

    struct vma_struct *vma;
    // 检查新区域是否与现有 VMA 重叠
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
    {
        goto out;
    }
    ret = -E_NO_MEM;

    // 创建新的 VMA
    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    // 插入 mm
    insert_vma_struct(mm, vma);
    // 如果需要返回 vma 指针
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;

out:
    return ret;
}

// dup_mmap - 复制内存映射 (fork 时使用)
// 将 from 的内存布局复制给 to
int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
    assert(to != NULL && from != NULL);
    list_entry_t *list = &(from->mmap_list), *le = list;
    // 遍历父进程 (from) 的所有 VMA
    while ((le = list_prev(le)) != list)
    {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        // 为子进程创建相同的 VMA
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        // 插入子进程的 mm
        insert_vma_struct(to, nvma);

        // 复制页表内容 (核心逻辑在 copy_range 中)
        // bool share = 1 表示启用共享 (Copy on Write)
        bool share = 1;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}

// exit_mmap - 进程退出时释放内存资源
void exit_mmap(struct mm_struct *mm)
{
    assert(mm != NULL && mm_count(mm) == 0);
    pde_t *pgdir = mm->pgdir;
    list_entry_t *list = &(mm->mmap_list), *le = list;
    // 第一遍遍历：取消所有页面的映射 (unmap_range)
    // 这会释放物理页的引用计数，如果归零则释放物理页
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    // 第二遍遍历：释放页表本身占用的内存 (exit_range)
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
    }
}

// copy_from_user - 从用户空间复制数据到内核空间
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable)
{
    // 检查源地址范围是否合法
    if (!user_mem_check(mm, (uintptr_t)src, len, writable))
    {
        return 0;
    }
    // 执行复制
    memcpy(dst, src, len);
    return 1;
}

// copy_to_user - 从内核空间复制数据到用户空间
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len)
{
    // 检查目标地址范围是否合法且可写
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1))
    {
        return 0;
    }
    // 执行复制
    memcpy(dst, src, len);
    return 1;
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
    check_vmm();
}

// check_vmm - check correctness of vmm
// 检查 VMM 逻辑的正确性
static void
check_vmm(void)
{
    // size_t nr_free_pages_store = nr_free_pages();

    check_vma_struct();
    // check_pgfault();

    cprintf("check_vmm() succeeded.\n");
}

// check_vma_struct - 检查 VMA 链表操作的正确性
static void
check_vma_struct(void)
{
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    // 逆序插入
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    // 正序插入
    for (i = step1 + 1; i <= step2; i++)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    // 检查链表顺序是否正确（应当是升序）
    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
    {
        assert(le != &(mm->mmap_list));
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    // 检查 find_vma 功能
    for (i = 5; i <= 5 * step2; i += 5)
    {
        struct vma_struct *vma1 = find_vma(mm, i);
        assert(vma1 != NULL);
        struct vma_struct *vma2 = find_vma(mm, i + 1);
        assert(vma2 != NULL);
        struct vma_struct *vma3 = find_vma(mm, i + 2);
        assert(vma3 == NULL);
        struct vma_struct *vma4 = find_vma(mm, i + 3);
        assert(vma4 == NULL);
        struct vma_struct *vma5 = find_vma(mm, i + 4);
        assert(vma5 == NULL);

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
    }

    // 检查边界
    for (i = 4; i >= 0; i--)
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
        if (vma_below_5 != NULL)
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
}

// user_mem_check - 检查一段用户空间内存是否合法且具有相应权限
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
    if (mm != NULL)
    {
        // 检查地址是否都在用户空间范围内
        if (!USER_ACCESS(addr, addr + len))
        {
            return 0;
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
        // 遍历范围内的所有部分，确保每一部分都在合法的 VMA 中
        while (start < end)
        {
            // 查找包含当前 start 地址的 VMA
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
            {
                return 0; // 没找到 VMA，访问非法
            }
            // 检查权限
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
            {
                return 0;
            }
            // 如果是栈操作，做额外的栈检查 (uCore 中简单的栈增长检查)
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
                { // check stack start & size
                    return 0;
                }
            }
            // 跳到当前 VMA 的结束，继续检查下一段
            start = vma->vm_end;
        }
        return 1;
    }
    // 如果是内核线程，直接检查是否在内核地址空间
    return KERN_ACCESS(addr, addr + len);
}


// 定义一个全局标志位，用于控制是否开启模拟 Dirty COW 攻击
bool TEST_DIRTY_COW_FLAG = 0;

// do_pgfault - 处理缺页异常的核心函数
// mm: 进程内存描述符
// error_code: 异常错误码 (标识读/写/不存在等)
// addr: 触发异常的虚拟地址
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;
    // 查找包含 addr 的 VMA
    struct vma_struct *vma = find_vma(mm, addr);

    // 统计缺页次数
    pgfault_num++; 

    // 如果地址不在任何 VMA 范围内，说明是无效访问 (Segfault)
    if (vma == NULL || vma->vm_start > addr) {
        return -E_INVAL;
    }

    // 权限检查：如果尝试写一个不可写的 VMA，直接报错
    if ((error_code & 2) && !(vma->vm_flags & VM_WRITE)) {
        return -E_INVAL;
    }

    // 根据 VMA 属性构建需要的页表权限 perm
    uint32_t perm = PTE_U; // 用户态权限
    if (vma->vm_flags & VM_WRITE) {
        perm |= (PTE_R | PTE_W);
    }
    if (vma->vm_flags & VM_READ) {
        perm |= PTE_R;
    }
    if (vma->vm_flags & VM_EXEC) {
        perm |= PTE_X;
    }

    // 将地址向下对齐到页边界
    addr = ROUNDDOWN(addr, PGSIZE);
    ret = -E_NO_MEM;
    pte_t *ptep = NULL;

    // 获取对应的页表项 (PTE)，如果中间页表不存在则分配 (create=1)
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
        return ret;
    }
    
    // Case 1: 页表项全为0，说明尚未建立映射 (Demand Paging / 按需分页)
    // 此时分配一个新的物理页并映射
    if (*ptep == 0) { 
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            return ret;
        }
    } 
    // Case 2: 页表项存在，可能是 Copy-on-Write 或者 Swap (本实验暂不考虑swap)
    else { 
        if (*ptep & PTE_V) {
            // LAB5 CHALLENGE: Copy on Write 处理
            // 判断条件：这是写操作 (error_code & 2) 
            //          && 且物理页目前是只读的 (!(*ptep & PTE_W))
            //          && 且 VMA 本身允许写入 (vma->vm_flags & VM_WRITE)
            // 这意味着这是一个共享的页面，现在进程试图修改它
            if ((error_code & 2) && !(*ptep & PTE_W) && (vma->vm_flags & VM_WRITE)) {
                struct Page *page = pte2page(*ptep);
                
                // 情况 A: 页面被多个进程共享 (Reference Count > 1)
                // 需要执行“复制”操作：分配新页，拷贝内容，重新映射给当前进程
                if (page_ref(page) > 1) {
                    // 分配一个新的物理页
                    struct Page *npage = alloc_page();
                    if (npage == NULL) return ret;
                    
                    // 复制原页面内容到新页面 (Deep Copy)
                    memcpy(page2kva(npage), page2kva(page), PGSIZE);


                    // =========================================================
                    // 【Dirty COW 模拟注入点】
                    // 模拟场景：攻击者在主线程进行 COW 缺页处理（正在复制内存）的同时，
                    // 在另一个线程调用 madvise(MADV_DONTNEED)，试图丢弃该页面映射。
                    // =========================================================
                    if (TEST_DIRTY_COW_FLAG) {
                        cprintf("[DirtyCOW] ATTACK: Another thread clears the PTE now!\n");
                        
                        // 1. 清空 PTE：模拟另一个线程解除了映射
                        *ptep = 0; 
                        
                        // 2. 刷新 TLB：确保 CPU 感知到映射已失效
                        tlb_invalidate(mm->pgdir, addr);
                        
                        // 3. 减少引用计数：模拟 madvise 导致的页面释放。
                        // 如果引用计数降为 0，该物理页会被回收。
                        // 这里手动减 1 是为了保持引用计数逻辑的一致性，防止内存泄漏或状态错误。
                        page_ref_dec(page); 
                    }
                    // =========================================================

                    // =========================================================
                    // [漏洞修复 / 竞态检测]
                    // 在执行原子性的页表更新（page_insert）之前，必须再次检查前提条件是否依然成立。
                    // =========================================================
                    // 检查 1: (*ptep & PTE_V) == 0 
                    //    含义：页表项是否被清空了？（比如上面的 madvise 攻击）
                    // 检查 2: pte2page(*ptep) != page
                    //    含义：页表项指向的物理页是否改变了？（比如被重新映射到了别的页）
                    if ((*ptep & PTE_V) == 0 || pte2page(*ptep) != page) {
                        cprintf("[DirtyCOW] Race detected! Retrying...\n");
                    
                        // 关键步骤：释放刚才申请用于 COW 的新物理页 npage。
                        // 因为映射失败了，如果不释放，这个新页就成了“孤儿”，导致内核内存泄漏。
                        free_page(npage); 
                    
                        // 返回 0：告诉异常处理机制“这次缺页处理由于竞争失败了，但不是错误”。
                        // 结果：CPU 会重新执行刚才触发异常的那条写指令。
                        // 由于映射已经被清空（如果被攻击），重执行会再次触发缺页异常，
                        // 内核会重新进入 do_pgfault，按 Demand Paging (空 PTE) 的逻辑处理，
                        // 从而避免了向错误的物理页写入数据。
                        return 0; 
                    }
                // =========================================================
                    
                    // 建立新映射：
                    // 1. page_insert 会把虚拟地址 addr 映射到 npage
                    // 2. npage 的 ref 会增加
                    // 3. 原 page 的 ref 会自动减少 (因为该地址原先映射的页被覆盖了)
                    // 4. 注意：这里赋予了 PTE_W 写权限，因为这是该进程私有的新页
                    if (page_insert(mm->pgdir, npage, addr, perm) != 0) {
                        return ret;
                    }
                } 
                // 情况 B: 页面只有当前进程在使用 (Reference Count == 1)
                // 说明其他共享的进程已经退出，或者经过多次COW后只剩自己。
                // 此时只需要恢复写权限即可，无需发生物理内存拷贝。
                else {
                    // page_insert 会检测到是同一个页，只更新权限并刷新 TLB
                    if (page_insert(mm->pgdir, page, addr, perm) != 0) {
                        return ret;
                    }
                }
            } else {
                // 如果不是 COW 情况的权限错误（例如尝试写只读代码段），则返回错误
                return ret; 
            }
        }
    }
    return 0;
}