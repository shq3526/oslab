// ------------------------------------------------Buddy System（longest 线段树）--------------------------
// 设计要点：
// 1) 用完全二叉树摘要 longest[] 维护“该子树可用的最大连续块大小”；
// 2) 分配：自顶向下选能满足请求的子树，直到节点大小 == 需求；置0占用，并向上回写 longest；
// 3) 释放：根据页偏移定位叶子，向上找到“首次 longest==0 的结点”，将其置为节点大小，并向上回写 longest；
// 4) 显示：扫描树，打印“满块且其父节点不是满块”的结点，相当于每阶空闲链表的“头块”；
// --------------------------------------------------------------------------------------------------------------------

#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <buddy_system_pmm.h>

#define MAX_BUDDY_ORDER 14                 // 最大支持到 2^14 = 16384 页
#define MAX_PAGES       (1u << MAX_BUDDY_ORDER)
#define TREE_MAX_NODES  (2u * MAX_PAGES)   // 2*size

// ---- 树索引宏（完全二叉树，根=0）----
#define LEFT_LEAF(i)    ((i) * 2 + 1)
#define RIGHT_LEAF(i)   ((i) * 2 + 2)
#define PARENT(i)       (((i) + 1) / 2 - 1)
#define IS_POWER_OF_2(x) (!((x) & ((x) - 1)))

// ==== Buddy 管理器状态结构 ====
typedef struct {
    unsigned int size;                  // 根容量（页数，2^k）
    unsigned int max_order;             // k
    unsigned int nr_free;               // 当前空闲总页数
    struct Page *base;                  // 管理范围起始页
    size_t       base_idx;              // = base - pages
    unsigned int longest[TREE_MAX_NODES]; // longest 数组（只用到 2*size-1 部分）
} buddy2_t;

static buddy2_t b2;

// ==== 外部符号 ====
extern struct Page *pages;
extern const size_t nbase;

// ==== 幂/取整工具 ====
static inline unsigned Next_Pow2(unsigned n) {
    if (n <= 1) return 1;
    if ((n & (n - 1)) == 0) return n;
    n--;
    n |= n >> 1;
    n |= n >> 2;
    n |= n >> 4;
    n |= n >> 8;
    n |= n >> 16; 
    return n + 1;
}

static inline unsigned Prev_Pow2(unsigned n) {
    if ((n & (n - 1)) == 0) return n;
    return Next_Pow2(n) >> 1;
}
static inline unsigned Get_Order_Of_2(unsigned n) {
    unsigned k = 0;
    while ((n >>= 1) != 0) k++;
    return k;
}

// ==== 内部工具：根据结点 index 计算其“块大小（页数）”====
static inline unsigned node_size_at(unsigned index) {
    // 根容量是 b2.size；在 buddy2 里 node_size 从根开始每层 /2
    // 反向计算：层数 = floor(log2(index+1))
    unsigned level = 0, x = index + 1;
    while (x >>= 1) level++;
    return b2.size >> level;
}

// ==== 初始化 ====
static void buddy_system_init(void) {
    memset(&b2, 0, sizeof(buddy2_t));
}

// 将 [base, base+n) 初始化为一棵 buddy2 树（容量取 <= MAX_PAGES 的最大 2^k）
static void buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);

    // 清页元信息
    for (struct Page *p = base; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = 0;
        p->property = -1;
        set_page_ref(p, 0);
    }

    unsigned p2 = Prev_Pow2((unsigned)n);
    if (p2 > MAX_PAGES) p2 = MAX_PAGES;

    b2.size      = p2;
    b2.max_order = Get_Order_Of_2(p2);
    b2.nr_free   = p2;
    b2.base      = base;
    b2.base_idx  = (size_t)(base - pages);

    // 按 buddy2_new 的方式填充 longest[]
    unsigned node_size = b2.size * 2;
    unsigned total = 2 * b2.size - 1;
    for (unsigned i = 0; i < total; ++i) {
        // i+1 如果是 2 的幂，说明进入下一层
        if (IS_POWER_OF_2(i + 1)) node_size >>= 1;
        b2.longest[i] = node_size;
    }

    // 显示用途：把根作为“一个大空闲块”的头页属性
    base->property = (int)b2.max_order;
    SetPageProperty(base);
}

// ==== 分配：buddy2_alloc 语义 ====
static struct Page *buddy_system_alloc_pages(size_t requested_pages) {
    assert(requested_pages > 0);
    if (requested_pages > b2.nr_free) return NULL;

    unsigned need = Next_Pow2((unsigned)requested_pages);
    if (need > b2.size) return NULL;

    if (b2.longest[0] < need) return NULL;

    unsigned index = 0;
    // 自顶向下找叶子
    for (unsigned node_size = b2.size; node_size != need; node_size >>= 1) {
        unsigned li = LEFT_LEAF(index);
        unsigned ri = RIGHT_LEAF(index);
        if (b2.longest[li] >= need) index = li;
        else                        index = ri;
    }

    // 关键：保存叶子下标，后面算 offset 用
    unsigned alloc_index = index;

    // 占用该叶子
    b2.longest[index] = 0;

    // 向上更新父结点的 longest（取左右子较大者）
    while (index) {
        index = PARENT(index);
        unsigned li = LEFT_LEAF(index);
        unsigned ri = RIGHT_LEAF(index);
        b2.longest[index] = (b2.longest[li] > b2.longest[ri]) ? b2.longest[li] : b2.longest[ri];
    }

    // 用“第一次找到的叶子”计算偏移
    unsigned offset = (alloc_index + 1) * need - b2.size;

    b2.nr_free -= need;

    struct Page *ret = &pages[b2.base_idx + offset];
    ClearPageProperty(ret);           // 展示用途：标成“非空闲头页”
    ret->property = -1;
    return ret;
}


// ==== 释放 ====
static void buddy_system_free_pages(struct Page *base, size_t n) {
    assert(base != NULL && n > 0);

    unsigned size = Next_Pow2((unsigned)n);
    if (size > b2.size) size = b2.size;

    // 计算 offset（以 b2.base 为起点的页偏移）
    size_t idx = (size_t)(base - pages);
    assert(idx >= b2.base_idx);
    unsigned offset = (unsigned)(idx - b2.base_idx);
    assert(offset < b2.size);

    // 从叶子向上找到“首次 longest==0”的结点（该结点的 node_size 就是释放块）
    unsigned node_size = 1;
    unsigned index = offset + b2.size - 1;
    while (b2.longest[index] != 0) {
        // 这个叶/中间节点已经是空闲，说明 offset 对应的是更大的块，继续向上找
        node_size <<= 1;
        if (index == 0) return; // 整棵树空，或重复释放，直接返回
        index = PARENT(index);
    }

    b2.longest[index] = node_size;

    // 向上更新（自然合并）
    while (index) {
        index = PARENT(index);
        node_size <<= 1;

        unsigned li = LEFT_LEAF(index);
        unsigned ri = RIGHT_LEAF(index);

        unsigned left_longest  = b2.longest[li];
        unsigned right_longest = b2.longest[ri];

        if (left_longest + right_longest == node_size) {
            b2.longest[index] = node_size;       // 两边刚好满 → 合并成父块
        } else {
            b2.longest[index] = (left_longest > right_longest) ? left_longest : right_longest;
        }
    }

    // 计数（按页加回）
    b2.nr_free += size;

    cprintf("Buddy System算法将释放第NO.%d页开始的共%d页\n", page2ppn(base), (int)size);
}

// ==== 查询空闲页总数 ====
static size_t buddy_system_nr_free_pages(void) {
    return b2.nr_free;
}


// ==== 显示 ====
// ==== 显示：按层扫描（分层索引优化版）====
// 复杂度：对每个阶 ord 仅扫描该阶所在层的节点个数（约 size / 2^ord）
// ==== 显示：分层聚合 + 每层 Longest（从根到叶）====
// ==== 显示：分层聚合 + 每层 Longest（从根到叶）====
// 关键修正：跳过任何“落在某个已占用叶子（longest==0）的子树里面”的节点，
// 避免把初始化残留的更小阶节点误当成有效空闲块。
static void show_buddy_array(int left, int right) {
    if (left < 0) left = 0;
    if (right > (int)b2.max_order) right = (int)b2.max_order;
    if (left > right) { int t = left; left = right; right = t; }

    cprintf("------------------按层级统计（从根到叶）:------------------\n");

    // 小工具：判断节点 i 是否“位于某个已占用叶子（longest==0）之下”
    auto bool under_allocated_leaf(unsigned i, unsigned node_size) {
        // 从 i 向上爬到根，只要遇到一个祖先 a：
        // 1) a 的块大小 >= node_size（必然成立，越往上越大）
        // 2) a 的 longest == 0（说明这一整块是“占用叶子”）
        // 就说明当前节点 i 落在已占用叶子之下，应跳过。
        unsigned idx = i;
        while (1) {
            unsigned level = 0, x = idx + 1;
            while (x >>= 1) level++;
            unsigned anc_size = b2.size >> level; // 祖先/自身块大小

            if (b2.longest[idx] == 0 && anc_size >= node_size) return 1;
            if (idx == 0) break;
            idx = PARENT(idx);
        }
        return 0;
    }

    int any_printed = 0;

    for (int ord = (int)b2.max_order; ord >= 0; --ord) {
        if (ord < left || ord > right) continue;

        unsigned block_size = (1u << ord);
        unsigned level = b2.max_order - (unsigned)ord;   // 根=0
        unsigned first = (1u << level) - 1;
        unsigned last  = (1u << (level + 1)) - 2;

        unsigned blocks = 0;
        unsigned pages_sum = 0;
        unsigned level_longest = 0;

        for (unsigned i = first; i <= last; ++i) {
            // 屏蔽掉落在“被占用叶子”之下的节点
            if (under_allocated_leaf(i, block_size)) continue;

            // 本层 Longest
            if (b2.longest[i] > level_longest) level_longest = b2.longest[i];

            // 满块且父非满：避免跨层重复
            if (b2.longest[i] == block_size) {
                if (i != 0) {
                    unsigned p = PARENT(i);
                    // 父满（==2*block_size）则由父层统计，当前层不计
                    if (b2.longest[p] == (block_size << 1)) continue;
                }
                blocks++;
                pages_sum += block_size;
            }
        }

        if (blocks > 0 || level_longest > 0) {
            cprintf("No.%d 层：整块数=%u，合计空闲页=%u（每块 %u 页） | 本层Longest=%u页",
                    ord, blocks, pages_sum, block_size, level_longest);
            if (level_longest) cprintf("（~No.%u）\n", Get_Order_Of_2(level_longest));
            else cprintf("\n");
            any_printed = 1;
        }
    }

    if (!any_printed) {
        cprintf("（无可按层统计的整块或连续空闲，可能空闲被高度碎片化或根可用空间极小）\n");
    }
    cprintf("全局剩余空闲页：%u\n", b2.nr_free);
    cprintf("------------------显示完成!------------------\n\n");
}




static void buddy_system_check_easy(void) {
    cprintf("CHECK OUR EASY ALLOC CONDITION:\n");
    cprintf("当前总的空闲块的数量为：%d\n", (int)b2.nr_free);
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;

    cprintf("1.p0请求8页\n");
    p0 = alloc_pages(8);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    cprintf("2.p1请求8页\n");
    p1 = alloc_pages(8);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    cprintf("3.p2请求8页\n");
    p2 = alloc_pages(8);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    cprintf("p0的虚拟地址为:0x%016lx.\n", p0);
    cprintf("p1的虚拟地址为:0x%016lx.\n", p1);
    cprintf("p2的虚拟地址为:0x%016lx.\n", p2);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    cprintf("CHECK OUR EASY FREE CONDITION:\n");
    cprintf("释放p0...\n");
    free_pages(p0, 8);
    cprintf("释放p0后,总空闲块数目为:%d\n", (int)b2.nr_free);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    cprintf("释放p1...\n");
    free_pages(p1, 8);
    cprintf("释放p1后,总空闲块数目为:%d\n", (int)b2.nr_free);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    cprintf("释放p2...\n");
    free_pages(p2, 8);
    cprintf("释放p2后,总空闲块数目为:%d\n", (int)b2.nr_free);
    show_buddy_array(0, MAX_BUDDY_ORDER);
}

static void buddy_system_check_difficult(void) {
    cprintf("CHECK OUR DIFFICULT ALLOC CONDITION:\n");
    cprintf("当前总的空闲块的数量为：%d\n", (int)b2.nr_free);
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;

    cprintf("1.p0请求20页\n");
    p0 = alloc_pages(20);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    cprintf("2.p1请求40页\n");
    p1 = alloc_pages(40);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    cprintf("3.p2请求200页\n");
    p2 = alloc_pages(200);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    cprintf("p0的虚拟地址为:0x%016lx.\n", p0);
    cprintf("p1的虚拟地址为:0x%016lx.\n", p1);
    cprintf("p2的虚拟地址为:0x%016lx.\n", p2);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    cprintf("CHECK OUR EASY DIFFICULT CONDITION:\n");
    cprintf("释放p0...\n");
    free_pages(p0, 20);
    cprintf("释放p0后,总空闲块数目为:%d\n", (int)b2.nr_free);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    cprintf("释放p1...\n");
    free_pages(p1, 40);
    cprintf("释放p1后,总空闲块数目为:%d\n", (int)b2.nr_free);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    cprintf("释放p2...\n");
    free_pages(p2, 200);
    cprintf("释放p2后,总空闲块数目为:%d\n", (int)b2.nr_free);
    show_buddy_array(0, MAX_BUDDY_ORDER);
}

static void buddy_system_check_min(void) {
    struct Page *p3 = alloc_pages(1);
    cprintf("分配p3之后(1页)\n");
    show_buddy_array(0, MAX_BUDDY_ORDER);

    if (p3 == NULL) {
        cprintf("WARN: 分配1页失败，跳过回收测试。\n");
        return;
    }
    cprintf("p3的虚拟地址为:0x%016lx.\n", p3);
    free_pages(p3, 1);
    show_buddy_array(0, MAX_BUDDY_ORDER);
}

static void buddy_system_check_max(void) {
    size_t max_pages = (1u << b2.max_order);
    struct Page *p3 = alloc_pages(max_pages);
    cprintf("分配p3之后(%d页)\n", (int)max_pages);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    if (p3 == NULL) {
        cprintf("WARN: 无法分配最大块（%d页），可能被碎片/已分配占用，跳过回收测试。\n", (int)max_pages);
        return;
    }
    cprintf("p3的虚拟地址为:0x%016lx.\n", p3);
    free_pages(p3, (size_t)max_pages);
    show_buddy_array(0, MAX_BUDDY_ORDER);
}

static void buddy_system_check(void) {
    cprintf("BEGIN TO TEST!\n");
    buddy_system_check_easy();
    buddy_system_check_difficult();
    buddy_system_check_min();
    buddy_system_check_max();
}

// ==== pmm_manager ：对外接口保持不变 ====
const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages = buddy_system_free_pages,
    .nr_free_pages = buddy_system_nr_free_pages,
    .check = buddy_system_check,
};
