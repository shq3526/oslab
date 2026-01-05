
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	00014297          	auipc	t0,0x14
ffffffffc0200004:	00028293          	mv	t0,t0
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0214000 <boot_hartid>
ffffffffc020000c:	00014297          	auipc	t0,0x14
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0214008 <boot_dtb>
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
ffffffffc0200018:	c02132b7          	lui	t0,0xc0213
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
ffffffffc0200034:	18029073          	csrw	satp,t0
ffffffffc0200038:	12000073          	sfence.vma
ffffffffc020003c:	c0213137          	lui	sp,0xc0213
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
ffffffffc020004a:	00091517          	auipc	a0,0x91
ffffffffc020004e:	01650513          	addi	a0,a0,22 # ffffffffc0291060 <buf>
ffffffffc0200052:	00097617          	auipc	a2,0x97
ffffffffc0200056:	8be60613          	addi	a2,a2,-1858 # ffffffffc0296910 <end>
ffffffffc020005a:	1141                	addi	sp,sp,-16
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
ffffffffc0200060:	e406                	sd	ra,8(sp)
ffffffffc0200062:	1a30b0ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc0200066:	52c000ef          	jal	ra,ffffffffc0200592 <cons_init>
ffffffffc020006a:	0000c597          	auipc	a1,0xc
ffffffffc020006e:	a0658593          	addi	a1,a1,-1530 # ffffffffc020ba70 <etext+0x2>
ffffffffc0200072:	0000c517          	auipc	a0,0xc
ffffffffc0200076:	a1e50513          	addi	a0,a0,-1506 # ffffffffc020ba90 <etext+0x22>
ffffffffc020007a:	12c000ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc020007e:	1ae000ef          	jal	ra,ffffffffc020022c <print_kerninfo>
ffffffffc0200082:	62a000ef          	jal	ra,ffffffffc02006ac <dtb_init>
ffffffffc0200086:	24b020ef          	jal	ra,ffffffffc0202ad0 <pmm_init>
ffffffffc020008a:	3ef000ef          	jal	ra,ffffffffc0200c78 <pic_init>
ffffffffc020008e:	515000ef          	jal	ra,ffffffffc0200da2 <idt_init>
ffffffffc0200092:	6d7030ef          	jal	ra,ffffffffc0203f68 <vmm_init>
ffffffffc0200096:	170070ef          	jal	ra,ffffffffc0207206 <sched_init>
ffffffffc020009a:	577060ef          	jal	ra,ffffffffc0206e10 <proc_init>
ffffffffc020009e:	1bf000ef          	jal	ra,ffffffffc0200a5c <ide_init>
ffffffffc02000a2:	108050ef          	jal	ra,ffffffffc02051aa <fs_init>
ffffffffc02000a6:	4a4000ef          	jal	ra,ffffffffc020054a <clock_init>
ffffffffc02000aa:	3c3000ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02000ae:	72f060ef          	jal	ra,ffffffffc0206fdc <cpu_idle>

ffffffffc02000b2 <readline>:
ffffffffc02000b2:	715d                	addi	sp,sp,-80
ffffffffc02000b4:	e486                	sd	ra,72(sp)
ffffffffc02000b6:	e0a6                	sd	s1,64(sp)
ffffffffc02000b8:	fc4a                	sd	s2,56(sp)
ffffffffc02000ba:	f84e                	sd	s3,48(sp)
ffffffffc02000bc:	f452                	sd	s4,40(sp)
ffffffffc02000be:	f056                	sd	s5,32(sp)
ffffffffc02000c0:	ec5a                	sd	s6,24(sp)
ffffffffc02000c2:	e85e                	sd	s7,16(sp)
ffffffffc02000c4:	c901                	beqz	a0,ffffffffc02000d4 <readline+0x22>
ffffffffc02000c6:	85aa                	mv	a1,a0
ffffffffc02000c8:	0000c517          	auipc	a0,0xc
ffffffffc02000cc:	9d050513          	addi	a0,a0,-1584 # ffffffffc020ba98 <etext+0x2a>
ffffffffc02000d0:	0d6000ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc02000d4:	4481                	li	s1,0
ffffffffc02000d6:	497d                	li	s2,31
ffffffffc02000d8:	49a1                	li	s3,8
ffffffffc02000da:	4aa9                	li	s5,10
ffffffffc02000dc:	4b35                	li	s6,13
ffffffffc02000de:	00091b97          	auipc	s7,0x91
ffffffffc02000e2:	f82b8b93          	addi	s7,s7,-126 # ffffffffc0291060 <buf>
ffffffffc02000e6:	3fe00a13          	li	s4,1022
ffffffffc02000ea:	0fa000ef          	jal	ra,ffffffffc02001e4 <getchar>
ffffffffc02000ee:	00054a63          	bltz	a0,ffffffffc0200102 <readline+0x50>
ffffffffc02000f2:	00a95a63          	bge	s2,a0,ffffffffc0200106 <readline+0x54>
ffffffffc02000f6:	029a5263          	bge	s4,s1,ffffffffc020011a <readline+0x68>
ffffffffc02000fa:	0ea000ef          	jal	ra,ffffffffc02001e4 <getchar>
ffffffffc02000fe:	fe055ae3          	bgez	a0,ffffffffc02000f2 <readline+0x40>
ffffffffc0200102:	4501                	li	a0,0
ffffffffc0200104:	a091                	j	ffffffffc0200148 <readline+0x96>
ffffffffc0200106:	03351463          	bne	a0,s3,ffffffffc020012e <readline+0x7c>
ffffffffc020010a:	e8a9                	bnez	s1,ffffffffc020015c <readline+0xaa>
ffffffffc020010c:	0d8000ef          	jal	ra,ffffffffc02001e4 <getchar>
ffffffffc0200110:	fe0549e3          	bltz	a0,ffffffffc0200102 <readline+0x50>
ffffffffc0200114:	fea959e3          	bge	s2,a0,ffffffffc0200106 <readline+0x54>
ffffffffc0200118:	4481                	li	s1,0
ffffffffc020011a:	e42a                	sd	a0,8(sp)
ffffffffc020011c:	0c6000ef          	jal	ra,ffffffffc02001e2 <cputchar>
ffffffffc0200120:	6522                	ld	a0,8(sp)
ffffffffc0200122:	009b87b3          	add	a5,s7,s1
ffffffffc0200126:	2485                	addiw	s1,s1,1
ffffffffc0200128:	00a78023          	sb	a0,0(a5)
ffffffffc020012c:	bf7d                	j	ffffffffc02000ea <readline+0x38>
ffffffffc020012e:	01550463          	beq	a0,s5,ffffffffc0200136 <readline+0x84>
ffffffffc0200132:	fb651ce3          	bne	a0,s6,ffffffffc02000ea <readline+0x38>
ffffffffc0200136:	0ac000ef          	jal	ra,ffffffffc02001e2 <cputchar>
ffffffffc020013a:	00091517          	auipc	a0,0x91
ffffffffc020013e:	f2650513          	addi	a0,a0,-218 # ffffffffc0291060 <buf>
ffffffffc0200142:	94aa                	add	s1,s1,a0
ffffffffc0200144:	00048023          	sb	zero,0(s1)
ffffffffc0200148:	60a6                	ld	ra,72(sp)
ffffffffc020014a:	6486                	ld	s1,64(sp)
ffffffffc020014c:	7962                	ld	s2,56(sp)
ffffffffc020014e:	79c2                	ld	s3,48(sp)
ffffffffc0200150:	7a22                	ld	s4,40(sp)
ffffffffc0200152:	7a82                	ld	s5,32(sp)
ffffffffc0200154:	6b62                	ld	s6,24(sp)
ffffffffc0200156:	6bc2                	ld	s7,16(sp)
ffffffffc0200158:	6161                	addi	sp,sp,80
ffffffffc020015a:	8082                	ret
ffffffffc020015c:	4521                	li	a0,8
ffffffffc020015e:	084000ef          	jal	ra,ffffffffc02001e2 <cputchar>
ffffffffc0200162:	34fd                	addiw	s1,s1,-1
ffffffffc0200164:	b759                	j	ffffffffc02000ea <readline+0x38>

ffffffffc0200166 <cputch>:
ffffffffc0200166:	1141                	addi	sp,sp,-16
ffffffffc0200168:	e022                	sd	s0,0(sp)
ffffffffc020016a:	e406                	sd	ra,8(sp)
ffffffffc020016c:	842e                	mv	s0,a1
ffffffffc020016e:	432000ef          	jal	ra,ffffffffc02005a0 <cons_putc>
ffffffffc0200172:	401c                	lw	a5,0(s0)
ffffffffc0200174:	60a2                	ld	ra,8(sp)
ffffffffc0200176:	2785                	addiw	a5,a5,1
ffffffffc0200178:	c01c                	sw	a5,0(s0)
ffffffffc020017a:	6402                	ld	s0,0(sp)
ffffffffc020017c:	0141                	addi	sp,sp,16
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <vcprintf>:
ffffffffc0200180:	1101                	addi	sp,sp,-32
ffffffffc0200182:	872e                	mv	a4,a1
ffffffffc0200184:	75dd                	lui	a1,0xffff7
ffffffffc0200186:	86aa                	mv	a3,a0
ffffffffc0200188:	0070                	addi	a2,sp,12
ffffffffc020018a:	00000517          	auipc	a0,0x0
ffffffffc020018e:	fdc50513          	addi	a0,a0,-36 # ffffffffc0200166 <cputch>
ffffffffc0200192:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc0200196:	ec06                	sd	ra,24(sp)
ffffffffc0200198:	c602                	sw	zero,12(sp)
ffffffffc020019a:	3b40b0ef          	jal	ra,ffffffffc020b54e <vprintfmt>
ffffffffc020019e:	60e2                	ld	ra,24(sp)
ffffffffc02001a0:	4532                	lw	a0,12(sp)
ffffffffc02001a2:	6105                	addi	sp,sp,32
ffffffffc02001a4:	8082                	ret

ffffffffc02001a6 <cprintf>:
ffffffffc02001a6:	711d                	addi	sp,sp,-96
ffffffffc02001a8:	02810313          	addi	t1,sp,40 # ffffffffc0213028 <boot_page_table_sv39+0x28>
ffffffffc02001ac:	8e2a                	mv	t3,a0
ffffffffc02001ae:	f42e                	sd	a1,40(sp)
ffffffffc02001b0:	75dd                	lui	a1,0xffff7
ffffffffc02001b2:	f832                	sd	a2,48(sp)
ffffffffc02001b4:	fc36                	sd	a3,56(sp)
ffffffffc02001b6:	e0ba                	sd	a4,64(sp)
ffffffffc02001b8:	00000517          	auipc	a0,0x0
ffffffffc02001bc:	fae50513          	addi	a0,a0,-82 # ffffffffc0200166 <cputch>
ffffffffc02001c0:	0050                	addi	a2,sp,4
ffffffffc02001c2:	871a                	mv	a4,t1
ffffffffc02001c4:	86f2                	mv	a3,t3
ffffffffc02001c6:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc02001ca:	ec06                	sd	ra,24(sp)
ffffffffc02001cc:	e4be                	sd	a5,72(sp)
ffffffffc02001ce:	e8c2                	sd	a6,80(sp)
ffffffffc02001d0:	ecc6                	sd	a7,88(sp)
ffffffffc02001d2:	e41a                	sd	t1,8(sp)
ffffffffc02001d4:	c202                	sw	zero,4(sp)
ffffffffc02001d6:	3780b0ef          	jal	ra,ffffffffc020b54e <vprintfmt>
ffffffffc02001da:	60e2                	ld	ra,24(sp)
ffffffffc02001dc:	4512                	lw	a0,4(sp)
ffffffffc02001de:	6125                	addi	sp,sp,96
ffffffffc02001e0:	8082                	ret

ffffffffc02001e2 <cputchar>:
ffffffffc02001e2:	ae7d                	j	ffffffffc02005a0 <cons_putc>

ffffffffc02001e4 <getchar>:
ffffffffc02001e4:	1141                	addi	sp,sp,-16
ffffffffc02001e6:	e406                	sd	ra,8(sp)
ffffffffc02001e8:	40c000ef          	jal	ra,ffffffffc02005f4 <cons_getc>
ffffffffc02001ec:	dd75                	beqz	a0,ffffffffc02001e8 <getchar+0x4>
ffffffffc02001ee:	60a2                	ld	ra,8(sp)
ffffffffc02001f0:	0141                	addi	sp,sp,16
ffffffffc02001f2:	8082                	ret

ffffffffc02001f4 <strdup>:
ffffffffc02001f4:	1101                	addi	sp,sp,-32
ffffffffc02001f6:	ec06                	sd	ra,24(sp)
ffffffffc02001f8:	e822                	sd	s0,16(sp)
ffffffffc02001fa:	e426                	sd	s1,8(sp)
ffffffffc02001fc:	e04a                	sd	s2,0(sp)
ffffffffc02001fe:	892a                	mv	s2,a0
ffffffffc0200200:	73a0b0ef          	jal	ra,ffffffffc020b93a <strlen>
ffffffffc0200204:	842a                	mv	s0,a0
ffffffffc0200206:	0505                	addi	a0,a0,1
ffffffffc0200208:	587010ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc020020c:	84aa                	mv	s1,a0
ffffffffc020020e:	c901                	beqz	a0,ffffffffc020021e <strdup+0x2a>
ffffffffc0200210:	8622                	mv	a2,s0
ffffffffc0200212:	85ca                	mv	a1,s2
ffffffffc0200214:	9426                	add	s0,s0,s1
ffffffffc0200216:	0410b0ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc020021a:	00040023          	sb	zero,0(s0)
ffffffffc020021e:	60e2                	ld	ra,24(sp)
ffffffffc0200220:	6442                	ld	s0,16(sp)
ffffffffc0200222:	6902                	ld	s2,0(sp)
ffffffffc0200224:	8526                	mv	a0,s1
ffffffffc0200226:	64a2                	ld	s1,8(sp)
ffffffffc0200228:	6105                	addi	sp,sp,32
ffffffffc020022a:	8082                	ret

ffffffffc020022c <print_kerninfo>:
ffffffffc020022c:	1141                	addi	sp,sp,-16
ffffffffc020022e:	0000c517          	auipc	a0,0xc
ffffffffc0200232:	87250513          	addi	a0,a0,-1934 # ffffffffc020baa0 <etext+0x32>
ffffffffc0200236:	e406                	sd	ra,8(sp)
ffffffffc0200238:	f6fff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc020023c:	00000597          	auipc	a1,0x0
ffffffffc0200240:	e0e58593          	addi	a1,a1,-498 # ffffffffc020004a <kern_init>
ffffffffc0200244:	0000c517          	auipc	a0,0xc
ffffffffc0200248:	87c50513          	addi	a0,a0,-1924 # ffffffffc020bac0 <etext+0x52>
ffffffffc020024c:	f5bff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200250:	0000c597          	auipc	a1,0xc
ffffffffc0200254:	81e58593          	addi	a1,a1,-2018 # ffffffffc020ba6e <etext>
ffffffffc0200258:	0000c517          	auipc	a0,0xc
ffffffffc020025c:	88850513          	addi	a0,a0,-1912 # ffffffffc020bae0 <etext+0x72>
ffffffffc0200260:	f47ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200264:	00091597          	auipc	a1,0x91
ffffffffc0200268:	dfc58593          	addi	a1,a1,-516 # ffffffffc0291060 <buf>
ffffffffc020026c:	0000c517          	auipc	a0,0xc
ffffffffc0200270:	89450513          	addi	a0,a0,-1900 # ffffffffc020bb00 <etext+0x92>
ffffffffc0200274:	f33ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200278:	00096597          	auipc	a1,0x96
ffffffffc020027c:	69858593          	addi	a1,a1,1688 # ffffffffc0296910 <end>
ffffffffc0200280:	0000c517          	auipc	a0,0xc
ffffffffc0200284:	8a050513          	addi	a0,a0,-1888 # ffffffffc020bb20 <etext+0xb2>
ffffffffc0200288:	f1fff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc020028c:	00097597          	auipc	a1,0x97
ffffffffc0200290:	a8358593          	addi	a1,a1,-1405 # ffffffffc0296d0f <end+0x3ff>
ffffffffc0200294:	00000797          	auipc	a5,0x0
ffffffffc0200298:	db678793          	addi	a5,a5,-586 # ffffffffc020004a <kern_init>
ffffffffc020029c:	40f587b3          	sub	a5,a1,a5
ffffffffc02002a0:	43f7d593          	srai	a1,a5,0x3f
ffffffffc02002a4:	60a2                	ld	ra,8(sp)
ffffffffc02002a6:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002aa:	95be                	add	a1,a1,a5
ffffffffc02002ac:	85a9                	srai	a1,a1,0xa
ffffffffc02002ae:	0000c517          	auipc	a0,0xc
ffffffffc02002b2:	89250513          	addi	a0,a0,-1902 # ffffffffc020bb40 <etext+0xd2>
ffffffffc02002b6:	0141                	addi	sp,sp,16
ffffffffc02002b8:	b5fd                	j	ffffffffc02001a6 <cprintf>

ffffffffc02002ba <print_stackframe>:
ffffffffc02002ba:	1141                	addi	sp,sp,-16
ffffffffc02002bc:	0000c617          	auipc	a2,0xc
ffffffffc02002c0:	8b460613          	addi	a2,a2,-1868 # ffffffffc020bb70 <etext+0x102>
ffffffffc02002c4:	04e00593          	li	a1,78
ffffffffc02002c8:	0000c517          	auipc	a0,0xc
ffffffffc02002cc:	8c050513          	addi	a0,a0,-1856 # ffffffffc020bb88 <etext+0x11a>
ffffffffc02002d0:	e406                	sd	ra,8(sp)
ffffffffc02002d2:	1cc000ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02002d6 <mon_help>:
ffffffffc02002d6:	1141                	addi	sp,sp,-16
ffffffffc02002d8:	0000c617          	auipc	a2,0xc
ffffffffc02002dc:	8c860613          	addi	a2,a2,-1848 # ffffffffc020bba0 <etext+0x132>
ffffffffc02002e0:	0000c597          	auipc	a1,0xc
ffffffffc02002e4:	8e058593          	addi	a1,a1,-1824 # ffffffffc020bbc0 <etext+0x152>
ffffffffc02002e8:	0000c517          	auipc	a0,0xc
ffffffffc02002ec:	8e050513          	addi	a0,a0,-1824 # ffffffffc020bbc8 <etext+0x15a>
ffffffffc02002f0:	e406                	sd	ra,8(sp)
ffffffffc02002f2:	eb5ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc02002f6:	0000c617          	auipc	a2,0xc
ffffffffc02002fa:	8e260613          	addi	a2,a2,-1822 # ffffffffc020bbd8 <etext+0x16a>
ffffffffc02002fe:	0000c597          	auipc	a1,0xc
ffffffffc0200302:	90258593          	addi	a1,a1,-1790 # ffffffffc020bc00 <etext+0x192>
ffffffffc0200306:	0000c517          	auipc	a0,0xc
ffffffffc020030a:	8c250513          	addi	a0,a0,-1854 # ffffffffc020bbc8 <etext+0x15a>
ffffffffc020030e:	e99ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200312:	0000c617          	auipc	a2,0xc
ffffffffc0200316:	8fe60613          	addi	a2,a2,-1794 # ffffffffc020bc10 <etext+0x1a2>
ffffffffc020031a:	0000c597          	auipc	a1,0xc
ffffffffc020031e:	91658593          	addi	a1,a1,-1770 # ffffffffc020bc30 <etext+0x1c2>
ffffffffc0200322:	0000c517          	auipc	a0,0xc
ffffffffc0200326:	8a650513          	addi	a0,a0,-1882 # ffffffffc020bbc8 <etext+0x15a>
ffffffffc020032a:	e7dff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc020032e:	60a2                	ld	ra,8(sp)
ffffffffc0200330:	4501                	li	a0,0
ffffffffc0200332:	0141                	addi	sp,sp,16
ffffffffc0200334:	8082                	ret

ffffffffc0200336 <mon_kerninfo>:
ffffffffc0200336:	1141                	addi	sp,sp,-16
ffffffffc0200338:	e406                	sd	ra,8(sp)
ffffffffc020033a:	ef3ff0ef          	jal	ra,ffffffffc020022c <print_kerninfo>
ffffffffc020033e:	60a2                	ld	ra,8(sp)
ffffffffc0200340:	4501                	li	a0,0
ffffffffc0200342:	0141                	addi	sp,sp,16
ffffffffc0200344:	8082                	ret

ffffffffc0200346 <mon_backtrace>:
ffffffffc0200346:	1141                	addi	sp,sp,-16
ffffffffc0200348:	e406                	sd	ra,8(sp)
ffffffffc020034a:	f71ff0ef          	jal	ra,ffffffffc02002ba <print_stackframe>
ffffffffc020034e:	60a2                	ld	ra,8(sp)
ffffffffc0200350:	4501                	li	a0,0
ffffffffc0200352:	0141                	addi	sp,sp,16
ffffffffc0200354:	8082                	ret

ffffffffc0200356 <kmonitor>:
ffffffffc0200356:	7115                	addi	sp,sp,-224
ffffffffc0200358:	ed5e                	sd	s7,152(sp)
ffffffffc020035a:	8baa                	mv	s7,a0
ffffffffc020035c:	0000c517          	auipc	a0,0xc
ffffffffc0200360:	8e450513          	addi	a0,a0,-1820 # ffffffffc020bc40 <etext+0x1d2>
ffffffffc0200364:	ed86                	sd	ra,216(sp)
ffffffffc0200366:	e9a2                	sd	s0,208(sp)
ffffffffc0200368:	e5a6                	sd	s1,200(sp)
ffffffffc020036a:	e1ca                	sd	s2,192(sp)
ffffffffc020036c:	fd4e                	sd	s3,184(sp)
ffffffffc020036e:	f952                	sd	s4,176(sp)
ffffffffc0200370:	f556                	sd	s5,168(sp)
ffffffffc0200372:	f15a                	sd	s6,160(sp)
ffffffffc0200374:	e962                	sd	s8,144(sp)
ffffffffc0200376:	e566                	sd	s9,136(sp)
ffffffffc0200378:	e16a                	sd	s10,128(sp)
ffffffffc020037a:	e2dff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc020037e:	0000c517          	auipc	a0,0xc
ffffffffc0200382:	8ea50513          	addi	a0,a0,-1814 # ffffffffc020bc68 <etext+0x1fa>
ffffffffc0200386:	e21ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc020038a:	000b8563          	beqz	s7,ffffffffc0200394 <kmonitor+0x3e>
ffffffffc020038e:	855e                	mv	a0,s7
ffffffffc0200390:	3fb000ef          	jal	ra,ffffffffc0200f8a <print_trapframe>
ffffffffc0200394:	0000cc17          	auipc	s8,0xc
ffffffffc0200398:	944c0c13          	addi	s8,s8,-1724 # ffffffffc020bcd8 <commands>
ffffffffc020039c:	0000c917          	auipc	s2,0xc
ffffffffc02003a0:	8f490913          	addi	s2,s2,-1804 # ffffffffc020bc90 <etext+0x222>
ffffffffc02003a4:	0000c497          	auipc	s1,0xc
ffffffffc02003a8:	8f448493          	addi	s1,s1,-1804 # ffffffffc020bc98 <etext+0x22a>
ffffffffc02003ac:	49bd                	li	s3,15
ffffffffc02003ae:	0000cb17          	auipc	s6,0xc
ffffffffc02003b2:	8f2b0b13          	addi	s6,s6,-1806 # ffffffffc020bca0 <etext+0x232>
ffffffffc02003b6:	0000ca17          	auipc	s4,0xc
ffffffffc02003ba:	80aa0a13          	addi	s4,s4,-2038 # ffffffffc020bbc0 <etext+0x152>
ffffffffc02003be:	4a8d                	li	s5,3
ffffffffc02003c0:	854a                	mv	a0,s2
ffffffffc02003c2:	cf1ff0ef          	jal	ra,ffffffffc02000b2 <readline>
ffffffffc02003c6:	842a                	mv	s0,a0
ffffffffc02003c8:	dd65                	beqz	a0,ffffffffc02003c0 <kmonitor+0x6a>
ffffffffc02003ca:	00054583          	lbu	a1,0(a0)
ffffffffc02003ce:	4c81                	li	s9,0
ffffffffc02003d0:	e1bd                	bnez	a1,ffffffffc0200436 <kmonitor+0xe0>
ffffffffc02003d2:	fe0c87e3          	beqz	s9,ffffffffc02003c0 <kmonitor+0x6a>
ffffffffc02003d6:	6582                	ld	a1,0(sp)
ffffffffc02003d8:	0000cd17          	auipc	s10,0xc
ffffffffc02003dc:	900d0d13          	addi	s10,s10,-1792 # ffffffffc020bcd8 <commands>
ffffffffc02003e0:	8552                	mv	a0,s4
ffffffffc02003e2:	4401                	li	s0,0
ffffffffc02003e4:	0d61                	addi	s10,s10,24
ffffffffc02003e6:	5c40b0ef          	jal	ra,ffffffffc020b9aa <strcmp>
ffffffffc02003ea:	c919                	beqz	a0,ffffffffc0200400 <kmonitor+0xaa>
ffffffffc02003ec:	2405                	addiw	s0,s0,1
ffffffffc02003ee:	0b540063          	beq	s0,s5,ffffffffc020048e <kmonitor+0x138>
ffffffffc02003f2:	000d3503          	ld	a0,0(s10)
ffffffffc02003f6:	6582                	ld	a1,0(sp)
ffffffffc02003f8:	0d61                	addi	s10,s10,24
ffffffffc02003fa:	5b00b0ef          	jal	ra,ffffffffc020b9aa <strcmp>
ffffffffc02003fe:	f57d                	bnez	a0,ffffffffc02003ec <kmonitor+0x96>
ffffffffc0200400:	00141793          	slli	a5,s0,0x1
ffffffffc0200404:	97a2                	add	a5,a5,s0
ffffffffc0200406:	078e                	slli	a5,a5,0x3
ffffffffc0200408:	97e2                	add	a5,a5,s8
ffffffffc020040a:	6b9c                	ld	a5,16(a5)
ffffffffc020040c:	865e                	mv	a2,s7
ffffffffc020040e:	002c                	addi	a1,sp,8
ffffffffc0200410:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200414:	9782                	jalr	a5
ffffffffc0200416:	fa0555e3          	bgez	a0,ffffffffc02003c0 <kmonitor+0x6a>
ffffffffc020041a:	60ee                	ld	ra,216(sp)
ffffffffc020041c:	644e                	ld	s0,208(sp)
ffffffffc020041e:	64ae                	ld	s1,200(sp)
ffffffffc0200420:	690e                	ld	s2,192(sp)
ffffffffc0200422:	79ea                	ld	s3,184(sp)
ffffffffc0200424:	7a4a                	ld	s4,176(sp)
ffffffffc0200426:	7aaa                	ld	s5,168(sp)
ffffffffc0200428:	7b0a                	ld	s6,160(sp)
ffffffffc020042a:	6bea                	ld	s7,152(sp)
ffffffffc020042c:	6c4a                	ld	s8,144(sp)
ffffffffc020042e:	6caa                	ld	s9,136(sp)
ffffffffc0200430:	6d0a                	ld	s10,128(sp)
ffffffffc0200432:	612d                	addi	sp,sp,224
ffffffffc0200434:	8082                	ret
ffffffffc0200436:	8526                	mv	a0,s1
ffffffffc0200438:	5b60b0ef          	jal	ra,ffffffffc020b9ee <strchr>
ffffffffc020043c:	c901                	beqz	a0,ffffffffc020044c <kmonitor+0xf6>
ffffffffc020043e:	00144583          	lbu	a1,1(s0)
ffffffffc0200442:	00040023          	sb	zero,0(s0)
ffffffffc0200446:	0405                	addi	s0,s0,1
ffffffffc0200448:	d5c9                	beqz	a1,ffffffffc02003d2 <kmonitor+0x7c>
ffffffffc020044a:	b7f5                	j	ffffffffc0200436 <kmonitor+0xe0>
ffffffffc020044c:	00044783          	lbu	a5,0(s0)
ffffffffc0200450:	d3c9                	beqz	a5,ffffffffc02003d2 <kmonitor+0x7c>
ffffffffc0200452:	033c8963          	beq	s9,s3,ffffffffc0200484 <kmonitor+0x12e>
ffffffffc0200456:	003c9793          	slli	a5,s9,0x3
ffffffffc020045a:	0118                	addi	a4,sp,128
ffffffffc020045c:	97ba                	add	a5,a5,a4
ffffffffc020045e:	f887b023          	sd	s0,-128(a5)
ffffffffc0200462:	00044583          	lbu	a1,0(s0)
ffffffffc0200466:	2c85                	addiw	s9,s9,1
ffffffffc0200468:	e591                	bnez	a1,ffffffffc0200474 <kmonitor+0x11e>
ffffffffc020046a:	b7b5                	j	ffffffffc02003d6 <kmonitor+0x80>
ffffffffc020046c:	00144583          	lbu	a1,1(s0)
ffffffffc0200470:	0405                	addi	s0,s0,1
ffffffffc0200472:	d1a5                	beqz	a1,ffffffffc02003d2 <kmonitor+0x7c>
ffffffffc0200474:	8526                	mv	a0,s1
ffffffffc0200476:	5780b0ef          	jal	ra,ffffffffc020b9ee <strchr>
ffffffffc020047a:	d96d                	beqz	a0,ffffffffc020046c <kmonitor+0x116>
ffffffffc020047c:	00044583          	lbu	a1,0(s0)
ffffffffc0200480:	d9a9                	beqz	a1,ffffffffc02003d2 <kmonitor+0x7c>
ffffffffc0200482:	bf55                	j	ffffffffc0200436 <kmonitor+0xe0>
ffffffffc0200484:	45c1                	li	a1,16
ffffffffc0200486:	855a                	mv	a0,s6
ffffffffc0200488:	d1fff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc020048c:	b7e9                	j	ffffffffc0200456 <kmonitor+0x100>
ffffffffc020048e:	6582                	ld	a1,0(sp)
ffffffffc0200490:	0000c517          	auipc	a0,0xc
ffffffffc0200494:	83050513          	addi	a0,a0,-2000 # ffffffffc020bcc0 <etext+0x252>
ffffffffc0200498:	d0fff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc020049c:	b715                	j	ffffffffc02003c0 <kmonitor+0x6a>

ffffffffc020049e <__panic>:
ffffffffc020049e:	00096317          	auipc	t1,0x96
ffffffffc02004a2:	3ca30313          	addi	t1,t1,970 # ffffffffc0296868 <is_panic>
ffffffffc02004a6:	00033e03          	ld	t3,0(t1)
ffffffffc02004aa:	715d                	addi	sp,sp,-80
ffffffffc02004ac:	ec06                	sd	ra,24(sp)
ffffffffc02004ae:	e822                	sd	s0,16(sp)
ffffffffc02004b0:	f436                	sd	a3,40(sp)
ffffffffc02004b2:	f83a                	sd	a4,48(sp)
ffffffffc02004b4:	fc3e                	sd	a5,56(sp)
ffffffffc02004b6:	e0c2                	sd	a6,64(sp)
ffffffffc02004b8:	e4c6                	sd	a7,72(sp)
ffffffffc02004ba:	020e1a63          	bnez	t3,ffffffffc02004ee <__panic+0x50>
ffffffffc02004be:	4785                	li	a5,1
ffffffffc02004c0:	00f33023          	sd	a5,0(t1)
ffffffffc02004c4:	8432                	mv	s0,a2
ffffffffc02004c6:	103c                	addi	a5,sp,40
ffffffffc02004c8:	862e                	mv	a2,a1
ffffffffc02004ca:	85aa                	mv	a1,a0
ffffffffc02004cc:	0000c517          	auipc	a0,0xc
ffffffffc02004d0:	85450513          	addi	a0,a0,-1964 # ffffffffc020bd20 <commands+0x48>
ffffffffc02004d4:	e43e                	sd	a5,8(sp)
ffffffffc02004d6:	cd1ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc02004da:	65a2                	ld	a1,8(sp)
ffffffffc02004dc:	8522                	mv	a0,s0
ffffffffc02004de:	ca3ff0ef          	jal	ra,ffffffffc0200180 <vcprintf>
ffffffffc02004e2:	0000d517          	auipc	a0,0xd
ffffffffc02004e6:	afe50513          	addi	a0,a0,-1282 # ffffffffc020cfe0 <default_pmm_manager+0x610>
ffffffffc02004ea:	cbdff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc02004ee:	4501                	li	a0,0
ffffffffc02004f0:	4581                	li	a1,0
ffffffffc02004f2:	4601                	li	a2,0
ffffffffc02004f4:	48a1                	li	a7,8
ffffffffc02004f6:	00000073          	ecall
ffffffffc02004fa:	778000ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02004fe:	4501                	li	a0,0
ffffffffc0200500:	e57ff0ef          	jal	ra,ffffffffc0200356 <kmonitor>
ffffffffc0200504:	bfed                	j	ffffffffc02004fe <__panic+0x60>

ffffffffc0200506 <__warn>:
ffffffffc0200506:	715d                	addi	sp,sp,-80
ffffffffc0200508:	832e                	mv	t1,a1
ffffffffc020050a:	e822                	sd	s0,16(sp)
ffffffffc020050c:	85aa                	mv	a1,a0
ffffffffc020050e:	8432                	mv	s0,a2
ffffffffc0200510:	fc3e                	sd	a5,56(sp)
ffffffffc0200512:	861a                	mv	a2,t1
ffffffffc0200514:	103c                	addi	a5,sp,40
ffffffffc0200516:	0000c517          	auipc	a0,0xc
ffffffffc020051a:	82a50513          	addi	a0,a0,-2006 # ffffffffc020bd40 <commands+0x68>
ffffffffc020051e:	ec06                	sd	ra,24(sp)
ffffffffc0200520:	f436                	sd	a3,40(sp)
ffffffffc0200522:	f83a                	sd	a4,48(sp)
ffffffffc0200524:	e0c2                	sd	a6,64(sp)
ffffffffc0200526:	e4c6                	sd	a7,72(sp)
ffffffffc0200528:	e43e                	sd	a5,8(sp)
ffffffffc020052a:	c7dff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc020052e:	65a2                	ld	a1,8(sp)
ffffffffc0200530:	8522                	mv	a0,s0
ffffffffc0200532:	c4fff0ef          	jal	ra,ffffffffc0200180 <vcprintf>
ffffffffc0200536:	0000d517          	auipc	a0,0xd
ffffffffc020053a:	aaa50513          	addi	a0,a0,-1366 # ffffffffc020cfe0 <default_pmm_manager+0x610>
ffffffffc020053e:	c69ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200542:	60e2                	ld	ra,24(sp)
ffffffffc0200544:	6442                	ld	s0,16(sp)
ffffffffc0200546:	6161                	addi	sp,sp,80
ffffffffc0200548:	8082                	ret

ffffffffc020054a <clock_init>:
ffffffffc020054a:	02000793          	li	a5,32
ffffffffc020054e:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc0200552:	c0102573          	rdtime	a0
ffffffffc0200556:	67e1                	lui	a5,0x18
ffffffffc0200558:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_bin_swap_img_size+0x109a0>
ffffffffc020055c:	953e                	add	a0,a0,a5
ffffffffc020055e:	4581                	li	a1,0
ffffffffc0200560:	4601                	li	a2,0
ffffffffc0200562:	4881                	li	a7,0
ffffffffc0200564:	00000073          	ecall
ffffffffc0200568:	0000b517          	auipc	a0,0xb
ffffffffc020056c:	7f850513          	addi	a0,a0,2040 # ffffffffc020bd60 <commands+0x88>
ffffffffc0200570:	00096797          	auipc	a5,0x96
ffffffffc0200574:	3007b023          	sd	zero,768(a5) # ffffffffc0296870 <ticks>
ffffffffc0200578:	b13d                	j	ffffffffc02001a6 <cprintf>

ffffffffc020057a <clock_set_next_event>:
ffffffffc020057a:	c0102573          	rdtime	a0
ffffffffc020057e:	67e1                	lui	a5,0x18
ffffffffc0200580:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_bin_swap_img_size+0x109a0>
ffffffffc0200584:	953e                	add	a0,a0,a5
ffffffffc0200586:	4581                	li	a1,0
ffffffffc0200588:	4601                	li	a2,0
ffffffffc020058a:	4881                	li	a7,0
ffffffffc020058c:	00000073          	ecall
ffffffffc0200590:	8082                	ret

ffffffffc0200592 <cons_init>:
ffffffffc0200592:	4501                	li	a0,0
ffffffffc0200594:	4581                	li	a1,0
ffffffffc0200596:	4601                	li	a2,0
ffffffffc0200598:	4889                	li	a7,2
ffffffffc020059a:	00000073          	ecall
ffffffffc020059e:	8082                	ret

ffffffffc02005a0 <cons_putc>:
ffffffffc02005a0:	1101                	addi	sp,sp,-32
ffffffffc02005a2:	ec06                	sd	ra,24(sp)
ffffffffc02005a4:	100027f3          	csrr	a5,sstatus
ffffffffc02005a8:	8b89                	andi	a5,a5,2
ffffffffc02005aa:	4701                	li	a4,0
ffffffffc02005ac:	ef95                	bnez	a5,ffffffffc02005e8 <cons_putc+0x48>
ffffffffc02005ae:	47a1                	li	a5,8
ffffffffc02005b0:	00f50b63          	beq	a0,a5,ffffffffc02005c6 <cons_putc+0x26>
ffffffffc02005b4:	4581                	li	a1,0
ffffffffc02005b6:	4601                	li	a2,0
ffffffffc02005b8:	4885                	li	a7,1
ffffffffc02005ba:	00000073          	ecall
ffffffffc02005be:	e315                	bnez	a4,ffffffffc02005e2 <cons_putc+0x42>
ffffffffc02005c0:	60e2                	ld	ra,24(sp)
ffffffffc02005c2:	6105                	addi	sp,sp,32
ffffffffc02005c4:	8082                	ret
ffffffffc02005c6:	4521                	li	a0,8
ffffffffc02005c8:	4581                	li	a1,0
ffffffffc02005ca:	4601                	li	a2,0
ffffffffc02005cc:	4885                	li	a7,1
ffffffffc02005ce:	00000073          	ecall
ffffffffc02005d2:	02000513          	li	a0,32
ffffffffc02005d6:	00000073          	ecall
ffffffffc02005da:	4521                	li	a0,8
ffffffffc02005dc:	00000073          	ecall
ffffffffc02005e0:	d365                	beqz	a4,ffffffffc02005c0 <cons_putc+0x20>
ffffffffc02005e2:	60e2                	ld	ra,24(sp)
ffffffffc02005e4:	6105                	addi	sp,sp,32
ffffffffc02005e6:	a559                	j	ffffffffc0200c6c <intr_enable>
ffffffffc02005e8:	e42a                	sd	a0,8(sp)
ffffffffc02005ea:	688000ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02005ee:	6522                	ld	a0,8(sp)
ffffffffc02005f0:	4705                	li	a4,1
ffffffffc02005f2:	bf75                	j	ffffffffc02005ae <cons_putc+0xe>

ffffffffc02005f4 <cons_getc>:
ffffffffc02005f4:	1101                	addi	sp,sp,-32
ffffffffc02005f6:	ec06                	sd	ra,24(sp)
ffffffffc02005f8:	100027f3          	csrr	a5,sstatus
ffffffffc02005fc:	8b89                	andi	a5,a5,2
ffffffffc02005fe:	4801                	li	a6,0
ffffffffc0200600:	e3d5                	bnez	a5,ffffffffc02006a4 <cons_getc+0xb0>
ffffffffc0200602:	00091697          	auipc	a3,0x91
ffffffffc0200606:	e5e68693          	addi	a3,a3,-418 # ffffffffc0291460 <cons>
ffffffffc020060a:	07f00713          	li	a4,127
ffffffffc020060e:	20000313          	li	t1,512
ffffffffc0200612:	a021                	j	ffffffffc020061a <cons_getc+0x26>
ffffffffc0200614:	0ff57513          	zext.b	a0,a0
ffffffffc0200618:	ef91                	bnez	a5,ffffffffc0200634 <cons_getc+0x40>
ffffffffc020061a:	4501                	li	a0,0
ffffffffc020061c:	4581                	li	a1,0
ffffffffc020061e:	4601                	li	a2,0
ffffffffc0200620:	4889                	li	a7,2
ffffffffc0200622:	00000073          	ecall
ffffffffc0200626:	0005079b          	sext.w	a5,a0
ffffffffc020062a:	0207c763          	bltz	a5,ffffffffc0200658 <cons_getc+0x64>
ffffffffc020062e:	fee793e3          	bne	a5,a4,ffffffffc0200614 <cons_getc+0x20>
ffffffffc0200632:	4521                	li	a0,8
ffffffffc0200634:	2046a783          	lw	a5,516(a3)
ffffffffc0200638:	02079613          	slli	a2,a5,0x20
ffffffffc020063c:	9201                	srli	a2,a2,0x20
ffffffffc020063e:	2785                	addiw	a5,a5,1
ffffffffc0200640:	9636                	add	a2,a2,a3
ffffffffc0200642:	20f6a223          	sw	a5,516(a3)
ffffffffc0200646:	00a60023          	sb	a0,0(a2)
ffffffffc020064a:	fc6798e3          	bne	a5,t1,ffffffffc020061a <cons_getc+0x26>
ffffffffc020064e:	00091797          	auipc	a5,0x91
ffffffffc0200652:	0007ab23          	sw	zero,22(a5) # ffffffffc0291664 <cons+0x204>
ffffffffc0200656:	b7d1                	j	ffffffffc020061a <cons_getc+0x26>
ffffffffc0200658:	2006a783          	lw	a5,512(a3)
ffffffffc020065c:	2046a703          	lw	a4,516(a3)
ffffffffc0200660:	4501                	li	a0,0
ffffffffc0200662:	00f70f63          	beq	a4,a5,ffffffffc0200680 <cons_getc+0x8c>
ffffffffc0200666:	0017861b          	addiw	a2,a5,1
ffffffffc020066a:	1782                	slli	a5,a5,0x20
ffffffffc020066c:	9381                	srli	a5,a5,0x20
ffffffffc020066e:	97b6                	add	a5,a5,a3
ffffffffc0200670:	20c6a023          	sw	a2,512(a3)
ffffffffc0200674:	20000713          	li	a4,512
ffffffffc0200678:	0007c503          	lbu	a0,0(a5)
ffffffffc020067c:	00e60763          	beq	a2,a4,ffffffffc020068a <cons_getc+0x96>
ffffffffc0200680:	00081b63          	bnez	a6,ffffffffc0200696 <cons_getc+0xa2>
ffffffffc0200684:	60e2                	ld	ra,24(sp)
ffffffffc0200686:	6105                	addi	sp,sp,32
ffffffffc0200688:	8082                	ret
ffffffffc020068a:	00091797          	auipc	a5,0x91
ffffffffc020068e:	fc07ab23          	sw	zero,-42(a5) # ffffffffc0291660 <cons+0x200>
ffffffffc0200692:	fe0809e3          	beqz	a6,ffffffffc0200684 <cons_getc+0x90>
ffffffffc0200696:	e42a                	sd	a0,8(sp)
ffffffffc0200698:	5d4000ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc020069c:	60e2                	ld	ra,24(sp)
ffffffffc020069e:	6522                	ld	a0,8(sp)
ffffffffc02006a0:	6105                	addi	sp,sp,32
ffffffffc02006a2:	8082                	ret
ffffffffc02006a4:	5ce000ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02006a8:	4805                	li	a6,1
ffffffffc02006aa:	bfa1                	j	ffffffffc0200602 <cons_getc+0xe>

ffffffffc02006ac <dtb_init>:
ffffffffc02006ac:	7119                	addi	sp,sp,-128
ffffffffc02006ae:	0000b517          	auipc	a0,0xb
ffffffffc02006b2:	6d250513          	addi	a0,a0,1746 # ffffffffc020bd80 <commands+0xa8>
ffffffffc02006b6:	fc86                	sd	ra,120(sp)
ffffffffc02006b8:	f8a2                	sd	s0,112(sp)
ffffffffc02006ba:	e8d2                	sd	s4,80(sp)
ffffffffc02006bc:	f4a6                	sd	s1,104(sp)
ffffffffc02006be:	f0ca                	sd	s2,96(sp)
ffffffffc02006c0:	ecce                	sd	s3,88(sp)
ffffffffc02006c2:	e4d6                	sd	s5,72(sp)
ffffffffc02006c4:	e0da                	sd	s6,64(sp)
ffffffffc02006c6:	fc5e                	sd	s7,56(sp)
ffffffffc02006c8:	f862                	sd	s8,48(sp)
ffffffffc02006ca:	f466                	sd	s9,40(sp)
ffffffffc02006cc:	f06a                	sd	s10,32(sp)
ffffffffc02006ce:	ec6e                	sd	s11,24(sp)
ffffffffc02006d0:	ad7ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc02006d4:	00014597          	auipc	a1,0x14
ffffffffc02006d8:	92c5b583          	ld	a1,-1748(a1) # ffffffffc0214000 <boot_hartid>
ffffffffc02006dc:	0000b517          	auipc	a0,0xb
ffffffffc02006e0:	6b450513          	addi	a0,a0,1716 # ffffffffc020bd90 <commands+0xb8>
ffffffffc02006e4:	ac3ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc02006e8:	00014417          	auipc	s0,0x14
ffffffffc02006ec:	92040413          	addi	s0,s0,-1760 # ffffffffc0214008 <boot_dtb>
ffffffffc02006f0:	600c                	ld	a1,0(s0)
ffffffffc02006f2:	0000b517          	auipc	a0,0xb
ffffffffc02006f6:	6ae50513          	addi	a0,a0,1710 # ffffffffc020bda0 <commands+0xc8>
ffffffffc02006fa:	aadff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc02006fe:	00043a03          	ld	s4,0(s0)
ffffffffc0200702:	0000b517          	auipc	a0,0xb
ffffffffc0200706:	6b650513          	addi	a0,a0,1718 # ffffffffc020bdb8 <commands+0xe0>
ffffffffc020070a:	120a0463          	beqz	s4,ffffffffc0200832 <dtb_init+0x186>
ffffffffc020070e:	57f5                	li	a5,-3
ffffffffc0200710:	07fa                	slli	a5,a5,0x1e
ffffffffc0200712:	00fa0733          	add	a4,s4,a5
ffffffffc0200716:	431c                	lw	a5,0(a4)
ffffffffc0200718:	00ff0637          	lui	a2,0xff0
ffffffffc020071c:	6b41                	lui	s6,0x10
ffffffffc020071e:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200722:	0187969b          	slliw	a3,a5,0x18
ffffffffc0200726:	0187d51b          	srliw	a0,a5,0x18
ffffffffc020072a:	0105959b          	slliw	a1,a1,0x10
ffffffffc020072e:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200732:	8df1                	and	a1,a1,a2
ffffffffc0200734:	8ec9                	or	a3,a3,a0
ffffffffc0200736:	0087979b          	slliw	a5,a5,0x8
ffffffffc020073a:	1b7d                	addi	s6,s6,-1
ffffffffc020073c:	0167f7b3          	and	a5,a5,s6
ffffffffc0200740:	8dd5                	or	a1,a1,a3
ffffffffc0200742:	8ddd                	or	a1,a1,a5
ffffffffc0200744:	d00e07b7          	lui	a5,0xd00e0
ffffffffc0200748:	2581                	sext.w	a1,a1
ffffffffc020074a:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe495dd>
ffffffffc020074e:	10f59163          	bne	a1,a5,ffffffffc0200850 <dtb_init+0x1a4>
ffffffffc0200752:	471c                	lw	a5,8(a4)
ffffffffc0200754:	4754                	lw	a3,12(a4)
ffffffffc0200756:	4c81                	li	s9,0
ffffffffc0200758:	0087d59b          	srliw	a1,a5,0x8
ffffffffc020075c:	0086d51b          	srliw	a0,a3,0x8
ffffffffc0200760:	0186941b          	slliw	s0,a3,0x18
ffffffffc0200764:	0186d89b          	srliw	a7,a3,0x18
ffffffffc0200768:	01879a1b          	slliw	s4,a5,0x18
ffffffffc020076c:	0187d81b          	srliw	a6,a5,0x18
ffffffffc0200770:	0105151b          	slliw	a0,a0,0x10
ffffffffc0200774:	0106d69b          	srliw	a3,a3,0x10
ffffffffc0200778:	0105959b          	slliw	a1,a1,0x10
ffffffffc020077c:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200780:	8d71                	and	a0,a0,a2
ffffffffc0200782:	01146433          	or	s0,s0,a7
ffffffffc0200786:	0086969b          	slliw	a3,a3,0x8
ffffffffc020078a:	010a6a33          	or	s4,s4,a6
ffffffffc020078e:	8e6d                	and	a2,a2,a1
ffffffffc0200790:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200794:	8c49                	or	s0,s0,a0
ffffffffc0200796:	0166f6b3          	and	a3,a3,s6
ffffffffc020079a:	00ca6a33          	or	s4,s4,a2
ffffffffc020079e:	0167f7b3          	and	a5,a5,s6
ffffffffc02007a2:	8c55                	or	s0,s0,a3
ffffffffc02007a4:	00fa6a33          	or	s4,s4,a5
ffffffffc02007a8:	1402                	slli	s0,s0,0x20
ffffffffc02007aa:	1a02                	slli	s4,s4,0x20
ffffffffc02007ac:	9001                	srli	s0,s0,0x20
ffffffffc02007ae:	020a5a13          	srli	s4,s4,0x20
ffffffffc02007b2:	943a                	add	s0,s0,a4
ffffffffc02007b4:	9a3a                	add	s4,s4,a4
ffffffffc02007b6:	00ff0c37          	lui	s8,0xff0
ffffffffc02007ba:	4b8d                	li	s7,3
ffffffffc02007bc:	0000b917          	auipc	s2,0xb
ffffffffc02007c0:	64c90913          	addi	s2,s2,1612 # ffffffffc020be08 <commands+0x130>
ffffffffc02007c4:	49bd                	li	s3,15
ffffffffc02007c6:	4d91                	li	s11,4
ffffffffc02007c8:	4d05                	li	s10,1
ffffffffc02007ca:	0000b497          	auipc	s1,0xb
ffffffffc02007ce:	63648493          	addi	s1,s1,1590 # ffffffffc020be00 <commands+0x128>
ffffffffc02007d2:	000a2703          	lw	a4,0(s4)
ffffffffc02007d6:	004a0a93          	addi	s5,s4,4
ffffffffc02007da:	0087569b          	srliw	a3,a4,0x8
ffffffffc02007de:	0187179b          	slliw	a5,a4,0x18
ffffffffc02007e2:	0187561b          	srliw	a2,a4,0x18
ffffffffc02007e6:	0106969b          	slliw	a3,a3,0x10
ffffffffc02007ea:	0107571b          	srliw	a4,a4,0x10
ffffffffc02007ee:	8fd1                	or	a5,a5,a2
ffffffffc02007f0:	0186f6b3          	and	a3,a3,s8
ffffffffc02007f4:	0087171b          	slliw	a4,a4,0x8
ffffffffc02007f8:	8fd5                	or	a5,a5,a3
ffffffffc02007fa:	00eb7733          	and	a4,s6,a4
ffffffffc02007fe:	8fd9                	or	a5,a5,a4
ffffffffc0200800:	2781                	sext.w	a5,a5
ffffffffc0200802:	09778c63          	beq	a5,s7,ffffffffc020089a <dtb_init+0x1ee>
ffffffffc0200806:	00fbea63          	bltu	s7,a5,ffffffffc020081a <dtb_init+0x16e>
ffffffffc020080a:	07a78663          	beq	a5,s10,ffffffffc0200876 <dtb_init+0x1ca>
ffffffffc020080e:	4709                	li	a4,2
ffffffffc0200810:	00e79763          	bne	a5,a4,ffffffffc020081e <dtb_init+0x172>
ffffffffc0200814:	4c81                	li	s9,0
ffffffffc0200816:	8a56                	mv	s4,s5
ffffffffc0200818:	bf6d                	j	ffffffffc02007d2 <dtb_init+0x126>
ffffffffc020081a:	ffb78ee3          	beq	a5,s11,ffffffffc0200816 <dtb_init+0x16a>
ffffffffc020081e:	0000b517          	auipc	a0,0xb
ffffffffc0200822:	66250513          	addi	a0,a0,1634 # ffffffffc020be80 <commands+0x1a8>
ffffffffc0200826:	981ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc020082a:	0000b517          	auipc	a0,0xb
ffffffffc020082e:	68e50513          	addi	a0,a0,1678 # ffffffffc020beb8 <commands+0x1e0>
ffffffffc0200832:	7446                	ld	s0,112(sp)
ffffffffc0200834:	70e6                	ld	ra,120(sp)
ffffffffc0200836:	74a6                	ld	s1,104(sp)
ffffffffc0200838:	7906                	ld	s2,96(sp)
ffffffffc020083a:	69e6                	ld	s3,88(sp)
ffffffffc020083c:	6a46                	ld	s4,80(sp)
ffffffffc020083e:	6aa6                	ld	s5,72(sp)
ffffffffc0200840:	6b06                	ld	s6,64(sp)
ffffffffc0200842:	7be2                	ld	s7,56(sp)
ffffffffc0200844:	7c42                	ld	s8,48(sp)
ffffffffc0200846:	7ca2                	ld	s9,40(sp)
ffffffffc0200848:	7d02                	ld	s10,32(sp)
ffffffffc020084a:	6de2                	ld	s11,24(sp)
ffffffffc020084c:	6109                	addi	sp,sp,128
ffffffffc020084e:	baa1                	j	ffffffffc02001a6 <cprintf>
ffffffffc0200850:	7446                	ld	s0,112(sp)
ffffffffc0200852:	70e6                	ld	ra,120(sp)
ffffffffc0200854:	74a6                	ld	s1,104(sp)
ffffffffc0200856:	7906                	ld	s2,96(sp)
ffffffffc0200858:	69e6                	ld	s3,88(sp)
ffffffffc020085a:	6a46                	ld	s4,80(sp)
ffffffffc020085c:	6aa6                	ld	s5,72(sp)
ffffffffc020085e:	6b06                	ld	s6,64(sp)
ffffffffc0200860:	7be2                	ld	s7,56(sp)
ffffffffc0200862:	7c42                	ld	s8,48(sp)
ffffffffc0200864:	7ca2                	ld	s9,40(sp)
ffffffffc0200866:	7d02                	ld	s10,32(sp)
ffffffffc0200868:	6de2                	ld	s11,24(sp)
ffffffffc020086a:	0000b517          	auipc	a0,0xb
ffffffffc020086e:	56e50513          	addi	a0,a0,1390 # ffffffffc020bdd8 <commands+0x100>
ffffffffc0200872:	6109                	addi	sp,sp,128
ffffffffc0200874:	ba0d                	j	ffffffffc02001a6 <cprintf>
ffffffffc0200876:	8556                	mv	a0,s5
ffffffffc0200878:	0c20b0ef          	jal	ra,ffffffffc020b93a <strlen>
ffffffffc020087c:	8a2a                	mv	s4,a0
ffffffffc020087e:	4619                	li	a2,6
ffffffffc0200880:	85a6                	mv	a1,s1
ffffffffc0200882:	8556                	mv	a0,s5
ffffffffc0200884:	2a01                	sext.w	s4,s4
ffffffffc0200886:	1420b0ef          	jal	ra,ffffffffc020b9c8 <strncmp>
ffffffffc020088a:	e111                	bnez	a0,ffffffffc020088e <dtb_init+0x1e2>
ffffffffc020088c:	4c85                	li	s9,1
ffffffffc020088e:	0a91                	addi	s5,s5,4
ffffffffc0200890:	9ad2                	add	s5,s5,s4
ffffffffc0200892:	ffcafa93          	andi	s5,s5,-4
ffffffffc0200896:	8a56                	mv	s4,s5
ffffffffc0200898:	bf2d                	j	ffffffffc02007d2 <dtb_init+0x126>
ffffffffc020089a:	004a2783          	lw	a5,4(s4)
ffffffffc020089e:	00ca0693          	addi	a3,s4,12
ffffffffc02008a2:	0087d71b          	srliw	a4,a5,0x8
ffffffffc02008a6:	01879a9b          	slliw	s5,a5,0x18
ffffffffc02008aa:	0187d61b          	srliw	a2,a5,0x18
ffffffffc02008ae:	0107171b          	slliw	a4,a4,0x10
ffffffffc02008b2:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02008b6:	00caeab3          	or	s5,s5,a2
ffffffffc02008ba:	01877733          	and	a4,a4,s8
ffffffffc02008be:	0087979b          	slliw	a5,a5,0x8
ffffffffc02008c2:	00eaeab3          	or	s5,s5,a4
ffffffffc02008c6:	00fb77b3          	and	a5,s6,a5
ffffffffc02008ca:	00faeab3          	or	s5,s5,a5
ffffffffc02008ce:	2a81                	sext.w	s5,s5
ffffffffc02008d0:	000c9c63          	bnez	s9,ffffffffc02008e8 <dtb_init+0x23c>
ffffffffc02008d4:	1a82                	slli	s5,s5,0x20
ffffffffc02008d6:	00368793          	addi	a5,a3,3
ffffffffc02008da:	020ada93          	srli	s5,s5,0x20
ffffffffc02008de:	9abe                	add	s5,s5,a5
ffffffffc02008e0:	ffcafa93          	andi	s5,s5,-4
ffffffffc02008e4:	8a56                	mv	s4,s5
ffffffffc02008e6:	b5f5                	j	ffffffffc02007d2 <dtb_init+0x126>
ffffffffc02008e8:	008a2783          	lw	a5,8(s4)
ffffffffc02008ec:	85ca                	mv	a1,s2
ffffffffc02008ee:	e436                	sd	a3,8(sp)
ffffffffc02008f0:	0087d51b          	srliw	a0,a5,0x8
ffffffffc02008f4:	0187d61b          	srliw	a2,a5,0x18
ffffffffc02008f8:	0187971b          	slliw	a4,a5,0x18
ffffffffc02008fc:	0105151b          	slliw	a0,a0,0x10
ffffffffc0200900:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200904:	8f51                	or	a4,a4,a2
ffffffffc0200906:	01857533          	and	a0,a0,s8
ffffffffc020090a:	0087979b          	slliw	a5,a5,0x8
ffffffffc020090e:	8d59                	or	a0,a0,a4
ffffffffc0200910:	00fb77b3          	and	a5,s6,a5
ffffffffc0200914:	8d5d                	or	a0,a0,a5
ffffffffc0200916:	1502                	slli	a0,a0,0x20
ffffffffc0200918:	9101                	srli	a0,a0,0x20
ffffffffc020091a:	9522                	add	a0,a0,s0
ffffffffc020091c:	08e0b0ef          	jal	ra,ffffffffc020b9aa <strcmp>
ffffffffc0200920:	66a2                	ld	a3,8(sp)
ffffffffc0200922:	f94d                	bnez	a0,ffffffffc02008d4 <dtb_init+0x228>
ffffffffc0200924:	fb59f8e3          	bgeu	s3,s5,ffffffffc02008d4 <dtb_init+0x228>
ffffffffc0200928:	00ca3783          	ld	a5,12(s4)
ffffffffc020092c:	014a3703          	ld	a4,20(s4)
ffffffffc0200930:	0000b517          	auipc	a0,0xb
ffffffffc0200934:	4e050513          	addi	a0,a0,1248 # ffffffffc020be10 <commands+0x138>
ffffffffc0200938:	4207d613          	srai	a2,a5,0x20
ffffffffc020093c:	0087d31b          	srliw	t1,a5,0x8
ffffffffc0200940:	42075593          	srai	a1,a4,0x20
ffffffffc0200944:	0187de1b          	srliw	t3,a5,0x18
ffffffffc0200948:	0186581b          	srliw	a6,a2,0x18
ffffffffc020094c:	0187941b          	slliw	s0,a5,0x18
ffffffffc0200950:	0107d89b          	srliw	a7,a5,0x10
ffffffffc0200954:	0187d693          	srli	a3,a5,0x18
ffffffffc0200958:	01861f1b          	slliw	t5,a2,0x18
ffffffffc020095c:	0087579b          	srliw	a5,a4,0x8
ffffffffc0200960:	0103131b          	slliw	t1,t1,0x10
ffffffffc0200964:	0106561b          	srliw	a2,a2,0x10
ffffffffc0200968:	010f6f33          	or	t5,t5,a6
ffffffffc020096c:	0187529b          	srliw	t0,a4,0x18
ffffffffc0200970:	0185df9b          	srliw	t6,a1,0x18
ffffffffc0200974:	01837333          	and	t1,t1,s8
ffffffffc0200978:	01c46433          	or	s0,s0,t3
ffffffffc020097c:	0186f6b3          	and	a3,a3,s8
ffffffffc0200980:	01859e1b          	slliw	t3,a1,0x18
ffffffffc0200984:	01871e9b          	slliw	t4,a4,0x18
ffffffffc0200988:	0107581b          	srliw	a6,a4,0x10
ffffffffc020098c:	0086161b          	slliw	a2,a2,0x8
ffffffffc0200990:	8361                	srli	a4,a4,0x18
ffffffffc0200992:	0107979b          	slliw	a5,a5,0x10
ffffffffc0200996:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020099a:	01e6e6b3          	or	a3,a3,t5
ffffffffc020099e:	00cb7633          	and	a2,s6,a2
ffffffffc02009a2:	0088181b          	slliw	a6,a6,0x8
ffffffffc02009a6:	0085959b          	slliw	a1,a1,0x8
ffffffffc02009aa:	00646433          	or	s0,s0,t1
ffffffffc02009ae:	0187f7b3          	and	a5,a5,s8
ffffffffc02009b2:	01fe6333          	or	t1,t3,t6
ffffffffc02009b6:	01877c33          	and	s8,a4,s8
ffffffffc02009ba:	0088989b          	slliw	a7,a7,0x8
ffffffffc02009be:	011b78b3          	and	a7,s6,a7
ffffffffc02009c2:	005eeeb3          	or	t4,t4,t0
ffffffffc02009c6:	00c6e733          	or	a4,a3,a2
ffffffffc02009ca:	006c6c33          	or	s8,s8,t1
ffffffffc02009ce:	010b76b3          	and	a3,s6,a6
ffffffffc02009d2:	00bb7b33          	and	s6,s6,a1
ffffffffc02009d6:	01d7e7b3          	or	a5,a5,t4
ffffffffc02009da:	016c6b33          	or	s6,s8,s6
ffffffffc02009de:	01146433          	or	s0,s0,a7
ffffffffc02009e2:	8fd5                	or	a5,a5,a3
ffffffffc02009e4:	1702                	slli	a4,a4,0x20
ffffffffc02009e6:	1b02                	slli	s6,s6,0x20
ffffffffc02009e8:	1782                	slli	a5,a5,0x20
ffffffffc02009ea:	9301                	srli	a4,a4,0x20
ffffffffc02009ec:	1402                	slli	s0,s0,0x20
ffffffffc02009ee:	020b5b13          	srli	s6,s6,0x20
ffffffffc02009f2:	0167eb33          	or	s6,a5,s6
ffffffffc02009f6:	8c59                	or	s0,s0,a4
ffffffffc02009f8:	faeff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc02009fc:	85a2                	mv	a1,s0
ffffffffc02009fe:	0000b517          	auipc	a0,0xb
ffffffffc0200a02:	43250513          	addi	a0,a0,1074 # ffffffffc020be30 <commands+0x158>
ffffffffc0200a06:	fa0ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200a0a:	014b5613          	srli	a2,s6,0x14
ffffffffc0200a0e:	85da                	mv	a1,s6
ffffffffc0200a10:	0000b517          	auipc	a0,0xb
ffffffffc0200a14:	43850513          	addi	a0,a0,1080 # ffffffffc020be48 <commands+0x170>
ffffffffc0200a18:	f8eff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200a1c:	008b05b3          	add	a1,s6,s0
ffffffffc0200a20:	15fd                	addi	a1,a1,-1
ffffffffc0200a22:	0000b517          	auipc	a0,0xb
ffffffffc0200a26:	44650513          	addi	a0,a0,1094 # ffffffffc020be68 <commands+0x190>
ffffffffc0200a2a:	f7cff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200a2e:	0000b517          	auipc	a0,0xb
ffffffffc0200a32:	48a50513          	addi	a0,a0,1162 # ffffffffc020beb8 <commands+0x1e0>
ffffffffc0200a36:	00096797          	auipc	a5,0x96
ffffffffc0200a3a:	e487b123          	sd	s0,-446(a5) # ffffffffc0296878 <memory_base>
ffffffffc0200a3e:	00096797          	auipc	a5,0x96
ffffffffc0200a42:	e567b123          	sd	s6,-446(a5) # ffffffffc0296880 <memory_size>
ffffffffc0200a46:	b3f5                	j	ffffffffc0200832 <dtb_init+0x186>

ffffffffc0200a48 <get_memory_base>:
ffffffffc0200a48:	00096517          	auipc	a0,0x96
ffffffffc0200a4c:	e3053503          	ld	a0,-464(a0) # ffffffffc0296878 <memory_base>
ffffffffc0200a50:	8082                	ret

ffffffffc0200a52 <get_memory_size>:
ffffffffc0200a52:	00096517          	auipc	a0,0x96
ffffffffc0200a56:	e2e53503          	ld	a0,-466(a0) # ffffffffc0296880 <memory_size>
ffffffffc0200a5a:	8082                	ret

ffffffffc0200a5c <ide_init>:
ffffffffc0200a5c:	1141                	addi	sp,sp,-16
ffffffffc0200a5e:	00091597          	auipc	a1,0x91
ffffffffc0200a62:	c5a58593          	addi	a1,a1,-934 # ffffffffc02916b8 <ide_devices+0x50>
ffffffffc0200a66:	4505                	li	a0,1
ffffffffc0200a68:	e022                	sd	s0,0(sp)
ffffffffc0200a6a:	00091797          	auipc	a5,0x91
ffffffffc0200a6e:	be07af23          	sw	zero,-1026(a5) # ffffffffc0291668 <ide_devices>
ffffffffc0200a72:	00091797          	auipc	a5,0x91
ffffffffc0200a76:	c407a323          	sw	zero,-954(a5) # ffffffffc02916b8 <ide_devices+0x50>
ffffffffc0200a7a:	00091797          	auipc	a5,0x91
ffffffffc0200a7e:	c807a723          	sw	zero,-882(a5) # ffffffffc0291708 <ide_devices+0xa0>
ffffffffc0200a82:	00091797          	auipc	a5,0x91
ffffffffc0200a86:	cc07ab23          	sw	zero,-810(a5) # ffffffffc0291758 <ide_devices+0xf0>
ffffffffc0200a8a:	e406                	sd	ra,8(sp)
ffffffffc0200a8c:	00091417          	auipc	s0,0x91
ffffffffc0200a90:	bdc40413          	addi	s0,s0,-1060 # ffffffffc0291668 <ide_devices>
ffffffffc0200a94:	23a000ef          	jal	ra,ffffffffc0200cce <ramdisk_init>
ffffffffc0200a98:	483c                	lw	a5,80(s0)
ffffffffc0200a9a:	cf99                	beqz	a5,ffffffffc0200ab8 <ide_init+0x5c>
ffffffffc0200a9c:	00091597          	auipc	a1,0x91
ffffffffc0200aa0:	c6c58593          	addi	a1,a1,-916 # ffffffffc0291708 <ide_devices+0xa0>
ffffffffc0200aa4:	4509                	li	a0,2
ffffffffc0200aa6:	228000ef          	jal	ra,ffffffffc0200cce <ramdisk_init>
ffffffffc0200aaa:	0a042783          	lw	a5,160(s0)
ffffffffc0200aae:	c785                	beqz	a5,ffffffffc0200ad6 <ide_init+0x7a>
ffffffffc0200ab0:	60a2                	ld	ra,8(sp)
ffffffffc0200ab2:	6402                	ld	s0,0(sp)
ffffffffc0200ab4:	0141                	addi	sp,sp,16
ffffffffc0200ab6:	8082                	ret
ffffffffc0200ab8:	0000b697          	auipc	a3,0xb
ffffffffc0200abc:	41868693          	addi	a3,a3,1048 # ffffffffc020bed0 <commands+0x1f8>
ffffffffc0200ac0:	0000b617          	auipc	a2,0xb
ffffffffc0200ac4:	42860613          	addi	a2,a2,1064 # ffffffffc020bee8 <commands+0x210>
ffffffffc0200ac8:	45c5                	li	a1,17
ffffffffc0200aca:	0000b517          	auipc	a0,0xb
ffffffffc0200ace:	43650513          	addi	a0,a0,1078 # ffffffffc020bf00 <commands+0x228>
ffffffffc0200ad2:	9cdff0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0200ad6:	0000b697          	auipc	a3,0xb
ffffffffc0200ada:	44268693          	addi	a3,a3,1090 # ffffffffc020bf18 <commands+0x240>
ffffffffc0200ade:	0000b617          	auipc	a2,0xb
ffffffffc0200ae2:	40a60613          	addi	a2,a2,1034 # ffffffffc020bee8 <commands+0x210>
ffffffffc0200ae6:	45d1                	li	a1,20
ffffffffc0200ae8:	0000b517          	auipc	a0,0xb
ffffffffc0200aec:	41850513          	addi	a0,a0,1048 # ffffffffc020bf00 <commands+0x228>
ffffffffc0200af0:	9afff0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0200af4 <ide_device_valid>:
ffffffffc0200af4:	478d                	li	a5,3
ffffffffc0200af6:	00a7ef63          	bltu	a5,a0,ffffffffc0200b14 <ide_device_valid+0x20>
ffffffffc0200afa:	00251793          	slli	a5,a0,0x2
ffffffffc0200afe:	953e                	add	a0,a0,a5
ffffffffc0200b00:	0512                	slli	a0,a0,0x4
ffffffffc0200b02:	00091797          	auipc	a5,0x91
ffffffffc0200b06:	b6678793          	addi	a5,a5,-1178 # ffffffffc0291668 <ide_devices>
ffffffffc0200b0a:	953e                	add	a0,a0,a5
ffffffffc0200b0c:	4108                	lw	a0,0(a0)
ffffffffc0200b0e:	00a03533          	snez	a0,a0
ffffffffc0200b12:	8082                	ret
ffffffffc0200b14:	4501                	li	a0,0
ffffffffc0200b16:	8082                	ret

ffffffffc0200b18 <ide_device_size>:
ffffffffc0200b18:	478d                	li	a5,3
ffffffffc0200b1a:	02a7e163          	bltu	a5,a0,ffffffffc0200b3c <ide_device_size+0x24>
ffffffffc0200b1e:	00251793          	slli	a5,a0,0x2
ffffffffc0200b22:	953e                	add	a0,a0,a5
ffffffffc0200b24:	0512                	slli	a0,a0,0x4
ffffffffc0200b26:	00091797          	auipc	a5,0x91
ffffffffc0200b2a:	b4278793          	addi	a5,a5,-1214 # ffffffffc0291668 <ide_devices>
ffffffffc0200b2e:	97aa                	add	a5,a5,a0
ffffffffc0200b30:	4398                	lw	a4,0(a5)
ffffffffc0200b32:	4501                	li	a0,0
ffffffffc0200b34:	c709                	beqz	a4,ffffffffc0200b3e <ide_device_size+0x26>
ffffffffc0200b36:	0087e503          	lwu	a0,8(a5)
ffffffffc0200b3a:	8082                	ret
ffffffffc0200b3c:	4501                	li	a0,0
ffffffffc0200b3e:	8082                	ret

ffffffffc0200b40 <ide_read_secs>:
ffffffffc0200b40:	1141                	addi	sp,sp,-16
ffffffffc0200b42:	e406                	sd	ra,8(sp)
ffffffffc0200b44:	08000793          	li	a5,128
ffffffffc0200b48:	04d7e763          	bltu	a5,a3,ffffffffc0200b96 <ide_read_secs+0x56>
ffffffffc0200b4c:	478d                	li	a5,3
ffffffffc0200b4e:	0005081b          	sext.w	a6,a0
ffffffffc0200b52:	04a7e263          	bltu	a5,a0,ffffffffc0200b96 <ide_read_secs+0x56>
ffffffffc0200b56:	00281793          	slli	a5,a6,0x2
ffffffffc0200b5a:	97c2                	add	a5,a5,a6
ffffffffc0200b5c:	0792                	slli	a5,a5,0x4
ffffffffc0200b5e:	00091817          	auipc	a6,0x91
ffffffffc0200b62:	b0a80813          	addi	a6,a6,-1270 # ffffffffc0291668 <ide_devices>
ffffffffc0200b66:	97c2                	add	a5,a5,a6
ffffffffc0200b68:	0007a883          	lw	a7,0(a5)
ffffffffc0200b6c:	02088563          	beqz	a7,ffffffffc0200b96 <ide_read_secs+0x56>
ffffffffc0200b70:	100008b7          	lui	a7,0x10000
ffffffffc0200b74:	0515f163          	bgeu	a1,a7,ffffffffc0200bb6 <ide_read_secs+0x76>
ffffffffc0200b78:	1582                	slli	a1,a1,0x20
ffffffffc0200b7a:	9181                	srli	a1,a1,0x20
ffffffffc0200b7c:	00d58733          	add	a4,a1,a3
ffffffffc0200b80:	02e8eb63          	bltu	a7,a4,ffffffffc0200bb6 <ide_read_secs+0x76>
ffffffffc0200b84:	00251713          	slli	a4,a0,0x2
ffffffffc0200b88:	60a2                	ld	ra,8(sp)
ffffffffc0200b8a:	63bc                	ld	a5,64(a5)
ffffffffc0200b8c:	953a                	add	a0,a0,a4
ffffffffc0200b8e:	0512                	slli	a0,a0,0x4
ffffffffc0200b90:	9542                	add	a0,a0,a6
ffffffffc0200b92:	0141                	addi	sp,sp,16
ffffffffc0200b94:	8782                	jr	a5
ffffffffc0200b96:	0000b697          	auipc	a3,0xb
ffffffffc0200b9a:	39a68693          	addi	a3,a3,922 # ffffffffc020bf30 <commands+0x258>
ffffffffc0200b9e:	0000b617          	auipc	a2,0xb
ffffffffc0200ba2:	34a60613          	addi	a2,a2,842 # ffffffffc020bee8 <commands+0x210>
ffffffffc0200ba6:	02200593          	li	a1,34
ffffffffc0200baa:	0000b517          	auipc	a0,0xb
ffffffffc0200bae:	35650513          	addi	a0,a0,854 # ffffffffc020bf00 <commands+0x228>
ffffffffc0200bb2:	8edff0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0200bb6:	0000b697          	auipc	a3,0xb
ffffffffc0200bba:	3a268693          	addi	a3,a3,930 # ffffffffc020bf58 <commands+0x280>
ffffffffc0200bbe:	0000b617          	auipc	a2,0xb
ffffffffc0200bc2:	32a60613          	addi	a2,a2,810 # ffffffffc020bee8 <commands+0x210>
ffffffffc0200bc6:	02300593          	li	a1,35
ffffffffc0200bca:	0000b517          	auipc	a0,0xb
ffffffffc0200bce:	33650513          	addi	a0,a0,822 # ffffffffc020bf00 <commands+0x228>
ffffffffc0200bd2:	8cdff0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0200bd6 <ide_write_secs>:
ffffffffc0200bd6:	1141                	addi	sp,sp,-16
ffffffffc0200bd8:	e406                	sd	ra,8(sp)
ffffffffc0200bda:	08000793          	li	a5,128
ffffffffc0200bde:	04d7e763          	bltu	a5,a3,ffffffffc0200c2c <ide_write_secs+0x56>
ffffffffc0200be2:	478d                	li	a5,3
ffffffffc0200be4:	0005081b          	sext.w	a6,a0
ffffffffc0200be8:	04a7e263          	bltu	a5,a0,ffffffffc0200c2c <ide_write_secs+0x56>
ffffffffc0200bec:	00281793          	slli	a5,a6,0x2
ffffffffc0200bf0:	97c2                	add	a5,a5,a6
ffffffffc0200bf2:	0792                	slli	a5,a5,0x4
ffffffffc0200bf4:	00091817          	auipc	a6,0x91
ffffffffc0200bf8:	a7480813          	addi	a6,a6,-1420 # ffffffffc0291668 <ide_devices>
ffffffffc0200bfc:	97c2                	add	a5,a5,a6
ffffffffc0200bfe:	0007a883          	lw	a7,0(a5)
ffffffffc0200c02:	02088563          	beqz	a7,ffffffffc0200c2c <ide_write_secs+0x56>
ffffffffc0200c06:	100008b7          	lui	a7,0x10000
ffffffffc0200c0a:	0515f163          	bgeu	a1,a7,ffffffffc0200c4c <ide_write_secs+0x76>
ffffffffc0200c0e:	1582                	slli	a1,a1,0x20
ffffffffc0200c10:	9181                	srli	a1,a1,0x20
ffffffffc0200c12:	00d58733          	add	a4,a1,a3
ffffffffc0200c16:	02e8eb63          	bltu	a7,a4,ffffffffc0200c4c <ide_write_secs+0x76>
ffffffffc0200c1a:	00251713          	slli	a4,a0,0x2
ffffffffc0200c1e:	60a2                	ld	ra,8(sp)
ffffffffc0200c20:	67bc                	ld	a5,72(a5)
ffffffffc0200c22:	953a                	add	a0,a0,a4
ffffffffc0200c24:	0512                	slli	a0,a0,0x4
ffffffffc0200c26:	9542                	add	a0,a0,a6
ffffffffc0200c28:	0141                	addi	sp,sp,16
ffffffffc0200c2a:	8782                	jr	a5
ffffffffc0200c2c:	0000b697          	auipc	a3,0xb
ffffffffc0200c30:	30468693          	addi	a3,a3,772 # ffffffffc020bf30 <commands+0x258>
ffffffffc0200c34:	0000b617          	auipc	a2,0xb
ffffffffc0200c38:	2b460613          	addi	a2,a2,692 # ffffffffc020bee8 <commands+0x210>
ffffffffc0200c3c:	02900593          	li	a1,41
ffffffffc0200c40:	0000b517          	auipc	a0,0xb
ffffffffc0200c44:	2c050513          	addi	a0,a0,704 # ffffffffc020bf00 <commands+0x228>
ffffffffc0200c48:	857ff0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0200c4c:	0000b697          	auipc	a3,0xb
ffffffffc0200c50:	30c68693          	addi	a3,a3,780 # ffffffffc020bf58 <commands+0x280>
ffffffffc0200c54:	0000b617          	auipc	a2,0xb
ffffffffc0200c58:	29460613          	addi	a2,a2,660 # ffffffffc020bee8 <commands+0x210>
ffffffffc0200c5c:	02a00593          	li	a1,42
ffffffffc0200c60:	0000b517          	auipc	a0,0xb
ffffffffc0200c64:	2a050513          	addi	a0,a0,672 # ffffffffc020bf00 <commands+0x228>
ffffffffc0200c68:	837ff0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0200c6c <intr_enable>:
ffffffffc0200c6c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200c70:	8082                	ret

ffffffffc0200c72 <intr_disable>:
ffffffffc0200c72:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200c76:	8082                	ret

ffffffffc0200c78 <pic_init>:
ffffffffc0200c78:	8082                	ret

ffffffffc0200c7a <ramdisk_write>:
ffffffffc0200c7a:	00856703          	lwu	a4,8(a0)
ffffffffc0200c7e:	1141                	addi	sp,sp,-16
ffffffffc0200c80:	e406                	sd	ra,8(sp)
ffffffffc0200c82:	8f0d                	sub	a4,a4,a1
ffffffffc0200c84:	87ae                	mv	a5,a1
ffffffffc0200c86:	85b2                	mv	a1,a2
ffffffffc0200c88:	00e6f363          	bgeu	a3,a4,ffffffffc0200c8e <ramdisk_write+0x14>
ffffffffc0200c8c:	8736                	mv	a4,a3
ffffffffc0200c8e:	6908                	ld	a0,16(a0)
ffffffffc0200c90:	07a6                	slli	a5,a5,0x9
ffffffffc0200c92:	00971613          	slli	a2,a4,0x9
ffffffffc0200c96:	953e                	add	a0,a0,a5
ffffffffc0200c98:	5bf0a0ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc0200c9c:	60a2                	ld	ra,8(sp)
ffffffffc0200c9e:	4501                	li	a0,0
ffffffffc0200ca0:	0141                	addi	sp,sp,16
ffffffffc0200ca2:	8082                	ret

ffffffffc0200ca4 <ramdisk_read>:
ffffffffc0200ca4:	00856783          	lwu	a5,8(a0)
ffffffffc0200ca8:	1141                	addi	sp,sp,-16
ffffffffc0200caa:	e406                	sd	ra,8(sp)
ffffffffc0200cac:	8f8d                	sub	a5,a5,a1
ffffffffc0200cae:	872a                	mv	a4,a0
ffffffffc0200cb0:	8532                	mv	a0,a2
ffffffffc0200cb2:	00f6f363          	bgeu	a3,a5,ffffffffc0200cb8 <ramdisk_read+0x14>
ffffffffc0200cb6:	87b6                	mv	a5,a3
ffffffffc0200cb8:	6b18                	ld	a4,16(a4)
ffffffffc0200cba:	05a6                	slli	a1,a1,0x9
ffffffffc0200cbc:	00979613          	slli	a2,a5,0x9
ffffffffc0200cc0:	95ba                	add	a1,a1,a4
ffffffffc0200cc2:	5950a0ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc0200cc6:	60a2                	ld	ra,8(sp)
ffffffffc0200cc8:	4501                	li	a0,0
ffffffffc0200cca:	0141                	addi	sp,sp,16
ffffffffc0200ccc:	8082                	ret

ffffffffc0200cce <ramdisk_init>:
ffffffffc0200cce:	1101                	addi	sp,sp,-32
ffffffffc0200cd0:	e822                	sd	s0,16(sp)
ffffffffc0200cd2:	842e                	mv	s0,a1
ffffffffc0200cd4:	e426                	sd	s1,8(sp)
ffffffffc0200cd6:	05000613          	li	a2,80
ffffffffc0200cda:	84aa                	mv	s1,a0
ffffffffc0200cdc:	4581                	li	a1,0
ffffffffc0200cde:	8522                	mv	a0,s0
ffffffffc0200ce0:	ec06                	sd	ra,24(sp)
ffffffffc0200ce2:	e04a                	sd	s2,0(sp)
ffffffffc0200ce4:	5210a0ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc0200ce8:	4785                	li	a5,1
ffffffffc0200cea:	06f48b63          	beq	s1,a5,ffffffffc0200d60 <ramdisk_init+0x92>
ffffffffc0200cee:	4789                	li	a5,2
ffffffffc0200cf0:	00090617          	auipc	a2,0x90
ffffffffc0200cf4:	32060613          	addi	a2,a2,800 # ffffffffc0291010 <arena>
ffffffffc0200cf8:	0001b917          	auipc	s2,0x1b
ffffffffc0200cfc:	01890913          	addi	s2,s2,24 # ffffffffc021bd10 <_binary_bin_sfs_img_start>
ffffffffc0200d00:	08f49563          	bne	s1,a5,ffffffffc0200d8a <ramdisk_init+0xbc>
ffffffffc0200d04:	06c90863          	beq	s2,a2,ffffffffc0200d74 <ramdisk_init+0xa6>
ffffffffc0200d08:	412604b3          	sub	s1,a2,s2
ffffffffc0200d0c:	86a6                	mv	a3,s1
ffffffffc0200d0e:	85ca                	mv	a1,s2
ffffffffc0200d10:	167d                	addi	a2,a2,-1
ffffffffc0200d12:	0000b517          	auipc	a0,0xb
ffffffffc0200d16:	29e50513          	addi	a0,a0,670 # ffffffffc020bfb0 <commands+0x2d8>
ffffffffc0200d1a:	c8cff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200d1e:	57fd                	li	a5,-1
ffffffffc0200d20:	1782                	slli	a5,a5,0x20
ffffffffc0200d22:	0785                	addi	a5,a5,1
ffffffffc0200d24:	0094d49b          	srliw	s1,s1,0x9
ffffffffc0200d28:	e01c                	sd	a5,0(s0)
ffffffffc0200d2a:	c404                	sw	s1,8(s0)
ffffffffc0200d2c:	01243823          	sd	s2,16(s0)
ffffffffc0200d30:	02040513          	addi	a0,s0,32
ffffffffc0200d34:	0000b597          	auipc	a1,0xb
ffffffffc0200d38:	2d458593          	addi	a1,a1,724 # ffffffffc020c008 <commands+0x330>
ffffffffc0200d3c:	4350a0ef          	jal	ra,ffffffffc020b970 <strcpy>
ffffffffc0200d40:	00000797          	auipc	a5,0x0
ffffffffc0200d44:	f6478793          	addi	a5,a5,-156 # ffffffffc0200ca4 <ramdisk_read>
ffffffffc0200d48:	e03c                	sd	a5,64(s0)
ffffffffc0200d4a:	00000797          	auipc	a5,0x0
ffffffffc0200d4e:	f3078793          	addi	a5,a5,-208 # ffffffffc0200c7a <ramdisk_write>
ffffffffc0200d52:	60e2                	ld	ra,24(sp)
ffffffffc0200d54:	e43c                	sd	a5,72(s0)
ffffffffc0200d56:	6442                	ld	s0,16(sp)
ffffffffc0200d58:	64a2                	ld	s1,8(sp)
ffffffffc0200d5a:	6902                	ld	s2,0(sp)
ffffffffc0200d5c:	6105                	addi	sp,sp,32
ffffffffc0200d5e:	8082                	ret
ffffffffc0200d60:	0001b617          	auipc	a2,0x1b
ffffffffc0200d64:	fb060613          	addi	a2,a2,-80 # ffffffffc021bd10 <_binary_bin_sfs_img_start>
ffffffffc0200d68:	00013917          	auipc	s2,0x13
ffffffffc0200d6c:	2a890913          	addi	s2,s2,680 # ffffffffc0214010 <_binary_bin_swap_img_start>
ffffffffc0200d70:	f8c91ce3          	bne	s2,a2,ffffffffc0200d08 <ramdisk_init+0x3a>
ffffffffc0200d74:	6442                	ld	s0,16(sp)
ffffffffc0200d76:	60e2                	ld	ra,24(sp)
ffffffffc0200d78:	64a2                	ld	s1,8(sp)
ffffffffc0200d7a:	6902                	ld	s2,0(sp)
ffffffffc0200d7c:	0000b517          	auipc	a0,0xb
ffffffffc0200d80:	21c50513          	addi	a0,a0,540 # ffffffffc020bf98 <commands+0x2c0>
ffffffffc0200d84:	6105                	addi	sp,sp,32
ffffffffc0200d86:	c20ff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc0200d8a:	0000b617          	auipc	a2,0xb
ffffffffc0200d8e:	24e60613          	addi	a2,a2,590 # ffffffffc020bfd8 <commands+0x300>
ffffffffc0200d92:	03200593          	li	a1,50
ffffffffc0200d96:	0000b517          	auipc	a0,0xb
ffffffffc0200d9a:	25a50513          	addi	a0,a0,602 # ffffffffc020bff0 <commands+0x318>
ffffffffc0200d9e:	f00ff0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0200da2 <idt_init>:
ffffffffc0200da2:	14005073          	csrwi	sscratch,0
ffffffffc0200da6:	00000797          	auipc	a5,0x0
ffffffffc0200daa:	43a78793          	addi	a5,a5,1082 # ffffffffc02011e0 <__alltraps>
ffffffffc0200dae:	10579073          	csrw	stvec,a5
ffffffffc0200db2:	000407b7          	lui	a5,0x40
ffffffffc0200db6:	1007a7f3          	csrrs	a5,sstatus,a5
ffffffffc0200dba:	8082                	ret

ffffffffc0200dbc <print_regs>:
ffffffffc0200dbc:	610c                	ld	a1,0(a0)
ffffffffc0200dbe:	1141                	addi	sp,sp,-16
ffffffffc0200dc0:	e022                	sd	s0,0(sp)
ffffffffc0200dc2:	842a                	mv	s0,a0
ffffffffc0200dc4:	0000b517          	auipc	a0,0xb
ffffffffc0200dc8:	25450513          	addi	a0,a0,596 # ffffffffc020c018 <commands+0x340>
ffffffffc0200dcc:	e406                	sd	ra,8(sp)
ffffffffc0200dce:	bd8ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200dd2:	640c                	ld	a1,8(s0)
ffffffffc0200dd4:	0000b517          	auipc	a0,0xb
ffffffffc0200dd8:	25c50513          	addi	a0,a0,604 # ffffffffc020c030 <commands+0x358>
ffffffffc0200ddc:	bcaff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200de0:	680c                	ld	a1,16(s0)
ffffffffc0200de2:	0000b517          	auipc	a0,0xb
ffffffffc0200de6:	26650513          	addi	a0,a0,614 # ffffffffc020c048 <commands+0x370>
ffffffffc0200dea:	bbcff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200dee:	6c0c                	ld	a1,24(s0)
ffffffffc0200df0:	0000b517          	auipc	a0,0xb
ffffffffc0200df4:	27050513          	addi	a0,a0,624 # ffffffffc020c060 <commands+0x388>
ffffffffc0200df8:	baeff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200dfc:	700c                	ld	a1,32(s0)
ffffffffc0200dfe:	0000b517          	auipc	a0,0xb
ffffffffc0200e02:	27a50513          	addi	a0,a0,634 # ffffffffc020c078 <commands+0x3a0>
ffffffffc0200e06:	ba0ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200e0a:	740c                	ld	a1,40(s0)
ffffffffc0200e0c:	0000b517          	auipc	a0,0xb
ffffffffc0200e10:	28450513          	addi	a0,a0,644 # ffffffffc020c090 <commands+0x3b8>
ffffffffc0200e14:	b92ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200e18:	780c                	ld	a1,48(s0)
ffffffffc0200e1a:	0000b517          	auipc	a0,0xb
ffffffffc0200e1e:	28e50513          	addi	a0,a0,654 # ffffffffc020c0a8 <commands+0x3d0>
ffffffffc0200e22:	b84ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200e26:	7c0c                	ld	a1,56(s0)
ffffffffc0200e28:	0000b517          	auipc	a0,0xb
ffffffffc0200e2c:	29850513          	addi	a0,a0,664 # ffffffffc020c0c0 <commands+0x3e8>
ffffffffc0200e30:	b76ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200e34:	602c                	ld	a1,64(s0)
ffffffffc0200e36:	0000b517          	auipc	a0,0xb
ffffffffc0200e3a:	2a250513          	addi	a0,a0,674 # ffffffffc020c0d8 <commands+0x400>
ffffffffc0200e3e:	b68ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200e42:	642c                	ld	a1,72(s0)
ffffffffc0200e44:	0000b517          	auipc	a0,0xb
ffffffffc0200e48:	2ac50513          	addi	a0,a0,684 # ffffffffc020c0f0 <commands+0x418>
ffffffffc0200e4c:	b5aff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200e50:	682c                	ld	a1,80(s0)
ffffffffc0200e52:	0000b517          	auipc	a0,0xb
ffffffffc0200e56:	2b650513          	addi	a0,a0,694 # ffffffffc020c108 <commands+0x430>
ffffffffc0200e5a:	b4cff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200e5e:	6c2c                	ld	a1,88(s0)
ffffffffc0200e60:	0000b517          	auipc	a0,0xb
ffffffffc0200e64:	2c050513          	addi	a0,a0,704 # ffffffffc020c120 <commands+0x448>
ffffffffc0200e68:	b3eff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200e6c:	702c                	ld	a1,96(s0)
ffffffffc0200e6e:	0000b517          	auipc	a0,0xb
ffffffffc0200e72:	2ca50513          	addi	a0,a0,714 # ffffffffc020c138 <commands+0x460>
ffffffffc0200e76:	b30ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200e7a:	742c                	ld	a1,104(s0)
ffffffffc0200e7c:	0000b517          	auipc	a0,0xb
ffffffffc0200e80:	2d450513          	addi	a0,a0,724 # ffffffffc020c150 <commands+0x478>
ffffffffc0200e84:	b22ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200e88:	782c                	ld	a1,112(s0)
ffffffffc0200e8a:	0000b517          	auipc	a0,0xb
ffffffffc0200e8e:	2de50513          	addi	a0,a0,734 # ffffffffc020c168 <commands+0x490>
ffffffffc0200e92:	b14ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200e96:	7c2c                	ld	a1,120(s0)
ffffffffc0200e98:	0000b517          	auipc	a0,0xb
ffffffffc0200e9c:	2e850513          	addi	a0,a0,744 # ffffffffc020c180 <commands+0x4a8>
ffffffffc0200ea0:	b06ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200ea4:	604c                	ld	a1,128(s0)
ffffffffc0200ea6:	0000b517          	auipc	a0,0xb
ffffffffc0200eaa:	2f250513          	addi	a0,a0,754 # ffffffffc020c198 <commands+0x4c0>
ffffffffc0200eae:	af8ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200eb2:	644c                	ld	a1,136(s0)
ffffffffc0200eb4:	0000b517          	auipc	a0,0xb
ffffffffc0200eb8:	2fc50513          	addi	a0,a0,764 # ffffffffc020c1b0 <commands+0x4d8>
ffffffffc0200ebc:	aeaff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200ec0:	684c                	ld	a1,144(s0)
ffffffffc0200ec2:	0000b517          	auipc	a0,0xb
ffffffffc0200ec6:	30650513          	addi	a0,a0,774 # ffffffffc020c1c8 <commands+0x4f0>
ffffffffc0200eca:	adcff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200ece:	6c4c                	ld	a1,152(s0)
ffffffffc0200ed0:	0000b517          	auipc	a0,0xb
ffffffffc0200ed4:	31050513          	addi	a0,a0,784 # ffffffffc020c1e0 <commands+0x508>
ffffffffc0200ed8:	aceff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200edc:	704c                	ld	a1,160(s0)
ffffffffc0200ede:	0000b517          	auipc	a0,0xb
ffffffffc0200ee2:	31a50513          	addi	a0,a0,794 # ffffffffc020c1f8 <commands+0x520>
ffffffffc0200ee6:	ac0ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200eea:	744c                	ld	a1,168(s0)
ffffffffc0200eec:	0000b517          	auipc	a0,0xb
ffffffffc0200ef0:	32450513          	addi	a0,a0,804 # ffffffffc020c210 <commands+0x538>
ffffffffc0200ef4:	ab2ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200ef8:	784c                	ld	a1,176(s0)
ffffffffc0200efa:	0000b517          	auipc	a0,0xb
ffffffffc0200efe:	32e50513          	addi	a0,a0,814 # ffffffffc020c228 <commands+0x550>
ffffffffc0200f02:	aa4ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200f06:	7c4c                	ld	a1,184(s0)
ffffffffc0200f08:	0000b517          	auipc	a0,0xb
ffffffffc0200f0c:	33850513          	addi	a0,a0,824 # ffffffffc020c240 <commands+0x568>
ffffffffc0200f10:	a96ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200f14:	606c                	ld	a1,192(s0)
ffffffffc0200f16:	0000b517          	auipc	a0,0xb
ffffffffc0200f1a:	34250513          	addi	a0,a0,834 # ffffffffc020c258 <commands+0x580>
ffffffffc0200f1e:	a88ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200f22:	646c                	ld	a1,200(s0)
ffffffffc0200f24:	0000b517          	auipc	a0,0xb
ffffffffc0200f28:	34c50513          	addi	a0,a0,844 # ffffffffc020c270 <commands+0x598>
ffffffffc0200f2c:	a7aff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200f30:	686c                	ld	a1,208(s0)
ffffffffc0200f32:	0000b517          	auipc	a0,0xb
ffffffffc0200f36:	35650513          	addi	a0,a0,854 # ffffffffc020c288 <commands+0x5b0>
ffffffffc0200f3a:	a6cff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200f3e:	6c6c                	ld	a1,216(s0)
ffffffffc0200f40:	0000b517          	auipc	a0,0xb
ffffffffc0200f44:	36050513          	addi	a0,a0,864 # ffffffffc020c2a0 <commands+0x5c8>
ffffffffc0200f48:	a5eff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200f4c:	706c                	ld	a1,224(s0)
ffffffffc0200f4e:	0000b517          	auipc	a0,0xb
ffffffffc0200f52:	36a50513          	addi	a0,a0,874 # ffffffffc020c2b8 <commands+0x5e0>
ffffffffc0200f56:	a50ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200f5a:	746c                	ld	a1,232(s0)
ffffffffc0200f5c:	0000b517          	auipc	a0,0xb
ffffffffc0200f60:	37450513          	addi	a0,a0,884 # ffffffffc020c2d0 <commands+0x5f8>
ffffffffc0200f64:	a42ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200f68:	786c                	ld	a1,240(s0)
ffffffffc0200f6a:	0000b517          	auipc	a0,0xb
ffffffffc0200f6e:	37e50513          	addi	a0,a0,894 # ffffffffc020c2e8 <commands+0x610>
ffffffffc0200f72:	a34ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200f76:	7c6c                	ld	a1,248(s0)
ffffffffc0200f78:	6402                	ld	s0,0(sp)
ffffffffc0200f7a:	60a2                	ld	ra,8(sp)
ffffffffc0200f7c:	0000b517          	auipc	a0,0xb
ffffffffc0200f80:	38450513          	addi	a0,a0,900 # ffffffffc020c300 <commands+0x628>
ffffffffc0200f84:	0141                	addi	sp,sp,16
ffffffffc0200f86:	a20ff06f          	j	ffffffffc02001a6 <cprintf>

ffffffffc0200f8a <print_trapframe>:
ffffffffc0200f8a:	1141                	addi	sp,sp,-16
ffffffffc0200f8c:	e022                	sd	s0,0(sp)
ffffffffc0200f8e:	85aa                	mv	a1,a0
ffffffffc0200f90:	842a                	mv	s0,a0
ffffffffc0200f92:	0000b517          	auipc	a0,0xb
ffffffffc0200f96:	38650513          	addi	a0,a0,902 # ffffffffc020c318 <commands+0x640>
ffffffffc0200f9a:	e406                	sd	ra,8(sp)
ffffffffc0200f9c:	a0aff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200fa0:	8522                	mv	a0,s0
ffffffffc0200fa2:	e1bff0ef          	jal	ra,ffffffffc0200dbc <print_regs>
ffffffffc0200fa6:	10043583          	ld	a1,256(s0)
ffffffffc0200faa:	0000b517          	auipc	a0,0xb
ffffffffc0200fae:	38650513          	addi	a0,a0,902 # ffffffffc020c330 <commands+0x658>
ffffffffc0200fb2:	9f4ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200fb6:	10843583          	ld	a1,264(s0)
ffffffffc0200fba:	0000b517          	auipc	a0,0xb
ffffffffc0200fbe:	38e50513          	addi	a0,a0,910 # ffffffffc020c348 <commands+0x670>
ffffffffc0200fc2:	9e4ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200fc6:	11043583          	ld	a1,272(s0)
ffffffffc0200fca:	0000b517          	auipc	a0,0xb
ffffffffc0200fce:	39650513          	addi	a0,a0,918 # ffffffffc020c360 <commands+0x688>
ffffffffc0200fd2:	9d4ff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0200fd6:	11843583          	ld	a1,280(s0)
ffffffffc0200fda:	6402                	ld	s0,0(sp)
ffffffffc0200fdc:	60a2                	ld	ra,8(sp)
ffffffffc0200fde:	0000b517          	auipc	a0,0xb
ffffffffc0200fe2:	39250513          	addi	a0,a0,914 # ffffffffc020c370 <commands+0x698>
ffffffffc0200fe6:	0141                	addi	sp,sp,16
ffffffffc0200fe8:	9beff06f          	j	ffffffffc02001a6 <cprintf>

ffffffffc0200fec <interrupt_handler>:
ffffffffc0200fec:	11853783          	ld	a5,280(a0)
ffffffffc0200ff0:	472d                	li	a4,11
ffffffffc0200ff2:	0786                	slli	a5,a5,0x1
ffffffffc0200ff4:	8385                	srli	a5,a5,0x1
ffffffffc0200ff6:	06f76c63          	bltu	a4,a5,ffffffffc020106e <interrupt_handler+0x82>
ffffffffc0200ffa:	0000b717          	auipc	a4,0xb
ffffffffc0200ffe:	42e70713          	addi	a4,a4,1070 # ffffffffc020c428 <commands+0x750>
ffffffffc0201002:	078a                	slli	a5,a5,0x2
ffffffffc0201004:	97ba                	add	a5,a5,a4
ffffffffc0201006:	439c                	lw	a5,0(a5)
ffffffffc0201008:	97ba                	add	a5,a5,a4
ffffffffc020100a:	8782                	jr	a5
ffffffffc020100c:	0000b517          	auipc	a0,0xb
ffffffffc0201010:	3dc50513          	addi	a0,a0,988 # ffffffffc020c3e8 <commands+0x710>
ffffffffc0201014:	992ff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc0201018:	0000b517          	auipc	a0,0xb
ffffffffc020101c:	3b050513          	addi	a0,a0,944 # ffffffffc020c3c8 <commands+0x6f0>
ffffffffc0201020:	986ff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc0201024:	0000b517          	auipc	a0,0xb
ffffffffc0201028:	36450513          	addi	a0,a0,868 # ffffffffc020c388 <commands+0x6b0>
ffffffffc020102c:	97aff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc0201030:	0000b517          	auipc	a0,0xb
ffffffffc0201034:	37850513          	addi	a0,a0,888 # ffffffffc020c3a8 <commands+0x6d0>
ffffffffc0201038:	96eff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc020103c:	1141                	addi	sp,sp,-16
ffffffffc020103e:	e406                	sd	ra,8(sp)
ffffffffc0201040:	d3aff0ef          	jal	ra,ffffffffc020057a <clock_set_next_event>
ffffffffc0201044:	00096717          	auipc	a4,0x96
ffffffffc0201048:	82c70713          	addi	a4,a4,-2004 # ffffffffc0296870 <ticks>
ffffffffc020104c:	631c                	ld	a5,0(a4)
ffffffffc020104e:	0785                	addi	a5,a5,1
ffffffffc0201050:	e31c                	sd	a5,0(a4)
ffffffffc0201052:	4c4060ef          	jal	ra,ffffffffc0207516 <run_timer_list>
ffffffffc0201056:	d9eff0ef          	jal	ra,ffffffffc02005f4 <cons_getc>
ffffffffc020105a:	60a2                	ld	ra,8(sp)
ffffffffc020105c:	0141                	addi	sp,sp,16
ffffffffc020105e:	6350706f          	j	ffffffffc0208e92 <dev_stdin_write>
ffffffffc0201062:	0000b517          	auipc	a0,0xb
ffffffffc0201066:	3a650513          	addi	a0,a0,934 # ffffffffc020c408 <commands+0x730>
ffffffffc020106a:	93cff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc020106e:	bf31                	j	ffffffffc0200f8a <print_trapframe>

ffffffffc0201070 <exception_handler>:
ffffffffc0201070:	11853783          	ld	a5,280(a0)
ffffffffc0201074:	1141                	addi	sp,sp,-16
ffffffffc0201076:	e022                	sd	s0,0(sp)
ffffffffc0201078:	e406                	sd	ra,8(sp)
ffffffffc020107a:	473d                	li	a4,15
ffffffffc020107c:	842a                	mv	s0,a0
ffffffffc020107e:	0af76b63          	bltu	a4,a5,ffffffffc0201134 <exception_handler+0xc4>
ffffffffc0201082:	0000b717          	auipc	a4,0xb
ffffffffc0201086:	56670713          	addi	a4,a4,1382 # ffffffffc020c5e8 <commands+0x910>
ffffffffc020108a:	078a                	slli	a5,a5,0x2
ffffffffc020108c:	97ba                	add	a5,a5,a4
ffffffffc020108e:	439c                	lw	a5,0(a5)
ffffffffc0201090:	97ba                	add	a5,a5,a4
ffffffffc0201092:	8782                	jr	a5
ffffffffc0201094:	0000b517          	auipc	a0,0xb
ffffffffc0201098:	4ac50513          	addi	a0,a0,1196 # ffffffffc020c540 <commands+0x868>
ffffffffc020109c:	90aff0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc02010a0:	10843783          	ld	a5,264(s0)
ffffffffc02010a4:	60a2                	ld	ra,8(sp)
ffffffffc02010a6:	0791                	addi	a5,a5,4
ffffffffc02010a8:	10f43423          	sd	a5,264(s0)
ffffffffc02010ac:	6402                	ld	s0,0(sp)
ffffffffc02010ae:	0141                	addi	sp,sp,16
ffffffffc02010b0:	67c0606f          	j	ffffffffc020772c <syscall>
ffffffffc02010b4:	0000b517          	auipc	a0,0xb
ffffffffc02010b8:	4ac50513          	addi	a0,a0,1196 # ffffffffc020c560 <commands+0x888>
ffffffffc02010bc:	6402                	ld	s0,0(sp)
ffffffffc02010be:	60a2                	ld	ra,8(sp)
ffffffffc02010c0:	0141                	addi	sp,sp,16
ffffffffc02010c2:	8e4ff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc02010c6:	0000b517          	auipc	a0,0xb
ffffffffc02010ca:	4ba50513          	addi	a0,a0,1210 # ffffffffc020c580 <commands+0x8a8>
ffffffffc02010ce:	b7fd                	j	ffffffffc02010bc <exception_handler+0x4c>
ffffffffc02010d0:	0000b517          	auipc	a0,0xb
ffffffffc02010d4:	4d050513          	addi	a0,a0,1232 # ffffffffc020c5a0 <commands+0x8c8>
ffffffffc02010d8:	b7d5                	j	ffffffffc02010bc <exception_handler+0x4c>
ffffffffc02010da:	0000b517          	auipc	a0,0xb
ffffffffc02010de:	4de50513          	addi	a0,a0,1246 # ffffffffc020c5b8 <commands+0x8e0>
ffffffffc02010e2:	bfe9                	j	ffffffffc02010bc <exception_handler+0x4c>
ffffffffc02010e4:	0000b517          	auipc	a0,0xb
ffffffffc02010e8:	4ec50513          	addi	a0,a0,1260 # ffffffffc020c5d0 <commands+0x8f8>
ffffffffc02010ec:	bfc1                	j	ffffffffc02010bc <exception_handler+0x4c>
ffffffffc02010ee:	0000b517          	auipc	a0,0xb
ffffffffc02010f2:	36a50513          	addi	a0,a0,874 # ffffffffc020c458 <commands+0x780>
ffffffffc02010f6:	b7d9                	j	ffffffffc02010bc <exception_handler+0x4c>
ffffffffc02010f8:	0000b517          	auipc	a0,0xb
ffffffffc02010fc:	38050513          	addi	a0,a0,896 # ffffffffc020c478 <commands+0x7a0>
ffffffffc0201100:	bf75                	j	ffffffffc02010bc <exception_handler+0x4c>
ffffffffc0201102:	0000b517          	auipc	a0,0xb
ffffffffc0201106:	39650513          	addi	a0,a0,918 # ffffffffc020c498 <commands+0x7c0>
ffffffffc020110a:	bf4d                	j	ffffffffc02010bc <exception_handler+0x4c>
ffffffffc020110c:	0000b517          	auipc	a0,0xb
ffffffffc0201110:	3a450513          	addi	a0,a0,932 # ffffffffc020c4b0 <commands+0x7d8>
ffffffffc0201114:	b765                	j	ffffffffc02010bc <exception_handler+0x4c>
ffffffffc0201116:	0000b517          	auipc	a0,0xb
ffffffffc020111a:	3aa50513          	addi	a0,a0,938 # ffffffffc020c4c0 <commands+0x7e8>
ffffffffc020111e:	bf79                	j	ffffffffc02010bc <exception_handler+0x4c>
ffffffffc0201120:	0000b517          	auipc	a0,0xb
ffffffffc0201124:	3c050513          	addi	a0,a0,960 # ffffffffc020c4e0 <commands+0x808>
ffffffffc0201128:	bf51                	j	ffffffffc02010bc <exception_handler+0x4c>
ffffffffc020112a:	0000b517          	auipc	a0,0xb
ffffffffc020112e:	3fe50513          	addi	a0,a0,1022 # ffffffffc020c528 <commands+0x850>
ffffffffc0201132:	b769                	j	ffffffffc02010bc <exception_handler+0x4c>
ffffffffc0201134:	8522                	mv	a0,s0
ffffffffc0201136:	6402                	ld	s0,0(sp)
ffffffffc0201138:	60a2                	ld	ra,8(sp)
ffffffffc020113a:	0141                	addi	sp,sp,16
ffffffffc020113c:	b5b9                	j	ffffffffc0200f8a <print_trapframe>
ffffffffc020113e:	0000b617          	auipc	a2,0xb
ffffffffc0201142:	3ba60613          	addi	a2,a2,954 # ffffffffc020c4f8 <commands+0x820>
ffffffffc0201146:	0b100593          	li	a1,177
ffffffffc020114a:	0000b517          	auipc	a0,0xb
ffffffffc020114e:	3c650513          	addi	a0,a0,966 # ffffffffc020c510 <commands+0x838>
ffffffffc0201152:	b4cff0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0201156 <trap>:
ffffffffc0201156:	1101                	addi	sp,sp,-32
ffffffffc0201158:	e822                	sd	s0,16(sp)
ffffffffc020115a:	00095417          	auipc	s0,0x95
ffffffffc020115e:	76640413          	addi	s0,s0,1894 # ffffffffc02968c0 <current>
ffffffffc0201162:	6018                	ld	a4,0(s0)
ffffffffc0201164:	ec06                	sd	ra,24(sp)
ffffffffc0201166:	e426                	sd	s1,8(sp)
ffffffffc0201168:	e04a                	sd	s2,0(sp)
ffffffffc020116a:	11853683          	ld	a3,280(a0)
ffffffffc020116e:	cf1d                	beqz	a4,ffffffffc02011ac <trap+0x56>
ffffffffc0201170:	10053483          	ld	s1,256(a0)
ffffffffc0201174:	0a073903          	ld	s2,160(a4)
ffffffffc0201178:	f348                	sd	a0,160(a4)
ffffffffc020117a:	1004f493          	andi	s1,s1,256
ffffffffc020117e:	0206c463          	bltz	a3,ffffffffc02011a6 <trap+0x50>
ffffffffc0201182:	eefff0ef          	jal	ra,ffffffffc0201070 <exception_handler>
ffffffffc0201186:	601c                	ld	a5,0(s0)
ffffffffc0201188:	0b27b023          	sd	s2,160(a5) # 400a0 <_binary_bin_swap_img_size+0x383a0>
ffffffffc020118c:	e499                	bnez	s1,ffffffffc020119a <trap+0x44>
ffffffffc020118e:	0b07a703          	lw	a4,176(a5)
ffffffffc0201192:	8b05                	andi	a4,a4,1
ffffffffc0201194:	e329                	bnez	a4,ffffffffc02011d6 <trap+0x80>
ffffffffc0201196:	6f9c                	ld	a5,24(a5)
ffffffffc0201198:	eb85                	bnez	a5,ffffffffc02011c8 <trap+0x72>
ffffffffc020119a:	60e2                	ld	ra,24(sp)
ffffffffc020119c:	6442                	ld	s0,16(sp)
ffffffffc020119e:	64a2                	ld	s1,8(sp)
ffffffffc02011a0:	6902                	ld	s2,0(sp)
ffffffffc02011a2:	6105                	addi	sp,sp,32
ffffffffc02011a4:	8082                	ret
ffffffffc02011a6:	e47ff0ef          	jal	ra,ffffffffc0200fec <interrupt_handler>
ffffffffc02011aa:	bff1                	j	ffffffffc0201186 <trap+0x30>
ffffffffc02011ac:	0006c863          	bltz	a3,ffffffffc02011bc <trap+0x66>
ffffffffc02011b0:	6442                	ld	s0,16(sp)
ffffffffc02011b2:	60e2                	ld	ra,24(sp)
ffffffffc02011b4:	64a2                	ld	s1,8(sp)
ffffffffc02011b6:	6902                	ld	s2,0(sp)
ffffffffc02011b8:	6105                	addi	sp,sp,32
ffffffffc02011ba:	bd5d                	j	ffffffffc0201070 <exception_handler>
ffffffffc02011bc:	6442                	ld	s0,16(sp)
ffffffffc02011be:	60e2                	ld	ra,24(sp)
ffffffffc02011c0:	64a2                	ld	s1,8(sp)
ffffffffc02011c2:	6902                	ld	s2,0(sp)
ffffffffc02011c4:	6105                	addi	sp,sp,32
ffffffffc02011c6:	b51d                	j	ffffffffc0200fec <interrupt_handler>
ffffffffc02011c8:	6442                	ld	s0,16(sp)
ffffffffc02011ca:	60e2                	ld	ra,24(sp)
ffffffffc02011cc:	64a2                	ld	s1,8(sp)
ffffffffc02011ce:	6902                	ld	s2,0(sp)
ffffffffc02011d0:	6105                	addi	sp,sp,32
ffffffffc02011d2:	1380606f          	j	ffffffffc020730a <schedule>
ffffffffc02011d6:	555d                	li	a0,-9
ffffffffc02011d8:	615040ef          	jal	ra,ffffffffc0205fec <do_exit>
ffffffffc02011dc:	601c                	ld	a5,0(s0)
ffffffffc02011de:	bf65                	j	ffffffffc0201196 <trap+0x40>

ffffffffc02011e0 <__alltraps>:
ffffffffc02011e0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc02011e4:	00011463          	bnez	sp,ffffffffc02011ec <__alltraps+0xc>
ffffffffc02011e8:	14002173          	csrr	sp,sscratch
ffffffffc02011ec:	712d                	addi	sp,sp,-288
ffffffffc02011ee:	e002                	sd	zero,0(sp)
ffffffffc02011f0:	e406                	sd	ra,8(sp)
ffffffffc02011f2:	ec0e                	sd	gp,24(sp)
ffffffffc02011f4:	f012                	sd	tp,32(sp)
ffffffffc02011f6:	f416                	sd	t0,40(sp)
ffffffffc02011f8:	f81a                	sd	t1,48(sp)
ffffffffc02011fa:	fc1e                	sd	t2,56(sp)
ffffffffc02011fc:	e0a2                	sd	s0,64(sp)
ffffffffc02011fe:	e4a6                	sd	s1,72(sp)
ffffffffc0201200:	e8aa                	sd	a0,80(sp)
ffffffffc0201202:	ecae                	sd	a1,88(sp)
ffffffffc0201204:	f0b2                	sd	a2,96(sp)
ffffffffc0201206:	f4b6                	sd	a3,104(sp)
ffffffffc0201208:	f8ba                	sd	a4,112(sp)
ffffffffc020120a:	fcbe                	sd	a5,120(sp)
ffffffffc020120c:	e142                	sd	a6,128(sp)
ffffffffc020120e:	e546                	sd	a7,136(sp)
ffffffffc0201210:	e94a                	sd	s2,144(sp)
ffffffffc0201212:	ed4e                	sd	s3,152(sp)
ffffffffc0201214:	f152                	sd	s4,160(sp)
ffffffffc0201216:	f556                	sd	s5,168(sp)
ffffffffc0201218:	f95a                	sd	s6,176(sp)
ffffffffc020121a:	fd5e                	sd	s7,184(sp)
ffffffffc020121c:	e1e2                	sd	s8,192(sp)
ffffffffc020121e:	e5e6                	sd	s9,200(sp)
ffffffffc0201220:	e9ea                	sd	s10,208(sp)
ffffffffc0201222:	edee                	sd	s11,216(sp)
ffffffffc0201224:	f1f2                	sd	t3,224(sp)
ffffffffc0201226:	f5f6                	sd	t4,232(sp)
ffffffffc0201228:	f9fa                	sd	t5,240(sp)
ffffffffc020122a:	fdfe                	sd	t6,248(sp)
ffffffffc020122c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0201230:	100024f3          	csrr	s1,sstatus
ffffffffc0201234:	14102973          	csrr	s2,sepc
ffffffffc0201238:	143029f3          	csrr	s3,stval
ffffffffc020123c:	14202a73          	csrr	s4,scause
ffffffffc0201240:	e822                	sd	s0,16(sp)
ffffffffc0201242:	e226                	sd	s1,256(sp)
ffffffffc0201244:	e64a                	sd	s2,264(sp)
ffffffffc0201246:	ea4e                	sd	s3,272(sp)
ffffffffc0201248:	ee52                	sd	s4,280(sp)
ffffffffc020124a:	850a                	mv	a0,sp
ffffffffc020124c:	f0bff0ef          	jal	ra,ffffffffc0201156 <trap>

ffffffffc0201250 <__trapret>:
ffffffffc0201250:	6492                	ld	s1,256(sp)
ffffffffc0201252:	6932                	ld	s2,264(sp)
ffffffffc0201254:	1004f413          	andi	s0,s1,256
ffffffffc0201258:	e401                	bnez	s0,ffffffffc0201260 <__trapret+0x10>
ffffffffc020125a:	1200                	addi	s0,sp,288
ffffffffc020125c:	14041073          	csrw	sscratch,s0
ffffffffc0201260:	10049073          	csrw	sstatus,s1
ffffffffc0201264:	14191073          	csrw	sepc,s2
ffffffffc0201268:	60a2                	ld	ra,8(sp)
ffffffffc020126a:	61e2                	ld	gp,24(sp)
ffffffffc020126c:	7202                	ld	tp,32(sp)
ffffffffc020126e:	72a2                	ld	t0,40(sp)
ffffffffc0201270:	7342                	ld	t1,48(sp)
ffffffffc0201272:	73e2                	ld	t2,56(sp)
ffffffffc0201274:	6406                	ld	s0,64(sp)
ffffffffc0201276:	64a6                	ld	s1,72(sp)
ffffffffc0201278:	6546                	ld	a0,80(sp)
ffffffffc020127a:	65e6                	ld	a1,88(sp)
ffffffffc020127c:	7606                	ld	a2,96(sp)
ffffffffc020127e:	76a6                	ld	a3,104(sp)
ffffffffc0201280:	7746                	ld	a4,112(sp)
ffffffffc0201282:	77e6                	ld	a5,120(sp)
ffffffffc0201284:	680a                	ld	a6,128(sp)
ffffffffc0201286:	68aa                	ld	a7,136(sp)
ffffffffc0201288:	694a                	ld	s2,144(sp)
ffffffffc020128a:	69ea                	ld	s3,152(sp)
ffffffffc020128c:	7a0a                	ld	s4,160(sp)
ffffffffc020128e:	7aaa                	ld	s5,168(sp)
ffffffffc0201290:	7b4a                	ld	s6,176(sp)
ffffffffc0201292:	7bea                	ld	s7,184(sp)
ffffffffc0201294:	6c0e                	ld	s8,192(sp)
ffffffffc0201296:	6cae                	ld	s9,200(sp)
ffffffffc0201298:	6d4e                	ld	s10,208(sp)
ffffffffc020129a:	6dee                	ld	s11,216(sp)
ffffffffc020129c:	7e0e                	ld	t3,224(sp)
ffffffffc020129e:	7eae                	ld	t4,232(sp)
ffffffffc02012a0:	7f4e                	ld	t5,240(sp)
ffffffffc02012a2:	7fee                	ld	t6,248(sp)
ffffffffc02012a4:	6142                	ld	sp,16(sp)
ffffffffc02012a6:	10200073          	sret

ffffffffc02012aa <forkrets>:
ffffffffc02012aa:	812a                	mv	sp,a0
ffffffffc02012ac:	b755                	j	ffffffffc0201250 <__trapret>

ffffffffc02012ae <default_init>:
ffffffffc02012ae:	00090797          	auipc	a5,0x90
ffffffffc02012b2:	4fa78793          	addi	a5,a5,1274 # ffffffffc02917a8 <free_area>
ffffffffc02012b6:	e79c                	sd	a5,8(a5)
ffffffffc02012b8:	e39c                	sd	a5,0(a5)
ffffffffc02012ba:	0007a823          	sw	zero,16(a5)
ffffffffc02012be:	8082                	ret

ffffffffc02012c0 <default_nr_free_pages>:
ffffffffc02012c0:	00090517          	auipc	a0,0x90
ffffffffc02012c4:	4f856503          	lwu	a0,1272(a0) # ffffffffc02917b8 <free_area+0x10>
ffffffffc02012c8:	8082                	ret

ffffffffc02012ca <default_check>:
ffffffffc02012ca:	715d                	addi	sp,sp,-80
ffffffffc02012cc:	e0a2                	sd	s0,64(sp)
ffffffffc02012ce:	00090417          	auipc	s0,0x90
ffffffffc02012d2:	4da40413          	addi	s0,s0,1242 # ffffffffc02917a8 <free_area>
ffffffffc02012d6:	641c                	ld	a5,8(s0)
ffffffffc02012d8:	e486                	sd	ra,72(sp)
ffffffffc02012da:	fc26                	sd	s1,56(sp)
ffffffffc02012dc:	f84a                	sd	s2,48(sp)
ffffffffc02012de:	f44e                	sd	s3,40(sp)
ffffffffc02012e0:	f052                	sd	s4,32(sp)
ffffffffc02012e2:	ec56                	sd	s5,24(sp)
ffffffffc02012e4:	e85a                	sd	s6,16(sp)
ffffffffc02012e6:	e45e                	sd	s7,8(sp)
ffffffffc02012e8:	e062                	sd	s8,0(sp)
ffffffffc02012ea:	2a878d63          	beq	a5,s0,ffffffffc02015a4 <default_check+0x2da>
ffffffffc02012ee:	4481                	li	s1,0
ffffffffc02012f0:	4901                	li	s2,0
ffffffffc02012f2:	ff07b703          	ld	a4,-16(a5)
ffffffffc02012f6:	8b09                	andi	a4,a4,2
ffffffffc02012f8:	2a070a63          	beqz	a4,ffffffffc02015ac <default_check+0x2e2>
ffffffffc02012fc:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201300:	679c                	ld	a5,8(a5)
ffffffffc0201302:	2905                	addiw	s2,s2,1
ffffffffc0201304:	9cb9                	addw	s1,s1,a4
ffffffffc0201306:	fe8796e3          	bne	a5,s0,ffffffffc02012f2 <default_check+0x28>
ffffffffc020130a:	89a6                	mv	s3,s1
ffffffffc020130c:	6df000ef          	jal	ra,ffffffffc02021ea <nr_free_pages>
ffffffffc0201310:	6f351e63          	bne	a0,s3,ffffffffc0201a0c <default_check+0x742>
ffffffffc0201314:	4505                	li	a0,1
ffffffffc0201316:	657000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc020131a:	8aaa                	mv	s5,a0
ffffffffc020131c:	42050863          	beqz	a0,ffffffffc020174c <default_check+0x482>
ffffffffc0201320:	4505                	li	a0,1
ffffffffc0201322:	64b000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc0201326:	89aa                	mv	s3,a0
ffffffffc0201328:	70050263          	beqz	a0,ffffffffc0201a2c <default_check+0x762>
ffffffffc020132c:	4505                	li	a0,1
ffffffffc020132e:	63f000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc0201332:	8a2a                	mv	s4,a0
ffffffffc0201334:	48050c63          	beqz	a0,ffffffffc02017cc <default_check+0x502>
ffffffffc0201338:	293a8a63          	beq	s5,s3,ffffffffc02015cc <default_check+0x302>
ffffffffc020133c:	28aa8863          	beq	s5,a0,ffffffffc02015cc <default_check+0x302>
ffffffffc0201340:	28a98663          	beq	s3,a0,ffffffffc02015cc <default_check+0x302>
ffffffffc0201344:	000aa783          	lw	a5,0(s5)
ffffffffc0201348:	2a079263          	bnez	a5,ffffffffc02015ec <default_check+0x322>
ffffffffc020134c:	0009a783          	lw	a5,0(s3)
ffffffffc0201350:	28079e63          	bnez	a5,ffffffffc02015ec <default_check+0x322>
ffffffffc0201354:	411c                	lw	a5,0(a0)
ffffffffc0201356:	28079b63          	bnez	a5,ffffffffc02015ec <default_check+0x322>
ffffffffc020135a:	00095797          	auipc	a5,0x95
ffffffffc020135e:	54e7b783          	ld	a5,1358(a5) # ffffffffc02968a8 <pages>
ffffffffc0201362:	40fa8733          	sub	a4,s5,a5
ffffffffc0201366:	0000f617          	auipc	a2,0xf
ffffffffc020136a:	a6a63603          	ld	a2,-1430(a2) # ffffffffc020fdd0 <nbase>
ffffffffc020136e:	8719                	srai	a4,a4,0x6
ffffffffc0201370:	9732                	add	a4,a4,a2
ffffffffc0201372:	00095697          	auipc	a3,0x95
ffffffffc0201376:	52e6b683          	ld	a3,1326(a3) # ffffffffc02968a0 <npage>
ffffffffc020137a:	06b2                	slli	a3,a3,0xc
ffffffffc020137c:	0732                	slli	a4,a4,0xc
ffffffffc020137e:	28d77763          	bgeu	a4,a3,ffffffffc020160c <default_check+0x342>
ffffffffc0201382:	40f98733          	sub	a4,s3,a5
ffffffffc0201386:	8719                	srai	a4,a4,0x6
ffffffffc0201388:	9732                	add	a4,a4,a2
ffffffffc020138a:	0732                	slli	a4,a4,0xc
ffffffffc020138c:	4cd77063          	bgeu	a4,a3,ffffffffc020184c <default_check+0x582>
ffffffffc0201390:	40f507b3          	sub	a5,a0,a5
ffffffffc0201394:	8799                	srai	a5,a5,0x6
ffffffffc0201396:	97b2                	add	a5,a5,a2
ffffffffc0201398:	07b2                	slli	a5,a5,0xc
ffffffffc020139a:	30d7f963          	bgeu	a5,a3,ffffffffc02016ac <default_check+0x3e2>
ffffffffc020139e:	4505                	li	a0,1
ffffffffc02013a0:	00043c03          	ld	s8,0(s0)
ffffffffc02013a4:	00843b83          	ld	s7,8(s0)
ffffffffc02013a8:	01042b03          	lw	s6,16(s0)
ffffffffc02013ac:	e400                	sd	s0,8(s0)
ffffffffc02013ae:	e000                	sd	s0,0(s0)
ffffffffc02013b0:	00090797          	auipc	a5,0x90
ffffffffc02013b4:	4007a423          	sw	zero,1032(a5) # ffffffffc02917b8 <free_area+0x10>
ffffffffc02013b8:	5b5000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc02013bc:	2c051863          	bnez	a0,ffffffffc020168c <default_check+0x3c2>
ffffffffc02013c0:	4585                	li	a1,1
ffffffffc02013c2:	8556                	mv	a0,s5
ffffffffc02013c4:	5e7000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc02013c8:	4585                	li	a1,1
ffffffffc02013ca:	854e                	mv	a0,s3
ffffffffc02013cc:	5df000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc02013d0:	4585                	li	a1,1
ffffffffc02013d2:	8552                	mv	a0,s4
ffffffffc02013d4:	5d7000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc02013d8:	4818                	lw	a4,16(s0)
ffffffffc02013da:	478d                	li	a5,3
ffffffffc02013dc:	28f71863          	bne	a4,a5,ffffffffc020166c <default_check+0x3a2>
ffffffffc02013e0:	4505                	li	a0,1
ffffffffc02013e2:	58b000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc02013e6:	89aa                	mv	s3,a0
ffffffffc02013e8:	26050263          	beqz	a0,ffffffffc020164c <default_check+0x382>
ffffffffc02013ec:	4505                	li	a0,1
ffffffffc02013ee:	57f000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc02013f2:	8aaa                	mv	s5,a0
ffffffffc02013f4:	3a050c63          	beqz	a0,ffffffffc02017ac <default_check+0x4e2>
ffffffffc02013f8:	4505                	li	a0,1
ffffffffc02013fa:	573000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc02013fe:	8a2a                	mv	s4,a0
ffffffffc0201400:	38050663          	beqz	a0,ffffffffc020178c <default_check+0x4c2>
ffffffffc0201404:	4505                	li	a0,1
ffffffffc0201406:	567000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc020140a:	36051163          	bnez	a0,ffffffffc020176c <default_check+0x4a2>
ffffffffc020140e:	4585                	li	a1,1
ffffffffc0201410:	854e                	mv	a0,s3
ffffffffc0201412:	599000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc0201416:	641c                	ld	a5,8(s0)
ffffffffc0201418:	20878a63          	beq	a5,s0,ffffffffc020162c <default_check+0x362>
ffffffffc020141c:	4505                	li	a0,1
ffffffffc020141e:	54f000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc0201422:	30a99563          	bne	s3,a0,ffffffffc020172c <default_check+0x462>
ffffffffc0201426:	4505                	li	a0,1
ffffffffc0201428:	545000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc020142c:	2e051063          	bnez	a0,ffffffffc020170c <default_check+0x442>
ffffffffc0201430:	481c                	lw	a5,16(s0)
ffffffffc0201432:	2a079d63          	bnez	a5,ffffffffc02016ec <default_check+0x422>
ffffffffc0201436:	854e                	mv	a0,s3
ffffffffc0201438:	4585                	li	a1,1
ffffffffc020143a:	01843023          	sd	s8,0(s0)
ffffffffc020143e:	01743423          	sd	s7,8(s0)
ffffffffc0201442:	01642823          	sw	s6,16(s0)
ffffffffc0201446:	565000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc020144a:	4585                	li	a1,1
ffffffffc020144c:	8556                	mv	a0,s5
ffffffffc020144e:	55d000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc0201452:	4585                	li	a1,1
ffffffffc0201454:	8552                	mv	a0,s4
ffffffffc0201456:	555000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc020145a:	4515                	li	a0,5
ffffffffc020145c:	511000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc0201460:	89aa                	mv	s3,a0
ffffffffc0201462:	26050563          	beqz	a0,ffffffffc02016cc <default_check+0x402>
ffffffffc0201466:	651c                	ld	a5,8(a0)
ffffffffc0201468:	8385                	srli	a5,a5,0x1
ffffffffc020146a:	8b85                	andi	a5,a5,1
ffffffffc020146c:	54079063          	bnez	a5,ffffffffc02019ac <default_check+0x6e2>
ffffffffc0201470:	4505                	li	a0,1
ffffffffc0201472:	00043b03          	ld	s6,0(s0)
ffffffffc0201476:	00843a83          	ld	s5,8(s0)
ffffffffc020147a:	e000                	sd	s0,0(s0)
ffffffffc020147c:	e400                	sd	s0,8(s0)
ffffffffc020147e:	4ef000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc0201482:	50051563          	bnez	a0,ffffffffc020198c <default_check+0x6c2>
ffffffffc0201486:	08098a13          	addi	s4,s3,128
ffffffffc020148a:	8552                	mv	a0,s4
ffffffffc020148c:	458d                	li	a1,3
ffffffffc020148e:	01042b83          	lw	s7,16(s0)
ffffffffc0201492:	00090797          	auipc	a5,0x90
ffffffffc0201496:	3207a323          	sw	zero,806(a5) # ffffffffc02917b8 <free_area+0x10>
ffffffffc020149a:	511000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc020149e:	4511                	li	a0,4
ffffffffc02014a0:	4cd000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc02014a4:	4c051463          	bnez	a0,ffffffffc020196c <default_check+0x6a2>
ffffffffc02014a8:	0889b783          	ld	a5,136(s3)
ffffffffc02014ac:	8385                	srli	a5,a5,0x1
ffffffffc02014ae:	8b85                	andi	a5,a5,1
ffffffffc02014b0:	48078e63          	beqz	a5,ffffffffc020194c <default_check+0x682>
ffffffffc02014b4:	0909a703          	lw	a4,144(s3)
ffffffffc02014b8:	478d                	li	a5,3
ffffffffc02014ba:	48f71963          	bne	a4,a5,ffffffffc020194c <default_check+0x682>
ffffffffc02014be:	450d                	li	a0,3
ffffffffc02014c0:	4ad000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc02014c4:	8c2a                	mv	s8,a0
ffffffffc02014c6:	46050363          	beqz	a0,ffffffffc020192c <default_check+0x662>
ffffffffc02014ca:	4505                	li	a0,1
ffffffffc02014cc:	4a1000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc02014d0:	42051e63          	bnez	a0,ffffffffc020190c <default_check+0x642>
ffffffffc02014d4:	418a1c63          	bne	s4,s8,ffffffffc02018ec <default_check+0x622>
ffffffffc02014d8:	4585                	li	a1,1
ffffffffc02014da:	854e                	mv	a0,s3
ffffffffc02014dc:	4cf000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc02014e0:	458d                	li	a1,3
ffffffffc02014e2:	8552                	mv	a0,s4
ffffffffc02014e4:	4c7000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc02014e8:	0089b783          	ld	a5,8(s3)
ffffffffc02014ec:	04098c13          	addi	s8,s3,64
ffffffffc02014f0:	8385                	srli	a5,a5,0x1
ffffffffc02014f2:	8b85                	andi	a5,a5,1
ffffffffc02014f4:	3c078c63          	beqz	a5,ffffffffc02018cc <default_check+0x602>
ffffffffc02014f8:	0109a703          	lw	a4,16(s3)
ffffffffc02014fc:	4785                	li	a5,1
ffffffffc02014fe:	3cf71763          	bne	a4,a5,ffffffffc02018cc <default_check+0x602>
ffffffffc0201502:	008a3783          	ld	a5,8(s4)
ffffffffc0201506:	8385                	srli	a5,a5,0x1
ffffffffc0201508:	8b85                	andi	a5,a5,1
ffffffffc020150a:	3a078163          	beqz	a5,ffffffffc02018ac <default_check+0x5e2>
ffffffffc020150e:	010a2703          	lw	a4,16(s4)
ffffffffc0201512:	478d                	li	a5,3
ffffffffc0201514:	38f71c63          	bne	a4,a5,ffffffffc02018ac <default_check+0x5e2>
ffffffffc0201518:	4505                	li	a0,1
ffffffffc020151a:	453000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc020151e:	36a99763          	bne	s3,a0,ffffffffc020188c <default_check+0x5c2>
ffffffffc0201522:	4585                	li	a1,1
ffffffffc0201524:	487000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc0201528:	4509                	li	a0,2
ffffffffc020152a:	443000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc020152e:	32aa1f63          	bne	s4,a0,ffffffffc020186c <default_check+0x5a2>
ffffffffc0201532:	4589                	li	a1,2
ffffffffc0201534:	477000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc0201538:	4585                	li	a1,1
ffffffffc020153a:	8562                	mv	a0,s8
ffffffffc020153c:	46f000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc0201540:	4515                	li	a0,5
ffffffffc0201542:	42b000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc0201546:	89aa                	mv	s3,a0
ffffffffc0201548:	48050263          	beqz	a0,ffffffffc02019cc <default_check+0x702>
ffffffffc020154c:	4505                	li	a0,1
ffffffffc020154e:	41f000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc0201552:	2c051d63          	bnez	a0,ffffffffc020182c <default_check+0x562>
ffffffffc0201556:	481c                	lw	a5,16(s0)
ffffffffc0201558:	2a079a63          	bnez	a5,ffffffffc020180c <default_check+0x542>
ffffffffc020155c:	4595                	li	a1,5
ffffffffc020155e:	854e                	mv	a0,s3
ffffffffc0201560:	01742823          	sw	s7,16(s0)
ffffffffc0201564:	01643023          	sd	s6,0(s0)
ffffffffc0201568:	01543423          	sd	s5,8(s0)
ffffffffc020156c:	43f000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc0201570:	641c                	ld	a5,8(s0)
ffffffffc0201572:	00878963          	beq	a5,s0,ffffffffc0201584 <default_check+0x2ba>
ffffffffc0201576:	ff87a703          	lw	a4,-8(a5)
ffffffffc020157a:	679c                	ld	a5,8(a5)
ffffffffc020157c:	397d                	addiw	s2,s2,-1
ffffffffc020157e:	9c99                	subw	s1,s1,a4
ffffffffc0201580:	fe879be3          	bne	a5,s0,ffffffffc0201576 <default_check+0x2ac>
ffffffffc0201584:	26091463          	bnez	s2,ffffffffc02017ec <default_check+0x522>
ffffffffc0201588:	46049263          	bnez	s1,ffffffffc02019ec <default_check+0x722>
ffffffffc020158c:	60a6                	ld	ra,72(sp)
ffffffffc020158e:	6406                	ld	s0,64(sp)
ffffffffc0201590:	74e2                	ld	s1,56(sp)
ffffffffc0201592:	7942                	ld	s2,48(sp)
ffffffffc0201594:	79a2                	ld	s3,40(sp)
ffffffffc0201596:	7a02                	ld	s4,32(sp)
ffffffffc0201598:	6ae2                	ld	s5,24(sp)
ffffffffc020159a:	6b42                	ld	s6,16(sp)
ffffffffc020159c:	6ba2                	ld	s7,8(sp)
ffffffffc020159e:	6c02                	ld	s8,0(sp)
ffffffffc02015a0:	6161                	addi	sp,sp,80
ffffffffc02015a2:	8082                	ret
ffffffffc02015a4:	4981                	li	s3,0
ffffffffc02015a6:	4481                	li	s1,0
ffffffffc02015a8:	4901                	li	s2,0
ffffffffc02015aa:	b38d                	j	ffffffffc020130c <default_check+0x42>
ffffffffc02015ac:	0000b697          	auipc	a3,0xb
ffffffffc02015b0:	07c68693          	addi	a3,a3,124 # ffffffffc020c628 <commands+0x950>
ffffffffc02015b4:	0000b617          	auipc	a2,0xb
ffffffffc02015b8:	93460613          	addi	a2,a2,-1740 # ffffffffc020bee8 <commands+0x210>
ffffffffc02015bc:	0ef00593          	li	a1,239
ffffffffc02015c0:	0000b517          	auipc	a0,0xb
ffffffffc02015c4:	07850513          	addi	a0,a0,120 # ffffffffc020c638 <commands+0x960>
ffffffffc02015c8:	ed7fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02015cc:	0000b697          	auipc	a3,0xb
ffffffffc02015d0:	10468693          	addi	a3,a3,260 # ffffffffc020c6d0 <commands+0x9f8>
ffffffffc02015d4:	0000b617          	auipc	a2,0xb
ffffffffc02015d8:	91460613          	addi	a2,a2,-1772 # ffffffffc020bee8 <commands+0x210>
ffffffffc02015dc:	0bc00593          	li	a1,188
ffffffffc02015e0:	0000b517          	auipc	a0,0xb
ffffffffc02015e4:	05850513          	addi	a0,a0,88 # ffffffffc020c638 <commands+0x960>
ffffffffc02015e8:	eb7fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02015ec:	0000b697          	auipc	a3,0xb
ffffffffc02015f0:	10c68693          	addi	a3,a3,268 # ffffffffc020c6f8 <commands+0xa20>
ffffffffc02015f4:	0000b617          	auipc	a2,0xb
ffffffffc02015f8:	8f460613          	addi	a2,a2,-1804 # ffffffffc020bee8 <commands+0x210>
ffffffffc02015fc:	0bd00593          	li	a1,189
ffffffffc0201600:	0000b517          	auipc	a0,0xb
ffffffffc0201604:	03850513          	addi	a0,a0,56 # ffffffffc020c638 <commands+0x960>
ffffffffc0201608:	e97fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020160c:	0000b697          	auipc	a3,0xb
ffffffffc0201610:	12c68693          	addi	a3,a3,300 # ffffffffc020c738 <commands+0xa60>
ffffffffc0201614:	0000b617          	auipc	a2,0xb
ffffffffc0201618:	8d460613          	addi	a2,a2,-1836 # ffffffffc020bee8 <commands+0x210>
ffffffffc020161c:	0bf00593          	li	a1,191
ffffffffc0201620:	0000b517          	auipc	a0,0xb
ffffffffc0201624:	01850513          	addi	a0,a0,24 # ffffffffc020c638 <commands+0x960>
ffffffffc0201628:	e77fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020162c:	0000b697          	auipc	a3,0xb
ffffffffc0201630:	19468693          	addi	a3,a3,404 # ffffffffc020c7c0 <commands+0xae8>
ffffffffc0201634:	0000b617          	auipc	a2,0xb
ffffffffc0201638:	8b460613          	addi	a2,a2,-1868 # ffffffffc020bee8 <commands+0x210>
ffffffffc020163c:	0d800593          	li	a1,216
ffffffffc0201640:	0000b517          	auipc	a0,0xb
ffffffffc0201644:	ff850513          	addi	a0,a0,-8 # ffffffffc020c638 <commands+0x960>
ffffffffc0201648:	e57fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020164c:	0000b697          	auipc	a3,0xb
ffffffffc0201650:	02468693          	addi	a3,a3,36 # ffffffffc020c670 <commands+0x998>
ffffffffc0201654:	0000b617          	auipc	a2,0xb
ffffffffc0201658:	89460613          	addi	a2,a2,-1900 # ffffffffc020bee8 <commands+0x210>
ffffffffc020165c:	0d100593          	li	a1,209
ffffffffc0201660:	0000b517          	auipc	a0,0xb
ffffffffc0201664:	fd850513          	addi	a0,a0,-40 # ffffffffc020c638 <commands+0x960>
ffffffffc0201668:	e37fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020166c:	0000b697          	auipc	a3,0xb
ffffffffc0201670:	14468693          	addi	a3,a3,324 # ffffffffc020c7b0 <commands+0xad8>
ffffffffc0201674:	0000b617          	auipc	a2,0xb
ffffffffc0201678:	87460613          	addi	a2,a2,-1932 # ffffffffc020bee8 <commands+0x210>
ffffffffc020167c:	0cf00593          	li	a1,207
ffffffffc0201680:	0000b517          	auipc	a0,0xb
ffffffffc0201684:	fb850513          	addi	a0,a0,-72 # ffffffffc020c638 <commands+0x960>
ffffffffc0201688:	e17fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020168c:	0000b697          	auipc	a3,0xb
ffffffffc0201690:	10c68693          	addi	a3,a3,268 # ffffffffc020c798 <commands+0xac0>
ffffffffc0201694:	0000b617          	auipc	a2,0xb
ffffffffc0201698:	85460613          	addi	a2,a2,-1964 # ffffffffc020bee8 <commands+0x210>
ffffffffc020169c:	0ca00593          	li	a1,202
ffffffffc02016a0:	0000b517          	auipc	a0,0xb
ffffffffc02016a4:	f9850513          	addi	a0,a0,-104 # ffffffffc020c638 <commands+0x960>
ffffffffc02016a8:	df7fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02016ac:	0000b697          	auipc	a3,0xb
ffffffffc02016b0:	0cc68693          	addi	a3,a3,204 # ffffffffc020c778 <commands+0xaa0>
ffffffffc02016b4:	0000b617          	auipc	a2,0xb
ffffffffc02016b8:	83460613          	addi	a2,a2,-1996 # ffffffffc020bee8 <commands+0x210>
ffffffffc02016bc:	0c100593          	li	a1,193
ffffffffc02016c0:	0000b517          	auipc	a0,0xb
ffffffffc02016c4:	f7850513          	addi	a0,a0,-136 # ffffffffc020c638 <commands+0x960>
ffffffffc02016c8:	dd7fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02016cc:	0000b697          	auipc	a3,0xb
ffffffffc02016d0:	13c68693          	addi	a3,a3,316 # ffffffffc020c808 <commands+0xb30>
ffffffffc02016d4:	0000b617          	auipc	a2,0xb
ffffffffc02016d8:	81460613          	addi	a2,a2,-2028 # ffffffffc020bee8 <commands+0x210>
ffffffffc02016dc:	0f700593          	li	a1,247
ffffffffc02016e0:	0000b517          	auipc	a0,0xb
ffffffffc02016e4:	f5850513          	addi	a0,a0,-168 # ffffffffc020c638 <commands+0x960>
ffffffffc02016e8:	db7fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02016ec:	0000b697          	auipc	a3,0xb
ffffffffc02016f0:	10c68693          	addi	a3,a3,268 # ffffffffc020c7f8 <commands+0xb20>
ffffffffc02016f4:	0000a617          	auipc	a2,0xa
ffffffffc02016f8:	7f460613          	addi	a2,a2,2036 # ffffffffc020bee8 <commands+0x210>
ffffffffc02016fc:	0de00593          	li	a1,222
ffffffffc0201700:	0000b517          	auipc	a0,0xb
ffffffffc0201704:	f3850513          	addi	a0,a0,-200 # ffffffffc020c638 <commands+0x960>
ffffffffc0201708:	d97fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020170c:	0000b697          	auipc	a3,0xb
ffffffffc0201710:	08c68693          	addi	a3,a3,140 # ffffffffc020c798 <commands+0xac0>
ffffffffc0201714:	0000a617          	auipc	a2,0xa
ffffffffc0201718:	7d460613          	addi	a2,a2,2004 # ffffffffc020bee8 <commands+0x210>
ffffffffc020171c:	0dc00593          	li	a1,220
ffffffffc0201720:	0000b517          	auipc	a0,0xb
ffffffffc0201724:	f1850513          	addi	a0,a0,-232 # ffffffffc020c638 <commands+0x960>
ffffffffc0201728:	d77fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020172c:	0000b697          	auipc	a3,0xb
ffffffffc0201730:	0ac68693          	addi	a3,a3,172 # ffffffffc020c7d8 <commands+0xb00>
ffffffffc0201734:	0000a617          	auipc	a2,0xa
ffffffffc0201738:	7b460613          	addi	a2,a2,1972 # ffffffffc020bee8 <commands+0x210>
ffffffffc020173c:	0db00593          	li	a1,219
ffffffffc0201740:	0000b517          	auipc	a0,0xb
ffffffffc0201744:	ef850513          	addi	a0,a0,-264 # ffffffffc020c638 <commands+0x960>
ffffffffc0201748:	d57fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020174c:	0000b697          	auipc	a3,0xb
ffffffffc0201750:	f2468693          	addi	a3,a3,-220 # ffffffffc020c670 <commands+0x998>
ffffffffc0201754:	0000a617          	auipc	a2,0xa
ffffffffc0201758:	79460613          	addi	a2,a2,1940 # ffffffffc020bee8 <commands+0x210>
ffffffffc020175c:	0b800593          	li	a1,184
ffffffffc0201760:	0000b517          	auipc	a0,0xb
ffffffffc0201764:	ed850513          	addi	a0,a0,-296 # ffffffffc020c638 <commands+0x960>
ffffffffc0201768:	d37fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020176c:	0000b697          	auipc	a3,0xb
ffffffffc0201770:	02c68693          	addi	a3,a3,44 # ffffffffc020c798 <commands+0xac0>
ffffffffc0201774:	0000a617          	auipc	a2,0xa
ffffffffc0201778:	77460613          	addi	a2,a2,1908 # ffffffffc020bee8 <commands+0x210>
ffffffffc020177c:	0d500593          	li	a1,213
ffffffffc0201780:	0000b517          	auipc	a0,0xb
ffffffffc0201784:	eb850513          	addi	a0,a0,-328 # ffffffffc020c638 <commands+0x960>
ffffffffc0201788:	d17fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020178c:	0000b697          	auipc	a3,0xb
ffffffffc0201790:	f2468693          	addi	a3,a3,-220 # ffffffffc020c6b0 <commands+0x9d8>
ffffffffc0201794:	0000a617          	auipc	a2,0xa
ffffffffc0201798:	75460613          	addi	a2,a2,1876 # ffffffffc020bee8 <commands+0x210>
ffffffffc020179c:	0d300593          	li	a1,211
ffffffffc02017a0:	0000b517          	auipc	a0,0xb
ffffffffc02017a4:	e9850513          	addi	a0,a0,-360 # ffffffffc020c638 <commands+0x960>
ffffffffc02017a8:	cf7fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02017ac:	0000b697          	auipc	a3,0xb
ffffffffc02017b0:	ee468693          	addi	a3,a3,-284 # ffffffffc020c690 <commands+0x9b8>
ffffffffc02017b4:	0000a617          	auipc	a2,0xa
ffffffffc02017b8:	73460613          	addi	a2,a2,1844 # ffffffffc020bee8 <commands+0x210>
ffffffffc02017bc:	0d200593          	li	a1,210
ffffffffc02017c0:	0000b517          	auipc	a0,0xb
ffffffffc02017c4:	e7850513          	addi	a0,a0,-392 # ffffffffc020c638 <commands+0x960>
ffffffffc02017c8:	cd7fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02017cc:	0000b697          	auipc	a3,0xb
ffffffffc02017d0:	ee468693          	addi	a3,a3,-284 # ffffffffc020c6b0 <commands+0x9d8>
ffffffffc02017d4:	0000a617          	auipc	a2,0xa
ffffffffc02017d8:	71460613          	addi	a2,a2,1812 # ffffffffc020bee8 <commands+0x210>
ffffffffc02017dc:	0ba00593          	li	a1,186
ffffffffc02017e0:	0000b517          	auipc	a0,0xb
ffffffffc02017e4:	e5850513          	addi	a0,a0,-424 # ffffffffc020c638 <commands+0x960>
ffffffffc02017e8:	cb7fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02017ec:	0000b697          	auipc	a3,0xb
ffffffffc02017f0:	16c68693          	addi	a3,a3,364 # ffffffffc020c958 <commands+0xc80>
ffffffffc02017f4:	0000a617          	auipc	a2,0xa
ffffffffc02017f8:	6f460613          	addi	a2,a2,1780 # ffffffffc020bee8 <commands+0x210>
ffffffffc02017fc:	12400593          	li	a1,292
ffffffffc0201800:	0000b517          	auipc	a0,0xb
ffffffffc0201804:	e3850513          	addi	a0,a0,-456 # ffffffffc020c638 <commands+0x960>
ffffffffc0201808:	c97fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020180c:	0000b697          	auipc	a3,0xb
ffffffffc0201810:	fec68693          	addi	a3,a3,-20 # ffffffffc020c7f8 <commands+0xb20>
ffffffffc0201814:	0000a617          	auipc	a2,0xa
ffffffffc0201818:	6d460613          	addi	a2,a2,1748 # ffffffffc020bee8 <commands+0x210>
ffffffffc020181c:	11900593          	li	a1,281
ffffffffc0201820:	0000b517          	auipc	a0,0xb
ffffffffc0201824:	e1850513          	addi	a0,a0,-488 # ffffffffc020c638 <commands+0x960>
ffffffffc0201828:	c77fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020182c:	0000b697          	auipc	a3,0xb
ffffffffc0201830:	f6c68693          	addi	a3,a3,-148 # ffffffffc020c798 <commands+0xac0>
ffffffffc0201834:	0000a617          	auipc	a2,0xa
ffffffffc0201838:	6b460613          	addi	a2,a2,1716 # ffffffffc020bee8 <commands+0x210>
ffffffffc020183c:	11700593          	li	a1,279
ffffffffc0201840:	0000b517          	auipc	a0,0xb
ffffffffc0201844:	df850513          	addi	a0,a0,-520 # ffffffffc020c638 <commands+0x960>
ffffffffc0201848:	c57fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020184c:	0000b697          	auipc	a3,0xb
ffffffffc0201850:	f0c68693          	addi	a3,a3,-244 # ffffffffc020c758 <commands+0xa80>
ffffffffc0201854:	0000a617          	auipc	a2,0xa
ffffffffc0201858:	69460613          	addi	a2,a2,1684 # ffffffffc020bee8 <commands+0x210>
ffffffffc020185c:	0c000593          	li	a1,192
ffffffffc0201860:	0000b517          	auipc	a0,0xb
ffffffffc0201864:	dd850513          	addi	a0,a0,-552 # ffffffffc020c638 <commands+0x960>
ffffffffc0201868:	c37fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020186c:	0000b697          	auipc	a3,0xb
ffffffffc0201870:	0ac68693          	addi	a3,a3,172 # ffffffffc020c918 <commands+0xc40>
ffffffffc0201874:	0000a617          	auipc	a2,0xa
ffffffffc0201878:	67460613          	addi	a2,a2,1652 # ffffffffc020bee8 <commands+0x210>
ffffffffc020187c:	11100593          	li	a1,273
ffffffffc0201880:	0000b517          	auipc	a0,0xb
ffffffffc0201884:	db850513          	addi	a0,a0,-584 # ffffffffc020c638 <commands+0x960>
ffffffffc0201888:	c17fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020188c:	0000b697          	auipc	a3,0xb
ffffffffc0201890:	06c68693          	addi	a3,a3,108 # ffffffffc020c8f8 <commands+0xc20>
ffffffffc0201894:	0000a617          	auipc	a2,0xa
ffffffffc0201898:	65460613          	addi	a2,a2,1620 # ffffffffc020bee8 <commands+0x210>
ffffffffc020189c:	10f00593          	li	a1,271
ffffffffc02018a0:	0000b517          	auipc	a0,0xb
ffffffffc02018a4:	d9850513          	addi	a0,a0,-616 # ffffffffc020c638 <commands+0x960>
ffffffffc02018a8:	bf7fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02018ac:	0000b697          	auipc	a3,0xb
ffffffffc02018b0:	02468693          	addi	a3,a3,36 # ffffffffc020c8d0 <commands+0xbf8>
ffffffffc02018b4:	0000a617          	auipc	a2,0xa
ffffffffc02018b8:	63460613          	addi	a2,a2,1588 # ffffffffc020bee8 <commands+0x210>
ffffffffc02018bc:	10d00593          	li	a1,269
ffffffffc02018c0:	0000b517          	auipc	a0,0xb
ffffffffc02018c4:	d7850513          	addi	a0,a0,-648 # ffffffffc020c638 <commands+0x960>
ffffffffc02018c8:	bd7fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02018cc:	0000b697          	auipc	a3,0xb
ffffffffc02018d0:	fdc68693          	addi	a3,a3,-36 # ffffffffc020c8a8 <commands+0xbd0>
ffffffffc02018d4:	0000a617          	auipc	a2,0xa
ffffffffc02018d8:	61460613          	addi	a2,a2,1556 # ffffffffc020bee8 <commands+0x210>
ffffffffc02018dc:	10c00593          	li	a1,268
ffffffffc02018e0:	0000b517          	auipc	a0,0xb
ffffffffc02018e4:	d5850513          	addi	a0,a0,-680 # ffffffffc020c638 <commands+0x960>
ffffffffc02018e8:	bb7fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02018ec:	0000b697          	auipc	a3,0xb
ffffffffc02018f0:	fac68693          	addi	a3,a3,-84 # ffffffffc020c898 <commands+0xbc0>
ffffffffc02018f4:	0000a617          	auipc	a2,0xa
ffffffffc02018f8:	5f460613          	addi	a2,a2,1524 # ffffffffc020bee8 <commands+0x210>
ffffffffc02018fc:	10700593          	li	a1,263
ffffffffc0201900:	0000b517          	auipc	a0,0xb
ffffffffc0201904:	d3850513          	addi	a0,a0,-712 # ffffffffc020c638 <commands+0x960>
ffffffffc0201908:	b97fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020190c:	0000b697          	auipc	a3,0xb
ffffffffc0201910:	e8c68693          	addi	a3,a3,-372 # ffffffffc020c798 <commands+0xac0>
ffffffffc0201914:	0000a617          	auipc	a2,0xa
ffffffffc0201918:	5d460613          	addi	a2,a2,1492 # ffffffffc020bee8 <commands+0x210>
ffffffffc020191c:	10600593          	li	a1,262
ffffffffc0201920:	0000b517          	auipc	a0,0xb
ffffffffc0201924:	d1850513          	addi	a0,a0,-744 # ffffffffc020c638 <commands+0x960>
ffffffffc0201928:	b77fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020192c:	0000b697          	auipc	a3,0xb
ffffffffc0201930:	f4c68693          	addi	a3,a3,-180 # ffffffffc020c878 <commands+0xba0>
ffffffffc0201934:	0000a617          	auipc	a2,0xa
ffffffffc0201938:	5b460613          	addi	a2,a2,1460 # ffffffffc020bee8 <commands+0x210>
ffffffffc020193c:	10500593          	li	a1,261
ffffffffc0201940:	0000b517          	auipc	a0,0xb
ffffffffc0201944:	cf850513          	addi	a0,a0,-776 # ffffffffc020c638 <commands+0x960>
ffffffffc0201948:	b57fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020194c:	0000b697          	auipc	a3,0xb
ffffffffc0201950:	efc68693          	addi	a3,a3,-260 # ffffffffc020c848 <commands+0xb70>
ffffffffc0201954:	0000a617          	auipc	a2,0xa
ffffffffc0201958:	59460613          	addi	a2,a2,1428 # ffffffffc020bee8 <commands+0x210>
ffffffffc020195c:	10400593          	li	a1,260
ffffffffc0201960:	0000b517          	auipc	a0,0xb
ffffffffc0201964:	cd850513          	addi	a0,a0,-808 # ffffffffc020c638 <commands+0x960>
ffffffffc0201968:	b37fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020196c:	0000b697          	auipc	a3,0xb
ffffffffc0201970:	ec468693          	addi	a3,a3,-316 # ffffffffc020c830 <commands+0xb58>
ffffffffc0201974:	0000a617          	auipc	a2,0xa
ffffffffc0201978:	57460613          	addi	a2,a2,1396 # ffffffffc020bee8 <commands+0x210>
ffffffffc020197c:	10300593          	li	a1,259
ffffffffc0201980:	0000b517          	auipc	a0,0xb
ffffffffc0201984:	cb850513          	addi	a0,a0,-840 # ffffffffc020c638 <commands+0x960>
ffffffffc0201988:	b17fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020198c:	0000b697          	auipc	a3,0xb
ffffffffc0201990:	e0c68693          	addi	a3,a3,-500 # ffffffffc020c798 <commands+0xac0>
ffffffffc0201994:	0000a617          	auipc	a2,0xa
ffffffffc0201998:	55460613          	addi	a2,a2,1364 # ffffffffc020bee8 <commands+0x210>
ffffffffc020199c:	0fd00593          	li	a1,253
ffffffffc02019a0:	0000b517          	auipc	a0,0xb
ffffffffc02019a4:	c9850513          	addi	a0,a0,-872 # ffffffffc020c638 <commands+0x960>
ffffffffc02019a8:	af7fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02019ac:	0000b697          	auipc	a3,0xb
ffffffffc02019b0:	e6c68693          	addi	a3,a3,-404 # ffffffffc020c818 <commands+0xb40>
ffffffffc02019b4:	0000a617          	auipc	a2,0xa
ffffffffc02019b8:	53460613          	addi	a2,a2,1332 # ffffffffc020bee8 <commands+0x210>
ffffffffc02019bc:	0f800593          	li	a1,248
ffffffffc02019c0:	0000b517          	auipc	a0,0xb
ffffffffc02019c4:	c7850513          	addi	a0,a0,-904 # ffffffffc020c638 <commands+0x960>
ffffffffc02019c8:	ad7fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02019cc:	0000b697          	auipc	a3,0xb
ffffffffc02019d0:	f6c68693          	addi	a3,a3,-148 # ffffffffc020c938 <commands+0xc60>
ffffffffc02019d4:	0000a617          	auipc	a2,0xa
ffffffffc02019d8:	51460613          	addi	a2,a2,1300 # ffffffffc020bee8 <commands+0x210>
ffffffffc02019dc:	11600593          	li	a1,278
ffffffffc02019e0:	0000b517          	auipc	a0,0xb
ffffffffc02019e4:	c5850513          	addi	a0,a0,-936 # ffffffffc020c638 <commands+0x960>
ffffffffc02019e8:	ab7fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02019ec:	0000b697          	auipc	a3,0xb
ffffffffc02019f0:	f7c68693          	addi	a3,a3,-132 # ffffffffc020c968 <commands+0xc90>
ffffffffc02019f4:	0000a617          	auipc	a2,0xa
ffffffffc02019f8:	4f460613          	addi	a2,a2,1268 # ffffffffc020bee8 <commands+0x210>
ffffffffc02019fc:	12500593          	li	a1,293
ffffffffc0201a00:	0000b517          	auipc	a0,0xb
ffffffffc0201a04:	c3850513          	addi	a0,a0,-968 # ffffffffc020c638 <commands+0x960>
ffffffffc0201a08:	a97fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0201a0c:	0000b697          	auipc	a3,0xb
ffffffffc0201a10:	c4468693          	addi	a3,a3,-956 # ffffffffc020c650 <commands+0x978>
ffffffffc0201a14:	0000a617          	auipc	a2,0xa
ffffffffc0201a18:	4d460613          	addi	a2,a2,1236 # ffffffffc020bee8 <commands+0x210>
ffffffffc0201a1c:	0f200593          	li	a1,242
ffffffffc0201a20:	0000b517          	auipc	a0,0xb
ffffffffc0201a24:	c1850513          	addi	a0,a0,-1000 # ffffffffc020c638 <commands+0x960>
ffffffffc0201a28:	a77fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0201a2c:	0000b697          	auipc	a3,0xb
ffffffffc0201a30:	c6468693          	addi	a3,a3,-924 # ffffffffc020c690 <commands+0x9b8>
ffffffffc0201a34:	0000a617          	auipc	a2,0xa
ffffffffc0201a38:	4b460613          	addi	a2,a2,1204 # ffffffffc020bee8 <commands+0x210>
ffffffffc0201a3c:	0b900593          	li	a1,185
ffffffffc0201a40:	0000b517          	auipc	a0,0xb
ffffffffc0201a44:	bf850513          	addi	a0,a0,-1032 # ffffffffc020c638 <commands+0x960>
ffffffffc0201a48:	a57fe0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0201a4c <default_free_pages>:
ffffffffc0201a4c:	1141                	addi	sp,sp,-16
ffffffffc0201a4e:	e406                	sd	ra,8(sp)
ffffffffc0201a50:	14058463          	beqz	a1,ffffffffc0201b98 <default_free_pages+0x14c>
ffffffffc0201a54:	00659693          	slli	a3,a1,0x6
ffffffffc0201a58:	96aa                	add	a3,a3,a0
ffffffffc0201a5a:	87aa                	mv	a5,a0
ffffffffc0201a5c:	02d50263          	beq	a0,a3,ffffffffc0201a80 <default_free_pages+0x34>
ffffffffc0201a60:	6798                	ld	a4,8(a5)
ffffffffc0201a62:	8b05                	andi	a4,a4,1
ffffffffc0201a64:	10071a63          	bnez	a4,ffffffffc0201b78 <default_free_pages+0x12c>
ffffffffc0201a68:	6798                	ld	a4,8(a5)
ffffffffc0201a6a:	8b09                	andi	a4,a4,2
ffffffffc0201a6c:	10071663          	bnez	a4,ffffffffc0201b78 <default_free_pages+0x12c>
ffffffffc0201a70:	0007b423          	sd	zero,8(a5)
ffffffffc0201a74:	0007a023          	sw	zero,0(a5)
ffffffffc0201a78:	04078793          	addi	a5,a5,64
ffffffffc0201a7c:	fed792e3          	bne	a5,a3,ffffffffc0201a60 <default_free_pages+0x14>
ffffffffc0201a80:	2581                	sext.w	a1,a1
ffffffffc0201a82:	c90c                	sw	a1,16(a0)
ffffffffc0201a84:	00850893          	addi	a7,a0,8
ffffffffc0201a88:	4789                	li	a5,2
ffffffffc0201a8a:	40f8b02f          	amoor.d	zero,a5,(a7)
ffffffffc0201a8e:	00090697          	auipc	a3,0x90
ffffffffc0201a92:	d1a68693          	addi	a3,a3,-742 # ffffffffc02917a8 <free_area>
ffffffffc0201a96:	4a98                	lw	a4,16(a3)
ffffffffc0201a98:	669c                	ld	a5,8(a3)
ffffffffc0201a9a:	01850613          	addi	a2,a0,24
ffffffffc0201a9e:	9db9                	addw	a1,a1,a4
ffffffffc0201aa0:	ca8c                	sw	a1,16(a3)
ffffffffc0201aa2:	0ad78463          	beq	a5,a3,ffffffffc0201b4a <default_free_pages+0xfe>
ffffffffc0201aa6:	fe878713          	addi	a4,a5,-24
ffffffffc0201aaa:	0006b803          	ld	a6,0(a3)
ffffffffc0201aae:	4581                	li	a1,0
ffffffffc0201ab0:	00e56a63          	bltu	a0,a4,ffffffffc0201ac4 <default_free_pages+0x78>
ffffffffc0201ab4:	6798                	ld	a4,8(a5)
ffffffffc0201ab6:	04d70c63          	beq	a4,a3,ffffffffc0201b0e <default_free_pages+0xc2>
ffffffffc0201aba:	87ba                	mv	a5,a4
ffffffffc0201abc:	fe878713          	addi	a4,a5,-24
ffffffffc0201ac0:	fee57ae3          	bgeu	a0,a4,ffffffffc0201ab4 <default_free_pages+0x68>
ffffffffc0201ac4:	c199                	beqz	a1,ffffffffc0201aca <default_free_pages+0x7e>
ffffffffc0201ac6:	0106b023          	sd	a6,0(a3)
ffffffffc0201aca:	6398                	ld	a4,0(a5)
ffffffffc0201acc:	e390                	sd	a2,0(a5)
ffffffffc0201ace:	e710                	sd	a2,8(a4)
ffffffffc0201ad0:	f11c                	sd	a5,32(a0)
ffffffffc0201ad2:	ed18                	sd	a4,24(a0)
ffffffffc0201ad4:	00d70d63          	beq	a4,a3,ffffffffc0201aee <default_free_pages+0xa2>
ffffffffc0201ad8:	ff872583          	lw	a1,-8(a4)
ffffffffc0201adc:	fe870613          	addi	a2,a4,-24
ffffffffc0201ae0:	02059813          	slli	a6,a1,0x20
ffffffffc0201ae4:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201ae8:	97b2                	add	a5,a5,a2
ffffffffc0201aea:	02f50c63          	beq	a0,a5,ffffffffc0201b22 <default_free_pages+0xd6>
ffffffffc0201aee:	711c                	ld	a5,32(a0)
ffffffffc0201af0:	00d78c63          	beq	a5,a3,ffffffffc0201b08 <default_free_pages+0xbc>
ffffffffc0201af4:	4910                	lw	a2,16(a0)
ffffffffc0201af6:	fe878693          	addi	a3,a5,-24
ffffffffc0201afa:	02061593          	slli	a1,a2,0x20
ffffffffc0201afe:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201b02:	972a                	add	a4,a4,a0
ffffffffc0201b04:	04e68a63          	beq	a3,a4,ffffffffc0201b58 <default_free_pages+0x10c>
ffffffffc0201b08:	60a2                	ld	ra,8(sp)
ffffffffc0201b0a:	0141                	addi	sp,sp,16
ffffffffc0201b0c:	8082                	ret
ffffffffc0201b0e:	e790                	sd	a2,8(a5)
ffffffffc0201b10:	f114                	sd	a3,32(a0)
ffffffffc0201b12:	6798                	ld	a4,8(a5)
ffffffffc0201b14:	ed1c                	sd	a5,24(a0)
ffffffffc0201b16:	02d70763          	beq	a4,a3,ffffffffc0201b44 <default_free_pages+0xf8>
ffffffffc0201b1a:	8832                	mv	a6,a2
ffffffffc0201b1c:	4585                	li	a1,1
ffffffffc0201b1e:	87ba                	mv	a5,a4
ffffffffc0201b20:	bf71                	j	ffffffffc0201abc <default_free_pages+0x70>
ffffffffc0201b22:	491c                	lw	a5,16(a0)
ffffffffc0201b24:	9dbd                	addw	a1,a1,a5
ffffffffc0201b26:	feb72c23          	sw	a1,-8(a4)
ffffffffc0201b2a:	57f5                	li	a5,-3
ffffffffc0201b2c:	60f8b02f          	amoand.d	zero,a5,(a7)
ffffffffc0201b30:	01853803          	ld	a6,24(a0)
ffffffffc0201b34:	710c                	ld	a1,32(a0)
ffffffffc0201b36:	8532                	mv	a0,a2
ffffffffc0201b38:	00b83423          	sd	a1,8(a6)
ffffffffc0201b3c:	671c                	ld	a5,8(a4)
ffffffffc0201b3e:	0105b023          	sd	a6,0(a1)
ffffffffc0201b42:	b77d                	j	ffffffffc0201af0 <default_free_pages+0xa4>
ffffffffc0201b44:	e290                	sd	a2,0(a3)
ffffffffc0201b46:	873e                	mv	a4,a5
ffffffffc0201b48:	bf41                	j	ffffffffc0201ad8 <default_free_pages+0x8c>
ffffffffc0201b4a:	60a2                	ld	ra,8(sp)
ffffffffc0201b4c:	e390                	sd	a2,0(a5)
ffffffffc0201b4e:	e790                	sd	a2,8(a5)
ffffffffc0201b50:	f11c                	sd	a5,32(a0)
ffffffffc0201b52:	ed1c                	sd	a5,24(a0)
ffffffffc0201b54:	0141                	addi	sp,sp,16
ffffffffc0201b56:	8082                	ret
ffffffffc0201b58:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201b5c:	ff078693          	addi	a3,a5,-16
ffffffffc0201b60:	9e39                	addw	a2,a2,a4
ffffffffc0201b62:	c910                	sw	a2,16(a0)
ffffffffc0201b64:	5775                	li	a4,-3
ffffffffc0201b66:	60e6b02f          	amoand.d	zero,a4,(a3)
ffffffffc0201b6a:	6398                	ld	a4,0(a5)
ffffffffc0201b6c:	679c                	ld	a5,8(a5)
ffffffffc0201b6e:	60a2                	ld	ra,8(sp)
ffffffffc0201b70:	e71c                	sd	a5,8(a4)
ffffffffc0201b72:	e398                	sd	a4,0(a5)
ffffffffc0201b74:	0141                	addi	sp,sp,16
ffffffffc0201b76:	8082                	ret
ffffffffc0201b78:	0000b697          	auipc	a3,0xb
ffffffffc0201b7c:	e0868693          	addi	a3,a3,-504 # ffffffffc020c980 <commands+0xca8>
ffffffffc0201b80:	0000a617          	auipc	a2,0xa
ffffffffc0201b84:	36860613          	addi	a2,a2,872 # ffffffffc020bee8 <commands+0x210>
ffffffffc0201b88:	08200593          	li	a1,130
ffffffffc0201b8c:	0000b517          	auipc	a0,0xb
ffffffffc0201b90:	aac50513          	addi	a0,a0,-1364 # ffffffffc020c638 <commands+0x960>
ffffffffc0201b94:	90bfe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0201b98:	0000b697          	auipc	a3,0xb
ffffffffc0201b9c:	de068693          	addi	a3,a3,-544 # ffffffffc020c978 <commands+0xca0>
ffffffffc0201ba0:	0000a617          	auipc	a2,0xa
ffffffffc0201ba4:	34860613          	addi	a2,a2,840 # ffffffffc020bee8 <commands+0x210>
ffffffffc0201ba8:	07f00593          	li	a1,127
ffffffffc0201bac:	0000b517          	auipc	a0,0xb
ffffffffc0201bb0:	a8c50513          	addi	a0,a0,-1396 # ffffffffc020c638 <commands+0x960>
ffffffffc0201bb4:	8ebfe0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0201bb8 <default_alloc_pages>:
ffffffffc0201bb8:	c941                	beqz	a0,ffffffffc0201c48 <default_alloc_pages+0x90>
ffffffffc0201bba:	00090597          	auipc	a1,0x90
ffffffffc0201bbe:	bee58593          	addi	a1,a1,-1042 # ffffffffc02917a8 <free_area>
ffffffffc0201bc2:	0105a803          	lw	a6,16(a1)
ffffffffc0201bc6:	872a                	mv	a4,a0
ffffffffc0201bc8:	02081793          	slli	a5,a6,0x20
ffffffffc0201bcc:	9381                	srli	a5,a5,0x20
ffffffffc0201bce:	00a7ee63          	bltu	a5,a0,ffffffffc0201bea <default_alloc_pages+0x32>
ffffffffc0201bd2:	87ae                	mv	a5,a1
ffffffffc0201bd4:	a801                	j	ffffffffc0201be4 <default_alloc_pages+0x2c>
ffffffffc0201bd6:	ff87a683          	lw	a3,-8(a5)
ffffffffc0201bda:	02069613          	slli	a2,a3,0x20
ffffffffc0201bde:	9201                	srli	a2,a2,0x20
ffffffffc0201be0:	00e67763          	bgeu	a2,a4,ffffffffc0201bee <default_alloc_pages+0x36>
ffffffffc0201be4:	679c                	ld	a5,8(a5)
ffffffffc0201be6:	feb798e3          	bne	a5,a1,ffffffffc0201bd6 <default_alloc_pages+0x1e>
ffffffffc0201bea:	4501                	li	a0,0
ffffffffc0201bec:	8082                	ret
ffffffffc0201bee:	0007b883          	ld	a7,0(a5)
ffffffffc0201bf2:	0087b303          	ld	t1,8(a5)
ffffffffc0201bf6:	fe878513          	addi	a0,a5,-24
ffffffffc0201bfa:	00070e1b          	sext.w	t3,a4
ffffffffc0201bfe:	0068b423          	sd	t1,8(a7) # 10000008 <_binary_bin_sfs_img_size+0xff8ad08>
ffffffffc0201c02:	01133023          	sd	a7,0(t1)
ffffffffc0201c06:	02c77863          	bgeu	a4,a2,ffffffffc0201c36 <default_alloc_pages+0x7e>
ffffffffc0201c0a:	071a                	slli	a4,a4,0x6
ffffffffc0201c0c:	972a                	add	a4,a4,a0
ffffffffc0201c0e:	41c686bb          	subw	a3,a3,t3
ffffffffc0201c12:	cb14                	sw	a3,16(a4)
ffffffffc0201c14:	00870613          	addi	a2,a4,8
ffffffffc0201c18:	4689                	li	a3,2
ffffffffc0201c1a:	40d6302f          	amoor.d	zero,a3,(a2)
ffffffffc0201c1e:	0088b683          	ld	a3,8(a7)
ffffffffc0201c22:	01870613          	addi	a2,a4,24
ffffffffc0201c26:	0105a803          	lw	a6,16(a1)
ffffffffc0201c2a:	e290                	sd	a2,0(a3)
ffffffffc0201c2c:	00c8b423          	sd	a2,8(a7)
ffffffffc0201c30:	f314                	sd	a3,32(a4)
ffffffffc0201c32:	01173c23          	sd	a7,24(a4)
ffffffffc0201c36:	41c8083b          	subw	a6,a6,t3
ffffffffc0201c3a:	0105a823          	sw	a6,16(a1)
ffffffffc0201c3e:	5775                	li	a4,-3
ffffffffc0201c40:	17c1                	addi	a5,a5,-16
ffffffffc0201c42:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201c46:	8082                	ret
ffffffffc0201c48:	1141                	addi	sp,sp,-16
ffffffffc0201c4a:	0000b697          	auipc	a3,0xb
ffffffffc0201c4e:	d2e68693          	addi	a3,a3,-722 # ffffffffc020c978 <commands+0xca0>
ffffffffc0201c52:	0000a617          	auipc	a2,0xa
ffffffffc0201c56:	29660613          	addi	a2,a2,662 # ffffffffc020bee8 <commands+0x210>
ffffffffc0201c5a:	06100593          	li	a1,97
ffffffffc0201c5e:	0000b517          	auipc	a0,0xb
ffffffffc0201c62:	9da50513          	addi	a0,a0,-1574 # ffffffffc020c638 <commands+0x960>
ffffffffc0201c66:	e406                	sd	ra,8(sp)
ffffffffc0201c68:	837fe0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0201c6c <default_init_memmap>:
ffffffffc0201c6c:	1141                	addi	sp,sp,-16
ffffffffc0201c6e:	e406                	sd	ra,8(sp)
ffffffffc0201c70:	c5f1                	beqz	a1,ffffffffc0201d3c <default_init_memmap+0xd0>
ffffffffc0201c72:	00659693          	slli	a3,a1,0x6
ffffffffc0201c76:	96aa                	add	a3,a3,a0
ffffffffc0201c78:	87aa                	mv	a5,a0
ffffffffc0201c7a:	00d50f63          	beq	a0,a3,ffffffffc0201c98 <default_init_memmap+0x2c>
ffffffffc0201c7e:	6798                	ld	a4,8(a5)
ffffffffc0201c80:	8b05                	andi	a4,a4,1
ffffffffc0201c82:	cf49                	beqz	a4,ffffffffc0201d1c <default_init_memmap+0xb0>
ffffffffc0201c84:	0007a823          	sw	zero,16(a5)
ffffffffc0201c88:	0007b423          	sd	zero,8(a5)
ffffffffc0201c8c:	0007a023          	sw	zero,0(a5)
ffffffffc0201c90:	04078793          	addi	a5,a5,64
ffffffffc0201c94:	fed795e3          	bne	a5,a3,ffffffffc0201c7e <default_init_memmap+0x12>
ffffffffc0201c98:	2581                	sext.w	a1,a1
ffffffffc0201c9a:	c90c                	sw	a1,16(a0)
ffffffffc0201c9c:	4789                	li	a5,2
ffffffffc0201c9e:	00850713          	addi	a4,a0,8
ffffffffc0201ca2:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc0201ca6:	00090697          	auipc	a3,0x90
ffffffffc0201caa:	b0268693          	addi	a3,a3,-1278 # ffffffffc02917a8 <free_area>
ffffffffc0201cae:	4a98                	lw	a4,16(a3)
ffffffffc0201cb0:	669c                	ld	a5,8(a3)
ffffffffc0201cb2:	01850613          	addi	a2,a0,24
ffffffffc0201cb6:	9db9                	addw	a1,a1,a4
ffffffffc0201cb8:	ca8c                	sw	a1,16(a3)
ffffffffc0201cba:	04d78a63          	beq	a5,a3,ffffffffc0201d0e <default_init_memmap+0xa2>
ffffffffc0201cbe:	fe878713          	addi	a4,a5,-24
ffffffffc0201cc2:	0006b803          	ld	a6,0(a3)
ffffffffc0201cc6:	4581                	li	a1,0
ffffffffc0201cc8:	00e56a63          	bltu	a0,a4,ffffffffc0201cdc <default_init_memmap+0x70>
ffffffffc0201ccc:	6798                	ld	a4,8(a5)
ffffffffc0201cce:	02d70263          	beq	a4,a3,ffffffffc0201cf2 <default_init_memmap+0x86>
ffffffffc0201cd2:	87ba                	mv	a5,a4
ffffffffc0201cd4:	fe878713          	addi	a4,a5,-24
ffffffffc0201cd8:	fee57ae3          	bgeu	a0,a4,ffffffffc0201ccc <default_init_memmap+0x60>
ffffffffc0201cdc:	c199                	beqz	a1,ffffffffc0201ce2 <default_init_memmap+0x76>
ffffffffc0201cde:	0106b023          	sd	a6,0(a3)
ffffffffc0201ce2:	6398                	ld	a4,0(a5)
ffffffffc0201ce4:	60a2                	ld	ra,8(sp)
ffffffffc0201ce6:	e390                	sd	a2,0(a5)
ffffffffc0201ce8:	e710                	sd	a2,8(a4)
ffffffffc0201cea:	f11c                	sd	a5,32(a0)
ffffffffc0201cec:	ed18                	sd	a4,24(a0)
ffffffffc0201cee:	0141                	addi	sp,sp,16
ffffffffc0201cf0:	8082                	ret
ffffffffc0201cf2:	e790                	sd	a2,8(a5)
ffffffffc0201cf4:	f114                	sd	a3,32(a0)
ffffffffc0201cf6:	6798                	ld	a4,8(a5)
ffffffffc0201cf8:	ed1c                	sd	a5,24(a0)
ffffffffc0201cfa:	00d70663          	beq	a4,a3,ffffffffc0201d06 <default_init_memmap+0x9a>
ffffffffc0201cfe:	8832                	mv	a6,a2
ffffffffc0201d00:	4585                	li	a1,1
ffffffffc0201d02:	87ba                	mv	a5,a4
ffffffffc0201d04:	bfc1                	j	ffffffffc0201cd4 <default_init_memmap+0x68>
ffffffffc0201d06:	60a2                	ld	ra,8(sp)
ffffffffc0201d08:	e290                	sd	a2,0(a3)
ffffffffc0201d0a:	0141                	addi	sp,sp,16
ffffffffc0201d0c:	8082                	ret
ffffffffc0201d0e:	60a2                	ld	ra,8(sp)
ffffffffc0201d10:	e390                	sd	a2,0(a5)
ffffffffc0201d12:	e790                	sd	a2,8(a5)
ffffffffc0201d14:	f11c                	sd	a5,32(a0)
ffffffffc0201d16:	ed1c                	sd	a5,24(a0)
ffffffffc0201d18:	0141                	addi	sp,sp,16
ffffffffc0201d1a:	8082                	ret
ffffffffc0201d1c:	0000b697          	auipc	a3,0xb
ffffffffc0201d20:	c8c68693          	addi	a3,a3,-884 # ffffffffc020c9a8 <commands+0xcd0>
ffffffffc0201d24:	0000a617          	auipc	a2,0xa
ffffffffc0201d28:	1c460613          	addi	a2,a2,452 # ffffffffc020bee8 <commands+0x210>
ffffffffc0201d2c:	04800593          	li	a1,72
ffffffffc0201d30:	0000b517          	auipc	a0,0xb
ffffffffc0201d34:	90850513          	addi	a0,a0,-1784 # ffffffffc020c638 <commands+0x960>
ffffffffc0201d38:	f66fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0201d3c:	0000b697          	auipc	a3,0xb
ffffffffc0201d40:	c3c68693          	addi	a3,a3,-964 # ffffffffc020c978 <commands+0xca0>
ffffffffc0201d44:	0000a617          	auipc	a2,0xa
ffffffffc0201d48:	1a460613          	addi	a2,a2,420 # ffffffffc020bee8 <commands+0x210>
ffffffffc0201d4c:	04500593          	li	a1,69
ffffffffc0201d50:	0000b517          	auipc	a0,0xb
ffffffffc0201d54:	8e850513          	addi	a0,a0,-1816 # ffffffffc020c638 <commands+0x960>
ffffffffc0201d58:	f46fe0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0201d5c <slob_free>:
ffffffffc0201d5c:	c94d                	beqz	a0,ffffffffc0201e0e <slob_free+0xb2>
ffffffffc0201d5e:	1141                	addi	sp,sp,-16
ffffffffc0201d60:	e022                	sd	s0,0(sp)
ffffffffc0201d62:	e406                	sd	ra,8(sp)
ffffffffc0201d64:	842a                	mv	s0,a0
ffffffffc0201d66:	e9c1                	bnez	a1,ffffffffc0201df6 <slob_free+0x9a>
ffffffffc0201d68:	100027f3          	csrr	a5,sstatus
ffffffffc0201d6c:	8b89                	andi	a5,a5,2
ffffffffc0201d6e:	4501                	li	a0,0
ffffffffc0201d70:	ebd9                	bnez	a5,ffffffffc0201e06 <slob_free+0xaa>
ffffffffc0201d72:	0008f617          	auipc	a2,0x8f
ffffffffc0201d76:	2de60613          	addi	a2,a2,734 # ffffffffc0291050 <slobfree>
ffffffffc0201d7a:	621c                	ld	a5,0(a2)
ffffffffc0201d7c:	873e                	mv	a4,a5
ffffffffc0201d7e:	679c                	ld	a5,8(a5)
ffffffffc0201d80:	02877a63          	bgeu	a4,s0,ffffffffc0201db4 <slob_free+0x58>
ffffffffc0201d84:	00f46463          	bltu	s0,a5,ffffffffc0201d8c <slob_free+0x30>
ffffffffc0201d88:	fef76ae3          	bltu	a4,a5,ffffffffc0201d7c <slob_free+0x20>
ffffffffc0201d8c:	400c                	lw	a1,0(s0)
ffffffffc0201d8e:	00459693          	slli	a3,a1,0x4
ffffffffc0201d92:	96a2                	add	a3,a3,s0
ffffffffc0201d94:	02d78a63          	beq	a5,a3,ffffffffc0201dc8 <slob_free+0x6c>
ffffffffc0201d98:	4314                	lw	a3,0(a4)
ffffffffc0201d9a:	e41c                	sd	a5,8(s0)
ffffffffc0201d9c:	00469793          	slli	a5,a3,0x4
ffffffffc0201da0:	97ba                	add	a5,a5,a4
ffffffffc0201da2:	02f40e63          	beq	s0,a5,ffffffffc0201dde <slob_free+0x82>
ffffffffc0201da6:	e700                	sd	s0,8(a4)
ffffffffc0201da8:	e218                	sd	a4,0(a2)
ffffffffc0201daa:	e129                	bnez	a0,ffffffffc0201dec <slob_free+0x90>
ffffffffc0201dac:	60a2                	ld	ra,8(sp)
ffffffffc0201dae:	6402                	ld	s0,0(sp)
ffffffffc0201db0:	0141                	addi	sp,sp,16
ffffffffc0201db2:	8082                	ret
ffffffffc0201db4:	fcf764e3          	bltu	a4,a5,ffffffffc0201d7c <slob_free+0x20>
ffffffffc0201db8:	fcf472e3          	bgeu	s0,a5,ffffffffc0201d7c <slob_free+0x20>
ffffffffc0201dbc:	400c                	lw	a1,0(s0)
ffffffffc0201dbe:	00459693          	slli	a3,a1,0x4
ffffffffc0201dc2:	96a2                	add	a3,a3,s0
ffffffffc0201dc4:	fcd79ae3          	bne	a5,a3,ffffffffc0201d98 <slob_free+0x3c>
ffffffffc0201dc8:	4394                	lw	a3,0(a5)
ffffffffc0201dca:	679c                	ld	a5,8(a5)
ffffffffc0201dcc:	9db5                	addw	a1,a1,a3
ffffffffc0201dce:	c00c                	sw	a1,0(s0)
ffffffffc0201dd0:	4314                	lw	a3,0(a4)
ffffffffc0201dd2:	e41c                	sd	a5,8(s0)
ffffffffc0201dd4:	00469793          	slli	a5,a3,0x4
ffffffffc0201dd8:	97ba                	add	a5,a5,a4
ffffffffc0201dda:	fcf416e3          	bne	s0,a5,ffffffffc0201da6 <slob_free+0x4a>
ffffffffc0201dde:	401c                	lw	a5,0(s0)
ffffffffc0201de0:	640c                	ld	a1,8(s0)
ffffffffc0201de2:	e218                	sd	a4,0(a2)
ffffffffc0201de4:	9ebd                	addw	a3,a3,a5
ffffffffc0201de6:	c314                	sw	a3,0(a4)
ffffffffc0201de8:	e70c                	sd	a1,8(a4)
ffffffffc0201dea:	d169                	beqz	a0,ffffffffc0201dac <slob_free+0x50>
ffffffffc0201dec:	6402                	ld	s0,0(sp)
ffffffffc0201dee:	60a2                	ld	ra,8(sp)
ffffffffc0201df0:	0141                	addi	sp,sp,16
ffffffffc0201df2:	e7bfe06f          	j	ffffffffc0200c6c <intr_enable>
ffffffffc0201df6:	25bd                	addiw	a1,a1,15
ffffffffc0201df8:	8191                	srli	a1,a1,0x4
ffffffffc0201dfa:	c10c                	sw	a1,0(a0)
ffffffffc0201dfc:	100027f3          	csrr	a5,sstatus
ffffffffc0201e00:	8b89                	andi	a5,a5,2
ffffffffc0201e02:	4501                	li	a0,0
ffffffffc0201e04:	d7bd                	beqz	a5,ffffffffc0201d72 <slob_free+0x16>
ffffffffc0201e06:	e6dfe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0201e0a:	4505                	li	a0,1
ffffffffc0201e0c:	b79d                	j	ffffffffc0201d72 <slob_free+0x16>
ffffffffc0201e0e:	8082                	ret

ffffffffc0201e10 <__slob_get_free_pages.constprop.0>:
ffffffffc0201e10:	4785                	li	a5,1
ffffffffc0201e12:	1141                	addi	sp,sp,-16
ffffffffc0201e14:	00a7953b          	sllw	a0,a5,a0
ffffffffc0201e18:	e406                	sd	ra,8(sp)
ffffffffc0201e1a:	352000ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc0201e1e:	c91d                	beqz	a0,ffffffffc0201e54 <__slob_get_free_pages.constprop.0+0x44>
ffffffffc0201e20:	00095697          	auipc	a3,0x95
ffffffffc0201e24:	a886b683          	ld	a3,-1400(a3) # ffffffffc02968a8 <pages>
ffffffffc0201e28:	8d15                	sub	a0,a0,a3
ffffffffc0201e2a:	8519                	srai	a0,a0,0x6
ffffffffc0201e2c:	0000e697          	auipc	a3,0xe
ffffffffc0201e30:	fa46b683          	ld	a3,-92(a3) # ffffffffc020fdd0 <nbase>
ffffffffc0201e34:	9536                	add	a0,a0,a3
ffffffffc0201e36:	00c51793          	slli	a5,a0,0xc
ffffffffc0201e3a:	83b1                	srli	a5,a5,0xc
ffffffffc0201e3c:	00095717          	auipc	a4,0x95
ffffffffc0201e40:	a6473703          	ld	a4,-1436(a4) # ffffffffc02968a0 <npage>
ffffffffc0201e44:	0532                	slli	a0,a0,0xc
ffffffffc0201e46:	00e7fa63          	bgeu	a5,a4,ffffffffc0201e5a <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201e4a:	00095697          	auipc	a3,0x95
ffffffffc0201e4e:	a6e6b683          	ld	a3,-1426(a3) # ffffffffc02968b8 <va_pa_offset>
ffffffffc0201e52:	9536                	add	a0,a0,a3
ffffffffc0201e54:	60a2                	ld	ra,8(sp)
ffffffffc0201e56:	0141                	addi	sp,sp,16
ffffffffc0201e58:	8082                	ret
ffffffffc0201e5a:	86aa                	mv	a3,a0
ffffffffc0201e5c:	0000b617          	auipc	a2,0xb
ffffffffc0201e60:	bac60613          	addi	a2,a2,-1108 # ffffffffc020ca08 <default_pmm_manager+0x38>
ffffffffc0201e64:	07100593          	li	a1,113
ffffffffc0201e68:	0000b517          	auipc	a0,0xb
ffffffffc0201e6c:	bc850513          	addi	a0,a0,-1080 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0201e70:	e2efe0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0201e74 <slob_alloc.constprop.0>:
ffffffffc0201e74:	1101                	addi	sp,sp,-32
ffffffffc0201e76:	ec06                	sd	ra,24(sp)
ffffffffc0201e78:	e822                	sd	s0,16(sp)
ffffffffc0201e7a:	e426                	sd	s1,8(sp)
ffffffffc0201e7c:	e04a                	sd	s2,0(sp)
ffffffffc0201e7e:	01050713          	addi	a4,a0,16
ffffffffc0201e82:	6785                	lui	a5,0x1
ffffffffc0201e84:	0cf77363          	bgeu	a4,a5,ffffffffc0201f4a <slob_alloc.constprop.0+0xd6>
ffffffffc0201e88:	00f50493          	addi	s1,a0,15
ffffffffc0201e8c:	8091                	srli	s1,s1,0x4
ffffffffc0201e8e:	2481                	sext.w	s1,s1
ffffffffc0201e90:	10002673          	csrr	a2,sstatus
ffffffffc0201e94:	8a09                	andi	a2,a2,2
ffffffffc0201e96:	e25d                	bnez	a2,ffffffffc0201f3c <slob_alloc.constprop.0+0xc8>
ffffffffc0201e98:	0008f917          	auipc	s2,0x8f
ffffffffc0201e9c:	1b890913          	addi	s2,s2,440 # ffffffffc0291050 <slobfree>
ffffffffc0201ea0:	00093683          	ld	a3,0(s2)
ffffffffc0201ea4:	669c                	ld	a5,8(a3)
ffffffffc0201ea6:	4398                	lw	a4,0(a5)
ffffffffc0201ea8:	08975e63          	bge	a4,s1,ffffffffc0201f44 <slob_alloc.constprop.0+0xd0>
ffffffffc0201eac:	00f68b63          	beq	a3,a5,ffffffffc0201ec2 <slob_alloc.constprop.0+0x4e>
ffffffffc0201eb0:	6780                	ld	s0,8(a5)
ffffffffc0201eb2:	4018                	lw	a4,0(s0)
ffffffffc0201eb4:	02975a63          	bge	a4,s1,ffffffffc0201ee8 <slob_alloc.constprop.0+0x74>
ffffffffc0201eb8:	00093683          	ld	a3,0(s2)
ffffffffc0201ebc:	87a2                	mv	a5,s0
ffffffffc0201ebe:	fef699e3          	bne	a3,a5,ffffffffc0201eb0 <slob_alloc.constprop.0+0x3c>
ffffffffc0201ec2:	ee31                	bnez	a2,ffffffffc0201f1e <slob_alloc.constprop.0+0xaa>
ffffffffc0201ec4:	4501                	li	a0,0
ffffffffc0201ec6:	f4bff0ef          	jal	ra,ffffffffc0201e10 <__slob_get_free_pages.constprop.0>
ffffffffc0201eca:	842a                	mv	s0,a0
ffffffffc0201ecc:	cd05                	beqz	a0,ffffffffc0201f04 <slob_alloc.constprop.0+0x90>
ffffffffc0201ece:	6585                	lui	a1,0x1
ffffffffc0201ed0:	e8dff0ef          	jal	ra,ffffffffc0201d5c <slob_free>
ffffffffc0201ed4:	10002673          	csrr	a2,sstatus
ffffffffc0201ed8:	8a09                	andi	a2,a2,2
ffffffffc0201eda:	ee05                	bnez	a2,ffffffffc0201f12 <slob_alloc.constprop.0+0x9e>
ffffffffc0201edc:	00093783          	ld	a5,0(s2)
ffffffffc0201ee0:	6780                	ld	s0,8(a5)
ffffffffc0201ee2:	4018                	lw	a4,0(s0)
ffffffffc0201ee4:	fc974ae3          	blt	a4,s1,ffffffffc0201eb8 <slob_alloc.constprop.0+0x44>
ffffffffc0201ee8:	04e48763          	beq	s1,a4,ffffffffc0201f36 <slob_alloc.constprop.0+0xc2>
ffffffffc0201eec:	00449693          	slli	a3,s1,0x4
ffffffffc0201ef0:	96a2                	add	a3,a3,s0
ffffffffc0201ef2:	e794                	sd	a3,8(a5)
ffffffffc0201ef4:	640c                	ld	a1,8(s0)
ffffffffc0201ef6:	9f05                	subw	a4,a4,s1
ffffffffc0201ef8:	c298                	sw	a4,0(a3)
ffffffffc0201efa:	e68c                	sd	a1,8(a3)
ffffffffc0201efc:	c004                	sw	s1,0(s0)
ffffffffc0201efe:	00f93023          	sd	a5,0(s2)
ffffffffc0201f02:	e20d                	bnez	a2,ffffffffc0201f24 <slob_alloc.constprop.0+0xb0>
ffffffffc0201f04:	60e2                	ld	ra,24(sp)
ffffffffc0201f06:	8522                	mv	a0,s0
ffffffffc0201f08:	6442                	ld	s0,16(sp)
ffffffffc0201f0a:	64a2                	ld	s1,8(sp)
ffffffffc0201f0c:	6902                	ld	s2,0(sp)
ffffffffc0201f0e:	6105                	addi	sp,sp,32
ffffffffc0201f10:	8082                	ret
ffffffffc0201f12:	d61fe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0201f16:	00093783          	ld	a5,0(s2)
ffffffffc0201f1a:	4605                	li	a2,1
ffffffffc0201f1c:	b7d1                	j	ffffffffc0201ee0 <slob_alloc.constprop.0+0x6c>
ffffffffc0201f1e:	d4ffe0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0201f22:	b74d                	j	ffffffffc0201ec4 <slob_alloc.constprop.0+0x50>
ffffffffc0201f24:	d49fe0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0201f28:	60e2                	ld	ra,24(sp)
ffffffffc0201f2a:	8522                	mv	a0,s0
ffffffffc0201f2c:	6442                	ld	s0,16(sp)
ffffffffc0201f2e:	64a2                	ld	s1,8(sp)
ffffffffc0201f30:	6902                	ld	s2,0(sp)
ffffffffc0201f32:	6105                	addi	sp,sp,32
ffffffffc0201f34:	8082                	ret
ffffffffc0201f36:	6418                	ld	a4,8(s0)
ffffffffc0201f38:	e798                	sd	a4,8(a5)
ffffffffc0201f3a:	b7d1                	j	ffffffffc0201efe <slob_alloc.constprop.0+0x8a>
ffffffffc0201f3c:	d37fe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0201f40:	4605                	li	a2,1
ffffffffc0201f42:	bf99                	j	ffffffffc0201e98 <slob_alloc.constprop.0+0x24>
ffffffffc0201f44:	843e                	mv	s0,a5
ffffffffc0201f46:	87b6                	mv	a5,a3
ffffffffc0201f48:	b745                	j	ffffffffc0201ee8 <slob_alloc.constprop.0+0x74>
ffffffffc0201f4a:	0000b697          	auipc	a3,0xb
ffffffffc0201f4e:	af668693          	addi	a3,a3,-1290 # ffffffffc020ca40 <default_pmm_manager+0x70>
ffffffffc0201f52:	0000a617          	auipc	a2,0xa
ffffffffc0201f56:	f9660613          	addi	a2,a2,-106 # ffffffffc020bee8 <commands+0x210>
ffffffffc0201f5a:	06300593          	li	a1,99
ffffffffc0201f5e:	0000b517          	auipc	a0,0xb
ffffffffc0201f62:	b0250513          	addi	a0,a0,-1278 # ffffffffc020ca60 <default_pmm_manager+0x90>
ffffffffc0201f66:	d38fe0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0201f6a <kmalloc_init>:
ffffffffc0201f6a:	1141                	addi	sp,sp,-16
ffffffffc0201f6c:	0000b517          	auipc	a0,0xb
ffffffffc0201f70:	b0c50513          	addi	a0,a0,-1268 # ffffffffc020ca78 <default_pmm_manager+0xa8>
ffffffffc0201f74:	e406                	sd	ra,8(sp)
ffffffffc0201f76:	a30fe0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0201f7a:	60a2                	ld	ra,8(sp)
ffffffffc0201f7c:	0000b517          	auipc	a0,0xb
ffffffffc0201f80:	b1450513          	addi	a0,a0,-1260 # ffffffffc020ca90 <default_pmm_manager+0xc0>
ffffffffc0201f84:	0141                	addi	sp,sp,16
ffffffffc0201f86:	a20fe06f          	j	ffffffffc02001a6 <cprintf>

ffffffffc0201f8a <kallocated>:
ffffffffc0201f8a:	4501                	li	a0,0
ffffffffc0201f8c:	8082                	ret

ffffffffc0201f8e <kmalloc>:
ffffffffc0201f8e:	1101                	addi	sp,sp,-32
ffffffffc0201f90:	e04a                	sd	s2,0(sp)
ffffffffc0201f92:	6905                	lui	s2,0x1
ffffffffc0201f94:	e822                	sd	s0,16(sp)
ffffffffc0201f96:	ec06                	sd	ra,24(sp)
ffffffffc0201f98:	e426                	sd	s1,8(sp)
ffffffffc0201f9a:	fef90793          	addi	a5,s2,-17 # fef <_binary_bin_swap_img_size-0x6d11>
ffffffffc0201f9e:	842a                	mv	s0,a0
ffffffffc0201fa0:	04a7f963          	bgeu	a5,a0,ffffffffc0201ff2 <kmalloc+0x64>
ffffffffc0201fa4:	4561                	li	a0,24
ffffffffc0201fa6:	ecfff0ef          	jal	ra,ffffffffc0201e74 <slob_alloc.constprop.0>
ffffffffc0201faa:	84aa                	mv	s1,a0
ffffffffc0201fac:	c929                	beqz	a0,ffffffffc0201ffe <kmalloc+0x70>
ffffffffc0201fae:	0004079b          	sext.w	a5,s0
ffffffffc0201fb2:	4501                	li	a0,0
ffffffffc0201fb4:	00f95763          	bge	s2,a5,ffffffffc0201fc2 <kmalloc+0x34>
ffffffffc0201fb8:	6705                	lui	a4,0x1
ffffffffc0201fba:	8785                	srai	a5,a5,0x1
ffffffffc0201fbc:	2505                	addiw	a0,a0,1
ffffffffc0201fbe:	fef74ee3          	blt	a4,a5,ffffffffc0201fba <kmalloc+0x2c>
ffffffffc0201fc2:	c088                	sw	a0,0(s1)
ffffffffc0201fc4:	e4dff0ef          	jal	ra,ffffffffc0201e10 <__slob_get_free_pages.constprop.0>
ffffffffc0201fc8:	e488                	sd	a0,8(s1)
ffffffffc0201fca:	842a                	mv	s0,a0
ffffffffc0201fcc:	c525                	beqz	a0,ffffffffc0202034 <kmalloc+0xa6>
ffffffffc0201fce:	100027f3          	csrr	a5,sstatus
ffffffffc0201fd2:	8b89                	andi	a5,a5,2
ffffffffc0201fd4:	ef8d                	bnez	a5,ffffffffc020200e <kmalloc+0x80>
ffffffffc0201fd6:	00095797          	auipc	a5,0x95
ffffffffc0201fda:	8b278793          	addi	a5,a5,-1870 # ffffffffc0296888 <bigblocks>
ffffffffc0201fde:	6398                	ld	a4,0(a5)
ffffffffc0201fe0:	e384                	sd	s1,0(a5)
ffffffffc0201fe2:	e898                	sd	a4,16(s1)
ffffffffc0201fe4:	60e2                	ld	ra,24(sp)
ffffffffc0201fe6:	8522                	mv	a0,s0
ffffffffc0201fe8:	6442                	ld	s0,16(sp)
ffffffffc0201fea:	64a2                	ld	s1,8(sp)
ffffffffc0201fec:	6902                	ld	s2,0(sp)
ffffffffc0201fee:	6105                	addi	sp,sp,32
ffffffffc0201ff0:	8082                	ret
ffffffffc0201ff2:	0541                	addi	a0,a0,16
ffffffffc0201ff4:	e81ff0ef          	jal	ra,ffffffffc0201e74 <slob_alloc.constprop.0>
ffffffffc0201ff8:	01050413          	addi	s0,a0,16
ffffffffc0201ffc:	f565                	bnez	a0,ffffffffc0201fe4 <kmalloc+0x56>
ffffffffc0201ffe:	4401                	li	s0,0
ffffffffc0202000:	60e2                	ld	ra,24(sp)
ffffffffc0202002:	8522                	mv	a0,s0
ffffffffc0202004:	6442                	ld	s0,16(sp)
ffffffffc0202006:	64a2                	ld	s1,8(sp)
ffffffffc0202008:	6902                	ld	s2,0(sp)
ffffffffc020200a:	6105                	addi	sp,sp,32
ffffffffc020200c:	8082                	ret
ffffffffc020200e:	c65fe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0202012:	00095797          	auipc	a5,0x95
ffffffffc0202016:	87678793          	addi	a5,a5,-1930 # ffffffffc0296888 <bigblocks>
ffffffffc020201a:	6398                	ld	a4,0(a5)
ffffffffc020201c:	e384                	sd	s1,0(a5)
ffffffffc020201e:	e898                	sd	a4,16(s1)
ffffffffc0202020:	c4dfe0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0202024:	6480                	ld	s0,8(s1)
ffffffffc0202026:	60e2                	ld	ra,24(sp)
ffffffffc0202028:	64a2                	ld	s1,8(sp)
ffffffffc020202a:	8522                	mv	a0,s0
ffffffffc020202c:	6442                	ld	s0,16(sp)
ffffffffc020202e:	6902                	ld	s2,0(sp)
ffffffffc0202030:	6105                	addi	sp,sp,32
ffffffffc0202032:	8082                	ret
ffffffffc0202034:	45e1                	li	a1,24
ffffffffc0202036:	8526                	mv	a0,s1
ffffffffc0202038:	d25ff0ef          	jal	ra,ffffffffc0201d5c <slob_free>
ffffffffc020203c:	b765                	j	ffffffffc0201fe4 <kmalloc+0x56>

ffffffffc020203e <kfree>:
ffffffffc020203e:	c169                	beqz	a0,ffffffffc0202100 <kfree+0xc2>
ffffffffc0202040:	1101                	addi	sp,sp,-32
ffffffffc0202042:	e822                	sd	s0,16(sp)
ffffffffc0202044:	ec06                	sd	ra,24(sp)
ffffffffc0202046:	e426                	sd	s1,8(sp)
ffffffffc0202048:	03451793          	slli	a5,a0,0x34
ffffffffc020204c:	842a                	mv	s0,a0
ffffffffc020204e:	e3d9                	bnez	a5,ffffffffc02020d4 <kfree+0x96>
ffffffffc0202050:	100027f3          	csrr	a5,sstatus
ffffffffc0202054:	8b89                	andi	a5,a5,2
ffffffffc0202056:	e7d9                	bnez	a5,ffffffffc02020e4 <kfree+0xa6>
ffffffffc0202058:	00095797          	auipc	a5,0x95
ffffffffc020205c:	8307b783          	ld	a5,-2000(a5) # ffffffffc0296888 <bigblocks>
ffffffffc0202060:	4601                	li	a2,0
ffffffffc0202062:	cbad                	beqz	a5,ffffffffc02020d4 <kfree+0x96>
ffffffffc0202064:	00095697          	auipc	a3,0x95
ffffffffc0202068:	82468693          	addi	a3,a3,-2012 # ffffffffc0296888 <bigblocks>
ffffffffc020206c:	a021                	j	ffffffffc0202074 <kfree+0x36>
ffffffffc020206e:	01048693          	addi	a3,s1,16
ffffffffc0202072:	c3a5                	beqz	a5,ffffffffc02020d2 <kfree+0x94>
ffffffffc0202074:	6798                	ld	a4,8(a5)
ffffffffc0202076:	84be                	mv	s1,a5
ffffffffc0202078:	6b9c                	ld	a5,16(a5)
ffffffffc020207a:	fe871ae3          	bne	a4,s0,ffffffffc020206e <kfree+0x30>
ffffffffc020207e:	e29c                	sd	a5,0(a3)
ffffffffc0202080:	ee2d                	bnez	a2,ffffffffc02020fa <kfree+0xbc>
ffffffffc0202082:	c02007b7          	lui	a5,0xc0200
ffffffffc0202086:	4098                	lw	a4,0(s1)
ffffffffc0202088:	08f46963          	bltu	s0,a5,ffffffffc020211a <kfree+0xdc>
ffffffffc020208c:	00095697          	auipc	a3,0x95
ffffffffc0202090:	82c6b683          	ld	a3,-2004(a3) # ffffffffc02968b8 <va_pa_offset>
ffffffffc0202094:	8c15                	sub	s0,s0,a3
ffffffffc0202096:	8031                	srli	s0,s0,0xc
ffffffffc0202098:	00095797          	auipc	a5,0x95
ffffffffc020209c:	8087b783          	ld	a5,-2040(a5) # ffffffffc02968a0 <npage>
ffffffffc02020a0:	06f47163          	bgeu	s0,a5,ffffffffc0202102 <kfree+0xc4>
ffffffffc02020a4:	0000e517          	auipc	a0,0xe
ffffffffc02020a8:	d2c53503          	ld	a0,-724(a0) # ffffffffc020fdd0 <nbase>
ffffffffc02020ac:	8c09                	sub	s0,s0,a0
ffffffffc02020ae:	041a                	slli	s0,s0,0x6
ffffffffc02020b0:	00094517          	auipc	a0,0x94
ffffffffc02020b4:	7f853503          	ld	a0,2040(a0) # ffffffffc02968a8 <pages>
ffffffffc02020b8:	4585                	li	a1,1
ffffffffc02020ba:	9522                	add	a0,a0,s0
ffffffffc02020bc:	00e595bb          	sllw	a1,a1,a4
ffffffffc02020c0:	0ea000ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc02020c4:	6442                	ld	s0,16(sp)
ffffffffc02020c6:	60e2                	ld	ra,24(sp)
ffffffffc02020c8:	8526                	mv	a0,s1
ffffffffc02020ca:	64a2                	ld	s1,8(sp)
ffffffffc02020cc:	45e1                	li	a1,24
ffffffffc02020ce:	6105                	addi	sp,sp,32
ffffffffc02020d0:	b171                	j	ffffffffc0201d5c <slob_free>
ffffffffc02020d2:	e20d                	bnez	a2,ffffffffc02020f4 <kfree+0xb6>
ffffffffc02020d4:	ff040513          	addi	a0,s0,-16
ffffffffc02020d8:	6442                	ld	s0,16(sp)
ffffffffc02020da:	60e2                	ld	ra,24(sp)
ffffffffc02020dc:	64a2                	ld	s1,8(sp)
ffffffffc02020de:	4581                	li	a1,0
ffffffffc02020e0:	6105                	addi	sp,sp,32
ffffffffc02020e2:	b9ad                	j	ffffffffc0201d5c <slob_free>
ffffffffc02020e4:	b8ffe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02020e8:	00094797          	auipc	a5,0x94
ffffffffc02020ec:	7a07b783          	ld	a5,1952(a5) # ffffffffc0296888 <bigblocks>
ffffffffc02020f0:	4605                	li	a2,1
ffffffffc02020f2:	fbad                	bnez	a5,ffffffffc0202064 <kfree+0x26>
ffffffffc02020f4:	b79fe0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02020f8:	bff1                	j	ffffffffc02020d4 <kfree+0x96>
ffffffffc02020fa:	b73fe0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02020fe:	b751                	j	ffffffffc0202082 <kfree+0x44>
ffffffffc0202100:	8082                	ret
ffffffffc0202102:	0000b617          	auipc	a2,0xb
ffffffffc0202106:	9d660613          	addi	a2,a2,-1578 # ffffffffc020cad8 <default_pmm_manager+0x108>
ffffffffc020210a:	06900593          	li	a1,105
ffffffffc020210e:	0000b517          	auipc	a0,0xb
ffffffffc0202112:	92250513          	addi	a0,a0,-1758 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0202116:	b88fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020211a:	86a2                	mv	a3,s0
ffffffffc020211c:	0000b617          	auipc	a2,0xb
ffffffffc0202120:	99460613          	addi	a2,a2,-1644 # ffffffffc020cab0 <default_pmm_manager+0xe0>
ffffffffc0202124:	07700593          	li	a1,119
ffffffffc0202128:	0000b517          	auipc	a0,0xb
ffffffffc020212c:	90850513          	addi	a0,a0,-1784 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0202130:	b6efe0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0202134 <pa2page.part.0>:
ffffffffc0202134:	1141                	addi	sp,sp,-16
ffffffffc0202136:	0000b617          	auipc	a2,0xb
ffffffffc020213a:	9a260613          	addi	a2,a2,-1630 # ffffffffc020cad8 <default_pmm_manager+0x108>
ffffffffc020213e:	06900593          	li	a1,105
ffffffffc0202142:	0000b517          	auipc	a0,0xb
ffffffffc0202146:	8ee50513          	addi	a0,a0,-1810 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc020214a:	e406                	sd	ra,8(sp)
ffffffffc020214c:	b52fe0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0202150 <pte2page.part.0>:
ffffffffc0202150:	1141                	addi	sp,sp,-16
ffffffffc0202152:	0000b617          	auipc	a2,0xb
ffffffffc0202156:	9a660613          	addi	a2,a2,-1626 # ffffffffc020caf8 <default_pmm_manager+0x128>
ffffffffc020215a:	07f00593          	li	a1,127
ffffffffc020215e:	0000b517          	auipc	a0,0xb
ffffffffc0202162:	8d250513          	addi	a0,a0,-1838 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0202166:	e406                	sd	ra,8(sp)
ffffffffc0202168:	b36fe0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020216c <alloc_pages>:
ffffffffc020216c:	100027f3          	csrr	a5,sstatus
ffffffffc0202170:	8b89                	andi	a5,a5,2
ffffffffc0202172:	e799                	bnez	a5,ffffffffc0202180 <alloc_pages+0x14>
ffffffffc0202174:	00094797          	auipc	a5,0x94
ffffffffc0202178:	73c7b783          	ld	a5,1852(a5) # ffffffffc02968b0 <pmm_manager>
ffffffffc020217c:	6f9c                	ld	a5,24(a5)
ffffffffc020217e:	8782                	jr	a5
ffffffffc0202180:	1141                	addi	sp,sp,-16
ffffffffc0202182:	e406                	sd	ra,8(sp)
ffffffffc0202184:	e022                	sd	s0,0(sp)
ffffffffc0202186:	842a                	mv	s0,a0
ffffffffc0202188:	aebfe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc020218c:	00094797          	auipc	a5,0x94
ffffffffc0202190:	7247b783          	ld	a5,1828(a5) # ffffffffc02968b0 <pmm_manager>
ffffffffc0202194:	6f9c                	ld	a5,24(a5)
ffffffffc0202196:	8522                	mv	a0,s0
ffffffffc0202198:	9782                	jalr	a5
ffffffffc020219a:	842a                	mv	s0,a0
ffffffffc020219c:	ad1fe0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02021a0:	60a2                	ld	ra,8(sp)
ffffffffc02021a2:	8522                	mv	a0,s0
ffffffffc02021a4:	6402                	ld	s0,0(sp)
ffffffffc02021a6:	0141                	addi	sp,sp,16
ffffffffc02021a8:	8082                	ret

ffffffffc02021aa <free_pages>:
ffffffffc02021aa:	100027f3          	csrr	a5,sstatus
ffffffffc02021ae:	8b89                	andi	a5,a5,2
ffffffffc02021b0:	e799                	bnez	a5,ffffffffc02021be <free_pages+0x14>
ffffffffc02021b2:	00094797          	auipc	a5,0x94
ffffffffc02021b6:	6fe7b783          	ld	a5,1790(a5) # ffffffffc02968b0 <pmm_manager>
ffffffffc02021ba:	739c                	ld	a5,32(a5)
ffffffffc02021bc:	8782                	jr	a5
ffffffffc02021be:	1101                	addi	sp,sp,-32
ffffffffc02021c0:	ec06                	sd	ra,24(sp)
ffffffffc02021c2:	e822                	sd	s0,16(sp)
ffffffffc02021c4:	e426                	sd	s1,8(sp)
ffffffffc02021c6:	842a                	mv	s0,a0
ffffffffc02021c8:	84ae                	mv	s1,a1
ffffffffc02021ca:	aa9fe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02021ce:	00094797          	auipc	a5,0x94
ffffffffc02021d2:	6e27b783          	ld	a5,1762(a5) # ffffffffc02968b0 <pmm_manager>
ffffffffc02021d6:	739c                	ld	a5,32(a5)
ffffffffc02021d8:	85a6                	mv	a1,s1
ffffffffc02021da:	8522                	mv	a0,s0
ffffffffc02021dc:	9782                	jalr	a5
ffffffffc02021de:	6442                	ld	s0,16(sp)
ffffffffc02021e0:	60e2                	ld	ra,24(sp)
ffffffffc02021e2:	64a2                	ld	s1,8(sp)
ffffffffc02021e4:	6105                	addi	sp,sp,32
ffffffffc02021e6:	a87fe06f          	j	ffffffffc0200c6c <intr_enable>

ffffffffc02021ea <nr_free_pages>:
ffffffffc02021ea:	100027f3          	csrr	a5,sstatus
ffffffffc02021ee:	8b89                	andi	a5,a5,2
ffffffffc02021f0:	e799                	bnez	a5,ffffffffc02021fe <nr_free_pages+0x14>
ffffffffc02021f2:	00094797          	auipc	a5,0x94
ffffffffc02021f6:	6be7b783          	ld	a5,1726(a5) # ffffffffc02968b0 <pmm_manager>
ffffffffc02021fa:	779c                	ld	a5,40(a5)
ffffffffc02021fc:	8782                	jr	a5
ffffffffc02021fe:	1141                	addi	sp,sp,-16
ffffffffc0202200:	e406                	sd	ra,8(sp)
ffffffffc0202202:	e022                	sd	s0,0(sp)
ffffffffc0202204:	a6ffe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0202208:	00094797          	auipc	a5,0x94
ffffffffc020220c:	6a87b783          	ld	a5,1704(a5) # ffffffffc02968b0 <pmm_manager>
ffffffffc0202210:	779c                	ld	a5,40(a5)
ffffffffc0202212:	9782                	jalr	a5
ffffffffc0202214:	842a                	mv	s0,a0
ffffffffc0202216:	a57fe0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc020221a:	60a2                	ld	ra,8(sp)
ffffffffc020221c:	8522                	mv	a0,s0
ffffffffc020221e:	6402                	ld	s0,0(sp)
ffffffffc0202220:	0141                	addi	sp,sp,16
ffffffffc0202222:	8082                	ret

ffffffffc0202224 <get_pte>:
ffffffffc0202224:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202228:	1ff7f793          	andi	a5,a5,511
ffffffffc020222c:	7139                	addi	sp,sp,-64
ffffffffc020222e:	078e                	slli	a5,a5,0x3
ffffffffc0202230:	f426                	sd	s1,40(sp)
ffffffffc0202232:	00f504b3          	add	s1,a0,a5
ffffffffc0202236:	6094                	ld	a3,0(s1)
ffffffffc0202238:	f04a                	sd	s2,32(sp)
ffffffffc020223a:	ec4e                	sd	s3,24(sp)
ffffffffc020223c:	e852                	sd	s4,16(sp)
ffffffffc020223e:	fc06                	sd	ra,56(sp)
ffffffffc0202240:	f822                	sd	s0,48(sp)
ffffffffc0202242:	e456                	sd	s5,8(sp)
ffffffffc0202244:	e05a                	sd	s6,0(sp)
ffffffffc0202246:	0016f793          	andi	a5,a3,1
ffffffffc020224a:	892e                	mv	s2,a1
ffffffffc020224c:	8a32                	mv	s4,a2
ffffffffc020224e:	00094997          	auipc	s3,0x94
ffffffffc0202252:	65298993          	addi	s3,s3,1618 # ffffffffc02968a0 <npage>
ffffffffc0202256:	efbd                	bnez	a5,ffffffffc02022d4 <get_pte+0xb0>
ffffffffc0202258:	14060c63          	beqz	a2,ffffffffc02023b0 <get_pte+0x18c>
ffffffffc020225c:	100027f3          	csrr	a5,sstatus
ffffffffc0202260:	8b89                	andi	a5,a5,2
ffffffffc0202262:	14079963          	bnez	a5,ffffffffc02023b4 <get_pte+0x190>
ffffffffc0202266:	00094797          	auipc	a5,0x94
ffffffffc020226a:	64a7b783          	ld	a5,1610(a5) # ffffffffc02968b0 <pmm_manager>
ffffffffc020226e:	6f9c                	ld	a5,24(a5)
ffffffffc0202270:	4505                	li	a0,1
ffffffffc0202272:	9782                	jalr	a5
ffffffffc0202274:	842a                	mv	s0,a0
ffffffffc0202276:	12040d63          	beqz	s0,ffffffffc02023b0 <get_pte+0x18c>
ffffffffc020227a:	00094b17          	auipc	s6,0x94
ffffffffc020227e:	62eb0b13          	addi	s6,s6,1582 # ffffffffc02968a8 <pages>
ffffffffc0202282:	000b3503          	ld	a0,0(s6)
ffffffffc0202286:	00080ab7          	lui	s5,0x80
ffffffffc020228a:	00094997          	auipc	s3,0x94
ffffffffc020228e:	61698993          	addi	s3,s3,1558 # ffffffffc02968a0 <npage>
ffffffffc0202292:	40a40533          	sub	a0,s0,a0
ffffffffc0202296:	8519                	srai	a0,a0,0x6
ffffffffc0202298:	9556                	add	a0,a0,s5
ffffffffc020229a:	0009b703          	ld	a4,0(s3)
ffffffffc020229e:	00c51793          	slli	a5,a0,0xc
ffffffffc02022a2:	4685                	li	a3,1
ffffffffc02022a4:	c014                	sw	a3,0(s0)
ffffffffc02022a6:	83b1                	srli	a5,a5,0xc
ffffffffc02022a8:	0532                	slli	a0,a0,0xc
ffffffffc02022aa:	16e7f763          	bgeu	a5,a4,ffffffffc0202418 <get_pte+0x1f4>
ffffffffc02022ae:	00094797          	auipc	a5,0x94
ffffffffc02022b2:	60a7b783          	ld	a5,1546(a5) # ffffffffc02968b8 <va_pa_offset>
ffffffffc02022b6:	6605                	lui	a2,0x1
ffffffffc02022b8:	4581                	li	a1,0
ffffffffc02022ba:	953e                	add	a0,a0,a5
ffffffffc02022bc:	748090ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc02022c0:	000b3683          	ld	a3,0(s6)
ffffffffc02022c4:	40d406b3          	sub	a3,s0,a3
ffffffffc02022c8:	8699                	srai	a3,a3,0x6
ffffffffc02022ca:	96d6                	add	a3,a3,s5
ffffffffc02022cc:	06aa                	slli	a3,a3,0xa
ffffffffc02022ce:	0116e693          	ori	a3,a3,17
ffffffffc02022d2:	e094                	sd	a3,0(s1)
ffffffffc02022d4:	77fd                	lui	a5,0xfffff
ffffffffc02022d6:	068a                	slli	a3,a3,0x2
ffffffffc02022d8:	0009b703          	ld	a4,0(s3)
ffffffffc02022dc:	8efd                	and	a3,a3,a5
ffffffffc02022de:	00c6d793          	srli	a5,a3,0xc
ffffffffc02022e2:	10e7ff63          	bgeu	a5,a4,ffffffffc0202400 <get_pte+0x1dc>
ffffffffc02022e6:	00094a97          	auipc	s5,0x94
ffffffffc02022ea:	5d2a8a93          	addi	s5,s5,1490 # ffffffffc02968b8 <va_pa_offset>
ffffffffc02022ee:	000ab403          	ld	s0,0(s5)
ffffffffc02022f2:	01595793          	srli	a5,s2,0x15
ffffffffc02022f6:	1ff7f793          	andi	a5,a5,511
ffffffffc02022fa:	96a2                	add	a3,a3,s0
ffffffffc02022fc:	00379413          	slli	s0,a5,0x3
ffffffffc0202300:	9436                	add	s0,s0,a3
ffffffffc0202302:	6014                	ld	a3,0(s0)
ffffffffc0202304:	0016f793          	andi	a5,a3,1
ffffffffc0202308:	ebad                	bnez	a5,ffffffffc020237a <get_pte+0x156>
ffffffffc020230a:	0a0a0363          	beqz	s4,ffffffffc02023b0 <get_pte+0x18c>
ffffffffc020230e:	100027f3          	csrr	a5,sstatus
ffffffffc0202312:	8b89                	andi	a5,a5,2
ffffffffc0202314:	efcd                	bnez	a5,ffffffffc02023ce <get_pte+0x1aa>
ffffffffc0202316:	00094797          	auipc	a5,0x94
ffffffffc020231a:	59a7b783          	ld	a5,1434(a5) # ffffffffc02968b0 <pmm_manager>
ffffffffc020231e:	6f9c                	ld	a5,24(a5)
ffffffffc0202320:	4505                	li	a0,1
ffffffffc0202322:	9782                	jalr	a5
ffffffffc0202324:	84aa                	mv	s1,a0
ffffffffc0202326:	c4c9                	beqz	s1,ffffffffc02023b0 <get_pte+0x18c>
ffffffffc0202328:	00094b17          	auipc	s6,0x94
ffffffffc020232c:	580b0b13          	addi	s6,s6,1408 # ffffffffc02968a8 <pages>
ffffffffc0202330:	000b3503          	ld	a0,0(s6)
ffffffffc0202334:	00080a37          	lui	s4,0x80
ffffffffc0202338:	0009b703          	ld	a4,0(s3)
ffffffffc020233c:	40a48533          	sub	a0,s1,a0
ffffffffc0202340:	8519                	srai	a0,a0,0x6
ffffffffc0202342:	9552                	add	a0,a0,s4
ffffffffc0202344:	00c51793          	slli	a5,a0,0xc
ffffffffc0202348:	4685                	li	a3,1
ffffffffc020234a:	c094                	sw	a3,0(s1)
ffffffffc020234c:	83b1                	srli	a5,a5,0xc
ffffffffc020234e:	0532                	slli	a0,a0,0xc
ffffffffc0202350:	0ee7f163          	bgeu	a5,a4,ffffffffc0202432 <get_pte+0x20e>
ffffffffc0202354:	000ab783          	ld	a5,0(s5)
ffffffffc0202358:	6605                	lui	a2,0x1
ffffffffc020235a:	4581                	li	a1,0
ffffffffc020235c:	953e                	add	a0,a0,a5
ffffffffc020235e:	6a6090ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc0202362:	000b3683          	ld	a3,0(s6)
ffffffffc0202366:	40d486b3          	sub	a3,s1,a3
ffffffffc020236a:	8699                	srai	a3,a3,0x6
ffffffffc020236c:	96d2                	add	a3,a3,s4
ffffffffc020236e:	06aa                	slli	a3,a3,0xa
ffffffffc0202370:	0116e693          	ori	a3,a3,17
ffffffffc0202374:	e014                	sd	a3,0(s0)
ffffffffc0202376:	0009b703          	ld	a4,0(s3)
ffffffffc020237a:	068a                	slli	a3,a3,0x2
ffffffffc020237c:	757d                	lui	a0,0xfffff
ffffffffc020237e:	8ee9                	and	a3,a3,a0
ffffffffc0202380:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202384:	06e7f263          	bgeu	a5,a4,ffffffffc02023e8 <get_pte+0x1c4>
ffffffffc0202388:	000ab503          	ld	a0,0(s5)
ffffffffc020238c:	00c95913          	srli	s2,s2,0xc
ffffffffc0202390:	1ff97913          	andi	s2,s2,511
ffffffffc0202394:	96aa                	add	a3,a3,a0
ffffffffc0202396:	00391513          	slli	a0,s2,0x3
ffffffffc020239a:	9536                	add	a0,a0,a3
ffffffffc020239c:	70e2                	ld	ra,56(sp)
ffffffffc020239e:	7442                	ld	s0,48(sp)
ffffffffc02023a0:	74a2                	ld	s1,40(sp)
ffffffffc02023a2:	7902                	ld	s2,32(sp)
ffffffffc02023a4:	69e2                	ld	s3,24(sp)
ffffffffc02023a6:	6a42                	ld	s4,16(sp)
ffffffffc02023a8:	6aa2                	ld	s5,8(sp)
ffffffffc02023aa:	6b02                	ld	s6,0(sp)
ffffffffc02023ac:	6121                	addi	sp,sp,64
ffffffffc02023ae:	8082                	ret
ffffffffc02023b0:	4501                	li	a0,0
ffffffffc02023b2:	b7ed                	j	ffffffffc020239c <get_pte+0x178>
ffffffffc02023b4:	8bffe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02023b8:	00094797          	auipc	a5,0x94
ffffffffc02023bc:	4f87b783          	ld	a5,1272(a5) # ffffffffc02968b0 <pmm_manager>
ffffffffc02023c0:	6f9c                	ld	a5,24(a5)
ffffffffc02023c2:	4505                	li	a0,1
ffffffffc02023c4:	9782                	jalr	a5
ffffffffc02023c6:	842a                	mv	s0,a0
ffffffffc02023c8:	8a5fe0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02023cc:	b56d                	j	ffffffffc0202276 <get_pte+0x52>
ffffffffc02023ce:	8a5fe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02023d2:	00094797          	auipc	a5,0x94
ffffffffc02023d6:	4de7b783          	ld	a5,1246(a5) # ffffffffc02968b0 <pmm_manager>
ffffffffc02023da:	6f9c                	ld	a5,24(a5)
ffffffffc02023dc:	4505                	li	a0,1
ffffffffc02023de:	9782                	jalr	a5
ffffffffc02023e0:	84aa                	mv	s1,a0
ffffffffc02023e2:	88bfe0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02023e6:	b781                	j	ffffffffc0202326 <get_pte+0x102>
ffffffffc02023e8:	0000a617          	auipc	a2,0xa
ffffffffc02023ec:	62060613          	addi	a2,a2,1568 # ffffffffc020ca08 <default_pmm_manager+0x38>
ffffffffc02023f0:	13200593          	li	a1,306
ffffffffc02023f4:	0000a517          	auipc	a0,0xa
ffffffffc02023f8:	72c50513          	addi	a0,a0,1836 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02023fc:	8a2fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0202400:	0000a617          	auipc	a2,0xa
ffffffffc0202404:	60860613          	addi	a2,a2,1544 # ffffffffc020ca08 <default_pmm_manager+0x38>
ffffffffc0202408:	12500593          	li	a1,293
ffffffffc020240c:	0000a517          	auipc	a0,0xa
ffffffffc0202410:	71450513          	addi	a0,a0,1812 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0202414:	88afe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0202418:	86aa                	mv	a3,a0
ffffffffc020241a:	0000a617          	auipc	a2,0xa
ffffffffc020241e:	5ee60613          	addi	a2,a2,1518 # ffffffffc020ca08 <default_pmm_manager+0x38>
ffffffffc0202422:	12100593          	li	a1,289
ffffffffc0202426:	0000a517          	auipc	a0,0xa
ffffffffc020242a:	6fa50513          	addi	a0,a0,1786 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020242e:	870fe0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0202432:	86aa                	mv	a3,a0
ffffffffc0202434:	0000a617          	auipc	a2,0xa
ffffffffc0202438:	5d460613          	addi	a2,a2,1492 # ffffffffc020ca08 <default_pmm_manager+0x38>
ffffffffc020243c:	12f00593          	li	a1,303
ffffffffc0202440:	0000a517          	auipc	a0,0xa
ffffffffc0202444:	6e050513          	addi	a0,a0,1760 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0202448:	856fe0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020244c <boot_map_segment>:
ffffffffc020244c:	6785                	lui	a5,0x1
ffffffffc020244e:	7139                	addi	sp,sp,-64
ffffffffc0202450:	00d5c833          	xor	a6,a1,a3
ffffffffc0202454:	17fd                	addi	a5,a5,-1
ffffffffc0202456:	fc06                	sd	ra,56(sp)
ffffffffc0202458:	f822                	sd	s0,48(sp)
ffffffffc020245a:	f426                	sd	s1,40(sp)
ffffffffc020245c:	f04a                	sd	s2,32(sp)
ffffffffc020245e:	ec4e                	sd	s3,24(sp)
ffffffffc0202460:	e852                	sd	s4,16(sp)
ffffffffc0202462:	e456                	sd	s5,8(sp)
ffffffffc0202464:	00f87833          	and	a6,a6,a5
ffffffffc0202468:	08081563          	bnez	a6,ffffffffc02024f2 <boot_map_segment+0xa6>
ffffffffc020246c:	00f5f4b3          	and	s1,a1,a5
ffffffffc0202470:	963e                	add	a2,a2,a5
ffffffffc0202472:	94b2                	add	s1,s1,a2
ffffffffc0202474:	797d                	lui	s2,0xfffff
ffffffffc0202476:	80b1                	srli	s1,s1,0xc
ffffffffc0202478:	0125f5b3          	and	a1,a1,s2
ffffffffc020247c:	0126f6b3          	and	a3,a3,s2
ffffffffc0202480:	c0a1                	beqz	s1,ffffffffc02024c0 <boot_map_segment+0x74>
ffffffffc0202482:	00176713          	ori	a4,a4,1
ffffffffc0202486:	04b2                	slli	s1,s1,0xc
ffffffffc0202488:	02071993          	slli	s3,a4,0x20
ffffffffc020248c:	8a2a                	mv	s4,a0
ffffffffc020248e:	842e                	mv	s0,a1
ffffffffc0202490:	94ae                	add	s1,s1,a1
ffffffffc0202492:	40b68933          	sub	s2,a3,a1
ffffffffc0202496:	0209d993          	srli	s3,s3,0x20
ffffffffc020249a:	6a85                	lui	s5,0x1
ffffffffc020249c:	4605                	li	a2,1
ffffffffc020249e:	85a2                	mv	a1,s0
ffffffffc02024a0:	8552                	mv	a0,s4
ffffffffc02024a2:	d83ff0ef          	jal	ra,ffffffffc0202224 <get_pte>
ffffffffc02024a6:	008907b3          	add	a5,s2,s0
ffffffffc02024aa:	c505                	beqz	a0,ffffffffc02024d2 <boot_map_segment+0x86>
ffffffffc02024ac:	83b1                	srli	a5,a5,0xc
ffffffffc02024ae:	07aa                	slli	a5,a5,0xa
ffffffffc02024b0:	0137e7b3          	or	a5,a5,s3
ffffffffc02024b4:	0017e793          	ori	a5,a5,1
ffffffffc02024b8:	e11c                	sd	a5,0(a0)
ffffffffc02024ba:	9456                	add	s0,s0,s5
ffffffffc02024bc:	fe8490e3          	bne	s1,s0,ffffffffc020249c <boot_map_segment+0x50>
ffffffffc02024c0:	70e2                	ld	ra,56(sp)
ffffffffc02024c2:	7442                	ld	s0,48(sp)
ffffffffc02024c4:	74a2                	ld	s1,40(sp)
ffffffffc02024c6:	7902                	ld	s2,32(sp)
ffffffffc02024c8:	69e2                	ld	s3,24(sp)
ffffffffc02024ca:	6a42                	ld	s4,16(sp)
ffffffffc02024cc:	6aa2                	ld	s5,8(sp)
ffffffffc02024ce:	6121                	addi	sp,sp,64
ffffffffc02024d0:	8082                	ret
ffffffffc02024d2:	0000a697          	auipc	a3,0xa
ffffffffc02024d6:	67668693          	addi	a3,a3,1654 # ffffffffc020cb48 <default_pmm_manager+0x178>
ffffffffc02024da:	0000a617          	auipc	a2,0xa
ffffffffc02024de:	a0e60613          	addi	a2,a2,-1522 # ffffffffc020bee8 <commands+0x210>
ffffffffc02024e2:	09c00593          	li	a1,156
ffffffffc02024e6:	0000a517          	auipc	a0,0xa
ffffffffc02024ea:	63a50513          	addi	a0,a0,1594 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02024ee:	fb1fd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02024f2:	0000a697          	auipc	a3,0xa
ffffffffc02024f6:	63e68693          	addi	a3,a3,1598 # ffffffffc020cb30 <default_pmm_manager+0x160>
ffffffffc02024fa:	0000a617          	auipc	a2,0xa
ffffffffc02024fe:	9ee60613          	addi	a2,a2,-1554 # ffffffffc020bee8 <commands+0x210>
ffffffffc0202502:	09500593          	li	a1,149
ffffffffc0202506:	0000a517          	auipc	a0,0xa
ffffffffc020250a:	61a50513          	addi	a0,a0,1562 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020250e:	f91fd0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0202512 <get_page>:
ffffffffc0202512:	1141                	addi	sp,sp,-16
ffffffffc0202514:	e022                	sd	s0,0(sp)
ffffffffc0202516:	8432                	mv	s0,a2
ffffffffc0202518:	4601                	li	a2,0
ffffffffc020251a:	e406                	sd	ra,8(sp)
ffffffffc020251c:	d09ff0ef          	jal	ra,ffffffffc0202224 <get_pte>
ffffffffc0202520:	c011                	beqz	s0,ffffffffc0202524 <get_page+0x12>
ffffffffc0202522:	e008                	sd	a0,0(s0)
ffffffffc0202524:	c511                	beqz	a0,ffffffffc0202530 <get_page+0x1e>
ffffffffc0202526:	611c                	ld	a5,0(a0)
ffffffffc0202528:	4501                	li	a0,0
ffffffffc020252a:	0017f713          	andi	a4,a5,1
ffffffffc020252e:	e709                	bnez	a4,ffffffffc0202538 <get_page+0x26>
ffffffffc0202530:	60a2                	ld	ra,8(sp)
ffffffffc0202532:	6402                	ld	s0,0(sp)
ffffffffc0202534:	0141                	addi	sp,sp,16
ffffffffc0202536:	8082                	ret
ffffffffc0202538:	078a                	slli	a5,a5,0x2
ffffffffc020253a:	83b1                	srli	a5,a5,0xc
ffffffffc020253c:	00094717          	auipc	a4,0x94
ffffffffc0202540:	36473703          	ld	a4,868(a4) # ffffffffc02968a0 <npage>
ffffffffc0202544:	00e7ff63          	bgeu	a5,a4,ffffffffc0202562 <get_page+0x50>
ffffffffc0202548:	60a2                	ld	ra,8(sp)
ffffffffc020254a:	6402                	ld	s0,0(sp)
ffffffffc020254c:	fff80537          	lui	a0,0xfff80
ffffffffc0202550:	97aa                	add	a5,a5,a0
ffffffffc0202552:	079a                	slli	a5,a5,0x6
ffffffffc0202554:	00094517          	auipc	a0,0x94
ffffffffc0202558:	35453503          	ld	a0,852(a0) # ffffffffc02968a8 <pages>
ffffffffc020255c:	953e                	add	a0,a0,a5
ffffffffc020255e:	0141                	addi	sp,sp,16
ffffffffc0202560:	8082                	ret
ffffffffc0202562:	bd3ff0ef          	jal	ra,ffffffffc0202134 <pa2page.part.0>

ffffffffc0202566 <unmap_range>:
ffffffffc0202566:	7159                	addi	sp,sp,-112
ffffffffc0202568:	00c5e7b3          	or	a5,a1,a2
ffffffffc020256c:	f486                	sd	ra,104(sp)
ffffffffc020256e:	f0a2                	sd	s0,96(sp)
ffffffffc0202570:	eca6                	sd	s1,88(sp)
ffffffffc0202572:	e8ca                	sd	s2,80(sp)
ffffffffc0202574:	e4ce                	sd	s3,72(sp)
ffffffffc0202576:	e0d2                	sd	s4,64(sp)
ffffffffc0202578:	fc56                	sd	s5,56(sp)
ffffffffc020257a:	f85a                	sd	s6,48(sp)
ffffffffc020257c:	f45e                	sd	s7,40(sp)
ffffffffc020257e:	f062                	sd	s8,32(sp)
ffffffffc0202580:	ec66                	sd	s9,24(sp)
ffffffffc0202582:	e86a                	sd	s10,16(sp)
ffffffffc0202584:	17d2                	slli	a5,a5,0x34
ffffffffc0202586:	e3ed                	bnez	a5,ffffffffc0202668 <unmap_range+0x102>
ffffffffc0202588:	002007b7          	lui	a5,0x200
ffffffffc020258c:	842e                	mv	s0,a1
ffffffffc020258e:	0ef5ed63          	bltu	a1,a5,ffffffffc0202688 <unmap_range+0x122>
ffffffffc0202592:	8932                	mv	s2,a2
ffffffffc0202594:	0ec5fa63          	bgeu	a1,a2,ffffffffc0202688 <unmap_range+0x122>
ffffffffc0202598:	4785                	li	a5,1
ffffffffc020259a:	07fe                	slli	a5,a5,0x1f
ffffffffc020259c:	0ec7e663          	bltu	a5,a2,ffffffffc0202688 <unmap_range+0x122>
ffffffffc02025a0:	89aa                	mv	s3,a0
ffffffffc02025a2:	6a05                	lui	s4,0x1
ffffffffc02025a4:	00094c97          	auipc	s9,0x94
ffffffffc02025a8:	2fcc8c93          	addi	s9,s9,764 # ffffffffc02968a0 <npage>
ffffffffc02025ac:	00094c17          	auipc	s8,0x94
ffffffffc02025b0:	2fcc0c13          	addi	s8,s8,764 # ffffffffc02968a8 <pages>
ffffffffc02025b4:	fff80bb7          	lui	s7,0xfff80
ffffffffc02025b8:	00094d17          	auipc	s10,0x94
ffffffffc02025bc:	2f8d0d13          	addi	s10,s10,760 # ffffffffc02968b0 <pmm_manager>
ffffffffc02025c0:	00200b37          	lui	s6,0x200
ffffffffc02025c4:	ffe00ab7          	lui	s5,0xffe00
ffffffffc02025c8:	4601                	li	a2,0
ffffffffc02025ca:	85a2                	mv	a1,s0
ffffffffc02025cc:	854e                	mv	a0,s3
ffffffffc02025ce:	c57ff0ef          	jal	ra,ffffffffc0202224 <get_pte>
ffffffffc02025d2:	84aa                	mv	s1,a0
ffffffffc02025d4:	cd29                	beqz	a0,ffffffffc020262e <unmap_range+0xc8>
ffffffffc02025d6:	611c                	ld	a5,0(a0)
ffffffffc02025d8:	e395                	bnez	a5,ffffffffc02025fc <unmap_range+0x96>
ffffffffc02025da:	9452                	add	s0,s0,s4
ffffffffc02025dc:	ff2466e3          	bltu	s0,s2,ffffffffc02025c8 <unmap_range+0x62>
ffffffffc02025e0:	70a6                	ld	ra,104(sp)
ffffffffc02025e2:	7406                	ld	s0,96(sp)
ffffffffc02025e4:	64e6                	ld	s1,88(sp)
ffffffffc02025e6:	6946                	ld	s2,80(sp)
ffffffffc02025e8:	69a6                	ld	s3,72(sp)
ffffffffc02025ea:	6a06                	ld	s4,64(sp)
ffffffffc02025ec:	7ae2                	ld	s5,56(sp)
ffffffffc02025ee:	7b42                	ld	s6,48(sp)
ffffffffc02025f0:	7ba2                	ld	s7,40(sp)
ffffffffc02025f2:	7c02                	ld	s8,32(sp)
ffffffffc02025f4:	6ce2                	ld	s9,24(sp)
ffffffffc02025f6:	6d42                	ld	s10,16(sp)
ffffffffc02025f8:	6165                	addi	sp,sp,112
ffffffffc02025fa:	8082                	ret
ffffffffc02025fc:	0017f713          	andi	a4,a5,1
ffffffffc0202600:	df69                	beqz	a4,ffffffffc02025da <unmap_range+0x74>
ffffffffc0202602:	000cb703          	ld	a4,0(s9)
ffffffffc0202606:	078a                	slli	a5,a5,0x2
ffffffffc0202608:	83b1                	srli	a5,a5,0xc
ffffffffc020260a:	08e7ff63          	bgeu	a5,a4,ffffffffc02026a8 <unmap_range+0x142>
ffffffffc020260e:	000c3503          	ld	a0,0(s8)
ffffffffc0202612:	97de                	add	a5,a5,s7
ffffffffc0202614:	079a                	slli	a5,a5,0x6
ffffffffc0202616:	953e                	add	a0,a0,a5
ffffffffc0202618:	411c                	lw	a5,0(a0)
ffffffffc020261a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020261e:	c118                	sw	a4,0(a0)
ffffffffc0202620:	cf11                	beqz	a4,ffffffffc020263c <unmap_range+0xd6>
ffffffffc0202622:	0004b023          	sd	zero,0(s1)
ffffffffc0202626:	12040073          	sfence.vma	s0
ffffffffc020262a:	9452                	add	s0,s0,s4
ffffffffc020262c:	bf45                	j	ffffffffc02025dc <unmap_range+0x76>
ffffffffc020262e:	945a                	add	s0,s0,s6
ffffffffc0202630:	01547433          	and	s0,s0,s5
ffffffffc0202634:	d455                	beqz	s0,ffffffffc02025e0 <unmap_range+0x7a>
ffffffffc0202636:	f92469e3          	bltu	s0,s2,ffffffffc02025c8 <unmap_range+0x62>
ffffffffc020263a:	b75d                	j	ffffffffc02025e0 <unmap_range+0x7a>
ffffffffc020263c:	100027f3          	csrr	a5,sstatus
ffffffffc0202640:	8b89                	andi	a5,a5,2
ffffffffc0202642:	e799                	bnez	a5,ffffffffc0202650 <unmap_range+0xea>
ffffffffc0202644:	000d3783          	ld	a5,0(s10)
ffffffffc0202648:	4585                	li	a1,1
ffffffffc020264a:	739c                	ld	a5,32(a5)
ffffffffc020264c:	9782                	jalr	a5
ffffffffc020264e:	bfd1                	j	ffffffffc0202622 <unmap_range+0xbc>
ffffffffc0202650:	e42a                	sd	a0,8(sp)
ffffffffc0202652:	e20fe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0202656:	000d3783          	ld	a5,0(s10)
ffffffffc020265a:	6522                	ld	a0,8(sp)
ffffffffc020265c:	4585                	li	a1,1
ffffffffc020265e:	739c                	ld	a5,32(a5)
ffffffffc0202660:	9782                	jalr	a5
ffffffffc0202662:	e0afe0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0202666:	bf75                	j	ffffffffc0202622 <unmap_range+0xbc>
ffffffffc0202668:	0000a697          	auipc	a3,0xa
ffffffffc020266c:	4f068693          	addi	a3,a3,1264 # ffffffffc020cb58 <default_pmm_manager+0x188>
ffffffffc0202670:	0000a617          	auipc	a2,0xa
ffffffffc0202674:	87860613          	addi	a2,a2,-1928 # ffffffffc020bee8 <commands+0x210>
ffffffffc0202678:	15a00593          	li	a1,346
ffffffffc020267c:	0000a517          	auipc	a0,0xa
ffffffffc0202680:	4a450513          	addi	a0,a0,1188 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0202684:	e1bfd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0202688:	0000a697          	auipc	a3,0xa
ffffffffc020268c:	50068693          	addi	a3,a3,1280 # ffffffffc020cb88 <default_pmm_manager+0x1b8>
ffffffffc0202690:	0000a617          	auipc	a2,0xa
ffffffffc0202694:	85860613          	addi	a2,a2,-1960 # ffffffffc020bee8 <commands+0x210>
ffffffffc0202698:	15b00593          	li	a1,347
ffffffffc020269c:	0000a517          	auipc	a0,0xa
ffffffffc02026a0:	48450513          	addi	a0,a0,1156 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02026a4:	dfbfd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02026a8:	a8dff0ef          	jal	ra,ffffffffc0202134 <pa2page.part.0>

ffffffffc02026ac <exit_range>:
ffffffffc02026ac:	7119                	addi	sp,sp,-128
ffffffffc02026ae:	00c5e7b3          	or	a5,a1,a2
ffffffffc02026b2:	fc86                	sd	ra,120(sp)
ffffffffc02026b4:	f8a2                	sd	s0,112(sp)
ffffffffc02026b6:	f4a6                	sd	s1,104(sp)
ffffffffc02026b8:	f0ca                	sd	s2,96(sp)
ffffffffc02026ba:	ecce                	sd	s3,88(sp)
ffffffffc02026bc:	e8d2                	sd	s4,80(sp)
ffffffffc02026be:	e4d6                	sd	s5,72(sp)
ffffffffc02026c0:	e0da                	sd	s6,64(sp)
ffffffffc02026c2:	fc5e                	sd	s7,56(sp)
ffffffffc02026c4:	f862                	sd	s8,48(sp)
ffffffffc02026c6:	f466                	sd	s9,40(sp)
ffffffffc02026c8:	f06a                	sd	s10,32(sp)
ffffffffc02026ca:	ec6e                	sd	s11,24(sp)
ffffffffc02026cc:	17d2                	slli	a5,a5,0x34
ffffffffc02026ce:	20079a63          	bnez	a5,ffffffffc02028e2 <exit_range+0x236>
ffffffffc02026d2:	002007b7          	lui	a5,0x200
ffffffffc02026d6:	24f5e463          	bltu	a1,a5,ffffffffc020291e <exit_range+0x272>
ffffffffc02026da:	8ab2                	mv	s5,a2
ffffffffc02026dc:	24c5f163          	bgeu	a1,a2,ffffffffc020291e <exit_range+0x272>
ffffffffc02026e0:	4785                	li	a5,1
ffffffffc02026e2:	07fe                	slli	a5,a5,0x1f
ffffffffc02026e4:	22c7ed63          	bltu	a5,a2,ffffffffc020291e <exit_range+0x272>
ffffffffc02026e8:	c00009b7          	lui	s3,0xc0000
ffffffffc02026ec:	0135f9b3          	and	s3,a1,s3
ffffffffc02026f0:	ffe00937          	lui	s2,0xffe00
ffffffffc02026f4:	400007b7          	lui	a5,0x40000
ffffffffc02026f8:	5cfd                	li	s9,-1
ffffffffc02026fa:	8c2a                	mv	s8,a0
ffffffffc02026fc:	0125f933          	and	s2,a1,s2
ffffffffc0202700:	99be                	add	s3,s3,a5
ffffffffc0202702:	00094d17          	auipc	s10,0x94
ffffffffc0202706:	19ed0d13          	addi	s10,s10,414 # ffffffffc02968a0 <npage>
ffffffffc020270a:	00ccdc93          	srli	s9,s9,0xc
ffffffffc020270e:	00094717          	auipc	a4,0x94
ffffffffc0202712:	19a70713          	addi	a4,a4,410 # ffffffffc02968a8 <pages>
ffffffffc0202716:	00094d97          	auipc	s11,0x94
ffffffffc020271a:	19ad8d93          	addi	s11,s11,410 # ffffffffc02968b0 <pmm_manager>
ffffffffc020271e:	c0000437          	lui	s0,0xc0000
ffffffffc0202722:	944e                	add	s0,s0,s3
ffffffffc0202724:	8079                	srli	s0,s0,0x1e
ffffffffc0202726:	1ff47413          	andi	s0,s0,511
ffffffffc020272a:	040e                	slli	s0,s0,0x3
ffffffffc020272c:	9462                	add	s0,s0,s8
ffffffffc020272e:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_bin_sfs_img_size+0xffffffffbff8ad00>
ffffffffc0202732:	001a7793          	andi	a5,s4,1
ffffffffc0202736:	eb99                	bnez	a5,ffffffffc020274c <exit_range+0xa0>
ffffffffc0202738:	12098463          	beqz	s3,ffffffffc0202860 <exit_range+0x1b4>
ffffffffc020273c:	400007b7          	lui	a5,0x40000
ffffffffc0202740:	97ce                	add	a5,a5,s3
ffffffffc0202742:	894e                	mv	s2,s3
ffffffffc0202744:	1159fe63          	bgeu	s3,s5,ffffffffc0202860 <exit_range+0x1b4>
ffffffffc0202748:	89be                	mv	s3,a5
ffffffffc020274a:	bfd1                	j	ffffffffc020271e <exit_range+0x72>
ffffffffc020274c:	000d3783          	ld	a5,0(s10)
ffffffffc0202750:	0a0a                	slli	s4,s4,0x2
ffffffffc0202752:	00ca5a13          	srli	s4,s4,0xc
ffffffffc0202756:	1cfa7263          	bgeu	s4,a5,ffffffffc020291a <exit_range+0x26e>
ffffffffc020275a:	fff80637          	lui	a2,0xfff80
ffffffffc020275e:	9652                	add	a2,a2,s4
ffffffffc0202760:	000806b7          	lui	a3,0x80
ffffffffc0202764:	96b2                	add	a3,a3,a2
ffffffffc0202766:	0196f5b3          	and	a1,a3,s9
ffffffffc020276a:	061a                	slli	a2,a2,0x6
ffffffffc020276c:	06b2                	slli	a3,a3,0xc
ffffffffc020276e:	18f5fa63          	bgeu	a1,a5,ffffffffc0202902 <exit_range+0x256>
ffffffffc0202772:	00094817          	auipc	a6,0x94
ffffffffc0202776:	14680813          	addi	a6,a6,326 # ffffffffc02968b8 <va_pa_offset>
ffffffffc020277a:	00083b03          	ld	s6,0(a6)
ffffffffc020277e:	4b85                	li	s7,1
ffffffffc0202780:	fff80e37          	lui	t3,0xfff80
ffffffffc0202784:	9b36                	add	s6,s6,a3
ffffffffc0202786:	00080337          	lui	t1,0x80
ffffffffc020278a:	6885                	lui	a7,0x1
ffffffffc020278c:	a819                	j	ffffffffc02027a2 <exit_range+0xf6>
ffffffffc020278e:	4b81                	li	s7,0
ffffffffc0202790:	002007b7          	lui	a5,0x200
ffffffffc0202794:	993e                	add	s2,s2,a5
ffffffffc0202796:	08090c63          	beqz	s2,ffffffffc020282e <exit_range+0x182>
ffffffffc020279a:	09397a63          	bgeu	s2,s3,ffffffffc020282e <exit_range+0x182>
ffffffffc020279e:	0f597063          	bgeu	s2,s5,ffffffffc020287e <exit_range+0x1d2>
ffffffffc02027a2:	01595493          	srli	s1,s2,0x15
ffffffffc02027a6:	1ff4f493          	andi	s1,s1,511
ffffffffc02027aa:	048e                	slli	s1,s1,0x3
ffffffffc02027ac:	94da                	add	s1,s1,s6
ffffffffc02027ae:	609c                	ld	a5,0(s1)
ffffffffc02027b0:	0017f693          	andi	a3,a5,1
ffffffffc02027b4:	dee9                	beqz	a3,ffffffffc020278e <exit_range+0xe2>
ffffffffc02027b6:	000d3583          	ld	a1,0(s10)
ffffffffc02027ba:	078a                	slli	a5,a5,0x2
ffffffffc02027bc:	83b1                	srli	a5,a5,0xc
ffffffffc02027be:	14b7fe63          	bgeu	a5,a1,ffffffffc020291a <exit_range+0x26e>
ffffffffc02027c2:	97f2                	add	a5,a5,t3
ffffffffc02027c4:	006786b3          	add	a3,a5,t1
ffffffffc02027c8:	0196feb3          	and	t4,a3,s9
ffffffffc02027cc:	00679513          	slli	a0,a5,0x6
ffffffffc02027d0:	06b2                	slli	a3,a3,0xc
ffffffffc02027d2:	12bef863          	bgeu	t4,a1,ffffffffc0202902 <exit_range+0x256>
ffffffffc02027d6:	00083783          	ld	a5,0(a6)
ffffffffc02027da:	96be                	add	a3,a3,a5
ffffffffc02027dc:	011685b3          	add	a1,a3,a7
ffffffffc02027e0:	629c                	ld	a5,0(a3)
ffffffffc02027e2:	8b85                	andi	a5,a5,1
ffffffffc02027e4:	f7d5                	bnez	a5,ffffffffc0202790 <exit_range+0xe4>
ffffffffc02027e6:	06a1                	addi	a3,a3,8
ffffffffc02027e8:	fed59ce3          	bne	a1,a3,ffffffffc02027e0 <exit_range+0x134>
ffffffffc02027ec:	631c                	ld	a5,0(a4)
ffffffffc02027ee:	953e                	add	a0,a0,a5
ffffffffc02027f0:	100027f3          	csrr	a5,sstatus
ffffffffc02027f4:	8b89                	andi	a5,a5,2
ffffffffc02027f6:	e7d9                	bnez	a5,ffffffffc0202884 <exit_range+0x1d8>
ffffffffc02027f8:	000db783          	ld	a5,0(s11)
ffffffffc02027fc:	4585                	li	a1,1
ffffffffc02027fe:	e032                	sd	a2,0(sp)
ffffffffc0202800:	739c                	ld	a5,32(a5)
ffffffffc0202802:	9782                	jalr	a5
ffffffffc0202804:	6602                	ld	a2,0(sp)
ffffffffc0202806:	00094817          	auipc	a6,0x94
ffffffffc020280a:	0b280813          	addi	a6,a6,178 # ffffffffc02968b8 <va_pa_offset>
ffffffffc020280e:	fff80e37          	lui	t3,0xfff80
ffffffffc0202812:	00080337          	lui	t1,0x80
ffffffffc0202816:	6885                	lui	a7,0x1
ffffffffc0202818:	00094717          	auipc	a4,0x94
ffffffffc020281c:	09070713          	addi	a4,a4,144 # ffffffffc02968a8 <pages>
ffffffffc0202820:	0004b023          	sd	zero,0(s1)
ffffffffc0202824:	002007b7          	lui	a5,0x200
ffffffffc0202828:	993e                	add	s2,s2,a5
ffffffffc020282a:	f60918e3          	bnez	s2,ffffffffc020279a <exit_range+0xee>
ffffffffc020282e:	f00b85e3          	beqz	s7,ffffffffc0202738 <exit_range+0x8c>
ffffffffc0202832:	000d3783          	ld	a5,0(s10)
ffffffffc0202836:	0efa7263          	bgeu	s4,a5,ffffffffc020291a <exit_range+0x26e>
ffffffffc020283a:	6308                	ld	a0,0(a4)
ffffffffc020283c:	9532                	add	a0,a0,a2
ffffffffc020283e:	100027f3          	csrr	a5,sstatus
ffffffffc0202842:	8b89                	andi	a5,a5,2
ffffffffc0202844:	efad                	bnez	a5,ffffffffc02028be <exit_range+0x212>
ffffffffc0202846:	000db783          	ld	a5,0(s11)
ffffffffc020284a:	4585                	li	a1,1
ffffffffc020284c:	739c                	ld	a5,32(a5)
ffffffffc020284e:	9782                	jalr	a5
ffffffffc0202850:	00094717          	auipc	a4,0x94
ffffffffc0202854:	05870713          	addi	a4,a4,88 # ffffffffc02968a8 <pages>
ffffffffc0202858:	00043023          	sd	zero,0(s0)
ffffffffc020285c:	ee0990e3          	bnez	s3,ffffffffc020273c <exit_range+0x90>
ffffffffc0202860:	70e6                	ld	ra,120(sp)
ffffffffc0202862:	7446                	ld	s0,112(sp)
ffffffffc0202864:	74a6                	ld	s1,104(sp)
ffffffffc0202866:	7906                	ld	s2,96(sp)
ffffffffc0202868:	69e6                	ld	s3,88(sp)
ffffffffc020286a:	6a46                	ld	s4,80(sp)
ffffffffc020286c:	6aa6                	ld	s5,72(sp)
ffffffffc020286e:	6b06                	ld	s6,64(sp)
ffffffffc0202870:	7be2                	ld	s7,56(sp)
ffffffffc0202872:	7c42                	ld	s8,48(sp)
ffffffffc0202874:	7ca2                	ld	s9,40(sp)
ffffffffc0202876:	7d02                	ld	s10,32(sp)
ffffffffc0202878:	6de2                	ld	s11,24(sp)
ffffffffc020287a:	6109                	addi	sp,sp,128
ffffffffc020287c:	8082                	ret
ffffffffc020287e:	ea0b8fe3          	beqz	s7,ffffffffc020273c <exit_range+0x90>
ffffffffc0202882:	bf45                	j	ffffffffc0202832 <exit_range+0x186>
ffffffffc0202884:	e032                	sd	a2,0(sp)
ffffffffc0202886:	e42a                	sd	a0,8(sp)
ffffffffc0202888:	beafe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc020288c:	000db783          	ld	a5,0(s11)
ffffffffc0202890:	6522                	ld	a0,8(sp)
ffffffffc0202892:	4585                	li	a1,1
ffffffffc0202894:	739c                	ld	a5,32(a5)
ffffffffc0202896:	9782                	jalr	a5
ffffffffc0202898:	bd4fe0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc020289c:	6602                	ld	a2,0(sp)
ffffffffc020289e:	00094717          	auipc	a4,0x94
ffffffffc02028a2:	00a70713          	addi	a4,a4,10 # ffffffffc02968a8 <pages>
ffffffffc02028a6:	6885                	lui	a7,0x1
ffffffffc02028a8:	00080337          	lui	t1,0x80
ffffffffc02028ac:	fff80e37          	lui	t3,0xfff80
ffffffffc02028b0:	00094817          	auipc	a6,0x94
ffffffffc02028b4:	00880813          	addi	a6,a6,8 # ffffffffc02968b8 <va_pa_offset>
ffffffffc02028b8:	0004b023          	sd	zero,0(s1)
ffffffffc02028bc:	b7a5                	j	ffffffffc0202824 <exit_range+0x178>
ffffffffc02028be:	e02a                	sd	a0,0(sp)
ffffffffc02028c0:	bb2fe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02028c4:	000db783          	ld	a5,0(s11)
ffffffffc02028c8:	6502                	ld	a0,0(sp)
ffffffffc02028ca:	4585                	li	a1,1
ffffffffc02028cc:	739c                	ld	a5,32(a5)
ffffffffc02028ce:	9782                	jalr	a5
ffffffffc02028d0:	b9cfe0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02028d4:	00094717          	auipc	a4,0x94
ffffffffc02028d8:	fd470713          	addi	a4,a4,-44 # ffffffffc02968a8 <pages>
ffffffffc02028dc:	00043023          	sd	zero,0(s0)
ffffffffc02028e0:	bfb5                	j	ffffffffc020285c <exit_range+0x1b0>
ffffffffc02028e2:	0000a697          	auipc	a3,0xa
ffffffffc02028e6:	27668693          	addi	a3,a3,630 # ffffffffc020cb58 <default_pmm_manager+0x188>
ffffffffc02028ea:	00009617          	auipc	a2,0x9
ffffffffc02028ee:	5fe60613          	addi	a2,a2,1534 # ffffffffc020bee8 <commands+0x210>
ffffffffc02028f2:	16f00593          	li	a1,367
ffffffffc02028f6:	0000a517          	auipc	a0,0xa
ffffffffc02028fa:	22a50513          	addi	a0,a0,554 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02028fe:	ba1fd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0202902:	0000a617          	auipc	a2,0xa
ffffffffc0202906:	10660613          	addi	a2,a2,262 # ffffffffc020ca08 <default_pmm_manager+0x38>
ffffffffc020290a:	07100593          	li	a1,113
ffffffffc020290e:	0000a517          	auipc	a0,0xa
ffffffffc0202912:	12250513          	addi	a0,a0,290 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0202916:	b89fd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020291a:	81bff0ef          	jal	ra,ffffffffc0202134 <pa2page.part.0>
ffffffffc020291e:	0000a697          	auipc	a3,0xa
ffffffffc0202922:	26a68693          	addi	a3,a3,618 # ffffffffc020cb88 <default_pmm_manager+0x1b8>
ffffffffc0202926:	00009617          	auipc	a2,0x9
ffffffffc020292a:	5c260613          	addi	a2,a2,1474 # ffffffffc020bee8 <commands+0x210>
ffffffffc020292e:	17000593          	li	a1,368
ffffffffc0202932:	0000a517          	auipc	a0,0xa
ffffffffc0202936:	1ee50513          	addi	a0,a0,494 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020293a:	b65fd0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020293e <page_remove>:
ffffffffc020293e:	7179                	addi	sp,sp,-48
ffffffffc0202940:	4601                	li	a2,0
ffffffffc0202942:	ec26                	sd	s1,24(sp)
ffffffffc0202944:	f406                	sd	ra,40(sp)
ffffffffc0202946:	f022                	sd	s0,32(sp)
ffffffffc0202948:	84ae                	mv	s1,a1
ffffffffc020294a:	8dbff0ef          	jal	ra,ffffffffc0202224 <get_pte>
ffffffffc020294e:	c511                	beqz	a0,ffffffffc020295a <page_remove+0x1c>
ffffffffc0202950:	611c                	ld	a5,0(a0)
ffffffffc0202952:	842a                	mv	s0,a0
ffffffffc0202954:	0017f713          	andi	a4,a5,1
ffffffffc0202958:	e711                	bnez	a4,ffffffffc0202964 <page_remove+0x26>
ffffffffc020295a:	70a2                	ld	ra,40(sp)
ffffffffc020295c:	7402                	ld	s0,32(sp)
ffffffffc020295e:	64e2                	ld	s1,24(sp)
ffffffffc0202960:	6145                	addi	sp,sp,48
ffffffffc0202962:	8082                	ret
ffffffffc0202964:	078a                	slli	a5,a5,0x2
ffffffffc0202966:	83b1                	srli	a5,a5,0xc
ffffffffc0202968:	00094717          	auipc	a4,0x94
ffffffffc020296c:	f3873703          	ld	a4,-200(a4) # ffffffffc02968a0 <npage>
ffffffffc0202970:	06e7f363          	bgeu	a5,a4,ffffffffc02029d6 <page_remove+0x98>
ffffffffc0202974:	fff80537          	lui	a0,0xfff80
ffffffffc0202978:	97aa                	add	a5,a5,a0
ffffffffc020297a:	079a                	slli	a5,a5,0x6
ffffffffc020297c:	00094517          	auipc	a0,0x94
ffffffffc0202980:	f2c53503          	ld	a0,-212(a0) # ffffffffc02968a8 <pages>
ffffffffc0202984:	953e                	add	a0,a0,a5
ffffffffc0202986:	411c                	lw	a5,0(a0)
ffffffffc0202988:	fff7871b          	addiw	a4,a5,-1
ffffffffc020298c:	c118                	sw	a4,0(a0)
ffffffffc020298e:	cb11                	beqz	a4,ffffffffc02029a2 <page_remove+0x64>
ffffffffc0202990:	00043023          	sd	zero,0(s0)
ffffffffc0202994:	12048073          	sfence.vma	s1
ffffffffc0202998:	70a2                	ld	ra,40(sp)
ffffffffc020299a:	7402                	ld	s0,32(sp)
ffffffffc020299c:	64e2                	ld	s1,24(sp)
ffffffffc020299e:	6145                	addi	sp,sp,48
ffffffffc02029a0:	8082                	ret
ffffffffc02029a2:	100027f3          	csrr	a5,sstatus
ffffffffc02029a6:	8b89                	andi	a5,a5,2
ffffffffc02029a8:	eb89                	bnez	a5,ffffffffc02029ba <page_remove+0x7c>
ffffffffc02029aa:	00094797          	auipc	a5,0x94
ffffffffc02029ae:	f067b783          	ld	a5,-250(a5) # ffffffffc02968b0 <pmm_manager>
ffffffffc02029b2:	739c                	ld	a5,32(a5)
ffffffffc02029b4:	4585                	li	a1,1
ffffffffc02029b6:	9782                	jalr	a5
ffffffffc02029b8:	bfe1                	j	ffffffffc0202990 <page_remove+0x52>
ffffffffc02029ba:	e42a                	sd	a0,8(sp)
ffffffffc02029bc:	ab6fe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02029c0:	00094797          	auipc	a5,0x94
ffffffffc02029c4:	ef07b783          	ld	a5,-272(a5) # ffffffffc02968b0 <pmm_manager>
ffffffffc02029c8:	739c                	ld	a5,32(a5)
ffffffffc02029ca:	6522                	ld	a0,8(sp)
ffffffffc02029cc:	4585                	li	a1,1
ffffffffc02029ce:	9782                	jalr	a5
ffffffffc02029d0:	a9cfe0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02029d4:	bf75                	j	ffffffffc0202990 <page_remove+0x52>
ffffffffc02029d6:	f5eff0ef          	jal	ra,ffffffffc0202134 <pa2page.part.0>

ffffffffc02029da <page_insert>:
ffffffffc02029da:	7139                	addi	sp,sp,-64
ffffffffc02029dc:	e852                	sd	s4,16(sp)
ffffffffc02029de:	8a32                	mv	s4,a2
ffffffffc02029e0:	f822                	sd	s0,48(sp)
ffffffffc02029e2:	4605                	li	a2,1
ffffffffc02029e4:	842e                	mv	s0,a1
ffffffffc02029e6:	85d2                	mv	a1,s4
ffffffffc02029e8:	f426                	sd	s1,40(sp)
ffffffffc02029ea:	fc06                	sd	ra,56(sp)
ffffffffc02029ec:	f04a                	sd	s2,32(sp)
ffffffffc02029ee:	ec4e                	sd	s3,24(sp)
ffffffffc02029f0:	e456                	sd	s5,8(sp)
ffffffffc02029f2:	84b6                	mv	s1,a3
ffffffffc02029f4:	831ff0ef          	jal	ra,ffffffffc0202224 <get_pte>
ffffffffc02029f8:	c961                	beqz	a0,ffffffffc0202ac8 <page_insert+0xee>
ffffffffc02029fa:	4014                	lw	a3,0(s0)
ffffffffc02029fc:	611c                	ld	a5,0(a0)
ffffffffc02029fe:	89aa                	mv	s3,a0
ffffffffc0202a00:	0016871b          	addiw	a4,a3,1
ffffffffc0202a04:	c018                	sw	a4,0(s0)
ffffffffc0202a06:	0017f713          	andi	a4,a5,1
ffffffffc0202a0a:	ef05                	bnez	a4,ffffffffc0202a42 <page_insert+0x68>
ffffffffc0202a0c:	00094717          	auipc	a4,0x94
ffffffffc0202a10:	e9c73703          	ld	a4,-356(a4) # ffffffffc02968a8 <pages>
ffffffffc0202a14:	8c19                	sub	s0,s0,a4
ffffffffc0202a16:	000807b7          	lui	a5,0x80
ffffffffc0202a1a:	8419                	srai	s0,s0,0x6
ffffffffc0202a1c:	943e                	add	s0,s0,a5
ffffffffc0202a1e:	042a                	slli	s0,s0,0xa
ffffffffc0202a20:	8cc1                	or	s1,s1,s0
ffffffffc0202a22:	0014e493          	ori	s1,s1,1
ffffffffc0202a26:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_bin_sfs_img_size+0xffffffffbff8ad00>
ffffffffc0202a2a:	120a0073          	sfence.vma	s4
ffffffffc0202a2e:	4501                	li	a0,0
ffffffffc0202a30:	70e2                	ld	ra,56(sp)
ffffffffc0202a32:	7442                	ld	s0,48(sp)
ffffffffc0202a34:	74a2                	ld	s1,40(sp)
ffffffffc0202a36:	7902                	ld	s2,32(sp)
ffffffffc0202a38:	69e2                	ld	s3,24(sp)
ffffffffc0202a3a:	6a42                	ld	s4,16(sp)
ffffffffc0202a3c:	6aa2                	ld	s5,8(sp)
ffffffffc0202a3e:	6121                	addi	sp,sp,64
ffffffffc0202a40:	8082                	ret
ffffffffc0202a42:	078a                	slli	a5,a5,0x2
ffffffffc0202a44:	83b1                	srli	a5,a5,0xc
ffffffffc0202a46:	00094717          	auipc	a4,0x94
ffffffffc0202a4a:	e5a73703          	ld	a4,-422(a4) # ffffffffc02968a0 <npage>
ffffffffc0202a4e:	06e7ff63          	bgeu	a5,a4,ffffffffc0202acc <page_insert+0xf2>
ffffffffc0202a52:	00094a97          	auipc	s5,0x94
ffffffffc0202a56:	e56a8a93          	addi	s5,s5,-426 # ffffffffc02968a8 <pages>
ffffffffc0202a5a:	000ab703          	ld	a4,0(s5)
ffffffffc0202a5e:	fff80937          	lui	s2,0xfff80
ffffffffc0202a62:	993e                	add	s2,s2,a5
ffffffffc0202a64:	091a                	slli	s2,s2,0x6
ffffffffc0202a66:	993a                	add	s2,s2,a4
ffffffffc0202a68:	01240c63          	beq	s0,s2,ffffffffc0202a80 <page_insert+0xa6>
ffffffffc0202a6c:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fce96f0>
ffffffffc0202a70:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202a74:	00d92023          	sw	a3,0(s2)
ffffffffc0202a78:	c691                	beqz	a3,ffffffffc0202a84 <page_insert+0xaa>
ffffffffc0202a7a:	120a0073          	sfence.vma	s4
ffffffffc0202a7e:	bf59                	j	ffffffffc0202a14 <page_insert+0x3a>
ffffffffc0202a80:	c014                	sw	a3,0(s0)
ffffffffc0202a82:	bf49                	j	ffffffffc0202a14 <page_insert+0x3a>
ffffffffc0202a84:	100027f3          	csrr	a5,sstatus
ffffffffc0202a88:	8b89                	andi	a5,a5,2
ffffffffc0202a8a:	ef91                	bnez	a5,ffffffffc0202aa6 <page_insert+0xcc>
ffffffffc0202a8c:	00094797          	auipc	a5,0x94
ffffffffc0202a90:	e247b783          	ld	a5,-476(a5) # ffffffffc02968b0 <pmm_manager>
ffffffffc0202a94:	739c                	ld	a5,32(a5)
ffffffffc0202a96:	4585                	li	a1,1
ffffffffc0202a98:	854a                	mv	a0,s2
ffffffffc0202a9a:	9782                	jalr	a5
ffffffffc0202a9c:	000ab703          	ld	a4,0(s5)
ffffffffc0202aa0:	120a0073          	sfence.vma	s4
ffffffffc0202aa4:	bf85                	j	ffffffffc0202a14 <page_insert+0x3a>
ffffffffc0202aa6:	9ccfe0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0202aaa:	00094797          	auipc	a5,0x94
ffffffffc0202aae:	e067b783          	ld	a5,-506(a5) # ffffffffc02968b0 <pmm_manager>
ffffffffc0202ab2:	739c                	ld	a5,32(a5)
ffffffffc0202ab4:	4585                	li	a1,1
ffffffffc0202ab6:	854a                	mv	a0,s2
ffffffffc0202ab8:	9782                	jalr	a5
ffffffffc0202aba:	9b2fe0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0202abe:	000ab703          	ld	a4,0(s5)
ffffffffc0202ac2:	120a0073          	sfence.vma	s4
ffffffffc0202ac6:	b7b9                	j	ffffffffc0202a14 <page_insert+0x3a>
ffffffffc0202ac8:	5571                	li	a0,-4
ffffffffc0202aca:	b79d                	j	ffffffffc0202a30 <page_insert+0x56>
ffffffffc0202acc:	e68ff0ef          	jal	ra,ffffffffc0202134 <pa2page.part.0>

ffffffffc0202ad0 <pmm_init>:
ffffffffc0202ad0:	0000a797          	auipc	a5,0xa
ffffffffc0202ad4:	f0078793          	addi	a5,a5,-256 # ffffffffc020c9d0 <default_pmm_manager>
ffffffffc0202ad8:	638c                	ld	a1,0(a5)
ffffffffc0202ada:	7159                	addi	sp,sp,-112
ffffffffc0202adc:	f85a                	sd	s6,48(sp)
ffffffffc0202ade:	0000a517          	auipc	a0,0xa
ffffffffc0202ae2:	0c250513          	addi	a0,a0,194 # ffffffffc020cba0 <default_pmm_manager+0x1d0>
ffffffffc0202ae6:	00094b17          	auipc	s6,0x94
ffffffffc0202aea:	dcab0b13          	addi	s6,s6,-566 # ffffffffc02968b0 <pmm_manager>
ffffffffc0202aee:	f486                	sd	ra,104(sp)
ffffffffc0202af0:	e8ca                	sd	s2,80(sp)
ffffffffc0202af2:	e4ce                	sd	s3,72(sp)
ffffffffc0202af4:	f0a2                	sd	s0,96(sp)
ffffffffc0202af6:	eca6                	sd	s1,88(sp)
ffffffffc0202af8:	e0d2                	sd	s4,64(sp)
ffffffffc0202afa:	fc56                	sd	s5,56(sp)
ffffffffc0202afc:	f45e                	sd	s7,40(sp)
ffffffffc0202afe:	f062                	sd	s8,32(sp)
ffffffffc0202b00:	ec66                	sd	s9,24(sp)
ffffffffc0202b02:	00fb3023          	sd	a5,0(s6)
ffffffffc0202b06:	ea0fd0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0202b0a:	000b3783          	ld	a5,0(s6)
ffffffffc0202b0e:	00094997          	auipc	s3,0x94
ffffffffc0202b12:	daa98993          	addi	s3,s3,-598 # ffffffffc02968b8 <va_pa_offset>
ffffffffc0202b16:	679c                	ld	a5,8(a5)
ffffffffc0202b18:	9782                	jalr	a5
ffffffffc0202b1a:	57f5                	li	a5,-3
ffffffffc0202b1c:	07fa                	slli	a5,a5,0x1e
ffffffffc0202b1e:	00f9b023          	sd	a5,0(s3)
ffffffffc0202b22:	f27fd0ef          	jal	ra,ffffffffc0200a48 <get_memory_base>
ffffffffc0202b26:	892a                	mv	s2,a0
ffffffffc0202b28:	f2bfd0ef          	jal	ra,ffffffffc0200a52 <get_memory_size>
ffffffffc0202b2c:	280502e3          	beqz	a0,ffffffffc02035b0 <pmm_init+0xae0>
ffffffffc0202b30:	84aa                	mv	s1,a0
ffffffffc0202b32:	0000a517          	auipc	a0,0xa
ffffffffc0202b36:	0a650513          	addi	a0,a0,166 # ffffffffc020cbd8 <default_pmm_manager+0x208>
ffffffffc0202b3a:	e6cfd0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0202b3e:	00990433          	add	s0,s2,s1
ffffffffc0202b42:	fff40693          	addi	a3,s0,-1
ffffffffc0202b46:	864a                	mv	a2,s2
ffffffffc0202b48:	85a6                	mv	a1,s1
ffffffffc0202b4a:	0000a517          	auipc	a0,0xa
ffffffffc0202b4e:	0a650513          	addi	a0,a0,166 # ffffffffc020cbf0 <default_pmm_manager+0x220>
ffffffffc0202b52:	e54fd0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0202b56:	c8000737          	lui	a4,0xc8000
ffffffffc0202b5a:	87a2                	mv	a5,s0
ffffffffc0202b5c:	5e876e63          	bltu	a4,s0,ffffffffc0203158 <pmm_init+0x688>
ffffffffc0202b60:	757d                	lui	a0,0xfffff
ffffffffc0202b62:	00095617          	auipc	a2,0x95
ffffffffc0202b66:	dad60613          	addi	a2,a2,-595 # ffffffffc029790f <end+0xfff>
ffffffffc0202b6a:	8e69                	and	a2,a2,a0
ffffffffc0202b6c:	00094497          	auipc	s1,0x94
ffffffffc0202b70:	d3448493          	addi	s1,s1,-716 # ffffffffc02968a0 <npage>
ffffffffc0202b74:	00c7d513          	srli	a0,a5,0xc
ffffffffc0202b78:	00094b97          	auipc	s7,0x94
ffffffffc0202b7c:	d30b8b93          	addi	s7,s7,-720 # ffffffffc02968a8 <pages>
ffffffffc0202b80:	e088                	sd	a0,0(s1)
ffffffffc0202b82:	00cbb023          	sd	a2,0(s7)
ffffffffc0202b86:	000807b7          	lui	a5,0x80
ffffffffc0202b8a:	86b2                	mv	a3,a2
ffffffffc0202b8c:	02f50863          	beq	a0,a5,ffffffffc0202bbc <pmm_init+0xec>
ffffffffc0202b90:	4781                	li	a5,0
ffffffffc0202b92:	4585                	li	a1,1
ffffffffc0202b94:	fff806b7          	lui	a3,0xfff80
ffffffffc0202b98:	00679513          	slli	a0,a5,0x6
ffffffffc0202b9c:	9532                	add	a0,a0,a2
ffffffffc0202b9e:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd686f8>
ffffffffc0202ba2:	40b7302f          	amoor.d	zero,a1,(a4)
ffffffffc0202ba6:	6088                	ld	a0,0(s1)
ffffffffc0202ba8:	0785                	addi	a5,a5,1
ffffffffc0202baa:	000bb603          	ld	a2,0(s7)
ffffffffc0202bae:	00d50733          	add	a4,a0,a3
ffffffffc0202bb2:	fee7e3e3          	bltu	a5,a4,ffffffffc0202b98 <pmm_init+0xc8>
ffffffffc0202bb6:	071a                	slli	a4,a4,0x6
ffffffffc0202bb8:	00e606b3          	add	a3,a2,a4
ffffffffc0202bbc:	c02007b7          	lui	a5,0xc0200
ffffffffc0202bc0:	3af6eae3          	bltu	a3,a5,ffffffffc0203774 <pmm_init+0xca4>
ffffffffc0202bc4:	0009b583          	ld	a1,0(s3)
ffffffffc0202bc8:	77fd                	lui	a5,0xfffff
ffffffffc0202bca:	8c7d                	and	s0,s0,a5
ffffffffc0202bcc:	8e8d                	sub	a3,a3,a1
ffffffffc0202bce:	5e86e363          	bltu	a3,s0,ffffffffc02031b4 <pmm_init+0x6e4>
ffffffffc0202bd2:	0000a517          	auipc	a0,0xa
ffffffffc0202bd6:	04650513          	addi	a0,a0,70 # ffffffffc020cc18 <default_pmm_manager+0x248>
ffffffffc0202bda:	dccfd0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0202bde:	000b3783          	ld	a5,0(s6)
ffffffffc0202be2:	7b9c                	ld	a5,48(a5)
ffffffffc0202be4:	9782                	jalr	a5
ffffffffc0202be6:	0000a517          	auipc	a0,0xa
ffffffffc0202bea:	04a50513          	addi	a0,a0,74 # ffffffffc020cc30 <default_pmm_manager+0x260>
ffffffffc0202bee:	db8fd0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0202bf2:	100027f3          	csrr	a5,sstatus
ffffffffc0202bf6:	8b89                	andi	a5,a5,2
ffffffffc0202bf8:	5a079363          	bnez	a5,ffffffffc020319e <pmm_init+0x6ce>
ffffffffc0202bfc:	000b3783          	ld	a5,0(s6)
ffffffffc0202c00:	4505                	li	a0,1
ffffffffc0202c02:	6f9c                	ld	a5,24(a5)
ffffffffc0202c04:	9782                	jalr	a5
ffffffffc0202c06:	842a                	mv	s0,a0
ffffffffc0202c08:	180408e3          	beqz	s0,ffffffffc0203598 <pmm_init+0xac8>
ffffffffc0202c0c:	000bb683          	ld	a3,0(s7)
ffffffffc0202c10:	5a7d                	li	s4,-1
ffffffffc0202c12:	6098                	ld	a4,0(s1)
ffffffffc0202c14:	40d406b3          	sub	a3,s0,a3
ffffffffc0202c18:	8699                	srai	a3,a3,0x6
ffffffffc0202c1a:	00080437          	lui	s0,0x80
ffffffffc0202c1e:	96a2                	add	a3,a3,s0
ffffffffc0202c20:	00ca5793          	srli	a5,s4,0xc
ffffffffc0202c24:	8ff5                	and	a5,a5,a3
ffffffffc0202c26:	06b2                	slli	a3,a3,0xc
ffffffffc0202c28:	30e7fde3          	bgeu	a5,a4,ffffffffc0203742 <pmm_init+0xc72>
ffffffffc0202c2c:	0009b403          	ld	s0,0(s3)
ffffffffc0202c30:	6605                	lui	a2,0x1
ffffffffc0202c32:	4581                	li	a1,0
ffffffffc0202c34:	9436                	add	s0,s0,a3
ffffffffc0202c36:	8522                	mv	a0,s0
ffffffffc0202c38:	5cd080ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc0202c3c:	0009b683          	ld	a3,0(s3)
ffffffffc0202c40:	77fd                	lui	a5,0xfffff
ffffffffc0202c42:	0000a917          	auipc	s2,0xa
ffffffffc0202c46:	e2b90913          	addi	s2,s2,-469 # ffffffffc020ca6d <default_pmm_manager+0x9d>
ffffffffc0202c4a:	00f97933          	and	s2,s2,a5
ffffffffc0202c4e:	c0200ab7          	lui	s5,0xc0200
ffffffffc0202c52:	3fe00637          	lui	a2,0x3fe00
ffffffffc0202c56:	964a                	add	a2,a2,s2
ffffffffc0202c58:	4729                	li	a4,10
ffffffffc0202c5a:	40da86b3          	sub	a3,s5,a3
ffffffffc0202c5e:	c02005b7          	lui	a1,0xc0200
ffffffffc0202c62:	8522                	mv	a0,s0
ffffffffc0202c64:	fe8ff0ef          	jal	ra,ffffffffc020244c <boot_map_segment>
ffffffffc0202c68:	c8000637          	lui	a2,0xc8000
ffffffffc0202c6c:	41260633          	sub	a2,a2,s2
ffffffffc0202c70:	3f596ce3          	bltu	s2,s5,ffffffffc0203868 <pmm_init+0xd98>
ffffffffc0202c74:	0009b683          	ld	a3,0(s3)
ffffffffc0202c78:	85ca                	mv	a1,s2
ffffffffc0202c7a:	4719                	li	a4,6
ffffffffc0202c7c:	40d906b3          	sub	a3,s2,a3
ffffffffc0202c80:	8522                	mv	a0,s0
ffffffffc0202c82:	00094917          	auipc	s2,0x94
ffffffffc0202c86:	c1690913          	addi	s2,s2,-1002 # ffffffffc0296898 <boot_pgdir_va>
ffffffffc0202c8a:	fc2ff0ef          	jal	ra,ffffffffc020244c <boot_map_segment>
ffffffffc0202c8e:	00893023          	sd	s0,0(s2)
ffffffffc0202c92:	2d5464e3          	bltu	s0,s5,ffffffffc020375a <pmm_init+0xc8a>
ffffffffc0202c96:	0009b783          	ld	a5,0(s3)
ffffffffc0202c9a:	1a7e                	slli	s4,s4,0x3f
ffffffffc0202c9c:	8c1d                	sub	s0,s0,a5
ffffffffc0202c9e:	00c45793          	srli	a5,s0,0xc
ffffffffc0202ca2:	00094717          	auipc	a4,0x94
ffffffffc0202ca6:	be873723          	sd	s0,-1042(a4) # ffffffffc0296890 <boot_pgdir_pa>
ffffffffc0202caa:	0147ea33          	or	s4,a5,s4
ffffffffc0202cae:	180a1073          	csrw	satp,s4
ffffffffc0202cb2:	12000073          	sfence.vma
ffffffffc0202cb6:	0000a517          	auipc	a0,0xa
ffffffffc0202cba:	fba50513          	addi	a0,a0,-70 # ffffffffc020cc70 <default_pmm_manager+0x2a0>
ffffffffc0202cbe:	ce8fd0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0202cc2:	0000e717          	auipc	a4,0xe
ffffffffc0202cc6:	33e70713          	addi	a4,a4,830 # ffffffffc0211000 <bootstack>
ffffffffc0202cca:	0000e797          	auipc	a5,0xe
ffffffffc0202cce:	33678793          	addi	a5,a5,822 # ffffffffc0211000 <bootstack>
ffffffffc0202cd2:	5cf70d63          	beq	a4,a5,ffffffffc02032ac <pmm_init+0x7dc>
ffffffffc0202cd6:	100027f3          	csrr	a5,sstatus
ffffffffc0202cda:	8b89                	andi	a5,a5,2
ffffffffc0202cdc:	4a079763          	bnez	a5,ffffffffc020318a <pmm_init+0x6ba>
ffffffffc0202ce0:	000b3783          	ld	a5,0(s6)
ffffffffc0202ce4:	779c                	ld	a5,40(a5)
ffffffffc0202ce6:	9782                	jalr	a5
ffffffffc0202ce8:	842a                	mv	s0,a0
ffffffffc0202cea:	6098                	ld	a4,0(s1)
ffffffffc0202cec:	c80007b7          	lui	a5,0xc8000
ffffffffc0202cf0:	83b1                	srli	a5,a5,0xc
ffffffffc0202cf2:	08e7e3e3          	bltu	a5,a4,ffffffffc0203578 <pmm_init+0xaa8>
ffffffffc0202cf6:	00093503          	ld	a0,0(s2)
ffffffffc0202cfa:	04050fe3          	beqz	a0,ffffffffc0203558 <pmm_init+0xa88>
ffffffffc0202cfe:	03451793          	slli	a5,a0,0x34
ffffffffc0202d02:	04079be3          	bnez	a5,ffffffffc0203558 <pmm_init+0xa88>
ffffffffc0202d06:	4601                	li	a2,0
ffffffffc0202d08:	4581                	li	a1,0
ffffffffc0202d0a:	809ff0ef          	jal	ra,ffffffffc0202512 <get_page>
ffffffffc0202d0e:	2e0511e3          	bnez	a0,ffffffffc02037f0 <pmm_init+0xd20>
ffffffffc0202d12:	100027f3          	csrr	a5,sstatus
ffffffffc0202d16:	8b89                	andi	a5,a5,2
ffffffffc0202d18:	44079e63          	bnez	a5,ffffffffc0203174 <pmm_init+0x6a4>
ffffffffc0202d1c:	000b3783          	ld	a5,0(s6)
ffffffffc0202d20:	4505                	li	a0,1
ffffffffc0202d22:	6f9c                	ld	a5,24(a5)
ffffffffc0202d24:	9782                	jalr	a5
ffffffffc0202d26:	8a2a                	mv	s4,a0
ffffffffc0202d28:	00093503          	ld	a0,0(s2)
ffffffffc0202d2c:	4681                	li	a3,0
ffffffffc0202d2e:	4601                	li	a2,0
ffffffffc0202d30:	85d2                	mv	a1,s4
ffffffffc0202d32:	ca9ff0ef          	jal	ra,ffffffffc02029da <page_insert>
ffffffffc0202d36:	26051be3          	bnez	a0,ffffffffc02037ac <pmm_init+0xcdc>
ffffffffc0202d3a:	00093503          	ld	a0,0(s2)
ffffffffc0202d3e:	4601                	li	a2,0
ffffffffc0202d40:	4581                	li	a1,0
ffffffffc0202d42:	ce2ff0ef          	jal	ra,ffffffffc0202224 <get_pte>
ffffffffc0202d46:	280505e3          	beqz	a0,ffffffffc02037d0 <pmm_init+0xd00>
ffffffffc0202d4a:	611c                	ld	a5,0(a0)
ffffffffc0202d4c:	0017f713          	andi	a4,a5,1
ffffffffc0202d50:	26070ee3          	beqz	a4,ffffffffc02037cc <pmm_init+0xcfc>
ffffffffc0202d54:	6098                	ld	a4,0(s1)
ffffffffc0202d56:	078a                	slli	a5,a5,0x2
ffffffffc0202d58:	83b1                	srli	a5,a5,0xc
ffffffffc0202d5a:	62e7f363          	bgeu	a5,a4,ffffffffc0203380 <pmm_init+0x8b0>
ffffffffc0202d5e:	000bb683          	ld	a3,0(s7)
ffffffffc0202d62:	fff80637          	lui	a2,0xfff80
ffffffffc0202d66:	97b2                	add	a5,a5,a2
ffffffffc0202d68:	079a                	slli	a5,a5,0x6
ffffffffc0202d6a:	97b6                	add	a5,a5,a3
ffffffffc0202d6c:	2afa12e3          	bne	s4,a5,ffffffffc0203810 <pmm_init+0xd40>
ffffffffc0202d70:	000a2683          	lw	a3,0(s4) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc0202d74:	4785                	li	a5,1
ffffffffc0202d76:	2cf699e3          	bne	a3,a5,ffffffffc0203848 <pmm_init+0xd78>
ffffffffc0202d7a:	00093503          	ld	a0,0(s2)
ffffffffc0202d7e:	77fd                	lui	a5,0xfffff
ffffffffc0202d80:	6114                	ld	a3,0(a0)
ffffffffc0202d82:	068a                	slli	a3,a3,0x2
ffffffffc0202d84:	8efd                	and	a3,a3,a5
ffffffffc0202d86:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202d8a:	2ae673e3          	bgeu	a2,a4,ffffffffc0203830 <pmm_init+0xd60>
ffffffffc0202d8e:	0009bc03          	ld	s8,0(s3)
ffffffffc0202d92:	96e2                	add	a3,a3,s8
ffffffffc0202d94:	0006ba83          	ld	s5,0(a3) # fffffffffff80000 <end+0x3fce96f0>
ffffffffc0202d98:	0a8a                	slli	s5,s5,0x2
ffffffffc0202d9a:	00fafab3          	and	s5,s5,a5
ffffffffc0202d9e:	00cad793          	srli	a5,s5,0xc
ffffffffc0202da2:	06e7f3e3          	bgeu	a5,a4,ffffffffc0203608 <pmm_init+0xb38>
ffffffffc0202da6:	4601                	li	a2,0
ffffffffc0202da8:	6585                	lui	a1,0x1
ffffffffc0202daa:	9ae2                	add	s5,s5,s8
ffffffffc0202dac:	c78ff0ef          	jal	ra,ffffffffc0202224 <get_pte>
ffffffffc0202db0:	0aa1                	addi	s5,s5,8
ffffffffc0202db2:	03551be3          	bne	a0,s5,ffffffffc02035e8 <pmm_init+0xb18>
ffffffffc0202db6:	100027f3          	csrr	a5,sstatus
ffffffffc0202dba:	8b89                	andi	a5,a5,2
ffffffffc0202dbc:	3a079163          	bnez	a5,ffffffffc020315e <pmm_init+0x68e>
ffffffffc0202dc0:	000b3783          	ld	a5,0(s6)
ffffffffc0202dc4:	4505                	li	a0,1
ffffffffc0202dc6:	6f9c                	ld	a5,24(a5)
ffffffffc0202dc8:	9782                	jalr	a5
ffffffffc0202dca:	8c2a                	mv	s8,a0
ffffffffc0202dcc:	00093503          	ld	a0,0(s2)
ffffffffc0202dd0:	46d1                	li	a3,20
ffffffffc0202dd2:	6605                	lui	a2,0x1
ffffffffc0202dd4:	85e2                	mv	a1,s8
ffffffffc0202dd6:	c05ff0ef          	jal	ra,ffffffffc02029da <page_insert>
ffffffffc0202dda:	1a0519e3          	bnez	a0,ffffffffc020378c <pmm_init+0xcbc>
ffffffffc0202dde:	00093503          	ld	a0,0(s2)
ffffffffc0202de2:	4601                	li	a2,0
ffffffffc0202de4:	6585                	lui	a1,0x1
ffffffffc0202de6:	c3eff0ef          	jal	ra,ffffffffc0202224 <get_pte>
ffffffffc0202dea:	10050ce3          	beqz	a0,ffffffffc0203702 <pmm_init+0xc32>
ffffffffc0202dee:	611c                	ld	a5,0(a0)
ffffffffc0202df0:	0107f713          	andi	a4,a5,16
ffffffffc0202df4:	0e0707e3          	beqz	a4,ffffffffc02036e2 <pmm_init+0xc12>
ffffffffc0202df8:	8b91                	andi	a5,a5,4
ffffffffc0202dfa:	0c0784e3          	beqz	a5,ffffffffc02036c2 <pmm_init+0xbf2>
ffffffffc0202dfe:	00093503          	ld	a0,0(s2)
ffffffffc0202e02:	611c                	ld	a5,0(a0)
ffffffffc0202e04:	8bc1                	andi	a5,a5,16
ffffffffc0202e06:	08078ee3          	beqz	a5,ffffffffc02036a2 <pmm_init+0xbd2>
ffffffffc0202e0a:	000c2703          	lw	a4,0(s8)
ffffffffc0202e0e:	4785                	li	a5,1
ffffffffc0202e10:	06f719e3          	bne	a4,a5,ffffffffc0203682 <pmm_init+0xbb2>
ffffffffc0202e14:	4681                	li	a3,0
ffffffffc0202e16:	6605                	lui	a2,0x1
ffffffffc0202e18:	85d2                	mv	a1,s4
ffffffffc0202e1a:	bc1ff0ef          	jal	ra,ffffffffc02029da <page_insert>
ffffffffc0202e1e:	040512e3          	bnez	a0,ffffffffc0203662 <pmm_init+0xb92>
ffffffffc0202e22:	000a2703          	lw	a4,0(s4)
ffffffffc0202e26:	4789                	li	a5,2
ffffffffc0202e28:	00f71de3          	bne	a4,a5,ffffffffc0203642 <pmm_init+0xb72>
ffffffffc0202e2c:	000c2783          	lw	a5,0(s8)
ffffffffc0202e30:	7e079963          	bnez	a5,ffffffffc0203622 <pmm_init+0xb52>
ffffffffc0202e34:	00093503          	ld	a0,0(s2)
ffffffffc0202e38:	4601                	li	a2,0
ffffffffc0202e3a:	6585                	lui	a1,0x1
ffffffffc0202e3c:	be8ff0ef          	jal	ra,ffffffffc0202224 <get_pte>
ffffffffc0202e40:	54050263          	beqz	a0,ffffffffc0203384 <pmm_init+0x8b4>
ffffffffc0202e44:	6118                	ld	a4,0(a0)
ffffffffc0202e46:	00177793          	andi	a5,a4,1
ffffffffc0202e4a:	180781e3          	beqz	a5,ffffffffc02037cc <pmm_init+0xcfc>
ffffffffc0202e4e:	6094                	ld	a3,0(s1)
ffffffffc0202e50:	00271793          	slli	a5,a4,0x2
ffffffffc0202e54:	83b1                	srli	a5,a5,0xc
ffffffffc0202e56:	52d7f563          	bgeu	a5,a3,ffffffffc0203380 <pmm_init+0x8b0>
ffffffffc0202e5a:	000bb683          	ld	a3,0(s7)
ffffffffc0202e5e:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202e62:	97d6                	add	a5,a5,s5
ffffffffc0202e64:	079a                	slli	a5,a5,0x6
ffffffffc0202e66:	97b6                	add	a5,a5,a3
ffffffffc0202e68:	58fa1e63          	bne	s4,a5,ffffffffc0203404 <pmm_init+0x934>
ffffffffc0202e6c:	8b41                	andi	a4,a4,16
ffffffffc0202e6e:	56071b63          	bnez	a4,ffffffffc02033e4 <pmm_init+0x914>
ffffffffc0202e72:	00093503          	ld	a0,0(s2)
ffffffffc0202e76:	4581                	li	a1,0
ffffffffc0202e78:	ac7ff0ef          	jal	ra,ffffffffc020293e <page_remove>
ffffffffc0202e7c:	000a2c83          	lw	s9,0(s4)
ffffffffc0202e80:	4785                	li	a5,1
ffffffffc0202e82:	5cfc9163          	bne	s9,a5,ffffffffc0203444 <pmm_init+0x974>
ffffffffc0202e86:	000c2783          	lw	a5,0(s8)
ffffffffc0202e8a:	58079d63          	bnez	a5,ffffffffc0203424 <pmm_init+0x954>
ffffffffc0202e8e:	00093503          	ld	a0,0(s2)
ffffffffc0202e92:	6585                	lui	a1,0x1
ffffffffc0202e94:	aabff0ef          	jal	ra,ffffffffc020293e <page_remove>
ffffffffc0202e98:	000a2783          	lw	a5,0(s4)
ffffffffc0202e9c:	200793e3          	bnez	a5,ffffffffc02038a2 <pmm_init+0xdd2>
ffffffffc0202ea0:	000c2783          	lw	a5,0(s8)
ffffffffc0202ea4:	1c079fe3          	bnez	a5,ffffffffc0203882 <pmm_init+0xdb2>
ffffffffc0202ea8:	00093a03          	ld	s4,0(s2)
ffffffffc0202eac:	608c                	ld	a1,0(s1)
ffffffffc0202eae:	000a3683          	ld	a3,0(s4)
ffffffffc0202eb2:	068a                	slli	a3,a3,0x2
ffffffffc0202eb4:	82b1                	srli	a3,a3,0xc
ffffffffc0202eb6:	4cb6f563          	bgeu	a3,a1,ffffffffc0203380 <pmm_init+0x8b0>
ffffffffc0202eba:	000bb503          	ld	a0,0(s7)
ffffffffc0202ebe:	96d6                	add	a3,a3,s5
ffffffffc0202ec0:	069a                	slli	a3,a3,0x6
ffffffffc0202ec2:	00d507b3          	add	a5,a0,a3
ffffffffc0202ec6:	439c                	lw	a5,0(a5)
ffffffffc0202ec8:	4f979e63          	bne	a5,s9,ffffffffc02033c4 <pmm_init+0x8f4>
ffffffffc0202ecc:	8699                	srai	a3,a3,0x6
ffffffffc0202ece:	00080637          	lui	a2,0x80
ffffffffc0202ed2:	96b2                	add	a3,a3,a2
ffffffffc0202ed4:	00c69713          	slli	a4,a3,0xc
ffffffffc0202ed8:	8331                	srli	a4,a4,0xc
ffffffffc0202eda:	06b2                	slli	a3,a3,0xc
ffffffffc0202edc:	06b773e3          	bgeu	a4,a1,ffffffffc0203742 <pmm_init+0xc72>
ffffffffc0202ee0:	0009b703          	ld	a4,0(s3)
ffffffffc0202ee4:	96ba                	add	a3,a3,a4
ffffffffc0202ee6:	629c                	ld	a5,0(a3)
ffffffffc0202ee8:	078a                	slli	a5,a5,0x2
ffffffffc0202eea:	83b1                	srli	a5,a5,0xc
ffffffffc0202eec:	48b7fa63          	bgeu	a5,a1,ffffffffc0203380 <pmm_init+0x8b0>
ffffffffc0202ef0:	8f91                	sub	a5,a5,a2
ffffffffc0202ef2:	079a                	slli	a5,a5,0x6
ffffffffc0202ef4:	953e                	add	a0,a0,a5
ffffffffc0202ef6:	100027f3          	csrr	a5,sstatus
ffffffffc0202efa:	8b89                	andi	a5,a5,2
ffffffffc0202efc:	32079463          	bnez	a5,ffffffffc0203224 <pmm_init+0x754>
ffffffffc0202f00:	000b3783          	ld	a5,0(s6)
ffffffffc0202f04:	4585                	li	a1,1
ffffffffc0202f06:	739c                	ld	a5,32(a5)
ffffffffc0202f08:	9782                	jalr	a5
ffffffffc0202f0a:	000a3783          	ld	a5,0(s4)
ffffffffc0202f0e:	6098                	ld	a4,0(s1)
ffffffffc0202f10:	078a                	slli	a5,a5,0x2
ffffffffc0202f12:	83b1                	srli	a5,a5,0xc
ffffffffc0202f14:	46e7f663          	bgeu	a5,a4,ffffffffc0203380 <pmm_init+0x8b0>
ffffffffc0202f18:	000bb503          	ld	a0,0(s7)
ffffffffc0202f1c:	fff80737          	lui	a4,0xfff80
ffffffffc0202f20:	97ba                	add	a5,a5,a4
ffffffffc0202f22:	079a                	slli	a5,a5,0x6
ffffffffc0202f24:	953e                	add	a0,a0,a5
ffffffffc0202f26:	100027f3          	csrr	a5,sstatus
ffffffffc0202f2a:	8b89                	andi	a5,a5,2
ffffffffc0202f2c:	2e079063          	bnez	a5,ffffffffc020320c <pmm_init+0x73c>
ffffffffc0202f30:	000b3783          	ld	a5,0(s6)
ffffffffc0202f34:	4585                	li	a1,1
ffffffffc0202f36:	739c                	ld	a5,32(a5)
ffffffffc0202f38:	9782                	jalr	a5
ffffffffc0202f3a:	00093783          	ld	a5,0(s2)
ffffffffc0202f3e:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd686f0>
ffffffffc0202f42:	12000073          	sfence.vma
ffffffffc0202f46:	100027f3          	csrr	a5,sstatus
ffffffffc0202f4a:	8b89                	andi	a5,a5,2
ffffffffc0202f4c:	2a079663          	bnez	a5,ffffffffc02031f8 <pmm_init+0x728>
ffffffffc0202f50:	000b3783          	ld	a5,0(s6)
ffffffffc0202f54:	779c                	ld	a5,40(a5)
ffffffffc0202f56:	9782                	jalr	a5
ffffffffc0202f58:	8a2a                	mv	s4,a0
ffffffffc0202f5a:	7d441463          	bne	s0,s4,ffffffffc0203722 <pmm_init+0xc52>
ffffffffc0202f5e:	0000a517          	auipc	a0,0xa
ffffffffc0202f62:	06a50513          	addi	a0,a0,106 # ffffffffc020cfc8 <default_pmm_manager+0x5f8>
ffffffffc0202f66:	a40fd0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0202f6a:	100027f3          	csrr	a5,sstatus
ffffffffc0202f6e:	8b89                	andi	a5,a5,2
ffffffffc0202f70:	26079a63          	bnez	a5,ffffffffc02031e4 <pmm_init+0x714>
ffffffffc0202f74:	000b3783          	ld	a5,0(s6)
ffffffffc0202f78:	779c                	ld	a5,40(a5)
ffffffffc0202f7a:	9782                	jalr	a5
ffffffffc0202f7c:	8c2a                	mv	s8,a0
ffffffffc0202f7e:	6098                	ld	a4,0(s1)
ffffffffc0202f80:	c0200437          	lui	s0,0xc0200
ffffffffc0202f84:	7afd                	lui	s5,0xfffff
ffffffffc0202f86:	00c71793          	slli	a5,a4,0xc
ffffffffc0202f8a:	6a05                	lui	s4,0x1
ffffffffc0202f8c:	02f47c63          	bgeu	s0,a5,ffffffffc0202fc4 <pmm_init+0x4f4>
ffffffffc0202f90:	00c45793          	srli	a5,s0,0xc
ffffffffc0202f94:	00093503          	ld	a0,0(s2)
ffffffffc0202f98:	3ae7f763          	bgeu	a5,a4,ffffffffc0203346 <pmm_init+0x876>
ffffffffc0202f9c:	0009b583          	ld	a1,0(s3)
ffffffffc0202fa0:	4601                	li	a2,0
ffffffffc0202fa2:	95a2                	add	a1,a1,s0
ffffffffc0202fa4:	a80ff0ef          	jal	ra,ffffffffc0202224 <get_pte>
ffffffffc0202fa8:	36050f63          	beqz	a0,ffffffffc0203326 <pmm_init+0x856>
ffffffffc0202fac:	611c                	ld	a5,0(a0)
ffffffffc0202fae:	078a                	slli	a5,a5,0x2
ffffffffc0202fb0:	0157f7b3          	and	a5,a5,s5
ffffffffc0202fb4:	3a879663          	bne	a5,s0,ffffffffc0203360 <pmm_init+0x890>
ffffffffc0202fb8:	6098                	ld	a4,0(s1)
ffffffffc0202fba:	9452                	add	s0,s0,s4
ffffffffc0202fbc:	00c71793          	slli	a5,a4,0xc
ffffffffc0202fc0:	fcf468e3          	bltu	s0,a5,ffffffffc0202f90 <pmm_init+0x4c0>
ffffffffc0202fc4:	00093783          	ld	a5,0(s2)
ffffffffc0202fc8:	639c                	ld	a5,0(a5)
ffffffffc0202fca:	48079d63          	bnez	a5,ffffffffc0203464 <pmm_init+0x994>
ffffffffc0202fce:	100027f3          	csrr	a5,sstatus
ffffffffc0202fd2:	8b89                	andi	a5,a5,2
ffffffffc0202fd4:	26079463          	bnez	a5,ffffffffc020323c <pmm_init+0x76c>
ffffffffc0202fd8:	000b3783          	ld	a5,0(s6)
ffffffffc0202fdc:	4505                	li	a0,1
ffffffffc0202fde:	6f9c                	ld	a5,24(a5)
ffffffffc0202fe0:	9782                	jalr	a5
ffffffffc0202fe2:	8a2a                	mv	s4,a0
ffffffffc0202fe4:	00093503          	ld	a0,0(s2)
ffffffffc0202fe8:	4699                	li	a3,6
ffffffffc0202fea:	10000613          	li	a2,256
ffffffffc0202fee:	85d2                	mv	a1,s4
ffffffffc0202ff0:	9ebff0ef          	jal	ra,ffffffffc02029da <page_insert>
ffffffffc0202ff4:	4a051863          	bnez	a0,ffffffffc02034a4 <pmm_init+0x9d4>
ffffffffc0202ff8:	000a2703          	lw	a4,0(s4) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc0202ffc:	4785                	li	a5,1
ffffffffc0202ffe:	48f71363          	bne	a4,a5,ffffffffc0203484 <pmm_init+0x9b4>
ffffffffc0203002:	00093503          	ld	a0,0(s2)
ffffffffc0203006:	6405                	lui	s0,0x1
ffffffffc0203008:	4699                	li	a3,6
ffffffffc020300a:	10040613          	addi	a2,s0,256 # 1100 <_binary_bin_swap_img_size-0x6c00>
ffffffffc020300e:	85d2                	mv	a1,s4
ffffffffc0203010:	9cbff0ef          	jal	ra,ffffffffc02029da <page_insert>
ffffffffc0203014:	38051863          	bnez	a0,ffffffffc02033a4 <pmm_init+0x8d4>
ffffffffc0203018:	000a2703          	lw	a4,0(s4)
ffffffffc020301c:	4789                	li	a5,2
ffffffffc020301e:	4ef71363          	bne	a4,a5,ffffffffc0203504 <pmm_init+0xa34>
ffffffffc0203022:	0000a597          	auipc	a1,0xa
ffffffffc0203026:	0ee58593          	addi	a1,a1,238 # ffffffffc020d110 <default_pmm_manager+0x740>
ffffffffc020302a:	10000513          	li	a0,256
ffffffffc020302e:	143080ef          	jal	ra,ffffffffc020b970 <strcpy>
ffffffffc0203032:	10040593          	addi	a1,s0,256
ffffffffc0203036:	10000513          	li	a0,256
ffffffffc020303a:	171080ef          	jal	ra,ffffffffc020b9aa <strcmp>
ffffffffc020303e:	4a051363          	bnez	a0,ffffffffc02034e4 <pmm_init+0xa14>
ffffffffc0203042:	000bb683          	ld	a3,0(s7)
ffffffffc0203046:	00080737          	lui	a4,0x80
ffffffffc020304a:	547d                	li	s0,-1
ffffffffc020304c:	40da06b3          	sub	a3,s4,a3
ffffffffc0203050:	8699                	srai	a3,a3,0x6
ffffffffc0203052:	609c                	ld	a5,0(s1)
ffffffffc0203054:	96ba                	add	a3,a3,a4
ffffffffc0203056:	8031                	srli	s0,s0,0xc
ffffffffc0203058:	0086f733          	and	a4,a3,s0
ffffffffc020305c:	06b2                	slli	a3,a3,0xc
ffffffffc020305e:	6ef77263          	bgeu	a4,a5,ffffffffc0203742 <pmm_init+0xc72>
ffffffffc0203062:	0009b783          	ld	a5,0(s3)
ffffffffc0203066:	10000513          	li	a0,256
ffffffffc020306a:	96be                	add	a3,a3,a5
ffffffffc020306c:	10068023          	sb	zero,256(a3)
ffffffffc0203070:	0cb080ef          	jal	ra,ffffffffc020b93a <strlen>
ffffffffc0203074:	44051863          	bnez	a0,ffffffffc02034c4 <pmm_init+0x9f4>
ffffffffc0203078:	00093a83          	ld	s5,0(s2)
ffffffffc020307c:	609c                	ld	a5,0(s1)
ffffffffc020307e:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd686f0>
ffffffffc0203082:	068a                	slli	a3,a3,0x2
ffffffffc0203084:	82b1                	srli	a3,a3,0xc
ffffffffc0203086:	2ef6fd63          	bgeu	a3,a5,ffffffffc0203380 <pmm_init+0x8b0>
ffffffffc020308a:	8c75                	and	s0,s0,a3
ffffffffc020308c:	06b2                	slli	a3,a3,0xc
ffffffffc020308e:	6af47a63          	bgeu	s0,a5,ffffffffc0203742 <pmm_init+0xc72>
ffffffffc0203092:	0009b403          	ld	s0,0(s3)
ffffffffc0203096:	9436                	add	s0,s0,a3
ffffffffc0203098:	100027f3          	csrr	a5,sstatus
ffffffffc020309c:	8b89                	andi	a5,a5,2
ffffffffc020309e:	1e079c63          	bnez	a5,ffffffffc0203296 <pmm_init+0x7c6>
ffffffffc02030a2:	000b3783          	ld	a5,0(s6)
ffffffffc02030a6:	4585                	li	a1,1
ffffffffc02030a8:	8552                	mv	a0,s4
ffffffffc02030aa:	739c                	ld	a5,32(a5)
ffffffffc02030ac:	9782                	jalr	a5
ffffffffc02030ae:	601c                	ld	a5,0(s0)
ffffffffc02030b0:	6098                	ld	a4,0(s1)
ffffffffc02030b2:	078a                	slli	a5,a5,0x2
ffffffffc02030b4:	83b1                	srli	a5,a5,0xc
ffffffffc02030b6:	2ce7f563          	bgeu	a5,a4,ffffffffc0203380 <pmm_init+0x8b0>
ffffffffc02030ba:	000bb503          	ld	a0,0(s7)
ffffffffc02030be:	fff80737          	lui	a4,0xfff80
ffffffffc02030c2:	97ba                	add	a5,a5,a4
ffffffffc02030c4:	079a                	slli	a5,a5,0x6
ffffffffc02030c6:	953e                	add	a0,a0,a5
ffffffffc02030c8:	100027f3          	csrr	a5,sstatus
ffffffffc02030cc:	8b89                	andi	a5,a5,2
ffffffffc02030ce:	1a079863          	bnez	a5,ffffffffc020327e <pmm_init+0x7ae>
ffffffffc02030d2:	000b3783          	ld	a5,0(s6)
ffffffffc02030d6:	4585                	li	a1,1
ffffffffc02030d8:	739c                	ld	a5,32(a5)
ffffffffc02030da:	9782                	jalr	a5
ffffffffc02030dc:	000ab783          	ld	a5,0(s5)
ffffffffc02030e0:	6098                	ld	a4,0(s1)
ffffffffc02030e2:	078a                	slli	a5,a5,0x2
ffffffffc02030e4:	83b1                	srli	a5,a5,0xc
ffffffffc02030e6:	28e7fd63          	bgeu	a5,a4,ffffffffc0203380 <pmm_init+0x8b0>
ffffffffc02030ea:	000bb503          	ld	a0,0(s7)
ffffffffc02030ee:	fff80737          	lui	a4,0xfff80
ffffffffc02030f2:	97ba                	add	a5,a5,a4
ffffffffc02030f4:	079a                	slli	a5,a5,0x6
ffffffffc02030f6:	953e                	add	a0,a0,a5
ffffffffc02030f8:	100027f3          	csrr	a5,sstatus
ffffffffc02030fc:	8b89                	andi	a5,a5,2
ffffffffc02030fe:	16079463          	bnez	a5,ffffffffc0203266 <pmm_init+0x796>
ffffffffc0203102:	000b3783          	ld	a5,0(s6)
ffffffffc0203106:	4585                	li	a1,1
ffffffffc0203108:	739c                	ld	a5,32(a5)
ffffffffc020310a:	9782                	jalr	a5
ffffffffc020310c:	00093783          	ld	a5,0(s2)
ffffffffc0203110:	0007b023          	sd	zero,0(a5)
ffffffffc0203114:	12000073          	sfence.vma
ffffffffc0203118:	100027f3          	csrr	a5,sstatus
ffffffffc020311c:	8b89                	andi	a5,a5,2
ffffffffc020311e:	12079a63          	bnez	a5,ffffffffc0203252 <pmm_init+0x782>
ffffffffc0203122:	000b3783          	ld	a5,0(s6)
ffffffffc0203126:	779c                	ld	a5,40(a5)
ffffffffc0203128:	9782                	jalr	a5
ffffffffc020312a:	842a                	mv	s0,a0
ffffffffc020312c:	488c1e63          	bne	s8,s0,ffffffffc02035c8 <pmm_init+0xaf8>
ffffffffc0203130:	0000a517          	auipc	a0,0xa
ffffffffc0203134:	05850513          	addi	a0,a0,88 # ffffffffc020d188 <default_pmm_manager+0x7b8>
ffffffffc0203138:	86efd0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc020313c:	7406                	ld	s0,96(sp)
ffffffffc020313e:	70a6                	ld	ra,104(sp)
ffffffffc0203140:	64e6                	ld	s1,88(sp)
ffffffffc0203142:	6946                	ld	s2,80(sp)
ffffffffc0203144:	69a6                	ld	s3,72(sp)
ffffffffc0203146:	6a06                	ld	s4,64(sp)
ffffffffc0203148:	7ae2                	ld	s5,56(sp)
ffffffffc020314a:	7b42                	ld	s6,48(sp)
ffffffffc020314c:	7ba2                	ld	s7,40(sp)
ffffffffc020314e:	7c02                	ld	s8,32(sp)
ffffffffc0203150:	6ce2                	ld	s9,24(sp)
ffffffffc0203152:	6165                	addi	sp,sp,112
ffffffffc0203154:	e17fe06f          	j	ffffffffc0201f6a <kmalloc_init>
ffffffffc0203158:	c80007b7          	lui	a5,0xc8000
ffffffffc020315c:	b411                	j	ffffffffc0202b60 <pmm_init+0x90>
ffffffffc020315e:	b15fd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0203162:	000b3783          	ld	a5,0(s6)
ffffffffc0203166:	4505                	li	a0,1
ffffffffc0203168:	6f9c                	ld	a5,24(a5)
ffffffffc020316a:	9782                	jalr	a5
ffffffffc020316c:	8c2a                	mv	s8,a0
ffffffffc020316e:	afffd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0203172:	b9a9                	j	ffffffffc0202dcc <pmm_init+0x2fc>
ffffffffc0203174:	afffd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0203178:	000b3783          	ld	a5,0(s6)
ffffffffc020317c:	4505                	li	a0,1
ffffffffc020317e:	6f9c                	ld	a5,24(a5)
ffffffffc0203180:	9782                	jalr	a5
ffffffffc0203182:	8a2a                	mv	s4,a0
ffffffffc0203184:	ae9fd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0203188:	b645                	j	ffffffffc0202d28 <pmm_init+0x258>
ffffffffc020318a:	ae9fd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc020318e:	000b3783          	ld	a5,0(s6)
ffffffffc0203192:	779c                	ld	a5,40(a5)
ffffffffc0203194:	9782                	jalr	a5
ffffffffc0203196:	842a                	mv	s0,a0
ffffffffc0203198:	ad5fd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc020319c:	b6b9                	j	ffffffffc0202cea <pmm_init+0x21a>
ffffffffc020319e:	ad5fd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02031a2:	000b3783          	ld	a5,0(s6)
ffffffffc02031a6:	4505                	li	a0,1
ffffffffc02031a8:	6f9c                	ld	a5,24(a5)
ffffffffc02031aa:	9782                	jalr	a5
ffffffffc02031ac:	842a                	mv	s0,a0
ffffffffc02031ae:	abffd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02031b2:	bc99                	j	ffffffffc0202c08 <pmm_init+0x138>
ffffffffc02031b4:	6705                	lui	a4,0x1
ffffffffc02031b6:	177d                	addi	a4,a4,-1
ffffffffc02031b8:	96ba                	add	a3,a3,a4
ffffffffc02031ba:	8ff5                	and	a5,a5,a3
ffffffffc02031bc:	00c7d713          	srli	a4,a5,0xc
ffffffffc02031c0:	1ca77063          	bgeu	a4,a0,ffffffffc0203380 <pmm_init+0x8b0>
ffffffffc02031c4:	000b3683          	ld	a3,0(s6)
ffffffffc02031c8:	fff80537          	lui	a0,0xfff80
ffffffffc02031cc:	972a                	add	a4,a4,a0
ffffffffc02031ce:	6a94                	ld	a3,16(a3)
ffffffffc02031d0:	8c1d                	sub	s0,s0,a5
ffffffffc02031d2:	00671513          	slli	a0,a4,0x6
ffffffffc02031d6:	00c45593          	srli	a1,s0,0xc
ffffffffc02031da:	9532                	add	a0,a0,a2
ffffffffc02031dc:	9682                	jalr	a3
ffffffffc02031de:	0009b583          	ld	a1,0(s3)
ffffffffc02031e2:	bac5                	j	ffffffffc0202bd2 <pmm_init+0x102>
ffffffffc02031e4:	a8ffd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02031e8:	000b3783          	ld	a5,0(s6)
ffffffffc02031ec:	779c                	ld	a5,40(a5)
ffffffffc02031ee:	9782                	jalr	a5
ffffffffc02031f0:	8c2a                	mv	s8,a0
ffffffffc02031f2:	a7bfd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02031f6:	b361                	j	ffffffffc0202f7e <pmm_init+0x4ae>
ffffffffc02031f8:	a7bfd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02031fc:	000b3783          	ld	a5,0(s6)
ffffffffc0203200:	779c                	ld	a5,40(a5)
ffffffffc0203202:	9782                	jalr	a5
ffffffffc0203204:	8a2a                	mv	s4,a0
ffffffffc0203206:	a67fd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc020320a:	bb81                	j	ffffffffc0202f5a <pmm_init+0x48a>
ffffffffc020320c:	e42a                	sd	a0,8(sp)
ffffffffc020320e:	a65fd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0203212:	000b3783          	ld	a5,0(s6)
ffffffffc0203216:	6522                	ld	a0,8(sp)
ffffffffc0203218:	4585                	li	a1,1
ffffffffc020321a:	739c                	ld	a5,32(a5)
ffffffffc020321c:	9782                	jalr	a5
ffffffffc020321e:	a4ffd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0203222:	bb21                	j	ffffffffc0202f3a <pmm_init+0x46a>
ffffffffc0203224:	e42a                	sd	a0,8(sp)
ffffffffc0203226:	a4dfd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc020322a:	000b3783          	ld	a5,0(s6)
ffffffffc020322e:	6522                	ld	a0,8(sp)
ffffffffc0203230:	4585                	li	a1,1
ffffffffc0203232:	739c                	ld	a5,32(a5)
ffffffffc0203234:	9782                	jalr	a5
ffffffffc0203236:	a37fd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc020323a:	b9c1                	j	ffffffffc0202f0a <pmm_init+0x43a>
ffffffffc020323c:	a37fd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0203240:	000b3783          	ld	a5,0(s6)
ffffffffc0203244:	4505                	li	a0,1
ffffffffc0203246:	6f9c                	ld	a5,24(a5)
ffffffffc0203248:	9782                	jalr	a5
ffffffffc020324a:	8a2a                	mv	s4,a0
ffffffffc020324c:	a21fd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0203250:	bb51                	j	ffffffffc0202fe4 <pmm_init+0x514>
ffffffffc0203252:	a21fd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0203256:	000b3783          	ld	a5,0(s6)
ffffffffc020325a:	779c                	ld	a5,40(a5)
ffffffffc020325c:	9782                	jalr	a5
ffffffffc020325e:	842a                	mv	s0,a0
ffffffffc0203260:	a0dfd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0203264:	b5e1                	j	ffffffffc020312c <pmm_init+0x65c>
ffffffffc0203266:	e42a                	sd	a0,8(sp)
ffffffffc0203268:	a0bfd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc020326c:	000b3783          	ld	a5,0(s6)
ffffffffc0203270:	6522                	ld	a0,8(sp)
ffffffffc0203272:	4585                	li	a1,1
ffffffffc0203274:	739c                	ld	a5,32(a5)
ffffffffc0203276:	9782                	jalr	a5
ffffffffc0203278:	9f5fd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc020327c:	bd41                	j	ffffffffc020310c <pmm_init+0x63c>
ffffffffc020327e:	e42a                	sd	a0,8(sp)
ffffffffc0203280:	9f3fd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0203284:	000b3783          	ld	a5,0(s6)
ffffffffc0203288:	6522                	ld	a0,8(sp)
ffffffffc020328a:	4585                	li	a1,1
ffffffffc020328c:	739c                	ld	a5,32(a5)
ffffffffc020328e:	9782                	jalr	a5
ffffffffc0203290:	9ddfd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0203294:	b5a1                	j	ffffffffc02030dc <pmm_init+0x60c>
ffffffffc0203296:	9ddfd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc020329a:	000b3783          	ld	a5,0(s6)
ffffffffc020329e:	4585                	li	a1,1
ffffffffc02032a0:	8552                	mv	a0,s4
ffffffffc02032a2:	739c                	ld	a5,32(a5)
ffffffffc02032a4:	9782                	jalr	a5
ffffffffc02032a6:	9c7fd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02032aa:	b511                	j	ffffffffc02030ae <pmm_init+0x5de>
ffffffffc02032ac:	00010417          	auipc	s0,0x10
ffffffffc02032b0:	d5440413          	addi	s0,s0,-684 # ffffffffc0213000 <boot_page_table_sv39>
ffffffffc02032b4:	00010797          	auipc	a5,0x10
ffffffffc02032b8:	d4c78793          	addi	a5,a5,-692 # ffffffffc0213000 <boot_page_table_sv39>
ffffffffc02032bc:	a0f41de3          	bne	s0,a5,ffffffffc0202cd6 <pmm_init+0x206>
ffffffffc02032c0:	4581                	li	a1,0
ffffffffc02032c2:	6605                	lui	a2,0x1
ffffffffc02032c4:	8522                	mv	a0,s0
ffffffffc02032c6:	73e080ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc02032ca:	0000d597          	auipc	a1,0xd
ffffffffc02032ce:	d3658593          	addi	a1,a1,-714 # ffffffffc0210000 <bootstackguard>
ffffffffc02032d2:	0000e797          	auipc	a5,0xe
ffffffffc02032d6:	d20786a3          	sb	zero,-723(a5) # ffffffffc0210fff <bootstackguard+0xfff>
ffffffffc02032da:	0000d797          	auipc	a5,0xd
ffffffffc02032de:	d2078323          	sb	zero,-730(a5) # ffffffffc0210000 <bootstackguard>
ffffffffc02032e2:	00093503          	ld	a0,0(s2)
ffffffffc02032e6:	2555ec63          	bltu	a1,s5,ffffffffc020353e <pmm_init+0xa6e>
ffffffffc02032ea:	0009b683          	ld	a3,0(s3)
ffffffffc02032ee:	4701                	li	a4,0
ffffffffc02032f0:	6605                	lui	a2,0x1
ffffffffc02032f2:	40d586b3          	sub	a3,a1,a3
ffffffffc02032f6:	956ff0ef          	jal	ra,ffffffffc020244c <boot_map_segment>
ffffffffc02032fa:	00093503          	ld	a0,0(s2)
ffffffffc02032fe:	23546363          	bltu	s0,s5,ffffffffc0203524 <pmm_init+0xa54>
ffffffffc0203302:	0009b683          	ld	a3,0(s3)
ffffffffc0203306:	4701                	li	a4,0
ffffffffc0203308:	6605                	lui	a2,0x1
ffffffffc020330a:	40d406b3          	sub	a3,s0,a3
ffffffffc020330e:	85a2                	mv	a1,s0
ffffffffc0203310:	93cff0ef          	jal	ra,ffffffffc020244c <boot_map_segment>
ffffffffc0203314:	12000073          	sfence.vma
ffffffffc0203318:	0000a517          	auipc	a0,0xa
ffffffffc020331c:	98050513          	addi	a0,a0,-1664 # ffffffffc020cc98 <default_pmm_manager+0x2c8>
ffffffffc0203320:	e87fc0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0203324:	ba4d                	j	ffffffffc0202cd6 <pmm_init+0x206>
ffffffffc0203326:	0000a697          	auipc	a3,0xa
ffffffffc020332a:	cc268693          	addi	a3,a3,-830 # ffffffffc020cfe8 <default_pmm_manager+0x618>
ffffffffc020332e:	00009617          	auipc	a2,0x9
ffffffffc0203332:	bba60613          	addi	a2,a2,-1094 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203336:	28c00593          	li	a1,652
ffffffffc020333a:	00009517          	auipc	a0,0x9
ffffffffc020333e:	7e650513          	addi	a0,a0,2022 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203342:	95cfd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203346:	86a2                	mv	a3,s0
ffffffffc0203348:	00009617          	auipc	a2,0x9
ffffffffc020334c:	6c060613          	addi	a2,a2,1728 # ffffffffc020ca08 <default_pmm_manager+0x38>
ffffffffc0203350:	28c00593          	li	a1,652
ffffffffc0203354:	00009517          	auipc	a0,0x9
ffffffffc0203358:	7cc50513          	addi	a0,a0,1996 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020335c:	942fd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203360:	0000a697          	auipc	a3,0xa
ffffffffc0203364:	cc868693          	addi	a3,a3,-824 # ffffffffc020d028 <default_pmm_manager+0x658>
ffffffffc0203368:	00009617          	auipc	a2,0x9
ffffffffc020336c:	b8060613          	addi	a2,a2,-1152 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203370:	28d00593          	li	a1,653
ffffffffc0203374:	00009517          	auipc	a0,0x9
ffffffffc0203378:	7ac50513          	addi	a0,a0,1964 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020337c:	922fd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203380:	db5fe0ef          	jal	ra,ffffffffc0202134 <pa2page.part.0>
ffffffffc0203384:	0000a697          	auipc	a3,0xa
ffffffffc0203388:	acc68693          	addi	a3,a3,-1332 # ffffffffc020ce50 <default_pmm_manager+0x480>
ffffffffc020338c:	00009617          	auipc	a2,0x9
ffffffffc0203390:	b5c60613          	addi	a2,a2,-1188 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203394:	26900593          	li	a1,617
ffffffffc0203398:	00009517          	auipc	a0,0x9
ffffffffc020339c:	78850513          	addi	a0,a0,1928 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02033a0:	8fefd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02033a4:	0000a697          	auipc	a3,0xa
ffffffffc02033a8:	d0c68693          	addi	a3,a3,-756 # ffffffffc020d0b0 <default_pmm_manager+0x6e0>
ffffffffc02033ac:	00009617          	auipc	a2,0x9
ffffffffc02033b0:	b3c60613          	addi	a2,a2,-1220 # ffffffffc020bee8 <commands+0x210>
ffffffffc02033b4:	29600593          	li	a1,662
ffffffffc02033b8:	00009517          	auipc	a0,0x9
ffffffffc02033bc:	76850513          	addi	a0,a0,1896 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02033c0:	8defd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02033c4:	0000a697          	auipc	a3,0xa
ffffffffc02033c8:	bac68693          	addi	a3,a3,-1108 # ffffffffc020cf70 <default_pmm_manager+0x5a0>
ffffffffc02033cc:	00009617          	auipc	a2,0x9
ffffffffc02033d0:	b1c60613          	addi	a2,a2,-1252 # ffffffffc020bee8 <commands+0x210>
ffffffffc02033d4:	27500593          	li	a1,629
ffffffffc02033d8:	00009517          	auipc	a0,0x9
ffffffffc02033dc:	74850513          	addi	a0,a0,1864 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02033e0:	8befd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02033e4:	0000a697          	auipc	a3,0xa
ffffffffc02033e8:	b5c68693          	addi	a3,a3,-1188 # ffffffffc020cf40 <default_pmm_manager+0x570>
ffffffffc02033ec:	00009617          	auipc	a2,0x9
ffffffffc02033f0:	afc60613          	addi	a2,a2,-1284 # ffffffffc020bee8 <commands+0x210>
ffffffffc02033f4:	26b00593          	li	a1,619
ffffffffc02033f8:	00009517          	auipc	a0,0x9
ffffffffc02033fc:	72850513          	addi	a0,a0,1832 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203400:	89efd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203404:	0000a697          	auipc	a3,0xa
ffffffffc0203408:	9ac68693          	addi	a3,a3,-1620 # ffffffffc020cdb0 <default_pmm_manager+0x3e0>
ffffffffc020340c:	00009617          	auipc	a2,0x9
ffffffffc0203410:	adc60613          	addi	a2,a2,-1316 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203414:	26a00593          	li	a1,618
ffffffffc0203418:	00009517          	auipc	a0,0x9
ffffffffc020341c:	70850513          	addi	a0,a0,1800 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203420:	87efd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203424:	0000a697          	auipc	a3,0xa
ffffffffc0203428:	b0468693          	addi	a3,a3,-1276 # ffffffffc020cf28 <default_pmm_manager+0x558>
ffffffffc020342c:	00009617          	auipc	a2,0x9
ffffffffc0203430:	abc60613          	addi	a2,a2,-1348 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203434:	26f00593          	li	a1,623
ffffffffc0203438:	00009517          	auipc	a0,0x9
ffffffffc020343c:	6e850513          	addi	a0,a0,1768 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203440:	85efd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203444:	0000a697          	auipc	a3,0xa
ffffffffc0203448:	98468693          	addi	a3,a3,-1660 # ffffffffc020cdc8 <default_pmm_manager+0x3f8>
ffffffffc020344c:	00009617          	auipc	a2,0x9
ffffffffc0203450:	a9c60613          	addi	a2,a2,-1380 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203454:	26e00593          	li	a1,622
ffffffffc0203458:	00009517          	auipc	a0,0x9
ffffffffc020345c:	6c850513          	addi	a0,a0,1736 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203460:	83efd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203464:	0000a697          	auipc	a3,0xa
ffffffffc0203468:	bdc68693          	addi	a3,a3,-1060 # ffffffffc020d040 <default_pmm_manager+0x670>
ffffffffc020346c:	00009617          	auipc	a2,0x9
ffffffffc0203470:	a7c60613          	addi	a2,a2,-1412 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203474:	29000593          	li	a1,656
ffffffffc0203478:	00009517          	auipc	a0,0x9
ffffffffc020347c:	6a850513          	addi	a0,a0,1704 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203480:	81efd0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203484:	0000a697          	auipc	a3,0xa
ffffffffc0203488:	c1468693          	addi	a3,a3,-1004 # ffffffffc020d098 <default_pmm_manager+0x6c8>
ffffffffc020348c:	00009617          	auipc	a2,0x9
ffffffffc0203490:	a5c60613          	addi	a2,a2,-1444 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203494:	29500593          	li	a1,661
ffffffffc0203498:	00009517          	auipc	a0,0x9
ffffffffc020349c:	68850513          	addi	a0,a0,1672 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02034a0:	ffffc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02034a4:	0000a697          	auipc	a3,0xa
ffffffffc02034a8:	bb468693          	addi	a3,a3,-1100 # ffffffffc020d058 <default_pmm_manager+0x688>
ffffffffc02034ac:	00009617          	auipc	a2,0x9
ffffffffc02034b0:	a3c60613          	addi	a2,a2,-1476 # ffffffffc020bee8 <commands+0x210>
ffffffffc02034b4:	29400593          	li	a1,660
ffffffffc02034b8:	00009517          	auipc	a0,0x9
ffffffffc02034bc:	66850513          	addi	a0,a0,1640 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02034c0:	fdffc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02034c4:	0000a697          	auipc	a3,0xa
ffffffffc02034c8:	c9c68693          	addi	a3,a3,-868 # ffffffffc020d160 <default_pmm_manager+0x790>
ffffffffc02034cc:	00009617          	auipc	a2,0x9
ffffffffc02034d0:	a1c60613          	addi	a2,a2,-1508 # ffffffffc020bee8 <commands+0x210>
ffffffffc02034d4:	29e00593          	li	a1,670
ffffffffc02034d8:	00009517          	auipc	a0,0x9
ffffffffc02034dc:	64850513          	addi	a0,a0,1608 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02034e0:	fbffc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02034e4:	0000a697          	auipc	a3,0xa
ffffffffc02034e8:	c4468693          	addi	a3,a3,-956 # ffffffffc020d128 <default_pmm_manager+0x758>
ffffffffc02034ec:	00009617          	auipc	a2,0x9
ffffffffc02034f0:	9fc60613          	addi	a2,a2,-1540 # ffffffffc020bee8 <commands+0x210>
ffffffffc02034f4:	29b00593          	li	a1,667
ffffffffc02034f8:	00009517          	auipc	a0,0x9
ffffffffc02034fc:	62850513          	addi	a0,a0,1576 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203500:	f9ffc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203504:	0000a697          	auipc	a3,0xa
ffffffffc0203508:	bf468693          	addi	a3,a3,-1036 # ffffffffc020d0f8 <default_pmm_manager+0x728>
ffffffffc020350c:	00009617          	auipc	a2,0x9
ffffffffc0203510:	9dc60613          	addi	a2,a2,-1572 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203514:	29700593          	li	a1,663
ffffffffc0203518:	00009517          	auipc	a0,0x9
ffffffffc020351c:	60850513          	addi	a0,a0,1544 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203520:	f7ffc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203524:	86a2                	mv	a3,s0
ffffffffc0203526:	00009617          	auipc	a2,0x9
ffffffffc020352a:	58a60613          	addi	a2,a2,1418 # ffffffffc020cab0 <default_pmm_manager+0xe0>
ffffffffc020352e:	0dc00593          	li	a1,220
ffffffffc0203532:	00009517          	auipc	a0,0x9
ffffffffc0203536:	5ee50513          	addi	a0,a0,1518 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020353a:	f65fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020353e:	86ae                	mv	a3,a1
ffffffffc0203540:	00009617          	auipc	a2,0x9
ffffffffc0203544:	57060613          	addi	a2,a2,1392 # ffffffffc020cab0 <default_pmm_manager+0xe0>
ffffffffc0203548:	0db00593          	li	a1,219
ffffffffc020354c:	00009517          	auipc	a0,0x9
ffffffffc0203550:	5d450513          	addi	a0,a0,1492 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203554:	f4bfc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203558:	00009697          	auipc	a3,0x9
ffffffffc020355c:	78868693          	addi	a3,a3,1928 # ffffffffc020cce0 <default_pmm_manager+0x310>
ffffffffc0203560:	00009617          	auipc	a2,0x9
ffffffffc0203564:	98860613          	addi	a2,a2,-1656 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203568:	24e00593          	li	a1,590
ffffffffc020356c:	00009517          	auipc	a0,0x9
ffffffffc0203570:	5b450513          	addi	a0,a0,1460 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203574:	f2bfc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203578:	00009697          	auipc	a3,0x9
ffffffffc020357c:	74868693          	addi	a3,a3,1864 # ffffffffc020ccc0 <default_pmm_manager+0x2f0>
ffffffffc0203580:	00009617          	auipc	a2,0x9
ffffffffc0203584:	96860613          	addi	a2,a2,-1688 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203588:	24d00593          	li	a1,589
ffffffffc020358c:	00009517          	auipc	a0,0x9
ffffffffc0203590:	59450513          	addi	a0,a0,1428 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203594:	f0bfc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203598:	00009617          	auipc	a2,0x9
ffffffffc020359c:	6b860613          	addi	a2,a2,1720 # ffffffffc020cc50 <default_pmm_manager+0x280>
ffffffffc02035a0:	0aa00593          	li	a1,170
ffffffffc02035a4:	00009517          	auipc	a0,0x9
ffffffffc02035a8:	57c50513          	addi	a0,a0,1404 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02035ac:	ef3fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02035b0:	00009617          	auipc	a2,0x9
ffffffffc02035b4:	60860613          	addi	a2,a2,1544 # ffffffffc020cbb8 <default_pmm_manager+0x1e8>
ffffffffc02035b8:	06500593          	li	a1,101
ffffffffc02035bc:	00009517          	auipc	a0,0x9
ffffffffc02035c0:	56450513          	addi	a0,a0,1380 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02035c4:	edbfc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02035c8:	0000a697          	auipc	a3,0xa
ffffffffc02035cc:	9d868693          	addi	a3,a3,-1576 # ffffffffc020cfa0 <default_pmm_manager+0x5d0>
ffffffffc02035d0:	00009617          	auipc	a2,0x9
ffffffffc02035d4:	91860613          	addi	a2,a2,-1768 # ffffffffc020bee8 <commands+0x210>
ffffffffc02035d8:	2a700593          	li	a1,679
ffffffffc02035dc:	00009517          	auipc	a0,0x9
ffffffffc02035e0:	54450513          	addi	a0,a0,1348 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02035e4:	ebbfc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02035e8:	00009697          	auipc	a3,0x9
ffffffffc02035ec:	7f868693          	addi	a3,a3,2040 # ffffffffc020cde0 <default_pmm_manager+0x410>
ffffffffc02035f0:	00009617          	auipc	a2,0x9
ffffffffc02035f4:	8f860613          	addi	a2,a2,-1800 # ffffffffc020bee8 <commands+0x210>
ffffffffc02035f8:	25c00593          	li	a1,604
ffffffffc02035fc:	00009517          	auipc	a0,0x9
ffffffffc0203600:	52450513          	addi	a0,a0,1316 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203604:	e9bfc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203608:	86d6                	mv	a3,s5
ffffffffc020360a:	00009617          	auipc	a2,0x9
ffffffffc020360e:	3fe60613          	addi	a2,a2,1022 # ffffffffc020ca08 <default_pmm_manager+0x38>
ffffffffc0203612:	25b00593          	li	a1,603
ffffffffc0203616:	00009517          	auipc	a0,0x9
ffffffffc020361a:	50a50513          	addi	a0,a0,1290 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020361e:	e81fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203622:	0000a697          	auipc	a3,0xa
ffffffffc0203626:	90668693          	addi	a3,a3,-1786 # ffffffffc020cf28 <default_pmm_manager+0x558>
ffffffffc020362a:	00009617          	auipc	a2,0x9
ffffffffc020362e:	8be60613          	addi	a2,a2,-1858 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203632:	26800593          	li	a1,616
ffffffffc0203636:	00009517          	auipc	a0,0x9
ffffffffc020363a:	4ea50513          	addi	a0,a0,1258 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020363e:	e61fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203642:	0000a697          	auipc	a3,0xa
ffffffffc0203646:	8ce68693          	addi	a3,a3,-1842 # ffffffffc020cf10 <default_pmm_manager+0x540>
ffffffffc020364a:	00009617          	auipc	a2,0x9
ffffffffc020364e:	89e60613          	addi	a2,a2,-1890 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203652:	26700593          	li	a1,615
ffffffffc0203656:	00009517          	auipc	a0,0x9
ffffffffc020365a:	4ca50513          	addi	a0,a0,1226 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020365e:	e41fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203662:	0000a697          	auipc	a3,0xa
ffffffffc0203666:	87e68693          	addi	a3,a3,-1922 # ffffffffc020cee0 <default_pmm_manager+0x510>
ffffffffc020366a:	00009617          	auipc	a2,0x9
ffffffffc020366e:	87e60613          	addi	a2,a2,-1922 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203672:	26600593          	li	a1,614
ffffffffc0203676:	00009517          	auipc	a0,0x9
ffffffffc020367a:	4aa50513          	addi	a0,a0,1194 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020367e:	e21fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203682:	0000a697          	auipc	a3,0xa
ffffffffc0203686:	84668693          	addi	a3,a3,-1978 # ffffffffc020cec8 <default_pmm_manager+0x4f8>
ffffffffc020368a:	00009617          	auipc	a2,0x9
ffffffffc020368e:	85e60613          	addi	a2,a2,-1954 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203692:	26400593          	li	a1,612
ffffffffc0203696:	00009517          	auipc	a0,0x9
ffffffffc020369a:	48a50513          	addi	a0,a0,1162 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020369e:	e01fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02036a2:	0000a697          	auipc	a3,0xa
ffffffffc02036a6:	80668693          	addi	a3,a3,-2042 # ffffffffc020cea8 <default_pmm_manager+0x4d8>
ffffffffc02036aa:	00009617          	auipc	a2,0x9
ffffffffc02036ae:	83e60613          	addi	a2,a2,-1986 # ffffffffc020bee8 <commands+0x210>
ffffffffc02036b2:	26300593          	li	a1,611
ffffffffc02036b6:	00009517          	auipc	a0,0x9
ffffffffc02036ba:	46a50513          	addi	a0,a0,1130 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02036be:	de1fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02036c2:	00009697          	auipc	a3,0x9
ffffffffc02036c6:	7d668693          	addi	a3,a3,2006 # ffffffffc020ce98 <default_pmm_manager+0x4c8>
ffffffffc02036ca:	00009617          	auipc	a2,0x9
ffffffffc02036ce:	81e60613          	addi	a2,a2,-2018 # ffffffffc020bee8 <commands+0x210>
ffffffffc02036d2:	26200593          	li	a1,610
ffffffffc02036d6:	00009517          	auipc	a0,0x9
ffffffffc02036da:	44a50513          	addi	a0,a0,1098 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02036de:	dc1fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02036e2:	00009697          	auipc	a3,0x9
ffffffffc02036e6:	7a668693          	addi	a3,a3,1958 # ffffffffc020ce88 <default_pmm_manager+0x4b8>
ffffffffc02036ea:	00008617          	auipc	a2,0x8
ffffffffc02036ee:	7fe60613          	addi	a2,a2,2046 # ffffffffc020bee8 <commands+0x210>
ffffffffc02036f2:	26100593          	li	a1,609
ffffffffc02036f6:	00009517          	auipc	a0,0x9
ffffffffc02036fa:	42a50513          	addi	a0,a0,1066 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02036fe:	da1fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203702:	00009697          	auipc	a3,0x9
ffffffffc0203706:	74e68693          	addi	a3,a3,1870 # ffffffffc020ce50 <default_pmm_manager+0x480>
ffffffffc020370a:	00008617          	auipc	a2,0x8
ffffffffc020370e:	7de60613          	addi	a2,a2,2014 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203712:	26000593          	li	a1,608
ffffffffc0203716:	00009517          	auipc	a0,0x9
ffffffffc020371a:	40a50513          	addi	a0,a0,1034 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020371e:	d81fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203722:	0000a697          	auipc	a3,0xa
ffffffffc0203726:	87e68693          	addi	a3,a3,-1922 # ffffffffc020cfa0 <default_pmm_manager+0x5d0>
ffffffffc020372a:	00008617          	auipc	a2,0x8
ffffffffc020372e:	7be60613          	addi	a2,a2,1982 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203732:	27d00593          	li	a1,637
ffffffffc0203736:	00009517          	auipc	a0,0x9
ffffffffc020373a:	3ea50513          	addi	a0,a0,1002 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020373e:	d61fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203742:	00009617          	auipc	a2,0x9
ffffffffc0203746:	2c660613          	addi	a2,a2,710 # ffffffffc020ca08 <default_pmm_manager+0x38>
ffffffffc020374a:	07100593          	li	a1,113
ffffffffc020374e:	00009517          	auipc	a0,0x9
ffffffffc0203752:	2e250513          	addi	a0,a0,738 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0203756:	d49fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020375a:	86a2                	mv	a3,s0
ffffffffc020375c:	00009617          	auipc	a2,0x9
ffffffffc0203760:	35460613          	addi	a2,a2,852 # ffffffffc020cab0 <default_pmm_manager+0xe0>
ffffffffc0203764:	0ca00593          	li	a1,202
ffffffffc0203768:	00009517          	auipc	a0,0x9
ffffffffc020376c:	3b850513          	addi	a0,a0,952 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203770:	d2ffc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203774:	00009617          	auipc	a2,0x9
ffffffffc0203778:	33c60613          	addi	a2,a2,828 # ffffffffc020cab0 <default_pmm_manager+0xe0>
ffffffffc020377c:	08100593          	li	a1,129
ffffffffc0203780:	00009517          	auipc	a0,0x9
ffffffffc0203784:	3a050513          	addi	a0,a0,928 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203788:	d17fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020378c:	00009697          	auipc	a3,0x9
ffffffffc0203790:	68468693          	addi	a3,a3,1668 # ffffffffc020ce10 <default_pmm_manager+0x440>
ffffffffc0203794:	00008617          	auipc	a2,0x8
ffffffffc0203798:	75460613          	addi	a2,a2,1876 # ffffffffc020bee8 <commands+0x210>
ffffffffc020379c:	25f00593          	li	a1,607
ffffffffc02037a0:	00009517          	auipc	a0,0x9
ffffffffc02037a4:	38050513          	addi	a0,a0,896 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02037a8:	cf7fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02037ac:	00009697          	auipc	a3,0x9
ffffffffc02037b0:	5a468693          	addi	a3,a3,1444 # ffffffffc020cd50 <default_pmm_manager+0x380>
ffffffffc02037b4:	00008617          	auipc	a2,0x8
ffffffffc02037b8:	73460613          	addi	a2,a2,1844 # ffffffffc020bee8 <commands+0x210>
ffffffffc02037bc:	25300593          	li	a1,595
ffffffffc02037c0:	00009517          	auipc	a0,0x9
ffffffffc02037c4:	36050513          	addi	a0,a0,864 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02037c8:	cd7fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02037cc:	985fe0ef          	jal	ra,ffffffffc0202150 <pte2page.part.0>
ffffffffc02037d0:	00009697          	auipc	a3,0x9
ffffffffc02037d4:	5b068693          	addi	a3,a3,1456 # ffffffffc020cd80 <default_pmm_manager+0x3b0>
ffffffffc02037d8:	00008617          	auipc	a2,0x8
ffffffffc02037dc:	71060613          	addi	a2,a2,1808 # ffffffffc020bee8 <commands+0x210>
ffffffffc02037e0:	25600593          	li	a1,598
ffffffffc02037e4:	00009517          	auipc	a0,0x9
ffffffffc02037e8:	33c50513          	addi	a0,a0,828 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02037ec:	cb3fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02037f0:	00009697          	auipc	a3,0x9
ffffffffc02037f4:	53068693          	addi	a3,a3,1328 # ffffffffc020cd20 <default_pmm_manager+0x350>
ffffffffc02037f8:	00008617          	auipc	a2,0x8
ffffffffc02037fc:	6f060613          	addi	a2,a2,1776 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203800:	24f00593          	li	a1,591
ffffffffc0203804:	00009517          	auipc	a0,0x9
ffffffffc0203808:	31c50513          	addi	a0,a0,796 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020380c:	c93fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203810:	00009697          	auipc	a3,0x9
ffffffffc0203814:	5a068693          	addi	a3,a3,1440 # ffffffffc020cdb0 <default_pmm_manager+0x3e0>
ffffffffc0203818:	00008617          	auipc	a2,0x8
ffffffffc020381c:	6d060613          	addi	a2,a2,1744 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203820:	25700593          	li	a1,599
ffffffffc0203824:	00009517          	auipc	a0,0x9
ffffffffc0203828:	2fc50513          	addi	a0,a0,764 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020382c:	c73fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203830:	00009617          	auipc	a2,0x9
ffffffffc0203834:	1d860613          	addi	a2,a2,472 # ffffffffc020ca08 <default_pmm_manager+0x38>
ffffffffc0203838:	25a00593          	li	a1,602
ffffffffc020383c:	00009517          	auipc	a0,0x9
ffffffffc0203840:	2e450513          	addi	a0,a0,740 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203844:	c5bfc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203848:	00009697          	auipc	a3,0x9
ffffffffc020384c:	58068693          	addi	a3,a3,1408 # ffffffffc020cdc8 <default_pmm_manager+0x3f8>
ffffffffc0203850:	00008617          	auipc	a2,0x8
ffffffffc0203854:	69860613          	addi	a2,a2,1688 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203858:	25800593          	li	a1,600
ffffffffc020385c:	00009517          	auipc	a0,0x9
ffffffffc0203860:	2c450513          	addi	a0,a0,708 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203864:	c3bfc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203868:	86ca                	mv	a3,s2
ffffffffc020386a:	00009617          	auipc	a2,0x9
ffffffffc020386e:	24660613          	addi	a2,a2,582 # ffffffffc020cab0 <default_pmm_manager+0xe0>
ffffffffc0203872:	0c600593          	li	a1,198
ffffffffc0203876:	00009517          	auipc	a0,0x9
ffffffffc020387a:	2aa50513          	addi	a0,a0,682 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020387e:	c21fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203882:	00009697          	auipc	a3,0x9
ffffffffc0203886:	6a668693          	addi	a3,a3,1702 # ffffffffc020cf28 <default_pmm_manager+0x558>
ffffffffc020388a:	00008617          	auipc	a2,0x8
ffffffffc020388e:	65e60613          	addi	a2,a2,1630 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203892:	27300593          	li	a1,627
ffffffffc0203896:	00009517          	auipc	a0,0x9
ffffffffc020389a:	28a50513          	addi	a0,a0,650 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc020389e:	c01fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02038a2:	00009697          	auipc	a3,0x9
ffffffffc02038a6:	6b668693          	addi	a3,a3,1718 # ffffffffc020cf58 <default_pmm_manager+0x588>
ffffffffc02038aa:	00008617          	auipc	a2,0x8
ffffffffc02038ae:	63e60613          	addi	a2,a2,1598 # ffffffffc020bee8 <commands+0x210>
ffffffffc02038b2:	27200593          	li	a1,626
ffffffffc02038b6:	00009517          	auipc	a0,0x9
ffffffffc02038ba:	26a50513          	addi	a0,a0,618 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc02038be:	be1fc0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02038c2 <copy_range>:
ffffffffc02038c2:	7159                	addi	sp,sp,-112
ffffffffc02038c4:	00d667b3          	or	a5,a2,a3
ffffffffc02038c8:	f486                	sd	ra,104(sp)
ffffffffc02038ca:	f0a2                	sd	s0,96(sp)
ffffffffc02038cc:	eca6                	sd	s1,88(sp)
ffffffffc02038ce:	e8ca                	sd	s2,80(sp)
ffffffffc02038d0:	e4ce                	sd	s3,72(sp)
ffffffffc02038d2:	e0d2                	sd	s4,64(sp)
ffffffffc02038d4:	fc56                	sd	s5,56(sp)
ffffffffc02038d6:	f85a                	sd	s6,48(sp)
ffffffffc02038d8:	f45e                	sd	s7,40(sp)
ffffffffc02038da:	f062                	sd	s8,32(sp)
ffffffffc02038dc:	ec66                	sd	s9,24(sp)
ffffffffc02038de:	e86a                	sd	s10,16(sp)
ffffffffc02038e0:	e46e                	sd	s11,8(sp)
ffffffffc02038e2:	17d2                	slli	a5,a5,0x34
ffffffffc02038e4:	20079f63          	bnez	a5,ffffffffc0203b02 <copy_range+0x240>
ffffffffc02038e8:	002007b7          	lui	a5,0x200
ffffffffc02038ec:	8432                	mv	s0,a2
ffffffffc02038ee:	1af66263          	bltu	a2,a5,ffffffffc0203a92 <copy_range+0x1d0>
ffffffffc02038f2:	8936                	mv	s2,a3
ffffffffc02038f4:	18d67f63          	bgeu	a2,a3,ffffffffc0203a92 <copy_range+0x1d0>
ffffffffc02038f8:	4785                	li	a5,1
ffffffffc02038fa:	07fe                	slli	a5,a5,0x1f
ffffffffc02038fc:	18d7eb63          	bltu	a5,a3,ffffffffc0203a92 <copy_range+0x1d0>
ffffffffc0203900:	5b7d                	li	s6,-1
ffffffffc0203902:	8aaa                	mv	s5,a0
ffffffffc0203904:	89ae                	mv	s3,a1
ffffffffc0203906:	6a05                	lui	s4,0x1
ffffffffc0203908:	00093c17          	auipc	s8,0x93
ffffffffc020390c:	f98c0c13          	addi	s8,s8,-104 # ffffffffc02968a0 <npage>
ffffffffc0203910:	00093b97          	auipc	s7,0x93
ffffffffc0203914:	f98b8b93          	addi	s7,s7,-104 # ffffffffc02968a8 <pages>
ffffffffc0203918:	00cb5b13          	srli	s6,s6,0xc
ffffffffc020391c:	00093c97          	auipc	s9,0x93
ffffffffc0203920:	f94c8c93          	addi	s9,s9,-108 # ffffffffc02968b0 <pmm_manager>
ffffffffc0203924:	4601                	li	a2,0
ffffffffc0203926:	85a2                	mv	a1,s0
ffffffffc0203928:	854e                	mv	a0,s3
ffffffffc020392a:	8fbfe0ef          	jal	ra,ffffffffc0202224 <get_pte>
ffffffffc020392e:	84aa                	mv	s1,a0
ffffffffc0203930:	0e050c63          	beqz	a0,ffffffffc0203a28 <copy_range+0x166>
ffffffffc0203934:	611c                	ld	a5,0(a0)
ffffffffc0203936:	8b85                	andi	a5,a5,1
ffffffffc0203938:	e785                	bnez	a5,ffffffffc0203960 <copy_range+0x9e>
ffffffffc020393a:	9452                	add	s0,s0,s4
ffffffffc020393c:	ff2464e3          	bltu	s0,s2,ffffffffc0203924 <copy_range+0x62>
ffffffffc0203940:	4501                	li	a0,0
ffffffffc0203942:	70a6                	ld	ra,104(sp)
ffffffffc0203944:	7406                	ld	s0,96(sp)
ffffffffc0203946:	64e6                	ld	s1,88(sp)
ffffffffc0203948:	6946                	ld	s2,80(sp)
ffffffffc020394a:	69a6                	ld	s3,72(sp)
ffffffffc020394c:	6a06                	ld	s4,64(sp)
ffffffffc020394e:	7ae2                	ld	s5,56(sp)
ffffffffc0203950:	7b42                	ld	s6,48(sp)
ffffffffc0203952:	7ba2                	ld	s7,40(sp)
ffffffffc0203954:	7c02                	ld	s8,32(sp)
ffffffffc0203956:	6ce2                	ld	s9,24(sp)
ffffffffc0203958:	6d42                	ld	s10,16(sp)
ffffffffc020395a:	6da2                	ld	s11,8(sp)
ffffffffc020395c:	6165                	addi	sp,sp,112
ffffffffc020395e:	8082                	ret
ffffffffc0203960:	4605                	li	a2,1
ffffffffc0203962:	85a2                	mv	a1,s0
ffffffffc0203964:	8556                	mv	a0,s5
ffffffffc0203966:	8bffe0ef          	jal	ra,ffffffffc0202224 <get_pte>
ffffffffc020396a:	c56d                	beqz	a0,ffffffffc0203a54 <copy_range+0x192>
ffffffffc020396c:	609c                	ld	a5,0(s1)
ffffffffc020396e:	0017f713          	andi	a4,a5,1
ffffffffc0203972:	01f7f493          	andi	s1,a5,31
ffffffffc0203976:	16070a63          	beqz	a4,ffffffffc0203aea <copy_range+0x228>
ffffffffc020397a:	000c3683          	ld	a3,0(s8)
ffffffffc020397e:	078a                	slli	a5,a5,0x2
ffffffffc0203980:	00c7d713          	srli	a4,a5,0xc
ffffffffc0203984:	14d77763          	bgeu	a4,a3,ffffffffc0203ad2 <copy_range+0x210>
ffffffffc0203988:	000bb783          	ld	a5,0(s7)
ffffffffc020398c:	fff806b7          	lui	a3,0xfff80
ffffffffc0203990:	9736                	add	a4,a4,a3
ffffffffc0203992:	071a                	slli	a4,a4,0x6
ffffffffc0203994:	00e78db3          	add	s11,a5,a4
ffffffffc0203998:	10002773          	csrr	a4,sstatus
ffffffffc020399c:	8b09                	andi	a4,a4,2
ffffffffc020399e:	e345                	bnez	a4,ffffffffc0203a3e <copy_range+0x17c>
ffffffffc02039a0:	000cb703          	ld	a4,0(s9)
ffffffffc02039a4:	4505                	li	a0,1
ffffffffc02039a6:	6f18                	ld	a4,24(a4)
ffffffffc02039a8:	9702                	jalr	a4
ffffffffc02039aa:	8d2a                	mv	s10,a0
ffffffffc02039ac:	0c0d8363          	beqz	s11,ffffffffc0203a72 <copy_range+0x1b0>
ffffffffc02039b0:	100d0163          	beqz	s10,ffffffffc0203ab2 <copy_range+0x1f0>
ffffffffc02039b4:	000bb703          	ld	a4,0(s7)
ffffffffc02039b8:	000805b7          	lui	a1,0x80
ffffffffc02039bc:	000c3603          	ld	a2,0(s8)
ffffffffc02039c0:	40ed86b3          	sub	a3,s11,a4
ffffffffc02039c4:	8699                	srai	a3,a3,0x6
ffffffffc02039c6:	96ae                	add	a3,a3,a1
ffffffffc02039c8:	0166f7b3          	and	a5,a3,s6
ffffffffc02039cc:	06b2                	slli	a3,a3,0xc
ffffffffc02039ce:	08c7f663          	bgeu	a5,a2,ffffffffc0203a5a <copy_range+0x198>
ffffffffc02039d2:	40ed07b3          	sub	a5,s10,a4
ffffffffc02039d6:	00093717          	auipc	a4,0x93
ffffffffc02039da:	ee270713          	addi	a4,a4,-286 # ffffffffc02968b8 <va_pa_offset>
ffffffffc02039de:	6308                	ld	a0,0(a4)
ffffffffc02039e0:	8799                	srai	a5,a5,0x6
ffffffffc02039e2:	97ae                	add	a5,a5,a1
ffffffffc02039e4:	0167f733          	and	a4,a5,s6
ffffffffc02039e8:	00a685b3          	add	a1,a3,a0
ffffffffc02039ec:	07b2                	slli	a5,a5,0xc
ffffffffc02039ee:	06c77563          	bgeu	a4,a2,ffffffffc0203a58 <copy_range+0x196>
ffffffffc02039f2:	6605                	lui	a2,0x1
ffffffffc02039f4:	953e                	add	a0,a0,a5
ffffffffc02039f6:	060080ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc02039fa:	86a6                	mv	a3,s1
ffffffffc02039fc:	8622                	mv	a2,s0
ffffffffc02039fe:	85ea                	mv	a1,s10
ffffffffc0203a00:	8556                	mv	a0,s5
ffffffffc0203a02:	fd9fe0ef          	jal	ra,ffffffffc02029da <page_insert>
ffffffffc0203a06:	d915                	beqz	a0,ffffffffc020393a <copy_range+0x78>
ffffffffc0203a08:	00009697          	auipc	a3,0x9
ffffffffc0203a0c:	7c068693          	addi	a3,a3,1984 # ffffffffc020d1c8 <default_pmm_manager+0x7f8>
ffffffffc0203a10:	00008617          	auipc	a2,0x8
ffffffffc0203a14:	4d860613          	addi	a2,a2,1240 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203a18:	1eb00593          	li	a1,491
ffffffffc0203a1c:	00009517          	auipc	a0,0x9
ffffffffc0203a20:	10450513          	addi	a0,a0,260 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203a24:	a7bfc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203a28:	00200637          	lui	a2,0x200
ffffffffc0203a2c:	9432                	add	s0,s0,a2
ffffffffc0203a2e:	ffe00637          	lui	a2,0xffe00
ffffffffc0203a32:	8c71                	and	s0,s0,a2
ffffffffc0203a34:	f00406e3          	beqz	s0,ffffffffc0203940 <copy_range+0x7e>
ffffffffc0203a38:	ef2466e3          	bltu	s0,s2,ffffffffc0203924 <copy_range+0x62>
ffffffffc0203a3c:	b711                	j	ffffffffc0203940 <copy_range+0x7e>
ffffffffc0203a3e:	a34fd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0203a42:	000cb703          	ld	a4,0(s9)
ffffffffc0203a46:	4505                	li	a0,1
ffffffffc0203a48:	6f18                	ld	a4,24(a4)
ffffffffc0203a4a:	9702                	jalr	a4
ffffffffc0203a4c:	8d2a                	mv	s10,a0
ffffffffc0203a4e:	a1efd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0203a52:	bfa9                	j	ffffffffc02039ac <copy_range+0xea>
ffffffffc0203a54:	5571                	li	a0,-4
ffffffffc0203a56:	b5f5                	j	ffffffffc0203942 <copy_range+0x80>
ffffffffc0203a58:	86be                	mv	a3,a5
ffffffffc0203a5a:	00009617          	auipc	a2,0x9
ffffffffc0203a5e:	fae60613          	addi	a2,a2,-82 # ffffffffc020ca08 <default_pmm_manager+0x38>
ffffffffc0203a62:	07100593          	li	a1,113
ffffffffc0203a66:	00009517          	auipc	a0,0x9
ffffffffc0203a6a:	fca50513          	addi	a0,a0,-54 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0203a6e:	a31fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203a72:	00009697          	auipc	a3,0x9
ffffffffc0203a76:	73668693          	addi	a3,a3,1846 # ffffffffc020d1a8 <default_pmm_manager+0x7d8>
ffffffffc0203a7a:	00008617          	auipc	a2,0x8
ffffffffc0203a7e:	46e60613          	addi	a2,a2,1134 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203a82:	1ce00593          	li	a1,462
ffffffffc0203a86:	00009517          	auipc	a0,0x9
ffffffffc0203a8a:	09a50513          	addi	a0,a0,154 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203a8e:	a11fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203a92:	00009697          	auipc	a3,0x9
ffffffffc0203a96:	0f668693          	addi	a3,a3,246 # ffffffffc020cb88 <default_pmm_manager+0x1b8>
ffffffffc0203a9a:	00008617          	auipc	a2,0x8
ffffffffc0203a9e:	44e60613          	addi	a2,a2,1102 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203aa2:	1b600593          	li	a1,438
ffffffffc0203aa6:	00009517          	auipc	a0,0x9
ffffffffc0203aaa:	07a50513          	addi	a0,a0,122 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203aae:	9f1fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203ab2:	00009697          	auipc	a3,0x9
ffffffffc0203ab6:	70668693          	addi	a3,a3,1798 # ffffffffc020d1b8 <default_pmm_manager+0x7e8>
ffffffffc0203aba:	00008617          	auipc	a2,0x8
ffffffffc0203abe:	42e60613          	addi	a2,a2,1070 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203ac2:	1cf00593          	li	a1,463
ffffffffc0203ac6:	00009517          	auipc	a0,0x9
ffffffffc0203aca:	05a50513          	addi	a0,a0,90 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203ace:	9d1fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203ad2:	00009617          	auipc	a2,0x9
ffffffffc0203ad6:	00660613          	addi	a2,a2,6 # ffffffffc020cad8 <default_pmm_manager+0x108>
ffffffffc0203ada:	06900593          	li	a1,105
ffffffffc0203ade:	00009517          	auipc	a0,0x9
ffffffffc0203ae2:	f5250513          	addi	a0,a0,-174 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0203ae6:	9b9fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203aea:	00009617          	auipc	a2,0x9
ffffffffc0203aee:	00e60613          	addi	a2,a2,14 # ffffffffc020caf8 <default_pmm_manager+0x128>
ffffffffc0203af2:	07f00593          	li	a1,127
ffffffffc0203af6:	00009517          	auipc	a0,0x9
ffffffffc0203afa:	f3a50513          	addi	a0,a0,-198 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0203afe:	9a1fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203b02:	00009697          	auipc	a3,0x9
ffffffffc0203b06:	05668693          	addi	a3,a3,86 # ffffffffc020cb58 <default_pmm_manager+0x188>
ffffffffc0203b0a:	00008617          	auipc	a2,0x8
ffffffffc0203b0e:	3de60613          	addi	a2,a2,990 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203b12:	1b500593          	li	a1,437
ffffffffc0203b16:	00009517          	auipc	a0,0x9
ffffffffc0203b1a:	00a50513          	addi	a0,a0,10 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203b1e:	981fc0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0203b22 <pgdir_alloc_page>:
ffffffffc0203b22:	7179                	addi	sp,sp,-48
ffffffffc0203b24:	ec26                	sd	s1,24(sp)
ffffffffc0203b26:	e84a                	sd	s2,16(sp)
ffffffffc0203b28:	e052                	sd	s4,0(sp)
ffffffffc0203b2a:	f406                	sd	ra,40(sp)
ffffffffc0203b2c:	f022                	sd	s0,32(sp)
ffffffffc0203b2e:	e44e                	sd	s3,8(sp)
ffffffffc0203b30:	8a2a                	mv	s4,a0
ffffffffc0203b32:	84ae                	mv	s1,a1
ffffffffc0203b34:	8932                	mv	s2,a2
ffffffffc0203b36:	100027f3          	csrr	a5,sstatus
ffffffffc0203b3a:	8b89                	andi	a5,a5,2
ffffffffc0203b3c:	00093997          	auipc	s3,0x93
ffffffffc0203b40:	d7498993          	addi	s3,s3,-652 # ffffffffc02968b0 <pmm_manager>
ffffffffc0203b44:	ef8d                	bnez	a5,ffffffffc0203b7e <pgdir_alloc_page+0x5c>
ffffffffc0203b46:	0009b783          	ld	a5,0(s3)
ffffffffc0203b4a:	4505                	li	a0,1
ffffffffc0203b4c:	6f9c                	ld	a5,24(a5)
ffffffffc0203b4e:	9782                	jalr	a5
ffffffffc0203b50:	842a                	mv	s0,a0
ffffffffc0203b52:	cc09                	beqz	s0,ffffffffc0203b6c <pgdir_alloc_page+0x4a>
ffffffffc0203b54:	86ca                	mv	a3,s2
ffffffffc0203b56:	8626                	mv	a2,s1
ffffffffc0203b58:	85a2                	mv	a1,s0
ffffffffc0203b5a:	8552                	mv	a0,s4
ffffffffc0203b5c:	e7ffe0ef          	jal	ra,ffffffffc02029da <page_insert>
ffffffffc0203b60:	e915                	bnez	a0,ffffffffc0203b94 <pgdir_alloc_page+0x72>
ffffffffc0203b62:	4018                	lw	a4,0(s0)
ffffffffc0203b64:	fc04                	sd	s1,56(s0)
ffffffffc0203b66:	4785                	li	a5,1
ffffffffc0203b68:	04f71e63          	bne	a4,a5,ffffffffc0203bc4 <pgdir_alloc_page+0xa2>
ffffffffc0203b6c:	70a2                	ld	ra,40(sp)
ffffffffc0203b6e:	8522                	mv	a0,s0
ffffffffc0203b70:	7402                	ld	s0,32(sp)
ffffffffc0203b72:	64e2                	ld	s1,24(sp)
ffffffffc0203b74:	6942                	ld	s2,16(sp)
ffffffffc0203b76:	69a2                	ld	s3,8(sp)
ffffffffc0203b78:	6a02                	ld	s4,0(sp)
ffffffffc0203b7a:	6145                	addi	sp,sp,48
ffffffffc0203b7c:	8082                	ret
ffffffffc0203b7e:	8f4fd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0203b82:	0009b783          	ld	a5,0(s3)
ffffffffc0203b86:	4505                	li	a0,1
ffffffffc0203b88:	6f9c                	ld	a5,24(a5)
ffffffffc0203b8a:	9782                	jalr	a5
ffffffffc0203b8c:	842a                	mv	s0,a0
ffffffffc0203b8e:	8defd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0203b92:	b7c1                	j	ffffffffc0203b52 <pgdir_alloc_page+0x30>
ffffffffc0203b94:	100027f3          	csrr	a5,sstatus
ffffffffc0203b98:	8b89                	andi	a5,a5,2
ffffffffc0203b9a:	eb89                	bnez	a5,ffffffffc0203bac <pgdir_alloc_page+0x8a>
ffffffffc0203b9c:	0009b783          	ld	a5,0(s3)
ffffffffc0203ba0:	8522                	mv	a0,s0
ffffffffc0203ba2:	4585                	li	a1,1
ffffffffc0203ba4:	739c                	ld	a5,32(a5)
ffffffffc0203ba6:	4401                	li	s0,0
ffffffffc0203ba8:	9782                	jalr	a5
ffffffffc0203baa:	b7c9                	j	ffffffffc0203b6c <pgdir_alloc_page+0x4a>
ffffffffc0203bac:	8c6fd0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0203bb0:	0009b783          	ld	a5,0(s3)
ffffffffc0203bb4:	8522                	mv	a0,s0
ffffffffc0203bb6:	4585                	li	a1,1
ffffffffc0203bb8:	739c                	ld	a5,32(a5)
ffffffffc0203bba:	4401                	li	s0,0
ffffffffc0203bbc:	9782                	jalr	a5
ffffffffc0203bbe:	8aefd0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0203bc2:	b76d                	j	ffffffffc0203b6c <pgdir_alloc_page+0x4a>
ffffffffc0203bc4:	00009697          	auipc	a3,0x9
ffffffffc0203bc8:	61468693          	addi	a3,a3,1556 # ffffffffc020d1d8 <default_pmm_manager+0x808>
ffffffffc0203bcc:	00008617          	auipc	a2,0x8
ffffffffc0203bd0:	31c60613          	addi	a2,a2,796 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203bd4:	23400593          	li	a1,564
ffffffffc0203bd8:	00009517          	auipc	a0,0x9
ffffffffc0203bdc:	f4850513          	addi	a0,a0,-184 # ffffffffc020cb20 <default_pmm_manager+0x150>
ffffffffc0203be0:	8bffc0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0203be4 <check_vma_overlap.part.0>:
ffffffffc0203be4:	1141                	addi	sp,sp,-16
ffffffffc0203be6:	00009697          	auipc	a3,0x9
ffffffffc0203bea:	60a68693          	addi	a3,a3,1546 # ffffffffc020d1f0 <default_pmm_manager+0x820>
ffffffffc0203bee:	00008617          	auipc	a2,0x8
ffffffffc0203bf2:	2fa60613          	addi	a2,a2,762 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203bf6:	07400593          	li	a1,116
ffffffffc0203bfa:	00009517          	auipc	a0,0x9
ffffffffc0203bfe:	61650513          	addi	a0,a0,1558 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc0203c02:	e406                	sd	ra,8(sp)
ffffffffc0203c04:	89bfc0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0203c08 <mm_create>:
ffffffffc0203c08:	1141                	addi	sp,sp,-16
ffffffffc0203c0a:	05800513          	li	a0,88
ffffffffc0203c0e:	e022                	sd	s0,0(sp)
ffffffffc0203c10:	e406                	sd	ra,8(sp)
ffffffffc0203c12:	b7cfe0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc0203c16:	842a                	mv	s0,a0
ffffffffc0203c18:	c115                	beqz	a0,ffffffffc0203c3c <mm_create+0x34>
ffffffffc0203c1a:	e408                	sd	a0,8(s0)
ffffffffc0203c1c:	e008                	sd	a0,0(s0)
ffffffffc0203c1e:	00053823          	sd	zero,16(a0)
ffffffffc0203c22:	00053c23          	sd	zero,24(a0)
ffffffffc0203c26:	02052023          	sw	zero,32(a0)
ffffffffc0203c2a:	02053423          	sd	zero,40(a0)
ffffffffc0203c2e:	02052823          	sw	zero,48(a0)
ffffffffc0203c32:	4585                	li	a1,1
ffffffffc0203c34:	03850513          	addi	a0,a0,56
ffffffffc0203c38:	123000ef          	jal	ra,ffffffffc020455a <sem_init>
ffffffffc0203c3c:	60a2                	ld	ra,8(sp)
ffffffffc0203c3e:	8522                	mv	a0,s0
ffffffffc0203c40:	6402                	ld	s0,0(sp)
ffffffffc0203c42:	0141                	addi	sp,sp,16
ffffffffc0203c44:	8082                	ret

ffffffffc0203c46 <find_vma>:
ffffffffc0203c46:	86aa                	mv	a3,a0
ffffffffc0203c48:	c505                	beqz	a0,ffffffffc0203c70 <find_vma+0x2a>
ffffffffc0203c4a:	6908                	ld	a0,16(a0)
ffffffffc0203c4c:	c501                	beqz	a0,ffffffffc0203c54 <find_vma+0xe>
ffffffffc0203c4e:	651c                	ld	a5,8(a0)
ffffffffc0203c50:	02f5f263          	bgeu	a1,a5,ffffffffc0203c74 <find_vma+0x2e>
ffffffffc0203c54:	669c                	ld	a5,8(a3)
ffffffffc0203c56:	00f68d63          	beq	a3,a5,ffffffffc0203c70 <find_vma+0x2a>
ffffffffc0203c5a:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_bin_sfs_img_size+0x18ace8>
ffffffffc0203c5e:	00e5e663          	bltu	a1,a4,ffffffffc0203c6a <find_vma+0x24>
ffffffffc0203c62:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203c66:	00e5ec63          	bltu	a1,a4,ffffffffc0203c7e <find_vma+0x38>
ffffffffc0203c6a:	679c                	ld	a5,8(a5)
ffffffffc0203c6c:	fef697e3          	bne	a3,a5,ffffffffc0203c5a <find_vma+0x14>
ffffffffc0203c70:	4501                	li	a0,0
ffffffffc0203c72:	8082                	ret
ffffffffc0203c74:	691c                	ld	a5,16(a0)
ffffffffc0203c76:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203c54 <find_vma+0xe>
ffffffffc0203c7a:	ea88                	sd	a0,16(a3)
ffffffffc0203c7c:	8082                	ret
ffffffffc0203c7e:	fe078513          	addi	a0,a5,-32
ffffffffc0203c82:	ea88                	sd	a0,16(a3)
ffffffffc0203c84:	8082                	ret

ffffffffc0203c86 <insert_vma_struct>:
ffffffffc0203c86:	6590                	ld	a2,8(a1)
ffffffffc0203c88:	0105b803          	ld	a6,16(a1) # 80010 <_binary_bin_sfs_img_size+0xad10>
ffffffffc0203c8c:	1141                	addi	sp,sp,-16
ffffffffc0203c8e:	e406                	sd	ra,8(sp)
ffffffffc0203c90:	87aa                	mv	a5,a0
ffffffffc0203c92:	01066763          	bltu	a2,a6,ffffffffc0203ca0 <insert_vma_struct+0x1a>
ffffffffc0203c96:	a085                	j	ffffffffc0203cf6 <insert_vma_struct+0x70>
ffffffffc0203c98:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203c9c:	04e66863          	bltu	a2,a4,ffffffffc0203cec <insert_vma_struct+0x66>
ffffffffc0203ca0:	86be                	mv	a3,a5
ffffffffc0203ca2:	679c                	ld	a5,8(a5)
ffffffffc0203ca4:	fef51ae3          	bne	a0,a5,ffffffffc0203c98 <insert_vma_struct+0x12>
ffffffffc0203ca8:	02a68463          	beq	a3,a0,ffffffffc0203cd0 <insert_vma_struct+0x4a>
ffffffffc0203cac:	ff06b703          	ld	a4,-16(a3)
ffffffffc0203cb0:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203cb4:	08e8f163          	bgeu	a7,a4,ffffffffc0203d36 <insert_vma_struct+0xb0>
ffffffffc0203cb8:	04e66f63          	bltu	a2,a4,ffffffffc0203d16 <insert_vma_struct+0x90>
ffffffffc0203cbc:	00f50a63          	beq	a0,a5,ffffffffc0203cd0 <insert_vma_struct+0x4a>
ffffffffc0203cc0:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203cc4:	05076963          	bltu	a4,a6,ffffffffc0203d16 <insert_vma_struct+0x90>
ffffffffc0203cc8:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203ccc:	02c77363          	bgeu	a4,a2,ffffffffc0203cf2 <insert_vma_struct+0x6c>
ffffffffc0203cd0:	5118                	lw	a4,32(a0)
ffffffffc0203cd2:	e188                	sd	a0,0(a1)
ffffffffc0203cd4:	02058613          	addi	a2,a1,32
ffffffffc0203cd8:	e390                	sd	a2,0(a5)
ffffffffc0203cda:	e690                	sd	a2,8(a3)
ffffffffc0203cdc:	60a2                	ld	ra,8(sp)
ffffffffc0203cde:	f59c                	sd	a5,40(a1)
ffffffffc0203ce0:	f194                	sd	a3,32(a1)
ffffffffc0203ce2:	0017079b          	addiw	a5,a4,1
ffffffffc0203ce6:	d11c                	sw	a5,32(a0)
ffffffffc0203ce8:	0141                	addi	sp,sp,16
ffffffffc0203cea:	8082                	ret
ffffffffc0203cec:	fca690e3          	bne	a3,a0,ffffffffc0203cac <insert_vma_struct+0x26>
ffffffffc0203cf0:	bfd1                	j	ffffffffc0203cc4 <insert_vma_struct+0x3e>
ffffffffc0203cf2:	ef3ff0ef          	jal	ra,ffffffffc0203be4 <check_vma_overlap.part.0>
ffffffffc0203cf6:	00009697          	auipc	a3,0x9
ffffffffc0203cfa:	52a68693          	addi	a3,a3,1322 # ffffffffc020d220 <default_pmm_manager+0x850>
ffffffffc0203cfe:	00008617          	auipc	a2,0x8
ffffffffc0203d02:	1ea60613          	addi	a2,a2,490 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203d06:	07a00593          	li	a1,122
ffffffffc0203d0a:	00009517          	auipc	a0,0x9
ffffffffc0203d0e:	50650513          	addi	a0,a0,1286 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc0203d12:	f8cfc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203d16:	00009697          	auipc	a3,0x9
ffffffffc0203d1a:	54a68693          	addi	a3,a3,1354 # ffffffffc020d260 <default_pmm_manager+0x890>
ffffffffc0203d1e:	00008617          	auipc	a2,0x8
ffffffffc0203d22:	1ca60613          	addi	a2,a2,458 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203d26:	07300593          	li	a1,115
ffffffffc0203d2a:	00009517          	auipc	a0,0x9
ffffffffc0203d2e:	4e650513          	addi	a0,a0,1254 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc0203d32:	f6cfc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203d36:	00009697          	auipc	a3,0x9
ffffffffc0203d3a:	50a68693          	addi	a3,a3,1290 # ffffffffc020d240 <default_pmm_manager+0x870>
ffffffffc0203d3e:	00008617          	auipc	a2,0x8
ffffffffc0203d42:	1aa60613          	addi	a2,a2,426 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203d46:	07200593          	li	a1,114
ffffffffc0203d4a:	00009517          	auipc	a0,0x9
ffffffffc0203d4e:	4c650513          	addi	a0,a0,1222 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc0203d52:	f4cfc0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0203d56 <mm_destroy>:
ffffffffc0203d56:	591c                	lw	a5,48(a0)
ffffffffc0203d58:	1141                	addi	sp,sp,-16
ffffffffc0203d5a:	e406                	sd	ra,8(sp)
ffffffffc0203d5c:	e022                	sd	s0,0(sp)
ffffffffc0203d5e:	e78d                	bnez	a5,ffffffffc0203d88 <mm_destroy+0x32>
ffffffffc0203d60:	842a                	mv	s0,a0
ffffffffc0203d62:	6508                	ld	a0,8(a0)
ffffffffc0203d64:	00a40c63          	beq	s0,a0,ffffffffc0203d7c <mm_destroy+0x26>
ffffffffc0203d68:	6118                	ld	a4,0(a0)
ffffffffc0203d6a:	651c                	ld	a5,8(a0)
ffffffffc0203d6c:	1501                	addi	a0,a0,-32
ffffffffc0203d6e:	e71c                	sd	a5,8(a4)
ffffffffc0203d70:	e398                	sd	a4,0(a5)
ffffffffc0203d72:	accfe0ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc0203d76:	6408                	ld	a0,8(s0)
ffffffffc0203d78:	fea418e3          	bne	s0,a0,ffffffffc0203d68 <mm_destroy+0x12>
ffffffffc0203d7c:	8522                	mv	a0,s0
ffffffffc0203d7e:	6402                	ld	s0,0(sp)
ffffffffc0203d80:	60a2                	ld	ra,8(sp)
ffffffffc0203d82:	0141                	addi	sp,sp,16
ffffffffc0203d84:	abafe06f          	j	ffffffffc020203e <kfree>
ffffffffc0203d88:	00009697          	auipc	a3,0x9
ffffffffc0203d8c:	4f868693          	addi	a3,a3,1272 # ffffffffc020d280 <default_pmm_manager+0x8b0>
ffffffffc0203d90:	00008617          	auipc	a2,0x8
ffffffffc0203d94:	15860613          	addi	a2,a2,344 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203d98:	09e00593          	li	a1,158
ffffffffc0203d9c:	00009517          	auipc	a0,0x9
ffffffffc0203da0:	47450513          	addi	a0,a0,1140 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc0203da4:	efafc0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0203da8 <mm_map>:
ffffffffc0203da8:	7139                	addi	sp,sp,-64
ffffffffc0203daa:	f822                	sd	s0,48(sp)
ffffffffc0203dac:	6405                	lui	s0,0x1
ffffffffc0203dae:	147d                	addi	s0,s0,-1
ffffffffc0203db0:	77fd                	lui	a5,0xfffff
ffffffffc0203db2:	9622                	add	a2,a2,s0
ffffffffc0203db4:	962e                	add	a2,a2,a1
ffffffffc0203db6:	f426                	sd	s1,40(sp)
ffffffffc0203db8:	fc06                	sd	ra,56(sp)
ffffffffc0203dba:	00f5f4b3          	and	s1,a1,a5
ffffffffc0203dbe:	f04a                	sd	s2,32(sp)
ffffffffc0203dc0:	ec4e                	sd	s3,24(sp)
ffffffffc0203dc2:	e852                	sd	s4,16(sp)
ffffffffc0203dc4:	e456                	sd	s5,8(sp)
ffffffffc0203dc6:	002005b7          	lui	a1,0x200
ffffffffc0203dca:	00f67433          	and	s0,a2,a5
ffffffffc0203dce:	06b4e363          	bltu	s1,a1,ffffffffc0203e34 <mm_map+0x8c>
ffffffffc0203dd2:	0684f163          	bgeu	s1,s0,ffffffffc0203e34 <mm_map+0x8c>
ffffffffc0203dd6:	4785                	li	a5,1
ffffffffc0203dd8:	07fe                	slli	a5,a5,0x1f
ffffffffc0203dda:	0487ed63          	bltu	a5,s0,ffffffffc0203e34 <mm_map+0x8c>
ffffffffc0203dde:	89aa                	mv	s3,a0
ffffffffc0203de0:	cd21                	beqz	a0,ffffffffc0203e38 <mm_map+0x90>
ffffffffc0203de2:	85a6                	mv	a1,s1
ffffffffc0203de4:	8ab6                	mv	s5,a3
ffffffffc0203de6:	8a3a                	mv	s4,a4
ffffffffc0203de8:	e5fff0ef          	jal	ra,ffffffffc0203c46 <find_vma>
ffffffffc0203dec:	c501                	beqz	a0,ffffffffc0203df4 <mm_map+0x4c>
ffffffffc0203dee:	651c                	ld	a5,8(a0)
ffffffffc0203df0:	0487e263          	bltu	a5,s0,ffffffffc0203e34 <mm_map+0x8c>
ffffffffc0203df4:	03000513          	li	a0,48
ffffffffc0203df8:	996fe0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc0203dfc:	892a                	mv	s2,a0
ffffffffc0203dfe:	5571                	li	a0,-4
ffffffffc0203e00:	02090163          	beqz	s2,ffffffffc0203e22 <mm_map+0x7a>
ffffffffc0203e04:	854e                	mv	a0,s3
ffffffffc0203e06:	00993423          	sd	s1,8(s2)
ffffffffc0203e0a:	00893823          	sd	s0,16(s2)
ffffffffc0203e0e:	01592c23          	sw	s5,24(s2)
ffffffffc0203e12:	85ca                	mv	a1,s2
ffffffffc0203e14:	e73ff0ef          	jal	ra,ffffffffc0203c86 <insert_vma_struct>
ffffffffc0203e18:	4501                	li	a0,0
ffffffffc0203e1a:	000a0463          	beqz	s4,ffffffffc0203e22 <mm_map+0x7a>
ffffffffc0203e1e:	012a3023          	sd	s2,0(s4) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc0203e22:	70e2                	ld	ra,56(sp)
ffffffffc0203e24:	7442                	ld	s0,48(sp)
ffffffffc0203e26:	74a2                	ld	s1,40(sp)
ffffffffc0203e28:	7902                	ld	s2,32(sp)
ffffffffc0203e2a:	69e2                	ld	s3,24(sp)
ffffffffc0203e2c:	6a42                	ld	s4,16(sp)
ffffffffc0203e2e:	6aa2                	ld	s5,8(sp)
ffffffffc0203e30:	6121                	addi	sp,sp,64
ffffffffc0203e32:	8082                	ret
ffffffffc0203e34:	5575                	li	a0,-3
ffffffffc0203e36:	b7f5                	j	ffffffffc0203e22 <mm_map+0x7a>
ffffffffc0203e38:	00009697          	auipc	a3,0x9
ffffffffc0203e3c:	46068693          	addi	a3,a3,1120 # ffffffffc020d298 <default_pmm_manager+0x8c8>
ffffffffc0203e40:	00008617          	auipc	a2,0x8
ffffffffc0203e44:	0a860613          	addi	a2,a2,168 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203e48:	0b300593          	li	a1,179
ffffffffc0203e4c:	00009517          	auipc	a0,0x9
ffffffffc0203e50:	3c450513          	addi	a0,a0,964 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc0203e54:	e4afc0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0203e58 <dup_mmap>:
ffffffffc0203e58:	7139                	addi	sp,sp,-64
ffffffffc0203e5a:	fc06                	sd	ra,56(sp)
ffffffffc0203e5c:	f822                	sd	s0,48(sp)
ffffffffc0203e5e:	f426                	sd	s1,40(sp)
ffffffffc0203e60:	f04a                	sd	s2,32(sp)
ffffffffc0203e62:	ec4e                	sd	s3,24(sp)
ffffffffc0203e64:	e852                	sd	s4,16(sp)
ffffffffc0203e66:	e456                	sd	s5,8(sp)
ffffffffc0203e68:	c52d                	beqz	a0,ffffffffc0203ed2 <dup_mmap+0x7a>
ffffffffc0203e6a:	892a                	mv	s2,a0
ffffffffc0203e6c:	84ae                	mv	s1,a1
ffffffffc0203e6e:	842e                	mv	s0,a1
ffffffffc0203e70:	e595                	bnez	a1,ffffffffc0203e9c <dup_mmap+0x44>
ffffffffc0203e72:	a085                	j	ffffffffc0203ed2 <dup_mmap+0x7a>
ffffffffc0203e74:	854a                	mv	a0,s2
ffffffffc0203e76:	0155b423          	sd	s5,8(a1) # 200008 <_binary_bin_sfs_img_size+0x18ad08>
ffffffffc0203e7a:	0145b823          	sd	s4,16(a1)
ffffffffc0203e7e:	0135ac23          	sw	s3,24(a1)
ffffffffc0203e82:	e05ff0ef          	jal	ra,ffffffffc0203c86 <insert_vma_struct>
ffffffffc0203e86:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_bin_swap_img_size-0x6d10>
ffffffffc0203e8a:	fe843603          	ld	a2,-24(s0)
ffffffffc0203e8e:	6c8c                	ld	a1,24(s1)
ffffffffc0203e90:	01893503          	ld	a0,24(s2)
ffffffffc0203e94:	4701                	li	a4,0
ffffffffc0203e96:	a2dff0ef          	jal	ra,ffffffffc02038c2 <copy_range>
ffffffffc0203e9a:	e105                	bnez	a0,ffffffffc0203eba <dup_mmap+0x62>
ffffffffc0203e9c:	6000                	ld	s0,0(s0)
ffffffffc0203e9e:	02848863          	beq	s1,s0,ffffffffc0203ece <dup_mmap+0x76>
ffffffffc0203ea2:	03000513          	li	a0,48
ffffffffc0203ea6:	fe843a83          	ld	s5,-24(s0)
ffffffffc0203eaa:	ff043a03          	ld	s4,-16(s0)
ffffffffc0203eae:	ff842983          	lw	s3,-8(s0)
ffffffffc0203eb2:	8dcfe0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc0203eb6:	85aa                	mv	a1,a0
ffffffffc0203eb8:	fd55                	bnez	a0,ffffffffc0203e74 <dup_mmap+0x1c>
ffffffffc0203eba:	5571                	li	a0,-4
ffffffffc0203ebc:	70e2                	ld	ra,56(sp)
ffffffffc0203ebe:	7442                	ld	s0,48(sp)
ffffffffc0203ec0:	74a2                	ld	s1,40(sp)
ffffffffc0203ec2:	7902                	ld	s2,32(sp)
ffffffffc0203ec4:	69e2                	ld	s3,24(sp)
ffffffffc0203ec6:	6a42                	ld	s4,16(sp)
ffffffffc0203ec8:	6aa2                	ld	s5,8(sp)
ffffffffc0203eca:	6121                	addi	sp,sp,64
ffffffffc0203ecc:	8082                	ret
ffffffffc0203ece:	4501                	li	a0,0
ffffffffc0203ed0:	b7f5                	j	ffffffffc0203ebc <dup_mmap+0x64>
ffffffffc0203ed2:	00009697          	auipc	a3,0x9
ffffffffc0203ed6:	3d668693          	addi	a3,a3,982 # ffffffffc020d2a8 <default_pmm_manager+0x8d8>
ffffffffc0203eda:	00008617          	auipc	a2,0x8
ffffffffc0203ede:	00e60613          	addi	a2,a2,14 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203ee2:	0cf00593          	li	a1,207
ffffffffc0203ee6:	00009517          	auipc	a0,0x9
ffffffffc0203eea:	32a50513          	addi	a0,a0,810 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc0203eee:	db0fc0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0203ef2 <exit_mmap>:
ffffffffc0203ef2:	1101                	addi	sp,sp,-32
ffffffffc0203ef4:	ec06                	sd	ra,24(sp)
ffffffffc0203ef6:	e822                	sd	s0,16(sp)
ffffffffc0203ef8:	e426                	sd	s1,8(sp)
ffffffffc0203efa:	e04a                	sd	s2,0(sp)
ffffffffc0203efc:	c531                	beqz	a0,ffffffffc0203f48 <exit_mmap+0x56>
ffffffffc0203efe:	591c                	lw	a5,48(a0)
ffffffffc0203f00:	84aa                	mv	s1,a0
ffffffffc0203f02:	e3b9                	bnez	a5,ffffffffc0203f48 <exit_mmap+0x56>
ffffffffc0203f04:	6500                	ld	s0,8(a0)
ffffffffc0203f06:	01853903          	ld	s2,24(a0)
ffffffffc0203f0a:	02850663          	beq	a0,s0,ffffffffc0203f36 <exit_mmap+0x44>
ffffffffc0203f0e:	ff043603          	ld	a2,-16(s0)
ffffffffc0203f12:	fe843583          	ld	a1,-24(s0)
ffffffffc0203f16:	854a                	mv	a0,s2
ffffffffc0203f18:	e4efe0ef          	jal	ra,ffffffffc0202566 <unmap_range>
ffffffffc0203f1c:	6400                	ld	s0,8(s0)
ffffffffc0203f1e:	fe8498e3          	bne	s1,s0,ffffffffc0203f0e <exit_mmap+0x1c>
ffffffffc0203f22:	6400                	ld	s0,8(s0)
ffffffffc0203f24:	00848c63          	beq	s1,s0,ffffffffc0203f3c <exit_mmap+0x4a>
ffffffffc0203f28:	ff043603          	ld	a2,-16(s0)
ffffffffc0203f2c:	fe843583          	ld	a1,-24(s0)
ffffffffc0203f30:	854a                	mv	a0,s2
ffffffffc0203f32:	f7afe0ef          	jal	ra,ffffffffc02026ac <exit_range>
ffffffffc0203f36:	6400                	ld	s0,8(s0)
ffffffffc0203f38:	fe8498e3          	bne	s1,s0,ffffffffc0203f28 <exit_mmap+0x36>
ffffffffc0203f3c:	60e2                	ld	ra,24(sp)
ffffffffc0203f3e:	6442                	ld	s0,16(sp)
ffffffffc0203f40:	64a2                	ld	s1,8(sp)
ffffffffc0203f42:	6902                	ld	s2,0(sp)
ffffffffc0203f44:	6105                	addi	sp,sp,32
ffffffffc0203f46:	8082                	ret
ffffffffc0203f48:	00009697          	auipc	a3,0x9
ffffffffc0203f4c:	38068693          	addi	a3,a3,896 # ffffffffc020d2c8 <default_pmm_manager+0x8f8>
ffffffffc0203f50:	00008617          	auipc	a2,0x8
ffffffffc0203f54:	f9860613          	addi	a2,a2,-104 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203f58:	0e800593          	li	a1,232
ffffffffc0203f5c:	00009517          	auipc	a0,0x9
ffffffffc0203f60:	2b450513          	addi	a0,a0,692 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc0203f64:	d3afc0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0203f68 <vmm_init>:
ffffffffc0203f68:	7139                	addi	sp,sp,-64
ffffffffc0203f6a:	05800513          	li	a0,88
ffffffffc0203f6e:	fc06                	sd	ra,56(sp)
ffffffffc0203f70:	f822                	sd	s0,48(sp)
ffffffffc0203f72:	f426                	sd	s1,40(sp)
ffffffffc0203f74:	f04a                	sd	s2,32(sp)
ffffffffc0203f76:	ec4e                	sd	s3,24(sp)
ffffffffc0203f78:	e852                	sd	s4,16(sp)
ffffffffc0203f7a:	e456                	sd	s5,8(sp)
ffffffffc0203f7c:	812fe0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc0203f80:	2e050963          	beqz	a0,ffffffffc0204272 <vmm_init+0x30a>
ffffffffc0203f84:	e508                	sd	a0,8(a0)
ffffffffc0203f86:	e108                	sd	a0,0(a0)
ffffffffc0203f88:	00053823          	sd	zero,16(a0)
ffffffffc0203f8c:	00053c23          	sd	zero,24(a0)
ffffffffc0203f90:	02052023          	sw	zero,32(a0)
ffffffffc0203f94:	02053423          	sd	zero,40(a0)
ffffffffc0203f98:	02052823          	sw	zero,48(a0)
ffffffffc0203f9c:	84aa                	mv	s1,a0
ffffffffc0203f9e:	4585                	li	a1,1
ffffffffc0203fa0:	03850513          	addi	a0,a0,56
ffffffffc0203fa4:	5b6000ef          	jal	ra,ffffffffc020455a <sem_init>
ffffffffc0203fa8:	03200413          	li	s0,50
ffffffffc0203fac:	a811                	j	ffffffffc0203fc0 <vmm_init+0x58>
ffffffffc0203fae:	e500                	sd	s0,8(a0)
ffffffffc0203fb0:	e91c                	sd	a5,16(a0)
ffffffffc0203fb2:	00052c23          	sw	zero,24(a0)
ffffffffc0203fb6:	146d                	addi	s0,s0,-5
ffffffffc0203fb8:	8526                	mv	a0,s1
ffffffffc0203fba:	ccdff0ef          	jal	ra,ffffffffc0203c86 <insert_vma_struct>
ffffffffc0203fbe:	c80d                	beqz	s0,ffffffffc0203ff0 <vmm_init+0x88>
ffffffffc0203fc0:	03000513          	li	a0,48
ffffffffc0203fc4:	fcbfd0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc0203fc8:	85aa                	mv	a1,a0
ffffffffc0203fca:	00240793          	addi	a5,s0,2
ffffffffc0203fce:	f165                	bnez	a0,ffffffffc0203fae <vmm_init+0x46>
ffffffffc0203fd0:	00009697          	auipc	a3,0x9
ffffffffc0203fd4:	49068693          	addi	a3,a3,1168 # ffffffffc020d460 <default_pmm_manager+0xa90>
ffffffffc0203fd8:	00008617          	auipc	a2,0x8
ffffffffc0203fdc:	f1060613          	addi	a2,a2,-240 # ffffffffc020bee8 <commands+0x210>
ffffffffc0203fe0:	12c00593          	li	a1,300
ffffffffc0203fe4:	00009517          	auipc	a0,0x9
ffffffffc0203fe8:	22c50513          	addi	a0,a0,556 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc0203fec:	cb2fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0203ff0:	03700413          	li	s0,55
ffffffffc0203ff4:	1f900913          	li	s2,505
ffffffffc0203ff8:	a819                	j	ffffffffc020400e <vmm_init+0xa6>
ffffffffc0203ffa:	e500                	sd	s0,8(a0)
ffffffffc0203ffc:	e91c                	sd	a5,16(a0)
ffffffffc0203ffe:	00052c23          	sw	zero,24(a0)
ffffffffc0204002:	0415                	addi	s0,s0,5
ffffffffc0204004:	8526                	mv	a0,s1
ffffffffc0204006:	c81ff0ef          	jal	ra,ffffffffc0203c86 <insert_vma_struct>
ffffffffc020400a:	03240a63          	beq	s0,s2,ffffffffc020403e <vmm_init+0xd6>
ffffffffc020400e:	03000513          	li	a0,48
ffffffffc0204012:	f7dfd0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc0204016:	85aa                	mv	a1,a0
ffffffffc0204018:	00240793          	addi	a5,s0,2
ffffffffc020401c:	fd79                	bnez	a0,ffffffffc0203ffa <vmm_init+0x92>
ffffffffc020401e:	00009697          	auipc	a3,0x9
ffffffffc0204022:	44268693          	addi	a3,a3,1090 # ffffffffc020d460 <default_pmm_manager+0xa90>
ffffffffc0204026:	00008617          	auipc	a2,0x8
ffffffffc020402a:	ec260613          	addi	a2,a2,-318 # ffffffffc020bee8 <commands+0x210>
ffffffffc020402e:	13300593          	li	a1,307
ffffffffc0204032:	00009517          	auipc	a0,0x9
ffffffffc0204036:	1de50513          	addi	a0,a0,478 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc020403a:	c64fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020403e:	649c                	ld	a5,8(s1)
ffffffffc0204040:	471d                	li	a4,7
ffffffffc0204042:	1fb00593          	li	a1,507
ffffffffc0204046:	16f48663          	beq	s1,a5,ffffffffc02041b2 <vmm_init+0x24a>
ffffffffc020404a:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd686d8>
ffffffffc020404e:	ffe70693          	addi	a3,a4,-2
ffffffffc0204052:	10d61063          	bne	a2,a3,ffffffffc0204152 <vmm_init+0x1ea>
ffffffffc0204056:	ff07b683          	ld	a3,-16(a5)
ffffffffc020405a:	0ed71c63          	bne	a4,a3,ffffffffc0204152 <vmm_init+0x1ea>
ffffffffc020405e:	0715                	addi	a4,a4,5
ffffffffc0204060:	679c                	ld	a5,8(a5)
ffffffffc0204062:	feb712e3          	bne	a4,a1,ffffffffc0204046 <vmm_init+0xde>
ffffffffc0204066:	4a1d                	li	s4,7
ffffffffc0204068:	4415                	li	s0,5
ffffffffc020406a:	1f900a93          	li	s5,505
ffffffffc020406e:	85a2                	mv	a1,s0
ffffffffc0204070:	8526                	mv	a0,s1
ffffffffc0204072:	bd5ff0ef          	jal	ra,ffffffffc0203c46 <find_vma>
ffffffffc0204076:	892a                	mv	s2,a0
ffffffffc0204078:	16050d63          	beqz	a0,ffffffffc02041f2 <vmm_init+0x28a>
ffffffffc020407c:	00140593          	addi	a1,s0,1
ffffffffc0204080:	8526                	mv	a0,s1
ffffffffc0204082:	bc5ff0ef          	jal	ra,ffffffffc0203c46 <find_vma>
ffffffffc0204086:	89aa                	mv	s3,a0
ffffffffc0204088:	14050563          	beqz	a0,ffffffffc02041d2 <vmm_init+0x26a>
ffffffffc020408c:	85d2                	mv	a1,s4
ffffffffc020408e:	8526                	mv	a0,s1
ffffffffc0204090:	bb7ff0ef          	jal	ra,ffffffffc0203c46 <find_vma>
ffffffffc0204094:	16051f63          	bnez	a0,ffffffffc0204212 <vmm_init+0x2aa>
ffffffffc0204098:	00340593          	addi	a1,s0,3
ffffffffc020409c:	8526                	mv	a0,s1
ffffffffc020409e:	ba9ff0ef          	jal	ra,ffffffffc0203c46 <find_vma>
ffffffffc02040a2:	1a051863          	bnez	a0,ffffffffc0204252 <vmm_init+0x2ea>
ffffffffc02040a6:	00440593          	addi	a1,s0,4
ffffffffc02040aa:	8526                	mv	a0,s1
ffffffffc02040ac:	b9bff0ef          	jal	ra,ffffffffc0203c46 <find_vma>
ffffffffc02040b0:	18051163          	bnez	a0,ffffffffc0204232 <vmm_init+0x2ca>
ffffffffc02040b4:	00893783          	ld	a5,8(s2)
ffffffffc02040b8:	0a879d63          	bne	a5,s0,ffffffffc0204172 <vmm_init+0x20a>
ffffffffc02040bc:	01093783          	ld	a5,16(s2)
ffffffffc02040c0:	0b479963          	bne	a5,s4,ffffffffc0204172 <vmm_init+0x20a>
ffffffffc02040c4:	0089b783          	ld	a5,8(s3)
ffffffffc02040c8:	0c879563          	bne	a5,s0,ffffffffc0204192 <vmm_init+0x22a>
ffffffffc02040cc:	0109b783          	ld	a5,16(s3)
ffffffffc02040d0:	0d479163          	bne	a5,s4,ffffffffc0204192 <vmm_init+0x22a>
ffffffffc02040d4:	0415                	addi	s0,s0,5
ffffffffc02040d6:	0a15                	addi	s4,s4,5
ffffffffc02040d8:	f9541be3          	bne	s0,s5,ffffffffc020406e <vmm_init+0x106>
ffffffffc02040dc:	4411                	li	s0,4
ffffffffc02040de:	597d                	li	s2,-1
ffffffffc02040e0:	85a2                	mv	a1,s0
ffffffffc02040e2:	8526                	mv	a0,s1
ffffffffc02040e4:	b63ff0ef          	jal	ra,ffffffffc0203c46 <find_vma>
ffffffffc02040e8:	0004059b          	sext.w	a1,s0
ffffffffc02040ec:	c90d                	beqz	a0,ffffffffc020411e <vmm_init+0x1b6>
ffffffffc02040ee:	6914                	ld	a3,16(a0)
ffffffffc02040f0:	6510                	ld	a2,8(a0)
ffffffffc02040f2:	00009517          	auipc	a0,0x9
ffffffffc02040f6:	2f650513          	addi	a0,a0,758 # ffffffffc020d3e8 <default_pmm_manager+0xa18>
ffffffffc02040fa:	8acfc0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc02040fe:	00009697          	auipc	a3,0x9
ffffffffc0204102:	31268693          	addi	a3,a3,786 # ffffffffc020d410 <default_pmm_manager+0xa40>
ffffffffc0204106:	00008617          	auipc	a2,0x8
ffffffffc020410a:	de260613          	addi	a2,a2,-542 # ffffffffc020bee8 <commands+0x210>
ffffffffc020410e:	15900593          	li	a1,345
ffffffffc0204112:	00009517          	auipc	a0,0x9
ffffffffc0204116:	0fe50513          	addi	a0,a0,254 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc020411a:	b84fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020411e:	147d                	addi	s0,s0,-1
ffffffffc0204120:	fd2410e3          	bne	s0,s2,ffffffffc02040e0 <vmm_init+0x178>
ffffffffc0204124:	8526                	mv	a0,s1
ffffffffc0204126:	c31ff0ef          	jal	ra,ffffffffc0203d56 <mm_destroy>
ffffffffc020412a:	00009517          	auipc	a0,0x9
ffffffffc020412e:	2fe50513          	addi	a0,a0,766 # ffffffffc020d428 <default_pmm_manager+0xa58>
ffffffffc0204132:	874fc0ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0204136:	7442                	ld	s0,48(sp)
ffffffffc0204138:	70e2                	ld	ra,56(sp)
ffffffffc020413a:	74a2                	ld	s1,40(sp)
ffffffffc020413c:	7902                	ld	s2,32(sp)
ffffffffc020413e:	69e2                	ld	s3,24(sp)
ffffffffc0204140:	6a42                	ld	s4,16(sp)
ffffffffc0204142:	6aa2                	ld	s5,8(sp)
ffffffffc0204144:	00009517          	auipc	a0,0x9
ffffffffc0204148:	30450513          	addi	a0,a0,772 # ffffffffc020d448 <default_pmm_manager+0xa78>
ffffffffc020414c:	6121                	addi	sp,sp,64
ffffffffc020414e:	858fc06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc0204152:	00009697          	auipc	a3,0x9
ffffffffc0204156:	1ae68693          	addi	a3,a3,430 # ffffffffc020d300 <default_pmm_manager+0x930>
ffffffffc020415a:	00008617          	auipc	a2,0x8
ffffffffc020415e:	d8e60613          	addi	a2,a2,-626 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204162:	13d00593          	li	a1,317
ffffffffc0204166:	00009517          	auipc	a0,0x9
ffffffffc020416a:	0aa50513          	addi	a0,a0,170 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc020416e:	b30fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0204172:	00009697          	auipc	a3,0x9
ffffffffc0204176:	21668693          	addi	a3,a3,534 # ffffffffc020d388 <default_pmm_manager+0x9b8>
ffffffffc020417a:	00008617          	auipc	a2,0x8
ffffffffc020417e:	d6e60613          	addi	a2,a2,-658 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204182:	14e00593          	li	a1,334
ffffffffc0204186:	00009517          	auipc	a0,0x9
ffffffffc020418a:	08a50513          	addi	a0,a0,138 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc020418e:	b10fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0204192:	00009697          	auipc	a3,0x9
ffffffffc0204196:	22668693          	addi	a3,a3,550 # ffffffffc020d3b8 <default_pmm_manager+0x9e8>
ffffffffc020419a:	00008617          	auipc	a2,0x8
ffffffffc020419e:	d4e60613          	addi	a2,a2,-690 # ffffffffc020bee8 <commands+0x210>
ffffffffc02041a2:	14f00593          	li	a1,335
ffffffffc02041a6:	00009517          	auipc	a0,0x9
ffffffffc02041aa:	06a50513          	addi	a0,a0,106 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc02041ae:	af0fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02041b2:	00009697          	auipc	a3,0x9
ffffffffc02041b6:	13668693          	addi	a3,a3,310 # ffffffffc020d2e8 <default_pmm_manager+0x918>
ffffffffc02041ba:	00008617          	auipc	a2,0x8
ffffffffc02041be:	d2e60613          	addi	a2,a2,-722 # ffffffffc020bee8 <commands+0x210>
ffffffffc02041c2:	13b00593          	li	a1,315
ffffffffc02041c6:	00009517          	auipc	a0,0x9
ffffffffc02041ca:	04a50513          	addi	a0,a0,74 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc02041ce:	ad0fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02041d2:	00009697          	auipc	a3,0x9
ffffffffc02041d6:	17668693          	addi	a3,a3,374 # ffffffffc020d348 <default_pmm_manager+0x978>
ffffffffc02041da:	00008617          	auipc	a2,0x8
ffffffffc02041de:	d0e60613          	addi	a2,a2,-754 # ffffffffc020bee8 <commands+0x210>
ffffffffc02041e2:	14600593          	li	a1,326
ffffffffc02041e6:	00009517          	auipc	a0,0x9
ffffffffc02041ea:	02a50513          	addi	a0,a0,42 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc02041ee:	ab0fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02041f2:	00009697          	auipc	a3,0x9
ffffffffc02041f6:	14668693          	addi	a3,a3,326 # ffffffffc020d338 <default_pmm_manager+0x968>
ffffffffc02041fa:	00008617          	auipc	a2,0x8
ffffffffc02041fe:	cee60613          	addi	a2,a2,-786 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204202:	14400593          	li	a1,324
ffffffffc0204206:	00009517          	auipc	a0,0x9
ffffffffc020420a:	00a50513          	addi	a0,a0,10 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc020420e:	a90fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0204212:	00009697          	auipc	a3,0x9
ffffffffc0204216:	14668693          	addi	a3,a3,326 # ffffffffc020d358 <default_pmm_manager+0x988>
ffffffffc020421a:	00008617          	auipc	a2,0x8
ffffffffc020421e:	cce60613          	addi	a2,a2,-818 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204222:	14800593          	li	a1,328
ffffffffc0204226:	00009517          	auipc	a0,0x9
ffffffffc020422a:	fea50513          	addi	a0,a0,-22 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc020422e:	a70fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0204232:	00009697          	auipc	a3,0x9
ffffffffc0204236:	14668693          	addi	a3,a3,326 # ffffffffc020d378 <default_pmm_manager+0x9a8>
ffffffffc020423a:	00008617          	auipc	a2,0x8
ffffffffc020423e:	cae60613          	addi	a2,a2,-850 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204242:	14c00593          	li	a1,332
ffffffffc0204246:	00009517          	auipc	a0,0x9
ffffffffc020424a:	fca50513          	addi	a0,a0,-54 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc020424e:	a50fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0204252:	00009697          	auipc	a3,0x9
ffffffffc0204256:	11668693          	addi	a3,a3,278 # ffffffffc020d368 <default_pmm_manager+0x998>
ffffffffc020425a:	00008617          	auipc	a2,0x8
ffffffffc020425e:	c8e60613          	addi	a2,a2,-882 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204262:	14a00593          	li	a1,330
ffffffffc0204266:	00009517          	auipc	a0,0x9
ffffffffc020426a:	faa50513          	addi	a0,a0,-86 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc020426e:	a30fc0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0204272:	00009697          	auipc	a3,0x9
ffffffffc0204276:	02668693          	addi	a3,a3,38 # ffffffffc020d298 <default_pmm_manager+0x8c8>
ffffffffc020427a:	00008617          	auipc	a2,0x8
ffffffffc020427e:	c6e60613          	addi	a2,a2,-914 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204282:	12400593          	li	a1,292
ffffffffc0204286:	00009517          	auipc	a0,0x9
ffffffffc020428a:	f8a50513          	addi	a0,a0,-118 # ffffffffc020d210 <default_pmm_manager+0x840>
ffffffffc020428e:	a10fc0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0204292 <user_mem_check>:
ffffffffc0204292:	7179                	addi	sp,sp,-48
ffffffffc0204294:	f022                	sd	s0,32(sp)
ffffffffc0204296:	f406                	sd	ra,40(sp)
ffffffffc0204298:	ec26                	sd	s1,24(sp)
ffffffffc020429a:	e84a                	sd	s2,16(sp)
ffffffffc020429c:	e44e                	sd	s3,8(sp)
ffffffffc020429e:	e052                	sd	s4,0(sp)
ffffffffc02042a0:	842e                	mv	s0,a1
ffffffffc02042a2:	c135                	beqz	a0,ffffffffc0204306 <user_mem_check+0x74>
ffffffffc02042a4:	002007b7          	lui	a5,0x200
ffffffffc02042a8:	04f5e663          	bltu	a1,a5,ffffffffc02042f4 <user_mem_check+0x62>
ffffffffc02042ac:	00c584b3          	add	s1,a1,a2
ffffffffc02042b0:	0495f263          	bgeu	a1,s1,ffffffffc02042f4 <user_mem_check+0x62>
ffffffffc02042b4:	4785                	li	a5,1
ffffffffc02042b6:	07fe                	slli	a5,a5,0x1f
ffffffffc02042b8:	0297ee63          	bltu	a5,s1,ffffffffc02042f4 <user_mem_check+0x62>
ffffffffc02042bc:	892a                	mv	s2,a0
ffffffffc02042be:	89b6                	mv	s3,a3
ffffffffc02042c0:	6a05                	lui	s4,0x1
ffffffffc02042c2:	a821                	j	ffffffffc02042da <user_mem_check+0x48>
ffffffffc02042c4:	0027f693          	andi	a3,a5,2
ffffffffc02042c8:	9752                	add	a4,a4,s4
ffffffffc02042ca:	8ba1                	andi	a5,a5,8
ffffffffc02042cc:	c685                	beqz	a3,ffffffffc02042f4 <user_mem_check+0x62>
ffffffffc02042ce:	c399                	beqz	a5,ffffffffc02042d4 <user_mem_check+0x42>
ffffffffc02042d0:	02e46263          	bltu	s0,a4,ffffffffc02042f4 <user_mem_check+0x62>
ffffffffc02042d4:	6900                	ld	s0,16(a0)
ffffffffc02042d6:	04947663          	bgeu	s0,s1,ffffffffc0204322 <user_mem_check+0x90>
ffffffffc02042da:	85a2                	mv	a1,s0
ffffffffc02042dc:	854a                	mv	a0,s2
ffffffffc02042de:	969ff0ef          	jal	ra,ffffffffc0203c46 <find_vma>
ffffffffc02042e2:	c909                	beqz	a0,ffffffffc02042f4 <user_mem_check+0x62>
ffffffffc02042e4:	6518                	ld	a4,8(a0)
ffffffffc02042e6:	00e46763          	bltu	s0,a4,ffffffffc02042f4 <user_mem_check+0x62>
ffffffffc02042ea:	4d1c                	lw	a5,24(a0)
ffffffffc02042ec:	fc099ce3          	bnez	s3,ffffffffc02042c4 <user_mem_check+0x32>
ffffffffc02042f0:	8b85                	andi	a5,a5,1
ffffffffc02042f2:	f3ed                	bnez	a5,ffffffffc02042d4 <user_mem_check+0x42>
ffffffffc02042f4:	4501                	li	a0,0
ffffffffc02042f6:	70a2                	ld	ra,40(sp)
ffffffffc02042f8:	7402                	ld	s0,32(sp)
ffffffffc02042fa:	64e2                	ld	s1,24(sp)
ffffffffc02042fc:	6942                	ld	s2,16(sp)
ffffffffc02042fe:	69a2                	ld	s3,8(sp)
ffffffffc0204300:	6a02                	ld	s4,0(sp)
ffffffffc0204302:	6145                	addi	sp,sp,48
ffffffffc0204304:	8082                	ret
ffffffffc0204306:	c02007b7          	lui	a5,0xc0200
ffffffffc020430a:	4501                	li	a0,0
ffffffffc020430c:	fef5e5e3          	bltu	a1,a5,ffffffffc02042f6 <user_mem_check+0x64>
ffffffffc0204310:	962e                	add	a2,a2,a1
ffffffffc0204312:	fec5f2e3          	bgeu	a1,a2,ffffffffc02042f6 <user_mem_check+0x64>
ffffffffc0204316:	c8000537          	lui	a0,0xc8000
ffffffffc020431a:	0505                	addi	a0,a0,1
ffffffffc020431c:	00a63533          	sltu	a0,a2,a0
ffffffffc0204320:	bfd9                	j	ffffffffc02042f6 <user_mem_check+0x64>
ffffffffc0204322:	4505                	li	a0,1
ffffffffc0204324:	bfc9                	j	ffffffffc02042f6 <user_mem_check+0x64>

ffffffffc0204326 <copy_from_user>:
ffffffffc0204326:	1101                	addi	sp,sp,-32
ffffffffc0204328:	e822                	sd	s0,16(sp)
ffffffffc020432a:	e426                	sd	s1,8(sp)
ffffffffc020432c:	8432                	mv	s0,a2
ffffffffc020432e:	84b6                	mv	s1,a3
ffffffffc0204330:	e04a                	sd	s2,0(sp)
ffffffffc0204332:	86ba                	mv	a3,a4
ffffffffc0204334:	892e                	mv	s2,a1
ffffffffc0204336:	8626                	mv	a2,s1
ffffffffc0204338:	85a2                	mv	a1,s0
ffffffffc020433a:	ec06                	sd	ra,24(sp)
ffffffffc020433c:	f57ff0ef          	jal	ra,ffffffffc0204292 <user_mem_check>
ffffffffc0204340:	c519                	beqz	a0,ffffffffc020434e <copy_from_user+0x28>
ffffffffc0204342:	8626                	mv	a2,s1
ffffffffc0204344:	85a2                	mv	a1,s0
ffffffffc0204346:	854a                	mv	a0,s2
ffffffffc0204348:	70e070ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc020434c:	4505                	li	a0,1
ffffffffc020434e:	60e2                	ld	ra,24(sp)
ffffffffc0204350:	6442                	ld	s0,16(sp)
ffffffffc0204352:	64a2                	ld	s1,8(sp)
ffffffffc0204354:	6902                	ld	s2,0(sp)
ffffffffc0204356:	6105                	addi	sp,sp,32
ffffffffc0204358:	8082                	ret

ffffffffc020435a <copy_to_user>:
ffffffffc020435a:	1101                	addi	sp,sp,-32
ffffffffc020435c:	e822                	sd	s0,16(sp)
ffffffffc020435e:	8436                	mv	s0,a3
ffffffffc0204360:	e04a                	sd	s2,0(sp)
ffffffffc0204362:	4685                	li	a3,1
ffffffffc0204364:	8932                	mv	s2,a2
ffffffffc0204366:	8622                	mv	a2,s0
ffffffffc0204368:	e426                	sd	s1,8(sp)
ffffffffc020436a:	ec06                	sd	ra,24(sp)
ffffffffc020436c:	84ae                	mv	s1,a1
ffffffffc020436e:	f25ff0ef          	jal	ra,ffffffffc0204292 <user_mem_check>
ffffffffc0204372:	c519                	beqz	a0,ffffffffc0204380 <copy_to_user+0x26>
ffffffffc0204374:	8622                	mv	a2,s0
ffffffffc0204376:	85ca                	mv	a1,s2
ffffffffc0204378:	8526                	mv	a0,s1
ffffffffc020437a:	6dc070ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc020437e:	4505                	li	a0,1
ffffffffc0204380:	60e2                	ld	ra,24(sp)
ffffffffc0204382:	6442                	ld	s0,16(sp)
ffffffffc0204384:	64a2                	ld	s1,8(sp)
ffffffffc0204386:	6902                	ld	s2,0(sp)
ffffffffc0204388:	6105                	addi	sp,sp,32
ffffffffc020438a:	8082                	ret

ffffffffc020438c <copy_string>:
ffffffffc020438c:	7139                	addi	sp,sp,-64
ffffffffc020438e:	ec4e                	sd	s3,24(sp)
ffffffffc0204390:	6985                	lui	s3,0x1
ffffffffc0204392:	99b2                	add	s3,s3,a2
ffffffffc0204394:	77fd                	lui	a5,0xfffff
ffffffffc0204396:	00f9f9b3          	and	s3,s3,a5
ffffffffc020439a:	f426                	sd	s1,40(sp)
ffffffffc020439c:	f04a                	sd	s2,32(sp)
ffffffffc020439e:	e852                	sd	s4,16(sp)
ffffffffc02043a0:	e456                	sd	s5,8(sp)
ffffffffc02043a2:	fc06                	sd	ra,56(sp)
ffffffffc02043a4:	f822                	sd	s0,48(sp)
ffffffffc02043a6:	84b2                	mv	s1,a2
ffffffffc02043a8:	8aaa                	mv	s5,a0
ffffffffc02043aa:	8a2e                	mv	s4,a1
ffffffffc02043ac:	8936                	mv	s2,a3
ffffffffc02043ae:	40c989b3          	sub	s3,s3,a2
ffffffffc02043b2:	a015                	j	ffffffffc02043d6 <copy_string+0x4a>
ffffffffc02043b4:	5a0070ef          	jal	ra,ffffffffc020b954 <strnlen>
ffffffffc02043b8:	87aa                	mv	a5,a0
ffffffffc02043ba:	85a6                	mv	a1,s1
ffffffffc02043bc:	8552                	mv	a0,s4
ffffffffc02043be:	8622                	mv	a2,s0
ffffffffc02043c0:	0487e363          	bltu	a5,s0,ffffffffc0204406 <copy_string+0x7a>
ffffffffc02043c4:	0329f763          	bgeu	s3,s2,ffffffffc02043f2 <copy_string+0x66>
ffffffffc02043c8:	68e070ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc02043cc:	9a22                	add	s4,s4,s0
ffffffffc02043ce:	94a2                	add	s1,s1,s0
ffffffffc02043d0:	40890933          	sub	s2,s2,s0
ffffffffc02043d4:	6985                	lui	s3,0x1
ffffffffc02043d6:	4681                	li	a3,0
ffffffffc02043d8:	85a6                	mv	a1,s1
ffffffffc02043da:	8556                	mv	a0,s5
ffffffffc02043dc:	844a                	mv	s0,s2
ffffffffc02043de:	0129f363          	bgeu	s3,s2,ffffffffc02043e4 <copy_string+0x58>
ffffffffc02043e2:	844e                	mv	s0,s3
ffffffffc02043e4:	8622                	mv	a2,s0
ffffffffc02043e6:	eadff0ef          	jal	ra,ffffffffc0204292 <user_mem_check>
ffffffffc02043ea:	87aa                	mv	a5,a0
ffffffffc02043ec:	85a2                	mv	a1,s0
ffffffffc02043ee:	8526                	mv	a0,s1
ffffffffc02043f0:	f3f1                	bnez	a5,ffffffffc02043b4 <copy_string+0x28>
ffffffffc02043f2:	4501                	li	a0,0
ffffffffc02043f4:	70e2                	ld	ra,56(sp)
ffffffffc02043f6:	7442                	ld	s0,48(sp)
ffffffffc02043f8:	74a2                	ld	s1,40(sp)
ffffffffc02043fa:	7902                	ld	s2,32(sp)
ffffffffc02043fc:	69e2                	ld	s3,24(sp)
ffffffffc02043fe:	6a42                	ld	s4,16(sp)
ffffffffc0204400:	6aa2                	ld	s5,8(sp)
ffffffffc0204402:	6121                	addi	sp,sp,64
ffffffffc0204404:	8082                	ret
ffffffffc0204406:	00178613          	addi	a2,a5,1 # fffffffffffff001 <end+0x3fd686f1>
ffffffffc020440a:	64c070ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc020440e:	4505                	li	a0,1
ffffffffc0204410:	b7d5                	j	ffffffffc02043f4 <copy_string+0x68>

ffffffffc0204412 <__down.constprop.0>:
ffffffffc0204412:	715d                	addi	sp,sp,-80
ffffffffc0204414:	e0a2                	sd	s0,64(sp)
ffffffffc0204416:	e486                	sd	ra,72(sp)
ffffffffc0204418:	fc26                	sd	s1,56(sp)
ffffffffc020441a:	842a                	mv	s0,a0
ffffffffc020441c:	100027f3          	csrr	a5,sstatus
ffffffffc0204420:	8b89                	andi	a5,a5,2
ffffffffc0204422:	ebb1                	bnez	a5,ffffffffc0204476 <__down.constprop.0+0x64>
ffffffffc0204424:	411c                	lw	a5,0(a0)
ffffffffc0204426:	00f05a63          	blez	a5,ffffffffc020443a <__down.constprop.0+0x28>
ffffffffc020442a:	37fd                	addiw	a5,a5,-1
ffffffffc020442c:	c11c                	sw	a5,0(a0)
ffffffffc020442e:	4501                	li	a0,0
ffffffffc0204430:	60a6                	ld	ra,72(sp)
ffffffffc0204432:	6406                	ld	s0,64(sp)
ffffffffc0204434:	74e2                	ld	s1,56(sp)
ffffffffc0204436:	6161                	addi	sp,sp,80
ffffffffc0204438:	8082                	ret
ffffffffc020443a:	00850413          	addi	s0,a0,8 # ffffffffc8000008 <end+0x7d696f8>
ffffffffc020443e:	0024                	addi	s1,sp,8
ffffffffc0204440:	10000613          	li	a2,256
ffffffffc0204444:	85a6                	mv	a1,s1
ffffffffc0204446:	8522                	mv	a0,s0
ffffffffc0204448:	2d8000ef          	jal	ra,ffffffffc0204720 <wait_current_set>
ffffffffc020444c:	6bf020ef          	jal	ra,ffffffffc020730a <schedule>
ffffffffc0204450:	100027f3          	csrr	a5,sstatus
ffffffffc0204454:	8b89                	andi	a5,a5,2
ffffffffc0204456:	efb9                	bnez	a5,ffffffffc02044b4 <__down.constprop.0+0xa2>
ffffffffc0204458:	8526                	mv	a0,s1
ffffffffc020445a:	19c000ef          	jal	ra,ffffffffc02045f6 <wait_in_queue>
ffffffffc020445e:	e531                	bnez	a0,ffffffffc02044aa <__down.constprop.0+0x98>
ffffffffc0204460:	4542                	lw	a0,16(sp)
ffffffffc0204462:	10000793          	li	a5,256
ffffffffc0204466:	fcf515e3          	bne	a0,a5,ffffffffc0204430 <__down.constprop.0+0x1e>
ffffffffc020446a:	60a6                	ld	ra,72(sp)
ffffffffc020446c:	6406                	ld	s0,64(sp)
ffffffffc020446e:	74e2                	ld	s1,56(sp)
ffffffffc0204470:	4501                	li	a0,0
ffffffffc0204472:	6161                	addi	sp,sp,80
ffffffffc0204474:	8082                	ret
ffffffffc0204476:	ffcfc0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc020447a:	401c                	lw	a5,0(s0)
ffffffffc020447c:	00f05c63          	blez	a5,ffffffffc0204494 <__down.constprop.0+0x82>
ffffffffc0204480:	37fd                	addiw	a5,a5,-1
ffffffffc0204482:	c01c                	sw	a5,0(s0)
ffffffffc0204484:	fe8fc0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0204488:	60a6                	ld	ra,72(sp)
ffffffffc020448a:	6406                	ld	s0,64(sp)
ffffffffc020448c:	74e2                	ld	s1,56(sp)
ffffffffc020448e:	4501                	li	a0,0
ffffffffc0204490:	6161                	addi	sp,sp,80
ffffffffc0204492:	8082                	ret
ffffffffc0204494:	0421                	addi	s0,s0,8
ffffffffc0204496:	0024                	addi	s1,sp,8
ffffffffc0204498:	10000613          	li	a2,256
ffffffffc020449c:	85a6                	mv	a1,s1
ffffffffc020449e:	8522                	mv	a0,s0
ffffffffc02044a0:	280000ef          	jal	ra,ffffffffc0204720 <wait_current_set>
ffffffffc02044a4:	fc8fc0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02044a8:	b755                	j	ffffffffc020444c <__down.constprop.0+0x3a>
ffffffffc02044aa:	85a6                	mv	a1,s1
ffffffffc02044ac:	8522                	mv	a0,s0
ffffffffc02044ae:	0ee000ef          	jal	ra,ffffffffc020459c <wait_queue_del>
ffffffffc02044b2:	b77d                	j	ffffffffc0204460 <__down.constprop.0+0x4e>
ffffffffc02044b4:	fbefc0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02044b8:	8526                	mv	a0,s1
ffffffffc02044ba:	13c000ef          	jal	ra,ffffffffc02045f6 <wait_in_queue>
ffffffffc02044be:	e501                	bnez	a0,ffffffffc02044c6 <__down.constprop.0+0xb4>
ffffffffc02044c0:	facfc0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02044c4:	bf71                	j	ffffffffc0204460 <__down.constprop.0+0x4e>
ffffffffc02044c6:	85a6                	mv	a1,s1
ffffffffc02044c8:	8522                	mv	a0,s0
ffffffffc02044ca:	0d2000ef          	jal	ra,ffffffffc020459c <wait_queue_del>
ffffffffc02044ce:	bfcd                	j	ffffffffc02044c0 <__down.constprop.0+0xae>

ffffffffc02044d0 <__up.constprop.0>:
ffffffffc02044d0:	1101                	addi	sp,sp,-32
ffffffffc02044d2:	e822                	sd	s0,16(sp)
ffffffffc02044d4:	ec06                	sd	ra,24(sp)
ffffffffc02044d6:	e426                	sd	s1,8(sp)
ffffffffc02044d8:	e04a                	sd	s2,0(sp)
ffffffffc02044da:	842a                	mv	s0,a0
ffffffffc02044dc:	100027f3          	csrr	a5,sstatus
ffffffffc02044e0:	8b89                	andi	a5,a5,2
ffffffffc02044e2:	4901                	li	s2,0
ffffffffc02044e4:	eba1                	bnez	a5,ffffffffc0204534 <__up.constprop.0+0x64>
ffffffffc02044e6:	00840493          	addi	s1,s0,8
ffffffffc02044ea:	8526                	mv	a0,s1
ffffffffc02044ec:	0ee000ef          	jal	ra,ffffffffc02045da <wait_queue_first>
ffffffffc02044f0:	85aa                	mv	a1,a0
ffffffffc02044f2:	cd0d                	beqz	a0,ffffffffc020452c <__up.constprop.0+0x5c>
ffffffffc02044f4:	6118                	ld	a4,0(a0)
ffffffffc02044f6:	10000793          	li	a5,256
ffffffffc02044fa:	0ec72703          	lw	a4,236(a4)
ffffffffc02044fe:	02f71f63          	bne	a4,a5,ffffffffc020453c <__up.constprop.0+0x6c>
ffffffffc0204502:	4685                	li	a3,1
ffffffffc0204504:	10000613          	li	a2,256
ffffffffc0204508:	8526                	mv	a0,s1
ffffffffc020450a:	0fa000ef          	jal	ra,ffffffffc0204604 <wakeup_wait>
ffffffffc020450e:	00091863          	bnez	s2,ffffffffc020451e <__up.constprop.0+0x4e>
ffffffffc0204512:	60e2                	ld	ra,24(sp)
ffffffffc0204514:	6442                	ld	s0,16(sp)
ffffffffc0204516:	64a2                	ld	s1,8(sp)
ffffffffc0204518:	6902                	ld	s2,0(sp)
ffffffffc020451a:	6105                	addi	sp,sp,32
ffffffffc020451c:	8082                	ret
ffffffffc020451e:	6442                	ld	s0,16(sp)
ffffffffc0204520:	60e2                	ld	ra,24(sp)
ffffffffc0204522:	64a2                	ld	s1,8(sp)
ffffffffc0204524:	6902                	ld	s2,0(sp)
ffffffffc0204526:	6105                	addi	sp,sp,32
ffffffffc0204528:	f44fc06f          	j	ffffffffc0200c6c <intr_enable>
ffffffffc020452c:	401c                	lw	a5,0(s0)
ffffffffc020452e:	2785                	addiw	a5,a5,1
ffffffffc0204530:	c01c                	sw	a5,0(s0)
ffffffffc0204532:	bff1                	j	ffffffffc020450e <__up.constprop.0+0x3e>
ffffffffc0204534:	f3efc0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0204538:	4905                	li	s2,1
ffffffffc020453a:	b775                	j	ffffffffc02044e6 <__up.constprop.0+0x16>
ffffffffc020453c:	00009697          	auipc	a3,0x9
ffffffffc0204540:	f3468693          	addi	a3,a3,-204 # ffffffffc020d470 <default_pmm_manager+0xaa0>
ffffffffc0204544:	00008617          	auipc	a2,0x8
ffffffffc0204548:	9a460613          	addi	a2,a2,-1628 # ffffffffc020bee8 <commands+0x210>
ffffffffc020454c:	45e5                	li	a1,25
ffffffffc020454e:	00009517          	auipc	a0,0x9
ffffffffc0204552:	f4a50513          	addi	a0,a0,-182 # ffffffffc020d498 <default_pmm_manager+0xac8>
ffffffffc0204556:	f49fb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020455a <sem_init>:
ffffffffc020455a:	c10c                	sw	a1,0(a0)
ffffffffc020455c:	0521                	addi	a0,a0,8
ffffffffc020455e:	a825                	j	ffffffffc0204596 <wait_queue_init>

ffffffffc0204560 <up>:
ffffffffc0204560:	f71ff06f          	j	ffffffffc02044d0 <__up.constprop.0>

ffffffffc0204564 <down>:
ffffffffc0204564:	1141                	addi	sp,sp,-16
ffffffffc0204566:	e406                	sd	ra,8(sp)
ffffffffc0204568:	eabff0ef          	jal	ra,ffffffffc0204412 <__down.constprop.0>
ffffffffc020456c:	2501                	sext.w	a0,a0
ffffffffc020456e:	e501                	bnez	a0,ffffffffc0204576 <down+0x12>
ffffffffc0204570:	60a2                	ld	ra,8(sp)
ffffffffc0204572:	0141                	addi	sp,sp,16
ffffffffc0204574:	8082                	ret
ffffffffc0204576:	00009697          	auipc	a3,0x9
ffffffffc020457a:	f3268693          	addi	a3,a3,-206 # ffffffffc020d4a8 <default_pmm_manager+0xad8>
ffffffffc020457e:	00008617          	auipc	a2,0x8
ffffffffc0204582:	96a60613          	addi	a2,a2,-1686 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204586:	04000593          	li	a1,64
ffffffffc020458a:	00009517          	auipc	a0,0x9
ffffffffc020458e:	f0e50513          	addi	a0,a0,-242 # ffffffffc020d498 <default_pmm_manager+0xac8>
ffffffffc0204592:	f0dfb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0204596 <wait_queue_init>:
ffffffffc0204596:	e508                	sd	a0,8(a0)
ffffffffc0204598:	e108                	sd	a0,0(a0)
ffffffffc020459a:	8082                	ret

ffffffffc020459c <wait_queue_del>:
ffffffffc020459c:	7198                	ld	a4,32(a1)
ffffffffc020459e:	01858793          	addi	a5,a1,24
ffffffffc02045a2:	00e78b63          	beq	a5,a4,ffffffffc02045b8 <wait_queue_del+0x1c>
ffffffffc02045a6:	6994                	ld	a3,16(a1)
ffffffffc02045a8:	00a69863          	bne	a3,a0,ffffffffc02045b8 <wait_queue_del+0x1c>
ffffffffc02045ac:	6d94                	ld	a3,24(a1)
ffffffffc02045ae:	e698                	sd	a4,8(a3)
ffffffffc02045b0:	e314                	sd	a3,0(a4)
ffffffffc02045b2:	f19c                	sd	a5,32(a1)
ffffffffc02045b4:	ed9c                	sd	a5,24(a1)
ffffffffc02045b6:	8082                	ret
ffffffffc02045b8:	1141                	addi	sp,sp,-16
ffffffffc02045ba:	00009697          	auipc	a3,0x9
ffffffffc02045be:	f4e68693          	addi	a3,a3,-178 # ffffffffc020d508 <default_pmm_manager+0xb38>
ffffffffc02045c2:	00008617          	auipc	a2,0x8
ffffffffc02045c6:	92660613          	addi	a2,a2,-1754 # ffffffffc020bee8 <commands+0x210>
ffffffffc02045ca:	45f1                	li	a1,28
ffffffffc02045cc:	00009517          	auipc	a0,0x9
ffffffffc02045d0:	f2450513          	addi	a0,a0,-220 # ffffffffc020d4f0 <default_pmm_manager+0xb20>
ffffffffc02045d4:	e406                	sd	ra,8(sp)
ffffffffc02045d6:	ec9fb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02045da <wait_queue_first>:
ffffffffc02045da:	651c                	ld	a5,8(a0)
ffffffffc02045dc:	00f50563          	beq	a0,a5,ffffffffc02045e6 <wait_queue_first+0xc>
ffffffffc02045e0:	fe878513          	addi	a0,a5,-24
ffffffffc02045e4:	8082                	ret
ffffffffc02045e6:	4501                	li	a0,0
ffffffffc02045e8:	8082                	ret

ffffffffc02045ea <wait_queue_empty>:
ffffffffc02045ea:	651c                	ld	a5,8(a0)
ffffffffc02045ec:	40a78533          	sub	a0,a5,a0
ffffffffc02045f0:	00153513          	seqz	a0,a0
ffffffffc02045f4:	8082                	ret

ffffffffc02045f6 <wait_in_queue>:
ffffffffc02045f6:	711c                	ld	a5,32(a0)
ffffffffc02045f8:	0561                	addi	a0,a0,24
ffffffffc02045fa:	40a78533          	sub	a0,a5,a0
ffffffffc02045fe:	00a03533          	snez	a0,a0
ffffffffc0204602:	8082                	ret

ffffffffc0204604 <wakeup_wait>:
ffffffffc0204604:	e689                	bnez	a3,ffffffffc020460e <wakeup_wait+0xa>
ffffffffc0204606:	6188                	ld	a0,0(a1)
ffffffffc0204608:	c590                	sw	a2,8(a1)
ffffffffc020460a:	44f0206f          	j	ffffffffc0207258 <wakeup_proc>
ffffffffc020460e:	7198                	ld	a4,32(a1)
ffffffffc0204610:	01858793          	addi	a5,a1,24
ffffffffc0204614:	00e78e63          	beq	a5,a4,ffffffffc0204630 <wakeup_wait+0x2c>
ffffffffc0204618:	6994                	ld	a3,16(a1)
ffffffffc020461a:	00d51b63          	bne	a0,a3,ffffffffc0204630 <wakeup_wait+0x2c>
ffffffffc020461e:	6d94                	ld	a3,24(a1)
ffffffffc0204620:	6188                	ld	a0,0(a1)
ffffffffc0204622:	e698                	sd	a4,8(a3)
ffffffffc0204624:	e314                	sd	a3,0(a4)
ffffffffc0204626:	f19c                	sd	a5,32(a1)
ffffffffc0204628:	ed9c                	sd	a5,24(a1)
ffffffffc020462a:	c590                	sw	a2,8(a1)
ffffffffc020462c:	42d0206f          	j	ffffffffc0207258 <wakeup_proc>
ffffffffc0204630:	1141                	addi	sp,sp,-16
ffffffffc0204632:	00009697          	auipc	a3,0x9
ffffffffc0204636:	ed668693          	addi	a3,a3,-298 # ffffffffc020d508 <default_pmm_manager+0xb38>
ffffffffc020463a:	00008617          	auipc	a2,0x8
ffffffffc020463e:	8ae60613          	addi	a2,a2,-1874 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204642:	45f1                	li	a1,28
ffffffffc0204644:	00009517          	auipc	a0,0x9
ffffffffc0204648:	eac50513          	addi	a0,a0,-340 # ffffffffc020d4f0 <default_pmm_manager+0xb20>
ffffffffc020464c:	e406                	sd	ra,8(sp)
ffffffffc020464e:	e51fb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0204652 <wakeup_queue>:
ffffffffc0204652:	651c                	ld	a5,8(a0)
ffffffffc0204654:	0ca78563          	beq	a5,a0,ffffffffc020471e <wakeup_queue+0xcc>
ffffffffc0204658:	1101                	addi	sp,sp,-32
ffffffffc020465a:	e822                	sd	s0,16(sp)
ffffffffc020465c:	e426                	sd	s1,8(sp)
ffffffffc020465e:	e04a                	sd	s2,0(sp)
ffffffffc0204660:	ec06                	sd	ra,24(sp)
ffffffffc0204662:	84aa                	mv	s1,a0
ffffffffc0204664:	892e                	mv	s2,a1
ffffffffc0204666:	fe878413          	addi	s0,a5,-24
ffffffffc020466a:	e23d                	bnez	a2,ffffffffc02046d0 <wakeup_queue+0x7e>
ffffffffc020466c:	6008                	ld	a0,0(s0)
ffffffffc020466e:	01242423          	sw	s2,8(s0)
ffffffffc0204672:	3e7020ef          	jal	ra,ffffffffc0207258 <wakeup_proc>
ffffffffc0204676:	701c                	ld	a5,32(s0)
ffffffffc0204678:	01840713          	addi	a4,s0,24
ffffffffc020467c:	02e78463          	beq	a5,a4,ffffffffc02046a4 <wakeup_queue+0x52>
ffffffffc0204680:	6818                	ld	a4,16(s0)
ffffffffc0204682:	02e49163          	bne	s1,a4,ffffffffc02046a4 <wakeup_queue+0x52>
ffffffffc0204686:	02f48f63          	beq	s1,a5,ffffffffc02046c4 <wakeup_queue+0x72>
ffffffffc020468a:	fe87b503          	ld	a0,-24(a5)
ffffffffc020468e:	ff27a823          	sw	s2,-16(a5)
ffffffffc0204692:	fe878413          	addi	s0,a5,-24
ffffffffc0204696:	3c3020ef          	jal	ra,ffffffffc0207258 <wakeup_proc>
ffffffffc020469a:	701c                	ld	a5,32(s0)
ffffffffc020469c:	01840713          	addi	a4,s0,24
ffffffffc02046a0:	fee790e3          	bne	a5,a4,ffffffffc0204680 <wakeup_queue+0x2e>
ffffffffc02046a4:	00009697          	auipc	a3,0x9
ffffffffc02046a8:	e6468693          	addi	a3,a3,-412 # ffffffffc020d508 <default_pmm_manager+0xb38>
ffffffffc02046ac:	00008617          	auipc	a2,0x8
ffffffffc02046b0:	83c60613          	addi	a2,a2,-1988 # ffffffffc020bee8 <commands+0x210>
ffffffffc02046b4:	02200593          	li	a1,34
ffffffffc02046b8:	00009517          	auipc	a0,0x9
ffffffffc02046bc:	e3850513          	addi	a0,a0,-456 # ffffffffc020d4f0 <default_pmm_manager+0xb20>
ffffffffc02046c0:	ddffb0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02046c4:	60e2                	ld	ra,24(sp)
ffffffffc02046c6:	6442                	ld	s0,16(sp)
ffffffffc02046c8:	64a2                	ld	s1,8(sp)
ffffffffc02046ca:	6902                	ld	s2,0(sp)
ffffffffc02046cc:	6105                	addi	sp,sp,32
ffffffffc02046ce:	8082                	ret
ffffffffc02046d0:	6798                	ld	a4,8(a5)
ffffffffc02046d2:	02f70763          	beq	a4,a5,ffffffffc0204700 <wakeup_queue+0xae>
ffffffffc02046d6:	6814                	ld	a3,16(s0)
ffffffffc02046d8:	02d49463          	bne	s1,a3,ffffffffc0204700 <wakeup_queue+0xae>
ffffffffc02046dc:	6c14                	ld	a3,24(s0)
ffffffffc02046de:	6008                	ld	a0,0(s0)
ffffffffc02046e0:	e698                	sd	a4,8(a3)
ffffffffc02046e2:	e314                	sd	a3,0(a4)
ffffffffc02046e4:	f01c                	sd	a5,32(s0)
ffffffffc02046e6:	ec1c                	sd	a5,24(s0)
ffffffffc02046e8:	01242423          	sw	s2,8(s0)
ffffffffc02046ec:	36d020ef          	jal	ra,ffffffffc0207258 <wakeup_proc>
ffffffffc02046f0:	6480                	ld	s0,8(s1)
ffffffffc02046f2:	fc8489e3          	beq	s1,s0,ffffffffc02046c4 <wakeup_queue+0x72>
ffffffffc02046f6:	6418                	ld	a4,8(s0)
ffffffffc02046f8:	87a2                	mv	a5,s0
ffffffffc02046fa:	1421                	addi	s0,s0,-24
ffffffffc02046fc:	fce79de3          	bne	a5,a4,ffffffffc02046d6 <wakeup_queue+0x84>
ffffffffc0204700:	00009697          	auipc	a3,0x9
ffffffffc0204704:	e0868693          	addi	a3,a3,-504 # ffffffffc020d508 <default_pmm_manager+0xb38>
ffffffffc0204708:	00007617          	auipc	a2,0x7
ffffffffc020470c:	7e060613          	addi	a2,a2,2016 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204710:	45f1                	li	a1,28
ffffffffc0204712:	00009517          	auipc	a0,0x9
ffffffffc0204716:	dde50513          	addi	a0,a0,-546 # ffffffffc020d4f0 <default_pmm_manager+0xb20>
ffffffffc020471a:	d85fb0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020471e:	8082                	ret

ffffffffc0204720 <wait_current_set>:
ffffffffc0204720:	00092797          	auipc	a5,0x92
ffffffffc0204724:	1a07b783          	ld	a5,416(a5) # ffffffffc02968c0 <current>
ffffffffc0204728:	c39d                	beqz	a5,ffffffffc020474e <wait_current_set+0x2e>
ffffffffc020472a:	01858713          	addi	a4,a1,24
ffffffffc020472e:	800006b7          	lui	a3,0x80000
ffffffffc0204732:	ed98                	sd	a4,24(a1)
ffffffffc0204734:	e19c                	sd	a5,0(a1)
ffffffffc0204736:	c594                	sw	a3,8(a1)
ffffffffc0204738:	4685                	li	a3,1
ffffffffc020473a:	c394                	sw	a3,0(a5)
ffffffffc020473c:	0ec7a623          	sw	a2,236(a5)
ffffffffc0204740:	611c                	ld	a5,0(a0)
ffffffffc0204742:	e988                	sd	a0,16(a1)
ffffffffc0204744:	e118                	sd	a4,0(a0)
ffffffffc0204746:	e798                	sd	a4,8(a5)
ffffffffc0204748:	f188                	sd	a0,32(a1)
ffffffffc020474a:	ed9c                	sd	a5,24(a1)
ffffffffc020474c:	8082                	ret
ffffffffc020474e:	1141                	addi	sp,sp,-16
ffffffffc0204750:	00009697          	auipc	a3,0x9
ffffffffc0204754:	df868693          	addi	a3,a3,-520 # ffffffffc020d548 <default_pmm_manager+0xb78>
ffffffffc0204758:	00007617          	auipc	a2,0x7
ffffffffc020475c:	79060613          	addi	a2,a2,1936 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204760:	07400593          	li	a1,116
ffffffffc0204764:	00009517          	auipc	a0,0x9
ffffffffc0204768:	d8c50513          	addi	a0,a0,-628 # ffffffffc020d4f0 <default_pmm_manager+0xb20>
ffffffffc020476c:	e406                	sd	ra,8(sp)
ffffffffc020476e:	d31fb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0204772 <get_fd_array.part.0>:
ffffffffc0204772:	1141                	addi	sp,sp,-16
ffffffffc0204774:	00009697          	auipc	a3,0x9
ffffffffc0204778:	de468693          	addi	a3,a3,-540 # ffffffffc020d558 <default_pmm_manager+0xb88>
ffffffffc020477c:	00007617          	auipc	a2,0x7
ffffffffc0204780:	76c60613          	addi	a2,a2,1900 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204784:	45d1                	li	a1,20
ffffffffc0204786:	00009517          	auipc	a0,0x9
ffffffffc020478a:	e0250513          	addi	a0,a0,-510 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc020478e:	e406                	sd	ra,8(sp)
ffffffffc0204790:	d0ffb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0204794 <fd_array_alloc>:
ffffffffc0204794:	00092797          	auipc	a5,0x92
ffffffffc0204798:	12c7b783          	ld	a5,300(a5) # ffffffffc02968c0 <current>
ffffffffc020479c:	1487b783          	ld	a5,328(a5)
ffffffffc02047a0:	1141                	addi	sp,sp,-16
ffffffffc02047a2:	e406                	sd	ra,8(sp)
ffffffffc02047a4:	c3a5                	beqz	a5,ffffffffc0204804 <fd_array_alloc+0x70>
ffffffffc02047a6:	4b98                	lw	a4,16(a5)
ffffffffc02047a8:	04e05e63          	blez	a4,ffffffffc0204804 <fd_array_alloc+0x70>
ffffffffc02047ac:	775d                	lui	a4,0xffff7
ffffffffc02047ae:	ad970713          	addi	a4,a4,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc02047b2:	679c                	ld	a5,8(a5)
ffffffffc02047b4:	02e50863          	beq	a0,a4,ffffffffc02047e4 <fd_array_alloc+0x50>
ffffffffc02047b8:	04700713          	li	a4,71
ffffffffc02047bc:	04a76263          	bltu	a4,a0,ffffffffc0204800 <fd_array_alloc+0x6c>
ffffffffc02047c0:	00351713          	slli	a4,a0,0x3
ffffffffc02047c4:	40a70533          	sub	a0,a4,a0
ffffffffc02047c8:	050e                	slli	a0,a0,0x3
ffffffffc02047ca:	97aa                	add	a5,a5,a0
ffffffffc02047cc:	4398                	lw	a4,0(a5)
ffffffffc02047ce:	e71d                	bnez	a4,ffffffffc02047fc <fd_array_alloc+0x68>
ffffffffc02047d0:	5b88                	lw	a0,48(a5)
ffffffffc02047d2:	e91d                	bnez	a0,ffffffffc0204808 <fd_array_alloc+0x74>
ffffffffc02047d4:	4705                	li	a4,1
ffffffffc02047d6:	c398                	sw	a4,0(a5)
ffffffffc02047d8:	0207b423          	sd	zero,40(a5)
ffffffffc02047dc:	e19c                	sd	a5,0(a1)
ffffffffc02047de:	60a2                	ld	ra,8(sp)
ffffffffc02047e0:	0141                	addi	sp,sp,16
ffffffffc02047e2:	8082                	ret
ffffffffc02047e4:	6685                	lui	a3,0x1
ffffffffc02047e6:	fc068693          	addi	a3,a3,-64 # fc0 <_binary_bin_swap_img_size-0x6d40>
ffffffffc02047ea:	96be                	add	a3,a3,a5
ffffffffc02047ec:	4398                	lw	a4,0(a5)
ffffffffc02047ee:	d36d                	beqz	a4,ffffffffc02047d0 <fd_array_alloc+0x3c>
ffffffffc02047f0:	03878793          	addi	a5,a5,56
ffffffffc02047f4:	fef69ce3          	bne	a3,a5,ffffffffc02047ec <fd_array_alloc+0x58>
ffffffffc02047f8:	5529                	li	a0,-22
ffffffffc02047fa:	b7d5                	j	ffffffffc02047de <fd_array_alloc+0x4a>
ffffffffc02047fc:	5545                	li	a0,-15
ffffffffc02047fe:	b7c5                	j	ffffffffc02047de <fd_array_alloc+0x4a>
ffffffffc0204800:	5575                	li	a0,-3
ffffffffc0204802:	bff1                	j	ffffffffc02047de <fd_array_alloc+0x4a>
ffffffffc0204804:	f6fff0ef          	jal	ra,ffffffffc0204772 <get_fd_array.part.0>
ffffffffc0204808:	00009697          	auipc	a3,0x9
ffffffffc020480c:	d9068693          	addi	a3,a3,-624 # ffffffffc020d598 <default_pmm_manager+0xbc8>
ffffffffc0204810:	00007617          	auipc	a2,0x7
ffffffffc0204814:	6d860613          	addi	a2,a2,1752 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204818:	03b00593          	li	a1,59
ffffffffc020481c:	00009517          	auipc	a0,0x9
ffffffffc0204820:	d6c50513          	addi	a0,a0,-660 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc0204824:	c7bfb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0204828 <fd_array_free>:
ffffffffc0204828:	411c                	lw	a5,0(a0)
ffffffffc020482a:	1141                	addi	sp,sp,-16
ffffffffc020482c:	e022                	sd	s0,0(sp)
ffffffffc020482e:	e406                	sd	ra,8(sp)
ffffffffc0204830:	4705                	li	a4,1
ffffffffc0204832:	842a                	mv	s0,a0
ffffffffc0204834:	04e78063          	beq	a5,a4,ffffffffc0204874 <fd_array_free+0x4c>
ffffffffc0204838:	470d                	li	a4,3
ffffffffc020483a:	04e79563          	bne	a5,a4,ffffffffc0204884 <fd_array_free+0x5c>
ffffffffc020483e:	591c                	lw	a5,48(a0)
ffffffffc0204840:	c38d                	beqz	a5,ffffffffc0204862 <fd_array_free+0x3a>
ffffffffc0204842:	00009697          	auipc	a3,0x9
ffffffffc0204846:	d5668693          	addi	a3,a3,-682 # ffffffffc020d598 <default_pmm_manager+0xbc8>
ffffffffc020484a:	00007617          	auipc	a2,0x7
ffffffffc020484e:	69e60613          	addi	a2,a2,1694 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204852:	04500593          	li	a1,69
ffffffffc0204856:	00009517          	auipc	a0,0x9
ffffffffc020485a:	d3250513          	addi	a0,a0,-718 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc020485e:	c41fb0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0204862:	7408                	ld	a0,40(s0)
ffffffffc0204864:	06b030ef          	jal	ra,ffffffffc02080ce <vfs_close>
ffffffffc0204868:	60a2                	ld	ra,8(sp)
ffffffffc020486a:	00042023          	sw	zero,0(s0)
ffffffffc020486e:	6402                	ld	s0,0(sp)
ffffffffc0204870:	0141                	addi	sp,sp,16
ffffffffc0204872:	8082                	ret
ffffffffc0204874:	591c                	lw	a5,48(a0)
ffffffffc0204876:	f7f1                	bnez	a5,ffffffffc0204842 <fd_array_free+0x1a>
ffffffffc0204878:	60a2                	ld	ra,8(sp)
ffffffffc020487a:	00042023          	sw	zero,0(s0)
ffffffffc020487e:	6402                	ld	s0,0(sp)
ffffffffc0204880:	0141                	addi	sp,sp,16
ffffffffc0204882:	8082                	ret
ffffffffc0204884:	00009697          	auipc	a3,0x9
ffffffffc0204888:	d4c68693          	addi	a3,a3,-692 # ffffffffc020d5d0 <default_pmm_manager+0xc00>
ffffffffc020488c:	00007617          	auipc	a2,0x7
ffffffffc0204890:	65c60613          	addi	a2,a2,1628 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204894:	04400593          	li	a1,68
ffffffffc0204898:	00009517          	auipc	a0,0x9
ffffffffc020489c:	cf050513          	addi	a0,a0,-784 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc02048a0:	bfffb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02048a4 <fd_array_release>:
ffffffffc02048a4:	4118                	lw	a4,0(a0)
ffffffffc02048a6:	1141                	addi	sp,sp,-16
ffffffffc02048a8:	e406                	sd	ra,8(sp)
ffffffffc02048aa:	4685                	li	a3,1
ffffffffc02048ac:	3779                	addiw	a4,a4,-2
ffffffffc02048ae:	04e6e063          	bltu	a3,a4,ffffffffc02048ee <fd_array_release+0x4a>
ffffffffc02048b2:	5918                	lw	a4,48(a0)
ffffffffc02048b4:	00e05d63          	blez	a4,ffffffffc02048ce <fd_array_release+0x2a>
ffffffffc02048b8:	fff7069b          	addiw	a3,a4,-1
ffffffffc02048bc:	d914                	sw	a3,48(a0)
ffffffffc02048be:	c681                	beqz	a3,ffffffffc02048c6 <fd_array_release+0x22>
ffffffffc02048c0:	60a2                	ld	ra,8(sp)
ffffffffc02048c2:	0141                	addi	sp,sp,16
ffffffffc02048c4:	8082                	ret
ffffffffc02048c6:	60a2                	ld	ra,8(sp)
ffffffffc02048c8:	0141                	addi	sp,sp,16
ffffffffc02048ca:	f5fff06f          	j	ffffffffc0204828 <fd_array_free>
ffffffffc02048ce:	00009697          	auipc	a3,0x9
ffffffffc02048d2:	d7268693          	addi	a3,a3,-654 # ffffffffc020d640 <default_pmm_manager+0xc70>
ffffffffc02048d6:	00007617          	auipc	a2,0x7
ffffffffc02048da:	61260613          	addi	a2,a2,1554 # ffffffffc020bee8 <commands+0x210>
ffffffffc02048de:	05600593          	li	a1,86
ffffffffc02048e2:	00009517          	auipc	a0,0x9
ffffffffc02048e6:	ca650513          	addi	a0,a0,-858 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc02048ea:	bb5fb0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02048ee:	00009697          	auipc	a3,0x9
ffffffffc02048f2:	d1a68693          	addi	a3,a3,-742 # ffffffffc020d608 <default_pmm_manager+0xc38>
ffffffffc02048f6:	00007617          	auipc	a2,0x7
ffffffffc02048fa:	5f260613          	addi	a2,a2,1522 # ffffffffc020bee8 <commands+0x210>
ffffffffc02048fe:	05500593          	li	a1,85
ffffffffc0204902:	00009517          	auipc	a0,0x9
ffffffffc0204906:	c8650513          	addi	a0,a0,-890 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc020490a:	b95fb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020490e <fd_array_open.part.0>:
ffffffffc020490e:	1141                	addi	sp,sp,-16
ffffffffc0204910:	00009697          	auipc	a3,0x9
ffffffffc0204914:	d4868693          	addi	a3,a3,-696 # ffffffffc020d658 <default_pmm_manager+0xc88>
ffffffffc0204918:	00007617          	auipc	a2,0x7
ffffffffc020491c:	5d060613          	addi	a2,a2,1488 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204920:	05f00593          	li	a1,95
ffffffffc0204924:	00009517          	auipc	a0,0x9
ffffffffc0204928:	c6450513          	addi	a0,a0,-924 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc020492c:	e406                	sd	ra,8(sp)
ffffffffc020492e:	b71fb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0204932 <fd_array_init>:
ffffffffc0204932:	4781                	li	a5,0
ffffffffc0204934:	04800713          	li	a4,72
ffffffffc0204938:	cd1c                	sw	a5,24(a0)
ffffffffc020493a:	02052823          	sw	zero,48(a0)
ffffffffc020493e:	00052023          	sw	zero,0(a0)
ffffffffc0204942:	2785                	addiw	a5,a5,1
ffffffffc0204944:	03850513          	addi	a0,a0,56
ffffffffc0204948:	fee798e3          	bne	a5,a4,ffffffffc0204938 <fd_array_init+0x6>
ffffffffc020494c:	8082                	ret

ffffffffc020494e <fd_array_close>:
ffffffffc020494e:	4118                	lw	a4,0(a0)
ffffffffc0204950:	1141                	addi	sp,sp,-16
ffffffffc0204952:	e406                	sd	ra,8(sp)
ffffffffc0204954:	e022                	sd	s0,0(sp)
ffffffffc0204956:	4789                	li	a5,2
ffffffffc0204958:	04f71a63          	bne	a4,a5,ffffffffc02049ac <fd_array_close+0x5e>
ffffffffc020495c:	591c                	lw	a5,48(a0)
ffffffffc020495e:	842a                	mv	s0,a0
ffffffffc0204960:	02f05663          	blez	a5,ffffffffc020498c <fd_array_close+0x3e>
ffffffffc0204964:	37fd                	addiw	a5,a5,-1
ffffffffc0204966:	470d                	li	a4,3
ffffffffc0204968:	c118                	sw	a4,0(a0)
ffffffffc020496a:	d91c                	sw	a5,48(a0)
ffffffffc020496c:	0007871b          	sext.w	a4,a5
ffffffffc0204970:	c709                	beqz	a4,ffffffffc020497a <fd_array_close+0x2c>
ffffffffc0204972:	60a2                	ld	ra,8(sp)
ffffffffc0204974:	6402                	ld	s0,0(sp)
ffffffffc0204976:	0141                	addi	sp,sp,16
ffffffffc0204978:	8082                	ret
ffffffffc020497a:	7508                	ld	a0,40(a0)
ffffffffc020497c:	752030ef          	jal	ra,ffffffffc02080ce <vfs_close>
ffffffffc0204980:	60a2                	ld	ra,8(sp)
ffffffffc0204982:	00042023          	sw	zero,0(s0)
ffffffffc0204986:	6402                	ld	s0,0(sp)
ffffffffc0204988:	0141                	addi	sp,sp,16
ffffffffc020498a:	8082                	ret
ffffffffc020498c:	00009697          	auipc	a3,0x9
ffffffffc0204990:	cb468693          	addi	a3,a3,-844 # ffffffffc020d640 <default_pmm_manager+0xc70>
ffffffffc0204994:	00007617          	auipc	a2,0x7
ffffffffc0204998:	55460613          	addi	a2,a2,1364 # ffffffffc020bee8 <commands+0x210>
ffffffffc020499c:	06800593          	li	a1,104
ffffffffc02049a0:	00009517          	auipc	a0,0x9
ffffffffc02049a4:	be850513          	addi	a0,a0,-1048 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc02049a8:	af7fb0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02049ac:	00009697          	auipc	a3,0x9
ffffffffc02049b0:	c0468693          	addi	a3,a3,-1020 # ffffffffc020d5b0 <default_pmm_manager+0xbe0>
ffffffffc02049b4:	00007617          	auipc	a2,0x7
ffffffffc02049b8:	53460613          	addi	a2,a2,1332 # ffffffffc020bee8 <commands+0x210>
ffffffffc02049bc:	06700593          	li	a1,103
ffffffffc02049c0:	00009517          	auipc	a0,0x9
ffffffffc02049c4:	bc850513          	addi	a0,a0,-1080 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc02049c8:	ad7fb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02049cc <fd_array_dup>:
ffffffffc02049cc:	7179                	addi	sp,sp,-48
ffffffffc02049ce:	e84a                	sd	s2,16(sp)
ffffffffc02049d0:	00052903          	lw	s2,0(a0)
ffffffffc02049d4:	f406                	sd	ra,40(sp)
ffffffffc02049d6:	f022                	sd	s0,32(sp)
ffffffffc02049d8:	ec26                	sd	s1,24(sp)
ffffffffc02049da:	e44e                	sd	s3,8(sp)
ffffffffc02049dc:	4785                	li	a5,1
ffffffffc02049de:	04f91663          	bne	s2,a5,ffffffffc0204a2a <fd_array_dup+0x5e>
ffffffffc02049e2:	0005a983          	lw	s3,0(a1)
ffffffffc02049e6:	4789                	li	a5,2
ffffffffc02049e8:	04f99163          	bne	s3,a5,ffffffffc0204a2a <fd_array_dup+0x5e>
ffffffffc02049ec:	7584                	ld	s1,40(a1)
ffffffffc02049ee:	699c                	ld	a5,16(a1)
ffffffffc02049f0:	7194                	ld	a3,32(a1)
ffffffffc02049f2:	6598                	ld	a4,8(a1)
ffffffffc02049f4:	842a                	mv	s0,a0
ffffffffc02049f6:	e91c                	sd	a5,16(a0)
ffffffffc02049f8:	f114                	sd	a3,32(a0)
ffffffffc02049fa:	e518                	sd	a4,8(a0)
ffffffffc02049fc:	8526                	mv	a0,s1
ffffffffc02049fe:	62f020ef          	jal	ra,ffffffffc020782c <inode_ref_inc>
ffffffffc0204a02:	8526                	mv	a0,s1
ffffffffc0204a04:	635020ef          	jal	ra,ffffffffc0207838 <inode_open_inc>
ffffffffc0204a08:	401c                	lw	a5,0(s0)
ffffffffc0204a0a:	f404                	sd	s1,40(s0)
ffffffffc0204a0c:	03279f63          	bne	a5,s2,ffffffffc0204a4a <fd_array_dup+0x7e>
ffffffffc0204a10:	cc8d                	beqz	s1,ffffffffc0204a4a <fd_array_dup+0x7e>
ffffffffc0204a12:	581c                	lw	a5,48(s0)
ffffffffc0204a14:	01342023          	sw	s3,0(s0)
ffffffffc0204a18:	70a2                	ld	ra,40(sp)
ffffffffc0204a1a:	2785                	addiw	a5,a5,1
ffffffffc0204a1c:	d81c                	sw	a5,48(s0)
ffffffffc0204a1e:	7402                	ld	s0,32(sp)
ffffffffc0204a20:	64e2                	ld	s1,24(sp)
ffffffffc0204a22:	6942                	ld	s2,16(sp)
ffffffffc0204a24:	69a2                	ld	s3,8(sp)
ffffffffc0204a26:	6145                	addi	sp,sp,48
ffffffffc0204a28:	8082                	ret
ffffffffc0204a2a:	00009697          	auipc	a3,0x9
ffffffffc0204a2e:	c5e68693          	addi	a3,a3,-930 # ffffffffc020d688 <default_pmm_manager+0xcb8>
ffffffffc0204a32:	00007617          	auipc	a2,0x7
ffffffffc0204a36:	4b660613          	addi	a2,a2,1206 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204a3a:	07300593          	li	a1,115
ffffffffc0204a3e:	00009517          	auipc	a0,0x9
ffffffffc0204a42:	b4a50513          	addi	a0,a0,-1206 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc0204a46:	a59fb0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0204a4a:	ec5ff0ef          	jal	ra,ffffffffc020490e <fd_array_open.part.0>

ffffffffc0204a4e <file_testfd>:
ffffffffc0204a4e:	04700793          	li	a5,71
ffffffffc0204a52:	04a7e263          	bltu	a5,a0,ffffffffc0204a96 <file_testfd+0x48>
ffffffffc0204a56:	00092797          	auipc	a5,0x92
ffffffffc0204a5a:	e6a7b783          	ld	a5,-406(a5) # ffffffffc02968c0 <current>
ffffffffc0204a5e:	1487b783          	ld	a5,328(a5)
ffffffffc0204a62:	cf85                	beqz	a5,ffffffffc0204a9a <file_testfd+0x4c>
ffffffffc0204a64:	4b98                	lw	a4,16(a5)
ffffffffc0204a66:	02e05a63          	blez	a4,ffffffffc0204a9a <file_testfd+0x4c>
ffffffffc0204a6a:	6798                	ld	a4,8(a5)
ffffffffc0204a6c:	00351793          	slli	a5,a0,0x3
ffffffffc0204a70:	8f89                	sub	a5,a5,a0
ffffffffc0204a72:	078e                	slli	a5,a5,0x3
ffffffffc0204a74:	97ba                	add	a5,a5,a4
ffffffffc0204a76:	4394                	lw	a3,0(a5)
ffffffffc0204a78:	4709                	li	a4,2
ffffffffc0204a7a:	00e69e63          	bne	a3,a4,ffffffffc0204a96 <file_testfd+0x48>
ffffffffc0204a7e:	4f98                	lw	a4,24(a5)
ffffffffc0204a80:	00a71b63          	bne	a4,a0,ffffffffc0204a96 <file_testfd+0x48>
ffffffffc0204a84:	c199                	beqz	a1,ffffffffc0204a8a <file_testfd+0x3c>
ffffffffc0204a86:	6788                	ld	a0,8(a5)
ffffffffc0204a88:	c901                	beqz	a0,ffffffffc0204a98 <file_testfd+0x4a>
ffffffffc0204a8a:	4505                	li	a0,1
ffffffffc0204a8c:	c611                	beqz	a2,ffffffffc0204a98 <file_testfd+0x4a>
ffffffffc0204a8e:	6b88                	ld	a0,16(a5)
ffffffffc0204a90:	00a03533          	snez	a0,a0
ffffffffc0204a94:	8082                	ret
ffffffffc0204a96:	4501                	li	a0,0
ffffffffc0204a98:	8082                	ret
ffffffffc0204a9a:	1141                	addi	sp,sp,-16
ffffffffc0204a9c:	e406                	sd	ra,8(sp)
ffffffffc0204a9e:	cd5ff0ef          	jal	ra,ffffffffc0204772 <get_fd_array.part.0>

ffffffffc0204aa2 <file_open>:
ffffffffc0204aa2:	711d                	addi	sp,sp,-96
ffffffffc0204aa4:	ec86                	sd	ra,88(sp)
ffffffffc0204aa6:	e8a2                	sd	s0,80(sp)
ffffffffc0204aa8:	e4a6                	sd	s1,72(sp)
ffffffffc0204aaa:	e0ca                	sd	s2,64(sp)
ffffffffc0204aac:	fc4e                	sd	s3,56(sp)
ffffffffc0204aae:	f852                	sd	s4,48(sp)
ffffffffc0204ab0:	0035f793          	andi	a5,a1,3
ffffffffc0204ab4:	470d                	li	a4,3
ffffffffc0204ab6:	0ce78163          	beq	a5,a4,ffffffffc0204b78 <file_open+0xd6>
ffffffffc0204aba:	078e                	slli	a5,a5,0x3
ffffffffc0204abc:	00009717          	auipc	a4,0x9
ffffffffc0204ac0:	e3c70713          	addi	a4,a4,-452 # ffffffffc020d8f8 <CSWTCH.84>
ffffffffc0204ac4:	892a                	mv	s2,a0
ffffffffc0204ac6:	00009697          	auipc	a3,0x9
ffffffffc0204aca:	e1a68693          	addi	a3,a3,-486 # ffffffffc020d8e0 <CSWTCH.83>
ffffffffc0204ace:	755d                	lui	a0,0xffff7
ffffffffc0204ad0:	96be                	add	a3,a3,a5
ffffffffc0204ad2:	84ae                	mv	s1,a1
ffffffffc0204ad4:	97ba                	add	a5,a5,a4
ffffffffc0204ad6:	858a                	mv	a1,sp
ffffffffc0204ad8:	ad950513          	addi	a0,a0,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc0204adc:	0006ba03          	ld	s4,0(a3)
ffffffffc0204ae0:	0007b983          	ld	s3,0(a5)
ffffffffc0204ae4:	cb1ff0ef          	jal	ra,ffffffffc0204794 <fd_array_alloc>
ffffffffc0204ae8:	842a                	mv	s0,a0
ffffffffc0204aea:	c911                	beqz	a0,ffffffffc0204afe <file_open+0x5c>
ffffffffc0204aec:	60e6                	ld	ra,88(sp)
ffffffffc0204aee:	8522                	mv	a0,s0
ffffffffc0204af0:	6446                	ld	s0,80(sp)
ffffffffc0204af2:	64a6                	ld	s1,72(sp)
ffffffffc0204af4:	6906                	ld	s2,64(sp)
ffffffffc0204af6:	79e2                	ld	s3,56(sp)
ffffffffc0204af8:	7a42                	ld	s4,48(sp)
ffffffffc0204afa:	6125                	addi	sp,sp,96
ffffffffc0204afc:	8082                	ret
ffffffffc0204afe:	0030                	addi	a2,sp,8
ffffffffc0204b00:	85a6                	mv	a1,s1
ffffffffc0204b02:	854a                	mv	a0,s2
ffffffffc0204b04:	424030ef          	jal	ra,ffffffffc0207f28 <vfs_open>
ffffffffc0204b08:	842a                	mv	s0,a0
ffffffffc0204b0a:	e13d                	bnez	a0,ffffffffc0204b70 <file_open+0xce>
ffffffffc0204b0c:	6782                	ld	a5,0(sp)
ffffffffc0204b0e:	0204f493          	andi	s1,s1,32
ffffffffc0204b12:	6422                	ld	s0,8(sp)
ffffffffc0204b14:	0207b023          	sd	zero,32(a5)
ffffffffc0204b18:	c885                	beqz	s1,ffffffffc0204b48 <file_open+0xa6>
ffffffffc0204b1a:	c03d                	beqz	s0,ffffffffc0204b80 <file_open+0xde>
ffffffffc0204b1c:	783c                	ld	a5,112(s0)
ffffffffc0204b1e:	c3ad                	beqz	a5,ffffffffc0204b80 <file_open+0xde>
ffffffffc0204b20:	779c                	ld	a5,40(a5)
ffffffffc0204b22:	cfb9                	beqz	a5,ffffffffc0204b80 <file_open+0xde>
ffffffffc0204b24:	8522                	mv	a0,s0
ffffffffc0204b26:	00009597          	auipc	a1,0x9
ffffffffc0204b2a:	bea58593          	addi	a1,a1,-1046 # ffffffffc020d710 <default_pmm_manager+0xd40>
ffffffffc0204b2e:	517020ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0204b32:	783c                	ld	a5,112(s0)
ffffffffc0204b34:	6522                	ld	a0,8(sp)
ffffffffc0204b36:	080c                	addi	a1,sp,16
ffffffffc0204b38:	779c                	ld	a5,40(a5)
ffffffffc0204b3a:	9782                	jalr	a5
ffffffffc0204b3c:	842a                	mv	s0,a0
ffffffffc0204b3e:	e515                	bnez	a0,ffffffffc0204b6a <file_open+0xc8>
ffffffffc0204b40:	6782                	ld	a5,0(sp)
ffffffffc0204b42:	7722                	ld	a4,40(sp)
ffffffffc0204b44:	6422                	ld	s0,8(sp)
ffffffffc0204b46:	f398                	sd	a4,32(a5)
ffffffffc0204b48:	4394                	lw	a3,0(a5)
ffffffffc0204b4a:	f780                	sd	s0,40(a5)
ffffffffc0204b4c:	0147b423          	sd	s4,8(a5)
ffffffffc0204b50:	0137b823          	sd	s3,16(a5)
ffffffffc0204b54:	4705                	li	a4,1
ffffffffc0204b56:	02e69363          	bne	a3,a4,ffffffffc0204b7c <file_open+0xda>
ffffffffc0204b5a:	c00d                	beqz	s0,ffffffffc0204b7c <file_open+0xda>
ffffffffc0204b5c:	5b98                	lw	a4,48(a5)
ffffffffc0204b5e:	4689                	li	a3,2
ffffffffc0204b60:	4f80                	lw	s0,24(a5)
ffffffffc0204b62:	2705                	addiw	a4,a4,1
ffffffffc0204b64:	c394                	sw	a3,0(a5)
ffffffffc0204b66:	db98                	sw	a4,48(a5)
ffffffffc0204b68:	b751                	j	ffffffffc0204aec <file_open+0x4a>
ffffffffc0204b6a:	6522                	ld	a0,8(sp)
ffffffffc0204b6c:	562030ef          	jal	ra,ffffffffc02080ce <vfs_close>
ffffffffc0204b70:	6502                	ld	a0,0(sp)
ffffffffc0204b72:	cb7ff0ef          	jal	ra,ffffffffc0204828 <fd_array_free>
ffffffffc0204b76:	bf9d                	j	ffffffffc0204aec <file_open+0x4a>
ffffffffc0204b78:	5475                	li	s0,-3
ffffffffc0204b7a:	bf8d                	j	ffffffffc0204aec <file_open+0x4a>
ffffffffc0204b7c:	d93ff0ef          	jal	ra,ffffffffc020490e <fd_array_open.part.0>
ffffffffc0204b80:	00009697          	auipc	a3,0x9
ffffffffc0204b84:	b4068693          	addi	a3,a3,-1216 # ffffffffc020d6c0 <default_pmm_manager+0xcf0>
ffffffffc0204b88:	00007617          	auipc	a2,0x7
ffffffffc0204b8c:	36060613          	addi	a2,a2,864 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204b90:	0b500593          	li	a1,181
ffffffffc0204b94:	00009517          	auipc	a0,0x9
ffffffffc0204b98:	9f450513          	addi	a0,a0,-1548 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc0204b9c:	903fb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0204ba0 <file_close>:
ffffffffc0204ba0:	04700713          	li	a4,71
ffffffffc0204ba4:	04a76563          	bltu	a4,a0,ffffffffc0204bee <file_close+0x4e>
ffffffffc0204ba8:	00092717          	auipc	a4,0x92
ffffffffc0204bac:	d1873703          	ld	a4,-744(a4) # ffffffffc02968c0 <current>
ffffffffc0204bb0:	14873703          	ld	a4,328(a4)
ffffffffc0204bb4:	1141                	addi	sp,sp,-16
ffffffffc0204bb6:	e406                	sd	ra,8(sp)
ffffffffc0204bb8:	cf0d                	beqz	a4,ffffffffc0204bf2 <file_close+0x52>
ffffffffc0204bba:	4b14                	lw	a3,16(a4)
ffffffffc0204bbc:	02d05b63          	blez	a3,ffffffffc0204bf2 <file_close+0x52>
ffffffffc0204bc0:	6718                	ld	a4,8(a4)
ffffffffc0204bc2:	87aa                	mv	a5,a0
ffffffffc0204bc4:	050e                	slli	a0,a0,0x3
ffffffffc0204bc6:	8d1d                	sub	a0,a0,a5
ffffffffc0204bc8:	050e                	slli	a0,a0,0x3
ffffffffc0204bca:	953a                	add	a0,a0,a4
ffffffffc0204bcc:	4114                	lw	a3,0(a0)
ffffffffc0204bce:	4709                	li	a4,2
ffffffffc0204bd0:	00e69b63          	bne	a3,a4,ffffffffc0204be6 <file_close+0x46>
ffffffffc0204bd4:	4d18                	lw	a4,24(a0)
ffffffffc0204bd6:	00f71863          	bne	a4,a5,ffffffffc0204be6 <file_close+0x46>
ffffffffc0204bda:	d75ff0ef          	jal	ra,ffffffffc020494e <fd_array_close>
ffffffffc0204bde:	60a2                	ld	ra,8(sp)
ffffffffc0204be0:	4501                	li	a0,0
ffffffffc0204be2:	0141                	addi	sp,sp,16
ffffffffc0204be4:	8082                	ret
ffffffffc0204be6:	60a2                	ld	ra,8(sp)
ffffffffc0204be8:	5575                	li	a0,-3
ffffffffc0204bea:	0141                	addi	sp,sp,16
ffffffffc0204bec:	8082                	ret
ffffffffc0204bee:	5575                	li	a0,-3
ffffffffc0204bf0:	8082                	ret
ffffffffc0204bf2:	b81ff0ef          	jal	ra,ffffffffc0204772 <get_fd_array.part.0>

ffffffffc0204bf6 <file_read>:
ffffffffc0204bf6:	715d                	addi	sp,sp,-80
ffffffffc0204bf8:	e486                	sd	ra,72(sp)
ffffffffc0204bfa:	e0a2                	sd	s0,64(sp)
ffffffffc0204bfc:	fc26                	sd	s1,56(sp)
ffffffffc0204bfe:	f84a                	sd	s2,48(sp)
ffffffffc0204c00:	f44e                	sd	s3,40(sp)
ffffffffc0204c02:	f052                	sd	s4,32(sp)
ffffffffc0204c04:	0006b023          	sd	zero,0(a3)
ffffffffc0204c08:	04700793          	li	a5,71
ffffffffc0204c0c:	0aa7e463          	bltu	a5,a0,ffffffffc0204cb4 <file_read+0xbe>
ffffffffc0204c10:	00092797          	auipc	a5,0x92
ffffffffc0204c14:	cb07b783          	ld	a5,-848(a5) # ffffffffc02968c0 <current>
ffffffffc0204c18:	1487b783          	ld	a5,328(a5)
ffffffffc0204c1c:	cfd1                	beqz	a5,ffffffffc0204cb8 <file_read+0xc2>
ffffffffc0204c1e:	4b98                	lw	a4,16(a5)
ffffffffc0204c20:	08e05c63          	blez	a4,ffffffffc0204cb8 <file_read+0xc2>
ffffffffc0204c24:	6780                	ld	s0,8(a5)
ffffffffc0204c26:	00351793          	slli	a5,a0,0x3
ffffffffc0204c2a:	8f89                	sub	a5,a5,a0
ffffffffc0204c2c:	078e                	slli	a5,a5,0x3
ffffffffc0204c2e:	943e                	add	s0,s0,a5
ffffffffc0204c30:	00042983          	lw	s3,0(s0)
ffffffffc0204c34:	4789                	li	a5,2
ffffffffc0204c36:	06f99f63          	bne	s3,a5,ffffffffc0204cb4 <file_read+0xbe>
ffffffffc0204c3a:	4c1c                	lw	a5,24(s0)
ffffffffc0204c3c:	06a79c63          	bne	a5,a0,ffffffffc0204cb4 <file_read+0xbe>
ffffffffc0204c40:	641c                	ld	a5,8(s0)
ffffffffc0204c42:	cbad                	beqz	a5,ffffffffc0204cb4 <file_read+0xbe>
ffffffffc0204c44:	581c                	lw	a5,48(s0)
ffffffffc0204c46:	8a36                	mv	s4,a3
ffffffffc0204c48:	7014                	ld	a3,32(s0)
ffffffffc0204c4a:	2785                	addiw	a5,a5,1
ffffffffc0204c4c:	850a                	mv	a0,sp
ffffffffc0204c4e:	d81c                	sw	a5,48(s0)
ffffffffc0204c50:	792000ef          	jal	ra,ffffffffc02053e2 <iobuf_init>
ffffffffc0204c54:	02843903          	ld	s2,40(s0)
ffffffffc0204c58:	84aa                	mv	s1,a0
ffffffffc0204c5a:	06090163          	beqz	s2,ffffffffc0204cbc <file_read+0xc6>
ffffffffc0204c5e:	07093783          	ld	a5,112(s2)
ffffffffc0204c62:	cfa9                	beqz	a5,ffffffffc0204cbc <file_read+0xc6>
ffffffffc0204c64:	6f9c                	ld	a5,24(a5)
ffffffffc0204c66:	cbb9                	beqz	a5,ffffffffc0204cbc <file_read+0xc6>
ffffffffc0204c68:	00009597          	auipc	a1,0x9
ffffffffc0204c6c:	b0058593          	addi	a1,a1,-1280 # ffffffffc020d768 <default_pmm_manager+0xd98>
ffffffffc0204c70:	854a                	mv	a0,s2
ffffffffc0204c72:	3d3020ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0204c76:	07093783          	ld	a5,112(s2)
ffffffffc0204c7a:	7408                	ld	a0,40(s0)
ffffffffc0204c7c:	85a6                	mv	a1,s1
ffffffffc0204c7e:	6f9c                	ld	a5,24(a5)
ffffffffc0204c80:	9782                	jalr	a5
ffffffffc0204c82:	689c                	ld	a5,16(s1)
ffffffffc0204c84:	6c94                	ld	a3,24(s1)
ffffffffc0204c86:	4018                	lw	a4,0(s0)
ffffffffc0204c88:	84aa                	mv	s1,a0
ffffffffc0204c8a:	8f95                	sub	a5,a5,a3
ffffffffc0204c8c:	03370063          	beq	a4,s3,ffffffffc0204cac <file_read+0xb6>
ffffffffc0204c90:	00fa3023          	sd	a5,0(s4) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc0204c94:	8522                	mv	a0,s0
ffffffffc0204c96:	c0fff0ef          	jal	ra,ffffffffc02048a4 <fd_array_release>
ffffffffc0204c9a:	60a6                	ld	ra,72(sp)
ffffffffc0204c9c:	6406                	ld	s0,64(sp)
ffffffffc0204c9e:	7942                	ld	s2,48(sp)
ffffffffc0204ca0:	79a2                	ld	s3,40(sp)
ffffffffc0204ca2:	7a02                	ld	s4,32(sp)
ffffffffc0204ca4:	8526                	mv	a0,s1
ffffffffc0204ca6:	74e2                	ld	s1,56(sp)
ffffffffc0204ca8:	6161                	addi	sp,sp,80
ffffffffc0204caa:	8082                	ret
ffffffffc0204cac:	7018                	ld	a4,32(s0)
ffffffffc0204cae:	973e                	add	a4,a4,a5
ffffffffc0204cb0:	f018                	sd	a4,32(s0)
ffffffffc0204cb2:	bff9                	j	ffffffffc0204c90 <file_read+0x9a>
ffffffffc0204cb4:	54f5                	li	s1,-3
ffffffffc0204cb6:	b7d5                	j	ffffffffc0204c9a <file_read+0xa4>
ffffffffc0204cb8:	abbff0ef          	jal	ra,ffffffffc0204772 <get_fd_array.part.0>
ffffffffc0204cbc:	00009697          	auipc	a3,0x9
ffffffffc0204cc0:	a5c68693          	addi	a3,a3,-1444 # ffffffffc020d718 <default_pmm_manager+0xd48>
ffffffffc0204cc4:	00007617          	auipc	a2,0x7
ffffffffc0204cc8:	22460613          	addi	a2,a2,548 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204ccc:	0de00593          	li	a1,222
ffffffffc0204cd0:	00009517          	auipc	a0,0x9
ffffffffc0204cd4:	8b850513          	addi	a0,a0,-1864 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc0204cd8:	fc6fb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0204cdc <file_write>:
ffffffffc0204cdc:	715d                	addi	sp,sp,-80
ffffffffc0204cde:	e486                	sd	ra,72(sp)
ffffffffc0204ce0:	e0a2                	sd	s0,64(sp)
ffffffffc0204ce2:	fc26                	sd	s1,56(sp)
ffffffffc0204ce4:	f84a                	sd	s2,48(sp)
ffffffffc0204ce6:	f44e                	sd	s3,40(sp)
ffffffffc0204ce8:	f052                	sd	s4,32(sp)
ffffffffc0204cea:	0006b023          	sd	zero,0(a3)
ffffffffc0204cee:	04700793          	li	a5,71
ffffffffc0204cf2:	0aa7e463          	bltu	a5,a0,ffffffffc0204d9a <file_write+0xbe>
ffffffffc0204cf6:	00092797          	auipc	a5,0x92
ffffffffc0204cfa:	bca7b783          	ld	a5,-1078(a5) # ffffffffc02968c0 <current>
ffffffffc0204cfe:	1487b783          	ld	a5,328(a5)
ffffffffc0204d02:	cfd1                	beqz	a5,ffffffffc0204d9e <file_write+0xc2>
ffffffffc0204d04:	4b98                	lw	a4,16(a5)
ffffffffc0204d06:	08e05c63          	blez	a4,ffffffffc0204d9e <file_write+0xc2>
ffffffffc0204d0a:	6780                	ld	s0,8(a5)
ffffffffc0204d0c:	00351793          	slli	a5,a0,0x3
ffffffffc0204d10:	8f89                	sub	a5,a5,a0
ffffffffc0204d12:	078e                	slli	a5,a5,0x3
ffffffffc0204d14:	943e                	add	s0,s0,a5
ffffffffc0204d16:	00042983          	lw	s3,0(s0)
ffffffffc0204d1a:	4789                	li	a5,2
ffffffffc0204d1c:	06f99f63          	bne	s3,a5,ffffffffc0204d9a <file_write+0xbe>
ffffffffc0204d20:	4c1c                	lw	a5,24(s0)
ffffffffc0204d22:	06a79c63          	bne	a5,a0,ffffffffc0204d9a <file_write+0xbe>
ffffffffc0204d26:	681c                	ld	a5,16(s0)
ffffffffc0204d28:	cbad                	beqz	a5,ffffffffc0204d9a <file_write+0xbe>
ffffffffc0204d2a:	581c                	lw	a5,48(s0)
ffffffffc0204d2c:	8a36                	mv	s4,a3
ffffffffc0204d2e:	7014                	ld	a3,32(s0)
ffffffffc0204d30:	2785                	addiw	a5,a5,1
ffffffffc0204d32:	850a                	mv	a0,sp
ffffffffc0204d34:	d81c                	sw	a5,48(s0)
ffffffffc0204d36:	6ac000ef          	jal	ra,ffffffffc02053e2 <iobuf_init>
ffffffffc0204d3a:	02843903          	ld	s2,40(s0)
ffffffffc0204d3e:	84aa                	mv	s1,a0
ffffffffc0204d40:	06090163          	beqz	s2,ffffffffc0204da2 <file_write+0xc6>
ffffffffc0204d44:	07093783          	ld	a5,112(s2)
ffffffffc0204d48:	cfa9                	beqz	a5,ffffffffc0204da2 <file_write+0xc6>
ffffffffc0204d4a:	739c                	ld	a5,32(a5)
ffffffffc0204d4c:	cbb9                	beqz	a5,ffffffffc0204da2 <file_write+0xc6>
ffffffffc0204d4e:	00009597          	auipc	a1,0x9
ffffffffc0204d52:	a7258593          	addi	a1,a1,-1422 # ffffffffc020d7c0 <default_pmm_manager+0xdf0>
ffffffffc0204d56:	854a                	mv	a0,s2
ffffffffc0204d58:	2ed020ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0204d5c:	07093783          	ld	a5,112(s2)
ffffffffc0204d60:	7408                	ld	a0,40(s0)
ffffffffc0204d62:	85a6                	mv	a1,s1
ffffffffc0204d64:	739c                	ld	a5,32(a5)
ffffffffc0204d66:	9782                	jalr	a5
ffffffffc0204d68:	689c                	ld	a5,16(s1)
ffffffffc0204d6a:	6c94                	ld	a3,24(s1)
ffffffffc0204d6c:	4018                	lw	a4,0(s0)
ffffffffc0204d6e:	84aa                	mv	s1,a0
ffffffffc0204d70:	8f95                	sub	a5,a5,a3
ffffffffc0204d72:	03370063          	beq	a4,s3,ffffffffc0204d92 <file_write+0xb6>
ffffffffc0204d76:	00fa3023          	sd	a5,0(s4)
ffffffffc0204d7a:	8522                	mv	a0,s0
ffffffffc0204d7c:	b29ff0ef          	jal	ra,ffffffffc02048a4 <fd_array_release>
ffffffffc0204d80:	60a6                	ld	ra,72(sp)
ffffffffc0204d82:	6406                	ld	s0,64(sp)
ffffffffc0204d84:	7942                	ld	s2,48(sp)
ffffffffc0204d86:	79a2                	ld	s3,40(sp)
ffffffffc0204d88:	7a02                	ld	s4,32(sp)
ffffffffc0204d8a:	8526                	mv	a0,s1
ffffffffc0204d8c:	74e2                	ld	s1,56(sp)
ffffffffc0204d8e:	6161                	addi	sp,sp,80
ffffffffc0204d90:	8082                	ret
ffffffffc0204d92:	7018                	ld	a4,32(s0)
ffffffffc0204d94:	973e                	add	a4,a4,a5
ffffffffc0204d96:	f018                	sd	a4,32(s0)
ffffffffc0204d98:	bff9                	j	ffffffffc0204d76 <file_write+0x9a>
ffffffffc0204d9a:	54f5                	li	s1,-3
ffffffffc0204d9c:	b7d5                	j	ffffffffc0204d80 <file_write+0xa4>
ffffffffc0204d9e:	9d5ff0ef          	jal	ra,ffffffffc0204772 <get_fd_array.part.0>
ffffffffc0204da2:	00009697          	auipc	a3,0x9
ffffffffc0204da6:	9ce68693          	addi	a3,a3,-1586 # ffffffffc020d770 <default_pmm_manager+0xda0>
ffffffffc0204daa:	00007617          	auipc	a2,0x7
ffffffffc0204dae:	13e60613          	addi	a2,a2,318 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204db2:	0f800593          	li	a1,248
ffffffffc0204db6:	00008517          	auipc	a0,0x8
ffffffffc0204dba:	7d250513          	addi	a0,a0,2002 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc0204dbe:	ee0fb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0204dc2 <file_seek>:
ffffffffc0204dc2:	7139                	addi	sp,sp,-64
ffffffffc0204dc4:	fc06                	sd	ra,56(sp)
ffffffffc0204dc6:	f822                	sd	s0,48(sp)
ffffffffc0204dc8:	f426                	sd	s1,40(sp)
ffffffffc0204dca:	f04a                	sd	s2,32(sp)
ffffffffc0204dcc:	04700793          	li	a5,71
ffffffffc0204dd0:	08a7e863          	bltu	a5,a0,ffffffffc0204e60 <file_seek+0x9e>
ffffffffc0204dd4:	00092797          	auipc	a5,0x92
ffffffffc0204dd8:	aec7b783          	ld	a5,-1300(a5) # ffffffffc02968c0 <current>
ffffffffc0204ddc:	1487b783          	ld	a5,328(a5)
ffffffffc0204de0:	cfdd                	beqz	a5,ffffffffc0204e9e <file_seek+0xdc>
ffffffffc0204de2:	4b98                	lw	a4,16(a5)
ffffffffc0204de4:	0ae05d63          	blez	a4,ffffffffc0204e9e <file_seek+0xdc>
ffffffffc0204de8:	6780                	ld	s0,8(a5)
ffffffffc0204dea:	00351793          	slli	a5,a0,0x3
ffffffffc0204dee:	8f89                	sub	a5,a5,a0
ffffffffc0204df0:	078e                	slli	a5,a5,0x3
ffffffffc0204df2:	943e                	add	s0,s0,a5
ffffffffc0204df4:	4018                	lw	a4,0(s0)
ffffffffc0204df6:	4789                	li	a5,2
ffffffffc0204df8:	06f71463          	bne	a4,a5,ffffffffc0204e60 <file_seek+0x9e>
ffffffffc0204dfc:	4c1c                	lw	a5,24(s0)
ffffffffc0204dfe:	06a79163          	bne	a5,a0,ffffffffc0204e60 <file_seek+0x9e>
ffffffffc0204e02:	581c                	lw	a5,48(s0)
ffffffffc0204e04:	4685                	li	a3,1
ffffffffc0204e06:	892e                	mv	s2,a1
ffffffffc0204e08:	2785                	addiw	a5,a5,1
ffffffffc0204e0a:	d81c                	sw	a5,48(s0)
ffffffffc0204e0c:	02d60063          	beq	a2,a3,ffffffffc0204e2c <file_seek+0x6a>
ffffffffc0204e10:	06e60063          	beq	a2,a4,ffffffffc0204e70 <file_seek+0xae>
ffffffffc0204e14:	54f5                	li	s1,-3
ffffffffc0204e16:	ce11                	beqz	a2,ffffffffc0204e32 <file_seek+0x70>
ffffffffc0204e18:	8522                	mv	a0,s0
ffffffffc0204e1a:	a8bff0ef          	jal	ra,ffffffffc02048a4 <fd_array_release>
ffffffffc0204e1e:	70e2                	ld	ra,56(sp)
ffffffffc0204e20:	7442                	ld	s0,48(sp)
ffffffffc0204e22:	7902                	ld	s2,32(sp)
ffffffffc0204e24:	8526                	mv	a0,s1
ffffffffc0204e26:	74a2                	ld	s1,40(sp)
ffffffffc0204e28:	6121                	addi	sp,sp,64
ffffffffc0204e2a:	8082                	ret
ffffffffc0204e2c:	701c                	ld	a5,32(s0)
ffffffffc0204e2e:	00f58933          	add	s2,a1,a5
ffffffffc0204e32:	7404                	ld	s1,40(s0)
ffffffffc0204e34:	c4bd                	beqz	s1,ffffffffc0204ea2 <file_seek+0xe0>
ffffffffc0204e36:	78bc                	ld	a5,112(s1)
ffffffffc0204e38:	c7ad                	beqz	a5,ffffffffc0204ea2 <file_seek+0xe0>
ffffffffc0204e3a:	6fbc                	ld	a5,88(a5)
ffffffffc0204e3c:	c3bd                	beqz	a5,ffffffffc0204ea2 <file_seek+0xe0>
ffffffffc0204e3e:	8526                	mv	a0,s1
ffffffffc0204e40:	00009597          	auipc	a1,0x9
ffffffffc0204e44:	9d858593          	addi	a1,a1,-1576 # ffffffffc020d818 <default_pmm_manager+0xe48>
ffffffffc0204e48:	1fd020ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0204e4c:	78bc                	ld	a5,112(s1)
ffffffffc0204e4e:	7408                	ld	a0,40(s0)
ffffffffc0204e50:	85ca                	mv	a1,s2
ffffffffc0204e52:	6fbc                	ld	a5,88(a5)
ffffffffc0204e54:	9782                	jalr	a5
ffffffffc0204e56:	84aa                	mv	s1,a0
ffffffffc0204e58:	f161                	bnez	a0,ffffffffc0204e18 <file_seek+0x56>
ffffffffc0204e5a:	03243023          	sd	s2,32(s0)
ffffffffc0204e5e:	bf6d                	j	ffffffffc0204e18 <file_seek+0x56>
ffffffffc0204e60:	70e2                	ld	ra,56(sp)
ffffffffc0204e62:	7442                	ld	s0,48(sp)
ffffffffc0204e64:	54f5                	li	s1,-3
ffffffffc0204e66:	7902                	ld	s2,32(sp)
ffffffffc0204e68:	8526                	mv	a0,s1
ffffffffc0204e6a:	74a2                	ld	s1,40(sp)
ffffffffc0204e6c:	6121                	addi	sp,sp,64
ffffffffc0204e6e:	8082                	ret
ffffffffc0204e70:	7404                	ld	s1,40(s0)
ffffffffc0204e72:	c8a1                	beqz	s1,ffffffffc0204ec2 <file_seek+0x100>
ffffffffc0204e74:	78bc                	ld	a5,112(s1)
ffffffffc0204e76:	c7b1                	beqz	a5,ffffffffc0204ec2 <file_seek+0x100>
ffffffffc0204e78:	779c                	ld	a5,40(a5)
ffffffffc0204e7a:	c7a1                	beqz	a5,ffffffffc0204ec2 <file_seek+0x100>
ffffffffc0204e7c:	8526                	mv	a0,s1
ffffffffc0204e7e:	00009597          	auipc	a1,0x9
ffffffffc0204e82:	89258593          	addi	a1,a1,-1902 # ffffffffc020d710 <default_pmm_manager+0xd40>
ffffffffc0204e86:	1bf020ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0204e8a:	78bc                	ld	a5,112(s1)
ffffffffc0204e8c:	7408                	ld	a0,40(s0)
ffffffffc0204e8e:	858a                	mv	a1,sp
ffffffffc0204e90:	779c                	ld	a5,40(a5)
ffffffffc0204e92:	9782                	jalr	a5
ffffffffc0204e94:	84aa                	mv	s1,a0
ffffffffc0204e96:	f149                	bnez	a0,ffffffffc0204e18 <file_seek+0x56>
ffffffffc0204e98:	67e2                	ld	a5,24(sp)
ffffffffc0204e9a:	993e                	add	s2,s2,a5
ffffffffc0204e9c:	bf59                	j	ffffffffc0204e32 <file_seek+0x70>
ffffffffc0204e9e:	8d5ff0ef          	jal	ra,ffffffffc0204772 <get_fd_array.part.0>
ffffffffc0204ea2:	00009697          	auipc	a3,0x9
ffffffffc0204ea6:	92668693          	addi	a3,a3,-1754 # ffffffffc020d7c8 <default_pmm_manager+0xdf8>
ffffffffc0204eaa:	00007617          	auipc	a2,0x7
ffffffffc0204eae:	03e60613          	addi	a2,a2,62 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204eb2:	11a00593          	li	a1,282
ffffffffc0204eb6:	00008517          	auipc	a0,0x8
ffffffffc0204eba:	6d250513          	addi	a0,a0,1746 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc0204ebe:	de0fb0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0204ec2:	00008697          	auipc	a3,0x8
ffffffffc0204ec6:	7fe68693          	addi	a3,a3,2046 # ffffffffc020d6c0 <default_pmm_manager+0xcf0>
ffffffffc0204eca:	00007617          	auipc	a2,0x7
ffffffffc0204ece:	01e60613          	addi	a2,a2,30 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204ed2:	11200593          	li	a1,274
ffffffffc0204ed6:	00008517          	auipc	a0,0x8
ffffffffc0204eda:	6b250513          	addi	a0,a0,1714 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc0204ede:	dc0fb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0204ee2 <file_fstat>:
ffffffffc0204ee2:	1101                	addi	sp,sp,-32
ffffffffc0204ee4:	ec06                	sd	ra,24(sp)
ffffffffc0204ee6:	e822                	sd	s0,16(sp)
ffffffffc0204ee8:	e426                	sd	s1,8(sp)
ffffffffc0204eea:	e04a                	sd	s2,0(sp)
ffffffffc0204eec:	04700793          	li	a5,71
ffffffffc0204ef0:	06a7ef63          	bltu	a5,a0,ffffffffc0204f6e <file_fstat+0x8c>
ffffffffc0204ef4:	00092797          	auipc	a5,0x92
ffffffffc0204ef8:	9cc7b783          	ld	a5,-1588(a5) # ffffffffc02968c0 <current>
ffffffffc0204efc:	1487b783          	ld	a5,328(a5)
ffffffffc0204f00:	cfd9                	beqz	a5,ffffffffc0204f9e <file_fstat+0xbc>
ffffffffc0204f02:	4b98                	lw	a4,16(a5)
ffffffffc0204f04:	08e05d63          	blez	a4,ffffffffc0204f9e <file_fstat+0xbc>
ffffffffc0204f08:	6780                	ld	s0,8(a5)
ffffffffc0204f0a:	00351793          	slli	a5,a0,0x3
ffffffffc0204f0e:	8f89                	sub	a5,a5,a0
ffffffffc0204f10:	078e                	slli	a5,a5,0x3
ffffffffc0204f12:	943e                	add	s0,s0,a5
ffffffffc0204f14:	4018                	lw	a4,0(s0)
ffffffffc0204f16:	4789                	li	a5,2
ffffffffc0204f18:	04f71b63          	bne	a4,a5,ffffffffc0204f6e <file_fstat+0x8c>
ffffffffc0204f1c:	4c1c                	lw	a5,24(s0)
ffffffffc0204f1e:	04a79863          	bne	a5,a0,ffffffffc0204f6e <file_fstat+0x8c>
ffffffffc0204f22:	581c                	lw	a5,48(s0)
ffffffffc0204f24:	02843903          	ld	s2,40(s0)
ffffffffc0204f28:	2785                	addiw	a5,a5,1
ffffffffc0204f2a:	d81c                	sw	a5,48(s0)
ffffffffc0204f2c:	04090963          	beqz	s2,ffffffffc0204f7e <file_fstat+0x9c>
ffffffffc0204f30:	07093783          	ld	a5,112(s2)
ffffffffc0204f34:	c7a9                	beqz	a5,ffffffffc0204f7e <file_fstat+0x9c>
ffffffffc0204f36:	779c                	ld	a5,40(a5)
ffffffffc0204f38:	c3b9                	beqz	a5,ffffffffc0204f7e <file_fstat+0x9c>
ffffffffc0204f3a:	84ae                	mv	s1,a1
ffffffffc0204f3c:	854a                	mv	a0,s2
ffffffffc0204f3e:	00008597          	auipc	a1,0x8
ffffffffc0204f42:	7d258593          	addi	a1,a1,2002 # ffffffffc020d710 <default_pmm_manager+0xd40>
ffffffffc0204f46:	0ff020ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0204f4a:	07093783          	ld	a5,112(s2)
ffffffffc0204f4e:	7408                	ld	a0,40(s0)
ffffffffc0204f50:	85a6                	mv	a1,s1
ffffffffc0204f52:	779c                	ld	a5,40(a5)
ffffffffc0204f54:	9782                	jalr	a5
ffffffffc0204f56:	87aa                	mv	a5,a0
ffffffffc0204f58:	8522                	mv	a0,s0
ffffffffc0204f5a:	843e                	mv	s0,a5
ffffffffc0204f5c:	949ff0ef          	jal	ra,ffffffffc02048a4 <fd_array_release>
ffffffffc0204f60:	60e2                	ld	ra,24(sp)
ffffffffc0204f62:	8522                	mv	a0,s0
ffffffffc0204f64:	6442                	ld	s0,16(sp)
ffffffffc0204f66:	64a2                	ld	s1,8(sp)
ffffffffc0204f68:	6902                	ld	s2,0(sp)
ffffffffc0204f6a:	6105                	addi	sp,sp,32
ffffffffc0204f6c:	8082                	ret
ffffffffc0204f6e:	5475                	li	s0,-3
ffffffffc0204f70:	60e2                	ld	ra,24(sp)
ffffffffc0204f72:	8522                	mv	a0,s0
ffffffffc0204f74:	6442                	ld	s0,16(sp)
ffffffffc0204f76:	64a2                	ld	s1,8(sp)
ffffffffc0204f78:	6902                	ld	s2,0(sp)
ffffffffc0204f7a:	6105                	addi	sp,sp,32
ffffffffc0204f7c:	8082                	ret
ffffffffc0204f7e:	00008697          	auipc	a3,0x8
ffffffffc0204f82:	74268693          	addi	a3,a3,1858 # ffffffffc020d6c0 <default_pmm_manager+0xcf0>
ffffffffc0204f86:	00007617          	auipc	a2,0x7
ffffffffc0204f8a:	f6260613          	addi	a2,a2,-158 # ffffffffc020bee8 <commands+0x210>
ffffffffc0204f8e:	12c00593          	li	a1,300
ffffffffc0204f92:	00008517          	auipc	a0,0x8
ffffffffc0204f96:	5f650513          	addi	a0,a0,1526 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc0204f9a:	d04fb0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0204f9e:	fd4ff0ef          	jal	ra,ffffffffc0204772 <get_fd_array.part.0>

ffffffffc0204fa2 <file_fsync>:
ffffffffc0204fa2:	1101                	addi	sp,sp,-32
ffffffffc0204fa4:	ec06                	sd	ra,24(sp)
ffffffffc0204fa6:	e822                	sd	s0,16(sp)
ffffffffc0204fa8:	e426                	sd	s1,8(sp)
ffffffffc0204faa:	04700793          	li	a5,71
ffffffffc0204fae:	06a7e863          	bltu	a5,a0,ffffffffc020501e <file_fsync+0x7c>
ffffffffc0204fb2:	00092797          	auipc	a5,0x92
ffffffffc0204fb6:	90e7b783          	ld	a5,-1778(a5) # ffffffffc02968c0 <current>
ffffffffc0204fba:	1487b783          	ld	a5,328(a5)
ffffffffc0204fbe:	c7d9                	beqz	a5,ffffffffc020504c <file_fsync+0xaa>
ffffffffc0204fc0:	4b98                	lw	a4,16(a5)
ffffffffc0204fc2:	08e05563          	blez	a4,ffffffffc020504c <file_fsync+0xaa>
ffffffffc0204fc6:	6780                	ld	s0,8(a5)
ffffffffc0204fc8:	00351793          	slli	a5,a0,0x3
ffffffffc0204fcc:	8f89                	sub	a5,a5,a0
ffffffffc0204fce:	078e                	slli	a5,a5,0x3
ffffffffc0204fd0:	943e                	add	s0,s0,a5
ffffffffc0204fd2:	4018                	lw	a4,0(s0)
ffffffffc0204fd4:	4789                	li	a5,2
ffffffffc0204fd6:	04f71463          	bne	a4,a5,ffffffffc020501e <file_fsync+0x7c>
ffffffffc0204fda:	4c1c                	lw	a5,24(s0)
ffffffffc0204fdc:	04a79163          	bne	a5,a0,ffffffffc020501e <file_fsync+0x7c>
ffffffffc0204fe0:	581c                	lw	a5,48(s0)
ffffffffc0204fe2:	7404                	ld	s1,40(s0)
ffffffffc0204fe4:	2785                	addiw	a5,a5,1
ffffffffc0204fe6:	d81c                	sw	a5,48(s0)
ffffffffc0204fe8:	c0b1                	beqz	s1,ffffffffc020502c <file_fsync+0x8a>
ffffffffc0204fea:	78bc                	ld	a5,112(s1)
ffffffffc0204fec:	c3a1                	beqz	a5,ffffffffc020502c <file_fsync+0x8a>
ffffffffc0204fee:	7b9c                	ld	a5,48(a5)
ffffffffc0204ff0:	cf95                	beqz	a5,ffffffffc020502c <file_fsync+0x8a>
ffffffffc0204ff2:	00009597          	auipc	a1,0x9
ffffffffc0204ff6:	87e58593          	addi	a1,a1,-1922 # ffffffffc020d870 <default_pmm_manager+0xea0>
ffffffffc0204ffa:	8526                	mv	a0,s1
ffffffffc0204ffc:	049020ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0205000:	78bc                	ld	a5,112(s1)
ffffffffc0205002:	7408                	ld	a0,40(s0)
ffffffffc0205004:	7b9c                	ld	a5,48(a5)
ffffffffc0205006:	9782                	jalr	a5
ffffffffc0205008:	87aa                	mv	a5,a0
ffffffffc020500a:	8522                	mv	a0,s0
ffffffffc020500c:	843e                	mv	s0,a5
ffffffffc020500e:	897ff0ef          	jal	ra,ffffffffc02048a4 <fd_array_release>
ffffffffc0205012:	60e2                	ld	ra,24(sp)
ffffffffc0205014:	8522                	mv	a0,s0
ffffffffc0205016:	6442                	ld	s0,16(sp)
ffffffffc0205018:	64a2                	ld	s1,8(sp)
ffffffffc020501a:	6105                	addi	sp,sp,32
ffffffffc020501c:	8082                	ret
ffffffffc020501e:	5475                	li	s0,-3
ffffffffc0205020:	60e2                	ld	ra,24(sp)
ffffffffc0205022:	8522                	mv	a0,s0
ffffffffc0205024:	6442                	ld	s0,16(sp)
ffffffffc0205026:	64a2                	ld	s1,8(sp)
ffffffffc0205028:	6105                	addi	sp,sp,32
ffffffffc020502a:	8082                	ret
ffffffffc020502c:	00008697          	auipc	a3,0x8
ffffffffc0205030:	7f468693          	addi	a3,a3,2036 # ffffffffc020d820 <default_pmm_manager+0xe50>
ffffffffc0205034:	00007617          	auipc	a2,0x7
ffffffffc0205038:	eb460613          	addi	a2,a2,-332 # ffffffffc020bee8 <commands+0x210>
ffffffffc020503c:	13a00593          	li	a1,314
ffffffffc0205040:	00008517          	auipc	a0,0x8
ffffffffc0205044:	54850513          	addi	a0,a0,1352 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc0205048:	c56fb0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020504c:	f26ff0ef          	jal	ra,ffffffffc0204772 <get_fd_array.part.0>

ffffffffc0205050 <file_getdirentry>:
ffffffffc0205050:	715d                	addi	sp,sp,-80
ffffffffc0205052:	e486                	sd	ra,72(sp)
ffffffffc0205054:	e0a2                	sd	s0,64(sp)
ffffffffc0205056:	fc26                	sd	s1,56(sp)
ffffffffc0205058:	f84a                	sd	s2,48(sp)
ffffffffc020505a:	f44e                	sd	s3,40(sp)
ffffffffc020505c:	04700793          	li	a5,71
ffffffffc0205060:	0aa7e063          	bltu	a5,a0,ffffffffc0205100 <file_getdirentry+0xb0>
ffffffffc0205064:	00092797          	auipc	a5,0x92
ffffffffc0205068:	85c7b783          	ld	a5,-1956(a5) # ffffffffc02968c0 <current>
ffffffffc020506c:	1487b783          	ld	a5,328(a5)
ffffffffc0205070:	c3e9                	beqz	a5,ffffffffc0205132 <file_getdirentry+0xe2>
ffffffffc0205072:	4b98                	lw	a4,16(a5)
ffffffffc0205074:	0ae05f63          	blez	a4,ffffffffc0205132 <file_getdirentry+0xe2>
ffffffffc0205078:	6780                	ld	s0,8(a5)
ffffffffc020507a:	00351793          	slli	a5,a0,0x3
ffffffffc020507e:	8f89                	sub	a5,a5,a0
ffffffffc0205080:	078e                	slli	a5,a5,0x3
ffffffffc0205082:	943e                	add	s0,s0,a5
ffffffffc0205084:	4018                	lw	a4,0(s0)
ffffffffc0205086:	4789                	li	a5,2
ffffffffc0205088:	06f71c63          	bne	a4,a5,ffffffffc0205100 <file_getdirentry+0xb0>
ffffffffc020508c:	4c1c                	lw	a5,24(s0)
ffffffffc020508e:	06a79963          	bne	a5,a0,ffffffffc0205100 <file_getdirentry+0xb0>
ffffffffc0205092:	581c                	lw	a5,48(s0)
ffffffffc0205094:	6194                	ld	a3,0(a1)
ffffffffc0205096:	84ae                	mv	s1,a1
ffffffffc0205098:	2785                	addiw	a5,a5,1
ffffffffc020509a:	10000613          	li	a2,256
ffffffffc020509e:	d81c                	sw	a5,48(s0)
ffffffffc02050a0:	05a1                	addi	a1,a1,8
ffffffffc02050a2:	850a                	mv	a0,sp
ffffffffc02050a4:	33e000ef          	jal	ra,ffffffffc02053e2 <iobuf_init>
ffffffffc02050a8:	02843983          	ld	s3,40(s0)
ffffffffc02050ac:	892a                	mv	s2,a0
ffffffffc02050ae:	06098263          	beqz	s3,ffffffffc0205112 <file_getdirentry+0xc2>
ffffffffc02050b2:	0709b783          	ld	a5,112(s3) # 1070 <_binary_bin_swap_img_size-0x6c90>
ffffffffc02050b6:	cfb1                	beqz	a5,ffffffffc0205112 <file_getdirentry+0xc2>
ffffffffc02050b8:	63bc                	ld	a5,64(a5)
ffffffffc02050ba:	cfa1                	beqz	a5,ffffffffc0205112 <file_getdirentry+0xc2>
ffffffffc02050bc:	854e                	mv	a0,s3
ffffffffc02050be:	00009597          	auipc	a1,0x9
ffffffffc02050c2:	81258593          	addi	a1,a1,-2030 # ffffffffc020d8d0 <default_pmm_manager+0xf00>
ffffffffc02050c6:	77e020ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc02050ca:	0709b783          	ld	a5,112(s3)
ffffffffc02050ce:	7408                	ld	a0,40(s0)
ffffffffc02050d0:	85ca                	mv	a1,s2
ffffffffc02050d2:	63bc                	ld	a5,64(a5)
ffffffffc02050d4:	9782                	jalr	a5
ffffffffc02050d6:	89aa                	mv	s3,a0
ffffffffc02050d8:	e909                	bnez	a0,ffffffffc02050ea <file_getdirentry+0x9a>
ffffffffc02050da:	609c                	ld	a5,0(s1)
ffffffffc02050dc:	01093683          	ld	a3,16(s2)
ffffffffc02050e0:	01893703          	ld	a4,24(s2)
ffffffffc02050e4:	97b6                	add	a5,a5,a3
ffffffffc02050e6:	8f99                	sub	a5,a5,a4
ffffffffc02050e8:	e09c                	sd	a5,0(s1)
ffffffffc02050ea:	8522                	mv	a0,s0
ffffffffc02050ec:	fb8ff0ef          	jal	ra,ffffffffc02048a4 <fd_array_release>
ffffffffc02050f0:	60a6                	ld	ra,72(sp)
ffffffffc02050f2:	6406                	ld	s0,64(sp)
ffffffffc02050f4:	74e2                	ld	s1,56(sp)
ffffffffc02050f6:	7942                	ld	s2,48(sp)
ffffffffc02050f8:	854e                	mv	a0,s3
ffffffffc02050fa:	79a2                	ld	s3,40(sp)
ffffffffc02050fc:	6161                	addi	sp,sp,80
ffffffffc02050fe:	8082                	ret
ffffffffc0205100:	60a6                	ld	ra,72(sp)
ffffffffc0205102:	6406                	ld	s0,64(sp)
ffffffffc0205104:	59f5                	li	s3,-3
ffffffffc0205106:	74e2                	ld	s1,56(sp)
ffffffffc0205108:	7942                	ld	s2,48(sp)
ffffffffc020510a:	854e                	mv	a0,s3
ffffffffc020510c:	79a2                	ld	s3,40(sp)
ffffffffc020510e:	6161                	addi	sp,sp,80
ffffffffc0205110:	8082                	ret
ffffffffc0205112:	00008697          	auipc	a3,0x8
ffffffffc0205116:	76668693          	addi	a3,a3,1894 # ffffffffc020d878 <default_pmm_manager+0xea8>
ffffffffc020511a:	00007617          	auipc	a2,0x7
ffffffffc020511e:	dce60613          	addi	a2,a2,-562 # ffffffffc020bee8 <commands+0x210>
ffffffffc0205122:	14a00593          	li	a1,330
ffffffffc0205126:	00008517          	auipc	a0,0x8
ffffffffc020512a:	46250513          	addi	a0,a0,1122 # ffffffffc020d588 <default_pmm_manager+0xbb8>
ffffffffc020512e:	b70fb0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0205132:	e40ff0ef          	jal	ra,ffffffffc0204772 <get_fd_array.part.0>

ffffffffc0205136 <file_dup>:
ffffffffc0205136:	04700713          	li	a4,71
ffffffffc020513a:	06a76463          	bltu	a4,a0,ffffffffc02051a2 <file_dup+0x6c>
ffffffffc020513e:	00091717          	auipc	a4,0x91
ffffffffc0205142:	78273703          	ld	a4,1922(a4) # ffffffffc02968c0 <current>
ffffffffc0205146:	14873703          	ld	a4,328(a4)
ffffffffc020514a:	1101                	addi	sp,sp,-32
ffffffffc020514c:	ec06                	sd	ra,24(sp)
ffffffffc020514e:	e822                	sd	s0,16(sp)
ffffffffc0205150:	cb39                	beqz	a4,ffffffffc02051a6 <file_dup+0x70>
ffffffffc0205152:	4b14                	lw	a3,16(a4)
ffffffffc0205154:	04d05963          	blez	a3,ffffffffc02051a6 <file_dup+0x70>
ffffffffc0205158:	6700                	ld	s0,8(a4)
ffffffffc020515a:	00351713          	slli	a4,a0,0x3
ffffffffc020515e:	8f09                	sub	a4,a4,a0
ffffffffc0205160:	070e                	slli	a4,a4,0x3
ffffffffc0205162:	943a                	add	s0,s0,a4
ffffffffc0205164:	4014                	lw	a3,0(s0)
ffffffffc0205166:	4709                	li	a4,2
ffffffffc0205168:	02e69863          	bne	a3,a4,ffffffffc0205198 <file_dup+0x62>
ffffffffc020516c:	4c18                	lw	a4,24(s0)
ffffffffc020516e:	02a71563          	bne	a4,a0,ffffffffc0205198 <file_dup+0x62>
ffffffffc0205172:	852e                	mv	a0,a1
ffffffffc0205174:	002c                	addi	a1,sp,8
ffffffffc0205176:	e1eff0ef          	jal	ra,ffffffffc0204794 <fd_array_alloc>
ffffffffc020517a:	c509                	beqz	a0,ffffffffc0205184 <file_dup+0x4e>
ffffffffc020517c:	60e2                	ld	ra,24(sp)
ffffffffc020517e:	6442                	ld	s0,16(sp)
ffffffffc0205180:	6105                	addi	sp,sp,32
ffffffffc0205182:	8082                	ret
ffffffffc0205184:	6522                	ld	a0,8(sp)
ffffffffc0205186:	85a2                	mv	a1,s0
ffffffffc0205188:	845ff0ef          	jal	ra,ffffffffc02049cc <fd_array_dup>
ffffffffc020518c:	67a2                	ld	a5,8(sp)
ffffffffc020518e:	60e2                	ld	ra,24(sp)
ffffffffc0205190:	6442                	ld	s0,16(sp)
ffffffffc0205192:	4f88                	lw	a0,24(a5)
ffffffffc0205194:	6105                	addi	sp,sp,32
ffffffffc0205196:	8082                	ret
ffffffffc0205198:	60e2                	ld	ra,24(sp)
ffffffffc020519a:	6442                	ld	s0,16(sp)
ffffffffc020519c:	5575                	li	a0,-3
ffffffffc020519e:	6105                	addi	sp,sp,32
ffffffffc02051a0:	8082                	ret
ffffffffc02051a2:	5575                	li	a0,-3
ffffffffc02051a4:	8082                	ret
ffffffffc02051a6:	dccff0ef          	jal	ra,ffffffffc0204772 <get_fd_array.part.0>

ffffffffc02051aa <fs_init>:
ffffffffc02051aa:	1141                	addi	sp,sp,-16
ffffffffc02051ac:	e406                	sd	ra,8(sp)
ffffffffc02051ae:	0b5020ef          	jal	ra,ffffffffc0207a62 <vfs_init>
ffffffffc02051b2:	039030ef          	jal	ra,ffffffffc02089ea <dev_init>
ffffffffc02051b6:	60a2                	ld	ra,8(sp)
ffffffffc02051b8:	0141                	addi	sp,sp,16
ffffffffc02051ba:	1880406f          	j	ffffffffc0209342 <sfs_init>

ffffffffc02051be <fs_cleanup>:
ffffffffc02051be:	2f70206f          	j	ffffffffc0207cb4 <vfs_cleanup>

ffffffffc02051c2 <lock_files>:
ffffffffc02051c2:	0561                	addi	a0,a0,24
ffffffffc02051c4:	ba0ff06f          	j	ffffffffc0204564 <down>

ffffffffc02051c8 <unlock_files>:
ffffffffc02051c8:	0561                	addi	a0,a0,24
ffffffffc02051ca:	b96ff06f          	j	ffffffffc0204560 <up>

ffffffffc02051ce <files_create>:
ffffffffc02051ce:	1141                	addi	sp,sp,-16
ffffffffc02051d0:	6505                	lui	a0,0x1
ffffffffc02051d2:	e022                	sd	s0,0(sp)
ffffffffc02051d4:	e406                	sd	ra,8(sp)
ffffffffc02051d6:	db9fc0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc02051da:	842a                	mv	s0,a0
ffffffffc02051dc:	cd19                	beqz	a0,ffffffffc02051fa <files_create+0x2c>
ffffffffc02051de:	03050793          	addi	a5,a0,48 # 1030 <_binary_bin_swap_img_size-0x6cd0>
ffffffffc02051e2:	00043023          	sd	zero,0(s0)
ffffffffc02051e6:	0561                	addi	a0,a0,24
ffffffffc02051e8:	e41c                	sd	a5,8(s0)
ffffffffc02051ea:	00042823          	sw	zero,16(s0)
ffffffffc02051ee:	4585                	li	a1,1
ffffffffc02051f0:	b6aff0ef          	jal	ra,ffffffffc020455a <sem_init>
ffffffffc02051f4:	6408                	ld	a0,8(s0)
ffffffffc02051f6:	f3cff0ef          	jal	ra,ffffffffc0204932 <fd_array_init>
ffffffffc02051fa:	60a2                	ld	ra,8(sp)
ffffffffc02051fc:	8522                	mv	a0,s0
ffffffffc02051fe:	6402                	ld	s0,0(sp)
ffffffffc0205200:	0141                	addi	sp,sp,16
ffffffffc0205202:	8082                	ret

ffffffffc0205204 <files_destroy>:
ffffffffc0205204:	7179                	addi	sp,sp,-48
ffffffffc0205206:	f406                	sd	ra,40(sp)
ffffffffc0205208:	f022                	sd	s0,32(sp)
ffffffffc020520a:	ec26                	sd	s1,24(sp)
ffffffffc020520c:	e84a                	sd	s2,16(sp)
ffffffffc020520e:	e44e                	sd	s3,8(sp)
ffffffffc0205210:	c52d                	beqz	a0,ffffffffc020527a <files_destroy+0x76>
ffffffffc0205212:	491c                	lw	a5,16(a0)
ffffffffc0205214:	89aa                	mv	s3,a0
ffffffffc0205216:	e3b5                	bnez	a5,ffffffffc020527a <files_destroy+0x76>
ffffffffc0205218:	6108                	ld	a0,0(a0)
ffffffffc020521a:	c119                	beqz	a0,ffffffffc0205220 <files_destroy+0x1c>
ffffffffc020521c:	6de020ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc0205220:	0089b403          	ld	s0,8(s3)
ffffffffc0205224:	6485                	lui	s1,0x1
ffffffffc0205226:	fc048493          	addi	s1,s1,-64 # fc0 <_binary_bin_swap_img_size-0x6d40>
ffffffffc020522a:	94a2                	add	s1,s1,s0
ffffffffc020522c:	4909                	li	s2,2
ffffffffc020522e:	401c                	lw	a5,0(s0)
ffffffffc0205230:	03278063          	beq	a5,s2,ffffffffc0205250 <files_destroy+0x4c>
ffffffffc0205234:	e39d                	bnez	a5,ffffffffc020525a <files_destroy+0x56>
ffffffffc0205236:	03840413          	addi	s0,s0,56
ffffffffc020523a:	fe849ae3          	bne	s1,s0,ffffffffc020522e <files_destroy+0x2a>
ffffffffc020523e:	7402                	ld	s0,32(sp)
ffffffffc0205240:	70a2                	ld	ra,40(sp)
ffffffffc0205242:	64e2                	ld	s1,24(sp)
ffffffffc0205244:	6942                	ld	s2,16(sp)
ffffffffc0205246:	854e                	mv	a0,s3
ffffffffc0205248:	69a2                	ld	s3,8(sp)
ffffffffc020524a:	6145                	addi	sp,sp,48
ffffffffc020524c:	df3fc06f          	j	ffffffffc020203e <kfree>
ffffffffc0205250:	8522                	mv	a0,s0
ffffffffc0205252:	efcff0ef          	jal	ra,ffffffffc020494e <fd_array_close>
ffffffffc0205256:	401c                	lw	a5,0(s0)
ffffffffc0205258:	bff1                	j	ffffffffc0205234 <files_destroy+0x30>
ffffffffc020525a:	00008697          	auipc	a3,0x8
ffffffffc020525e:	6f668693          	addi	a3,a3,1782 # ffffffffc020d950 <CSWTCH.84+0x58>
ffffffffc0205262:	00007617          	auipc	a2,0x7
ffffffffc0205266:	c8660613          	addi	a2,a2,-890 # ffffffffc020bee8 <commands+0x210>
ffffffffc020526a:	03d00593          	li	a1,61
ffffffffc020526e:	00008517          	auipc	a0,0x8
ffffffffc0205272:	6d250513          	addi	a0,a0,1746 # ffffffffc020d940 <CSWTCH.84+0x48>
ffffffffc0205276:	a28fb0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020527a:	00008697          	auipc	a3,0x8
ffffffffc020527e:	69668693          	addi	a3,a3,1686 # ffffffffc020d910 <CSWTCH.84+0x18>
ffffffffc0205282:	00007617          	auipc	a2,0x7
ffffffffc0205286:	c6660613          	addi	a2,a2,-922 # ffffffffc020bee8 <commands+0x210>
ffffffffc020528a:	03300593          	li	a1,51
ffffffffc020528e:	00008517          	auipc	a0,0x8
ffffffffc0205292:	6b250513          	addi	a0,a0,1714 # ffffffffc020d940 <CSWTCH.84+0x48>
ffffffffc0205296:	a08fb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020529a <files_closeall>:
ffffffffc020529a:	1101                	addi	sp,sp,-32
ffffffffc020529c:	ec06                	sd	ra,24(sp)
ffffffffc020529e:	e822                	sd	s0,16(sp)
ffffffffc02052a0:	e426                	sd	s1,8(sp)
ffffffffc02052a2:	e04a                	sd	s2,0(sp)
ffffffffc02052a4:	c129                	beqz	a0,ffffffffc02052e6 <files_closeall+0x4c>
ffffffffc02052a6:	491c                	lw	a5,16(a0)
ffffffffc02052a8:	02f05f63          	blez	a5,ffffffffc02052e6 <files_closeall+0x4c>
ffffffffc02052ac:	6504                	ld	s1,8(a0)
ffffffffc02052ae:	6785                	lui	a5,0x1
ffffffffc02052b0:	fc078793          	addi	a5,a5,-64 # fc0 <_binary_bin_swap_img_size-0x6d40>
ffffffffc02052b4:	07048413          	addi	s0,s1,112
ffffffffc02052b8:	4909                	li	s2,2
ffffffffc02052ba:	94be                	add	s1,s1,a5
ffffffffc02052bc:	a029                	j	ffffffffc02052c6 <files_closeall+0x2c>
ffffffffc02052be:	03840413          	addi	s0,s0,56
ffffffffc02052c2:	00848c63          	beq	s1,s0,ffffffffc02052da <files_closeall+0x40>
ffffffffc02052c6:	401c                	lw	a5,0(s0)
ffffffffc02052c8:	ff279be3          	bne	a5,s2,ffffffffc02052be <files_closeall+0x24>
ffffffffc02052cc:	8522                	mv	a0,s0
ffffffffc02052ce:	03840413          	addi	s0,s0,56
ffffffffc02052d2:	e7cff0ef          	jal	ra,ffffffffc020494e <fd_array_close>
ffffffffc02052d6:	fe8498e3          	bne	s1,s0,ffffffffc02052c6 <files_closeall+0x2c>
ffffffffc02052da:	60e2                	ld	ra,24(sp)
ffffffffc02052dc:	6442                	ld	s0,16(sp)
ffffffffc02052de:	64a2                	ld	s1,8(sp)
ffffffffc02052e0:	6902                	ld	s2,0(sp)
ffffffffc02052e2:	6105                	addi	sp,sp,32
ffffffffc02052e4:	8082                	ret
ffffffffc02052e6:	00008697          	auipc	a3,0x8
ffffffffc02052ea:	27268693          	addi	a3,a3,626 # ffffffffc020d558 <default_pmm_manager+0xb88>
ffffffffc02052ee:	00007617          	auipc	a2,0x7
ffffffffc02052f2:	bfa60613          	addi	a2,a2,-1030 # ffffffffc020bee8 <commands+0x210>
ffffffffc02052f6:	04500593          	li	a1,69
ffffffffc02052fa:	00008517          	auipc	a0,0x8
ffffffffc02052fe:	64650513          	addi	a0,a0,1606 # ffffffffc020d940 <CSWTCH.84+0x48>
ffffffffc0205302:	99cfb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0205306 <dup_files>:
ffffffffc0205306:	7179                	addi	sp,sp,-48
ffffffffc0205308:	f406                	sd	ra,40(sp)
ffffffffc020530a:	f022                	sd	s0,32(sp)
ffffffffc020530c:	ec26                	sd	s1,24(sp)
ffffffffc020530e:	e84a                	sd	s2,16(sp)
ffffffffc0205310:	e44e                	sd	s3,8(sp)
ffffffffc0205312:	e052                	sd	s4,0(sp)
ffffffffc0205314:	c52d                	beqz	a0,ffffffffc020537e <dup_files+0x78>
ffffffffc0205316:	842e                	mv	s0,a1
ffffffffc0205318:	c1bd                	beqz	a1,ffffffffc020537e <dup_files+0x78>
ffffffffc020531a:	491c                	lw	a5,16(a0)
ffffffffc020531c:	84aa                	mv	s1,a0
ffffffffc020531e:	e3c1                	bnez	a5,ffffffffc020539e <dup_files+0x98>
ffffffffc0205320:	499c                	lw	a5,16(a1)
ffffffffc0205322:	06f05e63          	blez	a5,ffffffffc020539e <dup_files+0x98>
ffffffffc0205326:	6188                	ld	a0,0(a1)
ffffffffc0205328:	e088                	sd	a0,0(s1)
ffffffffc020532a:	c119                	beqz	a0,ffffffffc0205330 <dup_files+0x2a>
ffffffffc020532c:	500020ef          	jal	ra,ffffffffc020782c <inode_ref_inc>
ffffffffc0205330:	6400                	ld	s0,8(s0)
ffffffffc0205332:	6905                	lui	s2,0x1
ffffffffc0205334:	fc090913          	addi	s2,s2,-64 # fc0 <_binary_bin_swap_img_size-0x6d40>
ffffffffc0205338:	6484                	ld	s1,8(s1)
ffffffffc020533a:	9922                	add	s2,s2,s0
ffffffffc020533c:	4989                	li	s3,2
ffffffffc020533e:	4a05                	li	s4,1
ffffffffc0205340:	a039                	j	ffffffffc020534e <dup_files+0x48>
ffffffffc0205342:	03840413          	addi	s0,s0,56
ffffffffc0205346:	03848493          	addi	s1,s1,56
ffffffffc020534a:	02890163          	beq	s2,s0,ffffffffc020536c <dup_files+0x66>
ffffffffc020534e:	401c                	lw	a5,0(s0)
ffffffffc0205350:	ff3799e3          	bne	a5,s3,ffffffffc0205342 <dup_files+0x3c>
ffffffffc0205354:	0144a023          	sw	s4,0(s1)
ffffffffc0205358:	85a2                	mv	a1,s0
ffffffffc020535a:	8526                	mv	a0,s1
ffffffffc020535c:	03840413          	addi	s0,s0,56
ffffffffc0205360:	e6cff0ef          	jal	ra,ffffffffc02049cc <fd_array_dup>
ffffffffc0205364:	03848493          	addi	s1,s1,56
ffffffffc0205368:	fe8913e3          	bne	s2,s0,ffffffffc020534e <dup_files+0x48>
ffffffffc020536c:	70a2                	ld	ra,40(sp)
ffffffffc020536e:	7402                	ld	s0,32(sp)
ffffffffc0205370:	64e2                	ld	s1,24(sp)
ffffffffc0205372:	6942                	ld	s2,16(sp)
ffffffffc0205374:	69a2                	ld	s3,8(sp)
ffffffffc0205376:	6a02                	ld	s4,0(sp)
ffffffffc0205378:	4501                	li	a0,0
ffffffffc020537a:	6145                	addi	sp,sp,48
ffffffffc020537c:	8082                	ret
ffffffffc020537e:	00008697          	auipc	a3,0x8
ffffffffc0205382:	f2a68693          	addi	a3,a3,-214 # ffffffffc020d2a8 <default_pmm_manager+0x8d8>
ffffffffc0205386:	00007617          	auipc	a2,0x7
ffffffffc020538a:	b6260613          	addi	a2,a2,-1182 # ffffffffc020bee8 <commands+0x210>
ffffffffc020538e:	05300593          	li	a1,83
ffffffffc0205392:	00008517          	auipc	a0,0x8
ffffffffc0205396:	5ae50513          	addi	a0,a0,1454 # ffffffffc020d940 <CSWTCH.84+0x48>
ffffffffc020539a:	904fb0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020539e:	00008697          	auipc	a3,0x8
ffffffffc02053a2:	5ca68693          	addi	a3,a3,1482 # ffffffffc020d968 <CSWTCH.84+0x70>
ffffffffc02053a6:	00007617          	auipc	a2,0x7
ffffffffc02053aa:	b4260613          	addi	a2,a2,-1214 # ffffffffc020bee8 <commands+0x210>
ffffffffc02053ae:	05400593          	li	a1,84
ffffffffc02053b2:	00008517          	auipc	a0,0x8
ffffffffc02053b6:	58e50513          	addi	a0,a0,1422 # ffffffffc020d940 <CSWTCH.84+0x48>
ffffffffc02053ba:	8e4fb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02053be <iobuf_skip.part.0>:
ffffffffc02053be:	1141                	addi	sp,sp,-16
ffffffffc02053c0:	00008697          	auipc	a3,0x8
ffffffffc02053c4:	5d868693          	addi	a3,a3,1496 # ffffffffc020d998 <CSWTCH.84+0xa0>
ffffffffc02053c8:	00007617          	auipc	a2,0x7
ffffffffc02053cc:	b2060613          	addi	a2,a2,-1248 # ffffffffc020bee8 <commands+0x210>
ffffffffc02053d0:	04a00593          	li	a1,74
ffffffffc02053d4:	00008517          	auipc	a0,0x8
ffffffffc02053d8:	5dc50513          	addi	a0,a0,1500 # ffffffffc020d9b0 <CSWTCH.84+0xb8>
ffffffffc02053dc:	e406                	sd	ra,8(sp)
ffffffffc02053de:	8c0fb0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02053e2 <iobuf_init>:
ffffffffc02053e2:	e10c                	sd	a1,0(a0)
ffffffffc02053e4:	e514                	sd	a3,8(a0)
ffffffffc02053e6:	ed10                	sd	a2,24(a0)
ffffffffc02053e8:	e910                	sd	a2,16(a0)
ffffffffc02053ea:	8082                	ret

ffffffffc02053ec <iobuf_move>:
ffffffffc02053ec:	7179                	addi	sp,sp,-48
ffffffffc02053ee:	ec26                	sd	s1,24(sp)
ffffffffc02053f0:	6d04                	ld	s1,24(a0)
ffffffffc02053f2:	f022                	sd	s0,32(sp)
ffffffffc02053f4:	e84a                	sd	s2,16(sp)
ffffffffc02053f6:	e44e                	sd	s3,8(sp)
ffffffffc02053f8:	f406                	sd	ra,40(sp)
ffffffffc02053fa:	842a                	mv	s0,a0
ffffffffc02053fc:	8932                	mv	s2,a2
ffffffffc02053fe:	852e                	mv	a0,a1
ffffffffc0205400:	89ba                	mv	s3,a4
ffffffffc0205402:	00967363          	bgeu	a2,s1,ffffffffc0205408 <iobuf_move+0x1c>
ffffffffc0205406:	84b2                	mv	s1,a2
ffffffffc0205408:	c495                	beqz	s1,ffffffffc0205434 <iobuf_move+0x48>
ffffffffc020540a:	600c                	ld	a1,0(s0)
ffffffffc020540c:	c681                	beqz	a3,ffffffffc0205414 <iobuf_move+0x28>
ffffffffc020540e:	87ae                	mv	a5,a1
ffffffffc0205410:	85aa                	mv	a1,a0
ffffffffc0205412:	853e                	mv	a0,a5
ffffffffc0205414:	8626                	mv	a2,s1
ffffffffc0205416:	600060ef          	jal	ra,ffffffffc020ba16 <memmove>
ffffffffc020541a:	6c1c                	ld	a5,24(s0)
ffffffffc020541c:	0297ea63          	bltu	a5,s1,ffffffffc0205450 <iobuf_move+0x64>
ffffffffc0205420:	6014                	ld	a3,0(s0)
ffffffffc0205422:	6418                	ld	a4,8(s0)
ffffffffc0205424:	8f85                	sub	a5,a5,s1
ffffffffc0205426:	96a6                	add	a3,a3,s1
ffffffffc0205428:	9726                	add	a4,a4,s1
ffffffffc020542a:	e014                	sd	a3,0(s0)
ffffffffc020542c:	e418                	sd	a4,8(s0)
ffffffffc020542e:	ec1c                	sd	a5,24(s0)
ffffffffc0205430:	40990933          	sub	s2,s2,s1
ffffffffc0205434:	00098463          	beqz	s3,ffffffffc020543c <iobuf_move+0x50>
ffffffffc0205438:	0099b023          	sd	s1,0(s3)
ffffffffc020543c:	4501                	li	a0,0
ffffffffc020543e:	00091b63          	bnez	s2,ffffffffc0205454 <iobuf_move+0x68>
ffffffffc0205442:	70a2                	ld	ra,40(sp)
ffffffffc0205444:	7402                	ld	s0,32(sp)
ffffffffc0205446:	64e2                	ld	s1,24(sp)
ffffffffc0205448:	6942                	ld	s2,16(sp)
ffffffffc020544a:	69a2                	ld	s3,8(sp)
ffffffffc020544c:	6145                	addi	sp,sp,48
ffffffffc020544e:	8082                	ret
ffffffffc0205450:	f6fff0ef          	jal	ra,ffffffffc02053be <iobuf_skip.part.0>
ffffffffc0205454:	5571                	li	a0,-4
ffffffffc0205456:	b7f5                	j	ffffffffc0205442 <iobuf_move+0x56>

ffffffffc0205458 <iobuf_skip>:
ffffffffc0205458:	6d1c                	ld	a5,24(a0)
ffffffffc020545a:	00b7eb63          	bltu	a5,a1,ffffffffc0205470 <iobuf_skip+0x18>
ffffffffc020545e:	6114                	ld	a3,0(a0)
ffffffffc0205460:	6518                	ld	a4,8(a0)
ffffffffc0205462:	8f8d                	sub	a5,a5,a1
ffffffffc0205464:	96ae                	add	a3,a3,a1
ffffffffc0205466:	95ba                	add	a1,a1,a4
ffffffffc0205468:	e114                	sd	a3,0(a0)
ffffffffc020546a:	e50c                	sd	a1,8(a0)
ffffffffc020546c:	ed1c                	sd	a5,24(a0)
ffffffffc020546e:	8082                	ret
ffffffffc0205470:	1141                	addi	sp,sp,-16
ffffffffc0205472:	e406                	sd	ra,8(sp)
ffffffffc0205474:	f4bff0ef          	jal	ra,ffffffffc02053be <iobuf_skip.part.0>

ffffffffc0205478 <copy_path>:
ffffffffc0205478:	7139                	addi	sp,sp,-64
ffffffffc020547a:	f04a                	sd	s2,32(sp)
ffffffffc020547c:	00091917          	auipc	s2,0x91
ffffffffc0205480:	44490913          	addi	s2,s2,1092 # ffffffffc02968c0 <current>
ffffffffc0205484:	00093703          	ld	a4,0(s2)
ffffffffc0205488:	ec4e                	sd	s3,24(sp)
ffffffffc020548a:	89aa                	mv	s3,a0
ffffffffc020548c:	6505                	lui	a0,0x1
ffffffffc020548e:	f426                	sd	s1,40(sp)
ffffffffc0205490:	e852                	sd	s4,16(sp)
ffffffffc0205492:	fc06                	sd	ra,56(sp)
ffffffffc0205494:	f822                	sd	s0,48(sp)
ffffffffc0205496:	e456                	sd	s5,8(sp)
ffffffffc0205498:	02873a03          	ld	s4,40(a4)
ffffffffc020549c:	84ae                	mv	s1,a1
ffffffffc020549e:	af1fc0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc02054a2:	c141                	beqz	a0,ffffffffc0205522 <copy_path+0xaa>
ffffffffc02054a4:	842a                	mv	s0,a0
ffffffffc02054a6:	040a0563          	beqz	s4,ffffffffc02054f0 <copy_path+0x78>
ffffffffc02054aa:	038a0a93          	addi	s5,s4,56
ffffffffc02054ae:	8556                	mv	a0,s5
ffffffffc02054b0:	8b4ff0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc02054b4:	00093783          	ld	a5,0(s2)
ffffffffc02054b8:	cba1                	beqz	a5,ffffffffc0205508 <copy_path+0x90>
ffffffffc02054ba:	43dc                	lw	a5,4(a5)
ffffffffc02054bc:	6685                	lui	a3,0x1
ffffffffc02054be:	8626                	mv	a2,s1
ffffffffc02054c0:	04fa2823          	sw	a5,80(s4)
ffffffffc02054c4:	85a2                	mv	a1,s0
ffffffffc02054c6:	8552                	mv	a0,s4
ffffffffc02054c8:	ec5fe0ef          	jal	ra,ffffffffc020438c <copy_string>
ffffffffc02054cc:	c529                	beqz	a0,ffffffffc0205516 <copy_path+0x9e>
ffffffffc02054ce:	8556                	mv	a0,s5
ffffffffc02054d0:	890ff0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc02054d4:	040a2823          	sw	zero,80(s4)
ffffffffc02054d8:	0089b023          	sd	s0,0(s3)
ffffffffc02054dc:	4501                	li	a0,0
ffffffffc02054de:	70e2                	ld	ra,56(sp)
ffffffffc02054e0:	7442                	ld	s0,48(sp)
ffffffffc02054e2:	74a2                	ld	s1,40(sp)
ffffffffc02054e4:	7902                	ld	s2,32(sp)
ffffffffc02054e6:	69e2                	ld	s3,24(sp)
ffffffffc02054e8:	6a42                	ld	s4,16(sp)
ffffffffc02054ea:	6aa2                	ld	s5,8(sp)
ffffffffc02054ec:	6121                	addi	sp,sp,64
ffffffffc02054ee:	8082                	ret
ffffffffc02054f0:	85aa                	mv	a1,a0
ffffffffc02054f2:	6685                	lui	a3,0x1
ffffffffc02054f4:	8626                	mv	a2,s1
ffffffffc02054f6:	4501                	li	a0,0
ffffffffc02054f8:	e95fe0ef          	jal	ra,ffffffffc020438c <copy_string>
ffffffffc02054fc:	fd71                	bnez	a0,ffffffffc02054d8 <copy_path+0x60>
ffffffffc02054fe:	8522                	mv	a0,s0
ffffffffc0205500:	b3ffc0ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc0205504:	5575                	li	a0,-3
ffffffffc0205506:	bfe1                	j	ffffffffc02054de <copy_path+0x66>
ffffffffc0205508:	6685                	lui	a3,0x1
ffffffffc020550a:	8626                	mv	a2,s1
ffffffffc020550c:	85a2                	mv	a1,s0
ffffffffc020550e:	8552                	mv	a0,s4
ffffffffc0205510:	e7dfe0ef          	jal	ra,ffffffffc020438c <copy_string>
ffffffffc0205514:	fd4d                	bnez	a0,ffffffffc02054ce <copy_path+0x56>
ffffffffc0205516:	8556                	mv	a0,s5
ffffffffc0205518:	848ff0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc020551c:	040a2823          	sw	zero,80(s4)
ffffffffc0205520:	bff9                	j	ffffffffc02054fe <copy_path+0x86>
ffffffffc0205522:	5571                	li	a0,-4
ffffffffc0205524:	bf6d                	j	ffffffffc02054de <copy_path+0x66>

ffffffffc0205526 <sysfile_open>:
ffffffffc0205526:	7179                	addi	sp,sp,-48
ffffffffc0205528:	872a                	mv	a4,a0
ffffffffc020552a:	ec26                	sd	s1,24(sp)
ffffffffc020552c:	0028                	addi	a0,sp,8
ffffffffc020552e:	84ae                	mv	s1,a1
ffffffffc0205530:	85ba                	mv	a1,a4
ffffffffc0205532:	f022                	sd	s0,32(sp)
ffffffffc0205534:	f406                	sd	ra,40(sp)
ffffffffc0205536:	f43ff0ef          	jal	ra,ffffffffc0205478 <copy_path>
ffffffffc020553a:	842a                	mv	s0,a0
ffffffffc020553c:	e909                	bnez	a0,ffffffffc020554e <sysfile_open+0x28>
ffffffffc020553e:	6522                	ld	a0,8(sp)
ffffffffc0205540:	85a6                	mv	a1,s1
ffffffffc0205542:	d60ff0ef          	jal	ra,ffffffffc0204aa2 <file_open>
ffffffffc0205546:	842a                	mv	s0,a0
ffffffffc0205548:	6522                	ld	a0,8(sp)
ffffffffc020554a:	af5fc0ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020554e:	70a2                	ld	ra,40(sp)
ffffffffc0205550:	8522                	mv	a0,s0
ffffffffc0205552:	7402                	ld	s0,32(sp)
ffffffffc0205554:	64e2                	ld	s1,24(sp)
ffffffffc0205556:	6145                	addi	sp,sp,48
ffffffffc0205558:	8082                	ret

ffffffffc020555a <sysfile_close>:
ffffffffc020555a:	e46ff06f          	j	ffffffffc0204ba0 <file_close>

ffffffffc020555e <sysfile_read>:
ffffffffc020555e:	7159                	addi	sp,sp,-112
ffffffffc0205560:	f0a2                	sd	s0,96(sp)
ffffffffc0205562:	f486                	sd	ra,104(sp)
ffffffffc0205564:	eca6                	sd	s1,88(sp)
ffffffffc0205566:	e8ca                	sd	s2,80(sp)
ffffffffc0205568:	e4ce                	sd	s3,72(sp)
ffffffffc020556a:	e0d2                	sd	s4,64(sp)
ffffffffc020556c:	fc56                	sd	s5,56(sp)
ffffffffc020556e:	f85a                	sd	s6,48(sp)
ffffffffc0205570:	f45e                	sd	s7,40(sp)
ffffffffc0205572:	f062                	sd	s8,32(sp)
ffffffffc0205574:	ec66                	sd	s9,24(sp)
ffffffffc0205576:	4401                	li	s0,0
ffffffffc0205578:	ee19                	bnez	a2,ffffffffc0205596 <sysfile_read+0x38>
ffffffffc020557a:	70a6                	ld	ra,104(sp)
ffffffffc020557c:	8522                	mv	a0,s0
ffffffffc020557e:	7406                	ld	s0,96(sp)
ffffffffc0205580:	64e6                	ld	s1,88(sp)
ffffffffc0205582:	6946                	ld	s2,80(sp)
ffffffffc0205584:	69a6                	ld	s3,72(sp)
ffffffffc0205586:	6a06                	ld	s4,64(sp)
ffffffffc0205588:	7ae2                	ld	s5,56(sp)
ffffffffc020558a:	7b42                	ld	s6,48(sp)
ffffffffc020558c:	7ba2                	ld	s7,40(sp)
ffffffffc020558e:	7c02                	ld	s8,32(sp)
ffffffffc0205590:	6ce2                	ld	s9,24(sp)
ffffffffc0205592:	6165                	addi	sp,sp,112
ffffffffc0205594:	8082                	ret
ffffffffc0205596:	00091c97          	auipc	s9,0x91
ffffffffc020559a:	32ac8c93          	addi	s9,s9,810 # ffffffffc02968c0 <current>
ffffffffc020559e:	000cb783          	ld	a5,0(s9)
ffffffffc02055a2:	84b2                	mv	s1,a2
ffffffffc02055a4:	8b2e                	mv	s6,a1
ffffffffc02055a6:	4601                	li	a2,0
ffffffffc02055a8:	4585                	li	a1,1
ffffffffc02055aa:	0287b903          	ld	s2,40(a5)
ffffffffc02055ae:	8aaa                	mv	s5,a0
ffffffffc02055b0:	c9eff0ef          	jal	ra,ffffffffc0204a4e <file_testfd>
ffffffffc02055b4:	c959                	beqz	a0,ffffffffc020564a <sysfile_read+0xec>
ffffffffc02055b6:	6505                	lui	a0,0x1
ffffffffc02055b8:	9d7fc0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc02055bc:	89aa                	mv	s3,a0
ffffffffc02055be:	c941                	beqz	a0,ffffffffc020564e <sysfile_read+0xf0>
ffffffffc02055c0:	4b81                	li	s7,0
ffffffffc02055c2:	6a05                	lui	s4,0x1
ffffffffc02055c4:	03890c13          	addi	s8,s2,56
ffffffffc02055c8:	0744ec63          	bltu	s1,s4,ffffffffc0205640 <sysfile_read+0xe2>
ffffffffc02055cc:	e452                	sd	s4,8(sp)
ffffffffc02055ce:	6605                	lui	a2,0x1
ffffffffc02055d0:	0034                	addi	a3,sp,8
ffffffffc02055d2:	85ce                	mv	a1,s3
ffffffffc02055d4:	8556                	mv	a0,s5
ffffffffc02055d6:	e20ff0ef          	jal	ra,ffffffffc0204bf6 <file_read>
ffffffffc02055da:	66a2                	ld	a3,8(sp)
ffffffffc02055dc:	842a                	mv	s0,a0
ffffffffc02055de:	ca9d                	beqz	a3,ffffffffc0205614 <sysfile_read+0xb6>
ffffffffc02055e0:	00090c63          	beqz	s2,ffffffffc02055f8 <sysfile_read+0x9a>
ffffffffc02055e4:	8562                	mv	a0,s8
ffffffffc02055e6:	f7ffe0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc02055ea:	000cb783          	ld	a5,0(s9)
ffffffffc02055ee:	cfa1                	beqz	a5,ffffffffc0205646 <sysfile_read+0xe8>
ffffffffc02055f0:	43dc                	lw	a5,4(a5)
ffffffffc02055f2:	66a2                	ld	a3,8(sp)
ffffffffc02055f4:	04f92823          	sw	a5,80(s2)
ffffffffc02055f8:	864e                	mv	a2,s3
ffffffffc02055fa:	85da                	mv	a1,s6
ffffffffc02055fc:	854a                	mv	a0,s2
ffffffffc02055fe:	d5dfe0ef          	jal	ra,ffffffffc020435a <copy_to_user>
ffffffffc0205602:	c50d                	beqz	a0,ffffffffc020562c <sysfile_read+0xce>
ffffffffc0205604:	67a2                	ld	a5,8(sp)
ffffffffc0205606:	04f4e663          	bltu	s1,a5,ffffffffc0205652 <sysfile_read+0xf4>
ffffffffc020560a:	9b3e                	add	s6,s6,a5
ffffffffc020560c:	8c9d                	sub	s1,s1,a5
ffffffffc020560e:	9bbe                	add	s7,s7,a5
ffffffffc0205610:	02091263          	bnez	s2,ffffffffc0205634 <sysfile_read+0xd6>
ffffffffc0205614:	e401                	bnez	s0,ffffffffc020561c <sysfile_read+0xbe>
ffffffffc0205616:	67a2                	ld	a5,8(sp)
ffffffffc0205618:	c391                	beqz	a5,ffffffffc020561c <sysfile_read+0xbe>
ffffffffc020561a:	f4dd                	bnez	s1,ffffffffc02055c8 <sysfile_read+0x6a>
ffffffffc020561c:	854e                	mv	a0,s3
ffffffffc020561e:	a21fc0ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc0205622:	f40b8ce3          	beqz	s7,ffffffffc020557a <sysfile_read+0x1c>
ffffffffc0205626:	000b841b          	sext.w	s0,s7
ffffffffc020562a:	bf81                	j	ffffffffc020557a <sysfile_read+0x1c>
ffffffffc020562c:	e011                	bnez	s0,ffffffffc0205630 <sysfile_read+0xd2>
ffffffffc020562e:	5475                	li	s0,-3
ffffffffc0205630:	fe0906e3          	beqz	s2,ffffffffc020561c <sysfile_read+0xbe>
ffffffffc0205634:	8562                	mv	a0,s8
ffffffffc0205636:	f2bfe0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc020563a:	04092823          	sw	zero,80(s2)
ffffffffc020563e:	bfd9                	j	ffffffffc0205614 <sysfile_read+0xb6>
ffffffffc0205640:	e426                	sd	s1,8(sp)
ffffffffc0205642:	8626                	mv	a2,s1
ffffffffc0205644:	b771                	j	ffffffffc02055d0 <sysfile_read+0x72>
ffffffffc0205646:	66a2                	ld	a3,8(sp)
ffffffffc0205648:	bf45                	j	ffffffffc02055f8 <sysfile_read+0x9a>
ffffffffc020564a:	5475                	li	s0,-3
ffffffffc020564c:	b73d                	j	ffffffffc020557a <sysfile_read+0x1c>
ffffffffc020564e:	5471                	li	s0,-4
ffffffffc0205650:	b72d                	j	ffffffffc020557a <sysfile_read+0x1c>
ffffffffc0205652:	00008697          	auipc	a3,0x8
ffffffffc0205656:	36e68693          	addi	a3,a3,878 # ffffffffc020d9c0 <CSWTCH.84+0xc8>
ffffffffc020565a:	00007617          	auipc	a2,0x7
ffffffffc020565e:	88e60613          	addi	a2,a2,-1906 # ffffffffc020bee8 <commands+0x210>
ffffffffc0205662:	05500593          	li	a1,85
ffffffffc0205666:	00008517          	auipc	a0,0x8
ffffffffc020566a:	36a50513          	addi	a0,a0,874 # ffffffffc020d9d0 <CSWTCH.84+0xd8>
ffffffffc020566e:	e31fa0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0205672 <sysfile_write>:
ffffffffc0205672:	7159                	addi	sp,sp,-112
ffffffffc0205674:	e8ca                	sd	s2,80(sp)
ffffffffc0205676:	f486                	sd	ra,104(sp)
ffffffffc0205678:	f0a2                	sd	s0,96(sp)
ffffffffc020567a:	eca6                	sd	s1,88(sp)
ffffffffc020567c:	e4ce                	sd	s3,72(sp)
ffffffffc020567e:	e0d2                	sd	s4,64(sp)
ffffffffc0205680:	fc56                	sd	s5,56(sp)
ffffffffc0205682:	f85a                	sd	s6,48(sp)
ffffffffc0205684:	f45e                	sd	s7,40(sp)
ffffffffc0205686:	f062                	sd	s8,32(sp)
ffffffffc0205688:	ec66                	sd	s9,24(sp)
ffffffffc020568a:	4901                	li	s2,0
ffffffffc020568c:	ee19                	bnez	a2,ffffffffc02056aa <sysfile_write+0x38>
ffffffffc020568e:	70a6                	ld	ra,104(sp)
ffffffffc0205690:	7406                	ld	s0,96(sp)
ffffffffc0205692:	64e6                	ld	s1,88(sp)
ffffffffc0205694:	69a6                	ld	s3,72(sp)
ffffffffc0205696:	6a06                	ld	s4,64(sp)
ffffffffc0205698:	7ae2                	ld	s5,56(sp)
ffffffffc020569a:	7b42                	ld	s6,48(sp)
ffffffffc020569c:	7ba2                	ld	s7,40(sp)
ffffffffc020569e:	7c02                	ld	s8,32(sp)
ffffffffc02056a0:	6ce2                	ld	s9,24(sp)
ffffffffc02056a2:	854a                	mv	a0,s2
ffffffffc02056a4:	6946                	ld	s2,80(sp)
ffffffffc02056a6:	6165                	addi	sp,sp,112
ffffffffc02056a8:	8082                	ret
ffffffffc02056aa:	00091c17          	auipc	s8,0x91
ffffffffc02056ae:	216c0c13          	addi	s8,s8,534 # ffffffffc02968c0 <current>
ffffffffc02056b2:	000c3783          	ld	a5,0(s8)
ffffffffc02056b6:	8432                	mv	s0,a2
ffffffffc02056b8:	89ae                	mv	s3,a1
ffffffffc02056ba:	4605                	li	a2,1
ffffffffc02056bc:	4581                	li	a1,0
ffffffffc02056be:	7784                	ld	s1,40(a5)
ffffffffc02056c0:	8baa                	mv	s7,a0
ffffffffc02056c2:	b8cff0ef          	jal	ra,ffffffffc0204a4e <file_testfd>
ffffffffc02056c6:	cd59                	beqz	a0,ffffffffc0205764 <sysfile_write+0xf2>
ffffffffc02056c8:	6505                	lui	a0,0x1
ffffffffc02056ca:	8c5fc0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc02056ce:	8a2a                	mv	s4,a0
ffffffffc02056d0:	cd41                	beqz	a0,ffffffffc0205768 <sysfile_write+0xf6>
ffffffffc02056d2:	4c81                	li	s9,0
ffffffffc02056d4:	6a85                	lui	s5,0x1
ffffffffc02056d6:	03848b13          	addi	s6,s1,56
ffffffffc02056da:	05546a63          	bltu	s0,s5,ffffffffc020572e <sysfile_write+0xbc>
ffffffffc02056de:	e456                	sd	s5,8(sp)
ffffffffc02056e0:	c8a9                	beqz	s1,ffffffffc0205732 <sysfile_write+0xc0>
ffffffffc02056e2:	855a                	mv	a0,s6
ffffffffc02056e4:	e81fe0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc02056e8:	000c3783          	ld	a5,0(s8)
ffffffffc02056ec:	c399                	beqz	a5,ffffffffc02056f2 <sysfile_write+0x80>
ffffffffc02056ee:	43dc                	lw	a5,4(a5)
ffffffffc02056f0:	c8bc                	sw	a5,80(s1)
ffffffffc02056f2:	66a2                	ld	a3,8(sp)
ffffffffc02056f4:	4701                	li	a4,0
ffffffffc02056f6:	864e                	mv	a2,s3
ffffffffc02056f8:	85d2                	mv	a1,s4
ffffffffc02056fa:	8526                	mv	a0,s1
ffffffffc02056fc:	c2bfe0ef          	jal	ra,ffffffffc0204326 <copy_from_user>
ffffffffc0205700:	c139                	beqz	a0,ffffffffc0205746 <sysfile_write+0xd4>
ffffffffc0205702:	855a                	mv	a0,s6
ffffffffc0205704:	e5dfe0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0205708:	0404a823          	sw	zero,80(s1)
ffffffffc020570c:	6622                	ld	a2,8(sp)
ffffffffc020570e:	0034                	addi	a3,sp,8
ffffffffc0205710:	85d2                	mv	a1,s4
ffffffffc0205712:	855e                	mv	a0,s7
ffffffffc0205714:	dc8ff0ef          	jal	ra,ffffffffc0204cdc <file_write>
ffffffffc0205718:	67a2                	ld	a5,8(sp)
ffffffffc020571a:	892a                	mv	s2,a0
ffffffffc020571c:	ef85                	bnez	a5,ffffffffc0205754 <sysfile_write+0xe2>
ffffffffc020571e:	8552                	mv	a0,s4
ffffffffc0205720:	91ffc0ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc0205724:	f60c85e3          	beqz	s9,ffffffffc020568e <sysfile_write+0x1c>
ffffffffc0205728:	000c891b          	sext.w	s2,s9
ffffffffc020572c:	b78d                	j	ffffffffc020568e <sysfile_write+0x1c>
ffffffffc020572e:	e422                	sd	s0,8(sp)
ffffffffc0205730:	f8cd                	bnez	s1,ffffffffc02056e2 <sysfile_write+0x70>
ffffffffc0205732:	66a2                	ld	a3,8(sp)
ffffffffc0205734:	4701                	li	a4,0
ffffffffc0205736:	864e                	mv	a2,s3
ffffffffc0205738:	85d2                	mv	a1,s4
ffffffffc020573a:	4501                	li	a0,0
ffffffffc020573c:	bebfe0ef          	jal	ra,ffffffffc0204326 <copy_from_user>
ffffffffc0205740:	f571                	bnez	a0,ffffffffc020570c <sysfile_write+0x9a>
ffffffffc0205742:	5975                	li	s2,-3
ffffffffc0205744:	bfe9                	j	ffffffffc020571e <sysfile_write+0xac>
ffffffffc0205746:	855a                	mv	a0,s6
ffffffffc0205748:	e19fe0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc020574c:	5975                	li	s2,-3
ffffffffc020574e:	0404a823          	sw	zero,80(s1)
ffffffffc0205752:	b7f1                	j	ffffffffc020571e <sysfile_write+0xac>
ffffffffc0205754:	00f46c63          	bltu	s0,a5,ffffffffc020576c <sysfile_write+0xfa>
ffffffffc0205758:	99be                	add	s3,s3,a5
ffffffffc020575a:	8c1d                	sub	s0,s0,a5
ffffffffc020575c:	9cbe                	add	s9,s9,a5
ffffffffc020575e:	f161                	bnez	a0,ffffffffc020571e <sysfile_write+0xac>
ffffffffc0205760:	fc2d                	bnez	s0,ffffffffc02056da <sysfile_write+0x68>
ffffffffc0205762:	bf75                	j	ffffffffc020571e <sysfile_write+0xac>
ffffffffc0205764:	5975                	li	s2,-3
ffffffffc0205766:	b725                	j	ffffffffc020568e <sysfile_write+0x1c>
ffffffffc0205768:	5971                	li	s2,-4
ffffffffc020576a:	b715                	j	ffffffffc020568e <sysfile_write+0x1c>
ffffffffc020576c:	00008697          	auipc	a3,0x8
ffffffffc0205770:	25468693          	addi	a3,a3,596 # ffffffffc020d9c0 <CSWTCH.84+0xc8>
ffffffffc0205774:	00006617          	auipc	a2,0x6
ffffffffc0205778:	77460613          	addi	a2,a2,1908 # ffffffffc020bee8 <commands+0x210>
ffffffffc020577c:	08a00593          	li	a1,138
ffffffffc0205780:	00008517          	auipc	a0,0x8
ffffffffc0205784:	25050513          	addi	a0,a0,592 # ffffffffc020d9d0 <CSWTCH.84+0xd8>
ffffffffc0205788:	d17fa0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020578c <sysfile_seek>:
ffffffffc020578c:	e36ff06f          	j	ffffffffc0204dc2 <file_seek>

ffffffffc0205790 <sysfile_fstat>:
ffffffffc0205790:	715d                	addi	sp,sp,-80
ffffffffc0205792:	f44e                	sd	s3,40(sp)
ffffffffc0205794:	00091997          	auipc	s3,0x91
ffffffffc0205798:	12c98993          	addi	s3,s3,300 # ffffffffc02968c0 <current>
ffffffffc020579c:	0009b703          	ld	a4,0(s3)
ffffffffc02057a0:	fc26                	sd	s1,56(sp)
ffffffffc02057a2:	84ae                	mv	s1,a1
ffffffffc02057a4:	858a                	mv	a1,sp
ffffffffc02057a6:	e0a2                	sd	s0,64(sp)
ffffffffc02057a8:	f84a                	sd	s2,48(sp)
ffffffffc02057aa:	e486                	sd	ra,72(sp)
ffffffffc02057ac:	02873903          	ld	s2,40(a4)
ffffffffc02057b0:	f052                	sd	s4,32(sp)
ffffffffc02057b2:	f30ff0ef          	jal	ra,ffffffffc0204ee2 <file_fstat>
ffffffffc02057b6:	842a                	mv	s0,a0
ffffffffc02057b8:	e91d                	bnez	a0,ffffffffc02057ee <sysfile_fstat+0x5e>
ffffffffc02057ba:	04090363          	beqz	s2,ffffffffc0205800 <sysfile_fstat+0x70>
ffffffffc02057be:	03890a13          	addi	s4,s2,56
ffffffffc02057c2:	8552                	mv	a0,s4
ffffffffc02057c4:	da1fe0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc02057c8:	0009b783          	ld	a5,0(s3)
ffffffffc02057cc:	c3b9                	beqz	a5,ffffffffc0205812 <sysfile_fstat+0x82>
ffffffffc02057ce:	43dc                	lw	a5,4(a5)
ffffffffc02057d0:	02000693          	li	a3,32
ffffffffc02057d4:	860a                	mv	a2,sp
ffffffffc02057d6:	04f92823          	sw	a5,80(s2)
ffffffffc02057da:	85a6                	mv	a1,s1
ffffffffc02057dc:	854a                	mv	a0,s2
ffffffffc02057de:	b7dfe0ef          	jal	ra,ffffffffc020435a <copy_to_user>
ffffffffc02057e2:	c121                	beqz	a0,ffffffffc0205822 <sysfile_fstat+0x92>
ffffffffc02057e4:	8552                	mv	a0,s4
ffffffffc02057e6:	d7bfe0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc02057ea:	04092823          	sw	zero,80(s2)
ffffffffc02057ee:	60a6                	ld	ra,72(sp)
ffffffffc02057f0:	8522                	mv	a0,s0
ffffffffc02057f2:	6406                	ld	s0,64(sp)
ffffffffc02057f4:	74e2                	ld	s1,56(sp)
ffffffffc02057f6:	7942                	ld	s2,48(sp)
ffffffffc02057f8:	79a2                	ld	s3,40(sp)
ffffffffc02057fa:	7a02                	ld	s4,32(sp)
ffffffffc02057fc:	6161                	addi	sp,sp,80
ffffffffc02057fe:	8082                	ret
ffffffffc0205800:	02000693          	li	a3,32
ffffffffc0205804:	860a                	mv	a2,sp
ffffffffc0205806:	85a6                	mv	a1,s1
ffffffffc0205808:	b53fe0ef          	jal	ra,ffffffffc020435a <copy_to_user>
ffffffffc020580c:	f16d                	bnez	a0,ffffffffc02057ee <sysfile_fstat+0x5e>
ffffffffc020580e:	5475                	li	s0,-3
ffffffffc0205810:	bff9                	j	ffffffffc02057ee <sysfile_fstat+0x5e>
ffffffffc0205812:	02000693          	li	a3,32
ffffffffc0205816:	860a                	mv	a2,sp
ffffffffc0205818:	85a6                	mv	a1,s1
ffffffffc020581a:	854a                	mv	a0,s2
ffffffffc020581c:	b3ffe0ef          	jal	ra,ffffffffc020435a <copy_to_user>
ffffffffc0205820:	f171                	bnez	a0,ffffffffc02057e4 <sysfile_fstat+0x54>
ffffffffc0205822:	8552                	mv	a0,s4
ffffffffc0205824:	d3dfe0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0205828:	5475                	li	s0,-3
ffffffffc020582a:	04092823          	sw	zero,80(s2)
ffffffffc020582e:	b7c1                	j	ffffffffc02057ee <sysfile_fstat+0x5e>

ffffffffc0205830 <sysfile_fsync>:
ffffffffc0205830:	f72ff06f          	j	ffffffffc0204fa2 <file_fsync>

ffffffffc0205834 <sysfile_getcwd>:
ffffffffc0205834:	715d                	addi	sp,sp,-80
ffffffffc0205836:	f44e                	sd	s3,40(sp)
ffffffffc0205838:	00091997          	auipc	s3,0x91
ffffffffc020583c:	08898993          	addi	s3,s3,136 # ffffffffc02968c0 <current>
ffffffffc0205840:	0009b783          	ld	a5,0(s3)
ffffffffc0205844:	f84a                	sd	s2,48(sp)
ffffffffc0205846:	e486                	sd	ra,72(sp)
ffffffffc0205848:	e0a2                	sd	s0,64(sp)
ffffffffc020584a:	fc26                	sd	s1,56(sp)
ffffffffc020584c:	f052                	sd	s4,32(sp)
ffffffffc020584e:	0287b903          	ld	s2,40(a5)
ffffffffc0205852:	cda9                	beqz	a1,ffffffffc02058ac <sysfile_getcwd+0x78>
ffffffffc0205854:	842e                	mv	s0,a1
ffffffffc0205856:	84aa                	mv	s1,a0
ffffffffc0205858:	04090363          	beqz	s2,ffffffffc020589e <sysfile_getcwd+0x6a>
ffffffffc020585c:	03890a13          	addi	s4,s2,56
ffffffffc0205860:	8552                	mv	a0,s4
ffffffffc0205862:	d03fe0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc0205866:	0009b783          	ld	a5,0(s3)
ffffffffc020586a:	c781                	beqz	a5,ffffffffc0205872 <sysfile_getcwd+0x3e>
ffffffffc020586c:	43dc                	lw	a5,4(a5)
ffffffffc020586e:	04f92823          	sw	a5,80(s2)
ffffffffc0205872:	4685                	li	a3,1
ffffffffc0205874:	8622                	mv	a2,s0
ffffffffc0205876:	85a6                	mv	a1,s1
ffffffffc0205878:	854a                	mv	a0,s2
ffffffffc020587a:	a19fe0ef          	jal	ra,ffffffffc0204292 <user_mem_check>
ffffffffc020587e:	e90d                	bnez	a0,ffffffffc02058b0 <sysfile_getcwd+0x7c>
ffffffffc0205880:	5475                	li	s0,-3
ffffffffc0205882:	8552                	mv	a0,s4
ffffffffc0205884:	cddfe0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0205888:	04092823          	sw	zero,80(s2)
ffffffffc020588c:	60a6                	ld	ra,72(sp)
ffffffffc020588e:	8522                	mv	a0,s0
ffffffffc0205890:	6406                	ld	s0,64(sp)
ffffffffc0205892:	74e2                	ld	s1,56(sp)
ffffffffc0205894:	7942                	ld	s2,48(sp)
ffffffffc0205896:	79a2                	ld	s3,40(sp)
ffffffffc0205898:	7a02                	ld	s4,32(sp)
ffffffffc020589a:	6161                	addi	sp,sp,80
ffffffffc020589c:	8082                	ret
ffffffffc020589e:	862e                	mv	a2,a1
ffffffffc02058a0:	4685                	li	a3,1
ffffffffc02058a2:	85aa                	mv	a1,a0
ffffffffc02058a4:	4501                	li	a0,0
ffffffffc02058a6:	9edfe0ef          	jal	ra,ffffffffc0204292 <user_mem_check>
ffffffffc02058aa:	ed09                	bnez	a0,ffffffffc02058c4 <sysfile_getcwd+0x90>
ffffffffc02058ac:	5475                	li	s0,-3
ffffffffc02058ae:	bff9                	j	ffffffffc020588c <sysfile_getcwd+0x58>
ffffffffc02058b0:	8622                	mv	a2,s0
ffffffffc02058b2:	4681                	li	a3,0
ffffffffc02058b4:	85a6                	mv	a1,s1
ffffffffc02058b6:	850a                	mv	a0,sp
ffffffffc02058b8:	b2bff0ef          	jal	ra,ffffffffc02053e2 <iobuf_init>
ffffffffc02058bc:	5db020ef          	jal	ra,ffffffffc0208696 <vfs_getcwd>
ffffffffc02058c0:	842a                	mv	s0,a0
ffffffffc02058c2:	b7c1                	j	ffffffffc0205882 <sysfile_getcwd+0x4e>
ffffffffc02058c4:	8622                	mv	a2,s0
ffffffffc02058c6:	4681                	li	a3,0
ffffffffc02058c8:	85a6                	mv	a1,s1
ffffffffc02058ca:	850a                	mv	a0,sp
ffffffffc02058cc:	b17ff0ef          	jal	ra,ffffffffc02053e2 <iobuf_init>
ffffffffc02058d0:	5c7020ef          	jal	ra,ffffffffc0208696 <vfs_getcwd>
ffffffffc02058d4:	842a                	mv	s0,a0
ffffffffc02058d6:	bf5d                	j	ffffffffc020588c <sysfile_getcwd+0x58>

ffffffffc02058d8 <sysfile_getdirentry>:
ffffffffc02058d8:	7139                	addi	sp,sp,-64
ffffffffc02058da:	e852                	sd	s4,16(sp)
ffffffffc02058dc:	00091a17          	auipc	s4,0x91
ffffffffc02058e0:	fe4a0a13          	addi	s4,s4,-28 # ffffffffc02968c0 <current>
ffffffffc02058e4:	000a3703          	ld	a4,0(s4)
ffffffffc02058e8:	ec4e                	sd	s3,24(sp)
ffffffffc02058ea:	89aa                	mv	s3,a0
ffffffffc02058ec:	10800513          	li	a0,264
ffffffffc02058f0:	f426                	sd	s1,40(sp)
ffffffffc02058f2:	f04a                	sd	s2,32(sp)
ffffffffc02058f4:	fc06                	sd	ra,56(sp)
ffffffffc02058f6:	f822                	sd	s0,48(sp)
ffffffffc02058f8:	e456                	sd	s5,8(sp)
ffffffffc02058fa:	7704                	ld	s1,40(a4)
ffffffffc02058fc:	892e                	mv	s2,a1
ffffffffc02058fe:	e90fc0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc0205902:	c169                	beqz	a0,ffffffffc02059c4 <sysfile_getdirentry+0xec>
ffffffffc0205904:	842a                	mv	s0,a0
ffffffffc0205906:	c8c1                	beqz	s1,ffffffffc0205996 <sysfile_getdirentry+0xbe>
ffffffffc0205908:	03848a93          	addi	s5,s1,56
ffffffffc020590c:	8556                	mv	a0,s5
ffffffffc020590e:	c57fe0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc0205912:	000a3783          	ld	a5,0(s4)
ffffffffc0205916:	c399                	beqz	a5,ffffffffc020591c <sysfile_getdirentry+0x44>
ffffffffc0205918:	43dc                	lw	a5,4(a5)
ffffffffc020591a:	c8bc                	sw	a5,80(s1)
ffffffffc020591c:	4705                	li	a4,1
ffffffffc020591e:	46a1                	li	a3,8
ffffffffc0205920:	864a                	mv	a2,s2
ffffffffc0205922:	85a2                	mv	a1,s0
ffffffffc0205924:	8526                	mv	a0,s1
ffffffffc0205926:	a01fe0ef          	jal	ra,ffffffffc0204326 <copy_from_user>
ffffffffc020592a:	e505                	bnez	a0,ffffffffc0205952 <sysfile_getdirentry+0x7a>
ffffffffc020592c:	8556                	mv	a0,s5
ffffffffc020592e:	c33fe0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0205932:	59f5                	li	s3,-3
ffffffffc0205934:	0404a823          	sw	zero,80(s1)
ffffffffc0205938:	8522                	mv	a0,s0
ffffffffc020593a:	f04fc0ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020593e:	70e2                	ld	ra,56(sp)
ffffffffc0205940:	7442                	ld	s0,48(sp)
ffffffffc0205942:	74a2                	ld	s1,40(sp)
ffffffffc0205944:	7902                	ld	s2,32(sp)
ffffffffc0205946:	6a42                	ld	s4,16(sp)
ffffffffc0205948:	6aa2                	ld	s5,8(sp)
ffffffffc020594a:	854e                	mv	a0,s3
ffffffffc020594c:	69e2                	ld	s3,24(sp)
ffffffffc020594e:	6121                	addi	sp,sp,64
ffffffffc0205950:	8082                	ret
ffffffffc0205952:	8556                	mv	a0,s5
ffffffffc0205954:	c0dfe0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0205958:	854e                	mv	a0,s3
ffffffffc020595a:	85a2                	mv	a1,s0
ffffffffc020595c:	0404a823          	sw	zero,80(s1)
ffffffffc0205960:	ef0ff0ef          	jal	ra,ffffffffc0205050 <file_getdirentry>
ffffffffc0205964:	89aa                	mv	s3,a0
ffffffffc0205966:	f969                	bnez	a0,ffffffffc0205938 <sysfile_getdirentry+0x60>
ffffffffc0205968:	8556                	mv	a0,s5
ffffffffc020596a:	bfbfe0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc020596e:	000a3783          	ld	a5,0(s4)
ffffffffc0205972:	c399                	beqz	a5,ffffffffc0205978 <sysfile_getdirentry+0xa0>
ffffffffc0205974:	43dc                	lw	a5,4(a5)
ffffffffc0205976:	c8bc                	sw	a5,80(s1)
ffffffffc0205978:	10800693          	li	a3,264
ffffffffc020597c:	8622                	mv	a2,s0
ffffffffc020597e:	85ca                	mv	a1,s2
ffffffffc0205980:	8526                	mv	a0,s1
ffffffffc0205982:	9d9fe0ef          	jal	ra,ffffffffc020435a <copy_to_user>
ffffffffc0205986:	e111                	bnez	a0,ffffffffc020598a <sysfile_getdirentry+0xb2>
ffffffffc0205988:	59f5                	li	s3,-3
ffffffffc020598a:	8556                	mv	a0,s5
ffffffffc020598c:	bd5fe0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0205990:	0404a823          	sw	zero,80(s1)
ffffffffc0205994:	b755                	j	ffffffffc0205938 <sysfile_getdirentry+0x60>
ffffffffc0205996:	85aa                	mv	a1,a0
ffffffffc0205998:	4705                	li	a4,1
ffffffffc020599a:	46a1                	li	a3,8
ffffffffc020599c:	864a                	mv	a2,s2
ffffffffc020599e:	4501                	li	a0,0
ffffffffc02059a0:	987fe0ef          	jal	ra,ffffffffc0204326 <copy_from_user>
ffffffffc02059a4:	cd11                	beqz	a0,ffffffffc02059c0 <sysfile_getdirentry+0xe8>
ffffffffc02059a6:	854e                	mv	a0,s3
ffffffffc02059a8:	85a2                	mv	a1,s0
ffffffffc02059aa:	ea6ff0ef          	jal	ra,ffffffffc0205050 <file_getdirentry>
ffffffffc02059ae:	89aa                	mv	s3,a0
ffffffffc02059b0:	f541                	bnez	a0,ffffffffc0205938 <sysfile_getdirentry+0x60>
ffffffffc02059b2:	10800693          	li	a3,264
ffffffffc02059b6:	8622                	mv	a2,s0
ffffffffc02059b8:	85ca                	mv	a1,s2
ffffffffc02059ba:	9a1fe0ef          	jal	ra,ffffffffc020435a <copy_to_user>
ffffffffc02059be:	fd2d                	bnez	a0,ffffffffc0205938 <sysfile_getdirentry+0x60>
ffffffffc02059c0:	59f5                	li	s3,-3
ffffffffc02059c2:	bf9d                	j	ffffffffc0205938 <sysfile_getdirentry+0x60>
ffffffffc02059c4:	59f1                	li	s3,-4
ffffffffc02059c6:	bfa5                	j	ffffffffc020593e <sysfile_getdirentry+0x66>

ffffffffc02059c8 <sysfile_dup>:
ffffffffc02059c8:	f6eff06f          	j	ffffffffc0205136 <file_dup>

ffffffffc02059cc <kernel_thread_entry>:
ffffffffc02059cc:	8526                	mv	a0,s1
ffffffffc02059ce:	9402                	jalr	s0
ffffffffc02059d0:	61c000ef          	jal	ra,ffffffffc0205fec <do_exit>

ffffffffc02059d4 <alloc_proc>:
ffffffffc02059d4:	1141                	addi	sp,sp,-16
ffffffffc02059d6:	15000513          	li	a0,336
ffffffffc02059da:	e022                	sd	s0,0(sp)
ffffffffc02059dc:	e406                	sd	ra,8(sp)
ffffffffc02059de:	db0fc0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc02059e2:	842a                	mv	s0,a0
ffffffffc02059e4:	c141                	beqz	a0,ffffffffc0205a64 <alloc_proc+0x90>
ffffffffc02059e6:	57fd                	li	a5,-1
ffffffffc02059e8:	1782                	slli	a5,a5,0x20
ffffffffc02059ea:	e11c                	sd	a5,0(a0)
ffffffffc02059ec:	07000613          	li	a2,112
ffffffffc02059f0:	4581                	li	a1,0
ffffffffc02059f2:	00052423          	sw	zero,8(a0)
ffffffffc02059f6:	00053823          	sd	zero,16(a0)
ffffffffc02059fa:	00053c23          	sd	zero,24(a0)
ffffffffc02059fe:	02053023          	sd	zero,32(a0)
ffffffffc0205a02:	02053423          	sd	zero,40(a0)
ffffffffc0205a06:	03050513          	addi	a0,a0,48
ffffffffc0205a0a:	7fb050ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc0205a0e:	00091797          	auipc	a5,0x91
ffffffffc0205a12:	e827b783          	ld	a5,-382(a5) # ffffffffc0296890 <boot_pgdir_pa>
ffffffffc0205a16:	f45c                	sd	a5,168(s0)
ffffffffc0205a18:	0a043023          	sd	zero,160(s0)
ffffffffc0205a1c:	0a042823          	sw	zero,176(s0)
ffffffffc0205a20:	463d                	li	a2,15
ffffffffc0205a22:	4581                	li	a1,0
ffffffffc0205a24:	0b440513          	addi	a0,s0,180
ffffffffc0205a28:	7dd050ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc0205a2c:	11040793          	addi	a5,s0,272
ffffffffc0205a30:	0e042623          	sw	zero,236(s0)
ffffffffc0205a34:	0e043c23          	sd	zero,248(s0)
ffffffffc0205a38:	10043023          	sd	zero,256(s0)
ffffffffc0205a3c:	0e043823          	sd	zero,240(s0)
ffffffffc0205a40:	10043423          	sd	zero,264(s0)
ffffffffc0205a44:	10f43c23          	sd	a5,280(s0)
ffffffffc0205a48:	10f43823          	sd	a5,272(s0)
ffffffffc0205a4c:	12042023          	sw	zero,288(s0)
ffffffffc0205a50:	12043423          	sd	zero,296(s0)
ffffffffc0205a54:	12043823          	sd	zero,304(s0)
ffffffffc0205a58:	12043c23          	sd	zero,312(s0)
ffffffffc0205a5c:	14043023          	sd	zero,320(s0)
ffffffffc0205a60:	14043423          	sd	zero,328(s0)
ffffffffc0205a64:	60a2                	ld	ra,8(sp)
ffffffffc0205a66:	8522                	mv	a0,s0
ffffffffc0205a68:	6402                	ld	s0,0(sp)
ffffffffc0205a6a:	0141                	addi	sp,sp,16
ffffffffc0205a6c:	8082                	ret

ffffffffc0205a6e <forkret>:
ffffffffc0205a6e:	00091797          	auipc	a5,0x91
ffffffffc0205a72:	e527b783          	ld	a5,-430(a5) # ffffffffc02968c0 <current>
ffffffffc0205a76:	73c8                	ld	a0,160(a5)
ffffffffc0205a78:	833fb06f          	j	ffffffffc02012aa <forkrets>

ffffffffc0205a7c <put_pgdir.isra.0>:
ffffffffc0205a7c:	1141                	addi	sp,sp,-16
ffffffffc0205a7e:	e406                	sd	ra,8(sp)
ffffffffc0205a80:	c02007b7          	lui	a5,0xc0200
ffffffffc0205a84:	02f56e63          	bltu	a0,a5,ffffffffc0205ac0 <put_pgdir.isra.0+0x44>
ffffffffc0205a88:	00091697          	auipc	a3,0x91
ffffffffc0205a8c:	e306b683          	ld	a3,-464(a3) # ffffffffc02968b8 <va_pa_offset>
ffffffffc0205a90:	8d15                	sub	a0,a0,a3
ffffffffc0205a92:	8131                	srli	a0,a0,0xc
ffffffffc0205a94:	00091797          	auipc	a5,0x91
ffffffffc0205a98:	e0c7b783          	ld	a5,-500(a5) # ffffffffc02968a0 <npage>
ffffffffc0205a9c:	02f57f63          	bgeu	a0,a5,ffffffffc0205ada <put_pgdir.isra.0+0x5e>
ffffffffc0205aa0:	0000a697          	auipc	a3,0xa
ffffffffc0205aa4:	3306b683          	ld	a3,816(a3) # ffffffffc020fdd0 <nbase>
ffffffffc0205aa8:	60a2                	ld	ra,8(sp)
ffffffffc0205aaa:	8d15                	sub	a0,a0,a3
ffffffffc0205aac:	00091797          	auipc	a5,0x91
ffffffffc0205ab0:	dfc7b783          	ld	a5,-516(a5) # ffffffffc02968a8 <pages>
ffffffffc0205ab4:	051a                	slli	a0,a0,0x6
ffffffffc0205ab6:	4585                	li	a1,1
ffffffffc0205ab8:	953e                	add	a0,a0,a5
ffffffffc0205aba:	0141                	addi	sp,sp,16
ffffffffc0205abc:	eeefc06f          	j	ffffffffc02021aa <free_pages>
ffffffffc0205ac0:	86aa                	mv	a3,a0
ffffffffc0205ac2:	00007617          	auipc	a2,0x7
ffffffffc0205ac6:	fee60613          	addi	a2,a2,-18 # ffffffffc020cab0 <default_pmm_manager+0xe0>
ffffffffc0205aca:	07700593          	li	a1,119
ffffffffc0205ace:	00007517          	auipc	a0,0x7
ffffffffc0205ad2:	f6250513          	addi	a0,a0,-158 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0205ad6:	9c9fa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0205ada:	00007617          	auipc	a2,0x7
ffffffffc0205ade:	ffe60613          	addi	a2,a2,-2 # ffffffffc020cad8 <default_pmm_manager+0x108>
ffffffffc0205ae2:	06900593          	li	a1,105
ffffffffc0205ae6:	00007517          	auipc	a0,0x7
ffffffffc0205aea:	f4a50513          	addi	a0,a0,-182 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0205aee:	9b1fa0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0205af2 <proc_run>:
ffffffffc0205af2:	7179                	addi	sp,sp,-48
ffffffffc0205af4:	ec4a                	sd	s2,24(sp)
ffffffffc0205af6:	00091917          	auipc	s2,0x91
ffffffffc0205afa:	dca90913          	addi	s2,s2,-566 # ffffffffc02968c0 <current>
ffffffffc0205afe:	f026                	sd	s1,32(sp)
ffffffffc0205b00:	00093483          	ld	s1,0(s2)
ffffffffc0205b04:	f406                	sd	ra,40(sp)
ffffffffc0205b06:	e84e                	sd	s3,16(sp)
ffffffffc0205b08:	02a48a63          	beq	s1,a0,ffffffffc0205b3c <proc_run+0x4a>
ffffffffc0205b0c:	100027f3          	csrr	a5,sstatus
ffffffffc0205b10:	8b89                	andi	a5,a5,2
ffffffffc0205b12:	4981                	li	s3,0
ffffffffc0205b14:	e3a9                	bnez	a5,ffffffffc0205b56 <proc_run+0x64>
ffffffffc0205b16:	755c                	ld	a5,168(a0)
ffffffffc0205b18:	577d                	li	a4,-1
ffffffffc0205b1a:	177e                	slli	a4,a4,0x3f
ffffffffc0205b1c:	83b1                	srli	a5,a5,0xc
ffffffffc0205b1e:	00a93023          	sd	a0,0(s2)
ffffffffc0205b22:	8fd9                	or	a5,a5,a4
ffffffffc0205b24:	18079073          	csrw	satp,a5
ffffffffc0205b28:	12000073          	sfence.vma
ffffffffc0205b2c:	03050593          	addi	a1,a0,48
ffffffffc0205b30:	03048513          	addi	a0,s1,48
ffffffffc0205b34:	580010ef          	jal	ra,ffffffffc02070b4 <switch_to>
ffffffffc0205b38:	00099863          	bnez	s3,ffffffffc0205b48 <proc_run+0x56>
ffffffffc0205b3c:	70a2                	ld	ra,40(sp)
ffffffffc0205b3e:	7482                	ld	s1,32(sp)
ffffffffc0205b40:	6962                	ld	s2,24(sp)
ffffffffc0205b42:	69c2                	ld	s3,16(sp)
ffffffffc0205b44:	6145                	addi	sp,sp,48
ffffffffc0205b46:	8082                	ret
ffffffffc0205b48:	70a2                	ld	ra,40(sp)
ffffffffc0205b4a:	7482                	ld	s1,32(sp)
ffffffffc0205b4c:	6962                	ld	s2,24(sp)
ffffffffc0205b4e:	69c2                	ld	s3,16(sp)
ffffffffc0205b50:	6145                	addi	sp,sp,48
ffffffffc0205b52:	91afb06f          	j	ffffffffc0200c6c <intr_enable>
ffffffffc0205b56:	e42a                	sd	a0,8(sp)
ffffffffc0205b58:	91afb0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0205b5c:	6522                	ld	a0,8(sp)
ffffffffc0205b5e:	4985                	li	s3,1
ffffffffc0205b60:	bf5d                	j	ffffffffc0205b16 <proc_run+0x24>

ffffffffc0205b62 <do_fork>:
ffffffffc0205b62:	7119                	addi	sp,sp,-128
ffffffffc0205b64:	f0ca                	sd	s2,96(sp)
ffffffffc0205b66:	00091917          	auipc	s2,0x91
ffffffffc0205b6a:	d7290913          	addi	s2,s2,-654 # ffffffffc02968d8 <nr_process>
ffffffffc0205b6e:	00092703          	lw	a4,0(s2)
ffffffffc0205b72:	fc86                	sd	ra,120(sp)
ffffffffc0205b74:	f8a2                	sd	s0,112(sp)
ffffffffc0205b76:	f4a6                	sd	s1,104(sp)
ffffffffc0205b78:	ecce                	sd	s3,88(sp)
ffffffffc0205b7a:	e8d2                	sd	s4,80(sp)
ffffffffc0205b7c:	e4d6                	sd	s5,72(sp)
ffffffffc0205b7e:	e0da                	sd	s6,64(sp)
ffffffffc0205b80:	fc5e                	sd	s7,56(sp)
ffffffffc0205b82:	f862                	sd	s8,48(sp)
ffffffffc0205b84:	f466                	sd	s9,40(sp)
ffffffffc0205b86:	f06a                	sd	s10,32(sp)
ffffffffc0205b88:	ec6e                	sd	s11,24(sp)
ffffffffc0205b8a:	6785                	lui	a5,0x1
ffffffffc0205b8c:	e032                	sd	a2,0(sp)
ffffffffc0205b8e:	36f75263          	bge	a4,a5,ffffffffc0205ef2 <do_fork+0x390>
ffffffffc0205b92:	89aa                	mv	s3,a0
ffffffffc0205b94:	8a2e                	mv	s4,a1
ffffffffc0205b96:	e3fff0ef          	jal	ra,ffffffffc02059d4 <alloc_proc>
ffffffffc0205b9a:	842a                	mv	s0,a0
ffffffffc0205b9c:	2a050363          	beqz	a0,ffffffffc0205e42 <do_fork+0x2e0>
ffffffffc0205ba0:	00091d97          	auipc	s11,0x91
ffffffffc0205ba4:	d20d8d93          	addi	s11,s11,-736 # ffffffffc02968c0 <current>
ffffffffc0205ba8:	000db783          	ld	a5,0(s11)
ffffffffc0205bac:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_bin_swap_img_size-0x6c14>
ffffffffc0205bb0:	f11c                	sd	a5,32(a0)
ffffffffc0205bb2:	3a071963          	bnez	a4,ffffffffc0205f64 <do_fork+0x402>
ffffffffc0205bb6:	4509                	li	a0,2
ffffffffc0205bb8:	db4fc0ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc0205bbc:	28050063          	beqz	a0,ffffffffc0205e3c <do_fork+0x2da>
ffffffffc0205bc0:	00091b17          	auipc	s6,0x91
ffffffffc0205bc4:	ce8b0b13          	addi	s6,s6,-792 # ffffffffc02968a8 <pages>
ffffffffc0205bc8:	000b3683          	ld	a3,0(s6)
ffffffffc0205bcc:	00091b97          	auipc	s7,0x91
ffffffffc0205bd0:	cd4b8b93          	addi	s7,s7,-812 # ffffffffc02968a0 <npage>
ffffffffc0205bd4:	0000aa97          	auipc	s5,0xa
ffffffffc0205bd8:	1fcaba83          	ld	s5,508(s5) # ffffffffc020fdd0 <nbase>
ffffffffc0205bdc:	40d506b3          	sub	a3,a0,a3
ffffffffc0205be0:	8699                	srai	a3,a3,0x6
ffffffffc0205be2:	5c7d                	li	s8,-1
ffffffffc0205be4:	000bb783          	ld	a5,0(s7)
ffffffffc0205be8:	96d6                	add	a3,a3,s5
ffffffffc0205bea:	00cc5c13          	srli	s8,s8,0xc
ffffffffc0205bee:	0186f733          	and	a4,a3,s8
ffffffffc0205bf2:	06b2                	slli	a3,a3,0xc
ffffffffc0205bf4:	38f77863          	bgeu	a4,a5,ffffffffc0205f84 <do_fork+0x422>
ffffffffc0205bf8:	000db603          	ld	a2,0(s11)
ffffffffc0205bfc:	00091c97          	auipc	s9,0x91
ffffffffc0205c00:	cbcc8c93          	addi	s9,s9,-836 # ffffffffc02968b8 <va_pa_offset>
ffffffffc0205c04:	000cb703          	ld	a4,0(s9)
ffffffffc0205c08:	7604                	ld	s1,40(a2)
ffffffffc0205c0a:	96ba                	add	a3,a3,a4
ffffffffc0205c0c:	e814                	sd	a3,16(s0)
ffffffffc0205c0e:	c485                	beqz	s1,ffffffffc0205c36 <do_fork+0xd4>
ffffffffc0205c10:	1009f713          	andi	a4,s3,256
ffffffffc0205c14:	22070963          	beqz	a4,ffffffffc0205e46 <do_fork+0x2e4>
ffffffffc0205c18:	5898                	lw	a4,48(s1)
ffffffffc0205c1a:	6c94                	ld	a3,24(s1)
ffffffffc0205c1c:	c0200637          	lui	a2,0xc0200
ffffffffc0205c20:	2705                	addiw	a4,a4,1
ffffffffc0205c22:	d898                	sw	a4,48(s1)
ffffffffc0205c24:	f404                	sd	s1,40(s0)
ffffffffc0205c26:	2ec6eb63          	bltu	a3,a2,ffffffffc0205f1c <do_fork+0x3ba>
ffffffffc0205c2a:	000cb783          	ld	a5,0(s9)
ffffffffc0205c2e:	000db603          	ld	a2,0(s11)
ffffffffc0205c32:	8e9d                	sub	a3,a3,a5
ffffffffc0205c34:	f454                	sd	a3,168(s0)
ffffffffc0205c36:	14863c03          	ld	s8,328(a2) # ffffffffc0200148 <readline+0x96>
ffffffffc0205c3a:	2c0c0163          	beqz	s8,ffffffffc0205efc <do_fork+0x39a>
ffffffffc0205c3e:	00b9d993          	srli	s3,s3,0xb
ffffffffc0205c42:	0019f993          	andi	s3,s3,1
ffffffffc0205c46:	1a098763          	beqz	s3,ffffffffc0205df4 <do_fork+0x292>
ffffffffc0205c4a:	010c2783          	lw	a5,16(s8)
ffffffffc0205c4e:	6818                	ld	a4,16(s0)
ffffffffc0205c50:	6602                	ld	a2,0(sp)
ffffffffc0205c52:	2785                	addiw	a5,a5,1
ffffffffc0205c54:	00fc2823          	sw	a5,16(s8)
ffffffffc0205c58:	6789                	lui	a5,0x2
ffffffffc0205c5a:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_bin_swap_img_size-0x5e20>
ffffffffc0205c5e:	973e                	add	a4,a4,a5
ffffffffc0205c60:	15843423          	sd	s8,328(s0)
ffffffffc0205c64:	f058                	sd	a4,160(s0)
ffffffffc0205c66:	87ba                	mv	a5,a4
ffffffffc0205c68:	12060893          	addi	a7,a2,288
ffffffffc0205c6c:	00063803          	ld	a6,0(a2)
ffffffffc0205c70:	6608                	ld	a0,8(a2)
ffffffffc0205c72:	6a0c                	ld	a1,16(a2)
ffffffffc0205c74:	6e14                	ld	a3,24(a2)
ffffffffc0205c76:	0107b023          	sd	a6,0(a5)
ffffffffc0205c7a:	e788                	sd	a0,8(a5)
ffffffffc0205c7c:	eb8c                	sd	a1,16(a5)
ffffffffc0205c7e:	ef94                	sd	a3,24(a5)
ffffffffc0205c80:	02060613          	addi	a2,a2,32
ffffffffc0205c84:	02078793          	addi	a5,a5,32
ffffffffc0205c88:	ff1612e3          	bne	a2,a7,ffffffffc0205c6c <do_fork+0x10a>
ffffffffc0205c8c:	04073823          	sd	zero,80(a4)
ffffffffc0205c90:	120a0f63          	beqz	s4,ffffffffc0205dce <do_fork+0x26c>
ffffffffc0205c94:	01473823          	sd	s4,16(a4)
ffffffffc0205c98:	00000797          	auipc	a5,0x0
ffffffffc0205c9c:	dd678793          	addi	a5,a5,-554 # ffffffffc0205a6e <forkret>
ffffffffc0205ca0:	f81c                	sd	a5,48(s0)
ffffffffc0205ca2:	fc18                	sd	a4,56(s0)
ffffffffc0205ca4:	100027f3          	csrr	a5,sstatus
ffffffffc0205ca8:	8b89                	andi	a5,a5,2
ffffffffc0205caa:	4981                	li	s3,0
ffffffffc0205cac:	14079063          	bnez	a5,ffffffffc0205dec <do_fork+0x28a>
ffffffffc0205cb0:	0008b817          	auipc	a6,0x8b
ffffffffc0205cb4:	3a880813          	addi	a6,a6,936 # ffffffffc0291058 <last_pid.1>
ffffffffc0205cb8:	00082783          	lw	a5,0(a6)
ffffffffc0205cbc:	6709                	lui	a4,0x2
ffffffffc0205cbe:	0017851b          	addiw	a0,a5,1
ffffffffc0205cc2:	00a82023          	sw	a0,0(a6)
ffffffffc0205cc6:	08e55d63          	bge	a0,a4,ffffffffc0205d60 <do_fork+0x1fe>
ffffffffc0205cca:	0008b317          	auipc	t1,0x8b
ffffffffc0205cce:	39230313          	addi	t1,t1,914 # ffffffffc029105c <next_safe.0>
ffffffffc0205cd2:	00032783          	lw	a5,0(t1)
ffffffffc0205cd6:	00090497          	auipc	s1,0x90
ffffffffc0205cda:	aea48493          	addi	s1,s1,-1302 # ffffffffc02957c0 <proc_list>
ffffffffc0205cde:	08f55963          	bge	a0,a5,ffffffffc0205d70 <do_fork+0x20e>
ffffffffc0205ce2:	c048                	sw	a0,4(s0)
ffffffffc0205ce4:	45a9                	li	a1,10
ffffffffc0205ce6:	2501                	sext.w	a0,a0
ffffffffc0205ce8:	7c0050ef          	jal	ra,ffffffffc020b4a8 <hash32>
ffffffffc0205cec:	02051793          	slli	a5,a0,0x20
ffffffffc0205cf0:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205cf4:	0008c797          	auipc	a5,0x8c
ffffffffc0205cf8:	acc78793          	addi	a5,a5,-1332 # ffffffffc02917c0 <hash_list>
ffffffffc0205cfc:	953e                	add	a0,a0,a5
ffffffffc0205cfe:	650c                	ld	a1,8(a0)
ffffffffc0205d00:	7014                	ld	a3,32(s0)
ffffffffc0205d02:	0d840793          	addi	a5,s0,216
ffffffffc0205d06:	e19c                	sd	a5,0(a1)
ffffffffc0205d08:	6490                	ld	a2,8(s1)
ffffffffc0205d0a:	e51c                	sd	a5,8(a0)
ffffffffc0205d0c:	7af8                	ld	a4,240(a3)
ffffffffc0205d0e:	0c840793          	addi	a5,s0,200
ffffffffc0205d12:	f06c                	sd	a1,224(s0)
ffffffffc0205d14:	ec68                	sd	a0,216(s0)
ffffffffc0205d16:	e21c                	sd	a5,0(a2)
ffffffffc0205d18:	e49c                	sd	a5,8(s1)
ffffffffc0205d1a:	e870                	sd	a2,208(s0)
ffffffffc0205d1c:	e464                	sd	s1,200(s0)
ffffffffc0205d1e:	0e043c23          	sd	zero,248(s0)
ffffffffc0205d22:	10e43023          	sd	a4,256(s0)
ffffffffc0205d26:	c311                	beqz	a4,ffffffffc0205d2a <do_fork+0x1c8>
ffffffffc0205d28:	ff60                	sd	s0,248(a4)
ffffffffc0205d2a:	00092783          	lw	a5,0(s2)
ffffffffc0205d2e:	fae0                	sd	s0,240(a3)
ffffffffc0205d30:	2785                	addiw	a5,a5,1
ffffffffc0205d32:	00f92023          	sw	a5,0(s2)
ffffffffc0205d36:	18099663          	bnez	s3,ffffffffc0205ec2 <do_fork+0x360>
ffffffffc0205d3a:	8522                	mv	a0,s0
ffffffffc0205d3c:	51c010ef          	jal	ra,ffffffffc0207258 <wakeup_proc>
ffffffffc0205d40:	4048                	lw	a0,4(s0)
ffffffffc0205d42:	70e6                	ld	ra,120(sp)
ffffffffc0205d44:	7446                	ld	s0,112(sp)
ffffffffc0205d46:	74a6                	ld	s1,104(sp)
ffffffffc0205d48:	7906                	ld	s2,96(sp)
ffffffffc0205d4a:	69e6                	ld	s3,88(sp)
ffffffffc0205d4c:	6a46                	ld	s4,80(sp)
ffffffffc0205d4e:	6aa6                	ld	s5,72(sp)
ffffffffc0205d50:	6b06                	ld	s6,64(sp)
ffffffffc0205d52:	7be2                	ld	s7,56(sp)
ffffffffc0205d54:	7c42                	ld	s8,48(sp)
ffffffffc0205d56:	7ca2                	ld	s9,40(sp)
ffffffffc0205d58:	7d02                	ld	s10,32(sp)
ffffffffc0205d5a:	6de2                	ld	s11,24(sp)
ffffffffc0205d5c:	6109                	addi	sp,sp,128
ffffffffc0205d5e:	8082                	ret
ffffffffc0205d60:	4785                	li	a5,1
ffffffffc0205d62:	00f82023          	sw	a5,0(a6)
ffffffffc0205d66:	4505                	li	a0,1
ffffffffc0205d68:	0008b317          	auipc	t1,0x8b
ffffffffc0205d6c:	2f430313          	addi	t1,t1,756 # ffffffffc029105c <next_safe.0>
ffffffffc0205d70:	00090497          	auipc	s1,0x90
ffffffffc0205d74:	a5048493          	addi	s1,s1,-1456 # ffffffffc02957c0 <proc_list>
ffffffffc0205d78:	0084be03          	ld	t3,8(s1)
ffffffffc0205d7c:	6789                	lui	a5,0x2
ffffffffc0205d7e:	00f32023          	sw	a5,0(t1)
ffffffffc0205d82:	86aa                	mv	a3,a0
ffffffffc0205d84:	4581                	li	a1,0
ffffffffc0205d86:	6e89                	lui	t4,0x2
ffffffffc0205d88:	169e0063          	beq	t3,s1,ffffffffc0205ee8 <do_fork+0x386>
ffffffffc0205d8c:	88ae                	mv	a7,a1
ffffffffc0205d8e:	87f2                	mv	a5,t3
ffffffffc0205d90:	6609                	lui	a2,0x2
ffffffffc0205d92:	a811                	j	ffffffffc0205da6 <do_fork+0x244>
ffffffffc0205d94:	00e6d663          	bge	a3,a4,ffffffffc0205da0 <do_fork+0x23e>
ffffffffc0205d98:	00c75463          	bge	a4,a2,ffffffffc0205da0 <do_fork+0x23e>
ffffffffc0205d9c:	863a                	mv	a2,a4
ffffffffc0205d9e:	4885                	li	a7,1
ffffffffc0205da0:	679c                	ld	a5,8(a5)
ffffffffc0205da2:	00978d63          	beq	a5,s1,ffffffffc0205dbc <do_fork+0x25a>
ffffffffc0205da6:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_bin_swap_img_size-0x5dc4>
ffffffffc0205daa:	fed715e3          	bne	a4,a3,ffffffffc0205d94 <do_fork+0x232>
ffffffffc0205dae:	2685                	addiw	a3,a3,1
ffffffffc0205db0:	10c6dc63          	bge	a3,a2,ffffffffc0205ec8 <do_fork+0x366>
ffffffffc0205db4:	679c                	ld	a5,8(a5)
ffffffffc0205db6:	4585                	li	a1,1
ffffffffc0205db8:	fe9797e3          	bne	a5,s1,ffffffffc0205da6 <do_fork+0x244>
ffffffffc0205dbc:	c581                	beqz	a1,ffffffffc0205dc4 <do_fork+0x262>
ffffffffc0205dbe:	00d82023          	sw	a3,0(a6)
ffffffffc0205dc2:	8536                	mv	a0,a3
ffffffffc0205dc4:	f0088fe3          	beqz	a7,ffffffffc0205ce2 <do_fork+0x180>
ffffffffc0205dc8:	00c32023          	sw	a2,0(t1)
ffffffffc0205dcc:	bf19                	j	ffffffffc0205ce2 <do_fork+0x180>
ffffffffc0205dce:	8a3a                	mv	s4,a4
ffffffffc0205dd0:	01473823          	sd	s4,16(a4) # 2010 <_binary_bin_swap_img_size-0x5cf0>
ffffffffc0205dd4:	00000797          	auipc	a5,0x0
ffffffffc0205dd8:	c9a78793          	addi	a5,a5,-870 # ffffffffc0205a6e <forkret>
ffffffffc0205ddc:	f81c                	sd	a5,48(s0)
ffffffffc0205dde:	fc18                	sd	a4,56(s0)
ffffffffc0205de0:	100027f3          	csrr	a5,sstatus
ffffffffc0205de4:	8b89                	andi	a5,a5,2
ffffffffc0205de6:	4981                	li	s3,0
ffffffffc0205de8:	ec0784e3          	beqz	a5,ffffffffc0205cb0 <do_fork+0x14e>
ffffffffc0205dec:	e87fa0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0205df0:	4985                	li	s3,1
ffffffffc0205df2:	bd7d                	j	ffffffffc0205cb0 <do_fork+0x14e>
ffffffffc0205df4:	bdaff0ef          	jal	ra,ffffffffc02051ce <files_create>
ffffffffc0205df8:	89aa                	mv	s3,a0
ffffffffc0205dfa:	c911                	beqz	a0,ffffffffc0205e0e <do_fork+0x2ac>
ffffffffc0205dfc:	85e2                	mv	a1,s8
ffffffffc0205dfe:	d08ff0ef          	jal	ra,ffffffffc0205306 <dup_files>
ffffffffc0205e02:	8c4e                	mv	s8,s3
ffffffffc0205e04:	e40503e3          	beqz	a0,ffffffffc0205c4a <do_fork+0xe8>
ffffffffc0205e08:	854e                	mv	a0,s3
ffffffffc0205e0a:	bfaff0ef          	jal	ra,ffffffffc0205204 <files_destroy>
ffffffffc0205e0e:	6814                	ld	a3,16(s0)
ffffffffc0205e10:	c02007b7          	lui	a5,0xc0200
ffffffffc0205e14:	12f6ec63          	bltu	a3,a5,ffffffffc0205f4c <do_fork+0x3ea>
ffffffffc0205e18:	000cb783          	ld	a5,0(s9)
ffffffffc0205e1c:	000bb703          	ld	a4,0(s7)
ffffffffc0205e20:	40f687b3          	sub	a5,a3,a5
ffffffffc0205e24:	83b1                	srli	a5,a5,0xc
ffffffffc0205e26:	10e7f763          	bgeu	a5,a4,ffffffffc0205f34 <do_fork+0x3d2>
ffffffffc0205e2a:	000b3503          	ld	a0,0(s6)
ffffffffc0205e2e:	415787b3          	sub	a5,a5,s5
ffffffffc0205e32:	079a                	slli	a5,a5,0x6
ffffffffc0205e34:	4589                	li	a1,2
ffffffffc0205e36:	953e                	add	a0,a0,a5
ffffffffc0205e38:	b72fc0ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc0205e3c:	8522                	mv	a0,s0
ffffffffc0205e3e:	a00fc0ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc0205e42:	5571                	li	a0,-4
ffffffffc0205e44:	bdfd                	j	ffffffffc0205d42 <do_fork+0x1e0>
ffffffffc0205e46:	dc3fd0ef          	jal	ra,ffffffffc0203c08 <mm_create>
ffffffffc0205e4a:	8d2a                	mv	s10,a0
ffffffffc0205e4c:	d169                	beqz	a0,ffffffffc0205e0e <do_fork+0x2ac>
ffffffffc0205e4e:	4505                	li	a0,1
ffffffffc0205e50:	b1cfc0ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc0205e54:	c551                	beqz	a0,ffffffffc0205ee0 <do_fork+0x37e>
ffffffffc0205e56:	000b3683          	ld	a3,0(s6)
ffffffffc0205e5a:	000bb703          	ld	a4,0(s7)
ffffffffc0205e5e:	40d506b3          	sub	a3,a0,a3
ffffffffc0205e62:	8699                	srai	a3,a3,0x6
ffffffffc0205e64:	96d6                	add	a3,a3,s5
ffffffffc0205e66:	0186fc33          	and	s8,a3,s8
ffffffffc0205e6a:	06b2                	slli	a3,a3,0xc
ffffffffc0205e6c:	10ec7c63          	bgeu	s8,a4,ffffffffc0205f84 <do_fork+0x422>
ffffffffc0205e70:	000cbc03          	ld	s8,0(s9)
ffffffffc0205e74:	6605                	lui	a2,0x1
ffffffffc0205e76:	00091597          	auipc	a1,0x91
ffffffffc0205e7a:	a225b583          	ld	a1,-1502(a1) # ffffffffc0296898 <boot_pgdir_va>
ffffffffc0205e7e:	9c36                	add	s8,s8,a3
ffffffffc0205e80:	8562                	mv	a0,s8
ffffffffc0205e82:	3d5050ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc0205e86:	03848713          	addi	a4,s1,56
ffffffffc0205e8a:	853a                	mv	a0,a4
ffffffffc0205e8c:	018d3c23          	sd	s8,24(s10)
ffffffffc0205e90:	e43a                	sd	a4,8(sp)
ffffffffc0205e92:	ed2fe0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc0205e96:	000db683          	ld	a3,0(s11)
ffffffffc0205e9a:	6722                	ld	a4,8(sp)
ffffffffc0205e9c:	c299                	beqz	a3,ffffffffc0205ea2 <do_fork+0x340>
ffffffffc0205e9e:	42d4                	lw	a3,4(a3)
ffffffffc0205ea0:	c8b4                	sw	a3,80(s1)
ffffffffc0205ea2:	85a6                	mv	a1,s1
ffffffffc0205ea4:	856a                	mv	a0,s10
ffffffffc0205ea6:	e43a                	sd	a4,8(sp)
ffffffffc0205ea8:	fb1fd0ef          	jal	ra,ffffffffc0203e58 <dup_mmap>
ffffffffc0205eac:	6722                	ld	a4,8(sp)
ffffffffc0205eae:	8c2a                	mv	s8,a0
ffffffffc0205eb0:	853a                	mv	a0,a4
ffffffffc0205eb2:	eaefe0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0205eb6:	0404a823          	sw	zero,80(s1)
ffffffffc0205eba:	000c1c63          	bnez	s8,ffffffffc0205ed2 <do_fork+0x370>
ffffffffc0205ebe:	84ea                	mv	s1,s10
ffffffffc0205ec0:	bba1                	j	ffffffffc0205c18 <do_fork+0xb6>
ffffffffc0205ec2:	dabfa0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0205ec6:	bd95                	j	ffffffffc0205d3a <do_fork+0x1d8>
ffffffffc0205ec8:	01d6c363          	blt	a3,t4,ffffffffc0205ece <do_fork+0x36c>
ffffffffc0205ecc:	4685                	li	a3,1
ffffffffc0205ece:	4585                	li	a1,1
ffffffffc0205ed0:	bd65                	j	ffffffffc0205d88 <do_fork+0x226>
ffffffffc0205ed2:	856a                	mv	a0,s10
ffffffffc0205ed4:	81efe0ef          	jal	ra,ffffffffc0203ef2 <exit_mmap>
ffffffffc0205ed8:	018d3503          	ld	a0,24(s10)
ffffffffc0205edc:	ba1ff0ef          	jal	ra,ffffffffc0205a7c <put_pgdir.isra.0>
ffffffffc0205ee0:	856a                	mv	a0,s10
ffffffffc0205ee2:	e75fd0ef          	jal	ra,ffffffffc0203d56 <mm_destroy>
ffffffffc0205ee6:	b725                	j	ffffffffc0205e0e <do_fork+0x2ac>
ffffffffc0205ee8:	c599                	beqz	a1,ffffffffc0205ef6 <do_fork+0x394>
ffffffffc0205eea:	00d82023          	sw	a3,0(a6)
ffffffffc0205eee:	8536                	mv	a0,a3
ffffffffc0205ef0:	bbcd                	j	ffffffffc0205ce2 <do_fork+0x180>
ffffffffc0205ef2:	556d                	li	a0,-5
ffffffffc0205ef4:	b5b9                	j	ffffffffc0205d42 <do_fork+0x1e0>
ffffffffc0205ef6:	00082503          	lw	a0,0(a6)
ffffffffc0205efa:	b3e5                	j	ffffffffc0205ce2 <do_fork+0x180>
ffffffffc0205efc:	00008697          	auipc	a3,0x8
ffffffffc0205f00:	b2468693          	addi	a3,a3,-1244 # ffffffffc020da20 <CSWTCH.84+0x128>
ffffffffc0205f04:	00006617          	auipc	a2,0x6
ffffffffc0205f08:	fe460613          	addi	a2,a2,-28 # ffffffffc020bee8 <commands+0x210>
ffffffffc0205f0c:	1df00593          	li	a1,479
ffffffffc0205f10:	00008517          	auipc	a0,0x8
ffffffffc0205f14:	af850513          	addi	a0,a0,-1288 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0205f18:	d86fa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0205f1c:	00007617          	auipc	a2,0x7
ffffffffc0205f20:	b9460613          	addi	a2,a2,-1132 # ffffffffc020cab0 <default_pmm_manager+0xe0>
ffffffffc0205f24:	1bf00593          	li	a1,447
ffffffffc0205f28:	00008517          	auipc	a0,0x8
ffffffffc0205f2c:	ae050513          	addi	a0,a0,-1312 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0205f30:	d6efa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0205f34:	00007617          	auipc	a2,0x7
ffffffffc0205f38:	ba460613          	addi	a2,a2,-1116 # ffffffffc020cad8 <default_pmm_manager+0x108>
ffffffffc0205f3c:	06900593          	li	a1,105
ffffffffc0205f40:	00007517          	auipc	a0,0x7
ffffffffc0205f44:	af050513          	addi	a0,a0,-1296 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0205f48:	d56fa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0205f4c:	00007617          	auipc	a2,0x7
ffffffffc0205f50:	b6460613          	addi	a2,a2,-1180 # ffffffffc020cab0 <default_pmm_manager+0xe0>
ffffffffc0205f54:	07700593          	li	a1,119
ffffffffc0205f58:	00007517          	auipc	a0,0x7
ffffffffc0205f5c:	ad850513          	addi	a0,a0,-1320 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0205f60:	d3efa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0205f64:	00008697          	auipc	a3,0x8
ffffffffc0205f68:	a8468693          	addi	a3,a3,-1404 # ffffffffc020d9e8 <CSWTCH.84+0xf0>
ffffffffc0205f6c:	00006617          	auipc	a2,0x6
ffffffffc0205f70:	f7c60613          	addi	a2,a2,-132 # ffffffffc020bee8 <commands+0x210>
ffffffffc0205f74:	23300593          	li	a1,563
ffffffffc0205f78:	00008517          	auipc	a0,0x8
ffffffffc0205f7c:	a9050513          	addi	a0,a0,-1392 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0205f80:	d1efa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0205f84:	00007617          	auipc	a2,0x7
ffffffffc0205f88:	a8460613          	addi	a2,a2,-1404 # ffffffffc020ca08 <default_pmm_manager+0x38>
ffffffffc0205f8c:	07100593          	li	a1,113
ffffffffc0205f90:	00007517          	auipc	a0,0x7
ffffffffc0205f94:	aa050513          	addi	a0,a0,-1376 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0205f98:	d06fa0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0205f9c <kernel_thread>:
ffffffffc0205f9c:	7129                	addi	sp,sp,-320
ffffffffc0205f9e:	fa22                	sd	s0,304(sp)
ffffffffc0205fa0:	f626                	sd	s1,296(sp)
ffffffffc0205fa2:	f24a                	sd	s2,288(sp)
ffffffffc0205fa4:	84ae                	mv	s1,a1
ffffffffc0205fa6:	892a                	mv	s2,a0
ffffffffc0205fa8:	8432                	mv	s0,a2
ffffffffc0205faa:	4581                	li	a1,0
ffffffffc0205fac:	12000613          	li	a2,288
ffffffffc0205fb0:	850a                	mv	a0,sp
ffffffffc0205fb2:	fe06                	sd	ra,312(sp)
ffffffffc0205fb4:	251050ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc0205fb8:	e0ca                	sd	s2,64(sp)
ffffffffc0205fba:	e4a6                	sd	s1,72(sp)
ffffffffc0205fbc:	100027f3          	csrr	a5,sstatus
ffffffffc0205fc0:	edd7f793          	andi	a5,a5,-291
ffffffffc0205fc4:	1207e793          	ori	a5,a5,288
ffffffffc0205fc8:	e23e                	sd	a5,256(sp)
ffffffffc0205fca:	860a                	mv	a2,sp
ffffffffc0205fcc:	10046513          	ori	a0,s0,256
ffffffffc0205fd0:	00000797          	auipc	a5,0x0
ffffffffc0205fd4:	9fc78793          	addi	a5,a5,-1540 # ffffffffc02059cc <kernel_thread_entry>
ffffffffc0205fd8:	4581                	li	a1,0
ffffffffc0205fda:	e63e                	sd	a5,264(sp)
ffffffffc0205fdc:	b87ff0ef          	jal	ra,ffffffffc0205b62 <do_fork>
ffffffffc0205fe0:	70f2                	ld	ra,312(sp)
ffffffffc0205fe2:	7452                	ld	s0,304(sp)
ffffffffc0205fe4:	74b2                	ld	s1,296(sp)
ffffffffc0205fe6:	7912                	ld	s2,288(sp)
ffffffffc0205fe8:	6131                	addi	sp,sp,320
ffffffffc0205fea:	8082                	ret

ffffffffc0205fec <do_exit>:
ffffffffc0205fec:	7179                	addi	sp,sp,-48
ffffffffc0205fee:	f022                	sd	s0,32(sp)
ffffffffc0205ff0:	00091417          	auipc	s0,0x91
ffffffffc0205ff4:	8d040413          	addi	s0,s0,-1840 # ffffffffc02968c0 <current>
ffffffffc0205ff8:	601c                	ld	a5,0(s0)
ffffffffc0205ffa:	f406                	sd	ra,40(sp)
ffffffffc0205ffc:	ec26                	sd	s1,24(sp)
ffffffffc0205ffe:	e84a                	sd	s2,16(sp)
ffffffffc0206000:	e44e                	sd	s3,8(sp)
ffffffffc0206002:	e052                	sd	s4,0(sp)
ffffffffc0206004:	00091717          	auipc	a4,0x91
ffffffffc0206008:	8c473703          	ld	a4,-1852(a4) # ffffffffc02968c8 <idleproc>
ffffffffc020600c:	0ee78763          	beq	a5,a4,ffffffffc02060fa <do_exit+0x10e>
ffffffffc0206010:	00091497          	auipc	s1,0x91
ffffffffc0206014:	8c048493          	addi	s1,s1,-1856 # ffffffffc02968d0 <initproc>
ffffffffc0206018:	6098                	ld	a4,0(s1)
ffffffffc020601a:	10e78763          	beq	a5,a4,ffffffffc0206128 <do_exit+0x13c>
ffffffffc020601e:	0287b983          	ld	s3,40(a5)
ffffffffc0206022:	892a                	mv	s2,a0
ffffffffc0206024:	02098e63          	beqz	s3,ffffffffc0206060 <do_exit+0x74>
ffffffffc0206028:	00091797          	auipc	a5,0x91
ffffffffc020602c:	8687b783          	ld	a5,-1944(a5) # ffffffffc0296890 <boot_pgdir_pa>
ffffffffc0206030:	577d                	li	a4,-1
ffffffffc0206032:	177e                	slli	a4,a4,0x3f
ffffffffc0206034:	83b1                	srli	a5,a5,0xc
ffffffffc0206036:	8fd9                	or	a5,a5,a4
ffffffffc0206038:	18079073          	csrw	satp,a5
ffffffffc020603c:	0309a783          	lw	a5,48(s3)
ffffffffc0206040:	fff7871b          	addiw	a4,a5,-1
ffffffffc0206044:	02e9a823          	sw	a4,48(s3)
ffffffffc0206048:	c769                	beqz	a4,ffffffffc0206112 <do_exit+0x126>
ffffffffc020604a:	601c                	ld	a5,0(s0)
ffffffffc020604c:	1487b503          	ld	a0,328(a5)
ffffffffc0206050:	0207b423          	sd	zero,40(a5)
ffffffffc0206054:	c511                	beqz	a0,ffffffffc0206060 <do_exit+0x74>
ffffffffc0206056:	491c                	lw	a5,16(a0)
ffffffffc0206058:	fff7871b          	addiw	a4,a5,-1
ffffffffc020605c:	c918                	sw	a4,16(a0)
ffffffffc020605e:	cb59                	beqz	a4,ffffffffc02060f4 <do_exit+0x108>
ffffffffc0206060:	601c                	ld	a5,0(s0)
ffffffffc0206062:	470d                	li	a4,3
ffffffffc0206064:	c398                	sw	a4,0(a5)
ffffffffc0206066:	0f27a423          	sw	s2,232(a5)
ffffffffc020606a:	100027f3          	csrr	a5,sstatus
ffffffffc020606e:	8b89                	andi	a5,a5,2
ffffffffc0206070:	4a01                	li	s4,0
ffffffffc0206072:	e7f9                	bnez	a5,ffffffffc0206140 <do_exit+0x154>
ffffffffc0206074:	6018                	ld	a4,0(s0)
ffffffffc0206076:	800007b7          	lui	a5,0x80000
ffffffffc020607a:	0785                	addi	a5,a5,1
ffffffffc020607c:	7308                	ld	a0,32(a4)
ffffffffc020607e:	0ec52703          	lw	a4,236(a0)
ffffffffc0206082:	0cf70363          	beq	a4,a5,ffffffffc0206148 <do_exit+0x15c>
ffffffffc0206086:	6018                	ld	a4,0(s0)
ffffffffc0206088:	7b7c                	ld	a5,240(a4)
ffffffffc020608a:	c3a1                	beqz	a5,ffffffffc02060ca <do_exit+0xde>
ffffffffc020608c:	800009b7          	lui	s3,0x80000
ffffffffc0206090:	490d                	li	s2,3
ffffffffc0206092:	0985                	addi	s3,s3,1
ffffffffc0206094:	a021                	j	ffffffffc020609c <do_exit+0xb0>
ffffffffc0206096:	6018                	ld	a4,0(s0)
ffffffffc0206098:	7b7c                	ld	a5,240(a4)
ffffffffc020609a:	cb85                	beqz	a5,ffffffffc02060ca <do_exit+0xde>
ffffffffc020609c:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_bin_sfs_img_size+0xffffffff7ff8ae00>
ffffffffc02060a0:	6088                	ld	a0,0(s1)
ffffffffc02060a2:	fb74                	sd	a3,240(a4)
ffffffffc02060a4:	7978                	ld	a4,240(a0)
ffffffffc02060a6:	0e07bc23          	sd	zero,248(a5)
ffffffffc02060aa:	10e7b023          	sd	a4,256(a5)
ffffffffc02060ae:	c311                	beqz	a4,ffffffffc02060b2 <do_exit+0xc6>
ffffffffc02060b0:	ff7c                	sd	a5,248(a4)
ffffffffc02060b2:	4398                	lw	a4,0(a5)
ffffffffc02060b4:	f388                	sd	a0,32(a5)
ffffffffc02060b6:	f97c                	sd	a5,240(a0)
ffffffffc02060b8:	fd271fe3          	bne	a4,s2,ffffffffc0206096 <do_exit+0xaa>
ffffffffc02060bc:	0ec52783          	lw	a5,236(a0)
ffffffffc02060c0:	fd379be3          	bne	a5,s3,ffffffffc0206096 <do_exit+0xaa>
ffffffffc02060c4:	194010ef          	jal	ra,ffffffffc0207258 <wakeup_proc>
ffffffffc02060c8:	b7f9                	j	ffffffffc0206096 <do_exit+0xaa>
ffffffffc02060ca:	020a1263          	bnez	s4,ffffffffc02060ee <do_exit+0x102>
ffffffffc02060ce:	23c010ef          	jal	ra,ffffffffc020730a <schedule>
ffffffffc02060d2:	601c                	ld	a5,0(s0)
ffffffffc02060d4:	00008617          	auipc	a2,0x8
ffffffffc02060d8:	98460613          	addi	a2,a2,-1660 # ffffffffc020da58 <CSWTCH.84+0x160>
ffffffffc02060dc:	2a900593          	li	a1,681
ffffffffc02060e0:	43d4                	lw	a3,4(a5)
ffffffffc02060e2:	00008517          	auipc	a0,0x8
ffffffffc02060e6:	92650513          	addi	a0,a0,-1754 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc02060ea:	bb4fa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02060ee:	b7ffa0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02060f2:	bff1                	j	ffffffffc02060ce <do_exit+0xe2>
ffffffffc02060f4:	910ff0ef          	jal	ra,ffffffffc0205204 <files_destroy>
ffffffffc02060f8:	b7a5                	j	ffffffffc0206060 <do_exit+0x74>
ffffffffc02060fa:	00008617          	auipc	a2,0x8
ffffffffc02060fe:	93e60613          	addi	a2,a2,-1730 # ffffffffc020da38 <CSWTCH.84+0x140>
ffffffffc0206102:	27400593          	li	a1,628
ffffffffc0206106:	00008517          	auipc	a0,0x8
ffffffffc020610a:	90250513          	addi	a0,a0,-1790 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc020610e:	b90fa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206112:	854e                	mv	a0,s3
ffffffffc0206114:	ddffd0ef          	jal	ra,ffffffffc0203ef2 <exit_mmap>
ffffffffc0206118:	0189b503          	ld	a0,24(s3) # ffffffff80000018 <_binary_bin_sfs_img_size+0xffffffff7ff8ad18>
ffffffffc020611c:	961ff0ef          	jal	ra,ffffffffc0205a7c <put_pgdir.isra.0>
ffffffffc0206120:	854e                	mv	a0,s3
ffffffffc0206122:	c35fd0ef          	jal	ra,ffffffffc0203d56 <mm_destroy>
ffffffffc0206126:	b715                	j	ffffffffc020604a <do_exit+0x5e>
ffffffffc0206128:	00008617          	auipc	a2,0x8
ffffffffc020612c:	92060613          	addi	a2,a2,-1760 # ffffffffc020da48 <CSWTCH.84+0x150>
ffffffffc0206130:	27800593          	li	a1,632
ffffffffc0206134:	00008517          	auipc	a0,0x8
ffffffffc0206138:	8d450513          	addi	a0,a0,-1836 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc020613c:	b62fa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206140:	b33fa0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0206144:	4a05                	li	s4,1
ffffffffc0206146:	b73d                	j	ffffffffc0206074 <do_exit+0x88>
ffffffffc0206148:	110010ef          	jal	ra,ffffffffc0207258 <wakeup_proc>
ffffffffc020614c:	bf2d                	j	ffffffffc0206086 <do_exit+0x9a>

ffffffffc020614e <do_wait.part.0>:
ffffffffc020614e:	715d                	addi	sp,sp,-80
ffffffffc0206150:	f84a                	sd	s2,48(sp)
ffffffffc0206152:	f44e                	sd	s3,40(sp)
ffffffffc0206154:	80000937          	lui	s2,0x80000
ffffffffc0206158:	6989                	lui	s3,0x2
ffffffffc020615a:	fc26                	sd	s1,56(sp)
ffffffffc020615c:	f052                	sd	s4,32(sp)
ffffffffc020615e:	ec56                	sd	s5,24(sp)
ffffffffc0206160:	e85a                	sd	s6,16(sp)
ffffffffc0206162:	e45e                	sd	s7,8(sp)
ffffffffc0206164:	e486                	sd	ra,72(sp)
ffffffffc0206166:	e0a2                	sd	s0,64(sp)
ffffffffc0206168:	84aa                	mv	s1,a0
ffffffffc020616a:	8a2e                	mv	s4,a1
ffffffffc020616c:	00090b97          	auipc	s7,0x90
ffffffffc0206170:	754b8b93          	addi	s7,s7,1876 # ffffffffc02968c0 <current>
ffffffffc0206174:	00050b1b          	sext.w	s6,a0
ffffffffc0206178:	fff50a9b          	addiw	s5,a0,-1
ffffffffc020617c:	19f9                	addi	s3,s3,-2
ffffffffc020617e:	0905                	addi	s2,s2,1
ffffffffc0206180:	ccbd                	beqz	s1,ffffffffc02061fe <do_wait.part.0+0xb0>
ffffffffc0206182:	0359e863          	bltu	s3,s5,ffffffffc02061b2 <do_wait.part.0+0x64>
ffffffffc0206186:	45a9                	li	a1,10
ffffffffc0206188:	855a                	mv	a0,s6
ffffffffc020618a:	31e050ef          	jal	ra,ffffffffc020b4a8 <hash32>
ffffffffc020618e:	02051793          	slli	a5,a0,0x20
ffffffffc0206192:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0206196:	0008b797          	auipc	a5,0x8b
ffffffffc020619a:	62a78793          	addi	a5,a5,1578 # ffffffffc02917c0 <hash_list>
ffffffffc020619e:	953e                	add	a0,a0,a5
ffffffffc02061a0:	842a                	mv	s0,a0
ffffffffc02061a2:	a029                	j	ffffffffc02061ac <do_wait.part.0+0x5e>
ffffffffc02061a4:	f2c42783          	lw	a5,-212(s0)
ffffffffc02061a8:	02978163          	beq	a5,s1,ffffffffc02061ca <do_wait.part.0+0x7c>
ffffffffc02061ac:	6400                	ld	s0,8(s0)
ffffffffc02061ae:	fe851be3          	bne	a0,s0,ffffffffc02061a4 <do_wait.part.0+0x56>
ffffffffc02061b2:	5579                	li	a0,-2
ffffffffc02061b4:	60a6                	ld	ra,72(sp)
ffffffffc02061b6:	6406                	ld	s0,64(sp)
ffffffffc02061b8:	74e2                	ld	s1,56(sp)
ffffffffc02061ba:	7942                	ld	s2,48(sp)
ffffffffc02061bc:	79a2                	ld	s3,40(sp)
ffffffffc02061be:	7a02                	ld	s4,32(sp)
ffffffffc02061c0:	6ae2                	ld	s5,24(sp)
ffffffffc02061c2:	6b42                	ld	s6,16(sp)
ffffffffc02061c4:	6ba2                	ld	s7,8(sp)
ffffffffc02061c6:	6161                	addi	sp,sp,80
ffffffffc02061c8:	8082                	ret
ffffffffc02061ca:	000bb683          	ld	a3,0(s7)
ffffffffc02061ce:	f4843783          	ld	a5,-184(s0)
ffffffffc02061d2:	fed790e3          	bne	a5,a3,ffffffffc02061b2 <do_wait.part.0+0x64>
ffffffffc02061d6:	f2842703          	lw	a4,-216(s0)
ffffffffc02061da:	478d                	li	a5,3
ffffffffc02061dc:	0ef70b63          	beq	a4,a5,ffffffffc02062d2 <do_wait.part.0+0x184>
ffffffffc02061e0:	4785                	li	a5,1
ffffffffc02061e2:	c29c                	sw	a5,0(a3)
ffffffffc02061e4:	0f26a623          	sw	s2,236(a3)
ffffffffc02061e8:	122010ef          	jal	ra,ffffffffc020730a <schedule>
ffffffffc02061ec:	000bb783          	ld	a5,0(s7)
ffffffffc02061f0:	0b07a783          	lw	a5,176(a5)
ffffffffc02061f4:	8b85                	andi	a5,a5,1
ffffffffc02061f6:	d7c9                	beqz	a5,ffffffffc0206180 <do_wait.part.0+0x32>
ffffffffc02061f8:	555d                	li	a0,-9
ffffffffc02061fa:	df3ff0ef          	jal	ra,ffffffffc0205fec <do_exit>
ffffffffc02061fe:	000bb683          	ld	a3,0(s7)
ffffffffc0206202:	7ae0                	ld	s0,240(a3)
ffffffffc0206204:	d45d                	beqz	s0,ffffffffc02061b2 <do_wait.part.0+0x64>
ffffffffc0206206:	470d                	li	a4,3
ffffffffc0206208:	a021                	j	ffffffffc0206210 <do_wait.part.0+0xc2>
ffffffffc020620a:	10043403          	ld	s0,256(s0)
ffffffffc020620e:	d869                	beqz	s0,ffffffffc02061e0 <do_wait.part.0+0x92>
ffffffffc0206210:	401c                	lw	a5,0(s0)
ffffffffc0206212:	fee79ce3          	bne	a5,a4,ffffffffc020620a <do_wait.part.0+0xbc>
ffffffffc0206216:	00090797          	auipc	a5,0x90
ffffffffc020621a:	6b27b783          	ld	a5,1714(a5) # ffffffffc02968c8 <idleproc>
ffffffffc020621e:	0c878963          	beq	a5,s0,ffffffffc02062f0 <do_wait.part.0+0x1a2>
ffffffffc0206222:	00090797          	auipc	a5,0x90
ffffffffc0206226:	6ae7b783          	ld	a5,1710(a5) # ffffffffc02968d0 <initproc>
ffffffffc020622a:	0cf40363          	beq	s0,a5,ffffffffc02062f0 <do_wait.part.0+0x1a2>
ffffffffc020622e:	000a0663          	beqz	s4,ffffffffc020623a <do_wait.part.0+0xec>
ffffffffc0206232:	0e842783          	lw	a5,232(s0)
ffffffffc0206236:	00fa2023          	sw	a5,0(s4)
ffffffffc020623a:	100027f3          	csrr	a5,sstatus
ffffffffc020623e:	8b89                	andi	a5,a5,2
ffffffffc0206240:	4581                	li	a1,0
ffffffffc0206242:	e7c1                	bnez	a5,ffffffffc02062ca <do_wait.part.0+0x17c>
ffffffffc0206244:	6c70                	ld	a2,216(s0)
ffffffffc0206246:	7074                	ld	a3,224(s0)
ffffffffc0206248:	10043703          	ld	a4,256(s0)
ffffffffc020624c:	7c7c                	ld	a5,248(s0)
ffffffffc020624e:	e614                	sd	a3,8(a2)
ffffffffc0206250:	e290                	sd	a2,0(a3)
ffffffffc0206252:	6470                	ld	a2,200(s0)
ffffffffc0206254:	6874                	ld	a3,208(s0)
ffffffffc0206256:	e614                	sd	a3,8(a2)
ffffffffc0206258:	e290                	sd	a2,0(a3)
ffffffffc020625a:	c319                	beqz	a4,ffffffffc0206260 <do_wait.part.0+0x112>
ffffffffc020625c:	ff7c                	sd	a5,248(a4)
ffffffffc020625e:	7c7c                	ld	a5,248(s0)
ffffffffc0206260:	c3b5                	beqz	a5,ffffffffc02062c4 <do_wait.part.0+0x176>
ffffffffc0206262:	10e7b023          	sd	a4,256(a5)
ffffffffc0206266:	00090717          	auipc	a4,0x90
ffffffffc020626a:	67270713          	addi	a4,a4,1650 # ffffffffc02968d8 <nr_process>
ffffffffc020626e:	431c                	lw	a5,0(a4)
ffffffffc0206270:	37fd                	addiw	a5,a5,-1
ffffffffc0206272:	c31c                	sw	a5,0(a4)
ffffffffc0206274:	e5a9                	bnez	a1,ffffffffc02062be <do_wait.part.0+0x170>
ffffffffc0206276:	6814                	ld	a3,16(s0)
ffffffffc0206278:	c02007b7          	lui	a5,0xc0200
ffffffffc020627c:	04f6ee63          	bltu	a3,a5,ffffffffc02062d8 <do_wait.part.0+0x18a>
ffffffffc0206280:	00090797          	auipc	a5,0x90
ffffffffc0206284:	6387b783          	ld	a5,1592(a5) # ffffffffc02968b8 <va_pa_offset>
ffffffffc0206288:	8e9d                	sub	a3,a3,a5
ffffffffc020628a:	82b1                	srli	a3,a3,0xc
ffffffffc020628c:	00090797          	auipc	a5,0x90
ffffffffc0206290:	6147b783          	ld	a5,1556(a5) # ffffffffc02968a0 <npage>
ffffffffc0206294:	06f6fa63          	bgeu	a3,a5,ffffffffc0206308 <do_wait.part.0+0x1ba>
ffffffffc0206298:	0000a517          	auipc	a0,0xa
ffffffffc020629c:	b3853503          	ld	a0,-1224(a0) # ffffffffc020fdd0 <nbase>
ffffffffc02062a0:	8e89                	sub	a3,a3,a0
ffffffffc02062a2:	069a                	slli	a3,a3,0x6
ffffffffc02062a4:	00090517          	auipc	a0,0x90
ffffffffc02062a8:	60453503          	ld	a0,1540(a0) # ffffffffc02968a8 <pages>
ffffffffc02062ac:	9536                	add	a0,a0,a3
ffffffffc02062ae:	4589                	li	a1,2
ffffffffc02062b0:	efbfb0ef          	jal	ra,ffffffffc02021aa <free_pages>
ffffffffc02062b4:	8522                	mv	a0,s0
ffffffffc02062b6:	d89fb0ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc02062ba:	4501                	li	a0,0
ffffffffc02062bc:	bde5                	j	ffffffffc02061b4 <do_wait.part.0+0x66>
ffffffffc02062be:	9affa0ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02062c2:	bf55                	j	ffffffffc0206276 <do_wait.part.0+0x128>
ffffffffc02062c4:	701c                	ld	a5,32(s0)
ffffffffc02062c6:	fbf8                	sd	a4,240(a5)
ffffffffc02062c8:	bf79                	j	ffffffffc0206266 <do_wait.part.0+0x118>
ffffffffc02062ca:	9a9fa0ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02062ce:	4585                	li	a1,1
ffffffffc02062d0:	bf95                	j	ffffffffc0206244 <do_wait.part.0+0xf6>
ffffffffc02062d2:	f2840413          	addi	s0,s0,-216
ffffffffc02062d6:	b781                	j	ffffffffc0206216 <do_wait.part.0+0xc8>
ffffffffc02062d8:	00006617          	auipc	a2,0x6
ffffffffc02062dc:	7d860613          	addi	a2,a2,2008 # ffffffffc020cab0 <default_pmm_manager+0xe0>
ffffffffc02062e0:	07700593          	li	a1,119
ffffffffc02062e4:	00006517          	auipc	a0,0x6
ffffffffc02062e8:	74c50513          	addi	a0,a0,1868 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc02062ec:	9b2fa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02062f0:	00007617          	auipc	a2,0x7
ffffffffc02062f4:	78860613          	addi	a2,a2,1928 # ffffffffc020da78 <CSWTCH.84+0x180>
ffffffffc02062f8:	47200593          	li	a1,1138
ffffffffc02062fc:	00007517          	auipc	a0,0x7
ffffffffc0206300:	70c50513          	addi	a0,a0,1804 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0206304:	99afa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206308:	00006617          	auipc	a2,0x6
ffffffffc020630c:	7d060613          	addi	a2,a2,2000 # ffffffffc020cad8 <default_pmm_manager+0x108>
ffffffffc0206310:	06900593          	li	a1,105
ffffffffc0206314:	00006517          	auipc	a0,0x6
ffffffffc0206318:	71c50513          	addi	a0,a0,1820 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc020631c:	982fa0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0206320 <init_main>:
ffffffffc0206320:	1141                	addi	sp,sp,-16
ffffffffc0206322:	00007517          	auipc	a0,0x7
ffffffffc0206326:	77650513          	addi	a0,a0,1910 # ffffffffc020da98 <CSWTCH.84+0x1a0>
ffffffffc020632a:	e406                	sd	ra,8(sp)
ffffffffc020632c:	74e010ef          	jal	ra,ffffffffc0207a7a <vfs_set_bootfs>
ffffffffc0206330:	e179                	bnez	a0,ffffffffc02063f6 <init_main+0xd6>
ffffffffc0206332:	eb9fb0ef          	jal	ra,ffffffffc02021ea <nr_free_pages>
ffffffffc0206336:	c55fb0ef          	jal	ra,ffffffffc0201f8a <kallocated>
ffffffffc020633a:	4601                	li	a2,0
ffffffffc020633c:	4581                	li	a1,0
ffffffffc020633e:	00001517          	auipc	a0,0x1
ffffffffc0206342:	97450513          	addi	a0,a0,-1676 # ffffffffc0206cb2 <user_main>
ffffffffc0206346:	c57ff0ef          	jal	ra,ffffffffc0205f9c <kernel_thread>
ffffffffc020634a:	00a04563          	bgtz	a0,ffffffffc0206354 <init_main+0x34>
ffffffffc020634e:	a841                	j	ffffffffc02063de <init_main+0xbe>
ffffffffc0206350:	7bb000ef          	jal	ra,ffffffffc020730a <schedule>
ffffffffc0206354:	4581                	li	a1,0
ffffffffc0206356:	4501                	li	a0,0
ffffffffc0206358:	df7ff0ef          	jal	ra,ffffffffc020614e <do_wait.part.0>
ffffffffc020635c:	d975                	beqz	a0,ffffffffc0206350 <init_main+0x30>
ffffffffc020635e:	e61fe0ef          	jal	ra,ffffffffc02051be <fs_cleanup>
ffffffffc0206362:	00007517          	auipc	a0,0x7
ffffffffc0206366:	77e50513          	addi	a0,a0,1918 # ffffffffc020dae0 <CSWTCH.84+0x1e8>
ffffffffc020636a:	e3df90ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc020636e:	00090797          	auipc	a5,0x90
ffffffffc0206372:	5627b783          	ld	a5,1378(a5) # ffffffffc02968d0 <initproc>
ffffffffc0206376:	7bf8                	ld	a4,240(a5)
ffffffffc0206378:	e339                	bnez	a4,ffffffffc02063be <init_main+0x9e>
ffffffffc020637a:	7ff8                	ld	a4,248(a5)
ffffffffc020637c:	e329                	bnez	a4,ffffffffc02063be <init_main+0x9e>
ffffffffc020637e:	1007b703          	ld	a4,256(a5)
ffffffffc0206382:	ef15                	bnez	a4,ffffffffc02063be <init_main+0x9e>
ffffffffc0206384:	00090697          	auipc	a3,0x90
ffffffffc0206388:	5546a683          	lw	a3,1364(a3) # ffffffffc02968d8 <nr_process>
ffffffffc020638c:	4709                	li	a4,2
ffffffffc020638e:	0ce69163          	bne	a3,a4,ffffffffc0206450 <init_main+0x130>
ffffffffc0206392:	0008f717          	auipc	a4,0x8f
ffffffffc0206396:	42e70713          	addi	a4,a4,1070 # ffffffffc02957c0 <proc_list>
ffffffffc020639a:	6714                	ld	a3,8(a4)
ffffffffc020639c:	0c878793          	addi	a5,a5,200
ffffffffc02063a0:	08d79863          	bne	a5,a3,ffffffffc0206430 <init_main+0x110>
ffffffffc02063a4:	6318                	ld	a4,0(a4)
ffffffffc02063a6:	06e79563          	bne	a5,a4,ffffffffc0206410 <init_main+0xf0>
ffffffffc02063aa:	00008517          	auipc	a0,0x8
ffffffffc02063ae:	81e50513          	addi	a0,a0,-2018 # ffffffffc020dbc8 <CSWTCH.84+0x2d0>
ffffffffc02063b2:	df5f90ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc02063b6:	60a2                	ld	ra,8(sp)
ffffffffc02063b8:	4501                	li	a0,0
ffffffffc02063ba:	0141                	addi	sp,sp,16
ffffffffc02063bc:	8082                	ret
ffffffffc02063be:	00007697          	auipc	a3,0x7
ffffffffc02063c2:	74a68693          	addi	a3,a3,1866 # ffffffffc020db08 <CSWTCH.84+0x210>
ffffffffc02063c6:	00006617          	auipc	a2,0x6
ffffffffc02063ca:	b2260613          	addi	a2,a2,-1246 # ffffffffc020bee8 <commands+0x210>
ffffffffc02063ce:	4e800593          	li	a1,1256
ffffffffc02063d2:	00007517          	auipc	a0,0x7
ffffffffc02063d6:	63650513          	addi	a0,a0,1590 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc02063da:	8c4fa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02063de:	00007617          	auipc	a2,0x7
ffffffffc02063e2:	6e260613          	addi	a2,a2,1762 # ffffffffc020dac0 <CSWTCH.84+0x1c8>
ffffffffc02063e6:	4db00593          	li	a1,1243
ffffffffc02063ea:	00007517          	auipc	a0,0x7
ffffffffc02063ee:	61e50513          	addi	a0,a0,1566 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc02063f2:	8acfa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02063f6:	86aa                	mv	a3,a0
ffffffffc02063f8:	00007617          	auipc	a2,0x7
ffffffffc02063fc:	6a860613          	addi	a2,a2,1704 # ffffffffc020daa0 <CSWTCH.84+0x1a8>
ffffffffc0206400:	4d300593          	li	a1,1235
ffffffffc0206404:	00007517          	auipc	a0,0x7
ffffffffc0206408:	60450513          	addi	a0,a0,1540 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc020640c:	892fa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206410:	00007697          	auipc	a3,0x7
ffffffffc0206414:	78868693          	addi	a3,a3,1928 # ffffffffc020db98 <CSWTCH.84+0x2a0>
ffffffffc0206418:	00006617          	auipc	a2,0x6
ffffffffc020641c:	ad060613          	addi	a2,a2,-1328 # ffffffffc020bee8 <commands+0x210>
ffffffffc0206420:	4eb00593          	li	a1,1259
ffffffffc0206424:	00007517          	auipc	a0,0x7
ffffffffc0206428:	5e450513          	addi	a0,a0,1508 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc020642c:	872fa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206430:	00007697          	auipc	a3,0x7
ffffffffc0206434:	73868693          	addi	a3,a3,1848 # ffffffffc020db68 <CSWTCH.84+0x270>
ffffffffc0206438:	00006617          	auipc	a2,0x6
ffffffffc020643c:	ab060613          	addi	a2,a2,-1360 # ffffffffc020bee8 <commands+0x210>
ffffffffc0206440:	4ea00593          	li	a1,1258
ffffffffc0206444:	00007517          	auipc	a0,0x7
ffffffffc0206448:	5c450513          	addi	a0,a0,1476 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc020644c:	852fa0ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206450:	00007697          	auipc	a3,0x7
ffffffffc0206454:	70868693          	addi	a3,a3,1800 # ffffffffc020db58 <CSWTCH.84+0x260>
ffffffffc0206458:	00006617          	auipc	a2,0x6
ffffffffc020645c:	a9060613          	addi	a2,a2,-1392 # ffffffffc020bee8 <commands+0x210>
ffffffffc0206460:	4e900593          	li	a1,1257
ffffffffc0206464:	00007517          	auipc	a0,0x7
ffffffffc0206468:	5a450513          	addi	a0,a0,1444 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc020646c:	832fa0ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0206470 <do_execve>:
ffffffffc0206470:	d9010113          	addi	sp,sp,-624
ffffffffc0206474:	23513c23          	sd	s5,568(sp)
ffffffffc0206478:	00090a97          	auipc	s5,0x90
ffffffffc020647c:	448a8a93          	addi	s5,s5,1096 # ffffffffc02968c0 <current>
ffffffffc0206480:	000ab683          	ld	a3,0(s5)
ffffffffc0206484:	23813023          	sd	s8,544(sp)
ffffffffc0206488:	fff5871b          	addiw	a4,a1,-1
ffffffffc020648c:	0286bc03          	ld	s8,40(a3)
ffffffffc0206490:	0005869b          	sext.w	a3,a1
ffffffffc0206494:	26113423          	sd	ra,616(sp)
ffffffffc0206498:	26813023          	sd	s0,608(sp)
ffffffffc020649c:	24913c23          	sd	s1,600(sp)
ffffffffc02064a0:	25213823          	sd	s2,592(sp)
ffffffffc02064a4:	25313423          	sd	s3,584(sp)
ffffffffc02064a8:	25413023          	sd	s4,576(sp)
ffffffffc02064ac:	23613823          	sd	s6,560(sp)
ffffffffc02064b0:	23713423          	sd	s7,552(sp)
ffffffffc02064b4:	21913c23          	sd	s9,536(sp)
ffffffffc02064b8:	21a13823          	sd	s10,528(sp)
ffffffffc02064bc:	21b13423          	sd	s11,520(sp)
ffffffffc02064c0:	cc3a                	sw	a4,24(sp)
ffffffffc02064c2:	47fd                	li	a5,31
ffffffffc02064c4:	f036                	sd	a3,32(sp)
ffffffffc02064c6:	5ae7e263          	bltu	a5,a4,ffffffffc0206a6a <do_execve+0x5fa>
ffffffffc02064ca:	842e                	mv	s0,a1
ffffffffc02064cc:	84aa                	mv	s1,a0
ffffffffc02064ce:	8b32                	mv	s6,a2
ffffffffc02064d0:	4581                	li	a1,0
ffffffffc02064d2:	4641                	li	a2,16
ffffffffc02064d4:	18a8                	addi	a0,sp,120
ffffffffc02064d6:	52e050ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc02064da:	000c0c63          	beqz	s8,ffffffffc02064f2 <do_execve+0x82>
ffffffffc02064de:	038c0513          	addi	a0,s8,56
ffffffffc02064e2:	882fe0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc02064e6:	000ab783          	ld	a5,0(s5)
ffffffffc02064ea:	c781                	beqz	a5,ffffffffc02064f2 <do_execve+0x82>
ffffffffc02064ec:	43dc                	lw	a5,4(a5)
ffffffffc02064ee:	04fc2823          	sw	a5,80(s8)
ffffffffc02064f2:	30048463          	beqz	s1,ffffffffc02067fa <do_execve+0x38a>
ffffffffc02064f6:	46c1                	li	a3,16
ffffffffc02064f8:	8626                	mv	a2,s1
ffffffffc02064fa:	18ac                	addi	a1,sp,120
ffffffffc02064fc:	8562                	mv	a0,s8
ffffffffc02064fe:	e8ffd0ef          	jal	ra,ffffffffc020438c <copy_string>
ffffffffc0206502:	56050c63          	beqz	a0,ffffffffc0206a7a <do_execve+0x60a>
ffffffffc0206506:	00341793          	slli	a5,s0,0x3
ffffffffc020650a:	4681                	li	a3,0
ffffffffc020650c:	863e                	mv	a2,a5
ffffffffc020650e:	85da                	mv	a1,s6
ffffffffc0206510:	8562                	mv	a0,s8
ffffffffc0206512:	f43e                	sd	a5,40(sp)
ffffffffc0206514:	d7ffd0ef          	jal	ra,ffffffffc0204292 <user_mem_check>
ffffffffc0206518:	89da                	mv	s3,s6
ffffffffc020651a:	54050a63          	beqz	a0,ffffffffc0206a6e <do_execve+0x5fe>
ffffffffc020651e:	10010b93          	addi	s7,sp,256
ffffffffc0206522:	8a5e                	mv	s4,s7
ffffffffc0206524:	4901                	li	s2,0
ffffffffc0206526:	6505                	lui	a0,0x1
ffffffffc0206528:	a67fb0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc020652c:	84aa                	mv	s1,a0
ffffffffc020652e:	26050e63          	beqz	a0,ffffffffc02067aa <do_execve+0x33a>
ffffffffc0206532:	0009b603          	ld	a2,0(s3) # 2000 <_binary_bin_swap_img_size-0x5d00>
ffffffffc0206536:	85aa                	mv	a1,a0
ffffffffc0206538:	6685                	lui	a3,0x1
ffffffffc020653a:	8562                	mv	a0,s8
ffffffffc020653c:	e51fd0ef          	jal	ra,ffffffffc020438c <copy_string>
ffffffffc0206540:	2a050863          	beqz	a0,ffffffffc02067f0 <do_execve+0x380>
ffffffffc0206544:	009a3023          	sd	s1,0(s4)
ffffffffc0206548:	2905                	addiw	s2,s2,1
ffffffffc020654a:	0a21                	addi	s4,s4,8
ffffffffc020654c:	09a1                	addi	s3,s3,8
ffffffffc020654e:	fd241ce3          	bne	s0,s2,ffffffffc0206526 <do_execve+0xb6>
ffffffffc0206552:	000b3483          	ld	s1,0(s6)
ffffffffc0206556:	1c0c0763          	beqz	s8,ffffffffc0206724 <do_execve+0x2b4>
ffffffffc020655a:	038c0513          	addi	a0,s8,56
ffffffffc020655e:	802fe0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0206562:	000ab783          	ld	a5,0(s5)
ffffffffc0206566:	040c2823          	sw	zero,80(s8)
ffffffffc020656a:	1487b503          	ld	a0,328(a5)
ffffffffc020656e:	d2dfe0ef          	jal	ra,ffffffffc020529a <files_closeall>
ffffffffc0206572:	4581                	li	a1,0
ffffffffc0206574:	8526                	mv	a0,s1
ffffffffc0206576:	fb1fe0ef          	jal	ra,ffffffffc0205526 <sysfile_open>
ffffffffc020657a:	8a2a                	mv	s4,a0
ffffffffc020657c:	1e054a63          	bltz	a0,ffffffffc0206770 <do_execve+0x300>
ffffffffc0206580:	00090797          	auipc	a5,0x90
ffffffffc0206584:	3107b783          	ld	a5,784(a5) # ffffffffc0296890 <boot_pgdir_pa>
ffffffffc0206588:	577d                	li	a4,-1
ffffffffc020658a:	177e                	slli	a4,a4,0x3f
ffffffffc020658c:	83b1                	srli	a5,a5,0xc
ffffffffc020658e:	8fd9                	or	a5,a5,a4
ffffffffc0206590:	18079073          	csrw	satp,a5
ffffffffc0206594:	030c2783          	lw	a5,48(s8)
ffffffffc0206598:	fff7871b          	addiw	a4,a5,-1
ffffffffc020659c:	02ec2823          	sw	a4,48(s8)
ffffffffc02065a0:	2c070263          	beqz	a4,ffffffffc0206864 <do_execve+0x3f4>
ffffffffc02065a4:	000ab783          	ld	a5,0(s5)
ffffffffc02065a8:	0207b423          	sd	zero,40(a5)
ffffffffc02065ac:	e5cfd0ef          	jal	ra,ffffffffc0203c08 <mm_create>
ffffffffc02065b0:	89aa                	mv	s3,a0
ffffffffc02065b2:	1e050a63          	beqz	a0,ffffffffc02067a6 <do_execve+0x336>
ffffffffc02065b6:	4505                	li	a0,1
ffffffffc02065b8:	bb5fb0ef          	jal	ra,ffffffffc020216c <alloc_pages>
ffffffffc02065bc:	1e050263          	beqz	a0,ffffffffc02067a0 <do_execve+0x330>
ffffffffc02065c0:	00090c97          	auipc	s9,0x90
ffffffffc02065c4:	2e8c8c93          	addi	s9,s9,744 # ffffffffc02968a8 <pages>
ffffffffc02065c8:	000cb683          	ld	a3,0(s9)
ffffffffc02065cc:	0000a717          	auipc	a4,0xa
ffffffffc02065d0:	80473703          	ld	a4,-2044(a4) # ffffffffc020fdd0 <nbase>
ffffffffc02065d4:	00090d17          	auipc	s10,0x90
ffffffffc02065d8:	2ccd0d13          	addi	s10,s10,716 # ffffffffc02968a0 <npage>
ffffffffc02065dc:	40d506b3          	sub	a3,a0,a3
ffffffffc02065e0:	8699                	srai	a3,a3,0x6
ffffffffc02065e2:	96ba                	add	a3,a3,a4
ffffffffc02065e4:	e83a                	sd	a4,16(sp)
ffffffffc02065e6:	000d3783          	ld	a5,0(s10)
ffffffffc02065ea:	577d                	li	a4,-1
ffffffffc02065ec:	8331                	srli	a4,a4,0xc
ffffffffc02065ee:	e43a                	sd	a4,8(sp)
ffffffffc02065f0:	8f75                	and	a4,a4,a3
ffffffffc02065f2:	06b2                	slli	a3,a3,0xc
ffffffffc02065f4:	5ef77863          	bgeu	a4,a5,ffffffffc0206be4 <do_execve+0x774>
ffffffffc02065f8:	00090797          	auipc	a5,0x90
ffffffffc02065fc:	2c078793          	addi	a5,a5,704 # ffffffffc02968b8 <va_pa_offset>
ffffffffc0206600:	6384                	ld	s1,0(a5)
ffffffffc0206602:	6605                	lui	a2,0x1
ffffffffc0206604:	00090597          	auipc	a1,0x90
ffffffffc0206608:	2945b583          	ld	a1,660(a1) # ffffffffc0296898 <boot_pgdir_va>
ffffffffc020660c:	94b6                	add	s1,s1,a3
ffffffffc020660e:	8526                	mv	a0,s1
ffffffffc0206610:	446050ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc0206614:	4601                	li	a2,0
ffffffffc0206616:	0099bc23          	sd	s1,24(s3)
ffffffffc020661a:	4581                	li	a1,0
ffffffffc020661c:	8552                	mv	a0,s4
ffffffffc020661e:	96eff0ef          	jal	ra,ffffffffc020578c <sysfile_seek>
ffffffffc0206622:	8b2a                	mv	s6,a0
ffffffffc0206624:	12051e63          	bnez	a0,ffffffffc0206760 <do_execve+0x2f0>
ffffffffc0206628:	04000613          	li	a2,64
ffffffffc020662c:	018c                	addi	a1,sp,192
ffffffffc020662e:	8552                	mv	a0,s4
ffffffffc0206630:	f2ffe0ef          	jal	ra,ffffffffc020555e <sysfile_read>
ffffffffc0206634:	04000793          	li	a5,64
ffffffffc0206638:	12f51463          	bne	a0,a5,ffffffffc0206760 <do_execve+0x2f0>
ffffffffc020663c:	470e                	lw	a4,192(sp)
ffffffffc020663e:	464c47b7          	lui	a5,0x464c4
ffffffffc0206642:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_bin_sfs_img_size+0x4644f27f>
ffffffffc0206646:	32f71763          	bne	a4,a5,ffffffffc0206974 <do_execve+0x504>
ffffffffc020664a:	0f815783          	lhu	a5,248(sp)
ffffffffc020664e:	1e078363          	beqz	a5,ffffffffc0206834 <do_execve+0x3c4>
ffffffffc0206652:	57f1                	li	a5,-4
ffffffffc0206654:	f082                	sd	zero,96(sp)
ffffffffc0206656:	ec82                	sd	zero,88(sp)
ffffffffc0206658:	f802                	sd	zero,48(sp)
ffffffffc020665a:	f4be                	sd	a5,104(sp)
ffffffffc020665c:	e8da                	sd	s6,80(sp)
ffffffffc020665e:	e4a2                	sd	s0,72(sp)
ffffffffc0206660:	758e                	ld	a1,224(sp)
ffffffffc0206662:	67e6                	ld	a5,88(sp)
ffffffffc0206664:	4601                	li	a2,0
ffffffffc0206666:	8552                	mv	a0,s4
ffffffffc0206668:	95be                	add	a1,a1,a5
ffffffffc020666a:	922ff0ef          	jal	ra,ffffffffc020578c <sysfile_seek>
ffffffffc020666e:	e919                	bnez	a0,ffffffffc0206684 <do_execve+0x214>
ffffffffc0206670:	03800613          	li	a2,56
ffffffffc0206674:	012c                	addi	a1,sp,136
ffffffffc0206676:	8552                	mv	a0,s4
ffffffffc0206678:	ee7fe0ef          	jal	ra,ffffffffc020555e <sysfile_read>
ffffffffc020667c:	03800793          	li	a5,56
ffffffffc0206680:	18f50963          	beq	a0,a5,ffffffffc0206812 <do_execve+0x3a2>
ffffffffc0206684:	854e                	mv	a0,s3
ffffffffc0206686:	6b46                	ld	s6,80(sp)
ffffffffc0206688:	6426                	ld	s0,72(sp)
ffffffffc020668a:	869fd0ef          	jal	ra,ffffffffc0203ef2 <exit_mmap>
ffffffffc020668e:	0189b503          	ld	a0,24(s3)
ffffffffc0206692:	beaff0ef          	jal	ra,ffffffffc0205a7c <put_pgdir.isra.0>
ffffffffc0206696:	854e                	mv	a0,s3
ffffffffc0206698:	ebefd0ef          	jal	ra,ffffffffc0203d56 <mm_destroy>
ffffffffc020669c:	77a6                	ld	a5,104(sp)
ffffffffc020669e:	5c079863          	bnez	a5,ffffffffc0206c6e <do_execve+0x7fe>
ffffffffc02066a2:	7722                	ld	a4,40(sp)
ffffffffc02066a4:	fff40793          	addi	a5,s0,-1
ffffffffc02066a8:	ff0b8413          	addi	s0,s7,-16
ffffffffc02066ac:	943a                	add	s0,s0,a4
ffffffffc02066ae:	6762                	ld	a4,24(sp)
ffffffffc02066b0:	078e                	slli	a5,a5,0x3
ffffffffc02066b2:	9bbe                	add	s7,s7,a5
ffffffffc02066b4:	02071693          	slli	a3,a4,0x20
ffffffffc02066b8:	01d6d713          	srli	a4,a3,0x1d
ffffffffc02066bc:	8c19                	sub	s0,s0,a4
ffffffffc02066be:	000bb503          	ld	a0,0(s7)
ffffffffc02066c2:	1be1                	addi	s7,s7,-8
ffffffffc02066c4:	97bfb0ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc02066c8:	fe8b9be3          	bne	s7,s0,ffffffffc02066be <do_execve+0x24e>
ffffffffc02066cc:	000ab403          	ld	s0,0(s5)
ffffffffc02066d0:	4641                	li	a2,16
ffffffffc02066d2:	4581                	li	a1,0
ffffffffc02066d4:	0b440413          	addi	s0,s0,180
ffffffffc02066d8:	8522                	mv	a0,s0
ffffffffc02066da:	32a050ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc02066de:	463d                	li	a2,15
ffffffffc02066e0:	18ac                	addi	a1,sp,120
ffffffffc02066e2:	8522                	mv	a0,s0
ffffffffc02066e4:	372050ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc02066e8:	26813083          	ld	ra,616(sp)
ffffffffc02066ec:	26013403          	ld	s0,608(sp)
ffffffffc02066f0:	25813483          	ld	s1,600(sp)
ffffffffc02066f4:	25013903          	ld	s2,592(sp)
ffffffffc02066f8:	24813983          	ld	s3,584(sp)
ffffffffc02066fc:	24013a03          	ld	s4,576(sp)
ffffffffc0206700:	23813a83          	ld	s5,568(sp)
ffffffffc0206704:	22813b83          	ld	s7,552(sp)
ffffffffc0206708:	22013c03          	ld	s8,544(sp)
ffffffffc020670c:	21813c83          	ld	s9,536(sp)
ffffffffc0206710:	21013d03          	ld	s10,528(sp)
ffffffffc0206714:	20813d83          	ld	s11,520(sp)
ffffffffc0206718:	855a                	mv	a0,s6
ffffffffc020671a:	23013b03          	ld	s6,560(sp)
ffffffffc020671e:	27010113          	addi	sp,sp,624
ffffffffc0206722:	8082                	ret
ffffffffc0206724:	000ab783          	ld	a5,0(s5)
ffffffffc0206728:	1487b503          	ld	a0,328(a5)
ffffffffc020672c:	b6ffe0ef          	jal	ra,ffffffffc020529a <files_closeall>
ffffffffc0206730:	4581                	li	a1,0
ffffffffc0206732:	8526                	mv	a0,s1
ffffffffc0206734:	df3fe0ef          	jal	ra,ffffffffc0205526 <sysfile_open>
ffffffffc0206738:	8a2a                	mv	s4,a0
ffffffffc020673a:	02054b63          	bltz	a0,ffffffffc0206770 <do_execve+0x300>
ffffffffc020673e:	000ab783          	ld	a5,0(s5)
ffffffffc0206742:	779c                	ld	a5,40(a5)
ffffffffc0206744:	e60784e3          	beqz	a5,ffffffffc02065ac <do_execve+0x13c>
ffffffffc0206748:	00007617          	auipc	a2,0x7
ffffffffc020674c:	4b060613          	addi	a2,a2,1200 # ffffffffc020dbf8 <CSWTCH.84+0x300>
ffffffffc0206750:	2dd00593          	li	a1,733
ffffffffc0206754:	00007517          	auipc	a0,0x7
ffffffffc0206758:	2b450513          	addi	a0,a0,692 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc020675c:	d43f90ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206760:	0189b503          	ld	a0,24(s3)
ffffffffc0206764:	5a71                	li	s4,-4
ffffffffc0206766:	b16ff0ef          	jal	ra,ffffffffc0205a7c <put_pgdir.isra.0>
ffffffffc020676a:	854e                	mv	a0,s3
ffffffffc020676c:	deafd0ef          	jal	ra,ffffffffc0203d56 <mm_destroy>
ffffffffc0206770:	7722                	ld	a4,40(sp)
ffffffffc0206772:	fff40793          	addi	a5,s0,-1
ffffffffc0206776:	ff0b8413          	addi	s0,s7,-16
ffffffffc020677a:	943a                	add	s0,s0,a4
ffffffffc020677c:	6762                	ld	a4,24(sp)
ffffffffc020677e:	078e                	slli	a5,a5,0x3
ffffffffc0206780:	9bbe                	add	s7,s7,a5
ffffffffc0206782:	02071693          	slli	a3,a4,0x20
ffffffffc0206786:	01d6d713          	srli	a4,a3,0x1d
ffffffffc020678a:	8c19                	sub	s0,s0,a4
ffffffffc020678c:	000bb503          	ld	a0,0(s7)
ffffffffc0206790:	1be1                	addi	s7,s7,-8
ffffffffc0206792:	8adfb0ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc0206796:	ff741be3          	bne	s0,s7,ffffffffc020678c <do_execve+0x31c>
ffffffffc020679a:	8552                	mv	a0,s4
ffffffffc020679c:	851ff0ef          	jal	ra,ffffffffc0205fec <do_exit>
ffffffffc02067a0:	854e                	mv	a0,s3
ffffffffc02067a2:	db4fd0ef          	jal	ra,ffffffffc0203d56 <mm_destroy>
ffffffffc02067a6:	5a71                	li	s4,-4
ffffffffc02067a8:	b7e1                	j	ffffffffc0206770 <do_execve+0x300>
ffffffffc02067aa:	5b71                	li	s6,-4
ffffffffc02067ac:	02090963          	beqz	s2,ffffffffc02067de <do_execve+0x36e>
ffffffffc02067b0:	00391693          	slli	a3,s2,0x3
ffffffffc02067b4:	fff90793          	addi	a5,s2,-1 # ffffffff7fffffff <_binary_bin_sfs_img_size+0xffffffff7ff8acff>
ffffffffc02067b8:	ff0b8713          	addi	a4,s7,-16
ffffffffc02067bc:	397d                	addiw	s2,s2,-1
ffffffffc02067be:	9736                	add	a4,a4,a3
ffffffffc02067c0:	02091693          	slli	a3,s2,0x20
ffffffffc02067c4:	078e                	slli	a5,a5,0x3
ffffffffc02067c6:	01d6d913          	srli	s2,a3,0x1d
ffffffffc02067ca:	9bbe                	add	s7,s7,a5
ffffffffc02067cc:	41270933          	sub	s2,a4,s2
ffffffffc02067d0:	000bb503          	ld	a0,0(s7)
ffffffffc02067d4:	1be1                	addi	s7,s7,-8
ffffffffc02067d6:	869fb0ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc02067da:	ff791be3          	bne	s2,s7,ffffffffc02067d0 <do_execve+0x360>
ffffffffc02067de:	f00c05e3          	beqz	s8,ffffffffc02066e8 <do_execve+0x278>
ffffffffc02067e2:	038c0513          	addi	a0,s8,56
ffffffffc02067e6:	d7bfd0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc02067ea:	040c2823          	sw	zero,80(s8)
ffffffffc02067ee:	bded                	j	ffffffffc02066e8 <do_execve+0x278>
ffffffffc02067f0:	8526                	mv	a0,s1
ffffffffc02067f2:	84dfb0ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc02067f6:	5b75                	li	s6,-3
ffffffffc02067f8:	bf55                	j	ffffffffc02067ac <do_execve+0x33c>
ffffffffc02067fa:	000ab783          	ld	a5,0(s5)
ffffffffc02067fe:	00007617          	auipc	a2,0x7
ffffffffc0206802:	3ea60613          	addi	a2,a2,1002 # ffffffffc020dbe8 <CSWTCH.84+0x2f0>
ffffffffc0206806:	45c1                	li	a1,16
ffffffffc0206808:	43d4                	lw	a3,4(a5)
ffffffffc020680a:	18a8                	addi	a0,sp,120
ffffffffc020680c:	0e0050ef          	jal	ra,ffffffffc020b8ec <snprintf>
ffffffffc0206810:	b9dd                	j	ffffffffc0206506 <do_execve+0x96>
ffffffffc0206812:	47aa                	lw	a5,136(sp)
ffffffffc0206814:	4705                	li	a4,1
ffffffffc0206816:	06e78263          	beq	a5,a4,ffffffffc020687a <do_execve+0x40a>
ffffffffc020681a:	7706                	ld	a4,96(sp)
ffffffffc020681c:	66e6                	ld	a3,88(sp)
ffffffffc020681e:	0f815783          	lhu	a5,248(sp)
ffffffffc0206822:	2705                	addiw	a4,a4,1
ffffffffc0206824:	03868693          	addi	a3,a3,56 # 1038 <_binary_bin_swap_img_size-0x6cc8>
ffffffffc0206828:	f0ba                	sd	a4,96(sp)
ffffffffc020682a:	ecb6                	sd	a3,88(sp)
ffffffffc020682c:	e2f74ae3          	blt	a4,a5,ffffffffc0206660 <do_execve+0x1f0>
ffffffffc0206830:	6b46                	ld	s6,80(sp)
ffffffffc0206832:	6426                	ld	s0,72(sp)
ffffffffc0206834:	4701                	li	a4,0
ffffffffc0206836:	46ad                	li	a3,11
ffffffffc0206838:	00100637          	lui	a2,0x100
ffffffffc020683c:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0206840:	854e                	mv	a0,s3
ffffffffc0206842:	d66fd0ef          	jal	ra,ffffffffc0203da8 <mm_map>
ffffffffc0206846:	f4aa                	sd	a0,104(sp)
ffffffffc0206848:	24050563          	beqz	a0,ffffffffc0206a92 <do_execve+0x622>
ffffffffc020684c:	854e                	mv	a0,s3
ffffffffc020684e:	ea4fd0ef          	jal	ra,ffffffffc0203ef2 <exit_mmap>
ffffffffc0206852:	0189b503          	ld	a0,24(s3)
ffffffffc0206856:	7a26                	ld	s4,104(sp)
ffffffffc0206858:	a24ff0ef          	jal	ra,ffffffffc0205a7c <put_pgdir.isra.0>
ffffffffc020685c:	854e                	mv	a0,s3
ffffffffc020685e:	cf8fd0ef          	jal	ra,ffffffffc0203d56 <mm_destroy>
ffffffffc0206862:	b739                	j	ffffffffc0206770 <do_execve+0x300>
ffffffffc0206864:	8562                	mv	a0,s8
ffffffffc0206866:	e8cfd0ef          	jal	ra,ffffffffc0203ef2 <exit_mmap>
ffffffffc020686a:	018c3503          	ld	a0,24(s8)
ffffffffc020686e:	a0eff0ef          	jal	ra,ffffffffc0205a7c <put_pgdir.isra.0>
ffffffffc0206872:	8562                	mv	a0,s8
ffffffffc0206874:	ce2fd0ef          	jal	ra,ffffffffc0203d56 <mm_destroy>
ffffffffc0206878:	b335                	j	ffffffffc02065a4 <do_execve+0x134>
ffffffffc020687a:	764a                	ld	a2,176(sp)
ffffffffc020687c:	77aa                	ld	a5,168(sp)
ffffffffc020687e:	34f66e63          	bltu	a2,a5,ffffffffc0206bda <do_execve+0x76a>
ffffffffc0206882:	47ba                	lw	a5,140(sp)
ffffffffc0206884:	0017f693          	andi	a3,a5,1
ffffffffc0206888:	c291                	beqz	a3,ffffffffc020688c <do_execve+0x41c>
ffffffffc020688a:	4691                	li	a3,4
ffffffffc020688c:	0027f713          	andi	a4,a5,2
ffffffffc0206890:	8b91                	andi	a5,a5,4
ffffffffc0206892:	0e071a63          	bnez	a4,ffffffffc0206986 <do_execve+0x516>
ffffffffc0206896:	4745                	li	a4,17
ffffffffc0206898:	e0ba                	sd	a4,64(sp)
ffffffffc020689a:	c789                	beqz	a5,ffffffffc02068a4 <do_execve+0x434>
ffffffffc020689c:	47cd                	li	a5,19
ffffffffc020689e:	0016e693          	ori	a3,a3,1
ffffffffc02068a2:	e0be                	sd	a5,64(sp)
ffffffffc02068a4:	0026f793          	andi	a5,a3,2
ffffffffc02068a8:	0e079363          	bnez	a5,ffffffffc020698e <do_execve+0x51e>
ffffffffc02068ac:	0046f793          	andi	a5,a3,4
ffffffffc02068b0:	c789                	beqz	a5,ffffffffc02068ba <do_execve+0x44a>
ffffffffc02068b2:	6786                	ld	a5,64(sp)
ffffffffc02068b4:	0087e793          	ori	a5,a5,8
ffffffffc02068b8:	e0be                	sd	a5,64(sp)
ffffffffc02068ba:	65ea                	ld	a1,152(sp)
ffffffffc02068bc:	4701                	li	a4,0
ffffffffc02068be:	854e                	mv	a0,s3
ffffffffc02068c0:	ce8fd0ef          	jal	ra,ffffffffc0203da8 <mm_map>
ffffffffc02068c4:	f4aa                	sd	a0,104(sp)
ffffffffc02068c6:	30051863          	bnez	a0,ffffffffc0206bd6 <do_execve+0x766>
ffffffffc02068ca:	6b6a                	ld	s6,152(sp)
ffffffffc02068cc:	7daa                	ld	s11,168(sp)
ffffffffc02068ce:	77fd                	lui	a5,0xfffff
ffffffffc02068d0:	00fb7433          	and	s0,s6,a5
ffffffffc02068d4:	01bb07b3          	add	a5,s6,s11
ffffffffc02068d8:	8922                	mv	s2,s0
ffffffffc02068da:	8dbe                	mv	s11,a5
ffffffffc02068dc:	1afb7963          	bgeu	s6,a5,ffffffffc0206a8e <do_execve+0x61e>
ffffffffc02068e0:	0189b503          	ld	a0,24(s3)
ffffffffc02068e4:	6606                	ld	a2,64(sp)
ffffffffc02068e6:	85ca                	mv	a1,s2
ffffffffc02068e8:	a3afd0ef          	jal	ra,ffffffffc0203b22 <pgdir_alloc_page>
ffffffffc02068ec:	842a                	mv	s0,a0
ffffffffc02068ee:	16050a63          	beqz	a0,ffffffffc0206a62 <do_execve+0x5f2>
ffffffffc02068f2:	6785                	lui	a5,0x1
ffffffffc02068f4:	00f90c33          	add	s8,s2,a5
ffffffffc02068f8:	416c04b3          	sub	s1,s8,s6
ffffffffc02068fc:	018df463          	bgeu	s11,s8,ffffffffc0206904 <do_execve+0x494>
ffffffffc0206900:	416d84b3          	sub	s1,s11,s6
ffffffffc0206904:	000cb783          	ld	a5,0(s9)
ffffffffc0206908:	6742                	ld	a4,16(sp)
ffffffffc020690a:	656a                	ld	a0,152(sp)
ffffffffc020690c:	40f407b3          	sub	a5,s0,a5
ffffffffc0206910:	8799                	srai	a5,a5,0x6
ffffffffc0206912:	97ba                	add	a5,a5,a4
ffffffffc0206914:	65ca                	ld	a1,144(sp)
ffffffffc0206916:	6722                	ld	a4,8(sp)
ffffffffc0206918:	000d3603          	ld	a2,0(s10)
ffffffffc020691c:	8d89                	sub	a1,a1,a0
ffffffffc020691e:	00e7f533          	and	a0,a5,a4
ffffffffc0206922:	07b2                	slli	a5,a5,0xc
ffffffffc0206924:	f83e                	sd	a5,48(sp)
ffffffffc0206926:	95da                	add	a1,a1,s6
ffffffffc0206928:	2ac57d63          	bgeu	a0,a2,ffffffffc0206be2 <do_execve+0x772>
ffffffffc020692c:	00090797          	auipc	a5,0x90
ffffffffc0206930:	f8c78793          	addi	a5,a5,-116 # ffffffffc02968b8 <va_pa_offset>
ffffffffc0206934:	639c                	ld	a5,0(a5)
ffffffffc0206936:	4601                	li	a2,0
ffffffffc0206938:	8552                	mv	a0,s4
ffffffffc020693a:	fc3e                	sd	a5,56(sp)
ffffffffc020693c:	e51fe0ef          	jal	ra,ffffffffc020578c <sysfile_seek>
ffffffffc0206940:	ed09                	bnez	a0,ffffffffc020695a <do_execve+0x4ea>
ffffffffc0206942:	7742                	ld	a4,48(sp)
ffffffffc0206944:	77e2                	ld	a5,56(sp)
ffffffffc0206946:	412b05b3          	sub	a1,s6,s2
ffffffffc020694a:	8626                	mv	a2,s1
ffffffffc020694c:	97ba                	add	a5,a5,a4
ffffffffc020694e:	95be                	add	a1,a1,a5
ffffffffc0206950:	8552                	mv	a0,s4
ffffffffc0206952:	c0dfe0ef          	jal	ra,ffffffffc020555e <sysfile_read>
ffffffffc0206956:	02a48f63          	beq	s1,a0,ffffffffc0206994 <do_execve+0x524>
ffffffffc020695a:	854e                	mv	a0,s3
ffffffffc020695c:	6b46                	ld	s6,80(sp)
ffffffffc020695e:	6426                	ld	s0,72(sp)
ffffffffc0206960:	d92fd0ef          	jal	ra,ffffffffc0203ef2 <exit_mmap>
ffffffffc0206964:	0189b503          	ld	a0,24(s3)
ffffffffc0206968:	914ff0ef          	jal	ra,ffffffffc0205a7c <put_pgdir.isra.0>
ffffffffc020696c:	854e                	mv	a0,s3
ffffffffc020696e:	be8fd0ef          	jal	ra,ffffffffc0203d56 <mm_destroy>
ffffffffc0206972:	bb05                	j	ffffffffc02066a2 <do_execve+0x232>
ffffffffc0206974:	0189b503          	ld	a0,24(s3)
ffffffffc0206978:	5a61                	li	s4,-8
ffffffffc020697a:	902ff0ef          	jal	ra,ffffffffc0205a7c <put_pgdir.isra.0>
ffffffffc020697e:	854e                	mv	a0,s3
ffffffffc0206980:	bd6fd0ef          	jal	ra,ffffffffc0203d56 <mm_destroy>
ffffffffc0206984:	b3f5                	j	ffffffffc0206770 <do_execve+0x300>
ffffffffc0206986:	0026e693          	ori	a3,a3,2
ffffffffc020698a:	f00799e3          	bnez	a5,ffffffffc020689c <do_execve+0x42c>
ffffffffc020698e:	47dd                	li	a5,23
ffffffffc0206990:	e0be                	sd	a5,64(sp)
ffffffffc0206992:	bf29                	j	ffffffffc02068ac <do_execve+0x43c>
ffffffffc0206994:	9b26                	add	s6,s6,s1
ffffffffc0206996:	01bb7463          	bgeu	s6,s11,ffffffffc020699e <do_execve+0x52e>
ffffffffc020699a:	8962                	mv	s2,s8
ffffffffc020699c:	b791                	j	ffffffffc02068e0 <do_execve+0x470>
ffffffffc020699e:	64ea                	ld	s1,152(sp)
ffffffffc02069a0:	f822                	sd	s0,48(sp)
ffffffffc02069a2:	8962                	mv	s2,s8
ffffffffc02069a4:	76ca                	ld	a3,176(sp)
ffffffffc02069a6:	94b6                	add	s1,s1,a3
ffffffffc02069a8:	052b7c63          	bgeu	s6,s2,ffffffffc0206a00 <do_execve+0x590>
ffffffffc02069ac:	e76487e3          	beq	s1,s6,ffffffffc020681a <do_execve+0x3aa>
ffffffffc02069b0:	6785                	lui	a5,0x1
ffffffffc02069b2:	00fb0533          	add	a0,s6,a5
ffffffffc02069b6:	41250533          	sub	a0,a0,s2
ffffffffc02069ba:	41648433          	sub	s0,s1,s6
ffffffffc02069be:	0124e463          	bltu	s1,s2,ffffffffc02069c6 <do_execve+0x556>
ffffffffc02069c2:	41690433          	sub	s0,s2,s6
ffffffffc02069c6:	77c2                	ld	a5,48(sp)
ffffffffc02069c8:	000cb683          	ld	a3,0(s9)
ffffffffc02069cc:	000d3603          	ld	a2,0(s10)
ffffffffc02069d0:	40d786b3          	sub	a3,a5,a3
ffffffffc02069d4:	67c2                	ld	a5,16(sp)
ffffffffc02069d6:	8699                	srai	a3,a3,0x6
ffffffffc02069d8:	96be                	add	a3,a3,a5
ffffffffc02069da:	67a2                	ld	a5,8(sp)
ffffffffc02069dc:	00f6f5b3          	and	a1,a3,a5
ffffffffc02069e0:	06b2                	slli	a3,a3,0xc
ffffffffc02069e2:	20c5f163          	bgeu	a1,a2,ffffffffc0206be4 <do_execve+0x774>
ffffffffc02069e6:	00090797          	auipc	a5,0x90
ffffffffc02069ea:	ed278793          	addi	a5,a5,-302 # ffffffffc02968b8 <va_pa_offset>
ffffffffc02069ee:	0007b803          	ld	a6,0(a5)
ffffffffc02069f2:	8622                	mv	a2,s0
ffffffffc02069f4:	4581                	li	a1,0
ffffffffc02069f6:	96c2                	add	a3,a3,a6
ffffffffc02069f8:	9536                	add	a0,a0,a3
ffffffffc02069fa:	00a050ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc02069fe:	9b22                	add	s6,s6,s0
ffffffffc0206a00:	e09b7de3          	bgeu	s6,s1,ffffffffc020681a <do_execve+0x3aa>
ffffffffc0206a04:	6406                	ld	s0,64(sp)
ffffffffc0206a06:	6dc2                	ld	s11,16(sp)
ffffffffc0206a08:	a0a9                	j	ffffffffc0206a52 <do_execve+0x5e2>
ffffffffc0206a0a:	6785                	lui	a5,0x1
ffffffffc0206a0c:	412b0533          	sub	a0,s6,s2
ffffffffc0206a10:	993e                	add	s2,s2,a5
ffffffffc0206a12:	41690633          	sub	a2,s2,s6
ffffffffc0206a16:	0124f463          	bgeu	s1,s2,ffffffffc0206a1e <do_execve+0x5ae>
ffffffffc0206a1a:	41648633          	sub	a2,s1,s6
ffffffffc0206a1e:	000cb783          	ld	a5,0(s9)
ffffffffc0206a22:	66a2                	ld	a3,8(sp)
ffffffffc0206a24:	000d3703          	ld	a4,0(s10)
ffffffffc0206a28:	40fc07b3          	sub	a5,s8,a5
ffffffffc0206a2c:	8799                	srai	a5,a5,0x6
ffffffffc0206a2e:	97ee                	add	a5,a5,s11
ffffffffc0206a30:	8efd                	and	a3,a3,a5
ffffffffc0206a32:	07b2                	slli	a5,a5,0xc
ffffffffc0206a34:	1ce6f463          	bgeu	a3,a4,ffffffffc0206bfc <do_execve+0x78c>
ffffffffc0206a38:	00090717          	auipc	a4,0x90
ffffffffc0206a3c:	e8070713          	addi	a4,a4,-384 # ffffffffc02968b8 <va_pa_offset>
ffffffffc0206a40:	6318                	ld	a4,0(a4)
ffffffffc0206a42:	9b32                	add	s6,s6,a2
ffffffffc0206a44:	4581                	li	a1,0
ffffffffc0206a46:	97ba                	add	a5,a5,a4
ffffffffc0206a48:	953e                	add	a0,a0,a5
ffffffffc0206a4a:	7bb040ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc0206a4e:	029b7463          	bgeu	s6,s1,ffffffffc0206a76 <do_execve+0x606>
ffffffffc0206a52:	0189b503          	ld	a0,24(s3)
ffffffffc0206a56:	8622                	mv	a2,s0
ffffffffc0206a58:	85ca                	mv	a1,s2
ffffffffc0206a5a:	8c8fd0ef          	jal	ra,ffffffffc0203b22 <pgdir_alloc_page>
ffffffffc0206a5e:	8c2a                	mv	s8,a0
ffffffffc0206a60:	f54d                	bnez	a0,ffffffffc0206a0a <do_execve+0x59a>
ffffffffc0206a62:	57f1                	li	a5,-4
ffffffffc0206a64:	6426                	ld	s0,72(sp)
ffffffffc0206a66:	f4be                	sd	a5,104(sp)
ffffffffc0206a68:	b3d5                	j	ffffffffc020684c <do_execve+0x3dc>
ffffffffc0206a6a:	5b75                	li	s6,-3
ffffffffc0206a6c:	b9b5                	j	ffffffffc02066e8 <do_execve+0x278>
ffffffffc0206a6e:	5b75                	li	s6,-3
ffffffffc0206a70:	d60c19e3          	bnez	s8,ffffffffc02067e2 <do_execve+0x372>
ffffffffc0206a74:	b995                	j	ffffffffc02066e8 <do_execve+0x278>
ffffffffc0206a76:	f862                	sd	s8,48(sp)
ffffffffc0206a78:	b34d                	j	ffffffffc020681a <do_execve+0x3aa>
ffffffffc0206a7a:	fe0c08e3          	beqz	s8,ffffffffc0206a6a <do_execve+0x5fa>
ffffffffc0206a7e:	038c0513          	addi	a0,s8,56
ffffffffc0206a82:	adffd0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0206a86:	5b75                	li	s6,-3
ffffffffc0206a88:	040c2823          	sw	zero,80(s8)
ffffffffc0206a8c:	b9b1                	j	ffffffffc02066e8 <do_execve+0x278>
ffffffffc0206a8e:	84da                	mv	s1,s6
ffffffffc0206a90:	bf11                	j	ffffffffc02069a4 <do_execve+0x534>
ffffffffc0206a92:	0189b503          	ld	a0,24(s3)
ffffffffc0206a96:	467d                	li	a2,31
ffffffffc0206a98:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0206a9c:	886fd0ef          	jal	ra,ffffffffc0203b22 <pgdir_alloc_page>
ffffffffc0206aa0:	1a050763          	beqz	a0,ffffffffc0206c4e <do_execve+0x7de>
ffffffffc0206aa4:	0189b503          	ld	a0,24(s3)
ffffffffc0206aa8:	467d                	li	a2,31
ffffffffc0206aaa:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0206aae:	874fd0ef          	jal	ra,ffffffffc0203b22 <pgdir_alloc_page>
ffffffffc0206ab2:	1e050063          	beqz	a0,ffffffffc0206c92 <do_execve+0x822>
ffffffffc0206ab6:	0189b503          	ld	a0,24(s3)
ffffffffc0206aba:	467d                	li	a2,31
ffffffffc0206abc:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0206ac0:	862fd0ef          	jal	ra,ffffffffc0203b22 <pgdir_alloc_page>
ffffffffc0206ac4:	1a050763          	beqz	a0,ffffffffc0206c72 <do_execve+0x802>
ffffffffc0206ac8:	0189b503          	ld	a0,24(s3)
ffffffffc0206acc:	467d                	li	a2,31
ffffffffc0206ace:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0206ad2:	850fd0ef          	jal	ra,ffffffffc0203b22 <pgdir_alloc_page>
ffffffffc0206ad6:	14050c63          	beqz	a0,ffffffffc0206c2e <do_execve+0x7be>
ffffffffc0206ada:	0309a783          	lw	a5,48(s3)
ffffffffc0206ade:	000ab703          	ld	a4,0(s5)
ffffffffc0206ae2:	0189b683          	ld	a3,24(s3)
ffffffffc0206ae6:	2785                	addiw	a5,a5,1
ffffffffc0206ae8:	02f9a823          	sw	a5,48(s3)
ffffffffc0206aec:	03373423          	sd	s3,40(a4)
ffffffffc0206af0:	c02007b7          	lui	a5,0xc0200
ffffffffc0206af4:	12f6e163          	bltu	a3,a5,ffffffffc0206c16 <do_execve+0x7a6>
ffffffffc0206af8:	00090797          	auipc	a5,0x90
ffffffffc0206afc:	dc078793          	addi	a5,a5,-576 # ffffffffc02968b8 <va_pa_offset>
ffffffffc0206b00:	639c                	ld	a5,0(a5)
ffffffffc0206b02:	8e9d                	sub	a3,a3,a5
ffffffffc0206b04:	f754                	sd	a3,168(a4)
ffffffffc0206b06:	577d                	li	a4,-1
ffffffffc0206b08:	00c6d793          	srli	a5,a3,0xc
ffffffffc0206b0c:	177e                	slli	a4,a4,0x3f
ffffffffc0206b0e:	8fd9                	or	a5,a5,a4
ffffffffc0206b10:	18079073          	csrw	satp,a5
ffffffffc0206b14:	7a02                	ld	s4,32(sp)
ffffffffc0206b16:	4981                	li	s3,0
ffffffffc0206b18:	895e                	mv	s2,s7
ffffffffc0206b1a:	4481                	li	s1,0
ffffffffc0206b1c:	00093503          	ld	a0,0(s2)
ffffffffc0206b20:	6585                	lui	a1,0x1
ffffffffc0206b22:	2485                	addiw	s1,s1,1
ffffffffc0206b24:	631040ef          	jal	ra,ffffffffc020b954 <strnlen>
ffffffffc0206b28:	00150793          	addi	a5,a0,1
ffffffffc0206b2c:	013789bb          	addw	s3,a5,s3
ffffffffc0206b30:	0921                	addi	s2,s2,8
ffffffffc0206b32:	ff44e5e3          	bltu	s1,s4,ffffffffc0206b1c <do_execve+0x6ac>
ffffffffc0206b36:	80000937          	lui	s2,0x80000
ffffffffc0206b3a:	4139093b          	subw	s2,s2,s3
ffffffffc0206b3e:	77a2                	ld	a5,40(sp)
ffffffffc0206b40:	1902                	slli	s2,s2,0x20
ffffffffc0206b42:	02095913          	srli	s2,s2,0x20
ffffffffc0206b46:	ff897913          	andi	s2,s2,-8
ffffffffc0206b4a:	00878993          	addi	s3,a5,8
ffffffffc0206b4e:	413909b3          	sub	s3,s2,s3
ffffffffc0206b52:	41798db3          	sub	s11,s3,s7
ffffffffc0206b56:	e422                	sd	s0,8(sp)
ffffffffc0206b58:	8d5e                	mv	s10,s7
ffffffffc0206b5a:	4a01                	li	s4,0
ffffffffc0206b5c:	4c01                	li	s8,0
ffffffffc0206b5e:	846e                	mv	s0,s11
ffffffffc0206b60:	000d3d83          	ld	s11,0(s10)
ffffffffc0206b64:	020a1c93          	slli	s9,s4,0x20
ffffffffc0206b68:	6585                	lui	a1,0x1
ffffffffc0206b6a:	856e                	mv	a0,s11
ffffffffc0206b6c:	020cdc93          	srli	s9,s9,0x20
ffffffffc0206b70:	5e5040ef          	jal	ra,ffffffffc020b954 <strnlen>
ffffffffc0206b74:	9cca                	add	s9,s9,s2
ffffffffc0206b76:	84aa                	mv	s1,a0
ffffffffc0206b78:	85ee                	mv	a1,s11
ffffffffc0206b7a:	8566                	mv	a0,s9
ffffffffc0206b7c:	5f5040ef          	jal	ra,ffffffffc020b970 <strcpy>
ffffffffc0206b80:	01a407b3          	add	a5,s0,s10
ffffffffc0206b84:	0197b023          	sd	s9,0(a5)
ffffffffc0206b88:	7782                	ld	a5,32(sp)
ffffffffc0206b8a:	2485                	addiw	s1,s1,1
ffffffffc0206b8c:	2c05                	addiw	s8,s8,1
ffffffffc0206b8e:	01448a3b          	addw	s4,s1,s4
ffffffffc0206b92:	0d21                	addi	s10,s10,8
ffffffffc0206b94:	fcfc66e3          	bltu	s8,a5,ffffffffc0206b60 <do_execve+0x6f0>
ffffffffc0206b98:	000ab783          	ld	a5,0(s5)
ffffffffc0206b9c:	7722                	ld	a4,40(sp)
ffffffffc0206b9e:	12000613          	li	a2,288
ffffffffc0206ba2:	73c4                	ld	s1,160(a5)
ffffffffc0206ba4:	974e                	add	a4,a4,s3
ffffffffc0206ba6:	00073023          	sd	zero,0(a4)
ffffffffc0206baa:	4581                	li	a1,0
ffffffffc0206bac:	8526                	mv	a0,s1
ffffffffc0206bae:	6422                	ld	s0,8(sp)
ffffffffc0206bb0:	655040ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc0206bb4:	67ee                	ld	a5,216(sp)
ffffffffc0206bb6:	0134b823          	sd	s3,16(s1)
ffffffffc0206bba:	10f4b423          	sd	a5,264(s1)
ffffffffc0206bbe:	100027f3          	csrr	a5,sstatus
ffffffffc0206bc2:	edf7f793          	andi	a5,a5,-289
ffffffffc0206bc6:	0207e793          	ori	a5,a5,32
ffffffffc0206bca:	10f4b023          	sd	a5,256(s1)
ffffffffc0206bce:	e8a0                	sd	s0,80(s1)
ffffffffc0206bd0:	0534bc23          	sd	s3,88(s1)
ffffffffc0206bd4:	b4f9                	j	ffffffffc02066a2 <do_execve+0x232>
ffffffffc0206bd6:	6426                	ld	s0,72(sp)
ffffffffc0206bd8:	b995                	j	ffffffffc020684c <do_execve+0x3dc>
ffffffffc0206bda:	57e1                	li	a5,-8
ffffffffc0206bdc:	6426                	ld	s0,72(sp)
ffffffffc0206bde:	f4be                	sd	a5,104(sp)
ffffffffc0206be0:	b1b5                	j	ffffffffc020684c <do_execve+0x3dc>
ffffffffc0206be2:	86be                	mv	a3,a5
ffffffffc0206be4:	00006617          	auipc	a2,0x6
ffffffffc0206be8:	e2460613          	addi	a2,a2,-476 # ffffffffc020ca08 <default_pmm_manager+0x38>
ffffffffc0206bec:	07100593          	li	a1,113
ffffffffc0206bf0:	00006517          	auipc	a0,0x6
ffffffffc0206bf4:	e4050513          	addi	a0,a0,-448 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0206bf8:	8a7f90ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206bfc:	86be                	mv	a3,a5
ffffffffc0206bfe:	00006617          	auipc	a2,0x6
ffffffffc0206c02:	e0a60613          	addi	a2,a2,-502 # ffffffffc020ca08 <default_pmm_manager+0x38>
ffffffffc0206c06:	07100593          	li	a1,113
ffffffffc0206c0a:	00006517          	auipc	a0,0x6
ffffffffc0206c0e:	e2650513          	addi	a0,a0,-474 # ffffffffc020ca30 <default_pmm_manager+0x60>
ffffffffc0206c12:	88df90ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206c16:	00006617          	auipc	a2,0x6
ffffffffc0206c1a:	e9a60613          	addi	a2,a2,-358 # ffffffffc020cab0 <default_pmm_manager+0xe0>
ffffffffc0206c1e:	38100593          	li	a1,897
ffffffffc0206c22:	00007517          	auipc	a0,0x7
ffffffffc0206c26:	de650513          	addi	a0,a0,-538 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0206c2a:	875f90ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206c2e:	00007697          	auipc	a3,0x7
ffffffffc0206c32:	0ca68693          	addi	a3,a3,202 # ffffffffc020dcf8 <CSWTCH.84+0x400>
ffffffffc0206c36:	00005617          	auipc	a2,0x5
ffffffffc0206c3a:	2b260613          	addi	a2,a2,690 # ffffffffc020bee8 <commands+0x210>
ffffffffc0206c3e:	37c00593          	li	a1,892
ffffffffc0206c42:	00007517          	auipc	a0,0x7
ffffffffc0206c46:	dc650513          	addi	a0,a0,-570 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0206c4a:	855f90ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206c4e:	00007697          	auipc	a3,0x7
ffffffffc0206c52:	fd268693          	addi	a3,a3,-46 # ffffffffc020dc20 <CSWTCH.84+0x328>
ffffffffc0206c56:	00005617          	auipc	a2,0x5
ffffffffc0206c5a:	29260613          	addi	a2,a2,658 # ffffffffc020bee8 <commands+0x210>
ffffffffc0206c5e:	37900593          	li	a1,889
ffffffffc0206c62:	00007517          	auipc	a0,0x7
ffffffffc0206c66:	da650513          	addi	a0,a0,-602 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0206c6a:	835f90ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206c6e:	7a26                	ld	s4,104(sp)
ffffffffc0206c70:	b601                	j	ffffffffc0206770 <do_execve+0x300>
ffffffffc0206c72:	00007697          	auipc	a3,0x7
ffffffffc0206c76:	03e68693          	addi	a3,a3,62 # ffffffffc020dcb0 <CSWTCH.84+0x3b8>
ffffffffc0206c7a:	00005617          	auipc	a2,0x5
ffffffffc0206c7e:	26e60613          	addi	a2,a2,622 # ffffffffc020bee8 <commands+0x210>
ffffffffc0206c82:	37b00593          	li	a1,891
ffffffffc0206c86:	00007517          	auipc	a0,0x7
ffffffffc0206c8a:	d8250513          	addi	a0,a0,-638 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0206c8e:	811f90ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206c92:	00007697          	auipc	a3,0x7
ffffffffc0206c96:	fd668693          	addi	a3,a3,-42 # ffffffffc020dc68 <CSWTCH.84+0x370>
ffffffffc0206c9a:	00005617          	auipc	a2,0x5
ffffffffc0206c9e:	24e60613          	addi	a2,a2,590 # ffffffffc020bee8 <commands+0x210>
ffffffffc0206ca2:	37a00593          	li	a1,890
ffffffffc0206ca6:	00007517          	auipc	a0,0x7
ffffffffc0206caa:	d6250513          	addi	a0,a0,-670 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0206cae:	ff0f90ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0206cb2 <user_main>:
ffffffffc0206cb2:	7179                	addi	sp,sp,-48
ffffffffc0206cb4:	e84a                	sd	s2,16(sp)
ffffffffc0206cb6:	00090917          	auipc	s2,0x90
ffffffffc0206cba:	c0a90913          	addi	s2,s2,-1014 # ffffffffc02968c0 <current>
ffffffffc0206cbe:	00093783          	ld	a5,0(s2)
ffffffffc0206cc2:	00007617          	auipc	a2,0x7
ffffffffc0206cc6:	07e60613          	addi	a2,a2,126 # ffffffffc020dd40 <CSWTCH.84+0x448>
ffffffffc0206cca:	00007517          	auipc	a0,0x7
ffffffffc0206cce:	07e50513          	addi	a0,a0,126 # ffffffffc020dd48 <CSWTCH.84+0x450>
ffffffffc0206cd2:	43cc                	lw	a1,4(a5)
ffffffffc0206cd4:	f406                	sd	ra,40(sp)
ffffffffc0206cd6:	f022                	sd	s0,32(sp)
ffffffffc0206cd8:	ec26                	sd	s1,24(sp)
ffffffffc0206cda:	e032                	sd	a2,0(sp)
ffffffffc0206cdc:	e402                	sd	zero,8(sp)
ffffffffc0206cde:	cc8f90ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0206ce2:	6782                	ld	a5,0(sp)
ffffffffc0206ce4:	cfb9                	beqz	a5,ffffffffc0206d42 <user_main+0x90>
ffffffffc0206ce6:	003c                	addi	a5,sp,8
ffffffffc0206ce8:	4401                	li	s0,0
ffffffffc0206cea:	6398                	ld	a4,0(a5)
ffffffffc0206cec:	0405                	addi	s0,s0,1
ffffffffc0206cee:	07a1                	addi	a5,a5,8
ffffffffc0206cf0:	ff6d                	bnez	a4,ffffffffc0206cea <user_main+0x38>
ffffffffc0206cf2:	00093783          	ld	a5,0(s2)
ffffffffc0206cf6:	12000613          	li	a2,288
ffffffffc0206cfa:	6b84                	ld	s1,16(a5)
ffffffffc0206cfc:	73cc                	ld	a1,160(a5)
ffffffffc0206cfe:	6789                	lui	a5,0x2
ffffffffc0206d00:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_bin_swap_img_size-0x5e20>
ffffffffc0206d04:	94be                	add	s1,s1,a5
ffffffffc0206d06:	8526                	mv	a0,s1
ffffffffc0206d08:	54f040ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc0206d0c:	00093783          	ld	a5,0(s2)
ffffffffc0206d10:	860a                	mv	a2,sp
ffffffffc0206d12:	0004059b          	sext.w	a1,s0
ffffffffc0206d16:	f3c4                	sd	s1,160(a5)
ffffffffc0206d18:	00007517          	auipc	a0,0x7
ffffffffc0206d1c:	02850513          	addi	a0,a0,40 # ffffffffc020dd40 <CSWTCH.84+0x448>
ffffffffc0206d20:	f50ff0ef          	jal	ra,ffffffffc0206470 <do_execve>
ffffffffc0206d24:	8126                	mv	sp,s1
ffffffffc0206d26:	d2afa06f          	j	ffffffffc0201250 <__trapret>
ffffffffc0206d2a:	00007617          	auipc	a2,0x7
ffffffffc0206d2e:	04660613          	addi	a2,a2,70 # ffffffffc020dd70 <CSWTCH.84+0x478>
ffffffffc0206d32:	4c900593          	li	a1,1225
ffffffffc0206d36:	00007517          	auipc	a0,0x7
ffffffffc0206d3a:	cd250513          	addi	a0,a0,-814 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0206d3e:	f60f90ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206d42:	4401                	li	s0,0
ffffffffc0206d44:	b77d                	j	ffffffffc0206cf2 <user_main+0x40>

ffffffffc0206d46 <do_yield>:
ffffffffc0206d46:	00090797          	auipc	a5,0x90
ffffffffc0206d4a:	b7a7b783          	ld	a5,-1158(a5) # ffffffffc02968c0 <current>
ffffffffc0206d4e:	4705                	li	a4,1
ffffffffc0206d50:	ef98                	sd	a4,24(a5)
ffffffffc0206d52:	4501                	li	a0,0
ffffffffc0206d54:	8082                	ret

ffffffffc0206d56 <do_wait>:
ffffffffc0206d56:	1101                	addi	sp,sp,-32
ffffffffc0206d58:	e822                	sd	s0,16(sp)
ffffffffc0206d5a:	e426                	sd	s1,8(sp)
ffffffffc0206d5c:	ec06                	sd	ra,24(sp)
ffffffffc0206d5e:	842e                	mv	s0,a1
ffffffffc0206d60:	84aa                	mv	s1,a0
ffffffffc0206d62:	c999                	beqz	a1,ffffffffc0206d78 <do_wait+0x22>
ffffffffc0206d64:	00090797          	auipc	a5,0x90
ffffffffc0206d68:	b5c7b783          	ld	a5,-1188(a5) # ffffffffc02968c0 <current>
ffffffffc0206d6c:	7788                	ld	a0,40(a5)
ffffffffc0206d6e:	4685                	li	a3,1
ffffffffc0206d70:	4611                	li	a2,4
ffffffffc0206d72:	d20fd0ef          	jal	ra,ffffffffc0204292 <user_mem_check>
ffffffffc0206d76:	c909                	beqz	a0,ffffffffc0206d88 <do_wait+0x32>
ffffffffc0206d78:	85a2                	mv	a1,s0
ffffffffc0206d7a:	6442                	ld	s0,16(sp)
ffffffffc0206d7c:	60e2                	ld	ra,24(sp)
ffffffffc0206d7e:	8526                	mv	a0,s1
ffffffffc0206d80:	64a2                	ld	s1,8(sp)
ffffffffc0206d82:	6105                	addi	sp,sp,32
ffffffffc0206d84:	bcaff06f          	j	ffffffffc020614e <do_wait.part.0>
ffffffffc0206d88:	60e2                	ld	ra,24(sp)
ffffffffc0206d8a:	6442                	ld	s0,16(sp)
ffffffffc0206d8c:	64a2                	ld	s1,8(sp)
ffffffffc0206d8e:	5575                	li	a0,-3
ffffffffc0206d90:	6105                	addi	sp,sp,32
ffffffffc0206d92:	8082                	ret

ffffffffc0206d94 <do_kill>:
ffffffffc0206d94:	1141                	addi	sp,sp,-16
ffffffffc0206d96:	6789                	lui	a5,0x2
ffffffffc0206d98:	e406                	sd	ra,8(sp)
ffffffffc0206d9a:	e022                	sd	s0,0(sp)
ffffffffc0206d9c:	fff5071b          	addiw	a4,a0,-1
ffffffffc0206da0:	17f9                	addi	a5,a5,-2
ffffffffc0206da2:	02e7e963          	bltu	a5,a4,ffffffffc0206dd4 <do_kill+0x40>
ffffffffc0206da6:	842a                	mv	s0,a0
ffffffffc0206da8:	45a9                	li	a1,10
ffffffffc0206daa:	2501                	sext.w	a0,a0
ffffffffc0206dac:	6fc040ef          	jal	ra,ffffffffc020b4a8 <hash32>
ffffffffc0206db0:	02051793          	slli	a5,a0,0x20
ffffffffc0206db4:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0206db8:	0008b797          	auipc	a5,0x8b
ffffffffc0206dbc:	a0878793          	addi	a5,a5,-1528 # ffffffffc02917c0 <hash_list>
ffffffffc0206dc0:	953e                	add	a0,a0,a5
ffffffffc0206dc2:	87aa                	mv	a5,a0
ffffffffc0206dc4:	a029                	j	ffffffffc0206dce <do_kill+0x3a>
ffffffffc0206dc6:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0206dca:	00870b63          	beq	a4,s0,ffffffffc0206de0 <do_kill+0x4c>
ffffffffc0206dce:	679c                	ld	a5,8(a5)
ffffffffc0206dd0:	fef51be3          	bne	a0,a5,ffffffffc0206dc6 <do_kill+0x32>
ffffffffc0206dd4:	5475                	li	s0,-3
ffffffffc0206dd6:	60a2                	ld	ra,8(sp)
ffffffffc0206dd8:	8522                	mv	a0,s0
ffffffffc0206dda:	6402                	ld	s0,0(sp)
ffffffffc0206ddc:	0141                	addi	sp,sp,16
ffffffffc0206dde:	8082                	ret
ffffffffc0206de0:	fd87a703          	lw	a4,-40(a5)
ffffffffc0206de4:	00177693          	andi	a3,a4,1
ffffffffc0206de8:	e295                	bnez	a3,ffffffffc0206e0c <do_kill+0x78>
ffffffffc0206dea:	4bd4                	lw	a3,20(a5)
ffffffffc0206dec:	00176713          	ori	a4,a4,1
ffffffffc0206df0:	fce7ac23          	sw	a4,-40(a5)
ffffffffc0206df4:	4401                	li	s0,0
ffffffffc0206df6:	fe06d0e3          	bgez	a3,ffffffffc0206dd6 <do_kill+0x42>
ffffffffc0206dfa:	f2878513          	addi	a0,a5,-216
ffffffffc0206dfe:	45a000ef          	jal	ra,ffffffffc0207258 <wakeup_proc>
ffffffffc0206e02:	60a2                	ld	ra,8(sp)
ffffffffc0206e04:	8522                	mv	a0,s0
ffffffffc0206e06:	6402                	ld	s0,0(sp)
ffffffffc0206e08:	0141                	addi	sp,sp,16
ffffffffc0206e0a:	8082                	ret
ffffffffc0206e0c:	545d                	li	s0,-9
ffffffffc0206e0e:	b7e1                	j	ffffffffc0206dd6 <do_kill+0x42>

ffffffffc0206e10 <proc_init>:
ffffffffc0206e10:	1101                	addi	sp,sp,-32
ffffffffc0206e12:	e426                	sd	s1,8(sp)
ffffffffc0206e14:	0008f797          	auipc	a5,0x8f
ffffffffc0206e18:	9ac78793          	addi	a5,a5,-1620 # ffffffffc02957c0 <proc_list>
ffffffffc0206e1c:	ec06                	sd	ra,24(sp)
ffffffffc0206e1e:	e822                	sd	s0,16(sp)
ffffffffc0206e20:	e04a                	sd	s2,0(sp)
ffffffffc0206e22:	0008b497          	auipc	s1,0x8b
ffffffffc0206e26:	99e48493          	addi	s1,s1,-1634 # ffffffffc02917c0 <hash_list>
ffffffffc0206e2a:	e79c                	sd	a5,8(a5)
ffffffffc0206e2c:	e39c                	sd	a5,0(a5)
ffffffffc0206e2e:	0008f717          	auipc	a4,0x8f
ffffffffc0206e32:	99270713          	addi	a4,a4,-1646 # ffffffffc02957c0 <proc_list>
ffffffffc0206e36:	87a6                	mv	a5,s1
ffffffffc0206e38:	e79c                	sd	a5,8(a5)
ffffffffc0206e3a:	e39c                	sd	a5,0(a5)
ffffffffc0206e3c:	07c1                	addi	a5,a5,16
ffffffffc0206e3e:	fef71de3          	bne	a4,a5,ffffffffc0206e38 <proc_init+0x28>
ffffffffc0206e42:	b93fe0ef          	jal	ra,ffffffffc02059d4 <alloc_proc>
ffffffffc0206e46:	00090917          	auipc	s2,0x90
ffffffffc0206e4a:	a8290913          	addi	s2,s2,-1406 # ffffffffc02968c8 <idleproc>
ffffffffc0206e4e:	00a93023          	sd	a0,0(s2)
ffffffffc0206e52:	842a                	mv	s0,a0
ffffffffc0206e54:	12050863          	beqz	a0,ffffffffc0206f84 <proc_init+0x174>
ffffffffc0206e58:	4789                	li	a5,2
ffffffffc0206e5a:	e11c                	sd	a5,0(a0)
ffffffffc0206e5c:	0000a797          	auipc	a5,0xa
ffffffffc0206e60:	1a478793          	addi	a5,a5,420 # ffffffffc0211000 <bootstack>
ffffffffc0206e64:	e91c                	sd	a5,16(a0)
ffffffffc0206e66:	4785                	li	a5,1
ffffffffc0206e68:	ed1c                	sd	a5,24(a0)
ffffffffc0206e6a:	b64fe0ef          	jal	ra,ffffffffc02051ce <files_create>
ffffffffc0206e6e:	14a43423          	sd	a0,328(s0)
ffffffffc0206e72:	0e050d63          	beqz	a0,ffffffffc0206f6c <proc_init+0x15c>
ffffffffc0206e76:	00093403          	ld	s0,0(s2)
ffffffffc0206e7a:	4641                	li	a2,16
ffffffffc0206e7c:	4581                	li	a1,0
ffffffffc0206e7e:	14843703          	ld	a4,328(s0)
ffffffffc0206e82:	0b440413          	addi	s0,s0,180
ffffffffc0206e86:	8522                	mv	a0,s0
ffffffffc0206e88:	4b1c                	lw	a5,16(a4)
ffffffffc0206e8a:	2785                	addiw	a5,a5,1
ffffffffc0206e8c:	cb1c                	sw	a5,16(a4)
ffffffffc0206e8e:	377040ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc0206e92:	463d                	li	a2,15
ffffffffc0206e94:	00007597          	auipc	a1,0x7
ffffffffc0206e98:	f3c58593          	addi	a1,a1,-196 # ffffffffc020ddd0 <CSWTCH.84+0x4d8>
ffffffffc0206e9c:	8522                	mv	a0,s0
ffffffffc0206e9e:	3b9040ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc0206ea2:	00090717          	auipc	a4,0x90
ffffffffc0206ea6:	a3670713          	addi	a4,a4,-1482 # ffffffffc02968d8 <nr_process>
ffffffffc0206eaa:	431c                	lw	a5,0(a4)
ffffffffc0206eac:	00093683          	ld	a3,0(s2)
ffffffffc0206eb0:	4601                	li	a2,0
ffffffffc0206eb2:	2785                	addiw	a5,a5,1
ffffffffc0206eb4:	4581                	li	a1,0
ffffffffc0206eb6:	fffff517          	auipc	a0,0xfffff
ffffffffc0206eba:	46a50513          	addi	a0,a0,1130 # ffffffffc0206320 <init_main>
ffffffffc0206ebe:	c31c                	sw	a5,0(a4)
ffffffffc0206ec0:	00090797          	auipc	a5,0x90
ffffffffc0206ec4:	a0d7b023          	sd	a3,-1536(a5) # ffffffffc02968c0 <current>
ffffffffc0206ec8:	8d4ff0ef          	jal	ra,ffffffffc0205f9c <kernel_thread>
ffffffffc0206ecc:	842a                	mv	s0,a0
ffffffffc0206ece:	08a05363          	blez	a0,ffffffffc0206f54 <proc_init+0x144>
ffffffffc0206ed2:	6789                	lui	a5,0x2
ffffffffc0206ed4:	fff5071b          	addiw	a4,a0,-1
ffffffffc0206ed8:	17f9                	addi	a5,a5,-2
ffffffffc0206eda:	2501                	sext.w	a0,a0
ffffffffc0206edc:	02e7e363          	bltu	a5,a4,ffffffffc0206f02 <proc_init+0xf2>
ffffffffc0206ee0:	45a9                	li	a1,10
ffffffffc0206ee2:	5c6040ef          	jal	ra,ffffffffc020b4a8 <hash32>
ffffffffc0206ee6:	02051793          	slli	a5,a0,0x20
ffffffffc0206eea:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0206eee:	96a6                	add	a3,a3,s1
ffffffffc0206ef0:	87b6                	mv	a5,a3
ffffffffc0206ef2:	a029                	j	ffffffffc0206efc <proc_init+0xec>
ffffffffc0206ef4:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_bin_swap_img_size-0x5dd4>
ffffffffc0206ef8:	04870b63          	beq	a4,s0,ffffffffc0206f4e <proc_init+0x13e>
ffffffffc0206efc:	679c                	ld	a5,8(a5)
ffffffffc0206efe:	fef69be3          	bne	a3,a5,ffffffffc0206ef4 <proc_init+0xe4>
ffffffffc0206f02:	4781                	li	a5,0
ffffffffc0206f04:	0b478493          	addi	s1,a5,180
ffffffffc0206f08:	4641                	li	a2,16
ffffffffc0206f0a:	4581                	li	a1,0
ffffffffc0206f0c:	00090417          	auipc	s0,0x90
ffffffffc0206f10:	9c440413          	addi	s0,s0,-1596 # ffffffffc02968d0 <initproc>
ffffffffc0206f14:	8526                	mv	a0,s1
ffffffffc0206f16:	e01c                	sd	a5,0(s0)
ffffffffc0206f18:	2ed040ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc0206f1c:	463d                	li	a2,15
ffffffffc0206f1e:	00007597          	auipc	a1,0x7
ffffffffc0206f22:	eda58593          	addi	a1,a1,-294 # ffffffffc020ddf8 <CSWTCH.84+0x500>
ffffffffc0206f26:	8526                	mv	a0,s1
ffffffffc0206f28:	32f040ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc0206f2c:	00093783          	ld	a5,0(s2)
ffffffffc0206f30:	c7d1                	beqz	a5,ffffffffc0206fbc <proc_init+0x1ac>
ffffffffc0206f32:	43dc                	lw	a5,4(a5)
ffffffffc0206f34:	e7c1                	bnez	a5,ffffffffc0206fbc <proc_init+0x1ac>
ffffffffc0206f36:	601c                	ld	a5,0(s0)
ffffffffc0206f38:	c3b5                	beqz	a5,ffffffffc0206f9c <proc_init+0x18c>
ffffffffc0206f3a:	43d8                	lw	a4,4(a5)
ffffffffc0206f3c:	4785                	li	a5,1
ffffffffc0206f3e:	04f71f63          	bne	a4,a5,ffffffffc0206f9c <proc_init+0x18c>
ffffffffc0206f42:	60e2                	ld	ra,24(sp)
ffffffffc0206f44:	6442                	ld	s0,16(sp)
ffffffffc0206f46:	64a2                	ld	s1,8(sp)
ffffffffc0206f48:	6902                	ld	s2,0(sp)
ffffffffc0206f4a:	6105                	addi	sp,sp,32
ffffffffc0206f4c:	8082                	ret
ffffffffc0206f4e:	f2878793          	addi	a5,a5,-216
ffffffffc0206f52:	bf4d                	j	ffffffffc0206f04 <proc_init+0xf4>
ffffffffc0206f54:	00007617          	auipc	a2,0x7
ffffffffc0206f58:	e8460613          	addi	a2,a2,-380 # ffffffffc020ddd8 <CSWTCH.84+0x4e0>
ffffffffc0206f5c:	51500593          	li	a1,1301
ffffffffc0206f60:	00007517          	auipc	a0,0x7
ffffffffc0206f64:	aa850513          	addi	a0,a0,-1368 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0206f68:	d36f90ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206f6c:	00007617          	auipc	a2,0x7
ffffffffc0206f70:	e3c60613          	addi	a2,a2,-452 # ffffffffc020dda8 <CSWTCH.84+0x4b0>
ffffffffc0206f74:	50900593          	li	a1,1289
ffffffffc0206f78:	00007517          	auipc	a0,0x7
ffffffffc0206f7c:	a9050513          	addi	a0,a0,-1392 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0206f80:	d1ef90ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206f84:	00007617          	auipc	a2,0x7
ffffffffc0206f88:	e0c60613          	addi	a2,a2,-500 # ffffffffc020dd90 <CSWTCH.84+0x498>
ffffffffc0206f8c:	4ff00593          	li	a1,1279
ffffffffc0206f90:	00007517          	auipc	a0,0x7
ffffffffc0206f94:	a7850513          	addi	a0,a0,-1416 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0206f98:	d06f90ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206f9c:	00007697          	auipc	a3,0x7
ffffffffc0206fa0:	e8c68693          	addi	a3,a3,-372 # ffffffffc020de28 <CSWTCH.84+0x530>
ffffffffc0206fa4:	00005617          	auipc	a2,0x5
ffffffffc0206fa8:	f4460613          	addi	a2,a2,-188 # ffffffffc020bee8 <commands+0x210>
ffffffffc0206fac:	51c00593          	li	a1,1308
ffffffffc0206fb0:	00007517          	auipc	a0,0x7
ffffffffc0206fb4:	a5850513          	addi	a0,a0,-1448 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0206fb8:	ce6f90ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0206fbc:	00007697          	auipc	a3,0x7
ffffffffc0206fc0:	e4468693          	addi	a3,a3,-444 # ffffffffc020de00 <CSWTCH.84+0x508>
ffffffffc0206fc4:	00005617          	auipc	a2,0x5
ffffffffc0206fc8:	f2460613          	addi	a2,a2,-220 # ffffffffc020bee8 <commands+0x210>
ffffffffc0206fcc:	51b00593          	li	a1,1307
ffffffffc0206fd0:	00007517          	auipc	a0,0x7
ffffffffc0206fd4:	a3850513          	addi	a0,a0,-1480 # ffffffffc020da08 <CSWTCH.84+0x110>
ffffffffc0206fd8:	cc6f90ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0206fdc <cpu_idle>:
ffffffffc0206fdc:	1141                	addi	sp,sp,-16
ffffffffc0206fde:	e022                	sd	s0,0(sp)
ffffffffc0206fe0:	e406                	sd	ra,8(sp)
ffffffffc0206fe2:	00090417          	auipc	s0,0x90
ffffffffc0206fe6:	8de40413          	addi	s0,s0,-1826 # ffffffffc02968c0 <current>
ffffffffc0206fea:	6018                	ld	a4,0(s0)
ffffffffc0206fec:	6f1c                	ld	a5,24(a4)
ffffffffc0206fee:	dffd                	beqz	a5,ffffffffc0206fec <cpu_idle+0x10>
ffffffffc0206ff0:	31a000ef          	jal	ra,ffffffffc020730a <schedule>
ffffffffc0206ff4:	bfdd                	j	ffffffffc0206fea <cpu_idle+0xe>

ffffffffc0206ff6 <lab6_set_priority>:
ffffffffc0206ff6:	1141                	addi	sp,sp,-16
ffffffffc0206ff8:	e022                	sd	s0,0(sp)
ffffffffc0206ffa:	85aa                	mv	a1,a0
ffffffffc0206ffc:	842a                	mv	s0,a0
ffffffffc0206ffe:	00007517          	auipc	a0,0x7
ffffffffc0207002:	e5250513          	addi	a0,a0,-430 # ffffffffc020de50 <CSWTCH.84+0x558>
ffffffffc0207006:	e406                	sd	ra,8(sp)
ffffffffc0207008:	99ef90ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc020700c:	00090797          	auipc	a5,0x90
ffffffffc0207010:	8b47b783          	ld	a5,-1868(a5) # ffffffffc02968c0 <current>
ffffffffc0207014:	e801                	bnez	s0,ffffffffc0207024 <lab6_set_priority+0x2e>
ffffffffc0207016:	60a2                	ld	ra,8(sp)
ffffffffc0207018:	6402                	ld	s0,0(sp)
ffffffffc020701a:	4705                	li	a4,1
ffffffffc020701c:	14e7a223          	sw	a4,324(a5)
ffffffffc0207020:	0141                	addi	sp,sp,16
ffffffffc0207022:	8082                	ret
ffffffffc0207024:	60a2                	ld	ra,8(sp)
ffffffffc0207026:	1487a223          	sw	s0,324(a5)
ffffffffc020702a:	6402                	ld	s0,0(sp)
ffffffffc020702c:	0141                	addi	sp,sp,16
ffffffffc020702e:	8082                	ret

ffffffffc0207030 <do_sleep>:
ffffffffc0207030:	c539                	beqz	a0,ffffffffc020707e <do_sleep+0x4e>
ffffffffc0207032:	7179                	addi	sp,sp,-48
ffffffffc0207034:	f022                	sd	s0,32(sp)
ffffffffc0207036:	f406                	sd	ra,40(sp)
ffffffffc0207038:	842a                	mv	s0,a0
ffffffffc020703a:	100027f3          	csrr	a5,sstatus
ffffffffc020703e:	8b89                	andi	a5,a5,2
ffffffffc0207040:	e3a9                	bnez	a5,ffffffffc0207082 <do_sleep+0x52>
ffffffffc0207042:	00090797          	auipc	a5,0x90
ffffffffc0207046:	87e7b783          	ld	a5,-1922(a5) # ffffffffc02968c0 <current>
ffffffffc020704a:	0818                	addi	a4,sp,16
ffffffffc020704c:	c02a                	sw	a0,0(sp)
ffffffffc020704e:	ec3a                	sd	a4,24(sp)
ffffffffc0207050:	e83a                	sd	a4,16(sp)
ffffffffc0207052:	e43e                	sd	a5,8(sp)
ffffffffc0207054:	4705                	li	a4,1
ffffffffc0207056:	c398                	sw	a4,0(a5)
ffffffffc0207058:	80000737          	lui	a4,0x80000
ffffffffc020705c:	840a                	mv	s0,sp
ffffffffc020705e:	0709                	addi	a4,a4,2
ffffffffc0207060:	0ee7a623          	sw	a4,236(a5)
ffffffffc0207064:	8522                	mv	a0,s0
ffffffffc0207066:	364000ef          	jal	ra,ffffffffc02073ca <add_timer>
ffffffffc020706a:	2a0000ef          	jal	ra,ffffffffc020730a <schedule>
ffffffffc020706e:	8522                	mv	a0,s0
ffffffffc0207070:	422000ef          	jal	ra,ffffffffc0207492 <del_timer>
ffffffffc0207074:	70a2                	ld	ra,40(sp)
ffffffffc0207076:	7402                	ld	s0,32(sp)
ffffffffc0207078:	4501                	li	a0,0
ffffffffc020707a:	6145                	addi	sp,sp,48
ffffffffc020707c:	8082                	ret
ffffffffc020707e:	4501                	li	a0,0
ffffffffc0207080:	8082                	ret
ffffffffc0207082:	bf1f90ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0207086:	00090797          	auipc	a5,0x90
ffffffffc020708a:	83a7b783          	ld	a5,-1990(a5) # ffffffffc02968c0 <current>
ffffffffc020708e:	0818                	addi	a4,sp,16
ffffffffc0207090:	c022                	sw	s0,0(sp)
ffffffffc0207092:	e43e                	sd	a5,8(sp)
ffffffffc0207094:	ec3a                	sd	a4,24(sp)
ffffffffc0207096:	e83a                	sd	a4,16(sp)
ffffffffc0207098:	4705                	li	a4,1
ffffffffc020709a:	c398                	sw	a4,0(a5)
ffffffffc020709c:	80000737          	lui	a4,0x80000
ffffffffc02070a0:	0709                	addi	a4,a4,2
ffffffffc02070a2:	840a                	mv	s0,sp
ffffffffc02070a4:	8522                	mv	a0,s0
ffffffffc02070a6:	0ee7a623          	sw	a4,236(a5)
ffffffffc02070aa:	320000ef          	jal	ra,ffffffffc02073ca <add_timer>
ffffffffc02070ae:	bbff90ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc02070b2:	bf65                	j	ffffffffc020706a <do_sleep+0x3a>

ffffffffc02070b4 <switch_to>:
ffffffffc02070b4:	00153023          	sd	ra,0(a0)
ffffffffc02070b8:	00253423          	sd	sp,8(a0)
ffffffffc02070bc:	e900                	sd	s0,16(a0)
ffffffffc02070be:	ed04                	sd	s1,24(a0)
ffffffffc02070c0:	03253023          	sd	s2,32(a0)
ffffffffc02070c4:	03353423          	sd	s3,40(a0)
ffffffffc02070c8:	03453823          	sd	s4,48(a0)
ffffffffc02070cc:	03553c23          	sd	s5,56(a0)
ffffffffc02070d0:	05653023          	sd	s6,64(a0)
ffffffffc02070d4:	05753423          	sd	s7,72(a0)
ffffffffc02070d8:	05853823          	sd	s8,80(a0)
ffffffffc02070dc:	05953c23          	sd	s9,88(a0)
ffffffffc02070e0:	07a53023          	sd	s10,96(a0)
ffffffffc02070e4:	07b53423          	sd	s11,104(a0)
ffffffffc02070e8:	0005b083          	ld	ra,0(a1)
ffffffffc02070ec:	0085b103          	ld	sp,8(a1)
ffffffffc02070f0:	6980                	ld	s0,16(a1)
ffffffffc02070f2:	6d84                	ld	s1,24(a1)
ffffffffc02070f4:	0205b903          	ld	s2,32(a1)
ffffffffc02070f8:	0285b983          	ld	s3,40(a1)
ffffffffc02070fc:	0305ba03          	ld	s4,48(a1)
ffffffffc0207100:	0385ba83          	ld	s5,56(a1)
ffffffffc0207104:	0405bb03          	ld	s6,64(a1)
ffffffffc0207108:	0485bb83          	ld	s7,72(a1)
ffffffffc020710c:	0505bc03          	ld	s8,80(a1)
ffffffffc0207110:	0585bc83          	ld	s9,88(a1)
ffffffffc0207114:	0605bd03          	ld	s10,96(a1)
ffffffffc0207118:	0685bd83          	ld	s11,104(a1)
ffffffffc020711c:	8082                	ret

ffffffffc020711e <RR_init>:
ffffffffc020711e:	e508                	sd	a0,8(a0)
ffffffffc0207120:	e108                	sd	a0,0(a0)
ffffffffc0207122:	00052823          	sw	zero,16(a0)
ffffffffc0207126:	8082                	ret

ffffffffc0207128 <RR_pick_next>:
ffffffffc0207128:	651c                	ld	a5,8(a0)
ffffffffc020712a:	00f50563          	beq	a0,a5,ffffffffc0207134 <RR_pick_next+0xc>
ffffffffc020712e:	ef078513          	addi	a0,a5,-272
ffffffffc0207132:	8082                	ret
ffffffffc0207134:	4501                	li	a0,0
ffffffffc0207136:	8082                	ret

ffffffffc0207138 <RR_proc_tick>:
ffffffffc0207138:	1205a783          	lw	a5,288(a1)
ffffffffc020713c:	00f05563          	blez	a5,ffffffffc0207146 <RR_proc_tick+0xe>
ffffffffc0207140:	37fd                	addiw	a5,a5,-1
ffffffffc0207142:	12f5a023          	sw	a5,288(a1)
ffffffffc0207146:	e399                	bnez	a5,ffffffffc020714c <RR_proc_tick+0x14>
ffffffffc0207148:	4785                	li	a5,1
ffffffffc020714a:	ed9c                	sd	a5,24(a1)
ffffffffc020714c:	8082                	ret

ffffffffc020714e <RR_dequeue>:
ffffffffc020714e:	1185b703          	ld	a4,280(a1)
ffffffffc0207152:	11058793          	addi	a5,a1,272
ffffffffc0207156:	02e78363          	beq	a5,a4,ffffffffc020717c <RR_dequeue+0x2e>
ffffffffc020715a:	1085b683          	ld	a3,264(a1)
ffffffffc020715e:	00a69f63          	bne	a3,a0,ffffffffc020717c <RR_dequeue+0x2e>
ffffffffc0207162:	1105b503          	ld	a0,272(a1)
ffffffffc0207166:	4a90                	lw	a2,16(a3)
ffffffffc0207168:	e518                	sd	a4,8(a0)
ffffffffc020716a:	e308                	sd	a0,0(a4)
ffffffffc020716c:	10f5bc23          	sd	a5,280(a1)
ffffffffc0207170:	10f5b823          	sd	a5,272(a1)
ffffffffc0207174:	fff6079b          	addiw	a5,a2,-1
ffffffffc0207178:	ca9c                	sw	a5,16(a3)
ffffffffc020717a:	8082                	ret
ffffffffc020717c:	1141                	addi	sp,sp,-16
ffffffffc020717e:	00007697          	auipc	a3,0x7
ffffffffc0207182:	cea68693          	addi	a3,a3,-790 # ffffffffc020de68 <CSWTCH.84+0x570>
ffffffffc0207186:	00005617          	auipc	a2,0x5
ffffffffc020718a:	d6260613          	addi	a2,a2,-670 # ffffffffc020bee8 <commands+0x210>
ffffffffc020718e:	03c00593          	li	a1,60
ffffffffc0207192:	00007517          	auipc	a0,0x7
ffffffffc0207196:	d0e50513          	addi	a0,a0,-754 # ffffffffc020dea0 <CSWTCH.84+0x5a8>
ffffffffc020719a:	e406                	sd	ra,8(sp)
ffffffffc020719c:	b02f90ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02071a0 <RR_enqueue>:
ffffffffc02071a0:	1185b703          	ld	a4,280(a1)
ffffffffc02071a4:	11058793          	addi	a5,a1,272
ffffffffc02071a8:	02e79d63          	bne	a5,a4,ffffffffc02071e2 <RR_enqueue+0x42>
ffffffffc02071ac:	6118                	ld	a4,0(a0)
ffffffffc02071ae:	1205a683          	lw	a3,288(a1)
ffffffffc02071b2:	e11c                	sd	a5,0(a0)
ffffffffc02071b4:	e71c                	sd	a5,8(a4)
ffffffffc02071b6:	10a5bc23          	sd	a0,280(a1)
ffffffffc02071ba:	10e5b823          	sd	a4,272(a1)
ffffffffc02071be:	495c                	lw	a5,20(a0)
ffffffffc02071c0:	ea89                	bnez	a3,ffffffffc02071d2 <RR_enqueue+0x32>
ffffffffc02071c2:	12f5a023          	sw	a5,288(a1)
ffffffffc02071c6:	491c                	lw	a5,16(a0)
ffffffffc02071c8:	10a5b423          	sd	a0,264(a1)
ffffffffc02071cc:	2785                	addiw	a5,a5,1
ffffffffc02071ce:	c91c                	sw	a5,16(a0)
ffffffffc02071d0:	8082                	ret
ffffffffc02071d2:	fed7c8e3          	blt	a5,a3,ffffffffc02071c2 <RR_enqueue+0x22>
ffffffffc02071d6:	491c                	lw	a5,16(a0)
ffffffffc02071d8:	10a5b423          	sd	a0,264(a1)
ffffffffc02071dc:	2785                	addiw	a5,a5,1
ffffffffc02071de:	c91c                	sw	a5,16(a0)
ffffffffc02071e0:	8082                	ret
ffffffffc02071e2:	1141                	addi	sp,sp,-16
ffffffffc02071e4:	00007697          	auipc	a3,0x7
ffffffffc02071e8:	cdc68693          	addi	a3,a3,-804 # ffffffffc020dec0 <CSWTCH.84+0x5c8>
ffffffffc02071ec:	00005617          	auipc	a2,0x5
ffffffffc02071f0:	cfc60613          	addi	a2,a2,-772 # ffffffffc020bee8 <commands+0x210>
ffffffffc02071f4:	02800593          	li	a1,40
ffffffffc02071f8:	00007517          	auipc	a0,0x7
ffffffffc02071fc:	ca850513          	addi	a0,a0,-856 # ffffffffc020dea0 <CSWTCH.84+0x5a8>
ffffffffc0207200:	e406                	sd	ra,8(sp)
ffffffffc0207202:	a9cf90ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0207206 <sched_init>:
ffffffffc0207206:	1141                	addi	sp,sp,-16
ffffffffc0207208:	0008a717          	auipc	a4,0x8a
ffffffffc020720c:	e1870713          	addi	a4,a4,-488 # ffffffffc0291020 <default_sched_class>
ffffffffc0207210:	e022                	sd	s0,0(sp)
ffffffffc0207212:	e406                	sd	ra,8(sp)
ffffffffc0207214:	0008e797          	auipc	a5,0x8e
ffffffffc0207218:	5dc78793          	addi	a5,a5,1500 # ffffffffc02957f0 <timer_list>
ffffffffc020721c:	6714                	ld	a3,8(a4)
ffffffffc020721e:	0008e517          	auipc	a0,0x8e
ffffffffc0207222:	5b250513          	addi	a0,a0,1458 # ffffffffc02957d0 <__rq>
ffffffffc0207226:	e79c                	sd	a5,8(a5)
ffffffffc0207228:	e39c                	sd	a5,0(a5)
ffffffffc020722a:	4795                	li	a5,5
ffffffffc020722c:	c95c                	sw	a5,20(a0)
ffffffffc020722e:	0008f417          	auipc	s0,0x8f
ffffffffc0207232:	6ba40413          	addi	s0,s0,1722 # ffffffffc02968e8 <sched_class>
ffffffffc0207236:	0008f797          	auipc	a5,0x8f
ffffffffc020723a:	6aa7b523          	sd	a0,1706(a5) # ffffffffc02968e0 <rq>
ffffffffc020723e:	e018                	sd	a4,0(s0)
ffffffffc0207240:	9682                	jalr	a3
ffffffffc0207242:	601c                	ld	a5,0(s0)
ffffffffc0207244:	6402                	ld	s0,0(sp)
ffffffffc0207246:	60a2                	ld	ra,8(sp)
ffffffffc0207248:	638c                	ld	a1,0(a5)
ffffffffc020724a:	00007517          	auipc	a0,0x7
ffffffffc020724e:	ca650513          	addi	a0,a0,-858 # ffffffffc020def0 <CSWTCH.84+0x5f8>
ffffffffc0207252:	0141                	addi	sp,sp,16
ffffffffc0207254:	f53f806f          	j	ffffffffc02001a6 <cprintf>

ffffffffc0207258 <wakeup_proc>:
ffffffffc0207258:	4118                	lw	a4,0(a0)
ffffffffc020725a:	1101                	addi	sp,sp,-32
ffffffffc020725c:	ec06                	sd	ra,24(sp)
ffffffffc020725e:	e822                	sd	s0,16(sp)
ffffffffc0207260:	e426                	sd	s1,8(sp)
ffffffffc0207262:	478d                	li	a5,3
ffffffffc0207264:	08f70363          	beq	a4,a5,ffffffffc02072ea <wakeup_proc+0x92>
ffffffffc0207268:	842a                	mv	s0,a0
ffffffffc020726a:	100027f3          	csrr	a5,sstatus
ffffffffc020726e:	8b89                	andi	a5,a5,2
ffffffffc0207270:	4481                	li	s1,0
ffffffffc0207272:	e7bd                	bnez	a5,ffffffffc02072e0 <wakeup_proc+0x88>
ffffffffc0207274:	4789                	li	a5,2
ffffffffc0207276:	04f70863          	beq	a4,a5,ffffffffc02072c6 <wakeup_proc+0x6e>
ffffffffc020727a:	c01c                	sw	a5,0(s0)
ffffffffc020727c:	0e042623          	sw	zero,236(s0)
ffffffffc0207280:	0008f797          	auipc	a5,0x8f
ffffffffc0207284:	6407b783          	ld	a5,1600(a5) # ffffffffc02968c0 <current>
ffffffffc0207288:	02878363          	beq	a5,s0,ffffffffc02072ae <wakeup_proc+0x56>
ffffffffc020728c:	0008f797          	auipc	a5,0x8f
ffffffffc0207290:	63c7b783          	ld	a5,1596(a5) # ffffffffc02968c8 <idleproc>
ffffffffc0207294:	00f40d63          	beq	s0,a5,ffffffffc02072ae <wakeup_proc+0x56>
ffffffffc0207298:	0008f797          	auipc	a5,0x8f
ffffffffc020729c:	6507b783          	ld	a5,1616(a5) # ffffffffc02968e8 <sched_class>
ffffffffc02072a0:	6b9c                	ld	a5,16(a5)
ffffffffc02072a2:	85a2                	mv	a1,s0
ffffffffc02072a4:	0008f517          	auipc	a0,0x8f
ffffffffc02072a8:	63c53503          	ld	a0,1596(a0) # ffffffffc02968e0 <rq>
ffffffffc02072ac:	9782                	jalr	a5
ffffffffc02072ae:	e491                	bnez	s1,ffffffffc02072ba <wakeup_proc+0x62>
ffffffffc02072b0:	60e2                	ld	ra,24(sp)
ffffffffc02072b2:	6442                	ld	s0,16(sp)
ffffffffc02072b4:	64a2                	ld	s1,8(sp)
ffffffffc02072b6:	6105                	addi	sp,sp,32
ffffffffc02072b8:	8082                	ret
ffffffffc02072ba:	6442                	ld	s0,16(sp)
ffffffffc02072bc:	60e2                	ld	ra,24(sp)
ffffffffc02072be:	64a2                	ld	s1,8(sp)
ffffffffc02072c0:	6105                	addi	sp,sp,32
ffffffffc02072c2:	9abf906f          	j	ffffffffc0200c6c <intr_enable>
ffffffffc02072c6:	00007617          	auipc	a2,0x7
ffffffffc02072ca:	c7a60613          	addi	a2,a2,-902 # ffffffffc020df40 <CSWTCH.84+0x648>
ffffffffc02072ce:	05200593          	li	a1,82
ffffffffc02072d2:	00007517          	auipc	a0,0x7
ffffffffc02072d6:	c5650513          	addi	a0,a0,-938 # ffffffffc020df28 <CSWTCH.84+0x630>
ffffffffc02072da:	a2cf90ef          	jal	ra,ffffffffc0200506 <__warn>
ffffffffc02072de:	bfc1                	j	ffffffffc02072ae <wakeup_proc+0x56>
ffffffffc02072e0:	993f90ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02072e4:	4018                	lw	a4,0(s0)
ffffffffc02072e6:	4485                	li	s1,1
ffffffffc02072e8:	b771                	j	ffffffffc0207274 <wakeup_proc+0x1c>
ffffffffc02072ea:	00007697          	auipc	a3,0x7
ffffffffc02072ee:	c1e68693          	addi	a3,a3,-994 # ffffffffc020df08 <CSWTCH.84+0x610>
ffffffffc02072f2:	00005617          	auipc	a2,0x5
ffffffffc02072f6:	bf660613          	addi	a2,a2,-1034 # ffffffffc020bee8 <commands+0x210>
ffffffffc02072fa:	04300593          	li	a1,67
ffffffffc02072fe:	00007517          	auipc	a0,0x7
ffffffffc0207302:	c2a50513          	addi	a0,a0,-982 # ffffffffc020df28 <CSWTCH.84+0x630>
ffffffffc0207306:	998f90ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020730a <schedule>:
ffffffffc020730a:	7179                	addi	sp,sp,-48
ffffffffc020730c:	f406                	sd	ra,40(sp)
ffffffffc020730e:	f022                	sd	s0,32(sp)
ffffffffc0207310:	ec26                	sd	s1,24(sp)
ffffffffc0207312:	e84a                	sd	s2,16(sp)
ffffffffc0207314:	e44e                	sd	s3,8(sp)
ffffffffc0207316:	e052                	sd	s4,0(sp)
ffffffffc0207318:	100027f3          	csrr	a5,sstatus
ffffffffc020731c:	8b89                	andi	a5,a5,2
ffffffffc020731e:	4a01                	li	s4,0
ffffffffc0207320:	e3cd                	bnez	a5,ffffffffc02073c2 <schedule+0xb8>
ffffffffc0207322:	0008f497          	auipc	s1,0x8f
ffffffffc0207326:	59e48493          	addi	s1,s1,1438 # ffffffffc02968c0 <current>
ffffffffc020732a:	608c                	ld	a1,0(s1)
ffffffffc020732c:	0008f997          	auipc	s3,0x8f
ffffffffc0207330:	5bc98993          	addi	s3,s3,1468 # ffffffffc02968e8 <sched_class>
ffffffffc0207334:	0008f917          	auipc	s2,0x8f
ffffffffc0207338:	5ac90913          	addi	s2,s2,1452 # ffffffffc02968e0 <rq>
ffffffffc020733c:	4194                	lw	a3,0(a1)
ffffffffc020733e:	0005bc23          	sd	zero,24(a1)
ffffffffc0207342:	4709                	li	a4,2
ffffffffc0207344:	0009b783          	ld	a5,0(s3)
ffffffffc0207348:	00093503          	ld	a0,0(s2)
ffffffffc020734c:	04e68e63          	beq	a3,a4,ffffffffc02073a8 <schedule+0x9e>
ffffffffc0207350:	739c                	ld	a5,32(a5)
ffffffffc0207352:	9782                	jalr	a5
ffffffffc0207354:	842a                	mv	s0,a0
ffffffffc0207356:	c521                	beqz	a0,ffffffffc020739e <schedule+0x94>
ffffffffc0207358:	0009b783          	ld	a5,0(s3)
ffffffffc020735c:	00093503          	ld	a0,0(s2)
ffffffffc0207360:	85a2                	mv	a1,s0
ffffffffc0207362:	6f9c                	ld	a5,24(a5)
ffffffffc0207364:	9782                	jalr	a5
ffffffffc0207366:	441c                	lw	a5,8(s0)
ffffffffc0207368:	6098                	ld	a4,0(s1)
ffffffffc020736a:	2785                	addiw	a5,a5,1
ffffffffc020736c:	c41c                	sw	a5,8(s0)
ffffffffc020736e:	00870563          	beq	a4,s0,ffffffffc0207378 <schedule+0x6e>
ffffffffc0207372:	8522                	mv	a0,s0
ffffffffc0207374:	f7efe0ef          	jal	ra,ffffffffc0205af2 <proc_run>
ffffffffc0207378:	000a1a63          	bnez	s4,ffffffffc020738c <schedule+0x82>
ffffffffc020737c:	70a2                	ld	ra,40(sp)
ffffffffc020737e:	7402                	ld	s0,32(sp)
ffffffffc0207380:	64e2                	ld	s1,24(sp)
ffffffffc0207382:	6942                	ld	s2,16(sp)
ffffffffc0207384:	69a2                	ld	s3,8(sp)
ffffffffc0207386:	6a02                	ld	s4,0(sp)
ffffffffc0207388:	6145                	addi	sp,sp,48
ffffffffc020738a:	8082                	ret
ffffffffc020738c:	7402                	ld	s0,32(sp)
ffffffffc020738e:	70a2                	ld	ra,40(sp)
ffffffffc0207390:	64e2                	ld	s1,24(sp)
ffffffffc0207392:	6942                	ld	s2,16(sp)
ffffffffc0207394:	69a2                	ld	s3,8(sp)
ffffffffc0207396:	6a02                	ld	s4,0(sp)
ffffffffc0207398:	6145                	addi	sp,sp,48
ffffffffc020739a:	8d3f906f          	j	ffffffffc0200c6c <intr_enable>
ffffffffc020739e:	0008f417          	auipc	s0,0x8f
ffffffffc02073a2:	52a43403          	ld	s0,1322(s0) # ffffffffc02968c8 <idleproc>
ffffffffc02073a6:	b7c1                	j	ffffffffc0207366 <schedule+0x5c>
ffffffffc02073a8:	0008f717          	auipc	a4,0x8f
ffffffffc02073ac:	52073703          	ld	a4,1312(a4) # ffffffffc02968c8 <idleproc>
ffffffffc02073b0:	fae580e3          	beq	a1,a4,ffffffffc0207350 <schedule+0x46>
ffffffffc02073b4:	6b9c                	ld	a5,16(a5)
ffffffffc02073b6:	9782                	jalr	a5
ffffffffc02073b8:	0009b783          	ld	a5,0(s3)
ffffffffc02073bc:	00093503          	ld	a0,0(s2)
ffffffffc02073c0:	bf41                	j	ffffffffc0207350 <schedule+0x46>
ffffffffc02073c2:	8b1f90ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02073c6:	4a05                	li	s4,1
ffffffffc02073c8:	bfa9                	j	ffffffffc0207322 <schedule+0x18>

ffffffffc02073ca <add_timer>:
ffffffffc02073ca:	1141                	addi	sp,sp,-16
ffffffffc02073cc:	e022                	sd	s0,0(sp)
ffffffffc02073ce:	e406                	sd	ra,8(sp)
ffffffffc02073d0:	842a                	mv	s0,a0
ffffffffc02073d2:	100027f3          	csrr	a5,sstatus
ffffffffc02073d6:	8b89                	andi	a5,a5,2
ffffffffc02073d8:	4501                	li	a0,0
ffffffffc02073da:	eba5                	bnez	a5,ffffffffc020744a <add_timer+0x80>
ffffffffc02073dc:	401c                	lw	a5,0(s0)
ffffffffc02073de:	cbb5                	beqz	a5,ffffffffc0207452 <add_timer+0x88>
ffffffffc02073e0:	6418                	ld	a4,8(s0)
ffffffffc02073e2:	cb25                	beqz	a4,ffffffffc0207452 <add_timer+0x88>
ffffffffc02073e4:	6c18                	ld	a4,24(s0)
ffffffffc02073e6:	01040593          	addi	a1,s0,16
ffffffffc02073ea:	08e59463          	bne	a1,a4,ffffffffc0207472 <add_timer+0xa8>
ffffffffc02073ee:	0008e617          	auipc	a2,0x8e
ffffffffc02073f2:	40260613          	addi	a2,a2,1026 # ffffffffc02957f0 <timer_list>
ffffffffc02073f6:	6618                	ld	a4,8(a2)
ffffffffc02073f8:	00c71863          	bne	a4,a2,ffffffffc0207408 <add_timer+0x3e>
ffffffffc02073fc:	a80d                	j	ffffffffc020742e <add_timer+0x64>
ffffffffc02073fe:	6718                	ld	a4,8(a4)
ffffffffc0207400:	9f95                	subw	a5,a5,a3
ffffffffc0207402:	c01c                	sw	a5,0(s0)
ffffffffc0207404:	02c70563          	beq	a4,a2,ffffffffc020742e <add_timer+0x64>
ffffffffc0207408:	ff072683          	lw	a3,-16(a4)
ffffffffc020740c:	fed7f9e3          	bgeu	a5,a3,ffffffffc02073fe <add_timer+0x34>
ffffffffc0207410:	40f687bb          	subw	a5,a3,a5
ffffffffc0207414:	fef72823          	sw	a5,-16(a4)
ffffffffc0207418:	631c                	ld	a5,0(a4)
ffffffffc020741a:	e30c                	sd	a1,0(a4)
ffffffffc020741c:	e78c                	sd	a1,8(a5)
ffffffffc020741e:	ec18                	sd	a4,24(s0)
ffffffffc0207420:	e81c                	sd	a5,16(s0)
ffffffffc0207422:	c105                	beqz	a0,ffffffffc0207442 <add_timer+0x78>
ffffffffc0207424:	6402                	ld	s0,0(sp)
ffffffffc0207426:	60a2                	ld	ra,8(sp)
ffffffffc0207428:	0141                	addi	sp,sp,16
ffffffffc020742a:	843f906f          	j	ffffffffc0200c6c <intr_enable>
ffffffffc020742e:	0008e717          	auipc	a4,0x8e
ffffffffc0207432:	3c270713          	addi	a4,a4,962 # ffffffffc02957f0 <timer_list>
ffffffffc0207436:	631c                	ld	a5,0(a4)
ffffffffc0207438:	e30c                	sd	a1,0(a4)
ffffffffc020743a:	e78c                	sd	a1,8(a5)
ffffffffc020743c:	ec18                	sd	a4,24(s0)
ffffffffc020743e:	e81c                	sd	a5,16(s0)
ffffffffc0207440:	f175                	bnez	a0,ffffffffc0207424 <add_timer+0x5a>
ffffffffc0207442:	60a2                	ld	ra,8(sp)
ffffffffc0207444:	6402                	ld	s0,0(sp)
ffffffffc0207446:	0141                	addi	sp,sp,16
ffffffffc0207448:	8082                	ret
ffffffffc020744a:	829f90ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc020744e:	4505                	li	a0,1
ffffffffc0207450:	b771                	j	ffffffffc02073dc <add_timer+0x12>
ffffffffc0207452:	00007697          	auipc	a3,0x7
ffffffffc0207456:	b0e68693          	addi	a3,a3,-1266 # ffffffffc020df60 <CSWTCH.84+0x668>
ffffffffc020745a:	00005617          	auipc	a2,0x5
ffffffffc020745e:	a8e60613          	addi	a2,a2,-1394 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207462:	07a00593          	li	a1,122
ffffffffc0207466:	00007517          	auipc	a0,0x7
ffffffffc020746a:	ac250513          	addi	a0,a0,-1342 # ffffffffc020df28 <CSWTCH.84+0x630>
ffffffffc020746e:	830f90ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0207472:	00007697          	auipc	a3,0x7
ffffffffc0207476:	b1e68693          	addi	a3,a3,-1250 # ffffffffc020df90 <CSWTCH.84+0x698>
ffffffffc020747a:	00005617          	auipc	a2,0x5
ffffffffc020747e:	a6e60613          	addi	a2,a2,-1426 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207482:	07b00593          	li	a1,123
ffffffffc0207486:	00007517          	auipc	a0,0x7
ffffffffc020748a:	aa250513          	addi	a0,a0,-1374 # ffffffffc020df28 <CSWTCH.84+0x630>
ffffffffc020748e:	810f90ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0207492 <del_timer>:
ffffffffc0207492:	1101                	addi	sp,sp,-32
ffffffffc0207494:	e822                	sd	s0,16(sp)
ffffffffc0207496:	ec06                	sd	ra,24(sp)
ffffffffc0207498:	e426                	sd	s1,8(sp)
ffffffffc020749a:	842a                	mv	s0,a0
ffffffffc020749c:	100027f3          	csrr	a5,sstatus
ffffffffc02074a0:	8b89                	andi	a5,a5,2
ffffffffc02074a2:	01050493          	addi	s1,a0,16
ffffffffc02074a6:	eb9d                	bnez	a5,ffffffffc02074dc <del_timer+0x4a>
ffffffffc02074a8:	6d1c                	ld	a5,24(a0)
ffffffffc02074aa:	02978463          	beq	a5,s1,ffffffffc02074d2 <del_timer+0x40>
ffffffffc02074ae:	4114                	lw	a3,0(a0)
ffffffffc02074b0:	6918                	ld	a4,16(a0)
ffffffffc02074b2:	ce81                	beqz	a3,ffffffffc02074ca <del_timer+0x38>
ffffffffc02074b4:	0008e617          	auipc	a2,0x8e
ffffffffc02074b8:	33c60613          	addi	a2,a2,828 # ffffffffc02957f0 <timer_list>
ffffffffc02074bc:	00c78763          	beq	a5,a2,ffffffffc02074ca <del_timer+0x38>
ffffffffc02074c0:	ff07a603          	lw	a2,-16(a5)
ffffffffc02074c4:	9eb1                	addw	a3,a3,a2
ffffffffc02074c6:	fed7a823          	sw	a3,-16(a5)
ffffffffc02074ca:	e71c                	sd	a5,8(a4)
ffffffffc02074cc:	e398                	sd	a4,0(a5)
ffffffffc02074ce:	ec04                	sd	s1,24(s0)
ffffffffc02074d0:	e804                	sd	s1,16(s0)
ffffffffc02074d2:	60e2                	ld	ra,24(sp)
ffffffffc02074d4:	6442                	ld	s0,16(sp)
ffffffffc02074d6:	64a2                	ld	s1,8(sp)
ffffffffc02074d8:	6105                	addi	sp,sp,32
ffffffffc02074da:	8082                	ret
ffffffffc02074dc:	f96f90ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc02074e0:	6c1c                	ld	a5,24(s0)
ffffffffc02074e2:	02978463          	beq	a5,s1,ffffffffc020750a <del_timer+0x78>
ffffffffc02074e6:	4014                	lw	a3,0(s0)
ffffffffc02074e8:	6818                	ld	a4,16(s0)
ffffffffc02074ea:	ce81                	beqz	a3,ffffffffc0207502 <del_timer+0x70>
ffffffffc02074ec:	0008e617          	auipc	a2,0x8e
ffffffffc02074f0:	30460613          	addi	a2,a2,772 # ffffffffc02957f0 <timer_list>
ffffffffc02074f4:	00c78763          	beq	a5,a2,ffffffffc0207502 <del_timer+0x70>
ffffffffc02074f8:	ff07a603          	lw	a2,-16(a5)
ffffffffc02074fc:	9eb1                	addw	a3,a3,a2
ffffffffc02074fe:	fed7a823          	sw	a3,-16(a5)
ffffffffc0207502:	e71c                	sd	a5,8(a4)
ffffffffc0207504:	e398                	sd	a4,0(a5)
ffffffffc0207506:	ec04                	sd	s1,24(s0)
ffffffffc0207508:	e804                	sd	s1,16(s0)
ffffffffc020750a:	6442                	ld	s0,16(sp)
ffffffffc020750c:	60e2                	ld	ra,24(sp)
ffffffffc020750e:	64a2                	ld	s1,8(sp)
ffffffffc0207510:	6105                	addi	sp,sp,32
ffffffffc0207512:	f5af906f          	j	ffffffffc0200c6c <intr_enable>

ffffffffc0207516 <run_timer_list>:
ffffffffc0207516:	7139                	addi	sp,sp,-64
ffffffffc0207518:	fc06                	sd	ra,56(sp)
ffffffffc020751a:	f822                	sd	s0,48(sp)
ffffffffc020751c:	f426                	sd	s1,40(sp)
ffffffffc020751e:	f04a                	sd	s2,32(sp)
ffffffffc0207520:	ec4e                	sd	s3,24(sp)
ffffffffc0207522:	e852                	sd	s4,16(sp)
ffffffffc0207524:	e456                	sd	s5,8(sp)
ffffffffc0207526:	e05a                	sd	s6,0(sp)
ffffffffc0207528:	100027f3          	csrr	a5,sstatus
ffffffffc020752c:	8b89                	andi	a5,a5,2
ffffffffc020752e:	4b01                	li	s6,0
ffffffffc0207530:	efe9                	bnez	a5,ffffffffc020760a <run_timer_list+0xf4>
ffffffffc0207532:	0008e997          	auipc	s3,0x8e
ffffffffc0207536:	2be98993          	addi	s3,s3,702 # ffffffffc02957f0 <timer_list>
ffffffffc020753a:	0089b403          	ld	s0,8(s3)
ffffffffc020753e:	07340a63          	beq	s0,s3,ffffffffc02075b2 <run_timer_list+0x9c>
ffffffffc0207542:	ff042783          	lw	a5,-16(s0)
ffffffffc0207546:	ff040913          	addi	s2,s0,-16
ffffffffc020754a:	0e078763          	beqz	a5,ffffffffc0207638 <run_timer_list+0x122>
ffffffffc020754e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0207552:	fee42823          	sw	a4,-16(s0)
ffffffffc0207556:	ef31                	bnez	a4,ffffffffc02075b2 <run_timer_list+0x9c>
ffffffffc0207558:	00007a97          	auipc	s5,0x7
ffffffffc020755c:	aa0a8a93          	addi	s5,s5,-1376 # ffffffffc020dff8 <CSWTCH.84+0x700>
ffffffffc0207560:	00007a17          	auipc	s4,0x7
ffffffffc0207564:	9c8a0a13          	addi	s4,s4,-1592 # ffffffffc020df28 <CSWTCH.84+0x630>
ffffffffc0207568:	a005                	j	ffffffffc0207588 <run_timer_list+0x72>
ffffffffc020756a:	0a07d763          	bgez	a5,ffffffffc0207618 <run_timer_list+0x102>
ffffffffc020756e:	8526                	mv	a0,s1
ffffffffc0207570:	ce9ff0ef          	jal	ra,ffffffffc0207258 <wakeup_proc>
ffffffffc0207574:	854a                	mv	a0,s2
ffffffffc0207576:	f1dff0ef          	jal	ra,ffffffffc0207492 <del_timer>
ffffffffc020757a:	03340c63          	beq	s0,s3,ffffffffc02075b2 <run_timer_list+0x9c>
ffffffffc020757e:	ff042783          	lw	a5,-16(s0)
ffffffffc0207582:	ff040913          	addi	s2,s0,-16
ffffffffc0207586:	e795                	bnez	a5,ffffffffc02075b2 <run_timer_list+0x9c>
ffffffffc0207588:	00893483          	ld	s1,8(s2)
ffffffffc020758c:	6400                	ld	s0,8(s0)
ffffffffc020758e:	0ec4a783          	lw	a5,236(s1)
ffffffffc0207592:	ffe1                	bnez	a5,ffffffffc020756a <run_timer_list+0x54>
ffffffffc0207594:	40d4                	lw	a3,4(s1)
ffffffffc0207596:	8656                	mv	a2,s5
ffffffffc0207598:	0ba00593          	li	a1,186
ffffffffc020759c:	8552                	mv	a0,s4
ffffffffc020759e:	f69f80ef          	jal	ra,ffffffffc0200506 <__warn>
ffffffffc02075a2:	8526                	mv	a0,s1
ffffffffc02075a4:	cb5ff0ef          	jal	ra,ffffffffc0207258 <wakeup_proc>
ffffffffc02075a8:	854a                	mv	a0,s2
ffffffffc02075aa:	ee9ff0ef          	jal	ra,ffffffffc0207492 <del_timer>
ffffffffc02075ae:	fd3418e3          	bne	s0,s3,ffffffffc020757e <run_timer_list+0x68>
ffffffffc02075b2:	0008f597          	auipc	a1,0x8f
ffffffffc02075b6:	30e5b583          	ld	a1,782(a1) # ffffffffc02968c0 <current>
ffffffffc02075ba:	c18d                	beqz	a1,ffffffffc02075dc <run_timer_list+0xc6>
ffffffffc02075bc:	0008f797          	auipc	a5,0x8f
ffffffffc02075c0:	30c7b783          	ld	a5,780(a5) # ffffffffc02968c8 <idleproc>
ffffffffc02075c4:	04f58763          	beq	a1,a5,ffffffffc0207612 <run_timer_list+0xfc>
ffffffffc02075c8:	0008f797          	auipc	a5,0x8f
ffffffffc02075cc:	3207b783          	ld	a5,800(a5) # ffffffffc02968e8 <sched_class>
ffffffffc02075d0:	779c                	ld	a5,40(a5)
ffffffffc02075d2:	0008f517          	auipc	a0,0x8f
ffffffffc02075d6:	30e53503          	ld	a0,782(a0) # ffffffffc02968e0 <rq>
ffffffffc02075da:	9782                	jalr	a5
ffffffffc02075dc:	000b1c63          	bnez	s6,ffffffffc02075f4 <run_timer_list+0xde>
ffffffffc02075e0:	70e2                	ld	ra,56(sp)
ffffffffc02075e2:	7442                	ld	s0,48(sp)
ffffffffc02075e4:	74a2                	ld	s1,40(sp)
ffffffffc02075e6:	7902                	ld	s2,32(sp)
ffffffffc02075e8:	69e2                	ld	s3,24(sp)
ffffffffc02075ea:	6a42                	ld	s4,16(sp)
ffffffffc02075ec:	6aa2                	ld	s5,8(sp)
ffffffffc02075ee:	6b02                	ld	s6,0(sp)
ffffffffc02075f0:	6121                	addi	sp,sp,64
ffffffffc02075f2:	8082                	ret
ffffffffc02075f4:	7442                	ld	s0,48(sp)
ffffffffc02075f6:	70e2                	ld	ra,56(sp)
ffffffffc02075f8:	74a2                	ld	s1,40(sp)
ffffffffc02075fa:	7902                	ld	s2,32(sp)
ffffffffc02075fc:	69e2                	ld	s3,24(sp)
ffffffffc02075fe:	6a42                	ld	s4,16(sp)
ffffffffc0207600:	6aa2                	ld	s5,8(sp)
ffffffffc0207602:	6b02                	ld	s6,0(sp)
ffffffffc0207604:	6121                	addi	sp,sp,64
ffffffffc0207606:	e66f906f          	j	ffffffffc0200c6c <intr_enable>
ffffffffc020760a:	e68f90ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc020760e:	4b05                	li	s6,1
ffffffffc0207610:	b70d                	j	ffffffffc0207532 <run_timer_list+0x1c>
ffffffffc0207612:	4785                	li	a5,1
ffffffffc0207614:	ed9c                	sd	a5,24(a1)
ffffffffc0207616:	b7d9                	j	ffffffffc02075dc <run_timer_list+0xc6>
ffffffffc0207618:	00007697          	auipc	a3,0x7
ffffffffc020761c:	9b868693          	addi	a3,a3,-1608 # ffffffffc020dfd0 <CSWTCH.84+0x6d8>
ffffffffc0207620:	00005617          	auipc	a2,0x5
ffffffffc0207624:	8c860613          	addi	a2,a2,-1848 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207628:	0b600593          	li	a1,182
ffffffffc020762c:	00007517          	auipc	a0,0x7
ffffffffc0207630:	8fc50513          	addi	a0,a0,-1796 # ffffffffc020df28 <CSWTCH.84+0x630>
ffffffffc0207634:	e6bf80ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0207638:	00007697          	auipc	a3,0x7
ffffffffc020763c:	98068693          	addi	a3,a3,-1664 # ffffffffc020dfb8 <CSWTCH.84+0x6c0>
ffffffffc0207640:	00005617          	auipc	a2,0x5
ffffffffc0207644:	8a860613          	addi	a2,a2,-1880 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207648:	0ae00593          	li	a1,174
ffffffffc020764c:	00007517          	auipc	a0,0x7
ffffffffc0207650:	8dc50513          	addi	a0,a0,-1828 # ffffffffc020df28 <CSWTCH.84+0x630>
ffffffffc0207654:	e4bf80ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0207658 <sys_getpid>:
ffffffffc0207658:	0008f797          	auipc	a5,0x8f
ffffffffc020765c:	2687b783          	ld	a5,616(a5) # ffffffffc02968c0 <current>
ffffffffc0207660:	43c8                	lw	a0,4(a5)
ffffffffc0207662:	8082                	ret

ffffffffc0207664 <sys_pgdir>:
ffffffffc0207664:	4501                	li	a0,0
ffffffffc0207666:	8082                	ret

ffffffffc0207668 <sys_gettime>:
ffffffffc0207668:	0008f797          	auipc	a5,0x8f
ffffffffc020766c:	2087b783          	ld	a5,520(a5) # ffffffffc0296870 <ticks>
ffffffffc0207670:	0027951b          	slliw	a0,a5,0x2
ffffffffc0207674:	9d3d                	addw	a0,a0,a5
ffffffffc0207676:	0015151b          	slliw	a0,a0,0x1
ffffffffc020767a:	8082                	ret

ffffffffc020767c <sys_lab6_set_priority>:
ffffffffc020767c:	4108                	lw	a0,0(a0)
ffffffffc020767e:	1141                	addi	sp,sp,-16
ffffffffc0207680:	e406                	sd	ra,8(sp)
ffffffffc0207682:	975ff0ef          	jal	ra,ffffffffc0206ff6 <lab6_set_priority>
ffffffffc0207686:	60a2                	ld	ra,8(sp)
ffffffffc0207688:	4501                	li	a0,0
ffffffffc020768a:	0141                	addi	sp,sp,16
ffffffffc020768c:	8082                	ret

ffffffffc020768e <sys_dup>:
ffffffffc020768e:	450c                	lw	a1,8(a0)
ffffffffc0207690:	4108                	lw	a0,0(a0)
ffffffffc0207692:	b36fe06f          	j	ffffffffc02059c8 <sysfile_dup>

ffffffffc0207696 <sys_getdirentry>:
ffffffffc0207696:	650c                	ld	a1,8(a0)
ffffffffc0207698:	4108                	lw	a0,0(a0)
ffffffffc020769a:	a3efe06f          	j	ffffffffc02058d8 <sysfile_getdirentry>

ffffffffc020769e <sys_getcwd>:
ffffffffc020769e:	650c                	ld	a1,8(a0)
ffffffffc02076a0:	6108                	ld	a0,0(a0)
ffffffffc02076a2:	992fe06f          	j	ffffffffc0205834 <sysfile_getcwd>

ffffffffc02076a6 <sys_fsync>:
ffffffffc02076a6:	4108                	lw	a0,0(a0)
ffffffffc02076a8:	988fe06f          	j	ffffffffc0205830 <sysfile_fsync>

ffffffffc02076ac <sys_fstat>:
ffffffffc02076ac:	650c                	ld	a1,8(a0)
ffffffffc02076ae:	4108                	lw	a0,0(a0)
ffffffffc02076b0:	8e0fe06f          	j	ffffffffc0205790 <sysfile_fstat>

ffffffffc02076b4 <sys_seek>:
ffffffffc02076b4:	4910                	lw	a2,16(a0)
ffffffffc02076b6:	650c                	ld	a1,8(a0)
ffffffffc02076b8:	4108                	lw	a0,0(a0)
ffffffffc02076ba:	8d2fe06f          	j	ffffffffc020578c <sysfile_seek>

ffffffffc02076be <sys_write>:
ffffffffc02076be:	6910                	ld	a2,16(a0)
ffffffffc02076c0:	650c                	ld	a1,8(a0)
ffffffffc02076c2:	4108                	lw	a0,0(a0)
ffffffffc02076c4:	faffd06f          	j	ffffffffc0205672 <sysfile_write>

ffffffffc02076c8 <sys_read>:
ffffffffc02076c8:	6910                	ld	a2,16(a0)
ffffffffc02076ca:	650c                	ld	a1,8(a0)
ffffffffc02076cc:	4108                	lw	a0,0(a0)
ffffffffc02076ce:	e91fd06f          	j	ffffffffc020555e <sysfile_read>

ffffffffc02076d2 <sys_close>:
ffffffffc02076d2:	4108                	lw	a0,0(a0)
ffffffffc02076d4:	e87fd06f          	j	ffffffffc020555a <sysfile_close>

ffffffffc02076d8 <sys_open>:
ffffffffc02076d8:	450c                	lw	a1,8(a0)
ffffffffc02076da:	6108                	ld	a0,0(a0)
ffffffffc02076dc:	e4bfd06f          	j	ffffffffc0205526 <sysfile_open>

ffffffffc02076e0 <sys_putc>:
ffffffffc02076e0:	4108                	lw	a0,0(a0)
ffffffffc02076e2:	1141                	addi	sp,sp,-16
ffffffffc02076e4:	e406                	sd	ra,8(sp)
ffffffffc02076e6:	afdf80ef          	jal	ra,ffffffffc02001e2 <cputchar>
ffffffffc02076ea:	60a2                	ld	ra,8(sp)
ffffffffc02076ec:	4501                	li	a0,0
ffffffffc02076ee:	0141                	addi	sp,sp,16
ffffffffc02076f0:	8082                	ret

ffffffffc02076f2 <sys_kill>:
ffffffffc02076f2:	4108                	lw	a0,0(a0)
ffffffffc02076f4:	ea0ff06f          	j	ffffffffc0206d94 <do_kill>

ffffffffc02076f8 <sys_sleep>:
ffffffffc02076f8:	4108                	lw	a0,0(a0)
ffffffffc02076fa:	937ff06f          	j	ffffffffc0207030 <do_sleep>

ffffffffc02076fe <sys_yield>:
ffffffffc02076fe:	e48ff06f          	j	ffffffffc0206d46 <do_yield>

ffffffffc0207702 <sys_exec>:
ffffffffc0207702:	6910                	ld	a2,16(a0)
ffffffffc0207704:	450c                	lw	a1,8(a0)
ffffffffc0207706:	6108                	ld	a0,0(a0)
ffffffffc0207708:	d69fe06f          	j	ffffffffc0206470 <do_execve>

ffffffffc020770c <sys_wait>:
ffffffffc020770c:	650c                	ld	a1,8(a0)
ffffffffc020770e:	4108                	lw	a0,0(a0)
ffffffffc0207710:	e46ff06f          	j	ffffffffc0206d56 <do_wait>

ffffffffc0207714 <sys_fork>:
ffffffffc0207714:	0008f797          	auipc	a5,0x8f
ffffffffc0207718:	1ac7b783          	ld	a5,428(a5) # ffffffffc02968c0 <current>
ffffffffc020771c:	73d0                	ld	a2,160(a5)
ffffffffc020771e:	4501                	li	a0,0
ffffffffc0207720:	6a0c                	ld	a1,16(a2)
ffffffffc0207722:	c40fe06f          	j	ffffffffc0205b62 <do_fork>

ffffffffc0207726 <sys_exit>:
ffffffffc0207726:	4108                	lw	a0,0(a0)
ffffffffc0207728:	8c5fe06f          	j	ffffffffc0205fec <do_exit>

ffffffffc020772c <syscall>:
ffffffffc020772c:	715d                	addi	sp,sp,-80
ffffffffc020772e:	fc26                	sd	s1,56(sp)
ffffffffc0207730:	0008f497          	auipc	s1,0x8f
ffffffffc0207734:	19048493          	addi	s1,s1,400 # ffffffffc02968c0 <current>
ffffffffc0207738:	6098                	ld	a4,0(s1)
ffffffffc020773a:	e0a2                	sd	s0,64(sp)
ffffffffc020773c:	f84a                	sd	s2,48(sp)
ffffffffc020773e:	7340                	ld	s0,160(a4)
ffffffffc0207740:	e486                	sd	ra,72(sp)
ffffffffc0207742:	0ff00793          	li	a5,255
ffffffffc0207746:	05042903          	lw	s2,80(s0)
ffffffffc020774a:	0327ee63          	bltu	a5,s2,ffffffffc0207786 <syscall+0x5a>
ffffffffc020774e:	00391713          	slli	a4,s2,0x3
ffffffffc0207752:	00007797          	auipc	a5,0x7
ffffffffc0207756:	90e78793          	addi	a5,a5,-1778 # ffffffffc020e060 <syscalls>
ffffffffc020775a:	97ba                	add	a5,a5,a4
ffffffffc020775c:	639c                	ld	a5,0(a5)
ffffffffc020775e:	c785                	beqz	a5,ffffffffc0207786 <syscall+0x5a>
ffffffffc0207760:	6c28                	ld	a0,88(s0)
ffffffffc0207762:	702c                	ld	a1,96(s0)
ffffffffc0207764:	7430                	ld	a2,104(s0)
ffffffffc0207766:	7834                	ld	a3,112(s0)
ffffffffc0207768:	7c38                	ld	a4,120(s0)
ffffffffc020776a:	e42a                	sd	a0,8(sp)
ffffffffc020776c:	e82e                	sd	a1,16(sp)
ffffffffc020776e:	ec32                	sd	a2,24(sp)
ffffffffc0207770:	f036                	sd	a3,32(sp)
ffffffffc0207772:	f43a                	sd	a4,40(sp)
ffffffffc0207774:	0028                	addi	a0,sp,8
ffffffffc0207776:	9782                	jalr	a5
ffffffffc0207778:	60a6                	ld	ra,72(sp)
ffffffffc020777a:	e828                	sd	a0,80(s0)
ffffffffc020777c:	6406                	ld	s0,64(sp)
ffffffffc020777e:	74e2                	ld	s1,56(sp)
ffffffffc0207780:	7942                	ld	s2,48(sp)
ffffffffc0207782:	6161                	addi	sp,sp,80
ffffffffc0207784:	8082                	ret
ffffffffc0207786:	8522                	mv	a0,s0
ffffffffc0207788:	803f90ef          	jal	ra,ffffffffc0200f8a <print_trapframe>
ffffffffc020778c:	609c                	ld	a5,0(s1)
ffffffffc020778e:	86ca                	mv	a3,s2
ffffffffc0207790:	00007617          	auipc	a2,0x7
ffffffffc0207794:	88860613          	addi	a2,a2,-1912 # ffffffffc020e018 <CSWTCH.84+0x720>
ffffffffc0207798:	43d8                	lw	a4,4(a5)
ffffffffc020779a:	0d800593          	li	a1,216
ffffffffc020779e:	0b478793          	addi	a5,a5,180
ffffffffc02077a2:	00007517          	auipc	a0,0x7
ffffffffc02077a6:	8a650513          	addi	a0,a0,-1882 # ffffffffc020e048 <CSWTCH.84+0x750>
ffffffffc02077aa:	cf5f80ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02077ae <__alloc_inode>:
ffffffffc02077ae:	1141                	addi	sp,sp,-16
ffffffffc02077b0:	e022                	sd	s0,0(sp)
ffffffffc02077b2:	842a                	mv	s0,a0
ffffffffc02077b4:	07800513          	li	a0,120
ffffffffc02077b8:	e406                	sd	ra,8(sp)
ffffffffc02077ba:	fd4fa0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc02077be:	c111                	beqz	a0,ffffffffc02077c2 <__alloc_inode+0x14>
ffffffffc02077c0:	cd20                	sw	s0,88(a0)
ffffffffc02077c2:	60a2                	ld	ra,8(sp)
ffffffffc02077c4:	6402                	ld	s0,0(sp)
ffffffffc02077c6:	0141                	addi	sp,sp,16
ffffffffc02077c8:	8082                	ret

ffffffffc02077ca <inode_init>:
ffffffffc02077ca:	4785                	li	a5,1
ffffffffc02077cc:	06052023          	sw	zero,96(a0)
ffffffffc02077d0:	f92c                	sd	a1,112(a0)
ffffffffc02077d2:	f530                	sd	a2,104(a0)
ffffffffc02077d4:	cd7c                	sw	a5,92(a0)
ffffffffc02077d6:	8082                	ret

ffffffffc02077d8 <inode_kill>:
ffffffffc02077d8:	4d78                	lw	a4,92(a0)
ffffffffc02077da:	1141                	addi	sp,sp,-16
ffffffffc02077dc:	e406                	sd	ra,8(sp)
ffffffffc02077de:	e719                	bnez	a4,ffffffffc02077ec <inode_kill+0x14>
ffffffffc02077e0:	513c                	lw	a5,96(a0)
ffffffffc02077e2:	e78d                	bnez	a5,ffffffffc020780c <inode_kill+0x34>
ffffffffc02077e4:	60a2                	ld	ra,8(sp)
ffffffffc02077e6:	0141                	addi	sp,sp,16
ffffffffc02077e8:	857fa06f          	j	ffffffffc020203e <kfree>
ffffffffc02077ec:	00007697          	auipc	a3,0x7
ffffffffc02077f0:	07468693          	addi	a3,a3,116 # ffffffffc020e860 <syscalls+0x800>
ffffffffc02077f4:	00004617          	auipc	a2,0x4
ffffffffc02077f8:	6f460613          	addi	a2,a2,1780 # ffffffffc020bee8 <commands+0x210>
ffffffffc02077fc:	02900593          	li	a1,41
ffffffffc0207800:	00007517          	auipc	a0,0x7
ffffffffc0207804:	08050513          	addi	a0,a0,128 # ffffffffc020e880 <syscalls+0x820>
ffffffffc0207808:	c97f80ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020780c:	00007697          	auipc	a3,0x7
ffffffffc0207810:	08c68693          	addi	a3,a3,140 # ffffffffc020e898 <syscalls+0x838>
ffffffffc0207814:	00004617          	auipc	a2,0x4
ffffffffc0207818:	6d460613          	addi	a2,a2,1748 # ffffffffc020bee8 <commands+0x210>
ffffffffc020781c:	02a00593          	li	a1,42
ffffffffc0207820:	00007517          	auipc	a0,0x7
ffffffffc0207824:	06050513          	addi	a0,a0,96 # ffffffffc020e880 <syscalls+0x820>
ffffffffc0207828:	c77f80ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020782c <inode_ref_inc>:
ffffffffc020782c:	4d7c                	lw	a5,92(a0)
ffffffffc020782e:	2785                	addiw	a5,a5,1
ffffffffc0207830:	cd7c                	sw	a5,92(a0)
ffffffffc0207832:	0007851b          	sext.w	a0,a5
ffffffffc0207836:	8082                	ret

ffffffffc0207838 <inode_open_inc>:
ffffffffc0207838:	513c                	lw	a5,96(a0)
ffffffffc020783a:	2785                	addiw	a5,a5,1
ffffffffc020783c:	d13c                	sw	a5,96(a0)
ffffffffc020783e:	0007851b          	sext.w	a0,a5
ffffffffc0207842:	8082                	ret

ffffffffc0207844 <inode_check>:
ffffffffc0207844:	1141                	addi	sp,sp,-16
ffffffffc0207846:	e406                	sd	ra,8(sp)
ffffffffc0207848:	c90d                	beqz	a0,ffffffffc020787a <inode_check+0x36>
ffffffffc020784a:	793c                	ld	a5,112(a0)
ffffffffc020784c:	c79d                	beqz	a5,ffffffffc020787a <inode_check+0x36>
ffffffffc020784e:	6398                	ld	a4,0(a5)
ffffffffc0207850:	4625d7b7          	lui	a5,0x4625d
ffffffffc0207854:	0786                	slli	a5,a5,0x1
ffffffffc0207856:	47678793          	addi	a5,a5,1142 # 4625d476 <_binary_bin_sfs_img_size+0x461e8176>
ffffffffc020785a:	08f71063          	bne	a4,a5,ffffffffc02078da <inode_check+0x96>
ffffffffc020785e:	4d78                	lw	a4,92(a0)
ffffffffc0207860:	513c                	lw	a5,96(a0)
ffffffffc0207862:	04f74c63          	blt	a4,a5,ffffffffc02078ba <inode_check+0x76>
ffffffffc0207866:	0407ca63          	bltz	a5,ffffffffc02078ba <inode_check+0x76>
ffffffffc020786a:	66c1                	lui	a3,0x10
ffffffffc020786c:	02d75763          	bge	a4,a3,ffffffffc020789a <inode_check+0x56>
ffffffffc0207870:	02d7d563          	bge	a5,a3,ffffffffc020789a <inode_check+0x56>
ffffffffc0207874:	60a2                	ld	ra,8(sp)
ffffffffc0207876:	0141                	addi	sp,sp,16
ffffffffc0207878:	8082                	ret
ffffffffc020787a:	00007697          	auipc	a3,0x7
ffffffffc020787e:	03e68693          	addi	a3,a3,62 # ffffffffc020e8b8 <syscalls+0x858>
ffffffffc0207882:	00004617          	auipc	a2,0x4
ffffffffc0207886:	66660613          	addi	a2,a2,1638 # ffffffffc020bee8 <commands+0x210>
ffffffffc020788a:	06e00593          	li	a1,110
ffffffffc020788e:	00007517          	auipc	a0,0x7
ffffffffc0207892:	ff250513          	addi	a0,a0,-14 # ffffffffc020e880 <syscalls+0x820>
ffffffffc0207896:	c09f80ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020789a:	00007697          	auipc	a3,0x7
ffffffffc020789e:	09e68693          	addi	a3,a3,158 # ffffffffc020e938 <syscalls+0x8d8>
ffffffffc02078a2:	00004617          	auipc	a2,0x4
ffffffffc02078a6:	64660613          	addi	a2,a2,1606 # ffffffffc020bee8 <commands+0x210>
ffffffffc02078aa:	07200593          	li	a1,114
ffffffffc02078ae:	00007517          	auipc	a0,0x7
ffffffffc02078b2:	fd250513          	addi	a0,a0,-46 # ffffffffc020e880 <syscalls+0x820>
ffffffffc02078b6:	be9f80ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02078ba:	00007697          	auipc	a3,0x7
ffffffffc02078be:	04e68693          	addi	a3,a3,78 # ffffffffc020e908 <syscalls+0x8a8>
ffffffffc02078c2:	00004617          	auipc	a2,0x4
ffffffffc02078c6:	62660613          	addi	a2,a2,1574 # ffffffffc020bee8 <commands+0x210>
ffffffffc02078ca:	07100593          	li	a1,113
ffffffffc02078ce:	00007517          	auipc	a0,0x7
ffffffffc02078d2:	fb250513          	addi	a0,a0,-78 # ffffffffc020e880 <syscalls+0x820>
ffffffffc02078d6:	bc9f80ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02078da:	00007697          	auipc	a3,0x7
ffffffffc02078de:	00668693          	addi	a3,a3,6 # ffffffffc020e8e0 <syscalls+0x880>
ffffffffc02078e2:	00004617          	auipc	a2,0x4
ffffffffc02078e6:	60660613          	addi	a2,a2,1542 # ffffffffc020bee8 <commands+0x210>
ffffffffc02078ea:	06f00593          	li	a1,111
ffffffffc02078ee:	00007517          	auipc	a0,0x7
ffffffffc02078f2:	f9250513          	addi	a0,a0,-110 # ffffffffc020e880 <syscalls+0x820>
ffffffffc02078f6:	ba9f80ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02078fa <inode_ref_dec>:
ffffffffc02078fa:	4d7c                	lw	a5,92(a0)
ffffffffc02078fc:	1101                	addi	sp,sp,-32
ffffffffc02078fe:	ec06                	sd	ra,24(sp)
ffffffffc0207900:	e822                	sd	s0,16(sp)
ffffffffc0207902:	e426                	sd	s1,8(sp)
ffffffffc0207904:	e04a                	sd	s2,0(sp)
ffffffffc0207906:	06f05e63          	blez	a5,ffffffffc0207982 <inode_ref_dec+0x88>
ffffffffc020790a:	fff7849b          	addiw	s1,a5,-1
ffffffffc020790e:	cd64                	sw	s1,92(a0)
ffffffffc0207910:	842a                	mv	s0,a0
ffffffffc0207912:	e09d                	bnez	s1,ffffffffc0207938 <inode_ref_dec+0x3e>
ffffffffc0207914:	793c                	ld	a5,112(a0)
ffffffffc0207916:	c7b1                	beqz	a5,ffffffffc0207962 <inode_ref_dec+0x68>
ffffffffc0207918:	0487b903          	ld	s2,72(a5)
ffffffffc020791c:	04090363          	beqz	s2,ffffffffc0207962 <inode_ref_dec+0x68>
ffffffffc0207920:	00007597          	auipc	a1,0x7
ffffffffc0207924:	0c858593          	addi	a1,a1,200 # ffffffffc020e9e8 <syscalls+0x988>
ffffffffc0207928:	f1dff0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc020792c:	8522                	mv	a0,s0
ffffffffc020792e:	9902                	jalr	s2
ffffffffc0207930:	c501                	beqz	a0,ffffffffc0207938 <inode_ref_dec+0x3e>
ffffffffc0207932:	57c5                	li	a5,-15
ffffffffc0207934:	00f51963          	bne	a0,a5,ffffffffc0207946 <inode_ref_dec+0x4c>
ffffffffc0207938:	60e2                	ld	ra,24(sp)
ffffffffc020793a:	6442                	ld	s0,16(sp)
ffffffffc020793c:	6902                	ld	s2,0(sp)
ffffffffc020793e:	8526                	mv	a0,s1
ffffffffc0207940:	64a2                	ld	s1,8(sp)
ffffffffc0207942:	6105                	addi	sp,sp,32
ffffffffc0207944:	8082                	ret
ffffffffc0207946:	85aa                	mv	a1,a0
ffffffffc0207948:	00007517          	auipc	a0,0x7
ffffffffc020794c:	0a850513          	addi	a0,a0,168 # ffffffffc020e9f0 <syscalls+0x990>
ffffffffc0207950:	857f80ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0207954:	60e2                	ld	ra,24(sp)
ffffffffc0207956:	6442                	ld	s0,16(sp)
ffffffffc0207958:	6902                	ld	s2,0(sp)
ffffffffc020795a:	8526                	mv	a0,s1
ffffffffc020795c:	64a2                	ld	s1,8(sp)
ffffffffc020795e:	6105                	addi	sp,sp,32
ffffffffc0207960:	8082                	ret
ffffffffc0207962:	00007697          	auipc	a3,0x7
ffffffffc0207966:	03668693          	addi	a3,a3,54 # ffffffffc020e998 <syscalls+0x938>
ffffffffc020796a:	00004617          	auipc	a2,0x4
ffffffffc020796e:	57e60613          	addi	a2,a2,1406 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207972:	04400593          	li	a1,68
ffffffffc0207976:	00007517          	auipc	a0,0x7
ffffffffc020797a:	f0a50513          	addi	a0,a0,-246 # ffffffffc020e880 <syscalls+0x820>
ffffffffc020797e:	b21f80ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0207982:	00007697          	auipc	a3,0x7
ffffffffc0207986:	ff668693          	addi	a3,a3,-10 # ffffffffc020e978 <syscalls+0x918>
ffffffffc020798a:	00004617          	auipc	a2,0x4
ffffffffc020798e:	55e60613          	addi	a2,a2,1374 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207992:	03f00593          	li	a1,63
ffffffffc0207996:	00007517          	auipc	a0,0x7
ffffffffc020799a:	eea50513          	addi	a0,a0,-278 # ffffffffc020e880 <syscalls+0x820>
ffffffffc020799e:	b01f80ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02079a2 <inode_open_dec>:
ffffffffc02079a2:	513c                	lw	a5,96(a0)
ffffffffc02079a4:	1101                	addi	sp,sp,-32
ffffffffc02079a6:	ec06                	sd	ra,24(sp)
ffffffffc02079a8:	e822                	sd	s0,16(sp)
ffffffffc02079aa:	e426                	sd	s1,8(sp)
ffffffffc02079ac:	e04a                	sd	s2,0(sp)
ffffffffc02079ae:	06f05b63          	blez	a5,ffffffffc0207a24 <inode_open_dec+0x82>
ffffffffc02079b2:	fff7849b          	addiw	s1,a5,-1
ffffffffc02079b6:	d124                	sw	s1,96(a0)
ffffffffc02079b8:	842a                	mv	s0,a0
ffffffffc02079ba:	e085                	bnez	s1,ffffffffc02079da <inode_open_dec+0x38>
ffffffffc02079bc:	793c                	ld	a5,112(a0)
ffffffffc02079be:	c3b9                	beqz	a5,ffffffffc0207a04 <inode_open_dec+0x62>
ffffffffc02079c0:	0107b903          	ld	s2,16(a5)
ffffffffc02079c4:	04090063          	beqz	s2,ffffffffc0207a04 <inode_open_dec+0x62>
ffffffffc02079c8:	00007597          	auipc	a1,0x7
ffffffffc02079cc:	0b858593          	addi	a1,a1,184 # ffffffffc020ea80 <syscalls+0xa20>
ffffffffc02079d0:	e75ff0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc02079d4:	8522                	mv	a0,s0
ffffffffc02079d6:	9902                	jalr	s2
ffffffffc02079d8:	e901                	bnez	a0,ffffffffc02079e8 <inode_open_dec+0x46>
ffffffffc02079da:	60e2                	ld	ra,24(sp)
ffffffffc02079dc:	6442                	ld	s0,16(sp)
ffffffffc02079de:	6902                	ld	s2,0(sp)
ffffffffc02079e0:	8526                	mv	a0,s1
ffffffffc02079e2:	64a2                	ld	s1,8(sp)
ffffffffc02079e4:	6105                	addi	sp,sp,32
ffffffffc02079e6:	8082                	ret
ffffffffc02079e8:	85aa                	mv	a1,a0
ffffffffc02079ea:	00007517          	auipc	a0,0x7
ffffffffc02079ee:	09e50513          	addi	a0,a0,158 # ffffffffc020ea88 <syscalls+0xa28>
ffffffffc02079f2:	fb4f80ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc02079f6:	60e2                	ld	ra,24(sp)
ffffffffc02079f8:	6442                	ld	s0,16(sp)
ffffffffc02079fa:	6902                	ld	s2,0(sp)
ffffffffc02079fc:	8526                	mv	a0,s1
ffffffffc02079fe:	64a2                	ld	s1,8(sp)
ffffffffc0207a00:	6105                	addi	sp,sp,32
ffffffffc0207a02:	8082                	ret
ffffffffc0207a04:	00007697          	auipc	a3,0x7
ffffffffc0207a08:	02c68693          	addi	a3,a3,44 # ffffffffc020ea30 <syscalls+0x9d0>
ffffffffc0207a0c:	00004617          	auipc	a2,0x4
ffffffffc0207a10:	4dc60613          	addi	a2,a2,1244 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207a14:	06100593          	li	a1,97
ffffffffc0207a18:	00007517          	auipc	a0,0x7
ffffffffc0207a1c:	e6850513          	addi	a0,a0,-408 # ffffffffc020e880 <syscalls+0x820>
ffffffffc0207a20:	a7ff80ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0207a24:	00007697          	auipc	a3,0x7
ffffffffc0207a28:	fec68693          	addi	a3,a3,-20 # ffffffffc020ea10 <syscalls+0x9b0>
ffffffffc0207a2c:	00004617          	auipc	a2,0x4
ffffffffc0207a30:	4bc60613          	addi	a2,a2,1212 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207a34:	05c00593          	li	a1,92
ffffffffc0207a38:	00007517          	auipc	a0,0x7
ffffffffc0207a3c:	e4850513          	addi	a0,a0,-440 # ffffffffc020e880 <syscalls+0x820>
ffffffffc0207a40:	a5ff80ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0207a44 <__alloc_fs>:
ffffffffc0207a44:	1141                	addi	sp,sp,-16
ffffffffc0207a46:	e022                	sd	s0,0(sp)
ffffffffc0207a48:	842a                	mv	s0,a0
ffffffffc0207a4a:	0d800513          	li	a0,216
ffffffffc0207a4e:	e406                	sd	ra,8(sp)
ffffffffc0207a50:	d3efa0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc0207a54:	c119                	beqz	a0,ffffffffc0207a5a <__alloc_fs+0x16>
ffffffffc0207a56:	0a852823          	sw	s0,176(a0)
ffffffffc0207a5a:	60a2                	ld	ra,8(sp)
ffffffffc0207a5c:	6402                	ld	s0,0(sp)
ffffffffc0207a5e:	0141                	addi	sp,sp,16
ffffffffc0207a60:	8082                	ret

ffffffffc0207a62 <vfs_init>:
ffffffffc0207a62:	1141                	addi	sp,sp,-16
ffffffffc0207a64:	4585                	li	a1,1
ffffffffc0207a66:	0008e517          	auipc	a0,0x8e
ffffffffc0207a6a:	d9a50513          	addi	a0,a0,-614 # ffffffffc0295800 <bootfs_sem>
ffffffffc0207a6e:	e406                	sd	ra,8(sp)
ffffffffc0207a70:	aebfc0ef          	jal	ra,ffffffffc020455a <sem_init>
ffffffffc0207a74:	60a2                	ld	ra,8(sp)
ffffffffc0207a76:	0141                	addi	sp,sp,16
ffffffffc0207a78:	a40d                	j	ffffffffc0207c9a <vfs_devlist_init>

ffffffffc0207a7a <vfs_set_bootfs>:
ffffffffc0207a7a:	7179                	addi	sp,sp,-48
ffffffffc0207a7c:	f022                	sd	s0,32(sp)
ffffffffc0207a7e:	f406                	sd	ra,40(sp)
ffffffffc0207a80:	ec26                	sd	s1,24(sp)
ffffffffc0207a82:	e402                	sd	zero,8(sp)
ffffffffc0207a84:	842a                	mv	s0,a0
ffffffffc0207a86:	c915                	beqz	a0,ffffffffc0207aba <vfs_set_bootfs+0x40>
ffffffffc0207a88:	03a00593          	li	a1,58
ffffffffc0207a8c:	763030ef          	jal	ra,ffffffffc020b9ee <strchr>
ffffffffc0207a90:	c135                	beqz	a0,ffffffffc0207af4 <vfs_set_bootfs+0x7a>
ffffffffc0207a92:	00154783          	lbu	a5,1(a0)
ffffffffc0207a96:	efb9                	bnez	a5,ffffffffc0207af4 <vfs_set_bootfs+0x7a>
ffffffffc0207a98:	8522                	mv	a0,s0
ffffffffc0207a9a:	3cb000ef          	jal	ra,ffffffffc0208664 <vfs_chdir>
ffffffffc0207a9e:	842a                	mv	s0,a0
ffffffffc0207aa0:	c519                	beqz	a0,ffffffffc0207aae <vfs_set_bootfs+0x34>
ffffffffc0207aa2:	70a2                	ld	ra,40(sp)
ffffffffc0207aa4:	8522                	mv	a0,s0
ffffffffc0207aa6:	7402                	ld	s0,32(sp)
ffffffffc0207aa8:	64e2                	ld	s1,24(sp)
ffffffffc0207aaa:	6145                	addi	sp,sp,48
ffffffffc0207aac:	8082                	ret
ffffffffc0207aae:	0028                	addi	a0,sp,8
ffffffffc0207ab0:	2bf000ef          	jal	ra,ffffffffc020856e <vfs_get_curdir>
ffffffffc0207ab4:	842a                	mv	s0,a0
ffffffffc0207ab6:	f575                	bnez	a0,ffffffffc0207aa2 <vfs_set_bootfs+0x28>
ffffffffc0207ab8:	6422                	ld	s0,8(sp)
ffffffffc0207aba:	0008e517          	auipc	a0,0x8e
ffffffffc0207abe:	d4650513          	addi	a0,a0,-698 # ffffffffc0295800 <bootfs_sem>
ffffffffc0207ac2:	aa3fc0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc0207ac6:	0008f797          	auipc	a5,0x8f
ffffffffc0207aca:	e2a78793          	addi	a5,a5,-470 # ffffffffc02968f0 <bootfs_node>
ffffffffc0207ace:	6384                	ld	s1,0(a5)
ffffffffc0207ad0:	0008e517          	auipc	a0,0x8e
ffffffffc0207ad4:	d3050513          	addi	a0,a0,-720 # ffffffffc0295800 <bootfs_sem>
ffffffffc0207ad8:	e380                	sd	s0,0(a5)
ffffffffc0207ada:	4401                	li	s0,0
ffffffffc0207adc:	a85fc0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0207ae0:	d0e9                	beqz	s1,ffffffffc0207aa2 <vfs_set_bootfs+0x28>
ffffffffc0207ae2:	8526                	mv	a0,s1
ffffffffc0207ae4:	e17ff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc0207ae8:	70a2                	ld	ra,40(sp)
ffffffffc0207aea:	8522                	mv	a0,s0
ffffffffc0207aec:	7402                	ld	s0,32(sp)
ffffffffc0207aee:	64e2                	ld	s1,24(sp)
ffffffffc0207af0:	6145                	addi	sp,sp,48
ffffffffc0207af2:	8082                	ret
ffffffffc0207af4:	5475                	li	s0,-3
ffffffffc0207af6:	b775                	j	ffffffffc0207aa2 <vfs_set_bootfs+0x28>

ffffffffc0207af8 <vfs_get_bootfs>:
ffffffffc0207af8:	1101                	addi	sp,sp,-32
ffffffffc0207afa:	e426                	sd	s1,8(sp)
ffffffffc0207afc:	0008f497          	auipc	s1,0x8f
ffffffffc0207b00:	df448493          	addi	s1,s1,-524 # ffffffffc02968f0 <bootfs_node>
ffffffffc0207b04:	609c                	ld	a5,0(s1)
ffffffffc0207b06:	ec06                	sd	ra,24(sp)
ffffffffc0207b08:	e822                	sd	s0,16(sp)
ffffffffc0207b0a:	c3a1                	beqz	a5,ffffffffc0207b4a <vfs_get_bootfs+0x52>
ffffffffc0207b0c:	842a                	mv	s0,a0
ffffffffc0207b0e:	0008e517          	auipc	a0,0x8e
ffffffffc0207b12:	cf250513          	addi	a0,a0,-782 # ffffffffc0295800 <bootfs_sem>
ffffffffc0207b16:	a4ffc0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc0207b1a:	6084                	ld	s1,0(s1)
ffffffffc0207b1c:	c08d                	beqz	s1,ffffffffc0207b3e <vfs_get_bootfs+0x46>
ffffffffc0207b1e:	8526                	mv	a0,s1
ffffffffc0207b20:	d0dff0ef          	jal	ra,ffffffffc020782c <inode_ref_inc>
ffffffffc0207b24:	0008e517          	auipc	a0,0x8e
ffffffffc0207b28:	cdc50513          	addi	a0,a0,-804 # ffffffffc0295800 <bootfs_sem>
ffffffffc0207b2c:	a35fc0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0207b30:	4501                	li	a0,0
ffffffffc0207b32:	e004                	sd	s1,0(s0)
ffffffffc0207b34:	60e2                	ld	ra,24(sp)
ffffffffc0207b36:	6442                	ld	s0,16(sp)
ffffffffc0207b38:	64a2                	ld	s1,8(sp)
ffffffffc0207b3a:	6105                	addi	sp,sp,32
ffffffffc0207b3c:	8082                	ret
ffffffffc0207b3e:	0008e517          	auipc	a0,0x8e
ffffffffc0207b42:	cc250513          	addi	a0,a0,-830 # ffffffffc0295800 <bootfs_sem>
ffffffffc0207b46:	a1bfc0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0207b4a:	5541                	li	a0,-16
ffffffffc0207b4c:	b7e5                	j	ffffffffc0207b34 <vfs_get_bootfs+0x3c>

ffffffffc0207b4e <vfs_do_add>:
ffffffffc0207b4e:	7139                	addi	sp,sp,-64
ffffffffc0207b50:	fc06                	sd	ra,56(sp)
ffffffffc0207b52:	f822                	sd	s0,48(sp)
ffffffffc0207b54:	f426                	sd	s1,40(sp)
ffffffffc0207b56:	f04a                	sd	s2,32(sp)
ffffffffc0207b58:	ec4e                	sd	s3,24(sp)
ffffffffc0207b5a:	e852                	sd	s4,16(sp)
ffffffffc0207b5c:	e456                	sd	s5,8(sp)
ffffffffc0207b5e:	e05a                	sd	s6,0(sp)
ffffffffc0207b60:	0e050b63          	beqz	a0,ffffffffc0207c56 <vfs_do_add+0x108>
ffffffffc0207b64:	842a                	mv	s0,a0
ffffffffc0207b66:	8a2e                	mv	s4,a1
ffffffffc0207b68:	8b32                	mv	s6,a2
ffffffffc0207b6a:	8ab6                	mv	s5,a3
ffffffffc0207b6c:	c5cd                	beqz	a1,ffffffffc0207c16 <vfs_do_add+0xc8>
ffffffffc0207b6e:	4db8                	lw	a4,88(a1)
ffffffffc0207b70:	6785                	lui	a5,0x1
ffffffffc0207b72:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0207b76:	0af71163          	bne	a4,a5,ffffffffc0207c18 <vfs_do_add+0xca>
ffffffffc0207b7a:	8522                	mv	a0,s0
ffffffffc0207b7c:	5bf030ef          	jal	ra,ffffffffc020b93a <strlen>
ffffffffc0207b80:	47fd                	li	a5,31
ffffffffc0207b82:	0ca7e663          	bltu	a5,a0,ffffffffc0207c4e <vfs_do_add+0x100>
ffffffffc0207b86:	8522                	mv	a0,s0
ffffffffc0207b88:	e6cf80ef          	jal	ra,ffffffffc02001f4 <strdup>
ffffffffc0207b8c:	84aa                	mv	s1,a0
ffffffffc0207b8e:	c171                	beqz	a0,ffffffffc0207c52 <vfs_do_add+0x104>
ffffffffc0207b90:	03000513          	li	a0,48
ffffffffc0207b94:	bfafa0ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc0207b98:	89aa                	mv	s3,a0
ffffffffc0207b9a:	c92d                	beqz	a0,ffffffffc0207c0c <vfs_do_add+0xbe>
ffffffffc0207b9c:	0008e517          	auipc	a0,0x8e
ffffffffc0207ba0:	c8c50513          	addi	a0,a0,-884 # ffffffffc0295828 <vdev_list_sem>
ffffffffc0207ba4:	0008e917          	auipc	s2,0x8e
ffffffffc0207ba8:	c7490913          	addi	s2,s2,-908 # ffffffffc0295818 <vdev_list>
ffffffffc0207bac:	9b9fc0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc0207bb0:	844a                	mv	s0,s2
ffffffffc0207bb2:	a039                	j	ffffffffc0207bc0 <vfs_do_add+0x72>
ffffffffc0207bb4:	fe043503          	ld	a0,-32(s0)
ffffffffc0207bb8:	85a6                	mv	a1,s1
ffffffffc0207bba:	5f1030ef          	jal	ra,ffffffffc020b9aa <strcmp>
ffffffffc0207bbe:	cd2d                	beqz	a0,ffffffffc0207c38 <vfs_do_add+0xea>
ffffffffc0207bc0:	6400                	ld	s0,8(s0)
ffffffffc0207bc2:	ff2419e3          	bne	s0,s2,ffffffffc0207bb4 <vfs_do_add+0x66>
ffffffffc0207bc6:	6418                	ld	a4,8(s0)
ffffffffc0207bc8:	02098793          	addi	a5,s3,32
ffffffffc0207bcc:	0099b023          	sd	s1,0(s3)
ffffffffc0207bd0:	0149b423          	sd	s4,8(s3)
ffffffffc0207bd4:	0159bc23          	sd	s5,24(s3)
ffffffffc0207bd8:	0169b823          	sd	s6,16(s3)
ffffffffc0207bdc:	e31c                	sd	a5,0(a4)
ffffffffc0207bde:	0289b023          	sd	s0,32(s3)
ffffffffc0207be2:	02e9b423          	sd	a4,40(s3)
ffffffffc0207be6:	0008e517          	auipc	a0,0x8e
ffffffffc0207bea:	c4250513          	addi	a0,a0,-958 # ffffffffc0295828 <vdev_list_sem>
ffffffffc0207bee:	e41c                	sd	a5,8(s0)
ffffffffc0207bf0:	4401                	li	s0,0
ffffffffc0207bf2:	96ffc0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0207bf6:	70e2                	ld	ra,56(sp)
ffffffffc0207bf8:	8522                	mv	a0,s0
ffffffffc0207bfa:	7442                	ld	s0,48(sp)
ffffffffc0207bfc:	74a2                	ld	s1,40(sp)
ffffffffc0207bfe:	7902                	ld	s2,32(sp)
ffffffffc0207c00:	69e2                	ld	s3,24(sp)
ffffffffc0207c02:	6a42                	ld	s4,16(sp)
ffffffffc0207c04:	6aa2                	ld	s5,8(sp)
ffffffffc0207c06:	6b02                	ld	s6,0(sp)
ffffffffc0207c08:	6121                	addi	sp,sp,64
ffffffffc0207c0a:	8082                	ret
ffffffffc0207c0c:	5471                	li	s0,-4
ffffffffc0207c0e:	8526                	mv	a0,s1
ffffffffc0207c10:	c2efa0ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc0207c14:	b7cd                	j	ffffffffc0207bf6 <vfs_do_add+0xa8>
ffffffffc0207c16:	d2b5                	beqz	a3,ffffffffc0207b7a <vfs_do_add+0x2c>
ffffffffc0207c18:	00007697          	auipc	a3,0x7
ffffffffc0207c1c:	eb868693          	addi	a3,a3,-328 # ffffffffc020ead0 <syscalls+0xa70>
ffffffffc0207c20:	00004617          	auipc	a2,0x4
ffffffffc0207c24:	2c860613          	addi	a2,a2,712 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207c28:	08f00593          	li	a1,143
ffffffffc0207c2c:	00007517          	auipc	a0,0x7
ffffffffc0207c30:	e8c50513          	addi	a0,a0,-372 # ffffffffc020eab8 <syscalls+0xa58>
ffffffffc0207c34:	86bf80ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0207c38:	0008e517          	auipc	a0,0x8e
ffffffffc0207c3c:	bf050513          	addi	a0,a0,-1040 # ffffffffc0295828 <vdev_list_sem>
ffffffffc0207c40:	921fc0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0207c44:	854e                	mv	a0,s3
ffffffffc0207c46:	bf8fa0ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc0207c4a:	5425                	li	s0,-23
ffffffffc0207c4c:	b7c9                	j	ffffffffc0207c0e <vfs_do_add+0xc0>
ffffffffc0207c4e:	5451                	li	s0,-12
ffffffffc0207c50:	b75d                	j	ffffffffc0207bf6 <vfs_do_add+0xa8>
ffffffffc0207c52:	5471                	li	s0,-4
ffffffffc0207c54:	b74d                	j	ffffffffc0207bf6 <vfs_do_add+0xa8>
ffffffffc0207c56:	00007697          	auipc	a3,0x7
ffffffffc0207c5a:	e5268693          	addi	a3,a3,-430 # ffffffffc020eaa8 <syscalls+0xa48>
ffffffffc0207c5e:	00004617          	auipc	a2,0x4
ffffffffc0207c62:	28a60613          	addi	a2,a2,650 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207c66:	08e00593          	li	a1,142
ffffffffc0207c6a:	00007517          	auipc	a0,0x7
ffffffffc0207c6e:	e4e50513          	addi	a0,a0,-434 # ffffffffc020eab8 <syscalls+0xa58>
ffffffffc0207c72:	82df80ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0207c76 <find_mount.part.0>:
ffffffffc0207c76:	1141                	addi	sp,sp,-16
ffffffffc0207c78:	00007697          	auipc	a3,0x7
ffffffffc0207c7c:	e3068693          	addi	a3,a3,-464 # ffffffffc020eaa8 <syscalls+0xa48>
ffffffffc0207c80:	00004617          	auipc	a2,0x4
ffffffffc0207c84:	26860613          	addi	a2,a2,616 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207c88:	0cd00593          	li	a1,205
ffffffffc0207c8c:	00007517          	auipc	a0,0x7
ffffffffc0207c90:	e2c50513          	addi	a0,a0,-468 # ffffffffc020eab8 <syscalls+0xa58>
ffffffffc0207c94:	e406                	sd	ra,8(sp)
ffffffffc0207c96:	809f80ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0207c9a <vfs_devlist_init>:
ffffffffc0207c9a:	0008e797          	auipc	a5,0x8e
ffffffffc0207c9e:	b7e78793          	addi	a5,a5,-1154 # ffffffffc0295818 <vdev_list>
ffffffffc0207ca2:	4585                	li	a1,1
ffffffffc0207ca4:	0008e517          	auipc	a0,0x8e
ffffffffc0207ca8:	b8450513          	addi	a0,a0,-1148 # ffffffffc0295828 <vdev_list_sem>
ffffffffc0207cac:	e79c                	sd	a5,8(a5)
ffffffffc0207cae:	e39c                	sd	a5,0(a5)
ffffffffc0207cb0:	8abfc06f          	j	ffffffffc020455a <sem_init>

ffffffffc0207cb4 <vfs_cleanup>:
ffffffffc0207cb4:	1101                	addi	sp,sp,-32
ffffffffc0207cb6:	e426                	sd	s1,8(sp)
ffffffffc0207cb8:	0008e497          	auipc	s1,0x8e
ffffffffc0207cbc:	b6048493          	addi	s1,s1,-1184 # ffffffffc0295818 <vdev_list>
ffffffffc0207cc0:	649c                	ld	a5,8(s1)
ffffffffc0207cc2:	ec06                	sd	ra,24(sp)
ffffffffc0207cc4:	e822                	sd	s0,16(sp)
ffffffffc0207cc6:	02978e63          	beq	a5,s1,ffffffffc0207d02 <vfs_cleanup+0x4e>
ffffffffc0207cca:	0008e517          	auipc	a0,0x8e
ffffffffc0207cce:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0295828 <vdev_list_sem>
ffffffffc0207cd2:	893fc0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc0207cd6:	6480                	ld	s0,8(s1)
ffffffffc0207cd8:	00940b63          	beq	s0,s1,ffffffffc0207cee <vfs_cleanup+0x3a>
ffffffffc0207cdc:	ff043783          	ld	a5,-16(s0)
ffffffffc0207ce0:	853e                	mv	a0,a5
ffffffffc0207ce2:	c399                	beqz	a5,ffffffffc0207ce8 <vfs_cleanup+0x34>
ffffffffc0207ce4:	6bfc                	ld	a5,208(a5)
ffffffffc0207ce6:	9782                	jalr	a5
ffffffffc0207ce8:	6400                	ld	s0,8(s0)
ffffffffc0207cea:	fe9419e3          	bne	s0,s1,ffffffffc0207cdc <vfs_cleanup+0x28>
ffffffffc0207cee:	6442                	ld	s0,16(sp)
ffffffffc0207cf0:	60e2                	ld	ra,24(sp)
ffffffffc0207cf2:	64a2                	ld	s1,8(sp)
ffffffffc0207cf4:	0008e517          	auipc	a0,0x8e
ffffffffc0207cf8:	b3450513          	addi	a0,a0,-1228 # ffffffffc0295828 <vdev_list_sem>
ffffffffc0207cfc:	6105                	addi	sp,sp,32
ffffffffc0207cfe:	863fc06f          	j	ffffffffc0204560 <up>
ffffffffc0207d02:	60e2                	ld	ra,24(sp)
ffffffffc0207d04:	6442                	ld	s0,16(sp)
ffffffffc0207d06:	64a2                	ld	s1,8(sp)
ffffffffc0207d08:	6105                	addi	sp,sp,32
ffffffffc0207d0a:	8082                	ret

ffffffffc0207d0c <vfs_get_root>:
ffffffffc0207d0c:	7179                	addi	sp,sp,-48
ffffffffc0207d0e:	f406                	sd	ra,40(sp)
ffffffffc0207d10:	f022                	sd	s0,32(sp)
ffffffffc0207d12:	ec26                	sd	s1,24(sp)
ffffffffc0207d14:	e84a                	sd	s2,16(sp)
ffffffffc0207d16:	e44e                	sd	s3,8(sp)
ffffffffc0207d18:	e052                	sd	s4,0(sp)
ffffffffc0207d1a:	c541                	beqz	a0,ffffffffc0207da2 <vfs_get_root+0x96>
ffffffffc0207d1c:	0008e917          	auipc	s2,0x8e
ffffffffc0207d20:	afc90913          	addi	s2,s2,-1284 # ffffffffc0295818 <vdev_list>
ffffffffc0207d24:	00893783          	ld	a5,8(s2)
ffffffffc0207d28:	07278b63          	beq	a5,s2,ffffffffc0207d9e <vfs_get_root+0x92>
ffffffffc0207d2c:	89aa                	mv	s3,a0
ffffffffc0207d2e:	0008e517          	auipc	a0,0x8e
ffffffffc0207d32:	afa50513          	addi	a0,a0,-1286 # ffffffffc0295828 <vdev_list_sem>
ffffffffc0207d36:	8a2e                	mv	s4,a1
ffffffffc0207d38:	844a                	mv	s0,s2
ffffffffc0207d3a:	82bfc0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc0207d3e:	a801                	j	ffffffffc0207d4e <vfs_get_root+0x42>
ffffffffc0207d40:	fe043583          	ld	a1,-32(s0)
ffffffffc0207d44:	854e                	mv	a0,s3
ffffffffc0207d46:	465030ef          	jal	ra,ffffffffc020b9aa <strcmp>
ffffffffc0207d4a:	84aa                	mv	s1,a0
ffffffffc0207d4c:	c505                	beqz	a0,ffffffffc0207d74 <vfs_get_root+0x68>
ffffffffc0207d4e:	6400                	ld	s0,8(s0)
ffffffffc0207d50:	ff2418e3          	bne	s0,s2,ffffffffc0207d40 <vfs_get_root+0x34>
ffffffffc0207d54:	54cd                	li	s1,-13
ffffffffc0207d56:	0008e517          	auipc	a0,0x8e
ffffffffc0207d5a:	ad250513          	addi	a0,a0,-1326 # ffffffffc0295828 <vdev_list_sem>
ffffffffc0207d5e:	803fc0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0207d62:	70a2                	ld	ra,40(sp)
ffffffffc0207d64:	7402                	ld	s0,32(sp)
ffffffffc0207d66:	6942                	ld	s2,16(sp)
ffffffffc0207d68:	69a2                	ld	s3,8(sp)
ffffffffc0207d6a:	6a02                	ld	s4,0(sp)
ffffffffc0207d6c:	8526                	mv	a0,s1
ffffffffc0207d6e:	64e2                	ld	s1,24(sp)
ffffffffc0207d70:	6145                	addi	sp,sp,48
ffffffffc0207d72:	8082                	ret
ffffffffc0207d74:	ff043503          	ld	a0,-16(s0)
ffffffffc0207d78:	c519                	beqz	a0,ffffffffc0207d86 <vfs_get_root+0x7a>
ffffffffc0207d7a:	617c                	ld	a5,192(a0)
ffffffffc0207d7c:	9782                	jalr	a5
ffffffffc0207d7e:	c519                	beqz	a0,ffffffffc0207d8c <vfs_get_root+0x80>
ffffffffc0207d80:	00aa3023          	sd	a0,0(s4)
ffffffffc0207d84:	bfc9                	j	ffffffffc0207d56 <vfs_get_root+0x4a>
ffffffffc0207d86:	ff843783          	ld	a5,-8(s0)
ffffffffc0207d8a:	c399                	beqz	a5,ffffffffc0207d90 <vfs_get_root+0x84>
ffffffffc0207d8c:	54c9                	li	s1,-14
ffffffffc0207d8e:	b7e1                	j	ffffffffc0207d56 <vfs_get_root+0x4a>
ffffffffc0207d90:	fe843503          	ld	a0,-24(s0)
ffffffffc0207d94:	a99ff0ef          	jal	ra,ffffffffc020782c <inode_ref_inc>
ffffffffc0207d98:	fe843503          	ld	a0,-24(s0)
ffffffffc0207d9c:	b7cd                	j	ffffffffc0207d7e <vfs_get_root+0x72>
ffffffffc0207d9e:	54cd                	li	s1,-13
ffffffffc0207da0:	b7c9                	j	ffffffffc0207d62 <vfs_get_root+0x56>
ffffffffc0207da2:	00007697          	auipc	a3,0x7
ffffffffc0207da6:	d0668693          	addi	a3,a3,-762 # ffffffffc020eaa8 <syscalls+0xa48>
ffffffffc0207daa:	00004617          	auipc	a2,0x4
ffffffffc0207dae:	13e60613          	addi	a2,a2,318 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207db2:	04500593          	li	a1,69
ffffffffc0207db6:	00007517          	auipc	a0,0x7
ffffffffc0207dba:	d0250513          	addi	a0,a0,-766 # ffffffffc020eab8 <syscalls+0xa58>
ffffffffc0207dbe:	ee0f80ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0207dc2 <vfs_get_devname>:
ffffffffc0207dc2:	0008e697          	auipc	a3,0x8e
ffffffffc0207dc6:	a5668693          	addi	a3,a3,-1450 # ffffffffc0295818 <vdev_list>
ffffffffc0207dca:	87b6                	mv	a5,a3
ffffffffc0207dcc:	e511                	bnez	a0,ffffffffc0207dd8 <vfs_get_devname+0x16>
ffffffffc0207dce:	a829                	j	ffffffffc0207de8 <vfs_get_devname+0x26>
ffffffffc0207dd0:	ff07b703          	ld	a4,-16(a5)
ffffffffc0207dd4:	00a70763          	beq	a4,a0,ffffffffc0207de2 <vfs_get_devname+0x20>
ffffffffc0207dd8:	679c                	ld	a5,8(a5)
ffffffffc0207dda:	fed79be3          	bne	a5,a3,ffffffffc0207dd0 <vfs_get_devname+0xe>
ffffffffc0207dde:	4501                	li	a0,0
ffffffffc0207de0:	8082                	ret
ffffffffc0207de2:	fe07b503          	ld	a0,-32(a5)
ffffffffc0207de6:	8082                	ret
ffffffffc0207de8:	1141                	addi	sp,sp,-16
ffffffffc0207dea:	00007697          	auipc	a3,0x7
ffffffffc0207dee:	d4668693          	addi	a3,a3,-698 # ffffffffc020eb30 <syscalls+0xad0>
ffffffffc0207df2:	00004617          	auipc	a2,0x4
ffffffffc0207df6:	0f660613          	addi	a2,a2,246 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207dfa:	06a00593          	li	a1,106
ffffffffc0207dfe:	00007517          	auipc	a0,0x7
ffffffffc0207e02:	cba50513          	addi	a0,a0,-838 # ffffffffc020eab8 <syscalls+0xa58>
ffffffffc0207e06:	e406                	sd	ra,8(sp)
ffffffffc0207e08:	e96f80ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0207e0c <vfs_add_dev>:
ffffffffc0207e0c:	86b2                	mv	a3,a2
ffffffffc0207e0e:	4601                	li	a2,0
ffffffffc0207e10:	d3fff06f          	j	ffffffffc0207b4e <vfs_do_add>

ffffffffc0207e14 <vfs_mount>:
ffffffffc0207e14:	7179                	addi	sp,sp,-48
ffffffffc0207e16:	e84a                	sd	s2,16(sp)
ffffffffc0207e18:	892a                	mv	s2,a0
ffffffffc0207e1a:	0008e517          	auipc	a0,0x8e
ffffffffc0207e1e:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0295828 <vdev_list_sem>
ffffffffc0207e22:	e44e                	sd	s3,8(sp)
ffffffffc0207e24:	f406                	sd	ra,40(sp)
ffffffffc0207e26:	f022                	sd	s0,32(sp)
ffffffffc0207e28:	ec26                	sd	s1,24(sp)
ffffffffc0207e2a:	89ae                	mv	s3,a1
ffffffffc0207e2c:	f38fc0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc0207e30:	08090a63          	beqz	s2,ffffffffc0207ec4 <vfs_mount+0xb0>
ffffffffc0207e34:	0008e497          	auipc	s1,0x8e
ffffffffc0207e38:	9e448493          	addi	s1,s1,-1564 # ffffffffc0295818 <vdev_list>
ffffffffc0207e3c:	6480                	ld	s0,8(s1)
ffffffffc0207e3e:	00941663          	bne	s0,s1,ffffffffc0207e4a <vfs_mount+0x36>
ffffffffc0207e42:	a8ad                	j	ffffffffc0207ebc <vfs_mount+0xa8>
ffffffffc0207e44:	6400                	ld	s0,8(s0)
ffffffffc0207e46:	06940b63          	beq	s0,s1,ffffffffc0207ebc <vfs_mount+0xa8>
ffffffffc0207e4a:	ff843783          	ld	a5,-8(s0)
ffffffffc0207e4e:	dbfd                	beqz	a5,ffffffffc0207e44 <vfs_mount+0x30>
ffffffffc0207e50:	fe043503          	ld	a0,-32(s0)
ffffffffc0207e54:	85ca                	mv	a1,s2
ffffffffc0207e56:	355030ef          	jal	ra,ffffffffc020b9aa <strcmp>
ffffffffc0207e5a:	f56d                	bnez	a0,ffffffffc0207e44 <vfs_mount+0x30>
ffffffffc0207e5c:	ff043783          	ld	a5,-16(s0)
ffffffffc0207e60:	e3a5                	bnez	a5,ffffffffc0207ec0 <vfs_mount+0xac>
ffffffffc0207e62:	fe043783          	ld	a5,-32(s0)
ffffffffc0207e66:	c3c9                	beqz	a5,ffffffffc0207ee8 <vfs_mount+0xd4>
ffffffffc0207e68:	ff843783          	ld	a5,-8(s0)
ffffffffc0207e6c:	cfb5                	beqz	a5,ffffffffc0207ee8 <vfs_mount+0xd4>
ffffffffc0207e6e:	fe843503          	ld	a0,-24(s0)
ffffffffc0207e72:	c939                	beqz	a0,ffffffffc0207ec8 <vfs_mount+0xb4>
ffffffffc0207e74:	4d38                	lw	a4,88(a0)
ffffffffc0207e76:	6785                	lui	a5,0x1
ffffffffc0207e78:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0207e7c:	04f71663          	bne	a4,a5,ffffffffc0207ec8 <vfs_mount+0xb4>
ffffffffc0207e80:	ff040593          	addi	a1,s0,-16
ffffffffc0207e84:	9982                	jalr	s3
ffffffffc0207e86:	84aa                	mv	s1,a0
ffffffffc0207e88:	ed01                	bnez	a0,ffffffffc0207ea0 <vfs_mount+0x8c>
ffffffffc0207e8a:	ff043783          	ld	a5,-16(s0)
ffffffffc0207e8e:	cfad                	beqz	a5,ffffffffc0207f08 <vfs_mount+0xf4>
ffffffffc0207e90:	fe043583          	ld	a1,-32(s0)
ffffffffc0207e94:	00007517          	auipc	a0,0x7
ffffffffc0207e98:	d2c50513          	addi	a0,a0,-724 # ffffffffc020ebc0 <syscalls+0xb60>
ffffffffc0207e9c:	b0af80ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0207ea0:	0008e517          	auipc	a0,0x8e
ffffffffc0207ea4:	98850513          	addi	a0,a0,-1656 # ffffffffc0295828 <vdev_list_sem>
ffffffffc0207ea8:	eb8fc0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0207eac:	70a2                	ld	ra,40(sp)
ffffffffc0207eae:	7402                	ld	s0,32(sp)
ffffffffc0207eb0:	6942                	ld	s2,16(sp)
ffffffffc0207eb2:	69a2                	ld	s3,8(sp)
ffffffffc0207eb4:	8526                	mv	a0,s1
ffffffffc0207eb6:	64e2                	ld	s1,24(sp)
ffffffffc0207eb8:	6145                	addi	sp,sp,48
ffffffffc0207eba:	8082                	ret
ffffffffc0207ebc:	54cd                	li	s1,-13
ffffffffc0207ebe:	b7cd                	j	ffffffffc0207ea0 <vfs_mount+0x8c>
ffffffffc0207ec0:	54c5                	li	s1,-15
ffffffffc0207ec2:	bff9                	j	ffffffffc0207ea0 <vfs_mount+0x8c>
ffffffffc0207ec4:	db3ff0ef          	jal	ra,ffffffffc0207c76 <find_mount.part.0>
ffffffffc0207ec8:	00007697          	auipc	a3,0x7
ffffffffc0207ecc:	ca868693          	addi	a3,a3,-856 # ffffffffc020eb70 <syscalls+0xb10>
ffffffffc0207ed0:	00004617          	auipc	a2,0x4
ffffffffc0207ed4:	01860613          	addi	a2,a2,24 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207ed8:	0ed00593          	li	a1,237
ffffffffc0207edc:	00007517          	auipc	a0,0x7
ffffffffc0207ee0:	bdc50513          	addi	a0,a0,-1060 # ffffffffc020eab8 <syscalls+0xa58>
ffffffffc0207ee4:	dbaf80ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0207ee8:	00007697          	auipc	a3,0x7
ffffffffc0207eec:	c5868693          	addi	a3,a3,-936 # ffffffffc020eb40 <syscalls+0xae0>
ffffffffc0207ef0:	00004617          	auipc	a2,0x4
ffffffffc0207ef4:	ff860613          	addi	a2,a2,-8 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207ef8:	0eb00593          	li	a1,235
ffffffffc0207efc:	00007517          	auipc	a0,0x7
ffffffffc0207f00:	bbc50513          	addi	a0,a0,-1092 # ffffffffc020eab8 <syscalls+0xa58>
ffffffffc0207f04:	d9af80ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0207f08:	00007697          	auipc	a3,0x7
ffffffffc0207f0c:	ca068693          	addi	a3,a3,-864 # ffffffffc020eba8 <syscalls+0xb48>
ffffffffc0207f10:	00004617          	auipc	a2,0x4
ffffffffc0207f14:	fd860613          	addi	a2,a2,-40 # ffffffffc020bee8 <commands+0x210>
ffffffffc0207f18:	0ef00593          	li	a1,239
ffffffffc0207f1c:	00007517          	auipc	a0,0x7
ffffffffc0207f20:	b9c50513          	addi	a0,a0,-1124 # ffffffffc020eab8 <syscalls+0xa58>
ffffffffc0207f24:	d7af80ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0207f28 <vfs_open>:
ffffffffc0207f28:	711d                	addi	sp,sp,-96
ffffffffc0207f2a:	e4a6                	sd	s1,72(sp)
ffffffffc0207f2c:	e0ca                	sd	s2,64(sp)
ffffffffc0207f2e:	fc4e                	sd	s3,56(sp)
ffffffffc0207f30:	ec86                	sd	ra,88(sp)
ffffffffc0207f32:	e8a2                	sd	s0,80(sp)
ffffffffc0207f34:	f852                	sd	s4,48(sp)
ffffffffc0207f36:	f456                	sd	s5,40(sp)
ffffffffc0207f38:	0035f793          	andi	a5,a1,3
ffffffffc0207f3c:	84ae                	mv	s1,a1
ffffffffc0207f3e:	892a                	mv	s2,a0
ffffffffc0207f40:	89b2                	mv	s3,a2
ffffffffc0207f42:	0e078663          	beqz	a5,ffffffffc020802e <vfs_open+0x106>
ffffffffc0207f46:	470d                	li	a4,3
ffffffffc0207f48:	0105fa93          	andi	s5,a1,16
ffffffffc0207f4c:	0ce78f63          	beq	a5,a4,ffffffffc020802a <vfs_open+0x102>
ffffffffc0207f50:	002c                	addi	a1,sp,8
ffffffffc0207f52:	854a                	mv	a0,s2
ffffffffc0207f54:	60a000ef          	jal	ra,ffffffffc020855e <vfs_lookup>
ffffffffc0207f58:	842a                	mv	s0,a0
ffffffffc0207f5a:	0044fa13          	andi	s4,s1,4
ffffffffc0207f5e:	e159                	bnez	a0,ffffffffc0207fe4 <vfs_open+0xbc>
ffffffffc0207f60:	00c4f793          	andi	a5,s1,12
ffffffffc0207f64:	4731                	li	a4,12
ffffffffc0207f66:	0ee78263          	beq	a5,a4,ffffffffc020804a <vfs_open+0x122>
ffffffffc0207f6a:	6422                	ld	s0,8(sp)
ffffffffc0207f6c:	12040163          	beqz	s0,ffffffffc020808e <vfs_open+0x166>
ffffffffc0207f70:	783c                	ld	a5,112(s0)
ffffffffc0207f72:	cff1                	beqz	a5,ffffffffc020804e <vfs_open+0x126>
ffffffffc0207f74:	679c                	ld	a5,8(a5)
ffffffffc0207f76:	cfe1                	beqz	a5,ffffffffc020804e <vfs_open+0x126>
ffffffffc0207f78:	8522                	mv	a0,s0
ffffffffc0207f7a:	00007597          	auipc	a1,0x7
ffffffffc0207f7e:	d2658593          	addi	a1,a1,-730 # ffffffffc020eca0 <syscalls+0xc40>
ffffffffc0207f82:	8c3ff0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0207f86:	783c                	ld	a5,112(s0)
ffffffffc0207f88:	6522                	ld	a0,8(sp)
ffffffffc0207f8a:	85a6                	mv	a1,s1
ffffffffc0207f8c:	679c                	ld	a5,8(a5)
ffffffffc0207f8e:	9782                	jalr	a5
ffffffffc0207f90:	842a                	mv	s0,a0
ffffffffc0207f92:	6522                	ld	a0,8(sp)
ffffffffc0207f94:	e845                	bnez	s0,ffffffffc0208044 <vfs_open+0x11c>
ffffffffc0207f96:	015a6a33          	or	s4,s4,s5
ffffffffc0207f9a:	89fff0ef          	jal	ra,ffffffffc0207838 <inode_open_inc>
ffffffffc0207f9e:	020a0663          	beqz	s4,ffffffffc0207fca <vfs_open+0xa2>
ffffffffc0207fa2:	64a2                	ld	s1,8(sp)
ffffffffc0207fa4:	c4e9                	beqz	s1,ffffffffc020806e <vfs_open+0x146>
ffffffffc0207fa6:	78bc                	ld	a5,112(s1)
ffffffffc0207fa8:	c3f9                	beqz	a5,ffffffffc020806e <vfs_open+0x146>
ffffffffc0207faa:	73bc                	ld	a5,96(a5)
ffffffffc0207fac:	c3e9                	beqz	a5,ffffffffc020806e <vfs_open+0x146>
ffffffffc0207fae:	00007597          	auipc	a1,0x7
ffffffffc0207fb2:	d5258593          	addi	a1,a1,-686 # ffffffffc020ed00 <syscalls+0xca0>
ffffffffc0207fb6:	8526                	mv	a0,s1
ffffffffc0207fb8:	88dff0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0207fbc:	78bc                	ld	a5,112(s1)
ffffffffc0207fbe:	6522                	ld	a0,8(sp)
ffffffffc0207fc0:	4581                	li	a1,0
ffffffffc0207fc2:	73bc                	ld	a5,96(a5)
ffffffffc0207fc4:	9782                	jalr	a5
ffffffffc0207fc6:	87aa                	mv	a5,a0
ffffffffc0207fc8:	e92d                	bnez	a0,ffffffffc020803a <vfs_open+0x112>
ffffffffc0207fca:	67a2                	ld	a5,8(sp)
ffffffffc0207fcc:	00f9b023          	sd	a5,0(s3)
ffffffffc0207fd0:	60e6                	ld	ra,88(sp)
ffffffffc0207fd2:	8522                	mv	a0,s0
ffffffffc0207fd4:	6446                	ld	s0,80(sp)
ffffffffc0207fd6:	64a6                	ld	s1,72(sp)
ffffffffc0207fd8:	6906                	ld	s2,64(sp)
ffffffffc0207fda:	79e2                	ld	s3,56(sp)
ffffffffc0207fdc:	7a42                	ld	s4,48(sp)
ffffffffc0207fde:	7aa2                	ld	s5,40(sp)
ffffffffc0207fe0:	6125                	addi	sp,sp,96
ffffffffc0207fe2:	8082                	ret
ffffffffc0207fe4:	57c1                	li	a5,-16
ffffffffc0207fe6:	fef515e3          	bne	a0,a5,ffffffffc0207fd0 <vfs_open+0xa8>
ffffffffc0207fea:	fe0a03e3          	beqz	s4,ffffffffc0207fd0 <vfs_open+0xa8>
ffffffffc0207fee:	0810                	addi	a2,sp,16
ffffffffc0207ff0:	082c                	addi	a1,sp,24
ffffffffc0207ff2:	854a                	mv	a0,s2
ffffffffc0207ff4:	572000ef          	jal	ra,ffffffffc0208566 <vfs_lookup_parent>
ffffffffc0207ff8:	842a                	mv	s0,a0
ffffffffc0207ffa:	f979                	bnez	a0,ffffffffc0207fd0 <vfs_open+0xa8>
ffffffffc0207ffc:	6462                	ld	s0,24(sp)
ffffffffc0207ffe:	c845                	beqz	s0,ffffffffc02080ae <vfs_open+0x186>
ffffffffc0208000:	783c                	ld	a5,112(s0)
ffffffffc0208002:	c7d5                	beqz	a5,ffffffffc02080ae <vfs_open+0x186>
ffffffffc0208004:	77bc                	ld	a5,104(a5)
ffffffffc0208006:	c7c5                	beqz	a5,ffffffffc02080ae <vfs_open+0x186>
ffffffffc0208008:	8522                	mv	a0,s0
ffffffffc020800a:	00007597          	auipc	a1,0x7
ffffffffc020800e:	c2e58593          	addi	a1,a1,-978 # ffffffffc020ec38 <syscalls+0xbd8>
ffffffffc0208012:	833ff0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0208016:	783c                	ld	a5,112(s0)
ffffffffc0208018:	65c2                	ld	a1,16(sp)
ffffffffc020801a:	6562                	ld	a0,24(sp)
ffffffffc020801c:	77bc                	ld	a5,104(a5)
ffffffffc020801e:	4034d613          	srai	a2,s1,0x3
ffffffffc0208022:	0034                	addi	a3,sp,8
ffffffffc0208024:	8a05                	andi	a2,a2,1
ffffffffc0208026:	9782                	jalr	a5
ffffffffc0208028:	b789                	j	ffffffffc0207f6a <vfs_open+0x42>
ffffffffc020802a:	5475                	li	s0,-3
ffffffffc020802c:	b755                	j	ffffffffc0207fd0 <vfs_open+0xa8>
ffffffffc020802e:	0105fa93          	andi	s5,a1,16
ffffffffc0208032:	5475                	li	s0,-3
ffffffffc0208034:	f80a9ee3          	bnez	s5,ffffffffc0207fd0 <vfs_open+0xa8>
ffffffffc0208038:	bf21                	j	ffffffffc0207f50 <vfs_open+0x28>
ffffffffc020803a:	6522                	ld	a0,8(sp)
ffffffffc020803c:	843e                	mv	s0,a5
ffffffffc020803e:	965ff0ef          	jal	ra,ffffffffc02079a2 <inode_open_dec>
ffffffffc0208042:	6522                	ld	a0,8(sp)
ffffffffc0208044:	8b7ff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc0208048:	b761                	j	ffffffffc0207fd0 <vfs_open+0xa8>
ffffffffc020804a:	5425                	li	s0,-23
ffffffffc020804c:	b751                	j	ffffffffc0207fd0 <vfs_open+0xa8>
ffffffffc020804e:	00007697          	auipc	a3,0x7
ffffffffc0208052:	c0268693          	addi	a3,a3,-1022 # ffffffffc020ec50 <syscalls+0xbf0>
ffffffffc0208056:	00004617          	auipc	a2,0x4
ffffffffc020805a:	e9260613          	addi	a2,a2,-366 # ffffffffc020bee8 <commands+0x210>
ffffffffc020805e:	03200593          	li	a1,50
ffffffffc0208062:	00007517          	auipc	a0,0x7
ffffffffc0208066:	bbe50513          	addi	a0,a0,-1090 # ffffffffc020ec20 <syscalls+0xbc0>
ffffffffc020806a:	c34f80ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020806e:	00007697          	auipc	a3,0x7
ffffffffc0208072:	c3a68693          	addi	a3,a3,-966 # ffffffffc020eca8 <syscalls+0xc48>
ffffffffc0208076:	00004617          	auipc	a2,0x4
ffffffffc020807a:	e7260613          	addi	a2,a2,-398 # ffffffffc020bee8 <commands+0x210>
ffffffffc020807e:	03900593          	li	a1,57
ffffffffc0208082:	00007517          	auipc	a0,0x7
ffffffffc0208086:	b9e50513          	addi	a0,a0,-1122 # ffffffffc020ec20 <syscalls+0xbc0>
ffffffffc020808a:	c14f80ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020808e:	00007697          	auipc	a3,0x7
ffffffffc0208092:	bb268693          	addi	a3,a3,-1102 # ffffffffc020ec40 <syscalls+0xbe0>
ffffffffc0208096:	00004617          	auipc	a2,0x4
ffffffffc020809a:	e5260613          	addi	a2,a2,-430 # ffffffffc020bee8 <commands+0x210>
ffffffffc020809e:	03000593          	li	a1,48
ffffffffc02080a2:	00007517          	auipc	a0,0x7
ffffffffc02080a6:	b7e50513          	addi	a0,a0,-1154 # ffffffffc020ec20 <syscalls+0xbc0>
ffffffffc02080aa:	bf4f80ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02080ae:	00007697          	auipc	a3,0x7
ffffffffc02080b2:	b2268693          	addi	a3,a3,-1246 # ffffffffc020ebd0 <syscalls+0xb70>
ffffffffc02080b6:	00004617          	auipc	a2,0x4
ffffffffc02080ba:	e3260613          	addi	a2,a2,-462 # ffffffffc020bee8 <commands+0x210>
ffffffffc02080be:	02b00593          	li	a1,43
ffffffffc02080c2:	00007517          	auipc	a0,0x7
ffffffffc02080c6:	b5e50513          	addi	a0,a0,-1186 # ffffffffc020ec20 <syscalls+0xbc0>
ffffffffc02080ca:	bd4f80ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02080ce <vfs_close>:
ffffffffc02080ce:	1141                	addi	sp,sp,-16
ffffffffc02080d0:	e406                	sd	ra,8(sp)
ffffffffc02080d2:	e022                	sd	s0,0(sp)
ffffffffc02080d4:	842a                	mv	s0,a0
ffffffffc02080d6:	8cdff0ef          	jal	ra,ffffffffc02079a2 <inode_open_dec>
ffffffffc02080da:	8522                	mv	a0,s0
ffffffffc02080dc:	81fff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc02080e0:	60a2                	ld	ra,8(sp)
ffffffffc02080e2:	6402                	ld	s0,0(sp)
ffffffffc02080e4:	4501                	li	a0,0
ffffffffc02080e6:	0141                	addi	sp,sp,16
ffffffffc02080e8:	8082                	ret

ffffffffc02080ea <get_device>:
ffffffffc02080ea:	7179                	addi	sp,sp,-48
ffffffffc02080ec:	ec26                	sd	s1,24(sp)
ffffffffc02080ee:	e84a                	sd	s2,16(sp)
ffffffffc02080f0:	f406                	sd	ra,40(sp)
ffffffffc02080f2:	f022                	sd	s0,32(sp)
ffffffffc02080f4:	00054303          	lbu	t1,0(a0)
ffffffffc02080f8:	892e                	mv	s2,a1
ffffffffc02080fa:	84b2                	mv	s1,a2
ffffffffc02080fc:	02030463          	beqz	t1,ffffffffc0208124 <get_device+0x3a>
ffffffffc0208100:	00150413          	addi	s0,a0,1
ffffffffc0208104:	86a2                	mv	a3,s0
ffffffffc0208106:	879a                	mv	a5,t1
ffffffffc0208108:	4701                	li	a4,0
ffffffffc020810a:	03a00813          	li	a6,58
ffffffffc020810e:	02f00893          	li	a7,47
ffffffffc0208112:	03078263          	beq	a5,a6,ffffffffc0208136 <get_device+0x4c>
ffffffffc0208116:	05178963          	beq	a5,a7,ffffffffc0208168 <get_device+0x7e>
ffffffffc020811a:	0006c783          	lbu	a5,0(a3)
ffffffffc020811e:	2705                	addiw	a4,a4,1
ffffffffc0208120:	0685                	addi	a3,a3,1
ffffffffc0208122:	fbe5                	bnez	a5,ffffffffc0208112 <get_device+0x28>
ffffffffc0208124:	7402                	ld	s0,32(sp)
ffffffffc0208126:	00a93023          	sd	a0,0(s2)
ffffffffc020812a:	70a2                	ld	ra,40(sp)
ffffffffc020812c:	6942                	ld	s2,16(sp)
ffffffffc020812e:	8526                	mv	a0,s1
ffffffffc0208130:	64e2                	ld	s1,24(sp)
ffffffffc0208132:	6145                	addi	sp,sp,48
ffffffffc0208134:	a92d                	j	ffffffffc020856e <vfs_get_curdir>
ffffffffc0208136:	cb15                	beqz	a4,ffffffffc020816a <get_device+0x80>
ffffffffc0208138:	00e507b3          	add	a5,a0,a4
ffffffffc020813c:	0705                	addi	a4,a4,1
ffffffffc020813e:	00078023          	sb	zero,0(a5)
ffffffffc0208142:	972a                	add	a4,a4,a0
ffffffffc0208144:	02f00613          	li	a2,47
ffffffffc0208148:	00074783          	lbu	a5,0(a4)
ffffffffc020814c:	86ba                	mv	a3,a4
ffffffffc020814e:	0705                	addi	a4,a4,1
ffffffffc0208150:	fec78ce3          	beq	a5,a2,ffffffffc0208148 <get_device+0x5e>
ffffffffc0208154:	7402                	ld	s0,32(sp)
ffffffffc0208156:	70a2                	ld	ra,40(sp)
ffffffffc0208158:	00d93023          	sd	a3,0(s2)
ffffffffc020815c:	85a6                	mv	a1,s1
ffffffffc020815e:	6942                	ld	s2,16(sp)
ffffffffc0208160:	64e2                	ld	s1,24(sp)
ffffffffc0208162:	6145                	addi	sp,sp,48
ffffffffc0208164:	ba9ff06f          	j	ffffffffc0207d0c <vfs_get_root>
ffffffffc0208168:	ff55                	bnez	a4,ffffffffc0208124 <get_device+0x3a>
ffffffffc020816a:	02f00793          	li	a5,47
ffffffffc020816e:	04f30563          	beq	t1,a5,ffffffffc02081b8 <get_device+0xce>
ffffffffc0208172:	03a00793          	li	a5,58
ffffffffc0208176:	06f31663          	bne	t1,a5,ffffffffc02081e2 <get_device+0xf8>
ffffffffc020817a:	0028                	addi	a0,sp,8
ffffffffc020817c:	3f2000ef          	jal	ra,ffffffffc020856e <vfs_get_curdir>
ffffffffc0208180:	e515                	bnez	a0,ffffffffc02081ac <get_device+0xc2>
ffffffffc0208182:	67a2                	ld	a5,8(sp)
ffffffffc0208184:	77a8                	ld	a0,104(a5)
ffffffffc0208186:	cd15                	beqz	a0,ffffffffc02081c2 <get_device+0xd8>
ffffffffc0208188:	617c                	ld	a5,192(a0)
ffffffffc020818a:	9782                	jalr	a5
ffffffffc020818c:	87aa                	mv	a5,a0
ffffffffc020818e:	6522                	ld	a0,8(sp)
ffffffffc0208190:	e09c                	sd	a5,0(s1)
ffffffffc0208192:	f68ff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc0208196:	02f00713          	li	a4,47
ffffffffc020819a:	a011                	j	ffffffffc020819e <get_device+0xb4>
ffffffffc020819c:	0405                	addi	s0,s0,1
ffffffffc020819e:	00044783          	lbu	a5,0(s0)
ffffffffc02081a2:	fee78de3          	beq	a5,a4,ffffffffc020819c <get_device+0xb2>
ffffffffc02081a6:	00893023          	sd	s0,0(s2)
ffffffffc02081aa:	4501                	li	a0,0
ffffffffc02081ac:	70a2                	ld	ra,40(sp)
ffffffffc02081ae:	7402                	ld	s0,32(sp)
ffffffffc02081b0:	64e2                	ld	s1,24(sp)
ffffffffc02081b2:	6942                	ld	s2,16(sp)
ffffffffc02081b4:	6145                	addi	sp,sp,48
ffffffffc02081b6:	8082                	ret
ffffffffc02081b8:	8526                	mv	a0,s1
ffffffffc02081ba:	93fff0ef          	jal	ra,ffffffffc0207af8 <vfs_get_bootfs>
ffffffffc02081be:	dd61                	beqz	a0,ffffffffc0208196 <get_device+0xac>
ffffffffc02081c0:	b7f5                	j	ffffffffc02081ac <get_device+0xc2>
ffffffffc02081c2:	00007697          	auipc	a3,0x7
ffffffffc02081c6:	b7668693          	addi	a3,a3,-1162 # ffffffffc020ed38 <syscalls+0xcd8>
ffffffffc02081ca:	00004617          	auipc	a2,0x4
ffffffffc02081ce:	d1e60613          	addi	a2,a2,-738 # ffffffffc020bee8 <commands+0x210>
ffffffffc02081d2:	03d00593          	li	a1,61
ffffffffc02081d6:	00007517          	auipc	a0,0x7
ffffffffc02081da:	b4a50513          	addi	a0,a0,-1206 # ffffffffc020ed20 <syscalls+0xcc0>
ffffffffc02081de:	ac0f80ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02081e2:	00007697          	auipc	a3,0x7
ffffffffc02081e6:	b2e68693          	addi	a3,a3,-1234 # ffffffffc020ed10 <syscalls+0xcb0>
ffffffffc02081ea:	00004617          	auipc	a2,0x4
ffffffffc02081ee:	cfe60613          	addi	a2,a2,-770 # ffffffffc020bee8 <commands+0x210>
ffffffffc02081f2:	03700593          	li	a1,55
ffffffffc02081f6:	00007517          	auipc	a0,0x7
ffffffffc02081fa:	b2a50513          	addi	a0,a0,-1238 # ffffffffc020ed20 <syscalls+0xcc0>
ffffffffc02081fe:	aa0f80ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0208202 <vfs_lookup_internal>:
ffffffffc0208202:	7155                	addi	sp,sp,-208
ffffffffc0208204:	f54e                	sd	s3,168(sp)
ffffffffc0208206:	f8ea                	sd	s10,112(sp)
ffffffffc0208208:	89b2                	mv	s3,a2
ffffffffc020820a:	8d2e                	mv	s10,a1
ffffffffc020820c:	1030                	addi	a2,sp,40
ffffffffc020820e:	082c                	addi	a1,sp,24
ffffffffc0208210:	ed56                	sd	s5,152(sp)
ffffffffc0208212:	e586                	sd	ra,200(sp)
ffffffffc0208214:	e1a2                	sd	s0,192(sp)
ffffffffc0208216:	fd26                	sd	s1,184(sp)
ffffffffc0208218:	f94a                	sd	s2,176(sp)
ffffffffc020821a:	f152                	sd	s4,160(sp)
ffffffffc020821c:	e95a                	sd	s6,144(sp)
ffffffffc020821e:	e55e                	sd	s7,136(sp)
ffffffffc0208220:	e162                	sd	s8,128(sp)
ffffffffc0208222:	fce6                	sd	s9,120(sp)
ffffffffc0208224:	f4ee                	sd	s11,104(sp)
ffffffffc0208226:	ec2a                	sd	a0,24(sp)
ffffffffc0208228:	e46a                	sd	s10,8(sp)
ffffffffc020822a:	e836                	sd	a3,16(sp)
ffffffffc020822c:	ebfff0ef          	jal	ra,ffffffffc02080ea <get_device>
ffffffffc0208230:	8aaa                	mv	s5,a0
ffffffffc0208232:	c10d                	beqz	a0,ffffffffc0208254 <vfs_lookup_internal+0x52>
ffffffffc0208234:	60ae                	ld	ra,200(sp)
ffffffffc0208236:	640e                	ld	s0,192(sp)
ffffffffc0208238:	74ea                	ld	s1,184(sp)
ffffffffc020823a:	794a                	ld	s2,176(sp)
ffffffffc020823c:	79aa                	ld	s3,168(sp)
ffffffffc020823e:	7a0a                	ld	s4,160(sp)
ffffffffc0208240:	6b4a                	ld	s6,144(sp)
ffffffffc0208242:	6baa                	ld	s7,136(sp)
ffffffffc0208244:	6c0a                	ld	s8,128(sp)
ffffffffc0208246:	7ce6                	ld	s9,120(sp)
ffffffffc0208248:	7d46                	ld	s10,112(sp)
ffffffffc020824a:	7da6                	ld	s11,104(sp)
ffffffffc020824c:	8556                	mv	a0,s5
ffffffffc020824e:	6aea                	ld	s5,152(sp)
ffffffffc0208250:	6169                	addi	sp,sp,208
ffffffffc0208252:	8082                	ret
ffffffffc0208254:	6505                	lui	a0,0x1
ffffffffc0208256:	d39f90ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc020825a:	84aa                	mv	s1,a0
ffffffffc020825c:	2c050c63          	beqz	a0,ffffffffc0208534 <vfs_lookup_internal+0x332>
ffffffffc0208260:	6562                	ld	a0,24(sp)
ffffffffc0208262:	6d8030ef          	jal	ra,ffffffffc020b93a <strlen>
ffffffffc0208266:	6785                	lui	a5,0x1
ffffffffc0208268:	26f57e63          	bgeu	a0,a5,ffffffffc02084e4 <vfs_lookup_internal+0x2e2>
ffffffffc020826c:	65e2                	ld	a1,24(sp)
ffffffffc020826e:	8526                	mv	a0,s1
ffffffffc0208270:	4a01                	li	s4,0
ffffffffc0208272:	6fe030ef          	jal	ra,ffffffffc020b970 <strcpy>
ffffffffc0208276:	0004c783          	lbu	a5,0(s1)
ffffffffc020827a:	8926                	mv	s2,s1
ffffffffc020827c:	1e078963          	beqz	a5,ffffffffc020846e <vfs_lookup_internal+0x26c>
ffffffffc0208280:	00007b17          	auipc	s6,0x7
ffffffffc0208284:	b20b0b13          	addi	s6,s6,-1248 # ffffffffc020eda0 <syscalls+0xd40>
ffffffffc0208288:	00007b97          	auipc	s7,0x7
ffffffffc020828c:	b70b8b93          	addi	s7,s7,-1168 # ffffffffc020edf8 <syscalls+0xd98>
ffffffffc0208290:	6c0d                	lui	s8,0x3
ffffffffc0208292:	4d95                	li	s11,5
ffffffffc0208294:	aa21                	j	ffffffffc02083ac <vfs_lookup_internal+0x1aa>
ffffffffc0208296:	14099b63          	bnez	s3,ffffffffc02083ec <vfs_lookup_internal+0x1ea>
ffffffffc020829a:	7422                	ld	s0,40(sp)
ffffffffc020829c:	24040c63          	beqz	s0,ffffffffc02084f4 <vfs_lookup_internal+0x2f2>
ffffffffc02082a0:	7838                	ld	a4,112(s0)
ffffffffc02082a2:	24070963          	beqz	a4,ffffffffc02084f4 <vfs_lookup_internal+0x2f2>
ffffffffc02082a6:	7b38                	ld	a4,112(a4)
ffffffffc02082a8:	24070663          	beqz	a4,ffffffffc02084f4 <vfs_lookup_internal+0x2f2>
ffffffffc02082ac:	85da                	mv	a1,s6
ffffffffc02082ae:	8522                	mv	a0,s0
ffffffffc02082b0:	d94ff0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc02082b4:	7838                	ld	a4,112(s0)
ffffffffc02082b6:	7522                	ld	a0,40(sp)
ffffffffc02082b8:	1810                	addi	a2,sp,48
ffffffffc02082ba:	7b38                	ld	a4,112(a4)
ffffffffc02082bc:	85ca                	mv	a1,s2
ffffffffc02082be:	9702                	jalr	a4
ffffffffc02082c0:	1c051563          	bnez	a0,ffffffffc020848a <vfs_lookup_internal+0x288>
ffffffffc02082c4:	7442                	ld	s0,48(sp)
ffffffffc02082c6:	24040763          	beqz	s0,ffffffffc0208514 <vfs_lookup_internal+0x312>
ffffffffc02082ca:	7838                	ld	a4,112(s0)
ffffffffc02082cc:	24070463          	beqz	a4,ffffffffc0208514 <vfs_lookup_internal+0x312>
ffffffffc02082d0:	6b38                	ld	a4,80(a4)
ffffffffc02082d2:	24070163          	beqz	a4,ffffffffc0208514 <vfs_lookup_internal+0x312>
ffffffffc02082d6:	85de                	mv	a1,s7
ffffffffc02082d8:	8522                	mv	a0,s0
ffffffffc02082da:	d6aff0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc02082de:	7838                	ld	a4,112(s0)
ffffffffc02082e0:	7542                	ld	a0,48(sp)
ffffffffc02082e2:	104c                	addi	a1,sp,36
ffffffffc02082e4:	6b38                	ld	a4,80(a4)
ffffffffc02082e6:	9702                	jalr	a4
ffffffffc02082e8:	872a                	mv	a4,a0
ffffffffc02082ea:	18051a63          	bnez	a0,ffffffffc020847e <vfs_lookup_internal+0x27c>
ffffffffc02082ee:	5712                	lw	a4,36(sp)
ffffffffc02082f0:	11871e63          	bne	a4,s8,ffffffffc020840c <vfs_lookup_internal+0x20a>
ffffffffc02082f4:	2a05                	addiw	s4,s4,1
ffffffffc02082f6:	194dcd63          	blt	s11,s4,ffffffffc0208490 <vfs_lookup_internal+0x28e>
ffffffffc02082fa:	6505                	lui	a0,0x1
ffffffffc02082fc:	c93f90ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc0208300:	842a                	mv	s0,a0
ffffffffc0208302:	1a050963          	beqz	a0,ffffffffc02084b4 <vfs_lookup_internal+0x2b2>
ffffffffc0208306:	6605                	lui	a2,0x1
ffffffffc0208308:	85aa                	mv	a1,a0
ffffffffc020830a:	4681                	li	a3,0
ffffffffc020830c:	167d                	addi	a2,a2,-1
ffffffffc020830e:	0088                	addi	a0,sp,64
ffffffffc0208310:	8d2fd0ef          	jal	ra,ffffffffc02053e2 <iobuf_init>
ffffffffc0208314:	7942                	ld	s2,48(sp)
ffffffffc0208316:	8d2a                	mv	s10,a0
ffffffffc0208318:	22090363          	beqz	s2,ffffffffc020853e <vfs_lookup_internal+0x33c>
ffffffffc020831c:	07093683          	ld	a3,112(s2)
ffffffffc0208320:	20068f63          	beqz	a3,ffffffffc020853e <vfs_lookup_internal+0x33c>
ffffffffc0208324:	6e94                	ld	a3,24(a3)
ffffffffc0208326:	20068c63          	beqz	a3,ffffffffc020853e <vfs_lookup_internal+0x33c>
ffffffffc020832a:	854a                	mv	a0,s2
ffffffffc020832c:	00005597          	auipc	a1,0x5
ffffffffc0208330:	43c58593          	addi	a1,a1,1084 # ffffffffc020d768 <default_pmm_manager+0xd98>
ffffffffc0208334:	d10ff0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0208338:	07093683          	ld	a3,112(s2)
ffffffffc020833c:	7542                	ld	a0,48(sp)
ffffffffc020833e:	85ea                	mv	a1,s10
ffffffffc0208340:	6e94                	ld	a3,24(a3)
ffffffffc0208342:	9682                	jalr	a3
ffffffffc0208344:	892a                	mv	s2,a0
ffffffffc0208346:	7542                	ld	a0,48(sp)
ffffffffc0208348:	db2ff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc020834c:	14091e63          	bnez	s2,ffffffffc02084a8 <vfs_lookup_internal+0x2a6>
ffffffffc0208350:	010d3683          	ld	a3,16(s10)
ffffffffc0208354:	018d3703          	ld	a4,24(s10)
ffffffffc0208358:	02f00613          	li	a2,47
ffffffffc020835c:	8522                	mv	a0,s0
ffffffffc020835e:	40e68733          	sub	a4,a3,a4
ffffffffc0208362:	9722                	add	a4,a4,s0
ffffffffc0208364:	00070023          	sb	zero,0(a4)
ffffffffc0208368:	fc22                	sd	s0,56(sp)
ffffffffc020836a:	00044703          	lbu	a4,0(s0)
ffffffffc020836e:	0cc70863          	beq	a4,a2,ffffffffc020843e <vfs_lookup_internal+0x23c>
ffffffffc0208372:	5c8030ef          	jal	ra,ffffffffc020b93a <strlen>
ffffffffc0208376:	0005091b          	sext.w	s2,a0
ffffffffc020837a:	0a0c8263          	beqz	s9,ffffffffc020841e <vfs_lookup_internal+0x21c>
ffffffffc020837e:	8566                	mv	a0,s9
ffffffffc0208380:	5ba030ef          	jal	ra,ffffffffc020b93a <strlen>
ffffffffc0208384:	2909                	addiw	s2,s2,2
ffffffffc0208386:	00a9093b          	addw	s2,s2,a0
ffffffffc020838a:	6705                	lui	a4,0x1
ffffffffc020838c:	08e95e63          	bge	s2,a4,ffffffffc0208428 <vfs_lookup_internal+0x226>
ffffffffc0208390:	000cc703          	lbu	a4,0(s9)
ffffffffc0208394:	e369                	bnez	a4,ffffffffc0208456 <vfs_lookup_internal+0x254>
ffffffffc0208396:	75e2                	ld	a1,56(sp)
ffffffffc0208398:	8526                	mv	a0,s1
ffffffffc020839a:	8926                	mv	s2,s1
ffffffffc020839c:	5d4030ef          	jal	ra,ffffffffc020b970 <strcpy>
ffffffffc02083a0:	8522                	mv	a0,s0
ffffffffc02083a2:	c9df90ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc02083a6:	00094783          	lbu	a5,0(s2)
ffffffffc02083aa:	c3f1                	beqz	a5,ffffffffc020846e <vfs_lookup_internal+0x26c>
ffffffffc02083ac:	02f00593          	li	a1,47
ffffffffc02083b0:	854a                	mv	a0,s2
ffffffffc02083b2:	63c030ef          	jal	ra,ffffffffc020b9ee <strchr>
ffffffffc02083b6:	8caa                	mv	s9,a0
ffffffffc02083b8:	ec050fe3          	beqz	a0,ffffffffc0208296 <vfs_lookup_internal+0x94>
ffffffffc02083bc:	00154683          	lbu	a3,1(a0) # 1001 <_binary_bin_swap_img_size-0x6cff>
ffffffffc02083c0:	00150793          	addi	a5,a0,1
ffffffffc02083c4:	00050023          	sb	zero,0(a0)
ffffffffc02083c8:	02f00713          	li	a4,47
ffffffffc02083cc:	8cbe                	mv	s9,a5
ffffffffc02083ce:	00e69963          	bne	a3,a4,ffffffffc02083e0 <vfs_lookup_internal+0x1de>
ffffffffc02083d2:	02f00693          	li	a3,47
ffffffffc02083d6:	001cc703          	lbu	a4,1(s9)
ffffffffc02083da:	0c85                	addi	s9,s9,1
ffffffffc02083dc:	fed70de3          	beq	a4,a3,ffffffffc02083d6 <vfs_lookup_internal+0x1d4>
ffffffffc02083e0:	ea098de3          	beqz	s3,ffffffffc020829a <vfs_lookup_internal+0x98>
ffffffffc02083e4:	000cc703          	lbu	a4,0(s9)
ffffffffc02083e8:	ea0719e3          	bnez	a4,ffffffffc020829a <vfs_lookup_internal+0x98>
ffffffffc02083ec:	77a2                	ld	a5,40(sp)
ffffffffc02083ee:	6722                	ld	a4,8(sp)
ffffffffc02083f0:	6442                	ld	s0,16(sp)
ffffffffc02083f2:	6562                	ld	a0,24(sp)
ffffffffc02083f4:	e31c                	sd	a5,0(a4)
ffffffffc02083f6:	85ca                	mv	a1,s2
ffffffffc02083f8:	01243023          	sd	s2,0(s0)
ffffffffc02083fc:	574030ef          	jal	ra,ffffffffc020b970 <strcpy>
ffffffffc0208400:	67e2                	ld	a5,24(sp)
ffffffffc0208402:	8526                	mv	a0,s1
ffffffffc0208404:	e01c                	sd	a5,0(s0)
ffffffffc0208406:	c39f90ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020840a:	b52d                	j	ffffffffc0208234 <vfs_lookup_internal+0x32>
ffffffffc020840c:	7522                	ld	a0,40(sp)
ffffffffc020840e:	cecff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc0208412:	7542                	ld	a0,48(sp)
ffffffffc0208414:	f42a                	sd	a0,40(sp)
ffffffffc0208416:	080c8363          	beqz	s9,ffffffffc020849c <vfs_lookup_internal+0x29a>
ffffffffc020841a:	8966                	mv	s2,s9
ffffffffc020841c:	b769                	j	ffffffffc02083a6 <vfs_lookup_internal+0x1a4>
ffffffffc020841e:	0029051b          	addiw	a0,s2,2
ffffffffc0208422:	6785                	lui	a5,0x1
ffffffffc0208424:	f6f549e3          	blt	a0,a5,ffffffffc0208396 <vfs_lookup_internal+0x194>
ffffffffc0208428:	8522                	mv	a0,s0
ffffffffc020842a:	c15f90ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020842e:	7522                	ld	a0,40(sp)
ffffffffc0208430:	5ad1                	li	s5,-12
ffffffffc0208432:	cc8ff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc0208436:	8526                	mv	a0,s1
ffffffffc0208438:	c07f90ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020843c:	bbe5                	j	ffffffffc0208234 <vfs_lookup_internal+0x32>
ffffffffc020843e:	7522                	ld	a0,40(sp)
ffffffffc0208440:	cbaff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc0208444:	1030                	addi	a2,sp,40
ffffffffc0208446:	182c                	addi	a1,sp,56
ffffffffc0208448:	8522                	mv	a0,s0
ffffffffc020844a:	ca1ff0ef          	jal	ra,ffffffffc02080ea <get_device>
ffffffffc020844e:	892a                	mv	s2,a0
ffffffffc0208450:	e549                	bnez	a0,ffffffffc02084da <vfs_lookup_internal+0x2d8>
ffffffffc0208452:	7562                	ld	a0,56(sp)
ffffffffc0208454:	bf39                	j	ffffffffc0208372 <vfs_lookup_internal+0x170>
ffffffffc0208456:	00007597          	auipc	a1,0x7
ffffffffc020845a:	9aa58593          	addi	a1,a1,-1622 # ffffffffc020ee00 <syscalls+0xda0>
ffffffffc020845e:	8522                	mv	a0,s0
ffffffffc0208460:	522030ef          	jal	ra,ffffffffc020b982 <strcat>
ffffffffc0208464:	85e6                	mv	a1,s9
ffffffffc0208466:	8522                	mv	a0,s0
ffffffffc0208468:	51a030ef          	jal	ra,ffffffffc020b982 <strcat>
ffffffffc020846c:	b72d                	j	ffffffffc0208396 <vfs_lookup_internal+0x194>
ffffffffc020846e:	77a2                	ld	a5,40(sp)
ffffffffc0208470:	04098863          	beqz	s3,ffffffffc02084c0 <vfs_lookup_internal+0x2be>
ffffffffc0208474:	5af5                	li	s5,-3
ffffffffc0208476:	853e                	mv	a0,a5
ffffffffc0208478:	c82ff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc020847c:	bf6d                	j	ffffffffc0208436 <vfs_lookup_internal+0x234>
ffffffffc020847e:	7542                	ld	a0,48(sp)
ffffffffc0208480:	8aba                	mv	s5,a4
ffffffffc0208482:	c78ff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc0208486:	77a2                	ld	a5,40(sp)
ffffffffc0208488:	b7fd                	j	ffffffffc0208476 <vfs_lookup_internal+0x274>
ffffffffc020848a:	77a2                	ld	a5,40(sp)
ffffffffc020848c:	8aaa                	mv	s5,a0
ffffffffc020848e:	b7e5                	j	ffffffffc0208476 <vfs_lookup_internal+0x274>
ffffffffc0208490:	7542                	ld	a0,48(sp)
ffffffffc0208492:	5ad1                	li	s5,-12
ffffffffc0208494:	c66ff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc0208498:	77a2                	ld	a5,40(sp)
ffffffffc020849a:	bff1                	j	ffffffffc0208476 <vfs_lookup_internal+0x274>
ffffffffc020849c:	02098863          	beqz	s3,ffffffffc02084cc <vfs_lookup_internal+0x2ca>
ffffffffc02084a0:	c5aff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc02084a4:	5af5                	li	s5,-3
ffffffffc02084a6:	bf41                	j	ffffffffc0208436 <vfs_lookup_internal+0x234>
ffffffffc02084a8:	8522                	mv	a0,s0
ffffffffc02084aa:	b95f90ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc02084ae:	77a2                	ld	a5,40(sp)
ffffffffc02084b0:	8aca                	mv	s5,s2
ffffffffc02084b2:	b7d1                	j	ffffffffc0208476 <vfs_lookup_internal+0x274>
ffffffffc02084b4:	7542                	ld	a0,48(sp)
ffffffffc02084b6:	5af1                	li	s5,-4
ffffffffc02084b8:	c42ff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc02084bc:	77a2                	ld	a5,40(sp)
ffffffffc02084be:	bf65                	j	ffffffffc0208476 <vfs_lookup_internal+0x274>
ffffffffc02084c0:	6722                	ld	a4,8(sp)
ffffffffc02084c2:	8526                	mv	a0,s1
ffffffffc02084c4:	e31c                	sd	a5,0(a4)
ffffffffc02084c6:	b79f90ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc02084ca:	b3ad                	j	ffffffffc0208234 <vfs_lookup_internal+0x32>
ffffffffc02084cc:	67a2                	ld	a5,8(sp)
ffffffffc02084ce:	4a81                	li	s5,0
ffffffffc02084d0:	e388                	sd	a0,0(a5)
ffffffffc02084d2:	8526                	mv	a0,s1
ffffffffc02084d4:	b6bf90ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc02084d8:	bbb1                	j	ffffffffc0208234 <vfs_lookup_internal+0x32>
ffffffffc02084da:	8522                	mv	a0,s0
ffffffffc02084dc:	b63f90ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc02084e0:	8aca                	mv	s5,s2
ffffffffc02084e2:	bf91                	j	ffffffffc0208436 <vfs_lookup_internal+0x234>
ffffffffc02084e4:	7522                	ld	a0,40(sp)
ffffffffc02084e6:	5ad1                	li	s5,-12
ffffffffc02084e8:	c12ff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc02084ec:	8526                	mv	a0,s1
ffffffffc02084ee:	b51f90ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc02084f2:	b389                	j	ffffffffc0208234 <vfs_lookup_internal+0x32>
ffffffffc02084f4:	00007697          	auipc	a3,0x7
ffffffffc02084f8:	85c68693          	addi	a3,a3,-1956 # ffffffffc020ed50 <syscalls+0xcf0>
ffffffffc02084fc:	00004617          	auipc	a2,0x4
ffffffffc0208500:	9ec60613          	addi	a2,a2,-1556 # ffffffffc020bee8 <commands+0x210>
ffffffffc0208504:	09800593          	li	a1,152
ffffffffc0208508:	00007517          	auipc	a0,0x7
ffffffffc020850c:	81850513          	addi	a0,a0,-2024 # ffffffffc020ed20 <syscalls+0xcc0>
ffffffffc0208510:	f8ff70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0208514:	00007697          	auipc	a3,0x7
ffffffffc0208518:	89468693          	addi	a3,a3,-1900 # ffffffffc020eda8 <syscalls+0xd48>
ffffffffc020851c:	00004617          	auipc	a2,0x4
ffffffffc0208520:	9cc60613          	addi	a2,a2,-1588 # ffffffffc020bee8 <commands+0x210>
ffffffffc0208524:	09e00593          	li	a1,158
ffffffffc0208528:	00006517          	auipc	a0,0x6
ffffffffc020852c:	7f850513          	addi	a0,a0,2040 # ffffffffc020ed20 <syscalls+0xcc0>
ffffffffc0208530:	f6ff70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0208534:	7522                	ld	a0,40(sp)
ffffffffc0208536:	5af1                	li	s5,-4
ffffffffc0208538:	bc2ff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc020853c:	b9e5                	j	ffffffffc0208234 <vfs_lookup_internal+0x32>
ffffffffc020853e:	00005697          	auipc	a3,0x5
ffffffffc0208542:	1da68693          	addi	a3,a3,474 # ffffffffc020d718 <default_pmm_manager+0xd48>
ffffffffc0208546:	00004617          	auipc	a2,0x4
ffffffffc020854a:	9a260613          	addi	a2,a2,-1630 # ffffffffc020bee8 <commands+0x210>
ffffffffc020854e:	0b400593          	li	a1,180
ffffffffc0208552:	00006517          	auipc	a0,0x6
ffffffffc0208556:	7ce50513          	addi	a0,a0,1998 # ffffffffc020ed20 <syscalls+0xcc0>
ffffffffc020855a:	f45f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020855e <vfs_lookup>:
ffffffffc020855e:	4681                	li	a3,0
ffffffffc0208560:	4601                	li	a2,0
ffffffffc0208562:	ca1ff06f          	j	ffffffffc0208202 <vfs_lookup_internal>

ffffffffc0208566 <vfs_lookup_parent>:
ffffffffc0208566:	86b2                	mv	a3,a2
ffffffffc0208568:	4605                	li	a2,1
ffffffffc020856a:	c99ff06f          	j	ffffffffc0208202 <vfs_lookup_internal>

ffffffffc020856e <vfs_get_curdir>:
ffffffffc020856e:	0008e797          	auipc	a5,0x8e
ffffffffc0208572:	3527b783          	ld	a5,850(a5) # ffffffffc02968c0 <current>
ffffffffc0208576:	1487b783          	ld	a5,328(a5)
ffffffffc020857a:	1101                	addi	sp,sp,-32
ffffffffc020857c:	e426                	sd	s1,8(sp)
ffffffffc020857e:	6384                	ld	s1,0(a5)
ffffffffc0208580:	ec06                	sd	ra,24(sp)
ffffffffc0208582:	e822                	sd	s0,16(sp)
ffffffffc0208584:	cc81                	beqz	s1,ffffffffc020859c <vfs_get_curdir+0x2e>
ffffffffc0208586:	842a                	mv	s0,a0
ffffffffc0208588:	8526                	mv	a0,s1
ffffffffc020858a:	aa2ff0ef          	jal	ra,ffffffffc020782c <inode_ref_inc>
ffffffffc020858e:	4501                	li	a0,0
ffffffffc0208590:	e004                	sd	s1,0(s0)
ffffffffc0208592:	60e2                	ld	ra,24(sp)
ffffffffc0208594:	6442                	ld	s0,16(sp)
ffffffffc0208596:	64a2                	ld	s1,8(sp)
ffffffffc0208598:	6105                	addi	sp,sp,32
ffffffffc020859a:	8082                	ret
ffffffffc020859c:	5541                	li	a0,-16
ffffffffc020859e:	bfd5                	j	ffffffffc0208592 <vfs_get_curdir+0x24>

ffffffffc02085a0 <vfs_set_curdir>:
ffffffffc02085a0:	7139                	addi	sp,sp,-64
ffffffffc02085a2:	f04a                	sd	s2,32(sp)
ffffffffc02085a4:	0008e917          	auipc	s2,0x8e
ffffffffc02085a8:	31c90913          	addi	s2,s2,796 # ffffffffc02968c0 <current>
ffffffffc02085ac:	00093783          	ld	a5,0(s2)
ffffffffc02085b0:	f822                	sd	s0,48(sp)
ffffffffc02085b2:	842a                	mv	s0,a0
ffffffffc02085b4:	1487b503          	ld	a0,328(a5)
ffffffffc02085b8:	ec4e                	sd	s3,24(sp)
ffffffffc02085ba:	fc06                	sd	ra,56(sp)
ffffffffc02085bc:	f426                	sd	s1,40(sp)
ffffffffc02085be:	c05fc0ef          	jal	ra,ffffffffc02051c2 <lock_files>
ffffffffc02085c2:	00093783          	ld	a5,0(s2)
ffffffffc02085c6:	1487b503          	ld	a0,328(a5)
ffffffffc02085ca:	00053983          	ld	s3,0(a0)
ffffffffc02085ce:	07340963          	beq	s0,s3,ffffffffc0208640 <vfs_set_curdir+0xa0>
ffffffffc02085d2:	cc39                	beqz	s0,ffffffffc0208630 <vfs_set_curdir+0x90>
ffffffffc02085d4:	783c                	ld	a5,112(s0)
ffffffffc02085d6:	c7bd                	beqz	a5,ffffffffc0208644 <vfs_set_curdir+0xa4>
ffffffffc02085d8:	6bbc                	ld	a5,80(a5)
ffffffffc02085da:	c7ad                	beqz	a5,ffffffffc0208644 <vfs_set_curdir+0xa4>
ffffffffc02085dc:	00007597          	auipc	a1,0x7
ffffffffc02085e0:	81c58593          	addi	a1,a1,-2020 # ffffffffc020edf8 <syscalls+0xd98>
ffffffffc02085e4:	8522                	mv	a0,s0
ffffffffc02085e6:	a5eff0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc02085ea:	783c                	ld	a5,112(s0)
ffffffffc02085ec:	006c                	addi	a1,sp,12
ffffffffc02085ee:	8522                	mv	a0,s0
ffffffffc02085f0:	6bbc                	ld	a5,80(a5)
ffffffffc02085f2:	9782                	jalr	a5
ffffffffc02085f4:	84aa                	mv	s1,a0
ffffffffc02085f6:	e901                	bnez	a0,ffffffffc0208606 <vfs_set_curdir+0x66>
ffffffffc02085f8:	47b2                	lw	a5,12(sp)
ffffffffc02085fa:	669d                	lui	a3,0x7
ffffffffc02085fc:	6709                	lui	a4,0x2
ffffffffc02085fe:	8ff5                	and	a5,a5,a3
ffffffffc0208600:	54b9                	li	s1,-18
ffffffffc0208602:	02e78063          	beq	a5,a4,ffffffffc0208622 <vfs_set_curdir+0x82>
ffffffffc0208606:	00093783          	ld	a5,0(s2)
ffffffffc020860a:	1487b503          	ld	a0,328(a5)
ffffffffc020860e:	bbbfc0ef          	jal	ra,ffffffffc02051c8 <unlock_files>
ffffffffc0208612:	70e2                	ld	ra,56(sp)
ffffffffc0208614:	7442                	ld	s0,48(sp)
ffffffffc0208616:	7902                	ld	s2,32(sp)
ffffffffc0208618:	69e2                	ld	s3,24(sp)
ffffffffc020861a:	8526                	mv	a0,s1
ffffffffc020861c:	74a2                	ld	s1,40(sp)
ffffffffc020861e:	6121                	addi	sp,sp,64
ffffffffc0208620:	8082                	ret
ffffffffc0208622:	8522                	mv	a0,s0
ffffffffc0208624:	a08ff0ef          	jal	ra,ffffffffc020782c <inode_ref_inc>
ffffffffc0208628:	00093783          	ld	a5,0(s2)
ffffffffc020862c:	1487b503          	ld	a0,328(a5)
ffffffffc0208630:	e100                	sd	s0,0(a0)
ffffffffc0208632:	4481                	li	s1,0
ffffffffc0208634:	fc098de3          	beqz	s3,ffffffffc020860e <vfs_set_curdir+0x6e>
ffffffffc0208638:	854e                	mv	a0,s3
ffffffffc020863a:	ac0ff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc020863e:	b7e1                	j	ffffffffc0208606 <vfs_set_curdir+0x66>
ffffffffc0208640:	4481                	li	s1,0
ffffffffc0208642:	b7f1                	j	ffffffffc020860e <vfs_set_curdir+0x6e>
ffffffffc0208644:	00006697          	auipc	a3,0x6
ffffffffc0208648:	76468693          	addi	a3,a3,1892 # ffffffffc020eda8 <syscalls+0xd48>
ffffffffc020864c:	00004617          	auipc	a2,0x4
ffffffffc0208650:	89c60613          	addi	a2,a2,-1892 # ffffffffc020bee8 <commands+0x210>
ffffffffc0208654:	04300593          	li	a1,67
ffffffffc0208658:	00006517          	auipc	a0,0x6
ffffffffc020865c:	7b050513          	addi	a0,a0,1968 # ffffffffc020ee08 <syscalls+0xda8>
ffffffffc0208660:	e3ff70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0208664 <vfs_chdir>:
ffffffffc0208664:	1101                	addi	sp,sp,-32
ffffffffc0208666:	002c                	addi	a1,sp,8
ffffffffc0208668:	e822                	sd	s0,16(sp)
ffffffffc020866a:	ec06                	sd	ra,24(sp)
ffffffffc020866c:	ef3ff0ef          	jal	ra,ffffffffc020855e <vfs_lookup>
ffffffffc0208670:	842a                	mv	s0,a0
ffffffffc0208672:	c511                	beqz	a0,ffffffffc020867e <vfs_chdir+0x1a>
ffffffffc0208674:	60e2                	ld	ra,24(sp)
ffffffffc0208676:	8522                	mv	a0,s0
ffffffffc0208678:	6442                	ld	s0,16(sp)
ffffffffc020867a:	6105                	addi	sp,sp,32
ffffffffc020867c:	8082                	ret
ffffffffc020867e:	6522                	ld	a0,8(sp)
ffffffffc0208680:	f21ff0ef          	jal	ra,ffffffffc02085a0 <vfs_set_curdir>
ffffffffc0208684:	842a                	mv	s0,a0
ffffffffc0208686:	6522                	ld	a0,8(sp)
ffffffffc0208688:	a72ff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc020868c:	60e2                	ld	ra,24(sp)
ffffffffc020868e:	8522                	mv	a0,s0
ffffffffc0208690:	6442                	ld	s0,16(sp)
ffffffffc0208692:	6105                	addi	sp,sp,32
ffffffffc0208694:	8082                	ret

ffffffffc0208696 <vfs_getcwd>:
ffffffffc0208696:	0008e797          	auipc	a5,0x8e
ffffffffc020869a:	22a7b783          	ld	a5,554(a5) # ffffffffc02968c0 <current>
ffffffffc020869e:	1487b783          	ld	a5,328(a5)
ffffffffc02086a2:	7179                	addi	sp,sp,-48
ffffffffc02086a4:	ec26                	sd	s1,24(sp)
ffffffffc02086a6:	6384                	ld	s1,0(a5)
ffffffffc02086a8:	f406                	sd	ra,40(sp)
ffffffffc02086aa:	f022                	sd	s0,32(sp)
ffffffffc02086ac:	e84a                	sd	s2,16(sp)
ffffffffc02086ae:	ccbd                	beqz	s1,ffffffffc020872c <vfs_getcwd+0x96>
ffffffffc02086b0:	892a                	mv	s2,a0
ffffffffc02086b2:	8526                	mv	a0,s1
ffffffffc02086b4:	978ff0ef          	jal	ra,ffffffffc020782c <inode_ref_inc>
ffffffffc02086b8:	74a8                	ld	a0,104(s1)
ffffffffc02086ba:	c93d                	beqz	a0,ffffffffc0208730 <vfs_getcwd+0x9a>
ffffffffc02086bc:	f06ff0ef          	jal	ra,ffffffffc0207dc2 <vfs_get_devname>
ffffffffc02086c0:	842a                	mv	s0,a0
ffffffffc02086c2:	278030ef          	jal	ra,ffffffffc020b93a <strlen>
ffffffffc02086c6:	862a                	mv	a2,a0
ffffffffc02086c8:	85a2                	mv	a1,s0
ffffffffc02086ca:	4701                	li	a4,0
ffffffffc02086cc:	4685                	li	a3,1
ffffffffc02086ce:	854a                	mv	a0,s2
ffffffffc02086d0:	d1dfc0ef          	jal	ra,ffffffffc02053ec <iobuf_move>
ffffffffc02086d4:	842a                	mv	s0,a0
ffffffffc02086d6:	c919                	beqz	a0,ffffffffc02086ec <vfs_getcwd+0x56>
ffffffffc02086d8:	8526                	mv	a0,s1
ffffffffc02086da:	a20ff0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc02086de:	70a2                	ld	ra,40(sp)
ffffffffc02086e0:	8522                	mv	a0,s0
ffffffffc02086e2:	7402                	ld	s0,32(sp)
ffffffffc02086e4:	64e2                	ld	s1,24(sp)
ffffffffc02086e6:	6942                	ld	s2,16(sp)
ffffffffc02086e8:	6145                	addi	sp,sp,48
ffffffffc02086ea:	8082                	ret
ffffffffc02086ec:	03a00793          	li	a5,58
ffffffffc02086f0:	4701                	li	a4,0
ffffffffc02086f2:	4685                	li	a3,1
ffffffffc02086f4:	4605                	li	a2,1
ffffffffc02086f6:	00f10593          	addi	a1,sp,15
ffffffffc02086fa:	854a                	mv	a0,s2
ffffffffc02086fc:	00f107a3          	sb	a5,15(sp)
ffffffffc0208700:	cedfc0ef          	jal	ra,ffffffffc02053ec <iobuf_move>
ffffffffc0208704:	842a                	mv	s0,a0
ffffffffc0208706:	f969                	bnez	a0,ffffffffc02086d8 <vfs_getcwd+0x42>
ffffffffc0208708:	78bc                	ld	a5,112(s1)
ffffffffc020870a:	c3b9                	beqz	a5,ffffffffc0208750 <vfs_getcwd+0xba>
ffffffffc020870c:	7f9c                	ld	a5,56(a5)
ffffffffc020870e:	c3a9                	beqz	a5,ffffffffc0208750 <vfs_getcwd+0xba>
ffffffffc0208710:	00006597          	auipc	a1,0x6
ffffffffc0208714:	76858593          	addi	a1,a1,1896 # ffffffffc020ee78 <syscalls+0xe18>
ffffffffc0208718:	8526                	mv	a0,s1
ffffffffc020871a:	92aff0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc020871e:	78bc                	ld	a5,112(s1)
ffffffffc0208720:	85ca                	mv	a1,s2
ffffffffc0208722:	8526                	mv	a0,s1
ffffffffc0208724:	7f9c                	ld	a5,56(a5)
ffffffffc0208726:	9782                	jalr	a5
ffffffffc0208728:	842a                	mv	s0,a0
ffffffffc020872a:	b77d                	j	ffffffffc02086d8 <vfs_getcwd+0x42>
ffffffffc020872c:	5441                	li	s0,-16
ffffffffc020872e:	bf45                	j	ffffffffc02086de <vfs_getcwd+0x48>
ffffffffc0208730:	00006697          	auipc	a3,0x6
ffffffffc0208734:	60868693          	addi	a3,a3,1544 # ffffffffc020ed38 <syscalls+0xcd8>
ffffffffc0208738:	00003617          	auipc	a2,0x3
ffffffffc020873c:	7b060613          	addi	a2,a2,1968 # ffffffffc020bee8 <commands+0x210>
ffffffffc0208740:	06e00593          	li	a1,110
ffffffffc0208744:	00006517          	auipc	a0,0x6
ffffffffc0208748:	6c450513          	addi	a0,a0,1732 # ffffffffc020ee08 <syscalls+0xda8>
ffffffffc020874c:	d53f70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0208750:	00006697          	auipc	a3,0x6
ffffffffc0208754:	6d068693          	addi	a3,a3,1744 # ffffffffc020ee20 <syscalls+0xdc0>
ffffffffc0208758:	00003617          	auipc	a2,0x3
ffffffffc020875c:	79060613          	addi	a2,a2,1936 # ffffffffc020bee8 <commands+0x210>
ffffffffc0208760:	07800593          	li	a1,120
ffffffffc0208764:	00006517          	auipc	a0,0x6
ffffffffc0208768:	6a450513          	addi	a0,a0,1700 # ffffffffc020ee08 <syscalls+0xda8>
ffffffffc020876c:	d33f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0208770 <dev_lookup>:
ffffffffc0208770:	0005c783          	lbu	a5,0(a1)
ffffffffc0208774:	e385                	bnez	a5,ffffffffc0208794 <dev_lookup+0x24>
ffffffffc0208776:	1101                	addi	sp,sp,-32
ffffffffc0208778:	e822                	sd	s0,16(sp)
ffffffffc020877a:	e426                	sd	s1,8(sp)
ffffffffc020877c:	ec06                	sd	ra,24(sp)
ffffffffc020877e:	84aa                	mv	s1,a0
ffffffffc0208780:	8432                	mv	s0,a2
ffffffffc0208782:	8aaff0ef          	jal	ra,ffffffffc020782c <inode_ref_inc>
ffffffffc0208786:	60e2                	ld	ra,24(sp)
ffffffffc0208788:	e004                	sd	s1,0(s0)
ffffffffc020878a:	6442                	ld	s0,16(sp)
ffffffffc020878c:	64a2                	ld	s1,8(sp)
ffffffffc020878e:	4501                	li	a0,0
ffffffffc0208790:	6105                	addi	sp,sp,32
ffffffffc0208792:	8082                	ret
ffffffffc0208794:	5541                	li	a0,-16
ffffffffc0208796:	8082                	ret

ffffffffc0208798 <dev_fstat>:
ffffffffc0208798:	1101                	addi	sp,sp,-32
ffffffffc020879a:	e426                	sd	s1,8(sp)
ffffffffc020879c:	84ae                	mv	s1,a1
ffffffffc020879e:	e822                	sd	s0,16(sp)
ffffffffc02087a0:	02000613          	li	a2,32
ffffffffc02087a4:	842a                	mv	s0,a0
ffffffffc02087a6:	4581                	li	a1,0
ffffffffc02087a8:	8526                	mv	a0,s1
ffffffffc02087aa:	ec06                	sd	ra,24(sp)
ffffffffc02087ac:	258030ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc02087b0:	c429                	beqz	s0,ffffffffc02087fa <dev_fstat+0x62>
ffffffffc02087b2:	783c                	ld	a5,112(s0)
ffffffffc02087b4:	c3b9                	beqz	a5,ffffffffc02087fa <dev_fstat+0x62>
ffffffffc02087b6:	6bbc                	ld	a5,80(a5)
ffffffffc02087b8:	c3a9                	beqz	a5,ffffffffc02087fa <dev_fstat+0x62>
ffffffffc02087ba:	00006597          	auipc	a1,0x6
ffffffffc02087be:	63e58593          	addi	a1,a1,1598 # ffffffffc020edf8 <syscalls+0xd98>
ffffffffc02087c2:	8522                	mv	a0,s0
ffffffffc02087c4:	880ff0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc02087c8:	783c                	ld	a5,112(s0)
ffffffffc02087ca:	85a6                	mv	a1,s1
ffffffffc02087cc:	8522                	mv	a0,s0
ffffffffc02087ce:	6bbc                	ld	a5,80(a5)
ffffffffc02087d0:	9782                	jalr	a5
ffffffffc02087d2:	ed19                	bnez	a0,ffffffffc02087f0 <dev_fstat+0x58>
ffffffffc02087d4:	4c38                	lw	a4,88(s0)
ffffffffc02087d6:	6785                	lui	a5,0x1
ffffffffc02087d8:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc02087dc:	02f71f63          	bne	a4,a5,ffffffffc020881a <dev_fstat+0x82>
ffffffffc02087e0:	6018                	ld	a4,0(s0)
ffffffffc02087e2:	641c                	ld	a5,8(s0)
ffffffffc02087e4:	4685                	li	a3,1
ffffffffc02087e6:	e494                	sd	a3,8(s1)
ffffffffc02087e8:	02e787b3          	mul	a5,a5,a4
ffffffffc02087ec:	e898                	sd	a4,16(s1)
ffffffffc02087ee:	ec9c                	sd	a5,24(s1)
ffffffffc02087f0:	60e2                	ld	ra,24(sp)
ffffffffc02087f2:	6442                	ld	s0,16(sp)
ffffffffc02087f4:	64a2                	ld	s1,8(sp)
ffffffffc02087f6:	6105                	addi	sp,sp,32
ffffffffc02087f8:	8082                	ret
ffffffffc02087fa:	00006697          	auipc	a3,0x6
ffffffffc02087fe:	5ae68693          	addi	a3,a3,1454 # ffffffffc020eda8 <syscalls+0xd48>
ffffffffc0208802:	00003617          	auipc	a2,0x3
ffffffffc0208806:	6e660613          	addi	a2,a2,1766 # ffffffffc020bee8 <commands+0x210>
ffffffffc020880a:	04200593          	li	a1,66
ffffffffc020880e:	00006517          	auipc	a0,0x6
ffffffffc0208812:	67a50513          	addi	a0,a0,1658 # ffffffffc020ee88 <syscalls+0xe28>
ffffffffc0208816:	c89f70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020881a:	00006697          	auipc	a3,0x6
ffffffffc020881e:	35668693          	addi	a3,a3,854 # ffffffffc020eb70 <syscalls+0xb10>
ffffffffc0208822:	00003617          	auipc	a2,0x3
ffffffffc0208826:	6c660613          	addi	a2,a2,1734 # ffffffffc020bee8 <commands+0x210>
ffffffffc020882a:	04500593          	li	a1,69
ffffffffc020882e:	00006517          	auipc	a0,0x6
ffffffffc0208832:	65a50513          	addi	a0,a0,1626 # ffffffffc020ee88 <syscalls+0xe28>
ffffffffc0208836:	c69f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020883a <dev_ioctl>:
ffffffffc020883a:	c909                	beqz	a0,ffffffffc020884c <dev_ioctl+0x12>
ffffffffc020883c:	4d34                	lw	a3,88(a0)
ffffffffc020883e:	6705                	lui	a4,0x1
ffffffffc0208840:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208844:	00e69463          	bne	a3,a4,ffffffffc020884c <dev_ioctl+0x12>
ffffffffc0208848:	751c                	ld	a5,40(a0)
ffffffffc020884a:	8782                	jr	a5
ffffffffc020884c:	1141                	addi	sp,sp,-16
ffffffffc020884e:	00006697          	auipc	a3,0x6
ffffffffc0208852:	32268693          	addi	a3,a3,802 # ffffffffc020eb70 <syscalls+0xb10>
ffffffffc0208856:	00003617          	auipc	a2,0x3
ffffffffc020885a:	69260613          	addi	a2,a2,1682 # ffffffffc020bee8 <commands+0x210>
ffffffffc020885e:	03500593          	li	a1,53
ffffffffc0208862:	00006517          	auipc	a0,0x6
ffffffffc0208866:	62650513          	addi	a0,a0,1574 # ffffffffc020ee88 <syscalls+0xe28>
ffffffffc020886a:	e406                	sd	ra,8(sp)
ffffffffc020886c:	c33f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0208870 <dev_tryseek>:
ffffffffc0208870:	c51d                	beqz	a0,ffffffffc020889e <dev_tryseek+0x2e>
ffffffffc0208872:	4d38                	lw	a4,88(a0)
ffffffffc0208874:	6785                	lui	a5,0x1
ffffffffc0208876:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc020887a:	02f71263          	bne	a4,a5,ffffffffc020889e <dev_tryseek+0x2e>
ffffffffc020887e:	611c                	ld	a5,0(a0)
ffffffffc0208880:	cf89                	beqz	a5,ffffffffc020889a <dev_tryseek+0x2a>
ffffffffc0208882:	6518                	ld	a4,8(a0)
ffffffffc0208884:	02e5f6b3          	remu	a3,a1,a4
ffffffffc0208888:	ea89                	bnez	a3,ffffffffc020889a <dev_tryseek+0x2a>
ffffffffc020888a:	0005c863          	bltz	a1,ffffffffc020889a <dev_tryseek+0x2a>
ffffffffc020888e:	02e787b3          	mul	a5,a5,a4
ffffffffc0208892:	00f5f463          	bgeu	a1,a5,ffffffffc020889a <dev_tryseek+0x2a>
ffffffffc0208896:	4501                	li	a0,0
ffffffffc0208898:	8082                	ret
ffffffffc020889a:	5575                	li	a0,-3
ffffffffc020889c:	8082                	ret
ffffffffc020889e:	1141                	addi	sp,sp,-16
ffffffffc02088a0:	00006697          	auipc	a3,0x6
ffffffffc02088a4:	2d068693          	addi	a3,a3,720 # ffffffffc020eb70 <syscalls+0xb10>
ffffffffc02088a8:	00003617          	auipc	a2,0x3
ffffffffc02088ac:	64060613          	addi	a2,a2,1600 # ffffffffc020bee8 <commands+0x210>
ffffffffc02088b0:	05f00593          	li	a1,95
ffffffffc02088b4:	00006517          	auipc	a0,0x6
ffffffffc02088b8:	5d450513          	addi	a0,a0,1492 # ffffffffc020ee88 <syscalls+0xe28>
ffffffffc02088bc:	e406                	sd	ra,8(sp)
ffffffffc02088be:	be1f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02088c2 <dev_gettype>:
ffffffffc02088c2:	c10d                	beqz	a0,ffffffffc02088e4 <dev_gettype+0x22>
ffffffffc02088c4:	4d38                	lw	a4,88(a0)
ffffffffc02088c6:	6785                	lui	a5,0x1
ffffffffc02088c8:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc02088cc:	00f71c63          	bne	a4,a5,ffffffffc02088e4 <dev_gettype+0x22>
ffffffffc02088d0:	6118                	ld	a4,0(a0)
ffffffffc02088d2:	6795                	lui	a5,0x5
ffffffffc02088d4:	c701                	beqz	a4,ffffffffc02088dc <dev_gettype+0x1a>
ffffffffc02088d6:	c19c                	sw	a5,0(a1)
ffffffffc02088d8:	4501                	li	a0,0
ffffffffc02088da:	8082                	ret
ffffffffc02088dc:	6791                	lui	a5,0x4
ffffffffc02088de:	c19c                	sw	a5,0(a1)
ffffffffc02088e0:	4501                	li	a0,0
ffffffffc02088e2:	8082                	ret
ffffffffc02088e4:	1141                	addi	sp,sp,-16
ffffffffc02088e6:	00006697          	auipc	a3,0x6
ffffffffc02088ea:	28a68693          	addi	a3,a3,650 # ffffffffc020eb70 <syscalls+0xb10>
ffffffffc02088ee:	00003617          	auipc	a2,0x3
ffffffffc02088f2:	5fa60613          	addi	a2,a2,1530 # ffffffffc020bee8 <commands+0x210>
ffffffffc02088f6:	05300593          	li	a1,83
ffffffffc02088fa:	00006517          	auipc	a0,0x6
ffffffffc02088fe:	58e50513          	addi	a0,a0,1422 # ffffffffc020ee88 <syscalls+0xe28>
ffffffffc0208902:	e406                	sd	ra,8(sp)
ffffffffc0208904:	b9bf70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0208908 <dev_write>:
ffffffffc0208908:	c911                	beqz	a0,ffffffffc020891c <dev_write+0x14>
ffffffffc020890a:	4d34                	lw	a3,88(a0)
ffffffffc020890c:	6705                	lui	a4,0x1
ffffffffc020890e:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208912:	00e69563          	bne	a3,a4,ffffffffc020891c <dev_write+0x14>
ffffffffc0208916:	711c                	ld	a5,32(a0)
ffffffffc0208918:	4605                	li	a2,1
ffffffffc020891a:	8782                	jr	a5
ffffffffc020891c:	1141                	addi	sp,sp,-16
ffffffffc020891e:	00006697          	auipc	a3,0x6
ffffffffc0208922:	25268693          	addi	a3,a3,594 # ffffffffc020eb70 <syscalls+0xb10>
ffffffffc0208926:	00003617          	auipc	a2,0x3
ffffffffc020892a:	5c260613          	addi	a2,a2,1474 # ffffffffc020bee8 <commands+0x210>
ffffffffc020892e:	02c00593          	li	a1,44
ffffffffc0208932:	00006517          	auipc	a0,0x6
ffffffffc0208936:	55650513          	addi	a0,a0,1366 # ffffffffc020ee88 <syscalls+0xe28>
ffffffffc020893a:	e406                	sd	ra,8(sp)
ffffffffc020893c:	b63f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0208940 <dev_read>:
ffffffffc0208940:	c911                	beqz	a0,ffffffffc0208954 <dev_read+0x14>
ffffffffc0208942:	4d34                	lw	a3,88(a0)
ffffffffc0208944:	6705                	lui	a4,0x1
ffffffffc0208946:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc020894a:	00e69563          	bne	a3,a4,ffffffffc0208954 <dev_read+0x14>
ffffffffc020894e:	711c                	ld	a5,32(a0)
ffffffffc0208950:	4601                	li	a2,0
ffffffffc0208952:	8782                	jr	a5
ffffffffc0208954:	1141                	addi	sp,sp,-16
ffffffffc0208956:	00006697          	auipc	a3,0x6
ffffffffc020895a:	21a68693          	addi	a3,a3,538 # ffffffffc020eb70 <syscalls+0xb10>
ffffffffc020895e:	00003617          	auipc	a2,0x3
ffffffffc0208962:	58a60613          	addi	a2,a2,1418 # ffffffffc020bee8 <commands+0x210>
ffffffffc0208966:	02300593          	li	a1,35
ffffffffc020896a:	00006517          	auipc	a0,0x6
ffffffffc020896e:	51e50513          	addi	a0,a0,1310 # ffffffffc020ee88 <syscalls+0xe28>
ffffffffc0208972:	e406                	sd	ra,8(sp)
ffffffffc0208974:	b2bf70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0208978 <dev_close>:
ffffffffc0208978:	c909                	beqz	a0,ffffffffc020898a <dev_close+0x12>
ffffffffc020897a:	4d34                	lw	a3,88(a0)
ffffffffc020897c:	6705                	lui	a4,0x1
ffffffffc020897e:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208982:	00e69463          	bne	a3,a4,ffffffffc020898a <dev_close+0x12>
ffffffffc0208986:	6d1c                	ld	a5,24(a0)
ffffffffc0208988:	8782                	jr	a5
ffffffffc020898a:	1141                	addi	sp,sp,-16
ffffffffc020898c:	00006697          	auipc	a3,0x6
ffffffffc0208990:	1e468693          	addi	a3,a3,484 # ffffffffc020eb70 <syscalls+0xb10>
ffffffffc0208994:	00003617          	auipc	a2,0x3
ffffffffc0208998:	55460613          	addi	a2,a2,1364 # ffffffffc020bee8 <commands+0x210>
ffffffffc020899c:	45e9                	li	a1,26
ffffffffc020899e:	00006517          	auipc	a0,0x6
ffffffffc02089a2:	4ea50513          	addi	a0,a0,1258 # ffffffffc020ee88 <syscalls+0xe28>
ffffffffc02089a6:	e406                	sd	ra,8(sp)
ffffffffc02089a8:	af7f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02089ac <dev_open>:
ffffffffc02089ac:	03c5f713          	andi	a4,a1,60
ffffffffc02089b0:	eb11                	bnez	a4,ffffffffc02089c4 <dev_open+0x18>
ffffffffc02089b2:	c919                	beqz	a0,ffffffffc02089c8 <dev_open+0x1c>
ffffffffc02089b4:	4d34                	lw	a3,88(a0)
ffffffffc02089b6:	6705                	lui	a4,0x1
ffffffffc02089b8:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc02089bc:	00e69663          	bne	a3,a4,ffffffffc02089c8 <dev_open+0x1c>
ffffffffc02089c0:	691c                	ld	a5,16(a0)
ffffffffc02089c2:	8782                	jr	a5
ffffffffc02089c4:	5575                	li	a0,-3
ffffffffc02089c6:	8082                	ret
ffffffffc02089c8:	1141                	addi	sp,sp,-16
ffffffffc02089ca:	00006697          	auipc	a3,0x6
ffffffffc02089ce:	1a668693          	addi	a3,a3,422 # ffffffffc020eb70 <syscalls+0xb10>
ffffffffc02089d2:	00003617          	auipc	a2,0x3
ffffffffc02089d6:	51660613          	addi	a2,a2,1302 # ffffffffc020bee8 <commands+0x210>
ffffffffc02089da:	45c5                	li	a1,17
ffffffffc02089dc:	00006517          	auipc	a0,0x6
ffffffffc02089e0:	4ac50513          	addi	a0,a0,1196 # ffffffffc020ee88 <syscalls+0xe28>
ffffffffc02089e4:	e406                	sd	ra,8(sp)
ffffffffc02089e6:	ab9f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02089ea <dev_init>:
ffffffffc02089ea:	1141                	addi	sp,sp,-16
ffffffffc02089ec:	e406                	sd	ra,8(sp)
ffffffffc02089ee:	542000ef          	jal	ra,ffffffffc0208f30 <dev_init_stdin>
ffffffffc02089f2:	65a000ef          	jal	ra,ffffffffc020904c <dev_init_stdout>
ffffffffc02089f6:	60a2                	ld	ra,8(sp)
ffffffffc02089f8:	0141                	addi	sp,sp,16
ffffffffc02089fa:	a439                	j	ffffffffc0208c08 <dev_init_disk0>

ffffffffc02089fc <dev_create_inode>:
ffffffffc02089fc:	6505                	lui	a0,0x1
ffffffffc02089fe:	1141                	addi	sp,sp,-16
ffffffffc0208a00:	23450513          	addi	a0,a0,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208a04:	e022                	sd	s0,0(sp)
ffffffffc0208a06:	e406                	sd	ra,8(sp)
ffffffffc0208a08:	da7fe0ef          	jal	ra,ffffffffc02077ae <__alloc_inode>
ffffffffc0208a0c:	842a                	mv	s0,a0
ffffffffc0208a0e:	c901                	beqz	a0,ffffffffc0208a1e <dev_create_inode+0x22>
ffffffffc0208a10:	4601                	li	a2,0
ffffffffc0208a12:	00006597          	auipc	a1,0x6
ffffffffc0208a16:	48e58593          	addi	a1,a1,1166 # ffffffffc020eea0 <dev_node_ops>
ffffffffc0208a1a:	db1fe0ef          	jal	ra,ffffffffc02077ca <inode_init>
ffffffffc0208a1e:	60a2                	ld	ra,8(sp)
ffffffffc0208a20:	8522                	mv	a0,s0
ffffffffc0208a22:	6402                	ld	s0,0(sp)
ffffffffc0208a24:	0141                	addi	sp,sp,16
ffffffffc0208a26:	8082                	ret

ffffffffc0208a28 <disk0_open>:
ffffffffc0208a28:	4501                	li	a0,0
ffffffffc0208a2a:	8082                	ret

ffffffffc0208a2c <disk0_close>:
ffffffffc0208a2c:	4501                	li	a0,0
ffffffffc0208a2e:	8082                	ret

ffffffffc0208a30 <disk0_ioctl>:
ffffffffc0208a30:	5531                	li	a0,-20
ffffffffc0208a32:	8082                	ret

ffffffffc0208a34 <disk0_io>:
ffffffffc0208a34:	659c                	ld	a5,8(a1)
ffffffffc0208a36:	7159                	addi	sp,sp,-112
ffffffffc0208a38:	eca6                	sd	s1,88(sp)
ffffffffc0208a3a:	f45e                	sd	s7,40(sp)
ffffffffc0208a3c:	6d84                	ld	s1,24(a1)
ffffffffc0208a3e:	6b85                	lui	s7,0x1
ffffffffc0208a40:	1bfd                	addi	s7,s7,-1
ffffffffc0208a42:	e4ce                	sd	s3,72(sp)
ffffffffc0208a44:	43f7d993          	srai	s3,a5,0x3f
ffffffffc0208a48:	0179f9b3          	and	s3,s3,s7
ffffffffc0208a4c:	99be                	add	s3,s3,a5
ffffffffc0208a4e:	8fc5                	or	a5,a5,s1
ffffffffc0208a50:	f486                	sd	ra,104(sp)
ffffffffc0208a52:	f0a2                	sd	s0,96(sp)
ffffffffc0208a54:	e8ca                	sd	s2,80(sp)
ffffffffc0208a56:	e0d2                	sd	s4,64(sp)
ffffffffc0208a58:	fc56                	sd	s5,56(sp)
ffffffffc0208a5a:	f85a                	sd	s6,48(sp)
ffffffffc0208a5c:	f062                	sd	s8,32(sp)
ffffffffc0208a5e:	ec66                	sd	s9,24(sp)
ffffffffc0208a60:	e86a                	sd	s10,16(sp)
ffffffffc0208a62:	0177f7b3          	and	a5,a5,s7
ffffffffc0208a66:	10079d63          	bnez	a5,ffffffffc0208b80 <disk0_io+0x14c>
ffffffffc0208a6a:	40c9d993          	srai	s3,s3,0xc
ffffffffc0208a6e:	00c4d713          	srli	a4,s1,0xc
ffffffffc0208a72:	2981                	sext.w	s3,s3
ffffffffc0208a74:	2701                	sext.w	a4,a4
ffffffffc0208a76:	00e987bb          	addw	a5,s3,a4
ffffffffc0208a7a:	6114                	ld	a3,0(a0)
ffffffffc0208a7c:	1782                	slli	a5,a5,0x20
ffffffffc0208a7e:	9381                	srli	a5,a5,0x20
ffffffffc0208a80:	10f6e063          	bltu	a3,a5,ffffffffc0208b80 <disk0_io+0x14c>
ffffffffc0208a84:	4501                	li	a0,0
ffffffffc0208a86:	ef19                	bnez	a4,ffffffffc0208aa4 <disk0_io+0x70>
ffffffffc0208a88:	70a6                	ld	ra,104(sp)
ffffffffc0208a8a:	7406                	ld	s0,96(sp)
ffffffffc0208a8c:	64e6                	ld	s1,88(sp)
ffffffffc0208a8e:	6946                	ld	s2,80(sp)
ffffffffc0208a90:	69a6                	ld	s3,72(sp)
ffffffffc0208a92:	6a06                	ld	s4,64(sp)
ffffffffc0208a94:	7ae2                	ld	s5,56(sp)
ffffffffc0208a96:	7b42                	ld	s6,48(sp)
ffffffffc0208a98:	7ba2                	ld	s7,40(sp)
ffffffffc0208a9a:	7c02                	ld	s8,32(sp)
ffffffffc0208a9c:	6ce2                	ld	s9,24(sp)
ffffffffc0208a9e:	6d42                	ld	s10,16(sp)
ffffffffc0208aa0:	6165                	addi	sp,sp,112
ffffffffc0208aa2:	8082                	ret
ffffffffc0208aa4:	0008d517          	auipc	a0,0x8d
ffffffffc0208aa8:	d9c50513          	addi	a0,a0,-612 # ffffffffc0295840 <disk0_sem>
ffffffffc0208aac:	8b2e                	mv	s6,a1
ffffffffc0208aae:	8c32                	mv	s8,a2
ffffffffc0208ab0:	0008ea97          	auipc	s5,0x8e
ffffffffc0208ab4:	e48a8a93          	addi	s5,s5,-440 # ffffffffc02968f8 <disk0_buffer>
ffffffffc0208ab8:	aadfb0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc0208abc:	6c91                	lui	s9,0x4
ffffffffc0208abe:	e4b9                	bnez	s1,ffffffffc0208b0c <disk0_io+0xd8>
ffffffffc0208ac0:	a845                	j	ffffffffc0208b70 <disk0_io+0x13c>
ffffffffc0208ac2:	00c4d413          	srli	s0,s1,0xc
ffffffffc0208ac6:	0034169b          	slliw	a3,s0,0x3
ffffffffc0208aca:	00068d1b          	sext.w	s10,a3
ffffffffc0208ace:	1682                	slli	a3,a3,0x20
ffffffffc0208ad0:	2401                	sext.w	s0,s0
ffffffffc0208ad2:	9281                	srli	a3,a3,0x20
ffffffffc0208ad4:	8926                	mv	s2,s1
ffffffffc0208ad6:	00399a1b          	slliw	s4,s3,0x3
ffffffffc0208ada:	862e                	mv	a2,a1
ffffffffc0208adc:	4509                	li	a0,2
ffffffffc0208ade:	85d2                	mv	a1,s4
ffffffffc0208ae0:	860f80ef          	jal	ra,ffffffffc0200b40 <ide_read_secs>
ffffffffc0208ae4:	e165                	bnez	a0,ffffffffc0208bc4 <disk0_io+0x190>
ffffffffc0208ae6:	000ab583          	ld	a1,0(s5)
ffffffffc0208aea:	0038                	addi	a4,sp,8
ffffffffc0208aec:	4685                	li	a3,1
ffffffffc0208aee:	864a                	mv	a2,s2
ffffffffc0208af0:	855a                	mv	a0,s6
ffffffffc0208af2:	8fbfc0ef          	jal	ra,ffffffffc02053ec <iobuf_move>
ffffffffc0208af6:	67a2                	ld	a5,8(sp)
ffffffffc0208af8:	09279663          	bne	a5,s2,ffffffffc0208b84 <disk0_io+0x150>
ffffffffc0208afc:	017977b3          	and	a5,s2,s7
ffffffffc0208b00:	e3d1                	bnez	a5,ffffffffc0208b84 <disk0_io+0x150>
ffffffffc0208b02:	412484b3          	sub	s1,s1,s2
ffffffffc0208b06:	013409bb          	addw	s3,s0,s3
ffffffffc0208b0a:	c0bd                	beqz	s1,ffffffffc0208b70 <disk0_io+0x13c>
ffffffffc0208b0c:	000ab583          	ld	a1,0(s5)
ffffffffc0208b10:	000c1b63          	bnez	s8,ffffffffc0208b26 <disk0_io+0xf2>
ffffffffc0208b14:	fb94e7e3          	bltu	s1,s9,ffffffffc0208ac2 <disk0_io+0x8e>
ffffffffc0208b18:	02000693          	li	a3,32
ffffffffc0208b1c:	02000d13          	li	s10,32
ffffffffc0208b20:	4411                	li	s0,4
ffffffffc0208b22:	6911                	lui	s2,0x4
ffffffffc0208b24:	bf4d                	j	ffffffffc0208ad6 <disk0_io+0xa2>
ffffffffc0208b26:	0038                	addi	a4,sp,8
ffffffffc0208b28:	4681                	li	a3,0
ffffffffc0208b2a:	6611                	lui	a2,0x4
ffffffffc0208b2c:	855a                	mv	a0,s6
ffffffffc0208b2e:	8bffc0ef          	jal	ra,ffffffffc02053ec <iobuf_move>
ffffffffc0208b32:	6422                	ld	s0,8(sp)
ffffffffc0208b34:	c825                	beqz	s0,ffffffffc0208ba4 <disk0_io+0x170>
ffffffffc0208b36:	0684e763          	bltu	s1,s0,ffffffffc0208ba4 <disk0_io+0x170>
ffffffffc0208b3a:	017477b3          	and	a5,s0,s7
ffffffffc0208b3e:	e3bd                	bnez	a5,ffffffffc0208ba4 <disk0_io+0x170>
ffffffffc0208b40:	8031                	srli	s0,s0,0xc
ffffffffc0208b42:	0034179b          	slliw	a5,s0,0x3
ffffffffc0208b46:	000ab603          	ld	a2,0(s5)
ffffffffc0208b4a:	0039991b          	slliw	s2,s3,0x3
ffffffffc0208b4e:	02079693          	slli	a3,a5,0x20
ffffffffc0208b52:	9281                	srli	a3,a3,0x20
ffffffffc0208b54:	85ca                	mv	a1,s2
ffffffffc0208b56:	4509                	li	a0,2
ffffffffc0208b58:	2401                	sext.w	s0,s0
ffffffffc0208b5a:	00078a1b          	sext.w	s4,a5
ffffffffc0208b5e:	878f80ef          	jal	ra,ffffffffc0200bd6 <ide_write_secs>
ffffffffc0208b62:	e151                	bnez	a0,ffffffffc0208be6 <disk0_io+0x1b2>
ffffffffc0208b64:	6922                	ld	s2,8(sp)
ffffffffc0208b66:	013409bb          	addw	s3,s0,s3
ffffffffc0208b6a:	412484b3          	sub	s1,s1,s2
ffffffffc0208b6e:	fcd9                	bnez	s1,ffffffffc0208b0c <disk0_io+0xd8>
ffffffffc0208b70:	0008d517          	auipc	a0,0x8d
ffffffffc0208b74:	cd050513          	addi	a0,a0,-816 # ffffffffc0295840 <disk0_sem>
ffffffffc0208b78:	9e9fb0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0208b7c:	4501                	li	a0,0
ffffffffc0208b7e:	b729                	j	ffffffffc0208a88 <disk0_io+0x54>
ffffffffc0208b80:	5575                	li	a0,-3
ffffffffc0208b82:	b719                	j	ffffffffc0208a88 <disk0_io+0x54>
ffffffffc0208b84:	00006697          	auipc	a3,0x6
ffffffffc0208b88:	4cc68693          	addi	a3,a3,1228 # ffffffffc020f050 <dev_node_ops+0x1b0>
ffffffffc0208b8c:	00003617          	auipc	a2,0x3
ffffffffc0208b90:	35c60613          	addi	a2,a2,860 # ffffffffc020bee8 <commands+0x210>
ffffffffc0208b94:	06200593          	li	a1,98
ffffffffc0208b98:	00006517          	auipc	a0,0x6
ffffffffc0208b9c:	40050513          	addi	a0,a0,1024 # ffffffffc020ef98 <dev_node_ops+0xf8>
ffffffffc0208ba0:	8fff70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0208ba4:	00006697          	auipc	a3,0x6
ffffffffc0208ba8:	3b468693          	addi	a3,a3,948 # ffffffffc020ef58 <dev_node_ops+0xb8>
ffffffffc0208bac:	00003617          	auipc	a2,0x3
ffffffffc0208bb0:	33c60613          	addi	a2,a2,828 # ffffffffc020bee8 <commands+0x210>
ffffffffc0208bb4:	05700593          	li	a1,87
ffffffffc0208bb8:	00006517          	auipc	a0,0x6
ffffffffc0208bbc:	3e050513          	addi	a0,a0,992 # ffffffffc020ef98 <dev_node_ops+0xf8>
ffffffffc0208bc0:	8dff70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0208bc4:	88aa                	mv	a7,a0
ffffffffc0208bc6:	886a                	mv	a6,s10
ffffffffc0208bc8:	87a2                	mv	a5,s0
ffffffffc0208bca:	8752                	mv	a4,s4
ffffffffc0208bcc:	86ce                	mv	a3,s3
ffffffffc0208bce:	00006617          	auipc	a2,0x6
ffffffffc0208bd2:	43a60613          	addi	a2,a2,1082 # ffffffffc020f008 <dev_node_ops+0x168>
ffffffffc0208bd6:	02d00593          	li	a1,45
ffffffffc0208bda:	00006517          	auipc	a0,0x6
ffffffffc0208bde:	3be50513          	addi	a0,a0,958 # ffffffffc020ef98 <dev_node_ops+0xf8>
ffffffffc0208be2:	8bdf70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0208be6:	88aa                	mv	a7,a0
ffffffffc0208be8:	8852                	mv	a6,s4
ffffffffc0208bea:	87a2                	mv	a5,s0
ffffffffc0208bec:	874a                	mv	a4,s2
ffffffffc0208bee:	86ce                	mv	a3,s3
ffffffffc0208bf0:	00006617          	auipc	a2,0x6
ffffffffc0208bf4:	3c860613          	addi	a2,a2,968 # ffffffffc020efb8 <dev_node_ops+0x118>
ffffffffc0208bf8:	03700593          	li	a1,55
ffffffffc0208bfc:	00006517          	auipc	a0,0x6
ffffffffc0208c00:	39c50513          	addi	a0,a0,924 # ffffffffc020ef98 <dev_node_ops+0xf8>
ffffffffc0208c04:	89bf70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0208c08 <dev_init_disk0>:
ffffffffc0208c08:	1101                	addi	sp,sp,-32
ffffffffc0208c0a:	ec06                	sd	ra,24(sp)
ffffffffc0208c0c:	e822                	sd	s0,16(sp)
ffffffffc0208c0e:	e426                	sd	s1,8(sp)
ffffffffc0208c10:	dedff0ef          	jal	ra,ffffffffc02089fc <dev_create_inode>
ffffffffc0208c14:	c541                	beqz	a0,ffffffffc0208c9c <dev_init_disk0+0x94>
ffffffffc0208c16:	4d38                	lw	a4,88(a0)
ffffffffc0208c18:	6485                	lui	s1,0x1
ffffffffc0208c1a:	23448793          	addi	a5,s1,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208c1e:	842a                	mv	s0,a0
ffffffffc0208c20:	0cf71f63          	bne	a4,a5,ffffffffc0208cfe <dev_init_disk0+0xf6>
ffffffffc0208c24:	4509                	li	a0,2
ffffffffc0208c26:	ecff70ef          	jal	ra,ffffffffc0200af4 <ide_device_valid>
ffffffffc0208c2a:	cd55                	beqz	a0,ffffffffc0208ce6 <dev_init_disk0+0xde>
ffffffffc0208c2c:	4509                	li	a0,2
ffffffffc0208c2e:	eebf70ef          	jal	ra,ffffffffc0200b18 <ide_device_size>
ffffffffc0208c32:	00355793          	srli	a5,a0,0x3
ffffffffc0208c36:	e01c                	sd	a5,0(s0)
ffffffffc0208c38:	00000797          	auipc	a5,0x0
ffffffffc0208c3c:	df078793          	addi	a5,a5,-528 # ffffffffc0208a28 <disk0_open>
ffffffffc0208c40:	e81c                	sd	a5,16(s0)
ffffffffc0208c42:	00000797          	auipc	a5,0x0
ffffffffc0208c46:	dea78793          	addi	a5,a5,-534 # ffffffffc0208a2c <disk0_close>
ffffffffc0208c4a:	ec1c                	sd	a5,24(s0)
ffffffffc0208c4c:	00000797          	auipc	a5,0x0
ffffffffc0208c50:	de878793          	addi	a5,a5,-536 # ffffffffc0208a34 <disk0_io>
ffffffffc0208c54:	f01c                	sd	a5,32(s0)
ffffffffc0208c56:	00000797          	auipc	a5,0x0
ffffffffc0208c5a:	dda78793          	addi	a5,a5,-550 # ffffffffc0208a30 <disk0_ioctl>
ffffffffc0208c5e:	f41c                	sd	a5,40(s0)
ffffffffc0208c60:	4585                	li	a1,1
ffffffffc0208c62:	0008d517          	auipc	a0,0x8d
ffffffffc0208c66:	bde50513          	addi	a0,a0,-1058 # ffffffffc0295840 <disk0_sem>
ffffffffc0208c6a:	e404                	sd	s1,8(s0)
ffffffffc0208c6c:	8effb0ef          	jal	ra,ffffffffc020455a <sem_init>
ffffffffc0208c70:	6511                	lui	a0,0x4
ffffffffc0208c72:	b1cf90ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc0208c76:	0008e797          	auipc	a5,0x8e
ffffffffc0208c7a:	c8a7b123          	sd	a0,-894(a5) # ffffffffc02968f8 <disk0_buffer>
ffffffffc0208c7e:	c921                	beqz	a0,ffffffffc0208cce <dev_init_disk0+0xc6>
ffffffffc0208c80:	4605                	li	a2,1
ffffffffc0208c82:	85a2                	mv	a1,s0
ffffffffc0208c84:	00006517          	auipc	a0,0x6
ffffffffc0208c88:	45c50513          	addi	a0,a0,1116 # ffffffffc020f0e0 <dev_node_ops+0x240>
ffffffffc0208c8c:	980ff0ef          	jal	ra,ffffffffc0207e0c <vfs_add_dev>
ffffffffc0208c90:	e115                	bnez	a0,ffffffffc0208cb4 <dev_init_disk0+0xac>
ffffffffc0208c92:	60e2                	ld	ra,24(sp)
ffffffffc0208c94:	6442                	ld	s0,16(sp)
ffffffffc0208c96:	64a2                	ld	s1,8(sp)
ffffffffc0208c98:	6105                	addi	sp,sp,32
ffffffffc0208c9a:	8082                	ret
ffffffffc0208c9c:	00006617          	auipc	a2,0x6
ffffffffc0208ca0:	3e460613          	addi	a2,a2,996 # ffffffffc020f080 <dev_node_ops+0x1e0>
ffffffffc0208ca4:	08700593          	li	a1,135
ffffffffc0208ca8:	00006517          	auipc	a0,0x6
ffffffffc0208cac:	2f050513          	addi	a0,a0,752 # ffffffffc020ef98 <dev_node_ops+0xf8>
ffffffffc0208cb0:	feef70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0208cb4:	86aa                	mv	a3,a0
ffffffffc0208cb6:	00006617          	auipc	a2,0x6
ffffffffc0208cba:	43260613          	addi	a2,a2,1074 # ffffffffc020f0e8 <dev_node_ops+0x248>
ffffffffc0208cbe:	08d00593          	li	a1,141
ffffffffc0208cc2:	00006517          	auipc	a0,0x6
ffffffffc0208cc6:	2d650513          	addi	a0,a0,726 # ffffffffc020ef98 <dev_node_ops+0xf8>
ffffffffc0208cca:	fd4f70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0208cce:	00006617          	auipc	a2,0x6
ffffffffc0208cd2:	3f260613          	addi	a2,a2,1010 # ffffffffc020f0c0 <dev_node_ops+0x220>
ffffffffc0208cd6:	07f00593          	li	a1,127
ffffffffc0208cda:	00006517          	auipc	a0,0x6
ffffffffc0208cde:	2be50513          	addi	a0,a0,702 # ffffffffc020ef98 <dev_node_ops+0xf8>
ffffffffc0208ce2:	fbcf70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0208ce6:	00006617          	auipc	a2,0x6
ffffffffc0208cea:	3ba60613          	addi	a2,a2,954 # ffffffffc020f0a0 <dev_node_ops+0x200>
ffffffffc0208cee:	07300593          	li	a1,115
ffffffffc0208cf2:	00006517          	auipc	a0,0x6
ffffffffc0208cf6:	2a650513          	addi	a0,a0,678 # ffffffffc020ef98 <dev_node_ops+0xf8>
ffffffffc0208cfa:	fa4f70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0208cfe:	00006697          	auipc	a3,0x6
ffffffffc0208d02:	e7268693          	addi	a3,a3,-398 # ffffffffc020eb70 <syscalls+0xb10>
ffffffffc0208d06:	00003617          	auipc	a2,0x3
ffffffffc0208d0a:	1e260613          	addi	a2,a2,482 # ffffffffc020bee8 <commands+0x210>
ffffffffc0208d0e:	08900593          	li	a1,137
ffffffffc0208d12:	00006517          	auipc	a0,0x6
ffffffffc0208d16:	28650513          	addi	a0,a0,646 # ffffffffc020ef98 <dev_node_ops+0xf8>
ffffffffc0208d1a:	f84f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0208d1e <stdin_open>:
ffffffffc0208d1e:	4501                	li	a0,0
ffffffffc0208d20:	e191                	bnez	a1,ffffffffc0208d24 <stdin_open+0x6>
ffffffffc0208d22:	8082                	ret
ffffffffc0208d24:	5575                	li	a0,-3
ffffffffc0208d26:	8082                	ret

ffffffffc0208d28 <stdin_close>:
ffffffffc0208d28:	4501                	li	a0,0
ffffffffc0208d2a:	8082                	ret

ffffffffc0208d2c <stdin_ioctl>:
ffffffffc0208d2c:	5575                	li	a0,-3
ffffffffc0208d2e:	8082                	ret

ffffffffc0208d30 <stdin_io>:
ffffffffc0208d30:	7135                	addi	sp,sp,-160
ffffffffc0208d32:	ed06                	sd	ra,152(sp)
ffffffffc0208d34:	e922                	sd	s0,144(sp)
ffffffffc0208d36:	e526                	sd	s1,136(sp)
ffffffffc0208d38:	e14a                	sd	s2,128(sp)
ffffffffc0208d3a:	fcce                	sd	s3,120(sp)
ffffffffc0208d3c:	f8d2                	sd	s4,112(sp)
ffffffffc0208d3e:	f4d6                	sd	s5,104(sp)
ffffffffc0208d40:	f0da                	sd	s6,96(sp)
ffffffffc0208d42:	ecde                	sd	s7,88(sp)
ffffffffc0208d44:	e8e2                	sd	s8,80(sp)
ffffffffc0208d46:	e4e6                	sd	s9,72(sp)
ffffffffc0208d48:	e0ea                	sd	s10,64(sp)
ffffffffc0208d4a:	fc6e                	sd	s11,56(sp)
ffffffffc0208d4c:	14061163          	bnez	a2,ffffffffc0208e8e <stdin_io+0x15e>
ffffffffc0208d50:	0005bd83          	ld	s11,0(a1)
ffffffffc0208d54:	0185bd03          	ld	s10,24(a1)
ffffffffc0208d58:	8b2e                	mv	s6,a1
ffffffffc0208d5a:	100027f3          	csrr	a5,sstatus
ffffffffc0208d5e:	8b89                	andi	a5,a5,2
ffffffffc0208d60:	10079e63          	bnez	a5,ffffffffc0208e7c <stdin_io+0x14c>
ffffffffc0208d64:	4401                	li	s0,0
ffffffffc0208d66:	100d0963          	beqz	s10,ffffffffc0208e78 <stdin_io+0x148>
ffffffffc0208d6a:	0008e997          	auipc	s3,0x8e
ffffffffc0208d6e:	b9698993          	addi	s3,s3,-1130 # ffffffffc0296900 <p_rpos>
ffffffffc0208d72:	0009b783          	ld	a5,0(s3)
ffffffffc0208d76:	800004b7          	lui	s1,0x80000
ffffffffc0208d7a:	6c85                	lui	s9,0x1
ffffffffc0208d7c:	4a81                	li	s5,0
ffffffffc0208d7e:	0008ea17          	auipc	s4,0x8e
ffffffffc0208d82:	b8aa0a13          	addi	s4,s4,-1142 # ffffffffc0296908 <p_wpos>
ffffffffc0208d86:	0491                	addi	s1,s1,4
ffffffffc0208d88:	0008d917          	auipc	s2,0x8d
ffffffffc0208d8c:	ad090913          	addi	s2,s2,-1328 # ffffffffc0295858 <__wait_queue>
ffffffffc0208d90:	1cfd                	addi	s9,s9,-1
ffffffffc0208d92:	000a3703          	ld	a4,0(s4)
ffffffffc0208d96:	000a8c1b          	sext.w	s8,s5
ffffffffc0208d9a:	8be2                	mv	s7,s8
ffffffffc0208d9c:	02e7d763          	bge	a5,a4,ffffffffc0208dca <stdin_io+0x9a>
ffffffffc0208da0:	a859                	j	ffffffffc0208e36 <stdin_io+0x106>
ffffffffc0208da2:	d68fe0ef          	jal	ra,ffffffffc020730a <schedule>
ffffffffc0208da6:	100027f3          	csrr	a5,sstatus
ffffffffc0208daa:	8b89                	andi	a5,a5,2
ffffffffc0208dac:	4401                	li	s0,0
ffffffffc0208dae:	ef8d                	bnez	a5,ffffffffc0208de8 <stdin_io+0xb8>
ffffffffc0208db0:	0028                	addi	a0,sp,8
ffffffffc0208db2:	845fb0ef          	jal	ra,ffffffffc02045f6 <wait_in_queue>
ffffffffc0208db6:	e121                	bnez	a0,ffffffffc0208df6 <stdin_io+0xc6>
ffffffffc0208db8:	47c2                	lw	a5,16(sp)
ffffffffc0208dba:	04979563          	bne	a5,s1,ffffffffc0208e04 <stdin_io+0xd4>
ffffffffc0208dbe:	0009b783          	ld	a5,0(s3)
ffffffffc0208dc2:	000a3703          	ld	a4,0(s4)
ffffffffc0208dc6:	06e7c863          	blt	a5,a4,ffffffffc0208e36 <stdin_io+0x106>
ffffffffc0208dca:	8626                	mv	a2,s1
ffffffffc0208dcc:	002c                	addi	a1,sp,8
ffffffffc0208dce:	854a                	mv	a0,s2
ffffffffc0208dd0:	951fb0ef          	jal	ra,ffffffffc0204720 <wait_current_set>
ffffffffc0208dd4:	d479                	beqz	s0,ffffffffc0208da2 <stdin_io+0x72>
ffffffffc0208dd6:	e97f70ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0208dda:	d30fe0ef          	jal	ra,ffffffffc020730a <schedule>
ffffffffc0208dde:	100027f3          	csrr	a5,sstatus
ffffffffc0208de2:	8b89                	andi	a5,a5,2
ffffffffc0208de4:	4401                	li	s0,0
ffffffffc0208de6:	d7e9                	beqz	a5,ffffffffc0208db0 <stdin_io+0x80>
ffffffffc0208de8:	e8bf70ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0208dec:	0028                	addi	a0,sp,8
ffffffffc0208dee:	4405                	li	s0,1
ffffffffc0208df0:	807fb0ef          	jal	ra,ffffffffc02045f6 <wait_in_queue>
ffffffffc0208df4:	d171                	beqz	a0,ffffffffc0208db8 <stdin_io+0x88>
ffffffffc0208df6:	002c                	addi	a1,sp,8
ffffffffc0208df8:	854a                	mv	a0,s2
ffffffffc0208dfa:	fa2fb0ef          	jal	ra,ffffffffc020459c <wait_queue_del>
ffffffffc0208dfe:	47c2                	lw	a5,16(sp)
ffffffffc0208e00:	fa978fe3          	beq	a5,s1,ffffffffc0208dbe <stdin_io+0x8e>
ffffffffc0208e04:	e435                	bnez	s0,ffffffffc0208e70 <stdin_io+0x140>
ffffffffc0208e06:	060b8963          	beqz	s7,ffffffffc0208e78 <stdin_io+0x148>
ffffffffc0208e0a:	018b3783          	ld	a5,24(s6)
ffffffffc0208e0e:	41578ab3          	sub	s5,a5,s5
ffffffffc0208e12:	015b3c23          	sd	s5,24(s6)
ffffffffc0208e16:	60ea                	ld	ra,152(sp)
ffffffffc0208e18:	644a                	ld	s0,144(sp)
ffffffffc0208e1a:	64aa                	ld	s1,136(sp)
ffffffffc0208e1c:	690a                	ld	s2,128(sp)
ffffffffc0208e1e:	79e6                	ld	s3,120(sp)
ffffffffc0208e20:	7a46                	ld	s4,112(sp)
ffffffffc0208e22:	7aa6                	ld	s5,104(sp)
ffffffffc0208e24:	7b06                	ld	s6,96(sp)
ffffffffc0208e26:	6c46                	ld	s8,80(sp)
ffffffffc0208e28:	6ca6                	ld	s9,72(sp)
ffffffffc0208e2a:	6d06                	ld	s10,64(sp)
ffffffffc0208e2c:	7de2                	ld	s11,56(sp)
ffffffffc0208e2e:	855e                	mv	a0,s7
ffffffffc0208e30:	6be6                	ld	s7,88(sp)
ffffffffc0208e32:	610d                	addi	sp,sp,160
ffffffffc0208e34:	8082                	ret
ffffffffc0208e36:	43f7d713          	srai	a4,a5,0x3f
ffffffffc0208e3a:	03475693          	srli	a3,a4,0x34
ffffffffc0208e3e:	00d78733          	add	a4,a5,a3
ffffffffc0208e42:	01977733          	and	a4,a4,s9
ffffffffc0208e46:	8f15                	sub	a4,a4,a3
ffffffffc0208e48:	0008d697          	auipc	a3,0x8d
ffffffffc0208e4c:	a2068693          	addi	a3,a3,-1504 # ffffffffc0295868 <stdin_buffer>
ffffffffc0208e50:	9736                	add	a4,a4,a3
ffffffffc0208e52:	00074683          	lbu	a3,0(a4)
ffffffffc0208e56:	0785                	addi	a5,a5,1
ffffffffc0208e58:	015d8733          	add	a4,s11,s5
ffffffffc0208e5c:	00d70023          	sb	a3,0(a4)
ffffffffc0208e60:	00f9b023          	sd	a5,0(s3)
ffffffffc0208e64:	0a85                	addi	s5,s5,1
ffffffffc0208e66:	001c0b9b          	addiw	s7,s8,1
ffffffffc0208e6a:	f3aae4e3          	bltu	s5,s10,ffffffffc0208d92 <stdin_io+0x62>
ffffffffc0208e6e:	dc51                	beqz	s0,ffffffffc0208e0a <stdin_io+0xda>
ffffffffc0208e70:	dfdf70ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0208e74:	f80b9be3          	bnez	s7,ffffffffc0208e0a <stdin_io+0xda>
ffffffffc0208e78:	4b81                	li	s7,0
ffffffffc0208e7a:	bf71                	j	ffffffffc0208e16 <stdin_io+0xe6>
ffffffffc0208e7c:	df7f70ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0208e80:	4405                	li	s0,1
ffffffffc0208e82:	ee0d14e3          	bnez	s10,ffffffffc0208d6a <stdin_io+0x3a>
ffffffffc0208e86:	de7f70ef          	jal	ra,ffffffffc0200c6c <intr_enable>
ffffffffc0208e8a:	4b81                	li	s7,0
ffffffffc0208e8c:	b769                	j	ffffffffc0208e16 <stdin_io+0xe6>
ffffffffc0208e8e:	5bf5                	li	s7,-3
ffffffffc0208e90:	b759                	j	ffffffffc0208e16 <stdin_io+0xe6>

ffffffffc0208e92 <dev_stdin_write>:
ffffffffc0208e92:	e111                	bnez	a0,ffffffffc0208e96 <dev_stdin_write+0x4>
ffffffffc0208e94:	8082                	ret
ffffffffc0208e96:	1101                	addi	sp,sp,-32
ffffffffc0208e98:	e822                	sd	s0,16(sp)
ffffffffc0208e9a:	ec06                	sd	ra,24(sp)
ffffffffc0208e9c:	e426                	sd	s1,8(sp)
ffffffffc0208e9e:	842a                	mv	s0,a0
ffffffffc0208ea0:	100027f3          	csrr	a5,sstatus
ffffffffc0208ea4:	8b89                	andi	a5,a5,2
ffffffffc0208ea6:	4481                	li	s1,0
ffffffffc0208ea8:	e3c1                	bnez	a5,ffffffffc0208f28 <dev_stdin_write+0x96>
ffffffffc0208eaa:	0008e597          	auipc	a1,0x8e
ffffffffc0208eae:	a5e58593          	addi	a1,a1,-1442 # ffffffffc0296908 <p_wpos>
ffffffffc0208eb2:	6198                	ld	a4,0(a1)
ffffffffc0208eb4:	6605                	lui	a2,0x1
ffffffffc0208eb6:	fff60513          	addi	a0,a2,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0208eba:	43f75693          	srai	a3,a4,0x3f
ffffffffc0208ebe:	92d1                	srli	a3,a3,0x34
ffffffffc0208ec0:	00d707b3          	add	a5,a4,a3
ffffffffc0208ec4:	8fe9                	and	a5,a5,a0
ffffffffc0208ec6:	8f95                	sub	a5,a5,a3
ffffffffc0208ec8:	0008d697          	auipc	a3,0x8d
ffffffffc0208ecc:	9a068693          	addi	a3,a3,-1632 # ffffffffc0295868 <stdin_buffer>
ffffffffc0208ed0:	97b6                	add	a5,a5,a3
ffffffffc0208ed2:	00878023          	sb	s0,0(a5)
ffffffffc0208ed6:	0008e797          	auipc	a5,0x8e
ffffffffc0208eda:	a2a7b783          	ld	a5,-1494(a5) # ffffffffc0296900 <p_rpos>
ffffffffc0208ede:	40f707b3          	sub	a5,a4,a5
ffffffffc0208ee2:	00c7d463          	bge	a5,a2,ffffffffc0208eea <dev_stdin_write+0x58>
ffffffffc0208ee6:	0705                	addi	a4,a4,1
ffffffffc0208ee8:	e198                	sd	a4,0(a1)
ffffffffc0208eea:	0008d517          	auipc	a0,0x8d
ffffffffc0208eee:	96e50513          	addi	a0,a0,-1682 # ffffffffc0295858 <__wait_queue>
ffffffffc0208ef2:	ef8fb0ef          	jal	ra,ffffffffc02045ea <wait_queue_empty>
ffffffffc0208ef6:	cd09                	beqz	a0,ffffffffc0208f10 <dev_stdin_write+0x7e>
ffffffffc0208ef8:	e491                	bnez	s1,ffffffffc0208f04 <dev_stdin_write+0x72>
ffffffffc0208efa:	60e2                	ld	ra,24(sp)
ffffffffc0208efc:	6442                	ld	s0,16(sp)
ffffffffc0208efe:	64a2                	ld	s1,8(sp)
ffffffffc0208f00:	6105                	addi	sp,sp,32
ffffffffc0208f02:	8082                	ret
ffffffffc0208f04:	6442                	ld	s0,16(sp)
ffffffffc0208f06:	60e2                	ld	ra,24(sp)
ffffffffc0208f08:	64a2                	ld	s1,8(sp)
ffffffffc0208f0a:	6105                	addi	sp,sp,32
ffffffffc0208f0c:	d61f706f          	j	ffffffffc0200c6c <intr_enable>
ffffffffc0208f10:	800005b7          	lui	a1,0x80000
ffffffffc0208f14:	4605                	li	a2,1
ffffffffc0208f16:	0591                	addi	a1,a1,4
ffffffffc0208f18:	0008d517          	auipc	a0,0x8d
ffffffffc0208f1c:	94050513          	addi	a0,a0,-1728 # ffffffffc0295858 <__wait_queue>
ffffffffc0208f20:	f32fb0ef          	jal	ra,ffffffffc0204652 <wakeup_queue>
ffffffffc0208f24:	d8f9                	beqz	s1,ffffffffc0208efa <dev_stdin_write+0x68>
ffffffffc0208f26:	bff9                	j	ffffffffc0208f04 <dev_stdin_write+0x72>
ffffffffc0208f28:	d4bf70ef          	jal	ra,ffffffffc0200c72 <intr_disable>
ffffffffc0208f2c:	4485                	li	s1,1
ffffffffc0208f2e:	bfb5                	j	ffffffffc0208eaa <dev_stdin_write+0x18>

ffffffffc0208f30 <dev_init_stdin>:
ffffffffc0208f30:	1141                	addi	sp,sp,-16
ffffffffc0208f32:	e406                	sd	ra,8(sp)
ffffffffc0208f34:	e022                	sd	s0,0(sp)
ffffffffc0208f36:	ac7ff0ef          	jal	ra,ffffffffc02089fc <dev_create_inode>
ffffffffc0208f3a:	c93d                	beqz	a0,ffffffffc0208fb0 <dev_init_stdin+0x80>
ffffffffc0208f3c:	4d38                	lw	a4,88(a0)
ffffffffc0208f3e:	6785                	lui	a5,0x1
ffffffffc0208f40:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208f44:	842a                	mv	s0,a0
ffffffffc0208f46:	08f71e63          	bne	a4,a5,ffffffffc0208fe2 <dev_init_stdin+0xb2>
ffffffffc0208f4a:	4785                	li	a5,1
ffffffffc0208f4c:	e41c                	sd	a5,8(s0)
ffffffffc0208f4e:	00000797          	auipc	a5,0x0
ffffffffc0208f52:	dd078793          	addi	a5,a5,-560 # ffffffffc0208d1e <stdin_open>
ffffffffc0208f56:	e81c                	sd	a5,16(s0)
ffffffffc0208f58:	00000797          	auipc	a5,0x0
ffffffffc0208f5c:	dd078793          	addi	a5,a5,-560 # ffffffffc0208d28 <stdin_close>
ffffffffc0208f60:	ec1c                	sd	a5,24(s0)
ffffffffc0208f62:	00000797          	auipc	a5,0x0
ffffffffc0208f66:	dce78793          	addi	a5,a5,-562 # ffffffffc0208d30 <stdin_io>
ffffffffc0208f6a:	f01c                	sd	a5,32(s0)
ffffffffc0208f6c:	00000797          	auipc	a5,0x0
ffffffffc0208f70:	dc078793          	addi	a5,a5,-576 # ffffffffc0208d2c <stdin_ioctl>
ffffffffc0208f74:	f41c                	sd	a5,40(s0)
ffffffffc0208f76:	0008d517          	auipc	a0,0x8d
ffffffffc0208f7a:	8e250513          	addi	a0,a0,-1822 # ffffffffc0295858 <__wait_queue>
ffffffffc0208f7e:	00043023          	sd	zero,0(s0)
ffffffffc0208f82:	0008e797          	auipc	a5,0x8e
ffffffffc0208f86:	9807b323          	sd	zero,-1658(a5) # ffffffffc0296908 <p_wpos>
ffffffffc0208f8a:	0008e797          	auipc	a5,0x8e
ffffffffc0208f8e:	9607bb23          	sd	zero,-1674(a5) # ffffffffc0296900 <p_rpos>
ffffffffc0208f92:	e04fb0ef          	jal	ra,ffffffffc0204596 <wait_queue_init>
ffffffffc0208f96:	4601                	li	a2,0
ffffffffc0208f98:	85a2                	mv	a1,s0
ffffffffc0208f9a:	00006517          	auipc	a0,0x6
ffffffffc0208f9e:	1ae50513          	addi	a0,a0,430 # ffffffffc020f148 <dev_node_ops+0x2a8>
ffffffffc0208fa2:	e6bfe0ef          	jal	ra,ffffffffc0207e0c <vfs_add_dev>
ffffffffc0208fa6:	e10d                	bnez	a0,ffffffffc0208fc8 <dev_init_stdin+0x98>
ffffffffc0208fa8:	60a2                	ld	ra,8(sp)
ffffffffc0208faa:	6402                	ld	s0,0(sp)
ffffffffc0208fac:	0141                	addi	sp,sp,16
ffffffffc0208fae:	8082                	ret
ffffffffc0208fb0:	00006617          	auipc	a2,0x6
ffffffffc0208fb4:	15860613          	addi	a2,a2,344 # ffffffffc020f108 <dev_node_ops+0x268>
ffffffffc0208fb8:	07500593          	li	a1,117
ffffffffc0208fbc:	00006517          	auipc	a0,0x6
ffffffffc0208fc0:	16c50513          	addi	a0,a0,364 # ffffffffc020f128 <dev_node_ops+0x288>
ffffffffc0208fc4:	cdaf70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0208fc8:	86aa                	mv	a3,a0
ffffffffc0208fca:	00006617          	auipc	a2,0x6
ffffffffc0208fce:	18660613          	addi	a2,a2,390 # ffffffffc020f150 <dev_node_ops+0x2b0>
ffffffffc0208fd2:	07b00593          	li	a1,123
ffffffffc0208fd6:	00006517          	auipc	a0,0x6
ffffffffc0208fda:	15250513          	addi	a0,a0,338 # ffffffffc020f128 <dev_node_ops+0x288>
ffffffffc0208fde:	cc0f70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0208fe2:	00006697          	auipc	a3,0x6
ffffffffc0208fe6:	b8e68693          	addi	a3,a3,-1138 # ffffffffc020eb70 <syscalls+0xb10>
ffffffffc0208fea:	00003617          	auipc	a2,0x3
ffffffffc0208fee:	efe60613          	addi	a2,a2,-258 # ffffffffc020bee8 <commands+0x210>
ffffffffc0208ff2:	07700593          	li	a1,119
ffffffffc0208ff6:	00006517          	auipc	a0,0x6
ffffffffc0208ffa:	13250513          	addi	a0,a0,306 # ffffffffc020f128 <dev_node_ops+0x288>
ffffffffc0208ffe:	ca0f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0209002 <stdout_open>:
ffffffffc0209002:	4785                	li	a5,1
ffffffffc0209004:	4501                	li	a0,0
ffffffffc0209006:	00f59363          	bne	a1,a5,ffffffffc020900c <stdout_open+0xa>
ffffffffc020900a:	8082                	ret
ffffffffc020900c:	5575                	li	a0,-3
ffffffffc020900e:	8082                	ret

ffffffffc0209010 <stdout_close>:
ffffffffc0209010:	4501                	li	a0,0
ffffffffc0209012:	8082                	ret

ffffffffc0209014 <stdout_ioctl>:
ffffffffc0209014:	5575                	li	a0,-3
ffffffffc0209016:	8082                	ret

ffffffffc0209018 <stdout_io>:
ffffffffc0209018:	ca05                	beqz	a2,ffffffffc0209048 <stdout_io+0x30>
ffffffffc020901a:	6d9c                	ld	a5,24(a1)
ffffffffc020901c:	1101                	addi	sp,sp,-32
ffffffffc020901e:	e822                	sd	s0,16(sp)
ffffffffc0209020:	e426                	sd	s1,8(sp)
ffffffffc0209022:	ec06                	sd	ra,24(sp)
ffffffffc0209024:	6180                	ld	s0,0(a1)
ffffffffc0209026:	84ae                	mv	s1,a1
ffffffffc0209028:	cb91                	beqz	a5,ffffffffc020903c <stdout_io+0x24>
ffffffffc020902a:	00044503          	lbu	a0,0(s0)
ffffffffc020902e:	0405                	addi	s0,s0,1
ffffffffc0209030:	9b2f70ef          	jal	ra,ffffffffc02001e2 <cputchar>
ffffffffc0209034:	6c9c                	ld	a5,24(s1)
ffffffffc0209036:	17fd                	addi	a5,a5,-1
ffffffffc0209038:	ec9c                	sd	a5,24(s1)
ffffffffc020903a:	fbe5                	bnez	a5,ffffffffc020902a <stdout_io+0x12>
ffffffffc020903c:	60e2                	ld	ra,24(sp)
ffffffffc020903e:	6442                	ld	s0,16(sp)
ffffffffc0209040:	64a2                	ld	s1,8(sp)
ffffffffc0209042:	4501                	li	a0,0
ffffffffc0209044:	6105                	addi	sp,sp,32
ffffffffc0209046:	8082                	ret
ffffffffc0209048:	5575                	li	a0,-3
ffffffffc020904a:	8082                	ret

ffffffffc020904c <dev_init_stdout>:
ffffffffc020904c:	1141                	addi	sp,sp,-16
ffffffffc020904e:	e406                	sd	ra,8(sp)
ffffffffc0209050:	9adff0ef          	jal	ra,ffffffffc02089fc <dev_create_inode>
ffffffffc0209054:	c939                	beqz	a0,ffffffffc02090aa <dev_init_stdout+0x5e>
ffffffffc0209056:	4d38                	lw	a4,88(a0)
ffffffffc0209058:	6785                	lui	a5,0x1
ffffffffc020905a:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc020905e:	85aa                	mv	a1,a0
ffffffffc0209060:	06f71e63          	bne	a4,a5,ffffffffc02090dc <dev_init_stdout+0x90>
ffffffffc0209064:	4785                	li	a5,1
ffffffffc0209066:	e51c                	sd	a5,8(a0)
ffffffffc0209068:	00000797          	auipc	a5,0x0
ffffffffc020906c:	f9a78793          	addi	a5,a5,-102 # ffffffffc0209002 <stdout_open>
ffffffffc0209070:	e91c                	sd	a5,16(a0)
ffffffffc0209072:	00000797          	auipc	a5,0x0
ffffffffc0209076:	f9e78793          	addi	a5,a5,-98 # ffffffffc0209010 <stdout_close>
ffffffffc020907a:	ed1c                	sd	a5,24(a0)
ffffffffc020907c:	00000797          	auipc	a5,0x0
ffffffffc0209080:	f9c78793          	addi	a5,a5,-100 # ffffffffc0209018 <stdout_io>
ffffffffc0209084:	f11c                	sd	a5,32(a0)
ffffffffc0209086:	00000797          	auipc	a5,0x0
ffffffffc020908a:	f8e78793          	addi	a5,a5,-114 # ffffffffc0209014 <stdout_ioctl>
ffffffffc020908e:	00053023          	sd	zero,0(a0)
ffffffffc0209092:	f51c                	sd	a5,40(a0)
ffffffffc0209094:	4601                	li	a2,0
ffffffffc0209096:	00006517          	auipc	a0,0x6
ffffffffc020909a:	11a50513          	addi	a0,a0,282 # ffffffffc020f1b0 <dev_node_ops+0x310>
ffffffffc020909e:	d6ffe0ef          	jal	ra,ffffffffc0207e0c <vfs_add_dev>
ffffffffc02090a2:	e105                	bnez	a0,ffffffffc02090c2 <dev_init_stdout+0x76>
ffffffffc02090a4:	60a2                	ld	ra,8(sp)
ffffffffc02090a6:	0141                	addi	sp,sp,16
ffffffffc02090a8:	8082                	ret
ffffffffc02090aa:	00006617          	auipc	a2,0x6
ffffffffc02090ae:	0c660613          	addi	a2,a2,198 # ffffffffc020f170 <dev_node_ops+0x2d0>
ffffffffc02090b2:	03700593          	li	a1,55
ffffffffc02090b6:	00006517          	auipc	a0,0x6
ffffffffc02090ba:	0da50513          	addi	a0,a0,218 # ffffffffc020f190 <dev_node_ops+0x2f0>
ffffffffc02090be:	be0f70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02090c2:	86aa                	mv	a3,a0
ffffffffc02090c4:	00006617          	auipc	a2,0x6
ffffffffc02090c8:	0f460613          	addi	a2,a2,244 # ffffffffc020f1b8 <dev_node_ops+0x318>
ffffffffc02090cc:	03d00593          	li	a1,61
ffffffffc02090d0:	00006517          	auipc	a0,0x6
ffffffffc02090d4:	0c050513          	addi	a0,a0,192 # ffffffffc020f190 <dev_node_ops+0x2f0>
ffffffffc02090d8:	bc6f70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02090dc:	00006697          	auipc	a3,0x6
ffffffffc02090e0:	a9468693          	addi	a3,a3,-1388 # ffffffffc020eb70 <syscalls+0xb10>
ffffffffc02090e4:	00003617          	auipc	a2,0x3
ffffffffc02090e8:	e0460613          	addi	a2,a2,-508 # ffffffffc020bee8 <commands+0x210>
ffffffffc02090ec:	03900593          	li	a1,57
ffffffffc02090f0:	00006517          	auipc	a0,0x6
ffffffffc02090f4:	0a050513          	addi	a0,a0,160 # ffffffffc020f190 <dev_node_ops+0x2f0>
ffffffffc02090f8:	ba6f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02090fc <bitmap_translate.part.0>:
ffffffffc02090fc:	1141                	addi	sp,sp,-16
ffffffffc02090fe:	00006697          	auipc	a3,0x6
ffffffffc0209102:	0da68693          	addi	a3,a3,218 # ffffffffc020f1d8 <dev_node_ops+0x338>
ffffffffc0209106:	00003617          	auipc	a2,0x3
ffffffffc020910a:	de260613          	addi	a2,a2,-542 # ffffffffc020bee8 <commands+0x210>
ffffffffc020910e:	04c00593          	li	a1,76
ffffffffc0209112:	00006517          	auipc	a0,0x6
ffffffffc0209116:	0de50513          	addi	a0,a0,222 # ffffffffc020f1f0 <dev_node_ops+0x350>
ffffffffc020911a:	e406                	sd	ra,8(sp)
ffffffffc020911c:	b82f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0209120 <bitmap_create>:
ffffffffc0209120:	7139                	addi	sp,sp,-64
ffffffffc0209122:	fc06                	sd	ra,56(sp)
ffffffffc0209124:	f822                	sd	s0,48(sp)
ffffffffc0209126:	f426                	sd	s1,40(sp)
ffffffffc0209128:	f04a                	sd	s2,32(sp)
ffffffffc020912a:	ec4e                	sd	s3,24(sp)
ffffffffc020912c:	e852                	sd	s4,16(sp)
ffffffffc020912e:	e456                	sd	s5,8(sp)
ffffffffc0209130:	c14d                	beqz	a0,ffffffffc02091d2 <bitmap_create+0xb2>
ffffffffc0209132:	842a                	mv	s0,a0
ffffffffc0209134:	4541                	li	a0,16
ffffffffc0209136:	e59f80ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc020913a:	84aa                	mv	s1,a0
ffffffffc020913c:	cd25                	beqz	a0,ffffffffc02091b4 <bitmap_create+0x94>
ffffffffc020913e:	02041a13          	slli	s4,s0,0x20
ffffffffc0209142:	020a5a13          	srli	s4,s4,0x20
ffffffffc0209146:	01fa0793          	addi	a5,s4,31
ffffffffc020914a:	0057d993          	srli	s3,a5,0x5
ffffffffc020914e:	00299a93          	slli	s5,s3,0x2
ffffffffc0209152:	8556                	mv	a0,s5
ffffffffc0209154:	894e                	mv	s2,s3
ffffffffc0209156:	e39f80ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc020915a:	c53d                	beqz	a0,ffffffffc02091c8 <bitmap_create+0xa8>
ffffffffc020915c:	0134a223          	sw	s3,4(s1) # ffffffff80000004 <_binary_bin_sfs_img_size+0xffffffff7ff8ad04>
ffffffffc0209160:	c080                	sw	s0,0(s1)
ffffffffc0209162:	8656                	mv	a2,s5
ffffffffc0209164:	0ff00593          	li	a1,255
ffffffffc0209168:	09d020ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc020916c:	e488                	sd	a0,8(s1)
ffffffffc020916e:	0996                	slli	s3,s3,0x5
ffffffffc0209170:	053a0263          	beq	s4,s3,ffffffffc02091b4 <bitmap_create+0x94>
ffffffffc0209174:	fff9079b          	addiw	a5,s2,-1
ffffffffc0209178:	0057969b          	slliw	a3,a5,0x5
ffffffffc020917c:	0054561b          	srliw	a2,s0,0x5
ffffffffc0209180:	40d4073b          	subw	a4,s0,a3
ffffffffc0209184:	0054541b          	srliw	s0,s0,0x5
ffffffffc0209188:	08f61463          	bne	a2,a5,ffffffffc0209210 <bitmap_create+0xf0>
ffffffffc020918c:	fff7069b          	addiw	a3,a4,-1
ffffffffc0209190:	47f9                	li	a5,30
ffffffffc0209192:	04d7ef63          	bltu	a5,a3,ffffffffc02091f0 <bitmap_create+0xd0>
ffffffffc0209196:	1402                	slli	s0,s0,0x20
ffffffffc0209198:	8079                	srli	s0,s0,0x1e
ffffffffc020919a:	9522                	add	a0,a0,s0
ffffffffc020919c:	411c                	lw	a5,0(a0)
ffffffffc020919e:	4585                	li	a1,1
ffffffffc02091a0:	02000613          	li	a2,32
ffffffffc02091a4:	00e596bb          	sllw	a3,a1,a4
ffffffffc02091a8:	8fb5                	xor	a5,a5,a3
ffffffffc02091aa:	2705                	addiw	a4,a4,1
ffffffffc02091ac:	2781                	sext.w	a5,a5
ffffffffc02091ae:	fec71be3          	bne	a4,a2,ffffffffc02091a4 <bitmap_create+0x84>
ffffffffc02091b2:	c11c                	sw	a5,0(a0)
ffffffffc02091b4:	70e2                	ld	ra,56(sp)
ffffffffc02091b6:	7442                	ld	s0,48(sp)
ffffffffc02091b8:	7902                	ld	s2,32(sp)
ffffffffc02091ba:	69e2                	ld	s3,24(sp)
ffffffffc02091bc:	6a42                	ld	s4,16(sp)
ffffffffc02091be:	6aa2                	ld	s5,8(sp)
ffffffffc02091c0:	8526                	mv	a0,s1
ffffffffc02091c2:	74a2                	ld	s1,40(sp)
ffffffffc02091c4:	6121                	addi	sp,sp,64
ffffffffc02091c6:	8082                	ret
ffffffffc02091c8:	8526                	mv	a0,s1
ffffffffc02091ca:	e75f80ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc02091ce:	4481                	li	s1,0
ffffffffc02091d0:	b7d5                	j	ffffffffc02091b4 <bitmap_create+0x94>
ffffffffc02091d2:	00006697          	auipc	a3,0x6
ffffffffc02091d6:	03668693          	addi	a3,a3,54 # ffffffffc020f208 <dev_node_ops+0x368>
ffffffffc02091da:	00003617          	auipc	a2,0x3
ffffffffc02091de:	d0e60613          	addi	a2,a2,-754 # ffffffffc020bee8 <commands+0x210>
ffffffffc02091e2:	45d5                	li	a1,21
ffffffffc02091e4:	00006517          	auipc	a0,0x6
ffffffffc02091e8:	00c50513          	addi	a0,a0,12 # ffffffffc020f1f0 <dev_node_ops+0x350>
ffffffffc02091ec:	ab2f70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02091f0:	00006697          	auipc	a3,0x6
ffffffffc02091f4:	05868693          	addi	a3,a3,88 # ffffffffc020f248 <dev_node_ops+0x3a8>
ffffffffc02091f8:	00003617          	auipc	a2,0x3
ffffffffc02091fc:	cf060613          	addi	a2,a2,-784 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209200:	02b00593          	li	a1,43
ffffffffc0209204:	00006517          	auipc	a0,0x6
ffffffffc0209208:	fec50513          	addi	a0,a0,-20 # ffffffffc020f1f0 <dev_node_ops+0x350>
ffffffffc020920c:	a92f70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209210:	00006697          	auipc	a3,0x6
ffffffffc0209214:	02068693          	addi	a3,a3,32 # ffffffffc020f230 <dev_node_ops+0x390>
ffffffffc0209218:	00003617          	auipc	a2,0x3
ffffffffc020921c:	cd060613          	addi	a2,a2,-816 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209220:	02a00593          	li	a1,42
ffffffffc0209224:	00006517          	auipc	a0,0x6
ffffffffc0209228:	fcc50513          	addi	a0,a0,-52 # ffffffffc020f1f0 <dev_node_ops+0x350>
ffffffffc020922c:	a72f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0209230 <bitmap_alloc>:
ffffffffc0209230:	4150                	lw	a2,4(a0)
ffffffffc0209232:	651c                	ld	a5,8(a0)
ffffffffc0209234:	c231                	beqz	a2,ffffffffc0209278 <bitmap_alloc+0x48>
ffffffffc0209236:	4701                	li	a4,0
ffffffffc0209238:	a029                	j	ffffffffc0209242 <bitmap_alloc+0x12>
ffffffffc020923a:	2705                	addiw	a4,a4,1
ffffffffc020923c:	0791                	addi	a5,a5,4
ffffffffc020923e:	02e60d63          	beq	a2,a4,ffffffffc0209278 <bitmap_alloc+0x48>
ffffffffc0209242:	4394                	lw	a3,0(a5)
ffffffffc0209244:	dafd                	beqz	a3,ffffffffc020923a <bitmap_alloc+0xa>
ffffffffc0209246:	4501                	li	a0,0
ffffffffc0209248:	4885                	li	a7,1
ffffffffc020924a:	8e36                	mv	t3,a3
ffffffffc020924c:	02000313          	li	t1,32
ffffffffc0209250:	a021                	j	ffffffffc0209258 <bitmap_alloc+0x28>
ffffffffc0209252:	2505                	addiw	a0,a0,1
ffffffffc0209254:	02650463          	beq	a0,t1,ffffffffc020927c <bitmap_alloc+0x4c>
ffffffffc0209258:	00a8983b          	sllw	a6,a7,a0
ffffffffc020925c:	0106f633          	and	a2,a3,a6
ffffffffc0209260:	2601                	sext.w	a2,a2
ffffffffc0209262:	da65                	beqz	a2,ffffffffc0209252 <bitmap_alloc+0x22>
ffffffffc0209264:	010e4833          	xor	a6,t3,a6
ffffffffc0209268:	0057171b          	slliw	a4,a4,0x5
ffffffffc020926c:	9f29                	addw	a4,a4,a0
ffffffffc020926e:	0107a023          	sw	a6,0(a5)
ffffffffc0209272:	c198                	sw	a4,0(a1)
ffffffffc0209274:	4501                	li	a0,0
ffffffffc0209276:	8082                	ret
ffffffffc0209278:	5571                	li	a0,-4
ffffffffc020927a:	8082                	ret
ffffffffc020927c:	1141                	addi	sp,sp,-16
ffffffffc020927e:	00004697          	auipc	a3,0x4
ffffffffc0209282:	cea68693          	addi	a3,a3,-790 # ffffffffc020cf68 <default_pmm_manager+0x598>
ffffffffc0209286:	00003617          	auipc	a2,0x3
ffffffffc020928a:	c6260613          	addi	a2,a2,-926 # ffffffffc020bee8 <commands+0x210>
ffffffffc020928e:	04300593          	li	a1,67
ffffffffc0209292:	00006517          	auipc	a0,0x6
ffffffffc0209296:	f5e50513          	addi	a0,a0,-162 # ffffffffc020f1f0 <dev_node_ops+0x350>
ffffffffc020929a:	e406                	sd	ra,8(sp)
ffffffffc020929c:	a02f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02092a0 <bitmap_test>:
ffffffffc02092a0:	411c                	lw	a5,0(a0)
ffffffffc02092a2:	00f5ff63          	bgeu	a1,a5,ffffffffc02092c0 <bitmap_test+0x20>
ffffffffc02092a6:	651c                	ld	a5,8(a0)
ffffffffc02092a8:	0055d71b          	srliw	a4,a1,0x5
ffffffffc02092ac:	070a                	slli	a4,a4,0x2
ffffffffc02092ae:	97ba                	add	a5,a5,a4
ffffffffc02092b0:	4388                	lw	a0,0(a5)
ffffffffc02092b2:	4785                	li	a5,1
ffffffffc02092b4:	00b795bb          	sllw	a1,a5,a1
ffffffffc02092b8:	8d6d                	and	a0,a0,a1
ffffffffc02092ba:	1502                	slli	a0,a0,0x20
ffffffffc02092bc:	9101                	srli	a0,a0,0x20
ffffffffc02092be:	8082                	ret
ffffffffc02092c0:	1141                	addi	sp,sp,-16
ffffffffc02092c2:	e406                	sd	ra,8(sp)
ffffffffc02092c4:	e39ff0ef          	jal	ra,ffffffffc02090fc <bitmap_translate.part.0>

ffffffffc02092c8 <bitmap_free>:
ffffffffc02092c8:	411c                	lw	a5,0(a0)
ffffffffc02092ca:	1141                	addi	sp,sp,-16
ffffffffc02092cc:	e406                	sd	ra,8(sp)
ffffffffc02092ce:	02f5f463          	bgeu	a1,a5,ffffffffc02092f6 <bitmap_free+0x2e>
ffffffffc02092d2:	651c                	ld	a5,8(a0)
ffffffffc02092d4:	0055d71b          	srliw	a4,a1,0x5
ffffffffc02092d8:	070a                	slli	a4,a4,0x2
ffffffffc02092da:	97ba                	add	a5,a5,a4
ffffffffc02092dc:	4398                	lw	a4,0(a5)
ffffffffc02092de:	4685                	li	a3,1
ffffffffc02092e0:	00b695bb          	sllw	a1,a3,a1
ffffffffc02092e4:	00b776b3          	and	a3,a4,a1
ffffffffc02092e8:	2681                	sext.w	a3,a3
ffffffffc02092ea:	ea81                	bnez	a3,ffffffffc02092fa <bitmap_free+0x32>
ffffffffc02092ec:	60a2                	ld	ra,8(sp)
ffffffffc02092ee:	8f4d                	or	a4,a4,a1
ffffffffc02092f0:	c398                	sw	a4,0(a5)
ffffffffc02092f2:	0141                	addi	sp,sp,16
ffffffffc02092f4:	8082                	ret
ffffffffc02092f6:	e07ff0ef          	jal	ra,ffffffffc02090fc <bitmap_translate.part.0>
ffffffffc02092fa:	00006697          	auipc	a3,0x6
ffffffffc02092fe:	f7668693          	addi	a3,a3,-138 # ffffffffc020f270 <dev_node_ops+0x3d0>
ffffffffc0209302:	00003617          	auipc	a2,0x3
ffffffffc0209306:	be660613          	addi	a2,a2,-1050 # ffffffffc020bee8 <commands+0x210>
ffffffffc020930a:	05f00593          	li	a1,95
ffffffffc020930e:	00006517          	auipc	a0,0x6
ffffffffc0209312:	ee250513          	addi	a0,a0,-286 # ffffffffc020f1f0 <dev_node_ops+0x350>
ffffffffc0209316:	988f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020931a <bitmap_destroy>:
ffffffffc020931a:	1141                	addi	sp,sp,-16
ffffffffc020931c:	e022                	sd	s0,0(sp)
ffffffffc020931e:	842a                	mv	s0,a0
ffffffffc0209320:	6508                	ld	a0,8(a0)
ffffffffc0209322:	e406                	sd	ra,8(sp)
ffffffffc0209324:	d1bf80ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc0209328:	8522                	mv	a0,s0
ffffffffc020932a:	6402                	ld	s0,0(sp)
ffffffffc020932c:	60a2                	ld	ra,8(sp)
ffffffffc020932e:	0141                	addi	sp,sp,16
ffffffffc0209330:	d0ff806f          	j	ffffffffc020203e <kfree>

ffffffffc0209334 <bitmap_getdata>:
ffffffffc0209334:	c589                	beqz	a1,ffffffffc020933e <bitmap_getdata+0xa>
ffffffffc0209336:	00456783          	lwu	a5,4(a0)
ffffffffc020933a:	078a                	slli	a5,a5,0x2
ffffffffc020933c:	e19c                	sd	a5,0(a1)
ffffffffc020933e:	6508                	ld	a0,8(a0)
ffffffffc0209340:	8082                	ret

ffffffffc0209342 <sfs_init>:
ffffffffc0209342:	1141                	addi	sp,sp,-16
ffffffffc0209344:	00006517          	auipc	a0,0x6
ffffffffc0209348:	d9c50513          	addi	a0,a0,-612 # ffffffffc020f0e0 <dev_node_ops+0x240>
ffffffffc020934c:	e406                	sd	ra,8(sp)
ffffffffc020934e:	554000ef          	jal	ra,ffffffffc02098a2 <sfs_mount>
ffffffffc0209352:	e501                	bnez	a0,ffffffffc020935a <sfs_init+0x18>
ffffffffc0209354:	60a2                	ld	ra,8(sp)
ffffffffc0209356:	0141                	addi	sp,sp,16
ffffffffc0209358:	8082                	ret
ffffffffc020935a:	86aa                	mv	a3,a0
ffffffffc020935c:	00006617          	auipc	a2,0x6
ffffffffc0209360:	f2460613          	addi	a2,a2,-220 # ffffffffc020f280 <dev_node_ops+0x3e0>
ffffffffc0209364:	45c1                	li	a1,16
ffffffffc0209366:	00006517          	auipc	a0,0x6
ffffffffc020936a:	f3a50513          	addi	a0,a0,-198 # ffffffffc020f2a0 <dev_node_ops+0x400>
ffffffffc020936e:	930f70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0209372 <sfs_unmount>:
ffffffffc0209372:	1141                	addi	sp,sp,-16
ffffffffc0209374:	e406                	sd	ra,8(sp)
ffffffffc0209376:	e022                	sd	s0,0(sp)
ffffffffc0209378:	cd1d                	beqz	a0,ffffffffc02093b6 <sfs_unmount+0x44>
ffffffffc020937a:	0b052783          	lw	a5,176(a0)
ffffffffc020937e:	842a                	mv	s0,a0
ffffffffc0209380:	eb9d                	bnez	a5,ffffffffc02093b6 <sfs_unmount+0x44>
ffffffffc0209382:	7158                	ld	a4,160(a0)
ffffffffc0209384:	09850793          	addi	a5,a0,152
ffffffffc0209388:	02f71563          	bne	a4,a5,ffffffffc02093b2 <sfs_unmount+0x40>
ffffffffc020938c:	613c                	ld	a5,64(a0)
ffffffffc020938e:	e7a1                	bnez	a5,ffffffffc02093d6 <sfs_unmount+0x64>
ffffffffc0209390:	7d08                	ld	a0,56(a0)
ffffffffc0209392:	f89ff0ef          	jal	ra,ffffffffc020931a <bitmap_destroy>
ffffffffc0209396:	6428                	ld	a0,72(s0)
ffffffffc0209398:	ca7f80ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020939c:	7448                	ld	a0,168(s0)
ffffffffc020939e:	ca1f80ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc02093a2:	8522                	mv	a0,s0
ffffffffc02093a4:	c9bf80ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc02093a8:	4501                	li	a0,0
ffffffffc02093aa:	60a2                	ld	ra,8(sp)
ffffffffc02093ac:	6402                	ld	s0,0(sp)
ffffffffc02093ae:	0141                	addi	sp,sp,16
ffffffffc02093b0:	8082                	ret
ffffffffc02093b2:	5545                	li	a0,-15
ffffffffc02093b4:	bfdd                	j	ffffffffc02093aa <sfs_unmount+0x38>
ffffffffc02093b6:	00006697          	auipc	a3,0x6
ffffffffc02093ba:	f0268693          	addi	a3,a3,-254 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc02093be:	00003617          	auipc	a2,0x3
ffffffffc02093c2:	b2a60613          	addi	a2,a2,-1238 # ffffffffc020bee8 <commands+0x210>
ffffffffc02093c6:	04100593          	li	a1,65
ffffffffc02093ca:	00006517          	auipc	a0,0x6
ffffffffc02093ce:	f1e50513          	addi	a0,a0,-226 # ffffffffc020f2e8 <dev_node_ops+0x448>
ffffffffc02093d2:	8ccf70ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02093d6:	00006697          	auipc	a3,0x6
ffffffffc02093da:	f2a68693          	addi	a3,a3,-214 # ffffffffc020f300 <dev_node_ops+0x460>
ffffffffc02093de:	00003617          	auipc	a2,0x3
ffffffffc02093e2:	b0a60613          	addi	a2,a2,-1270 # ffffffffc020bee8 <commands+0x210>
ffffffffc02093e6:	04500593          	li	a1,69
ffffffffc02093ea:	00006517          	auipc	a0,0x6
ffffffffc02093ee:	efe50513          	addi	a0,a0,-258 # ffffffffc020f2e8 <dev_node_ops+0x448>
ffffffffc02093f2:	8acf70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02093f6 <sfs_cleanup>:
ffffffffc02093f6:	1101                	addi	sp,sp,-32
ffffffffc02093f8:	ec06                	sd	ra,24(sp)
ffffffffc02093fa:	e822                	sd	s0,16(sp)
ffffffffc02093fc:	e426                	sd	s1,8(sp)
ffffffffc02093fe:	e04a                	sd	s2,0(sp)
ffffffffc0209400:	c525                	beqz	a0,ffffffffc0209468 <sfs_cleanup+0x72>
ffffffffc0209402:	0b052783          	lw	a5,176(a0)
ffffffffc0209406:	84aa                	mv	s1,a0
ffffffffc0209408:	e3a5                	bnez	a5,ffffffffc0209468 <sfs_cleanup+0x72>
ffffffffc020940a:	4158                	lw	a4,4(a0)
ffffffffc020940c:	4514                	lw	a3,8(a0)
ffffffffc020940e:	00c50913          	addi	s2,a0,12
ffffffffc0209412:	85ca                	mv	a1,s2
ffffffffc0209414:	40d7063b          	subw	a2,a4,a3
ffffffffc0209418:	00006517          	auipc	a0,0x6
ffffffffc020941c:	f0050513          	addi	a0,a0,-256 # ffffffffc020f318 <dev_node_ops+0x478>
ffffffffc0209420:	d87f60ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0209424:	02000413          	li	s0,32
ffffffffc0209428:	a019                	j	ffffffffc020942e <sfs_cleanup+0x38>
ffffffffc020942a:	347d                	addiw	s0,s0,-1
ffffffffc020942c:	c819                	beqz	s0,ffffffffc0209442 <sfs_cleanup+0x4c>
ffffffffc020942e:	7cdc                	ld	a5,184(s1)
ffffffffc0209430:	8526                	mv	a0,s1
ffffffffc0209432:	9782                	jalr	a5
ffffffffc0209434:	f97d                	bnez	a0,ffffffffc020942a <sfs_cleanup+0x34>
ffffffffc0209436:	60e2                	ld	ra,24(sp)
ffffffffc0209438:	6442                	ld	s0,16(sp)
ffffffffc020943a:	64a2                	ld	s1,8(sp)
ffffffffc020943c:	6902                	ld	s2,0(sp)
ffffffffc020943e:	6105                	addi	sp,sp,32
ffffffffc0209440:	8082                	ret
ffffffffc0209442:	6442                	ld	s0,16(sp)
ffffffffc0209444:	60e2                	ld	ra,24(sp)
ffffffffc0209446:	64a2                	ld	s1,8(sp)
ffffffffc0209448:	86ca                	mv	a3,s2
ffffffffc020944a:	6902                	ld	s2,0(sp)
ffffffffc020944c:	872a                	mv	a4,a0
ffffffffc020944e:	00006617          	auipc	a2,0x6
ffffffffc0209452:	eea60613          	addi	a2,a2,-278 # ffffffffc020f338 <dev_node_ops+0x498>
ffffffffc0209456:	05f00593          	li	a1,95
ffffffffc020945a:	00006517          	auipc	a0,0x6
ffffffffc020945e:	e8e50513          	addi	a0,a0,-370 # ffffffffc020f2e8 <dev_node_ops+0x448>
ffffffffc0209462:	6105                	addi	sp,sp,32
ffffffffc0209464:	8a2f706f          	j	ffffffffc0200506 <__warn>
ffffffffc0209468:	00006697          	auipc	a3,0x6
ffffffffc020946c:	e5068693          	addi	a3,a3,-432 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc0209470:	00003617          	auipc	a2,0x3
ffffffffc0209474:	a7860613          	addi	a2,a2,-1416 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209478:	05400593          	li	a1,84
ffffffffc020947c:	00006517          	auipc	a0,0x6
ffffffffc0209480:	e6c50513          	addi	a0,a0,-404 # ffffffffc020f2e8 <dev_node_ops+0x448>
ffffffffc0209484:	81af70ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0209488 <sfs_sync>:
ffffffffc0209488:	7179                	addi	sp,sp,-48
ffffffffc020948a:	f406                	sd	ra,40(sp)
ffffffffc020948c:	f022                	sd	s0,32(sp)
ffffffffc020948e:	ec26                	sd	s1,24(sp)
ffffffffc0209490:	e84a                	sd	s2,16(sp)
ffffffffc0209492:	e44e                	sd	s3,8(sp)
ffffffffc0209494:	e052                	sd	s4,0(sp)
ffffffffc0209496:	cd4d                	beqz	a0,ffffffffc0209550 <sfs_sync+0xc8>
ffffffffc0209498:	0b052783          	lw	a5,176(a0)
ffffffffc020949c:	8a2a                	mv	s4,a0
ffffffffc020949e:	ebcd                	bnez	a5,ffffffffc0209550 <sfs_sync+0xc8>
ffffffffc02094a0:	7e9010ef          	jal	ra,ffffffffc020b488 <lock_sfs_fs>
ffffffffc02094a4:	0a0a3403          	ld	s0,160(s4)
ffffffffc02094a8:	098a0913          	addi	s2,s4,152
ffffffffc02094ac:	02890763          	beq	s2,s0,ffffffffc02094da <sfs_sync+0x52>
ffffffffc02094b0:	00004997          	auipc	s3,0x4
ffffffffc02094b4:	3c098993          	addi	s3,s3,960 # ffffffffc020d870 <default_pmm_manager+0xea0>
ffffffffc02094b8:	7c1c                	ld	a5,56(s0)
ffffffffc02094ba:	fc840493          	addi	s1,s0,-56
ffffffffc02094be:	cbb5                	beqz	a5,ffffffffc0209532 <sfs_sync+0xaa>
ffffffffc02094c0:	7b9c                	ld	a5,48(a5)
ffffffffc02094c2:	cba5                	beqz	a5,ffffffffc0209532 <sfs_sync+0xaa>
ffffffffc02094c4:	85ce                	mv	a1,s3
ffffffffc02094c6:	8526                	mv	a0,s1
ffffffffc02094c8:	b7cfe0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc02094cc:	7c1c                	ld	a5,56(s0)
ffffffffc02094ce:	8526                	mv	a0,s1
ffffffffc02094d0:	7b9c                	ld	a5,48(a5)
ffffffffc02094d2:	9782                	jalr	a5
ffffffffc02094d4:	6400                	ld	s0,8(s0)
ffffffffc02094d6:	fe8911e3          	bne	s2,s0,ffffffffc02094b8 <sfs_sync+0x30>
ffffffffc02094da:	8552                	mv	a0,s4
ffffffffc02094dc:	7bd010ef          	jal	ra,ffffffffc020b498 <unlock_sfs_fs>
ffffffffc02094e0:	040a3783          	ld	a5,64(s4)
ffffffffc02094e4:	4501                	li	a0,0
ffffffffc02094e6:	eb89                	bnez	a5,ffffffffc02094f8 <sfs_sync+0x70>
ffffffffc02094e8:	70a2                	ld	ra,40(sp)
ffffffffc02094ea:	7402                	ld	s0,32(sp)
ffffffffc02094ec:	64e2                	ld	s1,24(sp)
ffffffffc02094ee:	6942                	ld	s2,16(sp)
ffffffffc02094f0:	69a2                	ld	s3,8(sp)
ffffffffc02094f2:	6a02                	ld	s4,0(sp)
ffffffffc02094f4:	6145                	addi	sp,sp,48
ffffffffc02094f6:	8082                	ret
ffffffffc02094f8:	040a3023          	sd	zero,64(s4)
ffffffffc02094fc:	8552                	mv	a0,s4
ffffffffc02094fe:	66f010ef          	jal	ra,ffffffffc020b36c <sfs_sync_super>
ffffffffc0209502:	cd01                	beqz	a0,ffffffffc020951a <sfs_sync+0x92>
ffffffffc0209504:	70a2                	ld	ra,40(sp)
ffffffffc0209506:	7402                	ld	s0,32(sp)
ffffffffc0209508:	4785                	li	a5,1
ffffffffc020950a:	04fa3023          	sd	a5,64(s4)
ffffffffc020950e:	64e2                	ld	s1,24(sp)
ffffffffc0209510:	6942                	ld	s2,16(sp)
ffffffffc0209512:	69a2                	ld	s3,8(sp)
ffffffffc0209514:	6a02                	ld	s4,0(sp)
ffffffffc0209516:	6145                	addi	sp,sp,48
ffffffffc0209518:	8082                	ret
ffffffffc020951a:	8552                	mv	a0,s4
ffffffffc020951c:	697010ef          	jal	ra,ffffffffc020b3b2 <sfs_sync_freemap>
ffffffffc0209520:	f175                	bnez	a0,ffffffffc0209504 <sfs_sync+0x7c>
ffffffffc0209522:	70a2                	ld	ra,40(sp)
ffffffffc0209524:	7402                	ld	s0,32(sp)
ffffffffc0209526:	64e2                	ld	s1,24(sp)
ffffffffc0209528:	6942                	ld	s2,16(sp)
ffffffffc020952a:	69a2                	ld	s3,8(sp)
ffffffffc020952c:	6a02                	ld	s4,0(sp)
ffffffffc020952e:	6145                	addi	sp,sp,48
ffffffffc0209530:	8082                	ret
ffffffffc0209532:	00004697          	auipc	a3,0x4
ffffffffc0209536:	2ee68693          	addi	a3,a3,750 # ffffffffc020d820 <default_pmm_manager+0xe50>
ffffffffc020953a:	00003617          	auipc	a2,0x3
ffffffffc020953e:	9ae60613          	addi	a2,a2,-1618 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209542:	45ed                	li	a1,27
ffffffffc0209544:	00006517          	auipc	a0,0x6
ffffffffc0209548:	da450513          	addi	a0,a0,-604 # ffffffffc020f2e8 <dev_node_ops+0x448>
ffffffffc020954c:	f53f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209550:	00006697          	auipc	a3,0x6
ffffffffc0209554:	d6868693          	addi	a3,a3,-664 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc0209558:	00003617          	auipc	a2,0x3
ffffffffc020955c:	99060613          	addi	a2,a2,-1648 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209560:	45d5                	li	a1,21
ffffffffc0209562:	00006517          	auipc	a0,0x6
ffffffffc0209566:	d8650513          	addi	a0,a0,-634 # ffffffffc020f2e8 <dev_node_ops+0x448>
ffffffffc020956a:	f35f60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020956e <sfs_get_root>:
ffffffffc020956e:	1101                	addi	sp,sp,-32
ffffffffc0209570:	ec06                	sd	ra,24(sp)
ffffffffc0209572:	cd09                	beqz	a0,ffffffffc020958c <sfs_get_root+0x1e>
ffffffffc0209574:	0b052783          	lw	a5,176(a0)
ffffffffc0209578:	eb91                	bnez	a5,ffffffffc020958c <sfs_get_root+0x1e>
ffffffffc020957a:	4605                	li	a2,1
ffffffffc020957c:	002c                	addi	a1,sp,8
ffffffffc020957e:	618010ef          	jal	ra,ffffffffc020ab96 <sfs_load_inode>
ffffffffc0209582:	e50d                	bnez	a0,ffffffffc02095ac <sfs_get_root+0x3e>
ffffffffc0209584:	60e2                	ld	ra,24(sp)
ffffffffc0209586:	6522                	ld	a0,8(sp)
ffffffffc0209588:	6105                	addi	sp,sp,32
ffffffffc020958a:	8082                	ret
ffffffffc020958c:	00006697          	auipc	a3,0x6
ffffffffc0209590:	d2c68693          	addi	a3,a3,-724 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc0209594:	00003617          	auipc	a2,0x3
ffffffffc0209598:	95460613          	addi	a2,a2,-1708 # ffffffffc020bee8 <commands+0x210>
ffffffffc020959c:	03600593          	li	a1,54
ffffffffc02095a0:	00006517          	auipc	a0,0x6
ffffffffc02095a4:	d4850513          	addi	a0,a0,-696 # ffffffffc020f2e8 <dev_node_ops+0x448>
ffffffffc02095a8:	ef7f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02095ac:	86aa                	mv	a3,a0
ffffffffc02095ae:	00006617          	auipc	a2,0x6
ffffffffc02095b2:	daa60613          	addi	a2,a2,-598 # ffffffffc020f358 <dev_node_ops+0x4b8>
ffffffffc02095b6:	03700593          	li	a1,55
ffffffffc02095ba:	00006517          	auipc	a0,0x6
ffffffffc02095be:	d2e50513          	addi	a0,a0,-722 # ffffffffc020f2e8 <dev_node_ops+0x448>
ffffffffc02095c2:	eddf60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02095c6 <sfs_do_mount>:
ffffffffc02095c6:	6518                	ld	a4,8(a0)
ffffffffc02095c8:	7171                	addi	sp,sp,-176
ffffffffc02095ca:	f506                	sd	ra,168(sp)
ffffffffc02095cc:	f122                	sd	s0,160(sp)
ffffffffc02095ce:	ed26                	sd	s1,152(sp)
ffffffffc02095d0:	e94a                	sd	s2,144(sp)
ffffffffc02095d2:	e54e                	sd	s3,136(sp)
ffffffffc02095d4:	e152                	sd	s4,128(sp)
ffffffffc02095d6:	fcd6                	sd	s5,120(sp)
ffffffffc02095d8:	f8da                	sd	s6,112(sp)
ffffffffc02095da:	f4de                	sd	s7,104(sp)
ffffffffc02095dc:	f0e2                	sd	s8,96(sp)
ffffffffc02095de:	ece6                	sd	s9,88(sp)
ffffffffc02095e0:	e8ea                	sd	s10,80(sp)
ffffffffc02095e2:	e4ee                	sd	s11,72(sp)
ffffffffc02095e4:	6785                	lui	a5,0x1
ffffffffc02095e6:	24f71663          	bne	a4,a5,ffffffffc0209832 <sfs_do_mount+0x26c>
ffffffffc02095ea:	892a                	mv	s2,a0
ffffffffc02095ec:	4501                	li	a0,0
ffffffffc02095ee:	8aae                	mv	s5,a1
ffffffffc02095f0:	c54fe0ef          	jal	ra,ffffffffc0207a44 <__alloc_fs>
ffffffffc02095f4:	842a                	mv	s0,a0
ffffffffc02095f6:	24050463          	beqz	a0,ffffffffc020983e <sfs_do_mount+0x278>
ffffffffc02095fa:	0b052b03          	lw	s6,176(a0)
ffffffffc02095fe:	260b1263          	bnez	s6,ffffffffc0209862 <sfs_do_mount+0x29c>
ffffffffc0209602:	03253823          	sd	s2,48(a0)
ffffffffc0209606:	6505                	lui	a0,0x1
ffffffffc0209608:	987f80ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc020960c:	e428                	sd	a0,72(s0)
ffffffffc020960e:	84aa                	mv	s1,a0
ffffffffc0209610:	16050363          	beqz	a0,ffffffffc0209776 <sfs_do_mount+0x1b0>
ffffffffc0209614:	85aa                	mv	a1,a0
ffffffffc0209616:	4681                	li	a3,0
ffffffffc0209618:	6605                	lui	a2,0x1
ffffffffc020961a:	1008                	addi	a0,sp,32
ffffffffc020961c:	dc7fb0ef          	jal	ra,ffffffffc02053e2 <iobuf_init>
ffffffffc0209620:	02093783          	ld	a5,32(s2)
ffffffffc0209624:	85aa                	mv	a1,a0
ffffffffc0209626:	4601                	li	a2,0
ffffffffc0209628:	854a                	mv	a0,s2
ffffffffc020962a:	9782                	jalr	a5
ffffffffc020962c:	8a2a                	mv	s4,a0
ffffffffc020962e:	10051e63          	bnez	a0,ffffffffc020974a <sfs_do_mount+0x184>
ffffffffc0209632:	408c                	lw	a1,0(s1)
ffffffffc0209634:	2f8dc637          	lui	a2,0x2f8dc
ffffffffc0209638:	e2a60613          	addi	a2,a2,-470 # 2f8dbe2a <_binary_bin_sfs_img_size+0x2f866b2a>
ffffffffc020963c:	14c59863          	bne	a1,a2,ffffffffc020978c <sfs_do_mount+0x1c6>
ffffffffc0209640:	40dc                	lw	a5,4(s1)
ffffffffc0209642:	00093603          	ld	a2,0(s2)
ffffffffc0209646:	02079713          	slli	a4,a5,0x20
ffffffffc020964a:	9301                	srli	a4,a4,0x20
ffffffffc020964c:	12e66763          	bltu	a2,a4,ffffffffc020977a <sfs_do_mount+0x1b4>
ffffffffc0209650:	020485a3          	sb	zero,43(s1)
ffffffffc0209654:	0084af03          	lw	t5,8(s1)
ffffffffc0209658:	00c4ae83          	lw	t4,12(s1)
ffffffffc020965c:	0104ae03          	lw	t3,16(s1)
ffffffffc0209660:	0144a303          	lw	t1,20(s1)
ffffffffc0209664:	0184a883          	lw	a7,24(s1)
ffffffffc0209668:	01c4a803          	lw	a6,28(s1)
ffffffffc020966c:	5090                	lw	a2,32(s1)
ffffffffc020966e:	50d4                	lw	a3,36(s1)
ffffffffc0209670:	5498                	lw	a4,40(s1)
ffffffffc0209672:	6511                	lui	a0,0x4
ffffffffc0209674:	c00c                	sw	a1,0(s0)
ffffffffc0209676:	c05c                	sw	a5,4(s0)
ffffffffc0209678:	01e42423          	sw	t5,8(s0)
ffffffffc020967c:	01d42623          	sw	t4,12(s0)
ffffffffc0209680:	01c42823          	sw	t3,16(s0)
ffffffffc0209684:	00642a23          	sw	t1,20(s0)
ffffffffc0209688:	01142c23          	sw	a7,24(s0)
ffffffffc020968c:	01042e23          	sw	a6,28(s0)
ffffffffc0209690:	d010                	sw	a2,32(s0)
ffffffffc0209692:	d054                	sw	a3,36(s0)
ffffffffc0209694:	d418                	sw	a4,40(s0)
ffffffffc0209696:	8f9f80ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc020969a:	f448                	sd	a0,168(s0)
ffffffffc020969c:	8c2a                	mv	s8,a0
ffffffffc020969e:	18050c63          	beqz	a0,ffffffffc0209836 <sfs_do_mount+0x270>
ffffffffc02096a2:	6711                	lui	a4,0x4
ffffffffc02096a4:	87aa                	mv	a5,a0
ffffffffc02096a6:	972a                	add	a4,a4,a0
ffffffffc02096a8:	e79c                	sd	a5,8(a5)
ffffffffc02096aa:	e39c                	sd	a5,0(a5)
ffffffffc02096ac:	07c1                	addi	a5,a5,16
ffffffffc02096ae:	fee79de3          	bne	a5,a4,ffffffffc02096a8 <sfs_do_mount+0xe2>
ffffffffc02096b2:	0044eb83          	lwu	s7,4(s1)
ffffffffc02096b6:	67a1                	lui	a5,0x8
ffffffffc02096b8:	fff78993          	addi	s3,a5,-1 # 7fff <_binary_bin_swap_img_size+0x2ff>
ffffffffc02096bc:	9bce                	add	s7,s7,s3
ffffffffc02096be:	77e1                	lui	a5,0xffff8
ffffffffc02096c0:	00fbfbb3          	and	s7,s7,a5
ffffffffc02096c4:	2b81                	sext.w	s7,s7
ffffffffc02096c6:	855e                	mv	a0,s7
ffffffffc02096c8:	a59ff0ef          	jal	ra,ffffffffc0209120 <bitmap_create>
ffffffffc02096cc:	fc08                	sd	a0,56(s0)
ffffffffc02096ce:	8d2a                	mv	s10,a0
ffffffffc02096d0:	14050f63          	beqz	a0,ffffffffc020982e <sfs_do_mount+0x268>
ffffffffc02096d4:	0044e783          	lwu	a5,4(s1)
ffffffffc02096d8:	082c                	addi	a1,sp,24
ffffffffc02096da:	97ce                	add	a5,a5,s3
ffffffffc02096dc:	00f7d713          	srli	a4,a5,0xf
ffffffffc02096e0:	e43a                	sd	a4,8(sp)
ffffffffc02096e2:	40f7d993          	srai	s3,a5,0xf
ffffffffc02096e6:	c4fff0ef          	jal	ra,ffffffffc0209334 <bitmap_getdata>
ffffffffc02096ea:	14050c63          	beqz	a0,ffffffffc0209842 <sfs_do_mount+0x27c>
ffffffffc02096ee:	00c9979b          	slliw	a5,s3,0xc
ffffffffc02096f2:	66e2                	ld	a3,24(sp)
ffffffffc02096f4:	1782                	slli	a5,a5,0x20
ffffffffc02096f6:	9381                	srli	a5,a5,0x20
ffffffffc02096f8:	14d79563          	bne	a5,a3,ffffffffc0209842 <sfs_do_mount+0x27c>
ffffffffc02096fc:	6722                	ld	a4,8(sp)
ffffffffc02096fe:	6d89                	lui	s11,0x2
ffffffffc0209700:	89aa                	mv	s3,a0
ffffffffc0209702:	00c71c93          	slli	s9,a4,0xc
ffffffffc0209706:	9caa                	add	s9,s9,a0
ffffffffc0209708:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020970c:	e711                	bnez	a4,ffffffffc0209718 <sfs_do_mount+0x152>
ffffffffc020970e:	a079                	j	ffffffffc020979c <sfs_do_mount+0x1d6>
ffffffffc0209710:	6785                	lui	a5,0x1
ffffffffc0209712:	99be                	add	s3,s3,a5
ffffffffc0209714:	093c8463          	beq	s9,s3,ffffffffc020979c <sfs_do_mount+0x1d6>
ffffffffc0209718:	013d86bb          	addw	a3,s11,s3
ffffffffc020971c:	1682                	slli	a3,a3,0x20
ffffffffc020971e:	6605                	lui	a2,0x1
ffffffffc0209720:	85ce                	mv	a1,s3
ffffffffc0209722:	9281                	srli	a3,a3,0x20
ffffffffc0209724:	1008                	addi	a0,sp,32
ffffffffc0209726:	cbdfb0ef          	jal	ra,ffffffffc02053e2 <iobuf_init>
ffffffffc020972a:	02093783          	ld	a5,32(s2)
ffffffffc020972e:	85aa                	mv	a1,a0
ffffffffc0209730:	4601                	li	a2,0
ffffffffc0209732:	854a                	mv	a0,s2
ffffffffc0209734:	9782                	jalr	a5
ffffffffc0209736:	dd69                	beqz	a0,ffffffffc0209710 <sfs_do_mount+0x14a>
ffffffffc0209738:	e42a                	sd	a0,8(sp)
ffffffffc020973a:	856a                	mv	a0,s10
ffffffffc020973c:	bdfff0ef          	jal	ra,ffffffffc020931a <bitmap_destroy>
ffffffffc0209740:	67a2                	ld	a5,8(sp)
ffffffffc0209742:	8a3e                	mv	s4,a5
ffffffffc0209744:	8562                	mv	a0,s8
ffffffffc0209746:	8f9f80ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020974a:	8526                	mv	a0,s1
ffffffffc020974c:	8f3f80ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc0209750:	8522                	mv	a0,s0
ffffffffc0209752:	8edf80ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc0209756:	70aa                	ld	ra,168(sp)
ffffffffc0209758:	740a                	ld	s0,160(sp)
ffffffffc020975a:	64ea                	ld	s1,152(sp)
ffffffffc020975c:	694a                	ld	s2,144(sp)
ffffffffc020975e:	69aa                	ld	s3,136(sp)
ffffffffc0209760:	7ae6                	ld	s5,120(sp)
ffffffffc0209762:	7b46                	ld	s6,112(sp)
ffffffffc0209764:	7ba6                	ld	s7,104(sp)
ffffffffc0209766:	7c06                	ld	s8,96(sp)
ffffffffc0209768:	6ce6                	ld	s9,88(sp)
ffffffffc020976a:	6d46                	ld	s10,80(sp)
ffffffffc020976c:	6da6                	ld	s11,72(sp)
ffffffffc020976e:	8552                	mv	a0,s4
ffffffffc0209770:	6a0a                	ld	s4,128(sp)
ffffffffc0209772:	614d                	addi	sp,sp,176
ffffffffc0209774:	8082                	ret
ffffffffc0209776:	5a71                	li	s4,-4
ffffffffc0209778:	bfe1                	j	ffffffffc0209750 <sfs_do_mount+0x18a>
ffffffffc020977a:	85be                	mv	a1,a5
ffffffffc020977c:	00006517          	auipc	a0,0x6
ffffffffc0209780:	c3450513          	addi	a0,a0,-972 # ffffffffc020f3b0 <dev_node_ops+0x510>
ffffffffc0209784:	a23f60ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0209788:	5a75                	li	s4,-3
ffffffffc020978a:	b7c1                	j	ffffffffc020974a <sfs_do_mount+0x184>
ffffffffc020978c:	00006517          	auipc	a0,0x6
ffffffffc0209790:	bec50513          	addi	a0,a0,-1044 # ffffffffc020f378 <dev_node_ops+0x4d8>
ffffffffc0209794:	a13f60ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0209798:	5a75                	li	s4,-3
ffffffffc020979a:	bf45                	j	ffffffffc020974a <sfs_do_mount+0x184>
ffffffffc020979c:	00442903          	lw	s2,4(s0)
ffffffffc02097a0:	4481                	li	s1,0
ffffffffc02097a2:	080b8c63          	beqz	s7,ffffffffc020983a <sfs_do_mount+0x274>
ffffffffc02097a6:	85a6                	mv	a1,s1
ffffffffc02097a8:	856a                	mv	a0,s10
ffffffffc02097aa:	af7ff0ef          	jal	ra,ffffffffc02092a0 <bitmap_test>
ffffffffc02097ae:	c111                	beqz	a0,ffffffffc02097b2 <sfs_do_mount+0x1ec>
ffffffffc02097b0:	2b05                	addiw	s6,s6,1
ffffffffc02097b2:	2485                	addiw	s1,s1,1
ffffffffc02097b4:	fe9b99e3          	bne	s7,s1,ffffffffc02097a6 <sfs_do_mount+0x1e0>
ffffffffc02097b8:	441c                	lw	a5,8(s0)
ffffffffc02097ba:	0d679463          	bne	a5,s6,ffffffffc0209882 <sfs_do_mount+0x2bc>
ffffffffc02097be:	4585                	li	a1,1
ffffffffc02097c0:	05040513          	addi	a0,s0,80
ffffffffc02097c4:	04043023          	sd	zero,64(s0)
ffffffffc02097c8:	d93fa0ef          	jal	ra,ffffffffc020455a <sem_init>
ffffffffc02097cc:	4585                	li	a1,1
ffffffffc02097ce:	06840513          	addi	a0,s0,104
ffffffffc02097d2:	d89fa0ef          	jal	ra,ffffffffc020455a <sem_init>
ffffffffc02097d6:	4585                	li	a1,1
ffffffffc02097d8:	08040513          	addi	a0,s0,128
ffffffffc02097dc:	d7ffa0ef          	jal	ra,ffffffffc020455a <sem_init>
ffffffffc02097e0:	09840793          	addi	a5,s0,152
ffffffffc02097e4:	f05c                	sd	a5,160(s0)
ffffffffc02097e6:	ec5c                	sd	a5,152(s0)
ffffffffc02097e8:	874a                	mv	a4,s2
ffffffffc02097ea:	86da                	mv	a3,s6
ffffffffc02097ec:	4169063b          	subw	a2,s2,s6
ffffffffc02097f0:	00c40593          	addi	a1,s0,12
ffffffffc02097f4:	00006517          	auipc	a0,0x6
ffffffffc02097f8:	c4c50513          	addi	a0,a0,-948 # ffffffffc020f440 <dev_node_ops+0x5a0>
ffffffffc02097fc:	9abf60ef          	jal	ra,ffffffffc02001a6 <cprintf>
ffffffffc0209800:	00000797          	auipc	a5,0x0
ffffffffc0209804:	c8878793          	addi	a5,a5,-888 # ffffffffc0209488 <sfs_sync>
ffffffffc0209808:	fc5c                	sd	a5,184(s0)
ffffffffc020980a:	00000797          	auipc	a5,0x0
ffffffffc020980e:	d6478793          	addi	a5,a5,-668 # ffffffffc020956e <sfs_get_root>
ffffffffc0209812:	e07c                	sd	a5,192(s0)
ffffffffc0209814:	00000797          	auipc	a5,0x0
ffffffffc0209818:	b5e78793          	addi	a5,a5,-1186 # ffffffffc0209372 <sfs_unmount>
ffffffffc020981c:	e47c                	sd	a5,200(s0)
ffffffffc020981e:	00000797          	auipc	a5,0x0
ffffffffc0209822:	bd878793          	addi	a5,a5,-1064 # ffffffffc02093f6 <sfs_cleanup>
ffffffffc0209826:	e87c                	sd	a5,208(s0)
ffffffffc0209828:	008ab023          	sd	s0,0(s5)
ffffffffc020982c:	b72d                	j	ffffffffc0209756 <sfs_do_mount+0x190>
ffffffffc020982e:	5a71                	li	s4,-4
ffffffffc0209830:	bf11                	j	ffffffffc0209744 <sfs_do_mount+0x17e>
ffffffffc0209832:	5a49                	li	s4,-14
ffffffffc0209834:	b70d                	j	ffffffffc0209756 <sfs_do_mount+0x190>
ffffffffc0209836:	5a71                	li	s4,-4
ffffffffc0209838:	bf09                	j	ffffffffc020974a <sfs_do_mount+0x184>
ffffffffc020983a:	4b01                	li	s6,0
ffffffffc020983c:	bfb5                	j	ffffffffc02097b8 <sfs_do_mount+0x1f2>
ffffffffc020983e:	5a71                	li	s4,-4
ffffffffc0209840:	bf19                	j	ffffffffc0209756 <sfs_do_mount+0x190>
ffffffffc0209842:	00006697          	auipc	a3,0x6
ffffffffc0209846:	b9e68693          	addi	a3,a3,-1122 # ffffffffc020f3e0 <dev_node_ops+0x540>
ffffffffc020984a:	00002617          	auipc	a2,0x2
ffffffffc020984e:	69e60613          	addi	a2,a2,1694 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209852:	08300593          	li	a1,131
ffffffffc0209856:	00006517          	auipc	a0,0x6
ffffffffc020985a:	a9250513          	addi	a0,a0,-1390 # ffffffffc020f2e8 <dev_node_ops+0x448>
ffffffffc020985e:	c41f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209862:	00006697          	auipc	a3,0x6
ffffffffc0209866:	a5668693          	addi	a3,a3,-1450 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc020986a:	00002617          	auipc	a2,0x2
ffffffffc020986e:	67e60613          	addi	a2,a2,1662 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209872:	0a300593          	li	a1,163
ffffffffc0209876:	00006517          	auipc	a0,0x6
ffffffffc020987a:	a7250513          	addi	a0,a0,-1422 # ffffffffc020f2e8 <dev_node_ops+0x448>
ffffffffc020987e:	c21f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209882:	00006697          	auipc	a3,0x6
ffffffffc0209886:	b8e68693          	addi	a3,a3,-1138 # ffffffffc020f410 <dev_node_ops+0x570>
ffffffffc020988a:	00002617          	auipc	a2,0x2
ffffffffc020988e:	65e60613          	addi	a2,a2,1630 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209892:	0e000593          	li	a1,224
ffffffffc0209896:	00006517          	auipc	a0,0x6
ffffffffc020989a:	a5250513          	addi	a0,a0,-1454 # ffffffffc020f2e8 <dev_node_ops+0x448>
ffffffffc020989e:	c01f60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02098a2 <sfs_mount>:
ffffffffc02098a2:	00000597          	auipc	a1,0x0
ffffffffc02098a6:	d2458593          	addi	a1,a1,-732 # ffffffffc02095c6 <sfs_do_mount>
ffffffffc02098aa:	d6afe06f          	j	ffffffffc0207e14 <vfs_mount>

ffffffffc02098ae <sfs_opendir>:
ffffffffc02098ae:	0235f593          	andi	a1,a1,35
ffffffffc02098b2:	4501                	li	a0,0
ffffffffc02098b4:	e191                	bnez	a1,ffffffffc02098b8 <sfs_opendir+0xa>
ffffffffc02098b6:	8082                	ret
ffffffffc02098b8:	553d                	li	a0,-17
ffffffffc02098ba:	8082                	ret

ffffffffc02098bc <sfs_openfile>:
ffffffffc02098bc:	4501                	li	a0,0
ffffffffc02098be:	8082                	ret

ffffffffc02098c0 <sfs_gettype>:
ffffffffc02098c0:	1141                	addi	sp,sp,-16
ffffffffc02098c2:	e406                	sd	ra,8(sp)
ffffffffc02098c4:	c939                	beqz	a0,ffffffffc020991a <sfs_gettype+0x5a>
ffffffffc02098c6:	4d34                	lw	a3,88(a0)
ffffffffc02098c8:	6785                	lui	a5,0x1
ffffffffc02098ca:	23578713          	addi	a4,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc02098ce:	04e69663          	bne	a3,a4,ffffffffc020991a <sfs_gettype+0x5a>
ffffffffc02098d2:	6114                	ld	a3,0(a0)
ffffffffc02098d4:	4709                	li	a4,2
ffffffffc02098d6:	0046d683          	lhu	a3,4(a3)
ffffffffc02098da:	02e68a63          	beq	a3,a4,ffffffffc020990e <sfs_gettype+0x4e>
ffffffffc02098de:	470d                	li	a4,3
ffffffffc02098e0:	02e68163          	beq	a3,a4,ffffffffc0209902 <sfs_gettype+0x42>
ffffffffc02098e4:	4705                	li	a4,1
ffffffffc02098e6:	00e68f63          	beq	a3,a4,ffffffffc0209904 <sfs_gettype+0x44>
ffffffffc02098ea:	00006617          	auipc	a2,0x6
ffffffffc02098ee:	bc660613          	addi	a2,a2,-1082 # ffffffffc020f4b0 <dev_node_ops+0x610>
ffffffffc02098f2:	3a600593          	li	a1,934
ffffffffc02098f6:	00006517          	auipc	a0,0x6
ffffffffc02098fa:	ba250513          	addi	a0,a0,-1118 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc02098fe:	ba1f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209902:	678d                	lui	a5,0x3
ffffffffc0209904:	60a2                	ld	ra,8(sp)
ffffffffc0209906:	c19c                	sw	a5,0(a1)
ffffffffc0209908:	4501                	li	a0,0
ffffffffc020990a:	0141                	addi	sp,sp,16
ffffffffc020990c:	8082                	ret
ffffffffc020990e:	60a2                	ld	ra,8(sp)
ffffffffc0209910:	6789                	lui	a5,0x2
ffffffffc0209912:	c19c                	sw	a5,0(a1)
ffffffffc0209914:	4501                	li	a0,0
ffffffffc0209916:	0141                	addi	sp,sp,16
ffffffffc0209918:	8082                	ret
ffffffffc020991a:	00006697          	auipc	a3,0x6
ffffffffc020991e:	b4668693          	addi	a3,a3,-1210 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc0209922:	00002617          	auipc	a2,0x2
ffffffffc0209926:	5c660613          	addi	a2,a2,1478 # ffffffffc020bee8 <commands+0x210>
ffffffffc020992a:	39a00593          	li	a1,922
ffffffffc020992e:	00006517          	auipc	a0,0x6
ffffffffc0209932:	b6a50513          	addi	a0,a0,-1174 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209936:	b69f60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020993a <sfs_fsync>:
ffffffffc020993a:	7179                	addi	sp,sp,-48
ffffffffc020993c:	ec26                	sd	s1,24(sp)
ffffffffc020993e:	7524                	ld	s1,104(a0)
ffffffffc0209940:	f406                	sd	ra,40(sp)
ffffffffc0209942:	f022                	sd	s0,32(sp)
ffffffffc0209944:	e84a                	sd	s2,16(sp)
ffffffffc0209946:	e44e                	sd	s3,8(sp)
ffffffffc0209948:	c4bd                	beqz	s1,ffffffffc02099b6 <sfs_fsync+0x7c>
ffffffffc020994a:	0b04a783          	lw	a5,176(s1)
ffffffffc020994e:	e7a5                	bnez	a5,ffffffffc02099b6 <sfs_fsync+0x7c>
ffffffffc0209950:	4d38                	lw	a4,88(a0)
ffffffffc0209952:	6785                	lui	a5,0x1
ffffffffc0209954:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209958:	842a                	mv	s0,a0
ffffffffc020995a:	06f71e63          	bne	a4,a5,ffffffffc02099d6 <sfs_fsync+0x9c>
ffffffffc020995e:	691c                	ld	a5,16(a0)
ffffffffc0209960:	4901                	li	s2,0
ffffffffc0209962:	eb89                	bnez	a5,ffffffffc0209974 <sfs_fsync+0x3a>
ffffffffc0209964:	70a2                	ld	ra,40(sp)
ffffffffc0209966:	7402                	ld	s0,32(sp)
ffffffffc0209968:	64e2                	ld	s1,24(sp)
ffffffffc020996a:	69a2                	ld	s3,8(sp)
ffffffffc020996c:	854a                	mv	a0,s2
ffffffffc020996e:	6942                	ld	s2,16(sp)
ffffffffc0209970:	6145                	addi	sp,sp,48
ffffffffc0209972:	8082                	ret
ffffffffc0209974:	02050993          	addi	s3,a0,32
ffffffffc0209978:	854e                	mv	a0,s3
ffffffffc020997a:	bebfa0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc020997e:	681c                	ld	a5,16(s0)
ffffffffc0209980:	ef81                	bnez	a5,ffffffffc0209998 <sfs_fsync+0x5e>
ffffffffc0209982:	854e                	mv	a0,s3
ffffffffc0209984:	bddfa0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc0209988:	70a2                	ld	ra,40(sp)
ffffffffc020998a:	7402                	ld	s0,32(sp)
ffffffffc020998c:	64e2                	ld	s1,24(sp)
ffffffffc020998e:	69a2                	ld	s3,8(sp)
ffffffffc0209990:	854a                	mv	a0,s2
ffffffffc0209992:	6942                	ld	s2,16(sp)
ffffffffc0209994:	6145                	addi	sp,sp,48
ffffffffc0209996:	8082                	ret
ffffffffc0209998:	4414                	lw	a3,8(s0)
ffffffffc020999a:	600c                	ld	a1,0(s0)
ffffffffc020999c:	00043823          	sd	zero,16(s0)
ffffffffc02099a0:	4701                	li	a4,0
ffffffffc02099a2:	04000613          	li	a2,64
ffffffffc02099a6:	8526                	mv	a0,s1
ffffffffc02099a8:	131010ef          	jal	ra,ffffffffc020b2d8 <sfs_wbuf>
ffffffffc02099ac:	892a                	mv	s2,a0
ffffffffc02099ae:	d971                	beqz	a0,ffffffffc0209982 <sfs_fsync+0x48>
ffffffffc02099b0:	4785                	li	a5,1
ffffffffc02099b2:	e81c                	sd	a5,16(s0)
ffffffffc02099b4:	b7f9                	j	ffffffffc0209982 <sfs_fsync+0x48>
ffffffffc02099b6:	00006697          	auipc	a3,0x6
ffffffffc02099ba:	90268693          	addi	a3,a3,-1790 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc02099be:	00002617          	auipc	a2,0x2
ffffffffc02099c2:	52a60613          	addi	a2,a2,1322 # ffffffffc020bee8 <commands+0x210>
ffffffffc02099c6:	2de00593          	li	a1,734
ffffffffc02099ca:	00006517          	auipc	a0,0x6
ffffffffc02099ce:	ace50513          	addi	a0,a0,-1330 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc02099d2:	acdf60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc02099d6:	00006697          	auipc	a3,0x6
ffffffffc02099da:	a8a68693          	addi	a3,a3,-1398 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc02099de:	00002617          	auipc	a2,0x2
ffffffffc02099e2:	50a60613          	addi	a2,a2,1290 # ffffffffc020bee8 <commands+0x210>
ffffffffc02099e6:	2df00593          	li	a1,735
ffffffffc02099ea:	00006517          	auipc	a0,0x6
ffffffffc02099ee:	aae50513          	addi	a0,a0,-1362 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc02099f2:	aadf60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc02099f6 <sfs_fstat>:
ffffffffc02099f6:	1101                	addi	sp,sp,-32
ffffffffc02099f8:	e426                	sd	s1,8(sp)
ffffffffc02099fa:	84ae                	mv	s1,a1
ffffffffc02099fc:	e822                	sd	s0,16(sp)
ffffffffc02099fe:	02000613          	li	a2,32
ffffffffc0209a02:	842a                	mv	s0,a0
ffffffffc0209a04:	4581                	li	a1,0
ffffffffc0209a06:	8526                	mv	a0,s1
ffffffffc0209a08:	ec06                	sd	ra,24(sp)
ffffffffc0209a0a:	7fb010ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc0209a0e:	c439                	beqz	s0,ffffffffc0209a5c <sfs_fstat+0x66>
ffffffffc0209a10:	783c                	ld	a5,112(s0)
ffffffffc0209a12:	c7a9                	beqz	a5,ffffffffc0209a5c <sfs_fstat+0x66>
ffffffffc0209a14:	6bbc                	ld	a5,80(a5)
ffffffffc0209a16:	c3b9                	beqz	a5,ffffffffc0209a5c <sfs_fstat+0x66>
ffffffffc0209a18:	00005597          	auipc	a1,0x5
ffffffffc0209a1c:	3e058593          	addi	a1,a1,992 # ffffffffc020edf8 <syscalls+0xd98>
ffffffffc0209a20:	8522                	mv	a0,s0
ffffffffc0209a22:	e23fd0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0209a26:	783c                	ld	a5,112(s0)
ffffffffc0209a28:	85a6                	mv	a1,s1
ffffffffc0209a2a:	8522                	mv	a0,s0
ffffffffc0209a2c:	6bbc                	ld	a5,80(a5)
ffffffffc0209a2e:	9782                	jalr	a5
ffffffffc0209a30:	e10d                	bnez	a0,ffffffffc0209a52 <sfs_fstat+0x5c>
ffffffffc0209a32:	4c38                	lw	a4,88(s0)
ffffffffc0209a34:	6785                	lui	a5,0x1
ffffffffc0209a36:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209a3a:	04f71163          	bne	a4,a5,ffffffffc0209a7c <sfs_fstat+0x86>
ffffffffc0209a3e:	601c                	ld	a5,0(s0)
ffffffffc0209a40:	0067d683          	lhu	a3,6(a5)
ffffffffc0209a44:	0087e703          	lwu	a4,8(a5)
ffffffffc0209a48:	0007e783          	lwu	a5,0(a5)
ffffffffc0209a4c:	e494                	sd	a3,8(s1)
ffffffffc0209a4e:	e898                	sd	a4,16(s1)
ffffffffc0209a50:	ec9c                	sd	a5,24(s1)
ffffffffc0209a52:	60e2                	ld	ra,24(sp)
ffffffffc0209a54:	6442                	ld	s0,16(sp)
ffffffffc0209a56:	64a2                	ld	s1,8(sp)
ffffffffc0209a58:	6105                	addi	sp,sp,32
ffffffffc0209a5a:	8082                	ret
ffffffffc0209a5c:	00005697          	auipc	a3,0x5
ffffffffc0209a60:	34c68693          	addi	a3,a3,844 # ffffffffc020eda8 <syscalls+0xd48>
ffffffffc0209a64:	00002617          	auipc	a2,0x2
ffffffffc0209a68:	48460613          	addi	a2,a2,1156 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209a6c:	2cf00593          	li	a1,719
ffffffffc0209a70:	00006517          	auipc	a0,0x6
ffffffffc0209a74:	a2850513          	addi	a0,a0,-1496 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209a78:	a27f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209a7c:	00006697          	auipc	a3,0x6
ffffffffc0209a80:	9e468693          	addi	a3,a3,-1564 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc0209a84:	00002617          	auipc	a2,0x2
ffffffffc0209a88:	46460613          	addi	a2,a2,1124 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209a8c:	2d200593          	li	a1,722
ffffffffc0209a90:	00006517          	auipc	a0,0x6
ffffffffc0209a94:	a0850513          	addi	a0,a0,-1528 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209a98:	a07f60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0209a9c <sfs_symlink>:
ffffffffc0209a9c:	753c                	ld	a5,104(a0)
ffffffffc0209a9e:	715d                	addi	sp,sp,-80
ffffffffc0209aa0:	e486                	sd	ra,72(sp)
ffffffffc0209aa2:	e0a2                	sd	s0,64(sp)
ffffffffc0209aa4:	fc26                	sd	s1,56(sp)
ffffffffc0209aa6:	f84a                	sd	s2,48(sp)
ffffffffc0209aa8:	cfd9                	beqz	a5,ffffffffc0209b46 <sfs_symlink+0xaa>
ffffffffc0209aaa:	0b07a783          	lw	a5,176(a5)
ffffffffc0209aae:	efc1                	bnez	a5,ffffffffc0209b46 <sfs_symlink+0xaa>
ffffffffc0209ab0:	793c                	ld	a5,112(a0)
ffffffffc0209ab2:	842a                	mv	s0,a0
ffffffffc0209ab4:	cbe9                	beqz	a5,ffffffffc0209b86 <sfs_symlink+0xea>
ffffffffc0209ab6:	77bc                	ld	a5,104(a5)
ffffffffc0209ab8:	c7f9                	beqz	a5,ffffffffc0209b86 <sfs_symlink+0xea>
ffffffffc0209aba:	892e                	mv	s2,a1
ffffffffc0209abc:	00005597          	auipc	a1,0x5
ffffffffc0209ac0:	17c58593          	addi	a1,a1,380 # ffffffffc020ec38 <syscalls+0xbd8>
ffffffffc0209ac4:	84b2                	mv	s1,a2
ffffffffc0209ac6:	d7ffd0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0209aca:	783c                	ld	a5,112(s0)
ffffffffc0209acc:	8522                	mv	a0,s0
ffffffffc0209ace:	0034                	addi	a3,sp,8
ffffffffc0209ad0:	77bc                	ld	a5,104(a5)
ffffffffc0209ad2:	4605                	li	a2,1
ffffffffc0209ad4:	85ca                	mv	a1,s2
ffffffffc0209ad6:	9782                	jalr	a5
ffffffffc0209ad8:	842a                	mv	s0,a0
ffffffffc0209ada:	ed39                	bnez	a0,ffffffffc0209b38 <sfs_symlink+0x9c>
ffffffffc0209adc:	67a2                	ld	a5,8(sp)
ffffffffc0209ade:	c7e1                	beqz	a5,ffffffffc0209ba6 <sfs_symlink+0x10a>
ffffffffc0209ae0:	4fb4                	lw	a3,88(a5)
ffffffffc0209ae2:	6705                	lui	a4,0x1
ffffffffc0209ae4:	23570713          	addi	a4,a4,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209ae8:	0ae69f63          	bne	a3,a4,ffffffffc0209ba6 <sfs_symlink+0x10a>
ffffffffc0209aec:	6398                	ld	a4,0(a5)
ffffffffc0209aee:	468d                	li	a3,3
ffffffffc0209af0:	8526                	mv	a0,s1
ffffffffc0209af2:	00d71223          	sh	a3,4(a4)
ffffffffc0209af6:	4705                	li	a4,1
ffffffffc0209af8:	eb98                	sd	a4,16(a5)
ffffffffc0209afa:	641010ef          	jal	ra,ffffffffc020b93a <strlen>
ffffffffc0209afe:	862a                	mv	a2,a0
ffffffffc0209b00:	85a6                	mv	a1,s1
ffffffffc0209b02:	4681                	li	a3,0
ffffffffc0209b04:	0808                	addi	a0,sp,16
ffffffffc0209b06:	8ddfb0ef          	jal	ra,ffffffffc02053e2 <iobuf_init>
ffffffffc0209b0a:	6422                	ld	s0,8(sp)
ffffffffc0209b0c:	84aa                	mv	s1,a0
ffffffffc0209b0e:	cc21                	beqz	s0,ffffffffc0209b66 <sfs_symlink+0xca>
ffffffffc0209b10:	783c                	ld	a5,112(s0)
ffffffffc0209b12:	cbb1                	beqz	a5,ffffffffc0209b66 <sfs_symlink+0xca>
ffffffffc0209b14:	739c                	ld	a5,32(a5)
ffffffffc0209b16:	cba1                	beqz	a5,ffffffffc0209b66 <sfs_symlink+0xca>
ffffffffc0209b18:	8522                	mv	a0,s0
ffffffffc0209b1a:	00004597          	auipc	a1,0x4
ffffffffc0209b1e:	ca658593          	addi	a1,a1,-858 # ffffffffc020d7c0 <default_pmm_manager+0xdf0>
ffffffffc0209b22:	d23fd0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0209b26:	783c                	ld	a5,112(s0)
ffffffffc0209b28:	6522                	ld	a0,8(sp)
ffffffffc0209b2a:	85a6                	mv	a1,s1
ffffffffc0209b2c:	739c                	ld	a5,32(a5)
ffffffffc0209b2e:	9782                	jalr	a5
ffffffffc0209b30:	842a                	mv	s0,a0
ffffffffc0209b32:	6522                	ld	a0,8(sp)
ffffffffc0209b34:	dc7fd0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc0209b38:	60a6                	ld	ra,72(sp)
ffffffffc0209b3a:	8522                	mv	a0,s0
ffffffffc0209b3c:	6406                	ld	s0,64(sp)
ffffffffc0209b3e:	74e2                	ld	s1,56(sp)
ffffffffc0209b40:	7942                	ld	s2,48(sp)
ffffffffc0209b42:	6161                	addi	sp,sp,80
ffffffffc0209b44:	8082                	ret
ffffffffc0209b46:	00005697          	auipc	a3,0x5
ffffffffc0209b4a:	77268693          	addi	a3,a3,1906 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc0209b4e:	00002617          	auipc	a2,0x2
ffffffffc0209b52:	39a60613          	addi	a2,a2,922 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209b56:	45600593          	li	a1,1110
ffffffffc0209b5a:	00006517          	auipc	a0,0x6
ffffffffc0209b5e:	93e50513          	addi	a0,a0,-1730 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209b62:	93df60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209b66:	00004697          	auipc	a3,0x4
ffffffffc0209b6a:	c0a68693          	addi	a3,a3,-1014 # ffffffffc020d770 <default_pmm_manager+0xda0>
ffffffffc0209b6e:	00002617          	auipc	a2,0x2
ffffffffc0209b72:	37a60613          	addi	a2,a2,890 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209b76:	46800593          	li	a1,1128
ffffffffc0209b7a:	00006517          	auipc	a0,0x6
ffffffffc0209b7e:	91e50513          	addi	a0,a0,-1762 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209b82:	91df60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209b86:	00005697          	auipc	a3,0x5
ffffffffc0209b8a:	04a68693          	addi	a3,a3,74 # ffffffffc020ebd0 <syscalls+0xb70>
ffffffffc0209b8e:	00002617          	auipc	a2,0x2
ffffffffc0209b92:	35a60613          	addi	a2,a2,858 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209b96:	45b00593          	li	a1,1115
ffffffffc0209b9a:	00006517          	auipc	a0,0x6
ffffffffc0209b9e:	8fe50513          	addi	a0,a0,-1794 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209ba2:	8fdf60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209ba6:	00006697          	auipc	a3,0x6
ffffffffc0209baa:	8ba68693          	addi	a3,a3,-1862 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc0209bae:	00002617          	auipc	a2,0x2
ffffffffc0209bb2:	33a60613          	addi	a2,a2,826 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209bb6:	45f00593          	li	a1,1119
ffffffffc0209bba:	00006517          	auipc	a0,0x6
ffffffffc0209bbe:	8de50513          	addi	a0,a0,-1826 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209bc2:	8ddf60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0209bc6 <sfs_tryseek>:
ffffffffc0209bc6:	080007b7          	lui	a5,0x8000
ffffffffc0209bca:	04f5fd63          	bgeu	a1,a5,ffffffffc0209c24 <sfs_tryseek+0x5e>
ffffffffc0209bce:	1101                	addi	sp,sp,-32
ffffffffc0209bd0:	e822                	sd	s0,16(sp)
ffffffffc0209bd2:	ec06                	sd	ra,24(sp)
ffffffffc0209bd4:	e426                	sd	s1,8(sp)
ffffffffc0209bd6:	842a                	mv	s0,a0
ffffffffc0209bd8:	c921                	beqz	a0,ffffffffc0209c28 <sfs_tryseek+0x62>
ffffffffc0209bda:	4d38                	lw	a4,88(a0)
ffffffffc0209bdc:	6785                	lui	a5,0x1
ffffffffc0209bde:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209be2:	04f71363          	bne	a4,a5,ffffffffc0209c28 <sfs_tryseek+0x62>
ffffffffc0209be6:	611c                	ld	a5,0(a0)
ffffffffc0209be8:	84ae                	mv	s1,a1
ffffffffc0209bea:	0007e783          	lwu	a5,0(a5)
ffffffffc0209bee:	02b7d563          	bge	a5,a1,ffffffffc0209c18 <sfs_tryseek+0x52>
ffffffffc0209bf2:	793c                	ld	a5,112(a0)
ffffffffc0209bf4:	cbb1                	beqz	a5,ffffffffc0209c48 <sfs_tryseek+0x82>
ffffffffc0209bf6:	73bc                	ld	a5,96(a5)
ffffffffc0209bf8:	cba1                	beqz	a5,ffffffffc0209c48 <sfs_tryseek+0x82>
ffffffffc0209bfa:	00005597          	auipc	a1,0x5
ffffffffc0209bfe:	10658593          	addi	a1,a1,262 # ffffffffc020ed00 <syscalls+0xca0>
ffffffffc0209c02:	c43fd0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0209c06:	783c                	ld	a5,112(s0)
ffffffffc0209c08:	8522                	mv	a0,s0
ffffffffc0209c0a:	6442                	ld	s0,16(sp)
ffffffffc0209c0c:	60e2                	ld	ra,24(sp)
ffffffffc0209c0e:	73bc                	ld	a5,96(a5)
ffffffffc0209c10:	85a6                	mv	a1,s1
ffffffffc0209c12:	64a2                	ld	s1,8(sp)
ffffffffc0209c14:	6105                	addi	sp,sp,32
ffffffffc0209c16:	8782                	jr	a5
ffffffffc0209c18:	60e2                	ld	ra,24(sp)
ffffffffc0209c1a:	6442                	ld	s0,16(sp)
ffffffffc0209c1c:	64a2                	ld	s1,8(sp)
ffffffffc0209c1e:	4501                	li	a0,0
ffffffffc0209c20:	6105                	addi	sp,sp,32
ffffffffc0209c22:	8082                	ret
ffffffffc0209c24:	5575                	li	a0,-3
ffffffffc0209c26:	8082                	ret
ffffffffc0209c28:	00006697          	auipc	a3,0x6
ffffffffc0209c2c:	83868693          	addi	a3,a3,-1992 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc0209c30:	00002617          	auipc	a2,0x2
ffffffffc0209c34:	2b860613          	addi	a2,a2,696 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209c38:	3b100593          	li	a1,945
ffffffffc0209c3c:	00006517          	auipc	a0,0x6
ffffffffc0209c40:	85c50513          	addi	a0,a0,-1956 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209c44:	85bf60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209c48:	00005697          	auipc	a3,0x5
ffffffffc0209c4c:	06068693          	addi	a3,a3,96 # ffffffffc020eca8 <syscalls+0xc48>
ffffffffc0209c50:	00002617          	auipc	a2,0x2
ffffffffc0209c54:	29860613          	addi	a2,a2,664 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209c58:	3b300593          	li	a1,947
ffffffffc0209c5c:	00006517          	auipc	a0,0x6
ffffffffc0209c60:	83c50513          	addi	a0,a0,-1988 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209c64:	83bf60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0209c68 <sfs_close>:
ffffffffc0209c68:	1141                	addi	sp,sp,-16
ffffffffc0209c6a:	e406                	sd	ra,8(sp)
ffffffffc0209c6c:	e022                	sd	s0,0(sp)
ffffffffc0209c6e:	c11d                	beqz	a0,ffffffffc0209c94 <sfs_close+0x2c>
ffffffffc0209c70:	793c                	ld	a5,112(a0)
ffffffffc0209c72:	842a                	mv	s0,a0
ffffffffc0209c74:	c385                	beqz	a5,ffffffffc0209c94 <sfs_close+0x2c>
ffffffffc0209c76:	7b9c                	ld	a5,48(a5)
ffffffffc0209c78:	cf91                	beqz	a5,ffffffffc0209c94 <sfs_close+0x2c>
ffffffffc0209c7a:	00004597          	auipc	a1,0x4
ffffffffc0209c7e:	bf658593          	addi	a1,a1,-1034 # ffffffffc020d870 <default_pmm_manager+0xea0>
ffffffffc0209c82:	bc3fd0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0209c86:	783c                	ld	a5,112(s0)
ffffffffc0209c88:	8522                	mv	a0,s0
ffffffffc0209c8a:	6402                	ld	s0,0(sp)
ffffffffc0209c8c:	60a2                	ld	ra,8(sp)
ffffffffc0209c8e:	7b9c                	ld	a5,48(a5)
ffffffffc0209c90:	0141                	addi	sp,sp,16
ffffffffc0209c92:	8782                	jr	a5
ffffffffc0209c94:	00004697          	auipc	a3,0x4
ffffffffc0209c98:	b8c68693          	addi	a3,a3,-1140 # ffffffffc020d820 <default_pmm_manager+0xe50>
ffffffffc0209c9c:	00002617          	auipc	a2,0x2
ffffffffc0209ca0:	24c60613          	addi	a2,a2,588 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209ca4:	21c00593          	li	a1,540
ffffffffc0209ca8:	00005517          	auipc	a0,0x5
ffffffffc0209cac:	7f050513          	addi	a0,a0,2032 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209cb0:	feef60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0209cb4 <sfs_io.part.0>:
ffffffffc0209cb4:	1141                	addi	sp,sp,-16
ffffffffc0209cb6:	00005697          	auipc	a3,0x5
ffffffffc0209cba:	7aa68693          	addi	a3,a3,1962 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc0209cbe:	00002617          	auipc	a2,0x2
ffffffffc0209cc2:	22a60613          	addi	a2,a2,554 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209cc6:	2ae00593          	li	a1,686
ffffffffc0209cca:	00005517          	auipc	a0,0x5
ffffffffc0209cce:	7ce50513          	addi	a0,a0,1998 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209cd2:	e406                	sd	ra,8(sp)
ffffffffc0209cd4:	fcaf60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0209cd8 <sfs_block_free>:
ffffffffc0209cd8:	1101                	addi	sp,sp,-32
ffffffffc0209cda:	e426                	sd	s1,8(sp)
ffffffffc0209cdc:	ec06                	sd	ra,24(sp)
ffffffffc0209cde:	e822                	sd	s0,16(sp)
ffffffffc0209ce0:	4154                	lw	a3,4(a0)
ffffffffc0209ce2:	84ae                	mv	s1,a1
ffffffffc0209ce4:	c595                	beqz	a1,ffffffffc0209d10 <sfs_block_free+0x38>
ffffffffc0209ce6:	02d5f563          	bgeu	a1,a3,ffffffffc0209d10 <sfs_block_free+0x38>
ffffffffc0209cea:	842a                	mv	s0,a0
ffffffffc0209cec:	7d08                	ld	a0,56(a0)
ffffffffc0209cee:	db2ff0ef          	jal	ra,ffffffffc02092a0 <bitmap_test>
ffffffffc0209cf2:	ed05                	bnez	a0,ffffffffc0209d2a <sfs_block_free+0x52>
ffffffffc0209cf4:	7c08                	ld	a0,56(s0)
ffffffffc0209cf6:	85a6                	mv	a1,s1
ffffffffc0209cf8:	dd0ff0ef          	jal	ra,ffffffffc02092c8 <bitmap_free>
ffffffffc0209cfc:	441c                	lw	a5,8(s0)
ffffffffc0209cfe:	4705                	li	a4,1
ffffffffc0209d00:	60e2                	ld	ra,24(sp)
ffffffffc0209d02:	2785                	addiw	a5,a5,1
ffffffffc0209d04:	e038                	sd	a4,64(s0)
ffffffffc0209d06:	c41c                	sw	a5,8(s0)
ffffffffc0209d08:	6442                	ld	s0,16(sp)
ffffffffc0209d0a:	64a2                	ld	s1,8(sp)
ffffffffc0209d0c:	6105                	addi	sp,sp,32
ffffffffc0209d0e:	8082                	ret
ffffffffc0209d10:	8726                	mv	a4,s1
ffffffffc0209d12:	00005617          	auipc	a2,0x5
ffffffffc0209d16:	7b660613          	addi	a2,a2,1974 # ffffffffc020f4c8 <dev_node_ops+0x628>
ffffffffc0209d1a:	05300593          	li	a1,83
ffffffffc0209d1e:	00005517          	auipc	a0,0x5
ffffffffc0209d22:	77a50513          	addi	a0,a0,1914 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209d26:	f78f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209d2a:	00005697          	auipc	a3,0x5
ffffffffc0209d2e:	7d668693          	addi	a3,a3,2006 # ffffffffc020f500 <dev_node_ops+0x660>
ffffffffc0209d32:	00002617          	auipc	a2,0x2
ffffffffc0209d36:	1b660613          	addi	a2,a2,438 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209d3a:	06a00593          	li	a1,106
ffffffffc0209d3e:	00005517          	auipc	a0,0x5
ffffffffc0209d42:	75a50513          	addi	a0,a0,1882 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209d46:	f58f60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0209d4a <sfs_reclaim>:
ffffffffc0209d4a:	1101                	addi	sp,sp,-32
ffffffffc0209d4c:	e426                	sd	s1,8(sp)
ffffffffc0209d4e:	7524                	ld	s1,104(a0)
ffffffffc0209d50:	ec06                	sd	ra,24(sp)
ffffffffc0209d52:	e822                	sd	s0,16(sp)
ffffffffc0209d54:	e04a                	sd	s2,0(sp)
ffffffffc0209d56:	0e048a63          	beqz	s1,ffffffffc0209e4a <sfs_reclaim+0x100>
ffffffffc0209d5a:	0b04a783          	lw	a5,176(s1)
ffffffffc0209d5e:	0e079663          	bnez	a5,ffffffffc0209e4a <sfs_reclaim+0x100>
ffffffffc0209d62:	4d38                	lw	a4,88(a0)
ffffffffc0209d64:	6785                	lui	a5,0x1
ffffffffc0209d66:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209d6a:	842a                	mv	s0,a0
ffffffffc0209d6c:	10f71f63          	bne	a4,a5,ffffffffc0209e8a <sfs_reclaim+0x140>
ffffffffc0209d70:	8526                	mv	a0,s1
ffffffffc0209d72:	716010ef          	jal	ra,ffffffffc020b488 <lock_sfs_fs>
ffffffffc0209d76:	4c1c                	lw	a5,24(s0)
ffffffffc0209d78:	0ef05963          	blez	a5,ffffffffc0209e6a <sfs_reclaim+0x120>
ffffffffc0209d7c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0209d80:	cc18                	sw	a4,24(s0)
ffffffffc0209d82:	eb59                	bnez	a4,ffffffffc0209e18 <sfs_reclaim+0xce>
ffffffffc0209d84:	05c42903          	lw	s2,92(s0)
ffffffffc0209d88:	08091863          	bnez	s2,ffffffffc0209e18 <sfs_reclaim+0xce>
ffffffffc0209d8c:	601c                	ld	a5,0(s0)
ffffffffc0209d8e:	0067d783          	lhu	a5,6(a5)
ffffffffc0209d92:	e785                	bnez	a5,ffffffffc0209dba <sfs_reclaim+0x70>
ffffffffc0209d94:	783c                	ld	a5,112(s0)
ffffffffc0209d96:	10078a63          	beqz	a5,ffffffffc0209eaa <sfs_reclaim+0x160>
ffffffffc0209d9a:	73bc                	ld	a5,96(a5)
ffffffffc0209d9c:	10078763          	beqz	a5,ffffffffc0209eaa <sfs_reclaim+0x160>
ffffffffc0209da0:	00005597          	auipc	a1,0x5
ffffffffc0209da4:	f6058593          	addi	a1,a1,-160 # ffffffffc020ed00 <syscalls+0xca0>
ffffffffc0209da8:	8522                	mv	a0,s0
ffffffffc0209daa:	a9bfd0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0209dae:	783c                	ld	a5,112(s0)
ffffffffc0209db0:	4581                	li	a1,0
ffffffffc0209db2:	8522                	mv	a0,s0
ffffffffc0209db4:	73bc                	ld	a5,96(a5)
ffffffffc0209db6:	9782                	jalr	a5
ffffffffc0209db8:	e559                	bnez	a0,ffffffffc0209e46 <sfs_reclaim+0xfc>
ffffffffc0209dba:	681c                	ld	a5,16(s0)
ffffffffc0209dbc:	c39d                	beqz	a5,ffffffffc0209de2 <sfs_reclaim+0x98>
ffffffffc0209dbe:	783c                	ld	a5,112(s0)
ffffffffc0209dc0:	10078563          	beqz	a5,ffffffffc0209eca <sfs_reclaim+0x180>
ffffffffc0209dc4:	7b9c                	ld	a5,48(a5)
ffffffffc0209dc6:	10078263          	beqz	a5,ffffffffc0209eca <sfs_reclaim+0x180>
ffffffffc0209dca:	8522                	mv	a0,s0
ffffffffc0209dcc:	00004597          	auipc	a1,0x4
ffffffffc0209dd0:	aa458593          	addi	a1,a1,-1372 # ffffffffc020d870 <default_pmm_manager+0xea0>
ffffffffc0209dd4:	a71fd0ef          	jal	ra,ffffffffc0207844 <inode_check>
ffffffffc0209dd8:	783c                	ld	a5,112(s0)
ffffffffc0209dda:	8522                	mv	a0,s0
ffffffffc0209ddc:	7b9c                	ld	a5,48(a5)
ffffffffc0209dde:	9782                	jalr	a5
ffffffffc0209de0:	e13d                	bnez	a0,ffffffffc0209e46 <sfs_reclaim+0xfc>
ffffffffc0209de2:	7c18                	ld	a4,56(s0)
ffffffffc0209de4:	603c                	ld	a5,64(s0)
ffffffffc0209de6:	8526                	mv	a0,s1
ffffffffc0209de8:	e71c                	sd	a5,8(a4)
ffffffffc0209dea:	e398                	sd	a4,0(a5)
ffffffffc0209dec:	6438                	ld	a4,72(s0)
ffffffffc0209dee:	683c                	ld	a5,80(s0)
ffffffffc0209df0:	e71c                	sd	a5,8(a4)
ffffffffc0209df2:	e398                	sd	a4,0(a5)
ffffffffc0209df4:	6a4010ef          	jal	ra,ffffffffc020b498 <unlock_sfs_fs>
ffffffffc0209df8:	6008                	ld	a0,0(s0)
ffffffffc0209dfa:	00655783          	lhu	a5,6(a0)
ffffffffc0209dfe:	cb85                	beqz	a5,ffffffffc0209e2e <sfs_reclaim+0xe4>
ffffffffc0209e00:	a3ef80ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc0209e04:	8522                	mv	a0,s0
ffffffffc0209e06:	9d3fd0ef          	jal	ra,ffffffffc02077d8 <inode_kill>
ffffffffc0209e0a:	60e2                	ld	ra,24(sp)
ffffffffc0209e0c:	6442                	ld	s0,16(sp)
ffffffffc0209e0e:	64a2                	ld	s1,8(sp)
ffffffffc0209e10:	854a                	mv	a0,s2
ffffffffc0209e12:	6902                	ld	s2,0(sp)
ffffffffc0209e14:	6105                	addi	sp,sp,32
ffffffffc0209e16:	8082                	ret
ffffffffc0209e18:	5945                	li	s2,-15
ffffffffc0209e1a:	8526                	mv	a0,s1
ffffffffc0209e1c:	67c010ef          	jal	ra,ffffffffc020b498 <unlock_sfs_fs>
ffffffffc0209e20:	60e2                	ld	ra,24(sp)
ffffffffc0209e22:	6442                	ld	s0,16(sp)
ffffffffc0209e24:	64a2                	ld	s1,8(sp)
ffffffffc0209e26:	854a                	mv	a0,s2
ffffffffc0209e28:	6902                	ld	s2,0(sp)
ffffffffc0209e2a:	6105                	addi	sp,sp,32
ffffffffc0209e2c:	8082                	ret
ffffffffc0209e2e:	440c                	lw	a1,8(s0)
ffffffffc0209e30:	8526                	mv	a0,s1
ffffffffc0209e32:	ea7ff0ef          	jal	ra,ffffffffc0209cd8 <sfs_block_free>
ffffffffc0209e36:	6008                	ld	a0,0(s0)
ffffffffc0209e38:	5d4c                	lw	a1,60(a0)
ffffffffc0209e3a:	d1f9                	beqz	a1,ffffffffc0209e00 <sfs_reclaim+0xb6>
ffffffffc0209e3c:	8526                	mv	a0,s1
ffffffffc0209e3e:	e9bff0ef          	jal	ra,ffffffffc0209cd8 <sfs_block_free>
ffffffffc0209e42:	6008                	ld	a0,0(s0)
ffffffffc0209e44:	bf75                	j	ffffffffc0209e00 <sfs_reclaim+0xb6>
ffffffffc0209e46:	892a                	mv	s2,a0
ffffffffc0209e48:	bfc9                	j	ffffffffc0209e1a <sfs_reclaim+0xd0>
ffffffffc0209e4a:	00005697          	auipc	a3,0x5
ffffffffc0209e4e:	46e68693          	addi	a3,a3,1134 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc0209e52:	00002617          	auipc	a2,0x2
ffffffffc0209e56:	09660613          	addi	a2,a2,150 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209e5a:	36f00593          	li	a1,879
ffffffffc0209e5e:	00005517          	auipc	a0,0x5
ffffffffc0209e62:	63a50513          	addi	a0,a0,1594 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209e66:	e38f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209e6a:	00005697          	auipc	a3,0x5
ffffffffc0209e6e:	6b668693          	addi	a3,a3,1718 # ffffffffc020f520 <dev_node_ops+0x680>
ffffffffc0209e72:	00002617          	auipc	a2,0x2
ffffffffc0209e76:	07660613          	addi	a2,a2,118 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209e7a:	37500593          	li	a1,885
ffffffffc0209e7e:	00005517          	auipc	a0,0x5
ffffffffc0209e82:	61a50513          	addi	a0,a0,1562 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209e86:	e18f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209e8a:	00005697          	auipc	a3,0x5
ffffffffc0209e8e:	5d668693          	addi	a3,a3,1494 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc0209e92:	00002617          	auipc	a2,0x2
ffffffffc0209e96:	05660613          	addi	a2,a2,86 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209e9a:	37000593          	li	a1,880
ffffffffc0209e9e:	00005517          	auipc	a0,0x5
ffffffffc0209ea2:	5fa50513          	addi	a0,a0,1530 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209ea6:	df8f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209eaa:	00005697          	auipc	a3,0x5
ffffffffc0209eae:	dfe68693          	addi	a3,a3,-514 # ffffffffc020eca8 <syscalls+0xc48>
ffffffffc0209eb2:	00002617          	auipc	a2,0x2
ffffffffc0209eb6:	03660613          	addi	a2,a2,54 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209eba:	37a00593          	li	a1,890
ffffffffc0209ebe:	00005517          	auipc	a0,0x5
ffffffffc0209ec2:	5da50513          	addi	a0,a0,1498 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209ec6:	dd8f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209eca:	00004697          	auipc	a3,0x4
ffffffffc0209ece:	95668693          	addi	a3,a3,-1706 # ffffffffc020d820 <default_pmm_manager+0xe50>
ffffffffc0209ed2:	00002617          	auipc	a2,0x2
ffffffffc0209ed6:	01660613          	addi	a2,a2,22 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209eda:	37f00593          	li	a1,895
ffffffffc0209ede:	00005517          	auipc	a0,0x5
ffffffffc0209ee2:	5ba50513          	addi	a0,a0,1466 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209ee6:	db8f60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0209eea <sfs_block_alloc>:
ffffffffc0209eea:	1101                	addi	sp,sp,-32
ffffffffc0209eec:	e822                	sd	s0,16(sp)
ffffffffc0209eee:	842a                	mv	s0,a0
ffffffffc0209ef0:	7d08                	ld	a0,56(a0)
ffffffffc0209ef2:	e426                	sd	s1,8(sp)
ffffffffc0209ef4:	ec06                	sd	ra,24(sp)
ffffffffc0209ef6:	84ae                	mv	s1,a1
ffffffffc0209ef8:	b38ff0ef          	jal	ra,ffffffffc0209230 <bitmap_alloc>
ffffffffc0209efc:	e90d                	bnez	a0,ffffffffc0209f2e <sfs_block_alloc+0x44>
ffffffffc0209efe:	441c                	lw	a5,8(s0)
ffffffffc0209f00:	cbad                	beqz	a5,ffffffffc0209f72 <sfs_block_alloc+0x88>
ffffffffc0209f02:	37fd                	addiw	a5,a5,-1
ffffffffc0209f04:	c41c                	sw	a5,8(s0)
ffffffffc0209f06:	408c                	lw	a1,0(s1)
ffffffffc0209f08:	4785                	li	a5,1
ffffffffc0209f0a:	e03c                	sd	a5,64(s0)
ffffffffc0209f0c:	4054                	lw	a3,4(s0)
ffffffffc0209f0e:	c58d                	beqz	a1,ffffffffc0209f38 <sfs_block_alloc+0x4e>
ffffffffc0209f10:	02d5f463          	bgeu	a1,a3,ffffffffc0209f38 <sfs_block_alloc+0x4e>
ffffffffc0209f14:	7c08                	ld	a0,56(s0)
ffffffffc0209f16:	b8aff0ef          	jal	ra,ffffffffc02092a0 <bitmap_test>
ffffffffc0209f1a:	ed05                	bnez	a0,ffffffffc0209f52 <sfs_block_alloc+0x68>
ffffffffc0209f1c:	8522                	mv	a0,s0
ffffffffc0209f1e:	6442                	ld	s0,16(sp)
ffffffffc0209f20:	408c                	lw	a1,0(s1)
ffffffffc0209f22:	60e2                	ld	ra,24(sp)
ffffffffc0209f24:	64a2                	ld	s1,8(sp)
ffffffffc0209f26:	4605                	li	a2,1
ffffffffc0209f28:	6105                	addi	sp,sp,32
ffffffffc0209f2a:	4fe0106f          	j	ffffffffc020b428 <sfs_clear_block>
ffffffffc0209f2e:	60e2                	ld	ra,24(sp)
ffffffffc0209f30:	6442                	ld	s0,16(sp)
ffffffffc0209f32:	64a2                	ld	s1,8(sp)
ffffffffc0209f34:	6105                	addi	sp,sp,32
ffffffffc0209f36:	8082                	ret
ffffffffc0209f38:	872e                	mv	a4,a1
ffffffffc0209f3a:	00005617          	auipc	a2,0x5
ffffffffc0209f3e:	58e60613          	addi	a2,a2,1422 # ffffffffc020f4c8 <dev_node_ops+0x628>
ffffffffc0209f42:	05300593          	li	a1,83
ffffffffc0209f46:	00005517          	auipc	a0,0x5
ffffffffc0209f4a:	55250513          	addi	a0,a0,1362 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209f4e:	d50f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209f52:	00005697          	auipc	a3,0x5
ffffffffc0209f56:	60668693          	addi	a3,a3,1542 # ffffffffc020f558 <dev_node_ops+0x6b8>
ffffffffc0209f5a:	00002617          	auipc	a2,0x2
ffffffffc0209f5e:	f8e60613          	addi	a2,a2,-114 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209f62:	06100593          	li	a1,97
ffffffffc0209f66:	00005517          	auipc	a0,0x5
ffffffffc0209f6a:	53250513          	addi	a0,a0,1330 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209f6e:	d30f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc0209f72:	00005697          	auipc	a3,0x5
ffffffffc0209f76:	5c668693          	addi	a3,a3,1478 # ffffffffc020f538 <dev_node_ops+0x698>
ffffffffc0209f7a:	00002617          	auipc	a2,0x2
ffffffffc0209f7e:	f6e60613          	addi	a2,a2,-146 # ffffffffc020bee8 <commands+0x210>
ffffffffc0209f82:	05f00593          	li	a1,95
ffffffffc0209f86:	00005517          	auipc	a0,0x5
ffffffffc0209f8a:	51250513          	addi	a0,a0,1298 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc0209f8e:	d10f60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc0209f92 <sfs_bmap_load_nolock>:
ffffffffc0209f92:	7159                	addi	sp,sp,-112
ffffffffc0209f94:	f85a                	sd	s6,48(sp)
ffffffffc0209f96:	0005bb03          	ld	s6,0(a1)
ffffffffc0209f9a:	f45e                	sd	s7,40(sp)
ffffffffc0209f9c:	f486                	sd	ra,104(sp)
ffffffffc0209f9e:	008b2b83          	lw	s7,8(s6)
ffffffffc0209fa2:	f0a2                	sd	s0,96(sp)
ffffffffc0209fa4:	eca6                	sd	s1,88(sp)
ffffffffc0209fa6:	e8ca                	sd	s2,80(sp)
ffffffffc0209fa8:	e4ce                	sd	s3,72(sp)
ffffffffc0209faa:	e0d2                	sd	s4,64(sp)
ffffffffc0209fac:	fc56                	sd	s5,56(sp)
ffffffffc0209fae:	f062                	sd	s8,32(sp)
ffffffffc0209fb0:	ec66                	sd	s9,24(sp)
ffffffffc0209fb2:	18cbe363          	bltu	s7,a2,ffffffffc020a138 <sfs_bmap_load_nolock+0x1a6>
ffffffffc0209fb6:	47ad                	li	a5,11
ffffffffc0209fb8:	8aae                	mv	s5,a1
ffffffffc0209fba:	8432                	mv	s0,a2
ffffffffc0209fbc:	84aa                	mv	s1,a0
ffffffffc0209fbe:	89b6                	mv	s3,a3
ffffffffc0209fc0:	04c7f563          	bgeu	a5,a2,ffffffffc020a00a <sfs_bmap_load_nolock+0x78>
ffffffffc0209fc4:	ff46071b          	addiw	a4,a2,-12
ffffffffc0209fc8:	0007069b          	sext.w	a3,a4
ffffffffc0209fcc:	3ff00793          	li	a5,1023
ffffffffc0209fd0:	1ad7e163          	bltu	a5,a3,ffffffffc020a172 <sfs_bmap_load_nolock+0x1e0>
ffffffffc0209fd4:	03cb2a03          	lw	s4,60(s6)
ffffffffc0209fd8:	02071793          	slli	a5,a4,0x20
ffffffffc0209fdc:	c602                	sw	zero,12(sp)
ffffffffc0209fde:	c452                	sw	s4,8(sp)
ffffffffc0209fe0:	01e7dc13          	srli	s8,a5,0x1e
ffffffffc0209fe4:	0e0a1e63          	bnez	s4,ffffffffc020a0e0 <sfs_bmap_load_nolock+0x14e>
ffffffffc0209fe8:	0acb8663          	beq	s7,a2,ffffffffc020a094 <sfs_bmap_load_nolock+0x102>
ffffffffc0209fec:	4a01                	li	s4,0
ffffffffc0209fee:	40d4                	lw	a3,4(s1)
ffffffffc0209ff0:	8752                	mv	a4,s4
ffffffffc0209ff2:	00005617          	auipc	a2,0x5
ffffffffc0209ff6:	4d660613          	addi	a2,a2,1238 # ffffffffc020f4c8 <dev_node_ops+0x628>
ffffffffc0209ffa:	05300593          	li	a1,83
ffffffffc0209ffe:	00005517          	auipc	a0,0x5
ffffffffc020a002:	49a50513          	addi	a0,a0,1178 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a006:	c98f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020a00a:	02061793          	slli	a5,a2,0x20
ffffffffc020a00e:	01e7da13          	srli	s4,a5,0x1e
ffffffffc020a012:	9a5a                	add	s4,s4,s6
ffffffffc020a014:	00ca2583          	lw	a1,12(s4)
ffffffffc020a018:	c22e                	sw	a1,4(sp)
ffffffffc020a01a:	ed99                	bnez	a1,ffffffffc020a038 <sfs_bmap_load_nolock+0xa6>
ffffffffc020a01c:	fccb98e3          	bne	s7,a2,ffffffffc0209fec <sfs_bmap_load_nolock+0x5a>
ffffffffc020a020:	004c                	addi	a1,sp,4
ffffffffc020a022:	ec9ff0ef          	jal	ra,ffffffffc0209eea <sfs_block_alloc>
ffffffffc020a026:	892a                	mv	s2,a0
ffffffffc020a028:	e921                	bnez	a0,ffffffffc020a078 <sfs_bmap_load_nolock+0xe6>
ffffffffc020a02a:	4592                	lw	a1,4(sp)
ffffffffc020a02c:	4705                	li	a4,1
ffffffffc020a02e:	00ba2623          	sw	a1,12(s4)
ffffffffc020a032:	00eab823          	sd	a4,16(s5)
ffffffffc020a036:	d9dd                	beqz	a1,ffffffffc0209fec <sfs_bmap_load_nolock+0x5a>
ffffffffc020a038:	40d4                	lw	a3,4(s1)
ffffffffc020a03a:	10d5ff63          	bgeu	a1,a3,ffffffffc020a158 <sfs_bmap_load_nolock+0x1c6>
ffffffffc020a03e:	7c88                	ld	a0,56(s1)
ffffffffc020a040:	a60ff0ef          	jal	ra,ffffffffc02092a0 <bitmap_test>
ffffffffc020a044:	18051363          	bnez	a0,ffffffffc020a1ca <sfs_bmap_load_nolock+0x238>
ffffffffc020a048:	4a12                	lw	s4,4(sp)
ffffffffc020a04a:	fa0a02e3          	beqz	s4,ffffffffc0209fee <sfs_bmap_load_nolock+0x5c>
ffffffffc020a04e:	40dc                	lw	a5,4(s1)
ffffffffc020a050:	f8fa7fe3          	bgeu	s4,a5,ffffffffc0209fee <sfs_bmap_load_nolock+0x5c>
ffffffffc020a054:	7c88                	ld	a0,56(s1)
ffffffffc020a056:	85d2                	mv	a1,s4
ffffffffc020a058:	a48ff0ef          	jal	ra,ffffffffc02092a0 <bitmap_test>
ffffffffc020a05c:	12051763          	bnez	a0,ffffffffc020a18a <sfs_bmap_load_nolock+0x1f8>
ffffffffc020a060:	008b9763          	bne	s7,s0,ffffffffc020a06e <sfs_bmap_load_nolock+0xdc>
ffffffffc020a064:	008b2783          	lw	a5,8(s6)
ffffffffc020a068:	2785                	addiw	a5,a5,1
ffffffffc020a06a:	00fb2423          	sw	a5,8(s6)
ffffffffc020a06e:	4901                	li	s2,0
ffffffffc020a070:	00098463          	beqz	s3,ffffffffc020a078 <sfs_bmap_load_nolock+0xe6>
ffffffffc020a074:	0149a023          	sw	s4,0(s3)
ffffffffc020a078:	70a6                	ld	ra,104(sp)
ffffffffc020a07a:	7406                	ld	s0,96(sp)
ffffffffc020a07c:	64e6                	ld	s1,88(sp)
ffffffffc020a07e:	69a6                	ld	s3,72(sp)
ffffffffc020a080:	6a06                	ld	s4,64(sp)
ffffffffc020a082:	7ae2                	ld	s5,56(sp)
ffffffffc020a084:	7b42                	ld	s6,48(sp)
ffffffffc020a086:	7ba2                	ld	s7,40(sp)
ffffffffc020a088:	7c02                	ld	s8,32(sp)
ffffffffc020a08a:	6ce2                	ld	s9,24(sp)
ffffffffc020a08c:	854a                	mv	a0,s2
ffffffffc020a08e:	6946                	ld	s2,80(sp)
ffffffffc020a090:	6165                	addi	sp,sp,112
ffffffffc020a092:	8082                	ret
ffffffffc020a094:	002c                	addi	a1,sp,8
ffffffffc020a096:	e55ff0ef          	jal	ra,ffffffffc0209eea <sfs_block_alloc>
ffffffffc020a09a:	892a                	mv	s2,a0
ffffffffc020a09c:	00c10c93          	addi	s9,sp,12
ffffffffc020a0a0:	fd61                	bnez	a0,ffffffffc020a078 <sfs_bmap_load_nolock+0xe6>
ffffffffc020a0a2:	85e6                	mv	a1,s9
ffffffffc020a0a4:	8526                	mv	a0,s1
ffffffffc020a0a6:	e45ff0ef          	jal	ra,ffffffffc0209eea <sfs_block_alloc>
ffffffffc020a0aa:	892a                	mv	s2,a0
ffffffffc020a0ac:	e925                	bnez	a0,ffffffffc020a11c <sfs_bmap_load_nolock+0x18a>
ffffffffc020a0ae:	46a2                	lw	a3,8(sp)
ffffffffc020a0b0:	85e6                	mv	a1,s9
ffffffffc020a0b2:	8762                	mv	a4,s8
ffffffffc020a0b4:	4611                	li	a2,4
ffffffffc020a0b6:	8526                	mv	a0,s1
ffffffffc020a0b8:	220010ef          	jal	ra,ffffffffc020b2d8 <sfs_wbuf>
ffffffffc020a0bc:	45b2                	lw	a1,12(sp)
ffffffffc020a0be:	892a                	mv	s2,a0
ffffffffc020a0c0:	e939                	bnez	a0,ffffffffc020a116 <sfs_bmap_load_nolock+0x184>
ffffffffc020a0c2:	03cb2683          	lw	a3,60(s6)
ffffffffc020a0c6:	4722                	lw	a4,8(sp)
ffffffffc020a0c8:	c22e                	sw	a1,4(sp)
ffffffffc020a0ca:	f6d706e3          	beq	a4,a3,ffffffffc020a036 <sfs_bmap_load_nolock+0xa4>
ffffffffc020a0ce:	eef1                	bnez	a3,ffffffffc020a1aa <sfs_bmap_load_nolock+0x218>
ffffffffc020a0d0:	02eb2e23          	sw	a4,60(s6)
ffffffffc020a0d4:	4705                	li	a4,1
ffffffffc020a0d6:	00eab823          	sd	a4,16(s5)
ffffffffc020a0da:	f00589e3          	beqz	a1,ffffffffc0209fec <sfs_bmap_load_nolock+0x5a>
ffffffffc020a0de:	bfa9                	j	ffffffffc020a038 <sfs_bmap_load_nolock+0xa6>
ffffffffc020a0e0:	00c10c93          	addi	s9,sp,12
ffffffffc020a0e4:	8762                	mv	a4,s8
ffffffffc020a0e6:	86d2                	mv	a3,s4
ffffffffc020a0e8:	4611                	li	a2,4
ffffffffc020a0ea:	85e6                	mv	a1,s9
ffffffffc020a0ec:	16c010ef          	jal	ra,ffffffffc020b258 <sfs_rbuf>
ffffffffc020a0f0:	892a                	mv	s2,a0
ffffffffc020a0f2:	f159                	bnez	a0,ffffffffc020a078 <sfs_bmap_load_nolock+0xe6>
ffffffffc020a0f4:	45b2                	lw	a1,12(sp)
ffffffffc020a0f6:	e995                	bnez	a1,ffffffffc020a12a <sfs_bmap_load_nolock+0x198>
ffffffffc020a0f8:	fa8b85e3          	beq	s7,s0,ffffffffc020a0a2 <sfs_bmap_load_nolock+0x110>
ffffffffc020a0fc:	03cb2703          	lw	a4,60(s6)
ffffffffc020a100:	47a2                	lw	a5,8(sp)
ffffffffc020a102:	c202                	sw	zero,4(sp)
ffffffffc020a104:	eee784e3          	beq	a5,a4,ffffffffc0209fec <sfs_bmap_load_nolock+0x5a>
ffffffffc020a108:	e34d                	bnez	a4,ffffffffc020a1aa <sfs_bmap_load_nolock+0x218>
ffffffffc020a10a:	02fb2e23          	sw	a5,60(s6)
ffffffffc020a10e:	4785                	li	a5,1
ffffffffc020a110:	00fab823          	sd	a5,16(s5)
ffffffffc020a114:	bde1                	j	ffffffffc0209fec <sfs_bmap_load_nolock+0x5a>
ffffffffc020a116:	8526                	mv	a0,s1
ffffffffc020a118:	bc1ff0ef          	jal	ra,ffffffffc0209cd8 <sfs_block_free>
ffffffffc020a11c:	45a2                	lw	a1,8(sp)
ffffffffc020a11e:	f4ba0de3          	beq	s4,a1,ffffffffc020a078 <sfs_bmap_load_nolock+0xe6>
ffffffffc020a122:	8526                	mv	a0,s1
ffffffffc020a124:	bb5ff0ef          	jal	ra,ffffffffc0209cd8 <sfs_block_free>
ffffffffc020a128:	bf81                	j	ffffffffc020a078 <sfs_bmap_load_nolock+0xe6>
ffffffffc020a12a:	03cb2683          	lw	a3,60(s6)
ffffffffc020a12e:	4722                	lw	a4,8(sp)
ffffffffc020a130:	c22e                	sw	a1,4(sp)
ffffffffc020a132:	f8e69ee3          	bne	a3,a4,ffffffffc020a0ce <sfs_bmap_load_nolock+0x13c>
ffffffffc020a136:	b709                	j	ffffffffc020a038 <sfs_bmap_load_nolock+0xa6>
ffffffffc020a138:	00005697          	auipc	a3,0x5
ffffffffc020a13c:	44868693          	addi	a3,a3,1096 # ffffffffc020f580 <dev_node_ops+0x6e0>
ffffffffc020a140:	00002617          	auipc	a2,0x2
ffffffffc020a144:	da860613          	addi	a2,a2,-600 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a148:	16400593          	li	a1,356
ffffffffc020a14c:	00005517          	auipc	a0,0x5
ffffffffc020a150:	34c50513          	addi	a0,a0,844 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a154:	b4af60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020a158:	872e                	mv	a4,a1
ffffffffc020a15a:	00005617          	auipc	a2,0x5
ffffffffc020a15e:	36e60613          	addi	a2,a2,878 # ffffffffc020f4c8 <dev_node_ops+0x628>
ffffffffc020a162:	05300593          	li	a1,83
ffffffffc020a166:	00005517          	auipc	a0,0x5
ffffffffc020a16a:	33250513          	addi	a0,a0,818 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a16e:	b30f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020a172:	00005617          	auipc	a2,0x5
ffffffffc020a176:	43e60613          	addi	a2,a2,1086 # ffffffffc020f5b0 <dev_node_ops+0x710>
ffffffffc020a17a:	11e00593          	li	a1,286
ffffffffc020a17e:	00005517          	auipc	a0,0x5
ffffffffc020a182:	31a50513          	addi	a0,a0,794 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a186:	b18f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020a18a:	00005697          	auipc	a3,0x5
ffffffffc020a18e:	37668693          	addi	a3,a3,886 # ffffffffc020f500 <dev_node_ops+0x660>
ffffffffc020a192:	00002617          	auipc	a2,0x2
ffffffffc020a196:	d5660613          	addi	a2,a2,-682 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a19a:	16b00593          	li	a1,363
ffffffffc020a19e:	00005517          	auipc	a0,0x5
ffffffffc020a1a2:	2fa50513          	addi	a0,a0,762 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a1a6:	af8f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020a1aa:	00005697          	auipc	a3,0x5
ffffffffc020a1ae:	3ee68693          	addi	a3,a3,1006 # ffffffffc020f598 <dev_node_ops+0x6f8>
ffffffffc020a1b2:	00002617          	auipc	a2,0x2
ffffffffc020a1b6:	d3660613          	addi	a2,a2,-714 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a1ba:	11800593          	li	a1,280
ffffffffc020a1be:	00005517          	auipc	a0,0x5
ffffffffc020a1c2:	2da50513          	addi	a0,a0,730 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a1c6:	ad8f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020a1ca:	00005697          	auipc	a3,0x5
ffffffffc020a1ce:	41668693          	addi	a3,a3,1046 # ffffffffc020f5e0 <dev_node_ops+0x740>
ffffffffc020a1d2:	00002617          	auipc	a2,0x2
ffffffffc020a1d6:	d1660613          	addi	a2,a2,-746 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a1da:	12100593          	li	a1,289
ffffffffc020a1de:	00005517          	auipc	a0,0x5
ffffffffc020a1e2:	2ba50513          	addi	a0,a0,698 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a1e6:	ab8f60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020a1ea <sfs_io_nolock>:
ffffffffc020a1ea:	7175                	addi	sp,sp,-144
ffffffffc020a1ec:	f0d2                	sd	s4,96(sp)
ffffffffc020a1ee:	8a2e                	mv	s4,a1
ffffffffc020a1f0:	618c                	ld	a1,0(a1)
ffffffffc020a1f2:	e506                	sd	ra,136(sp)
ffffffffc020a1f4:	e122                	sd	s0,128(sp)
ffffffffc020a1f6:	0045d883          	lhu	a7,4(a1)
ffffffffc020a1fa:	fca6                	sd	s1,120(sp)
ffffffffc020a1fc:	f8ca                	sd	s2,112(sp)
ffffffffc020a1fe:	f4ce                	sd	s3,104(sp)
ffffffffc020a200:	ecd6                	sd	s5,88(sp)
ffffffffc020a202:	e8da                	sd	s6,80(sp)
ffffffffc020a204:	e4de                	sd	s7,72(sp)
ffffffffc020a206:	e0e2                	sd	s8,64(sp)
ffffffffc020a208:	fc66                	sd	s9,56(sp)
ffffffffc020a20a:	f86a                	sd	s10,48(sp)
ffffffffc020a20c:	f46e                	sd	s11,40(sp)
ffffffffc020a20e:	4809                	li	a6,2
ffffffffc020a210:	19088763          	beq	a7,a6,ffffffffc020a39e <sfs_io_nolock+0x1b4>
ffffffffc020a214:	00073a83          	ld	s5,0(a4)
ffffffffc020a218:	8c3a                	mv	s8,a4
ffffffffc020a21a:	000c3023          	sd	zero,0(s8) # 3000 <_binary_bin_swap_img_size-0x4d00>
ffffffffc020a21e:	08000737          	lui	a4,0x8000
ffffffffc020a222:	84b6                	mv	s1,a3
ffffffffc020a224:	8d36                	mv	s10,a3
ffffffffc020a226:	9ab6                	add	s5,s5,a3
ffffffffc020a228:	16e6f963          	bgeu	a3,a4,ffffffffc020a39a <sfs_io_nolock+0x1b0>
ffffffffc020a22c:	16dac763          	blt	s5,a3,ffffffffc020a39a <sfs_io_nolock+0x1b0>
ffffffffc020a230:	892a                	mv	s2,a0
ffffffffc020a232:	4501                	li	a0,0
ffffffffc020a234:	0d568163          	beq	a3,s5,ffffffffc020a2f6 <sfs_io_nolock+0x10c>
ffffffffc020a238:	8432                	mv	s0,a2
ffffffffc020a23a:	01577463          	bgeu	a4,s5,ffffffffc020a242 <sfs_io_nolock+0x58>
ffffffffc020a23e:	08000ab7          	lui	s5,0x8000
ffffffffc020a242:	cbe9                	beqz	a5,ffffffffc020a314 <sfs_io_nolock+0x12a>
ffffffffc020a244:	00001797          	auipc	a5,0x1
ffffffffc020a248:	09478793          	addi	a5,a5,148 # ffffffffc020b2d8 <sfs_wbuf>
ffffffffc020a24c:	00001c97          	auipc	s9,0x1
ffffffffc020a250:	facc8c93          	addi	s9,s9,-84 # ffffffffc020b1f8 <sfs_wblock>
ffffffffc020a254:	e03e                	sd	a5,0(sp)
ffffffffc020a256:	6705                	lui	a4,0x1
ffffffffc020a258:	40c4dd93          	srai	s11,s1,0xc
ffffffffc020a25c:	40cadb13          	srai	s6,s5,0xc
ffffffffc020a260:	fff70b93          	addi	s7,a4,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc020a264:	41bb07bb          	subw	a5,s6,s11
ffffffffc020a268:	0174fbb3          	and	s7,s1,s7
ffffffffc020a26c:	8b3e                	mv	s6,a5
ffffffffc020a26e:	2d81                	sext.w	s11,s11
ffffffffc020a270:	89de                	mv	s3,s7
ffffffffc020a272:	020b8b63          	beqz	s7,ffffffffc020a2a8 <sfs_io_nolock+0xbe>
ffffffffc020a276:	409a89b3          	sub	s3,s5,s1
ffffffffc020a27a:	efd5                	bnez	a5,ffffffffc020a336 <sfs_io_nolock+0x14c>
ffffffffc020a27c:	0874                	addi	a3,sp,28
ffffffffc020a27e:	866e                	mv	a2,s11
ffffffffc020a280:	85d2                	mv	a1,s4
ffffffffc020a282:	854a                	mv	a0,s2
ffffffffc020a284:	e43e                	sd	a5,8(sp)
ffffffffc020a286:	d0dff0ef          	jal	ra,ffffffffc0209f92 <sfs_bmap_load_nolock>
ffffffffc020a28a:	e161                	bnez	a0,ffffffffc020a34a <sfs_io_nolock+0x160>
ffffffffc020a28c:	46f2                	lw	a3,28(sp)
ffffffffc020a28e:	6782                	ld	a5,0(sp)
ffffffffc020a290:	875e                	mv	a4,s7
ffffffffc020a292:	864e                	mv	a2,s3
ffffffffc020a294:	85a2                	mv	a1,s0
ffffffffc020a296:	854a                	mv	a0,s2
ffffffffc020a298:	9782                	jalr	a5
ffffffffc020a29a:	e945                	bnez	a0,ffffffffc020a34a <sfs_io_nolock+0x160>
ffffffffc020a29c:	67a2                	ld	a5,8(sp)
ffffffffc020a29e:	cf85                	beqz	a5,ffffffffc020a2d6 <sfs_io_nolock+0xec>
ffffffffc020a2a0:	944e                	add	s0,s0,s3
ffffffffc020a2a2:	2d85                	addiw	s11,s11,1
ffffffffc020a2a4:	fffb079b          	addiw	a5,s6,-1
ffffffffc020a2a8:	cfd5                	beqz	a5,ffffffffc020a364 <sfs_io_nolock+0x17a>
ffffffffc020a2aa:	01b78bbb          	addw	s7,a5,s11
ffffffffc020a2ae:	6b05                	lui	s6,0x1
ffffffffc020a2b0:	a821                	j	ffffffffc020a2c8 <sfs_io_nolock+0xde>
ffffffffc020a2b2:	4672                	lw	a2,28(sp)
ffffffffc020a2b4:	4685                	li	a3,1
ffffffffc020a2b6:	85a2                	mv	a1,s0
ffffffffc020a2b8:	854a                	mv	a0,s2
ffffffffc020a2ba:	9c82                	jalr	s9
ffffffffc020a2bc:	ed09                	bnez	a0,ffffffffc020a2d6 <sfs_io_nolock+0xec>
ffffffffc020a2be:	2d85                	addiw	s11,s11,1
ffffffffc020a2c0:	99da                	add	s3,s3,s6
ffffffffc020a2c2:	945a                	add	s0,s0,s6
ffffffffc020a2c4:	0b7d8163          	beq	s11,s7,ffffffffc020a366 <sfs_io_nolock+0x17c>
ffffffffc020a2c8:	0874                	addi	a3,sp,28
ffffffffc020a2ca:	866e                	mv	a2,s11
ffffffffc020a2cc:	85d2                	mv	a1,s4
ffffffffc020a2ce:	854a                	mv	a0,s2
ffffffffc020a2d0:	cc3ff0ef          	jal	ra,ffffffffc0209f92 <sfs_bmap_load_nolock>
ffffffffc020a2d4:	dd79                	beqz	a0,ffffffffc020a2b2 <sfs_io_nolock+0xc8>
ffffffffc020a2d6:	01348d33          	add	s10,s1,s3
ffffffffc020a2da:	000a3783          	ld	a5,0(s4)
ffffffffc020a2de:	013c3023          	sd	s3,0(s8)
ffffffffc020a2e2:	0007e703          	lwu	a4,0(a5)
ffffffffc020a2e6:	01a77863          	bgeu	a4,s10,ffffffffc020a2f6 <sfs_io_nolock+0x10c>
ffffffffc020a2ea:	013484bb          	addw	s1,s1,s3
ffffffffc020a2ee:	c384                	sw	s1,0(a5)
ffffffffc020a2f0:	4785                	li	a5,1
ffffffffc020a2f2:	00fa3823          	sd	a5,16(s4)
ffffffffc020a2f6:	60aa                	ld	ra,136(sp)
ffffffffc020a2f8:	640a                	ld	s0,128(sp)
ffffffffc020a2fa:	74e6                	ld	s1,120(sp)
ffffffffc020a2fc:	7946                	ld	s2,112(sp)
ffffffffc020a2fe:	79a6                	ld	s3,104(sp)
ffffffffc020a300:	7a06                	ld	s4,96(sp)
ffffffffc020a302:	6ae6                	ld	s5,88(sp)
ffffffffc020a304:	6b46                	ld	s6,80(sp)
ffffffffc020a306:	6ba6                	ld	s7,72(sp)
ffffffffc020a308:	6c06                	ld	s8,64(sp)
ffffffffc020a30a:	7ce2                	ld	s9,56(sp)
ffffffffc020a30c:	7d42                	ld	s10,48(sp)
ffffffffc020a30e:	7da2                	ld	s11,40(sp)
ffffffffc020a310:	6149                	addi	sp,sp,144
ffffffffc020a312:	8082                	ret
ffffffffc020a314:	0005e783          	lwu	a5,0(a1)
ffffffffc020a318:	4501                	li	a0,0
ffffffffc020a31a:	fcf4dee3          	bge	s1,a5,ffffffffc020a2f6 <sfs_io_nolock+0x10c>
ffffffffc020a31e:	0357c863          	blt	a5,s5,ffffffffc020a34e <sfs_io_nolock+0x164>
ffffffffc020a322:	00001797          	auipc	a5,0x1
ffffffffc020a326:	f3678793          	addi	a5,a5,-202 # ffffffffc020b258 <sfs_rbuf>
ffffffffc020a32a:	00001c97          	auipc	s9,0x1
ffffffffc020a32e:	e6ec8c93          	addi	s9,s9,-402 # ffffffffc020b198 <sfs_rblock>
ffffffffc020a332:	e03e                	sd	a5,0(sp)
ffffffffc020a334:	b70d                	j	ffffffffc020a256 <sfs_io_nolock+0x6c>
ffffffffc020a336:	0874                	addi	a3,sp,28
ffffffffc020a338:	866e                	mv	a2,s11
ffffffffc020a33a:	85d2                	mv	a1,s4
ffffffffc020a33c:	854a                	mv	a0,s2
ffffffffc020a33e:	417709b3          	sub	s3,a4,s7
ffffffffc020a342:	e43e                	sd	a5,8(sp)
ffffffffc020a344:	c4fff0ef          	jal	ra,ffffffffc0209f92 <sfs_bmap_load_nolock>
ffffffffc020a348:	d131                	beqz	a0,ffffffffc020a28c <sfs_io_nolock+0xa2>
ffffffffc020a34a:	4981                	li	s3,0
ffffffffc020a34c:	b779                	j	ffffffffc020a2da <sfs_io_nolock+0xf0>
ffffffffc020a34e:	8abe                	mv	s5,a5
ffffffffc020a350:	00001797          	auipc	a5,0x1
ffffffffc020a354:	f0878793          	addi	a5,a5,-248 # ffffffffc020b258 <sfs_rbuf>
ffffffffc020a358:	00001c97          	auipc	s9,0x1
ffffffffc020a35c:	e40c8c93          	addi	s9,s9,-448 # ffffffffc020b198 <sfs_rblock>
ffffffffc020a360:	e03e                	sd	a5,0(sp)
ffffffffc020a362:	bdd5                	j	ffffffffc020a256 <sfs_io_nolock+0x6c>
ffffffffc020a364:	8bee                	mv	s7,s11
ffffffffc020a366:	1ad2                	slli	s5,s5,0x34
ffffffffc020a368:	034adb13          	srli	s6,s5,0x34
ffffffffc020a36c:	000a9663          	bnez	s5,ffffffffc020a378 <sfs_io_nolock+0x18e>
ffffffffc020a370:	01348d33          	add	s10,s1,s3
ffffffffc020a374:	4501                	li	a0,0
ffffffffc020a376:	b795                	j	ffffffffc020a2da <sfs_io_nolock+0xf0>
ffffffffc020a378:	0874                	addi	a3,sp,28
ffffffffc020a37a:	865e                	mv	a2,s7
ffffffffc020a37c:	85d2                	mv	a1,s4
ffffffffc020a37e:	854a                	mv	a0,s2
ffffffffc020a380:	c13ff0ef          	jal	ra,ffffffffc0209f92 <sfs_bmap_load_nolock>
ffffffffc020a384:	f929                	bnez	a0,ffffffffc020a2d6 <sfs_io_nolock+0xec>
ffffffffc020a386:	46f2                	lw	a3,28(sp)
ffffffffc020a388:	6782                	ld	a5,0(sp)
ffffffffc020a38a:	4701                	li	a4,0
ffffffffc020a38c:	865a                	mv	a2,s6
ffffffffc020a38e:	85a2                	mv	a1,s0
ffffffffc020a390:	854a                	mv	a0,s2
ffffffffc020a392:	9782                	jalr	a5
ffffffffc020a394:	f129                	bnez	a0,ffffffffc020a2d6 <sfs_io_nolock+0xec>
ffffffffc020a396:	99da                	add	s3,s3,s6
ffffffffc020a398:	bf3d                	j	ffffffffc020a2d6 <sfs_io_nolock+0xec>
ffffffffc020a39a:	5575                	li	a0,-3
ffffffffc020a39c:	bfa9                	j	ffffffffc020a2f6 <sfs_io_nolock+0x10c>
ffffffffc020a39e:	00005697          	auipc	a3,0x5
ffffffffc020a3a2:	26a68693          	addi	a3,a3,618 # ffffffffc020f608 <dev_node_ops+0x768>
ffffffffc020a3a6:	00002617          	auipc	a2,0x2
ffffffffc020a3aa:	b4260613          	addi	a2,a2,-1214 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a3ae:	22b00593          	li	a1,555
ffffffffc020a3b2:	00005517          	auipc	a0,0x5
ffffffffc020a3b6:	0e650513          	addi	a0,a0,230 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a3ba:	8e4f60ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020a3be <sfs_read>:
ffffffffc020a3be:	7139                	addi	sp,sp,-64
ffffffffc020a3c0:	f04a                	sd	s2,32(sp)
ffffffffc020a3c2:	06853903          	ld	s2,104(a0)
ffffffffc020a3c6:	fc06                	sd	ra,56(sp)
ffffffffc020a3c8:	f822                	sd	s0,48(sp)
ffffffffc020a3ca:	f426                	sd	s1,40(sp)
ffffffffc020a3cc:	ec4e                	sd	s3,24(sp)
ffffffffc020a3ce:	04090f63          	beqz	s2,ffffffffc020a42c <sfs_read+0x6e>
ffffffffc020a3d2:	0b092783          	lw	a5,176(s2)
ffffffffc020a3d6:	ebb9                	bnez	a5,ffffffffc020a42c <sfs_read+0x6e>
ffffffffc020a3d8:	4d38                	lw	a4,88(a0)
ffffffffc020a3da:	6785                	lui	a5,0x1
ffffffffc020a3dc:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a3e0:	842a                	mv	s0,a0
ffffffffc020a3e2:	06f71563          	bne	a4,a5,ffffffffc020a44c <sfs_read+0x8e>
ffffffffc020a3e6:	02050993          	addi	s3,a0,32
ffffffffc020a3ea:	854e                	mv	a0,s3
ffffffffc020a3ec:	84ae                	mv	s1,a1
ffffffffc020a3ee:	976fa0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc020a3f2:	0184b803          	ld	a6,24(s1)
ffffffffc020a3f6:	6494                	ld	a3,8(s1)
ffffffffc020a3f8:	6090                	ld	a2,0(s1)
ffffffffc020a3fa:	85a2                	mv	a1,s0
ffffffffc020a3fc:	4781                	li	a5,0
ffffffffc020a3fe:	0038                	addi	a4,sp,8
ffffffffc020a400:	854a                	mv	a0,s2
ffffffffc020a402:	e442                	sd	a6,8(sp)
ffffffffc020a404:	de7ff0ef          	jal	ra,ffffffffc020a1ea <sfs_io_nolock>
ffffffffc020a408:	65a2                	ld	a1,8(sp)
ffffffffc020a40a:	842a                	mv	s0,a0
ffffffffc020a40c:	ed81                	bnez	a1,ffffffffc020a424 <sfs_read+0x66>
ffffffffc020a40e:	854e                	mv	a0,s3
ffffffffc020a410:	950fa0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc020a414:	70e2                	ld	ra,56(sp)
ffffffffc020a416:	8522                	mv	a0,s0
ffffffffc020a418:	7442                	ld	s0,48(sp)
ffffffffc020a41a:	74a2                	ld	s1,40(sp)
ffffffffc020a41c:	7902                	ld	s2,32(sp)
ffffffffc020a41e:	69e2                	ld	s3,24(sp)
ffffffffc020a420:	6121                	addi	sp,sp,64
ffffffffc020a422:	8082                	ret
ffffffffc020a424:	8526                	mv	a0,s1
ffffffffc020a426:	832fb0ef          	jal	ra,ffffffffc0205458 <iobuf_skip>
ffffffffc020a42a:	b7d5                	j	ffffffffc020a40e <sfs_read+0x50>
ffffffffc020a42c:	00005697          	auipc	a3,0x5
ffffffffc020a430:	e8c68693          	addi	a3,a3,-372 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc020a434:	00002617          	auipc	a2,0x2
ffffffffc020a438:	ab460613          	addi	a2,a2,-1356 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a43c:	2ad00593          	li	a1,685
ffffffffc020a440:	00005517          	auipc	a0,0x5
ffffffffc020a444:	05850513          	addi	a0,a0,88 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a448:	856f60ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020a44c:	869ff0ef          	jal	ra,ffffffffc0209cb4 <sfs_io.part.0>

ffffffffc020a450 <sfs_write>:
ffffffffc020a450:	7139                	addi	sp,sp,-64
ffffffffc020a452:	f04a                	sd	s2,32(sp)
ffffffffc020a454:	06853903          	ld	s2,104(a0)
ffffffffc020a458:	fc06                	sd	ra,56(sp)
ffffffffc020a45a:	f822                	sd	s0,48(sp)
ffffffffc020a45c:	f426                	sd	s1,40(sp)
ffffffffc020a45e:	ec4e                	sd	s3,24(sp)
ffffffffc020a460:	04090f63          	beqz	s2,ffffffffc020a4be <sfs_write+0x6e>
ffffffffc020a464:	0b092783          	lw	a5,176(s2)
ffffffffc020a468:	ebb9                	bnez	a5,ffffffffc020a4be <sfs_write+0x6e>
ffffffffc020a46a:	4d38                	lw	a4,88(a0)
ffffffffc020a46c:	6785                	lui	a5,0x1
ffffffffc020a46e:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a472:	842a                	mv	s0,a0
ffffffffc020a474:	06f71563          	bne	a4,a5,ffffffffc020a4de <sfs_write+0x8e>
ffffffffc020a478:	02050993          	addi	s3,a0,32
ffffffffc020a47c:	854e                	mv	a0,s3
ffffffffc020a47e:	84ae                	mv	s1,a1
ffffffffc020a480:	8e4fa0ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc020a484:	0184b803          	ld	a6,24(s1)
ffffffffc020a488:	6494                	ld	a3,8(s1)
ffffffffc020a48a:	6090                	ld	a2,0(s1)
ffffffffc020a48c:	85a2                	mv	a1,s0
ffffffffc020a48e:	4785                	li	a5,1
ffffffffc020a490:	0038                	addi	a4,sp,8
ffffffffc020a492:	854a                	mv	a0,s2
ffffffffc020a494:	e442                	sd	a6,8(sp)
ffffffffc020a496:	d55ff0ef          	jal	ra,ffffffffc020a1ea <sfs_io_nolock>
ffffffffc020a49a:	65a2                	ld	a1,8(sp)
ffffffffc020a49c:	842a                	mv	s0,a0
ffffffffc020a49e:	ed81                	bnez	a1,ffffffffc020a4b6 <sfs_write+0x66>
ffffffffc020a4a0:	854e                	mv	a0,s3
ffffffffc020a4a2:	8befa0ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc020a4a6:	70e2                	ld	ra,56(sp)
ffffffffc020a4a8:	8522                	mv	a0,s0
ffffffffc020a4aa:	7442                	ld	s0,48(sp)
ffffffffc020a4ac:	74a2                	ld	s1,40(sp)
ffffffffc020a4ae:	7902                	ld	s2,32(sp)
ffffffffc020a4b0:	69e2                	ld	s3,24(sp)
ffffffffc020a4b2:	6121                	addi	sp,sp,64
ffffffffc020a4b4:	8082                	ret
ffffffffc020a4b6:	8526                	mv	a0,s1
ffffffffc020a4b8:	fa1fa0ef          	jal	ra,ffffffffc0205458 <iobuf_skip>
ffffffffc020a4bc:	b7d5                	j	ffffffffc020a4a0 <sfs_write+0x50>
ffffffffc020a4be:	00005697          	auipc	a3,0x5
ffffffffc020a4c2:	dfa68693          	addi	a3,a3,-518 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc020a4c6:	00002617          	auipc	a2,0x2
ffffffffc020a4ca:	a2260613          	addi	a2,a2,-1502 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a4ce:	2ad00593          	li	a1,685
ffffffffc020a4d2:	00005517          	auipc	a0,0x5
ffffffffc020a4d6:	fc650513          	addi	a0,a0,-58 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a4da:	fc5f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020a4de:	fd6ff0ef          	jal	ra,ffffffffc0209cb4 <sfs_io.part.0>

ffffffffc020a4e2 <sfs_dirent_read_nolock>:
ffffffffc020a4e2:	6198                	ld	a4,0(a1)
ffffffffc020a4e4:	7179                	addi	sp,sp,-48
ffffffffc020a4e6:	f406                	sd	ra,40(sp)
ffffffffc020a4e8:	00475883          	lhu	a7,4(a4)
ffffffffc020a4ec:	f022                	sd	s0,32(sp)
ffffffffc020a4ee:	ec26                	sd	s1,24(sp)
ffffffffc020a4f0:	4809                	li	a6,2
ffffffffc020a4f2:	05089b63          	bne	a7,a6,ffffffffc020a548 <sfs_dirent_read_nolock+0x66>
ffffffffc020a4f6:	4718                	lw	a4,8(a4)
ffffffffc020a4f8:	87b2                	mv	a5,a2
ffffffffc020a4fa:	2601                	sext.w	a2,a2
ffffffffc020a4fc:	04e7f663          	bgeu	a5,a4,ffffffffc020a548 <sfs_dirent_read_nolock+0x66>
ffffffffc020a500:	84b6                	mv	s1,a3
ffffffffc020a502:	0074                	addi	a3,sp,12
ffffffffc020a504:	842a                	mv	s0,a0
ffffffffc020a506:	a8dff0ef          	jal	ra,ffffffffc0209f92 <sfs_bmap_load_nolock>
ffffffffc020a50a:	c511                	beqz	a0,ffffffffc020a516 <sfs_dirent_read_nolock+0x34>
ffffffffc020a50c:	70a2                	ld	ra,40(sp)
ffffffffc020a50e:	7402                	ld	s0,32(sp)
ffffffffc020a510:	64e2                	ld	s1,24(sp)
ffffffffc020a512:	6145                	addi	sp,sp,48
ffffffffc020a514:	8082                	ret
ffffffffc020a516:	45b2                	lw	a1,12(sp)
ffffffffc020a518:	4054                	lw	a3,4(s0)
ffffffffc020a51a:	c5b9                	beqz	a1,ffffffffc020a568 <sfs_dirent_read_nolock+0x86>
ffffffffc020a51c:	04d5f663          	bgeu	a1,a3,ffffffffc020a568 <sfs_dirent_read_nolock+0x86>
ffffffffc020a520:	7c08                	ld	a0,56(s0)
ffffffffc020a522:	d7ffe0ef          	jal	ra,ffffffffc02092a0 <bitmap_test>
ffffffffc020a526:	ed31                	bnez	a0,ffffffffc020a582 <sfs_dirent_read_nolock+0xa0>
ffffffffc020a528:	46b2                	lw	a3,12(sp)
ffffffffc020a52a:	4701                	li	a4,0
ffffffffc020a52c:	10400613          	li	a2,260
ffffffffc020a530:	85a6                	mv	a1,s1
ffffffffc020a532:	8522                	mv	a0,s0
ffffffffc020a534:	525000ef          	jal	ra,ffffffffc020b258 <sfs_rbuf>
ffffffffc020a538:	f971                	bnez	a0,ffffffffc020a50c <sfs_dirent_read_nolock+0x2a>
ffffffffc020a53a:	100481a3          	sb	zero,259(s1)
ffffffffc020a53e:	70a2                	ld	ra,40(sp)
ffffffffc020a540:	7402                	ld	s0,32(sp)
ffffffffc020a542:	64e2                	ld	s1,24(sp)
ffffffffc020a544:	6145                	addi	sp,sp,48
ffffffffc020a546:	8082                	ret
ffffffffc020a548:	00005697          	auipc	a3,0x5
ffffffffc020a54c:	0e068693          	addi	a3,a3,224 # ffffffffc020f628 <dev_node_ops+0x788>
ffffffffc020a550:	00002617          	auipc	a2,0x2
ffffffffc020a554:	99860613          	addi	a2,a2,-1640 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a558:	18e00593          	li	a1,398
ffffffffc020a55c:	00005517          	auipc	a0,0x5
ffffffffc020a560:	f3c50513          	addi	a0,a0,-196 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a564:	f3bf50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020a568:	872e                	mv	a4,a1
ffffffffc020a56a:	00005617          	auipc	a2,0x5
ffffffffc020a56e:	f5e60613          	addi	a2,a2,-162 # ffffffffc020f4c8 <dev_node_ops+0x628>
ffffffffc020a572:	05300593          	li	a1,83
ffffffffc020a576:	00005517          	auipc	a0,0x5
ffffffffc020a57a:	f2250513          	addi	a0,a0,-222 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a57e:	f21f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020a582:	00005697          	auipc	a3,0x5
ffffffffc020a586:	f7e68693          	addi	a3,a3,-130 # ffffffffc020f500 <dev_node_ops+0x660>
ffffffffc020a58a:	00002617          	auipc	a2,0x2
ffffffffc020a58e:	95e60613          	addi	a2,a2,-1698 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a592:	19500593          	li	a1,405
ffffffffc020a596:	00005517          	auipc	a0,0x5
ffffffffc020a59a:	f0250513          	addi	a0,a0,-254 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a59e:	f01f50ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020a5a2 <sfs_getdirentry>:
ffffffffc020a5a2:	715d                	addi	sp,sp,-80
ffffffffc020a5a4:	ec56                	sd	s5,24(sp)
ffffffffc020a5a6:	8aaa                	mv	s5,a0
ffffffffc020a5a8:	10400513          	li	a0,260
ffffffffc020a5ac:	e85a                	sd	s6,16(sp)
ffffffffc020a5ae:	e486                	sd	ra,72(sp)
ffffffffc020a5b0:	e0a2                	sd	s0,64(sp)
ffffffffc020a5b2:	fc26                	sd	s1,56(sp)
ffffffffc020a5b4:	f84a                	sd	s2,48(sp)
ffffffffc020a5b6:	f44e                	sd	s3,40(sp)
ffffffffc020a5b8:	f052                	sd	s4,32(sp)
ffffffffc020a5ba:	e45e                	sd	s7,8(sp)
ffffffffc020a5bc:	e062                	sd	s8,0(sp)
ffffffffc020a5be:	8b2e                	mv	s6,a1
ffffffffc020a5c0:	9cff70ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc020a5c4:	cd61                	beqz	a0,ffffffffc020a69c <sfs_getdirentry+0xfa>
ffffffffc020a5c6:	068abb83          	ld	s7,104(s5) # 8000068 <_binary_bin_sfs_img_size+0x7f8ad68>
ffffffffc020a5ca:	0c0b8b63          	beqz	s7,ffffffffc020a6a0 <sfs_getdirentry+0xfe>
ffffffffc020a5ce:	0b0ba783          	lw	a5,176(s7) # 10b0 <_binary_bin_swap_img_size-0x6c50>
ffffffffc020a5d2:	e7f9                	bnez	a5,ffffffffc020a6a0 <sfs_getdirentry+0xfe>
ffffffffc020a5d4:	058aa703          	lw	a4,88(s5)
ffffffffc020a5d8:	6785                	lui	a5,0x1
ffffffffc020a5da:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a5de:	0ef71163          	bne	a4,a5,ffffffffc020a6c0 <sfs_getdirentry+0x11e>
ffffffffc020a5e2:	008b3983          	ld	s3,8(s6) # 1008 <_binary_bin_swap_img_size-0x6cf8>
ffffffffc020a5e6:	892a                	mv	s2,a0
ffffffffc020a5e8:	0a09c163          	bltz	s3,ffffffffc020a68a <sfs_getdirentry+0xe8>
ffffffffc020a5ec:	0ff9f793          	zext.b	a5,s3
ffffffffc020a5f0:	efc9                	bnez	a5,ffffffffc020a68a <sfs_getdirentry+0xe8>
ffffffffc020a5f2:	000ab783          	ld	a5,0(s5)
ffffffffc020a5f6:	0089d993          	srli	s3,s3,0x8
ffffffffc020a5fa:	2981                	sext.w	s3,s3
ffffffffc020a5fc:	479c                	lw	a5,8(a5)
ffffffffc020a5fe:	0937eb63          	bltu	a5,s3,ffffffffc020a694 <sfs_getdirentry+0xf2>
ffffffffc020a602:	020a8c13          	addi	s8,s5,32
ffffffffc020a606:	8562                	mv	a0,s8
ffffffffc020a608:	f5df90ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc020a60c:	000ab783          	ld	a5,0(s5)
ffffffffc020a610:	0087aa03          	lw	s4,8(a5)
ffffffffc020a614:	07405663          	blez	s4,ffffffffc020a680 <sfs_getdirentry+0xde>
ffffffffc020a618:	4481                	li	s1,0
ffffffffc020a61a:	a811                	j	ffffffffc020a62e <sfs_getdirentry+0x8c>
ffffffffc020a61c:	00092783          	lw	a5,0(s2)
ffffffffc020a620:	c781                	beqz	a5,ffffffffc020a628 <sfs_getdirentry+0x86>
ffffffffc020a622:	02098263          	beqz	s3,ffffffffc020a646 <sfs_getdirentry+0xa4>
ffffffffc020a626:	39fd                	addiw	s3,s3,-1
ffffffffc020a628:	2485                	addiw	s1,s1,1
ffffffffc020a62a:	049a0b63          	beq	s4,s1,ffffffffc020a680 <sfs_getdirentry+0xde>
ffffffffc020a62e:	86ca                	mv	a3,s2
ffffffffc020a630:	8626                	mv	a2,s1
ffffffffc020a632:	85d6                	mv	a1,s5
ffffffffc020a634:	855e                	mv	a0,s7
ffffffffc020a636:	eadff0ef          	jal	ra,ffffffffc020a4e2 <sfs_dirent_read_nolock>
ffffffffc020a63a:	842a                	mv	s0,a0
ffffffffc020a63c:	d165                	beqz	a0,ffffffffc020a61c <sfs_getdirentry+0x7a>
ffffffffc020a63e:	8562                	mv	a0,s8
ffffffffc020a640:	f21f90ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc020a644:	a831                	j	ffffffffc020a660 <sfs_getdirentry+0xbe>
ffffffffc020a646:	8562                	mv	a0,s8
ffffffffc020a648:	f19f90ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc020a64c:	4701                	li	a4,0
ffffffffc020a64e:	4685                	li	a3,1
ffffffffc020a650:	10000613          	li	a2,256
ffffffffc020a654:	00490593          	addi	a1,s2,4
ffffffffc020a658:	855a                	mv	a0,s6
ffffffffc020a65a:	d93fa0ef          	jal	ra,ffffffffc02053ec <iobuf_move>
ffffffffc020a65e:	842a                	mv	s0,a0
ffffffffc020a660:	854a                	mv	a0,s2
ffffffffc020a662:	9ddf70ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020a666:	60a6                	ld	ra,72(sp)
ffffffffc020a668:	8522                	mv	a0,s0
ffffffffc020a66a:	6406                	ld	s0,64(sp)
ffffffffc020a66c:	74e2                	ld	s1,56(sp)
ffffffffc020a66e:	7942                	ld	s2,48(sp)
ffffffffc020a670:	79a2                	ld	s3,40(sp)
ffffffffc020a672:	7a02                	ld	s4,32(sp)
ffffffffc020a674:	6ae2                	ld	s5,24(sp)
ffffffffc020a676:	6b42                	ld	s6,16(sp)
ffffffffc020a678:	6ba2                	ld	s7,8(sp)
ffffffffc020a67a:	6c02                	ld	s8,0(sp)
ffffffffc020a67c:	6161                	addi	sp,sp,80
ffffffffc020a67e:	8082                	ret
ffffffffc020a680:	8562                	mv	a0,s8
ffffffffc020a682:	5441                	li	s0,-16
ffffffffc020a684:	eddf90ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc020a688:	bfe1                	j	ffffffffc020a660 <sfs_getdirentry+0xbe>
ffffffffc020a68a:	854a                	mv	a0,s2
ffffffffc020a68c:	9b3f70ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020a690:	5475                	li	s0,-3
ffffffffc020a692:	bfd1                	j	ffffffffc020a666 <sfs_getdirentry+0xc4>
ffffffffc020a694:	9abf70ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020a698:	5441                	li	s0,-16
ffffffffc020a69a:	b7f1                	j	ffffffffc020a666 <sfs_getdirentry+0xc4>
ffffffffc020a69c:	5471                	li	s0,-4
ffffffffc020a69e:	b7e1                	j	ffffffffc020a666 <sfs_getdirentry+0xc4>
ffffffffc020a6a0:	00005697          	auipc	a3,0x5
ffffffffc020a6a4:	c1868693          	addi	a3,a3,-1000 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc020a6a8:	00002617          	auipc	a2,0x2
ffffffffc020a6ac:	84060613          	addi	a2,a2,-1984 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a6b0:	35100593          	li	a1,849
ffffffffc020a6b4:	00005517          	auipc	a0,0x5
ffffffffc020a6b8:	de450513          	addi	a0,a0,-540 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a6bc:	de3f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020a6c0:	00005697          	auipc	a3,0x5
ffffffffc020a6c4:	da068693          	addi	a3,a3,-608 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc020a6c8:	00002617          	auipc	a2,0x2
ffffffffc020a6cc:	82060613          	addi	a2,a2,-2016 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a6d0:	35200593          	li	a1,850
ffffffffc020a6d4:	00005517          	auipc	a0,0x5
ffffffffc020a6d8:	dc450513          	addi	a0,a0,-572 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a6dc:	dc3f50ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020a6e0 <sfs_dirent_search_nolock>:
ffffffffc020a6e0:	711d                	addi	sp,sp,-96
ffffffffc020a6e2:	fc4e                	sd	s3,56(sp)
ffffffffc020a6e4:	89aa                	mv	s3,a0
ffffffffc020a6e6:	8532                	mv	a0,a2
ffffffffc020a6e8:	e0ca                	sd	s2,64(sp)
ffffffffc020a6ea:	f852                	sd	s4,48(sp)
ffffffffc020a6ec:	f05a                	sd	s6,32(sp)
ffffffffc020a6ee:	e862                	sd	s8,16(sp)
ffffffffc020a6f0:	e466                	sd	s9,8(sp)
ffffffffc020a6f2:	8a3e                	mv	s4,a5
ffffffffc020a6f4:	ec86                	sd	ra,88(sp)
ffffffffc020a6f6:	e8a2                	sd	s0,80(sp)
ffffffffc020a6f8:	e4a6                	sd	s1,72(sp)
ffffffffc020a6fa:	f456                	sd	s5,40(sp)
ffffffffc020a6fc:	ec5e                	sd	s7,24(sp)
ffffffffc020a6fe:	e06a                	sd	s10,0(sp)
ffffffffc020a700:	8b32                	mv	s6,a2
ffffffffc020a702:	892e                	mv	s2,a1
ffffffffc020a704:	8cb6                	mv	s9,a3
ffffffffc020a706:	8c3a                	mv	s8,a4
ffffffffc020a708:	232010ef          	jal	ra,ffffffffc020b93a <strlen>
ffffffffc020a70c:	0ff00793          	li	a5,255
ffffffffc020a710:	08a7ec63          	bltu	a5,a0,ffffffffc020a7a8 <sfs_dirent_search_nolock+0xc8>
ffffffffc020a714:	10400513          	li	a0,260
ffffffffc020a718:	877f70ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc020a71c:	8d2a                	mv	s10,a0
ffffffffc020a71e:	c159                	beqz	a0,ffffffffc020a7a4 <sfs_dirent_search_nolock+0xc4>
ffffffffc020a720:	00093783          	ld	a5,0(s2)
ffffffffc020a724:	0087aa83          	lw	s5,8(a5)
ffffffffc020a728:	000a0463          	beqz	s4,ffffffffc020a730 <sfs_dirent_search_nolock+0x50>
ffffffffc020a72c:	015a2023          	sw	s5,0(s4)
ffffffffc020a730:	07505863          	blez	s5,ffffffffc020a7a0 <sfs_dirent_search_nolock+0xc0>
ffffffffc020a734:	4481                	li	s1,0
ffffffffc020a736:	004d0b93          	addi	s7,s10,4
ffffffffc020a73a:	a801                	j	ffffffffc020a74a <sfs_dirent_search_nolock+0x6a>
ffffffffc020a73c:	000a0463          	beqz	s4,ffffffffc020a744 <sfs_dirent_search_nolock+0x64>
ffffffffc020a740:	009a2023          	sw	s1,0(s4)
ffffffffc020a744:	2485                	addiw	s1,s1,1
ffffffffc020a746:	049a8d63          	beq	s5,s1,ffffffffc020a7a0 <sfs_dirent_search_nolock+0xc0>
ffffffffc020a74a:	86ea                	mv	a3,s10
ffffffffc020a74c:	8626                	mv	a2,s1
ffffffffc020a74e:	85ca                	mv	a1,s2
ffffffffc020a750:	854e                	mv	a0,s3
ffffffffc020a752:	d91ff0ef          	jal	ra,ffffffffc020a4e2 <sfs_dirent_read_nolock>
ffffffffc020a756:	842a                	mv	s0,a0
ffffffffc020a758:	e115                	bnez	a0,ffffffffc020a77c <sfs_dirent_search_nolock+0x9c>
ffffffffc020a75a:	000d2783          	lw	a5,0(s10)
ffffffffc020a75e:	dff9                	beqz	a5,ffffffffc020a73c <sfs_dirent_search_nolock+0x5c>
ffffffffc020a760:	85de                	mv	a1,s7
ffffffffc020a762:	855a                	mv	a0,s6
ffffffffc020a764:	246010ef          	jal	ra,ffffffffc020b9aa <strcmp>
ffffffffc020a768:	842a                	mv	s0,a0
ffffffffc020a76a:	fd69                	bnez	a0,ffffffffc020a744 <sfs_dirent_search_nolock+0x64>
ffffffffc020a76c:	000c0463          	beqz	s8,ffffffffc020a774 <sfs_dirent_search_nolock+0x94>
ffffffffc020a770:	009c2023          	sw	s1,0(s8)
ffffffffc020a774:	000d2783          	lw	a5,0(s10)
ffffffffc020a778:	00fca023          	sw	a5,0(s9)
ffffffffc020a77c:	856a                	mv	a0,s10
ffffffffc020a77e:	8c1f70ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020a782:	60e6                	ld	ra,88(sp)
ffffffffc020a784:	8522                	mv	a0,s0
ffffffffc020a786:	6446                	ld	s0,80(sp)
ffffffffc020a788:	64a6                	ld	s1,72(sp)
ffffffffc020a78a:	6906                	ld	s2,64(sp)
ffffffffc020a78c:	79e2                	ld	s3,56(sp)
ffffffffc020a78e:	7a42                	ld	s4,48(sp)
ffffffffc020a790:	7aa2                	ld	s5,40(sp)
ffffffffc020a792:	7b02                	ld	s6,32(sp)
ffffffffc020a794:	6be2                	ld	s7,24(sp)
ffffffffc020a796:	6c42                	ld	s8,16(sp)
ffffffffc020a798:	6ca2                	ld	s9,8(sp)
ffffffffc020a79a:	6d02                	ld	s10,0(sp)
ffffffffc020a79c:	6125                	addi	sp,sp,96
ffffffffc020a79e:	8082                	ret
ffffffffc020a7a0:	5441                	li	s0,-16
ffffffffc020a7a2:	bfe9                	j	ffffffffc020a77c <sfs_dirent_search_nolock+0x9c>
ffffffffc020a7a4:	5471                	li	s0,-4
ffffffffc020a7a6:	bff1                	j	ffffffffc020a782 <sfs_dirent_search_nolock+0xa2>
ffffffffc020a7a8:	00005697          	auipc	a3,0x5
ffffffffc020a7ac:	ed068693          	addi	a3,a3,-304 # ffffffffc020f678 <dev_node_ops+0x7d8>
ffffffffc020a7b0:	00001617          	auipc	a2,0x1
ffffffffc020a7b4:	73860613          	addi	a2,a2,1848 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a7b8:	1ba00593          	li	a1,442
ffffffffc020a7bc:	00005517          	auipc	a0,0x5
ffffffffc020a7c0:	cdc50513          	addi	a0,a0,-804 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a7c4:	cdbf50ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020a7c8 <sfs_link>:
ffffffffc020a7c8:	715d                	addi	sp,sp,-80
ffffffffc020a7ca:	f44e                	sd	s3,40(sp)
ffffffffc020a7cc:	06853983          	ld	s3,104(a0)
ffffffffc020a7d0:	e486                	sd	ra,72(sp)
ffffffffc020a7d2:	e0a2                	sd	s0,64(sp)
ffffffffc020a7d4:	fc26                	sd	s1,56(sp)
ffffffffc020a7d6:	f84a                	sd	s2,48(sp)
ffffffffc020a7d8:	f052                	sd	s4,32(sp)
ffffffffc020a7da:	ec56                	sd	s5,24(sp)
ffffffffc020a7dc:	e85a                	sd	s6,16(sp)
ffffffffc020a7de:	0e098863          	beqz	s3,ffffffffc020a8ce <sfs_link+0x106>
ffffffffc020a7e2:	0b09a783          	lw	a5,176(s3)
ffffffffc020a7e6:	0e079463          	bnez	a5,ffffffffc020a8ce <sfs_link+0x106>
ffffffffc020a7ea:	4d38                	lw	a4,88(a0)
ffffffffc020a7ec:	6785                	lui	a5,0x1
ffffffffc020a7ee:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a7f2:	8a2a                	mv	s4,a0
ffffffffc020a7f4:	10f71d63          	bne	a4,a5,ffffffffc020a90e <sfs_link+0x146>
ffffffffc020a7f8:	84b2                	mv	s1,a2
ffffffffc020a7fa:	0e060a63          	beqz	a2,ffffffffc020a8ee <sfs_link+0x126>
ffffffffc020a7fe:	4e3c                	lw	a5,88(a2)
ffffffffc020a800:	0ee79763          	bne	a5,a4,ffffffffc020a8ee <sfs_link+0x126>
ffffffffc020a804:	763c                	ld	a5,104(a2)
ffffffffc020a806:	0b379e63          	bne	a5,s3,ffffffffc020a8c2 <sfs_link+0xfa>
ffffffffc020a80a:	6218                	ld	a4,0(a2)
ffffffffc020a80c:	4789                	li	a5,2
ffffffffc020a80e:	00475703          	lhu	a4,4(a4)
ffffffffc020a812:	0af70a63          	beq	a4,a5,ffffffffc020a8c6 <sfs_link+0xfe>
ffffffffc020a816:	854e                	mv	a0,s3
ffffffffc020a818:	8aae                	mv	s5,a1
ffffffffc020a81a:	46f000ef          	jal	ra,ffffffffc020b488 <lock_sfs_fs>
ffffffffc020a81e:	005c                	addi	a5,sp,4
ffffffffc020a820:	870a                	mv	a4,sp
ffffffffc020a822:	0034                	addi	a3,sp,8
ffffffffc020a824:	8656                	mv	a2,s5
ffffffffc020a826:	85d2                	mv	a1,s4
ffffffffc020a828:	854e                	mv	a0,s3
ffffffffc020a82a:	0084ab03          	lw	s6,8(s1)
ffffffffc020a82e:	eb3ff0ef          	jal	ra,ffffffffc020a6e0 <sfs_dirent_search_nolock>
ffffffffc020a832:	842a                	mv	s0,a0
ffffffffc020a834:	c959                	beqz	a0,ffffffffc020a8ca <sfs_link+0x102>
ffffffffc020a836:	57c1                	li	a5,-16
ffffffffc020a838:	02f50063          	beq	a0,a5,ffffffffc020a858 <sfs_link+0x90>
ffffffffc020a83c:	854e                	mv	a0,s3
ffffffffc020a83e:	45b000ef          	jal	ra,ffffffffc020b498 <unlock_sfs_fs>
ffffffffc020a842:	60a6                	ld	ra,72(sp)
ffffffffc020a844:	8522                	mv	a0,s0
ffffffffc020a846:	6406                	ld	s0,64(sp)
ffffffffc020a848:	74e2                	ld	s1,56(sp)
ffffffffc020a84a:	7942                	ld	s2,48(sp)
ffffffffc020a84c:	79a2                	ld	s3,40(sp)
ffffffffc020a84e:	7a02                	ld	s4,32(sp)
ffffffffc020a850:	6ae2                	ld	s5,24(sp)
ffffffffc020a852:	6b42                	ld	s6,16(sp)
ffffffffc020a854:	6161                	addi	sp,sp,80
ffffffffc020a856:	8082                	ret
ffffffffc020a858:	10400513          	li	a0,260
ffffffffc020a85c:	f32f70ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc020a860:	892a                	mv	s2,a0
ffffffffc020a862:	5471                	li	s0,-4
ffffffffc020a864:	dd61                	beqz	a0,ffffffffc020a83c <sfs_link+0x74>
ffffffffc020a866:	10400613          	li	a2,260
ffffffffc020a86a:	4581                	li	a1,0
ffffffffc020a86c:	198010ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc020a870:	85d6                	mv	a1,s5
ffffffffc020a872:	00490513          	addi	a0,s2,4
ffffffffc020a876:	0fa010ef          	jal	ra,ffffffffc020b970 <strcpy>
ffffffffc020a87a:	4612                	lw	a2,4(sp)
ffffffffc020a87c:	0074                	addi	a3,sp,12
ffffffffc020a87e:	01692023          	sw	s6,0(s2)
ffffffffc020a882:	85d2                	mv	a1,s4
ffffffffc020a884:	854e                	mv	a0,s3
ffffffffc020a886:	f0cff0ef          	jal	ra,ffffffffc0209f92 <sfs_bmap_load_nolock>
ffffffffc020a88a:	842a                	mv	s0,a0
ffffffffc020a88c:	e51d                	bnez	a0,ffffffffc020a8ba <sfs_link+0xf2>
ffffffffc020a88e:	46b2                	lw	a3,12(sp)
ffffffffc020a890:	4701                	li	a4,0
ffffffffc020a892:	10400613          	li	a2,260
ffffffffc020a896:	85ca                	mv	a1,s2
ffffffffc020a898:	854e                	mv	a0,s3
ffffffffc020a89a:	23f000ef          	jal	ra,ffffffffc020b2d8 <sfs_wbuf>
ffffffffc020a89e:	842a                	mv	s0,a0
ffffffffc020a8a0:	854a                	mv	a0,s2
ffffffffc020a8a2:	f9cf70ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020a8a6:	f859                	bnez	s0,ffffffffc020a83c <sfs_link+0x74>
ffffffffc020a8a8:	6098                	ld	a4,0(s1)
ffffffffc020a8aa:	00675783          	lhu	a5,6(a4)
ffffffffc020a8ae:	2785                	addiw	a5,a5,1
ffffffffc020a8b0:	00f71323          	sh	a5,6(a4)
ffffffffc020a8b4:	4785                	li	a5,1
ffffffffc020a8b6:	e89c                	sd	a5,16(s1)
ffffffffc020a8b8:	b751                	j	ffffffffc020a83c <sfs_link+0x74>
ffffffffc020a8ba:	854a                	mv	a0,s2
ffffffffc020a8bc:	f82f70ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020a8c0:	bfb5                	j	ffffffffc020a83c <sfs_link+0x74>
ffffffffc020a8c2:	5435                	li	s0,-19
ffffffffc020a8c4:	bfbd                	j	ffffffffc020a842 <sfs_link+0x7a>
ffffffffc020a8c6:	543d                	li	s0,-17
ffffffffc020a8c8:	bfad                	j	ffffffffc020a842 <sfs_link+0x7a>
ffffffffc020a8ca:	5425                	li	s0,-23
ffffffffc020a8cc:	bf85                	j	ffffffffc020a83c <sfs_link+0x74>
ffffffffc020a8ce:	00005697          	auipc	a3,0x5
ffffffffc020a8d2:	9ea68693          	addi	a3,a3,-1558 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc020a8d6:	00001617          	auipc	a2,0x1
ffffffffc020a8da:	61260613          	addi	a2,a2,1554 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a8de:	43500593          	li	a1,1077
ffffffffc020a8e2:	00005517          	auipc	a0,0x5
ffffffffc020a8e6:	bb650513          	addi	a0,a0,-1098 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a8ea:	bb5f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020a8ee:	00005697          	auipc	a3,0x5
ffffffffc020a8f2:	b7268693          	addi	a3,a3,-1166 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc020a8f6:	00001617          	auipc	a2,0x1
ffffffffc020a8fa:	5f260613          	addi	a2,a2,1522 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a8fe:	43700593          	li	a1,1079
ffffffffc020a902:	00005517          	auipc	a0,0x5
ffffffffc020a906:	b9650513          	addi	a0,a0,-1130 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a90a:	b95f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020a90e:	00005697          	auipc	a3,0x5
ffffffffc020a912:	b5268693          	addi	a3,a3,-1198 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc020a916:	00001617          	auipc	a2,0x1
ffffffffc020a91a:	5d260613          	addi	a2,a2,1490 # ffffffffc020bee8 <commands+0x210>
ffffffffc020a91e:	43600593          	li	a1,1078
ffffffffc020a922:	00005517          	auipc	a0,0x5
ffffffffc020a926:	b7650513          	addi	a0,a0,-1162 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020a92a:	b75f50ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020a92e <sfs_truncfile>:
ffffffffc020a92e:	7175                	addi	sp,sp,-144
ffffffffc020a930:	e506                	sd	ra,136(sp)
ffffffffc020a932:	e122                	sd	s0,128(sp)
ffffffffc020a934:	fca6                	sd	s1,120(sp)
ffffffffc020a936:	f8ca                	sd	s2,112(sp)
ffffffffc020a938:	f4ce                	sd	s3,104(sp)
ffffffffc020a93a:	f0d2                	sd	s4,96(sp)
ffffffffc020a93c:	ecd6                	sd	s5,88(sp)
ffffffffc020a93e:	e8da                	sd	s6,80(sp)
ffffffffc020a940:	e4de                	sd	s7,72(sp)
ffffffffc020a942:	e0e2                	sd	s8,64(sp)
ffffffffc020a944:	fc66                	sd	s9,56(sp)
ffffffffc020a946:	f86a                	sd	s10,48(sp)
ffffffffc020a948:	f46e                	sd	s11,40(sp)
ffffffffc020a94a:	080007b7          	lui	a5,0x8000
ffffffffc020a94e:	16b7e463          	bltu	a5,a1,ffffffffc020aab6 <sfs_truncfile+0x188>
ffffffffc020a952:	06853c83          	ld	s9,104(a0)
ffffffffc020a956:	89aa                	mv	s3,a0
ffffffffc020a958:	160c8163          	beqz	s9,ffffffffc020aaba <sfs_truncfile+0x18c>
ffffffffc020a95c:	0b0ca783          	lw	a5,176(s9)
ffffffffc020a960:	14079d63          	bnez	a5,ffffffffc020aaba <sfs_truncfile+0x18c>
ffffffffc020a964:	4d38                	lw	a4,88(a0)
ffffffffc020a966:	6405                	lui	s0,0x1
ffffffffc020a968:	23540793          	addi	a5,s0,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a96c:	16f71763          	bne	a4,a5,ffffffffc020aada <sfs_truncfile+0x1ac>
ffffffffc020a970:	00053a83          	ld	s5,0(a0)
ffffffffc020a974:	147d                	addi	s0,s0,-1
ffffffffc020a976:	942e                	add	s0,s0,a1
ffffffffc020a978:	000ae783          	lwu	a5,0(s5)
ffffffffc020a97c:	8031                	srli	s0,s0,0xc
ffffffffc020a97e:	8a2e                	mv	s4,a1
ffffffffc020a980:	2401                	sext.w	s0,s0
ffffffffc020a982:	02b79763          	bne	a5,a1,ffffffffc020a9b0 <sfs_truncfile+0x82>
ffffffffc020a986:	008aa783          	lw	a5,8(s5)
ffffffffc020a98a:	4901                	li	s2,0
ffffffffc020a98c:	18879763          	bne	a5,s0,ffffffffc020ab1a <sfs_truncfile+0x1ec>
ffffffffc020a990:	60aa                	ld	ra,136(sp)
ffffffffc020a992:	640a                	ld	s0,128(sp)
ffffffffc020a994:	74e6                	ld	s1,120(sp)
ffffffffc020a996:	79a6                	ld	s3,104(sp)
ffffffffc020a998:	7a06                	ld	s4,96(sp)
ffffffffc020a99a:	6ae6                	ld	s5,88(sp)
ffffffffc020a99c:	6b46                	ld	s6,80(sp)
ffffffffc020a99e:	6ba6                	ld	s7,72(sp)
ffffffffc020a9a0:	6c06                	ld	s8,64(sp)
ffffffffc020a9a2:	7ce2                	ld	s9,56(sp)
ffffffffc020a9a4:	7d42                	ld	s10,48(sp)
ffffffffc020a9a6:	7da2                	ld	s11,40(sp)
ffffffffc020a9a8:	854a                	mv	a0,s2
ffffffffc020a9aa:	7946                	ld	s2,112(sp)
ffffffffc020a9ac:	6149                	addi	sp,sp,144
ffffffffc020a9ae:	8082                	ret
ffffffffc020a9b0:	02050b13          	addi	s6,a0,32
ffffffffc020a9b4:	855a                	mv	a0,s6
ffffffffc020a9b6:	baff90ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc020a9ba:	008aa483          	lw	s1,8(s5)
ffffffffc020a9be:	0a84e663          	bltu	s1,s0,ffffffffc020aa6a <sfs_truncfile+0x13c>
ffffffffc020a9c2:	0c947163          	bgeu	s0,s1,ffffffffc020aa84 <sfs_truncfile+0x156>
ffffffffc020a9c6:	4dad                	li	s11,11
ffffffffc020a9c8:	4b85                	li	s7,1
ffffffffc020a9ca:	a09d                	j	ffffffffc020aa30 <sfs_truncfile+0x102>
ffffffffc020a9cc:	ff37091b          	addiw	s2,a4,-13
ffffffffc020a9d0:	0009079b          	sext.w	a5,s2
ffffffffc020a9d4:	3ff00713          	li	a4,1023
ffffffffc020a9d8:	04f76563          	bltu	a4,a5,ffffffffc020aa22 <sfs_truncfile+0xf4>
ffffffffc020a9dc:	03cd2c03          	lw	s8,60(s10)
ffffffffc020a9e0:	040c0163          	beqz	s8,ffffffffc020aa22 <sfs_truncfile+0xf4>
ffffffffc020a9e4:	004ca783          	lw	a5,4(s9)
ffffffffc020a9e8:	18fc7963          	bgeu	s8,a5,ffffffffc020ab7a <sfs_truncfile+0x24c>
ffffffffc020a9ec:	038cb503          	ld	a0,56(s9)
ffffffffc020a9f0:	85e2                	mv	a1,s8
ffffffffc020a9f2:	8affe0ef          	jal	ra,ffffffffc02092a0 <bitmap_test>
ffffffffc020a9f6:	16051263          	bnez	a0,ffffffffc020ab5a <sfs_truncfile+0x22c>
ffffffffc020a9fa:	02091793          	slli	a5,s2,0x20
ffffffffc020a9fe:	01e7d713          	srli	a4,a5,0x1e
ffffffffc020aa02:	86e2                	mv	a3,s8
ffffffffc020aa04:	4611                	li	a2,4
ffffffffc020aa06:	082c                	addi	a1,sp,24
ffffffffc020aa08:	8566                	mv	a0,s9
ffffffffc020aa0a:	e43a                	sd	a4,8(sp)
ffffffffc020aa0c:	ce02                	sw	zero,28(sp)
ffffffffc020aa0e:	04b000ef          	jal	ra,ffffffffc020b258 <sfs_rbuf>
ffffffffc020aa12:	892a                	mv	s2,a0
ffffffffc020aa14:	e141                	bnez	a0,ffffffffc020aa94 <sfs_truncfile+0x166>
ffffffffc020aa16:	47e2                	lw	a5,24(sp)
ffffffffc020aa18:	6722                	ld	a4,8(sp)
ffffffffc020aa1a:	e3c9                	bnez	a5,ffffffffc020aa9c <sfs_truncfile+0x16e>
ffffffffc020aa1c:	008d2603          	lw	a2,8(s10)
ffffffffc020aa20:	367d                	addiw	a2,a2,-1
ffffffffc020aa22:	00cd2423          	sw	a2,8(s10)
ffffffffc020aa26:	0179b823          	sd	s7,16(s3)
ffffffffc020aa2a:	34fd                	addiw	s1,s1,-1
ffffffffc020aa2c:	04940a63          	beq	s0,s1,ffffffffc020aa80 <sfs_truncfile+0x152>
ffffffffc020aa30:	0009bd03          	ld	s10,0(s3)
ffffffffc020aa34:	008d2703          	lw	a4,8(s10)
ffffffffc020aa38:	c369                	beqz	a4,ffffffffc020aafa <sfs_truncfile+0x1cc>
ffffffffc020aa3a:	fff7079b          	addiw	a5,a4,-1
ffffffffc020aa3e:	0007861b          	sext.w	a2,a5
ffffffffc020aa42:	f8cde5e3          	bltu	s11,a2,ffffffffc020a9cc <sfs_truncfile+0x9e>
ffffffffc020aa46:	02079713          	slli	a4,a5,0x20
ffffffffc020aa4a:	01e75793          	srli	a5,a4,0x1e
ffffffffc020aa4e:	00fd0933          	add	s2,s10,a5
ffffffffc020aa52:	00c92583          	lw	a1,12(s2)
ffffffffc020aa56:	d5f1                	beqz	a1,ffffffffc020aa22 <sfs_truncfile+0xf4>
ffffffffc020aa58:	8566                	mv	a0,s9
ffffffffc020aa5a:	a7eff0ef          	jal	ra,ffffffffc0209cd8 <sfs_block_free>
ffffffffc020aa5e:	00092623          	sw	zero,12(s2)
ffffffffc020aa62:	008d2603          	lw	a2,8(s10)
ffffffffc020aa66:	367d                	addiw	a2,a2,-1
ffffffffc020aa68:	bf6d                	j	ffffffffc020aa22 <sfs_truncfile+0xf4>
ffffffffc020aa6a:	4681                	li	a3,0
ffffffffc020aa6c:	8626                	mv	a2,s1
ffffffffc020aa6e:	85ce                	mv	a1,s3
ffffffffc020aa70:	8566                	mv	a0,s9
ffffffffc020aa72:	d20ff0ef          	jal	ra,ffffffffc0209f92 <sfs_bmap_load_nolock>
ffffffffc020aa76:	892a                	mv	s2,a0
ffffffffc020aa78:	ed11                	bnez	a0,ffffffffc020aa94 <sfs_truncfile+0x166>
ffffffffc020aa7a:	2485                	addiw	s1,s1,1
ffffffffc020aa7c:	fe9417e3          	bne	s0,s1,ffffffffc020aa6a <sfs_truncfile+0x13c>
ffffffffc020aa80:	008aa483          	lw	s1,8(s5)
ffffffffc020aa84:	0a941b63          	bne	s0,s1,ffffffffc020ab3a <sfs_truncfile+0x20c>
ffffffffc020aa88:	014aa023          	sw	s4,0(s5)
ffffffffc020aa8c:	4785                	li	a5,1
ffffffffc020aa8e:	00f9b823          	sd	a5,16(s3)
ffffffffc020aa92:	4901                	li	s2,0
ffffffffc020aa94:	855a                	mv	a0,s6
ffffffffc020aa96:	acbf90ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc020aa9a:	bddd                	j	ffffffffc020a990 <sfs_truncfile+0x62>
ffffffffc020aa9c:	86e2                	mv	a3,s8
ffffffffc020aa9e:	4611                	li	a2,4
ffffffffc020aaa0:	086c                	addi	a1,sp,28
ffffffffc020aaa2:	8566                	mv	a0,s9
ffffffffc020aaa4:	035000ef          	jal	ra,ffffffffc020b2d8 <sfs_wbuf>
ffffffffc020aaa8:	892a                	mv	s2,a0
ffffffffc020aaaa:	f56d                	bnez	a0,ffffffffc020aa94 <sfs_truncfile+0x166>
ffffffffc020aaac:	45e2                	lw	a1,24(sp)
ffffffffc020aaae:	8566                	mv	a0,s9
ffffffffc020aab0:	a28ff0ef          	jal	ra,ffffffffc0209cd8 <sfs_block_free>
ffffffffc020aab4:	b7a5                	j	ffffffffc020aa1c <sfs_truncfile+0xee>
ffffffffc020aab6:	5975                	li	s2,-3
ffffffffc020aab8:	bde1                	j	ffffffffc020a990 <sfs_truncfile+0x62>
ffffffffc020aaba:	00004697          	auipc	a3,0x4
ffffffffc020aabe:	7fe68693          	addi	a3,a3,2046 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc020aac2:	00001617          	auipc	a2,0x1
ffffffffc020aac6:	42660613          	addi	a2,a2,1062 # ffffffffc020bee8 <commands+0x210>
ffffffffc020aaca:	3c000593          	li	a1,960
ffffffffc020aace:	00005517          	auipc	a0,0x5
ffffffffc020aad2:	9ca50513          	addi	a0,a0,-1590 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020aad6:	9c9f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020aada:	00005697          	auipc	a3,0x5
ffffffffc020aade:	98668693          	addi	a3,a3,-1658 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc020aae2:	00001617          	auipc	a2,0x1
ffffffffc020aae6:	40660613          	addi	a2,a2,1030 # ffffffffc020bee8 <commands+0x210>
ffffffffc020aaea:	3c100593          	li	a1,961
ffffffffc020aaee:	00005517          	auipc	a0,0x5
ffffffffc020aaf2:	9aa50513          	addi	a0,a0,-1622 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020aaf6:	9a9f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020aafa:	00005697          	auipc	a3,0x5
ffffffffc020aafe:	bbe68693          	addi	a3,a3,-1090 # ffffffffc020f6b8 <dev_node_ops+0x818>
ffffffffc020ab02:	00001617          	auipc	a2,0x1
ffffffffc020ab06:	3e660613          	addi	a2,a2,998 # ffffffffc020bee8 <commands+0x210>
ffffffffc020ab0a:	17b00593          	li	a1,379
ffffffffc020ab0e:	00005517          	auipc	a0,0x5
ffffffffc020ab12:	98a50513          	addi	a0,a0,-1654 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020ab16:	989f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020ab1a:	00005697          	auipc	a3,0x5
ffffffffc020ab1e:	b8668693          	addi	a3,a3,-1146 # ffffffffc020f6a0 <dev_node_ops+0x800>
ffffffffc020ab22:	00001617          	auipc	a2,0x1
ffffffffc020ab26:	3c660613          	addi	a2,a2,966 # ffffffffc020bee8 <commands+0x210>
ffffffffc020ab2a:	3c800593          	li	a1,968
ffffffffc020ab2e:	00005517          	auipc	a0,0x5
ffffffffc020ab32:	96a50513          	addi	a0,a0,-1686 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020ab36:	969f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020ab3a:	00005697          	auipc	a3,0x5
ffffffffc020ab3e:	bce68693          	addi	a3,a3,-1074 # ffffffffc020f708 <dev_node_ops+0x868>
ffffffffc020ab42:	00001617          	auipc	a2,0x1
ffffffffc020ab46:	3a660613          	addi	a2,a2,934 # ffffffffc020bee8 <commands+0x210>
ffffffffc020ab4a:	3e100593          	li	a1,993
ffffffffc020ab4e:	00005517          	auipc	a0,0x5
ffffffffc020ab52:	94a50513          	addi	a0,a0,-1718 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020ab56:	949f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020ab5a:	00005697          	auipc	a3,0x5
ffffffffc020ab5e:	b7668693          	addi	a3,a3,-1162 # ffffffffc020f6d0 <dev_node_ops+0x830>
ffffffffc020ab62:	00001617          	auipc	a2,0x1
ffffffffc020ab66:	38660613          	addi	a2,a2,902 # ffffffffc020bee8 <commands+0x210>
ffffffffc020ab6a:	12b00593          	li	a1,299
ffffffffc020ab6e:	00005517          	auipc	a0,0x5
ffffffffc020ab72:	92a50513          	addi	a0,a0,-1750 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020ab76:	929f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020ab7a:	8762                	mv	a4,s8
ffffffffc020ab7c:	86be                	mv	a3,a5
ffffffffc020ab7e:	00005617          	auipc	a2,0x5
ffffffffc020ab82:	94a60613          	addi	a2,a2,-1718 # ffffffffc020f4c8 <dev_node_ops+0x628>
ffffffffc020ab86:	05300593          	li	a1,83
ffffffffc020ab8a:	00005517          	auipc	a0,0x5
ffffffffc020ab8e:	90e50513          	addi	a0,a0,-1778 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020ab92:	90df50ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020ab96 <sfs_load_inode>:
ffffffffc020ab96:	7139                	addi	sp,sp,-64
ffffffffc020ab98:	fc06                	sd	ra,56(sp)
ffffffffc020ab9a:	f822                	sd	s0,48(sp)
ffffffffc020ab9c:	f426                	sd	s1,40(sp)
ffffffffc020ab9e:	f04a                	sd	s2,32(sp)
ffffffffc020aba0:	84b2                	mv	s1,a2
ffffffffc020aba2:	892a                	mv	s2,a0
ffffffffc020aba4:	ec4e                	sd	s3,24(sp)
ffffffffc020aba6:	e852                	sd	s4,16(sp)
ffffffffc020aba8:	89ae                	mv	s3,a1
ffffffffc020abaa:	e456                	sd	s5,8(sp)
ffffffffc020abac:	0dd000ef          	jal	ra,ffffffffc020b488 <lock_sfs_fs>
ffffffffc020abb0:	45a9                	li	a1,10
ffffffffc020abb2:	8526                	mv	a0,s1
ffffffffc020abb4:	0a893403          	ld	s0,168(s2)
ffffffffc020abb8:	0f1000ef          	jal	ra,ffffffffc020b4a8 <hash32>
ffffffffc020abbc:	02051793          	slli	a5,a0,0x20
ffffffffc020abc0:	01c7d713          	srli	a4,a5,0x1c
ffffffffc020abc4:	9722                	add	a4,a4,s0
ffffffffc020abc6:	843a                	mv	s0,a4
ffffffffc020abc8:	a029                	j	ffffffffc020abd2 <sfs_load_inode+0x3c>
ffffffffc020abca:	fc042783          	lw	a5,-64(s0)
ffffffffc020abce:	10978863          	beq	a5,s1,ffffffffc020acde <sfs_load_inode+0x148>
ffffffffc020abd2:	6400                	ld	s0,8(s0)
ffffffffc020abd4:	fe871be3          	bne	a4,s0,ffffffffc020abca <sfs_load_inode+0x34>
ffffffffc020abd8:	04000513          	li	a0,64
ffffffffc020abdc:	bb2f70ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc020abe0:	8aaa                	mv	s5,a0
ffffffffc020abe2:	16050563          	beqz	a0,ffffffffc020ad4c <sfs_load_inode+0x1b6>
ffffffffc020abe6:	00492683          	lw	a3,4(s2)
ffffffffc020abea:	18048363          	beqz	s1,ffffffffc020ad70 <sfs_load_inode+0x1da>
ffffffffc020abee:	18d4f163          	bgeu	s1,a3,ffffffffc020ad70 <sfs_load_inode+0x1da>
ffffffffc020abf2:	03893503          	ld	a0,56(s2)
ffffffffc020abf6:	85a6                	mv	a1,s1
ffffffffc020abf8:	ea8fe0ef          	jal	ra,ffffffffc02092a0 <bitmap_test>
ffffffffc020abfc:	18051763          	bnez	a0,ffffffffc020ad8a <sfs_load_inode+0x1f4>
ffffffffc020ac00:	4701                	li	a4,0
ffffffffc020ac02:	86a6                	mv	a3,s1
ffffffffc020ac04:	04000613          	li	a2,64
ffffffffc020ac08:	85d6                	mv	a1,s5
ffffffffc020ac0a:	854a                	mv	a0,s2
ffffffffc020ac0c:	64c000ef          	jal	ra,ffffffffc020b258 <sfs_rbuf>
ffffffffc020ac10:	842a                	mv	s0,a0
ffffffffc020ac12:	0e051563          	bnez	a0,ffffffffc020acfc <sfs_load_inode+0x166>
ffffffffc020ac16:	006ad783          	lhu	a5,6(s5)
ffffffffc020ac1a:	12078b63          	beqz	a5,ffffffffc020ad50 <sfs_load_inode+0x1ba>
ffffffffc020ac1e:	6405                	lui	s0,0x1
ffffffffc020ac20:	23540513          	addi	a0,s0,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020ac24:	b8bfc0ef          	jal	ra,ffffffffc02077ae <__alloc_inode>
ffffffffc020ac28:	8a2a                	mv	s4,a0
ffffffffc020ac2a:	c961                	beqz	a0,ffffffffc020acfa <sfs_load_inode+0x164>
ffffffffc020ac2c:	004ad683          	lhu	a3,4(s5)
ffffffffc020ac30:	4785                	li	a5,1
ffffffffc020ac32:	0cf69c63          	bne	a3,a5,ffffffffc020ad0a <sfs_load_inode+0x174>
ffffffffc020ac36:	864a                	mv	a2,s2
ffffffffc020ac38:	00005597          	auipc	a1,0x5
ffffffffc020ac3c:	c1858593          	addi	a1,a1,-1000 # ffffffffc020f850 <sfs_node_fileops>
ffffffffc020ac40:	b8bfc0ef          	jal	ra,ffffffffc02077ca <inode_init>
ffffffffc020ac44:	058a2783          	lw	a5,88(s4)
ffffffffc020ac48:	23540413          	addi	s0,s0,565
ffffffffc020ac4c:	0e879063          	bne	a5,s0,ffffffffc020ad2c <sfs_load_inode+0x196>
ffffffffc020ac50:	4785                	li	a5,1
ffffffffc020ac52:	00fa2c23          	sw	a5,24(s4)
ffffffffc020ac56:	015a3023          	sd	s5,0(s4)
ffffffffc020ac5a:	009a2423          	sw	s1,8(s4)
ffffffffc020ac5e:	000a3823          	sd	zero,16(s4)
ffffffffc020ac62:	4585                	li	a1,1
ffffffffc020ac64:	020a0513          	addi	a0,s4,32
ffffffffc020ac68:	8f3f90ef          	jal	ra,ffffffffc020455a <sem_init>
ffffffffc020ac6c:	058a2703          	lw	a4,88(s4)
ffffffffc020ac70:	6785                	lui	a5,0x1
ffffffffc020ac72:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020ac76:	14f71663          	bne	a4,a5,ffffffffc020adc2 <sfs_load_inode+0x22c>
ffffffffc020ac7a:	0a093703          	ld	a4,160(s2)
ffffffffc020ac7e:	038a0793          	addi	a5,s4,56
ffffffffc020ac82:	008a2503          	lw	a0,8(s4)
ffffffffc020ac86:	e31c                	sd	a5,0(a4)
ffffffffc020ac88:	0af93023          	sd	a5,160(s2)
ffffffffc020ac8c:	09890793          	addi	a5,s2,152
ffffffffc020ac90:	0a893403          	ld	s0,168(s2)
ffffffffc020ac94:	45a9                	li	a1,10
ffffffffc020ac96:	04ea3023          	sd	a4,64(s4)
ffffffffc020ac9a:	02fa3c23          	sd	a5,56(s4)
ffffffffc020ac9e:	00b000ef          	jal	ra,ffffffffc020b4a8 <hash32>
ffffffffc020aca2:	02051713          	slli	a4,a0,0x20
ffffffffc020aca6:	01c75793          	srli	a5,a4,0x1c
ffffffffc020acaa:	97a2                	add	a5,a5,s0
ffffffffc020acac:	6798                	ld	a4,8(a5)
ffffffffc020acae:	048a0693          	addi	a3,s4,72
ffffffffc020acb2:	e314                	sd	a3,0(a4)
ffffffffc020acb4:	e794                	sd	a3,8(a5)
ffffffffc020acb6:	04ea3823          	sd	a4,80(s4)
ffffffffc020acba:	04fa3423          	sd	a5,72(s4)
ffffffffc020acbe:	854a                	mv	a0,s2
ffffffffc020acc0:	7d8000ef          	jal	ra,ffffffffc020b498 <unlock_sfs_fs>
ffffffffc020acc4:	4401                	li	s0,0
ffffffffc020acc6:	0149b023          	sd	s4,0(s3)
ffffffffc020acca:	70e2                	ld	ra,56(sp)
ffffffffc020accc:	8522                	mv	a0,s0
ffffffffc020acce:	7442                	ld	s0,48(sp)
ffffffffc020acd0:	74a2                	ld	s1,40(sp)
ffffffffc020acd2:	7902                	ld	s2,32(sp)
ffffffffc020acd4:	69e2                	ld	s3,24(sp)
ffffffffc020acd6:	6a42                	ld	s4,16(sp)
ffffffffc020acd8:	6aa2                	ld	s5,8(sp)
ffffffffc020acda:	6121                	addi	sp,sp,64
ffffffffc020acdc:	8082                	ret
ffffffffc020acde:	fb840a13          	addi	s4,s0,-72
ffffffffc020ace2:	8552                	mv	a0,s4
ffffffffc020ace4:	b49fc0ef          	jal	ra,ffffffffc020782c <inode_ref_inc>
ffffffffc020ace8:	4785                	li	a5,1
ffffffffc020acea:	fcf51ae3          	bne	a0,a5,ffffffffc020acbe <sfs_load_inode+0x128>
ffffffffc020acee:	fd042783          	lw	a5,-48(s0)
ffffffffc020acf2:	2785                	addiw	a5,a5,1
ffffffffc020acf4:	fcf42823          	sw	a5,-48(s0)
ffffffffc020acf8:	b7d9                	j	ffffffffc020acbe <sfs_load_inode+0x128>
ffffffffc020acfa:	5471                	li	s0,-4
ffffffffc020acfc:	8556                	mv	a0,s5
ffffffffc020acfe:	b40f70ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020ad02:	854a                	mv	a0,s2
ffffffffc020ad04:	794000ef          	jal	ra,ffffffffc020b498 <unlock_sfs_fs>
ffffffffc020ad08:	b7c9                	j	ffffffffc020acca <sfs_load_inode+0x134>
ffffffffc020ad0a:	4789                	li	a5,2
ffffffffc020ad0c:	08f69f63          	bne	a3,a5,ffffffffc020adaa <sfs_load_inode+0x214>
ffffffffc020ad10:	864a                	mv	a2,s2
ffffffffc020ad12:	00005597          	auipc	a1,0x5
ffffffffc020ad16:	a8658593          	addi	a1,a1,-1402 # ffffffffc020f798 <sfs_node_dirops>
ffffffffc020ad1a:	ab1fc0ef          	jal	ra,ffffffffc02077ca <inode_init>
ffffffffc020ad1e:	058a2703          	lw	a4,88(s4)
ffffffffc020ad22:	6785                	lui	a5,0x1
ffffffffc020ad24:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020ad28:	f2f704e3          	beq	a4,a5,ffffffffc020ac50 <sfs_load_inode+0xba>
ffffffffc020ad2c:	00004697          	auipc	a3,0x4
ffffffffc020ad30:	73468693          	addi	a3,a3,1844 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc020ad34:	00001617          	auipc	a2,0x1
ffffffffc020ad38:	1b460613          	addi	a2,a2,436 # ffffffffc020bee8 <commands+0x210>
ffffffffc020ad3c:	07700593          	li	a1,119
ffffffffc020ad40:	00004517          	auipc	a0,0x4
ffffffffc020ad44:	75850513          	addi	a0,a0,1880 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020ad48:	f56f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020ad4c:	5471                	li	s0,-4
ffffffffc020ad4e:	bf55                	j	ffffffffc020ad02 <sfs_load_inode+0x16c>
ffffffffc020ad50:	00005697          	auipc	a3,0x5
ffffffffc020ad54:	9d068693          	addi	a3,a3,-1584 # ffffffffc020f720 <dev_node_ops+0x880>
ffffffffc020ad58:	00001617          	auipc	a2,0x1
ffffffffc020ad5c:	19060613          	addi	a2,a2,400 # ffffffffc020bee8 <commands+0x210>
ffffffffc020ad60:	0ad00593          	li	a1,173
ffffffffc020ad64:	00004517          	auipc	a0,0x4
ffffffffc020ad68:	73450513          	addi	a0,a0,1844 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020ad6c:	f32f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020ad70:	8726                	mv	a4,s1
ffffffffc020ad72:	00004617          	auipc	a2,0x4
ffffffffc020ad76:	75660613          	addi	a2,a2,1878 # ffffffffc020f4c8 <dev_node_ops+0x628>
ffffffffc020ad7a:	05300593          	li	a1,83
ffffffffc020ad7e:	00004517          	auipc	a0,0x4
ffffffffc020ad82:	71a50513          	addi	a0,a0,1818 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020ad86:	f18f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020ad8a:	00004697          	auipc	a3,0x4
ffffffffc020ad8e:	77668693          	addi	a3,a3,1910 # ffffffffc020f500 <dev_node_ops+0x660>
ffffffffc020ad92:	00001617          	auipc	a2,0x1
ffffffffc020ad96:	15660613          	addi	a2,a2,342 # ffffffffc020bee8 <commands+0x210>
ffffffffc020ad9a:	0a800593          	li	a1,168
ffffffffc020ad9e:	00004517          	auipc	a0,0x4
ffffffffc020ada2:	6fa50513          	addi	a0,a0,1786 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020ada6:	ef8f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020adaa:	00004617          	auipc	a2,0x4
ffffffffc020adae:	70660613          	addi	a2,a2,1798 # ffffffffc020f4b0 <dev_node_ops+0x610>
ffffffffc020adb2:	02e00593          	li	a1,46
ffffffffc020adb6:	00004517          	auipc	a0,0x4
ffffffffc020adba:	6e250513          	addi	a0,a0,1762 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020adbe:	ee0f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020adc2:	00004697          	auipc	a3,0x4
ffffffffc020adc6:	69e68693          	addi	a3,a3,1694 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc020adca:	00001617          	auipc	a2,0x1
ffffffffc020adce:	11e60613          	addi	a2,a2,286 # ffffffffc020bee8 <commands+0x210>
ffffffffc020add2:	0b100593          	li	a1,177
ffffffffc020add6:	00004517          	auipc	a0,0x4
ffffffffc020adda:	6c250513          	addi	a0,a0,1730 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020adde:	ec0f50ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020ade2 <sfs_lookup>:
ffffffffc020ade2:	7139                	addi	sp,sp,-64
ffffffffc020ade4:	ec4e                	sd	s3,24(sp)
ffffffffc020ade6:	06853983          	ld	s3,104(a0)
ffffffffc020adea:	fc06                	sd	ra,56(sp)
ffffffffc020adec:	f822                	sd	s0,48(sp)
ffffffffc020adee:	f426                	sd	s1,40(sp)
ffffffffc020adf0:	f04a                	sd	s2,32(sp)
ffffffffc020adf2:	e852                	sd	s4,16(sp)
ffffffffc020adf4:	0a098e63          	beqz	s3,ffffffffc020aeb0 <sfs_lookup+0xce>
ffffffffc020adf8:	0b09a783          	lw	a5,176(s3)
ffffffffc020adfc:	ebd5                	bnez	a5,ffffffffc020aeb0 <sfs_lookup+0xce>
ffffffffc020adfe:	0005c783          	lbu	a5,0(a1)
ffffffffc020ae02:	84ae                	mv	s1,a1
ffffffffc020ae04:	c7d1                	beqz	a5,ffffffffc020ae90 <sfs_lookup+0xae>
ffffffffc020ae06:	02f00713          	li	a4,47
ffffffffc020ae0a:	08e78363          	beq	a5,a4,ffffffffc020ae90 <sfs_lookup+0xae>
ffffffffc020ae0e:	842a                	mv	s0,a0
ffffffffc020ae10:	8a32                	mv	s4,a2
ffffffffc020ae12:	a1bfc0ef          	jal	ra,ffffffffc020782c <inode_ref_inc>
ffffffffc020ae16:	4c38                	lw	a4,88(s0)
ffffffffc020ae18:	6785                	lui	a5,0x1
ffffffffc020ae1a:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020ae1e:	0af71963          	bne	a4,a5,ffffffffc020aed0 <sfs_lookup+0xee>
ffffffffc020ae22:	6018                	ld	a4,0(s0)
ffffffffc020ae24:	4789                	li	a5,2
ffffffffc020ae26:	00475703          	lhu	a4,4(a4)
ffffffffc020ae2a:	04f71e63          	bne	a4,a5,ffffffffc020ae86 <sfs_lookup+0xa4>
ffffffffc020ae2e:	02040913          	addi	s2,s0,32
ffffffffc020ae32:	854a                	mv	a0,s2
ffffffffc020ae34:	f30f90ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc020ae38:	8626                	mv	a2,s1
ffffffffc020ae3a:	4781                	li	a5,0
ffffffffc020ae3c:	4701                	li	a4,0
ffffffffc020ae3e:	0054                	addi	a3,sp,4
ffffffffc020ae40:	85a2                	mv	a1,s0
ffffffffc020ae42:	854e                	mv	a0,s3
ffffffffc020ae44:	89dff0ef          	jal	ra,ffffffffc020a6e0 <sfs_dirent_search_nolock>
ffffffffc020ae48:	84aa                	mv	s1,a0
ffffffffc020ae4a:	854a                	mv	a0,s2
ffffffffc020ae4c:	f14f90ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc020ae50:	cc89                	beqz	s1,ffffffffc020ae6a <sfs_lookup+0x88>
ffffffffc020ae52:	8522                	mv	a0,s0
ffffffffc020ae54:	aa7fc0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc020ae58:	70e2                	ld	ra,56(sp)
ffffffffc020ae5a:	7442                	ld	s0,48(sp)
ffffffffc020ae5c:	7902                	ld	s2,32(sp)
ffffffffc020ae5e:	69e2                	ld	s3,24(sp)
ffffffffc020ae60:	6a42                	ld	s4,16(sp)
ffffffffc020ae62:	8526                	mv	a0,s1
ffffffffc020ae64:	74a2                	ld	s1,40(sp)
ffffffffc020ae66:	6121                	addi	sp,sp,64
ffffffffc020ae68:	8082                	ret
ffffffffc020ae6a:	4612                	lw	a2,4(sp)
ffffffffc020ae6c:	002c                	addi	a1,sp,8
ffffffffc020ae6e:	854e                	mv	a0,s3
ffffffffc020ae70:	d27ff0ef          	jal	ra,ffffffffc020ab96 <sfs_load_inode>
ffffffffc020ae74:	84aa                	mv	s1,a0
ffffffffc020ae76:	8522                	mv	a0,s0
ffffffffc020ae78:	a83fc0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc020ae7c:	fcf1                	bnez	s1,ffffffffc020ae58 <sfs_lookup+0x76>
ffffffffc020ae7e:	67a2                	ld	a5,8(sp)
ffffffffc020ae80:	00fa3023          	sd	a5,0(s4)
ffffffffc020ae84:	bfd1                	j	ffffffffc020ae58 <sfs_lookup+0x76>
ffffffffc020ae86:	8522                	mv	a0,s0
ffffffffc020ae88:	a73fc0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc020ae8c:	54b9                	li	s1,-18
ffffffffc020ae8e:	b7e9                	j	ffffffffc020ae58 <sfs_lookup+0x76>
ffffffffc020ae90:	00005697          	auipc	a3,0x5
ffffffffc020ae94:	8a868693          	addi	a3,a3,-1880 # ffffffffc020f738 <dev_node_ops+0x898>
ffffffffc020ae98:	00001617          	auipc	a2,0x1
ffffffffc020ae9c:	05060613          	addi	a2,a2,80 # ffffffffc020bee8 <commands+0x210>
ffffffffc020aea0:	3f200593          	li	a1,1010
ffffffffc020aea4:	00004517          	auipc	a0,0x4
ffffffffc020aea8:	5f450513          	addi	a0,a0,1524 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020aeac:	df2f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020aeb0:	00004697          	auipc	a3,0x4
ffffffffc020aeb4:	40868693          	addi	a3,a3,1032 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc020aeb8:	00001617          	auipc	a2,0x1
ffffffffc020aebc:	03060613          	addi	a2,a2,48 # ffffffffc020bee8 <commands+0x210>
ffffffffc020aec0:	3f100593          	li	a1,1009
ffffffffc020aec4:	00004517          	auipc	a0,0x4
ffffffffc020aec8:	5d450513          	addi	a0,a0,1492 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020aecc:	dd2f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020aed0:	00004697          	auipc	a3,0x4
ffffffffc020aed4:	59068693          	addi	a3,a3,1424 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc020aed8:	00001617          	auipc	a2,0x1
ffffffffc020aedc:	01060613          	addi	a2,a2,16 # ffffffffc020bee8 <commands+0x210>
ffffffffc020aee0:	3f400593          	li	a1,1012
ffffffffc020aee4:	00004517          	auipc	a0,0x4
ffffffffc020aee8:	5b450513          	addi	a0,a0,1460 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020aeec:	db2f50ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020aef0 <sfs_namefile>:
ffffffffc020aef0:	6d98                	ld	a4,24(a1)
ffffffffc020aef2:	7175                	addi	sp,sp,-144
ffffffffc020aef4:	e506                	sd	ra,136(sp)
ffffffffc020aef6:	e122                	sd	s0,128(sp)
ffffffffc020aef8:	fca6                	sd	s1,120(sp)
ffffffffc020aefa:	f8ca                	sd	s2,112(sp)
ffffffffc020aefc:	f4ce                	sd	s3,104(sp)
ffffffffc020aefe:	f0d2                	sd	s4,96(sp)
ffffffffc020af00:	ecd6                	sd	s5,88(sp)
ffffffffc020af02:	e8da                	sd	s6,80(sp)
ffffffffc020af04:	e4de                	sd	s7,72(sp)
ffffffffc020af06:	e0e2                	sd	s8,64(sp)
ffffffffc020af08:	fc66                	sd	s9,56(sp)
ffffffffc020af0a:	f86a                	sd	s10,48(sp)
ffffffffc020af0c:	f46e                	sd	s11,40(sp)
ffffffffc020af0e:	e42e                	sd	a1,8(sp)
ffffffffc020af10:	4789                	li	a5,2
ffffffffc020af12:	1ae7f563          	bgeu	a5,a4,ffffffffc020b0bc <sfs_namefile+0x1cc>
ffffffffc020af16:	89aa                	mv	s3,a0
ffffffffc020af18:	10400513          	li	a0,260
ffffffffc020af1c:	872f70ef          	jal	ra,ffffffffc0201f8e <kmalloc>
ffffffffc020af20:	842a                	mv	s0,a0
ffffffffc020af22:	18050d63          	beqz	a0,ffffffffc020b0bc <sfs_namefile+0x1cc>
ffffffffc020af26:	0689b483          	ld	s1,104(s3)
ffffffffc020af2a:	1e048b63          	beqz	s1,ffffffffc020b120 <sfs_namefile+0x230>
ffffffffc020af2e:	0b04a783          	lw	a5,176(s1)
ffffffffc020af32:	1e079763          	bnez	a5,ffffffffc020b120 <sfs_namefile+0x230>
ffffffffc020af36:	0589ac83          	lw	s9,88(s3)
ffffffffc020af3a:	6785                	lui	a5,0x1
ffffffffc020af3c:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020af40:	1cfc9063          	bne	s9,a5,ffffffffc020b100 <sfs_namefile+0x210>
ffffffffc020af44:	6722                	ld	a4,8(sp)
ffffffffc020af46:	854e                	mv	a0,s3
ffffffffc020af48:	8ace                	mv	s5,s3
ffffffffc020af4a:	6f1c                	ld	a5,24(a4)
ffffffffc020af4c:	00073b03          	ld	s6,0(a4)
ffffffffc020af50:	02098a13          	addi	s4,s3,32
ffffffffc020af54:	ffe78b93          	addi	s7,a5,-2
ffffffffc020af58:	9b3e                	add	s6,s6,a5
ffffffffc020af5a:	00004d17          	auipc	s10,0x4
ffffffffc020af5e:	7fed0d13          	addi	s10,s10,2046 # ffffffffc020f758 <dev_node_ops+0x8b8>
ffffffffc020af62:	8cbfc0ef          	jal	ra,ffffffffc020782c <inode_ref_inc>
ffffffffc020af66:	00440c13          	addi	s8,s0,4
ffffffffc020af6a:	e066                	sd	s9,0(sp)
ffffffffc020af6c:	8552                	mv	a0,s4
ffffffffc020af6e:	df6f90ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc020af72:	4781                	li	a5,0
ffffffffc020af74:	4701                	li	a4,0
ffffffffc020af76:	0854                	addi	a3,sp,20
ffffffffc020af78:	866a                	mv	a2,s10
ffffffffc020af7a:	85d6                	mv	a1,s5
ffffffffc020af7c:	8526                	mv	a0,s1
ffffffffc020af7e:	f62ff0ef          	jal	ra,ffffffffc020a6e0 <sfs_dirent_search_nolock>
ffffffffc020af82:	8daa                	mv	s11,a0
ffffffffc020af84:	8552                	mv	a0,s4
ffffffffc020af86:	ddaf90ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc020af8a:	020d8863          	beqz	s11,ffffffffc020afba <sfs_namefile+0xca>
ffffffffc020af8e:	854e                	mv	a0,s3
ffffffffc020af90:	96bfc0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc020af94:	8522                	mv	a0,s0
ffffffffc020af96:	8a8f70ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020af9a:	60aa                	ld	ra,136(sp)
ffffffffc020af9c:	640a                	ld	s0,128(sp)
ffffffffc020af9e:	74e6                	ld	s1,120(sp)
ffffffffc020afa0:	7946                	ld	s2,112(sp)
ffffffffc020afa2:	79a6                	ld	s3,104(sp)
ffffffffc020afa4:	7a06                	ld	s4,96(sp)
ffffffffc020afa6:	6ae6                	ld	s5,88(sp)
ffffffffc020afa8:	6b46                	ld	s6,80(sp)
ffffffffc020afaa:	6ba6                	ld	s7,72(sp)
ffffffffc020afac:	6c06                	ld	s8,64(sp)
ffffffffc020afae:	7ce2                	ld	s9,56(sp)
ffffffffc020afb0:	7d42                	ld	s10,48(sp)
ffffffffc020afb2:	856e                	mv	a0,s11
ffffffffc020afb4:	7da2                	ld	s11,40(sp)
ffffffffc020afb6:	6149                	addi	sp,sp,144
ffffffffc020afb8:	8082                	ret
ffffffffc020afba:	4652                	lw	a2,20(sp)
ffffffffc020afbc:	082c                	addi	a1,sp,24
ffffffffc020afbe:	8526                	mv	a0,s1
ffffffffc020afc0:	bd7ff0ef          	jal	ra,ffffffffc020ab96 <sfs_load_inode>
ffffffffc020afc4:	8daa                	mv	s11,a0
ffffffffc020afc6:	f561                	bnez	a0,ffffffffc020af8e <sfs_namefile+0x9e>
ffffffffc020afc8:	854e                	mv	a0,s3
ffffffffc020afca:	008aa903          	lw	s2,8(s5)
ffffffffc020afce:	92dfc0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc020afd2:	6ce2                	ld	s9,24(sp)
ffffffffc020afd4:	0b3c8463          	beq	s9,s3,ffffffffc020b07c <sfs_namefile+0x18c>
ffffffffc020afd8:	100c8463          	beqz	s9,ffffffffc020b0e0 <sfs_namefile+0x1f0>
ffffffffc020afdc:	058ca703          	lw	a4,88(s9)
ffffffffc020afe0:	6782                	ld	a5,0(sp)
ffffffffc020afe2:	0ef71f63          	bne	a4,a5,ffffffffc020b0e0 <sfs_namefile+0x1f0>
ffffffffc020afe6:	008ca703          	lw	a4,8(s9)
ffffffffc020afea:	8ae6                	mv	s5,s9
ffffffffc020afec:	0d270a63          	beq	a4,s2,ffffffffc020b0c0 <sfs_namefile+0x1d0>
ffffffffc020aff0:	000cb703          	ld	a4,0(s9)
ffffffffc020aff4:	4789                	li	a5,2
ffffffffc020aff6:	00475703          	lhu	a4,4(a4)
ffffffffc020affa:	0cf71363          	bne	a4,a5,ffffffffc020b0c0 <sfs_namefile+0x1d0>
ffffffffc020affe:	020c8a13          	addi	s4,s9,32
ffffffffc020b002:	8552                	mv	a0,s4
ffffffffc020b004:	d60f90ef          	jal	ra,ffffffffc0204564 <down>
ffffffffc020b008:	000cb703          	ld	a4,0(s9)
ffffffffc020b00c:	00872983          	lw	s3,8(a4)
ffffffffc020b010:	01304963          	bgtz	s3,ffffffffc020b022 <sfs_namefile+0x132>
ffffffffc020b014:	a899                	j	ffffffffc020b06a <sfs_namefile+0x17a>
ffffffffc020b016:	4018                	lw	a4,0(s0)
ffffffffc020b018:	01270e63          	beq	a4,s2,ffffffffc020b034 <sfs_namefile+0x144>
ffffffffc020b01c:	2d85                	addiw	s11,s11,1
ffffffffc020b01e:	05b98663          	beq	s3,s11,ffffffffc020b06a <sfs_namefile+0x17a>
ffffffffc020b022:	86a2                	mv	a3,s0
ffffffffc020b024:	866e                	mv	a2,s11
ffffffffc020b026:	85e6                	mv	a1,s9
ffffffffc020b028:	8526                	mv	a0,s1
ffffffffc020b02a:	cb8ff0ef          	jal	ra,ffffffffc020a4e2 <sfs_dirent_read_nolock>
ffffffffc020b02e:	872a                	mv	a4,a0
ffffffffc020b030:	d17d                	beqz	a0,ffffffffc020b016 <sfs_namefile+0x126>
ffffffffc020b032:	a82d                	j	ffffffffc020b06c <sfs_namefile+0x17c>
ffffffffc020b034:	8552                	mv	a0,s4
ffffffffc020b036:	d2af90ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc020b03a:	8562                	mv	a0,s8
ffffffffc020b03c:	0ff000ef          	jal	ra,ffffffffc020b93a <strlen>
ffffffffc020b040:	00150793          	addi	a5,a0,1
ffffffffc020b044:	862a                	mv	a2,a0
ffffffffc020b046:	06fbe863          	bltu	s7,a5,ffffffffc020b0b6 <sfs_namefile+0x1c6>
ffffffffc020b04a:	fff64913          	not	s2,a2
ffffffffc020b04e:	995a                	add	s2,s2,s6
ffffffffc020b050:	85e2                	mv	a1,s8
ffffffffc020b052:	854a                	mv	a0,s2
ffffffffc020b054:	40fb8bb3          	sub	s7,s7,a5
ffffffffc020b058:	1ff000ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc020b05c:	02f00793          	li	a5,47
ffffffffc020b060:	fefb0fa3          	sb	a5,-1(s6)
ffffffffc020b064:	89e6                	mv	s3,s9
ffffffffc020b066:	8b4a                	mv	s6,s2
ffffffffc020b068:	b711                	j	ffffffffc020af6c <sfs_namefile+0x7c>
ffffffffc020b06a:	5741                	li	a4,-16
ffffffffc020b06c:	8552                	mv	a0,s4
ffffffffc020b06e:	e03a                	sd	a4,0(sp)
ffffffffc020b070:	cf0f90ef          	jal	ra,ffffffffc0204560 <up>
ffffffffc020b074:	6702                	ld	a4,0(sp)
ffffffffc020b076:	89e6                	mv	s3,s9
ffffffffc020b078:	8dba                	mv	s11,a4
ffffffffc020b07a:	bf11                	j	ffffffffc020af8e <sfs_namefile+0x9e>
ffffffffc020b07c:	854e                	mv	a0,s3
ffffffffc020b07e:	87dfc0ef          	jal	ra,ffffffffc02078fa <inode_ref_dec>
ffffffffc020b082:	64a2                	ld	s1,8(sp)
ffffffffc020b084:	85da                	mv	a1,s6
ffffffffc020b086:	6c98                	ld	a4,24(s1)
ffffffffc020b088:	6088                	ld	a0,0(s1)
ffffffffc020b08a:	1779                	addi	a4,a4,-2
ffffffffc020b08c:	41770bb3          	sub	s7,a4,s7
ffffffffc020b090:	865e                	mv	a2,s7
ffffffffc020b092:	0505                	addi	a0,a0,1
ffffffffc020b094:	183000ef          	jal	ra,ffffffffc020ba16 <memmove>
ffffffffc020b098:	02f00713          	li	a4,47
ffffffffc020b09c:	fee50fa3          	sb	a4,-1(a0)
ffffffffc020b0a0:	955e                	add	a0,a0,s7
ffffffffc020b0a2:	00050023          	sb	zero,0(a0)
ffffffffc020b0a6:	85de                	mv	a1,s7
ffffffffc020b0a8:	8526                	mv	a0,s1
ffffffffc020b0aa:	baefa0ef          	jal	ra,ffffffffc0205458 <iobuf_skip>
ffffffffc020b0ae:	8522                	mv	a0,s0
ffffffffc020b0b0:	f8ff60ef          	jal	ra,ffffffffc020203e <kfree>
ffffffffc020b0b4:	b5dd                	j	ffffffffc020af9a <sfs_namefile+0xaa>
ffffffffc020b0b6:	89e6                	mv	s3,s9
ffffffffc020b0b8:	5df1                	li	s11,-4
ffffffffc020b0ba:	bdd1                	j	ffffffffc020af8e <sfs_namefile+0x9e>
ffffffffc020b0bc:	5df1                	li	s11,-4
ffffffffc020b0be:	bdf1                	j	ffffffffc020af9a <sfs_namefile+0xaa>
ffffffffc020b0c0:	00004697          	auipc	a3,0x4
ffffffffc020b0c4:	6a068693          	addi	a3,a3,1696 # ffffffffc020f760 <dev_node_ops+0x8c0>
ffffffffc020b0c8:	00001617          	auipc	a2,0x1
ffffffffc020b0cc:	e2060613          	addi	a2,a2,-480 # ffffffffc020bee8 <commands+0x210>
ffffffffc020b0d0:	31000593          	li	a1,784
ffffffffc020b0d4:	00004517          	auipc	a0,0x4
ffffffffc020b0d8:	3c450513          	addi	a0,a0,964 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020b0dc:	bc2f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020b0e0:	00004697          	auipc	a3,0x4
ffffffffc020b0e4:	38068693          	addi	a3,a3,896 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc020b0e8:	00001617          	auipc	a2,0x1
ffffffffc020b0ec:	e0060613          	addi	a2,a2,-512 # ffffffffc020bee8 <commands+0x210>
ffffffffc020b0f0:	30f00593          	li	a1,783
ffffffffc020b0f4:	00004517          	auipc	a0,0x4
ffffffffc020b0f8:	3a450513          	addi	a0,a0,932 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020b0fc:	ba2f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020b100:	00004697          	auipc	a3,0x4
ffffffffc020b104:	36068693          	addi	a3,a3,864 # ffffffffc020f460 <dev_node_ops+0x5c0>
ffffffffc020b108:	00001617          	auipc	a2,0x1
ffffffffc020b10c:	de060613          	addi	a2,a2,-544 # ffffffffc020bee8 <commands+0x210>
ffffffffc020b110:	2fc00593          	li	a1,764
ffffffffc020b114:	00004517          	auipc	a0,0x4
ffffffffc020b118:	38450513          	addi	a0,a0,900 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020b11c:	b82f50ef          	jal	ra,ffffffffc020049e <__panic>
ffffffffc020b120:	00004697          	auipc	a3,0x4
ffffffffc020b124:	19868693          	addi	a3,a3,408 # ffffffffc020f2b8 <dev_node_ops+0x418>
ffffffffc020b128:	00001617          	auipc	a2,0x1
ffffffffc020b12c:	dc060613          	addi	a2,a2,-576 # ffffffffc020bee8 <commands+0x210>
ffffffffc020b130:	2fb00593          	li	a1,763
ffffffffc020b134:	00004517          	auipc	a0,0x4
ffffffffc020b138:	36450513          	addi	a0,a0,868 # ffffffffc020f498 <dev_node_ops+0x5f8>
ffffffffc020b13c:	b62f50ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020b140 <sfs_rwblock_nolock>:
ffffffffc020b140:	7139                	addi	sp,sp,-64
ffffffffc020b142:	f822                	sd	s0,48(sp)
ffffffffc020b144:	f426                	sd	s1,40(sp)
ffffffffc020b146:	fc06                	sd	ra,56(sp)
ffffffffc020b148:	842a                	mv	s0,a0
ffffffffc020b14a:	84b6                	mv	s1,a3
ffffffffc020b14c:	e211                	bnez	a2,ffffffffc020b150 <sfs_rwblock_nolock+0x10>
ffffffffc020b14e:	e715                	bnez	a4,ffffffffc020b17a <sfs_rwblock_nolock+0x3a>
ffffffffc020b150:	405c                	lw	a5,4(s0)
ffffffffc020b152:	02f67463          	bgeu	a2,a5,ffffffffc020b17a <sfs_rwblock_nolock+0x3a>
ffffffffc020b156:	00c6169b          	slliw	a3,a2,0xc
ffffffffc020b15a:	1682                	slli	a3,a3,0x20
ffffffffc020b15c:	6605                	lui	a2,0x1
ffffffffc020b15e:	9281                	srli	a3,a3,0x20
ffffffffc020b160:	850a                	mv	a0,sp
ffffffffc020b162:	a80fa0ef          	jal	ra,ffffffffc02053e2 <iobuf_init>
ffffffffc020b166:	85aa                	mv	a1,a0
ffffffffc020b168:	7808                	ld	a0,48(s0)
ffffffffc020b16a:	8626                	mv	a2,s1
ffffffffc020b16c:	7118                	ld	a4,32(a0)
ffffffffc020b16e:	9702                	jalr	a4
ffffffffc020b170:	70e2                	ld	ra,56(sp)
ffffffffc020b172:	7442                	ld	s0,48(sp)
ffffffffc020b174:	74a2                	ld	s1,40(sp)
ffffffffc020b176:	6121                	addi	sp,sp,64
ffffffffc020b178:	8082                	ret
ffffffffc020b17a:	00004697          	auipc	a3,0x4
ffffffffc020b17e:	78e68693          	addi	a3,a3,1934 # ffffffffc020f908 <sfs_node_fileops+0xb8>
ffffffffc020b182:	00001617          	auipc	a2,0x1
ffffffffc020b186:	d6660613          	addi	a2,a2,-666 # ffffffffc020bee8 <commands+0x210>
ffffffffc020b18a:	45d5                	li	a1,21
ffffffffc020b18c:	00004517          	auipc	a0,0x4
ffffffffc020b190:	7b450513          	addi	a0,a0,1972 # ffffffffc020f940 <sfs_node_fileops+0xf0>
ffffffffc020b194:	b0af50ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020b198 <sfs_rblock>:
ffffffffc020b198:	7139                	addi	sp,sp,-64
ffffffffc020b19a:	ec4e                	sd	s3,24(sp)
ffffffffc020b19c:	89b6                	mv	s3,a3
ffffffffc020b19e:	f822                	sd	s0,48(sp)
ffffffffc020b1a0:	f04a                	sd	s2,32(sp)
ffffffffc020b1a2:	e852                	sd	s4,16(sp)
ffffffffc020b1a4:	fc06                	sd	ra,56(sp)
ffffffffc020b1a6:	f426                	sd	s1,40(sp)
ffffffffc020b1a8:	e456                	sd	s5,8(sp)
ffffffffc020b1aa:	8a2a                	mv	s4,a0
ffffffffc020b1ac:	892e                	mv	s2,a1
ffffffffc020b1ae:	8432                	mv	s0,a2
ffffffffc020b1b0:	2e0000ef          	jal	ra,ffffffffc020b490 <lock_sfs_io>
ffffffffc020b1b4:	04098063          	beqz	s3,ffffffffc020b1f4 <sfs_rblock+0x5c>
ffffffffc020b1b8:	013409bb          	addw	s3,s0,s3
ffffffffc020b1bc:	6a85                	lui	s5,0x1
ffffffffc020b1be:	a021                	j	ffffffffc020b1c6 <sfs_rblock+0x2e>
ffffffffc020b1c0:	9956                	add	s2,s2,s5
ffffffffc020b1c2:	02898963          	beq	s3,s0,ffffffffc020b1f4 <sfs_rblock+0x5c>
ffffffffc020b1c6:	8622                	mv	a2,s0
ffffffffc020b1c8:	85ca                	mv	a1,s2
ffffffffc020b1ca:	4705                	li	a4,1
ffffffffc020b1cc:	4681                	li	a3,0
ffffffffc020b1ce:	8552                	mv	a0,s4
ffffffffc020b1d0:	f71ff0ef          	jal	ra,ffffffffc020b140 <sfs_rwblock_nolock>
ffffffffc020b1d4:	84aa                	mv	s1,a0
ffffffffc020b1d6:	2405                	addiw	s0,s0,1
ffffffffc020b1d8:	d565                	beqz	a0,ffffffffc020b1c0 <sfs_rblock+0x28>
ffffffffc020b1da:	8552                	mv	a0,s4
ffffffffc020b1dc:	2c4000ef          	jal	ra,ffffffffc020b4a0 <unlock_sfs_io>
ffffffffc020b1e0:	70e2                	ld	ra,56(sp)
ffffffffc020b1e2:	7442                	ld	s0,48(sp)
ffffffffc020b1e4:	7902                	ld	s2,32(sp)
ffffffffc020b1e6:	69e2                	ld	s3,24(sp)
ffffffffc020b1e8:	6a42                	ld	s4,16(sp)
ffffffffc020b1ea:	6aa2                	ld	s5,8(sp)
ffffffffc020b1ec:	8526                	mv	a0,s1
ffffffffc020b1ee:	74a2                	ld	s1,40(sp)
ffffffffc020b1f0:	6121                	addi	sp,sp,64
ffffffffc020b1f2:	8082                	ret
ffffffffc020b1f4:	4481                	li	s1,0
ffffffffc020b1f6:	b7d5                	j	ffffffffc020b1da <sfs_rblock+0x42>

ffffffffc020b1f8 <sfs_wblock>:
ffffffffc020b1f8:	7139                	addi	sp,sp,-64
ffffffffc020b1fa:	ec4e                	sd	s3,24(sp)
ffffffffc020b1fc:	89b6                	mv	s3,a3
ffffffffc020b1fe:	f822                	sd	s0,48(sp)
ffffffffc020b200:	f04a                	sd	s2,32(sp)
ffffffffc020b202:	e852                	sd	s4,16(sp)
ffffffffc020b204:	fc06                	sd	ra,56(sp)
ffffffffc020b206:	f426                	sd	s1,40(sp)
ffffffffc020b208:	e456                	sd	s5,8(sp)
ffffffffc020b20a:	8a2a                	mv	s4,a0
ffffffffc020b20c:	892e                	mv	s2,a1
ffffffffc020b20e:	8432                	mv	s0,a2
ffffffffc020b210:	280000ef          	jal	ra,ffffffffc020b490 <lock_sfs_io>
ffffffffc020b214:	04098063          	beqz	s3,ffffffffc020b254 <sfs_wblock+0x5c>
ffffffffc020b218:	013409bb          	addw	s3,s0,s3
ffffffffc020b21c:	6a85                	lui	s5,0x1
ffffffffc020b21e:	a021                	j	ffffffffc020b226 <sfs_wblock+0x2e>
ffffffffc020b220:	9956                	add	s2,s2,s5
ffffffffc020b222:	02898963          	beq	s3,s0,ffffffffc020b254 <sfs_wblock+0x5c>
ffffffffc020b226:	8622                	mv	a2,s0
ffffffffc020b228:	85ca                	mv	a1,s2
ffffffffc020b22a:	4705                	li	a4,1
ffffffffc020b22c:	4685                	li	a3,1
ffffffffc020b22e:	8552                	mv	a0,s4
ffffffffc020b230:	f11ff0ef          	jal	ra,ffffffffc020b140 <sfs_rwblock_nolock>
ffffffffc020b234:	84aa                	mv	s1,a0
ffffffffc020b236:	2405                	addiw	s0,s0,1
ffffffffc020b238:	d565                	beqz	a0,ffffffffc020b220 <sfs_wblock+0x28>
ffffffffc020b23a:	8552                	mv	a0,s4
ffffffffc020b23c:	264000ef          	jal	ra,ffffffffc020b4a0 <unlock_sfs_io>
ffffffffc020b240:	70e2                	ld	ra,56(sp)
ffffffffc020b242:	7442                	ld	s0,48(sp)
ffffffffc020b244:	7902                	ld	s2,32(sp)
ffffffffc020b246:	69e2                	ld	s3,24(sp)
ffffffffc020b248:	6a42                	ld	s4,16(sp)
ffffffffc020b24a:	6aa2                	ld	s5,8(sp)
ffffffffc020b24c:	8526                	mv	a0,s1
ffffffffc020b24e:	74a2                	ld	s1,40(sp)
ffffffffc020b250:	6121                	addi	sp,sp,64
ffffffffc020b252:	8082                	ret
ffffffffc020b254:	4481                	li	s1,0
ffffffffc020b256:	b7d5                	j	ffffffffc020b23a <sfs_wblock+0x42>

ffffffffc020b258 <sfs_rbuf>:
ffffffffc020b258:	7179                	addi	sp,sp,-48
ffffffffc020b25a:	f406                	sd	ra,40(sp)
ffffffffc020b25c:	f022                	sd	s0,32(sp)
ffffffffc020b25e:	ec26                	sd	s1,24(sp)
ffffffffc020b260:	e84a                	sd	s2,16(sp)
ffffffffc020b262:	e44e                	sd	s3,8(sp)
ffffffffc020b264:	e052                	sd	s4,0(sp)
ffffffffc020b266:	6785                	lui	a5,0x1
ffffffffc020b268:	04f77863          	bgeu	a4,a5,ffffffffc020b2b8 <sfs_rbuf+0x60>
ffffffffc020b26c:	84ba                	mv	s1,a4
ffffffffc020b26e:	9732                	add	a4,a4,a2
ffffffffc020b270:	89b2                	mv	s3,a2
ffffffffc020b272:	04e7e363          	bltu	a5,a4,ffffffffc020b2b8 <sfs_rbuf+0x60>
ffffffffc020b276:	8936                	mv	s2,a3
ffffffffc020b278:	842a                	mv	s0,a0
ffffffffc020b27a:	8a2e                	mv	s4,a1
ffffffffc020b27c:	214000ef          	jal	ra,ffffffffc020b490 <lock_sfs_io>
ffffffffc020b280:	642c                	ld	a1,72(s0)
ffffffffc020b282:	864a                	mv	a2,s2
ffffffffc020b284:	4705                	li	a4,1
ffffffffc020b286:	4681                	li	a3,0
ffffffffc020b288:	8522                	mv	a0,s0
ffffffffc020b28a:	eb7ff0ef          	jal	ra,ffffffffc020b140 <sfs_rwblock_nolock>
ffffffffc020b28e:	892a                	mv	s2,a0
ffffffffc020b290:	cd09                	beqz	a0,ffffffffc020b2aa <sfs_rbuf+0x52>
ffffffffc020b292:	8522                	mv	a0,s0
ffffffffc020b294:	20c000ef          	jal	ra,ffffffffc020b4a0 <unlock_sfs_io>
ffffffffc020b298:	70a2                	ld	ra,40(sp)
ffffffffc020b29a:	7402                	ld	s0,32(sp)
ffffffffc020b29c:	64e2                	ld	s1,24(sp)
ffffffffc020b29e:	69a2                	ld	s3,8(sp)
ffffffffc020b2a0:	6a02                	ld	s4,0(sp)
ffffffffc020b2a2:	854a                	mv	a0,s2
ffffffffc020b2a4:	6942                	ld	s2,16(sp)
ffffffffc020b2a6:	6145                	addi	sp,sp,48
ffffffffc020b2a8:	8082                	ret
ffffffffc020b2aa:	642c                	ld	a1,72(s0)
ffffffffc020b2ac:	864e                	mv	a2,s3
ffffffffc020b2ae:	8552                	mv	a0,s4
ffffffffc020b2b0:	95a6                	add	a1,a1,s1
ffffffffc020b2b2:	7a4000ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc020b2b6:	bff1                	j	ffffffffc020b292 <sfs_rbuf+0x3a>
ffffffffc020b2b8:	00004697          	auipc	a3,0x4
ffffffffc020b2bc:	6a068693          	addi	a3,a3,1696 # ffffffffc020f958 <sfs_node_fileops+0x108>
ffffffffc020b2c0:	00001617          	auipc	a2,0x1
ffffffffc020b2c4:	c2860613          	addi	a2,a2,-984 # ffffffffc020bee8 <commands+0x210>
ffffffffc020b2c8:	05500593          	li	a1,85
ffffffffc020b2cc:	00004517          	auipc	a0,0x4
ffffffffc020b2d0:	67450513          	addi	a0,a0,1652 # ffffffffc020f940 <sfs_node_fileops+0xf0>
ffffffffc020b2d4:	9caf50ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020b2d8 <sfs_wbuf>:
ffffffffc020b2d8:	7139                	addi	sp,sp,-64
ffffffffc020b2da:	fc06                	sd	ra,56(sp)
ffffffffc020b2dc:	f822                	sd	s0,48(sp)
ffffffffc020b2de:	f426                	sd	s1,40(sp)
ffffffffc020b2e0:	f04a                	sd	s2,32(sp)
ffffffffc020b2e2:	ec4e                	sd	s3,24(sp)
ffffffffc020b2e4:	e852                	sd	s4,16(sp)
ffffffffc020b2e6:	e456                	sd	s5,8(sp)
ffffffffc020b2e8:	6785                	lui	a5,0x1
ffffffffc020b2ea:	06f77163          	bgeu	a4,a5,ffffffffc020b34c <sfs_wbuf+0x74>
ffffffffc020b2ee:	893a                	mv	s2,a4
ffffffffc020b2f0:	9732                	add	a4,a4,a2
ffffffffc020b2f2:	8a32                	mv	s4,a2
ffffffffc020b2f4:	04e7ec63          	bltu	a5,a4,ffffffffc020b34c <sfs_wbuf+0x74>
ffffffffc020b2f8:	842a                	mv	s0,a0
ffffffffc020b2fa:	89b6                	mv	s3,a3
ffffffffc020b2fc:	8aae                	mv	s5,a1
ffffffffc020b2fe:	192000ef          	jal	ra,ffffffffc020b490 <lock_sfs_io>
ffffffffc020b302:	642c                	ld	a1,72(s0)
ffffffffc020b304:	4705                	li	a4,1
ffffffffc020b306:	4681                	li	a3,0
ffffffffc020b308:	864e                	mv	a2,s3
ffffffffc020b30a:	8522                	mv	a0,s0
ffffffffc020b30c:	e35ff0ef          	jal	ra,ffffffffc020b140 <sfs_rwblock_nolock>
ffffffffc020b310:	84aa                	mv	s1,a0
ffffffffc020b312:	cd11                	beqz	a0,ffffffffc020b32e <sfs_wbuf+0x56>
ffffffffc020b314:	8522                	mv	a0,s0
ffffffffc020b316:	18a000ef          	jal	ra,ffffffffc020b4a0 <unlock_sfs_io>
ffffffffc020b31a:	70e2                	ld	ra,56(sp)
ffffffffc020b31c:	7442                	ld	s0,48(sp)
ffffffffc020b31e:	7902                	ld	s2,32(sp)
ffffffffc020b320:	69e2                	ld	s3,24(sp)
ffffffffc020b322:	6a42                	ld	s4,16(sp)
ffffffffc020b324:	6aa2                	ld	s5,8(sp)
ffffffffc020b326:	8526                	mv	a0,s1
ffffffffc020b328:	74a2                	ld	s1,40(sp)
ffffffffc020b32a:	6121                	addi	sp,sp,64
ffffffffc020b32c:	8082                	ret
ffffffffc020b32e:	6428                	ld	a0,72(s0)
ffffffffc020b330:	8652                	mv	a2,s4
ffffffffc020b332:	85d6                	mv	a1,s5
ffffffffc020b334:	954a                	add	a0,a0,s2
ffffffffc020b336:	720000ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc020b33a:	642c                	ld	a1,72(s0)
ffffffffc020b33c:	4705                	li	a4,1
ffffffffc020b33e:	4685                	li	a3,1
ffffffffc020b340:	864e                	mv	a2,s3
ffffffffc020b342:	8522                	mv	a0,s0
ffffffffc020b344:	dfdff0ef          	jal	ra,ffffffffc020b140 <sfs_rwblock_nolock>
ffffffffc020b348:	84aa                	mv	s1,a0
ffffffffc020b34a:	b7e9                	j	ffffffffc020b314 <sfs_wbuf+0x3c>
ffffffffc020b34c:	00004697          	auipc	a3,0x4
ffffffffc020b350:	60c68693          	addi	a3,a3,1548 # ffffffffc020f958 <sfs_node_fileops+0x108>
ffffffffc020b354:	00001617          	auipc	a2,0x1
ffffffffc020b358:	b9460613          	addi	a2,a2,-1132 # ffffffffc020bee8 <commands+0x210>
ffffffffc020b35c:	06b00593          	li	a1,107
ffffffffc020b360:	00004517          	auipc	a0,0x4
ffffffffc020b364:	5e050513          	addi	a0,a0,1504 # ffffffffc020f940 <sfs_node_fileops+0xf0>
ffffffffc020b368:	936f50ef          	jal	ra,ffffffffc020049e <__panic>

ffffffffc020b36c <sfs_sync_super>:
ffffffffc020b36c:	1101                	addi	sp,sp,-32
ffffffffc020b36e:	ec06                	sd	ra,24(sp)
ffffffffc020b370:	e822                	sd	s0,16(sp)
ffffffffc020b372:	e426                	sd	s1,8(sp)
ffffffffc020b374:	842a                	mv	s0,a0
ffffffffc020b376:	11a000ef          	jal	ra,ffffffffc020b490 <lock_sfs_io>
ffffffffc020b37a:	6428                	ld	a0,72(s0)
ffffffffc020b37c:	6605                	lui	a2,0x1
ffffffffc020b37e:	4581                	li	a1,0
ffffffffc020b380:	684000ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc020b384:	6428                	ld	a0,72(s0)
ffffffffc020b386:	85a2                	mv	a1,s0
ffffffffc020b388:	02c00613          	li	a2,44
ffffffffc020b38c:	6ca000ef          	jal	ra,ffffffffc020ba56 <memcpy>
ffffffffc020b390:	642c                	ld	a1,72(s0)
ffffffffc020b392:	4701                	li	a4,0
ffffffffc020b394:	4685                	li	a3,1
ffffffffc020b396:	4601                	li	a2,0
ffffffffc020b398:	8522                	mv	a0,s0
ffffffffc020b39a:	da7ff0ef          	jal	ra,ffffffffc020b140 <sfs_rwblock_nolock>
ffffffffc020b39e:	84aa                	mv	s1,a0
ffffffffc020b3a0:	8522                	mv	a0,s0
ffffffffc020b3a2:	0fe000ef          	jal	ra,ffffffffc020b4a0 <unlock_sfs_io>
ffffffffc020b3a6:	60e2                	ld	ra,24(sp)
ffffffffc020b3a8:	6442                	ld	s0,16(sp)
ffffffffc020b3aa:	8526                	mv	a0,s1
ffffffffc020b3ac:	64a2                	ld	s1,8(sp)
ffffffffc020b3ae:	6105                	addi	sp,sp,32
ffffffffc020b3b0:	8082                	ret

ffffffffc020b3b2 <sfs_sync_freemap>:
ffffffffc020b3b2:	7139                	addi	sp,sp,-64
ffffffffc020b3b4:	ec4e                	sd	s3,24(sp)
ffffffffc020b3b6:	e852                	sd	s4,16(sp)
ffffffffc020b3b8:	00456983          	lwu	s3,4(a0)
ffffffffc020b3bc:	8a2a                	mv	s4,a0
ffffffffc020b3be:	7d08                	ld	a0,56(a0)
ffffffffc020b3c0:	67a1                	lui	a5,0x8
ffffffffc020b3c2:	17fd                	addi	a5,a5,-1
ffffffffc020b3c4:	4581                	li	a1,0
ffffffffc020b3c6:	f822                	sd	s0,48(sp)
ffffffffc020b3c8:	fc06                	sd	ra,56(sp)
ffffffffc020b3ca:	f426                	sd	s1,40(sp)
ffffffffc020b3cc:	f04a                	sd	s2,32(sp)
ffffffffc020b3ce:	e456                	sd	s5,8(sp)
ffffffffc020b3d0:	99be                	add	s3,s3,a5
ffffffffc020b3d2:	f63fd0ef          	jal	ra,ffffffffc0209334 <bitmap_getdata>
ffffffffc020b3d6:	00f9d993          	srli	s3,s3,0xf
ffffffffc020b3da:	842a                	mv	s0,a0
ffffffffc020b3dc:	8552                	mv	a0,s4
ffffffffc020b3de:	0b2000ef          	jal	ra,ffffffffc020b490 <lock_sfs_io>
ffffffffc020b3e2:	04098163          	beqz	s3,ffffffffc020b424 <sfs_sync_freemap+0x72>
ffffffffc020b3e6:	09b2                	slli	s3,s3,0xc
ffffffffc020b3e8:	99a2                	add	s3,s3,s0
ffffffffc020b3ea:	4909                	li	s2,2
ffffffffc020b3ec:	6a85                	lui	s5,0x1
ffffffffc020b3ee:	a021                	j	ffffffffc020b3f6 <sfs_sync_freemap+0x44>
ffffffffc020b3f0:	2905                	addiw	s2,s2,1
ffffffffc020b3f2:	02898963          	beq	s3,s0,ffffffffc020b424 <sfs_sync_freemap+0x72>
ffffffffc020b3f6:	85a2                	mv	a1,s0
ffffffffc020b3f8:	864a                	mv	a2,s2
ffffffffc020b3fa:	4705                	li	a4,1
ffffffffc020b3fc:	4685                	li	a3,1
ffffffffc020b3fe:	8552                	mv	a0,s4
ffffffffc020b400:	d41ff0ef          	jal	ra,ffffffffc020b140 <sfs_rwblock_nolock>
ffffffffc020b404:	84aa                	mv	s1,a0
ffffffffc020b406:	9456                	add	s0,s0,s5
ffffffffc020b408:	d565                	beqz	a0,ffffffffc020b3f0 <sfs_sync_freemap+0x3e>
ffffffffc020b40a:	8552                	mv	a0,s4
ffffffffc020b40c:	094000ef          	jal	ra,ffffffffc020b4a0 <unlock_sfs_io>
ffffffffc020b410:	70e2                	ld	ra,56(sp)
ffffffffc020b412:	7442                	ld	s0,48(sp)
ffffffffc020b414:	7902                	ld	s2,32(sp)
ffffffffc020b416:	69e2                	ld	s3,24(sp)
ffffffffc020b418:	6a42                	ld	s4,16(sp)
ffffffffc020b41a:	6aa2                	ld	s5,8(sp)
ffffffffc020b41c:	8526                	mv	a0,s1
ffffffffc020b41e:	74a2                	ld	s1,40(sp)
ffffffffc020b420:	6121                	addi	sp,sp,64
ffffffffc020b422:	8082                	ret
ffffffffc020b424:	4481                	li	s1,0
ffffffffc020b426:	b7d5                	j	ffffffffc020b40a <sfs_sync_freemap+0x58>

ffffffffc020b428 <sfs_clear_block>:
ffffffffc020b428:	7179                	addi	sp,sp,-48
ffffffffc020b42a:	f022                	sd	s0,32(sp)
ffffffffc020b42c:	e84a                	sd	s2,16(sp)
ffffffffc020b42e:	e44e                	sd	s3,8(sp)
ffffffffc020b430:	f406                	sd	ra,40(sp)
ffffffffc020b432:	89b2                	mv	s3,a2
ffffffffc020b434:	ec26                	sd	s1,24(sp)
ffffffffc020b436:	892a                	mv	s2,a0
ffffffffc020b438:	842e                	mv	s0,a1
ffffffffc020b43a:	056000ef          	jal	ra,ffffffffc020b490 <lock_sfs_io>
ffffffffc020b43e:	04893503          	ld	a0,72(s2)
ffffffffc020b442:	6605                	lui	a2,0x1
ffffffffc020b444:	4581                	li	a1,0
ffffffffc020b446:	5be000ef          	jal	ra,ffffffffc020ba04 <memset>
ffffffffc020b44a:	02098d63          	beqz	s3,ffffffffc020b484 <sfs_clear_block+0x5c>
ffffffffc020b44e:	013409bb          	addw	s3,s0,s3
ffffffffc020b452:	a019                	j	ffffffffc020b458 <sfs_clear_block+0x30>
ffffffffc020b454:	02898863          	beq	s3,s0,ffffffffc020b484 <sfs_clear_block+0x5c>
ffffffffc020b458:	04893583          	ld	a1,72(s2)
ffffffffc020b45c:	8622                	mv	a2,s0
ffffffffc020b45e:	4705                	li	a4,1
ffffffffc020b460:	4685                	li	a3,1
ffffffffc020b462:	854a                	mv	a0,s2
ffffffffc020b464:	cddff0ef          	jal	ra,ffffffffc020b140 <sfs_rwblock_nolock>
ffffffffc020b468:	84aa                	mv	s1,a0
ffffffffc020b46a:	2405                	addiw	s0,s0,1
ffffffffc020b46c:	d565                	beqz	a0,ffffffffc020b454 <sfs_clear_block+0x2c>
ffffffffc020b46e:	854a                	mv	a0,s2
ffffffffc020b470:	030000ef          	jal	ra,ffffffffc020b4a0 <unlock_sfs_io>
ffffffffc020b474:	70a2                	ld	ra,40(sp)
ffffffffc020b476:	7402                	ld	s0,32(sp)
ffffffffc020b478:	6942                	ld	s2,16(sp)
ffffffffc020b47a:	69a2                	ld	s3,8(sp)
ffffffffc020b47c:	8526                	mv	a0,s1
ffffffffc020b47e:	64e2                	ld	s1,24(sp)
ffffffffc020b480:	6145                	addi	sp,sp,48
ffffffffc020b482:	8082                	ret
ffffffffc020b484:	4481                	li	s1,0
ffffffffc020b486:	b7e5                	j	ffffffffc020b46e <sfs_clear_block+0x46>

ffffffffc020b488 <lock_sfs_fs>:
ffffffffc020b488:	05050513          	addi	a0,a0,80
ffffffffc020b48c:	8d8f906f          	j	ffffffffc0204564 <down>

ffffffffc020b490 <lock_sfs_io>:
ffffffffc020b490:	06850513          	addi	a0,a0,104
ffffffffc020b494:	8d0f906f          	j	ffffffffc0204564 <down>

ffffffffc020b498 <unlock_sfs_fs>:
ffffffffc020b498:	05050513          	addi	a0,a0,80
ffffffffc020b49c:	8c4f906f          	j	ffffffffc0204560 <up>

ffffffffc020b4a0 <unlock_sfs_io>:
ffffffffc020b4a0:	06850513          	addi	a0,a0,104
ffffffffc020b4a4:	8bcf906f          	j	ffffffffc0204560 <up>

ffffffffc020b4a8 <hash32>:
ffffffffc020b4a8:	9e3707b7          	lui	a5,0x9e370
ffffffffc020b4ac:	2785                	addiw	a5,a5,1
ffffffffc020b4ae:	02a7853b          	mulw	a0,a5,a0
ffffffffc020b4b2:	02000793          	li	a5,32
ffffffffc020b4b6:	9f8d                	subw	a5,a5,a1
ffffffffc020b4b8:	00f5553b          	srlw	a0,a0,a5
ffffffffc020b4bc:	8082                	ret

ffffffffc020b4be <printnum>:
ffffffffc020b4be:	02071893          	slli	a7,a4,0x20
ffffffffc020b4c2:	7139                	addi	sp,sp,-64
ffffffffc020b4c4:	0208d893          	srli	a7,a7,0x20
ffffffffc020b4c8:	e456                	sd	s5,8(sp)
ffffffffc020b4ca:	0316fab3          	remu	s5,a3,a7
ffffffffc020b4ce:	f822                	sd	s0,48(sp)
ffffffffc020b4d0:	f426                	sd	s1,40(sp)
ffffffffc020b4d2:	f04a                	sd	s2,32(sp)
ffffffffc020b4d4:	ec4e                	sd	s3,24(sp)
ffffffffc020b4d6:	fc06                	sd	ra,56(sp)
ffffffffc020b4d8:	e852                	sd	s4,16(sp)
ffffffffc020b4da:	84aa                	mv	s1,a0
ffffffffc020b4dc:	89ae                	mv	s3,a1
ffffffffc020b4de:	8932                	mv	s2,a2
ffffffffc020b4e0:	fff7841b          	addiw	s0,a5,-1
ffffffffc020b4e4:	2a81                	sext.w	s5,s5
ffffffffc020b4e6:	0516f163          	bgeu	a3,a7,ffffffffc020b528 <printnum+0x6a>
ffffffffc020b4ea:	8a42                	mv	s4,a6
ffffffffc020b4ec:	00805863          	blez	s0,ffffffffc020b4fc <printnum+0x3e>
ffffffffc020b4f0:	347d                	addiw	s0,s0,-1
ffffffffc020b4f2:	864e                	mv	a2,s3
ffffffffc020b4f4:	85ca                	mv	a1,s2
ffffffffc020b4f6:	8552                	mv	a0,s4
ffffffffc020b4f8:	9482                	jalr	s1
ffffffffc020b4fa:	f87d                	bnez	s0,ffffffffc020b4f0 <printnum+0x32>
ffffffffc020b4fc:	1a82                	slli	s5,s5,0x20
ffffffffc020b4fe:	00004797          	auipc	a5,0x4
ffffffffc020b502:	4a278793          	addi	a5,a5,1186 # ffffffffc020f9a0 <sfs_node_fileops+0x150>
ffffffffc020b506:	020ada93          	srli	s5,s5,0x20
ffffffffc020b50a:	9abe                	add	s5,s5,a5
ffffffffc020b50c:	7442                	ld	s0,48(sp)
ffffffffc020b50e:	000ac503          	lbu	a0,0(s5) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc020b512:	70e2                	ld	ra,56(sp)
ffffffffc020b514:	6a42                	ld	s4,16(sp)
ffffffffc020b516:	6aa2                	ld	s5,8(sp)
ffffffffc020b518:	864e                	mv	a2,s3
ffffffffc020b51a:	85ca                	mv	a1,s2
ffffffffc020b51c:	69e2                	ld	s3,24(sp)
ffffffffc020b51e:	7902                	ld	s2,32(sp)
ffffffffc020b520:	87a6                	mv	a5,s1
ffffffffc020b522:	74a2                	ld	s1,40(sp)
ffffffffc020b524:	6121                	addi	sp,sp,64
ffffffffc020b526:	8782                	jr	a5
ffffffffc020b528:	0316d6b3          	divu	a3,a3,a7
ffffffffc020b52c:	87a2                	mv	a5,s0
ffffffffc020b52e:	f91ff0ef          	jal	ra,ffffffffc020b4be <printnum>
ffffffffc020b532:	b7e9                	j	ffffffffc020b4fc <printnum+0x3e>

ffffffffc020b534 <sprintputch>:
ffffffffc020b534:	499c                	lw	a5,16(a1)
ffffffffc020b536:	6198                	ld	a4,0(a1)
ffffffffc020b538:	6594                	ld	a3,8(a1)
ffffffffc020b53a:	2785                	addiw	a5,a5,1
ffffffffc020b53c:	c99c                	sw	a5,16(a1)
ffffffffc020b53e:	00d77763          	bgeu	a4,a3,ffffffffc020b54c <sprintputch+0x18>
ffffffffc020b542:	00170793          	addi	a5,a4,1
ffffffffc020b546:	e19c                	sd	a5,0(a1)
ffffffffc020b548:	00a70023          	sb	a0,0(a4)
ffffffffc020b54c:	8082                	ret

ffffffffc020b54e <vprintfmt>:
ffffffffc020b54e:	7119                	addi	sp,sp,-128
ffffffffc020b550:	f4a6                	sd	s1,104(sp)
ffffffffc020b552:	f0ca                	sd	s2,96(sp)
ffffffffc020b554:	ecce                	sd	s3,88(sp)
ffffffffc020b556:	e8d2                	sd	s4,80(sp)
ffffffffc020b558:	e4d6                	sd	s5,72(sp)
ffffffffc020b55a:	e0da                	sd	s6,64(sp)
ffffffffc020b55c:	fc5e                	sd	s7,56(sp)
ffffffffc020b55e:	ec6e                	sd	s11,24(sp)
ffffffffc020b560:	fc86                	sd	ra,120(sp)
ffffffffc020b562:	f8a2                	sd	s0,112(sp)
ffffffffc020b564:	f862                	sd	s8,48(sp)
ffffffffc020b566:	f466                	sd	s9,40(sp)
ffffffffc020b568:	f06a                	sd	s10,32(sp)
ffffffffc020b56a:	89aa                	mv	s3,a0
ffffffffc020b56c:	892e                	mv	s2,a1
ffffffffc020b56e:	84b2                	mv	s1,a2
ffffffffc020b570:	8db6                	mv	s11,a3
ffffffffc020b572:	8aba                	mv	s5,a4
ffffffffc020b574:	02500a13          	li	s4,37
ffffffffc020b578:	5bfd                	li	s7,-1
ffffffffc020b57a:	00004b17          	auipc	s6,0x4
ffffffffc020b57e:	452b0b13          	addi	s6,s6,1106 # ffffffffc020f9cc <sfs_node_fileops+0x17c>
ffffffffc020b582:	000dc503          	lbu	a0,0(s11) # 2000 <_binary_bin_swap_img_size-0x5d00>
ffffffffc020b586:	001d8413          	addi	s0,s11,1
ffffffffc020b58a:	01450b63          	beq	a0,s4,ffffffffc020b5a0 <vprintfmt+0x52>
ffffffffc020b58e:	c129                	beqz	a0,ffffffffc020b5d0 <vprintfmt+0x82>
ffffffffc020b590:	864a                	mv	a2,s2
ffffffffc020b592:	85a6                	mv	a1,s1
ffffffffc020b594:	0405                	addi	s0,s0,1
ffffffffc020b596:	9982                	jalr	s3
ffffffffc020b598:	fff44503          	lbu	a0,-1(s0)
ffffffffc020b59c:	ff4519e3          	bne	a0,s4,ffffffffc020b58e <vprintfmt+0x40>
ffffffffc020b5a0:	00044583          	lbu	a1,0(s0)
ffffffffc020b5a4:	02000813          	li	a6,32
ffffffffc020b5a8:	4d01                	li	s10,0
ffffffffc020b5aa:	4301                	li	t1,0
ffffffffc020b5ac:	5cfd                	li	s9,-1
ffffffffc020b5ae:	5c7d                	li	s8,-1
ffffffffc020b5b0:	05500513          	li	a0,85
ffffffffc020b5b4:	48a5                	li	a7,9
ffffffffc020b5b6:	fdd5861b          	addiw	a2,a1,-35
ffffffffc020b5ba:	0ff67613          	zext.b	a2,a2
ffffffffc020b5be:	00140d93          	addi	s11,s0,1
ffffffffc020b5c2:	04c56263          	bltu	a0,a2,ffffffffc020b606 <vprintfmt+0xb8>
ffffffffc020b5c6:	060a                	slli	a2,a2,0x2
ffffffffc020b5c8:	965a                	add	a2,a2,s6
ffffffffc020b5ca:	4214                	lw	a3,0(a2)
ffffffffc020b5cc:	96da                	add	a3,a3,s6
ffffffffc020b5ce:	8682                	jr	a3
ffffffffc020b5d0:	70e6                	ld	ra,120(sp)
ffffffffc020b5d2:	7446                	ld	s0,112(sp)
ffffffffc020b5d4:	74a6                	ld	s1,104(sp)
ffffffffc020b5d6:	7906                	ld	s2,96(sp)
ffffffffc020b5d8:	69e6                	ld	s3,88(sp)
ffffffffc020b5da:	6a46                	ld	s4,80(sp)
ffffffffc020b5dc:	6aa6                	ld	s5,72(sp)
ffffffffc020b5de:	6b06                	ld	s6,64(sp)
ffffffffc020b5e0:	7be2                	ld	s7,56(sp)
ffffffffc020b5e2:	7c42                	ld	s8,48(sp)
ffffffffc020b5e4:	7ca2                	ld	s9,40(sp)
ffffffffc020b5e6:	7d02                	ld	s10,32(sp)
ffffffffc020b5e8:	6de2                	ld	s11,24(sp)
ffffffffc020b5ea:	6109                	addi	sp,sp,128
ffffffffc020b5ec:	8082                	ret
ffffffffc020b5ee:	882e                	mv	a6,a1
ffffffffc020b5f0:	00144583          	lbu	a1,1(s0)
ffffffffc020b5f4:	846e                	mv	s0,s11
ffffffffc020b5f6:	00140d93          	addi	s11,s0,1
ffffffffc020b5fa:	fdd5861b          	addiw	a2,a1,-35
ffffffffc020b5fe:	0ff67613          	zext.b	a2,a2
ffffffffc020b602:	fcc572e3          	bgeu	a0,a2,ffffffffc020b5c6 <vprintfmt+0x78>
ffffffffc020b606:	864a                	mv	a2,s2
ffffffffc020b608:	85a6                	mv	a1,s1
ffffffffc020b60a:	02500513          	li	a0,37
ffffffffc020b60e:	9982                	jalr	s3
ffffffffc020b610:	fff44783          	lbu	a5,-1(s0)
ffffffffc020b614:	8da2                	mv	s11,s0
ffffffffc020b616:	f74786e3          	beq	a5,s4,ffffffffc020b582 <vprintfmt+0x34>
ffffffffc020b61a:	ffedc783          	lbu	a5,-2(s11)
ffffffffc020b61e:	1dfd                	addi	s11,s11,-1
ffffffffc020b620:	ff479de3          	bne	a5,s4,ffffffffc020b61a <vprintfmt+0xcc>
ffffffffc020b624:	bfb9                	j	ffffffffc020b582 <vprintfmt+0x34>
ffffffffc020b626:	fd058c9b          	addiw	s9,a1,-48
ffffffffc020b62a:	00144583          	lbu	a1,1(s0)
ffffffffc020b62e:	846e                	mv	s0,s11
ffffffffc020b630:	fd05869b          	addiw	a3,a1,-48
ffffffffc020b634:	0005861b          	sext.w	a2,a1
ffffffffc020b638:	02d8e463          	bltu	a7,a3,ffffffffc020b660 <vprintfmt+0x112>
ffffffffc020b63c:	00144583          	lbu	a1,1(s0)
ffffffffc020b640:	002c969b          	slliw	a3,s9,0x2
ffffffffc020b644:	0196873b          	addw	a4,a3,s9
ffffffffc020b648:	0017171b          	slliw	a4,a4,0x1
ffffffffc020b64c:	9f31                	addw	a4,a4,a2
ffffffffc020b64e:	fd05869b          	addiw	a3,a1,-48
ffffffffc020b652:	0405                	addi	s0,s0,1
ffffffffc020b654:	fd070c9b          	addiw	s9,a4,-48
ffffffffc020b658:	0005861b          	sext.w	a2,a1
ffffffffc020b65c:	fed8f0e3          	bgeu	a7,a3,ffffffffc020b63c <vprintfmt+0xee>
ffffffffc020b660:	f40c5be3          	bgez	s8,ffffffffc020b5b6 <vprintfmt+0x68>
ffffffffc020b664:	8c66                	mv	s8,s9
ffffffffc020b666:	5cfd                	li	s9,-1
ffffffffc020b668:	b7b9                	j	ffffffffc020b5b6 <vprintfmt+0x68>
ffffffffc020b66a:	fffc4693          	not	a3,s8
ffffffffc020b66e:	96fd                	srai	a3,a3,0x3f
ffffffffc020b670:	00dc77b3          	and	a5,s8,a3
ffffffffc020b674:	00144583          	lbu	a1,1(s0)
ffffffffc020b678:	00078c1b          	sext.w	s8,a5
ffffffffc020b67c:	846e                	mv	s0,s11
ffffffffc020b67e:	bf25                	j	ffffffffc020b5b6 <vprintfmt+0x68>
ffffffffc020b680:	000aac83          	lw	s9,0(s5)
ffffffffc020b684:	00144583          	lbu	a1,1(s0)
ffffffffc020b688:	0aa1                	addi	s5,s5,8
ffffffffc020b68a:	846e                	mv	s0,s11
ffffffffc020b68c:	bfd1                	j	ffffffffc020b660 <vprintfmt+0x112>
ffffffffc020b68e:	4705                	li	a4,1
ffffffffc020b690:	008a8613          	addi	a2,s5,8
ffffffffc020b694:	00674463          	blt	a4,t1,ffffffffc020b69c <vprintfmt+0x14e>
ffffffffc020b698:	1c030c63          	beqz	t1,ffffffffc020b870 <vprintfmt+0x322>
ffffffffc020b69c:	000ab683          	ld	a3,0(s5)
ffffffffc020b6a0:	4741                	li	a4,16
ffffffffc020b6a2:	8ab2                	mv	s5,a2
ffffffffc020b6a4:	2801                	sext.w	a6,a6
ffffffffc020b6a6:	87e2                	mv	a5,s8
ffffffffc020b6a8:	8626                	mv	a2,s1
ffffffffc020b6aa:	85ca                	mv	a1,s2
ffffffffc020b6ac:	854e                	mv	a0,s3
ffffffffc020b6ae:	e11ff0ef          	jal	ra,ffffffffc020b4be <printnum>
ffffffffc020b6b2:	bdc1                	j	ffffffffc020b582 <vprintfmt+0x34>
ffffffffc020b6b4:	000aa503          	lw	a0,0(s5)
ffffffffc020b6b8:	864a                	mv	a2,s2
ffffffffc020b6ba:	85a6                	mv	a1,s1
ffffffffc020b6bc:	0aa1                	addi	s5,s5,8
ffffffffc020b6be:	9982                	jalr	s3
ffffffffc020b6c0:	b5c9                	j	ffffffffc020b582 <vprintfmt+0x34>
ffffffffc020b6c2:	4705                	li	a4,1
ffffffffc020b6c4:	008a8613          	addi	a2,s5,8
ffffffffc020b6c8:	00674463          	blt	a4,t1,ffffffffc020b6d0 <vprintfmt+0x182>
ffffffffc020b6cc:	18030d63          	beqz	t1,ffffffffc020b866 <vprintfmt+0x318>
ffffffffc020b6d0:	000ab683          	ld	a3,0(s5)
ffffffffc020b6d4:	4729                	li	a4,10
ffffffffc020b6d6:	8ab2                	mv	s5,a2
ffffffffc020b6d8:	b7f1                	j	ffffffffc020b6a4 <vprintfmt+0x156>
ffffffffc020b6da:	00144583          	lbu	a1,1(s0)
ffffffffc020b6de:	4d05                	li	s10,1
ffffffffc020b6e0:	846e                	mv	s0,s11
ffffffffc020b6e2:	bdd1                	j	ffffffffc020b5b6 <vprintfmt+0x68>
ffffffffc020b6e4:	864a                	mv	a2,s2
ffffffffc020b6e6:	85a6                	mv	a1,s1
ffffffffc020b6e8:	02500513          	li	a0,37
ffffffffc020b6ec:	9982                	jalr	s3
ffffffffc020b6ee:	bd51                	j	ffffffffc020b582 <vprintfmt+0x34>
ffffffffc020b6f0:	00144583          	lbu	a1,1(s0)
ffffffffc020b6f4:	2305                	addiw	t1,t1,1
ffffffffc020b6f6:	846e                	mv	s0,s11
ffffffffc020b6f8:	bd7d                	j	ffffffffc020b5b6 <vprintfmt+0x68>
ffffffffc020b6fa:	4705                	li	a4,1
ffffffffc020b6fc:	008a8613          	addi	a2,s5,8
ffffffffc020b700:	00674463          	blt	a4,t1,ffffffffc020b708 <vprintfmt+0x1ba>
ffffffffc020b704:	14030c63          	beqz	t1,ffffffffc020b85c <vprintfmt+0x30e>
ffffffffc020b708:	000ab683          	ld	a3,0(s5)
ffffffffc020b70c:	4721                	li	a4,8
ffffffffc020b70e:	8ab2                	mv	s5,a2
ffffffffc020b710:	bf51                	j	ffffffffc020b6a4 <vprintfmt+0x156>
ffffffffc020b712:	03000513          	li	a0,48
ffffffffc020b716:	864a                	mv	a2,s2
ffffffffc020b718:	85a6                	mv	a1,s1
ffffffffc020b71a:	e042                	sd	a6,0(sp)
ffffffffc020b71c:	9982                	jalr	s3
ffffffffc020b71e:	864a                	mv	a2,s2
ffffffffc020b720:	85a6                	mv	a1,s1
ffffffffc020b722:	07800513          	li	a0,120
ffffffffc020b726:	9982                	jalr	s3
ffffffffc020b728:	0aa1                	addi	s5,s5,8
ffffffffc020b72a:	6802                	ld	a6,0(sp)
ffffffffc020b72c:	4741                	li	a4,16
ffffffffc020b72e:	ff8ab683          	ld	a3,-8(s5)
ffffffffc020b732:	bf8d                	j	ffffffffc020b6a4 <vprintfmt+0x156>
ffffffffc020b734:	000ab403          	ld	s0,0(s5)
ffffffffc020b738:	008a8793          	addi	a5,s5,8
ffffffffc020b73c:	e03e                	sd	a5,0(sp)
ffffffffc020b73e:	14040c63          	beqz	s0,ffffffffc020b896 <vprintfmt+0x348>
ffffffffc020b742:	11805063          	blez	s8,ffffffffc020b842 <vprintfmt+0x2f4>
ffffffffc020b746:	02d00693          	li	a3,45
ffffffffc020b74a:	0cd81963          	bne	a6,a3,ffffffffc020b81c <vprintfmt+0x2ce>
ffffffffc020b74e:	00044683          	lbu	a3,0(s0)
ffffffffc020b752:	0006851b          	sext.w	a0,a3
ffffffffc020b756:	ce8d                	beqz	a3,ffffffffc020b790 <vprintfmt+0x242>
ffffffffc020b758:	00140a93          	addi	s5,s0,1
ffffffffc020b75c:	05e00413          	li	s0,94
ffffffffc020b760:	000cc563          	bltz	s9,ffffffffc020b76a <vprintfmt+0x21c>
ffffffffc020b764:	3cfd                	addiw	s9,s9,-1
ffffffffc020b766:	037c8363          	beq	s9,s7,ffffffffc020b78c <vprintfmt+0x23e>
ffffffffc020b76a:	864a                	mv	a2,s2
ffffffffc020b76c:	85a6                	mv	a1,s1
ffffffffc020b76e:	100d0663          	beqz	s10,ffffffffc020b87a <vprintfmt+0x32c>
ffffffffc020b772:	3681                	addiw	a3,a3,-32
ffffffffc020b774:	10d47363          	bgeu	s0,a3,ffffffffc020b87a <vprintfmt+0x32c>
ffffffffc020b778:	03f00513          	li	a0,63
ffffffffc020b77c:	9982                	jalr	s3
ffffffffc020b77e:	000ac683          	lbu	a3,0(s5)
ffffffffc020b782:	3c7d                	addiw	s8,s8,-1
ffffffffc020b784:	0a85                	addi	s5,s5,1
ffffffffc020b786:	0006851b          	sext.w	a0,a3
ffffffffc020b78a:	faf9                	bnez	a3,ffffffffc020b760 <vprintfmt+0x212>
ffffffffc020b78c:	01805a63          	blez	s8,ffffffffc020b7a0 <vprintfmt+0x252>
ffffffffc020b790:	3c7d                	addiw	s8,s8,-1
ffffffffc020b792:	864a                	mv	a2,s2
ffffffffc020b794:	85a6                	mv	a1,s1
ffffffffc020b796:	02000513          	li	a0,32
ffffffffc020b79a:	9982                	jalr	s3
ffffffffc020b79c:	fe0c1ae3          	bnez	s8,ffffffffc020b790 <vprintfmt+0x242>
ffffffffc020b7a0:	6a82                	ld	s5,0(sp)
ffffffffc020b7a2:	b3c5                	j	ffffffffc020b582 <vprintfmt+0x34>
ffffffffc020b7a4:	4705                	li	a4,1
ffffffffc020b7a6:	008a8d13          	addi	s10,s5,8
ffffffffc020b7aa:	00674463          	blt	a4,t1,ffffffffc020b7b2 <vprintfmt+0x264>
ffffffffc020b7ae:	0a030463          	beqz	t1,ffffffffc020b856 <vprintfmt+0x308>
ffffffffc020b7b2:	000ab403          	ld	s0,0(s5)
ffffffffc020b7b6:	0c044463          	bltz	s0,ffffffffc020b87e <vprintfmt+0x330>
ffffffffc020b7ba:	86a2                	mv	a3,s0
ffffffffc020b7bc:	8aea                	mv	s5,s10
ffffffffc020b7be:	4729                	li	a4,10
ffffffffc020b7c0:	b5d5                	j	ffffffffc020b6a4 <vprintfmt+0x156>
ffffffffc020b7c2:	000aa783          	lw	a5,0(s5)
ffffffffc020b7c6:	46e5                	li	a3,25
ffffffffc020b7c8:	0aa1                	addi	s5,s5,8
ffffffffc020b7ca:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc020b7ce:	8fb9                	xor	a5,a5,a4
ffffffffc020b7d0:	40e7873b          	subw	a4,a5,a4
ffffffffc020b7d4:	02e6c663          	blt	a3,a4,ffffffffc020b800 <vprintfmt+0x2b2>
ffffffffc020b7d8:	00371793          	slli	a5,a4,0x3
ffffffffc020b7dc:	00004697          	auipc	a3,0x4
ffffffffc020b7e0:	52468693          	addi	a3,a3,1316 # ffffffffc020fd00 <error_string>
ffffffffc020b7e4:	97b6                	add	a5,a5,a3
ffffffffc020b7e6:	639c                	ld	a5,0(a5)
ffffffffc020b7e8:	cf81                	beqz	a5,ffffffffc020b800 <vprintfmt+0x2b2>
ffffffffc020b7ea:	873e                	mv	a4,a5
ffffffffc020b7ec:	00000697          	auipc	a3,0x0
ffffffffc020b7f0:	2ac68693          	addi	a3,a3,684 # ffffffffc020ba98 <etext+0x2a>
ffffffffc020b7f4:	8626                	mv	a2,s1
ffffffffc020b7f6:	85ca                	mv	a1,s2
ffffffffc020b7f8:	854e                	mv	a0,s3
ffffffffc020b7fa:	0d4000ef          	jal	ra,ffffffffc020b8ce <printfmt>
ffffffffc020b7fe:	b351                	j	ffffffffc020b582 <vprintfmt+0x34>
ffffffffc020b800:	00004697          	auipc	a3,0x4
ffffffffc020b804:	1c068693          	addi	a3,a3,448 # ffffffffc020f9c0 <sfs_node_fileops+0x170>
ffffffffc020b808:	8626                	mv	a2,s1
ffffffffc020b80a:	85ca                	mv	a1,s2
ffffffffc020b80c:	854e                	mv	a0,s3
ffffffffc020b80e:	0c0000ef          	jal	ra,ffffffffc020b8ce <printfmt>
ffffffffc020b812:	bb85                	j	ffffffffc020b582 <vprintfmt+0x34>
ffffffffc020b814:	00004417          	auipc	s0,0x4
ffffffffc020b818:	1a440413          	addi	s0,s0,420 # ffffffffc020f9b8 <sfs_node_fileops+0x168>
ffffffffc020b81c:	85e6                	mv	a1,s9
ffffffffc020b81e:	8522                	mv	a0,s0
ffffffffc020b820:	e442                	sd	a6,8(sp)
ffffffffc020b822:	132000ef          	jal	ra,ffffffffc020b954 <strnlen>
ffffffffc020b826:	40ac0c3b          	subw	s8,s8,a0
ffffffffc020b82a:	01805c63          	blez	s8,ffffffffc020b842 <vprintfmt+0x2f4>
ffffffffc020b82e:	6822                	ld	a6,8(sp)
ffffffffc020b830:	00080a9b          	sext.w	s5,a6
ffffffffc020b834:	3c7d                	addiw	s8,s8,-1
ffffffffc020b836:	864a                	mv	a2,s2
ffffffffc020b838:	85a6                	mv	a1,s1
ffffffffc020b83a:	8556                	mv	a0,s5
ffffffffc020b83c:	9982                	jalr	s3
ffffffffc020b83e:	fe0c1be3          	bnez	s8,ffffffffc020b834 <vprintfmt+0x2e6>
ffffffffc020b842:	00044683          	lbu	a3,0(s0)
ffffffffc020b846:	00140a93          	addi	s5,s0,1
ffffffffc020b84a:	0006851b          	sext.w	a0,a3
ffffffffc020b84e:	daa9                	beqz	a3,ffffffffc020b7a0 <vprintfmt+0x252>
ffffffffc020b850:	05e00413          	li	s0,94
ffffffffc020b854:	b731                	j	ffffffffc020b760 <vprintfmt+0x212>
ffffffffc020b856:	000aa403          	lw	s0,0(s5)
ffffffffc020b85a:	bfb1                	j	ffffffffc020b7b6 <vprintfmt+0x268>
ffffffffc020b85c:	000ae683          	lwu	a3,0(s5)
ffffffffc020b860:	4721                	li	a4,8
ffffffffc020b862:	8ab2                	mv	s5,a2
ffffffffc020b864:	b581                	j	ffffffffc020b6a4 <vprintfmt+0x156>
ffffffffc020b866:	000ae683          	lwu	a3,0(s5)
ffffffffc020b86a:	4729                	li	a4,10
ffffffffc020b86c:	8ab2                	mv	s5,a2
ffffffffc020b86e:	bd1d                	j	ffffffffc020b6a4 <vprintfmt+0x156>
ffffffffc020b870:	000ae683          	lwu	a3,0(s5)
ffffffffc020b874:	4741                	li	a4,16
ffffffffc020b876:	8ab2                	mv	s5,a2
ffffffffc020b878:	b535                	j	ffffffffc020b6a4 <vprintfmt+0x156>
ffffffffc020b87a:	9982                	jalr	s3
ffffffffc020b87c:	b709                	j	ffffffffc020b77e <vprintfmt+0x230>
ffffffffc020b87e:	864a                	mv	a2,s2
ffffffffc020b880:	85a6                	mv	a1,s1
ffffffffc020b882:	02d00513          	li	a0,45
ffffffffc020b886:	e042                	sd	a6,0(sp)
ffffffffc020b888:	9982                	jalr	s3
ffffffffc020b88a:	6802                	ld	a6,0(sp)
ffffffffc020b88c:	8aea                	mv	s5,s10
ffffffffc020b88e:	408006b3          	neg	a3,s0
ffffffffc020b892:	4729                	li	a4,10
ffffffffc020b894:	bd01                	j	ffffffffc020b6a4 <vprintfmt+0x156>
ffffffffc020b896:	03805163          	blez	s8,ffffffffc020b8b8 <vprintfmt+0x36a>
ffffffffc020b89a:	02d00693          	li	a3,45
ffffffffc020b89e:	f6d81be3          	bne	a6,a3,ffffffffc020b814 <vprintfmt+0x2c6>
ffffffffc020b8a2:	00004417          	auipc	s0,0x4
ffffffffc020b8a6:	11640413          	addi	s0,s0,278 # ffffffffc020f9b8 <sfs_node_fileops+0x168>
ffffffffc020b8aa:	02800693          	li	a3,40
ffffffffc020b8ae:	02800513          	li	a0,40
ffffffffc020b8b2:	00140a93          	addi	s5,s0,1
ffffffffc020b8b6:	b55d                	j	ffffffffc020b75c <vprintfmt+0x20e>
ffffffffc020b8b8:	00004a97          	auipc	s5,0x4
ffffffffc020b8bc:	101a8a93          	addi	s5,s5,257 # ffffffffc020f9b9 <sfs_node_fileops+0x169>
ffffffffc020b8c0:	02800513          	li	a0,40
ffffffffc020b8c4:	02800693          	li	a3,40
ffffffffc020b8c8:	05e00413          	li	s0,94
ffffffffc020b8cc:	bd51                	j	ffffffffc020b760 <vprintfmt+0x212>

ffffffffc020b8ce <printfmt>:
ffffffffc020b8ce:	7139                	addi	sp,sp,-64
ffffffffc020b8d0:	02010313          	addi	t1,sp,32
ffffffffc020b8d4:	f03a                	sd	a4,32(sp)
ffffffffc020b8d6:	871a                	mv	a4,t1
ffffffffc020b8d8:	ec06                	sd	ra,24(sp)
ffffffffc020b8da:	f43e                	sd	a5,40(sp)
ffffffffc020b8dc:	f842                	sd	a6,48(sp)
ffffffffc020b8de:	fc46                	sd	a7,56(sp)
ffffffffc020b8e0:	e41a                	sd	t1,8(sp)
ffffffffc020b8e2:	c6dff0ef          	jal	ra,ffffffffc020b54e <vprintfmt>
ffffffffc020b8e6:	60e2                	ld	ra,24(sp)
ffffffffc020b8e8:	6121                	addi	sp,sp,64
ffffffffc020b8ea:	8082                	ret

ffffffffc020b8ec <snprintf>:
ffffffffc020b8ec:	711d                	addi	sp,sp,-96
ffffffffc020b8ee:	15fd                	addi	a1,a1,-1
ffffffffc020b8f0:	03810313          	addi	t1,sp,56
ffffffffc020b8f4:	95aa                	add	a1,a1,a0
ffffffffc020b8f6:	f406                	sd	ra,40(sp)
ffffffffc020b8f8:	fc36                	sd	a3,56(sp)
ffffffffc020b8fa:	e0ba                	sd	a4,64(sp)
ffffffffc020b8fc:	e4be                	sd	a5,72(sp)
ffffffffc020b8fe:	e8c2                	sd	a6,80(sp)
ffffffffc020b900:	ecc6                	sd	a7,88(sp)
ffffffffc020b902:	e01a                	sd	t1,0(sp)
ffffffffc020b904:	e42a                	sd	a0,8(sp)
ffffffffc020b906:	e82e                	sd	a1,16(sp)
ffffffffc020b908:	cc02                	sw	zero,24(sp)
ffffffffc020b90a:	c515                	beqz	a0,ffffffffc020b936 <snprintf+0x4a>
ffffffffc020b90c:	02a5e563          	bltu	a1,a0,ffffffffc020b936 <snprintf+0x4a>
ffffffffc020b910:	75dd                	lui	a1,0xffff7
ffffffffc020b912:	86b2                	mv	a3,a2
ffffffffc020b914:	00000517          	auipc	a0,0x0
ffffffffc020b918:	c2050513          	addi	a0,a0,-992 # ffffffffc020b534 <sprintputch>
ffffffffc020b91c:	871a                	mv	a4,t1
ffffffffc020b91e:	0030                	addi	a2,sp,8
ffffffffc020b920:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc020b924:	c2bff0ef          	jal	ra,ffffffffc020b54e <vprintfmt>
ffffffffc020b928:	67a2                	ld	a5,8(sp)
ffffffffc020b92a:	00078023          	sb	zero,0(a5)
ffffffffc020b92e:	4562                	lw	a0,24(sp)
ffffffffc020b930:	70a2                	ld	ra,40(sp)
ffffffffc020b932:	6125                	addi	sp,sp,96
ffffffffc020b934:	8082                	ret
ffffffffc020b936:	5575                	li	a0,-3
ffffffffc020b938:	bfe5                	j	ffffffffc020b930 <snprintf+0x44>

ffffffffc020b93a <strlen>:
ffffffffc020b93a:	00054783          	lbu	a5,0(a0)
ffffffffc020b93e:	872a                	mv	a4,a0
ffffffffc020b940:	4501                	li	a0,0
ffffffffc020b942:	cb81                	beqz	a5,ffffffffc020b952 <strlen+0x18>
ffffffffc020b944:	0505                	addi	a0,a0,1
ffffffffc020b946:	00a707b3          	add	a5,a4,a0
ffffffffc020b94a:	0007c783          	lbu	a5,0(a5)
ffffffffc020b94e:	fbfd                	bnez	a5,ffffffffc020b944 <strlen+0xa>
ffffffffc020b950:	8082                	ret
ffffffffc020b952:	8082                	ret

ffffffffc020b954 <strnlen>:
ffffffffc020b954:	4781                	li	a5,0
ffffffffc020b956:	e589                	bnez	a1,ffffffffc020b960 <strnlen+0xc>
ffffffffc020b958:	a811                	j	ffffffffc020b96c <strnlen+0x18>
ffffffffc020b95a:	0785                	addi	a5,a5,1
ffffffffc020b95c:	00f58863          	beq	a1,a5,ffffffffc020b96c <strnlen+0x18>
ffffffffc020b960:	00f50733          	add	a4,a0,a5
ffffffffc020b964:	00074703          	lbu	a4,0(a4)
ffffffffc020b968:	fb6d                	bnez	a4,ffffffffc020b95a <strnlen+0x6>
ffffffffc020b96a:	85be                	mv	a1,a5
ffffffffc020b96c:	852e                	mv	a0,a1
ffffffffc020b96e:	8082                	ret

ffffffffc020b970 <strcpy>:
ffffffffc020b970:	87aa                	mv	a5,a0
ffffffffc020b972:	0005c703          	lbu	a4,0(a1)
ffffffffc020b976:	0785                	addi	a5,a5,1
ffffffffc020b978:	0585                	addi	a1,a1,1
ffffffffc020b97a:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020b97e:	fb75                	bnez	a4,ffffffffc020b972 <strcpy+0x2>
ffffffffc020b980:	8082                	ret

ffffffffc020b982 <strcat>:
ffffffffc020b982:	00054783          	lbu	a5,0(a0)
ffffffffc020b986:	86aa                	mv	a3,a0
ffffffffc020b988:	cb81                	beqz	a5,ffffffffc020b998 <strcat+0x16>
ffffffffc020b98a:	4781                	li	a5,0
ffffffffc020b98c:	0785                	addi	a5,a5,1
ffffffffc020b98e:	00f68533          	add	a0,a3,a5
ffffffffc020b992:	00054703          	lbu	a4,0(a0)
ffffffffc020b996:	fb7d                	bnez	a4,ffffffffc020b98c <strcat+0xa>
ffffffffc020b998:	87aa                	mv	a5,a0
ffffffffc020b99a:	0005c703          	lbu	a4,0(a1)
ffffffffc020b99e:	0785                	addi	a5,a5,1
ffffffffc020b9a0:	0585                	addi	a1,a1,1
ffffffffc020b9a2:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020b9a6:	fb75                	bnez	a4,ffffffffc020b99a <strcat+0x18>
ffffffffc020b9a8:	8082                	ret

ffffffffc020b9aa <strcmp>:
ffffffffc020b9aa:	00054783          	lbu	a5,0(a0)
ffffffffc020b9ae:	0005c703          	lbu	a4,0(a1)
ffffffffc020b9b2:	cb89                	beqz	a5,ffffffffc020b9c4 <strcmp+0x1a>
ffffffffc020b9b4:	0505                	addi	a0,a0,1
ffffffffc020b9b6:	0585                	addi	a1,a1,1
ffffffffc020b9b8:	fee789e3          	beq	a5,a4,ffffffffc020b9aa <strcmp>
ffffffffc020b9bc:	0007851b          	sext.w	a0,a5
ffffffffc020b9c0:	9d19                	subw	a0,a0,a4
ffffffffc020b9c2:	8082                	ret
ffffffffc020b9c4:	4501                	li	a0,0
ffffffffc020b9c6:	bfed                	j	ffffffffc020b9c0 <strcmp+0x16>

ffffffffc020b9c8 <strncmp>:
ffffffffc020b9c8:	c20d                	beqz	a2,ffffffffc020b9ea <strncmp+0x22>
ffffffffc020b9ca:	962e                	add	a2,a2,a1
ffffffffc020b9cc:	a031                	j	ffffffffc020b9d8 <strncmp+0x10>
ffffffffc020b9ce:	0505                	addi	a0,a0,1
ffffffffc020b9d0:	00e79a63          	bne	a5,a4,ffffffffc020b9e4 <strncmp+0x1c>
ffffffffc020b9d4:	00b60b63          	beq	a2,a1,ffffffffc020b9ea <strncmp+0x22>
ffffffffc020b9d8:	00054783          	lbu	a5,0(a0)
ffffffffc020b9dc:	0585                	addi	a1,a1,1
ffffffffc020b9de:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020b9e2:	f7f5                	bnez	a5,ffffffffc020b9ce <strncmp+0x6>
ffffffffc020b9e4:	40e7853b          	subw	a0,a5,a4
ffffffffc020b9e8:	8082                	ret
ffffffffc020b9ea:	4501                	li	a0,0
ffffffffc020b9ec:	8082                	ret

ffffffffc020b9ee <strchr>:
ffffffffc020b9ee:	00054783          	lbu	a5,0(a0)
ffffffffc020b9f2:	c799                	beqz	a5,ffffffffc020ba00 <strchr+0x12>
ffffffffc020b9f4:	00f58763          	beq	a1,a5,ffffffffc020ba02 <strchr+0x14>
ffffffffc020b9f8:	00154783          	lbu	a5,1(a0)
ffffffffc020b9fc:	0505                	addi	a0,a0,1
ffffffffc020b9fe:	fbfd                	bnez	a5,ffffffffc020b9f4 <strchr+0x6>
ffffffffc020ba00:	4501                	li	a0,0
ffffffffc020ba02:	8082                	ret

ffffffffc020ba04 <memset>:
ffffffffc020ba04:	ca01                	beqz	a2,ffffffffc020ba14 <memset+0x10>
ffffffffc020ba06:	962a                	add	a2,a2,a0
ffffffffc020ba08:	87aa                	mv	a5,a0
ffffffffc020ba0a:	0785                	addi	a5,a5,1
ffffffffc020ba0c:	feb78fa3          	sb	a1,-1(a5)
ffffffffc020ba10:	fec79de3          	bne	a5,a2,ffffffffc020ba0a <memset+0x6>
ffffffffc020ba14:	8082                	ret

ffffffffc020ba16 <memmove>:
ffffffffc020ba16:	02a5f263          	bgeu	a1,a0,ffffffffc020ba3a <memmove+0x24>
ffffffffc020ba1a:	00c587b3          	add	a5,a1,a2
ffffffffc020ba1e:	00f57e63          	bgeu	a0,a5,ffffffffc020ba3a <memmove+0x24>
ffffffffc020ba22:	00c50733          	add	a4,a0,a2
ffffffffc020ba26:	c615                	beqz	a2,ffffffffc020ba52 <memmove+0x3c>
ffffffffc020ba28:	fff7c683          	lbu	a3,-1(a5)
ffffffffc020ba2c:	17fd                	addi	a5,a5,-1
ffffffffc020ba2e:	177d                	addi	a4,a4,-1
ffffffffc020ba30:	00d70023          	sb	a3,0(a4)
ffffffffc020ba34:	fef59ae3          	bne	a1,a5,ffffffffc020ba28 <memmove+0x12>
ffffffffc020ba38:	8082                	ret
ffffffffc020ba3a:	00c586b3          	add	a3,a1,a2
ffffffffc020ba3e:	87aa                	mv	a5,a0
ffffffffc020ba40:	ca11                	beqz	a2,ffffffffc020ba54 <memmove+0x3e>
ffffffffc020ba42:	0005c703          	lbu	a4,0(a1)
ffffffffc020ba46:	0585                	addi	a1,a1,1
ffffffffc020ba48:	0785                	addi	a5,a5,1
ffffffffc020ba4a:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020ba4e:	fed59ae3          	bne	a1,a3,ffffffffc020ba42 <memmove+0x2c>
ffffffffc020ba52:	8082                	ret
ffffffffc020ba54:	8082                	ret

ffffffffc020ba56 <memcpy>:
ffffffffc020ba56:	ca19                	beqz	a2,ffffffffc020ba6c <memcpy+0x16>
ffffffffc020ba58:	962e                	add	a2,a2,a1
ffffffffc020ba5a:	87aa                	mv	a5,a0
ffffffffc020ba5c:	0005c703          	lbu	a4,0(a1)
ffffffffc020ba60:	0585                	addi	a1,a1,1
ffffffffc020ba62:	0785                	addi	a5,a5,1
ffffffffc020ba64:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020ba68:	fec59ae3          	bne	a1,a2,ffffffffc020ba5c <memcpy+0x6>
ffffffffc020ba6c:	8082                	ret
