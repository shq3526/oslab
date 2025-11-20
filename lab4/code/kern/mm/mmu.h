#ifndef __KERN_MM_MMU_H__
#define __KERN_MM_MMU_H__

#ifndef __ASSEMBLER__
#include <defs.h>
#endif /* !__ASSEMBLER__ */

/*
 * [RISC-V 分页机制核心原理 - Sv39 模式]
 *
 * 尽管代码中的部分旧注释提到了 "32-bit"，但根据下方的宏定义（如 PDX1SHIFT=30, 0x1FF掩码），
 * ucore 在此处实现的是 RISC-V 的 **Sv39** 分页模式，这是 64 位 RISC-V 系统最常用的分页方案。
 *
 * 1. 虚拟地址 (Virtual Address) 结构:
 * 在 Sv39 模式下，虚拟地址有效位为 39 位，结构如下：
 *
 * 63          39 38        30 29        21 20        12 11                           0
 * +--------------+------------+------------+------------+-----------------------------+
 * |   Reserved   |   VPN[2]   |   VPN[1]   |   VPN[0]   |      Page Offset (PGOFF)    |
 * +--------------+------------+------------+------------+-----------------------------+
 * 扩展位       一级页目录    二级页目录      页表              页内偏移
 * (PDX1)       (PDX0)        (PTX)
 *
 * - VPN (Virtual Page Number): 虚拟页号，分为三级，每级 9 位 (2^9 = 512 项)。
 * - Offset: 12 位，对应 4KB (2^12) 的页面大小。
 *
 * 2. 页表项 (PTE) 结构:
 * 物理页号 (PPN) + 标志位 (Flags)
 */

// A linear address 'la' has a three-part structure as follows:
// 线性地址 'la' (虚拟地址) 的结构分解：
//
// +--------9-------+-------9--------+-------9--------+---------12----------+
// | Page Directory | Page Directory |   Page Table   | Offset within Page  |
// |    Index 1     |    Index 0     |     Index      |                     |
// +----------------+----------------+----------------+---------------------+
//  \--- PDX1(la) --/ \--- PDX0(la) -/ \--- PTX(la) --/ \---- PGOFF(la) ----/
//  \------------------------- PPN(la) -------------------------------------/
//
// PDX, PTX, PGOFF 和 PPN 宏用于分解线性地址。
// 使用 PGADDR(PDX(la), PTX(la), PGOFF(la)) 可以从索引和偏移量重构线性地址。

// RISC-V uses 32-bit virtual address to access 34-bit physical address! (旧注释，实际为Sv39)
// Sv39 page table entry (Sv39 页表项结构):
// +---------20----------+--------9-------+--------9-------+---2----+-------8-------+
// |       PPN[2]        |      PPN[1]    |      PPN[0]    |Reserved|D|A|G|U|X|W|R|V|
// +---------------------+----------------+----------------+--------+---------------+

// [页目录索引宏]
// PDX1: 获取一级页目录索引 (VPN[2])
// ((la >> 30) & 0x1FF) -> 取第 30-38 位
#define PDX1(la) ((((uintptr_t)(la)) >> PDX1SHIFT) & 0x1FF)

// PDX0: 获取二级页目录索引 (VPN[1])
// ((la >> 21) & 0x1FF) -> 取第 21-29 位
#define PDX0(la) ((((uintptr_t)(la)) >> PDX0SHIFT) & 0x1FF)

// [页表索引宏]
// PTX: 获取页表索引 (VPN[0])
// ((la >> 12) & 0x1FF) -> 取第 12-20 位
#define PTX(la) ((((uintptr_t)(la)) >> PTXSHIFT) & 0x1FF)

// [物理页号字段]
// PPN: 获取地址中的页号部分 (去除偏移量)
#define PPN(la) (((uintptr_t)(la)) >> PTXSHIFT)

// [页内偏移]
// PGOFF: 获取低 12 位的偏移量
#define PGOFF(la) (((uintptr_t)(la)) & 0xFFF)

// [地址构造宏]
// 根据各级索引和偏移量，合成一个线性地址
#define PGADDR(d1, d0, t, o) ((uintptr_t)((d1) << PDX1SHIFT |(d0) << PDX0SHIFT | (t) << PTXSHIFT | (o)))

// [PTE 地址提取]
// 从页表项 (PTE) 或页目录项 (PDE) 中提取下一级物理页的物理地址。
// 原理：PTE 的低 10 位是标志位，~0x3FF (即 ...11110000000000) 用于屏蔽这些标志位。
// 然后通过位移操作调整，得到实际的物理地址。
// 注意：RISC-V 的 PTE 格式中，PPN 存储在高位，需要移位还原成物理地址。
#define PTE_ADDR(pte)   (((uintptr_t)(pte) & ~0x3FF) << (PTXSHIFT - PTE_PPN_SHIFT))
#define PDE_ADDR(pde)   PTE_ADDR(pde)

/* page directory and page table constants */
/* 页目录和页表相关常量 */

#define NPDEENTRY       512                    // 每个页目录包含的条目数 (2^9 = 512)
#define NPTEENTRY       512                    // 每个页表包含的条目数 (2^9 = 512)

#define PGSIZE          4096                    // 页面大小：4096 字节 (4KB)
#define PGSHIFT         12                      // log2(PGSIZE) = 12 位
#define PTSIZE          (PGSIZE * NPTEENTRY)    // 一个页目录项映射的内存大小 (4KB * 512 = 2MB)
                                                // 这也是大页 (Huge Page) 的大小
#define PTSHIFT         21                      // log2(PTSIZE) = 21 位

// [位移定义]
#define PTXSHIFT        12                      // PTX (VPN[0]) 在线性地址中的偏移
#define PDX0SHIFT       21                      // PDX0 (VPN[1]) 在线性地址中的偏移
#define PDX1SHIFT       30                      // PDX1 (VPN[2]) 在线性地址中的偏移
#define PTE_PPN_SHIFT   10                      // PPN 在物理地址(PTE)中的偏移 (PTE 的低 10 位是 Flags)

// [页表项 (PTE) 标志位]
// 这些位由硬件定义，MMU 在地址转换时会检查这些位以进行权限控制。

#define PTE_V     0x001 // Valid (有效位)
                        // 1: 该页表项有效，MMU 可以使用。
                        // 0: 该页表项无效，访问会导致 Page Fault (缺页异常)。

#define PTE_R     0x002 // Read (可读)
#define PTE_W     0x004 // Write (可写)
#define PTE_X     0x008 // Execute (可执行)
                        // 组合规则：
                        // - R=0, W=1: 保留组合，通常无效。
                        // - R=0, W=0, X=0: 指向下一级页表的指针 (非叶子节点)。
                        // - 只有叶子节点 (实际映射物理页的 PTE) 才会设置 R/W/X 权限。

#define PTE_U     0x010 // User (用户位)
                        // 1: 用户模式 (U-mode) 可以访问该页面。
                        // 0: 只有内核模式 (S-mode) 可以访问。
                        // 注意：如果 S-mode 试图访问 U=1 的页面，通常也会报错 (取决于 SUM 位)，这是为了防止内核意外访问用户数据。

#define PTE_G     0x020 // Global (全局位)
                        // 1: 该映射在所有地址空间中都有效 (通常用于内核部分)。
                        // 硬件在 TLB 刷新时不会清除标记为 G 的条目。

#define PTE_A     0x040 // Accessed (访问位)
                        // 1: 自从上次清除以来，该页面被读、写或执行过。
                        // 用于页面置换算法 (如 Clock 算法) 判断页面是否热点。

#define PTE_D     0x080 // Dirty (脏位)
                        // 1: 自从上次清除以来，该页面被写入过。
                        // 页面被换出到磁盘时，如果 D=1，说明需要写回磁盘；如果 D=0，则可以直接丢弃。

#define PTE_SOFT  0x300 // Reserved for Software (软件保留位)
                        // 硬件忽略这些位，操作系统可以用它们存储自定义信息 (如写时复制标记)。

// [常见权限组合宏]
#define PAGE_TABLE_DIR (PTE_V)                  // 页目录项 (指向下一级页表，无 R/W/X 权限)
#define READ_ONLY (PTE_R | PTE_V)               // 只读页面 (代码段常量)
#define READ_WRITE (PTE_R | PTE_W | PTE_V)      // 读写页面 (数据段、堆、栈)
#define EXEC_ONLY (PTE_X | PTE_V)               // 只执行 (代码段)
#define READ_EXEC (PTE_R | PTE_X | PTE_V)       // 读和执行 (通常的代码段)
#define READ_WRITE_EXEC (PTE_R | PTE_W | PTE_X | PTE_V) // 读写执行 (不推荐，不安全)

#define PTE_USER (PTE_R | PTE_W | PTE_X | PTE_U | PTE_V) // 用户态全权限 (用于测试或特殊用途)

#endif /* !__KERN_MM_MMU_H__ */