/*
 * kern/mm/vmm.c
 *
 * 本文件实现了虚拟内存管理 (Virtual Memory Management) 子系统。
 * 主要涉及两个核心数据结构：
 * 1. mm_struct (mm): 描述一个进程的整个虚拟内存空间。
 * - 包含页目录表指针 (pgdir)。
 * - 包含一个 VMA 链表 (mmap_list)，按地址排序。
 * - 包含一个缓存指针 (mmap_cache)，用于加速查找。
 *
 * 2. vma_struct (vma): 描述一段连续的虚拟内存区域。
 * - 定义了起始地址 (vm_start) 和结束地址 (vm_end)。
 * - 定义了该区域的属性 (vm_flags，如读、写、执行)。
 *
 * 主要功能：
 * - 创建、销毁和管理 mm 和 vma。
 * - 处理缺页异常（虽然 do_pgfault 的具体实现在其他文件，但 vmm 提供了基础结构支持）。
 * - 提供用户内存访问的合法性检查 (user_mem_check)。
 */

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

static void check_vmm(void);
static void check_vma_struct(void);

// mm_create -  alloc a mm_struct & initialize it.
// 创建一个新的 mm_struct，通常在进程创建时调用。
struct mm_struct *
mm_create(void)
{
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));

    if (mm != NULL)
    {
        list_init(&(mm->mmap_list)); // 初始化 VMA 链表头
        mm->mmap_cache = NULL;       // 初始化 VMA 缓存
        mm->pgdir = NULL;            // 页目录表暂为空，后续分配
        mm->map_count = 0;           // VMA 计数

        mm->sm_priv = NULL;          // Swap 管理相关私有数据

        set_mm_count(mm, 0);         // 引用计数初始化
        sem_init(&(mm->mm_sem), 1);  // 初始化互斥信号量
    }
    return mm;
}

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
// 创建一个新的 vma_struct，描述 [vm_start, vm_end) 的虚拟地址范围。
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags)
{
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));

    if (vma != NULL)
    {
        vma->vm_start = vm_start;
        vma->vm_end = vm_end;
        vma->vm_flags = vm_flags;
    }
    return vma;
}

// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
// 查找包含指定虚拟地址 addr 的 VMA。
// 如果找到，返回该 vma 指针；否则返回 NULL。
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr)
{
    struct vma_struct *vma = NULL;
    if (mm != NULL)
    {
        // 1. 尝试从缓存中查找 (局部性原理，最近访问的 VMA 很可能再次被访问)
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
        {
            // 2. 缓存未命中，遍历链表查找
            bool found = 0;
            list_entry_t *list = &(mm->mmap_list), *le = list;
            while ((le = list_next(le)) != list)
            {
                vma = le2vma(le, list_link);
                // 检查 addr 是否在当前 vma 范围内
                if (vma->vm_start <= addr && addr < vma->vm_end)
                {
                    found = 1;
                    break;
                }
            }
            if (!found)
            {
                vma = NULL;
            }
        }
        // 3. 如果找到了，更新缓存
        if (vma != NULL)
        {
            mm->mmap_cache = vma;
        }
    }
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
// 检查两个 VMA 是否重叠。VMA 必须按地址递增排列且无重叠。
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start); // 前一个的结束必须 <= 后一个的开始
    assert(next->vm_start < next->vm_end);
}

// insert_vma_struct -insert vma in mm's list link
// 将一个新的 VMA 插入到 mm 的链表中，保持链表按 vm_start 排序。
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

    list_entry_t *le = list;
    // 遍历链表，找到合适的插入位置
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

    /* check overlap */
    // 检查是否与前一个或后一个 VMA 重叠
    if (le_prev != list)
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
    }
    if (le_next != list)
    {
        check_vma_overlap(vma, le2vma(le_next, list_link));
    }

    vma->vm_mm = mm;
    // 插入链表
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
}

// mm_destroy - free mm and mm internal fields
// 销毁 mm_struct，释放其中所有的 VMA 和 mm 自身占用的内存。
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0); // 确保引用计数为 0

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
    }
    kfree(mm); // kfree mm
    mm = NULL;
}

// mm_map - 建立一段虚拟内存映射
// 在 mm 中创建一个覆盖 [addr, addr + len) 的新 VMA，并插入链表。
int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
    // 检查地址范围是否在合法的用户空间内
    if (!USER_ACCESS(start, end))
    {
        return -E_INVAL;
    }

    assert(mm != NULL);

    int ret = -E_INVAL;

    struct vma_struct *vma;
    // 检查是否已经存在重叠的 VMA
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
    {
        goto out;
    }
    ret = -E_NO_MEM;

    // 创建并插入新 VMA
    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;

out:
    return ret;
}

// dup_mmap - 复制内存映射 (Fork 核心)
// 将 from (父进程) 的所有 VMA 复制给 to (子进程)，并复制页表内容。
int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
    assert(to != NULL && from != NULL);
    list_entry_t *list = &(from->mmap_list), *le = list;
    // 遍历父进程的 VMA 链表
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

        insert_vma_struct(to, nvma);

        bool share = 0;
        // 复制页表项和物理页内容 (Copy-on-Write 可以在这里优化，目前是深拷贝)
        // 调用 pmm.c 中的 copy_range
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}

// exit_mmap - 退出内存映射 (Exit 核心)
// 解除 mm 关联的所有 VMA 的映射，释放对应的页表和物理页资源。
void exit_mmap(struct mm_struct *mm)
{
    assert(mm != NULL && mm_count(mm) == 0);
    pde_t *pgdir = mm->pgdir;
    list_entry_t *list = &(mm->mmap_list), *le = list;
    // 遍历所有 VMA，解除映射 (释放物理页)
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    // 再次遍历，释放页表本身占用的内存
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
    }
}

// copy_from_user - 从用户空间拷贝数据到内核空间
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable)
{
    // 检查用户源地址 src 是否合法 (是否在 VMA 内，且有对应权限)
    if (!user_mem_check(mm, (uintptr_t)src, len, writable))
    {
        return 0;
    }
    memcpy(dst, src, len);
    return 1;
}

// copy_to_user - 从内核空间拷贝数据到用户空间
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len)
{
    // 检查用户目的地址 dst 是否合法 (是否在 VMA 内，且可写)
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1))
    {
        return 0;
    }
    memcpy(dst, src, len);
    return 1;
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
// VMM 初始化函数 (目前主要用于自检)
void vmm_init(void)
{
    check_vmm();
}

// check_vmm - check correctness of vmm
static void
check_vmm(void)
{
    // size_t nr_free_pages_store = nr_free_pages();

    check_vma_struct();
    // check_pgfault();

    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void)
{
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i++)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
    {
        assert(le != &(mm->mmap_list));
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

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

// user_mem_check - check the legality of user memory access
// 检查用户内存访问权限
// 遍历 [addr, addr + len) 覆盖的所有 VMA，确保它们都存在且具有指定的权限。
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
    if (mm != NULL)
    {
        if (!USER_ACCESS(addr, addr + len))
        {
            return 0;
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
        while (start < end)
        {
            // 查找包含 start 地址的 VMA
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
            {
                return 0; // 地址未被映射
            }
            // 检查权限 (write 为 true 时检查 VM_WRITE，否则检查 VM_READ)
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
            {
                return 0; // 权限不足
            }
            // 栈检查：如果涉及栈区 (VM_STACK)，做额外的栈增长方向检查（可选）
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end; // 跳到下一个 VMA 继续检查
        }
        return 1;
    }
    // 如果是内核线程 (mm == NULL)，直接检查地址是否在内核空间
    return KERN_ACCESS(addr, addr + len);
}

// copy_string - 安全地从用户空间拷贝字符串到内核缓冲区
bool copy_string(struct mm_struct *mm, char *dst, const char *src,
                 size_t maxn)
{
    size_t alen,
        part = ROUNDDOWN((uintptr_t)src + PGSIZE, PGSIZE) - (uintptr_t)src;
    while (1)
    {
        if (part > maxn)
        {
            part = maxn;
        }
        // 检查源字符串内存块的合法性
        if (!user_mem_check(mm, (uintptr_t)src, part, 0))
        {
            return 0;
        }
        // 尝试拷贝字符串，如果遇到 null 终止符则提前结束
        if ((alen = strnlen(src, part)) < part)
        {
            memcpy(dst, src, alen + 1);
            return 1;
        }
        if (part == maxn)
        {
            return 0; // 超过最大长度限制
        }
        // 还没结束，继续拷贝下一页
        memcpy(dst, src, part);
        dst += part, src += part, maxn -= part;
        part = PGSIZE;
    }
}