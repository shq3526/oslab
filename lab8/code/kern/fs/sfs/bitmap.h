#ifndef __KERN_FS_SFS_BITMAP_H__
#define __KERN_FS_SFS_BITMAP_H__

#include <defs.h>


/*
 * Fixed-size array of bits. (Intended for storage management.)
 * 固定大小的位数组。（用于存储空间管理，即记录哪些磁盘块被使用了，哪些是空的）
 *
 * Functions:
 * bitmap_create  - allocate a new bitmap object.
 * Returns NULL on error.
 * bitmap_getdata - return pointer to raw bit data (for I/O).
 * bitmap_alloc   - locate a cleared bit, set it, and return its index.
 * bitmap_mark    - set a clear bit by its index. (注：实际对应下面的 bitmap_free 或类似逻辑，但在 SFS 中 1=Free)
 * bitmap_unmark  - clear a set bit by its index.
 * bitmap_isset   - return whether a particular bit is set or not.
 * bitmap_destroy - destroy bitmap.
 */

// 前向声明，具体结构体定义在 .c 文件中对外隐藏
struct bitmap;

/*
 * bitmap_create - 创建一个新的位图对象
 * @nbits: 位图需要管理的比特位总数（通常对应磁盘的总块数）
 * @return: 成功返回位图结构指针，失败返回 NULL
 */
struct bitmap *bitmap_create(uint32_t nbits);                   // allocate a new bitmap object.

/*
 * bitmap_alloc - 分配一个空闲位
 * @bitmap: 位图对象指针
 * @index_store: 输出参数，用于存储分配到的索引值（块号）
 * @return: 成功返回 0，失败（没有空闲位）返回错误码 -E_NO_MEM
 * * 逻辑：寻找值为 1 (Free) 的位，将其翻转为 0 (Used)，并将索引写入 index_store。
 */
int bitmap_alloc(struct bitmap *bitmap, uint32_t *index_store);   // locate a cleared bit, set it, and return its index.

/*
 * bitmap_test - 测试指定位的状态
 * @index: 要测试的索引
 * @return: 返回 true (非0) 表示该位为 1 (空闲)，返回 false (0) 表示该位为 0 (已占用)
 */
bool bitmap_test(struct bitmap *bitmap, uint32_t index);          // return whether a particular bit is set or not.

/*
 * bitmap_free - 释放指定索引位
 * @index: 要释放的索引（块号）
 * * 逻辑：将指定索引位的值置为 1 (Free)。
 */
void bitmap_free(struct bitmap *bitmap, uint32_t index);          // according index, set related bit to 1

/*
 * bitmap_destroy - 销毁位图对象
 * 释放位图结构体及内部数据数组占用的内存。
 */
void bitmap_destroy(struct bitmap *bitmap);                       // free memory contains bitmap

/*
 * bitmap_getdata - 获取位图的原始数据指针
 * @len_store: 输出参数，如果不为 NULL，用于存储数据的字节长度
 * @return: 返回指向位图内部数据数组的指针 (void*)
 * * 用途：主要用于将内存中的 freemap 数据写入磁盘（I/O 操作），或者计算校验和。
 */
void *bitmap_getdata(struct bitmap *bitmap, size_t *len_store);   // return pointer to raw bit data (for I/O)

#endif /* !__KERN_FS_SFS_BITMAP_H__ */