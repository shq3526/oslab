
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00006297          	auipc	t0,0x6
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0206000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00006297          	auipc	t0,0x6
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0206008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
    #计算物理页号：ppn = pa >> 12 ( srli t0, t0, 12 )。

    #设置 satp = (Sv39 模式 8 << 60) | ppn

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号，物理地址右移12位抹除低12位偏移位后得到物理页号
    srli    t0, t0, 12
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
    # 按位或操作把satp的MODE字段，高1000后面全0，计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200034:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB。
    #不加参数， sfence.vma 会刷新整个 TLB 。加上一个虚拟地址，只会刷新这个虚拟地址的映射
    sfence.vma
ffffffffc0200038:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc020003c:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	0d828293          	addi	t0,t0,216 # ffffffffc02000d8 <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020004a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[];
    cprintf("Special kernel symbols:\n");
ffffffffc020004c:	00001517          	auipc	a0,0x1
ffffffffc0200050:	7dc50513          	addi	a0,a0,2012 # ffffffffc0201828 <etext+0x6>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00001517          	auipc	a0,0x1
ffffffffc0200066:	7e650513          	addi	a0,a0,2022 # ffffffffc0201848 <etext+0x26>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00001597          	auipc	a1,0x1
ffffffffc0200072:	7b458593          	addi	a1,a1,1972 # ffffffffc0201822 <etext>
ffffffffc0200076:	00001517          	auipc	a0,0x1
ffffffffc020007a:	7f250513          	addi	a0,a0,2034 # ffffffffc0201868 <etext+0x46>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00006597          	auipc	a1,0x6
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0206018 <b2>
ffffffffc020008a:	00001517          	auipc	a0,0x1
ffffffffc020008e:	7fe50513          	addi	a0,a0,2046 # ffffffffc0201888 <etext+0x66>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00026597          	auipc	a1,0x26
ffffffffc020009a:	fea58593          	addi	a1,a1,-22 # ffffffffc0226080 <end>
ffffffffc020009e:	00002517          	auipc	a0,0x2
ffffffffc02000a2:	80a50513          	addi	a0,a0,-2038 # ffffffffc02018a8 <etext+0x86>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00026597          	auipc	a1,0x26
ffffffffc02000ae:	3d558593          	addi	a1,a1,981 # ffffffffc022647f <end+0x3ff>
ffffffffc02000b2:	00000797          	auipc	a5,0x0
ffffffffc02000b6:	02678793          	addi	a5,a5,38 # ffffffffc02000d8 <kern_init>
ffffffffc02000ba:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000be:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02000c2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000c4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c8:	95be                	add	a1,a1,a5
ffffffffc02000ca:	85a9                	srai	a1,a1,0xa
ffffffffc02000cc:	00001517          	auipc	a0,0x1
ffffffffc02000d0:	7fc50513          	addi	a0,a0,2044 # ffffffffc02018c8 <etext+0xa6>
}
ffffffffc02000d4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000d6:	a89d                	j	ffffffffc020014c <cprintf>

ffffffffc02000d8 <kern_init>:
        kern_init函数在完成一些输出并对lab1实验结果的检查后，
        将进入物理内存管理初始化的工作，调用pmm_init函数完成物理内存的管理
*/
int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc02000d8:	00006517          	auipc	a0,0x6
ffffffffc02000dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0206018 <b2>
ffffffffc02000e0:	00026617          	auipc	a2,0x26
ffffffffc02000e4:	fa060613          	addi	a2,a2,-96 # ffffffffc0226080 <end>
int kern_init(void) {
ffffffffc02000e8:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ee:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000f0:	720010ef          	jal	ra,ffffffffc0201810 <memset>
    dtb_init();
ffffffffc02000f4:	12c000ef          	jal	ra,ffffffffc0200220 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f8:	11e000ef          	jal	ra,ffffffffc0200216 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fc:	00001517          	auipc	a0,0x1
ffffffffc0200100:	7fc50513          	addi	a0,a0,2044 # ffffffffc02018f8 <etext+0xd6>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>

    print_kerninfo();
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010c:	0aa010ef          	jal	ra,ffffffffc02011b6 <pmm_init>
        当程序试图访问一个不存在的页面时，CPU会触发缺页异常，此时会调用缺页中断处理程序
        该程序会在物理内存中分配一个新的页面，并将其映射到虚拟地址空间中。
    */

    /* do nothing */
    while (1)
ffffffffc0200110:	a001                	j	ffffffffc0200110 <kern_init+0x38>

ffffffffc0200112 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200112:	1141                	addi	sp,sp,-16
ffffffffc0200114:	e022                	sd	s0,0(sp)
ffffffffc0200116:	e406                	sd	ra,8(sp)
ffffffffc0200118:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020011a:	0fe000ef          	jal	ra,ffffffffc0200218 <cons_putc>
    (*cnt) ++;
ffffffffc020011e:	401c                	lw	a5,0(s0)
}
ffffffffc0200120:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200122:	2785                	addiw	a5,a5,1
ffffffffc0200124:	c01c                	sw	a5,0(s0)
}
ffffffffc0200126:	6402                	ld	s0,0(sp)
ffffffffc0200128:	0141                	addi	sp,sp,16
ffffffffc020012a:	8082                	ret

ffffffffc020012c <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020012c:	1101                	addi	sp,sp,-32
ffffffffc020012e:	862a                	mv	a2,a0
ffffffffc0200130:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200132:	00000517          	auipc	a0,0x0
ffffffffc0200136:	fe050513          	addi	a0,a0,-32 # ffffffffc0200112 <cputch>
ffffffffc020013a:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc020013c:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020013e:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200140:	2ba010ef          	jal	ra,ffffffffc02013fa <vprintfmt>
    return cnt;
}
ffffffffc0200144:	60e2                	ld	ra,24(sp)
ffffffffc0200146:	4532                	lw	a0,12(sp)
ffffffffc0200148:	6105                	addi	sp,sp,32
ffffffffc020014a:	8082                	ret

ffffffffc020014c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020014c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020014e:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200152:	8e2a                	mv	t3,a0
ffffffffc0200154:	f42e                	sd	a1,40(sp)
ffffffffc0200156:	f832                	sd	a2,48(sp)
ffffffffc0200158:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020015a:	00000517          	auipc	a0,0x0
ffffffffc020015e:	fb850513          	addi	a0,a0,-72 # ffffffffc0200112 <cputch>
ffffffffc0200162:	004c                	addi	a1,sp,4
ffffffffc0200164:	869a                	mv	a3,t1
ffffffffc0200166:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc0200168:	ec06                	sd	ra,24(sp)
ffffffffc020016a:	e0ba                	sd	a4,64(sp)
ffffffffc020016c:	e4be                	sd	a5,72(sp)
ffffffffc020016e:	e8c2                	sd	a6,80(sp)
ffffffffc0200170:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc0200172:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc0200174:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200176:	284010ef          	jal	ra,ffffffffc02013fa <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc020017a:	60e2                	ld	ra,24(sp)
ffffffffc020017c:	4512                	lw	a0,4(sp)
ffffffffc020017e:	6125                	addi	sp,sp,96
ffffffffc0200180:	8082                	ret

ffffffffc0200182 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200182:	1101                	addi	sp,sp,-32
ffffffffc0200184:	e822                	sd	s0,16(sp)
ffffffffc0200186:	ec06                	sd	ra,24(sp)
ffffffffc0200188:	e426                	sd	s1,8(sp)
ffffffffc020018a:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020018c:	00054503          	lbu	a0,0(a0)
ffffffffc0200190:	c51d                	beqz	a0,ffffffffc02001be <cputs+0x3c>
ffffffffc0200192:	0405                	addi	s0,s0,1
ffffffffc0200194:	4485                	li	s1,1
ffffffffc0200196:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200198:	080000ef          	jal	ra,ffffffffc0200218 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020019c:	00044503          	lbu	a0,0(s0)
ffffffffc02001a0:	008487bb          	addw	a5,s1,s0
ffffffffc02001a4:	0405                	addi	s0,s0,1
ffffffffc02001a6:	f96d                	bnez	a0,ffffffffc0200198 <cputs+0x16>
    (*cnt) ++;
ffffffffc02001a8:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001ac:	4529                	li	a0,10
ffffffffc02001ae:	06a000ef          	jal	ra,ffffffffc0200218 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001b2:	60e2                	ld	ra,24(sp)
ffffffffc02001b4:	8522                	mv	a0,s0
ffffffffc02001b6:	6442                	ld	s0,16(sp)
ffffffffc02001b8:	64a2                	ld	s1,8(sp)
ffffffffc02001ba:	6105                	addi	sp,sp,32
ffffffffc02001bc:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001be:	4405                	li	s0,1
ffffffffc02001c0:	b7f5                	j	ffffffffc02001ac <cputs+0x2a>

ffffffffc02001c2 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c2:	00026317          	auipc	t1,0x26
ffffffffc02001c6:	e7630313          	addi	t1,t1,-394 # ffffffffc0226038 <is_panic>
ffffffffc02001ca:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001ce:	715d                	addi	sp,sp,-80
ffffffffc02001d0:	ec06                	sd	ra,24(sp)
ffffffffc02001d2:	e822                	sd	s0,16(sp)
ffffffffc02001d4:	f436                	sd	a3,40(sp)
ffffffffc02001d6:	f83a                	sd	a4,48(sp)
ffffffffc02001d8:	fc3e                	sd	a5,56(sp)
ffffffffc02001da:	e0c2                	sd	a6,64(sp)
ffffffffc02001dc:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001de:	000e0363          	beqz	t3,ffffffffc02001e4 <__panic+0x22>
    vcprintf(fmt, ap);
    cprintf("\n");
    va_end(ap);

panic_dead:
    while (1) {
ffffffffc02001e2:	a001                	j	ffffffffc02001e2 <__panic+0x20>
    is_panic = 1;
ffffffffc02001e4:	4785                	li	a5,1
ffffffffc02001e6:	00f32023          	sw	a5,0(t1)
    va_start(ap, fmt);
ffffffffc02001ea:	8432                	mv	s0,a2
ffffffffc02001ec:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001ee:	862e                	mv	a2,a1
ffffffffc02001f0:	85aa                	mv	a1,a0
ffffffffc02001f2:	00001517          	auipc	a0,0x1
ffffffffc02001f6:	72650513          	addi	a0,a0,1830 # ffffffffc0201918 <etext+0xf6>
    va_start(ap, fmt);
ffffffffc02001fa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001fc:	f51ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200200:	65a2                	ld	a1,8(sp)
ffffffffc0200202:	8522                	mv	a0,s0
ffffffffc0200204:	f29ff0ef          	jal	ra,ffffffffc020012c <vcprintf>
    cprintf("\n");
ffffffffc0200208:	00001517          	auipc	a0,0x1
ffffffffc020020c:	6e850513          	addi	a0,a0,1768 # ffffffffc02018f0 <etext+0xce>
ffffffffc0200210:	f3dff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200214:	b7f9                	j	ffffffffc02001e2 <__panic+0x20>

ffffffffc0200216 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200216:	8082                	ret

ffffffffc0200218 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200218:	0ff57513          	zext.b	a0,a0
ffffffffc020021c:	5600106f          	j	ffffffffc020177c <sbi_console_putchar>

ffffffffc0200220 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200220:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200222:	00001517          	auipc	a0,0x1
ffffffffc0200226:	71650513          	addi	a0,a0,1814 # ffffffffc0201938 <etext+0x116>
void dtb_init(void) {
ffffffffc020022a:	fc86                	sd	ra,120(sp)
ffffffffc020022c:	f8a2                	sd	s0,112(sp)
ffffffffc020022e:	e8d2                	sd	s4,80(sp)
ffffffffc0200230:	f4a6                	sd	s1,104(sp)
ffffffffc0200232:	f0ca                	sd	s2,96(sp)
ffffffffc0200234:	ecce                	sd	s3,88(sp)
ffffffffc0200236:	e4d6                	sd	s5,72(sp)
ffffffffc0200238:	e0da                	sd	s6,64(sp)
ffffffffc020023a:	fc5e                	sd	s7,56(sp)
ffffffffc020023c:	f862                	sd	s8,48(sp)
ffffffffc020023e:	f466                	sd	s9,40(sp)
ffffffffc0200240:	f06a                	sd	s10,32(sp)
ffffffffc0200242:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc0200244:	f09ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200248:	00006597          	auipc	a1,0x6
ffffffffc020024c:	db85b583          	ld	a1,-584(a1) # ffffffffc0206000 <boot_hartid>
ffffffffc0200250:	00001517          	auipc	a0,0x1
ffffffffc0200254:	6f850513          	addi	a0,a0,1784 # ffffffffc0201948 <etext+0x126>
ffffffffc0200258:	ef5ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020025c:	00006417          	auipc	s0,0x6
ffffffffc0200260:	dac40413          	addi	s0,s0,-596 # ffffffffc0206008 <boot_dtb>
ffffffffc0200264:	600c                	ld	a1,0(s0)
ffffffffc0200266:	00001517          	auipc	a0,0x1
ffffffffc020026a:	6f250513          	addi	a0,a0,1778 # ffffffffc0201958 <etext+0x136>
ffffffffc020026e:	edfff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200272:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200276:	00001517          	auipc	a0,0x1
ffffffffc020027a:	6fa50513          	addi	a0,a0,1786 # ffffffffc0201970 <etext+0x14e>
    if (boot_dtb == 0) {
ffffffffc020027e:	120a0463          	beqz	s4,ffffffffc02003a6 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200282:	57f5                	li	a5,-3
ffffffffc0200284:	07fa                	slli	a5,a5,0x1e
ffffffffc0200286:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc020028a:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020028c:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200290:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200292:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200296:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020029a:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020029e:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002a2:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002a6:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002a8:	8ec9                	or	a3,a3,a0
ffffffffc02002aa:	0087979b          	slliw	a5,a5,0x8
ffffffffc02002ae:	1b7d                	addi	s6,s6,-1
ffffffffc02002b0:	0167f7b3          	and	a5,a5,s6
ffffffffc02002b4:	8dd5                	or	a1,a1,a3
ffffffffc02002b6:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc02002b8:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002bc:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc02002be:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfeb9e6d>
ffffffffc02002c2:	10f59163          	bne	a1,a5,ffffffffc02003c4 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02002c6:	471c                	lw	a5,8(a4)
ffffffffc02002c8:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02002ca:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002cc:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02002d0:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02002d4:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002d8:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002dc:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e0:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002e4:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e8:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002ec:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002f0:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002f4:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002f6:	01146433          	or	s0,s0,a7
ffffffffc02002fa:	0086969b          	slliw	a3,a3,0x8
ffffffffc02002fe:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200302:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200304:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200308:	8c49                	or	s0,s0,a0
ffffffffc020030a:	0166f6b3          	and	a3,a3,s6
ffffffffc020030e:	00ca6a33          	or	s4,s4,a2
ffffffffc0200312:	0167f7b3          	and	a5,a5,s6
ffffffffc0200316:	8c55                	or	s0,s0,a3
ffffffffc0200318:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020031c:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020031e:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200320:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200322:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200326:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200328:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020032a:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc020032e:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200330:	00001917          	auipc	s2,0x1
ffffffffc0200334:	69090913          	addi	s2,s2,1680 # ffffffffc02019c0 <etext+0x19e>
ffffffffc0200338:	49bd                	li	s3,15
        switch (token) {
ffffffffc020033a:	4d91                	li	s11,4
ffffffffc020033c:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020033e:	00001497          	auipc	s1,0x1
ffffffffc0200342:	67a48493          	addi	s1,s1,1658 # ffffffffc02019b8 <etext+0x196>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200346:	000a2703          	lw	a4,0(s4)
ffffffffc020034a:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020034e:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200352:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200356:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020035a:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020035e:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200362:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200364:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200368:	0087171b          	slliw	a4,a4,0x8
ffffffffc020036c:	8fd5                	or	a5,a5,a3
ffffffffc020036e:	00eb7733          	and	a4,s6,a4
ffffffffc0200372:	8fd9                	or	a5,a5,a4
ffffffffc0200374:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200376:	09778c63          	beq	a5,s7,ffffffffc020040e <dtb_init+0x1ee>
ffffffffc020037a:	00fbea63          	bltu	s7,a5,ffffffffc020038e <dtb_init+0x16e>
ffffffffc020037e:	07a78663          	beq	a5,s10,ffffffffc02003ea <dtb_init+0x1ca>
ffffffffc0200382:	4709                	li	a4,2
ffffffffc0200384:	00e79763          	bne	a5,a4,ffffffffc0200392 <dtb_init+0x172>
ffffffffc0200388:	4c81                	li	s9,0
ffffffffc020038a:	8a56                	mv	s4,s5
ffffffffc020038c:	bf6d                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020038e:	ffb78ee3          	beq	a5,s11,ffffffffc020038a <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200392:	00001517          	auipc	a0,0x1
ffffffffc0200396:	6a650513          	addi	a0,a0,1702 # ffffffffc0201a38 <etext+0x216>
ffffffffc020039a:	db3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	6d250513          	addi	a0,a0,1746 # ffffffffc0201a70 <etext+0x24e>
}
ffffffffc02003a6:	7446                	ld	s0,112(sp)
ffffffffc02003a8:	70e6                	ld	ra,120(sp)
ffffffffc02003aa:	74a6                	ld	s1,104(sp)
ffffffffc02003ac:	7906                	ld	s2,96(sp)
ffffffffc02003ae:	69e6                	ld	s3,88(sp)
ffffffffc02003b0:	6a46                	ld	s4,80(sp)
ffffffffc02003b2:	6aa6                	ld	s5,72(sp)
ffffffffc02003b4:	6b06                	ld	s6,64(sp)
ffffffffc02003b6:	7be2                	ld	s7,56(sp)
ffffffffc02003b8:	7c42                	ld	s8,48(sp)
ffffffffc02003ba:	7ca2                	ld	s9,40(sp)
ffffffffc02003bc:	7d02                	ld	s10,32(sp)
ffffffffc02003be:	6de2                	ld	s11,24(sp)
ffffffffc02003c0:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02003c2:	b369                	j	ffffffffc020014c <cprintf>
}
ffffffffc02003c4:	7446                	ld	s0,112(sp)
ffffffffc02003c6:	70e6                	ld	ra,120(sp)
ffffffffc02003c8:	74a6                	ld	s1,104(sp)
ffffffffc02003ca:	7906                	ld	s2,96(sp)
ffffffffc02003cc:	69e6                	ld	s3,88(sp)
ffffffffc02003ce:	6a46                	ld	s4,80(sp)
ffffffffc02003d0:	6aa6                	ld	s5,72(sp)
ffffffffc02003d2:	6b06                	ld	s6,64(sp)
ffffffffc02003d4:	7be2                	ld	s7,56(sp)
ffffffffc02003d6:	7c42                	ld	s8,48(sp)
ffffffffc02003d8:	7ca2                	ld	s9,40(sp)
ffffffffc02003da:	7d02                	ld	s10,32(sp)
ffffffffc02003dc:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	5b250513          	addi	a0,a0,1458 # ffffffffc0201990 <etext+0x16e>
}
ffffffffc02003e6:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003e8:	b395                	j	ffffffffc020014c <cprintf>
                int name_len = strlen(name);
ffffffffc02003ea:	8556                	mv	a0,s5
ffffffffc02003ec:	3aa010ef          	jal	ra,ffffffffc0201796 <strlen>
ffffffffc02003f0:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003f2:	4619                	li	a2,6
ffffffffc02003f4:	85a6                	mv	a1,s1
ffffffffc02003f6:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02003f8:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003fa:	3f0010ef          	jal	ra,ffffffffc02017ea <strncmp>
ffffffffc02003fe:	e111                	bnez	a0,ffffffffc0200402 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc0200400:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200402:	0a91                	addi	s5,s5,4
ffffffffc0200404:	9ad2                	add	s5,s5,s4
ffffffffc0200406:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc020040a:	8a56                	mv	s4,s5
ffffffffc020040c:	bf2d                	j	ffffffffc0200346 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc020040e:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200412:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200416:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020041a:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020041e:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200422:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200426:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020042a:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020042e:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200432:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200436:	00eaeab3          	or	s5,s5,a4
ffffffffc020043a:	00fb77b3          	and	a5,s6,a5
ffffffffc020043e:	00faeab3          	or	s5,s5,a5
ffffffffc0200442:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200444:	000c9c63          	bnez	s9,ffffffffc020045c <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200448:	1a82                	slli	s5,s5,0x20
ffffffffc020044a:	00368793          	addi	a5,a3,3
ffffffffc020044e:	020ada93          	srli	s5,s5,0x20
ffffffffc0200452:	9abe                	add	s5,s5,a5
ffffffffc0200454:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200458:	8a56                	mv	s4,s5
ffffffffc020045a:	b5f5                	j	ffffffffc0200346 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc020045c:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200460:	85ca                	mv	a1,s2
ffffffffc0200462:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200464:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200468:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020046c:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200470:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200474:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200478:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020047a:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020047e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200482:	8d59                	or	a0,a0,a4
ffffffffc0200484:	00fb77b3          	and	a5,s6,a5
ffffffffc0200488:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc020048a:	1502                	slli	a0,a0,0x20
ffffffffc020048c:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020048e:	9522                	add	a0,a0,s0
ffffffffc0200490:	33c010ef          	jal	ra,ffffffffc02017cc <strcmp>
ffffffffc0200494:	66a2                	ld	a3,8(sp)
ffffffffc0200496:	f94d                	bnez	a0,ffffffffc0200448 <dtb_init+0x228>
ffffffffc0200498:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200448 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020049c:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02004a0:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02004a4:	00001517          	auipc	a0,0x1
ffffffffc02004a8:	52450513          	addi	a0,a0,1316 # ffffffffc02019c8 <etext+0x1a6>
           fdt32_to_cpu(x >> 32);
ffffffffc02004ac:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b0:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02004b4:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004b8:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02004bc:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c0:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004c4:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c8:	0187d693          	srli	a3,a5,0x18
ffffffffc02004cc:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02004d0:	0087579b          	srliw	a5,a4,0x8
ffffffffc02004d4:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004d8:	0106561b          	srliw	a2,a2,0x10
ffffffffc02004dc:	010f6f33          	or	t5,t5,a6
ffffffffc02004e0:	0187529b          	srliw	t0,a4,0x18
ffffffffc02004e4:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004e8:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ec:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004f0:	0186f6b3          	and	a3,a3,s8
ffffffffc02004f4:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02004f8:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004fc:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200500:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200504:	8361                	srli	a4,a4,0x18
ffffffffc0200506:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020050a:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020050e:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200512:	00cb7633          	and	a2,s6,a2
ffffffffc0200516:	0088181b          	slliw	a6,a6,0x8
ffffffffc020051a:	0085959b          	slliw	a1,a1,0x8
ffffffffc020051e:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200522:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200526:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020052a:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020052e:	0088989b          	slliw	a7,a7,0x8
ffffffffc0200532:	011b78b3          	and	a7,s6,a7
ffffffffc0200536:	005eeeb3          	or	t4,t4,t0
ffffffffc020053a:	00c6e733          	or	a4,a3,a2
ffffffffc020053e:	006c6c33          	or	s8,s8,t1
ffffffffc0200542:	010b76b3          	and	a3,s6,a6
ffffffffc0200546:	00bb7b33          	and	s6,s6,a1
ffffffffc020054a:	01d7e7b3          	or	a5,a5,t4
ffffffffc020054e:	016c6b33          	or	s6,s8,s6
ffffffffc0200552:	01146433          	or	s0,s0,a7
ffffffffc0200556:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc0200558:	1702                	slli	a4,a4,0x20
ffffffffc020055a:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020055c:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020055e:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200560:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200562:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200566:	0167eb33          	or	s6,a5,s6
ffffffffc020056a:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc020056c:	be1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200570:	85a2                	mv	a1,s0
ffffffffc0200572:	00001517          	auipc	a0,0x1
ffffffffc0200576:	47650513          	addi	a0,a0,1142 # ffffffffc02019e8 <etext+0x1c6>
ffffffffc020057a:	bd3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020057e:	014b5613          	srli	a2,s6,0x14
ffffffffc0200582:	85da                	mv	a1,s6
ffffffffc0200584:	00001517          	auipc	a0,0x1
ffffffffc0200588:	47c50513          	addi	a0,a0,1148 # ffffffffc0201a00 <etext+0x1de>
ffffffffc020058c:	bc1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200590:	008b05b3          	add	a1,s6,s0
ffffffffc0200594:	15fd                	addi	a1,a1,-1
ffffffffc0200596:	00001517          	auipc	a0,0x1
ffffffffc020059a:	48a50513          	addi	a0,a0,1162 # ffffffffc0201a20 <etext+0x1fe>
ffffffffc020059e:	bafff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02005a2:	00001517          	auipc	a0,0x1
ffffffffc02005a6:	4ce50513          	addi	a0,a0,1230 # ffffffffc0201a70 <etext+0x24e>
        memory_base = mem_base;
ffffffffc02005aa:	00026797          	auipc	a5,0x26
ffffffffc02005ae:	a887bb23          	sd	s0,-1386(a5) # ffffffffc0226040 <memory_base>
        memory_size = mem_size;
ffffffffc02005b2:	00026797          	auipc	a5,0x26
ffffffffc02005b6:	a967bb23          	sd	s6,-1386(a5) # ffffffffc0226048 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02005ba:	b3f5                	j	ffffffffc02003a6 <dtb_init+0x186>

ffffffffc02005bc <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02005bc:	00026517          	auipc	a0,0x26
ffffffffc02005c0:	a8453503          	ld	a0,-1404(a0) # ffffffffc0226040 <memory_base>
ffffffffc02005c4:	8082                	ret

ffffffffc02005c6 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02005c6:	00026517          	auipc	a0,0x26
ffffffffc02005ca:	a8253503          	ld	a0,-1406(a0) # ffffffffc0226048 <memory_size>
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <buddy_system_nr_free_pages>:
}

// ==== 查询空闲页总数 ====
static size_t buddy_system_nr_free_pages(void) {
    return b2.nr_free;
}
ffffffffc02005d0:	00006517          	auipc	a0,0x6
ffffffffc02005d4:	a5056503          	lwu	a0,-1456(a0) # ffffffffc0206020 <b2+0x8>
ffffffffc02005d8:	8082                	ret

ffffffffc02005da <buddy_system_init>:
    memset(&b2, 0, sizeof(buddy2_t));
ffffffffc02005da:	00020637          	lui	a2,0x20
ffffffffc02005de:	02060613          	addi	a2,a2,32 # 20020 <kern_entry-0xffffffffc01dffe0>
ffffffffc02005e2:	4581                	li	a1,0
ffffffffc02005e4:	00006517          	auipc	a0,0x6
ffffffffc02005e8:	a3450513          	addi	a0,a0,-1484 # ffffffffc0206018 <b2>
ffffffffc02005ec:	2240106f          	j	ffffffffc0201810 <memset>

ffffffffc02005f0 <buddy_system_init_memmap>:
static void buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc02005f0:	1141                	addi	sp,sp,-16
ffffffffc02005f2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02005f4:	18058063          	beqz	a1,ffffffffc0200774 <buddy_system_init_memmap+0x184>
    for (struct Page *p = base; p != base + n; p++) {
ffffffffc02005f8:	00259693          	slli	a3,a1,0x2
ffffffffc02005fc:	96ae                	add	a3,a3,a1
ffffffffc02005fe:	068e                	slli	a3,a3,0x3
ffffffffc0200600:	96aa                	add	a3,a3,a0
ffffffffc0200602:	87aa                	mv	a5,a0
        p->property = -1;
ffffffffc0200604:	567d                	li	a2,-1
    for (struct Page *p = base; p != base + n; p++) {
ffffffffc0200606:	00d50f63          	beq	a0,a3,ffffffffc0200624 <buddy_system_init_memmap+0x34>
        assert(PageReserved(p));
ffffffffc020060a:	6798                	ld	a4,8(a5)
ffffffffc020060c:	8b05                	andi	a4,a4,1
ffffffffc020060e:	14070363          	beqz	a4,ffffffffc0200754 <buddy_system_init_memmap+0x164>
        p->flags = 0;
ffffffffc0200612:	0007b423          	sd	zero,8(a5)
        p->property = -1;
ffffffffc0200616:	cb90                	sw	a2,16(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200618:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p != base + n; p++) {
ffffffffc020061c:	02878793          	addi	a5,a5,40
ffffffffc0200620:	fed795e3          	bne	a5,a3,ffffffffc020060a <buddy_system_init_memmap+0x1a>
    unsigned p2 = Prev_Pow2((unsigned)n);
ffffffffc0200624:	0005871b          	sext.w	a4,a1
    if ((n & (n - 1)) == 0) return n;
ffffffffc0200628:	35fd                	addiw	a1,a1,-1
ffffffffc020062a:	00b777b3          	and	a5,a4,a1
ffffffffc020062e:	2781                	sext.w	a5,a5
ffffffffc0200630:	cbcd                	beqz	a5,ffffffffc02006e2 <buddy_system_init_memmap+0xf2>
    if (n <= 1) return 1;
ffffffffc0200632:	4785                	li	a5,1
ffffffffc0200634:	0cf70463          	beq	a4,a5,ffffffffc02006fc <buddy_system_init_memmap+0x10c>
    n |= n >> 1;
ffffffffc0200638:	0015d79b          	srliw	a5,a1,0x1
ffffffffc020063c:	8fcd                	or	a5,a5,a1
    n |= n >> 2;
ffffffffc020063e:	0027d71b          	srliw	a4,a5,0x2
ffffffffc0200642:	8fd9                	or	a5,a5,a4
    n |= n >> 4;
ffffffffc0200644:	0047d71b          	srliw	a4,a5,0x4
ffffffffc0200648:	8fd9                	or	a5,a5,a4
    n |= n >> 8;
ffffffffc020064a:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020064e:	8fd9                	or	a5,a5,a4
    n |= n >> 16; 
ffffffffc0200650:	0107d71b          	srliw	a4,a5,0x10
ffffffffc0200654:	8fd9                	or	a5,a5,a4
    return n + 1;
ffffffffc0200656:	2785                	addiw	a5,a5,1
ffffffffc0200658:	0017d89b          	srliw	a7,a5,0x1
ffffffffc020065c:	6711                	lui	a4,0x4
    return Next_Pow2(n) >> 1;
ffffffffc020065e:	0017d79b          	srliw	a5,a5,0x1
ffffffffc0200662:	01177463          	bgeu	a4,a7,ffffffffc020066a <buddy_system_init_memmap+0x7a>
ffffffffc0200666:	6791                	lui	a5,0x4
ffffffffc0200668:	6891                	lui	a7,0x4
    unsigned node_size = b2.size * 2;
ffffffffc020066a:	0017959b          	slliw	a1,a5,0x1
    unsigned total = 2 * b2.size - 1;
ffffffffc020066e:	fff5881b          	addiw	a6,a1,-1
    while ((n >>= 1) != 0) k++;
ffffffffc0200672:	0017d79b          	srliw	a5,a5,0x1
    b2.base_idx  = (size_t)(base - pages);
ffffffffc0200676:	00026717          	auipc	a4,0x26
ffffffffc020067a:	9e273703          	ld	a4,-1566(a4) # ffffffffc0226058 <pages>
    b2.size      = p2;
ffffffffc020067e:	00006697          	auipc	a3,0x6
ffffffffc0200682:	99a68693          	addi	a3,a3,-1638 # ffffffffc0206018 <b2>
    b2.base_idx  = (size_t)(base - pages);
ffffffffc0200686:	40e50733          	sub	a4,a0,a4
ffffffffc020068a:	870d                	srai	a4,a4,0x3
ffffffffc020068c:	00002617          	auipc	a2,0x2
ffffffffc0200690:	e4463603          	ld	a2,-444(a2) # ffffffffc02024d0 <error_string+0x38>
    b2.size      = p2;
ffffffffc0200694:	0116a023          	sw	a7,0(a3)
    b2.base_idx  = (size_t)(base - pages);
ffffffffc0200698:	02c70733          	mul	a4,a4,a2
    while ((n >>= 1) != 0) k++;
ffffffffc020069c:	cbc1                	beqz	a5,ffffffffc020072c <buddy_system_init_memmap+0x13c>
    unsigned k = 0;
ffffffffc020069e:	4601                	li	a2,0
    while ((n >>= 1) != 0) k++;
ffffffffc02006a0:	8385                	srli	a5,a5,0x1
ffffffffc02006a2:	2605                	addiw	a2,a2,1
ffffffffc02006a4:	fff5                	bnez	a5,ffffffffc02006a0 <buddy_system_init_memmap+0xb0>
    b2.max_order = Get_Order_Of_2(p2);
ffffffffc02006a6:	c2d0                	sw	a2,4(a3)
    b2.nr_free   = p2;
ffffffffc02006a8:	0116a423          	sw	a7,8(a3)
    b2.base      = base;
ffffffffc02006ac:	ea88                	sd	a0,16(a3)
    b2.base_idx  = (size_t)(base - pages);
ffffffffc02006ae:	ee98                	sd	a4,24(a3)
    for (unsigned i = 0; i < total; ++i) {
ffffffffc02006b0:	00006697          	auipc	a3,0x6
ffffffffc02006b4:	98868693          	addi	a3,a3,-1656 # ffffffffc0206038 <b2+0x20>
    unsigned k = 0;
ffffffffc02006b8:	4781                	li	a5,0
        if (IS_POWER_OF_2(i + 1)) node_size >>= 1;
ffffffffc02006ba:	0007871b          	sext.w	a4,a5
ffffffffc02006be:	2785                	addiw	a5,a5,1
ffffffffc02006c0:	8f7d                	and	a4,a4,a5
ffffffffc02006c2:	2701                	sext.w	a4,a4
ffffffffc02006c4:	e319                	bnez	a4,ffffffffc02006ca <buddy_system_init_memmap+0xda>
ffffffffc02006c6:	0015d59b          	srliw	a1,a1,0x1
        b2.longest[i] = node_size;
ffffffffc02006ca:	c28c                	sw	a1,0(a3)
    for (unsigned i = 0; i < total; ++i) {
ffffffffc02006cc:	0691                	addi	a3,a3,4
ffffffffc02006ce:	ff07e6e3          	bltu	a5,a6,ffffffffc02006ba <buddy_system_init_memmap+0xca>
    SetPageProperty(base);
ffffffffc02006d2:	651c                	ld	a5,8(a0)
}
ffffffffc02006d4:	60a2                	ld	ra,8(sp)
    base->property = (int)b2.max_order;
ffffffffc02006d6:	c910                	sw	a2,16(a0)
    SetPageProperty(base);
ffffffffc02006d8:	0027e793          	ori	a5,a5,2
ffffffffc02006dc:	e51c                	sd	a5,8(a0)
}
ffffffffc02006de:	0141                	addi	sp,sp,16
ffffffffc02006e0:	8082                	ret
ffffffffc02006e2:	6691                	lui	a3,0x4
ffffffffc02006e4:	87ba                	mv	a5,a4
ffffffffc02006e6:	04e6ed63          	bltu	a3,a4,ffffffffc0200740 <buddy_system_init_memmap+0x150>
    unsigned node_size = b2.size * 2;
ffffffffc02006ea:	0017959b          	slliw	a1,a5,0x1
ffffffffc02006ee:	0007889b          	sext.w	a7,a5
    unsigned total = 2 * b2.size - 1;
ffffffffc02006f2:	fff5881b          	addiw	a6,a1,-1
    while ((n >>= 1) != 0) k++;
ffffffffc02006f6:	0017d79b          	srliw	a5,a5,0x1
ffffffffc02006fa:	bfb5                	j	ffffffffc0200676 <buddy_system_init_memmap+0x86>
    b2.base_idx  = (size_t)(base - pages);
ffffffffc02006fc:	00026717          	auipc	a4,0x26
ffffffffc0200700:	95c73703          	ld	a4,-1700(a4) # ffffffffc0226058 <pages>
ffffffffc0200704:	40e50733          	sub	a4,a0,a4
ffffffffc0200708:	00002797          	auipc	a5,0x2
ffffffffc020070c:	dc87b783          	ld	a5,-568(a5) # ffffffffc02024d0 <error_string+0x38>
ffffffffc0200710:	870d                	srai	a4,a4,0x3
ffffffffc0200712:	02f70733          	mul	a4,a4,a5
ffffffffc0200716:	587d                	li	a6,-1
    b2.size      = p2;
ffffffffc0200718:	00006797          	auipc	a5,0x6
ffffffffc020071c:	9007a023          	sw	zero,-1792(a5) # ffffffffc0206018 <b2>
    b2.base_idx  = (size_t)(base - pages);
ffffffffc0200720:	4581                	li	a1,0
ffffffffc0200722:	4881                	li	a7,0
ffffffffc0200724:	00006697          	auipc	a3,0x6
ffffffffc0200728:	8f468693          	addi	a3,a3,-1804 # ffffffffc0206018 <b2>
    b2.max_order = Get_Order_Of_2(p2);
ffffffffc020072c:	00006797          	auipc	a5,0x6
ffffffffc0200730:	8e07a823          	sw	zero,-1808(a5) # ffffffffc020601c <b2+0x4>
    b2.nr_free   = p2;
ffffffffc0200734:	0116a423          	sw	a7,8(a3)
    b2.base      = base;
ffffffffc0200738:	ea88                	sd	a0,16(a3)
    b2.base_idx  = (size_t)(base - pages);
ffffffffc020073a:	ee98                	sd	a4,24(a3)
    unsigned k = 0;
ffffffffc020073c:	4601                	li	a2,0
ffffffffc020073e:	bf8d                	j	ffffffffc02006b0 <buddy_system_init_memmap+0xc0>
ffffffffc0200740:	6791                	lui	a5,0x4
    unsigned node_size = b2.size * 2;
ffffffffc0200742:	0017959b          	slliw	a1,a5,0x1
ffffffffc0200746:	0007889b          	sext.w	a7,a5
    unsigned total = 2 * b2.size - 1;
ffffffffc020074a:	fff5881b          	addiw	a6,a1,-1
    while ((n >>= 1) != 0) k++;
ffffffffc020074e:	0017d79b          	srliw	a5,a5,0x1
ffffffffc0200752:	b715                	j	ffffffffc0200676 <buddy_system_init_memmap+0x86>
        assert(PageReserved(p));
ffffffffc0200754:	00001697          	auipc	a3,0x1
ffffffffc0200758:	36c68693          	addi	a3,a3,876 # ffffffffc0201ac0 <etext+0x29e>
ffffffffc020075c:	00001617          	auipc	a2,0x1
ffffffffc0200760:	32c60613          	addi	a2,a2,812 # ffffffffc0201a88 <etext+0x266>
ffffffffc0200764:	05400593          	li	a1,84
ffffffffc0200768:	00001517          	auipc	a0,0x1
ffffffffc020076c:	33850513          	addi	a0,a0,824 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0200770:	a53ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc0200774:	00002697          	auipc	a3,0x2
ffffffffc0200778:	8e468693          	addi	a3,a3,-1820 # ffffffffc0202058 <etext+0x836>
ffffffffc020077c:	00001617          	auipc	a2,0x1
ffffffffc0200780:	30c60613          	addi	a2,a2,780 # ffffffffc0201a88 <etext+0x266>
ffffffffc0200784:	05000593          	li	a1,80
ffffffffc0200788:	00001517          	auipc	a0,0x1
ffffffffc020078c:	31850513          	addi	a0,a0,792 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0200790:	a33ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200794 <show_buddy_array.constprop.0>:
// 复杂度：对每个阶 ord 仅扫描该阶所在层的节点个数（约 size / 2^ord）
// ==== 显示：分层聚合 + 每层 Longest（从根到叶）====
// ==== 显示：分层聚合 + 每层 Longest（从根到叶）====
// 关键修正：跳过任何“落在某个已占用叶子（longest==0）的子树里面”的节点，
// 避免把初始化残留的更小阶节点误当成有效空闲块。
static void show_buddy_array(int left, int right) {
ffffffffc0200794:	715d                	addi	sp,sp,-80
ffffffffc0200796:	e85a                	sd	s6,16(sp)
    if (left < 0) left = 0;
    if (right > (int)b2.max_order) right = (int)b2.max_order;
ffffffffc0200798:	00006b17          	auipc	s6,0x6
ffffffffc020079c:	880b0b13          	addi	s6,s6,-1920 # ffffffffc0206018 <b2>
ffffffffc02007a0:	004b2783          	lw	a5,4(s6)
static void show_buddy_array(int left, int right) {
ffffffffc02007a4:	e0a2                	sd	s0,64(sp)
ffffffffc02007a6:	e486                	sd	ra,72(sp)
ffffffffc02007a8:	fc26                	sd	s1,56(sp)
ffffffffc02007aa:	f84a                	sd	s2,48(sp)
ffffffffc02007ac:	f44e                	sd	s3,40(sp)
ffffffffc02007ae:	f052                	sd	s4,32(sp)
ffffffffc02007b0:	ec56                	sd	s5,24(sp)
ffffffffc02007b2:	e45e                	sd	s7,8(sp)
ffffffffc02007b4:	e062                	sd	s8,0(sp)
ffffffffc02007b6:	4739                	li	a4,14
ffffffffc02007b8:	4439                	li	s0,14
ffffffffc02007ba:	00f74463          	blt	a4,a5,ffffffffc02007c2 <show_buddy_array.constprop.0+0x2e>
ffffffffc02007be:	0007841b          	sext.w	s0,a5
    if (left > right) { int t = left; left = right; right = t; }
ffffffffc02007c2:	4481                	li	s1,0
ffffffffc02007c4:	0007d463          	bgez	a5,ffffffffc02007cc <show_buddy_array.constprop.0+0x38>
ffffffffc02007c8:	84a2                	mv	s1,s0
ffffffffc02007ca:	4401                	li	s0,0

    cprintf("------------------按层级统计（从根到叶）:------------------\n");
ffffffffc02007cc:	00001517          	auipc	a0,0x1
ffffffffc02007d0:	30450513          	addi	a0,a0,772 # ffffffffc0201ad0 <etext+0x2ae>
ffffffffc02007d4:	979ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        return 0;
    }

    int any_printed = 0;

    for (int ord = (int)b2.max_order; ord >= 0; --ord) {
ffffffffc02007d8:	004b2b83          	lw	s7,4(s6)
    int any_printed = 0;
ffffffffc02007dc:	4281                	li	t0,0
    for (int ord = (int)b2.max_order; ord >= 0; --ord) {
ffffffffc02007de:	160bc463          	bltz	s7,ffffffffc0200946 <show_buddy_array.constprop.0+0x1b2>
        if (ord < left || ord > right) continue;

        unsigned block_size = (1u << ord);
ffffffffc02007e2:	4905                	li	s2,1
                pages_sum += block_size;
            }
        }

        if (blocks > 0 || level_longest > 0) {
            cprintf("No.%d 层：整块数=%u，合计空闲页=%u（每块 %u 页） | 本层Longest=%u页",
ffffffffc02007e4:	00001a97          	auipc	s5,0x1
ffffffffc02007e8:	3a4a8a93          	addi	s5,s5,932 # ffffffffc0201b88 <etext+0x366>
                    ord, blocks, pages_sum, block_size, level_longest);
            if (level_longest) cprintf("（~No.%u）\n", Get_Order_Of_2(level_longest));
            else cprintf("\n");
ffffffffc02007ec:	00001a17          	auipc	s4,0x1
ffffffffc02007f0:	104a0a13          	addi	s4,s4,260 # ffffffffc02018f0 <etext+0xce>
            if (level_longest) cprintf("（~No.%u）\n", Get_Order_Of_2(level_longest));
ffffffffc02007f4:	00001997          	auipc	s3,0x1
ffffffffc02007f8:	3ec98993          	addi	s3,s3,1004 # ffffffffc0201be0 <etext+0x3be>
        if (ord < left || ord > right) continue;
ffffffffc02007fc:	009bc463          	blt	s7,s1,ffffffffc0200804 <show_buddy_array.constprop.0+0x70>
ffffffffc0200800:	05745063          	bge	s0,s7,ffffffffc0200840 <show_buddy_array.constprop.0+0xac>
    for (int ord = (int)b2.max_order; ord >= 0; --ord) {
ffffffffc0200804:	3bfd                	addiw	s7,s7,-1
ffffffffc0200806:	57fd                	li	a5,-1
ffffffffc0200808:	fefb9ae3          	bne	s7,a5,ffffffffc02007fc <show_buddy_array.constprop.0+0x68>
            any_printed = 1;
        }
    }

    if (!any_printed) {
ffffffffc020080c:	12028d63          	beqz	t0,ffffffffc0200946 <show_buddy_array.constprop.0+0x1b2>
        cprintf("（无可按层统计的整块或连续空闲，可能空闲被高度碎片化或根可用空间极小）\n");
    }
    cprintf("全局剩余空闲页：%u\n", b2.nr_free);
ffffffffc0200810:	008b2583          	lw	a1,8(s6)
ffffffffc0200814:	00001517          	auipc	a0,0x1
ffffffffc0200818:	3dc50513          	addi	a0,a0,988 # ffffffffc0201bf0 <etext+0x3ce>
ffffffffc020081c:	931ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("------------------显示完成!------------------\n\n");
}
ffffffffc0200820:	6406                	ld	s0,64(sp)
ffffffffc0200822:	60a6                	ld	ra,72(sp)
ffffffffc0200824:	74e2                	ld	s1,56(sp)
ffffffffc0200826:	7942                	ld	s2,48(sp)
ffffffffc0200828:	79a2                	ld	s3,40(sp)
ffffffffc020082a:	7a02                	ld	s4,32(sp)
ffffffffc020082c:	6ae2                	ld	s5,24(sp)
ffffffffc020082e:	6b42                	ld	s6,16(sp)
ffffffffc0200830:	6ba2                	ld	s7,8(sp)
ffffffffc0200832:	6c02                	ld	s8,0(sp)
    cprintf("------------------显示完成!------------------\n\n");
ffffffffc0200834:	00001517          	auipc	a0,0x1
ffffffffc0200838:	3dc50513          	addi	a0,a0,988 # ffffffffc0201c10 <etext+0x3ee>
}
ffffffffc020083c:	6161                	addi	sp,sp,80
    cprintf("------------------显示完成!------------------\n\n");
ffffffffc020083e:	b239                	j	ffffffffc020014c <cprintf>
        unsigned level = b2.max_order - (unsigned)ord;   // 根=0
ffffffffc0200840:	004b2e83          	lw	t4,4(s6)
        unsigned block_size = (1u << ord);
ffffffffc0200844:	0179173b          	sllw	a4,s2,s7
        unsigned level = b2.max_order - (unsigned)ord;   // 根=0
ffffffffc0200848:	417e8ebb          	subw	t4,t4,s7
        unsigned last  = (1u << (level + 1)) - 2;
ffffffffc020084c:	001e8f1b          	addiw	t5,t4,1
ffffffffc0200850:	01e91f3b          	sllw	t5,s2,t5
        unsigned first = (1u << level) - 1;
ffffffffc0200854:	01d91ebb          	sllw	t4,s2,t4
ffffffffc0200858:	fffe8e1b          	addiw	t3,t4,-1
        unsigned last  = (1u << (level + 1)) - 2;
ffffffffc020085c:	3f79                	addiw	t5,t5,-2
        for (unsigned i = first; i <= last; ++i) {
ffffffffc020085e:	fbcf63e3          	bltu	t5,t3,ffffffffc0200804 <show_buddy_array.constprop.0+0x70>
            unsigned anc_size = b2.size >> level; // 祖先/自身块大小
ffffffffc0200862:	000b2303          	lw	t1,0(s6)
                    if (b2.longest[p] == (block_size << 1)) continue;
ffffffffc0200866:	00171f9b          	slliw	t6,a4,0x1
        unsigned pages_sum = 0;
ffffffffc020086a:	4681                	li	a3,0
        unsigned blocks = 0;
ffffffffc020086c:	4601                	li	a2,0
        unsigned level_longest = 0;
ffffffffc020086e:	4c01                	li	s8,0
    int any_printed = 0;
ffffffffc0200870:	88f2                	mv	a7,t3
            unsigned level = 0, x = idx + 1;
ffffffffc0200872:	0018851b          	addiw	a0,a7,1
            while (x >>= 1) level++;
ffffffffc0200876:	0015559b          	srliw	a1,a0,0x1
ffffffffc020087a:	0015581b          	srliw	a6,a0,0x1
ffffffffc020087e:	c99d                	beqz	a1,ffffffffc02008b4 <show_buddy_array.constprop.0+0x120>
            unsigned level = 0, x = idx + 1;
ffffffffc0200880:	4501                	li	a0,0
            while (x >>= 1) level++;
ffffffffc0200882:	8185                	srli	a1,a1,0x1
ffffffffc0200884:	2505                	addiw	a0,a0,1
ffffffffc0200886:	fdf5                	bnez	a1,ffffffffc0200882 <show_buddy_array.constprop.0+0xee>
            unsigned anc_size = b2.size >> level; // 祖先/自身块大小
ffffffffc0200888:	00a3553b          	srlw	a0,t1,a0
            if (b2.longest[idx] == 0 && anc_size >= node_size) return 1;
ffffffffc020088c:	02089793          	slli	a5,a7,0x20
ffffffffc0200890:	01e7d593          	srli	a1,a5,0x1e
ffffffffc0200894:	95da                	add	a1,a1,s6
ffffffffc0200896:	518c                	lw	a1,32(a1)
ffffffffc0200898:	e199                	bnez	a1,ffffffffc020089e <show_buddy_array.constprop.0+0x10a>
ffffffffc020089a:	02e57d63          	bgeu	a0,a4,ffffffffc02008d4 <show_buddy_array.constprop.0+0x140>
            if (idx == 0) break;
ffffffffc020089e:	00088d63          	beqz	a7,ffffffffc02008b8 <show_buddy_array.constprop.0+0x124>
            idx = PARENT(idx);
ffffffffc02008a2:	fff8089b          	addiw	a7,a6,-1
            unsigned level = 0, x = idx + 1;
ffffffffc02008a6:	0018851b          	addiw	a0,a7,1
            while (x >>= 1) level++;
ffffffffc02008aa:	0015559b          	srliw	a1,a0,0x1
ffffffffc02008ae:	0015581b          	srliw	a6,a0,0x1
ffffffffc02008b2:	f5f9                	bnez	a1,ffffffffc0200880 <show_buddy_array.constprop.0+0xec>
ffffffffc02008b4:	851a                	mv	a0,t1
ffffffffc02008b6:	bfd9                	j	ffffffffc020088c <show_buddy_array.constprop.0+0xf8>
            if (b2.longest[i] > level_longest) level_longest = b2.longest[i];
ffffffffc02008b8:	020e1793          	slli	a5,t3,0x20
ffffffffc02008bc:	01e7d593          	srli	a1,a5,0x1e
ffffffffc02008c0:	95da                	add	a1,a1,s6
ffffffffc02008c2:	518c                	lw	a1,32(a1)
ffffffffc02008c4:	852e                	mv	a0,a1
ffffffffc02008c6:	0185f363          	bgeu	a1,s8,ffffffffc02008cc <show_buddy_array.constprop.0+0x138>
ffffffffc02008ca:	8562                	mv	a0,s8
ffffffffc02008cc:	00050c1b          	sext.w	s8,a0
            if (b2.longest[i] == block_size) {
ffffffffc02008d0:	00b70963          	beq	a4,a1,ffffffffc02008e2 <show_buddy_array.constprop.0+0x14e>
        for (unsigned i = first; i <= last; ++i) {
ffffffffc02008d4:	001e859b          	addiw	a1,t4,1
ffffffffc02008d8:	2e05                	addiw	t3,t3,1
ffffffffc02008da:	03df6863          	bltu	t5,t4,ffffffffc020090a <show_buddy_array.constprop.0+0x176>
ffffffffc02008de:	8eae                	mv	t4,a1
ffffffffc02008e0:	bf41                	j	ffffffffc0200870 <show_buddy_array.constprop.0+0xdc>
                if (i != 0) {
ffffffffc02008e2:	000e0d63          	beqz	t3,ffffffffc02008fc <show_buddy_array.constprop.0+0x168>
                    unsigned p = PARENT(i);
ffffffffc02008e6:	001ed59b          	srliw	a1,t4,0x1
ffffffffc02008ea:	35fd                	addiw	a1,a1,-1
                    if (b2.longest[p] == (block_size << 1)) continue;
ffffffffc02008ec:	02059793          	slli	a5,a1,0x20
ffffffffc02008f0:	01e7d593          	srli	a1,a5,0x1e
ffffffffc02008f4:	95da                	add	a1,a1,s6
ffffffffc02008f6:	518c                	lw	a1,32(a1)
ffffffffc02008f8:	fdf58ee3          	beq	a1,t6,ffffffffc02008d4 <show_buddy_array.constprop.0+0x140>
                blocks++;
ffffffffc02008fc:	2605                	addiw	a2,a2,1
                pages_sum += block_size;
ffffffffc02008fe:	9eb9                	addw	a3,a3,a4
        for (unsigned i = first; i <= last; ++i) {
ffffffffc0200900:	001e859b          	addiw	a1,t4,1
ffffffffc0200904:	2e05                	addiw	t3,t3,1
ffffffffc0200906:	fddf7ce3          	bgeu	t5,t4,ffffffffc02008de <show_buddy_array.constprop.0+0x14a>
        if (blocks > 0 || level_longest > 0) {
ffffffffc020090a:	018665b3          	or	a1,a2,s8
ffffffffc020090e:	ee058be3          	beqz	a1,ffffffffc0200804 <show_buddy_array.constprop.0+0x70>
            cprintf("No.%d 层：整块数=%u，合计空闲页=%u（每块 %u 页） | 本层Longest=%u页",
ffffffffc0200912:	87e2                	mv	a5,s8
ffffffffc0200914:	85de                	mv	a1,s7
ffffffffc0200916:	8556                	mv	a0,s5
ffffffffc0200918:	835ff0ef          	jal	ra,ffffffffc020014c <cprintf>
            if (level_longest) cprintf("（~No.%u）\n", Get_Order_Of_2(level_longest));
ffffffffc020091c:	000c1763          	bnez	s8,ffffffffc020092a <show_buddy_array.constprop.0+0x196>
            else cprintf("\n");
ffffffffc0200920:	8552                	mv	a0,s4
ffffffffc0200922:	82bff0ef          	jal	ra,ffffffffc020014c <cprintf>
            any_printed = 1;
ffffffffc0200926:	4285                	li	t0,1
ffffffffc0200928:	bdf1                	j	ffffffffc0200804 <show_buddy_array.constprop.0+0x70>
    while ((n >>= 1) != 0) k++;
ffffffffc020092a:	001c559b          	srliw	a1,s8,0x1
ffffffffc020092e:	c599                	beqz	a1,ffffffffc020093c <show_buddy_array.constprop.0+0x1a8>
    unsigned k = 0;
ffffffffc0200930:	4781                	li	a5,0
    while ((n >>= 1) != 0) k++;
ffffffffc0200932:	0015d59b          	srliw	a1,a1,0x1
ffffffffc0200936:	2785                	addiw	a5,a5,1
ffffffffc0200938:	fded                	bnez	a1,ffffffffc0200932 <show_buddy_array.constprop.0+0x19e>
ffffffffc020093a:	85be                	mv	a1,a5
            if (level_longest) cprintf("（~No.%u）\n", Get_Order_Of_2(level_longest));
ffffffffc020093c:	854e                	mv	a0,s3
ffffffffc020093e:	80fff0ef          	jal	ra,ffffffffc020014c <cprintf>
            any_printed = 1;
ffffffffc0200942:	4285                	li	t0,1
ffffffffc0200944:	b5c1                	j	ffffffffc0200804 <show_buddy_array.constprop.0+0x70>
        cprintf("（无可按层统计的整块或连续空闲，可能空闲被高度碎片化或根可用空间极小）\n");
ffffffffc0200946:	00001517          	auipc	a0,0x1
ffffffffc020094a:	1d250513          	addi	a0,a0,466 # ffffffffc0201b18 <etext+0x2f6>
ffffffffc020094e:	ffeff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200952:	bd7d                	j	ffffffffc0200810 <show_buddy_array.constprop.0+0x7c>

ffffffffc0200954 <buddy_system_check>:
    cprintf("p3的虚拟地址为:0x%016lx.\n", p3);
    free_pages(p3, (size_t)max_pages);
    show_buddy_array(0, MAX_BUDDY_ORDER);
}

static void buddy_system_check(void) {
ffffffffc0200954:	715d                	addi	sp,sp,-80
    cprintf("BEGIN TO TEST!\n");
ffffffffc0200956:	00001517          	auipc	a0,0x1
ffffffffc020095a:	2f250513          	addi	a0,a0,754 # ffffffffc0201c48 <etext+0x426>
static void buddy_system_check(void) {
ffffffffc020095e:	e486                	sd	ra,72(sp)
ffffffffc0200960:	e0a2                	sd	s0,64(sp)
ffffffffc0200962:	f44e                	sd	s3,40(sp)
ffffffffc0200964:	f052                	sd	s4,32(sp)
ffffffffc0200966:	ec56                	sd	s5,24(sp)
ffffffffc0200968:	fc26                	sd	s1,56(sp)
ffffffffc020096a:	f84a                	sd	s2,48(sp)
ffffffffc020096c:	e85a                	sd	s6,16(sp)
ffffffffc020096e:	e45e                	sd	s7,8(sp)
    cprintf("BEGIN TO TEST!\n");
ffffffffc0200970:	fdcff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("CHECK OUR EASY ALLOC CONDITION:\n");
ffffffffc0200974:	00001517          	auipc	a0,0x1
ffffffffc0200978:	2e450513          	addi	a0,a0,740 # ffffffffc0201c58 <etext+0x436>
ffffffffc020097c:	fd0ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("当前总的空闲块的数量为：%d\n", (int)b2.nr_free);
ffffffffc0200980:	00005417          	auipc	s0,0x5
ffffffffc0200984:	69840413          	addi	s0,s0,1688 # ffffffffc0206018 <b2>
ffffffffc0200988:	440c                	lw	a1,8(s0)
ffffffffc020098a:	00001517          	auipc	a0,0x1
ffffffffc020098e:	2f650513          	addi	a0,a0,758 # ffffffffc0201c80 <etext+0x45e>
ffffffffc0200992:	fbaff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("1.p0请求8页\n");
ffffffffc0200996:	00001517          	auipc	a0,0x1
ffffffffc020099a:	31250513          	addi	a0,a0,786 # ffffffffc0201ca8 <etext+0x486>
ffffffffc020099e:	faeff0ef          	jal	ra,ffffffffc020014c <cprintf>
    p0 = alloc_pages(8);
ffffffffc02009a2:	4521                	li	a0,8
ffffffffc02009a4:	7fa000ef          	jal	ra,ffffffffc020119e <alloc_pages>
ffffffffc02009a8:	8a2a                	mv	s4,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc02009aa:	debff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    cprintf("2.p1请求8页\n");
ffffffffc02009ae:	00001517          	auipc	a0,0x1
ffffffffc02009b2:	30a50513          	addi	a0,a0,778 # ffffffffc0201cb8 <etext+0x496>
ffffffffc02009b6:	f96ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    p1 = alloc_pages(8);
ffffffffc02009ba:	4521                	li	a0,8
ffffffffc02009bc:	7e2000ef          	jal	ra,ffffffffc020119e <alloc_pages>
ffffffffc02009c0:	89aa                	mv	s3,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc02009c2:	dd3ff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    cprintf("3.p2请求8页\n");
ffffffffc02009c6:	00001517          	auipc	a0,0x1
ffffffffc02009ca:	30250513          	addi	a0,a0,770 # ffffffffc0201cc8 <etext+0x4a6>
ffffffffc02009ce:	f7eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    p2 = alloc_pages(8);
ffffffffc02009d2:	4521                	li	a0,8
ffffffffc02009d4:	7ca000ef          	jal	ra,ffffffffc020119e <alloc_pages>
ffffffffc02009d8:	8aaa                	mv	s5,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc02009da:	dbbff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    cprintf("p0的虚拟地址为:0x%016lx.\n", p0);
ffffffffc02009de:	85d2                	mv	a1,s4
ffffffffc02009e0:	00001517          	auipc	a0,0x1
ffffffffc02009e4:	2f850513          	addi	a0,a0,760 # ffffffffc0201cd8 <etext+0x4b6>
ffffffffc02009e8:	f64ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("p1的虚拟地址为:0x%016lx.\n", p1);
ffffffffc02009ec:	85ce                	mv	a1,s3
ffffffffc02009ee:	00001517          	auipc	a0,0x1
ffffffffc02009f2:	30a50513          	addi	a0,a0,778 # ffffffffc0201cf8 <etext+0x4d6>
ffffffffc02009f6:	f56ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("p2的虚拟地址为:0x%016lx.\n", p2);
ffffffffc02009fa:	85d6                	mv	a1,s5
ffffffffc02009fc:	00001517          	auipc	a0,0x1
ffffffffc0200a00:	31c50513          	addi	a0,a0,796 # ffffffffc0201d18 <etext+0x4f6>
ffffffffc0200a04:	f48ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200a08:	333a0a63          	beq	s4,s3,ffffffffc0200d3c <buddy_system_check+0x3e8>
ffffffffc0200a0c:	335a0863          	beq	s4,s5,ffffffffc0200d3c <buddy_system_check+0x3e8>
ffffffffc0200a10:	33598663          	beq	s3,s5,ffffffffc0200d3c <buddy_system_check+0x3e8>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200a14:	000a2783          	lw	a5,0(s4)
ffffffffc0200a18:	36079263          	bnez	a5,ffffffffc0200d7c <buddy_system_check+0x428>
ffffffffc0200a1c:	0009a783          	lw	a5,0(s3)
ffffffffc0200a20:	34079e63          	bnez	a5,ffffffffc0200d7c <buddy_system_check+0x428>
ffffffffc0200a24:	000aa783          	lw	a5,0(s5)
ffffffffc0200a28:	34079a63          	bnez	a5,ffffffffc0200d7c <buddy_system_check+0x428>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a2c:	00025b97          	auipc	s7,0x25
ffffffffc0200a30:	62cb8b93          	addi	s7,s7,1580 # ffffffffc0226058 <pages>
ffffffffc0200a34:	000bb783          	ld	a5,0(s7)
ffffffffc0200a38:	00002497          	auipc	s1,0x2
ffffffffc0200a3c:	a984b483          	ld	s1,-1384(s1) # ffffffffc02024d0 <error_string+0x38>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200a40:	00025b17          	auipc	s6,0x25
ffffffffc0200a44:	610b0b13          	addi	s6,s6,1552 # ffffffffc0226050 <npage>
ffffffffc0200a48:	40fa0733          	sub	a4,s4,a5
ffffffffc0200a4c:	870d                	srai	a4,a4,0x3
ffffffffc0200a4e:	02970733          	mul	a4,a4,s1
ffffffffc0200a52:	000b3683          	ld	a3,0(s6)
ffffffffc0200a56:	00002917          	auipc	s2,0x2
ffffffffc0200a5a:	a8293903          	ld	s2,-1406(s2) # ffffffffc02024d8 <nbase>
ffffffffc0200a5e:	06b2                	slli	a3,a3,0xc
ffffffffc0200a60:	974a                	add	a4,a4,s2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a62:	0732                	slli	a4,a4,0xc
ffffffffc0200a64:	3ed77c63          	bgeu	a4,a3,ffffffffc0200e5c <buddy_system_check+0x508>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a68:	40f98733          	sub	a4,s3,a5
ffffffffc0200a6c:	870d                	srai	a4,a4,0x3
ffffffffc0200a6e:	02970733          	mul	a4,a4,s1
ffffffffc0200a72:	974a                	add	a4,a4,s2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a74:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200a76:	34d77363          	bgeu	a4,a3,ffffffffc0200dbc <buddy_system_check+0x468>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a7a:	40fa87b3          	sub	a5,s5,a5
ffffffffc0200a7e:	878d                	srai	a5,a5,0x3
ffffffffc0200a80:	029787b3          	mul	a5,a5,s1
ffffffffc0200a84:	97ca                	add	a5,a5,s2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a86:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200a88:	38d7fa63          	bgeu	a5,a3,ffffffffc0200e1c <buddy_system_check+0x4c8>
    cprintf("CHECK OUR EASY FREE CONDITION:\n");
ffffffffc0200a8c:	00001517          	auipc	a0,0x1
ffffffffc0200a90:	37450513          	addi	a0,a0,884 # ffffffffc0201e00 <etext+0x5de>
ffffffffc0200a94:	eb8ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("释放p0...\n");
ffffffffc0200a98:	00001517          	auipc	a0,0x1
ffffffffc0200a9c:	38850513          	addi	a0,a0,904 # ffffffffc0201e20 <etext+0x5fe>
ffffffffc0200aa0:	eacff0ef          	jal	ra,ffffffffc020014c <cprintf>
    free_pages(p0, 8);
ffffffffc0200aa4:	8552                	mv	a0,s4
ffffffffc0200aa6:	45a1                	li	a1,8
ffffffffc0200aa8:	702000ef          	jal	ra,ffffffffc02011aa <free_pages>
    cprintf("释放p0后,总空闲块数目为:%d\n", (int)b2.nr_free);
ffffffffc0200aac:	440c                	lw	a1,8(s0)
ffffffffc0200aae:	00001517          	auipc	a0,0x1
ffffffffc0200ab2:	38250513          	addi	a0,a0,898 # ffffffffc0201e30 <etext+0x60e>
ffffffffc0200ab6:	e96ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200aba:	cdbff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    cprintf("释放p1...\n");
ffffffffc0200abe:	00001517          	auipc	a0,0x1
ffffffffc0200ac2:	39a50513          	addi	a0,a0,922 # ffffffffc0201e58 <etext+0x636>
ffffffffc0200ac6:	e86ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    free_pages(p1, 8);
ffffffffc0200aca:	854e                	mv	a0,s3
ffffffffc0200acc:	45a1                	li	a1,8
ffffffffc0200ace:	6dc000ef          	jal	ra,ffffffffc02011aa <free_pages>
    cprintf("释放p1后,总空闲块数目为:%d\n", (int)b2.nr_free);
ffffffffc0200ad2:	440c                	lw	a1,8(s0)
ffffffffc0200ad4:	00001517          	auipc	a0,0x1
ffffffffc0200ad8:	39450513          	addi	a0,a0,916 # ffffffffc0201e68 <etext+0x646>
ffffffffc0200adc:	e70ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200ae0:	cb5ff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    cprintf("释放p2...\n");
ffffffffc0200ae4:	00001517          	auipc	a0,0x1
ffffffffc0200ae8:	3ac50513          	addi	a0,a0,940 # ffffffffc0201e90 <etext+0x66e>
ffffffffc0200aec:	e60ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    free_pages(p2, 8);
ffffffffc0200af0:	8556                	mv	a0,s5
ffffffffc0200af2:	45a1                	li	a1,8
ffffffffc0200af4:	6b6000ef          	jal	ra,ffffffffc02011aa <free_pages>
    cprintf("释放p2后,总空闲块数目为:%d\n", (int)b2.nr_free);
ffffffffc0200af8:	440c                	lw	a1,8(s0)
ffffffffc0200afa:	00001517          	auipc	a0,0x1
ffffffffc0200afe:	3a650513          	addi	a0,a0,934 # ffffffffc0201ea0 <etext+0x67e>
ffffffffc0200b02:	e4aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200b06:	c8fff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    cprintf("CHECK OUR DIFFICULT ALLOC CONDITION:\n");
ffffffffc0200b0a:	00001517          	auipc	a0,0x1
ffffffffc0200b0e:	3be50513          	addi	a0,a0,958 # ffffffffc0201ec8 <etext+0x6a6>
ffffffffc0200b12:	e3aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("当前总的空闲块的数量为：%d\n", (int)b2.nr_free);
ffffffffc0200b16:	440c                	lw	a1,8(s0)
ffffffffc0200b18:	00001517          	auipc	a0,0x1
ffffffffc0200b1c:	16850513          	addi	a0,a0,360 # ffffffffc0201c80 <etext+0x45e>
ffffffffc0200b20:	e2cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("1.p0请求20页\n");
ffffffffc0200b24:	00001517          	auipc	a0,0x1
ffffffffc0200b28:	3cc50513          	addi	a0,a0,972 # ffffffffc0201ef0 <etext+0x6ce>
ffffffffc0200b2c:	e20ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    p0 = alloc_pages(20);
ffffffffc0200b30:	4551                	li	a0,20
ffffffffc0200b32:	66c000ef          	jal	ra,ffffffffc020119e <alloc_pages>
ffffffffc0200b36:	89aa                	mv	s3,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200b38:	c5dff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    cprintf("2.p1请求40页\n");
ffffffffc0200b3c:	00001517          	auipc	a0,0x1
ffffffffc0200b40:	3cc50513          	addi	a0,a0,972 # ffffffffc0201f08 <etext+0x6e6>
ffffffffc0200b44:	e08ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    p1 = alloc_pages(40);
ffffffffc0200b48:	02800513          	li	a0,40
ffffffffc0200b4c:	652000ef          	jal	ra,ffffffffc020119e <alloc_pages>
ffffffffc0200b50:	8aaa                	mv	s5,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200b52:	c43ff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    cprintf("3.p2请求200页\n");
ffffffffc0200b56:	00001517          	auipc	a0,0x1
ffffffffc0200b5a:	3ca50513          	addi	a0,a0,970 # ffffffffc0201f20 <etext+0x6fe>
ffffffffc0200b5e:	deeff0ef          	jal	ra,ffffffffc020014c <cprintf>
    p2 = alloc_pages(200);
ffffffffc0200b62:	0c800513          	li	a0,200
ffffffffc0200b66:	638000ef          	jal	ra,ffffffffc020119e <alloc_pages>
ffffffffc0200b6a:	8a2a                	mv	s4,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200b6c:	c29ff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    cprintf("p0的虚拟地址为:0x%016lx.\n", p0);
ffffffffc0200b70:	85ce                	mv	a1,s3
ffffffffc0200b72:	00001517          	auipc	a0,0x1
ffffffffc0200b76:	16650513          	addi	a0,a0,358 # ffffffffc0201cd8 <etext+0x4b6>
ffffffffc0200b7a:	dd2ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("p1的虚拟地址为:0x%016lx.\n", p1);
ffffffffc0200b7e:	85d6                	mv	a1,s5
ffffffffc0200b80:	00001517          	auipc	a0,0x1
ffffffffc0200b84:	17850513          	addi	a0,a0,376 # ffffffffc0201cf8 <etext+0x4d6>
ffffffffc0200b88:	dc4ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("p2的虚拟地址为:0x%016lx.\n", p2);
ffffffffc0200b8c:	85d2                	mv	a1,s4
ffffffffc0200b8e:	00001517          	auipc	a0,0x1
ffffffffc0200b92:	18a50513          	addi	a0,a0,394 # ffffffffc0201d18 <etext+0x4f6>
ffffffffc0200b96:	db6ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b9a:	1d598163          	beq	s3,s5,ffffffffc0200d5c <buddy_system_check+0x408>
ffffffffc0200b9e:	1b498f63          	beq	s3,s4,ffffffffc0200d5c <buddy_system_check+0x408>
ffffffffc0200ba2:	1b4a8d63          	beq	s5,s4,ffffffffc0200d5c <buddy_system_check+0x408>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ba6:	0009a783          	lw	a5,0(s3)
ffffffffc0200baa:	1e079963          	bnez	a5,ffffffffc0200d9c <buddy_system_check+0x448>
ffffffffc0200bae:	000aa783          	lw	a5,0(s5)
ffffffffc0200bb2:	1e079563          	bnez	a5,ffffffffc0200d9c <buddy_system_check+0x448>
ffffffffc0200bb6:	000a2783          	lw	a5,0(s4)
ffffffffc0200bba:	1e079163          	bnez	a5,ffffffffc0200d9c <buddy_system_check+0x448>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bbe:	000bb783          	ld	a5,0(s7)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bc2:	000b3683          	ld	a3,0(s6)
ffffffffc0200bc6:	40f98733          	sub	a4,s3,a5
ffffffffc0200bca:	870d                	srai	a4,a4,0x3
ffffffffc0200bcc:	02970733          	mul	a4,a4,s1
ffffffffc0200bd0:	06b2                	slli	a3,a3,0xc
ffffffffc0200bd2:	974a                	add	a4,a4,s2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bd4:	0732                	slli	a4,a4,0xc
ffffffffc0200bd6:	26d77363          	bgeu	a4,a3,ffffffffc0200e3c <buddy_system_check+0x4e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bda:	40fa8733          	sub	a4,s5,a5
ffffffffc0200bde:	870d                	srai	a4,a4,0x3
ffffffffc0200be0:	02970733          	mul	a4,a4,s1
ffffffffc0200be4:	974a                	add	a4,a4,s2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200be6:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200be8:	1ed77a63          	bgeu	a4,a3,ffffffffc0200ddc <buddy_system_check+0x488>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bec:	40fa07b3          	sub	a5,s4,a5
ffffffffc0200bf0:	878d                	srai	a5,a5,0x3
ffffffffc0200bf2:	029787b3          	mul	a5,a5,s1
ffffffffc0200bf6:	97ca                	add	a5,a5,s2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bf8:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bfa:	20d7f163          	bgeu	a5,a3,ffffffffc0200dfc <buddy_system_check+0x4a8>
    cprintf("CHECK OUR EASY DIFFICULT CONDITION:\n");
ffffffffc0200bfe:	00001517          	auipc	a0,0x1
ffffffffc0200c02:	33a50513          	addi	a0,a0,826 # ffffffffc0201f38 <etext+0x716>
ffffffffc0200c06:	d46ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("释放p0...\n");
ffffffffc0200c0a:	00001517          	auipc	a0,0x1
ffffffffc0200c0e:	21650513          	addi	a0,a0,534 # ffffffffc0201e20 <etext+0x5fe>
ffffffffc0200c12:	d3aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    free_pages(p0, 20);
ffffffffc0200c16:	45d1                	li	a1,20
ffffffffc0200c18:	854e                	mv	a0,s3
ffffffffc0200c1a:	590000ef          	jal	ra,ffffffffc02011aa <free_pages>
    cprintf("释放p0后,总空闲块数目为:%d\n", (int)b2.nr_free);
ffffffffc0200c1e:	440c                	lw	a1,8(s0)
ffffffffc0200c20:	00001517          	auipc	a0,0x1
ffffffffc0200c24:	21050513          	addi	a0,a0,528 # ffffffffc0201e30 <etext+0x60e>
ffffffffc0200c28:	d24ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200c2c:	b69ff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    cprintf("释放p1...\n");
ffffffffc0200c30:	00001517          	auipc	a0,0x1
ffffffffc0200c34:	22850513          	addi	a0,a0,552 # ffffffffc0201e58 <etext+0x636>
ffffffffc0200c38:	d14ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    free_pages(p1, 40);
ffffffffc0200c3c:	02800593          	li	a1,40
ffffffffc0200c40:	8556                	mv	a0,s5
ffffffffc0200c42:	568000ef          	jal	ra,ffffffffc02011aa <free_pages>
    cprintf("释放p1后,总空闲块数目为:%d\n", (int)b2.nr_free);
ffffffffc0200c46:	440c                	lw	a1,8(s0)
ffffffffc0200c48:	00001517          	auipc	a0,0x1
ffffffffc0200c4c:	22050513          	addi	a0,a0,544 # ffffffffc0201e68 <etext+0x646>
ffffffffc0200c50:	cfcff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200c54:	b41ff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    cprintf("释放p2...\n");
ffffffffc0200c58:	00001517          	auipc	a0,0x1
ffffffffc0200c5c:	23850513          	addi	a0,a0,568 # ffffffffc0201e90 <etext+0x66e>
ffffffffc0200c60:	cecff0ef          	jal	ra,ffffffffc020014c <cprintf>
    free_pages(p2, 200);
ffffffffc0200c64:	0c800593          	li	a1,200
ffffffffc0200c68:	8552                	mv	a0,s4
ffffffffc0200c6a:	540000ef          	jal	ra,ffffffffc02011aa <free_pages>
    cprintf("释放p2后,总空闲块数目为:%d\n", (int)b2.nr_free);
ffffffffc0200c6e:	440c                	lw	a1,8(s0)
ffffffffc0200c70:	00001517          	auipc	a0,0x1
ffffffffc0200c74:	23050513          	addi	a0,a0,560 # ffffffffc0201ea0 <etext+0x67e>
ffffffffc0200c78:	cd4ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200c7c:	b19ff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    struct Page *p3 = alloc_pages(1);
ffffffffc0200c80:	4505                	li	a0,1
ffffffffc0200c82:	51c000ef          	jal	ra,ffffffffc020119e <alloc_pages>
ffffffffc0200c86:	84aa                	mv	s1,a0
    cprintf("分配p3之后(1页)\n");
ffffffffc0200c88:	00001517          	auipc	a0,0x1
ffffffffc0200c8c:	2d850513          	addi	a0,a0,728 # ffffffffc0201f60 <etext+0x73e>
ffffffffc0200c90:	cbcff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200c94:	b01ff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    if (p3 == NULL) {
ffffffffc0200c98:	c8b5                	beqz	s1,ffffffffc0200d0c <buddy_system_check+0x3b8>
    cprintf("p3的虚拟地址为:0x%016lx.\n", p3);
ffffffffc0200c9a:	85a6                	mv	a1,s1
ffffffffc0200c9c:	00001517          	auipc	a0,0x1
ffffffffc0200ca0:	30c50513          	addi	a0,a0,780 # ffffffffc0201fa8 <etext+0x786>
ffffffffc0200ca4:	ca8ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    free_pages(p3, 1);
ffffffffc0200ca8:	4585                	li	a1,1
ffffffffc0200caa:	8526                	mv	a0,s1
ffffffffc0200cac:	4fe000ef          	jal	ra,ffffffffc02011aa <free_pages>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200cb0:	ae5ff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    size_t max_pages = (1u << b2.max_order);
ffffffffc0200cb4:	404c                	lw	a1,4(s0)
ffffffffc0200cb6:	4405                	li	s0,1
ffffffffc0200cb8:	00b4143b          	sllw	s0,s0,a1
ffffffffc0200cbc:	02041913          	slli	s2,s0,0x20
ffffffffc0200cc0:	02095913          	srli	s2,s2,0x20
    struct Page *p3 = alloc_pages(max_pages);
ffffffffc0200cc4:	854a                	mv	a0,s2
ffffffffc0200cc6:	4d8000ef          	jal	ra,ffffffffc020119e <alloc_pages>
ffffffffc0200cca:	84aa                	mv	s1,a0
    cprintf("分配p3之后(%d页)\n", (int)max_pages);
ffffffffc0200ccc:	85a2                	mv	a1,s0
ffffffffc0200cce:	00001517          	auipc	a0,0x1
ffffffffc0200cd2:	2fa50513          	addi	a0,a0,762 # ffffffffc0201fc8 <etext+0x7a6>
ffffffffc0200cd6:	c76ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200cda:	abbff0ef          	jal	ra,ffffffffc0200794 <show_buddy_array.constprop.0>
    if (p3 == NULL) {
ffffffffc0200cde:	cc95                	beqz	s1,ffffffffc0200d1a <buddy_system_check+0x3c6>
    cprintf("p3的虚拟地址为:0x%016lx.\n", p3);
ffffffffc0200ce0:	85a6                	mv	a1,s1
ffffffffc0200ce2:	00001517          	auipc	a0,0x1
ffffffffc0200ce6:	2c650513          	addi	a0,a0,710 # ffffffffc0201fa8 <etext+0x786>
ffffffffc0200cea:	c62ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    free_pages(p3, (size_t)max_pages);
ffffffffc0200cee:	85ca                	mv	a1,s2
ffffffffc0200cf0:	8526                	mv	a0,s1
ffffffffc0200cf2:	4b8000ef          	jal	ra,ffffffffc02011aa <free_pages>
    buddy_system_check_easy();
    buddy_system_check_difficult();
    buddy_system_check_min();
    buddy_system_check_max();
}
ffffffffc0200cf6:	6406                	ld	s0,64(sp)
ffffffffc0200cf8:	60a6                	ld	ra,72(sp)
ffffffffc0200cfa:	74e2                	ld	s1,56(sp)
ffffffffc0200cfc:	7942                	ld	s2,48(sp)
ffffffffc0200cfe:	79a2                	ld	s3,40(sp)
ffffffffc0200d00:	7a02                	ld	s4,32(sp)
ffffffffc0200d02:	6ae2                	ld	s5,24(sp)
ffffffffc0200d04:	6b42                	ld	s6,16(sp)
ffffffffc0200d06:	6ba2                	ld	s7,8(sp)
ffffffffc0200d08:	6161                	addi	sp,sp,80
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200d0a:	b469                	j	ffffffffc0200794 <show_buddy_array.constprop.0>
        cprintf("WARN: 分配1页失败，跳过回收测试。\n");
ffffffffc0200d0c:	00001517          	auipc	a0,0x1
ffffffffc0200d10:	26c50513          	addi	a0,a0,620 # ffffffffc0201f78 <etext+0x756>
ffffffffc0200d14:	c38ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        return;
ffffffffc0200d18:	bf71                	j	ffffffffc0200cb4 <buddy_system_check+0x360>
        cprintf("WARN: 无法分配最大块（%d页），可能被碎片/已分配占用，跳过回收测试。\n", (int)max_pages);
ffffffffc0200d1a:	85a2                	mv	a1,s0
}
ffffffffc0200d1c:	6406                	ld	s0,64(sp)
ffffffffc0200d1e:	60a6                	ld	ra,72(sp)
ffffffffc0200d20:	74e2                	ld	s1,56(sp)
ffffffffc0200d22:	7942                	ld	s2,48(sp)
ffffffffc0200d24:	79a2                	ld	s3,40(sp)
ffffffffc0200d26:	7a02                	ld	s4,32(sp)
ffffffffc0200d28:	6ae2                	ld	s5,24(sp)
ffffffffc0200d2a:	6b42                	ld	s6,16(sp)
ffffffffc0200d2c:	6ba2                	ld	s7,8(sp)
        cprintf("WARN: 无法分配最大块（%d页），可能被碎片/已分配占用，跳过回收测试。\n", (int)max_pages);
ffffffffc0200d2e:	00001517          	auipc	a0,0x1
ffffffffc0200d32:	2b250513          	addi	a0,a0,690 # ffffffffc0201fe0 <etext+0x7be>
}
ffffffffc0200d36:	6161                	addi	sp,sp,80
        cprintf("WARN: 无法分配最大块（%d页），可能被碎片/已分配占用，跳过回收测试。\n", (int)max_pages);
ffffffffc0200d38:	c14ff06f          	j	ffffffffc020014c <cprintf>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200d3c:	00001697          	auipc	a3,0x1
ffffffffc0200d40:	ffc68693          	addi	a3,a3,-4 # ffffffffc0201d38 <etext+0x516>
ffffffffc0200d44:	00001617          	auipc	a2,0x1
ffffffffc0200d48:	d4460613          	addi	a2,a2,-700 # ffffffffc0201a88 <etext+0x266>
ffffffffc0200d4c:	14000593          	li	a1,320
ffffffffc0200d50:	00001517          	auipc	a0,0x1
ffffffffc0200d54:	d5050513          	addi	a0,a0,-688 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0200d58:	c6aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200d5c:	00001697          	auipc	a3,0x1
ffffffffc0200d60:	fdc68693          	addi	a3,a3,-36 # ffffffffc0201d38 <etext+0x516>
ffffffffc0200d64:	00001617          	auipc	a2,0x1
ffffffffc0200d68:	d2460613          	addi	a2,a2,-732 # ffffffffc0201a88 <etext+0x266>
ffffffffc0200d6c:	16e00593          	li	a1,366
ffffffffc0200d70:	00001517          	auipc	a0,0x1
ffffffffc0200d74:	d3050513          	addi	a0,a0,-720 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0200d78:	c4aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200d7c:	00001697          	auipc	a3,0x1
ffffffffc0200d80:	fe468693          	addi	a3,a3,-28 # ffffffffc0201d60 <etext+0x53e>
ffffffffc0200d84:	00001617          	auipc	a2,0x1
ffffffffc0200d88:	d0460613          	addi	a2,a2,-764 # ffffffffc0201a88 <etext+0x266>
ffffffffc0200d8c:	14100593          	li	a1,321
ffffffffc0200d90:	00001517          	auipc	a0,0x1
ffffffffc0200d94:	d1050513          	addi	a0,a0,-752 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0200d98:	c2aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200d9c:	00001697          	auipc	a3,0x1
ffffffffc0200da0:	fc468693          	addi	a3,a3,-60 # ffffffffc0201d60 <etext+0x53e>
ffffffffc0200da4:	00001617          	auipc	a2,0x1
ffffffffc0200da8:	ce460613          	addi	a2,a2,-796 # ffffffffc0201a88 <etext+0x266>
ffffffffc0200dac:	16f00593          	li	a1,367
ffffffffc0200db0:	00001517          	auipc	a0,0x1
ffffffffc0200db4:	cf050513          	addi	a0,a0,-784 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0200db8:	c0aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200dbc:	00001697          	auipc	a3,0x1
ffffffffc0200dc0:	00468693          	addi	a3,a3,4 # ffffffffc0201dc0 <etext+0x59e>
ffffffffc0200dc4:	00001617          	auipc	a2,0x1
ffffffffc0200dc8:	cc460613          	addi	a2,a2,-828 # ffffffffc0201a88 <etext+0x266>
ffffffffc0200dcc:	14400593          	li	a1,324
ffffffffc0200dd0:	00001517          	auipc	a0,0x1
ffffffffc0200dd4:	cd050513          	addi	a0,a0,-816 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0200dd8:	beaff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ddc:	00001697          	auipc	a3,0x1
ffffffffc0200de0:	fe468693          	addi	a3,a3,-28 # ffffffffc0201dc0 <etext+0x59e>
ffffffffc0200de4:	00001617          	auipc	a2,0x1
ffffffffc0200de8:	ca460613          	addi	a2,a2,-860 # ffffffffc0201a88 <etext+0x266>
ffffffffc0200dec:	17200593          	li	a1,370
ffffffffc0200df0:	00001517          	auipc	a0,0x1
ffffffffc0200df4:	cb050513          	addi	a0,a0,-848 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0200df8:	bcaff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200dfc:	00001697          	auipc	a3,0x1
ffffffffc0200e00:	fe468693          	addi	a3,a3,-28 # ffffffffc0201de0 <etext+0x5be>
ffffffffc0200e04:	00001617          	auipc	a2,0x1
ffffffffc0200e08:	c8460613          	addi	a2,a2,-892 # ffffffffc0201a88 <etext+0x266>
ffffffffc0200e0c:	17300593          	li	a1,371
ffffffffc0200e10:	00001517          	auipc	a0,0x1
ffffffffc0200e14:	c9050513          	addi	a0,a0,-880 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0200e18:	baaff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e1c:	00001697          	auipc	a3,0x1
ffffffffc0200e20:	fc468693          	addi	a3,a3,-60 # ffffffffc0201de0 <etext+0x5be>
ffffffffc0200e24:	00001617          	auipc	a2,0x1
ffffffffc0200e28:	c6460613          	addi	a2,a2,-924 # ffffffffc0201a88 <etext+0x266>
ffffffffc0200e2c:	14500593          	li	a1,325
ffffffffc0200e30:	00001517          	auipc	a0,0x1
ffffffffc0200e34:	c7050513          	addi	a0,a0,-912 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0200e38:	b8aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e3c:	00001697          	auipc	a3,0x1
ffffffffc0200e40:	f6468693          	addi	a3,a3,-156 # ffffffffc0201da0 <etext+0x57e>
ffffffffc0200e44:	00001617          	auipc	a2,0x1
ffffffffc0200e48:	c4460613          	addi	a2,a2,-956 # ffffffffc0201a88 <etext+0x266>
ffffffffc0200e4c:	17100593          	li	a1,369
ffffffffc0200e50:	00001517          	auipc	a0,0x1
ffffffffc0200e54:	c5050513          	addi	a0,a0,-944 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0200e58:	b6aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e5c:	00001697          	auipc	a3,0x1
ffffffffc0200e60:	f4468693          	addi	a3,a3,-188 # ffffffffc0201da0 <etext+0x57e>
ffffffffc0200e64:	00001617          	auipc	a2,0x1
ffffffffc0200e68:	c2460613          	addi	a2,a2,-988 # ffffffffc0201a88 <etext+0x266>
ffffffffc0200e6c:	14300593          	li	a1,323
ffffffffc0200e70:	00001517          	auipc	a0,0x1
ffffffffc0200e74:	c3050513          	addi	a0,a0,-976 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0200e78:	b4aff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200e7c <buddy_system_free_pages>:
static void buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200e7c:	1141                	addi	sp,sp,-16
ffffffffc0200e7e:	e406                	sd	ra,8(sp)
    assert(base != NULL && n > 0);
ffffffffc0200e80:	14050e63          	beqz	a0,ffffffffc0200fdc <buddy_system_free_pages+0x160>
ffffffffc0200e84:	14058c63          	beqz	a1,ffffffffc0200fdc <buddy_system_free_pages+0x160>
    unsigned size = Next_Pow2((unsigned)n);
ffffffffc0200e88:	0005889b          	sext.w	a7,a1
    if (n <= 1) return 1;
ffffffffc0200e8c:	4785                	li	a5,1
ffffffffc0200e8e:	1517f363          	bgeu	a5,a7,ffffffffc0200fd4 <buddy_system_free_pages+0x158>
    if ((n & (n - 1)) == 0) return n;
ffffffffc0200e92:	fff8871b          	addiw	a4,a7,-1
ffffffffc0200e96:	00e8f7b3          	and	a5,a7,a4
ffffffffc0200e9a:	2781                	sext.w	a5,a5
ffffffffc0200e9c:	c795                	beqz	a5,ffffffffc0200ec8 <buddy_system_free_pages+0x4c>
    n |= n >> 1;
ffffffffc0200e9e:	0017589b          	srliw	a7,a4,0x1
ffffffffc0200ea2:	00e8e8b3          	or	a7,a7,a4
    n |= n >> 2;
ffffffffc0200ea6:	0028d79b          	srliw	a5,a7,0x2
ffffffffc0200eaa:	00f8e8b3          	or	a7,a7,a5
    n |= n >> 4;
ffffffffc0200eae:	0048d79b          	srliw	a5,a7,0x4
ffffffffc0200eb2:	00f8e8b3          	or	a7,a7,a5
    n |= n >> 8;
ffffffffc0200eb6:	0088d79b          	srliw	a5,a7,0x8
ffffffffc0200eba:	00f8e8b3          	or	a7,a7,a5
    n |= n >> 16; 
ffffffffc0200ebe:	0108d79b          	srliw	a5,a7,0x10
ffffffffc0200ec2:	00f8e8b3          	or	a7,a7,a5
    return n + 1;
ffffffffc0200ec6:	2885                	addiw	a7,a7,1
    size_t idx = (size_t)(base - pages);
ffffffffc0200ec8:	00025597          	auipc	a1,0x25
ffffffffc0200ecc:	1905b583          	ld	a1,400(a1) # ffffffffc0226058 <pages>
ffffffffc0200ed0:	40b505b3          	sub	a1,a0,a1
ffffffffc0200ed4:	00001797          	auipc	a5,0x1
ffffffffc0200ed8:	5fc7b783          	ld	a5,1532(a5) # ffffffffc02024d0 <error_string+0x38>
ffffffffc0200edc:	858d                	srai	a1,a1,0x3
ffffffffc0200ede:	02f585b3          	mul	a1,a1,a5
    if (size > b2.size) size = b2.size;
ffffffffc0200ee2:	00005817          	auipc	a6,0x5
ffffffffc0200ee6:	13680813          	addi	a6,a6,310 # ffffffffc0206018 <b2>
    assert(idx >= b2.base_idx);
ffffffffc0200eea:	01883783          	ld	a5,24(a6)
    if (size > b2.size) size = b2.size;
ffffffffc0200eee:	00082503          	lw	a0,0(a6)
    assert(idx >= b2.base_idx);
ffffffffc0200ef2:	12f5e563          	bltu	a1,a5,ffffffffc020101c <buddy_system_free_pages+0x1a0>
    unsigned offset = (unsigned)(idx - b2.base_idx);
ffffffffc0200ef6:	40f587bb          	subw	a5,a1,a5
ffffffffc0200efa:	873e                	mv	a4,a5
    assert(offset < b2.size);
ffffffffc0200efc:	10a7f063          	bgeu	a5,a0,ffffffffc0200ffc <buddy_system_free_pages+0x180>
    unsigned index = offset + b2.size - 1;
ffffffffc0200f00:	fff5079b          	addiw	a5,a0,-1
ffffffffc0200f04:	9fb9                	addw	a5,a5,a4
    while (b2.longest[index] != 0) {
ffffffffc0200f06:	02079693          	slli	a3,a5,0x20
ffffffffc0200f0a:	01e6d713          	srli	a4,a3,0x1e
ffffffffc0200f0e:	9742                	add	a4,a4,a6
ffffffffc0200f10:	5318                	lw	a4,32(a4)
ffffffffc0200f12:	c379                	beqz	a4,ffffffffc0200fd8 <buddy_system_free_pages+0x15c>
        if (index == 0) return; // 整棵树空，或重复释放，直接返回
ffffffffc0200f14:	cfcd                	beqz	a5,ffffffffc0200fce <buddy_system_free_pages+0x152>
        node_size <<= 1;
ffffffffc0200f16:	4709                	li	a4,2
ffffffffc0200f18:	a021                	j	ffffffffc0200f20 <buddy_system_free_pages+0xa4>
ffffffffc0200f1a:	0017171b          	slliw	a4,a4,0x1
        if (index == 0) return; // 整棵树空，或重复释放，直接返回
ffffffffc0200f1e:	cbc5                	beqz	a5,ffffffffc0200fce <buddy_system_free_pages+0x152>
        index = PARENT(index);
ffffffffc0200f20:	2785                	addiw	a5,a5,1
ffffffffc0200f22:	0017d79b          	srliw	a5,a5,0x1
ffffffffc0200f26:	37fd                	addiw	a5,a5,-1
    while (b2.longest[index] != 0) {
ffffffffc0200f28:	02079613          	slli	a2,a5,0x20
ffffffffc0200f2c:	01e65693          	srli	a3,a2,0x1e
ffffffffc0200f30:	96c2                	add	a3,a3,a6
ffffffffc0200f32:	5294                	lw	a3,32(a3)
ffffffffc0200f34:	f2fd                	bnez	a3,ffffffffc0200f1a <buddy_system_free_pages+0x9e>
    b2.longest[index] = node_size;
ffffffffc0200f36:	02079613          	slli	a2,a5,0x20
ffffffffc0200f3a:	01e65693          	srli	a3,a2,0x1e
ffffffffc0200f3e:	96c2                	add	a3,a3,a6
ffffffffc0200f40:	d298                	sw	a4,32(a3)
    while (index) {
ffffffffc0200f42:	cfa9                	beqz	a5,ffffffffc0200f9c <buddy_system_free_pages+0x120>
        index = PARENT(index);
ffffffffc0200f44:	2785                	addiw	a5,a5,1
ffffffffc0200f46:	0017d69b          	srliw	a3,a5,0x1
ffffffffc0200f4a:	36fd                	addiw	a3,a3,-1
        unsigned ri = RIGHT_LEAF(index);
ffffffffc0200f4c:	9bf9                	andi	a5,a5,-2
        unsigned li = LEFT_LEAF(index);
ffffffffc0200f4e:	0016961b          	slliw	a2,a3,0x1
        unsigned right_longest = b2.longest[ri];
ffffffffc0200f52:	1782                	slli	a5,a5,0x20
        unsigned li = LEFT_LEAF(index);
ffffffffc0200f54:	2605                	addiw	a2,a2,1
        unsigned right_longest = b2.longest[ri];
ffffffffc0200f56:	9381                	srli	a5,a5,0x20
        unsigned left_longest  = b2.longest[li];
ffffffffc0200f58:	02061313          	slli	t1,a2,0x20
        unsigned right_longest = b2.longest[ri];
ffffffffc0200f5c:	07a1                	addi	a5,a5,8
        unsigned left_longest  = b2.longest[li];
ffffffffc0200f5e:	01e35613          	srli	a2,t1,0x1e
        unsigned right_longest = b2.longest[ri];
ffffffffc0200f62:	078a                	slli	a5,a5,0x2
        unsigned left_longest  = b2.longest[li];
ffffffffc0200f64:	9642                	add	a2,a2,a6
        unsigned right_longest = b2.longest[ri];
ffffffffc0200f66:	97c2                	add	a5,a5,a6
        unsigned left_longest  = b2.longest[li];
ffffffffc0200f68:	02062303          	lw	t1,32(a2)
        unsigned right_longest = b2.longest[ri];
ffffffffc0200f6c:	0007ae03          	lw	t3,0(a5)
        node_size <<= 1;
ffffffffc0200f70:	0017171b          	slliw	a4,a4,0x1
        index = PARENT(index);
ffffffffc0200f74:	0006879b          	sext.w	a5,a3
        if (left_longest + right_longest == node_size) {
ffffffffc0200f78:	01c30ebb          	addw	t4,t1,t3
ffffffffc0200f7c:	863a                	mv	a2,a4
ffffffffc0200f7e:	00ee8863          	beq	t4,a4,ffffffffc0200f8e <buddy_system_free_pages+0x112>
            b2.longest[index] = (left_longest > right_longest) ? left_longest : right_longest;
ffffffffc0200f82:	0003061b          	sext.w	a2,t1
ffffffffc0200f86:	01c37463          	bgeu	t1,t3,ffffffffc0200f8e <buddy_system_free_pages+0x112>
ffffffffc0200f8a:	000e061b          	sext.w	a2,t3
ffffffffc0200f8e:	02069313          	slli	t1,a3,0x20
ffffffffc0200f92:	01e35693          	srli	a3,t1,0x1e
ffffffffc0200f96:	96c2                	add	a3,a3,a6
ffffffffc0200f98:	d290                	sw	a2,32(a3)
    while (index) {
ffffffffc0200f9a:	f7cd                	bnez	a5,ffffffffc0200f44 <buddy_system_free_pages+0xc8>
ffffffffc0200f9c:	872a                	mv	a4,a0
ffffffffc0200f9e:	02a8e663          	bltu	a7,a0,ffffffffc0200fca <buddy_system_free_pages+0x14e>
    b2.nr_free += size;
ffffffffc0200fa2:	00882783          	lw	a5,8(a6)
}
ffffffffc0200fa6:	60a2                	ld	ra,8(sp)
    cprintf("Buddy System算法将释放第NO.%d页开始的共%d页\n", page2ppn(base), (int)size);
ffffffffc0200fa8:	0007061b          	sext.w	a2,a4
    b2.nr_free += size;
ffffffffc0200fac:	9fb9                	addw	a5,a5,a4
ffffffffc0200fae:	00f82423          	sw	a5,8(a6)
    cprintf("Buddy System算法将释放第NO.%d页开始的共%d页\n", page2ppn(base), (int)size);
ffffffffc0200fb2:	00001717          	auipc	a4,0x1
ffffffffc0200fb6:	52673703          	ld	a4,1318(a4) # ffffffffc02024d8 <nbase>
ffffffffc0200fba:	95ba                	add	a1,a1,a4
ffffffffc0200fbc:	00001517          	auipc	a0,0x1
ffffffffc0200fc0:	0d450513          	addi	a0,a0,212 # ffffffffc0202090 <etext+0x86e>
}
ffffffffc0200fc4:	0141                	addi	sp,sp,16
    cprintf("Buddy System算法将释放第NO.%d页开始的共%d页\n", page2ppn(base), (int)size);
ffffffffc0200fc6:	986ff06f          	j	ffffffffc020014c <cprintf>
ffffffffc0200fca:	8746                	mv	a4,a7
ffffffffc0200fcc:	bfd9                	j	ffffffffc0200fa2 <buddy_system_free_pages+0x126>
}
ffffffffc0200fce:	60a2                	ld	ra,8(sp)
ffffffffc0200fd0:	0141                	addi	sp,sp,16
ffffffffc0200fd2:	8082                	ret
    if (n <= 1) return 1;
ffffffffc0200fd4:	4885                	li	a7,1
ffffffffc0200fd6:	bdcd                	j	ffffffffc0200ec8 <buddy_system_free_pages+0x4c>
    unsigned node_size = 1;
ffffffffc0200fd8:	4705                	li	a4,1
ffffffffc0200fda:	bfb1                	j	ffffffffc0200f36 <buddy_system_free_pages+0xba>
    assert(base != NULL && n > 0);
ffffffffc0200fdc:	00001697          	auipc	a3,0x1
ffffffffc0200fe0:	06c68693          	addi	a3,a3,108 # ffffffffc0202048 <etext+0x826>
ffffffffc0200fe4:	00001617          	auipc	a2,0x1
ffffffffc0200fe8:	aa460613          	addi	a2,a2,-1372 # ffffffffc0201a88 <etext+0x266>
ffffffffc0200fec:	0a000593          	li	a1,160
ffffffffc0200ff0:	00001517          	auipc	a0,0x1
ffffffffc0200ff4:	ab050513          	addi	a0,a0,-1360 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0200ff8:	9caff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(offset < b2.size);
ffffffffc0200ffc:	00001697          	auipc	a3,0x1
ffffffffc0201000:	07c68693          	addi	a3,a3,124 # ffffffffc0202078 <etext+0x856>
ffffffffc0201004:	00001617          	auipc	a2,0x1
ffffffffc0201008:	a8460613          	addi	a2,a2,-1404 # ffffffffc0201a88 <etext+0x266>
ffffffffc020100c:	0a900593          	li	a1,169
ffffffffc0201010:	00001517          	auipc	a0,0x1
ffffffffc0201014:	a9050513          	addi	a0,a0,-1392 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0201018:	9aaff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(idx >= b2.base_idx);
ffffffffc020101c:	00001697          	auipc	a3,0x1
ffffffffc0201020:	04468693          	addi	a3,a3,68 # ffffffffc0202060 <etext+0x83e>
ffffffffc0201024:	00001617          	auipc	a2,0x1
ffffffffc0201028:	a6460613          	addi	a2,a2,-1436 # ffffffffc0201a88 <etext+0x266>
ffffffffc020102c:	0a700593          	li	a1,167
ffffffffc0201030:	00001517          	auipc	a0,0x1
ffffffffc0201034:	a7050513          	addi	a0,a0,-1424 # ffffffffc0201aa0 <etext+0x27e>
ffffffffc0201038:	98aff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020103c <buddy_system_alloc_pages>:
    assert(requested_pages > 0);
ffffffffc020103c:	12050f63          	beqz	a0,ffffffffc020117a <buddy_system_alloc_pages+0x13e>
    if (requested_pages > b2.nr_free) return NULL;
ffffffffc0201040:	00005597          	auipc	a1,0x5
ffffffffc0201044:	fd858593          	addi	a1,a1,-40 # ffffffffc0206018 <b2>
ffffffffc0201048:	0085a883          	lw	a7,8(a1)
ffffffffc020104c:	02089793          	slli	a5,a7,0x20
ffffffffc0201050:	9381                	srli	a5,a5,0x20
ffffffffc0201052:	10a7ec63          	bltu	a5,a0,ffffffffc020116a <buddy_system_alloc_pages+0x12e>
    if (n <= 1) return 1;
ffffffffc0201056:	4805                	li	a6,1
ffffffffc0201058:	03050e63          	beq	a0,a6,ffffffffc0201094 <buddy_system_alloc_pages+0x58>
    unsigned need = Next_Pow2((unsigned)requested_pages);
ffffffffc020105c:	0005081b          	sext.w	a6,a0
    if ((n & (n - 1)) == 0) return n;
ffffffffc0201060:	357d                	addiw	a0,a0,-1
ffffffffc0201062:	00a877b3          	and	a5,a6,a0
ffffffffc0201066:	2781                	sext.w	a5,a5
ffffffffc0201068:	c795                	beqz	a5,ffffffffc0201094 <buddy_system_alloc_pages+0x58>
    n |= n >> 1;
ffffffffc020106a:	0015581b          	srliw	a6,a0,0x1
ffffffffc020106e:	00a86533          	or	a0,a6,a0
    n |= n >> 2;
ffffffffc0201072:	0025581b          	srliw	a6,a0,0x2
ffffffffc0201076:	01056833          	or	a6,a0,a6
    n |= n >> 4;
ffffffffc020107a:	0048551b          	srliw	a0,a6,0x4
ffffffffc020107e:	00a86833          	or	a6,a6,a0
    n |= n >> 8;
ffffffffc0201082:	0088579b          	srliw	a5,a6,0x8
ffffffffc0201086:	00f86833          	or	a6,a6,a5
    n |= n >> 16; 
ffffffffc020108a:	0108579b          	srliw	a5,a6,0x10
ffffffffc020108e:	00f86833          	or	a6,a6,a5
    return n + 1;
ffffffffc0201092:	2805                	addiw	a6,a6,1
    if (need > b2.size) return NULL;
ffffffffc0201094:	0005a303          	lw	t1,0(a1)
ffffffffc0201098:	0d036963          	bltu	t1,a6,ffffffffc020116a <buddy_system_alloc_pages+0x12e>
    if (b2.longest[0] < need) return NULL;
ffffffffc020109c:	519c                	lw	a5,32(a1)
ffffffffc020109e:	0d07e663          	bltu	a5,a6,ffffffffc020116a <buddy_system_alloc_pages+0x12e>
    for (unsigned node_size = b2.size; node_size != need; node_size >>= 1) {
ffffffffc02010a2:	0d030663          	beq	t1,a6,ffffffffc020116e <buddy_system_alloc_pages+0x132>
ffffffffc02010a6:	861a                	mv	a2,t1
    unsigned index = 0;
ffffffffc02010a8:	4781                	li	a5,0
        unsigned li = LEFT_LEAF(index);
ffffffffc02010aa:	0017969b          	slliw	a3,a5,0x1
ffffffffc02010ae:	0016879b          	addiw	a5,a3,1
        if (b2.longest[li] >= need) index = li;
ffffffffc02010b2:	02079513          	slli	a0,a5,0x20
ffffffffc02010b6:	01e55713          	srli	a4,a0,0x1e
ffffffffc02010ba:	972e                	add	a4,a4,a1
ffffffffc02010bc:	5308                	lw	a0,32(a4)
        unsigned ri = RIGHT_LEAF(index);
ffffffffc02010be:	0026871b          	addiw	a4,a3,2
        if (b2.longest[li] >= need) index = li;
ffffffffc02010c2:	01057563          	bgeu	a0,a6,ffffffffc02010cc <buddy_system_alloc_pages+0x90>
        else                        index = ri;
ffffffffc02010c6:	87ba                	mv	a5,a4
    unsigned offset = (alloc_index + 1) * need - b2.size;
ffffffffc02010c8:	0036871b          	addiw	a4,a3,3
    for (unsigned node_size = b2.size; node_size != need; node_size >>= 1) {
ffffffffc02010cc:	0016561b          	srliw	a2,a2,0x1
ffffffffc02010d0:	fd061de3          	bne	a2,a6,ffffffffc02010aa <buddy_system_alloc_pages+0x6e>
    b2.longest[index] = 0;
ffffffffc02010d4:	02079613          	slli	a2,a5,0x20
ffffffffc02010d8:	01e65693          	srli	a3,a2,0x1e
ffffffffc02010dc:	96ae                	add	a3,a3,a1
ffffffffc02010de:	0206a023          	sw	zero,32(a3)
    unsigned offset = (alloc_index + 1) * need - b2.size;
ffffffffc02010e2:	02e8053b          	mulw	a0,a6,a4
    while (index) {
ffffffffc02010e6:	cba9                	beqz	a5,ffffffffc0201138 <buddy_system_alloc_pages+0xfc>
        index = PARENT(index);
ffffffffc02010e8:	2785                	addiw	a5,a5,1
ffffffffc02010ea:	0017d61b          	srliw	a2,a5,0x1
ffffffffc02010ee:	367d                	addiw	a2,a2,-1
        unsigned ri = RIGHT_LEAF(index);
ffffffffc02010f0:	ffe7f713          	andi	a4,a5,-2
        unsigned li = LEFT_LEAF(index);
ffffffffc02010f4:	0016169b          	slliw	a3,a2,0x1
        b2.longest[index] = (b2.longest[li] > b2.longest[ri]) ? b2.longest[li] : b2.longest[ri];
ffffffffc02010f8:	1702                	slli	a4,a4,0x20
        unsigned li = LEFT_LEAF(index);
ffffffffc02010fa:	2685                	addiw	a3,a3,1
        b2.longest[index] = (b2.longest[li] > b2.longest[ri]) ? b2.longest[li] : b2.longest[ri];
ffffffffc02010fc:	9301                	srli	a4,a4,0x20
ffffffffc02010fe:	02069793          	slli	a5,a3,0x20
ffffffffc0201102:	0721                	addi	a4,a4,8
ffffffffc0201104:	01e7d693          	srli	a3,a5,0x1e
ffffffffc0201108:	070a                	slli	a4,a4,0x2
ffffffffc020110a:	972e                	add	a4,a4,a1
ffffffffc020110c:	96ae                	add	a3,a3,a1
ffffffffc020110e:	00072e03          	lw	t3,0(a4)
ffffffffc0201112:	5294                	lw	a3,32(a3)
ffffffffc0201114:	02061793          	slli	a5,a2,0x20
ffffffffc0201118:	01e7d713          	srli	a4,a5,0x1e
ffffffffc020111c:	02070713          	addi	a4,a4,32
ffffffffc0201120:	00068f1b          	sext.w	t5,a3
ffffffffc0201124:	000e0e9b          	sext.w	t4,t3
        index = PARENT(index);
ffffffffc0201128:	0006079b          	sext.w	a5,a2
        b2.longest[index] = (b2.longest[li] > b2.longest[ri]) ? b2.longest[li] : b2.longest[ri];
ffffffffc020112c:	972e                	add	a4,a4,a1
ffffffffc020112e:	01df7363          	bgeu	t5,t4,ffffffffc0201134 <buddy_system_alloc_pages+0xf8>
ffffffffc0201132:	86f2                	mv	a3,t3
ffffffffc0201134:	c314                	sw	a3,0(a4)
    while (index) {
ffffffffc0201136:	fbcd                	bnez	a5,ffffffffc02010e8 <buddy_system_alloc_pages+0xac>
    struct Page *ret = &pages[b2.base_idx + offset];
ffffffffc0201138:	6d98                	ld	a4,24(a1)
    unsigned offset = (alloc_index + 1) * need - b2.size;
ffffffffc020113a:	406507bb          	subw	a5,a0,t1
    struct Page *ret = &pages[b2.base_idx + offset];
ffffffffc020113e:	1782                	slli	a5,a5,0x20
ffffffffc0201140:	9381                	srli	a5,a5,0x20
ffffffffc0201142:	97ba                	add	a5,a5,a4
ffffffffc0201144:	00279513          	slli	a0,a5,0x2
ffffffffc0201148:	97aa                	add	a5,a5,a0
ffffffffc020114a:	078e                	slli	a5,a5,0x3
ffffffffc020114c:	00025517          	auipc	a0,0x25
ffffffffc0201150:	f0c53503          	ld	a0,-244(a0) # ffffffffc0226058 <pages>
ffffffffc0201154:	953e                	add	a0,a0,a5
    ClearPageProperty(ret);           // 展示用途：标成“非空闲头页”
ffffffffc0201156:	651c                	ld	a5,8(a0)
    b2.nr_free -= need;
ffffffffc0201158:	4108883b          	subw	a6,a7,a6
ffffffffc020115c:	0105a423          	sw	a6,8(a1)
    ClearPageProperty(ret);           // 展示用途：标成“非空闲头页”
ffffffffc0201160:	9bf5                	andi	a5,a5,-3
ffffffffc0201162:	e51c                	sd	a5,8(a0)
    ret->property = -1;
ffffffffc0201164:	57fd                	li	a5,-1
ffffffffc0201166:	c91c                	sw	a5,16(a0)
    return ret;
ffffffffc0201168:	8082                	ret
    if (requested_pages > b2.nr_free) return NULL;
ffffffffc020116a:	4501                	li	a0,0
}
ffffffffc020116c:	8082                	ret
    b2.longest[index] = 0;
ffffffffc020116e:	00005797          	auipc	a5,0x5
ffffffffc0201172:	ec07a523          	sw	zero,-310(a5) # ffffffffc0206038 <b2+0x20>
ffffffffc0201176:	8542                	mv	a0,a6
ffffffffc0201178:	b7c1                	j	ffffffffc0201138 <buddy_system_alloc_pages+0xfc>
static struct Page *buddy_system_alloc_pages(size_t requested_pages) {
ffffffffc020117a:	1141                	addi	sp,sp,-16
    assert(requested_pages > 0);
ffffffffc020117c:	00001697          	auipc	a3,0x1
ffffffffc0201180:	f5468693          	addi	a3,a3,-172 # ffffffffc02020d0 <etext+0x8ae>
ffffffffc0201184:	00001617          	auipc	a2,0x1
ffffffffc0201188:	90460613          	addi	a2,a2,-1788 # ffffffffc0201a88 <etext+0x266>
ffffffffc020118c:	07300593          	li	a1,115
ffffffffc0201190:	00001517          	auipc	a0,0x1
ffffffffc0201194:	91050513          	addi	a0,a0,-1776 # ffffffffc0201aa0 <etext+0x27e>
static struct Page *buddy_system_alloc_pages(size_t requested_pages) {
ffffffffc0201198:	e406                	sd	ra,8(sp)
    assert(requested_pages > 0);
ffffffffc020119a:	828ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020119e <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);  
ffffffffc020119e:	00025797          	auipc	a5,0x25
ffffffffc02011a2:	ec27b783          	ld	a5,-318(a5) # ffffffffc0226060 <pmm_manager>
ffffffffc02011a6:	6f9c                	ld	a5,24(a5)
ffffffffc02011a8:	8782                	jr	a5

ffffffffc02011aa <free_pages>:
    //   调用管理器的分配函数，分配连续 n 页物理内存
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);  
ffffffffc02011aa:	00025797          	auipc	a5,0x25
ffffffffc02011ae:	eb67b783          	ld	a5,-330(a5) # ffffffffc0226060 <pmm_manager>
ffffffffc02011b2:	739c                	ld	a5,32(a5)
ffffffffc02011b4:	8782                	jr	a5

ffffffffc02011b6 <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02011b6:	00001797          	auipc	a5,0x1
ffffffffc02011ba:	f5278793          	addi	a5,a5,-174 # ffffffffc0202108 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);  
ffffffffc02011be:	638c                	ld	a1,0(a5)
        //   初始化空闲页映射表，为 [mem_begin, mem_end) 区域建立 free list
    }
}

/* pmm_init - initialize the physical memory management 初始化物理内存管理*/
void pmm_init(void) {
ffffffffc02011c0:	7179                	addi	sp,sp,-48
ffffffffc02011c2:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);  
ffffffffc02011c4:	00001517          	auipc	a0,0x1
ffffffffc02011c8:	f7c50513          	addi	a0,a0,-132 # ffffffffc0202140 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02011cc:	00025417          	auipc	s0,0x25
ffffffffc02011d0:	e9440413          	addi	s0,s0,-364 # ffffffffc0226060 <pmm_manager>
void pmm_init(void) {
ffffffffc02011d4:	f406                	sd	ra,40(sp)
ffffffffc02011d6:	ec26                	sd	s1,24(sp)
ffffffffc02011d8:	e44e                	sd	s3,8(sp)
ffffffffc02011da:	e84a                	sd	s2,16(sp)
ffffffffc02011dc:	e052                	sd	s4,0(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02011de:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);  
ffffffffc02011e0:	f6dfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    pmm_manager->init();  
ffffffffc02011e4:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  
ffffffffc02011e6:	00025497          	auipc	s1,0x25
ffffffffc02011ea:	e9248493          	addi	s1,s1,-366 # ffffffffc0226078 <va_pa_offset>
    pmm_manager->init();  
ffffffffc02011ee:	679c                	ld	a5,8(a5)
ffffffffc02011f0:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  
ffffffffc02011f2:	57f5                	li	a5,-3
ffffffffc02011f4:	07fa                	slli	a5,a5,0x1e
ffffffffc02011f6:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();  
ffffffffc02011f8:	bc4ff0ef          	jal	ra,ffffffffc02005bc <get_memory_base>
ffffffffc02011fc:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();  
ffffffffc02011fe:	bc8ff0ef          	jal	ra,ffffffffc02005c6 <get_memory_size>
    if (mem_size == 0) {
ffffffffc0201202:	14050d63          	beqz	a0,ffffffffc020135c <pmm_init+0x1a6>
    uint64_t mem_end   = mem_begin + mem_size;  
ffffffffc0201206:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0201208:	00001517          	auipc	a0,0x1
ffffffffc020120c:	f8050513          	addi	a0,a0,-128 # ffffffffc0202188 <buddy_system_pmm_manager+0x80>
ffffffffc0201210:	f3dfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;  
ffffffffc0201214:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201218:	864e                	mv	a2,s3
ffffffffc020121a:	fffa0693          	addi	a3,s4,-1
ffffffffc020121e:	85ca                	mv	a1,s2
ffffffffc0201220:	00001517          	auipc	a0,0x1
ffffffffc0201224:	f8050513          	addi	a0,a0,-128 # ffffffffc02021a0 <buddy_system_pmm_manager+0x98>
ffffffffc0201228:	f25fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020122c:	c80007b7          	lui	a5,0xc8000
ffffffffc0201230:	8652                	mv	a2,s4
ffffffffc0201232:	0d47e463          	bltu	a5,s4,ffffffffc02012fa <pmm_init+0x144>
ffffffffc0201236:	00026797          	auipc	a5,0x26
ffffffffc020123a:	e4978793          	addi	a5,a5,-439 # ffffffffc022707f <end+0xfff>
ffffffffc020123e:	757d                	lui	a0,0xfffff
ffffffffc0201240:	8d7d                	and	a0,a0,a5
ffffffffc0201242:	8231                	srli	a2,a2,0xc
ffffffffc0201244:	00025797          	auipc	a5,0x25
ffffffffc0201248:	e0c7b623          	sd	a2,-500(a5) # ffffffffc0226050 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020124c:	00025797          	auipc	a5,0x25
ffffffffc0201250:	e0a7b623          	sd	a0,-500(a5) # ffffffffc0226058 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201254:	000807b7          	lui	a5,0x80
ffffffffc0201258:	002005b7          	lui	a1,0x200
ffffffffc020125c:	02f60563          	beq	a2,a5,ffffffffc0201286 <pmm_init+0xd0>
ffffffffc0201260:	00261593          	slli	a1,a2,0x2
ffffffffc0201264:	00c586b3          	add	a3,a1,a2
ffffffffc0201268:	fec007b7          	lui	a5,0xfec00
ffffffffc020126c:	97aa                	add	a5,a5,a0
ffffffffc020126e:	068e                	slli	a3,a3,0x3
ffffffffc0201270:	96be                	add	a3,a3,a5
ffffffffc0201272:	87aa                	mv	a5,a0
        SetPageReserved(pages + i);  
ffffffffc0201274:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201276:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9d9fa8>
        SetPageReserved(pages + i);  
ffffffffc020127a:	00176713          	ori	a4,a4,1
ffffffffc020127e:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201282:	fef699e3          	bne	a3,a5,ffffffffc0201274 <pmm_init+0xbe>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201286:	95b2                	add	a1,a1,a2
ffffffffc0201288:	fec006b7          	lui	a3,0xfec00
ffffffffc020128c:	96aa                	add	a3,a3,a0
ffffffffc020128e:	058e                	slli	a1,a1,0x3
ffffffffc0201290:	96ae                	add	a3,a3,a1
ffffffffc0201292:	c02007b7          	lui	a5,0xc0200
ffffffffc0201296:	0af6e763          	bltu	a3,a5,ffffffffc0201344 <pmm_init+0x18e>
ffffffffc020129a:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020129c:	77fd                	lui	a5,0xfffff
ffffffffc020129e:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02012a2:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02012a4:	04b6ee63          	bltu	a3,a1,ffffffffc0201300 <pmm_init+0x14a>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
    //   打印页表基址信息，方便调试虚实地址映射
}

static void check_alloc_page(void) {
    pmm_manager->check();  
ffffffffc02012a8:	601c                	ld	a5,0(s0)
ffffffffc02012aa:	7b9c                	ld	a5,48(a5)
ffffffffc02012ac:	9782                	jalr	a5
    //   调用内存管理器的自检函数（例如 best_fit_check），执行多轮分配/释放验证
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02012ae:	00001517          	auipc	a0,0x1
ffffffffc02012b2:	f7a50513          	addi	a0,a0,-134 # ffffffffc0202228 <buddy_system_pmm_manager+0x120>
ffffffffc02012b6:	e97fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;  
ffffffffc02012ba:	00004597          	auipc	a1,0x4
ffffffffc02012be:	d4658593          	addi	a1,a1,-698 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02012c2:	00025797          	auipc	a5,0x25
ffffffffc02012c6:	dab7b723          	sd	a1,-594(a5) # ffffffffc0226070 <satp_virtual>
    satp_physical = PADDR(satp_virtual);  
ffffffffc02012ca:	c02007b7          	lui	a5,0xc0200
ffffffffc02012ce:	0af5e363          	bltu	a1,a5,ffffffffc0201374 <pmm_init+0x1be>
ffffffffc02012d2:	6090                	ld	a2,0(s1)
}
ffffffffc02012d4:	7402                	ld	s0,32(sp)
ffffffffc02012d6:	70a2                	ld	ra,40(sp)
ffffffffc02012d8:	64e2                	ld	s1,24(sp)
ffffffffc02012da:	6942                	ld	s2,16(sp)
ffffffffc02012dc:	69a2                	ld	s3,8(sp)
ffffffffc02012de:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);  
ffffffffc02012e0:	40c58633          	sub	a2,a1,a2
ffffffffc02012e4:	00025797          	auipc	a5,0x25
ffffffffc02012e8:	d8c7b223          	sd	a2,-636(a5) # ffffffffc0226068 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02012ec:	00001517          	auipc	a0,0x1
ffffffffc02012f0:	f5c50513          	addi	a0,a0,-164 # ffffffffc0202248 <buddy_system_pmm_manager+0x140>
}
ffffffffc02012f4:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02012f6:	e57fe06f          	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02012fa:	c8000637          	lui	a2,0xc8000
ffffffffc02012fe:	bf25                	j	ffffffffc0201236 <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201300:	6705                	lui	a4,0x1
ffffffffc0201302:	177d                	addi	a4,a4,-1
ffffffffc0201304:	96ba                	add	a3,a3,a4
ffffffffc0201306:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201308:	00c6d793          	srli	a5,a3,0xc
ffffffffc020130c:	02c7f063          	bgeu	a5,a2,ffffffffc020132c <pmm_init+0x176>
    pmm_manager->init_memmap(base, n);  
ffffffffc0201310:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201312:	fff80737          	lui	a4,0xfff80
ffffffffc0201316:	973e                	add	a4,a4,a5
ffffffffc0201318:	00271793          	slli	a5,a4,0x2
ffffffffc020131c:	97ba                	add	a5,a5,a4
ffffffffc020131e:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201320:	8d95                	sub	a1,a1,a3
ffffffffc0201322:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);  
ffffffffc0201324:	81b1                	srli	a1,a1,0xc
ffffffffc0201326:	953e                	add	a0,a0,a5
ffffffffc0201328:	9702                	jalr	a4
}
ffffffffc020132a:	bfbd                	j	ffffffffc02012a8 <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc020132c:	00001617          	auipc	a2,0x1
ffffffffc0201330:	ecc60613          	addi	a2,a2,-308 # ffffffffc02021f8 <buddy_system_pmm_manager+0xf0>
ffffffffc0201334:	06a00593          	li	a1,106
ffffffffc0201338:	00001517          	auipc	a0,0x1
ffffffffc020133c:	ee050513          	addi	a0,a0,-288 # ffffffffc0202218 <buddy_system_pmm_manager+0x110>
ffffffffc0201340:	e83fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201344:	00001617          	auipc	a2,0x1
ffffffffc0201348:	e8c60613          	addi	a2,a2,-372 # ffffffffc02021d0 <buddy_system_pmm_manager+0xc8>
ffffffffc020134c:	07c00593          	li	a1,124
ffffffffc0201350:	00001517          	auipc	a0,0x1
ffffffffc0201354:	e2850513          	addi	a0,a0,-472 # ffffffffc0202178 <buddy_system_pmm_manager+0x70>
ffffffffc0201358:	e6bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");  
ffffffffc020135c:	00001617          	auipc	a2,0x1
ffffffffc0201360:	dfc60613          	addi	a2,a2,-516 # ffffffffc0202158 <buddy_system_pmm_manager+0x50>
ffffffffc0201364:	05d00593          	li	a1,93
ffffffffc0201368:	00001517          	auipc	a0,0x1
ffffffffc020136c:	e1050513          	addi	a0,a0,-496 # ffffffffc0202178 <buddy_system_pmm_manager+0x70>
ffffffffc0201370:	e53fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);  
ffffffffc0201374:	86ae                	mv	a3,a1
ffffffffc0201376:	00001617          	auipc	a2,0x1
ffffffffc020137a:	e5a60613          	addi	a2,a2,-422 # ffffffffc02021d0 <buddy_system_pmm_manager+0xc8>
ffffffffc020137e:	0a000593          	li	a1,160
ffffffffc0201382:	00001517          	auipc	a0,0x1
ffffffffc0201386:	df650513          	addi	a0,a0,-522 # ffffffffc0202178 <buddy_system_pmm_manager+0x70>
ffffffffc020138a:	e39fe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020138e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020138e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201392:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201394:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201398:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020139a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020139e:	f022                	sd	s0,32(sp)
ffffffffc02013a0:	ec26                	sd	s1,24(sp)
ffffffffc02013a2:	e84a                	sd	s2,16(sp)
ffffffffc02013a4:	f406                	sd	ra,40(sp)
ffffffffc02013a6:	e44e                	sd	s3,8(sp)
ffffffffc02013a8:	84aa                	mv	s1,a0
ffffffffc02013aa:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02013ac:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02013b0:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02013b2:	03067e63          	bgeu	a2,a6,ffffffffc02013ee <printnum+0x60>
ffffffffc02013b6:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02013b8:	00805763          	blez	s0,ffffffffc02013c6 <printnum+0x38>
ffffffffc02013bc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02013be:	85ca                	mv	a1,s2
ffffffffc02013c0:	854e                	mv	a0,s3
ffffffffc02013c2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02013c4:	fc65                	bnez	s0,ffffffffc02013bc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013c6:	1a02                	slli	s4,s4,0x20
ffffffffc02013c8:	00001797          	auipc	a5,0x1
ffffffffc02013cc:	ec078793          	addi	a5,a5,-320 # ffffffffc0202288 <buddy_system_pmm_manager+0x180>
ffffffffc02013d0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02013d4:	9a3e                	add	s4,s4,a5
}
ffffffffc02013d6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013d8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02013dc:	70a2                	ld	ra,40(sp)
ffffffffc02013de:	69a2                	ld	s3,8(sp)
ffffffffc02013e0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013e2:	85ca                	mv	a1,s2
ffffffffc02013e4:	87a6                	mv	a5,s1
}
ffffffffc02013e6:	6942                	ld	s2,16(sp)
ffffffffc02013e8:	64e2                	ld	s1,24(sp)
ffffffffc02013ea:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013ec:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02013ee:	03065633          	divu	a2,a2,a6
ffffffffc02013f2:	8722                	mv	a4,s0
ffffffffc02013f4:	f9bff0ef          	jal	ra,ffffffffc020138e <printnum>
ffffffffc02013f8:	b7f9                	j	ffffffffc02013c6 <printnum+0x38>

ffffffffc02013fa <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02013fa:	7119                	addi	sp,sp,-128
ffffffffc02013fc:	f4a6                	sd	s1,104(sp)
ffffffffc02013fe:	f0ca                	sd	s2,96(sp)
ffffffffc0201400:	ecce                	sd	s3,88(sp)
ffffffffc0201402:	e8d2                	sd	s4,80(sp)
ffffffffc0201404:	e4d6                	sd	s5,72(sp)
ffffffffc0201406:	e0da                	sd	s6,64(sp)
ffffffffc0201408:	fc5e                	sd	s7,56(sp)
ffffffffc020140a:	f06a                	sd	s10,32(sp)
ffffffffc020140c:	fc86                	sd	ra,120(sp)
ffffffffc020140e:	f8a2                	sd	s0,112(sp)
ffffffffc0201410:	f862                	sd	s8,48(sp)
ffffffffc0201412:	f466                	sd	s9,40(sp)
ffffffffc0201414:	ec6e                	sd	s11,24(sp)
ffffffffc0201416:	892a                	mv	s2,a0
ffffffffc0201418:	84ae                	mv	s1,a1
ffffffffc020141a:	8d32                	mv	s10,a2
ffffffffc020141c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020141e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201422:	5b7d                	li	s6,-1
ffffffffc0201424:	00001a97          	auipc	s5,0x1
ffffffffc0201428:	e98a8a93          	addi	s5,s5,-360 # ffffffffc02022bc <buddy_system_pmm_manager+0x1b4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020142c:	00001b97          	auipc	s7,0x1
ffffffffc0201430:	06cb8b93          	addi	s7,s7,108 # ffffffffc0202498 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201434:	000d4503          	lbu	a0,0(s10)
ffffffffc0201438:	001d0413          	addi	s0,s10,1
ffffffffc020143c:	01350a63          	beq	a0,s3,ffffffffc0201450 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201440:	c121                	beqz	a0,ffffffffc0201480 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201442:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201444:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201446:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201448:	fff44503          	lbu	a0,-1(s0)
ffffffffc020144c:	ff351ae3          	bne	a0,s3,ffffffffc0201440 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201450:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201454:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201458:	4c81                	li	s9,0
ffffffffc020145a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020145c:	5c7d                	li	s8,-1
ffffffffc020145e:	5dfd                	li	s11,-1
ffffffffc0201460:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201464:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201466:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020146a:	0ff5f593          	zext.b	a1,a1
ffffffffc020146e:	00140d13          	addi	s10,s0,1
ffffffffc0201472:	04b56263          	bltu	a0,a1,ffffffffc02014b6 <vprintfmt+0xbc>
ffffffffc0201476:	058a                	slli	a1,a1,0x2
ffffffffc0201478:	95d6                	add	a1,a1,s5
ffffffffc020147a:	4194                	lw	a3,0(a1)
ffffffffc020147c:	96d6                	add	a3,a3,s5
ffffffffc020147e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201480:	70e6                	ld	ra,120(sp)
ffffffffc0201482:	7446                	ld	s0,112(sp)
ffffffffc0201484:	74a6                	ld	s1,104(sp)
ffffffffc0201486:	7906                	ld	s2,96(sp)
ffffffffc0201488:	69e6                	ld	s3,88(sp)
ffffffffc020148a:	6a46                	ld	s4,80(sp)
ffffffffc020148c:	6aa6                	ld	s5,72(sp)
ffffffffc020148e:	6b06                	ld	s6,64(sp)
ffffffffc0201490:	7be2                	ld	s7,56(sp)
ffffffffc0201492:	7c42                	ld	s8,48(sp)
ffffffffc0201494:	7ca2                	ld	s9,40(sp)
ffffffffc0201496:	7d02                	ld	s10,32(sp)
ffffffffc0201498:	6de2                	ld	s11,24(sp)
ffffffffc020149a:	6109                	addi	sp,sp,128
ffffffffc020149c:	8082                	ret
            padc = '0';
ffffffffc020149e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02014a0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014a4:	846a                	mv	s0,s10
ffffffffc02014a6:	00140d13          	addi	s10,s0,1
ffffffffc02014aa:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02014ae:	0ff5f593          	zext.b	a1,a1
ffffffffc02014b2:	fcb572e3          	bgeu	a0,a1,ffffffffc0201476 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02014b6:	85a6                	mv	a1,s1
ffffffffc02014b8:	02500513          	li	a0,37
ffffffffc02014bc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02014be:	fff44783          	lbu	a5,-1(s0)
ffffffffc02014c2:	8d22                	mv	s10,s0
ffffffffc02014c4:	f73788e3          	beq	a5,s3,ffffffffc0201434 <vprintfmt+0x3a>
ffffffffc02014c8:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02014cc:	1d7d                	addi	s10,s10,-1
ffffffffc02014ce:	ff379de3          	bne	a5,s3,ffffffffc02014c8 <vprintfmt+0xce>
ffffffffc02014d2:	b78d                	j	ffffffffc0201434 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02014d4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02014d8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014dc:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02014de:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02014e2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02014e6:	02d86463          	bltu	a6,a3,ffffffffc020150e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02014ea:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02014ee:	002c169b          	slliw	a3,s8,0x2
ffffffffc02014f2:	0186873b          	addw	a4,a3,s8
ffffffffc02014f6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02014fa:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02014fc:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201500:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201502:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201506:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020150a:	fed870e3          	bgeu	a6,a3,ffffffffc02014ea <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020150e:	f40ddce3          	bgez	s11,ffffffffc0201466 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201512:	8de2                	mv	s11,s8
ffffffffc0201514:	5c7d                	li	s8,-1
ffffffffc0201516:	bf81                	j	ffffffffc0201466 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201518:	fffdc693          	not	a3,s11
ffffffffc020151c:	96fd                	srai	a3,a3,0x3f
ffffffffc020151e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201522:	00144603          	lbu	a2,1(s0)
ffffffffc0201526:	2d81                	sext.w	s11,s11
ffffffffc0201528:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020152a:	bf35                	j	ffffffffc0201466 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020152c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201530:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201534:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201536:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201538:	bfd9                	j	ffffffffc020150e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020153a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020153c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201540:	01174463          	blt	a4,a7,ffffffffc0201548 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201544:	1a088e63          	beqz	a7,ffffffffc0201700 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201548:	000a3603          	ld	a2,0(s4)
ffffffffc020154c:	46c1                	li	a3,16
ffffffffc020154e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201550:	2781                	sext.w	a5,a5
ffffffffc0201552:	876e                	mv	a4,s11
ffffffffc0201554:	85a6                	mv	a1,s1
ffffffffc0201556:	854a                	mv	a0,s2
ffffffffc0201558:	e37ff0ef          	jal	ra,ffffffffc020138e <printnum>
            break;
ffffffffc020155c:	bde1                	j	ffffffffc0201434 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020155e:	000a2503          	lw	a0,0(s4)
ffffffffc0201562:	85a6                	mv	a1,s1
ffffffffc0201564:	0a21                	addi	s4,s4,8
ffffffffc0201566:	9902                	jalr	s2
            break;
ffffffffc0201568:	b5f1                	j	ffffffffc0201434 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020156a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020156c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201570:	01174463          	blt	a4,a7,ffffffffc0201578 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201574:	18088163          	beqz	a7,ffffffffc02016f6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201578:	000a3603          	ld	a2,0(s4)
ffffffffc020157c:	46a9                	li	a3,10
ffffffffc020157e:	8a2e                	mv	s4,a1
ffffffffc0201580:	bfc1                	j	ffffffffc0201550 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201582:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201586:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201588:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020158a:	bdf1                	j	ffffffffc0201466 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020158c:	85a6                	mv	a1,s1
ffffffffc020158e:	02500513          	li	a0,37
ffffffffc0201592:	9902                	jalr	s2
            break;
ffffffffc0201594:	b545                	j	ffffffffc0201434 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201596:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020159a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020159c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020159e:	b5e1                	j	ffffffffc0201466 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02015a0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02015a2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02015a6:	01174463          	blt	a4,a7,ffffffffc02015ae <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02015aa:	14088163          	beqz	a7,ffffffffc02016ec <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02015ae:	000a3603          	ld	a2,0(s4)
ffffffffc02015b2:	46a1                	li	a3,8
ffffffffc02015b4:	8a2e                	mv	s4,a1
ffffffffc02015b6:	bf69                	j	ffffffffc0201550 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02015b8:	03000513          	li	a0,48
ffffffffc02015bc:	85a6                	mv	a1,s1
ffffffffc02015be:	e03e                	sd	a5,0(sp)
ffffffffc02015c0:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02015c2:	85a6                	mv	a1,s1
ffffffffc02015c4:	07800513          	li	a0,120
ffffffffc02015c8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02015ca:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02015cc:	6782                	ld	a5,0(sp)
ffffffffc02015ce:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02015d0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02015d4:	bfb5                	j	ffffffffc0201550 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02015d6:	000a3403          	ld	s0,0(s4)
ffffffffc02015da:	008a0713          	addi	a4,s4,8
ffffffffc02015de:	e03a                	sd	a4,0(sp)
ffffffffc02015e0:	14040263          	beqz	s0,ffffffffc0201724 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02015e4:	0fb05763          	blez	s11,ffffffffc02016d2 <vprintfmt+0x2d8>
ffffffffc02015e8:	02d00693          	li	a3,45
ffffffffc02015ec:	0cd79163          	bne	a5,a3,ffffffffc02016ae <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015f0:	00044783          	lbu	a5,0(s0)
ffffffffc02015f4:	0007851b          	sext.w	a0,a5
ffffffffc02015f8:	cf85                	beqz	a5,ffffffffc0201630 <vprintfmt+0x236>
ffffffffc02015fa:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015fe:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201602:	000c4563          	bltz	s8,ffffffffc020160c <vprintfmt+0x212>
ffffffffc0201606:	3c7d                	addiw	s8,s8,-1
ffffffffc0201608:	036c0263          	beq	s8,s6,ffffffffc020162c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020160c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020160e:	0e0c8e63          	beqz	s9,ffffffffc020170a <vprintfmt+0x310>
ffffffffc0201612:	3781                	addiw	a5,a5,-32
ffffffffc0201614:	0ef47b63          	bgeu	s0,a5,ffffffffc020170a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201618:	03f00513          	li	a0,63
ffffffffc020161c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020161e:	000a4783          	lbu	a5,0(s4)
ffffffffc0201622:	3dfd                	addiw	s11,s11,-1
ffffffffc0201624:	0a05                	addi	s4,s4,1
ffffffffc0201626:	0007851b          	sext.w	a0,a5
ffffffffc020162a:	ffe1                	bnez	a5,ffffffffc0201602 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020162c:	01b05963          	blez	s11,ffffffffc020163e <vprintfmt+0x244>
ffffffffc0201630:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201632:	85a6                	mv	a1,s1
ffffffffc0201634:	02000513          	li	a0,32
ffffffffc0201638:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020163a:	fe0d9be3          	bnez	s11,ffffffffc0201630 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020163e:	6a02                	ld	s4,0(sp)
ffffffffc0201640:	bbd5                	j	ffffffffc0201434 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201642:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201644:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201648:	01174463          	blt	a4,a7,ffffffffc0201650 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020164c:	08088d63          	beqz	a7,ffffffffc02016e6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201650:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201654:	0a044d63          	bltz	s0,ffffffffc020170e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201658:	8622                	mv	a2,s0
ffffffffc020165a:	8a66                	mv	s4,s9
ffffffffc020165c:	46a9                	li	a3,10
ffffffffc020165e:	bdcd                	j	ffffffffc0201550 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201660:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201664:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201666:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201668:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020166c:	8fb5                	xor	a5,a5,a3
ffffffffc020166e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201672:	02d74163          	blt	a4,a3,ffffffffc0201694 <vprintfmt+0x29a>
ffffffffc0201676:	00369793          	slli	a5,a3,0x3
ffffffffc020167a:	97de                	add	a5,a5,s7
ffffffffc020167c:	639c                	ld	a5,0(a5)
ffffffffc020167e:	cb99                	beqz	a5,ffffffffc0201694 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201680:	86be                	mv	a3,a5
ffffffffc0201682:	00001617          	auipc	a2,0x1
ffffffffc0201686:	c3660613          	addi	a2,a2,-970 # ffffffffc02022b8 <buddy_system_pmm_manager+0x1b0>
ffffffffc020168a:	85a6                	mv	a1,s1
ffffffffc020168c:	854a                	mv	a0,s2
ffffffffc020168e:	0ce000ef          	jal	ra,ffffffffc020175c <printfmt>
ffffffffc0201692:	b34d                	j	ffffffffc0201434 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201694:	00001617          	auipc	a2,0x1
ffffffffc0201698:	c1460613          	addi	a2,a2,-1004 # ffffffffc02022a8 <buddy_system_pmm_manager+0x1a0>
ffffffffc020169c:	85a6                	mv	a1,s1
ffffffffc020169e:	854a                	mv	a0,s2
ffffffffc02016a0:	0bc000ef          	jal	ra,ffffffffc020175c <printfmt>
ffffffffc02016a4:	bb41                	j	ffffffffc0201434 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02016a6:	00001417          	auipc	s0,0x1
ffffffffc02016aa:	bfa40413          	addi	s0,s0,-1030 # ffffffffc02022a0 <buddy_system_pmm_manager+0x198>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016ae:	85e2                	mv	a1,s8
ffffffffc02016b0:	8522                	mv	a0,s0
ffffffffc02016b2:	e43e                	sd	a5,8(sp)
ffffffffc02016b4:	0fc000ef          	jal	ra,ffffffffc02017b0 <strnlen>
ffffffffc02016b8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02016bc:	01b05b63          	blez	s11,ffffffffc02016d2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02016c0:	67a2                	ld	a5,8(sp)
ffffffffc02016c2:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016c6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02016c8:	85a6                	mv	a1,s1
ffffffffc02016ca:	8552                	mv	a0,s4
ffffffffc02016cc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016ce:	fe0d9ce3          	bnez	s11,ffffffffc02016c6 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016d2:	00044783          	lbu	a5,0(s0)
ffffffffc02016d6:	00140a13          	addi	s4,s0,1
ffffffffc02016da:	0007851b          	sext.w	a0,a5
ffffffffc02016de:	d3a5                	beqz	a5,ffffffffc020163e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016e0:	05e00413          	li	s0,94
ffffffffc02016e4:	bf39                	j	ffffffffc0201602 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02016e6:	000a2403          	lw	s0,0(s4)
ffffffffc02016ea:	b7ad                	j	ffffffffc0201654 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02016ec:	000a6603          	lwu	a2,0(s4)
ffffffffc02016f0:	46a1                	li	a3,8
ffffffffc02016f2:	8a2e                	mv	s4,a1
ffffffffc02016f4:	bdb1                	j	ffffffffc0201550 <vprintfmt+0x156>
ffffffffc02016f6:	000a6603          	lwu	a2,0(s4)
ffffffffc02016fa:	46a9                	li	a3,10
ffffffffc02016fc:	8a2e                	mv	s4,a1
ffffffffc02016fe:	bd89                	j	ffffffffc0201550 <vprintfmt+0x156>
ffffffffc0201700:	000a6603          	lwu	a2,0(s4)
ffffffffc0201704:	46c1                	li	a3,16
ffffffffc0201706:	8a2e                	mv	s4,a1
ffffffffc0201708:	b5a1                	j	ffffffffc0201550 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020170a:	9902                	jalr	s2
ffffffffc020170c:	bf09                	j	ffffffffc020161e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020170e:	85a6                	mv	a1,s1
ffffffffc0201710:	02d00513          	li	a0,45
ffffffffc0201714:	e03e                	sd	a5,0(sp)
ffffffffc0201716:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201718:	6782                	ld	a5,0(sp)
ffffffffc020171a:	8a66                	mv	s4,s9
ffffffffc020171c:	40800633          	neg	a2,s0
ffffffffc0201720:	46a9                	li	a3,10
ffffffffc0201722:	b53d                	j	ffffffffc0201550 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201724:	03b05163          	blez	s11,ffffffffc0201746 <vprintfmt+0x34c>
ffffffffc0201728:	02d00693          	li	a3,45
ffffffffc020172c:	f6d79de3          	bne	a5,a3,ffffffffc02016a6 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201730:	00001417          	auipc	s0,0x1
ffffffffc0201734:	b7040413          	addi	s0,s0,-1168 # ffffffffc02022a0 <buddy_system_pmm_manager+0x198>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201738:	02800793          	li	a5,40
ffffffffc020173c:	02800513          	li	a0,40
ffffffffc0201740:	00140a13          	addi	s4,s0,1
ffffffffc0201744:	bd6d                	j	ffffffffc02015fe <vprintfmt+0x204>
ffffffffc0201746:	00001a17          	auipc	s4,0x1
ffffffffc020174a:	b5ba0a13          	addi	s4,s4,-1189 # ffffffffc02022a1 <buddy_system_pmm_manager+0x199>
ffffffffc020174e:	02800513          	li	a0,40
ffffffffc0201752:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201756:	05e00413          	li	s0,94
ffffffffc020175a:	b565                	j	ffffffffc0201602 <vprintfmt+0x208>

ffffffffc020175c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020175c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020175e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201762:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201764:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201766:	ec06                	sd	ra,24(sp)
ffffffffc0201768:	f83a                	sd	a4,48(sp)
ffffffffc020176a:	fc3e                	sd	a5,56(sp)
ffffffffc020176c:	e0c2                	sd	a6,64(sp)
ffffffffc020176e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201770:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201772:	c89ff0ef          	jal	ra,ffffffffc02013fa <vprintfmt>
}
ffffffffc0201776:	60e2                	ld	ra,24(sp)
ffffffffc0201778:	6161                	addi	sp,sp,80
ffffffffc020177a:	8082                	ret

ffffffffc020177c <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc020177c:	4781                	li	a5,0
ffffffffc020177e:	00005717          	auipc	a4,0x5
ffffffffc0201782:	89273703          	ld	a4,-1902(a4) # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201786:	88ba                	mv	a7,a4
ffffffffc0201788:	852a                	mv	a0,a0
ffffffffc020178a:	85be                	mv	a1,a5
ffffffffc020178c:	863e                	mv	a2,a5
ffffffffc020178e:	00000073          	ecall
ffffffffc0201792:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201794:	8082                	ret

ffffffffc0201796 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0201796:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc020179a:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc020179c:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020179e:	cb81                	beqz	a5,ffffffffc02017ae <strlen+0x18>
        cnt ++;
ffffffffc02017a0:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02017a2:	00a707b3          	add	a5,a4,a0
ffffffffc02017a6:	0007c783          	lbu	a5,0(a5)
ffffffffc02017aa:	fbfd                	bnez	a5,ffffffffc02017a0 <strlen+0xa>
ffffffffc02017ac:	8082                	ret
    }
    return cnt;
}
ffffffffc02017ae:	8082                	ret

ffffffffc02017b0 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02017b0:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02017b2:	e589                	bnez	a1,ffffffffc02017bc <strnlen+0xc>
ffffffffc02017b4:	a811                	j	ffffffffc02017c8 <strnlen+0x18>
        cnt ++;
ffffffffc02017b6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02017b8:	00f58863          	beq	a1,a5,ffffffffc02017c8 <strnlen+0x18>
ffffffffc02017bc:	00f50733          	add	a4,a0,a5
ffffffffc02017c0:	00074703          	lbu	a4,0(a4)
ffffffffc02017c4:	fb6d                	bnez	a4,ffffffffc02017b6 <strnlen+0x6>
ffffffffc02017c6:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02017c8:	852e                	mv	a0,a1
ffffffffc02017ca:	8082                	ret

ffffffffc02017cc <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02017cc:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02017d0:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02017d4:	cb89                	beqz	a5,ffffffffc02017e6 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02017d6:	0505                	addi	a0,a0,1
ffffffffc02017d8:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02017da:	fee789e3          	beq	a5,a4,ffffffffc02017cc <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02017de:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02017e2:	9d19                	subw	a0,a0,a4
ffffffffc02017e4:	8082                	ret
ffffffffc02017e6:	4501                	li	a0,0
ffffffffc02017e8:	bfed                	j	ffffffffc02017e2 <strcmp+0x16>

ffffffffc02017ea <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02017ea:	c20d                	beqz	a2,ffffffffc020180c <strncmp+0x22>
ffffffffc02017ec:	962e                	add	a2,a2,a1
ffffffffc02017ee:	a031                	j	ffffffffc02017fa <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc02017f0:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02017f2:	00e79a63          	bne	a5,a4,ffffffffc0201806 <strncmp+0x1c>
ffffffffc02017f6:	00b60b63          	beq	a2,a1,ffffffffc020180c <strncmp+0x22>
ffffffffc02017fa:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02017fe:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201800:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201804:	f7f5                	bnez	a5,ffffffffc02017f0 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201806:	40e7853b          	subw	a0,a5,a4
}
ffffffffc020180a:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020180c:	4501                	li	a0,0
ffffffffc020180e:	8082                	ret

ffffffffc0201810 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201810:	ca01                	beqz	a2,ffffffffc0201820 <memset+0x10>
ffffffffc0201812:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201814:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201816:	0785                	addi	a5,a5,1
ffffffffc0201818:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020181c:	fec79de3          	bne	a5,a2,ffffffffc0201816 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201820:	8082                	ret
