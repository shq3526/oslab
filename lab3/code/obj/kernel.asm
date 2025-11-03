
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00007297          	auipc	t0,0x7
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0207000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00007297          	auipc	t0,0x7
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0207008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02062b7          	lui	t0,0xc0206
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200034:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200038:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc020003c:	c0206137          	lui	sp,0xc0206

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 1. 使用临时寄存器 t1 计算栈顶的精确地址
    lui t1, %hi(bootstacktop)
ffffffffc0200040:	c0206337          	lui	t1,0xc0206
    addi t1, t1, %lo(bootstacktop)
ffffffffc0200044:	00030313          	mv	t1,t1
    # 2. 将精确地址一次性地、安全地传给 sp
    mv sp, t1
ffffffffc0200048:	811a                	mv	sp,t1
    # 现在栈指针已经完美设置，可以安全地调用任何C函数了
    # 然后跳转到 kern_init (不再返回)
    lui t0, %hi(kern_init)
ffffffffc020004a:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020004e:	05428293          	addi	t0,t0,84 # ffffffffc0200054 <kern_init>
    jr t0
ffffffffc0200052:	8282                	jr	t0

ffffffffc0200054 <kern_init>:
    // end 是.bss段（未初始化数据）的结束地址
    extern char edata[], end[];

    // 清理 BSS 段：将 .data 段末尾到 .bss 段末尾的内存区域全部清零
    // 这是 C 语言标准要求的，确保所有未初始化的全局/静态变量默认为 0
    memset(edata, 0, end - edata);
ffffffffc0200054:	00007517          	auipc	a0,0x7
ffffffffc0200058:	fd450513          	addi	a0,a0,-44 # ffffffffc0207028 <free_area>
ffffffffc020005c:	00007617          	auipc	a2,0x7
ffffffffc0200060:	44460613          	addi	a2,a2,1092 # ffffffffc02074a0 <end>
int kern_init(void) {
ffffffffc0200064:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200066:	8e09                	sub	a2,a2,a0
ffffffffc0200068:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020006a:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020006c:	7bf010ef          	jal	ra,ffffffffc020202a <memset>

    // [!] 注意：dtb_init() 在 memset 之后调用。
    // OpenSBI 将 DTB 地址传递给内核，内核需要解析它以获取硬件信息（如内存布局）
    // 实验指导中提到，这个函数用于读取并保存 DTB 的内存信息。
    dtb_init();
ffffffffc0200070:	416000ef          	jal	ra,ffffffffc0200486 <dtb_init>

    cons_init(); // 初始化控制台（console），之后 cprintf 才能工作
ffffffffc0200074:	404000ef          	jal	ra,ffffffffc0200478 <cons_init>

    const char *message = "(THU.CST) os is loading ...\0";
    cputs(message); // 向控制台输出启动信息
ffffffffc0200078:	00002517          	auipc	a0,0x2
ffffffffc020007c:	fc850513          	addi	a0,a0,-56 # ffffffffc0202040 <etext+0x4>
ffffffffc0200080:	098000ef          	jal	ra,ffffffffc0200118 <cputs>

    print_kerninfo(); // 打印内核信息（如内核占用的内存范围）
ffffffffc0200084:	0e4000ef          	jal	ra,ffffffffc0200168 <print_kerninfo>
    // grade_backtrace(); // 用于调试栈回溯的函数调用（已注释）

    // idt_init (Interrupt Descriptor Table) 是 x86 的叫法
    // 在 RISC-V 中，这个函数（trap.c 中的 idt_init）实际上是初始化中断向量表
    // 主要是设置 stvec 寄存器，使其指向汇编入口 __alltraps
    idt_init();
ffffffffc0200088:	7ba000ef          	jal	ra,ffffffffc0200842 <idt_init>

    // 初始化物理内存管理器（PMM）
    // pmm_init 会调用 pmm_manager->init() 和 pmm_manager->init_memmap()
    // 来设置物理内存的空闲页链表（基于 dtb_init 获取的内存范围）
    pmm_init();
ffffffffc020008c:	023010ef          	jal	ra,ffffffffc02018ae <pmm_init>

    // 再次调用 idt_init() [?] 备注：这里调用了两次，可能是遗留代码，但无害
    idt_init(); 
ffffffffc0200090:	7b2000ef          	jal	ra,ffffffffc0200842 <idt_init>
    
    // [!] 调用两个测试函数（在 trap.c 中实现），用于触发 Challenge 3 的异常处理
    test_breakpoint(); // 触发断点异常
ffffffffc0200094:	373000ef          	jal	ra,ffffffffc0200c06 <test_breakpoint>
    test_illegal();    // 触发非法指令异常
ffffffffc0200098:	391000ef          	jal	ra,ffffffffc0200c28 <test_illegal>

    // 初始化时钟中断（clock.c）
    // 1. 设置 sie 寄存器，使能 S 模式的时钟中断
    // 2. 调用 clock_set_next_event() 设置 *第一次* 时钟中断
    clock_init();
ffffffffc020009c:	39a000ef          	jal	ra,ffffffffc0200436 <clock_init>
    
    // 使能中断（intr.c）
    // 设置 sstatus 寄存器的 SIE 位（Supervisor Interrupt Enable），
    // 允许 CPU 响 S 模式的中断请求
    intr_enable();
ffffffffc02000a0:	796000ef          	jal	ra,ffffffffc0200836 <intr_enable>

    /* do nothing */
    // 内核初始化完成，进入一个死循环
    // 此时 OS 变为由中断驱动，等待时钟中断或其他中断的发生
    while (1)
ffffffffc02000a4:	a001                	j	ffffffffc02000a4 <kern_init+0x50>

ffffffffc02000a6 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc02000a6:	1141                	addi	sp,sp,-16
ffffffffc02000a8:	e022                	sd	s0,0(sp)
ffffffffc02000aa:	e406                	sd	ra,8(sp)
ffffffffc02000ac:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc02000ae:	3cc000ef          	jal	ra,ffffffffc020047a <cons_putc>
    (*cnt) ++;
ffffffffc02000b2:	401c                	lw	a5,0(s0)
}
ffffffffc02000b4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000b6:	2785                	addiw	a5,a5,1
ffffffffc02000b8:	c01c                	sw	a5,0(s0)
}
ffffffffc02000ba:	6402                	ld	s0,0(sp)
ffffffffc02000bc:	0141                	addi	sp,sp,16
ffffffffc02000be:	8082                	ret

ffffffffc02000c0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000c0:	1101                	addi	sp,sp,-32
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fe050513          	addi	a0,a0,-32 # ffffffffc02000a6 <cputch>
ffffffffc02000ce:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000d2:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000d4:	227010ef          	jal	ra,ffffffffc0201afa <vprintfmt>
    return cnt;
}
ffffffffc02000d8:	60e2                	ld	ra,24(sp)
ffffffffc02000da:	4532                	lw	a0,12(sp)
ffffffffc02000dc:	6105                	addi	sp,sp,32
ffffffffc02000de:	8082                	ret

ffffffffc02000e0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000e0:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000e2:	02810313          	addi	t1,sp,40 # ffffffffc0206028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000e6:	8e2a                	mv	t3,a0
ffffffffc02000e8:	f42e                	sd	a1,40(sp)
ffffffffc02000ea:	f832                	sd	a2,48(sp)
ffffffffc02000ec:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ee:	00000517          	auipc	a0,0x0
ffffffffc02000f2:	fb850513          	addi	a0,a0,-72 # ffffffffc02000a6 <cputch>
ffffffffc02000f6:	004c                	addi	a1,sp,4
ffffffffc02000f8:	869a                	mv	a3,t1
ffffffffc02000fa:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000fc:	ec06                	sd	ra,24(sp)
ffffffffc02000fe:	e0ba                	sd	a4,64(sp)
ffffffffc0200100:	e4be                	sd	a5,72(sp)
ffffffffc0200102:	e8c2                	sd	a6,80(sp)
ffffffffc0200104:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc0200106:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc0200108:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020010a:	1f1010ef          	jal	ra,ffffffffc0201afa <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc020010e:	60e2                	ld	ra,24(sp)
ffffffffc0200110:	4512                	lw	a0,4(sp)
ffffffffc0200112:	6125                	addi	sp,sp,96
ffffffffc0200114:	8082                	ret

ffffffffc0200116 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200116:	a695                	j	ffffffffc020047a <cons_putc>

ffffffffc0200118 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200118:	1101                	addi	sp,sp,-32
ffffffffc020011a:	e822                	sd	s0,16(sp)
ffffffffc020011c:	ec06                	sd	ra,24(sp)
ffffffffc020011e:	e426                	sd	s1,8(sp)
ffffffffc0200120:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200122:	00054503          	lbu	a0,0(a0)
ffffffffc0200126:	c51d                	beqz	a0,ffffffffc0200154 <cputs+0x3c>
ffffffffc0200128:	0405                	addi	s0,s0,1
ffffffffc020012a:	4485                	li	s1,1
ffffffffc020012c:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020012e:	34c000ef          	jal	ra,ffffffffc020047a <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200132:	00044503          	lbu	a0,0(s0)
ffffffffc0200136:	008487bb          	addw	a5,s1,s0
ffffffffc020013a:	0405                	addi	s0,s0,1
ffffffffc020013c:	f96d                	bnez	a0,ffffffffc020012e <cputs+0x16>
    (*cnt) ++;
ffffffffc020013e:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200142:	4529                	li	a0,10
ffffffffc0200144:	336000ef          	jal	ra,ffffffffc020047a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200148:	60e2                	ld	ra,24(sp)
ffffffffc020014a:	8522                	mv	a0,s0
ffffffffc020014c:	6442                	ld	s0,16(sp)
ffffffffc020014e:	64a2                	ld	s1,8(sp)
ffffffffc0200150:	6105                	addi	sp,sp,32
ffffffffc0200152:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200154:	4405                	li	s0,1
ffffffffc0200156:	b7f5                	j	ffffffffc0200142 <cputs+0x2a>

ffffffffc0200158 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200158:	1141                	addi	sp,sp,-16
ffffffffc020015a:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020015c:	326000ef          	jal	ra,ffffffffc0200482 <cons_getc>
ffffffffc0200160:	dd75                	beqz	a0,ffffffffc020015c <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200162:	60a2                	ld	ra,8(sp)
ffffffffc0200164:	0141                	addi	sp,sp,16
ffffffffc0200166:	8082                	ret

ffffffffc0200168 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200168:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	ef650513          	addi	a0,a0,-266 # ffffffffc0202060 <etext+0x24>
void print_kerninfo(void) {
ffffffffc0200172:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200174:	f6dff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc0200178:	00000597          	auipc	a1,0x0
ffffffffc020017c:	edc58593          	addi	a1,a1,-292 # ffffffffc0200054 <kern_init>
ffffffffc0200180:	00002517          	auipc	a0,0x2
ffffffffc0200184:	f0050513          	addi	a0,a0,-256 # ffffffffc0202080 <etext+0x44>
ffffffffc0200188:	f59ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020018c:	00002597          	auipc	a1,0x2
ffffffffc0200190:	eb058593          	addi	a1,a1,-336 # ffffffffc020203c <etext>
ffffffffc0200194:	00002517          	auipc	a0,0x2
ffffffffc0200198:	f0c50513          	addi	a0,a0,-244 # ffffffffc02020a0 <etext+0x64>
ffffffffc020019c:	f45ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001a0:	00007597          	auipc	a1,0x7
ffffffffc02001a4:	e8858593          	addi	a1,a1,-376 # ffffffffc0207028 <free_area>
ffffffffc02001a8:	00002517          	auipc	a0,0x2
ffffffffc02001ac:	f1850513          	addi	a0,a0,-232 # ffffffffc02020c0 <etext+0x84>
ffffffffc02001b0:	f31ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001b4:	00007597          	auipc	a1,0x7
ffffffffc02001b8:	2ec58593          	addi	a1,a1,748 # ffffffffc02074a0 <end>
ffffffffc02001bc:	00002517          	auipc	a0,0x2
ffffffffc02001c0:	f2450513          	addi	a0,a0,-220 # ffffffffc02020e0 <etext+0xa4>
ffffffffc02001c4:	f1dff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001c8:	00007597          	auipc	a1,0x7
ffffffffc02001cc:	6d758593          	addi	a1,a1,1751 # ffffffffc020789f <end+0x3ff>
ffffffffc02001d0:	00000797          	auipc	a5,0x0
ffffffffc02001d4:	e8478793          	addi	a5,a5,-380 # ffffffffc0200054 <kern_init>
ffffffffc02001d8:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001dc:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001e0:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001e2:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001e6:	95be                	add	a1,a1,a5
ffffffffc02001e8:	85a9                	srai	a1,a1,0xa
ffffffffc02001ea:	00002517          	auipc	a0,0x2
ffffffffc02001ee:	f1650513          	addi	a0,a0,-234 # ffffffffc0202100 <etext+0xc4>
}
ffffffffc02001f2:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001f4:	b5f5                	j	ffffffffc02000e0 <cprintf>

ffffffffc02001f6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001f6:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02001f8:	00002617          	auipc	a2,0x2
ffffffffc02001fc:	f3860613          	addi	a2,a2,-200 # ffffffffc0202130 <etext+0xf4>
ffffffffc0200200:	04d00593          	li	a1,77
ffffffffc0200204:	00002517          	auipc	a0,0x2
ffffffffc0200208:	f4450513          	addi	a0,a0,-188 # ffffffffc0202148 <etext+0x10c>
void print_stackframe(void) {
ffffffffc020020c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020020e:	1cc000ef          	jal	ra,ffffffffc02003da <__panic>

ffffffffc0200212 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200212:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200214:	00002617          	auipc	a2,0x2
ffffffffc0200218:	f4c60613          	addi	a2,a2,-180 # ffffffffc0202160 <etext+0x124>
ffffffffc020021c:	00002597          	auipc	a1,0x2
ffffffffc0200220:	f6458593          	addi	a1,a1,-156 # ffffffffc0202180 <etext+0x144>
ffffffffc0200224:	00002517          	auipc	a0,0x2
ffffffffc0200228:	f6450513          	addi	a0,a0,-156 # ffffffffc0202188 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020022c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020022e:	eb3ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0200232:	00002617          	auipc	a2,0x2
ffffffffc0200236:	f6660613          	addi	a2,a2,-154 # ffffffffc0202198 <etext+0x15c>
ffffffffc020023a:	00002597          	auipc	a1,0x2
ffffffffc020023e:	f8658593          	addi	a1,a1,-122 # ffffffffc02021c0 <etext+0x184>
ffffffffc0200242:	00002517          	auipc	a0,0x2
ffffffffc0200246:	f4650513          	addi	a0,a0,-186 # ffffffffc0202188 <etext+0x14c>
ffffffffc020024a:	e97ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc020024e:	00002617          	auipc	a2,0x2
ffffffffc0200252:	f8260613          	addi	a2,a2,-126 # ffffffffc02021d0 <etext+0x194>
ffffffffc0200256:	00002597          	auipc	a1,0x2
ffffffffc020025a:	f9a58593          	addi	a1,a1,-102 # ffffffffc02021f0 <etext+0x1b4>
ffffffffc020025e:	00002517          	auipc	a0,0x2
ffffffffc0200262:	f2a50513          	addi	a0,a0,-214 # ffffffffc0202188 <etext+0x14c>
ffffffffc0200266:	e7bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    }
    return 0;
}
ffffffffc020026a:	60a2                	ld	ra,8(sp)
ffffffffc020026c:	4501                	li	a0,0
ffffffffc020026e:	0141                	addi	sp,sp,16
ffffffffc0200270:	8082                	ret

ffffffffc0200272 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	1141                	addi	sp,sp,-16
ffffffffc0200274:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200276:	ef3ff0ef          	jal	ra,ffffffffc0200168 <print_kerninfo>
    return 0;
}
ffffffffc020027a:	60a2                	ld	ra,8(sp)
ffffffffc020027c:	4501                	li	a0,0
ffffffffc020027e:	0141                	addi	sp,sp,16
ffffffffc0200280:	8082                	ret

ffffffffc0200282 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1141                	addi	sp,sp,-16
ffffffffc0200284:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200286:	f71ff0ef          	jal	ra,ffffffffc02001f6 <print_stackframe>
    return 0;
}
ffffffffc020028a:	60a2                	ld	ra,8(sp)
ffffffffc020028c:	4501                	li	a0,0
ffffffffc020028e:	0141                	addi	sp,sp,16
ffffffffc0200290:	8082                	ret

ffffffffc0200292 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200292:	7115                	addi	sp,sp,-224
ffffffffc0200294:	ed5e                	sd	s7,152(sp)
ffffffffc0200296:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200298:	00002517          	auipc	a0,0x2
ffffffffc020029c:	f6850513          	addi	a0,a0,-152 # ffffffffc0202200 <etext+0x1c4>
kmonitor(struct trapframe *tf) {
ffffffffc02002a0:	ed86                	sd	ra,216(sp)
ffffffffc02002a2:	e9a2                	sd	s0,208(sp)
ffffffffc02002a4:	e5a6                	sd	s1,200(sp)
ffffffffc02002a6:	e1ca                	sd	s2,192(sp)
ffffffffc02002a8:	fd4e                	sd	s3,184(sp)
ffffffffc02002aa:	f952                	sd	s4,176(sp)
ffffffffc02002ac:	f556                	sd	s5,168(sp)
ffffffffc02002ae:	f15a                	sd	s6,160(sp)
ffffffffc02002b0:	e962                	sd	s8,144(sp)
ffffffffc02002b2:	e566                	sd	s9,136(sp)
ffffffffc02002b4:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002b6:	e2bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002ba:	00002517          	auipc	a0,0x2
ffffffffc02002be:	f6e50513          	addi	a0,a0,-146 # ffffffffc0202228 <etext+0x1ec>
ffffffffc02002c2:	e1fff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    if (tf != NULL) {
ffffffffc02002c6:	000b8563          	beqz	s7,ffffffffc02002d0 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002ca:	855e                	mv	a0,s7
ffffffffc02002cc:	756000ef          	jal	ra,ffffffffc0200a22 <print_trapframe>
ffffffffc02002d0:	00002c17          	auipc	s8,0x2
ffffffffc02002d4:	fc8c0c13          	addi	s8,s8,-56 # ffffffffc0202298 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d8:	00002917          	auipc	s2,0x2
ffffffffc02002dc:	f7890913          	addi	s2,s2,-136 # ffffffffc0202250 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	00002497          	auipc	s1,0x2
ffffffffc02002e4:	f7848493          	addi	s1,s1,-136 # ffffffffc0202258 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002e8:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002ea:	00002b17          	auipc	s6,0x2
ffffffffc02002ee:	f76b0b13          	addi	s6,s6,-138 # ffffffffc0202260 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc02002f2:	00002a17          	auipc	s4,0x2
ffffffffc02002f6:	e8ea0a13          	addi	s4,s4,-370 # ffffffffc0202180 <etext+0x144>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002fc:	854a                	mv	a0,s2
ffffffffc02002fe:	37f010ef          	jal	ra,ffffffffc0201e7c <readline>
ffffffffc0200302:	842a                	mv	s0,a0
ffffffffc0200304:	dd65                	beqz	a0,ffffffffc02002fc <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200306:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020030a:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	e1bd                	bnez	a1,ffffffffc0200372 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc020030e:	fe0c87e3          	beqz	s9,ffffffffc02002fc <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200312:	6582                	ld	a1,0(sp)
ffffffffc0200314:	00002d17          	auipc	s10,0x2
ffffffffc0200318:	f84d0d13          	addi	s10,s10,-124 # ffffffffc0202298 <commands>
        argv[argc ++] = buf;
ffffffffc020031c:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020031e:	4401                	li	s0,0
ffffffffc0200320:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200322:	4af010ef          	jal	ra,ffffffffc0201fd0 <strcmp>
ffffffffc0200326:	c919                	beqz	a0,ffffffffc020033c <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200328:	2405                	addiw	s0,s0,1
ffffffffc020032a:	0b540063          	beq	s0,s5,ffffffffc02003ca <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020032e:	000d3503          	ld	a0,0(s10)
ffffffffc0200332:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200334:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200336:	49b010ef          	jal	ra,ffffffffc0201fd0 <strcmp>
ffffffffc020033a:	f57d                	bnez	a0,ffffffffc0200328 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020033c:	00141793          	slli	a5,s0,0x1
ffffffffc0200340:	97a2                	add	a5,a5,s0
ffffffffc0200342:	078e                	slli	a5,a5,0x3
ffffffffc0200344:	97e2                	add	a5,a5,s8
ffffffffc0200346:	6b9c                	ld	a5,16(a5)
ffffffffc0200348:	865e                	mv	a2,s7
ffffffffc020034a:	002c                	addi	a1,sp,8
ffffffffc020034c:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200350:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200352:	fa0555e3          	bgez	a0,ffffffffc02002fc <kmonitor+0x6a>
}
ffffffffc0200356:	60ee                	ld	ra,216(sp)
ffffffffc0200358:	644e                	ld	s0,208(sp)
ffffffffc020035a:	64ae                	ld	s1,200(sp)
ffffffffc020035c:	690e                	ld	s2,192(sp)
ffffffffc020035e:	79ea                	ld	s3,184(sp)
ffffffffc0200360:	7a4a                	ld	s4,176(sp)
ffffffffc0200362:	7aaa                	ld	s5,168(sp)
ffffffffc0200364:	7b0a                	ld	s6,160(sp)
ffffffffc0200366:	6bea                	ld	s7,152(sp)
ffffffffc0200368:	6c4a                	ld	s8,144(sp)
ffffffffc020036a:	6caa                	ld	s9,136(sp)
ffffffffc020036c:	6d0a                	ld	s10,128(sp)
ffffffffc020036e:	612d                	addi	sp,sp,224
ffffffffc0200370:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200372:	8526                	mv	a0,s1
ffffffffc0200374:	4a1010ef          	jal	ra,ffffffffc0202014 <strchr>
ffffffffc0200378:	c901                	beqz	a0,ffffffffc0200388 <kmonitor+0xf6>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc020037e:	00040023          	sb	zero,0(s0)
ffffffffc0200382:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200384:	d5c9                	beqz	a1,ffffffffc020030e <kmonitor+0x7c>
ffffffffc0200386:	b7f5                	j	ffffffffc0200372 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200388:	00044783          	lbu	a5,0(s0)
ffffffffc020038c:	d3c9                	beqz	a5,ffffffffc020030e <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc020038e:	033c8963          	beq	s9,s3,ffffffffc02003c0 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200392:	003c9793          	slli	a5,s9,0x3
ffffffffc0200396:	0118                	addi	a4,sp,128
ffffffffc0200398:	97ba                	add	a5,a5,a4
ffffffffc020039a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039e:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003a2:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a4:	e591                	bnez	a1,ffffffffc02003b0 <kmonitor+0x11e>
ffffffffc02003a6:	b7b5                	j	ffffffffc0200312 <kmonitor+0x80>
ffffffffc02003a8:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003ac:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003ae:	d1a5                	beqz	a1,ffffffffc020030e <kmonitor+0x7c>
ffffffffc02003b0:	8526                	mv	a0,s1
ffffffffc02003b2:	463010ef          	jal	ra,ffffffffc0202014 <strchr>
ffffffffc02003b6:	d96d                	beqz	a0,ffffffffc02003a8 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b8:	00044583          	lbu	a1,0(s0)
ffffffffc02003bc:	d9a9                	beqz	a1,ffffffffc020030e <kmonitor+0x7c>
ffffffffc02003be:	bf55                	j	ffffffffc0200372 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003c0:	45c1                	li	a1,16
ffffffffc02003c2:	855a                	mv	a0,s6
ffffffffc02003c4:	d1dff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc02003c8:	b7e9                	j	ffffffffc0200392 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003ca:	6582                	ld	a1,0(sp)
ffffffffc02003cc:	00002517          	auipc	a0,0x2
ffffffffc02003d0:	eb450513          	addi	a0,a0,-332 # ffffffffc0202280 <etext+0x244>
ffffffffc02003d4:	d0dff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    return 0;
ffffffffc02003d8:	b715                	j	ffffffffc02002fc <kmonitor+0x6a>

ffffffffc02003da <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003da:	00007317          	auipc	t1,0x7
ffffffffc02003de:	06630313          	addi	t1,t1,102 # ffffffffc0207440 <is_panic>
ffffffffc02003e2:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003e6:	715d                	addi	sp,sp,-80
ffffffffc02003e8:	ec06                	sd	ra,24(sp)
ffffffffc02003ea:	e822                	sd	s0,16(sp)
ffffffffc02003ec:	f436                	sd	a3,40(sp)
ffffffffc02003ee:	f83a                	sd	a4,48(sp)
ffffffffc02003f0:	fc3e                	sd	a5,56(sp)
ffffffffc02003f2:	e0c2                	sd	a6,64(sp)
ffffffffc02003f4:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003f6:	020e1a63          	bnez	t3,ffffffffc020042a <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003fa:	4785                	li	a5,1
ffffffffc02003fc:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200400:	8432                	mv	s0,a2
ffffffffc0200402:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200404:	862e                	mv	a2,a1
ffffffffc0200406:	85aa                	mv	a1,a0
ffffffffc0200408:	00002517          	auipc	a0,0x2
ffffffffc020040c:	ed850513          	addi	a0,a0,-296 # ffffffffc02022e0 <commands+0x48>
    va_start(ap, fmt);
ffffffffc0200410:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200412:	ccfff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200416:	65a2                	ld	a1,8(sp)
ffffffffc0200418:	8522                	mv	a0,s0
ffffffffc020041a:	ca7ff0ef          	jal	ra,ffffffffc02000c0 <vcprintf>
    cprintf("\n");
ffffffffc020041e:	00002517          	auipc	a0,0x2
ffffffffc0200422:	57250513          	addi	a0,a0,1394 # ffffffffc0202990 <commands+0x6f8>
ffffffffc0200426:	cbbff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020042a:	412000ef          	jal	ra,ffffffffc020083c <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020042e:	4501                	li	a0,0
ffffffffc0200430:	e63ff0ef          	jal	ra,ffffffffc0200292 <kmonitor>
    while (1) {
ffffffffc0200434:	bfed                	j	ffffffffc020042e <__panic+0x54>

ffffffffc0200436 <clock_init>:
 * clock_init - 初始化时钟中断
 * 1. 使能S模式的时钟中断
 * 2. 设置第一次时钟中断事件
 * 3. 初始化 ticks 计数器
 */
void clock_init(void) {
ffffffffc0200436:	1141                	addi	sp,sp,-16
ffffffffc0200438:	e406                	sd	ra,8(sp)
     * sie (Supervisor Interrupt Enable) 是一个 CSR，用于控制哪些中断可以上报给 S 模式。
     * set_csr 宏用于设置 sie 寄存器中的某一位。
     * MIP_STIP (定义在 riscv.h) 是 Supervisor Timer Interrupt Pending (STIP) 位的掩码。
     * 这行代码的作用是：使能S模式的时钟中断。
     */
    set_csr(sie, MIP_STIP);
ffffffffc020043a:	02000793          	li	a5,32
ffffffffc020043e:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200442:	c0102573          	rdtime	a0
     * 它告诉 M 模式：“请在 time 寄存器的值达到 X 时，向 S 模式触发一个时钟中断”。
     * * get_cycles()：获取当前 time 寄存器的值。
     * get_cycles() + timebase：计算出下一次中断的目标时间
     * （即：当前时间 + 100,000 节拍）。
     */
    sbi_set_timer(get_cycles() + timebase);
ffffffffc0200446:	67e1                	lui	a5,0x18
ffffffffc0200448:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020044c:	953e                	add	a0,a0,a5
ffffffffc020044e:	2fd010ef          	jal	ra,ffffffffc0201f4a <sbi_set_timer>
}
ffffffffc0200452:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200454:	00007797          	auipc	a5,0x7
ffffffffc0200458:	fe07ba23          	sd	zero,-12(a5) # ffffffffc0207448 <ticks>
    cprintf("++ setup timer interrupts\n"); // 打印初始化完成信息
ffffffffc020045c:	00002517          	auipc	a0,0x2
ffffffffc0200460:	ea450513          	addi	a0,a0,-348 # ffffffffc0202300 <commands+0x68>
}
ffffffffc0200464:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n"); // 打印初始化完成信息
ffffffffc0200466:	b9ad                	j	ffffffffc02000e0 <cprintf>

ffffffffc0200468 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200468:	c0102573          	rdtime	a0
    sbi_set_timer(get_cycles() + timebase);
ffffffffc020046c:	67e1                	lui	a5,0x18
ffffffffc020046e:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200472:	953e                	add	a0,a0,a5
ffffffffc0200474:	2d70106f          	j	ffffffffc0201f4a <sbi_set_timer>

ffffffffc0200478 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200478:	8082                	ret

ffffffffc020047a <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020047a:	0ff57513          	zext.b	a0,a0
ffffffffc020047e:	2b30106f          	j	ffffffffc0201f30 <sbi_console_putchar>

ffffffffc0200482 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200482:	2e30106f          	j	ffffffffc0201f64 <sbi_console_getchar>

ffffffffc0200486 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200486:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200488:	00002517          	auipc	a0,0x2
ffffffffc020048c:	e9850513          	addi	a0,a0,-360 # ffffffffc0202320 <commands+0x88>
void dtb_init(void) {
ffffffffc0200490:	fc86                	sd	ra,120(sp)
ffffffffc0200492:	f8a2                	sd	s0,112(sp)
ffffffffc0200494:	e8d2                	sd	s4,80(sp)
ffffffffc0200496:	f4a6                	sd	s1,104(sp)
ffffffffc0200498:	f0ca                	sd	s2,96(sp)
ffffffffc020049a:	ecce                	sd	s3,88(sp)
ffffffffc020049c:	e4d6                	sd	s5,72(sp)
ffffffffc020049e:	e0da                	sd	s6,64(sp)
ffffffffc02004a0:	fc5e                	sd	s7,56(sp)
ffffffffc02004a2:	f862                	sd	s8,48(sp)
ffffffffc02004a4:	f466                	sd	s9,40(sp)
ffffffffc02004a6:	f06a                	sd	s10,32(sp)
ffffffffc02004a8:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc02004aa:	c37ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02004ae:	00007597          	auipc	a1,0x7
ffffffffc02004b2:	b525b583          	ld	a1,-1198(a1) # ffffffffc0207000 <boot_hartid>
ffffffffc02004b6:	00002517          	auipc	a0,0x2
ffffffffc02004ba:	e7a50513          	addi	a0,a0,-390 # ffffffffc0202330 <commands+0x98>
ffffffffc02004be:	c23ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02004c2:	00007417          	auipc	s0,0x7
ffffffffc02004c6:	b4640413          	addi	s0,s0,-1210 # ffffffffc0207008 <boot_dtb>
ffffffffc02004ca:	600c                	ld	a1,0(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	e7450513          	addi	a0,a0,-396 # ffffffffc0202340 <commands+0xa8>
ffffffffc02004d4:	c0dff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc02004d8:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc02004dc:	00002517          	auipc	a0,0x2
ffffffffc02004e0:	e7c50513          	addi	a0,a0,-388 # ffffffffc0202358 <commands+0xc0>
    if (boot_dtb == 0) {
ffffffffc02004e4:	120a0463          	beqz	s4,ffffffffc020060c <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc02004e8:	57f5                	li	a5,-3
ffffffffc02004ea:	07fa                	slli	a5,a5,0x1e
ffffffffc02004ec:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc02004f0:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004f2:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004f6:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004f8:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02004fc:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200500:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200504:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200508:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020050c:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020050e:	8ec9                	or	a3,a3,a0
ffffffffc0200510:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200514:	1b7d                	addi	s6,s6,-1
ffffffffc0200516:	0167f7b3          	and	a5,a5,s6
ffffffffc020051a:	8dd5                	or	a1,a1,a3
ffffffffc020051c:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc020051e:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200522:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc0200524:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed8a4d>
ffffffffc0200528:	10f59163          	bne	a1,a5,ffffffffc020062a <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc020052c:	471c                	lw	a5,8(a4)
ffffffffc020052e:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc0200530:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200532:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200536:	0086d51b          	srliw	a0,a3,0x8
ffffffffc020053a:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020053e:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200542:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200546:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020054a:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020054e:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200552:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200556:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020055a:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020055c:	01146433          	or	s0,s0,a7
ffffffffc0200560:	0086969b          	slliw	a3,a3,0x8
ffffffffc0200564:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200568:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020056a:	0087979b          	slliw	a5,a5,0x8
ffffffffc020056e:	8c49                	or	s0,s0,a0
ffffffffc0200570:	0166f6b3          	and	a3,a3,s6
ffffffffc0200574:	00ca6a33          	or	s4,s4,a2
ffffffffc0200578:	0167f7b3          	and	a5,a5,s6
ffffffffc020057c:	8c55                	or	s0,s0,a3
ffffffffc020057e:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200582:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200584:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200586:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200588:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020058c:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020058e:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200590:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc0200594:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200596:	00002917          	auipc	s2,0x2
ffffffffc020059a:	e1290913          	addi	s2,s2,-494 # ffffffffc02023a8 <commands+0x110>
ffffffffc020059e:	49bd                	li	s3,15
        switch (token) {
ffffffffc02005a0:	4d91                	li	s11,4
ffffffffc02005a2:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02005a4:	00002497          	auipc	s1,0x2
ffffffffc02005a8:	dfc48493          	addi	s1,s1,-516 # ffffffffc02023a0 <commands+0x108>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02005ac:	000a2703          	lw	a4,0(s4)
ffffffffc02005b0:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005b4:	0087569b          	srliw	a3,a4,0x8
ffffffffc02005b8:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005bc:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005c0:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005c4:	0107571b          	srliw	a4,a4,0x10
ffffffffc02005c8:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005ca:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005ce:	0087171b          	slliw	a4,a4,0x8
ffffffffc02005d2:	8fd5                	or	a5,a5,a3
ffffffffc02005d4:	00eb7733          	and	a4,s6,a4
ffffffffc02005d8:	8fd9                	or	a5,a5,a4
ffffffffc02005da:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc02005dc:	09778c63          	beq	a5,s7,ffffffffc0200674 <dtb_init+0x1ee>
ffffffffc02005e0:	00fbea63          	bltu	s7,a5,ffffffffc02005f4 <dtb_init+0x16e>
ffffffffc02005e4:	07a78663          	beq	a5,s10,ffffffffc0200650 <dtb_init+0x1ca>
ffffffffc02005e8:	4709                	li	a4,2
ffffffffc02005ea:	00e79763          	bne	a5,a4,ffffffffc02005f8 <dtb_init+0x172>
ffffffffc02005ee:	4c81                	li	s9,0
ffffffffc02005f0:	8a56                	mv	s4,s5
ffffffffc02005f2:	bf6d                	j	ffffffffc02005ac <dtb_init+0x126>
ffffffffc02005f4:	ffb78ee3          	beq	a5,s11,ffffffffc02005f0 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc02005f8:	00002517          	auipc	a0,0x2
ffffffffc02005fc:	e2850513          	addi	a0,a0,-472 # ffffffffc0202420 <commands+0x188>
ffffffffc0200600:	ae1ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200604:	00002517          	auipc	a0,0x2
ffffffffc0200608:	e5450513          	addi	a0,a0,-428 # ffffffffc0202458 <commands+0x1c0>
}
ffffffffc020060c:	7446                	ld	s0,112(sp)
ffffffffc020060e:	70e6                	ld	ra,120(sp)
ffffffffc0200610:	74a6                	ld	s1,104(sp)
ffffffffc0200612:	7906                	ld	s2,96(sp)
ffffffffc0200614:	69e6                	ld	s3,88(sp)
ffffffffc0200616:	6a46                	ld	s4,80(sp)
ffffffffc0200618:	6aa6                	ld	s5,72(sp)
ffffffffc020061a:	6b06                	ld	s6,64(sp)
ffffffffc020061c:	7be2                	ld	s7,56(sp)
ffffffffc020061e:	7c42                	ld	s8,48(sp)
ffffffffc0200620:	7ca2                	ld	s9,40(sp)
ffffffffc0200622:	7d02                	ld	s10,32(sp)
ffffffffc0200624:	6de2                	ld	s11,24(sp)
ffffffffc0200626:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc0200628:	bc65                	j	ffffffffc02000e0 <cprintf>
}
ffffffffc020062a:	7446                	ld	s0,112(sp)
ffffffffc020062c:	70e6                	ld	ra,120(sp)
ffffffffc020062e:	74a6                	ld	s1,104(sp)
ffffffffc0200630:	7906                	ld	s2,96(sp)
ffffffffc0200632:	69e6                	ld	s3,88(sp)
ffffffffc0200634:	6a46                	ld	s4,80(sp)
ffffffffc0200636:	6aa6                	ld	s5,72(sp)
ffffffffc0200638:	6b06                	ld	s6,64(sp)
ffffffffc020063a:	7be2                	ld	s7,56(sp)
ffffffffc020063c:	7c42                	ld	s8,48(sp)
ffffffffc020063e:	7ca2                	ld	s9,40(sp)
ffffffffc0200640:	7d02                	ld	s10,32(sp)
ffffffffc0200642:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200644:	00002517          	auipc	a0,0x2
ffffffffc0200648:	d3450513          	addi	a0,a0,-716 # ffffffffc0202378 <commands+0xe0>
}
ffffffffc020064c:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc020064e:	bc49                	j	ffffffffc02000e0 <cprintf>
                int name_len = strlen(name);
ffffffffc0200650:	8556                	mv	a0,s5
ffffffffc0200652:	149010ef          	jal	ra,ffffffffc0201f9a <strlen>
ffffffffc0200656:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200658:	4619                	li	a2,6
ffffffffc020065a:	85a6                	mv	a1,s1
ffffffffc020065c:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc020065e:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200660:	18f010ef          	jal	ra,ffffffffc0201fee <strncmp>
ffffffffc0200664:	e111                	bnez	a0,ffffffffc0200668 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc0200666:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200668:	0a91                	addi	s5,s5,4
ffffffffc020066a:	9ad2                	add	s5,s5,s4
ffffffffc020066c:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200670:	8a56                	mv	s4,s5
ffffffffc0200672:	bf2d                	j	ffffffffc02005ac <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200674:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200678:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020067c:	0087d71b          	srliw	a4,a5,0x8
ffffffffc0200680:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200684:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200688:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020068c:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200690:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200694:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200698:	0087979b          	slliw	a5,a5,0x8
ffffffffc020069c:	00eaeab3          	or	s5,s5,a4
ffffffffc02006a0:	00fb77b3          	and	a5,s6,a5
ffffffffc02006a4:	00faeab3          	or	s5,s5,a5
ffffffffc02006a8:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006aa:	000c9c63          	bnez	s9,ffffffffc02006c2 <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02006ae:	1a82                	slli	s5,s5,0x20
ffffffffc02006b0:	00368793          	addi	a5,a3,3
ffffffffc02006b4:	020ada93          	srli	s5,s5,0x20
ffffffffc02006b8:	9abe                	add	s5,s5,a5
ffffffffc02006ba:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02006be:	8a56                	mv	s4,s5
ffffffffc02006c0:	b5f5                	j	ffffffffc02005ac <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006c2:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006c6:	85ca                	mv	a1,s2
ffffffffc02006c8:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ca:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ce:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006d2:	0187971b          	slliw	a4,a5,0x18
ffffffffc02006d6:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006da:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02006de:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006e0:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006e4:	0087979b          	slliw	a5,a5,0x8
ffffffffc02006e8:	8d59                	or	a0,a0,a4
ffffffffc02006ea:	00fb77b3          	and	a5,s6,a5
ffffffffc02006ee:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc02006f0:	1502                	slli	a0,a0,0x20
ffffffffc02006f2:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006f4:	9522                	add	a0,a0,s0
ffffffffc02006f6:	0db010ef          	jal	ra,ffffffffc0201fd0 <strcmp>
ffffffffc02006fa:	66a2                	ld	a3,8(sp)
ffffffffc02006fc:	f94d                	bnez	a0,ffffffffc02006ae <dtb_init+0x228>
ffffffffc02006fe:	fb59f8e3          	bgeu	s3,s5,ffffffffc02006ae <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200702:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200706:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020070a:	00002517          	auipc	a0,0x2
ffffffffc020070e:	ca650513          	addi	a0,a0,-858 # ffffffffc02023b0 <commands+0x118>
           fdt32_to_cpu(x >> 32);
ffffffffc0200712:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200716:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc020071a:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020071e:	0187de1b          	srliw	t3,a5,0x18
ffffffffc0200722:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200726:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020072a:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020072e:	0187d693          	srli	a3,a5,0x18
ffffffffc0200732:	01861f1b          	slliw	t5,a2,0x18
ffffffffc0200736:	0087579b          	srliw	a5,a4,0x8
ffffffffc020073a:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020073e:	0106561b          	srliw	a2,a2,0x10
ffffffffc0200742:	010f6f33          	or	t5,t5,a6
ffffffffc0200746:	0187529b          	srliw	t0,a4,0x18
ffffffffc020074a:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020074e:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200752:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200756:	0186f6b3          	and	a3,a3,s8
ffffffffc020075a:	01859e1b          	slliw	t3,a1,0x18
ffffffffc020075e:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200762:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200766:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020076a:	8361                	srli	a4,a4,0x18
ffffffffc020076c:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200770:	0105d59b          	srliw	a1,a1,0x10
ffffffffc0200774:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200778:	00cb7633          	and	a2,s6,a2
ffffffffc020077c:	0088181b          	slliw	a6,a6,0x8
ffffffffc0200780:	0085959b          	slliw	a1,a1,0x8
ffffffffc0200784:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200788:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020078c:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200790:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200794:	0088989b          	slliw	a7,a7,0x8
ffffffffc0200798:	011b78b3          	and	a7,s6,a7
ffffffffc020079c:	005eeeb3          	or	t4,t4,t0
ffffffffc02007a0:	00c6e733          	or	a4,a3,a2
ffffffffc02007a4:	006c6c33          	or	s8,s8,t1
ffffffffc02007a8:	010b76b3          	and	a3,s6,a6
ffffffffc02007ac:	00bb7b33          	and	s6,s6,a1
ffffffffc02007b0:	01d7e7b3          	or	a5,a5,t4
ffffffffc02007b4:	016c6b33          	or	s6,s8,s6
ffffffffc02007b8:	01146433          	or	s0,s0,a7
ffffffffc02007bc:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc02007be:	1702                	slli	a4,a4,0x20
ffffffffc02007c0:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02007c2:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc02007c4:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02007c6:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc02007c8:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02007cc:	0167eb33          	or	s6,a5,s6
ffffffffc02007d0:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc02007d2:	90fff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc02007d6:	85a2                	mv	a1,s0
ffffffffc02007d8:	00002517          	auipc	a0,0x2
ffffffffc02007dc:	bf850513          	addi	a0,a0,-1032 # ffffffffc02023d0 <commands+0x138>
ffffffffc02007e0:	901ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc02007e4:	014b5613          	srli	a2,s6,0x14
ffffffffc02007e8:	85da                	mv	a1,s6
ffffffffc02007ea:	00002517          	auipc	a0,0x2
ffffffffc02007ee:	bfe50513          	addi	a0,a0,-1026 # ffffffffc02023e8 <commands+0x150>
ffffffffc02007f2:	8efff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02007f6:	008b05b3          	add	a1,s6,s0
ffffffffc02007fa:	15fd                	addi	a1,a1,-1
ffffffffc02007fc:	00002517          	auipc	a0,0x2
ffffffffc0200800:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0202408 <commands+0x170>
ffffffffc0200804:	8ddff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200808:	00002517          	auipc	a0,0x2
ffffffffc020080c:	c5050513          	addi	a0,a0,-944 # ffffffffc0202458 <commands+0x1c0>
        memory_base = mem_base;
ffffffffc0200810:	00007797          	auipc	a5,0x7
ffffffffc0200814:	c487b023          	sd	s0,-960(a5) # ffffffffc0207450 <memory_base>
        memory_size = mem_size;
ffffffffc0200818:	00007797          	auipc	a5,0x7
ffffffffc020081c:	c567b023          	sd	s6,-960(a5) # ffffffffc0207458 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200820:	b3f5                	j	ffffffffc020060c <dtb_init+0x186>

ffffffffc0200822 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc0200822:	00007517          	auipc	a0,0x7
ffffffffc0200826:	c2e53503          	ld	a0,-978(a0) # ffffffffc0207450 <memory_base>
ffffffffc020082a:	8082                	ret

ffffffffc020082c <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc020082c:	00007517          	auipc	a0,0x7
ffffffffc0200830:	c2c53503          	ld	a0,-980(a0) # ffffffffc0207458 <memory_size>
ffffffffc0200834:	8082                	ret

ffffffffc0200836 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200836:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020083a:	8082                	ret

ffffffffc020083c <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020083c:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200840:	8082                	ret

ffffffffc0200842 <idt_init>:
    /* * 设置 sscratch 寄存器为 0。
     * sscratch 是一个 S 模式 CSR，用于在 U/S 态切换时临时保存栈指针。
     * 在 ucore 的设计中，sscratch 为 0 表示当前在 S 模式（内核态）执行。
     * 当从 U 模式陷入时，__alltraps 会用 sscratch 保存的内核栈顶替换 sp。
     */
    write_csr(sscratch, 0);
ffffffffc0200842:	14005073          	csrwi	sscratch,0
    /* * 设置 stvec (Supervisor Trap Vector Base Address) 寄存器。
     * 这是 S 模式最重要的陷阱控制寄存器之一。
     * 它指向所有 S 模式中断和异常的唯一入口点。
     * 这里将其设置为汇编函数 __alltraps 的地址。
     */
    write_csr(stvec, &__alltraps);
ffffffffc0200846:	00000797          	auipc	a5,0x0
ffffffffc020084a:	42278793          	addi	a5,a5,1058 # ffffffffc0200c68 <__alltraps>
ffffffffc020084e:	10579073          	csrw	stvec,a5
}
ffffffffc0200852:	8082                	ret

ffffffffc0200854 <print_regs>:
    cprintf("   cause    0x%08x\n", tf->cause);   // 打印 scause (S 模式陷阱原因)
}

// 打印通用寄存器组（gpr）的内容，用于调试
void print_regs(struct pushregs *gpr) {
    cprintf("   zero     0x%08x\n", gpr->zero); // x0 (硬编码为 0)
ffffffffc0200854:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200856:	1141                	addi	sp,sp,-16
ffffffffc0200858:	e022                	sd	s0,0(sp)
ffffffffc020085a:	842a                	mv	s0,a0
    cprintf("   zero     0x%08x\n", gpr->zero); // x0 (硬编码为 0)
ffffffffc020085c:	00002517          	auipc	a0,0x2
ffffffffc0200860:	c1450513          	addi	a0,a0,-1004 # ffffffffc0202470 <commands+0x1d8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200864:	e406                	sd	ra,8(sp)
    cprintf("   zero     0x%08x\n", gpr->zero); // x0 (硬编码为 0)
ffffffffc0200866:	87bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   ra       0x%08x\n", gpr->ra);   // x1 (返回地址, Return Address)
ffffffffc020086a:	640c                	ld	a1,8(s0)
ffffffffc020086c:	00002517          	auipc	a0,0x2
ffffffffc0200870:	c1c50513          	addi	a0,a0,-996 # ffffffffc0202488 <commands+0x1f0>
ffffffffc0200874:	86dff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   sp       0x%08x\n", gpr->sp);   // x2 (栈指针, Stack Pointer)
ffffffffc0200878:	680c                	ld	a1,16(s0)
ffffffffc020087a:	00002517          	auipc	a0,0x2
ffffffffc020087e:	c2650513          	addi	a0,a0,-986 # ffffffffc02024a0 <commands+0x208>
ffffffffc0200882:	85fff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   gp       0x%08x\n", gpr->gp);   // x3 (全局指针, Global Pointer)
ffffffffc0200886:	6c0c                	ld	a1,24(s0)
ffffffffc0200888:	00002517          	auipc	a0,0x2
ffffffffc020088c:	c3050513          	addi	a0,a0,-976 # ffffffffc02024b8 <commands+0x220>
ffffffffc0200890:	851ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   tp       0x%08x\n", gpr->tp);   // x4 (线程指针, Thread Pointer)
ffffffffc0200894:	700c                	ld	a1,32(s0)
ffffffffc0200896:	00002517          	auipc	a0,0x2
ffffffffc020089a:	c3a50513          	addi	a0,a0,-966 # ffffffffc02024d0 <commands+0x238>
ffffffffc020089e:	843ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   t0       0x%08x\n", gpr->t0);   // x5 (临时寄存器 0, Temporary)
ffffffffc02008a2:	740c                	ld	a1,40(s0)
ffffffffc02008a4:	00002517          	auipc	a0,0x2
ffffffffc02008a8:	c4450513          	addi	a0,a0,-956 # ffffffffc02024e8 <commands+0x250>
ffffffffc02008ac:	835ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   t1       0x%08x\n", gpr->t1);   // x6 (临时寄存器 1)
ffffffffc02008b0:	780c                	ld	a1,48(s0)
ffffffffc02008b2:	00002517          	auipc	a0,0x2
ffffffffc02008b6:	c4e50513          	addi	a0,a0,-946 # ffffffffc0202500 <commands+0x268>
ffffffffc02008ba:	827ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   t2       0x%08x\n", gpr->t2);   // x7 (临时寄存器 2)
ffffffffc02008be:	7c0c                	ld	a1,56(s0)
ffffffffc02008c0:	00002517          	auipc	a0,0x2
ffffffffc02008c4:	c5850513          	addi	a0,a0,-936 # ffffffffc0202518 <commands+0x280>
ffffffffc02008c8:	819ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   s0       0x%08x\n", gpr->s0);   // x8 (保存寄存器 0 / 帧指针, Frame Pointer)
ffffffffc02008cc:	602c                	ld	a1,64(s0)
ffffffffc02008ce:	00002517          	auipc	a0,0x2
ffffffffc02008d2:	c6250513          	addi	a0,a0,-926 # ffffffffc0202530 <commands+0x298>
ffffffffc02008d6:	80bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   s1       0x%08x\n", gpr->s1);   // x9 (保存寄存器 1, Saved Register)
ffffffffc02008da:	642c                	ld	a1,72(s0)
ffffffffc02008dc:	00002517          	auipc	a0,0x2
ffffffffc02008e0:	c6c50513          	addi	a0,a0,-916 # ffffffffc0202548 <commands+0x2b0>
ffffffffc02008e4:	ffcff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   a0       0x%08x\n", gpr->a0);   // x10 (参数/返回值 0, Argument/Return Value)
ffffffffc02008e8:	682c                	ld	a1,80(s0)
ffffffffc02008ea:	00002517          	auipc	a0,0x2
ffffffffc02008ee:	c7650513          	addi	a0,a0,-906 # ffffffffc0202560 <commands+0x2c8>
ffffffffc02008f2:	feeff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   a1       0x%08x\n", gpr->a1);   // x11 (参数/返回值 1)
ffffffffc02008f6:	6c2c                	ld	a1,88(s0)
ffffffffc02008f8:	00002517          	auipc	a0,0x2
ffffffffc02008fc:	c8050513          	addi	a0,a0,-896 # ffffffffc0202578 <commands+0x2e0>
ffffffffc0200900:	fe0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   a2       0x%08x\n", gpr->a2);   // x12 (参数 2)
ffffffffc0200904:	702c                	ld	a1,96(s0)
ffffffffc0200906:	00002517          	auipc	a0,0x2
ffffffffc020090a:	c8a50513          	addi	a0,a0,-886 # ffffffffc0202590 <commands+0x2f8>
ffffffffc020090e:	fd2ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   a3       0x%08x\n", gpr->a3);   // x13 (参数 3)
ffffffffc0200912:	742c                	ld	a1,104(s0)
ffffffffc0200914:	00002517          	auipc	a0,0x2
ffffffffc0200918:	c9450513          	addi	a0,a0,-876 # ffffffffc02025a8 <commands+0x310>
ffffffffc020091c:	fc4ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   a4       0x%08x\n", gpr->a4);   // x14 (参数 4)
ffffffffc0200920:	782c                	ld	a1,112(s0)
ffffffffc0200922:	00002517          	auipc	a0,0x2
ffffffffc0200926:	c9e50513          	addi	a0,a0,-866 # ffffffffc02025c0 <commands+0x328>
ffffffffc020092a:	fb6ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   a5       0x%08x\n", gpr->a5);   // x15 (参数 5)
ffffffffc020092e:	7c2c                	ld	a1,120(s0)
ffffffffc0200930:	00002517          	auipc	a0,0x2
ffffffffc0200934:	ca850513          	addi	a0,a0,-856 # ffffffffc02025d8 <commands+0x340>
ffffffffc0200938:	fa8ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   a6       0x%08x\n", gpr->a6);   // x16 (参数 6)
ffffffffc020093c:	604c                	ld	a1,128(s0)
ffffffffc020093e:	00002517          	auipc	a0,0x2
ffffffffc0200942:	cb250513          	addi	a0,a0,-846 # ffffffffc02025f0 <commands+0x358>
ffffffffc0200946:	f9aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   a7       0x%08x\n", gpr->a7);   // x17 (参数 7)
ffffffffc020094a:	644c                	ld	a1,136(s0)
ffffffffc020094c:	00002517          	auipc	a0,0x2
ffffffffc0200950:	cbc50513          	addi	a0,a0,-836 # ffffffffc0202608 <commands+0x370>
ffffffffc0200954:	f8cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   s2       0x%08x\n", gpr->s2);   // x18 (保存寄存器 2)
ffffffffc0200958:	684c                	ld	a1,144(s0)
ffffffffc020095a:	00002517          	auipc	a0,0x2
ffffffffc020095e:	cc650513          	addi	a0,a0,-826 # ffffffffc0202620 <commands+0x388>
ffffffffc0200962:	f7eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   s3       0x%08x\n", gpr->s3);   // x19 (保存寄存器 3)
ffffffffc0200966:	6c4c                	ld	a1,152(s0)
ffffffffc0200968:	00002517          	auipc	a0,0x2
ffffffffc020096c:	cd050513          	addi	a0,a0,-816 # ffffffffc0202638 <commands+0x3a0>
ffffffffc0200970:	f70ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   s4       0x%08x\n", gpr->s4);   // x20 (保存寄存器 4)
ffffffffc0200974:	704c                	ld	a1,160(s0)
ffffffffc0200976:	00002517          	auipc	a0,0x2
ffffffffc020097a:	cda50513          	addi	a0,a0,-806 # ffffffffc0202650 <commands+0x3b8>
ffffffffc020097e:	f62ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   s5       0x%08x\n", gpr->s5);   // x21 (保存寄存器 5)
ffffffffc0200982:	744c                	ld	a1,168(s0)
ffffffffc0200984:	00002517          	auipc	a0,0x2
ffffffffc0200988:	ce450513          	addi	a0,a0,-796 # ffffffffc0202668 <commands+0x3d0>
ffffffffc020098c:	f54ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   s6       0x%08x\n", gpr->s6);   // x22 (保存寄存器 6)
ffffffffc0200990:	784c                	ld	a1,176(s0)
ffffffffc0200992:	00002517          	auipc	a0,0x2
ffffffffc0200996:	cee50513          	addi	a0,a0,-786 # ffffffffc0202680 <commands+0x3e8>
ffffffffc020099a:	f46ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   s7       0x%08x\n", gpr->s7);   // x23 (保存寄存器 7)
ffffffffc020099e:	7c4c                	ld	a1,184(s0)
ffffffffc02009a0:	00002517          	auipc	a0,0x2
ffffffffc02009a4:	cf850513          	addi	a0,a0,-776 # ffffffffc0202698 <commands+0x400>
ffffffffc02009a8:	f38ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   s8       0x%08x\n", gpr->s8);   // x24 (保存寄存器 8)
ffffffffc02009ac:	606c                	ld	a1,192(s0)
ffffffffc02009ae:	00002517          	auipc	a0,0x2
ffffffffc02009b2:	d0250513          	addi	a0,a0,-766 # ffffffffc02026b0 <commands+0x418>
ffffffffc02009b6:	f2aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   s9       0x%08x\n", gpr->s9);   // x25 (保存寄存器 9)
ffffffffc02009ba:	646c                	ld	a1,200(s0)
ffffffffc02009bc:	00002517          	auipc	a0,0x2
ffffffffc02009c0:	d0c50513          	addi	a0,a0,-756 # ffffffffc02026c8 <commands+0x430>
ffffffffc02009c4:	f1cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   s10      0x%08x\n", gpr->s10);  // x26 (保存寄存器 10)
ffffffffc02009c8:	686c                	ld	a1,208(s0)
ffffffffc02009ca:	00002517          	auipc	a0,0x2
ffffffffc02009ce:	d1650513          	addi	a0,a0,-746 # ffffffffc02026e0 <commands+0x448>
ffffffffc02009d2:	f0eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   s11      0x%08x\n", gpr->s11);  // x27 (保存寄存器 11)
ffffffffc02009d6:	6c6c                	ld	a1,216(s0)
ffffffffc02009d8:	00002517          	auipc	a0,0x2
ffffffffc02009dc:	d2050513          	addi	a0,a0,-736 # ffffffffc02026f8 <commands+0x460>
ffffffffc02009e0:	f00ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   t3       0x%08x\n", gpr->t3);   // x28 (临时寄存器 3)
ffffffffc02009e4:	706c                	ld	a1,224(s0)
ffffffffc02009e6:	00002517          	auipc	a0,0x2
ffffffffc02009ea:	d2a50513          	addi	a0,a0,-726 # ffffffffc0202710 <commands+0x478>
ffffffffc02009ee:	ef2ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   t4       0x%08x\n", gpr->t4);   // x29 (临时寄存器 4)
ffffffffc02009f2:	746c                	ld	a1,232(s0)
ffffffffc02009f4:	00002517          	auipc	a0,0x2
ffffffffc02009f8:	d3450513          	addi	a0,a0,-716 # ffffffffc0202728 <commands+0x490>
ffffffffc02009fc:	ee4ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   t5       0x%08x\n", gpr->t5);   // x30 (临时寄存器 5)
ffffffffc0200a00:	786c                	ld	a1,240(s0)
ffffffffc0200a02:	00002517          	auipc	a0,0x2
ffffffffc0200a06:	d3e50513          	addi	a0,a0,-706 # ffffffffc0202740 <commands+0x4a8>
ffffffffc0200a0a:	ed6ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   t6       0x%08x\n", gpr->t6);   // x31 (临时寄存器 6)
ffffffffc0200a0e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200a10:	6402                	ld	s0,0(sp)
ffffffffc0200a12:	60a2                	ld	ra,8(sp)
    cprintf("   t6       0x%08x\n", gpr->t6);   // x31 (临时寄存器 6)
ffffffffc0200a14:	00002517          	auipc	a0,0x2
ffffffffc0200a18:	d4450513          	addi	a0,a0,-700 # ffffffffc0202758 <commands+0x4c0>
}
ffffffffc0200a1c:	0141                	addi	sp,sp,16
    cprintf("   t6       0x%08x\n", gpr->t6);   // x31 (临时寄存器 6)
ffffffffc0200a1e:	ec2ff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200a22 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a22:	1141                	addi	sp,sp,-16
ffffffffc0200a24:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a26:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a28:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a2a:	00002517          	auipc	a0,0x2
ffffffffc0200a2e:	d4650513          	addi	a0,a0,-698 # ffffffffc0202770 <commands+0x4d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a32:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a34:	eacff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    print_regs(&tf->gpr); // 打印所有通用寄存器
ffffffffc0200a38:	8522                	mv	a0,s0
ffffffffc0200a3a:	e1bff0ef          	jal	ra,ffffffffc0200854 <print_regs>
    cprintf("   status   0x%08x\n", tf->status); // 打印 sstatus 寄存器 (S 模式状态)
ffffffffc0200a3e:	10043583          	ld	a1,256(s0)
ffffffffc0200a42:	00002517          	auipc	a0,0x2
ffffffffc0200a46:	d4650513          	addi	a0,a0,-698 # ffffffffc0202788 <commands+0x4f0>
ffffffffc0200a4a:	e96ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   epc      0x%08x\n", tf->epc);    // 打印 sepc (S 模式异常程序计数器，即发生陷阱的指令地址)
ffffffffc0200a4e:	10843583          	ld	a1,264(s0)
ffffffffc0200a52:	00002517          	auipc	a0,0x2
ffffffffc0200a56:	d4e50513          	addi	a0,a0,-690 # ffffffffc02027a0 <commands+0x508>
ffffffffc0200a5a:	e86ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   badvaddr 0x%08x\n", tf->badvaddr); // 打印 stval (S 模式陷阱值，通常是出错的地址或指令)
ffffffffc0200a5e:	11043583          	ld	a1,272(s0)
ffffffffc0200a62:	00002517          	auipc	a0,0x2
ffffffffc0200a66:	d5650513          	addi	a0,a0,-682 # ffffffffc02027b8 <commands+0x520>
ffffffffc0200a6a:	e76ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("   cause    0x%08x\n", tf->cause);   // 打印 scause (S 模式陷阱原因)
ffffffffc0200a6e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200a72:	6402                	ld	s0,0(sp)
ffffffffc0200a74:	60a2                	ld	ra,8(sp)
    cprintf("   cause    0x%08x\n", tf->cause);   // 打印 scause (S 模式陷阱原因)
ffffffffc0200a76:	00002517          	auipc	a0,0x2
ffffffffc0200a7a:	d5a50513          	addi	a0,a0,-678 # ffffffffc02027d0 <commands+0x538>
}
ffffffffc0200a7e:	0141                	addi	sp,sp,16
    cprintf("   cause    0x%08x\n", tf->cause);   // 打印 scause (S 模式陷阱原因)
ffffffffc0200a80:	e60ff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200a84 <interrupt_handler>:
 * 当 trap_dispatch 确定这是一个中断（而不是异常）时调用此函数
 */
void interrupt_handler(struct trapframe *tf) {
    // scause 寄存器的最高位是中断标志（1=中断, 0=异常）
    // (tf->cause << 1) >> 1 用于清除最高位，得到纯粹的中断原因码
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200a84:	11853783          	ld	a5,280(a0)
ffffffffc0200a88:	472d                	li	a4,11
ffffffffc0200a8a:	0786                	slli	a5,a5,0x1
ffffffffc0200a8c:	8385                	srli	a5,a5,0x1
ffffffffc0200a8e:	08f76363          	bltu	a4,a5,ffffffffc0200b14 <interrupt_handler+0x90>
ffffffffc0200a92:	00002717          	auipc	a4,0x2
ffffffffc0200a96:	e1e70713          	addi	a4,a4,-482 # ffffffffc02028b0 <commands+0x618>
ffffffffc0200a9a:	078a                	slli	a5,a5,0x2
ffffffffc0200a9c:	97ba                	add	a5,a5,a4
ffffffffc0200a9e:	439c                	lw	a5,0(a5)
ffffffffc0200aa0:	97ba                	add	a5,a5,a4
ffffffffc0200aa2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT: // H 模式软件中断
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT: // M 模式软件中断
            cprintf("Machine software interrupt\n");
ffffffffc0200aa4:	00002517          	auipc	a0,0x2
ffffffffc0200aa8:	da450513          	addi	a0,a0,-604 # ffffffffc0202848 <commands+0x5b0>
ffffffffc0200aac:	e34ff06f          	j	ffffffffc02000e0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc0200ab0:	00002517          	auipc	a0,0x2
ffffffffc0200ab4:	d7850513          	addi	a0,a0,-648 # ffffffffc0202828 <commands+0x590>
ffffffffc0200ab8:	e28ff06f          	j	ffffffffc02000e0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200abc:	00002517          	auipc	a0,0x2
ffffffffc0200ac0:	d2c50513          	addi	a0,a0,-724 # ffffffffc02027e8 <commands+0x550>
ffffffffc0200ac4:	e1cff06f          	j	ffffffffc02000e0 <cprintf>
            break;
        case IRQ_U_TIMER: // U 模式时钟中断
            cprintf("User Timer interrupt\n");
ffffffffc0200ac8:	00002517          	auipc	a0,0x2
ffffffffc0200acc:	da050513          	addi	a0,a0,-608 # ffffffffc0202868 <commands+0x5d0>
ffffffffc0200ad0:	e10ff06f          	j	ffffffffc02000e0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200ad4:	1141                	addi	sp,sp,-16
ffffffffc0200ad6:	e406                	sd	ra,8(sp)
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
             * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
             */

            // (1) 设置下次时钟中断 (必须, 否则时钟中断只会触发一次)
            clock_set_next_event();
ffffffffc0200ad8:	991ff0ef          	jal	ra,ffffffffc0200468 <clock_set_next_event>

            // (2) 计数器（ticks）加一 (ticks 在 clock.c 中定义, clock.h 提供了声明)
            ticks++;
ffffffffc0200adc:	00007797          	auipc	a5,0x7
ffffffffc0200ae0:	96c78793          	addi	a5,a5,-1684 # ffffffffc0207448 <ticks>
ffffffffc0200ae4:	6398                	ld	a4,0(a5)
ffffffffc0200ae6:	0705                	addi	a4,a4,1
ffffffffc0200ae8:	e398                	sd	a4,0(a5)

            // (3) 检查是否达到 TICK_NUM (100)
            if (ticks % TICK_NUM == 0) {
ffffffffc0200aea:	639c                	ld	a5,0(a5)
ffffffffc0200aec:	06400713          	li	a4,100
ffffffffc0200af0:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200af4:	c38d                	beqz	a5,ffffffffc0200b16 <interrupt_handler+0x92>
            break;
        default: // 未知的中断类型
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200af6:	60a2                	ld	ra,8(sp)
ffffffffc0200af8:	0141                	addi	sp,sp,16
ffffffffc0200afa:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200afc:	00002517          	auipc	a0,0x2
ffffffffc0200b00:	d9450513          	addi	a0,a0,-620 # ffffffffc0202890 <commands+0x5f8>
ffffffffc0200b04:	ddcff06f          	j	ffffffffc02000e0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200b08:	00002517          	auipc	a0,0x2
ffffffffc0200b0c:	d0050513          	addi	a0,a0,-768 # ffffffffc0202808 <commands+0x570>
ffffffffc0200b10:	dd0ff06f          	j	ffffffffc02000e0 <cprintf>
            print_trapframe(tf);
ffffffffc0200b14:	b739                	j	ffffffffc0200a22 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200b16:	06400593          	li	a1,100
ffffffffc0200b1a:	00002517          	auipc	a0,0x2
ffffffffc0200b1e:	d6650513          	addi	a0,a0,-666 # ffffffffc0202880 <commands+0x5e8>
ffffffffc0200b22:	dbeff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
                print_num++;
ffffffffc0200b26:	00007717          	auipc	a4,0x7
ffffffffc0200b2a:	93a70713          	addi	a4,a4,-1734 # ffffffffc0207460 <print_num>
ffffffffc0200b2e:	431c                	lw	a5,0(a4)
                if (print_num == 10) {
ffffffffc0200b30:	46a9                	li	a3,10
                print_num++;
ffffffffc0200b32:	0017861b          	addiw	a2,a5,1
ffffffffc0200b36:	c310                	sw	a2,0(a4)
                if (print_num == 10) {
ffffffffc0200b38:	fad61fe3          	bne	a2,a3,ffffffffc0200af6 <interrupt_handler+0x72>
}
ffffffffc0200b3c:	60a2                	ld	ra,8(sp)
ffffffffc0200b3e:	0141                	addi	sp,sp,16
                    sbi_shutdown();
ffffffffc0200b40:	4400106f          	j	ffffffffc0201f80 <sbi_shutdown>

ffffffffc0200b44 <exception_handler>:

/*
 * exception_handler - 异常处理函数
 * 当 trap_dispatch 确定这是一个异常（而不是中断）时调用此函数
 */
void exception_handler(struct trapframe *tf) {
ffffffffc0200b44:	1101                	addi	sp,sp,-32
ffffffffc0200b46:	e822                	sd	s0,16(sp)
    switch (tf->cause) {
ffffffffc0200b48:	11853403          	ld	s0,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200b4c:	e426                	sd	s1,8(sp)
ffffffffc0200b4e:	e04a                	sd	s2,0(sp)
ffffffffc0200b50:	ec06                	sd	ra,24(sp)
    switch (tf->cause) {
ffffffffc0200b52:	490d                	li	s2,3
void exception_handler(struct trapframe *tf) {
ffffffffc0200b54:	84aa                	mv	s1,a0
    switch (tf->cause) {
ffffffffc0200b56:	05240f63          	beq	s0,s2,ffffffffc0200bb4 <exception_handler+0x70>
ffffffffc0200b5a:	04896363          	bltu	s2,s0,ffffffffc0200ba0 <exception_handler+0x5c>
ffffffffc0200b5e:	4789                	li	a5,2
ffffffffc0200b60:	02f41a63          	bne	s0,a5,ffffffffc0200b94 <exception_handler+0x50>
            /* LAB3 CHALLENGE3   YOUR CODE :  2313547*/
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
             */
            cprintf("Exception type: Illegal instruction\n");
ffffffffc0200b64:	00002517          	auipc	a0,0x2
ffffffffc0200b68:	d7c50513          	addi	a0,a0,-644 # ffffffffc02028e0 <commands+0x648>
ffffffffc0200b6c:	d74ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc); // 打印发生异常的地址
ffffffffc0200b70:	1084b583          	ld	a1,264(s1)
ffffffffc0200b74:	00002517          	auipc	a0,0x2
ffffffffc0200b78:	d9450513          	addi	a0,a0,-620 # ffffffffc0202908 <commands+0x670>
ffffffffc0200b7c:	d64ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
            // 更新 tf->epc，使其指向下一条指令
            // 这样 sret 返回时就不会再次执行这条非法指令，避免了死循环
            // rv_next_step 会自动判断指令是 2 字节还是 4 字节长
            tf->epc += rv_next_step(tf->epc);
ffffffffc0200b80:	1084b783          	ld	a5,264(s1)
    return ((half & 0x3) != 0x3) ? 2 : 4;
ffffffffc0200b84:	0007d703          	lhu	a4,0(a5)
ffffffffc0200b88:	8b0d                	andi	a4,a4,3
ffffffffc0200b8a:	07270663          	beq	a4,s2,ffffffffc0200bf6 <exception_handler+0xb2>
            tf->epc += rv_next_step(tf->epc);
ffffffffc0200b8e:	97a2                	add	a5,a5,s0
ffffffffc0200b90:	10f4b423          	sd	a5,264(s1)
            break;
        default: // 未知的异常类型
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200b94:	60e2                	ld	ra,24(sp)
ffffffffc0200b96:	6442                	ld	s0,16(sp)
ffffffffc0200b98:	64a2                	ld	s1,8(sp)
ffffffffc0200b9a:	6902                	ld	s2,0(sp)
ffffffffc0200b9c:	6105                	addi	sp,sp,32
ffffffffc0200b9e:	8082                	ret
    switch (tf->cause) {
ffffffffc0200ba0:	1471                	addi	s0,s0,-4
ffffffffc0200ba2:	479d                	li	a5,7
ffffffffc0200ba4:	fe87f8e3          	bgeu	a5,s0,ffffffffc0200b94 <exception_handler+0x50>
}
ffffffffc0200ba8:	6442                	ld	s0,16(sp)
ffffffffc0200baa:	60e2                	ld	ra,24(sp)
ffffffffc0200bac:	64a2                	ld	s1,8(sp)
ffffffffc0200bae:	6902                	ld	s2,0(sp)
ffffffffc0200bb0:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200bb2:	bd85                	j	ffffffffc0200a22 <print_trapframe>
            cprintf("Exception type: breakpoint\n");
ffffffffc0200bb4:	00002517          	auipc	a0,0x2
ffffffffc0200bb8:	d7c50513          	addi	a0,a0,-644 # ffffffffc0202930 <commands+0x698>
ffffffffc0200bbc:	d24ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc); // 打印 ebreak 指令的地址
ffffffffc0200bc0:	1084b583          	ld	a1,264(s1)
ffffffffc0200bc4:	00002517          	auipc	a0,0x2
ffffffffc0200bc8:	d8c50513          	addi	a0,a0,-628 # ffffffffc0202950 <commands+0x6b8>
ffffffffc0200bcc:	d14ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
            tf->epc += rv_next_step(tf->epc);
ffffffffc0200bd0:	1084b783          	ld	a5,264(s1)
    return ((half & 0x3) != 0x3) ? 2 : 4;
ffffffffc0200bd4:	4689                	li	a3,2
ffffffffc0200bd6:	0007d703          	lhu	a4,0(a5)
ffffffffc0200bda:	8b0d                	andi	a4,a4,3
ffffffffc0200bdc:	00870b63          	beq	a4,s0,ffffffffc0200bf2 <exception_handler+0xae>
}
ffffffffc0200be0:	60e2                	ld	ra,24(sp)
ffffffffc0200be2:	6442                	ld	s0,16(sp)
            tf->epc += rv_next_step(tf->epc);
ffffffffc0200be4:	97b6                	add	a5,a5,a3
ffffffffc0200be6:	10f4b423          	sd	a5,264(s1)
}
ffffffffc0200bea:	6902                	ld	s2,0(sp)
ffffffffc0200bec:	64a2                	ld	s1,8(sp)
ffffffffc0200bee:	6105                	addi	sp,sp,32
ffffffffc0200bf0:	8082                	ret
    return ((half & 0x3) != 0x3) ? 2 : 4;
ffffffffc0200bf2:	4691                	li	a3,4
ffffffffc0200bf4:	b7f5                	j	ffffffffc0200be0 <exception_handler+0x9c>
ffffffffc0200bf6:	4411                	li	s0,4
ffffffffc0200bf8:	bf59                	j	ffffffffc0200b8e <exception_handler+0x4a>

ffffffffc0200bfa <trap>:
 * 这是 C 语言中处理陷阱的第二级入口
 */
static inline void trap_dispatch(struct trapframe *tf) {
    // 检查 scause 寄存器的最高位（中断位）
    // (intptr_t)tf->cause < 0 表示最高位为 1，即这是一个中断
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200bfa:	11853783          	ld	a5,280(a0)
ffffffffc0200bfe:	0007c363          	bltz	a5,ffffffffc0200c04 <trap+0xa>
        // interrupts
        interrupt_handler(tf); // 转到中断处理器
    } else {
        // exceptions
        exception_handler(tf); // 转到异常处理器
ffffffffc0200c02:	b789                	j	ffffffffc0200b44 <exception_handler>
        interrupt_handler(tf); // 转到中断处理器
ffffffffc0200c04:	b541                	j	ffffffffc0200a84 <interrupt_handler>

ffffffffc0200c06 <test_breakpoint>:
/*
 * test_breakpoint - 用于测试断点异常 (Challenge 3)
 * __attribute__((noinline)) 确保编译器不会将此函数内联，
 * 从而保证 ebreak 指令在一个独立的函数栈帧中执行。
 */
__attribute__((noinline)) void test_breakpoint(void) {
ffffffffc0200c06:	1141                	addi	sp,sp,-16
    cprintf("\n=== [TEST] breakpoint begin ===\n");
ffffffffc0200c08:	00002517          	auipc	a0,0x2
ffffffffc0200c0c:	d6850513          	addi	a0,a0,-664 # ffffffffc0202970 <commands+0x6d8>
__attribute__((noinline)) void test_breakpoint(void) {
ffffffffc0200c10:	e406                	sd	ra,8(sp)
    cprintf("\n=== [TEST] breakpoint begin ===\n");
ffffffffc0200c12:	cceff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    // 嵌入汇编，执行 ebreak 指令，这将立即触发一个断点异常
    asm volatile("ebreak");
ffffffffc0200c16:	9002                	ebreak
    // 如果 exception_handler 正确处理了异常并更新了 epc,
    // sret 后将返回到这里继续执行。
    cprintf("[TEST] breakpoint returned\n");
}
ffffffffc0200c18:	60a2                	ld	ra,8(sp)
    cprintf("[TEST] breakpoint returned\n");
ffffffffc0200c1a:	00002517          	auipc	a0,0x2
ffffffffc0200c1e:	d7e50513          	addi	a0,a0,-642 # ffffffffc0202998 <commands+0x700>
}
ffffffffc0200c22:	0141                	addi	sp,sp,16
    cprintf("[TEST] breakpoint returned\n");
ffffffffc0200c24:	cbcff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200c28 <test_illegal>:

/*
 * test_illegal - 用于测试非法指令异常 (Challenge 3)
 */
__attribute__((noinline)) void test_illegal(void) {
ffffffffc0200c28:	1141                	addi	sp,sp,-16
    cprintf("\n=== [TEST] illegal begin (32-bit) ===\n");
ffffffffc0200c2a:	00002517          	auipc	a0,0x2
ffffffffc0200c2e:	d8e50513          	addi	a0,a0,-626 # ffffffffc02029b8 <commands+0x720>
__attribute__((noinline)) void test_illegal(void) {
ffffffffc0200c32:	e406                	sd	ra,8(sp)
    cprintf("\n=== [TEST] illegal begin (32-bit) ===\n");
ffffffffc0200c34:	cacff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0200c38:	ffff                	0xffff
ffffffffc0200c3a:	ffff                	0xffff
    // .word 0xFFFFFFFF 插入一个 32 位的字，
    // 0xFFFFFFFF 在 RISC-V 中是一个保证非法的指令编码
    asm volatile(".align 2\n\t"
                 ".word 0xFFFFFFFF\n\t");
    // sret 后将返回到这里
    cprintf("[TEST] illegal 32-bit returned\n");
ffffffffc0200c3c:	00002517          	auipc	a0,0x2
ffffffffc0200c40:	da450513          	addi	a0,a0,-604 # ffffffffc02029e0 <commands+0x748>
ffffffffc0200c44:	c9cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>

    cprintf("\n=== [TEST] illegal begin (16-bit) ===\n");
ffffffffc0200c48:	00002517          	auipc	a0,0x2
ffffffffc0200c4c:	db850513          	addi	a0,a0,-584 # ffffffffc0202a00 <commands+0x768>
ffffffffc0200c50:	c90ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0200c54:	0000                	unimp
    // .2byte 0x0000 插入一个 16 位的字，
    // 0x0000 (C.ILLEGAL) 是 RVC 中的非法指令编码
    asm volatile(".2byte 0x0000\n\t");
    // sret 后将返回到这里
    cprintf("[TEST] illegal 16-bit returned\n");
}
ffffffffc0200c56:	60a2                	ld	ra,8(sp)
    cprintf("[TEST] illegal 16-bit returned\n");
ffffffffc0200c58:	00002517          	auipc	a0,0x2
ffffffffc0200c5c:	dd050513          	addi	a0,a0,-560 # ffffffffc0202a28 <commands+0x790>
}
ffffffffc0200c60:	0141                	addi	sp,sp,16
    cprintf("[TEST] illegal 16-bit returned\n");
ffffffffc0200c62:	c7eff06f          	j	ffffffffc02000e0 <cprintf>
	...

ffffffffc0200c68 <__alltraps>:

    #真正的中断入口点
    .globl __alltraps
    .align(2)  #中断入口点 __alltraps必须四字节对齐
__alltraps:
    SAVE_ALL   #保存上下文
ffffffffc0200c68:	14011073          	csrw	sscratch,sp
ffffffffc0200c6c:	712d                	addi	sp,sp,-288
ffffffffc0200c6e:	e002                	sd	zero,0(sp)
ffffffffc0200c70:	e406                	sd	ra,8(sp)
ffffffffc0200c72:	ec0e                	sd	gp,24(sp)
ffffffffc0200c74:	f012                	sd	tp,32(sp)
ffffffffc0200c76:	f416                	sd	t0,40(sp)
ffffffffc0200c78:	f81a                	sd	t1,48(sp)
ffffffffc0200c7a:	fc1e                	sd	t2,56(sp)
ffffffffc0200c7c:	e0a2                	sd	s0,64(sp)
ffffffffc0200c7e:	e4a6                	sd	s1,72(sp)
ffffffffc0200c80:	e8aa                	sd	a0,80(sp)
ffffffffc0200c82:	ecae                	sd	a1,88(sp)
ffffffffc0200c84:	f0b2                	sd	a2,96(sp)
ffffffffc0200c86:	f4b6                	sd	a3,104(sp)
ffffffffc0200c88:	f8ba                	sd	a4,112(sp)
ffffffffc0200c8a:	fcbe                	sd	a5,120(sp)
ffffffffc0200c8c:	e142                	sd	a6,128(sp)
ffffffffc0200c8e:	e546                	sd	a7,136(sp)
ffffffffc0200c90:	e94a                	sd	s2,144(sp)
ffffffffc0200c92:	ed4e                	sd	s3,152(sp)
ffffffffc0200c94:	f152                	sd	s4,160(sp)
ffffffffc0200c96:	f556                	sd	s5,168(sp)
ffffffffc0200c98:	f95a                	sd	s6,176(sp)
ffffffffc0200c9a:	fd5e                	sd	s7,184(sp)
ffffffffc0200c9c:	e1e2                	sd	s8,192(sp)
ffffffffc0200c9e:	e5e6                	sd	s9,200(sp)
ffffffffc0200ca0:	e9ea                	sd	s10,208(sp)
ffffffffc0200ca2:	edee                	sd	s11,216(sp)
ffffffffc0200ca4:	f1f2                	sd	t3,224(sp)
ffffffffc0200ca6:	f5f6                	sd	t4,232(sp)
ffffffffc0200ca8:	f9fa                	sd	t5,240(sp)
ffffffffc0200caa:	fdfe                	sd	t6,248(sp)
ffffffffc0200cac:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cb0:	100024f3          	csrr	s1,sstatus
ffffffffc0200cb4:	14102973          	csrr	s2,sepc
ffffffffc0200cb8:	143029f3          	csrr	s3,stval
ffffffffc0200cbc:	14202a73          	csrr	s4,scause
ffffffffc0200cc0:	e822                	sd	s0,16(sp)
ffffffffc0200cc2:	e226                	sd	s1,256(sp)
ffffffffc0200cc4:	e64a                	sd	s2,264(sp)
ffffffffc0200cc6:	ea4e                	sd	s3,272(sp)
ffffffffc0200cc8:	ee52                	sd	s4,280(sp)

    move  a0, sp  #传递参数:指向刚刚在栈上保存好的 trapframe 的指针
ffffffffc0200cca:	850a                	mv	a0,sp
    #按照RISCV calling convention, a0寄存器传递参数给接下来调用的函数trap。
    #trap是trap.c里面的一个C语言函数，也就是我们的中断处理程序
    jal trap
ffffffffc0200ccc:	f2fff0ef          	jal	ra,ffffffffc0200bfa <trap>

ffffffffc0200cd0 <__trapret>:
    # sp should be the same as before "jal trap"
    #trap函数指向完之后，会回到这里向下继续执行__trapret里面的内容，RESTORE_ALL,sret

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200cd0:	6492                	ld	s1,256(sp)
ffffffffc0200cd2:	6932                	ld	s2,264(sp)
ffffffffc0200cd4:	10049073          	csrw	sstatus,s1
ffffffffc0200cd8:	14191073          	csrw	sepc,s2
ffffffffc0200cdc:	60a2                	ld	ra,8(sp)
ffffffffc0200cde:	61e2                	ld	gp,24(sp)
ffffffffc0200ce0:	7202                	ld	tp,32(sp)
ffffffffc0200ce2:	72a2                	ld	t0,40(sp)
ffffffffc0200ce4:	7342                	ld	t1,48(sp)
ffffffffc0200ce6:	73e2                	ld	t2,56(sp)
ffffffffc0200ce8:	6406                	ld	s0,64(sp)
ffffffffc0200cea:	64a6                	ld	s1,72(sp)
ffffffffc0200cec:	6546                	ld	a0,80(sp)
ffffffffc0200cee:	65e6                	ld	a1,88(sp)
ffffffffc0200cf0:	7606                	ld	a2,96(sp)
ffffffffc0200cf2:	76a6                	ld	a3,104(sp)
ffffffffc0200cf4:	7746                	ld	a4,112(sp)
ffffffffc0200cf6:	77e6                	ld	a5,120(sp)
ffffffffc0200cf8:	680a                	ld	a6,128(sp)
ffffffffc0200cfa:	68aa                	ld	a7,136(sp)
ffffffffc0200cfc:	694a                	ld	s2,144(sp)
ffffffffc0200cfe:	69ea                	ld	s3,152(sp)
ffffffffc0200d00:	7a0a                	ld	s4,160(sp)
ffffffffc0200d02:	7aaa                	ld	s5,168(sp)
ffffffffc0200d04:	7b4a                	ld	s6,176(sp)
ffffffffc0200d06:	7bea                	ld	s7,184(sp)
ffffffffc0200d08:	6c0e                	ld	s8,192(sp)
ffffffffc0200d0a:	6cae                	ld	s9,200(sp)
ffffffffc0200d0c:	6d4e                	ld	s10,208(sp)
ffffffffc0200d0e:	6dee                	ld	s11,216(sp)
ffffffffc0200d10:	7e0e                	ld	t3,224(sp)
ffffffffc0200d12:	7eae                	ld	t4,232(sp)
ffffffffc0200d14:	7f4e                	ld	t5,240(sp)
ffffffffc0200d16:	7fee                	ld	t6,248(sp)
ffffffffc0200d18:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d1a:	10200073          	sret

ffffffffc0200d1e <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200d1e:	00006797          	auipc	a5,0x6
ffffffffc0200d22:	30a78793          	addi	a5,a5,778 # ffffffffc0207028 <free_area>
ffffffffc0200d26:	e79c                	sd	a5,8(a5)
ffffffffc0200d28:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200d2a:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200d2e:	8082                	ret

ffffffffc0200d30 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200d30:	00006517          	auipc	a0,0x6
ffffffffc0200d34:	30856503          	lwu	a0,776(a0) # ffffffffc0207038 <free_area+0x10>
ffffffffc0200d38:	8082                	ret

ffffffffc0200d3a <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200d3a:	715d                	addi	sp,sp,-80
ffffffffc0200d3c:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200d3e:	00006417          	auipc	s0,0x6
ffffffffc0200d42:	2ea40413          	addi	s0,s0,746 # ffffffffc0207028 <free_area>
ffffffffc0200d46:	641c                	ld	a5,8(s0)
ffffffffc0200d48:	e486                	sd	ra,72(sp)
ffffffffc0200d4a:	fc26                	sd	s1,56(sp)
ffffffffc0200d4c:	f84a                	sd	s2,48(sp)
ffffffffc0200d4e:	f44e                	sd	s3,40(sp)
ffffffffc0200d50:	f052                	sd	s4,32(sp)
ffffffffc0200d52:	ec56                	sd	s5,24(sp)
ffffffffc0200d54:	e85a                	sd	s6,16(sp)
ffffffffc0200d56:	e45e                	sd	s7,8(sp)
ffffffffc0200d58:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d5a:	2c878763          	beq	a5,s0,ffffffffc0201028 <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200d5e:	4481                	li	s1,0
ffffffffc0200d60:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200d62:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200d66:	8b09                	andi	a4,a4,2
ffffffffc0200d68:	2c070463          	beqz	a4,ffffffffc0201030 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200d6c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200d70:	679c                	ld	a5,8(a5)
ffffffffc0200d72:	2905                	addiw	s2,s2,1
ffffffffc0200d74:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d76:	fe8796e3          	bne	a5,s0,ffffffffc0200d62 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200d7a:	89a6                	mv	s3,s1
ffffffffc0200d7c:	2f9000ef          	jal	ra,ffffffffc0201874 <nr_free_pages>
ffffffffc0200d80:	71351863          	bne	a0,s3,ffffffffc0201490 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d84:	4505                	li	a0,1
ffffffffc0200d86:	271000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200d8a:	8a2a                	mv	s4,a0
ffffffffc0200d8c:	44050263          	beqz	a0,ffffffffc02011d0 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d90:	4505                	li	a0,1
ffffffffc0200d92:	265000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200d96:	89aa                	mv	s3,a0
ffffffffc0200d98:	70050c63          	beqz	a0,ffffffffc02014b0 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d9c:	4505                	li	a0,1
ffffffffc0200d9e:	259000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200da2:	8aaa                	mv	s5,a0
ffffffffc0200da4:	4a050663          	beqz	a0,ffffffffc0201250 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200da8:	2b3a0463          	beq	s4,s3,ffffffffc0201050 <default_check+0x316>
ffffffffc0200dac:	2aaa0263          	beq	s4,a0,ffffffffc0201050 <default_check+0x316>
ffffffffc0200db0:	2aa98063          	beq	s3,a0,ffffffffc0201050 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200db4:	000a2783          	lw	a5,0(s4)
ffffffffc0200db8:	2a079c63          	bnez	a5,ffffffffc0201070 <default_check+0x336>
ffffffffc0200dbc:	0009a783          	lw	a5,0(s3)
ffffffffc0200dc0:	2a079863          	bnez	a5,ffffffffc0201070 <default_check+0x336>
ffffffffc0200dc4:	411c                	lw	a5,0(a0)
ffffffffc0200dc6:	2a079563          	bnez	a5,ffffffffc0201070 <default_check+0x336>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200dca:	00006797          	auipc	a5,0x6
ffffffffc0200dce:	6a67b783          	ld	a5,1702(a5) # ffffffffc0207470 <pages>
ffffffffc0200dd2:	40fa0733          	sub	a4,s4,a5
ffffffffc0200dd6:	870d                	srai	a4,a4,0x3
ffffffffc0200dd8:	00002597          	auipc	a1,0x2
ffffffffc0200ddc:	3f85b583          	ld	a1,1016(a1) # ffffffffc02031d0 <error_string+0x38>
ffffffffc0200de0:	02b70733          	mul	a4,a4,a1
ffffffffc0200de4:	00002617          	auipc	a2,0x2
ffffffffc0200de8:	3f463603          	ld	a2,1012(a2) # ffffffffc02031d8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200dec:	00006697          	auipc	a3,0x6
ffffffffc0200df0:	67c6b683          	ld	a3,1660(a3) # ffffffffc0207468 <npage>
ffffffffc0200df4:	06b2                	slli	a3,a3,0xc
ffffffffc0200df6:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200df8:	0732                	slli	a4,a4,0xc
ffffffffc0200dfa:	28d77b63          	bgeu	a4,a3,ffffffffc0201090 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200dfe:	40f98733          	sub	a4,s3,a5
ffffffffc0200e02:	870d                	srai	a4,a4,0x3
ffffffffc0200e04:	02b70733          	mul	a4,a4,a1
ffffffffc0200e08:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e0a:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e0c:	4cd77263          	bgeu	a4,a3,ffffffffc02012d0 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e10:	40f507b3          	sub	a5,a0,a5
ffffffffc0200e14:	878d                	srai	a5,a5,0x3
ffffffffc0200e16:	02b787b3          	mul	a5,a5,a1
ffffffffc0200e1a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e1c:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e1e:	30d7f963          	bgeu	a5,a3,ffffffffc0201130 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200e22:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200e24:	00043c03          	ld	s8,0(s0)
ffffffffc0200e28:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200e2c:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200e30:	e400                	sd	s0,8(s0)
ffffffffc0200e32:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200e34:	00006797          	auipc	a5,0x6
ffffffffc0200e38:	2007a223          	sw	zero,516(a5) # ffffffffc0207038 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200e3c:	1bb000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200e40:	2c051863          	bnez	a0,ffffffffc0201110 <default_check+0x3d6>
    free_page(p0);
ffffffffc0200e44:	4585                	li	a1,1
ffffffffc0200e46:	8552                	mv	a0,s4
ffffffffc0200e48:	1ed000ef          	jal	ra,ffffffffc0201834 <free_pages>
    free_page(p1);
ffffffffc0200e4c:	4585                	li	a1,1
ffffffffc0200e4e:	854e                	mv	a0,s3
ffffffffc0200e50:	1e5000ef          	jal	ra,ffffffffc0201834 <free_pages>
    free_page(p2);
ffffffffc0200e54:	4585                	li	a1,1
ffffffffc0200e56:	8556                	mv	a0,s5
ffffffffc0200e58:	1dd000ef          	jal	ra,ffffffffc0201834 <free_pages>
    assert(nr_free == 3);
ffffffffc0200e5c:	4818                	lw	a4,16(s0)
ffffffffc0200e5e:	478d                	li	a5,3
ffffffffc0200e60:	28f71863          	bne	a4,a5,ffffffffc02010f0 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e64:	4505                	li	a0,1
ffffffffc0200e66:	191000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200e6a:	89aa                	mv	s3,a0
ffffffffc0200e6c:	26050263          	beqz	a0,ffffffffc02010d0 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e70:	4505                	li	a0,1
ffffffffc0200e72:	185000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200e76:	8aaa                	mv	s5,a0
ffffffffc0200e78:	3a050c63          	beqz	a0,ffffffffc0201230 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e7c:	4505                	li	a0,1
ffffffffc0200e7e:	179000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200e82:	8a2a                	mv	s4,a0
ffffffffc0200e84:	38050663          	beqz	a0,ffffffffc0201210 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200e88:	4505                	li	a0,1
ffffffffc0200e8a:	16d000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200e8e:	36051163          	bnez	a0,ffffffffc02011f0 <default_check+0x4b6>
    free_page(p0);
ffffffffc0200e92:	4585                	li	a1,1
ffffffffc0200e94:	854e                	mv	a0,s3
ffffffffc0200e96:	19f000ef          	jal	ra,ffffffffc0201834 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200e9a:	641c                	ld	a5,8(s0)
ffffffffc0200e9c:	20878a63          	beq	a5,s0,ffffffffc02010b0 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200ea0:	4505                	li	a0,1
ffffffffc0200ea2:	155000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200ea6:	30a99563          	bne	s3,a0,ffffffffc02011b0 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200eaa:	4505                	li	a0,1
ffffffffc0200eac:	14b000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200eb0:	2e051063          	bnez	a0,ffffffffc0201190 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200eb4:	481c                	lw	a5,16(s0)
ffffffffc0200eb6:	2a079d63          	bnez	a5,ffffffffc0201170 <default_check+0x436>
    free_page(p);
ffffffffc0200eba:	854e                	mv	a0,s3
ffffffffc0200ebc:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200ebe:	01843023          	sd	s8,0(s0)
ffffffffc0200ec2:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200ec6:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200eca:	16b000ef          	jal	ra,ffffffffc0201834 <free_pages>
    free_page(p1);
ffffffffc0200ece:	4585                	li	a1,1
ffffffffc0200ed0:	8556                	mv	a0,s5
ffffffffc0200ed2:	163000ef          	jal	ra,ffffffffc0201834 <free_pages>
    free_page(p2);
ffffffffc0200ed6:	4585                	li	a1,1
ffffffffc0200ed8:	8552                	mv	a0,s4
ffffffffc0200eda:	15b000ef          	jal	ra,ffffffffc0201834 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200ede:	4515                	li	a0,5
ffffffffc0200ee0:	117000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200ee4:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200ee6:	26050563          	beqz	a0,ffffffffc0201150 <default_check+0x416>
ffffffffc0200eea:	651c                	ld	a5,8(a0)
ffffffffc0200eec:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200eee:	8b85                	andi	a5,a5,1
ffffffffc0200ef0:	54079063          	bnez	a5,ffffffffc0201430 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200ef4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ef6:	00043b03          	ld	s6,0(s0)
ffffffffc0200efa:	00843a83          	ld	s5,8(s0)
ffffffffc0200efe:	e000                	sd	s0,0(s0)
ffffffffc0200f00:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200f02:	0f5000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200f06:	50051563          	bnez	a0,ffffffffc0201410 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200f0a:	05098a13          	addi	s4,s3,80
ffffffffc0200f0e:	8552                	mv	a0,s4
ffffffffc0200f10:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200f12:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200f16:	00006797          	auipc	a5,0x6
ffffffffc0200f1a:	1207a123          	sw	zero,290(a5) # ffffffffc0207038 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200f1e:	117000ef          	jal	ra,ffffffffc0201834 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f22:	4511                	li	a0,4
ffffffffc0200f24:	0d3000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200f28:	4c051463          	bnez	a0,ffffffffc02013f0 <default_check+0x6b6>
ffffffffc0200f2c:	0589b783          	ld	a5,88(s3)
ffffffffc0200f30:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200f32:	8b85                	andi	a5,a5,1
ffffffffc0200f34:	48078e63          	beqz	a5,ffffffffc02013d0 <default_check+0x696>
ffffffffc0200f38:	0609a703          	lw	a4,96(s3)
ffffffffc0200f3c:	478d                	li	a5,3
ffffffffc0200f3e:	48f71963          	bne	a4,a5,ffffffffc02013d0 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200f42:	450d                	li	a0,3
ffffffffc0200f44:	0b3000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200f48:	8c2a                	mv	s8,a0
ffffffffc0200f4a:	46050363          	beqz	a0,ffffffffc02013b0 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200f4e:	4505                	li	a0,1
ffffffffc0200f50:	0a7000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200f54:	42051e63          	bnez	a0,ffffffffc0201390 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200f58:	418a1c63          	bne	s4,s8,ffffffffc0201370 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200f5c:	4585                	li	a1,1
ffffffffc0200f5e:	854e                	mv	a0,s3
ffffffffc0200f60:	0d5000ef          	jal	ra,ffffffffc0201834 <free_pages>
    free_pages(p1, 3);
ffffffffc0200f64:	458d                	li	a1,3
ffffffffc0200f66:	8552                	mv	a0,s4
ffffffffc0200f68:	0cd000ef          	jal	ra,ffffffffc0201834 <free_pages>
ffffffffc0200f6c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200f70:	02898c13          	addi	s8,s3,40
ffffffffc0200f74:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200f76:	8b85                	andi	a5,a5,1
ffffffffc0200f78:	3c078c63          	beqz	a5,ffffffffc0201350 <default_check+0x616>
ffffffffc0200f7c:	0109a703          	lw	a4,16(s3)
ffffffffc0200f80:	4785                	li	a5,1
ffffffffc0200f82:	3cf71763          	bne	a4,a5,ffffffffc0201350 <default_check+0x616>
ffffffffc0200f86:	008a3783          	ld	a5,8(s4)
ffffffffc0200f8a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200f8c:	8b85                	andi	a5,a5,1
ffffffffc0200f8e:	3a078163          	beqz	a5,ffffffffc0201330 <default_check+0x5f6>
ffffffffc0200f92:	010a2703          	lw	a4,16(s4)
ffffffffc0200f96:	478d                	li	a5,3
ffffffffc0200f98:	38f71c63          	bne	a4,a5,ffffffffc0201330 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200f9c:	4505                	li	a0,1
ffffffffc0200f9e:	059000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200fa2:	36a99763          	bne	s3,a0,ffffffffc0201310 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200fa6:	4585                	li	a1,1
ffffffffc0200fa8:	08d000ef          	jal	ra,ffffffffc0201834 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200fac:	4509                	li	a0,2
ffffffffc0200fae:	049000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200fb2:	32aa1f63          	bne	s4,a0,ffffffffc02012f0 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200fb6:	4589                	li	a1,2
ffffffffc0200fb8:	07d000ef          	jal	ra,ffffffffc0201834 <free_pages>
    free_page(p2);
ffffffffc0200fbc:	4585                	li	a1,1
ffffffffc0200fbe:	8562                	mv	a0,s8
ffffffffc0200fc0:	075000ef          	jal	ra,ffffffffc0201834 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200fc4:	4515                	li	a0,5
ffffffffc0200fc6:	031000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200fca:	89aa                	mv	s3,a0
ffffffffc0200fcc:	48050263          	beqz	a0,ffffffffc0201450 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200fd0:	4505                	li	a0,1
ffffffffc0200fd2:	025000ef          	jal	ra,ffffffffc02017f6 <alloc_pages>
ffffffffc0200fd6:	2c051d63          	bnez	a0,ffffffffc02012b0 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200fda:	481c                	lw	a5,16(s0)
ffffffffc0200fdc:	2a079a63          	bnez	a5,ffffffffc0201290 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200fe0:	4595                	li	a1,5
ffffffffc0200fe2:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200fe4:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200fe8:	01643023          	sd	s6,0(s0)
ffffffffc0200fec:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200ff0:	045000ef          	jal	ra,ffffffffc0201834 <free_pages>
    return listelm->next;
ffffffffc0200ff4:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ff6:	00878963          	beq	a5,s0,ffffffffc0201008 <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200ffa:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ffe:	679c                	ld	a5,8(a5)
ffffffffc0201000:	397d                	addiw	s2,s2,-1
ffffffffc0201002:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201004:	fe879be3          	bne	a5,s0,ffffffffc0200ffa <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0201008:	26091463          	bnez	s2,ffffffffc0201270 <default_check+0x536>
    assert(total == 0);
ffffffffc020100c:	46049263          	bnez	s1,ffffffffc0201470 <default_check+0x736>
}
ffffffffc0201010:	60a6                	ld	ra,72(sp)
ffffffffc0201012:	6406                	ld	s0,64(sp)
ffffffffc0201014:	74e2                	ld	s1,56(sp)
ffffffffc0201016:	7942                	ld	s2,48(sp)
ffffffffc0201018:	79a2                	ld	s3,40(sp)
ffffffffc020101a:	7a02                	ld	s4,32(sp)
ffffffffc020101c:	6ae2                	ld	s5,24(sp)
ffffffffc020101e:	6b42                	ld	s6,16(sp)
ffffffffc0201020:	6ba2                	ld	s7,8(sp)
ffffffffc0201022:	6c02                	ld	s8,0(sp)
ffffffffc0201024:	6161                	addi	sp,sp,80
ffffffffc0201026:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201028:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020102a:	4481                	li	s1,0
ffffffffc020102c:	4901                	li	s2,0
ffffffffc020102e:	b3b9                	j	ffffffffc0200d7c <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201030:	00002697          	auipc	a3,0x2
ffffffffc0201034:	a1868693          	addi	a3,a3,-1512 # ffffffffc0202a48 <commands+0x7b0>
ffffffffc0201038:	00002617          	auipc	a2,0x2
ffffffffc020103c:	a2060613          	addi	a2,a2,-1504 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201040:	0f000593          	li	a1,240
ffffffffc0201044:	00002517          	auipc	a0,0x2
ffffffffc0201048:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020104c:	b8eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201050:	00002697          	auipc	a3,0x2
ffffffffc0201054:	ab868693          	addi	a3,a3,-1352 # ffffffffc0202b08 <commands+0x870>
ffffffffc0201058:	00002617          	auipc	a2,0x2
ffffffffc020105c:	a0060613          	addi	a2,a2,-1536 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201060:	0bd00593          	li	a1,189
ffffffffc0201064:	00002517          	auipc	a0,0x2
ffffffffc0201068:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020106c:	b6eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201070:	00002697          	auipc	a3,0x2
ffffffffc0201074:	ac068693          	addi	a3,a3,-1344 # ffffffffc0202b30 <commands+0x898>
ffffffffc0201078:	00002617          	auipc	a2,0x2
ffffffffc020107c:	9e060613          	addi	a2,a2,-1568 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201080:	0be00593          	li	a1,190
ffffffffc0201084:	00002517          	auipc	a0,0x2
ffffffffc0201088:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020108c:	b4eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201090:	00002697          	auipc	a3,0x2
ffffffffc0201094:	ae068693          	addi	a3,a3,-1312 # ffffffffc0202b70 <commands+0x8d8>
ffffffffc0201098:	00002617          	auipc	a2,0x2
ffffffffc020109c:	9c060613          	addi	a2,a2,-1600 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02010a0:	0c000593          	li	a1,192
ffffffffc02010a4:	00002517          	auipc	a0,0x2
ffffffffc02010a8:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02010ac:	b2eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(!list_empty(&free_list));
ffffffffc02010b0:	00002697          	auipc	a3,0x2
ffffffffc02010b4:	b4868693          	addi	a3,a3,-1208 # ffffffffc0202bf8 <commands+0x960>
ffffffffc02010b8:	00002617          	auipc	a2,0x2
ffffffffc02010bc:	9a060613          	addi	a2,a2,-1632 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02010c0:	0d900593          	li	a1,217
ffffffffc02010c4:	00002517          	auipc	a0,0x2
ffffffffc02010c8:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02010cc:	b0eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02010d0:	00002697          	auipc	a3,0x2
ffffffffc02010d4:	9d868693          	addi	a3,a3,-1576 # ffffffffc0202aa8 <commands+0x810>
ffffffffc02010d8:	00002617          	auipc	a2,0x2
ffffffffc02010dc:	98060613          	addi	a2,a2,-1664 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02010e0:	0d200593          	li	a1,210
ffffffffc02010e4:	00002517          	auipc	a0,0x2
ffffffffc02010e8:	98c50513          	addi	a0,a0,-1652 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02010ec:	aeeff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(nr_free == 3);
ffffffffc02010f0:	00002697          	auipc	a3,0x2
ffffffffc02010f4:	af868693          	addi	a3,a3,-1288 # ffffffffc0202be8 <commands+0x950>
ffffffffc02010f8:	00002617          	auipc	a2,0x2
ffffffffc02010fc:	96060613          	addi	a2,a2,-1696 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201100:	0d000593          	li	a1,208
ffffffffc0201104:	00002517          	auipc	a0,0x2
ffffffffc0201108:	96c50513          	addi	a0,a0,-1684 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020110c:	aceff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201110:	00002697          	auipc	a3,0x2
ffffffffc0201114:	ac068693          	addi	a3,a3,-1344 # ffffffffc0202bd0 <commands+0x938>
ffffffffc0201118:	00002617          	auipc	a2,0x2
ffffffffc020111c:	94060613          	addi	a2,a2,-1728 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201120:	0cb00593          	li	a1,203
ffffffffc0201124:	00002517          	auipc	a0,0x2
ffffffffc0201128:	94c50513          	addi	a0,a0,-1716 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020112c:	aaeff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201130:	00002697          	auipc	a3,0x2
ffffffffc0201134:	a8068693          	addi	a3,a3,-1408 # ffffffffc0202bb0 <commands+0x918>
ffffffffc0201138:	00002617          	auipc	a2,0x2
ffffffffc020113c:	92060613          	addi	a2,a2,-1760 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201140:	0c200593          	li	a1,194
ffffffffc0201144:	00002517          	auipc	a0,0x2
ffffffffc0201148:	92c50513          	addi	a0,a0,-1748 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020114c:	a8eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(p0 != NULL);
ffffffffc0201150:	00002697          	auipc	a3,0x2
ffffffffc0201154:	af068693          	addi	a3,a3,-1296 # ffffffffc0202c40 <commands+0x9a8>
ffffffffc0201158:	00002617          	auipc	a2,0x2
ffffffffc020115c:	90060613          	addi	a2,a2,-1792 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201160:	0f800593          	li	a1,248
ffffffffc0201164:	00002517          	auipc	a0,0x2
ffffffffc0201168:	90c50513          	addi	a0,a0,-1780 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020116c:	a6eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(nr_free == 0);
ffffffffc0201170:	00002697          	auipc	a3,0x2
ffffffffc0201174:	ac068693          	addi	a3,a3,-1344 # ffffffffc0202c30 <commands+0x998>
ffffffffc0201178:	00002617          	auipc	a2,0x2
ffffffffc020117c:	8e060613          	addi	a2,a2,-1824 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201180:	0df00593          	li	a1,223
ffffffffc0201184:	00002517          	auipc	a0,0x2
ffffffffc0201188:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020118c:	a4eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201190:	00002697          	auipc	a3,0x2
ffffffffc0201194:	a4068693          	addi	a3,a3,-1472 # ffffffffc0202bd0 <commands+0x938>
ffffffffc0201198:	00002617          	auipc	a2,0x2
ffffffffc020119c:	8c060613          	addi	a2,a2,-1856 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02011a0:	0dd00593          	li	a1,221
ffffffffc02011a4:	00002517          	auipc	a0,0x2
ffffffffc02011a8:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02011ac:	a2eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02011b0:	00002697          	auipc	a3,0x2
ffffffffc02011b4:	a6068693          	addi	a3,a3,-1440 # ffffffffc0202c10 <commands+0x978>
ffffffffc02011b8:	00002617          	auipc	a2,0x2
ffffffffc02011bc:	8a060613          	addi	a2,a2,-1888 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02011c0:	0dc00593          	li	a1,220
ffffffffc02011c4:	00002517          	auipc	a0,0x2
ffffffffc02011c8:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02011cc:	a0eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02011d0:	00002697          	auipc	a3,0x2
ffffffffc02011d4:	8d868693          	addi	a3,a3,-1832 # ffffffffc0202aa8 <commands+0x810>
ffffffffc02011d8:	00002617          	auipc	a2,0x2
ffffffffc02011dc:	88060613          	addi	a2,a2,-1920 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02011e0:	0b900593          	li	a1,185
ffffffffc02011e4:	00002517          	auipc	a0,0x2
ffffffffc02011e8:	88c50513          	addi	a0,a0,-1908 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02011ec:	9eeff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011f0:	00002697          	auipc	a3,0x2
ffffffffc02011f4:	9e068693          	addi	a3,a3,-1568 # ffffffffc0202bd0 <commands+0x938>
ffffffffc02011f8:	00002617          	auipc	a2,0x2
ffffffffc02011fc:	86060613          	addi	a2,a2,-1952 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201200:	0d600593          	li	a1,214
ffffffffc0201204:	00002517          	auipc	a0,0x2
ffffffffc0201208:	86c50513          	addi	a0,a0,-1940 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020120c:	9ceff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201210:	00002697          	auipc	a3,0x2
ffffffffc0201214:	8d868693          	addi	a3,a3,-1832 # ffffffffc0202ae8 <commands+0x850>
ffffffffc0201218:	00002617          	auipc	a2,0x2
ffffffffc020121c:	84060613          	addi	a2,a2,-1984 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201220:	0d400593          	li	a1,212
ffffffffc0201224:	00002517          	auipc	a0,0x2
ffffffffc0201228:	84c50513          	addi	a0,a0,-1972 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020122c:	9aeff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201230:	00002697          	auipc	a3,0x2
ffffffffc0201234:	89868693          	addi	a3,a3,-1896 # ffffffffc0202ac8 <commands+0x830>
ffffffffc0201238:	00002617          	auipc	a2,0x2
ffffffffc020123c:	82060613          	addi	a2,a2,-2016 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201240:	0d300593          	li	a1,211
ffffffffc0201244:	00002517          	auipc	a0,0x2
ffffffffc0201248:	82c50513          	addi	a0,a0,-2004 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020124c:	98eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201250:	00002697          	auipc	a3,0x2
ffffffffc0201254:	89868693          	addi	a3,a3,-1896 # ffffffffc0202ae8 <commands+0x850>
ffffffffc0201258:	00002617          	auipc	a2,0x2
ffffffffc020125c:	80060613          	addi	a2,a2,-2048 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201260:	0bb00593          	li	a1,187
ffffffffc0201264:	00002517          	auipc	a0,0x2
ffffffffc0201268:	80c50513          	addi	a0,a0,-2036 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020126c:	96eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(count == 0);
ffffffffc0201270:	00002697          	auipc	a3,0x2
ffffffffc0201274:	b2068693          	addi	a3,a3,-1248 # ffffffffc0202d90 <commands+0xaf8>
ffffffffc0201278:	00001617          	auipc	a2,0x1
ffffffffc020127c:	7e060613          	addi	a2,a2,2016 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201280:	12500593          	li	a1,293
ffffffffc0201284:	00001517          	auipc	a0,0x1
ffffffffc0201288:	7ec50513          	addi	a0,a0,2028 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020128c:	94eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(nr_free == 0);
ffffffffc0201290:	00002697          	auipc	a3,0x2
ffffffffc0201294:	9a068693          	addi	a3,a3,-1632 # ffffffffc0202c30 <commands+0x998>
ffffffffc0201298:	00001617          	auipc	a2,0x1
ffffffffc020129c:	7c060613          	addi	a2,a2,1984 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02012a0:	11a00593          	li	a1,282
ffffffffc02012a4:	00001517          	auipc	a0,0x1
ffffffffc02012a8:	7cc50513          	addi	a0,a0,1996 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02012ac:	92eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012b0:	00002697          	auipc	a3,0x2
ffffffffc02012b4:	92068693          	addi	a3,a3,-1760 # ffffffffc0202bd0 <commands+0x938>
ffffffffc02012b8:	00001617          	auipc	a2,0x1
ffffffffc02012bc:	7a060613          	addi	a2,a2,1952 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02012c0:	11800593          	li	a1,280
ffffffffc02012c4:	00001517          	auipc	a0,0x1
ffffffffc02012c8:	7ac50513          	addi	a0,a0,1964 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02012cc:	90eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02012d0:	00002697          	auipc	a3,0x2
ffffffffc02012d4:	8c068693          	addi	a3,a3,-1856 # ffffffffc0202b90 <commands+0x8f8>
ffffffffc02012d8:	00001617          	auipc	a2,0x1
ffffffffc02012dc:	78060613          	addi	a2,a2,1920 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02012e0:	0c100593          	li	a1,193
ffffffffc02012e4:	00001517          	auipc	a0,0x1
ffffffffc02012e8:	78c50513          	addi	a0,a0,1932 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02012ec:	8eeff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02012f0:	00002697          	auipc	a3,0x2
ffffffffc02012f4:	a6068693          	addi	a3,a3,-1440 # ffffffffc0202d50 <commands+0xab8>
ffffffffc02012f8:	00001617          	auipc	a2,0x1
ffffffffc02012fc:	76060613          	addi	a2,a2,1888 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201300:	11200593          	li	a1,274
ffffffffc0201304:	00001517          	auipc	a0,0x1
ffffffffc0201308:	76c50513          	addi	a0,a0,1900 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020130c:	8ceff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201310:	00002697          	auipc	a3,0x2
ffffffffc0201314:	a2068693          	addi	a3,a3,-1504 # ffffffffc0202d30 <commands+0xa98>
ffffffffc0201318:	00001617          	auipc	a2,0x1
ffffffffc020131c:	74060613          	addi	a2,a2,1856 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201320:	11000593          	li	a1,272
ffffffffc0201324:	00001517          	auipc	a0,0x1
ffffffffc0201328:	74c50513          	addi	a0,a0,1868 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020132c:	8aeff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201330:	00002697          	auipc	a3,0x2
ffffffffc0201334:	9d868693          	addi	a3,a3,-1576 # ffffffffc0202d08 <commands+0xa70>
ffffffffc0201338:	00001617          	auipc	a2,0x1
ffffffffc020133c:	72060613          	addi	a2,a2,1824 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201340:	10e00593          	li	a1,270
ffffffffc0201344:	00001517          	auipc	a0,0x1
ffffffffc0201348:	72c50513          	addi	a0,a0,1836 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020134c:	88eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201350:	00002697          	auipc	a3,0x2
ffffffffc0201354:	99068693          	addi	a3,a3,-1648 # ffffffffc0202ce0 <commands+0xa48>
ffffffffc0201358:	00001617          	auipc	a2,0x1
ffffffffc020135c:	70060613          	addi	a2,a2,1792 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201360:	10d00593          	li	a1,269
ffffffffc0201364:	00001517          	auipc	a0,0x1
ffffffffc0201368:	70c50513          	addi	a0,a0,1804 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020136c:	86eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201370:	00002697          	auipc	a3,0x2
ffffffffc0201374:	96068693          	addi	a3,a3,-1696 # ffffffffc0202cd0 <commands+0xa38>
ffffffffc0201378:	00001617          	auipc	a2,0x1
ffffffffc020137c:	6e060613          	addi	a2,a2,1760 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201380:	10800593          	li	a1,264
ffffffffc0201384:	00001517          	auipc	a0,0x1
ffffffffc0201388:	6ec50513          	addi	a0,a0,1772 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020138c:	84eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201390:	00002697          	auipc	a3,0x2
ffffffffc0201394:	84068693          	addi	a3,a3,-1984 # ffffffffc0202bd0 <commands+0x938>
ffffffffc0201398:	00001617          	auipc	a2,0x1
ffffffffc020139c:	6c060613          	addi	a2,a2,1728 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02013a0:	10700593          	li	a1,263
ffffffffc02013a4:	00001517          	auipc	a0,0x1
ffffffffc02013a8:	6cc50513          	addi	a0,a0,1740 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02013ac:	82eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02013b0:	00002697          	auipc	a3,0x2
ffffffffc02013b4:	90068693          	addi	a3,a3,-1792 # ffffffffc0202cb0 <commands+0xa18>
ffffffffc02013b8:	00001617          	auipc	a2,0x1
ffffffffc02013bc:	6a060613          	addi	a2,a2,1696 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02013c0:	10600593          	li	a1,262
ffffffffc02013c4:	00001517          	auipc	a0,0x1
ffffffffc02013c8:	6ac50513          	addi	a0,a0,1708 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02013cc:	80eff0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02013d0:	00002697          	auipc	a3,0x2
ffffffffc02013d4:	8b068693          	addi	a3,a3,-1872 # ffffffffc0202c80 <commands+0x9e8>
ffffffffc02013d8:	00001617          	auipc	a2,0x1
ffffffffc02013dc:	68060613          	addi	a2,a2,1664 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02013e0:	10500593          	li	a1,261
ffffffffc02013e4:	00001517          	auipc	a0,0x1
ffffffffc02013e8:	68c50513          	addi	a0,a0,1676 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02013ec:	feffe0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02013f0:	00002697          	auipc	a3,0x2
ffffffffc02013f4:	87868693          	addi	a3,a3,-1928 # ffffffffc0202c68 <commands+0x9d0>
ffffffffc02013f8:	00001617          	auipc	a2,0x1
ffffffffc02013fc:	66060613          	addi	a2,a2,1632 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201400:	10400593          	li	a1,260
ffffffffc0201404:	00001517          	auipc	a0,0x1
ffffffffc0201408:	66c50513          	addi	a0,a0,1644 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020140c:	fcffe0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201410:	00001697          	auipc	a3,0x1
ffffffffc0201414:	7c068693          	addi	a3,a3,1984 # ffffffffc0202bd0 <commands+0x938>
ffffffffc0201418:	00001617          	auipc	a2,0x1
ffffffffc020141c:	64060613          	addi	a2,a2,1600 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201420:	0fe00593          	li	a1,254
ffffffffc0201424:	00001517          	auipc	a0,0x1
ffffffffc0201428:	64c50513          	addi	a0,a0,1612 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020142c:	faffe0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(!PageProperty(p0));
ffffffffc0201430:	00002697          	auipc	a3,0x2
ffffffffc0201434:	82068693          	addi	a3,a3,-2016 # ffffffffc0202c50 <commands+0x9b8>
ffffffffc0201438:	00001617          	auipc	a2,0x1
ffffffffc020143c:	62060613          	addi	a2,a2,1568 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201440:	0f900593          	li	a1,249
ffffffffc0201444:	00001517          	auipc	a0,0x1
ffffffffc0201448:	62c50513          	addi	a0,a0,1580 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020144c:	f8ffe0ef          	jal	ra,ffffffffc02003da <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201450:	00002697          	auipc	a3,0x2
ffffffffc0201454:	92068693          	addi	a3,a3,-1760 # ffffffffc0202d70 <commands+0xad8>
ffffffffc0201458:	00001617          	auipc	a2,0x1
ffffffffc020145c:	60060613          	addi	a2,a2,1536 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201460:	11700593          	li	a1,279
ffffffffc0201464:	00001517          	auipc	a0,0x1
ffffffffc0201468:	60c50513          	addi	a0,a0,1548 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020146c:	f6ffe0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(total == 0);
ffffffffc0201470:	00002697          	auipc	a3,0x2
ffffffffc0201474:	93068693          	addi	a3,a3,-1744 # ffffffffc0202da0 <commands+0xb08>
ffffffffc0201478:	00001617          	auipc	a2,0x1
ffffffffc020147c:	5e060613          	addi	a2,a2,1504 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201480:	12600593          	li	a1,294
ffffffffc0201484:	00001517          	auipc	a0,0x1
ffffffffc0201488:	5ec50513          	addi	a0,a0,1516 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc020148c:	f4ffe0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(total == nr_free_pages());
ffffffffc0201490:	00001697          	auipc	a3,0x1
ffffffffc0201494:	5f868693          	addi	a3,a3,1528 # ffffffffc0202a88 <commands+0x7f0>
ffffffffc0201498:	00001617          	auipc	a2,0x1
ffffffffc020149c:	5c060613          	addi	a2,a2,1472 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02014a0:	0f300593          	li	a1,243
ffffffffc02014a4:	00001517          	auipc	a0,0x1
ffffffffc02014a8:	5cc50513          	addi	a0,a0,1484 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02014ac:	f2ffe0ef          	jal	ra,ffffffffc02003da <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02014b0:	00001697          	auipc	a3,0x1
ffffffffc02014b4:	61868693          	addi	a3,a3,1560 # ffffffffc0202ac8 <commands+0x830>
ffffffffc02014b8:	00001617          	auipc	a2,0x1
ffffffffc02014bc:	5a060613          	addi	a2,a2,1440 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02014c0:	0ba00593          	li	a1,186
ffffffffc02014c4:	00001517          	auipc	a0,0x1
ffffffffc02014c8:	5ac50513          	addi	a0,a0,1452 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02014cc:	f0ffe0ef          	jal	ra,ffffffffc02003da <__panic>

ffffffffc02014d0 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02014d0:	1141                	addi	sp,sp,-16
ffffffffc02014d2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014d4:	14058a63          	beqz	a1,ffffffffc0201628 <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc02014d8:	00259693          	slli	a3,a1,0x2
ffffffffc02014dc:	96ae                	add	a3,a3,a1
ffffffffc02014de:	068e                	slli	a3,a3,0x3
ffffffffc02014e0:	96aa                	add	a3,a3,a0
ffffffffc02014e2:	87aa                	mv	a5,a0
ffffffffc02014e4:	02d50263          	beq	a0,a3,ffffffffc0201508 <default_free_pages+0x38>
ffffffffc02014e8:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02014ea:	8b05                	andi	a4,a4,1
ffffffffc02014ec:	10071e63          	bnez	a4,ffffffffc0201608 <default_free_pages+0x138>
ffffffffc02014f0:	6798                	ld	a4,8(a5)
ffffffffc02014f2:	8b09                	andi	a4,a4,2
ffffffffc02014f4:	10071a63          	bnez	a4,ffffffffc0201608 <default_free_pages+0x138>
        p->flags = 0;
ffffffffc02014f8:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02014fc:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201500:	02878793          	addi	a5,a5,40
ffffffffc0201504:	fed792e3          	bne	a5,a3,ffffffffc02014e8 <default_free_pages+0x18>
    base->property = n;
ffffffffc0201508:	2581                	sext.w	a1,a1
ffffffffc020150a:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020150c:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201510:	4789                	li	a5,2
ffffffffc0201512:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201516:	00006697          	auipc	a3,0x6
ffffffffc020151a:	b1268693          	addi	a3,a3,-1262 # ffffffffc0207028 <free_area>
ffffffffc020151e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201520:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201522:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201526:	9db9                	addw	a1,a1,a4
ffffffffc0201528:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020152a:	0ad78863          	beq	a5,a3,ffffffffc02015da <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc020152e:	fe878713          	addi	a4,a5,-24
ffffffffc0201532:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201536:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201538:	00e56a63          	bltu	a0,a4,ffffffffc020154c <default_free_pages+0x7c>
    return listelm->next;
ffffffffc020153c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020153e:	06d70263          	beq	a4,a3,ffffffffc02015a2 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201542:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201544:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201548:	fee57ae3          	bgeu	a0,a4,ffffffffc020153c <default_free_pages+0x6c>
ffffffffc020154c:	c199                	beqz	a1,ffffffffc0201552 <default_free_pages+0x82>
ffffffffc020154e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201552:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201554:	e390                	sd	a2,0(a5)
ffffffffc0201556:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201558:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020155a:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc020155c:	02d70063          	beq	a4,a3,ffffffffc020157c <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0201560:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201564:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc0201568:	02081613          	slli	a2,a6,0x20
ffffffffc020156c:	9201                	srli	a2,a2,0x20
ffffffffc020156e:	00261793          	slli	a5,a2,0x2
ffffffffc0201572:	97b2                	add	a5,a5,a2
ffffffffc0201574:	078e                	slli	a5,a5,0x3
ffffffffc0201576:	97ae                	add	a5,a5,a1
ffffffffc0201578:	02f50f63          	beq	a0,a5,ffffffffc02015b6 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc020157c:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc020157e:	00d70f63          	beq	a4,a3,ffffffffc020159c <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201582:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0201584:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0201588:	02059613          	slli	a2,a1,0x20
ffffffffc020158c:	9201                	srli	a2,a2,0x20
ffffffffc020158e:	00261793          	slli	a5,a2,0x2
ffffffffc0201592:	97b2                	add	a5,a5,a2
ffffffffc0201594:	078e                	slli	a5,a5,0x3
ffffffffc0201596:	97aa                	add	a5,a5,a0
ffffffffc0201598:	04f68863          	beq	a3,a5,ffffffffc02015e8 <default_free_pages+0x118>
}
ffffffffc020159c:	60a2                	ld	ra,8(sp)
ffffffffc020159e:	0141                	addi	sp,sp,16
ffffffffc02015a0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02015a2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015a4:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02015a6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02015a8:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015aa:	02d70563          	beq	a4,a3,ffffffffc02015d4 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02015ae:	8832                	mv	a6,a2
ffffffffc02015b0:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02015b2:	87ba                	mv	a5,a4
ffffffffc02015b4:	bf41                	j	ffffffffc0201544 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc02015b6:	491c                	lw	a5,16(a0)
ffffffffc02015b8:	0107883b          	addw	a6,a5,a6
ffffffffc02015bc:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02015c0:	57f5                	li	a5,-3
ffffffffc02015c2:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02015c6:	6d10                	ld	a2,24(a0)
ffffffffc02015c8:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc02015ca:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02015cc:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02015ce:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02015d0:	e390                	sd	a2,0(a5)
ffffffffc02015d2:	b775                	j	ffffffffc020157e <default_free_pages+0xae>
ffffffffc02015d4:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015d6:	873e                	mv	a4,a5
ffffffffc02015d8:	b761                	j	ffffffffc0201560 <default_free_pages+0x90>
}
ffffffffc02015da:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02015dc:	e390                	sd	a2,0(a5)
ffffffffc02015de:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015e0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02015e2:	ed1c                	sd	a5,24(a0)
ffffffffc02015e4:	0141                	addi	sp,sp,16
ffffffffc02015e6:	8082                	ret
            base->property += p->property;
ffffffffc02015e8:	ff872783          	lw	a5,-8(a4)
ffffffffc02015ec:	ff070693          	addi	a3,a4,-16
ffffffffc02015f0:	9dbd                	addw	a1,a1,a5
ffffffffc02015f2:	c90c                	sw	a1,16(a0)
ffffffffc02015f4:	57f5                	li	a5,-3
ffffffffc02015f6:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02015fa:	6314                	ld	a3,0(a4)
ffffffffc02015fc:	671c                	ld	a5,8(a4)
}
ffffffffc02015fe:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201600:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201602:	e394                	sd	a3,0(a5)
ffffffffc0201604:	0141                	addi	sp,sp,16
ffffffffc0201606:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201608:	00001697          	auipc	a3,0x1
ffffffffc020160c:	7b068693          	addi	a3,a3,1968 # ffffffffc0202db8 <commands+0xb20>
ffffffffc0201610:	00001617          	auipc	a2,0x1
ffffffffc0201614:	44860613          	addi	a2,a2,1096 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201618:	08300593          	li	a1,131
ffffffffc020161c:	00001517          	auipc	a0,0x1
ffffffffc0201620:	45450513          	addi	a0,a0,1108 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc0201624:	db7fe0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(n > 0);
ffffffffc0201628:	00001697          	auipc	a3,0x1
ffffffffc020162c:	78868693          	addi	a3,a3,1928 # ffffffffc0202db0 <commands+0xb18>
ffffffffc0201630:	00001617          	auipc	a2,0x1
ffffffffc0201634:	42860613          	addi	a2,a2,1064 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc0201638:	08000593          	li	a1,128
ffffffffc020163c:	00001517          	auipc	a0,0x1
ffffffffc0201640:	43450513          	addi	a0,a0,1076 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc0201644:	d97fe0ef          	jal	ra,ffffffffc02003da <__panic>

ffffffffc0201648 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201648:	c959                	beqz	a0,ffffffffc02016de <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020164a:	00006597          	auipc	a1,0x6
ffffffffc020164e:	9de58593          	addi	a1,a1,-1570 # ffffffffc0207028 <free_area>
ffffffffc0201652:	0105a803          	lw	a6,16(a1)
ffffffffc0201656:	862a                	mv	a2,a0
ffffffffc0201658:	02081793          	slli	a5,a6,0x20
ffffffffc020165c:	9381                	srli	a5,a5,0x20
ffffffffc020165e:	00a7ee63          	bltu	a5,a0,ffffffffc020167a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201662:	87ae                	mv	a5,a1
ffffffffc0201664:	a801                	j	ffffffffc0201674 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201666:	ff87a703          	lw	a4,-8(a5)
ffffffffc020166a:	02071693          	slli	a3,a4,0x20
ffffffffc020166e:	9281                	srli	a3,a3,0x20
ffffffffc0201670:	00c6f763          	bgeu	a3,a2,ffffffffc020167e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201674:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201676:	feb798e3          	bne	a5,a1,ffffffffc0201666 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020167a:	4501                	li	a0,0
}
ffffffffc020167c:	8082                	ret
    return listelm->prev;
ffffffffc020167e:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201682:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201686:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc020168a:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc020168e:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201692:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201696:	02d67b63          	bgeu	a2,a3,ffffffffc02016cc <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc020169a:	00261693          	slli	a3,a2,0x2
ffffffffc020169e:	96b2                	add	a3,a3,a2
ffffffffc02016a0:	068e                	slli	a3,a3,0x3
ffffffffc02016a2:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02016a4:	41c7073b          	subw	a4,a4,t3
ffffffffc02016a8:	ca98                	sw	a4,16(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02016aa:	00868613          	addi	a2,a3,8
ffffffffc02016ae:	4709                	li	a4,2
ffffffffc02016b0:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02016b4:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02016b8:	01868613          	addi	a2,a3,24
        nr_free -= n;
ffffffffc02016bc:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02016c0:	e310                	sd	a2,0(a4)
ffffffffc02016c2:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02016c6:	f298                	sd	a4,32(a3)
    elm->prev = prev;
ffffffffc02016c8:	0116bc23          	sd	a7,24(a3)
ffffffffc02016cc:	41c8083b          	subw	a6,a6,t3
ffffffffc02016d0:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02016d4:	5775                	li	a4,-3
ffffffffc02016d6:	17c1                	addi	a5,a5,-16
ffffffffc02016d8:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02016dc:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02016de:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02016e0:	00001697          	auipc	a3,0x1
ffffffffc02016e4:	6d068693          	addi	a3,a3,1744 # ffffffffc0202db0 <commands+0xb18>
ffffffffc02016e8:	00001617          	auipc	a2,0x1
ffffffffc02016ec:	37060613          	addi	a2,a2,880 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02016f0:	06200593          	li	a1,98
ffffffffc02016f4:	00001517          	auipc	a0,0x1
ffffffffc02016f8:	37c50513          	addi	a0,a0,892 # ffffffffc0202a70 <commands+0x7d8>
default_alloc_pages(size_t n) {
ffffffffc02016fc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02016fe:	cddfe0ef          	jal	ra,ffffffffc02003da <__panic>

ffffffffc0201702 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201702:	1141                	addi	sp,sp,-16
ffffffffc0201704:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201706:	c9e1                	beqz	a1,ffffffffc02017d6 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201708:	00259693          	slli	a3,a1,0x2
ffffffffc020170c:	96ae                	add	a3,a3,a1
ffffffffc020170e:	068e                	slli	a3,a3,0x3
ffffffffc0201710:	96aa                	add	a3,a3,a0
ffffffffc0201712:	87aa                	mv	a5,a0
ffffffffc0201714:	00d50f63          	beq	a0,a3,ffffffffc0201732 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201718:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020171a:	8b05                	andi	a4,a4,1
ffffffffc020171c:	cf49                	beqz	a4,ffffffffc02017b6 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc020171e:	0007a823          	sw	zero,16(a5)
ffffffffc0201722:	0007b423          	sd	zero,8(a5)
ffffffffc0201726:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020172a:	02878793          	addi	a5,a5,40
ffffffffc020172e:	fed795e3          	bne	a5,a3,ffffffffc0201718 <default_init_memmap+0x16>
    base->property = n;
ffffffffc0201732:	2581                	sext.w	a1,a1
ffffffffc0201734:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201736:	4789                	li	a5,2
ffffffffc0201738:	00850713          	addi	a4,a0,8
ffffffffc020173c:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201740:	00006697          	auipc	a3,0x6
ffffffffc0201744:	8e868693          	addi	a3,a3,-1816 # ffffffffc0207028 <free_area>
ffffffffc0201748:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020174a:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020174c:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201750:	9db9                	addw	a1,a1,a4
ffffffffc0201752:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201754:	04d78a63          	beq	a5,a3,ffffffffc02017a8 <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0201758:	fe878713          	addi	a4,a5,-24
ffffffffc020175c:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201760:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201762:	00e56a63          	bltu	a0,a4,ffffffffc0201776 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0201766:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201768:	02d70263          	beq	a4,a3,ffffffffc020178c <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc020176c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020176e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201772:	fee57ae3          	bgeu	a0,a4,ffffffffc0201766 <default_init_memmap+0x64>
ffffffffc0201776:	c199                	beqz	a1,ffffffffc020177c <default_init_memmap+0x7a>
ffffffffc0201778:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020177c:	6398                	ld	a4,0(a5)
}
ffffffffc020177e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201780:	e390                	sd	a2,0(a5)
ffffffffc0201782:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201784:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201786:	ed18                	sd	a4,24(a0)
ffffffffc0201788:	0141                	addi	sp,sp,16
ffffffffc020178a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020178c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020178e:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201790:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201792:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201794:	00d70663          	beq	a4,a3,ffffffffc02017a0 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0201798:	8832                	mv	a6,a2
ffffffffc020179a:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020179c:	87ba                	mv	a5,a4
ffffffffc020179e:	bfc1                	j	ffffffffc020176e <default_init_memmap+0x6c>
}
ffffffffc02017a0:	60a2                	ld	ra,8(sp)
ffffffffc02017a2:	e290                	sd	a2,0(a3)
ffffffffc02017a4:	0141                	addi	sp,sp,16
ffffffffc02017a6:	8082                	ret
ffffffffc02017a8:	60a2                	ld	ra,8(sp)
ffffffffc02017aa:	e390                	sd	a2,0(a5)
ffffffffc02017ac:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02017ae:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02017b0:	ed1c                	sd	a5,24(a0)
ffffffffc02017b2:	0141                	addi	sp,sp,16
ffffffffc02017b4:	8082                	ret
        assert(PageReserved(p));
ffffffffc02017b6:	00001697          	auipc	a3,0x1
ffffffffc02017ba:	62a68693          	addi	a3,a3,1578 # ffffffffc0202de0 <commands+0xb48>
ffffffffc02017be:	00001617          	auipc	a2,0x1
ffffffffc02017c2:	29a60613          	addi	a2,a2,666 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02017c6:	04900593          	li	a1,73
ffffffffc02017ca:	00001517          	auipc	a0,0x1
ffffffffc02017ce:	2a650513          	addi	a0,a0,678 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02017d2:	c09fe0ef          	jal	ra,ffffffffc02003da <__panic>
    assert(n > 0);
ffffffffc02017d6:	00001697          	auipc	a3,0x1
ffffffffc02017da:	5da68693          	addi	a3,a3,1498 # ffffffffc0202db0 <commands+0xb18>
ffffffffc02017de:	00001617          	auipc	a2,0x1
ffffffffc02017e2:	27a60613          	addi	a2,a2,634 # ffffffffc0202a58 <commands+0x7c0>
ffffffffc02017e6:	04600593          	li	a1,70
ffffffffc02017ea:	00001517          	auipc	a0,0x1
ffffffffc02017ee:	28650513          	addi	a0,a0,646 # ffffffffc0202a70 <commands+0x7d8>
ffffffffc02017f2:	be9fe0ef          	jal	ra,ffffffffc02003da <__panic>

ffffffffc02017f6 <alloc_pages>:
 * 用途：在执行原子操作前调用，确保操作不被中断打断
 */
static inline bool __intr_save(void) {
    // 读取sstatus寄存器的值，与SSTATUS_SIE（中断使能位掩码）进行与运算
    // 若结果非0，说明当前中断是使能的
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017f6:	100027f3          	csrr	a5,sstatus
ffffffffc02017fa:	8b89                	andi	a5,a5,2
ffffffffc02017fc:	e799                	bnez	a5,ffffffffc020180a <alloc_pages+0x14>

    // 保存当前中断状态并关闭中断，确保后续分配操作不被打断
    local_intr_save(intr_flag);
    {
        // 调用内存管理器的分配函数实际执行分配（具体实现由pmm_manager指向的算法决定）
        page = pmm_manager->alloc_pages(n);
ffffffffc02017fe:	00006797          	auipc	a5,0x6
ffffffffc0201802:	c7a7b783          	ld	a5,-902(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0201806:	6f9c                	ld	a5,24(a5)
ffffffffc0201808:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc020180a:	1141                	addi	sp,sp,-16
ffffffffc020180c:	e406                	sd	ra,8(sp)
ffffffffc020180e:	e022                	sd	s0,0(sp)
ffffffffc0201810:	842a                	mv	s0,a0
        intr_disable();  // 关闭全局中断（屏蔽所有可屏蔽中断）
ffffffffc0201812:	82aff0ef          	jal	ra,ffffffffc020083c <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201816:	00006797          	auipc	a5,0x6
ffffffffc020181a:	c627b783          	ld	a5,-926(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc020181e:	6f9c                	ld	a5,24(a5)
ffffffffc0201820:	8522                	mv	a0,s0
ffffffffc0201822:	9782                	jalr	a5
ffffffffc0201824:	842a                	mv	s0,a0
 * 功能：若flag为1，则重新使能中断，确保不影响原有中断状态
 * 用途：原子操作完成后调用，恢复系统中断状态
 */
static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();   // 重新开启全局中断
ffffffffc0201826:	810ff0ef          	jal	ra,ffffffffc0200836 <intr_enable>
    }
    // 恢复中断状态（若原中断是开启的，则重新开启；否则保持关闭）
    local_intr_restore(intr_flag);

    return page;  // 返回分配到的物理页指针
}
ffffffffc020182a:	60a2                	ld	ra,8(sp)
ffffffffc020182c:	8522                	mv	a0,s0
ffffffffc020182e:	6402                	ld	s0,0(sp)
ffffffffc0201830:	0141                	addi	sp,sp,16
ffffffffc0201832:	8082                	ret

ffffffffc0201834 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201834:	100027f3          	csrr	a5,sstatus
ffffffffc0201838:	8b89                	andi	a5,a5,2
ffffffffc020183a:	e799                	bnez	a5,ffffffffc0201848 <free_pages+0x14>

    // 保存当前中断状态并关闭中断，确保释放操作不被打断
    local_intr_save(intr_flag);
    {
        // 调用内存管理器的释放函数实际执行释放
        pmm_manager->free_pages(base, n);
ffffffffc020183c:	00006797          	auipc	a5,0x6
ffffffffc0201840:	c3c7b783          	ld	a5,-964(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0201844:	739c                	ld	a5,32(a5)
ffffffffc0201846:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201848:	1101                	addi	sp,sp,-32
ffffffffc020184a:	ec06                	sd	ra,24(sp)
ffffffffc020184c:	e822                	sd	s0,16(sp)
ffffffffc020184e:	e426                	sd	s1,8(sp)
ffffffffc0201850:	842a                	mv	s0,a0
ffffffffc0201852:	84ae                	mv	s1,a1
        intr_disable();  // 关闭全局中断（屏蔽所有可屏蔽中断）
ffffffffc0201854:	fe9fe0ef          	jal	ra,ffffffffc020083c <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201858:	00006797          	auipc	a5,0x6
ffffffffc020185c:	c207b783          	ld	a5,-992(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0201860:	739c                	ld	a5,32(a5)
ffffffffc0201862:	85a6                	mv	a1,s1
ffffffffc0201864:	8522                	mv	a0,s0
ffffffffc0201866:	9782                	jalr	a5
    }
    // 恢复中断状态
    local_intr_restore(intr_flag);
}
ffffffffc0201868:	6442                	ld	s0,16(sp)
ffffffffc020186a:	60e2                	ld	ra,24(sp)
ffffffffc020186c:	64a2                	ld	s1,8(sp)
ffffffffc020186e:	6105                	addi	sp,sp,32
        intr_enable();   // 重新开启全局中断
ffffffffc0201870:	fc7fe06f          	j	ffffffffc0200836 <intr_enable>

ffffffffc0201874 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201874:	100027f3          	csrr	a5,sstatus
ffffffffc0201878:	8b89                	andi	a5,a5,2
ffffffffc020187a:	e799                	bnez	a5,ffffffffc0201888 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;               // 用于存储空闲页数的返回值
    bool intr_flag;           // 用于保存中断状态的标志
    local_intr_save(intr_flag);  // 关闭中断确保操作原子性
    {
        ret = pmm_manager->nr_free_pages();  // 委托给当前管理器获取空闲页数
ffffffffc020187c:	00006797          	auipc	a5,0x6
ffffffffc0201880:	bfc7b783          	ld	a5,-1028(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0201884:	779c                	ld	a5,40(a5)
ffffffffc0201886:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201888:	1141                	addi	sp,sp,-16
ffffffffc020188a:	e406                	sd	ra,8(sp)
ffffffffc020188c:	e022                	sd	s0,0(sp)
        intr_disable();  // 关闭全局中断（屏蔽所有可屏蔽中断）
ffffffffc020188e:	faffe0ef          	jal	ra,ffffffffc020083c <intr_disable>
        ret = pmm_manager->nr_free_pages();  // 委托给当前管理器获取空闲页数
ffffffffc0201892:	00006797          	auipc	a5,0x6
ffffffffc0201896:	be67b783          	ld	a5,-1050(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc020189a:	779c                	ld	a5,40(a5)
ffffffffc020189c:	9782                	jalr	a5
ffffffffc020189e:	842a                	mv	s0,a0
        intr_enable();   // 重新开启全局中断
ffffffffc02018a0:	f97fe0ef          	jal	ra,ffffffffc0200836 <intr_enable>
    }
    local_intr_restore(intr_flag);  // 恢复中断状态
    return ret;  // 返回空闲页数
}
ffffffffc02018a4:	60a2                	ld	ra,8(sp)
ffffffffc02018a6:	8522                	mv	a0,s0
ffffffffc02018a8:	6402                	ld	s0,0(sp)
ffffffffc02018aa:	0141                	addi	sp,sp,16
ffffffffc02018ac:	8082                	ret

ffffffffc02018ae <pmm_init>:
    pmm_manager = &default_pmm_manager;  // 设置默认物理内存管理器（可切换为其他算法如最佳适配）
ffffffffc02018ae:	00001797          	auipc	a5,0x1
ffffffffc02018b2:	55a78793          	addi	a5,a5,1370 # ffffffffc0202e08 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);  // 打印使用的内存管理器名称
ffffffffc02018b6:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - 初始化物理内存管理系统 */
void pmm_init(void) {
ffffffffc02018b8:	7179                	addi	sp,sp,-48
ffffffffc02018ba:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);  // 打印使用的内存管理器名称
ffffffffc02018bc:	00001517          	auipc	a0,0x1
ffffffffc02018c0:	58450513          	addi	a0,a0,1412 # ffffffffc0202e40 <default_pmm_manager+0x38>
    pmm_manager = &default_pmm_manager;  // 设置默认物理内存管理器（可切换为其他算法如最佳适配）
ffffffffc02018c4:	00006417          	auipc	s0,0x6
ffffffffc02018c8:	bb440413          	addi	s0,s0,-1100 # ffffffffc0207478 <pmm_manager>
void pmm_init(void) {
ffffffffc02018cc:	f406                	sd	ra,40(sp)
ffffffffc02018ce:	ec26                	sd	s1,24(sp)
ffffffffc02018d0:	e44e                	sd	s3,8(sp)
ffffffffc02018d2:	e84a                	sd	s2,16(sp)
ffffffffc02018d4:	e052                	sd	s4,0(sp)
    pmm_manager = &default_pmm_manager;  // 设置默认物理内存管理器（可切换为其他算法如最佳适配）
ffffffffc02018d6:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);  // 打印使用的内存管理器名称
ffffffffc02018d8:	809fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    pmm_manager->init();  // 调用管理器的初始化函数（初始化内部数据结构）
ffffffffc02018dc:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  // 设置虚拟地址与物理地址的偏移量（内核空间偏移）
ffffffffc02018de:	00006497          	auipc	s1,0x6
ffffffffc02018e2:	bb248493          	addi	s1,s1,-1102 # ffffffffc0207490 <va_pa_offset>
    pmm_manager->init();  // 调用管理器的初始化函数（初始化内部数据结构）
ffffffffc02018e6:	679c                	ld	a5,8(a5)
ffffffffc02018e8:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  // 设置虚拟地址与物理地址的偏移量（内核空间偏移）
ffffffffc02018ea:	57f5                	li	a5,-3
ffffffffc02018ec:	07fa                	slli	a5,a5,0x1e
ffffffffc02018ee:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc02018f0:	f33fe0ef          	jal	ra,ffffffffc0200822 <get_memory_base>
ffffffffc02018f4:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc02018f6:	f37fe0ef          	jal	ra,ffffffffc020082c <get_memory_size>
    if (mem_size == 0) {
ffffffffc02018fa:	16050163          	beqz	a0,ffffffffc0201a5c <pmm_init+0x1ae>
    uint64_t mem_end   = mem_begin + mem_size;  // 计算内存结束地址
ffffffffc02018fe:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0201900:	00001517          	auipc	a0,0x1
ffffffffc0201904:	58850513          	addi	a0,a0,1416 # ffffffffc0202e88 <default_pmm_manager+0x80>
ffffffffc0201908:	fd8fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;  // 计算内存结束地址
ffffffffc020190c:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201910:	864e                	mv	a2,s3
ffffffffc0201912:	fffa0693          	addi	a3,s4,-1
ffffffffc0201916:	85ca                	mv	a1,s2
ffffffffc0201918:	00001517          	auipc	a0,0x1
ffffffffc020191c:	58850513          	addi	a0,a0,1416 # ffffffffc0202ea0 <default_pmm_manager+0x98>
ffffffffc0201920:	fc0fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0201924:	c80007b7          	lui	a5,0xc8000
ffffffffc0201928:	8652                	mv	a2,s4
ffffffffc020192a:	0d47e863          	bltu	a5,s4,ffffffffc02019fa <pmm_init+0x14c>
ffffffffc020192e:	00007797          	auipc	a5,0x7
ffffffffc0201932:	b7178793          	addi	a5,a5,-1167 # ffffffffc020849f <end+0xfff>
ffffffffc0201936:	757d                	lui	a0,0xfffff
ffffffffc0201938:	8d7d                	and	a0,a0,a5
ffffffffc020193a:	8231                	srli	a2,a2,0xc
ffffffffc020193c:	00006597          	auipc	a1,0x6
ffffffffc0201940:	b2c58593          	addi	a1,a1,-1236 # ffffffffc0207468 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201944:	00006817          	auipc	a6,0x6
ffffffffc0201948:	b2c80813          	addi	a6,a6,-1236 # ffffffffc0207470 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020194c:	e190                	sd	a2,0(a1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020194e:	00a83023          	sd	a0,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201952:	000807b7          	lui	a5,0x80
ffffffffc0201956:	02f60663          	beq	a2,a5,ffffffffc0201982 <pmm_init+0xd4>
ffffffffc020195a:	4701                	li	a4,0
ffffffffc020195c:	4781                	li	a5,0
ffffffffc020195e:	4305                	li	t1,1
ffffffffc0201960:	fff808b7          	lui	a7,0xfff80
        SetPageReserved(pages + i);
ffffffffc0201964:	953a                	add	a0,a0,a4
ffffffffc0201966:	00850693          	addi	a3,a0,8 # fffffffffffff008 <end+0x3fdf7b68>
ffffffffc020196a:	4066b02f          	amoor.d	zero,t1,(a3)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020196e:	6190                	ld	a2,0(a1)
ffffffffc0201970:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc0201972:	00083503          	ld	a0,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201976:	011606b3          	add	a3,a2,a7
ffffffffc020197a:	02870713          	addi	a4,a4,40
ffffffffc020197e:	fed7e3e3          	bltu	a5,a3,ffffffffc0201964 <pmm_init+0xb6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201982:	00261693          	slli	a3,a2,0x2
ffffffffc0201986:	96b2                	add	a3,a3,a2
ffffffffc0201988:	fec007b7          	lui	a5,0xfec00
ffffffffc020198c:	97aa                	add	a5,a5,a0
ffffffffc020198e:	068e                	slli	a3,a3,0x3
ffffffffc0201990:	96be                	add	a3,a3,a5
ffffffffc0201992:	c02007b7          	lui	a5,0xc0200
ffffffffc0201996:	0af6e763          	bltu	a3,a5,ffffffffc0201a44 <pmm_init+0x196>
ffffffffc020199a:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020199c:	77fd                	lui	a5,0xfffff
ffffffffc020199e:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02019a2:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02019a4:	04b6ee63          	bltu	a3,a1,ffffffffc0201a00 <pmm_init+0x152>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

// check_alloc_page - 检查物理内存分配功能的正确性
static void check_alloc_page(void) {
    pmm_manager->check();  // 调用当前内存管理器的检查函数（验证分配/释放逻辑）
ffffffffc02019a8:	601c                	ld	a5,0(s0)
ffffffffc02019aa:	7b9c                	ld	a5,48(a5)
ffffffffc02019ac:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");  // 打印检查成功信息
ffffffffc02019ae:	00001517          	auipc	a0,0x1
ffffffffc02019b2:	57a50513          	addi	a0,a0,1402 # ffffffffc0202f28 <default_pmm_manager+0x120>
ffffffffc02019b6:	f2afe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;  // 保存页表的虚拟地址
ffffffffc02019ba:	00004597          	auipc	a1,0x4
ffffffffc02019be:	64658593          	addi	a1,a1,1606 # ffffffffc0206000 <boot_page_table_sv39>
ffffffffc02019c2:	00006797          	auipc	a5,0x6
ffffffffc02019c6:	acb7b323          	sd	a1,-1338(a5) # ffffffffc0207488 <satp_virtual>
    satp_physical = PADDR(satp_virtual);  // 计算页表的物理地址（虚拟地址减去偏移量）
ffffffffc02019ca:	c02007b7          	lui	a5,0xc0200
ffffffffc02019ce:	0af5e363          	bltu	a1,a5,ffffffffc0201a74 <pmm_init+0x1c6>
ffffffffc02019d2:	6090                	ld	a2,0(s1)
}
ffffffffc02019d4:	7402                	ld	s0,32(sp)
ffffffffc02019d6:	70a2                	ld	ra,40(sp)
ffffffffc02019d8:	64e2                	ld	s1,24(sp)
ffffffffc02019da:	6942                	ld	s2,16(sp)
ffffffffc02019dc:	69a2                	ld	s3,8(sp)
ffffffffc02019de:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);  // 计算页表的物理地址（虚拟地址减去偏移量）
ffffffffc02019e0:	40c58633          	sub	a2,a1,a2
ffffffffc02019e4:	00006797          	auipc	a5,0x6
ffffffffc02019e8:	a8c7be23          	sd	a2,-1380(a5) # ffffffffc0207480 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02019ec:	00001517          	auipc	a0,0x1
ffffffffc02019f0:	55c50513          	addi	a0,a0,1372 # ffffffffc0202f48 <default_pmm_manager+0x140>
}
ffffffffc02019f4:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02019f6:	eeafe06f          	j	ffffffffc02000e0 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02019fa:	c8000637          	lui	a2,0xc8000
ffffffffc02019fe:	bf05                	j	ffffffffc020192e <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201a00:	6705                	lui	a4,0x1
ffffffffc0201a02:	177d                	addi	a4,a4,-1
ffffffffc0201a04:	96ba                	add	a3,a3,a4
ffffffffc0201a06:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201a08:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201a0c:	02c7f063          	bgeu	a5,a2,ffffffffc0201a2c <pmm_init+0x17e>
    pmm_manager->init_memmap(base, n);  // 委托给当前管理器实现（初始化n个连续物理页的元数据）
ffffffffc0201a10:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201a12:	fff80737          	lui	a4,0xfff80
ffffffffc0201a16:	973e                	add	a4,a4,a5
ffffffffc0201a18:	00271793          	slli	a5,a4,0x2
ffffffffc0201a1c:	97ba                	add	a5,a5,a4
ffffffffc0201a1e:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201a20:	8d95                	sub	a1,a1,a3
ffffffffc0201a22:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);  // 委托给当前管理器实现（初始化n个连续物理页的元数据）
ffffffffc0201a24:	81b1                	srli	a1,a1,0xc
ffffffffc0201a26:	953e                	add	a0,a0,a5
ffffffffc0201a28:	9702                	jalr	a4
}
ffffffffc0201a2a:	bfbd                	j	ffffffffc02019a8 <pmm_init+0xfa>
        panic("pa2page called with invalid pa");
ffffffffc0201a2c:	00001617          	auipc	a2,0x1
ffffffffc0201a30:	4cc60613          	addi	a2,a2,1228 # ffffffffc0202ef8 <default_pmm_manager+0xf0>
ffffffffc0201a34:	06b00593          	li	a1,107
ffffffffc0201a38:	00001517          	auipc	a0,0x1
ffffffffc0201a3c:	4e050513          	addi	a0,a0,1248 # ffffffffc0202f18 <default_pmm_manager+0x110>
ffffffffc0201a40:	99bfe0ef          	jal	ra,ffffffffc02003da <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201a44:	00001617          	auipc	a2,0x1
ffffffffc0201a48:	48c60613          	addi	a2,a2,1164 # ffffffffc0202ed0 <default_pmm_manager+0xc8>
ffffffffc0201a4c:	08c00593          	li	a1,140
ffffffffc0201a50:	00001517          	auipc	a0,0x1
ffffffffc0201a54:	42850513          	addi	a0,a0,1064 # ffffffffc0202e78 <default_pmm_manager+0x70>
ffffffffc0201a58:	983fe0ef          	jal	ra,ffffffffc02003da <__panic>
        panic("DTB memory info not available");  // 若无法获取内存信息则触发panic（致命错误）
ffffffffc0201a5c:	00001617          	auipc	a2,0x1
ffffffffc0201a60:	3fc60613          	addi	a2,a2,1020 # ffffffffc0202e58 <default_pmm_manager+0x50>
ffffffffc0201a64:	07000593          	li	a1,112
ffffffffc0201a68:	00001517          	auipc	a0,0x1
ffffffffc0201a6c:	41050513          	addi	a0,a0,1040 # ffffffffc0202e78 <default_pmm_manager+0x70>
ffffffffc0201a70:	96bfe0ef          	jal	ra,ffffffffc02003da <__panic>
    satp_physical = PADDR(satp_virtual);  // 计算页表的物理地址（虚拟地址减去偏移量）
ffffffffc0201a74:	86ae                	mv	a3,a1
ffffffffc0201a76:	00001617          	auipc	a2,0x1
ffffffffc0201a7a:	45a60613          	addi	a2,a2,1114 # ffffffffc0202ed0 <default_pmm_manager+0xc8>
ffffffffc0201a7e:	0a900593          	li	a1,169
ffffffffc0201a82:	00001517          	auipc	a0,0x1
ffffffffc0201a86:	3f650513          	addi	a0,a0,1014 # ffffffffc0202e78 <default_pmm_manager+0x70>
ffffffffc0201a8a:	951fe0ef          	jal	ra,ffffffffc02003da <__panic>

ffffffffc0201a8e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201a8e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201a92:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201a94:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201a98:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201a9a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201a9e:	f022                	sd	s0,32(sp)
ffffffffc0201aa0:	ec26                	sd	s1,24(sp)
ffffffffc0201aa2:	e84a                	sd	s2,16(sp)
ffffffffc0201aa4:	f406                	sd	ra,40(sp)
ffffffffc0201aa6:	e44e                	sd	s3,8(sp)
ffffffffc0201aa8:	84aa                	mv	s1,a0
ffffffffc0201aaa:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201aac:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201ab0:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201ab2:	03067e63          	bgeu	a2,a6,ffffffffc0201aee <printnum+0x60>
ffffffffc0201ab6:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201ab8:	00805763          	blez	s0,ffffffffc0201ac6 <printnum+0x38>
ffffffffc0201abc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201abe:	85ca                	mv	a1,s2
ffffffffc0201ac0:	854e                	mv	a0,s3
ffffffffc0201ac2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201ac4:	fc65                	bnez	s0,ffffffffc0201abc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201ac6:	1a02                	slli	s4,s4,0x20
ffffffffc0201ac8:	00001797          	auipc	a5,0x1
ffffffffc0201acc:	4c078793          	addi	a5,a5,1216 # ffffffffc0202f88 <default_pmm_manager+0x180>
ffffffffc0201ad0:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201ad4:	9a3e                	add	s4,s4,a5
}
ffffffffc0201ad6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201ad8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201adc:	70a2                	ld	ra,40(sp)
ffffffffc0201ade:	69a2                	ld	s3,8(sp)
ffffffffc0201ae0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201ae2:	85ca                	mv	a1,s2
ffffffffc0201ae4:	87a6                	mv	a5,s1
}
ffffffffc0201ae6:	6942                	ld	s2,16(sp)
ffffffffc0201ae8:	64e2                	ld	s1,24(sp)
ffffffffc0201aea:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201aec:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201aee:	03065633          	divu	a2,a2,a6
ffffffffc0201af2:	8722                	mv	a4,s0
ffffffffc0201af4:	f9bff0ef          	jal	ra,ffffffffc0201a8e <printnum>
ffffffffc0201af8:	b7f9                	j	ffffffffc0201ac6 <printnum+0x38>

ffffffffc0201afa <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201afa:	7119                	addi	sp,sp,-128
ffffffffc0201afc:	f4a6                	sd	s1,104(sp)
ffffffffc0201afe:	f0ca                	sd	s2,96(sp)
ffffffffc0201b00:	ecce                	sd	s3,88(sp)
ffffffffc0201b02:	e8d2                	sd	s4,80(sp)
ffffffffc0201b04:	e4d6                	sd	s5,72(sp)
ffffffffc0201b06:	e0da                	sd	s6,64(sp)
ffffffffc0201b08:	fc5e                	sd	s7,56(sp)
ffffffffc0201b0a:	f06a                	sd	s10,32(sp)
ffffffffc0201b0c:	fc86                	sd	ra,120(sp)
ffffffffc0201b0e:	f8a2                	sd	s0,112(sp)
ffffffffc0201b10:	f862                	sd	s8,48(sp)
ffffffffc0201b12:	f466                	sd	s9,40(sp)
ffffffffc0201b14:	ec6e                	sd	s11,24(sp)
ffffffffc0201b16:	892a                	mv	s2,a0
ffffffffc0201b18:	84ae                	mv	s1,a1
ffffffffc0201b1a:	8d32                	mv	s10,a2
ffffffffc0201b1c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201b1e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201b22:	5b7d                	li	s6,-1
ffffffffc0201b24:	00001a97          	auipc	s5,0x1
ffffffffc0201b28:	498a8a93          	addi	s5,s5,1176 # ffffffffc0202fbc <default_pmm_manager+0x1b4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201b2c:	00001b97          	auipc	s7,0x1
ffffffffc0201b30:	66cb8b93          	addi	s7,s7,1644 # ffffffffc0203198 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201b34:	000d4503          	lbu	a0,0(s10)
ffffffffc0201b38:	001d0413          	addi	s0,s10,1
ffffffffc0201b3c:	01350a63          	beq	a0,s3,ffffffffc0201b50 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201b40:	c121                	beqz	a0,ffffffffc0201b80 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201b42:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201b44:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201b46:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201b48:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201b4c:	ff351ae3          	bne	a0,s3,ffffffffc0201b40 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b50:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201b54:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201b58:	4c81                	li	s9,0
ffffffffc0201b5a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201b5c:	5c7d                	li	s8,-1
ffffffffc0201b5e:	5dfd                	li	s11,-1
ffffffffc0201b60:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201b64:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b66:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201b6a:	0ff5f593          	zext.b	a1,a1
ffffffffc0201b6e:	00140d13          	addi	s10,s0,1
ffffffffc0201b72:	04b56263          	bltu	a0,a1,ffffffffc0201bb6 <vprintfmt+0xbc>
ffffffffc0201b76:	058a                	slli	a1,a1,0x2
ffffffffc0201b78:	95d6                	add	a1,a1,s5
ffffffffc0201b7a:	4194                	lw	a3,0(a1)
ffffffffc0201b7c:	96d6                	add	a3,a3,s5
ffffffffc0201b7e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201b80:	70e6                	ld	ra,120(sp)
ffffffffc0201b82:	7446                	ld	s0,112(sp)
ffffffffc0201b84:	74a6                	ld	s1,104(sp)
ffffffffc0201b86:	7906                	ld	s2,96(sp)
ffffffffc0201b88:	69e6                	ld	s3,88(sp)
ffffffffc0201b8a:	6a46                	ld	s4,80(sp)
ffffffffc0201b8c:	6aa6                	ld	s5,72(sp)
ffffffffc0201b8e:	6b06                	ld	s6,64(sp)
ffffffffc0201b90:	7be2                	ld	s7,56(sp)
ffffffffc0201b92:	7c42                	ld	s8,48(sp)
ffffffffc0201b94:	7ca2                	ld	s9,40(sp)
ffffffffc0201b96:	7d02                	ld	s10,32(sp)
ffffffffc0201b98:	6de2                	ld	s11,24(sp)
ffffffffc0201b9a:	6109                	addi	sp,sp,128
ffffffffc0201b9c:	8082                	ret
            padc = '0';
ffffffffc0201b9e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201ba0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ba4:	846a                	mv	s0,s10
ffffffffc0201ba6:	00140d13          	addi	s10,s0,1
ffffffffc0201baa:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201bae:	0ff5f593          	zext.b	a1,a1
ffffffffc0201bb2:	fcb572e3          	bgeu	a0,a1,ffffffffc0201b76 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201bb6:	85a6                	mv	a1,s1
ffffffffc0201bb8:	02500513          	li	a0,37
ffffffffc0201bbc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201bbe:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201bc2:	8d22                	mv	s10,s0
ffffffffc0201bc4:	f73788e3          	beq	a5,s3,ffffffffc0201b34 <vprintfmt+0x3a>
ffffffffc0201bc8:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201bcc:	1d7d                	addi	s10,s10,-1
ffffffffc0201bce:	ff379de3          	bne	a5,s3,ffffffffc0201bc8 <vprintfmt+0xce>
ffffffffc0201bd2:	b78d                	j	ffffffffc0201b34 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201bd4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201bd8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201bdc:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201bde:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201be2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201be6:	02d86463          	bltu	a6,a3,ffffffffc0201c0e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201bea:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201bee:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201bf2:	0186873b          	addw	a4,a3,s8
ffffffffc0201bf6:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201bfa:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201bfc:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201c00:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201c02:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201c06:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201c0a:	fed870e3          	bgeu	a6,a3,ffffffffc0201bea <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201c0e:	f40ddce3          	bgez	s11,ffffffffc0201b66 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201c12:	8de2                	mv	s11,s8
ffffffffc0201c14:	5c7d                	li	s8,-1
ffffffffc0201c16:	bf81                	j	ffffffffc0201b66 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201c18:	fffdc693          	not	a3,s11
ffffffffc0201c1c:	96fd                	srai	a3,a3,0x3f
ffffffffc0201c1e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c22:	00144603          	lbu	a2,1(s0)
ffffffffc0201c26:	2d81                	sext.w	s11,s11
ffffffffc0201c28:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201c2a:	bf35                	j	ffffffffc0201b66 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201c2c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c30:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201c34:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c36:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201c38:	bfd9                	j	ffffffffc0201c0e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201c3a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201c3c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201c40:	01174463          	blt	a4,a7,ffffffffc0201c48 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201c44:	1a088e63          	beqz	a7,ffffffffc0201e00 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201c48:	000a3603          	ld	a2,0(s4)
ffffffffc0201c4c:	46c1                	li	a3,16
ffffffffc0201c4e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201c50:	2781                	sext.w	a5,a5
ffffffffc0201c52:	876e                	mv	a4,s11
ffffffffc0201c54:	85a6                	mv	a1,s1
ffffffffc0201c56:	854a                	mv	a0,s2
ffffffffc0201c58:	e37ff0ef          	jal	ra,ffffffffc0201a8e <printnum>
            break;
ffffffffc0201c5c:	bde1                	j	ffffffffc0201b34 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201c5e:	000a2503          	lw	a0,0(s4)
ffffffffc0201c62:	85a6                	mv	a1,s1
ffffffffc0201c64:	0a21                	addi	s4,s4,8
ffffffffc0201c66:	9902                	jalr	s2
            break;
ffffffffc0201c68:	b5f1                	j	ffffffffc0201b34 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201c6a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201c6c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201c70:	01174463          	blt	a4,a7,ffffffffc0201c78 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201c74:	18088163          	beqz	a7,ffffffffc0201df6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201c78:	000a3603          	ld	a2,0(s4)
ffffffffc0201c7c:	46a9                	li	a3,10
ffffffffc0201c7e:	8a2e                	mv	s4,a1
ffffffffc0201c80:	bfc1                	j	ffffffffc0201c50 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c82:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201c86:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c88:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201c8a:	bdf1                	j	ffffffffc0201b66 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201c8c:	85a6                	mv	a1,s1
ffffffffc0201c8e:	02500513          	li	a0,37
ffffffffc0201c92:	9902                	jalr	s2
            break;
ffffffffc0201c94:	b545                	j	ffffffffc0201b34 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c96:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201c9a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c9c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201c9e:	b5e1                	j	ffffffffc0201b66 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201ca0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201ca2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201ca6:	01174463          	blt	a4,a7,ffffffffc0201cae <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201caa:	14088163          	beqz	a7,ffffffffc0201dec <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201cae:	000a3603          	ld	a2,0(s4)
ffffffffc0201cb2:	46a1                	li	a3,8
ffffffffc0201cb4:	8a2e                	mv	s4,a1
ffffffffc0201cb6:	bf69                	j	ffffffffc0201c50 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201cb8:	03000513          	li	a0,48
ffffffffc0201cbc:	85a6                	mv	a1,s1
ffffffffc0201cbe:	e03e                	sd	a5,0(sp)
ffffffffc0201cc0:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201cc2:	85a6                	mv	a1,s1
ffffffffc0201cc4:	07800513          	li	a0,120
ffffffffc0201cc8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201cca:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201ccc:	6782                	ld	a5,0(sp)
ffffffffc0201cce:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201cd0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201cd4:	bfb5                	j	ffffffffc0201c50 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201cd6:	000a3403          	ld	s0,0(s4)
ffffffffc0201cda:	008a0713          	addi	a4,s4,8
ffffffffc0201cde:	e03a                	sd	a4,0(sp)
ffffffffc0201ce0:	14040263          	beqz	s0,ffffffffc0201e24 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201ce4:	0fb05763          	blez	s11,ffffffffc0201dd2 <vprintfmt+0x2d8>
ffffffffc0201ce8:	02d00693          	li	a3,45
ffffffffc0201cec:	0cd79163          	bne	a5,a3,ffffffffc0201dae <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201cf0:	00044783          	lbu	a5,0(s0)
ffffffffc0201cf4:	0007851b          	sext.w	a0,a5
ffffffffc0201cf8:	cf85                	beqz	a5,ffffffffc0201d30 <vprintfmt+0x236>
ffffffffc0201cfa:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201cfe:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201d02:	000c4563          	bltz	s8,ffffffffc0201d0c <vprintfmt+0x212>
ffffffffc0201d06:	3c7d                	addiw	s8,s8,-1
ffffffffc0201d08:	036c0263          	beq	s8,s6,ffffffffc0201d2c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201d0c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201d0e:	0e0c8e63          	beqz	s9,ffffffffc0201e0a <vprintfmt+0x310>
ffffffffc0201d12:	3781                	addiw	a5,a5,-32
ffffffffc0201d14:	0ef47b63          	bgeu	s0,a5,ffffffffc0201e0a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201d18:	03f00513          	li	a0,63
ffffffffc0201d1c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201d1e:	000a4783          	lbu	a5,0(s4)
ffffffffc0201d22:	3dfd                	addiw	s11,s11,-1
ffffffffc0201d24:	0a05                	addi	s4,s4,1
ffffffffc0201d26:	0007851b          	sext.w	a0,a5
ffffffffc0201d2a:	ffe1                	bnez	a5,ffffffffc0201d02 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201d2c:	01b05963          	blez	s11,ffffffffc0201d3e <vprintfmt+0x244>
ffffffffc0201d30:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201d32:	85a6                	mv	a1,s1
ffffffffc0201d34:	02000513          	li	a0,32
ffffffffc0201d38:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201d3a:	fe0d9be3          	bnez	s11,ffffffffc0201d30 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201d3e:	6a02                	ld	s4,0(sp)
ffffffffc0201d40:	bbd5                	j	ffffffffc0201b34 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201d42:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201d44:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201d48:	01174463          	blt	a4,a7,ffffffffc0201d50 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201d4c:	08088d63          	beqz	a7,ffffffffc0201de6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201d50:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201d54:	0a044d63          	bltz	s0,ffffffffc0201e0e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201d58:	8622                	mv	a2,s0
ffffffffc0201d5a:	8a66                	mv	s4,s9
ffffffffc0201d5c:	46a9                	li	a3,10
ffffffffc0201d5e:	bdcd                	j	ffffffffc0201c50 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201d60:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201d64:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201d66:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201d68:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201d6c:	8fb5                	xor	a5,a5,a3
ffffffffc0201d6e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201d72:	02d74163          	blt	a4,a3,ffffffffc0201d94 <vprintfmt+0x29a>
ffffffffc0201d76:	00369793          	slli	a5,a3,0x3
ffffffffc0201d7a:	97de                	add	a5,a5,s7
ffffffffc0201d7c:	639c                	ld	a5,0(a5)
ffffffffc0201d7e:	cb99                	beqz	a5,ffffffffc0201d94 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201d80:	86be                	mv	a3,a5
ffffffffc0201d82:	00001617          	auipc	a2,0x1
ffffffffc0201d86:	23660613          	addi	a2,a2,566 # ffffffffc0202fb8 <default_pmm_manager+0x1b0>
ffffffffc0201d8a:	85a6                	mv	a1,s1
ffffffffc0201d8c:	854a                	mv	a0,s2
ffffffffc0201d8e:	0ce000ef          	jal	ra,ffffffffc0201e5c <printfmt>
ffffffffc0201d92:	b34d                	j	ffffffffc0201b34 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201d94:	00001617          	auipc	a2,0x1
ffffffffc0201d98:	21460613          	addi	a2,a2,532 # ffffffffc0202fa8 <default_pmm_manager+0x1a0>
ffffffffc0201d9c:	85a6                	mv	a1,s1
ffffffffc0201d9e:	854a                	mv	a0,s2
ffffffffc0201da0:	0bc000ef          	jal	ra,ffffffffc0201e5c <printfmt>
ffffffffc0201da4:	bb41                	j	ffffffffc0201b34 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201da6:	00001417          	auipc	s0,0x1
ffffffffc0201daa:	1fa40413          	addi	s0,s0,506 # ffffffffc0202fa0 <default_pmm_manager+0x198>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201dae:	85e2                	mv	a1,s8
ffffffffc0201db0:	8522                	mv	a0,s0
ffffffffc0201db2:	e43e                	sd	a5,8(sp)
ffffffffc0201db4:	200000ef          	jal	ra,ffffffffc0201fb4 <strnlen>
ffffffffc0201db8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201dbc:	01b05b63          	blez	s11,ffffffffc0201dd2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201dc0:	67a2                	ld	a5,8(sp)
ffffffffc0201dc2:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201dc6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201dc8:	85a6                	mv	a1,s1
ffffffffc0201dca:	8552                	mv	a0,s4
ffffffffc0201dcc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201dce:	fe0d9ce3          	bnez	s11,ffffffffc0201dc6 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201dd2:	00044783          	lbu	a5,0(s0)
ffffffffc0201dd6:	00140a13          	addi	s4,s0,1
ffffffffc0201dda:	0007851b          	sext.w	a0,a5
ffffffffc0201dde:	d3a5                	beqz	a5,ffffffffc0201d3e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201de0:	05e00413          	li	s0,94
ffffffffc0201de4:	bf39                	j	ffffffffc0201d02 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201de6:	000a2403          	lw	s0,0(s4)
ffffffffc0201dea:	b7ad                	j	ffffffffc0201d54 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201dec:	000a6603          	lwu	a2,0(s4)
ffffffffc0201df0:	46a1                	li	a3,8
ffffffffc0201df2:	8a2e                	mv	s4,a1
ffffffffc0201df4:	bdb1                	j	ffffffffc0201c50 <vprintfmt+0x156>
ffffffffc0201df6:	000a6603          	lwu	a2,0(s4)
ffffffffc0201dfa:	46a9                	li	a3,10
ffffffffc0201dfc:	8a2e                	mv	s4,a1
ffffffffc0201dfe:	bd89                	j	ffffffffc0201c50 <vprintfmt+0x156>
ffffffffc0201e00:	000a6603          	lwu	a2,0(s4)
ffffffffc0201e04:	46c1                	li	a3,16
ffffffffc0201e06:	8a2e                	mv	s4,a1
ffffffffc0201e08:	b5a1                	j	ffffffffc0201c50 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201e0a:	9902                	jalr	s2
ffffffffc0201e0c:	bf09                	j	ffffffffc0201d1e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201e0e:	85a6                	mv	a1,s1
ffffffffc0201e10:	02d00513          	li	a0,45
ffffffffc0201e14:	e03e                	sd	a5,0(sp)
ffffffffc0201e16:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201e18:	6782                	ld	a5,0(sp)
ffffffffc0201e1a:	8a66                	mv	s4,s9
ffffffffc0201e1c:	40800633          	neg	a2,s0
ffffffffc0201e20:	46a9                	li	a3,10
ffffffffc0201e22:	b53d                	j	ffffffffc0201c50 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201e24:	03b05163          	blez	s11,ffffffffc0201e46 <vprintfmt+0x34c>
ffffffffc0201e28:	02d00693          	li	a3,45
ffffffffc0201e2c:	f6d79de3          	bne	a5,a3,ffffffffc0201da6 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201e30:	00001417          	auipc	s0,0x1
ffffffffc0201e34:	17040413          	addi	s0,s0,368 # ffffffffc0202fa0 <default_pmm_manager+0x198>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201e38:	02800793          	li	a5,40
ffffffffc0201e3c:	02800513          	li	a0,40
ffffffffc0201e40:	00140a13          	addi	s4,s0,1
ffffffffc0201e44:	bd6d                	j	ffffffffc0201cfe <vprintfmt+0x204>
ffffffffc0201e46:	00001a17          	auipc	s4,0x1
ffffffffc0201e4a:	15ba0a13          	addi	s4,s4,347 # ffffffffc0202fa1 <default_pmm_manager+0x199>
ffffffffc0201e4e:	02800513          	li	a0,40
ffffffffc0201e52:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201e56:	05e00413          	li	s0,94
ffffffffc0201e5a:	b565                	j	ffffffffc0201d02 <vprintfmt+0x208>

ffffffffc0201e5c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201e5c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201e5e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201e62:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201e64:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201e66:	ec06                	sd	ra,24(sp)
ffffffffc0201e68:	f83a                	sd	a4,48(sp)
ffffffffc0201e6a:	fc3e                	sd	a5,56(sp)
ffffffffc0201e6c:	e0c2                	sd	a6,64(sp)
ffffffffc0201e6e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201e70:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201e72:	c89ff0ef          	jal	ra,ffffffffc0201afa <vprintfmt>
}
ffffffffc0201e76:	60e2                	ld	ra,24(sp)
ffffffffc0201e78:	6161                	addi	sp,sp,80
ffffffffc0201e7a:	8082                	ret

ffffffffc0201e7c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201e7c:	715d                	addi	sp,sp,-80
ffffffffc0201e7e:	e486                	sd	ra,72(sp)
ffffffffc0201e80:	e0a6                	sd	s1,64(sp)
ffffffffc0201e82:	fc4a                	sd	s2,56(sp)
ffffffffc0201e84:	f84e                	sd	s3,48(sp)
ffffffffc0201e86:	f452                	sd	s4,40(sp)
ffffffffc0201e88:	f056                	sd	s5,32(sp)
ffffffffc0201e8a:	ec5a                	sd	s6,24(sp)
ffffffffc0201e8c:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201e8e:	c901                	beqz	a0,ffffffffc0201e9e <readline+0x22>
ffffffffc0201e90:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201e92:	00001517          	auipc	a0,0x1
ffffffffc0201e96:	12650513          	addi	a0,a0,294 # ffffffffc0202fb8 <default_pmm_manager+0x1b0>
ffffffffc0201e9a:	a46fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
readline(const char *prompt) {
ffffffffc0201e9e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ea0:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201ea2:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201ea4:	4aa9                	li	s5,10
ffffffffc0201ea6:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201ea8:	00005b97          	auipc	s7,0x5
ffffffffc0201eac:	198b8b93          	addi	s7,s7,408 # ffffffffc0207040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201eb0:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201eb4:	aa4fe0ef          	jal	ra,ffffffffc0200158 <getchar>
        if (c < 0) {
ffffffffc0201eb8:	00054a63          	bltz	a0,ffffffffc0201ecc <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ebc:	00a95a63          	bge	s2,a0,ffffffffc0201ed0 <readline+0x54>
ffffffffc0201ec0:	029a5263          	bge	s4,s1,ffffffffc0201ee4 <readline+0x68>
        c = getchar();
ffffffffc0201ec4:	a94fe0ef          	jal	ra,ffffffffc0200158 <getchar>
        if (c < 0) {
ffffffffc0201ec8:	fe055ae3          	bgez	a0,ffffffffc0201ebc <readline+0x40>
            return NULL;
ffffffffc0201ecc:	4501                	li	a0,0
ffffffffc0201ece:	a091                	j	ffffffffc0201f12 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201ed0:	03351463          	bne	a0,s3,ffffffffc0201ef8 <readline+0x7c>
ffffffffc0201ed4:	e8a9                	bnez	s1,ffffffffc0201f26 <readline+0xaa>
        c = getchar();
ffffffffc0201ed6:	a82fe0ef          	jal	ra,ffffffffc0200158 <getchar>
        if (c < 0) {
ffffffffc0201eda:	fe0549e3          	bltz	a0,ffffffffc0201ecc <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ede:	fea959e3          	bge	s2,a0,ffffffffc0201ed0 <readline+0x54>
ffffffffc0201ee2:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201ee4:	e42a                	sd	a0,8(sp)
ffffffffc0201ee6:	a30fe0ef          	jal	ra,ffffffffc0200116 <cputchar>
            buf[i ++] = c;
ffffffffc0201eea:	6522                	ld	a0,8(sp)
ffffffffc0201eec:	009b87b3          	add	a5,s7,s1
ffffffffc0201ef0:	2485                	addiw	s1,s1,1
ffffffffc0201ef2:	00a78023          	sb	a0,0(a5)
ffffffffc0201ef6:	bf7d                	j	ffffffffc0201eb4 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201ef8:	01550463          	beq	a0,s5,ffffffffc0201f00 <readline+0x84>
ffffffffc0201efc:	fb651ce3          	bne	a0,s6,ffffffffc0201eb4 <readline+0x38>
            cputchar(c);
ffffffffc0201f00:	a16fe0ef          	jal	ra,ffffffffc0200116 <cputchar>
            buf[i] = '\0';
ffffffffc0201f04:	00005517          	auipc	a0,0x5
ffffffffc0201f08:	13c50513          	addi	a0,a0,316 # ffffffffc0207040 <buf>
ffffffffc0201f0c:	94aa                	add	s1,s1,a0
ffffffffc0201f0e:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201f12:	60a6                	ld	ra,72(sp)
ffffffffc0201f14:	6486                	ld	s1,64(sp)
ffffffffc0201f16:	7962                	ld	s2,56(sp)
ffffffffc0201f18:	79c2                	ld	s3,48(sp)
ffffffffc0201f1a:	7a22                	ld	s4,40(sp)
ffffffffc0201f1c:	7a82                	ld	s5,32(sp)
ffffffffc0201f1e:	6b62                	ld	s6,24(sp)
ffffffffc0201f20:	6bc2                	ld	s7,16(sp)
ffffffffc0201f22:	6161                	addi	sp,sp,80
ffffffffc0201f24:	8082                	ret
            cputchar(c);
ffffffffc0201f26:	4521                	li	a0,8
ffffffffc0201f28:	9eefe0ef          	jal	ra,ffffffffc0200116 <cputchar>
            i --;
ffffffffc0201f2c:	34fd                	addiw	s1,s1,-1
ffffffffc0201f2e:	b759                	j	ffffffffc0201eb4 <readline+0x38>

ffffffffc0201f30 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201f30:	4781                	li	a5,0
ffffffffc0201f32:	00005717          	auipc	a4,0x5
ffffffffc0201f36:	0e673703          	ld	a4,230(a4) # ffffffffc0207018 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201f3a:	88ba                	mv	a7,a4
ffffffffc0201f3c:	852a                	mv	a0,a0
ffffffffc0201f3e:	85be                	mv	a1,a5
ffffffffc0201f40:	863e                	mv	a2,a5
ffffffffc0201f42:	00000073          	ecall
ffffffffc0201f46:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201f48:	8082                	ret

ffffffffc0201f4a <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201f4a:	4781                	li	a5,0
ffffffffc0201f4c:	00005717          	auipc	a4,0x5
ffffffffc0201f50:	54c73703          	ld	a4,1356(a4) # ffffffffc0207498 <SBI_SET_TIMER>
ffffffffc0201f54:	88ba                	mv	a7,a4
ffffffffc0201f56:	852a                	mv	a0,a0
ffffffffc0201f58:	85be                	mv	a1,a5
ffffffffc0201f5a:	863e                	mv	a2,a5
ffffffffc0201f5c:	00000073          	ecall
ffffffffc0201f60:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201f62:	8082                	ret

ffffffffc0201f64 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201f64:	4501                	li	a0,0
ffffffffc0201f66:	00005797          	auipc	a5,0x5
ffffffffc0201f6a:	0aa7b783          	ld	a5,170(a5) # ffffffffc0207010 <SBI_CONSOLE_GETCHAR>
ffffffffc0201f6e:	88be                	mv	a7,a5
ffffffffc0201f70:	852a                	mv	a0,a0
ffffffffc0201f72:	85aa                	mv	a1,a0
ffffffffc0201f74:	862a                	mv	a2,a0
ffffffffc0201f76:	00000073          	ecall
ffffffffc0201f7a:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201f7c:	2501                	sext.w	a0,a0
ffffffffc0201f7e:	8082                	ret

ffffffffc0201f80 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201f80:	4781                	li	a5,0
ffffffffc0201f82:	00005717          	auipc	a4,0x5
ffffffffc0201f86:	09e73703          	ld	a4,158(a4) # ffffffffc0207020 <SBI_SHUTDOWN>
ffffffffc0201f8a:	88ba                	mv	a7,a4
ffffffffc0201f8c:	853e                	mv	a0,a5
ffffffffc0201f8e:	85be                	mv	a1,a5
ffffffffc0201f90:	863e                	mv	a2,a5
ffffffffc0201f92:	00000073          	ecall
ffffffffc0201f96:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
	sbi_call(SBI_SHUTDOWN, 0, 0, 0);
ffffffffc0201f98:	8082                	ret

ffffffffc0201f9a <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0201f9a:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0201f9e:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0201fa0:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0201fa2:	cb81                	beqz	a5,ffffffffc0201fb2 <strlen+0x18>
        cnt ++;
ffffffffc0201fa4:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0201fa6:	00a707b3          	add	a5,a4,a0
ffffffffc0201faa:	0007c783          	lbu	a5,0(a5)
ffffffffc0201fae:	fbfd                	bnez	a5,ffffffffc0201fa4 <strlen+0xa>
ffffffffc0201fb0:	8082                	ret
    }
    return cnt;
}
ffffffffc0201fb2:	8082                	ret

ffffffffc0201fb4 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201fb4:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201fb6:	e589                	bnez	a1,ffffffffc0201fc0 <strnlen+0xc>
ffffffffc0201fb8:	a811                	j	ffffffffc0201fcc <strnlen+0x18>
        cnt ++;
ffffffffc0201fba:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201fbc:	00f58863          	beq	a1,a5,ffffffffc0201fcc <strnlen+0x18>
ffffffffc0201fc0:	00f50733          	add	a4,a0,a5
ffffffffc0201fc4:	00074703          	lbu	a4,0(a4)
ffffffffc0201fc8:	fb6d                	bnez	a4,ffffffffc0201fba <strnlen+0x6>
ffffffffc0201fca:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201fcc:	852e                	mv	a0,a1
ffffffffc0201fce:	8082                	ret

ffffffffc0201fd0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201fd0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201fd4:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201fd8:	cb89                	beqz	a5,ffffffffc0201fea <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201fda:	0505                	addi	a0,a0,1
ffffffffc0201fdc:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201fde:	fee789e3          	beq	a5,a4,ffffffffc0201fd0 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201fe2:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201fe6:	9d19                	subw	a0,a0,a4
ffffffffc0201fe8:	8082                	ret
ffffffffc0201fea:	4501                	li	a0,0
ffffffffc0201fec:	bfed                	j	ffffffffc0201fe6 <strcmp+0x16>

ffffffffc0201fee <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201fee:	c20d                	beqz	a2,ffffffffc0202010 <strncmp+0x22>
ffffffffc0201ff0:	962e                	add	a2,a2,a1
ffffffffc0201ff2:	a031                	j	ffffffffc0201ffe <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0201ff4:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201ff6:	00e79a63          	bne	a5,a4,ffffffffc020200a <strncmp+0x1c>
ffffffffc0201ffa:	00b60b63          	beq	a2,a1,ffffffffc0202010 <strncmp+0x22>
ffffffffc0201ffe:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0202002:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0202004:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0202008:	f7f5                	bnez	a5,ffffffffc0201ff4 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020200a:	40e7853b          	subw	a0,a5,a4
}
ffffffffc020200e:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0202010:	4501                	li	a0,0
ffffffffc0202012:	8082                	ret

ffffffffc0202014 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0202014:	00054783          	lbu	a5,0(a0)
ffffffffc0202018:	c799                	beqz	a5,ffffffffc0202026 <strchr+0x12>
        if (*s == c) {
ffffffffc020201a:	00f58763          	beq	a1,a5,ffffffffc0202028 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020201e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0202022:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0202024:	fbfd                	bnez	a5,ffffffffc020201a <strchr+0x6>
    }
    return NULL;
ffffffffc0202026:	4501                	li	a0,0
}
ffffffffc0202028:	8082                	ret

ffffffffc020202a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020202a:	ca01                	beqz	a2,ffffffffc020203a <memset+0x10>
ffffffffc020202c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020202e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0202030:	0785                	addi	a5,a5,1
ffffffffc0202032:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0202036:	fec79de3          	bne	a5,a2,ffffffffc0202030 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020203a:	8082                	ret
