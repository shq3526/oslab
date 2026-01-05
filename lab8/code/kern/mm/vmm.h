/*
 * kern/mm/vmm.h
 *
 * 本文件定义了虚拟内存管理 (VMM) 的核心数据结构和函数原型。
 *
 * 主要包含两个核心结构体：
 * 1. vma_struct (Virtual Memory Area):
 * 描述进程虚拟地址空间中一段连续的区域（如代码段、数据段、栈）。
 * 它定义了区域的范围 [vm_start, vm_end) 以及访问权限 (读/写/执行)。
 *
 * 2. mm_struct (Memory Management Struct):
 * 描述一个进程的完整虚拟内存布局。
 * 它包含了一个 vma_struct 的链表，以及指向页目录表 (pgdir) 的指针。
 * 在进程控制块 (proc_struct) 中，通常有一个指向 mm_struct 的指针。
 */

#ifndef __KERN_MM_VMM_H__
#define __KERN_MM_VMM_H__

#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <sync.h>
#include <sem.h>
#include <proc.h>
// pre define
struct mm_struct;

// the virtual continuous memory area(vma), [vm_start, vm_end),
// addr belong to a vma means  vma.vm_start<= addr <vma.vm_end
/*
 * 虚拟内存区域结构体 (VMA)
 * 描述一段连续的虚拟地址范围。
 * 类似于 Linux 中的 vm_area_struct。
 */
struct vma_struct
{
    struct mm_struct *vm_mm; // the set of vma using the same PDT
                             // 指向所属的 mm_struct (反向指针)
    uintptr_t vm_start;      // start addr of vma
                             // 区域起始虚拟地址 (包含)
    uintptr_t vm_end;        // end addr of vma, not include the vm_end itself
                             // 区域结束虚拟地址 (不包含，即开区间)
    uint32_t vm_flags;       // flags of vma
                             // 区域标志位 (VM_READ, VM_WRITE, VM_EXEC 等)
    list_entry_t list_link;  // linear list link which sorted by start addr of vma
                             // 链表节点，用于将该 VMA 链接到 mm_struct 的 mmap_list 中
                             // 链表通常按 vm_start 从小到大排序
};

// 通过链表节点获取 vma_struct 指针的宏
#define le2vma(le, member) \
    to_struct((le), struct vma_struct, member)

/* VMA 权限标志位定义 */
#define VM_READ 0x00000001  // 可读
#define VM_WRITE 0x00000002 // 可写
#define VM_EXEC 0x00000004  // 可执行
#define VM_STACK 0x00000008 // 标识该 VMA 是栈区 (可能涉及栈增长检查)

// the control struct for a set of vma using the same PDT
/*
 * 进程内存描述符结构体 (mm_struct)
 * 管理一个进程所有的虚拟内存区域。
 */
struct mm_struct
{
    list_entry_t mmap_list;        // linear list link which sorted by start addr of vma
                                   // 连接所有 vma_struct 的双向链表头
    struct vma_struct *mmap_cache; // current accessed vma, used for speed purpose
                                   // VMA 缓存：指向上一次成功查找的 VMA。
                                   // 利用程序的局部性原理，加速 find_vma 查找。
    pde_t *pgdir;                  // the PDT of these vma
                                   // 页目录表 (Page Directory Table) 的内核虚拟地址。
                                   // 它是硬件 MMU 进行地址转换的根。
    int map_count;                 // the count of these vma
                                   // 当前包含的 VMA 总数
    void *sm_priv;                 // the private data for swap manager
                                   // Swap 管理器的私有数据 (用于页面置换算法，如记录访问历史)
    int mm_count;                  // the number ofprocess which shared the mm
                                   // 引用计数：有多少个进程共享这个 mm_struct。
                                   // 通常为 1，但在多线程(CLONE_VM)情况下可能 > 1。
    semaphore_t mm_sem;            // mutex for using dup_mmap fun to duplicat the mm
                                   // 互斥信号量：保护 mm_struct 内部数据的并发访问 (如 mmap_list, pgdir)
    int locked_by;                 // 记录持有锁的进程 PID (调试用)
};

/* --- VMA 操作接口 --- */

// 根据虚拟地址 addr 查找其所在的 VMA
struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr);
// 创建一个新的 VMA 结构体
struct vma_struct *vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags);
// 将 VMA 插入到 mm 的链表中 (会维护链表有序性)
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma);

/* --- mm_struct 生命周期管理 --- */

// 创建并初始化 mm_struct
struct mm_struct *mm_create(void);
// 销毁 mm_struct (释放所有 VMA 和自身内存)
void mm_destroy(struct mm_struct *mm);

/* --- 内存映射核心功能 --- */

// VMM 子系统初始化
void vmm_init(void);
// 建立映射：在 addr 位置分配 len 长度的虚拟内存，权限为 vm_flags
int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store);
// 解除映射 (Munmap)：释放指定范围的虚拟内存
int mm_unmap(struct mm_struct *mm, uintptr_t addr, size_t len);
// 复制内存空间：将 from 的所有 VMA 和页表内容复制给 to (用于 fork)
int dup_mmap(struct mm_struct *to, struct mm_struct *from);
// 退出内存空间：释放 mm 管理的所有资源 (用于 exit)
void exit_mmap(struct mm_struct *mm);
// 查找一段未被映射的空闲虚拟地址空间
uintptr_t get_unmapped_area(struct mm_struct *mm, size_t len);
// 调整堆大小 (sbrk/brk 系统调用后端)
int mm_brk(struct mm_struct *mm, uintptr_t addr, size_t len);

// extern volatile unsigned int pgfault_num;
extern struct mm_struct *check_mm_struct;

/* --- 用户空间访问安全检查 --- */

// 检查用户空间地址范围 [start, start+len) 是否合法 (即是否都在有效的 VMA 内且权限匹配)
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
// 从用户空间拷贝数据到内核 (包含安全性检查)
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
// 从内核空间拷贝数据到用户空间 (包含安全性检查)
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);
// 安全地从用户空间拷贝字符串
bool copy_string(struct mm_struct *mm, char *dst, const char *src, size_t maxn);

/* --- 内联函数：引用计数与锁 --- */

// 获取引用计数
static inline int
mm_count(struct mm_struct *mm)
{
    return mm->mm_count;
}

// 设置引用计数
static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
}

// 增加引用计数
static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
    return mm->mm_count;
}

// 减少引用计数
static inline int
mm_count_dec(struct mm_struct *mm)
{
    mm->mm_count -= 1;
    return mm->mm_count;
}

// 获取 mm 锁 (P操作)
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        down(&(mm->mm_sem));
        if (current != NULL)
        {
            mm->locked_by = current->pid;
        }
    }
}

// 释放 mm 锁 (V操作)
static inline void
unlock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        up(&(mm->mm_sem));
        mm->locked_by = 0;
    }
}

#endif /* !__KERN_MM_VMM_H__ */