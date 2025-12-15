#ifndef __KERN_MM_MMU_H__
#define __KERN_MM_MMU_H__

#ifndef __ASSEMBLER__
#include <defs.h>
#endif

// A linear address 'la' has a three-part structure as follows:
//
// +--------10------+-------10-------+---------12----------+
// | Page Directory |   Page Table   | Offset within Page  |
// |      Index     |     Index      |                     |
// +----------------+----------------+---------------------+
//  \--- PDX(la) --/ \--- PTX(la) --/ \---- PGOFF(la) ----/
//  \----------- PPN(la) -----------/
//
// The PDX, PTX, PGOFF, and PPN macros decompose linear addresses as shown.
// To construct a linear address la from PDX(la), PTX(la), and PGOFF(la),
// use PGADDR(PDX(la), PTX(la), PGOFF(la)).

// RISC-V uses 32-bit virtual address to access 34-bit physical address!
// Sv32 page table entry:
// +---------12----------+--------10-------+---2----+-------8-------+
// |       PPN[1]        |      PPN[0]     |Reserved|D|A|G|U|X|W|R|V|
// +---------12----------+-----------------+--------+---------------+

/*
 * RV32Sv32 page table entry:
 * | 31 10 | 9             7 | 6 | 5 | 4  1 | 0
 * PFN    reserved for SW   D   R   TYPE   V
 *
 * RV64Sv39 / RV64Sv48 page table entry:
 * | 63           48 | 47 10 | 9             7 | 6 | 5 | 4  1 | 0
 * reserved for HW    PFN    reserved for SW   D   R   TYPE   V
 */

// page directory index
// [注释] 获取一级页目录索引 (VPN[2])。
// 这里的 PDX1SHIFT 为 30，掩码 0x1FF (9位)。这是 Sv39 模式下的最高级页表索引。
#define PDX1(la) ((((uintptr_t)(la)) >> PDX1SHIFT) & 0x1FF)

// [注释] 获取二级页目录索引 (VPN[1])。
// PDX0SHIFT 为 21，掩码 0x1FF (9位)。
#define PDX0(la) ((((uintptr_t)(la)) >> PDX0SHIFT) & 0x1FF)

// page table index
// [注释] 获取页表索引 (VPN[0])。
// PTXSHIFT 为 12，掩码 0x1FF (9位)。这是直接指向物理页的页表项索引。
#define PTX(la) ((((uintptr_t)(la)) >> PTXSHIFT) & 0x1FF)

// page number field of address
// [注释] 获取物理页号 (PPN)。
// 将线性地址右移 12 位，去掉页内偏移，剩下的就是页号部分。
#define PPN(la) (((uintptr_t)(la)) >> PTXSHIFT)

// offset in page
// [注释] 获取页内偏移 (Offset)。
// 掩码 0xFFF (12位)，对应 4KB 页大小的偏移量。
#define PGOFF(la) (((uintptr_t)(la)) & 0xFFF)

// construct linear address from indexes and offset
// [注释] 根据各级索引和偏移量重新构造线性地址 (虚拟地址)。
#define PGADDR(d1, d0, t, o) ((uintptr_t)((d1) << PDX1SHIFT | (d0) << PDX0SHIFT | (t) << PTXSHIFT | (o)))

// address in page table or page directory entry
// [注释] 从页表项 (PTE) 中提取物理地址。
// 1. (pte) & ~0x3FF: 清除 PTE 低 10 位的标志位 (保留位+权限位)。
// 2. << (PTXSHIFT - PTE_PPN_SHIFT): 左移 2 位 (12 - 10)。
//    因为 RISC-V 的 PPN 从 PTE 的第 10 位开始，而物理地址需要左移 12 位对齐到 4KB 边界。
#define PTE_ADDR(pte) (((uintptr_t)(pte) & ~0x3FF) << (PTXSHIFT - PTE_PPN_SHIFT))
#define PDE_ADDR(pde) PTE_ADDR(pde)

/* page directory and page table constants */
#define NPDEENTRY 512 // page directory entries per page directory
// [注释] 每个页表包含的条目数。2^9 = 512。
#define NPTEENTRY 512 // page table entries per page table

#define PGSIZE 4096                 // bytes mapped by a page
                                    // [注释] 页大小 4KB (2^12)
#define PGSHIFT 12                  // log2(PGSIZE)
                                    // [注释] 页大小的位数 12
#define PTSIZE (PGSIZE * NPTEENTRY) // bytes mapped by a page directory entry
                                    // [注释] 一个页表(二级)覆盖的内存大小：4KB * 512 = 2MB (大页)
#define PTSHIFT 21                  // log2(PTSIZE)
                                    // [注释] 2MB 的位数 21
#define PDSIZE (PTSIZE * NPDEENTRY) // bytes mapped by a page directory
                                    // [注释] 一个页目录(一级)覆盖的内存大小：2MB * 512 = 1GB

#define PTXSHIFT 12  // offset of PTX in a linear address
                     // [注释] 0级索引(PTX)在地址中的偏移：12
#define PDX0SHIFT 21 // offset of PDX in a linear address
                     // [注释] 1级索引(PDX0)在地址中的偏移：21
#define PDX1SHIFT 30
                     // [注释] 2级索引(PDX1)在地址中的偏移：30
#define PTE_PPN_SHIFT 10 // offset of PPN in a physical address
                         // [注释] PPN 在 PTE 中的起始位是第 10 位

// page table entry (PTE) fields
// [注释] 以下为 RISC-V 硬件定义的页表项标志位
#define PTE_V 0x001    // Valid
                       // [注释] V位：置1表示该页表项有效
#define PTE_R 0x002    // Read
                       // [注释] R位：置1表示允许读取
#define PTE_W 0x004    // Write
                       // [注释] W位：置1表示允许写入
#define PTE_X 0x008    // Execute
                       // [注释] X位：置1表示允许执行 (代码段)
#define PTE_U 0x010    // User
                       // [注释] U位：置1表示用户态 (U-Mode) 可访问。Lab5 必须设置此位。
#define PTE_G 0x020    // Global
                       // [注释] G位：全局映射 (通常用于内核部分，TLB切换时不刷新)
#define PTE_A 0x040    // Accessed
                       // [注释] A位：被访问过 (硬件自动置位，用于LRU算法)
#define PTE_D 0x080    // Dirty
                       // [注释] D位：被写入过 (硬件自动置位，用于判断是否需要写回磁盘或COW)
#define PTE_SOFT 0x300 // Reserved for Software
                       // [注释] 保留给软件使用的位 (RSW)，硬件忽略

// [注释] 常用权限组合宏
#define PAGE_TABLE_DIR (PTE_V)
// [注释] 指向下一级页表的目录项 (Sv39中非叶子节点只有V位，RWX都为0)

#define READ_ONLY (PTE_R | PTE_V)
// [注释] 只读页 (如 .rodata 段)

#define READ_WRITE (PTE_R | PTE_W | PTE_V)
// [注释] 读写页 (如 .data, .bss 段)

#define EXEC_ONLY (PTE_X | PTE_V)
// [注释] 只执行

#define READ_EXEC (PTE_R | PTE_X | PTE_V)
// [注释] 读+执行 (如 .text 代码段)

#define READ_WRITE_EXEC (PTE_R | PTE_W | PTE_X | PTE_V)
// [注释] 读+写+执行 (通常不推荐，有安全风险)

#define PTE_USER (PTE_R | PTE_W | PTE_X | PTE_U | PTE_V)
// [注释] 用户态全权限掩码：用户可读、可写、可执行、有效。

#endif /* !__KERN_MM_MMU_H__ */