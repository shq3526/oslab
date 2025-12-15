
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	0000c297          	auipc	t0,0xc
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc020c000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	0000c297          	auipc	t0,0xc
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc020c008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc020003c:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
void grade_backtrace(void);

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc020004a:	000d3517          	auipc	a0,0xd3
ffffffffc020004e:	91e50513          	addi	a0,a0,-1762 # ffffffffc02d2968 <buf>
ffffffffc0200052:	000d7617          	auipc	a2,0xd7
ffffffffc0200056:	dda60613          	addi	a2,a2,-550 # ffffffffc02d6e2c <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	277050ef          	jal	ra,ffffffffc0205ad8 <memset>
    dtb_init();
ffffffffc0200066:	598000ef          	jal	ra,ffffffffc02005fe <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	522000ef          	jal	ra,ffffffffc020058c <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00006597          	auipc	a1,0x6
ffffffffc0200072:	a9a58593          	addi	a1,a1,-1382 # ffffffffc0205b08 <etext+0x6>
ffffffffc0200076:	00006517          	auipc	a0,0x6
ffffffffc020007a:	ab250513          	addi	a0,a0,-1358 # ffffffffc0205b28 <etext+0x26>
ffffffffc020007e:	116000ef          	jal	ra,ffffffffc0200194 <cprintf>

    print_kerninfo();
ffffffffc0200082:	19a000ef          	jal	ra,ffffffffc020021c <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	7bc020ef          	jal	ra,ffffffffc0202842 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	131000ef          	jal	ra,ffffffffc02009ba <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	12f000ef          	jal	ra,ffffffffc02009bc <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	303030ef          	jal	ra,ffffffffc0203b94 <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	140050ef          	jal	ra,ffffffffc02051d6 <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	4a0000ef          	jal	ra,ffffffffc020053a <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	111000ef          	jal	ra,ffffffffc02009ae <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	2cc050ef          	jal	ra,ffffffffc020536e <cpu_idle>

ffffffffc02000a6 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02000a6:	715d                	addi	sp,sp,-80
ffffffffc02000a8:	e486                	sd	ra,72(sp)
ffffffffc02000aa:	e0a6                	sd	s1,64(sp)
ffffffffc02000ac:	fc4a                	sd	s2,56(sp)
ffffffffc02000ae:	f84e                	sd	s3,48(sp)
ffffffffc02000b0:	f452                	sd	s4,40(sp)
ffffffffc02000b2:	f056                	sd	s5,32(sp)
ffffffffc02000b4:	ec5a                	sd	s6,24(sp)
ffffffffc02000b6:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000b8:	c901                	beqz	a0,ffffffffc02000c8 <readline+0x22>
ffffffffc02000ba:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000bc:	00006517          	auipc	a0,0x6
ffffffffc02000c0:	a7450513          	addi	a0,a0,-1420 # ffffffffc0205b30 <etext+0x2e>
ffffffffc02000c4:	0d0000ef          	jal	ra,ffffffffc0200194 <cprintf>
readline(const char *prompt) {
ffffffffc02000c8:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000ca:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000cc:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ce:	4aa9                	li	s5,10
ffffffffc02000d0:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000d2:	000d3b97          	auipc	s7,0xd3
ffffffffc02000d6:	896b8b93          	addi	s7,s7,-1898 # ffffffffc02d2968 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000de:	12e000ef          	jal	ra,ffffffffc020020c <getchar>
        if (c < 0) {
ffffffffc02000e2:	00054a63          	bltz	a0,ffffffffc02000f6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000e6:	00a95a63          	bge	s2,a0,ffffffffc02000fa <readline+0x54>
ffffffffc02000ea:	029a5263          	bge	s4,s1,ffffffffc020010e <readline+0x68>
        c = getchar();
ffffffffc02000ee:	11e000ef          	jal	ra,ffffffffc020020c <getchar>
        if (c < 0) {
ffffffffc02000f2:	fe055ae3          	bgez	a0,ffffffffc02000e6 <readline+0x40>
            return NULL;
ffffffffc02000f6:	4501                	li	a0,0
ffffffffc02000f8:	a091                	j	ffffffffc020013c <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000fa:	03351463          	bne	a0,s3,ffffffffc0200122 <readline+0x7c>
ffffffffc02000fe:	e8a9                	bnez	s1,ffffffffc0200150 <readline+0xaa>
        c = getchar();
ffffffffc0200100:	10c000ef          	jal	ra,ffffffffc020020c <getchar>
        if (c < 0) {
ffffffffc0200104:	fe0549e3          	bltz	a0,ffffffffc02000f6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200108:	fea959e3          	bge	s2,a0,ffffffffc02000fa <readline+0x54>
ffffffffc020010c:	4481                	li	s1,0
            cputchar(c);
ffffffffc020010e:	e42a                	sd	a0,8(sp)
ffffffffc0200110:	0ba000ef          	jal	ra,ffffffffc02001ca <cputchar>
            buf[i ++] = c;
ffffffffc0200114:	6522                	ld	a0,8(sp)
ffffffffc0200116:	009b87b3          	add	a5,s7,s1
ffffffffc020011a:	2485                	addiw	s1,s1,1
ffffffffc020011c:	00a78023          	sb	a0,0(a5)
ffffffffc0200120:	bf7d                	j	ffffffffc02000de <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0200122:	01550463          	beq	a0,s5,ffffffffc020012a <readline+0x84>
ffffffffc0200126:	fb651ce3          	bne	a0,s6,ffffffffc02000de <readline+0x38>
            cputchar(c);
ffffffffc020012a:	0a0000ef          	jal	ra,ffffffffc02001ca <cputchar>
            buf[i] = '\0';
ffffffffc020012e:	000d3517          	auipc	a0,0xd3
ffffffffc0200132:	83a50513          	addi	a0,a0,-1990 # ffffffffc02d2968 <buf>
ffffffffc0200136:	94aa                	add	s1,s1,a0
ffffffffc0200138:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020013c:	60a6                	ld	ra,72(sp)
ffffffffc020013e:	6486                	ld	s1,64(sp)
ffffffffc0200140:	7962                	ld	s2,56(sp)
ffffffffc0200142:	79c2                	ld	s3,48(sp)
ffffffffc0200144:	7a22                	ld	s4,40(sp)
ffffffffc0200146:	7a82                	ld	s5,32(sp)
ffffffffc0200148:	6b62                	ld	s6,24(sp)
ffffffffc020014a:	6bc2                	ld	s7,16(sp)
ffffffffc020014c:	6161                	addi	sp,sp,80
ffffffffc020014e:	8082                	ret
            cputchar(c);
ffffffffc0200150:	4521                	li	a0,8
ffffffffc0200152:	078000ef          	jal	ra,ffffffffc02001ca <cputchar>
            i --;
ffffffffc0200156:	34fd                	addiw	s1,s1,-1
ffffffffc0200158:	b759                	j	ffffffffc02000de <readline+0x38>

ffffffffc020015a <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc020015a:	1141                	addi	sp,sp,-16
ffffffffc020015c:	e022                	sd	s0,0(sp)
ffffffffc020015e:	e406                	sd	ra,8(sp)
ffffffffc0200160:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200162:	42c000ef          	jal	ra,ffffffffc020058e <cons_putc>
    (*cnt)++;
ffffffffc0200166:	401c                	lw	a5,0(s0)
}
ffffffffc0200168:	60a2                	ld	ra,8(sp)
    (*cnt)++;
ffffffffc020016a:	2785                	addiw	a5,a5,1
ffffffffc020016c:	c01c                	sw	a5,0(s0)
}
ffffffffc020016e:	6402                	ld	s0,0(sp)
ffffffffc0200170:	0141                	addi	sp,sp,16
ffffffffc0200172:	8082                	ret

ffffffffc0200174 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc0200174:	1101                	addi	sp,sp,-32
ffffffffc0200176:	862a                	mv	a2,a0
ffffffffc0200178:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020017a:	00000517          	auipc	a0,0x0
ffffffffc020017e:	fe050513          	addi	a0,a0,-32 # ffffffffc020015a <cputch>
ffffffffc0200182:	006c                	addi	a1,sp,12
{
ffffffffc0200184:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200186:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc0200188:	52c050ef          	jal	ra,ffffffffc02056b4 <vprintfmt>
    return cnt;
}
ffffffffc020018c:	60e2                	ld	ra,24(sp)
ffffffffc020018e:	4532                	lw	a0,12(sp)
ffffffffc0200190:	6105                	addi	sp,sp,32
ffffffffc0200192:	8082                	ret

ffffffffc0200194 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc0200194:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200196:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
{
ffffffffc020019a:	8e2a                	mv	t3,a0
ffffffffc020019c:	f42e                	sd	a1,40(sp)
ffffffffc020019e:	f832                	sd	a2,48(sp)
ffffffffc02001a0:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001a2:	00000517          	auipc	a0,0x0
ffffffffc02001a6:	fb850513          	addi	a0,a0,-72 # ffffffffc020015a <cputch>
ffffffffc02001aa:	004c                	addi	a1,sp,4
ffffffffc02001ac:	869a                	mv	a3,t1
ffffffffc02001ae:	8672                	mv	a2,t3
{
ffffffffc02001b0:	ec06                	sd	ra,24(sp)
ffffffffc02001b2:	e0ba                	sd	a4,64(sp)
ffffffffc02001b4:	e4be                	sd	a5,72(sp)
ffffffffc02001b6:	e8c2                	sd	a6,80(sp)
ffffffffc02001b8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001ba:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001bc:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001be:	4f6050ef          	jal	ra,ffffffffc02056b4 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001c2:	60e2                	ld	ra,24(sp)
ffffffffc02001c4:	4512                	lw	a0,4(sp)
ffffffffc02001c6:	6125                	addi	sp,sp,96
ffffffffc02001c8:	8082                	ret

ffffffffc02001ca <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
    cons_putc(c);
ffffffffc02001ca:	a6d1                	j	ffffffffc020058e <cons_putc>

ffffffffc02001cc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int cputs(const char *str)
{
ffffffffc02001cc:	1101                	addi	sp,sp,-32
ffffffffc02001ce:	e822                	sd	s0,16(sp)
ffffffffc02001d0:	ec06                	sd	ra,24(sp)
ffffffffc02001d2:	e426                	sd	s1,8(sp)
ffffffffc02001d4:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str++) != '\0')
ffffffffc02001d6:	00054503          	lbu	a0,0(a0)
ffffffffc02001da:	c51d                	beqz	a0,ffffffffc0200208 <cputs+0x3c>
ffffffffc02001dc:	0405                	addi	s0,s0,1
ffffffffc02001de:	4485                	li	s1,1
ffffffffc02001e0:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001e2:	3ac000ef          	jal	ra,ffffffffc020058e <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc02001e6:	00044503          	lbu	a0,0(s0)
ffffffffc02001ea:	008487bb          	addw	a5,s1,s0
ffffffffc02001ee:	0405                	addi	s0,s0,1
ffffffffc02001f0:	f96d                	bnez	a0,ffffffffc02001e2 <cputs+0x16>
    (*cnt)++;
ffffffffc02001f2:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001f6:	4529                	li	a0,10
ffffffffc02001f8:	396000ef          	jal	ra,ffffffffc020058e <cons_putc>
    {
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001fc:	60e2                	ld	ra,24(sp)
ffffffffc02001fe:	8522                	mv	a0,s0
ffffffffc0200200:	6442                	ld	s0,16(sp)
ffffffffc0200202:	64a2                	ld	s1,8(sp)
ffffffffc0200204:	6105                	addi	sp,sp,32
ffffffffc0200206:	8082                	ret
    while ((c = *str++) != '\0')
ffffffffc0200208:	4405                	li	s0,1
ffffffffc020020a:	b7f5                	j	ffffffffc02001f6 <cputs+0x2a>

ffffffffc020020c <getchar>:

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc020020c:	1141                	addi	sp,sp,-16
ffffffffc020020e:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200210:	3b2000ef          	jal	ra,ffffffffc02005c2 <cons_getc>
ffffffffc0200214:	dd75                	beqz	a0,ffffffffc0200210 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200216:	60a2                	ld	ra,8(sp)
ffffffffc0200218:	0141                	addi	sp,sp,16
ffffffffc020021a:	8082                	ret

ffffffffc020021c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
ffffffffc020021c:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020021e:	00006517          	auipc	a0,0x6
ffffffffc0200222:	91a50513          	addi	a0,a0,-1766 # ffffffffc0205b38 <etext+0x36>
{
ffffffffc0200226:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200228:	f6dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020022c:	00000597          	auipc	a1,0x0
ffffffffc0200230:	e1e58593          	addi	a1,a1,-482 # ffffffffc020004a <kern_init>
ffffffffc0200234:	00006517          	auipc	a0,0x6
ffffffffc0200238:	92450513          	addi	a0,a0,-1756 # ffffffffc0205b58 <etext+0x56>
ffffffffc020023c:	f59ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200240:	00006597          	auipc	a1,0x6
ffffffffc0200244:	8c258593          	addi	a1,a1,-1854 # ffffffffc0205b02 <etext>
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	93050513          	addi	a0,a0,-1744 # ffffffffc0205b78 <etext+0x76>
ffffffffc0200250:	f45ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200254:	000d2597          	auipc	a1,0xd2
ffffffffc0200258:	71458593          	addi	a1,a1,1812 # ffffffffc02d2968 <buf>
ffffffffc020025c:	00006517          	auipc	a0,0x6
ffffffffc0200260:	93c50513          	addi	a0,a0,-1732 # ffffffffc0205b98 <etext+0x96>
ffffffffc0200264:	f31ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200268:	000d7597          	auipc	a1,0xd7
ffffffffc020026c:	bc458593          	addi	a1,a1,-1084 # ffffffffc02d6e2c <end>
ffffffffc0200270:	00006517          	auipc	a0,0x6
ffffffffc0200274:	94850513          	addi	a0,a0,-1720 # ffffffffc0205bb8 <etext+0xb6>
ffffffffc0200278:	f1dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020027c:	000d7597          	auipc	a1,0xd7
ffffffffc0200280:	faf58593          	addi	a1,a1,-81 # ffffffffc02d722b <end+0x3ff>
ffffffffc0200284:	00000797          	auipc	a5,0x0
ffffffffc0200288:	dc678793          	addi	a5,a5,-570 # ffffffffc020004a <kern_init>
ffffffffc020028c:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200290:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200294:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200296:	3ff5f593          	andi	a1,a1,1023
ffffffffc020029a:	95be                	add	a1,a1,a5
ffffffffc020029c:	85a9                	srai	a1,a1,0xa
ffffffffc020029e:	00006517          	auipc	a0,0x6
ffffffffc02002a2:	93a50513          	addi	a0,a0,-1734 # ffffffffc0205bd8 <etext+0xd6>
}
ffffffffc02002a6:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a8:	b5f5                	j	ffffffffc0200194 <cprintf>

ffffffffc02002aa <print_stackframe>:
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void)
{
ffffffffc02002aa:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002ac:	00006617          	auipc	a2,0x6
ffffffffc02002b0:	95c60613          	addi	a2,a2,-1700 # ffffffffc0205c08 <etext+0x106>
ffffffffc02002b4:	04f00593          	li	a1,79
ffffffffc02002b8:	00006517          	auipc	a0,0x6
ffffffffc02002bc:	96850513          	addi	a0,a0,-1688 # ffffffffc0205c20 <etext+0x11e>
{
ffffffffc02002c0:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002c2:	1cc000ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02002c6 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int mon_help(int argc, char **argv, struct trapframe *tf)
{
ffffffffc02002c6:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i++)
    {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002c8:	00006617          	auipc	a2,0x6
ffffffffc02002cc:	97060613          	addi	a2,a2,-1680 # ffffffffc0205c38 <etext+0x136>
ffffffffc02002d0:	00006597          	auipc	a1,0x6
ffffffffc02002d4:	98858593          	addi	a1,a1,-1656 # ffffffffc0205c58 <etext+0x156>
ffffffffc02002d8:	00006517          	auipc	a0,0x6
ffffffffc02002dc:	98850513          	addi	a0,a0,-1656 # ffffffffc0205c60 <etext+0x15e>
{
ffffffffc02002e0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e2:	eb3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002e6:	00006617          	auipc	a2,0x6
ffffffffc02002ea:	98a60613          	addi	a2,a2,-1654 # ffffffffc0205c70 <etext+0x16e>
ffffffffc02002ee:	00006597          	auipc	a1,0x6
ffffffffc02002f2:	9aa58593          	addi	a1,a1,-1622 # ffffffffc0205c98 <etext+0x196>
ffffffffc02002f6:	00006517          	auipc	a0,0x6
ffffffffc02002fa:	96a50513          	addi	a0,a0,-1686 # ffffffffc0205c60 <etext+0x15e>
ffffffffc02002fe:	e97ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200302:	00006617          	auipc	a2,0x6
ffffffffc0200306:	9a660613          	addi	a2,a2,-1626 # ffffffffc0205ca8 <etext+0x1a6>
ffffffffc020030a:	00006597          	auipc	a1,0x6
ffffffffc020030e:	9be58593          	addi	a1,a1,-1602 # ffffffffc0205cc8 <etext+0x1c6>
ffffffffc0200312:	00006517          	auipc	a0,0x6
ffffffffc0200316:	94e50513          	addi	a0,a0,-1714 # ffffffffc0205c60 <etext+0x15e>
ffffffffc020031a:	e7bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    return 0;
}
ffffffffc020031e:	60a2                	ld	ra,8(sp)
ffffffffc0200320:	4501                	li	a0,0
ffffffffc0200322:	0141                	addi	sp,sp,16
ffffffffc0200324:	8082                	ret

ffffffffc0200326 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int mon_kerninfo(int argc, char **argv, struct trapframe *tf)
{
ffffffffc0200326:	1141                	addi	sp,sp,-16
ffffffffc0200328:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020032a:	ef3ff0ef          	jal	ra,ffffffffc020021c <print_kerninfo>
    return 0;
}
ffffffffc020032e:	60a2                	ld	ra,8(sp)
ffffffffc0200330:	4501                	li	a0,0
ffffffffc0200332:	0141                	addi	sp,sp,16
ffffffffc0200334:	8082                	ret

ffffffffc0200336 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int mon_backtrace(int argc, char **argv, struct trapframe *tf)
{
ffffffffc0200336:	1141                	addi	sp,sp,-16
ffffffffc0200338:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020033a:	f71ff0ef          	jal	ra,ffffffffc02002aa <print_stackframe>
    return 0;
}
ffffffffc020033e:	60a2                	ld	ra,8(sp)
ffffffffc0200340:	4501                	li	a0,0
ffffffffc0200342:	0141                	addi	sp,sp,16
ffffffffc0200344:	8082                	ret

ffffffffc0200346 <kmonitor>:
{
ffffffffc0200346:	7115                	addi	sp,sp,-224
ffffffffc0200348:	ed5e                	sd	s7,152(sp)
ffffffffc020034a:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020034c:	00006517          	auipc	a0,0x6
ffffffffc0200350:	98c50513          	addi	a0,a0,-1652 # ffffffffc0205cd8 <etext+0x1d6>
{
ffffffffc0200354:	ed86                	sd	ra,216(sp)
ffffffffc0200356:	e9a2                	sd	s0,208(sp)
ffffffffc0200358:	e5a6                	sd	s1,200(sp)
ffffffffc020035a:	e1ca                	sd	s2,192(sp)
ffffffffc020035c:	fd4e                	sd	s3,184(sp)
ffffffffc020035e:	f952                	sd	s4,176(sp)
ffffffffc0200360:	f556                	sd	s5,168(sp)
ffffffffc0200362:	f15a                	sd	s6,160(sp)
ffffffffc0200364:	e962                	sd	s8,144(sp)
ffffffffc0200366:	e566                	sd	s9,136(sp)
ffffffffc0200368:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020036a:	e2bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020036e:	00006517          	auipc	a0,0x6
ffffffffc0200372:	99250513          	addi	a0,a0,-1646 # ffffffffc0205d00 <etext+0x1fe>
ffffffffc0200376:	e1fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if (tf != NULL)
ffffffffc020037a:	000b8563          	beqz	s7,ffffffffc0200384 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037e:	855e                	mv	a0,s7
ffffffffc0200380:	025000ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
ffffffffc0200384:	00006c17          	auipc	s8,0x6
ffffffffc0200388:	9ecc0c13          	addi	s8,s8,-1556 # ffffffffc0205d70 <commands>
        if ((buf = readline("K> ")) != NULL)
ffffffffc020038c:	00006917          	auipc	s2,0x6
ffffffffc0200390:	99c90913          	addi	s2,s2,-1636 # ffffffffc0205d28 <etext+0x226>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200394:	00006497          	auipc	s1,0x6
ffffffffc0200398:	99c48493          	addi	s1,s1,-1636 # ffffffffc0205d30 <etext+0x22e>
        if (argc == MAXARGS - 1)
ffffffffc020039c:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039e:	00006b17          	auipc	s6,0x6
ffffffffc02003a2:	99ab0b13          	addi	s6,s6,-1638 # ffffffffc0205d38 <etext+0x236>
        argv[argc++] = buf;
ffffffffc02003a6:	00006a17          	auipc	s4,0x6
ffffffffc02003aa:	8b2a0a13          	addi	s4,s4,-1870 # ffffffffc0205c58 <etext+0x156>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003ae:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL)
ffffffffc02003b0:	854a                	mv	a0,s2
ffffffffc02003b2:	cf5ff0ef          	jal	ra,ffffffffc02000a6 <readline>
ffffffffc02003b6:	842a                	mv	s0,a0
ffffffffc02003b8:	dd65                	beqz	a0,ffffffffc02003b0 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02003ba:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003be:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02003c0:	e1bd                	bnez	a1,ffffffffc0200426 <kmonitor+0xe0>
    if (argc == 0)
ffffffffc02003c2:	fe0c87e3          	beqz	s9,ffffffffc02003b0 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003c6:	6582                	ld	a1,0(sp)
ffffffffc02003c8:	00006d17          	auipc	s10,0x6
ffffffffc02003cc:	9a8d0d13          	addi	s10,s10,-1624 # ffffffffc0205d70 <commands>
        argv[argc++] = buf;
ffffffffc02003d0:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003d2:	4401                	li	s0,0
ffffffffc02003d4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003d6:	6a8050ef          	jal	ra,ffffffffc0205a7e <strcmp>
ffffffffc02003da:	c919                	beqz	a0,ffffffffc02003f0 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003dc:	2405                	addiw	s0,s0,1
ffffffffc02003de:	0b540063          	beq	s0,s5,ffffffffc020047e <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003e2:	000d3503          	ld	a0,0(s10)
ffffffffc02003e6:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003e8:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003ea:	694050ef          	jal	ra,ffffffffc0205a7e <strcmp>
ffffffffc02003ee:	f57d                	bnez	a0,ffffffffc02003dc <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003f0:	00141793          	slli	a5,s0,0x1
ffffffffc02003f4:	97a2                	add	a5,a5,s0
ffffffffc02003f6:	078e                	slli	a5,a5,0x3
ffffffffc02003f8:	97e2                	add	a5,a5,s8
ffffffffc02003fa:	6b9c                	ld	a5,16(a5)
ffffffffc02003fc:	865e                	mv	a2,s7
ffffffffc02003fe:	002c                	addi	a1,sp,8
ffffffffc0200400:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200404:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0)
ffffffffc0200406:	fa0555e3          	bgez	a0,ffffffffc02003b0 <kmonitor+0x6a>
}
ffffffffc020040a:	60ee                	ld	ra,216(sp)
ffffffffc020040c:	644e                	ld	s0,208(sp)
ffffffffc020040e:	64ae                	ld	s1,200(sp)
ffffffffc0200410:	690e                	ld	s2,192(sp)
ffffffffc0200412:	79ea                	ld	s3,184(sp)
ffffffffc0200414:	7a4a                	ld	s4,176(sp)
ffffffffc0200416:	7aaa                	ld	s5,168(sp)
ffffffffc0200418:	7b0a                	ld	s6,160(sp)
ffffffffc020041a:	6bea                	ld	s7,152(sp)
ffffffffc020041c:	6c4a                	ld	s8,144(sp)
ffffffffc020041e:	6caa                	ld	s9,136(sp)
ffffffffc0200420:	6d0a                	ld	s10,128(sp)
ffffffffc0200422:	612d                	addi	sp,sp,224
ffffffffc0200424:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200426:	8526                	mv	a0,s1
ffffffffc0200428:	69a050ef          	jal	ra,ffffffffc0205ac2 <strchr>
ffffffffc020042c:	c901                	beqz	a0,ffffffffc020043c <kmonitor+0xf6>
ffffffffc020042e:	00144583          	lbu	a1,1(s0)
            *buf++ = '\0';
ffffffffc0200432:	00040023          	sb	zero,0(s0)
ffffffffc0200436:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200438:	d5c9                	beqz	a1,ffffffffc02003c2 <kmonitor+0x7c>
ffffffffc020043a:	b7f5                	j	ffffffffc0200426 <kmonitor+0xe0>
        if (*buf == '\0')
ffffffffc020043c:	00044783          	lbu	a5,0(s0)
ffffffffc0200440:	d3c9                	beqz	a5,ffffffffc02003c2 <kmonitor+0x7c>
        if (argc == MAXARGS - 1)
ffffffffc0200442:	033c8963          	beq	s9,s3,ffffffffc0200474 <kmonitor+0x12e>
        argv[argc++] = buf;
ffffffffc0200446:	003c9793          	slli	a5,s9,0x3
ffffffffc020044a:	0118                	addi	a4,sp,128
ffffffffc020044c:	97ba                	add	a5,a5,a4
ffffffffc020044e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200452:	00044583          	lbu	a1,0(s0)
        argv[argc++] = buf;
ffffffffc0200456:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200458:	e591                	bnez	a1,ffffffffc0200464 <kmonitor+0x11e>
ffffffffc020045a:	b7b5                	j	ffffffffc02003c6 <kmonitor+0x80>
ffffffffc020045c:	00144583          	lbu	a1,1(s0)
            buf++;
ffffffffc0200460:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200462:	d1a5                	beqz	a1,ffffffffc02003c2 <kmonitor+0x7c>
ffffffffc0200464:	8526                	mv	a0,s1
ffffffffc0200466:	65c050ef          	jal	ra,ffffffffc0205ac2 <strchr>
ffffffffc020046a:	d96d                	beqz	a0,ffffffffc020045c <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc020046c:	00044583          	lbu	a1,0(s0)
ffffffffc0200470:	d9a9                	beqz	a1,ffffffffc02003c2 <kmonitor+0x7c>
ffffffffc0200472:	bf55                	j	ffffffffc0200426 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200474:	45c1                	li	a1,16
ffffffffc0200476:	855a                	mv	a0,s6
ffffffffc0200478:	d1dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc020047c:	b7e9                	j	ffffffffc0200446 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020047e:	6582                	ld	a1,0(sp)
ffffffffc0200480:	00006517          	auipc	a0,0x6
ffffffffc0200484:	8d850513          	addi	a0,a0,-1832 # ffffffffc0205d58 <etext+0x256>
ffffffffc0200488:	d0dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
ffffffffc020048c:	b715                	j	ffffffffc02003b0 <kmonitor+0x6a>

ffffffffc020048e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void __panic(const char *file, int line, const char *fmt, ...)
{
    if (is_panic)
ffffffffc020048e:	000d7317          	auipc	t1,0xd7
ffffffffc0200492:	90230313          	addi	t1,t1,-1790 # ffffffffc02d6d90 <is_panic>
ffffffffc0200496:	00033e03          	ld	t3,0(t1)
{
ffffffffc020049a:	715d                	addi	sp,sp,-80
ffffffffc020049c:	ec06                	sd	ra,24(sp)
ffffffffc020049e:	e822                	sd	s0,16(sp)
ffffffffc02004a0:	f436                	sd	a3,40(sp)
ffffffffc02004a2:	f83a                	sd	a4,48(sp)
ffffffffc02004a4:	fc3e                	sd	a5,56(sp)
ffffffffc02004a6:	e0c2                	sd	a6,64(sp)
ffffffffc02004a8:	e4c6                	sd	a7,72(sp)
    if (is_panic)
ffffffffc02004aa:	020e1a63          	bnez	t3,ffffffffc02004de <__panic+0x50>
    {
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004ae:	4785                	li	a5,1
ffffffffc02004b0:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004b4:	8432                	mv	s0,a2
ffffffffc02004b6:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b8:	862e                	mv	a2,a1
ffffffffc02004ba:	85aa                	mv	a1,a0
ffffffffc02004bc:	00006517          	auipc	a0,0x6
ffffffffc02004c0:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0205db8 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02004c4:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004c6:	ccfff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004ca:	65a2                	ld	a1,8(sp)
ffffffffc02004cc:	8522                	mv	a0,s0
ffffffffc02004ce:	ca7ff0ef          	jal	ra,ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc02004d2:	00007517          	auipc	a0,0x7
ffffffffc02004d6:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0206ef0 <default_pmm_manager+0x578>
ffffffffc02004da:	cbbff0ef          	jal	ra,ffffffffc0200194 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004de:	4501                	li	a0,0
ffffffffc02004e0:	4581                	li	a1,0
ffffffffc02004e2:	4601                	li	a2,0
ffffffffc02004e4:	48a1                	li	a7,8
ffffffffc02004e6:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004ea:	4ca000ef          	jal	ra,ffffffffc02009b4 <intr_disable>
    while (1)
    {
        kmonitor(NULL);
ffffffffc02004ee:	4501                	li	a0,0
ffffffffc02004f0:	e57ff0ef          	jal	ra,ffffffffc0200346 <kmonitor>
    while (1)
ffffffffc02004f4:	bfed                	j	ffffffffc02004ee <__panic+0x60>

ffffffffc02004f6 <__warn>:
    }
}

/* __warn - like panic, but don't */
void __warn(const char *file, int line, const char *fmt, ...)
{
ffffffffc02004f6:	715d                	addi	sp,sp,-80
ffffffffc02004f8:	832e                	mv	t1,a1
ffffffffc02004fa:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004fc:	85aa                	mv	a1,a0
{
ffffffffc02004fe:	8432                	mv	s0,a2
ffffffffc0200500:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200502:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc0200504:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200506:	00006517          	auipc	a0,0x6
ffffffffc020050a:	8d250513          	addi	a0,a0,-1838 # ffffffffc0205dd8 <commands+0x68>
{
ffffffffc020050e:	ec06                	sd	ra,24(sp)
ffffffffc0200510:	f436                	sd	a3,40(sp)
ffffffffc0200512:	f83a                	sd	a4,48(sp)
ffffffffc0200514:	e0c2                	sd	a6,64(sp)
ffffffffc0200516:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200518:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020051a:	c7bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020051e:	65a2                	ld	a1,8(sp)
ffffffffc0200520:	8522                	mv	a0,s0
ffffffffc0200522:	c53ff0ef          	jal	ra,ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc0200526:	00007517          	auipc	a0,0x7
ffffffffc020052a:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0206ef0 <default_pmm_manager+0x578>
ffffffffc020052e:	c67ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    va_end(ap);
}
ffffffffc0200532:	60e2                	ld	ra,24(sp)
ffffffffc0200534:	6442                	ld	s0,16(sp)
ffffffffc0200536:	6161                	addi	sp,sp,80
ffffffffc0200538:	8082                	ret

ffffffffc020053a <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020053a:	67e1                	lui	a5,0x18
ffffffffc020053c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd3d0>
ffffffffc0200540:	000d7717          	auipc	a4,0xd7
ffffffffc0200544:	86f73023          	sd	a5,-1952(a4) # ffffffffc02d6da0 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200548:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020054c:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020054e:	953e                	add	a0,a0,a5
ffffffffc0200550:	4601                	li	a2,0
ffffffffc0200552:	4881                	li	a7,0
ffffffffc0200554:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200558:	02000793          	li	a5,32
ffffffffc020055c:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200560:	00006517          	auipc	a0,0x6
ffffffffc0200564:	89850513          	addi	a0,a0,-1896 # ffffffffc0205df8 <commands+0x88>
    ticks = 0;
ffffffffc0200568:	000d7797          	auipc	a5,0xd7
ffffffffc020056c:	8207b823          	sd	zero,-2000(a5) # ffffffffc02d6d98 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200570:	b115                	j	ffffffffc0200194 <cprintf>

ffffffffc0200572 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200572:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200576:	000d7797          	auipc	a5,0xd7
ffffffffc020057a:	82a7b783          	ld	a5,-2006(a5) # ffffffffc02d6da0 <timebase>
ffffffffc020057e:	953e                	add	a0,a0,a5
ffffffffc0200580:	4581                	li	a1,0
ffffffffc0200582:	4601                	li	a2,0
ffffffffc0200584:	4881                	li	a7,0
ffffffffc0200586:	00000073          	ecall
ffffffffc020058a:	8082                	ret

ffffffffc020058c <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020058c:	8082                	ret

ffffffffc020058e <cons_putc>:
 * B 结束后如果不看之前的状态直接开中断，A 的后续代码就会暴露在中断风险下。
 * 因此必须“恢复”到之前的状态，而不是盲目“开启”。
 */
static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020058e:	100027f3          	csrr	a5,sstatus
ffffffffc0200592:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200594:	0ff57513          	zext.b	a0,a0
ffffffffc0200598:	e799                	bnez	a5,ffffffffc02005a6 <cons_putc+0x18>
ffffffffc020059a:	4581                	li	a1,0
ffffffffc020059c:	4601                	li	a2,0
ffffffffc020059e:	4885                	li	a7,1
ffffffffc02005a0:	00000073          	ecall
 * * 逻辑：
 * 只有当之前是开启状态 (flag=1) 时，才重新开启中断。
 */
static inline void __intr_restore(bool flag)
{
    if (flag)
ffffffffc02005a4:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005a6:	1101                	addi	sp,sp,-32
ffffffffc02005a8:	ec06                	sd	ra,24(sp)
ffffffffc02005aa:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005ac:	408000ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02005b0:	6522                	ld	a0,8(sp)
ffffffffc02005b2:	4581                	li	a1,0
ffffffffc02005b4:	4601                	li	a2,0
ffffffffc02005b6:	4885                	li	a7,1
ffffffffc02005b8:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005bc:	60e2                	ld	ra,24(sp)
ffffffffc02005be:	6105                	addi	sp,sp,32
    {
        intr_enable();
ffffffffc02005c0:	a6fd                	j	ffffffffc02009ae <intr_enable>

ffffffffc02005c2 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02005c2:	100027f3          	csrr	a5,sstatus
ffffffffc02005c6:	8b89                	andi	a5,a5,2
ffffffffc02005c8:	eb89                	bnez	a5,ffffffffc02005da <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005ca:	4501                	li	a0,0
ffffffffc02005cc:	4581                	li	a1,0
ffffffffc02005ce:	4601                	li	a2,0
ffffffffc02005d0:	4889                	li	a7,2
ffffffffc02005d2:	00000073          	ecall
ffffffffc02005d6:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005d8:	8082                	ret
int cons_getc(void) {
ffffffffc02005da:	1101                	addi	sp,sp,-32
ffffffffc02005dc:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005de:	3d6000ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02005e2:	4501                	li	a0,0
ffffffffc02005e4:	4581                	li	a1,0
ffffffffc02005e6:	4601                	li	a2,0
ffffffffc02005e8:	4889                	li	a7,2
ffffffffc02005ea:	00000073          	ecall
ffffffffc02005ee:	2501                	sext.w	a0,a0
ffffffffc02005f0:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005f2:	3bc000ef          	jal	ra,ffffffffc02009ae <intr_enable>
}
ffffffffc02005f6:	60e2                	ld	ra,24(sp)
ffffffffc02005f8:	6522                	ld	a0,8(sp)
ffffffffc02005fa:	6105                	addi	sp,sp,32
ffffffffc02005fc:	8082                	ret

ffffffffc02005fe <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc02005fe:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200600:	00006517          	auipc	a0,0x6
ffffffffc0200604:	81850513          	addi	a0,a0,-2024 # ffffffffc0205e18 <commands+0xa8>
void dtb_init(void) {
ffffffffc0200608:	fc86                	sd	ra,120(sp)
ffffffffc020060a:	f8a2                	sd	s0,112(sp)
ffffffffc020060c:	e8d2                	sd	s4,80(sp)
ffffffffc020060e:	f4a6                	sd	s1,104(sp)
ffffffffc0200610:	f0ca                	sd	s2,96(sp)
ffffffffc0200612:	ecce                	sd	s3,88(sp)
ffffffffc0200614:	e4d6                	sd	s5,72(sp)
ffffffffc0200616:	e0da                	sd	s6,64(sp)
ffffffffc0200618:	fc5e                	sd	s7,56(sp)
ffffffffc020061a:	f862                	sd	s8,48(sp)
ffffffffc020061c:	f466                	sd	s9,40(sp)
ffffffffc020061e:	f06a                	sd	s10,32(sp)
ffffffffc0200620:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc0200622:	b73ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200626:	0000c597          	auipc	a1,0xc
ffffffffc020062a:	9da5b583          	ld	a1,-1574(a1) # ffffffffc020c000 <boot_hartid>
ffffffffc020062e:	00005517          	auipc	a0,0x5
ffffffffc0200632:	7fa50513          	addi	a0,a0,2042 # ffffffffc0205e28 <commands+0xb8>
ffffffffc0200636:	b5fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020063a:	0000c417          	auipc	s0,0xc
ffffffffc020063e:	9ce40413          	addi	s0,s0,-1586 # ffffffffc020c008 <boot_dtb>
ffffffffc0200642:	600c                	ld	a1,0(s0)
ffffffffc0200644:	00005517          	auipc	a0,0x5
ffffffffc0200648:	7f450513          	addi	a0,a0,2036 # ffffffffc0205e38 <commands+0xc8>
ffffffffc020064c:	b49ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200650:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200654:	00005517          	auipc	a0,0x5
ffffffffc0200658:	7fc50513          	addi	a0,a0,2044 # ffffffffc0205e50 <commands+0xe0>
    if (boot_dtb == 0) {
ffffffffc020065c:	120a0463          	beqz	s4,ffffffffc0200784 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200660:	57f5                	li	a5,-3
ffffffffc0200662:	07fa                	slli	a5,a5,0x1e
ffffffffc0200664:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200668:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020066a:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020066e:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200670:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200674:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200678:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020067c:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200680:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200684:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200686:	8ec9                	or	a3,a3,a0
ffffffffc0200688:	0087979b          	slliw	a5,a5,0x8
ffffffffc020068c:	1b7d                	addi	s6,s6,-1
ffffffffc020068e:	0167f7b3          	and	a5,a5,s6
ffffffffc0200692:	8dd5                	or	a1,a1,a3
ffffffffc0200694:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc0200696:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020069a:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc020069c:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe090c1>
ffffffffc02006a0:	10f59163          	bne	a1,a5,ffffffffc02007a2 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02006a4:	471c                	lw	a5,8(a4)
ffffffffc02006a6:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02006a8:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006aa:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02006ae:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02006b2:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b6:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ba:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006be:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006c2:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006c6:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ca:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ce:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006d2:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006d4:	01146433          	or	s0,s0,a7
ffffffffc02006d8:	0086969b          	slliw	a3,a3,0x8
ffffffffc02006dc:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006e0:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006e2:	0087979b          	slliw	a5,a5,0x8
ffffffffc02006e6:	8c49                	or	s0,s0,a0
ffffffffc02006e8:	0166f6b3          	and	a3,a3,s6
ffffffffc02006ec:	00ca6a33          	or	s4,s4,a2
ffffffffc02006f0:	0167f7b3          	and	a5,a5,s6
ffffffffc02006f4:	8c55                	or	s0,s0,a3
ffffffffc02006f6:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02006fa:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02006fc:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02006fe:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200700:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200704:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200706:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200708:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc020070c:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020070e:	00005917          	auipc	s2,0x5
ffffffffc0200712:	79290913          	addi	s2,s2,1938 # ffffffffc0205ea0 <commands+0x130>
ffffffffc0200716:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200718:	4d91                	li	s11,4
ffffffffc020071a:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020071c:	00005497          	auipc	s1,0x5
ffffffffc0200720:	77c48493          	addi	s1,s1,1916 # ffffffffc0205e98 <commands+0x128>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200724:	000a2703          	lw	a4,0(s4)
ffffffffc0200728:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020072c:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200730:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200734:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200738:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020073c:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200740:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200742:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200746:	0087171b          	slliw	a4,a4,0x8
ffffffffc020074a:	8fd5                	or	a5,a5,a3
ffffffffc020074c:	00eb7733          	and	a4,s6,a4
ffffffffc0200750:	8fd9                	or	a5,a5,a4
ffffffffc0200752:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200754:	09778c63          	beq	a5,s7,ffffffffc02007ec <dtb_init+0x1ee>
ffffffffc0200758:	00fbea63          	bltu	s7,a5,ffffffffc020076c <dtb_init+0x16e>
ffffffffc020075c:	07a78663          	beq	a5,s10,ffffffffc02007c8 <dtb_init+0x1ca>
ffffffffc0200760:	4709                	li	a4,2
ffffffffc0200762:	00e79763          	bne	a5,a4,ffffffffc0200770 <dtb_init+0x172>
ffffffffc0200766:	4c81                	li	s9,0
ffffffffc0200768:	8a56                	mv	s4,s5
ffffffffc020076a:	bf6d                	j	ffffffffc0200724 <dtb_init+0x126>
ffffffffc020076c:	ffb78ee3          	beq	a5,s11,ffffffffc0200768 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200770:	00005517          	auipc	a0,0x5
ffffffffc0200774:	7a850513          	addi	a0,a0,1960 # ffffffffc0205f18 <commands+0x1a8>
ffffffffc0200778:	a1dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020077c:	00005517          	auipc	a0,0x5
ffffffffc0200780:	7d450513          	addi	a0,a0,2004 # ffffffffc0205f50 <commands+0x1e0>
}
ffffffffc0200784:	7446                	ld	s0,112(sp)
ffffffffc0200786:	70e6                	ld	ra,120(sp)
ffffffffc0200788:	74a6                	ld	s1,104(sp)
ffffffffc020078a:	7906                	ld	s2,96(sp)
ffffffffc020078c:	69e6                	ld	s3,88(sp)
ffffffffc020078e:	6a46                	ld	s4,80(sp)
ffffffffc0200790:	6aa6                	ld	s5,72(sp)
ffffffffc0200792:	6b06                	ld	s6,64(sp)
ffffffffc0200794:	7be2                	ld	s7,56(sp)
ffffffffc0200796:	7c42                	ld	s8,48(sp)
ffffffffc0200798:	7ca2                	ld	s9,40(sp)
ffffffffc020079a:	7d02                	ld	s10,32(sp)
ffffffffc020079c:	6de2                	ld	s11,24(sp)
ffffffffc020079e:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02007a0:	bad5                	j	ffffffffc0200194 <cprintf>
}
ffffffffc02007a2:	7446                	ld	s0,112(sp)
ffffffffc02007a4:	70e6                	ld	ra,120(sp)
ffffffffc02007a6:	74a6                	ld	s1,104(sp)
ffffffffc02007a8:	7906                	ld	s2,96(sp)
ffffffffc02007aa:	69e6                	ld	s3,88(sp)
ffffffffc02007ac:	6a46                	ld	s4,80(sp)
ffffffffc02007ae:	6aa6                	ld	s5,72(sp)
ffffffffc02007b0:	6b06                	ld	s6,64(sp)
ffffffffc02007b2:	7be2                	ld	s7,56(sp)
ffffffffc02007b4:	7c42                	ld	s8,48(sp)
ffffffffc02007b6:	7ca2                	ld	s9,40(sp)
ffffffffc02007b8:	7d02                	ld	s10,32(sp)
ffffffffc02007ba:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02007bc:	00005517          	auipc	a0,0x5
ffffffffc02007c0:	6b450513          	addi	a0,a0,1716 # ffffffffc0205e70 <commands+0x100>
}
ffffffffc02007c4:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02007c6:	b2f9                	j	ffffffffc0200194 <cprintf>
                int name_len = strlen(name);
ffffffffc02007c8:	8556                	mv	a0,s5
ffffffffc02007ca:	26c050ef          	jal	ra,ffffffffc0205a36 <strlen>
ffffffffc02007ce:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d0:	4619                	li	a2,6
ffffffffc02007d2:	85a6                	mv	a1,s1
ffffffffc02007d4:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02007d6:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d8:	2c4050ef          	jal	ra,ffffffffc0205a9c <strncmp>
ffffffffc02007dc:	e111                	bnez	a0,ffffffffc02007e0 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc02007de:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02007e0:	0a91                	addi	s5,s5,4
ffffffffc02007e2:	9ad2                	add	s5,s5,s4
ffffffffc02007e4:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02007e8:	8a56                	mv	s4,s5
ffffffffc02007ea:	bf2d                	j	ffffffffc0200724 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc02007ec:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02007f0:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007f4:	0087d71b          	srliw	a4,a5,0x8
ffffffffc02007f8:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007fc:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200800:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200804:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200808:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020080c:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200810:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200814:	00eaeab3          	or	s5,s5,a4
ffffffffc0200818:	00fb77b3          	and	a5,s6,a5
ffffffffc020081c:	00faeab3          	or	s5,s5,a5
ffffffffc0200820:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200822:	000c9c63          	bnez	s9,ffffffffc020083a <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200826:	1a82                	slli	s5,s5,0x20
ffffffffc0200828:	00368793          	addi	a5,a3,3
ffffffffc020082c:	020ada93          	srli	s5,s5,0x20
ffffffffc0200830:	9abe                	add	s5,s5,a5
ffffffffc0200832:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200836:	8a56                	mv	s4,s5
ffffffffc0200838:	b5f5                	j	ffffffffc0200724 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc020083a:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020083e:	85ca                	mv	a1,s2
ffffffffc0200840:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200842:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200846:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020084a:	0187971b          	slliw	a4,a5,0x18
ffffffffc020084e:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200852:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200856:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200858:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020085c:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200860:	8d59                	or	a0,a0,a4
ffffffffc0200862:	00fb77b3          	and	a5,s6,a5
ffffffffc0200866:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200868:	1502                	slli	a0,a0,0x20
ffffffffc020086a:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020086c:	9522                	add	a0,a0,s0
ffffffffc020086e:	210050ef          	jal	ra,ffffffffc0205a7e <strcmp>
ffffffffc0200872:	66a2                	ld	a3,8(sp)
ffffffffc0200874:	f94d                	bnez	a0,ffffffffc0200826 <dtb_init+0x228>
ffffffffc0200876:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200826 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020087a:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020087e:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200882:	00005517          	auipc	a0,0x5
ffffffffc0200886:	62650513          	addi	a0,a0,1574 # ffffffffc0205ea8 <commands+0x138>
           fdt32_to_cpu(x >> 32);
ffffffffc020088a:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020088e:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc0200892:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200896:	0187de1b          	srliw	t3,a5,0x18
ffffffffc020089a:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020089e:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008a2:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008a6:	0187d693          	srli	a3,a5,0x18
ffffffffc02008aa:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02008ae:	0087579b          	srliw	a5,a4,0x8
ffffffffc02008b2:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008b6:	0106561b          	srliw	a2,a2,0x10
ffffffffc02008ba:	010f6f33          	or	t5,t5,a6
ffffffffc02008be:	0187529b          	srliw	t0,a4,0x18
ffffffffc02008c2:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008c6:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008ca:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008ce:	0186f6b3          	and	a3,a3,s8
ffffffffc02008d2:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02008d6:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008da:	0107581b          	srliw	a6,a4,0x10
ffffffffc02008de:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008e2:	8361                	srli	a4,a4,0x18
ffffffffc02008e4:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008e8:	0105d59b          	srliw	a1,a1,0x10
ffffffffc02008ec:	01e6e6b3          	or	a3,a3,t5
ffffffffc02008f0:	00cb7633          	and	a2,s6,a2
ffffffffc02008f4:	0088181b          	slliw	a6,a6,0x8
ffffffffc02008f8:	0085959b          	slliw	a1,a1,0x8
ffffffffc02008fc:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200900:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200904:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200908:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020090c:	0088989b          	slliw	a7,a7,0x8
ffffffffc0200910:	011b78b3          	and	a7,s6,a7
ffffffffc0200914:	005eeeb3          	or	t4,t4,t0
ffffffffc0200918:	00c6e733          	or	a4,a3,a2
ffffffffc020091c:	006c6c33          	or	s8,s8,t1
ffffffffc0200920:	010b76b3          	and	a3,s6,a6
ffffffffc0200924:	00bb7b33          	and	s6,s6,a1
ffffffffc0200928:	01d7e7b3          	or	a5,a5,t4
ffffffffc020092c:	016c6b33          	or	s6,s8,s6
ffffffffc0200930:	01146433          	or	s0,s0,a7
ffffffffc0200934:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc0200936:	1702                	slli	a4,a4,0x20
ffffffffc0200938:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020093a:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020093c:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020093e:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200940:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200944:	0167eb33          	or	s6,a5,s6
ffffffffc0200948:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc020094a:	84bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc020094e:	85a2                	mv	a1,s0
ffffffffc0200950:	00005517          	auipc	a0,0x5
ffffffffc0200954:	57850513          	addi	a0,a0,1400 # ffffffffc0205ec8 <commands+0x158>
ffffffffc0200958:	83dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020095c:	014b5613          	srli	a2,s6,0x14
ffffffffc0200960:	85da                	mv	a1,s6
ffffffffc0200962:	00005517          	auipc	a0,0x5
ffffffffc0200966:	57e50513          	addi	a0,a0,1406 # ffffffffc0205ee0 <commands+0x170>
ffffffffc020096a:	82bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc020096e:	008b05b3          	add	a1,s6,s0
ffffffffc0200972:	15fd                	addi	a1,a1,-1
ffffffffc0200974:	00005517          	auipc	a0,0x5
ffffffffc0200978:	58c50513          	addi	a0,a0,1420 # ffffffffc0205f00 <commands+0x190>
ffffffffc020097c:	819ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200980:	00005517          	auipc	a0,0x5
ffffffffc0200984:	5d050513          	addi	a0,a0,1488 # ffffffffc0205f50 <commands+0x1e0>
        memory_base = mem_base;
ffffffffc0200988:	000d6797          	auipc	a5,0xd6
ffffffffc020098c:	4287b023          	sd	s0,1056(a5) # ffffffffc02d6da8 <memory_base>
        memory_size = mem_size;
ffffffffc0200990:	000d6797          	auipc	a5,0xd6
ffffffffc0200994:	4367b023          	sd	s6,1056(a5) # ffffffffc02d6db0 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200998:	b3f5                	j	ffffffffc0200784 <dtb_init+0x186>

ffffffffc020099a <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc020099a:	000d6517          	auipc	a0,0xd6
ffffffffc020099e:	40e53503          	ld	a0,1038(a0) # ffffffffc02d6da8 <memory_base>
ffffffffc02009a2:	8082                	ret

ffffffffc02009a4 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02009a4:	000d6517          	auipc	a0,0xd6
ffffffffc02009a8:	40c53503          	ld	a0,1036(a0) # ffffffffc02d6db0 <memory_size>
ffffffffc02009ac:	8082                	ret

ffffffffc02009ae <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02009ae:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02009b2:	8082                	ret

ffffffffc02009b4 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02009b4:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02009b8:	8082                	ret

ffffffffc02009ba <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02009ba:	8082                	ret

ffffffffc02009bc <idt_init>:
     * - 设置为 0：表示当前已经在内核态执行。
     * - 在 trapentry.S 中，会检查 sscratch：
     * - 如果是 0，说明发生中断前已经在内核，不需要切换栈。
     * - 如果非 0，说明发生中断前在用户态，sscratch 里存的是内核栈地址，需要交换 sp 切换到内核栈。
     */
    write_csr(sscratch, 0);
ffffffffc02009bc:	14005073          	csrwi	sscratch,0
    /* * [中断入口] 设置 stvec (Supervisor Trap Vector Base Address)
     * 将中断向量表的基地址设置为 __alltraps (定义在 trapentry.S)。
     * 当任何中断或异常发生时，CPU 会自动跳转到 __alltraps 处的汇编代码开始执行。
     * __alltraps 负责保存所有寄存器 (Context Save) 并调用 trap() 函数。
     */
    write_csr(stvec, &__alltraps);
ffffffffc02009c0:	00000797          	auipc	a5,0x0
ffffffffc02009c4:	5a078793          	addi	a5,a5,1440 # ffffffffc0200f60 <__alltraps>
ffffffffc02009c8:	10579073          	csrw	stvec,a5
    /* * [内存权限] 设置 sstatus 寄存器
     * SSTATUS_SUM (Supervisor User Memory access):
     * 允许内核模式下的代码直接读取/写入用户模式的内存页。
     * 这在系统调用处理（如 sys_write）中读取用户传入的字符串参数时是必须的。
     */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc02009cc:	000407b7          	lui	a5,0x40
ffffffffc02009d0:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc02009d4:	8082                	ret

ffffffffc02009d6 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009d6:	610c                	ld	a1,0(a0)
{
ffffffffc02009d8:	1141                	addi	sp,sp,-16
ffffffffc02009da:	e022                	sd	s0,0(sp)
ffffffffc02009dc:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009de:	00005517          	auipc	a0,0x5
ffffffffc02009e2:	58a50513          	addi	a0,a0,1418 # ffffffffc0205f68 <commands+0x1f8>
{
ffffffffc02009e6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009e8:	facff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009ec:	640c                	ld	a1,8(s0)
ffffffffc02009ee:	00005517          	auipc	a0,0x5
ffffffffc02009f2:	59250513          	addi	a0,a0,1426 # ffffffffc0205f80 <commands+0x210>
ffffffffc02009f6:	f9eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009fa:	680c                	ld	a1,16(s0)
ffffffffc02009fc:	00005517          	auipc	a0,0x5
ffffffffc0200a00:	59c50513          	addi	a0,a0,1436 # ffffffffc0205f98 <commands+0x228>
ffffffffc0200a04:	f90ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200a08:	6c0c                	ld	a1,24(s0)
ffffffffc0200a0a:	00005517          	auipc	a0,0x5
ffffffffc0200a0e:	5a650513          	addi	a0,a0,1446 # ffffffffc0205fb0 <commands+0x240>
ffffffffc0200a12:	f82ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200a16:	700c                	ld	a1,32(s0)
ffffffffc0200a18:	00005517          	auipc	a0,0x5
ffffffffc0200a1c:	5b050513          	addi	a0,a0,1456 # ffffffffc0205fc8 <commands+0x258>
ffffffffc0200a20:	f74ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200a24:	740c                	ld	a1,40(s0)
ffffffffc0200a26:	00005517          	auipc	a0,0x5
ffffffffc0200a2a:	5ba50513          	addi	a0,a0,1466 # ffffffffc0205fe0 <commands+0x270>
ffffffffc0200a2e:	f66ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200a32:	780c                	ld	a1,48(s0)
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	5c450513          	addi	a0,a0,1476 # ffffffffc0205ff8 <commands+0x288>
ffffffffc0200a3c:	f58ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a40:	7c0c                	ld	a1,56(s0)
ffffffffc0200a42:	00005517          	auipc	a0,0x5
ffffffffc0200a46:	5ce50513          	addi	a0,a0,1486 # ffffffffc0206010 <commands+0x2a0>
ffffffffc0200a4a:	f4aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a4e:	602c                	ld	a1,64(s0)
ffffffffc0200a50:	00005517          	auipc	a0,0x5
ffffffffc0200a54:	5d850513          	addi	a0,a0,1496 # ffffffffc0206028 <commands+0x2b8>
ffffffffc0200a58:	f3cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a5c:	642c                	ld	a1,72(s0)
ffffffffc0200a5e:	00005517          	auipc	a0,0x5
ffffffffc0200a62:	5e250513          	addi	a0,a0,1506 # ffffffffc0206040 <commands+0x2d0>
ffffffffc0200a66:	f2eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a6a:	682c                	ld	a1,80(s0)
ffffffffc0200a6c:	00005517          	auipc	a0,0x5
ffffffffc0200a70:	5ec50513          	addi	a0,a0,1516 # ffffffffc0206058 <commands+0x2e8>
ffffffffc0200a74:	f20ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a78:	6c2c                	ld	a1,88(s0)
ffffffffc0200a7a:	00005517          	auipc	a0,0x5
ffffffffc0200a7e:	5f650513          	addi	a0,a0,1526 # ffffffffc0206070 <commands+0x300>
ffffffffc0200a82:	f12ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a86:	702c                	ld	a1,96(s0)
ffffffffc0200a88:	00005517          	auipc	a0,0x5
ffffffffc0200a8c:	60050513          	addi	a0,a0,1536 # ffffffffc0206088 <commands+0x318>
ffffffffc0200a90:	f04ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a94:	742c                	ld	a1,104(s0)
ffffffffc0200a96:	00005517          	auipc	a0,0x5
ffffffffc0200a9a:	60a50513          	addi	a0,a0,1546 # ffffffffc02060a0 <commands+0x330>
ffffffffc0200a9e:	ef6ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200aa2:	782c                	ld	a1,112(s0)
ffffffffc0200aa4:	00005517          	auipc	a0,0x5
ffffffffc0200aa8:	61450513          	addi	a0,a0,1556 # ffffffffc02060b8 <commands+0x348>
ffffffffc0200aac:	ee8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200ab0:	7c2c                	ld	a1,120(s0)
ffffffffc0200ab2:	00005517          	auipc	a0,0x5
ffffffffc0200ab6:	61e50513          	addi	a0,a0,1566 # ffffffffc02060d0 <commands+0x360>
ffffffffc0200aba:	edaff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200abe:	604c                	ld	a1,128(s0)
ffffffffc0200ac0:	00005517          	auipc	a0,0x5
ffffffffc0200ac4:	62850513          	addi	a0,a0,1576 # ffffffffc02060e8 <commands+0x378>
ffffffffc0200ac8:	eccff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200acc:	644c                	ld	a1,136(s0)
ffffffffc0200ace:	00005517          	auipc	a0,0x5
ffffffffc0200ad2:	63250513          	addi	a0,a0,1586 # ffffffffc0206100 <commands+0x390>
ffffffffc0200ad6:	ebeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200ada:	684c                	ld	a1,144(s0)
ffffffffc0200adc:	00005517          	auipc	a0,0x5
ffffffffc0200ae0:	63c50513          	addi	a0,a0,1596 # ffffffffc0206118 <commands+0x3a8>
ffffffffc0200ae4:	eb0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200ae8:	6c4c                	ld	a1,152(s0)
ffffffffc0200aea:	00005517          	auipc	a0,0x5
ffffffffc0200aee:	64650513          	addi	a0,a0,1606 # ffffffffc0206130 <commands+0x3c0>
ffffffffc0200af2:	ea2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200af6:	704c                	ld	a1,160(s0)
ffffffffc0200af8:	00005517          	auipc	a0,0x5
ffffffffc0200afc:	65050513          	addi	a0,a0,1616 # ffffffffc0206148 <commands+0x3d8>
ffffffffc0200b00:	e94ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200b04:	744c                	ld	a1,168(s0)
ffffffffc0200b06:	00005517          	auipc	a0,0x5
ffffffffc0200b0a:	65a50513          	addi	a0,a0,1626 # ffffffffc0206160 <commands+0x3f0>
ffffffffc0200b0e:	e86ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200b12:	784c                	ld	a1,176(s0)
ffffffffc0200b14:	00005517          	auipc	a0,0x5
ffffffffc0200b18:	66450513          	addi	a0,a0,1636 # ffffffffc0206178 <commands+0x408>
ffffffffc0200b1c:	e78ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200b20:	7c4c                	ld	a1,184(s0)
ffffffffc0200b22:	00005517          	auipc	a0,0x5
ffffffffc0200b26:	66e50513          	addi	a0,a0,1646 # ffffffffc0206190 <commands+0x420>
ffffffffc0200b2a:	e6aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200b2e:	606c                	ld	a1,192(s0)
ffffffffc0200b30:	00005517          	auipc	a0,0x5
ffffffffc0200b34:	67850513          	addi	a0,a0,1656 # ffffffffc02061a8 <commands+0x438>
ffffffffc0200b38:	e5cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200b3c:	646c                	ld	a1,200(s0)
ffffffffc0200b3e:	00005517          	auipc	a0,0x5
ffffffffc0200b42:	68250513          	addi	a0,a0,1666 # ffffffffc02061c0 <commands+0x450>
ffffffffc0200b46:	e4eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b4a:	686c                	ld	a1,208(s0)
ffffffffc0200b4c:	00005517          	auipc	a0,0x5
ffffffffc0200b50:	68c50513          	addi	a0,a0,1676 # ffffffffc02061d8 <commands+0x468>
ffffffffc0200b54:	e40ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b58:	6c6c                	ld	a1,216(s0)
ffffffffc0200b5a:	00005517          	auipc	a0,0x5
ffffffffc0200b5e:	69650513          	addi	a0,a0,1686 # ffffffffc02061f0 <commands+0x480>
ffffffffc0200b62:	e32ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b66:	706c                	ld	a1,224(s0)
ffffffffc0200b68:	00005517          	auipc	a0,0x5
ffffffffc0200b6c:	6a050513          	addi	a0,a0,1696 # ffffffffc0206208 <commands+0x498>
ffffffffc0200b70:	e24ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b74:	746c                	ld	a1,232(s0)
ffffffffc0200b76:	00005517          	auipc	a0,0x5
ffffffffc0200b7a:	6aa50513          	addi	a0,a0,1706 # ffffffffc0206220 <commands+0x4b0>
ffffffffc0200b7e:	e16ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b82:	786c                	ld	a1,240(s0)
ffffffffc0200b84:	00005517          	auipc	a0,0x5
ffffffffc0200b88:	6b450513          	addi	a0,a0,1716 # ffffffffc0206238 <commands+0x4c8>
ffffffffc0200b8c:	e08ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b90:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b92:	6402                	ld	s0,0(sp)
ffffffffc0200b94:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b96:	00005517          	auipc	a0,0x5
ffffffffc0200b9a:	6ba50513          	addi	a0,a0,1722 # ffffffffc0206250 <commands+0x4e0>
}
ffffffffc0200b9e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ba0:	df4ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200ba4 <print_trapframe>:
{
ffffffffc0200ba4:	1141                	addi	sp,sp,-16
ffffffffc0200ba6:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200ba8:	85aa                	mv	a1,a0
{
ffffffffc0200baa:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200bac:	00005517          	auipc	a0,0x5
ffffffffc0200bb0:	6bc50513          	addi	a0,a0,1724 # ffffffffc0206268 <commands+0x4f8>
{
ffffffffc0200bb4:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200bb6:	ddeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200bba:	8522                	mv	a0,s0
ffffffffc0200bbc:	e1bff0ef          	jal	ra,ffffffffc02009d6 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200bc0:	10043583          	ld	a1,256(s0)
ffffffffc0200bc4:	00005517          	auipc	a0,0x5
ffffffffc0200bc8:	6bc50513          	addi	a0,a0,1724 # ffffffffc0206280 <commands+0x510>
ffffffffc0200bcc:	dc8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200bd0:	10843583          	ld	a1,264(s0)
ffffffffc0200bd4:	00005517          	auipc	a0,0x5
ffffffffc0200bd8:	6c450513          	addi	a0,a0,1732 # ffffffffc0206298 <commands+0x528>
ffffffffc0200bdc:	db8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200be0:	11043583          	ld	a1,272(s0)
ffffffffc0200be4:	00005517          	auipc	a0,0x5
ffffffffc0200be8:	6cc50513          	addi	a0,a0,1740 # ffffffffc02062b0 <commands+0x540>
ffffffffc0200bec:	da8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf0:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bf4:	6402                	ld	s0,0(sp)
ffffffffc0200bf6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf8:	00005517          	auipc	a0,0x5
ffffffffc0200bfc:	6c850513          	addi	a0,a0,1736 # ffffffffc02062c0 <commands+0x550>
}
ffffffffc0200c00:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200c02:	d92ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200c06 <interrupt_handler>:
 * 这里的核心逻辑对应实验报告中的【时间片轮转调度 (RR)】实现。
 */
void interrupt_handler(struct trapframe *tf)
{
    // cause 最高位为1表示中断，去掉最高位得到具体的中断号
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200c06:	11853783          	ld	a5,280(a0)
ffffffffc0200c0a:	472d                	li	a4,11
ffffffffc0200c0c:	0786                	slli	a5,a5,0x1
ffffffffc0200c0e:	8385                	srli	a5,a5,0x1
ffffffffc0200c10:	0cf76863          	bltu	a4,a5,ffffffffc0200ce0 <interrupt_handler+0xda>
ffffffffc0200c14:	00005717          	auipc	a4,0x5
ffffffffc0200c18:	76470713          	addi	a4,a4,1892 # ffffffffc0206378 <commands+0x608>
ffffffffc0200c1c:	078a                	slli	a5,a5,0x2
ffffffffc0200c1e:	97ba                	add	a5,a5,a4
ffffffffc0200c20:	439c                	lw	a5,0(a5)
{
ffffffffc0200c22:	1141                	addi	sp,sp,-16
ffffffffc0200c24:	e406                	sd	ra,8(sp)
ffffffffc0200c26:	97ba                	add	a5,a5,a4
ffffffffc0200c28:	8782                	jr	a5
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c2a:	60a2                	ld	ra,8(sp)
        cprintf("Machine software interrupt\n");
ffffffffc0200c2c:	00005517          	auipc	a0,0x5
ffffffffc0200c30:	70c50513          	addi	a0,a0,1804 # ffffffffc0206338 <commands+0x5c8>
}
ffffffffc0200c34:	0141                	addi	sp,sp,16
        cprintf("Machine software interrupt\n");
ffffffffc0200c36:	d5eff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200c3a:	60a2                	ld	ra,8(sp)
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c3c:	00005517          	auipc	a0,0x5
ffffffffc0200c40:	6dc50513          	addi	a0,a0,1756 # ffffffffc0206318 <commands+0x5a8>
}
ffffffffc0200c44:	0141                	addi	sp,sp,16
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c46:	d4eff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200c4a:	60a2                	ld	ra,8(sp)
        cprintf("User software interrupt\n");
ffffffffc0200c4c:	00005517          	auipc	a0,0x5
ffffffffc0200c50:	68c50513          	addi	a0,a0,1676 # ffffffffc02062d8 <commands+0x568>
}
ffffffffc0200c54:	0141                	addi	sp,sp,16
        cprintf("User software interrupt\n");
ffffffffc0200c56:	d3eff06f          	j	ffffffffc0200194 <cprintf>
        clock_set_next_event();
ffffffffc0200c5a:	919ff0ef          	jal	ra,ffffffffc0200572 <clock_set_next_event>
        ticks++;
ffffffffc0200c5e:	000d6697          	auipc	a3,0xd6
ffffffffc0200c62:	13a68693          	addi	a3,a3,314 # ffffffffc02d6d98 <ticks>
ffffffffc0200c66:	629c                	ld	a5,0(a3)
        if (current != NULL) {
ffffffffc0200c68:	000d6717          	auipc	a4,0xd6
ffffffffc0200c6c:	1a873703          	ld	a4,424(a4) # ffffffffc02d6e10 <current>
        ticks++;
ffffffffc0200c70:	0785                	addi	a5,a5,1
ffffffffc0200c72:	e29c                	sd	a5,0(a3)
        if (current != NULL) {
ffffffffc0200c74:	cb09                	beqz	a4,ffffffffc0200c86 <interrupt_handler+0x80>
            if (current->time_slice > 0) {
ffffffffc0200c76:	10872783          	lw	a5,264(a4)
ffffffffc0200c7a:	00f05563          	blez	a5,ffffffffc0200c84 <interrupt_handler+0x7e>
                current->time_slice--;
ffffffffc0200c7e:	37fd                	addiw	a5,a5,-1
ffffffffc0200c80:	10f72423          	sw	a5,264(a4)
            if (current->time_slice == 0) {
ffffffffc0200c84:	cb9d                	beqz	a5,ffffffffc0200cba <interrupt_handler+0xb4>
}
ffffffffc0200c86:	60a2                	ld	ra,8(sp)
ffffffffc0200c88:	0141                	addi	sp,sp,16
ffffffffc0200c8a:	8082                	ret
        clock_set_next_event();
ffffffffc0200c8c:	8e7ff0ef          	jal	ra,ffffffffc0200572 <clock_set_next_event>
        ticks++;
ffffffffc0200c90:	000d6697          	auipc	a3,0xd6
ffffffffc0200c94:	10868693          	addi	a3,a3,264 # ffffffffc02d6d98 <ticks>
ffffffffc0200c98:	629c                	ld	a5,0(a3)
        if (current != NULL) {
ffffffffc0200c9a:	000d6717          	auipc	a4,0xd6
ffffffffc0200c9e:	17673703          	ld	a4,374(a4) # ffffffffc02d6e10 <current>
        ticks++;
ffffffffc0200ca2:	0785                	addi	a5,a5,1
ffffffffc0200ca4:	e29c                	sd	a5,0(a3)
        if (current != NULL) {
ffffffffc0200ca6:	d365                	beqz	a4,ffffffffc0200c86 <interrupt_handler+0x80>
            if (current->time_slice > 0) {
ffffffffc0200ca8:	10872783          	lw	a5,264(a4)
ffffffffc0200cac:	00f05763          	blez	a5,ffffffffc0200cba <interrupt_handler+0xb4>
                current->time_slice--;
ffffffffc0200cb0:	fff7869b          	addiw	a3,a5,-1
ffffffffc0200cb4:	10d72423          	sw	a3,264(a4)
            if (current->time_slice <= 0) {
ffffffffc0200cb8:	f6f9                	bnez	a3,ffffffffc0200c86 <interrupt_handler+0x80>
                current->need_resched = 1;
ffffffffc0200cba:	4785                	li	a5,1
ffffffffc0200cbc:	ef1c                	sd	a5,24(a4)
ffffffffc0200cbe:	b7e1                	j	ffffffffc0200c86 <interrupt_handler+0x80>
}
ffffffffc0200cc0:	60a2                	ld	ra,8(sp)
        cprintf("Supervisor external interrupt\n");
ffffffffc0200cc2:	00005517          	auipc	a0,0x5
ffffffffc0200cc6:	69650513          	addi	a0,a0,1686 # ffffffffc0206358 <commands+0x5e8>
}
ffffffffc0200cca:	0141                	addi	sp,sp,16
        cprintf("Supervisor external interrupt\n");
ffffffffc0200ccc:	cc8ff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200cd0:	60a2                	ld	ra,8(sp)
        cprintf("Supervisor software interrupt\n");
ffffffffc0200cd2:	00005517          	auipc	a0,0x5
ffffffffc0200cd6:	62650513          	addi	a0,a0,1574 # ffffffffc02062f8 <commands+0x588>
}
ffffffffc0200cda:	0141                	addi	sp,sp,16
        cprintf("Supervisor software interrupt\n");
ffffffffc0200cdc:	cb8ff06f          	j	ffffffffc0200194 <cprintf>
        print_trapframe(tf);
ffffffffc0200ce0:	b5d1                	j	ffffffffc0200ba4 <print_trapframe>

ffffffffc0200ce2 <exception_handler>:
 * 2. 缺页异常处理 (Page Fault Handling for COW)
 */
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200ce2:	11853783          	ld	a5,280(a0)
{
ffffffffc0200ce6:	1101                	addi	sp,sp,-32
ffffffffc0200ce8:	e822                	sd	s0,16(sp)
ffffffffc0200cea:	ec06                	sd	ra,24(sp)
ffffffffc0200cec:	e426                	sd	s1,8(sp)
ffffffffc0200cee:	473d                	li	a4,15
ffffffffc0200cf0:	842a                	mv	s0,a0
ffffffffc0200cf2:	18f76063          	bltu	a4,a5,ffffffffc0200e72 <exception_handler+0x190>
ffffffffc0200cf6:	00006717          	auipc	a4,0x6
ffffffffc0200cfa:	88270713          	addi	a4,a4,-1918 # ffffffffc0206578 <commands+0x808>
ffffffffc0200cfe:	078a                	slli	a5,a5,0x2
ffffffffc0200d00:	97ba                	add	a5,a5,a4
ffffffffc0200d02:	439c                	lw	a5,0(a5)
ffffffffc0200d04:	97ba                	add	a5,a5,a4
ffffffffc0200d06:	8782                	jr	a5
        tf->epc += 4; // 重要：sepc 指向发生异常的指令 (ecall)。
                      // 我们希望处理完后返回到 ecall 的下一条指令继续执行，所以 PC+4。
        syscall();    // 查表调用 sys_fork, sys_exit, sys_write 等
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200d08:	00005517          	auipc	a0,0x5
ffffffffc0200d0c:	78850513          	addi	a0,a0,1928 # ffffffffc0206490 <commands+0x720>
ffffffffc0200d10:	c84ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        tf->epc += 4;
ffffffffc0200d14:	10843783          	ld	a5,264(s0)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200d18:	60e2                	ld	ra,24(sp)
ffffffffc0200d1a:	64a2                	ld	s1,8(sp)
        tf->epc += 4;
ffffffffc0200d1c:	0791                	addi	a5,a5,4
ffffffffc0200d1e:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200d22:	6442                	ld	s0,16(sp)
ffffffffc0200d24:	6105                	addi	sp,sp,32
        syscall();
ffffffffc0200d26:	08b0406f          	j	ffffffffc02055b0 <syscall>
        cprintf("Environment call from H-mode\n");
ffffffffc0200d2a:	00005517          	auipc	a0,0x5
ffffffffc0200d2e:	78650513          	addi	a0,a0,1926 # ffffffffc02064b0 <commands+0x740>
}
ffffffffc0200d32:	6442                	ld	s0,16(sp)
ffffffffc0200d34:	60e2                	ld	ra,24(sp)
ffffffffc0200d36:	64a2                	ld	s1,8(sp)
ffffffffc0200d38:	6105                	addi	sp,sp,32
        cprintf("Instruction access fault\n");
ffffffffc0200d3a:	c5aff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200d3e:	00005517          	auipc	a0,0x5
ffffffffc0200d42:	79250513          	addi	a0,a0,1938 # ffffffffc02064d0 <commands+0x760>
ffffffffc0200d46:	b7f5                	j	ffffffffc0200d32 <exception_handler+0x50>
        cprintf("Instruction page fault\n");
ffffffffc0200d48:	00005517          	auipc	a0,0x5
ffffffffc0200d4c:	7a850513          	addi	a0,a0,1960 # ffffffffc02064f0 <commands+0x780>
ffffffffc0200d50:	c44ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (do_pgfault(current->mm, tf->cause, tf->tval) != 0) {
ffffffffc0200d54:	000d6497          	auipc	s1,0xd6
ffffffffc0200d58:	0bc48493          	addi	s1,s1,188 # ffffffffc02d6e10 <current>
ffffffffc0200d5c:	609c                	ld	a5,0(s1)
ffffffffc0200d5e:	11043603          	ld	a2,272(s0)
ffffffffc0200d62:	11842583          	lw	a1,280(s0)
ffffffffc0200d66:	7788                	ld	a0,40(a5)
ffffffffc0200d68:	1e4030ef          	jal	ra,ffffffffc0203f4c <do_pgfault>
ffffffffc0200d6c:	0c050f63          	beqz	a0,ffffffffc0200e4a <exception_handler+0x168>
            print_trapframe(tf); // 如果处理失败（真是非法访问），则打印帧并杀进程
ffffffffc0200d70:	8522                	mv	a0,s0
ffffffffc0200d72:	e33ff0ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
            if (current == NULL) {
ffffffffc0200d76:	609c                	ld	a5,0(s1)
ffffffffc0200d78:	ebc9                	bnez	a5,ffffffffc0200e0a <exception_handler+0x128>
                panic("handle_exception: page fault in kernel (current == NULL)");
ffffffffc0200d7a:	00005617          	auipc	a2,0x5
ffffffffc0200d7e:	78e60613          	addi	a2,a2,1934 # ffffffffc0206508 <commands+0x798>
ffffffffc0200d82:	13e00593          	li	a1,318
ffffffffc0200d86:	00005517          	auipc	a0,0x5
ffffffffc0200d8a:	6da50513          	addi	a0,a0,1754 # ffffffffc0206460 <commands+0x6f0>
ffffffffc0200d8e:	f00ff0ef          	jal	ra,ffffffffc020048e <__panic>
        cprintf("Load page fault\n");
ffffffffc0200d92:	00005517          	auipc	a0,0x5
ffffffffc0200d96:	7b650513          	addi	a0,a0,1974 # ffffffffc0206548 <commands+0x7d8>
ffffffffc0200d9a:	bfaff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (do_pgfault(current->mm, tf->cause, tf->tval) != 0) {
ffffffffc0200d9e:	000d6497          	auipc	s1,0xd6
ffffffffc0200da2:	07248493          	addi	s1,s1,114 # ffffffffc02d6e10 <current>
ffffffffc0200da6:	609c                	ld	a5,0(s1)
ffffffffc0200da8:	11043603          	ld	a2,272(s0)
ffffffffc0200dac:	11842583          	lw	a1,280(s0)
ffffffffc0200db0:	7788                	ld	a0,40(a5)
ffffffffc0200db2:	19a030ef          	jal	ra,ffffffffc0203f4c <do_pgfault>
ffffffffc0200db6:	c951                	beqz	a0,ffffffffc0200e4a <exception_handler+0x168>
            print_trapframe(tf);
ffffffffc0200db8:	8522                	mv	a0,s0
ffffffffc0200dba:	debff0ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
            if (current == NULL) {
ffffffffc0200dbe:	609c                	ld	a5,0(s1)
ffffffffc0200dc0:	e7a9                	bnez	a5,ffffffffc0200e0a <exception_handler+0x128>
                panic("handle_exception: page fault in kernel (current == NULL)");
ffffffffc0200dc2:	00005617          	auipc	a2,0x5
ffffffffc0200dc6:	74660613          	addi	a2,a2,1862 # ffffffffc0206508 <commands+0x798>
ffffffffc0200dca:	14a00593          	li	a1,330
ffffffffc0200dce:	00005517          	auipc	a0,0x5
ffffffffc0200dd2:	69250513          	addi	a0,a0,1682 # ffffffffc0206460 <commands+0x6f0>
ffffffffc0200dd6:	eb8ff0ef          	jal	ra,ffffffffc020048e <__panic>
        cprintf("Store/AMO page fault\n");
ffffffffc0200dda:	00005517          	auipc	a0,0x5
ffffffffc0200dde:	78650513          	addi	a0,a0,1926 # ffffffffc0206560 <commands+0x7f0>
ffffffffc0200de2:	bb2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (do_pgfault(current->mm, tf->cause, tf->tval) != 0) {
ffffffffc0200de6:	000d6497          	auipc	s1,0xd6
ffffffffc0200dea:	02a48493          	addi	s1,s1,42 # ffffffffc02d6e10 <current>
ffffffffc0200dee:	609c                	ld	a5,0(s1)
ffffffffc0200df0:	11043603          	ld	a2,272(s0)
ffffffffc0200df4:	11842583          	lw	a1,280(s0)
ffffffffc0200df8:	7788                	ld	a0,40(a5)
ffffffffc0200dfa:	152030ef          	jal	ra,ffffffffc0203f4c <do_pgfault>
ffffffffc0200dfe:	c531                	beqz	a0,ffffffffc0200e4a <exception_handler+0x168>
            print_trapframe(tf);
ffffffffc0200e00:	8522                	mv	a0,s0
ffffffffc0200e02:	da3ff0ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
            if (current == NULL) {
ffffffffc0200e06:	609c                	ld	a5,0(s1)
ffffffffc0200e08:	cbdd                	beqz	a5,ffffffffc0200ebe <exception_handler+0x1dc>
}
ffffffffc0200e0a:	6442                	ld	s0,16(sp)
ffffffffc0200e0c:	60e2                	ld	ra,24(sp)
ffffffffc0200e0e:	64a2                	ld	s1,8(sp)
            do_exit(-E_KILLED);
ffffffffc0200e10:	555d                	li	a0,-9
}
ffffffffc0200e12:	6105                	addi	sp,sp,32
            do_exit(-E_KILLED);
ffffffffc0200e14:	1a50306f          	j	ffffffffc02047b8 <do_exit>
        cprintf("Instruction address misaligned\n");
ffffffffc0200e18:	00005517          	auipc	a0,0x5
ffffffffc0200e1c:	59050513          	addi	a0,a0,1424 # ffffffffc02063a8 <commands+0x638>
ffffffffc0200e20:	bf09                	j	ffffffffc0200d32 <exception_handler+0x50>
        cprintf("Instruction access fault\n");
ffffffffc0200e22:	00005517          	auipc	a0,0x5
ffffffffc0200e26:	5a650513          	addi	a0,a0,1446 # ffffffffc02063c8 <commands+0x658>
ffffffffc0200e2a:	b721                	j	ffffffffc0200d32 <exception_handler+0x50>
        cprintf("Illegal instruction\n");
ffffffffc0200e2c:	00005517          	auipc	a0,0x5
ffffffffc0200e30:	5bc50513          	addi	a0,a0,1468 # ffffffffc02063e8 <commands+0x678>
ffffffffc0200e34:	bdfd                	j	ffffffffc0200d32 <exception_handler+0x50>
        cprintf("Breakpoint\n");
ffffffffc0200e36:	00005517          	auipc	a0,0x5
ffffffffc0200e3a:	5ca50513          	addi	a0,a0,1482 # ffffffffc0206400 <commands+0x690>
ffffffffc0200e3e:	b56ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (tf->gpr.a7 == 10) // 检查是否是特定的 kernel_execve 调用
ffffffffc0200e42:	6458                	ld	a4,136(s0)
ffffffffc0200e44:	47a9                	li	a5,10
ffffffffc0200e46:	04f70863          	beq	a4,a5,ffffffffc0200e96 <exception_handler+0x1b4>
}
ffffffffc0200e4a:	60e2                	ld	ra,24(sp)
ffffffffc0200e4c:	6442                	ld	s0,16(sp)
ffffffffc0200e4e:	64a2                	ld	s1,8(sp)
ffffffffc0200e50:	6105                	addi	sp,sp,32
ffffffffc0200e52:	8082                	ret
        cprintf("Load address misaligned\n");
ffffffffc0200e54:	00005517          	auipc	a0,0x5
ffffffffc0200e58:	5bc50513          	addi	a0,a0,1468 # ffffffffc0206410 <commands+0x6a0>
ffffffffc0200e5c:	bdd9                	j	ffffffffc0200d32 <exception_handler+0x50>
        cprintf("Load access fault\n");
ffffffffc0200e5e:	00005517          	auipc	a0,0x5
ffffffffc0200e62:	5d250513          	addi	a0,a0,1490 # ffffffffc0206430 <commands+0x6c0>
ffffffffc0200e66:	b5f1                	j	ffffffffc0200d32 <exception_handler+0x50>
        cprintf("Store/AMO access fault\n");
ffffffffc0200e68:	00005517          	auipc	a0,0x5
ffffffffc0200e6c:	61050513          	addi	a0,a0,1552 # ffffffffc0206478 <commands+0x708>
ffffffffc0200e70:	b5c9                	j	ffffffffc0200d32 <exception_handler+0x50>
        print_trapframe(tf);
ffffffffc0200e72:	8522                	mv	a0,s0
}
ffffffffc0200e74:	6442                	ld	s0,16(sp)
ffffffffc0200e76:	60e2                	ld	ra,24(sp)
ffffffffc0200e78:	64a2                	ld	s1,8(sp)
ffffffffc0200e7a:	6105                	addi	sp,sp,32
        print_trapframe(tf);
ffffffffc0200e7c:	b325                	j	ffffffffc0200ba4 <print_trapframe>
        panic("AMO address misaligned\n");
ffffffffc0200e7e:	00005617          	auipc	a2,0x5
ffffffffc0200e82:	5ca60613          	addi	a2,a2,1482 # ffffffffc0206448 <commands+0x6d8>
ffffffffc0200e86:	11600593          	li	a1,278
ffffffffc0200e8a:	00005517          	auipc	a0,0x5
ffffffffc0200e8e:	5d650513          	addi	a0,a0,1494 # ffffffffc0206460 <commands+0x6f0>
ffffffffc0200e92:	dfcff0ef          	jal	ra,ffffffffc020048e <__panic>
            tf->epc += 4; // 跳过 ebreak 指令，否则返回后会死循环执行 ebreak
ffffffffc0200e96:	10843783          	ld	a5,264(s0)
ffffffffc0200e9a:	0791                	addi	a5,a5,4
ffffffffc0200e9c:	10f43423          	sd	a5,264(s0)
            syscall();    // 执行真正的系统调用逻辑 (sys_exec)
ffffffffc0200ea0:	710040ef          	jal	ra,ffffffffc02055b0 <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200ea4:	000d6797          	auipc	a5,0xd6
ffffffffc0200ea8:	f6c7b783          	ld	a5,-148(a5) # ffffffffc02d6e10 <current>
ffffffffc0200eac:	6b9c                	ld	a5,16(a5)
ffffffffc0200eae:	8522                	mv	a0,s0
}
ffffffffc0200eb0:	6442                	ld	s0,16(sp)
ffffffffc0200eb2:	60e2                	ld	ra,24(sp)
ffffffffc0200eb4:	64a2                	ld	s1,8(sp)
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200eb6:	6589                	lui	a1,0x2
ffffffffc0200eb8:	95be                	add	a1,a1,a5
}
ffffffffc0200eba:	6105                	addi	sp,sp,32
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200ebc:	aa8d                	j	ffffffffc020102e <kernel_execve_ret>
                panic("handle_exception: page fault in kernel (current == NULL)");
ffffffffc0200ebe:	00005617          	auipc	a2,0x5
ffffffffc0200ec2:	64a60613          	addi	a2,a2,1610 # ffffffffc0206508 <commands+0x798>
ffffffffc0200ec6:	15c00593          	li	a1,348
ffffffffc0200eca:	00005517          	auipc	a0,0x5
ffffffffc0200ece:	59650513          	addi	a0,a0,1430 # ffffffffc0206460 <commands+0x6f0>
ffffffffc0200ed2:	dbcff0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0200ed6 <trap>:
 * trap - 通用陷阱处理入口
 * 所有的异常和中断最终都会走到这里。
 * 这里负责处理“嵌套陷阱”的逻辑，并决定何时进行进程调度。
 * */
/* 请替换 kern/trap/trap.c 末尾的 trap 函数 */
void trap(struct trapframe *tf) {
ffffffffc0200ed6:	1101                	addi	sp,sp,-32
ffffffffc0200ed8:	e822                	sd	s0,16(sp)
    // 1. 如果当前没有进程（如 OS 启动早期的中断），直接处理，不涉及进程调度
    if (current == NULL) {
ffffffffc0200eda:	000d6417          	auipc	s0,0xd6
ffffffffc0200ede:	f3640413          	addi	s0,s0,-202 # ffffffffc02d6e10 <current>
ffffffffc0200ee2:	6018                	ld	a4,0(s0)
void trap(struct trapframe *tf) {
ffffffffc0200ee4:	ec06                	sd	ra,24(sp)
ffffffffc0200ee6:	e426                	sd	s1,8(sp)
ffffffffc0200ee8:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200eea:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200eee:	cf1d                	beqz	a4,ffffffffc0200f2c <trap+0x56>

        // 【关键逻辑】判断中断来源
        // 检查 SSTATUS_SPP 位：
        // 0 -> 用户态 (User Mode)，in_kernel = false
        // 1 -> 内核态 (Supervisor Mode)，in_kernel = true
        bool in_kernel = (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200ef0:	10053483          	ld	s1,256(a0)
        struct trapframe *otf = current->tf;
ffffffffc0200ef4:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200ef8:	f348                	sd	a0,160(a4)
        bool in_kernel = (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200efa:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0)
ffffffffc0200efe:	0206c463          	bltz	a3,ffffffffc0200f26 <trap+0x50>
        exception_handler(tf);
ffffffffc0200f02:	de1ff0ef          	jal	ra,ffffffffc0200ce2 <exception_handler>

        // 3. 分发处理 (Dispatch)
        trap_dispatch(tf);

        // 4. 恢复旧的中断帧
        current->tf = otf;
ffffffffc0200f06:	601c                	ld	a5,0(s0)
ffffffffc0200f08:	0b27b023          	sd	s2,160(a5)

        // 5. 进程调度决策点 (Scheduling Decision)
        // 只有当满足以下条件时，才触发调度：
        // (1) 中断来自用户态 (!in_kernel)。如果内核代码执行中被打断，通常不立即抢占，保证内核原子性。
        // (2) 调度器标记了需要调度 (need_resched == 1)，这通常是在 interrupt_handler 中时间片耗尽设置的。
        if (!in_kernel) {
ffffffffc0200f0c:	e499                	bnez	s1,ffffffffc0200f1a <trap+0x44>
            // 检查当前进程是否被标记为正在退出 (PF_EXITING)
            // 如果是，直接结束它，不再让它回用户态。
            if (current->flags & PF_EXITING) {
ffffffffc0200f0e:	0b07a703          	lw	a4,176(a5)
ffffffffc0200f12:	8b05                	andi	a4,a4,1
ffffffffc0200f14:	e329                	bnez	a4,ffffffffc0200f56 <trap+0x80>
            }
            
            // 【核心】时间片轮转调度的触发点
            // 如果时间片用完 (need_resched 被置位)，现在可以安全地挂起当前进程，
            // 切换到下一个 RUNNABLE 进程。
            if (current->need_resched) {
ffffffffc0200f16:	6f9c                	ld	a5,24(a5)
ffffffffc0200f18:	eb85                	bnez	a5,ffffffffc0200f48 <trap+0x72>
                schedule();
            }
        }
    }
ffffffffc0200f1a:	60e2                	ld	ra,24(sp)
ffffffffc0200f1c:	6442                	ld	s0,16(sp)
ffffffffc0200f1e:	64a2                	ld	s1,8(sp)
ffffffffc0200f20:	6902                	ld	s2,0(sp)
ffffffffc0200f22:	6105                	addi	sp,sp,32
ffffffffc0200f24:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200f26:	ce1ff0ef          	jal	ra,ffffffffc0200c06 <interrupt_handler>
ffffffffc0200f2a:	bff1                	j	ffffffffc0200f06 <trap+0x30>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200f2c:	0006c863          	bltz	a3,ffffffffc0200f3c <trap+0x66>
ffffffffc0200f30:	6442                	ld	s0,16(sp)
ffffffffc0200f32:	60e2                	ld	ra,24(sp)
ffffffffc0200f34:	64a2                	ld	s1,8(sp)
ffffffffc0200f36:	6902                	ld	s2,0(sp)
ffffffffc0200f38:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200f3a:	b365                	j	ffffffffc0200ce2 <exception_handler>
ffffffffc0200f3c:	6442                	ld	s0,16(sp)
ffffffffc0200f3e:	60e2                	ld	ra,24(sp)
ffffffffc0200f40:	64a2                	ld	s1,8(sp)
ffffffffc0200f42:	6902                	ld	s2,0(sp)
ffffffffc0200f44:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200f46:	b1c1                	j	ffffffffc0200c06 <interrupt_handler>
ffffffffc0200f48:	6442                	ld	s0,16(sp)
ffffffffc0200f4a:	60e2                	ld	ra,24(sp)
ffffffffc0200f4c:	64a2                	ld	s1,8(sp)
ffffffffc0200f4e:	6902                	ld	s2,0(sp)
ffffffffc0200f50:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200f52:	5220406f          	j	ffffffffc0205474 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200f56:	555d                	li	a0,-9
ffffffffc0200f58:	061030ef          	jal	ra,ffffffffc02047b8 <do_exit>
            if (current->need_resched) {
ffffffffc0200f5c:	601c                	ld	a5,0(s0)
ffffffffc0200f5e:	bf65                	j	ffffffffc0200f16 <trap+0x40>

ffffffffc0200f60 <__alltraps>:
    # 中断入口点：__alltraps
    # CPU 发生中断/异常时，stvec 寄存器指向这里
    # =======================================================
    .globl __alltraps
__alltraps:
    SAVE_ALL            # 1. 保存当前上下文到栈上
ffffffffc0200f60:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200f64:	00011463          	bnez	sp,ffffffffc0200f6c <__alltraps+0xc>
ffffffffc0200f68:	14002173          	csrr	sp,sscratch
ffffffffc0200f6c:	712d                	addi	sp,sp,-288
ffffffffc0200f6e:	e002                	sd	zero,0(sp)
ffffffffc0200f70:	e406                	sd	ra,8(sp)
ffffffffc0200f72:	ec0e                	sd	gp,24(sp)
ffffffffc0200f74:	f012                	sd	tp,32(sp)
ffffffffc0200f76:	f416                	sd	t0,40(sp)
ffffffffc0200f78:	f81a                	sd	t1,48(sp)
ffffffffc0200f7a:	fc1e                	sd	t2,56(sp)
ffffffffc0200f7c:	e0a2                	sd	s0,64(sp)
ffffffffc0200f7e:	e4a6                	sd	s1,72(sp)
ffffffffc0200f80:	e8aa                	sd	a0,80(sp)
ffffffffc0200f82:	ecae                	sd	a1,88(sp)
ffffffffc0200f84:	f0b2                	sd	a2,96(sp)
ffffffffc0200f86:	f4b6                	sd	a3,104(sp)
ffffffffc0200f88:	f8ba                	sd	a4,112(sp)
ffffffffc0200f8a:	fcbe                	sd	a5,120(sp)
ffffffffc0200f8c:	e142                	sd	a6,128(sp)
ffffffffc0200f8e:	e546                	sd	a7,136(sp)
ffffffffc0200f90:	e94a                	sd	s2,144(sp)
ffffffffc0200f92:	ed4e                	sd	s3,152(sp)
ffffffffc0200f94:	f152                	sd	s4,160(sp)
ffffffffc0200f96:	f556                	sd	s5,168(sp)
ffffffffc0200f98:	f95a                	sd	s6,176(sp)
ffffffffc0200f9a:	fd5e                	sd	s7,184(sp)
ffffffffc0200f9c:	e1e2                	sd	s8,192(sp)
ffffffffc0200f9e:	e5e6                	sd	s9,200(sp)
ffffffffc0200fa0:	e9ea                	sd	s10,208(sp)
ffffffffc0200fa2:	edee                	sd	s11,216(sp)
ffffffffc0200fa4:	f1f2                	sd	t3,224(sp)
ffffffffc0200fa6:	f5f6                	sd	t4,232(sp)
ffffffffc0200fa8:	f9fa                	sd	t5,240(sp)
ffffffffc0200faa:	fdfe                	sd	t6,248(sp)
ffffffffc0200fac:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200fb0:	100024f3          	csrr	s1,sstatus
ffffffffc0200fb4:	14102973          	csrr	s2,sepc
ffffffffc0200fb8:	143029f3          	csrr	s3,stval
ffffffffc0200fbc:	14202a73          	csrr	s4,scause
ffffffffc0200fc0:	e822                	sd	s0,16(sp)
ffffffffc0200fc2:	e226                	sd	s1,256(sp)
ffffffffc0200fc4:	e64a                	sd	s2,264(sp)
ffffffffc0200fc6:	ea4e                	sd	s3,272(sp)
ffffffffc0200fc8:	ee52                	sd	s4,280(sp)

    move  a0, sp        # 2. 将当前 sp (指向 TrapFrame 的首地址) 作为第一个参数 a0 传递给 C 函数
ffffffffc0200fca:	850a                	mv	a0,sp
    jal trap            # 3. 跳转调用 C 语言的 trap 函数进行具体处理
ffffffffc0200fcc:	f0bff0ef          	jal	ra,ffffffffc0200ed6 <trap>

ffffffffc0200fd0 <__trapret>:
    # =======================================================
    # 中断返回点：__trapret
    # =======================================================
    .globl __trapret
__trapret:
    RESTORE_ALL         # 4. 从栈上恢复上下文
ffffffffc0200fd0:	6492                	ld	s1,256(sp)
ffffffffc0200fd2:	6932                	ld	s2,264(sp)
ffffffffc0200fd4:	1004f413          	andi	s0,s1,256
ffffffffc0200fd8:	e401                	bnez	s0,ffffffffc0200fe0 <__trapret+0x10>
ffffffffc0200fda:	1200                	addi	s0,sp,288
ffffffffc0200fdc:	14041073          	csrw	sscratch,s0
ffffffffc0200fe0:	10049073          	csrw	sstatus,s1
ffffffffc0200fe4:	14191073          	csrw	sepc,s2
ffffffffc0200fe8:	60a2                	ld	ra,8(sp)
ffffffffc0200fea:	61e2                	ld	gp,24(sp)
ffffffffc0200fec:	7202                	ld	tp,32(sp)
ffffffffc0200fee:	72a2                	ld	t0,40(sp)
ffffffffc0200ff0:	7342                	ld	t1,48(sp)
ffffffffc0200ff2:	73e2                	ld	t2,56(sp)
ffffffffc0200ff4:	6406                	ld	s0,64(sp)
ffffffffc0200ff6:	64a6                	ld	s1,72(sp)
ffffffffc0200ff8:	6546                	ld	a0,80(sp)
ffffffffc0200ffa:	65e6                	ld	a1,88(sp)
ffffffffc0200ffc:	7606                	ld	a2,96(sp)
ffffffffc0200ffe:	76a6                	ld	a3,104(sp)
ffffffffc0201000:	7746                	ld	a4,112(sp)
ffffffffc0201002:	77e6                	ld	a5,120(sp)
ffffffffc0201004:	680a                	ld	a6,128(sp)
ffffffffc0201006:	68aa                	ld	a7,136(sp)
ffffffffc0201008:	694a                	ld	s2,144(sp)
ffffffffc020100a:	69ea                	ld	s3,152(sp)
ffffffffc020100c:	7a0a                	ld	s4,160(sp)
ffffffffc020100e:	7aaa                	ld	s5,168(sp)
ffffffffc0201010:	7b4a                	ld	s6,176(sp)
ffffffffc0201012:	7bea                	ld	s7,184(sp)
ffffffffc0201014:	6c0e                	ld	s8,192(sp)
ffffffffc0201016:	6cae                	ld	s9,200(sp)
ffffffffc0201018:	6d4e                	ld	s10,208(sp)
ffffffffc020101a:	6dee                	ld	s11,216(sp)
ffffffffc020101c:	7e0e                	ld	t3,224(sp)
ffffffffc020101e:	7eae                	ld	t4,232(sp)
ffffffffc0201020:	7f4e                	ld	t5,240(sp)
ffffffffc0201022:	7fee                	ld	t6,248(sp)
ffffffffc0201024:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret                # 5. 特权级切换指令。
ffffffffc0201026:	10200073          	sret

ffffffffc020102a <forkrets>:
    # =======================================================
    .globl forkrets
forkrets:
    # 新进程被调度时，context.ra 指向 forkrets
    # a0 寄存器保存了新进程的 trapframe 指针 (在 copy_thread 中设置)
    move sp, a0         # 将 sp 指向新进程的 TrapFrame
ffffffffc020102a:	812a                	mv	sp,a0
    j __trapret         # 跳转到 __trapret，执行 RESTORE_ALL 并 sret 进入用户态
ffffffffc020102c:	b755                	j	ffffffffc0200fd0 <__trapret>

ffffffffc020102e <kernel_execve_ret>:
kernel_execve_ret:
    # a0: 原来的 trapframe 地址
    # a1: 当前进程的 kstacktop (内核栈顶)

    # 调整 a1 向下预留 TrapFrame 的空间，a1 现在指向新 TrapFrame 的底部
    addi a1, a1, -36*REGBYTES
ffffffffc020102e:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7e80>

    # [复制 TrapFrame]
    # copy from previous trapframe (a0) to new trapframe (a1)
    # 将旧的 TrapFrame 内容逐个寄存器复制到新的栈顶位置
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0201032:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0201036:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc020103a:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc020103e:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0201042:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0201046:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc020104a:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc020104e:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0201052:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0201054:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0201056:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0201058:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc020105a:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc020105c:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc020105e:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0201060:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0201062:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0201064:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0201066:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0201068:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc020106a:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc020106c:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc020106e:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0201070:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0201072:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0201074:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0201076:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0201078:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc020107a:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc020107c:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc020107e:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0201080:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0201082:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0201084:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0201086:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0201088:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc020108a:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc020108c:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc020108e:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0201090:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0201092:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0201094:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0201096:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0201098:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc020109a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc020109c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc020109e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc02010a0:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc02010a2:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc02010a4:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc02010a6:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc02010a8:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc02010aa:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc02010ac:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc02010ae:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc02010b0:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc02010b2:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc02010b4:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc02010b6:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc02010b8:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc02010ba:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc02010bc:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc02010be:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc02010c0:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc02010c2:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc02010c4:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc02010c6:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc02010c8:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc02010ca:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc02010cc:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc02010ce:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc02010d0:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    # 将栈指针指向新的 TrapFrame，并跳转到恢复流程
    # 这样看起来就像是从一个中断中返回一样，最终 sret 跳转到新程序的入口
    move sp, a1
ffffffffc02010d2:	812e                	mv	sp,a1
ffffffffc02010d4:	bdf5                	j	ffffffffc0200fd0 <__trapret>

ffffffffc02010d6 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02010d6:	000d2797          	auipc	a5,0xd2
ffffffffc02010da:	c9278793          	addi	a5,a5,-878 # ffffffffc02d2d68 <free_area>
ffffffffc02010de:	e79c                	sd	a5,8(a5)
ffffffffc02010e0:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc02010e2:	0007a823          	sw	zero,16(a5)
}
ffffffffc02010e6:	8082                	ret

ffffffffc02010e8 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc02010e8:	000d2517          	auipc	a0,0xd2
ffffffffc02010ec:	c9056503          	lwu	a0,-880(a0) # ffffffffc02d2d78 <free_area+0x10>
ffffffffc02010f0:	8082                	ret

ffffffffc02010f2 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc02010f2:	715d                	addi	sp,sp,-80
ffffffffc02010f4:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02010f6:	000d2417          	auipc	s0,0xd2
ffffffffc02010fa:	c7240413          	addi	s0,s0,-910 # ffffffffc02d2d68 <free_area>
ffffffffc02010fe:	641c                	ld	a5,8(s0)
ffffffffc0201100:	e486                	sd	ra,72(sp)
ffffffffc0201102:	fc26                	sd	s1,56(sp)
ffffffffc0201104:	f84a                	sd	s2,48(sp)
ffffffffc0201106:	f44e                	sd	s3,40(sp)
ffffffffc0201108:	f052                	sd	s4,32(sp)
ffffffffc020110a:	ec56                	sd	s5,24(sp)
ffffffffc020110c:	e85a                	sd	s6,16(sp)
ffffffffc020110e:	e45e                	sd	s7,8(sp)
ffffffffc0201110:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201112:	2a878d63          	beq	a5,s0,ffffffffc02013cc <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0201116:	4481                	li	s1,0
ffffffffc0201118:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020111a:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020111e:	8b09                	andi	a4,a4,2
ffffffffc0201120:	2a070a63          	beqz	a4,ffffffffc02013d4 <default_check+0x2e2>
        count++, total += p->property;
ffffffffc0201124:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201128:	679c                	ld	a5,8(a5)
ffffffffc020112a:	2905                	addiw	s2,s2,1
ffffffffc020112c:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc020112e:	fe8796e3          	bne	a5,s0,ffffffffc020111a <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0201132:	89a6                	mv	s3,s1
ffffffffc0201134:	6ef000ef          	jal	ra,ffffffffc0202022 <nr_free_pages>
ffffffffc0201138:	6f351e63          	bne	a0,s3,ffffffffc0201834 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020113c:	4505                	li	a0,1
ffffffffc020113e:	667000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc0201142:	8aaa                	mv	s5,a0
ffffffffc0201144:	42050863          	beqz	a0,ffffffffc0201574 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201148:	4505                	li	a0,1
ffffffffc020114a:	65b000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc020114e:	89aa                	mv	s3,a0
ffffffffc0201150:	70050263          	beqz	a0,ffffffffc0201854 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201154:	4505                	li	a0,1
ffffffffc0201156:	64f000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc020115a:	8a2a                	mv	s4,a0
ffffffffc020115c:	48050c63          	beqz	a0,ffffffffc02015f4 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201160:	293a8a63          	beq	s5,s3,ffffffffc02013f4 <default_check+0x302>
ffffffffc0201164:	28aa8863          	beq	s5,a0,ffffffffc02013f4 <default_check+0x302>
ffffffffc0201168:	28a98663          	beq	s3,a0,ffffffffc02013f4 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020116c:	000aa783          	lw	a5,0(s5)
ffffffffc0201170:	2a079263          	bnez	a5,ffffffffc0201414 <default_check+0x322>
ffffffffc0201174:	0009a783          	lw	a5,0(s3)
ffffffffc0201178:	28079e63          	bnez	a5,ffffffffc0201414 <default_check+0x322>
ffffffffc020117c:	411c                	lw	a5,0(a0)
ffffffffc020117e:	28079b63          	bnez	a5,ffffffffc0201414 <default_check+0x322>
// page2ppn - 将 Page 结构体指针转换为物理页帧号 (Physical Page Number)
static inline ppn_t
page2ppn(struct Page *page)
{
    // 通过指针减法计算数组索引，再加上物理内存起始页号 (nbase)
    return page - pages + nbase;
ffffffffc0201182:	000d6797          	auipc	a5,0xd6
ffffffffc0201186:	c667b783          	ld	a5,-922(a5) # ffffffffc02d6de8 <pages>
ffffffffc020118a:	40fa8733          	sub	a4,s5,a5
ffffffffc020118e:	00007617          	auipc	a2,0x7
ffffffffc0201192:	29a63603          	ld	a2,666(a2) # ffffffffc0208428 <nbase>
ffffffffc0201196:	8719                	srai	a4,a4,0x6
ffffffffc0201198:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020119a:	000d6697          	auipc	a3,0xd6
ffffffffc020119e:	c466b683          	ld	a3,-954(a3) # ffffffffc02d6de0 <npage>
ffffffffc02011a2:	06b2                	slli	a3,a3,0xc
// page2pa - 将 Page 结构体指针转换为物理地址 (Physical Address)
static inline uintptr_t
page2pa(struct Page *page)
{
    // 物理地址 = 页帧号 << 12 (4KB页面)
    return page2ppn(page) << PGSHIFT;
ffffffffc02011a4:	0732                	slli	a4,a4,0xc
ffffffffc02011a6:	28d77763          	bgeu	a4,a3,ffffffffc0201434 <default_check+0x342>
    return page - pages + nbase;
ffffffffc02011aa:	40f98733          	sub	a4,s3,a5
ffffffffc02011ae:	8719                	srai	a4,a4,0x6
ffffffffc02011b0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02011b2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02011b4:	4cd77063          	bgeu	a4,a3,ffffffffc0201674 <default_check+0x582>
    return page - pages + nbase;
ffffffffc02011b8:	40f507b3          	sub	a5,a0,a5
ffffffffc02011bc:	8799                	srai	a5,a5,0x6
ffffffffc02011be:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02011c0:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02011c2:	30d7f963          	bgeu	a5,a3,ffffffffc02014d4 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc02011c6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02011c8:	00043c03          	ld	s8,0(s0)
ffffffffc02011cc:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02011d0:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02011d4:	e400                	sd	s0,8(s0)
ffffffffc02011d6:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02011d8:	000d2797          	auipc	a5,0xd2
ffffffffc02011dc:	ba07a023          	sw	zero,-1120(a5) # ffffffffc02d2d78 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02011e0:	5c5000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc02011e4:	2c051863          	bnez	a0,ffffffffc02014b4 <default_check+0x3c2>
    free_page(p0);
ffffffffc02011e8:	4585                	li	a1,1
ffffffffc02011ea:	8556                	mv	a0,s5
ffffffffc02011ec:	5f7000ef          	jal	ra,ffffffffc0201fe2 <free_pages>
    free_page(p1);
ffffffffc02011f0:	4585                	li	a1,1
ffffffffc02011f2:	854e                	mv	a0,s3
ffffffffc02011f4:	5ef000ef          	jal	ra,ffffffffc0201fe2 <free_pages>
    free_page(p2);
ffffffffc02011f8:	4585                	li	a1,1
ffffffffc02011fa:	8552                	mv	a0,s4
ffffffffc02011fc:	5e7000ef          	jal	ra,ffffffffc0201fe2 <free_pages>
    assert(nr_free == 3);
ffffffffc0201200:	4818                	lw	a4,16(s0)
ffffffffc0201202:	478d                	li	a5,3
ffffffffc0201204:	28f71863          	bne	a4,a5,ffffffffc0201494 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201208:	4505                	li	a0,1
ffffffffc020120a:	59b000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc020120e:	89aa                	mv	s3,a0
ffffffffc0201210:	26050263          	beqz	a0,ffffffffc0201474 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201214:	4505                	li	a0,1
ffffffffc0201216:	58f000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc020121a:	8aaa                	mv	s5,a0
ffffffffc020121c:	3a050c63          	beqz	a0,ffffffffc02015d4 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201220:	4505                	li	a0,1
ffffffffc0201222:	583000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc0201226:	8a2a                	mv	s4,a0
ffffffffc0201228:	38050663          	beqz	a0,ffffffffc02015b4 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc020122c:	4505                	li	a0,1
ffffffffc020122e:	577000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc0201232:	36051163          	bnez	a0,ffffffffc0201594 <default_check+0x4a2>
    free_page(p0);
ffffffffc0201236:	4585                	li	a1,1
ffffffffc0201238:	854e                	mv	a0,s3
ffffffffc020123a:	5a9000ef          	jal	ra,ffffffffc0201fe2 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020123e:	641c                	ld	a5,8(s0)
ffffffffc0201240:	20878a63          	beq	a5,s0,ffffffffc0201454 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0201244:	4505                	li	a0,1
ffffffffc0201246:	55f000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc020124a:	30a99563          	bne	s3,a0,ffffffffc0201554 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc020124e:	4505                	li	a0,1
ffffffffc0201250:	555000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc0201254:	2e051063          	bnez	a0,ffffffffc0201534 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0201258:	481c                	lw	a5,16(s0)
ffffffffc020125a:	2a079d63          	bnez	a5,ffffffffc0201514 <default_check+0x422>
    free_page(p);
ffffffffc020125e:	854e                	mv	a0,s3
ffffffffc0201260:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201262:	01843023          	sd	s8,0(s0)
ffffffffc0201266:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc020126a:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc020126e:	575000ef          	jal	ra,ffffffffc0201fe2 <free_pages>
    free_page(p1);
ffffffffc0201272:	4585                	li	a1,1
ffffffffc0201274:	8556                	mv	a0,s5
ffffffffc0201276:	56d000ef          	jal	ra,ffffffffc0201fe2 <free_pages>
    free_page(p2);
ffffffffc020127a:	4585                	li	a1,1
ffffffffc020127c:	8552                	mv	a0,s4
ffffffffc020127e:	565000ef          	jal	ra,ffffffffc0201fe2 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201282:	4515                	li	a0,5
ffffffffc0201284:	521000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc0201288:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020128a:	26050563          	beqz	a0,ffffffffc02014f4 <default_check+0x402>
ffffffffc020128e:	651c                	ld	a5,8(a0)
ffffffffc0201290:	8385                	srli	a5,a5,0x1
ffffffffc0201292:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201294:	54079063          	bnez	a5,ffffffffc02017d4 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201298:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020129a:	00043b03          	ld	s6,0(s0)
ffffffffc020129e:	00843a83          	ld	s5,8(s0)
ffffffffc02012a2:	e000                	sd	s0,0(s0)
ffffffffc02012a4:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02012a6:	4ff000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc02012aa:	50051563          	bnez	a0,ffffffffc02017b4 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02012ae:	08098a13          	addi	s4,s3,128
ffffffffc02012b2:	8552                	mv	a0,s4
ffffffffc02012b4:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02012b6:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02012ba:	000d2797          	auipc	a5,0xd2
ffffffffc02012be:	aa07af23          	sw	zero,-1346(a5) # ffffffffc02d2d78 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02012c2:	521000ef          	jal	ra,ffffffffc0201fe2 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02012c6:	4511                	li	a0,4
ffffffffc02012c8:	4dd000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc02012cc:	4c051463          	bnez	a0,ffffffffc0201794 <default_check+0x6a2>
ffffffffc02012d0:	0889b783          	ld	a5,136(s3)
ffffffffc02012d4:	8385                	srli	a5,a5,0x1
ffffffffc02012d6:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02012d8:	48078e63          	beqz	a5,ffffffffc0201774 <default_check+0x682>
ffffffffc02012dc:	0909a703          	lw	a4,144(s3)
ffffffffc02012e0:	478d                	li	a5,3
ffffffffc02012e2:	48f71963          	bne	a4,a5,ffffffffc0201774 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02012e6:	450d                	li	a0,3
ffffffffc02012e8:	4bd000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc02012ec:	8c2a                	mv	s8,a0
ffffffffc02012ee:	46050363          	beqz	a0,ffffffffc0201754 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc02012f2:	4505                	li	a0,1
ffffffffc02012f4:	4b1000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc02012f8:	42051e63          	bnez	a0,ffffffffc0201734 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc02012fc:	418a1c63          	bne	s4,s8,ffffffffc0201714 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201300:	4585                	li	a1,1
ffffffffc0201302:	854e                	mv	a0,s3
ffffffffc0201304:	4df000ef          	jal	ra,ffffffffc0201fe2 <free_pages>
    free_pages(p1, 3);
ffffffffc0201308:	458d                	li	a1,3
ffffffffc020130a:	8552                	mv	a0,s4
ffffffffc020130c:	4d7000ef          	jal	ra,ffffffffc0201fe2 <free_pages>
ffffffffc0201310:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201314:	04098c13          	addi	s8,s3,64
ffffffffc0201318:	8385                	srli	a5,a5,0x1
ffffffffc020131a:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020131c:	3c078c63          	beqz	a5,ffffffffc02016f4 <default_check+0x602>
ffffffffc0201320:	0109a703          	lw	a4,16(s3)
ffffffffc0201324:	4785                	li	a5,1
ffffffffc0201326:	3cf71763          	bne	a4,a5,ffffffffc02016f4 <default_check+0x602>
ffffffffc020132a:	008a3783          	ld	a5,8(s4)
ffffffffc020132e:	8385                	srli	a5,a5,0x1
ffffffffc0201330:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201332:	3a078163          	beqz	a5,ffffffffc02016d4 <default_check+0x5e2>
ffffffffc0201336:	010a2703          	lw	a4,16(s4)
ffffffffc020133a:	478d                	li	a5,3
ffffffffc020133c:	38f71c63          	bne	a4,a5,ffffffffc02016d4 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201340:	4505                	li	a0,1
ffffffffc0201342:	463000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc0201346:	36a99763          	bne	s3,a0,ffffffffc02016b4 <default_check+0x5c2>
    free_page(p0);
ffffffffc020134a:	4585                	li	a1,1
ffffffffc020134c:	497000ef          	jal	ra,ffffffffc0201fe2 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201350:	4509                	li	a0,2
ffffffffc0201352:	453000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc0201356:	32aa1f63          	bne	s4,a0,ffffffffc0201694 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc020135a:	4589                	li	a1,2
ffffffffc020135c:	487000ef          	jal	ra,ffffffffc0201fe2 <free_pages>
    free_page(p2);
ffffffffc0201360:	4585                	li	a1,1
ffffffffc0201362:	8562                	mv	a0,s8
ffffffffc0201364:	47f000ef          	jal	ra,ffffffffc0201fe2 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201368:	4515                	li	a0,5
ffffffffc020136a:	43b000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc020136e:	89aa                	mv	s3,a0
ffffffffc0201370:	48050263          	beqz	a0,ffffffffc02017f4 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0201374:	4505                	li	a0,1
ffffffffc0201376:	42f000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc020137a:	2c051d63          	bnez	a0,ffffffffc0201654 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc020137e:	481c                	lw	a5,16(s0)
ffffffffc0201380:	2a079a63          	bnez	a5,ffffffffc0201634 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201384:	4595                	li	a1,5
ffffffffc0201386:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201388:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc020138c:	01643023          	sd	s6,0(s0)
ffffffffc0201390:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0201394:	44f000ef          	jal	ra,ffffffffc0201fe2 <free_pages>
    return listelm->next;
ffffffffc0201398:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc020139a:	00878963          	beq	a5,s0,ffffffffc02013ac <default_check+0x2ba>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc020139e:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013a2:	679c                	ld	a5,8(a5)
ffffffffc02013a4:	397d                	addiw	s2,s2,-1
ffffffffc02013a6:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc02013a8:	fe879be3          	bne	a5,s0,ffffffffc020139e <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02013ac:	26091463          	bnez	s2,ffffffffc0201614 <default_check+0x522>
    assert(total == 0);
ffffffffc02013b0:	46049263          	bnez	s1,ffffffffc0201814 <default_check+0x722>
}
ffffffffc02013b4:	60a6                	ld	ra,72(sp)
ffffffffc02013b6:	6406                	ld	s0,64(sp)
ffffffffc02013b8:	74e2                	ld	s1,56(sp)
ffffffffc02013ba:	7942                	ld	s2,48(sp)
ffffffffc02013bc:	79a2                	ld	s3,40(sp)
ffffffffc02013be:	7a02                	ld	s4,32(sp)
ffffffffc02013c0:	6ae2                	ld	s5,24(sp)
ffffffffc02013c2:	6b42                	ld	s6,16(sp)
ffffffffc02013c4:	6ba2                	ld	s7,8(sp)
ffffffffc02013c6:	6c02                	ld	s8,0(sp)
ffffffffc02013c8:	6161                	addi	sp,sp,80
ffffffffc02013ca:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc02013cc:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02013ce:	4481                	li	s1,0
ffffffffc02013d0:	4901                	li	s2,0
ffffffffc02013d2:	b38d                	j	ffffffffc0201134 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02013d4:	00005697          	auipc	a3,0x5
ffffffffc02013d8:	1e468693          	addi	a3,a3,484 # ffffffffc02065b8 <commands+0x848>
ffffffffc02013dc:	00005617          	auipc	a2,0x5
ffffffffc02013e0:	1ec60613          	addi	a2,a2,492 # ffffffffc02065c8 <commands+0x858>
ffffffffc02013e4:	11000593          	li	a1,272
ffffffffc02013e8:	00005517          	auipc	a0,0x5
ffffffffc02013ec:	1f850513          	addi	a0,a0,504 # ffffffffc02065e0 <commands+0x870>
ffffffffc02013f0:	89eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02013f4:	00005697          	auipc	a3,0x5
ffffffffc02013f8:	28468693          	addi	a3,a3,644 # ffffffffc0206678 <commands+0x908>
ffffffffc02013fc:	00005617          	auipc	a2,0x5
ffffffffc0201400:	1cc60613          	addi	a2,a2,460 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201404:	0db00593          	li	a1,219
ffffffffc0201408:	00005517          	auipc	a0,0x5
ffffffffc020140c:	1d850513          	addi	a0,a0,472 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201410:	87eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201414:	00005697          	auipc	a3,0x5
ffffffffc0201418:	28c68693          	addi	a3,a3,652 # ffffffffc02066a0 <commands+0x930>
ffffffffc020141c:	00005617          	auipc	a2,0x5
ffffffffc0201420:	1ac60613          	addi	a2,a2,428 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201424:	0dc00593          	li	a1,220
ffffffffc0201428:	00005517          	auipc	a0,0x5
ffffffffc020142c:	1b850513          	addi	a0,a0,440 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201430:	85eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201434:	00005697          	auipc	a3,0x5
ffffffffc0201438:	2ac68693          	addi	a3,a3,684 # ffffffffc02066e0 <commands+0x970>
ffffffffc020143c:	00005617          	auipc	a2,0x5
ffffffffc0201440:	18c60613          	addi	a2,a2,396 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201444:	0de00593          	li	a1,222
ffffffffc0201448:	00005517          	auipc	a0,0x5
ffffffffc020144c:	19850513          	addi	a0,a0,408 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201450:	83eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201454:	00005697          	auipc	a3,0x5
ffffffffc0201458:	31468693          	addi	a3,a3,788 # ffffffffc0206768 <commands+0x9f8>
ffffffffc020145c:	00005617          	auipc	a2,0x5
ffffffffc0201460:	16c60613          	addi	a2,a2,364 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201464:	0f700593          	li	a1,247
ffffffffc0201468:	00005517          	auipc	a0,0x5
ffffffffc020146c:	17850513          	addi	a0,a0,376 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201470:	81eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201474:	00005697          	auipc	a3,0x5
ffffffffc0201478:	1a468693          	addi	a3,a3,420 # ffffffffc0206618 <commands+0x8a8>
ffffffffc020147c:	00005617          	auipc	a2,0x5
ffffffffc0201480:	14c60613          	addi	a2,a2,332 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201484:	0f000593          	li	a1,240
ffffffffc0201488:	00005517          	auipc	a0,0x5
ffffffffc020148c:	15850513          	addi	a0,a0,344 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201490:	ffffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 3);
ffffffffc0201494:	00005697          	auipc	a3,0x5
ffffffffc0201498:	2c468693          	addi	a3,a3,708 # ffffffffc0206758 <commands+0x9e8>
ffffffffc020149c:	00005617          	auipc	a2,0x5
ffffffffc02014a0:	12c60613          	addi	a2,a2,300 # ffffffffc02065c8 <commands+0x858>
ffffffffc02014a4:	0ee00593          	li	a1,238
ffffffffc02014a8:	00005517          	auipc	a0,0x5
ffffffffc02014ac:	13850513          	addi	a0,a0,312 # ffffffffc02065e0 <commands+0x870>
ffffffffc02014b0:	fdffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014b4:	00005697          	auipc	a3,0x5
ffffffffc02014b8:	28c68693          	addi	a3,a3,652 # ffffffffc0206740 <commands+0x9d0>
ffffffffc02014bc:	00005617          	auipc	a2,0x5
ffffffffc02014c0:	10c60613          	addi	a2,a2,268 # ffffffffc02065c8 <commands+0x858>
ffffffffc02014c4:	0e900593          	li	a1,233
ffffffffc02014c8:	00005517          	auipc	a0,0x5
ffffffffc02014cc:	11850513          	addi	a0,a0,280 # ffffffffc02065e0 <commands+0x870>
ffffffffc02014d0:	fbffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02014d4:	00005697          	auipc	a3,0x5
ffffffffc02014d8:	24c68693          	addi	a3,a3,588 # ffffffffc0206720 <commands+0x9b0>
ffffffffc02014dc:	00005617          	auipc	a2,0x5
ffffffffc02014e0:	0ec60613          	addi	a2,a2,236 # ffffffffc02065c8 <commands+0x858>
ffffffffc02014e4:	0e000593          	li	a1,224
ffffffffc02014e8:	00005517          	auipc	a0,0x5
ffffffffc02014ec:	0f850513          	addi	a0,a0,248 # ffffffffc02065e0 <commands+0x870>
ffffffffc02014f0:	f9ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 != NULL);
ffffffffc02014f4:	00005697          	auipc	a3,0x5
ffffffffc02014f8:	2bc68693          	addi	a3,a3,700 # ffffffffc02067b0 <commands+0xa40>
ffffffffc02014fc:	00005617          	auipc	a2,0x5
ffffffffc0201500:	0cc60613          	addi	a2,a2,204 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201504:	11800593          	li	a1,280
ffffffffc0201508:	00005517          	auipc	a0,0x5
ffffffffc020150c:	0d850513          	addi	a0,a0,216 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201510:	f7ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 0);
ffffffffc0201514:	00005697          	auipc	a3,0x5
ffffffffc0201518:	28c68693          	addi	a3,a3,652 # ffffffffc02067a0 <commands+0xa30>
ffffffffc020151c:	00005617          	auipc	a2,0x5
ffffffffc0201520:	0ac60613          	addi	a2,a2,172 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201524:	0fd00593          	li	a1,253
ffffffffc0201528:	00005517          	auipc	a0,0x5
ffffffffc020152c:	0b850513          	addi	a0,a0,184 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201530:	f5ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201534:	00005697          	auipc	a3,0x5
ffffffffc0201538:	20c68693          	addi	a3,a3,524 # ffffffffc0206740 <commands+0x9d0>
ffffffffc020153c:	00005617          	auipc	a2,0x5
ffffffffc0201540:	08c60613          	addi	a2,a2,140 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201544:	0fb00593          	li	a1,251
ffffffffc0201548:	00005517          	auipc	a0,0x5
ffffffffc020154c:	09850513          	addi	a0,a0,152 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201550:	f3ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201554:	00005697          	auipc	a3,0x5
ffffffffc0201558:	22c68693          	addi	a3,a3,556 # ffffffffc0206780 <commands+0xa10>
ffffffffc020155c:	00005617          	auipc	a2,0x5
ffffffffc0201560:	06c60613          	addi	a2,a2,108 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201564:	0fa00593          	li	a1,250
ffffffffc0201568:	00005517          	auipc	a0,0x5
ffffffffc020156c:	07850513          	addi	a0,a0,120 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201570:	f1ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201574:	00005697          	auipc	a3,0x5
ffffffffc0201578:	0a468693          	addi	a3,a3,164 # ffffffffc0206618 <commands+0x8a8>
ffffffffc020157c:	00005617          	auipc	a2,0x5
ffffffffc0201580:	04c60613          	addi	a2,a2,76 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201584:	0d700593          	li	a1,215
ffffffffc0201588:	00005517          	auipc	a0,0x5
ffffffffc020158c:	05850513          	addi	a0,a0,88 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201590:	efffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201594:	00005697          	auipc	a3,0x5
ffffffffc0201598:	1ac68693          	addi	a3,a3,428 # ffffffffc0206740 <commands+0x9d0>
ffffffffc020159c:	00005617          	auipc	a2,0x5
ffffffffc02015a0:	02c60613          	addi	a2,a2,44 # ffffffffc02065c8 <commands+0x858>
ffffffffc02015a4:	0f400593          	li	a1,244
ffffffffc02015a8:	00005517          	auipc	a0,0x5
ffffffffc02015ac:	03850513          	addi	a0,a0,56 # ffffffffc02065e0 <commands+0x870>
ffffffffc02015b0:	edffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02015b4:	00005697          	auipc	a3,0x5
ffffffffc02015b8:	0a468693          	addi	a3,a3,164 # ffffffffc0206658 <commands+0x8e8>
ffffffffc02015bc:	00005617          	auipc	a2,0x5
ffffffffc02015c0:	00c60613          	addi	a2,a2,12 # ffffffffc02065c8 <commands+0x858>
ffffffffc02015c4:	0f200593          	li	a1,242
ffffffffc02015c8:	00005517          	auipc	a0,0x5
ffffffffc02015cc:	01850513          	addi	a0,a0,24 # ffffffffc02065e0 <commands+0x870>
ffffffffc02015d0:	ebffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02015d4:	00005697          	auipc	a3,0x5
ffffffffc02015d8:	06468693          	addi	a3,a3,100 # ffffffffc0206638 <commands+0x8c8>
ffffffffc02015dc:	00005617          	auipc	a2,0x5
ffffffffc02015e0:	fec60613          	addi	a2,a2,-20 # ffffffffc02065c8 <commands+0x858>
ffffffffc02015e4:	0f100593          	li	a1,241
ffffffffc02015e8:	00005517          	auipc	a0,0x5
ffffffffc02015ec:	ff850513          	addi	a0,a0,-8 # ffffffffc02065e0 <commands+0x870>
ffffffffc02015f0:	e9ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02015f4:	00005697          	auipc	a3,0x5
ffffffffc02015f8:	06468693          	addi	a3,a3,100 # ffffffffc0206658 <commands+0x8e8>
ffffffffc02015fc:	00005617          	auipc	a2,0x5
ffffffffc0201600:	fcc60613          	addi	a2,a2,-52 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201604:	0d900593          	li	a1,217
ffffffffc0201608:	00005517          	auipc	a0,0x5
ffffffffc020160c:	fd850513          	addi	a0,a0,-40 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201610:	e7ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(count == 0);
ffffffffc0201614:	00005697          	auipc	a3,0x5
ffffffffc0201618:	2ec68693          	addi	a3,a3,748 # ffffffffc0206900 <commands+0xb90>
ffffffffc020161c:	00005617          	auipc	a2,0x5
ffffffffc0201620:	fac60613          	addi	a2,a2,-84 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201624:	14600593          	li	a1,326
ffffffffc0201628:	00005517          	auipc	a0,0x5
ffffffffc020162c:	fb850513          	addi	a0,a0,-72 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201630:	e5ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 0);
ffffffffc0201634:	00005697          	auipc	a3,0x5
ffffffffc0201638:	16c68693          	addi	a3,a3,364 # ffffffffc02067a0 <commands+0xa30>
ffffffffc020163c:	00005617          	auipc	a2,0x5
ffffffffc0201640:	f8c60613          	addi	a2,a2,-116 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201644:	13a00593          	li	a1,314
ffffffffc0201648:	00005517          	auipc	a0,0x5
ffffffffc020164c:	f9850513          	addi	a0,a0,-104 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201650:	e3ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201654:	00005697          	auipc	a3,0x5
ffffffffc0201658:	0ec68693          	addi	a3,a3,236 # ffffffffc0206740 <commands+0x9d0>
ffffffffc020165c:	00005617          	auipc	a2,0x5
ffffffffc0201660:	f6c60613          	addi	a2,a2,-148 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201664:	13800593          	li	a1,312
ffffffffc0201668:	00005517          	auipc	a0,0x5
ffffffffc020166c:	f7850513          	addi	a0,a0,-136 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201670:	e1ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201674:	00005697          	auipc	a3,0x5
ffffffffc0201678:	08c68693          	addi	a3,a3,140 # ffffffffc0206700 <commands+0x990>
ffffffffc020167c:	00005617          	auipc	a2,0x5
ffffffffc0201680:	f4c60613          	addi	a2,a2,-180 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201684:	0df00593          	li	a1,223
ffffffffc0201688:	00005517          	auipc	a0,0x5
ffffffffc020168c:	f5850513          	addi	a0,a0,-168 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201690:	dfffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201694:	00005697          	auipc	a3,0x5
ffffffffc0201698:	22c68693          	addi	a3,a3,556 # ffffffffc02068c0 <commands+0xb50>
ffffffffc020169c:	00005617          	auipc	a2,0x5
ffffffffc02016a0:	f2c60613          	addi	a2,a2,-212 # ffffffffc02065c8 <commands+0x858>
ffffffffc02016a4:	13200593          	li	a1,306
ffffffffc02016a8:	00005517          	auipc	a0,0x5
ffffffffc02016ac:	f3850513          	addi	a0,a0,-200 # ffffffffc02065e0 <commands+0x870>
ffffffffc02016b0:	ddffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02016b4:	00005697          	auipc	a3,0x5
ffffffffc02016b8:	1ec68693          	addi	a3,a3,492 # ffffffffc02068a0 <commands+0xb30>
ffffffffc02016bc:	00005617          	auipc	a2,0x5
ffffffffc02016c0:	f0c60613          	addi	a2,a2,-244 # ffffffffc02065c8 <commands+0x858>
ffffffffc02016c4:	13000593          	li	a1,304
ffffffffc02016c8:	00005517          	auipc	a0,0x5
ffffffffc02016cc:	f1850513          	addi	a0,a0,-232 # ffffffffc02065e0 <commands+0x870>
ffffffffc02016d0:	dbffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02016d4:	00005697          	auipc	a3,0x5
ffffffffc02016d8:	1a468693          	addi	a3,a3,420 # ffffffffc0206878 <commands+0xb08>
ffffffffc02016dc:	00005617          	auipc	a2,0x5
ffffffffc02016e0:	eec60613          	addi	a2,a2,-276 # ffffffffc02065c8 <commands+0x858>
ffffffffc02016e4:	12e00593          	li	a1,302
ffffffffc02016e8:	00005517          	auipc	a0,0x5
ffffffffc02016ec:	ef850513          	addi	a0,a0,-264 # ffffffffc02065e0 <commands+0x870>
ffffffffc02016f0:	d9ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02016f4:	00005697          	auipc	a3,0x5
ffffffffc02016f8:	15c68693          	addi	a3,a3,348 # ffffffffc0206850 <commands+0xae0>
ffffffffc02016fc:	00005617          	auipc	a2,0x5
ffffffffc0201700:	ecc60613          	addi	a2,a2,-308 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201704:	12d00593          	li	a1,301
ffffffffc0201708:	00005517          	auipc	a0,0x5
ffffffffc020170c:	ed850513          	addi	a0,a0,-296 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201710:	d7ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201714:	00005697          	auipc	a3,0x5
ffffffffc0201718:	12c68693          	addi	a3,a3,300 # ffffffffc0206840 <commands+0xad0>
ffffffffc020171c:	00005617          	auipc	a2,0x5
ffffffffc0201720:	eac60613          	addi	a2,a2,-340 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201724:	12800593          	li	a1,296
ffffffffc0201728:	00005517          	auipc	a0,0x5
ffffffffc020172c:	eb850513          	addi	a0,a0,-328 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201730:	d5ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201734:	00005697          	auipc	a3,0x5
ffffffffc0201738:	00c68693          	addi	a3,a3,12 # ffffffffc0206740 <commands+0x9d0>
ffffffffc020173c:	00005617          	auipc	a2,0x5
ffffffffc0201740:	e8c60613          	addi	a2,a2,-372 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201744:	12700593          	li	a1,295
ffffffffc0201748:	00005517          	auipc	a0,0x5
ffffffffc020174c:	e9850513          	addi	a0,a0,-360 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201750:	d3ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201754:	00005697          	auipc	a3,0x5
ffffffffc0201758:	0cc68693          	addi	a3,a3,204 # ffffffffc0206820 <commands+0xab0>
ffffffffc020175c:	00005617          	auipc	a2,0x5
ffffffffc0201760:	e6c60613          	addi	a2,a2,-404 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201764:	12600593          	li	a1,294
ffffffffc0201768:	00005517          	auipc	a0,0x5
ffffffffc020176c:	e7850513          	addi	a0,a0,-392 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201770:	d1ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201774:	00005697          	auipc	a3,0x5
ffffffffc0201778:	07c68693          	addi	a3,a3,124 # ffffffffc02067f0 <commands+0xa80>
ffffffffc020177c:	00005617          	auipc	a2,0x5
ffffffffc0201780:	e4c60613          	addi	a2,a2,-436 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201784:	12500593          	li	a1,293
ffffffffc0201788:	00005517          	auipc	a0,0x5
ffffffffc020178c:	e5850513          	addi	a0,a0,-424 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201790:	cfffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201794:	00005697          	auipc	a3,0x5
ffffffffc0201798:	04468693          	addi	a3,a3,68 # ffffffffc02067d8 <commands+0xa68>
ffffffffc020179c:	00005617          	auipc	a2,0x5
ffffffffc02017a0:	e2c60613          	addi	a2,a2,-468 # ffffffffc02065c8 <commands+0x858>
ffffffffc02017a4:	12400593          	li	a1,292
ffffffffc02017a8:	00005517          	auipc	a0,0x5
ffffffffc02017ac:	e3850513          	addi	a0,a0,-456 # ffffffffc02065e0 <commands+0x870>
ffffffffc02017b0:	cdffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02017b4:	00005697          	auipc	a3,0x5
ffffffffc02017b8:	f8c68693          	addi	a3,a3,-116 # ffffffffc0206740 <commands+0x9d0>
ffffffffc02017bc:	00005617          	auipc	a2,0x5
ffffffffc02017c0:	e0c60613          	addi	a2,a2,-500 # ffffffffc02065c8 <commands+0x858>
ffffffffc02017c4:	11e00593          	li	a1,286
ffffffffc02017c8:	00005517          	auipc	a0,0x5
ffffffffc02017cc:	e1850513          	addi	a0,a0,-488 # ffffffffc02065e0 <commands+0x870>
ffffffffc02017d0:	cbffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(!PageProperty(p0));
ffffffffc02017d4:	00005697          	auipc	a3,0x5
ffffffffc02017d8:	fec68693          	addi	a3,a3,-20 # ffffffffc02067c0 <commands+0xa50>
ffffffffc02017dc:	00005617          	auipc	a2,0x5
ffffffffc02017e0:	dec60613          	addi	a2,a2,-532 # ffffffffc02065c8 <commands+0x858>
ffffffffc02017e4:	11900593          	li	a1,281
ffffffffc02017e8:	00005517          	auipc	a0,0x5
ffffffffc02017ec:	df850513          	addi	a0,a0,-520 # ffffffffc02065e0 <commands+0x870>
ffffffffc02017f0:	c9ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02017f4:	00005697          	auipc	a3,0x5
ffffffffc02017f8:	0ec68693          	addi	a3,a3,236 # ffffffffc02068e0 <commands+0xb70>
ffffffffc02017fc:	00005617          	auipc	a2,0x5
ffffffffc0201800:	dcc60613          	addi	a2,a2,-564 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201804:	13700593          	li	a1,311
ffffffffc0201808:	00005517          	auipc	a0,0x5
ffffffffc020180c:	dd850513          	addi	a0,a0,-552 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201810:	c7ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(total == 0);
ffffffffc0201814:	00005697          	auipc	a3,0x5
ffffffffc0201818:	0fc68693          	addi	a3,a3,252 # ffffffffc0206910 <commands+0xba0>
ffffffffc020181c:	00005617          	auipc	a2,0x5
ffffffffc0201820:	dac60613          	addi	a2,a2,-596 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201824:	14700593          	li	a1,327
ffffffffc0201828:	00005517          	auipc	a0,0x5
ffffffffc020182c:	db850513          	addi	a0,a0,-584 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201830:	c5ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(total == nr_free_pages());
ffffffffc0201834:	00005697          	auipc	a3,0x5
ffffffffc0201838:	dc468693          	addi	a3,a3,-572 # ffffffffc02065f8 <commands+0x888>
ffffffffc020183c:	00005617          	auipc	a2,0x5
ffffffffc0201840:	d8c60613          	addi	a2,a2,-628 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201844:	11300593          	li	a1,275
ffffffffc0201848:	00005517          	auipc	a0,0x5
ffffffffc020184c:	d9850513          	addi	a0,a0,-616 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201850:	c3ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201854:	00005697          	auipc	a3,0x5
ffffffffc0201858:	de468693          	addi	a3,a3,-540 # ffffffffc0206638 <commands+0x8c8>
ffffffffc020185c:	00005617          	auipc	a2,0x5
ffffffffc0201860:	d6c60613          	addi	a2,a2,-660 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201864:	0d800593          	li	a1,216
ffffffffc0201868:	00005517          	auipc	a0,0x5
ffffffffc020186c:	d7850513          	addi	a0,a0,-648 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201870:	c1ffe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201874 <default_free_pages>:
{
ffffffffc0201874:	1141                	addi	sp,sp,-16
ffffffffc0201876:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201878:	14058463          	beqz	a1,ffffffffc02019c0 <default_free_pages+0x14c>
    for (; p != base + n; p++)
ffffffffc020187c:	00659693          	slli	a3,a1,0x6
ffffffffc0201880:	96aa                	add	a3,a3,a0
ffffffffc0201882:	87aa                	mv	a5,a0
ffffffffc0201884:	02d50263          	beq	a0,a3,ffffffffc02018a8 <default_free_pages+0x34>
ffffffffc0201888:	6798                	ld	a4,8(a5)
ffffffffc020188a:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020188c:	10071a63          	bnez	a4,ffffffffc02019a0 <default_free_pages+0x12c>
ffffffffc0201890:	6798                	ld	a4,8(a5)
ffffffffc0201892:	8b09                	andi	a4,a4,2
ffffffffc0201894:	10071663          	bnez	a4,ffffffffc02019a0 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0201898:	0007b423          	sd	zero,8(a5)

// set_page_ref - 设置页面的引用计数
static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc020189c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02018a0:	04078793          	addi	a5,a5,64
ffffffffc02018a4:	fed792e3          	bne	a5,a3,ffffffffc0201888 <default_free_pages+0x14>
    base->property = n;
ffffffffc02018a8:	2581                	sext.w	a1,a1
ffffffffc02018aa:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02018ac:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018b0:	4789                	li	a5,2
ffffffffc02018b2:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02018b6:	000d1697          	auipc	a3,0xd1
ffffffffc02018ba:	4b268693          	addi	a3,a3,1202 # ffffffffc02d2d68 <free_area>
ffffffffc02018be:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018c0:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02018c2:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02018c6:	9db9                	addw	a1,a1,a4
ffffffffc02018c8:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc02018ca:	0ad78463          	beq	a5,a3,ffffffffc0201972 <default_free_pages+0xfe>
            struct Page *page = le2page(le, page_link);
ffffffffc02018ce:	fe878713          	addi	a4,a5,-24
ffffffffc02018d2:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc02018d6:	4581                	li	a1,0
            if (base < page)
ffffffffc02018d8:	00e56a63          	bltu	a0,a4,ffffffffc02018ec <default_free_pages+0x78>
    return listelm->next;
ffffffffc02018dc:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc02018de:	04d70c63          	beq	a4,a3,ffffffffc0201936 <default_free_pages+0xc2>
    for (; p != base + n; p++)
ffffffffc02018e2:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc02018e4:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc02018e8:	fee57ae3          	bgeu	a0,a4,ffffffffc02018dc <default_free_pages+0x68>
ffffffffc02018ec:	c199                	beqz	a1,ffffffffc02018f2 <default_free_pages+0x7e>
ffffffffc02018ee:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02018f2:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02018f4:	e390                	sd	a2,0(a5)
ffffffffc02018f6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02018f8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02018fa:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc02018fc:	00d70d63          	beq	a4,a3,ffffffffc0201916 <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc0201900:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201904:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc0201908:	02059813          	slli	a6,a1,0x20
ffffffffc020190c:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201910:	97b2                	add	a5,a5,a2
ffffffffc0201912:	02f50c63          	beq	a0,a5,ffffffffc020194a <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201916:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc0201918:	00d78c63          	beq	a5,a3,ffffffffc0201930 <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc020191c:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020191e:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc0201922:	02061593          	slli	a1,a2,0x20
ffffffffc0201926:	01a5d713          	srli	a4,a1,0x1a
ffffffffc020192a:	972a                	add	a4,a4,a0
ffffffffc020192c:	04e68a63          	beq	a3,a4,ffffffffc0201980 <default_free_pages+0x10c>
}
ffffffffc0201930:	60a2                	ld	ra,8(sp)
ffffffffc0201932:	0141                	addi	sp,sp,16
ffffffffc0201934:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201936:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201938:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020193a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020193c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc020193e:	02d70763          	beq	a4,a3,ffffffffc020196c <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0201942:	8832                	mv	a6,a2
ffffffffc0201944:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0201946:	87ba                	mv	a5,a4
ffffffffc0201948:	bf71                	j	ffffffffc02018e4 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc020194a:	491c                	lw	a5,16(a0)
ffffffffc020194c:	9dbd                	addw	a1,a1,a5
ffffffffc020194e:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201952:	57f5                	li	a5,-3
ffffffffc0201954:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201958:	01853803          	ld	a6,24(a0)
ffffffffc020195c:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc020195e:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201960:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0201964:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0201966:	0105b023          	sd	a6,0(a1)
ffffffffc020196a:	b77d                	j	ffffffffc0201918 <default_free_pages+0xa4>
ffffffffc020196c:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc020196e:	873e                	mv	a4,a5
ffffffffc0201970:	bf41                	j	ffffffffc0201900 <default_free_pages+0x8c>
}
ffffffffc0201972:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201974:	e390                	sd	a2,0(a5)
ffffffffc0201976:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201978:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020197a:	ed1c                	sd	a5,24(a0)
ffffffffc020197c:	0141                	addi	sp,sp,16
ffffffffc020197e:	8082                	ret
            base->property += p->property;
ffffffffc0201980:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201984:	ff078693          	addi	a3,a5,-16
ffffffffc0201988:	9e39                	addw	a2,a2,a4
ffffffffc020198a:	c910                	sw	a2,16(a0)
ffffffffc020198c:	5775                	li	a4,-3
ffffffffc020198e:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201992:	6398                	ld	a4,0(a5)
ffffffffc0201994:	679c                	ld	a5,8(a5)
}
ffffffffc0201996:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201998:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020199a:	e398                	sd	a4,0(a5)
ffffffffc020199c:	0141                	addi	sp,sp,16
ffffffffc020199e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02019a0:	00005697          	auipc	a3,0x5
ffffffffc02019a4:	f8868693          	addi	a3,a3,-120 # ffffffffc0206928 <commands+0xbb8>
ffffffffc02019a8:	00005617          	auipc	a2,0x5
ffffffffc02019ac:	c2060613          	addi	a2,a2,-992 # ffffffffc02065c8 <commands+0x858>
ffffffffc02019b0:	09400593          	li	a1,148
ffffffffc02019b4:	00005517          	auipc	a0,0x5
ffffffffc02019b8:	c2c50513          	addi	a0,a0,-980 # ffffffffc02065e0 <commands+0x870>
ffffffffc02019bc:	ad3fe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(n > 0);
ffffffffc02019c0:	00005697          	auipc	a3,0x5
ffffffffc02019c4:	f6068693          	addi	a3,a3,-160 # ffffffffc0206920 <commands+0xbb0>
ffffffffc02019c8:	00005617          	auipc	a2,0x5
ffffffffc02019cc:	c0060613          	addi	a2,a2,-1024 # ffffffffc02065c8 <commands+0x858>
ffffffffc02019d0:	09000593          	li	a1,144
ffffffffc02019d4:	00005517          	auipc	a0,0x5
ffffffffc02019d8:	c0c50513          	addi	a0,a0,-1012 # ffffffffc02065e0 <commands+0x870>
ffffffffc02019dc:	ab3fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02019e0 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02019e0:	c941                	beqz	a0,ffffffffc0201a70 <default_alloc_pages+0x90>
    if (n > nr_free)
ffffffffc02019e2:	000d1597          	auipc	a1,0xd1
ffffffffc02019e6:	38658593          	addi	a1,a1,902 # ffffffffc02d2d68 <free_area>
ffffffffc02019ea:	0105a803          	lw	a6,16(a1)
ffffffffc02019ee:	872a                	mv	a4,a0
ffffffffc02019f0:	02081793          	slli	a5,a6,0x20
ffffffffc02019f4:	9381                	srli	a5,a5,0x20
ffffffffc02019f6:	00a7ee63          	bltu	a5,a0,ffffffffc0201a12 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02019fa:	87ae                	mv	a5,a1
ffffffffc02019fc:	a801                	j	ffffffffc0201a0c <default_alloc_pages+0x2c>
        if (p->property >= n)
ffffffffc02019fe:	ff87a683          	lw	a3,-8(a5)
ffffffffc0201a02:	02069613          	slli	a2,a3,0x20
ffffffffc0201a06:	9201                	srli	a2,a2,0x20
ffffffffc0201a08:	00e67763          	bgeu	a2,a4,ffffffffc0201a16 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201a0c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc0201a0e:	feb798e3          	bne	a5,a1,ffffffffc02019fe <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201a12:	4501                	li	a0,0
}
ffffffffc0201a14:	8082                	ret
    return listelm->prev;
ffffffffc0201a16:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201a1a:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201a1e:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0201a22:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201a26:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201a2a:	01133023          	sd	a7,0(t1)
        if (page->property > n)
ffffffffc0201a2e:	02c77863          	bgeu	a4,a2,ffffffffc0201a5e <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0201a32:	071a                	slli	a4,a4,0x6
ffffffffc0201a34:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201a36:	41c686bb          	subw	a3,a3,t3
ffffffffc0201a3a:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201a3c:	00870613          	addi	a2,a4,8
ffffffffc0201a40:	4689                	li	a3,2
ffffffffc0201a42:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201a46:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201a4a:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0201a4e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201a52:	e290                	sd	a2,0(a3)
ffffffffc0201a54:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201a58:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0201a5a:	01173c23          	sd	a7,24(a4)
ffffffffc0201a5e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201a62:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201a66:	5775                	li	a4,-3
ffffffffc0201a68:	17c1                	addi	a5,a5,-16
ffffffffc0201a6a:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201a6e:	8082                	ret
{
ffffffffc0201a70:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201a72:	00005697          	auipc	a3,0x5
ffffffffc0201a76:	eae68693          	addi	a3,a3,-338 # ffffffffc0206920 <commands+0xbb0>
ffffffffc0201a7a:	00005617          	auipc	a2,0x5
ffffffffc0201a7e:	b4e60613          	addi	a2,a2,-1202 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201a82:	06c00593          	li	a1,108
ffffffffc0201a86:	00005517          	auipc	a0,0x5
ffffffffc0201a8a:	b5a50513          	addi	a0,a0,-1190 # ffffffffc02065e0 <commands+0x870>
{
ffffffffc0201a8e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201a90:	9fffe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201a94 <default_init_memmap>:
{
ffffffffc0201a94:	1141                	addi	sp,sp,-16
ffffffffc0201a96:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201a98:	c5f1                	beqz	a1,ffffffffc0201b64 <default_init_memmap+0xd0>
    for (; p != base + n; p++)
ffffffffc0201a9a:	00659693          	slli	a3,a1,0x6
ffffffffc0201a9e:	96aa                	add	a3,a3,a0
ffffffffc0201aa0:	87aa                	mv	a5,a0
ffffffffc0201aa2:	00d50f63          	beq	a0,a3,ffffffffc0201ac0 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201aa6:	6798                	ld	a4,8(a5)
ffffffffc0201aa8:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0201aaa:	cf49                	beqz	a4,ffffffffc0201b44 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0201aac:	0007a823          	sw	zero,16(a5)
ffffffffc0201ab0:	0007b423          	sd	zero,8(a5)
ffffffffc0201ab4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0201ab8:	04078793          	addi	a5,a5,64
ffffffffc0201abc:	fed795e3          	bne	a5,a3,ffffffffc0201aa6 <default_init_memmap+0x12>
    base->property = n;
ffffffffc0201ac0:	2581                	sext.w	a1,a1
ffffffffc0201ac2:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201ac4:	4789                	li	a5,2
ffffffffc0201ac6:	00850713          	addi	a4,a0,8
ffffffffc0201aca:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201ace:	000d1697          	auipc	a3,0xd1
ffffffffc0201ad2:	29a68693          	addi	a3,a3,666 # ffffffffc02d2d68 <free_area>
ffffffffc0201ad6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201ad8:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201ada:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201ade:	9db9                	addw	a1,a1,a4
ffffffffc0201ae0:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0201ae2:	04d78a63          	beq	a5,a3,ffffffffc0201b36 <default_init_memmap+0xa2>
            struct Page *page = le2page(le, page_link);
ffffffffc0201ae6:	fe878713          	addi	a4,a5,-24
ffffffffc0201aea:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0201aee:	4581                	li	a1,0
            if (base < page)
ffffffffc0201af0:	00e56a63          	bltu	a0,a4,ffffffffc0201b04 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201af4:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201af6:	02d70263          	beq	a4,a3,ffffffffc0201b1a <default_init_memmap+0x86>
    for (; p != base + n; p++)
ffffffffc0201afa:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201afc:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201b00:	fee57ae3          	bgeu	a0,a4,ffffffffc0201af4 <default_init_memmap+0x60>
ffffffffc0201b04:	c199                	beqz	a1,ffffffffc0201b0a <default_init_memmap+0x76>
ffffffffc0201b06:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201b0a:	6398                	ld	a4,0(a5)
}
ffffffffc0201b0c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201b0e:	e390                	sd	a2,0(a5)
ffffffffc0201b10:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201b12:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201b14:	ed18                	sd	a4,24(a0)
ffffffffc0201b16:	0141                	addi	sp,sp,16
ffffffffc0201b18:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201b1a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201b1c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201b1e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201b20:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0201b22:	00d70663          	beq	a4,a3,ffffffffc0201b2e <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0201b26:	8832                	mv	a6,a2
ffffffffc0201b28:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0201b2a:	87ba                	mv	a5,a4
ffffffffc0201b2c:	bfc1                	j	ffffffffc0201afc <default_init_memmap+0x68>
}
ffffffffc0201b2e:	60a2                	ld	ra,8(sp)
ffffffffc0201b30:	e290                	sd	a2,0(a3)
ffffffffc0201b32:	0141                	addi	sp,sp,16
ffffffffc0201b34:	8082                	ret
ffffffffc0201b36:	60a2                	ld	ra,8(sp)
ffffffffc0201b38:	e390                	sd	a2,0(a5)
ffffffffc0201b3a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201b3c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201b3e:	ed1c                	sd	a5,24(a0)
ffffffffc0201b40:	0141                	addi	sp,sp,16
ffffffffc0201b42:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201b44:	00005697          	auipc	a3,0x5
ffffffffc0201b48:	e0c68693          	addi	a3,a3,-500 # ffffffffc0206950 <commands+0xbe0>
ffffffffc0201b4c:	00005617          	auipc	a2,0x5
ffffffffc0201b50:	a7c60613          	addi	a2,a2,-1412 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201b54:	04b00593          	li	a1,75
ffffffffc0201b58:	00005517          	auipc	a0,0x5
ffffffffc0201b5c:	a8850513          	addi	a0,a0,-1400 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201b60:	92ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(n > 0);
ffffffffc0201b64:	00005697          	auipc	a3,0x5
ffffffffc0201b68:	dbc68693          	addi	a3,a3,-580 # ffffffffc0206920 <commands+0xbb0>
ffffffffc0201b6c:	00005617          	auipc	a2,0x5
ffffffffc0201b70:	a5c60613          	addi	a2,a2,-1444 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201b74:	04700593          	li	a1,71
ffffffffc0201b78:	00005517          	auipc	a0,0x5
ffffffffc0201b7c:	a6850513          	addi	a0,a0,-1432 # ffffffffc02065e0 <commands+0x870>
ffffffffc0201b80:	90ffe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201b84 <slob_free>:
static void slob_free(void *block, int size)
{
    slob_t *cur, *b = (slob_t *)block;
    unsigned long flags;

    if (!block)
ffffffffc0201b84:	c94d                	beqz	a0,ffffffffc0201c36 <slob_free+0xb2>
{
ffffffffc0201b86:	1141                	addi	sp,sp,-16
ffffffffc0201b88:	e022                	sd	s0,0(sp)
ffffffffc0201b8a:	e406                	sd	ra,8(sp)
ffffffffc0201b8c:	842a                	mv	s0,a0
        return;

    // 如果指定了 size，更新头部信息 (通常在注入新页时使用)
    if (size)
ffffffffc0201b8e:	e9c1                	bnez	a1,ffffffffc0201c1e <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b90:	100027f3          	csrr	a5,sstatus
ffffffffc0201b94:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201b96:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b98:	ebd9                	bnez	a5,ffffffffc0201c2e <slob_free+0xaa>
        b->units = SLOB_UNITS(size);

    /* Find reinsertion point 寻找插入点 */
    // SLOB 链表是按地址排序的，我们需要找到 b 应该插入的位置
    spin_lock_irqsave(&slob_lock, flags);
    for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201b9a:	000d1617          	auipc	a2,0xd1
ffffffffc0201b9e:	dbe60613          	addi	a2,a2,-578 # ffffffffc02d2958 <slobfree>
ffffffffc0201ba2:	621c                	ld	a5,0(a2)
        // 处理链表环的边界情况 (cur >= cur->next 表示链表尾部/头部交界处)
        if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201ba4:	873e                	mv	a4,a5
    for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201ba6:	679c                	ld	a5,8(a5)
ffffffffc0201ba8:	02877a63          	bgeu	a4,s0,ffffffffc0201bdc <slob_free+0x58>
ffffffffc0201bac:	00f46463          	bltu	s0,a5,ffffffffc0201bb4 <slob_free+0x30>
        if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201bb0:	fef76ae3          	bltu	a4,a5,ffffffffc0201ba4 <slob_free+0x20>
    // 此时，cur 是 b 的前一个节点 (地址小于 b)
    // cur->next 是 b 的后一个节点 (地址大于 b)

    // 1. 尝试与后一个块合并 (Coalescing with next)
    // 如果 b 的结束地址等于下一个块的起始地址
    if (b + b->units == cur->next)
ffffffffc0201bb4:	400c                	lw	a1,0(s0)
ffffffffc0201bb6:	00459693          	slli	a3,a1,0x4
ffffffffc0201bba:	96a2                	add	a3,a3,s0
ffffffffc0201bbc:	02d78a63          	beq	a5,a3,ffffffffc0201bf0 <slob_free+0x6c>
    else
        b->next = cur->next;          // 否则直接链接

    // 2. 尝试与前一个块合并 (Coalescing with prev)
    // 如果 cur 的结束地址等于 b 的起始地址
    if (cur + cur->units == b)
ffffffffc0201bc0:	4314                	lw	a3,0(a4)
        b->next = cur->next;          // 否则直接链接
ffffffffc0201bc2:	e41c                	sd	a5,8(s0)
    if (cur + cur->units == b)
ffffffffc0201bc4:	00469793          	slli	a5,a3,0x4
ffffffffc0201bc8:	97ba                	add	a5,a5,a4
ffffffffc0201bca:	02f40e63          	beq	s0,a5,ffffffffc0201c06 <slob_free+0x82>
    {
        cur->units += b->units;       // 合并大小
        cur->next = b->next;          // 跳过 b
    }
    else
        cur->next = b;                // 否则 cur 指向 b
ffffffffc0201bce:	e700                	sd	s0,8(a4)

    // 将 slobfree 指向当前操作的位置，利用局部性原理
    slobfree = cur;
ffffffffc0201bd0:	e218                	sd	a4,0(a2)
    if (flag)
ffffffffc0201bd2:	e129                	bnez	a0,ffffffffc0201c14 <slob_free+0x90>

    spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201bd4:	60a2                	ld	ra,8(sp)
ffffffffc0201bd6:	6402                	ld	s0,0(sp)
ffffffffc0201bd8:	0141                	addi	sp,sp,16
ffffffffc0201bda:	8082                	ret
        if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201bdc:	fcf764e3          	bltu	a4,a5,ffffffffc0201ba4 <slob_free+0x20>
ffffffffc0201be0:	fcf472e3          	bgeu	s0,a5,ffffffffc0201ba4 <slob_free+0x20>
    if (b + b->units == cur->next)
ffffffffc0201be4:	400c                	lw	a1,0(s0)
ffffffffc0201be6:	00459693          	slli	a3,a1,0x4
ffffffffc0201bea:	96a2                	add	a3,a3,s0
ffffffffc0201bec:	fcd79ae3          	bne	a5,a3,ffffffffc0201bc0 <slob_free+0x3c>
        b->units += cur->next->units; // 合并大小
ffffffffc0201bf0:	4394                	lw	a3,0(a5)
        b->next = cur->next->next;    // 跳过下一个块
ffffffffc0201bf2:	679c                	ld	a5,8(a5)
        b->units += cur->next->units; // 合并大小
ffffffffc0201bf4:	9db5                	addw	a1,a1,a3
ffffffffc0201bf6:	c00c                	sw	a1,0(s0)
    if (cur + cur->units == b)
ffffffffc0201bf8:	4314                	lw	a3,0(a4)
        b->next = cur->next->next;    // 跳过下一个块
ffffffffc0201bfa:	e41c                	sd	a5,8(s0)
    if (cur + cur->units == b)
ffffffffc0201bfc:	00469793          	slli	a5,a3,0x4
ffffffffc0201c00:	97ba                	add	a5,a5,a4
ffffffffc0201c02:	fcf416e3          	bne	s0,a5,ffffffffc0201bce <slob_free+0x4a>
        cur->units += b->units;       // 合并大小
ffffffffc0201c06:	401c                	lw	a5,0(s0)
        cur->next = b->next;          // 跳过 b
ffffffffc0201c08:	640c                	ld	a1,8(s0)
    slobfree = cur;
ffffffffc0201c0a:	e218                	sd	a4,0(a2)
        cur->units += b->units;       // 合并大小
ffffffffc0201c0c:	9ebd                	addw	a3,a3,a5
ffffffffc0201c0e:	c314                	sw	a3,0(a4)
        cur->next = b->next;          // 跳过 b
ffffffffc0201c10:	e70c                	sd	a1,8(a4)
ffffffffc0201c12:	d169                	beqz	a0,ffffffffc0201bd4 <slob_free+0x50>
}
ffffffffc0201c14:	6402                	ld	s0,0(sp)
ffffffffc0201c16:	60a2                	ld	ra,8(sp)
ffffffffc0201c18:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201c1a:	d95fe06f          	j	ffffffffc02009ae <intr_enable>
        b->units = SLOB_UNITS(size);
ffffffffc0201c1e:	25bd                	addiw	a1,a1,15
ffffffffc0201c20:	8191                	srli	a1,a1,0x4
ffffffffc0201c22:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c24:	100027f3          	csrr	a5,sstatus
ffffffffc0201c28:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201c2a:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c2c:	d7bd                	beqz	a5,ffffffffc0201b9a <slob_free+0x16>
        intr_disable();
ffffffffc0201c2e:	d87fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0201c32:	4505                	li	a0,1
ffffffffc0201c34:	b79d                	j	ffffffffc0201b9a <slob_free+0x16>
ffffffffc0201c36:	8082                	ret

ffffffffc0201c38 <__slob_get_free_pages.constprop.0>:
    struct Page *page = alloc_pages(1 << order);
ffffffffc0201c38:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201c3a:	1141                	addi	sp,sp,-16
    struct Page *page = alloc_pages(1 << order);
ffffffffc0201c3c:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201c40:	e406                	sd	ra,8(sp)
    struct Page *page = alloc_pages(1 << order);
ffffffffc0201c42:	362000ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
    if (!page)
ffffffffc0201c46:	c91d                	beqz	a0,ffffffffc0201c7c <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201c48:	000d5697          	auipc	a3,0xd5
ffffffffc0201c4c:	1a06b683          	ld	a3,416(a3) # ffffffffc02d6de8 <pages>
ffffffffc0201c50:	8d15                	sub	a0,a0,a3
ffffffffc0201c52:	8519                	srai	a0,a0,0x6
ffffffffc0201c54:	00006697          	auipc	a3,0x6
ffffffffc0201c58:	7d46b683          	ld	a3,2004(a3) # ffffffffc0208428 <nbase>
ffffffffc0201c5c:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201c5e:	00c51793          	slli	a5,a0,0xc
ffffffffc0201c62:	83b1                	srli	a5,a5,0xc
ffffffffc0201c64:	000d5717          	auipc	a4,0xd5
ffffffffc0201c68:	17c73703          	ld	a4,380(a4) # ffffffffc02d6de0 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c6c:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201c6e:	00e7fa63          	bgeu	a5,a4,ffffffffc0201c82 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201c72:	000d5697          	auipc	a3,0xd5
ffffffffc0201c76:	1866b683          	ld	a3,390(a3) # ffffffffc02d6df8 <va_pa_offset>
ffffffffc0201c7a:	9536                	add	a0,a0,a3
}
ffffffffc0201c7c:	60a2                	ld	ra,8(sp)
ffffffffc0201c7e:	0141                	addi	sp,sp,16
ffffffffc0201c80:	8082                	ret
ffffffffc0201c82:	86aa                	mv	a3,a0
ffffffffc0201c84:	00005617          	auipc	a2,0x5
ffffffffc0201c88:	d2c60613          	addi	a2,a2,-724 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0201c8c:	0bd00593          	li	a1,189
ffffffffc0201c90:	00005517          	auipc	a0,0x5
ffffffffc0201c94:	d4850513          	addi	a0,a0,-696 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0201c98:	ff6fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201c9c <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201c9c:	1101                	addi	sp,sp,-32
ffffffffc0201c9e:	ec06                	sd	ra,24(sp)
ffffffffc0201ca0:	e822                	sd	s0,16(sp)
ffffffffc0201ca2:	e426                	sd	s1,8(sp)
ffffffffc0201ca4:	e04a                	sd	s2,0(sp)
    assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201ca6:	01050713          	addi	a4,a0,16
ffffffffc0201caa:	6785                	lui	a5,0x1
ffffffffc0201cac:	0cf77363          	bgeu	a4,a5,ffffffffc0201d72 <slob_alloc.constprop.0+0xd6>
    int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201cb0:	00f50493          	addi	s1,a0,15
ffffffffc0201cb4:	8091                	srli	s1,s1,0x4
ffffffffc0201cb6:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201cb8:	10002673          	csrr	a2,sstatus
ffffffffc0201cbc:	8a09                	andi	a2,a2,2
ffffffffc0201cbe:	e25d                	bnez	a2,ffffffffc0201d64 <slob_alloc.constprop.0+0xc8>
    prev = slobfree;
ffffffffc0201cc0:	000d1917          	auipc	s2,0xd1
ffffffffc0201cc4:	c9890913          	addi	s2,s2,-872 # ffffffffc02d2958 <slobfree>
ffffffffc0201cc8:	00093683          	ld	a3,0(s2)
    for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201ccc:	669c                	ld	a5,8(a3)
        if (cur->units >= units + delta)
ffffffffc0201cce:	4398                	lw	a4,0(a5)
ffffffffc0201cd0:	08975e63          	bge	a4,s1,ffffffffc0201d6c <slob_alloc.constprop.0+0xd0>
        if (cur == slobfree)
ffffffffc0201cd4:	00f68b63          	beq	a3,a5,ffffffffc0201cea <slob_alloc.constprop.0+0x4e>
    for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201cd8:	6780                	ld	s0,8(a5)
        if (cur->units >= units + delta)
ffffffffc0201cda:	4018                	lw	a4,0(s0)
ffffffffc0201cdc:	02975a63          	bge	a4,s1,ffffffffc0201d10 <slob_alloc.constprop.0+0x74>
        if (cur == slobfree)
ffffffffc0201ce0:	00093683          	ld	a3,0(s2)
ffffffffc0201ce4:	87a2                	mv	a5,s0
ffffffffc0201ce6:	fef699e3          	bne	a3,a5,ffffffffc0201cd8 <slob_alloc.constprop.0+0x3c>
    if (flag)
ffffffffc0201cea:	ee31                	bnez	a2,ffffffffc0201d46 <slob_alloc.constprop.0+0xaa>
            cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201cec:	4501                	li	a0,0
ffffffffc0201cee:	f4bff0ef          	jal	ra,ffffffffc0201c38 <__slob_get_free_pages.constprop.0>
ffffffffc0201cf2:	842a                	mv	s0,a0
            if (!cur)
ffffffffc0201cf4:	cd05                	beqz	a0,ffffffffc0201d2c <slob_alloc.constprop.0+0x90>
            slob_free(cur, PAGE_SIZE);
ffffffffc0201cf6:	6585                	lui	a1,0x1
ffffffffc0201cf8:	e8dff0ef          	jal	ra,ffffffffc0201b84 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201cfc:	10002673          	csrr	a2,sstatus
ffffffffc0201d00:	8a09                	andi	a2,a2,2
ffffffffc0201d02:	ee05                	bnez	a2,ffffffffc0201d3a <slob_alloc.constprop.0+0x9e>
            cur = slobfree;
ffffffffc0201d04:	00093783          	ld	a5,0(s2)
    for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201d08:	6780                	ld	s0,8(a5)
        if (cur->units >= units + delta)
ffffffffc0201d0a:	4018                	lw	a4,0(s0)
ffffffffc0201d0c:	fc974ae3          	blt	a4,s1,ffffffffc0201ce0 <slob_alloc.constprop.0+0x44>
            if (cur->units == units)    /* exact fit? */
ffffffffc0201d10:	04e48763          	beq	s1,a4,ffffffffc0201d5e <slob_alloc.constprop.0+0xc2>
                prev->next = cur + units;
ffffffffc0201d14:	00449693          	slli	a3,s1,0x4
ffffffffc0201d18:	96a2                	add	a3,a3,s0
ffffffffc0201d1a:	e794                	sd	a3,8(a5)
                prev->next->next = cur->next;
ffffffffc0201d1c:	640c                	ld	a1,8(s0)
                prev->next->units = cur->units - units;
ffffffffc0201d1e:	9f05                	subw	a4,a4,s1
ffffffffc0201d20:	c298                	sw	a4,0(a3)
                prev->next->next = cur->next;
ffffffffc0201d22:	e68c                	sd	a1,8(a3)
                cur->units = units;
ffffffffc0201d24:	c004                	sw	s1,0(s0)
            slobfree = prev;
ffffffffc0201d26:	00f93023          	sd	a5,0(s2)
    if (flag)
ffffffffc0201d2a:	e20d                	bnez	a2,ffffffffc0201d4c <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201d2c:	60e2                	ld	ra,24(sp)
ffffffffc0201d2e:	8522                	mv	a0,s0
ffffffffc0201d30:	6442                	ld	s0,16(sp)
ffffffffc0201d32:	64a2                	ld	s1,8(sp)
ffffffffc0201d34:	6902                	ld	s2,0(sp)
ffffffffc0201d36:	6105                	addi	sp,sp,32
ffffffffc0201d38:	8082                	ret
        intr_disable();
ffffffffc0201d3a:	c7bfe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
            cur = slobfree;
ffffffffc0201d3e:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201d42:	4605                	li	a2,1
ffffffffc0201d44:	b7d1                	j	ffffffffc0201d08 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201d46:	c69fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201d4a:	b74d                	j	ffffffffc0201cec <slob_alloc.constprop.0+0x50>
ffffffffc0201d4c:	c63fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
}
ffffffffc0201d50:	60e2                	ld	ra,24(sp)
ffffffffc0201d52:	8522                	mv	a0,s0
ffffffffc0201d54:	6442                	ld	s0,16(sp)
ffffffffc0201d56:	64a2                	ld	s1,8(sp)
ffffffffc0201d58:	6902                	ld	s2,0(sp)
ffffffffc0201d5a:	6105                	addi	sp,sp,32
ffffffffc0201d5c:	8082                	ret
                prev->next = cur->next; /* unlink */
ffffffffc0201d5e:	6418                	ld	a4,8(s0)
ffffffffc0201d60:	e798                	sd	a4,8(a5)
ffffffffc0201d62:	b7d1                	j	ffffffffc0201d26 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201d64:	c51fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0201d68:	4605                	li	a2,1
ffffffffc0201d6a:	bf99                	j	ffffffffc0201cc0 <slob_alloc.constprop.0+0x24>
        if (cur->units >= units + delta)
ffffffffc0201d6c:	843e                	mv	s0,a5
ffffffffc0201d6e:	87b6                	mv	a5,a3
ffffffffc0201d70:	b745                	j	ffffffffc0201d10 <slob_alloc.constprop.0+0x74>
    assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201d72:	00005697          	auipc	a3,0x5
ffffffffc0201d76:	c7668693          	addi	a3,a3,-906 # ffffffffc02069e8 <default_pmm_manager+0x70>
ffffffffc0201d7a:	00005617          	auipc	a2,0x5
ffffffffc0201d7e:	84e60613          	addi	a2,a2,-1970 # ffffffffc02065c8 <commands+0x858>
ffffffffc0201d82:	07300593          	li	a1,115
ffffffffc0201d86:	00005517          	auipc	a0,0x5
ffffffffc0201d8a:	c8250513          	addi	a0,a0,-894 # ffffffffc0206a08 <default_pmm_manager+0x90>
ffffffffc0201d8e:	f00fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201d92 <kmalloc_init>:
}

// kmalloc_init - 对外暴露的初始化接口
inline void
kmalloc_init(void)
{
ffffffffc0201d92:	1141                	addi	sp,sp,-16
    cprintf("use SLOB allocator\n");
ffffffffc0201d94:	00005517          	auipc	a0,0x5
ffffffffc0201d98:	c8c50513          	addi	a0,a0,-884 # ffffffffc0206a20 <default_pmm_manager+0xa8>
{
ffffffffc0201d9c:	e406                	sd	ra,8(sp)
    cprintf("use SLOB allocator\n");
ffffffffc0201d9e:	bf6fe0ef          	jal	ra,ffffffffc0200194 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201da2:	60a2                	ld	ra,8(sp)

/* 初始化锁，设置为 0 (未锁定) */
static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc0201da4:	000d5797          	auipc	a5,0xd5
ffffffffc0201da8:	0207b223          	sd	zero,36(a5) # ffffffffc02d6dc8 <slob_lock>
ffffffffc0201dac:	000d5797          	auipc	a5,0xd5
ffffffffc0201db0:	0007ba23          	sd	zero,20(a5) # ffffffffc02d6dc0 <block_lock>
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201db4:	00005517          	auipc	a0,0x5
ffffffffc0201db8:	c8450513          	addi	a0,a0,-892 # ffffffffc0206a38 <default_pmm_manager+0xc0>
}
ffffffffc0201dbc:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201dbe:	bd6fe06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0201dc2 <kallocated>:

size_t
kallocated(void)
{
    return slob_allocated();
}
ffffffffc0201dc2:	4501                	li	a0,0
ffffffffc0201dc4:	8082                	ret

ffffffffc0201dc6 <kmalloc>:
}

// kmalloc - 内核通用内存分配接口
void *
kmalloc(size_t size)
{
ffffffffc0201dc6:	1101                	addi	sp,sp,-32
ffffffffc0201dc8:	e04a                	sd	s2,0(sp)
    if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201dca:	6905                	lui	s2,0x1
{
ffffffffc0201dcc:	e822                	sd	s0,16(sp)
ffffffffc0201dce:	ec06                	sd	ra,24(sp)
ffffffffc0201dd0:	e426                	sd	s1,8(sp)
    if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201dd2:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8d71>
{
ffffffffc0201dd6:	842a                	mv	s0,a0
    if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201dd8:	04a7f963          	bgeu	a5,a0,ffffffffc0201e2a <kmalloc+0x64>
    bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201ddc:	4561                	li	a0,24
ffffffffc0201dde:	ebfff0ef          	jal	ra,ffffffffc0201c9c <slob_alloc.constprop.0>
ffffffffc0201de2:	84aa                	mv	s1,a0
    if (!bb)
ffffffffc0201de4:	c929                	beqz	a0,ffffffffc0201e36 <kmalloc+0x70>
    bb->order = find_order(size);
ffffffffc0201de6:	0004079b          	sext.w	a5,s0
    int order = 0;
ffffffffc0201dea:	4501                	li	a0,0
    for (; size > 4096; size >>= 1)
ffffffffc0201dec:	00f95763          	bge	s2,a5,ffffffffc0201dfa <kmalloc+0x34>
ffffffffc0201df0:	6705                	lui	a4,0x1
ffffffffc0201df2:	8785                	srai	a5,a5,0x1
        order++;
ffffffffc0201df4:	2505                	addiw	a0,a0,1
    for (; size > 4096; size >>= 1)
ffffffffc0201df6:	fef74ee3          	blt	a4,a5,ffffffffc0201df2 <kmalloc+0x2c>
    bb->order = find_order(size);
ffffffffc0201dfa:	c088                	sw	a0,0(s1)
    bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201dfc:	e3dff0ef          	jal	ra,ffffffffc0201c38 <__slob_get_free_pages.constprop.0>
ffffffffc0201e00:	e488                	sd	a0,8(s1)
ffffffffc0201e02:	842a                	mv	s0,a0
    if (bb->pages)
ffffffffc0201e04:	c525                	beqz	a0,ffffffffc0201e6c <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e06:	100027f3          	csrr	a5,sstatus
ffffffffc0201e0a:	8b89                	andi	a5,a5,2
ffffffffc0201e0c:	ef8d                	bnez	a5,ffffffffc0201e46 <kmalloc+0x80>
        bb->next = bigblocks;
ffffffffc0201e0e:	000d5797          	auipc	a5,0xd5
ffffffffc0201e12:	faa78793          	addi	a5,a5,-86 # ffffffffc02d6db8 <bigblocks>
ffffffffc0201e16:	6398                	ld	a4,0(a5)
        bigblocks = bb;
ffffffffc0201e18:	e384                	sd	s1,0(a5)
        bb->next = bigblocks;
ffffffffc0201e1a:	e898                	sd	a4,16(s1)
    return __kmalloc(size, 0);
}
ffffffffc0201e1c:	60e2                	ld	ra,24(sp)
ffffffffc0201e1e:	8522                	mv	a0,s0
ffffffffc0201e20:	6442                	ld	s0,16(sp)
ffffffffc0201e22:	64a2                	ld	s1,8(sp)
ffffffffc0201e24:	6902                	ld	s2,0(sp)
ffffffffc0201e26:	6105                	addi	sp,sp,32
ffffffffc0201e28:	8082                	ret
        m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201e2a:	0541                	addi	a0,a0,16
ffffffffc0201e2c:	e71ff0ef          	jal	ra,ffffffffc0201c9c <slob_alloc.constprop.0>
        return m ? (void *)(m + 1) : 0;
ffffffffc0201e30:	01050413          	addi	s0,a0,16
ffffffffc0201e34:	f565                	bnez	a0,ffffffffc0201e1c <kmalloc+0x56>
ffffffffc0201e36:	4401                	li	s0,0
}
ffffffffc0201e38:	60e2                	ld	ra,24(sp)
ffffffffc0201e3a:	8522                	mv	a0,s0
ffffffffc0201e3c:	6442                	ld	s0,16(sp)
ffffffffc0201e3e:	64a2                	ld	s1,8(sp)
ffffffffc0201e40:	6902                	ld	s2,0(sp)
ffffffffc0201e42:	6105                	addi	sp,sp,32
ffffffffc0201e44:	8082                	ret
        intr_disable();
ffffffffc0201e46:	b6ffe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        bb->next = bigblocks;
ffffffffc0201e4a:	000d5797          	auipc	a5,0xd5
ffffffffc0201e4e:	f6e78793          	addi	a5,a5,-146 # ffffffffc02d6db8 <bigblocks>
ffffffffc0201e52:	6398                	ld	a4,0(a5)
        bigblocks = bb;
ffffffffc0201e54:	e384                	sd	s1,0(a5)
        bb->next = bigblocks;
ffffffffc0201e56:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201e58:	b57fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
        return bb->pages;
ffffffffc0201e5c:	6480                	ld	s0,8(s1)
}
ffffffffc0201e5e:	60e2                	ld	ra,24(sp)
ffffffffc0201e60:	64a2                	ld	s1,8(sp)
ffffffffc0201e62:	8522                	mv	a0,s0
ffffffffc0201e64:	6442                	ld	s0,16(sp)
ffffffffc0201e66:	6902                	ld	s2,0(sp)
ffffffffc0201e68:	6105                	addi	sp,sp,32
ffffffffc0201e6a:	8082                	ret
    slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e6c:	45e1                	li	a1,24
ffffffffc0201e6e:	8526                	mv	a0,s1
ffffffffc0201e70:	d15ff0ef          	jal	ra,ffffffffc0201b84 <slob_free>
    return __kmalloc(size, 0);
ffffffffc0201e74:	b765                	j	ffffffffc0201e1c <kmalloc+0x56>

ffffffffc0201e76 <kfree>:
void kfree(void *block)
{
    bigblock_t *bb, **last = &bigblocks;
    unsigned long flags;

    if (!block)
ffffffffc0201e76:	c169                	beqz	a0,ffffffffc0201f38 <kfree+0xc2>
{
ffffffffc0201e78:	1101                	addi	sp,sp,-32
ffffffffc0201e7a:	e822                	sd	s0,16(sp)
ffffffffc0201e7c:	ec06                	sd	ra,24(sp)
ffffffffc0201e7e:	e426                	sd	s1,8(sp)
        return;

    // 1. 检查地址是否按页对齐
    // 如果是页对齐的，它可能是通过 bigblock 机制分配的大块
    if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201e80:	03451793          	slli	a5,a0,0x34
ffffffffc0201e84:	842a                	mv	s0,a0
ffffffffc0201e86:	e3d9                	bnez	a5,ffffffffc0201f0c <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e88:	100027f3          	csrr	a5,sstatus
ffffffffc0201e8c:	8b89                	andi	a5,a5,2
ffffffffc0201e8e:	e7d9                	bnez	a5,ffffffffc0201f1c <kfree+0xa6>
    {
        /* might be on the big block list */
        spin_lock_irqsave(&block_lock, flags);
        // 遍历 bigblocks 链表查找该地址
        for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201e90:	000d5797          	auipc	a5,0xd5
ffffffffc0201e94:	f287b783          	ld	a5,-216(a5) # ffffffffc02d6db8 <bigblocks>
    return 0;
ffffffffc0201e98:	4601                	li	a2,0
ffffffffc0201e9a:	cbad                	beqz	a5,ffffffffc0201f0c <kfree+0x96>
    bigblock_t *bb, **last = &bigblocks;
ffffffffc0201e9c:	000d5697          	auipc	a3,0xd5
ffffffffc0201ea0:	f1c68693          	addi	a3,a3,-228 # ffffffffc02d6db8 <bigblocks>
ffffffffc0201ea4:	a021                	j	ffffffffc0201eac <kfree+0x36>
        for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201ea6:	01048693          	addi	a3,s1,16
ffffffffc0201eaa:	c3a5                	beqz	a5,ffffffffc0201f0a <kfree+0x94>
        {
            if (bb->pages == block)
ffffffffc0201eac:	6798                	ld	a4,8(a5)
ffffffffc0201eae:	84be                	mv	s1,a5
            {
                // 找到了！从链表中移除
                *last = bb->next;
ffffffffc0201eb0:	6b9c                	ld	a5,16(a5)
            if (bb->pages == block)
ffffffffc0201eb2:	fe871ae3          	bne	a4,s0,ffffffffc0201ea6 <kfree+0x30>
                *last = bb->next;
ffffffffc0201eb6:	e29c                	sd	a5,0(a3)
    if (flag)
ffffffffc0201eb8:	ee2d                	bnez	a2,ffffffffc0201f32 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201eba:	c02007b7          	lui	a5,0xc0200
                spin_unlock_irqrestore(&block_lock, flags);
                
                // 释放物理页
                __slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201ebe:	4098                	lw	a4,0(s1)
ffffffffc0201ec0:	08f46963          	bltu	s0,a5,ffffffffc0201f52 <kfree+0xdc>
ffffffffc0201ec4:	000d5697          	auipc	a3,0xd5
ffffffffc0201ec8:	f346b683          	ld	a3,-204(a3) # ffffffffc02d6df8 <va_pa_offset>
ffffffffc0201ecc:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc0201ece:	8031                	srli	s0,s0,0xc
ffffffffc0201ed0:	000d5797          	auipc	a5,0xd5
ffffffffc0201ed4:	f107b783          	ld	a5,-240(a5) # ffffffffc02d6de0 <npage>
ffffffffc0201ed8:	06f47163          	bgeu	s0,a5,ffffffffc0201f3a <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201edc:	00006517          	auipc	a0,0x6
ffffffffc0201ee0:	54c53503          	ld	a0,1356(a0) # ffffffffc0208428 <nbase>
ffffffffc0201ee4:	8c09                	sub	s0,s0,a0
ffffffffc0201ee6:	041a                	slli	s0,s0,0x6
    free_pages(kva2page((void *)kva), 1 << order);
ffffffffc0201ee8:	000d5517          	auipc	a0,0xd5
ffffffffc0201eec:	f0053503          	ld	a0,-256(a0) # ffffffffc02d6de8 <pages>
ffffffffc0201ef0:	4585                	li	a1,1
ffffffffc0201ef2:	9522                	add	a0,a0,s0
ffffffffc0201ef4:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201ef8:	0ea000ef          	jal	ra,ffffffffc0201fe2 <free_pages>
    // 2. 释放小内存块
    // 指针回退 sizeof(slob_t) 找到头部，调用 slob_free
    // 第二个参数为 0，表示让 slob_free 自己查看头部里的 units 字段确定大小
    slob_free((slob_t *)block - 1, 0);
    return;
}
ffffffffc0201efc:	6442                	ld	s0,16(sp)
ffffffffc0201efe:	60e2                	ld	ra,24(sp)
                slob_free(bb, sizeof(bigblock_t));
ffffffffc0201f00:	8526                	mv	a0,s1
}
ffffffffc0201f02:	64a2                	ld	s1,8(sp)
                slob_free(bb, sizeof(bigblock_t));
ffffffffc0201f04:	45e1                	li	a1,24
}
ffffffffc0201f06:	6105                	addi	sp,sp,32
    slob_free((slob_t *)block - 1, 0);
ffffffffc0201f08:	b9b5                	j	ffffffffc0201b84 <slob_free>
ffffffffc0201f0a:	e20d                	bnez	a2,ffffffffc0201f2c <kfree+0xb6>
ffffffffc0201f0c:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201f10:	6442                	ld	s0,16(sp)
ffffffffc0201f12:	60e2                	ld	ra,24(sp)
ffffffffc0201f14:	64a2                	ld	s1,8(sp)
    slob_free((slob_t *)block - 1, 0);
ffffffffc0201f16:	4581                	li	a1,0
}
ffffffffc0201f18:	6105                	addi	sp,sp,32
    slob_free((slob_t *)block - 1, 0);
ffffffffc0201f1a:	b1ad                	j	ffffffffc0201b84 <slob_free>
        intr_disable();
ffffffffc0201f1c:	a99fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201f20:	000d5797          	auipc	a5,0xd5
ffffffffc0201f24:	e987b783          	ld	a5,-360(a5) # ffffffffc02d6db8 <bigblocks>
        return 1;
ffffffffc0201f28:	4605                	li	a2,1
ffffffffc0201f2a:	fbad                	bnez	a5,ffffffffc0201e9c <kfree+0x26>
        intr_enable();
ffffffffc0201f2c:	a83fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201f30:	bff1                	j	ffffffffc0201f0c <kfree+0x96>
ffffffffc0201f32:	a7dfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201f36:	b751                	j	ffffffffc0201eba <kfree+0x44>
ffffffffc0201f38:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201f3a:	00005617          	auipc	a2,0x5
ffffffffc0201f3e:	b4660613          	addi	a2,a2,-1210 # ffffffffc0206a80 <default_pmm_manager+0x108>
ffffffffc0201f42:	0b200593          	li	a1,178
ffffffffc0201f46:	00005517          	auipc	a0,0x5
ffffffffc0201f4a:	a9250513          	addi	a0,a0,-1390 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0201f4e:	d40fe0ef          	jal	ra,ffffffffc020048e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201f52:	86a2                	mv	a3,s0
ffffffffc0201f54:	00005617          	auipc	a2,0x5
ffffffffc0201f58:	b0460613          	addi	a2,a2,-1276 # ffffffffc0206a58 <default_pmm_manager+0xe0>
ffffffffc0201f5c:	0c500593          	li	a1,197
ffffffffc0201f60:	00005517          	auipc	a0,0x5
ffffffffc0201f64:	a7850513          	addi	a0,a0,-1416 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0201f68:	d26fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201f6c <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201f6c:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201f6e:	00005617          	auipc	a2,0x5
ffffffffc0201f72:	b1260613          	addi	a2,a2,-1262 # ffffffffc0206a80 <default_pmm_manager+0x108>
ffffffffc0201f76:	0b200593          	li	a1,178
ffffffffc0201f7a:	00005517          	auipc	a0,0x5
ffffffffc0201f7e:	a5e50513          	addi	a0,a0,-1442 # ffffffffc02069d8 <default_pmm_manager+0x60>
pa2page(uintptr_t pa)
ffffffffc0201f82:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201f84:	d0afe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201f88 <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc0201f88:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201f8a:	00005617          	auipc	a2,0x5
ffffffffc0201f8e:	b1660613          	addi	a2,a2,-1258 # ffffffffc0206aa0 <default_pmm_manager+0x128>
ffffffffc0201f92:	0cf00593          	li	a1,207
ffffffffc0201f96:	00005517          	auipc	a0,0x5
ffffffffc0201f9a:	a4250513          	addi	a0,a0,-1470 # ffffffffc02069d8 <default_pmm_manager+0x60>
pte2page(pte_t pte)
ffffffffc0201f9e:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201fa0:	ceefe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201fa4 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201fa4:	100027f3          	csrr	a5,sstatus
ffffffffc0201fa8:	8b89                	andi	a5,a5,2
ffffffffc0201faa:	e799                	bnez	a5,ffffffffc0201fb8 <alloc_pages+0x14>
    // 保存当前中断状态并禁用中断，进入临界区
    // 防止在分配内存修改空闲链表时发生中断导致数据竞争
    local_intr_save(intr_flag);
    {
        // 调用具体管理器的分配函数分配 n 页
        page = pmm_manager->alloc_pages(n);
ffffffffc0201fac:	000d5797          	auipc	a5,0xd5
ffffffffc0201fb0:	e447b783          	ld	a5,-444(a5) # ffffffffc02d6df0 <pmm_manager>
ffffffffc0201fb4:	6f9c                	ld	a5,24(a5)
ffffffffc0201fb6:	8782                	jr	a5
{
ffffffffc0201fb8:	1141                	addi	sp,sp,-16
ffffffffc0201fba:	e406                	sd	ra,8(sp)
ffffffffc0201fbc:	e022                	sd	s0,0(sp)
ffffffffc0201fbe:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201fc0:	9f5fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201fc4:	000d5797          	auipc	a5,0xd5
ffffffffc0201fc8:	e2c7b783          	ld	a5,-468(a5) # ffffffffc02d6df0 <pmm_manager>
ffffffffc0201fcc:	6f9c                	ld	a5,24(a5)
ffffffffc0201fce:	8522                	mv	a0,s0
ffffffffc0201fd0:	9782                	jalr	a5
ffffffffc0201fd2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201fd4:	9dbfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
    // 恢复之前的中断状态，退出临界区
    local_intr_restore(intr_flag);
    
    // 返回分配到的第一个页面的 Page 结构体指针
    return page;
}
ffffffffc0201fd8:	60a2                	ld	ra,8(sp)
ffffffffc0201fda:	8522                	mv	a0,s0
ffffffffc0201fdc:	6402                	ld	s0,0(sp)
ffffffffc0201fde:	0141                	addi	sp,sp,16
ffffffffc0201fe0:	8082                	ret

ffffffffc0201fe2 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201fe2:	100027f3          	csrr	a5,sstatus
ffffffffc0201fe6:	8b89                	andi	a5,a5,2
ffffffffc0201fe8:	e799                	bnez	a5,ffffffffc0201ff6 <free_pages+0x14>
    
    // 保存中断状态并关中断，进入临界区
    local_intr_save(intr_flag);
    {
        // 调用具体管理器的释放函数
        pmm_manager->free_pages(base, n);
ffffffffc0201fea:	000d5797          	auipc	a5,0xd5
ffffffffc0201fee:	e067b783          	ld	a5,-506(a5) # ffffffffc02d6df0 <pmm_manager>
ffffffffc0201ff2:	739c                	ld	a5,32(a5)
ffffffffc0201ff4:	8782                	jr	a5
{
ffffffffc0201ff6:	1101                	addi	sp,sp,-32
ffffffffc0201ff8:	ec06                	sd	ra,24(sp)
ffffffffc0201ffa:	e822                	sd	s0,16(sp)
ffffffffc0201ffc:	e426                	sd	s1,8(sp)
ffffffffc0201ffe:	842a                	mv	s0,a0
ffffffffc0202000:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202002:	9b3fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202006:	000d5797          	auipc	a5,0xd5
ffffffffc020200a:	dea7b783          	ld	a5,-534(a5) # ffffffffc02d6df0 <pmm_manager>
ffffffffc020200e:	739c                	ld	a5,32(a5)
ffffffffc0202010:	85a6                	mv	a1,s1
ffffffffc0202012:	8522                	mv	a0,s0
ffffffffc0202014:	9782                	jalr	a5
    }
    // 恢复中断状态，退出临界区
    local_intr_restore(intr_flag);
}
ffffffffc0202016:	6442                	ld	s0,16(sp)
ffffffffc0202018:	60e2                	ld	ra,24(sp)
ffffffffc020201a:	64a2                	ld	s1,8(sp)
ffffffffc020201c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020201e:	991fe06f          	j	ffffffffc02009ae <intr_enable>

ffffffffc0202022 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202022:	100027f3          	csrr	a5,sstatus
ffffffffc0202026:	8b89                	andi	a5,a5,2
ffffffffc0202028:	e799                	bnez	a5,ffffffffc0202036 <nr_free_pages+0x14>
    
    // 关中断，防止在统计过程中链表发生变化
    local_intr_save(intr_flag);
    {
        // 调用管理器获取空闲页数
        ret = pmm_manager->nr_free_pages();
ffffffffc020202a:	000d5797          	auipc	a5,0xd5
ffffffffc020202e:	dc67b783          	ld	a5,-570(a5) # ffffffffc02d6df0 <pmm_manager>
ffffffffc0202032:	779c                	ld	a5,40(a5)
ffffffffc0202034:	8782                	jr	a5
{
ffffffffc0202036:	1141                	addi	sp,sp,-16
ffffffffc0202038:	e406                	sd	ra,8(sp)
ffffffffc020203a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020203c:	979fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202040:	000d5797          	auipc	a5,0xd5
ffffffffc0202044:	db07b783          	ld	a5,-592(a5) # ffffffffc02d6df0 <pmm_manager>
ffffffffc0202048:	779c                	ld	a5,40(a5)
ffffffffc020204a:	9782                	jalr	a5
ffffffffc020204c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020204e:	961fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
    // 开中断
    local_intr_restore(intr_flag);
    
    // 返回空闲页数
    return ret;
}
ffffffffc0202052:	60a2                	ld	ra,8(sp)
ffffffffc0202054:	8522                	mv	a0,s0
ffffffffc0202056:	6402                	ld	s0,0(sp)
ffffffffc0202058:	0141                	addi	sp,sp,16
ffffffffc020205a:	8082                	ret

ffffffffc020205c <get_pte>:
// create: 如果中间页表不存在，是否创建
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    // PDX1(la) 获取一级页表索引（Page Directory Index 1）
    // 获取一级页表项指针
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020205c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202060:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0202064:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202066:	078e                	slli	a5,a5,0x3
{
ffffffffc0202068:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020206a:	00f504b3          	add	s1,a0,a5
    
    // 检查一级页表项是否有效 (PTE_V)
    if (!(*pdep1 & PTE_V))
ffffffffc020206e:	6094                	ld	a3,0(s1)
{
ffffffffc0202070:	f04a                	sd	s2,32(sp)
ffffffffc0202072:	ec4e                	sd	s3,24(sp)
ffffffffc0202074:	e852                	sd	s4,16(sp)
ffffffffc0202076:	fc06                	sd	ra,56(sp)
ffffffffc0202078:	f822                	sd	s0,48(sp)
ffffffffc020207a:	e456                	sd	s5,8(sp)
ffffffffc020207c:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc020207e:	0016f793          	andi	a5,a3,1
{
ffffffffc0202082:	892e                	mv	s2,a1
ffffffffc0202084:	8a32                	mv	s4,a2
ffffffffc0202086:	000d5997          	auipc	s3,0xd5
ffffffffc020208a:	d5a98993          	addi	s3,s3,-678 # ffffffffc02d6de0 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc020208e:	efbd                	bnez	a5,ffffffffc020210c <get_pte+0xb0>
    {
        struct Page *page;
        // 如果不创建新页表，或者分配页面失败，返回 NULL
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202090:	14060c63          	beqz	a2,ffffffffc02021e8 <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202094:	100027f3          	csrr	a5,sstatus
ffffffffc0202098:	8b89                	andi	a5,a5,2
ffffffffc020209a:	14079963          	bnez	a5,ffffffffc02021ec <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc020209e:	000d5797          	auipc	a5,0xd5
ffffffffc02020a2:	d527b783          	ld	a5,-686(a5) # ffffffffc02d6df0 <pmm_manager>
ffffffffc02020a6:	6f9c                	ld	a5,24(a5)
ffffffffc02020a8:	4505                	li	a0,1
ffffffffc02020aa:	9782                	jalr	a5
ffffffffc02020ac:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02020ae:	12040d63          	beqz	s0,ffffffffc02021e8 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc02020b2:	000d5b17          	auipc	s6,0xd5
ffffffffc02020b6:	d36b0b13          	addi	s6,s6,-714 # ffffffffc02d6de8 <pages>
ffffffffc02020ba:	000b3503          	ld	a0,0(s6)
ffffffffc02020be:	00080ab7          	lui	s5,0x80
        // 设置页面引用计数为 1
        set_page_ref(page, 1);
        // 获取分配页面的物理地址
        uintptr_t pa = page2pa(page);
        // 将新分配的页表内存清零 (非常重要)
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020c2:	000d5997          	auipc	s3,0xd5
ffffffffc02020c6:	d1e98993          	addi	s3,s3,-738 # ffffffffc02d6de0 <npage>
ffffffffc02020ca:	40a40533          	sub	a0,s0,a0
ffffffffc02020ce:	8519                	srai	a0,a0,0x6
ffffffffc02020d0:	9556                	add	a0,a0,s5
ffffffffc02020d2:	0009b703          	ld	a4,0(s3)
ffffffffc02020d6:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02020da:	4685                	li	a3,1
ffffffffc02020dc:	c014                	sw	a3,0(s0)
ffffffffc02020de:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02020e0:	0532                	slli	a0,a0,0xc
ffffffffc02020e2:	16e7f763          	bgeu	a5,a4,ffffffffc0202250 <get_pte+0x1f4>
ffffffffc02020e6:	000d5797          	auipc	a5,0xd5
ffffffffc02020ea:	d127b783          	ld	a5,-750(a5) # ffffffffc02d6df8 <va_pa_offset>
ffffffffc02020ee:	6605                	lui	a2,0x1
ffffffffc02020f0:	4581                	li	a1,0
ffffffffc02020f2:	953e                	add	a0,a0,a5
ffffffffc02020f4:	1e5030ef          	jal	ra,ffffffffc0205ad8 <memset>
    return page - pages + nbase;
ffffffffc02020f8:	000b3683          	ld	a3,0(s6)
ffffffffc02020fc:	40d406b3          	sub	a3,s0,a3
ffffffffc0202100:	8699                	srai	a3,a3,0x6
ffffffffc0202102:	96d6                	add	a3,a3,s5
// construct PTE from a page and permission bits
// pte_create - 根据物理页帧号 (ppn) 和权限位 (type) 构建一个 PTE 值
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    // 将 PPN 移动到 PTE 的正确位置，并或上标志位 (PTE_V 表示有效，type 包含 R/W/X/U 等)
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202104:	06aa                	slli	a3,a3,0xa
ffffffffc0202106:	0116e693          	ori	a3,a3,17
        // 设置一级页表项：指向新分配的二级页表物理页号，设置用户位和有效位
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020210a:	e094                	sd	a3,0(s1)
    }

    // 根据一级页表项的内容，找到二级页表 (Page Directory/Table Level 0) 的内核虚拟地址
    // 并通过 PDX0(la) 获取二级页表索引
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020210c:	77fd                	lui	a5,0xfffff
ffffffffc020210e:	068a                	slli	a3,a3,0x2
ffffffffc0202110:	0009b703          	ld	a4,0(s3)
ffffffffc0202114:	8efd                	and	a3,a3,a5
ffffffffc0202116:	00c6d793          	srli	a5,a3,0xc
ffffffffc020211a:	10e7ff63          	bgeu	a5,a4,ffffffffc0202238 <get_pte+0x1dc>
ffffffffc020211e:	000d5a97          	auipc	s5,0xd5
ffffffffc0202122:	cdaa8a93          	addi	s5,s5,-806 # ffffffffc02d6df8 <va_pa_offset>
ffffffffc0202126:	000ab403          	ld	s0,0(s5)
ffffffffc020212a:	01595793          	srli	a5,s2,0x15
ffffffffc020212e:	1ff7f793          	andi	a5,a5,511
ffffffffc0202132:	96a2                	add	a3,a3,s0
ffffffffc0202134:	00379413          	slli	s0,a5,0x3
ffffffffc0202138:	9436                	add	s0,s0,a3
    
    // 检查二级页表项是否有效
    if (!(*pdep0 & PTE_V))
ffffffffc020213a:	6014                	ld	a3,0(s0)
ffffffffc020213c:	0016f793          	andi	a5,a3,1
ffffffffc0202140:	ebad                	bnez	a5,ffffffffc02021b2 <get_pte+0x156>
    {
        struct Page *page;
        // 如果不创建或分配失败，返回 NULL
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202142:	0a0a0363          	beqz	s4,ffffffffc02021e8 <get_pte+0x18c>
ffffffffc0202146:	100027f3          	csrr	a5,sstatus
ffffffffc020214a:	8b89                	andi	a5,a5,2
ffffffffc020214c:	efcd                	bnez	a5,ffffffffc0202206 <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc020214e:	000d5797          	auipc	a5,0xd5
ffffffffc0202152:	ca27b783          	ld	a5,-862(a5) # ffffffffc02d6df0 <pmm_manager>
ffffffffc0202156:	6f9c                	ld	a5,24(a5)
ffffffffc0202158:	4505                	li	a0,1
ffffffffc020215a:	9782                	jalr	a5
ffffffffc020215c:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc020215e:	c4c9                	beqz	s1,ffffffffc02021e8 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0202160:	000d5b17          	auipc	s6,0xd5
ffffffffc0202164:	c88b0b13          	addi	s6,s6,-888 # ffffffffc02d6de8 <pages>
ffffffffc0202168:	000b3503          	ld	a0,0(s6)
ffffffffc020216c:	00080a37          	lui	s4,0x80
        // 设置引用计数
        set_page_ref(page, 1);
        // 获取物理地址
        uintptr_t pa = page2pa(page);
        // 内存清零
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202170:	0009b703          	ld	a4,0(s3)
ffffffffc0202174:	40a48533          	sub	a0,s1,a0
ffffffffc0202178:	8519                	srai	a0,a0,0x6
ffffffffc020217a:	9552                	add	a0,a0,s4
ffffffffc020217c:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202180:	4685                	li	a3,1
ffffffffc0202182:	c094                	sw	a3,0(s1)
ffffffffc0202184:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202186:	0532                	slli	a0,a0,0xc
ffffffffc0202188:	0ee7f163          	bgeu	a5,a4,ffffffffc020226a <get_pte+0x20e>
ffffffffc020218c:	000ab783          	ld	a5,0(s5)
ffffffffc0202190:	6605                	lui	a2,0x1
ffffffffc0202192:	4581                	li	a1,0
ffffffffc0202194:	953e                	add	a0,a0,a5
ffffffffc0202196:	143030ef          	jal	ra,ffffffffc0205ad8 <memset>
    return page - pages + nbase;
ffffffffc020219a:	000b3683          	ld	a3,0(s6)
ffffffffc020219e:	40d486b3          	sub	a3,s1,a3
ffffffffc02021a2:	8699                	srai	a3,a3,0x6
ffffffffc02021a4:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02021a6:	06aa                	slli	a3,a3,0xa
ffffffffc02021a8:	0116e693          	ori	a3,a3,17
        // 设置二级页表项：指向新分配的三级页表（页表），设置权限
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02021ac:	e014                	sd	a3,0(s0)
    }
    
    // 根据二级页表项，找到三级页表 (Page Table) 的地址
    // 并通过 PTX(la) 获取页表项索引，返回该 PTE 的内核虚拟地址
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02021ae:	0009b703          	ld	a4,0(s3)
ffffffffc02021b2:	068a                	slli	a3,a3,0x2
ffffffffc02021b4:	757d                	lui	a0,0xfffff
ffffffffc02021b6:	8ee9                	and	a3,a3,a0
ffffffffc02021b8:	00c6d793          	srli	a5,a3,0xc
ffffffffc02021bc:	06e7f263          	bgeu	a5,a4,ffffffffc0202220 <get_pte+0x1c4>
ffffffffc02021c0:	000ab503          	ld	a0,0(s5)
ffffffffc02021c4:	00c95913          	srli	s2,s2,0xc
ffffffffc02021c8:	1ff97913          	andi	s2,s2,511
ffffffffc02021cc:	96aa                	add	a3,a3,a0
ffffffffc02021ce:	00391513          	slli	a0,s2,0x3
ffffffffc02021d2:	9536                	add	a0,a0,a3
}
ffffffffc02021d4:	70e2                	ld	ra,56(sp)
ffffffffc02021d6:	7442                	ld	s0,48(sp)
ffffffffc02021d8:	74a2                	ld	s1,40(sp)
ffffffffc02021da:	7902                	ld	s2,32(sp)
ffffffffc02021dc:	69e2                	ld	s3,24(sp)
ffffffffc02021de:	6a42                	ld	s4,16(sp)
ffffffffc02021e0:	6aa2                	ld	s5,8(sp)
ffffffffc02021e2:	6b02                	ld	s6,0(sp)
ffffffffc02021e4:	6121                	addi	sp,sp,64
ffffffffc02021e6:	8082                	ret
            return NULL;
ffffffffc02021e8:	4501                	li	a0,0
ffffffffc02021ea:	b7ed                	j	ffffffffc02021d4 <get_pte+0x178>
        intr_disable();
ffffffffc02021ec:	fc8fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02021f0:	000d5797          	auipc	a5,0xd5
ffffffffc02021f4:	c007b783          	ld	a5,-1024(a5) # ffffffffc02d6df0 <pmm_manager>
ffffffffc02021f8:	6f9c                	ld	a5,24(a5)
ffffffffc02021fa:	4505                	li	a0,1
ffffffffc02021fc:	9782                	jalr	a5
ffffffffc02021fe:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202200:	faefe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202204:	b56d                	j	ffffffffc02020ae <get_pte+0x52>
        intr_disable();
ffffffffc0202206:	faefe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc020220a:	000d5797          	auipc	a5,0xd5
ffffffffc020220e:	be67b783          	ld	a5,-1050(a5) # ffffffffc02d6df0 <pmm_manager>
ffffffffc0202212:	6f9c                	ld	a5,24(a5)
ffffffffc0202214:	4505                	li	a0,1
ffffffffc0202216:	9782                	jalr	a5
ffffffffc0202218:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc020221a:	f94fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020221e:	b781                	j	ffffffffc020215e <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202220:	00004617          	auipc	a2,0x4
ffffffffc0202224:	79060613          	addi	a2,a2,1936 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0202228:	15b00593          	li	a1,347
ffffffffc020222c:	00005517          	auipc	a0,0x5
ffffffffc0202230:	89c50513          	addi	a0,a0,-1892 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202234:	a5afe0ef          	jal	ra,ffffffffc020048e <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202238:	00004617          	auipc	a2,0x4
ffffffffc020223c:	77860613          	addi	a2,a2,1912 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0202240:	14400593          	li	a1,324
ffffffffc0202244:	00005517          	auipc	a0,0x5
ffffffffc0202248:	88450513          	addi	a0,a0,-1916 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020224c:	a42fe0ef          	jal	ra,ffffffffc020048e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202250:	86aa                	mv	a3,a0
ffffffffc0202252:	00004617          	auipc	a2,0x4
ffffffffc0202256:	75e60613          	addi	a2,a2,1886 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc020225a:	13d00593          	li	a1,317
ffffffffc020225e:	00005517          	auipc	a0,0x5
ffffffffc0202262:	86a50513          	addi	a0,a0,-1942 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202266:	a28fe0ef          	jal	ra,ffffffffc020048e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020226a:	86aa                	mv	a3,a0
ffffffffc020226c:	00004617          	auipc	a2,0x4
ffffffffc0202270:	74460613          	addi	a2,a2,1860 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0202274:	15400593          	li	a1,340
ffffffffc0202278:	00005517          	auipc	a0,0x5
ffffffffc020227c:	85050513          	addi	a0,a0,-1968 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202280:	a0efe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0202284 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
// 根据虚拟地址 la 获取对应的物理页结构体 Page
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0202284:	1141                	addi	sp,sp,-16
ffffffffc0202286:	e022                	sd	s0,0(sp)
ffffffffc0202288:	8432                	mv	s0,a2
    // 查找 PTE，不创建新页表 (第三个参数为 0)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020228a:	4601                	li	a2,0
{
ffffffffc020228c:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020228e:	dcfff0ef          	jal	ra,ffffffffc020205c <get_pte>
    
    // 如果调用者提供了存储 ptep 的指针，则保存找到的 PTE 地址
    if (ptep_store != NULL)
ffffffffc0202292:	c011                	beqz	s0,ffffffffc0202296 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0202294:	e008                	sd	a0,0(s0)
    }
    
    // 如果 PTE 存在且有效
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202296:	c511                	beqz	a0,ffffffffc02022a2 <get_page+0x1e>
ffffffffc0202298:	611c                	ld	a5,0(a0)
    {
        // 将 PTE 转换为对应的 Page 结构体指针并返回
        return pte2page(*ptep);
    }
    // 否则返回 NULL
    return NULL;
ffffffffc020229a:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020229c:	0017f713          	andi	a4,a5,1
ffffffffc02022a0:	e709                	bnez	a4,ffffffffc02022aa <get_page+0x26>
}
ffffffffc02022a2:	60a2                	ld	ra,8(sp)
ffffffffc02022a4:	6402                	ld	s0,0(sp)
ffffffffc02022a6:	0141                	addi	sp,sp,16
ffffffffc02022a8:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02022aa:	078a                	slli	a5,a5,0x2
ffffffffc02022ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02022ae:	000d5717          	auipc	a4,0xd5
ffffffffc02022b2:	b3273703          	ld	a4,-1230(a4) # ffffffffc02d6de0 <npage>
ffffffffc02022b6:	00e7ff63          	bgeu	a5,a4,ffffffffc02022d4 <get_page+0x50>
ffffffffc02022ba:	60a2                	ld	ra,8(sp)
ffffffffc02022bc:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc02022be:	fff80537          	lui	a0,0xfff80
ffffffffc02022c2:	97aa                	add	a5,a5,a0
ffffffffc02022c4:	079a                	slli	a5,a5,0x6
ffffffffc02022c6:	000d5517          	auipc	a0,0xd5
ffffffffc02022ca:	b2253503          	ld	a0,-1246(a0) # ffffffffc02d6de8 <pages>
ffffffffc02022ce:	953e                	add	a0,a0,a5
ffffffffc02022d0:	0141                	addi	sp,sp,16
ffffffffc02022d2:	8082                	ret
ffffffffc02022d4:	c99ff0ef          	jal	ra,ffffffffc0201f6c <pa2page.part.0>

ffffffffc02022d8 <unmap_range>:
    }
}

// unmap_range - 取消 [start, end) 范围内的所有映射
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc02022d8:	7159                	addi	sp,sp,-112
    // 断言地址按页对齐
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022da:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc02022de:	f486                	sd	ra,104(sp)
ffffffffc02022e0:	f0a2                	sd	s0,96(sp)
ffffffffc02022e2:	eca6                	sd	s1,88(sp)
ffffffffc02022e4:	e8ca                	sd	s2,80(sp)
ffffffffc02022e6:	e4ce                	sd	s3,72(sp)
ffffffffc02022e8:	e0d2                	sd	s4,64(sp)
ffffffffc02022ea:	fc56                	sd	s5,56(sp)
ffffffffc02022ec:	f85a                	sd	s6,48(sp)
ffffffffc02022ee:	f45e                	sd	s7,40(sp)
ffffffffc02022f0:	f062                	sd	s8,32(sp)
ffffffffc02022f2:	ec66                	sd	s9,24(sp)
ffffffffc02022f4:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022f6:	17d2                	slli	a5,a5,0x34
ffffffffc02022f8:	e3ed                	bnez	a5,ffffffffc02023da <unmap_range+0x102>
    // 断言在用户空间范围内
    assert(USER_ACCESS(start, end));
ffffffffc02022fa:	002007b7          	lui	a5,0x200
ffffffffc02022fe:	842e                	mv	s0,a1
ffffffffc0202300:	0ef5ed63          	bltu	a1,a5,ffffffffc02023fa <unmap_range+0x122>
ffffffffc0202304:	8932                	mv	s2,a2
ffffffffc0202306:	0ec5fa63          	bgeu	a1,a2,ffffffffc02023fa <unmap_range+0x122>
ffffffffc020230a:	4785                	li	a5,1
ffffffffc020230c:	07fe                	slli	a5,a5,0x1f
ffffffffc020230e:	0ec7e663          	bltu	a5,a2,ffffffffc02023fa <unmap_range+0x122>
ffffffffc0202312:	89aa                	mv	s3,a0
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        // 移动到下一页
        start += PGSIZE;
ffffffffc0202314:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc0202316:	000d5c97          	auipc	s9,0xd5
ffffffffc020231a:	acac8c93          	addi	s9,s9,-1334 # ffffffffc02d6de0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020231e:	000d5c17          	auipc	s8,0xd5
ffffffffc0202322:	acac0c13          	addi	s8,s8,-1334 # ffffffffc02d6de8 <pages>
ffffffffc0202326:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc020232a:	000d5d17          	auipc	s10,0xd5
ffffffffc020232e:	ac6d0d13          	addi	s10,s10,-1338 # ffffffffc02d6df0 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202332:	00200b37          	lui	s6,0x200
ffffffffc0202336:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc020233a:	4601                	li	a2,0
ffffffffc020233c:	85a2                	mv	a1,s0
ffffffffc020233e:	854e                	mv	a0,s3
ffffffffc0202340:	d1dff0ef          	jal	ra,ffffffffc020205c <get_pte>
ffffffffc0202344:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0202346:	cd29                	beqz	a0,ffffffffc02023a0 <unmap_range+0xc8>
        if (*ptep != 0)
ffffffffc0202348:	611c                	ld	a5,0(a0)
ffffffffc020234a:	e395                	bnez	a5,ffffffffc020236e <unmap_range+0x96>
        start += PGSIZE;
ffffffffc020234c:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020234e:	ff2466e3          	bltu	s0,s2,ffffffffc020233a <unmap_range+0x62>
}
ffffffffc0202352:	70a6                	ld	ra,104(sp)
ffffffffc0202354:	7406                	ld	s0,96(sp)
ffffffffc0202356:	64e6                	ld	s1,88(sp)
ffffffffc0202358:	6946                	ld	s2,80(sp)
ffffffffc020235a:	69a6                	ld	s3,72(sp)
ffffffffc020235c:	6a06                	ld	s4,64(sp)
ffffffffc020235e:	7ae2                	ld	s5,56(sp)
ffffffffc0202360:	7b42                	ld	s6,48(sp)
ffffffffc0202362:	7ba2                	ld	s7,40(sp)
ffffffffc0202364:	7c02                	ld	s8,32(sp)
ffffffffc0202366:	6ce2                	ld	s9,24(sp)
ffffffffc0202368:	6d42                	ld	s10,16(sp)
ffffffffc020236a:	6165                	addi	sp,sp,112
ffffffffc020236c:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc020236e:	0017f713          	andi	a4,a5,1
ffffffffc0202372:	df69                	beqz	a4,ffffffffc020234c <unmap_range+0x74>
    if (PPN(pa) >= npage)
ffffffffc0202374:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202378:	078a                	slli	a5,a5,0x2
ffffffffc020237a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020237c:	08e7ff63          	bgeu	a5,a4,ffffffffc020241a <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0202380:	000c3503          	ld	a0,0(s8)
ffffffffc0202384:	97de                	add	a5,a5,s7
ffffffffc0202386:	079a                	slli	a5,a5,0x6
ffffffffc0202388:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020238a:	411c                	lw	a5,0(a0)
ffffffffc020238c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202390:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc0202392:	cf11                	beqz	a4,ffffffffc02023ae <unmap_range+0xd6>
        *ptep = 0;
ffffffffc0202394:	0004b023          	sd	zero,0(s1)
// invalidate a TLB entry
// 刷新 TLB 条目
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    // 使用 RISC-V 汇编指令 sfence.vma 刷新与地址 la 相关的 TLB
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202398:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020239c:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020239e:	bf45                	j	ffffffffc020234e <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02023a0:	945a                	add	s0,s0,s6
ffffffffc02023a2:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02023a6:	d455                	beqz	s0,ffffffffc0202352 <unmap_range+0x7a>
ffffffffc02023a8:	f92469e3          	bltu	s0,s2,ffffffffc020233a <unmap_range+0x62>
ffffffffc02023ac:	b75d                	j	ffffffffc0202352 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02023ae:	100027f3          	csrr	a5,sstatus
ffffffffc02023b2:	8b89                	andi	a5,a5,2
ffffffffc02023b4:	e799                	bnez	a5,ffffffffc02023c2 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc02023b6:	000d3783          	ld	a5,0(s10)
ffffffffc02023ba:	4585                	li	a1,1
ffffffffc02023bc:	739c                	ld	a5,32(a5)
ffffffffc02023be:	9782                	jalr	a5
    if (flag)
ffffffffc02023c0:	bfd1                	j	ffffffffc0202394 <unmap_range+0xbc>
ffffffffc02023c2:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02023c4:	df0fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02023c8:	000d3783          	ld	a5,0(s10)
ffffffffc02023cc:	6522                	ld	a0,8(sp)
ffffffffc02023ce:	4585                	li	a1,1
ffffffffc02023d0:	739c                	ld	a5,32(a5)
ffffffffc02023d2:	9782                	jalr	a5
        intr_enable();
ffffffffc02023d4:	ddafe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02023d8:	bf75                	j	ffffffffc0202394 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02023da:	00004697          	auipc	a3,0x4
ffffffffc02023de:	6fe68693          	addi	a3,a3,1790 # ffffffffc0206ad8 <default_pmm_manager+0x160>
ffffffffc02023e2:	00004617          	auipc	a2,0x4
ffffffffc02023e6:	1e660613          	addi	a2,a2,486 # ffffffffc02065c8 <commands+0x858>
ffffffffc02023ea:	19100593          	li	a1,401
ffffffffc02023ee:	00004517          	auipc	a0,0x4
ffffffffc02023f2:	6da50513          	addi	a0,a0,1754 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02023f6:	898fe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02023fa:	00004697          	auipc	a3,0x4
ffffffffc02023fe:	70e68693          	addi	a3,a3,1806 # ffffffffc0206b08 <default_pmm_manager+0x190>
ffffffffc0202402:	00004617          	auipc	a2,0x4
ffffffffc0202406:	1c660613          	addi	a2,a2,454 # ffffffffc02065c8 <commands+0x858>
ffffffffc020240a:	19300593          	li	a1,403
ffffffffc020240e:	00004517          	auipc	a0,0x4
ffffffffc0202412:	6ba50513          	addi	a0,a0,1722 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202416:	878fe0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc020241a:	b53ff0ef          	jal	ra,ffffffffc0201f6c <pa2page.part.0>

ffffffffc020241e <exit_range>:
{
ffffffffc020241e:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202420:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202424:	fc86                	sd	ra,120(sp)
ffffffffc0202426:	f8a2                	sd	s0,112(sp)
ffffffffc0202428:	f4a6                	sd	s1,104(sp)
ffffffffc020242a:	f0ca                	sd	s2,96(sp)
ffffffffc020242c:	ecce                	sd	s3,88(sp)
ffffffffc020242e:	e8d2                	sd	s4,80(sp)
ffffffffc0202430:	e4d6                	sd	s5,72(sp)
ffffffffc0202432:	e0da                	sd	s6,64(sp)
ffffffffc0202434:	fc5e                	sd	s7,56(sp)
ffffffffc0202436:	f862                	sd	s8,48(sp)
ffffffffc0202438:	f466                	sd	s9,40(sp)
ffffffffc020243a:	f06a                	sd	s10,32(sp)
ffffffffc020243c:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020243e:	17d2                	slli	a5,a5,0x34
ffffffffc0202440:	20079a63          	bnez	a5,ffffffffc0202654 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc0202444:	002007b7          	lui	a5,0x200
ffffffffc0202448:	24f5e463          	bltu	a1,a5,ffffffffc0202690 <exit_range+0x272>
ffffffffc020244c:	8ab2                	mv	s5,a2
ffffffffc020244e:	24c5f163          	bgeu	a1,a2,ffffffffc0202690 <exit_range+0x272>
ffffffffc0202452:	4785                	li	a5,1
ffffffffc0202454:	07fe                	slli	a5,a5,0x1f
ffffffffc0202456:	22c7ed63          	bltu	a5,a2,ffffffffc0202690 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020245a:	c00009b7          	lui	s3,0xc0000
ffffffffc020245e:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202462:	ffe00937          	lui	s2,0xffe00
ffffffffc0202466:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc020246a:	5cfd                	li	s9,-1
ffffffffc020246c:	8c2a                	mv	s8,a0
ffffffffc020246e:	0125f933          	and	s2,a1,s2
ffffffffc0202472:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage)
ffffffffc0202474:	000d5d17          	auipc	s10,0xd5
ffffffffc0202478:	96cd0d13          	addi	s10,s10,-1684 # ffffffffc02d6de0 <npage>
    return KADDR(page2pa(page));
ffffffffc020247c:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202480:	000d5717          	auipc	a4,0xd5
ffffffffc0202484:	96870713          	addi	a4,a4,-1688 # ffffffffc02d6de8 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc0202488:	000d5d97          	auipc	s11,0xd5
ffffffffc020248c:	968d8d93          	addi	s11,s11,-1688 # ffffffffc02d6df0 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202490:	c0000437          	lui	s0,0xc0000
ffffffffc0202494:	944e                	add	s0,s0,s3
ffffffffc0202496:	8079                	srli	s0,s0,0x1e
ffffffffc0202498:	1ff47413          	andi	s0,s0,511
ffffffffc020249c:	040e                	slli	s0,s0,0x3
ffffffffc020249e:	9462                	add	s0,s0,s8
ffffffffc02024a0:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4d30>
        if (pde1 & PTE_V)
ffffffffc02024a4:	001a7793          	andi	a5,s4,1
ffffffffc02024a8:	eb99                	bnez	a5,ffffffffc02024be <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc02024aa:	12098463          	beqz	s3,ffffffffc02025d2 <exit_range+0x1b4>
ffffffffc02024ae:	400007b7          	lui	a5,0x40000
ffffffffc02024b2:	97ce                	add	a5,a5,s3
ffffffffc02024b4:	894e                	mv	s2,s3
ffffffffc02024b6:	1159fe63          	bgeu	s3,s5,ffffffffc02025d2 <exit_range+0x1b4>
ffffffffc02024ba:	89be                	mv	s3,a5
ffffffffc02024bc:	bfd1                	j	ffffffffc0202490 <exit_range+0x72>
    if (PPN(pa) >= npage)
ffffffffc02024be:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024c2:	0a0a                	slli	s4,s4,0x2
ffffffffc02024c4:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage)
ffffffffc02024c8:	1cfa7263          	bgeu	s4,a5,ffffffffc020268c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02024cc:	fff80637          	lui	a2,0xfff80
ffffffffc02024d0:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc02024d2:	000806b7          	lui	a3,0x80
ffffffffc02024d6:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02024d8:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02024dc:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02024de:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02024e0:	18f5fa63          	bgeu	a1,a5,ffffffffc0202674 <exit_range+0x256>
ffffffffc02024e4:	000d5817          	auipc	a6,0xd5
ffffffffc02024e8:	91480813          	addi	a6,a6,-1772 # ffffffffc02d6df8 <va_pa_offset>
ffffffffc02024ec:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc02024f0:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc02024f2:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc02024f6:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc02024f8:	00080337          	lui	t1,0x80
ffffffffc02024fc:	6885                	lui	a7,0x1
ffffffffc02024fe:	a819                	j	ffffffffc0202514 <exit_range+0xf6>
                    free_pd0 = 0; 
ffffffffc0202500:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0202502:	002007b7          	lui	a5,0x200
ffffffffc0202506:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202508:	08090c63          	beqz	s2,ffffffffc02025a0 <exit_range+0x182>
ffffffffc020250c:	09397a63          	bgeu	s2,s3,ffffffffc02025a0 <exit_range+0x182>
ffffffffc0202510:	0f597063          	bgeu	s2,s5,ffffffffc02025f0 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202514:	01595493          	srli	s1,s2,0x15
ffffffffc0202518:	1ff4f493          	andi	s1,s1,511
ffffffffc020251c:	048e                	slli	s1,s1,0x3
ffffffffc020251e:	94da                	add	s1,s1,s6
ffffffffc0202520:	609c                	ld	a5,0(s1)
                if (pde0 & PTE_V)
ffffffffc0202522:	0017f693          	andi	a3,a5,1
ffffffffc0202526:	dee9                	beqz	a3,ffffffffc0202500 <exit_range+0xe2>
    if (PPN(pa) >= npage)
ffffffffc0202528:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020252c:	078a                	slli	a5,a5,0x2
ffffffffc020252e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202530:	14b7fe63          	bgeu	a5,a1,ffffffffc020268c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202534:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0202536:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc020253a:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc020253e:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202542:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202544:	12bef863          	bgeu	t4,a1,ffffffffc0202674 <exit_range+0x256>
ffffffffc0202548:	00083783          	ld	a5,0(a6)
ffffffffc020254c:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc020254e:	011685b3          	add	a1,a3,a7
                        if (pt[i] & PTE_V)
ffffffffc0202552:	629c                	ld	a5,0(a3)
ffffffffc0202554:	8b85                	andi	a5,a5,1
ffffffffc0202556:	f7d5                	bnez	a5,ffffffffc0202502 <exit_range+0xe4>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202558:	06a1                	addi	a3,a3,8
ffffffffc020255a:	fed59ce3          	bne	a1,a3,ffffffffc0202552 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc020255e:	631c                	ld	a5,0(a4)
ffffffffc0202560:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202562:	100027f3          	csrr	a5,sstatus
ffffffffc0202566:	8b89                	andi	a5,a5,2
ffffffffc0202568:	e7d9                	bnez	a5,ffffffffc02025f6 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc020256a:	000db783          	ld	a5,0(s11)
ffffffffc020256e:	4585                	li	a1,1
ffffffffc0202570:	e032                	sd	a2,0(sp)
ffffffffc0202572:	739c                	ld	a5,32(a5)
ffffffffc0202574:	9782                	jalr	a5
    if (flag)
ffffffffc0202576:	6602                	ld	a2,0(sp)
ffffffffc0202578:	000d5817          	auipc	a6,0xd5
ffffffffc020257c:	88080813          	addi	a6,a6,-1920 # ffffffffc02d6df8 <va_pa_offset>
ffffffffc0202580:	fff80e37          	lui	t3,0xfff80
ffffffffc0202584:	00080337          	lui	t1,0x80
ffffffffc0202588:	6885                	lui	a7,0x1
ffffffffc020258a:	000d5717          	auipc	a4,0xd5
ffffffffc020258e:	85e70713          	addi	a4,a4,-1954 # ffffffffc02d6de8 <pages>
                        pd0[PDX0(d0start)] = 0; // 清空父级条目
ffffffffc0202592:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0202596:	002007b7          	lui	a5,0x200
ffffffffc020259a:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc020259c:	f60918e3          	bnez	s2,ffffffffc020250c <exit_range+0xee>
            if (free_pd0)
ffffffffc02025a0:	f00b85e3          	beqz	s7,ffffffffc02024aa <exit_range+0x8c>
    if (PPN(pa) >= npage)
ffffffffc02025a4:	000d3783          	ld	a5,0(s10)
ffffffffc02025a8:	0efa7263          	bgeu	s4,a5,ffffffffc020268c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02025ac:	6308                	ld	a0,0(a4)
ffffffffc02025ae:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02025b0:	100027f3          	csrr	a5,sstatus
ffffffffc02025b4:	8b89                	andi	a5,a5,2
ffffffffc02025b6:	efad                	bnez	a5,ffffffffc0202630 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc02025b8:	000db783          	ld	a5,0(s11)
ffffffffc02025bc:	4585                	li	a1,1
ffffffffc02025be:	739c                	ld	a5,32(a5)
ffffffffc02025c0:	9782                	jalr	a5
ffffffffc02025c2:	000d5717          	auipc	a4,0xd5
ffffffffc02025c6:	82670713          	addi	a4,a4,-2010 # ffffffffc02d6de8 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02025ca:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc02025ce:	ee0990e3          	bnez	s3,ffffffffc02024ae <exit_range+0x90>
}
ffffffffc02025d2:	70e6                	ld	ra,120(sp)
ffffffffc02025d4:	7446                	ld	s0,112(sp)
ffffffffc02025d6:	74a6                	ld	s1,104(sp)
ffffffffc02025d8:	7906                	ld	s2,96(sp)
ffffffffc02025da:	69e6                	ld	s3,88(sp)
ffffffffc02025dc:	6a46                	ld	s4,80(sp)
ffffffffc02025de:	6aa6                	ld	s5,72(sp)
ffffffffc02025e0:	6b06                	ld	s6,64(sp)
ffffffffc02025e2:	7be2                	ld	s7,56(sp)
ffffffffc02025e4:	7c42                	ld	s8,48(sp)
ffffffffc02025e6:	7ca2                	ld	s9,40(sp)
ffffffffc02025e8:	7d02                	ld	s10,32(sp)
ffffffffc02025ea:	6de2                	ld	s11,24(sp)
ffffffffc02025ec:	6109                	addi	sp,sp,128
ffffffffc02025ee:	8082                	ret
            if (free_pd0)
ffffffffc02025f0:	ea0b8fe3          	beqz	s7,ffffffffc02024ae <exit_range+0x90>
ffffffffc02025f4:	bf45                	j	ffffffffc02025a4 <exit_range+0x186>
ffffffffc02025f6:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc02025f8:	e42a                	sd	a0,8(sp)
ffffffffc02025fa:	bbafe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02025fe:	000db783          	ld	a5,0(s11)
ffffffffc0202602:	6522                	ld	a0,8(sp)
ffffffffc0202604:	4585                	li	a1,1
ffffffffc0202606:	739c                	ld	a5,32(a5)
ffffffffc0202608:	9782                	jalr	a5
        intr_enable();
ffffffffc020260a:	ba4fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020260e:	6602                	ld	a2,0(sp)
ffffffffc0202610:	000d4717          	auipc	a4,0xd4
ffffffffc0202614:	7d870713          	addi	a4,a4,2008 # ffffffffc02d6de8 <pages>
ffffffffc0202618:	6885                	lui	a7,0x1
ffffffffc020261a:	00080337          	lui	t1,0x80
ffffffffc020261e:	fff80e37          	lui	t3,0xfff80
ffffffffc0202622:	000d4817          	auipc	a6,0xd4
ffffffffc0202626:	7d680813          	addi	a6,a6,2006 # ffffffffc02d6df8 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0; // 清空父级条目
ffffffffc020262a:	0004b023          	sd	zero,0(s1)
ffffffffc020262e:	b7a5                	j	ffffffffc0202596 <exit_range+0x178>
ffffffffc0202630:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202632:	b82fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202636:	000db783          	ld	a5,0(s11)
ffffffffc020263a:	6502                	ld	a0,0(sp)
ffffffffc020263c:	4585                	li	a1,1
ffffffffc020263e:	739c                	ld	a5,32(a5)
ffffffffc0202640:	9782                	jalr	a5
        intr_enable();
ffffffffc0202642:	b6cfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202646:	000d4717          	auipc	a4,0xd4
ffffffffc020264a:	7a270713          	addi	a4,a4,1954 # ffffffffc02d6de8 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020264e:	00043023          	sd	zero,0(s0)
ffffffffc0202652:	bfb5                	j	ffffffffc02025ce <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202654:	00004697          	auipc	a3,0x4
ffffffffc0202658:	48468693          	addi	a3,a3,1156 # ffffffffc0206ad8 <default_pmm_manager+0x160>
ffffffffc020265c:	00004617          	auipc	a2,0x4
ffffffffc0202660:	f6c60613          	addi	a2,a2,-148 # ffffffffc02065c8 <commands+0x858>
ffffffffc0202664:	1ae00593          	li	a1,430
ffffffffc0202668:	00004517          	auipc	a0,0x4
ffffffffc020266c:	46050513          	addi	a0,a0,1120 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202670:	e1ffd0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202674:	00004617          	auipc	a2,0x4
ffffffffc0202678:	33c60613          	addi	a2,a2,828 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc020267c:	0bd00593          	li	a1,189
ffffffffc0202680:	00004517          	auipc	a0,0x4
ffffffffc0202684:	35850513          	addi	a0,a0,856 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0202688:	e07fd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc020268c:	8e1ff0ef          	jal	ra,ffffffffc0201f6c <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0202690:	00004697          	auipc	a3,0x4
ffffffffc0202694:	47868693          	addi	a3,a3,1144 # ffffffffc0206b08 <default_pmm_manager+0x190>
ffffffffc0202698:	00004617          	auipc	a2,0x4
ffffffffc020269c:	f3060613          	addi	a2,a2,-208 # ffffffffc02065c8 <commands+0x858>
ffffffffc02026a0:	1af00593          	li	a1,431
ffffffffc02026a4:	00004517          	auipc	a0,0x4
ffffffffc02026a8:	42450513          	addi	a0,a0,1060 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02026ac:	de3fd0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02026b0 <page_remove>:
{
ffffffffc02026b0:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02026b2:	4601                	li	a2,0
{
ffffffffc02026b4:	ec26                	sd	s1,24(sp)
ffffffffc02026b6:	f406                	sd	ra,40(sp)
ffffffffc02026b8:	f022                	sd	s0,32(sp)
ffffffffc02026ba:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02026bc:	9a1ff0ef          	jal	ra,ffffffffc020205c <get_pte>
    if (ptep != NULL)
ffffffffc02026c0:	c511                	beqz	a0,ffffffffc02026cc <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc02026c2:	611c                	ld	a5,0(a0)
ffffffffc02026c4:	842a                	mv	s0,a0
ffffffffc02026c6:	0017f713          	andi	a4,a5,1
ffffffffc02026ca:	e711                	bnez	a4,ffffffffc02026d6 <page_remove+0x26>
}
ffffffffc02026cc:	70a2                	ld	ra,40(sp)
ffffffffc02026ce:	7402                	ld	s0,32(sp)
ffffffffc02026d0:	64e2                	ld	s1,24(sp)
ffffffffc02026d2:	6145                	addi	sp,sp,48
ffffffffc02026d4:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02026d6:	078a                	slli	a5,a5,0x2
ffffffffc02026d8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02026da:	000d4717          	auipc	a4,0xd4
ffffffffc02026de:	70673703          	ld	a4,1798(a4) # ffffffffc02d6de0 <npage>
ffffffffc02026e2:	06e7f363          	bgeu	a5,a4,ffffffffc0202748 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02026e6:	fff80537          	lui	a0,0xfff80
ffffffffc02026ea:	97aa                	add	a5,a5,a0
ffffffffc02026ec:	079a                	slli	a5,a5,0x6
ffffffffc02026ee:	000d4517          	auipc	a0,0xd4
ffffffffc02026f2:	6fa53503          	ld	a0,1786(a0) # ffffffffc02d6de8 <pages>
ffffffffc02026f6:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02026f8:	411c                	lw	a5,0(a0)
ffffffffc02026fa:	fff7871b          	addiw	a4,a5,-1
ffffffffc02026fe:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc0202700:	cb11                	beqz	a4,ffffffffc0202714 <page_remove+0x64>
        *ptep = 0;
ffffffffc0202702:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202706:	12048073          	sfence.vma	s1
}
ffffffffc020270a:	70a2                	ld	ra,40(sp)
ffffffffc020270c:	7402                	ld	s0,32(sp)
ffffffffc020270e:	64e2                	ld	s1,24(sp)
ffffffffc0202710:	6145                	addi	sp,sp,48
ffffffffc0202712:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202714:	100027f3          	csrr	a5,sstatus
ffffffffc0202718:	8b89                	andi	a5,a5,2
ffffffffc020271a:	eb89                	bnez	a5,ffffffffc020272c <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc020271c:	000d4797          	auipc	a5,0xd4
ffffffffc0202720:	6d47b783          	ld	a5,1748(a5) # ffffffffc02d6df0 <pmm_manager>
ffffffffc0202724:	739c                	ld	a5,32(a5)
ffffffffc0202726:	4585                	li	a1,1
ffffffffc0202728:	9782                	jalr	a5
    if (flag)
ffffffffc020272a:	bfe1                	j	ffffffffc0202702 <page_remove+0x52>
        intr_disable();
ffffffffc020272c:	e42a                	sd	a0,8(sp)
ffffffffc020272e:	a86fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202732:	000d4797          	auipc	a5,0xd4
ffffffffc0202736:	6be7b783          	ld	a5,1726(a5) # ffffffffc02d6df0 <pmm_manager>
ffffffffc020273a:	739c                	ld	a5,32(a5)
ffffffffc020273c:	6522                	ld	a0,8(sp)
ffffffffc020273e:	4585                	li	a1,1
ffffffffc0202740:	9782                	jalr	a5
        intr_enable();
ffffffffc0202742:	a6cfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202746:	bf75                	j	ffffffffc0202702 <page_remove+0x52>
ffffffffc0202748:	825ff0ef          	jal	ra,ffffffffc0201f6c <pa2page.part.0>

ffffffffc020274c <page_insert>:
{
ffffffffc020274c:	7139                	addi	sp,sp,-64
ffffffffc020274e:	e852                	sd	s4,16(sp)
ffffffffc0202750:	8a32                	mv	s4,a2
ffffffffc0202752:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202754:	4605                	li	a2,1
{
ffffffffc0202756:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202758:	85d2                	mv	a1,s4
{
ffffffffc020275a:	f426                	sd	s1,40(sp)
ffffffffc020275c:	fc06                	sd	ra,56(sp)
ffffffffc020275e:	f04a                	sd	s2,32(sp)
ffffffffc0202760:	ec4e                	sd	s3,24(sp)
ffffffffc0202762:	e456                	sd	s5,8(sp)
ffffffffc0202764:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202766:	8f7ff0ef          	jal	ra,ffffffffc020205c <get_pte>
    if (ptep == NULL)
ffffffffc020276a:	c961                	beqz	a0,ffffffffc020283a <page_insert+0xee>
    page->ref += 1;
ffffffffc020276c:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc020276e:	611c                	ld	a5,0(a0)
ffffffffc0202770:	89aa                	mv	s3,a0
ffffffffc0202772:	0016871b          	addiw	a4,a3,1
ffffffffc0202776:	c018                	sw	a4,0(s0)
ffffffffc0202778:	0017f713          	andi	a4,a5,1
ffffffffc020277c:	ef05                	bnez	a4,ffffffffc02027b4 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc020277e:	000d4717          	auipc	a4,0xd4
ffffffffc0202782:	66a73703          	ld	a4,1642(a4) # ffffffffc02d6de8 <pages>
ffffffffc0202786:	8c19                	sub	s0,s0,a4
ffffffffc0202788:	000807b7          	lui	a5,0x80
ffffffffc020278c:	8419                	srai	s0,s0,0x6
ffffffffc020278e:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202790:	042a                	slli	s0,s0,0xa
ffffffffc0202792:	8cc1                	or	s1,s1,s0
ffffffffc0202794:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202798:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4d30>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020279c:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc02027a0:	4501                	li	a0,0
}
ffffffffc02027a2:	70e2                	ld	ra,56(sp)
ffffffffc02027a4:	7442                	ld	s0,48(sp)
ffffffffc02027a6:	74a2                	ld	s1,40(sp)
ffffffffc02027a8:	7902                	ld	s2,32(sp)
ffffffffc02027aa:	69e2                	ld	s3,24(sp)
ffffffffc02027ac:	6a42                	ld	s4,16(sp)
ffffffffc02027ae:	6aa2                	ld	s5,8(sp)
ffffffffc02027b0:	6121                	addi	sp,sp,64
ffffffffc02027b2:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02027b4:	078a                	slli	a5,a5,0x2
ffffffffc02027b6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02027b8:	000d4717          	auipc	a4,0xd4
ffffffffc02027bc:	62873703          	ld	a4,1576(a4) # ffffffffc02d6de0 <npage>
ffffffffc02027c0:	06e7ff63          	bgeu	a5,a4,ffffffffc020283e <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02027c4:	000d4a97          	auipc	s5,0xd4
ffffffffc02027c8:	624a8a93          	addi	s5,s5,1572 # ffffffffc02d6de8 <pages>
ffffffffc02027cc:	000ab703          	ld	a4,0(s5)
ffffffffc02027d0:	fff80937          	lui	s2,0xfff80
ffffffffc02027d4:	993e                	add	s2,s2,a5
ffffffffc02027d6:	091a                	slli	s2,s2,0x6
ffffffffc02027d8:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc02027da:	01240c63          	beq	s0,s2,ffffffffc02027f2 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc02027de:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fca91d4>
ffffffffc02027e2:	fff7869b          	addiw	a3,a5,-1
ffffffffc02027e6:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) == 0)
ffffffffc02027ea:	c691                	beqz	a3,ffffffffc02027f6 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02027ec:	120a0073          	sfence.vma	s4
}
ffffffffc02027f0:	bf59                	j	ffffffffc0202786 <page_insert+0x3a>
ffffffffc02027f2:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02027f4:	bf49                	j	ffffffffc0202786 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02027f6:	100027f3          	csrr	a5,sstatus
ffffffffc02027fa:	8b89                	andi	a5,a5,2
ffffffffc02027fc:	ef91                	bnez	a5,ffffffffc0202818 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc02027fe:	000d4797          	auipc	a5,0xd4
ffffffffc0202802:	5f27b783          	ld	a5,1522(a5) # ffffffffc02d6df0 <pmm_manager>
ffffffffc0202806:	739c                	ld	a5,32(a5)
ffffffffc0202808:	4585                	li	a1,1
ffffffffc020280a:	854a                	mv	a0,s2
ffffffffc020280c:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020280e:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202812:	120a0073          	sfence.vma	s4
ffffffffc0202816:	bf85                	j	ffffffffc0202786 <page_insert+0x3a>
        intr_disable();
ffffffffc0202818:	99cfe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020281c:	000d4797          	auipc	a5,0xd4
ffffffffc0202820:	5d47b783          	ld	a5,1492(a5) # ffffffffc02d6df0 <pmm_manager>
ffffffffc0202824:	739c                	ld	a5,32(a5)
ffffffffc0202826:	4585                	li	a1,1
ffffffffc0202828:	854a                	mv	a0,s2
ffffffffc020282a:	9782                	jalr	a5
        intr_enable();
ffffffffc020282c:	982fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202830:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202834:	120a0073          	sfence.vma	s4
ffffffffc0202838:	b7b9                	j	ffffffffc0202786 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020283a:	5571                	li	a0,-4
ffffffffc020283c:	b79d                	j	ffffffffc02027a2 <page_insert+0x56>
ffffffffc020283e:	f2eff0ef          	jal	ra,ffffffffc0201f6c <pa2page.part.0>

ffffffffc0202842 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202842:	00004797          	auipc	a5,0x4
ffffffffc0202846:	13678793          	addi	a5,a5,310 # ffffffffc0206978 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020284a:	638c                	ld	a1,0(a5)
{
ffffffffc020284c:	7159                	addi	sp,sp,-112
ffffffffc020284e:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202850:	00004517          	auipc	a0,0x4
ffffffffc0202854:	2d050513          	addi	a0,a0,720 # ffffffffc0206b20 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc0202858:	000d4b17          	auipc	s6,0xd4
ffffffffc020285c:	598b0b13          	addi	s6,s6,1432 # ffffffffc02d6df0 <pmm_manager>
{
ffffffffc0202860:	f486                	sd	ra,104(sp)
ffffffffc0202862:	e8ca                	sd	s2,80(sp)
ffffffffc0202864:	e4ce                	sd	s3,72(sp)
ffffffffc0202866:	f0a2                	sd	s0,96(sp)
ffffffffc0202868:	eca6                	sd	s1,88(sp)
ffffffffc020286a:	e0d2                	sd	s4,64(sp)
ffffffffc020286c:	fc56                	sd	s5,56(sp)
ffffffffc020286e:	f45e                	sd	s7,40(sp)
ffffffffc0202870:	f062                	sd	s8,32(sp)
ffffffffc0202872:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202874:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202878:	91dfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    pmm_manager->init();
ffffffffc020287c:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202880:	000d4997          	auipc	s3,0xd4
ffffffffc0202884:	57898993          	addi	s3,s3,1400 # ffffffffc02d6df8 <va_pa_offset>
    pmm_manager->init();
ffffffffc0202888:	679c                	ld	a5,8(a5)
ffffffffc020288a:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020288c:	57f5                	li	a5,-3
ffffffffc020288e:	07fa                	slli	a5,a5,0x1e
ffffffffc0202890:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc0202894:	906fe0ef          	jal	ra,ffffffffc020099a <get_memory_base>
ffffffffc0202898:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc020289a:	90afe0ef          	jal	ra,ffffffffc02009a4 <get_memory_size>
    if (mem_size == 0)
ffffffffc020289e:	200505e3          	beqz	a0,ffffffffc02032a8 <pmm_init+0xa66>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02028a2:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc02028a4:	00004517          	auipc	a0,0x4
ffffffffc02028a8:	2b450513          	addi	a0,a0,692 # ffffffffc0206b58 <default_pmm_manager+0x1e0>
ffffffffc02028ac:	8e9fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02028b0:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02028b4:	fff40693          	addi	a3,s0,-1
ffffffffc02028b8:	864a                	mv	a2,s2
ffffffffc02028ba:	85a6                	mv	a1,s1
ffffffffc02028bc:	00004517          	auipc	a0,0x4
ffffffffc02028c0:	2b450513          	addi	a0,a0,692 # ffffffffc0206b70 <default_pmm_manager+0x1f8>
ffffffffc02028c4:	8d1fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02028c8:	c8000737          	lui	a4,0xc8000
ffffffffc02028cc:	87a2                	mv	a5,s0
ffffffffc02028ce:	54876163          	bltu	a4,s0,ffffffffc0202e10 <pmm_init+0x5ce>
ffffffffc02028d2:	757d                	lui	a0,0xfffff
ffffffffc02028d4:	000d5617          	auipc	a2,0xd5
ffffffffc02028d8:	55760613          	addi	a2,a2,1367 # ffffffffc02d7e2b <end+0xfff>
ffffffffc02028dc:	8e69                	and	a2,a2,a0
ffffffffc02028de:	000d4497          	auipc	s1,0xd4
ffffffffc02028e2:	50248493          	addi	s1,s1,1282 # ffffffffc02d6de0 <npage>
ffffffffc02028e6:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02028ea:	000d4b97          	auipc	s7,0xd4
ffffffffc02028ee:	4feb8b93          	addi	s7,s7,1278 # ffffffffc02d6de8 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02028f2:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02028f4:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02028f8:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02028fc:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02028fe:	02f50863          	beq	a0,a5,ffffffffc020292e <pmm_init+0xec>
ffffffffc0202902:	4781                	li	a5,0
ffffffffc0202904:	4585                	li	a1,1
ffffffffc0202906:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc020290a:	00679513          	slli	a0,a5,0x6
ffffffffc020290e:	9532                	add	a0,a0,a2
ffffffffc0202910:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd281dc>
ffffffffc0202914:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202918:	6088                	ld	a0,0(s1)
ffffffffc020291a:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc020291c:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202920:	00d50733          	add	a4,a0,a3
ffffffffc0202924:	fee7e3e3          	bltu	a5,a4,ffffffffc020290a <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202928:	071a                	slli	a4,a4,0x6
ffffffffc020292a:	00e606b3          	add	a3,a2,a4
ffffffffc020292e:	c02007b7          	lui	a5,0xc0200
ffffffffc0202932:	2ef6ece3          	bltu	a3,a5,ffffffffc020342a <pmm_init+0xbe8>
ffffffffc0202936:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020293a:	77fd                	lui	a5,0xfffff
ffffffffc020293c:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020293e:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0202940:	5086eb63          	bltu	a3,s0,ffffffffc0202e56 <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202944:	00004517          	auipc	a0,0x4
ffffffffc0202948:	25450513          	addi	a0,a0,596 # ffffffffc0206b98 <default_pmm_manager+0x220>
ffffffffc020294c:	849fd0ef          	jal	ra,ffffffffc0200194 <cprintf>

// 检查分配函数功能的静态测试函数
static void check_alloc_page(void)
{
    // 调用管理器的检查函数
    pmm_manager->check();
ffffffffc0202950:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202954:	000d4917          	auipc	s2,0xd4
ffffffffc0202958:	48490913          	addi	s2,s2,1156 # ffffffffc02d6dd8 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc020295c:	7b9c                	ld	a5,48(a5)
ffffffffc020295e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202960:	00004517          	auipc	a0,0x4
ffffffffc0202964:	25050513          	addi	a0,a0,592 # ffffffffc0206bb0 <default_pmm_manager+0x238>
ffffffffc0202968:	82dfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc020296c:	00008697          	auipc	a3,0x8
ffffffffc0202970:	69468693          	addi	a3,a3,1684 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0202974:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0202978:	c02007b7          	lui	a5,0xc0200
ffffffffc020297c:	28f6ebe3          	bltu	a3,a5,ffffffffc0203412 <pmm_init+0xbd0>
ffffffffc0202980:	0009b783          	ld	a5,0(s3)
ffffffffc0202984:	8e9d                	sub	a3,a3,a5
ffffffffc0202986:	000d4797          	auipc	a5,0xd4
ffffffffc020298a:	44d7b523          	sd	a3,1098(a5) # ffffffffc02d6dd0 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020298e:	100027f3          	csrr	a5,sstatus
ffffffffc0202992:	8b89                	andi	a5,a5,2
ffffffffc0202994:	4a079763          	bnez	a5,ffffffffc0202e42 <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202998:	000b3783          	ld	a5,0(s6)
ffffffffc020299c:	779c                	ld	a5,40(a5)
ffffffffc020299e:	9782                	jalr	a5
ffffffffc02029a0:	842a                	mv	s0,a0
    // 记录当前的空闲页数
    size_t nr_free_store;
    nr_free_store = nr_free_pages();

    // 一些断言检查
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02029a2:	6098                	ld	a4,0(s1)
ffffffffc02029a4:	c80007b7          	lui	a5,0xc8000
ffffffffc02029a8:	83b1                	srli	a5,a5,0xc
ffffffffc02029aa:	66e7e363          	bltu	a5,a4,ffffffffc0203010 <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02029ae:	00093503          	ld	a0,0(s2)
ffffffffc02029b2:	62050f63          	beqz	a0,ffffffffc0202ff0 <pmm_init+0x7ae>
ffffffffc02029b6:	03451793          	slli	a5,a0,0x34
ffffffffc02029ba:	62079b63          	bnez	a5,ffffffffc0202ff0 <pmm_init+0x7ae>
    // 确保地址 0 还没被映射
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02029be:	4601                	li	a2,0
ffffffffc02029c0:	4581                	li	a1,0
ffffffffc02029c2:	8c3ff0ef          	jal	ra,ffffffffc0202284 <get_page>
ffffffffc02029c6:	60051563          	bnez	a0,ffffffffc0202fd0 <pmm_init+0x78e>
ffffffffc02029ca:	100027f3          	csrr	a5,sstatus
ffffffffc02029ce:	8b89                	andi	a5,a5,2
ffffffffc02029d0:	44079e63          	bnez	a5,ffffffffc0202e2c <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc02029d4:	000b3783          	ld	a5,0(s6)
ffffffffc02029d8:	4505                	li	a0,1
ffffffffc02029da:	6f9c                	ld	a5,24(a5)
ffffffffc02029dc:	9782                	jalr	a5
ffffffffc02029de:	8a2a                	mv	s4,a0

    // 分配页面 p1
    struct Page *p1, *p2;
    p1 = alloc_page();
    // 尝试将 p1 映射到地址 0x0
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02029e0:	00093503          	ld	a0,0(s2)
ffffffffc02029e4:	4681                	li	a3,0
ffffffffc02029e6:	4601                	li	a2,0
ffffffffc02029e8:	85d2                	mv	a1,s4
ffffffffc02029ea:	d63ff0ef          	jal	ra,ffffffffc020274c <page_insert>
ffffffffc02029ee:	26051ae3          	bnez	a0,ffffffffc0203462 <pmm_init+0xc20>

    // 检查映射是否成功
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02029f2:	00093503          	ld	a0,0(s2)
ffffffffc02029f6:	4601                	li	a2,0
ffffffffc02029f8:	4581                	li	a1,0
ffffffffc02029fa:	e62ff0ef          	jal	ra,ffffffffc020205c <get_pte>
ffffffffc02029fe:	240502e3          	beqz	a0,ffffffffc0203442 <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc0202a02:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202a04:	0017f713          	andi	a4,a5,1
ffffffffc0202a08:	5a070263          	beqz	a4,ffffffffc0202fac <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202a0c:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a0e:	078a                	slli	a5,a5,0x2
ffffffffc0202a10:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202a12:	58e7fb63          	bgeu	a5,a4,ffffffffc0202fa8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a16:	000bb683          	ld	a3,0(s7)
ffffffffc0202a1a:	fff80637          	lui	a2,0xfff80
ffffffffc0202a1e:	97b2                	add	a5,a5,a2
ffffffffc0202a20:	079a                	slli	a5,a5,0x6
ffffffffc0202a22:	97b6                	add	a5,a5,a3
ffffffffc0202a24:	14fa17e3          	bne	s4,a5,ffffffffc0203372 <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc0202a28:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8d60>
ffffffffc0202a2c:	4785                	li	a5,1
ffffffffc0202a2e:	12f692e3          	bne	a3,a5,ffffffffc0203352 <pmm_init+0xb10>

    // 检查页表结构的连续性假设
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202a32:	00093503          	ld	a0,0(s2)
ffffffffc0202a36:	77fd                	lui	a5,0xfffff
ffffffffc0202a38:	6114                	ld	a3,0(a0)
ffffffffc0202a3a:	068a                	slli	a3,a3,0x2
ffffffffc0202a3c:	8efd                	and	a3,a3,a5
ffffffffc0202a3e:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202a42:	0ee67ce3          	bgeu	a2,a4,ffffffffc020333a <pmm_init+0xaf8>
ffffffffc0202a46:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a4a:	96e2                	add	a3,a3,s8
ffffffffc0202a4c:	0006ba83          	ld	s5,0(a3)
ffffffffc0202a50:	0a8a                	slli	s5,s5,0x2
ffffffffc0202a52:	00fafab3          	and	s5,s5,a5
ffffffffc0202a56:	00cad793          	srli	a5,s5,0xc
ffffffffc0202a5a:	0ce7f3e3          	bgeu	a5,a4,ffffffffc0203320 <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202a5e:	4601                	li	a2,0
ffffffffc0202a60:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a62:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202a64:	df8ff0ef          	jal	ra,ffffffffc020205c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a68:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202a6a:	55551363          	bne	a0,s5,ffffffffc0202fb0 <pmm_init+0x76e>
ffffffffc0202a6e:	100027f3          	csrr	a5,sstatus
ffffffffc0202a72:	8b89                	andi	a5,a5,2
ffffffffc0202a74:	3a079163          	bnez	a5,ffffffffc0202e16 <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a78:	000b3783          	ld	a5,0(s6)
ffffffffc0202a7c:	4505                	li	a0,1
ffffffffc0202a7e:	6f9c                	ld	a5,24(a5)
ffffffffc0202a80:	9782                	jalr	a5
ffffffffc0202a82:	8c2a                	mv	s8,a0

    // 分配页面 p2 并映射到 PGSIZE (第二个页的位置)
    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202a84:	00093503          	ld	a0,0(s2)
ffffffffc0202a88:	46d1                	li	a3,20
ffffffffc0202a8a:	6605                	lui	a2,0x1
ffffffffc0202a8c:	85e2                	mv	a1,s8
ffffffffc0202a8e:	cbfff0ef          	jal	ra,ffffffffc020274c <page_insert>
ffffffffc0202a92:	060517e3          	bnez	a0,ffffffffc0203300 <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202a96:	00093503          	ld	a0,0(s2)
ffffffffc0202a9a:	4601                	li	a2,0
ffffffffc0202a9c:	6585                	lui	a1,0x1
ffffffffc0202a9e:	dbeff0ef          	jal	ra,ffffffffc020205c <get_pte>
ffffffffc0202aa2:	02050fe3          	beqz	a0,ffffffffc02032e0 <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc0202aa6:	611c                	ld	a5,0(a0)
ffffffffc0202aa8:	0107f713          	andi	a4,a5,16
ffffffffc0202aac:	7c070e63          	beqz	a4,ffffffffc0203288 <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc0202ab0:	8b91                	andi	a5,a5,4
ffffffffc0202ab2:	7a078b63          	beqz	a5,ffffffffc0203268 <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202ab6:	00093503          	ld	a0,0(s2)
ffffffffc0202aba:	611c                	ld	a5,0(a0)
ffffffffc0202abc:	8bc1                	andi	a5,a5,16
ffffffffc0202abe:	78078563          	beqz	a5,ffffffffc0203248 <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc0202ac2:	000c2703          	lw	a4,0(s8)
ffffffffc0202ac6:	4785                	li	a5,1
ffffffffc0202ac8:	76f71063          	bne	a4,a5,ffffffffc0203228 <pmm_init+0x9e6>

    // 将 p1 重新映射到 PGSIZE (覆盖 p2)
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202acc:	4681                	li	a3,0
ffffffffc0202ace:	6605                	lui	a2,0x1
ffffffffc0202ad0:	85d2                	mv	a1,s4
ffffffffc0202ad2:	c7bff0ef          	jal	ra,ffffffffc020274c <page_insert>
ffffffffc0202ad6:	72051963          	bnez	a0,ffffffffc0203208 <pmm_init+0x9c6>
    assert(page_ref(p1) == 2); // p1 现在被映射了两次 (0x0 和 PGSIZE)
ffffffffc0202ada:	000a2703          	lw	a4,0(s4)
ffffffffc0202ade:	4789                	li	a5,2
ffffffffc0202ae0:	70f71463          	bne	a4,a5,ffffffffc02031e8 <pmm_init+0x9a6>
    assert(page_ref(p2) == 0); // p2 被覆盖，引用归零
ffffffffc0202ae4:	000c2783          	lw	a5,0(s8)
ffffffffc0202ae8:	6e079063          	bnez	a5,ffffffffc02031c8 <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202aec:	00093503          	ld	a0,0(s2)
ffffffffc0202af0:	4601                	li	a2,0
ffffffffc0202af2:	6585                	lui	a1,0x1
ffffffffc0202af4:	d68ff0ef          	jal	ra,ffffffffc020205c <get_pte>
ffffffffc0202af8:	6a050863          	beqz	a0,ffffffffc02031a8 <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc0202afc:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202afe:	00177793          	andi	a5,a4,1
ffffffffc0202b02:	4a078563          	beqz	a5,ffffffffc0202fac <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202b06:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b08:	00271793          	slli	a5,a4,0x2
ffffffffc0202b0c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b0e:	48d7fd63          	bgeu	a5,a3,ffffffffc0202fa8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b12:	000bb683          	ld	a3,0(s7)
ffffffffc0202b16:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202b1a:	97d6                	add	a5,a5,s5
ffffffffc0202b1c:	079a                	slli	a5,a5,0x6
ffffffffc0202b1e:	97b6                	add	a5,a5,a3
ffffffffc0202b20:	66fa1463          	bne	s4,a5,ffffffffc0203188 <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202b24:	8b41                	andi	a4,a4,16
ffffffffc0202b26:	64071163          	bnez	a4,ffffffffc0203168 <pmm_init+0x926>

    // 移除 0x0 的映射
    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202b2a:	00093503          	ld	a0,0(s2)
ffffffffc0202b2e:	4581                	li	a1,0
ffffffffc0202b30:	b81ff0ef          	jal	ra,ffffffffc02026b0 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202b34:	000a2c83          	lw	s9,0(s4)
ffffffffc0202b38:	4785                	li	a5,1
ffffffffc0202b3a:	60fc9763          	bne	s9,a5,ffffffffc0203148 <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc0202b3e:	000c2783          	lw	a5,0(s8)
ffffffffc0202b42:	5e079363          	bnez	a5,ffffffffc0203128 <pmm_init+0x8e6>

    // 移除 PGSIZE 的映射
    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202b46:	00093503          	ld	a0,0(s2)
ffffffffc0202b4a:	6585                	lui	a1,0x1
ffffffffc0202b4c:	b65ff0ef          	jal	ra,ffffffffc02026b0 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202b50:	000a2783          	lw	a5,0(s4)
ffffffffc0202b54:	52079a63          	bnez	a5,ffffffffc0203088 <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc0202b58:	000c2783          	lw	a5,0(s8)
ffffffffc0202b5c:	50079663          	bnez	a5,ffffffffc0203068 <pmm_init+0x826>

    // 检查中间页表的引用计数
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202b60:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202b64:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b66:	000a3683          	ld	a3,0(s4)
ffffffffc0202b6a:	068a                	slli	a3,a3,0x2
ffffffffc0202b6c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b6e:	42b6fd63          	bgeu	a3,a1,ffffffffc0202fa8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b72:	000bb503          	ld	a0,0(s7)
ffffffffc0202b76:	96d6                	add	a3,a3,s5
ffffffffc0202b78:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0202b7a:	00d507b3          	add	a5,a0,a3
ffffffffc0202b7e:	439c                	lw	a5,0(a5)
ffffffffc0202b80:	4d979463          	bne	a5,s9,ffffffffc0203048 <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc0202b84:	8699                	srai	a3,a3,0x6
ffffffffc0202b86:	00080637          	lui	a2,0x80
ffffffffc0202b8a:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202b8c:	00c69713          	slli	a4,a3,0xc
ffffffffc0202b90:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b92:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202b94:	48b77e63          	bgeu	a4,a1,ffffffffc0203030 <pmm_init+0x7ee>

    // 清理测试用的页表
    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202b98:	0009b703          	ld	a4,0(s3)
ffffffffc0202b9c:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b9e:	629c                	ld	a5,0(a3)
ffffffffc0202ba0:	078a                	slli	a5,a5,0x2
ffffffffc0202ba2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ba4:	40b7f263          	bgeu	a5,a1,ffffffffc0202fa8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ba8:	8f91                	sub	a5,a5,a2
ffffffffc0202baa:	079a                	slli	a5,a5,0x6
ffffffffc0202bac:	953e                	add	a0,a0,a5
ffffffffc0202bae:	100027f3          	csrr	a5,sstatus
ffffffffc0202bb2:	8b89                	andi	a5,a5,2
ffffffffc0202bb4:	30079963          	bnez	a5,ffffffffc0202ec6 <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc0202bb8:	000b3783          	ld	a5,0(s6)
ffffffffc0202bbc:	4585                	li	a1,1
ffffffffc0202bbe:	739c                	ld	a5,32(a5)
ffffffffc0202bc0:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bc2:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202bc6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bc8:	078a                	slli	a5,a5,0x2
ffffffffc0202bca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202bcc:	3ce7fe63          	bgeu	a5,a4,ffffffffc0202fa8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bd0:	000bb503          	ld	a0,0(s7)
ffffffffc0202bd4:	fff80737          	lui	a4,0xfff80
ffffffffc0202bd8:	97ba                	add	a5,a5,a4
ffffffffc0202bda:	079a                	slli	a5,a5,0x6
ffffffffc0202bdc:	953e                	add	a0,a0,a5
ffffffffc0202bde:	100027f3          	csrr	a5,sstatus
ffffffffc0202be2:	8b89                	andi	a5,a5,2
ffffffffc0202be4:	2c079563          	bnez	a5,ffffffffc0202eae <pmm_init+0x66c>
ffffffffc0202be8:	000b3783          	ld	a5,0(s6)
ffffffffc0202bec:	4585                	li	a1,1
ffffffffc0202bee:	739c                	ld	a5,32(a5)
ffffffffc0202bf0:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202bf2:	00093783          	ld	a5,0(s2)
ffffffffc0202bf6:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd281d4>
    asm volatile("sfence.vma");
ffffffffc0202bfa:	12000073          	sfence.vma
ffffffffc0202bfe:	100027f3          	csrr	a5,sstatus
ffffffffc0202c02:	8b89                	andi	a5,a5,2
ffffffffc0202c04:	28079b63          	bnez	a5,ffffffffc0202e9a <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c08:	000b3783          	ld	a5,0(s6)
ffffffffc0202c0c:	779c                	ld	a5,40(a5)
ffffffffc0202c0e:	9782                	jalr	a5
ffffffffc0202c10:	8a2a                	mv	s4,a0
    flush_tlb();

    // 确保没有内存泄漏
    assert(nr_free_store == nr_free_pages());
ffffffffc0202c12:	4b441b63          	bne	s0,s4,ffffffffc02030c8 <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202c16:	00004517          	auipc	a0,0x4
ffffffffc0202c1a:	2c250513          	addi	a0,a0,706 # ffffffffc0206ed8 <default_pmm_manager+0x560>
ffffffffc0202c1e:	d76fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0202c22:	100027f3          	csrr	a5,sstatus
ffffffffc0202c26:	8b89                	andi	a5,a5,2
ffffffffc0202c28:	24079f63          	bnez	a5,ffffffffc0202e86 <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c2c:	000b3783          	ld	a5,0(s6)
ffffffffc0202c30:	779c                	ld	a5,40(a5)
ffffffffc0202c32:	9782                	jalr	a5
ffffffffc0202c34:	8c2a                	mv	s8,a0
    int i;

    nr_free_store = nr_free_pages();

    // 遍历内核空间，确保都建立了映射
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202c36:	6098                	ld	a4,0(s1)
ffffffffc0202c38:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202c3c:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202c3e:	00c71793          	slli	a5,a4,0xc
ffffffffc0202c42:	6a05                	lui	s4,0x1
ffffffffc0202c44:	02f47c63          	bgeu	s0,a5,ffffffffc0202c7c <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202c48:	00c45793          	srli	a5,s0,0xc
ffffffffc0202c4c:	00093503          	ld	a0,0(s2)
ffffffffc0202c50:	2ee7ff63          	bgeu	a5,a4,ffffffffc0202f4e <pmm_init+0x70c>
ffffffffc0202c54:	0009b583          	ld	a1,0(s3)
ffffffffc0202c58:	4601                	li	a2,0
ffffffffc0202c5a:	95a2                	add	a1,a1,s0
ffffffffc0202c5c:	c00ff0ef          	jal	ra,ffffffffc020205c <get_pte>
ffffffffc0202c60:	32050463          	beqz	a0,ffffffffc0202f88 <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202c64:	611c                	ld	a5,0(a0)
ffffffffc0202c66:	078a                	slli	a5,a5,0x2
ffffffffc0202c68:	0157f7b3          	and	a5,a5,s5
ffffffffc0202c6c:	2e879e63          	bne	a5,s0,ffffffffc0202f68 <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202c70:	6098                	ld	a4,0(s1)
ffffffffc0202c72:	9452                	add	s0,s0,s4
ffffffffc0202c74:	00c71793          	slli	a5,a4,0xc
ffffffffc0202c78:	fcf468e3          	bltu	s0,a5,ffffffffc0202c48 <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202c7c:	00093783          	ld	a5,0(s2)
ffffffffc0202c80:	639c                	ld	a5,0(a5)
ffffffffc0202c82:	42079363          	bnez	a5,ffffffffc02030a8 <pmm_init+0x866>
ffffffffc0202c86:	100027f3          	csrr	a5,sstatus
ffffffffc0202c8a:	8b89                	andi	a5,a5,2
ffffffffc0202c8c:	24079963          	bnez	a5,ffffffffc0202ede <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202c90:	000b3783          	ld	a5,0(s6)
ffffffffc0202c94:	4505                	li	a0,1
ffffffffc0202c96:	6f9c                	ld	a5,24(a5)
ffffffffc0202c98:	9782                	jalr	a5
ffffffffc0202c9a:	8a2a                	mv	s4,a0

    // 测试读写映射
    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c9c:	00093503          	ld	a0,0(s2)
ffffffffc0202ca0:	4699                	li	a3,6
ffffffffc0202ca2:	10000613          	li	a2,256
ffffffffc0202ca6:	85d2                	mv	a1,s4
ffffffffc0202ca8:	aa5ff0ef          	jal	ra,ffffffffc020274c <page_insert>
ffffffffc0202cac:	44051e63          	bnez	a0,ffffffffc0203108 <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc0202cb0:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8d60>
ffffffffc0202cb4:	4785                	li	a5,1
ffffffffc0202cb6:	42f71963          	bne	a4,a5,ffffffffc02030e8 <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202cba:	00093503          	ld	a0,0(s2)
ffffffffc0202cbe:	6405                	lui	s0,0x1
ffffffffc0202cc0:	4699                	li	a3,6
ffffffffc0202cc2:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8c60>
ffffffffc0202cc6:	85d2                	mv	a1,s4
ffffffffc0202cc8:	a85ff0ef          	jal	ra,ffffffffc020274c <page_insert>
ffffffffc0202ccc:	72051363          	bnez	a0,ffffffffc02033f2 <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc0202cd0:	000a2703          	lw	a4,0(s4)
ffffffffc0202cd4:	4789                	li	a5,2
ffffffffc0202cd6:	6ef71e63          	bne	a4,a5,ffffffffc02033d2 <pmm_init+0xb90>

    // 写入字符串测试
    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202cda:	00004597          	auipc	a1,0x4
ffffffffc0202cde:	34658593          	addi	a1,a1,838 # ffffffffc0207020 <default_pmm_manager+0x6a8>
ffffffffc0202ce2:	10000513          	li	a0,256
ffffffffc0202ce6:	587020ef          	jal	ra,ffffffffc0205a6c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202cea:	10040593          	addi	a1,s0,256
ffffffffc0202cee:	10000513          	li	a0,256
ffffffffc0202cf2:	58d020ef          	jal	ra,ffffffffc0205a7e <strcmp>
ffffffffc0202cf6:	6a051e63          	bnez	a0,ffffffffc02033b2 <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc0202cfa:	000bb683          	ld	a3,0(s7)
ffffffffc0202cfe:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202d02:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202d04:	40da06b3          	sub	a3,s4,a3
ffffffffc0202d08:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202d0a:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202d0c:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202d0e:	8031                	srli	s0,s0,0xc
ffffffffc0202d10:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d14:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202d16:	30f77d63          	bgeu	a4,a5,ffffffffc0203030 <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202d1a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202d1e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202d22:	96be                	add	a3,a3,a5
ffffffffc0202d24:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202d28:	50f020ef          	jal	ra,ffffffffc0205a36 <strlen>
ffffffffc0202d2c:	66051363          	bnez	a0,ffffffffc0203392 <pmm_init+0xb50>

    // 清理
    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202d30:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202d34:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d36:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd281d4>
ffffffffc0202d3a:	068a                	slli	a3,a3,0x2
ffffffffc0202d3c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d3e:	26f6f563          	bgeu	a3,a5,ffffffffc0202fa8 <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc0202d42:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d44:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202d46:	2ef47563          	bgeu	s0,a5,ffffffffc0203030 <pmm_init+0x7ee>
ffffffffc0202d4a:	0009b403          	ld	s0,0(s3)
ffffffffc0202d4e:	9436                	add	s0,s0,a3
ffffffffc0202d50:	100027f3          	csrr	a5,sstatus
ffffffffc0202d54:	8b89                	andi	a5,a5,2
ffffffffc0202d56:	1e079163          	bnez	a5,ffffffffc0202f38 <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0202d5a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d5e:	4585                	li	a1,1
ffffffffc0202d60:	8552                	mv	a0,s4
ffffffffc0202d62:	739c                	ld	a5,32(a5)
ffffffffc0202d64:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d66:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0202d68:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d6a:	078a                	slli	a5,a5,0x2
ffffffffc0202d6c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d6e:	22e7fd63          	bgeu	a5,a4,ffffffffc0202fa8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d72:	000bb503          	ld	a0,0(s7)
ffffffffc0202d76:	fff80737          	lui	a4,0xfff80
ffffffffc0202d7a:	97ba                	add	a5,a5,a4
ffffffffc0202d7c:	079a                	slli	a5,a5,0x6
ffffffffc0202d7e:	953e                	add	a0,a0,a5
ffffffffc0202d80:	100027f3          	csrr	a5,sstatus
ffffffffc0202d84:	8b89                	andi	a5,a5,2
ffffffffc0202d86:	18079d63          	bnez	a5,ffffffffc0202f20 <pmm_init+0x6de>
ffffffffc0202d8a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d8e:	4585                	li	a1,1
ffffffffc0202d90:	739c                	ld	a5,32(a5)
ffffffffc0202d92:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d94:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc0202d98:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d9a:	078a                	slli	a5,a5,0x2
ffffffffc0202d9c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d9e:	20e7f563          	bgeu	a5,a4,ffffffffc0202fa8 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202da2:	000bb503          	ld	a0,0(s7)
ffffffffc0202da6:	fff80737          	lui	a4,0xfff80
ffffffffc0202daa:	97ba                	add	a5,a5,a4
ffffffffc0202dac:	079a                	slli	a5,a5,0x6
ffffffffc0202dae:	953e                	add	a0,a0,a5
ffffffffc0202db0:	100027f3          	csrr	a5,sstatus
ffffffffc0202db4:	8b89                	andi	a5,a5,2
ffffffffc0202db6:	14079963          	bnez	a5,ffffffffc0202f08 <pmm_init+0x6c6>
ffffffffc0202dba:	000b3783          	ld	a5,0(s6)
ffffffffc0202dbe:	4585                	li	a1,1
ffffffffc0202dc0:	739c                	ld	a5,32(a5)
ffffffffc0202dc2:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202dc4:	00093783          	ld	a5,0(s2)
ffffffffc0202dc8:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202dcc:	12000073          	sfence.vma
ffffffffc0202dd0:	100027f3          	csrr	a5,sstatus
ffffffffc0202dd4:	8b89                	andi	a5,a5,2
ffffffffc0202dd6:	10079f63          	bnez	a5,ffffffffc0202ef4 <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202dda:	000b3783          	ld	a5,0(s6)
ffffffffc0202dde:	779c                	ld	a5,40(a5)
ffffffffc0202de0:	9782                	jalr	a5
ffffffffc0202de2:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202de4:	4c8c1e63          	bne	s8,s0,ffffffffc02032c0 <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202de8:	00004517          	auipc	a0,0x4
ffffffffc0202dec:	2b050513          	addi	a0,a0,688 # ffffffffc0207098 <default_pmm_manager+0x720>
ffffffffc0202df0:	ba4fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0202df4:	7406                	ld	s0,96(sp)
ffffffffc0202df6:	70a6                	ld	ra,104(sp)
ffffffffc0202df8:	64e6                	ld	s1,88(sp)
ffffffffc0202dfa:	6946                	ld	s2,80(sp)
ffffffffc0202dfc:	69a6                	ld	s3,72(sp)
ffffffffc0202dfe:	6a06                	ld	s4,64(sp)
ffffffffc0202e00:	7ae2                	ld	s5,56(sp)
ffffffffc0202e02:	7b42                	ld	s6,48(sp)
ffffffffc0202e04:	7ba2                	ld	s7,40(sp)
ffffffffc0202e06:	7c02                	ld	s8,32(sp)
ffffffffc0202e08:	6ce2                	ld	s9,24(sp)
ffffffffc0202e0a:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202e0c:	f87fe06f          	j	ffffffffc0201d92 <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc0202e10:	c80007b7          	lui	a5,0xc8000
ffffffffc0202e14:	bc7d                	j	ffffffffc02028d2 <pmm_init+0x90>
        intr_disable();
ffffffffc0202e16:	b9ffd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202e1a:	000b3783          	ld	a5,0(s6)
ffffffffc0202e1e:	4505                	li	a0,1
ffffffffc0202e20:	6f9c                	ld	a5,24(a5)
ffffffffc0202e22:	9782                	jalr	a5
ffffffffc0202e24:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202e26:	b89fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e2a:	b9a9                	j	ffffffffc0202a84 <pmm_init+0x242>
        intr_disable();
ffffffffc0202e2c:	b89fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202e30:	000b3783          	ld	a5,0(s6)
ffffffffc0202e34:	4505                	li	a0,1
ffffffffc0202e36:	6f9c                	ld	a5,24(a5)
ffffffffc0202e38:	9782                	jalr	a5
ffffffffc0202e3a:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202e3c:	b73fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e40:	b645                	j	ffffffffc02029e0 <pmm_init+0x19e>
        intr_disable();
ffffffffc0202e42:	b73fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e46:	000b3783          	ld	a5,0(s6)
ffffffffc0202e4a:	779c                	ld	a5,40(a5)
ffffffffc0202e4c:	9782                	jalr	a5
ffffffffc0202e4e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202e50:	b5ffd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e54:	b6b9                	j	ffffffffc02029a2 <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202e56:	6705                	lui	a4,0x1
ffffffffc0202e58:	177d                	addi	a4,a4,-1
ffffffffc0202e5a:	96ba                	add	a3,a3,a4
ffffffffc0202e5c:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202e5e:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202e62:	14a77363          	bgeu	a4,a0,ffffffffc0202fa8 <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0202e66:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0202e6a:	fff80537          	lui	a0,0xfff80
ffffffffc0202e6e:	972a                	add	a4,a4,a0
ffffffffc0202e70:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202e72:	8c1d                	sub	s0,s0,a5
ffffffffc0202e74:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202e78:	00c45593          	srli	a1,s0,0xc
ffffffffc0202e7c:	9532                	add	a0,a0,a2
ffffffffc0202e7e:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202e80:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202e84:	b4c1                	j	ffffffffc0202944 <pmm_init+0x102>
        intr_disable();
ffffffffc0202e86:	b2ffd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e8a:	000b3783          	ld	a5,0(s6)
ffffffffc0202e8e:	779c                	ld	a5,40(a5)
ffffffffc0202e90:	9782                	jalr	a5
ffffffffc0202e92:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202e94:	b1bfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e98:	bb79                	j	ffffffffc0202c36 <pmm_init+0x3f4>
        intr_disable();
ffffffffc0202e9a:	b1bfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202e9e:	000b3783          	ld	a5,0(s6)
ffffffffc0202ea2:	779c                	ld	a5,40(a5)
ffffffffc0202ea4:	9782                	jalr	a5
ffffffffc0202ea6:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202ea8:	b07fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202eac:	b39d                	j	ffffffffc0202c12 <pmm_init+0x3d0>
ffffffffc0202eae:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202eb0:	b05fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202eb4:	000b3783          	ld	a5,0(s6)
ffffffffc0202eb8:	6522                	ld	a0,8(sp)
ffffffffc0202eba:	4585                	li	a1,1
ffffffffc0202ebc:	739c                	ld	a5,32(a5)
ffffffffc0202ebe:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ec0:	aeffd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202ec4:	b33d                	j	ffffffffc0202bf2 <pmm_init+0x3b0>
ffffffffc0202ec6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ec8:	aedfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202ecc:	000b3783          	ld	a5,0(s6)
ffffffffc0202ed0:	6522                	ld	a0,8(sp)
ffffffffc0202ed2:	4585                	li	a1,1
ffffffffc0202ed4:	739c                	ld	a5,32(a5)
ffffffffc0202ed6:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ed8:	ad7fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202edc:	b1dd                	j	ffffffffc0202bc2 <pmm_init+0x380>
        intr_disable();
ffffffffc0202ede:	ad7fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202ee2:	000b3783          	ld	a5,0(s6)
ffffffffc0202ee6:	4505                	li	a0,1
ffffffffc0202ee8:	6f9c                	ld	a5,24(a5)
ffffffffc0202eea:	9782                	jalr	a5
ffffffffc0202eec:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202eee:	ac1fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202ef2:	b36d                	j	ffffffffc0202c9c <pmm_init+0x45a>
        intr_disable();
ffffffffc0202ef4:	ac1fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ef8:	000b3783          	ld	a5,0(s6)
ffffffffc0202efc:	779c                	ld	a5,40(a5)
ffffffffc0202efe:	9782                	jalr	a5
ffffffffc0202f00:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202f02:	aadfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202f06:	bdf9                	j	ffffffffc0202de4 <pmm_init+0x5a2>
ffffffffc0202f08:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202f0a:	aabfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202f0e:	000b3783          	ld	a5,0(s6)
ffffffffc0202f12:	6522                	ld	a0,8(sp)
ffffffffc0202f14:	4585                	li	a1,1
ffffffffc0202f16:	739c                	ld	a5,32(a5)
ffffffffc0202f18:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f1a:	a95fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202f1e:	b55d                	j	ffffffffc0202dc4 <pmm_init+0x582>
ffffffffc0202f20:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202f22:	a93fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202f26:	000b3783          	ld	a5,0(s6)
ffffffffc0202f2a:	6522                	ld	a0,8(sp)
ffffffffc0202f2c:	4585                	li	a1,1
ffffffffc0202f2e:	739c                	ld	a5,32(a5)
ffffffffc0202f30:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f32:	a7dfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202f36:	bdb9                	j	ffffffffc0202d94 <pmm_init+0x552>
        intr_disable();
ffffffffc0202f38:	a7dfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202f3c:	000b3783          	ld	a5,0(s6)
ffffffffc0202f40:	4585                	li	a1,1
ffffffffc0202f42:	8552                	mv	a0,s4
ffffffffc0202f44:	739c                	ld	a5,32(a5)
ffffffffc0202f46:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f48:	a67fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202f4c:	bd29                	j	ffffffffc0202d66 <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202f4e:	86a2                	mv	a3,s0
ffffffffc0202f50:	00004617          	auipc	a2,0x4
ffffffffc0202f54:	a6060613          	addi	a2,a2,-1440 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0202f58:	2ff00593          	li	a1,767
ffffffffc0202f5c:	00004517          	auipc	a0,0x4
ffffffffc0202f60:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202f64:	d2afd0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202f68:	00004697          	auipc	a3,0x4
ffffffffc0202f6c:	fd068693          	addi	a3,a3,-48 # ffffffffc0206f38 <default_pmm_manager+0x5c0>
ffffffffc0202f70:	00003617          	auipc	a2,0x3
ffffffffc0202f74:	65860613          	addi	a2,a2,1624 # ffffffffc02065c8 <commands+0x858>
ffffffffc0202f78:	30000593          	li	a1,768
ffffffffc0202f7c:	00004517          	auipc	a0,0x4
ffffffffc0202f80:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202f84:	d0afd0ef          	jal	ra,ffffffffc020048e <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202f88:	00004697          	auipc	a3,0x4
ffffffffc0202f8c:	f7068693          	addi	a3,a3,-144 # ffffffffc0206ef8 <default_pmm_manager+0x580>
ffffffffc0202f90:	00003617          	auipc	a2,0x3
ffffffffc0202f94:	63860613          	addi	a2,a2,1592 # ffffffffc02065c8 <commands+0x858>
ffffffffc0202f98:	2ff00593          	li	a1,767
ffffffffc0202f9c:	00004517          	auipc	a0,0x4
ffffffffc0202fa0:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202fa4:	ceafd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0202fa8:	fc5fe0ef          	jal	ra,ffffffffc0201f6c <pa2page.part.0>
ffffffffc0202fac:	fddfe0ef          	jal	ra,ffffffffc0201f88 <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202fb0:	00004697          	auipc	a3,0x4
ffffffffc0202fb4:	d4068693          	addi	a3,a3,-704 # ffffffffc0206cf0 <default_pmm_manager+0x378>
ffffffffc0202fb8:	00003617          	auipc	a2,0x3
ffffffffc0202fbc:	61060613          	addi	a2,a2,1552 # ffffffffc02065c8 <commands+0x858>
ffffffffc0202fc0:	2c600593          	li	a1,710
ffffffffc0202fc4:	00004517          	auipc	a0,0x4
ffffffffc0202fc8:	b0450513          	addi	a0,a0,-1276 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202fcc:	cc2fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202fd0:	00004697          	auipc	a3,0x4
ffffffffc0202fd4:	c6068693          	addi	a3,a3,-928 # ffffffffc0206c30 <default_pmm_manager+0x2b8>
ffffffffc0202fd8:	00003617          	auipc	a2,0x3
ffffffffc0202fdc:	5f060613          	addi	a2,a2,1520 # ffffffffc02065c8 <commands+0x858>
ffffffffc0202fe0:	2b500593          	li	a1,693
ffffffffc0202fe4:	00004517          	auipc	a0,0x4
ffffffffc0202fe8:	ae450513          	addi	a0,a0,-1308 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202fec:	ca2fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202ff0:	00004697          	auipc	a3,0x4
ffffffffc0202ff4:	c0068693          	addi	a3,a3,-1024 # ffffffffc0206bf0 <default_pmm_manager+0x278>
ffffffffc0202ff8:	00003617          	auipc	a2,0x3
ffffffffc0202ffc:	5d060613          	addi	a2,a2,1488 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203000:	2b300593          	li	a1,691
ffffffffc0203004:	00004517          	auipc	a0,0x4
ffffffffc0203008:	ac450513          	addi	a0,a0,-1340 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020300c:	c82fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203010:	00004697          	auipc	a3,0x4
ffffffffc0203014:	bc068693          	addi	a3,a3,-1088 # ffffffffc0206bd0 <default_pmm_manager+0x258>
ffffffffc0203018:	00003617          	auipc	a2,0x3
ffffffffc020301c:	5b060613          	addi	a2,a2,1456 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203020:	2b200593          	li	a1,690
ffffffffc0203024:	00004517          	auipc	a0,0x4
ffffffffc0203028:	aa450513          	addi	a0,a0,-1372 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020302c:	c62fd0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0203030:	00004617          	auipc	a2,0x4
ffffffffc0203034:	98060613          	addi	a2,a2,-1664 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0203038:	0bd00593          	li	a1,189
ffffffffc020303c:	00004517          	auipc	a0,0x4
ffffffffc0203040:	99c50513          	addi	a0,a0,-1636 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0203044:	c4afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0203048:	00004697          	auipc	a3,0x4
ffffffffc020304c:	e3868693          	addi	a3,a3,-456 # ffffffffc0206e80 <default_pmm_manager+0x508>
ffffffffc0203050:	00003617          	auipc	a2,0x3
ffffffffc0203054:	57860613          	addi	a2,a2,1400 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203058:	2e400593          	li	a1,740
ffffffffc020305c:	00004517          	auipc	a0,0x4
ffffffffc0203060:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203064:	c2afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203068:	00004697          	auipc	a3,0x4
ffffffffc020306c:	dd068693          	addi	a3,a3,-560 # ffffffffc0206e38 <default_pmm_manager+0x4c0>
ffffffffc0203070:	00003617          	auipc	a2,0x3
ffffffffc0203074:	55860613          	addi	a2,a2,1368 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203078:	2e100593          	li	a1,737
ffffffffc020307c:	00004517          	auipc	a0,0x4
ffffffffc0203080:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203084:	c0afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203088:	00004697          	auipc	a3,0x4
ffffffffc020308c:	de068693          	addi	a3,a3,-544 # ffffffffc0206e68 <default_pmm_manager+0x4f0>
ffffffffc0203090:	00003617          	auipc	a2,0x3
ffffffffc0203094:	53860613          	addi	a2,a2,1336 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203098:	2e000593          	li	a1,736
ffffffffc020309c:	00004517          	auipc	a0,0x4
ffffffffc02030a0:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02030a4:	beafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc02030a8:	00004697          	auipc	a3,0x4
ffffffffc02030ac:	ea868693          	addi	a3,a3,-344 # ffffffffc0206f50 <default_pmm_manager+0x5d8>
ffffffffc02030b0:	00003617          	auipc	a2,0x3
ffffffffc02030b4:	51860613          	addi	a2,a2,1304 # ffffffffc02065c8 <commands+0x858>
ffffffffc02030b8:	30300593          	li	a1,771
ffffffffc02030bc:	00004517          	auipc	a0,0x4
ffffffffc02030c0:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02030c4:	bcafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02030c8:	00004697          	auipc	a3,0x4
ffffffffc02030cc:	de868693          	addi	a3,a3,-536 # ffffffffc0206eb0 <default_pmm_manager+0x538>
ffffffffc02030d0:	00003617          	auipc	a2,0x3
ffffffffc02030d4:	4f860613          	addi	a2,a2,1272 # ffffffffc02065c8 <commands+0x858>
ffffffffc02030d8:	2ee00593          	li	a1,750
ffffffffc02030dc:	00004517          	auipc	a0,0x4
ffffffffc02030e0:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02030e4:	baafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p) == 1);
ffffffffc02030e8:	00004697          	auipc	a3,0x4
ffffffffc02030ec:	ec068693          	addi	a3,a3,-320 # ffffffffc0206fa8 <default_pmm_manager+0x630>
ffffffffc02030f0:	00003617          	auipc	a2,0x3
ffffffffc02030f4:	4d860613          	addi	a2,a2,1240 # ffffffffc02065c8 <commands+0x858>
ffffffffc02030f8:	30900593          	li	a1,777
ffffffffc02030fc:	00004517          	auipc	a0,0x4
ffffffffc0203100:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203104:	b8afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203108:	00004697          	auipc	a3,0x4
ffffffffc020310c:	e6068693          	addi	a3,a3,-416 # ffffffffc0206f68 <default_pmm_manager+0x5f0>
ffffffffc0203110:	00003617          	auipc	a2,0x3
ffffffffc0203114:	4b860613          	addi	a2,a2,1208 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203118:	30800593          	li	a1,776
ffffffffc020311c:	00004517          	auipc	a0,0x4
ffffffffc0203120:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203124:	b6afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203128:	00004697          	auipc	a3,0x4
ffffffffc020312c:	d1068693          	addi	a3,a3,-752 # ffffffffc0206e38 <default_pmm_manager+0x4c0>
ffffffffc0203130:	00003617          	auipc	a2,0x3
ffffffffc0203134:	49860613          	addi	a2,a2,1176 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203138:	2dc00593          	li	a1,732
ffffffffc020313c:	00004517          	auipc	a0,0x4
ffffffffc0203140:	98c50513          	addi	a0,a0,-1652 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203144:	b4afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203148:	00004697          	auipc	a3,0x4
ffffffffc020314c:	b9068693          	addi	a3,a3,-1136 # ffffffffc0206cd8 <default_pmm_manager+0x360>
ffffffffc0203150:	00003617          	auipc	a2,0x3
ffffffffc0203154:	47860613          	addi	a2,a2,1144 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203158:	2db00593          	li	a1,731
ffffffffc020315c:	00004517          	auipc	a0,0x4
ffffffffc0203160:	96c50513          	addi	a0,a0,-1684 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203164:	b2afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203168:	00004697          	auipc	a3,0x4
ffffffffc020316c:	ce868693          	addi	a3,a3,-792 # ffffffffc0206e50 <default_pmm_manager+0x4d8>
ffffffffc0203170:	00003617          	auipc	a2,0x3
ffffffffc0203174:	45860613          	addi	a2,a2,1112 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203178:	2d700593          	li	a1,727
ffffffffc020317c:	00004517          	auipc	a0,0x4
ffffffffc0203180:	94c50513          	addi	a0,a0,-1716 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203184:	b0afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203188:	00004697          	auipc	a3,0x4
ffffffffc020318c:	b3868693          	addi	a3,a3,-1224 # ffffffffc0206cc0 <default_pmm_manager+0x348>
ffffffffc0203190:	00003617          	auipc	a2,0x3
ffffffffc0203194:	43860613          	addi	a2,a2,1080 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203198:	2d600593          	li	a1,726
ffffffffc020319c:	00004517          	auipc	a0,0x4
ffffffffc02031a0:	92c50513          	addi	a0,a0,-1748 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02031a4:	aeafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02031a8:	00004697          	auipc	a3,0x4
ffffffffc02031ac:	bb868693          	addi	a3,a3,-1096 # ffffffffc0206d60 <default_pmm_manager+0x3e8>
ffffffffc02031b0:	00003617          	auipc	a2,0x3
ffffffffc02031b4:	41860613          	addi	a2,a2,1048 # ffffffffc02065c8 <commands+0x858>
ffffffffc02031b8:	2d500593          	li	a1,725
ffffffffc02031bc:	00004517          	auipc	a0,0x4
ffffffffc02031c0:	90c50513          	addi	a0,a0,-1780 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02031c4:	acafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0); // p2 被覆盖，引用归零
ffffffffc02031c8:	00004697          	auipc	a3,0x4
ffffffffc02031cc:	c7068693          	addi	a3,a3,-912 # ffffffffc0206e38 <default_pmm_manager+0x4c0>
ffffffffc02031d0:	00003617          	auipc	a2,0x3
ffffffffc02031d4:	3f860613          	addi	a2,a2,1016 # ffffffffc02065c8 <commands+0x858>
ffffffffc02031d8:	2d400593          	li	a1,724
ffffffffc02031dc:	00004517          	auipc	a0,0x4
ffffffffc02031e0:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02031e4:	aaafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 2); // p1 现在被映射了两次 (0x0 和 PGSIZE)
ffffffffc02031e8:	00004697          	auipc	a3,0x4
ffffffffc02031ec:	c3868693          	addi	a3,a3,-968 # ffffffffc0206e20 <default_pmm_manager+0x4a8>
ffffffffc02031f0:	00003617          	auipc	a2,0x3
ffffffffc02031f4:	3d860613          	addi	a2,a2,984 # ffffffffc02065c8 <commands+0x858>
ffffffffc02031f8:	2d300593          	li	a1,723
ffffffffc02031fc:	00004517          	auipc	a0,0x4
ffffffffc0203200:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203204:	a8afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0203208:	00004697          	auipc	a3,0x4
ffffffffc020320c:	be868693          	addi	a3,a3,-1048 # ffffffffc0206df0 <default_pmm_manager+0x478>
ffffffffc0203210:	00003617          	auipc	a2,0x3
ffffffffc0203214:	3b860613          	addi	a2,a2,952 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203218:	2d200593          	li	a1,722
ffffffffc020321c:	00004517          	auipc	a0,0x4
ffffffffc0203220:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203224:	a6afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203228:	00004697          	auipc	a3,0x4
ffffffffc020322c:	bb068693          	addi	a3,a3,-1104 # ffffffffc0206dd8 <default_pmm_manager+0x460>
ffffffffc0203230:	00003617          	auipc	a2,0x3
ffffffffc0203234:	39860613          	addi	a2,a2,920 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203238:	2cf00593          	li	a1,719
ffffffffc020323c:	00004517          	auipc	a0,0x4
ffffffffc0203240:	88c50513          	addi	a0,a0,-1908 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203244:	a4afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0203248:	00004697          	auipc	a3,0x4
ffffffffc020324c:	b7068693          	addi	a3,a3,-1168 # ffffffffc0206db8 <default_pmm_manager+0x440>
ffffffffc0203250:	00003617          	auipc	a2,0x3
ffffffffc0203254:	37860613          	addi	a2,a2,888 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203258:	2ce00593          	li	a1,718
ffffffffc020325c:	00004517          	auipc	a0,0x4
ffffffffc0203260:	86c50513          	addi	a0,a0,-1940 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203264:	a2afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203268:	00004697          	auipc	a3,0x4
ffffffffc020326c:	b4068693          	addi	a3,a3,-1216 # ffffffffc0206da8 <default_pmm_manager+0x430>
ffffffffc0203270:	00003617          	auipc	a2,0x3
ffffffffc0203274:	35860613          	addi	a2,a2,856 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203278:	2cd00593          	li	a1,717
ffffffffc020327c:	00004517          	auipc	a0,0x4
ffffffffc0203280:	84c50513          	addi	a0,a0,-1972 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203284:	a0afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203288:	00004697          	auipc	a3,0x4
ffffffffc020328c:	b1068693          	addi	a3,a3,-1264 # ffffffffc0206d98 <default_pmm_manager+0x420>
ffffffffc0203290:	00003617          	auipc	a2,0x3
ffffffffc0203294:	33860613          	addi	a2,a2,824 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203298:	2cc00593          	li	a1,716
ffffffffc020329c:	00004517          	auipc	a0,0x4
ffffffffc02032a0:	82c50513          	addi	a0,a0,-2004 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02032a4:	9eafd0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("DTB memory info not available");
ffffffffc02032a8:	00004617          	auipc	a2,0x4
ffffffffc02032ac:	89060613          	addi	a2,a2,-1904 # ffffffffc0206b38 <default_pmm_manager+0x1c0>
ffffffffc02032b0:	09500593          	li	a1,149
ffffffffc02032b4:	00004517          	auipc	a0,0x4
ffffffffc02032b8:	81450513          	addi	a0,a0,-2028 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02032bc:	9d2fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02032c0:	00004697          	auipc	a3,0x4
ffffffffc02032c4:	bf068693          	addi	a3,a3,-1040 # ffffffffc0206eb0 <default_pmm_manager+0x538>
ffffffffc02032c8:	00003617          	auipc	a2,0x3
ffffffffc02032cc:	30060613          	addi	a2,a2,768 # ffffffffc02065c8 <commands+0x858>
ffffffffc02032d0:	31d00593          	li	a1,797
ffffffffc02032d4:	00003517          	auipc	a0,0x3
ffffffffc02032d8:	7f450513          	addi	a0,a0,2036 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02032dc:	9b2fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02032e0:	00004697          	auipc	a3,0x4
ffffffffc02032e4:	a8068693          	addi	a3,a3,-1408 # ffffffffc0206d60 <default_pmm_manager+0x3e8>
ffffffffc02032e8:	00003617          	auipc	a2,0x3
ffffffffc02032ec:	2e060613          	addi	a2,a2,736 # ffffffffc02065c8 <commands+0x858>
ffffffffc02032f0:	2cb00593          	li	a1,715
ffffffffc02032f4:	00003517          	auipc	a0,0x3
ffffffffc02032f8:	7d450513          	addi	a0,a0,2004 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02032fc:	992fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203300:	00004697          	auipc	a3,0x4
ffffffffc0203304:	a2068693          	addi	a3,a3,-1504 # ffffffffc0206d20 <default_pmm_manager+0x3a8>
ffffffffc0203308:	00003617          	auipc	a2,0x3
ffffffffc020330c:	2c060613          	addi	a2,a2,704 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203310:	2ca00593          	li	a1,714
ffffffffc0203314:	00003517          	auipc	a0,0x3
ffffffffc0203318:	7b450513          	addi	a0,a0,1972 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020331c:	972fd0ef          	jal	ra,ffffffffc020048e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203320:	86d6                	mv	a3,s5
ffffffffc0203322:	00003617          	auipc	a2,0x3
ffffffffc0203326:	68e60613          	addi	a2,a2,1678 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc020332a:	2c500593          	li	a1,709
ffffffffc020332e:	00003517          	auipc	a0,0x3
ffffffffc0203332:	79a50513          	addi	a0,a0,1946 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203336:	958fd0ef          	jal	ra,ffffffffc020048e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020333a:	00003617          	auipc	a2,0x3
ffffffffc020333e:	67660613          	addi	a2,a2,1654 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0203342:	2c400593          	li	a1,708
ffffffffc0203346:	00003517          	auipc	a0,0x3
ffffffffc020334a:	78250513          	addi	a0,a0,1922 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020334e:	940fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203352:	00004697          	auipc	a3,0x4
ffffffffc0203356:	98668693          	addi	a3,a3,-1658 # ffffffffc0206cd8 <default_pmm_manager+0x360>
ffffffffc020335a:	00003617          	auipc	a2,0x3
ffffffffc020335e:	26e60613          	addi	a2,a2,622 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203362:	2c100593          	li	a1,705
ffffffffc0203366:	00003517          	auipc	a0,0x3
ffffffffc020336a:	76250513          	addi	a0,a0,1890 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020336e:	920fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203372:	00004697          	auipc	a3,0x4
ffffffffc0203376:	94e68693          	addi	a3,a3,-1714 # ffffffffc0206cc0 <default_pmm_manager+0x348>
ffffffffc020337a:	00003617          	auipc	a2,0x3
ffffffffc020337e:	24e60613          	addi	a2,a2,590 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203382:	2c000593          	li	a1,704
ffffffffc0203386:	00003517          	auipc	a0,0x3
ffffffffc020338a:	74250513          	addi	a0,a0,1858 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020338e:	900fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203392:	00004697          	auipc	a3,0x4
ffffffffc0203396:	cde68693          	addi	a3,a3,-802 # ffffffffc0207070 <default_pmm_manager+0x6f8>
ffffffffc020339a:	00003617          	auipc	a2,0x3
ffffffffc020339e:	22e60613          	addi	a2,a2,558 # ffffffffc02065c8 <commands+0x858>
ffffffffc02033a2:	31300593          	li	a1,787
ffffffffc02033a6:	00003517          	auipc	a0,0x3
ffffffffc02033aa:	72250513          	addi	a0,a0,1826 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02033ae:	8e0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02033b2:	00004697          	auipc	a3,0x4
ffffffffc02033b6:	c8668693          	addi	a3,a3,-890 # ffffffffc0207038 <default_pmm_manager+0x6c0>
ffffffffc02033ba:	00003617          	auipc	a2,0x3
ffffffffc02033be:	20e60613          	addi	a2,a2,526 # ffffffffc02065c8 <commands+0x858>
ffffffffc02033c2:	31000593          	li	a1,784
ffffffffc02033c6:	00003517          	auipc	a0,0x3
ffffffffc02033ca:	70250513          	addi	a0,a0,1794 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02033ce:	8c0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p) == 2);
ffffffffc02033d2:	00004697          	auipc	a3,0x4
ffffffffc02033d6:	c3668693          	addi	a3,a3,-970 # ffffffffc0207008 <default_pmm_manager+0x690>
ffffffffc02033da:	00003617          	auipc	a2,0x3
ffffffffc02033de:	1ee60613          	addi	a2,a2,494 # ffffffffc02065c8 <commands+0x858>
ffffffffc02033e2:	30b00593          	li	a1,779
ffffffffc02033e6:	00003517          	auipc	a0,0x3
ffffffffc02033ea:	6e250513          	addi	a0,a0,1762 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02033ee:	8a0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02033f2:	00004697          	auipc	a3,0x4
ffffffffc02033f6:	bce68693          	addi	a3,a3,-1074 # ffffffffc0206fc0 <default_pmm_manager+0x648>
ffffffffc02033fa:	00003617          	auipc	a2,0x3
ffffffffc02033fe:	1ce60613          	addi	a2,a2,462 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203402:	30a00593          	li	a1,778
ffffffffc0203406:	00003517          	auipc	a0,0x3
ffffffffc020340a:	6c250513          	addi	a0,a0,1730 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020340e:	880fd0ef          	jal	ra,ffffffffc020048e <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0203412:	00003617          	auipc	a2,0x3
ffffffffc0203416:	64660613          	addi	a2,a2,1606 # ffffffffc0206a58 <default_pmm_manager+0xe0>
ffffffffc020341a:	11400593          	li	a1,276
ffffffffc020341e:	00003517          	auipc	a0,0x3
ffffffffc0203422:	6aa50513          	addi	a0,a0,1706 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203426:	868fd0ef          	jal	ra,ffffffffc020048e <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020342a:	00003617          	auipc	a2,0x3
ffffffffc020342e:	62e60613          	addi	a2,a2,1582 # ffffffffc0206a58 <default_pmm_manager+0xe0>
ffffffffc0203432:	0be00593          	li	a1,190
ffffffffc0203436:	00003517          	auipc	a0,0x3
ffffffffc020343a:	69250513          	addi	a0,a0,1682 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020343e:	850fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203442:	00004697          	auipc	a3,0x4
ffffffffc0203446:	84e68693          	addi	a3,a3,-1970 # ffffffffc0206c90 <default_pmm_manager+0x318>
ffffffffc020344a:	00003617          	auipc	a2,0x3
ffffffffc020344e:	17e60613          	addi	a2,a2,382 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203452:	2bf00593          	li	a1,703
ffffffffc0203456:	00003517          	auipc	a0,0x3
ffffffffc020345a:	67250513          	addi	a0,a0,1650 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020345e:	830fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203462:	00003697          	auipc	a3,0x3
ffffffffc0203466:	7fe68693          	addi	a3,a3,2046 # ffffffffc0206c60 <default_pmm_manager+0x2e8>
ffffffffc020346a:	00003617          	auipc	a2,0x3
ffffffffc020346e:	15e60613          	addi	a2,a2,350 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203472:	2bb00593          	li	a1,699
ffffffffc0203476:	00003517          	auipc	a0,0x3
ffffffffc020347a:	65250513          	addi	a0,a0,1618 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020347e:	810fd0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203482 <copy_range>:
{
ffffffffc0203482:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203484:	00d667b3          	or	a5,a2,a3
{
ffffffffc0203488:	fc86                	sd	ra,120(sp)
ffffffffc020348a:	f8a2                	sd	s0,112(sp)
ffffffffc020348c:	f4a6                	sd	s1,104(sp)
ffffffffc020348e:	f0ca                	sd	s2,96(sp)
ffffffffc0203490:	ecce                	sd	s3,88(sp)
ffffffffc0203492:	e8d2                	sd	s4,80(sp)
ffffffffc0203494:	e4d6                	sd	s5,72(sp)
ffffffffc0203496:	e0da                	sd	s6,64(sp)
ffffffffc0203498:	fc5e                	sd	s7,56(sp)
ffffffffc020349a:	f862                	sd	s8,48(sp)
ffffffffc020349c:	f466                	sd	s9,40(sp)
ffffffffc020349e:	f06a                	sd	s10,32(sp)
ffffffffc02034a0:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02034a2:	17d2                	slli	a5,a5,0x34
ffffffffc02034a4:	20079f63          	bnez	a5,ffffffffc02036c2 <copy_range+0x240>
    assert(USER_ACCESS(start, end));
ffffffffc02034a8:	002007b7          	lui	a5,0x200
ffffffffc02034ac:	8432                	mv	s0,a2
ffffffffc02034ae:	1ef66a63          	bltu	a2,a5,ffffffffc02036a2 <copy_range+0x220>
ffffffffc02034b2:	84b6                	mv	s1,a3
ffffffffc02034b4:	1ed67763          	bgeu	a2,a3,ffffffffc02036a2 <copy_range+0x220>
ffffffffc02034b8:	4785                	li	a5,1
ffffffffc02034ba:	07fe                	slli	a5,a5,0x1f
ffffffffc02034bc:	1ed7e363          	bltu	a5,a3,ffffffffc02036a2 <copy_range+0x220>
ffffffffc02034c0:	5c7d                	li	s8,-1
ffffffffc02034c2:	00cc5793          	srli	a5,s8,0xc
ffffffffc02034c6:	8a2a                	mv	s4,a0
ffffffffc02034c8:	892e                	mv	s2,a1
ffffffffc02034ca:	8aba                	mv	s5,a4
        start += PGSIZE;
ffffffffc02034cc:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage)
ffffffffc02034ce:	000d4b97          	auipc	s7,0xd4
ffffffffc02034d2:	912b8b93          	addi	s7,s7,-1774 # ffffffffc02d6de0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02034d6:	000d4b17          	auipc	s6,0xd4
ffffffffc02034da:	912b0b13          	addi	s6,s6,-1774 # ffffffffc02d6de8 <pages>
ffffffffc02034de:	fff80cb7          	lui	s9,0xfff80
    return KADDR(page2pa(page));
ffffffffc02034e2:	e03e                	sd	a5,0(sp)
        page = pmm_manager->alloc_pages(n);
ffffffffc02034e4:	000d4d17          	auipc	s10,0xd4
ffffffffc02034e8:	90cd0d13          	addi	s10,s10,-1780 # ffffffffc02d6df0 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02034ec:	4601                	li	a2,0
ffffffffc02034ee:	85a2                	mv	a1,s0
ffffffffc02034f0:	854a                	mv	a0,s2
ffffffffc02034f2:	b6bfe0ef          	jal	ra,ffffffffc020205c <get_pte>
ffffffffc02034f6:	8c2a                	mv	s8,a0
        if (ptep == NULL)
ffffffffc02034f8:	c945                	beqz	a0,ffffffffc02035a8 <copy_range+0x126>
        if (*ptep & PTE_V)
ffffffffc02034fa:	6118                	ld	a4,0(a0)
ffffffffc02034fc:	8b05                	andi	a4,a4,1
ffffffffc02034fe:	e705                	bnez	a4,ffffffffc0203526 <copy_range+0xa4>
        start += PGSIZE;
ffffffffc0203500:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0203502:	fe9465e3          	bltu	s0,s1,ffffffffc02034ec <copy_range+0x6a>
    return 0;
ffffffffc0203506:	4501                	li	a0,0
}
ffffffffc0203508:	70e6                	ld	ra,120(sp)
ffffffffc020350a:	7446                	ld	s0,112(sp)
ffffffffc020350c:	74a6                	ld	s1,104(sp)
ffffffffc020350e:	7906                	ld	s2,96(sp)
ffffffffc0203510:	69e6                	ld	s3,88(sp)
ffffffffc0203512:	6a46                	ld	s4,80(sp)
ffffffffc0203514:	6aa6                	ld	s5,72(sp)
ffffffffc0203516:	6b06                	ld	s6,64(sp)
ffffffffc0203518:	7be2                	ld	s7,56(sp)
ffffffffc020351a:	7c42                	ld	s8,48(sp)
ffffffffc020351c:	7ca2                	ld	s9,40(sp)
ffffffffc020351e:	7d02                	ld	s10,32(sp)
ffffffffc0203520:	6de2                	ld	s11,24(sp)
ffffffffc0203522:	6109                	addi	sp,sp,128
ffffffffc0203524:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0203526:	4605                	li	a2,1
ffffffffc0203528:	85a2                	mv	a1,s0
ffffffffc020352a:	8552                	mv	a0,s4
ffffffffc020352c:	b31fe0ef          	jal	ra,ffffffffc020205c <get_pte>
ffffffffc0203530:	12050f63          	beqz	a0,ffffffffc020366e <copy_range+0x1ec>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203534:	000c3783          	ld	a5,0(s8)
    if (!(pte & PTE_V))
ffffffffc0203538:	0017f613          	andi	a2,a5,1
ffffffffc020353c:	0007871b          	sext.w	a4,a5
ffffffffc0203540:	01f7fc13          	andi	s8,a5,31
ffffffffc0203544:	14060363          	beqz	a2,ffffffffc020368a <copy_range+0x208>
    if (PPN(pa) >= npage)
ffffffffc0203548:	000bb603          	ld	a2,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc020354c:	078a                	slli	a5,a5,0x2
ffffffffc020354e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203550:	12c7f163          	bgeu	a5,a2,ffffffffc0203672 <copy_range+0x1f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0203554:	000b3583          	ld	a1,0(s6)
ffffffffc0203558:	97e6                	add	a5,a5,s9
ffffffffc020355a:	079a                	slli	a5,a5,0x6
ffffffffc020355c:	95be                	add	a1,a1,a5
            if (share)
ffffffffc020355e:	040a8f63          	beqz	s5,ffffffffc02035bc <copy_range+0x13a>
                if (perm & PTE_W) {
ffffffffc0203562:	00477793          	andi	a5,a4,4
ffffffffc0203566:	cb99                	beqz	a5,ffffffffc020357c <copy_range+0xfa>
                    perm &= ~PTE_W;
ffffffffc0203568:	01b77c13          	andi	s8,a4,27
                    ret = page_insert(from, page, start, perm);
ffffffffc020356c:	86e2                	mv	a3,s8
ffffffffc020356e:	8622                	mv	a2,s0
ffffffffc0203570:	854a                	mv	a0,s2
ffffffffc0203572:	e42e                	sd	a1,8(sp)
ffffffffc0203574:	9d8ff0ef          	jal	ra,ffffffffc020274c <page_insert>
                    if (ret != 0) return ret;
ffffffffc0203578:	65a2                	ld	a1,8(sp)
ffffffffc020357a:	f559                	bnez	a0,ffffffffc0203508 <copy_range+0x86>
                ret = page_insert(to, page, start, perm);
ffffffffc020357c:	86e2                	mv	a3,s8
ffffffffc020357e:	8622                	mv	a2,s0
ffffffffc0203580:	8552                	mv	a0,s4
ffffffffc0203582:	9caff0ef          	jal	ra,ffffffffc020274c <page_insert>
                assert(ret == 0);
ffffffffc0203586:	dd2d                	beqz	a0,ffffffffc0203500 <copy_range+0x7e>
ffffffffc0203588:	00004697          	auipc	a3,0x4
ffffffffc020358c:	b3068693          	addi	a3,a3,-1232 # ffffffffc02070b8 <default_pmm_manager+0x740>
ffffffffc0203590:	00003617          	auipc	a2,0x3
ffffffffc0203594:	03860613          	addi	a2,a2,56 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203598:	22900593          	li	a1,553
ffffffffc020359c:	00003517          	auipc	a0,0x3
ffffffffc02035a0:	52c50513          	addi	a0,a0,1324 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02035a4:	eebfc0ef          	jal	ra,ffffffffc020048e <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02035a8:	00200637          	lui	a2,0x200
ffffffffc02035ac:	9432                	add	s0,s0,a2
ffffffffc02035ae:	ffe00637          	lui	a2,0xffe00
ffffffffc02035b2:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc02035b4:	d829                	beqz	s0,ffffffffc0203506 <copy_range+0x84>
ffffffffc02035b6:	f2946be3          	bltu	s0,s1,ffffffffc02034ec <copy_range+0x6a>
ffffffffc02035ba:	b7b1                	j	ffffffffc0203506 <copy_range+0x84>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02035bc:	100027f3          	csrr	a5,sstatus
ffffffffc02035c0:	8b89                	andi	a5,a5,2
ffffffffc02035c2:	e42e                	sd	a1,8(sp)
ffffffffc02035c4:	ebc9                	bnez	a5,ffffffffc0203656 <copy_range+0x1d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc02035c6:	000d3783          	ld	a5,0(s10)
ffffffffc02035ca:	4505                	li	a0,1
ffffffffc02035cc:	6f9c                	ld	a5,24(a5)
ffffffffc02035ce:	9782                	jalr	a5
ffffffffc02035d0:	65a2                	ld	a1,8(sp)
ffffffffc02035d2:	8daa                	mv	s11,a0
                assert(page != NULL);
ffffffffc02035d4:	10058763          	beqz	a1,ffffffffc02036e2 <copy_range+0x260>
                assert(npage != NULL);
ffffffffc02035d8:	140d8f63          	beqz	s11,ffffffffc0203736 <copy_range+0x2b4>
    return page - pages + nbase;
ffffffffc02035dc:	000b3703          	ld	a4,0(s6)
    return KADDR(page2pa(page));
ffffffffc02035e0:	6682                	ld	a3,0(sp)
    return page - pages + nbase;
ffffffffc02035e2:	000808b7          	lui	a7,0x80
ffffffffc02035e6:	40e587b3          	sub	a5,a1,a4
ffffffffc02035ea:	8799                	srai	a5,a5,0x6
    return KADDR(page2pa(page));
ffffffffc02035ec:	000bb603          	ld	a2,0(s7)
    return page - pages + nbase;
ffffffffc02035f0:	97c6                	add	a5,a5,a7
    return KADDR(page2pa(page));
ffffffffc02035f2:	00d7f5b3          	and	a1,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02035f6:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02035f8:	12c5f263          	bgeu	a1,a2,ffffffffc020371c <copy_range+0x29a>
ffffffffc02035fc:	000d3697          	auipc	a3,0xd3
ffffffffc0203600:	7fc68693          	addi	a3,a3,2044 # ffffffffc02d6df8 <va_pa_offset>
ffffffffc0203604:	6288                	ld	a0,0(a3)
    return page - pages + nbase;
ffffffffc0203606:	40ed8733          	sub	a4,s11,a4
    return KADDR(page2pa(page));
ffffffffc020360a:	6682                	ld	a3,0(sp)
    return page - pages + nbase;
ffffffffc020360c:	8719                	srai	a4,a4,0x6
ffffffffc020360e:	9746                	add	a4,a4,a7
    return KADDR(page2pa(page));
ffffffffc0203610:	00d778b3          	and	a7,a4,a3
ffffffffc0203614:	00a785b3          	add	a1,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203618:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc020361a:	0ec8f463          	bgeu	a7,a2,ffffffffc0203702 <copy_range+0x280>
                memcpy(kva_dst, kva_src, PGSIZE);
ffffffffc020361e:	6605                	lui	a2,0x1
ffffffffc0203620:	953a                	add	a0,a0,a4
ffffffffc0203622:	4c8020ef          	jal	ra,ffffffffc0205aea <memcpy>
                ret = page_insert(to, npage, start, perm);
ffffffffc0203626:	86e2                	mv	a3,s8
ffffffffc0203628:	8622                	mv	a2,s0
ffffffffc020362a:	85ee                	mv	a1,s11
ffffffffc020362c:	8552                	mv	a0,s4
ffffffffc020362e:	91eff0ef          	jal	ra,ffffffffc020274c <page_insert>
                assert(ret == 0);
ffffffffc0203632:	ec0507e3          	beqz	a0,ffffffffc0203500 <copy_range+0x7e>
ffffffffc0203636:	00004697          	auipc	a3,0x4
ffffffffc020363a:	a8268693          	addi	a3,a3,-1406 # ffffffffc02070b8 <default_pmm_manager+0x740>
ffffffffc020363e:	00003617          	auipc	a2,0x3
ffffffffc0203642:	f8a60613          	addi	a2,a2,-118 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203646:	23f00593          	li	a1,575
ffffffffc020364a:	00003517          	auipc	a0,0x3
ffffffffc020364e:	47e50513          	addi	a0,a0,1150 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203652:	e3dfc0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_disable();
ffffffffc0203656:	b5efd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020365a:	000d3783          	ld	a5,0(s10)
ffffffffc020365e:	4505                	li	a0,1
ffffffffc0203660:	6f9c                	ld	a5,24(a5)
ffffffffc0203662:	9782                	jalr	a5
ffffffffc0203664:	8daa                	mv	s11,a0
        intr_enable();
ffffffffc0203666:	b48fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020366a:	65a2                	ld	a1,8(sp)
ffffffffc020366c:	b7a5                	j	ffffffffc02035d4 <copy_range+0x152>
                return -E_NO_MEM; // 内存不足
ffffffffc020366e:	5571                	li	a0,-4
ffffffffc0203670:	bd61                	j	ffffffffc0203508 <copy_range+0x86>
        panic("pa2page called with invalid pa");
ffffffffc0203672:	00003617          	auipc	a2,0x3
ffffffffc0203676:	40e60613          	addi	a2,a2,1038 # ffffffffc0206a80 <default_pmm_manager+0x108>
ffffffffc020367a:	0b200593          	li	a1,178
ffffffffc020367e:	00003517          	auipc	a0,0x3
ffffffffc0203682:	35a50513          	addi	a0,a0,858 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0203686:	e09fc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020368a:	00003617          	auipc	a2,0x3
ffffffffc020368e:	41660613          	addi	a2,a2,1046 # ffffffffc0206aa0 <default_pmm_manager+0x128>
ffffffffc0203692:	0cf00593          	li	a1,207
ffffffffc0203696:	00003517          	auipc	a0,0x3
ffffffffc020369a:	34250513          	addi	a0,a0,834 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc020369e:	df1fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02036a2:	00003697          	auipc	a3,0x3
ffffffffc02036a6:	46668693          	addi	a3,a3,1126 # ffffffffc0206b08 <default_pmm_manager+0x190>
ffffffffc02036aa:	00003617          	auipc	a2,0x3
ffffffffc02036ae:	f1e60613          	addi	a2,a2,-226 # ffffffffc02065c8 <commands+0x858>
ffffffffc02036b2:	1f800593          	li	a1,504
ffffffffc02036b6:	00003517          	auipc	a0,0x3
ffffffffc02036ba:	41250513          	addi	a0,a0,1042 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02036be:	dd1fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02036c2:	00003697          	auipc	a3,0x3
ffffffffc02036c6:	41668693          	addi	a3,a3,1046 # ffffffffc0206ad8 <default_pmm_manager+0x160>
ffffffffc02036ca:	00003617          	auipc	a2,0x3
ffffffffc02036ce:	efe60613          	addi	a2,a2,-258 # ffffffffc02065c8 <commands+0x858>
ffffffffc02036d2:	1f700593          	li	a1,503
ffffffffc02036d6:	00003517          	auipc	a0,0x3
ffffffffc02036da:	3f250513          	addi	a0,a0,1010 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02036de:	db1fc0ef          	jal	ra,ffffffffc020048e <__panic>
                assert(page != NULL);
ffffffffc02036e2:	00004697          	auipc	a3,0x4
ffffffffc02036e6:	9e668693          	addi	a3,a3,-1562 # ffffffffc02070c8 <default_pmm_manager+0x750>
ffffffffc02036ea:	00003617          	auipc	a2,0x3
ffffffffc02036ee:	ede60613          	addi	a2,a2,-290 # ffffffffc02065c8 <commands+0x858>
ffffffffc02036f2:	23300593          	li	a1,563
ffffffffc02036f6:	00003517          	auipc	a0,0x3
ffffffffc02036fa:	3d250513          	addi	a0,a0,978 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02036fe:	d91fc0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0203702:	86ba                	mv	a3,a4
ffffffffc0203704:	00003617          	auipc	a2,0x3
ffffffffc0203708:	2ac60613          	addi	a2,a2,684 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc020370c:	0bd00593          	li	a1,189
ffffffffc0203710:	00003517          	auipc	a0,0x3
ffffffffc0203714:	2c850513          	addi	a0,a0,712 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0203718:	d77fc0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc020371c:	86be                	mv	a3,a5
ffffffffc020371e:	00003617          	auipc	a2,0x3
ffffffffc0203722:	29260613          	addi	a2,a2,658 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0203726:	0bd00593          	li	a1,189
ffffffffc020372a:	00003517          	auipc	a0,0x3
ffffffffc020372e:	2ae50513          	addi	a0,a0,686 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0203732:	d5dfc0ef          	jal	ra,ffffffffc020048e <__panic>
                assert(npage != NULL);
ffffffffc0203736:	00004697          	auipc	a3,0x4
ffffffffc020373a:	9a268693          	addi	a3,a3,-1630 # ffffffffc02070d8 <default_pmm_manager+0x760>
ffffffffc020373e:	00003617          	auipc	a2,0x3
ffffffffc0203742:	e8a60613          	addi	a2,a2,-374 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203746:	23400593          	li	a1,564
ffffffffc020374a:	00003517          	auipc	a0,0x3
ffffffffc020374e:	37e50513          	addi	a0,a0,894 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203752:	d3dfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203756 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203756:	12058073          	sfence.vma	a1
}
ffffffffc020375a:	8082                	ret

ffffffffc020375c <pgdir_alloc_page>:
{
ffffffffc020375c:	7179                	addi	sp,sp,-48
ffffffffc020375e:	ec26                	sd	s1,24(sp)
ffffffffc0203760:	e84a                	sd	s2,16(sp)
ffffffffc0203762:	e052                	sd	s4,0(sp)
ffffffffc0203764:	f406                	sd	ra,40(sp)
ffffffffc0203766:	f022                	sd	s0,32(sp)
ffffffffc0203768:	e44e                	sd	s3,8(sp)
ffffffffc020376a:	8a2a                	mv	s4,a0
ffffffffc020376c:	84ae                	mv	s1,a1
ffffffffc020376e:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203770:	100027f3          	csrr	a5,sstatus
ffffffffc0203774:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc0203776:	000d3997          	auipc	s3,0xd3
ffffffffc020377a:	67a98993          	addi	s3,s3,1658 # ffffffffc02d6df0 <pmm_manager>
ffffffffc020377e:	ef8d                	bnez	a5,ffffffffc02037b8 <pgdir_alloc_page+0x5c>
ffffffffc0203780:	0009b783          	ld	a5,0(s3)
ffffffffc0203784:	4505                	li	a0,1
ffffffffc0203786:	6f9c                	ld	a5,24(a5)
ffffffffc0203788:	9782                	jalr	a5
ffffffffc020378a:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc020378c:	cc09                	beqz	s0,ffffffffc02037a6 <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc020378e:	86ca                	mv	a3,s2
ffffffffc0203790:	8626                	mv	a2,s1
ffffffffc0203792:	85a2                	mv	a1,s0
ffffffffc0203794:	8552                	mv	a0,s4
ffffffffc0203796:	fb7fe0ef          	jal	ra,ffffffffc020274c <page_insert>
ffffffffc020379a:	e915                	bnez	a0,ffffffffc02037ce <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc020379c:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc020379e:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc02037a0:	4785                	li	a5,1
ffffffffc02037a2:	04f71e63          	bne	a4,a5,ffffffffc02037fe <pgdir_alloc_page+0xa2>
}
ffffffffc02037a6:	70a2                	ld	ra,40(sp)
ffffffffc02037a8:	8522                	mv	a0,s0
ffffffffc02037aa:	7402                	ld	s0,32(sp)
ffffffffc02037ac:	64e2                	ld	s1,24(sp)
ffffffffc02037ae:	6942                	ld	s2,16(sp)
ffffffffc02037b0:	69a2                	ld	s3,8(sp)
ffffffffc02037b2:	6a02                	ld	s4,0(sp)
ffffffffc02037b4:	6145                	addi	sp,sp,48
ffffffffc02037b6:	8082                	ret
        intr_disable();
ffffffffc02037b8:	9fcfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02037bc:	0009b783          	ld	a5,0(s3)
ffffffffc02037c0:	4505                	li	a0,1
ffffffffc02037c2:	6f9c                	ld	a5,24(a5)
ffffffffc02037c4:	9782                	jalr	a5
ffffffffc02037c6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02037c8:	9e6fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02037cc:	b7c1                	j	ffffffffc020378c <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02037ce:	100027f3          	csrr	a5,sstatus
ffffffffc02037d2:	8b89                	andi	a5,a5,2
ffffffffc02037d4:	eb89                	bnez	a5,ffffffffc02037e6 <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc02037d6:	0009b783          	ld	a5,0(s3)
ffffffffc02037da:	8522                	mv	a0,s0
ffffffffc02037dc:	4585                	li	a1,1
ffffffffc02037de:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02037e0:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02037e2:	9782                	jalr	a5
    if (flag)
ffffffffc02037e4:	b7c9                	j	ffffffffc02037a6 <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc02037e6:	9cefd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02037ea:	0009b783          	ld	a5,0(s3)
ffffffffc02037ee:	8522                	mv	a0,s0
ffffffffc02037f0:	4585                	li	a1,1
ffffffffc02037f2:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02037f4:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02037f6:	9782                	jalr	a5
        intr_enable();
ffffffffc02037f8:	9b6fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02037fc:	b76d                	j	ffffffffc02037a6 <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc02037fe:	00004697          	auipc	a3,0x4
ffffffffc0203802:	8ea68693          	addi	a3,a3,-1814 # ffffffffc02070e8 <default_pmm_manager+0x770>
ffffffffc0203806:	00003617          	auipc	a2,0x3
ffffffffc020380a:	dc260613          	addi	a2,a2,-574 # ffffffffc02065c8 <commands+0x858>
ffffffffc020380e:	29c00593          	li	a1,668
ffffffffc0203812:	00003517          	auipc	a0,0x3
ffffffffc0203816:	2b650513          	addi	a0,a0,694 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020381a:	c75fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020381e <check_vma_overlap.part.0>:
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
// 检查两个 VMA 是否重叠（断言检查）
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc020381e:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    // 前一个 VMA 的结束必须小于等于后一个 VMA 的开始
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203820:	00004697          	auipc	a3,0x4
ffffffffc0203824:	8e068693          	addi	a3,a3,-1824 # ffffffffc0207100 <default_pmm_manager+0x788>
ffffffffc0203828:	00003617          	auipc	a2,0x3
ffffffffc020382c:	da060613          	addi	a2,a2,-608 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203830:	08e00593          	li	a1,142
ffffffffc0203834:	00004517          	auipc	a0,0x4
ffffffffc0203838:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0207120 <default_pmm_manager+0x7a8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc020383c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020383e:	c51fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203842 <mm_create>:
{
ffffffffc0203842:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203844:	04000513          	li	a0,64
{
ffffffffc0203848:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020384a:	d7cfe0ef          	jal	ra,ffffffffc0201dc6 <kmalloc>
    if (mm != NULL)
ffffffffc020384e:	cd19                	beqz	a0,ffffffffc020386c <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc0203850:	e508                	sd	a0,8(a0)
ffffffffc0203852:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203854:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203858:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020385c:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203860:	02053423          	sd	zero,40(a0)

// 内联函数：设置 mm 的引用计数
static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc0203864:	02052823          	sw	zero,48(a0)
    *lock = 0;
ffffffffc0203868:	02053c23          	sd	zero,56(a0)
}
ffffffffc020386c:	60a2                	ld	ra,8(sp)
ffffffffc020386e:	0141                	addi	sp,sp,16
ffffffffc0203870:	8082                	ret

ffffffffc0203872 <find_vma>:
{
ffffffffc0203872:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc0203874:	c505                	beqz	a0,ffffffffc020389c <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203876:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203878:	c501                	beqz	a0,ffffffffc0203880 <find_vma+0xe>
ffffffffc020387a:	651c                	ld	a5,8(a0)
ffffffffc020387c:	02f5f263          	bgeu	a1,a5,ffffffffc02038a0 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203880:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc0203882:	00f68d63          	beq	a3,a5,ffffffffc020389c <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0203886:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_obj___user_exit_out_size+0x1f4d18>
ffffffffc020388a:	00e5e663          	bltu	a1,a4,ffffffffc0203896 <find_vma+0x24>
ffffffffc020388e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203892:	00e5ec63          	bltu	a1,a4,ffffffffc02038aa <find_vma+0x38>
ffffffffc0203896:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0203898:	fef697e3          	bne	a3,a5,ffffffffc0203886 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc020389c:	4501                	li	a0,0
}
ffffffffc020389e:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02038a0:	691c                	ld	a5,16(a0)
ffffffffc02038a2:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203880 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc02038a6:	ea88                	sd	a0,16(a3)
ffffffffc02038a8:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc02038aa:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc02038ae:	ea88                	sd	a0,16(a3)
ffffffffc02038b0:	8082                	ret

ffffffffc02038b2 <insert_vma_struct>:

// insert_vma_struct -insert vma in mm's list link
// 将一个新的 VMA 插入到 mm 的链表中（按地址排序）
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc02038b2:	6590                	ld	a2,8(a1)
ffffffffc02038b4:	0105b803          	ld	a6,16(a1)
{
ffffffffc02038b8:	1141                	addi	sp,sp,-16
ffffffffc02038ba:	e406                	sd	ra,8(sp)
ffffffffc02038bc:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02038be:	01066763          	bltu	a2,a6,ffffffffc02038cc <insert_vma_struct+0x1a>
ffffffffc02038c2:	a085                	j	ffffffffc0203922 <insert_vma_struct+0x70>
    // 寻找插入位置：找到第一个起始地址大于 vma->vm_start 的节点
    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02038c4:	fe87b703          	ld	a4,-24(a5)
ffffffffc02038c8:	04e66863          	bltu	a2,a4,ffffffffc0203918 <insert_vma_struct+0x66>
ffffffffc02038cc:	86be                	mv	a3,a5
ffffffffc02038ce:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc02038d0:	fef51ae3          	bne	a0,a5,ffffffffc02038c4 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap - 检查是否与前后节点重叠 */
    if (le_prev != list)
ffffffffc02038d4:	02a68463          	beq	a3,a0,ffffffffc02038fc <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02038d8:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02038dc:	fe86b883          	ld	a7,-24(a3)
ffffffffc02038e0:	08e8f163          	bgeu	a7,a4,ffffffffc0203962 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02038e4:	04e66f63          	bltu	a2,a4,ffffffffc0203942 <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc02038e8:	00f50a63          	beq	a0,a5,ffffffffc02038fc <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02038ec:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02038f0:	05076963          	bltu	a4,a6,ffffffffc0203942 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02038f4:	ff07b603          	ld	a2,-16(a5)
ffffffffc02038f8:	02c77363          	bgeu	a4,a2,ffffffffc020391e <insert_vma_struct+0x6c>
    vma->vm_mm = mm;
    // 将 vma 插入到 le_prev 之后
    list_add_after(le_prev, &(vma->list_link));

    // 增加 mm 中的映射计数
    mm->map_count++;
ffffffffc02038fc:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02038fe:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203900:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203904:	e390                	sd	a2,0(a5)
ffffffffc0203906:	e690                	sd	a2,8(a3)
}
ffffffffc0203908:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020390a:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020390c:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc020390e:	0017079b          	addiw	a5,a4,1
ffffffffc0203912:	d11c                	sw	a5,32(a0)
}
ffffffffc0203914:	0141                	addi	sp,sp,16
ffffffffc0203916:	8082                	ret
    if (le_prev != list)
ffffffffc0203918:	fca690e3          	bne	a3,a0,ffffffffc02038d8 <insert_vma_struct+0x26>
ffffffffc020391c:	bfd1                	j	ffffffffc02038f0 <insert_vma_struct+0x3e>
ffffffffc020391e:	f01ff0ef          	jal	ra,ffffffffc020381e <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203922:	00004697          	auipc	a3,0x4
ffffffffc0203926:	80e68693          	addi	a3,a3,-2034 # ffffffffc0207130 <default_pmm_manager+0x7b8>
ffffffffc020392a:	00003617          	auipc	a2,0x3
ffffffffc020392e:	c9e60613          	addi	a2,a2,-866 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203932:	09500593          	li	a1,149
ffffffffc0203936:	00003517          	auipc	a0,0x3
ffffffffc020393a:	7ea50513          	addi	a0,a0,2026 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc020393e:	b51fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203942:	00004697          	auipc	a3,0x4
ffffffffc0203946:	82e68693          	addi	a3,a3,-2002 # ffffffffc0207170 <default_pmm_manager+0x7f8>
ffffffffc020394a:	00003617          	auipc	a2,0x3
ffffffffc020394e:	c7e60613          	addi	a2,a2,-898 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203952:	08d00593          	li	a1,141
ffffffffc0203956:	00003517          	auipc	a0,0x3
ffffffffc020395a:	7ca50513          	addi	a0,a0,1994 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc020395e:	b31fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203962:	00003697          	auipc	a3,0x3
ffffffffc0203966:	7ee68693          	addi	a3,a3,2030 # ffffffffc0207150 <default_pmm_manager+0x7d8>
ffffffffc020396a:	00003617          	auipc	a2,0x3
ffffffffc020396e:	c5e60613          	addi	a2,a2,-930 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203972:	08b00593          	li	a1,139
ffffffffc0203976:	00003517          	auipc	a0,0x3
ffffffffc020397a:	7aa50513          	addi	a0,a0,1962 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc020397e:	b11fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203982 <mm_destroy>:
// mm_destroy - free mm and mm internal fields
// 销毁 mm_struct 及其挂载的所有 vma_struct
void mm_destroy(struct mm_struct *mm)
{
    // 确保此时引用计数为 0
    assert(mm_count(mm) == 0);
ffffffffc0203982:	591c                	lw	a5,48(a0)
{
ffffffffc0203984:	1141                	addi	sp,sp,-16
ffffffffc0203986:	e406                	sd	ra,8(sp)
ffffffffc0203988:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc020398a:	e78d                	bnez	a5,ffffffffc02039b4 <mm_destroy+0x32>
ffffffffc020398c:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020398e:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    // 遍历并删除所有 VMA
    while ((le = list_next(list)) != list)
ffffffffc0203990:	00a40c63          	beq	s0,a0,ffffffffc02039a8 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203994:	6118                	ld	a4,0(a0)
ffffffffc0203996:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // 释放 vma 结构体内存
ffffffffc0203998:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020399a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020399c:	e398                	sd	a4,0(a5)
ffffffffc020399e:	cd8fe0ef          	jal	ra,ffffffffc0201e76 <kfree>
    return listelm->next;
ffffffffc02039a2:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc02039a4:	fea418e3          	bne	s0,a0,ffffffffc0203994 <mm_destroy+0x12>
    }
    kfree(mm); // 释放 mm 结构体内存
ffffffffc02039a8:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc02039aa:	6402                	ld	s0,0(sp)
ffffffffc02039ac:	60a2                	ld	ra,8(sp)
ffffffffc02039ae:	0141                	addi	sp,sp,16
    kfree(mm); // 释放 mm 结构体内存
ffffffffc02039b0:	cc6fe06f          	j	ffffffffc0201e76 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02039b4:	00003697          	auipc	a3,0x3
ffffffffc02039b8:	7dc68693          	addi	a3,a3,2012 # ffffffffc0207190 <default_pmm_manager+0x818>
ffffffffc02039bc:	00003617          	auipc	a2,0x3
ffffffffc02039c0:	c0c60613          	addi	a2,a2,-1012 # ffffffffc02065c8 <commands+0x858>
ffffffffc02039c4:	0bf00593          	li	a1,191
ffffffffc02039c8:	00003517          	auipc	a0,0x3
ffffffffc02039cc:	75850513          	addi	a0,a0,1880 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc02039d0:	abffc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02039d4 <mm_map>:

// mm_map - 建立一段虚拟地址映射（创建 VMA 并插入）
int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc02039d4:	7139                	addi	sp,sp,-64
ffffffffc02039d6:	f822                	sd	s0,48(sp)
    // 地址对齐
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02039d8:	6405                	lui	s0,0x1
ffffffffc02039da:	147d                	addi	s0,s0,-1
ffffffffc02039dc:	77fd                	lui	a5,0xfffff
ffffffffc02039de:	9622                	add	a2,a2,s0
ffffffffc02039e0:	962e                	add	a2,a2,a1
{
ffffffffc02039e2:	f426                	sd	s1,40(sp)
ffffffffc02039e4:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02039e6:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc02039ea:	f04a                	sd	s2,32(sp)
ffffffffc02039ec:	ec4e                	sd	s3,24(sp)
ffffffffc02039ee:	e852                	sd	s4,16(sp)
ffffffffc02039f0:	e456                	sd	s5,8(sp)
    // 检查是否超出用户空间范围
    if (!USER_ACCESS(start, end))
ffffffffc02039f2:	002005b7          	lui	a1,0x200
ffffffffc02039f6:	00f67433          	and	s0,a2,a5
ffffffffc02039fa:	06b4e363          	bltu	s1,a1,ffffffffc0203a60 <mm_map+0x8c>
ffffffffc02039fe:	0684f163          	bgeu	s1,s0,ffffffffc0203a60 <mm_map+0x8c>
ffffffffc0203a02:	4785                	li	a5,1
ffffffffc0203a04:	07fe                	slli	a5,a5,0x1f
ffffffffc0203a06:	0487ed63          	bltu	a5,s0,ffffffffc0203a60 <mm_map+0x8c>
ffffffffc0203a0a:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0203a0c:	cd21                	beqz	a0,ffffffffc0203a64 <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    // 检查新区域是否与现有 VMA 重叠
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc0203a0e:	85a6                	mv	a1,s1
ffffffffc0203a10:	8ab6                	mv	s5,a3
ffffffffc0203a12:	8a3a                	mv	s4,a4
ffffffffc0203a14:	e5fff0ef          	jal	ra,ffffffffc0203872 <find_vma>
ffffffffc0203a18:	c501                	beqz	a0,ffffffffc0203a20 <mm_map+0x4c>
ffffffffc0203a1a:	651c                	ld	a5,8(a0)
ffffffffc0203a1c:	0487e263          	bltu	a5,s0,ffffffffc0203a60 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a20:	03000513          	li	a0,48
ffffffffc0203a24:	ba2fe0ef          	jal	ra,ffffffffc0201dc6 <kmalloc>
ffffffffc0203a28:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0203a2a:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc0203a2c:	02090163          	beqz	s2,ffffffffc0203a4e <mm_map+0x7a>
    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    // 插入 mm
    insert_vma_struct(mm, vma);
ffffffffc0203a30:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0203a32:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0203a36:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0203a3a:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0203a3e:	85ca                	mv	a1,s2
ffffffffc0203a40:	e73ff0ef          	jal	ra,ffffffffc02038b2 <insert_vma_struct>
    // 如果需要返回 vma 指针
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0203a44:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc0203a46:	000a0463          	beqz	s4,ffffffffc0203a4e <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0203a4a:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0203a4e:	70e2                	ld	ra,56(sp)
ffffffffc0203a50:	7442                	ld	s0,48(sp)
ffffffffc0203a52:	74a2                	ld	s1,40(sp)
ffffffffc0203a54:	7902                	ld	s2,32(sp)
ffffffffc0203a56:	69e2                	ld	s3,24(sp)
ffffffffc0203a58:	6a42                	ld	s4,16(sp)
ffffffffc0203a5a:	6aa2                	ld	s5,8(sp)
ffffffffc0203a5c:	6121                	addi	sp,sp,64
ffffffffc0203a5e:	8082                	ret
        return -E_INVAL;
ffffffffc0203a60:	5575                	li	a0,-3
ffffffffc0203a62:	b7f5                	j	ffffffffc0203a4e <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0203a64:	00003697          	auipc	a3,0x3
ffffffffc0203a68:	74468693          	addi	a3,a3,1860 # ffffffffc02071a8 <default_pmm_manager+0x830>
ffffffffc0203a6c:	00003617          	auipc	a2,0x3
ffffffffc0203a70:	b5c60613          	addi	a2,a2,-1188 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203a74:	0d800593          	li	a1,216
ffffffffc0203a78:	00003517          	auipc	a0,0x3
ffffffffc0203a7c:	6a850513          	addi	a0,a0,1704 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203a80:	a0ffc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203a84 <dup_mmap>:

// dup_mmap - 复制内存映射 (fork 时使用)
// 将 from 的内存布局复制给 to
int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0203a84:	7139                	addi	sp,sp,-64
ffffffffc0203a86:	fc06                	sd	ra,56(sp)
ffffffffc0203a88:	f822                	sd	s0,48(sp)
ffffffffc0203a8a:	f426                	sd	s1,40(sp)
ffffffffc0203a8c:	f04a                	sd	s2,32(sp)
ffffffffc0203a8e:	ec4e                	sd	s3,24(sp)
ffffffffc0203a90:	e852                	sd	s4,16(sp)
ffffffffc0203a92:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0203a94:	c52d                	beqz	a0,ffffffffc0203afe <dup_mmap+0x7a>
ffffffffc0203a96:	892a                	mv	s2,a0
ffffffffc0203a98:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0203a9a:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0203a9c:	e595                	bnez	a1,ffffffffc0203ac8 <dup_mmap+0x44>
ffffffffc0203a9e:	a085                	j	ffffffffc0203afe <dup_mmap+0x7a>
        {
            return -E_NO_MEM;
        }

        // 插入子进程的 mm
        insert_vma_struct(to, nvma);
ffffffffc0203aa0:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0203aa2:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4d38>
        vma->vm_end = vm_end;
ffffffffc0203aa6:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0203aaa:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0203aae:	e05ff0ef          	jal	ra,ffffffffc02038b2 <insert_vma_struct>

        // 复制页表内容 (核心逻辑在 copy_range 中)
        // bool share = 1 表示启用共享 (Copy on Write)
        bool share = 1;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0203ab2:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8d70>
ffffffffc0203ab6:	fe843603          	ld	a2,-24(s0)
ffffffffc0203aba:	6c8c                	ld	a1,24(s1)
ffffffffc0203abc:	01893503          	ld	a0,24(s2)
ffffffffc0203ac0:	4705                	li	a4,1
ffffffffc0203ac2:	9c1ff0ef          	jal	ra,ffffffffc0203482 <copy_range>
ffffffffc0203ac6:	e105                	bnez	a0,ffffffffc0203ae6 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0203ac8:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0203aca:	02848863          	beq	s1,s0,ffffffffc0203afa <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203ace:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0203ad2:	fe843a83          	ld	s5,-24(s0)
ffffffffc0203ad6:	ff043a03          	ld	s4,-16(s0)
ffffffffc0203ada:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203ade:	ae8fe0ef          	jal	ra,ffffffffc0201dc6 <kmalloc>
ffffffffc0203ae2:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc0203ae4:	fd55                	bnez	a0,ffffffffc0203aa0 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0203ae6:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0203ae8:	70e2                	ld	ra,56(sp)
ffffffffc0203aea:	7442                	ld	s0,48(sp)
ffffffffc0203aec:	74a2                	ld	s1,40(sp)
ffffffffc0203aee:	7902                	ld	s2,32(sp)
ffffffffc0203af0:	69e2                	ld	s3,24(sp)
ffffffffc0203af2:	6a42                	ld	s4,16(sp)
ffffffffc0203af4:	6aa2                	ld	s5,8(sp)
ffffffffc0203af6:	6121                	addi	sp,sp,64
ffffffffc0203af8:	8082                	ret
    return 0;
ffffffffc0203afa:	4501                	li	a0,0
ffffffffc0203afc:	b7f5                	j	ffffffffc0203ae8 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0203afe:	00003697          	auipc	a3,0x3
ffffffffc0203b02:	6ba68693          	addi	a3,a3,1722 # ffffffffc02071b8 <default_pmm_manager+0x840>
ffffffffc0203b06:	00003617          	auipc	a2,0x3
ffffffffc0203b0a:	ac260613          	addi	a2,a2,-1342 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203b0e:	0fa00593          	li	a1,250
ffffffffc0203b12:	00003517          	auipc	a0,0x3
ffffffffc0203b16:	60e50513          	addi	a0,a0,1550 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203b1a:	975fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203b1e <exit_mmap>:

// exit_mmap - 进程退出时释放内存资源
void exit_mmap(struct mm_struct *mm)
{
ffffffffc0203b1e:	1101                	addi	sp,sp,-32
ffffffffc0203b20:	ec06                	sd	ra,24(sp)
ffffffffc0203b22:	e822                	sd	s0,16(sp)
ffffffffc0203b24:	e426                	sd	s1,8(sp)
ffffffffc0203b26:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203b28:	c531                	beqz	a0,ffffffffc0203b74 <exit_mmap+0x56>
ffffffffc0203b2a:	591c                	lw	a5,48(a0)
ffffffffc0203b2c:	84aa                	mv	s1,a0
ffffffffc0203b2e:	e3b9                	bnez	a5,ffffffffc0203b74 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0203b30:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0203b32:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    // 第一遍遍历：取消所有页面的映射 (unmap_range)
    // 这会释放物理页的引用计数，如果归零则释放物理页
    while ((le = list_next(le)) != list)
ffffffffc0203b36:	02850663          	beq	a0,s0,ffffffffc0203b62 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203b3a:	ff043603          	ld	a2,-16(s0)
ffffffffc0203b3e:	fe843583          	ld	a1,-24(s0)
ffffffffc0203b42:	854a                	mv	a0,s2
ffffffffc0203b44:	f94fe0ef          	jal	ra,ffffffffc02022d8 <unmap_range>
ffffffffc0203b48:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203b4a:	fe8498e3          	bne	s1,s0,ffffffffc0203b3a <exit_mmap+0x1c>
ffffffffc0203b4e:	6400                	ld	s0,8(s0)
    }
    // 第二遍遍历：释放页表本身占用的内存 (exit_range)
    while ((le = list_next(le)) != list)
ffffffffc0203b50:	00848c63          	beq	s1,s0,ffffffffc0203b68 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203b54:	ff043603          	ld	a2,-16(s0)
ffffffffc0203b58:	fe843583          	ld	a1,-24(s0)
ffffffffc0203b5c:	854a                	mv	a0,s2
ffffffffc0203b5e:	8c1fe0ef          	jal	ra,ffffffffc020241e <exit_range>
ffffffffc0203b62:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203b64:	fe8498e3          	bne	s1,s0,ffffffffc0203b54 <exit_mmap+0x36>
    }
}
ffffffffc0203b68:	60e2                	ld	ra,24(sp)
ffffffffc0203b6a:	6442                	ld	s0,16(sp)
ffffffffc0203b6c:	64a2                	ld	s1,8(sp)
ffffffffc0203b6e:	6902                	ld	s2,0(sp)
ffffffffc0203b70:	6105                	addi	sp,sp,32
ffffffffc0203b72:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203b74:	00003697          	auipc	a3,0x3
ffffffffc0203b78:	66468693          	addi	a3,a3,1636 # ffffffffc02071d8 <default_pmm_manager+0x860>
ffffffffc0203b7c:	00003617          	auipc	a2,0x3
ffffffffc0203b80:	a4c60613          	addi	a2,a2,-1460 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203b84:	11900593          	li	a1,281
ffffffffc0203b88:	00003517          	auipc	a0,0x3
ffffffffc0203b8c:	59850513          	addi	a0,a0,1432 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203b90:	8fffc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203b94 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203b94:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203b96:	04000513          	li	a0,64
{
ffffffffc0203b9a:	fc06                	sd	ra,56(sp)
ffffffffc0203b9c:	f822                	sd	s0,48(sp)
ffffffffc0203b9e:	f426                	sd	s1,40(sp)
ffffffffc0203ba0:	f04a                	sd	s2,32(sp)
ffffffffc0203ba2:	ec4e                	sd	s3,24(sp)
ffffffffc0203ba4:	e852                	sd	s4,16(sp)
ffffffffc0203ba6:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203ba8:	a1efe0ef          	jal	ra,ffffffffc0201dc6 <kmalloc>
    if (mm != NULL)
ffffffffc0203bac:	2e050663          	beqz	a0,ffffffffc0203e98 <vmm_init+0x304>
ffffffffc0203bb0:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0203bb2:	e508                	sd	a0,8(a0)
ffffffffc0203bb4:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203bb6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203bba:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203bbe:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203bc2:	02053423          	sd	zero,40(a0)
ffffffffc0203bc6:	02052823          	sw	zero,48(a0)
ffffffffc0203bca:	02053c23          	sd	zero,56(a0)
ffffffffc0203bce:	03200413          	li	s0,50
ffffffffc0203bd2:	a811                	j	ffffffffc0203be6 <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc0203bd4:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203bd6:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203bd8:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    // 逆序插入
    for (i = step1; i >= 1; i--)
ffffffffc0203bdc:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203bde:	8526                	mv	a0,s1
ffffffffc0203be0:	cd3ff0ef          	jal	ra,ffffffffc02038b2 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0203be4:	c80d                	beqz	s0,ffffffffc0203c16 <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203be6:	03000513          	li	a0,48
ffffffffc0203bea:	9dcfe0ef          	jal	ra,ffffffffc0201dc6 <kmalloc>
ffffffffc0203bee:	85aa                	mv	a1,a0
ffffffffc0203bf0:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203bf4:	f165                	bnez	a0,ffffffffc0203bd4 <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc0203bf6:	00003697          	auipc	a3,0x3
ffffffffc0203bfa:	77a68693          	addi	a3,a3,1914 # ffffffffc0207370 <default_pmm_manager+0x9f8>
ffffffffc0203bfe:	00003617          	auipc	a2,0x3
ffffffffc0203c02:	9ca60613          	addi	a2,a2,-1590 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203c06:	16900593          	li	a1,361
ffffffffc0203c0a:	00003517          	auipc	a0,0x3
ffffffffc0203c0e:	51650513          	addi	a0,a0,1302 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203c12:	87dfc0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0203c16:	03700413          	li	s0,55
    }

    // 正序插入
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203c1a:	1f900913          	li	s2,505
ffffffffc0203c1e:	a819                	j	ffffffffc0203c34 <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc0203c20:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203c22:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203c24:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203c28:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203c2a:	8526                	mv	a0,s1
ffffffffc0203c2c:	c87ff0ef          	jal	ra,ffffffffc02038b2 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203c30:	03240a63          	beq	s0,s2,ffffffffc0203c64 <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203c34:	03000513          	li	a0,48
ffffffffc0203c38:	98efe0ef          	jal	ra,ffffffffc0201dc6 <kmalloc>
ffffffffc0203c3c:	85aa                	mv	a1,a0
ffffffffc0203c3e:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203c42:	fd79                	bnez	a0,ffffffffc0203c20 <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc0203c44:	00003697          	auipc	a3,0x3
ffffffffc0203c48:	72c68693          	addi	a3,a3,1836 # ffffffffc0207370 <default_pmm_manager+0x9f8>
ffffffffc0203c4c:	00003617          	auipc	a2,0x3
ffffffffc0203c50:	97c60613          	addi	a2,a2,-1668 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203c54:	17100593          	li	a1,369
ffffffffc0203c58:	00003517          	auipc	a0,0x3
ffffffffc0203c5c:	4c850513          	addi	a0,a0,1224 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203c60:	82ffc0ef          	jal	ra,ffffffffc020048e <__panic>
    return listelm->next;
ffffffffc0203c64:	649c                	ld	a5,8(s1)
ffffffffc0203c66:	471d                	li	a4,7
    }

    // 检查链表顺序是否正确（应当是升序）
    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203c68:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203c6c:	16f48663          	beq	s1,a5,ffffffffc0203dd8 <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203c70:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd281bc>
ffffffffc0203c74:	ffe70693          	addi	a3,a4,-2 # ffe <_binary_obj___user_faultread_out_size-0x8d62>
ffffffffc0203c78:	10d61063          	bne	a2,a3,ffffffffc0203d78 <vmm_init+0x1e4>
ffffffffc0203c7c:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203c80:	0ed71c63          	bne	a4,a3,ffffffffc0203d78 <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc0203c84:	0715                	addi	a4,a4,5
ffffffffc0203c86:	679c                	ld	a5,8(a5)
ffffffffc0203c88:	feb712e3          	bne	a4,a1,ffffffffc0203c6c <vmm_init+0xd8>
ffffffffc0203c8c:	4a1d                	li	s4,7
ffffffffc0203c8e:	4415                	li	s0,5
        le = list_next(le);
    }

    // 检查 find_vma 功能
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203c90:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203c94:	85a2                	mv	a1,s0
ffffffffc0203c96:	8526                	mv	a0,s1
ffffffffc0203c98:	bdbff0ef          	jal	ra,ffffffffc0203872 <find_vma>
ffffffffc0203c9c:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203c9e:	16050d63          	beqz	a0,ffffffffc0203e18 <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203ca2:	00140593          	addi	a1,s0,1
ffffffffc0203ca6:	8526                	mv	a0,s1
ffffffffc0203ca8:	bcbff0ef          	jal	ra,ffffffffc0203872 <find_vma>
ffffffffc0203cac:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203cae:	14050563          	beqz	a0,ffffffffc0203df8 <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203cb2:	85d2                	mv	a1,s4
ffffffffc0203cb4:	8526                	mv	a0,s1
ffffffffc0203cb6:	bbdff0ef          	jal	ra,ffffffffc0203872 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203cba:	16051f63          	bnez	a0,ffffffffc0203e38 <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203cbe:	00340593          	addi	a1,s0,3
ffffffffc0203cc2:	8526                	mv	a0,s1
ffffffffc0203cc4:	bafff0ef          	jal	ra,ffffffffc0203872 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203cc8:	1a051863          	bnez	a0,ffffffffc0203e78 <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203ccc:	00440593          	addi	a1,s0,4
ffffffffc0203cd0:	8526                	mv	a0,s1
ffffffffc0203cd2:	ba1ff0ef          	jal	ra,ffffffffc0203872 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203cd6:	18051163          	bnez	a0,ffffffffc0203e58 <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203cda:	00893783          	ld	a5,8(s2)
ffffffffc0203cde:	0a879d63          	bne	a5,s0,ffffffffc0203d98 <vmm_init+0x204>
ffffffffc0203ce2:	01093783          	ld	a5,16(s2)
ffffffffc0203ce6:	0b479963          	bne	a5,s4,ffffffffc0203d98 <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203cea:	0089b783          	ld	a5,8(s3)
ffffffffc0203cee:	0c879563          	bne	a5,s0,ffffffffc0203db8 <vmm_init+0x224>
ffffffffc0203cf2:	0109b783          	ld	a5,16(s3)
ffffffffc0203cf6:	0d479163          	bne	a5,s4,ffffffffc0203db8 <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203cfa:	0415                	addi	s0,s0,5
ffffffffc0203cfc:	0a15                	addi	s4,s4,5
ffffffffc0203cfe:	f9541be3          	bne	s0,s5,ffffffffc0203c94 <vmm_init+0x100>
ffffffffc0203d02:	4411                	li	s0,4
    }

    // 检查边界
    for (i = 4; i >= 0; i--)
ffffffffc0203d04:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203d06:	85a2                	mv	a1,s0
ffffffffc0203d08:	8526                	mv	a0,s1
ffffffffc0203d0a:	b69ff0ef          	jal	ra,ffffffffc0203872 <find_vma>
ffffffffc0203d0e:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203d12:	c90d                	beqz	a0,ffffffffc0203d44 <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203d14:	6914                	ld	a3,16(a0)
ffffffffc0203d16:	6510                	ld	a2,8(a0)
ffffffffc0203d18:	00003517          	auipc	a0,0x3
ffffffffc0203d1c:	5e050513          	addi	a0,a0,1504 # ffffffffc02072f8 <default_pmm_manager+0x980>
ffffffffc0203d20:	c74fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203d24:	00003697          	auipc	a3,0x3
ffffffffc0203d28:	5fc68693          	addi	a3,a3,1532 # ffffffffc0207320 <default_pmm_manager+0x9a8>
ffffffffc0203d2c:	00003617          	auipc	a2,0x3
ffffffffc0203d30:	89c60613          	addi	a2,a2,-1892 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203d34:	19a00593          	li	a1,410
ffffffffc0203d38:	00003517          	auipc	a0,0x3
ffffffffc0203d3c:	3e850513          	addi	a0,a0,1000 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203d40:	f4efc0ef          	jal	ra,ffffffffc020048e <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203d44:	147d                	addi	s0,s0,-1
ffffffffc0203d46:	fd2410e3          	bne	s0,s2,ffffffffc0203d06 <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc0203d4a:	8526                	mv	a0,s1
ffffffffc0203d4c:	c37ff0ef          	jal	ra,ffffffffc0203982 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203d50:	00003517          	auipc	a0,0x3
ffffffffc0203d54:	5e850513          	addi	a0,a0,1512 # ffffffffc0207338 <default_pmm_manager+0x9c0>
ffffffffc0203d58:	c3cfc0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0203d5c:	7442                	ld	s0,48(sp)
ffffffffc0203d5e:	70e2                	ld	ra,56(sp)
ffffffffc0203d60:	74a2                	ld	s1,40(sp)
ffffffffc0203d62:	7902                	ld	s2,32(sp)
ffffffffc0203d64:	69e2                	ld	s3,24(sp)
ffffffffc0203d66:	6a42                	ld	s4,16(sp)
ffffffffc0203d68:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d6a:	00003517          	auipc	a0,0x3
ffffffffc0203d6e:	5ee50513          	addi	a0,a0,1518 # ffffffffc0207358 <default_pmm_manager+0x9e0>
}
ffffffffc0203d72:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d74:	c20fc06f          	j	ffffffffc0200194 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203d78:	00003697          	auipc	a3,0x3
ffffffffc0203d7c:	49868693          	addi	a3,a3,1176 # ffffffffc0207210 <default_pmm_manager+0x898>
ffffffffc0203d80:	00003617          	auipc	a2,0x3
ffffffffc0203d84:	84860613          	addi	a2,a2,-1976 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203d88:	17c00593          	li	a1,380
ffffffffc0203d8c:	00003517          	auipc	a0,0x3
ffffffffc0203d90:	39450513          	addi	a0,a0,916 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203d94:	efafc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203d98:	00003697          	auipc	a3,0x3
ffffffffc0203d9c:	50068693          	addi	a3,a3,1280 # ffffffffc0207298 <default_pmm_manager+0x920>
ffffffffc0203da0:	00003617          	auipc	a2,0x3
ffffffffc0203da4:	82860613          	addi	a2,a2,-2008 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203da8:	18e00593          	li	a1,398
ffffffffc0203dac:	00003517          	auipc	a0,0x3
ffffffffc0203db0:	37450513          	addi	a0,a0,884 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203db4:	edafc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203db8:	00003697          	auipc	a3,0x3
ffffffffc0203dbc:	51068693          	addi	a3,a3,1296 # ffffffffc02072c8 <default_pmm_manager+0x950>
ffffffffc0203dc0:	00003617          	auipc	a2,0x3
ffffffffc0203dc4:	80860613          	addi	a2,a2,-2040 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203dc8:	18f00593          	li	a1,399
ffffffffc0203dcc:	00003517          	auipc	a0,0x3
ffffffffc0203dd0:	35450513          	addi	a0,a0,852 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203dd4:	ebafc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203dd8:	00003697          	auipc	a3,0x3
ffffffffc0203ddc:	42068693          	addi	a3,a3,1056 # ffffffffc02071f8 <default_pmm_manager+0x880>
ffffffffc0203de0:	00002617          	auipc	a2,0x2
ffffffffc0203de4:	7e860613          	addi	a2,a2,2024 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203de8:	17a00593          	li	a1,378
ffffffffc0203dec:	00003517          	auipc	a0,0x3
ffffffffc0203df0:	33450513          	addi	a0,a0,820 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203df4:	e9afc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma2 != NULL);
ffffffffc0203df8:	00003697          	auipc	a3,0x3
ffffffffc0203dfc:	46068693          	addi	a3,a3,1120 # ffffffffc0207258 <default_pmm_manager+0x8e0>
ffffffffc0203e00:	00002617          	auipc	a2,0x2
ffffffffc0203e04:	7c860613          	addi	a2,a2,1992 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203e08:	18600593          	li	a1,390
ffffffffc0203e0c:	00003517          	auipc	a0,0x3
ffffffffc0203e10:	31450513          	addi	a0,a0,788 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203e14:	e7afc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma1 != NULL);
ffffffffc0203e18:	00003697          	auipc	a3,0x3
ffffffffc0203e1c:	43068693          	addi	a3,a3,1072 # ffffffffc0207248 <default_pmm_manager+0x8d0>
ffffffffc0203e20:	00002617          	auipc	a2,0x2
ffffffffc0203e24:	7a860613          	addi	a2,a2,1960 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203e28:	18400593          	li	a1,388
ffffffffc0203e2c:	00003517          	auipc	a0,0x3
ffffffffc0203e30:	2f450513          	addi	a0,a0,756 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203e34:	e5afc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma3 == NULL);
ffffffffc0203e38:	00003697          	auipc	a3,0x3
ffffffffc0203e3c:	43068693          	addi	a3,a3,1072 # ffffffffc0207268 <default_pmm_manager+0x8f0>
ffffffffc0203e40:	00002617          	auipc	a2,0x2
ffffffffc0203e44:	78860613          	addi	a2,a2,1928 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203e48:	18800593          	li	a1,392
ffffffffc0203e4c:	00003517          	auipc	a0,0x3
ffffffffc0203e50:	2d450513          	addi	a0,a0,724 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203e54:	e3afc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma5 == NULL);
ffffffffc0203e58:	00003697          	auipc	a3,0x3
ffffffffc0203e5c:	43068693          	addi	a3,a3,1072 # ffffffffc0207288 <default_pmm_manager+0x910>
ffffffffc0203e60:	00002617          	auipc	a2,0x2
ffffffffc0203e64:	76860613          	addi	a2,a2,1896 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203e68:	18c00593          	li	a1,396
ffffffffc0203e6c:	00003517          	auipc	a0,0x3
ffffffffc0203e70:	2b450513          	addi	a0,a0,692 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203e74:	e1afc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma4 == NULL);
ffffffffc0203e78:	00003697          	auipc	a3,0x3
ffffffffc0203e7c:	40068693          	addi	a3,a3,1024 # ffffffffc0207278 <default_pmm_manager+0x900>
ffffffffc0203e80:	00002617          	auipc	a2,0x2
ffffffffc0203e84:	74860613          	addi	a2,a2,1864 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203e88:	18a00593          	li	a1,394
ffffffffc0203e8c:	00003517          	auipc	a0,0x3
ffffffffc0203e90:	29450513          	addi	a0,a0,660 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203e94:	dfafc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(mm != NULL);
ffffffffc0203e98:	00003697          	auipc	a3,0x3
ffffffffc0203e9c:	31068693          	addi	a3,a3,784 # ffffffffc02071a8 <default_pmm_manager+0x830>
ffffffffc0203ea0:	00002617          	auipc	a2,0x2
ffffffffc0203ea4:	72860613          	addi	a2,a2,1832 # ffffffffc02065c8 <commands+0x858>
ffffffffc0203ea8:	16000593          	li	a1,352
ffffffffc0203eac:	00003517          	auipc	a0,0x3
ffffffffc0203eb0:	27450513          	addi	a0,a0,628 # ffffffffc0207120 <default_pmm_manager+0x7a8>
ffffffffc0203eb4:	ddafc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203eb8 <user_mem_check>:
}

// user_mem_check - 检查一段用户空间内存是否合法且具有相应权限
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203eb8:	7179                	addi	sp,sp,-48
ffffffffc0203eba:	f022                	sd	s0,32(sp)
ffffffffc0203ebc:	f406                	sd	ra,40(sp)
ffffffffc0203ebe:	ec26                	sd	s1,24(sp)
ffffffffc0203ec0:	e84a                	sd	s2,16(sp)
ffffffffc0203ec2:	e44e                	sd	s3,8(sp)
ffffffffc0203ec4:	e052                	sd	s4,0(sp)
ffffffffc0203ec6:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203ec8:	c135                	beqz	a0,ffffffffc0203f2c <user_mem_check+0x74>
    {
        // 检查地址是否都在用户空间范围内
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203eca:	002007b7          	lui	a5,0x200
ffffffffc0203ece:	04f5e663          	bltu	a1,a5,ffffffffc0203f1a <user_mem_check+0x62>
ffffffffc0203ed2:	00c584b3          	add	s1,a1,a2
ffffffffc0203ed6:	0495f263          	bgeu	a1,s1,ffffffffc0203f1a <user_mem_check+0x62>
ffffffffc0203eda:	4785                	li	a5,1
ffffffffc0203edc:	07fe                	slli	a5,a5,0x1f
ffffffffc0203ede:	0297ee63          	bltu	a5,s1,ffffffffc0203f1a <user_mem_check+0x62>
ffffffffc0203ee2:	892a                	mv	s2,a0
ffffffffc0203ee4:	89b6                	mv	s3,a3
                return 0;
            }
            // 如果是栈操作，做额外的栈检查 (uCore 中简单的栈增长检查)
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203ee6:	6a05                	lui	s4,0x1
ffffffffc0203ee8:	a821                	j	ffffffffc0203f00 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203eea:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203eee:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203ef0:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203ef2:	c685                	beqz	a3,ffffffffc0203f1a <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203ef4:	c399                	beqz	a5,ffffffffc0203efa <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203ef6:	02e46263          	bltu	s0,a4,ffffffffc0203f1a <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            // 跳到当前 VMA 的结束，继续检查下一段
            start = vma->vm_end;
ffffffffc0203efa:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203efc:	04947663          	bgeu	s0,s1,ffffffffc0203f48 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203f00:	85a2                	mv	a1,s0
ffffffffc0203f02:	854a                	mv	a0,s2
ffffffffc0203f04:	96fff0ef          	jal	ra,ffffffffc0203872 <find_vma>
ffffffffc0203f08:	c909                	beqz	a0,ffffffffc0203f1a <user_mem_check+0x62>
ffffffffc0203f0a:	6518                	ld	a4,8(a0)
ffffffffc0203f0c:	00e46763          	bltu	s0,a4,ffffffffc0203f1a <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203f10:	4d1c                	lw	a5,24(a0)
ffffffffc0203f12:	fc099ce3          	bnez	s3,ffffffffc0203eea <user_mem_check+0x32>
ffffffffc0203f16:	8b85                	andi	a5,a5,1
ffffffffc0203f18:	f3ed                	bnez	a5,ffffffffc0203efa <user_mem_check+0x42>
            return 0;
ffffffffc0203f1a:	4501                	li	a0,0
        }
        return 1;
    }
    // 如果是内核线程，直接检查是否在内核地址空间
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0203f1c:	70a2                	ld	ra,40(sp)
ffffffffc0203f1e:	7402                	ld	s0,32(sp)
ffffffffc0203f20:	64e2                	ld	s1,24(sp)
ffffffffc0203f22:	6942                	ld	s2,16(sp)
ffffffffc0203f24:	69a2                	ld	s3,8(sp)
ffffffffc0203f26:	6a02                	ld	s4,0(sp)
ffffffffc0203f28:	6145                	addi	sp,sp,48
ffffffffc0203f2a:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203f2c:	c02007b7          	lui	a5,0xc0200
ffffffffc0203f30:	4501                	li	a0,0
ffffffffc0203f32:	fef5e5e3          	bltu	a1,a5,ffffffffc0203f1c <user_mem_check+0x64>
ffffffffc0203f36:	962e                	add	a2,a2,a1
ffffffffc0203f38:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203f1c <user_mem_check+0x64>
ffffffffc0203f3c:	c8000537          	lui	a0,0xc8000
ffffffffc0203f40:	0505                	addi	a0,a0,1
ffffffffc0203f42:	00a63533          	sltu	a0,a2,a0
ffffffffc0203f46:	bfd9                	j	ffffffffc0203f1c <user_mem_check+0x64>
        return 1;
ffffffffc0203f48:	4505                	li	a0,1
ffffffffc0203f4a:	bfc9                	j	ffffffffc0203f1c <user_mem_check+0x64>

ffffffffc0203f4c <do_pgfault>:

// do_pgfault - 处理缺页异常的核心函数
// mm: 进程内存描述符
// error_code: 异常错误码 (标识读/写/不存在等)
// addr: 触发异常的虚拟地址
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203f4c:	715d                	addi	sp,sp,-80
ffffffffc0203f4e:	fc26                	sd	s1,56(sp)
ffffffffc0203f50:	84ae                	mv	s1,a1
    int ret = -E_INVAL;
    // 查找包含 addr 的 VMA
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203f52:	85b2                	mv	a1,a2
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203f54:	f84a                	sd	s2,48(sp)
ffffffffc0203f56:	f44e                	sd	s3,40(sp)
ffffffffc0203f58:	e486                	sd	ra,72(sp)
ffffffffc0203f5a:	e0a2                	sd	s0,64(sp)
ffffffffc0203f5c:	f052                	sd	s4,32(sp)
ffffffffc0203f5e:	ec56                	sd	s5,24(sp)
ffffffffc0203f60:	e85a                	sd	s6,16(sp)
ffffffffc0203f62:	e45e                	sd	s7,8(sp)
ffffffffc0203f64:	e062                	sd	s8,0(sp)
ffffffffc0203f66:	8932                	mv	s2,a2
ffffffffc0203f68:	89aa                	mv	s3,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203f6a:	909ff0ef          	jal	ra,ffffffffc0203872 <find_vma>

    // 统计缺页次数
    pgfault_num++; 
ffffffffc0203f6e:	000d3797          	auipc	a5,0xd3
ffffffffc0203f72:	e9a7a783          	lw	a5,-358(a5) # ffffffffc02d6e08 <pgfault_num>
ffffffffc0203f76:	2785                	addiw	a5,a5,1
ffffffffc0203f78:	000d3717          	auipc	a4,0xd3
ffffffffc0203f7c:	e8f72823          	sw	a5,-368(a4) # ffffffffc02d6e08 <pgfault_num>

    // 如果地址不在任何 VMA 范围内，说明是无效访问 (Segfault)
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203f80:	18050b63          	beqz	a0,ffffffffc0204116 <do_pgfault+0x1ca>
ffffffffc0203f84:	651c                	ld	a5,8(a0)
ffffffffc0203f86:	842a                	mv	s0,a0
ffffffffc0203f88:	18f96763          	bltu	s2,a5,ffffffffc0204116 <do_pgfault+0x1ca>
        return -E_INVAL;
    }

    // 权限检查：如果尝试写一个不可写的 VMA，直接报错
    if ((error_code & 2) && !(vma->vm_flags & VM_WRITE)) {
ffffffffc0203f8c:	4d1c                	lw	a5,24(a0)
ffffffffc0203f8e:	8889                	andi	s1,s1,2
ffffffffc0203f90:	0027f713          	andi	a4,a5,2
ffffffffc0203f94:	12049a63          	bnez	s1,ffffffffc02040c8 <do_pgfault+0x17c>
        return -E_INVAL;
    }

    // 根据 VMA 属性构建需要的页表权限 perm
    uint32_t perm = PTE_U; // 用户态权限
ffffffffc0203f98:	4ac1                	li	s5,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203f9a:	12071863          	bnez	a4,ffffffffc02040ca <do_pgfault+0x17e>
        perm |= (PTE_R | PTE_W);
    }
    if (vma->vm_flags & VM_READ) {
ffffffffc0203f9e:	0017f713          	andi	a4,a5,1
ffffffffc0203fa2:	c319                	beqz	a4,ffffffffc0203fa8 <do_pgfault+0x5c>
        perm |= PTE_R;
ffffffffc0203fa4:	002aea93          	ori	s5,s5,2
    }
    if (vma->vm_flags & VM_EXEC) {
ffffffffc0203fa8:	8b91                	andi	a5,a5,4
ffffffffc0203faa:	c399                	beqz	a5,ffffffffc0203fb0 <do_pgfault+0x64>
        perm |= PTE_X;
ffffffffc0203fac:	008aea93          	ori	s5,s5,8
    }

    // 将地址向下对齐到页边界
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203fb0:	767d                	lui	a2,0xfffff
    ret = -E_NO_MEM;
    pte_t *ptep = NULL;

    // 获取对应的页表项 (PTE)，如果中间页表不存在则分配 (create=1)
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203fb2:	0189b503          	ld	a0,24(s3)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203fb6:	00c97933          	and	s2,s2,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203fba:	85ca                	mv	a1,s2
ffffffffc0203fbc:	4605                	li	a2,1
ffffffffc0203fbe:	89efe0ef          	jal	ra,ffffffffc020205c <get_pte>
ffffffffc0203fc2:	8a2a                	mv	s4,a0
ffffffffc0203fc4:	10050c63          	beqz	a0,ffffffffc02040dc <do_pgfault+0x190>
        return ret;
    }
    
    // Case 1: 页表项全为0，说明尚未建立映射 (Demand Paging / 按需分页)
    // 此时分配一个新的物理页并映射
    if (*ptep == 0) { 
ffffffffc0203fc8:	611c                	ld	a5,0(a0)
ffffffffc0203fca:	10078263          	beqz	a5,ffffffffc02040ce <do_pgfault+0x182>
            return ret;
        }
    } 
    // Case 2: 页表项存在，可能是 Copy-on-Write 或者 Swap (本实验暂不考虑swap)
    else { 
        if (*ptep & PTE_V) {
ffffffffc0203fce:	0017f713          	andi	a4,a5,1
ffffffffc0203fd2:	cf71                	beqz	a4,ffffffffc02040ae <do_pgfault+0x162>
            // LAB5 CHALLENGE: Copy on Write 处理
            // 判断条件：这是写操作 (error_code & 2) 
            //          && 且物理页目前是只读的 (!(*ptep & PTE_W))
            //          && 且 VMA 本身允许写入 (vma->vm_flags & VM_WRITE)
            // 这意味着这是一个共享的页面，现在进程试图修改它
            if ((error_code & 2) && !(*ptep & PTE_W) && (vma->vm_flags & VM_WRITE)) {
ffffffffc0203fd4:	10048463          	beqz	s1,ffffffffc02040dc <do_pgfault+0x190>
ffffffffc0203fd8:	0047f713          	andi	a4,a5,4
ffffffffc0203fdc:	10071063          	bnez	a4,ffffffffc02040dc <do_pgfault+0x190>
ffffffffc0203fe0:	4c18                	lw	a4,24(s0)
ffffffffc0203fe2:	8b09                	andi	a4,a4,2
ffffffffc0203fe4:	0e070c63          	beqz	a4,ffffffffc02040dc <do_pgfault+0x190>
    if (PPN(pa) >= npage)
ffffffffc0203fe8:	000d3b97          	auipc	s7,0xd3
ffffffffc0203fec:	df8b8b93          	addi	s7,s7,-520 # ffffffffc02d6de0 <npage>
ffffffffc0203ff0:	000bb703          	ld	a4,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203ff4:	078a                	slli	a5,a5,0x2
ffffffffc0203ff6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203ff8:	12e7fb63          	bgeu	a5,a4,ffffffffc020412e <do_pgfault+0x1e2>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ffc:	000d3c17          	auipc	s8,0xd3
ffffffffc0204000:	decc0c13          	addi	s8,s8,-532 # ffffffffc02d6de8 <pages>
ffffffffc0204004:	000c3403          	ld	s0,0(s8)
ffffffffc0204008:	00004497          	auipc	s1,0x4
ffffffffc020400c:	4204b483          	ld	s1,1056(s1) # ffffffffc0208428 <nbase>
ffffffffc0204010:	8f85                	sub	a5,a5,s1
ffffffffc0204012:	079a                	slli	a5,a5,0x6
ffffffffc0204014:	943e                	add	s0,s0,a5
                struct Page *page = pte2page(*ptep);
                
                // 情况 A: 页面被多个进程共享 (Reference Count > 1)
                // 需要执行“复制”操作：分配新页，拷贝内容，重新映射给当前进程
                if (page_ref(page) > 1) {
ffffffffc0204016:	4018                	lw	a4,0(s0)
ffffffffc0204018:	4785                	li	a5,1
ffffffffc020401a:	0ce7d363          	bge	a5,a4,ffffffffc02040e0 <do_pgfault+0x194>
                    // 分配一个新的物理页
                    struct Page *npage = alloc_page();
ffffffffc020401e:	4505                	li	a0,1
ffffffffc0204020:	f85fd0ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc0204024:	8b2a                	mv	s6,a0
                    if (npage == NULL) return ret;
ffffffffc0204026:	c95d                	beqz	a0,ffffffffc02040dc <do_pgfault+0x190>
    return page - pages + nbase;
ffffffffc0204028:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc020402c:	000bb803          	ld	a6,0(s7)
    return page - pages + nbase;
ffffffffc0204030:	40e506b3          	sub	a3,a0,a4
ffffffffc0204034:	8699                	srai	a3,a3,0x6
ffffffffc0204036:	96a6                	add	a3,a3,s1
    return KADDR(page2pa(page));
ffffffffc0204038:	00c69793          	slli	a5,a3,0xc
ffffffffc020403c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020403e:	00c69513          	slli	a0,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204042:	1107fe63          	bgeu	a5,a6,ffffffffc020415e <do_pgfault+0x212>
    return page - pages + nbase;
ffffffffc0204046:	40e406b3          	sub	a3,s0,a4
ffffffffc020404a:	8699                	srai	a3,a3,0x6
ffffffffc020404c:	96a6                	add	a3,a3,s1
    return KADDR(page2pa(page));
ffffffffc020404e:	00c69793          	slli	a5,a3,0xc
ffffffffc0204052:	000d3597          	auipc	a1,0xd3
ffffffffc0204056:	da65b583          	ld	a1,-602(a1) # ffffffffc02d6df8 <va_pa_offset>
ffffffffc020405a:	83b1                	srli	a5,a5,0xc
ffffffffc020405c:	952e                	add	a0,a0,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc020405e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204060:	0f07f363          	bgeu	a5,a6,ffffffffc0204146 <do_pgfault+0x1fa>
                    
                    // 复制原页面内容到新页面 (Deep Copy)
                    memcpy(page2kva(npage), page2kva(page), PGSIZE);
ffffffffc0204064:	6605                	lui	a2,0x1
ffffffffc0204066:	95b6                	add	a1,a1,a3
ffffffffc0204068:	283010ef          	jal	ra,ffffffffc0205aea <memcpy>
                    // =========================================================
                    // 【Dirty COW 模拟注入点】
                    // 模拟场景：攻击者在主线程进行 COW 缺页处理（正在复制内存）的同时，
                    // 在另一个线程调用 madvise(MADV_DONTNEED)，试图丢弃该页面映射。
                    // =========================================================
                    if (TEST_DIRTY_COW_FLAG) {
ffffffffc020406c:	000d3797          	auipc	a5,0xd3
ffffffffc0204070:	d947b783          	ld	a5,-620(a5) # ffffffffc02d6e00 <TEST_DIRTY_COW_FLAG>
ffffffffc0204074:	e3c1                	bnez	a5,ffffffffc02040f4 <do_pgfault+0x1a8>
                    // =========================================================
                    // 检查 1: (*ptep & PTE_V) == 0 
                    //    含义：页表项是否被清空了？（比如上面的 madvise 攻击）
                    // 检查 2: pte2page(*ptep) != page
                    //    含义：页表项指向的物理页是否改变了？（比如被重新映射到了别的页）
                    if ((*ptep & PTE_V) == 0 || pte2page(*ptep) != page) {
ffffffffc0204076:	000a3783          	ld	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8d60>
ffffffffc020407a:	0017f713          	andi	a4,a5,1
ffffffffc020407e:	cf11                	beqz	a4,ffffffffc020409a <do_pgfault+0x14e>
    if (PPN(pa) >= npage)
ffffffffc0204080:	000bb703          	ld	a4,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204084:	078a                	slli	a5,a5,0x2
ffffffffc0204086:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0204088:	0ae7f363          	bgeu	a5,a4,ffffffffc020412e <do_pgfault+0x1e2>
    return &pages[PPN(pa) - nbase];
ffffffffc020408c:	000c3703          	ld	a4,0(s8)
ffffffffc0204090:	8f85                	sub	a5,a5,s1
ffffffffc0204092:	079a                	slli	a5,a5,0x6
ffffffffc0204094:	97ba                	add	a5,a5,a4
ffffffffc0204096:	08f40263          	beq	s0,a5,ffffffffc020411a <do_pgfault+0x1ce>
                        cprintf("[DirtyCOW] Race detected! Retrying...\n");
ffffffffc020409a:	00003517          	auipc	a0,0x3
ffffffffc020409e:	31e50513          	addi	a0,a0,798 # ffffffffc02073b8 <default_pmm_manager+0xa40>
ffffffffc02040a2:	8f2fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
                    
                        // 关键步骤：释放刚才申请用于 COW 的新物理页 npage。
                        // 因为映射失败了，如果不释放，这个新页就成了“孤儿”，导致内核内存泄漏。
                        free_page(npage); 
ffffffffc02040a6:	4585                	li	a1,1
ffffffffc02040a8:	855a                	mv	a0,s6
ffffffffc02040aa:	f39fd0ef          	jal	ra,ffffffffc0201fe2 <free_pages>
                        // 返回 0：告诉异常处理机制“这次缺页处理由于竞争失败了，但不是错误”。
                        // 结果：CPU 会重新执行刚才触发异常的那条写指令。
                        // 由于映射已经被清空（如果被攻击），重执行会再次触发缺页异常，
                        // 内核会重新进入 do_pgfault，按 Demand Paging (空 PTE) 的逻辑处理，
                        // 从而避免了向错误的物理页写入数据。
                        return 0; 
ffffffffc02040ae:	4501                	li	a0,0
                return ret; 
            }
        }
    }
    return 0;
ffffffffc02040b0:	60a6                	ld	ra,72(sp)
ffffffffc02040b2:	6406                	ld	s0,64(sp)
ffffffffc02040b4:	74e2                	ld	s1,56(sp)
ffffffffc02040b6:	7942                	ld	s2,48(sp)
ffffffffc02040b8:	79a2                	ld	s3,40(sp)
ffffffffc02040ba:	7a02                	ld	s4,32(sp)
ffffffffc02040bc:	6ae2                	ld	s5,24(sp)
ffffffffc02040be:	6b42                	ld	s6,16(sp)
ffffffffc02040c0:	6ba2                	ld	s7,8(sp)
ffffffffc02040c2:	6c02                	ld	s8,0(sp)
ffffffffc02040c4:	6161                	addi	sp,sp,80
ffffffffc02040c6:	8082                	ret
    if ((error_code & 2) && !(vma->vm_flags & VM_WRITE)) {
ffffffffc02040c8:	c739                	beqz	a4,ffffffffc0204116 <do_pgfault+0x1ca>
        perm |= (PTE_R | PTE_W);
ffffffffc02040ca:	4ad9                	li	s5,22
ffffffffc02040cc:	bdc9                	j	ffffffffc0203f9e <do_pgfault+0x52>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02040ce:	0189b503          	ld	a0,24(s3)
ffffffffc02040d2:	8656                	mv	a2,s5
ffffffffc02040d4:	85ca                	mv	a1,s2
ffffffffc02040d6:	e86ff0ef          	jal	ra,ffffffffc020375c <pgdir_alloc_page>
ffffffffc02040da:	f971                	bnez	a0,ffffffffc02040ae <do_pgfault+0x162>
        return ret;
ffffffffc02040dc:	5571                	li	a0,-4
ffffffffc02040de:	bfc9                	j	ffffffffc02040b0 <do_pgfault+0x164>
                    if (page_insert(mm->pgdir, page, addr, perm) != 0) {
ffffffffc02040e0:	0189b503          	ld	a0,24(s3)
ffffffffc02040e4:	86d6                	mv	a3,s5
ffffffffc02040e6:	864a                	mv	a2,s2
ffffffffc02040e8:	85a2                	mv	a1,s0
ffffffffc02040ea:	e62fe0ef          	jal	ra,ffffffffc020274c <page_insert>
ffffffffc02040ee:	d161                	beqz	a0,ffffffffc02040ae <do_pgfault+0x162>
        return ret;
ffffffffc02040f0:	5571                	li	a0,-4
ffffffffc02040f2:	bf7d                	j	ffffffffc02040b0 <do_pgfault+0x164>
                        cprintf("[DirtyCOW] ATTACK: Another thread clears the PTE now!\n");
ffffffffc02040f4:	00003517          	auipc	a0,0x3
ffffffffc02040f8:	28c50513          	addi	a0,a0,652 # ffffffffc0207380 <default_pmm_manager+0xa08>
ffffffffc02040fc:	898fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
                        tlb_invalidate(mm->pgdir, addr);
ffffffffc0204100:	0189b503          	ld	a0,24(s3)
ffffffffc0204104:	85ca                	mv	a1,s2
                        *ptep = 0; 
ffffffffc0204106:	000a3023          	sd	zero,0(s4)
                        tlb_invalidate(mm->pgdir, addr);
ffffffffc020410a:	e4cff0ef          	jal	ra,ffffffffc0203756 <tlb_invalidate>
    page->ref -= 1;
ffffffffc020410e:	401c                	lw	a5,0(s0)
ffffffffc0204110:	37fd                	addiw	a5,a5,-1
ffffffffc0204112:	c01c                	sw	a5,0(s0)
    return page->ref;
ffffffffc0204114:	b78d                	j	ffffffffc0204076 <do_pgfault+0x12a>
        return -E_INVAL;
ffffffffc0204116:	5575                	li	a0,-3
ffffffffc0204118:	bf61                	j	ffffffffc02040b0 <do_pgfault+0x164>
                    if (page_insert(mm->pgdir, npage, addr, perm) != 0) {
ffffffffc020411a:	0189b503          	ld	a0,24(s3)
ffffffffc020411e:	86d6                	mv	a3,s5
ffffffffc0204120:	864a                	mv	a2,s2
ffffffffc0204122:	85da                	mv	a1,s6
ffffffffc0204124:	e28fe0ef          	jal	ra,ffffffffc020274c <page_insert>
ffffffffc0204128:	d159                	beqz	a0,ffffffffc02040ae <do_pgfault+0x162>
        return ret;
ffffffffc020412a:	5571                	li	a0,-4
ffffffffc020412c:	b751                	j	ffffffffc02040b0 <do_pgfault+0x164>
        panic("pa2page called with invalid pa");
ffffffffc020412e:	00003617          	auipc	a2,0x3
ffffffffc0204132:	95260613          	addi	a2,a2,-1710 # ffffffffc0206a80 <default_pmm_manager+0x108>
ffffffffc0204136:	0b200593          	li	a1,178
ffffffffc020413a:	00003517          	auipc	a0,0x3
ffffffffc020413e:	89e50513          	addi	a0,a0,-1890 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0204142:	b4cfc0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0204146:	00003617          	auipc	a2,0x3
ffffffffc020414a:	86a60613          	addi	a2,a2,-1942 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc020414e:	0bd00593          	li	a1,189
ffffffffc0204152:	00003517          	auipc	a0,0x3
ffffffffc0204156:	88650513          	addi	a0,a0,-1914 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc020415a:	b34fc0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc020415e:	86aa                	mv	a3,a0
ffffffffc0204160:	00003617          	auipc	a2,0x3
ffffffffc0204164:	85060613          	addi	a2,a2,-1968 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0204168:	0bd00593          	li	a1,189
ffffffffc020416c:	00003517          	auipc	a0,0x3
ffffffffc0204170:	86c50513          	addi	a0,a0,-1940 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0204174:	b1afc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204178 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204178:	8526                	mv	a0,s1
	jalr s0
ffffffffc020417a:	9402                	jalr	s0

	jal do_exit
ffffffffc020417c:	63c000ef          	jal	ra,ffffffffc02047b8 <do_exit>

ffffffffc0204180 <alloc_proc>:
 * 1. 从内核堆分配 struct proc_struct 的内存。
 * 2. 将所有字段初始化为默认值 (0, NULL, UNINIT)。
 */
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0204180:	1141                	addi	sp,sp,-16
    // 从内核堆分配 PCB 结构体内存
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204182:	11000513          	li	a0,272
{
ffffffffc0204186:	e022                	sd	s0,0(sp)
ffffffffc0204188:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020418a:	c3dfd0ef          	jal	ra,ffffffffc0201dc6 <kmalloc>
ffffffffc020418e:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0204190:	cd31                	beqz	a0,ffffffffc02041ec <alloc_proc+0x6c>
    {
        // LAB4:EXERCISE1 YOUR CODE
        // LAB5 YOUR CODE : 2312220(update LAB4 steps)
        
        // [1] 基本状态初始化
        proc->state = PROC_UNINIT;          // 初始状态设为未初始化
ffffffffc0204192:	57fd                	li	a5,-1
ffffffffc0204194:	1782                	slli	a5,a5,0x20
ffffffffc0204196:	e11c                	sd	a5,0(a0)
        proc->parent = NULL;                // 父进程指针置空
        proc->mm = NULL;                    // 内存描述符置空 (内核线程不需要，用户进程在 do_fork/exec 时分配)
        
        // [2] 上下文与中断帧清零
        // context 用于进程切换 (switch_to)，保存 callee-saved 寄存器
        memset(&(proc->context), 0, sizeof(struct context)); 
ffffffffc0204198:	07000613          	li	a2,112
ffffffffc020419c:	4581                	li	a1,0
        proc->runs = 0;                     // 运行时间/次数归零
ffffffffc020419e:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;                   // 内核栈指针初始化为 0 (稍后在 setup_kstack 分配)
ffffffffc02041a2:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;             // 初始不需要调度
ffffffffc02041a6:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;                // 父进程指针置空
ffffffffc02041aa:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                    // 内存描述符置空 (内核线程不需要，用户进程在 do_fork/exec 时分配)
ffffffffc02041ae:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context)); 
ffffffffc02041b2:	03050513          	addi	a0,a0,48
ffffffffc02041b6:	123010ef          	jal	ra,ffffffffc0205ad8 <memset>
        // tf 用于中断/系统调用返回 (sret)，保存中断现场
        proc->tf = NULL;                    
        
        // [3] 页表初始化
        // 初始指向内核页表基址，确保即使没有用户空间也能在内核运行
        proc->pgdir = boot_pgdir_pa;        
ffffffffc02041ba:	000d3797          	auipc	a5,0xd3
ffffffffc02041be:	c167b783          	ld	a5,-1002(a5) # ffffffffc02d6dd0 <boot_pgdir_pa>
        proc->tf = NULL;                    
ffffffffc02041c2:	0a043023          	sd	zero,160(s0)
        proc->pgdir = boot_pgdir_pa;        
ffffffffc02041c6:	f45c                	sd	a5,168(s0)
        
        proc->flags = 0;                    // 标志位清零
ffffffffc02041c8:	0a042823          	sw	zero,176(s0)
        memset(&(proc->name), 0, PROC_NAME_LEN + 1); // 进程名清零
ffffffffc02041cc:	4641                	li	a2,16
ffffffffc02041ce:	4581                	li	a1,0
ffffffffc02041d0:	0b440513          	addi	a0,s0,180
ffffffffc02041d4:	105010ef          	jal	ra,ffffffffc0205ad8 <memset>

        // [Lab 5 新增] 等待状态与进程关系链表
        proc->wait_state = 0; // 0 表示没有在等待，WT_CHILD 表示等待子进程
ffffffffc02041d8:	0e042623          	sw	zero,236(s0)
        
        // 初始化家族关系指针
        // cptr: 指向第一个(最年轻)子进程
        // yptr: 指向下一个(更年轻)兄弟进程
        // optr: 指向上一个(更年长)兄弟进程
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc02041dc:	0e043c23          	sd	zero,248(s0)
ffffffffc02041e0:	10043023          	sd	zero,256(s0)
ffffffffc02041e4:	0e043823          	sd	zero,240(s0)
        
        // [Lab 5 调度] 时间片初始化
        // 用于 Round-Robin 调度算法，初始为 0
        proc->time_slice = 0;
ffffffffc02041e8:	10042423          	sw	zero,264(s0)
    }
    return proc;
}
ffffffffc02041ec:	60a2                	ld	ra,8(sp)
ffffffffc02041ee:	8522                	mv	a0,s0
ffffffffc02041f0:	6402                	ld	s0,0(sp)
ffffffffc02041f2:	0141                	addi	sp,sp,16
ffffffffc02041f4:	8082                	ret

ffffffffc02041f6 <forkret>:
static void
forkret(void)
{
    // forkrets 位于 trapentry.S
    // 它将 tf (trapframe) 中的寄存器值恢复到 CPU，最后执行 sret 返回用户态/内核态
    forkrets(current->tf);
ffffffffc02041f6:	000d3797          	auipc	a5,0xd3
ffffffffc02041fa:	c1a7b783          	ld	a5,-998(a5) # ffffffffc02d6e10 <current>
ffffffffc02041fe:	73c8                	ld	a0,160(a5)
ffffffffc0204200:	e2bfc06f          	j	ffffffffc020102a <forkrets>

ffffffffc0204204 <user_main>:
 */
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204204:	000d3797          	auipc	a5,0xd3
ffffffffc0204208:	c0c7b783          	ld	a5,-1012(a5) # ffffffffc02d6e10 <current>
ffffffffc020420c:	43cc                	lw	a1,4(a5)
{
ffffffffc020420e:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204210:	00003617          	auipc	a2,0x3
ffffffffc0204214:	1d060613          	addi	a2,a2,464 # ffffffffc02073e0 <default_pmm_manager+0xa68>
ffffffffc0204218:	00003517          	auipc	a0,0x3
ffffffffc020421c:	1d850513          	addi	a0,a0,472 # ffffffffc02073f0 <default_pmm_manager+0xa78>
{
ffffffffc0204220:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204222:	f73fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0204226:	3fe07797          	auipc	a5,0x3fe07
ffffffffc020422a:	8f278793          	addi	a5,a5,-1806 # ab18 <_binary_obj___user_forktest_out_size>
ffffffffc020422e:	e43e                	sd	a5,8(sp)
ffffffffc0204230:	00003517          	auipc	a0,0x3
ffffffffc0204234:	1b050513          	addi	a0,a0,432 # ffffffffc02073e0 <default_pmm_manager+0xa68>
ffffffffc0204238:	00071797          	auipc	a5,0x71
ffffffffc020423c:	ca878793          	addi	a5,a5,-856 # ffffffffc0274ee0 <_binary_obj___user_forktest_out_start>
ffffffffc0204240:	f03e                	sd	a5,32(sp)
ffffffffc0204242:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0204244:	e802                	sd	zero,16(sp)
ffffffffc0204246:	7f0010ef          	jal	ra,ffffffffc0205a36 <strlen>
ffffffffc020424a:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc020424c:	4511                	li	a0,4
ffffffffc020424e:	55a2                	lw	a1,40(sp)
ffffffffc0204250:	4662                	lw	a2,24(sp)
ffffffffc0204252:	5682                	lw	a3,32(sp)
ffffffffc0204254:	4722                	lw	a4,8(sp)
ffffffffc0204256:	48a9                	li	a7,10
ffffffffc0204258:	9002                	ebreak
ffffffffc020425a:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc020425c:	65c2                	ld	a1,16(sp)
ffffffffc020425e:	00003517          	auipc	a0,0x3
ffffffffc0204262:	1ba50513          	addi	a0,a0,442 # ffffffffc0207418 <default_pmm_manager+0xaa0>
ffffffffc0204266:	f2ffb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    //KERNEL_EXECVE(cow_stress);
    
    // [Challenge]: 运行 Dirty COW 测试程序
    KERNEL_EXECVE(dirty_cow_test); 
#endif
    panic("user_main execve failed.\n");
ffffffffc020426a:	00003617          	auipc	a2,0x3
ffffffffc020426e:	1be60613          	addi	a2,a2,446 # ffffffffc0207428 <default_pmm_manager+0xab0>
ffffffffc0204272:	46a00593          	li	a1,1130
ffffffffc0204276:	00003517          	auipc	a0,0x3
ffffffffc020427a:	1d250513          	addi	a0,a0,466 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc020427e:	a10fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204282 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204282:	6d14                	ld	a3,24(a0)
{
ffffffffc0204284:	1141                	addi	sp,sp,-16
ffffffffc0204286:	e406                	sd	ra,8(sp)
ffffffffc0204288:	c02007b7          	lui	a5,0xc0200
ffffffffc020428c:	02f6ee63          	bltu	a3,a5,ffffffffc02042c8 <put_pgdir+0x46>
ffffffffc0204290:	000d3517          	auipc	a0,0xd3
ffffffffc0204294:	b6853503          	ld	a0,-1176(a0) # ffffffffc02d6df8 <va_pa_offset>
ffffffffc0204298:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc020429a:	82b1                	srli	a3,a3,0xc
ffffffffc020429c:	000d3797          	auipc	a5,0xd3
ffffffffc02042a0:	b447b783          	ld	a5,-1212(a5) # ffffffffc02d6de0 <npage>
ffffffffc02042a4:	02f6fe63          	bgeu	a3,a5,ffffffffc02042e0 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc02042a8:	00004517          	auipc	a0,0x4
ffffffffc02042ac:	18053503          	ld	a0,384(a0) # ffffffffc0208428 <nbase>
}
ffffffffc02042b0:	60a2                	ld	ra,8(sp)
ffffffffc02042b2:	8e89                	sub	a3,a3,a0
ffffffffc02042b4:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc02042b6:	000d3517          	auipc	a0,0xd3
ffffffffc02042ba:	b3253503          	ld	a0,-1230(a0) # ffffffffc02d6de8 <pages>
ffffffffc02042be:	4585                	li	a1,1
ffffffffc02042c0:	9536                	add	a0,a0,a3
}
ffffffffc02042c2:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc02042c4:	d1ffd06f          	j	ffffffffc0201fe2 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc02042c8:	00002617          	auipc	a2,0x2
ffffffffc02042cc:	79060613          	addi	a2,a2,1936 # ffffffffc0206a58 <default_pmm_manager+0xe0>
ffffffffc02042d0:	0c500593          	li	a1,197
ffffffffc02042d4:	00002517          	auipc	a0,0x2
ffffffffc02042d8:	70450513          	addi	a0,a0,1796 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc02042dc:	9b2fc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02042e0:	00002617          	auipc	a2,0x2
ffffffffc02042e4:	7a060613          	addi	a2,a2,1952 # ffffffffc0206a80 <default_pmm_manager+0x108>
ffffffffc02042e8:	0b200593          	li	a1,178
ffffffffc02042ec:	00002517          	auipc	a0,0x2
ffffffffc02042f0:	6ec50513          	addi	a0,a0,1772 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc02042f4:	99afc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02042f8 <proc_run>:
{
ffffffffc02042f8:	7179                	addi	sp,sp,-48
ffffffffc02042fa:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc02042fc:	000d3917          	auipc	s2,0xd3
ffffffffc0204300:	b1490913          	addi	s2,s2,-1260 # ffffffffc02d6e10 <current>
{
ffffffffc0204304:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc0204306:	00093483          	ld	s1,0(s2)
{
ffffffffc020430a:	f406                	sd	ra,40(sp)
ffffffffc020430c:	e84e                	sd	s3,16(sp)
    if (proc != current)
ffffffffc020430e:	02a48863          	beq	s1,a0,ffffffffc020433e <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204312:	100027f3          	csrr	a5,sstatus
ffffffffc0204316:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204318:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020431a:	ef9d                	bnez	a5,ffffffffc0204358 <proc_run+0x60>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc020431c:	755c                	ld	a5,168(a0)
ffffffffc020431e:	577d                	li	a4,-1
ffffffffc0204320:	177e                	slli	a4,a4,0x3f
ffffffffc0204322:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0204324:	00a93023          	sd	a0,0(s2)
ffffffffc0204328:	8fd9                	or	a5,a5,a4
ffffffffc020432a:	18079073          	csrw	satp,a5
            switch_to(&(prev_proc->context), &(proc->context));
ffffffffc020432e:	03050593          	addi	a1,a0,48
ffffffffc0204332:	03048513          	addi	a0,s1,48
ffffffffc0204336:	052010ef          	jal	ra,ffffffffc0205388 <switch_to>
    if (flag)
ffffffffc020433a:	00099863          	bnez	s3,ffffffffc020434a <proc_run+0x52>
}
ffffffffc020433e:	70a2                	ld	ra,40(sp)
ffffffffc0204340:	7482                	ld	s1,32(sp)
ffffffffc0204342:	6962                	ld	s2,24(sp)
ffffffffc0204344:	69c2                	ld	s3,16(sp)
ffffffffc0204346:	6145                	addi	sp,sp,48
ffffffffc0204348:	8082                	ret
ffffffffc020434a:	70a2                	ld	ra,40(sp)
ffffffffc020434c:	7482                	ld	s1,32(sp)
ffffffffc020434e:	6962                	ld	s2,24(sp)
ffffffffc0204350:	69c2                	ld	s3,16(sp)
ffffffffc0204352:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204354:	e5afc06f          	j	ffffffffc02009ae <intr_enable>
ffffffffc0204358:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020435a:	e5afc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc020435e:	6522                	ld	a0,8(sp)
ffffffffc0204360:	4985                	li	s3,1
ffffffffc0204362:	bf6d                	j	ffffffffc020431c <proc_run+0x24>

ffffffffc0204364 <do_fork>:
{
ffffffffc0204364:	7119                	addi	sp,sp,-128
ffffffffc0204366:	f0ca                	sd	s2,96(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204368:	000d3917          	auipc	s2,0xd3
ffffffffc020436c:	ac090913          	addi	s2,s2,-1344 # ffffffffc02d6e28 <nr_process>
ffffffffc0204370:	00092703          	lw	a4,0(s2)
{
ffffffffc0204374:	fc86                	sd	ra,120(sp)
ffffffffc0204376:	f8a2                	sd	s0,112(sp)
ffffffffc0204378:	f4a6                	sd	s1,104(sp)
ffffffffc020437a:	ecce                	sd	s3,88(sp)
ffffffffc020437c:	e8d2                	sd	s4,80(sp)
ffffffffc020437e:	e4d6                	sd	s5,72(sp)
ffffffffc0204380:	e0da                	sd	s6,64(sp)
ffffffffc0204382:	fc5e                	sd	s7,56(sp)
ffffffffc0204384:	f862                	sd	s8,48(sp)
ffffffffc0204386:	f466                	sd	s9,40(sp)
ffffffffc0204388:	f06a                	sd	s10,32(sp)
ffffffffc020438a:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc020438c:	6785                	lui	a5,0x1
ffffffffc020438e:	32f75b63          	bge	a4,a5,ffffffffc02046c4 <do_fork+0x360>
ffffffffc0204392:	8a2a                	mv	s4,a0
ffffffffc0204394:	89ae                	mv	s3,a1
ffffffffc0204396:	8432                	mv	s0,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc0204398:	de9ff0ef          	jal	ra,ffffffffc0204180 <alloc_proc>
ffffffffc020439c:	84aa                	mv	s1,a0
ffffffffc020439e:	30050463          	beqz	a0,ffffffffc02046a6 <do_fork+0x342>
    proc->parent = current;
ffffffffc02043a2:	000d3c17          	auipc	s8,0xd3
ffffffffc02043a6:	a6ec0c13          	addi	s8,s8,-1426 # ffffffffc02d6e10 <current>
ffffffffc02043aa:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);
ffffffffc02043ae:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8c74>
    proc->parent = current;
ffffffffc02043b2:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc02043b4:	30071d63          	bnez	a4,ffffffffc02046ce <do_fork+0x36a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02043b8:	4509                	li	a0,2
ffffffffc02043ba:	bebfd0ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
    if (page != NULL)
ffffffffc02043be:	2e050163          	beqz	a0,ffffffffc02046a0 <do_fork+0x33c>
    return page - pages + nbase;
ffffffffc02043c2:	000d3a97          	auipc	s5,0xd3
ffffffffc02043c6:	a26a8a93          	addi	s5,s5,-1498 # ffffffffc02d6de8 <pages>
ffffffffc02043ca:	000ab683          	ld	a3,0(s5)
ffffffffc02043ce:	00004b17          	auipc	s6,0x4
ffffffffc02043d2:	05ab0b13          	addi	s6,s6,90 # ffffffffc0208428 <nbase>
ffffffffc02043d6:	000b3783          	ld	a5,0(s6)
ffffffffc02043da:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc02043de:	000d3b97          	auipc	s7,0xd3
ffffffffc02043e2:	a02b8b93          	addi	s7,s7,-1534 # ffffffffc02d6de0 <npage>
    return page - pages + nbase;
ffffffffc02043e6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02043e8:	5dfd                	li	s11,-1
ffffffffc02043ea:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc02043ee:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02043f0:	00cddd93          	srli	s11,s11,0xc
ffffffffc02043f4:	01b6f633          	and	a2,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc02043f8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02043fa:	2ee67a63          	bgeu	a2,a4,ffffffffc02046ee <do_fork+0x38a>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc02043fe:	000c3603          	ld	a2,0(s8)
ffffffffc0204402:	000d3c17          	auipc	s8,0xd3
ffffffffc0204406:	9f6c0c13          	addi	s8,s8,-1546 # ffffffffc02d6df8 <va_pa_offset>
ffffffffc020440a:	000c3703          	ld	a4,0(s8)
ffffffffc020440e:	02863d03          	ld	s10,40(a2)
ffffffffc0204412:	e43e                	sd	a5,8(sp)
ffffffffc0204414:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204416:	e894                	sd	a3,16(s1)
    if (oldmm == NULL)
ffffffffc0204418:	020d0863          	beqz	s10,ffffffffc0204448 <do_fork+0xe4>
    if (clone_flags & CLONE_VM)
ffffffffc020441c:	100a7a13          	andi	s4,s4,256
ffffffffc0204420:	1c0a0163          	beqz	s4,ffffffffc02045e2 <do_fork+0x27e>

// 内联函数：增加 mm 的引用计数
static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0204424:	030d2703          	lw	a4,48(s10)
    proc->pgdir = PADDR(mm->pgdir); // 设置 proc->pgdir 为物理地址 (用于 SATP)
ffffffffc0204428:	018d3783          	ld	a5,24(s10)
ffffffffc020442c:	c02006b7          	lui	a3,0xc0200
ffffffffc0204430:	2705                	addiw	a4,a4,1
ffffffffc0204432:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc0204436:	03a4b423          	sd	s10,40(s1)
    proc->pgdir = PADDR(mm->pgdir); // 设置 proc->pgdir 为物理地址 (用于 SATP)
ffffffffc020443a:	2ed7e263          	bltu	a5,a3,ffffffffc020471e <do_fork+0x3ba>
ffffffffc020443e:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204442:	6894                	ld	a3,16(s1)
    proc->pgdir = PADDR(mm->pgdir); // 设置 proc->pgdir 为物理地址 (用于 SATP)
ffffffffc0204444:	8f99                	sub	a5,a5,a4
ffffffffc0204446:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204448:	6789                	lui	a5,0x2
ffffffffc020444a:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7e80>
ffffffffc020444e:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204450:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204452:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0204454:	87b6                	mv	a5,a3
ffffffffc0204456:	12040893          	addi	a7,s0,288
ffffffffc020445a:	00063803          	ld	a6,0(a2)
ffffffffc020445e:	6608                	ld	a0,8(a2)
ffffffffc0204460:	6a0c                	ld	a1,16(a2)
ffffffffc0204462:	6e18                	ld	a4,24(a2)
ffffffffc0204464:	0107b023          	sd	a6,0(a5)
ffffffffc0204468:	e788                	sd	a0,8(a5)
ffffffffc020446a:	eb8c                	sd	a1,16(a5)
ffffffffc020446c:	ef98                	sd	a4,24(a5)
ffffffffc020446e:	02060613          	addi	a2,a2,32
ffffffffc0204472:	02078793          	addi	a5,a5,32
ffffffffc0204476:	ff1612e3          	bne	a2,a7,ffffffffc020445a <do_fork+0xf6>
    proc->tf->gpr.a0 = 0;
ffffffffc020447a:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020447e:	12098f63          	beqz	s3,ffffffffc02045bc <do_fork+0x258>
ffffffffc0204482:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204486:	00000797          	auipc	a5,0x0
ffffffffc020448a:	d7078793          	addi	a5,a5,-656 # ffffffffc02041f6 <forkret>
ffffffffc020448e:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204490:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204492:	100027f3          	csrr	a5,sstatus
ffffffffc0204496:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204498:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020449a:	14079063          	bnez	a5,ffffffffc02045da <do_fork+0x276>
    if (++last_pid >= MAX_PID)
ffffffffc020449e:	000ce817          	auipc	a6,0xce
ffffffffc02044a2:	4c280813          	addi	a6,a6,1218 # ffffffffc02d2960 <last_pid.1>
ffffffffc02044a6:	00082783          	lw	a5,0(a6)
ffffffffc02044aa:	6709                	lui	a4,0x2
ffffffffc02044ac:	0017851b          	addiw	a0,a5,1
ffffffffc02044b0:	00a82023          	sw	a0,0(a6)
ffffffffc02044b4:	08e55d63          	bge	a0,a4,ffffffffc020454e <do_fork+0x1ea>
    if (last_pid >= next_safe)
ffffffffc02044b8:	000ce317          	auipc	t1,0xce
ffffffffc02044bc:	4ac30313          	addi	t1,t1,1196 # ffffffffc02d2964 <next_safe.0>
ffffffffc02044c0:	00032783          	lw	a5,0(t1)
ffffffffc02044c4:	000d3417          	auipc	s0,0xd3
ffffffffc02044c8:	8bc40413          	addi	s0,s0,-1860 # ffffffffc02d6d80 <proc_list>
ffffffffc02044cc:	08f55963          	bge	a0,a5,ffffffffc020455e <do_fork+0x1fa>
        proc->pid = get_pid(); // 获取唯一的 PID
ffffffffc02044d0:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02044d2:	45a9                	li	a1,10
ffffffffc02044d4:	2501                	sext.w	a0,a0
ffffffffc02044d6:	15c010ef          	jal	ra,ffffffffc0205632 <hash32>
ffffffffc02044da:	02051793          	slli	a5,a0,0x20
ffffffffc02044de:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02044e2:	000cf797          	auipc	a5,0xcf
ffffffffc02044e6:	89e78793          	addi	a5,a5,-1890 # ffffffffc02d2d80 <hash_list>
ffffffffc02044ea:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02044ec:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02044ee:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02044f0:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc02044f4:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02044f6:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc02044f8:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02044fa:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02044fc:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc0204500:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc0204502:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc0204504:	e21c                	sd	a5,0(a2)
ffffffffc0204506:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc0204508:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc020450a:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL; // 新进程是最年轻的，所以没有比它更年轻的弟弟 (yptr=NULL)
ffffffffc020450c:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204510:	10e4b023          	sd	a4,256(s1)
ffffffffc0204514:	c311                	beqz	a4,ffffffffc0204518 <do_fork+0x1b4>
        proc->optr->yptr = proc; // 让原来的子进程认这个新进程为弟弟
ffffffffc0204516:	ff64                	sd	s1,248(a4)
    nr_process++;
ffffffffc0204518:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc; 
ffffffffc020451c:	fae4                	sd	s1,240(a3)
    nr_process++;
ffffffffc020451e:	2785                	addiw	a5,a5,1
ffffffffc0204520:	00f92023          	sw	a5,0(s2)
    if (flag)
ffffffffc0204524:	18099363          	bnez	s3,ffffffffc02046aa <do_fork+0x346>
    wakeup_proc(proc); 
ffffffffc0204528:	8526                	mv	a0,s1
ffffffffc020452a:	6c9000ef          	jal	ra,ffffffffc02053f2 <wakeup_proc>
    ret = proc->pid;
ffffffffc020452e:	40c8                	lw	a0,4(s1)
}
ffffffffc0204530:	70e6                	ld	ra,120(sp)
ffffffffc0204532:	7446                	ld	s0,112(sp)
ffffffffc0204534:	74a6                	ld	s1,104(sp)
ffffffffc0204536:	7906                	ld	s2,96(sp)
ffffffffc0204538:	69e6                	ld	s3,88(sp)
ffffffffc020453a:	6a46                	ld	s4,80(sp)
ffffffffc020453c:	6aa6                	ld	s5,72(sp)
ffffffffc020453e:	6b06                	ld	s6,64(sp)
ffffffffc0204540:	7be2                	ld	s7,56(sp)
ffffffffc0204542:	7c42                	ld	s8,48(sp)
ffffffffc0204544:	7ca2                	ld	s9,40(sp)
ffffffffc0204546:	7d02                	ld	s10,32(sp)
ffffffffc0204548:	6de2                	ld	s11,24(sp)
ffffffffc020454a:	6109                	addi	sp,sp,128
ffffffffc020454c:	8082                	ret
        last_pid = 1;
ffffffffc020454e:	4785                	li	a5,1
ffffffffc0204550:	00f82023          	sw	a5,0(a6)
        goto inside; // 如果溢出，重新开始搜索
ffffffffc0204554:	4505                	li	a0,1
ffffffffc0204556:	000ce317          	auipc	t1,0xce
ffffffffc020455a:	40e30313          	addi	t1,t1,1038 # ffffffffc02d2964 <next_safe.0>
    return listelm->next;
ffffffffc020455e:	000d3417          	auipc	s0,0xd3
ffffffffc0204562:	82240413          	addi	s0,s0,-2014 # ffffffffc02d6d80 <proc_list>
ffffffffc0204566:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc020456a:	6789                	lui	a5,0x2
ffffffffc020456c:	00f32023          	sw	a5,0(t1)
ffffffffc0204570:	86aa                	mv	a3,a0
ffffffffc0204572:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc0204574:	6e89                	lui	t4,0x2
ffffffffc0204576:	148e0263          	beq	t3,s0,ffffffffc02046ba <do_fork+0x356>
ffffffffc020457a:	88ae                	mv	a7,a1
ffffffffc020457c:	87f2                	mv	a5,t3
ffffffffc020457e:	6609                	lui	a2,0x2
ffffffffc0204580:	a811                	j	ffffffffc0204594 <do_fork+0x230>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0204582:	00e6d663          	bge	a3,a4,ffffffffc020458e <do_fork+0x22a>
ffffffffc0204586:	00c75463          	bge	a4,a2,ffffffffc020458e <do_fork+0x22a>
ffffffffc020458a:	863a                	mv	a2,a4
ffffffffc020458c:	4885                	li	a7,1
ffffffffc020458e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204590:	00878d63          	beq	a5,s0,ffffffffc02045aa <do_fork+0x246>
            if (proc->pid == last_pid)
ffffffffc0204594:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7e24>
ffffffffc0204598:	fed715e3          	bne	a4,a3,ffffffffc0204582 <do_fork+0x21e>
                if (++last_pid >= next_safe)
ffffffffc020459c:	2685                	addiw	a3,a3,1
ffffffffc020459e:	10c6d963          	bge	a3,a2,ffffffffc02046b0 <do_fork+0x34c>
ffffffffc02045a2:	679c                	ld	a5,8(a5)
ffffffffc02045a4:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc02045a6:	fe8797e3          	bne	a5,s0,ffffffffc0204594 <do_fork+0x230>
ffffffffc02045aa:	c581                	beqz	a1,ffffffffc02045b2 <do_fork+0x24e>
ffffffffc02045ac:	00d82023          	sw	a3,0(a6)
ffffffffc02045b0:	8536                	mv	a0,a3
ffffffffc02045b2:	f0088fe3          	beqz	a7,ffffffffc02044d0 <do_fork+0x16c>
ffffffffc02045b6:	00c32023          	sw	a2,0(t1)
ffffffffc02045ba:	bf19                	j	ffffffffc02044d0 <do_fork+0x16c>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02045bc:	89b6                	mv	s3,a3
ffffffffc02045be:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02045c2:	00000797          	auipc	a5,0x0
ffffffffc02045c6:	c3478793          	addi	a5,a5,-972 # ffffffffc02041f6 <forkret>
ffffffffc02045ca:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02045cc:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02045ce:	100027f3          	csrr	a5,sstatus
ffffffffc02045d2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02045d4:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02045d6:	ec0784e3          	beqz	a5,ffffffffc020449e <do_fork+0x13a>
        intr_disable();
ffffffffc02045da:	bdafc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc02045de:	4985                	li	s3,1
ffffffffc02045e0:	bd7d                	j	ffffffffc020449e <do_fork+0x13a>
    if ((mm = mm_create()) == NULL)
ffffffffc02045e2:	a60ff0ef          	jal	ra,ffffffffc0203842 <mm_create>
ffffffffc02045e6:	8caa                	mv	s9,a0
ffffffffc02045e8:	c541                	beqz	a0,ffffffffc0204670 <do_fork+0x30c>
    if ((page = alloc_page()) == NULL)
ffffffffc02045ea:	4505                	li	a0,1
ffffffffc02045ec:	9b9fd0ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc02045f0:	cd2d                	beqz	a0,ffffffffc020466a <do_fork+0x306>
    return page - pages + nbase;
ffffffffc02045f2:	000ab683          	ld	a3,0(s5)
ffffffffc02045f6:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc02045f8:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc02045fc:	40d506b3          	sub	a3,a0,a3
ffffffffc0204600:	8699                	srai	a3,a3,0x6
ffffffffc0204602:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204604:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc0204608:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020460a:	0eedf263          	bgeu	s11,a4,ffffffffc02046ee <do_fork+0x38a>
ffffffffc020460e:	000c3a03          	ld	s4,0(s8)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204612:	6605                	lui	a2,0x1
ffffffffc0204614:	000d2597          	auipc	a1,0xd2
ffffffffc0204618:	7c45b583          	ld	a1,1988(a1) # ffffffffc02d6dd8 <boot_pgdir_va>
ffffffffc020461c:	9a36                	add	s4,s4,a3
ffffffffc020461e:	8552                	mv	a0,s4
ffffffffc0204620:	4ca010ef          	jal	ra,ffffffffc0205aea <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc0204624:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc0204628:	014cbc23          	sd	s4,24(s9) # fffffffffff80018 <end+0x3fca91ec>
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020462c:	4785                	li	a5,1
ffffffffc020462e:	40fdb7af          	amoor.d	a5,a5,(s11)
 * 因此，获取失败时主动放弃 CPU，让持有锁的进程有机会运行并释放锁。
 */
static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc0204632:	8b85                	andi	a5,a5,1
ffffffffc0204634:	4a05                	li	s4,1
ffffffffc0204636:	c799                	beqz	a5,ffffffffc0204644 <do_fork+0x2e0>
    {
        schedule();
ffffffffc0204638:	63d000ef          	jal	ra,ffffffffc0205474 <schedule>
ffffffffc020463c:	414db7af          	amoor.d	a5,s4,(s11)
    while (!try_lock(lock))
ffffffffc0204640:	8b85                	andi	a5,a5,1
ffffffffc0204642:	fbfd                	bnez	a5,ffffffffc0204638 <do_fork+0x2d4>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204644:	85ea                	mv	a1,s10
ffffffffc0204646:	8566                	mv	a0,s9
ffffffffc0204648:	c3cff0ef          	jal	ra,ffffffffc0203a84 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020464c:	57f9                	li	a5,-2
ffffffffc020464e:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc0204652:	8b85                	andi	a5,a5,1
 * 如果操作前锁的值已经是 0，说明逻辑错误（释放了一个没有被锁住的锁），触发 panic。
 */
static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc0204654:	0e078e63          	beqz	a5,ffffffffc0204750 <do_fork+0x3ec>
good_mm:
ffffffffc0204658:	8d66                	mv	s10,s9
    if (ret != 0)
ffffffffc020465a:	dc0505e3          	beqz	a0,ffffffffc0204424 <do_fork+0xc0>
    exit_mmap(mm);
ffffffffc020465e:	8566                	mv	a0,s9
ffffffffc0204660:	cbeff0ef          	jal	ra,ffffffffc0203b1e <exit_mmap>
    put_pgdir(mm);
ffffffffc0204664:	8566                	mv	a0,s9
ffffffffc0204666:	c1dff0ef          	jal	ra,ffffffffc0204282 <put_pgdir>
    mm_destroy(mm);
ffffffffc020466a:	8566                	mv	a0,s9
ffffffffc020466c:	b16ff0ef          	jal	ra,ffffffffc0203982 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204670:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc0204672:	c02007b7          	lui	a5,0xc0200
ffffffffc0204676:	0cf6e163          	bltu	a3,a5,ffffffffc0204738 <do_fork+0x3d4>
ffffffffc020467a:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage)
ffffffffc020467e:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0204682:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204686:	83b1                	srli	a5,a5,0xc
ffffffffc0204688:	06e7ff63          	bgeu	a5,a4,ffffffffc0204706 <do_fork+0x3a2>
    return &pages[PPN(pa) - nbase];
ffffffffc020468c:	000b3703          	ld	a4,0(s6)
ffffffffc0204690:	000ab503          	ld	a0,0(s5)
ffffffffc0204694:	4589                	li	a1,2
ffffffffc0204696:	8f99                	sub	a5,a5,a4
ffffffffc0204698:	079a                	slli	a5,a5,0x6
ffffffffc020469a:	953e                	add	a0,a0,a5
ffffffffc020469c:	947fd0ef          	jal	ra,ffffffffc0201fe2 <free_pages>
    kfree(proc);
ffffffffc02046a0:	8526                	mv	a0,s1
ffffffffc02046a2:	fd4fd0ef          	jal	ra,ffffffffc0201e76 <kfree>
    ret = -E_NO_MEM;
ffffffffc02046a6:	5571                	li	a0,-4
    return ret;
ffffffffc02046a8:	b561                	j	ffffffffc0204530 <do_fork+0x1cc>
        intr_enable();
ffffffffc02046aa:	b04fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02046ae:	bdad                	j	ffffffffc0204528 <do_fork+0x1c4>
                    if (last_pid >= MAX_PID)
ffffffffc02046b0:	01d6c363          	blt	a3,t4,ffffffffc02046b6 <do_fork+0x352>
                        last_pid = 1;
ffffffffc02046b4:	4685                	li	a3,1
                    goto repeat; // 重新搜索
ffffffffc02046b6:	4585                	li	a1,1
ffffffffc02046b8:	bd7d                	j	ffffffffc0204576 <do_fork+0x212>
ffffffffc02046ba:	c599                	beqz	a1,ffffffffc02046c8 <do_fork+0x364>
ffffffffc02046bc:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc02046c0:	8536                	mv	a0,a3
ffffffffc02046c2:	b539                	j	ffffffffc02044d0 <do_fork+0x16c>
    int ret = -E_NO_FREE_PROC;
ffffffffc02046c4:	556d                	li	a0,-5
ffffffffc02046c6:	b5ad                	j	ffffffffc0204530 <do_fork+0x1cc>
    return last_pid;
ffffffffc02046c8:	00082503          	lw	a0,0(a6)
ffffffffc02046cc:	b511                	j	ffffffffc02044d0 <do_fork+0x16c>
    assert(current->wait_state == 0);
ffffffffc02046ce:	00003697          	auipc	a3,0x3
ffffffffc02046d2:	d9268693          	addi	a3,a3,-622 # ffffffffc0207460 <default_pmm_manager+0xae8>
ffffffffc02046d6:	00002617          	auipc	a2,0x2
ffffffffc02046da:	ef260613          	addi	a2,a2,-270 # ffffffffc02065c8 <commands+0x858>
ffffffffc02046de:	22400593          	li	a1,548
ffffffffc02046e2:	00003517          	auipc	a0,0x3
ffffffffc02046e6:	d6650513          	addi	a0,a0,-666 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc02046ea:	da5fb0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc02046ee:	00002617          	auipc	a2,0x2
ffffffffc02046f2:	2c260613          	addi	a2,a2,706 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc02046f6:	0bd00593          	li	a1,189
ffffffffc02046fa:	00002517          	auipc	a0,0x2
ffffffffc02046fe:	2de50513          	addi	a0,a0,734 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0204702:	d8dfb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204706:	00002617          	auipc	a2,0x2
ffffffffc020470a:	37a60613          	addi	a2,a2,890 # ffffffffc0206a80 <default_pmm_manager+0x108>
ffffffffc020470e:	0b200593          	li	a1,178
ffffffffc0204712:	00002517          	auipc	a0,0x2
ffffffffc0204716:	2c650513          	addi	a0,a0,710 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc020471a:	d75fb0ef          	jal	ra,ffffffffc020048e <__panic>
    proc->pgdir = PADDR(mm->pgdir); // 设置 proc->pgdir 为物理地址 (用于 SATP)
ffffffffc020471e:	86be                	mv	a3,a5
ffffffffc0204720:	00002617          	auipc	a2,0x2
ffffffffc0204724:	33860613          	addi	a2,a2,824 # ffffffffc0206a58 <default_pmm_manager+0xe0>
ffffffffc0204728:	1e400593          	li	a1,484
ffffffffc020472c:	00003517          	auipc	a0,0x3
ffffffffc0204730:	d1c50513          	addi	a0,a0,-740 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc0204734:	d5bfb0ef          	jal	ra,ffffffffc020048e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204738:	00002617          	auipc	a2,0x2
ffffffffc020473c:	32060613          	addi	a2,a2,800 # ffffffffc0206a58 <default_pmm_manager+0xe0>
ffffffffc0204740:	0c500593          	li	a1,197
ffffffffc0204744:	00002517          	auipc	a0,0x2
ffffffffc0204748:	29450513          	addi	a0,a0,660 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc020474c:	d43fb0ef          	jal	ra,ffffffffc020048e <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc0204750:	00003617          	auipc	a2,0x3
ffffffffc0204754:	d3060613          	addi	a2,a2,-720 # ffffffffc0207480 <default_pmm_manager+0xb08>
ffffffffc0204758:	08400593          	li	a1,132
ffffffffc020475c:	00003517          	auipc	a0,0x3
ffffffffc0204760:	d3450513          	addi	a0,a0,-716 # ffffffffc0207490 <default_pmm_manager+0xb18>
ffffffffc0204764:	d2bfb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204768 <kernel_thread>:
{
ffffffffc0204768:	7129                	addi	sp,sp,-320
ffffffffc020476a:	fa22                	sd	s0,304(sp)
ffffffffc020476c:	f626                	sd	s1,296(sp)
ffffffffc020476e:	f24a                	sd	s2,288(sp)
ffffffffc0204770:	84ae                	mv	s1,a1
ffffffffc0204772:	892a                	mv	s2,a0
ffffffffc0204774:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204776:	4581                	li	a1,0
ffffffffc0204778:	12000613          	li	a2,288
ffffffffc020477c:	850a                	mv	a0,sp
{
ffffffffc020477e:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204780:	358010ef          	jal	ra,ffffffffc0205ad8 <memset>
    tf.gpr.s0 = (uintptr_t)fn;  // s0 存放函数指针 (kernel_thread_entry 会调用它)
ffffffffc0204784:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg; // s1 存放函数参数
ffffffffc0204786:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204788:	100027f3          	csrr	a5,sstatus
ffffffffc020478c:	edd7f793          	andi	a5,a5,-291
ffffffffc0204790:	1207e793          	ori	a5,a5,288
ffffffffc0204794:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204796:	860a                	mv	a2,sp
ffffffffc0204798:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020479c:	00000797          	auipc	a5,0x0
ffffffffc02047a0:	9dc78793          	addi	a5,a5,-1572 # ffffffffc0204178 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02047a4:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02047a6:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02047a8:	bbdff0ef          	jal	ra,ffffffffc0204364 <do_fork>
}
ffffffffc02047ac:	70f2                	ld	ra,312(sp)
ffffffffc02047ae:	7452                	ld	s0,304(sp)
ffffffffc02047b0:	74b2                	ld	s1,296(sp)
ffffffffc02047b2:	7912                	ld	s2,288(sp)
ffffffffc02047b4:	6131                	addi	sp,sp,320
ffffffffc02047b6:	8082                	ret

ffffffffc02047b8 <do_exit>:
{
ffffffffc02047b8:	7179                	addi	sp,sp,-48
ffffffffc02047ba:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc02047bc:	000d2417          	auipc	s0,0xd2
ffffffffc02047c0:	65440413          	addi	s0,s0,1620 # ffffffffc02d6e10 <current>
ffffffffc02047c4:	601c                	ld	a5,0(s0)
{
ffffffffc02047c6:	f406                	sd	ra,40(sp)
ffffffffc02047c8:	ec26                	sd	s1,24(sp)
ffffffffc02047ca:	e84a                	sd	s2,16(sp)
ffffffffc02047cc:	e44e                	sd	s3,8(sp)
ffffffffc02047ce:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc02047d0:	000d2717          	auipc	a4,0xd2
ffffffffc02047d4:	64873703          	ld	a4,1608(a4) # ffffffffc02d6e18 <idleproc>
ffffffffc02047d8:	0ce78c63          	beq	a5,a4,ffffffffc02048b0 <do_exit+0xf8>
    if (current == initproc)
ffffffffc02047dc:	000d2497          	auipc	s1,0xd2
ffffffffc02047e0:	64448493          	addi	s1,s1,1604 # ffffffffc02d6e20 <initproc>
ffffffffc02047e4:	6098                	ld	a4,0(s1)
ffffffffc02047e6:	0ee78b63          	beq	a5,a4,ffffffffc02048dc <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc02047ea:	0287b983          	ld	s3,40(a5)
ffffffffc02047ee:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc02047f0:	02098663          	beqz	s3,ffffffffc020481c <do_exit+0x64>
ffffffffc02047f4:	000d2797          	auipc	a5,0xd2
ffffffffc02047f8:	5dc7b783          	ld	a5,1500(a5) # ffffffffc02d6dd0 <boot_pgdir_pa>
ffffffffc02047fc:	577d                	li	a4,-1
ffffffffc02047fe:	177e                	slli	a4,a4,0x3f
ffffffffc0204800:	83b1                	srli	a5,a5,0xc
ffffffffc0204802:	8fd9                	or	a5,a5,a4
ffffffffc0204804:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0204808:	0309a783          	lw	a5,48(s3)
ffffffffc020480c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204810:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc0204814:	cb55                	beqz	a4,ffffffffc02048c8 <do_exit+0x110>
        current->mm = NULL;
ffffffffc0204816:	601c                	ld	a5,0(s0)
ffffffffc0204818:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020481c:	601c                	ld	a5,0(s0)
ffffffffc020481e:	470d                	li	a4,3
ffffffffc0204820:	c398                	sw	a4,0(a5)
    current->exit_code = error_code; // 保存退出码
ffffffffc0204822:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204826:	100027f3          	csrr	a5,sstatus
ffffffffc020482a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020482c:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020482e:	e3f9                	bnez	a5,ffffffffc02048f4 <do_exit+0x13c>
        proc = current->parent;
ffffffffc0204830:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204832:	800007b7          	lui	a5,0x80000
ffffffffc0204836:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0204838:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc020483a:	0ec52703          	lw	a4,236(a0)
ffffffffc020483e:	0af70f63          	beq	a4,a5,ffffffffc02048fc <do_exit+0x144>
        while (current->cptr != NULL)
ffffffffc0204842:	6018                	ld	a4,0(s0)
ffffffffc0204844:	7b7c                	ld	a5,240(a4)
ffffffffc0204846:	c3a1                	beqz	a5,ffffffffc0204886 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204848:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc020484c:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc020484e:	0985                	addi	s3,s3,1
ffffffffc0204850:	a021                	j	ffffffffc0204858 <do_exit+0xa0>
        while (current->cptr != NULL)
ffffffffc0204852:	6018                	ld	a4,0(s0)
ffffffffc0204854:	7b7c                	ld	a5,240(a4)
ffffffffc0204856:	cb85                	beqz	a5,ffffffffc0204886 <do_exit+0xce>
            current->cptr = proc->optr; // 从当前子进程链表移除
ffffffffc0204858:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4e30>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020485c:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr; // 从当前子进程链表移除
ffffffffc020485e:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204860:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0204862:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204866:	10e7b023          	sd	a4,256(a5)
ffffffffc020486a:	c311                	beqz	a4,ffffffffc020486e <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc020486c:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020486e:	4398                	lw	a4,0(a5)
            proc->parent = initproc; // 认贼作父 (划掉) 认 initproc 为父
ffffffffc0204870:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0204872:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204874:	fd271fe3          	bne	a4,s2,ffffffffc0204852 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204878:	0ec52783          	lw	a5,236(a0)
ffffffffc020487c:	fd379be3          	bne	a5,s3,ffffffffc0204852 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0204880:	373000ef          	jal	ra,ffffffffc02053f2 <wakeup_proc>
ffffffffc0204884:	b7f9                	j	ffffffffc0204852 <do_exit+0x9a>
    if (flag)
ffffffffc0204886:	020a1263          	bnez	s4,ffffffffc02048aa <do_exit+0xf2>
    schedule();
ffffffffc020488a:	3eb000ef          	jal	ra,ffffffffc0205474 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020488e:	601c                	ld	a5,0(s0)
ffffffffc0204890:	00003617          	auipc	a2,0x3
ffffffffc0204894:	c3860613          	addi	a2,a2,-968 # ffffffffc02074c8 <default_pmm_manager+0xb50>
ffffffffc0204898:	29c00593          	li	a1,668
ffffffffc020489c:	43d4                	lw	a3,4(a5)
ffffffffc020489e:	00003517          	auipc	a0,0x3
ffffffffc02048a2:	baa50513          	addi	a0,a0,-1110 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc02048a6:	be9fb0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_enable();
ffffffffc02048aa:	904fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02048ae:	bff1                	j	ffffffffc020488a <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc02048b0:	00003617          	auipc	a2,0x3
ffffffffc02048b4:	bf860613          	addi	a2,a2,-1032 # ffffffffc02074a8 <default_pmm_manager+0xb30>
ffffffffc02048b8:	25600593          	li	a1,598
ffffffffc02048bc:	00003517          	auipc	a0,0x3
ffffffffc02048c0:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc02048c4:	bcbfb0ef          	jal	ra,ffffffffc020048e <__panic>
            exit_mmap(mm);  // 释放 VMA 和映射
ffffffffc02048c8:	854e                	mv	a0,s3
ffffffffc02048ca:	a54ff0ef          	jal	ra,ffffffffc0203b1e <exit_mmap>
            put_pgdir(mm);  // 释放页目录表
ffffffffc02048ce:	854e                	mv	a0,s3
ffffffffc02048d0:	9b3ff0ef          	jal	ra,ffffffffc0204282 <put_pgdir>
            mm_destroy(mm); // 释放 mm 结构体
ffffffffc02048d4:	854e                	mv	a0,s3
ffffffffc02048d6:	8acff0ef          	jal	ra,ffffffffc0203982 <mm_destroy>
ffffffffc02048da:	bf35                	j	ffffffffc0204816 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02048dc:	00003617          	auipc	a2,0x3
ffffffffc02048e0:	bdc60613          	addi	a2,a2,-1060 # ffffffffc02074b8 <default_pmm_manager+0xb40>
ffffffffc02048e4:	25a00593          	li	a1,602
ffffffffc02048e8:	00003517          	auipc	a0,0x3
ffffffffc02048ec:	b6050513          	addi	a0,a0,-1184 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc02048f0:	b9ffb0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_disable();
ffffffffc02048f4:	8c0fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc02048f8:	4a05                	li	s4,1
ffffffffc02048fa:	bf1d                	j	ffffffffc0204830 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc02048fc:	2f7000ef          	jal	ra,ffffffffc02053f2 <wakeup_proc>
ffffffffc0204900:	b789                	j	ffffffffc0204842 <do_exit+0x8a>

ffffffffc0204902 <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc0204902:	715d                	addi	sp,sp,-80
ffffffffc0204904:	f84a                	sd	s2,48(sp)
ffffffffc0204906:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD; // 等待子进程状态
ffffffffc0204908:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc020490c:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc020490e:	fc26                	sd	s1,56(sp)
ffffffffc0204910:	f052                	sd	s4,32(sp)
ffffffffc0204912:	ec56                	sd	s5,24(sp)
ffffffffc0204914:	e85a                	sd	s6,16(sp)
ffffffffc0204916:	e45e                	sd	s7,8(sp)
ffffffffc0204918:	e486                	sd	ra,72(sp)
ffffffffc020491a:	e0a2                	sd	s0,64(sp)
ffffffffc020491c:	84aa                	mv	s1,a0
ffffffffc020491e:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0204920:	000d2b97          	auipc	s7,0xd2
ffffffffc0204924:	4f0b8b93          	addi	s7,s7,1264 # ffffffffc02d6e10 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204928:	00050b1b          	sext.w	s6,a0
ffffffffc020492c:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0204930:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD; // 等待子进程状态
ffffffffc0204932:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc0204934:	ccbd                	beqz	s1,ffffffffc02049b2 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204936:	0359e863          	bltu	s3,s5,ffffffffc0204966 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020493a:	45a9                	li	a1,10
ffffffffc020493c:	855a                	mv	a0,s6
ffffffffc020493e:	4f5000ef          	jal	ra,ffffffffc0205632 <hash32>
ffffffffc0204942:	02051793          	slli	a5,a0,0x20
ffffffffc0204946:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020494a:	000ce797          	auipc	a5,0xce
ffffffffc020494e:	43678793          	addi	a5,a5,1078 # ffffffffc02d2d80 <hash_list>
ffffffffc0204952:	953e                	add	a0,a0,a5
ffffffffc0204954:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc0204956:	a029                	j	ffffffffc0204960 <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc0204958:	f2c42783          	lw	a5,-212(s0)
ffffffffc020495c:	02978163          	beq	a5,s1,ffffffffc020497e <do_wait.part.0+0x7c>
ffffffffc0204960:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc0204962:	fe851be3          	bne	a0,s0,ffffffffc0204958 <do_wait.part.0+0x56>
    return -E_BAD_PROC; // 没有符合条件的子进程
ffffffffc0204966:	5579                	li	a0,-2
}
ffffffffc0204968:	60a6                	ld	ra,72(sp)
ffffffffc020496a:	6406                	ld	s0,64(sp)
ffffffffc020496c:	74e2                	ld	s1,56(sp)
ffffffffc020496e:	7942                	ld	s2,48(sp)
ffffffffc0204970:	79a2                	ld	s3,40(sp)
ffffffffc0204972:	7a02                	ld	s4,32(sp)
ffffffffc0204974:	6ae2                	ld	s5,24(sp)
ffffffffc0204976:	6b42                	ld	s6,16(sp)
ffffffffc0204978:	6ba2                	ld	s7,8(sp)
ffffffffc020497a:	6161                	addi	sp,sp,80
ffffffffc020497c:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc020497e:	000bb683          	ld	a3,0(s7)
ffffffffc0204982:	f4843783          	ld	a5,-184(s0)
ffffffffc0204986:	fed790e3          	bne	a5,a3,ffffffffc0204966 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020498a:	f2842703          	lw	a4,-216(s0)
ffffffffc020498e:	478d                	li	a5,3
ffffffffc0204990:	0ef70b63          	beq	a4,a5,ffffffffc0204a86 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0204994:	4785                	li	a5,1
ffffffffc0204996:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD; // 等待子进程状态
ffffffffc0204998:	0f26a623          	sw	s2,236(a3)
        schedule(); // 让出 CPU
ffffffffc020499c:	2d9000ef          	jal	ra,ffffffffc0205474 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc02049a0:	000bb783          	ld	a5,0(s7)
ffffffffc02049a4:	0b07a783          	lw	a5,176(a5)
ffffffffc02049a8:	8b85                	andi	a5,a5,1
ffffffffc02049aa:	d7c9                	beqz	a5,ffffffffc0204934 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc02049ac:	555d                	li	a0,-9
ffffffffc02049ae:	e0bff0ef          	jal	ra,ffffffffc02047b8 <do_exit>
        proc = current->cptr;
ffffffffc02049b2:	000bb683          	ld	a3,0(s7)
ffffffffc02049b6:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc02049b8:	d45d                	beqz	s0,ffffffffc0204966 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02049ba:	470d                	li	a4,3
ffffffffc02049bc:	a021                	j	ffffffffc02049c4 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc02049be:	10043403          	ld	s0,256(s0)
ffffffffc02049c2:	d869                	beqz	s0,ffffffffc0204994 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02049c4:	401c                	lw	a5,0(s0)
ffffffffc02049c6:	fee79ce3          	bne	a5,a4,ffffffffc02049be <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc02049ca:	000d2797          	auipc	a5,0xd2
ffffffffc02049ce:	44e7b783          	ld	a5,1102(a5) # ffffffffc02d6e18 <idleproc>
ffffffffc02049d2:	0c878963          	beq	a5,s0,ffffffffc0204aa4 <do_wait.part.0+0x1a2>
ffffffffc02049d6:	000d2797          	auipc	a5,0xd2
ffffffffc02049da:	44a7b783          	ld	a5,1098(a5) # ffffffffc02d6e20 <initproc>
ffffffffc02049de:	0cf40363          	beq	s0,a5,ffffffffc0204aa4 <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc02049e2:	000a0663          	beqz	s4,ffffffffc02049ee <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc02049e6:	0e842783          	lw	a5,232(s0)
ffffffffc02049ea:	00fa2023          	sw	a5,0(s4)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02049ee:	100027f3          	csrr	a5,sstatus
ffffffffc02049f2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02049f4:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02049f6:	e7c1                	bnez	a5,ffffffffc0204a7e <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02049f8:	6c70                	ld	a2,216(s0)
ffffffffc02049fa:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc02049fc:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0204a00:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0204a02:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204a04:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204a06:	6470                	ld	a2,200(s0)
ffffffffc0204a08:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0204a0a:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204a0c:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc0204a0e:	c319                	beqz	a4,ffffffffc0204a14 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0204a10:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc0204a12:	7c7c                	ld	a5,248(s0)
ffffffffc0204a14:	c3b5                	beqz	a5,ffffffffc0204a78 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0204a16:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc0204a1a:	000d2717          	auipc	a4,0xd2
ffffffffc0204a1e:	40e70713          	addi	a4,a4,1038 # ffffffffc02d6e28 <nr_process>
ffffffffc0204a22:	431c                	lw	a5,0(a4)
ffffffffc0204a24:	37fd                	addiw	a5,a5,-1
ffffffffc0204a26:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc0204a28:	e5a9                	bnez	a1,ffffffffc0204a72 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204a2a:	6814                	ld	a3,16(s0)
ffffffffc0204a2c:	c02007b7          	lui	a5,0xc0200
ffffffffc0204a30:	04f6ee63          	bltu	a3,a5,ffffffffc0204a8c <do_wait.part.0+0x18a>
ffffffffc0204a34:	000d2797          	auipc	a5,0xd2
ffffffffc0204a38:	3c47b783          	ld	a5,964(a5) # ffffffffc02d6df8 <va_pa_offset>
ffffffffc0204a3c:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204a3e:	82b1                	srli	a3,a3,0xc
ffffffffc0204a40:	000d2797          	auipc	a5,0xd2
ffffffffc0204a44:	3a07b783          	ld	a5,928(a5) # ffffffffc02d6de0 <npage>
ffffffffc0204a48:	06f6fa63          	bgeu	a3,a5,ffffffffc0204abc <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0204a4c:	00004517          	auipc	a0,0x4
ffffffffc0204a50:	9dc53503          	ld	a0,-1572(a0) # ffffffffc0208428 <nbase>
ffffffffc0204a54:	8e89                	sub	a3,a3,a0
ffffffffc0204a56:	069a                	slli	a3,a3,0x6
ffffffffc0204a58:	000d2517          	auipc	a0,0xd2
ffffffffc0204a5c:	39053503          	ld	a0,912(a0) # ffffffffc02d6de8 <pages>
ffffffffc0204a60:	9536                	add	a0,a0,a3
ffffffffc0204a62:	4589                	li	a1,2
ffffffffc0204a64:	d7efd0ef          	jal	ra,ffffffffc0201fe2 <free_pages>
    kfree(proc);      // 释放 PCB 内存
ffffffffc0204a68:	8522                	mv	a0,s0
ffffffffc0204a6a:	c0cfd0ef          	jal	ra,ffffffffc0201e76 <kfree>
    return 0;
ffffffffc0204a6e:	4501                	li	a0,0
ffffffffc0204a70:	bde5                	j	ffffffffc0204968 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0204a72:	f3dfb0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0204a76:	bf55                	j	ffffffffc0204a2a <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc0204a78:	701c                	ld	a5,32(s0)
ffffffffc0204a7a:	fbf8                	sd	a4,240(a5)
ffffffffc0204a7c:	bf79                	j	ffffffffc0204a1a <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0204a7e:	f37fb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0204a82:	4585                	li	a1,1
ffffffffc0204a84:	bf95                	j	ffffffffc02049f8 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204a86:	f2840413          	addi	s0,s0,-216
ffffffffc0204a8a:	b781                	j	ffffffffc02049ca <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0204a8c:	00002617          	auipc	a2,0x2
ffffffffc0204a90:	fcc60613          	addi	a2,a2,-52 # ffffffffc0206a58 <default_pmm_manager+0xe0>
ffffffffc0204a94:	0c500593          	li	a1,197
ffffffffc0204a98:	00002517          	auipc	a0,0x2
ffffffffc0204a9c:	f4050513          	addi	a0,a0,-192 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0204aa0:	9effb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0204aa4:	00003617          	auipc	a2,0x3
ffffffffc0204aa8:	a4460613          	addi	a2,a2,-1468 # ffffffffc02074e8 <default_pmm_manager+0xb70>
ffffffffc0204aac:	40000593          	li	a1,1024
ffffffffc0204ab0:	00003517          	auipc	a0,0x3
ffffffffc0204ab4:	99850513          	addi	a0,a0,-1640 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc0204ab8:	9d7fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204abc:	00002617          	auipc	a2,0x2
ffffffffc0204ac0:	fc460613          	addi	a2,a2,-60 # ffffffffc0206a80 <default_pmm_manager+0x108>
ffffffffc0204ac4:	0b200593          	li	a1,178
ffffffffc0204ac8:	00002517          	auipc	a0,0x2
ffffffffc0204acc:	f1050513          	addi	a0,a0,-240 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0204ad0:	9bffb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204ad4 <init_main>:
 * init_main - Init 进程的主体函数
 * * [功能]: 创建 user_main，并回收所有用户进程。
 */
static int
init_main(void *arg)
{
ffffffffc0204ad4:	1141                	addi	sp,sp,-16
ffffffffc0204ad6:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204ad8:	d4afd0ef          	jal	ra,ffffffffc0202022 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0204adc:	ae6fd0ef          	jal	ra,ffffffffc0201dc2 <kallocated>

    // 创建 user_main 内核线程
    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204ae0:	4601                	li	a2,0
ffffffffc0204ae2:	4581                	li	a1,0
ffffffffc0204ae4:	fffff517          	auipc	a0,0xfffff
ffffffffc0204ae8:	72050513          	addi	a0,a0,1824 # ffffffffc0204204 <user_main>
ffffffffc0204aec:	c7dff0ef          	jal	ra,ffffffffc0204768 <kernel_thread>
    if (pid <= 0)
ffffffffc0204af0:	00a04563          	bgtz	a0,ffffffffc0204afa <init_main+0x26>
ffffffffc0204af4:	a071                	j	ffffffffc0204b80 <init_main+0xac>
    }

    // 等待所有子进程结束 (当 user_main 及其 fork 出来的所有进程都退出后，do_wait 才会返回非0)
    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc0204af6:	17f000ef          	jal	ra,ffffffffc0205474 <schedule>
    if (code_store != NULL)
ffffffffc0204afa:	4581                	li	a1,0
ffffffffc0204afc:	4501                	li	a0,0
ffffffffc0204afe:	e05ff0ef          	jal	ra,ffffffffc0204902 <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc0204b02:	d975                	beqz	a0,ffffffffc0204af6 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0204b04:	00003517          	auipc	a0,0x3
ffffffffc0204b08:	a2450513          	addi	a0,a0,-1500 # ffffffffc0207528 <default_pmm_manager+0xbb0>
ffffffffc0204b0c:	e88fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    // 确保系统回到了只有 initproc 和 idleproc 的状态
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204b10:	000d2797          	auipc	a5,0xd2
ffffffffc0204b14:	3107b783          	ld	a5,784(a5) # ffffffffc02d6e20 <initproc>
ffffffffc0204b18:	7bf8                	ld	a4,240(a5)
ffffffffc0204b1a:	e339                	bnez	a4,ffffffffc0204b60 <init_main+0x8c>
ffffffffc0204b1c:	7ff8                	ld	a4,248(a5)
ffffffffc0204b1e:	e329                	bnez	a4,ffffffffc0204b60 <init_main+0x8c>
ffffffffc0204b20:	1007b703          	ld	a4,256(a5)
ffffffffc0204b24:	ef15                	bnez	a4,ffffffffc0204b60 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0204b26:	000d2697          	auipc	a3,0xd2
ffffffffc0204b2a:	3026a683          	lw	a3,770(a3) # ffffffffc02d6e28 <nr_process>
ffffffffc0204b2e:	4709                	li	a4,2
ffffffffc0204b30:	0ae69463          	bne	a3,a4,ffffffffc0204bd8 <init_main+0x104>
    return listelm->next;
ffffffffc0204b34:	000d2697          	auipc	a3,0xd2
ffffffffc0204b38:	24c68693          	addi	a3,a3,588 # ffffffffc02d6d80 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204b3c:	6698                	ld	a4,8(a3)
ffffffffc0204b3e:	0c878793          	addi	a5,a5,200
ffffffffc0204b42:	06f71b63          	bne	a4,a5,ffffffffc0204bb8 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204b46:	629c                	ld	a5,0(a3)
ffffffffc0204b48:	04f71863          	bne	a4,a5,ffffffffc0204b98 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204b4c:	00003517          	auipc	a0,0x3
ffffffffc0204b50:	ac450513          	addi	a0,a0,-1340 # ffffffffc0207610 <default_pmm_manager+0xc98>
ffffffffc0204b54:	e40fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
}
ffffffffc0204b58:	60a2                	ld	ra,8(sp)
ffffffffc0204b5a:	4501                	li	a0,0
ffffffffc0204b5c:	0141                	addi	sp,sp,16
ffffffffc0204b5e:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204b60:	00003697          	auipc	a3,0x3
ffffffffc0204b64:	9f068693          	addi	a3,a3,-1552 # ffffffffc0207550 <default_pmm_manager+0xbd8>
ffffffffc0204b68:	00002617          	auipc	a2,0x2
ffffffffc0204b6c:	a6060613          	addi	a2,a2,-1440 # ffffffffc02065c8 <commands+0x858>
ffffffffc0204b70:	48600593          	li	a1,1158
ffffffffc0204b74:	00003517          	auipc	a0,0x3
ffffffffc0204b78:	8d450513          	addi	a0,a0,-1836 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc0204b7c:	913fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("create user_main failed.\n");
ffffffffc0204b80:	00003617          	auipc	a2,0x3
ffffffffc0204b84:	98860613          	addi	a2,a2,-1656 # ffffffffc0207508 <default_pmm_manager+0xb90>
ffffffffc0204b88:	47b00593          	li	a1,1147
ffffffffc0204b8c:	00003517          	auipc	a0,0x3
ffffffffc0204b90:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc0204b94:	8fbfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204b98:	00003697          	auipc	a3,0x3
ffffffffc0204b9c:	a4868693          	addi	a3,a3,-1464 # ffffffffc02075e0 <default_pmm_manager+0xc68>
ffffffffc0204ba0:	00002617          	auipc	a2,0x2
ffffffffc0204ba4:	a2860613          	addi	a2,a2,-1496 # ffffffffc02065c8 <commands+0x858>
ffffffffc0204ba8:	48900593          	li	a1,1161
ffffffffc0204bac:	00003517          	auipc	a0,0x3
ffffffffc0204bb0:	89c50513          	addi	a0,a0,-1892 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc0204bb4:	8dbfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204bb8:	00003697          	auipc	a3,0x3
ffffffffc0204bbc:	9f868693          	addi	a3,a3,-1544 # ffffffffc02075b0 <default_pmm_manager+0xc38>
ffffffffc0204bc0:	00002617          	auipc	a2,0x2
ffffffffc0204bc4:	a0860613          	addi	a2,a2,-1528 # ffffffffc02065c8 <commands+0x858>
ffffffffc0204bc8:	48800593          	li	a1,1160
ffffffffc0204bcc:	00003517          	auipc	a0,0x3
ffffffffc0204bd0:	87c50513          	addi	a0,a0,-1924 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc0204bd4:	8bbfb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_process == 2);
ffffffffc0204bd8:	00003697          	auipc	a3,0x3
ffffffffc0204bdc:	9c868693          	addi	a3,a3,-1592 # ffffffffc02075a0 <default_pmm_manager+0xc28>
ffffffffc0204be0:	00002617          	auipc	a2,0x2
ffffffffc0204be4:	9e860613          	addi	a2,a2,-1560 # ffffffffc02065c8 <commands+0x858>
ffffffffc0204be8:	48700593          	li	a1,1159
ffffffffc0204bec:	00003517          	auipc	a0,0x3
ffffffffc0204bf0:	85c50513          	addi	a0,a0,-1956 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc0204bf4:	89bfb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204bf8 <do_execve>:
{
ffffffffc0204bf8:	7171                	addi	sp,sp,-176
ffffffffc0204bfa:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204bfc:	000d2d97          	auipc	s11,0xd2
ffffffffc0204c00:	214d8d93          	addi	s11,s11,532 # ffffffffc02d6e10 <current>
ffffffffc0204c04:	000db783          	ld	a5,0(s11)
{
ffffffffc0204c08:	e94a                	sd	s2,144(sp)
ffffffffc0204c0a:	f122                	sd	s0,160(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204c0c:	0287b903          	ld	s2,40(a5)
{
ffffffffc0204c10:	ed26                	sd	s1,152(sp)
ffffffffc0204c12:	f8da                	sd	s6,112(sp)
ffffffffc0204c14:	84aa                	mv	s1,a0
ffffffffc0204c16:	8b32                	mv	s6,a2
ffffffffc0204c18:	842e                	mv	s0,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204c1a:	862e                	mv	a2,a1
ffffffffc0204c1c:	4681                	li	a3,0
ffffffffc0204c1e:	85aa                	mv	a1,a0
ffffffffc0204c20:	854a                	mv	a0,s2
{
ffffffffc0204c22:	f506                	sd	ra,168(sp)
ffffffffc0204c24:	e54e                	sd	s3,136(sp)
ffffffffc0204c26:	e152                	sd	s4,128(sp)
ffffffffc0204c28:	fcd6                	sd	s5,120(sp)
ffffffffc0204c2a:	f4de                	sd	s7,104(sp)
ffffffffc0204c2c:	f0e2                	sd	s8,96(sp)
ffffffffc0204c2e:	ece6                	sd	s9,88(sp)
ffffffffc0204c30:	e8ea                	sd	s10,80(sp)
ffffffffc0204c32:	f05a                	sd	s6,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204c34:	a84ff0ef          	jal	ra,ffffffffc0203eb8 <user_mem_check>
ffffffffc0204c38:	40050a63          	beqz	a0,ffffffffc020504c <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204c3c:	4641                	li	a2,16
ffffffffc0204c3e:	4581                	li	a1,0
ffffffffc0204c40:	1808                	addi	a0,sp,48
ffffffffc0204c42:	697000ef          	jal	ra,ffffffffc0205ad8 <memset>
    memcpy(local_name, name, len);
ffffffffc0204c46:	47bd                	li	a5,15
ffffffffc0204c48:	8622                	mv	a2,s0
ffffffffc0204c4a:	1e87e263          	bltu	a5,s0,ffffffffc0204e2e <do_execve+0x236>
ffffffffc0204c4e:	85a6                	mv	a1,s1
ffffffffc0204c50:	1808                	addi	a0,sp,48
ffffffffc0204c52:	699000ef          	jal	ra,ffffffffc0205aea <memcpy>
    if (mm != NULL)
ffffffffc0204c56:	1e090363          	beqz	s2,ffffffffc0204e3c <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc0204c5a:	00002517          	auipc	a0,0x2
ffffffffc0204c5e:	54e50513          	addi	a0,a0,1358 # ffffffffc02071a8 <default_pmm_manager+0x830>
ffffffffc0204c62:	d6afb0ef          	jal	ra,ffffffffc02001cc <cputs>
ffffffffc0204c66:	000d2797          	auipc	a5,0xd2
ffffffffc0204c6a:	16a7b783          	ld	a5,362(a5) # ffffffffc02d6dd0 <boot_pgdir_pa>
ffffffffc0204c6e:	577d                	li	a4,-1
ffffffffc0204c70:	177e                	slli	a4,a4,0x3f
ffffffffc0204c72:	83b1                	srli	a5,a5,0xc
ffffffffc0204c74:	8fd9                	or	a5,a5,a4
ffffffffc0204c76:	18079073          	csrw	satp,a5
ffffffffc0204c7a:	03092783          	lw	a5,48(s2) # ffffffff80000030 <_binary_obj___user_exit_out_size+0xffffffff7fff4d60>
ffffffffc0204c7e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204c82:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0)
ffffffffc0204c86:	2c070463          	beqz	a4,ffffffffc0204f4e <do_execve+0x356>
        current->mm = NULL;
ffffffffc0204c8a:	000db783          	ld	a5,0(s11)
ffffffffc0204c8e:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0204c92:	bb1fe0ef          	jal	ra,ffffffffc0203842 <mm_create>
ffffffffc0204c96:	842a                	mv	s0,a0
ffffffffc0204c98:	1c050d63          	beqz	a0,ffffffffc0204e72 <do_execve+0x27a>
    if ((page = alloc_page()) == NULL)
ffffffffc0204c9c:	4505                	li	a0,1
ffffffffc0204c9e:	b06fd0ef          	jal	ra,ffffffffc0201fa4 <alloc_pages>
ffffffffc0204ca2:	3a050963          	beqz	a0,ffffffffc0205054 <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc0204ca6:	000d2c97          	auipc	s9,0xd2
ffffffffc0204caa:	142c8c93          	addi	s9,s9,322 # ffffffffc02d6de8 <pages>
ffffffffc0204cae:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204cb2:	000d2c17          	auipc	s8,0xd2
ffffffffc0204cb6:	12ec0c13          	addi	s8,s8,302 # ffffffffc02d6de0 <npage>
    return page - pages + nbase;
ffffffffc0204cba:	00003717          	auipc	a4,0x3
ffffffffc0204cbe:	76e73703          	ld	a4,1902(a4) # ffffffffc0208428 <nbase>
ffffffffc0204cc2:	40d506b3          	sub	a3,a0,a3
ffffffffc0204cc6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204cc8:	5a7d                	li	s4,-1
ffffffffc0204cca:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0204cce:	96ba                	add	a3,a3,a4
ffffffffc0204cd0:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204cd2:	00ca5713          	srli	a4,s4,0xc
ffffffffc0204cd6:	ec3a                	sd	a4,24(sp)
ffffffffc0204cd8:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204cda:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204cdc:	38f77063          	bgeu	a4,a5,ffffffffc020505c <do_execve+0x464>
ffffffffc0204ce0:	000d2a97          	auipc	s5,0xd2
ffffffffc0204ce4:	118a8a93          	addi	s5,s5,280 # ffffffffc02d6df8 <va_pa_offset>
ffffffffc0204ce8:	000ab483          	ld	s1,0(s5)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204cec:	6605                	lui	a2,0x1
ffffffffc0204cee:	000d2597          	auipc	a1,0xd2
ffffffffc0204cf2:	0ea5b583          	ld	a1,234(a1) # ffffffffc02d6dd8 <boot_pgdir_va>
ffffffffc0204cf6:	94b6                	add	s1,s1,a3
ffffffffc0204cf8:	8526                	mv	a0,s1
ffffffffc0204cfa:	5f1000ef          	jal	ra,ffffffffc0205aea <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204cfe:	7782                	ld	a5,32(sp)
ffffffffc0204d00:	4398                	lw	a4,0(a5)
ffffffffc0204d02:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204d06:	ec04                	sd	s1,24(s0)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204d08:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b92af>
ffffffffc0204d0c:	14f71963          	bne	a4,a5,ffffffffc0204e5e <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204d10:	7682                	ld	a3,32(sp)
    struct Page *page = NULL;
ffffffffc0204d12:	4b81                	li	s7,0
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204d14:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204d18:	0206b903          	ld	s2,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204d1c:	00371793          	slli	a5,a4,0x3
ffffffffc0204d20:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204d22:	9936                	add	s2,s2,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204d24:	078e                	slli	a5,a5,0x3
ffffffffc0204d26:	97ca                	add	a5,a5,s2
ffffffffc0204d28:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204d2a:	00f97c63          	bgeu	s2,a5,ffffffffc0204d42 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204d2e:	00092783          	lw	a5,0(s2)
ffffffffc0204d32:	4705                	li	a4,1
ffffffffc0204d34:	14e78163          	beq	a5,a4,ffffffffc0204e76 <do_execve+0x27e>
    for (; ph < ph_end; ph++)
ffffffffc0204d38:	77a2                	ld	a5,40(sp)
ffffffffc0204d3a:	03890913          	addi	s2,s2,56
ffffffffc0204d3e:	fef968e3          	bltu	s2,a5,ffffffffc0204d2e <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204d42:	4701                	li	a4,0
ffffffffc0204d44:	46ad                	li	a3,11
ffffffffc0204d46:	00100637          	lui	a2,0x100
ffffffffc0204d4a:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204d4e:	8522                	mv	a0,s0
ffffffffc0204d50:	c85fe0ef          	jal	ra,ffffffffc02039d4 <mm_map>
ffffffffc0204d54:	89aa                	mv	s3,a0
ffffffffc0204d56:	1e051263          	bnez	a0,ffffffffc0204f3a <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204d5a:	6c08                	ld	a0,24(s0)
ffffffffc0204d5c:	467d                	li	a2,31
ffffffffc0204d5e:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204d62:	9fbfe0ef          	jal	ra,ffffffffc020375c <pgdir_alloc_page>
ffffffffc0204d66:	38050363          	beqz	a0,ffffffffc02050ec <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204d6a:	6c08                	ld	a0,24(s0)
ffffffffc0204d6c:	467d                	li	a2,31
ffffffffc0204d6e:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204d72:	9ebfe0ef          	jal	ra,ffffffffc020375c <pgdir_alloc_page>
ffffffffc0204d76:	34050b63          	beqz	a0,ffffffffc02050cc <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204d7a:	6c08                	ld	a0,24(s0)
ffffffffc0204d7c:	467d                	li	a2,31
ffffffffc0204d7e:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204d82:	9dbfe0ef          	jal	ra,ffffffffc020375c <pgdir_alloc_page>
ffffffffc0204d86:	32050363          	beqz	a0,ffffffffc02050ac <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204d8a:	6c08                	ld	a0,24(s0)
ffffffffc0204d8c:	467d                	li	a2,31
ffffffffc0204d8e:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204d92:	9cbfe0ef          	jal	ra,ffffffffc020375c <pgdir_alloc_page>
ffffffffc0204d96:	2e050b63          	beqz	a0,ffffffffc020508c <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc0204d9a:	581c                	lw	a5,48(s0)
    current->mm = mm;
ffffffffc0204d9c:	000db603          	ld	a2,0(s11)
    current->pgdir = PADDR(mm->pgdir); // 记录页目录物理地址
ffffffffc0204da0:	6c14                	ld	a3,24(s0)
ffffffffc0204da2:	2785                	addiw	a5,a5,1
ffffffffc0204da4:	d81c                	sw	a5,48(s0)
    current->mm = mm;
ffffffffc0204da6:	f600                	sd	s0,40(a2)
    current->pgdir = PADDR(mm->pgdir); // 记录页目录物理地址
ffffffffc0204da8:	c02007b7          	lui	a5,0xc0200
ffffffffc0204dac:	2cf6e463          	bltu	a3,a5,ffffffffc0205074 <do_execve+0x47c>
ffffffffc0204db0:	000ab783          	ld	a5,0(s5)
ffffffffc0204db4:	577d                	li	a4,-1
ffffffffc0204db6:	177e                	slli	a4,a4,0x3f
ffffffffc0204db8:	8e9d                	sub	a3,a3,a5
ffffffffc0204dba:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204dbe:	f654                	sd	a3,168(a2)
ffffffffc0204dc0:	8fd9                	or	a5,a5,a4
ffffffffc0204dc2:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0204dc6:	7244                	ld	s1,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204dc8:	4581                	li	a1,0
ffffffffc0204dca:	12000613          	li	a2,288
ffffffffc0204dce:	8526                	mv	a0,s1
ffffffffc0204dd0:	509000ef          	jal	ra,ffffffffc0205ad8 <memset>
    tf->epc = elf->e_entry;
ffffffffc0204dd4:	7782                	ld	a5,32(sp)
ffffffffc0204dd6:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204dd8:	4785                	li	a5,1
ffffffffc0204dda:	07fe                	slli	a5,a5,0x1f
ffffffffc0204ddc:	e89c                	sd	a5,16(s1)
    tf->epc = elf->e_entry;
ffffffffc0204dde:	10e4b423          	sd	a4,264(s1)
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204de2:	100027f3          	csrr	a5,sstatus
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204de6:	000db403          	ld	s0,0(s11)
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204dea:	edf7f793          	andi	a5,a5,-289
ffffffffc0204dee:	0207e793          	ori	a5,a5,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204df2:	0b440413          	addi	s0,s0,180
ffffffffc0204df6:	4641                	li	a2,16
ffffffffc0204df8:	4581                	li	a1,0
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204dfa:	10f4b023          	sd	a5,256(s1)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204dfe:	8522                	mv	a0,s0
ffffffffc0204e00:	4d9000ef          	jal	ra,ffffffffc0205ad8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204e04:	463d                	li	a2,15
ffffffffc0204e06:	180c                	addi	a1,sp,48
ffffffffc0204e08:	8522                	mv	a0,s0
ffffffffc0204e0a:	4e1000ef          	jal	ra,ffffffffc0205aea <memcpy>
}
ffffffffc0204e0e:	70aa                	ld	ra,168(sp)
ffffffffc0204e10:	740a                	ld	s0,160(sp)
ffffffffc0204e12:	64ea                	ld	s1,152(sp)
ffffffffc0204e14:	694a                	ld	s2,144(sp)
ffffffffc0204e16:	6a0a                	ld	s4,128(sp)
ffffffffc0204e18:	7ae6                	ld	s5,120(sp)
ffffffffc0204e1a:	7b46                	ld	s6,112(sp)
ffffffffc0204e1c:	7ba6                	ld	s7,104(sp)
ffffffffc0204e1e:	7c06                	ld	s8,96(sp)
ffffffffc0204e20:	6ce6                	ld	s9,88(sp)
ffffffffc0204e22:	6d46                	ld	s10,80(sp)
ffffffffc0204e24:	6da6                	ld	s11,72(sp)
ffffffffc0204e26:	854e                	mv	a0,s3
ffffffffc0204e28:	69aa                	ld	s3,136(sp)
ffffffffc0204e2a:	614d                	addi	sp,sp,176
ffffffffc0204e2c:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0204e2e:	463d                	li	a2,15
ffffffffc0204e30:	85a6                	mv	a1,s1
ffffffffc0204e32:	1808                	addi	a0,sp,48
ffffffffc0204e34:	4b7000ef          	jal	ra,ffffffffc0205aea <memcpy>
    if (mm != NULL)
ffffffffc0204e38:	e20911e3          	bnez	s2,ffffffffc0204c5a <do_execve+0x62>
    if (current->mm != NULL)
ffffffffc0204e3c:	000db783          	ld	a5,0(s11)
ffffffffc0204e40:	779c                	ld	a5,40(a5)
ffffffffc0204e42:	e40788e3          	beqz	a5,ffffffffc0204c92 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0204e46:	00002617          	auipc	a2,0x2
ffffffffc0204e4a:	7ea60613          	addi	a2,a2,2026 # ffffffffc0207630 <default_pmm_manager+0xcb8>
ffffffffc0204e4e:	2b600593          	li	a1,694
ffffffffc0204e52:	00002517          	auipc	a0,0x2
ffffffffc0204e56:	5f650513          	addi	a0,a0,1526 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc0204e5a:	e34fb0ef          	jal	ra,ffffffffc020048e <__panic>
    put_pgdir(mm);
ffffffffc0204e5e:	8522                	mv	a0,s0
ffffffffc0204e60:	c22ff0ef          	jal	ra,ffffffffc0204282 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204e64:	8522                	mv	a0,s0
ffffffffc0204e66:	b1dfe0ef          	jal	ra,ffffffffc0203982 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0204e6a:	59e1                	li	s3,-8
    do_exit(ret); // 加载失败，直接退出
ffffffffc0204e6c:	854e                	mv	a0,s3
ffffffffc0204e6e:	94bff0ef          	jal	ra,ffffffffc02047b8 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0204e72:	59f1                	li	s3,-4
ffffffffc0204e74:	bfe5                	j	ffffffffc0204e6c <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204e76:	02893603          	ld	a2,40(s2)
ffffffffc0204e7a:	02093783          	ld	a5,32(s2)
ffffffffc0204e7e:	1cf66d63          	bltu	a2,a5,ffffffffc0205058 <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;  // 可执行
ffffffffc0204e82:	00492783          	lw	a5,4(s2)
ffffffffc0204e86:	0017f693          	andi	a3,a5,1
ffffffffc0204e8a:	c291                	beqz	a3,ffffffffc0204e8e <do_execve+0x296>
ffffffffc0204e8c:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE; // 可写
ffffffffc0204e8e:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;  // 可读
ffffffffc0204e92:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE; // 可写
ffffffffc0204e94:	e779                	bnez	a4,ffffffffc0204f62 <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V; 
ffffffffc0204e96:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;  // 可读
ffffffffc0204e98:	c781                	beqz	a5,ffffffffc0204ea0 <do_execve+0x2a8>
ffffffffc0204e9a:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0204e9e:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0204ea0:	0026f793          	andi	a5,a3,2
ffffffffc0204ea4:	e3f1                	bnez	a5,ffffffffc0204f68 <do_execve+0x370>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0204ea6:	0046f793          	andi	a5,a3,4
ffffffffc0204eaa:	c399                	beqz	a5,ffffffffc0204eb0 <do_execve+0x2b8>
ffffffffc0204eac:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204eb0:	01093583          	ld	a1,16(s2)
ffffffffc0204eb4:	4701                	li	a4,0
ffffffffc0204eb6:	8522                	mv	a0,s0
ffffffffc0204eb8:	b1dfe0ef          	jal	ra,ffffffffc02039d4 <mm_map>
ffffffffc0204ebc:	89aa                	mv	s3,a0
ffffffffc0204ebe:	ed35                	bnez	a0,ffffffffc0204f3a <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204ec0:	01093b03          	ld	s6,16(s2)
ffffffffc0204ec4:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz; // 拷贝数据的结束地址 (不包含 BSS)
ffffffffc0204ec6:	02093983          	ld	s3,32(s2)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204eca:	00893483          	ld	s1,8(s2)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204ece:	00fb7a33          	and	s4,s6,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204ed2:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz; // 拷贝数据的结束地址 (不包含 BSS)
ffffffffc0204ed4:	99da                	add	s3,s3,s6
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204ed6:	94be                	add	s1,s1,a5
        while (start < end)
ffffffffc0204ed8:	053b6963          	bltu	s6,s3,ffffffffc0204f2a <do_execve+0x332>
ffffffffc0204edc:	aa95                	j	ffffffffc0205050 <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204ede:	6785                	lui	a5,0x1
ffffffffc0204ee0:	414b0533          	sub	a0,s6,s4
ffffffffc0204ee4:	9a3e                	add	s4,s4,a5
ffffffffc0204ee6:	416a0633          	sub	a2,s4,s6
            if (end < la)
ffffffffc0204eea:	0149f463          	bgeu	s3,s4,ffffffffc0204ef2 <do_execve+0x2fa>
                size -= la - end; // 如果这是最后一页且未填满，调整 size
ffffffffc0204eee:	41698633          	sub	a2,s3,s6
    return page - pages + nbase;
ffffffffc0204ef2:	000cb683          	ld	a3,0(s9)
ffffffffc0204ef6:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204ef8:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204efc:	40db86b3          	sub	a3,s7,a3
ffffffffc0204f00:	8699                	srai	a3,a3,0x6
ffffffffc0204f02:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204f04:	67e2                	ld	a5,24(sp)
ffffffffc0204f06:	00f6f8b3          	and	a7,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204f0a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204f0c:	14b8f863          	bgeu	a7,a1,ffffffffc020505c <do_execve+0x464>
ffffffffc0204f10:	000ab883          	ld	a7,0(s5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204f14:	85a6                	mv	a1,s1
            start += size, from += size;
ffffffffc0204f16:	9b32                	add	s6,s6,a2
ffffffffc0204f18:	96c6                	add	a3,a3,a7
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204f1a:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0204f1c:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204f1e:	3cd000ef          	jal	ra,ffffffffc0205aea <memcpy>
            start += size, from += size;
ffffffffc0204f22:	6622                	ld	a2,8(sp)
ffffffffc0204f24:	94b2                	add	s1,s1,a2
        while (start < end)
ffffffffc0204f26:	053b7363          	bgeu	s6,s3,ffffffffc0204f6c <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204f2a:	6c08                	ld	a0,24(s0)
ffffffffc0204f2c:	866a                	mv	a2,s10
ffffffffc0204f2e:	85d2                	mv	a1,s4
ffffffffc0204f30:	82dfe0ef          	jal	ra,ffffffffc020375c <pgdir_alloc_page>
ffffffffc0204f34:	8baa                	mv	s7,a0
ffffffffc0204f36:	f545                	bnez	a0,ffffffffc0204ede <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0204f38:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0204f3a:	8522                	mv	a0,s0
ffffffffc0204f3c:	be3fe0ef          	jal	ra,ffffffffc0203b1e <exit_mmap>
    put_pgdir(mm);
ffffffffc0204f40:	8522                	mv	a0,s0
ffffffffc0204f42:	b40ff0ef          	jal	ra,ffffffffc0204282 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204f46:	8522                	mv	a0,s0
ffffffffc0204f48:	a3bfe0ef          	jal	ra,ffffffffc0203982 <mm_destroy>
    return ret;
ffffffffc0204f4c:	b705                	j	ffffffffc0204e6c <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0204f4e:	854a                	mv	a0,s2
ffffffffc0204f50:	bcffe0ef          	jal	ra,ffffffffc0203b1e <exit_mmap>
            put_pgdir(mm);
ffffffffc0204f54:	854a                	mv	a0,s2
ffffffffc0204f56:	b2cff0ef          	jal	ra,ffffffffc0204282 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204f5a:	854a                	mv	a0,s2
ffffffffc0204f5c:	a27fe0ef          	jal	ra,ffffffffc0203982 <mm_destroy>
ffffffffc0204f60:	b32d                	j	ffffffffc0204c8a <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE; // 可写
ffffffffc0204f62:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;  // 可读
ffffffffc0204f66:	fb95                	bnez	a5,ffffffffc0204e9a <do_execve+0x2a2>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0204f68:	4d5d                	li	s10,23
ffffffffc0204f6a:	bf35                	j	ffffffffc0204ea6 <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz; // 整个段的结束地址 (包含 BSS)
ffffffffc0204f6c:	01093483          	ld	s1,16(s2)
ffffffffc0204f70:	02893683          	ld	a3,40(s2)
ffffffffc0204f74:	94b6                	add	s1,s1,a3
        if (start < la)
ffffffffc0204f76:	074b7d63          	bgeu	s6,s4,ffffffffc0204ff0 <do_execve+0x3f8>
            if (start == end)
ffffffffc0204f7a:	db648fe3          	beq	s1,s6,ffffffffc0204d38 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204f7e:	6785                	lui	a5,0x1
ffffffffc0204f80:	00fb0533          	add	a0,s6,a5
ffffffffc0204f84:	41450533          	sub	a0,a0,s4
                size -= la - end;
ffffffffc0204f88:	416489b3          	sub	s3,s1,s6
            if (end < la)
ffffffffc0204f8c:	0b44fd63          	bgeu	s1,s4,ffffffffc0205046 <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0204f90:	000cb683          	ld	a3,0(s9)
ffffffffc0204f94:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204f96:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0204f9a:	40db86b3          	sub	a3,s7,a3
ffffffffc0204f9e:	8699                	srai	a3,a3,0x6
ffffffffc0204fa0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204fa2:	67e2                	ld	a5,24(sp)
ffffffffc0204fa4:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204fa8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204faa:	0ac5f963          	bgeu	a1,a2,ffffffffc020505c <do_execve+0x464>
ffffffffc0204fae:	000ab883          	ld	a7,0(s5)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204fb2:	864e                	mv	a2,s3
ffffffffc0204fb4:	4581                	li	a1,0
ffffffffc0204fb6:	96c6                	add	a3,a3,a7
ffffffffc0204fb8:	9536                	add	a0,a0,a3
ffffffffc0204fba:	31f000ef          	jal	ra,ffffffffc0205ad8 <memset>
            start += size;
ffffffffc0204fbe:	01698733          	add	a4,s3,s6
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204fc2:	0344f463          	bgeu	s1,s4,ffffffffc0204fea <do_execve+0x3f2>
ffffffffc0204fc6:	d6e489e3          	beq	s1,a4,ffffffffc0204d38 <do_execve+0x140>
ffffffffc0204fca:	00002697          	auipc	a3,0x2
ffffffffc0204fce:	68e68693          	addi	a3,a3,1678 # ffffffffc0207658 <default_pmm_manager+0xce0>
ffffffffc0204fd2:	00001617          	auipc	a2,0x1
ffffffffc0204fd6:	5f660613          	addi	a2,a2,1526 # ffffffffc02065c8 <commands+0x858>
ffffffffc0204fda:	33100593          	li	a1,817
ffffffffc0204fde:	00002517          	auipc	a0,0x2
ffffffffc0204fe2:	46a50513          	addi	a0,a0,1130 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc0204fe6:	ca8fb0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0204fea:	ff4710e3          	bne	a4,s4,ffffffffc0204fca <do_execve+0x3d2>
ffffffffc0204fee:	8b52                	mv	s6,s4
        while (start < end)
ffffffffc0204ff0:	d49b74e3          	bgeu	s6,s1,ffffffffc0204d38 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204ff4:	6c08                	ld	a0,24(s0)
ffffffffc0204ff6:	866a                	mv	a2,s10
ffffffffc0204ff8:	85d2                	mv	a1,s4
ffffffffc0204ffa:	f62fe0ef          	jal	ra,ffffffffc020375c <pgdir_alloc_page>
ffffffffc0204ffe:	8baa                	mv	s7,a0
ffffffffc0205000:	dd05                	beqz	a0,ffffffffc0204f38 <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205002:	6785                	lui	a5,0x1
ffffffffc0205004:	414b0533          	sub	a0,s6,s4
ffffffffc0205008:	9a3e                	add	s4,s4,a5
ffffffffc020500a:	416a0633          	sub	a2,s4,s6
            if (end < la)
ffffffffc020500e:	0144f463          	bgeu	s1,s4,ffffffffc0205016 <do_execve+0x41e>
                size -= la - end;
ffffffffc0205012:	41648633          	sub	a2,s1,s6
    return page - pages + nbase;
ffffffffc0205016:	000cb683          	ld	a3,0(s9)
ffffffffc020501a:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc020501c:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205020:	40db86b3          	sub	a3,s7,a3
ffffffffc0205024:	8699                	srai	a3,a3,0x6
ffffffffc0205026:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205028:	67e2                	ld	a5,24(sp)
ffffffffc020502a:	00f6f8b3          	and	a7,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc020502e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205030:	02b8f663          	bgeu	a7,a1,ffffffffc020505c <do_execve+0x464>
ffffffffc0205034:	000ab883          	ld	a7,0(s5)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205038:	4581                	li	a1,0
            start += size;
ffffffffc020503a:	9b32                	add	s6,s6,a2
ffffffffc020503c:	96c6                	add	a3,a3,a7
            memset(page2kva(page) + off, 0, size);
ffffffffc020503e:	9536                	add	a0,a0,a3
ffffffffc0205040:	299000ef          	jal	ra,ffffffffc0205ad8 <memset>
ffffffffc0205044:	b775                	j	ffffffffc0204ff0 <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205046:	416a09b3          	sub	s3,s4,s6
ffffffffc020504a:	b799                	j	ffffffffc0204f90 <do_execve+0x398>
        return -E_INVAL;
ffffffffc020504c:	59f5                	li	s3,-3
ffffffffc020504e:	b3c1                	j	ffffffffc0204e0e <do_execve+0x216>
        while (start < end)
ffffffffc0205050:	84da                	mv	s1,s6
ffffffffc0205052:	bf39                	j	ffffffffc0204f70 <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc0205054:	59f1                	li	s3,-4
ffffffffc0205056:	bdc5                	j	ffffffffc0204f46 <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0205058:	59e1                	li	s3,-8
ffffffffc020505a:	b5c5                	j	ffffffffc0204f3a <do_execve+0x342>
ffffffffc020505c:	00002617          	auipc	a2,0x2
ffffffffc0205060:	95460613          	addi	a2,a2,-1708 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0205064:	0bd00593          	li	a1,189
ffffffffc0205068:	00002517          	auipc	a0,0x2
ffffffffc020506c:	97050513          	addi	a0,a0,-1680 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0205070:	c1efb0ef          	jal	ra,ffffffffc020048e <__panic>
    current->pgdir = PADDR(mm->pgdir); // 记录页目录物理地址
ffffffffc0205074:	00002617          	auipc	a2,0x2
ffffffffc0205078:	9e460613          	addi	a2,a2,-1564 # ffffffffc0206a58 <default_pmm_manager+0xe0>
ffffffffc020507c:	35700593          	li	a1,855
ffffffffc0205080:	00002517          	auipc	a0,0x2
ffffffffc0205084:	3c850513          	addi	a0,a0,968 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc0205088:	c06fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc020508c:	00002697          	auipc	a3,0x2
ffffffffc0205090:	6e468693          	addi	a3,a3,1764 # ffffffffc0207770 <default_pmm_manager+0xdf8>
ffffffffc0205094:	00001617          	auipc	a2,0x1
ffffffffc0205098:	53460613          	addi	a2,a2,1332 # ffffffffc02065c8 <commands+0x858>
ffffffffc020509c:	35200593          	li	a1,850
ffffffffc02050a0:	00002517          	auipc	a0,0x2
ffffffffc02050a4:	3a850513          	addi	a0,a0,936 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc02050a8:	be6fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc02050ac:	00002697          	auipc	a3,0x2
ffffffffc02050b0:	67c68693          	addi	a3,a3,1660 # ffffffffc0207728 <default_pmm_manager+0xdb0>
ffffffffc02050b4:	00001617          	auipc	a2,0x1
ffffffffc02050b8:	51460613          	addi	a2,a2,1300 # ffffffffc02065c8 <commands+0x858>
ffffffffc02050bc:	35100593          	li	a1,849
ffffffffc02050c0:	00002517          	auipc	a0,0x2
ffffffffc02050c4:	38850513          	addi	a0,a0,904 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc02050c8:	bc6fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc02050cc:	00002697          	auipc	a3,0x2
ffffffffc02050d0:	61468693          	addi	a3,a3,1556 # ffffffffc02076e0 <default_pmm_manager+0xd68>
ffffffffc02050d4:	00001617          	auipc	a2,0x1
ffffffffc02050d8:	4f460613          	addi	a2,a2,1268 # ffffffffc02065c8 <commands+0x858>
ffffffffc02050dc:	35000593          	li	a1,848
ffffffffc02050e0:	00002517          	auipc	a0,0x2
ffffffffc02050e4:	36850513          	addi	a0,a0,872 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc02050e8:	ba6fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc02050ec:	00002697          	auipc	a3,0x2
ffffffffc02050f0:	5ac68693          	addi	a3,a3,1452 # ffffffffc0207698 <default_pmm_manager+0xd20>
ffffffffc02050f4:	00001617          	auipc	a2,0x1
ffffffffc02050f8:	4d460613          	addi	a2,a2,1236 # ffffffffc02065c8 <commands+0x858>
ffffffffc02050fc:	34f00593          	li	a1,847
ffffffffc0205100:	00002517          	auipc	a0,0x2
ffffffffc0205104:	34850513          	addi	a0,a0,840 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc0205108:	b86fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020510c <do_yield>:
    current->need_resched = 1; // 标记需要调度，trap 返回时会处理
ffffffffc020510c:	000d2797          	auipc	a5,0xd2
ffffffffc0205110:	d047b783          	ld	a5,-764(a5) # ffffffffc02d6e10 <current>
ffffffffc0205114:	4705                	li	a4,1
ffffffffc0205116:	ef98                	sd	a4,24(a5)
}
ffffffffc0205118:	4501                	li	a0,0
ffffffffc020511a:	8082                	ret

ffffffffc020511c <do_wait>:
{
ffffffffc020511c:	1101                	addi	sp,sp,-32
ffffffffc020511e:	e822                	sd	s0,16(sp)
ffffffffc0205120:	e426                	sd	s1,8(sp)
ffffffffc0205122:	ec06                	sd	ra,24(sp)
ffffffffc0205124:	842e                	mv	s0,a1
ffffffffc0205126:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc0205128:	c999                	beqz	a1,ffffffffc020513e <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc020512a:	000d2797          	auipc	a5,0xd2
ffffffffc020512e:	ce67b783          	ld	a5,-794(a5) # ffffffffc02d6e10 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0205132:	7788                	ld	a0,40(a5)
ffffffffc0205134:	4685                	li	a3,1
ffffffffc0205136:	4611                	li	a2,4
ffffffffc0205138:	d81fe0ef          	jal	ra,ffffffffc0203eb8 <user_mem_check>
ffffffffc020513c:	c909                	beqz	a0,ffffffffc020514e <do_wait+0x32>
ffffffffc020513e:	85a2                	mv	a1,s0
}
ffffffffc0205140:	6442                	ld	s0,16(sp)
ffffffffc0205142:	60e2                	ld	ra,24(sp)
ffffffffc0205144:	8526                	mv	a0,s1
ffffffffc0205146:	64a2                	ld	s1,8(sp)
ffffffffc0205148:	6105                	addi	sp,sp,32
ffffffffc020514a:	fb8ff06f          	j	ffffffffc0204902 <do_wait.part.0>
ffffffffc020514e:	60e2                	ld	ra,24(sp)
ffffffffc0205150:	6442                	ld	s0,16(sp)
ffffffffc0205152:	64a2                	ld	s1,8(sp)
ffffffffc0205154:	5575                	li	a0,-3
ffffffffc0205156:	6105                	addi	sp,sp,32
ffffffffc0205158:	8082                	ret

ffffffffc020515a <do_kill>:
{
ffffffffc020515a:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc020515c:	6789                	lui	a5,0x2
{
ffffffffc020515e:	e406                	sd	ra,8(sp)
ffffffffc0205160:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc0205162:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205166:	17f9                	addi	a5,a5,-2
ffffffffc0205168:	02e7e963          	bltu	a5,a4,ffffffffc020519a <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020516c:	842a                	mv	s0,a0
ffffffffc020516e:	45a9                	li	a1,10
ffffffffc0205170:	2501                	sext.w	a0,a0
ffffffffc0205172:	4c0000ef          	jal	ra,ffffffffc0205632 <hash32>
ffffffffc0205176:	02051793          	slli	a5,a0,0x20
ffffffffc020517a:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020517e:	000ce797          	auipc	a5,0xce
ffffffffc0205182:	c0278793          	addi	a5,a5,-1022 # ffffffffc02d2d80 <hash_list>
ffffffffc0205186:	953e                	add	a0,a0,a5
ffffffffc0205188:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc020518a:	a029                	j	ffffffffc0205194 <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc020518c:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205190:	00870b63          	beq	a4,s0,ffffffffc02051a6 <do_kill+0x4c>
ffffffffc0205194:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0205196:	fef51be3          	bne	a0,a5,ffffffffc020518c <do_kill+0x32>
    return -E_INVAL;
ffffffffc020519a:	5475                	li	s0,-3
}
ffffffffc020519c:	60a2                	ld	ra,8(sp)
ffffffffc020519e:	8522                	mv	a0,s0
ffffffffc02051a0:	6402                	ld	s0,0(sp)
ffffffffc02051a2:	0141                	addi	sp,sp,16
ffffffffc02051a4:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc02051a6:	fd87a703          	lw	a4,-40(a5)
ffffffffc02051aa:	00177693          	andi	a3,a4,1
ffffffffc02051ae:	e295                	bnez	a3,ffffffffc02051d2 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc02051b0:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING; // 设置正在退出标志
ffffffffc02051b2:	00176713          	ori	a4,a4,1
ffffffffc02051b6:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc02051ba:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc02051bc:	fe06d0e3          	bgez	a3,ffffffffc020519c <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc02051c0:	f2878513          	addi	a0,a5,-216
ffffffffc02051c4:	22e000ef          	jal	ra,ffffffffc02053f2 <wakeup_proc>
}
ffffffffc02051c8:	60a2                	ld	ra,8(sp)
ffffffffc02051ca:	8522                	mv	a0,s0
ffffffffc02051cc:	6402                	ld	s0,0(sp)
ffffffffc02051ce:	0141                	addi	sp,sp,16
ffffffffc02051d0:	8082                	ret
        return -E_KILLED;
ffffffffc02051d2:	545d                	li	s0,-9
ffffffffc02051d4:	b7e1                	j	ffffffffc020519c <do_kill+0x42>

ffffffffc02051d6 <proc_init>:

// proc_init - 进程子系统初始化
void proc_init(void)
{
ffffffffc02051d6:	1101                	addi	sp,sp,-32
ffffffffc02051d8:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc02051da:	000d2797          	auipc	a5,0xd2
ffffffffc02051de:	ba678793          	addi	a5,a5,-1114 # ffffffffc02d6d80 <proc_list>
ffffffffc02051e2:	ec06                	sd	ra,24(sp)
ffffffffc02051e4:	e822                	sd	s0,16(sp)
ffffffffc02051e6:	e04a                	sd	s2,0(sp)
ffffffffc02051e8:	000ce497          	auipc	s1,0xce
ffffffffc02051ec:	b9848493          	addi	s1,s1,-1128 # ffffffffc02d2d80 <hash_list>
ffffffffc02051f0:	e79c                	sd	a5,8(a5)
ffffffffc02051f2:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc02051f4:	000d2717          	auipc	a4,0xd2
ffffffffc02051f8:	b8c70713          	addi	a4,a4,-1140 # ffffffffc02d6d80 <proc_list>
ffffffffc02051fc:	87a6                	mv	a5,s1
ffffffffc02051fe:	e79c                	sd	a5,8(a5)
ffffffffc0205200:	e39c                	sd	a5,0(a5)
ffffffffc0205202:	07c1                	addi	a5,a5,16
ffffffffc0205204:	fef71de3          	bne	a4,a5,ffffffffc02051fe <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    // [1] 创建 idleproc (0号进程)
    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0205208:	f79fe0ef          	jal	ra,ffffffffc0204180 <alloc_proc>
ffffffffc020520c:	000d2917          	auipc	s2,0xd2
ffffffffc0205210:	c0c90913          	addi	s2,s2,-1012 # ffffffffc02d6e18 <idleproc>
ffffffffc0205214:	00a93023          	sd	a0,0(s2)
ffffffffc0205218:	0e050f63          	beqz	a0,ffffffffc0205316 <proc_init+0x140>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE; // 永远是就绪的
ffffffffc020521c:	4789                	li	a5,2
ffffffffc020521e:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack; // idle 使用启动时的栈
ffffffffc0205220:	00004797          	auipc	a5,0x4
ffffffffc0205224:	de078793          	addi	a5,a5,-544 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205228:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack; // idle 使用启动时的栈
ffffffffc020522c:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc020522e:	4785                	li	a5,1
ffffffffc0205230:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205232:	4641                	li	a2,16
ffffffffc0205234:	4581                	li	a1,0
ffffffffc0205236:	8522                	mv	a0,s0
ffffffffc0205238:	0a1000ef          	jal	ra,ffffffffc0205ad8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020523c:	463d                	li	a2,15
ffffffffc020523e:	00002597          	auipc	a1,0x2
ffffffffc0205242:	59258593          	addi	a1,a1,1426 # ffffffffc02077d0 <default_pmm_manager+0xe58>
ffffffffc0205246:	8522                	mv	a0,s0
ffffffffc0205248:	0a3000ef          	jal	ra,ffffffffc0205aea <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc020524c:	000d2717          	auipc	a4,0xd2
ffffffffc0205250:	bdc70713          	addi	a4,a4,-1060 # ffffffffc02d6e28 <nr_process>
ffffffffc0205254:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205256:	00093683          	ld	a3,0(s2)

    // [2] 创建 initproc (1号进程，运行 init_main)
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020525a:	4601                	li	a2,0
    nr_process++;
ffffffffc020525c:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020525e:	4581                	li	a1,0
ffffffffc0205260:	00000517          	auipc	a0,0x0
ffffffffc0205264:	87450513          	addi	a0,a0,-1932 # ffffffffc0204ad4 <init_main>
    nr_process++;
ffffffffc0205268:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc020526a:	000d2797          	auipc	a5,0xd2
ffffffffc020526e:	bad7b323          	sd	a3,-1114(a5) # ffffffffc02d6e10 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205272:	cf6ff0ef          	jal	ra,ffffffffc0204768 <kernel_thread>
ffffffffc0205276:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0205278:	08a05363          	blez	a0,ffffffffc02052fe <proc_init+0x128>
    if (0 < pid && pid < MAX_PID)
ffffffffc020527c:	6789                	lui	a5,0x2
ffffffffc020527e:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205282:	17f9                	addi	a5,a5,-2
ffffffffc0205284:	2501                	sext.w	a0,a0
ffffffffc0205286:	02e7e363          	bltu	a5,a4,ffffffffc02052ac <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020528a:	45a9                	li	a1,10
ffffffffc020528c:	3a6000ef          	jal	ra,ffffffffc0205632 <hash32>
ffffffffc0205290:	02051793          	slli	a5,a0,0x20
ffffffffc0205294:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205298:	96a6                	add	a3,a3,s1
ffffffffc020529a:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc020529c:	a029                	j	ffffffffc02052a6 <proc_init+0xd0>
            if (proc->pid == pid)
ffffffffc020529e:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7e34>
ffffffffc02052a2:	04870b63          	beq	a4,s0,ffffffffc02052f8 <proc_init+0x122>
    return listelm->next;
ffffffffc02052a6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02052a8:	fef69be3          	bne	a3,a5,ffffffffc020529e <proc_init+0xc8>
    return NULL;
ffffffffc02052ac:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02052ae:	0b478493          	addi	s1,a5,180
ffffffffc02052b2:	4641                	li	a2,16
ffffffffc02052b4:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc02052b6:	000d2417          	auipc	s0,0xd2
ffffffffc02052ba:	b6a40413          	addi	s0,s0,-1174 # ffffffffc02d6e20 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02052be:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc02052c0:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02052c2:	017000ef          	jal	ra,ffffffffc0205ad8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02052c6:	463d                	li	a2,15
ffffffffc02052c8:	00002597          	auipc	a1,0x2
ffffffffc02052cc:	53058593          	addi	a1,a1,1328 # ffffffffc02077f8 <default_pmm_manager+0xe80>
ffffffffc02052d0:	8526                	mv	a0,s1
ffffffffc02052d2:	019000ef          	jal	ra,ffffffffc0205aea <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02052d6:	00093783          	ld	a5,0(s2)
ffffffffc02052da:	cbb5                	beqz	a5,ffffffffc020534e <proc_init+0x178>
ffffffffc02052dc:	43dc                	lw	a5,4(a5)
ffffffffc02052de:	eba5                	bnez	a5,ffffffffc020534e <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02052e0:	601c                	ld	a5,0(s0)
ffffffffc02052e2:	c7b1                	beqz	a5,ffffffffc020532e <proc_init+0x158>
ffffffffc02052e4:	43d8                	lw	a4,4(a5)
ffffffffc02052e6:	4785                	li	a5,1
ffffffffc02052e8:	04f71363          	bne	a4,a5,ffffffffc020532e <proc_init+0x158>
}
ffffffffc02052ec:	60e2                	ld	ra,24(sp)
ffffffffc02052ee:	6442                	ld	s0,16(sp)
ffffffffc02052f0:	64a2                	ld	s1,8(sp)
ffffffffc02052f2:	6902                	ld	s2,0(sp)
ffffffffc02052f4:	6105                	addi	sp,sp,32
ffffffffc02052f6:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02052f8:	f2878793          	addi	a5,a5,-216
ffffffffc02052fc:	bf4d                	j	ffffffffc02052ae <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc02052fe:	00002617          	auipc	a2,0x2
ffffffffc0205302:	4da60613          	addi	a2,a2,1242 # ffffffffc02077d8 <default_pmm_manager+0xe60>
ffffffffc0205306:	4ad00593          	li	a1,1197
ffffffffc020530a:	00002517          	auipc	a0,0x2
ffffffffc020530e:	13e50513          	addi	a0,a0,318 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc0205312:	97cfb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205316:	00002617          	auipc	a2,0x2
ffffffffc020531a:	4a260613          	addi	a2,a2,1186 # ffffffffc02077b8 <default_pmm_manager+0xe40>
ffffffffc020531e:	49d00593          	li	a1,1181
ffffffffc0205322:	00002517          	auipc	a0,0x2
ffffffffc0205326:	12650513          	addi	a0,a0,294 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc020532a:	964fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020532e:	00002697          	auipc	a3,0x2
ffffffffc0205332:	4fa68693          	addi	a3,a3,1274 # ffffffffc0207828 <default_pmm_manager+0xeb0>
ffffffffc0205336:	00001617          	auipc	a2,0x1
ffffffffc020533a:	29260613          	addi	a2,a2,658 # ffffffffc02065c8 <commands+0x858>
ffffffffc020533e:	4b400593          	li	a1,1204
ffffffffc0205342:	00002517          	auipc	a0,0x2
ffffffffc0205346:	10650513          	addi	a0,a0,262 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc020534a:	944fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020534e:	00002697          	auipc	a3,0x2
ffffffffc0205352:	4b268693          	addi	a3,a3,1202 # ffffffffc0207800 <default_pmm_manager+0xe88>
ffffffffc0205356:	00001617          	auipc	a2,0x1
ffffffffc020535a:	27260613          	addi	a2,a2,626 # ffffffffc02065c8 <commands+0x858>
ffffffffc020535e:	4b300593          	li	a1,1203
ffffffffc0205362:	00002517          	auipc	a0,0x2
ffffffffc0205366:	0e650513          	addi	a0,a0,230 # ffffffffc0207448 <default_pmm_manager+0xad0>
ffffffffc020536a:	924fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020536e <cpu_idle>:

// cpu_idle - 空闲循环
// 当没有其他 RUNNABLE 进程时，schedule 会切换到这里
void cpu_idle(void)
{
ffffffffc020536e:	1141                	addi	sp,sp,-16
ffffffffc0205370:	e022                	sd	s0,0(sp)
ffffffffc0205372:	e406                	sd	ra,8(sp)
ffffffffc0205374:	000d2417          	auipc	s0,0xd2
ffffffffc0205378:	a9c40413          	addi	s0,s0,-1380 # ffffffffc02d6e10 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc020537c:	6018                	ld	a4,0(s0)
ffffffffc020537e:	6f1c                	ld	a5,24(a4)
ffffffffc0205380:	dffd                	beqz	a5,ffffffffc020537e <cpu_idle+0x10>
        {
            schedule();
ffffffffc0205382:	0f2000ef          	jal	ra,ffffffffc0205474 <schedule>
ffffffffc0205386:	bfdd                	j	ffffffffc020537c <cpu_idle+0xe>

ffffffffc0205388 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205388:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc020538c:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205390:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205392:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205394:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205398:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc020539c:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02053a0:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02053a4:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02053a8:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02053ac:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02053b0:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02053b4:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02053b8:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02053bc:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02053c0:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02053c4:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02053c6:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02053c8:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02053cc:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02053d0:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02053d4:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02053d8:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02053dc:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02053e0:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02053e4:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02053e8:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02053ec:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc02053f0:	8082                	ret

ffffffffc02053f2 <wakeup_proc>:
 * 2. 当进程等待某个事件/资源时，条件满足后被唤醒。
 */
void wakeup_proc(struct proc_struct *proc)
{
    // 只有非僵尸进程才能被唤醒。僵尸进程已经结束执行，等待回收，不能再运行。
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02053f2:	4118                	lw	a4,0(a0)
{
ffffffffc02053f4:	1101                	addi	sp,sp,-32
ffffffffc02053f6:	ec06                	sd	ra,24(sp)
ffffffffc02053f8:	e822                	sd	s0,16(sp)
ffffffffc02053fa:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02053fc:	478d                	li	a5,3
ffffffffc02053fe:	04f70c63          	beq	a4,a5,ffffffffc0205456 <wakeup_proc+0x64>
ffffffffc0205402:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205404:	100027f3          	csrr	a5,sstatus
ffffffffc0205408:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020540a:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020540c:	e3a1                	bnez	a5,ffffffffc020544c <wakeup_proc+0x5a>
    // 进程状态的修改涉及共享数据（进程控制块），必须保证原子性。
    // 这里关闭中断，防止在修改过程中发生中断导致并发竞态问题。
    local_intr_save(intr_flag);
    {
        // 只有当进程状态不是 RUNNABLE 时才需要唤醒
        if (proc->state != PROC_RUNNABLE)
ffffffffc020540e:	4789                	li	a5,2
ffffffffc0205410:	02f70163          	beq	a4,a5,ffffffffc0205432 <wakeup_proc+0x40>
        {
            proc->state = PROC_RUNNABLE; // 设置为就绪态，可以被调度器选中
ffffffffc0205414:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;        // 清除等待标记
ffffffffc0205416:	0e042623          	sw	zero,236(s0)
    if (flag)
ffffffffc020541a:	e491                	bnez	s1,ffffffffc0205426 <wakeup_proc+0x34>
            warn("wakeup runnable process.\n");
        }
    }
    // 【开中断】恢复中断状态
    local_intr_restore(intr_flag);
}
ffffffffc020541c:	60e2                	ld	ra,24(sp)
ffffffffc020541e:	6442                	ld	s0,16(sp)
ffffffffc0205420:	64a2                	ld	s1,8(sp)
ffffffffc0205422:	6105                	addi	sp,sp,32
ffffffffc0205424:	8082                	ret
ffffffffc0205426:	6442                	ld	s0,16(sp)
ffffffffc0205428:	60e2                	ld	ra,24(sp)
ffffffffc020542a:	64a2                	ld	s1,8(sp)
ffffffffc020542c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020542e:	d80fb06f          	j	ffffffffc02009ae <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205432:	00002617          	auipc	a2,0x2
ffffffffc0205436:	45660613          	addi	a2,a2,1110 # ffffffffc0207888 <default_pmm_manager+0xf10>
ffffffffc020543a:	02100593          	li	a1,33
ffffffffc020543e:	00002517          	auipc	a0,0x2
ffffffffc0205442:	43250513          	addi	a0,a0,1074 # ffffffffc0207870 <default_pmm_manager+0xef8>
ffffffffc0205446:	8b0fb0ef          	jal	ra,ffffffffc02004f6 <__warn>
ffffffffc020544a:	bfc1                	j	ffffffffc020541a <wakeup_proc+0x28>
        intr_disable();
ffffffffc020544c:	d68fb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205450:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205452:	4485                	li	s1,1
ffffffffc0205454:	bf6d                	j	ffffffffc020540e <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205456:	00002697          	auipc	a3,0x2
ffffffffc020545a:	3fa68693          	addi	a3,a3,1018 # ffffffffc0207850 <default_pmm_manager+0xed8>
ffffffffc020545e:	00001617          	auipc	a2,0x1
ffffffffc0205462:	16a60613          	addi	a2,a2,362 # ffffffffc02065c8 <commands+0x858>
ffffffffc0205466:	45c5                	li	a1,17
ffffffffc0205468:	00002517          	auipc	a0,0x2
ffffffffc020546c:	40850513          	addi	a0,a0,1032 # ffffffffc0207870 <default_pmm_manager+0xef8>
ffffffffc0205470:	81efb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0205474 <schedule>:
 * 2. 找到第一个状态为 PROC_RUNNABLE 的进程。
 * 3. 恢复该进程的时间片 (如果是因时间片耗尽而被抢占的)。
 * 4. 调用 proc_run 执行上下文切换。
 */
void schedule(void)
{
ffffffffc0205474:	1141                	addi	sp,sp,-16
ffffffffc0205476:	e406                	sd	ra,8(sp)
ffffffffc0205478:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020547a:	100027f3          	csrr	a5,sstatus
ffffffffc020547e:	8b89                	andi	a5,a5,2
ffffffffc0205480:	4401                	li	s0,0
ffffffffc0205482:	e3d9                	bnez	a5,ffffffffc0205508 <schedule+0x94>
    // 调度过程涉及修改 current 指针、进程链表等核心数据结构，
    // 且 proc_run 进行上下文切换时必须处于关中断状态。
    local_intr_save(intr_flag);
    {
        // 清除当前进程的“需要调度”标记
        current->need_resched = 0;
ffffffffc0205484:	000d2897          	auipc	a7,0xd2
ffffffffc0205488:	98c8b883          	ld	a7,-1652(a7) # ffffffffc02d6e10 <current>
ffffffffc020548c:	0008bc23          	sd	zero,24(a7)
        
        // 确定遍历的起点：
        // 如果当前是 idleproc (0号进程)，从链表头开始找；
        // 否则，从当前进程的下一个位置开始找 (实现 Round-Robin 轮转，保证公平)。
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205490:	000d2517          	auipc	a0,0xd2
ffffffffc0205494:	98853503          	ld	a0,-1656(a0) # ffffffffc02d6e18 <idleproc>
ffffffffc0205498:	06a88263          	beq	a7,a0,ffffffffc02054fc <schedule+0x88>
ffffffffc020549c:	0c888693          	addi	a3,a7,200
ffffffffc02054a0:	000d2617          	auipc	a2,0xd2
ffffffffc02054a4:	8e060613          	addi	a2,a2,-1824 # ffffffffc02d6d80 <proc_list>
        le = last;
ffffffffc02054a8:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02054aa:	4581                	li	a1,0
            {
                // 通过链表节点反解出对应的进程结构体指针
                next = le2proc(le, list_link);
                
                // 找到一个处于“就绪”状态的进程
                if (next->state == PROC_RUNNABLE)
ffffffffc02054ac:	4809                	li	a6,2
ffffffffc02054ae:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)
ffffffffc02054b0:	00c78863          	beq	a5,a2,ffffffffc02054c0 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE)
ffffffffc02054b4:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02054b8:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)
ffffffffc02054bc:	03070163          	beq	a4,a6,ffffffffc02054de <schedule+0x6a>
                    
                    // 找到目标，跳出循环
                    break;
                }
            }
        } while (le != last); // 如果遍历了一圈回到原点，说明没有其他就绪进程
ffffffffc02054c0:	fef697e3          	bne	a3,a5,ffffffffc02054ae <schedule+0x3a>
        
        // 如果没有找到可运行的进程 (next == NULL 或 next 不可运行)
        // 则运行 idleproc (空闲进程)，让 CPU 进入空闲循环
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc02054c4:	e18d                	bnez	a1,ffffffffc02054e6 <schedule+0x72>
        {
            next = idleproc;
        }
        
        // 统计该进程的运行次数
        next->runs++;
ffffffffc02054c6:	451c                	lw	a5,8(a0)
ffffffffc02054c8:	2785                	addiw	a5,a5,1
ffffffffc02054ca:	c51c                	sw	a5,8(a0)
        
        // 如果选出的进程不是当前正在运行的进程，则进行上下文切换
        if (next != current)
ffffffffc02054cc:	00a88463          	beq	a7,a0,ffffffffc02054d4 <schedule+0x60>
        {
            // proc_run 会完成以下工作：
            // 1. 切换页表 (lcr3)
            // 2. 切换内核栈 (switch_to)
            // 3. 更新 current 指针
            proc_run(next);
ffffffffc02054d0:	e29fe0ef          	jal	ra,ffffffffc02042f8 <proc_run>
    if (flag)
ffffffffc02054d4:	ec19                	bnez	s0,ffffffffc02054f2 <schedule+0x7e>
    }
    // 【开中断】
    // 注意：当 proc_run 返回时，实际上已经是在“新进程”的上下文中了。
    // 这里的 local_intr_restore 恢复的是新进程之前保存的中断状态。
    local_intr_restore(intr_flag);
ffffffffc02054d6:	60a2                	ld	ra,8(sp)
ffffffffc02054d8:	6402                	ld	s0,0(sp)
ffffffffc02054da:	0141                	addi	sp,sp,16
ffffffffc02054dc:	8082                	ret
                    if (next->time_slice == 0) {
ffffffffc02054de:	43b8                	lw	a4,64(a5)
ffffffffc02054e0:	e319                	bnez	a4,ffffffffc02054e6 <schedule+0x72>
                         next->time_slice = 3;
ffffffffc02054e2:	470d                	li	a4,3
ffffffffc02054e4:	c3b8                	sw	a4,64(a5)
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc02054e6:	4198                	lw	a4,0(a1)
ffffffffc02054e8:	4789                	li	a5,2
ffffffffc02054ea:	fcf71ee3          	bne	a4,a5,ffffffffc02054c6 <schedule+0x52>
ffffffffc02054ee:	852e                	mv	a0,a1
ffffffffc02054f0:	bfd9                	j	ffffffffc02054c6 <schedule+0x52>
ffffffffc02054f2:	6402                	ld	s0,0(sp)
ffffffffc02054f4:	60a2                	ld	ra,8(sp)
ffffffffc02054f6:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02054f8:	cb6fb06f          	j	ffffffffc02009ae <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02054fc:	000d2617          	auipc	a2,0xd2
ffffffffc0205500:	88460613          	addi	a2,a2,-1916 # ffffffffc02d6d80 <proc_list>
ffffffffc0205504:	86b2                	mv	a3,a2
ffffffffc0205506:	b74d                	j	ffffffffc02054a8 <schedule+0x34>
        intr_disable();
ffffffffc0205508:	cacfb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc020550c:	4405                	li	s0,1
ffffffffc020550e:	bf9d                	j	ffffffffc0205484 <schedule+0x10>

ffffffffc0205510 <sys_getpid>:
/* [Syscall Handler] sys_getpid
 * 功能：获取当前进程 ID。
 */
static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205510:	000d2797          	auipc	a5,0xd2
ffffffffc0205514:	9007b783          	ld	a5,-1792(a5) # ffffffffc02d6e10 <current>
}
ffffffffc0205518:	43c8                	lw	a0,4(a5)
ffffffffc020551a:	8082                	ret

ffffffffc020551c <sys_pgdir>:
 */
static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc020551c:	4501                	li	a0,0
ffffffffc020551e:	8082                	ret

ffffffffc0205520 <sys_set_cow_attack>:
 * 2. 当开启时，do_pgfault (vmm.c) 会在页面复制后、建立映射前，故意清空 PTE，模拟竞态条件。
 */
// 【新增】实现控制攻击开关的系统调用
static int
sys_set_cow_attack(uint64_t arg[]) {
    int enable = (int)arg[0];
ffffffffc0205520:	411c                	lw	a5,0(a0)
sys_set_cow_attack(uint64_t arg[]) {
ffffffffc0205522:	1141                	addi	sp,sp,-16
ffffffffc0205524:	e406                	sd	ra,8(sp)
    TEST_DIRTY_COW_FLAG = (enable != 0);
ffffffffc0205526:	00f03733          	snez	a4,a5
ffffffffc020552a:	000d2697          	auipc	a3,0xd2
ffffffffc020552e:	8ce6bb23          	sd	a4,-1834(a3) # ffffffffc02d6e00 <TEST_DIRTY_COW_FLAG>
    cprintf("[Kernel] Dirty COW Attack Simulation: %s\n", 
ffffffffc0205532:	00002597          	auipc	a1,0x2
ffffffffc0205536:	37e58593          	addi	a1,a1,894 # ffffffffc02078b0 <default_pmm_manager+0xf38>
ffffffffc020553a:	c789                	beqz	a5,ffffffffc0205544 <sys_set_cow_attack+0x24>
ffffffffc020553c:	00002597          	auipc	a1,0x2
ffffffffc0205540:	36c58593          	addi	a1,a1,876 # ffffffffc02078a8 <default_pmm_manager+0xf30>
ffffffffc0205544:	00002517          	auipc	a0,0x2
ffffffffc0205548:	37c50513          	addi	a0,a0,892 # ffffffffc02078c0 <default_pmm_manager+0xf48>
ffffffffc020554c:	c49fa0ef          	jal	ra,ffffffffc0200194 <cprintf>
            TEST_DIRTY_COW_FLAG ? "ENABLED" : "DISABLED");
    return 0;
}
ffffffffc0205550:	60a2                	ld	ra,8(sp)
ffffffffc0205552:	4501                	li	a0,0
ffffffffc0205554:	0141                	addi	sp,sp,16
ffffffffc0205556:	8082                	ret

ffffffffc0205558 <sys_get_free_pages>:
sys_get_free_pages(uint64_t arg[]) {
ffffffffc0205558:	1141                	addi	sp,sp,-16
ffffffffc020555a:	e406                	sd	ra,8(sp)
    return (int)nr_free_pages();
ffffffffc020555c:	ac7fc0ef          	jal	ra,ffffffffc0202022 <nr_free_pages>
}
ffffffffc0205560:	60a2                	ld	ra,8(sp)
ffffffffc0205562:	2501                	sext.w	a0,a0
ffffffffc0205564:	0141                	addi	sp,sp,16
ffffffffc0205566:	8082                	ret

ffffffffc0205568 <sys_putc>:
    cputchar(c);
ffffffffc0205568:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc020556a:	1141                	addi	sp,sp,-16
ffffffffc020556c:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020556e:	c5dfa0ef          	jal	ra,ffffffffc02001ca <cputchar>
}
ffffffffc0205572:	60a2                	ld	ra,8(sp)
ffffffffc0205574:	4501                	li	a0,0
ffffffffc0205576:	0141                	addi	sp,sp,16
ffffffffc0205578:	8082                	ret

ffffffffc020557a <sys_kill>:
    return do_kill(pid);
ffffffffc020557a:	4108                	lw	a0,0(a0)
ffffffffc020557c:	bdfff06f          	j	ffffffffc020515a <do_kill>

ffffffffc0205580 <sys_yield>:
    return do_yield();
ffffffffc0205580:	b8dff06f          	j	ffffffffc020510c <do_yield>

ffffffffc0205584 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205584:	6d14                	ld	a3,24(a0)
ffffffffc0205586:	6910                	ld	a2,16(a0)
ffffffffc0205588:	650c                	ld	a1,8(a0)
ffffffffc020558a:	6108                	ld	a0,0(a0)
ffffffffc020558c:	e6cff06f          	j	ffffffffc0204bf8 <do_execve>

ffffffffc0205590 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205590:	650c                	ld	a1,8(a0)
ffffffffc0205592:	4108                	lw	a0,0(a0)
ffffffffc0205594:	b89ff06f          	j	ffffffffc020511c <do_wait>

ffffffffc0205598 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205598:	000d2797          	auipc	a5,0xd2
ffffffffc020559c:	8787b783          	ld	a5,-1928(a5) # ffffffffc02d6e10 <current>
ffffffffc02055a0:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02055a2:	4501                	li	a0,0
ffffffffc02055a4:	6a0c                	ld	a1,16(a2)
ffffffffc02055a6:	dbffe06f          	j	ffffffffc0204364 <do_fork>

ffffffffc02055aa <sys_exit>:
    return do_exit(error_code);
ffffffffc02055aa:	4108                	lw	a0,0(a0)
ffffffffc02055ac:	a0cff06f          	j	ffffffffc02047b8 <do_exit>

ffffffffc02055b0 <syscall>:
 * - a1-a5: 保存系统调用的参数。
 * 3. 查表调用对应的 sys_xxx 函数。
 * 4. 将返回值写回 tf->gpr.a0，这样当 sret 返回用户态时，用户程序能拿到结果。
 */
void
syscall(void) {
ffffffffc02055b0:	715d                	addi	sp,sp,-80
ffffffffc02055b2:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02055b4:	000d2497          	auipc	s1,0xd2
ffffffffc02055b8:	85c48493          	addi	s1,s1,-1956 # ffffffffc02d6e10 <current>
ffffffffc02055bc:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02055be:	e0a2                	sd	s0,64(sp)
ffffffffc02055c0:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02055c2:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02055c4:	e486                	sd	ra,72(sp)
    
    // 获取系统调用号 (保存在寄存器 a0 中)
    int num = tf->gpr.a0;
    
    // 检查调用号是否合法
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02055c6:	0fb00793          	li	a5,251
    int num = tf->gpr.a0;
ffffffffc02055ca:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02055ce:	0327ee63          	bltu	a5,s2,ffffffffc020560a <syscall+0x5a>
        if (syscalls[num] != NULL) {
ffffffffc02055d2:	00391713          	slli	a4,s2,0x3
ffffffffc02055d6:	00002797          	auipc	a5,0x2
ffffffffc02055da:	36278793          	addi	a5,a5,866 # ffffffffc0207938 <syscalls>
ffffffffc02055de:	97ba                	add	a5,a5,a4
ffffffffc02055e0:	639c                	ld	a5,0(a5)
ffffffffc02055e2:	c785                	beqz	a5,ffffffffc020560a <syscall+0x5a>
            // 将寄存器参数 (a1-a5) 填入 arg 数组
            arg[0] = tf->gpr.a1;
ffffffffc02055e4:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02055e6:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02055e8:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02055ea:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02055ec:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02055ee:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02055f0:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02055f2:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02055f4:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02055f6:	f43a                	sd	a4,40(sp)
            
            // 执行具体的系统调用，并将返回值存回 a0 寄存器
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02055f8:	0028                	addi	a0,sp,8
ffffffffc02055fa:	9782                	jalr	a5
    
    // 如果调用号未定义，打印中断帧并 Panic
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
ffffffffc02055fc:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02055fe:	e828                	sd	a0,80(s0)
ffffffffc0205600:	6406                	ld	s0,64(sp)
ffffffffc0205602:	74e2                	ld	s1,56(sp)
ffffffffc0205604:	7942                	ld	s2,48(sp)
ffffffffc0205606:	6161                	addi	sp,sp,80
ffffffffc0205608:	8082                	ret
    print_trapframe(tf);
ffffffffc020560a:	8522                	mv	a0,s0
ffffffffc020560c:	d98fb0ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205610:	609c                	ld	a5,0(s1)
ffffffffc0205612:	86ca                	mv	a3,s2
ffffffffc0205614:	00002617          	auipc	a2,0x2
ffffffffc0205618:	2dc60613          	addi	a2,a2,732 # ffffffffc02078f0 <default_pmm_manager+0xf78>
ffffffffc020561c:	43d8                	lw	a4,4(a5)
ffffffffc020561e:	0cc00593          	li	a1,204
ffffffffc0205622:	0b478793          	addi	a5,a5,180
ffffffffc0205626:	00002517          	auipc	a0,0x2
ffffffffc020562a:	2fa50513          	addi	a0,a0,762 # ffffffffc0207920 <default_pmm_manager+0xfa8>
ffffffffc020562e:	e61fa0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0205632 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0205632:	9e3707b7          	lui	a5,0x9e370
ffffffffc0205636:	2785                	addiw	a5,a5,1
ffffffffc0205638:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc020563c:	02000793          	li	a5,32
ffffffffc0205640:	9f8d                	subw	a5,a5,a1
}
ffffffffc0205642:	00f5553b          	srlw	a0,a0,a5
ffffffffc0205646:	8082                	ret

ffffffffc0205648 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0205648:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020564c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020564e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205652:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0205654:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205658:	f022                	sd	s0,32(sp)
ffffffffc020565a:	ec26                	sd	s1,24(sp)
ffffffffc020565c:	e84a                	sd	s2,16(sp)
ffffffffc020565e:	f406                	sd	ra,40(sp)
ffffffffc0205660:	e44e                	sd	s3,8(sp)
ffffffffc0205662:	84aa                	mv	s1,a0
ffffffffc0205664:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0205666:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020566a:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020566c:	03067e63          	bgeu	a2,a6,ffffffffc02056a8 <printnum+0x60>
ffffffffc0205670:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0205672:	00805763          	blez	s0,ffffffffc0205680 <printnum+0x38>
ffffffffc0205676:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0205678:	85ca                	mv	a1,s2
ffffffffc020567a:	854e                	mv	a0,s3
ffffffffc020567c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020567e:	fc65                	bnez	s0,ffffffffc0205676 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205680:	1a02                	slli	s4,s4,0x20
ffffffffc0205682:	00003797          	auipc	a5,0x3
ffffffffc0205686:	a9678793          	addi	a5,a5,-1386 # ffffffffc0208118 <syscalls+0x7e0>
ffffffffc020568a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020568e:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0205690:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205692:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0205696:	70a2                	ld	ra,40(sp)
ffffffffc0205698:	69a2                	ld	s3,8(sp)
ffffffffc020569a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020569c:	85ca                	mv	a1,s2
ffffffffc020569e:	87a6                	mv	a5,s1
}
ffffffffc02056a0:	6942                	ld	s2,16(sp)
ffffffffc02056a2:	64e2                	ld	s1,24(sp)
ffffffffc02056a4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02056a6:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02056a8:	03065633          	divu	a2,a2,a6
ffffffffc02056ac:	8722                	mv	a4,s0
ffffffffc02056ae:	f9bff0ef          	jal	ra,ffffffffc0205648 <printnum>
ffffffffc02056b2:	b7f9                	j	ffffffffc0205680 <printnum+0x38>

ffffffffc02056b4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02056b4:	7119                	addi	sp,sp,-128
ffffffffc02056b6:	f4a6                	sd	s1,104(sp)
ffffffffc02056b8:	f0ca                	sd	s2,96(sp)
ffffffffc02056ba:	ecce                	sd	s3,88(sp)
ffffffffc02056bc:	e8d2                	sd	s4,80(sp)
ffffffffc02056be:	e4d6                	sd	s5,72(sp)
ffffffffc02056c0:	e0da                	sd	s6,64(sp)
ffffffffc02056c2:	fc5e                	sd	s7,56(sp)
ffffffffc02056c4:	f06a                	sd	s10,32(sp)
ffffffffc02056c6:	fc86                	sd	ra,120(sp)
ffffffffc02056c8:	f8a2                	sd	s0,112(sp)
ffffffffc02056ca:	f862                	sd	s8,48(sp)
ffffffffc02056cc:	f466                	sd	s9,40(sp)
ffffffffc02056ce:	ec6e                	sd	s11,24(sp)
ffffffffc02056d0:	892a                	mv	s2,a0
ffffffffc02056d2:	84ae                	mv	s1,a1
ffffffffc02056d4:	8d32                	mv	s10,a2
ffffffffc02056d6:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02056d8:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02056dc:	5b7d                	li	s6,-1
ffffffffc02056de:	00003a97          	auipc	s5,0x3
ffffffffc02056e2:	a66a8a93          	addi	s5,s5,-1434 # ffffffffc0208144 <syscalls+0x80c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02056e6:	00003b97          	auipc	s7,0x3
ffffffffc02056ea:	c7ab8b93          	addi	s7,s7,-902 # ffffffffc0208360 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02056ee:	000d4503          	lbu	a0,0(s10)
ffffffffc02056f2:	001d0413          	addi	s0,s10,1
ffffffffc02056f6:	01350a63          	beq	a0,s3,ffffffffc020570a <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02056fa:	c121                	beqz	a0,ffffffffc020573a <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02056fc:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02056fe:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0205700:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205702:	fff44503          	lbu	a0,-1(s0)
ffffffffc0205706:	ff351ae3          	bne	a0,s3,ffffffffc02056fa <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020570a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020570e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0205712:	4c81                	li	s9,0
ffffffffc0205714:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0205716:	5c7d                	li	s8,-1
ffffffffc0205718:	5dfd                	li	s11,-1
ffffffffc020571a:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020571e:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205720:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0205724:	0ff5f593          	zext.b	a1,a1
ffffffffc0205728:	00140d13          	addi	s10,s0,1
ffffffffc020572c:	04b56263          	bltu	a0,a1,ffffffffc0205770 <vprintfmt+0xbc>
ffffffffc0205730:	058a                	slli	a1,a1,0x2
ffffffffc0205732:	95d6                	add	a1,a1,s5
ffffffffc0205734:	4194                	lw	a3,0(a1)
ffffffffc0205736:	96d6                	add	a3,a3,s5
ffffffffc0205738:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020573a:	70e6                	ld	ra,120(sp)
ffffffffc020573c:	7446                	ld	s0,112(sp)
ffffffffc020573e:	74a6                	ld	s1,104(sp)
ffffffffc0205740:	7906                	ld	s2,96(sp)
ffffffffc0205742:	69e6                	ld	s3,88(sp)
ffffffffc0205744:	6a46                	ld	s4,80(sp)
ffffffffc0205746:	6aa6                	ld	s5,72(sp)
ffffffffc0205748:	6b06                	ld	s6,64(sp)
ffffffffc020574a:	7be2                	ld	s7,56(sp)
ffffffffc020574c:	7c42                	ld	s8,48(sp)
ffffffffc020574e:	7ca2                	ld	s9,40(sp)
ffffffffc0205750:	7d02                	ld	s10,32(sp)
ffffffffc0205752:	6de2                	ld	s11,24(sp)
ffffffffc0205754:	6109                	addi	sp,sp,128
ffffffffc0205756:	8082                	ret
            padc = '0';
ffffffffc0205758:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020575a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020575e:	846a                	mv	s0,s10
ffffffffc0205760:	00140d13          	addi	s10,s0,1
ffffffffc0205764:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0205768:	0ff5f593          	zext.b	a1,a1
ffffffffc020576c:	fcb572e3          	bgeu	a0,a1,ffffffffc0205730 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0205770:	85a6                	mv	a1,s1
ffffffffc0205772:	02500513          	li	a0,37
ffffffffc0205776:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0205778:	fff44783          	lbu	a5,-1(s0)
ffffffffc020577c:	8d22                	mv	s10,s0
ffffffffc020577e:	f73788e3          	beq	a5,s3,ffffffffc02056ee <vprintfmt+0x3a>
ffffffffc0205782:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0205786:	1d7d                	addi	s10,s10,-1
ffffffffc0205788:	ff379de3          	bne	a5,s3,ffffffffc0205782 <vprintfmt+0xce>
ffffffffc020578c:	b78d                	j	ffffffffc02056ee <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020578e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0205792:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205796:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0205798:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020579c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02057a0:	02d86463          	bltu	a6,a3,ffffffffc02057c8 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02057a4:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02057a8:	002c169b          	slliw	a3,s8,0x2
ffffffffc02057ac:	0186873b          	addw	a4,a3,s8
ffffffffc02057b0:	0017171b          	slliw	a4,a4,0x1
ffffffffc02057b4:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02057b6:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02057ba:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02057bc:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02057c0:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02057c4:	fed870e3          	bgeu	a6,a3,ffffffffc02057a4 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02057c8:	f40ddce3          	bgez	s11,ffffffffc0205720 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02057cc:	8de2                	mv	s11,s8
ffffffffc02057ce:	5c7d                	li	s8,-1
ffffffffc02057d0:	bf81                	j	ffffffffc0205720 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02057d2:	fffdc693          	not	a3,s11
ffffffffc02057d6:	96fd                	srai	a3,a3,0x3f
ffffffffc02057d8:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057dc:	00144603          	lbu	a2,1(s0)
ffffffffc02057e0:	2d81                	sext.w	s11,s11
ffffffffc02057e2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02057e4:	bf35                	j	ffffffffc0205720 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02057e6:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057ea:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02057ee:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057f0:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02057f2:	bfd9                	j	ffffffffc02057c8 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02057f4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02057f6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02057fa:	01174463          	blt	a4,a7,ffffffffc0205802 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02057fe:	1a088e63          	beqz	a7,ffffffffc02059ba <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0205802:	000a3603          	ld	a2,0(s4)
ffffffffc0205806:	46c1                	li	a3,16
ffffffffc0205808:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020580a:	2781                	sext.w	a5,a5
ffffffffc020580c:	876e                	mv	a4,s11
ffffffffc020580e:	85a6                	mv	a1,s1
ffffffffc0205810:	854a                	mv	a0,s2
ffffffffc0205812:	e37ff0ef          	jal	ra,ffffffffc0205648 <printnum>
            break;
ffffffffc0205816:	bde1                	j	ffffffffc02056ee <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0205818:	000a2503          	lw	a0,0(s4)
ffffffffc020581c:	85a6                	mv	a1,s1
ffffffffc020581e:	0a21                	addi	s4,s4,8
ffffffffc0205820:	9902                	jalr	s2
            break;
ffffffffc0205822:	b5f1                	j	ffffffffc02056ee <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0205824:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205826:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020582a:	01174463          	blt	a4,a7,ffffffffc0205832 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020582e:	18088163          	beqz	a7,ffffffffc02059b0 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0205832:	000a3603          	ld	a2,0(s4)
ffffffffc0205836:	46a9                	li	a3,10
ffffffffc0205838:	8a2e                	mv	s4,a1
ffffffffc020583a:	bfc1                	j	ffffffffc020580a <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020583c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0205840:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205842:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205844:	bdf1                	j	ffffffffc0205720 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0205846:	85a6                	mv	a1,s1
ffffffffc0205848:	02500513          	li	a0,37
ffffffffc020584c:	9902                	jalr	s2
            break;
ffffffffc020584e:	b545                	j	ffffffffc02056ee <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205850:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0205854:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205856:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205858:	b5e1                	j	ffffffffc0205720 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020585a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020585c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205860:	01174463          	blt	a4,a7,ffffffffc0205868 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0205864:	14088163          	beqz	a7,ffffffffc02059a6 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0205868:	000a3603          	ld	a2,0(s4)
ffffffffc020586c:	46a1                	li	a3,8
ffffffffc020586e:	8a2e                	mv	s4,a1
ffffffffc0205870:	bf69                	j	ffffffffc020580a <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0205872:	03000513          	li	a0,48
ffffffffc0205876:	85a6                	mv	a1,s1
ffffffffc0205878:	e03e                	sd	a5,0(sp)
ffffffffc020587a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020587c:	85a6                	mv	a1,s1
ffffffffc020587e:	07800513          	li	a0,120
ffffffffc0205882:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205884:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0205886:	6782                	ld	a5,0(sp)
ffffffffc0205888:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020588a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020588e:	bfb5                	j	ffffffffc020580a <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205890:	000a3403          	ld	s0,0(s4)
ffffffffc0205894:	008a0713          	addi	a4,s4,8
ffffffffc0205898:	e03a                	sd	a4,0(sp)
ffffffffc020589a:	14040263          	beqz	s0,ffffffffc02059de <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020589e:	0fb05763          	blez	s11,ffffffffc020598c <vprintfmt+0x2d8>
ffffffffc02058a2:	02d00693          	li	a3,45
ffffffffc02058a6:	0cd79163          	bne	a5,a3,ffffffffc0205968 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02058aa:	00044783          	lbu	a5,0(s0)
ffffffffc02058ae:	0007851b          	sext.w	a0,a5
ffffffffc02058b2:	cf85                	beqz	a5,ffffffffc02058ea <vprintfmt+0x236>
ffffffffc02058b4:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02058b8:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02058bc:	000c4563          	bltz	s8,ffffffffc02058c6 <vprintfmt+0x212>
ffffffffc02058c0:	3c7d                	addiw	s8,s8,-1
ffffffffc02058c2:	036c0263          	beq	s8,s6,ffffffffc02058e6 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02058c6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02058c8:	0e0c8e63          	beqz	s9,ffffffffc02059c4 <vprintfmt+0x310>
ffffffffc02058cc:	3781                	addiw	a5,a5,-32
ffffffffc02058ce:	0ef47b63          	bgeu	s0,a5,ffffffffc02059c4 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02058d2:	03f00513          	li	a0,63
ffffffffc02058d6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02058d8:	000a4783          	lbu	a5,0(s4)
ffffffffc02058dc:	3dfd                	addiw	s11,s11,-1
ffffffffc02058de:	0a05                	addi	s4,s4,1
ffffffffc02058e0:	0007851b          	sext.w	a0,a5
ffffffffc02058e4:	ffe1                	bnez	a5,ffffffffc02058bc <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02058e6:	01b05963          	blez	s11,ffffffffc02058f8 <vprintfmt+0x244>
ffffffffc02058ea:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02058ec:	85a6                	mv	a1,s1
ffffffffc02058ee:	02000513          	li	a0,32
ffffffffc02058f2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02058f4:	fe0d9be3          	bnez	s11,ffffffffc02058ea <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02058f8:	6a02                	ld	s4,0(sp)
ffffffffc02058fa:	bbd5                	j	ffffffffc02056ee <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02058fc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02058fe:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0205902:	01174463          	blt	a4,a7,ffffffffc020590a <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0205906:	08088d63          	beqz	a7,ffffffffc02059a0 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020590a:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020590e:	0a044d63          	bltz	s0,ffffffffc02059c8 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0205912:	8622                	mv	a2,s0
ffffffffc0205914:	8a66                	mv	s4,s9
ffffffffc0205916:	46a9                	li	a3,10
ffffffffc0205918:	bdcd                	j	ffffffffc020580a <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020591a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020591e:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0205920:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0205922:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0205926:	8fb5                	xor	a5,a5,a3
ffffffffc0205928:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020592c:	02d74163          	blt	a4,a3,ffffffffc020594e <vprintfmt+0x29a>
ffffffffc0205930:	00369793          	slli	a5,a3,0x3
ffffffffc0205934:	97de                	add	a5,a5,s7
ffffffffc0205936:	639c                	ld	a5,0(a5)
ffffffffc0205938:	cb99                	beqz	a5,ffffffffc020594e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020593a:	86be                	mv	a3,a5
ffffffffc020593c:	00000617          	auipc	a2,0x0
ffffffffc0205940:	1f460613          	addi	a2,a2,500 # ffffffffc0205b30 <etext+0x2e>
ffffffffc0205944:	85a6                	mv	a1,s1
ffffffffc0205946:	854a                	mv	a0,s2
ffffffffc0205948:	0ce000ef          	jal	ra,ffffffffc0205a16 <printfmt>
ffffffffc020594c:	b34d                	j	ffffffffc02056ee <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020594e:	00002617          	auipc	a2,0x2
ffffffffc0205952:	7ea60613          	addi	a2,a2,2026 # ffffffffc0208138 <syscalls+0x800>
ffffffffc0205956:	85a6                	mv	a1,s1
ffffffffc0205958:	854a                	mv	a0,s2
ffffffffc020595a:	0bc000ef          	jal	ra,ffffffffc0205a16 <printfmt>
ffffffffc020595e:	bb41                	j	ffffffffc02056ee <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0205960:	00002417          	auipc	s0,0x2
ffffffffc0205964:	7d040413          	addi	s0,s0,2000 # ffffffffc0208130 <syscalls+0x7f8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205968:	85e2                	mv	a1,s8
ffffffffc020596a:	8522                	mv	a0,s0
ffffffffc020596c:	e43e                	sd	a5,8(sp)
ffffffffc020596e:	0e2000ef          	jal	ra,ffffffffc0205a50 <strnlen>
ffffffffc0205972:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0205976:	01b05b63          	blez	s11,ffffffffc020598c <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020597a:	67a2                	ld	a5,8(sp)
ffffffffc020597c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205980:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0205982:	85a6                	mv	a1,s1
ffffffffc0205984:	8552                	mv	a0,s4
ffffffffc0205986:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205988:	fe0d9ce3          	bnez	s11,ffffffffc0205980 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020598c:	00044783          	lbu	a5,0(s0)
ffffffffc0205990:	00140a13          	addi	s4,s0,1
ffffffffc0205994:	0007851b          	sext.w	a0,a5
ffffffffc0205998:	d3a5                	beqz	a5,ffffffffc02058f8 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020599a:	05e00413          	li	s0,94
ffffffffc020599e:	bf39                	j	ffffffffc02058bc <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02059a0:	000a2403          	lw	s0,0(s4)
ffffffffc02059a4:	b7ad                	j	ffffffffc020590e <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02059a6:	000a6603          	lwu	a2,0(s4)
ffffffffc02059aa:	46a1                	li	a3,8
ffffffffc02059ac:	8a2e                	mv	s4,a1
ffffffffc02059ae:	bdb1                	j	ffffffffc020580a <vprintfmt+0x156>
ffffffffc02059b0:	000a6603          	lwu	a2,0(s4)
ffffffffc02059b4:	46a9                	li	a3,10
ffffffffc02059b6:	8a2e                	mv	s4,a1
ffffffffc02059b8:	bd89                	j	ffffffffc020580a <vprintfmt+0x156>
ffffffffc02059ba:	000a6603          	lwu	a2,0(s4)
ffffffffc02059be:	46c1                	li	a3,16
ffffffffc02059c0:	8a2e                	mv	s4,a1
ffffffffc02059c2:	b5a1                	j	ffffffffc020580a <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02059c4:	9902                	jalr	s2
ffffffffc02059c6:	bf09                	j	ffffffffc02058d8 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02059c8:	85a6                	mv	a1,s1
ffffffffc02059ca:	02d00513          	li	a0,45
ffffffffc02059ce:	e03e                	sd	a5,0(sp)
ffffffffc02059d0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02059d2:	6782                	ld	a5,0(sp)
ffffffffc02059d4:	8a66                	mv	s4,s9
ffffffffc02059d6:	40800633          	neg	a2,s0
ffffffffc02059da:	46a9                	li	a3,10
ffffffffc02059dc:	b53d                	j	ffffffffc020580a <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02059de:	03b05163          	blez	s11,ffffffffc0205a00 <vprintfmt+0x34c>
ffffffffc02059e2:	02d00693          	li	a3,45
ffffffffc02059e6:	f6d79de3          	bne	a5,a3,ffffffffc0205960 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02059ea:	00002417          	auipc	s0,0x2
ffffffffc02059ee:	74640413          	addi	s0,s0,1862 # ffffffffc0208130 <syscalls+0x7f8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02059f2:	02800793          	li	a5,40
ffffffffc02059f6:	02800513          	li	a0,40
ffffffffc02059fa:	00140a13          	addi	s4,s0,1
ffffffffc02059fe:	bd6d                	j	ffffffffc02058b8 <vprintfmt+0x204>
ffffffffc0205a00:	00002a17          	auipc	s4,0x2
ffffffffc0205a04:	731a0a13          	addi	s4,s4,1841 # ffffffffc0208131 <syscalls+0x7f9>
ffffffffc0205a08:	02800513          	li	a0,40
ffffffffc0205a0c:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205a10:	05e00413          	li	s0,94
ffffffffc0205a14:	b565                	j	ffffffffc02058bc <vprintfmt+0x208>

ffffffffc0205a16 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205a16:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0205a18:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205a1c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205a1e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205a20:	ec06                	sd	ra,24(sp)
ffffffffc0205a22:	f83a                	sd	a4,48(sp)
ffffffffc0205a24:	fc3e                	sd	a5,56(sp)
ffffffffc0205a26:	e0c2                	sd	a6,64(sp)
ffffffffc0205a28:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0205a2a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205a2c:	c89ff0ef          	jal	ra,ffffffffc02056b4 <vprintfmt>
}
ffffffffc0205a30:	60e2                	ld	ra,24(sp)
ffffffffc0205a32:	6161                	addi	sp,sp,80
ffffffffc0205a34:	8082                	ret

ffffffffc0205a36 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205a36:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0205a3a:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0205a3c:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0205a3e:	cb81                	beqz	a5,ffffffffc0205a4e <strlen+0x18>
        cnt ++;
ffffffffc0205a40:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0205a42:	00a707b3          	add	a5,a4,a0
ffffffffc0205a46:	0007c783          	lbu	a5,0(a5)
ffffffffc0205a4a:	fbfd                	bnez	a5,ffffffffc0205a40 <strlen+0xa>
ffffffffc0205a4c:	8082                	ret
    }
    return cnt;
}
ffffffffc0205a4e:	8082                	ret

ffffffffc0205a50 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0205a50:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205a52:	e589                	bnez	a1,ffffffffc0205a5c <strnlen+0xc>
ffffffffc0205a54:	a811                	j	ffffffffc0205a68 <strnlen+0x18>
        cnt ++;
ffffffffc0205a56:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205a58:	00f58863          	beq	a1,a5,ffffffffc0205a68 <strnlen+0x18>
ffffffffc0205a5c:	00f50733          	add	a4,a0,a5
ffffffffc0205a60:	00074703          	lbu	a4,0(a4)
ffffffffc0205a64:	fb6d                	bnez	a4,ffffffffc0205a56 <strnlen+0x6>
ffffffffc0205a66:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205a68:	852e                	mv	a0,a1
ffffffffc0205a6a:	8082                	ret

ffffffffc0205a6c <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205a6c:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205a6e:	0005c703          	lbu	a4,0(a1)
ffffffffc0205a72:	0785                	addi	a5,a5,1
ffffffffc0205a74:	0585                	addi	a1,a1,1
ffffffffc0205a76:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205a7a:	fb75                	bnez	a4,ffffffffc0205a6e <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205a7c:	8082                	ret

ffffffffc0205a7e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205a7e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205a82:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205a86:	cb89                	beqz	a5,ffffffffc0205a98 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0205a88:	0505                	addi	a0,a0,1
ffffffffc0205a8a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205a8c:	fee789e3          	beq	a5,a4,ffffffffc0205a7e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205a90:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0205a94:	9d19                	subw	a0,a0,a4
ffffffffc0205a96:	8082                	ret
ffffffffc0205a98:	4501                	li	a0,0
ffffffffc0205a9a:	bfed                	j	ffffffffc0205a94 <strcmp+0x16>

ffffffffc0205a9c <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205a9c:	c20d                	beqz	a2,ffffffffc0205abe <strncmp+0x22>
ffffffffc0205a9e:	962e                	add	a2,a2,a1
ffffffffc0205aa0:	a031                	j	ffffffffc0205aac <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0205aa2:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205aa4:	00e79a63          	bne	a5,a4,ffffffffc0205ab8 <strncmp+0x1c>
ffffffffc0205aa8:	00b60b63          	beq	a2,a1,ffffffffc0205abe <strncmp+0x22>
ffffffffc0205aac:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0205ab0:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205ab2:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0205ab6:	f7f5                	bnez	a5,ffffffffc0205aa2 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205ab8:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0205abc:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205abe:	4501                	li	a0,0
ffffffffc0205ac0:	8082                	ret

ffffffffc0205ac2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0205ac2:	00054783          	lbu	a5,0(a0)
ffffffffc0205ac6:	c799                	beqz	a5,ffffffffc0205ad4 <strchr+0x12>
        if (*s == c) {
ffffffffc0205ac8:	00f58763          	beq	a1,a5,ffffffffc0205ad6 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0205acc:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0205ad0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0205ad2:	fbfd                	bnez	a5,ffffffffc0205ac8 <strchr+0x6>
    }
    return NULL;
ffffffffc0205ad4:	4501                	li	a0,0
}
ffffffffc0205ad6:	8082                	ret

ffffffffc0205ad8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0205ad8:	ca01                	beqz	a2,ffffffffc0205ae8 <memset+0x10>
ffffffffc0205ada:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0205adc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0205ade:	0785                	addi	a5,a5,1
ffffffffc0205ae0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0205ae4:	fec79de3          	bne	a5,a2,ffffffffc0205ade <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205ae8:	8082                	ret

ffffffffc0205aea <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205aea:	ca19                	beqz	a2,ffffffffc0205b00 <memcpy+0x16>
ffffffffc0205aec:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0205aee:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0205af0:	0005c703          	lbu	a4,0(a1)
ffffffffc0205af4:	0585                	addi	a1,a1,1
ffffffffc0205af6:	0785                	addi	a5,a5,1
ffffffffc0205af8:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0205afc:	fec59ae3          	bne	a1,a2,ffffffffc0205af0 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0205b00:	8082                	ret
