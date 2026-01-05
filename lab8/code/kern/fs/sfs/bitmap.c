#include <defs.h>
#include <string.h>
#include <bitmap.h>
#include <kmalloc.h>
#include <error.h>
#include <assert.h>

// 定义位图的基本操作单位为 32 位无符号整数 (uint32_t)
#define WORD_TYPE           uint32_t
// 计算一个操作单位包含多少个位 (通常是 32 位)
#define WORD_BITS           (sizeof(WORD_TYPE) * CHAR_BIT)

struct bitmap {
    uint32_t nbits;         // 位图中总的有效位数 (例如磁盘的总块数)
    uint32_t nwords;        // 位图占用的字 (WORD_TYPE) 数量
    WORD_TYPE *map;         // 指向实际存储位数据的数组指针
};

// bitmap_create - allocate a new bitmap object.
// 创建并初始化一个新的位图结构
// nbits: 位图需要管理的比特位总数
struct bitmap *
bitmap_create(uint32_t nbits) {
    static_assert(WORD_BITS != 0);
    // 参数检查：nbits 必须非零，且防止溢出
    assert(nbits != 0 && nbits + WORD_BITS > nbits);

    struct bitmap *bitmap;
    // 分配 bitmap 结构体的内存
    if ((bitmap = kmalloc(sizeof(struct bitmap))) == NULL) {
        return NULL;
    }

    // 计算需要多少个 WORD_TYPE 来存储 nbits
    // ROUNDUP_DIV 实现向上取整，例如 33 位需要 2 个 word
    uint32_t nwords = ROUNDUP_DIV(nbits, WORD_BITS);
    WORD_TYPE *map;
    // 分配存放位图数据的数组内存
    if ((map = kmalloc(sizeof(WORD_TYPE) * nwords)) == NULL) {
        kfree(bitmap);
        return NULL;
    }

    bitmap->nbits = nbits, bitmap->nwords = nwords;
    // 初始化位图：将所有位设置为 1 (0xFF)。
    // 在 SFS 中，1 表示"空闲"，0 表示"已占用"。初始状态下所有块都是空闲的。
    bitmap->map = memset(map, 0xFF, sizeof(WORD_TYPE) * nwords);

    /* mark any leftover bits at the end in use(0) */
    // 处理最后一个 word 中的填充位。
    // 如果 nbits 不是 32 的倍数，最后一个 word 的高位部分是无效的。
    // 我们将这些无效位标记为 0 (已占用)，防止 bitmap_alloc 错误地分配出这些不存在的索引。
    if (nbits != nwords * WORD_BITS) {
        // ix 是最后一个 word 的下标
        uint32_t ix = nwords - 1; 
        // overbits 是最后一个 word 中有效位的数量
        uint32_t overbits = nbits - ix * WORD_BITS;

        assert(nbits / WORD_BITS == ix);
        assert(overbits > 0 && overbits < WORD_BITS);

        // 将 overbits 之后的所有高位翻转（从 1 变为 0）
        for (; overbits < WORD_BITS; overbits ++) {
            bitmap->map[ix] ^= (1 << overbits);
        }
    }
    return bitmap;
}

// bitmap_alloc - locate a cleared bit, set it, and return its index.
// 分配一个空闲位：找到一个值为 1 的位，将其设为 0，并返回其索引
int
bitmap_alloc(struct bitmap *bitmap, uint32_t *index_store) {
    WORD_TYPE *map = bitmap->map;
    uint32_t ix, offset, nwords = bitmap->nwords;
    
    // 遍历每一个 word
    for (ix = 0; ix < nwords; ix ++) {
        // 如果 word 不为 0，说明其中至少有一个位是 1 (空闲)
        if (map[ix] != 0) {
            // 遍历该 word 中的每一位
            for (offset = 0; offset < WORD_BITS; offset ++) {
                WORD_TYPE mask = (1 << offset);
                // 找到第一个为 1 的位
                if (map[ix] & mask) {
                    // 使用异或操作将该位翻转为 0 (标记为已占用)
                    map[ix] ^= mask;
                    // 计算并返回全局索引值
                    *index_store = ix * WORD_BITS + offset;
                    return 0;
                }
            }
            // 理论上如果 map[ix] != 0，循环内一定能找到位并返回，这里不应到达
            assert(0);
        }
    }
    // 遍历完所有 word 都没有找到空闲位，返回内存不足错误
    return -E_NO_MEM;
}

// bitmap_translate - according index, get the related word and mask
// 辅助函数：根据全局索引 index，计算它在哪个 word 以及对应的位掩码 mask
static void
bitmap_translate(struct bitmap *bitmap, uint32_t index, WORD_TYPE **word, WORD_TYPE *mask) {
    assert(index < bitmap->nbits);
    // 计算数组下标
    uint32_t ix = index / WORD_BITS; 
    // 计算位偏移
    uint32_t offset = index % WORD_BITS;
    // 返回对应的 word 指针和 mask
    *word = bitmap->map + ix;
    *mask = (1 << offset);
}

// bitmap_test - according index, get the related value (0 OR 1) in the bitmap
// 测试指定索引位的状态
// 返回 true (非0) 表示空闲，返回 false (0) 表示已占用
bool
bitmap_test(struct bitmap *bitmap, uint32_t index) {
    WORD_TYPE *word, mask;
    bitmap_translate(bitmap, index, &word, &mask);
    return (*word & mask);
}

// bitmap_free - according index, set related bit to 1
// 释放指定索引位：将该位的值重置为 1 (空闲)
void
bitmap_free(struct bitmap *bitmap, uint32_t index) {
    WORD_TYPE *word, mask;
    bitmap_translate(bitmap, index, &word, &mask);
    // 确保释放前该位是 0 (已占用) 状态，防止重复释放
    assert(!(*word & mask));
    // 使用或操作将该位置为 1
    *word |= mask;
}

// bitmap_destroy - free memory contains bitmap
// 销毁位图，释放所有相关内存
void
bitmap_destroy(struct bitmap *bitmap) {
    kfree(bitmap->map);
    kfree(bitmap);
}

// bitmap_getdata - return bitmap->map, return the length of bits to len_store
// 获取位图的原始数据指针和数据长度 (字节数)
// 通常用于将内存中的 freemap 写入磁盘
void *
bitmap_getdata(struct bitmap *bitmap, size_t *len_store) {
    if (len_store != NULL) {
        *len_store = sizeof(WORD_TYPE) * bitmap->nwords;
    }
    return bitmap->map;
}