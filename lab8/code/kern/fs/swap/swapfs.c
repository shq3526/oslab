#include <swapfs.h>
#include <mmu.h>
#include <fs.h>
#include <ide.h>
#include <pmm.h>
#include <assert.h>

// 记录 Swap 分区支持的最大页数 (Total Swap Pages)
size_t max_swap_offset;

/*
 * swapfs_init - 初始化 Swap 文件系统
 * 1. 检查页大小和扇区大小的对齐情况。
 * 2. 检查 Swap 设备（通常是 disk1）是否存在。
 * 3. 计算 Swap 分区的总容量（以页为单位）。
 */
void swapfs_init(void)
{
    // 静态断言：确保页大小 (4096) 是扇区大小 (512) 的整数倍
    // 否则无法简单地将页映射到扇区
    static_assert((PGSIZE % SECTSIZE) == 0);
    
    // 检查 Swap 设备是否有效 (SWAP_DEV_NO 通常定义为 1，即第二个硬盘)
    if (!ide_device_valid(SWAP_DEV_NO))
    {
        panic("swap fs isn't available.\n");
    }
    
    // 计算最大 Swap 偏移量 (支持多少个页)
    // ide_device_size 返回总扇区数
    // PGSIZE / SECTSIZE = 8 (一个页包含 8 个扇区)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
}

/*
 * swapfs_read - 从 Swap 磁盘读取一个页的内容
 * @entry: Swap 表项，包含数据在磁盘上的索引 (offset)
 * @page:  目标物理页结构指针
 * @return: 0 表示成功，其他值表示错误
 */
int swapfs_read(swap_entry_t entry, struct Page *page)
{
    // ide_read_secs: 底层 IDE 驱动读取函数
    // 1. SWAP_DEV_NO: 设备号
    // 2. swap_offset(entry) * PAGE_NSECT: 计算起始扇区号
    //    swap_offset 提取 entry 中的索引，乘以每页扇区数 (8) 得到物理扇区号
    // 3. page2kva(page): 将 page 结构体转换为内核虚拟地址 (KVA)
    //    IDE 驱动需要虚拟地址作为数据传输的目的地
    // 4. PAGE_NSECT: 读取的扇区数量 (8个扇区 = 4KB)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

/*
 * swapfs_write - 将一个页的内容写入 Swap 磁盘
 * @entry: Swap 表项，包含写入目标的磁盘索引
 * @page:  源物理页结构指针
 * @return: 0 表示成功，其他值表示错误
 */
int swapfs_write(swap_entry_t entry, struct Page *page)
{
    // ide_write_secs: 底层 IDE 驱动写入函数
    // 参数逻辑同上，只是方向相反 (从内存写入磁盘)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}