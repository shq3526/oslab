#ifndef __LIBS_ATOMIC_H__
#define __LIBS_ATOMIC_H__

/* Atomic operations that C can't guarantee us. Useful for resource counting
 * etc.. */
// 定义了对一个二进制位进行读写的原子操作，确保相关操作不被中断打断。包括set_bit()设置某个二进制位的值为1, 
// change_bit()给某个二进制位取反，test_bit()返回某个二进制位的值。

// --- 函数前向声明 ---
// __attribute__((always_inline)) 强制编译器始终内联这些函数，以提高性能

static inline void set_bit(int nr, volatile void *addr)
    __attribute__((always_inline));
static inline void clear_bit(int nr, volatile void *addr)
    __attribute__((always_inline));
static inline void change_bit(int nr, volatile void *addr)
    __attribute__((always_inline));
static inline bool test_bit(int nr, volatile void *addr)
    __attribute__((always_inline));
static inline bool test_and_set_bit(int nr, volatile void *addr)
    __attribute__((always_inline));
static inline bool test_and_clear_bit(int nr, volatile void *addr)
    __attribute__((always_inline));

// --- 宏定义 ---

// BITS_PER_LONG 定义了 CPU 的原生字长（Word Size）
// __riscv_xlen 是 GCC 预定义的宏，在 64 位 RISC-V 上为 64，在 32 位上为 32
#define BITS_PER_LONG __riscv_xlen

#if (BITS_PER_LONG == 64)
// 如果是 64 位系统，使用 ".d" (doubleword) 后缀的原子操作指令
#define __AMO(op) "amo" #op ".d"
#elif (BITS_PER_LONG == 32)
// 如果是 32 位系统，使用 ".w" (word) 后缀的原子操作指令
#define __AMO(op) "amo" #op ".w"
#else
#error "Unexpected BITS_PER_LONG"
#endif

// BIT_MASK(nr) 计算第 nr 位在 *一个字* 内的位掩码 (bitmask)
// 例如 nr = 5, BITS_PER_LONG = 64, 结果是 1 << 5 = 0b100000
#define BIT_MASK(nr) (1UL << ((nr) % BITS_PER_LONG))

// BIT_WORD(nr) 计算第 nr 位位于哪个 *字* (word)
// (nr) / BITS_PER_LONG 得到的是在 (unsigned long *) 数组中的索引
#define BIT_WORD(nr) ((nr) / BITS_PER_LONG)

/*
 * __test_and_op_bit - 核心宏，用于实现 "测试并操作"
 * op: 操作 (e.g., or, and, xor)
 * mod: 掩码修改器 (e.g., __NOP, __NOT)
 * nr: 位号
 * addr: 内存地址
 *
 * 它使用 RISC-V 的 AMO (Atomic Memory Operation) 指令
 * 格式: __AMO(op) rd, rs2, (rs1)
 * 1. 从 (rs1) [内存地址] 加载原始值
 * 2. 将这个原始值存入 rd [目标寄存器, __res]
 * 3. 将 rs2 [源寄存器, mod(__mask)] 与刚加载的原始值执行 op 操作
 * 4. 将操作结果写回 (rs1) [内存地址]
 * 这一切都是原子的。
 *
 * 宏的返回值是 ((__res & __mask) != 0)，即返回这个位在 *操作前* 的原始值 (true/false)。
 */
#define __test_and_op_bit(op, mod, nr, addr)                   \
    ({                                                         \
        unsigned long __res, __mask;                           \
        __mask = BIT_MASK(nr);                                 \
        __asm__ __volatile__(__AMO(op) " %0, %2, %1"           \
                             : "=r"(__res), "+A"(addr[BIT_WORD(nr)]) \
                             : "r"(mod(__mask)));                  \
        ((__res & __mask) != 0);                               \
    })

/*
 * __op_bit - 核心宏，用于实现 "仅操作" (不关心原始值)
 * op: 操作 (e.g., or, and, xor)
 * mod: 掩码修改器
 * nr: 位号
 * addr: 内存地址
 *
 * 使用 AMO 指令，但将目标寄存器(rd)设置为 "zero" (即 x0 寄存器)
 * 这意味着 "丢弃" 从内存中加载的原始值，只执行 "操作并写回"。
 */
#define __op_bit(op, mod, nr, addr)      \
    __asm__ __volatile__(__AMO(op) " zero, %1, %0" \
                         : "+A"(addr[BIT_WORD(nr)]) \
                         : "r"(mod(BIT_MASK(nr))))

/* 掩码修改器 (Bitmask modifiers) */
#define __NOP(x) (x)  // NOP = No Operation, 原样返回 x (用于 set_bit, change_bit)
#define __NOT(x) (~(x)) // NOT = Bitwise NOT, 返回 x 的按位取反 (用于 clear_bit)

/* *
 * set_bit - 原子地在内存中设置一个位 (置 1)
 * @nr:    要设置的位号
 * @addr:  起始地址
 *
 * 实现: addr[word] = addr[word] | (1 << nr) (原子操作)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * 注意 @nr 可以是几乎任意大的；这个函数不限于只操作一个字。
 * */
static inline void set_bit(int nr, volatile void *addr) {
    // 使用 "or" (或) 操作，修改器为 __NOP (掩码不变)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
}

/* *
 * clear_bit - 原子地在内存中清除一个位 (置 0)
 * @nr:    要清除的位号
 * @addr:  起始地址
 *
 * 实现: addr[word] = addr[word] & ~(1 << nr) (原子操作)
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    // 使用 "and" (与) 操作，修改器为 __NOT (掩码取反)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
}

/* *
 * change_bit - 原子地在内存中翻转一个位
 * @nr:    要翻转的位号
 * @addr:  起始地址
 *
 * 实现: addr[word] = addr[word] ^ (1 << nr) (原子操作)
 * */
static inline void change_bit(int nr, volatile void *addr) {
    // 使用 "xor" (异或) 操作，修改器为 __NOP (掩码不变)
    __op_bit (xor, __NOP, nr, ((volatile unsigned long *)addr));
}

/* *
 * test_bit - 确定一个位是否被设置 (非原子)
 * @nr:    要测试的位号
 * @addr:  起始地址
 *
 * 这是一个非原子操作。它只读取当前内存值并检查某一位。
 * volatile 确保编译器每次都从内存重新读取，而不是使用缓存的旧值。
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    // 计算对应的字，右移 nr 位，然后与 1 '与' 操作
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
}

/* *
 * test_and_set_bit - 原子地设置一个位，并返回它 *旧* 的值
 * @nr:    要设置的位号
 * @addr:  起始地址
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    // 使用 "or" (或) 操作，并返回原始值
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
}

/* *
 * test_and_clear_bit - 原子地清除一个位，并返回它 *旧* 的值
 * @nr:    要清除的位号
 * @addr:  起始地址
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    // 使用 "and" (与) 操作和 __NOT (掩码取反)，并返回原始值
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
}

#endif /* !__LIBS_ATOMIC_H__ */
