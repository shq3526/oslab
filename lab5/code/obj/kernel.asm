
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	0000b297          	auipc	t0,0xb
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc020b000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	0000b297          	auipc	t0,0xb
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc020b008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c020a2b7          	lui	t0,0xc020a
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
ffffffffc020003c:	c020a137          	lui	sp,0xc020a

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
ffffffffc020004a:	000c6517          	auipc	a0,0xc6
ffffffffc020004e:	93e50513          	addi	a0,a0,-1730 # ffffffffc02c5988 <buf>
ffffffffc0200052:	000ca617          	auipc	a2,0xca
ffffffffc0200056:	de260613          	addi	a2,a2,-542 # ffffffffc02c9e34 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	171050ef          	jal	ra,ffffffffc02059d2 <memset>
    dtb_init();
ffffffffc0200066:	598000ef          	jal	ra,ffffffffc02005fe <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	522000ef          	jal	ra,ffffffffc020058c <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00006597          	auipc	a1,0x6
ffffffffc0200072:	99258593          	addi	a1,a1,-1646 # ffffffffc0205a00 <etext+0x4>
ffffffffc0200076:	00006517          	auipc	a0,0x6
ffffffffc020007a:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0205a20 <etext+0x24>
ffffffffc020007e:	116000ef          	jal	ra,ffffffffc0200194 <cprintf>

    print_kerninfo();
ffffffffc0200082:	19a000ef          	jal	ra,ffffffffc020021c <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	76c020ef          	jal	ra,ffffffffc02027f2 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	131000ef          	jal	ra,ffffffffc02009ba <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	12f000ef          	jal	ra,ffffffffc02009bc <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	2ad030ef          	jal	ra,ffffffffc0203b3e <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	074050ef          	jal	ra,ffffffffc020510a <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	4a0000ef          	jal	ra,ffffffffc020053a <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	111000ef          	jal	ra,ffffffffc02009ae <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	200050ef          	jal	ra,ffffffffc02052a2 <cpu_idle>

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
ffffffffc02000c0:	96c50513          	addi	a0,a0,-1684 # ffffffffc0205a28 <etext+0x2c>
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
ffffffffc02000d2:	000c6b97          	auipc	s7,0xc6
ffffffffc02000d6:	8b6b8b93          	addi	s7,s7,-1866 # ffffffffc02c5988 <buf>
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
ffffffffc020012e:	000c6517          	auipc	a0,0xc6
ffffffffc0200132:	85a50513          	addi	a0,a0,-1958 # ffffffffc02c5988 <buf>
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
ffffffffc0200188:	426050ef          	jal	ra,ffffffffc02055ae <vprintfmt>
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
ffffffffc0200196:	02810313          	addi	t1,sp,40 # ffffffffc020a028 <boot_page_table_sv39+0x28>
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
ffffffffc02001be:	3f0050ef          	jal	ra,ffffffffc02055ae <vprintfmt>
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
ffffffffc0200222:	81250513          	addi	a0,a0,-2030 # ffffffffc0205a30 <etext+0x34>
{
ffffffffc0200226:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200228:	f6dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020022c:	00000597          	auipc	a1,0x0
ffffffffc0200230:	e1e58593          	addi	a1,a1,-482 # ffffffffc020004a <kern_init>
ffffffffc0200234:	00006517          	auipc	a0,0x6
ffffffffc0200238:	81c50513          	addi	a0,a0,-2020 # ffffffffc0205a50 <etext+0x54>
ffffffffc020023c:	f59ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200240:	00005597          	auipc	a1,0x5
ffffffffc0200244:	7bc58593          	addi	a1,a1,1980 # ffffffffc02059fc <etext>
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	82850513          	addi	a0,a0,-2008 # ffffffffc0205a70 <etext+0x74>
ffffffffc0200250:	f45ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200254:	000c5597          	auipc	a1,0xc5
ffffffffc0200258:	73458593          	addi	a1,a1,1844 # ffffffffc02c5988 <buf>
ffffffffc020025c:	00006517          	auipc	a0,0x6
ffffffffc0200260:	83450513          	addi	a0,a0,-1996 # ffffffffc0205a90 <etext+0x94>
ffffffffc0200264:	f31ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200268:	000ca597          	auipc	a1,0xca
ffffffffc020026c:	bcc58593          	addi	a1,a1,-1076 # ffffffffc02c9e34 <end>
ffffffffc0200270:	00006517          	auipc	a0,0x6
ffffffffc0200274:	84050513          	addi	a0,a0,-1984 # ffffffffc0205ab0 <etext+0xb4>
ffffffffc0200278:	f1dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020027c:	000ca597          	auipc	a1,0xca
ffffffffc0200280:	fb758593          	addi	a1,a1,-73 # ffffffffc02ca233 <end+0x3ff>
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
ffffffffc02002a2:	83250513          	addi	a0,a0,-1998 # ffffffffc0205ad0 <etext+0xd4>
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
ffffffffc02002b0:	85460613          	addi	a2,a2,-1964 # ffffffffc0205b00 <etext+0x104>
ffffffffc02002b4:	04f00593          	li	a1,79
ffffffffc02002b8:	00006517          	auipc	a0,0x6
ffffffffc02002bc:	86050513          	addi	a0,a0,-1952 # ffffffffc0205b18 <etext+0x11c>
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
ffffffffc02002cc:	86860613          	addi	a2,a2,-1944 # ffffffffc0205b30 <etext+0x134>
ffffffffc02002d0:	00006597          	auipc	a1,0x6
ffffffffc02002d4:	88058593          	addi	a1,a1,-1920 # ffffffffc0205b50 <etext+0x154>
ffffffffc02002d8:	00006517          	auipc	a0,0x6
ffffffffc02002dc:	88050513          	addi	a0,a0,-1920 # ffffffffc0205b58 <etext+0x15c>
{
ffffffffc02002e0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e2:	eb3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002e6:	00006617          	auipc	a2,0x6
ffffffffc02002ea:	88260613          	addi	a2,a2,-1918 # ffffffffc0205b68 <etext+0x16c>
ffffffffc02002ee:	00006597          	auipc	a1,0x6
ffffffffc02002f2:	8a258593          	addi	a1,a1,-1886 # ffffffffc0205b90 <etext+0x194>
ffffffffc02002f6:	00006517          	auipc	a0,0x6
ffffffffc02002fa:	86250513          	addi	a0,a0,-1950 # ffffffffc0205b58 <etext+0x15c>
ffffffffc02002fe:	e97ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200302:	00006617          	auipc	a2,0x6
ffffffffc0200306:	89e60613          	addi	a2,a2,-1890 # ffffffffc0205ba0 <etext+0x1a4>
ffffffffc020030a:	00006597          	auipc	a1,0x6
ffffffffc020030e:	8b658593          	addi	a1,a1,-1866 # ffffffffc0205bc0 <etext+0x1c4>
ffffffffc0200312:	00006517          	auipc	a0,0x6
ffffffffc0200316:	84650513          	addi	a0,a0,-1978 # ffffffffc0205b58 <etext+0x15c>
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
ffffffffc0200350:	88450513          	addi	a0,a0,-1916 # ffffffffc0205bd0 <etext+0x1d4>
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
ffffffffc0200372:	88a50513          	addi	a0,a0,-1910 # ffffffffc0205bf8 <etext+0x1fc>
ffffffffc0200376:	e1fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if (tf != NULL)
ffffffffc020037a:	000b8563          	beqz	s7,ffffffffc0200384 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037e:	855e                	mv	a0,s7
ffffffffc0200380:	025000ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
ffffffffc0200384:	00006c17          	auipc	s8,0x6
ffffffffc0200388:	8e4c0c13          	addi	s8,s8,-1820 # ffffffffc0205c68 <commands>
        if ((buf = readline("K> ")) != NULL)
ffffffffc020038c:	00006917          	auipc	s2,0x6
ffffffffc0200390:	89490913          	addi	s2,s2,-1900 # ffffffffc0205c20 <etext+0x224>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200394:	00006497          	auipc	s1,0x6
ffffffffc0200398:	89448493          	addi	s1,s1,-1900 # ffffffffc0205c28 <etext+0x22c>
        if (argc == MAXARGS - 1)
ffffffffc020039c:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039e:	00006b17          	auipc	s6,0x6
ffffffffc02003a2:	892b0b13          	addi	s6,s6,-1902 # ffffffffc0205c30 <etext+0x234>
        argv[argc++] = buf;
ffffffffc02003a6:	00005a17          	auipc	s4,0x5
ffffffffc02003aa:	7aaa0a13          	addi	s4,s4,1962 # ffffffffc0205b50 <etext+0x154>
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
ffffffffc02003cc:	8a0d0d13          	addi	s10,s10,-1888 # ffffffffc0205c68 <commands>
        argv[argc++] = buf;
ffffffffc02003d0:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003d2:	4401                	li	s0,0
ffffffffc02003d4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003d6:	5a2050ef          	jal	ra,ffffffffc0205978 <strcmp>
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
ffffffffc02003ea:	58e050ef          	jal	ra,ffffffffc0205978 <strcmp>
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
ffffffffc0200428:	594050ef          	jal	ra,ffffffffc02059bc <strchr>
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
ffffffffc0200466:	556050ef          	jal	ra,ffffffffc02059bc <strchr>
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
ffffffffc0200480:	00005517          	auipc	a0,0x5
ffffffffc0200484:	7d050513          	addi	a0,a0,2000 # ffffffffc0205c50 <etext+0x254>
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
ffffffffc020048e:	000ca317          	auipc	t1,0xca
ffffffffc0200492:	92230313          	addi	t1,t1,-1758 # ffffffffc02c9db0 <is_panic>
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
ffffffffc02004bc:	00005517          	auipc	a0,0x5
ffffffffc02004c0:	7f450513          	addi	a0,a0,2036 # ffffffffc0205cb0 <commands+0x48>
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
ffffffffc02004d6:	91650513          	addi	a0,a0,-1770 # ffffffffc0206de8 <default_pmm_manager+0x578>
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
ffffffffc0200506:	00005517          	auipc	a0,0x5
ffffffffc020050a:	7ca50513          	addi	a0,a0,1994 # ffffffffc0205cd0 <commands+0x68>
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
ffffffffc020052a:	8c250513          	addi	a0,a0,-1854 # ffffffffc0206de8 <default_pmm_manager+0x578>
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
ffffffffc020053c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd4d8>
ffffffffc0200540:	000ca717          	auipc	a4,0xca
ffffffffc0200544:	88f73023          	sd	a5,-1920(a4) # ffffffffc02c9dc0 <timebase>
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
ffffffffc0200560:	00005517          	auipc	a0,0x5
ffffffffc0200564:	79050513          	addi	a0,a0,1936 # ffffffffc0205cf0 <commands+0x88>
    ticks = 0;
ffffffffc0200568:	000ca797          	auipc	a5,0xca
ffffffffc020056c:	8407b823          	sd	zero,-1968(a5) # ffffffffc02c9db8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200570:	b115                	j	ffffffffc0200194 <cprintf>

ffffffffc0200572 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200572:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200576:	000ca797          	auipc	a5,0xca
ffffffffc020057a:	84a7b783          	ld	a5,-1974(a5) # ffffffffc02c9dc0 <timebase>
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
#include <riscv.h>
#include <assert.h>

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
    return 0;
}

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
ffffffffc0200600:	00005517          	auipc	a0,0x5
ffffffffc0200604:	71050513          	addi	a0,a0,1808 # ffffffffc0205d10 <commands+0xa8>
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
ffffffffc0200626:	0000b597          	auipc	a1,0xb
ffffffffc020062a:	9da5b583          	ld	a1,-1574(a1) # ffffffffc020b000 <boot_hartid>
ffffffffc020062e:	00005517          	auipc	a0,0x5
ffffffffc0200632:	6f250513          	addi	a0,a0,1778 # ffffffffc0205d20 <commands+0xb8>
ffffffffc0200636:	b5fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020063a:	0000b417          	auipc	s0,0xb
ffffffffc020063e:	9ce40413          	addi	s0,s0,-1586 # ffffffffc020b008 <boot_dtb>
ffffffffc0200642:	600c                	ld	a1,0(s0)
ffffffffc0200644:	00005517          	auipc	a0,0x5
ffffffffc0200648:	6ec50513          	addi	a0,a0,1772 # ffffffffc0205d30 <commands+0xc8>
ffffffffc020064c:	b49ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200650:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200654:	00005517          	auipc	a0,0x5
ffffffffc0200658:	6f450513          	addi	a0,a0,1780 # ffffffffc0205d48 <commands+0xe0>
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
ffffffffc020069c:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe160b9>
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
ffffffffc0200712:	68a90913          	addi	s2,s2,1674 # ffffffffc0205d98 <commands+0x130>
ffffffffc0200716:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200718:	4d91                	li	s11,4
ffffffffc020071a:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020071c:	00005497          	auipc	s1,0x5
ffffffffc0200720:	67448493          	addi	s1,s1,1652 # ffffffffc0205d90 <commands+0x128>
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
ffffffffc0200774:	6a050513          	addi	a0,a0,1696 # ffffffffc0205e10 <commands+0x1a8>
ffffffffc0200778:	a1dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020077c:	00005517          	auipc	a0,0x5
ffffffffc0200780:	6cc50513          	addi	a0,a0,1740 # ffffffffc0205e48 <commands+0x1e0>
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
ffffffffc02007c0:	5ac50513          	addi	a0,a0,1452 # ffffffffc0205d68 <commands+0x100>
}
ffffffffc02007c4:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02007c6:	b2f9                	j	ffffffffc0200194 <cprintf>
                int name_len = strlen(name);
ffffffffc02007c8:	8556                	mv	a0,s5
ffffffffc02007ca:	166050ef          	jal	ra,ffffffffc0205930 <strlen>
ffffffffc02007ce:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d0:	4619                	li	a2,6
ffffffffc02007d2:	85a6                	mv	a1,s1
ffffffffc02007d4:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02007d6:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02007d8:	1be050ef          	jal	ra,ffffffffc0205996 <strncmp>
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
ffffffffc020086e:	10a050ef          	jal	ra,ffffffffc0205978 <strcmp>
ffffffffc0200872:	66a2                	ld	a3,8(sp)
ffffffffc0200874:	f94d                	bnez	a0,ffffffffc0200826 <dtb_init+0x228>
ffffffffc0200876:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200826 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020087a:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020087e:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200882:	00005517          	auipc	a0,0x5
ffffffffc0200886:	51e50513          	addi	a0,a0,1310 # ffffffffc0205da0 <commands+0x138>
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
ffffffffc0200954:	47050513          	addi	a0,a0,1136 # ffffffffc0205dc0 <commands+0x158>
ffffffffc0200958:	83dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020095c:	014b5613          	srli	a2,s6,0x14
ffffffffc0200960:	85da                	mv	a1,s6
ffffffffc0200962:	00005517          	auipc	a0,0x5
ffffffffc0200966:	47650513          	addi	a0,a0,1142 # ffffffffc0205dd8 <commands+0x170>
ffffffffc020096a:	82bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc020096e:	008b05b3          	add	a1,s6,s0
ffffffffc0200972:	15fd                	addi	a1,a1,-1
ffffffffc0200974:	00005517          	auipc	a0,0x5
ffffffffc0200978:	48450513          	addi	a0,a0,1156 # ffffffffc0205df8 <commands+0x190>
ffffffffc020097c:	819ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200980:	00005517          	auipc	a0,0x5
ffffffffc0200984:	4c850513          	addi	a0,a0,1224 # ffffffffc0205e48 <commands+0x1e0>
        memory_base = mem_base;
ffffffffc0200988:	000c9797          	auipc	a5,0xc9
ffffffffc020098c:	4487b023          	sd	s0,1088(a5) # ffffffffc02c9dc8 <memory_base>
        memory_size = mem_size;
ffffffffc0200990:	000c9797          	auipc	a5,0xc9
ffffffffc0200994:	4567b023          	sd	s6,1088(a5) # ffffffffc02c9dd0 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200998:	b3f5                	j	ffffffffc0200784 <dtb_init+0x186>

ffffffffc020099a <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc020099a:	000c9517          	auipc	a0,0xc9
ffffffffc020099e:	42e53503          	ld	a0,1070(a0) # ffffffffc02c9dc8 <memory_base>
ffffffffc02009a2:	8082                	ret

ffffffffc02009a4 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02009a4:	000c9517          	auipc	a0,0xc9
ffffffffc02009a8:	42c53503          	ld	a0,1068(a0) # ffffffffc02c9dd0 <memory_size>
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
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc02009bc:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc02009c0:	00000797          	auipc	a5,0x0
ffffffffc02009c4:	56078793          	addi	a5,a5,1376 # ffffffffc0200f20 <__alltraps>
ffffffffc02009c8:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
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
ffffffffc02009e2:	48250513          	addi	a0,a0,1154 # ffffffffc0205e60 <commands+0x1f8>
{
ffffffffc02009e6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009e8:	facff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009ec:	640c                	ld	a1,8(s0)
ffffffffc02009ee:	00005517          	auipc	a0,0x5
ffffffffc02009f2:	48a50513          	addi	a0,a0,1162 # ffffffffc0205e78 <commands+0x210>
ffffffffc02009f6:	f9eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009fa:	680c                	ld	a1,16(s0)
ffffffffc02009fc:	00005517          	auipc	a0,0x5
ffffffffc0200a00:	49450513          	addi	a0,a0,1172 # ffffffffc0205e90 <commands+0x228>
ffffffffc0200a04:	f90ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200a08:	6c0c                	ld	a1,24(s0)
ffffffffc0200a0a:	00005517          	auipc	a0,0x5
ffffffffc0200a0e:	49e50513          	addi	a0,a0,1182 # ffffffffc0205ea8 <commands+0x240>
ffffffffc0200a12:	f82ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200a16:	700c                	ld	a1,32(s0)
ffffffffc0200a18:	00005517          	auipc	a0,0x5
ffffffffc0200a1c:	4a850513          	addi	a0,a0,1192 # ffffffffc0205ec0 <commands+0x258>
ffffffffc0200a20:	f74ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200a24:	740c                	ld	a1,40(s0)
ffffffffc0200a26:	00005517          	auipc	a0,0x5
ffffffffc0200a2a:	4b250513          	addi	a0,a0,1202 # ffffffffc0205ed8 <commands+0x270>
ffffffffc0200a2e:	f66ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200a32:	780c                	ld	a1,48(s0)
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	4bc50513          	addi	a0,a0,1212 # ffffffffc0205ef0 <commands+0x288>
ffffffffc0200a3c:	f58ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a40:	7c0c                	ld	a1,56(s0)
ffffffffc0200a42:	00005517          	auipc	a0,0x5
ffffffffc0200a46:	4c650513          	addi	a0,a0,1222 # ffffffffc0205f08 <commands+0x2a0>
ffffffffc0200a4a:	f4aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a4e:	602c                	ld	a1,64(s0)
ffffffffc0200a50:	00005517          	auipc	a0,0x5
ffffffffc0200a54:	4d050513          	addi	a0,a0,1232 # ffffffffc0205f20 <commands+0x2b8>
ffffffffc0200a58:	f3cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a5c:	642c                	ld	a1,72(s0)
ffffffffc0200a5e:	00005517          	auipc	a0,0x5
ffffffffc0200a62:	4da50513          	addi	a0,a0,1242 # ffffffffc0205f38 <commands+0x2d0>
ffffffffc0200a66:	f2eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a6a:	682c                	ld	a1,80(s0)
ffffffffc0200a6c:	00005517          	auipc	a0,0x5
ffffffffc0200a70:	4e450513          	addi	a0,a0,1252 # ffffffffc0205f50 <commands+0x2e8>
ffffffffc0200a74:	f20ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a78:	6c2c                	ld	a1,88(s0)
ffffffffc0200a7a:	00005517          	auipc	a0,0x5
ffffffffc0200a7e:	4ee50513          	addi	a0,a0,1262 # ffffffffc0205f68 <commands+0x300>
ffffffffc0200a82:	f12ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a86:	702c                	ld	a1,96(s0)
ffffffffc0200a88:	00005517          	auipc	a0,0x5
ffffffffc0200a8c:	4f850513          	addi	a0,a0,1272 # ffffffffc0205f80 <commands+0x318>
ffffffffc0200a90:	f04ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a94:	742c                	ld	a1,104(s0)
ffffffffc0200a96:	00005517          	auipc	a0,0x5
ffffffffc0200a9a:	50250513          	addi	a0,a0,1282 # ffffffffc0205f98 <commands+0x330>
ffffffffc0200a9e:	ef6ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200aa2:	782c                	ld	a1,112(s0)
ffffffffc0200aa4:	00005517          	auipc	a0,0x5
ffffffffc0200aa8:	50c50513          	addi	a0,a0,1292 # ffffffffc0205fb0 <commands+0x348>
ffffffffc0200aac:	ee8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200ab0:	7c2c                	ld	a1,120(s0)
ffffffffc0200ab2:	00005517          	auipc	a0,0x5
ffffffffc0200ab6:	51650513          	addi	a0,a0,1302 # ffffffffc0205fc8 <commands+0x360>
ffffffffc0200aba:	edaff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200abe:	604c                	ld	a1,128(s0)
ffffffffc0200ac0:	00005517          	auipc	a0,0x5
ffffffffc0200ac4:	52050513          	addi	a0,a0,1312 # ffffffffc0205fe0 <commands+0x378>
ffffffffc0200ac8:	eccff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200acc:	644c                	ld	a1,136(s0)
ffffffffc0200ace:	00005517          	auipc	a0,0x5
ffffffffc0200ad2:	52a50513          	addi	a0,a0,1322 # ffffffffc0205ff8 <commands+0x390>
ffffffffc0200ad6:	ebeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200ada:	684c                	ld	a1,144(s0)
ffffffffc0200adc:	00005517          	auipc	a0,0x5
ffffffffc0200ae0:	53450513          	addi	a0,a0,1332 # ffffffffc0206010 <commands+0x3a8>
ffffffffc0200ae4:	eb0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200ae8:	6c4c                	ld	a1,152(s0)
ffffffffc0200aea:	00005517          	auipc	a0,0x5
ffffffffc0200aee:	53e50513          	addi	a0,a0,1342 # ffffffffc0206028 <commands+0x3c0>
ffffffffc0200af2:	ea2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200af6:	704c                	ld	a1,160(s0)
ffffffffc0200af8:	00005517          	auipc	a0,0x5
ffffffffc0200afc:	54850513          	addi	a0,a0,1352 # ffffffffc0206040 <commands+0x3d8>
ffffffffc0200b00:	e94ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200b04:	744c                	ld	a1,168(s0)
ffffffffc0200b06:	00005517          	auipc	a0,0x5
ffffffffc0200b0a:	55250513          	addi	a0,a0,1362 # ffffffffc0206058 <commands+0x3f0>
ffffffffc0200b0e:	e86ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200b12:	784c                	ld	a1,176(s0)
ffffffffc0200b14:	00005517          	auipc	a0,0x5
ffffffffc0200b18:	55c50513          	addi	a0,a0,1372 # ffffffffc0206070 <commands+0x408>
ffffffffc0200b1c:	e78ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200b20:	7c4c                	ld	a1,184(s0)
ffffffffc0200b22:	00005517          	auipc	a0,0x5
ffffffffc0200b26:	56650513          	addi	a0,a0,1382 # ffffffffc0206088 <commands+0x420>
ffffffffc0200b2a:	e6aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200b2e:	606c                	ld	a1,192(s0)
ffffffffc0200b30:	00005517          	auipc	a0,0x5
ffffffffc0200b34:	57050513          	addi	a0,a0,1392 # ffffffffc02060a0 <commands+0x438>
ffffffffc0200b38:	e5cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200b3c:	646c                	ld	a1,200(s0)
ffffffffc0200b3e:	00005517          	auipc	a0,0x5
ffffffffc0200b42:	57a50513          	addi	a0,a0,1402 # ffffffffc02060b8 <commands+0x450>
ffffffffc0200b46:	e4eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b4a:	686c                	ld	a1,208(s0)
ffffffffc0200b4c:	00005517          	auipc	a0,0x5
ffffffffc0200b50:	58450513          	addi	a0,a0,1412 # ffffffffc02060d0 <commands+0x468>
ffffffffc0200b54:	e40ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b58:	6c6c                	ld	a1,216(s0)
ffffffffc0200b5a:	00005517          	auipc	a0,0x5
ffffffffc0200b5e:	58e50513          	addi	a0,a0,1422 # ffffffffc02060e8 <commands+0x480>
ffffffffc0200b62:	e32ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b66:	706c                	ld	a1,224(s0)
ffffffffc0200b68:	00005517          	auipc	a0,0x5
ffffffffc0200b6c:	59850513          	addi	a0,a0,1432 # ffffffffc0206100 <commands+0x498>
ffffffffc0200b70:	e24ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b74:	746c                	ld	a1,232(s0)
ffffffffc0200b76:	00005517          	auipc	a0,0x5
ffffffffc0200b7a:	5a250513          	addi	a0,a0,1442 # ffffffffc0206118 <commands+0x4b0>
ffffffffc0200b7e:	e16ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b82:	786c                	ld	a1,240(s0)
ffffffffc0200b84:	00005517          	auipc	a0,0x5
ffffffffc0200b88:	5ac50513          	addi	a0,a0,1452 # ffffffffc0206130 <commands+0x4c8>
ffffffffc0200b8c:	e08ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b90:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b92:	6402                	ld	s0,0(sp)
ffffffffc0200b94:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b96:	00005517          	auipc	a0,0x5
ffffffffc0200b9a:	5b250513          	addi	a0,a0,1458 # ffffffffc0206148 <commands+0x4e0>
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
ffffffffc0200bb0:	5b450513          	addi	a0,a0,1460 # ffffffffc0206160 <commands+0x4f8>
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
ffffffffc0200bc8:	5b450513          	addi	a0,a0,1460 # ffffffffc0206178 <commands+0x510>
ffffffffc0200bcc:	dc8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200bd0:	10843583          	ld	a1,264(s0)
ffffffffc0200bd4:	00005517          	auipc	a0,0x5
ffffffffc0200bd8:	5bc50513          	addi	a0,a0,1468 # ffffffffc0206190 <commands+0x528>
ffffffffc0200bdc:	db8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200be0:	11043583          	ld	a1,272(s0)
ffffffffc0200be4:	00005517          	auipc	a0,0x5
ffffffffc0200be8:	5c450513          	addi	a0,a0,1476 # ffffffffc02061a8 <commands+0x540>
ffffffffc0200bec:	da8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf0:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bf4:	6402                	ld	s0,0(sp)
ffffffffc0200bf6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf8:	00005517          	auipc	a0,0x5
ffffffffc0200bfc:	5c050513          	addi	a0,a0,1472 # ffffffffc02061b8 <commands+0x550>
}
ffffffffc0200c00:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200c02:	d92ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200c06 <interrupt_handler>:

extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200c06:	11853783          	ld	a5,280(a0)
ffffffffc0200c0a:	472d                	li	a4,11
ffffffffc0200c0c:	0786                	slli	a5,a5,0x1
ffffffffc0200c0e:	8385                	srli	a5,a5,0x1
ffffffffc0200c10:	08f76763          	bltu	a4,a5,ffffffffc0200c9e <interrupt_handler+0x98>
ffffffffc0200c14:	00005717          	auipc	a4,0x5
ffffffffc0200c18:	65c70713          	addi	a4,a4,1628 # ffffffffc0206270 <commands+0x608>
ffffffffc0200c1c:	078a                	slli	a5,a5,0x2
ffffffffc0200c1e:	97ba                	add	a5,a5,a4
ffffffffc0200c20:	439c                	lw	a5,0(a5)
ffffffffc0200c22:	97ba                	add	a5,a5,a4
ffffffffc0200c24:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200c26:	00005517          	auipc	a0,0x5
ffffffffc0200c2a:	60a50513          	addi	a0,a0,1546 # ffffffffc0206230 <commands+0x5c8>
ffffffffc0200c2e:	d66ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c32:	00005517          	auipc	a0,0x5
ffffffffc0200c36:	5de50513          	addi	a0,a0,1502 # ffffffffc0206210 <commands+0x5a8>
ffffffffc0200c3a:	d5aff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200c3e:	00005517          	auipc	a0,0x5
ffffffffc0200c42:	59250513          	addi	a0,a0,1426 # ffffffffc02061d0 <commands+0x568>
ffffffffc0200c46:	d4eff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c4a:	00005517          	auipc	a0,0x5
ffffffffc0200c4e:	5a650513          	addi	a0,a0,1446 # ffffffffc02061f0 <commands+0x588>
ffffffffc0200c52:	d42ff06f          	j	ffffffffc0200194 <cprintf>
{
ffffffffc0200c56:	1141                	addi	sp,sp,-16
ffffffffc0200c58:	e406                	sd	ra,8(sp)
        *(1) 设置下一次时钟中断（clock_set_next_event）
        *(2) ticks 计数器自增
        *(3) 每 TICK_NUM 次中断（如 100 次），进行判断当前是否有进程正在运行，如果有则标记该进程需要被重新调度（current->need_resched）
        */
        // (1) 设置下次时钟中断 (保持心跳)
        clock_set_next_event();
ffffffffc0200c5a:	919ff0ef          	jal	ra,ffffffffc0200572 <clock_set_next_event>

        // (2) 计数器（ticks）加一 (更新系统时间

        // (3) 检查时间片是否耗尽
        ticks++;
ffffffffc0200c5e:	000c9697          	auipc	a3,0xc9
ffffffffc0200c62:	15a68693          	addi	a3,a3,346 # ffffffffc02c9db8 <ticks>
ffffffffc0200c66:	629c                	ld	a5,0(a3)

    // 【核心修复：手动消耗时间片】
    // 只有这样，schedule 里设置的 time_slice = 10 才会慢慢变成 0
        if (current != NULL) {
ffffffffc0200c68:	000c9717          	auipc	a4,0xc9
ffffffffc0200c6c:	1b073703          	ld	a4,432(a4) # ffffffffc02c9e18 <current>
        ticks++;
ffffffffc0200c70:	0785                	addi	a5,a5,1
ffffffffc0200c72:	e29c                	sd	a5,0(a3)
        if (current != NULL) {
ffffffffc0200c74:	cf01                	beqz	a4,ffffffffc0200c8c <interrupt_handler+0x86>
            if (current->time_slice > 0) {
ffffffffc0200c76:	10872783          	lw	a5,264(a4)
ffffffffc0200c7a:	00f05763          	blez	a5,ffffffffc0200c88 <interrupt_handler+0x82>
                current->time_slice--;
ffffffffc0200c7e:	fff7869b          	addiw	a3,a5,-1
ffffffffc0200c82:	10d72423          	sw	a3,264(a4)
            }
            
            // 当时间片耗尽时，标记需要调度
            if (current->time_slice <= 0) {
ffffffffc0200c86:	e299                	bnez	a3,ffffffffc0200c8c <interrupt_handler+0x86>
                current->need_resched = 1;
ffffffffc0200c88:	4785                	li	a5,1
ffffffffc0200c8a:	ef1c                	sd	a5,24(a4)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c8c:	60a2                	ld	ra,8(sp)
ffffffffc0200c8e:	0141                	addi	sp,sp,16
ffffffffc0200c90:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200c92:	00005517          	auipc	a0,0x5
ffffffffc0200c96:	5be50513          	addi	a0,a0,1470 # ffffffffc0206250 <commands+0x5e8>
ffffffffc0200c9a:	cfaff06f          	j	ffffffffc0200194 <cprintf>
        print_trapframe(tf);
ffffffffc0200c9e:	b719                	j	ffffffffc0200ba4 <print_trapframe>

ffffffffc0200ca0 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200ca0:	11853783          	ld	a5,280(a0)
{
ffffffffc0200ca4:	1101                	addi	sp,sp,-32
ffffffffc0200ca6:	e822                	sd	s0,16(sp)
ffffffffc0200ca8:	ec06                	sd	ra,24(sp)
ffffffffc0200caa:	e426                	sd	s1,8(sp)
ffffffffc0200cac:	473d                	li	a4,15
ffffffffc0200cae:	842a                	mv	s0,a0
ffffffffc0200cb0:	18f76063          	bltu	a4,a5,ffffffffc0200e30 <exception_handler+0x190>
ffffffffc0200cb4:	00005717          	auipc	a4,0x5
ffffffffc0200cb8:	7bc70713          	addi	a4,a4,1980 # ffffffffc0206470 <commands+0x808>
ffffffffc0200cbc:	078a                	slli	a5,a5,0x2
ffffffffc0200cbe:	97ba                	add	a5,a5,a4
ffffffffc0200cc0:	439c                	lw	a5,0(a5)
ffffffffc0200cc2:	97ba                	add	a5,a5,a4
ffffffffc0200cc4:	8782                	jr	a5
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200cc6:	00005517          	auipc	a0,0x5
ffffffffc0200cca:	6c250513          	addi	a0,a0,1730 # ffffffffc0206388 <commands+0x720>
ffffffffc0200cce:	cc6ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        tf->epc += 4;
ffffffffc0200cd2:	10843783          	ld	a5,264(s0)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200cd6:	60e2                	ld	ra,24(sp)
ffffffffc0200cd8:	64a2                	ld	s1,8(sp)
        tf->epc += 4;
ffffffffc0200cda:	0791                	addi	a5,a5,4
ffffffffc0200cdc:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200ce0:	6442                	ld	s0,16(sp)
ffffffffc0200ce2:	6105                	addi	sp,sp,32
        syscall();
ffffffffc0200ce4:	7c60406f          	j	ffffffffc02054aa <syscall>
        cprintf("Environment call from H-mode\n");
ffffffffc0200ce8:	00005517          	auipc	a0,0x5
ffffffffc0200cec:	6c050513          	addi	a0,a0,1728 # ffffffffc02063a8 <commands+0x740>
}
ffffffffc0200cf0:	6442                	ld	s0,16(sp)
ffffffffc0200cf2:	60e2                	ld	ra,24(sp)
ffffffffc0200cf4:	64a2                	ld	s1,8(sp)
ffffffffc0200cf6:	6105                	addi	sp,sp,32
        cprintf("Instruction access fault\n");
ffffffffc0200cf8:	c9cff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200cfc:	00005517          	auipc	a0,0x5
ffffffffc0200d00:	6cc50513          	addi	a0,a0,1740 # ffffffffc02063c8 <commands+0x760>
ffffffffc0200d04:	b7f5                	j	ffffffffc0200cf0 <exception_handler+0x50>
        cprintf("Instruction page fault\n");
ffffffffc0200d06:	00005517          	auipc	a0,0x5
ffffffffc0200d0a:	6e250513          	addi	a0,a0,1762 # ffffffffc02063e8 <commands+0x780>
ffffffffc0200d0e:	c86ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (do_pgfault(current->mm, tf->cause, tf->tval) != 0) {
ffffffffc0200d12:	000c9497          	auipc	s1,0xc9
ffffffffc0200d16:	10648493          	addi	s1,s1,262 # ffffffffc02c9e18 <current>
ffffffffc0200d1a:	609c                	ld	a5,0(s1)
ffffffffc0200d1c:	11043603          	ld	a2,272(s0)
ffffffffc0200d20:	11842583          	lw	a1,280(s0)
ffffffffc0200d24:	7788                	ld	a0,40(a5)
ffffffffc0200d26:	1d0030ef          	jal	ra,ffffffffc0203ef6 <do_pgfault>
ffffffffc0200d2a:	0c050f63          	beqz	a0,ffffffffc0200e08 <exception_handler+0x168>
            print_trapframe(tf);
ffffffffc0200d2e:	8522                	mv	a0,s0
ffffffffc0200d30:	e75ff0ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
            if (current == NULL) {
ffffffffc0200d34:	609c                	ld	a5,0(s1)
ffffffffc0200d36:	ebc9                	bnez	a5,ffffffffc0200dc8 <exception_handler+0x128>
                panic("handle_exception: page fault in kernel (current == NULL)");
ffffffffc0200d38:	00005617          	auipc	a2,0x5
ffffffffc0200d3c:	6c860613          	addi	a2,a2,1736 # ffffffffc0206400 <commands+0x798>
ffffffffc0200d40:	0e800593          	li	a1,232
ffffffffc0200d44:	00005517          	auipc	a0,0x5
ffffffffc0200d48:	61450513          	addi	a0,a0,1556 # ffffffffc0206358 <commands+0x6f0>
ffffffffc0200d4c:	f42ff0ef          	jal	ra,ffffffffc020048e <__panic>
        cprintf("Load page fault\n");
ffffffffc0200d50:	00005517          	auipc	a0,0x5
ffffffffc0200d54:	6f050513          	addi	a0,a0,1776 # ffffffffc0206440 <commands+0x7d8>
ffffffffc0200d58:	c3cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (do_pgfault(current->mm, tf->cause, tf->tval) != 0) {
ffffffffc0200d5c:	000c9497          	auipc	s1,0xc9
ffffffffc0200d60:	0bc48493          	addi	s1,s1,188 # ffffffffc02c9e18 <current>
ffffffffc0200d64:	609c                	ld	a5,0(s1)
ffffffffc0200d66:	11043603          	ld	a2,272(s0)
ffffffffc0200d6a:	11842583          	lw	a1,280(s0)
ffffffffc0200d6e:	7788                	ld	a0,40(a5)
ffffffffc0200d70:	186030ef          	jal	ra,ffffffffc0203ef6 <do_pgfault>
ffffffffc0200d74:	c951                	beqz	a0,ffffffffc0200e08 <exception_handler+0x168>
            print_trapframe(tf);
ffffffffc0200d76:	8522                	mv	a0,s0
ffffffffc0200d78:	e2dff0ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
            if (current == NULL) {
ffffffffc0200d7c:	609c                	ld	a5,0(s1)
ffffffffc0200d7e:	e7a9                	bnez	a5,ffffffffc0200dc8 <exception_handler+0x128>
                panic("handle_exception: page fault in kernel (current == NULL)");
ffffffffc0200d80:	00005617          	auipc	a2,0x5
ffffffffc0200d84:	68060613          	addi	a2,a2,1664 # ffffffffc0206400 <commands+0x798>
ffffffffc0200d88:	0f400593          	li	a1,244
ffffffffc0200d8c:	00005517          	auipc	a0,0x5
ffffffffc0200d90:	5cc50513          	addi	a0,a0,1484 # ffffffffc0206358 <commands+0x6f0>
ffffffffc0200d94:	efaff0ef          	jal	ra,ffffffffc020048e <__panic>
        cprintf("Store/AMO page fault\n");
ffffffffc0200d98:	00005517          	auipc	a0,0x5
ffffffffc0200d9c:	6c050513          	addi	a0,a0,1728 # ffffffffc0206458 <commands+0x7f0>
ffffffffc0200da0:	bf4ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (do_pgfault(current->mm, tf->cause, tf->tval) != 0) {
ffffffffc0200da4:	000c9497          	auipc	s1,0xc9
ffffffffc0200da8:	07448493          	addi	s1,s1,116 # ffffffffc02c9e18 <current>
ffffffffc0200dac:	609c                	ld	a5,0(s1)
ffffffffc0200dae:	11043603          	ld	a2,272(s0)
ffffffffc0200db2:	11842583          	lw	a1,280(s0)
ffffffffc0200db6:	7788                	ld	a0,40(a5)
ffffffffc0200db8:	13e030ef          	jal	ra,ffffffffc0203ef6 <do_pgfault>
ffffffffc0200dbc:	c531                	beqz	a0,ffffffffc0200e08 <exception_handler+0x168>
            print_trapframe(tf);
ffffffffc0200dbe:	8522                	mv	a0,s0
ffffffffc0200dc0:	de5ff0ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
            if (current == NULL) {
ffffffffc0200dc4:	609c                	ld	a5,0(s1)
ffffffffc0200dc6:	cbdd                	beqz	a5,ffffffffc0200e7c <exception_handler+0x1dc>
}
ffffffffc0200dc8:	6442                	ld	s0,16(sp)
ffffffffc0200dca:	60e2                	ld	ra,24(sp)
ffffffffc0200dcc:	64a2                	ld	s1,8(sp)
            do_exit(-E_KILLED);
ffffffffc0200dce:	555d                	li	a0,-9
}
ffffffffc0200dd0:	6105                	addi	sp,sp,32
            do_exit(-E_KILLED);
ffffffffc0200dd2:	11b0306f          	j	ffffffffc02046ec <do_exit>
        cprintf("Instruction address misaligned\n");
ffffffffc0200dd6:	00005517          	auipc	a0,0x5
ffffffffc0200dda:	4ca50513          	addi	a0,a0,1226 # ffffffffc02062a0 <commands+0x638>
ffffffffc0200dde:	bf09                	j	ffffffffc0200cf0 <exception_handler+0x50>
        cprintf("Instruction access fault\n");
ffffffffc0200de0:	00005517          	auipc	a0,0x5
ffffffffc0200de4:	4e050513          	addi	a0,a0,1248 # ffffffffc02062c0 <commands+0x658>
ffffffffc0200de8:	b721                	j	ffffffffc0200cf0 <exception_handler+0x50>
        cprintf("Illegal instruction\n");
ffffffffc0200dea:	00005517          	auipc	a0,0x5
ffffffffc0200dee:	4f650513          	addi	a0,a0,1270 # ffffffffc02062e0 <commands+0x678>
ffffffffc0200df2:	bdfd                	j	ffffffffc0200cf0 <exception_handler+0x50>
        cprintf("Breakpoint\n");
ffffffffc0200df4:	00005517          	auipc	a0,0x5
ffffffffc0200df8:	50450513          	addi	a0,a0,1284 # ffffffffc02062f8 <commands+0x690>
ffffffffc0200dfc:	b98ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (tf->gpr.a7 == 10)
ffffffffc0200e00:	6458                	ld	a4,136(s0)
ffffffffc0200e02:	47a9                	li	a5,10
ffffffffc0200e04:	04f70863          	beq	a4,a5,ffffffffc0200e54 <exception_handler+0x1b4>
}
ffffffffc0200e08:	60e2                	ld	ra,24(sp)
ffffffffc0200e0a:	6442                	ld	s0,16(sp)
ffffffffc0200e0c:	64a2                	ld	s1,8(sp)
ffffffffc0200e0e:	6105                	addi	sp,sp,32
ffffffffc0200e10:	8082                	ret
        cprintf("Load address misaligned\n");
ffffffffc0200e12:	00005517          	auipc	a0,0x5
ffffffffc0200e16:	4f650513          	addi	a0,a0,1270 # ffffffffc0206308 <commands+0x6a0>
ffffffffc0200e1a:	bdd9                	j	ffffffffc0200cf0 <exception_handler+0x50>
        cprintf("Load access fault\n");
ffffffffc0200e1c:	00005517          	auipc	a0,0x5
ffffffffc0200e20:	50c50513          	addi	a0,a0,1292 # ffffffffc0206328 <commands+0x6c0>
ffffffffc0200e24:	b5f1                	j	ffffffffc0200cf0 <exception_handler+0x50>
        cprintf("Store/AMO access fault\n");
ffffffffc0200e26:	00005517          	auipc	a0,0x5
ffffffffc0200e2a:	54a50513          	addi	a0,a0,1354 # ffffffffc0206370 <commands+0x708>
ffffffffc0200e2e:	b5c9                	j	ffffffffc0200cf0 <exception_handler+0x50>
        print_trapframe(tf);
ffffffffc0200e30:	8522                	mv	a0,s0
}
ffffffffc0200e32:	6442                	ld	s0,16(sp)
ffffffffc0200e34:	60e2                	ld	ra,24(sp)
ffffffffc0200e36:	64a2                	ld	s1,8(sp)
ffffffffc0200e38:	6105                	addi	sp,sp,32
        print_trapframe(tf);
ffffffffc0200e3a:	b3ad                	j	ffffffffc0200ba4 <print_trapframe>
        panic("AMO address misaligned\n");
ffffffffc0200e3c:	00005617          	auipc	a2,0x5
ffffffffc0200e40:	50460613          	addi	a2,a2,1284 # ffffffffc0206340 <commands+0x6d8>
ffffffffc0200e44:	0cd00593          	li	a1,205
ffffffffc0200e48:	00005517          	auipc	a0,0x5
ffffffffc0200e4c:	51050513          	addi	a0,a0,1296 # ffffffffc0206358 <commands+0x6f0>
ffffffffc0200e50:	e3eff0ef          	jal	ra,ffffffffc020048e <__panic>
            tf->epc += 4;
ffffffffc0200e54:	10843783          	ld	a5,264(s0)
ffffffffc0200e58:	0791                	addi	a5,a5,4
ffffffffc0200e5a:	10f43423          	sd	a5,264(s0)
            syscall();
ffffffffc0200e5e:	64c040ef          	jal	ra,ffffffffc02054aa <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e62:	000c9797          	auipc	a5,0xc9
ffffffffc0200e66:	fb67b783          	ld	a5,-74(a5) # ffffffffc02c9e18 <current>
ffffffffc0200e6a:	6b9c                	ld	a5,16(a5)
ffffffffc0200e6c:	8522                	mv	a0,s0
}
ffffffffc0200e6e:	6442                	ld	s0,16(sp)
ffffffffc0200e70:	60e2                	ld	ra,24(sp)
ffffffffc0200e72:	64a2                	ld	s1,8(sp)
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e74:	6589                	lui	a1,0x2
ffffffffc0200e76:	95be                	add	a1,a1,a5
}
ffffffffc0200e78:	6105                	addi	sp,sp,32
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e7a:	aa95                	j	ffffffffc0200fee <kernel_execve_ret>
                panic("handle_exception: page fault in kernel (current == NULL)");
ffffffffc0200e7c:	00005617          	auipc	a2,0x5
ffffffffc0200e80:	58460613          	addi	a2,a2,1412 # ffffffffc0206400 <commands+0x798>
ffffffffc0200e84:	10000593          	li	a1,256
ffffffffc0200e88:	00005517          	auipc	a0,0x5
ffffffffc0200e8c:	4d050513          	addi	a0,a0,1232 # ffffffffc0206358 <commands+0x6f0>
ffffffffc0200e90:	dfeff0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0200e94 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
/* 请替换 kern/trap/trap.c 末尾的 trap 函数 */
void trap(struct trapframe *tf) {
ffffffffc0200e94:	1101                	addi	sp,sp,-32
ffffffffc0200e96:	e822                	sd	s0,16(sp)
    // 1. 如果当前没有进程（如刚启动），直接分发中断
    if (current == NULL) {
ffffffffc0200e98:	000c9417          	auipc	s0,0xc9
ffffffffc0200e9c:	f8040413          	addi	s0,s0,-128 # ffffffffc02c9e18 <current>
ffffffffc0200ea0:	6018                	ld	a4,0(s0)
void trap(struct trapframe *tf) {
ffffffffc0200ea2:	ec06                	sd	ra,24(sp)
ffffffffc0200ea4:	e426                	sd	s1,8(sp)
ffffffffc0200ea6:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200ea8:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200eac:	cf1d                	beqz	a4,ffffffffc0200eea <trap+0x56>
        current->tf = tf;

        // 【关键修复】手动检查 SSTATUS_SPP 位
        // 如果 SPP 位是 0，说明中断来自用户态 (in_kernel = false)
        // 如果 SPP 位是 1，说明中断来自内核态 (in_kernel = true)
        bool in_kernel = (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200eae:	10053483          	ld	s1,256(a0)
        struct trapframe *otf = current->tf;
ffffffffc0200eb2:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200eb6:	f348                	sd	a0,160(a4)
        bool in_kernel = (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200eb8:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0)
ffffffffc0200ebc:	0206c463          	bltz	a3,ffffffffc0200ee4 <trap+0x50>
        exception_handler(tf);
ffffffffc0200ec0:	de1ff0ef          	jal	ra,ffffffffc0200ca0 <exception_handler>

        trap_dispatch(tf);

        // 3. 恢复旧的中断帧
        current->tf = otf;
ffffffffc0200ec4:	601c                	ld	a5,0(s0)
ffffffffc0200ec6:	0b27b023          	sd	s2,160(a5)

        // 4. 只有在用户态产生的中断，且需要调度时，才执行调度
        if (!in_kernel) {
ffffffffc0200eca:	e499                	bnez	s1,ffffffffc0200ed8 <trap+0x44>
            // 处理进程退出的标记
            if (current->flags & PF_EXITING) {
ffffffffc0200ecc:	0b07a703          	lw	a4,176(a5)
ffffffffc0200ed0:	8b05                	andi	a4,a4,1
ffffffffc0200ed2:	e329                	bnez	a4,ffffffffc0200f14 <trap+0x80>
                do_exit(-E_KILLED);
            }
            // 【核心】时间片用完，执行抢占调度
            if (current->need_resched) {
ffffffffc0200ed4:	6f9c                	ld	a5,24(a5)
ffffffffc0200ed6:	eb85                	bnez	a5,ffffffffc0200f06 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200ed8:	60e2                	ld	ra,24(sp)
ffffffffc0200eda:	6442                	ld	s0,16(sp)
ffffffffc0200edc:	64a2                	ld	s1,8(sp)
ffffffffc0200ede:	6902                	ld	s2,0(sp)
ffffffffc0200ee0:	6105                	addi	sp,sp,32
ffffffffc0200ee2:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200ee4:	d23ff0ef          	jal	ra,ffffffffc0200c06 <interrupt_handler>
ffffffffc0200ee8:	bff1                	j	ffffffffc0200ec4 <trap+0x30>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200eea:	0006c863          	bltz	a3,ffffffffc0200efa <trap+0x66>
}
ffffffffc0200eee:	6442                	ld	s0,16(sp)
ffffffffc0200ef0:	60e2                	ld	ra,24(sp)
ffffffffc0200ef2:	64a2                	ld	s1,8(sp)
ffffffffc0200ef4:	6902                	ld	s2,0(sp)
ffffffffc0200ef6:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200ef8:	b365                	j	ffffffffc0200ca0 <exception_handler>
}
ffffffffc0200efa:	6442                	ld	s0,16(sp)
ffffffffc0200efc:	60e2                	ld	ra,24(sp)
ffffffffc0200efe:	64a2                	ld	s1,8(sp)
ffffffffc0200f00:	6902                	ld	s2,0(sp)
ffffffffc0200f02:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200f04:	b309                	j	ffffffffc0200c06 <interrupt_handler>
}
ffffffffc0200f06:	6442                	ld	s0,16(sp)
ffffffffc0200f08:	60e2                	ld	ra,24(sp)
ffffffffc0200f0a:	64a2                	ld	s1,8(sp)
ffffffffc0200f0c:	6902                	ld	s2,0(sp)
ffffffffc0200f0e:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200f10:	4960406f          	j	ffffffffc02053a6 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200f14:	555d                	li	a0,-9
ffffffffc0200f16:	7d6030ef          	jal	ra,ffffffffc02046ec <do_exit>
            if (current->need_resched) {
ffffffffc0200f1a:	601c                	ld	a5,0(s0)
ffffffffc0200f1c:	bf65                	j	ffffffffc0200ed4 <trap+0x40>
	...

ffffffffc0200f20 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200f20:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200f24:	00011463          	bnez	sp,ffffffffc0200f2c <__alltraps+0xc>
ffffffffc0200f28:	14002173          	csrr	sp,sscratch
ffffffffc0200f2c:	712d                	addi	sp,sp,-288
ffffffffc0200f2e:	e002                	sd	zero,0(sp)
ffffffffc0200f30:	e406                	sd	ra,8(sp)
ffffffffc0200f32:	ec0e                	sd	gp,24(sp)
ffffffffc0200f34:	f012                	sd	tp,32(sp)
ffffffffc0200f36:	f416                	sd	t0,40(sp)
ffffffffc0200f38:	f81a                	sd	t1,48(sp)
ffffffffc0200f3a:	fc1e                	sd	t2,56(sp)
ffffffffc0200f3c:	e0a2                	sd	s0,64(sp)
ffffffffc0200f3e:	e4a6                	sd	s1,72(sp)
ffffffffc0200f40:	e8aa                	sd	a0,80(sp)
ffffffffc0200f42:	ecae                	sd	a1,88(sp)
ffffffffc0200f44:	f0b2                	sd	a2,96(sp)
ffffffffc0200f46:	f4b6                	sd	a3,104(sp)
ffffffffc0200f48:	f8ba                	sd	a4,112(sp)
ffffffffc0200f4a:	fcbe                	sd	a5,120(sp)
ffffffffc0200f4c:	e142                	sd	a6,128(sp)
ffffffffc0200f4e:	e546                	sd	a7,136(sp)
ffffffffc0200f50:	e94a                	sd	s2,144(sp)
ffffffffc0200f52:	ed4e                	sd	s3,152(sp)
ffffffffc0200f54:	f152                	sd	s4,160(sp)
ffffffffc0200f56:	f556                	sd	s5,168(sp)
ffffffffc0200f58:	f95a                	sd	s6,176(sp)
ffffffffc0200f5a:	fd5e                	sd	s7,184(sp)
ffffffffc0200f5c:	e1e2                	sd	s8,192(sp)
ffffffffc0200f5e:	e5e6                	sd	s9,200(sp)
ffffffffc0200f60:	e9ea                	sd	s10,208(sp)
ffffffffc0200f62:	edee                	sd	s11,216(sp)
ffffffffc0200f64:	f1f2                	sd	t3,224(sp)
ffffffffc0200f66:	f5f6                	sd	t4,232(sp)
ffffffffc0200f68:	f9fa                	sd	t5,240(sp)
ffffffffc0200f6a:	fdfe                	sd	t6,248(sp)
ffffffffc0200f6c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200f70:	100024f3          	csrr	s1,sstatus
ffffffffc0200f74:	14102973          	csrr	s2,sepc
ffffffffc0200f78:	143029f3          	csrr	s3,stval
ffffffffc0200f7c:	14202a73          	csrr	s4,scause
ffffffffc0200f80:	e822                	sd	s0,16(sp)
ffffffffc0200f82:	e226                	sd	s1,256(sp)
ffffffffc0200f84:	e64a                	sd	s2,264(sp)
ffffffffc0200f86:	ea4e                	sd	s3,272(sp)
ffffffffc0200f88:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200f8a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200f8c:	f09ff0ef          	jal	ra,ffffffffc0200e94 <trap>

ffffffffc0200f90 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200f90:	6492                	ld	s1,256(sp)
ffffffffc0200f92:	6932                	ld	s2,264(sp)
ffffffffc0200f94:	1004f413          	andi	s0,s1,256
ffffffffc0200f98:	e401                	bnez	s0,ffffffffc0200fa0 <__trapret+0x10>
ffffffffc0200f9a:	1200                	addi	s0,sp,288
ffffffffc0200f9c:	14041073          	csrw	sscratch,s0
ffffffffc0200fa0:	10049073          	csrw	sstatus,s1
ffffffffc0200fa4:	14191073          	csrw	sepc,s2
ffffffffc0200fa8:	60a2                	ld	ra,8(sp)
ffffffffc0200faa:	61e2                	ld	gp,24(sp)
ffffffffc0200fac:	7202                	ld	tp,32(sp)
ffffffffc0200fae:	72a2                	ld	t0,40(sp)
ffffffffc0200fb0:	7342                	ld	t1,48(sp)
ffffffffc0200fb2:	73e2                	ld	t2,56(sp)
ffffffffc0200fb4:	6406                	ld	s0,64(sp)
ffffffffc0200fb6:	64a6                	ld	s1,72(sp)
ffffffffc0200fb8:	6546                	ld	a0,80(sp)
ffffffffc0200fba:	65e6                	ld	a1,88(sp)
ffffffffc0200fbc:	7606                	ld	a2,96(sp)
ffffffffc0200fbe:	76a6                	ld	a3,104(sp)
ffffffffc0200fc0:	7746                	ld	a4,112(sp)
ffffffffc0200fc2:	77e6                	ld	a5,120(sp)
ffffffffc0200fc4:	680a                	ld	a6,128(sp)
ffffffffc0200fc6:	68aa                	ld	a7,136(sp)
ffffffffc0200fc8:	694a                	ld	s2,144(sp)
ffffffffc0200fca:	69ea                	ld	s3,152(sp)
ffffffffc0200fcc:	7a0a                	ld	s4,160(sp)
ffffffffc0200fce:	7aaa                	ld	s5,168(sp)
ffffffffc0200fd0:	7b4a                	ld	s6,176(sp)
ffffffffc0200fd2:	7bea                	ld	s7,184(sp)
ffffffffc0200fd4:	6c0e                	ld	s8,192(sp)
ffffffffc0200fd6:	6cae                	ld	s9,200(sp)
ffffffffc0200fd8:	6d4e                	ld	s10,208(sp)
ffffffffc0200fda:	6dee                	ld	s11,216(sp)
ffffffffc0200fdc:	7e0e                	ld	t3,224(sp)
ffffffffc0200fde:	7eae                	ld	t4,232(sp)
ffffffffc0200fe0:	7f4e                	ld	t5,240(sp)
ffffffffc0200fe2:	7fee                	ld	t6,248(sp)
ffffffffc0200fe4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200fe6:	10200073          	sret

ffffffffc0200fea <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200fea:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200fec:	b755                	j	ffffffffc0200f90 <__trapret>

ffffffffc0200fee <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200fee:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7d70>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200ff2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200ff6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200ffa:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200ffe:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0201002:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0201006:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc020100a:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc020100e:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0201012:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0201014:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0201016:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0201018:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc020101a:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc020101c:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc020101e:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0201020:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0201022:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0201024:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0201026:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0201028:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc020102a:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc020102c:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc020102e:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0201030:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0201032:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0201034:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0201036:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0201038:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc020103a:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc020103c:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc020103e:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0201040:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0201042:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0201044:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0201046:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0201048:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc020104a:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc020104c:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc020104e:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0201050:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0201052:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0201054:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0201056:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0201058:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc020105a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc020105c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc020105e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0201060:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0201062:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0201064:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0201066:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0201068:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc020106a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc020106c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc020106e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0201070:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0201072:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0201074:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0201076:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0201078:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc020107a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc020107c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc020107e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0201080:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0201082:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0201084:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0201086:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0201088:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc020108a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc020108c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc020108e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0201090:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0201092:	812e                	mv	sp,a1
ffffffffc0201094:	bdf5                	j	ffffffffc0200f90 <__trapret>

ffffffffc0201096 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201096:	000c5797          	auipc	a5,0xc5
ffffffffc020109a:	cf278793          	addi	a5,a5,-782 # ffffffffc02c5d88 <free_area>
ffffffffc020109e:	e79c                	sd	a5,8(a5)
ffffffffc02010a0:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc02010a2:	0007a823          	sw	zero,16(a5)
}
ffffffffc02010a6:	8082                	ret

ffffffffc02010a8 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc02010a8:	000c5517          	auipc	a0,0xc5
ffffffffc02010ac:	cf056503          	lwu	a0,-784(a0) # ffffffffc02c5d98 <free_area+0x10>
ffffffffc02010b0:	8082                	ret

ffffffffc02010b2 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc02010b2:	715d                	addi	sp,sp,-80
ffffffffc02010b4:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02010b6:	000c5417          	auipc	s0,0xc5
ffffffffc02010ba:	cd240413          	addi	s0,s0,-814 # ffffffffc02c5d88 <free_area>
ffffffffc02010be:	641c                	ld	a5,8(s0)
ffffffffc02010c0:	e486                	sd	ra,72(sp)
ffffffffc02010c2:	fc26                	sd	s1,56(sp)
ffffffffc02010c4:	f84a                	sd	s2,48(sp)
ffffffffc02010c6:	f44e                	sd	s3,40(sp)
ffffffffc02010c8:	f052                	sd	s4,32(sp)
ffffffffc02010ca:	ec56                	sd	s5,24(sp)
ffffffffc02010cc:	e85a                	sd	s6,16(sp)
ffffffffc02010ce:	e45e                	sd	s7,8(sp)
ffffffffc02010d0:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc02010d2:	2a878d63          	beq	a5,s0,ffffffffc020138c <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc02010d6:	4481                	li	s1,0
ffffffffc02010d8:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02010da:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02010de:	8b09                	andi	a4,a4,2
ffffffffc02010e0:	2a070a63          	beqz	a4,ffffffffc0201394 <default_check+0x2e2>
        count++, total += p->property;
ffffffffc02010e4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010e8:	679c                	ld	a5,8(a5)
ffffffffc02010ea:	2905                	addiw	s2,s2,1
ffffffffc02010ec:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc02010ee:	fe8796e3          	bne	a5,s0,ffffffffc02010da <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02010f2:	89a6                	mv	s3,s1
ffffffffc02010f4:	6df000ef          	jal	ra,ffffffffc0201fd2 <nr_free_pages>
ffffffffc02010f8:	6f351e63          	bne	a0,s3,ffffffffc02017f4 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02010fc:	4505                	li	a0,1
ffffffffc02010fe:	657000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc0201102:	8aaa                	mv	s5,a0
ffffffffc0201104:	42050863          	beqz	a0,ffffffffc0201534 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201108:	4505                	li	a0,1
ffffffffc020110a:	64b000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc020110e:	89aa                	mv	s3,a0
ffffffffc0201110:	70050263          	beqz	a0,ffffffffc0201814 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201114:	4505                	li	a0,1
ffffffffc0201116:	63f000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc020111a:	8a2a                	mv	s4,a0
ffffffffc020111c:	48050c63          	beqz	a0,ffffffffc02015b4 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201120:	293a8a63          	beq	s5,s3,ffffffffc02013b4 <default_check+0x302>
ffffffffc0201124:	28aa8863          	beq	s5,a0,ffffffffc02013b4 <default_check+0x302>
ffffffffc0201128:	28a98663          	beq	s3,a0,ffffffffc02013b4 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020112c:	000aa783          	lw	a5,0(s5)
ffffffffc0201130:	2a079263          	bnez	a5,ffffffffc02013d4 <default_check+0x322>
ffffffffc0201134:	0009a783          	lw	a5,0(s3)
ffffffffc0201138:	28079e63          	bnez	a5,ffffffffc02013d4 <default_check+0x322>
ffffffffc020113c:	411c                	lw	a5,0(a0)
ffffffffc020113e:	28079b63          	bnez	a5,ffffffffc02013d4 <default_check+0x322>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc0201142:	000c9797          	auipc	a5,0xc9
ffffffffc0201146:	cb67b783          	ld	a5,-842(a5) # ffffffffc02c9df8 <pages>
ffffffffc020114a:	40fa8733          	sub	a4,s5,a5
ffffffffc020114e:	00007617          	auipc	a2,0x7
ffffffffc0201152:	a5263603          	ld	a2,-1454(a2) # ffffffffc0207ba0 <nbase>
ffffffffc0201156:	8719                	srai	a4,a4,0x6
ffffffffc0201158:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020115a:	000c9697          	auipc	a3,0xc9
ffffffffc020115e:	c966b683          	ld	a3,-874(a3) # ffffffffc02c9df0 <npage>
ffffffffc0201162:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc0201164:	0732                	slli	a4,a4,0xc
ffffffffc0201166:	28d77763          	bgeu	a4,a3,ffffffffc02013f4 <default_check+0x342>
    return page - pages + nbase;
ffffffffc020116a:	40f98733          	sub	a4,s3,a5
ffffffffc020116e:	8719                	srai	a4,a4,0x6
ffffffffc0201170:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201172:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201174:	4cd77063          	bgeu	a4,a3,ffffffffc0201634 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0201178:	40f507b3          	sub	a5,a0,a5
ffffffffc020117c:	8799                	srai	a5,a5,0x6
ffffffffc020117e:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201180:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201182:	30d7f963          	bgeu	a5,a3,ffffffffc0201494 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0201186:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201188:	00043c03          	ld	s8,0(s0)
ffffffffc020118c:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201190:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201194:	e400                	sd	s0,8(s0)
ffffffffc0201196:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201198:	000c5797          	auipc	a5,0xc5
ffffffffc020119c:	c007a023          	sw	zero,-1024(a5) # ffffffffc02c5d98 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02011a0:	5b5000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc02011a4:	2c051863          	bnez	a0,ffffffffc0201474 <default_check+0x3c2>
    free_page(p0);
ffffffffc02011a8:	4585                	li	a1,1
ffffffffc02011aa:	8556                	mv	a0,s5
ffffffffc02011ac:	5e7000ef          	jal	ra,ffffffffc0201f92 <free_pages>
    free_page(p1);
ffffffffc02011b0:	4585                	li	a1,1
ffffffffc02011b2:	854e                	mv	a0,s3
ffffffffc02011b4:	5df000ef          	jal	ra,ffffffffc0201f92 <free_pages>
    free_page(p2);
ffffffffc02011b8:	4585                	li	a1,1
ffffffffc02011ba:	8552                	mv	a0,s4
ffffffffc02011bc:	5d7000ef          	jal	ra,ffffffffc0201f92 <free_pages>
    assert(nr_free == 3);
ffffffffc02011c0:	4818                	lw	a4,16(s0)
ffffffffc02011c2:	478d                	li	a5,3
ffffffffc02011c4:	28f71863          	bne	a4,a5,ffffffffc0201454 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02011c8:	4505                	li	a0,1
ffffffffc02011ca:	58b000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc02011ce:	89aa                	mv	s3,a0
ffffffffc02011d0:	26050263          	beqz	a0,ffffffffc0201434 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02011d4:	4505                	li	a0,1
ffffffffc02011d6:	57f000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc02011da:	8aaa                	mv	s5,a0
ffffffffc02011dc:	3a050c63          	beqz	a0,ffffffffc0201594 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02011e0:	4505                	li	a0,1
ffffffffc02011e2:	573000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc02011e6:	8a2a                	mv	s4,a0
ffffffffc02011e8:	38050663          	beqz	a0,ffffffffc0201574 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc02011ec:	4505                	li	a0,1
ffffffffc02011ee:	567000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc02011f2:	36051163          	bnez	a0,ffffffffc0201554 <default_check+0x4a2>
    free_page(p0);
ffffffffc02011f6:	4585                	li	a1,1
ffffffffc02011f8:	854e                	mv	a0,s3
ffffffffc02011fa:	599000ef          	jal	ra,ffffffffc0201f92 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02011fe:	641c                	ld	a5,8(s0)
ffffffffc0201200:	20878a63          	beq	a5,s0,ffffffffc0201414 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0201204:	4505                	li	a0,1
ffffffffc0201206:	54f000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc020120a:	30a99563          	bne	s3,a0,ffffffffc0201514 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc020120e:	4505                	li	a0,1
ffffffffc0201210:	545000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc0201214:	2e051063          	bnez	a0,ffffffffc02014f4 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0201218:	481c                	lw	a5,16(s0)
ffffffffc020121a:	2a079d63          	bnez	a5,ffffffffc02014d4 <default_check+0x422>
    free_page(p);
ffffffffc020121e:	854e                	mv	a0,s3
ffffffffc0201220:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201222:	01843023          	sd	s8,0(s0)
ffffffffc0201226:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc020122a:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc020122e:	565000ef          	jal	ra,ffffffffc0201f92 <free_pages>
    free_page(p1);
ffffffffc0201232:	4585                	li	a1,1
ffffffffc0201234:	8556                	mv	a0,s5
ffffffffc0201236:	55d000ef          	jal	ra,ffffffffc0201f92 <free_pages>
    free_page(p2);
ffffffffc020123a:	4585                	li	a1,1
ffffffffc020123c:	8552                	mv	a0,s4
ffffffffc020123e:	555000ef          	jal	ra,ffffffffc0201f92 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201242:	4515                	li	a0,5
ffffffffc0201244:	511000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc0201248:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020124a:	26050563          	beqz	a0,ffffffffc02014b4 <default_check+0x402>
ffffffffc020124e:	651c                	ld	a5,8(a0)
ffffffffc0201250:	8385                	srli	a5,a5,0x1
ffffffffc0201252:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201254:	54079063          	bnez	a5,ffffffffc0201794 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201258:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020125a:	00043b03          	ld	s6,0(s0)
ffffffffc020125e:	00843a83          	ld	s5,8(s0)
ffffffffc0201262:	e000                	sd	s0,0(s0)
ffffffffc0201264:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0201266:	4ef000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc020126a:	50051563          	bnez	a0,ffffffffc0201774 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020126e:	08098a13          	addi	s4,s3,128
ffffffffc0201272:	8552                	mv	a0,s4
ffffffffc0201274:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201276:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc020127a:	000c5797          	auipc	a5,0xc5
ffffffffc020127e:	b007af23          	sw	zero,-1250(a5) # ffffffffc02c5d98 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201282:	511000ef          	jal	ra,ffffffffc0201f92 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201286:	4511                	li	a0,4
ffffffffc0201288:	4cd000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc020128c:	4c051463          	bnez	a0,ffffffffc0201754 <default_check+0x6a2>
ffffffffc0201290:	0889b783          	ld	a5,136(s3)
ffffffffc0201294:	8385                	srli	a5,a5,0x1
ffffffffc0201296:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201298:	48078e63          	beqz	a5,ffffffffc0201734 <default_check+0x682>
ffffffffc020129c:	0909a703          	lw	a4,144(s3)
ffffffffc02012a0:	478d                	li	a5,3
ffffffffc02012a2:	48f71963          	bne	a4,a5,ffffffffc0201734 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02012a6:	450d                	li	a0,3
ffffffffc02012a8:	4ad000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc02012ac:	8c2a                	mv	s8,a0
ffffffffc02012ae:	46050363          	beqz	a0,ffffffffc0201714 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc02012b2:	4505                	li	a0,1
ffffffffc02012b4:	4a1000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc02012b8:	42051e63          	bnez	a0,ffffffffc02016f4 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc02012bc:	418a1c63          	bne	s4,s8,ffffffffc02016d4 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02012c0:	4585                	li	a1,1
ffffffffc02012c2:	854e                	mv	a0,s3
ffffffffc02012c4:	4cf000ef          	jal	ra,ffffffffc0201f92 <free_pages>
    free_pages(p1, 3);
ffffffffc02012c8:	458d                	li	a1,3
ffffffffc02012ca:	8552                	mv	a0,s4
ffffffffc02012cc:	4c7000ef          	jal	ra,ffffffffc0201f92 <free_pages>
ffffffffc02012d0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02012d4:	04098c13          	addi	s8,s3,64
ffffffffc02012d8:	8385                	srli	a5,a5,0x1
ffffffffc02012da:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02012dc:	3c078c63          	beqz	a5,ffffffffc02016b4 <default_check+0x602>
ffffffffc02012e0:	0109a703          	lw	a4,16(s3)
ffffffffc02012e4:	4785                	li	a5,1
ffffffffc02012e6:	3cf71763          	bne	a4,a5,ffffffffc02016b4 <default_check+0x602>
ffffffffc02012ea:	008a3783          	ld	a5,8(s4)
ffffffffc02012ee:	8385                	srli	a5,a5,0x1
ffffffffc02012f0:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02012f2:	3a078163          	beqz	a5,ffffffffc0201694 <default_check+0x5e2>
ffffffffc02012f6:	010a2703          	lw	a4,16(s4)
ffffffffc02012fa:	478d                	li	a5,3
ffffffffc02012fc:	38f71c63          	bne	a4,a5,ffffffffc0201694 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201300:	4505                	li	a0,1
ffffffffc0201302:	453000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc0201306:	36a99763          	bne	s3,a0,ffffffffc0201674 <default_check+0x5c2>
    free_page(p0);
ffffffffc020130a:	4585                	li	a1,1
ffffffffc020130c:	487000ef          	jal	ra,ffffffffc0201f92 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201310:	4509                	li	a0,2
ffffffffc0201312:	443000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc0201316:	32aa1f63          	bne	s4,a0,ffffffffc0201654 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc020131a:	4589                	li	a1,2
ffffffffc020131c:	477000ef          	jal	ra,ffffffffc0201f92 <free_pages>
    free_page(p2);
ffffffffc0201320:	4585                	li	a1,1
ffffffffc0201322:	8562                	mv	a0,s8
ffffffffc0201324:	46f000ef          	jal	ra,ffffffffc0201f92 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201328:	4515                	li	a0,5
ffffffffc020132a:	42b000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc020132e:	89aa                	mv	s3,a0
ffffffffc0201330:	48050263          	beqz	a0,ffffffffc02017b4 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0201334:	4505                	li	a0,1
ffffffffc0201336:	41f000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc020133a:	2c051d63          	bnez	a0,ffffffffc0201614 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc020133e:	481c                	lw	a5,16(s0)
ffffffffc0201340:	2a079a63          	bnez	a5,ffffffffc02015f4 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201344:	4595                	li	a1,5
ffffffffc0201346:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201348:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc020134c:	01643023          	sd	s6,0(s0)
ffffffffc0201350:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0201354:	43f000ef          	jal	ra,ffffffffc0201f92 <free_pages>
    return listelm->next;
ffffffffc0201358:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc020135a:	00878963          	beq	a5,s0,ffffffffc020136c <default_check+0x2ba>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc020135e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201362:	679c                	ld	a5,8(a5)
ffffffffc0201364:	397d                	addiw	s2,s2,-1
ffffffffc0201366:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201368:	fe879be3          	bne	a5,s0,ffffffffc020135e <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc020136c:	26091463          	bnez	s2,ffffffffc02015d4 <default_check+0x522>
    assert(total == 0);
ffffffffc0201370:	46049263          	bnez	s1,ffffffffc02017d4 <default_check+0x722>
}
ffffffffc0201374:	60a6                	ld	ra,72(sp)
ffffffffc0201376:	6406                	ld	s0,64(sp)
ffffffffc0201378:	74e2                	ld	s1,56(sp)
ffffffffc020137a:	7942                	ld	s2,48(sp)
ffffffffc020137c:	79a2                	ld	s3,40(sp)
ffffffffc020137e:	7a02                	ld	s4,32(sp)
ffffffffc0201380:	6ae2                	ld	s5,24(sp)
ffffffffc0201382:	6b42                	ld	s6,16(sp)
ffffffffc0201384:	6ba2                	ld	s7,8(sp)
ffffffffc0201386:	6c02                	ld	s8,0(sp)
ffffffffc0201388:	6161                	addi	sp,sp,80
ffffffffc020138a:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc020138c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020138e:	4481                	li	s1,0
ffffffffc0201390:	4901                	li	s2,0
ffffffffc0201392:	b38d                	j	ffffffffc02010f4 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201394:	00005697          	auipc	a3,0x5
ffffffffc0201398:	11c68693          	addi	a3,a3,284 # ffffffffc02064b0 <commands+0x848>
ffffffffc020139c:	00005617          	auipc	a2,0x5
ffffffffc02013a0:	12460613          	addi	a2,a2,292 # ffffffffc02064c0 <commands+0x858>
ffffffffc02013a4:	11000593          	li	a1,272
ffffffffc02013a8:	00005517          	auipc	a0,0x5
ffffffffc02013ac:	13050513          	addi	a0,a0,304 # ffffffffc02064d8 <commands+0x870>
ffffffffc02013b0:	8deff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02013b4:	00005697          	auipc	a3,0x5
ffffffffc02013b8:	1bc68693          	addi	a3,a3,444 # ffffffffc0206570 <commands+0x908>
ffffffffc02013bc:	00005617          	auipc	a2,0x5
ffffffffc02013c0:	10460613          	addi	a2,a2,260 # ffffffffc02064c0 <commands+0x858>
ffffffffc02013c4:	0db00593          	li	a1,219
ffffffffc02013c8:	00005517          	auipc	a0,0x5
ffffffffc02013cc:	11050513          	addi	a0,a0,272 # ffffffffc02064d8 <commands+0x870>
ffffffffc02013d0:	8beff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02013d4:	00005697          	auipc	a3,0x5
ffffffffc02013d8:	1c468693          	addi	a3,a3,452 # ffffffffc0206598 <commands+0x930>
ffffffffc02013dc:	00005617          	auipc	a2,0x5
ffffffffc02013e0:	0e460613          	addi	a2,a2,228 # ffffffffc02064c0 <commands+0x858>
ffffffffc02013e4:	0dc00593          	li	a1,220
ffffffffc02013e8:	00005517          	auipc	a0,0x5
ffffffffc02013ec:	0f050513          	addi	a0,a0,240 # ffffffffc02064d8 <commands+0x870>
ffffffffc02013f0:	89eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02013f4:	00005697          	auipc	a3,0x5
ffffffffc02013f8:	1e468693          	addi	a3,a3,484 # ffffffffc02065d8 <commands+0x970>
ffffffffc02013fc:	00005617          	auipc	a2,0x5
ffffffffc0201400:	0c460613          	addi	a2,a2,196 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201404:	0de00593          	li	a1,222
ffffffffc0201408:	00005517          	auipc	a0,0x5
ffffffffc020140c:	0d050513          	addi	a0,a0,208 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201410:	87eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201414:	00005697          	auipc	a3,0x5
ffffffffc0201418:	24c68693          	addi	a3,a3,588 # ffffffffc0206660 <commands+0x9f8>
ffffffffc020141c:	00005617          	auipc	a2,0x5
ffffffffc0201420:	0a460613          	addi	a2,a2,164 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201424:	0f700593          	li	a1,247
ffffffffc0201428:	00005517          	auipc	a0,0x5
ffffffffc020142c:	0b050513          	addi	a0,a0,176 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201430:	85eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201434:	00005697          	auipc	a3,0x5
ffffffffc0201438:	0dc68693          	addi	a3,a3,220 # ffffffffc0206510 <commands+0x8a8>
ffffffffc020143c:	00005617          	auipc	a2,0x5
ffffffffc0201440:	08460613          	addi	a2,a2,132 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201444:	0f000593          	li	a1,240
ffffffffc0201448:	00005517          	auipc	a0,0x5
ffffffffc020144c:	09050513          	addi	a0,a0,144 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201450:	83eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 3);
ffffffffc0201454:	00005697          	auipc	a3,0x5
ffffffffc0201458:	1fc68693          	addi	a3,a3,508 # ffffffffc0206650 <commands+0x9e8>
ffffffffc020145c:	00005617          	auipc	a2,0x5
ffffffffc0201460:	06460613          	addi	a2,a2,100 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201464:	0ee00593          	li	a1,238
ffffffffc0201468:	00005517          	auipc	a0,0x5
ffffffffc020146c:	07050513          	addi	a0,a0,112 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201470:	81eff0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201474:	00005697          	auipc	a3,0x5
ffffffffc0201478:	1c468693          	addi	a3,a3,452 # ffffffffc0206638 <commands+0x9d0>
ffffffffc020147c:	00005617          	auipc	a2,0x5
ffffffffc0201480:	04460613          	addi	a2,a2,68 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201484:	0e900593          	li	a1,233
ffffffffc0201488:	00005517          	auipc	a0,0x5
ffffffffc020148c:	05050513          	addi	a0,a0,80 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201490:	ffffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201494:	00005697          	auipc	a3,0x5
ffffffffc0201498:	18468693          	addi	a3,a3,388 # ffffffffc0206618 <commands+0x9b0>
ffffffffc020149c:	00005617          	auipc	a2,0x5
ffffffffc02014a0:	02460613          	addi	a2,a2,36 # ffffffffc02064c0 <commands+0x858>
ffffffffc02014a4:	0e000593          	li	a1,224
ffffffffc02014a8:	00005517          	auipc	a0,0x5
ffffffffc02014ac:	03050513          	addi	a0,a0,48 # ffffffffc02064d8 <commands+0x870>
ffffffffc02014b0:	fdffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 != NULL);
ffffffffc02014b4:	00005697          	auipc	a3,0x5
ffffffffc02014b8:	1f468693          	addi	a3,a3,500 # ffffffffc02066a8 <commands+0xa40>
ffffffffc02014bc:	00005617          	auipc	a2,0x5
ffffffffc02014c0:	00460613          	addi	a2,a2,4 # ffffffffc02064c0 <commands+0x858>
ffffffffc02014c4:	11800593          	li	a1,280
ffffffffc02014c8:	00005517          	auipc	a0,0x5
ffffffffc02014cc:	01050513          	addi	a0,a0,16 # ffffffffc02064d8 <commands+0x870>
ffffffffc02014d0:	fbffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 0);
ffffffffc02014d4:	00005697          	auipc	a3,0x5
ffffffffc02014d8:	1c468693          	addi	a3,a3,452 # ffffffffc0206698 <commands+0xa30>
ffffffffc02014dc:	00005617          	auipc	a2,0x5
ffffffffc02014e0:	fe460613          	addi	a2,a2,-28 # ffffffffc02064c0 <commands+0x858>
ffffffffc02014e4:	0fd00593          	li	a1,253
ffffffffc02014e8:	00005517          	auipc	a0,0x5
ffffffffc02014ec:	ff050513          	addi	a0,a0,-16 # ffffffffc02064d8 <commands+0x870>
ffffffffc02014f0:	f9ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014f4:	00005697          	auipc	a3,0x5
ffffffffc02014f8:	14468693          	addi	a3,a3,324 # ffffffffc0206638 <commands+0x9d0>
ffffffffc02014fc:	00005617          	auipc	a2,0x5
ffffffffc0201500:	fc460613          	addi	a2,a2,-60 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201504:	0fb00593          	li	a1,251
ffffffffc0201508:	00005517          	auipc	a0,0x5
ffffffffc020150c:	fd050513          	addi	a0,a0,-48 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201510:	f7ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201514:	00005697          	auipc	a3,0x5
ffffffffc0201518:	16468693          	addi	a3,a3,356 # ffffffffc0206678 <commands+0xa10>
ffffffffc020151c:	00005617          	auipc	a2,0x5
ffffffffc0201520:	fa460613          	addi	a2,a2,-92 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201524:	0fa00593          	li	a1,250
ffffffffc0201528:	00005517          	auipc	a0,0x5
ffffffffc020152c:	fb050513          	addi	a0,a0,-80 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201530:	f5ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201534:	00005697          	auipc	a3,0x5
ffffffffc0201538:	fdc68693          	addi	a3,a3,-36 # ffffffffc0206510 <commands+0x8a8>
ffffffffc020153c:	00005617          	auipc	a2,0x5
ffffffffc0201540:	f8460613          	addi	a2,a2,-124 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201544:	0d700593          	li	a1,215
ffffffffc0201548:	00005517          	auipc	a0,0x5
ffffffffc020154c:	f9050513          	addi	a0,a0,-112 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201550:	f3ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201554:	00005697          	auipc	a3,0x5
ffffffffc0201558:	0e468693          	addi	a3,a3,228 # ffffffffc0206638 <commands+0x9d0>
ffffffffc020155c:	00005617          	auipc	a2,0x5
ffffffffc0201560:	f6460613          	addi	a2,a2,-156 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201564:	0f400593          	li	a1,244
ffffffffc0201568:	00005517          	auipc	a0,0x5
ffffffffc020156c:	f7050513          	addi	a0,a0,-144 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201570:	f1ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201574:	00005697          	auipc	a3,0x5
ffffffffc0201578:	fdc68693          	addi	a3,a3,-36 # ffffffffc0206550 <commands+0x8e8>
ffffffffc020157c:	00005617          	auipc	a2,0x5
ffffffffc0201580:	f4460613          	addi	a2,a2,-188 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201584:	0f200593          	li	a1,242
ffffffffc0201588:	00005517          	auipc	a0,0x5
ffffffffc020158c:	f5050513          	addi	a0,a0,-176 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201590:	efffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201594:	00005697          	auipc	a3,0x5
ffffffffc0201598:	f9c68693          	addi	a3,a3,-100 # ffffffffc0206530 <commands+0x8c8>
ffffffffc020159c:	00005617          	auipc	a2,0x5
ffffffffc02015a0:	f2460613          	addi	a2,a2,-220 # ffffffffc02064c0 <commands+0x858>
ffffffffc02015a4:	0f100593          	li	a1,241
ffffffffc02015a8:	00005517          	auipc	a0,0x5
ffffffffc02015ac:	f3050513          	addi	a0,a0,-208 # ffffffffc02064d8 <commands+0x870>
ffffffffc02015b0:	edffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02015b4:	00005697          	auipc	a3,0x5
ffffffffc02015b8:	f9c68693          	addi	a3,a3,-100 # ffffffffc0206550 <commands+0x8e8>
ffffffffc02015bc:	00005617          	auipc	a2,0x5
ffffffffc02015c0:	f0460613          	addi	a2,a2,-252 # ffffffffc02064c0 <commands+0x858>
ffffffffc02015c4:	0d900593          	li	a1,217
ffffffffc02015c8:	00005517          	auipc	a0,0x5
ffffffffc02015cc:	f1050513          	addi	a0,a0,-240 # ffffffffc02064d8 <commands+0x870>
ffffffffc02015d0:	ebffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(count == 0);
ffffffffc02015d4:	00005697          	auipc	a3,0x5
ffffffffc02015d8:	22468693          	addi	a3,a3,548 # ffffffffc02067f8 <commands+0xb90>
ffffffffc02015dc:	00005617          	auipc	a2,0x5
ffffffffc02015e0:	ee460613          	addi	a2,a2,-284 # ffffffffc02064c0 <commands+0x858>
ffffffffc02015e4:	14600593          	li	a1,326
ffffffffc02015e8:	00005517          	auipc	a0,0x5
ffffffffc02015ec:	ef050513          	addi	a0,a0,-272 # ffffffffc02064d8 <commands+0x870>
ffffffffc02015f0:	e9ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free == 0);
ffffffffc02015f4:	00005697          	auipc	a3,0x5
ffffffffc02015f8:	0a468693          	addi	a3,a3,164 # ffffffffc0206698 <commands+0xa30>
ffffffffc02015fc:	00005617          	auipc	a2,0x5
ffffffffc0201600:	ec460613          	addi	a2,a2,-316 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201604:	13a00593          	li	a1,314
ffffffffc0201608:	00005517          	auipc	a0,0x5
ffffffffc020160c:	ed050513          	addi	a0,a0,-304 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201610:	e7ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201614:	00005697          	auipc	a3,0x5
ffffffffc0201618:	02468693          	addi	a3,a3,36 # ffffffffc0206638 <commands+0x9d0>
ffffffffc020161c:	00005617          	auipc	a2,0x5
ffffffffc0201620:	ea460613          	addi	a2,a2,-348 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201624:	13800593          	li	a1,312
ffffffffc0201628:	00005517          	auipc	a0,0x5
ffffffffc020162c:	eb050513          	addi	a0,a0,-336 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201630:	e5ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201634:	00005697          	auipc	a3,0x5
ffffffffc0201638:	fc468693          	addi	a3,a3,-60 # ffffffffc02065f8 <commands+0x990>
ffffffffc020163c:	00005617          	auipc	a2,0x5
ffffffffc0201640:	e8460613          	addi	a2,a2,-380 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201644:	0df00593          	li	a1,223
ffffffffc0201648:	00005517          	auipc	a0,0x5
ffffffffc020164c:	e9050513          	addi	a0,a0,-368 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201650:	e3ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201654:	00005697          	auipc	a3,0x5
ffffffffc0201658:	16468693          	addi	a3,a3,356 # ffffffffc02067b8 <commands+0xb50>
ffffffffc020165c:	00005617          	auipc	a2,0x5
ffffffffc0201660:	e6460613          	addi	a2,a2,-412 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201664:	13200593          	li	a1,306
ffffffffc0201668:	00005517          	auipc	a0,0x5
ffffffffc020166c:	e7050513          	addi	a0,a0,-400 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201670:	e1ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201674:	00005697          	auipc	a3,0x5
ffffffffc0201678:	12468693          	addi	a3,a3,292 # ffffffffc0206798 <commands+0xb30>
ffffffffc020167c:	00005617          	auipc	a2,0x5
ffffffffc0201680:	e4460613          	addi	a2,a2,-444 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201684:	13000593          	li	a1,304
ffffffffc0201688:	00005517          	auipc	a0,0x5
ffffffffc020168c:	e5050513          	addi	a0,a0,-432 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201690:	dfffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201694:	00005697          	auipc	a3,0x5
ffffffffc0201698:	0dc68693          	addi	a3,a3,220 # ffffffffc0206770 <commands+0xb08>
ffffffffc020169c:	00005617          	auipc	a2,0x5
ffffffffc02016a0:	e2460613          	addi	a2,a2,-476 # ffffffffc02064c0 <commands+0x858>
ffffffffc02016a4:	12e00593          	li	a1,302
ffffffffc02016a8:	00005517          	auipc	a0,0x5
ffffffffc02016ac:	e3050513          	addi	a0,a0,-464 # ffffffffc02064d8 <commands+0x870>
ffffffffc02016b0:	ddffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02016b4:	00005697          	auipc	a3,0x5
ffffffffc02016b8:	09468693          	addi	a3,a3,148 # ffffffffc0206748 <commands+0xae0>
ffffffffc02016bc:	00005617          	auipc	a2,0x5
ffffffffc02016c0:	e0460613          	addi	a2,a2,-508 # ffffffffc02064c0 <commands+0x858>
ffffffffc02016c4:	12d00593          	li	a1,301
ffffffffc02016c8:	00005517          	auipc	a0,0x5
ffffffffc02016cc:	e1050513          	addi	a0,a0,-496 # ffffffffc02064d8 <commands+0x870>
ffffffffc02016d0:	dbffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(p0 + 2 == p1);
ffffffffc02016d4:	00005697          	auipc	a3,0x5
ffffffffc02016d8:	06468693          	addi	a3,a3,100 # ffffffffc0206738 <commands+0xad0>
ffffffffc02016dc:	00005617          	auipc	a2,0x5
ffffffffc02016e0:	de460613          	addi	a2,a2,-540 # ffffffffc02064c0 <commands+0x858>
ffffffffc02016e4:	12800593          	li	a1,296
ffffffffc02016e8:	00005517          	auipc	a0,0x5
ffffffffc02016ec:	df050513          	addi	a0,a0,-528 # ffffffffc02064d8 <commands+0x870>
ffffffffc02016f0:	d9ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02016f4:	00005697          	auipc	a3,0x5
ffffffffc02016f8:	f4468693          	addi	a3,a3,-188 # ffffffffc0206638 <commands+0x9d0>
ffffffffc02016fc:	00005617          	auipc	a2,0x5
ffffffffc0201700:	dc460613          	addi	a2,a2,-572 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201704:	12700593          	li	a1,295
ffffffffc0201708:	00005517          	auipc	a0,0x5
ffffffffc020170c:	dd050513          	addi	a0,a0,-560 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201710:	d7ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201714:	00005697          	auipc	a3,0x5
ffffffffc0201718:	00468693          	addi	a3,a3,4 # ffffffffc0206718 <commands+0xab0>
ffffffffc020171c:	00005617          	auipc	a2,0x5
ffffffffc0201720:	da460613          	addi	a2,a2,-604 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201724:	12600593          	li	a1,294
ffffffffc0201728:	00005517          	auipc	a0,0x5
ffffffffc020172c:	db050513          	addi	a0,a0,-592 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201730:	d5ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201734:	00005697          	auipc	a3,0x5
ffffffffc0201738:	fb468693          	addi	a3,a3,-76 # ffffffffc02066e8 <commands+0xa80>
ffffffffc020173c:	00005617          	auipc	a2,0x5
ffffffffc0201740:	d8460613          	addi	a2,a2,-636 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201744:	12500593          	li	a1,293
ffffffffc0201748:	00005517          	auipc	a0,0x5
ffffffffc020174c:	d9050513          	addi	a0,a0,-624 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201750:	d3ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201754:	00005697          	auipc	a3,0x5
ffffffffc0201758:	f7c68693          	addi	a3,a3,-132 # ffffffffc02066d0 <commands+0xa68>
ffffffffc020175c:	00005617          	auipc	a2,0x5
ffffffffc0201760:	d6460613          	addi	a2,a2,-668 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201764:	12400593          	li	a1,292
ffffffffc0201768:	00005517          	auipc	a0,0x5
ffffffffc020176c:	d7050513          	addi	a0,a0,-656 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201770:	d1ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201774:	00005697          	auipc	a3,0x5
ffffffffc0201778:	ec468693          	addi	a3,a3,-316 # ffffffffc0206638 <commands+0x9d0>
ffffffffc020177c:	00005617          	auipc	a2,0x5
ffffffffc0201780:	d4460613          	addi	a2,a2,-700 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201784:	11e00593          	li	a1,286
ffffffffc0201788:	00005517          	auipc	a0,0x5
ffffffffc020178c:	d5050513          	addi	a0,a0,-688 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201790:	cfffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(!PageProperty(p0));
ffffffffc0201794:	00005697          	auipc	a3,0x5
ffffffffc0201798:	f2468693          	addi	a3,a3,-220 # ffffffffc02066b8 <commands+0xa50>
ffffffffc020179c:	00005617          	auipc	a2,0x5
ffffffffc02017a0:	d2460613          	addi	a2,a2,-732 # ffffffffc02064c0 <commands+0x858>
ffffffffc02017a4:	11900593          	li	a1,281
ffffffffc02017a8:	00005517          	auipc	a0,0x5
ffffffffc02017ac:	d3050513          	addi	a0,a0,-720 # ffffffffc02064d8 <commands+0x870>
ffffffffc02017b0:	cdffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02017b4:	00005697          	auipc	a3,0x5
ffffffffc02017b8:	02468693          	addi	a3,a3,36 # ffffffffc02067d8 <commands+0xb70>
ffffffffc02017bc:	00005617          	auipc	a2,0x5
ffffffffc02017c0:	d0460613          	addi	a2,a2,-764 # ffffffffc02064c0 <commands+0x858>
ffffffffc02017c4:	13700593          	li	a1,311
ffffffffc02017c8:	00005517          	auipc	a0,0x5
ffffffffc02017cc:	d1050513          	addi	a0,a0,-752 # ffffffffc02064d8 <commands+0x870>
ffffffffc02017d0:	cbffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(total == 0);
ffffffffc02017d4:	00005697          	auipc	a3,0x5
ffffffffc02017d8:	03468693          	addi	a3,a3,52 # ffffffffc0206808 <commands+0xba0>
ffffffffc02017dc:	00005617          	auipc	a2,0x5
ffffffffc02017e0:	ce460613          	addi	a2,a2,-796 # ffffffffc02064c0 <commands+0x858>
ffffffffc02017e4:	14700593          	li	a1,327
ffffffffc02017e8:	00005517          	auipc	a0,0x5
ffffffffc02017ec:	cf050513          	addi	a0,a0,-784 # ffffffffc02064d8 <commands+0x870>
ffffffffc02017f0:	c9ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(total == nr_free_pages());
ffffffffc02017f4:	00005697          	auipc	a3,0x5
ffffffffc02017f8:	cfc68693          	addi	a3,a3,-772 # ffffffffc02064f0 <commands+0x888>
ffffffffc02017fc:	00005617          	auipc	a2,0x5
ffffffffc0201800:	cc460613          	addi	a2,a2,-828 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201804:	11300593          	li	a1,275
ffffffffc0201808:	00005517          	auipc	a0,0x5
ffffffffc020180c:	cd050513          	addi	a0,a0,-816 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201810:	c7ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201814:	00005697          	auipc	a3,0x5
ffffffffc0201818:	d1c68693          	addi	a3,a3,-740 # ffffffffc0206530 <commands+0x8c8>
ffffffffc020181c:	00005617          	auipc	a2,0x5
ffffffffc0201820:	ca460613          	addi	a2,a2,-860 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201824:	0d800593          	li	a1,216
ffffffffc0201828:	00005517          	auipc	a0,0x5
ffffffffc020182c:	cb050513          	addi	a0,a0,-848 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201830:	c5ffe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201834 <default_free_pages>:
{
ffffffffc0201834:	1141                	addi	sp,sp,-16
ffffffffc0201836:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201838:	14058463          	beqz	a1,ffffffffc0201980 <default_free_pages+0x14c>
    for (; p != base + n; p++)
ffffffffc020183c:	00659693          	slli	a3,a1,0x6
ffffffffc0201840:	96aa                	add	a3,a3,a0
ffffffffc0201842:	87aa                	mv	a5,a0
ffffffffc0201844:	02d50263          	beq	a0,a3,ffffffffc0201868 <default_free_pages+0x34>
ffffffffc0201848:	6798                	ld	a4,8(a5)
ffffffffc020184a:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020184c:	10071a63          	bnez	a4,ffffffffc0201960 <default_free_pages+0x12c>
ffffffffc0201850:	6798                	ld	a4,8(a5)
ffffffffc0201852:	8b09                	andi	a4,a4,2
ffffffffc0201854:	10071663          	bnez	a4,ffffffffc0201960 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0201858:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc020185c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0201860:	04078793          	addi	a5,a5,64
ffffffffc0201864:	fed792e3          	bne	a5,a3,ffffffffc0201848 <default_free_pages+0x14>
    base->property = n;
ffffffffc0201868:	2581                	sext.w	a1,a1
ffffffffc020186a:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020186c:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201870:	4789                	li	a5,2
ffffffffc0201872:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201876:	000c4697          	auipc	a3,0xc4
ffffffffc020187a:	51268693          	addi	a3,a3,1298 # ffffffffc02c5d88 <free_area>
ffffffffc020187e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201880:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201882:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201886:	9db9                	addw	a1,a1,a4
ffffffffc0201888:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc020188a:	0ad78463          	beq	a5,a3,ffffffffc0201932 <default_free_pages+0xfe>
            struct Page *page = le2page(le, page_link);
ffffffffc020188e:	fe878713          	addi	a4,a5,-24
ffffffffc0201892:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0201896:	4581                	li	a1,0
            if (base < page)
ffffffffc0201898:	00e56a63          	bltu	a0,a4,ffffffffc02018ac <default_free_pages+0x78>
    return listelm->next;
ffffffffc020189c:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc020189e:	04d70c63          	beq	a4,a3,ffffffffc02018f6 <default_free_pages+0xc2>
    for (; p != base + n; p++)
ffffffffc02018a2:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc02018a4:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc02018a8:	fee57ae3          	bgeu	a0,a4,ffffffffc020189c <default_free_pages+0x68>
ffffffffc02018ac:	c199                	beqz	a1,ffffffffc02018b2 <default_free_pages+0x7e>
ffffffffc02018ae:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02018b2:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02018b4:	e390                	sd	a2,0(a5)
ffffffffc02018b6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02018b8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02018ba:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc02018bc:	00d70d63          	beq	a4,a3,ffffffffc02018d6 <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc02018c0:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc02018c4:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc02018c8:	02059813          	slli	a6,a1,0x20
ffffffffc02018cc:	01a85793          	srli	a5,a6,0x1a
ffffffffc02018d0:	97b2                	add	a5,a5,a2
ffffffffc02018d2:	02f50c63          	beq	a0,a5,ffffffffc020190a <default_free_pages+0xd6>
    return listelm->next;
ffffffffc02018d6:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc02018d8:	00d78c63          	beq	a5,a3,ffffffffc02018f0 <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc02018dc:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc02018de:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc02018e2:	02061593          	slli	a1,a2,0x20
ffffffffc02018e6:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02018ea:	972a                	add	a4,a4,a0
ffffffffc02018ec:	04e68a63          	beq	a3,a4,ffffffffc0201940 <default_free_pages+0x10c>
}
ffffffffc02018f0:	60a2                	ld	ra,8(sp)
ffffffffc02018f2:	0141                	addi	sp,sp,16
ffffffffc02018f4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02018f6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02018f8:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02018fa:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02018fc:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc02018fe:	02d70763          	beq	a4,a3,ffffffffc020192c <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0201902:	8832                	mv	a6,a2
ffffffffc0201904:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0201906:	87ba                	mv	a5,a4
ffffffffc0201908:	bf71                	j	ffffffffc02018a4 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc020190a:	491c                	lw	a5,16(a0)
ffffffffc020190c:	9dbd                	addw	a1,a1,a5
ffffffffc020190e:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201912:	57f5                	li	a5,-3
ffffffffc0201914:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201918:	01853803          	ld	a6,24(a0)
ffffffffc020191c:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc020191e:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201920:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0201924:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0201926:	0105b023          	sd	a6,0(a1)
ffffffffc020192a:	b77d                	j	ffffffffc02018d8 <default_free_pages+0xa4>
ffffffffc020192c:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc020192e:	873e                	mv	a4,a5
ffffffffc0201930:	bf41                	j	ffffffffc02018c0 <default_free_pages+0x8c>
}
ffffffffc0201932:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201934:	e390                	sd	a2,0(a5)
ffffffffc0201936:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201938:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020193a:	ed1c                	sd	a5,24(a0)
ffffffffc020193c:	0141                	addi	sp,sp,16
ffffffffc020193e:	8082                	ret
            base->property += p->property;
ffffffffc0201940:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201944:	ff078693          	addi	a3,a5,-16
ffffffffc0201948:	9e39                	addw	a2,a2,a4
ffffffffc020194a:	c910                	sw	a2,16(a0)
ffffffffc020194c:	5775                	li	a4,-3
ffffffffc020194e:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201952:	6398                	ld	a4,0(a5)
ffffffffc0201954:	679c                	ld	a5,8(a5)
}
ffffffffc0201956:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201958:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020195a:	e398                	sd	a4,0(a5)
ffffffffc020195c:	0141                	addi	sp,sp,16
ffffffffc020195e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201960:	00005697          	auipc	a3,0x5
ffffffffc0201964:	ec068693          	addi	a3,a3,-320 # ffffffffc0206820 <commands+0xbb8>
ffffffffc0201968:	00005617          	auipc	a2,0x5
ffffffffc020196c:	b5860613          	addi	a2,a2,-1192 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201970:	09400593          	li	a1,148
ffffffffc0201974:	00005517          	auipc	a0,0x5
ffffffffc0201978:	b6450513          	addi	a0,a0,-1180 # ffffffffc02064d8 <commands+0x870>
ffffffffc020197c:	b13fe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(n > 0);
ffffffffc0201980:	00005697          	auipc	a3,0x5
ffffffffc0201984:	e9868693          	addi	a3,a3,-360 # ffffffffc0206818 <commands+0xbb0>
ffffffffc0201988:	00005617          	auipc	a2,0x5
ffffffffc020198c:	b3860613          	addi	a2,a2,-1224 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201990:	09000593          	li	a1,144
ffffffffc0201994:	00005517          	auipc	a0,0x5
ffffffffc0201998:	b4450513          	addi	a0,a0,-1212 # ffffffffc02064d8 <commands+0x870>
ffffffffc020199c:	af3fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02019a0 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02019a0:	c941                	beqz	a0,ffffffffc0201a30 <default_alloc_pages+0x90>
    if (n > nr_free)
ffffffffc02019a2:	000c4597          	auipc	a1,0xc4
ffffffffc02019a6:	3e658593          	addi	a1,a1,998 # ffffffffc02c5d88 <free_area>
ffffffffc02019aa:	0105a803          	lw	a6,16(a1)
ffffffffc02019ae:	872a                	mv	a4,a0
ffffffffc02019b0:	02081793          	slli	a5,a6,0x20
ffffffffc02019b4:	9381                	srli	a5,a5,0x20
ffffffffc02019b6:	00a7ee63          	bltu	a5,a0,ffffffffc02019d2 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02019ba:	87ae                	mv	a5,a1
ffffffffc02019bc:	a801                	j	ffffffffc02019cc <default_alloc_pages+0x2c>
        if (p->property >= n)
ffffffffc02019be:	ff87a683          	lw	a3,-8(a5)
ffffffffc02019c2:	02069613          	slli	a2,a3,0x20
ffffffffc02019c6:	9201                	srli	a2,a2,0x20
ffffffffc02019c8:	00e67763          	bgeu	a2,a4,ffffffffc02019d6 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02019cc:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc02019ce:	feb798e3          	bne	a5,a1,ffffffffc02019be <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02019d2:	4501                	li	a0,0
}
ffffffffc02019d4:	8082                	ret
    return listelm->prev;
ffffffffc02019d6:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02019da:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02019de:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc02019e2:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc02019e6:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02019ea:	01133023          	sd	a7,0(t1)
        if (page->property > n)
ffffffffc02019ee:	02c77863          	bgeu	a4,a2,ffffffffc0201a1e <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc02019f2:	071a                	slli	a4,a4,0x6
ffffffffc02019f4:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02019f6:	41c686bb          	subw	a3,a3,t3
ffffffffc02019fa:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02019fc:	00870613          	addi	a2,a4,8
ffffffffc0201a00:	4689                	li	a3,2
ffffffffc0201a02:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201a06:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201a0a:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0201a0e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201a12:	e290                	sd	a2,0(a3)
ffffffffc0201a14:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201a18:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0201a1a:	01173c23          	sd	a7,24(a4)
ffffffffc0201a1e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201a22:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201a26:	5775                	li	a4,-3
ffffffffc0201a28:	17c1                	addi	a5,a5,-16
ffffffffc0201a2a:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201a2e:	8082                	ret
{
ffffffffc0201a30:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201a32:	00005697          	auipc	a3,0x5
ffffffffc0201a36:	de668693          	addi	a3,a3,-538 # ffffffffc0206818 <commands+0xbb0>
ffffffffc0201a3a:	00005617          	auipc	a2,0x5
ffffffffc0201a3e:	a8660613          	addi	a2,a2,-1402 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201a42:	06c00593          	li	a1,108
ffffffffc0201a46:	00005517          	auipc	a0,0x5
ffffffffc0201a4a:	a9250513          	addi	a0,a0,-1390 # ffffffffc02064d8 <commands+0x870>
{
ffffffffc0201a4e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201a50:	a3ffe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201a54 <default_init_memmap>:
{
ffffffffc0201a54:	1141                	addi	sp,sp,-16
ffffffffc0201a56:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201a58:	c5f1                	beqz	a1,ffffffffc0201b24 <default_init_memmap+0xd0>
    for (; p != base + n; p++)
ffffffffc0201a5a:	00659693          	slli	a3,a1,0x6
ffffffffc0201a5e:	96aa                	add	a3,a3,a0
ffffffffc0201a60:	87aa                	mv	a5,a0
ffffffffc0201a62:	00d50f63          	beq	a0,a3,ffffffffc0201a80 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201a66:	6798                	ld	a4,8(a5)
ffffffffc0201a68:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0201a6a:	cf49                	beqz	a4,ffffffffc0201b04 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0201a6c:	0007a823          	sw	zero,16(a5)
ffffffffc0201a70:	0007b423          	sd	zero,8(a5)
ffffffffc0201a74:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0201a78:	04078793          	addi	a5,a5,64
ffffffffc0201a7c:	fed795e3          	bne	a5,a3,ffffffffc0201a66 <default_init_memmap+0x12>
    base->property = n;
ffffffffc0201a80:	2581                	sext.w	a1,a1
ffffffffc0201a82:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201a84:	4789                	li	a5,2
ffffffffc0201a86:	00850713          	addi	a4,a0,8
ffffffffc0201a8a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201a8e:	000c4697          	auipc	a3,0xc4
ffffffffc0201a92:	2fa68693          	addi	a3,a3,762 # ffffffffc02c5d88 <free_area>
ffffffffc0201a96:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201a98:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201a9a:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201a9e:	9db9                	addw	a1,a1,a4
ffffffffc0201aa0:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0201aa2:	04d78a63          	beq	a5,a3,ffffffffc0201af6 <default_init_memmap+0xa2>
            struct Page *page = le2page(le, page_link);
ffffffffc0201aa6:	fe878713          	addi	a4,a5,-24
ffffffffc0201aaa:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0201aae:	4581                	li	a1,0
            if (base < page)
ffffffffc0201ab0:	00e56a63          	bltu	a0,a4,ffffffffc0201ac4 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201ab4:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201ab6:	02d70263          	beq	a4,a3,ffffffffc0201ada <default_init_memmap+0x86>
    for (; p != base + n; p++)
ffffffffc0201aba:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201abc:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201ac0:	fee57ae3          	bgeu	a0,a4,ffffffffc0201ab4 <default_init_memmap+0x60>
ffffffffc0201ac4:	c199                	beqz	a1,ffffffffc0201aca <default_init_memmap+0x76>
ffffffffc0201ac6:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201aca:	6398                	ld	a4,0(a5)
}
ffffffffc0201acc:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201ace:	e390                	sd	a2,0(a5)
ffffffffc0201ad0:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201ad2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201ad4:	ed18                	sd	a4,24(a0)
ffffffffc0201ad6:	0141                	addi	sp,sp,16
ffffffffc0201ad8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201ada:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201adc:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201ade:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201ae0:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0201ae2:	00d70663          	beq	a4,a3,ffffffffc0201aee <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0201ae6:	8832                	mv	a6,a2
ffffffffc0201ae8:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0201aea:	87ba                	mv	a5,a4
ffffffffc0201aec:	bfc1                	j	ffffffffc0201abc <default_init_memmap+0x68>
}
ffffffffc0201aee:	60a2                	ld	ra,8(sp)
ffffffffc0201af0:	e290                	sd	a2,0(a3)
ffffffffc0201af2:	0141                	addi	sp,sp,16
ffffffffc0201af4:	8082                	ret
ffffffffc0201af6:	60a2                	ld	ra,8(sp)
ffffffffc0201af8:	e390                	sd	a2,0(a5)
ffffffffc0201afa:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201afc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201afe:	ed1c                	sd	a5,24(a0)
ffffffffc0201b00:	0141                	addi	sp,sp,16
ffffffffc0201b02:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201b04:	00005697          	auipc	a3,0x5
ffffffffc0201b08:	d4468693          	addi	a3,a3,-700 # ffffffffc0206848 <commands+0xbe0>
ffffffffc0201b0c:	00005617          	auipc	a2,0x5
ffffffffc0201b10:	9b460613          	addi	a2,a2,-1612 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201b14:	04b00593          	li	a1,75
ffffffffc0201b18:	00005517          	auipc	a0,0x5
ffffffffc0201b1c:	9c050513          	addi	a0,a0,-1600 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201b20:	96ffe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(n > 0);
ffffffffc0201b24:	00005697          	auipc	a3,0x5
ffffffffc0201b28:	cf468693          	addi	a3,a3,-780 # ffffffffc0206818 <commands+0xbb0>
ffffffffc0201b2c:	00005617          	auipc	a2,0x5
ffffffffc0201b30:	99460613          	addi	a2,a2,-1644 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201b34:	04700593          	li	a1,71
ffffffffc0201b38:	00005517          	auipc	a0,0x5
ffffffffc0201b3c:	9a050513          	addi	a0,a0,-1632 # ffffffffc02064d8 <commands+0x870>
ffffffffc0201b40:	94ffe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201b44 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201b44:	c94d                	beqz	a0,ffffffffc0201bf6 <slob_free+0xb2>
{
ffffffffc0201b46:	1141                	addi	sp,sp,-16
ffffffffc0201b48:	e022                	sd	s0,0(sp)
ffffffffc0201b4a:	e406                	sd	ra,8(sp)
ffffffffc0201b4c:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201b4e:	e9c1                	bnez	a1,ffffffffc0201bde <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b50:	100027f3          	csrr	a5,sstatus
ffffffffc0201b54:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201b56:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b58:	ebd9                	bnez	a5,ffffffffc0201bee <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201b5a:	000c4617          	auipc	a2,0xc4
ffffffffc0201b5e:	e1e60613          	addi	a2,a2,-482 # ffffffffc02c5978 <slobfree>
ffffffffc0201b62:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b64:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201b66:	679c                	ld	a5,8(a5)
ffffffffc0201b68:	02877a63          	bgeu	a4,s0,ffffffffc0201b9c <slob_free+0x58>
ffffffffc0201b6c:	00f46463          	bltu	s0,a5,ffffffffc0201b74 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b70:	fef76ae3          	bltu	a4,a5,ffffffffc0201b64 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc0201b74:	400c                	lw	a1,0(s0)
ffffffffc0201b76:	00459693          	slli	a3,a1,0x4
ffffffffc0201b7a:	96a2                	add	a3,a3,s0
ffffffffc0201b7c:	02d78a63          	beq	a5,a3,ffffffffc0201bb0 <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201b80:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201b82:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201b84:	00469793          	slli	a5,a3,0x4
ffffffffc0201b88:	97ba                	add	a5,a5,a4
ffffffffc0201b8a:	02f40e63          	beq	s0,a5,ffffffffc0201bc6 <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc0201b8e:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201b90:	e218                	sd	a4,0(a2)
    if (flag)
ffffffffc0201b92:	e129                	bnez	a0,ffffffffc0201bd4 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201b94:	60a2                	ld	ra,8(sp)
ffffffffc0201b96:	6402                	ld	s0,0(sp)
ffffffffc0201b98:	0141                	addi	sp,sp,16
ffffffffc0201b9a:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b9c:	fcf764e3          	bltu	a4,a5,ffffffffc0201b64 <slob_free+0x20>
ffffffffc0201ba0:	fcf472e3          	bgeu	s0,a5,ffffffffc0201b64 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc0201ba4:	400c                	lw	a1,0(s0)
ffffffffc0201ba6:	00459693          	slli	a3,a1,0x4
ffffffffc0201baa:	96a2                	add	a3,a3,s0
ffffffffc0201bac:	fcd79ae3          	bne	a5,a3,ffffffffc0201b80 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201bb0:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201bb2:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201bb4:	9db5                	addw	a1,a1,a3
ffffffffc0201bb6:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc0201bb8:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201bba:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201bbc:	00469793          	slli	a5,a3,0x4
ffffffffc0201bc0:	97ba                	add	a5,a5,a4
ffffffffc0201bc2:	fcf416e3          	bne	s0,a5,ffffffffc0201b8e <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201bc6:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201bc8:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201bca:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201bcc:	9ebd                	addw	a3,a3,a5
ffffffffc0201bce:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201bd0:	e70c                	sd	a1,8(a4)
ffffffffc0201bd2:	d169                	beqz	a0,ffffffffc0201b94 <slob_free+0x50>
}
ffffffffc0201bd4:	6402                	ld	s0,0(sp)
ffffffffc0201bd6:	60a2                	ld	ra,8(sp)
ffffffffc0201bd8:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201bda:	dd5fe06f          	j	ffffffffc02009ae <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201bde:	25bd                	addiw	a1,a1,15
ffffffffc0201be0:	8191                	srli	a1,a1,0x4
ffffffffc0201be2:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201be4:	100027f3          	csrr	a5,sstatus
ffffffffc0201be8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201bea:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201bec:	d7bd                	beqz	a5,ffffffffc0201b5a <slob_free+0x16>
        intr_disable();
ffffffffc0201bee:	dc7fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0201bf2:	4505                	li	a0,1
ffffffffc0201bf4:	b79d                	j	ffffffffc0201b5a <slob_free+0x16>
ffffffffc0201bf6:	8082                	ret

ffffffffc0201bf8 <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201bf8:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201bfa:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201bfc:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201c00:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201c02:	352000ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
	if (!page)
ffffffffc0201c06:	c91d                	beqz	a0,ffffffffc0201c3c <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201c08:	000c8697          	auipc	a3,0xc8
ffffffffc0201c0c:	1f06b683          	ld	a3,496(a3) # ffffffffc02c9df8 <pages>
ffffffffc0201c10:	8d15                	sub	a0,a0,a3
ffffffffc0201c12:	8519                	srai	a0,a0,0x6
ffffffffc0201c14:	00006697          	auipc	a3,0x6
ffffffffc0201c18:	f8c6b683          	ld	a3,-116(a3) # ffffffffc0207ba0 <nbase>
ffffffffc0201c1c:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201c1e:	00c51793          	slli	a5,a0,0xc
ffffffffc0201c22:	83b1                	srli	a5,a5,0xc
ffffffffc0201c24:	000c8717          	auipc	a4,0xc8
ffffffffc0201c28:	1cc73703          	ld	a4,460(a4) # ffffffffc02c9df0 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c2c:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201c2e:	00e7fa63          	bgeu	a5,a4,ffffffffc0201c42 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201c32:	000c8697          	auipc	a3,0xc8
ffffffffc0201c36:	1d66b683          	ld	a3,470(a3) # ffffffffc02c9e08 <va_pa_offset>
ffffffffc0201c3a:	9536                	add	a0,a0,a3
}
ffffffffc0201c3c:	60a2                	ld	ra,8(sp)
ffffffffc0201c3e:	0141                	addi	sp,sp,16
ffffffffc0201c40:	8082                	ret
ffffffffc0201c42:	86aa                	mv	a3,a0
ffffffffc0201c44:	00005617          	auipc	a2,0x5
ffffffffc0201c48:	c6460613          	addi	a2,a2,-924 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc0201c4c:	07100593          	li	a1,113
ffffffffc0201c50:	00005517          	auipc	a0,0x5
ffffffffc0201c54:	c8050513          	addi	a0,a0,-896 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc0201c58:	837fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201c5c <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201c5c:	1101                	addi	sp,sp,-32
ffffffffc0201c5e:	ec06                	sd	ra,24(sp)
ffffffffc0201c60:	e822                	sd	s0,16(sp)
ffffffffc0201c62:	e426                	sd	s1,8(sp)
ffffffffc0201c64:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201c66:	01050713          	addi	a4,a0,16
ffffffffc0201c6a:	6785                	lui	a5,0x1
ffffffffc0201c6c:	0cf77363          	bgeu	a4,a5,ffffffffc0201d32 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201c70:	00f50493          	addi	s1,a0,15
ffffffffc0201c74:	8091                	srli	s1,s1,0x4
ffffffffc0201c76:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c78:	10002673          	csrr	a2,sstatus
ffffffffc0201c7c:	8a09                	andi	a2,a2,2
ffffffffc0201c7e:	e25d                	bnez	a2,ffffffffc0201d24 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201c80:	000c4917          	auipc	s2,0xc4
ffffffffc0201c84:	cf890913          	addi	s2,s2,-776 # ffffffffc02c5978 <slobfree>
ffffffffc0201c88:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c8c:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc0201c8e:	4398                	lw	a4,0(a5)
ffffffffc0201c90:	08975e63          	bge	a4,s1,ffffffffc0201d2c <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc0201c94:	00f68b63          	beq	a3,a5,ffffffffc0201caa <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c98:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201c9a:	4018                	lw	a4,0(s0)
ffffffffc0201c9c:	02975a63          	bge	a4,s1,ffffffffc0201cd0 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc0201ca0:	00093683          	ld	a3,0(s2)
ffffffffc0201ca4:	87a2                	mv	a5,s0
ffffffffc0201ca6:	fef699e3          	bne	a3,a5,ffffffffc0201c98 <slob_alloc.constprop.0+0x3c>
    if (flag)
ffffffffc0201caa:	ee31                	bnez	a2,ffffffffc0201d06 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201cac:	4501                	li	a0,0
ffffffffc0201cae:	f4bff0ef          	jal	ra,ffffffffc0201bf8 <__slob_get_free_pages.constprop.0>
ffffffffc0201cb2:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201cb4:	cd05                	beqz	a0,ffffffffc0201cec <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201cb6:	6585                	lui	a1,0x1
ffffffffc0201cb8:	e8dff0ef          	jal	ra,ffffffffc0201b44 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201cbc:	10002673          	csrr	a2,sstatus
ffffffffc0201cc0:	8a09                	andi	a2,a2,2
ffffffffc0201cc2:	ee05                	bnez	a2,ffffffffc0201cfa <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201cc4:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201cc8:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201cca:	4018                	lw	a4,0(s0)
ffffffffc0201ccc:	fc974ae3          	blt	a4,s1,ffffffffc0201ca0 <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201cd0:	04e48763          	beq	s1,a4,ffffffffc0201d1e <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201cd4:	00449693          	slli	a3,s1,0x4
ffffffffc0201cd8:	96a2                	add	a3,a3,s0
ffffffffc0201cda:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201cdc:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201cde:	9f05                	subw	a4,a4,s1
ffffffffc0201ce0:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201ce2:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201ce4:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201ce6:	00f93023          	sd	a5,0(s2)
    if (flag)
ffffffffc0201cea:	e20d                	bnez	a2,ffffffffc0201d0c <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201cec:	60e2                	ld	ra,24(sp)
ffffffffc0201cee:	8522                	mv	a0,s0
ffffffffc0201cf0:	6442                	ld	s0,16(sp)
ffffffffc0201cf2:	64a2                	ld	s1,8(sp)
ffffffffc0201cf4:	6902                	ld	s2,0(sp)
ffffffffc0201cf6:	6105                	addi	sp,sp,32
ffffffffc0201cf8:	8082                	ret
        intr_disable();
ffffffffc0201cfa:	cbbfe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
			cur = slobfree;
ffffffffc0201cfe:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201d02:	4605                	li	a2,1
ffffffffc0201d04:	b7d1                	j	ffffffffc0201cc8 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201d06:	ca9fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201d0a:	b74d                	j	ffffffffc0201cac <slob_alloc.constprop.0+0x50>
ffffffffc0201d0c:	ca3fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
}
ffffffffc0201d10:	60e2                	ld	ra,24(sp)
ffffffffc0201d12:	8522                	mv	a0,s0
ffffffffc0201d14:	6442                	ld	s0,16(sp)
ffffffffc0201d16:	64a2                	ld	s1,8(sp)
ffffffffc0201d18:	6902                	ld	s2,0(sp)
ffffffffc0201d1a:	6105                	addi	sp,sp,32
ffffffffc0201d1c:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201d1e:	6418                	ld	a4,8(s0)
ffffffffc0201d20:	e798                	sd	a4,8(a5)
ffffffffc0201d22:	b7d1                	j	ffffffffc0201ce6 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201d24:	c91fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0201d28:	4605                	li	a2,1
ffffffffc0201d2a:	bf99                	j	ffffffffc0201c80 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0201d2c:	843e                	mv	s0,a5
ffffffffc0201d2e:	87b6                	mv	a5,a3
ffffffffc0201d30:	b745                	j	ffffffffc0201cd0 <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201d32:	00005697          	auipc	a3,0x5
ffffffffc0201d36:	bae68693          	addi	a3,a3,-1106 # ffffffffc02068e0 <default_pmm_manager+0x70>
ffffffffc0201d3a:	00004617          	auipc	a2,0x4
ffffffffc0201d3e:	78660613          	addi	a2,a2,1926 # ffffffffc02064c0 <commands+0x858>
ffffffffc0201d42:	06300593          	li	a1,99
ffffffffc0201d46:	00005517          	auipc	a0,0x5
ffffffffc0201d4a:	bba50513          	addi	a0,a0,-1094 # ffffffffc0206900 <default_pmm_manager+0x90>
ffffffffc0201d4e:	f40fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201d52 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201d52:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201d54:	00005517          	auipc	a0,0x5
ffffffffc0201d58:	bc450513          	addi	a0,a0,-1084 # ffffffffc0206918 <default_pmm_manager+0xa8>
{
ffffffffc0201d5c:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201d5e:	c36fe0ef          	jal	ra,ffffffffc0200194 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201d62:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201d64:	00005517          	auipc	a0,0x5
ffffffffc0201d68:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0206930 <default_pmm_manager+0xc0>
}
ffffffffc0201d6c:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201d6e:	c26fe06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0201d72 <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201d72:	4501                	li	a0,0
ffffffffc0201d74:	8082                	ret

ffffffffc0201d76 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201d76:	1101                	addi	sp,sp,-32
ffffffffc0201d78:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201d7a:	6905                	lui	s2,0x1
{
ffffffffc0201d7c:	e822                	sd	s0,16(sp)
ffffffffc0201d7e:	ec06                	sd	ra,24(sp)
ffffffffc0201d80:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201d82:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8c61>
{
ffffffffc0201d86:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201d88:	04a7f963          	bgeu	a5,a0,ffffffffc0201dda <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201d8c:	4561                	li	a0,24
ffffffffc0201d8e:	ecfff0ef          	jal	ra,ffffffffc0201c5c <slob_alloc.constprop.0>
ffffffffc0201d92:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201d94:	c929                	beqz	a0,ffffffffc0201de6 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201d96:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201d9a:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201d9c:	00f95763          	bge	s2,a5,ffffffffc0201daa <kmalloc+0x34>
ffffffffc0201da0:	6705                	lui	a4,0x1
ffffffffc0201da2:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201da4:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201da6:	fef74ee3          	blt	a4,a5,ffffffffc0201da2 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201daa:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201dac:	e4dff0ef          	jal	ra,ffffffffc0201bf8 <__slob_get_free_pages.constprop.0>
ffffffffc0201db0:	e488                	sd	a0,8(s1)
ffffffffc0201db2:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc0201db4:	c525                	beqz	a0,ffffffffc0201e1c <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201db6:	100027f3          	csrr	a5,sstatus
ffffffffc0201dba:	8b89                	andi	a5,a5,2
ffffffffc0201dbc:	ef8d                	bnez	a5,ffffffffc0201df6 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201dbe:	000c8797          	auipc	a5,0xc8
ffffffffc0201dc2:	01a78793          	addi	a5,a5,26 # ffffffffc02c9dd8 <bigblocks>
ffffffffc0201dc6:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201dc8:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201dca:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0201dcc:	60e2                	ld	ra,24(sp)
ffffffffc0201dce:	8522                	mv	a0,s0
ffffffffc0201dd0:	6442                	ld	s0,16(sp)
ffffffffc0201dd2:	64a2                	ld	s1,8(sp)
ffffffffc0201dd4:	6902                	ld	s2,0(sp)
ffffffffc0201dd6:	6105                	addi	sp,sp,32
ffffffffc0201dd8:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201dda:	0541                	addi	a0,a0,16
ffffffffc0201ddc:	e81ff0ef          	jal	ra,ffffffffc0201c5c <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201de0:	01050413          	addi	s0,a0,16
ffffffffc0201de4:	f565                	bnez	a0,ffffffffc0201dcc <kmalloc+0x56>
ffffffffc0201de6:	4401                	li	s0,0
}
ffffffffc0201de8:	60e2                	ld	ra,24(sp)
ffffffffc0201dea:	8522                	mv	a0,s0
ffffffffc0201dec:	6442                	ld	s0,16(sp)
ffffffffc0201dee:	64a2                	ld	s1,8(sp)
ffffffffc0201df0:	6902                	ld	s2,0(sp)
ffffffffc0201df2:	6105                	addi	sp,sp,32
ffffffffc0201df4:	8082                	ret
        intr_disable();
ffffffffc0201df6:	bbffe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201dfa:	000c8797          	auipc	a5,0xc8
ffffffffc0201dfe:	fde78793          	addi	a5,a5,-34 # ffffffffc02c9dd8 <bigblocks>
ffffffffc0201e02:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201e04:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201e06:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201e08:	ba7fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
		return bb->pages;
ffffffffc0201e0c:	6480                	ld	s0,8(s1)
}
ffffffffc0201e0e:	60e2                	ld	ra,24(sp)
ffffffffc0201e10:	64a2                	ld	s1,8(sp)
ffffffffc0201e12:	8522                	mv	a0,s0
ffffffffc0201e14:	6442                	ld	s0,16(sp)
ffffffffc0201e16:	6902                	ld	s2,0(sp)
ffffffffc0201e18:	6105                	addi	sp,sp,32
ffffffffc0201e1a:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e1c:	45e1                	li	a1,24
ffffffffc0201e1e:	8526                	mv	a0,s1
ffffffffc0201e20:	d25ff0ef          	jal	ra,ffffffffc0201b44 <slob_free>
	return __kmalloc(size, 0);
ffffffffc0201e24:	b765                	j	ffffffffc0201dcc <kmalloc+0x56>

ffffffffc0201e26 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201e26:	c169                	beqz	a0,ffffffffc0201ee8 <kfree+0xc2>
{
ffffffffc0201e28:	1101                	addi	sp,sp,-32
ffffffffc0201e2a:	e822                	sd	s0,16(sp)
ffffffffc0201e2c:	ec06                	sd	ra,24(sp)
ffffffffc0201e2e:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201e30:	03451793          	slli	a5,a0,0x34
ffffffffc0201e34:	842a                	mv	s0,a0
ffffffffc0201e36:	e3d9                	bnez	a5,ffffffffc0201ebc <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e38:	100027f3          	csrr	a5,sstatus
ffffffffc0201e3c:	8b89                	andi	a5,a5,2
ffffffffc0201e3e:	e7d9                	bnez	a5,ffffffffc0201ecc <kfree+0xa6>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201e40:	000c8797          	auipc	a5,0xc8
ffffffffc0201e44:	f987b783          	ld	a5,-104(a5) # ffffffffc02c9dd8 <bigblocks>
    return 0;
ffffffffc0201e48:	4601                	li	a2,0
ffffffffc0201e4a:	cbad                	beqz	a5,ffffffffc0201ebc <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201e4c:	000c8697          	auipc	a3,0xc8
ffffffffc0201e50:	f8c68693          	addi	a3,a3,-116 # ffffffffc02c9dd8 <bigblocks>
ffffffffc0201e54:	a021                	j	ffffffffc0201e5c <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201e56:	01048693          	addi	a3,s1,16
ffffffffc0201e5a:	c3a5                	beqz	a5,ffffffffc0201eba <kfree+0x94>
		{
			if (bb->pages == block)
ffffffffc0201e5c:	6798                	ld	a4,8(a5)
ffffffffc0201e5e:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc0201e60:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201e62:	fe871ae3          	bne	a4,s0,ffffffffc0201e56 <kfree+0x30>
				*last = bb->next;
ffffffffc0201e66:	e29c                	sd	a5,0(a3)
    if (flag)
ffffffffc0201e68:	ee2d                	bnez	a2,ffffffffc0201ee2 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201e6a:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201e6e:	4098                	lw	a4,0(s1)
ffffffffc0201e70:	08f46963          	bltu	s0,a5,ffffffffc0201f02 <kfree+0xdc>
ffffffffc0201e74:	000c8697          	auipc	a3,0xc8
ffffffffc0201e78:	f946b683          	ld	a3,-108(a3) # ffffffffc02c9e08 <va_pa_offset>
ffffffffc0201e7c:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc0201e7e:	8031                	srli	s0,s0,0xc
ffffffffc0201e80:	000c8797          	auipc	a5,0xc8
ffffffffc0201e84:	f707b783          	ld	a5,-144(a5) # ffffffffc02c9df0 <npage>
ffffffffc0201e88:	06f47163          	bgeu	s0,a5,ffffffffc0201eea <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e8c:	00006517          	auipc	a0,0x6
ffffffffc0201e90:	d1453503          	ld	a0,-748(a0) # ffffffffc0207ba0 <nbase>
ffffffffc0201e94:	8c09                	sub	s0,s0,a0
ffffffffc0201e96:	041a                	slli	s0,s0,0x6
	free_pages(kva2page((void *)kva), 1 << order);
ffffffffc0201e98:	000c8517          	auipc	a0,0xc8
ffffffffc0201e9c:	f6053503          	ld	a0,-160(a0) # ffffffffc02c9df8 <pages>
ffffffffc0201ea0:	4585                	li	a1,1
ffffffffc0201ea2:	9522                	add	a0,a0,s0
ffffffffc0201ea4:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201ea8:	0ea000ef          	jal	ra,ffffffffc0201f92 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201eac:	6442                	ld	s0,16(sp)
ffffffffc0201eae:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201eb0:	8526                	mv	a0,s1
}
ffffffffc0201eb2:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201eb4:	45e1                	li	a1,24
}
ffffffffc0201eb6:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201eb8:	b171                	j	ffffffffc0201b44 <slob_free>
ffffffffc0201eba:	e20d                	bnez	a2,ffffffffc0201edc <kfree+0xb6>
ffffffffc0201ebc:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201ec0:	6442                	ld	s0,16(sp)
ffffffffc0201ec2:	60e2                	ld	ra,24(sp)
ffffffffc0201ec4:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201ec6:	4581                	li	a1,0
}
ffffffffc0201ec8:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201eca:	b9ad                	j	ffffffffc0201b44 <slob_free>
        intr_disable();
ffffffffc0201ecc:	ae9fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201ed0:	000c8797          	auipc	a5,0xc8
ffffffffc0201ed4:	f087b783          	ld	a5,-248(a5) # ffffffffc02c9dd8 <bigblocks>
        return 1;
ffffffffc0201ed8:	4605                	li	a2,1
ffffffffc0201eda:	fbad                	bnez	a5,ffffffffc0201e4c <kfree+0x26>
        intr_enable();
ffffffffc0201edc:	ad3fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201ee0:	bff1                	j	ffffffffc0201ebc <kfree+0x96>
ffffffffc0201ee2:	acdfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201ee6:	b751                	j	ffffffffc0201e6a <kfree+0x44>
ffffffffc0201ee8:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201eea:	00005617          	auipc	a2,0x5
ffffffffc0201eee:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0206978 <default_pmm_manager+0x108>
ffffffffc0201ef2:	06900593          	li	a1,105
ffffffffc0201ef6:	00005517          	auipc	a0,0x5
ffffffffc0201efa:	9da50513          	addi	a0,a0,-1574 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc0201efe:	d90fe0ef          	jal	ra,ffffffffc020048e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201f02:	86a2                	mv	a3,s0
ffffffffc0201f04:	00005617          	auipc	a2,0x5
ffffffffc0201f08:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0206950 <default_pmm_manager+0xe0>
ffffffffc0201f0c:	07700593          	li	a1,119
ffffffffc0201f10:	00005517          	auipc	a0,0x5
ffffffffc0201f14:	9c050513          	addi	a0,a0,-1600 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc0201f18:	d76fe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201f1c <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201f1c:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201f1e:	00005617          	auipc	a2,0x5
ffffffffc0201f22:	a5a60613          	addi	a2,a2,-1446 # ffffffffc0206978 <default_pmm_manager+0x108>
ffffffffc0201f26:	06900593          	li	a1,105
ffffffffc0201f2a:	00005517          	auipc	a0,0x5
ffffffffc0201f2e:	9a650513          	addi	a0,a0,-1626 # ffffffffc02068d0 <default_pmm_manager+0x60>
pa2page(uintptr_t pa)
ffffffffc0201f32:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201f34:	d5afe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201f38 <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc0201f38:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201f3a:	00005617          	auipc	a2,0x5
ffffffffc0201f3e:	a5e60613          	addi	a2,a2,-1442 # ffffffffc0206998 <default_pmm_manager+0x128>
ffffffffc0201f42:	07f00593          	li	a1,127
ffffffffc0201f46:	00005517          	auipc	a0,0x5
ffffffffc0201f4a:	98a50513          	addi	a0,a0,-1654 # ffffffffc02068d0 <default_pmm_manager+0x60>
pte2page(pte_t pte)
ffffffffc0201f4e:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201f50:	d3efe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0201f54 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201f54:	100027f3          	csrr	a5,sstatus
ffffffffc0201f58:	8b89                	andi	a5,a5,2
ffffffffc0201f5a:	e799                	bnez	a5,ffffffffc0201f68 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f5c:	000c8797          	auipc	a5,0xc8
ffffffffc0201f60:	ea47b783          	ld	a5,-348(a5) # ffffffffc02c9e00 <pmm_manager>
ffffffffc0201f64:	6f9c                	ld	a5,24(a5)
ffffffffc0201f66:	8782                	jr	a5
{
ffffffffc0201f68:	1141                	addi	sp,sp,-16
ffffffffc0201f6a:	e406                	sd	ra,8(sp)
ffffffffc0201f6c:	e022                	sd	s0,0(sp)
ffffffffc0201f6e:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201f70:	a45fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f74:	000c8797          	auipc	a5,0xc8
ffffffffc0201f78:	e8c7b783          	ld	a5,-372(a5) # ffffffffc02c9e00 <pmm_manager>
ffffffffc0201f7c:	6f9c                	ld	a5,24(a5)
ffffffffc0201f7e:	8522                	mv	a0,s0
ffffffffc0201f80:	9782                	jalr	a5
ffffffffc0201f82:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f84:	a2bfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201f88:	60a2                	ld	ra,8(sp)
ffffffffc0201f8a:	8522                	mv	a0,s0
ffffffffc0201f8c:	6402                	ld	s0,0(sp)
ffffffffc0201f8e:	0141                	addi	sp,sp,16
ffffffffc0201f90:	8082                	ret

ffffffffc0201f92 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201f92:	100027f3          	csrr	a5,sstatus
ffffffffc0201f96:	8b89                	andi	a5,a5,2
ffffffffc0201f98:	e799                	bnez	a5,ffffffffc0201fa6 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201f9a:	000c8797          	auipc	a5,0xc8
ffffffffc0201f9e:	e667b783          	ld	a5,-410(a5) # ffffffffc02c9e00 <pmm_manager>
ffffffffc0201fa2:	739c                	ld	a5,32(a5)
ffffffffc0201fa4:	8782                	jr	a5
{
ffffffffc0201fa6:	1101                	addi	sp,sp,-32
ffffffffc0201fa8:	ec06                	sd	ra,24(sp)
ffffffffc0201faa:	e822                	sd	s0,16(sp)
ffffffffc0201fac:	e426                	sd	s1,8(sp)
ffffffffc0201fae:	842a                	mv	s0,a0
ffffffffc0201fb0:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201fb2:	a03fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201fb6:	000c8797          	auipc	a5,0xc8
ffffffffc0201fba:	e4a7b783          	ld	a5,-438(a5) # ffffffffc02c9e00 <pmm_manager>
ffffffffc0201fbe:	739c                	ld	a5,32(a5)
ffffffffc0201fc0:	85a6                	mv	a1,s1
ffffffffc0201fc2:	8522                	mv	a0,s0
ffffffffc0201fc4:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201fc6:	6442                	ld	s0,16(sp)
ffffffffc0201fc8:	60e2                	ld	ra,24(sp)
ffffffffc0201fca:	64a2                	ld	s1,8(sp)
ffffffffc0201fcc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201fce:	9e1fe06f          	j	ffffffffc02009ae <intr_enable>

ffffffffc0201fd2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201fd2:	100027f3          	csrr	a5,sstatus
ffffffffc0201fd6:	8b89                	andi	a5,a5,2
ffffffffc0201fd8:	e799                	bnez	a5,ffffffffc0201fe6 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201fda:	000c8797          	auipc	a5,0xc8
ffffffffc0201fde:	e267b783          	ld	a5,-474(a5) # ffffffffc02c9e00 <pmm_manager>
ffffffffc0201fe2:	779c                	ld	a5,40(a5)
ffffffffc0201fe4:	8782                	jr	a5
{
ffffffffc0201fe6:	1141                	addi	sp,sp,-16
ffffffffc0201fe8:	e406                	sd	ra,8(sp)
ffffffffc0201fea:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201fec:	9c9fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201ff0:	000c8797          	auipc	a5,0xc8
ffffffffc0201ff4:	e107b783          	ld	a5,-496(a5) # ffffffffc02c9e00 <pmm_manager>
ffffffffc0201ff8:	779c                	ld	a5,40(a5)
ffffffffc0201ffa:	9782                	jalr	a5
ffffffffc0201ffc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201ffe:	9b1fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202002:	60a2                	ld	ra,8(sp)
ffffffffc0202004:	8522                	mv	a0,s0
ffffffffc0202006:	6402                	ld	s0,0(sp)
ffffffffc0202008:	0141                	addi	sp,sp,16
ffffffffc020200a:	8082                	ret

ffffffffc020200c <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020200c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202010:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0202014:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202016:	078e                	slli	a5,a5,0x3
{
ffffffffc0202018:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020201a:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc020201e:	6094                	ld	a3,0(s1)
{
ffffffffc0202020:	f04a                	sd	s2,32(sp)
ffffffffc0202022:	ec4e                	sd	s3,24(sp)
ffffffffc0202024:	e852                	sd	s4,16(sp)
ffffffffc0202026:	fc06                	sd	ra,56(sp)
ffffffffc0202028:	f822                	sd	s0,48(sp)
ffffffffc020202a:	e456                	sd	s5,8(sp)
ffffffffc020202c:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc020202e:	0016f793          	andi	a5,a3,1
{
ffffffffc0202032:	892e                	mv	s2,a1
ffffffffc0202034:	8a32                	mv	s4,a2
ffffffffc0202036:	000c8997          	auipc	s3,0xc8
ffffffffc020203a:	dba98993          	addi	s3,s3,-582 # ffffffffc02c9df0 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc020203e:	efbd                	bnez	a5,ffffffffc02020bc <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202040:	14060c63          	beqz	a2,ffffffffc0202198 <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202044:	100027f3          	csrr	a5,sstatus
ffffffffc0202048:	8b89                	andi	a5,a5,2
ffffffffc020204a:	14079963          	bnez	a5,ffffffffc020219c <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc020204e:	000c8797          	auipc	a5,0xc8
ffffffffc0202052:	db27b783          	ld	a5,-590(a5) # ffffffffc02c9e00 <pmm_manager>
ffffffffc0202056:	6f9c                	ld	a5,24(a5)
ffffffffc0202058:	4505                	li	a0,1
ffffffffc020205a:	9782                	jalr	a5
ffffffffc020205c:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc020205e:	12040d63          	beqz	s0,ffffffffc0202198 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0202062:	000c8b17          	auipc	s6,0xc8
ffffffffc0202066:	d96b0b13          	addi	s6,s6,-618 # ffffffffc02c9df8 <pages>
ffffffffc020206a:	000b3503          	ld	a0,0(s6)
ffffffffc020206e:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202072:	000c8997          	auipc	s3,0xc8
ffffffffc0202076:	d7e98993          	addi	s3,s3,-642 # ffffffffc02c9df0 <npage>
ffffffffc020207a:	40a40533          	sub	a0,s0,a0
ffffffffc020207e:	8519                	srai	a0,a0,0x6
ffffffffc0202080:	9556                	add	a0,a0,s5
ffffffffc0202082:	0009b703          	ld	a4,0(s3)
ffffffffc0202086:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc020208a:	4685                	li	a3,1
ffffffffc020208c:	c014                	sw	a3,0(s0)
ffffffffc020208e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202090:	0532                	slli	a0,a0,0xc
ffffffffc0202092:	16e7f763          	bgeu	a5,a4,ffffffffc0202200 <get_pte+0x1f4>
ffffffffc0202096:	000c8797          	auipc	a5,0xc8
ffffffffc020209a:	d727b783          	ld	a5,-654(a5) # ffffffffc02c9e08 <va_pa_offset>
ffffffffc020209e:	6605                	lui	a2,0x1
ffffffffc02020a0:	4581                	li	a1,0
ffffffffc02020a2:	953e                	add	a0,a0,a5
ffffffffc02020a4:	12f030ef          	jal	ra,ffffffffc02059d2 <memset>
    return page - pages + nbase;
ffffffffc02020a8:	000b3683          	ld	a3,0(s6)
ffffffffc02020ac:	40d406b3          	sub	a3,s0,a3
ffffffffc02020b0:	8699                	srai	a3,a3,0x6
ffffffffc02020b2:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02020b4:	06aa                	slli	a3,a3,0xa
ffffffffc02020b6:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02020ba:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020bc:	77fd                	lui	a5,0xfffff
ffffffffc02020be:	068a                	slli	a3,a3,0x2
ffffffffc02020c0:	0009b703          	ld	a4,0(s3)
ffffffffc02020c4:	8efd                	and	a3,a3,a5
ffffffffc02020c6:	00c6d793          	srli	a5,a3,0xc
ffffffffc02020ca:	10e7ff63          	bgeu	a5,a4,ffffffffc02021e8 <get_pte+0x1dc>
ffffffffc02020ce:	000c8a97          	auipc	s5,0xc8
ffffffffc02020d2:	d3aa8a93          	addi	s5,s5,-710 # ffffffffc02c9e08 <va_pa_offset>
ffffffffc02020d6:	000ab403          	ld	s0,0(s5)
ffffffffc02020da:	01595793          	srli	a5,s2,0x15
ffffffffc02020de:	1ff7f793          	andi	a5,a5,511
ffffffffc02020e2:	96a2                	add	a3,a3,s0
ffffffffc02020e4:	00379413          	slli	s0,a5,0x3
ffffffffc02020e8:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc02020ea:	6014                	ld	a3,0(s0)
ffffffffc02020ec:	0016f793          	andi	a5,a3,1
ffffffffc02020f0:	ebad                	bnez	a5,ffffffffc0202162 <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02020f2:	0a0a0363          	beqz	s4,ffffffffc0202198 <get_pte+0x18c>
ffffffffc02020f6:	100027f3          	csrr	a5,sstatus
ffffffffc02020fa:	8b89                	andi	a5,a5,2
ffffffffc02020fc:	efcd                	bnez	a5,ffffffffc02021b6 <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc02020fe:	000c8797          	auipc	a5,0xc8
ffffffffc0202102:	d027b783          	ld	a5,-766(a5) # ffffffffc02c9e00 <pmm_manager>
ffffffffc0202106:	6f9c                	ld	a5,24(a5)
ffffffffc0202108:	4505                	li	a0,1
ffffffffc020210a:	9782                	jalr	a5
ffffffffc020210c:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc020210e:	c4c9                	beqz	s1,ffffffffc0202198 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0202110:	000c8b17          	auipc	s6,0xc8
ffffffffc0202114:	ce8b0b13          	addi	s6,s6,-792 # ffffffffc02c9df8 <pages>
ffffffffc0202118:	000b3503          	ld	a0,0(s6)
ffffffffc020211c:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202120:	0009b703          	ld	a4,0(s3)
ffffffffc0202124:	40a48533          	sub	a0,s1,a0
ffffffffc0202128:	8519                	srai	a0,a0,0x6
ffffffffc020212a:	9552                	add	a0,a0,s4
ffffffffc020212c:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202130:	4685                	li	a3,1
ffffffffc0202132:	c094                	sw	a3,0(s1)
ffffffffc0202134:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202136:	0532                	slli	a0,a0,0xc
ffffffffc0202138:	0ee7f163          	bgeu	a5,a4,ffffffffc020221a <get_pte+0x20e>
ffffffffc020213c:	000ab783          	ld	a5,0(s5)
ffffffffc0202140:	6605                	lui	a2,0x1
ffffffffc0202142:	4581                	li	a1,0
ffffffffc0202144:	953e                	add	a0,a0,a5
ffffffffc0202146:	08d030ef          	jal	ra,ffffffffc02059d2 <memset>
    return page - pages + nbase;
ffffffffc020214a:	000b3683          	ld	a3,0(s6)
ffffffffc020214e:	40d486b3          	sub	a3,s1,a3
ffffffffc0202152:	8699                	srai	a3,a3,0x6
ffffffffc0202154:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202156:	06aa                	slli	a3,a3,0xa
ffffffffc0202158:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020215c:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020215e:	0009b703          	ld	a4,0(s3)
ffffffffc0202162:	068a                	slli	a3,a3,0x2
ffffffffc0202164:	757d                	lui	a0,0xfffff
ffffffffc0202166:	8ee9                	and	a3,a3,a0
ffffffffc0202168:	00c6d793          	srli	a5,a3,0xc
ffffffffc020216c:	06e7f263          	bgeu	a5,a4,ffffffffc02021d0 <get_pte+0x1c4>
ffffffffc0202170:	000ab503          	ld	a0,0(s5)
ffffffffc0202174:	00c95913          	srli	s2,s2,0xc
ffffffffc0202178:	1ff97913          	andi	s2,s2,511
ffffffffc020217c:	96aa                	add	a3,a3,a0
ffffffffc020217e:	00391513          	slli	a0,s2,0x3
ffffffffc0202182:	9536                	add	a0,a0,a3
}
ffffffffc0202184:	70e2                	ld	ra,56(sp)
ffffffffc0202186:	7442                	ld	s0,48(sp)
ffffffffc0202188:	74a2                	ld	s1,40(sp)
ffffffffc020218a:	7902                	ld	s2,32(sp)
ffffffffc020218c:	69e2                	ld	s3,24(sp)
ffffffffc020218e:	6a42                	ld	s4,16(sp)
ffffffffc0202190:	6aa2                	ld	s5,8(sp)
ffffffffc0202192:	6b02                	ld	s6,0(sp)
ffffffffc0202194:	6121                	addi	sp,sp,64
ffffffffc0202196:	8082                	ret
            return NULL;
ffffffffc0202198:	4501                	li	a0,0
ffffffffc020219a:	b7ed                	j	ffffffffc0202184 <get_pte+0x178>
        intr_disable();
ffffffffc020219c:	819fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02021a0:	000c8797          	auipc	a5,0xc8
ffffffffc02021a4:	c607b783          	ld	a5,-928(a5) # ffffffffc02c9e00 <pmm_manager>
ffffffffc02021a8:	6f9c                	ld	a5,24(a5)
ffffffffc02021aa:	4505                	li	a0,1
ffffffffc02021ac:	9782                	jalr	a5
ffffffffc02021ae:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02021b0:	ffefe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02021b4:	b56d                	j	ffffffffc020205e <get_pte+0x52>
        intr_disable();
ffffffffc02021b6:	ffefe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02021ba:	000c8797          	auipc	a5,0xc8
ffffffffc02021be:	c467b783          	ld	a5,-954(a5) # ffffffffc02c9e00 <pmm_manager>
ffffffffc02021c2:	6f9c                	ld	a5,24(a5)
ffffffffc02021c4:	4505                	li	a0,1
ffffffffc02021c6:	9782                	jalr	a5
ffffffffc02021c8:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc02021ca:	fe4fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02021ce:	b781                	j	ffffffffc020210e <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02021d0:	00004617          	auipc	a2,0x4
ffffffffc02021d4:	6d860613          	addi	a2,a2,1752 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc02021d8:	0fa00593          	li	a1,250
ffffffffc02021dc:	00004517          	auipc	a0,0x4
ffffffffc02021e0:	7e450513          	addi	a0,a0,2020 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02021e4:	aaafe0ef          	jal	ra,ffffffffc020048e <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02021e8:	00004617          	auipc	a2,0x4
ffffffffc02021ec:	6c060613          	addi	a2,a2,1728 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc02021f0:	0ed00593          	li	a1,237
ffffffffc02021f4:	00004517          	auipc	a0,0x4
ffffffffc02021f8:	7cc50513          	addi	a0,a0,1996 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02021fc:	a92fe0ef          	jal	ra,ffffffffc020048e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202200:	86aa                	mv	a3,a0
ffffffffc0202202:	00004617          	auipc	a2,0x4
ffffffffc0202206:	6a660613          	addi	a2,a2,1702 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc020220a:	0e900593          	li	a1,233
ffffffffc020220e:	00004517          	auipc	a0,0x4
ffffffffc0202212:	7b250513          	addi	a0,a0,1970 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0202216:	a78fe0ef          	jal	ra,ffffffffc020048e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020221a:	86aa                	mv	a3,a0
ffffffffc020221c:	00004617          	auipc	a2,0x4
ffffffffc0202220:	68c60613          	addi	a2,a2,1676 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc0202224:	0f700593          	li	a1,247
ffffffffc0202228:	00004517          	auipc	a0,0x4
ffffffffc020222c:	79850513          	addi	a0,a0,1944 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0202230:	a5efe0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0202234 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0202234:	1141                	addi	sp,sp,-16
ffffffffc0202236:	e022                	sd	s0,0(sp)
ffffffffc0202238:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020223a:	4601                	li	a2,0
{
ffffffffc020223c:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020223e:	dcfff0ef          	jal	ra,ffffffffc020200c <get_pte>
    if (ptep_store != NULL)
ffffffffc0202242:	c011                	beqz	s0,ffffffffc0202246 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0202244:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202246:	c511                	beqz	a0,ffffffffc0202252 <get_page+0x1e>
ffffffffc0202248:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020224a:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020224c:	0017f713          	andi	a4,a5,1
ffffffffc0202250:	e709                	bnez	a4,ffffffffc020225a <get_page+0x26>
}
ffffffffc0202252:	60a2                	ld	ra,8(sp)
ffffffffc0202254:	6402                	ld	s0,0(sp)
ffffffffc0202256:	0141                	addi	sp,sp,16
ffffffffc0202258:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020225a:	078a                	slli	a5,a5,0x2
ffffffffc020225c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020225e:	000c8717          	auipc	a4,0xc8
ffffffffc0202262:	b9273703          	ld	a4,-1134(a4) # ffffffffc02c9df0 <npage>
ffffffffc0202266:	00e7ff63          	bgeu	a5,a4,ffffffffc0202284 <get_page+0x50>
ffffffffc020226a:	60a2                	ld	ra,8(sp)
ffffffffc020226c:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc020226e:	fff80537          	lui	a0,0xfff80
ffffffffc0202272:	97aa                	add	a5,a5,a0
ffffffffc0202274:	079a                	slli	a5,a5,0x6
ffffffffc0202276:	000c8517          	auipc	a0,0xc8
ffffffffc020227a:	b8253503          	ld	a0,-1150(a0) # ffffffffc02c9df8 <pages>
ffffffffc020227e:	953e                	add	a0,a0,a5
ffffffffc0202280:	0141                	addi	sp,sp,16
ffffffffc0202282:	8082                	ret
ffffffffc0202284:	c99ff0ef          	jal	ra,ffffffffc0201f1c <pa2page.part.0>

ffffffffc0202288 <unmap_range>:
        tlb_invalidate(pgdir, la);
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0202288:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020228a:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc020228e:	f486                	sd	ra,104(sp)
ffffffffc0202290:	f0a2                	sd	s0,96(sp)
ffffffffc0202292:	eca6                	sd	s1,88(sp)
ffffffffc0202294:	e8ca                	sd	s2,80(sp)
ffffffffc0202296:	e4ce                	sd	s3,72(sp)
ffffffffc0202298:	e0d2                	sd	s4,64(sp)
ffffffffc020229a:	fc56                	sd	s5,56(sp)
ffffffffc020229c:	f85a                	sd	s6,48(sp)
ffffffffc020229e:	f45e                	sd	s7,40(sp)
ffffffffc02022a0:	f062                	sd	s8,32(sp)
ffffffffc02022a2:	ec66                	sd	s9,24(sp)
ffffffffc02022a4:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022a6:	17d2                	slli	a5,a5,0x34
ffffffffc02022a8:	e3ed                	bnez	a5,ffffffffc020238a <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc02022aa:	002007b7          	lui	a5,0x200
ffffffffc02022ae:	842e                	mv	s0,a1
ffffffffc02022b0:	0ef5ed63          	bltu	a1,a5,ffffffffc02023aa <unmap_range+0x122>
ffffffffc02022b4:	8932                	mv	s2,a2
ffffffffc02022b6:	0ec5fa63          	bgeu	a1,a2,ffffffffc02023aa <unmap_range+0x122>
ffffffffc02022ba:	4785                	li	a5,1
ffffffffc02022bc:	07fe                	slli	a5,a5,0x1f
ffffffffc02022be:	0ec7e663          	bltu	a5,a2,ffffffffc02023aa <unmap_range+0x122>
ffffffffc02022c2:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02022c4:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc02022c6:	000c8c97          	auipc	s9,0xc8
ffffffffc02022ca:	b2ac8c93          	addi	s9,s9,-1238 # ffffffffc02c9df0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02022ce:	000c8c17          	auipc	s8,0xc8
ffffffffc02022d2:	b2ac0c13          	addi	s8,s8,-1238 # ffffffffc02c9df8 <pages>
ffffffffc02022d6:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc02022da:	000c8d17          	auipc	s10,0xc8
ffffffffc02022de:	b26d0d13          	addi	s10,s10,-1242 # ffffffffc02c9e00 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02022e2:	00200b37          	lui	s6,0x200
ffffffffc02022e6:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02022ea:	4601                	li	a2,0
ffffffffc02022ec:	85a2                	mv	a1,s0
ffffffffc02022ee:	854e                	mv	a0,s3
ffffffffc02022f0:	d1dff0ef          	jal	ra,ffffffffc020200c <get_pte>
ffffffffc02022f4:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc02022f6:	cd29                	beqz	a0,ffffffffc0202350 <unmap_range+0xc8>
        if (*ptep != 0)
ffffffffc02022f8:	611c                	ld	a5,0(a0)
ffffffffc02022fa:	e395                	bnez	a5,ffffffffc020231e <unmap_range+0x96>
        start += PGSIZE;
ffffffffc02022fc:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02022fe:	ff2466e3          	bltu	s0,s2,ffffffffc02022ea <unmap_range+0x62>
}
ffffffffc0202302:	70a6                	ld	ra,104(sp)
ffffffffc0202304:	7406                	ld	s0,96(sp)
ffffffffc0202306:	64e6                	ld	s1,88(sp)
ffffffffc0202308:	6946                	ld	s2,80(sp)
ffffffffc020230a:	69a6                	ld	s3,72(sp)
ffffffffc020230c:	6a06                	ld	s4,64(sp)
ffffffffc020230e:	7ae2                	ld	s5,56(sp)
ffffffffc0202310:	7b42                	ld	s6,48(sp)
ffffffffc0202312:	7ba2                	ld	s7,40(sp)
ffffffffc0202314:	7c02                	ld	s8,32(sp)
ffffffffc0202316:	6ce2                	ld	s9,24(sp)
ffffffffc0202318:	6d42                	ld	s10,16(sp)
ffffffffc020231a:	6165                	addi	sp,sp,112
ffffffffc020231c:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc020231e:	0017f713          	andi	a4,a5,1
ffffffffc0202322:	df69                	beqz	a4,ffffffffc02022fc <unmap_range+0x74>
    if (PPN(pa) >= npage)
ffffffffc0202324:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202328:	078a                	slli	a5,a5,0x2
ffffffffc020232a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020232c:	08e7ff63          	bgeu	a5,a4,ffffffffc02023ca <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0202330:	000c3503          	ld	a0,0(s8)
ffffffffc0202334:	97de                	add	a5,a5,s7
ffffffffc0202336:	079a                	slli	a5,a5,0x6
ffffffffc0202338:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020233a:	411c                	lw	a5,0(a0)
ffffffffc020233c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202340:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc0202342:	cf11                	beqz	a4,ffffffffc020235e <unmap_range+0xd6>
        *ptep = 0;
ffffffffc0202344:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202348:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020234c:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020234e:	bf45                	j	ffffffffc02022fe <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202350:	945a                	add	s0,s0,s6
ffffffffc0202352:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202356:	d455                	beqz	s0,ffffffffc0202302 <unmap_range+0x7a>
ffffffffc0202358:	f92469e3          	bltu	s0,s2,ffffffffc02022ea <unmap_range+0x62>
ffffffffc020235c:	b75d                	j	ffffffffc0202302 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020235e:	100027f3          	csrr	a5,sstatus
ffffffffc0202362:	8b89                	andi	a5,a5,2
ffffffffc0202364:	e799                	bnez	a5,ffffffffc0202372 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc0202366:	000d3783          	ld	a5,0(s10)
ffffffffc020236a:	4585                	li	a1,1
ffffffffc020236c:	739c                	ld	a5,32(a5)
ffffffffc020236e:	9782                	jalr	a5
    if (flag)
ffffffffc0202370:	bfd1                	j	ffffffffc0202344 <unmap_range+0xbc>
ffffffffc0202372:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202374:	e40fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202378:	000d3783          	ld	a5,0(s10)
ffffffffc020237c:	6522                	ld	a0,8(sp)
ffffffffc020237e:	4585                	li	a1,1
ffffffffc0202380:	739c                	ld	a5,32(a5)
ffffffffc0202382:	9782                	jalr	a5
        intr_enable();
ffffffffc0202384:	e2afe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202388:	bf75                	j	ffffffffc0202344 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020238a:	00004697          	auipc	a3,0x4
ffffffffc020238e:	64668693          	addi	a3,a3,1606 # ffffffffc02069d0 <default_pmm_manager+0x160>
ffffffffc0202392:	00004617          	auipc	a2,0x4
ffffffffc0202396:	12e60613          	addi	a2,a2,302 # ffffffffc02064c0 <commands+0x858>
ffffffffc020239a:	12000593          	li	a1,288
ffffffffc020239e:	00004517          	auipc	a0,0x4
ffffffffc02023a2:	62250513          	addi	a0,a0,1570 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02023a6:	8e8fe0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02023aa:	00004697          	auipc	a3,0x4
ffffffffc02023ae:	65668693          	addi	a3,a3,1622 # ffffffffc0206a00 <default_pmm_manager+0x190>
ffffffffc02023b2:	00004617          	auipc	a2,0x4
ffffffffc02023b6:	10e60613          	addi	a2,a2,270 # ffffffffc02064c0 <commands+0x858>
ffffffffc02023ba:	12100593          	li	a1,289
ffffffffc02023be:	00004517          	auipc	a0,0x4
ffffffffc02023c2:	60250513          	addi	a0,a0,1538 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02023c6:	8c8fe0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc02023ca:	b53ff0ef          	jal	ra,ffffffffc0201f1c <pa2page.part.0>

ffffffffc02023ce <exit_range>:
{
ffffffffc02023ce:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02023d0:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc02023d4:	fc86                	sd	ra,120(sp)
ffffffffc02023d6:	f8a2                	sd	s0,112(sp)
ffffffffc02023d8:	f4a6                	sd	s1,104(sp)
ffffffffc02023da:	f0ca                	sd	s2,96(sp)
ffffffffc02023dc:	ecce                	sd	s3,88(sp)
ffffffffc02023de:	e8d2                	sd	s4,80(sp)
ffffffffc02023e0:	e4d6                	sd	s5,72(sp)
ffffffffc02023e2:	e0da                	sd	s6,64(sp)
ffffffffc02023e4:	fc5e                	sd	s7,56(sp)
ffffffffc02023e6:	f862                	sd	s8,48(sp)
ffffffffc02023e8:	f466                	sd	s9,40(sp)
ffffffffc02023ea:	f06a                	sd	s10,32(sp)
ffffffffc02023ec:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02023ee:	17d2                	slli	a5,a5,0x34
ffffffffc02023f0:	20079a63          	bnez	a5,ffffffffc0202604 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc02023f4:	002007b7          	lui	a5,0x200
ffffffffc02023f8:	24f5e463          	bltu	a1,a5,ffffffffc0202640 <exit_range+0x272>
ffffffffc02023fc:	8ab2                	mv	s5,a2
ffffffffc02023fe:	24c5f163          	bgeu	a1,a2,ffffffffc0202640 <exit_range+0x272>
ffffffffc0202402:	4785                	li	a5,1
ffffffffc0202404:	07fe                	slli	a5,a5,0x1f
ffffffffc0202406:	22c7ed63          	bltu	a5,a2,ffffffffc0202640 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020240a:	c00009b7          	lui	s3,0xc0000
ffffffffc020240e:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202412:	ffe00937          	lui	s2,0xffe00
ffffffffc0202416:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc020241a:	5cfd                	li	s9,-1
ffffffffc020241c:	8c2a                	mv	s8,a0
ffffffffc020241e:	0125f933          	and	s2,a1,s2
ffffffffc0202422:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage)
ffffffffc0202424:	000c8d17          	auipc	s10,0xc8
ffffffffc0202428:	9ccd0d13          	addi	s10,s10,-1588 # ffffffffc02c9df0 <npage>
    return KADDR(page2pa(page));
ffffffffc020242c:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202430:	000c8717          	auipc	a4,0xc8
ffffffffc0202434:	9c870713          	addi	a4,a4,-1592 # ffffffffc02c9df8 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc0202438:	000c8d97          	auipc	s11,0xc8
ffffffffc020243c:	9c8d8d93          	addi	s11,s11,-1592 # ffffffffc02c9e00 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202440:	c0000437          	lui	s0,0xc0000
ffffffffc0202444:	944e                	add	s0,s0,s3
ffffffffc0202446:	8079                	srli	s0,s0,0x1e
ffffffffc0202448:	1ff47413          	andi	s0,s0,511
ffffffffc020244c:	040e                	slli	s0,s0,0x3
ffffffffc020244e:	9462                	add	s0,s0,s8
ffffffffc0202450:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4e38>
        if (pde1 & PTE_V)
ffffffffc0202454:	001a7793          	andi	a5,s4,1
ffffffffc0202458:	eb99                	bnez	a5,ffffffffc020246e <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc020245a:	12098463          	beqz	s3,ffffffffc0202582 <exit_range+0x1b4>
ffffffffc020245e:	400007b7          	lui	a5,0x40000
ffffffffc0202462:	97ce                	add	a5,a5,s3
ffffffffc0202464:	894e                	mv	s2,s3
ffffffffc0202466:	1159fe63          	bgeu	s3,s5,ffffffffc0202582 <exit_range+0x1b4>
ffffffffc020246a:	89be                	mv	s3,a5
ffffffffc020246c:	bfd1                	j	ffffffffc0202440 <exit_range+0x72>
    if (PPN(pa) >= npage)
ffffffffc020246e:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202472:	0a0a                	slli	s4,s4,0x2
ffffffffc0202474:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202478:	1cfa7263          	bgeu	s4,a5,ffffffffc020263c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020247c:	fff80637          	lui	a2,0xfff80
ffffffffc0202480:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0202482:	000806b7          	lui	a3,0x80
ffffffffc0202486:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202488:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc020248c:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020248e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202490:	18f5fa63          	bgeu	a1,a5,ffffffffc0202624 <exit_range+0x256>
ffffffffc0202494:	000c8817          	auipc	a6,0xc8
ffffffffc0202498:	97480813          	addi	a6,a6,-1676 # ffffffffc02c9e08 <va_pa_offset>
ffffffffc020249c:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc02024a0:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc02024a2:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc02024a6:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc02024a8:	00080337          	lui	t1,0x80
ffffffffc02024ac:	6885                	lui	a7,0x1
ffffffffc02024ae:	a819                	j	ffffffffc02024c4 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc02024b0:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc02024b2:	002007b7          	lui	a5,0x200
ffffffffc02024b6:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02024b8:	08090c63          	beqz	s2,ffffffffc0202550 <exit_range+0x182>
ffffffffc02024bc:	09397a63          	bgeu	s2,s3,ffffffffc0202550 <exit_range+0x182>
ffffffffc02024c0:	0f597063          	bgeu	s2,s5,ffffffffc02025a0 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02024c4:	01595493          	srli	s1,s2,0x15
ffffffffc02024c8:	1ff4f493          	andi	s1,s1,511
ffffffffc02024cc:	048e                	slli	s1,s1,0x3
ffffffffc02024ce:	94da                	add	s1,s1,s6
ffffffffc02024d0:	609c                	ld	a5,0(s1)
                if (pde0 & PTE_V)
ffffffffc02024d2:	0017f693          	andi	a3,a5,1
ffffffffc02024d6:	dee9                	beqz	a3,ffffffffc02024b0 <exit_range+0xe2>
    if (PPN(pa) >= npage)
ffffffffc02024d8:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024dc:	078a                	slli	a5,a5,0x2
ffffffffc02024de:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02024e0:	14b7fe63          	bgeu	a5,a1,ffffffffc020263c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02024e4:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc02024e6:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc02024ea:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02024ee:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02024f2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02024f4:	12bef863          	bgeu	t4,a1,ffffffffc0202624 <exit_range+0x256>
ffffffffc02024f8:	00083783          	ld	a5,0(a6)
ffffffffc02024fc:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02024fe:	011685b3          	add	a1,a3,a7
                        if (pt[i] & PTE_V)
ffffffffc0202502:	629c                	ld	a5,0(a3)
ffffffffc0202504:	8b85                	andi	a5,a5,1
ffffffffc0202506:	f7d5                	bnez	a5,ffffffffc02024b2 <exit_range+0xe4>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202508:	06a1                	addi	a3,a3,8
ffffffffc020250a:	fed59ce3          	bne	a1,a3,ffffffffc0202502 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc020250e:	631c                	ld	a5,0(a4)
ffffffffc0202510:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202512:	100027f3          	csrr	a5,sstatus
ffffffffc0202516:	8b89                	andi	a5,a5,2
ffffffffc0202518:	e7d9                	bnez	a5,ffffffffc02025a6 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc020251a:	000db783          	ld	a5,0(s11)
ffffffffc020251e:	4585                	li	a1,1
ffffffffc0202520:	e032                	sd	a2,0(sp)
ffffffffc0202522:	739c                	ld	a5,32(a5)
ffffffffc0202524:	9782                	jalr	a5
    if (flag)
ffffffffc0202526:	6602                	ld	a2,0(sp)
ffffffffc0202528:	000c8817          	auipc	a6,0xc8
ffffffffc020252c:	8e080813          	addi	a6,a6,-1824 # ffffffffc02c9e08 <va_pa_offset>
ffffffffc0202530:	fff80e37          	lui	t3,0xfff80
ffffffffc0202534:	00080337          	lui	t1,0x80
ffffffffc0202538:	6885                	lui	a7,0x1
ffffffffc020253a:	000c8717          	auipc	a4,0xc8
ffffffffc020253e:	8be70713          	addi	a4,a4,-1858 # ffffffffc02c9df8 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202542:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0202546:	002007b7          	lui	a5,0x200
ffffffffc020254a:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc020254c:	f60918e3          	bnez	s2,ffffffffc02024bc <exit_range+0xee>
            if (free_pd0)
ffffffffc0202550:	f00b85e3          	beqz	s7,ffffffffc020245a <exit_range+0x8c>
    if (PPN(pa) >= npage)
ffffffffc0202554:	000d3783          	ld	a5,0(s10)
ffffffffc0202558:	0efa7263          	bgeu	s4,a5,ffffffffc020263c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020255c:	6308                	ld	a0,0(a4)
ffffffffc020255e:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202560:	100027f3          	csrr	a5,sstatus
ffffffffc0202564:	8b89                	andi	a5,a5,2
ffffffffc0202566:	efad                	bnez	a5,ffffffffc02025e0 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc0202568:	000db783          	ld	a5,0(s11)
ffffffffc020256c:	4585                	li	a1,1
ffffffffc020256e:	739c                	ld	a5,32(a5)
ffffffffc0202570:	9782                	jalr	a5
ffffffffc0202572:	000c8717          	auipc	a4,0xc8
ffffffffc0202576:	88670713          	addi	a4,a4,-1914 # ffffffffc02c9df8 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020257a:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc020257e:	ee0990e3          	bnez	s3,ffffffffc020245e <exit_range+0x90>
}
ffffffffc0202582:	70e6                	ld	ra,120(sp)
ffffffffc0202584:	7446                	ld	s0,112(sp)
ffffffffc0202586:	74a6                	ld	s1,104(sp)
ffffffffc0202588:	7906                	ld	s2,96(sp)
ffffffffc020258a:	69e6                	ld	s3,88(sp)
ffffffffc020258c:	6a46                	ld	s4,80(sp)
ffffffffc020258e:	6aa6                	ld	s5,72(sp)
ffffffffc0202590:	6b06                	ld	s6,64(sp)
ffffffffc0202592:	7be2                	ld	s7,56(sp)
ffffffffc0202594:	7c42                	ld	s8,48(sp)
ffffffffc0202596:	7ca2                	ld	s9,40(sp)
ffffffffc0202598:	7d02                	ld	s10,32(sp)
ffffffffc020259a:	6de2                	ld	s11,24(sp)
ffffffffc020259c:	6109                	addi	sp,sp,128
ffffffffc020259e:	8082                	ret
            if (free_pd0)
ffffffffc02025a0:	ea0b8fe3          	beqz	s7,ffffffffc020245e <exit_range+0x90>
ffffffffc02025a4:	bf45                	j	ffffffffc0202554 <exit_range+0x186>
ffffffffc02025a6:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc02025a8:	e42a                	sd	a0,8(sp)
ffffffffc02025aa:	c0afe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02025ae:	000db783          	ld	a5,0(s11)
ffffffffc02025b2:	6522                	ld	a0,8(sp)
ffffffffc02025b4:	4585                	li	a1,1
ffffffffc02025b6:	739c                	ld	a5,32(a5)
ffffffffc02025b8:	9782                	jalr	a5
        intr_enable();
ffffffffc02025ba:	bf4fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02025be:	6602                	ld	a2,0(sp)
ffffffffc02025c0:	000c8717          	auipc	a4,0xc8
ffffffffc02025c4:	83870713          	addi	a4,a4,-1992 # ffffffffc02c9df8 <pages>
ffffffffc02025c8:	6885                	lui	a7,0x1
ffffffffc02025ca:	00080337          	lui	t1,0x80
ffffffffc02025ce:	fff80e37          	lui	t3,0xfff80
ffffffffc02025d2:	000c8817          	auipc	a6,0xc8
ffffffffc02025d6:	83680813          	addi	a6,a6,-1994 # ffffffffc02c9e08 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02025da:	0004b023          	sd	zero,0(s1)
ffffffffc02025de:	b7a5                	j	ffffffffc0202546 <exit_range+0x178>
ffffffffc02025e0:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc02025e2:	bd2fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02025e6:	000db783          	ld	a5,0(s11)
ffffffffc02025ea:	6502                	ld	a0,0(sp)
ffffffffc02025ec:	4585                	li	a1,1
ffffffffc02025ee:	739c                	ld	a5,32(a5)
ffffffffc02025f0:	9782                	jalr	a5
        intr_enable();
ffffffffc02025f2:	bbcfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02025f6:	000c8717          	auipc	a4,0xc8
ffffffffc02025fa:	80270713          	addi	a4,a4,-2046 # ffffffffc02c9df8 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02025fe:	00043023          	sd	zero,0(s0)
ffffffffc0202602:	bfb5                	j	ffffffffc020257e <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202604:	00004697          	auipc	a3,0x4
ffffffffc0202608:	3cc68693          	addi	a3,a3,972 # ffffffffc02069d0 <default_pmm_manager+0x160>
ffffffffc020260c:	00004617          	auipc	a2,0x4
ffffffffc0202610:	eb460613          	addi	a2,a2,-332 # ffffffffc02064c0 <commands+0x858>
ffffffffc0202614:	13500593          	li	a1,309
ffffffffc0202618:	00004517          	auipc	a0,0x4
ffffffffc020261c:	3a850513          	addi	a0,a0,936 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0202620:	e6ffd0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202624:	00004617          	auipc	a2,0x4
ffffffffc0202628:	28460613          	addi	a2,a2,644 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc020262c:	07100593          	li	a1,113
ffffffffc0202630:	00004517          	auipc	a0,0x4
ffffffffc0202634:	2a050513          	addi	a0,a0,672 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc0202638:	e57fd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc020263c:	8e1ff0ef          	jal	ra,ffffffffc0201f1c <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0202640:	00004697          	auipc	a3,0x4
ffffffffc0202644:	3c068693          	addi	a3,a3,960 # ffffffffc0206a00 <default_pmm_manager+0x190>
ffffffffc0202648:	00004617          	auipc	a2,0x4
ffffffffc020264c:	e7860613          	addi	a2,a2,-392 # ffffffffc02064c0 <commands+0x858>
ffffffffc0202650:	13600593          	li	a1,310
ffffffffc0202654:	00004517          	auipc	a0,0x4
ffffffffc0202658:	36c50513          	addi	a0,a0,876 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc020265c:	e33fd0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0202660 <page_remove>:
{
ffffffffc0202660:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202662:	4601                	li	a2,0
{
ffffffffc0202664:	ec26                	sd	s1,24(sp)
ffffffffc0202666:	f406                	sd	ra,40(sp)
ffffffffc0202668:	f022                	sd	s0,32(sp)
ffffffffc020266a:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020266c:	9a1ff0ef          	jal	ra,ffffffffc020200c <get_pte>
    if (ptep != NULL)
ffffffffc0202670:	c511                	beqz	a0,ffffffffc020267c <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc0202672:	611c                	ld	a5,0(a0)
ffffffffc0202674:	842a                	mv	s0,a0
ffffffffc0202676:	0017f713          	andi	a4,a5,1
ffffffffc020267a:	e711                	bnez	a4,ffffffffc0202686 <page_remove+0x26>
}
ffffffffc020267c:	70a2                	ld	ra,40(sp)
ffffffffc020267e:	7402                	ld	s0,32(sp)
ffffffffc0202680:	64e2                	ld	s1,24(sp)
ffffffffc0202682:	6145                	addi	sp,sp,48
ffffffffc0202684:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202686:	078a                	slli	a5,a5,0x2
ffffffffc0202688:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020268a:	000c7717          	auipc	a4,0xc7
ffffffffc020268e:	76673703          	ld	a4,1894(a4) # ffffffffc02c9df0 <npage>
ffffffffc0202692:	06e7f363          	bgeu	a5,a4,ffffffffc02026f8 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202696:	fff80537          	lui	a0,0xfff80
ffffffffc020269a:	97aa                	add	a5,a5,a0
ffffffffc020269c:	079a                	slli	a5,a5,0x6
ffffffffc020269e:	000c7517          	auipc	a0,0xc7
ffffffffc02026a2:	75a53503          	ld	a0,1882(a0) # ffffffffc02c9df8 <pages>
ffffffffc02026a6:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02026a8:	411c                	lw	a5,0(a0)
ffffffffc02026aa:	fff7871b          	addiw	a4,a5,-1
ffffffffc02026ae:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc02026b0:	cb11                	beqz	a4,ffffffffc02026c4 <page_remove+0x64>
        *ptep = 0;
ffffffffc02026b2:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02026b6:	12048073          	sfence.vma	s1
}
ffffffffc02026ba:	70a2                	ld	ra,40(sp)
ffffffffc02026bc:	7402                	ld	s0,32(sp)
ffffffffc02026be:	64e2                	ld	s1,24(sp)
ffffffffc02026c0:	6145                	addi	sp,sp,48
ffffffffc02026c2:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02026c4:	100027f3          	csrr	a5,sstatus
ffffffffc02026c8:	8b89                	andi	a5,a5,2
ffffffffc02026ca:	eb89                	bnez	a5,ffffffffc02026dc <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc02026cc:	000c7797          	auipc	a5,0xc7
ffffffffc02026d0:	7347b783          	ld	a5,1844(a5) # ffffffffc02c9e00 <pmm_manager>
ffffffffc02026d4:	739c                	ld	a5,32(a5)
ffffffffc02026d6:	4585                	li	a1,1
ffffffffc02026d8:	9782                	jalr	a5
    if (flag)
ffffffffc02026da:	bfe1                	j	ffffffffc02026b2 <page_remove+0x52>
        intr_disable();
ffffffffc02026dc:	e42a                	sd	a0,8(sp)
ffffffffc02026de:	ad6fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02026e2:	000c7797          	auipc	a5,0xc7
ffffffffc02026e6:	71e7b783          	ld	a5,1822(a5) # ffffffffc02c9e00 <pmm_manager>
ffffffffc02026ea:	739c                	ld	a5,32(a5)
ffffffffc02026ec:	6522                	ld	a0,8(sp)
ffffffffc02026ee:	4585                	li	a1,1
ffffffffc02026f0:	9782                	jalr	a5
        intr_enable();
ffffffffc02026f2:	abcfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02026f6:	bf75                	j	ffffffffc02026b2 <page_remove+0x52>
ffffffffc02026f8:	825ff0ef          	jal	ra,ffffffffc0201f1c <pa2page.part.0>

ffffffffc02026fc <page_insert>:
{
ffffffffc02026fc:	7139                	addi	sp,sp,-64
ffffffffc02026fe:	e852                	sd	s4,16(sp)
ffffffffc0202700:	8a32                	mv	s4,a2
ffffffffc0202702:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202704:	4605                	li	a2,1
{
ffffffffc0202706:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202708:	85d2                	mv	a1,s4
{
ffffffffc020270a:	f426                	sd	s1,40(sp)
ffffffffc020270c:	fc06                	sd	ra,56(sp)
ffffffffc020270e:	f04a                	sd	s2,32(sp)
ffffffffc0202710:	ec4e                	sd	s3,24(sp)
ffffffffc0202712:	e456                	sd	s5,8(sp)
ffffffffc0202714:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202716:	8f7ff0ef          	jal	ra,ffffffffc020200c <get_pte>
    if (ptep == NULL)
ffffffffc020271a:	c961                	beqz	a0,ffffffffc02027ea <page_insert+0xee>
    page->ref += 1;
ffffffffc020271c:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc020271e:	611c                	ld	a5,0(a0)
ffffffffc0202720:	89aa                	mv	s3,a0
ffffffffc0202722:	0016871b          	addiw	a4,a3,1
ffffffffc0202726:	c018                	sw	a4,0(s0)
ffffffffc0202728:	0017f713          	andi	a4,a5,1
ffffffffc020272c:	ef05                	bnez	a4,ffffffffc0202764 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc020272e:	000c7717          	auipc	a4,0xc7
ffffffffc0202732:	6ca73703          	ld	a4,1738(a4) # ffffffffc02c9df8 <pages>
ffffffffc0202736:	8c19                	sub	s0,s0,a4
ffffffffc0202738:	000807b7          	lui	a5,0x80
ffffffffc020273c:	8419                	srai	s0,s0,0x6
ffffffffc020273e:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202740:	042a                	slli	s0,s0,0xa
ffffffffc0202742:	8cc1                	or	s1,s1,s0
ffffffffc0202744:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202748:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4e38>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020274c:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0202750:	4501                	li	a0,0
}
ffffffffc0202752:	70e2                	ld	ra,56(sp)
ffffffffc0202754:	7442                	ld	s0,48(sp)
ffffffffc0202756:	74a2                	ld	s1,40(sp)
ffffffffc0202758:	7902                	ld	s2,32(sp)
ffffffffc020275a:	69e2                	ld	s3,24(sp)
ffffffffc020275c:	6a42                	ld	s4,16(sp)
ffffffffc020275e:	6aa2                	ld	s5,8(sp)
ffffffffc0202760:	6121                	addi	sp,sp,64
ffffffffc0202762:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202764:	078a                	slli	a5,a5,0x2
ffffffffc0202766:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202768:	000c7717          	auipc	a4,0xc7
ffffffffc020276c:	68873703          	ld	a4,1672(a4) # ffffffffc02c9df0 <npage>
ffffffffc0202770:	06e7ff63          	bgeu	a5,a4,ffffffffc02027ee <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202774:	000c7a97          	auipc	s5,0xc7
ffffffffc0202778:	684a8a93          	addi	s5,s5,1668 # ffffffffc02c9df8 <pages>
ffffffffc020277c:	000ab703          	ld	a4,0(s5)
ffffffffc0202780:	fff80937          	lui	s2,0xfff80
ffffffffc0202784:	993e                	add	s2,s2,a5
ffffffffc0202786:	091a                	slli	s2,s2,0x6
ffffffffc0202788:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc020278a:	01240c63          	beq	s0,s2,ffffffffc02027a2 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc020278e:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fcb61cc>
ffffffffc0202792:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202796:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) == 0)
ffffffffc020279a:	c691                	beqz	a3,ffffffffc02027a6 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020279c:	120a0073          	sfence.vma	s4
}
ffffffffc02027a0:	bf59                	j	ffffffffc0202736 <page_insert+0x3a>
ffffffffc02027a2:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02027a4:	bf49                	j	ffffffffc0202736 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02027a6:	100027f3          	csrr	a5,sstatus
ffffffffc02027aa:	8b89                	andi	a5,a5,2
ffffffffc02027ac:	ef91                	bnez	a5,ffffffffc02027c8 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc02027ae:	000c7797          	auipc	a5,0xc7
ffffffffc02027b2:	6527b783          	ld	a5,1618(a5) # ffffffffc02c9e00 <pmm_manager>
ffffffffc02027b6:	739c                	ld	a5,32(a5)
ffffffffc02027b8:	4585                	li	a1,1
ffffffffc02027ba:	854a                	mv	a0,s2
ffffffffc02027bc:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02027be:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02027c2:	120a0073          	sfence.vma	s4
ffffffffc02027c6:	bf85                	j	ffffffffc0202736 <page_insert+0x3a>
        intr_disable();
ffffffffc02027c8:	9ecfe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02027cc:	000c7797          	auipc	a5,0xc7
ffffffffc02027d0:	6347b783          	ld	a5,1588(a5) # ffffffffc02c9e00 <pmm_manager>
ffffffffc02027d4:	739c                	ld	a5,32(a5)
ffffffffc02027d6:	4585                	li	a1,1
ffffffffc02027d8:	854a                	mv	a0,s2
ffffffffc02027da:	9782                	jalr	a5
        intr_enable();
ffffffffc02027dc:	9d2fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02027e0:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02027e4:	120a0073          	sfence.vma	s4
ffffffffc02027e8:	b7b9                	j	ffffffffc0202736 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02027ea:	5571                	li	a0,-4
ffffffffc02027ec:	b79d                	j	ffffffffc0202752 <page_insert+0x56>
ffffffffc02027ee:	f2eff0ef          	jal	ra,ffffffffc0201f1c <pa2page.part.0>

ffffffffc02027f2 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02027f2:	00004797          	auipc	a5,0x4
ffffffffc02027f6:	07e78793          	addi	a5,a5,126 # ffffffffc0206870 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02027fa:	638c                	ld	a1,0(a5)
{
ffffffffc02027fc:	7159                	addi	sp,sp,-112
ffffffffc02027fe:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202800:	00004517          	auipc	a0,0x4
ffffffffc0202804:	21850513          	addi	a0,a0,536 # ffffffffc0206a18 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc0202808:	000c7b17          	auipc	s6,0xc7
ffffffffc020280c:	5f8b0b13          	addi	s6,s6,1528 # ffffffffc02c9e00 <pmm_manager>
{
ffffffffc0202810:	f486                	sd	ra,104(sp)
ffffffffc0202812:	e8ca                	sd	s2,80(sp)
ffffffffc0202814:	e4ce                	sd	s3,72(sp)
ffffffffc0202816:	f0a2                	sd	s0,96(sp)
ffffffffc0202818:	eca6                	sd	s1,88(sp)
ffffffffc020281a:	e0d2                	sd	s4,64(sp)
ffffffffc020281c:	fc56                	sd	s5,56(sp)
ffffffffc020281e:	f45e                	sd	s7,40(sp)
ffffffffc0202820:	f062                	sd	s8,32(sp)
ffffffffc0202822:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202824:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202828:	96dfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    pmm_manager->init();
ffffffffc020282c:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202830:	000c7997          	auipc	s3,0xc7
ffffffffc0202834:	5d898993          	addi	s3,s3,1496 # ffffffffc02c9e08 <va_pa_offset>
    pmm_manager->init();
ffffffffc0202838:	679c                	ld	a5,8(a5)
ffffffffc020283a:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020283c:	57f5                	li	a5,-3
ffffffffc020283e:	07fa                	slli	a5,a5,0x1e
ffffffffc0202840:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc0202844:	956fe0ef          	jal	ra,ffffffffc020099a <get_memory_base>
ffffffffc0202848:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc020284a:	95afe0ef          	jal	ra,ffffffffc02009a4 <get_memory_size>
    if (mem_size == 0)
ffffffffc020284e:	200505e3          	beqz	a0,ffffffffc0203258 <pmm_init+0xa66>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0202852:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc0202854:	00004517          	auipc	a0,0x4
ffffffffc0202858:	1fc50513          	addi	a0,a0,508 # ffffffffc0206a50 <default_pmm_manager+0x1e0>
ffffffffc020285c:	939fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0202860:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202864:	fff40693          	addi	a3,s0,-1
ffffffffc0202868:	864a                	mv	a2,s2
ffffffffc020286a:	85a6                	mv	a1,s1
ffffffffc020286c:	00004517          	auipc	a0,0x4
ffffffffc0202870:	1fc50513          	addi	a0,a0,508 # ffffffffc0206a68 <default_pmm_manager+0x1f8>
ffffffffc0202874:	921fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0202878:	c8000737          	lui	a4,0xc8000
ffffffffc020287c:	87a2                	mv	a5,s0
ffffffffc020287e:	54876163          	bltu	a4,s0,ffffffffc0202dc0 <pmm_init+0x5ce>
ffffffffc0202882:	757d                	lui	a0,0xfffff
ffffffffc0202884:	000c8617          	auipc	a2,0xc8
ffffffffc0202888:	5af60613          	addi	a2,a2,1455 # ffffffffc02cae33 <end+0xfff>
ffffffffc020288c:	8e69                	and	a2,a2,a0
ffffffffc020288e:	000c7497          	auipc	s1,0xc7
ffffffffc0202892:	56248493          	addi	s1,s1,1378 # ffffffffc02c9df0 <npage>
ffffffffc0202896:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020289a:	000c7b97          	auipc	s7,0xc7
ffffffffc020289e:	55eb8b93          	addi	s7,s7,1374 # ffffffffc02c9df8 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02028a2:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02028a4:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02028a8:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02028ac:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02028ae:	02f50863          	beq	a0,a5,ffffffffc02028de <pmm_init+0xec>
ffffffffc02028b2:	4781                	li	a5,0
ffffffffc02028b4:	4585                	li	a1,1
ffffffffc02028b6:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc02028ba:	00679513          	slli	a0,a5,0x6
ffffffffc02028be:	9532                	add	a0,a0,a2
ffffffffc02028c0:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd351d4>
ffffffffc02028c4:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02028c8:	6088                	ld	a0,0(s1)
ffffffffc02028ca:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc02028cc:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02028d0:	00d50733          	add	a4,a0,a3
ffffffffc02028d4:	fee7e3e3          	bltu	a5,a4,ffffffffc02028ba <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02028d8:	071a                	slli	a4,a4,0x6
ffffffffc02028da:	00e606b3          	add	a3,a2,a4
ffffffffc02028de:	c02007b7          	lui	a5,0xc0200
ffffffffc02028e2:	2ef6ece3          	bltu	a3,a5,ffffffffc02033da <pmm_init+0xbe8>
ffffffffc02028e6:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02028ea:	77fd                	lui	a5,0xfffff
ffffffffc02028ec:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02028ee:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc02028f0:	5086eb63          	bltu	a3,s0,ffffffffc0202e06 <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc02028f4:	00004517          	auipc	a0,0x4
ffffffffc02028f8:	19c50513          	addi	a0,a0,412 # ffffffffc0206a90 <default_pmm_manager+0x220>
ffffffffc02028fc:	899fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202900:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202904:	000c7917          	auipc	s2,0xc7
ffffffffc0202908:	4e490913          	addi	s2,s2,1252 # ffffffffc02c9de8 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc020290c:	7b9c                	ld	a5,48(a5)
ffffffffc020290e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202910:	00004517          	auipc	a0,0x4
ffffffffc0202914:	19850513          	addi	a0,a0,408 # ffffffffc0206aa8 <default_pmm_manager+0x238>
ffffffffc0202918:	87dfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc020291c:	00007697          	auipc	a3,0x7
ffffffffc0202920:	6e468693          	addi	a3,a3,1764 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc0202924:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0202928:	c02007b7          	lui	a5,0xc0200
ffffffffc020292c:	28f6ebe3          	bltu	a3,a5,ffffffffc02033c2 <pmm_init+0xbd0>
ffffffffc0202930:	0009b783          	ld	a5,0(s3)
ffffffffc0202934:	8e9d                	sub	a3,a3,a5
ffffffffc0202936:	000c7797          	auipc	a5,0xc7
ffffffffc020293a:	4ad7b523          	sd	a3,1194(a5) # ffffffffc02c9de0 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020293e:	100027f3          	csrr	a5,sstatus
ffffffffc0202942:	8b89                	andi	a5,a5,2
ffffffffc0202944:	4a079763          	bnez	a5,ffffffffc0202df2 <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202948:	000b3783          	ld	a5,0(s6)
ffffffffc020294c:	779c                	ld	a5,40(a5)
ffffffffc020294e:	9782                	jalr	a5
ffffffffc0202950:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202952:	6098                	ld	a4,0(s1)
ffffffffc0202954:	c80007b7          	lui	a5,0xc8000
ffffffffc0202958:	83b1                	srli	a5,a5,0xc
ffffffffc020295a:	66e7e363          	bltu	a5,a4,ffffffffc0202fc0 <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc020295e:	00093503          	ld	a0,0(s2)
ffffffffc0202962:	62050f63          	beqz	a0,ffffffffc0202fa0 <pmm_init+0x7ae>
ffffffffc0202966:	03451793          	slli	a5,a0,0x34
ffffffffc020296a:	62079b63          	bnez	a5,ffffffffc0202fa0 <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc020296e:	4601                	li	a2,0
ffffffffc0202970:	4581                	li	a1,0
ffffffffc0202972:	8c3ff0ef          	jal	ra,ffffffffc0202234 <get_page>
ffffffffc0202976:	60051563          	bnez	a0,ffffffffc0202f80 <pmm_init+0x78e>
ffffffffc020297a:	100027f3          	csrr	a5,sstatus
ffffffffc020297e:	8b89                	andi	a5,a5,2
ffffffffc0202980:	44079e63          	bnez	a5,ffffffffc0202ddc <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202984:	000b3783          	ld	a5,0(s6)
ffffffffc0202988:	4505                	li	a0,1
ffffffffc020298a:	6f9c                	ld	a5,24(a5)
ffffffffc020298c:	9782                	jalr	a5
ffffffffc020298e:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202990:	00093503          	ld	a0,0(s2)
ffffffffc0202994:	4681                	li	a3,0
ffffffffc0202996:	4601                	li	a2,0
ffffffffc0202998:	85d2                	mv	a1,s4
ffffffffc020299a:	d63ff0ef          	jal	ra,ffffffffc02026fc <page_insert>
ffffffffc020299e:	26051ae3          	bnez	a0,ffffffffc0203412 <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02029a2:	00093503          	ld	a0,0(s2)
ffffffffc02029a6:	4601                	li	a2,0
ffffffffc02029a8:	4581                	li	a1,0
ffffffffc02029aa:	e62ff0ef          	jal	ra,ffffffffc020200c <get_pte>
ffffffffc02029ae:	240502e3          	beqz	a0,ffffffffc02033f2 <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc02029b2:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc02029b4:	0017f713          	andi	a4,a5,1
ffffffffc02029b8:	5a070263          	beqz	a4,ffffffffc0202f5c <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc02029bc:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02029be:	078a                	slli	a5,a5,0x2
ffffffffc02029c0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02029c2:	58e7fb63          	bgeu	a5,a4,ffffffffc0202f58 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02029c6:	000bb683          	ld	a3,0(s7)
ffffffffc02029ca:	fff80637          	lui	a2,0xfff80
ffffffffc02029ce:	97b2                	add	a5,a5,a2
ffffffffc02029d0:	079a                	slli	a5,a5,0x6
ffffffffc02029d2:	97b6                	add	a5,a5,a3
ffffffffc02029d4:	14fa17e3          	bne	s4,a5,ffffffffc0203322 <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc02029d8:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8c50>
ffffffffc02029dc:	4785                	li	a5,1
ffffffffc02029de:	12f692e3          	bne	a3,a5,ffffffffc0203302 <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc02029e2:	00093503          	ld	a0,0(s2)
ffffffffc02029e6:	77fd                	lui	a5,0xfffff
ffffffffc02029e8:	6114                	ld	a3,0(a0)
ffffffffc02029ea:	068a                	slli	a3,a3,0x2
ffffffffc02029ec:	8efd                	and	a3,a3,a5
ffffffffc02029ee:	00c6d613          	srli	a2,a3,0xc
ffffffffc02029f2:	0ee67ce3          	bgeu	a2,a4,ffffffffc02032ea <pmm_init+0xaf8>
ffffffffc02029f6:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02029fa:	96e2                	add	a3,a3,s8
ffffffffc02029fc:	0006ba83          	ld	s5,0(a3)
ffffffffc0202a00:	0a8a                	slli	s5,s5,0x2
ffffffffc0202a02:	00fafab3          	and	s5,s5,a5
ffffffffc0202a06:	00cad793          	srli	a5,s5,0xc
ffffffffc0202a0a:	0ce7f3e3          	bgeu	a5,a4,ffffffffc02032d0 <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202a0e:	4601                	li	a2,0
ffffffffc0202a10:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a12:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202a14:	df8ff0ef          	jal	ra,ffffffffc020200c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a18:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202a1a:	55551363          	bne	a0,s5,ffffffffc0202f60 <pmm_init+0x76e>
ffffffffc0202a1e:	100027f3          	csrr	a5,sstatus
ffffffffc0202a22:	8b89                	andi	a5,a5,2
ffffffffc0202a24:	3a079163          	bnez	a5,ffffffffc0202dc6 <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a28:	000b3783          	ld	a5,0(s6)
ffffffffc0202a2c:	4505                	li	a0,1
ffffffffc0202a2e:	6f9c                	ld	a5,24(a5)
ffffffffc0202a30:	9782                	jalr	a5
ffffffffc0202a32:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202a34:	00093503          	ld	a0,0(s2)
ffffffffc0202a38:	46d1                	li	a3,20
ffffffffc0202a3a:	6605                	lui	a2,0x1
ffffffffc0202a3c:	85e2                	mv	a1,s8
ffffffffc0202a3e:	cbfff0ef          	jal	ra,ffffffffc02026fc <page_insert>
ffffffffc0202a42:	060517e3          	bnez	a0,ffffffffc02032b0 <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202a46:	00093503          	ld	a0,0(s2)
ffffffffc0202a4a:	4601                	li	a2,0
ffffffffc0202a4c:	6585                	lui	a1,0x1
ffffffffc0202a4e:	dbeff0ef          	jal	ra,ffffffffc020200c <get_pte>
ffffffffc0202a52:	02050fe3          	beqz	a0,ffffffffc0203290 <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc0202a56:	611c                	ld	a5,0(a0)
ffffffffc0202a58:	0107f713          	andi	a4,a5,16
ffffffffc0202a5c:	7c070e63          	beqz	a4,ffffffffc0203238 <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc0202a60:	8b91                	andi	a5,a5,4
ffffffffc0202a62:	7a078b63          	beqz	a5,ffffffffc0203218 <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202a66:	00093503          	ld	a0,0(s2)
ffffffffc0202a6a:	611c                	ld	a5,0(a0)
ffffffffc0202a6c:	8bc1                	andi	a5,a5,16
ffffffffc0202a6e:	78078563          	beqz	a5,ffffffffc02031f8 <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc0202a72:	000c2703          	lw	a4,0(s8)
ffffffffc0202a76:	4785                	li	a5,1
ffffffffc0202a78:	76f71063          	bne	a4,a5,ffffffffc02031d8 <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202a7c:	4681                	li	a3,0
ffffffffc0202a7e:	6605                	lui	a2,0x1
ffffffffc0202a80:	85d2                	mv	a1,s4
ffffffffc0202a82:	c7bff0ef          	jal	ra,ffffffffc02026fc <page_insert>
ffffffffc0202a86:	72051963          	bnez	a0,ffffffffc02031b8 <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc0202a8a:	000a2703          	lw	a4,0(s4)
ffffffffc0202a8e:	4789                	li	a5,2
ffffffffc0202a90:	70f71463          	bne	a4,a5,ffffffffc0203198 <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc0202a94:	000c2783          	lw	a5,0(s8)
ffffffffc0202a98:	6e079063          	bnez	a5,ffffffffc0203178 <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202a9c:	00093503          	ld	a0,0(s2)
ffffffffc0202aa0:	4601                	li	a2,0
ffffffffc0202aa2:	6585                	lui	a1,0x1
ffffffffc0202aa4:	d68ff0ef          	jal	ra,ffffffffc020200c <get_pte>
ffffffffc0202aa8:	6a050863          	beqz	a0,ffffffffc0203158 <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc0202aac:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202aae:	00177793          	andi	a5,a4,1
ffffffffc0202ab2:	4a078563          	beqz	a5,ffffffffc0202f5c <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202ab6:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ab8:	00271793          	slli	a5,a4,0x2
ffffffffc0202abc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202abe:	48d7fd63          	bgeu	a5,a3,ffffffffc0202f58 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ac2:	000bb683          	ld	a3,0(s7)
ffffffffc0202ac6:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202aca:	97d6                	add	a5,a5,s5
ffffffffc0202acc:	079a                	slli	a5,a5,0x6
ffffffffc0202ace:	97b6                	add	a5,a5,a3
ffffffffc0202ad0:	66fa1463          	bne	s4,a5,ffffffffc0203138 <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202ad4:	8b41                	andi	a4,a4,16
ffffffffc0202ad6:	64071163          	bnez	a4,ffffffffc0203118 <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202ada:	00093503          	ld	a0,0(s2)
ffffffffc0202ade:	4581                	li	a1,0
ffffffffc0202ae0:	b81ff0ef          	jal	ra,ffffffffc0202660 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202ae4:	000a2c83          	lw	s9,0(s4)
ffffffffc0202ae8:	4785                	li	a5,1
ffffffffc0202aea:	60fc9763          	bne	s9,a5,ffffffffc02030f8 <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc0202aee:	000c2783          	lw	a5,0(s8)
ffffffffc0202af2:	5e079363          	bnez	a5,ffffffffc02030d8 <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202af6:	00093503          	ld	a0,0(s2)
ffffffffc0202afa:	6585                	lui	a1,0x1
ffffffffc0202afc:	b65ff0ef          	jal	ra,ffffffffc0202660 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202b00:	000a2783          	lw	a5,0(s4)
ffffffffc0202b04:	52079a63          	bnez	a5,ffffffffc0203038 <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc0202b08:	000c2783          	lw	a5,0(s8)
ffffffffc0202b0c:	50079663          	bnez	a5,ffffffffc0203018 <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202b10:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202b14:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b16:	000a3683          	ld	a3,0(s4)
ffffffffc0202b1a:	068a                	slli	a3,a3,0x2
ffffffffc0202b1c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b1e:	42b6fd63          	bgeu	a3,a1,ffffffffc0202f58 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b22:	000bb503          	ld	a0,0(s7)
ffffffffc0202b26:	96d6                	add	a3,a3,s5
ffffffffc0202b28:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0202b2a:	00d507b3          	add	a5,a0,a3
ffffffffc0202b2e:	439c                	lw	a5,0(a5)
ffffffffc0202b30:	4d979463          	bne	a5,s9,ffffffffc0202ff8 <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc0202b34:	8699                	srai	a3,a3,0x6
ffffffffc0202b36:	00080637          	lui	a2,0x80
ffffffffc0202b3a:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202b3c:	00c69713          	slli	a4,a3,0xc
ffffffffc0202b40:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b42:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202b44:	48b77e63          	bgeu	a4,a1,ffffffffc0202fe0 <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202b48:	0009b703          	ld	a4,0(s3)
ffffffffc0202b4c:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b4e:	629c                	ld	a5,0(a3)
ffffffffc0202b50:	078a                	slli	a5,a5,0x2
ffffffffc0202b52:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b54:	40b7f263          	bgeu	a5,a1,ffffffffc0202f58 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b58:	8f91                	sub	a5,a5,a2
ffffffffc0202b5a:	079a                	slli	a5,a5,0x6
ffffffffc0202b5c:	953e                	add	a0,a0,a5
ffffffffc0202b5e:	100027f3          	csrr	a5,sstatus
ffffffffc0202b62:	8b89                	andi	a5,a5,2
ffffffffc0202b64:	30079963          	bnez	a5,ffffffffc0202e76 <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc0202b68:	000b3783          	ld	a5,0(s6)
ffffffffc0202b6c:	4585                	li	a1,1
ffffffffc0202b6e:	739c                	ld	a5,32(a5)
ffffffffc0202b70:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b72:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202b76:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b78:	078a                	slli	a5,a5,0x2
ffffffffc0202b7a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b7c:	3ce7fe63          	bgeu	a5,a4,ffffffffc0202f58 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b80:	000bb503          	ld	a0,0(s7)
ffffffffc0202b84:	fff80737          	lui	a4,0xfff80
ffffffffc0202b88:	97ba                	add	a5,a5,a4
ffffffffc0202b8a:	079a                	slli	a5,a5,0x6
ffffffffc0202b8c:	953e                	add	a0,a0,a5
ffffffffc0202b8e:	100027f3          	csrr	a5,sstatus
ffffffffc0202b92:	8b89                	andi	a5,a5,2
ffffffffc0202b94:	2c079563          	bnez	a5,ffffffffc0202e5e <pmm_init+0x66c>
ffffffffc0202b98:	000b3783          	ld	a5,0(s6)
ffffffffc0202b9c:	4585                	li	a1,1
ffffffffc0202b9e:	739c                	ld	a5,32(a5)
ffffffffc0202ba0:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202ba2:	00093783          	ld	a5,0(s2)
ffffffffc0202ba6:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd351cc>
    asm volatile("sfence.vma");
ffffffffc0202baa:	12000073          	sfence.vma
ffffffffc0202bae:	100027f3          	csrr	a5,sstatus
ffffffffc0202bb2:	8b89                	andi	a5,a5,2
ffffffffc0202bb4:	28079b63          	bnez	a5,ffffffffc0202e4a <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202bb8:	000b3783          	ld	a5,0(s6)
ffffffffc0202bbc:	779c                	ld	a5,40(a5)
ffffffffc0202bbe:	9782                	jalr	a5
ffffffffc0202bc0:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202bc2:	4b441b63          	bne	s0,s4,ffffffffc0203078 <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202bc6:	00004517          	auipc	a0,0x4
ffffffffc0202bca:	20a50513          	addi	a0,a0,522 # ffffffffc0206dd0 <default_pmm_manager+0x560>
ffffffffc0202bce:	dc6fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0202bd2:	100027f3          	csrr	a5,sstatus
ffffffffc0202bd6:	8b89                	andi	a5,a5,2
ffffffffc0202bd8:	24079f63          	bnez	a5,ffffffffc0202e36 <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202bdc:	000b3783          	ld	a5,0(s6)
ffffffffc0202be0:	779c                	ld	a5,40(a5)
ffffffffc0202be2:	9782                	jalr	a5
ffffffffc0202be4:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202be6:	6098                	ld	a4,0(s1)
ffffffffc0202be8:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bec:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202bee:	00c71793          	slli	a5,a4,0xc
ffffffffc0202bf2:	6a05                	lui	s4,0x1
ffffffffc0202bf4:	02f47c63          	bgeu	s0,a5,ffffffffc0202c2c <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202bf8:	00c45793          	srli	a5,s0,0xc
ffffffffc0202bfc:	00093503          	ld	a0,0(s2)
ffffffffc0202c00:	2ee7ff63          	bgeu	a5,a4,ffffffffc0202efe <pmm_init+0x70c>
ffffffffc0202c04:	0009b583          	ld	a1,0(s3)
ffffffffc0202c08:	4601                	li	a2,0
ffffffffc0202c0a:	95a2                	add	a1,a1,s0
ffffffffc0202c0c:	c00ff0ef          	jal	ra,ffffffffc020200c <get_pte>
ffffffffc0202c10:	32050463          	beqz	a0,ffffffffc0202f38 <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202c14:	611c                	ld	a5,0(a0)
ffffffffc0202c16:	078a                	slli	a5,a5,0x2
ffffffffc0202c18:	0157f7b3          	and	a5,a5,s5
ffffffffc0202c1c:	2e879e63          	bne	a5,s0,ffffffffc0202f18 <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202c20:	6098                	ld	a4,0(s1)
ffffffffc0202c22:	9452                	add	s0,s0,s4
ffffffffc0202c24:	00c71793          	slli	a5,a4,0xc
ffffffffc0202c28:	fcf468e3          	bltu	s0,a5,ffffffffc0202bf8 <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202c2c:	00093783          	ld	a5,0(s2)
ffffffffc0202c30:	639c                	ld	a5,0(a5)
ffffffffc0202c32:	42079363          	bnez	a5,ffffffffc0203058 <pmm_init+0x866>
ffffffffc0202c36:	100027f3          	csrr	a5,sstatus
ffffffffc0202c3a:	8b89                	andi	a5,a5,2
ffffffffc0202c3c:	24079963          	bnez	a5,ffffffffc0202e8e <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202c40:	000b3783          	ld	a5,0(s6)
ffffffffc0202c44:	4505                	li	a0,1
ffffffffc0202c46:	6f9c                	ld	a5,24(a5)
ffffffffc0202c48:	9782                	jalr	a5
ffffffffc0202c4a:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c4c:	00093503          	ld	a0,0(s2)
ffffffffc0202c50:	4699                	li	a3,6
ffffffffc0202c52:	10000613          	li	a2,256
ffffffffc0202c56:	85d2                	mv	a1,s4
ffffffffc0202c58:	aa5ff0ef          	jal	ra,ffffffffc02026fc <page_insert>
ffffffffc0202c5c:	44051e63          	bnez	a0,ffffffffc02030b8 <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc0202c60:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8c50>
ffffffffc0202c64:	4785                	li	a5,1
ffffffffc0202c66:	42f71963          	bne	a4,a5,ffffffffc0203098 <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202c6a:	00093503          	ld	a0,0(s2)
ffffffffc0202c6e:	6405                	lui	s0,0x1
ffffffffc0202c70:	4699                	li	a3,6
ffffffffc0202c72:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8b50>
ffffffffc0202c76:	85d2                	mv	a1,s4
ffffffffc0202c78:	a85ff0ef          	jal	ra,ffffffffc02026fc <page_insert>
ffffffffc0202c7c:	72051363          	bnez	a0,ffffffffc02033a2 <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc0202c80:	000a2703          	lw	a4,0(s4)
ffffffffc0202c84:	4789                	li	a5,2
ffffffffc0202c86:	6ef71e63          	bne	a4,a5,ffffffffc0203382 <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202c8a:	00004597          	auipc	a1,0x4
ffffffffc0202c8e:	28e58593          	addi	a1,a1,654 # ffffffffc0206f18 <default_pmm_manager+0x6a8>
ffffffffc0202c92:	10000513          	li	a0,256
ffffffffc0202c96:	4d1020ef          	jal	ra,ffffffffc0205966 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202c9a:	10040593          	addi	a1,s0,256
ffffffffc0202c9e:	10000513          	li	a0,256
ffffffffc0202ca2:	4d7020ef          	jal	ra,ffffffffc0205978 <strcmp>
ffffffffc0202ca6:	6a051e63          	bnez	a0,ffffffffc0203362 <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc0202caa:	000bb683          	ld	a3,0(s7)
ffffffffc0202cae:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202cb2:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202cb4:	40da06b3          	sub	a3,s4,a3
ffffffffc0202cb8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202cba:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202cbc:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202cbe:	8031                	srli	s0,s0,0xc
ffffffffc0202cc0:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202cc4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202cc6:	30f77d63          	bgeu	a4,a5,ffffffffc0202fe0 <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202cca:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202cce:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202cd2:	96be                	add	a3,a3,a5
ffffffffc0202cd4:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202cd8:	459020ef          	jal	ra,ffffffffc0205930 <strlen>
ffffffffc0202cdc:	66051363          	bnez	a0,ffffffffc0203342 <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202ce0:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202ce4:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ce6:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd351cc>
ffffffffc0202cea:	068a                	slli	a3,a3,0x2
ffffffffc0202cec:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202cee:	26f6f563          	bgeu	a3,a5,ffffffffc0202f58 <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc0202cf2:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202cf4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202cf6:	2ef47563          	bgeu	s0,a5,ffffffffc0202fe0 <pmm_init+0x7ee>
ffffffffc0202cfa:	0009b403          	ld	s0,0(s3)
ffffffffc0202cfe:	9436                	add	s0,s0,a3
ffffffffc0202d00:	100027f3          	csrr	a5,sstatus
ffffffffc0202d04:	8b89                	andi	a5,a5,2
ffffffffc0202d06:	1e079163          	bnez	a5,ffffffffc0202ee8 <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0202d0a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d0e:	4585                	li	a1,1
ffffffffc0202d10:	8552                	mv	a0,s4
ffffffffc0202d12:	739c                	ld	a5,32(a5)
ffffffffc0202d14:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d16:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0202d18:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d1a:	078a                	slli	a5,a5,0x2
ffffffffc0202d1c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d1e:	22e7fd63          	bgeu	a5,a4,ffffffffc0202f58 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d22:	000bb503          	ld	a0,0(s7)
ffffffffc0202d26:	fff80737          	lui	a4,0xfff80
ffffffffc0202d2a:	97ba                	add	a5,a5,a4
ffffffffc0202d2c:	079a                	slli	a5,a5,0x6
ffffffffc0202d2e:	953e                	add	a0,a0,a5
ffffffffc0202d30:	100027f3          	csrr	a5,sstatus
ffffffffc0202d34:	8b89                	andi	a5,a5,2
ffffffffc0202d36:	18079d63          	bnez	a5,ffffffffc0202ed0 <pmm_init+0x6de>
ffffffffc0202d3a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d3e:	4585                	li	a1,1
ffffffffc0202d40:	739c                	ld	a5,32(a5)
ffffffffc0202d42:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d44:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc0202d48:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d4a:	078a                	slli	a5,a5,0x2
ffffffffc0202d4c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d4e:	20e7f563          	bgeu	a5,a4,ffffffffc0202f58 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d52:	000bb503          	ld	a0,0(s7)
ffffffffc0202d56:	fff80737          	lui	a4,0xfff80
ffffffffc0202d5a:	97ba                	add	a5,a5,a4
ffffffffc0202d5c:	079a                	slli	a5,a5,0x6
ffffffffc0202d5e:	953e                	add	a0,a0,a5
ffffffffc0202d60:	100027f3          	csrr	a5,sstatus
ffffffffc0202d64:	8b89                	andi	a5,a5,2
ffffffffc0202d66:	14079963          	bnez	a5,ffffffffc0202eb8 <pmm_init+0x6c6>
ffffffffc0202d6a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d6e:	4585                	li	a1,1
ffffffffc0202d70:	739c                	ld	a5,32(a5)
ffffffffc0202d72:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202d74:	00093783          	ld	a5,0(s2)
ffffffffc0202d78:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202d7c:	12000073          	sfence.vma
ffffffffc0202d80:	100027f3          	csrr	a5,sstatus
ffffffffc0202d84:	8b89                	andi	a5,a5,2
ffffffffc0202d86:	10079f63          	bnez	a5,ffffffffc0202ea4 <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202d8a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d8e:	779c                	ld	a5,40(a5)
ffffffffc0202d90:	9782                	jalr	a5
ffffffffc0202d92:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202d94:	4c8c1e63          	bne	s8,s0,ffffffffc0203270 <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202d98:	00004517          	auipc	a0,0x4
ffffffffc0202d9c:	1f850513          	addi	a0,a0,504 # ffffffffc0206f90 <default_pmm_manager+0x720>
ffffffffc0202da0:	bf4fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0202da4:	7406                	ld	s0,96(sp)
ffffffffc0202da6:	70a6                	ld	ra,104(sp)
ffffffffc0202da8:	64e6                	ld	s1,88(sp)
ffffffffc0202daa:	6946                	ld	s2,80(sp)
ffffffffc0202dac:	69a6                	ld	s3,72(sp)
ffffffffc0202dae:	6a06                	ld	s4,64(sp)
ffffffffc0202db0:	7ae2                	ld	s5,56(sp)
ffffffffc0202db2:	7b42                	ld	s6,48(sp)
ffffffffc0202db4:	7ba2                	ld	s7,40(sp)
ffffffffc0202db6:	7c02                	ld	s8,32(sp)
ffffffffc0202db8:	6ce2                	ld	s9,24(sp)
ffffffffc0202dba:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202dbc:	f97fe06f          	j	ffffffffc0201d52 <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc0202dc0:	c80007b7          	lui	a5,0xc8000
ffffffffc0202dc4:	bc7d                	j	ffffffffc0202882 <pmm_init+0x90>
        intr_disable();
ffffffffc0202dc6:	beffd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202dca:	000b3783          	ld	a5,0(s6)
ffffffffc0202dce:	4505                	li	a0,1
ffffffffc0202dd0:	6f9c                	ld	a5,24(a5)
ffffffffc0202dd2:	9782                	jalr	a5
ffffffffc0202dd4:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202dd6:	bd9fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202dda:	b9a9                	j	ffffffffc0202a34 <pmm_init+0x242>
        intr_disable();
ffffffffc0202ddc:	bd9fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202de0:	000b3783          	ld	a5,0(s6)
ffffffffc0202de4:	4505                	li	a0,1
ffffffffc0202de6:	6f9c                	ld	a5,24(a5)
ffffffffc0202de8:	9782                	jalr	a5
ffffffffc0202dea:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202dec:	bc3fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202df0:	b645                	j	ffffffffc0202990 <pmm_init+0x19e>
        intr_disable();
ffffffffc0202df2:	bc3fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202df6:	000b3783          	ld	a5,0(s6)
ffffffffc0202dfa:	779c                	ld	a5,40(a5)
ffffffffc0202dfc:	9782                	jalr	a5
ffffffffc0202dfe:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202e00:	baffd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e04:	b6b9                	j	ffffffffc0202952 <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202e06:	6705                	lui	a4,0x1
ffffffffc0202e08:	177d                	addi	a4,a4,-1
ffffffffc0202e0a:	96ba                	add	a3,a3,a4
ffffffffc0202e0c:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202e0e:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202e12:	14a77363          	bgeu	a4,a0,ffffffffc0202f58 <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0202e16:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0202e1a:	fff80537          	lui	a0,0xfff80
ffffffffc0202e1e:	972a                	add	a4,a4,a0
ffffffffc0202e20:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202e22:	8c1d                	sub	s0,s0,a5
ffffffffc0202e24:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202e28:	00c45593          	srli	a1,s0,0xc
ffffffffc0202e2c:	9532                	add	a0,a0,a2
ffffffffc0202e2e:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202e30:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202e34:	b4c1                	j	ffffffffc02028f4 <pmm_init+0x102>
        intr_disable();
ffffffffc0202e36:	b7ffd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e3a:	000b3783          	ld	a5,0(s6)
ffffffffc0202e3e:	779c                	ld	a5,40(a5)
ffffffffc0202e40:	9782                	jalr	a5
ffffffffc0202e42:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202e44:	b6bfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e48:	bb79                	j	ffffffffc0202be6 <pmm_init+0x3f4>
        intr_disable();
ffffffffc0202e4a:	b6bfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202e4e:	000b3783          	ld	a5,0(s6)
ffffffffc0202e52:	779c                	ld	a5,40(a5)
ffffffffc0202e54:	9782                	jalr	a5
ffffffffc0202e56:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202e58:	b57fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e5c:	b39d                	j	ffffffffc0202bc2 <pmm_init+0x3d0>
ffffffffc0202e5e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e60:	b55fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e64:	000b3783          	ld	a5,0(s6)
ffffffffc0202e68:	6522                	ld	a0,8(sp)
ffffffffc0202e6a:	4585                	li	a1,1
ffffffffc0202e6c:	739c                	ld	a5,32(a5)
ffffffffc0202e6e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e70:	b3ffd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e74:	b33d                	j	ffffffffc0202ba2 <pmm_init+0x3b0>
ffffffffc0202e76:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e78:	b3dfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202e7c:	000b3783          	ld	a5,0(s6)
ffffffffc0202e80:	6522                	ld	a0,8(sp)
ffffffffc0202e82:	4585                	li	a1,1
ffffffffc0202e84:	739c                	ld	a5,32(a5)
ffffffffc0202e86:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e88:	b27fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e8c:	b1dd                	j	ffffffffc0202b72 <pmm_init+0x380>
        intr_disable();
ffffffffc0202e8e:	b27fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202e92:	000b3783          	ld	a5,0(s6)
ffffffffc0202e96:	4505                	li	a0,1
ffffffffc0202e98:	6f9c                	ld	a5,24(a5)
ffffffffc0202e9a:	9782                	jalr	a5
ffffffffc0202e9c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202e9e:	b11fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202ea2:	b36d                	j	ffffffffc0202c4c <pmm_init+0x45a>
        intr_disable();
ffffffffc0202ea4:	b11fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ea8:	000b3783          	ld	a5,0(s6)
ffffffffc0202eac:	779c                	ld	a5,40(a5)
ffffffffc0202eae:	9782                	jalr	a5
ffffffffc0202eb0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202eb2:	afdfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202eb6:	bdf9                	j	ffffffffc0202d94 <pmm_init+0x5a2>
ffffffffc0202eb8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202eba:	afbfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202ebe:	000b3783          	ld	a5,0(s6)
ffffffffc0202ec2:	6522                	ld	a0,8(sp)
ffffffffc0202ec4:	4585                	li	a1,1
ffffffffc0202ec6:	739c                	ld	a5,32(a5)
ffffffffc0202ec8:	9782                	jalr	a5
        intr_enable();
ffffffffc0202eca:	ae5fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202ece:	b55d                	j	ffffffffc0202d74 <pmm_init+0x582>
ffffffffc0202ed0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ed2:	ae3fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202ed6:	000b3783          	ld	a5,0(s6)
ffffffffc0202eda:	6522                	ld	a0,8(sp)
ffffffffc0202edc:	4585                	li	a1,1
ffffffffc0202ede:	739c                	ld	a5,32(a5)
ffffffffc0202ee0:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ee2:	acdfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202ee6:	bdb9                	j	ffffffffc0202d44 <pmm_init+0x552>
        intr_disable();
ffffffffc0202ee8:	acdfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202eec:	000b3783          	ld	a5,0(s6)
ffffffffc0202ef0:	4585                	li	a1,1
ffffffffc0202ef2:	8552                	mv	a0,s4
ffffffffc0202ef4:	739c                	ld	a5,32(a5)
ffffffffc0202ef6:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ef8:	ab7fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202efc:	bd29                	j	ffffffffc0202d16 <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202efe:	86a2                	mv	a3,s0
ffffffffc0202f00:	00004617          	auipc	a2,0x4
ffffffffc0202f04:	9a860613          	addi	a2,a2,-1624 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc0202f08:	26500593          	li	a1,613
ffffffffc0202f0c:	00004517          	auipc	a0,0x4
ffffffffc0202f10:	ab450513          	addi	a0,a0,-1356 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0202f14:	d7afd0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202f18:	00004697          	auipc	a3,0x4
ffffffffc0202f1c:	f1868693          	addi	a3,a3,-232 # ffffffffc0206e30 <default_pmm_manager+0x5c0>
ffffffffc0202f20:	00003617          	auipc	a2,0x3
ffffffffc0202f24:	5a060613          	addi	a2,a2,1440 # ffffffffc02064c0 <commands+0x858>
ffffffffc0202f28:	26600593          	li	a1,614
ffffffffc0202f2c:	00004517          	auipc	a0,0x4
ffffffffc0202f30:	a9450513          	addi	a0,a0,-1388 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0202f34:	d5afd0ef          	jal	ra,ffffffffc020048e <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202f38:	00004697          	auipc	a3,0x4
ffffffffc0202f3c:	eb868693          	addi	a3,a3,-328 # ffffffffc0206df0 <default_pmm_manager+0x580>
ffffffffc0202f40:	00003617          	auipc	a2,0x3
ffffffffc0202f44:	58060613          	addi	a2,a2,1408 # ffffffffc02064c0 <commands+0x858>
ffffffffc0202f48:	26500593          	li	a1,613
ffffffffc0202f4c:	00004517          	auipc	a0,0x4
ffffffffc0202f50:	a7450513          	addi	a0,a0,-1420 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0202f54:	d3afd0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0202f58:	fc5fe0ef          	jal	ra,ffffffffc0201f1c <pa2page.part.0>
ffffffffc0202f5c:	fddfe0ef          	jal	ra,ffffffffc0201f38 <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202f60:	00004697          	auipc	a3,0x4
ffffffffc0202f64:	c8868693          	addi	a3,a3,-888 # ffffffffc0206be8 <default_pmm_manager+0x378>
ffffffffc0202f68:	00003617          	auipc	a2,0x3
ffffffffc0202f6c:	55860613          	addi	a2,a2,1368 # ffffffffc02064c0 <commands+0x858>
ffffffffc0202f70:	23500593          	li	a1,565
ffffffffc0202f74:	00004517          	auipc	a0,0x4
ffffffffc0202f78:	a4c50513          	addi	a0,a0,-1460 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0202f7c:	d12fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202f80:	00004697          	auipc	a3,0x4
ffffffffc0202f84:	ba868693          	addi	a3,a3,-1112 # ffffffffc0206b28 <default_pmm_manager+0x2b8>
ffffffffc0202f88:	00003617          	auipc	a2,0x3
ffffffffc0202f8c:	53860613          	addi	a2,a2,1336 # ffffffffc02064c0 <commands+0x858>
ffffffffc0202f90:	22800593          	li	a1,552
ffffffffc0202f94:	00004517          	auipc	a0,0x4
ffffffffc0202f98:	a2c50513          	addi	a0,a0,-1492 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0202f9c:	cf2fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202fa0:	00004697          	auipc	a3,0x4
ffffffffc0202fa4:	b4868693          	addi	a3,a3,-1208 # ffffffffc0206ae8 <default_pmm_manager+0x278>
ffffffffc0202fa8:	00003617          	auipc	a2,0x3
ffffffffc0202fac:	51860613          	addi	a2,a2,1304 # ffffffffc02064c0 <commands+0x858>
ffffffffc0202fb0:	22700593          	li	a1,551
ffffffffc0202fb4:	00004517          	auipc	a0,0x4
ffffffffc0202fb8:	a0c50513          	addi	a0,a0,-1524 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0202fbc:	cd2fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202fc0:	00004697          	auipc	a3,0x4
ffffffffc0202fc4:	b0868693          	addi	a3,a3,-1272 # ffffffffc0206ac8 <default_pmm_manager+0x258>
ffffffffc0202fc8:	00003617          	auipc	a2,0x3
ffffffffc0202fcc:	4f860613          	addi	a2,a2,1272 # ffffffffc02064c0 <commands+0x858>
ffffffffc0202fd0:	22600593          	li	a1,550
ffffffffc0202fd4:	00004517          	auipc	a0,0x4
ffffffffc0202fd8:	9ec50513          	addi	a0,a0,-1556 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0202fdc:	cb2fd0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202fe0:	00004617          	auipc	a2,0x4
ffffffffc0202fe4:	8c860613          	addi	a2,a2,-1848 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc0202fe8:	07100593          	li	a1,113
ffffffffc0202fec:	00004517          	auipc	a0,0x4
ffffffffc0202ff0:	8e450513          	addi	a0,a0,-1820 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc0202ff4:	c9afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202ff8:	00004697          	auipc	a3,0x4
ffffffffc0202ffc:	d8068693          	addi	a3,a3,-640 # ffffffffc0206d78 <default_pmm_manager+0x508>
ffffffffc0203000:	00003617          	auipc	a2,0x3
ffffffffc0203004:	4c060613          	addi	a2,a2,1216 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203008:	24e00593          	li	a1,590
ffffffffc020300c:	00004517          	auipc	a0,0x4
ffffffffc0203010:	9b450513          	addi	a0,a0,-1612 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203014:	c7afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203018:	00004697          	auipc	a3,0x4
ffffffffc020301c:	d1868693          	addi	a3,a3,-744 # ffffffffc0206d30 <default_pmm_manager+0x4c0>
ffffffffc0203020:	00003617          	auipc	a2,0x3
ffffffffc0203024:	4a060613          	addi	a2,a2,1184 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203028:	24c00593          	li	a1,588
ffffffffc020302c:	00004517          	auipc	a0,0x4
ffffffffc0203030:	99450513          	addi	a0,a0,-1644 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203034:	c5afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203038:	00004697          	auipc	a3,0x4
ffffffffc020303c:	d2868693          	addi	a3,a3,-728 # ffffffffc0206d60 <default_pmm_manager+0x4f0>
ffffffffc0203040:	00003617          	auipc	a2,0x3
ffffffffc0203044:	48060613          	addi	a2,a2,1152 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203048:	24b00593          	li	a1,587
ffffffffc020304c:	00004517          	auipc	a0,0x4
ffffffffc0203050:	97450513          	addi	a0,a0,-1676 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203054:	c3afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc0203058:	00004697          	auipc	a3,0x4
ffffffffc020305c:	df068693          	addi	a3,a3,-528 # ffffffffc0206e48 <default_pmm_manager+0x5d8>
ffffffffc0203060:	00003617          	auipc	a2,0x3
ffffffffc0203064:	46060613          	addi	a2,a2,1120 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203068:	26900593          	li	a1,617
ffffffffc020306c:	00004517          	auipc	a0,0x4
ffffffffc0203070:	95450513          	addi	a0,a0,-1708 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203074:	c1afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203078:	00004697          	auipc	a3,0x4
ffffffffc020307c:	d3068693          	addi	a3,a3,-720 # ffffffffc0206da8 <default_pmm_manager+0x538>
ffffffffc0203080:	00003617          	auipc	a2,0x3
ffffffffc0203084:	44060613          	addi	a2,a2,1088 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203088:	25600593          	li	a1,598
ffffffffc020308c:	00004517          	auipc	a0,0x4
ffffffffc0203090:	93450513          	addi	a0,a0,-1740 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203094:	bfafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203098:	00004697          	auipc	a3,0x4
ffffffffc020309c:	e0868693          	addi	a3,a3,-504 # ffffffffc0206ea0 <default_pmm_manager+0x630>
ffffffffc02030a0:	00003617          	auipc	a2,0x3
ffffffffc02030a4:	42060613          	addi	a2,a2,1056 # ffffffffc02064c0 <commands+0x858>
ffffffffc02030a8:	26e00593          	li	a1,622
ffffffffc02030ac:	00004517          	auipc	a0,0x4
ffffffffc02030b0:	91450513          	addi	a0,a0,-1772 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02030b4:	bdafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02030b8:	00004697          	auipc	a3,0x4
ffffffffc02030bc:	da868693          	addi	a3,a3,-600 # ffffffffc0206e60 <default_pmm_manager+0x5f0>
ffffffffc02030c0:	00003617          	auipc	a2,0x3
ffffffffc02030c4:	40060613          	addi	a2,a2,1024 # ffffffffc02064c0 <commands+0x858>
ffffffffc02030c8:	26d00593          	li	a1,621
ffffffffc02030cc:	00004517          	auipc	a0,0x4
ffffffffc02030d0:	8f450513          	addi	a0,a0,-1804 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02030d4:	bbafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02030d8:	00004697          	auipc	a3,0x4
ffffffffc02030dc:	c5868693          	addi	a3,a3,-936 # ffffffffc0206d30 <default_pmm_manager+0x4c0>
ffffffffc02030e0:	00003617          	auipc	a2,0x3
ffffffffc02030e4:	3e060613          	addi	a2,a2,992 # ffffffffc02064c0 <commands+0x858>
ffffffffc02030e8:	24800593          	li	a1,584
ffffffffc02030ec:	00004517          	auipc	a0,0x4
ffffffffc02030f0:	8d450513          	addi	a0,a0,-1836 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02030f4:	b9afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02030f8:	00004697          	auipc	a3,0x4
ffffffffc02030fc:	ad868693          	addi	a3,a3,-1320 # ffffffffc0206bd0 <default_pmm_manager+0x360>
ffffffffc0203100:	00003617          	auipc	a2,0x3
ffffffffc0203104:	3c060613          	addi	a2,a2,960 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203108:	24700593          	li	a1,583
ffffffffc020310c:	00004517          	auipc	a0,0x4
ffffffffc0203110:	8b450513          	addi	a0,a0,-1868 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203114:	b7afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203118:	00004697          	auipc	a3,0x4
ffffffffc020311c:	c3068693          	addi	a3,a3,-976 # ffffffffc0206d48 <default_pmm_manager+0x4d8>
ffffffffc0203120:	00003617          	auipc	a2,0x3
ffffffffc0203124:	3a060613          	addi	a2,a2,928 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203128:	24400593          	li	a1,580
ffffffffc020312c:	00004517          	auipc	a0,0x4
ffffffffc0203130:	89450513          	addi	a0,a0,-1900 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203134:	b5afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203138:	00004697          	auipc	a3,0x4
ffffffffc020313c:	a8068693          	addi	a3,a3,-1408 # ffffffffc0206bb8 <default_pmm_manager+0x348>
ffffffffc0203140:	00003617          	auipc	a2,0x3
ffffffffc0203144:	38060613          	addi	a2,a2,896 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203148:	24300593          	li	a1,579
ffffffffc020314c:	00004517          	auipc	a0,0x4
ffffffffc0203150:	87450513          	addi	a0,a0,-1932 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203154:	b3afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203158:	00004697          	auipc	a3,0x4
ffffffffc020315c:	b0068693          	addi	a3,a3,-1280 # ffffffffc0206c58 <default_pmm_manager+0x3e8>
ffffffffc0203160:	00003617          	auipc	a2,0x3
ffffffffc0203164:	36060613          	addi	a2,a2,864 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203168:	24200593          	li	a1,578
ffffffffc020316c:	00004517          	auipc	a0,0x4
ffffffffc0203170:	85450513          	addi	a0,a0,-1964 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203174:	b1afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203178:	00004697          	auipc	a3,0x4
ffffffffc020317c:	bb868693          	addi	a3,a3,-1096 # ffffffffc0206d30 <default_pmm_manager+0x4c0>
ffffffffc0203180:	00003617          	auipc	a2,0x3
ffffffffc0203184:	34060613          	addi	a2,a2,832 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203188:	24100593          	li	a1,577
ffffffffc020318c:	00004517          	auipc	a0,0x4
ffffffffc0203190:	83450513          	addi	a0,a0,-1996 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203194:	afafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203198:	00004697          	auipc	a3,0x4
ffffffffc020319c:	b8068693          	addi	a3,a3,-1152 # ffffffffc0206d18 <default_pmm_manager+0x4a8>
ffffffffc02031a0:	00003617          	auipc	a2,0x3
ffffffffc02031a4:	32060613          	addi	a2,a2,800 # ffffffffc02064c0 <commands+0x858>
ffffffffc02031a8:	24000593          	li	a1,576
ffffffffc02031ac:	00004517          	auipc	a0,0x4
ffffffffc02031b0:	81450513          	addi	a0,a0,-2028 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02031b4:	adafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc02031b8:	00004697          	auipc	a3,0x4
ffffffffc02031bc:	b3068693          	addi	a3,a3,-1232 # ffffffffc0206ce8 <default_pmm_manager+0x478>
ffffffffc02031c0:	00003617          	auipc	a2,0x3
ffffffffc02031c4:	30060613          	addi	a2,a2,768 # ffffffffc02064c0 <commands+0x858>
ffffffffc02031c8:	23f00593          	li	a1,575
ffffffffc02031cc:	00003517          	auipc	a0,0x3
ffffffffc02031d0:	7f450513          	addi	a0,a0,2036 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02031d4:	abafd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02031d8:	00004697          	auipc	a3,0x4
ffffffffc02031dc:	af868693          	addi	a3,a3,-1288 # ffffffffc0206cd0 <default_pmm_manager+0x460>
ffffffffc02031e0:	00003617          	auipc	a2,0x3
ffffffffc02031e4:	2e060613          	addi	a2,a2,736 # ffffffffc02064c0 <commands+0x858>
ffffffffc02031e8:	23d00593          	li	a1,573
ffffffffc02031ec:	00003517          	auipc	a0,0x3
ffffffffc02031f0:	7d450513          	addi	a0,a0,2004 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02031f4:	a9afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc02031f8:	00004697          	auipc	a3,0x4
ffffffffc02031fc:	ab868693          	addi	a3,a3,-1352 # ffffffffc0206cb0 <default_pmm_manager+0x440>
ffffffffc0203200:	00003617          	auipc	a2,0x3
ffffffffc0203204:	2c060613          	addi	a2,a2,704 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203208:	23c00593          	li	a1,572
ffffffffc020320c:	00003517          	auipc	a0,0x3
ffffffffc0203210:	7b450513          	addi	a0,a0,1972 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203214:	a7afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203218:	00004697          	auipc	a3,0x4
ffffffffc020321c:	a8868693          	addi	a3,a3,-1400 # ffffffffc0206ca0 <default_pmm_manager+0x430>
ffffffffc0203220:	00003617          	auipc	a2,0x3
ffffffffc0203224:	2a060613          	addi	a2,a2,672 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203228:	23b00593          	li	a1,571
ffffffffc020322c:	00003517          	auipc	a0,0x3
ffffffffc0203230:	79450513          	addi	a0,a0,1940 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203234:	a5afd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203238:	00004697          	auipc	a3,0x4
ffffffffc020323c:	a5868693          	addi	a3,a3,-1448 # ffffffffc0206c90 <default_pmm_manager+0x420>
ffffffffc0203240:	00003617          	auipc	a2,0x3
ffffffffc0203244:	28060613          	addi	a2,a2,640 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203248:	23a00593          	li	a1,570
ffffffffc020324c:	00003517          	auipc	a0,0x3
ffffffffc0203250:	77450513          	addi	a0,a0,1908 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203254:	a3afd0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("DTB memory info not available");
ffffffffc0203258:	00003617          	auipc	a2,0x3
ffffffffc020325c:	7d860613          	addi	a2,a2,2008 # ffffffffc0206a30 <default_pmm_manager+0x1c0>
ffffffffc0203260:	06500593          	li	a1,101
ffffffffc0203264:	00003517          	auipc	a0,0x3
ffffffffc0203268:	75c50513          	addi	a0,a0,1884 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc020326c:	a22fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203270:	00004697          	auipc	a3,0x4
ffffffffc0203274:	b3868693          	addi	a3,a3,-1224 # ffffffffc0206da8 <default_pmm_manager+0x538>
ffffffffc0203278:	00003617          	auipc	a2,0x3
ffffffffc020327c:	24860613          	addi	a2,a2,584 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203280:	28000593          	li	a1,640
ffffffffc0203284:	00003517          	auipc	a0,0x3
ffffffffc0203288:	73c50513          	addi	a0,a0,1852 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc020328c:	a02fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203290:	00004697          	auipc	a3,0x4
ffffffffc0203294:	9c868693          	addi	a3,a3,-1592 # ffffffffc0206c58 <default_pmm_manager+0x3e8>
ffffffffc0203298:	00003617          	auipc	a2,0x3
ffffffffc020329c:	22860613          	addi	a2,a2,552 # ffffffffc02064c0 <commands+0x858>
ffffffffc02032a0:	23900593          	li	a1,569
ffffffffc02032a4:	00003517          	auipc	a0,0x3
ffffffffc02032a8:	71c50513          	addi	a0,a0,1820 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02032ac:	9e2fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02032b0:	00004697          	auipc	a3,0x4
ffffffffc02032b4:	96868693          	addi	a3,a3,-1688 # ffffffffc0206c18 <default_pmm_manager+0x3a8>
ffffffffc02032b8:	00003617          	auipc	a2,0x3
ffffffffc02032bc:	20860613          	addi	a2,a2,520 # ffffffffc02064c0 <commands+0x858>
ffffffffc02032c0:	23800593          	li	a1,568
ffffffffc02032c4:	00003517          	auipc	a0,0x3
ffffffffc02032c8:	6fc50513          	addi	a0,a0,1788 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02032cc:	9c2fd0ef          	jal	ra,ffffffffc020048e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02032d0:	86d6                	mv	a3,s5
ffffffffc02032d2:	00003617          	auipc	a2,0x3
ffffffffc02032d6:	5d660613          	addi	a2,a2,1494 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc02032da:	23400593          	li	a1,564
ffffffffc02032de:	00003517          	auipc	a0,0x3
ffffffffc02032e2:	6e250513          	addi	a0,a0,1762 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02032e6:	9a8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc02032ea:	00003617          	auipc	a2,0x3
ffffffffc02032ee:	5be60613          	addi	a2,a2,1470 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc02032f2:	23300593          	li	a1,563
ffffffffc02032f6:	00003517          	auipc	a0,0x3
ffffffffc02032fa:	6ca50513          	addi	a0,a0,1738 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02032fe:	990fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203302:	00004697          	auipc	a3,0x4
ffffffffc0203306:	8ce68693          	addi	a3,a3,-1842 # ffffffffc0206bd0 <default_pmm_manager+0x360>
ffffffffc020330a:	00003617          	auipc	a2,0x3
ffffffffc020330e:	1b660613          	addi	a2,a2,438 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203312:	23100593          	li	a1,561
ffffffffc0203316:	00003517          	auipc	a0,0x3
ffffffffc020331a:	6aa50513          	addi	a0,a0,1706 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc020331e:	970fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203322:	00004697          	auipc	a3,0x4
ffffffffc0203326:	89668693          	addi	a3,a3,-1898 # ffffffffc0206bb8 <default_pmm_manager+0x348>
ffffffffc020332a:	00003617          	auipc	a2,0x3
ffffffffc020332e:	19660613          	addi	a2,a2,406 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203332:	23000593          	li	a1,560
ffffffffc0203336:	00003517          	auipc	a0,0x3
ffffffffc020333a:	68a50513          	addi	a0,a0,1674 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc020333e:	950fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203342:	00004697          	auipc	a3,0x4
ffffffffc0203346:	c2668693          	addi	a3,a3,-986 # ffffffffc0206f68 <default_pmm_manager+0x6f8>
ffffffffc020334a:	00003617          	auipc	a2,0x3
ffffffffc020334e:	17660613          	addi	a2,a2,374 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203352:	27700593          	li	a1,631
ffffffffc0203356:	00003517          	auipc	a0,0x3
ffffffffc020335a:	66a50513          	addi	a0,a0,1642 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc020335e:	930fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203362:	00004697          	auipc	a3,0x4
ffffffffc0203366:	bce68693          	addi	a3,a3,-1074 # ffffffffc0206f30 <default_pmm_manager+0x6c0>
ffffffffc020336a:	00003617          	auipc	a2,0x3
ffffffffc020336e:	15660613          	addi	a2,a2,342 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203372:	27400593          	li	a1,628
ffffffffc0203376:	00003517          	auipc	a0,0x3
ffffffffc020337a:	64a50513          	addi	a0,a0,1610 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc020337e:	910fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203382:	00004697          	auipc	a3,0x4
ffffffffc0203386:	b7e68693          	addi	a3,a3,-1154 # ffffffffc0206f00 <default_pmm_manager+0x690>
ffffffffc020338a:	00003617          	auipc	a2,0x3
ffffffffc020338e:	13660613          	addi	a2,a2,310 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203392:	27000593          	li	a1,624
ffffffffc0203396:	00003517          	auipc	a0,0x3
ffffffffc020339a:	62a50513          	addi	a0,a0,1578 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc020339e:	8f0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02033a2:	00004697          	auipc	a3,0x4
ffffffffc02033a6:	b1668693          	addi	a3,a3,-1258 # ffffffffc0206eb8 <default_pmm_manager+0x648>
ffffffffc02033aa:	00003617          	auipc	a2,0x3
ffffffffc02033ae:	11660613          	addi	a2,a2,278 # ffffffffc02064c0 <commands+0x858>
ffffffffc02033b2:	26f00593          	li	a1,623
ffffffffc02033b6:	00003517          	auipc	a0,0x3
ffffffffc02033ba:	60a50513          	addi	a0,a0,1546 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02033be:	8d0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02033c2:	00003617          	auipc	a2,0x3
ffffffffc02033c6:	58e60613          	addi	a2,a2,1422 # ffffffffc0206950 <default_pmm_manager+0xe0>
ffffffffc02033ca:	0c900593          	li	a1,201
ffffffffc02033ce:	00003517          	auipc	a0,0x3
ffffffffc02033d2:	5f250513          	addi	a0,a0,1522 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02033d6:	8b8fd0ef          	jal	ra,ffffffffc020048e <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02033da:	00003617          	auipc	a2,0x3
ffffffffc02033de:	57660613          	addi	a2,a2,1398 # ffffffffc0206950 <default_pmm_manager+0xe0>
ffffffffc02033e2:	08100593          	li	a1,129
ffffffffc02033e6:	00003517          	auipc	a0,0x3
ffffffffc02033ea:	5da50513          	addi	a0,a0,1498 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02033ee:	8a0fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02033f2:	00003697          	auipc	a3,0x3
ffffffffc02033f6:	79668693          	addi	a3,a3,1942 # ffffffffc0206b88 <default_pmm_manager+0x318>
ffffffffc02033fa:	00003617          	auipc	a2,0x3
ffffffffc02033fe:	0c660613          	addi	a2,a2,198 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203402:	22f00593          	li	a1,559
ffffffffc0203406:	00003517          	auipc	a0,0x3
ffffffffc020340a:	5ba50513          	addi	a0,a0,1466 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc020340e:	880fd0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203412:	00003697          	auipc	a3,0x3
ffffffffc0203416:	74668693          	addi	a3,a3,1862 # ffffffffc0206b58 <default_pmm_manager+0x2e8>
ffffffffc020341a:	00003617          	auipc	a2,0x3
ffffffffc020341e:	0a660613          	addi	a2,a2,166 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203422:	22c00593          	li	a1,556
ffffffffc0203426:	00003517          	auipc	a0,0x3
ffffffffc020342a:	59a50513          	addi	a0,a0,1434 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc020342e:	860fd0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203432 <copy_range>:
{
ffffffffc0203432:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203434:	00d667b3          	or	a5,a2,a3
{
ffffffffc0203438:	fc86                	sd	ra,120(sp)
ffffffffc020343a:	f8a2                	sd	s0,112(sp)
ffffffffc020343c:	f4a6                	sd	s1,104(sp)
ffffffffc020343e:	f0ca                	sd	s2,96(sp)
ffffffffc0203440:	ecce                	sd	s3,88(sp)
ffffffffc0203442:	e8d2                	sd	s4,80(sp)
ffffffffc0203444:	e4d6                	sd	s5,72(sp)
ffffffffc0203446:	e0da                	sd	s6,64(sp)
ffffffffc0203448:	fc5e                	sd	s7,56(sp)
ffffffffc020344a:	f862                	sd	s8,48(sp)
ffffffffc020344c:	f466                	sd	s9,40(sp)
ffffffffc020344e:	f06a                	sd	s10,32(sp)
ffffffffc0203450:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203452:	17d2                	slli	a5,a5,0x34
ffffffffc0203454:	20079f63          	bnez	a5,ffffffffc0203672 <copy_range+0x240>
    assert(USER_ACCESS(start, end));
ffffffffc0203458:	002007b7          	lui	a5,0x200
ffffffffc020345c:	8432                	mv	s0,a2
ffffffffc020345e:	1ef66a63          	bltu	a2,a5,ffffffffc0203652 <copy_range+0x220>
ffffffffc0203462:	84b6                	mv	s1,a3
ffffffffc0203464:	1ed67763          	bgeu	a2,a3,ffffffffc0203652 <copy_range+0x220>
ffffffffc0203468:	4785                	li	a5,1
ffffffffc020346a:	07fe                	slli	a5,a5,0x1f
ffffffffc020346c:	1ed7e363          	bltu	a5,a3,ffffffffc0203652 <copy_range+0x220>
ffffffffc0203470:	5c7d                	li	s8,-1
ffffffffc0203472:	00cc5793          	srli	a5,s8,0xc
ffffffffc0203476:	8a2a                	mv	s4,a0
ffffffffc0203478:	892e                	mv	s2,a1
ffffffffc020347a:	8aba                	mv	s5,a4
        start += PGSIZE;
ffffffffc020347c:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage)
ffffffffc020347e:	000c7b97          	auipc	s7,0xc7
ffffffffc0203482:	972b8b93          	addi	s7,s7,-1678 # ffffffffc02c9df0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203486:	000c7b17          	auipc	s6,0xc7
ffffffffc020348a:	972b0b13          	addi	s6,s6,-1678 # ffffffffc02c9df8 <pages>
ffffffffc020348e:	fff80cb7          	lui	s9,0xfff80
    return KADDR(page2pa(page));
ffffffffc0203492:	e03e                	sd	a5,0(sp)
        page = pmm_manager->alloc_pages(n);
ffffffffc0203494:	000c7d17          	auipc	s10,0xc7
ffffffffc0203498:	96cd0d13          	addi	s10,s10,-1684 # ffffffffc02c9e00 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020349c:	4601                	li	a2,0
ffffffffc020349e:	85a2                	mv	a1,s0
ffffffffc02034a0:	854a                	mv	a0,s2
ffffffffc02034a2:	b6bfe0ef          	jal	ra,ffffffffc020200c <get_pte>
ffffffffc02034a6:	8c2a                	mv	s8,a0
        if (ptep == NULL)
ffffffffc02034a8:	c945                	beqz	a0,ffffffffc0203558 <copy_range+0x126>
        if (*ptep & PTE_V)
ffffffffc02034aa:	6118                	ld	a4,0(a0)
ffffffffc02034ac:	8b05                	andi	a4,a4,1
ffffffffc02034ae:	e705                	bnez	a4,ffffffffc02034d6 <copy_range+0xa4>
        start += PGSIZE;
ffffffffc02034b0:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc02034b2:	fe9465e3          	bltu	s0,s1,ffffffffc020349c <copy_range+0x6a>
    return 0;
ffffffffc02034b6:	4501                	li	a0,0
}
ffffffffc02034b8:	70e6                	ld	ra,120(sp)
ffffffffc02034ba:	7446                	ld	s0,112(sp)
ffffffffc02034bc:	74a6                	ld	s1,104(sp)
ffffffffc02034be:	7906                	ld	s2,96(sp)
ffffffffc02034c0:	69e6                	ld	s3,88(sp)
ffffffffc02034c2:	6a46                	ld	s4,80(sp)
ffffffffc02034c4:	6aa6                	ld	s5,72(sp)
ffffffffc02034c6:	6b06                	ld	s6,64(sp)
ffffffffc02034c8:	7be2                	ld	s7,56(sp)
ffffffffc02034ca:	7c42                	ld	s8,48(sp)
ffffffffc02034cc:	7ca2                	ld	s9,40(sp)
ffffffffc02034ce:	7d02                	ld	s10,32(sp)
ffffffffc02034d0:	6de2                	ld	s11,24(sp)
ffffffffc02034d2:	6109                	addi	sp,sp,128
ffffffffc02034d4:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc02034d6:	4605                	li	a2,1
ffffffffc02034d8:	85a2                	mv	a1,s0
ffffffffc02034da:	8552                	mv	a0,s4
ffffffffc02034dc:	b31fe0ef          	jal	ra,ffffffffc020200c <get_pte>
ffffffffc02034e0:	12050f63          	beqz	a0,ffffffffc020361e <copy_range+0x1ec>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02034e4:	000c3783          	ld	a5,0(s8)
    if (!(pte & PTE_V))
ffffffffc02034e8:	0017f613          	andi	a2,a5,1
ffffffffc02034ec:	0007871b          	sext.w	a4,a5
ffffffffc02034f0:	01f7fc13          	andi	s8,a5,31
ffffffffc02034f4:	14060363          	beqz	a2,ffffffffc020363a <copy_range+0x208>
    if (PPN(pa) >= npage)
ffffffffc02034f8:	000bb603          	ld	a2,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc02034fc:	078a                	slli	a5,a5,0x2
ffffffffc02034fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203500:	12c7f163          	bgeu	a5,a2,ffffffffc0203622 <copy_range+0x1f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0203504:	000b3583          	ld	a1,0(s6)
ffffffffc0203508:	97e6                	add	a5,a5,s9
ffffffffc020350a:	079a                	slli	a5,a5,0x6
ffffffffc020350c:	95be                	add	a1,a1,a5
            if (share)
ffffffffc020350e:	040a8f63          	beqz	s5,ffffffffc020356c <copy_range+0x13a>
                if (perm & PTE_W) {
ffffffffc0203512:	00477793          	andi	a5,a4,4
ffffffffc0203516:	cb99                	beqz	a5,ffffffffc020352c <copy_range+0xfa>
                    perm &= ~PTE_W;
ffffffffc0203518:	01b77c13          	andi	s8,a4,27
                    ret = page_insert(from, page, start, perm);
ffffffffc020351c:	86e2                	mv	a3,s8
ffffffffc020351e:	8622                	mv	a2,s0
ffffffffc0203520:	854a                	mv	a0,s2
ffffffffc0203522:	e42e                	sd	a1,8(sp)
ffffffffc0203524:	9d8ff0ef          	jal	ra,ffffffffc02026fc <page_insert>
                    if (ret != 0) return ret;
ffffffffc0203528:	65a2                	ld	a1,8(sp)
ffffffffc020352a:	f559                	bnez	a0,ffffffffc02034b8 <copy_range+0x86>
                ret = page_insert(to, page, start, perm);
ffffffffc020352c:	86e2                	mv	a3,s8
ffffffffc020352e:	8622                	mv	a2,s0
ffffffffc0203530:	8552                	mv	a0,s4
ffffffffc0203532:	9caff0ef          	jal	ra,ffffffffc02026fc <page_insert>
                assert(ret == 0);
ffffffffc0203536:	dd2d                	beqz	a0,ffffffffc02034b0 <copy_range+0x7e>
ffffffffc0203538:	00004697          	auipc	a3,0x4
ffffffffc020353c:	a7868693          	addi	a3,a3,-1416 # ffffffffc0206fb0 <default_pmm_manager+0x740>
ffffffffc0203540:	00003617          	auipc	a2,0x3
ffffffffc0203544:	f8060613          	addi	a2,a2,-128 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203548:	1a200593          	li	a1,418
ffffffffc020354c:	00003517          	auipc	a0,0x3
ffffffffc0203550:	47450513          	addi	a0,a0,1140 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203554:	f3bfc0ef          	jal	ra,ffffffffc020048e <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203558:	00200637          	lui	a2,0x200
ffffffffc020355c:	9432                	add	s0,s0,a2
ffffffffc020355e:	ffe00637          	lui	a2,0xffe00
ffffffffc0203562:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc0203564:	d829                	beqz	s0,ffffffffc02034b6 <copy_range+0x84>
ffffffffc0203566:	f2946be3          	bltu	s0,s1,ffffffffc020349c <copy_range+0x6a>
ffffffffc020356a:	b7b1                	j	ffffffffc02034b6 <copy_range+0x84>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020356c:	100027f3          	csrr	a5,sstatus
ffffffffc0203570:	8b89                	andi	a5,a5,2
ffffffffc0203572:	e42e                	sd	a1,8(sp)
ffffffffc0203574:	ebc9                	bnez	a5,ffffffffc0203606 <copy_range+0x1d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203576:	000d3783          	ld	a5,0(s10)
ffffffffc020357a:	4505                	li	a0,1
ffffffffc020357c:	6f9c                	ld	a5,24(a5)
ffffffffc020357e:	9782                	jalr	a5
ffffffffc0203580:	65a2                	ld	a1,8(sp)
ffffffffc0203582:	8daa                	mv	s11,a0
                assert(page != NULL);
ffffffffc0203584:	10058763          	beqz	a1,ffffffffc0203692 <copy_range+0x260>
                assert(npage != NULL);
ffffffffc0203588:	140d8f63          	beqz	s11,ffffffffc02036e6 <copy_range+0x2b4>
    return page - pages + nbase;
ffffffffc020358c:	000b3703          	ld	a4,0(s6)
    return KADDR(page2pa(page));
ffffffffc0203590:	6682                	ld	a3,0(sp)
    return page - pages + nbase;
ffffffffc0203592:	000808b7          	lui	a7,0x80
ffffffffc0203596:	40e587b3          	sub	a5,a1,a4
ffffffffc020359a:	8799                	srai	a5,a5,0x6
    return KADDR(page2pa(page));
ffffffffc020359c:	000bb603          	ld	a2,0(s7)
    return page - pages + nbase;
ffffffffc02035a0:	97c6                	add	a5,a5,a7
    return KADDR(page2pa(page));
ffffffffc02035a2:	00d7f5b3          	and	a1,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02035a6:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02035a8:	12c5f263          	bgeu	a1,a2,ffffffffc02036cc <copy_range+0x29a>
ffffffffc02035ac:	000c7697          	auipc	a3,0xc7
ffffffffc02035b0:	85c68693          	addi	a3,a3,-1956 # ffffffffc02c9e08 <va_pa_offset>
ffffffffc02035b4:	6288                	ld	a0,0(a3)
    return page - pages + nbase;
ffffffffc02035b6:	40ed8733          	sub	a4,s11,a4
    return KADDR(page2pa(page));
ffffffffc02035ba:	6682                	ld	a3,0(sp)
    return page - pages + nbase;
ffffffffc02035bc:	8719                	srai	a4,a4,0x6
ffffffffc02035be:	9746                	add	a4,a4,a7
    return KADDR(page2pa(page));
ffffffffc02035c0:	00d778b3          	and	a7,a4,a3
ffffffffc02035c4:	00a785b3          	add	a1,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02035c8:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc02035ca:	0ec8f463          	bgeu	a7,a2,ffffffffc02036b2 <copy_range+0x280>
                memcpy(kva_dst, kva_src, PGSIZE);
ffffffffc02035ce:	6605                	lui	a2,0x1
ffffffffc02035d0:	953a                	add	a0,a0,a4
ffffffffc02035d2:	412020ef          	jal	ra,ffffffffc02059e4 <memcpy>
                ret = page_insert(to, npage, start, perm);
ffffffffc02035d6:	86e2                	mv	a3,s8
ffffffffc02035d8:	8622                	mv	a2,s0
ffffffffc02035da:	85ee                	mv	a1,s11
ffffffffc02035dc:	8552                	mv	a0,s4
ffffffffc02035de:	91eff0ef          	jal	ra,ffffffffc02026fc <page_insert>
                assert(ret == 0);
ffffffffc02035e2:	ec0507e3          	beqz	a0,ffffffffc02034b0 <copy_range+0x7e>
ffffffffc02035e6:	00004697          	auipc	a3,0x4
ffffffffc02035ea:	9ca68693          	addi	a3,a3,-1590 # ffffffffc0206fb0 <default_pmm_manager+0x740>
ffffffffc02035ee:	00003617          	auipc	a2,0x3
ffffffffc02035f2:	ed260613          	addi	a2,a2,-302 # ffffffffc02064c0 <commands+0x858>
ffffffffc02035f6:	1c100593          	li	a1,449
ffffffffc02035fa:	00003517          	auipc	a0,0x3
ffffffffc02035fe:	3c650513          	addi	a0,a0,966 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203602:	e8dfc0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_disable();
ffffffffc0203606:	baefd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020360a:	000d3783          	ld	a5,0(s10)
ffffffffc020360e:	4505                	li	a0,1
ffffffffc0203610:	6f9c                	ld	a5,24(a5)
ffffffffc0203612:	9782                	jalr	a5
ffffffffc0203614:	8daa                	mv	s11,a0
        intr_enable();
ffffffffc0203616:	b98fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020361a:	65a2                	ld	a1,8(sp)
ffffffffc020361c:	b7a5                	j	ffffffffc0203584 <copy_range+0x152>
                return -E_NO_MEM;
ffffffffc020361e:	5571                	li	a0,-4
ffffffffc0203620:	bd61                	j	ffffffffc02034b8 <copy_range+0x86>
        panic("pa2page called with invalid pa");
ffffffffc0203622:	00003617          	auipc	a2,0x3
ffffffffc0203626:	35660613          	addi	a2,a2,854 # ffffffffc0206978 <default_pmm_manager+0x108>
ffffffffc020362a:	06900593          	li	a1,105
ffffffffc020362e:	00003517          	auipc	a0,0x3
ffffffffc0203632:	2a250513          	addi	a0,a0,674 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc0203636:	e59fc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020363a:	00003617          	auipc	a2,0x3
ffffffffc020363e:	35e60613          	addi	a2,a2,862 # ffffffffc0206998 <default_pmm_manager+0x128>
ffffffffc0203642:	07f00593          	li	a1,127
ffffffffc0203646:	00003517          	auipc	a0,0x3
ffffffffc020364a:	28a50513          	addi	a0,a0,650 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc020364e:	e41fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203652:	00003697          	auipc	a3,0x3
ffffffffc0203656:	3ae68693          	addi	a3,a3,942 # ffffffffc0206a00 <default_pmm_manager+0x190>
ffffffffc020365a:	00003617          	auipc	a2,0x3
ffffffffc020365e:	e6660613          	addi	a2,a2,-410 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203662:	17b00593          	li	a1,379
ffffffffc0203666:	00003517          	auipc	a0,0x3
ffffffffc020366a:	35a50513          	addi	a0,a0,858 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc020366e:	e21fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203672:	00003697          	auipc	a3,0x3
ffffffffc0203676:	35e68693          	addi	a3,a3,862 # ffffffffc02069d0 <default_pmm_manager+0x160>
ffffffffc020367a:	00003617          	auipc	a2,0x3
ffffffffc020367e:	e4660613          	addi	a2,a2,-442 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203682:	17a00593          	li	a1,378
ffffffffc0203686:	00003517          	auipc	a0,0x3
ffffffffc020368a:	33a50513          	addi	a0,a0,826 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc020368e:	e01fc0ef          	jal	ra,ffffffffc020048e <__panic>
                assert(page != NULL);
ffffffffc0203692:	00004697          	auipc	a3,0x4
ffffffffc0203696:	92e68693          	addi	a3,a3,-1746 # ffffffffc0206fc0 <default_pmm_manager+0x750>
ffffffffc020369a:	00003617          	auipc	a2,0x3
ffffffffc020369e:	e2660613          	addi	a2,a2,-474 # ffffffffc02064c0 <commands+0x858>
ffffffffc02036a2:	1aa00593          	li	a1,426
ffffffffc02036a6:	00003517          	auipc	a0,0x3
ffffffffc02036aa:	31a50513          	addi	a0,a0,794 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02036ae:	de1fc0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc02036b2:	86ba                	mv	a3,a4
ffffffffc02036b4:	00003617          	auipc	a2,0x3
ffffffffc02036b8:	1f460613          	addi	a2,a2,500 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc02036bc:	07100593          	li	a1,113
ffffffffc02036c0:	00003517          	auipc	a0,0x3
ffffffffc02036c4:	21050513          	addi	a0,a0,528 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc02036c8:	dc7fc0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc02036cc:	86be                	mv	a3,a5
ffffffffc02036ce:	00003617          	auipc	a2,0x3
ffffffffc02036d2:	1da60613          	addi	a2,a2,474 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc02036d6:	07100593          	li	a1,113
ffffffffc02036da:	00003517          	auipc	a0,0x3
ffffffffc02036de:	1f650513          	addi	a0,a0,502 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc02036e2:	dadfc0ef          	jal	ra,ffffffffc020048e <__panic>
                assert(npage != NULL);
ffffffffc02036e6:	00004697          	auipc	a3,0x4
ffffffffc02036ea:	8ea68693          	addi	a3,a3,-1814 # ffffffffc0206fd0 <default_pmm_manager+0x760>
ffffffffc02036ee:	00003617          	auipc	a2,0x3
ffffffffc02036f2:	dd260613          	addi	a2,a2,-558 # ffffffffc02064c0 <commands+0x858>
ffffffffc02036f6:	1ab00593          	li	a1,427
ffffffffc02036fa:	00003517          	auipc	a0,0x3
ffffffffc02036fe:	2c650513          	addi	a0,a0,710 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc0203702:	d8dfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203706 <pgdir_alloc_page>:
{
ffffffffc0203706:	7179                	addi	sp,sp,-48
ffffffffc0203708:	ec26                	sd	s1,24(sp)
ffffffffc020370a:	e84a                	sd	s2,16(sp)
ffffffffc020370c:	e052                	sd	s4,0(sp)
ffffffffc020370e:	f406                	sd	ra,40(sp)
ffffffffc0203710:	f022                	sd	s0,32(sp)
ffffffffc0203712:	e44e                	sd	s3,8(sp)
ffffffffc0203714:	8a2a                	mv	s4,a0
ffffffffc0203716:	84ae                	mv	s1,a1
ffffffffc0203718:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020371a:	100027f3          	csrr	a5,sstatus
ffffffffc020371e:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc0203720:	000c6997          	auipc	s3,0xc6
ffffffffc0203724:	6e098993          	addi	s3,s3,1760 # ffffffffc02c9e00 <pmm_manager>
ffffffffc0203728:	ef8d                	bnez	a5,ffffffffc0203762 <pgdir_alloc_page+0x5c>
ffffffffc020372a:	0009b783          	ld	a5,0(s3)
ffffffffc020372e:	4505                	li	a0,1
ffffffffc0203730:	6f9c                	ld	a5,24(a5)
ffffffffc0203732:	9782                	jalr	a5
ffffffffc0203734:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc0203736:	cc09                	beqz	s0,ffffffffc0203750 <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203738:	86ca                	mv	a3,s2
ffffffffc020373a:	8626                	mv	a2,s1
ffffffffc020373c:	85a2                	mv	a1,s0
ffffffffc020373e:	8552                	mv	a0,s4
ffffffffc0203740:	fbdfe0ef          	jal	ra,ffffffffc02026fc <page_insert>
ffffffffc0203744:	e915                	bnez	a0,ffffffffc0203778 <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc0203746:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc0203748:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc020374a:	4785                	li	a5,1
ffffffffc020374c:	04f71e63          	bne	a4,a5,ffffffffc02037a8 <pgdir_alloc_page+0xa2>
}
ffffffffc0203750:	70a2                	ld	ra,40(sp)
ffffffffc0203752:	8522                	mv	a0,s0
ffffffffc0203754:	7402                	ld	s0,32(sp)
ffffffffc0203756:	64e2                	ld	s1,24(sp)
ffffffffc0203758:	6942                	ld	s2,16(sp)
ffffffffc020375a:	69a2                	ld	s3,8(sp)
ffffffffc020375c:	6a02                	ld	s4,0(sp)
ffffffffc020375e:	6145                	addi	sp,sp,48
ffffffffc0203760:	8082                	ret
        intr_disable();
ffffffffc0203762:	a52fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203766:	0009b783          	ld	a5,0(s3)
ffffffffc020376a:	4505                	li	a0,1
ffffffffc020376c:	6f9c                	ld	a5,24(a5)
ffffffffc020376e:	9782                	jalr	a5
ffffffffc0203770:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203772:	a3cfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203776:	b7c1                	j	ffffffffc0203736 <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203778:	100027f3          	csrr	a5,sstatus
ffffffffc020377c:	8b89                	andi	a5,a5,2
ffffffffc020377e:	eb89                	bnez	a5,ffffffffc0203790 <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc0203780:	0009b783          	ld	a5,0(s3)
ffffffffc0203784:	8522                	mv	a0,s0
ffffffffc0203786:	4585                	li	a1,1
ffffffffc0203788:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc020378a:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc020378c:	9782                	jalr	a5
    if (flag)
ffffffffc020378e:	b7c9                	j	ffffffffc0203750 <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc0203790:	a24fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0203794:	0009b783          	ld	a5,0(s3)
ffffffffc0203798:	8522                	mv	a0,s0
ffffffffc020379a:	4585                	li	a1,1
ffffffffc020379c:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc020379e:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02037a0:	9782                	jalr	a5
        intr_enable();
ffffffffc02037a2:	a0cfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02037a6:	b76d                	j	ffffffffc0203750 <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc02037a8:	00004697          	auipc	a3,0x4
ffffffffc02037ac:	83868693          	addi	a3,a3,-1992 # ffffffffc0206fe0 <default_pmm_manager+0x770>
ffffffffc02037b0:	00003617          	auipc	a2,0x3
ffffffffc02037b4:	d1060613          	addi	a2,a2,-752 # ffffffffc02064c0 <commands+0x858>
ffffffffc02037b8:	20d00593          	li	a1,525
ffffffffc02037bc:	00003517          	auipc	a0,0x3
ffffffffc02037c0:	20450513          	addi	a0,a0,516 # ffffffffc02069c0 <default_pmm_manager+0x150>
ffffffffc02037c4:	ccbfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02037c8 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02037c8:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02037ca:	00004697          	auipc	a3,0x4
ffffffffc02037ce:	82e68693          	addi	a3,a3,-2002 # ffffffffc0206ff8 <default_pmm_manager+0x788>
ffffffffc02037d2:	00003617          	auipc	a2,0x3
ffffffffc02037d6:	cee60613          	addi	a2,a2,-786 # ffffffffc02064c0 <commands+0x858>
ffffffffc02037da:	07400593          	li	a1,116
ffffffffc02037de:	00004517          	auipc	a0,0x4
ffffffffc02037e2:	83a50513          	addi	a0,a0,-1990 # ffffffffc0207018 <default_pmm_manager+0x7a8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02037e6:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02037e8:	ca7fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02037ec <mm_create>:
{
ffffffffc02037ec:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02037ee:	04000513          	li	a0,64
{
ffffffffc02037f2:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02037f4:	d82fe0ef          	jal	ra,ffffffffc0201d76 <kmalloc>
    if (mm != NULL)
ffffffffc02037f8:	cd19                	beqz	a0,ffffffffc0203816 <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc02037fa:	e508                	sd	a0,8(a0)
ffffffffc02037fc:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02037fe:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203802:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203806:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc020380a:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc020380e:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc0203812:	02053c23          	sd	zero,56(a0)
}
ffffffffc0203816:	60a2                	ld	ra,8(sp)
ffffffffc0203818:	0141                	addi	sp,sp,16
ffffffffc020381a:	8082                	ret

ffffffffc020381c <find_vma>:
{
ffffffffc020381c:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc020381e:	c505                	beqz	a0,ffffffffc0203846 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203820:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203822:	c501                	beqz	a0,ffffffffc020382a <find_vma+0xe>
ffffffffc0203824:	651c                	ld	a5,8(a0)
ffffffffc0203826:	02f5f263          	bgeu	a1,a5,ffffffffc020384a <find_vma+0x2e>
    return listelm->next;
ffffffffc020382a:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc020382c:	00f68d63          	beq	a3,a5,ffffffffc0203846 <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0203830:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_obj___user_exit_out_size+0x1f4e20>
ffffffffc0203834:	00e5e663          	bltu	a1,a4,ffffffffc0203840 <find_vma+0x24>
ffffffffc0203838:	ff07b703          	ld	a4,-16(a5)
ffffffffc020383c:	00e5ec63          	bltu	a1,a4,ffffffffc0203854 <find_vma+0x38>
ffffffffc0203840:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0203842:	fef697e3          	bne	a3,a5,ffffffffc0203830 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203846:	4501                	li	a0,0
}
ffffffffc0203848:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020384a:	691c                	ld	a5,16(a0)
ffffffffc020384c:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020382a <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203850:	ea88                	sd	a0,16(a3)
ffffffffc0203852:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0203854:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203858:	ea88                	sd	a0,16(a3)
ffffffffc020385a:	8082                	ret

ffffffffc020385c <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc020385c:	6590                	ld	a2,8(a1)
ffffffffc020385e:	0105b803          	ld	a6,16(a1)
{
ffffffffc0203862:	1141                	addi	sp,sp,-16
ffffffffc0203864:	e406                	sd	ra,8(sp)
ffffffffc0203866:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203868:	01066763          	bltu	a2,a6,ffffffffc0203876 <insert_vma_struct+0x1a>
ffffffffc020386c:	a085                	j	ffffffffc02038cc <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc020386e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203872:	04e66863          	bltu	a2,a4,ffffffffc02038c2 <insert_vma_struct+0x66>
ffffffffc0203876:	86be                	mv	a3,a5
ffffffffc0203878:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc020387a:	fef51ae3          	bne	a0,a5,ffffffffc020386e <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc020387e:	02a68463          	beq	a3,a0,ffffffffc02038a6 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203882:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203886:	fe86b883          	ld	a7,-24(a3)
ffffffffc020388a:	08e8f163          	bgeu	a7,a4,ffffffffc020390c <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020388e:	04e66f63          	bltu	a2,a4,ffffffffc02038ec <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc0203892:	00f50a63          	beq	a0,a5,ffffffffc02038a6 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0203896:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020389a:	05076963          	bltu	a4,a6,ffffffffc02038ec <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc020389e:	ff07b603          	ld	a2,-16(a5)
ffffffffc02038a2:	02c77363          	bgeu	a4,a2,ffffffffc02038c8 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc02038a6:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02038a8:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02038aa:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02038ae:	e390                	sd	a2,0(a5)
ffffffffc02038b0:	e690                	sd	a2,8(a3)
}
ffffffffc02038b2:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02038b4:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02038b6:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc02038b8:	0017079b          	addiw	a5,a4,1
ffffffffc02038bc:	d11c                	sw	a5,32(a0)
}
ffffffffc02038be:	0141                	addi	sp,sp,16
ffffffffc02038c0:	8082                	ret
    if (le_prev != list)
ffffffffc02038c2:	fca690e3          	bne	a3,a0,ffffffffc0203882 <insert_vma_struct+0x26>
ffffffffc02038c6:	bfd1                	j	ffffffffc020389a <insert_vma_struct+0x3e>
ffffffffc02038c8:	f01ff0ef          	jal	ra,ffffffffc02037c8 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02038cc:	00003697          	auipc	a3,0x3
ffffffffc02038d0:	75c68693          	addi	a3,a3,1884 # ffffffffc0207028 <default_pmm_manager+0x7b8>
ffffffffc02038d4:	00003617          	auipc	a2,0x3
ffffffffc02038d8:	bec60613          	addi	a2,a2,-1044 # ffffffffc02064c0 <commands+0x858>
ffffffffc02038dc:	07a00593          	li	a1,122
ffffffffc02038e0:	00003517          	auipc	a0,0x3
ffffffffc02038e4:	73850513          	addi	a0,a0,1848 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc02038e8:	ba7fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02038ec:	00003697          	auipc	a3,0x3
ffffffffc02038f0:	77c68693          	addi	a3,a3,1916 # ffffffffc0207068 <default_pmm_manager+0x7f8>
ffffffffc02038f4:	00003617          	auipc	a2,0x3
ffffffffc02038f8:	bcc60613          	addi	a2,a2,-1076 # ffffffffc02064c0 <commands+0x858>
ffffffffc02038fc:	07300593          	li	a1,115
ffffffffc0203900:	00003517          	auipc	a0,0x3
ffffffffc0203904:	71850513          	addi	a0,a0,1816 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203908:	b87fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020390c:	00003697          	auipc	a3,0x3
ffffffffc0203910:	73c68693          	addi	a3,a3,1852 # ffffffffc0207048 <default_pmm_manager+0x7d8>
ffffffffc0203914:	00003617          	auipc	a2,0x3
ffffffffc0203918:	bac60613          	addi	a2,a2,-1108 # ffffffffc02064c0 <commands+0x858>
ffffffffc020391c:	07200593          	li	a1,114
ffffffffc0203920:	00003517          	auipc	a0,0x3
ffffffffc0203924:	6f850513          	addi	a0,a0,1784 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203928:	b67fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020392c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc020392c:	591c                	lw	a5,48(a0)
{
ffffffffc020392e:	1141                	addi	sp,sp,-16
ffffffffc0203930:	e406                	sd	ra,8(sp)
ffffffffc0203932:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0203934:	e78d                	bnez	a5,ffffffffc020395e <mm_destroy+0x32>
ffffffffc0203936:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203938:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc020393a:	00a40c63          	beq	s0,a0,ffffffffc0203952 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020393e:	6118                	ld	a4,0(a0)
ffffffffc0203940:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0203942:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203944:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203946:	e398                	sd	a4,0(a5)
ffffffffc0203948:	cdefe0ef          	jal	ra,ffffffffc0201e26 <kfree>
    return listelm->next;
ffffffffc020394c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc020394e:	fea418e3          	bne	s0,a0,ffffffffc020393e <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc0203952:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0203954:	6402                	ld	s0,0(sp)
ffffffffc0203956:	60a2                	ld	ra,8(sp)
ffffffffc0203958:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc020395a:	cccfe06f          	j	ffffffffc0201e26 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020395e:	00003697          	auipc	a3,0x3
ffffffffc0203962:	72a68693          	addi	a3,a3,1834 # ffffffffc0207088 <default_pmm_manager+0x818>
ffffffffc0203966:	00003617          	auipc	a2,0x3
ffffffffc020396a:	b5a60613          	addi	a2,a2,-1190 # ffffffffc02064c0 <commands+0x858>
ffffffffc020396e:	09e00593          	li	a1,158
ffffffffc0203972:	00003517          	auipc	a0,0x3
ffffffffc0203976:	6a650513          	addi	a0,a0,1702 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc020397a:	b15fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020397e <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc020397e:	7139                	addi	sp,sp,-64
ffffffffc0203980:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203982:	6405                	lui	s0,0x1
ffffffffc0203984:	147d                	addi	s0,s0,-1
ffffffffc0203986:	77fd                	lui	a5,0xfffff
ffffffffc0203988:	9622                	add	a2,a2,s0
ffffffffc020398a:	962e                	add	a2,a2,a1
{
ffffffffc020398c:	f426                	sd	s1,40(sp)
ffffffffc020398e:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203990:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc0203994:	f04a                	sd	s2,32(sp)
ffffffffc0203996:	ec4e                	sd	s3,24(sp)
ffffffffc0203998:	e852                	sd	s4,16(sp)
ffffffffc020399a:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc020399c:	002005b7          	lui	a1,0x200
ffffffffc02039a0:	00f67433          	and	s0,a2,a5
ffffffffc02039a4:	06b4e363          	bltu	s1,a1,ffffffffc0203a0a <mm_map+0x8c>
ffffffffc02039a8:	0684f163          	bgeu	s1,s0,ffffffffc0203a0a <mm_map+0x8c>
ffffffffc02039ac:	4785                	li	a5,1
ffffffffc02039ae:	07fe                	slli	a5,a5,0x1f
ffffffffc02039b0:	0487ed63          	bltu	a5,s0,ffffffffc0203a0a <mm_map+0x8c>
ffffffffc02039b4:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02039b6:	cd21                	beqz	a0,ffffffffc0203a0e <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc02039b8:	85a6                	mv	a1,s1
ffffffffc02039ba:	8ab6                	mv	s5,a3
ffffffffc02039bc:	8a3a                	mv	s4,a4
ffffffffc02039be:	e5fff0ef          	jal	ra,ffffffffc020381c <find_vma>
ffffffffc02039c2:	c501                	beqz	a0,ffffffffc02039ca <mm_map+0x4c>
ffffffffc02039c4:	651c                	ld	a5,8(a0)
ffffffffc02039c6:	0487e263          	bltu	a5,s0,ffffffffc0203a0a <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039ca:	03000513          	li	a0,48
ffffffffc02039ce:	ba8fe0ef          	jal	ra,ffffffffc0201d76 <kmalloc>
ffffffffc02039d2:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02039d4:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc02039d6:	02090163          	beqz	s2,ffffffffc02039f8 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02039da:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02039dc:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02039e0:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02039e4:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02039e8:	85ca                	mv	a1,s2
ffffffffc02039ea:	e73ff0ef          	jal	ra,ffffffffc020385c <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02039ee:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc02039f0:	000a0463          	beqz	s4,ffffffffc02039f8 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc02039f4:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc02039f8:	70e2                	ld	ra,56(sp)
ffffffffc02039fa:	7442                	ld	s0,48(sp)
ffffffffc02039fc:	74a2                	ld	s1,40(sp)
ffffffffc02039fe:	7902                	ld	s2,32(sp)
ffffffffc0203a00:	69e2                	ld	s3,24(sp)
ffffffffc0203a02:	6a42                	ld	s4,16(sp)
ffffffffc0203a04:	6aa2                	ld	s5,8(sp)
ffffffffc0203a06:	6121                	addi	sp,sp,64
ffffffffc0203a08:	8082                	ret
        return -E_INVAL;
ffffffffc0203a0a:	5575                	li	a0,-3
ffffffffc0203a0c:	b7f5                	j	ffffffffc02039f8 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0203a0e:	00003697          	auipc	a3,0x3
ffffffffc0203a12:	69268693          	addi	a3,a3,1682 # ffffffffc02070a0 <default_pmm_manager+0x830>
ffffffffc0203a16:	00003617          	auipc	a2,0x3
ffffffffc0203a1a:	aaa60613          	addi	a2,a2,-1366 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203a1e:	0b300593          	li	a1,179
ffffffffc0203a22:	00003517          	auipc	a0,0x3
ffffffffc0203a26:	5f650513          	addi	a0,a0,1526 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203a2a:	a65fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203a2e <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0203a2e:	7139                	addi	sp,sp,-64
ffffffffc0203a30:	fc06                	sd	ra,56(sp)
ffffffffc0203a32:	f822                	sd	s0,48(sp)
ffffffffc0203a34:	f426                	sd	s1,40(sp)
ffffffffc0203a36:	f04a                	sd	s2,32(sp)
ffffffffc0203a38:	ec4e                	sd	s3,24(sp)
ffffffffc0203a3a:	e852                	sd	s4,16(sp)
ffffffffc0203a3c:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0203a3e:	c52d                	beqz	a0,ffffffffc0203aa8 <dup_mmap+0x7a>
ffffffffc0203a40:	892a                	mv	s2,a0
ffffffffc0203a42:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0203a44:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0203a46:	e595                	bnez	a1,ffffffffc0203a72 <dup_mmap+0x44>
ffffffffc0203a48:	a085                	j	ffffffffc0203aa8 <dup_mmap+0x7a>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0203a4a:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0203a4c:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4e40>
        vma->vm_end = vm_end;
ffffffffc0203a50:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0203a54:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0203a58:	e05ff0ef          	jal	ra,ffffffffc020385c <insert_vma_struct>

        bool share = 1;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0203a5c:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8c60>
ffffffffc0203a60:	fe843603          	ld	a2,-24(s0)
ffffffffc0203a64:	6c8c                	ld	a1,24(s1)
ffffffffc0203a66:	01893503          	ld	a0,24(s2)
ffffffffc0203a6a:	4705                	li	a4,1
ffffffffc0203a6c:	9c7ff0ef          	jal	ra,ffffffffc0203432 <copy_range>
ffffffffc0203a70:	e105                	bnez	a0,ffffffffc0203a90 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0203a72:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0203a74:	02848863          	beq	s1,s0,ffffffffc0203aa4 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a78:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0203a7c:	fe843a83          	ld	s5,-24(s0)
ffffffffc0203a80:	ff043a03          	ld	s4,-16(s0)
ffffffffc0203a84:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a88:	aeefe0ef          	jal	ra,ffffffffc0201d76 <kmalloc>
ffffffffc0203a8c:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc0203a8e:	fd55                	bnez	a0,ffffffffc0203a4a <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0203a90:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0203a92:	70e2                	ld	ra,56(sp)
ffffffffc0203a94:	7442                	ld	s0,48(sp)
ffffffffc0203a96:	74a2                	ld	s1,40(sp)
ffffffffc0203a98:	7902                	ld	s2,32(sp)
ffffffffc0203a9a:	69e2                	ld	s3,24(sp)
ffffffffc0203a9c:	6a42                	ld	s4,16(sp)
ffffffffc0203a9e:	6aa2                	ld	s5,8(sp)
ffffffffc0203aa0:	6121                	addi	sp,sp,64
ffffffffc0203aa2:	8082                	ret
    return 0;
ffffffffc0203aa4:	4501                	li	a0,0
ffffffffc0203aa6:	b7f5                	j	ffffffffc0203a92 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0203aa8:	00003697          	auipc	a3,0x3
ffffffffc0203aac:	60868693          	addi	a3,a3,1544 # ffffffffc02070b0 <default_pmm_manager+0x840>
ffffffffc0203ab0:	00003617          	auipc	a2,0x3
ffffffffc0203ab4:	a1060613          	addi	a2,a2,-1520 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203ab8:	0cf00593          	li	a1,207
ffffffffc0203abc:	00003517          	auipc	a0,0x3
ffffffffc0203ac0:	55c50513          	addi	a0,a0,1372 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203ac4:	9cbfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203ac8 <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc0203ac8:	1101                	addi	sp,sp,-32
ffffffffc0203aca:	ec06                	sd	ra,24(sp)
ffffffffc0203acc:	e822                	sd	s0,16(sp)
ffffffffc0203ace:	e426                	sd	s1,8(sp)
ffffffffc0203ad0:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203ad2:	c531                	beqz	a0,ffffffffc0203b1e <exit_mmap+0x56>
ffffffffc0203ad4:	591c                	lw	a5,48(a0)
ffffffffc0203ad6:	84aa                	mv	s1,a0
ffffffffc0203ad8:	e3b9                	bnez	a5,ffffffffc0203b1e <exit_mmap+0x56>
    return listelm->next;
ffffffffc0203ada:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0203adc:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0203ae0:	02850663          	beq	a0,s0,ffffffffc0203b0c <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203ae4:	ff043603          	ld	a2,-16(s0)
ffffffffc0203ae8:	fe843583          	ld	a1,-24(s0)
ffffffffc0203aec:	854a                	mv	a0,s2
ffffffffc0203aee:	f9afe0ef          	jal	ra,ffffffffc0202288 <unmap_range>
ffffffffc0203af2:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203af4:	fe8498e3          	bne	s1,s0,ffffffffc0203ae4 <exit_mmap+0x1c>
ffffffffc0203af8:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0203afa:	00848c63          	beq	s1,s0,ffffffffc0203b12 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203afe:	ff043603          	ld	a2,-16(s0)
ffffffffc0203b02:	fe843583          	ld	a1,-24(s0)
ffffffffc0203b06:	854a                	mv	a0,s2
ffffffffc0203b08:	8c7fe0ef          	jal	ra,ffffffffc02023ce <exit_range>
ffffffffc0203b0c:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203b0e:	fe8498e3          	bne	s1,s0,ffffffffc0203afe <exit_mmap+0x36>
    }
}
ffffffffc0203b12:	60e2                	ld	ra,24(sp)
ffffffffc0203b14:	6442                	ld	s0,16(sp)
ffffffffc0203b16:	64a2                	ld	s1,8(sp)
ffffffffc0203b18:	6902                	ld	s2,0(sp)
ffffffffc0203b1a:	6105                	addi	sp,sp,32
ffffffffc0203b1c:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203b1e:	00003697          	auipc	a3,0x3
ffffffffc0203b22:	5b268693          	addi	a3,a3,1458 # ffffffffc02070d0 <default_pmm_manager+0x860>
ffffffffc0203b26:	00003617          	auipc	a2,0x3
ffffffffc0203b2a:	99a60613          	addi	a2,a2,-1638 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203b2e:	0e800593          	li	a1,232
ffffffffc0203b32:	00003517          	auipc	a0,0x3
ffffffffc0203b36:	4e650513          	addi	a0,a0,1254 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203b3a:	955fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203b3e <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203b3e:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203b40:	04000513          	li	a0,64
{
ffffffffc0203b44:	fc06                	sd	ra,56(sp)
ffffffffc0203b46:	f822                	sd	s0,48(sp)
ffffffffc0203b48:	f426                	sd	s1,40(sp)
ffffffffc0203b4a:	f04a                	sd	s2,32(sp)
ffffffffc0203b4c:	ec4e                	sd	s3,24(sp)
ffffffffc0203b4e:	e852                	sd	s4,16(sp)
ffffffffc0203b50:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203b52:	a24fe0ef          	jal	ra,ffffffffc0201d76 <kmalloc>
    if (mm != NULL)
ffffffffc0203b56:	2e050663          	beqz	a0,ffffffffc0203e42 <vmm_init+0x304>
ffffffffc0203b5a:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0203b5c:	e508                	sd	a0,8(a0)
ffffffffc0203b5e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203b60:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203b64:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203b68:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203b6c:	02053423          	sd	zero,40(a0)
ffffffffc0203b70:	02052823          	sw	zero,48(a0)
ffffffffc0203b74:	02053c23          	sd	zero,56(a0)
ffffffffc0203b78:	03200413          	li	s0,50
ffffffffc0203b7c:	a811                	j	ffffffffc0203b90 <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc0203b7e:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203b80:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203b82:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc0203b86:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203b88:	8526                	mv	a0,s1
ffffffffc0203b8a:	cd3ff0ef          	jal	ra,ffffffffc020385c <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0203b8e:	c80d                	beqz	s0,ffffffffc0203bc0 <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203b90:	03000513          	li	a0,48
ffffffffc0203b94:	9e2fe0ef          	jal	ra,ffffffffc0201d76 <kmalloc>
ffffffffc0203b98:	85aa                	mv	a1,a0
ffffffffc0203b9a:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203b9e:	f165                	bnez	a0,ffffffffc0203b7e <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc0203ba0:	00003697          	auipc	a3,0x3
ffffffffc0203ba4:	6c868693          	addi	a3,a3,1736 # ffffffffc0207268 <default_pmm_manager+0x9f8>
ffffffffc0203ba8:	00003617          	auipc	a2,0x3
ffffffffc0203bac:	91860613          	addi	a2,a2,-1768 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203bb0:	12c00593          	li	a1,300
ffffffffc0203bb4:	00003517          	auipc	a0,0x3
ffffffffc0203bb8:	46450513          	addi	a0,a0,1124 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203bbc:	8d3fc0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0203bc0:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203bc4:	1f900913          	li	s2,505
ffffffffc0203bc8:	a819                	j	ffffffffc0203bde <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc0203bca:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203bcc:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203bce:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203bd2:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203bd4:	8526                	mv	a0,s1
ffffffffc0203bd6:	c87ff0ef          	jal	ra,ffffffffc020385c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203bda:	03240a63          	beq	s0,s2,ffffffffc0203c0e <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203bde:	03000513          	li	a0,48
ffffffffc0203be2:	994fe0ef          	jal	ra,ffffffffc0201d76 <kmalloc>
ffffffffc0203be6:	85aa                	mv	a1,a0
ffffffffc0203be8:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203bec:	fd79                	bnez	a0,ffffffffc0203bca <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc0203bee:	00003697          	auipc	a3,0x3
ffffffffc0203bf2:	67a68693          	addi	a3,a3,1658 # ffffffffc0207268 <default_pmm_manager+0x9f8>
ffffffffc0203bf6:	00003617          	auipc	a2,0x3
ffffffffc0203bfa:	8ca60613          	addi	a2,a2,-1846 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203bfe:	13300593          	li	a1,307
ffffffffc0203c02:	00003517          	auipc	a0,0x3
ffffffffc0203c06:	41650513          	addi	a0,a0,1046 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203c0a:	885fc0ef          	jal	ra,ffffffffc020048e <__panic>
    return listelm->next;
ffffffffc0203c0e:	649c                	ld	a5,8(s1)
ffffffffc0203c10:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203c12:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203c16:	16f48663          	beq	s1,a5,ffffffffc0203d82 <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203c1a:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd351b4>
ffffffffc0203c1e:	ffe70693          	addi	a3,a4,-2 # ffe <_binary_obj___user_faultread_out_size-0x8c52>
ffffffffc0203c22:	10d61063          	bne	a2,a3,ffffffffc0203d22 <vmm_init+0x1e4>
ffffffffc0203c26:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203c2a:	0ed71c63          	bne	a4,a3,ffffffffc0203d22 <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc0203c2e:	0715                	addi	a4,a4,5
ffffffffc0203c30:	679c                	ld	a5,8(a5)
ffffffffc0203c32:	feb712e3          	bne	a4,a1,ffffffffc0203c16 <vmm_init+0xd8>
ffffffffc0203c36:	4a1d                	li	s4,7
ffffffffc0203c38:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203c3a:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203c3e:	85a2                	mv	a1,s0
ffffffffc0203c40:	8526                	mv	a0,s1
ffffffffc0203c42:	bdbff0ef          	jal	ra,ffffffffc020381c <find_vma>
ffffffffc0203c46:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203c48:	16050d63          	beqz	a0,ffffffffc0203dc2 <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203c4c:	00140593          	addi	a1,s0,1
ffffffffc0203c50:	8526                	mv	a0,s1
ffffffffc0203c52:	bcbff0ef          	jal	ra,ffffffffc020381c <find_vma>
ffffffffc0203c56:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203c58:	14050563          	beqz	a0,ffffffffc0203da2 <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203c5c:	85d2                	mv	a1,s4
ffffffffc0203c5e:	8526                	mv	a0,s1
ffffffffc0203c60:	bbdff0ef          	jal	ra,ffffffffc020381c <find_vma>
        assert(vma3 == NULL);
ffffffffc0203c64:	16051f63          	bnez	a0,ffffffffc0203de2 <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203c68:	00340593          	addi	a1,s0,3
ffffffffc0203c6c:	8526                	mv	a0,s1
ffffffffc0203c6e:	bafff0ef          	jal	ra,ffffffffc020381c <find_vma>
        assert(vma4 == NULL);
ffffffffc0203c72:	1a051863          	bnez	a0,ffffffffc0203e22 <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203c76:	00440593          	addi	a1,s0,4
ffffffffc0203c7a:	8526                	mv	a0,s1
ffffffffc0203c7c:	ba1ff0ef          	jal	ra,ffffffffc020381c <find_vma>
        assert(vma5 == NULL);
ffffffffc0203c80:	18051163          	bnez	a0,ffffffffc0203e02 <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203c84:	00893783          	ld	a5,8(s2)
ffffffffc0203c88:	0a879d63          	bne	a5,s0,ffffffffc0203d42 <vmm_init+0x204>
ffffffffc0203c8c:	01093783          	ld	a5,16(s2)
ffffffffc0203c90:	0b479963          	bne	a5,s4,ffffffffc0203d42 <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203c94:	0089b783          	ld	a5,8(s3)
ffffffffc0203c98:	0c879563          	bne	a5,s0,ffffffffc0203d62 <vmm_init+0x224>
ffffffffc0203c9c:	0109b783          	ld	a5,16(s3)
ffffffffc0203ca0:	0d479163          	bne	a5,s4,ffffffffc0203d62 <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203ca4:	0415                	addi	s0,s0,5
ffffffffc0203ca6:	0a15                	addi	s4,s4,5
ffffffffc0203ca8:	f9541be3          	bne	s0,s5,ffffffffc0203c3e <vmm_init+0x100>
ffffffffc0203cac:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203cae:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203cb0:	85a2                	mv	a1,s0
ffffffffc0203cb2:	8526                	mv	a0,s1
ffffffffc0203cb4:	b69ff0ef          	jal	ra,ffffffffc020381c <find_vma>
ffffffffc0203cb8:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203cbc:	c90d                	beqz	a0,ffffffffc0203cee <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203cbe:	6914                	ld	a3,16(a0)
ffffffffc0203cc0:	6510                	ld	a2,8(a0)
ffffffffc0203cc2:	00003517          	auipc	a0,0x3
ffffffffc0203cc6:	52e50513          	addi	a0,a0,1326 # ffffffffc02071f0 <default_pmm_manager+0x980>
ffffffffc0203cca:	ccafc0ef          	jal	ra,ffffffffc0200194 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203cce:	00003697          	auipc	a3,0x3
ffffffffc0203cd2:	54a68693          	addi	a3,a3,1354 # ffffffffc0207218 <default_pmm_manager+0x9a8>
ffffffffc0203cd6:	00002617          	auipc	a2,0x2
ffffffffc0203cda:	7ea60613          	addi	a2,a2,2026 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203cde:	15900593          	li	a1,345
ffffffffc0203ce2:	00003517          	auipc	a0,0x3
ffffffffc0203ce6:	33650513          	addi	a0,a0,822 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203cea:	fa4fc0ef          	jal	ra,ffffffffc020048e <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203cee:	147d                	addi	s0,s0,-1
ffffffffc0203cf0:	fd2410e3          	bne	s0,s2,ffffffffc0203cb0 <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc0203cf4:	8526                	mv	a0,s1
ffffffffc0203cf6:	c37ff0ef          	jal	ra,ffffffffc020392c <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203cfa:	00003517          	auipc	a0,0x3
ffffffffc0203cfe:	53650513          	addi	a0,a0,1334 # ffffffffc0207230 <default_pmm_manager+0x9c0>
ffffffffc0203d02:	c92fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0203d06:	7442                	ld	s0,48(sp)
ffffffffc0203d08:	70e2                	ld	ra,56(sp)
ffffffffc0203d0a:	74a2                	ld	s1,40(sp)
ffffffffc0203d0c:	7902                	ld	s2,32(sp)
ffffffffc0203d0e:	69e2                	ld	s3,24(sp)
ffffffffc0203d10:	6a42                	ld	s4,16(sp)
ffffffffc0203d12:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d14:	00003517          	auipc	a0,0x3
ffffffffc0203d18:	53c50513          	addi	a0,a0,1340 # ffffffffc0207250 <default_pmm_manager+0x9e0>
}
ffffffffc0203d1c:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d1e:	c76fc06f          	j	ffffffffc0200194 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203d22:	00003697          	auipc	a3,0x3
ffffffffc0203d26:	3e668693          	addi	a3,a3,998 # ffffffffc0207108 <default_pmm_manager+0x898>
ffffffffc0203d2a:	00002617          	auipc	a2,0x2
ffffffffc0203d2e:	79660613          	addi	a2,a2,1942 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203d32:	13d00593          	li	a1,317
ffffffffc0203d36:	00003517          	auipc	a0,0x3
ffffffffc0203d3a:	2e250513          	addi	a0,a0,738 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203d3e:	f50fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203d42:	00003697          	auipc	a3,0x3
ffffffffc0203d46:	44e68693          	addi	a3,a3,1102 # ffffffffc0207190 <default_pmm_manager+0x920>
ffffffffc0203d4a:	00002617          	auipc	a2,0x2
ffffffffc0203d4e:	77660613          	addi	a2,a2,1910 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203d52:	14e00593          	li	a1,334
ffffffffc0203d56:	00003517          	auipc	a0,0x3
ffffffffc0203d5a:	2c250513          	addi	a0,a0,706 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203d5e:	f30fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203d62:	00003697          	auipc	a3,0x3
ffffffffc0203d66:	45e68693          	addi	a3,a3,1118 # ffffffffc02071c0 <default_pmm_manager+0x950>
ffffffffc0203d6a:	00002617          	auipc	a2,0x2
ffffffffc0203d6e:	75660613          	addi	a2,a2,1878 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203d72:	14f00593          	li	a1,335
ffffffffc0203d76:	00003517          	auipc	a0,0x3
ffffffffc0203d7a:	2a250513          	addi	a0,a0,674 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203d7e:	f10fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203d82:	00003697          	auipc	a3,0x3
ffffffffc0203d86:	36e68693          	addi	a3,a3,878 # ffffffffc02070f0 <default_pmm_manager+0x880>
ffffffffc0203d8a:	00002617          	auipc	a2,0x2
ffffffffc0203d8e:	73660613          	addi	a2,a2,1846 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203d92:	13b00593          	li	a1,315
ffffffffc0203d96:	00003517          	auipc	a0,0x3
ffffffffc0203d9a:	28250513          	addi	a0,a0,642 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203d9e:	ef0fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma2 != NULL);
ffffffffc0203da2:	00003697          	auipc	a3,0x3
ffffffffc0203da6:	3ae68693          	addi	a3,a3,942 # ffffffffc0207150 <default_pmm_manager+0x8e0>
ffffffffc0203daa:	00002617          	auipc	a2,0x2
ffffffffc0203dae:	71660613          	addi	a2,a2,1814 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203db2:	14600593          	li	a1,326
ffffffffc0203db6:	00003517          	auipc	a0,0x3
ffffffffc0203dba:	26250513          	addi	a0,a0,610 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203dbe:	ed0fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma1 != NULL);
ffffffffc0203dc2:	00003697          	auipc	a3,0x3
ffffffffc0203dc6:	37e68693          	addi	a3,a3,894 # ffffffffc0207140 <default_pmm_manager+0x8d0>
ffffffffc0203dca:	00002617          	auipc	a2,0x2
ffffffffc0203dce:	6f660613          	addi	a2,a2,1782 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203dd2:	14400593          	li	a1,324
ffffffffc0203dd6:	00003517          	auipc	a0,0x3
ffffffffc0203dda:	24250513          	addi	a0,a0,578 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203dde:	eb0fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma3 == NULL);
ffffffffc0203de2:	00003697          	auipc	a3,0x3
ffffffffc0203de6:	37e68693          	addi	a3,a3,894 # ffffffffc0207160 <default_pmm_manager+0x8f0>
ffffffffc0203dea:	00002617          	auipc	a2,0x2
ffffffffc0203dee:	6d660613          	addi	a2,a2,1750 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203df2:	14800593          	li	a1,328
ffffffffc0203df6:	00003517          	auipc	a0,0x3
ffffffffc0203dfa:	22250513          	addi	a0,a0,546 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203dfe:	e90fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma5 == NULL);
ffffffffc0203e02:	00003697          	auipc	a3,0x3
ffffffffc0203e06:	37e68693          	addi	a3,a3,894 # ffffffffc0207180 <default_pmm_manager+0x910>
ffffffffc0203e0a:	00002617          	auipc	a2,0x2
ffffffffc0203e0e:	6b660613          	addi	a2,a2,1718 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203e12:	14c00593          	li	a1,332
ffffffffc0203e16:	00003517          	auipc	a0,0x3
ffffffffc0203e1a:	20250513          	addi	a0,a0,514 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203e1e:	e70fc0ef          	jal	ra,ffffffffc020048e <__panic>
        assert(vma4 == NULL);
ffffffffc0203e22:	00003697          	auipc	a3,0x3
ffffffffc0203e26:	34e68693          	addi	a3,a3,846 # ffffffffc0207170 <default_pmm_manager+0x900>
ffffffffc0203e2a:	00002617          	auipc	a2,0x2
ffffffffc0203e2e:	69660613          	addi	a2,a2,1686 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203e32:	14a00593          	li	a1,330
ffffffffc0203e36:	00003517          	auipc	a0,0x3
ffffffffc0203e3a:	1e250513          	addi	a0,a0,482 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203e3e:	e50fc0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(mm != NULL);
ffffffffc0203e42:	00003697          	auipc	a3,0x3
ffffffffc0203e46:	25e68693          	addi	a3,a3,606 # ffffffffc02070a0 <default_pmm_manager+0x830>
ffffffffc0203e4a:	00002617          	auipc	a2,0x2
ffffffffc0203e4e:	67660613          	addi	a2,a2,1654 # ffffffffc02064c0 <commands+0x858>
ffffffffc0203e52:	12400593          	li	a1,292
ffffffffc0203e56:	00003517          	auipc	a0,0x3
ffffffffc0203e5a:	1c250513          	addi	a0,a0,450 # ffffffffc0207018 <default_pmm_manager+0x7a8>
ffffffffc0203e5e:	e30fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0203e62 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203e62:	7179                	addi	sp,sp,-48
ffffffffc0203e64:	f022                	sd	s0,32(sp)
ffffffffc0203e66:	f406                	sd	ra,40(sp)
ffffffffc0203e68:	ec26                	sd	s1,24(sp)
ffffffffc0203e6a:	e84a                	sd	s2,16(sp)
ffffffffc0203e6c:	e44e                	sd	s3,8(sp)
ffffffffc0203e6e:	e052                	sd	s4,0(sp)
ffffffffc0203e70:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203e72:	c135                	beqz	a0,ffffffffc0203ed6 <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203e74:	002007b7          	lui	a5,0x200
ffffffffc0203e78:	04f5e663          	bltu	a1,a5,ffffffffc0203ec4 <user_mem_check+0x62>
ffffffffc0203e7c:	00c584b3          	add	s1,a1,a2
ffffffffc0203e80:	0495f263          	bgeu	a1,s1,ffffffffc0203ec4 <user_mem_check+0x62>
ffffffffc0203e84:	4785                	li	a5,1
ffffffffc0203e86:	07fe                	slli	a5,a5,0x1f
ffffffffc0203e88:	0297ee63          	bltu	a5,s1,ffffffffc0203ec4 <user_mem_check+0x62>
ffffffffc0203e8c:	892a                	mv	s2,a0
ffffffffc0203e8e:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203e90:	6a05                	lui	s4,0x1
ffffffffc0203e92:	a821                	j	ffffffffc0203eaa <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203e94:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203e98:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203e9a:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203e9c:	c685                	beqz	a3,ffffffffc0203ec4 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203e9e:	c399                	beqz	a5,ffffffffc0203ea4 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203ea0:	02e46263          	bltu	s0,a4,ffffffffc0203ec4 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203ea4:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203ea6:	04947663          	bgeu	s0,s1,ffffffffc0203ef2 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203eaa:	85a2                	mv	a1,s0
ffffffffc0203eac:	854a                	mv	a0,s2
ffffffffc0203eae:	96fff0ef          	jal	ra,ffffffffc020381c <find_vma>
ffffffffc0203eb2:	c909                	beqz	a0,ffffffffc0203ec4 <user_mem_check+0x62>
ffffffffc0203eb4:	6518                	ld	a4,8(a0)
ffffffffc0203eb6:	00e46763          	bltu	s0,a4,ffffffffc0203ec4 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203eba:	4d1c                	lw	a5,24(a0)
ffffffffc0203ebc:	fc099ce3          	bnez	s3,ffffffffc0203e94 <user_mem_check+0x32>
ffffffffc0203ec0:	8b85                	andi	a5,a5,1
ffffffffc0203ec2:	f3ed                	bnez	a5,ffffffffc0203ea4 <user_mem_check+0x42>
            return 0;
ffffffffc0203ec4:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0203ec6:	70a2                	ld	ra,40(sp)
ffffffffc0203ec8:	7402                	ld	s0,32(sp)
ffffffffc0203eca:	64e2                	ld	s1,24(sp)
ffffffffc0203ecc:	6942                	ld	s2,16(sp)
ffffffffc0203ece:	69a2                	ld	s3,8(sp)
ffffffffc0203ed0:	6a02                	ld	s4,0(sp)
ffffffffc0203ed2:	6145                	addi	sp,sp,48
ffffffffc0203ed4:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203ed6:	c02007b7          	lui	a5,0xc0200
ffffffffc0203eda:	4501                	li	a0,0
ffffffffc0203edc:	fef5e5e3          	bltu	a1,a5,ffffffffc0203ec6 <user_mem_check+0x64>
ffffffffc0203ee0:	962e                	add	a2,a2,a1
ffffffffc0203ee2:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203ec6 <user_mem_check+0x64>
ffffffffc0203ee6:	c8000537          	lui	a0,0xc8000
ffffffffc0203eea:	0505                	addi	a0,a0,1
ffffffffc0203eec:	00a63533          	sltu	a0,a2,a0
ffffffffc0203ef0:	bfd9                	j	ffffffffc0203ec6 <user_mem_check+0x64>
        return 1;
ffffffffc0203ef2:	4505                	li	a0,1
ffffffffc0203ef4:	bfc9                	j	ffffffffc0203ec6 <user_mem_check+0x64>

ffffffffc0203ef6 <do_pgfault>:



int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203ef6:	715d                	addi	sp,sp,-80
ffffffffc0203ef8:	fc26                	sd	s1,56(sp)
ffffffffc0203efa:	84ae                	mv	s1,a1
    int ret = -E_INVAL;
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203efc:	85b2                	mv	a1,a2
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203efe:	f84a                	sd	s2,48(sp)
ffffffffc0203f00:	f44e                	sd	s3,40(sp)
ffffffffc0203f02:	e486                	sd	ra,72(sp)
ffffffffc0203f04:	e0a2                	sd	s0,64(sp)
ffffffffc0203f06:	f052                	sd	s4,32(sp)
ffffffffc0203f08:	ec56                	sd	s5,24(sp)
ffffffffc0203f0a:	e85a                	sd	s6,16(sp)
ffffffffc0203f0c:	e45e                	sd	s7,8(sp)
ffffffffc0203f0e:	8932                	mv	s2,a2
ffffffffc0203f10:	89aa                	mv	s3,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203f12:	90bff0ef          	jal	ra,ffffffffc020381c <find_vma>

    pgfault_num++; 
ffffffffc0203f16:	000c6797          	auipc	a5,0xc6
ffffffffc0203f1a:	efa7a783          	lw	a5,-262(a5) # ffffffffc02c9e10 <pgfault_num>
ffffffffc0203f1e:	2785                	addiw	a5,a5,1
ffffffffc0203f20:	000c6717          	auipc	a4,0xc6
ffffffffc0203f24:	eef72823          	sw	a5,-272(a4) # ffffffffc02c9e10 <pgfault_num>

    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203f28:	12050b63          	beqz	a0,ffffffffc020405e <do_pgfault+0x168>
ffffffffc0203f2c:	651c                	ld	a5,8(a0)
ffffffffc0203f2e:	842a                	mv	s0,a0
ffffffffc0203f30:	12f96763          	bltu	s2,a5,ffffffffc020405e <do_pgfault+0x168>
        return -E_INVAL;
    }

    // 权限检查：如果尝试写一个不可写的VMA，直接报错
    if ((error_code & 2) && !(vma->vm_flags & VM_WRITE)) {
ffffffffc0203f34:	4d1c                	lw	a5,24(a0)
ffffffffc0203f36:	8889                	andi	s1,s1,2
ffffffffc0203f38:	0027f713          	andi	a4,a5,2
ffffffffc0203f3c:	0e049b63          	bnez	s1,ffffffffc0204032 <do_pgfault+0x13c>
        return -E_INVAL;
    }

    uint32_t perm = PTE_U;
ffffffffc0203f40:	4a41                	li	s4,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203f42:	0e071963          	bnez	a4,ffffffffc0204034 <do_pgfault+0x13e>
        perm |= (PTE_R | PTE_W);
    }
    if (vma->vm_flags & VM_READ) {
ffffffffc0203f46:	0017f713          	andi	a4,a5,1
ffffffffc0203f4a:	c319                	beqz	a4,ffffffffc0203f50 <do_pgfault+0x5a>
        perm |= PTE_R;
ffffffffc0203f4c:	002a6a13          	ori	s4,s4,2
    }
    if (vma->vm_flags & VM_EXEC) {
ffffffffc0203f50:	8b91                	andi	a5,a5,4
ffffffffc0203f52:	c399                	beqz	a5,ffffffffc0203f58 <do_pgfault+0x62>
        perm |= PTE_X;
ffffffffc0203f54:	008a6a13          	ori	s4,s4,8
    }

    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203f58:	767d                	lui	a2,0xfffff
    ret = -E_NO_MEM;
    pte_t *ptep = NULL;

    // 获取 PTE，如果不存在(PT未分配)则分配
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203f5a:	0189b503          	ld	a0,24(s3)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203f5e:	00c97933          	and	s2,s2,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203f62:	85ca                	mv	a1,s2
ffffffffc0203f64:	4605                	li	a2,1
ffffffffc0203f66:	8a6fe0ef          	jal	ra,ffffffffc020200c <get_pte>
ffffffffc0203f6a:	cd71                	beqz	a0,ffffffffc0204046 <do_pgfault+0x150>
        return ret;
    }
    
    // Case 1: 页表项全为0，说明尚未建立映射 (Demand Paging)
    if (*ptep == 0) { 
ffffffffc0203f6c:	611c                	ld	a5,0(a0)
ffffffffc0203f6e:	c7e9                	beqz	a5,ffffffffc0204038 <do_pgfault+0x142>
            return ret;
        }
    } 
    // Case 2: 页表项存在，可能是 COW 或者 Swap (本实验暂不考虑swap)
    else { 
        if (*ptep & PTE_V) {
ffffffffc0203f70:	0017f713          	andi	a4,a5,1
ffffffffc0203f74:	c35d                	beqz	a4,ffffffffc020401a <do_pgfault+0x124>
            // LAB5 CHALLENGE: Copy on Write 处理
            // 判断条件：这是写操作 (error_code & 2) 
            //          && 且物理页目前是只读的 (!(*ptep & PTE_W))
            //          && 且 VMA 允许写入 (vma->vm_flags & VM_WRITE)
            if ((error_code & 2) && !(*ptep & PTE_W) && (vma->vm_flags & VM_WRITE)) {
ffffffffc0203f76:	c8e1                	beqz	s1,ffffffffc0204046 <do_pgfault+0x150>
ffffffffc0203f78:	0047f713          	andi	a4,a5,4
ffffffffc0203f7c:	e769                	bnez	a4,ffffffffc0204046 <do_pgfault+0x150>
ffffffffc0203f7e:	4c18                	lw	a4,24(s0)
ffffffffc0203f80:	8b09                	andi	a4,a4,2
ffffffffc0203f82:	c371                	beqz	a4,ffffffffc0204046 <do_pgfault+0x150>
    if (PPN(pa) >= npage)
ffffffffc0203f84:	000c6b17          	auipc	s6,0xc6
ffffffffc0203f88:	e6cb0b13          	addi	s6,s6,-404 # ffffffffc02c9df0 <npage>
ffffffffc0203f8c:	000b3703          	ld	a4,0(s6)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203f90:	078a                	slli	a5,a5,0x2
ffffffffc0203f92:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203f94:	0ce7f763          	bgeu	a5,a4,ffffffffc0204062 <do_pgfault+0x16c>
    return &pages[PPN(pa) - nbase];
ffffffffc0203f98:	000c6b97          	auipc	s7,0xc6
ffffffffc0203f9c:	e60b8b93          	addi	s7,s7,-416 # ffffffffc02c9df8 <pages>
ffffffffc0203fa0:	000bb403          	ld	s0,0(s7)
ffffffffc0203fa4:	00004a97          	auipc	s5,0x4
ffffffffc0203fa8:	bfcaba83          	ld	s5,-1028(s5) # ffffffffc0207ba0 <nbase>
ffffffffc0203fac:	415787b3          	sub	a5,a5,s5
ffffffffc0203fb0:	079a                	slli	a5,a5,0x6
ffffffffc0203fb2:	943e                	add	s0,s0,a5
                struct Page *page = pte2page(*ptep);
                
                // 情况 A: 页面被多个进程共享 (Reference Count > 1)
                // 需要执行“复制”：分配新页，拷贝内容，重新映射
                if (page_ref(page) > 1) {
ffffffffc0203fb4:	4018                	lw	a4,0(s0)
ffffffffc0203fb6:	4785                	li	a5,1
ffffffffc0203fb8:	08e7d963          	bge	a5,a4,ffffffffc020404a <do_pgfault+0x154>
                    struct Page *npage = alloc_page();
ffffffffc0203fbc:	4505                	li	a0,1
ffffffffc0203fbe:	f97fd0ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc0203fc2:	84aa                	mv	s1,a0
                    if (npage == NULL) return ret;
ffffffffc0203fc4:	c149                	beqz	a0,ffffffffc0204046 <do_pgfault+0x150>
    return page - pages + nbase;
ffffffffc0203fc6:	000bb683          	ld	a3,0(s7)
    return KADDR(page2pa(page));
ffffffffc0203fca:	000b3803          	ld	a6,0(s6)
    return page - pages + nbase;
ffffffffc0203fce:	40d50733          	sub	a4,a0,a3
ffffffffc0203fd2:	8719                	srai	a4,a4,0x6
ffffffffc0203fd4:	9756                	add	a4,a4,s5
    return KADDR(page2pa(page));
ffffffffc0203fd6:	00c71613          	slli	a2,a4,0xc
ffffffffc0203fda:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203fdc:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc0203fde:	0b067a63          	bgeu	a2,a6,ffffffffc0204092 <do_pgfault+0x19c>
    return page - pages + nbase;
ffffffffc0203fe2:	40d406b3          	sub	a3,s0,a3
ffffffffc0203fe6:	8699                	srai	a3,a3,0x6
ffffffffc0203fe8:	96d6                	add	a3,a3,s5
    return KADDR(page2pa(page));
ffffffffc0203fea:	00c69793          	slli	a5,a3,0xc
ffffffffc0203fee:	000c6597          	auipc	a1,0xc6
ffffffffc0203ff2:	e1a5b583          	ld	a1,-486(a1) # ffffffffc02c9e08 <va_pa_offset>
ffffffffc0203ff6:	83b1                	srli	a5,a5,0xc
ffffffffc0203ff8:	00b70533          	add	a0,a4,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ffc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203ffe:	0707fe63          	bgeu	a5,a6,ffffffffc020407a <do_pgfault+0x184>
                    
                    // 复制原页面内容到新页面
                    memcpy(page2kva(npage), page2kva(page), PGSIZE);
ffffffffc0204002:	95b6                	add	a1,a1,a3
ffffffffc0204004:	6605                	lui	a2,0x1
ffffffffc0204006:	1df010ef          	jal	ra,ffffffffc02059e4 <memcpy>
                    // 建立新映射：
                    // 1. page_insert 会把虚拟地址 addr 映射到 npage
                    // 2. npage 的 ref 会增加
                    // 3. 原 page 的 ref 会自动减少 (因为该地址原先映射的页被覆盖了)
                    // 4. 注意：这里赋予了 PTE_W 写权限
                    if (page_insert(mm->pgdir, npage, addr, perm) != 0) {
ffffffffc020400a:	0189b503          	ld	a0,24(s3)
ffffffffc020400e:	86d2                	mv	a3,s4
ffffffffc0204010:	864a                	mv	a2,s2
ffffffffc0204012:	85a6                	mv	a1,s1
ffffffffc0204014:	ee8fe0ef          	jal	ra,ffffffffc02026fc <page_insert>
ffffffffc0204018:	e51d                	bnez	a0,ffffffffc0204046 <do_pgfault+0x150>
                // 如果不是 COW 情况的权限错误，则返回错误
                return ret; 
            }
        }
    }
    return 0;
ffffffffc020401a:	4501                	li	a0,0
ffffffffc020401c:	60a6                	ld	ra,72(sp)
ffffffffc020401e:	6406                	ld	s0,64(sp)
ffffffffc0204020:	74e2                	ld	s1,56(sp)
ffffffffc0204022:	7942                	ld	s2,48(sp)
ffffffffc0204024:	79a2                	ld	s3,40(sp)
ffffffffc0204026:	7a02                	ld	s4,32(sp)
ffffffffc0204028:	6ae2                	ld	s5,24(sp)
ffffffffc020402a:	6b42                	ld	s6,16(sp)
ffffffffc020402c:	6ba2                	ld	s7,8(sp)
ffffffffc020402e:	6161                	addi	sp,sp,80
ffffffffc0204030:	8082                	ret
    if ((error_code & 2) && !(vma->vm_flags & VM_WRITE)) {
ffffffffc0204032:	c715                	beqz	a4,ffffffffc020405e <do_pgfault+0x168>
        perm |= (PTE_R | PTE_W);
ffffffffc0204034:	4a59                	li	s4,22
ffffffffc0204036:	bf01                	j	ffffffffc0203f46 <do_pgfault+0x50>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204038:	0189b503          	ld	a0,24(s3)
ffffffffc020403c:	8652                	mv	a2,s4
ffffffffc020403e:	85ca                	mv	a1,s2
ffffffffc0204040:	ec6ff0ef          	jal	ra,ffffffffc0203706 <pgdir_alloc_page>
ffffffffc0204044:	f979                	bnez	a0,ffffffffc020401a <do_pgfault+0x124>
        return ret;
ffffffffc0204046:	5571                	li	a0,-4
ffffffffc0204048:	bfd1                	j	ffffffffc020401c <do_pgfault+0x126>
                    if (page_insert(mm->pgdir, page, addr, perm) != 0) {
ffffffffc020404a:	0189b503          	ld	a0,24(s3)
ffffffffc020404e:	86d2                	mv	a3,s4
ffffffffc0204050:	864a                	mv	a2,s2
ffffffffc0204052:	85a2                	mv	a1,s0
ffffffffc0204054:	ea8fe0ef          	jal	ra,ffffffffc02026fc <page_insert>
ffffffffc0204058:	d169                	beqz	a0,ffffffffc020401a <do_pgfault+0x124>
        return ret;
ffffffffc020405a:	5571                	li	a0,-4
ffffffffc020405c:	b7c1                	j	ffffffffc020401c <do_pgfault+0x126>
        return -E_INVAL;
ffffffffc020405e:	5575                	li	a0,-3
ffffffffc0204060:	bf75                	j	ffffffffc020401c <do_pgfault+0x126>
        panic("pa2page called with invalid pa");
ffffffffc0204062:	00003617          	auipc	a2,0x3
ffffffffc0204066:	91660613          	addi	a2,a2,-1770 # ffffffffc0206978 <default_pmm_manager+0x108>
ffffffffc020406a:	06900593          	li	a1,105
ffffffffc020406e:	00003517          	auipc	a0,0x3
ffffffffc0204072:	86250513          	addi	a0,a0,-1950 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc0204076:	c18fc0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc020407a:	00003617          	auipc	a2,0x3
ffffffffc020407e:	82e60613          	addi	a2,a2,-2002 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc0204082:	07100593          	li	a1,113
ffffffffc0204086:	00003517          	auipc	a0,0x3
ffffffffc020408a:	84a50513          	addi	a0,a0,-1974 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc020408e:	c00fc0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0204092:	86ba                	mv	a3,a4
ffffffffc0204094:	00003617          	auipc	a2,0x3
ffffffffc0204098:	81460613          	addi	a2,a2,-2028 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc020409c:	07100593          	li	a1,113
ffffffffc02040a0:	00003517          	auipc	a0,0x3
ffffffffc02040a4:	83050513          	addi	a0,a0,-2000 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc02040a8:	be6fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02040ac <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc02040ac:	8526                	mv	a0,s1
	jalr s0
ffffffffc02040ae:	9402                	jalr	s0

	jal do_exit
ffffffffc02040b0:	63c000ef          	jal	ra,ffffffffc02046ec <do_exit>

ffffffffc02040b4 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc02040b4:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02040b6:	11000513          	li	a0,272
{
ffffffffc02040ba:	e022                	sd	s0,0(sp)
ffffffffc02040bc:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02040be:	cb9fd0ef          	jal	ra,ffffffffc0201d76 <kmalloc>
ffffffffc02040c2:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc02040c4:	cd31                	beqz	a0,ffffffffc0204120 <alloc_proc+0x6c>
        /*
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */
        proc->state = PROC_UNINIT;          // 状态初始化为未初始化
ffffffffc02040c6:	57fd                	li	a5,-1
ffffffffc02040c8:	1782                	slli	a5,a5,0x20
ffffffffc02040ca:	e11c                	sd	a5,0(a0)
        proc->runs = 0;                     // 运行时间/次数初始化为 0
        proc->kstack = 0;                   // 内核栈地址初始化为 0
        proc->need_resched = 0;             // 刚创建时不急于抢占 CPU
        proc->parent = NULL;                // 父进程指针初始化为空
        proc->mm = NULL;                    // 内存管理结构初始化为空
        memset(&(proc->context), 0, sizeof(struct context)); // 清零上下文结构
ffffffffc02040cc:	07000613          	li	a2,112
ffffffffc02040d0:	4581                	li	a1,0
        proc->runs = 0;                     // 运行时间/次数初始化为 0
ffffffffc02040d2:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;                   // 内核栈地址初始化为 0
ffffffffc02040d6:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;             // 刚创建时不急于抢占 CPU
ffffffffc02040da:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;                // 父进程指针初始化为空
ffffffffc02040de:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                    // 内存管理结构初始化为空
ffffffffc02040e2:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context)); // 清零上下文结构
ffffffffc02040e6:	03050513          	addi	a0,a0,48
ffffffffc02040ea:	0e9010ef          	jal	ra,ffffffffc02059d2 <memset>
        proc->tf = NULL;                    // 中断帧指针初始化为空
        proc->pgdir = boot_pgdir_pa;                // 页目录表基址
ffffffffc02040ee:	000c6797          	auipc	a5,0xc6
ffffffffc02040f2:	cf27b783          	ld	a5,-782(a5) # ffffffffc02c9de0 <boot_pgdir_pa>
        proc->tf = NULL;                    // 中断帧指针初始化为空
ffffffffc02040f6:	0a043023          	sd	zero,160(s0)
        proc->pgdir = boot_pgdir_pa;                // 页目录表基址
ffffffffc02040fa:	f45c                	sd	a5,168(s0)
        proc->flags = 0;                    // 标志位清零
ffffffffc02040fc:	0a042823          	sw	zero,176(s0)
        memset(&(proc->name), 0, PROC_NAME_LEN + 1); // 进程名清零
ffffffffc0204100:	4641                	li	a2,16
ffffffffc0204102:	4581                	li	a1,0
ffffffffc0204104:	0b440513          	addi	a0,s0,180
ffffffffc0204108:	0cb010ef          	jal	ra,ffffffffc02059d2 <memset>

        proc->wait_state = 0; // 初始化等待状态为 0 (无等待)     
ffffffffc020410c:	0e042623          	sw	zero,236(s0)
        // 初始化进程关系链表指针为 NULL
        // cptr: 指向最年轻的子进程 (Child Pointer)
        // yptr: 指向下一个更年轻的兄弟进程 (Younger Sibling Pointer)
        // optr: 指向下一个更年长的兄弟进程 (Older Sibling Pointer)
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc0204110:	0e043c23          	sd	zero,248(s0)
ffffffffc0204114:	10043023          	sd	zero,256(s0)
ffffffffc0204118:	0e043823          	sd	zero,240(s0)
        proc->time_slice = 0;
ffffffffc020411c:	10042423          	sw	zero,264(s0)
    }
    return proc;
}
ffffffffc0204120:	60a2                	ld	ra,8(sp)
ffffffffc0204122:	8522                	mv	a0,s0
ffffffffc0204124:	6402                	ld	s0,0(sp)
ffffffffc0204126:	0141                	addi	sp,sp,16
ffffffffc0204128:	8082                	ret

ffffffffc020412a <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc020412a:	000c6797          	auipc	a5,0xc6
ffffffffc020412e:	cee7b783          	ld	a5,-786(a5) # ffffffffc02c9e18 <current>
ffffffffc0204132:	73c8                	ld	a0,160(a5)
ffffffffc0204134:	eb7fc06f          	j	ffffffffc0200fea <forkrets>

ffffffffc0204138 <user_main>:
// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204138:	000c6797          	auipc	a5,0xc6
ffffffffc020413c:	ce07b783          	ld	a5,-800(a5) # ffffffffc02c9e18 <current>
ffffffffc0204140:	43cc                	lw	a1,4(a5)
{
ffffffffc0204142:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204144:	00003617          	auipc	a2,0x3
ffffffffc0204148:	13460613          	addi	a2,a2,308 # ffffffffc0207278 <default_pmm_manager+0xa08>
ffffffffc020414c:	00003517          	auipc	a0,0x3
ffffffffc0204150:	13c50513          	addi	a0,a0,316 # ffffffffc0207288 <default_pmm_manager+0xa18>
{
ffffffffc0204154:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204156:	83efc0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc020415a:	3fe07797          	auipc	a5,0x3fe07
ffffffffc020415e:	8b678793          	addi	a5,a5,-1866 # aa10 <_binary_obj___user_forktest_out_size>
ffffffffc0204162:	e43e                	sd	a5,8(sp)
ffffffffc0204164:	00003517          	auipc	a0,0x3
ffffffffc0204168:	11450513          	addi	a0,a0,276 # ffffffffc0207278 <default_pmm_manager+0xa08>
ffffffffc020416c:	00064797          	auipc	a5,0x64
ffffffffc0204170:	69478793          	addi	a5,a5,1684 # ffffffffc0268800 <_binary_obj___user_forktest_out_start>
ffffffffc0204174:	f03e                	sd	a5,32(sp)
ffffffffc0204176:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0204178:	e802                	sd	zero,16(sp)
ffffffffc020417a:	7b6010ef          	jal	ra,ffffffffc0205930 <strlen>
ffffffffc020417e:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204180:	4511                	li	a0,4
ffffffffc0204182:	55a2                	lw	a1,40(sp)
ffffffffc0204184:	4662                	lw	a2,24(sp)
ffffffffc0204186:	5682                	lw	a3,32(sp)
ffffffffc0204188:	4722                	lw	a4,8(sp)
ffffffffc020418a:	48a9                	li	a7,10
ffffffffc020418c:	9002                	ebreak
ffffffffc020418e:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204190:	65c2                	ld	a1,16(sp)
ffffffffc0204192:	00003517          	auipc	a0,0x3
ffffffffc0204196:	11e50513          	addi	a0,a0,286 # ffffffffc02072b0 <default_pmm_manager+0xa40>
ffffffffc020419a:	ffbfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    //KERNEL_EXECVE(exit);
    KERNEL_EXECVE(cow_mem);
    //KERNEL_EXECVE(cow_data);
    //KERNEL_EXECVE(cow_stress);
#endif
    panic("user_main execve failed.\n");
ffffffffc020419e:	00003617          	auipc	a2,0x3
ffffffffc02041a2:	12260613          	addi	a2,a2,290 # ffffffffc02072c0 <default_pmm_manager+0xa50>
ffffffffc02041a6:	3d600593          	li	a1,982
ffffffffc02041aa:	00003517          	auipc	a0,0x3
ffffffffc02041ae:	13650513          	addi	a0,a0,310 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc02041b2:	adcfc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02041b6 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc02041b6:	6d14                	ld	a3,24(a0)
{
ffffffffc02041b8:	1141                	addi	sp,sp,-16
ffffffffc02041ba:	e406                	sd	ra,8(sp)
ffffffffc02041bc:	c02007b7          	lui	a5,0xc0200
ffffffffc02041c0:	02f6ee63          	bltu	a3,a5,ffffffffc02041fc <put_pgdir+0x46>
ffffffffc02041c4:	000c6517          	auipc	a0,0xc6
ffffffffc02041c8:	c4453503          	ld	a0,-956(a0) # ffffffffc02c9e08 <va_pa_offset>
ffffffffc02041cc:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc02041ce:	82b1                	srli	a3,a3,0xc
ffffffffc02041d0:	000c6797          	auipc	a5,0xc6
ffffffffc02041d4:	c207b783          	ld	a5,-992(a5) # ffffffffc02c9df0 <npage>
ffffffffc02041d8:	02f6fe63          	bgeu	a3,a5,ffffffffc0204214 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc02041dc:	00004517          	auipc	a0,0x4
ffffffffc02041e0:	9c453503          	ld	a0,-1596(a0) # ffffffffc0207ba0 <nbase>
}
ffffffffc02041e4:	60a2                	ld	ra,8(sp)
ffffffffc02041e6:	8e89                	sub	a3,a3,a0
ffffffffc02041e8:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc02041ea:	000c6517          	auipc	a0,0xc6
ffffffffc02041ee:	c0e53503          	ld	a0,-1010(a0) # ffffffffc02c9df8 <pages>
ffffffffc02041f2:	4585                	li	a1,1
ffffffffc02041f4:	9536                	add	a0,a0,a3
}
ffffffffc02041f6:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc02041f8:	d9bfd06f          	j	ffffffffc0201f92 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc02041fc:	00002617          	auipc	a2,0x2
ffffffffc0204200:	75460613          	addi	a2,a2,1876 # ffffffffc0206950 <default_pmm_manager+0xe0>
ffffffffc0204204:	07700593          	li	a1,119
ffffffffc0204208:	00002517          	auipc	a0,0x2
ffffffffc020420c:	6c850513          	addi	a0,a0,1736 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc0204210:	a7efc0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204214:	00002617          	auipc	a2,0x2
ffffffffc0204218:	76460613          	addi	a2,a2,1892 # ffffffffc0206978 <default_pmm_manager+0x108>
ffffffffc020421c:	06900593          	li	a1,105
ffffffffc0204220:	00002517          	auipc	a0,0x2
ffffffffc0204224:	6b050513          	addi	a0,a0,1712 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc0204228:	a66fc0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020422c <proc_run>:
{
ffffffffc020422c:	7179                	addi	sp,sp,-48
ffffffffc020422e:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc0204230:	000c6917          	auipc	s2,0xc6
ffffffffc0204234:	be890913          	addi	s2,s2,-1048 # ffffffffc02c9e18 <current>
{
ffffffffc0204238:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc020423a:	00093483          	ld	s1,0(s2)
{
ffffffffc020423e:	f406                	sd	ra,40(sp)
ffffffffc0204240:	e84e                	sd	s3,16(sp)
    if (proc != current)
ffffffffc0204242:	02a48863          	beq	s1,a0,ffffffffc0204272 <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204246:	100027f3          	csrr	a5,sstatus
ffffffffc020424a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020424c:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020424e:	ef9d                	bnez	a5,ffffffffc020428c <proc_run+0x60>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc0204250:	755c                	ld	a5,168(a0)
ffffffffc0204252:	577d                	li	a4,-1
ffffffffc0204254:	177e                	slli	a4,a4,0x3f
ffffffffc0204256:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0204258:	00a93023          	sd	a0,0(s2)
ffffffffc020425c:	8fd9                	or	a5,a5,a4
ffffffffc020425e:	18079073          	csrw	satp,a5
            switch_to(&(prev_proc->context), &(proc->context));
ffffffffc0204262:	03050593          	addi	a1,a0,48
ffffffffc0204266:	03048513          	addi	a0,s1,48
ffffffffc020426a:	052010ef          	jal	ra,ffffffffc02052bc <switch_to>
    if (flag)
ffffffffc020426e:	00099863          	bnez	s3,ffffffffc020427e <proc_run+0x52>
}
ffffffffc0204272:	70a2                	ld	ra,40(sp)
ffffffffc0204274:	7482                	ld	s1,32(sp)
ffffffffc0204276:	6962                	ld	s2,24(sp)
ffffffffc0204278:	69c2                	ld	s3,16(sp)
ffffffffc020427a:	6145                	addi	sp,sp,48
ffffffffc020427c:	8082                	ret
ffffffffc020427e:	70a2                	ld	ra,40(sp)
ffffffffc0204280:	7482                	ld	s1,32(sp)
ffffffffc0204282:	6962                	ld	s2,24(sp)
ffffffffc0204284:	69c2                	ld	s3,16(sp)
ffffffffc0204286:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204288:	f26fc06f          	j	ffffffffc02009ae <intr_enable>
ffffffffc020428c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020428e:	f26fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0204292:	6522                	ld	a0,8(sp)
ffffffffc0204294:	4985                	li	s3,1
ffffffffc0204296:	bf6d                	j	ffffffffc0204250 <proc_run+0x24>

ffffffffc0204298 <do_fork>:
{
ffffffffc0204298:	7119                	addi	sp,sp,-128
ffffffffc020429a:	f0ca                	sd	s2,96(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc020429c:	000c6917          	auipc	s2,0xc6
ffffffffc02042a0:	b9490913          	addi	s2,s2,-1132 # ffffffffc02c9e30 <nr_process>
ffffffffc02042a4:	00092703          	lw	a4,0(s2)
{
ffffffffc02042a8:	fc86                	sd	ra,120(sp)
ffffffffc02042aa:	f8a2                	sd	s0,112(sp)
ffffffffc02042ac:	f4a6                	sd	s1,104(sp)
ffffffffc02042ae:	ecce                	sd	s3,88(sp)
ffffffffc02042b0:	e8d2                	sd	s4,80(sp)
ffffffffc02042b2:	e4d6                	sd	s5,72(sp)
ffffffffc02042b4:	e0da                	sd	s6,64(sp)
ffffffffc02042b6:	fc5e                	sd	s7,56(sp)
ffffffffc02042b8:	f862                	sd	s8,48(sp)
ffffffffc02042ba:	f466                	sd	s9,40(sp)
ffffffffc02042bc:	f06a                	sd	s10,32(sp)
ffffffffc02042be:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc02042c0:	6785                	lui	a5,0x1
ffffffffc02042c2:	32f75b63          	bge	a4,a5,ffffffffc02045f8 <do_fork+0x360>
ffffffffc02042c6:	8a2a                	mv	s4,a0
ffffffffc02042c8:	89ae                	mv	s3,a1
ffffffffc02042ca:	8432                	mv	s0,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc02042cc:	de9ff0ef          	jal	ra,ffffffffc02040b4 <alloc_proc>
ffffffffc02042d0:	84aa                	mv	s1,a0
ffffffffc02042d2:	30050463          	beqz	a0,ffffffffc02045da <do_fork+0x342>
    proc->parent = current;
ffffffffc02042d6:	000c6c17          	auipc	s8,0xc6
ffffffffc02042da:	b42c0c13          	addi	s8,s8,-1214 # ffffffffc02c9e18 <current>
ffffffffc02042de:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);
ffffffffc02042e2:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8b64>
    proc->parent = current;
ffffffffc02042e6:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc02042e8:	30071d63          	bnez	a4,ffffffffc0204602 <do_fork+0x36a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02042ec:	4509                	li	a0,2
ffffffffc02042ee:	c67fd0ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
    if (page != NULL)
ffffffffc02042f2:	2e050163          	beqz	a0,ffffffffc02045d4 <do_fork+0x33c>
    return page - pages + nbase;
ffffffffc02042f6:	000c6a97          	auipc	s5,0xc6
ffffffffc02042fa:	b02a8a93          	addi	s5,s5,-1278 # ffffffffc02c9df8 <pages>
ffffffffc02042fe:	000ab683          	ld	a3,0(s5)
ffffffffc0204302:	00004b17          	auipc	s6,0x4
ffffffffc0204306:	89eb0b13          	addi	s6,s6,-1890 # ffffffffc0207ba0 <nbase>
ffffffffc020430a:	000b3783          	ld	a5,0(s6)
ffffffffc020430e:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204312:	000c6b97          	auipc	s7,0xc6
ffffffffc0204316:	adeb8b93          	addi	s7,s7,-1314 # ffffffffc02c9df0 <npage>
    return page - pages + nbase;
ffffffffc020431a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020431c:	5dfd                	li	s11,-1
ffffffffc020431e:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0204322:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204324:	00cddd93          	srli	s11,s11,0xc
ffffffffc0204328:	01b6f633          	and	a2,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc020432c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020432e:	2ee67a63          	bgeu	a2,a4,ffffffffc0204622 <do_fork+0x38a>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204332:	000c3603          	ld	a2,0(s8)
ffffffffc0204336:	000c6c17          	auipc	s8,0xc6
ffffffffc020433a:	ad2c0c13          	addi	s8,s8,-1326 # ffffffffc02c9e08 <va_pa_offset>
ffffffffc020433e:	000c3703          	ld	a4,0(s8)
ffffffffc0204342:	02863d03          	ld	s10,40(a2)
ffffffffc0204346:	e43e                	sd	a5,8(sp)
ffffffffc0204348:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020434a:	e894                	sd	a3,16(s1)
    if (oldmm == NULL)
ffffffffc020434c:	020d0863          	beqz	s10,ffffffffc020437c <do_fork+0xe4>
    if (clone_flags & CLONE_VM)
ffffffffc0204350:	100a7a13          	andi	s4,s4,256
ffffffffc0204354:	1c0a0163          	beqz	s4,ffffffffc0204516 <do_fork+0x27e>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0204358:	030d2703          	lw	a4,48(s10)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020435c:	018d3783          	ld	a5,24(s10)
ffffffffc0204360:	c02006b7          	lui	a3,0xc0200
ffffffffc0204364:	2705                	addiw	a4,a4,1
ffffffffc0204366:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc020436a:	03a4b423          	sd	s10,40(s1)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020436e:	2ed7e263          	bltu	a5,a3,ffffffffc0204652 <do_fork+0x3ba>
ffffffffc0204372:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204376:	6894                	ld	a3,16(s1)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204378:	8f99                	sub	a5,a5,a4
ffffffffc020437a:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020437c:	6789                	lui	a5,0x2
ffffffffc020437e:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7d70>
ffffffffc0204382:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204384:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204386:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0204388:	87b6                	mv	a5,a3
ffffffffc020438a:	12040893          	addi	a7,s0,288
ffffffffc020438e:	00063803          	ld	a6,0(a2)
ffffffffc0204392:	6608                	ld	a0,8(a2)
ffffffffc0204394:	6a0c                	ld	a1,16(a2)
ffffffffc0204396:	6e18                	ld	a4,24(a2)
ffffffffc0204398:	0107b023          	sd	a6,0(a5)
ffffffffc020439c:	e788                	sd	a0,8(a5)
ffffffffc020439e:	eb8c                	sd	a1,16(a5)
ffffffffc02043a0:	ef98                	sd	a4,24(a5)
ffffffffc02043a2:	02060613          	addi	a2,a2,32
ffffffffc02043a6:	02078793          	addi	a5,a5,32
ffffffffc02043aa:	ff1612e3          	bne	a2,a7,ffffffffc020438e <do_fork+0xf6>
    proc->tf->gpr.a0 = 0;
ffffffffc02043ae:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02043b2:	12098f63          	beqz	s3,ffffffffc02044f0 <do_fork+0x258>
ffffffffc02043b6:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02043ba:	00000797          	auipc	a5,0x0
ffffffffc02043be:	d7078793          	addi	a5,a5,-656 # ffffffffc020412a <forkret>
ffffffffc02043c2:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02043c4:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02043c6:	100027f3          	csrr	a5,sstatus
ffffffffc02043ca:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02043cc:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02043ce:	14079063          	bnez	a5,ffffffffc020450e <do_fork+0x276>
    if (++last_pid >= MAX_PID)
ffffffffc02043d2:	000c1817          	auipc	a6,0xc1
ffffffffc02043d6:	5ae80813          	addi	a6,a6,1454 # ffffffffc02c5980 <last_pid.1>
ffffffffc02043da:	00082783          	lw	a5,0(a6)
ffffffffc02043de:	6709                	lui	a4,0x2
ffffffffc02043e0:	0017851b          	addiw	a0,a5,1
ffffffffc02043e4:	00a82023          	sw	a0,0(a6)
ffffffffc02043e8:	08e55d63          	bge	a0,a4,ffffffffc0204482 <do_fork+0x1ea>
    if (last_pid >= next_safe)
ffffffffc02043ec:	000c1317          	auipc	t1,0xc1
ffffffffc02043f0:	59830313          	addi	t1,t1,1432 # ffffffffc02c5984 <next_safe.0>
ffffffffc02043f4:	00032783          	lw	a5,0(t1)
ffffffffc02043f8:	000c6417          	auipc	s0,0xc6
ffffffffc02043fc:	9a840413          	addi	s0,s0,-1624 # ffffffffc02c9da0 <proc_list>
ffffffffc0204400:	08f55963          	bge	a0,a5,ffffffffc0204492 <do_fork+0x1fa>
        proc->pid = get_pid(); // 获取唯一的 PID
ffffffffc0204404:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204406:	45a9                	li	a1,10
ffffffffc0204408:	2501                	sext.w	a0,a0
ffffffffc020440a:	122010ef          	jal	ra,ffffffffc020552c <hash32>
ffffffffc020440e:	02051793          	slli	a5,a0,0x20
ffffffffc0204412:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204416:	000c2797          	auipc	a5,0xc2
ffffffffc020441a:	98a78793          	addi	a5,a5,-1654 # ffffffffc02c5da0 <hash_list>
ffffffffc020441e:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204420:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204422:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204424:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc0204428:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020442a:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc020442c:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020442e:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204430:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc0204434:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc0204436:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc0204438:	e21c                	sd	a5,0(a2)
ffffffffc020443a:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc020443c:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc020443e:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc0204440:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204444:	10e4b023          	sd	a4,256(s1)
ffffffffc0204448:	c311                	beqz	a4,ffffffffc020444c <do_fork+0x1b4>
        proc->optr->yptr = proc;
ffffffffc020444a:	ff64                	sd	s1,248(a4)
    nr_process++;
ffffffffc020444c:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc0204450:	fae4                	sd	s1,240(a3)
    nr_process++;
ffffffffc0204452:	2785                	addiw	a5,a5,1
ffffffffc0204454:	00f92023          	sw	a5,0(s2)
    if (flag)
ffffffffc0204458:	18099363          	bnez	s3,ffffffffc02045de <do_fork+0x346>
    wakeup_proc(proc); 
ffffffffc020445c:	8526                	mv	a0,s1
ffffffffc020445e:	6c9000ef          	jal	ra,ffffffffc0205326 <wakeup_proc>
    ret = proc->pid;
ffffffffc0204462:	40c8                	lw	a0,4(s1)
}
ffffffffc0204464:	70e6                	ld	ra,120(sp)
ffffffffc0204466:	7446                	ld	s0,112(sp)
ffffffffc0204468:	74a6                	ld	s1,104(sp)
ffffffffc020446a:	7906                	ld	s2,96(sp)
ffffffffc020446c:	69e6                	ld	s3,88(sp)
ffffffffc020446e:	6a46                	ld	s4,80(sp)
ffffffffc0204470:	6aa6                	ld	s5,72(sp)
ffffffffc0204472:	6b06                	ld	s6,64(sp)
ffffffffc0204474:	7be2                	ld	s7,56(sp)
ffffffffc0204476:	7c42                	ld	s8,48(sp)
ffffffffc0204478:	7ca2                	ld	s9,40(sp)
ffffffffc020447a:	7d02                	ld	s10,32(sp)
ffffffffc020447c:	6de2                	ld	s11,24(sp)
ffffffffc020447e:	6109                	addi	sp,sp,128
ffffffffc0204480:	8082                	ret
        last_pid = 1;
ffffffffc0204482:	4785                	li	a5,1
ffffffffc0204484:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0204488:	4505                	li	a0,1
ffffffffc020448a:	000c1317          	auipc	t1,0xc1
ffffffffc020448e:	4fa30313          	addi	t1,t1,1274 # ffffffffc02c5984 <next_safe.0>
    return listelm->next;
ffffffffc0204492:	000c6417          	auipc	s0,0xc6
ffffffffc0204496:	90e40413          	addi	s0,s0,-1778 # ffffffffc02c9da0 <proc_list>
ffffffffc020449a:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc020449e:	6789                	lui	a5,0x2
ffffffffc02044a0:	00f32023          	sw	a5,0(t1)
ffffffffc02044a4:	86aa                	mv	a3,a0
ffffffffc02044a6:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc02044a8:	6e89                	lui	t4,0x2
ffffffffc02044aa:	148e0263          	beq	t3,s0,ffffffffc02045ee <do_fork+0x356>
ffffffffc02044ae:	88ae                	mv	a7,a1
ffffffffc02044b0:	87f2                	mv	a5,t3
ffffffffc02044b2:	6609                	lui	a2,0x2
ffffffffc02044b4:	a811                	j	ffffffffc02044c8 <do_fork+0x230>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02044b6:	00e6d663          	bge	a3,a4,ffffffffc02044c2 <do_fork+0x22a>
ffffffffc02044ba:	00c75463          	bge	a4,a2,ffffffffc02044c2 <do_fork+0x22a>
ffffffffc02044be:	863a                	mv	a2,a4
ffffffffc02044c0:	4885                	li	a7,1
ffffffffc02044c2:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02044c4:	00878d63          	beq	a5,s0,ffffffffc02044de <do_fork+0x246>
            if (proc->pid == last_pid)
ffffffffc02044c8:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7d14>
ffffffffc02044cc:	fed715e3          	bne	a4,a3,ffffffffc02044b6 <do_fork+0x21e>
                if (++last_pid >= next_safe)
ffffffffc02044d0:	2685                	addiw	a3,a3,1
ffffffffc02044d2:	10c6d963          	bge	a3,a2,ffffffffc02045e4 <do_fork+0x34c>
ffffffffc02044d6:	679c                	ld	a5,8(a5)
ffffffffc02044d8:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc02044da:	fe8797e3          	bne	a5,s0,ffffffffc02044c8 <do_fork+0x230>
ffffffffc02044de:	c581                	beqz	a1,ffffffffc02044e6 <do_fork+0x24e>
ffffffffc02044e0:	00d82023          	sw	a3,0(a6)
ffffffffc02044e4:	8536                	mv	a0,a3
ffffffffc02044e6:	f0088fe3          	beqz	a7,ffffffffc0204404 <do_fork+0x16c>
ffffffffc02044ea:	00c32023          	sw	a2,0(t1)
ffffffffc02044ee:	bf19                	j	ffffffffc0204404 <do_fork+0x16c>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02044f0:	89b6                	mv	s3,a3
ffffffffc02044f2:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044f6:	00000797          	auipc	a5,0x0
ffffffffc02044fa:	c3478793          	addi	a5,a5,-972 # ffffffffc020412a <forkret>
ffffffffc02044fe:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204500:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204502:	100027f3          	csrr	a5,sstatus
ffffffffc0204506:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204508:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020450a:	ec0784e3          	beqz	a5,ffffffffc02043d2 <do_fork+0x13a>
        intr_disable();
ffffffffc020450e:	ca6fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0204512:	4985                	li	s3,1
ffffffffc0204514:	bd7d                	j	ffffffffc02043d2 <do_fork+0x13a>
    if ((mm = mm_create()) == NULL)
ffffffffc0204516:	ad6ff0ef          	jal	ra,ffffffffc02037ec <mm_create>
ffffffffc020451a:	8caa                	mv	s9,a0
ffffffffc020451c:	c541                	beqz	a0,ffffffffc02045a4 <do_fork+0x30c>
    if ((page = alloc_page()) == NULL)
ffffffffc020451e:	4505                	li	a0,1
ffffffffc0204520:	a35fd0ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc0204524:	cd2d                	beqz	a0,ffffffffc020459e <do_fork+0x306>
    return page - pages + nbase;
ffffffffc0204526:	000ab683          	ld	a3,0(s5)
ffffffffc020452a:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc020452c:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0204530:	40d506b3          	sub	a3,a0,a3
ffffffffc0204534:	8699                	srai	a3,a3,0x6
ffffffffc0204536:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204538:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc020453c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020453e:	0eedf263          	bgeu	s11,a4,ffffffffc0204622 <do_fork+0x38a>
ffffffffc0204542:	000c3a03          	ld	s4,0(s8)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204546:	6605                	lui	a2,0x1
ffffffffc0204548:	000c6597          	auipc	a1,0xc6
ffffffffc020454c:	8a05b583          	ld	a1,-1888(a1) # ffffffffc02c9de8 <boot_pgdir_va>
ffffffffc0204550:	9a36                	add	s4,s4,a3
ffffffffc0204552:	8552                	mv	a0,s4
ffffffffc0204554:	490010ef          	jal	ra,ffffffffc02059e4 <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc0204558:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc020455c:	014cbc23          	sd	s4,24(s9) # fffffffffff80018 <end+0x3fcb61e4>
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204560:	4785                	li	a5,1
ffffffffc0204562:	40fdb7af          	amoor.d	a5,a5,(s11)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc0204566:	8b85                	andi	a5,a5,1
ffffffffc0204568:	4a05                	li	s4,1
ffffffffc020456a:	c799                	beqz	a5,ffffffffc0204578 <do_fork+0x2e0>
    {
        schedule();
ffffffffc020456c:	63b000ef          	jal	ra,ffffffffc02053a6 <schedule>
ffffffffc0204570:	414db7af          	amoor.d	a5,s4,(s11)
    while (!try_lock(lock))
ffffffffc0204574:	8b85                	andi	a5,a5,1
ffffffffc0204576:	fbfd                	bnez	a5,ffffffffc020456c <do_fork+0x2d4>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204578:	85ea                	mv	a1,s10
ffffffffc020457a:	8566                	mv	a0,s9
ffffffffc020457c:	cb2ff0ef          	jal	ra,ffffffffc0203a2e <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204580:	57f9                	li	a5,-2
ffffffffc0204582:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc0204586:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc0204588:	0e078e63          	beqz	a5,ffffffffc0204684 <do_fork+0x3ec>
good_mm:
ffffffffc020458c:	8d66                	mv	s10,s9
    if (ret != 0)
ffffffffc020458e:	dc0505e3          	beqz	a0,ffffffffc0204358 <do_fork+0xc0>
    exit_mmap(mm);
ffffffffc0204592:	8566                	mv	a0,s9
ffffffffc0204594:	d34ff0ef          	jal	ra,ffffffffc0203ac8 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204598:	8566                	mv	a0,s9
ffffffffc020459a:	c1dff0ef          	jal	ra,ffffffffc02041b6 <put_pgdir>
    mm_destroy(mm);
ffffffffc020459e:	8566                	mv	a0,s9
ffffffffc02045a0:	b8cff0ef          	jal	ra,ffffffffc020392c <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02045a4:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc02045a6:	c02007b7          	lui	a5,0xc0200
ffffffffc02045aa:	0cf6e163          	bltu	a3,a5,ffffffffc020466c <do_fork+0x3d4>
ffffffffc02045ae:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage)
ffffffffc02045b2:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc02045b6:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc02045ba:	83b1                	srli	a5,a5,0xc
ffffffffc02045bc:	06e7ff63          	bgeu	a5,a4,ffffffffc020463a <do_fork+0x3a2>
    return &pages[PPN(pa) - nbase];
ffffffffc02045c0:	000b3703          	ld	a4,0(s6)
ffffffffc02045c4:	000ab503          	ld	a0,0(s5)
ffffffffc02045c8:	4589                	li	a1,2
ffffffffc02045ca:	8f99                	sub	a5,a5,a4
ffffffffc02045cc:	079a                	slli	a5,a5,0x6
ffffffffc02045ce:	953e                	add	a0,a0,a5
ffffffffc02045d0:	9c3fd0ef          	jal	ra,ffffffffc0201f92 <free_pages>
    kfree(proc);
ffffffffc02045d4:	8526                	mv	a0,s1
ffffffffc02045d6:	851fd0ef          	jal	ra,ffffffffc0201e26 <kfree>
    ret = -E_NO_MEM;
ffffffffc02045da:	5571                	li	a0,-4
    return ret;
ffffffffc02045dc:	b561                	j	ffffffffc0204464 <do_fork+0x1cc>
        intr_enable();
ffffffffc02045de:	bd0fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02045e2:	bdad                	j	ffffffffc020445c <do_fork+0x1c4>
                    if (last_pid >= MAX_PID)
ffffffffc02045e4:	01d6c363          	blt	a3,t4,ffffffffc02045ea <do_fork+0x352>
                        last_pid = 1;
ffffffffc02045e8:	4685                	li	a3,1
                    goto repeat;
ffffffffc02045ea:	4585                	li	a1,1
ffffffffc02045ec:	bd7d                	j	ffffffffc02044aa <do_fork+0x212>
ffffffffc02045ee:	c599                	beqz	a1,ffffffffc02045fc <do_fork+0x364>
ffffffffc02045f0:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc02045f4:	8536                	mv	a0,a3
ffffffffc02045f6:	b539                	j	ffffffffc0204404 <do_fork+0x16c>
    int ret = -E_NO_FREE_PROC;
ffffffffc02045f8:	556d                	li	a0,-5
ffffffffc02045fa:	b5ad                	j	ffffffffc0204464 <do_fork+0x1cc>
    return last_pid;
ffffffffc02045fc:	00082503          	lw	a0,0(a6)
ffffffffc0204600:	b511                	j	ffffffffc0204404 <do_fork+0x16c>
    assert(current->wait_state == 0);
ffffffffc0204602:	00003697          	auipc	a3,0x3
ffffffffc0204606:	cf668693          	addi	a3,a3,-778 # ffffffffc02072f8 <default_pmm_manager+0xa88>
ffffffffc020460a:	00002617          	auipc	a2,0x2
ffffffffc020460e:	eb660613          	addi	a2,a2,-330 # ffffffffc02064c0 <commands+0x858>
ffffffffc0204612:	1f600593          	li	a1,502
ffffffffc0204616:	00003517          	auipc	a0,0x3
ffffffffc020461a:	cca50513          	addi	a0,a0,-822 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc020461e:	e71fb0ef          	jal	ra,ffffffffc020048e <__panic>
    return KADDR(page2pa(page));
ffffffffc0204622:	00002617          	auipc	a2,0x2
ffffffffc0204626:	28660613          	addi	a2,a2,646 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc020462a:	07100593          	li	a1,113
ffffffffc020462e:	00002517          	auipc	a0,0x2
ffffffffc0204632:	2a250513          	addi	a0,a0,674 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc0204636:	e59fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020463a:	00002617          	auipc	a2,0x2
ffffffffc020463e:	33e60613          	addi	a2,a2,830 # ffffffffc0206978 <default_pmm_manager+0x108>
ffffffffc0204642:	06900593          	li	a1,105
ffffffffc0204646:	00002517          	auipc	a0,0x2
ffffffffc020464a:	28a50513          	addi	a0,a0,650 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc020464e:	e41fb0ef          	jal	ra,ffffffffc020048e <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204652:	86be                	mv	a3,a5
ffffffffc0204654:	00002617          	auipc	a2,0x2
ffffffffc0204658:	2fc60613          	addi	a2,a2,764 # ffffffffc0206950 <default_pmm_manager+0xe0>
ffffffffc020465c:	1a300593          	li	a1,419
ffffffffc0204660:	00003517          	auipc	a0,0x3
ffffffffc0204664:	c8050513          	addi	a0,a0,-896 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc0204668:	e27fb0ef          	jal	ra,ffffffffc020048e <__panic>
    return pa2page(PADDR(kva));
ffffffffc020466c:	00002617          	auipc	a2,0x2
ffffffffc0204670:	2e460613          	addi	a2,a2,740 # ffffffffc0206950 <default_pmm_manager+0xe0>
ffffffffc0204674:	07700593          	li	a1,119
ffffffffc0204678:	00002517          	auipc	a0,0x2
ffffffffc020467c:	25850513          	addi	a0,a0,600 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc0204680:	e0ffb0ef          	jal	ra,ffffffffc020048e <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc0204684:	00003617          	auipc	a2,0x3
ffffffffc0204688:	c9460613          	addi	a2,a2,-876 # ffffffffc0207318 <default_pmm_manager+0xaa8>
ffffffffc020468c:	03f00593          	li	a1,63
ffffffffc0204690:	00003517          	auipc	a0,0x3
ffffffffc0204694:	c9850513          	addi	a0,a0,-872 # ffffffffc0207328 <default_pmm_manager+0xab8>
ffffffffc0204698:	df7fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020469c <kernel_thread>:
{
ffffffffc020469c:	7129                	addi	sp,sp,-320
ffffffffc020469e:	fa22                	sd	s0,304(sp)
ffffffffc02046a0:	f626                	sd	s1,296(sp)
ffffffffc02046a2:	f24a                	sd	s2,288(sp)
ffffffffc02046a4:	84ae                	mv	s1,a1
ffffffffc02046a6:	892a                	mv	s2,a0
ffffffffc02046a8:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02046aa:	4581                	li	a1,0
ffffffffc02046ac:	12000613          	li	a2,288
ffffffffc02046b0:	850a                	mv	a0,sp
{
ffffffffc02046b2:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02046b4:	31e010ef          	jal	ra,ffffffffc02059d2 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02046b8:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02046ba:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02046bc:	100027f3          	csrr	a5,sstatus
ffffffffc02046c0:	edd7f793          	andi	a5,a5,-291
ffffffffc02046c4:	1207e793          	ori	a5,a5,288
ffffffffc02046c8:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046ca:	860a                	mv	a2,sp
ffffffffc02046cc:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02046d0:	00000797          	auipc	a5,0x0
ffffffffc02046d4:	9dc78793          	addi	a5,a5,-1572 # ffffffffc02040ac <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046d8:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02046da:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046dc:	bbdff0ef          	jal	ra,ffffffffc0204298 <do_fork>
}
ffffffffc02046e0:	70f2                	ld	ra,312(sp)
ffffffffc02046e2:	7452                	ld	s0,304(sp)
ffffffffc02046e4:	74b2                	ld	s1,296(sp)
ffffffffc02046e6:	7912                	ld	s2,288(sp)
ffffffffc02046e8:	6131                	addi	sp,sp,320
ffffffffc02046ea:	8082                	ret

ffffffffc02046ec <do_exit>:
{
ffffffffc02046ec:	7179                	addi	sp,sp,-48
ffffffffc02046ee:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc02046f0:	000c5417          	auipc	s0,0xc5
ffffffffc02046f4:	72840413          	addi	s0,s0,1832 # ffffffffc02c9e18 <current>
ffffffffc02046f8:	601c                	ld	a5,0(s0)
{
ffffffffc02046fa:	f406                	sd	ra,40(sp)
ffffffffc02046fc:	ec26                	sd	s1,24(sp)
ffffffffc02046fe:	e84a                	sd	s2,16(sp)
ffffffffc0204700:	e44e                	sd	s3,8(sp)
ffffffffc0204702:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc0204704:	000c5717          	auipc	a4,0xc5
ffffffffc0204708:	71c73703          	ld	a4,1820(a4) # ffffffffc02c9e20 <idleproc>
ffffffffc020470c:	0ce78c63          	beq	a5,a4,ffffffffc02047e4 <do_exit+0xf8>
    if (current == initproc)
ffffffffc0204710:	000c5497          	auipc	s1,0xc5
ffffffffc0204714:	71848493          	addi	s1,s1,1816 # ffffffffc02c9e28 <initproc>
ffffffffc0204718:	6098                	ld	a4,0(s1)
ffffffffc020471a:	0ee78b63          	beq	a5,a4,ffffffffc0204810 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc020471e:	0287b983          	ld	s3,40(a5)
ffffffffc0204722:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc0204724:	02098663          	beqz	s3,ffffffffc0204750 <do_exit+0x64>
ffffffffc0204728:	000c5797          	auipc	a5,0xc5
ffffffffc020472c:	6b87b783          	ld	a5,1720(a5) # ffffffffc02c9de0 <boot_pgdir_pa>
ffffffffc0204730:	577d                	li	a4,-1
ffffffffc0204732:	177e                	slli	a4,a4,0x3f
ffffffffc0204734:	83b1                	srli	a5,a5,0xc
ffffffffc0204736:	8fd9                	or	a5,a5,a4
ffffffffc0204738:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020473c:	0309a783          	lw	a5,48(s3)
ffffffffc0204740:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204744:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc0204748:	cb55                	beqz	a4,ffffffffc02047fc <do_exit+0x110>
        current->mm = NULL;
ffffffffc020474a:	601c                	ld	a5,0(s0)
ffffffffc020474c:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0204750:	601c                	ld	a5,0(s0)
ffffffffc0204752:	470d                	li	a4,3
ffffffffc0204754:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0204756:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020475a:	100027f3          	csrr	a5,sstatus
ffffffffc020475e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204760:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204762:	e3f9                	bnez	a5,ffffffffc0204828 <do_exit+0x13c>
        proc = current->parent;
ffffffffc0204764:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204766:	800007b7          	lui	a5,0x80000
ffffffffc020476a:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020476c:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc020476e:	0ec52703          	lw	a4,236(a0)
ffffffffc0204772:	0af70f63          	beq	a4,a5,ffffffffc0204830 <do_exit+0x144>
        while (current->cptr != NULL)
ffffffffc0204776:	6018                	ld	a4,0(s0)
ffffffffc0204778:	7b7c                	ld	a5,240(a4)
ffffffffc020477a:	c3a1                	beqz	a5,ffffffffc02047ba <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD)
ffffffffc020477c:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204780:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204782:	0985                	addi	s3,s3,1
ffffffffc0204784:	a021                	j	ffffffffc020478c <do_exit+0xa0>
        while (current->cptr != NULL)
ffffffffc0204786:	6018                	ld	a4,0(s0)
ffffffffc0204788:	7b7c                	ld	a5,240(a4)
ffffffffc020478a:	cb85                	beqz	a5,ffffffffc02047ba <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc020478c:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4f38>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204790:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0204792:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204794:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0204796:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020479a:	10e7b023          	sd	a4,256(a5)
ffffffffc020479e:	c311                	beqz	a4,ffffffffc02047a2 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc02047a0:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02047a2:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02047a4:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02047a6:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02047a8:	fd271fe3          	bne	a4,s2,ffffffffc0204786 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc02047ac:	0ec52783          	lw	a5,236(a0)
ffffffffc02047b0:	fd379be3          	bne	a5,s3,ffffffffc0204786 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02047b4:	373000ef          	jal	ra,ffffffffc0205326 <wakeup_proc>
ffffffffc02047b8:	b7f9                	j	ffffffffc0204786 <do_exit+0x9a>
    if (flag)
ffffffffc02047ba:	020a1263          	bnez	s4,ffffffffc02047de <do_exit+0xf2>
    schedule();
ffffffffc02047be:	3e9000ef          	jal	ra,ffffffffc02053a6 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02047c2:	601c                	ld	a5,0(s0)
ffffffffc02047c4:	00003617          	auipc	a2,0x3
ffffffffc02047c8:	b9c60613          	addi	a2,a2,-1124 # ffffffffc0207360 <default_pmm_manager+0xaf0>
ffffffffc02047cc:	25b00593          	li	a1,603
ffffffffc02047d0:	43d4                	lw	a3,4(a5)
ffffffffc02047d2:	00003517          	auipc	a0,0x3
ffffffffc02047d6:	b0e50513          	addi	a0,a0,-1266 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc02047da:	cb5fb0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_enable();
ffffffffc02047de:	9d0fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02047e2:	bff1                	j	ffffffffc02047be <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc02047e4:	00003617          	auipc	a2,0x3
ffffffffc02047e8:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0207340 <default_pmm_manager+0xad0>
ffffffffc02047ec:	22700593          	li	a1,551
ffffffffc02047f0:	00003517          	auipc	a0,0x3
ffffffffc02047f4:	af050513          	addi	a0,a0,-1296 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc02047f8:	c97fb0ef          	jal	ra,ffffffffc020048e <__panic>
            exit_mmap(mm);
ffffffffc02047fc:	854e                	mv	a0,s3
ffffffffc02047fe:	acaff0ef          	jal	ra,ffffffffc0203ac8 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204802:	854e                	mv	a0,s3
ffffffffc0204804:	9b3ff0ef          	jal	ra,ffffffffc02041b6 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204808:	854e                	mv	a0,s3
ffffffffc020480a:	922ff0ef          	jal	ra,ffffffffc020392c <mm_destroy>
ffffffffc020480e:	bf35                	j	ffffffffc020474a <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc0204810:	00003617          	auipc	a2,0x3
ffffffffc0204814:	b4060613          	addi	a2,a2,-1216 # ffffffffc0207350 <default_pmm_manager+0xae0>
ffffffffc0204818:	22b00593          	li	a1,555
ffffffffc020481c:	00003517          	auipc	a0,0x3
ffffffffc0204820:	ac450513          	addi	a0,a0,-1340 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc0204824:	c6bfb0ef          	jal	ra,ffffffffc020048e <__panic>
        intr_disable();
ffffffffc0204828:	98cfc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc020482c:	4a05                	li	s4,1
ffffffffc020482e:	bf1d                	j	ffffffffc0204764 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc0204830:	2f7000ef          	jal	ra,ffffffffc0205326 <wakeup_proc>
ffffffffc0204834:	b789                	j	ffffffffc0204776 <do_exit+0x8a>

ffffffffc0204836 <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc0204836:	715d                	addi	sp,sp,-80
ffffffffc0204838:	f84a                	sd	s2,48(sp)
ffffffffc020483a:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc020483c:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc0204840:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc0204842:	fc26                	sd	s1,56(sp)
ffffffffc0204844:	f052                	sd	s4,32(sp)
ffffffffc0204846:	ec56                	sd	s5,24(sp)
ffffffffc0204848:	e85a                	sd	s6,16(sp)
ffffffffc020484a:	e45e                	sd	s7,8(sp)
ffffffffc020484c:	e486                	sd	ra,72(sp)
ffffffffc020484e:	e0a2                	sd	s0,64(sp)
ffffffffc0204850:	84aa                	mv	s1,a0
ffffffffc0204852:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0204854:	000c5b97          	auipc	s7,0xc5
ffffffffc0204858:	5c4b8b93          	addi	s7,s7,1476 # ffffffffc02c9e18 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc020485c:	00050b1b          	sext.w	s6,a0
ffffffffc0204860:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0204864:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0204866:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc0204868:	ccbd                	beqz	s1,ffffffffc02048e6 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc020486a:	0359e863          	bltu	s3,s5,ffffffffc020489a <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020486e:	45a9                	li	a1,10
ffffffffc0204870:	855a                	mv	a0,s6
ffffffffc0204872:	4bb000ef          	jal	ra,ffffffffc020552c <hash32>
ffffffffc0204876:	02051793          	slli	a5,a0,0x20
ffffffffc020487a:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020487e:	000c1797          	auipc	a5,0xc1
ffffffffc0204882:	52278793          	addi	a5,a5,1314 # ffffffffc02c5da0 <hash_list>
ffffffffc0204886:	953e                	add	a0,a0,a5
ffffffffc0204888:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc020488a:	a029                	j	ffffffffc0204894 <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc020488c:	f2c42783          	lw	a5,-212(s0)
ffffffffc0204890:	02978163          	beq	a5,s1,ffffffffc02048b2 <do_wait.part.0+0x7c>
ffffffffc0204894:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc0204896:	fe851be3          	bne	a0,s0,ffffffffc020488c <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc020489a:	5579                	li	a0,-2
}
ffffffffc020489c:	60a6                	ld	ra,72(sp)
ffffffffc020489e:	6406                	ld	s0,64(sp)
ffffffffc02048a0:	74e2                	ld	s1,56(sp)
ffffffffc02048a2:	7942                	ld	s2,48(sp)
ffffffffc02048a4:	79a2                	ld	s3,40(sp)
ffffffffc02048a6:	7a02                	ld	s4,32(sp)
ffffffffc02048a8:	6ae2                	ld	s5,24(sp)
ffffffffc02048aa:	6b42                	ld	s6,16(sp)
ffffffffc02048ac:	6ba2                	ld	s7,8(sp)
ffffffffc02048ae:	6161                	addi	sp,sp,80
ffffffffc02048b0:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc02048b2:	000bb683          	ld	a3,0(s7)
ffffffffc02048b6:	f4843783          	ld	a5,-184(s0)
ffffffffc02048ba:	fed790e3          	bne	a5,a3,ffffffffc020489a <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02048be:	f2842703          	lw	a4,-216(s0)
ffffffffc02048c2:	478d                	li	a5,3
ffffffffc02048c4:	0ef70b63          	beq	a4,a5,ffffffffc02049ba <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc02048c8:	4785                	li	a5,1
ffffffffc02048ca:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc02048cc:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc02048d0:	2d7000ef          	jal	ra,ffffffffc02053a6 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc02048d4:	000bb783          	ld	a5,0(s7)
ffffffffc02048d8:	0b07a783          	lw	a5,176(a5)
ffffffffc02048dc:	8b85                	andi	a5,a5,1
ffffffffc02048de:	d7c9                	beqz	a5,ffffffffc0204868 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc02048e0:	555d                	li	a0,-9
ffffffffc02048e2:	e0bff0ef          	jal	ra,ffffffffc02046ec <do_exit>
        proc = current->cptr;
ffffffffc02048e6:	000bb683          	ld	a3,0(s7)
ffffffffc02048ea:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc02048ec:	d45d                	beqz	s0,ffffffffc020489a <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02048ee:	470d                	li	a4,3
ffffffffc02048f0:	a021                	j	ffffffffc02048f8 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc02048f2:	10043403          	ld	s0,256(s0)
ffffffffc02048f6:	d869                	beqz	s0,ffffffffc02048c8 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02048f8:	401c                	lw	a5,0(s0)
ffffffffc02048fa:	fee79ce3          	bne	a5,a4,ffffffffc02048f2 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc02048fe:	000c5797          	auipc	a5,0xc5
ffffffffc0204902:	5227b783          	ld	a5,1314(a5) # ffffffffc02c9e20 <idleproc>
ffffffffc0204906:	0c878963          	beq	a5,s0,ffffffffc02049d8 <do_wait.part.0+0x1a2>
ffffffffc020490a:	000c5797          	auipc	a5,0xc5
ffffffffc020490e:	51e7b783          	ld	a5,1310(a5) # ffffffffc02c9e28 <initproc>
ffffffffc0204912:	0cf40363          	beq	s0,a5,ffffffffc02049d8 <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc0204916:	000a0663          	beqz	s4,ffffffffc0204922 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc020491a:	0e842783          	lw	a5,232(s0)
ffffffffc020491e:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8c50>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204922:	100027f3          	csrr	a5,sstatus
ffffffffc0204926:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204928:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020492a:	e7c1                	bnez	a5,ffffffffc02049b2 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020492c:	6c70                	ld	a2,216(s0)
ffffffffc020492e:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc0204930:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0204934:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0204936:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204938:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020493a:	6470                	ld	a2,200(s0)
ffffffffc020493c:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc020493e:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204940:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc0204942:	c319                	beqz	a4,ffffffffc0204948 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0204944:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc0204946:	7c7c                	ld	a5,248(s0)
ffffffffc0204948:	c3b5                	beqz	a5,ffffffffc02049ac <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc020494a:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc020494e:	000c5717          	auipc	a4,0xc5
ffffffffc0204952:	4e270713          	addi	a4,a4,1250 # ffffffffc02c9e30 <nr_process>
ffffffffc0204956:	431c                	lw	a5,0(a4)
ffffffffc0204958:	37fd                	addiw	a5,a5,-1
ffffffffc020495a:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc020495c:	e5a9                	bnez	a1,ffffffffc02049a6 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020495e:	6814                	ld	a3,16(s0)
ffffffffc0204960:	c02007b7          	lui	a5,0xc0200
ffffffffc0204964:	04f6ee63          	bltu	a3,a5,ffffffffc02049c0 <do_wait.part.0+0x18a>
ffffffffc0204968:	000c5797          	auipc	a5,0xc5
ffffffffc020496c:	4a07b783          	ld	a5,1184(a5) # ffffffffc02c9e08 <va_pa_offset>
ffffffffc0204970:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204972:	82b1                	srli	a3,a3,0xc
ffffffffc0204974:	000c5797          	auipc	a5,0xc5
ffffffffc0204978:	47c7b783          	ld	a5,1148(a5) # ffffffffc02c9df0 <npage>
ffffffffc020497c:	06f6fa63          	bgeu	a3,a5,ffffffffc02049f0 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0204980:	00003517          	auipc	a0,0x3
ffffffffc0204984:	22053503          	ld	a0,544(a0) # ffffffffc0207ba0 <nbase>
ffffffffc0204988:	8e89                	sub	a3,a3,a0
ffffffffc020498a:	069a                	slli	a3,a3,0x6
ffffffffc020498c:	000c5517          	auipc	a0,0xc5
ffffffffc0204990:	46c53503          	ld	a0,1132(a0) # ffffffffc02c9df8 <pages>
ffffffffc0204994:	9536                	add	a0,a0,a3
ffffffffc0204996:	4589                	li	a1,2
ffffffffc0204998:	dfafd0ef          	jal	ra,ffffffffc0201f92 <free_pages>
    kfree(proc);
ffffffffc020499c:	8522                	mv	a0,s0
ffffffffc020499e:	c88fd0ef          	jal	ra,ffffffffc0201e26 <kfree>
    return 0;
ffffffffc02049a2:	4501                	li	a0,0
ffffffffc02049a4:	bde5                	j	ffffffffc020489c <do_wait.part.0+0x66>
        intr_enable();
ffffffffc02049a6:	808fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02049aa:	bf55                	j	ffffffffc020495e <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc02049ac:	701c                	ld	a5,32(s0)
ffffffffc02049ae:	fbf8                	sd	a4,240(a5)
ffffffffc02049b0:	bf79                	j	ffffffffc020494e <do_wait.part.0+0x118>
        intr_disable();
ffffffffc02049b2:	802fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc02049b6:	4585                	li	a1,1
ffffffffc02049b8:	bf95                	j	ffffffffc020492c <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02049ba:	f2840413          	addi	s0,s0,-216
ffffffffc02049be:	b781                	j	ffffffffc02048fe <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc02049c0:	00002617          	auipc	a2,0x2
ffffffffc02049c4:	f9060613          	addi	a2,a2,-112 # ffffffffc0206950 <default_pmm_manager+0xe0>
ffffffffc02049c8:	07700593          	li	a1,119
ffffffffc02049cc:	00002517          	auipc	a0,0x2
ffffffffc02049d0:	f0450513          	addi	a0,a0,-252 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc02049d4:	abbfb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc02049d8:	00003617          	auipc	a2,0x3
ffffffffc02049dc:	9a860613          	addi	a2,a2,-1624 # ffffffffc0207380 <default_pmm_manager+0xb10>
ffffffffc02049e0:	37b00593          	li	a1,891
ffffffffc02049e4:	00003517          	auipc	a0,0x3
ffffffffc02049e8:	8fc50513          	addi	a0,a0,-1796 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc02049ec:	aa3fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02049f0:	00002617          	auipc	a2,0x2
ffffffffc02049f4:	f8860613          	addi	a2,a2,-120 # ffffffffc0206978 <default_pmm_manager+0x108>
ffffffffc02049f8:	06900593          	li	a1,105
ffffffffc02049fc:	00002517          	auipc	a0,0x2
ffffffffc0204a00:	ed450513          	addi	a0,a0,-300 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc0204a04:	a8bfb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204a08 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc0204a08:	1141                	addi	sp,sp,-16
ffffffffc0204a0a:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204a0c:	dc6fd0ef          	jal	ra,ffffffffc0201fd2 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0204a10:	b62fd0ef          	jal	ra,ffffffffc0201d72 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204a14:	4601                	li	a2,0
ffffffffc0204a16:	4581                	li	a1,0
ffffffffc0204a18:	fffff517          	auipc	a0,0xfffff
ffffffffc0204a1c:	72050513          	addi	a0,a0,1824 # ffffffffc0204138 <user_main>
ffffffffc0204a20:	c7dff0ef          	jal	ra,ffffffffc020469c <kernel_thread>
    if (pid <= 0)
ffffffffc0204a24:	00a04563          	bgtz	a0,ffffffffc0204a2e <init_main+0x26>
ffffffffc0204a28:	a071                	j	ffffffffc0204ab4 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc0204a2a:	17d000ef          	jal	ra,ffffffffc02053a6 <schedule>
    if (code_store != NULL)
ffffffffc0204a2e:	4581                	li	a1,0
ffffffffc0204a30:	4501                	li	a0,0
ffffffffc0204a32:	e05ff0ef          	jal	ra,ffffffffc0204836 <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc0204a36:	d975                	beqz	a0,ffffffffc0204a2a <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0204a38:	00003517          	auipc	a0,0x3
ffffffffc0204a3c:	98850513          	addi	a0,a0,-1656 # ffffffffc02073c0 <default_pmm_manager+0xb50>
ffffffffc0204a40:	f54fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204a44:	000c5797          	auipc	a5,0xc5
ffffffffc0204a48:	3e47b783          	ld	a5,996(a5) # ffffffffc02c9e28 <initproc>
ffffffffc0204a4c:	7bf8                	ld	a4,240(a5)
ffffffffc0204a4e:	e339                	bnez	a4,ffffffffc0204a94 <init_main+0x8c>
ffffffffc0204a50:	7ff8                	ld	a4,248(a5)
ffffffffc0204a52:	e329                	bnez	a4,ffffffffc0204a94 <init_main+0x8c>
ffffffffc0204a54:	1007b703          	ld	a4,256(a5)
ffffffffc0204a58:	ef15                	bnez	a4,ffffffffc0204a94 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0204a5a:	000c5697          	auipc	a3,0xc5
ffffffffc0204a5e:	3d66a683          	lw	a3,982(a3) # ffffffffc02c9e30 <nr_process>
ffffffffc0204a62:	4709                	li	a4,2
ffffffffc0204a64:	0ae69463          	bne	a3,a4,ffffffffc0204b0c <init_main+0x104>
    return listelm->next;
ffffffffc0204a68:	000c5697          	auipc	a3,0xc5
ffffffffc0204a6c:	33868693          	addi	a3,a3,824 # ffffffffc02c9da0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204a70:	6698                	ld	a4,8(a3)
ffffffffc0204a72:	0c878793          	addi	a5,a5,200
ffffffffc0204a76:	06f71b63          	bne	a4,a5,ffffffffc0204aec <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204a7a:	629c                	ld	a5,0(a3)
ffffffffc0204a7c:	04f71863          	bne	a4,a5,ffffffffc0204acc <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204a80:	00003517          	auipc	a0,0x3
ffffffffc0204a84:	a2850513          	addi	a0,a0,-1496 # ffffffffc02074a8 <default_pmm_manager+0xc38>
ffffffffc0204a88:	f0cfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
}
ffffffffc0204a8c:	60a2                	ld	ra,8(sp)
ffffffffc0204a8e:	4501                	li	a0,0
ffffffffc0204a90:	0141                	addi	sp,sp,16
ffffffffc0204a92:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204a94:	00003697          	auipc	a3,0x3
ffffffffc0204a98:	95468693          	addi	a3,a3,-1708 # ffffffffc02073e8 <default_pmm_manager+0xb78>
ffffffffc0204a9c:	00002617          	auipc	a2,0x2
ffffffffc0204aa0:	a2460613          	addi	a2,a2,-1500 # ffffffffc02064c0 <commands+0x858>
ffffffffc0204aa4:	3ec00593          	li	a1,1004
ffffffffc0204aa8:	00003517          	auipc	a0,0x3
ffffffffc0204aac:	83850513          	addi	a0,a0,-1992 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc0204ab0:	9dffb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("create user_main failed.\n");
ffffffffc0204ab4:	00003617          	auipc	a2,0x3
ffffffffc0204ab8:	8ec60613          	addi	a2,a2,-1812 # ffffffffc02073a0 <default_pmm_manager+0xb30>
ffffffffc0204abc:	3e300593          	li	a1,995
ffffffffc0204ac0:	00003517          	auipc	a0,0x3
ffffffffc0204ac4:	82050513          	addi	a0,a0,-2016 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc0204ac8:	9c7fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204acc:	00003697          	auipc	a3,0x3
ffffffffc0204ad0:	9ac68693          	addi	a3,a3,-1620 # ffffffffc0207478 <default_pmm_manager+0xc08>
ffffffffc0204ad4:	00002617          	auipc	a2,0x2
ffffffffc0204ad8:	9ec60613          	addi	a2,a2,-1556 # ffffffffc02064c0 <commands+0x858>
ffffffffc0204adc:	3ef00593          	li	a1,1007
ffffffffc0204ae0:	00003517          	auipc	a0,0x3
ffffffffc0204ae4:	80050513          	addi	a0,a0,-2048 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc0204ae8:	9a7fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204aec:	00003697          	auipc	a3,0x3
ffffffffc0204af0:	95c68693          	addi	a3,a3,-1700 # ffffffffc0207448 <default_pmm_manager+0xbd8>
ffffffffc0204af4:	00002617          	auipc	a2,0x2
ffffffffc0204af8:	9cc60613          	addi	a2,a2,-1588 # ffffffffc02064c0 <commands+0x858>
ffffffffc0204afc:	3ee00593          	li	a1,1006
ffffffffc0204b00:	00002517          	auipc	a0,0x2
ffffffffc0204b04:	7e050513          	addi	a0,a0,2016 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc0204b08:	987fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(nr_process == 2);
ffffffffc0204b0c:	00003697          	auipc	a3,0x3
ffffffffc0204b10:	92c68693          	addi	a3,a3,-1748 # ffffffffc0207438 <default_pmm_manager+0xbc8>
ffffffffc0204b14:	00002617          	auipc	a2,0x2
ffffffffc0204b18:	9ac60613          	addi	a2,a2,-1620 # ffffffffc02064c0 <commands+0x858>
ffffffffc0204b1c:	3ed00593          	li	a1,1005
ffffffffc0204b20:	00002517          	auipc	a0,0x2
ffffffffc0204b24:	7c050513          	addi	a0,a0,1984 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc0204b28:	967fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0204b2c <do_execve>:
{
ffffffffc0204b2c:	7171                	addi	sp,sp,-176
ffffffffc0204b2e:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204b30:	000c5d97          	auipc	s11,0xc5
ffffffffc0204b34:	2e8d8d93          	addi	s11,s11,744 # ffffffffc02c9e18 <current>
ffffffffc0204b38:	000db783          	ld	a5,0(s11)
{
ffffffffc0204b3c:	e94a                	sd	s2,144(sp)
ffffffffc0204b3e:	f122                	sd	s0,160(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204b40:	0287b903          	ld	s2,40(a5)
{
ffffffffc0204b44:	ed26                	sd	s1,152(sp)
ffffffffc0204b46:	f8da                	sd	s6,112(sp)
ffffffffc0204b48:	84aa                	mv	s1,a0
ffffffffc0204b4a:	8b32                	mv	s6,a2
ffffffffc0204b4c:	842e                	mv	s0,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204b4e:	862e                	mv	a2,a1
ffffffffc0204b50:	4681                	li	a3,0
ffffffffc0204b52:	85aa                	mv	a1,a0
ffffffffc0204b54:	854a                	mv	a0,s2
{
ffffffffc0204b56:	f506                	sd	ra,168(sp)
ffffffffc0204b58:	e54e                	sd	s3,136(sp)
ffffffffc0204b5a:	e152                	sd	s4,128(sp)
ffffffffc0204b5c:	fcd6                	sd	s5,120(sp)
ffffffffc0204b5e:	f4de                	sd	s7,104(sp)
ffffffffc0204b60:	f0e2                	sd	s8,96(sp)
ffffffffc0204b62:	ece6                	sd	s9,88(sp)
ffffffffc0204b64:	e8ea                	sd	s10,80(sp)
ffffffffc0204b66:	f05a                	sd	s6,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204b68:	afaff0ef          	jal	ra,ffffffffc0203e62 <user_mem_check>
ffffffffc0204b6c:	40050a63          	beqz	a0,ffffffffc0204f80 <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204b70:	4641                	li	a2,16
ffffffffc0204b72:	4581                	li	a1,0
ffffffffc0204b74:	1808                	addi	a0,sp,48
ffffffffc0204b76:	65d000ef          	jal	ra,ffffffffc02059d2 <memset>
    memcpy(local_name, name, len);
ffffffffc0204b7a:	47bd                	li	a5,15
ffffffffc0204b7c:	8622                	mv	a2,s0
ffffffffc0204b7e:	1e87e263          	bltu	a5,s0,ffffffffc0204d62 <do_execve+0x236>
ffffffffc0204b82:	85a6                	mv	a1,s1
ffffffffc0204b84:	1808                	addi	a0,sp,48
ffffffffc0204b86:	65f000ef          	jal	ra,ffffffffc02059e4 <memcpy>
    if (mm != NULL)
ffffffffc0204b8a:	1e090363          	beqz	s2,ffffffffc0204d70 <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc0204b8e:	00002517          	auipc	a0,0x2
ffffffffc0204b92:	51250513          	addi	a0,a0,1298 # ffffffffc02070a0 <default_pmm_manager+0x830>
ffffffffc0204b96:	e36fb0ef          	jal	ra,ffffffffc02001cc <cputs>
ffffffffc0204b9a:	000c5797          	auipc	a5,0xc5
ffffffffc0204b9e:	2467b783          	ld	a5,582(a5) # ffffffffc02c9de0 <boot_pgdir_pa>
ffffffffc0204ba2:	577d                	li	a4,-1
ffffffffc0204ba4:	177e                	slli	a4,a4,0x3f
ffffffffc0204ba6:	83b1                	srli	a5,a5,0xc
ffffffffc0204ba8:	8fd9                	or	a5,a5,a4
ffffffffc0204baa:	18079073          	csrw	satp,a5
ffffffffc0204bae:	03092783          	lw	a5,48(s2) # ffffffff80000030 <_binary_obj___user_exit_out_size+0xffffffff7fff4e68>
ffffffffc0204bb2:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204bb6:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0)
ffffffffc0204bba:	2c070463          	beqz	a4,ffffffffc0204e82 <do_execve+0x356>
        current->mm = NULL;
ffffffffc0204bbe:	000db783          	ld	a5,0(s11)
ffffffffc0204bc2:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0204bc6:	c27fe0ef          	jal	ra,ffffffffc02037ec <mm_create>
ffffffffc0204bca:	842a                	mv	s0,a0
ffffffffc0204bcc:	1c050d63          	beqz	a0,ffffffffc0204da6 <do_execve+0x27a>
    if ((page = alloc_page()) == NULL)
ffffffffc0204bd0:	4505                	li	a0,1
ffffffffc0204bd2:	b82fd0ef          	jal	ra,ffffffffc0201f54 <alloc_pages>
ffffffffc0204bd6:	3a050963          	beqz	a0,ffffffffc0204f88 <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc0204bda:	000c5c97          	auipc	s9,0xc5
ffffffffc0204bde:	21ec8c93          	addi	s9,s9,542 # ffffffffc02c9df8 <pages>
ffffffffc0204be2:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204be6:	000c5c17          	auipc	s8,0xc5
ffffffffc0204bea:	20ac0c13          	addi	s8,s8,522 # ffffffffc02c9df0 <npage>
    return page - pages + nbase;
ffffffffc0204bee:	00003717          	auipc	a4,0x3
ffffffffc0204bf2:	fb273703          	ld	a4,-78(a4) # ffffffffc0207ba0 <nbase>
ffffffffc0204bf6:	40d506b3          	sub	a3,a0,a3
ffffffffc0204bfa:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204bfc:	5a7d                	li	s4,-1
ffffffffc0204bfe:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0204c02:	96ba                	add	a3,a3,a4
ffffffffc0204c04:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204c06:	00ca5713          	srli	a4,s4,0xc
ffffffffc0204c0a:	ec3a                	sd	a4,24(sp)
ffffffffc0204c0c:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c0e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204c10:	38f77063          	bgeu	a4,a5,ffffffffc0204f90 <do_execve+0x464>
ffffffffc0204c14:	000c5a97          	auipc	s5,0xc5
ffffffffc0204c18:	1f4a8a93          	addi	s5,s5,500 # ffffffffc02c9e08 <va_pa_offset>
ffffffffc0204c1c:	000ab483          	ld	s1,0(s5)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204c20:	6605                	lui	a2,0x1
ffffffffc0204c22:	000c5597          	auipc	a1,0xc5
ffffffffc0204c26:	1c65b583          	ld	a1,454(a1) # ffffffffc02c9de8 <boot_pgdir_va>
ffffffffc0204c2a:	94b6                	add	s1,s1,a3
ffffffffc0204c2c:	8526                	mv	a0,s1
ffffffffc0204c2e:	5b7000ef          	jal	ra,ffffffffc02059e4 <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204c32:	7782                	ld	a5,32(sp)
ffffffffc0204c34:	4398                	lw	a4,0(a5)
ffffffffc0204c36:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204c3a:	ec04                	sd	s1,24(s0)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204c3c:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b93b7>
ffffffffc0204c40:	14f71963          	bne	a4,a5,ffffffffc0204d92 <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204c44:	7682                	ld	a3,32(sp)
    struct Page *page = NULL;
ffffffffc0204c46:	4b81                	li	s7,0
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204c48:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204c4c:	0206b903          	ld	s2,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204c50:	00371793          	slli	a5,a4,0x3
ffffffffc0204c54:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204c56:	9936                	add	s2,s2,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204c58:	078e                	slli	a5,a5,0x3
ffffffffc0204c5a:	97ca                	add	a5,a5,s2
ffffffffc0204c5c:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204c5e:	00f97c63          	bgeu	s2,a5,ffffffffc0204c76 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204c62:	00092783          	lw	a5,0(s2)
ffffffffc0204c66:	4705                	li	a4,1
ffffffffc0204c68:	14e78163          	beq	a5,a4,ffffffffc0204daa <do_execve+0x27e>
    for (; ph < ph_end; ph++)
ffffffffc0204c6c:	77a2                	ld	a5,40(sp)
ffffffffc0204c6e:	03890913          	addi	s2,s2,56
ffffffffc0204c72:	fef968e3          	bltu	s2,a5,ffffffffc0204c62 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204c76:	4701                	li	a4,0
ffffffffc0204c78:	46ad                	li	a3,11
ffffffffc0204c7a:	00100637          	lui	a2,0x100
ffffffffc0204c7e:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204c82:	8522                	mv	a0,s0
ffffffffc0204c84:	cfbfe0ef          	jal	ra,ffffffffc020397e <mm_map>
ffffffffc0204c88:	89aa                	mv	s3,a0
ffffffffc0204c8a:	1e051263          	bnez	a0,ffffffffc0204e6e <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204c8e:	6c08                	ld	a0,24(s0)
ffffffffc0204c90:	467d                	li	a2,31
ffffffffc0204c92:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204c96:	a71fe0ef          	jal	ra,ffffffffc0203706 <pgdir_alloc_page>
ffffffffc0204c9a:	38050363          	beqz	a0,ffffffffc0205020 <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204c9e:	6c08                	ld	a0,24(s0)
ffffffffc0204ca0:	467d                	li	a2,31
ffffffffc0204ca2:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204ca6:	a61fe0ef          	jal	ra,ffffffffc0203706 <pgdir_alloc_page>
ffffffffc0204caa:	34050b63          	beqz	a0,ffffffffc0205000 <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204cae:	6c08                	ld	a0,24(s0)
ffffffffc0204cb0:	467d                	li	a2,31
ffffffffc0204cb2:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204cb6:	a51fe0ef          	jal	ra,ffffffffc0203706 <pgdir_alloc_page>
ffffffffc0204cba:	32050363          	beqz	a0,ffffffffc0204fe0 <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204cbe:	6c08                	ld	a0,24(s0)
ffffffffc0204cc0:	467d                	li	a2,31
ffffffffc0204cc2:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204cc6:	a41fe0ef          	jal	ra,ffffffffc0203706 <pgdir_alloc_page>
ffffffffc0204cca:	2e050b63          	beqz	a0,ffffffffc0204fc0 <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc0204cce:	581c                	lw	a5,48(s0)
    current->mm = mm;
ffffffffc0204cd0:	000db603          	ld	a2,0(s11)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204cd4:	6c14                	ld	a3,24(s0)
ffffffffc0204cd6:	2785                	addiw	a5,a5,1
ffffffffc0204cd8:	d81c                	sw	a5,48(s0)
    current->mm = mm;
ffffffffc0204cda:	f600                	sd	s0,40(a2)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204cdc:	c02007b7          	lui	a5,0xc0200
ffffffffc0204ce0:	2cf6e463          	bltu	a3,a5,ffffffffc0204fa8 <do_execve+0x47c>
ffffffffc0204ce4:	000ab783          	ld	a5,0(s5)
ffffffffc0204ce8:	577d                	li	a4,-1
ffffffffc0204cea:	177e                	slli	a4,a4,0x3f
ffffffffc0204cec:	8e9d                	sub	a3,a3,a5
ffffffffc0204cee:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204cf2:	f654                	sd	a3,168(a2)
ffffffffc0204cf4:	8fd9                	or	a5,a5,a4
ffffffffc0204cf6:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0204cfa:	7244                	ld	s1,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204cfc:	4581                	li	a1,0
ffffffffc0204cfe:	12000613          	li	a2,288
ffffffffc0204d02:	8526                	mv	a0,s1
ffffffffc0204d04:	4cf000ef          	jal	ra,ffffffffc02059d2 <memset>
    tf->epc = elf->e_entry;
ffffffffc0204d08:	7782                	ld	a5,32(sp)
ffffffffc0204d0a:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204d0c:	4785                	li	a5,1
ffffffffc0204d0e:	07fe                	slli	a5,a5,0x1f
ffffffffc0204d10:	e89c                	sd	a5,16(s1)
    tf->epc = elf->e_entry;
ffffffffc0204d12:	10e4b423          	sd	a4,264(s1)
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204d16:	100027f3          	csrr	a5,sstatus
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d1a:	000db403          	ld	s0,0(s11)
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204d1e:	edf7f793          	andi	a5,a5,-289
ffffffffc0204d22:	0207e793          	ori	a5,a5,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d26:	0b440413          	addi	s0,s0,180
ffffffffc0204d2a:	4641                	li	a2,16
ffffffffc0204d2c:	4581                	li	a1,0
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204d2e:	10f4b023          	sd	a5,256(s1)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d32:	8522                	mv	a0,s0
ffffffffc0204d34:	49f000ef          	jal	ra,ffffffffc02059d2 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204d38:	463d                	li	a2,15
ffffffffc0204d3a:	180c                	addi	a1,sp,48
ffffffffc0204d3c:	8522                	mv	a0,s0
ffffffffc0204d3e:	4a7000ef          	jal	ra,ffffffffc02059e4 <memcpy>
}
ffffffffc0204d42:	70aa                	ld	ra,168(sp)
ffffffffc0204d44:	740a                	ld	s0,160(sp)
ffffffffc0204d46:	64ea                	ld	s1,152(sp)
ffffffffc0204d48:	694a                	ld	s2,144(sp)
ffffffffc0204d4a:	6a0a                	ld	s4,128(sp)
ffffffffc0204d4c:	7ae6                	ld	s5,120(sp)
ffffffffc0204d4e:	7b46                	ld	s6,112(sp)
ffffffffc0204d50:	7ba6                	ld	s7,104(sp)
ffffffffc0204d52:	7c06                	ld	s8,96(sp)
ffffffffc0204d54:	6ce6                	ld	s9,88(sp)
ffffffffc0204d56:	6d46                	ld	s10,80(sp)
ffffffffc0204d58:	6da6                	ld	s11,72(sp)
ffffffffc0204d5a:	854e                	mv	a0,s3
ffffffffc0204d5c:	69aa                	ld	s3,136(sp)
ffffffffc0204d5e:	614d                	addi	sp,sp,176
ffffffffc0204d60:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0204d62:	463d                	li	a2,15
ffffffffc0204d64:	85a6                	mv	a1,s1
ffffffffc0204d66:	1808                	addi	a0,sp,48
ffffffffc0204d68:	47d000ef          	jal	ra,ffffffffc02059e4 <memcpy>
    if (mm != NULL)
ffffffffc0204d6c:	e20911e3          	bnez	s2,ffffffffc0204b8e <do_execve+0x62>
    if (current->mm != NULL)
ffffffffc0204d70:	000db783          	ld	a5,0(s11)
ffffffffc0204d74:	779c                	ld	a5,40(a5)
ffffffffc0204d76:	e40788e3          	beqz	a5,ffffffffc0204bc6 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0204d7a:	00002617          	auipc	a2,0x2
ffffffffc0204d7e:	74e60613          	addi	a2,a2,1870 # ffffffffc02074c8 <default_pmm_manager+0xc58>
ffffffffc0204d82:	26700593          	li	a1,615
ffffffffc0204d86:	00002517          	auipc	a0,0x2
ffffffffc0204d8a:	55a50513          	addi	a0,a0,1370 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc0204d8e:	f00fb0ef          	jal	ra,ffffffffc020048e <__panic>
    put_pgdir(mm);
ffffffffc0204d92:	8522                	mv	a0,s0
ffffffffc0204d94:	c22ff0ef          	jal	ra,ffffffffc02041b6 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204d98:	8522                	mv	a0,s0
ffffffffc0204d9a:	b93fe0ef          	jal	ra,ffffffffc020392c <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0204d9e:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc0204da0:	854e                	mv	a0,s3
ffffffffc0204da2:	94bff0ef          	jal	ra,ffffffffc02046ec <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0204da6:	59f1                	li	s3,-4
ffffffffc0204da8:	bfe5                	j	ffffffffc0204da0 <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204daa:	02893603          	ld	a2,40(s2)
ffffffffc0204dae:	02093783          	ld	a5,32(s2)
ffffffffc0204db2:	1cf66d63          	bltu	a2,a5,ffffffffc0204f8c <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204db6:	00492783          	lw	a5,4(s2)
ffffffffc0204dba:	0017f693          	andi	a3,a5,1
ffffffffc0204dbe:	c291                	beqz	a3,ffffffffc0204dc2 <do_execve+0x296>
            vm_flags |= VM_EXEC;
ffffffffc0204dc0:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204dc2:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204dc6:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204dc8:	e779                	bnez	a4,ffffffffc0204e96 <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204dca:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204dcc:	c781                	beqz	a5,ffffffffc0204dd4 <do_execve+0x2a8>
            vm_flags |= VM_READ;
ffffffffc0204dce:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc0204dd2:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE)
ffffffffc0204dd4:	0026f793          	andi	a5,a3,2
ffffffffc0204dd8:	e3f1                	bnez	a5,ffffffffc0204e9c <do_execve+0x370>
        if (vm_flags & VM_EXEC)
ffffffffc0204dda:	0046f793          	andi	a5,a3,4
ffffffffc0204dde:	c399                	beqz	a5,ffffffffc0204de4 <do_execve+0x2b8>
            perm |= PTE_X;
ffffffffc0204de0:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204de4:	01093583          	ld	a1,16(s2)
ffffffffc0204de8:	4701                	li	a4,0
ffffffffc0204dea:	8522                	mv	a0,s0
ffffffffc0204dec:	b93fe0ef          	jal	ra,ffffffffc020397e <mm_map>
ffffffffc0204df0:	89aa                	mv	s3,a0
ffffffffc0204df2:	ed35                	bnez	a0,ffffffffc0204e6e <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204df4:	01093b03          	ld	s6,16(s2)
ffffffffc0204df8:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0204dfa:	02093983          	ld	s3,32(s2)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204dfe:	00893483          	ld	s1,8(s2)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204e02:	00fb7a33          	and	s4,s6,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204e06:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204e08:	99da                	add	s3,s3,s6
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204e0a:	94be                	add	s1,s1,a5
        while (start < end)
ffffffffc0204e0c:	053b6963          	bltu	s6,s3,ffffffffc0204e5e <do_execve+0x332>
ffffffffc0204e10:	aa95                	j	ffffffffc0204f84 <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204e12:	6785                	lui	a5,0x1
ffffffffc0204e14:	414b0533          	sub	a0,s6,s4
ffffffffc0204e18:	9a3e                	add	s4,s4,a5
ffffffffc0204e1a:	416a0633          	sub	a2,s4,s6
            if (end < la)
ffffffffc0204e1e:	0149f463          	bgeu	s3,s4,ffffffffc0204e26 <do_execve+0x2fa>
                size -= la - end;
ffffffffc0204e22:	41698633          	sub	a2,s3,s6
    return page - pages + nbase;
ffffffffc0204e26:	000cb683          	ld	a3,0(s9)
ffffffffc0204e2a:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204e2c:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204e30:	40db86b3          	sub	a3,s7,a3
ffffffffc0204e34:	8699                	srai	a3,a3,0x6
ffffffffc0204e36:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204e38:	67e2                	ld	a5,24(sp)
ffffffffc0204e3a:	00f6f8b3          	and	a7,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e3e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e40:	14b8f863          	bgeu	a7,a1,ffffffffc0204f90 <do_execve+0x464>
ffffffffc0204e44:	000ab883          	ld	a7,0(s5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204e48:	85a6                	mv	a1,s1
            start += size, from += size;
ffffffffc0204e4a:	9b32                	add	s6,s6,a2
ffffffffc0204e4c:	96c6                	add	a3,a3,a7
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204e4e:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0204e50:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204e52:	393000ef          	jal	ra,ffffffffc02059e4 <memcpy>
            start += size, from += size;
ffffffffc0204e56:	6622                	ld	a2,8(sp)
ffffffffc0204e58:	94b2                	add	s1,s1,a2
        while (start < end)
ffffffffc0204e5a:	053b7363          	bgeu	s6,s3,ffffffffc0204ea0 <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204e5e:	6c08                	ld	a0,24(s0)
ffffffffc0204e60:	866a                	mv	a2,s10
ffffffffc0204e62:	85d2                	mv	a1,s4
ffffffffc0204e64:	8a3fe0ef          	jal	ra,ffffffffc0203706 <pgdir_alloc_page>
ffffffffc0204e68:	8baa                	mv	s7,a0
ffffffffc0204e6a:	f545                	bnez	a0,ffffffffc0204e12 <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0204e6c:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0204e6e:	8522                	mv	a0,s0
ffffffffc0204e70:	c59fe0ef          	jal	ra,ffffffffc0203ac8 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204e74:	8522                	mv	a0,s0
ffffffffc0204e76:	b40ff0ef          	jal	ra,ffffffffc02041b6 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204e7a:	8522                	mv	a0,s0
ffffffffc0204e7c:	ab1fe0ef          	jal	ra,ffffffffc020392c <mm_destroy>
    return ret;
ffffffffc0204e80:	b705                	j	ffffffffc0204da0 <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0204e82:	854a                	mv	a0,s2
ffffffffc0204e84:	c45fe0ef          	jal	ra,ffffffffc0203ac8 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204e88:	854a                	mv	a0,s2
ffffffffc0204e8a:	b2cff0ef          	jal	ra,ffffffffc02041b6 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204e8e:	854a                	mv	a0,s2
ffffffffc0204e90:	a9dfe0ef          	jal	ra,ffffffffc020392c <mm_destroy>
ffffffffc0204e94:	b32d                	j	ffffffffc0204bbe <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0204e96:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204e9a:	fb95                	bnez	a5,ffffffffc0204dce <do_execve+0x2a2>
            perm |= (PTE_W | PTE_R);
ffffffffc0204e9c:	4d5d                	li	s10,23
ffffffffc0204e9e:	bf35                	j	ffffffffc0204dda <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204ea0:	01093483          	ld	s1,16(s2)
ffffffffc0204ea4:	02893683          	ld	a3,40(s2)
ffffffffc0204ea8:	94b6                	add	s1,s1,a3
        if (start < la)
ffffffffc0204eaa:	074b7d63          	bgeu	s6,s4,ffffffffc0204f24 <do_execve+0x3f8>
            if (start == end)
ffffffffc0204eae:	db648fe3          	beq	s1,s6,ffffffffc0204c6c <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204eb2:	6785                	lui	a5,0x1
ffffffffc0204eb4:	00fb0533          	add	a0,s6,a5
ffffffffc0204eb8:	41450533          	sub	a0,a0,s4
                size -= la - end;
ffffffffc0204ebc:	416489b3          	sub	s3,s1,s6
            if (end < la)
ffffffffc0204ec0:	0b44fd63          	bgeu	s1,s4,ffffffffc0204f7a <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0204ec4:	000cb683          	ld	a3,0(s9)
ffffffffc0204ec8:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204eca:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0204ece:	40db86b3          	sub	a3,s7,a3
ffffffffc0204ed2:	8699                	srai	a3,a3,0x6
ffffffffc0204ed4:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204ed6:	67e2                	ld	a5,24(sp)
ffffffffc0204ed8:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204edc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ede:	0ac5f963          	bgeu	a1,a2,ffffffffc0204f90 <do_execve+0x464>
ffffffffc0204ee2:	000ab883          	ld	a7,0(s5)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204ee6:	864e                	mv	a2,s3
ffffffffc0204ee8:	4581                	li	a1,0
ffffffffc0204eea:	96c6                	add	a3,a3,a7
ffffffffc0204eec:	9536                	add	a0,a0,a3
ffffffffc0204eee:	2e5000ef          	jal	ra,ffffffffc02059d2 <memset>
            start += size;
ffffffffc0204ef2:	01698733          	add	a4,s3,s6
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204ef6:	0344f463          	bgeu	s1,s4,ffffffffc0204f1e <do_execve+0x3f2>
ffffffffc0204efa:	d6e489e3          	beq	s1,a4,ffffffffc0204c6c <do_execve+0x140>
ffffffffc0204efe:	00002697          	auipc	a3,0x2
ffffffffc0204f02:	5f268693          	addi	a3,a3,1522 # ffffffffc02074f0 <default_pmm_manager+0xc80>
ffffffffc0204f06:	00001617          	auipc	a2,0x1
ffffffffc0204f0a:	5ba60613          	addi	a2,a2,1466 # ffffffffc02064c0 <commands+0x858>
ffffffffc0204f0e:	2d000593          	li	a1,720
ffffffffc0204f12:	00002517          	auipc	a0,0x2
ffffffffc0204f16:	3ce50513          	addi	a0,a0,974 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc0204f1a:	d74fb0ef          	jal	ra,ffffffffc020048e <__panic>
ffffffffc0204f1e:	ff4710e3          	bne	a4,s4,ffffffffc0204efe <do_execve+0x3d2>
ffffffffc0204f22:	8b52                	mv	s6,s4
        while (start < end)
ffffffffc0204f24:	d49b74e3          	bgeu	s6,s1,ffffffffc0204c6c <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204f28:	6c08                	ld	a0,24(s0)
ffffffffc0204f2a:	866a                	mv	a2,s10
ffffffffc0204f2c:	85d2                	mv	a1,s4
ffffffffc0204f2e:	fd8fe0ef          	jal	ra,ffffffffc0203706 <pgdir_alloc_page>
ffffffffc0204f32:	8baa                	mv	s7,a0
ffffffffc0204f34:	dd05                	beqz	a0,ffffffffc0204e6c <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204f36:	6785                	lui	a5,0x1
ffffffffc0204f38:	414b0533          	sub	a0,s6,s4
ffffffffc0204f3c:	9a3e                	add	s4,s4,a5
ffffffffc0204f3e:	416a0633          	sub	a2,s4,s6
            if (end < la)
ffffffffc0204f42:	0144f463          	bgeu	s1,s4,ffffffffc0204f4a <do_execve+0x41e>
                size -= la - end;
ffffffffc0204f46:	41648633          	sub	a2,s1,s6
    return page - pages + nbase;
ffffffffc0204f4a:	000cb683          	ld	a3,0(s9)
ffffffffc0204f4e:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204f50:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204f54:	40db86b3          	sub	a3,s7,a3
ffffffffc0204f58:	8699                	srai	a3,a3,0x6
ffffffffc0204f5a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204f5c:	67e2                	ld	a5,24(sp)
ffffffffc0204f5e:	00f6f8b3          	and	a7,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204f62:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204f64:	02b8f663          	bgeu	a7,a1,ffffffffc0204f90 <do_execve+0x464>
ffffffffc0204f68:	000ab883          	ld	a7,0(s5)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204f6c:	4581                	li	a1,0
            start += size;
ffffffffc0204f6e:	9b32                	add	s6,s6,a2
ffffffffc0204f70:	96c6                	add	a3,a3,a7
            memset(page2kva(page) + off, 0, size);
ffffffffc0204f72:	9536                	add	a0,a0,a3
ffffffffc0204f74:	25f000ef          	jal	ra,ffffffffc02059d2 <memset>
ffffffffc0204f78:	b775                	j	ffffffffc0204f24 <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204f7a:	416a09b3          	sub	s3,s4,s6
ffffffffc0204f7e:	b799                	j	ffffffffc0204ec4 <do_execve+0x398>
        return -E_INVAL;
ffffffffc0204f80:	59f5                	li	s3,-3
ffffffffc0204f82:	b3c1                	j	ffffffffc0204d42 <do_execve+0x216>
        while (start < end)
ffffffffc0204f84:	84da                	mv	s1,s6
ffffffffc0204f86:	bf39                	j	ffffffffc0204ea4 <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc0204f88:	59f1                	li	s3,-4
ffffffffc0204f8a:	bdc5                	j	ffffffffc0204e7a <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0204f8c:	59e1                	li	s3,-8
ffffffffc0204f8e:	b5c5                	j	ffffffffc0204e6e <do_execve+0x342>
ffffffffc0204f90:	00002617          	auipc	a2,0x2
ffffffffc0204f94:	91860613          	addi	a2,a2,-1768 # ffffffffc02068a8 <default_pmm_manager+0x38>
ffffffffc0204f98:	07100593          	li	a1,113
ffffffffc0204f9c:	00002517          	auipc	a0,0x2
ffffffffc0204fa0:	93450513          	addi	a0,a0,-1740 # ffffffffc02068d0 <default_pmm_manager+0x60>
ffffffffc0204fa4:	ceafb0ef          	jal	ra,ffffffffc020048e <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204fa8:	00002617          	auipc	a2,0x2
ffffffffc0204fac:	9a860613          	addi	a2,a2,-1624 # ffffffffc0206950 <default_pmm_manager+0xe0>
ffffffffc0204fb0:	2ef00593          	li	a1,751
ffffffffc0204fb4:	00002517          	auipc	a0,0x2
ffffffffc0204fb8:	32c50513          	addi	a0,a0,812 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc0204fbc:	cd2fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204fc0:	00002697          	auipc	a3,0x2
ffffffffc0204fc4:	64868693          	addi	a3,a3,1608 # ffffffffc0207608 <default_pmm_manager+0xd98>
ffffffffc0204fc8:	00001617          	auipc	a2,0x1
ffffffffc0204fcc:	4f860613          	addi	a2,a2,1272 # ffffffffc02064c0 <commands+0x858>
ffffffffc0204fd0:	2ea00593          	li	a1,746
ffffffffc0204fd4:	00002517          	auipc	a0,0x2
ffffffffc0204fd8:	30c50513          	addi	a0,a0,780 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc0204fdc:	cb2fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204fe0:	00002697          	auipc	a3,0x2
ffffffffc0204fe4:	5e068693          	addi	a3,a3,1504 # ffffffffc02075c0 <default_pmm_manager+0xd50>
ffffffffc0204fe8:	00001617          	auipc	a2,0x1
ffffffffc0204fec:	4d860613          	addi	a2,a2,1240 # ffffffffc02064c0 <commands+0x858>
ffffffffc0204ff0:	2e900593          	li	a1,745
ffffffffc0204ff4:	00002517          	auipc	a0,0x2
ffffffffc0204ff8:	2ec50513          	addi	a0,a0,748 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc0204ffc:	c92fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205000:	00002697          	auipc	a3,0x2
ffffffffc0205004:	57868693          	addi	a3,a3,1400 # ffffffffc0207578 <default_pmm_manager+0xd08>
ffffffffc0205008:	00001617          	auipc	a2,0x1
ffffffffc020500c:	4b860613          	addi	a2,a2,1208 # ffffffffc02064c0 <commands+0x858>
ffffffffc0205010:	2e800593          	li	a1,744
ffffffffc0205014:	00002517          	auipc	a0,0x2
ffffffffc0205018:	2cc50513          	addi	a0,a0,716 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc020501c:	c72fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0205020:	00002697          	auipc	a3,0x2
ffffffffc0205024:	51068693          	addi	a3,a3,1296 # ffffffffc0207530 <default_pmm_manager+0xcc0>
ffffffffc0205028:	00001617          	auipc	a2,0x1
ffffffffc020502c:	49860613          	addi	a2,a2,1176 # ffffffffc02064c0 <commands+0x858>
ffffffffc0205030:	2e700593          	li	a1,743
ffffffffc0205034:	00002517          	auipc	a0,0x2
ffffffffc0205038:	2ac50513          	addi	a0,a0,684 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc020503c:	c52fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc0205040 <do_yield>:
    current->need_resched = 1;
ffffffffc0205040:	000c5797          	auipc	a5,0xc5
ffffffffc0205044:	dd87b783          	ld	a5,-552(a5) # ffffffffc02c9e18 <current>
ffffffffc0205048:	4705                	li	a4,1
ffffffffc020504a:	ef98                	sd	a4,24(a5)
}
ffffffffc020504c:	4501                	li	a0,0
ffffffffc020504e:	8082                	ret

ffffffffc0205050 <do_wait>:
{
ffffffffc0205050:	1101                	addi	sp,sp,-32
ffffffffc0205052:	e822                	sd	s0,16(sp)
ffffffffc0205054:	e426                	sd	s1,8(sp)
ffffffffc0205056:	ec06                	sd	ra,24(sp)
ffffffffc0205058:	842e                	mv	s0,a1
ffffffffc020505a:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc020505c:	c999                	beqz	a1,ffffffffc0205072 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc020505e:	000c5797          	auipc	a5,0xc5
ffffffffc0205062:	dba7b783          	ld	a5,-582(a5) # ffffffffc02c9e18 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0205066:	7788                	ld	a0,40(a5)
ffffffffc0205068:	4685                	li	a3,1
ffffffffc020506a:	4611                	li	a2,4
ffffffffc020506c:	df7fe0ef          	jal	ra,ffffffffc0203e62 <user_mem_check>
ffffffffc0205070:	c909                	beqz	a0,ffffffffc0205082 <do_wait+0x32>
ffffffffc0205072:	85a2                	mv	a1,s0
}
ffffffffc0205074:	6442                	ld	s0,16(sp)
ffffffffc0205076:	60e2                	ld	ra,24(sp)
ffffffffc0205078:	8526                	mv	a0,s1
ffffffffc020507a:	64a2                	ld	s1,8(sp)
ffffffffc020507c:	6105                	addi	sp,sp,32
ffffffffc020507e:	fb8ff06f          	j	ffffffffc0204836 <do_wait.part.0>
ffffffffc0205082:	60e2                	ld	ra,24(sp)
ffffffffc0205084:	6442                	ld	s0,16(sp)
ffffffffc0205086:	64a2                	ld	s1,8(sp)
ffffffffc0205088:	5575                	li	a0,-3
ffffffffc020508a:	6105                	addi	sp,sp,32
ffffffffc020508c:	8082                	ret

ffffffffc020508e <do_kill>:
{
ffffffffc020508e:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc0205090:	6789                	lui	a5,0x2
{
ffffffffc0205092:	e406                	sd	ra,8(sp)
ffffffffc0205094:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc0205096:	fff5071b          	addiw	a4,a0,-1
ffffffffc020509a:	17f9                	addi	a5,a5,-2
ffffffffc020509c:	02e7e963          	bltu	a5,a4,ffffffffc02050ce <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02050a0:	842a                	mv	s0,a0
ffffffffc02050a2:	45a9                	li	a1,10
ffffffffc02050a4:	2501                	sext.w	a0,a0
ffffffffc02050a6:	486000ef          	jal	ra,ffffffffc020552c <hash32>
ffffffffc02050aa:	02051793          	slli	a5,a0,0x20
ffffffffc02050ae:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02050b2:	000c1797          	auipc	a5,0xc1
ffffffffc02050b6:	cee78793          	addi	a5,a5,-786 # ffffffffc02c5da0 <hash_list>
ffffffffc02050ba:	953e                	add	a0,a0,a5
ffffffffc02050bc:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc02050be:	a029                	j	ffffffffc02050c8 <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc02050c0:	f2c7a703          	lw	a4,-212(a5)
ffffffffc02050c4:	00870b63          	beq	a4,s0,ffffffffc02050da <do_kill+0x4c>
ffffffffc02050c8:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02050ca:	fef51be3          	bne	a0,a5,ffffffffc02050c0 <do_kill+0x32>
    return -E_INVAL;
ffffffffc02050ce:	5475                	li	s0,-3
}
ffffffffc02050d0:	60a2                	ld	ra,8(sp)
ffffffffc02050d2:	8522                	mv	a0,s0
ffffffffc02050d4:	6402                	ld	s0,0(sp)
ffffffffc02050d6:	0141                	addi	sp,sp,16
ffffffffc02050d8:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc02050da:	fd87a703          	lw	a4,-40(a5)
ffffffffc02050de:	00177693          	andi	a3,a4,1
ffffffffc02050e2:	e295                	bnez	a3,ffffffffc0205106 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc02050e4:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc02050e6:	00176713          	ori	a4,a4,1
ffffffffc02050ea:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc02050ee:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc02050f0:	fe06d0e3          	bgez	a3,ffffffffc02050d0 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc02050f4:	f2878513          	addi	a0,a5,-216
ffffffffc02050f8:	22e000ef          	jal	ra,ffffffffc0205326 <wakeup_proc>
}
ffffffffc02050fc:	60a2                	ld	ra,8(sp)
ffffffffc02050fe:	8522                	mv	a0,s0
ffffffffc0205100:	6402                	ld	s0,0(sp)
ffffffffc0205102:	0141                	addi	sp,sp,16
ffffffffc0205104:	8082                	ret
        return -E_KILLED;
ffffffffc0205106:	545d                	li	s0,-9
ffffffffc0205108:	b7e1                	j	ffffffffc02050d0 <do_kill+0x42>

ffffffffc020510a <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc020510a:	1101                	addi	sp,sp,-32
ffffffffc020510c:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc020510e:	000c5797          	auipc	a5,0xc5
ffffffffc0205112:	c9278793          	addi	a5,a5,-878 # ffffffffc02c9da0 <proc_list>
ffffffffc0205116:	ec06                	sd	ra,24(sp)
ffffffffc0205118:	e822                	sd	s0,16(sp)
ffffffffc020511a:	e04a                	sd	s2,0(sp)
ffffffffc020511c:	000c1497          	auipc	s1,0xc1
ffffffffc0205120:	c8448493          	addi	s1,s1,-892 # ffffffffc02c5da0 <hash_list>
ffffffffc0205124:	e79c                	sd	a5,8(a5)
ffffffffc0205126:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0205128:	000c5717          	auipc	a4,0xc5
ffffffffc020512c:	c7870713          	addi	a4,a4,-904 # ffffffffc02c9da0 <proc_list>
ffffffffc0205130:	87a6                	mv	a5,s1
ffffffffc0205132:	e79c                	sd	a5,8(a5)
ffffffffc0205134:	e39c                	sd	a5,0(a5)
ffffffffc0205136:	07c1                	addi	a5,a5,16
ffffffffc0205138:	fef71de3          	bne	a4,a5,ffffffffc0205132 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc020513c:	f79fe0ef          	jal	ra,ffffffffc02040b4 <alloc_proc>
ffffffffc0205140:	000c5917          	auipc	s2,0xc5
ffffffffc0205144:	ce090913          	addi	s2,s2,-800 # ffffffffc02c9e20 <idleproc>
ffffffffc0205148:	00a93023          	sd	a0,0(s2)
ffffffffc020514c:	0e050f63          	beqz	a0,ffffffffc020524a <proc_init+0x140>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205150:	4789                	li	a5,2
ffffffffc0205152:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205154:	00003797          	auipc	a5,0x3
ffffffffc0205158:	eac78793          	addi	a5,a5,-340 # ffffffffc0208000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020515c:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205160:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205162:	4785                	li	a5,1
ffffffffc0205164:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205166:	4641                	li	a2,16
ffffffffc0205168:	4581                	li	a1,0
ffffffffc020516a:	8522                	mv	a0,s0
ffffffffc020516c:	067000ef          	jal	ra,ffffffffc02059d2 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205170:	463d                	li	a2,15
ffffffffc0205172:	00002597          	auipc	a1,0x2
ffffffffc0205176:	4f658593          	addi	a1,a1,1270 # ffffffffc0207668 <default_pmm_manager+0xdf8>
ffffffffc020517a:	8522                	mv	a0,s0
ffffffffc020517c:	069000ef          	jal	ra,ffffffffc02059e4 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc0205180:	000c5717          	auipc	a4,0xc5
ffffffffc0205184:	cb070713          	addi	a4,a4,-848 # ffffffffc02c9e30 <nr_process>
ffffffffc0205188:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc020518a:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020518e:	4601                	li	a2,0
    nr_process++;
ffffffffc0205190:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205192:	4581                	li	a1,0
ffffffffc0205194:	00000517          	auipc	a0,0x0
ffffffffc0205198:	87450513          	addi	a0,a0,-1932 # ffffffffc0204a08 <init_main>
    nr_process++;
ffffffffc020519c:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc020519e:	000c5797          	auipc	a5,0xc5
ffffffffc02051a2:	c6d7bd23          	sd	a3,-902(a5) # ffffffffc02c9e18 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02051a6:	cf6ff0ef          	jal	ra,ffffffffc020469c <kernel_thread>
ffffffffc02051aa:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc02051ac:	08a05363          	blez	a0,ffffffffc0205232 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID)
ffffffffc02051b0:	6789                	lui	a5,0x2
ffffffffc02051b2:	fff5071b          	addiw	a4,a0,-1
ffffffffc02051b6:	17f9                	addi	a5,a5,-2
ffffffffc02051b8:	2501                	sext.w	a0,a0
ffffffffc02051ba:	02e7e363          	bltu	a5,a4,ffffffffc02051e0 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02051be:	45a9                	li	a1,10
ffffffffc02051c0:	36c000ef          	jal	ra,ffffffffc020552c <hash32>
ffffffffc02051c4:	02051793          	slli	a5,a0,0x20
ffffffffc02051c8:	01c7d693          	srli	a3,a5,0x1c
ffffffffc02051cc:	96a6                	add	a3,a3,s1
ffffffffc02051ce:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc02051d0:	a029                	j	ffffffffc02051da <proc_init+0xd0>
            if (proc->pid == pid)
ffffffffc02051d2:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7d24>
ffffffffc02051d6:	04870b63          	beq	a4,s0,ffffffffc020522c <proc_init+0x122>
    return listelm->next;
ffffffffc02051da:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02051dc:	fef69be3          	bne	a3,a5,ffffffffc02051d2 <proc_init+0xc8>
    return NULL;
ffffffffc02051e0:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02051e2:	0b478493          	addi	s1,a5,180
ffffffffc02051e6:	4641                	li	a2,16
ffffffffc02051e8:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc02051ea:	000c5417          	auipc	s0,0xc5
ffffffffc02051ee:	c3e40413          	addi	s0,s0,-962 # ffffffffc02c9e28 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02051f2:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc02051f4:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02051f6:	7dc000ef          	jal	ra,ffffffffc02059d2 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02051fa:	463d                	li	a2,15
ffffffffc02051fc:	00002597          	auipc	a1,0x2
ffffffffc0205200:	49458593          	addi	a1,a1,1172 # ffffffffc0207690 <default_pmm_manager+0xe20>
ffffffffc0205204:	8526                	mv	a0,s1
ffffffffc0205206:	7de000ef          	jal	ra,ffffffffc02059e4 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020520a:	00093783          	ld	a5,0(s2)
ffffffffc020520e:	cbb5                	beqz	a5,ffffffffc0205282 <proc_init+0x178>
ffffffffc0205210:	43dc                	lw	a5,4(a5)
ffffffffc0205212:	eba5                	bnez	a5,ffffffffc0205282 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205214:	601c                	ld	a5,0(s0)
ffffffffc0205216:	c7b1                	beqz	a5,ffffffffc0205262 <proc_init+0x158>
ffffffffc0205218:	43d8                	lw	a4,4(a5)
ffffffffc020521a:	4785                	li	a5,1
ffffffffc020521c:	04f71363          	bne	a4,a5,ffffffffc0205262 <proc_init+0x158>
}
ffffffffc0205220:	60e2                	ld	ra,24(sp)
ffffffffc0205222:	6442                	ld	s0,16(sp)
ffffffffc0205224:	64a2                	ld	s1,8(sp)
ffffffffc0205226:	6902                	ld	s2,0(sp)
ffffffffc0205228:	6105                	addi	sp,sp,32
ffffffffc020522a:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020522c:	f2878793          	addi	a5,a5,-216
ffffffffc0205230:	bf4d                	j	ffffffffc02051e2 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205232:	00002617          	auipc	a2,0x2
ffffffffc0205236:	43e60613          	addi	a2,a2,1086 # ffffffffc0207670 <default_pmm_manager+0xe00>
ffffffffc020523a:	41200593          	li	a1,1042
ffffffffc020523e:	00002517          	auipc	a0,0x2
ffffffffc0205242:	0a250513          	addi	a0,a0,162 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc0205246:	a48fb0ef          	jal	ra,ffffffffc020048e <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc020524a:	00002617          	auipc	a2,0x2
ffffffffc020524e:	40660613          	addi	a2,a2,1030 # ffffffffc0207650 <default_pmm_manager+0xde0>
ffffffffc0205252:	40300593          	li	a1,1027
ffffffffc0205256:	00002517          	auipc	a0,0x2
ffffffffc020525a:	08a50513          	addi	a0,a0,138 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc020525e:	a30fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205262:	00002697          	auipc	a3,0x2
ffffffffc0205266:	45e68693          	addi	a3,a3,1118 # ffffffffc02076c0 <default_pmm_manager+0xe50>
ffffffffc020526a:	00001617          	auipc	a2,0x1
ffffffffc020526e:	25660613          	addi	a2,a2,598 # ffffffffc02064c0 <commands+0x858>
ffffffffc0205272:	41900593          	li	a1,1049
ffffffffc0205276:	00002517          	auipc	a0,0x2
ffffffffc020527a:	06a50513          	addi	a0,a0,106 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc020527e:	a10fb0ef          	jal	ra,ffffffffc020048e <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205282:	00002697          	auipc	a3,0x2
ffffffffc0205286:	41668693          	addi	a3,a3,1046 # ffffffffc0207698 <default_pmm_manager+0xe28>
ffffffffc020528a:	00001617          	auipc	a2,0x1
ffffffffc020528e:	23660613          	addi	a2,a2,566 # ffffffffc02064c0 <commands+0x858>
ffffffffc0205292:	41800593          	li	a1,1048
ffffffffc0205296:	00002517          	auipc	a0,0x2
ffffffffc020529a:	04a50513          	addi	a0,a0,74 # ffffffffc02072e0 <default_pmm_manager+0xa70>
ffffffffc020529e:	9f0fb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02052a2 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc02052a2:	1141                	addi	sp,sp,-16
ffffffffc02052a4:	e022                	sd	s0,0(sp)
ffffffffc02052a6:	e406                	sd	ra,8(sp)
ffffffffc02052a8:	000c5417          	auipc	s0,0xc5
ffffffffc02052ac:	b7040413          	addi	s0,s0,-1168 # ffffffffc02c9e18 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc02052b0:	6018                	ld	a4,0(s0)
ffffffffc02052b2:	6f1c                	ld	a5,24(a4)
ffffffffc02052b4:	dffd                	beqz	a5,ffffffffc02052b2 <cpu_idle+0x10>
        {
            schedule();
ffffffffc02052b6:	0f0000ef          	jal	ra,ffffffffc02053a6 <schedule>
ffffffffc02052ba:	bfdd                	j	ffffffffc02052b0 <cpu_idle+0xe>

ffffffffc02052bc <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc02052bc:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc02052c0:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02052c4:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02052c6:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02052c8:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02052cc:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02052d0:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02052d4:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02052d8:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02052dc:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02052e0:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02052e4:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02052e8:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02052ec:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02052f0:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02052f4:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02052f8:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02052fa:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02052fc:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205300:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205304:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205308:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc020530c:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205310:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205314:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205318:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc020531c:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205320:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205324:	8082                	ret

ffffffffc0205326 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205326:	4118                	lw	a4,0(a0)
{
ffffffffc0205328:	1101                	addi	sp,sp,-32
ffffffffc020532a:	ec06                	sd	ra,24(sp)
ffffffffc020532c:	e822                	sd	s0,16(sp)
ffffffffc020532e:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205330:	478d                	li	a5,3
ffffffffc0205332:	04f70b63          	beq	a4,a5,ffffffffc0205388 <wakeup_proc+0x62>
ffffffffc0205336:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205338:	100027f3          	csrr	a5,sstatus
ffffffffc020533c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020533e:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205340:	ef9d                	bnez	a5,ffffffffc020537e <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205342:	4789                	li	a5,2
ffffffffc0205344:	02f70163          	beq	a4,a5,ffffffffc0205366 <wakeup_proc+0x40>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc0205348:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc020534a:	0e042623          	sw	zero,236(s0)
    if (flag)
ffffffffc020534e:	e491                	bnez	s1,ffffffffc020535a <wakeup_proc+0x34>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205350:	60e2                	ld	ra,24(sp)
ffffffffc0205352:	6442                	ld	s0,16(sp)
ffffffffc0205354:	64a2                	ld	s1,8(sp)
ffffffffc0205356:	6105                	addi	sp,sp,32
ffffffffc0205358:	8082                	ret
ffffffffc020535a:	6442                	ld	s0,16(sp)
ffffffffc020535c:	60e2                	ld	ra,24(sp)
ffffffffc020535e:	64a2                	ld	s1,8(sp)
ffffffffc0205360:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205362:	e4cfb06f          	j	ffffffffc02009ae <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205366:	00002617          	auipc	a2,0x2
ffffffffc020536a:	3ba60613          	addi	a2,a2,954 # ffffffffc0207720 <default_pmm_manager+0xeb0>
ffffffffc020536e:	45d1                	li	a1,20
ffffffffc0205370:	00002517          	auipc	a0,0x2
ffffffffc0205374:	39850513          	addi	a0,a0,920 # ffffffffc0207708 <default_pmm_manager+0xe98>
ffffffffc0205378:	97efb0ef          	jal	ra,ffffffffc02004f6 <__warn>
ffffffffc020537c:	bfc9                	j	ffffffffc020534e <wakeup_proc+0x28>
        intr_disable();
ffffffffc020537e:	e36fb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205382:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205384:	4485                	li	s1,1
ffffffffc0205386:	bf75                	j	ffffffffc0205342 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205388:	00002697          	auipc	a3,0x2
ffffffffc020538c:	36068693          	addi	a3,a3,864 # ffffffffc02076e8 <default_pmm_manager+0xe78>
ffffffffc0205390:	00001617          	auipc	a2,0x1
ffffffffc0205394:	13060613          	addi	a2,a2,304 # ffffffffc02064c0 <commands+0x858>
ffffffffc0205398:	45a5                	li	a1,9
ffffffffc020539a:	00002517          	auipc	a0,0x2
ffffffffc020539e:	36e50513          	addi	a0,a0,878 # ffffffffc0207708 <default_pmm_manager+0xe98>
ffffffffc02053a2:	8ecfb0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc02053a6 <schedule>:

void schedule(void)
{
ffffffffc02053a6:	1141                	addi	sp,sp,-16
ffffffffc02053a8:	e406                	sd	ra,8(sp)
ffffffffc02053aa:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02053ac:	100027f3          	csrr	a5,sstatus
ffffffffc02053b0:	8b89                	andi	a5,a5,2
ffffffffc02053b2:	4401                	li	s0,0
ffffffffc02053b4:	e3d9                	bnez	a5,ffffffffc020543a <schedule+0x94>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02053b6:	000c5897          	auipc	a7,0xc5
ffffffffc02053ba:	a628b883          	ld	a7,-1438(a7) # ffffffffc02c9e18 <current>
ffffffffc02053be:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02053c2:	000c5517          	auipc	a0,0xc5
ffffffffc02053c6:	a5e53503          	ld	a0,-1442(a0) # ffffffffc02c9e20 <idleproc>
ffffffffc02053ca:	06a88263          	beq	a7,a0,ffffffffc020542e <schedule+0x88>
ffffffffc02053ce:	0c888693          	addi	a3,a7,200
ffffffffc02053d2:	000c5617          	auipc	a2,0xc5
ffffffffc02053d6:	9ce60613          	addi	a2,a2,-1586 # ffffffffc02c9da0 <proc_list>
        le = last;
ffffffffc02053da:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02053dc:	4581                	li	a1,0
        do
        {
            if ((le = list_next(le)) != &proc_list)
            {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE)
ffffffffc02053de:	4809                	li	a6,2
ffffffffc02053e0:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)
ffffffffc02053e2:	00c78863          	beq	a5,a2,ffffffffc02053f2 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE)
ffffffffc02053e6:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02053ea:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)
ffffffffc02053ee:	03070163          	beq	a4,a6,ffffffffc0205410 <schedule+0x6a>
                         next->time_slice = 3;
                    }
                    break;
                }
            }
        } while (le != last);
ffffffffc02053f2:	fef697e3          	bne	a3,a5,ffffffffc02053e0 <schedule+0x3a>
        
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc02053f6:	e18d                	bnez	a1,ffffffffc0205418 <schedule+0x72>
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc02053f8:	451c                	lw	a5,8(a0)
ffffffffc02053fa:	2785                	addiw	a5,a5,1
ffffffffc02053fc:	c51c                	sw	a5,8(a0)
        if (next != current)
ffffffffc02053fe:	00a88463          	beq	a7,a0,ffffffffc0205406 <schedule+0x60>
        {
            proc_run(next);
ffffffffc0205402:	e2bfe0ef          	jal	ra,ffffffffc020422c <proc_run>
    if (flag)
ffffffffc0205406:	ec19                	bnez	s0,ffffffffc0205424 <schedule+0x7e>
        }
    }
    local_intr_restore(intr_flag);
ffffffffc0205408:	60a2                	ld	ra,8(sp)
ffffffffc020540a:	6402                	ld	s0,0(sp)
ffffffffc020540c:	0141                	addi	sp,sp,16
ffffffffc020540e:	8082                	ret
                    if (next->time_slice == 0) {
ffffffffc0205410:	43b8                	lw	a4,64(a5)
ffffffffc0205412:	e319                	bnez	a4,ffffffffc0205418 <schedule+0x72>
                         next->time_slice = 3;
ffffffffc0205414:	470d                	li	a4,3
ffffffffc0205416:	c3b8                	sw	a4,64(a5)
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0205418:	4198                	lw	a4,0(a1)
ffffffffc020541a:	4789                	li	a5,2
ffffffffc020541c:	fcf71ee3          	bne	a4,a5,ffffffffc02053f8 <schedule+0x52>
ffffffffc0205420:	852e                	mv	a0,a1
ffffffffc0205422:	bfd9                	j	ffffffffc02053f8 <schedule+0x52>
ffffffffc0205424:	6402                	ld	s0,0(sp)
ffffffffc0205426:	60a2                	ld	ra,8(sp)
ffffffffc0205428:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020542a:	d84fb06f          	j	ffffffffc02009ae <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020542e:	000c5617          	auipc	a2,0xc5
ffffffffc0205432:	97260613          	addi	a2,a2,-1678 # ffffffffc02c9da0 <proc_list>
ffffffffc0205436:	86b2                	mv	a3,a2
ffffffffc0205438:	b74d                	j	ffffffffc02053da <schedule+0x34>
        intr_disable();
ffffffffc020543a:	d7afb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc020543e:	4405                	li	s0,1
ffffffffc0205440:	bf9d                	j	ffffffffc02053b6 <schedule+0x10>

ffffffffc0205442 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205442:	000c5797          	auipc	a5,0xc5
ffffffffc0205446:	9d67b783          	ld	a5,-1578(a5) # ffffffffc02c9e18 <current>
}
ffffffffc020544a:	43c8                	lw	a0,4(a5)
ffffffffc020544c:	8082                	ret

ffffffffc020544e <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc020544e:	4501                	li	a0,0
ffffffffc0205450:	8082                	ret

ffffffffc0205452 <sys_get_free_pages>:

static int
sys_get_free_pages(uint64_t arg[]) {
ffffffffc0205452:	1141                	addi	sp,sp,-16
ffffffffc0205454:	e406                	sd	ra,8(sp)
    // 调用 pmm.h 中声明的内核函数，获取当前空闲页数
    return (int)nr_free_pages();
ffffffffc0205456:	b7dfc0ef          	jal	ra,ffffffffc0201fd2 <nr_free_pages>
}
ffffffffc020545a:	60a2                	ld	ra,8(sp)
ffffffffc020545c:	2501                	sext.w	a0,a0
ffffffffc020545e:	0141                	addi	sp,sp,16
ffffffffc0205460:	8082                	ret

ffffffffc0205462 <sys_putc>:
    cputchar(c);
ffffffffc0205462:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205464:	1141                	addi	sp,sp,-16
ffffffffc0205466:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205468:	d63fa0ef          	jal	ra,ffffffffc02001ca <cputchar>
}
ffffffffc020546c:	60a2                	ld	ra,8(sp)
ffffffffc020546e:	4501                	li	a0,0
ffffffffc0205470:	0141                	addi	sp,sp,16
ffffffffc0205472:	8082                	ret

ffffffffc0205474 <sys_kill>:
    return do_kill(pid);
ffffffffc0205474:	4108                	lw	a0,0(a0)
ffffffffc0205476:	c19ff06f          	j	ffffffffc020508e <do_kill>

ffffffffc020547a <sys_yield>:
    return do_yield();
ffffffffc020547a:	bc7ff06f          	j	ffffffffc0205040 <do_yield>

ffffffffc020547e <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc020547e:	6d14                	ld	a3,24(a0)
ffffffffc0205480:	6910                	ld	a2,16(a0)
ffffffffc0205482:	650c                	ld	a1,8(a0)
ffffffffc0205484:	6108                	ld	a0,0(a0)
ffffffffc0205486:	ea6ff06f          	j	ffffffffc0204b2c <do_execve>

ffffffffc020548a <sys_wait>:
    return do_wait(pid, store);
ffffffffc020548a:	650c                	ld	a1,8(a0)
ffffffffc020548c:	4108                	lw	a0,0(a0)
ffffffffc020548e:	bc3ff06f          	j	ffffffffc0205050 <do_wait>

ffffffffc0205492 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205492:	000c5797          	auipc	a5,0xc5
ffffffffc0205496:	9867b783          	ld	a5,-1658(a5) # ffffffffc02c9e18 <current>
ffffffffc020549a:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc020549c:	4501                	li	a0,0
ffffffffc020549e:	6a0c                	ld	a1,16(a2)
ffffffffc02054a0:	df9fe06f          	j	ffffffffc0204298 <do_fork>

ffffffffc02054a4 <sys_exit>:
    return do_exit(error_code);
ffffffffc02054a4:	4108                	lw	a0,0(a0)
ffffffffc02054a6:	a46ff06f          	j	ffffffffc02046ec <do_exit>

ffffffffc02054aa <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02054aa:	715d                	addi	sp,sp,-80
ffffffffc02054ac:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02054ae:	000c5497          	auipc	s1,0xc5
ffffffffc02054b2:	96a48493          	addi	s1,s1,-1686 # ffffffffc02c9e18 <current>
ffffffffc02054b6:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02054b8:	e0a2                	sd	s0,64(sp)
ffffffffc02054ba:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02054bc:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02054be:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02054c0:	02000793          	li	a5,32
    int num = tf->gpr.a0;
ffffffffc02054c4:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02054c8:	0327ee63          	bltu	a5,s2,ffffffffc0205504 <syscall+0x5a>
        if (syscalls[num] != NULL) {
ffffffffc02054cc:	00391713          	slli	a4,s2,0x3
ffffffffc02054d0:	00002797          	auipc	a5,0x2
ffffffffc02054d4:	2b878793          	addi	a5,a5,696 # ffffffffc0207788 <syscalls>
ffffffffc02054d8:	97ba                	add	a5,a5,a4
ffffffffc02054da:	639c                	ld	a5,0(a5)
ffffffffc02054dc:	c785                	beqz	a5,ffffffffc0205504 <syscall+0x5a>
            arg[0] = tf->gpr.a1;
ffffffffc02054de:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02054e0:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02054e2:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02054e4:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02054e6:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02054e8:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02054ea:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02054ec:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02054ee:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02054f0:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02054f2:	0028                	addi	a0,sp,8
ffffffffc02054f4:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02054f6:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02054f8:	e828                	sd	a0,80(s0)
}
ffffffffc02054fa:	6406                	ld	s0,64(sp)
ffffffffc02054fc:	74e2                	ld	s1,56(sp)
ffffffffc02054fe:	7942                	ld	s2,48(sp)
ffffffffc0205500:	6161                	addi	sp,sp,80
ffffffffc0205502:	8082                	ret
    print_trapframe(tf);
ffffffffc0205504:	8522                	mv	a0,s0
ffffffffc0205506:	e9efb0ef          	jal	ra,ffffffffc0200ba4 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc020550a:	609c                	ld	a5,0(s1)
ffffffffc020550c:	86ca                	mv	a3,s2
ffffffffc020550e:	00002617          	auipc	a2,0x2
ffffffffc0205512:	23260613          	addi	a2,a2,562 # ffffffffc0207740 <default_pmm_manager+0xed0>
ffffffffc0205516:	43d8                	lw	a4,4(a5)
ffffffffc0205518:	06900593          	li	a1,105
ffffffffc020551c:	0b478793          	addi	a5,a5,180
ffffffffc0205520:	00002517          	auipc	a0,0x2
ffffffffc0205524:	25050513          	addi	a0,a0,592 # ffffffffc0207770 <default_pmm_manager+0xf00>
ffffffffc0205528:	f67fa0ef          	jal	ra,ffffffffc020048e <__panic>

ffffffffc020552c <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020552c:	9e3707b7          	lui	a5,0x9e370
ffffffffc0205530:	2785                	addiw	a5,a5,1
ffffffffc0205532:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0205536:	02000793          	li	a5,32
ffffffffc020553a:	9f8d                	subw	a5,a5,a1
}
ffffffffc020553c:	00f5553b          	srlw	a0,a0,a5
ffffffffc0205540:	8082                	ret

ffffffffc0205542 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0205542:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205546:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0205548:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020554c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020554e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205552:	f022                	sd	s0,32(sp)
ffffffffc0205554:	ec26                	sd	s1,24(sp)
ffffffffc0205556:	e84a                	sd	s2,16(sp)
ffffffffc0205558:	f406                	sd	ra,40(sp)
ffffffffc020555a:	e44e                	sd	s3,8(sp)
ffffffffc020555c:	84aa                	mv	s1,a0
ffffffffc020555e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0205560:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0205564:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0205566:	03067e63          	bgeu	a2,a6,ffffffffc02055a2 <printnum+0x60>
ffffffffc020556a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020556c:	00805763          	blez	s0,ffffffffc020557a <printnum+0x38>
ffffffffc0205570:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0205572:	85ca                	mv	a1,s2
ffffffffc0205574:	854e                	mv	a0,s3
ffffffffc0205576:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0205578:	fc65                	bnez	s0,ffffffffc0205570 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020557a:	1a02                	slli	s4,s4,0x20
ffffffffc020557c:	00002797          	auipc	a5,0x2
ffffffffc0205580:	31478793          	addi	a5,a5,788 # ffffffffc0207890 <syscalls+0x108>
ffffffffc0205584:	020a5a13          	srli	s4,s4,0x20
ffffffffc0205588:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020558a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020558c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0205590:	70a2                	ld	ra,40(sp)
ffffffffc0205592:	69a2                	ld	s3,8(sp)
ffffffffc0205594:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205596:	85ca                	mv	a1,s2
ffffffffc0205598:	87a6                	mv	a5,s1
}
ffffffffc020559a:	6942                	ld	s2,16(sp)
ffffffffc020559c:	64e2                	ld	s1,24(sp)
ffffffffc020559e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02055a0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02055a2:	03065633          	divu	a2,a2,a6
ffffffffc02055a6:	8722                	mv	a4,s0
ffffffffc02055a8:	f9bff0ef          	jal	ra,ffffffffc0205542 <printnum>
ffffffffc02055ac:	b7f9                	j	ffffffffc020557a <printnum+0x38>

ffffffffc02055ae <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02055ae:	7119                	addi	sp,sp,-128
ffffffffc02055b0:	f4a6                	sd	s1,104(sp)
ffffffffc02055b2:	f0ca                	sd	s2,96(sp)
ffffffffc02055b4:	ecce                	sd	s3,88(sp)
ffffffffc02055b6:	e8d2                	sd	s4,80(sp)
ffffffffc02055b8:	e4d6                	sd	s5,72(sp)
ffffffffc02055ba:	e0da                	sd	s6,64(sp)
ffffffffc02055bc:	fc5e                	sd	s7,56(sp)
ffffffffc02055be:	f06a                	sd	s10,32(sp)
ffffffffc02055c0:	fc86                	sd	ra,120(sp)
ffffffffc02055c2:	f8a2                	sd	s0,112(sp)
ffffffffc02055c4:	f862                	sd	s8,48(sp)
ffffffffc02055c6:	f466                	sd	s9,40(sp)
ffffffffc02055c8:	ec6e                	sd	s11,24(sp)
ffffffffc02055ca:	892a                	mv	s2,a0
ffffffffc02055cc:	84ae                	mv	s1,a1
ffffffffc02055ce:	8d32                	mv	s10,a2
ffffffffc02055d0:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02055d2:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02055d6:	5b7d                	li	s6,-1
ffffffffc02055d8:	00002a97          	auipc	s5,0x2
ffffffffc02055dc:	2e4a8a93          	addi	s5,s5,740 # ffffffffc02078bc <syscalls+0x134>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02055e0:	00002b97          	auipc	s7,0x2
ffffffffc02055e4:	4f8b8b93          	addi	s7,s7,1272 # ffffffffc0207ad8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02055e8:	000d4503          	lbu	a0,0(s10)
ffffffffc02055ec:	001d0413          	addi	s0,s10,1
ffffffffc02055f0:	01350a63          	beq	a0,s3,ffffffffc0205604 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02055f4:	c121                	beqz	a0,ffffffffc0205634 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02055f6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02055f8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02055fa:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02055fc:	fff44503          	lbu	a0,-1(s0)
ffffffffc0205600:	ff351ae3          	bne	a0,s3,ffffffffc02055f4 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205604:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0205608:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020560c:	4c81                	li	s9,0
ffffffffc020560e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0205610:	5c7d                	li	s8,-1
ffffffffc0205612:	5dfd                	li	s11,-1
ffffffffc0205614:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0205618:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020561a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020561e:	0ff5f593          	zext.b	a1,a1
ffffffffc0205622:	00140d13          	addi	s10,s0,1
ffffffffc0205626:	04b56263          	bltu	a0,a1,ffffffffc020566a <vprintfmt+0xbc>
ffffffffc020562a:	058a                	slli	a1,a1,0x2
ffffffffc020562c:	95d6                	add	a1,a1,s5
ffffffffc020562e:	4194                	lw	a3,0(a1)
ffffffffc0205630:	96d6                	add	a3,a3,s5
ffffffffc0205632:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0205634:	70e6                	ld	ra,120(sp)
ffffffffc0205636:	7446                	ld	s0,112(sp)
ffffffffc0205638:	74a6                	ld	s1,104(sp)
ffffffffc020563a:	7906                	ld	s2,96(sp)
ffffffffc020563c:	69e6                	ld	s3,88(sp)
ffffffffc020563e:	6a46                	ld	s4,80(sp)
ffffffffc0205640:	6aa6                	ld	s5,72(sp)
ffffffffc0205642:	6b06                	ld	s6,64(sp)
ffffffffc0205644:	7be2                	ld	s7,56(sp)
ffffffffc0205646:	7c42                	ld	s8,48(sp)
ffffffffc0205648:	7ca2                	ld	s9,40(sp)
ffffffffc020564a:	7d02                	ld	s10,32(sp)
ffffffffc020564c:	6de2                	ld	s11,24(sp)
ffffffffc020564e:	6109                	addi	sp,sp,128
ffffffffc0205650:	8082                	ret
            padc = '0';
ffffffffc0205652:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0205654:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205658:	846a                	mv	s0,s10
ffffffffc020565a:	00140d13          	addi	s10,s0,1
ffffffffc020565e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0205662:	0ff5f593          	zext.b	a1,a1
ffffffffc0205666:	fcb572e3          	bgeu	a0,a1,ffffffffc020562a <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020566a:	85a6                	mv	a1,s1
ffffffffc020566c:	02500513          	li	a0,37
ffffffffc0205670:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0205672:	fff44783          	lbu	a5,-1(s0)
ffffffffc0205676:	8d22                	mv	s10,s0
ffffffffc0205678:	f73788e3          	beq	a5,s3,ffffffffc02055e8 <vprintfmt+0x3a>
ffffffffc020567c:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0205680:	1d7d                	addi	s10,s10,-1
ffffffffc0205682:	ff379de3          	bne	a5,s3,ffffffffc020567c <vprintfmt+0xce>
ffffffffc0205686:	b78d                	j	ffffffffc02055e8 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0205688:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020568c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205690:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0205692:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0205696:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020569a:	02d86463          	bltu	a6,a3,ffffffffc02056c2 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020569e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02056a2:	002c169b          	slliw	a3,s8,0x2
ffffffffc02056a6:	0186873b          	addw	a4,a3,s8
ffffffffc02056aa:	0017171b          	slliw	a4,a4,0x1
ffffffffc02056ae:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02056b0:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02056b4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02056b6:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02056ba:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02056be:	fed870e3          	bgeu	a6,a3,ffffffffc020569e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02056c2:	f40ddce3          	bgez	s11,ffffffffc020561a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02056c6:	8de2                	mv	s11,s8
ffffffffc02056c8:	5c7d                	li	s8,-1
ffffffffc02056ca:	bf81                	j	ffffffffc020561a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02056cc:	fffdc693          	not	a3,s11
ffffffffc02056d0:	96fd                	srai	a3,a3,0x3f
ffffffffc02056d2:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056d6:	00144603          	lbu	a2,1(s0)
ffffffffc02056da:	2d81                	sext.w	s11,s11
ffffffffc02056dc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02056de:	bf35                	j	ffffffffc020561a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02056e0:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056e4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02056e8:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056ea:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02056ec:	bfd9                	j	ffffffffc02056c2 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02056ee:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02056f0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02056f4:	01174463          	blt	a4,a7,ffffffffc02056fc <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02056f8:	1a088e63          	beqz	a7,ffffffffc02058b4 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02056fc:	000a3603          	ld	a2,0(s4)
ffffffffc0205700:	46c1                	li	a3,16
ffffffffc0205702:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0205704:	2781                	sext.w	a5,a5
ffffffffc0205706:	876e                	mv	a4,s11
ffffffffc0205708:	85a6                	mv	a1,s1
ffffffffc020570a:	854a                	mv	a0,s2
ffffffffc020570c:	e37ff0ef          	jal	ra,ffffffffc0205542 <printnum>
            break;
ffffffffc0205710:	bde1                	j	ffffffffc02055e8 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0205712:	000a2503          	lw	a0,0(s4)
ffffffffc0205716:	85a6                	mv	a1,s1
ffffffffc0205718:	0a21                	addi	s4,s4,8
ffffffffc020571a:	9902                	jalr	s2
            break;
ffffffffc020571c:	b5f1                	j	ffffffffc02055e8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020571e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205720:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205724:	01174463          	blt	a4,a7,ffffffffc020572c <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0205728:	18088163          	beqz	a7,ffffffffc02058aa <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020572c:	000a3603          	ld	a2,0(s4)
ffffffffc0205730:	46a9                	li	a3,10
ffffffffc0205732:	8a2e                	mv	s4,a1
ffffffffc0205734:	bfc1                	j	ffffffffc0205704 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205736:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020573a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020573c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020573e:	bdf1                	j	ffffffffc020561a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0205740:	85a6                	mv	a1,s1
ffffffffc0205742:	02500513          	li	a0,37
ffffffffc0205746:	9902                	jalr	s2
            break;
ffffffffc0205748:	b545                	j	ffffffffc02055e8 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020574a:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020574e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205750:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205752:	b5e1                	j	ffffffffc020561a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0205754:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205756:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020575a:	01174463          	blt	a4,a7,ffffffffc0205762 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020575e:	14088163          	beqz	a7,ffffffffc02058a0 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0205762:	000a3603          	ld	a2,0(s4)
ffffffffc0205766:	46a1                	li	a3,8
ffffffffc0205768:	8a2e                	mv	s4,a1
ffffffffc020576a:	bf69                	j	ffffffffc0205704 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020576c:	03000513          	li	a0,48
ffffffffc0205770:	85a6                	mv	a1,s1
ffffffffc0205772:	e03e                	sd	a5,0(sp)
ffffffffc0205774:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0205776:	85a6                	mv	a1,s1
ffffffffc0205778:	07800513          	li	a0,120
ffffffffc020577c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020577e:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0205780:	6782                	ld	a5,0(sp)
ffffffffc0205782:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205784:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0205788:	bfb5                	j	ffffffffc0205704 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020578a:	000a3403          	ld	s0,0(s4)
ffffffffc020578e:	008a0713          	addi	a4,s4,8
ffffffffc0205792:	e03a                	sd	a4,0(sp)
ffffffffc0205794:	14040263          	beqz	s0,ffffffffc02058d8 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0205798:	0fb05763          	blez	s11,ffffffffc0205886 <vprintfmt+0x2d8>
ffffffffc020579c:	02d00693          	li	a3,45
ffffffffc02057a0:	0cd79163          	bne	a5,a3,ffffffffc0205862 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02057a4:	00044783          	lbu	a5,0(s0)
ffffffffc02057a8:	0007851b          	sext.w	a0,a5
ffffffffc02057ac:	cf85                	beqz	a5,ffffffffc02057e4 <vprintfmt+0x236>
ffffffffc02057ae:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02057b2:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02057b6:	000c4563          	bltz	s8,ffffffffc02057c0 <vprintfmt+0x212>
ffffffffc02057ba:	3c7d                	addiw	s8,s8,-1
ffffffffc02057bc:	036c0263          	beq	s8,s6,ffffffffc02057e0 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02057c0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02057c2:	0e0c8e63          	beqz	s9,ffffffffc02058be <vprintfmt+0x310>
ffffffffc02057c6:	3781                	addiw	a5,a5,-32
ffffffffc02057c8:	0ef47b63          	bgeu	s0,a5,ffffffffc02058be <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02057cc:	03f00513          	li	a0,63
ffffffffc02057d0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02057d2:	000a4783          	lbu	a5,0(s4)
ffffffffc02057d6:	3dfd                	addiw	s11,s11,-1
ffffffffc02057d8:	0a05                	addi	s4,s4,1
ffffffffc02057da:	0007851b          	sext.w	a0,a5
ffffffffc02057de:	ffe1                	bnez	a5,ffffffffc02057b6 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02057e0:	01b05963          	blez	s11,ffffffffc02057f2 <vprintfmt+0x244>
ffffffffc02057e4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02057e6:	85a6                	mv	a1,s1
ffffffffc02057e8:	02000513          	li	a0,32
ffffffffc02057ec:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02057ee:	fe0d9be3          	bnez	s11,ffffffffc02057e4 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02057f2:	6a02                	ld	s4,0(sp)
ffffffffc02057f4:	bbd5                	j	ffffffffc02055e8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02057f6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02057f8:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02057fc:	01174463          	blt	a4,a7,ffffffffc0205804 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0205800:	08088d63          	beqz	a7,ffffffffc020589a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0205804:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0205808:	0a044d63          	bltz	s0,ffffffffc02058c2 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020580c:	8622                	mv	a2,s0
ffffffffc020580e:	8a66                	mv	s4,s9
ffffffffc0205810:	46a9                	li	a3,10
ffffffffc0205812:	bdcd                	j	ffffffffc0205704 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0205814:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205818:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc020581a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020581c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0205820:	8fb5                	xor	a5,a5,a3
ffffffffc0205822:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205826:	02d74163          	blt	a4,a3,ffffffffc0205848 <vprintfmt+0x29a>
ffffffffc020582a:	00369793          	slli	a5,a3,0x3
ffffffffc020582e:	97de                	add	a5,a5,s7
ffffffffc0205830:	639c                	ld	a5,0(a5)
ffffffffc0205832:	cb99                	beqz	a5,ffffffffc0205848 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0205834:	86be                	mv	a3,a5
ffffffffc0205836:	00000617          	auipc	a2,0x0
ffffffffc020583a:	1f260613          	addi	a2,a2,498 # ffffffffc0205a28 <etext+0x2c>
ffffffffc020583e:	85a6                	mv	a1,s1
ffffffffc0205840:	854a                	mv	a0,s2
ffffffffc0205842:	0ce000ef          	jal	ra,ffffffffc0205910 <printfmt>
ffffffffc0205846:	b34d                	j	ffffffffc02055e8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0205848:	00002617          	auipc	a2,0x2
ffffffffc020584c:	06860613          	addi	a2,a2,104 # ffffffffc02078b0 <syscalls+0x128>
ffffffffc0205850:	85a6                	mv	a1,s1
ffffffffc0205852:	854a                	mv	a0,s2
ffffffffc0205854:	0bc000ef          	jal	ra,ffffffffc0205910 <printfmt>
ffffffffc0205858:	bb41                	j	ffffffffc02055e8 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020585a:	00002417          	auipc	s0,0x2
ffffffffc020585e:	04e40413          	addi	s0,s0,78 # ffffffffc02078a8 <syscalls+0x120>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205862:	85e2                	mv	a1,s8
ffffffffc0205864:	8522                	mv	a0,s0
ffffffffc0205866:	e43e                	sd	a5,8(sp)
ffffffffc0205868:	0e2000ef          	jal	ra,ffffffffc020594a <strnlen>
ffffffffc020586c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0205870:	01b05b63          	blez	s11,ffffffffc0205886 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0205874:	67a2                	ld	a5,8(sp)
ffffffffc0205876:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020587a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020587c:	85a6                	mv	a1,s1
ffffffffc020587e:	8552                	mv	a0,s4
ffffffffc0205880:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205882:	fe0d9ce3          	bnez	s11,ffffffffc020587a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205886:	00044783          	lbu	a5,0(s0)
ffffffffc020588a:	00140a13          	addi	s4,s0,1
ffffffffc020588e:	0007851b          	sext.w	a0,a5
ffffffffc0205892:	d3a5                	beqz	a5,ffffffffc02057f2 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205894:	05e00413          	li	s0,94
ffffffffc0205898:	bf39                	j	ffffffffc02057b6 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020589a:	000a2403          	lw	s0,0(s4)
ffffffffc020589e:	b7ad                	j	ffffffffc0205808 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02058a0:	000a6603          	lwu	a2,0(s4)
ffffffffc02058a4:	46a1                	li	a3,8
ffffffffc02058a6:	8a2e                	mv	s4,a1
ffffffffc02058a8:	bdb1                	j	ffffffffc0205704 <vprintfmt+0x156>
ffffffffc02058aa:	000a6603          	lwu	a2,0(s4)
ffffffffc02058ae:	46a9                	li	a3,10
ffffffffc02058b0:	8a2e                	mv	s4,a1
ffffffffc02058b2:	bd89                	j	ffffffffc0205704 <vprintfmt+0x156>
ffffffffc02058b4:	000a6603          	lwu	a2,0(s4)
ffffffffc02058b8:	46c1                	li	a3,16
ffffffffc02058ba:	8a2e                	mv	s4,a1
ffffffffc02058bc:	b5a1                	j	ffffffffc0205704 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02058be:	9902                	jalr	s2
ffffffffc02058c0:	bf09                	j	ffffffffc02057d2 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02058c2:	85a6                	mv	a1,s1
ffffffffc02058c4:	02d00513          	li	a0,45
ffffffffc02058c8:	e03e                	sd	a5,0(sp)
ffffffffc02058ca:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02058cc:	6782                	ld	a5,0(sp)
ffffffffc02058ce:	8a66                	mv	s4,s9
ffffffffc02058d0:	40800633          	neg	a2,s0
ffffffffc02058d4:	46a9                	li	a3,10
ffffffffc02058d6:	b53d                	j	ffffffffc0205704 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02058d8:	03b05163          	blez	s11,ffffffffc02058fa <vprintfmt+0x34c>
ffffffffc02058dc:	02d00693          	li	a3,45
ffffffffc02058e0:	f6d79de3          	bne	a5,a3,ffffffffc020585a <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02058e4:	00002417          	auipc	s0,0x2
ffffffffc02058e8:	fc440413          	addi	s0,s0,-60 # ffffffffc02078a8 <syscalls+0x120>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02058ec:	02800793          	li	a5,40
ffffffffc02058f0:	02800513          	li	a0,40
ffffffffc02058f4:	00140a13          	addi	s4,s0,1
ffffffffc02058f8:	bd6d                	j	ffffffffc02057b2 <vprintfmt+0x204>
ffffffffc02058fa:	00002a17          	auipc	s4,0x2
ffffffffc02058fe:	fafa0a13          	addi	s4,s4,-81 # ffffffffc02078a9 <syscalls+0x121>
ffffffffc0205902:	02800513          	li	a0,40
ffffffffc0205906:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020590a:	05e00413          	li	s0,94
ffffffffc020590e:	b565                	j	ffffffffc02057b6 <vprintfmt+0x208>

ffffffffc0205910 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205910:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0205912:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205916:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205918:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020591a:	ec06                	sd	ra,24(sp)
ffffffffc020591c:	f83a                	sd	a4,48(sp)
ffffffffc020591e:	fc3e                	sd	a5,56(sp)
ffffffffc0205920:	e0c2                	sd	a6,64(sp)
ffffffffc0205922:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0205924:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205926:	c89ff0ef          	jal	ra,ffffffffc02055ae <vprintfmt>
}
ffffffffc020592a:	60e2                	ld	ra,24(sp)
ffffffffc020592c:	6161                	addi	sp,sp,80
ffffffffc020592e:	8082                	ret

ffffffffc0205930 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205930:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0205934:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0205936:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0205938:	cb81                	beqz	a5,ffffffffc0205948 <strlen+0x18>
        cnt ++;
ffffffffc020593a:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020593c:	00a707b3          	add	a5,a4,a0
ffffffffc0205940:	0007c783          	lbu	a5,0(a5)
ffffffffc0205944:	fbfd                	bnez	a5,ffffffffc020593a <strlen+0xa>
ffffffffc0205946:	8082                	ret
    }
    return cnt;
}
ffffffffc0205948:	8082                	ret

ffffffffc020594a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020594a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020594c:	e589                	bnez	a1,ffffffffc0205956 <strnlen+0xc>
ffffffffc020594e:	a811                	j	ffffffffc0205962 <strnlen+0x18>
        cnt ++;
ffffffffc0205950:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205952:	00f58863          	beq	a1,a5,ffffffffc0205962 <strnlen+0x18>
ffffffffc0205956:	00f50733          	add	a4,a0,a5
ffffffffc020595a:	00074703          	lbu	a4,0(a4)
ffffffffc020595e:	fb6d                	bnez	a4,ffffffffc0205950 <strnlen+0x6>
ffffffffc0205960:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205962:	852e                	mv	a0,a1
ffffffffc0205964:	8082                	ret

ffffffffc0205966 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205966:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205968:	0005c703          	lbu	a4,0(a1)
ffffffffc020596c:	0785                	addi	a5,a5,1
ffffffffc020596e:	0585                	addi	a1,a1,1
ffffffffc0205970:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205974:	fb75                	bnez	a4,ffffffffc0205968 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205976:	8082                	ret

ffffffffc0205978 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205978:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020597c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205980:	cb89                	beqz	a5,ffffffffc0205992 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0205982:	0505                	addi	a0,a0,1
ffffffffc0205984:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205986:	fee789e3          	beq	a5,a4,ffffffffc0205978 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020598a:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020598e:	9d19                	subw	a0,a0,a4
ffffffffc0205990:	8082                	ret
ffffffffc0205992:	4501                	li	a0,0
ffffffffc0205994:	bfed                	j	ffffffffc020598e <strcmp+0x16>

ffffffffc0205996 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205996:	c20d                	beqz	a2,ffffffffc02059b8 <strncmp+0x22>
ffffffffc0205998:	962e                	add	a2,a2,a1
ffffffffc020599a:	a031                	j	ffffffffc02059a6 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc020599c:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020599e:	00e79a63          	bne	a5,a4,ffffffffc02059b2 <strncmp+0x1c>
ffffffffc02059a2:	00b60b63          	beq	a2,a1,ffffffffc02059b8 <strncmp+0x22>
ffffffffc02059a6:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02059aa:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02059ac:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02059b0:	f7f5                	bnez	a5,ffffffffc020599c <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02059b2:	40e7853b          	subw	a0,a5,a4
}
ffffffffc02059b6:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02059b8:	4501                	li	a0,0
ffffffffc02059ba:	8082                	ret

ffffffffc02059bc <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02059bc:	00054783          	lbu	a5,0(a0)
ffffffffc02059c0:	c799                	beqz	a5,ffffffffc02059ce <strchr+0x12>
        if (*s == c) {
ffffffffc02059c2:	00f58763          	beq	a1,a5,ffffffffc02059d0 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02059c6:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02059ca:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02059cc:	fbfd                	bnez	a5,ffffffffc02059c2 <strchr+0x6>
    }
    return NULL;
ffffffffc02059ce:	4501                	li	a0,0
}
ffffffffc02059d0:	8082                	ret

ffffffffc02059d2 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02059d2:	ca01                	beqz	a2,ffffffffc02059e2 <memset+0x10>
ffffffffc02059d4:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02059d6:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02059d8:	0785                	addi	a5,a5,1
ffffffffc02059da:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02059de:	fec79de3          	bne	a5,a2,ffffffffc02059d8 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02059e2:	8082                	ret

ffffffffc02059e4 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02059e4:	ca19                	beqz	a2,ffffffffc02059fa <memcpy+0x16>
ffffffffc02059e6:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02059e8:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02059ea:	0005c703          	lbu	a4,0(a1)
ffffffffc02059ee:	0585                	addi	a1,a1,1
ffffffffc02059f0:	0785                	addi	a5,a5,1
ffffffffc02059f2:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02059f6:	fec59ae3          	bne	a1,a2,ffffffffc02059ea <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02059fa:	8082                	ret
