#ifndef __KERN_MM_VMM_H__
#define __KERN_MM_VMM_H__

#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <sync.h>

// pre define
// 预声明 mm_struct 结构体，因为 vma_struct 内部需要引用它
struct mm_struct;

// the virtual continuous memory area(vma), [vm_start, vm_end),
// addr belong to a vma means  vma.vm_start<= addr <vma.vm_end
// vma_struct 描述一段连续的虚拟内存区域 (Virtual Memory Area)
// 这段区域内的内存拥有相同的属性（权限、标志等）
struct vma_struct
{
    // 指向所属的内存描述符 (mm_struct)
    // 所有的 VMA 都属于某个 mm_struct (即某个进程)
    struct mm_struct *vm_mm; 
    
    // VMA 的起始虚拟地址 (包含)
    uintptr_t vm_start;      
    
    // VMA 的结束虚拟地址 (不包含)
    // 这是一个左闭右开区间: [vm_start, vm_end)
    uintptr_t vm_end;        
    
    // VMA 的标志位 (读/写/执行权限等)
    uint32_t vm_flags;       
    
    // 链表节点，用于将该 VMA 链接到 mm_struct 的 mmap_list 链表中
    // 链表通常按 vm_start 从小到大排序
    list_entry_t list_link;  
};

// 通过 list_entry_t 成员指针获取包含它的 vma_struct 结构体指针
#define le2vma(le, member) \
    to_struct((le), struct vma_struct, member)

// VMA 权限标志位定义
#define VM_READ 0x00000001  // 可读
#define VM_WRITE 0x00000002 // 可写
#define VM_EXEC 0x00000004  // 可执行
#define VM_STACK 0x00000008 // 是否为栈段 (用于栈增长检查)

// the control struct for a set of vma using the same PDT
// mm_struct (Memory Descriptor) 描述了一个进程的整个虚拟地址空间
// 它包含了一组 vma_struct，并管理对应的页表
struct mm_struct
{
    // 双向链表头，链接了归属于该进程的所有 vma_struct
    // 链表中的 VMA 按起始地址排序
    list_entry_t mmap_list;        
    
    // VMA 缓存指针
    // 指向最近一次成功查找的 VMA。利用局部性原理，
    // 下一次访问很可能还在同一个 VMA 内，从而加速 find_vma
    struct vma_struct *mmap_cache; 
    
    // 指向页目录表 (Page Directory Table) 的内核虚拟地址
    // 硬件通过它进行地址转换 (CR3 / SATP)
    pde_t *pgdir;                  
    
    // 该进程拥有的 VMA 总数量
    int map_count;                 
    
    // 交换管理器 (Swap Manager) 的私有数据指针
    // 用于页面置换算法记录状态 (如 FIFO 队列等)
    void *sm_priv;                 
    
    // 引用计数
    // 记录有多少个线程/进程共享这个 mm_struct
    // 如果为 0，则可以释放该结构体
    int mm_count;                  
    
    // 互斥锁，用于保护 mm_struct 的修改 (如 dup_mmap 时)
    // 防止多线程环境下的竞争条件
    lock_t mm_lock;                
};

// 查找包含指定地址 addr 的 VMA
struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr);

// 创建一个新的 VMA 结构体
struct vma_struct *vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags);

// 将 VMA 插入到 mm_struct 的链表中 (会保持链表有序)
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma);

// 创建并初始化一个新的 mm_struct
struct mm_struct *mm_create(void);

// 销毁 mm_struct 及其挂载的所有 VMA
void mm_destroy(struct mm_struct *mm);

// 初始化虚拟内存管理子系统
void vmm_init(void);

// 建立内存映射：在 mm 中分配一个新的 VMA
int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store);

// 解除内存映射：移除指定范围的 VMA (本实验未详细实现)
int mm_unmap(struct mm_struct *mm, uintptr_t addr, size_t len);

// 复制内存映射 (用于 fork)
// 将 from 进程的内存布局和页表内容复制给 to 进程
// 包含 Copy-on-Write 的逻辑
int dup_mmap(struct mm_struct *to, struct mm_struct *from);

// 退出内存映射 (用于进程退出)
// 释放页表和物理页资源
void exit_mmap(struct mm_struct *mm);

// 获取未映射的区域 (用于 mmap 系统调用寻找空闲地址，本实验未实现)
uintptr_t get_unmapped_area(struct mm_struct *mm, size_t len);

// 调整堆大小 (用于 brk 系统调用，本实验未实现)
int mm_brk(struct mm_struct *mm, uintptr_t addr, size_t len);

// 缺页异常处理函数 (Page Fault Handler)
// 核心函数，处理 Demand Paging 和 Copy-on-Write
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr);

// 外部变量：统计缺页异常次数
extern volatile unsigned int pgfault_num;
// 外部变量：用于检查的临时 mm_struct
extern struct mm_struct *check_mm_struct;
// 外部变量：模拟 Dirty COW 攻击的开关标志
extern bool TEST_DIRTY_COW_FLAG;

// 检查用户空间指针是否合法 (在 VMA 内且有权限)
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);

// 从用户空间安全复制数据到内核空间
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);

// 从内核空间安全复制数据到用户空间
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

// 内联函数：获取 mm 的引用计数
static inline int
mm_count(struct mm_struct *mm)
{
    return mm->mm_count;
}

// 内联函数：设置 mm 的引用计数
static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
}

// 内联函数：增加 mm 的引用计数
static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
    return mm->mm_count;
}

// 内联函数：减少 mm 的引用计数
static inline int
mm_count_dec(struct mm_struct *mm)
{
    mm->mm_count -= 1;
    return mm->mm_count;
}

// 内联函数：锁定 mm (自旋锁/互斥锁)
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
    }
}

// 内联函数：解锁 mm
static inline void
unlock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        unlock(&(mm->mm_lock));
    }
}

#endif /* !__KERN_MM_VMM_H__ */