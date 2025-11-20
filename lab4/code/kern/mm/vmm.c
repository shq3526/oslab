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
  [虚拟内存管理 (VMM) 设计与实现]

  VMM 设计包含两个核心部分：mm_struct (简称 mm) 和 vma_struct (简称 vma)。

  1. mm_struct (内存描述符):
     - 它是整个进程虚拟内存空间的管理器。
     - 拥有相同页目录表 (PDT) 的一组连续虚拟内存区域 (VMA) 归属于同一个 mm。
     - 每个进程通常有一个 mm_struct。

  2. vma_struct (虚拟内存区域):
     - 代表了一段连续的虚拟内存地址范围 (如 [0x1000, 0x2000))。
     - 拥有特定的属性 (如 只读、读写、可执行)。
     - 所有的 vma 通过线性链表连接在一起，挂在 mm_struct 下。
     - (高级实现中通常还会使用红黑树来加速查找，本实验仅使用链表)。

---------------
  mm 相关函数:
   全局函数
     struct mm_struct * mm_create(void)        // 创建并初始化 mm
     void mm_destroy(struct mm_struct *mm)     // 销毁 mm 及其包含的所有 vma
     int do_pgfault(struct mm_struct *mm, ...) // 处理缺页异常 (本文件未实现，通常在其他文件中)

--------------
  vma 相关函数:
   全局函数
     struct vma_struct * vma_create (...)      // 创建并初始化 vma
     void insert_vma_struct(...)               // 将 vma 插入到 mm 的链表中 (保持有序)
     struct vma_struct * find_vma(...)         // 查找包含特定地址的 vma

   本地函数
     inline void check_vma_overlap(...)        // 检查 vma 之间是否有重叠
---------------
   正确性检查函数:
     void check_vmm(void);
     void check_vma_struct(void);
     void check_pgfault(void);
*/

// szx func : print_vma and print_mm
// 辅助调试函数：打印 vma 信息
void print_vma(char *name, struct vma_struct *vma)
{
    cprintf("-- %s print_vma --\n", name);
    cprintf("   mm_struct: %p\n", vma->vm_mm);
    cprintf("   vm_start,vm_end: %x,%x\n", vma->vm_start, vma->vm_end);
    cprintf("   vm_flags: %x\n", vma->vm_flags);
    cprintf("   list_entry_t: %p\n", &vma->list_link);
}

// 辅助调试函数：打印 mm 及其所有 vma 信息
void print_mm(char *name, struct mm_struct *mm)
{
    cprintf("-- %s print_mm --\n", name);
    cprintf("   mmap_list: %p\n", &mm->mmap_list);
    cprintf("   map_count: %d\n", mm->map_count);
    list_entry_t *list = &mm->mmap_list;
    for (int i = 0; i < mm->map_count; i++)
    {
        list = list_next(list);
        print_vma(name, le2vma(list, list_link));
    }
}

static void check_vmm(void);
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create - 分配一个 mm_struct 并初始化它
// 这个结构体将作为新进程的内存管理器
struct mm_struct *
mm_create(void)
{
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));

    if (mm != NULL)
    {
        // 初始化 VMA 链表头
        list_init(&(mm->mmap_list));
        // mmap_cache 用于加速查找，初始为空
        mm->mmap_cache = NULL;
        // 页目录表指针，初始为空 (稍后会分配)
        mm->pgdir = NULL;
        // 当前拥有的 VMA 数量
        mm->map_count = 0;
        // 共享内存私有数据指针 (本实验可能未用到)
        mm->sm_priv = NULL;
    }
    return mm;
}

// vma_create - 分配一个 vma_struct 并初始化
// 参数:
//   vm_start: 起始虚拟地址
//   vm_end:   结束虚拟地址 (不包含)
//   vm_flags: 权限标志 (如 VM_READ, VM_WRITE)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags)
{
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));

    if (vma != NULL)
    {
        vma->vm_start = vm_start;
        vma->vm_end = vm_end;
        vma->vm_flags = vm_flags;
        // vma->vm_mm 将在 insert_vma_struct 时设置
    }
    return vma;
}

// find_vma - 查找包含指定地址 addr 的 vma
// 条件: vma->vm_start <= addr < vma->vm_end
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr)
{
    struct vma_struct *vma = NULL;
    if (mm != NULL)
    {
        // 1. 尝试使用 mmap_cache 进行快速查找
        // 原理：程序的内存访问通常具有局部性原理 (Locality of Reference)。
        // 最近一次访问的 VMA 很有可能就是下一次访问的 VMA，或者在附近。
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
        {
            // 2. 如果缓存未命中，则遍历线性链表
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
        // 3. 如果找到了，更新 mmap_cache，以便下次能更快找到
        if (vma != NULL)
        {
            mm->mmap_cache = vma;
        }
    }
    return vma;
}

// check_vma_overlap - 检查 vma1 (prev) 和 vma2 (next) 是否重叠
// 这是一个内联函数，用于 insert_vma_struct 中确保链表的有序性和无重叠性
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
{
    // 确保每个 VMA 自身的 start < end
    assert(prev->vm_start < prev->vm_end);
    // 确保前一个 VMA 的结束地址 <= 后一个 VMA 的起始地址
    // (即不允许重叠)
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
}

// insert_vma_struct - 将 vma 插入到 mm 的链表中
// 策略：保持链表按 vm_start 从小到大排序，并且没有重叠。
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

    list_entry_t *le = list;
    // 1. 寻找插入位置
    // 遍历链表，找到第一个起始地址比 vma 大的节点，然后停在它的前驱节点
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

    /* 2. 检查重叠 (Overlap Check) */
    // 检查与前一个节点是否重叠
    if (le_prev != list)
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
    }
    // 检查与后一个节点是否重叠
    if (le_next != list)
    {
        check_vma_overlap(vma, le2vma(le_next, list_link));
    }

    // 设置 vma 的归属 mm
    vma->vm_mm = mm;
    // 3. 执行插入操作 (插入到 le_prev 之后)
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
}

// mm_destroy - 释放 mm 及其内部字段
// 当进程退出时调用，清理所有的虚拟内存管理结构
void mm_destroy(struct mm_struct *mm)
{

    list_entry_t *list = &(mm->mmap_list), *le;
    // 遍历并释放所有的 vma 结构体
    while ((le = list_next(list)) != list)
    {
        list_del(le); // 从链表移除
        kfree(le2vma(le, list_link)); // 释放 vma 内存
    }
    kfree(mm); // 释放 mm 结构体本身
    mm = NULL;
}

// vmm_init - 初始化虚拟内存管理子系统
// 目前只调用检查函数来验证 VMM 的正确性
void vmm_init(void)
{
    check_vmm();
}

// check_vmm - 检查 VMM 的正确性
static void
check_vmm(void)
{
    check_vma_struct();
    // check_pgfault(); // 缺页异常检查 (可能尚未实现)

    cprintf("check_vmm() succeeded.\n");
}

// check_vma_struct - 测试 VMA 创建、插入和查找逻辑
static void
check_vma_struct(void)
{
    struct mm_struct *mm = mm_create();
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    // 1. 逆序插入一批 VMA
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    // 2. 正序插入另一批 VMA
    for (i = step1 + 1; i <= step2; i++)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    // 3. 验证链表是否有序
    // 即使插入顺序是乱的，链表遍历出来应该是按地址从小到大排序的
    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
    {
        assert(le != &(mm->mmap_list));
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    // 4. 验证 find_vma 功能
    for (i = 5; i <= 5 * step2; i += 5)
    {
        // 查找正好在 vma 范围内的地址
        struct vma_struct *vma1 = find_vma(mm, i);
        assert(vma1 != NULL);
        struct vma_struct *vma2 = find_vma(mm, i + 1);
        assert(vma2 != NULL);
        
        // 查找 vma 间隙中的地址 (应该返回 NULL)
        struct vma_struct *vma3 = find_vma(mm, i + 2);
        assert(vma3 == NULL);
        struct vma_struct *vma4 = find_vma(mm, i + 3);
        assert(vma4 == NULL);
        struct vma_struct *vma5 = find_vma(mm, i + 4);
        assert(vma5 == NULL);

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
    }

    // 5. 边界测试
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