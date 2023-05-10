
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 70 12 f0       	mov    $0xf0127000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 61 00 00 00       	call   f010009f <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	if (panicstr)
f0100047:	83 3d 00 c0 2b f0 00 	cmpl   $0x0,0xf02bc000
f010004e:	74 0f                	je     f010005f <_panic+0x1f>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100050:	83 ec 0c             	sub    $0xc,%esp
f0100053:	6a 00                	push   $0x0
f0100055:	e8 15 09 00 00       	call   f010096f <monitor>
f010005a:	83 c4 10             	add    $0x10,%esp
f010005d:	eb f1                	jmp    f0100050 <_panic+0x10>
	panicstr = fmt;
f010005f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100062:	a3 00 c0 2b f0       	mov    %eax,0xf02bc000
	asm volatile("cli; cld");
f0100067:	fa                   	cli    
f0100068:	fc                   	cld    
	va_start(ap, fmt);
f0100069:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006c:	e8 73 60 00 00       	call   f01060e4 <cpunum>
f0100071:	ff 75 0c             	push   0xc(%ebp)
f0100074:	ff 75 08             	push   0x8(%ebp)
f0100077:	50                   	push   %eax
f0100078:	68 c0 6f 10 f0       	push   $0xf0106fc0
f010007d:	e8 4f 3a 00 00       	call   f0103ad1 <cprintf>
	vcprintf(fmt, ap);
f0100082:	83 c4 08             	add    $0x8,%esp
f0100085:	53                   	push   %ebx
f0100086:	ff 75 10             	push   0x10(%ebp)
f0100089:	e8 1d 3a 00 00       	call   f0103aab <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 33 78 10 f0 	movl   $0xf0107833,(%esp)
f0100095:	e8 37 3a 00 00       	call   f0103ad1 <cprintf>
f010009a:	83 c4 10             	add    $0x10,%esp
f010009d:	eb b1                	jmp    f0100050 <_panic+0x10>

f010009f <i386_init>:
{
f010009f:	55                   	push   %ebp
f01000a0:	89 e5                	mov    %esp,%ebp
f01000a2:	53                   	push   %ebx
f01000a3:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000a6:	e8 90 05 00 00       	call   f010063b <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ab:	83 ec 08             	sub    $0x8,%esp
f01000ae:	68 ac 1a 00 00       	push   $0x1aac
f01000b3:	68 2c 70 10 f0       	push   $0xf010702c
f01000b8:	e8 14 3a 00 00       	call   f0103ad1 <cprintf>
	mem_init();
f01000bd:	e8 5c 12 00 00       	call   f010131e <mem_init>
	env_init();
f01000c2:	e8 d8 30 00 00       	call   f010319f <env_init>
	trap_init();
f01000c7:	e8 f7 3a 00 00       	call   f0103bc3 <trap_init>
	mp_init();
f01000cc:	e8 2d 5d 00 00       	call   f0105dfe <mp_init>
	lapic_init();
f01000d1:	e8 24 60 00 00       	call   f01060fa <lapic_init>
	pic_init();
f01000d6:	e8 05 39 00 00       	call   f01039e0 <pic_init>
	time_init();
f01000db:	e8 49 6c 00 00       	call   f0106d29 <time_init>
	pci_init();
f01000e0:	e8 24 6c 00 00       	call   f0106d09 <pci_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000e5:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f01000ec:	e8 63 62 00 00       	call   f0106354 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f1:	83 c4 10             	add    $0x10,%esp
f01000f4:	83 3d 60 c2 2b f0 07 	cmpl   $0x7,0xf02bc260
f01000fb:	76 27                	jbe    f0100124 <i386_init+0x85>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000fd:	83 ec 04             	sub    $0x4,%esp
f0100100:	b8 5a 5d 10 f0       	mov    $0xf0105d5a,%eax
f0100105:	2d e0 5c 10 f0       	sub    $0xf0105ce0,%eax
f010010a:	50                   	push   %eax
f010010b:	68 e0 5c 10 f0       	push   $0xf0105ce0
f0100110:	68 00 70 00 f0       	push   $0xf0007000
f0100115:	e8 19 5a 00 00       	call   f0105b33 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f010011a:	83 c4 10             	add    $0x10,%esp
f010011d:	bb 20 d0 2f f0       	mov    $0xf02fd020,%ebx
f0100122:	eb 19                	jmp    f010013d <i386_init+0x9e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100124:	68 00 70 00 00       	push   $0x7000
f0100129:	68 e4 6f 10 f0       	push   $0xf0106fe4
f010012e:	6a 69                	push   $0x69
f0100130:	68 47 70 10 f0       	push   $0xf0107047
f0100135:	e8 06 ff ff ff       	call   f0100040 <_panic>
f010013a:	83 c3 74             	add    $0x74,%ebx
f010013d:	6b 05 00 d0 2f f0 74 	imul   $0x74,0xf02fd000,%eax
f0100144:	05 20 d0 2f f0       	add    $0xf02fd020,%eax
f0100149:	39 c3                	cmp    %eax,%ebx
f010014b:	73 4d                	jae    f010019a <i386_init+0xfb>
		if (c == cpus + cpunum())  // We've started already.
f010014d:	e8 92 5f 00 00       	call   f01060e4 <cpunum>
f0100152:	6b c0 74             	imul   $0x74,%eax,%eax
f0100155:	05 20 d0 2f f0       	add    $0xf02fd020,%eax
f010015a:	39 c3                	cmp    %eax,%ebx
f010015c:	74 dc                	je     f010013a <i386_init+0x9b>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010015e:	89 d8                	mov    %ebx,%eax
f0100160:	2d 20 d0 2f f0       	sub    $0xf02fd020,%eax
f0100165:	c1 f8 02             	sar    $0x2,%eax
f0100168:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010016e:	c1 e0 0f             	shl    $0xf,%eax
f0100171:	8d 80 00 50 2c f0    	lea    -0xfd3b000(%eax),%eax
f0100177:	a3 04 c0 2b f0       	mov    %eax,0xf02bc004
		lapic_startap(c->cpu_id, PADDR(code));
f010017c:	83 ec 08             	sub    $0x8,%esp
f010017f:	68 00 70 00 00       	push   $0x7000
f0100184:	0f b6 03             	movzbl (%ebx),%eax
f0100187:	50                   	push   %eax
f0100188:	e8 bf 60 00 00       	call   f010624c <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f010018d:	83 c4 10             	add    $0x10,%esp
f0100190:	8b 43 04             	mov    0x4(%ebx),%eax
f0100193:	83 f8 01             	cmp    $0x1,%eax
f0100196:	75 f8                	jne    f0100190 <i386_init+0xf1>
f0100198:	eb a0                	jmp    f010013a <i386_init+0x9b>
	ENV_CREATE(user_MFQtest, ENV_TYPE_USER);
f010019a:	83 ec 08             	sub    $0x8,%esp
f010019d:	6a 00                	push   $0x0
f010019f:	68 78 69 2b f0       	push   $0xf02b6978
f01001a4:	e8 ed 31 00 00       	call   f0103396 <env_create>
	kbd_intr();
f01001a9:	e8 39 04 00 00       	call   f01005e7 <kbd_intr>
	sched_yield();
f01001ae:	e8 fb 45 00 00       	call   f01047ae <sched_yield>

f01001b3 <mp_main>:
{
f01001b3:	55                   	push   %ebp
f01001b4:	89 e5                	mov    %esp,%ebp
f01001b6:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001b9:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001be:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c3:	76 52                	jbe    f0100217 <mp_main+0x64>
	return (physaddr_t)kva - KERNBASE;
f01001c5:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f01001ca:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001cd:	e8 12 5f 00 00       	call   f01060e4 <cpunum>
f01001d2:	83 ec 08             	sub    $0x8,%esp
f01001d5:	50                   	push   %eax
f01001d6:	68 53 70 10 f0       	push   $0xf0107053
f01001db:	e8 f1 38 00 00       	call   f0103ad1 <cprintf>
	lapic_init();
f01001e0:	e8 15 5f 00 00       	call   f01060fa <lapic_init>
	env_init_percpu();
f01001e5:	e8 89 2f 00 00       	call   f0103173 <env_init_percpu>
	trap_init_percpu();
f01001ea:	e8 f6 38 00 00       	call   f0103ae5 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001ef:	e8 f0 5e 00 00       	call   f01060e4 <cpunum>
f01001f4:	6b d0 74             	imul   $0x74,%eax,%edx
f01001f7:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001fa:	b8 01 00 00 00       	mov    $0x1,%eax
f01001ff:	f0 87 82 20 d0 2f f0 	lock xchg %eax,-0xfd02fe0(%edx)
f0100206:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f010020d:	e8 42 61 00 00       	call   f0106354 <spin_lock>
	sched_yield();
f0100212:	e8 97 45 00 00       	call   f01047ae <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100217:	50                   	push   %eax
f0100218:	68 08 70 10 f0       	push   $0xf0107008
f010021d:	68 80 00 00 00       	push   $0x80
f0100222:	68 47 70 10 f0       	push   $0xf0107047
f0100227:	e8 14 fe ff ff       	call   f0100040 <_panic>

f010022c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010022c:	55                   	push   %ebp
f010022d:	89 e5                	mov    %esp,%ebp
f010022f:	53                   	push   %ebx
f0100230:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100233:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100236:	ff 75 0c             	push   0xc(%ebp)
f0100239:	ff 75 08             	push   0x8(%ebp)
f010023c:	68 69 70 10 f0       	push   $0xf0107069
f0100241:	e8 8b 38 00 00       	call   f0103ad1 <cprintf>
	vcprintf(fmt, ap);
f0100246:	83 c4 08             	add    $0x8,%esp
f0100249:	53                   	push   %ebx
f010024a:	ff 75 10             	push   0x10(%ebp)
f010024d:	e8 59 38 00 00       	call   f0103aab <vcprintf>
	cprintf("\n");
f0100252:	c7 04 24 33 78 10 f0 	movl   $0xf0107833,(%esp)
f0100259:	e8 73 38 00 00       	call   f0103ad1 <cprintf>
	va_end(ap);
}
f010025e:	83 c4 10             	add    $0x10,%esp
f0100261:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100264:	c9                   	leave  
f0100265:	c3                   	ret    

f0100266 <serial_proc_data>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100266:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026b:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026c:	a8 01                	test   $0x1,%al
f010026e:	74 0a                	je     f010027a <serial_proc_data+0x14>
f0100270:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100275:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100276:	0f b6 c0             	movzbl %al,%eax
f0100279:	c3                   	ret    
		return -1;
f010027a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010027f:	c3                   	ret    

f0100280 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100280:	55                   	push   %ebp
f0100281:	89 e5                	mov    %esp,%ebp
f0100283:	53                   	push   %ebx
f0100284:	83 ec 04             	sub    $0x4,%esp
f0100287:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100289:	eb 23                	jmp    f01002ae <cons_intr+0x2e>
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f010028b:	8b 0d 44 c2 2b f0    	mov    0xf02bc244,%ecx
f0100291:	8d 51 01             	lea    0x1(%ecx),%edx
f0100294:	88 81 40 c0 2b f0    	mov    %al,-0xfd43fc0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010029a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01002a5:	0f 44 d0             	cmove  %eax,%edx
f01002a8:	89 15 44 c2 2b f0    	mov    %edx,0xf02bc244
	while ((c = (*proc)()) != -1) {
f01002ae:	ff d3                	call   *%ebx
f01002b0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002b3:	74 06                	je     f01002bb <cons_intr+0x3b>
		if (c == 0)
f01002b5:	85 c0                	test   %eax,%eax
f01002b7:	75 d2                	jne    f010028b <cons_intr+0xb>
f01002b9:	eb f3                	jmp    f01002ae <cons_intr+0x2e>
	}
}
f01002bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002be:	c9                   	leave  
f01002bf:	c3                   	ret    

f01002c0 <kbd_proc_data>:
{
f01002c0:	55                   	push   %ebp
f01002c1:	89 e5                	mov    %esp,%ebp
f01002c3:	53                   	push   %ebx
f01002c4:	83 ec 04             	sub    $0x4,%esp
f01002c7:	ba 64 00 00 00       	mov    $0x64,%edx
f01002cc:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002cd:	a8 01                	test   $0x1,%al
f01002cf:	0f 84 ee 00 00 00    	je     f01003c3 <kbd_proc_data+0x103>
	if (stat & KBS_TERR)
f01002d5:	a8 20                	test   $0x20,%al
f01002d7:	0f 85 ed 00 00 00    	jne    f01003ca <kbd_proc_data+0x10a>
f01002dd:	ba 60 00 00 00       	mov    $0x60,%edx
f01002e2:	ec                   	in     (%dx),%al
f01002e3:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002e5:	3c e0                	cmp    $0xe0,%al
f01002e7:	74 61                	je     f010034a <kbd_proc_data+0x8a>
	} else if (data & 0x80) {
f01002e9:	84 c0                	test   %al,%al
f01002eb:	78 70                	js     f010035d <kbd_proc_data+0x9d>
	} else if (shift & E0ESC) {
f01002ed:	8b 0d 20 c0 2b f0    	mov    0xf02bc020,%ecx
f01002f3:	f6 c1 40             	test   $0x40,%cl
f01002f6:	74 0e                	je     f0100306 <kbd_proc_data+0x46>
		data |= 0x80;
f01002f8:	83 c8 80             	or     $0xffffff80,%eax
f01002fb:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002fd:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100300:	89 0d 20 c0 2b f0    	mov    %ecx,0xf02bc020
	shift |= shiftcode[data];
f0100306:	0f b6 d2             	movzbl %dl,%edx
f0100309:	0f b6 82 e0 71 10 f0 	movzbl -0xfef8e20(%edx),%eax
f0100310:	0b 05 20 c0 2b f0    	or     0xf02bc020,%eax
	shift ^= togglecode[data];
f0100316:	0f b6 8a e0 70 10 f0 	movzbl -0xfef8f20(%edx),%ecx
f010031d:	31 c8                	xor    %ecx,%eax
f010031f:	a3 20 c0 2b f0       	mov    %eax,0xf02bc020
	c = charcode[shift & (CTL | SHIFT)][data];
f0100324:	89 c1                	mov    %eax,%ecx
f0100326:	83 e1 03             	and    $0x3,%ecx
f0100329:	8b 0c 8d c0 70 10 f0 	mov    -0xfef8f40(,%ecx,4),%ecx
f0100330:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100334:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100337:	a8 08                	test   $0x8,%al
f0100339:	74 5d                	je     f0100398 <kbd_proc_data+0xd8>
		if ('a' <= c && c <= 'z')
f010033b:	89 da                	mov    %ebx,%edx
f010033d:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100340:	83 f9 19             	cmp    $0x19,%ecx
f0100343:	77 47                	ja     f010038c <kbd_proc_data+0xcc>
			c += 'A' - 'a';
f0100345:	83 eb 20             	sub    $0x20,%ebx
f0100348:	eb 0c                	jmp    f0100356 <kbd_proc_data+0x96>
		shift |= E0ESC;
f010034a:	83 0d 20 c0 2b f0 40 	orl    $0x40,0xf02bc020
		return 0;
f0100351:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100356:	89 d8                	mov    %ebx,%eax
f0100358:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010035b:	c9                   	leave  
f010035c:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010035d:	8b 0d 20 c0 2b f0    	mov    0xf02bc020,%ecx
f0100363:	83 e0 7f             	and    $0x7f,%eax
f0100366:	f6 c1 40             	test   $0x40,%cl
f0100369:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010036c:	0f b6 d2             	movzbl %dl,%edx
f010036f:	0f b6 82 e0 71 10 f0 	movzbl -0xfef8e20(%edx),%eax
f0100376:	83 c8 40             	or     $0x40,%eax
f0100379:	0f b6 c0             	movzbl %al,%eax
f010037c:	f7 d0                	not    %eax
f010037e:	21 c8                	and    %ecx,%eax
f0100380:	a3 20 c0 2b f0       	mov    %eax,0xf02bc020
		return 0;
f0100385:	bb 00 00 00 00       	mov    $0x0,%ebx
f010038a:	eb ca                	jmp    f0100356 <kbd_proc_data+0x96>
		else if ('A' <= c && c <= 'Z')
f010038c:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010038f:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100392:	83 fa 1a             	cmp    $0x1a,%edx
f0100395:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100398:	f7 d0                	not    %eax
f010039a:	a8 06                	test   $0x6,%al
f010039c:	75 b8                	jne    f0100356 <kbd_proc_data+0x96>
f010039e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003a4:	75 b0                	jne    f0100356 <kbd_proc_data+0x96>
		cprintf("Rebooting!\n");
f01003a6:	83 ec 0c             	sub    $0xc,%esp
f01003a9:	68 83 70 10 f0       	push   $0xf0107083
f01003ae:	e8 1e 37 00 00       	call   f0103ad1 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b3:	b8 03 00 00 00       	mov    $0x3,%eax
f01003b8:	ba 92 00 00 00       	mov    $0x92,%edx
f01003bd:	ee                   	out    %al,(%dx)
}
f01003be:	83 c4 10             	add    $0x10,%esp
f01003c1:	eb 93                	jmp    f0100356 <kbd_proc_data+0x96>
		return -1;
f01003c3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003c8:	eb 8c                	jmp    f0100356 <kbd_proc_data+0x96>
		return -1;
f01003ca:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003cf:	eb 85                	jmp    f0100356 <kbd_proc_data+0x96>

f01003d1 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003d1:	55                   	push   %ebp
f01003d2:	89 e5                	mov    %esp,%ebp
f01003d4:	57                   	push   %edi
f01003d5:	56                   	push   %esi
f01003d6:	53                   	push   %ebx
f01003d7:	83 ec 1c             	sub    $0x1c,%esp
f01003da:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003dc:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003e1:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003e6:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003eb:	89 f2                	mov    %esi,%edx
f01003ed:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003ee:	a8 20                	test   $0x20,%al
f01003f0:	75 13                	jne    f0100405 <cons_putc+0x34>
f01003f2:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003f8:	7f 0b                	jg     f0100405 <cons_putc+0x34>
f01003fa:	89 ca                	mov    %ecx,%edx
f01003fc:	ec                   	in     (%dx),%al
f01003fd:	ec                   	in     (%dx),%al
f01003fe:	ec                   	in     (%dx),%al
f01003ff:	ec                   	in     (%dx),%al
	     i++)
f0100400:	83 c3 01             	add    $0x1,%ebx
f0100403:	eb e6                	jmp    f01003eb <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f0100405:	89 f8                	mov    %edi,%eax
f0100407:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010040a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010040f:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100410:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100415:	be 79 03 00 00       	mov    $0x379,%esi
f010041a:	b9 84 00 00 00       	mov    $0x84,%ecx
f010041f:	89 f2                	mov    %esi,%edx
f0100421:	ec                   	in     (%dx),%al
f0100422:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100428:	7f 0f                	jg     f0100439 <cons_putc+0x68>
f010042a:	84 c0                	test   %al,%al
f010042c:	78 0b                	js     f0100439 <cons_putc+0x68>
f010042e:	89 ca                	mov    %ecx,%edx
f0100430:	ec                   	in     (%dx),%al
f0100431:	ec                   	in     (%dx),%al
f0100432:	ec                   	in     (%dx),%al
f0100433:	ec                   	in     (%dx),%al
f0100434:	83 c3 01             	add    $0x1,%ebx
f0100437:	eb e6                	jmp    f010041f <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100439:	ba 78 03 00 00       	mov    $0x378,%edx
f010043e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100442:	ee                   	out    %al,(%dx)
f0100443:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100448:	b8 0d 00 00 00       	mov    $0xd,%eax
f010044d:	ee                   	out    %al,(%dx)
f010044e:	b8 08 00 00 00       	mov    $0x8,%eax
f0100453:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100454:	89 f8                	mov    %edi,%eax
f0100456:	80 cc 07             	or     $0x7,%ah
f0100459:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010045f:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100462:	89 f8                	mov    %edi,%eax
f0100464:	0f b6 c0             	movzbl %al,%eax
f0100467:	89 fb                	mov    %edi,%ebx
f0100469:	80 fb 0a             	cmp    $0xa,%bl
f010046c:	0f 84 e1 00 00 00    	je     f0100553 <cons_putc+0x182>
f0100472:	83 f8 0a             	cmp    $0xa,%eax
f0100475:	7f 46                	jg     f01004bd <cons_putc+0xec>
f0100477:	83 f8 08             	cmp    $0x8,%eax
f010047a:	0f 84 a7 00 00 00    	je     f0100527 <cons_putc+0x156>
f0100480:	83 f8 09             	cmp    $0x9,%eax
f0100483:	0f 85 d7 00 00 00    	jne    f0100560 <cons_putc+0x18f>
		cons_putc(' ');
f0100489:	b8 20 00 00 00       	mov    $0x20,%eax
f010048e:	e8 3e ff ff ff       	call   f01003d1 <cons_putc>
		cons_putc(' ');
f0100493:	b8 20 00 00 00       	mov    $0x20,%eax
f0100498:	e8 34 ff ff ff       	call   f01003d1 <cons_putc>
		cons_putc(' ');
f010049d:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a2:	e8 2a ff ff ff       	call   f01003d1 <cons_putc>
		cons_putc(' ');
f01004a7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ac:	e8 20 ff ff ff       	call   f01003d1 <cons_putc>
		cons_putc(' ');
f01004b1:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b6:	e8 16 ff ff ff       	call   f01003d1 <cons_putc>
		break;
f01004bb:	eb 25                	jmp    f01004e2 <cons_putc+0x111>
	switch (c & 0xff) {
f01004bd:	83 f8 0d             	cmp    $0xd,%eax
f01004c0:	0f 85 9a 00 00 00    	jne    f0100560 <cons_putc+0x18f>
		crt_pos -= (crt_pos % CRT_COLS);
f01004c6:	0f b7 05 48 c2 2b f0 	movzwl 0xf02bc248,%eax
f01004cd:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004d3:	c1 e8 16             	shr    $0x16,%eax
f01004d6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004d9:	c1 e0 04             	shl    $0x4,%eax
f01004dc:	66 a3 48 c2 2b f0    	mov    %ax,0xf02bc248
	if (crt_pos >= CRT_SIZE) {
f01004e2:	66 81 3d 48 c2 2b f0 	cmpw   $0x7cf,0xf02bc248
f01004e9:	cf 07 
f01004eb:	0f 87 92 00 00 00    	ja     f0100583 <cons_putc+0x1b2>
	outb(addr_6845, 14);
f01004f1:	8b 0d 50 c2 2b f0    	mov    0xf02bc250,%ecx
f01004f7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004fc:	89 ca                	mov    %ecx,%edx
f01004fe:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004ff:	0f b7 1d 48 c2 2b f0 	movzwl 0xf02bc248,%ebx
f0100506:	8d 71 01             	lea    0x1(%ecx),%esi
f0100509:	89 d8                	mov    %ebx,%eax
f010050b:	66 c1 e8 08          	shr    $0x8,%ax
f010050f:	89 f2                	mov    %esi,%edx
f0100511:	ee                   	out    %al,(%dx)
f0100512:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100517:	89 ca                	mov    %ecx,%edx
f0100519:	ee                   	out    %al,(%dx)
f010051a:	89 d8                	mov    %ebx,%eax
f010051c:	89 f2                	mov    %esi,%edx
f010051e:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010051f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100522:	5b                   	pop    %ebx
f0100523:	5e                   	pop    %esi
f0100524:	5f                   	pop    %edi
f0100525:	5d                   	pop    %ebp
f0100526:	c3                   	ret    
		if (crt_pos > 0) {
f0100527:	0f b7 05 48 c2 2b f0 	movzwl 0xf02bc248,%eax
f010052e:	66 85 c0             	test   %ax,%ax
f0100531:	74 be                	je     f01004f1 <cons_putc+0x120>
			crt_pos--;
f0100533:	83 e8 01             	sub    $0x1,%eax
f0100536:	66 a3 48 c2 2b f0    	mov    %ax,0xf02bc248
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010053c:	0f b7 c0             	movzwl %ax,%eax
f010053f:	66 81 e7 00 ff       	and    $0xff00,%di
f0100544:	83 cf 20             	or     $0x20,%edi
f0100547:	8b 15 4c c2 2b f0    	mov    0xf02bc24c,%edx
f010054d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100551:	eb 8f                	jmp    f01004e2 <cons_putc+0x111>
		crt_pos += CRT_COLS;
f0100553:	66 83 05 48 c2 2b f0 	addw   $0x50,0xf02bc248
f010055a:	50 
f010055b:	e9 66 ff ff ff       	jmp    f01004c6 <cons_putc+0xf5>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100560:	0f b7 05 48 c2 2b f0 	movzwl 0xf02bc248,%eax
f0100567:	8d 50 01             	lea    0x1(%eax),%edx
f010056a:	66 89 15 48 c2 2b f0 	mov    %dx,0xf02bc248
f0100571:	0f b7 c0             	movzwl %ax,%eax
f0100574:	8b 15 4c c2 2b f0    	mov    0xf02bc24c,%edx
f010057a:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f010057e:	e9 5f ff ff ff       	jmp    f01004e2 <cons_putc+0x111>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100583:	a1 4c c2 2b f0       	mov    0xf02bc24c,%eax
f0100588:	83 ec 04             	sub    $0x4,%esp
f010058b:	68 00 0f 00 00       	push   $0xf00
f0100590:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100596:	52                   	push   %edx
f0100597:	50                   	push   %eax
f0100598:	e8 96 55 00 00       	call   f0105b33 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010059d:	8b 15 4c c2 2b f0    	mov    0xf02bc24c,%edx
f01005a3:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005a9:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005af:	83 c4 10             	add    $0x10,%esp
f01005b2:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005b7:	83 c0 02             	add    $0x2,%eax
f01005ba:	39 d0                	cmp    %edx,%eax
f01005bc:	75 f4                	jne    f01005b2 <cons_putc+0x1e1>
		crt_pos -= CRT_COLS;
f01005be:	66 83 2d 48 c2 2b f0 	subw   $0x50,0xf02bc248
f01005c5:	50 
f01005c6:	e9 26 ff ff ff       	jmp    f01004f1 <cons_putc+0x120>

f01005cb <serial_intr>:
	if (serial_exists)
f01005cb:	80 3d 54 c2 2b f0 00 	cmpb   $0x0,0xf02bc254
f01005d2:	75 01                	jne    f01005d5 <serial_intr+0xa>
f01005d4:	c3                   	ret    
{
f01005d5:	55                   	push   %ebp
f01005d6:	89 e5                	mov    %esp,%ebp
f01005d8:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005db:	b8 66 02 10 f0       	mov    $0xf0100266,%eax
f01005e0:	e8 9b fc ff ff       	call   f0100280 <cons_intr>
}
f01005e5:	c9                   	leave  
f01005e6:	c3                   	ret    

f01005e7 <kbd_intr>:
{
f01005e7:	55                   	push   %ebp
f01005e8:	89 e5                	mov    %esp,%ebp
f01005ea:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005ed:	b8 c0 02 10 f0       	mov    $0xf01002c0,%eax
f01005f2:	e8 89 fc ff ff       	call   f0100280 <cons_intr>
}
f01005f7:	c9                   	leave  
f01005f8:	c3                   	ret    

f01005f9 <cons_getc>:
{
f01005f9:	55                   	push   %ebp
f01005fa:	89 e5                	mov    %esp,%ebp
f01005fc:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01005ff:	e8 c7 ff ff ff       	call   f01005cb <serial_intr>
	kbd_intr();
f0100604:	e8 de ff ff ff       	call   f01005e7 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100609:	a1 40 c2 2b f0       	mov    0xf02bc240,%eax
	return 0;
f010060e:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100613:	3b 05 44 c2 2b f0    	cmp    0xf02bc244,%eax
f0100619:	74 1c                	je     f0100637 <cons_getc+0x3e>
		c = cons.buf[cons.rpos++];
f010061b:	8d 48 01             	lea    0x1(%eax),%ecx
f010061e:	0f b6 90 40 c0 2b f0 	movzbl -0xfd43fc0(%eax),%edx
			cons.rpos = 0;
f0100625:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f010062a:	b8 00 00 00 00       	mov    $0x0,%eax
f010062f:	0f 45 c1             	cmovne %ecx,%eax
f0100632:	a3 40 c2 2b f0       	mov    %eax,0xf02bc240
}
f0100637:	89 d0                	mov    %edx,%eax
f0100639:	c9                   	leave  
f010063a:	c3                   	ret    

f010063b <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010063b:	55                   	push   %ebp
f010063c:	89 e5                	mov    %esp,%ebp
f010063e:	57                   	push   %edi
f010063f:	56                   	push   %esi
f0100640:	53                   	push   %ebx
f0100641:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100644:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010064b:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100652:	5a a5 
	if (*cp != 0xA55A) {
f0100654:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010065b:	bb b4 03 00 00       	mov    $0x3b4,%ebx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100660:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	if (*cp != 0xA55A) {
f0100665:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100669:	0f 84 cd 00 00 00    	je     f010073c <cons_init+0x101>
		addr_6845 = MONO_BASE;
f010066f:	89 1d 50 c2 2b f0    	mov    %ebx,0xf02bc250
f0100675:	b8 0e 00 00 00       	mov    $0xe,%eax
f010067a:	89 da                	mov    %ebx,%edx
f010067c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010067d:	8d 7b 01             	lea    0x1(%ebx),%edi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100680:	89 fa                	mov    %edi,%edx
f0100682:	ec                   	in     (%dx),%al
f0100683:	0f b6 c8             	movzbl %al,%ecx
f0100686:	c1 e1 08             	shl    $0x8,%ecx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100689:	b8 0f 00 00 00       	mov    $0xf,%eax
f010068e:	89 da                	mov    %ebx,%edx
f0100690:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100691:	89 fa                	mov    %edi,%edx
f0100693:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100694:	89 35 4c c2 2b f0    	mov    %esi,0xf02bc24c
	pos |= inb(addr_6845 + 1);
f010069a:	0f b6 c0             	movzbl %al,%eax
f010069d:	09 c8                	or     %ecx,%eax
	crt_pos = pos;
f010069f:	66 a3 48 c2 2b f0    	mov    %ax,0xf02bc248
	kbd_intr();
f01006a5:	e8 3d ff ff ff       	call   f01005e7 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006aa:	83 ec 0c             	sub    $0xc,%esp
f01006ad:	0f b7 05 a8 93 12 f0 	movzwl 0xf01293a8,%eax
f01006b4:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006b9:	50                   	push   %eax
f01006ba:	e8 9e 32 00 00       	call   f010395d <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006bf:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006c4:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01006c9:	89 c8                	mov    %ecx,%eax
f01006cb:	89 da                	mov    %ebx,%edx
f01006cd:	ee                   	out    %al,(%dx)
f01006ce:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006d3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006d8:	89 fa                	mov    %edi,%edx
f01006da:	ee                   	out    %al,(%dx)
f01006db:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006e0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006e5:	ee                   	out    %al,(%dx)
f01006e6:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006eb:	89 c8                	mov    %ecx,%eax
f01006ed:	89 f2                	mov    %esi,%edx
f01006ef:	ee                   	out    %al,(%dx)
f01006f0:	b8 03 00 00 00       	mov    $0x3,%eax
f01006f5:	89 fa                	mov    %edi,%edx
f01006f7:	ee                   	out    %al,(%dx)
f01006f8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006fd:	89 c8                	mov    %ecx,%eax
f01006ff:	ee                   	out    %al,(%dx)
f0100700:	b8 01 00 00 00       	mov    $0x1,%eax
f0100705:	89 f2                	mov    %esi,%edx
f0100707:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100708:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010070d:	ec                   	in     (%dx),%al
f010070e:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100710:	83 c4 10             	add    $0x10,%esp
f0100713:	3c ff                	cmp    $0xff,%al
f0100715:	0f 95 05 54 c2 2b f0 	setne  0xf02bc254
f010071c:	89 da                	mov    %ebx,%edx
f010071e:	ec                   	in     (%dx),%al
f010071f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100724:	ec                   	in     (%dx),%al
	if (serial_exists)
f0100725:	80 f9 ff             	cmp    $0xff,%cl
f0100728:	75 28                	jne    f0100752 <cons_init+0x117>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
		cprintf("Serial port does not exist!\n");
f010072a:	83 ec 0c             	sub    $0xc,%esp
f010072d:	68 8f 70 10 f0       	push   $0xf010708f
f0100732:	e8 9a 33 00 00       	call   f0103ad1 <cprintf>
f0100737:	83 c4 10             	add    $0x10,%esp
}
f010073a:	eb 37                	jmp    f0100773 <cons_init+0x138>
		*cp = was;
f010073c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f0100743:	bb d4 03 00 00       	mov    $0x3d4,%ebx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100748:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010074d:	e9 1d ff ff ff       	jmp    f010066f <cons_init+0x34>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100752:	83 ec 0c             	sub    $0xc,%esp
f0100755:	0f b7 05 a8 93 12 f0 	movzwl 0xf01293a8,%eax
f010075c:	25 ef ff 00 00       	and    $0xffef,%eax
f0100761:	50                   	push   %eax
f0100762:	e8 f6 31 00 00       	call   f010395d <irq_setmask_8259A>
	if (!serial_exists)
f0100767:	83 c4 10             	add    $0x10,%esp
f010076a:	80 3d 54 c2 2b f0 00 	cmpb   $0x0,0xf02bc254
f0100771:	74 b7                	je     f010072a <cons_init+0xef>
}
f0100773:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100776:	5b                   	pop    %ebx
f0100777:	5e                   	pop    %esi
f0100778:	5f                   	pop    %edi
f0100779:	5d                   	pop    %ebp
f010077a:	c3                   	ret    

f010077b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010077b:	55                   	push   %ebp
f010077c:	89 e5                	mov    %esp,%ebp
f010077e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100781:	8b 45 08             	mov    0x8(%ebp),%eax
f0100784:	e8 48 fc ff ff       	call   f01003d1 <cons_putc>
}
f0100789:	c9                   	leave  
f010078a:	c3                   	ret    

f010078b <getchar>:

int
getchar(void)
{
f010078b:	55                   	push   %ebp
f010078c:	89 e5                	mov    %esp,%ebp
f010078e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100791:	e8 63 fe ff ff       	call   f01005f9 <cons_getc>
f0100796:	85 c0                	test   %eax,%eax
f0100798:	74 f7                	je     f0100791 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010079a:	c9                   	leave  
f010079b:	c3                   	ret    

f010079c <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f010079c:	b8 01 00 00 00       	mov    $0x1,%eax
f01007a1:	c3                   	ret    

f01007a2 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007a2:	55                   	push   %ebp
f01007a3:	89 e5                	mov    %esp,%ebp
f01007a5:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007a8:	68 e0 72 10 f0       	push   $0xf01072e0
f01007ad:	68 fe 72 10 f0       	push   $0xf01072fe
f01007b2:	68 03 73 10 f0       	push   $0xf0107303
f01007b7:	e8 15 33 00 00       	call   f0103ad1 <cprintf>
f01007bc:	83 c4 0c             	add    $0xc,%esp
f01007bf:	68 a4 73 10 f0       	push   $0xf01073a4
f01007c4:	68 0c 73 10 f0       	push   $0xf010730c
f01007c9:	68 03 73 10 f0       	push   $0xf0107303
f01007ce:	e8 fe 32 00 00       	call   f0103ad1 <cprintf>
	return 0;
}
f01007d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01007d8:	c9                   	leave  
f01007d9:	c3                   	ret    

f01007da <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007da:	55                   	push   %ebp
f01007db:	89 e5                	mov    %esp,%ebp
f01007dd:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007e0:	68 15 73 10 f0       	push   $0xf0107315
f01007e5:	e8 e7 32 00 00       	call   f0103ad1 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ea:	83 c4 08             	add    $0x8,%esp
f01007ed:	68 0c 00 10 00       	push   $0x10000c
f01007f2:	68 cc 73 10 f0       	push   $0xf01073cc
f01007f7:	e8 d5 32 00 00       	call   f0103ad1 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007fc:	83 c4 0c             	add    $0xc,%esp
f01007ff:	68 0c 00 10 00       	push   $0x10000c
f0100804:	68 0c 00 10 f0       	push   $0xf010000c
f0100809:	68 f4 73 10 f0       	push   $0xf01073f4
f010080e:	e8 be 32 00 00       	call   f0103ad1 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100813:	83 c4 0c             	add    $0xc,%esp
f0100816:	68 a1 6f 10 00       	push   $0x106fa1
f010081b:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0100820:	68 18 74 10 f0       	push   $0xf0107418
f0100825:	e8 a7 32 00 00       	call   f0103ad1 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082a:	83 c4 0c             	add    $0xc,%esp
f010082d:	68 00 c0 2b 00       	push   $0x2bc000
f0100832:	68 00 c0 2b f0       	push   $0xf02bc000
f0100837:	68 3c 74 10 f0       	push   $0xf010743c
f010083c:	e8 90 32 00 00       	call   f0103ad1 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100841:	83 c4 0c             	add    $0xc,%esp
f0100844:	68 b0 9b 34 00       	push   $0x349bb0
f0100849:	68 b0 9b 34 f0       	push   $0xf0349bb0
f010084e:	68 60 74 10 f0       	push   $0xf0107460
f0100853:	e8 79 32 00 00       	call   f0103ad1 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100858:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010085b:	b8 b0 9b 34 f0       	mov    $0xf0349bb0,%eax
f0100860:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100865:	c1 f8 0a             	sar    $0xa,%eax
f0100868:	50                   	push   %eax
f0100869:	68 84 74 10 f0       	push   $0xf0107484
f010086e:	e8 5e 32 00 00       	call   f0103ad1 <cprintf>
	return 0;
}
f0100873:	b8 00 00 00 00       	mov    $0x0,%eax
f0100878:	c9                   	leave  
f0100879:	c3                   	ret    

f010087a <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010087a:	55                   	push   %ebp
f010087b:	89 e5                	mov    %esp,%ebp
f010087d:	56                   	push   %esi
f010087e:	53                   	push   %ebx
f010087f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));//I guess it means moving ebp register value to local variable. 
f0100882:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	uint32_t * ebp;
	struct Eipdebuginfo info;
	
	ebp=(uint32_t *)read_ebp();
	cprintf("Stack backtrace:\n");
f0100884:	68 2e 73 10 f0       	push   $0xf010732e
f0100889:	e8 43 32 00 00       	call   f0103ad1 <cprintf>
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f010088e:	83 c4 10             	add    $0x10,%esp
		cprintf(" %08x",*(ebp+4));
		cprintf(" %08x",*(ebp+5));
		cprintf(" %08x\n",*(ebp+6));
		
		//Exercise 12
		debuginfo_eip(*(ebp+1) , &info);
f0100891:	8d 75 e0             	lea    -0x20(%ebp),%esi
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f0100894:	e9 c2 00 00 00       	jmp    f010095b <mon_backtrace+0xe1>
		cprintf(" ebp %08x",(uint32_t) ebp);
f0100899:	83 ec 08             	sub    $0x8,%esp
f010089c:	53                   	push   %ebx
f010089d:	68 40 73 10 f0       	push   $0xf0107340
f01008a2:	e8 2a 32 00 00       	call   f0103ad1 <cprintf>
		cprintf(" eip %08x",*(ebp+1));
f01008a7:	83 c4 08             	add    $0x8,%esp
f01008aa:	ff 73 04             	push   0x4(%ebx)
f01008ad:	68 4a 73 10 f0       	push   $0xf010734a
f01008b2:	e8 1a 32 00 00       	call   f0103ad1 <cprintf>
		cprintf(" args");
f01008b7:	c7 04 24 54 73 10 f0 	movl   $0xf0107354,(%esp)
f01008be:	e8 0e 32 00 00       	call   f0103ad1 <cprintf>
		cprintf(" %08x",*(ebp+2));
f01008c3:	83 c4 08             	add    $0x8,%esp
f01008c6:	ff 73 08             	push   0x8(%ebx)
f01008c9:	68 44 73 10 f0       	push   $0xf0107344
f01008ce:	e8 fe 31 00 00       	call   f0103ad1 <cprintf>
		cprintf(" %08x",*(ebp+3));
f01008d3:	83 c4 08             	add    $0x8,%esp
f01008d6:	ff 73 0c             	push   0xc(%ebx)
f01008d9:	68 44 73 10 f0       	push   $0xf0107344
f01008de:	e8 ee 31 00 00       	call   f0103ad1 <cprintf>
		cprintf(" %08x",*(ebp+4));
f01008e3:	83 c4 08             	add    $0x8,%esp
f01008e6:	ff 73 10             	push   0x10(%ebx)
f01008e9:	68 44 73 10 f0       	push   $0xf0107344
f01008ee:	e8 de 31 00 00       	call   f0103ad1 <cprintf>
		cprintf(" %08x",*(ebp+5));
f01008f3:	83 c4 08             	add    $0x8,%esp
f01008f6:	ff 73 14             	push   0x14(%ebx)
f01008f9:	68 44 73 10 f0       	push   $0xf0107344
f01008fe:	e8 ce 31 00 00       	call   f0103ad1 <cprintf>
		cprintf(" %08x\n",*(ebp+6));
f0100903:	83 c4 08             	add    $0x8,%esp
f0100906:	ff 73 18             	push   0x18(%ebx)
f0100909:	68 ae 8e 10 f0       	push   $0xf0108eae
f010090e:	e8 be 31 00 00       	call   f0103ad1 <cprintf>
		debuginfo_eip(*(ebp+1) , &info);
f0100913:	83 c4 08             	add    $0x8,%esp
f0100916:	56                   	push   %esi
f0100917:	ff 73 04             	push   0x4(%ebx)
f010091a:	e8 fd 46 00 00       	call   f010501c <debuginfo_eip>
		cprintf("\t%s:",info.eip_file);
f010091f:	83 c4 08             	add    $0x8,%esp
f0100922:	ff 75 e0             	push   -0x20(%ebp)
f0100925:	68 5a 73 10 f0       	push   $0xf010735a
f010092a:	e8 a2 31 00 00       	call   f0103ad1 <cprintf>
		cprintf("%d: ",info.eip_line);
f010092f:	83 c4 08             	add    $0x8,%esp
f0100932:	ff 75 e4             	push   -0x1c(%ebp)
f0100935:	68 7e 70 10 f0       	push   $0xf010707e
f010093a:	e8 92 31 00 00       	call   f0103ad1 <cprintf>
		cprintf("%.*s+%d\n", info.eip_fn_namelen , info.eip_fn_name , *(ebp+1) - info.eip_fn_addr );
f010093f:	8b 43 04             	mov    0x4(%ebx),%eax
f0100942:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100945:	50                   	push   %eax
f0100946:	ff 75 e8             	push   -0x18(%ebp)
f0100949:	ff 75 ec             	push   -0x14(%ebp)
f010094c:	68 5f 73 10 f0       	push   $0xf010735f
f0100951:	e8 7b 31 00 00       	call   f0103ad1 <cprintf>
		
		//
		ebp=(uint32_t *)(*ebp);
f0100956:	8b 1b                	mov    (%ebx),%ebx
f0100958:	83 c4 20             	add    $0x20,%esp
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f010095b:	85 db                	test   %ebx,%ebx
f010095d:	0f 85 36 ff ff ff    	jne    f0100899 <mon_backtrace+0x1f>
    	cprintf("x=%d y=%d\n", 3);
    	
	cprintf("Lab1 Exercise8 qusetion3 finish!\n");
	*/
	return 0;
}
f0100963:	b8 00 00 00 00       	mov    $0x0,%eax
f0100968:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010096b:	5b                   	pop    %ebx
f010096c:	5e                   	pop    %esi
f010096d:	5d                   	pop    %ebp
f010096e:	c3                   	ret    

f010096f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010096f:	55                   	push   %ebp
f0100970:	89 e5                	mov    %esp,%ebp
f0100972:	57                   	push   %edi
f0100973:	56                   	push   %esi
f0100974:	53                   	push   %ebx
f0100975:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100978:	68 b0 74 10 f0       	push   $0xf01074b0
f010097d:	e8 4f 31 00 00       	call   f0103ad1 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100982:	c7 04 24 d4 74 10 f0 	movl   $0xf01074d4,(%esp)
f0100989:	e8 43 31 00 00       	call   f0103ad1 <cprintf>

	if (tf != NULL)
f010098e:	83 c4 10             	add    $0x10,%esp
f0100991:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100995:	74 57                	je     f01009ee <monitor+0x7f>
		print_trapframe(tf);
f0100997:	83 ec 0c             	sub    $0xc,%esp
f010099a:	ff 75 08             	push   0x8(%ebp)
f010099d:	e8 ef 36 00 00       	call   f0104091 <print_trapframe>
f01009a2:	83 c4 10             	add    $0x10,%esp
f01009a5:	eb 47                	jmp    f01009ee <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f01009a7:	83 ec 08             	sub    $0x8,%esp
f01009aa:	0f be c0             	movsbl %al,%eax
f01009ad:	50                   	push   %eax
f01009ae:	68 6c 73 10 f0       	push   $0xf010736c
f01009b3:	e8 f6 50 00 00       	call   f0105aae <strchr>
f01009b8:	83 c4 10             	add    $0x10,%esp
f01009bb:	85 c0                	test   %eax,%eax
f01009bd:	74 0a                	je     f01009c9 <monitor+0x5a>
			*buf++ = 0;
f01009bf:	c6 03 00             	movb   $0x0,(%ebx)
f01009c2:	89 f7                	mov    %esi,%edi
f01009c4:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009c7:	eb 6b                	jmp    f0100a34 <monitor+0xc5>
		if (*buf == 0)
f01009c9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009cc:	74 73                	je     f0100a41 <monitor+0xd2>
		if (argc == MAXARGS-1) {
f01009ce:	83 fe 0f             	cmp    $0xf,%esi
f01009d1:	74 09                	je     f01009dc <monitor+0x6d>
		argv[argc++] = buf;
f01009d3:	8d 7e 01             	lea    0x1(%esi),%edi
f01009d6:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009da:	eb 39                	jmp    f0100a15 <monitor+0xa6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009dc:	83 ec 08             	sub    $0x8,%esp
f01009df:	6a 10                	push   $0x10
f01009e1:	68 71 73 10 f0       	push   $0xf0107371
f01009e6:	e8 e6 30 00 00       	call   f0103ad1 <cprintf>
			return 0;
f01009eb:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009ee:	83 ec 0c             	sub    $0xc,%esp
f01009f1:	68 68 73 10 f0       	push   $0xf0107368
f01009f6:	e8 79 4e 00 00       	call   f0105874 <readline>
f01009fb:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009fd:	83 c4 10             	add    $0x10,%esp
f0100a00:	85 c0                	test   %eax,%eax
f0100a02:	74 ea                	je     f01009ee <monitor+0x7f>
	argv[argc] = 0;
f0100a04:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a0b:	be 00 00 00 00       	mov    $0x0,%esi
f0100a10:	eb 24                	jmp    f0100a36 <monitor+0xc7>
			buf++;
f0100a12:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a15:	0f b6 03             	movzbl (%ebx),%eax
f0100a18:	84 c0                	test   %al,%al
f0100a1a:	74 18                	je     f0100a34 <monitor+0xc5>
f0100a1c:	83 ec 08             	sub    $0x8,%esp
f0100a1f:	0f be c0             	movsbl %al,%eax
f0100a22:	50                   	push   %eax
f0100a23:	68 6c 73 10 f0       	push   $0xf010736c
f0100a28:	e8 81 50 00 00       	call   f0105aae <strchr>
f0100a2d:	83 c4 10             	add    $0x10,%esp
f0100a30:	85 c0                	test   %eax,%eax
f0100a32:	74 de                	je     f0100a12 <monitor+0xa3>
			*buf++ = 0;
f0100a34:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a36:	0f b6 03             	movzbl (%ebx),%eax
f0100a39:	84 c0                	test   %al,%al
f0100a3b:	0f 85 66 ff ff ff    	jne    f01009a7 <monitor+0x38>
	argv[argc] = 0;
f0100a41:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a48:	00 
	if (argc == 0)
f0100a49:	85 f6                	test   %esi,%esi
f0100a4b:	74 a1                	je     f01009ee <monitor+0x7f>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a4d:	83 ec 08             	sub    $0x8,%esp
f0100a50:	68 fe 72 10 f0       	push   $0xf01072fe
f0100a55:	ff 75 a8             	push   -0x58(%ebp)
f0100a58:	e8 f1 4f 00 00       	call   f0105a4e <strcmp>
f0100a5d:	83 c4 10             	add    $0x10,%esp
f0100a60:	85 c0                	test   %eax,%eax
f0100a62:	74 34                	je     f0100a98 <monitor+0x129>
f0100a64:	83 ec 08             	sub    $0x8,%esp
f0100a67:	68 0c 73 10 f0       	push   $0xf010730c
f0100a6c:	ff 75 a8             	push   -0x58(%ebp)
f0100a6f:	e8 da 4f 00 00       	call   f0105a4e <strcmp>
f0100a74:	83 c4 10             	add    $0x10,%esp
f0100a77:	85 c0                	test   %eax,%eax
f0100a79:	74 18                	je     f0100a93 <monitor+0x124>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a7b:	83 ec 08             	sub    $0x8,%esp
f0100a7e:	ff 75 a8             	push   -0x58(%ebp)
f0100a81:	68 8e 73 10 f0       	push   $0xf010738e
f0100a86:	e8 46 30 00 00       	call   f0103ad1 <cprintf>
	return 0;
f0100a8b:	83 c4 10             	add    $0x10,%esp
f0100a8e:	e9 5b ff ff ff       	jmp    f01009ee <monitor+0x7f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a93:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a98:	83 ec 04             	sub    $0x4,%esp
f0100a9b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a9e:	ff 75 08             	push   0x8(%ebp)
f0100aa1:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100aa4:	52                   	push   %edx
f0100aa5:	56                   	push   %esi
f0100aa6:	ff 14 85 04 75 10 f0 	call   *-0xfef8afc(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100aad:	83 c4 10             	add    $0x10,%esp
f0100ab0:	85 c0                	test   %eax,%eax
f0100ab2:	0f 89 36 ff ff ff    	jns    f01009ee <monitor+0x7f>
				break;
	}
}
f0100ab8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100abb:	5b                   	pop    %ebx
f0100abc:	5e                   	pop    %esi
f0100abd:	5f                   	pop    %edi
f0100abe:	5d                   	pop    %ebp
f0100abf:	c3                   	ret    

f0100ac0 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100ac0:	55                   	push   %ebp
f0100ac1:	89 e5                	mov    %esp,%ebp
f0100ac3:	56                   	push   %esi
f0100ac4:	53                   	push   %ebx
f0100ac5:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ac7:	83 ec 0c             	sub    $0xc,%esp
f0100aca:	50                   	push   %eax
f0100acb:	e8 5f 2e 00 00       	call   f010392f <mc146818_read>
f0100ad0:	89 c6                	mov    %eax,%esi
f0100ad2:	83 c3 01             	add    $0x1,%ebx
f0100ad5:	89 1c 24             	mov    %ebx,(%esp)
f0100ad8:	e8 52 2e 00 00       	call   f010392f <mc146818_read>
f0100add:	c1 e0 08             	shl    $0x8,%eax
f0100ae0:	09 f0                	or     %esi,%eax
}
f0100ae2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ae5:	5b                   	pop    %ebx
f0100ae6:	5e                   	pop    %esi
f0100ae7:	5d                   	pop    %ebp
f0100ae8:	c3                   	ret    

f0100ae9 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ae9:	83 3d 64 c2 2b f0 00 	cmpl   $0x0,0xf02bc264
f0100af0:	74 21                	je     f0100b13 <boot_alloc+0x2a>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	
	//
	// LAB 2: Your code here.
	result=nextfree;
f0100af2:	8b 15 64 c2 2b f0    	mov    0xf02bc264,%edx
	nextfree=ROUNDUP(nextfree+n, PGSIZE);
f0100af8:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100aff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b04:	a3 64 c2 2b f0       	mov    %eax,0xf02bc264
	if( (uint32_t)nextfree < KERNBASE ){
f0100b09:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100b0e:	76 16                	jbe    f0100b26 <boot_alloc+0x3d>
	//这也与博客的写法 if( (uint32_t)nextfree - KERNBASE > (npages*PGSIZE))所不同。
	
	return result;

	//return NULL;
}
f0100b10:	89 d0                	mov    %edx,%eax
f0100b12:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);//ROUNDUP(a,n)函数在inc/types.h中定义：目的是用来进行地址向上对齐，即增大数a至n的倍数。
f0100b13:	ba af ab 34 f0       	mov    $0xf034abaf,%edx
f0100b18:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b1e:	89 15 64 c2 2b f0    	mov    %edx,0xf02bc264
f0100b24:	eb cc                	jmp    f0100af2 <boot_alloc+0x9>
{
f0100b26:	55                   	push   %ebp
f0100b27:	89 e5                	mov    %esp,%ebp
f0100b29:	83 ec 0c             	sub    $0xc,%esp
		panic("boot_alloc: out of memory\n");
f0100b2c:	68 14 75 10 f0       	push   $0xf0107514
f0100b31:	6a 75                	push   $0x75
f0100b33:	68 2f 75 10 f0       	push   $0xf010752f
f0100b38:	e8 03 f5 ff ff       	call   f0100040 <_panic>

f0100b3d <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b3d:	89 d1                	mov    %edx,%ecx
f0100b3f:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b42:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b45:	a8 01                	test   $0x1,%al
f0100b47:	74 51                	je     f0100b9a <check_va2pa+0x5d>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b49:	89 c1                	mov    %eax,%ecx
f0100b4b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100b51:	c1 e8 0c             	shr    $0xc,%eax
f0100b54:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f0100b5a:	73 23                	jae    f0100b7f <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P))
f0100b5c:	c1 ea 0c             	shr    $0xc,%edx
f0100b5f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b65:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b6c:	89 d0                	mov    %edx,%eax
f0100b6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b73:	f6 c2 01             	test   $0x1,%dl
f0100b76:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b7b:	0f 44 c2             	cmove  %edx,%eax
f0100b7e:	c3                   	ret    
{
f0100b7f:	55                   	push   %ebp
f0100b80:	89 e5                	mov    %esp,%ebp
f0100b82:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b85:	51                   	push   %ecx
f0100b86:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0100b8b:	68 c4 03 00 00       	push   $0x3c4
f0100b90:	68 2f 75 10 f0       	push   $0xf010752f
f0100b95:	e8 a6 f4 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100b9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b9f:	c3                   	ret    

f0100ba0 <check_page_free_list>:
{
f0100ba0:	55                   	push   %ebp
f0100ba1:	89 e5                	mov    %esp,%ebp
f0100ba3:	57                   	push   %edi
f0100ba4:	56                   	push   %esi
f0100ba5:	53                   	push   %ebx
f0100ba6:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100ba9:	84 c0                	test   %al,%al
f0100bab:	0f 85 77 02 00 00    	jne    f0100e28 <check_page_free_list+0x288>
	if (!page_free_list)
f0100bb1:	83 3d 6c c2 2b f0 00 	cmpl   $0x0,0xf02bc26c
f0100bb8:	74 0a                	je     f0100bc4 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100bba:	be 00 04 00 00       	mov    $0x400,%esi
f0100bbf:	e9 bf 02 00 00       	jmp    f0100e83 <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100bc4:	83 ec 04             	sub    $0x4,%esp
f0100bc7:	68 68 78 10 f0       	push   $0xf0107868
f0100bcc:	68 f7 02 00 00       	push   $0x2f7
f0100bd1:	68 2f 75 10 f0       	push   $0xf010752f
f0100bd6:	e8 65 f4 ff ff       	call   f0100040 <_panic>
f0100bdb:	50                   	push   %eax
f0100bdc:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0100be1:	6a 5a                	push   $0x5a
f0100be3:	68 3b 75 10 f0       	push   $0xf010753b
f0100be8:	e8 53 f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bed:	8b 1b                	mov    (%ebx),%ebx
f0100bef:	85 db                	test   %ebx,%ebx
f0100bf1:	74 41                	je     f0100c34 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0100bf3:	89 d8                	mov    %ebx,%eax
f0100bf5:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f0100bfb:	c1 f8 03             	sar    $0x3,%eax
f0100bfe:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c01:	89 c2                	mov    %eax,%edx
f0100c03:	c1 ea 16             	shr    $0x16,%edx
f0100c06:	39 f2                	cmp    %esi,%edx
f0100c08:	73 e3                	jae    f0100bed <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100c0a:	89 c2                	mov    %eax,%edx
f0100c0c:	c1 ea 0c             	shr    $0xc,%edx
f0100c0f:	3b 15 60 c2 2b f0    	cmp    0xf02bc260,%edx
f0100c15:	73 c4                	jae    f0100bdb <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100c17:	83 ec 04             	sub    $0x4,%esp
f0100c1a:	68 80 00 00 00       	push   $0x80
f0100c1f:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c24:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c29:	50                   	push   %eax
f0100c2a:	e8 be 4e 00 00       	call   f0105aed <memset>
f0100c2f:	83 c4 10             	add    $0x10,%esp
f0100c32:	eb b9                	jmp    f0100bed <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100c34:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c39:	e8 ab fe ff ff       	call   f0100ae9 <boot_alloc>
f0100c3e:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c41:	8b 15 6c c2 2b f0    	mov    0xf02bc26c,%edx
		assert(pp >= pages);
f0100c47:	8b 0d 58 c2 2b f0    	mov    0xf02bc258,%ecx
		assert(pp < pages + npages);
f0100c4d:	a1 60 c2 2b f0       	mov    0xf02bc260,%eax
f0100c52:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c55:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c58:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c5d:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c60:	e9 f9 00 00 00       	jmp    f0100d5e <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100c65:	68 49 75 10 f0       	push   $0xf0107549
f0100c6a:	68 55 75 10 f0       	push   $0xf0107555
f0100c6f:	68 11 03 00 00       	push   $0x311
f0100c74:	68 2f 75 10 f0       	push   $0xf010752f
f0100c79:	e8 c2 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c7e:	68 6a 75 10 f0       	push   $0xf010756a
f0100c83:	68 55 75 10 f0       	push   $0xf0107555
f0100c88:	68 12 03 00 00       	push   $0x312
f0100c8d:	68 2f 75 10 f0       	push   $0xf010752f
f0100c92:	e8 a9 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c97:	68 8c 78 10 f0       	push   $0xf010788c
f0100c9c:	68 55 75 10 f0       	push   $0xf0107555
f0100ca1:	68 13 03 00 00       	push   $0x313
f0100ca6:	68 2f 75 10 f0       	push   $0xf010752f
f0100cab:	e8 90 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100cb0:	68 7e 75 10 f0       	push   $0xf010757e
f0100cb5:	68 55 75 10 f0       	push   $0xf0107555
f0100cba:	68 16 03 00 00       	push   $0x316
f0100cbf:	68 2f 75 10 f0       	push   $0xf010752f
f0100cc4:	e8 77 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cc9:	68 8f 75 10 f0       	push   $0xf010758f
f0100cce:	68 55 75 10 f0       	push   $0xf0107555
f0100cd3:	68 17 03 00 00       	push   $0x317
f0100cd8:	68 2f 75 10 f0       	push   $0xf010752f
f0100cdd:	e8 5e f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ce2:	68 c0 78 10 f0       	push   $0xf01078c0
f0100ce7:	68 55 75 10 f0       	push   $0xf0107555
f0100cec:	68 18 03 00 00       	push   $0x318
f0100cf1:	68 2f 75 10 f0       	push   $0xf010752f
f0100cf6:	e8 45 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cfb:	68 a8 75 10 f0       	push   $0xf01075a8
f0100d00:	68 55 75 10 f0       	push   $0xf0107555
f0100d05:	68 19 03 00 00       	push   $0x319
f0100d0a:	68 2f 75 10 f0       	push   $0xf010752f
f0100d0f:	e8 2c f3 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100d14:	89 c3                	mov    %eax,%ebx
f0100d16:	c1 eb 0c             	shr    $0xc,%ebx
f0100d19:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100d1c:	76 0f                	jbe    f0100d2d <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100d1e:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d23:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d26:	77 17                	ja     f0100d3f <check_page_free_list+0x19f>
			++nfree_extmem;
f0100d28:	83 c7 01             	add    $0x1,%edi
f0100d2b:	eb 2f                	jmp    f0100d5c <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d2d:	50                   	push   %eax
f0100d2e:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0100d33:	6a 5a                	push   $0x5a
f0100d35:	68 3b 75 10 f0       	push   $0xf010753b
f0100d3a:	e8 01 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d3f:	68 e4 78 10 f0       	push   $0xf01078e4
f0100d44:	68 55 75 10 f0       	push   $0xf0107555
f0100d49:	68 1a 03 00 00       	push   $0x31a
f0100d4e:	68 2f 75 10 f0       	push   $0xf010752f
f0100d53:	e8 e8 f2 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100d58:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d5c:	8b 12                	mov    (%edx),%edx
f0100d5e:	85 d2                	test   %edx,%edx
f0100d60:	74 74                	je     f0100dd6 <check_page_free_list+0x236>
		assert(pp >= pages);
f0100d62:	39 d1                	cmp    %edx,%ecx
f0100d64:	0f 87 fb fe ff ff    	ja     f0100c65 <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100d6a:	39 d6                	cmp    %edx,%esi
f0100d6c:	0f 86 0c ff ff ff    	jbe    f0100c7e <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d72:	89 d0                	mov    %edx,%eax
f0100d74:	29 c8                	sub    %ecx,%eax
f0100d76:	a8 07                	test   $0x7,%al
f0100d78:	0f 85 19 ff ff ff    	jne    f0100c97 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0100d7e:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d81:	c1 e0 0c             	shl    $0xc,%eax
f0100d84:	0f 84 26 ff ff ff    	je     f0100cb0 <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d8a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d8f:	0f 84 34 ff ff ff    	je     f0100cc9 <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d95:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d9a:	0f 84 42 ff ff ff    	je     f0100ce2 <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100da0:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100da5:	0f 84 50 ff ff ff    	je     f0100cfb <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dab:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100db0:	0f 87 5e ff ff ff    	ja     f0100d14 <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100db6:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dbb:	75 9b                	jne    f0100d58 <check_page_free_list+0x1b8>
f0100dbd:	68 c2 75 10 f0       	push   $0xf01075c2
f0100dc2:	68 55 75 10 f0       	push   $0xf0107555
f0100dc7:	68 1c 03 00 00       	push   $0x31c
f0100dcc:	68 2f 75 10 f0       	push   $0xf010752f
f0100dd1:	e8 6a f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f0100dd6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100dd9:	85 db                	test   %ebx,%ebx
f0100ddb:	7e 19                	jle    f0100df6 <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100ddd:	85 ff                	test   %edi,%edi
f0100ddf:	7e 2e                	jle    f0100e0f <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100de1:	83 ec 0c             	sub    $0xc,%esp
f0100de4:	68 2c 79 10 f0       	push   $0xf010792c
f0100de9:	e8 e3 2c 00 00       	call   f0103ad1 <cprintf>
}
f0100dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100df1:	5b                   	pop    %ebx
f0100df2:	5e                   	pop    %esi
f0100df3:	5f                   	pop    %edi
f0100df4:	5d                   	pop    %ebp
f0100df5:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100df6:	68 df 75 10 f0       	push   $0xf01075df
f0100dfb:	68 55 75 10 f0       	push   $0xf0107555
f0100e00:	68 24 03 00 00       	push   $0x324
f0100e05:	68 2f 75 10 f0       	push   $0xf010752f
f0100e0a:	e8 31 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e0f:	68 f1 75 10 f0       	push   $0xf01075f1
f0100e14:	68 55 75 10 f0       	push   $0xf0107555
f0100e19:	68 25 03 00 00       	push   $0x325
f0100e1e:	68 2f 75 10 f0       	push   $0xf010752f
f0100e23:	e8 18 f2 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100e28:	a1 6c c2 2b f0       	mov    0xf02bc26c,%eax
f0100e2d:	85 c0                	test   %eax,%eax
f0100e2f:	0f 84 8f fd ff ff    	je     f0100bc4 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e35:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e38:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e3b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e3e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100e41:	89 c2                	mov    %eax,%edx
f0100e43:	2b 15 58 c2 2b f0    	sub    0xf02bc258,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e49:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100e4f:	0f 95 c2             	setne  %dl
f0100e52:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100e55:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100e59:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e5b:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e5f:	8b 00                	mov    (%eax),%eax
f0100e61:	85 c0                	test   %eax,%eax
f0100e63:	75 dc                	jne    f0100e41 <check_page_free_list+0x2a1>
		*tp[1] = 0;
f0100e65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e6e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e71:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e74:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e76:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e79:	a3 6c c2 2b f0       	mov    %eax,0xf02bc26c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100e7e:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e83:	8b 1d 6c c2 2b f0    	mov    0xf02bc26c,%ebx
f0100e89:	e9 61 fd ff ff       	jmp    f0100bef <check_page_free_list+0x4f>

f0100e8e <page_init>:
{
f0100e8e:	55                   	push   %ebp
f0100e8f:	89 e5                	mov    %esp,%ebp
f0100e91:	57                   	push   %edi
f0100e92:	56                   	push   %esi
f0100e93:	53                   	push   %ebx
f0100e94:	83 ec 0c             	sub    $0xc,%esp
	page_free_list = NULL;//其实是多余的，因为它本就是空指针，这只是为了方便阅读一点。
f0100e97:	c7 05 6c c2 2b f0 00 	movl   $0x0,0xf02bc26c
f0100e9e:	00 00 00 
	uint32_t EXTPHYSMEM_alloc = (uint32_t)boot_alloc(0) - KERNBASE;//EXTPHYSMEM_alloc：在EXTPHYSMEM区域已经被占用的bytes数
f0100ea1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ea6:	e8 3e fc ff ff       	call   f0100ae9 <boot_alloc>
		if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)/* 3,4条*/ ||  (i>=MPENTRY_PADDR/PGSIZE && i<(MPENTRY_PADDR+size)/PGSIZE) /*lab4*/){//不标记为free的页
f0100eab:	8d 98 00 00 10 10    	lea    0x10100000(%eax),%ebx
f0100eb1:	c1 eb 0c             	shr    $0xc,%ebx
    	size = ROUNDUP(size, PGSIZE);
f0100eb4:	b9 5a 5d 10 f0       	mov    $0xf0105d5a,%ecx
f0100eb9:	81 e9 e1 4c 10 f0    	sub    $0xf0104ce1,%ecx
		if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)/* 3,4条*/ ||  (i>=MPENTRY_PADDR/PGSIZE && i<(MPENTRY_PADDR+size)/PGSIZE) /*lab4*/){//不标记为free的页
f0100ebf:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100ec5:	81 c1 00 70 00 00    	add    $0x7000,%ecx
f0100ecb:	c1 e9 0c             	shr    $0xc,%ecx
	for (size_t i = 0; i < npages; i++) {
f0100ece:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ed3:	be 00 00 00 00       	mov    $0x0,%esi
f0100ed8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100edd:	eb 10                	jmp    f0100eef <page_init+0x61>
			pages[i].pp_ref = 1;
f0100edf:	8b 3d 58 c2 2b f0    	mov    0xf02bc258,%edi
f0100ee5:	66 c7 44 c7 04 01 00 	movw   $0x1,0x4(%edi,%eax,8)
	for (size_t i = 0; i < npages; i++) {
f0100eec:	83 c0 01             	add    $0x1,%eax
f0100eef:	39 05 60 c2 2b f0    	cmp    %eax,0xf02bc260
f0100ef5:	76 3e                	jbe    f0100f35 <page_init+0xa7>
		if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)/* 3,4条*/ ||  (i>=MPENTRY_PADDR/PGSIZE && i<(MPENTRY_PADDR+size)/PGSIZE) /*lab4*/){//不标记为free的页
f0100ef7:	85 c0                	test   %eax,%eax
f0100ef9:	74 e4                	je     f0100edf <page_init+0x51>
f0100efb:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0100f00:	76 04                	jbe    f0100f06 <page_init+0x78>
f0100f02:	39 c3                	cmp    %eax,%ebx
f0100f04:	77 d9                	ja     f0100edf <page_init+0x51>
f0100f06:	83 f8 06             	cmp    $0x6,%eax
f0100f09:	76 04                	jbe    f0100f0f <page_init+0x81>
f0100f0b:	39 c1                	cmp    %eax,%ecx
f0100f0d:	77 d0                	ja     f0100edf <page_init+0x51>
f0100f0f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0100f16:	89 d7                	mov    %edx,%edi
f0100f18:	03 3d 58 c2 2b f0    	add    0xf02bc258,%edi
f0100f1e:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
			pages[i].pp_link = page_free_list;
f0100f24:	89 37                	mov    %esi,(%edi)
			page_free_list = &pages[i];	
f0100f26:	89 d6                	mov    %edx,%esi
f0100f28:	03 35 58 c2 2b f0    	add    0xf02bc258,%esi
f0100f2e:	ba 01 00 00 00       	mov    $0x1,%edx
f0100f33:	eb b7                	jmp    f0100eec <page_init+0x5e>
f0100f35:	84 d2                	test   %dl,%dl
f0100f37:	74 06                	je     f0100f3f <page_init+0xb1>
f0100f39:	89 35 6c c2 2b f0    	mov    %esi,0xf02bc26c
}
f0100f3f:	83 c4 0c             	add    $0xc,%esp
f0100f42:	5b                   	pop    %ebx
f0100f43:	5e                   	pop    %esi
f0100f44:	5f                   	pop    %edi
f0100f45:	5d                   	pop    %ebp
f0100f46:	c3                   	ret    

f0100f47 <page_alloc>:
{
f0100f47:	55                   	push   %ebp
f0100f48:	89 e5                	mov    %esp,%ebp
f0100f4a:	53                   	push   %ebx
f0100f4b:	83 ec 04             	sub    $0x4,%esp
	if(!page_free_list) return res;
f0100f4e:	8b 1d 6c c2 2b f0    	mov    0xf02bc26c,%ebx
f0100f54:	85 db                	test   %ebx,%ebx
f0100f56:	74 13                	je     f0100f6b <page_alloc+0x24>
	page_free_list=page_free_list -> pp_link;
f0100f58:	8b 03                	mov    (%ebx),%eax
f0100f5a:	a3 6c c2 2b f0       	mov    %eax,0xf02bc26c
	res ->pp_link=NULL;
f0100f5f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO){//ALLOC_ZERO在pmap.h中定义 ALLOC_ZERO = 1<<0,
f0100f65:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f69:	75 07                	jne    f0100f72 <page_alloc+0x2b>
}
f0100f6b:	89 d8                	mov    %ebx,%eax
f0100f6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f70:	c9                   	leave  
f0100f71:	c3                   	ret    
f0100f72:	89 d8                	mov    %ebx,%eax
f0100f74:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f0100f7a:	c1 f8 03             	sar    $0x3,%eax
f0100f7d:	89 c2                	mov    %eax,%edx
f0100f7f:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100f82:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100f87:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f0100f8d:	73 1b                	jae    f0100faa <page_alloc+0x63>
		memset(page2kva(res) , '\0' ,  PGSIZE );
f0100f8f:	83 ec 04             	sub    $0x4,%esp
f0100f92:	68 00 10 00 00       	push   $0x1000
f0100f97:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100f99:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100f9f:	52                   	push   %edx
f0100fa0:	e8 48 4b 00 00       	call   f0105aed <memset>
f0100fa5:	83 c4 10             	add    $0x10,%esp
f0100fa8:	eb c1                	jmp    f0100f6b <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100faa:	52                   	push   %edx
f0100fab:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0100fb0:	6a 5a                	push   $0x5a
f0100fb2:	68 3b 75 10 f0       	push   $0xf010753b
f0100fb7:	e8 84 f0 ff ff       	call   f0100040 <_panic>

f0100fbc <page_free>:
{
f0100fbc:	55                   	push   %ebp
f0100fbd:	89 e5                	mov    %esp,%ebp
f0100fbf:	83 ec 08             	sub    $0x8,%esp
f0100fc2:	8b 45 08             	mov    0x8(%ebp),%eax
      	assert(pp->pp_ref == 0);
f0100fc5:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100fca:	75 14                	jne    f0100fe0 <page_free+0x24>
      	assert(pp->pp_link == NULL);
f0100fcc:	83 38 00             	cmpl   $0x0,(%eax)
f0100fcf:	75 28                	jne    f0100ff9 <page_free+0x3d>
	pp->pp_link=page_free_list;
f0100fd1:	8b 15 6c c2 2b f0    	mov    0xf02bc26c,%edx
f0100fd7:	89 10                	mov    %edx,(%eax)
	page_free_list=pp;
f0100fd9:	a3 6c c2 2b f0       	mov    %eax,0xf02bc26c
}
f0100fde:	c9                   	leave  
f0100fdf:	c3                   	ret    
      	assert(pp->pp_ref == 0);
f0100fe0:	68 02 76 10 f0       	push   $0xf0107602
f0100fe5:	68 55 75 10 f0       	push   $0xf0107555
f0100fea:	68 ab 01 00 00       	push   $0x1ab
f0100fef:	68 2f 75 10 f0       	push   $0xf010752f
f0100ff4:	e8 47 f0 ff ff       	call   f0100040 <_panic>
      	assert(pp->pp_link == NULL);
f0100ff9:	68 12 76 10 f0       	push   $0xf0107612
f0100ffe:	68 55 75 10 f0       	push   $0xf0107555
f0101003:	68 ac 01 00 00       	push   $0x1ac
f0101008:	68 2f 75 10 f0       	push   $0xf010752f
f010100d:	e8 2e f0 ff ff       	call   f0100040 <_panic>

f0101012 <page_decref>:
{
f0101012:	55                   	push   %ebp
f0101013:	89 e5                	mov    %esp,%ebp
f0101015:	83 ec 08             	sub    $0x8,%esp
f0101018:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010101b:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010101f:	83 e8 01             	sub    $0x1,%eax
f0101022:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101026:	66 85 c0             	test   %ax,%ax
f0101029:	74 02                	je     f010102d <page_decref+0x1b>
}
f010102b:	c9                   	leave  
f010102c:	c3                   	ret    
		page_free(pp);
f010102d:	83 ec 0c             	sub    $0xc,%esp
f0101030:	52                   	push   %edx
f0101031:	e8 86 ff ff ff       	call   f0100fbc <page_free>
f0101036:	83 c4 10             	add    $0x10,%esp
}
f0101039:	eb f0                	jmp    f010102b <page_decref+0x19>

f010103b <pgdir_walk>:
{
f010103b:	55                   	push   %ebp
f010103c:	89 e5                	mov    %esp,%ebp
f010103e:	56                   	push   %esi
f010103f:	53                   	push   %ebx
f0101040:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t* dir_entry=pgdir+PDX(va); //PDX(va)返回page directory index,dir_entry是指向页目录中的DIR ENTRY(见图)的指针。
f0101043:	89 f3                	mov    %esi,%ebx
f0101045:	c1 eb 16             	shr    $0x16,%ebx
f0101048:	c1 e3 02             	shl    $0x2,%ebx
f010104b:	03 5d 08             	add    0x8(%ebp),%ebx
	if( !(*dir_entry & PTE_P) ){//如果这个页表不存在
f010104e:	f6 03 01             	testb  $0x1,(%ebx)
f0101051:	75 67                	jne    f01010ba <pgdir_walk+0x7f>
		if(create==false) return NULL;
f0101053:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101057:	0f 84 b0 00 00 00    	je     f010110d <pgdir_walk+0xd2>
			struct PageInfo * new_pp =page_alloc(1);//别忘了这个它返回的是struct PageInfo *
f010105d:	83 ec 0c             	sub    $0xc,%esp
f0101060:	6a 01                	push   $0x1
f0101062:	e8 e0 fe ff ff       	call   f0100f47 <page_alloc>
			if(new_pp==NULL){
f0101067:	83 c4 10             	add    $0x10,%esp
f010106a:	85 c0                	test   %eax,%eax
f010106c:	74 71                	je     f01010df <pgdir_walk+0xa4>
			new_pp->pp_ref++;
f010106e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101073:	89 c2                	mov    %eax,%edx
f0101075:	2b 15 58 c2 2b f0    	sub    0xf02bc258,%edx
f010107b:	c1 fa 03             	sar    $0x3,%edx
f010107e:	c1 e2 0c             	shl    $0xc,%edx
			*dir_entry=(page2pa(new_pp) | PTE_P | PTE_W | PTE_U);//设置dir_entry的标志位。注释中说可以设置宽松，所以这里全部设置为最宽松：可读写，应用程序级别即可访问。 dirty位 和access位不做设置。
f0101081:	83 ca 07             	or     $0x7,%edx
f0101084:	89 13                	mov    %edx,(%ebx)
f0101086:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f010108c:	c1 f8 03             	sar    $0x3,%eax
f010108f:	89 c2                	mov    %eax,%edx
f0101091:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101094:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101099:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f010109f:	73 45                	jae    f01010e6 <pgdir_walk+0xab>
			memset(page2kva(new_pp) , '\0' ,  PGSIZE);//初始化new_page的物理内存，一定要用虚拟地址!!!!!			
f01010a1:	83 ec 04             	sub    $0x4,%esp
f01010a4:	68 00 10 00 00       	push   $0x1000
f01010a9:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01010ab:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01010b1:	52                   	push   %edx
f01010b2:	e8 36 4a 00 00       	call   f0105aed <memset>
f01010b7:	83 c4 10             	add    $0x10,%esp
	pte_t * page_base = KADDR(PTE_ADDR(*dir_entry));//注意这块的类型定义，这涉及地址运算。 很重要，之前的bug就是因为这里!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
f01010ba:	8b 03                	mov    (%ebx),%eax
f01010bc:	89 c2                	mov    %eax,%edx
f01010be:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01010c4:	c1 e8 0c             	shr    $0xc,%eax
f01010c7:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f01010cd:	73 29                	jae    f01010f8 <pgdir_walk+0xbd>
	return  &page_base[PTX(va)];	
f01010cf:	c1 ee 0a             	shr    $0xa,%esi
f01010d2:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01010d8:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
}
f01010df:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010e2:	5b                   	pop    %ebx
f01010e3:	5e                   	pop    %esi
f01010e4:	5d                   	pop    %ebp
f01010e5:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010e6:	52                   	push   %edx
f01010e7:	68 e4 6f 10 f0       	push   $0xf0106fe4
f01010ec:	6a 5a                	push   $0x5a
f01010ee:	68 3b 75 10 f0       	push   $0xf010753b
f01010f3:	e8 48 ef ff ff       	call   f0100040 <_panic>
f01010f8:	52                   	push   %edx
f01010f9:	68 e4 6f 10 f0       	push   $0xf0106fe4
f01010fe:	68 e7 01 00 00       	push   $0x1e7
f0101103:	68 2f 75 10 f0       	push   $0xf010752f
f0101108:	e8 33 ef ff ff       	call   f0100040 <_panic>
		if(create==false) return NULL;
f010110d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101112:	eb cb                	jmp    f01010df <pgdir_walk+0xa4>

f0101114 <boot_map_region>:
{
f0101114:	55                   	push   %ebp
f0101115:	89 e5                	mov    %esp,%ebp
f0101117:	57                   	push   %edi
f0101118:	56                   	push   %esi
f0101119:	53                   	push   %ebx
f010111a:	83 ec 1c             	sub    $0x1c,%esp
f010111d:	89 c7                	mov    %eax,%edi
f010111f:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101122:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(int i=0; i<size;i+=PGSIZE){
f0101125:	be 00 00 00 00       	mov    $0x0,%esi
f010112a:	89 f3                	mov    %esi,%ebx
f010112c:	03 5d 08             	add    0x8(%ebp),%ebx
f010112f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0101132:	76 3f                	jbe    f0101173 <boot_map_region+0x5f>
		pt_entry=pgdir_walk(pgdir, (void *) va ,1);
f0101134:	83 ec 04             	sub    $0x4,%esp
f0101137:	6a 01                	push   $0x1
f0101139:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010113c:	01 f0                	add    %esi,%eax
f010113e:	50                   	push   %eax
f010113f:	57                   	push   %edi
f0101140:	e8 f6 fe ff ff       	call   f010103b <pgdir_walk>
		if (pt_entry == NULL) {
f0101145:	83 c4 10             	add    $0x10,%esp
f0101148:	85 c0                	test   %eax,%eax
f010114a:	74 10                	je     f010115c <boot_map_region+0x48>
		* pt_entry=(pa |perm | PTE_P);//按照注释对pg_entry置标志位。
f010114c:	0b 5d 0c             	or     0xc(%ebp),%ebx
f010114f:	83 cb 01             	or     $0x1,%ebx
f0101152:	89 18                	mov    %ebx,(%eax)
	for(int i=0; i<size;i+=PGSIZE){
f0101154:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010115a:	eb ce                	jmp    f010112a <boot_map_region+0x16>
            		panic("boot_map_region(): out of memory\n");
f010115c:	83 ec 04             	sub    $0x4,%esp
f010115f:	68 50 79 10 f0       	push   $0xf0107950
f0101164:	68 01 02 00 00       	push   $0x201
f0101169:	68 2f 75 10 f0       	push   $0xf010752f
f010116e:	e8 cd ee ff ff       	call   f0100040 <_panic>
}
f0101173:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101176:	5b                   	pop    %ebx
f0101177:	5e                   	pop    %esi
f0101178:	5f                   	pop    %edi
f0101179:	5d                   	pop    %ebp
f010117a:	c3                   	ret    

f010117b <page_lookup>:
{
f010117b:	55                   	push   %ebp
f010117c:	89 e5                	mov    %esp,%ebp
f010117e:	53                   	push   %ebx
f010117f:	83 ec 08             	sub    $0x8,%esp
f0101182:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t * pt_entry=pgdir_walk(pgdir,va,0);
f0101185:	6a 00                	push   $0x0
f0101187:	ff 75 0c             	push   0xc(%ebp)
f010118a:	ff 75 08             	push   0x8(%ebp)
f010118d:	e8 a9 fe ff ff       	call   f010103b <pgdir_walk>
	if(pt_entry==NULL)  return NULL;
f0101192:	83 c4 10             	add    $0x10,%esp
f0101195:	85 c0                	test   %eax,%eax
f0101197:	74 21                	je     f01011ba <page_lookup+0x3f>
	if(!(*pt_entry & PTE_P))  return NULL;
f0101199:	f6 00 01             	testb  $0x1,(%eax)
f010119c:	74 35                	je     f01011d3 <page_lookup+0x58>
	if(pte_store) *pte_store=pt_entry;
f010119e:	85 db                	test   %ebx,%ebx
f01011a0:	74 02                	je     f01011a4 <page_lookup+0x29>
f01011a2:	89 03                	mov    %eax,(%ebx)
f01011a4:	8b 00                	mov    (%eax),%eax
f01011a6:	c1 e8 0c             	shr    $0xc,%eax

//返回对应物理地址的 struct PageInfo* 部分
static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f01011a9:	39 05 60 c2 2b f0    	cmp    %eax,0xf02bc260
f01011af:	76 0e                	jbe    f01011bf <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01011b1:	8b 15 58 c2 2b f0    	mov    0xf02bc258,%edx
f01011b7:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01011ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011bd:	c9                   	leave  
f01011be:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01011bf:	83 ec 04             	sub    $0x4,%esp
f01011c2:	68 74 79 10 f0       	push   $0xf0107974
f01011c7:	6a 52                	push   $0x52
f01011c9:	68 3b 75 10 f0       	push   $0xf010753b
f01011ce:	e8 6d ee ff ff       	call   f0100040 <_panic>
	if(!(*pt_entry & PTE_P))  return NULL;
f01011d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01011d8:	eb e0                	jmp    f01011ba <page_lookup+0x3f>

f01011da <tlb_invalidate>:
{
f01011da:	55                   	push   %ebp
f01011db:	89 e5                	mov    %esp,%ebp
f01011dd:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01011e0:	e8 ff 4e 00 00       	call   f01060e4 <cpunum>
f01011e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01011e8:	83 b8 28 d0 2f f0 00 	cmpl   $0x0,-0xfd02fd8(%eax)
f01011ef:	74 16                	je     f0101207 <tlb_invalidate+0x2d>
f01011f1:	e8 ee 4e 00 00       	call   f01060e4 <cpunum>
f01011f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01011f9:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f01011ff:	8b 55 08             	mov    0x8(%ebp),%edx
f0101202:	39 50 70             	cmp    %edx,0x70(%eax)
f0101205:	75 06                	jne    f010120d <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101207:	8b 45 0c             	mov    0xc(%ebp),%eax
f010120a:	0f 01 38             	invlpg (%eax)
}
f010120d:	c9                   	leave  
f010120e:	c3                   	ret    

f010120f <page_remove>:
{
f010120f:	55                   	push   %ebp
f0101210:	89 e5                	mov    %esp,%ebp
f0101212:	56                   	push   %esi
f0101213:	53                   	push   %ebx
f0101214:	83 ec 14             	sub    $0x14,%esp
f0101217:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010121a:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo * pp=page_lookup(pgdir,va,&pt_entry);
f010121d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101220:	50                   	push   %eax
f0101221:	56                   	push   %esi
f0101222:	53                   	push   %ebx
f0101223:	e8 53 ff ff ff       	call   f010117b <page_lookup>
	if(pp==NULL) return ;
f0101228:	83 c4 10             	add    $0x10,%esp
f010122b:	85 c0                	test   %eax,%eax
f010122d:	74 1f                	je     f010124e <page_remove+0x3f>
	page_decref(pp);
f010122f:	83 ec 0c             	sub    $0xc,%esp
f0101232:	50                   	push   %eax
f0101233:	e8 da fd ff ff       	call   f0101012 <page_decref>
	*pt_entry= 0;
f0101238:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010123b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f0101241:	83 c4 08             	add    $0x8,%esp
f0101244:	56                   	push   %esi
f0101245:	53                   	push   %ebx
f0101246:	e8 8f ff ff ff       	call   f01011da <tlb_invalidate>
f010124b:	83 c4 10             	add    $0x10,%esp
}
f010124e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101251:	5b                   	pop    %ebx
f0101252:	5e                   	pop    %esi
f0101253:	5d                   	pop    %ebp
f0101254:	c3                   	ret    

f0101255 <page_insert>:
{
f0101255:	55                   	push   %ebp
f0101256:	89 e5                	mov    %esp,%ebp
f0101258:	57                   	push   %edi
f0101259:	56                   	push   %esi
f010125a:	53                   	push   %ebx
f010125b:	83 ec 10             	sub    $0x10,%esp
f010125e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101261:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pt_entry=pgdir_walk(pgdir,va,1);
f0101264:	6a 01                	push   $0x1
f0101266:	57                   	push   %edi
f0101267:	ff 75 08             	push   0x8(%ebp)
f010126a:	e8 cc fd ff ff       	call   f010103b <pgdir_walk>
	if(pt_entry==NULL) return -E_NO_MEM;
f010126f:	83 c4 10             	add    $0x10,%esp
f0101272:	85 c0                	test   %eax,%eax
f0101274:	74 3e                	je     f01012b4 <page_insert+0x5f>
f0101276:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;//这个一定要在前面，否则如果相同的pp 重新插入相同的va就会把  pp释放掉了。
f0101278:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if( (*pt_entry) & PTE_P ){//如果这个页已经存在
f010127d:	f6 00 01             	testb  $0x1,(%eax)
f0101280:	75 21                	jne    f01012a3 <page_insert+0x4e>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101282:	2b 1d 58 c2 2b f0    	sub    0xf02bc258,%ebx
f0101288:	c1 fb 03             	sar    $0x3,%ebx
f010128b:	c1 e3 0c             	shl    $0xc,%ebx
	*pt_entry = *pt_entry | perm | PTE_P ;
f010128e:	0b 5d 14             	or     0x14(%ebp),%ebx
f0101291:	83 cb 01             	or     $0x1,%ebx
f0101294:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101296:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010129b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010129e:	5b                   	pop    %ebx
f010129f:	5e                   	pop    %esi
f01012a0:	5f                   	pop    %edi
f01012a1:	5d                   	pop    %ebp
f01012a2:	c3                   	ret    
		page_remove(pgdir, va);
f01012a3:	83 ec 08             	sub    $0x8,%esp
f01012a6:	57                   	push   %edi
f01012a7:	ff 75 08             	push   0x8(%ebp)
f01012aa:	e8 60 ff ff ff       	call   f010120f <page_remove>
f01012af:	83 c4 10             	add    $0x10,%esp
f01012b2:	eb ce                	jmp    f0101282 <page_insert+0x2d>
	if(pt_entry==NULL) return -E_NO_MEM;
f01012b4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01012b9:	eb e0                	jmp    f010129b <page_insert+0x46>

f01012bb <mmio_map_region>:
{
f01012bb:	55                   	push   %ebp
f01012bc:	89 e5                	mov    %esp,%ebp
f01012be:	56                   	push   %esi
f01012bf:	53                   	push   %ebx
	void *ret =(void*) base;
f01012c0:	8b 35 00 93 12 f0    	mov    0xf0129300,%esi
	size=ROUNDUP(size,PGSIZE);
f01012c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012c9:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01012cf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(base + size > MMIOLIM || base + size < base /*unsigned 越界*/)  panic("mmio_map_region reservation overflow");
f01012d5:	89 f0                	mov    %esi,%eax
f01012d7:	01 d8                	add    %ebx,%eax
f01012d9:	72 2c                	jb     f0101307 <mmio_map_region+0x4c>
f01012db:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01012e0:	77 25                	ja     f0101307 <mmio_map_region+0x4c>
	boot_map_region(kern_pgdir, base, size, pa, PTE_W|PTE_PCD|PTE_PWT);
f01012e2:	83 ec 08             	sub    $0x8,%esp
f01012e5:	6a 1a                	push   $0x1a
f01012e7:	ff 75 08             	push   0x8(%ebp)
f01012ea:	89 d9                	mov    %ebx,%ecx
f01012ec:	89 f2                	mov    %esi,%edx
f01012ee:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
f01012f3:	e8 1c fe ff ff       	call   f0101114 <boot_map_region>
	base += size;
f01012f8:	01 1d 00 93 12 f0    	add    %ebx,0xf0129300
}
f01012fe:	89 f0                	mov    %esi,%eax
f0101300:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101303:	5b                   	pop    %ebx
f0101304:	5e                   	pop    %esi
f0101305:	5d                   	pop    %ebp
f0101306:	c3                   	ret    
	if(base + size > MMIOLIM || base + size < base /*unsigned 越界*/)  panic("mmio_map_region reservation overflow");
f0101307:	83 ec 04             	sub    $0x4,%esp
f010130a:	68 94 79 10 f0       	push   $0xf0107994
f010130f:	68 9e 02 00 00       	push   $0x29e
f0101314:	68 2f 75 10 f0       	push   $0xf010752f
f0101319:	e8 22 ed ff ff       	call   f0100040 <_panic>

f010131e <mem_init>:
{
f010131e:	55                   	push   %ebp
f010131f:	89 e5                	mov    %esp,%ebp
f0101321:	57                   	push   %edi
f0101322:	56                   	push   %esi
f0101323:	53                   	push   %ebx
f0101324:	83 ec 4c             	sub    $0x4c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101327:	b8 15 00 00 00       	mov    $0x15,%eax
f010132c:	e8 8f f7 ff ff       	call   f0100ac0 <nvram_read>
f0101331:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101333:	b8 17 00 00 00       	mov    $0x17,%eax
f0101338:	e8 83 f7 ff ff       	call   f0100ac0 <nvram_read>
f010133d:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010133f:	b8 34 00 00 00       	mov    $0x34,%eax
f0101344:	e8 77 f7 ff ff       	call   f0100ac0 <nvram_read>
	if (ext16mem)
f0101349:	c1 e0 06             	shl    $0x6,%eax
f010134c:	0f 84 09 01 00 00    	je     f010145b <mem_init+0x13d>
		totalmem = 16 * 1024 + ext16mem;
f0101352:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101357:	89 c2                	mov    %eax,%edx
f0101359:	c1 ea 02             	shr    $0x2,%edx
f010135c:	89 15 60 c2 2b f0    	mov    %edx,0xf02bc260
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101362:	89 c2                	mov    %eax,%edx
f0101364:	29 da                	sub    %ebx,%edx
f0101366:	52                   	push   %edx
f0101367:	53                   	push   %ebx
f0101368:	50                   	push   %eax
f0101369:	68 bc 79 10 f0       	push   $0xf01079bc
f010136e:	e8 5e 27 00 00       	call   f0103ad1 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101373:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101378:	e8 6c f7 ff ff       	call   f0100ae9 <boot_alloc>
f010137d:	a3 5c c2 2b f0       	mov    %eax,0xf02bc25c
	memset(kern_pgdir, 0, PGSIZE);
f0101382:	83 c4 0c             	add    $0xc,%esp
f0101385:	68 00 10 00 00       	push   $0x1000
f010138a:	6a 00                	push   $0x0
f010138c:	50                   	push   %eax
f010138d:	e8 5b 47 00 00       	call   f0105aed <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101392:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101397:	83 c4 10             	add    $0x10,%esp
f010139a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010139f:	0f 86 c6 00 00 00    	jbe    f010146b <mem_init+0x14d>
	return (physaddr_t)kva - KERNBASE;
f01013a5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013ab:	83 ca 05             	or     $0x5,%edx
f01013ae:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = boot_alloc(npages * sizeof(struct PageInfo));//pages是页信息数组的地址
f01013b4:	a1 60 c2 2b f0       	mov    0xf02bc260,%eax
f01013b9:	c1 e0 03             	shl    $0x3,%eax
f01013bc:	e8 28 f7 ff ff       	call   f0100ae9 <boot_alloc>
f01013c1:	a3 58 c2 2b f0       	mov    %eax,0xf02bc258
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01013c6:	83 ec 04             	sub    $0x4,%esp
f01013c9:	8b 0d 60 c2 2b f0    	mov    0xf02bc260,%ecx
f01013cf:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013d6:	52                   	push   %edx
f01013d7:	6a 00                	push   $0x0
f01013d9:	50                   	push   %eax
f01013da:	e8 0e 47 00 00       	call   f0105aed <memset>
	envs = (struct Env*) boot_alloc (NENV * sizeof (struct Env) );
f01013df:	b8 00 30 02 00       	mov    $0x23000,%eax
f01013e4:	e8 00 f7 ff ff       	call   f0100ae9 <boot_alloc>
f01013e9:	a3 74 c2 2b f0       	mov    %eax,0xf02bc274
	memset(envs , 0, NENV * sizeof(struct Env));
f01013ee:	83 c4 0c             	add    $0xc,%esp
f01013f1:	68 00 30 02 00       	push   $0x23000
f01013f6:	6a 00                	push   $0x0
f01013f8:	50                   	push   %eax
f01013f9:	e8 ef 46 00 00       	call   f0105aed <memset>
	mfqs = (struct Listnode* ) boot_alloc(NMFQ * sizeof(struct Listnode));
f01013fe:	b8 28 00 00 00       	mov    $0x28,%eax
f0101403:	e8 e1 f6 ff ff       	call   f0100ae9 <boot_alloc>
f0101408:	a3 70 c2 2b f0       	mov    %eax,0xf02bc270
	memset(mfqs, 0, NMFQ * sizeof(struct Listnode));
f010140d:	83 c4 0c             	add    $0xc,%esp
f0101410:	6a 28                	push   $0x28
f0101412:	6a 00                	push   $0x0
f0101414:	50                   	push   %eax
f0101415:	e8 d3 46 00 00       	call   f0105aed <memset>
f010141a:	83 c4 10             	add    $0x10,%esp
f010141d:	ba 00 00 00 00       	mov    $0x0,%edx
		node_init(&mfqs[i]);
f0101422:	89 d0                	mov    %edx,%eax
f0101424:	03 05 70 c2 2b f0    	add    0xf02bc270,%eax
};//双向链表，头接尾，尾接头

static void
node_init(struct Listnode *ln) 
{
    ln->prev = ln->next = ln;
f010142a:	89 40 04             	mov    %eax,0x4(%eax)
f010142d:	89 00                	mov    %eax,(%eax)
	for (int i = 0 ; i < NMFQ; ++i)
f010142f:	83 c2 08             	add    $0x8,%edx
f0101432:	83 fa 28             	cmp    $0x28,%edx
f0101435:	75 eb                	jne    f0101422 <mem_init+0x104>
	page_init();
f0101437:	e8 52 fa ff ff       	call   f0100e8e <page_init>
	check_page_free_list(1);
f010143c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101441:	e8 5a f7 ff ff       	call   f0100ba0 <check_page_free_list>
	if (!pages)
f0101446:	83 3d 58 c2 2b f0 00 	cmpl   $0x0,0xf02bc258
f010144d:	74 31                	je     f0101480 <mem_init+0x162>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010144f:	a1 6c c2 2b f0       	mov    0xf02bc26c,%eax
f0101454:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101459:	eb 41                	jmp    f010149c <mem_init+0x17e>
		totalmem = 1 * 1024 + extmem;
f010145b:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101461:	85 f6                	test   %esi,%esi
f0101463:	0f 44 c3             	cmove  %ebx,%eax
f0101466:	e9 ec fe ff ff       	jmp    f0101357 <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010146b:	50                   	push   %eax
f010146c:	68 08 70 10 f0       	push   $0xf0107008
f0101471:	68 9f 00 00 00       	push   $0x9f
f0101476:	68 2f 75 10 f0       	push   $0xf010752f
f010147b:	e8 c0 eb ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f0101480:	83 ec 04             	sub    $0x4,%esp
f0101483:	68 26 76 10 f0       	push   $0xf0107626
f0101488:	68 38 03 00 00       	push   $0x338
f010148d:	68 2f 75 10 f0       	push   $0xf010752f
f0101492:	e8 a9 eb ff ff       	call   f0100040 <_panic>
		++nfree;
f0101497:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010149a:	8b 00                	mov    (%eax),%eax
f010149c:	85 c0                	test   %eax,%eax
f010149e:	75 f7                	jne    f0101497 <mem_init+0x179>
	assert((pp0 = page_alloc(0)));
f01014a0:	83 ec 0c             	sub    $0xc,%esp
f01014a3:	6a 00                	push   $0x0
f01014a5:	e8 9d fa ff ff       	call   f0100f47 <page_alloc>
f01014aa:	89 c7                	mov    %eax,%edi
f01014ac:	83 c4 10             	add    $0x10,%esp
f01014af:	85 c0                	test   %eax,%eax
f01014b1:	0f 84 1f 02 00 00    	je     f01016d6 <mem_init+0x3b8>
	assert((pp1 = page_alloc(0)));
f01014b7:	83 ec 0c             	sub    $0xc,%esp
f01014ba:	6a 00                	push   $0x0
f01014bc:	e8 86 fa ff ff       	call   f0100f47 <page_alloc>
f01014c1:	89 c6                	mov    %eax,%esi
f01014c3:	83 c4 10             	add    $0x10,%esp
f01014c6:	85 c0                	test   %eax,%eax
f01014c8:	0f 84 21 02 00 00    	je     f01016ef <mem_init+0x3d1>
	assert((pp2 = page_alloc(0)));
f01014ce:	83 ec 0c             	sub    $0xc,%esp
f01014d1:	6a 00                	push   $0x0
f01014d3:	e8 6f fa ff ff       	call   f0100f47 <page_alloc>
f01014d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014db:	83 c4 10             	add    $0x10,%esp
f01014de:	85 c0                	test   %eax,%eax
f01014e0:	0f 84 22 02 00 00    	je     f0101708 <mem_init+0x3ea>
	assert(pp1 && pp1 != pp0);
f01014e6:	39 f7                	cmp    %esi,%edi
f01014e8:	0f 84 33 02 00 00    	je     f0101721 <mem_init+0x403>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014f1:	39 c7                	cmp    %eax,%edi
f01014f3:	0f 84 41 02 00 00    	je     f010173a <mem_init+0x41c>
f01014f9:	39 c6                	cmp    %eax,%esi
f01014fb:	0f 84 39 02 00 00    	je     f010173a <mem_init+0x41c>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101501:	8b 0d 58 c2 2b f0    	mov    0xf02bc258,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101507:	8b 15 60 c2 2b f0    	mov    0xf02bc260,%edx
f010150d:	c1 e2 0c             	shl    $0xc,%edx
f0101510:	89 f8                	mov    %edi,%eax
f0101512:	29 c8                	sub    %ecx,%eax
f0101514:	c1 f8 03             	sar    $0x3,%eax
f0101517:	c1 e0 0c             	shl    $0xc,%eax
f010151a:	39 d0                	cmp    %edx,%eax
f010151c:	0f 83 31 02 00 00    	jae    f0101753 <mem_init+0x435>
f0101522:	89 f0                	mov    %esi,%eax
f0101524:	29 c8                	sub    %ecx,%eax
f0101526:	c1 f8 03             	sar    $0x3,%eax
f0101529:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010152c:	39 c2                	cmp    %eax,%edx
f010152e:	0f 86 38 02 00 00    	jbe    f010176c <mem_init+0x44e>
f0101534:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101537:	29 c8                	sub    %ecx,%eax
f0101539:	c1 f8 03             	sar    $0x3,%eax
f010153c:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f010153f:	39 c2                	cmp    %eax,%edx
f0101541:	0f 86 3e 02 00 00    	jbe    f0101785 <mem_init+0x467>
	fl = page_free_list;
f0101547:	a1 6c c2 2b f0       	mov    0xf02bc26c,%eax
f010154c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010154f:	c7 05 6c c2 2b f0 00 	movl   $0x0,0xf02bc26c
f0101556:	00 00 00 
	assert(!page_alloc(0));
f0101559:	83 ec 0c             	sub    $0xc,%esp
f010155c:	6a 00                	push   $0x0
f010155e:	e8 e4 f9 ff ff       	call   f0100f47 <page_alloc>
f0101563:	83 c4 10             	add    $0x10,%esp
f0101566:	85 c0                	test   %eax,%eax
f0101568:	0f 85 30 02 00 00    	jne    f010179e <mem_init+0x480>
	page_free(pp0);
f010156e:	83 ec 0c             	sub    $0xc,%esp
f0101571:	57                   	push   %edi
f0101572:	e8 45 fa ff ff       	call   f0100fbc <page_free>
	page_free(pp1);
f0101577:	89 34 24             	mov    %esi,(%esp)
f010157a:	e8 3d fa ff ff       	call   f0100fbc <page_free>
	page_free(pp2);
f010157f:	83 c4 04             	add    $0x4,%esp
f0101582:	ff 75 d4             	push   -0x2c(%ebp)
f0101585:	e8 32 fa ff ff       	call   f0100fbc <page_free>
	assert((pp0 = page_alloc(0)));
f010158a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101591:	e8 b1 f9 ff ff       	call   f0100f47 <page_alloc>
f0101596:	89 c6                	mov    %eax,%esi
f0101598:	83 c4 10             	add    $0x10,%esp
f010159b:	85 c0                	test   %eax,%eax
f010159d:	0f 84 14 02 00 00    	je     f01017b7 <mem_init+0x499>
	assert((pp1 = page_alloc(0)));
f01015a3:	83 ec 0c             	sub    $0xc,%esp
f01015a6:	6a 00                	push   $0x0
f01015a8:	e8 9a f9 ff ff       	call   f0100f47 <page_alloc>
f01015ad:	89 c7                	mov    %eax,%edi
f01015af:	83 c4 10             	add    $0x10,%esp
f01015b2:	85 c0                	test   %eax,%eax
f01015b4:	0f 84 16 02 00 00    	je     f01017d0 <mem_init+0x4b2>
	assert((pp2 = page_alloc(0)));
f01015ba:	83 ec 0c             	sub    $0xc,%esp
f01015bd:	6a 00                	push   $0x0
f01015bf:	e8 83 f9 ff ff       	call   f0100f47 <page_alloc>
f01015c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015c7:	83 c4 10             	add    $0x10,%esp
f01015ca:	85 c0                	test   %eax,%eax
f01015cc:	0f 84 17 02 00 00    	je     f01017e9 <mem_init+0x4cb>
	assert(pp1 && pp1 != pp0);
f01015d2:	39 fe                	cmp    %edi,%esi
f01015d4:	0f 84 28 02 00 00    	je     f0101802 <mem_init+0x4e4>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015dd:	39 c6                	cmp    %eax,%esi
f01015df:	0f 84 36 02 00 00    	je     f010181b <mem_init+0x4fd>
f01015e5:	39 c7                	cmp    %eax,%edi
f01015e7:	0f 84 2e 02 00 00    	je     f010181b <mem_init+0x4fd>
	assert(!page_alloc(0));
f01015ed:	83 ec 0c             	sub    $0xc,%esp
f01015f0:	6a 00                	push   $0x0
f01015f2:	e8 50 f9 ff ff       	call   f0100f47 <page_alloc>
f01015f7:	83 c4 10             	add    $0x10,%esp
f01015fa:	85 c0                	test   %eax,%eax
f01015fc:	0f 85 32 02 00 00    	jne    f0101834 <mem_init+0x516>
f0101602:	89 f0                	mov    %esi,%eax
f0101604:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f010160a:	c1 f8 03             	sar    $0x3,%eax
f010160d:	89 c2                	mov    %eax,%edx
f010160f:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101612:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101617:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f010161d:	0f 83 2a 02 00 00    	jae    f010184d <mem_init+0x52f>
	memset(page2kva(pp0), 1, PGSIZE);
f0101623:	83 ec 04             	sub    $0x4,%esp
f0101626:	68 00 10 00 00       	push   $0x1000
f010162b:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010162d:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101633:	52                   	push   %edx
f0101634:	e8 b4 44 00 00       	call   f0105aed <memset>
	page_free(pp0);
f0101639:	89 34 24             	mov    %esi,(%esp)
f010163c:	e8 7b f9 ff ff       	call   f0100fbc <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101641:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101648:	e8 fa f8 ff ff       	call   f0100f47 <page_alloc>
f010164d:	83 c4 10             	add    $0x10,%esp
f0101650:	85 c0                	test   %eax,%eax
f0101652:	0f 84 07 02 00 00    	je     f010185f <mem_init+0x541>
	assert(pp && pp0 == pp);
f0101658:	39 c6                	cmp    %eax,%esi
f010165a:	0f 85 18 02 00 00    	jne    f0101878 <mem_init+0x55a>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101660:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f0101666:	c1 f8 03             	sar    $0x3,%eax
f0101669:	89 c2                	mov    %eax,%edx
f010166b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010166e:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101673:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f0101679:	0f 83 12 02 00 00    	jae    f0101891 <mem_init+0x573>
	return (void *)(pa + KERNBASE);
f010167f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101685:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010168b:	80 38 00             	cmpb   $0x0,(%eax)
f010168e:	0f 85 0f 02 00 00    	jne    f01018a3 <mem_init+0x585>
	for (i = 0; i < PGSIZE; i++)
f0101694:	83 c0 01             	add    $0x1,%eax
f0101697:	39 d0                	cmp    %edx,%eax
f0101699:	75 f0                	jne    f010168b <mem_init+0x36d>
	page_free_list = fl;
f010169b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010169e:	a3 6c c2 2b f0       	mov    %eax,0xf02bc26c
	page_free(pp0);
f01016a3:	83 ec 0c             	sub    $0xc,%esp
f01016a6:	56                   	push   %esi
f01016a7:	e8 10 f9 ff ff       	call   f0100fbc <page_free>
	page_free(pp1);
f01016ac:	89 3c 24             	mov    %edi,(%esp)
f01016af:	e8 08 f9 ff ff       	call   f0100fbc <page_free>
	page_free(pp2);
f01016b4:	83 c4 04             	add    $0x4,%esp
f01016b7:	ff 75 d4             	push   -0x2c(%ebp)
f01016ba:	e8 fd f8 ff ff       	call   f0100fbc <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016bf:	a1 6c c2 2b f0       	mov    0xf02bc26c,%eax
f01016c4:	83 c4 10             	add    $0x10,%esp
f01016c7:	85 c0                	test   %eax,%eax
f01016c9:	0f 84 ed 01 00 00    	je     f01018bc <mem_init+0x59e>
		--nfree;
f01016cf:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016d2:	8b 00                	mov    (%eax),%eax
f01016d4:	eb f1                	jmp    f01016c7 <mem_init+0x3a9>
	assert((pp0 = page_alloc(0)));
f01016d6:	68 41 76 10 f0       	push   $0xf0107641
f01016db:	68 55 75 10 f0       	push   $0xf0107555
f01016e0:	68 40 03 00 00       	push   $0x340
f01016e5:	68 2f 75 10 f0       	push   $0xf010752f
f01016ea:	e8 51 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016ef:	68 57 76 10 f0       	push   $0xf0107657
f01016f4:	68 55 75 10 f0       	push   $0xf0107555
f01016f9:	68 41 03 00 00       	push   $0x341
f01016fe:	68 2f 75 10 f0       	push   $0xf010752f
f0101703:	e8 38 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101708:	68 6d 76 10 f0       	push   $0xf010766d
f010170d:	68 55 75 10 f0       	push   $0xf0107555
f0101712:	68 42 03 00 00       	push   $0x342
f0101717:	68 2f 75 10 f0       	push   $0xf010752f
f010171c:	e8 1f e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101721:	68 83 76 10 f0       	push   $0xf0107683
f0101726:	68 55 75 10 f0       	push   $0xf0107555
f010172b:	68 45 03 00 00       	push   $0x345
f0101730:	68 2f 75 10 f0       	push   $0xf010752f
f0101735:	e8 06 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010173a:	68 f8 79 10 f0       	push   $0xf01079f8
f010173f:	68 55 75 10 f0       	push   $0xf0107555
f0101744:	68 46 03 00 00       	push   $0x346
f0101749:	68 2f 75 10 f0       	push   $0xf010752f
f010174e:	e8 ed e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101753:	68 95 76 10 f0       	push   $0xf0107695
f0101758:	68 55 75 10 f0       	push   $0xf0107555
f010175d:	68 47 03 00 00       	push   $0x347
f0101762:	68 2f 75 10 f0       	push   $0xf010752f
f0101767:	e8 d4 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010176c:	68 b2 76 10 f0       	push   $0xf01076b2
f0101771:	68 55 75 10 f0       	push   $0xf0107555
f0101776:	68 48 03 00 00       	push   $0x348
f010177b:	68 2f 75 10 f0       	push   $0xf010752f
f0101780:	e8 bb e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101785:	68 cf 76 10 f0       	push   $0xf01076cf
f010178a:	68 55 75 10 f0       	push   $0xf0107555
f010178f:	68 49 03 00 00       	push   $0x349
f0101794:	68 2f 75 10 f0       	push   $0xf010752f
f0101799:	e8 a2 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010179e:	68 ec 76 10 f0       	push   $0xf01076ec
f01017a3:	68 55 75 10 f0       	push   $0xf0107555
f01017a8:	68 50 03 00 00       	push   $0x350
f01017ad:	68 2f 75 10 f0       	push   $0xf010752f
f01017b2:	e8 89 e8 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01017b7:	68 41 76 10 f0       	push   $0xf0107641
f01017bc:	68 55 75 10 f0       	push   $0xf0107555
f01017c1:	68 57 03 00 00       	push   $0x357
f01017c6:	68 2f 75 10 f0       	push   $0xf010752f
f01017cb:	e8 70 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017d0:	68 57 76 10 f0       	push   $0xf0107657
f01017d5:	68 55 75 10 f0       	push   $0xf0107555
f01017da:	68 58 03 00 00       	push   $0x358
f01017df:	68 2f 75 10 f0       	push   $0xf010752f
f01017e4:	e8 57 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017e9:	68 6d 76 10 f0       	push   $0xf010766d
f01017ee:	68 55 75 10 f0       	push   $0xf0107555
f01017f3:	68 59 03 00 00       	push   $0x359
f01017f8:	68 2f 75 10 f0       	push   $0xf010752f
f01017fd:	e8 3e e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101802:	68 83 76 10 f0       	push   $0xf0107683
f0101807:	68 55 75 10 f0       	push   $0xf0107555
f010180c:	68 5b 03 00 00       	push   $0x35b
f0101811:	68 2f 75 10 f0       	push   $0xf010752f
f0101816:	e8 25 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010181b:	68 f8 79 10 f0       	push   $0xf01079f8
f0101820:	68 55 75 10 f0       	push   $0xf0107555
f0101825:	68 5c 03 00 00       	push   $0x35c
f010182a:	68 2f 75 10 f0       	push   $0xf010752f
f010182f:	e8 0c e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101834:	68 ec 76 10 f0       	push   $0xf01076ec
f0101839:	68 55 75 10 f0       	push   $0xf0107555
f010183e:	68 5d 03 00 00       	push   $0x35d
f0101843:	68 2f 75 10 f0       	push   $0xf010752f
f0101848:	e8 f3 e7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010184d:	52                   	push   %edx
f010184e:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0101853:	6a 5a                	push   $0x5a
f0101855:	68 3b 75 10 f0       	push   $0xf010753b
f010185a:	e8 e1 e7 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010185f:	68 fb 76 10 f0       	push   $0xf01076fb
f0101864:	68 55 75 10 f0       	push   $0xf0107555
f0101869:	68 62 03 00 00       	push   $0x362
f010186e:	68 2f 75 10 f0       	push   $0xf010752f
f0101873:	e8 c8 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101878:	68 19 77 10 f0       	push   $0xf0107719
f010187d:	68 55 75 10 f0       	push   $0xf0107555
f0101882:	68 63 03 00 00       	push   $0x363
f0101887:	68 2f 75 10 f0       	push   $0xf010752f
f010188c:	e8 af e7 ff ff       	call   f0100040 <_panic>
f0101891:	52                   	push   %edx
f0101892:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0101897:	6a 5a                	push   $0x5a
f0101899:	68 3b 75 10 f0       	push   $0xf010753b
f010189e:	e8 9d e7 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f01018a3:	68 29 77 10 f0       	push   $0xf0107729
f01018a8:	68 55 75 10 f0       	push   $0xf0107555
f01018ad:	68 66 03 00 00       	push   $0x366
f01018b2:	68 2f 75 10 f0       	push   $0xf010752f
f01018b7:	e8 84 e7 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f01018bc:	85 db                	test   %ebx,%ebx
f01018be:	0f 85 3f 09 00 00    	jne    f0102203 <mem_init+0xee5>
	cprintf("check_page_alloc() succeeded!\n");
f01018c4:	83 ec 0c             	sub    $0xc,%esp
f01018c7:	68 18 7a 10 f0       	push   $0xf0107a18
f01018cc:	e8 00 22 00 00       	call   f0103ad1 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018d8:	e8 6a f6 ff ff       	call   f0100f47 <page_alloc>
f01018dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018e0:	83 c4 10             	add    $0x10,%esp
f01018e3:	85 c0                	test   %eax,%eax
f01018e5:	0f 84 31 09 00 00    	je     f010221c <mem_init+0xefe>
	assert((pp1 = page_alloc(0)));
f01018eb:	83 ec 0c             	sub    $0xc,%esp
f01018ee:	6a 00                	push   $0x0
f01018f0:	e8 52 f6 ff ff       	call   f0100f47 <page_alloc>
f01018f5:	89 c3                	mov    %eax,%ebx
f01018f7:	83 c4 10             	add    $0x10,%esp
f01018fa:	85 c0                	test   %eax,%eax
f01018fc:	0f 84 33 09 00 00    	je     f0102235 <mem_init+0xf17>
	assert((pp2 = page_alloc(0)));
f0101902:	83 ec 0c             	sub    $0xc,%esp
f0101905:	6a 00                	push   $0x0
f0101907:	e8 3b f6 ff ff       	call   f0100f47 <page_alloc>
f010190c:	89 c6                	mov    %eax,%esi
f010190e:	83 c4 10             	add    $0x10,%esp
f0101911:	85 c0                	test   %eax,%eax
f0101913:	0f 84 35 09 00 00    	je     f010224e <mem_init+0xf30>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101919:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010191c:	0f 84 45 09 00 00    	je     f0102267 <mem_init+0xf49>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101922:	39 c3                	cmp    %eax,%ebx
f0101924:	0f 84 56 09 00 00    	je     f0102280 <mem_init+0xf62>
f010192a:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010192d:	0f 84 4d 09 00 00    	je     f0102280 <mem_init+0xf62>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101933:	a1 6c c2 2b f0       	mov    0xf02bc26c,%eax
f0101938:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f010193b:	c7 05 6c c2 2b f0 00 	movl   $0x0,0xf02bc26c
f0101942:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101945:	83 ec 0c             	sub    $0xc,%esp
f0101948:	6a 00                	push   $0x0
f010194a:	e8 f8 f5 ff ff       	call   f0100f47 <page_alloc>
f010194f:	83 c4 10             	add    $0x10,%esp
f0101952:	85 c0                	test   %eax,%eax
f0101954:	0f 85 3f 09 00 00    	jne    f0102299 <mem_init+0xf7b>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010195a:	83 ec 04             	sub    $0x4,%esp
f010195d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101960:	50                   	push   %eax
f0101961:	6a 00                	push   $0x0
f0101963:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0101969:	e8 0d f8 ff ff       	call   f010117b <page_lookup>
f010196e:	83 c4 10             	add    $0x10,%esp
f0101971:	85 c0                	test   %eax,%eax
f0101973:	0f 85 39 09 00 00    	jne    f01022b2 <mem_init+0xf94>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101979:	6a 02                	push   $0x2
f010197b:	6a 00                	push   $0x0
f010197d:	53                   	push   %ebx
f010197e:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0101984:	e8 cc f8 ff ff       	call   f0101255 <page_insert>
f0101989:	83 c4 10             	add    $0x10,%esp
f010198c:	85 c0                	test   %eax,%eax
f010198e:	0f 89 37 09 00 00    	jns    f01022cb <mem_init+0xfad>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101994:	83 ec 0c             	sub    $0xc,%esp
f0101997:	ff 75 d4             	push   -0x2c(%ebp)
f010199a:	e8 1d f6 ff ff       	call   f0100fbc <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010199f:	6a 02                	push   $0x2
f01019a1:	6a 00                	push   $0x0
f01019a3:	53                   	push   %ebx
f01019a4:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f01019aa:	e8 a6 f8 ff ff       	call   f0101255 <page_insert>
f01019af:	83 c4 20             	add    $0x20,%esp
f01019b2:	85 c0                	test   %eax,%eax
f01019b4:	0f 85 2a 09 00 00    	jne    f01022e4 <mem_init+0xfc6>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019ba:	8b 3d 5c c2 2b f0    	mov    0xf02bc25c,%edi
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f01019c0:	8b 0d 58 c2 2b f0    	mov    0xf02bc258,%ecx
f01019c6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01019c9:	8b 17                	mov    (%edi),%edx
f01019cb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019d4:	29 c8                	sub    %ecx,%eax
f01019d6:	c1 f8 03             	sar    $0x3,%eax
f01019d9:	c1 e0 0c             	shl    $0xc,%eax
f01019dc:	39 c2                	cmp    %eax,%edx
f01019de:	0f 85 19 09 00 00    	jne    f01022fd <mem_init+0xfdf>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01019e9:	89 f8                	mov    %edi,%eax
f01019eb:	e8 4d f1 ff ff       	call   f0100b3d <check_va2pa>
f01019f0:	89 c2                	mov    %eax,%edx
f01019f2:	89 d8                	mov    %ebx,%eax
f01019f4:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01019f7:	c1 f8 03             	sar    $0x3,%eax
f01019fa:	c1 e0 0c             	shl    $0xc,%eax
f01019fd:	39 c2                	cmp    %eax,%edx
f01019ff:	0f 85 11 09 00 00    	jne    f0102316 <mem_init+0xff8>
	assert(pp1->pp_ref == 1);
f0101a05:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a0a:	0f 85 1f 09 00 00    	jne    f010232f <mem_init+0x1011>
	assert(pp0->pp_ref == 1);
f0101a10:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a13:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a18:	0f 85 2a 09 00 00    	jne    f0102348 <mem_init+0x102a>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a1e:	6a 02                	push   $0x2
f0101a20:	68 00 10 00 00       	push   $0x1000
f0101a25:	56                   	push   %esi
f0101a26:	57                   	push   %edi
f0101a27:	e8 29 f8 ff ff       	call   f0101255 <page_insert>
f0101a2c:	83 c4 10             	add    $0x10,%esp
f0101a2f:	85 c0                	test   %eax,%eax
f0101a31:	0f 85 2a 09 00 00    	jne    f0102361 <mem_init+0x1043>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a37:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a3c:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
f0101a41:	e8 f7 f0 ff ff       	call   f0100b3d <check_va2pa>
f0101a46:	89 c2                	mov    %eax,%edx
f0101a48:	89 f0                	mov    %esi,%eax
f0101a4a:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f0101a50:	c1 f8 03             	sar    $0x3,%eax
f0101a53:	c1 e0 0c             	shl    $0xc,%eax
f0101a56:	39 c2                	cmp    %eax,%edx
f0101a58:	0f 85 1c 09 00 00    	jne    f010237a <mem_init+0x105c>
	assert(pp2->pp_ref == 1);
f0101a5e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a63:	0f 85 2a 09 00 00    	jne    f0102393 <mem_init+0x1075>

	// should be no free memory
	assert(!page_alloc(0));
f0101a69:	83 ec 0c             	sub    $0xc,%esp
f0101a6c:	6a 00                	push   $0x0
f0101a6e:	e8 d4 f4 ff ff       	call   f0100f47 <page_alloc>
f0101a73:	83 c4 10             	add    $0x10,%esp
f0101a76:	85 c0                	test   %eax,%eax
f0101a78:	0f 85 2e 09 00 00    	jne    f01023ac <mem_init+0x108e>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a7e:	6a 02                	push   $0x2
f0101a80:	68 00 10 00 00       	push   $0x1000
f0101a85:	56                   	push   %esi
f0101a86:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0101a8c:	e8 c4 f7 ff ff       	call   f0101255 <page_insert>
f0101a91:	83 c4 10             	add    $0x10,%esp
f0101a94:	85 c0                	test   %eax,%eax
f0101a96:	0f 85 29 09 00 00    	jne    f01023c5 <mem_init+0x10a7>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a9c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aa1:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
f0101aa6:	e8 92 f0 ff ff       	call   f0100b3d <check_va2pa>
f0101aab:	89 c2                	mov    %eax,%edx
f0101aad:	89 f0                	mov    %esi,%eax
f0101aaf:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f0101ab5:	c1 f8 03             	sar    $0x3,%eax
f0101ab8:	c1 e0 0c             	shl    $0xc,%eax
f0101abb:	39 c2                	cmp    %eax,%edx
f0101abd:	0f 85 1b 09 00 00    	jne    f01023de <mem_init+0x10c0>
	assert(pp2->pp_ref == 1);
f0101ac3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ac8:	0f 85 29 09 00 00    	jne    f01023f7 <mem_init+0x10d9>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ace:	83 ec 0c             	sub    $0xc,%esp
f0101ad1:	6a 00                	push   $0x0
f0101ad3:	e8 6f f4 ff ff       	call   f0100f47 <page_alloc>
f0101ad8:	83 c4 10             	add    $0x10,%esp
f0101adb:	85 c0                	test   %eax,%eax
f0101add:	0f 85 2d 09 00 00    	jne    f0102410 <mem_init+0x10f2>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ae3:	8b 15 5c c2 2b f0    	mov    0xf02bc25c,%edx
f0101ae9:	8b 02                	mov    (%edx),%eax
f0101aeb:	89 c7                	mov    %eax,%edi
f0101aed:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0101af3:	c1 e8 0c             	shr    $0xc,%eax
f0101af6:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f0101afc:	0f 83 27 09 00 00    	jae    f0102429 <mem_init+0x110b>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b02:	83 ec 04             	sub    $0x4,%esp
f0101b05:	6a 00                	push   $0x0
f0101b07:	68 00 10 00 00       	push   $0x1000
f0101b0c:	52                   	push   %edx
f0101b0d:	e8 29 f5 ff ff       	call   f010103b <pgdir_walk>
f0101b12:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0101b18:	83 c4 10             	add    $0x10,%esp
f0101b1b:	39 f8                	cmp    %edi,%eax
f0101b1d:	0f 85 1b 09 00 00    	jne    f010243e <mem_init+0x1120>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b23:	6a 06                	push   $0x6
f0101b25:	68 00 10 00 00       	push   $0x1000
f0101b2a:	56                   	push   %esi
f0101b2b:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0101b31:	e8 1f f7 ff ff       	call   f0101255 <page_insert>
f0101b36:	83 c4 10             	add    $0x10,%esp
f0101b39:	85 c0                	test   %eax,%eax
f0101b3b:	0f 85 16 09 00 00    	jne    f0102457 <mem_init+0x1139>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b41:	8b 3d 5c c2 2b f0    	mov    0xf02bc25c,%edi
f0101b47:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b4c:	89 f8                	mov    %edi,%eax
f0101b4e:	e8 ea ef ff ff       	call   f0100b3d <check_va2pa>
f0101b53:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101b55:	89 f0                	mov    %esi,%eax
f0101b57:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f0101b5d:	c1 f8 03             	sar    $0x3,%eax
f0101b60:	c1 e0 0c             	shl    $0xc,%eax
f0101b63:	39 c2                	cmp    %eax,%edx
f0101b65:	0f 85 05 09 00 00    	jne    f0102470 <mem_init+0x1152>
	assert(pp2->pp_ref == 1);
f0101b6b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b70:	0f 85 13 09 00 00    	jne    f0102489 <mem_init+0x116b>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b76:	83 ec 04             	sub    $0x4,%esp
f0101b79:	6a 00                	push   $0x0
f0101b7b:	68 00 10 00 00       	push   $0x1000
f0101b80:	57                   	push   %edi
f0101b81:	e8 b5 f4 ff ff       	call   f010103b <pgdir_walk>
f0101b86:	83 c4 10             	add    $0x10,%esp
f0101b89:	f6 00 04             	testb  $0x4,(%eax)
f0101b8c:	0f 84 10 09 00 00    	je     f01024a2 <mem_init+0x1184>
	assert(kern_pgdir[0] & PTE_U);
f0101b92:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
f0101b97:	f6 00 04             	testb  $0x4,(%eax)
f0101b9a:	0f 84 1b 09 00 00    	je     f01024bb <mem_init+0x119d>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ba0:	6a 02                	push   $0x2
f0101ba2:	68 00 10 00 00       	push   $0x1000
f0101ba7:	56                   	push   %esi
f0101ba8:	50                   	push   %eax
f0101ba9:	e8 a7 f6 ff ff       	call   f0101255 <page_insert>
f0101bae:	83 c4 10             	add    $0x10,%esp
f0101bb1:	85 c0                	test   %eax,%eax
f0101bb3:	0f 85 1b 09 00 00    	jne    f01024d4 <mem_init+0x11b6>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101bb9:	83 ec 04             	sub    $0x4,%esp
f0101bbc:	6a 00                	push   $0x0
f0101bbe:	68 00 10 00 00       	push   $0x1000
f0101bc3:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0101bc9:	e8 6d f4 ff ff       	call   f010103b <pgdir_walk>
f0101bce:	83 c4 10             	add    $0x10,%esp
f0101bd1:	f6 00 02             	testb  $0x2,(%eax)
f0101bd4:	0f 84 13 09 00 00    	je     f01024ed <mem_init+0x11cf>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bda:	83 ec 04             	sub    $0x4,%esp
f0101bdd:	6a 00                	push   $0x0
f0101bdf:	68 00 10 00 00       	push   $0x1000
f0101be4:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0101bea:	e8 4c f4 ff ff       	call   f010103b <pgdir_walk>
f0101bef:	83 c4 10             	add    $0x10,%esp
f0101bf2:	f6 00 04             	testb  $0x4,(%eax)
f0101bf5:	0f 85 0b 09 00 00    	jne    f0102506 <mem_init+0x11e8>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101bfb:	6a 02                	push   $0x2
f0101bfd:	68 00 00 40 00       	push   $0x400000
f0101c02:	ff 75 d4             	push   -0x2c(%ebp)
f0101c05:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0101c0b:	e8 45 f6 ff ff       	call   f0101255 <page_insert>
f0101c10:	83 c4 10             	add    $0x10,%esp
f0101c13:	85 c0                	test   %eax,%eax
f0101c15:	0f 89 04 09 00 00    	jns    f010251f <mem_init+0x1201>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c1b:	6a 02                	push   $0x2
f0101c1d:	68 00 10 00 00       	push   $0x1000
f0101c22:	53                   	push   %ebx
f0101c23:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0101c29:	e8 27 f6 ff ff       	call   f0101255 <page_insert>
f0101c2e:	83 c4 10             	add    $0x10,%esp
f0101c31:	85 c0                	test   %eax,%eax
f0101c33:	0f 85 ff 08 00 00    	jne    f0102538 <mem_init+0x121a>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c39:	83 ec 04             	sub    $0x4,%esp
f0101c3c:	6a 00                	push   $0x0
f0101c3e:	68 00 10 00 00       	push   $0x1000
f0101c43:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0101c49:	e8 ed f3 ff ff       	call   f010103b <pgdir_walk>
f0101c4e:	83 c4 10             	add    $0x10,%esp
f0101c51:	f6 00 04             	testb  $0x4,(%eax)
f0101c54:	0f 85 f7 08 00 00    	jne    f0102551 <mem_init+0x1233>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c5a:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
f0101c5f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c62:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c67:	e8 d1 ee ff ff       	call   f0100b3d <check_va2pa>
f0101c6c:	89 df                	mov    %ebx,%edi
f0101c6e:	2b 3d 58 c2 2b f0    	sub    0xf02bc258,%edi
f0101c74:	c1 ff 03             	sar    $0x3,%edi
f0101c77:	c1 e7 0c             	shl    $0xc,%edi
f0101c7a:	39 f8                	cmp    %edi,%eax
f0101c7c:	0f 85 e8 08 00 00    	jne    f010256a <mem_init+0x124c>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c82:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c87:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c8a:	e8 ae ee ff ff       	call   f0100b3d <check_va2pa>
f0101c8f:	39 c7                	cmp    %eax,%edi
f0101c91:	0f 85 ec 08 00 00    	jne    f0102583 <mem_init+0x1265>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c97:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101c9c:	0f 85 fa 08 00 00    	jne    f010259c <mem_init+0x127e>
	assert(pp2->pp_ref == 0);
f0101ca2:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ca7:	0f 85 08 09 00 00    	jne    f01025b5 <mem_init+0x1297>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101cad:	83 ec 0c             	sub    $0xc,%esp
f0101cb0:	6a 00                	push   $0x0
f0101cb2:	e8 90 f2 ff ff       	call   f0100f47 <page_alloc>
f0101cb7:	83 c4 10             	add    $0x10,%esp
f0101cba:	39 c6                	cmp    %eax,%esi
f0101cbc:	0f 85 0c 09 00 00    	jne    f01025ce <mem_init+0x12b0>
f0101cc2:	85 c0                	test   %eax,%eax
f0101cc4:	0f 84 04 09 00 00    	je     f01025ce <mem_init+0x12b0>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101cca:	83 ec 08             	sub    $0x8,%esp
f0101ccd:	6a 00                	push   $0x0
f0101ccf:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0101cd5:	e8 35 f5 ff ff       	call   f010120f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cda:	8b 3d 5c c2 2b f0    	mov    0xf02bc25c,%edi
f0101ce0:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ce5:	89 f8                	mov    %edi,%eax
f0101ce7:	e8 51 ee ff ff       	call   f0100b3d <check_va2pa>
f0101cec:	83 c4 10             	add    $0x10,%esp
f0101cef:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cf2:	0f 85 ef 08 00 00    	jne    f01025e7 <mem_init+0x12c9>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cf8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cfd:	89 f8                	mov    %edi,%eax
f0101cff:	e8 39 ee ff ff       	call   f0100b3d <check_va2pa>
f0101d04:	89 c2                	mov    %eax,%edx
f0101d06:	89 d8                	mov    %ebx,%eax
f0101d08:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f0101d0e:	c1 f8 03             	sar    $0x3,%eax
f0101d11:	c1 e0 0c             	shl    $0xc,%eax
f0101d14:	39 c2                	cmp    %eax,%edx
f0101d16:	0f 85 e4 08 00 00    	jne    f0102600 <mem_init+0x12e2>
	assert(pp1->pp_ref == 1);
f0101d1c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d21:	0f 85 f2 08 00 00    	jne    f0102619 <mem_init+0x12fb>
	assert(pp2->pp_ref == 0);
f0101d27:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d2c:	0f 85 00 09 00 00    	jne    f0102632 <mem_init+0x1314>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d32:	6a 00                	push   $0x0
f0101d34:	68 00 10 00 00       	push   $0x1000
f0101d39:	53                   	push   %ebx
f0101d3a:	57                   	push   %edi
f0101d3b:	e8 15 f5 ff ff       	call   f0101255 <page_insert>
f0101d40:	83 c4 10             	add    $0x10,%esp
f0101d43:	85 c0                	test   %eax,%eax
f0101d45:	0f 85 00 09 00 00    	jne    f010264b <mem_init+0x132d>
	assert(pp1->pp_ref);
f0101d4b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d50:	0f 84 0e 09 00 00    	je     f0102664 <mem_init+0x1346>
	assert(pp1->pp_link == NULL);
f0101d56:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101d59:	0f 85 1e 09 00 00    	jne    f010267d <mem_init+0x135f>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d5f:	83 ec 08             	sub    $0x8,%esp
f0101d62:	68 00 10 00 00       	push   $0x1000
f0101d67:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0101d6d:	e8 9d f4 ff ff       	call   f010120f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d72:	8b 3d 5c c2 2b f0    	mov    0xf02bc25c,%edi
f0101d78:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d7d:	89 f8                	mov    %edi,%eax
f0101d7f:	e8 b9 ed ff ff       	call   f0100b3d <check_va2pa>
f0101d84:	83 c4 10             	add    $0x10,%esp
f0101d87:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d8a:	0f 85 06 09 00 00    	jne    f0102696 <mem_init+0x1378>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d90:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d95:	89 f8                	mov    %edi,%eax
f0101d97:	e8 a1 ed ff ff       	call   f0100b3d <check_va2pa>
f0101d9c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d9f:	0f 85 0a 09 00 00    	jne    f01026af <mem_init+0x1391>
	assert(pp1->pp_ref == 0);
f0101da5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101daa:	0f 85 18 09 00 00    	jne    f01026c8 <mem_init+0x13aa>
	assert(pp2->pp_ref == 0);
f0101db0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101db5:	0f 85 26 09 00 00    	jne    f01026e1 <mem_init+0x13c3>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101dbb:	83 ec 0c             	sub    $0xc,%esp
f0101dbe:	6a 00                	push   $0x0
f0101dc0:	e8 82 f1 ff ff       	call   f0100f47 <page_alloc>
f0101dc5:	83 c4 10             	add    $0x10,%esp
f0101dc8:	85 c0                	test   %eax,%eax
f0101dca:	0f 84 2a 09 00 00    	je     f01026fa <mem_init+0x13dc>
f0101dd0:	39 c3                	cmp    %eax,%ebx
f0101dd2:	0f 85 22 09 00 00    	jne    f01026fa <mem_init+0x13dc>

	// should be no free memory
	assert(!page_alloc(0));
f0101dd8:	83 ec 0c             	sub    $0xc,%esp
f0101ddb:	6a 00                	push   $0x0
f0101ddd:	e8 65 f1 ff ff       	call   f0100f47 <page_alloc>
f0101de2:	83 c4 10             	add    $0x10,%esp
f0101de5:	85 c0                	test   %eax,%eax
f0101de7:	0f 85 26 09 00 00    	jne    f0102713 <mem_init+0x13f5>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ded:	8b 0d 5c c2 2b f0    	mov    0xf02bc25c,%ecx
f0101df3:	8b 11                	mov    (%ecx),%edx
f0101df5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101dfb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dfe:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f0101e04:	c1 f8 03             	sar    $0x3,%eax
f0101e07:	c1 e0 0c             	shl    $0xc,%eax
f0101e0a:	39 c2                	cmp    %eax,%edx
f0101e0c:	0f 85 1a 09 00 00    	jne    f010272c <mem_init+0x140e>
	kern_pgdir[0] = 0;
f0101e12:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101e18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e1b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e20:	0f 85 1f 09 00 00    	jne    f0102745 <mem_init+0x1427>
	pp0->pp_ref = 0;
f0101e26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e29:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101e2f:	83 ec 0c             	sub    $0xc,%esp
f0101e32:	50                   	push   %eax
f0101e33:	e8 84 f1 ff ff       	call   f0100fbc <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e38:	83 c4 0c             	add    $0xc,%esp
f0101e3b:	6a 01                	push   $0x1
f0101e3d:	68 00 10 40 00       	push   $0x401000
f0101e42:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0101e48:	e8 ee f1 ff ff       	call   f010103b <pgdir_walk>
f0101e4d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101e50:	8b 0d 5c c2 2b f0    	mov    0xf02bc25c,%ecx
f0101e56:	8b 41 04             	mov    0x4(%ecx),%eax
f0101e59:	89 c7                	mov    %eax,%edi
f0101e5b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0101e61:	8b 15 60 c2 2b f0    	mov    0xf02bc260,%edx
f0101e67:	c1 e8 0c             	shr    $0xc,%eax
f0101e6a:	83 c4 10             	add    $0x10,%esp
f0101e6d:	39 d0                	cmp    %edx,%eax
f0101e6f:	0f 83 e9 08 00 00    	jae    f010275e <mem_init+0x1440>
	assert(ptep == ptep1 + PTX(va));
f0101e75:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0101e7b:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101e7e:	0f 85 ef 08 00 00    	jne    f0102773 <mem_init+0x1455>
	kern_pgdir[PDX(va)] = 0;
f0101e84:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101e8b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e8e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101e94:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f0101e9a:	c1 f8 03             	sar    $0x3,%eax
f0101e9d:	89 c1                	mov    %eax,%ecx
f0101e9f:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f0101ea2:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101ea7:	39 c2                	cmp    %eax,%edx
f0101ea9:	0f 86 dd 08 00 00    	jbe    f010278c <mem_init+0x146e>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101eaf:	83 ec 04             	sub    $0x4,%esp
f0101eb2:	68 00 10 00 00       	push   $0x1000
f0101eb7:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101ebc:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101ec2:	51                   	push   %ecx
f0101ec3:	e8 25 3c 00 00       	call   f0105aed <memset>
	page_free(pp0);
f0101ec8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101ecb:	89 3c 24             	mov    %edi,(%esp)
f0101ece:	e8 e9 f0 ff ff       	call   f0100fbc <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101ed3:	83 c4 0c             	add    $0xc,%esp
f0101ed6:	6a 01                	push   $0x1
f0101ed8:	6a 00                	push   $0x0
f0101eda:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0101ee0:	e8 56 f1 ff ff       	call   f010103b <pgdir_walk>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101ee5:	89 f8                	mov    %edi,%eax
f0101ee7:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f0101eed:	c1 f8 03             	sar    $0x3,%eax
f0101ef0:	89 c2                	mov    %eax,%edx
f0101ef2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101ef5:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101efa:	83 c4 10             	add    $0x10,%esp
f0101efd:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f0101f03:	0f 83 95 08 00 00    	jae    f010279e <mem_init+0x1480>
	return (void *)(pa + KERNBASE);
f0101f09:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101f0f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101f15:	f6 00 01             	testb  $0x1,(%eax)
f0101f18:	0f 85 92 08 00 00    	jne    f01027b0 <mem_init+0x1492>
	for(i=0; i<NPTENTRIES; i++)
f0101f1e:	83 c0 04             	add    $0x4,%eax
f0101f21:	39 d0                	cmp    %edx,%eax
f0101f23:	75 f0                	jne    f0101f15 <mem_init+0xbf7>
	kern_pgdir[0] = 0;
f0101f25:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
f0101f2a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101f30:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f33:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101f39:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101f3c:	89 0d 6c c2 2b f0    	mov    %ecx,0xf02bc26c

	// free the pages we took
	page_free(pp0);
f0101f42:	83 ec 0c             	sub    $0xc,%esp
f0101f45:	50                   	push   %eax
f0101f46:	e8 71 f0 ff ff       	call   f0100fbc <page_free>
	page_free(pp1);
f0101f4b:	89 1c 24             	mov    %ebx,(%esp)
f0101f4e:	e8 69 f0 ff ff       	call   f0100fbc <page_free>
	page_free(pp2);
f0101f53:	89 34 24             	mov    %esi,(%esp)
f0101f56:	e8 61 f0 ff ff       	call   f0100fbc <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101f5b:	83 c4 08             	add    $0x8,%esp
f0101f5e:	68 01 10 00 00       	push   $0x1001
f0101f63:	6a 00                	push   $0x0
f0101f65:	e8 51 f3 ff ff       	call   f01012bb <mmio_map_region>
f0101f6a:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101f6c:	83 c4 08             	add    $0x8,%esp
f0101f6f:	68 00 10 00 00       	push   $0x1000
f0101f74:	6a 00                	push   $0x0
f0101f76:	e8 40 f3 ff ff       	call   f01012bb <mmio_map_region>
f0101f7b:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101f7d:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f83:	83 c4 10             	add    $0x10,%esp
f0101f86:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f8c:	0f 86 37 08 00 00    	jbe    f01027c9 <mem_init+0x14ab>
f0101f92:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f97:	0f 87 2c 08 00 00    	ja     f01027c9 <mem_init+0x14ab>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f9d:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101fa3:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101fa9:	0f 87 33 08 00 00    	ja     f01027e2 <mem_init+0x14c4>
f0101faf:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101fb5:	0f 86 27 08 00 00    	jbe    f01027e2 <mem_init+0x14c4>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101fbb:	89 da                	mov    %ebx,%edx
f0101fbd:	09 f2                	or     %esi,%edx
f0101fbf:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101fc5:	0f 85 30 08 00 00    	jne    f01027fb <mem_init+0x14dd>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101fcb:	39 c6                	cmp    %eax,%esi
f0101fcd:	0f 82 41 08 00 00    	jb     f0102814 <mem_init+0x14f6>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101fd3:	8b 3d 5c c2 2b f0    	mov    0xf02bc25c,%edi
f0101fd9:	89 da                	mov    %ebx,%edx
f0101fdb:	89 f8                	mov    %edi,%eax
f0101fdd:	e8 5b eb ff ff       	call   f0100b3d <check_va2pa>
f0101fe2:	85 c0                	test   %eax,%eax
f0101fe4:	0f 85 43 08 00 00    	jne    f010282d <mem_init+0x150f>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101fea:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101ff0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ff3:	89 c2                	mov    %eax,%edx
f0101ff5:	89 f8                	mov    %edi,%eax
f0101ff7:	e8 41 eb ff ff       	call   f0100b3d <check_va2pa>
f0101ffc:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102001:	0f 85 3f 08 00 00    	jne    f0102846 <mem_init+0x1528>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102007:	89 f2                	mov    %esi,%edx
f0102009:	89 f8                	mov    %edi,%eax
f010200b:	e8 2d eb ff ff       	call   f0100b3d <check_va2pa>
f0102010:	85 c0                	test   %eax,%eax
f0102012:	0f 85 47 08 00 00    	jne    f010285f <mem_init+0x1541>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102018:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010201e:	89 f8                	mov    %edi,%eax
f0102020:	e8 18 eb ff ff       	call   f0100b3d <check_va2pa>
f0102025:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102028:	0f 85 4a 08 00 00    	jne    f0102878 <mem_init+0x155a>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010202e:	83 ec 04             	sub    $0x4,%esp
f0102031:	6a 00                	push   $0x0
f0102033:	53                   	push   %ebx
f0102034:	57                   	push   %edi
f0102035:	e8 01 f0 ff ff       	call   f010103b <pgdir_walk>
f010203a:	83 c4 10             	add    $0x10,%esp
f010203d:	f6 00 1a             	testb  $0x1a,(%eax)
f0102040:	0f 84 4b 08 00 00    	je     f0102891 <mem_init+0x1573>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102046:	83 ec 04             	sub    $0x4,%esp
f0102049:	6a 00                	push   $0x0
f010204b:	53                   	push   %ebx
f010204c:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0102052:	e8 e4 ef ff ff       	call   f010103b <pgdir_walk>
f0102057:	8b 00                	mov    (%eax),%eax
f0102059:	83 c4 10             	add    $0x10,%esp
f010205c:	83 e0 04             	and    $0x4,%eax
f010205f:	89 c7                	mov    %eax,%edi
f0102061:	0f 85 43 08 00 00    	jne    f01028aa <mem_init+0x158c>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102067:	83 ec 04             	sub    $0x4,%esp
f010206a:	6a 00                	push   $0x0
f010206c:	53                   	push   %ebx
f010206d:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0102073:	e8 c3 ef ff ff       	call   f010103b <pgdir_walk>
f0102078:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010207e:	83 c4 0c             	add    $0xc,%esp
f0102081:	6a 00                	push   $0x0
f0102083:	ff 75 d4             	push   -0x2c(%ebp)
f0102086:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f010208c:	e8 aa ef ff ff       	call   f010103b <pgdir_walk>
f0102091:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102097:	83 c4 0c             	add    $0xc,%esp
f010209a:	6a 00                	push   $0x0
f010209c:	56                   	push   %esi
f010209d:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f01020a3:	e8 93 ef ff ff       	call   f010103b <pgdir_walk>
f01020a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01020ae:	c7 04 24 1c 78 10 f0 	movl   $0xf010781c,(%esp)
f01020b5:	e8 17 1a 00 00       	call   f0103ad1 <cprintf>
	boot_map_region(kern_pgdir, UPAGES,ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE) , PADDR(pages), PTE_U | PTE_P);//但其实按照memlayout.h中的图，直接用PTSIZE也一样。因为PTSIZE远超过所需内存了，并且按图来说，其空闲内存也无他用，这里就正常写。
f01020ba:	a1 58 c2 2b f0       	mov    0xf02bc258,%eax
	if ((uint32_t)kva < KERNBASE)
f01020bf:	83 c4 10             	add    $0x10,%esp
f01020c2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020c7:	0f 86 f6 07 00 00    	jbe    f01028c3 <mem_init+0x15a5>
f01020cd:	8b 15 60 c2 2b f0    	mov    0xf02bc260,%edx
f01020d3:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f01020da:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01020e0:	83 ec 08             	sub    $0x8,%esp
f01020e3:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020e5:	05 00 00 00 10       	add    $0x10000000,%eax
f01020ea:	50                   	push   %eax
f01020eb:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020f0:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
f01020f5:	e8 1a f0 ff ff       	call   f0101114 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f01020fa:	a1 74 c2 2b f0       	mov    0xf02bc274,%eax
	if ((uint32_t)kva < KERNBASE)
f01020ff:	83 c4 10             	add    $0x10,%esp
f0102102:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102107:	0f 86 cb 07 00 00    	jbe    f01028d8 <mem_init+0x15ba>
f010210d:	83 ec 08             	sub    $0x8,%esp
f0102110:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102112:	05 00 00 00 10       	add    $0x10000000,%eax
f0102117:	50                   	push   %eax
f0102118:	b9 00 30 02 00       	mov    $0x23000,%ecx
f010211d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102122:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
f0102127:	e8 e8 ef ff ff       	call   f0101114 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f010212c:	83 c4 10             	add    $0x10,%esp
f010212f:	b8 00 f0 11 f0       	mov    $0xf011f000,%eax
f0102134:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102139:	0f 86 ae 07 00 00    	jbe    f01028ed <mem_init+0x15cf>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f010213f:	83 ec 08             	sub    $0x8,%esp
f0102142:	6a 02                	push   $0x2
f0102144:	68 00 f0 11 00       	push   $0x11f000
f0102149:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010214e:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102153:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
f0102158:	e8 b7 ef ff ff       	call   f0101114 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-KERNBASE , 0, PTE_W);
f010215d:	83 c4 08             	add    $0x8,%esp
f0102160:	6a 02                	push   $0x2
f0102162:	6a 00                	push   $0x0
f0102164:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102169:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010216e:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
f0102173:	e8 9c ef ff ff       	call   f0101114 <boot_map_region>
f0102178:	c7 45 c8 00 d0 2b f0 	movl   $0xf02bd000,-0x38(%ebp)
f010217f:	83 c4 10             	add    $0x10,%esp
f0102182:	bb 00 d0 2b f0       	mov    $0xf02bd000,%ebx
f0102187:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f010218c:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102192:	0f 86 6a 07 00 00    	jbe    f0102902 <mem_init+0x15e4>
		boot_map_region(kern_pgdir, 
f0102198:	83 ec 08             	sub    $0x8,%esp
f010219b:	6a 02                	push   $0x2
f010219d:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01021a3:	50                   	push   %eax
f01021a4:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01021a9:	89 f2                	mov    %esi,%edx
f01021ab:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
f01021b0:	e8 5f ef ff ff       	call   f0101114 <boot_map_region>
	for(size_t i = 0; i < NCPU; i++) {
f01021b5:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01021bb:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f01021c1:	83 c4 10             	add    $0x10,%esp
f01021c4:	81 fb 00 d0 2f f0    	cmp    $0xf02fd000,%ebx
f01021ca:	75 c0                	jne    f010218c <mem_init+0xe6e>
	pgdir = kern_pgdir;
f01021cc:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
f01021d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01021d4:	a1 60 c2 2b f0       	mov    0xf02bc260,%eax
f01021d9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01021dc:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01021e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021e8:	8b 35 58 c2 2b f0    	mov    0xf02bc258,%esi
	return (physaddr_t)kva - KERNBASE;
f01021ee:	8d 8e 00 00 00 10    	lea    0x10000000(%esi),%ecx
f01021f4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01021f7:	89 fb                	mov    %edi,%ebx
f01021f9:	89 7d cc             	mov    %edi,-0x34(%ebp)
f01021fc:	89 c7                	mov    %eax,%edi
f01021fe:	e9 2f 07 00 00       	jmp    f0102932 <mem_init+0x1614>
	assert(nfree == 0);
f0102203:	68 33 77 10 f0       	push   $0xf0107733
f0102208:	68 55 75 10 f0       	push   $0xf0107555
f010220d:	68 73 03 00 00       	push   $0x373
f0102212:	68 2f 75 10 f0       	push   $0xf010752f
f0102217:	e8 24 de ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010221c:	68 41 76 10 f0       	push   $0xf0107641
f0102221:	68 55 75 10 f0       	push   $0xf0107555
f0102226:	68 d9 03 00 00       	push   $0x3d9
f010222b:	68 2f 75 10 f0       	push   $0xf010752f
f0102230:	e8 0b de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102235:	68 57 76 10 f0       	push   $0xf0107657
f010223a:	68 55 75 10 f0       	push   $0xf0107555
f010223f:	68 da 03 00 00       	push   $0x3da
f0102244:	68 2f 75 10 f0       	push   $0xf010752f
f0102249:	e8 f2 dd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010224e:	68 6d 76 10 f0       	push   $0xf010766d
f0102253:	68 55 75 10 f0       	push   $0xf0107555
f0102258:	68 db 03 00 00       	push   $0x3db
f010225d:	68 2f 75 10 f0       	push   $0xf010752f
f0102262:	e8 d9 dd ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0102267:	68 83 76 10 f0       	push   $0xf0107683
f010226c:	68 55 75 10 f0       	push   $0xf0107555
f0102271:	68 de 03 00 00       	push   $0x3de
f0102276:	68 2f 75 10 f0       	push   $0xf010752f
f010227b:	e8 c0 dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102280:	68 f8 79 10 f0       	push   $0xf01079f8
f0102285:	68 55 75 10 f0       	push   $0xf0107555
f010228a:	68 df 03 00 00       	push   $0x3df
f010228f:	68 2f 75 10 f0       	push   $0xf010752f
f0102294:	e8 a7 dd ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102299:	68 ec 76 10 f0       	push   $0xf01076ec
f010229e:	68 55 75 10 f0       	push   $0xf0107555
f01022a3:	68 e6 03 00 00       	push   $0x3e6
f01022a8:	68 2f 75 10 f0       	push   $0xf010752f
f01022ad:	e8 8e dd ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01022b2:	68 38 7a 10 f0       	push   $0xf0107a38
f01022b7:	68 55 75 10 f0       	push   $0xf0107555
f01022bc:	68 e9 03 00 00       	push   $0x3e9
f01022c1:	68 2f 75 10 f0       	push   $0xf010752f
f01022c6:	e8 75 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01022cb:	68 70 7a 10 f0       	push   $0xf0107a70
f01022d0:	68 55 75 10 f0       	push   $0xf0107555
f01022d5:	68 ec 03 00 00       	push   $0x3ec
f01022da:	68 2f 75 10 f0       	push   $0xf010752f
f01022df:	e8 5c dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01022e4:	68 a0 7a 10 f0       	push   $0xf0107aa0
f01022e9:	68 55 75 10 f0       	push   $0xf0107555
f01022ee:	68 f0 03 00 00       	push   $0x3f0
f01022f3:	68 2f 75 10 f0       	push   $0xf010752f
f01022f8:	e8 43 dd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022fd:	68 d0 7a 10 f0       	push   $0xf0107ad0
f0102302:	68 55 75 10 f0       	push   $0xf0107555
f0102307:	68 f1 03 00 00       	push   $0x3f1
f010230c:	68 2f 75 10 f0       	push   $0xf010752f
f0102311:	e8 2a dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102316:	68 f8 7a 10 f0       	push   $0xf0107af8
f010231b:	68 55 75 10 f0       	push   $0xf0107555
f0102320:	68 f2 03 00 00       	push   $0x3f2
f0102325:	68 2f 75 10 f0       	push   $0xf010752f
f010232a:	e8 11 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010232f:	68 3e 77 10 f0       	push   $0xf010773e
f0102334:	68 55 75 10 f0       	push   $0xf0107555
f0102339:	68 f3 03 00 00       	push   $0x3f3
f010233e:	68 2f 75 10 f0       	push   $0xf010752f
f0102343:	e8 f8 dc ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102348:	68 4f 77 10 f0       	push   $0xf010774f
f010234d:	68 55 75 10 f0       	push   $0xf0107555
f0102352:	68 f4 03 00 00       	push   $0x3f4
f0102357:	68 2f 75 10 f0       	push   $0xf010752f
f010235c:	e8 df dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102361:	68 28 7b 10 f0       	push   $0xf0107b28
f0102366:	68 55 75 10 f0       	push   $0xf0107555
f010236b:	68 f7 03 00 00       	push   $0x3f7
f0102370:	68 2f 75 10 f0       	push   $0xf010752f
f0102375:	e8 c6 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010237a:	68 64 7b 10 f0       	push   $0xf0107b64
f010237f:	68 55 75 10 f0       	push   $0xf0107555
f0102384:	68 f8 03 00 00       	push   $0x3f8
f0102389:	68 2f 75 10 f0       	push   $0xf010752f
f010238e:	e8 ad dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102393:	68 60 77 10 f0       	push   $0xf0107760
f0102398:	68 55 75 10 f0       	push   $0xf0107555
f010239d:	68 f9 03 00 00       	push   $0x3f9
f01023a2:	68 2f 75 10 f0       	push   $0xf010752f
f01023a7:	e8 94 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01023ac:	68 ec 76 10 f0       	push   $0xf01076ec
f01023b1:	68 55 75 10 f0       	push   $0xf0107555
f01023b6:	68 fc 03 00 00       	push   $0x3fc
f01023bb:	68 2f 75 10 f0       	push   $0xf010752f
f01023c0:	e8 7b dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023c5:	68 28 7b 10 f0       	push   $0xf0107b28
f01023ca:	68 55 75 10 f0       	push   $0xf0107555
f01023cf:	68 ff 03 00 00       	push   $0x3ff
f01023d4:	68 2f 75 10 f0       	push   $0xf010752f
f01023d9:	e8 62 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023de:	68 64 7b 10 f0       	push   $0xf0107b64
f01023e3:	68 55 75 10 f0       	push   $0xf0107555
f01023e8:	68 00 04 00 00       	push   $0x400
f01023ed:	68 2f 75 10 f0       	push   $0xf010752f
f01023f2:	e8 49 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01023f7:	68 60 77 10 f0       	push   $0xf0107760
f01023fc:	68 55 75 10 f0       	push   $0xf0107555
f0102401:	68 01 04 00 00       	push   $0x401
f0102406:	68 2f 75 10 f0       	push   $0xf010752f
f010240b:	e8 30 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102410:	68 ec 76 10 f0       	push   $0xf01076ec
f0102415:	68 55 75 10 f0       	push   $0xf0107555
f010241a:	68 05 04 00 00       	push   $0x405
f010241f:	68 2f 75 10 f0       	push   $0xf010752f
f0102424:	e8 17 dc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102429:	57                   	push   %edi
f010242a:	68 e4 6f 10 f0       	push   $0xf0106fe4
f010242f:	68 08 04 00 00       	push   $0x408
f0102434:	68 2f 75 10 f0       	push   $0xf010752f
f0102439:	e8 02 dc ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010243e:	68 94 7b 10 f0       	push   $0xf0107b94
f0102443:	68 55 75 10 f0       	push   $0xf0107555
f0102448:	68 09 04 00 00       	push   $0x409
f010244d:	68 2f 75 10 f0       	push   $0xf010752f
f0102452:	e8 e9 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102457:	68 d4 7b 10 f0       	push   $0xf0107bd4
f010245c:	68 55 75 10 f0       	push   $0xf0107555
f0102461:	68 0c 04 00 00       	push   $0x40c
f0102466:	68 2f 75 10 f0       	push   $0xf010752f
f010246b:	e8 d0 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102470:	68 64 7b 10 f0       	push   $0xf0107b64
f0102475:	68 55 75 10 f0       	push   $0xf0107555
f010247a:	68 0d 04 00 00       	push   $0x40d
f010247f:	68 2f 75 10 f0       	push   $0xf010752f
f0102484:	e8 b7 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102489:	68 60 77 10 f0       	push   $0xf0107760
f010248e:	68 55 75 10 f0       	push   $0xf0107555
f0102493:	68 0e 04 00 00       	push   $0x40e
f0102498:	68 2f 75 10 f0       	push   $0xf010752f
f010249d:	e8 9e db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01024a2:	68 14 7c 10 f0       	push   $0xf0107c14
f01024a7:	68 55 75 10 f0       	push   $0xf0107555
f01024ac:	68 0f 04 00 00       	push   $0x40f
f01024b1:	68 2f 75 10 f0       	push   $0xf010752f
f01024b6:	e8 85 db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024bb:	68 71 77 10 f0       	push   $0xf0107771
f01024c0:	68 55 75 10 f0       	push   $0xf0107555
f01024c5:	68 10 04 00 00       	push   $0x410
f01024ca:	68 2f 75 10 f0       	push   $0xf010752f
f01024cf:	e8 6c db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024d4:	68 28 7b 10 f0       	push   $0xf0107b28
f01024d9:	68 55 75 10 f0       	push   $0xf0107555
f01024de:	68 13 04 00 00       	push   $0x413
f01024e3:	68 2f 75 10 f0       	push   $0xf010752f
f01024e8:	e8 53 db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01024ed:	68 48 7c 10 f0       	push   $0xf0107c48
f01024f2:	68 55 75 10 f0       	push   $0xf0107555
f01024f7:	68 14 04 00 00       	push   $0x414
f01024fc:	68 2f 75 10 f0       	push   $0xf010752f
f0102501:	e8 3a db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102506:	68 7c 7c 10 f0       	push   $0xf0107c7c
f010250b:	68 55 75 10 f0       	push   $0xf0107555
f0102510:	68 15 04 00 00       	push   $0x415
f0102515:	68 2f 75 10 f0       	push   $0xf010752f
f010251a:	e8 21 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010251f:	68 b4 7c 10 f0       	push   $0xf0107cb4
f0102524:	68 55 75 10 f0       	push   $0xf0107555
f0102529:	68 18 04 00 00       	push   $0x418
f010252e:	68 2f 75 10 f0       	push   $0xf010752f
f0102533:	e8 08 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102538:	68 ec 7c 10 f0       	push   $0xf0107cec
f010253d:	68 55 75 10 f0       	push   $0xf0107555
f0102542:	68 1b 04 00 00       	push   $0x41b
f0102547:	68 2f 75 10 f0       	push   $0xf010752f
f010254c:	e8 ef da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102551:	68 7c 7c 10 f0       	push   $0xf0107c7c
f0102556:	68 55 75 10 f0       	push   $0xf0107555
f010255b:	68 1c 04 00 00       	push   $0x41c
f0102560:	68 2f 75 10 f0       	push   $0xf010752f
f0102565:	e8 d6 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010256a:	68 28 7d 10 f0       	push   $0xf0107d28
f010256f:	68 55 75 10 f0       	push   $0xf0107555
f0102574:	68 1f 04 00 00       	push   $0x41f
f0102579:	68 2f 75 10 f0       	push   $0xf010752f
f010257e:	e8 bd da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102583:	68 54 7d 10 f0       	push   $0xf0107d54
f0102588:	68 55 75 10 f0       	push   $0xf0107555
f010258d:	68 20 04 00 00       	push   $0x420
f0102592:	68 2f 75 10 f0       	push   $0xf010752f
f0102597:	e8 a4 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f010259c:	68 87 77 10 f0       	push   $0xf0107787
f01025a1:	68 55 75 10 f0       	push   $0xf0107555
f01025a6:	68 22 04 00 00       	push   $0x422
f01025ab:	68 2f 75 10 f0       	push   $0xf010752f
f01025b0:	e8 8b da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025b5:	68 98 77 10 f0       	push   $0xf0107798
f01025ba:	68 55 75 10 f0       	push   $0xf0107555
f01025bf:	68 23 04 00 00       	push   $0x423
f01025c4:	68 2f 75 10 f0       	push   $0xf010752f
f01025c9:	e8 72 da ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01025ce:	68 84 7d 10 f0       	push   $0xf0107d84
f01025d3:	68 55 75 10 f0       	push   $0xf0107555
f01025d8:	68 26 04 00 00       	push   $0x426
f01025dd:	68 2f 75 10 f0       	push   $0xf010752f
f01025e2:	e8 59 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025e7:	68 a8 7d 10 f0       	push   $0xf0107da8
f01025ec:	68 55 75 10 f0       	push   $0xf0107555
f01025f1:	68 2a 04 00 00       	push   $0x42a
f01025f6:	68 2f 75 10 f0       	push   $0xf010752f
f01025fb:	e8 40 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102600:	68 54 7d 10 f0       	push   $0xf0107d54
f0102605:	68 55 75 10 f0       	push   $0xf0107555
f010260a:	68 2b 04 00 00       	push   $0x42b
f010260f:	68 2f 75 10 f0       	push   $0xf010752f
f0102614:	e8 27 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102619:	68 3e 77 10 f0       	push   $0xf010773e
f010261e:	68 55 75 10 f0       	push   $0xf0107555
f0102623:	68 2c 04 00 00       	push   $0x42c
f0102628:	68 2f 75 10 f0       	push   $0xf010752f
f010262d:	e8 0e da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102632:	68 98 77 10 f0       	push   $0xf0107798
f0102637:	68 55 75 10 f0       	push   $0xf0107555
f010263c:	68 2d 04 00 00       	push   $0x42d
f0102641:	68 2f 75 10 f0       	push   $0xf010752f
f0102646:	e8 f5 d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010264b:	68 cc 7d 10 f0       	push   $0xf0107dcc
f0102650:	68 55 75 10 f0       	push   $0xf0107555
f0102655:	68 30 04 00 00       	push   $0x430
f010265a:	68 2f 75 10 f0       	push   $0xf010752f
f010265f:	e8 dc d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102664:	68 a9 77 10 f0       	push   $0xf01077a9
f0102669:	68 55 75 10 f0       	push   $0xf0107555
f010266e:	68 31 04 00 00       	push   $0x431
f0102673:	68 2f 75 10 f0       	push   $0xf010752f
f0102678:	e8 c3 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010267d:	68 b5 77 10 f0       	push   $0xf01077b5
f0102682:	68 55 75 10 f0       	push   $0xf0107555
f0102687:	68 32 04 00 00       	push   $0x432
f010268c:	68 2f 75 10 f0       	push   $0xf010752f
f0102691:	e8 aa d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102696:	68 a8 7d 10 f0       	push   $0xf0107da8
f010269b:	68 55 75 10 f0       	push   $0xf0107555
f01026a0:	68 36 04 00 00       	push   $0x436
f01026a5:	68 2f 75 10 f0       	push   $0xf010752f
f01026aa:	e8 91 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01026af:	68 04 7e 10 f0       	push   $0xf0107e04
f01026b4:	68 55 75 10 f0       	push   $0xf0107555
f01026b9:	68 37 04 00 00       	push   $0x437
f01026be:	68 2f 75 10 f0       	push   $0xf010752f
f01026c3:	e8 78 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01026c8:	68 ca 77 10 f0       	push   $0xf01077ca
f01026cd:	68 55 75 10 f0       	push   $0xf0107555
f01026d2:	68 38 04 00 00       	push   $0x438
f01026d7:	68 2f 75 10 f0       	push   $0xf010752f
f01026dc:	e8 5f d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026e1:	68 98 77 10 f0       	push   $0xf0107798
f01026e6:	68 55 75 10 f0       	push   $0xf0107555
f01026eb:	68 39 04 00 00       	push   $0x439
f01026f0:	68 2f 75 10 f0       	push   $0xf010752f
f01026f5:	e8 46 d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01026fa:	68 2c 7e 10 f0       	push   $0xf0107e2c
f01026ff:	68 55 75 10 f0       	push   $0xf0107555
f0102704:	68 3c 04 00 00       	push   $0x43c
f0102709:	68 2f 75 10 f0       	push   $0xf010752f
f010270e:	e8 2d d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102713:	68 ec 76 10 f0       	push   $0xf01076ec
f0102718:	68 55 75 10 f0       	push   $0xf0107555
f010271d:	68 3f 04 00 00       	push   $0x43f
f0102722:	68 2f 75 10 f0       	push   $0xf010752f
f0102727:	e8 14 d9 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010272c:	68 d0 7a 10 f0       	push   $0xf0107ad0
f0102731:	68 55 75 10 f0       	push   $0xf0107555
f0102736:	68 42 04 00 00       	push   $0x442
f010273b:	68 2f 75 10 f0       	push   $0xf010752f
f0102740:	e8 fb d8 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102745:	68 4f 77 10 f0       	push   $0xf010774f
f010274a:	68 55 75 10 f0       	push   $0xf0107555
f010274f:	68 44 04 00 00       	push   $0x444
f0102754:	68 2f 75 10 f0       	push   $0xf010752f
f0102759:	e8 e2 d8 ff ff       	call   f0100040 <_panic>
f010275e:	57                   	push   %edi
f010275f:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0102764:	68 4b 04 00 00       	push   $0x44b
f0102769:	68 2f 75 10 f0       	push   $0xf010752f
f010276e:	e8 cd d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102773:	68 db 77 10 f0       	push   $0xf01077db
f0102778:	68 55 75 10 f0       	push   $0xf0107555
f010277d:	68 4c 04 00 00       	push   $0x44c
f0102782:	68 2f 75 10 f0       	push   $0xf010752f
f0102787:	e8 b4 d8 ff ff       	call   f0100040 <_panic>
f010278c:	51                   	push   %ecx
f010278d:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0102792:	6a 5a                	push   $0x5a
f0102794:	68 3b 75 10 f0       	push   $0xf010753b
f0102799:	e8 a2 d8 ff ff       	call   f0100040 <_panic>
f010279e:	52                   	push   %edx
f010279f:	68 e4 6f 10 f0       	push   $0xf0106fe4
f01027a4:	6a 5a                	push   $0x5a
f01027a6:	68 3b 75 10 f0       	push   $0xf010753b
f01027ab:	e8 90 d8 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f01027b0:	68 f3 77 10 f0       	push   $0xf01077f3
f01027b5:	68 55 75 10 f0       	push   $0xf0107555
f01027ba:	68 56 04 00 00       	push   $0x456
f01027bf:	68 2f 75 10 f0       	push   $0xf010752f
f01027c4:	e8 77 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01027c9:	68 50 7e 10 f0       	push   $0xf0107e50
f01027ce:	68 55 75 10 f0       	push   $0xf0107555
f01027d3:	68 66 04 00 00       	push   $0x466
f01027d8:	68 2f 75 10 f0       	push   $0xf010752f
f01027dd:	e8 5e d8 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01027e2:	68 78 7e 10 f0       	push   $0xf0107e78
f01027e7:	68 55 75 10 f0       	push   $0xf0107555
f01027ec:	68 67 04 00 00       	push   $0x467
f01027f1:	68 2f 75 10 f0       	push   $0xf010752f
f01027f6:	e8 45 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01027fb:	68 a0 7e 10 f0       	push   $0xf0107ea0
f0102800:	68 55 75 10 f0       	push   $0xf0107555
f0102805:	68 69 04 00 00       	push   $0x469
f010280a:	68 2f 75 10 f0       	push   $0xf010752f
f010280f:	e8 2c d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f0102814:	68 0a 78 10 f0       	push   $0xf010780a
f0102819:	68 55 75 10 f0       	push   $0xf0107555
f010281e:	68 6b 04 00 00       	push   $0x46b
f0102823:	68 2f 75 10 f0       	push   $0xf010752f
f0102828:	e8 13 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010282d:	68 c8 7e 10 f0       	push   $0xf0107ec8
f0102832:	68 55 75 10 f0       	push   $0xf0107555
f0102837:	68 6d 04 00 00       	push   $0x46d
f010283c:	68 2f 75 10 f0       	push   $0xf010752f
f0102841:	e8 fa d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102846:	68 ec 7e 10 f0       	push   $0xf0107eec
f010284b:	68 55 75 10 f0       	push   $0xf0107555
f0102850:	68 6e 04 00 00       	push   $0x46e
f0102855:	68 2f 75 10 f0       	push   $0xf010752f
f010285a:	e8 e1 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010285f:	68 1c 7f 10 f0       	push   $0xf0107f1c
f0102864:	68 55 75 10 f0       	push   $0xf0107555
f0102869:	68 6f 04 00 00       	push   $0x46f
f010286e:	68 2f 75 10 f0       	push   $0xf010752f
f0102873:	e8 c8 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102878:	68 40 7f 10 f0       	push   $0xf0107f40
f010287d:	68 55 75 10 f0       	push   $0xf0107555
f0102882:	68 70 04 00 00       	push   $0x470
f0102887:	68 2f 75 10 f0       	push   $0xf010752f
f010288c:	e8 af d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102891:	68 6c 7f 10 f0       	push   $0xf0107f6c
f0102896:	68 55 75 10 f0       	push   $0xf0107555
f010289b:	68 72 04 00 00       	push   $0x472
f01028a0:	68 2f 75 10 f0       	push   $0xf010752f
f01028a5:	e8 96 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01028aa:	68 b0 7f 10 f0       	push   $0xf0107fb0
f01028af:	68 55 75 10 f0       	push   $0xf0107555
f01028b4:	68 73 04 00 00       	push   $0x473
f01028b9:	68 2f 75 10 f0       	push   $0xf010752f
f01028be:	e8 7d d7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028c3:	50                   	push   %eax
f01028c4:	68 08 70 10 f0       	push   $0xf0107008
f01028c9:	68 d8 00 00 00       	push   $0xd8
f01028ce:	68 2f 75 10 f0       	push   $0xf010752f
f01028d3:	e8 68 d7 ff ff       	call   f0100040 <_panic>
f01028d8:	50                   	push   %eax
f01028d9:	68 08 70 10 f0       	push   $0xf0107008
f01028de:	68 e2 00 00 00       	push   $0xe2
f01028e3:	68 2f 75 10 f0       	push   $0xf010752f
f01028e8:	e8 53 d7 ff ff       	call   f0100040 <_panic>
f01028ed:	50                   	push   %eax
f01028ee:	68 08 70 10 f0       	push   $0xf0107008
f01028f3:	68 f0 00 00 00       	push   $0xf0
f01028f8:	68 2f 75 10 f0       	push   $0xf010752f
f01028fd:	e8 3e d7 ff ff       	call   f0100040 <_panic>
f0102902:	53                   	push   %ebx
f0102903:	68 08 70 10 f0       	push   $0xf0107008
f0102908:	68 38 01 00 00       	push   $0x138
f010290d:	68 2f 75 10 f0       	push   $0xf010752f
f0102912:	e8 29 d7 ff ff       	call   f0100040 <_panic>
f0102917:	56                   	push   %esi
f0102918:	68 08 70 10 f0       	push   $0xf0107008
f010291d:	68 8b 03 00 00       	push   $0x38b
f0102922:	68 2f 75 10 f0       	push   $0xf010752f
f0102927:	e8 14 d7 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f010292c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102932:	39 df                	cmp    %ebx,%edi
f0102934:	76 39                	jbe    f010296f <mem_init+0x1651>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102936:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010293c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010293f:	e8 f9 e1 ff ff       	call   f0100b3d <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102944:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010294a:	76 cb                	jbe    f0102917 <mem_init+0x15f9>
f010294c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010294f:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102952:	39 d0                	cmp    %edx,%eax
f0102954:	74 d6                	je     f010292c <mem_init+0x160e>
f0102956:	68 e4 7f 10 f0       	push   $0xf0107fe4
f010295b:	68 55 75 10 f0       	push   $0xf0107555
f0102960:	68 8b 03 00 00       	push   $0x38b
f0102965:	68 2f 75 10 f0       	push   $0xf010752f
f010296a:	e8 d1 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010296f:	8b 35 74 c2 2b f0    	mov    0xf02bc274,%esi
f0102975:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010297a:	8d 86 00 00 40 21    	lea    0x21400000(%esi),%eax
f0102980:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102983:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102986:	89 da                	mov    %ebx,%edx
f0102988:	89 f8                	mov    %edi,%eax
f010298a:	e8 ae e1 ff ff       	call   f0100b3d <check_va2pa>
f010298f:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102995:	76 46                	jbe    f01029dd <mem_init+0x16bf>
f0102997:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010299a:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f010299d:	39 d0                	cmp    %edx,%eax
f010299f:	75 51                	jne    f01029f2 <mem_init+0x16d4>
	for (i = 0; i < n; i += PGSIZE)
f01029a1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029a7:	81 fb 00 30 c2 ee    	cmp    $0xeec23000,%ebx
f01029ad:	75 d7                	jne    f0102986 <mem_init+0x1668>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029af:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01029b2:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01029b5:	c1 e6 0c             	shl    $0xc,%esi
f01029b8:	89 fb                	mov    %edi,%ebx
f01029ba:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01029bd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01029c0:	39 f3                	cmp    %esi,%ebx
f01029c2:	73 60                	jae    f0102a24 <mem_init+0x1706>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029c4:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01029ca:	89 f8                	mov    %edi,%eax
f01029cc:	e8 6c e1 ff ff       	call   f0100b3d <check_va2pa>
f01029d1:	39 c3                	cmp    %eax,%ebx
f01029d3:	75 36                	jne    f0102a0b <mem_init+0x16ed>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029d5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029db:	eb e3                	jmp    f01029c0 <mem_init+0x16a2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029dd:	56                   	push   %esi
f01029de:	68 08 70 10 f0       	push   $0xf0107008
f01029e3:	68 90 03 00 00       	push   $0x390
f01029e8:	68 2f 75 10 f0       	push   $0xf010752f
f01029ed:	e8 4e d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029f2:	68 18 80 10 f0       	push   $0xf0108018
f01029f7:	68 55 75 10 f0       	push   $0xf0107555
f01029fc:	68 90 03 00 00       	push   $0x390
f0102a01:	68 2f 75 10 f0       	push   $0xf010752f
f0102a06:	e8 35 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a0b:	68 4c 80 10 f0       	push   $0xf010804c
f0102a10:	68 55 75 10 f0       	push   $0xf0107555
f0102a15:	68 94 03 00 00       	push   $0x394
f0102a1a:	68 2f 75 10 f0       	push   $0xf010752f
f0102a1f:	e8 1c d6 ff ff       	call   f0100040 <_panic>
f0102a24:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102a27:	c7 45 c0 00 d0 2c 00 	movl   $0x2cd000,-0x40(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a2e:	c7 45 d0 00 00 00 f0 	movl   $0xf0000000,-0x30(%ebp)
f0102a35:	c7 45 c4 00 80 ff ef 	movl   $0xefff8000,-0x3c(%ebp)
f0102a3c:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0102a3f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102a42:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0102a45:	8d b3 00 80 ff ff    	lea    -0x8000(%ebx),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a4b:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102a4e:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0102a51:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0102a54:	81 c1 00 80 ff 0f    	add    $0xfff8000,%ecx
f0102a5a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102a5d:	89 75 bc             	mov    %esi,-0x44(%ebp)
f0102a60:	89 c6                	mov    %eax,%esi
f0102a62:	89 da                	mov    %ebx,%edx
f0102a64:	89 f8                	mov    %edi,%eax
f0102a66:	e8 d2 e0 ff ff       	call   f0100b3d <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102a6b:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102a71:	76 68                	jbe    f0102adb <mem_init+0x17bd>
f0102a73:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102a76:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102a79:	39 d0                	cmp    %edx,%eax
f0102a7b:	75 75                	jne    f0102af2 <mem_init+0x17d4>
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a7d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a83:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102a86:	75 da                	jne    f0102a62 <mem_init+0x1744>
f0102a88:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0102a8b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a8e:	89 f2                	mov    %esi,%edx
f0102a90:	89 f8                	mov    %edi,%eax
f0102a92:	e8 a6 e0 ff ff       	call   f0100b3d <check_va2pa>
f0102a97:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a9a:	75 6f                	jne    f0102b0b <mem_init+0x17ed>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a9c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102aa2:	39 de                	cmp    %ebx,%esi
f0102aa4:	75 e8                	jne    f0102a8e <mem_init+0x1770>
	for (n = 0; n < NCPU; n++) {
f0102aa6:	89 d8                	mov    %ebx,%eax
f0102aa8:	2d 00 00 01 00       	sub    $0x10000,%eax
f0102aad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102ab0:	81 6d d0 00 00 01 00 	subl   $0x10000,-0x30(%ebp)
f0102ab7:	81 45 c8 00 80 00 00 	addl   $0x8000,-0x38(%ebp)
f0102abe:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102ac1:	81 45 c0 00 80 01 00 	addl   $0x18000,-0x40(%ebp)
f0102ac8:	3d 00 d0 2f f0       	cmp    $0xf02fd000,%eax
f0102acd:	0f 85 6f ff ff ff    	jne    f0102a42 <mem_init+0x1724>
f0102ad3:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0102ad6:	e9 84 00 00 00       	jmp    f0102b5f <mem_init+0x1841>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102adb:	ff 75 b8             	push   -0x48(%ebp)
f0102ade:	68 08 70 10 f0       	push   $0xf0107008
f0102ae3:	68 9c 03 00 00       	push   $0x39c
f0102ae8:	68 2f 75 10 f0       	push   $0xf010752f
f0102aed:	e8 4e d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102af2:	68 74 80 10 f0       	push   $0xf0108074
f0102af7:	68 55 75 10 f0       	push   $0xf0107555
f0102afc:	68 9b 03 00 00       	push   $0x39b
f0102b01:	68 2f 75 10 f0       	push   $0xf010752f
f0102b06:	e8 35 d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102b0b:	68 bc 80 10 f0       	push   $0xf01080bc
f0102b10:	68 55 75 10 f0       	push   $0xf0107555
f0102b15:	68 9e 03 00 00       	push   $0x39e
f0102b1a:	68 2f 75 10 f0       	push   $0xf010752f
f0102b1f:	e8 1c d5 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102b24:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b27:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102b2b:	75 4e                	jne    f0102b7b <mem_init+0x185d>
f0102b2d:	68 35 78 10 f0       	push   $0xf0107835
f0102b32:	68 55 75 10 f0       	push   $0xf0107555
f0102b37:	68 a9 03 00 00       	push   $0x3a9
f0102b3c:	68 2f 75 10 f0       	push   $0xf010752f
f0102b41:	e8 fa d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b46:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b49:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f0102b4c:	a8 01                	test   $0x1,%al
f0102b4e:	74 30                	je     f0102b80 <mem_init+0x1862>
				assert(pgdir[i] & PTE_W);
f0102b50:	a8 02                	test   $0x2,%al
f0102b52:	74 45                	je     f0102b99 <mem_init+0x187b>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b54:	83 c7 01             	add    $0x1,%edi
f0102b57:	81 ff 00 04 00 00    	cmp    $0x400,%edi
f0102b5d:	74 6c                	je     f0102bcb <mem_init+0x18ad>
		switch (i) {
f0102b5f:	8d 87 45 fc ff ff    	lea    -0x3bb(%edi),%eax
f0102b65:	83 f8 04             	cmp    $0x4,%eax
f0102b68:	76 ba                	jbe    f0102b24 <mem_init+0x1806>
			if (i >= PDX(KERNBASE)) {
f0102b6a:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102b70:	77 d4                	ja     f0102b46 <mem_init+0x1828>
				assert(pgdir[i] == 0);
f0102b72:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b75:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f0102b79:	75 37                	jne    f0102bb2 <mem_init+0x1894>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b7b:	83 c7 01             	add    $0x1,%edi
f0102b7e:	eb df                	jmp    f0102b5f <mem_init+0x1841>
				assert(pgdir[i] & PTE_P);
f0102b80:	68 35 78 10 f0       	push   $0xf0107835
f0102b85:	68 55 75 10 f0       	push   $0xf0107555
f0102b8a:	68 ad 03 00 00       	push   $0x3ad
f0102b8f:	68 2f 75 10 f0       	push   $0xf010752f
f0102b94:	e8 a7 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b99:	68 46 78 10 f0       	push   $0xf0107846
f0102b9e:	68 55 75 10 f0       	push   $0xf0107555
f0102ba3:	68 ae 03 00 00       	push   $0x3ae
f0102ba8:	68 2f 75 10 f0       	push   $0xf010752f
f0102bad:	e8 8e d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102bb2:	68 57 78 10 f0       	push   $0xf0107857
f0102bb7:	68 55 75 10 f0       	push   $0xf0107555
f0102bbc:	68 b0 03 00 00       	push   $0x3b0
f0102bc1:	68 2f 75 10 f0       	push   $0xf010752f
f0102bc6:	e8 75 d4 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102bcb:	83 ec 0c             	sub    $0xc,%esp
f0102bce:	68 e0 80 10 f0       	push   $0xf01080e0
f0102bd3:	e8 f9 0e 00 00       	call   f0103ad1 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102bd8:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102bdd:	83 c4 10             	add    $0x10,%esp
f0102be0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102be5:	0f 86 03 02 00 00    	jbe    f0102dee <mem_init+0x1ad0>
	return (physaddr_t)kva - KERNBASE;
f0102beb:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f0102bf0:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102bf3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bf8:	e8 a3 df ff ff       	call   f0100ba0 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102bfd:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102c00:	83 e0 f3             	and    $0xfffffff3,%eax
f0102c03:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102c08:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c0b:	83 ec 0c             	sub    $0xc,%esp
f0102c0e:	6a 00                	push   $0x0
f0102c10:	e8 32 e3 ff ff       	call   f0100f47 <page_alloc>
f0102c15:	89 c3                	mov    %eax,%ebx
f0102c17:	83 c4 10             	add    $0x10,%esp
f0102c1a:	85 c0                	test   %eax,%eax
f0102c1c:	0f 84 e1 01 00 00    	je     f0102e03 <mem_init+0x1ae5>
	assert((pp1 = page_alloc(0)));
f0102c22:	83 ec 0c             	sub    $0xc,%esp
f0102c25:	6a 00                	push   $0x0
f0102c27:	e8 1b e3 ff ff       	call   f0100f47 <page_alloc>
f0102c2c:	89 c7                	mov    %eax,%edi
f0102c2e:	83 c4 10             	add    $0x10,%esp
f0102c31:	85 c0                	test   %eax,%eax
f0102c33:	0f 84 e3 01 00 00    	je     f0102e1c <mem_init+0x1afe>
	assert((pp2 = page_alloc(0)));
f0102c39:	83 ec 0c             	sub    $0xc,%esp
f0102c3c:	6a 00                	push   $0x0
f0102c3e:	e8 04 e3 ff ff       	call   f0100f47 <page_alloc>
f0102c43:	89 c6                	mov    %eax,%esi
f0102c45:	83 c4 10             	add    $0x10,%esp
f0102c48:	85 c0                	test   %eax,%eax
f0102c4a:	0f 84 e5 01 00 00    	je     f0102e35 <mem_init+0x1b17>
	page_free(pp0);
f0102c50:	83 ec 0c             	sub    $0xc,%esp
f0102c53:	53                   	push   %ebx
f0102c54:	e8 63 e3 ff ff       	call   f0100fbc <page_free>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102c59:	89 f8                	mov    %edi,%eax
f0102c5b:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f0102c61:	c1 f8 03             	sar    $0x3,%eax
f0102c64:	89 c2                	mov    %eax,%edx
f0102c66:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c69:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c6e:	83 c4 10             	add    $0x10,%esp
f0102c71:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f0102c77:	0f 83 d1 01 00 00    	jae    f0102e4e <mem_init+0x1b30>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c7d:	83 ec 04             	sub    $0x4,%esp
f0102c80:	68 00 10 00 00       	push   $0x1000
f0102c85:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c87:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c8d:	52                   	push   %edx
f0102c8e:	e8 5a 2e 00 00       	call   f0105aed <memset>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102c93:	89 f0                	mov    %esi,%eax
f0102c95:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f0102c9b:	c1 f8 03             	sar    $0x3,%eax
f0102c9e:	89 c2                	mov    %eax,%edx
f0102ca0:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102ca3:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102ca8:	83 c4 10             	add    $0x10,%esp
f0102cab:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f0102cb1:	0f 83 a9 01 00 00    	jae    f0102e60 <mem_init+0x1b42>
	memset(page2kva(pp2), 2, PGSIZE);
f0102cb7:	83 ec 04             	sub    $0x4,%esp
f0102cba:	68 00 10 00 00       	push   $0x1000
f0102cbf:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102cc1:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102cc7:	52                   	push   %edx
f0102cc8:	e8 20 2e 00 00       	call   f0105aed <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102ccd:	6a 02                	push   $0x2
f0102ccf:	68 00 10 00 00       	push   $0x1000
f0102cd4:	57                   	push   %edi
f0102cd5:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0102cdb:	e8 75 e5 ff ff       	call   f0101255 <page_insert>
	assert(pp1->pp_ref == 1);
f0102ce0:	83 c4 20             	add    $0x20,%esp
f0102ce3:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ce8:	0f 85 84 01 00 00    	jne    f0102e72 <mem_init+0x1b54>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cee:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cf5:	01 01 01 
f0102cf8:	0f 85 8d 01 00 00    	jne    f0102e8b <mem_init+0x1b6d>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102cfe:	6a 02                	push   $0x2
f0102d00:	68 00 10 00 00       	push   $0x1000
f0102d05:	56                   	push   %esi
f0102d06:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0102d0c:	e8 44 e5 ff ff       	call   f0101255 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d11:	83 c4 10             	add    $0x10,%esp
f0102d14:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d1b:	02 02 02 
f0102d1e:	0f 85 80 01 00 00    	jne    f0102ea4 <mem_init+0x1b86>
	assert(pp2->pp_ref == 1);
f0102d24:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d29:	0f 85 8e 01 00 00    	jne    f0102ebd <mem_init+0x1b9f>
	assert(pp1->pp_ref == 0);
f0102d2f:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d34:	0f 85 9c 01 00 00    	jne    f0102ed6 <mem_init+0x1bb8>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d3a:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d41:	03 03 03 
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102d44:	89 f0                	mov    %esi,%eax
f0102d46:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f0102d4c:	c1 f8 03             	sar    $0x3,%eax
f0102d4f:	89 c2                	mov    %eax,%edx
f0102d51:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d54:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d59:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f0102d5f:	0f 83 8a 01 00 00    	jae    f0102eef <mem_init+0x1bd1>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d65:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102d6c:	03 03 03 
f0102d6f:	0f 85 8c 01 00 00    	jne    f0102f01 <mem_init+0x1be3>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d75:	83 ec 08             	sub    $0x8,%esp
f0102d78:	68 00 10 00 00       	push   $0x1000
f0102d7d:	ff 35 5c c2 2b f0    	push   0xf02bc25c
f0102d83:	e8 87 e4 ff ff       	call   f010120f <page_remove>
	assert(pp2->pp_ref == 0);
f0102d88:	83 c4 10             	add    $0x10,%esp
f0102d8b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d90:	0f 85 84 01 00 00    	jne    f0102f1a <mem_init+0x1bfc>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d96:	8b 0d 5c c2 2b f0    	mov    0xf02bc25c,%ecx
f0102d9c:	8b 11                	mov    (%ecx),%edx
f0102d9e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102da4:	89 d8                	mov    %ebx,%eax
f0102da6:	2b 05 58 c2 2b f0    	sub    0xf02bc258,%eax
f0102dac:	c1 f8 03             	sar    $0x3,%eax
f0102daf:	c1 e0 0c             	shl    $0xc,%eax
f0102db2:	39 c2                	cmp    %eax,%edx
f0102db4:	0f 85 79 01 00 00    	jne    f0102f33 <mem_init+0x1c15>
	kern_pgdir[0] = 0;
f0102dba:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102dc0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102dc5:	0f 85 81 01 00 00    	jne    f0102f4c <mem_init+0x1c2e>
	pp0->pp_ref = 0;
f0102dcb:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102dd1:	83 ec 0c             	sub    $0xc,%esp
f0102dd4:	53                   	push   %ebx
f0102dd5:	e8 e2 e1 ff ff       	call   f0100fbc <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102dda:	c7 04 24 74 81 10 f0 	movl   $0xf0108174,(%esp)
f0102de1:	e8 eb 0c 00 00       	call   f0103ad1 <cprintf>
}
f0102de6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102de9:	5b                   	pop    %ebx
f0102dea:	5e                   	pop    %esi
f0102deb:	5f                   	pop    %edi
f0102dec:	5d                   	pop    %ebp
f0102ded:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dee:	50                   	push   %eax
f0102def:	68 08 70 10 f0       	push   $0xf0107008
f0102df4:	68 0b 01 00 00       	push   $0x10b
f0102df9:	68 2f 75 10 f0       	push   $0xf010752f
f0102dfe:	e8 3d d2 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102e03:	68 41 76 10 f0       	push   $0xf0107641
f0102e08:	68 55 75 10 f0       	push   $0xf0107555
f0102e0d:	68 88 04 00 00       	push   $0x488
f0102e12:	68 2f 75 10 f0       	push   $0xf010752f
f0102e17:	e8 24 d2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e1c:	68 57 76 10 f0       	push   $0xf0107657
f0102e21:	68 55 75 10 f0       	push   $0xf0107555
f0102e26:	68 89 04 00 00       	push   $0x489
f0102e2b:	68 2f 75 10 f0       	push   $0xf010752f
f0102e30:	e8 0b d2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e35:	68 6d 76 10 f0       	push   $0xf010766d
f0102e3a:	68 55 75 10 f0       	push   $0xf0107555
f0102e3f:	68 8a 04 00 00       	push   $0x48a
f0102e44:	68 2f 75 10 f0       	push   $0xf010752f
f0102e49:	e8 f2 d1 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e4e:	52                   	push   %edx
f0102e4f:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0102e54:	6a 5a                	push   $0x5a
f0102e56:	68 3b 75 10 f0       	push   $0xf010753b
f0102e5b:	e8 e0 d1 ff ff       	call   f0100040 <_panic>
f0102e60:	52                   	push   %edx
f0102e61:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0102e66:	6a 5a                	push   $0x5a
f0102e68:	68 3b 75 10 f0       	push   $0xf010753b
f0102e6d:	e8 ce d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102e72:	68 3e 77 10 f0       	push   $0xf010773e
f0102e77:	68 55 75 10 f0       	push   $0xf0107555
f0102e7c:	68 8f 04 00 00       	push   $0x48f
f0102e81:	68 2f 75 10 f0       	push   $0xf010752f
f0102e86:	e8 b5 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e8b:	68 00 81 10 f0       	push   $0xf0108100
f0102e90:	68 55 75 10 f0       	push   $0xf0107555
f0102e95:	68 90 04 00 00       	push   $0x490
f0102e9a:	68 2f 75 10 f0       	push   $0xf010752f
f0102e9f:	e8 9c d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ea4:	68 24 81 10 f0       	push   $0xf0108124
f0102ea9:	68 55 75 10 f0       	push   $0xf0107555
f0102eae:	68 92 04 00 00       	push   $0x492
f0102eb3:	68 2f 75 10 f0       	push   $0xf010752f
f0102eb8:	e8 83 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102ebd:	68 60 77 10 f0       	push   $0xf0107760
f0102ec2:	68 55 75 10 f0       	push   $0xf0107555
f0102ec7:	68 93 04 00 00       	push   $0x493
f0102ecc:	68 2f 75 10 f0       	push   $0xf010752f
f0102ed1:	e8 6a d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102ed6:	68 ca 77 10 f0       	push   $0xf01077ca
f0102edb:	68 55 75 10 f0       	push   $0xf0107555
f0102ee0:	68 94 04 00 00       	push   $0x494
f0102ee5:	68 2f 75 10 f0       	push   $0xf010752f
f0102eea:	e8 51 d1 ff ff       	call   f0100040 <_panic>
f0102eef:	52                   	push   %edx
f0102ef0:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0102ef5:	6a 5a                	push   $0x5a
f0102ef7:	68 3b 75 10 f0       	push   $0xf010753b
f0102efc:	e8 3f d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f01:	68 48 81 10 f0       	push   $0xf0108148
f0102f06:	68 55 75 10 f0       	push   $0xf0107555
f0102f0b:	68 96 04 00 00       	push   $0x496
f0102f10:	68 2f 75 10 f0       	push   $0xf010752f
f0102f15:	e8 26 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102f1a:	68 98 77 10 f0       	push   $0xf0107798
f0102f1f:	68 55 75 10 f0       	push   $0xf0107555
f0102f24:	68 98 04 00 00       	push   $0x498
f0102f29:	68 2f 75 10 f0       	push   $0xf010752f
f0102f2e:	e8 0d d1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f33:	68 d0 7a 10 f0       	push   $0xf0107ad0
f0102f38:	68 55 75 10 f0       	push   $0xf0107555
f0102f3d:	68 9b 04 00 00       	push   $0x49b
f0102f42:	68 2f 75 10 f0       	push   $0xf010752f
f0102f47:	e8 f4 d0 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102f4c:	68 4f 77 10 f0       	push   $0xf010774f
f0102f51:	68 55 75 10 f0       	push   $0xf0107555
f0102f56:	68 9d 04 00 00       	push   $0x49d
f0102f5b:	68 2f 75 10 f0       	push   $0xf010752f
f0102f60:	e8 db d0 ff ff       	call   f0100040 <_panic>

f0102f65 <user_mem_check>:
{
f0102f65:	55                   	push   %ebp
f0102f66:	89 e5                	mov    %esp,%ebp
f0102f68:	57                   	push   %edi
f0102f69:	56                   	push   %esi
f0102f6a:	53                   	push   %ebx
f0102f6b:	83 ec 1c             	sub    $0x1c,%esp
f0102f6e:	8b 75 14             	mov    0x14(%ebp),%esi
	char * start = ROUNDDOWN((char *)va, PGSIZE);
f0102f71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102f74:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f7a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	char * end = ROUNDUP((char *)(va + len), PGSIZE);
f0102f7d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102f80:	03 7d 10             	add    0x10(%ebp),%edi
f0102f83:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0102f89:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for(;start<end;start+=PGSIZE){
f0102f8f:	eb 15                	jmp    f0102fa6 <user_mem_check+0x41>
		    		user_mem_check_addr = (uintptr_t)va;
f0102f91:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f94:	a3 68 c2 2b f0       	mov    %eax,0xf02bc268
	      		return -E_FAULT;
f0102f99:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f9e:	eb 44                	jmp    f0102fe4 <user_mem_check+0x7f>
	for(;start<end;start+=PGSIZE){
f0102fa0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102fa6:	39 fb                	cmp    %edi,%ebx
f0102fa8:	73 42                	jae    f0102fec <user_mem_check+0x87>
		pte_t * cur= pgdir_walk(env->env_pgdir, (void *)start, 0);
f0102faa:	83 ec 04             	sub    $0x4,%esp
f0102fad:	6a 00                	push   $0x0
f0102faf:	53                   	push   %ebx
f0102fb0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fb3:	ff 70 70             	push   0x70(%eax)
f0102fb6:	e8 80 e0 ff ff       	call   f010103b <pgdir_walk>
f0102fbb:	89 da                	mov    %ebx,%edx
		if( (uint32_t) start >= ULIM || cur == NULL || ( (uint32_t)(*cur) & perm) != perm /*如果pte项的user位为0*/) {
f0102fbd:	83 c4 10             	add    $0x10,%esp
f0102fc0:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102fc6:	77 0c                	ja     f0102fd4 <user_mem_check+0x6f>
f0102fc8:	85 c0                	test   %eax,%eax
f0102fca:	74 08                	je     f0102fd4 <user_mem_check+0x6f>
f0102fcc:	89 f1                	mov    %esi,%ecx
f0102fce:	23 08                	and    (%eax),%ecx
f0102fd0:	39 ce                	cmp    %ecx,%esi
f0102fd2:	74 cc                	je     f0102fa0 <user_mem_check+0x3b>
			if(start == ROUNDDOWN((char *)va, PGSIZE)) {
f0102fd4:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102fd7:	74 b8                	je     f0102f91 <user_mem_check+0x2c>
	      			user_mem_check_addr = (uintptr_t)start;
f0102fd9:	89 15 68 c2 2b f0    	mov    %edx,0xf02bc268
	      		return -E_FAULT;
f0102fdf:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102fe4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fe7:	5b                   	pop    %ebx
f0102fe8:	5e                   	pop    %esi
f0102fe9:	5f                   	pop    %edi
f0102fea:	5d                   	pop    %ebp
f0102feb:	c3                   	ret    
	return 0;
f0102fec:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ff1:	eb f1                	jmp    f0102fe4 <user_mem_check+0x7f>

f0102ff3 <user_mem_assert>:
{
f0102ff3:	55                   	push   %ebp
f0102ff4:	89 e5                	mov    %esp,%ebp
f0102ff6:	53                   	push   %ebx
f0102ff7:	83 ec 04             	sub    $0x4,%esp
f0102ffa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102ffd:	8b 45 14             	mov    0x14(%ebp),%eax
f0103000:	83 c8 04             	or     $0x4,%eax
f0103003:	50                   	push   %eax
f0103004:	ff 75 10             	push   0x10(%ebp)
f0103007:	ff 75 0c             	push   0xc(%ebp)
f010300a:	53                   	push   %ebx
f010300b:	e8 55 ff ff ff       	call   f0102f65 <user_mem_check>
f0103010:	83 c4 10             	add    $0x10,%esp
f0103013:	85 c0                	test   %eax,%eax
f0103015:	78 05                	js     f010301c <user_mem_assert+0x29>
}
f0103017:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010301a:	c9                   	leave  
f010301b:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f010301c:	83 ec 04             	sub    $0x4,%esp
f010301f:	ff 35 68 c2 2b f0    	push   0xf02bc268
f0103025:	ff 73 58             	push   0x58(%ebx)
f0103028:	68 a0 81 10 f0       	push   $0xf01081a0
f010302d:	e8 9f 0a 00 00       	call   f0103ad1 <cprintf>
		env_destroy(env);	// may not return
f0103032:	89 1c 24             	mov    %ebx,(%esp)
f0103035:	e8 a0 06 00 00       	call   f01036da <env_destroy>
f010303a:	83 c4 10             	add    $0x10,%esp
}
f010303d:	eb d8                	jmp    f0103017 <user_mem_assert+0x24>

f010303f <node_remove>:
}

static void 
node_remove(struct Listnode *ln) 
{
    ln->prev->next = ln->next;
f010303f:	8b 08                	mov    (%eax),%ecx
f0103041:	8b 50 04             	mov    0x4(%eax),%edx
f0103044:	89 51 04             	mov    %edx,0x4(%ecx)
    ln->next->prev = ln->prev;
f0103047:	8b 08                	mov    (%eax),%ecx
f0103049:	89 0a                	mov    %ecx,(%edx)
    ln->prev = ln->next = ln;
f010304b:	89 40 04             	mov    %eax,0x4(%eax)
f010304e:	89 00                	mov    %eax,(%eax)
    node_init(ln);
}
f0103050:	c3                   	ret    

f0103051 <region_alloc>:
// Panic if any allocation attempt fails.
//
//为环境分配和映射物理内存
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103051:	55                   	push   %ebp
f0103052:	89 e5                	mov    %esp,%ebp
f0103054:	57                   	push   %edi
f0103055:	56                   	push   %esi
f0103056:	53                   	push   %ebx
f0103057:	83 ec 0c             	sub    $0xc,%esp
f010305a:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	//先申请物理内存，再调用page_insert（）
	void* start = (void *)ROUNDDOWN((uint32_t)va, PGSIZE);     
f010305c:	89 d3                	mov    %edx,%ebx
f010305e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
f0103064:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f010306b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	struct PageInfo *p = NULL;
	int r;
	for(void* i=start; i<end; i+=PGSIZE){
f0103071:	39 f3                	cmp    %esi,%ebx
f0103073:	73 5a                	jae    f01030cf <region_alloc+0x7e>
		p = page_alloc(0);
f0103075:	83 ec 0c             	sub    $0xc,%esp
f0103078:	6a 00                	push   $0x0
f010307a:	e8 c8 de ff ff       	call   f0100f47 <page_alloc>
		if(p == NULL) panic("region alloc - page alloc failed.");
f010307f:	83 c4 10             	add    $0x10,%esp
f0103082:	85 c0                	test   %eax,%eax
f0103084:	74 1b                	je     f01030a1 <region_alloc+0x50>
		
	 	r = page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);
f0103086:	6a 06                	push   $0x6
f0103088:	53                   	push   %ebx
f0103089:	50                   	push   %eax
f010308a:	ff 77 70             	push   0x70(%edi)
f010308d:	e8 c3 e1 ff ff       	call   f0101255 <page_insert>
	 	if(r != 0)  panic("region alloc - page insert error - page table couldn't be allocated");
f0103092:	83 c4 10             	add    $0x10,%esp
f0103095:	85 c0                	test   %eax,%eax
f0103097:	75 1f                	jne    f01030b8 <region_alloc+0x67>
	for(void* i=start; i<end; i+=PGSIZE){
f0103099:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010309f:	eb d0                	jmp    f0103071 <region_alloc+0x20>
		if(p == NULL) panic("region alloc - page alloc failed.");
f01030a1:	83 ec 04             	sub    $0x4,%esp
f01030a4:	68 d8 81 10 f0       	push   $0xf01081d8
f01030a9:	68 3e 01 00 00       	push   $0x13e
f01030ae:	68 c6 82 10 f0       	push   $0xf01082c6
f01030b3:	e8 88 cf ff ff       	call   f0100040 <_panic>
	 	if(r != 0)  panic("region alloc - page insert error - page table couldn't be allocated");
f01030b8:	83 ec 04             	sub    $0x4,%esp
f01030bb:	68 fc 81 10 f0       	push   $0xf01081fc
f01030c0:	68 41 01 00 00       	push   $0x141
f01030c5:	68 c6 82 10 f0       	push   $0xf01082c6
f01030ca:	e8 71 cf ff ff       	call   f0100040 <_panic>
	}
}
f01030cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030d2:	5b                   	pop    %ebx
f01030d3:	5e                   	pop    %esi
f01030d4:	5f                   	pop    %edi
f01030d5:	5d                   	pop    %ebp
f01030d6:	c3                   	ret    

f01030d7 <envid2env>:
{
f01030d7:	55                   	push   %ebp
f01030d8:	89 e5                	mov    %esp,%ebp
f01030da:	56                   	push   %esi
f01030db:	53                   	push   %ebx
f01030dc:	8b 75 08             	mov    0x8(%ebp),%esi
f01030df:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f01030e2:	85 f6                	test   %esi,%esi
f01030e4:	74 31                	je     f0103117 <envid2env+0x40>
	e = &envs[ENVX(envid)];
f01030e6:	89 f3                	mov    %esi,%ebx
f01030e8:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01030ee:	69 db 8c 00 00 00    	imul   $0x8c,%ebx,%ebx
f01030f4:	03 1d 74 c2 2b f0    	add    0xf02bc274,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01030fa:	83 7b 64 00          	cmpl   $0x0,0x64(%ebx)
f01030fe:	74 5b                	je     f010315b <envid2env+0x84>
f0103100:	39 73 58             	cmp    %esi,0x58(%ebx)
f0103103:	75 62                	jne    f0103167 <envid2env+0x90>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103105:	84 c0                	test   %al,%al
f0103107:	75 20                	jne    f0103129 <envid2env+0x52>
	return 0;
f0103109:	b8 00 00 00 00       	mov    $0x0,%eax
		*env_store = curenv;
f010310e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103111:	89 1a                	mov    %ebx,(%edx)
}
f0103113:	5b                   	pop    %ebx
f0103114:	5e                   	pop    %esi
f0103115:	5d                   	pop    %ebp
f0103116:	c3                   	ret    
		*env_store = curenv;
f0103117:	e8 c8 2f 00 00       	call   f01060e4 <cpunum>
f010311c:	6b c0 74             	imul   $0x74,%eax,%eax
f010311f:	8b 98 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%ebx
		return 0;
f0103125:	89 f0                	mov    %esi,%eax
f0103127:	eb e5                	jmp    f010310e <envid2env+0x37>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103129:	e8 b6 2f 00 00       	call   f01060e4 <cpunum>
f010312e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103131:	39 98 28 d0 2f f0    	cmp    %ebx,-0xfd02fd8(%eax)
f0103137:	74 d0                	je     f0103109 <envid2env+0x32>
f0103139:	8b 73 5c             	mov    0x5c(%ebx),%esi
f010313c:	e8 a3 2f 00 00       	call   f01060e4 <cpunum>
f0103141:	6b c0 74             	imul   $0x74,%eax,%eax
f0103144:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f010314a:	3b 70 58             	cmp    0x58(%eax),%esi
f010314d:	74 ba                	je     f0103109 <envid2env+0x32>
f010314f:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f0103154:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103159:	eb b3                	jmp    f010310e <envid2env+0x37>
f010315b:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f0103160:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103165:	eb a7                	jmp    f010310e <envid2env+0x37>
f0103167:	bb 00 00 00 00       	mov    $0x0,%ebx
f010316c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103171:	eb 9b                	jmp    f010310e <envid2env+0x37>

f0103173 <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f0103173:	b8 20 93 12 f0       	mov    $0xf0129320,%eax
f0103178:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f010317b:	b8 23 00 00 00       	mov    $0x23,%eax
f0103180:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103182:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103184:	b8 10 00 00 00       	mov    $0x10,%eax
f0103189:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010318b:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010318d:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f010318f:	ea 96 31 10 f0 08 00 	ljmp   $0x8,$0xf0103196
	asm volatile("lldt %0" : : "r" (sel));
f0103196:	b8 00 00 00 00       	mov    $0x0,%eax
f010319b:	0f 00 d0             	lldt   %ax
}
f010319e:	c3                   	ret    

f010319f <env_init>:
{
f010319f:	55                   	push   %ebp
f01031a0:	89 e5                	mov    %esp,%ebp
f01031a2:	83 ec 08             	sub    $0x8,%esp
	env_free_list=envs;
f01031a5:	a1 74 c2 2b f0       	mov    0xf02bc274,%eax
f01031aa:	a3 78 c2 2b f0       	mov    %eax,0xf02bc278
f01031af:	05 8c 00 00 00       	add    $0x8c,%eax
	for(int i=0;i<NENV;i++){
f01031b4:	ba 00 00 00 00       	mov    $0x0,%edx
f01031b9:	eb 13                	jmp    f01031ce <env_init+0x2f>
f01031bb:	89 40 c8             	mov    %eax,-0x38(%eax)
f01031be:	83 c2 01             	add    $0x1,%edx
f01031c1:	05 8c 00 00 00       	add    $0x8c,%eax
f01031c6:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f01031cc:	74 1d                	je     f01031eb <env_init+0x4c>
		envs[i].env_status = ENV_FREE;//初始化不需要操作mfq队列
f01031ce:	c7 40 d8 00 00 00 00 	movl   $0x0,-0x28(%eax)
		envs[i].env_id=0;
f01031d5:	c7 40 cc 00 00 00 00 	movl   $0x0,-0x34(%eax)
		if(i!=NENV-1) envs[i].env_link= &envs[i+1];
f01031dc:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f01031e2:	75 d7                	jne    f01031bb <env_init+0x1c>
f01031e4:	c7 40 c8 00 00 00 00 	movl   $0x0,-0x38(%eax)
	env_init_percpu();
f01031eb:	e8 83 ff ff ff       	call   f0103173 <env_init_percpu>
}
f01031f0:	c9                   	leave  
f01031f1:	c3                   	ret    

f01031f2 <env_alloc>:
{
f01031f2:	55                   	push   %ebp
f01031f3:	89 e5                	mov    %esp,%ebp
f01031f5:	53                   	push   %ebx
f01031f6:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f01031f9:	8b 1d 78 c2 2b f0    	mov    0xf02bc278,%ebx
f01031ff:	85 db                	test   %ebx,%ebx
f0103201:	0f 84 81 01 00 00    	je     f0103388 <env_alloc+0x196>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103207:	83 ec 0c             	sub    $0xc,%esp
f010320a:	6a 01                	push   $0x1
f010320c:	e8 36 dd ff ff       	call   f0100f47 <page_alloc>
f0103211:	83 c4 10             	add    $0x10,%esp
f0103214:	85 c0                	test   %eax,%eax
f0103216:	0f 84 73 01 00 00    	je     f010338f <env_alloc+0x19d>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f010321c:	89 c2                	mov    %eax,%edx
f010321e:	2b 15 58 c2 2b f0    	sub    0xf02bc258,%edx
f0103224:	c1 fa 03             	sar    $0x3,%edx
f0103227:	89 d1                	mov    %edx,%ecx
f0103229:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f010322c:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
f0103232:	3b 15 60 c2 2b f0    	cmp    0xf02bc260,%edx
f0103238:	0f 83 23 01 00 00    	jae    f0103361 <env_alloc+0x16f>
	return (void *)(pa + KERNBASE);
f010323e:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0103244:	89 4b 70             	mov    %ecx,0x70(%ebx)
	p->pp_ref++;
f0103247:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010324c:	b8 00 00 00 00       	mov    $0x0,%eax
		e->env_pgdir[i] = 0;        
f0103251:	8b 53 70             	mov    0x70(%ebx),%edx
f0103254:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	for(i = 0; i < PDX(UTOP); i++) {
f010325b:	83 c0 04             	add    $0x4,%eax
f010325e:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103263:	75 ec                	jne    f0103251 <env_alloc+0x5f>
		e->env_pgdir[i] = kern_pgdir[i];
f0103265:	8b 15 5c c2 2b f0    	mov    0xf02bc25c,%edx
f010326b:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f010326e:	8b 53 70             	mov    0x70(%ebx),%edx
f0103271:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
	for(i = PDX(UTOP); i < NPDENTRIES; i++) {//NPDENTRIES宏在mmu.h中定义，为1024
f0103274:	83 c0 04             	add    $0x4,%eax
f0103277:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010327c:	75 e7                	jne    f0103265 <env_alloc+0x73>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010327e:	8b 43 70             	mov    0x70(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103281:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103286:	0f 86 e7 00 00 00    	jbe    f0103373 <env_alloc+0x181>
	return (physaddr_t)kva - KERNBASE;
f010328c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103292:	83 ca 05             	or     $0x5,%edx
f0103295:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010329b:	8b 43 58             	mov    0x58(%ebx),%eax
f010329e:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f01032a3:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01032a8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01032ad:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01032b0:	89 da                	mov    %ebx,%edx
f01032b2:	2b 15 74 c2 2b f0    	sub    0xf02bc274,%edx
f01032b8:	c1 fa 02             	sar    $0x2,%edx
f01032bb:	69 d2 8b af f8 8a    	imul   $0x8af8af8b,%edx,%edx
f01032c1:	09 d0                	or     %edx,%eax
f01032c3:	89 43 58             	mov    %eax,0x58(%ebx)
	e->env_parent_id = parent_id;
f01032c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032c9:	89 43 5c             	mov    %eax,0x5c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01032cc:	c7 43 60 00 00 00 00 	movl   $0x0,0x60(%ebx)
	e->env_status = ENV_RUNNABLE;
f01032d3:	c7 43 64 02 00 00 00 	movl   $0x2,0x64(%ebx)
	e->env_mfq_level=0;
f01032da:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	e->env_mfq_time_slices= MFQ_SLICE ;
f01032e1:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
}

static void 
node_enqueue(struct Listnode *que, struct Listnode *ln) 
{
    node_insert(que->prev, ln);//插入到队列尾巴
f01032e8:	a1 70 c2 2b f0       	mov    0xf02bc270,%eax
f01032ed:	8b 00                	mov    (%eax),%eax
    ln->prev = pos;
f01032ef:	89 03                	mov    %eax,(%ebx)
    ln->next = pos->next;
f01032f1:	8b 50 04             	mov    0x4(%eax),%edx
f01032f4:	89 53 04             	mov    %edx,0x4(%ebx)
    ln->prev->next = ln;
f01032f7:	89 58 04             	mov    %ebx,0x4(%eax)
    ln->next->prev = ln;
f01032fa:	8b 43 04             	mov    0x4(%ebx),%eax
f01032fd:	89 18                	mov    %ebx,(%eax)
	e->env_runs = 0;
f01032ff:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103306:	83 ec 04             	sub    $0x4,%esp
f0103309:	6a 44                	push   $0x44
f010330b:	6a 00                	push   $0x0
f010330d:	8d 43 10             	lea    0x10(%ebx),%eax
f0103310:	50                   	push   %eax
f0103311:	e8 d7 27 00 00       	call   f0105aed <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103316:	66 c7 43 34 23 00    	movw   $0x23,0x34(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010331c:	66 c7 43 30 23 00    	movw   $0x23,0x30(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103322:	66 c7 43 50 23 00    	movw   $0x23,0x50(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103328:	c7 43 4c 00 e0 bf ee 	movl   $0xeebfe000,0x4c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010332f:	66 c7 43 44 1b 00    	movw   $0x1b,0x44(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f0103335:	81 4b 48 00 02 00 00 	orl    $0x200,0x48(%ebx)
	e->env_pgfault_upcall = 0;
f010333c:	c7 43 74 00 00 00 00 	movl   $0x0,0x74(%ebx)
	e->env_ipc_recving = 0;
f0103343:	c6 43 78 00          	movb   $0x0,0x78(%ebx)
	env_free_list = e->env_link;
f0103347:	8b 43 54             	mov    0x54(%ebx),%eax
f010334a:	a3 78 c2 2b f0       	mov    %eax,0xf02bc278
	*newenv_store = e;
f010334f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103352:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103354:	83 c4 10             	add    $0x10,%esp
f0103357:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010335c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010335f:	c9                   	leave  
f0103360:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103361:	51                   	push   %ecx
f0103362:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0103367:	6a 5a                	push   $0x5a
f0103369:	68 3b 75 10 f0       	push   $0xf010753b
f010336e:	e8 cd cc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103373:	50                   	push   %eax
f0103374:	68 08 70 10 f0       	push   $0xf0107008
f0103379:	68 d1 00 00 00       	push   $0xd1
f010337e:	68 c6 82 10 f0       	push   $0xf01082c6
f0103383:	e8 b8 cc ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f0103388:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010338d:	eb cd                	jmp    f010335c <env_alloc+0x16a>
		return -E_NO_MEM;
f010338f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103394:	eb c6                	jmp    f010335c <env_alloc+0x16a>

f0103396 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//用env_alloc分配一个环境，并调用load_icode将ELF二进制文件加载到环境中。
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103396:	55                   	push   %ebp
f0103397:	89 e5                	mov    %esp,%ebp
f0103399:	57                   	push   %edi
f010339a:	56                   	push   %esi
f010339b:	53                   	push   %ebx
f010339c:	83 ec 34             	sub    $0x34,%esp
f010339f:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 5: Your code here.


	// LAB 3: Your code here.
	//使用env_alloc分配一个env，根据注释很简单。
	struct Env * env=NULL;
f01033a2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&env, 0);
f01033a9:	6a 00                	push   $0x0
f01033ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01033ae:	50                   	push   %eax
f01033af:	e8 3e fe ff ff       	call   f01031f2 <env_alloc>
	if(r < 0)  panic("env_create error: %e", r);//使用lab中示例的panic。
f01033b4:	83 c4 10             	add    $0x10,%esp
f01033b7:	85 c0                	test   %eax,%eax
f01033b9:	78 44                	js     f01033ff <env_create+0x69>
	//通过修改EFLAGS寄存器中的IOPL位，赋予文件系统环境 I/O权限  
	if (type == ENV_TYPE_FS)  env->env_tf.tf_eflags |= FL_IOPL_MASK;
f01033bb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f01033bf:	74 53                	je     f0103414 <env_create+0x7e>
	
	load_icode(env,binary);
f01033c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if(e == NULL || binary == NULL)  panic("load_icode: invalid environment or binary\n");
f01033c7:	85 c0                	test   %eax,%eax
f01033c9:	74 55                	je     f0103420 <env_create+0x8a>
f01033cb:	85 ff                	test   %edi,%edi
f01033cd:	74 51                	je     f0103420 <env_create+0x8a>
	if(ElfHeader->e_magic != ELF_MAGIC) panic("load_icode error : binary is invalid elf format\n");
f01033cf:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01033d5:	75 60                	jne    f0103437 <env_create+0xa1>
	struct Proghdr * ph = (struct Proghdr *) ((uint8_t *) ElfHeader + ElfHeader->e_phoff);
f01033d7:	89 fb                	mov    %edi,%ebx
f01033d9:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr * eph = ph + ElfHeader->e_phnum;
f01033dc:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01033e0:	c1 e6 05             	shl    $0x5,%esi
f01033e3:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));//lcr3(uint32_t val)在inc/x86.h中定义 ，其将val值赋给cr3寄存器(即页目录基寄存器)。
f01033e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033e8:	8b 40 70             	mov    0x70(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01033eb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033f0:	76 5c                	jbe    f010344e <env_create+0xb8>
	return (physaddr_t)kva - KERNBASE;
f01033f2:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f01033f7:	0f 22 d8             	mov    %eax,%cr3
}
f01033fa:	e9 a0 00 00 00       	jmp    f010349f <env_create+0x109>
	if(r < 0)  panic("env_create error: %e", r);//使用lab中示例的panic。
f01033ff:	50                   	push   %eax
f0103400:	68 d1 82 10 f0       	push   $0xf01082d1
f0103405:	68 b1 01 00 00       	push   $0x1b1
f010340a:	68 c6 82 10 f0       	push   $0xf01082c6
f010340f:	e8 2c cc ff ff       	call   f0100040 <_panic>
	if (type == ENV_TYPE_FS)  env->env_tf.tf_eflags |= FL_IOPL_MASK;
f0103414:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103417:	81 48 48 00 30 00 00 	orl    $0x3000,0x48(%eax)
f010341e:	eb a1                	jmp    f01033c1 <env_create+0x2b>
	if(e == NULL || binary == NULL)  panic("load_icode: invalid environment or binary\n");
f0103420:	83 ec 04             	sub    $0x4,%esp
f0103423:	68 40 82 10 f0       	push   $0xf0108240
f0103428:	68 7f 01 00 00       	push   $0x17f
f010342d:	68 c6 82 10 f0       	push   $0xf01082c6
f0103432:	e8 09 cc ff ff       	call   f0100040 <_panic>
	if(ElfHeader->e_magic != ELF_MAGIC) panic("load_icode error : binary is invalid elf format\n");
f0103437:	83 ec 04             	sub    $0x4,%esp
f010343a:	68 6c 82 10 f0       	push   $0xf010826c
f010343f:	68 84 01 00 00       	push   $0x184
f0103444:	68 c6 82 10 f0       	push   $0xf01082c6
f0103449:	e8 f2 cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010344e:	50                   	push   %eax
f010344f:	68 08 70 10 f0       	push   $0xf0107008
f0103454:	68 89 01 00 00       	push   $0x189
f0103459:	68 c6 82 10 f0       	push   $0xf01082c6
f010345e:	e8 dd cb ff ff       	call   f0100040 <_panic>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);//为 环境e 分配和映射物理内存
f0103463:	8b 53 08             	mov    0x8(%ebx),%edx
f0103466:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103469:	e8 e3 fb ff ff       	call   f0103051 <region_alloc>
			memmove((void*)ph->p_va, (uint8_t *)binary + ph->p_offset, ph->p_filesz);//移动binary到虚拟内存  (mem等函数全在lib/string.c中定义)
f010346e:	83 ec 04             	sub    $0x4,%esp
f0103471:	ff 73 10             	push   0x10(%ebx)
f0103474:	89 f8                	mov    %edi,%eax
f0103476:	03 43 04             	add    0x4(%ebx),%eax
f0103479:	50                   	push   %eax
f010347a:	ff 73 08             	push   0x8(%ebx)
f010347d:	e8 b1 26 00 00       	call   f0105b33 <memmove>
			memset((void*)ph->p_va+ph->p_filesz, 0, ph->p_memsz-ph->p_filesz);//剩余内存置0
f0103482:	8b 43 10             	mov    0x10(%ebx),%eax
f0103485:	83 c4 0c             	add    $0xc,%esp
f0103488:	8b 53 14             	mov    0x14(%ebx),%edx
f010348b:	29 c2                	sub    %eax,%edx
f010348d:	52                   	push   %edx
f010348e:	6a 00                	push   $0x0
f0103490:	03 43 08             	add    0x8(%ebx),%eax
f0103493:	50                   	push   %eax
f0103494:	e8 54 26 00 00       	call   f0105aed <memset>
f0103499:	83 c4 10             	add    $0x10,%esp
	for(; ph < eph; ph++) {
f010349c:	83 c3 20             	add    $0x20,%ebx
f010349f:	39 de                	cmp    %ebx,%esi
f01034a1:	76 24                	jbe    f01034c7 <env_create+0x131>
		if(ph->p_type == ELF_PROG_LOAD){//注释要求
f01034a3:	83 3b 01             	cmpl   $0x1,(%ebx)
f01034a6:	75 f4                	jne    f010349c <env_create+0x106>
			if(ph->p_memsz < ph->p_filesz)
f01034a8:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01034ab:	3b 4b 10             	cmp    0x10(%ebx),%ecx
f01034ae:	73 b3                	jae    f0103463 <env_create+0xcd>
				panic("load_icode error: p_memsz < p_filesz\n");
f01034b0:	83 ec 04             	sub    $0x4,%esp
f01034b3:	68 a0 82 10 f0       	push   $0xf01082a0
f01034b8:	68 8e 01 00 00       	push   $0x18e
f01034bd:	68 c6 82 10 f0       	push   $0xf01082c6
f01034c2:	e8 79 cb ff ff       	call   f0100040 <_panic>
	lcr3(PADDR(kern_pgdir));//再切换回内核的页目录，我感觉要在分配栈前，一些博客与我有出入。
f01034c7:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
	if ((uint32_t)kva < KERNBASE)
f01034cc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034d1:	76 33                	jbe    f0103506 <env_create+0x170>
	return (physaddr_t)kva - KERNBASE;
f01034d3:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f01034d8:	0f 22 d8             	mov    %eax,%cr3
	e->env_tf.tf_eip = ElfHeader->e_entry;//这句我也不确定。但我感觉大致思路是由于段设计在JOS约等于没有（因为linux就约等于没有，之前lab中介绍有提到），而根据注释要修改cs:ip,所以就之修改了eip。
f01034db:	8b 47 18             	mov    0x18(%edi),%eax
f01034de:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01034e1:	89 47 40             	mov    %eax,0x40(%edi)
	region_alloc(e, (void*)(USTACKTOP-PGSIZE), PGSIZE);
f01034e4:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01034e9:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01034ee:	89 f8                	mov    %edi,%eax
f01034f0:	e8 5c fb ff ff       	call   f0103051 <region_alloc>
	env->env_type=type;
f01034f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034f8:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01034fb:	89 78 60             	mov    %edi,0x60(%eax)
}
f01034fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103501:	5b                   	pop    %ebx
f0103502:	5e                   	pop    %esi
f0103503:	5f                   	pop    %edi
f0103504:	5d                   	pop    %ebp
f0103505:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103506:	50                   	push   %eax
f0103507:	68 08 70 10 f0       	push   $0xf0107008
f010350c:	68 95 01 00 00       	push   $0x195
f0103511:	68 c6 82 10 f0       	push   $0xf01082c6
f0103516:	e8 25 cb ff ff       	call   f0100040 <_panic>

f010351b <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010351b:	55                   	push   %ebp
f010351c:	89 e5                	mov    %esp,%ebp
f010351e:	57                   	push   %edi
f010351f:	56                   	push   %esi
f0103520:	53                   	push   %ebx
f0103521:	83 ec 1c             	sub    $0x1c,%esp
f0103524:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103527:	e8 b8 2b 00 00       	call   f01060e4 <cpunum>
f010352c:	6b c0 74             	imul   $0x74,%eax,%eax
f010352f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103536:	39 b8 28 d0 2f f0    	cmp    %edi,-0xfd02fd8(%eax)
f010353c:	0f 85 b3 00 00 00    	jne    f01035f5 <env_free+0xda>
		lcr3(PADDR(kern_pgdir));
f0103542:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103547:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010354c:	76 14                	jbe    f0103562 <env_free+0x47>
	return (physaddr_t)kva - KERNBASE;
f010354e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103553:	0f 22 d8             	mov    %eax,%cr3
}
f0103556:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010355d:	e9 93 00 00 00       	jmp    f01035f5 <env_free+0xda>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103562:	50                   	push   %eax
f0103563:	68 08 70 10 f0       	push   $0xf0107008
f0103568:	68 c7 01 00 00       	push   $0x1c7
f010356d:	68 c6 82 10 f0       	push   $0xf01082c6
f0103572:	e8 c9 ca ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103577:	56                   	push   %esi
f0103578:	68 e4 6f 10 f0       	push   $0xf0106fe4
f010357d:	68 d6 01 00 00       	push   $0x1d6
f0103582:	68 c6 82 10 f0       	push   $0xf01082c6
f0103587:	e8 b4 ca ff ff       	call   f0100040 <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010358c:	83 c6 04             	add    $0x4,%esi
f010358f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103595:	81 fb 00 00 40 00    	cmp    $0x400000,%ebx
f010359b:	74 1b                	je     f01035b8 <env_free+0x9d>
			if (pt[pteno] & PTE_P)
f010359d:	f6 06 01             	testb  $0x1,(%esi)
f01035a0:	74 ea                	je     f010358c <env_free+0x71>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01035a2:	83 ec 08             	sub    $0x8,%esp
f01035a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035a8:	09 d8                	or     %ebx,%eax
f01035aa:	50                   	push   %eax
f01035ab:	ff 77 70             	push   0x70(%edi)
f01035ae:	e8 5c dc ff ff       	call   f010120f <page_remove>
f01035b3:	83 c4 10             	add    $0x10,%esp
f01035b6:	eb d4                	jmp    f010358c <env_free+0x71>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01035b8:	8b 47 70             	mov    0x70(%edi),%eax
f01035bb:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035be:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f01035c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01035c8:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f01035ce:	73 65                	jae    f0103635 <env_free+0x11a>
		page_decref(pa2page(pa));
f01035d0:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01035d3:	a1 58 c2 2b f0       	mov    0xf02bc258,%eax
f01035d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035db:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01035de:	50                   	push   %eax
f01035df:	e8 2e da ff ff       	call   f0101012 <page_decref>
f01035e4:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01035e7:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01035eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035ee:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01035f3:	74 54                	je     f0103649 <env_free+0x12e>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01035f5:	8b 47 70             	mov    0x70(%edi),%eax
f01035f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01035fb:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f01035fe:	a8 01                	test   $0x1,%al
f0103600:	74 e5                	je     f01035e7 <env_free+0xcc>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103602:	89 c6                	mov    %eax,%esi
f0103604:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f010360a:	c1 e8 0c             	shr    $0xc,%eax
f010360d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103610:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f0103616:	0f 83 5b ff ff ff    	jae    f0103577 <env_free+0x5c>
	return (void *)(pa + KERNBASE);
f010361c:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103622:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103625:	c1 e0 14             	shl    $0x14,%eax
f0103628:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010362b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103630:	e9 68 ff ff ff       	jmp    f010359d <env_free+0x82>
		panic("pa2page called with invalid pa");
f0103635:	83 ec 04             	sub    $0x4,%esp
f0103638:	68 74 79 10 f0       	push   $0xf0107974
f010363d:	6a 52                	push   $0x52
f010363f:	68 3b 75 10 f0       	push   $0xf010753b
f0103644:	e8 f7 c9 ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103649:	8b 47 70             	mov    0x70(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f010364c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103651:	76 5e                	jbe    f01036b1 <env_free+0x196>
	e->env_pgdir = 0;
f0103653:	c7 47 70 00 00 00 00 	movl   $0x0,0x70(%edi)
	return (physaddr_t)kva - KERNBASE;
f010365a:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f010365f:	c1 e8 0c             	shr    $0xc,%eax
f0103662:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f0103668:	73 5c                	jae    f01036c6 <env_free+0x1ab>
	page_decref(pa2page(pa));
f010366a:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010366d:	8b 15 58 c2 2b f0    	mov    0xf02bc258,%edx
f0103673:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103676:	50                   	push   %eax
f0103677:	e8 96 d9 ff ff       	call   f0101012 <page_decref>
//封装,改变ENV_RUNNABLE状态环境后 要将其移除就绪队列。
//注意：也有可能是将其执行，即改为running状态
void
env_disready(struct Env* e, enum EnvType new_envtype)
{
	e->env_status = new_envtype;
f010367c:	c7 47 64 00 00 00 00 	movl   $0x0,0x64(%edi)
	node_remove(& (e->env_mfq_link) );
f0103683:	89 f8                	mov    %edi,%eax
f0103685:	e8 b5 f9 ff ff       	call   f010303f <node_remove>
	e->env_link = env_free_list;
f010368a:	a1 78 c2 2b f0       	mov    0xf02bc278,%eax
f010368f:	89 47 54             	mov    %eax,0x54(%edi)
	e->env_mfq_level = 0;
f0103692:	c7 47 08 00 00 00 00 	movl   $0x0,0x8(%edi)
	e->env_mfq_time_slices = 0;
f0103699:	c7 47 0c 00 00 00 00 	movl   $0x0,0xc(%edi)
	env_free_list = e;
f01036a0:	89 3d 78 c2 2b f0    	mov    %edi,0xf02bc278
}
f01036a6:	83 c4 10             	add    $0x10,%esp
f01036a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01036ac:	5b                   	pop    %ebx
f01036ad:	5e                   	pop    %esi
f01036ae:	5f                   	pop    %edi
f01036af:	5d                   	pop    %ebp
f01036b0:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036b1:	50                   	push   %eax
f01036b2:	68 08 70 10 f0       	push   $0xf0107008
f01036b7:	68 e4 01 00 00       	push   $0x1e4
f01036bc:	68 c6 82 10 f0       	push   $0xf01082c6
f01036c1:	e8 7a c9 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f01036c6:	83 ec 04             	sub    $0x4,%esp
f01036c9:	68 74 79 10 f0       	push   $0xf0107974
f01036ce:	6a 52                	push   $0x52
f01036d0:	68 3b 75 10 f0       	push   $0xf010753b
f01036d5:	e8 66 c9 ff ff       	call   f0100040 <_panic>

f01036da <env_destroy>:
{
f01036da:	55                   	push   %ebp
f01036db:	89 e5                	mov    %esp,%ebp
f01036dd:	53                   	push   %ebx
f01036de:	83 ec 04             	sub    $0x4,%esp
f01036e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01036e4:	83 7b 64 03          	cmpl   $0x3,0x64(%ebx)
f01036e8:	74 21                	je     f010370b <env_destroy+0x31>
	env_free(e);
f01036ea:	83 ec 0c             	sub    $0xc,%esp
f01036ed:	53                   	push   %ebx
f01036ee:	e8 28 fe ff ff       	call   f010351b <env_free>
	if (curenv == e) {
f01036f3:	e8 ec 29 00 00       	call   f01060e4 <cpunum>
f01036f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01036fb:	83 c4 10             	add    $0x10,%esp
f01036fe:	39 98 28 d0 2f f0    	cmp    %ebx,-0xfd02fd8(%eax)
f0103704:	74 1e                	je     f0103724 <env_destroy+0x4a>
}
f0103706:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103709:	c9                   	leave  
f010370a:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010370b:	e8 d4 29 00 00       	call   f01060e4 <cpunum>
f0103710:	6b c0 74             	imul   $0x74,%eax,%eax
f0103713:	39 98 28 d0 2f f0    	cmp    %ebx,-0xfd02fd8(%eax)
f0103719:	74 cf                	je     f01036ea <env_destroy+0x10>
		e->env_status = ENV_DYING;
f010371b:	c7 43 64 01 00 00 00 	movl   $0x1,0x64(%ebx)
		return;
f0103722:	eb e2                	jmp    f0103706 <env_destroy+0x2c>
		curenv = NULL;
f0103724:	e8 bb 29 00 00       	call   f01060e4 <cpunum>
f0103729:	6b c0 74             	imul   $0x74,%eax,%eax
f010372c:	c7 80 28 d0 2f f0 00 	movl   $0x0,-0xfd02fd8(%eax)
f0103733:	00 00 00 
		sched_yield();
f0103736:	e8 73 10 00 00       	call   f01047ae <sched_yield>

f010373b <env_pop_tf>:
{
f010373b:	55                   	push   %ebp
f010373c:	89 e5                	mov    %esp,%ebp
f010373e:	53                   	push   %ebx
f010373f:	83 ec 04             	sub    $0x4,%esp
	curenv->env_cpunum = cpunum();
f0103742:	e8 9d 29 00 00       	call   f01060e4 <cpunum>
f0103747:	6b c0 74             	imul   $0x74,%eax,%eax
f010374a:	8b 98 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%ebx
f0103750:	e8 8f 29 00 00       	call   f01060e4 <cpunum>
f0103755:	89 43 6c             	mov    %eax,0x6c(%ebx)
	asm volatile(
f0103758:	8b 65 08             	mov    0x8(%ebp),%esp
f010375b:	61                   	popa   
f010375c:	07                   	pop    %es
f010375d:	1f                   	pop    %ds
f010375e:	83 c4 08             	add    $0x8,%esp
f0103761:	cf                   	iret   
	panic("iret failed");  /* mostly to placate the compiler */
f0103762:	83 ec 04             	sub    $0x4,%esp
f0103765:	68 e6 82 10 f0       	push   $0xf01082e6
f010376a:	68 1f 02 00 00       	push   $0x21f
f010376f:	68 c6 82 10 f0       	push   $0xf01082c6
f0103774:	e8 c7 c8 ff ff       	call   f0100040 <_panic>

f0103779 <env_mfq_add>:
{
f0103779:	55                   	push   %ebp
f010377a:	89 e5                	mov    %esp,%ebp
f010377c:	53                   	push   %ebx
f010377d:	83 ec 04             	sub    $0x4,%esp
f0103780:	8b 5d 08             	mov    0x8(%ebp),%ebx
	node_remove(&e->env_mfq_link);
f0103783:	89 d8                	mov    %ebx,%eax
f0103785:	e8 b5 f8 ff ff       	call   f010303f <node_remove>
	if (e->env_mfq_time_slices > 0) { // 如果还有时间片剩余
f010378a:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
f010378e:	7e 20                	jle    f01037b0 <env_mfq_add+0x37>
		node_insert(&mfqs[e->env_mfq_level], &(e->env_mfq_link) );	//插入队列头
f0103790:	8b 53 08             	mov    0x8(%ebx),%edx
f0103793:	a1 70 c2 2b f0       	mov    0xf02bc270,%eax
f0103798:	8d 04 d0             	lea    (%eax,%edx,8),%eax
    ln->prev = pos;
f010379b:	89 03                	mov    %eax,(%ebx)
    ln->next = pos->next;
f010379d:	8b 50 04             	mov    0x4(%eax),%edx
f01037a0:	89 53 04             	mov    %edx,0x4(%ebx)
    ln->prev->next = ln;
f01037a3:	89 58 04             	mov    %ebx,0x4(%eax)
    ln->next->prev = ln;
f01037a6:	8b 43 04             	mov    0x4(%ebx),%eax
f01037a9:	89 18                	mov    %ebx,(%eax)
}
f01037ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01037ae:	c9                   	leave  
f01037af:	c3                   	ret    
		uint32_t lv = MIN(e->env_mfq_level + 1, NMFQ - 1);
f01037b0:	8b 43 08             	mov    0x8(%ebx),%eax
f01037b3:	8d 48 01             	lea    0x1(%eax),%ecx
f01037b6:	b8 04 00 00 00       	mov    $0x4,%eax
f01037bb:	39 c1                	cmp    %eax,%ecx
f01037bd:	0f 4f c8             	cmovg  %eax,%ecx
		e->env_mfq_level = lv;
f01037c0:	89 4b 08             	mov    %ecx,0x8(%ebx)
		e->env_mfq_time_slices = (1 << lv) * MFQ_SLICE;
f01037c3:	b8 01 00 00 00       	mov    $0x1,%eax
f01037c8:	d3 e0                	shl    %cl,%eax
f01037ca:	89 43 0c             	mov    %eax,0xc(%ebx)
    node_insert(que->prev, ln);//插入到队列尾巴
f01037cd:	a1 70 c2 2b f0       	mov    0xf02bc270,%eax
f01037d2:	8b 04 c8             	mov    (%eax,%ecx,8),%eax
    ln->prev = pos;
f01037d5:	89 03                	mov    %eax,(%ebx)
    ln->next = pos->next;
f01037d7:	8b 50 04             	mov    0x4(%eax),%edx
f01037da:	89 53 04             	mov    %edx,0x4(%ebx)
    ln->prev->next = ln;
f01037dd:	89 58 04             	mov    %ebx,0x4(%eax)
    ln->next->prev = ln;
f01037e0:	8b 43 04             	mov    0x4(%ebx),%eax
f01037e3:	89 18                	mov    %ebx,(%eax)
}
f01037e5:	eb c4                	jmp    f01037ab <env_mfq_add+0x32>

f01037e7 <env_mfq_pop>:
{
f01037e7:	55                   	push   %ebp
f01037e8:	89 e5                	mov    %esp,%ebp
f01037ea:	83 ec 08             	sub    $0x8,%esp
	node_remove(& (e->env_mfq_link) );
f01037ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01037f0:	e8 4a f8 ff ff       	call   f010303f <node_remove>
}
f01037f5:	c9                   	leave  
f01037f6:	c3                   	ret    

f01037f7 <env_ready>:
{
f01037f7:	55                   	push   %ebp
f01037f8:	89 e5                	mov    %esp,%ebp
f01037fa:	83 ec 14             	sub    $0x14,%esp
f01037fd:	8b 45 08             	mov    0x8(%ebp),%eax
	e->env_status = ENV_RUNNABLE;
f0103800:	c7 40 64 02 00 00 00 	movl   $0x2,0x64(%eax)
	env_mfq_add(e);
f0103807:	50                   	push   %eax
f0103808:	e8 6c ff ff ff       	call   f0103779 <env_mfq_add>
}
f010380d:	83 c4 10             	add    $0x10,%esp
f0103810:	c9                   	leave  
f0103811:	c3                   	ret    

f0103812 <env_run>:
{
f0103812:	55                   	push   %ebp
f0103813:	89 e5                	mov    %esp,%ebp
f0103815:	53                   	push   %ebx
f0103816:	83 ec 04             	sub    $0x4,%esp
f0103819:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if(e == NULL) panic("env_run: invalid environment\n");
f010381c:	85 db                	test   %ebx,%ebx
f010381e:	0f 84 ab 00 00 00    	je     f01038cf <env_run+0xbd>
	if(curenv != NULL) {
f0103824:	e8 bb 28 00 00       	call   f01060e4 <cpunum>
f0103829:	6b c0 74             	imul   $0x74,%eax,%eax
f010382c:	83 b8 28 d0 2f f0 00 	cmpl   $0x0,-0xfd02fd8(%eax)
f0103833:	74 18                	je     f010384d <env_run+0x3b>
		if(curenv->env_status == ENV_RUNNING)  env_ready(curenv);
f0103835:	e8 aa 28 00 00       	call   f01060e4 <cpunum>
f010383a:	6b c0 74             	imul   $0x74,%eax,%eax
f010383d:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0103843:	83 78 64 03          	cmpl   $0x3,0x64(%eax)
f0103847:	0f 84 99 00 00 00    	je     f01038e6 <env_run+0xd4>
	curenv=e;
f010384d:	e8 92 28 00 00       	call   f01060e4 <cpunum>
f0103852:	6b c0 74             	imul   $0x74,%eax,%eax
f0103855:	89 98 28 d0 2f f0    	mov    %ebx,-0xfd02fd8(%eax)
	env_disready(curenv, ENV_RUNNING);
f010385b:	e8 84 28 00 00       	call   f01060e4 <cpunum>
f0103860:	6b c0 74             	imul   $0x74,%eax,%eax
f0103863:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
	e->env_status = new_envtype;
f0103869:	c7 40 64 03 00 00 00 	movl   $0x3,0x64(%eax)
	node_remove(& (e->env_mfq_link) );
f0103870:	e8 ca f7 ff ff       	call   f010303f <node_remove>
	curenv->env_runs++;
f0103875:	e8 6a 28 00 00       	call   f01060e4 <cpunum>
f010387a:	6b c0 74             	imul   $0x74,%eax,%eax
f010387d:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0103883:	83 40 68 01          	addl   $0x1,0x68(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103887:	e8 58 28 00 00       	call   f01060e4 <cpunum>
f010388c:	6b c0 74             	imul   $0x74,%eax,%eax
f010388f:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0103895:	8b 40 70             	mov    0x70(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103898:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010389d:	76 65                	jbe    f0103904 <env_run+0xf2>
	return (physaddr_t)kva - KERNBASE;
f010389f:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f01038a4:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01038a7:	83 ec 0c             	sub    $0xc,%esp
f01038aa:	68 c0 93 12 f0       	push   $0xf01293c0
f01038af:	e8 3a 2b 00 00       	call   f01063ee <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01038b4:	f3 90                	pause  
	env_pop_tf( &(curenv->env_tf) );
f01038b6:	e8 29 28 00 00       	call   f01060e4 <cpunum>
f01038bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01038be:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f01038c4:	83 c0 10             	add    $0x10,%eax
f01038c7:	89 04 24             	mov    %eax,(%esp)
f01038ca:	e8 6c fe ff ff       	call   f010373b <env_pop_tf>
	if(e == NULL) panic("env_run: invalid environment\n");
f01038cf:	83 ec 04             	sub    $0x4,%esp
f01038d2:	68 f2 82 10 f0       	push   $0xf01082f2
f01038d7:	68 3e 02 00 00       	push   $0x23e
f01038dc:	68 c6 82 10 f0       	push   $0xf01082c6
f01038e1:	e8 5a c7 ff ff       	call   f0100040 <_panic>
		if(curenv->env_status == ENV_RUNNING)  env_ready(curenv);
f01038e6:	e8 f9 27 00 00       	call   f01060e4 <cpunum>
f01038eb:	83 ec 0c             	sub    $0xc,%esp
f01038ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01038f1:	ff b0 28 d0 2f f0    	push   -0xfd02fd8(%eax)
f01038f7:	e8 fb fe ff ff       	call   f01037f7 <env_ready>
f01038fc:	83 c4 10             	add    $0x10,%esp
f01038ff:	e9 49 ff ff ff       	jmp    f010384d <env_run+0x3b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103904:	50                   	push   %eax
f0103905:	68 08 70 10 f0       	push   $0xf0107008
f010390a:	68 45 02 00 00       	push   $0x245
f010390f:	68 c6 82 10 f0       	push   $0xf01082c6
f0103914:	e8 27 c7 ff ff       	call   f0100040 <_panic>

f0103919 <env_disready>:
{
f0103919:	55                   	push   %ebp
f010391a:	89 e5                	mov    %esp,%ebp
f010391c:	83 ec 08             	sub    $0x8,%esp
f010391f:	8b 45 08             	mov    0x8(%ebp),%eax
	e->env_status = new_envtype;
f0103922:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103925:	89 50 64             	mov    %edx,0x64(%eax)
	node_remove(& (e->env_mfq_link) );
f0103928:	e8 12 f7 ff ff       	call   f010303f <node_remove>
#ifdef CONF_MFQ
	env_mfq_pop(e);
#endif
f010392d:	c9                   	leave  
f010392e:	c3                   	ret    

f010392f <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010392f:	55                   	push   %ebp
f0103930:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103932:	8b 45 08             	mov    0x8(%ebp),%eax
f0103935:	ba 70 00 00 00       	mov    $0x70,%edx
f010393a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010393b:	ba 71 00 00 00       	mov    $0x71,%edx
f0103940:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103941:	0f b6 c0             	movzbl %al,%eax
}
f0103944:	5d                   	pop    %ebp
f0103945:	c3                   	ret    

f0103946 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103946:	55                   	push   %ebp
f0103947:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103949:	8b 45 08             	mov    0x8(%ebp),%eax
f010394c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103951:	ee                   	out    %al,(%dx)
f0103952:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103955:	ba 71 00 00 00       	mov    $0x71,%edx
f010395a:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010395b:	5d                   	pop    %ebp
f010395c:	c3                   	ret    

f010395d <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010395d:	55                   	push   %ebp
f010395e:	89 e5                	mov    %esp,%ebp
f0103960:	56                   	push   %esi
f0103961:	53                   	push   %ebx
f0103962:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	irq_mask_8259A = mask;
f0103965:	66 89 0d a8 93 12 f0 	mov    %cx,0xf01293a8
	if (!didinit)
f010396c:	80 3d 7c c2 2b f0 00 	cmpb   $0x0,0xf02bc27c
f0103973:	75 07                	jne    f010397c <irq_setmask_8259A+0x1f>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103975:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103978:	5b                   	pop    %ebx
f0103979:	5e                   	pop    %esi
f010397a:	5d                   	pop    %ebp
f010397b:	c3                   	ret    
f010397c:	89 ce                	mov    %ecx,%esi
f010397e:	ba 21 00 00 00       	mov    $0x21,%edx
f0103983:	89 c8                	mov    %ecx,%eax
f0103985:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103986:	89 c8                	mov    %ecx,%eax
f0103988:	66 c1 e8 08          	shr    $0x8,%ax
f010398c:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103991:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103992:	83 ec 0c             	sub    $0xc,%esp
f0103995:	68 10 83 10 f0       	push   $0xf0108310
f010399a:	e8 32 01 00 00       	call   f0103ad1 <cprintf>
f010399f:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01039a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01039a7:	0f b7 f6             	movzwl %si,%esi
f01039aa:	f7 d6                	not    %esi
f01039ac:	eb 08                	jmp    f01039b6 <irq_setmask_8259A+0x59>
	for (i = 0; i < 16; i++)
f01039ae:	83 c3 01             	add    $0x1,%ebx
f01039b1:	83 fb 10             	cmp    $0x10,%ebx
f01039b4:	74 18                	je     f01039ce <irq_setmask_8259A+0x71>
		if (~mask & (1<<i))
f01039b6:	0f a3 de             	bt     %ebx,%esi
f01039b9:	73 f3                	jae    f01039ae <irq_setmask_8259A+0x51>
			cprintf(" %d", i);
f01039bb:	83 ec 08             	sub    $0x8,%esp
f01039be:	53                   	push   %ebx
f01039bf:	68 5b 89 10 f0       	push   $0xf010895b
f01039c4:	e8 08 01 00 00       	call   f0103ad1 <cprintf>
f01039c9:	83 c4 10             	add    $0x10,%esp
f01039cc:	eb e0                	jmp    f01039ae <irq_setmask_8259A+0x51>
	cprintf("\n");
f01039ce:	83 ec 0c             	sub    $0xc,%esp
f01039d1:	68 33 78 10 f0       	push   $0xf0107833
f01039d6:	e8 f6 00 00 00       	call   f0103ad1 <cprintf>
f01039db:	83 c4 10             	add    $0x10,%esp
f01039de:	eb 95                	jmp    f0103975 <irq_setmask_8259A+0x18>

f01039e0 <pic_init>:
{
f01039e0:	55                   	push   %ebp
f01039e1:	89 e5                	mov    %esp,%ebp
f01039e3:	57                   	push   %edi
f01039e4:	56                   	push   %esi
f01039e5:	53                   	push   %ebx
f01039e6:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f01039e9:	c6 05 7c c2 2b f0 01 	movb   $0x1,0xf02bc27c
f01039f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01039f5:	bb 21 00 00 00       	mov    $0x21,%ebx
f01039fa:	89 da                	mov    %ebx,%edx
f01039fc:	ee                   	out    %al,(%dx)
f01039fd:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103a02:	89 ca                	mov    %ecx,%edx
f0103a04:	ee                   	out    %al,(%dx)
f0103a05:	bf 11 00 00 00       	mov    $0x11,%edi
f0103a0a:	be 20 00 00 00       	mov    $0x20,%esi
f0103a0f:	89 f8                	mov    %edi,%eax
f0103a11:	89 f2                	mov    %esi,%edx
f0103a13:	ee                   	out    %al,(%dx)
f0103a14:	b8 20 00 00 00       	mov    $0x20,%eax
f0103a19:	89 da                	mov    %ebx,%edx
f0103a1b:	ee                   	out    %al,(%dx)
f0103a1c:	b8 04 00 00 00       	mov    $0x4,%eax
f0103a21:	ee                   	out    %al,(%dx)
f0103a22:	b8 03 00 00 00       	mov    $0x3,%eax
f0103a27:	ee                   	out    %al,(%dx)
f0103a28:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103a2d:	89 f8                	mov    %edi,%eax
f0103a2f:	89 da                	mov    %ebx,%edx
f0103a31:	ee                   	out    %al,(%dx)
f0103a32:	b8 28 00 00 00       	mov    $0x28,%eax
f0103a37:	89 ca                	mov    %ecx,%edx
f0103a39:	ee                   	out    %al,(%dx)
f0103a3a:	b8 02 00 00 00       	mov    $0x2,%eax
f0103a3f:	ee                   	out    %al,(%dx)
f0103a40:	b8 01 00 00 00       	mov    $0x1,%eax
f0103a45:	ee                   	out    %al,(%dx)
f0103a46:	bf 68 00 00 00       	mov    $0x68,%edi
f0103a4b:	89 f8                	mov    %edi,%eax
f0103a4d:	89 f2                	mov    %esi,%edx
f0103a4f:	ee                   	out    %al,(%dx)
f0103a50:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103a55:	89 c8                	mov    %ecx,%eax
f0103a57:	ee                   	out    %al,(%dx)
f0103a58:	89 f8                	mov    %edi,%eax
f0103a5a:	89 da                	mov    %ebx,%edx
f0103a5c:	ee                   	out    %al,(%dx)
f0103a5d:	89 c8                	mov    %ecx,%eax
f0103a5f:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103a60:	0f b7 05 a8 93 12 f0 	movzwl 0xf01293a8,%eax
f0103a67:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103a6b:	75 08                	jne    f0103a75 <pic_init+0x95>
}
f0103a6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a70:	5b                   	pop    %ebx
f0103a71:	5e                   	pop    %esi
f0103a72:	5f                   	pop    %edi
f0103a73:	5d                   	pop    %ebp
f0103a74:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f0103a75:	83 ec 0c             	sub    $0xc,%esp
f0103a78:	0f b7 c0             	movzwl %ax,%eax
f0103a7b:	50                   	push   %eax
f0103a7c:	e8 dc fe ff ff       	call   f010395d <irq_setmask_8259A>
f0103a81:	83 c4 10             	add    $0x10,%esp
}
f0103a84:	eb e7                	jmp    f0103a6d <pic_init+0x8d>

f0103a86 <irq_eoi>:
f0103a86:	b8 20 00 00 00       	mov    $0x20,%eax
f0103a8b:	ba 20 00 00 00       	mov    $0x20,%edx
f0103a90:	ee                   	out    %al,(%dx)
f0103a91:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103a96:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f0103a97:	c3                   	ret    

f0103a98 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103a98:	55                   	push   %ebp
f0103a99:	89 e5                	mov    %esp,%ebp
f0103a9b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103a9e:	ff 75 08             	push   0x8(%ebp)
f0103aa1:	e8 d5 cc ff ff       	call   f010077b <cputchar>
	*cnt++;
}
f0103aa6:	83 c4 10             	add    $0x10,%esp
f0103aa9:	c9                   	leave  
f0103aaa:	c3                   	ret    

f0103aab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103aab:	55                   	push   %ebp
f0103aac:	89 e5                	mov    %esp,%ebp
f0103aae:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103ab1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103ab8:	ff 75 0c             	push   0xc(%ebp)
f0103abb:	ff 75 08             	push   0x8(%ebp)
f0103abe:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103ac1:	50                   	push   %eax
f0103ac2:	68 98 3a 10 f0       	push   $0xf0103a98
f0103ac7:	e8 00 19 00 00       	call   f01053cc <vprintfmt>
	return cnt;
}
f0103acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103acf:	c9                   	leave  
f0103ad0:	c3                   	ret    

f0103ad1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103ad1:	55                   	push   %ebp
f0103ad2:	89 e5                	mov    %esp,%ebp
f0103ad4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103ad7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103ada:	50                   	push   %eax
f0103adb:	ff 75 08             	push   0x8(%ebp)
f0103ade:	e8 c8 ff ff ff       	call   f0103aab <vcprintf>
	va_end(ap);

	return cnt;
}
f0103ae3:	c9                   	leave  
f0103ae4:	c3                   	ret    

f0103ae5 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103ae5:	55                   	push   %ebp
f0103ae6:	89 e5                	mov    %esp,%ebp
f0103ae8:	57                   	push   %edi
f0103ae9:	56                   	push   %esi
f0103aea:	53                   	push   %ebx
f0103aeb:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	//依照注释hints修改即可
	size_t i =thiscpu->cpu_id;
f0103aee:	e8 f1 25 00 00       	call   f01060e4 <cpunum>
f0103af3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103af6:	0f b6 b8 20 d0 2f f0 	movzbl -0xfd02fe0(%eax),%edi
f0103afd:	89 f8                	mov    %edi,%eax
f0103aff:	0f b6 d8             	movzbl %al,%ebx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
f0103b02:	e8 dd 25 00 00       	call   f01060e4 <cpunum>
f0103b07:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b0a:	ba 00 f0 00 00       	mov    $0xf000,%edx
f0103b0f:	29 da                	sub    %ebx,%edx
f0103b11:	c1 e2 10             	shl    $0x10,%edx
f0103b14:	89 90 30 d0 2f f0    	mov    %edx,-0xfd02fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103b1a:	e8 c5 25 00 00       	call   f01060e4 <cpunum>
f0103b1f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b22:	66 c7 80 34 d0 2f f0 	movw   $0x10,-0xfd02fcc(%eax)
f0103b29:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);//这行不懂，直接较原来程序保持不变
f0103b2b:	e8 b4 25 00 00       	call   f01060e4 <cpunum>
f0103b30:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b33:	66 c7 80 92 d0 2f f0 	movw   $0x68,-0xfd02f6e(%eax)
f0103b3a:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103b3c:	83 c3 05             	add    $0x5,%ebx
f0103b3f:	e8 a0 25 00 00       	call   f01060e4 <cpunum>
f0103b44:	89 c6                	mov    %eax,%esi
f0103b46:	e8 99 25 00 00       	call   f01060e4 <cpunum>
f0103b4b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103b4e:	e8 91 25 00 00       	call   f01060e4 <cpunum>
f0103b53:	66 c7 04 dd 40 93 12 	movw   $0x67,-0xfed6cc0(,%ebx,8)
f0103b5a:	f0 67 00 
f0103b5d:	6b f6 74             	imul   $0x74,%esi,%esi
f0103b60:	81 c6 2c d0 2f f0    	add    $0xf02fd02c,%esi
f0103b66:	66 89 34 dd 42 93 12 	mov    %si,-0xfed6cbe(,%ebx,8)
f0103b6d:	f0 
f0103b6e:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103b72:	81 c2 2c d0 2f f0    	add    $0xf02fd02c,%edx
f0103b78:	c1 ea 10             	shr    $0x10,%edx
f0103b7b:	88 14 dd 44 93 12 f0 	mov    %dl,-0xfed6cbc(,%ebx,8)
f0103b82:	c6 04 dd 46 93 12 f0 	movb   $0x40,-0xfed6cba(,%ebx,8)
f0103b89:	40 
f0103b8a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b8d:	05 2c d0 2f f0       	add    $0xf02fd02c,%eax
f0103b92:	c1 e8 18             	shr    $0x18,%eax
f0103b95:	88 04 dd 47 93 12 f0 	mov    %al,-0xfed6cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103b9c:	c6 04 dd 45 93 12 f0 	movb   $0x89,-0xfed6cbb(,%ebx,8)
f0103ba3:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (i << 3));//相应的TSS选择子也要修改
f0103ba4:	89 f8                	mov    %edi,%eax
f0103ba6:	0f b6 f8             	movzbl %al,%edi
f0103ba9:	8d 3c fd 28 00 00 00 	lea    0x28(,%edi,8),%edi
	asm volatile("ltr %0" : : "r" (sel));
f0103bb0:	0f 00 df             	ltr    %di
	asm volatile("lidt (%0)" : : "r" (p));
f0103bb3:	b8 ac 93 12 f0       	mov    $0xf01293ac,%eax
f0103bb8:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103bbb:	83 c4 1c             	add    $0x1c,%esp
f0103bbe:	5b                   	pop    %ebx
f0103bbf:	5e                   	pop    %esi
f0103bc0:	5f                   	pop    %edi
f0103bc1:	5d                   	pop    %ebp
f0103bc2:	c3                   	ret    

f0103bc3 <trap_init>:
{
f0103bc3:	55                   	push   %ebp
f0103bc4:	89 e5                	mov    %esp,%ebp
f0103bc6:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, DIVIDE_HANDLER, 0);//GD_KT  kernel text
f0103bc9:	b8 44 46 10 f0       	mov    $0xf0104644,%eax
f0103bce:	66 a3 80 c2 2b f0    	mov    %ax,0xf02bc280
f0103bd4:	66 c7 05 82 c2 2b f0 	movw   $0x8,0xf02bc282
f0103bdb:	08 00 
f0103bdd:	c6 05 84 c2 2b f0 00 	movb   $0x0,0xf02bc284
f0103be4:	c6 05 85 c2 2b f0 8e 	movb   $0x8e,0xf02bc285
f0103beb:	c1 e8 10             	shr    $0x10,%eax
f0103bee:	66 a3 86 c2 2b f0    	mov    %ax,0xf02bc286
	SETGATE(idt[T_DEBUG], 0, GD_KT, DEBUG_HANDLER, 0);
f0103bf4:	b8 4e 46 10 f0       	mov    $0xf010464e,%eax
f0103bf9:	66 a3 88 c2 2b f0    	mov    %ax,0xf02bc288
f0103bff:	66 c7 05 8a c2 2b f0 	movw   $0x8,0xf02bc28a
f0103c06:	08 00 
f0103c08:	c6 05 8c c2 2b f0 00 	movb   $0x0,0xf02bc28c
f0103c0f:	c6 05 8d c2 2b f0 8e 	movb   $0x8e,0xf02bc28d
f0103c16:	c1 e8 10             	shr    $0x10,%eax
f0103c19:	66 a3 8e c2 2b f0    	mov    %ax,0xf02bc28e
	SETGATE(idt[T_NMI], 0, GD_KT, NMI_HANDLER, 0);
f0103c1f:	b8 54 46 10 f0       	mov    $0xf0104654,%eax
f0103c24:	66 a3 90 c2 2b f0    	mov    %ax,0xf02bc290
f0103c2a:	66 c7 05 92 c2 2b f0 	movw   $0x8,0xf02bc292
f0103c31:	08 00 
f0103c33:	c6 05 94 c2 2b f0 00 	movb   $0x0,0xf02bc294
f0103c3a:	c6 05 95 c2 2b f0 8e 	movb   $0x8e,0xf02bc295
f0103c41:	c1 e8 10             	shr    $0x10,%eax
f0103c44:	66 a3 96 c2 2b f0    	mov    %ax,0xf02bc296
	SETGATE(idt[T_BRKPT], 0, GD_KT, BRKPT_HANDLER, 3);//exercise 6在此处需要修改
f0103c4a:	b8 5a 46 10 f0       	mov    $0xf010465a,%eax
f0103c4f:	66 a3 98 c2 2b f0    	mov    %ax,0xf02bc298
f0103c55:	66 c7 05 9a c2 2b f0 	movw   $0x8,0xf02bc29a
f0103c5c:	08 00 
f0103c5e:	c6 05 9c c2 2b f0 00 	movb   $0x0,0xf02bc29c
f0103c65:	c6 05 9d c2 2b f0 ee 	movb   $0xee,0xf02bc29d
f0103c6c:	c1 e8 10             	shr    $0x10,%eax
f0103c6f:	66 a3 9e c2 2b f0    	mov    %ax,0xf02bc29e
	SETGATE(idt[T_OFLOW], 0, GD_KT, OFLOW_HANDLER, 0);
f0103c75:	b8 60 46 10 f0       	mov    $0xf0104660,%eax
f0103c7a:	66 a3 a0 c2 2b f0    	mov    %ax,0xf02bc2a0
f0103c80:	66 c7 05 a2 c2 2b f0 	movw   $0x8,0xf02bc2a2
f0103c87:	08 00 
f0103c89:	c6 05 a4 c2 2b f0 00 	movb   $0x0,0xf02bc2a4
f0103c90:	c6 05 a5 c2 2b f0 8e 	movb   $0x8e,0xf02bc2a5
f0103c97:	c1 e8 10             	shr    $0x10,%eax
f0103c9a:	66 a3 a6 c2 2b f0    	mov    %ax,0xf02bc2a6
	SETGATE(idt[T_BOUND], 0, GD_KT, BOUND_HANDLER, 0);
f0103ca0:	b8 66 46 10 f0       	mov    $0xf0104666,%eax
f0103ca5:	66 a3 a8 c2 2b f0    	mov    %ax,0xf02bc2a8
f0103cab:	66 c7 05 aa c2 2b f0 	movw   $0x8,0xf02bc2aa
f0103cb2:	08 00 
f0103cb4:	c6 05 ac c2 2b f0 00 	movb   $0x0,0xf02bc2ac
f0103cbb:	c6 05 ad c2 2b f0 8e 	movb   $0x8e,0xf02bc2ad
f0103cc2:	c1 e8 10             	shr    $0x10,%eax
f0103cc5:	66 a3 ae c2 2b f0    	mov    %ax,0xf02bc2ae
	SETGATE(idt[T_ILLOP], 0, GD_KT, ILLOP_HANDLER, 0);
f0103ccb:	b8 6c 46 10 f0       	mov    $0xf010466c,%eax
f0103cd0:	66 a3 b0 c2 2b f0    	mov    %ax,0xf02bc2b0
f0103cd6:	66 c7 05 b2 c2 2b f0 	movw   $0x8,0xf02bc2b2
f0103cdd:	08 00 
f0103cdf:	c6 05 b4 c2 2b f0 00 	movb   $0x0,0xf02bc2b4
f0103ce6:	c6 05 b5 c2 2b f0 8e 	movb   $0x8e,0xf02bc2b5
f0103ced:	c1 e8 10             	shr    $0x10,%eax
f0103cf0:	66 a3 b6 c2 2b f0    	mov    %ax,0xf02bc2b6
	SETGATE(idt[T_DEVICE], 0, GD_KT, DEVICE_HANDLER, 0);
f0103cf6:	b8 72 46 10 f0       	mov    $0xf0104672,%eax
f0103cfb:	66 a3 b8 c2 2b f0    	mov    %ax,0xf02bc2b8
f0103d01:	66 c7 05 ba c2 2b f0 	movw   $0x8,0xf02bc2ba
f0103d08:	08 00 
f0103d0a:	c6 05 bc c2 2b f0 00 	movb   $0x0,0xf02bc2bc
f0103d11:	c6 05 bd c2 2b f0 8e 	movb   $0x8e,0xf02bc2bd
f0103d18:	c1 e8 10             	shr    $0x10,%eax
f0103d1b:	66 a3 be c2 2b f0    	mov    %ax,0xf02bc2be
	SETGATE(idt[T_DBLFLT], 0, GD_KT, DBLFLT_HANDLER, 0);
f0103d21:	b8 78 46 10 f0       	mov    $0xf0104678,%eax
f0103d26:	66 a3 c0 c2 2b f0    	mov    %ax,0xf02bc2c0
f0103d2c:	66 c7 05 c2 c2 2b f0 	movw   $0x8,0xf02bc2c2
f0103d33:	08 00 
f0103d35:	c6 05 c4 c2 2b f0 00 	movb   $0x0,0xf02bc2c4
f0103d3c:	c6 05 c5 c2 2b f0 8e 	movb   $0x8e,0xf02bc2c5
f0103d43:	c1 e8 10             	shr    $0x10,%eax
f0103d46:	66 a3 c6 c2 2b f0    	mov    %ax,0xf02bc2c6
	SETGATE(idt[T_TSS], 0, GD_KT, TSS_HANDLER, 0);
f0103d4c:	b8 7c 46 10 f0       	mov    $0xf010467c,%eax
f0103d51:	66 a3 d0 c2 2b f0    	mov    %ax,0xf02bc2d0
f0103d57:	66 c7 05 d2 c2 2b f0 	movw   $0x8,0xf02bc2d2
f0103d5e:	08 00 
f0103d60:	c6 05 d4 c2 2b f0 00 	movb   $0x0,0xf02bc2d4
f0103d67:	c6 05 d5 c2 2b f0 8e 	movb   $0x8e,0xf02bc2d5
f0103d6e:	c1 e8 10             	shr    $0x10,%eax
f0103d71:	66 a3 d6 c2 2b f0    	mov    %ax,0xf02bc2d6
	SETGATE(idt[T_SEGNP], 0, GD_KT, SEGNP_HANDLER, 0);
f0103d77:	b8 80 46 10 f0       	mov    $0xf0104680,%eax
f0103d7c:	66 a3 d8 c2 2b f0    	mov    %ax,0xf02bc2d8
f0103d82:	66 c7 05 da c2 2b f0 	movw   $0x8,0xf02bc2da
f0103d89:	08 00 
f0103d8b:	c6 05 dc c2 2b f0 00 	movb   $0x0,0xf02bc2dc
f0103d92:	c6 05 dd c2 2b f0 8e 	movb   $0x8e,0xf02bc2dd
f0103d99:	c1 e8 10             	shr    $0x10,%eax
f0103d9c:	66 a3 de c2 2b f0    	mov    %ax,0xf02bc2de
	SETGATE(idt[T_STACK], 0, GD_KT, STACK_HANDLER, 0);
f0103da2:	b8 84 46 10 f0       	mov    $0xf0104684,%eax
f0103da7:	66 a3 e0 c2 2b f0    	mov    %ax,0xf02bc2e0
f0103dad:	66 c7 05 e2 c2 2b f0 	movw   $0x8,0xf02bc2e2
f0103db4:	08 00 
f0103db6:	c6 05 e4 c2 2b f0 00 	movb   $0x0,0xf02bc2e4
f0103dbd:	c6 05 e5 c2 2b f0 8e 	movb   $0x8e,0xf02bc2e5
f0103dc4:	c1 e8 10             	shr    $0x10,%eax
f0103dc7:	66 a3 e6 c2 2b f0    	mov    %ax,0xf02bc2e6
	SETGATE(idt[T_GPFLT], 0, GD_KT, GPFLT_HANDLER, 0);
f0103dcd:	b8 88 46 10 f0       	mov    $0xf0104688,%eax
f0103dd2:	66 a3 e8 c2 2b f0    	mov    %ax,0xf02bc2e8
f0103dd8:	66 c7 05 ea c2 2b f0 	movw   $0x8,0xf02bc2ea
f0103ddf:	08 00 
f0103de1:	c6 05 ec c2 2b f0 00 	movb   $0x0,0xf02bc2ec
f0103de8:	c6 05 ed c2 2b f0 8e 	movb   $0x8e,0xf02bc2ed
f0103def:	c1 e8 10             	shr    $0x10,%eax
f0103df2:	66 a3 ee c2 2b f0    	mov    %ax,0xf02bc2ee
	SETGATE(idt[T_PGFLT], 0, GD_KT, PGFLT_HANDLER, 0);
f0103df8:	b8 8c 46 10 f0       	mov    $0xf010468c,%eax
f0103dfd:	66 a3 f0 c2 2b f0    	mov    %ax,0xf02bc2f0
f0103e03:	66 c7 05 f2 c2 2b f0 	movw   $0x8,0xf02bc2f2
f0103e0a:	08 00 
f0103e0c:	c6 05 f4 c2 2b f0 00 	movb   $0x0,0xf02bc2f4
f0103e13:	c6 05 f5 c2 2b f0 8e 	movb   $0x8e,0xf02bc2f5
f0103e1a:	c1 e8 10             	shr    $0x10,%eax
f0103e1d:	66 a3 f6 c2 2b f0    	mov    %ax,0xf02bc2f6
	SETGATE(idt[T_FPERR], 0, GD_KT, FPERR_HANDLER, 0);
f0103e23:	b8 90 46 10 f0       	mov    $0xf0104690,%eax
f0103e28:	66 a3 00 c3 2b f0    	mov    %ax,0xf02bc300
f0103e2e:	66 c7 05 02 c3 2b f0 	movw   $0x8,0xf02bc302
f0103e35:	08 00 
f0103e37:	c6 05 04 c3 2b f0 00 	movb   $0x0,0xf02bc304
f0103e3e:	c6 05 05 c3 2b f0 8e 	movb   $0x8e,0xf02bc305
f0103e45:	c1 e8 10             	shr    $0x10,%eax
f0103e48:	66 a3 06 c3 2b f0    	mov    %ax,0xf02bc306
	SETGATE(idt[T_ALIGN], 0, GD_KT, ALIGN_HANDLER, 0);
f0103e4e:	b8 96 46 10 f0       	mov    $0xf0104696,%eax
f0103e53:	66 a3 08 c3 2b f0    	mov    %ax,0xf02bc308
f0103e59:	66 c7 05 0a c3 2b f0 	movw   $0x8,0xf02bc30a
f0103e60:	08 00 
f0103e62:	c6 05 0c c3 2b f0 00 	movb   $0x0,0xf02bc30c
f0103e69:	c6 05 0d c3 2b f0 8e 	movb   $0x8e,0xf02bc30d
f0103e70:	c1 e8 10             	shr    $0x10,%eax
f0103e73:	66 a3 0e c3 2b f0    	mov    %ax,0xf02bc30e
	SETGATE(idt[T_MCHK], 0, GD_KT, MCHK_HANDLER, 0);
f0103e79:	b8 9a 46 10 f0       	mov    $0xf010469a,%eax
f0103e7e:	66 a3 10 c3 2b f0    	mov    %ax,0xf02bc310
f0103e84:	66 c7 05 12 c3 2b f0 	movw   $0x8,0xf02bc312
f0103e8b:	08 00 
f0103e8d:	c6 05 14 c3 2b f0 00 	movb   $0x0,0xf02bc314
f0103e94:	c6 05 15 c3 2b f0 8e 	movb   $0x8e,0xf02bc315
f0103e9b:	c1 e8 10             	shr    $0x10,%eax
f0103e9e:	66 a3 16 c3 2b f0    	mov    %ax,0xf02bc316
	SETGATE(idt[T_SIMDERR], 0, GD_KT, SIMDERR_HANDLER, 0);
f0103ea4:	b8 a0 46 10 f0       	mov    $0xf01046a0,%eax
f0103ea9:	66 a3 18 c3 2b f0    	mov    %ax,0xf02bc318
f0103eaf:	66 c7 05 1a c3 2b f0 	movw   $0x8,0xf02bc31a
f0103eb6:	08 00 
f0103eb8:	c6 05 1c c3 2b f0 00 	movb   $0x0,0xf02bc31c
f0103ebf:	c6 05 1d c3 2b f0 8e 	movb   $0x8e,0xf02bc31d
f0103ec6:	c1 e8 10             	shr    $0x10,%eax
f0103ec9:	66 a3 1e c3 2b f0    	mov    %ax,0xf02bc31e
	SETGATE(idt[T_SYSCALL], 0 , GD_KT, SYSCALL_HANDLER, 3);//需要将dpl设置为3,因为这是用户态下调用的系统调用（中断）
f0103ecf:	b8 a6 46 10 f0       	mov    $0xf01046a6,%eax
f0103ed4:	66 a3 00 c4 2b f0    	mov    %ax,0xf02bc400
f0103eda:	66 c7 05 02 c4 2b f0 	movw   $0x8,0xf02bc402
f0103ee1:	08 00 
f0103ee3:	c6 05 04 c4 2b f0 00 	movb   $0x0,0xf02bc404
f0103eea:	c6 05 05 c4 2b f0 ee 	movb   $0xee,0xf02bc405
f0103ef1:	c1 e8 10             	shr    $0x10,%eax
f0103ef4:	66 a3 06 c4 2b f0    	mov    %ax,0xf02bc406
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],    0, GD_KT, timer_handler,   0);//中断是让内核抢占控制权，所以dpl应该设置为0。
f0103efa:	b8 ac 46 10 f0       	mov    $0xf01046ac,%eax
f0103eff:	66 a3 80 c3 2b f0    	mov    %ax,0xf02bc380
f0103f05:	66 c7 05 82 c3 2b f0 	movw   $0x8,0xf02bc382
f0103f0c:	08 00 
f0103f0e:	c6 05 84 c3 2b f0 00 	movb   $0x0,0xf02bc384
f0103f15:	c6 05 85 c3 2b f0 8e 	movb   $0x8e,0xf02bc385
f0103f1c:	c1 e8 10             	shr    $0x10,%eax
f0103f1f:	66 a3 86 c3 2b f0    	mov    %ax,0xf02bc386
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD],      0, GD_KT, kbd_handler,     0);
f0103f25:	b8 b2 46 10 f0       	mov    $0xf01046b2,%eax
f0103f2a:	66 a3 88 c3 2b f0    	mov    %ax,0xf02bc388
f0103f30:	66 c7 05 8a c3 2b f0 	movw   $0x8,0xf02bc38a
f0103f37:	08 00 
f0103f39:	c6 05 8c c3 2b f0 00 	movb   $0x0,0xf02bc38c
f0103f40:	c6 05 8d c3 2b f0 8e 	movb   $0x8e,0xf02bc38d
f0103f47:	c1 e8 10             	shr    $0x10,%eax
f0103f4a:	66 a3 8e c3 2b f0    	mov    %ax,0xf02bc38e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL],   0, GD_KT, serial_handler,  0);
f0103f50:	b8 b8 46 10 f0       	mov    $0xf01046b8,%eax
f0103f55:	66 a3 a0 c3 2b f0    	mov    %ax,0xf02bc3a0
f0103f5b:	66 c7 05 a2 c3 2b f0 	movw   $0x8,0xf02bc3a2
f0103f62:	08 00 
f0103f64:	c6 05 a4 c3 2b f0 00 	movb   $0x0,0xf02bc3a4
f0103f6b:	c6 05 a5 c3 2b f0 8e 	movb   $0x8e,0xf02bc3a5
f0103f72:	c1 e8 10             	shr    $0x10,%eax
f0103f75:	66 a3 a6 c3 2b f0    	mov    %ax,0xf02bc3a6
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, spurious_handler,0);
f0103f7b:	b8 be 46 10 f0       	mov    $0xf01046be,%eax
f0103f80:	66 a3 b8 c3 2b f0    	mov    %ax,0xf02bc3b8
f0103f86:	66 c7 05 ba c3 2b f0 	movw   $0x8,0xf02bc3ba
f0103f8d:	08 00 
f0103f8f:	c6 05 bc c3 2b f0 00 	movb   $0x0,0xf02bc3bc
f0103f96:	c6 05 bd c3 2b f0 8e 	movb   $0x8e,0xf02bc3bd
f0103f9d:	c1 e8 10             	shr    $0x10,%eax
f0103fa0:	66 a3 be c3 2b f0    	mov    %ax,0xf02bc3be
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE],      0, GD_KT, ide_handler,     0);
f0103fa6:	b8 c4 46 10 f0       	mov    $0xf01046c4,%eax
f0103fab:	66 a3 f0 c3 2b f0    	mov    %ax,0xf02bc3f0
f0103fb1:	66 c7 05 f2 c3 2b f0 	movw   $0x8,0xf02bc3f2
f0103fb8:	08 00 
f0103fba:	c6 05 f4 c3 2b f0 00 	movb   $0x0,0xf02bc3f4
f0103fc1:	c6 05 f5 c3 2b f0 8e 	movb   $0x8e,0xf02bc3f5
f0103fc8:	c1 e8 10             	shr    $0x10,%eax
f0103fcb:	66 a3 f6 c3 2b f0    	mov    %ax,0xf02bc3f6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR],    0, GD_KT, error_handler,   0);
f0103fd1:	b8 ca 46 10 f0       	mov    $0xf01046ca,%eax
f0103fd6:	66 a3 18 c4 2b f0    	mov    %ax,0xf02bc418
f0103fdc:	66 c7 05 1a c4 2b f0 	movw   $0x8,0xf02bc41a
f0103fe3:	08 00 
f0103fe5:	c6 05 1c c4 2b f0 00 	movb   $0x0,0xf02bc41c
f0103fec:	c6 05 1d c4 2b f0 8e 	movb   $0x8e,0xf02bc41d
f0103ff3:	c1 e8 10             	shr    $0x10,%eax
f0103ff6:	66 a3 1e c4 2b f0    	mov    %ax,0xf02bc41e
	trap_init_percpu();
f0103ffc:	e8 e4 fa ff ff       	call   f0103ae5 <trap_init_percpu>
}
f0104001:	c9                   	leave  
f0104002:	c3                   	ret    

f0104003 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104003:	55                   	push   %ebp
f0104004:	89 e5                	mov    %esp,%ebp
f0104006:	53                   	push   %ebx
f0104007:	83 ec 0c             	sub    $0xc,%esp
f010400a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010400d:	ff 33                	push   (%ebx)
f010400f:	68 24 83 10 f0       	push   $0xf0108324
f0104014:	e8 b8 fa ff ff       	call   f0103ad1 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104019:	83 c4 08             	add    $0x8,%esp
f010401c:	ff 73 04             	push   0x4(%ebx)
f010401f:	68 33 83 10 f0       	push   $0xf0108333
f0104024:	e8 a8 fa ff ff       	call   f0103ad1 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104029:	83 c4 08             	add    $0x8,%esp
f010402c:	ff 73 08             	push   0x8(%ebx)
f010402f:	68 42 83 10 f0       	push   $0xf0108342
f0104034:	e8 98 fa ff ff       	call   f0103ad1 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104039:	83 c4 08             	add    $0x8,%esp
f010403c:	ff 73 0c             	push   0xc(%ebx)
f010403f:	68 51 83 10 f0       	push   $0xf0108351
f0104044:	e8 88 fa ff ff       	call   f0103ad1 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104049:	83 c4 08             	add    $0x8,%esp
f010404c:	ff 73 10             	push   0x10(%ebx)
f010404f:	68 60 83 10 f0       	push   $0xf0108360
f0104054:	e8 78 fa ff ff       	call   f0103ad1 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104059:	83 c4 08             	add    $0x8,%esp
f010405c:	ff 73 14             	push   0x14(%ebx)
f010405f:	68 6f 83 10 f0       	push   $0xf010836f
f0104064:	e8 68 fa ff ff       	call   f0103ad1 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104069:	83 c4 08             	add    $0x8,%esp
f010406c:	ff 73 18             	push   0x18(%ebx)
f010406f:	68 7e 83 10 f0       	push   $0xf010837e
f0104074:	e8 58 fa ff ff       	call   f0103ad1 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104079:	83 c4 08             	add    $0x8,%esp
f010407c:	ff 73 1c             	push   0x1c(%ebx)
f010407f:	68 8d 83 10 f0       	push   $0xf010838d
f0104084:	e8 48 fa ff ff       	call   f0103ad1 <cprintf>
}
f0104089:	83 c4 10             	add    $0x10,%esp
f010408c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010408f:	c9                   	leave  
f0104090:	c3                   	ret    

f0104091 <print_trapframe>:
{
f0104091:	55                   	push   %ebp
f0104092:	89 e5                	mov    %esp,%ebp
f0104094:	56                   	push   %esi
f0104095:	53                   	push   %ebx
f0104096:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104099:	e8 46 20 00 00       	call   f01060e4 <cpunum>
f010409e:	83 ec 04             	sub    $0x4,%esp
f01040a1:	50                   	push   %eax
f01040a2:	53                   	push   %ebx
f01040a3:	68 f1 83 10 f0       	push   $0xf01083f1
f01040a8:	e8 24 fa ff ff       	call   f0103ad1 <cprintf>
	print_regs(&tf->tf_regs);
f01040ad:	89 1c 24             	mov    %ebx,(%esp)
f01040b0:	e8 4e ff ff ff       	call   f0104003 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01040b5:	83 c4 08             	add    $0x8,%esp
f01040b8:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01040bc:	50                   	push   %eax
f01040bd:	68 0f 84 10 f0       	push   $0xf010840f
f01040c2:	e8 0a fa ff ff       	call   f0103ad1 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01040c7:	83 c4 08             	add    $0x8,%esp
f01040ca:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01040ce:	50                   	push   %eax
f01040cf:	68 22 84 10 f0       	push   $0xf0108422
f01040d4:	e8 f8 f9 ff ff       	call   f0103ad1 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01040d9:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f01040dc:	83 c4 10             	add    $0x10,%esp
f01040df:	83 f8 13             	cmp    $0x13,%eax
f01040e2:	0f 86 da 00 00 00    	jbe    f01041c2 <print_trapframe+0x131>
		return "System call";
f01040e8:	ba 9c 83 10 f0       	mov    $0xf010839c,%edx
	if (trapno == T_SYSCALL)
f01040ed:	83 f8 30             	cmp    $0x30,%eax
f01040f0:	74 13                	je     f0104105 <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01040f2:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f01040f5:	83 fa 0f             	cmp    $0xf,%edx
f01040f8:	ba a8 83 10 f0       	mov    $0xf01083a8,%edx
f01040fd:	b9 b7 83 10 f0       	mov    $0xf01083b7,%ecx
f0104102:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104105:	83 ec 04             	sub    $0x4,%esp
f0104108:	52                   	push   %edx
f0104109:	50                   	push   %eax
f010410a:	68 35 84 10 f0       	push   $0xf0108435
f010410f:	e8 bd f9 ff ff       	call   f0103ad1 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104114:	83 c4 10             	add    $0x10,%esp
f0104117:	39 1d 80 ca 2b f0    	cmp    %ebx,0xf02bca80
f010411d:	0f 84 ab 00 00 00    	je     f01041ce <print_trapframe+0x13d>
	cprintf("  err  0x%08x", tf->tf_err);
f0104123:	83 ec 08             	sub    $0x8,%esp
f0104126:	ff 73 2c             	push   0x2c(%ebx)
f0104129:	68 56 84 10 f0       	push   $0xf0108456
f010412e:	e8 9e f9 ff ff       	call   f0103ad1 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104133:	83 c4 10             	add    $0x10,%esp
f0104136:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010413a:	0f 85 b1 00 00 00    	jne    f01041f1 <print_trapframe+0x160>
			tf->tf_err & 1 ? "protection" : "not-present");
f0104140:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0104143:	a8 01                	test   $0x1,%al
f0104145:	b9 ca 83 10 f0       	mov    $0xf01083ca,%ecx
f010414a:	ba d5 83 10 f0       	mov    $0xf01083d5,%edx
f010414f:	0f 44 ca             	cmove  %edx,%ecx
f0104152:	a8 02                	test   $0x2,%al
f0104154:	ba e1 83 10 f0       	mov    $0xf01083e1,%edx
f0104159:	be e7 83 10 f0       	mov    $0xf01083e7,%esi
f010415e:	0f 44 d6             	cmove  %esi,%edx
f0104161:	a8 04                	test   $0x4,%al
f0104163:	b8 ec 83 10 f0       	mov    $0xf01083ec,%eax
f0104168:	be 21 85 10 f0       	mov    $0xf0108521,%esi
f010416d:	0f 44 c6             	cmove  %esi,%eax
f0104170:	51                   	push   %ecx
f0104171:	52                   	push   %edx
f0104172:	50                   	push   %eax
f0104173:	68 64 84 10 f0       	push   $0xf0108464
f0104178:	e8 54 f9 ff ff       	call   f0103ad1 <cprintf>
f010417d:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104180:	83 ec 08             	sub    $0x8,%esp
f0104183:	ff 73 30             	push   0x30(%ebx)
f0104186:	68 73 84 10 f0       	push   $0xf0108473
f010418b:	e8 41 f9 ff ff       	call   f0103ad1 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104190:	83 c4 08             	add    $0x8,%esp
f0104193:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104197:	50                   	push   %eax
f0104198:	68 82 84 10 f0       	push   $0xf0108482
f010419d:	e8 2f f9 ff ff       	call   f0103ad1 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01041a2:	83 c4 08             	add    $0x8,%esp
f01041a5:	ff 73 38             	push   0x38(%ebx)
f01041a8:	68 95 84 10 f0       	push   $0xf0108495
f01041ad:	e8 1f f9 ff ff       	call   f0103ad1 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01041b2:	83 c4 10             	add    $0x10,%esp
f01041b5:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01041b9:	75 4b                	jne    f0104206 <print_trapframe+0x175>
}
f01041bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01041be:	5b                   	pop    %ebx
f01041bf:	5e                   	pop    %esi
f01041c0:	5d                   	pop    %ebp
f01041c1:	c3                   	ret    
		return excnames[trapno];
f01041c2:	8b 14 85 00 88 10 f0 	mov    -0xfef7800(,%eax,4),%edx
f01041c9:	e9 37 ff ff ff       	jmp    f0104105 <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01041ce:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01041d2:	0f 85 4b ff ff ff    	jne    f0104123 <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01041d8:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01041db:	83 ec 08             	sub    $0x8,%esp
f01041de:	50                   	push   %eax
f01041df:	68 47 84 10 f0       	push   $0xf0108447
f01041e4:	e8 e8 f8 ff ff       	call   f0103ad1 <cprintf>
f01041e9:	83 c4 10             	add    $0x10,%esp
f01041ec:	e9 32 ff ff ff       	jmp    f0104123 <print_trapframe+0x92>
		cprintf("\n");
f01041f1:	83 ec 0c             	sub    $0xc,%esp
f01041f4:	68 33 78 10 f0       	push   $0xf0107833
f01041f9:	e8 d3 f8 ff ff       	call   f0103ad1 <cprintf>
f01041fe:	83 c4 10             	add    $0x10,%esp
f0104201:	e9 7a ff ff ff       	jmp    f0104180 <print_trapframe+0xef>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104206:	83 ec 08             	sub    $0x8,%esp
f0104209:	ff 73 3c             	push   0x3c(%ebx)
f010420c:	68 a4 84 10 f0       	push   $0xf01084a4
f0104211:	e8 bb f8 ff ff       	call   f0103ad1 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104216:	83 c4 08             	add    $0x8,%esp
f0104219:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010421d:	50                   	push   %eax
f010421e:	68 b3 84 10 f0       	push   $0xf01084b3
f0104223:	e8 a9 f8 ff ff       	call   f0103ad1 <cprintf>
f0104228:	83 c4 10             	add    $0x10,%esp
}
f010422b:	eb 8e                	jmp    f01041bb <print_trapframe+0x12a>

f010422d <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010422d:	55                   	push   %ebp
f010422e:	89 e5                	mov    %esp,%ebp
f0104230:	57                   	push   %edi
f0104231:	56                   	push   %esi
f0104232:	53                   	push   %ebx
f0104233:	83 ec 0c             	sub    $0xc,%esp
f0104236:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104239:	0f 20 d6             	mov    %cr2,%esi
	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	// LAB 3: Your code here.  CPL为0时，为内核态。
	if( (tf->tf_cs & 3) == 0) panic("page_fault in kernel mode, fault address %u\n", fault_va);
f010423c:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104240:	74 5d                	je     f010429f <page_fault_handler+0x72>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.
	//注意， 其实并没有切换环境！！
	if (curenv->env_pgfault_upcall){
f0104242:	e8 9d 1e 00 00       	call   f01060e4 <cpunum>
f0104247:	6b c0 74             	imul   $0x74,%eax,%eax
f010424a:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104250:	83 78 74 00          	cmpl   $0x0,0x74(%eax)
f0104254:	75 5e                	jne    f01042b4 <page_fault_handler+0x87>
		curenv->env_tf.tf_esp        = (uint32_t) utf;

		env_run(curenv);
	}else{
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104256:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f0104259:	e8 86 1e 00 00       	call   f01060e4 <cpunum>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010425e:	57                   	push   %edi
f010425f:	56                   	push   %esi
			curenv->env_id, fault_va, tf->tf_eip);
f0104260:	6b c0 74             	imul   $0x74,%eax,%eax
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104263:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104269:	ff 70 58             	push   0x58(%eax)
f010426c:	68 9c 86 10 f0       	push   $0xf010869c
f0104271:	e8 5b f8 ff ff       	call   f0103ad1 <cprintf>
		print_trapframe(tf);
f0104276:	89 1c 24             	mov    %ebx,(%esp)
f0104279:	e8 13 fe ff ff       	call   f0104091 <print_trapframe>
		env_destroy(curenv);	
f010427e:	e8 61 1e 00 00       	call   f01060e4 <cpunum>
f0104283:	83 c4 04             	add    $0x4,%esp
f0104286:	6b c0 74             	imul   $0x74,%eax,%eax
f0104289:	ff b0 28 d0 2f f0    	push   -0xfd02fd8(%eax)
f010428f:	e8 46 f4 ff ff       	call   f01036da <env_destroy>
	}
}
f0104294:	83 c4 10             	add    $0x10,%esp
f0104297:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010429a:	5b                   	pop    %ebx
f010429b:	5e                   	pop    %esi
f010429c:	5f                   	pop    %edi
f010429d:	5d                   	pop    %ebp
f010429e:	c3                   	ret    
	if( (tf->tf_cs & 3) == 0) panic("page_fault in kernel mode, fault address %u\n", fault_va);
f010429f:	56                   	push   %esi
f01042a0:	68 6c 86 10 f0       	push   $0xf010866c
f01042a5:	68 96 01 00 00       	push   $0x196
f01042aa:	68 c6 84 10 f0       	push   $0xf01084c6
f01042af:	e8 8c bd ff ff       	call   f0100040 <_panic>
		if(UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1) // 发生异常时陷入。
f01042b4:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01042b7:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f01042bd:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
		if(UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1) // 发生异常时陷入。
f01042c2:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01042c8:	77 05                	ja     f01042cf <page_fault_handler+0xa2>
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);//要求的32位空字。
f01042ca:	83 e8 38             	sub    $0x38,%eax
f01042cd:	89 c7                	mov    %eax,%edi
		user_mem_assert(curenv, (const void *) utf, sizeof(struct UTrapframe), PTE_P|PTE_W);
f01042cf:	e8 10 1e 00 00       	call   f01060e4 <cpunum>
f01042d4:	6a 03                	push   $0x3
f01042d6:	6a 34                	push   $0x34
f01042d8:	57                   	push   %edi
f01042d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01042dc:	ff b0 28 d0 2f f0    	push   -0xfd02fd8(%eax)
f01042e2:	e8 0c ed ff ff       	call   f0102ff3 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f01042e7:	89 fa                	mov    %edi,%edx
f01042e9:	89 37                	mov    %esi,(%edi)
		utf->utf_err      = tf->tf_trapno;
f01042eb:	8b 43 28             	mov    0x28(%ebx),%eax
f01042ee:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs     = tf->tf_regs;
f01042f1:	8d 7f 08             	lea    0x8(%edi),%edi
f01042f4:	b9 08 00 00 00       	mov    $0x8,%ecx
f01042f9:	89 de                	mov    %ebx,%esi
f01042fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eflags   = tf->tf_eflags;
f01042fd:	8b 43 38             	mov    0x38(%ebx),%eax
f0104300:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_eip      = tf->tf_eip;
f0104303:	8b 43 30             	mov    0x30(%ebx),%eax
f0104306:	89 d7                	mov    %edx,%edi
f0104308:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_esp      = tf->tf_esp;
f010430b:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010430e:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uint32_t) curenv->env_pgfault_upcall;
f0104311:	e8 ce 1d 00 00       	call   f01060e4 <cpunum>
f0104316:	6b c0 74             	imul   $0x74,%eax,%eax
f0104319:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f010431f:	8b 58 74             	mov    0x74(%eax),%ebx
f0104322:	e8 bd 1d 00 00       	call   f01060e4 <cpunum>
f0104327:	6b c0 74             	imul   $0x74,%eax,%eax
f010432a:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104330:	89 58 40             	mov    %ebx,0x40(%eax)
		curenv->env_tf.tf_esp        = (uint32_t) utf;
f0104333:	e8 ac 1d 00 00       	call   f01060e4 <cpunum>
f0104338:	6b c0 74             	imul   $0x74,%eax,%eax
f010433b:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104341:	89 78 4c             	mov    %edi,0x4c(%eax)
		env_run(curenv);
f0104344:	e8 9b 1d 00 00       	call   f01060e4 <cpunum>
f0104349:	83 c4 04             	add    $0x4,%esp
f010434c:	6b c0 74             	imul   $0x74,%eax,%eax
f010434f:	ff b0 28 d0 2f f0    	push   -0xfd02fd8(%eax)
f0104355:	e8 b8 f4 ff ff       	call   f0103812 <env_run>

f010435a <trap>:
{
f010435a:	55                   	push   %ebp
f010435b:	89 e5                	mov    %esp,%ebp
f010435d:	57                   	push   %edi
f010435e:	56                   	push   %esi
f010435f:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0104362:	fc                   	cld    
	if (panicstr)
f0104363:	83 3d 00 c0 2b f0 00 	cmpl   $0x0,0xf02bc000
f010436a:	74 01                	je     f010436d <trap+0x13>
		asm volatile("hlt");
f010436c:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010436d:	e8 72 1d 00 00       	call   f01060e4 <cpunum>
f0104372:	6b d0 74             	imul   $0x74,%eax,%edx
f0104375:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104378:	b8 01 00 00 00       	mov    $0x1,%eax
f010437d:	f0 87 82 20 d0 2f f0 	lock xchg %eax,-0xfd02fe0(%edx)
f0104384:	83 f8 02             	cmp    $0x2,%eax
f0104387:	74 30                	je     f01043b9 <trap+0x5f>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104389:	9c                   	pushf  
f010438a:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f010438b:	f6 c4 02             	test   $0x2,%ah
f010438e:	75 3b                	jne    f01043cb <trap+0x71>
	if ((tf->tf_cs & 3) == 3) {
f0104390:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104394:	83 e0 03             	and    $0x3,%eax
f0104397:	66 83 f8 03          	cmp    $0x3,%ax
f010439b:	74 47                	je     f01043e4 <trap+0x8a>
	last_tf = tf;
f010439d:	89 35 80 ca 2b f0    	mov    %esi,0xf02bca80
	switch(tf->tf_trapno) 
f01043a3:	8b 46 28             	mov    0x28(%esi),%eax
f01043a6:	83 e8 03             	sub    $0x3,%eax
f01043a9:	83 f8 2d             	cmp    $0x2d,%eax
f01043ac:	0f 87 33 02 00 00    	ja     f01045e5 <trap+0x28b>
f01043b2:	ff 24 85 40 87 10 f0 	jmp    *-0xfef78c0(,%eax,4)
	spin_lock(&kernel_lock);
f01043b9:	83 ec 0c             	sub    $0xc,%esp
f01043bc:	68 c0 93 12 f0       	push   $0xf01293c0
f01043c1:	e8 8e 1f 00 00       	call   f0106354 <spin_lock>
}
f01043c6:	83 c4 10             	add    $0x10,%esp
f01043c9:	eb be                	jmp    f0104389 <trap+0x2f>
	assert(!(read_eflags() & FL_IF));
f01043cb:	68 d2 84 10 f0       	push   $0xf01084d2
f01043d0:	68 55 75 10 f0       	push   $0xf0107555
f01043d5:	68 61 01 00 00       	push   $0x161
f01043da:	68 c6 84 10 f0       	push   $0xf01084c6
f01043df:	e8 5c bc ff ff       	call   f0100040 <_panic>
	spin_lock(&kernel_lock);
f01043e4:	83 ec 0c             	sub    $0xc,%esp
f01043e7:	68 c0 93 12 f0       	push   $0xf01293c0
f01043ec:	e8 63 1f 00 00       	call   f0106354 <spin_lock>
		assert(curenv);
f01043f1:	e8 ee 1c 00 00       	call   f01060e4 <cpunum>
f01043f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01043f9:	83 c4 10             	add    $0x10,%esp
f01043fc:	83 b8 28 d0 2f f0 00 	cmpl   $0x0,-0xfd02fd8(%eax)
f0104403:	74 42                	je     f0104447 <trap+0xed>
		if (curenv->env_status == ENV_DYING) {
f0104405:	e8 da 1c 00 00       	call   f01060e4 <cpunum>
f010440a:	6b c0 74             	imul   $0x74,%eax,%eax
f010440d:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104413:	83 78 64 01          	cmpl   $0x1,0x64(%eax)
f0104417:	74 47                	je     f0104460 <trap+0x106>
		curenv->env_tf = *tf;
f0104419:	e8 c6 1c 00 00       	call   f01060e4 <cpunum>
f010441e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104421:	8b b8 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%edi
f0104427:	83 c7 10             	add    $0x10,%edi
f010442a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010442f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104431:	e8 ae 1c 00 00       	call   f01060e4 <cpunum>
f0104436:	6b c0 74             	imul   $0x74,%eax,%eax
f0104439:	8b b0 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%esi
f010443f:	83 c6 10             	add    $0x10,%esi
f0104442:	e9 56 ff ff ff       	jmp    f010439d <trap+0x43>
		assert(curenv);
f0104447:	68 eb 84 10 f0       	push   $0xf01084eb
f010444c:	68 55 75 10 f0       	push   $0xf0107555
f0104451:	68 6a 01 00 00       	push   $0x16a
f0104456:	68 c6 84 10 f0       	push   $0xf01084c6
f010445b:	e8 e0 bb ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f0104460:	e8 7f 1c 00 00       	call   f01060e4 <cpunum>
f0104465:	83 ec 0c             	sub    $0xc,%esp
f0104468:	6b c0 74             	imul   $0x74,%eax,%eax
f010446b:	ff b0 28 d0 2f f0    	push   -0xfd02fd8(%eax)
f0104471:	e8 a5 f0 ff ff       	call   f010351b <env_free>
			curenv = NULL;
f0104476:	e8 69 1c 00 00       	call   f01060e4 <cpunum>
f010447b:	6b c0 74             	imul   $0x74,%eax,%eax
f010447e:	c7 80 28 d0 2f f0 00 	movl   $0x0,-0xfd02fd8(%eax)
f0104485:	00 00 00 
			sched_yield();
f0104488:	e8 21 03 00 00       	call   f01047ae <sched_yield>
			page_fault_handler(tf);
f010448d:	83 ec 0c             	sub    $0xc,%esp
f0104490:	56                   	push   %esi
f0104491:	e8 97 fd ff ff       	call   f010422d <page_fault_handler>
			break; 
f0104496:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104499:	e8 46 1c 00 00       	call   f01060e4 <cpunum>
f010449e:	6b c0 74             	imul   $0x74,%eax,%eax
f01044a1:	83 b8 28 d0 2f f0 00 	cmpl   $0x0,-0xfd02fd8(%eax)
f01044a8:	74 18                	je     f01044c2 <trap+0x168>
f01044aa:	e8 35 1c 00 00       	call   f01060e4 <cpunum>
f01044af:	6b c0 74             	imul   $0x74,%eax,%eax
f01044b2:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f01044b8:	83 78 64 03          	cmpl   $0x3,0x64(%eax)
f01044bc:	0f 84 6b 01 00 00    	je     f010462d <trap+0x2d3>
		sched_yield();
f01044c2:	e8 e7 02 00 00       	call   f01047ae <sched_yield>
			monitor(tf);
f01044c7:	83 ec 0c             	sub    $0xc,%esp
f01044ca:	56                   	push   %esi
f01044cb:	e8 9f c4 ff ff       	call   f010096f <monitor>
			break;
f01044d0:	83 c4 10             	add    $0x10,%esp
f01044d3:	eb c4                	jmp    f0104499 <trap+0x13f>
			int32_t ret=syscall(tf->tf_regs.reg_eax, /*lab的文档中说应用程序将在寄存器中传递系统调用编号和系统调用参数。这样，内核就不需要遍历用户环境的栈或指令流。系统调用编号将进入%eax。但是在哪里实现的? 我也不清楚 在 lib/syscall.c中实现的！！！*/
f01044d5:	83 ec 08             	sub    $0x8,%esp
f01044d8:	ff 76 04             	push   0x4(%esi)
f01044db:	ff 36                	push   (%esi)
f01044dd:	ff 76 10             	push   0x10(%esi)
f01044e0:	ff 76 18             	push   0x18(%esi)
f01044e3:	ff 76 14             	push   0x14(%esi)
f01044e6:	ff 76 1c             	push   0x1c(%esi)
f01044e9:	e8 c1 03 00 00       	call   f01048af <syscall>
			tf->tf_regs.reg_eax = ret;//将返回值传递回%eax，其将被传递回用户进程
f01044ee:	89 46 1c             	mov    %eax,0x1c(%esi)
			break;
f01044f1:	83 c4 20             	add    $0x20,%esp
f01044f4:	eb a3                	jmp    f0104499 <trap+0x13f>
			cprintf("Spurious interrupt on irq 7\n");
f01044f6:	83 ec 0c             	sub    $0xc,%esp
f01044f9:	68 f2 84 10 f0       	push   $0xf01084f2
f01044fe:	e8 ce f5 ff ff       	call   f0103ad1 <cprintf>
			print_trapframe(tf);
f0104503:	89 34 24             	mov    %esi,(%esp)
f0104506:	e8 86 fb ff ff       	call   f0104091 <print_trapframe>
			break;
f010450b:	83 c4 10             	add    $0x10,%esp
f010450e:	eb 89                	jmp    f0104499 <trap+0x13f>
			cprintf("Timer Interupt comes, new time slice\n");
f0104510:	83 ec 0c             	sub    $0xc,%esp
f0104513:	68 c0 86 10 f0       	push   $0xf01086c0
f0104518:	e8 b4 f5 ff ff       	call   f0103ad1 <cprintf>
			lapic_eoi();
f010451d:	e8 09 1d 00 00       	call   f010622b <lapic_eoi>
			time_tick();
f0104522:	e8 0d 28 00 00       	call   f0106d34 <time_tick>
			(curenv->env_mfq_time_slices)--;//当前环境运行了一个时间片，先减一
f0104527:	e8 b8 1b 00 00       	call   f01060e4 <cpunum>
f010452c:	6b c0 74             	imul   $0x74,%eax,%eax
f010452f:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104535:	83 68 0c 01          	subl   $0x1,0xc(%eax)
			for(int i=0;i<curenv->env_mfq_level;i++){//如果优先级更高的队列有任务了，让出cpu
f0104539:	83 c4 10             	add    $0x10,%esp
f010453c:	be 00 00 00 00       	mov    $0x0,%esi
f0104541:	e8 9e 1b 00 00       	call   f01060e4 <cpunum>
f0104546:	6b c0 74             	imul   $0x74,%eax,%eax
f0104549:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f010454f:	3b 70 08             	cmp    0x8(%eax),%esi
f0104552:	7d 23                	jge    f0104577 <trap+0x21d>
				if(!queue_empty(&mfqs[i])){
f0104554:	a1 70 c2 2b f0       	mov    0xf02bc270,%eax
f0104559:	8d 04 f0             	lea    (%eax,%esi,8),%eax
f010455c:	3b 00                	cmp    (%eax),%eax
f010455e:	75 05                	jne    f0104565 <trap+0x20b>
			for(int i=0;i<curenv->env_mfq_level;i++){//如果优先级更高的队列有任务了，让出cpu
f0104560:	83 c6 01             	add    $0x1,%esi
f0104563:	eb dc                	jmp    f0104541 <trap+0x1e7>
					cprintf("there is higher level environment：  ");
f0104565:	83 ec 0c             	sub    $0xc,%esp
f0104568:	68 e8 86 10 f0       	push   $0xf01086e8
f010456d:	e8 5f f5 ff ff       	call   f0103ad1 <cprintf>
					sched_yield();
f0104572:	e8 37 02 00 00       	call   f01047ae <sched_yield>
			if (curenv && (curenv->env_mfq_time_slices == 0) ) {//这个环境时间片走完
f0104577:	e8 68 1b 00 00       	call   f01060e4 <cpunum>
f010457c:	6b c0 74             	imul   $0x74,%eax,%eax
f010457f:	83 b8 28 d0 2f f0 00 	cmpl   $0x0,-0xfd02fd8(%eax)
f0104586:	0f 84 0d ff ff ff    	je     f0104499 <trap+0x13f>
f010458c:	e8 53 1b 00 00       	call   f01060e4 <cpunum>
f0104591:	6b c0 74             	imul   $0x74,%eax,%eax
f0104594:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f010459a:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
f010459e:	0f 85 f5 fe ff ff    	jne    f0104499 <trap+0x13f>
				cprintf("environment %08x time slice exhausts：  ",curenv->env_id);
f01045a4:	e8 3b 1b 00 00       	call   f01060e4 <cpunum>
f01045a9:	83 ec 08             	sub    $0x8,%esp
f01045ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01045af:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f01045b5:	ff 70 58             	push   0x58(%eax)
f01045b8:	68 10 87 10 f0       	push   $0xf0108710
f01045bd:	e8 0f f5 ff ff       	call   f0103ad1 <cprintf>
				sched_yield();
f01045c2:	e8 e7 01 00 00       	call   f01047ae <sched_yield>
			lapic_eoi();
f01045c7:	e8 5f 1c 00 00       	call   f010622b <lapic_eoi>
			kbd_intr();
f01045cc:	e8 16 c0 ff ff       	call   f01005e7 <kbd_intr>
			break;
f01045d1:	e9 c3 fe ff ff       	jmp    f0104499 <trap+0x13f>
			lapic_eoi();
f01045d6:	e8 50 1c 00 00       	call   f010622b <lapic_eoi>
			serial_intr();
f01045db:	e8 eb bf ff ff       	call   f01005cb <serial_intr>
			break;
f01045e0:	e9 b4 fe ff ff       	jmp    f0104499 <trap+0x13f>
			print_trapframe(tf);
f01045e5:	83 ec 0c             	sub    $0xc,%esp
f01045e8:	56                   	push   %esi
f01045e9:	e8 a3 fa ff ff       	call   f0104091 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f01045ee:	83 c4 10             	add    $0x10,%esp
f01045f1:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01045f6:	74 1e                	je     f0104616 <trap+0x2bc>
				env_destroy(curenv);
f01045f8:	e8 e7 1a 00 00       	call   f01060e4 <cpunum>
f01045fd:	83 ec 0c             	sub    $0xc,%esp
f0104600:	6b c0 74             	imul   $0x74,%eax,%eax
f0104603:	ff b0 28 d0 2f f0    	push   -0xfd02fd8(%eax)
f0104609:	e8 cc f0 ff ff       	call   f01036da <env_destroy>
				return;
f010460e:	83 c4 10             	add    $0x10,%esp
f0104611:	e9 83 fe ff ff       	jmp    f0104499 <trap+0x13f>
				panic("unhandled trap in kernel");
f0104616:	83 ec 04             	sub    $0x4,%esp
f0104619:	68 0f 85 10 f0       	push   $0xf010850f
f010461e:	68 42 01 00 00       	push   $0x142
f0104623:	68 c6 84 10 f0       	push   $0xf01084c6
f0104628:	e8 13 ba ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f010462d:	e8 b2 1a 00 00       	call   f01060e4 <cpunum>
f0104632:	83 ec 0c             	sub    $0xc,%esp
f0104635:	6b c0 74             	imul   $0x74,%eax,%eax
f0104638:	ff b0 28 d0 2f f0    	push   -0xfd02fd8(%eax)
f010463e:	e8 cf f1 ff ff       	call   f0103812 <env_run>
f0104643:	90                   	nop

f0104644 <DIVIDE_HANDLER>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 //参见练习3中的 9.1 、9.10中的表，以及inc/trap.h 来完成这一部分。
TRAPHANDLER_NOEC(DIVIDE_HANDLER, T_DIVIDE);
f0104644:	6a 00                	push   $0x0
f0104646:	6a 00                	push   $0x0
f0104648:	e9 83 00 00 00       	jmp    f01046d0 <_alltraps>
f010464d:	90                   	nop

f010464e <DEBUG_HANDLER>:
TRAPHANDLER_NOEC(DEBUG_HANDLER, T_DEBUG);
f010464e:	6a 00                	push   $0x0
f0104650:	6a 01                	push   $0x1
f0104652:	eb 7c                	jmp    f01046d0 <_alltraps>

f0104654 <NMI_HANDLER>:
TRAPHANDLER_NOEC(NMI_HANDLER, T_NMI);
f0104654:	6a 00                	push   $0x0
f0104656:	6a 02                	push   $0x2
f0104658:	eb 76                	jmp    f01046d0 <_alltraps>

f010465a <BRKPT_HANDLER>:
TRAPHANDLER_NOEC(BRKPT_HANDLER, T_BRKPT);
f010465a:	6a 00                	push   $0x0
f010465c:	6a 03                	push   $0x3
f010465e:	eb 70                	jmp    f01046d0 <_alltraps>

f0104660 <OFLOW_HANDLER>:
TRAPHANDLER_NOEC(OFLOW_HANDLER, T_OFLOW);
f0104660:	6a 00                	push   $0x0
f0104662:	6a 04                	push   $0x4
f0104664:	eb 6a                	jmp    f01046d0 <_alltraps>

f0104666 <BOUND_HANDLER>:
TRAPHANDLER_NOEC(BOUND_HANDLER, T_BOUND);
f0104666:	6a 00                	push   $0x0
f0104668:	6a 05                	push   $0x5
f010466a:	eb 64                	jmp    f01046d0 <_alltraps>

f010466c <ILLOP_HANDLER>:
TRAPHANDLER_NOEC(ILLOP_HANDLER, T_ILLOP);
f010466c:	6a 00                	push   $0x0
f010466e:	6a 06                	push   $0x6
f0104670:	eb 5e                	jmp    f01046d0 <_alltraps>

f0104672 <DEVICE_HANDLER>:
TRAPHANDLER_NOEC(DEVICE_HANDLER, T_DEVICE);
f0104672:	6a 00                	push   $0x0
f0104674:	6a 07                	push   $0x7
f0104676:	eb 58                	jmp    f01046d0 <_alltraps>

f0104678 <DBLFLT_HANDLER>:
TRAPHANDLER(DBLFLT_HANDLER, T_DBLFLT);
f0104678:	6a 08                	push   $0x8
f010467a:	eb 54                	jmp    f01046d0 <_alltraps>

f010467c <TSS_HANDLER>:
/* reserved */
TRAPHANDLER(TSS_HANDLER, T_TSS);
f010467c:	6a 0a                	push   $0xa
f010467e:	eb 50                	jmp    f01046d0 <_alltraps>

f0104680 <SEGNP_HANDLER>:
TRAPHANDLER(SEGNP_HANDLER, T_SEGNP);
f0104680:	6a 0b                	push   $0xb
f0104682:	eb 4c                	jmp    f01046d0 <_alltraps>

f0104684 <STACK_HANDLER>:
TRAPHANDLER(STACK_HANDLER, T_STACK);
f0104684:	6a 0c                	push   $0xc
f0104686:	eb 48                	jmp    f01046d0 <_alltraps>

f0104688 <GPFLT_HANDLER>:
TRAPHANDLER(GPFLT_HANDLER, T_GPFLT);
f0104688:	6a 0d                	push   $0xd
f010468a:	eb 44                	jmp    f01046d0 <_alltraps>

f010468c <PGFLT_HANDLER>:
TRAPHANDLER(PGFLT_HANDLER, T_PGFLT);
f010468c:	6a 0e                	push   $0xe
f010468e:	eb 40                	jmp    f01046d0 <_alltraps>

f0104690 <FPERR_HANDLER>:
/* reserved */
TRAPHANDLER_NOEC(FPERR_HANDLER, T_FPERR);
f0104690:	6a 00                	push   $0x0
f0104692:	6a 10                	push   $0x10
f0104694:	eb 3a                	jmp    f01046d0 <_alltraps>

f0104696 <ALIGN_HANDLER>:
TRAPHANDLER(ALIGN_HANDLER, T_ALIGN);
f0104696:	6a 11                	push   $0x11
f0104698:	eb 36                	jmp    f01046d0 <_alltraps>

f010469a <MCHK_HANDLER>:
TRAPHANDLER_NOEC(MCHK_HANDLER, T_MCHK);
f010469a:	6a 00                	push   $0x0
f010469c:	6a 12                	push   $0x12
f010469e:	eb 30                	jmp    f01046d0 <_alltraps>

f01046a0 <SIMDERR_HANDLER>:
TRAPHANDLER_NOEC(SIMDERR_HANDLER, T_SIMDERR);
f01046a0:	6a 00                	push   $0x0
f01046a2:	6a 13                	push   $0x13
f01046a4:	eb 2a                	jmp    f01046d0 <_alltraps>

f01046a6 <SYSCALL_HANDLER>:

//exercise 7 syscall
TRAPHANDLER_NOEC(SYSCALL_HANDLER, T_SYSCALL);
f01046a6:	6a 00                	push   $0x0
f01046a8:	6a 30                	push   $0x30
f01046aa:	eb 24                	jmp    f01046d0 <_alltraps>

f01046ac <timer_handler>:

//lab4 exercise 13
//IRQS 
TRAPHANDLER_NOEC(timer_handler, IRQ_OFFSET + IRQ_TIMER);
f01046ac:	6a 00                	push   $0x0
f01046ae:	6a 20                	push   $0x20
f01046b0:	eb 1e                	jmp    f01046d0 <_alltraps>

f01046b2 <kbd_handler>:
TRAPHANDLER_NOEC(kbd_handler, IRQ_OFFSET + IRQ_KBD);
f01046b2:	6a 00                	push   $0x0
f01046b4:	6a 21                	push   $0x21
f01046b6:	eb 18                	jmp    f01046d0 <_alltraps>

f01046b8 <serial_handler>:
TRAPHANDLER_NOEC(serial_handler, IRQ_OFFSET + IRQ_SERIAL);
f01046b8:	6a 00                	push   $0x0
f01046ba:	6a 24                	push   $0x24
f01046bc:	eb 12                	jmp    f01046d0 <_alltraps>

f01046be <spurious_handler>:
TRAPHANDLER_NOEC(spurious_handler, IRQ_OFFSET + IRQ_SPURIOUS);
f01046be:	6a 00                	push   $0x0
f01046c0:	6a 27                	push   $0x27
f01046c2:	eb 0c                	jmp    f01046d0 <_alltraps>

f01046c4 <ide_handler>:
TRAPHANDLER_NOEC(ide_handler, IRQ_OFFSET + IRQ_IDE);
f01046c4:	6a 00                	push   $0x0
f01046c6:	6a 2e                	push   $0x2e
f01046c8:	eb 06                	jmp    f01046d0 <_alltraps>

f01046ca <error_handler>:
TRAPHANDLER_NOEC(error_handler, IRQ_OFFSET + IRQ_ERROR);
f01046ca:	6a 00                	push   $0x0
f01046cc:	6a 33                	push   $0x33
f01046ce:	eb 00                	jmp    f01046d0 <_alltraps>

f01046d0 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
 	//别忘了栈由高地址向低地址生长，于是Trapframe顺序变为tf_trapno（上面两个宏已经把num压栈了），ds，es，PushRegs的反向
	pushl %ds
f01046d0:	1e                   	push   %ds
	pushl %es
f01046d1:	06                   	push   %es
	pushal
f01046d2:	60                   	pusha  
	//
	movw $GD_KD, %ax 
f01046d3:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f01046d7:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f01046d9:	8e c0                	mov    %eax,%es
	movw GD_KD, %ds
	movw GD_KD, %es
	*/
	
	//这是作为trap(struct Trapframe *tf)的参数的
	pushl %esp
f01046db:	54                   	push   %esp
	//调用trap
	call trap
f01046dc:	e8 79 fc ff ff       	call   f010435a <trap>

f01046e1 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01046e1:	55                   	push   %ebp
f01046e2:	89 e5                	mov    %esp,%ebp
f01046e4:	83 ec 08             	sub    $0x8,%esp
f01046e7:	a1 74 c2 2b f0       	mov    0xf02bc274,%eax
f01046ec:	8d 50 64             	lea    0x64(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01046ef:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01046f4:	8b 02                	mov    (%edx),%eax
f01046f6:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01046f9:	83 f8 02             	cmp    $0x2,%eax
f01046fc:	76 30                	jbe    f010472e <sched_halt+0x4d>
	for (i = 0; i < NENV; i++) {
f01046fe:	83 c1 01             	add    $0x1,%ecx
f0104701:	81 c2 8c 00 00 00    	add    $0x8c,%edx
f0104707:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010470d:	75 e5                	jne    f01046f4 <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f010470f:	83 ec 0c             	sub    $0xc,%esp
f0104712:	68 50 88 10 f0       	push   $0xf0108850
f0104717:	e8 b5 f3 ff ff       	call   f0103ad1 <cprintf>
f010471c:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010471f:	83 ec 0c             	sub    $0xc,%esp
f0104722:	6a 00                	push   $0x0
f0104724:	e8 46 c2 ff ff       	call   f010096f <monitor>
f0104729:	83 c4 10             	add    $0x10,%esp
f010472c:	eb f1                	jmp    f010471f <sched_halt+0x3e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010472e:	e8 b1 19 00 00       	call   f01060e4 <cpunum>
f0104733:	6b c0 74             	imul   $0x74,%eax,%eax
f0104736:	c7 80 28 d0 2f f0 00 	movl   $0x0,-0xfd02fd8(%eax)
f010473d:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104740:	a1 5c c2 2b f0       	mov    0xf02bc25c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104745:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010474a:	76 50                	jbe    f010479c <sched_halt+0xbb>
	return (physaddr_t)kva - KERNBASE;
f010474c:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f0104751:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104754:	e8 8b 19 00 00       	call   f01060e4 <cpunum>
f0104759:	6b d0 74             	imul   $0x74,%eax,%edx
f010475c:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f010475f:	b8 02 00 00 00       	mov    $0x2,%eax
f0104764:	f0 87 82 20 d0 2f f0 	lock xchg %eax,-0xfd02fe0(%edx)
	spin_unlock(&kernel_lock);
f010476b:	83 ec 0c             	sub    $0xc,%esp
f010476e:	68 c0 93 12 f0       	push   $0xf01293c0
f0104773:	e8 76 1c 00 00       	call   f01063ee <spin_unlock>
	asm volatile("pause");
f0104778:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010477a:	e8 65 19 00 00       	call   f01060e4 <cpunum>
f010477f:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f0104782:	8b 80 30 d0 2f f0    	mov    -0xfd02fd0(%eax),%eax
f0104788:	bd 00 00 00 00       	mov    $0x0,%ebp
f010478d:	89 c4                	mov    %eax,%esp
f010478f:	6a 00                	push   $0x0
f0104791:	6a 00                	push   $0x0
f0104793:	fb                   	sti    
f0104794:	f4                   	hlt    
f0104795:	eb fd                	jmp    f0104794 <sched_halt+0xb3>
}
f0104797:	83 c4 10             	add    $0x10,%esp
f010479a:	c9                   	leave  
f010479b:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010479c:	50                   	push   %eax
f010479d:	68 08 70 10 f0       	push   $0xf0107008
f01047a2:	6a 64                	push   $0x64
f01047a4:	68 c1 88 10 f0       	push   $0xf01088c1
f01047a9:	e8 92 b8 ff ff       	call   f0100040 <_panic>

f01047ae <sched_yield>:
{
f01047ae:	55                   	push   %ebp
f01047af:	89 e5                	mov    %esp,%ebp
f01047b1:	53                   	push   %ebx
f01047b2:	83 ec 04             	sub    $0x4,%esp
	if(curenv && curenv->env_status == ENV_RUNNING) findscope=curenv->env_mfq_level;
f01047b5:	e8 2a 19 00 00       	call   f01060e4 <cpunum>
f01047ba:	6b c0 74             	imul   $0x74,%eax,%eax
	else findscope=NMFQ-1;
f01047bd:	b9 04 00 00 00       	mov    $0x4,%ecx
	if(curenv && curenv->env_status == ENV_RUNNING) findscope=curenv->env_mfq_level;
f01047c2:	83 b8 28 d0 2f f0 00 	cmpl   $0x0,-0xfd02fd8(%eax)
f01047c9:	74 19                	je     f01047e4 <sched_yield+0x36>
f01047cb:	e8 14 19 00 00       	call   f01060e4 <cpunum>
f01047d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01047d3:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
	else findscope=NMFQ-1;
f01047d9:	b9 04 00 00 00       	mov    $0x4,%ecx
	if(curenv && curenv->env_status == ENV_RUNNING) findscope=curenv->env_mfq_level;
f01047de:	83 78 64 03          	cmpl   $0x3,0x64(%eax)
f01047e2:	74 1e                	je     f0104802 <sched_yield+0x54>
f01047e4:	a1 70 c2 2b f0       	mov    0xf02bc270,%eax
	for (int i = 0; i <= findscope; i++) {//只在队列中找优先级高于或等于当前运行环境的环境
f01047e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01047ee:	39 d1                	cmp    %edx,%ecx
f01047f0:	0f 8c 8a 00 00 00    	jl     f0104880 <sched_yield+0xd2>
		if (!queue_empty(&mfqs[i])) {
f01047f6:	3b 00                	cmp    (%eax),%eax
f01047f8:	75 1b                	jne    f0104815 <sched_yield+0x67>
	for (int i = 0; i <= findscope; i++) {//只在队列中找优先级高于或等于当前运行环境的环境
f01047fa:	83 c2 01             	add    $0x1,%edx
f01047fd:	83 c0 08             	add    $0x8,%eax
f0104800:	eb ec                	jmp    f01047ee <sched_yield+0x40>
	if(curenv && curenv->env_status == ENV_RUNNING) findscope=curenv->env_mfq_level;
f0104802:	e8 dd 18 00 00       	call   f01060e4 <cpunum>
f0104807:	6b c0 74             	imul   $0x74,%eax,%eax
f010480a:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104810:	8b 48 08             	mov    0x8(%eax),%ecx
f0104813:	eb cf                	jmp    f01047e4 <sched_yield+0x36>
    return que->next;
f0104815:	8b 58 04             	mov    0x4(%eax),%ebx
			assert(idle->env_status == ENV_RUNNABLE);
f0104818:	83 7b 64 02          	cmpl   $0x2,0x64(%ebx)
f010481c:	75 18                	jne    f0104836 <sched_yield+0x88>
		cprintf("New running environment is %08x\n",idle->env_id);
f010481e:	83 ec 08             	sub    $0x8,%esp
f0104821:	ff 73 58             	push   0x58(%ebx)
f0104824:	68 a0 88 10 f0       	push   $0xf01088a0
f0104829:	e8 a3 f2 ff ff       	call   f0103ad1 <cprintf>
		env_run(idle);
f010482e:	89 1c 24             	mov    %ebx,(%esp)
f0104831:	e8 dc ef ff ff       	call   f0103812 <env_run>
			assert(idle->env_status == ENV_RUNNABLE);
f0104836:	68 7c 88 10 f0       	push   $0xf010887c
f010483b:	68 55 75 10 f0       	push   $0xf0107555
f0104840:	6a 2a                	push   $0x2a
f0104842:	68 c1 88 10 f0       	push   $0xf01088c1
f0104847:	e8 f4 b7 ff ff       	call   f0100040 <_panic>
		cprintf("still runs environment %08x\n",curenv->env_id);
f010484c:	e8 93 18 00 00       	call   f01060e4 <cpunum>
f0104851:	83 ec 08             	sub    $0x8,%esp
f0104854:	6b c0 74             	imul   $0x74,%eax,%eax
f0104857:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f010485d:	ff 70 58             	push   0x58(%eax)
f0104860:	68 ce 88 10 f0       	push   $0xf01088ce
f0104865:	e8 67 f2 ff ff       	call   f0103ad1 <cprintf>
		env_run(curenv);
f010486a:	e8 75 18 00 00       	call   f01060e4 <cpunum>
f010486f:	83 c4 04             	add    $0x4,%esp
f0104872:	6b c0 74             	imul   $0x74,%eax,%eax
f0104875:	ff b0 28 d0 2f f0    	push   -0xfd02fd8(%eax)
f010487b:	e8 92 ef ff ff       	call   f0103812 <env_run>
	} else if (curenv && curenv->env_status == ENV_RUNNING) {
f0104880:	e8 5f 18 00 00       	call   f01060e4 <cpunum>
f0104885:	6b c0 74             	imul   $0x74,%eax,%eax
f0104888:	83 b8 28 d0 2f f0 00 	cmpl   $0x0,-0xfd02fd8(%eax)
f010488f:	74 14                	je     f01048a5 <sched_yield+0xf7>
f0104891:	e8 4e 18 00 00       	call   f01060e4 <cpunum>
f0104896:	6b c0 74             	imul   $0x74,%eax,%eax
f0104899:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f010489f:	83 78 64 03          	cmpl   $0x3,0x64(%eax)
f01048a3:	74 a7                	je     f010484c <sched_yield+0x9e>
	sched_halt();
f01048a5:	e8 37 fe ff ff       	call   f01046e1 <sched_halt>
}
f01048aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01048ad:	c9                   	leave  
f01048ae:	c3                   	ret    

f01048af <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01048af:	55                   	push   %ebp
f01048b0:	89 e5                	mov    %esp,%ebp
f01048b2:	57                   	push   %edi
f01048b3:	56                   	push   %esi
f01048b4:	53                   	push   %ebx
f01048b5:	83 ec 1c             	sub    $0x1c,%esp
f01048b8:	8b 45 08             	mov    0x8(%ebp),%eax
	// LAB 3: Your code here.

	// panic("syscall not implemented");
	
	//依据不同的syscallno， 调用lib/system.c中的不同函数
	switch (syscallno) 
f01048bb:	83 f8 10             	cmp    $0x10,%eax
f01048be:	0f 87 59 06 00 00    	ja     f0104f1d <syscall+0x66e>
f01048c4:	ff 24 85 f0 88 10 f0 	jmp    *-0xfef7710(,%eax,4)
	user_mem_assert(curenv, s, len, 0);
f01048cb:	e8 14 18 00 00       	call   f01060e4 <cpunum>
f01048d0:	6a 00                	push   $0x0
f01048d2:	ff 75 10             	push   0x10(%ebp)
f01048d5:	ff 75 0c             	push   0xc(%ebp)
f01048d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01048db:	ff b0 28 d0 2f f0    	push   -0xfd02fd8(%eax)
f01048e1:	e8 0d e7 ff ff       	call   f0102ff3 <user_mem_assert>
	cprintf("%.*s", len, s);
f01048e6:	83 c4 0c             	add    $0xc,%esp
f01048e9:	ff 75 0c             	push   0xc(%ebp)
f01048ec:	ff 75 10             	push   0x10(%ebp)
f01048ef:	68 eb 88 10 f0       	push   $0xf01088eb
f01048f4:	e8 d8 f1 ff ff       	call   f0103ad1 <cprintf>
}
f01048f9:	83 c4 10             	add    $0x10,%esp
	{
		case SYS_cputs:
			sys_cputs( (const char *) a1, a2);
			return 0;
f01048fc:	bb 00 00 00 00       	mov    $0x0,%ebx
			
		default:
			return -E_INVAL;
	}
	return 0;
}
f0104901:	89 d8                	mov    %ebx,%eax
f0104903:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104906:	5b                   	pop    %ebx
f0104907:	5e                   	pop    %esi
f0104908:	5f                   	pop    %edi
f0104909:	5d                   	pop    %ebp
f010490a:	c3                   	ret    
	return cons_getc();
f010490b:	e8 e9 bc ff ff       	call   f01005f9 <cons_getc>
f0104910:	89 c3                	mov    %eax,%ebx
			return sys_cgetc();
f0104912:	eb ed                	jmp    f0104901 <syscall+0x52>
	return curenv->env_id;
f0104914:	e8 cb 17 00 00       	call   f01060e4 <cpunum>
f0104919:	6b c0 74             	imul   $0x74,%eax,%eax
f010491c:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104922:	8b 58 58             	mov    0x58(%eax),%ebx
			return sys_getenvid();
f0104925:	eb da                	jmp    f0104901 <syscall+0x52>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104927:	83 ec 04             	sub    $0x4,%esp
f010492a:	6a 01                	push   $0x1
f010492c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010492f:	50                   	push   %eax
f0104930:	ff 75 0c             	push   0xc(%ebp)
f0104933:	e8 9f e7 ff ff       	call   f01030d7 <envid2env>
f0104938:	89 c3                	mov    %eax,%ebx
f010493a:	83 c4 10             	add    $0x10,%esp
f010493d:	85 c0                	test   %eax,%eax
f010493f:	78 c0                	js     f0104901 <syscall+0x52>
	env_destroy(e);
f0104941:	83 ec 0c             	sub    $0xc,%esp
f0104944:	ff 75 e4             	push   -0x1c(%ebp)
f0104947:	e8 8e ed ff ff       	call   f01036da <env_destroy>
	return 0;
f010494c:	83 c4 10             	add    $0x10,%esp
f010494f:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_env_destroy(a1);
f0104954:	eb ab                	jmp    f0104901 <syscall+0x52>
	sched_yield();
f0104956:	e8 53 fe ff ff       	call   f01047ae <sched_yield>
	struct Env *e=NULL;
f010495b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int error_ret=env_alloc( &e , curenv->env_id);
f0104962:	e8 7d 17 00 00       	call   f01060e4 <cpunum>
f0104967:	83 ec 08             	sub    $0x8,%esp
f010496a:	6b c0 74             	imul   $0x74,%eax,%eax
f010496d:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104973:	ff 70 58             	push   0x58(%eax)
f0104976:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104979:	50                   	push   %eax
f010497a:	e8 73 e8 ff ff       	call   f01031f2 <env_alloc>
f010497f:	89 c3                	mov    %eax,%ebx
	if(error_ret<0 ) return error_ret;
f0104981:	83 c4 10             	add    $0x10,%esp
f0104984:	85 c0                	test   %eax,%eax
f0104986:	0f 88 75 ff ff ff    	js     f0104901 <syscall+0x52>
	e->env_status = ENV_NOT_RUNNABLE;
f010498c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010498f:	c7 40 64 04 00 00 00 	movl   $0x4,0x64(%eax)
    ln->prev->next = ln->next;
f0104996:	8b 08                	mov    (%eax),%ecx
f0104998:	8b 50 04             	mov    0x4(%eax),%edx
f010499b:	89 51 04             	mov    %edx,0x4(%ecx)
    ln->next->prev = ln->prev;
f010499e:	8b 08                	mov    (%eax),%ecx
f01049a0:	89 0a                	mov    %ecx,(%edx)
    ln->prev = ln->next = ln;
f01049a2:	89 40 04             	mov    %eax,0x4(%eax)
f01049a5:	89 00                	mov    %eax,(%eax)
	e->env_tf = curenv->env_tf;
f01049a7:	e8 38 17 00 00       	call   f01060e4 <cpunum>
f01049ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01049af:	8b b0 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%esi
f01049b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049b8:	8d 78 10             	lea    0x10(%eax),%edi
f01049bb:	83 c6 10             	add    $0x10,%esi
f01049be:	b9 11 00 00 00       	mov    $0x11,%ecx
f01049c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f01049c5:	c7 40 2c 00 00 00 00 	movl   $0x0,0x2c(%eax)
	return e->env_id;	
f01049cc:	8b 58 58             	mov    0x58(%eax),%ebx
			return sys_exofork();
f01049cf:	e9 2d ff ff ff       	jmp    f0104901 <syscall+0x52>
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) return -E_INVAL;  
f01049d4:	8b 45 10             	mov    0x10(%ebp),%eax
f01049d7:	83 e8 02             	sub    $0x2,%eax
f01049da:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01049df:	75 40                	jne    f0104a21 <syscall+0x172>
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f01049e1:	83 ec 04             	sub    $0x4,%esp
f01049e4:	6a 01                	push   $0x1
f01049e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049e9:	50                   	push   %eax
f01049ea:	ff 75 0c             	push   0xc(%ebp)
f01049ed:	e8 e5 e6 ff ff       	call   f01030d7 <envid2env>
f01049f2:	83 c4 10             	add    $0x10,%esp
f01049f5:	85 c0                	test   %eax,%eax
f01049f7:	78 32                	js     f0104a2b <syscall+0x17c>
	e->env_status = status;
f01049f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049fc:	8b 7d 10             	mov    0x10(%ebp),%edi
f01049ff:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;	
f0104a02:	bb 00 00 00 00       	mov    $0x0,%ebx
	if(status==ENV_RUNNABLE){//如果将环境状态变为RUNNABLE，需要插入队列
f0104a07:	83 ff 02             	cmp    $0x2,%edi
f0104a0a:	0f 85 f1 fe ff ff    	jne    f0104901 <syscall+0x52>
		env_mfq_add(e);
f0104a10:	83 ec 0c             	sub    $0xc,%esp
f0104a13:	50                   	push   %eax
f0104a14:	e8 60 ed ff ff       	call   f0103779 <env_mfq_add>
f0104a19:	83 c4 10             	add    $0x10,%esp
f0104a1c:	e9 e0 fe ff ff       	jmp    f0104901 <syscall+0x52>
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) return -E_INVAL;  
f0104a21:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a26:	e9 d6 fe ff ff       	jmp    f0104901 <syscall+0x52>
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f0104a2b:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104a30:	e9 cc fe ff ff       	jmp    f0104901 <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f0104a35:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a38:	83 e0 05             	and    $0x5,%eax
f0104a3b:	83 f8 05             	cmp    $0x5,%eax
f0104a3e:	0f 85 86 00 00 00    	jne    f0104aca <syscall+0x21b>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f0104a44:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f0104a4b:	0f 85 83 00 00 00    	jne    f0104ad4 <syscall+0x225>
f0104a51:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104a58:	77 7a                	ja     f0104ad4 <syscall+0x225>
f0104a5a:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104a61:	75 7b                	jne    f0104ade <syscall+0x22f>
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f0104a63:	83 ec 0c             	sub    $0xc,%esp
f0104a66:	6a 01                	push   $0x1
f0104a68:	e8 da c4 ff ff       	call   f0100f47 <page_alloc>
f0104a6d:	89 c6                	mov    %eax,%esi
	if( pp==NULL ) return -E_NO_MEM;
f0104a6f:	83 c4 10             	add    $0x10,%esp
f0104a72:	85 c0                	test   %eax,%eax
f0104a74:	74 72                	je     f0104ae8 <syscall+0x239>
	int error_ret=envid2env(envid, &e, 1);
f0104a76:	83 ec 04             	sub    $0x4,%esp
f0104a79:	6a 01                	push   $0x1
f0104a7b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a7e:	50                   	push   %eax
f0104a7f:	ff 75 0c             	push   0xc(%ebp)
f0104a82:	e8 50 e6 ff ff       	call   f01030d7 <envid2env>
f0104a87:	89 c3                	mov    %eax,%ebx
	if( error_ret <0 ) return error_ret;//error_ret 其实就是我们调用函数发生错误时的返回值， 这不同函数之间都是一致的。
f0104a89:	83 c4 10             	add    $0x10,%esp
f0104a8c:	85 c0                	test   %eax,%eax
f0104a8e:	0f 88 6d fe ff ff    	js     f0104901 <syscall+0x52>
	error_ret=page_insert(e->env_pgdir, pp, va, perm);
f0104a94:	ff 75 14             	push   0x14(%ebp)
f0104a97:	ff 75 10             	push   0x10(%ebp)
f0104a9a:	56                   	push   %esi
f0104a9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a9e:	ff 70 70             	push   0x70(%eax)
f0104aa1:	e8 af c7 ff ff       	call   f0101255 <page_insert>
f0104aa6:	89 c3                	mov    %eax,%ebx
	if(error_ret <0){
f0104aa8:	83 c4 10             	add    $0x10,%esp
f0104aab:	85 c0                	test   %eax,%eax
f0104aad:	78 0a                	js     f0104ab9 <syscall+0x20a>
	return 0;		
f0104aaf:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_page_alloc(a1,(void *)a2, (int)a3);
f0104ab4:	e9 48 fe ff ff       	jmp    f0104901 <syscall+0x52>
		page_free(pp);
f0104ab9:	83 ec 0c             	sub    $0xc,%esp
f0104abc:	56                   	push   %esi
f0104abd:	e8 fa c4 ff ff       	call   f0100fbc <page_free>
		return error_ret;
f0104ac2:	83 c4 10             	add    $0x10,%esp
f0104ac5:	e9 37 fe ff ff       	jmp    f0104901 <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f0104aca:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104acf:	e9 2d fe ff ff       	jmp    f0104901 <syscall+0x52>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f0104ad4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ad9:	e9 23 fe ff ff       	jmp    f0104901 <syscall+0x52>
f0104ade:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ae3:	e9 19 fe ff ff       	jmp    f0104901 <syscall+0x52>
	if( pp==NULL ) return -E_NO_MEM;
f0104ae8:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104aed:	e9 0f fe ff ff       	jmp    f0104901 <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f0104af2:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104af5:	83 e0 05             	and    $0x5,%eax
f0104af8:	83 f8 05             	cmp    $0x5,%eax
f0104afb:	0f 85 c0 00 00 00    	jne    f0104bc1 <syscall+0x312>
	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
f0104b01:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104b08:	0f 85 bd 00 00 00    	jne    f0104bcb <syscall+0x31c>
f0104b0e:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104b15:	0f 87 b0 00 00 00    	ja     f0104bcb <syscall+0x31c>
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
f0104b1b:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104b22:	0f 87 ad 00 00 00    	ja     f0104bd5 <syscall+0x326>
f0104b28:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b2b:	0b 45 18             	or     0x18(%ebp),%eax
f0104b2e:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104b33:	0f 85 a6 00 00 00    	jne    f0104bdf <syscall+0x330>
	if (envid2env(srcenvid, &src_e, 1)<0 || envid2env(dstenvid, &dst_e, 1)<0) return -E_BAD_ENV;
f0104b39:	83 ec 04             	sub    $0x4,%esp
f0104b3c:	6a 01                	push   $0x1
f0104b3e:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104b41:	50                   	push   %eax
f0104b42:	ff 75 0c             	push   0xc(%ebp)
f0104b45:	e8 8d e5 ff ff       	call   f01030d7 <envid2env>
f0104b4a:	83 c4 10             	add    $0x10,%esp
f0104b4d:	85 c0                	test   %eax,%eax
f0104b4f:	0f 88 94 00 00 00    	js     f0104be9 <syscall+0x33a>
f0104b55:	83 ec 04             	sub    $0x4,%esp
f0104b58:	6a 01                	push   $0x1
f0104b5a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104b5d:	50                   	push   %eax
f0104b5e:	ff 75 14             	push   0x14(%ebp)
f0104b61:	e8 71 e5 ff ff       	call   f01030d7 <envid2env>
f0104b66:	83 c4 10             	add    $0x10,%esp
f0104b69:	85 c0                	test   %eax,%eax
f0104b6b:	0f 88 82 00 00 00    	js     f0104bf3 <syscall+0x344>
	struct PageInfo *pp = page_lookup(src_e->env_pgdir, srcva, &src_pte);
f0104b71:	83 ec 04             	sub    $0x4,%esp
f0104b74:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b77:	50                   	push   %eax
f0104b78:	ff 75 10             	push   0x10(%ebp)
f0104b7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104b7e:	ff 70 70             	push   0x70(%eax)
f0104b81:	e8 f5 c5 ff ff       	call   f010117b <page_lookup>
	if( pp==NULL ) return -E_INVAL;
f0104b86:	83 c4 10             	add    $0x10,%esp
f0104b89:	85 c0                	test   %eax,%eax
f0104b8b:	74 70                	je     f0104bfd <syscall+0x34e>
	if ( ( ( *src_pte & PTE_W ) == 0 ) && ( (perm & PTE_W) == PTE_W ) ) return -E_INVAL;
f0104b8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b90:	f6 02 02             	testb  $0x2,(%edx)
f0104b93:	75 06                	jne    f0104b9b <syscall+0x2ec>
f0104b95:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104b99:	75 6c                	jne    f0104c07 <syscall+0x358>
	int error_ret =page_insert(dst_e->env_pgdir, pp, dstva, perm);
f0104b9b:	ff 75 1c             	push   0x1c(%ebp)
f0104b9e:	ff 75 18             	push   0x18(%ebp)
f0104ba1:	50                   	push   %eax
f0104ba2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ba5:	ff 70 70             	push   0x70(%eax)
f0104ba8:	e8 a8 c6 ff ff       	call   f0101255 <page_insert>
f0104bad:	85 c0                	test   %eax,%eax
f0104baf:	ba 00 00 00 00       	mov    $0x0,%edx
f0104bb4:	0f 4e d0             	cmovle %eax,%edx
f0104bb7:	89 d3                	mov    %edx,%ebx
f0104bb9:	83 c4 10             	add    $0x10,%esp
f0104bbc:	e9 40 fd ff ff       	jmp    f0104901 <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f0104bc1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bc6:	e9 36 fd ff ff       	jmp    f0104901 <syscall+0x52>
	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
f0104bcb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bd0:	e9 2c fd ff ff       	jmp    f0104901 <syscall+0x52>
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
f0104bd5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bda:	e9 22 fd ff ff       	jmp    f0104901 <syscall+0x52>
f0104bdf:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104be4:	e9 18 fd ff ff       	jmp    f0104901 <syscall+0x52>
	if (envid2env(srcenvid, &src_e, 1)<0 || envid2env(dstenvid, &dst_e, 1)<0) return -E_BAD_ENV;
f0104be9:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104bee:	e9 0e fd ff ff       	jmp    f0104901 <syscall+0x52>
f0104bf3:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104bf8:	e9 04 fd ff ff       	jmp    f0104901 <syscall+0x52>
	if( pp==NULL ) return -E_INVAL;
f0104bfd:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c02:	e9 fa fc ff ff       	jmp    f0104901 <syscall+0x52>
	if ( ( ( *src_pte & PTE_W ) == 0 ) && ( (perm & PTE_W) == PTE_W ) ) return -E_INVAL;
f0104c07:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_page_map(a1, (void *)a2, a3, (void*)a4, (int)a5);
f0104c0c:	e9 f0 fc ff ff       	jmp    f0104901 <syscall+0x52>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f0104c11:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104c18:	77 45                	ja     f0104c5f <syscall+0x3b0>
f0104c1a:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104c21:	75 46                	jne    f0104c69 <syscall+0x3ba>
	int error_ret=envid2env(envid, &e, 1);
f0104c23:	83 ec 04             	sub    $0x4,%esp
f0104c26:	6a 01                	push   $0x1
f0104c28:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c2b:	50                   	push   %eax
f0104c2c:	ff 75 0c             	push   0xc(%ebp)
f0104c2f:	e8 a3 e4 ff ff       	call   f01030d7 <envid2env>
f0104c34:	89 c3                	mov    %eax,%ebx
	if( error_ret <0 ) return error_ret;
f0104c36:	83 c4 10             	add    $0x10,%esp
f0104c39:	85 c0                	test   %eax,%eax
f0104c3b:	0f 88 c0 fc ff ff    	js     f0104901 <syscall+0x52>
	page_remove(e->env_pgdir, va);
f0104c41:	83 ec 08             	sub    $0x8,%esp
f0104c44:	ff 75 10             	push   0x10(%ebp)
f0104c47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c4a:	ff 70 70             	push   0x70(%eax)
f0104c4d:	e8 bd c5 ff ff       	call   f010120f <page_remove>
	return 0;
f0104c52:	83 c4 10             	add    $0x10,%esp
f0104c55:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c5a:	e9 a2 fc ff ff       	jmp    f0104901 <syscall+0x52>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f0104c5f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c64:	e9 98 fc ff ff       	jmp    f0104901 <syscall+0x52>
f0104c69:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_page_unmap(a1, (void *)a2);
f0104c6e:	e9 8e fc ff ff       	jmp    f0104901 <syscall+0x52>
	int error_ret= envid2env(envid, &e, 1);
f0104c73:	83 ec 04             	sub    $0x4,%esp
f0104c76:	6a 01                	push   $0x1
f0104c78:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c7b:	50                   	push   %eax
f0104c7c:	ff 75 0c             	push   0xc(%ebp)
f0104c7f:	e8 53 e4 ff ff       	call   f01030d7 <envid2env>
f0104c84:	89 c3                	mov    %eax,%ebx
	if(error_ret < 0 ) return error_ret;
f0104c86:	83 c4 10             	add    $0x10,%esp
f0104c89:	85 c0                	test   %eax,%eax
f0104c8b:	0f 88 70 fc ff ff    	js     f0104901 <syscall+0x52>
	e->env_pgfault_upcall = func;
f0104c91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c94:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104c97:	89 78 74             	mov    %edi,0x74(%eax)
	return 0;
f0104c9a:	bb 00 00 00 00       	mov    $0x0,%ebx
        		return sys_env_set_pgfault_upcall(a1, (void*) a2);
f0104c9f:	e9 5d fc ff ff       	jmp    f0104901 <syscall+0x52>
	if ( (r = envid2env( envid, &dstenv, 0)) < 0)  return r;
f0104ca4:	83 ec 04             	sub    $0x4,%esp
f0104ca7:	6a 00                	push   $0x0
f0104ca9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104cac:	50                   	push   %eax
f0104cad:	ff 75 0c             	push   0xc(%ebp)
f0104cb0:	e8 22 e4 ff ff       	call   f01030d7 <envid2env>
f0104cb5:	89 c3                	mov    %eax,%ebx
f0104cb7:	83 c4 10             	add    $0x10,%esp
f0104cba:	85 c0                	test   %eax,%eax
f0104cbc:	0f 88 3f fc ff ff    	js     f0104901 <syscall+0x52>
	if ( (dstenv->env_ipc_recving != true)  || dstenv->env_ipc_from != 0)  return -E_IPC_NOT_RECV;
f0104cc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cc5:	80 78 78 00          	cmpb   $0x0,0x78(%eax)
f0104cc9:	0f 84 14 01 00 00    	je     f0104de3 <syscall+0x534>
f0104ccf:	8b 98 84 00 00 00    	mov    0x84(%eax),%ebx
f0104cd5:	85 db                	test   %ebx,%ebx
f0104cd7:	0f 85 10 01 00 00    	jne    f0104ded <syscall+0x53e>
	dstenv->env_ipc_perm=0;//如果没转移页，设置为0
f0104cdd:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
f0104ce4:	00 00 00 
	if((uintptr_t) srcva <  UTOP){
f0104ce7:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104cee:	0f 87 8d 00 00 00    	ja     f0104d81 <syscall+0x4d2>
		if (  !(perm & PTE_P ) || !(perm & PTE_U) )  return -E_INVAL;
f0104cf4:	8b 45 18             	mov    0x18(%ebp),%eax
f0104cf7:	83 e0 05             	and    $0x5,%eax
f0104cfa:	83 f8 05             	cmp    $0x5,%eax
f0104cfd:	0f 85 bb 00 00 00    	jne    f0104dbe <syscall+0x50f>
		if ( PGOFF(srcva) )  return -E_INVAL;
f0104d03:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d06:	25 ff 0f 00 00       	and    $0xfff,%eax
		if (perm &  (~ PTE_SYSCALL))   return -E_INVAL; 
f0104d0b:	8b 55 18             	mov    0x18(%ebp),%edx
f0104d0e:	81 e2 f8 f1 ff ff    	and    $0xfffff1f8,%edx
f0104d14:	09 d0                	or     %edx,%eax
f0104d16:	74 0a                	je     f0104d22 <syscall+0x473>
f0104d18:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d1d:	e9 df fb ff ff       	jmp    f0104901 <syscall+0x52>
		if ((pp = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL )  return -E_INVAL;
f0104d22:	e8 bd 13 00 00       	call   f01060e4 <cpunum>
f0104d27:	83 ec 04             	sub    $0x4,%esp
f0104d2a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104d2d:	52                   	push   %edx
f0104d2e:	ff 75 14             	push   0x14(%ebp)
f0104d31:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d34:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104d3a:	ff 70 70             	push   0x70(%eax)
f0104d3d:	e8 39 c4 ff ff       	call   f010117b <page_lookup>
f0104d42:	83 c4 10             	add    $0x10,%esp
f0104d45:	85 c0                	test   %eax,%eax
f0104d47:	74 7f                	je     f0104dc8 <syscall+0x519>
		if ((perm & PTE_W) && !(*pte & PTE_W) )   return -E_INVAL;
f0104d49:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104d4d:	74 08                	je     f0104d57 <syscall+0x4a8>
f0104d4f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d52:	f6 02 02             	testb  $0x2,(%edx)
f0104d55:	74 7b                	je     f0104dd2 <syscall+0x523>
		if (dstenv->env_ipc_dstva) {
f0104d57:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104d5a:	8b 4a 7c             	mov    0x7c(%edx),%ecx
f0104d5d:	85 c9                	test   %ecx,%ecx
f0104d5f:	74 20                	je     f0104d81 <syscall+0x4d2>
			if( (r = page_insert(dstenv->env_pgdir, pp, dstenv->env_ipc_dstva,  perm) ) < 0)  return r;
f0104d61:	ff 75 18             	push   0x18(%ebp)
f0104d64:	51                   	push   %ecx
f0104d65:	50                   	push   %eax
f0104d66:	ff 72 70             	push   0x70(%edx)
f0104d69:	e8 e7 c4 ff ff       	call   f0101255 <page_insert>
f0104d6e:	83 c4 10             	add    $0x10,%esp
f0104d71:	85 c0                	test   %eax,%eax
f0104d73:	78 67                	js     f0104ddc <syscall+0x52d>
			dstenv->env_ipc_perm = perm;
f0104d75:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d78:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104d7b:	89 88 88 00 00 00    	mov    %ecx,0x88(%eax)
	dstenv->env_ipc_recving = false;
f0104d81:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d84:	c6 40 78 00          	movb   $0x0,0x78(%eax)
	dstenv->env_ipc_from = curenv->env_id;
f0104d88:	e8 57 13 00 00       	call   f01060e4 <cpunum>
f0104d8d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104d90:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d93:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104d99:	8b 40 58             	mov    0x58(%eax),%eax
f0104d9c:	89 82 84 00 00 00    	mov    %eax,0x84(%edx)
	dstenv->env_ipc_value = value;
f0104da2:	8b 45 10             	mov    0x10(%ebp),%eax
f0104da5:	89 82 80 00 00 00    	mov    %eax,0x80(%edx)
	dstenv->env_status = ENV_RUNNABLE;
f0104dab:	c7 42 64 02 00 00 00 	movl   $0x2,0x64(%edx)
	dstenv->env_tf.tf_regs.reg_eax = 0;
f0104db2:	c7 42 2c 00 00 00 00 	movl   $0x0,0x2c(%edx)
	return 0;
f0104db9:	e9 43 fb ff ff       	jmp    f0104901 <syscall+0x52>
		if (  !(perm & PTE_P ) || !(perm & PTE_U) )  return -E_INVAL;
f0104dbe:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104dc3:	e9 39 fb ff ff       	jmp    f0104901 <syscall+0x52>
		if ((pp = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL )  return -E_INVAL;
f0104dc8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104dcd:	e9 2f fb ff ff       	jmp    f0104901 <syscall+0x52>
		if ((perm & PTE_W) && !(*pte & PTE_W) )   return -E_INVAL;
f0104dd2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104dd7:	e9 25 fb ff ff       	jmp    f0104901 <syscall+0x52>
			if( (r = page_insert(dstenv->env_pgdir, pp, dstenv->env_ipc_dstva,  perm) ) < 0)  return r;
f0104ddc:	89 c3                	mov    %eax,%ebx
f0104dde:	e9 1e fb ff ff       	jmp    f0104901 <syscall+0x52>
	if ( (dstenv->env_ipc_recving != true)  || dstenv->env_ipc_from != 0)  return -E_IPC_NOT_RECV;
f0104de3:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104de8:	e9 14 fb ff ff       	jmp    f0104901 <syscall+0x52>
f0104ded:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0104df2:	e9 0a fb ff ff       	jmp    f0104901 <syscall+0x52>
	if ((uintptr_t) dstva < UTOP && PGOFF(dstva) != 0) return -E_INVAL;
f0104df7:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104dfe:	77 13                	ja     f0104e13 <syscall+0x564>
f0104e00:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104e07:	74 0a                	je     f0104e13 <syscall+0x564>
			return sys_ipc_recv((void *)a1);
f0104e09:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e0e:	e9 ee fa ff ff       	jmp    f0104901 <syscall+0x52>
	curenv->env_ipc_recving = true;
f0104e13:	e8 cc 12 00 00       	call   f01060e4 <cpunum>
f0104e18:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e1b:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104e21:	c6 40 78 01          	movb   $0x1,0x78(%eax)
	curenv->env_ipc_dstva = dstva;
f0104e25:	e8 ba 12 00 00       	call   f01060e4 <cpunum>
f0104e2a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e2d:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104e33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104e36:	89 48 7c             	mov    %ecx,0x7c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104e39:	e8 a6 12 00 00       	call   f01060e4 <cpunum>
f0104e3e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e41:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104e47:	c7 40 64 04 00 00 00 	movl   $0x4,0x64(%eax)
	curenv->env_ipc_from = 0;
f0104e4e:	e8 91 12 00 00       	call   f01060e4 <cpunum>
f0104e53:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e56:	8b 80 28 d0 2f f0    	mov    -0xfd02fd8(%eax),%eax
f0104e5c:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
f0104e63:	00 00 00 
	sched_yield();
f0104e66:	e8 43 f9 ff ff       	call   f01047ae <sched_yield>
	if( (r = envid2env(envid, &e, 1)) < 0 ) return r;
f0104e6b:	83 ec 04             	sub    $0x4,%esp
f0104e6e:	6a 01                	push   $0x1
f0104e70:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e73:	50                   	push   %eax
f0104e74:	ff 75 0c             	push   0xc(%ebp)
f0104e77:	e8 5b e2 ff ff       	call   f01030d7 <envid2env>
f0104e7c:	89 c3                	mov    %eax,%ebx
f0104e7e:	83 c4 10             	add    $0x10,%esp
f0104e81:	85 c0                	test   %eax,%eax
f0104e83:	0f 88 78 fa ff ff    	js     f0104901 <syscall+0x52>
	user_mem_assert(e, tf, sizeof(struct Trapframe), 0);
f0104e89:	6a 00                	push   $0x0
f0104e8b:	6a 44                	push   $0x44
f0104e8d:	ff 75 10             	push   0x10(%ebp)
f0104e90:	ff 75 e4             	push   -0x1c(%ebp)
f0104e93:	e8 5b e1 ff ff       	call   f0102ff3 <user_mem_assert>
	e->env_tf=*tf;
f0104e98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e9b:	8d 78 10             	lea    0x10(%eax),%edi
f0104e9e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104ea3:	8b 75 10             	mov    0x10(%ebp),%esi
f0104ea6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_cs|=3;
f0104ea8:	66 83 48 44 03       	orw    $0x3,0x44(%eax)
	e->env_tf.tf_eflags &=  ~FL_IOPL_MASK;
f0104ead:	8b 50 48             	mov    0x48(%eax),%edx
f0104eb0:	80 e6 cf             	and    $0xcf,%dh
f0104eb3:	80 ce 02             	or     $0x2,%dh
f0104eb6:	89 50 48             	mov    %edx,0x48(%eax)
	return 0;
f0104eb9:	83 c4 10             	add    $0x10,%esp
f0104ebc:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_env_set_trapframe(a1, (struct Trapframe*) a2);
f0104ec1:	e9 3b fa ff ff       	jmp    f0104901 <syscall+0x52>
	return time_msec();
f0104ec6:	e8 97 1e 00 00       	call   f0106d62 <time_msec>
f0104ecb:	89 c3                	mov    %eax,%ebx
			return sys_time_msec();
f0104ecd:	e9 2f fa ff ff       	jmp    f0104901 <syscall+0x52>
	user_mem_assert(curenv, buf, len, PTE_U);
f0104ed2:	e8 0d 12 00 00       	call   f01060e4 <cpunum>
f0104ed7:	6a 04                	push   $0x4
f0104ed9:	ff 75 10             	push   0x10(%ebp)
f0104edc:	ff 75 0c             	push   0xc(%ebp)
f0104edf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ee2:	ff b0 28 d0 2f f0    	push   -0xfd02fd8(%eax)
f0104ee8:	e8 06 e1 ff ff       	call   f0102ff3 <user_mem_assert>
	return e1000_transmit(buf, len);
f0104eed:	83 c4 08             	add    $0x8,%esp
f0104ef0:	ff 75 10             	push   0x10(%ebp)
f0104ef3:	ff 75 0c             	push   0xc(%ebp)
f0104ef6:	e8 cc 16 00 00       	call   f01065c7 <e1000_transmit>
f0104efb:	89 c3                	mov    %eax,%ebx
			return sys_e1000_try_send((void *)a1, (size_t)a2);
f0104efd:	83 c4 10             	add    $0x10,%esp
f0104f00:	e9 fc f9 ff ff       	jmp    f0104901 <syscall+0x52>
	return e1000_receive(dstva, len);
f0104f05:	83 ec 08             	sub    $0x8,%esp
f0104f08:	ff 75 10             	push   0x10(%ebp)
f0104f0b:	ff 75 0c             	push   0xc(%ebp)
f0104f0e:	e8 59 18 00 00       	call   f010676c <e1000_receive>
f0104f13:	89 c3                	mov    %eax,%ebx
			return sys_e1000_recv((void *)a1,(size_t *)a2);	
f0104f15:	83 c4 10             	add    $0x10,%esp
f0104f18:	e9 e4 f9 ff ff       	jmp    f0104901 <syscall+0x52>
	switch (syscallno) 
f0104f1d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f22:	e9 da f9 ff ff       	jmp    f0104901 <syscall+0x52>

f0104f27 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104f27:	55                   	push   %ebp
f0104f28:	89 e5                	mov    %esp,%ebp
f0104f2a:	57                   	push   %edi
f0104f2b:	56                   	push   %esi
f0104f2c:	53                   	push   %ebx
f0104f2d:	83 ec 14             	sub    $0x14,%esp
f0104f30:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104f33:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104f36:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104f39:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104f3c:	8b 1a                	mov    (%edx),%ebx
f0104f3e:	8b 01                	mov    (%ecx),%eax
f0104f40:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104f43:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104f4a:	eb 2f                	jmp    f0104f7b <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104f4c:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104f4f:	39 c3                	cmp    %eax,%ebx
f0104f51:	7f 4e                	jg     f0104fa1 <stab_binsearch+0x7a>
f0104f53:	0f b6 0a             	movzbl (%edx),%ecx
f0104f56:	83 ea 0c             	sub    $0xc,%edx
f0104f59:	39 f1                	cmp    %esi,%ecx
f0104f5b:	75 ef                	jne    f0104f4c <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104f5d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104f60:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104f63:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104f67:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104f6a:	73 3a                	jae    f0104fa6 <stab_binsearch+0x7f>
			*region_left = m;
f0104f6c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104f6f:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104f71:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0104f74:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104f7b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104f7e:	7f 53                	jg     f0104fd3 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0104f80:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104f83:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0104f86:	89 d0                	mov    %edx,%eax
f0104f88:	c1 e8 1f             	shr    $0x1f,%eax
f0104f8b:	01 d0                	add    %edx,%eax
f0104f8d:	89 c7                	mov    %eax,%edi
f0104f8f:	d1 ff                	sar    %edi
f0104f91:	83 e0 fe             	and    $0xfffffffe,%eax
f0104f94:	01 f8                	add    %edi,%eax
f0104f96:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104f99:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104f9d:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104f9f:	eb ae                	jmp    f0104f4f <stab_binsearch+0x28>
			l = true_m + 1;
f0104fa1:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104fa4:	eb d5                	jmp    f0104f7b <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104fa6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104fa9:	76 14                	jbe    f0104fbf <stab_binsearch+0x98>
			*region_right = m - 1;
f0104fab:	83 e8 01             	sub    $0x1,%eax
f0104fae:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104fb1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104fb4:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104fb6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104fbd:	eb bc                	jmp    f0104f7b <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104fbf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104fc2:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104fc4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104fc8:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104fca:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104fd1:	eb a8                	jmp    f0104f7b <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104fd3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104fd7:	75 15                	jne    f0104fee <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0104fd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104fdc:	8b 00                	mov    (%eax),%eax
f0104fde:	83 e8 01             	sub    $0x1,%eax
f0104fe1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104fe4:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104fe6:	83 c4 14             	add    $0x14,%esp
f0104fe9:	5b                   	pop    %ebx
f0104fea:	5e                   	pop    %esi
f0104feb:	5f                   	pop    %edi
f0104fec:	5d                   	pop    %ebp
f0104fed:	c3                   	ret    
		for (l = *region_right;
f0104fee:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ff1:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104ff3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ff6:	8b 0f                	mov    (%edi),%ecx
f0104ff8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ffb:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104ffe:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0105002:	39 c1                	cmp    %eax,%ecx
f0105004:	7d 0f                	jge    f0105015 <stab_binsearch+0xee>
f0105006:	0f b6 1a             	movzbl (%edx),%ebx
f0105009:	83 ea 0c             	sub    $0xc,%edx
f010500c:	39 f3                	cmp    %esi,%ebx
f010500e:	74 05                	je     f0105015 <stab_binsearch+0xee>
		     l--)
f0105010:	83 e8 01             	sub    $0x1,%eax
f0105013:	eb ed                	jmp    f0105002 <stab_binsearch+0xdb>
		*region_left = l;
f0105015:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105018:	89 07                	mov    %eax,(%edi)
}
f010501a:	eb ca                	jmp    f0104fe6 <stab_binsearch+0xbf>

f010501c <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010501c:	55                   	push   %ebp
f010501d:	89 e5                	mov    %esp,%ebp
f010501f:	57                   	push   %edi
f0105020:	56                   	push   %esi
f0105021:	53                   	push   %ebx
f0105022:	83 ec 4c             	sub    $0x4c,%esp
f0105025:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105028:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010502b:	c7 03 34 89 10 f0    	movl   $0xf0108934,(%ebx)
	info->eip_line = 0;
f0105031:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105038:	c7 43 08 34 89 10 f0 	movl   $0xf0108934,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010503f:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105046:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105049:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105050:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0105056:	0f 86 29 01 00 00    	jbe    f0105185 <debuginfo_eip+0x169>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010505c:	c7 45 c0 aa e4 11 f0 	movl   $0xf011e4aa,-0x40(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0105063:	c7 45 bc 65 62 11 f0 	movl   $0xf0116265,-0x44(%ebp)
		stab_end = __STAB_END__;
f010506a:	be 64 62 11 f0       	mov    $0xf0116264,%esi
		stabs = __STAB_BEGIN__;
f010506f:	c7 45 c4 48 91 10 f0 	movl   $0xf0109148,-0x3c(%ebp)
		if( user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ) return -1;
		if( user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) ) return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105076:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105079:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f010507c:	0f 83 3e 02 00 00    	jae    f01052c0 <debuginfo_eip+0x2a4>
f0105082:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0105086:	0f 85 3b 02 00 00    	jne    f01052c7 <debuginfo_eip+0x2ab>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010508c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105093:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0105096:	c1 fe 02             	sar    $0x2,%esi
f0105099:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f010509f:	83 e8 01             	sub    $0x1,%eax
f01050a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01050a5:	83 ec 08             	sub    $0x8,%esp
f01050a8:	57                   	push   %edi
f01050a9:	6a 64                	push   $0x64
f01050ab:	8d 75 e0             	lea    -0x20(%ebp),%esi
f01050ae:	89 f1                	mov    %esi,%ecx
f01050b0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01050b3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01050b6:	e8 6c fe ff ff       	call   f0104f27 <stab_binsearch>
	if (lfile == 0)
f01050bb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01050be:	83 c4 10             	add    $0x10,%esp
f01050c1:	85 f6                	test   %esi,%esi
f01050c3:	0f 84 05 02 00 00    	je     f01052ce <debuginfo_eip+0x2b2>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01050c9:	89 75 dc             	mov    %esi,-0x24(%ebp)
	rfun = rfile;
f01050cc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01050cf:	89 55 b8             	mov    %edx,-0x48(%ebp)
f01050d2:	89 55 d8             	mov    %edx,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01050d5:	83 ec 08             	sub    $0x8,%esp
f01050d8:	57                   	push   %edi
f01050d9:	6a 24                	push   $0x24
f01050db:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01050de:	89 d1                	mov    %edx,%ecx
f01050e0:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01050e3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01050e6:	e8 3c fe ff ff       	call   f0104f27 <stab_binsearch>

	if (lfun <= rfun) {
f01050eb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01050ee:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f01050f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01050f4:	89 45 b0             	mov    %eax,-0x50(%ebp)
f01050f7:	83 c4 10             	add    $0x10,%esp
f01050fa:	39 c2                	cmp    %eax,%edx
f01050fc:	0f 8f 32 01 00 00    	jg     f0105234 <debuginfo_eip+0x218>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105102:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0105105:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105108:	8d 14 82             	lea    (%edx,%eax,4),%edx
f010510b:	8b 02                	mov    (%edx),%eax
f010510d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105110:	2b 4d bc             	sub    -0x44(%ebp),%ecx
f0105113:	39 c8                	cmp    %ecx,%eax
f0105115:	73 06                	jae    f010511d <debuginfo_eip+0x101>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105117:	03 45 bc             	add    -0x44(%ebp),%eax
f010511a:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010511d:	8b 42 08             	mov    0x8(%edx),%eax
		addr -= info->eip_fn_addr;
f0105120:	29 c7                	sub    %eax,%edi
f0105122:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0105125:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0105128:	89 4d b8             	mov    %ecx,-0x48(%ebp)
		info->eip_fn_addr = stabs[lfun].n_value;
f010512b:	89 43 10             	mov    %eax,0x10(%ebx)
		// Search within the function definition for the line number.
		lline = lfun;
f010512e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0105131:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0105134:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105137:	83 ec 08             	sub    $0x8,%esp
f010513a:	6a 3a                	push   $0x3a
f010513c:	ff 73 08             	push   0x8(%ebx)
f010513f:	e8 8d 09 00 00       	call   f0105ad1 <strfind>
f0105144:	2b 43 08             	sub    0x8(%ebx),%eax
f0105147:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010514a:	83 c4 08             	add    $0x8,%esp
f010514d:	57                   	push   %edi
f010514e:	6a 44                	push   $0x44
f0105150:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105153:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105156:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105159:	89 f8                	mov    %edi,%eax
f010515b:	e8 c7 fd ff ff       	call   f0104f27 <stab_binsearch>
	if (lline <= rline) {
f0105160:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105163:	83 c4 10             	add    $0x10,%esp
f0105166:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105169:	0f 8f 66 01 00 00    	jg     f01052d5 <debuginfo_eip+0x2b9>
    		info->eip_line = stabs[lline].n_desc;
f010516f:	89 c2                	mov    %eax,%edx
f0105171:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105174:	0f b7 4c 87 06       	movzwl 0x6(%edi,%eax,4),%ecx
f0105179:	89 4b 04             	mov    %ecx,0x4(%ebx)
f010517c:	8d 44 87 04          	lea    0x4(%edi,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105180:	e9 be 00 00 00       	jmp    f0105243 <debuginfo_eip+0x227>
		if( user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) ) return -1;
f0105185:	e8 5a 0f 00 00       	call   f01060e4 <cpunum>
f010518a:	6a 04                	push   $0x4
f010518c:	6a 10                	push   $0x10
f010518e:	68 00 00 20 00       	push   $0x200000
f0105193:	6b c0 74             	imul   $0x74,%eax,%eax
f0105196:	ff b0 28 d0 2f f0    	push   -0xfd02fd8(%eax)
f010519c:	e8 c4 dd ff ff       	call   f0102f65 <user_mem_check>
f01051a1:	83 c4 10             	add    $0x10,%esp
f01051a4:	85 c0                	test   %eax,%eax
f01051a6:	0f 85 06 01 00 00    	jne    f01052b2 <debuginfo_eip+0x296>
		stabs = usd->stabs;
f01051ac:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f01051b2:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		stab_end = usd->stab_end;
f01051b5:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f01051bb:	a1 08 00 20 00       	mov    0x200008,%eax
f01051c0:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f01051c3:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f01051c9:	89 55 c0             	mov    %edx,-0x40(%ebp)
		if( user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ) return -1;
f01051cc:	e8 13 0f 00 00       	call   f01060e4 <cpunum>
f01051d1:	89 c2                	mov    %eax,%edx
f01051d3:	6a 04                	push   $0x4
f01051d5:	89 f0                	mov    %esi,%eax
f01051d7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01051da:	29 c8                	sub    %ecx,%eax
f01051dc:	c1 f8 02             	sar    $0x2,%eax
f01051df:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01051e5:	50                   	push   %eax
f01051e6:	51                   	push   %ecx
f01051e7:	6b d2 74             	imul   $0x74,%edx,%edx
f01051ea:	ff b2 28 d0 2f f0    	push   -0xfd02fd8(%edx)
f01051f0:	e8 70 dd ff ff       	call   f0102f65 <user_mem_check>
f01051f5:	83 c4 10             	add    $0x10,%esp
f01051f8:	85 c0                	test   %eax,%eax
f01051fa:	0f 85 b9 00 00 00    	jne    f01052b9 <debuginfo_eip+0x29d>
		if( user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) ) return -1;
f0105200:	e8 df 0e 00 00       	call   f01060e4 <cpunum>
f0105205:	6a 04                	push   $0x4
f0105207:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010520a:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f010520d:	29 ca                	sub    %ecx,%edx
f010520f:	52                   	push   %edx
f0105210:	51                   	push   %ecx
f0105211:	6b c0 74             	imul   $0x74,%eax,%eax
f0105214:	ff b0 28 d0 2f f0    	push   -0xfd02fd8(%eax)
f010521a:	e8 46 dd ff ff       	call   f0102f65 <user_mem_check>
f010521f:	83 c4 10             	add    $0x10,%esp
f0105222:	85 c0                	test   %eax,%eax
f0105224:	0f 84 4c fe ff ff    	je     f0105076 <debuginfo_eip+0x5a>
f010522a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010522f:	e9 ad 00 00 00       	jmp    f01052e1 <debuginfo_eip+0x2c5>
f0105234:	89 f8                	mov    %edi,%eax
f0105236:	89 f2                	mov    %esi,%edx
f0105238:	e9 ee fe ff ff       	jmp    f010512b <debuginfo_eip+0x10f>
f010523d:	83 ea 01             	sub    $0x1,%edx
f0105240:	83 e8 0c             	sub    $0xc,%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105243:	39 d6                	cmp    %edx,%esi
f0105245:	7f 2e                	jg     f0105275 <debuginfo_eip+0x259>
	       && stabs[lline].n_type != N_SOL
f0105247:	0f b6 08             	movzbl (%eax),%ecx
f010524a:	80 f9 84             	cmp    $0x84,%cl
f010524d:	74 0b                	je     f010525a <debuginfo_eip+0x23e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010524f:	80 f9 64             	cmp    $0x64,%cl
f0105252:	75 e9                	jne    f010523d <debuginfo_eip+0x221>
f0105254:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0105258:	74 e3                	je     f010523d <debuginfo_eip+0x221>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010525a:	8d 04 52             	lea    (%edx,%edx,2),%eax
f010525d:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105260:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0105263:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105266:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105269:	29 f0                	sub    %esi,%eax
f010526b:	39 c2                	cmp    %eax,%edx
f010526d:	73 06                	jae    f0105275 <debuginfo_eip+0x259>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010526f:	89 f0                	mov    %esi,%eax
f0105271:	01 d0                	add    %edx,%eax
f0105273:	89 03                	mov    %eax,(%ebx)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105275:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f010527a:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f010527d:	8b 75 b0             	mov    -0x50(%ebp),%esi
f0105280:	39 f7                	cmp    %esi,%edi
f0105282:	7d 5d                	jge    f01052e1 <debuginfo_eip+0x2c5>
		for (lline = lfun + 1;
f0105284:	83 c7 01             	add    $0x1,%edi
f0105287:	89 f8                	mov    %edi,%eax
f0105289:	8d 14 7f             	lea    (%edi,%edi,2),%edx
f010528c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010528f:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0105293:	eb 04                	jmp    f0105299 <debuginfo_eip+0x27d>
			info->eip_fn_narg++;
f0105295:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105299:	39 c6                	cmp    %eax,%esi
f010529b:	7e 3f                	jle    f01052dc <debuginfo_eip+0x2c0>
f010529d:	0f b6 0a             	movzbl (%edx),%ecx
f01052a0:	83 c0 01             	add    $0x1,%eax
f01052a3:	83 c2 0c             	add    $0xc,%edx
f01052a6:	80 f9 a0             	cmp    $0xa0,%cl
f01052a9:	74 ea                	je     f0105295 <debuginfo_eip+0x279>
	return 0;
f01052ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01052b0:	eb 2f                	jmp    f01052e1 <debuginfo_eip+0x2c5>
		if( user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) ) return -1;
f01052b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052b7:	eb 28                	jmp    f01052e1 <debuginfo_eip+0x2c5>
		if( user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ) return -1;
f01052b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052be:	eb 21                	jmp    f01052e1 <debuginfo_eip+0x2c5>
		return -1;
f01052c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052c5:	eb 1a                	jmp    f01052e1 <debuginfo_eip+0x2c5>
f01052c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052cc:	eb 13                	jmp    f01052e1 <debuginfo_eip+0x2c5>
		return -1;
f01052ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052d3:	eb 0c                	jmp    f01052e1 <debuginfo_eip+0x2c5>
    		return -1;
f01052d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052da:	eb 05                	jmp    f01052e1 <debuginfo_eip+0x2c5>
	return 0;
f01052dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01052e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01052e4:	5b                   	pop    %ebx
f01052e5:	5e                   	pop    %esi
f01052e6:	5f                   	pop    %edi
f01052e7:	5d                   	pop    %ebp
f01052e8:	c3                   	ret    

f01052e9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01052e9:	55                   	push   %ebp
f01052ea:	89 e5                	mov    %esp,%ebp
f01052ec:	57                   	push   %edi
f01052ed:	56                   	push   %esi
f01052ee:	53                   	push   %ebx
f01052ef:	83 ec 1c             	sub    $0x1c,%esp
f01052f2:	89 c7                	mov    %eax,%edi
f01052f4:	89 d6                	mov    %edx,%esi
f01052f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01052f9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01052fc:	89 d1                	mov    %edx,%ecx
f01052fe:	89 c2                	mov    %eax,%edx
f0105300:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105303:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105306:	8b 45 10             	mov    0x10(%ebp),%eax
f0105309:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010530c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010530f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105316:	39 c2                	cmp    %eax,%edx
f0105318:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f010531b:	72 3e                	jb     f010535b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010531d:	83 ec 0c             	sub    $0xc,%esp
f0105320:	ff 75 18             	push   0x18(%ebp)
f0105323:	83 eb 01             	sub    $0x1,%ebx
f0105326:	53                   	push   %ebx
f0105327:	50                   	push   %eax
f0105328:	83 ec 08             	sub    $0x8,%esp
f010532b:	ff 75 e4             	push   -0x1c(%ebp)
f010532e:	ff 75 e0             	push   -0x20(%ebp)
f0105331:	ff 75 dc             	push   -0x24(%ebp)
f0105334:	ff 75 d8             	push   -0x28(%ebp)
f0105337:	e8 34 1a 00 00       	call   f0106d70 <__udivdi3>
f010533c:	83 c4 18             	add    $0x18,%esp
f010533f:	52                   	push   %edx
f0105340:	50                   	push   %eax
f0105341:	89 f2                	mov    %esi,%edx
f0105343:	89 f8                	mov    %edi,%eax
f0105345:	e8 9f ff ff ff       	call   f01052e9 <printnum>
f010534a:	83 c4 20             	add    $0x20,%esp
f010534d:	eb 13                	jmp    f0105362 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010534f:	83 ec 08             	sub    $0x8,%esp
f0105352:	56                   	push   %esi
f0105353:	ff 75 18             	push   0x18(%ebp)
f0105356:	ff d7                	call   *%edi
f0105358:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010535b:	83 eb 01             	sub    $0x1,%ebx
f010535e:	85 db                	test   %ebx,%ebx
f0105360:	7f ed                	jg     f010534f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105362:	83 ec 08             	sub    $0x8,%esp
f0105365:	56                   	push   %esi
f0105366:	83 ec 04             	sub    $0x4,%esp
f0105369:	ff 75 e4             	push   -0x1c(%ebp)
f010536c:	ff 75 e0             	push   -0x20(%ebp)
f010536f:	ff 75 dc             	push   -0x24(%ebp)
f0105372:	ff 75 d8             	push   -0x28(%ebp)
f0105375:	e8 16 1b 00 00       	call   f0106e90 <__umoddi3>
f010537a:	83 c4 14             	add    $0x14,%esp
f010537d:	0f be 80 3e 89 10 f0 	movsbl -0xfef76c2(%eax),%eax
f0105384:	50                   	push   %eax
f0105385:	ff d7                	call   *%edi
}
f0105387:	83 c4 10             	add    $0x10,%esp
f010538a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010538d:	5b                   	pop    %ebx
f010538e:	5e                   	pop    %esi
f010538f:	5f                   	pop    %edi
f0105390:	5d                   	pop    %ebp
f0105391:	c3                   	ret    

f0105392 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105392:	55                   	push   %ebp
f0105393:	89 e5                	mov    %esp,%ebp
f0105395:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105398:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010539c:	8b 10                	mov    (%eax),%edx
f010539e:	3b 50 04             	cmp    0x4(%eax),%edx
f01053a1:	73 0a                	jae    f01053ad <sprintputch+0x1b>
		*b->buf++ = ch;
f01053a3:	8d 4a 01             	lea    0x1(%edx),%ecx
f01053a6:	89 08                	mov    %ecx,(%eax)
f01053a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01053ab:	88 02                	mov    %al,(%edx)
}
f01053ad:	5d                   	pop    %ebp
f01053ae:	c3                   	ret    

f01053af <printfmt>:
{
f01053af:	55                   	push   %ebp
f01053b0:	89 e5                	mov    %esp,%ebp
f01053b2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01053b5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01053b8:	50                   	push   %eax
f01053b9:	ff 75 10             	push   0x10(%ebp)
f01053bc:	ff 75 0c             	push   0xc(%ebp)
f01053bf:	ff 75 08             	push   0x8(%ebp)
f01053c2:	e8 05 00 00 00       	call   f01053cc <vprintfmt>
}
f01053c7:	83 c4 10             	add    $0x10,%esp
f01053ca:	c9                   	leave  
f01053cb:	c3                   	ret    

f01053cc <vprintfmt>:
{
f01053cc:	55                   	push   %ebp
f01053cd:	89 e5                	mov    %esp,%ebp
f01053cf:	57                   	push   %edi
f01053d0:	56                   	push   %esi
f01053d1:	53                   	push   %ebx
f01053d2:	83 ec 3c             	sub    $0x3c,%esp
f01053d5:	8b 75 08             	mov    0x8(%ebp),%esi
f01053d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053db:	8b 7d 10             	mov    0x10(%ebp),%edi
f01053de:	eb 0a                	jmp    f01053ea <vprintfmt+0x1e>
			putch(ch, putdat);
f01053e0:	83 ec 08             	sub    $0x8,%esp
f01053e3:	53                   	push   %ebx
f01053e4:	50                   	push   %eax
f01053e5:	ff d6                	call   *%esi
f01053e7:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01053ea:	83 c7 01             	add    $0x1,%edi
f01053ed:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01053f1:	83 f8 25             	cmp    $0x25,%eax
f01053f4:	74 0c                	je     f0105402 <vprintfmt+0x36>
			if (ch == '\0')
f01053f6:	85 c0                	test   %eax,%eax
f01053f8:	75 e6                	jne    f01053e0 <vprintfmt+0x14>
}
f01053fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053fd:	5b                   	pop    %ebx
f01053fe:	5e                   	pop    %esi
f01053ff:	5f                   	pop    %edi
f0105400:	5d                   	pop    %ebp
f0105401:	c3                   	ret    
		padc = ' ';
f0105402:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0105406:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f010540d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0105414:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010541b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105420:	8d 47 01             	lea    0x1(%edi),%eax
f0105423:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105426:	0f b6 17             	movzbl (%edi),%edx
f0105429:	8d 42 dd             	lea    -0x23(%edx),%eax
f010542c:	3c 55                	cmp    $0x55,%al
f010542e:	0f 87 bb 03 00 00    	ja     f01057ef <vprintfmt+0x423>
f0105434:	0f b6 c0             	movzbl %al,%eax
f0105437:	ff 24 85 80 8a 10 f0 	jmp    *-0xfef7580(,%eax,4)
f010543e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105441:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0105445:	eb d9                	jmp    f0105420 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0105447:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010544a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f010544e:	eb d0                	jmp    f0105420 <vprintfmt+0x54>
f0105450:	0f b6 d2             	movzbl %dl,%edx
f0105453:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0105456:	b8 00 00 00 00       	mov    $0x0,%eax
f010545b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f010545e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105461:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0105465:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0105468:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010546b:	83 f9 09             	cmp    $0x9,%ecx
f010546e:	77 55                	ja     f01054c5 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
f0105470:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0105473:	eb e9                	jmp    f010545e <vprintfmt+0x92>
			precision = va_arg(ap, int);
f0105475:	8b 45 14             	mov    0x14(%ebp),%eax
f0105478:	8b 00                	mov    (%eax),%eax
f010547a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010547d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105480:	8d 40 04             	lea    0x4(%eax),%eax
f0105483:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0105489:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010548d:	79 91                	jns    f0105420 <vprintfmt+0x54>
				width = precision, precision = -1;
f010548f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105492:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105495:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f010549c:	eb 82                	jmp    f0105420 <vprintfmt+0x54>
f010549e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01054a1:	85 d2                	test   %edx,%edx
f01054a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01054a8:	0f 49 c2             	cmovns %edx,%eax
f01054ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01054ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01054b1:	e9 6a ff ff ff       	jmp    f0105420 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f01054b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01054b9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01054c0:	e9 5b ff ff ff       	jmp    f0105420 <vprintfmt+0x54>
f01054c5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01054c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01054cb:	eb bc                	jmp    f0105489 <vprintfmt+0xbd>
			lflag++;
f01054cd:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01054d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01054d3:	e9 48 ff ff ff       	jmp    f0105420 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f01054d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01054db:	8d 78 04             	lea    0x4(%eax),%edi
f01054de:	83 ec 08             	sub    $0x8,%esp
f01054e1:	53                   	push   %ebx
f01054e2:	ff 30                	push   (%eax)
f01054e4:	ff d6                	call   *%esi
			break;
f01054e6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01054e9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01054ec:	e9 9d 02 00 00       	jmp    f010578e <vprintfmt+0x3c2>
			err = va_arg(ap, int);
f01054f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01054f4:	8d 78 04             	lea    0x4(%eax),%edi
f01054f7:	8b 10                	mov    (%eax),%edx
f01054f9:	89 d0                	mov    %edx,%eax
f01054fb:	f7 d8                	neg    %eax
f01054fd:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105500:	83 f8 0f             	cmp    $0xf,%eax
f0105503:	7f 23                	jg     f0105528 <vprintfmt+0x15c>
f0105505:	8b 14 85 e0 8b 10 f0 	mov    -0xfef7420(,%eax,4),%edx
f010550c:	85 d2                	test   %edx,%edx
f010550e:	74 18                	je     f0105528 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
f0105510:	52                   	push   %edx
f0105511:	68 67 75 10 f0       	push   $0xf0107567
f0105516:	53                   	push   %ebx
f0105517:	56                   	push   %esi
f0105518:	e8 92 fe ff ff       	call   f01053af <printfmt>
f010551d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105520:	89 7d 14             	mov    %edi,0x14(%ebp)
f0105523:	e9 66 02 00 00       	jmp    f010578e <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
f0105528:	50                   	push   %eax
f0105529:	68 56 89 10 f0       	push   $0xf0108956
f010552e:	53                   	push   %ebx
f010552f:	56                   	push   %esi
f0105530:	e8 7a fe ff ff       	call   f01053af <printfmt>
f0105535:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105538:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010553b:	e9 4e 02 00 00       	jmp    f010578e <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
f0105540:	8b 45 14             	mov    0x14(%ebp),%eax
f0105543:	83 c0 04             	add    $0x4,%eax
f0105546:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0105549:	8b 45 14             	mov    0x14(%ebp),%eax
f010554c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f010554e:	85 d2                	test   %edx,%edx
f0105550:	b8 4f 89 10 f0       	mov    $0xf010894f,%eax
f0105555:	0f 45 c2             	cmovne %edx,%eax
f0105558:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f010555b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010555f:	7e 06                	jle    f0105567 <vprintfmt+0x19b>
f0105561:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0105565:	75 0d                	jne    f0105574 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105567:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010556a:	89 c7                	mov    %eax,%edi
f010556c:	03 45 e0             	add    -0x20(%ebp),%eax
f010556f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105572:	eb 55                	jmp    f01055c9 <vprintfmt+0x1fd>
f0105574:	83 ec 08             	sub    $0x8,%esp
f0105577:	ff 75 d8             	push   -0x28(%ebp)
f010557a:	ff 75 cc             	push   -0x34(%ebp)
f010557d:	e8 f8 03 00 00       	call   f010597a <strnlen>
f0105582:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105585:	29 c1                	sub    %eax,%ecx
f0105587:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f010558a:	83 c4 10             	add    $0x10,%esp
f010558d:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
f010558f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0105593:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0105596:	eb 0f                	jmp    f01055a7 <vprintfmt+0x1db>
					putch(padc, putdat);
f0105598:	83 ec 08             	sub    $0x8,%esp
f010559b:	53                   	push   %ebx
f010559c:	ff 75 e0             	push   -0x20(%ebp)
f010559f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01055a1:	83 ef 01             	sub    $0x1,%edi
f01055a4:	83 c4 10             	add    $0x10,%esp
f01055a7:	85 ff                	test   %edi,%edi
f01055a9:	7f ed                	jg     f0105598 <vprintfmt+0x1cc>
f01055ab:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01055ae:	85 d2                	test   %edx,%edx
f01055b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01055b5:	0f 49 c2             	cmovns %edx,%eax
f01055b8:	29 c2                	sub    %eax,%edx
f01055ba:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01055bd:	eb a8                	jmp    f0105567 <vprintfmt+0x19b>
					putch(ch, putdat);
f01055bf:	83 ec 08             	sub    $0x8,%esp
f01055c2:	53                   	push   %ebx
f01055c3:	52                   	push   %edx
f01055c4:	ff d6                	call   *%esi
f01055c6:	83 c4 10             	add    $0x10,%esp
f01055c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01055cc:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01055ce:	83 c7 01             	add    $0x1,%edi
f01055d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01055d5:	0f be d0             	movsbl %al,%edx
f01055d8:	85 d2                	test   %edx,%edx
f01055da:	74 4b                	je     f0105627 <vprintfmt+0x25b>
f01055dc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01055e0:	78 06                	js     f01055e8 <vprintfmt+0x21c>
f01055e2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01055e6:	78 1e                	js     f0105606 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
f01055e8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01055ec:	74 d1                	je     f01055bf <vprintfmt+0x1f3>
f01055ee:	0f be c0             	movsbl %al,%eax
f01055f1:	83 e8 20             	sub    $0x20,%eax
f01055f4:	83 f8 5e             	cmp    $0x5e,%eax
f01055f7:	76 c6                	jbe    f01055bf <vprintfmt+0x1f3>
					putch('?', putdat);
f01055f9:	83 ec 08             	sub    $0x8,%esp
f01055fc:	53                   	push   %ebx
f01055fd:	6a 3f                	push   $0x3f
f01055ff:	ff d6                	call   *%esi
f0105601:	83 c4 10             	add    $0x10,%esp
f0105604:	eb c3                	jmp    f01055c9 <vprintfmt+0x1fd>
f0105606:	89 cf                	mov    %ecx,%edi
f0105608:	eb 0e                	jmp    f0105618 <vprintfmt+0x24c>
				putch(' ', putdat);
f010560a:	83 ec 08             	sub    $0x8,%esp
f010560d:	53                   	push   %ebx
f010560e:	6a 20                	push   $0x20
f0105610:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105612:	83 ef 01             	sub    $0x1,%edi
f0105615:	83 c4 10             	add    $0x10,%esp
f0105618:	85 ff                	test   %edi,%edi
f010561a:	7f ee                	jg     f010560a <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
f010561c:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010561f:	89 45 14             	mov    %eax,0x14(%ebp)
f0105622:	e9 67 01 00 00       	jmp    f010578e <vprintfmt+0x3c2>
f0105627:	89 cf                	mov    %ecx,%edi
f0105629:	eb ed                	jmp    f0105618 <vprintfmt+0x24c>
	if (lflag >= 2)
f010562b:	83 f9 01             	cmp    $0x1,%ecx
f010562e:	7f 1b                	jg     f010564b <vprintfmt+0x27f>
	else if (lflag)
f0105630:	85 c9                	test   %ecx,%ecx
f0105632:	74 63                	je     f0105697 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
f0105634:	8b 45 14             	mov    0x14(%ebp),%eax
f0105637:	8b 00                	mov    (%eax),%eax
f0105639:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010563c:	99                   	cltd   
f010563d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105640:	8b 45 14             	mov    0x14(%ebp),%eax
f0105643:	8d 40 04             	lea    0x4(%eax),%eax
f0105646:	89 45 14             	mov    %eax,0x14(%ebp)
f0105649:	eb 17                	jmp    f0105662 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f010564b:	8b 45 14             	mov    0x14(%ebp),%eax
f010564e:	8b 50 04             	mov    0x4(%eax),%edx
f0105651:	8b 00                	mov    (%eax),%eax
f0105653:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105656:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105659:	8b 45 14             	mov    0x14(%ebp),%eax
f010565c:	8d 40 08             	lea    0x8(%eax),%eax
f010565f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105662:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105665:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0105668:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
f010566d:	85 c9                	test   %ecx,%ecx
f010566f:	0f 89 ff 00 00 00    	jns    f0105774 <vprintfmt+0x3a8>
				putch('-', putdat);
f0105675:	83 ec 08             	sub    $0x8,%esp
f0105678:	53                   	push   %ebx
f0105679:	6a 2d                	push   $0x2d
f010567b:	ff d6                	call   *%esi
				num = -(long long) num;
f010567d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105680:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105683:	f7 da                	neg    %edx
f0105685:	83 d1 00             	adc    $0x0,%ecx
f0105688:	f7 d9                	neg    %ecx
f010568a:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010568d:	bf 0a 00 00 00       	mov    $0xa,%edi
f0105692:	e9 dd 00 00 00       	jmp    f0105774 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
f0105697:	8b 45 14             	mov    0x14(%ebp),%eax
f010569a:	8b 00                	mov    (%eax),%eax
f010569c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010569f:	99                   	cltd   
f01056a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01056a3:	8b 45 14             	mov    0x14(%ebp),%eax
f01056a6:	8d 40 04             	lea    0x4(%eax),%eax
f01056a9:	89 45 14             	mov    %eax,0x14(%ebp)
f01056ac:	eb b4                	jmp    f0105662 <vprintfmt+0x296>
	if (lflag >= 2)
f01056ae:	83 f9 01             	cmp    $0x1,%ecx
f01056b1:	7f 1e                	jg     f01056d1 <vprintfmt+0x305>
	else if (lflag)
f01056b3:	85 c9                	test   %ecx,%ecx
f01056b5:	74 32                	je     f01056e9 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
f01056b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01056ba:	8b 10                	mov    (%eax),%edx
f01056bc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01056c1:	8d 40 04             	lea    0x4(%eax),%eax
f01056c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01056c7:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
f01056cc:	e9 a3 00 00 00       	jmp    f0105774 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f01056d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01056d4:	8b 10                	mov    (%eax),%edx
f01056d6:	8b 48 04             	mov    0x4(%eax),%ecx
f01056d9:	8d 40 08             	lea    0x8(%eax),%eax
f01056dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01056df:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
f01056e4:	e9 8b 00 00 00       	jmp    f0105774 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f01056e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01056ec:	8b 10                	mov    (%eax),%edx
f01056ee:	b9 00 00 00 00       	mov    $0x0,%ecx
f01056f3:	8d 40 04             	lea    0x4(%eax),%eax
f01056f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01056f9:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
f01056fe:	eb 74                	jmp    f0105774 <vprintfmt+0x3a8>
	if (lflag >= 2)
f0105700:	83 f9 01             	cmp    $0x1,%ecx
f0105703:	7f 1b                	jg     f0105720 <vprintfmt+0x354>
	else if (lflag)
f0105705:	85 c9                	test   %ecx,%ecx
f0105707:	74 2c                	je     f0105735 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
f0105709:	8b 45 14             	mov    0x14(%ebp),%eax
f010570c:	8b 10                	mov    (%eax),%edx
f010570e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105713:	8d 40 04             	lea    0x4(%eax),%eax
f0105716:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0105719:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
f010571e:	eb 54                	jmp    f0105774 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f0105720:	8b 45 14             	mov    0x14(%ebp),%eax
f0105723:	8b 10                	mov    (%eax),%edx
f0105725:	8b 48 04             	mov    0x4(%eax),%ecx
f0105728:	8d 40 08             	lea    0x8(%eax),%eax
f010572b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f010572e:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
f0105733:	eb 3f                	jmp    f0105774 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f0105735:	8b 45 14             	mov    0x14(%ebp),%eax
f0105738:	8b 10                	mov    (%eax),%edx
f010573a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010573f:	8d 40 04             	lea    0x4(%eax),%eax
f0105742:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0105745:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
f010574a:	eb 28                	jmp    f0105774 <vprintfmt+0x3a8>
			putch('0', putdat);
f010574c:	83 ec 08             	sub    $0x8,%esp
f010574f:	53                   	push   %ebx
f0105750:	6a 30                	push   $0x30
f0105752:	ff d6                	call   *%esi
			putch('x', putdat);
f0105754:	83 c4 08             	add    $0x8,%esp
f0105757:	53                   	push   %ebx
f0105758:	6a 78                	push   $0x78
f010575a:	ff d6                	call   *%esi
			num = (unsigned long long)
f010575c:	8b 45 14             	mov    0x14(%ebp),%eax
f010575f:	8b 10                	mov    (%eax),%edx
f0105761:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0105766:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0105769:	8d 40 04             	lea    0x4(%eax),%eax
f010576c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010576f:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
f0105774:	83 ec 0c             	sub    $0xc,%esp
f0105777:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f010577b:	50                   	push   %eax
f010577c:	ff 75 e0             	push   -0x20(%ebp)
f010577f:	57                   	push   %edi
f0105780:	51                   	push   %ecx
f0105781:	52                   	push   %edx
f0105782:	89 da                	mov    %ebx,%edx
f0105784:	89 f0                	mov    %esi,%eax
f0105786:	e8 5e fb ff ff       	call   f01052e9 <printnum>
			break;
f010578b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010578e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105791:	e9 54 fc ff ff       	jmp    f01053ea <vprintfmt+0x1e>
	if (lflag >= 2)
f0105796:	83 f9 01             	cmp    $0x1,%ecx
f0105799:	7f 1b                	jg     f01057b6 <vprintfmt+0x3ea>
	else if (lflag)
f010579b:	85 c9                	test   %ecx,%ecx
f010579d:	74 2c                	je     f01057cb <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
f010579f:	8b 45 14             	mov    0x14(%ebp),%eax
f01057a2:	8b 10                	mov    (%eax),%edx
f01057a4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057a9:	8d 40 04             	lea    0x4(%eax),%eax
f01057ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01057af:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
f01057b4:	eb be                	jmp    f0105774 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f01057b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01057b9:	8b 10                	mov    (%eax),%edx
f01057bb:	8b 48 04             	mov    0x4(%eax),%ecx
f01057be:	8d 40 08             	lea    0x8(%eax),%eax
f01057c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01057c4:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
f01057c9:	eb a9                	jmp    f0105774 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f01057cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01057ce:	8b 10                	mov    (%eax),%edx
f01057d0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057d5:	8d 40 04             	lea    0x4(%eax),%eax
f01057d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01057db:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
f01057e0:	eb 92                	jmp    f0105774 <vprintfmt+0x3a8>
			putch(ch, putdat);
f01057e2:	83 ec 08             	sub    $0x8,%esp
f01057e5:	53                   	push   %ebx
f01057e6:	6a 25                	push   $0x25
f01057e8:	ff d6                	call   *%esi
			break;
f01057ea:	83 c4 10             	add    $0x10,%esp
f01057ed:	eb 9f                	jmp    f010578e <vprintfmt+0x3c2>
			putch('%', putdat);
f01057ef:	83 ec 08             	sub    $0x8,%esp
f01057f2:	53                   	push   %ebx
f01057f3:	6a 25                	push   $0x25
f01057f5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01057f7:	83 c4 10             	add    $0x10,%esp
f01057fa:	89 f8                	mov    %edi,%eax
f01057fc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105800:	74 05                	je     f0105807 <vprintfmt+0x43b>
f0105802:	83 e8 01             	sub    $0x1,%eax
f0105805:	eb f5                	jmp    f01057fc <vprintfmt+0x430>
f0105807:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010580a:	eb 82                	jmp    f010578e <vprintfmt+0x3c2>

f010580c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010580c:	55                   	push   %ebp
f010580d:	89 e5                	mov    %esp,%ebp
f010580f:	83 ec 18             	sub    $0x18,%esp
f0105812:	8b 45 08             	mov    0x8(%ebp),%eax
f0105815:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105818:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010581b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010581f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105822:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105829:	85 c0                	test   %eax,%eax
f010582b:	74 26                	je     f0105853 <vsnprintf+0x47>
f010582d:	85 d2                	test   %edx,%edx
f010582f:	7e 22                	jle    f0105853 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105831:	ff 75 14             	push   0x14(%ebp)
f0105834:	ff 75 10             	push   0x10(%ebp)
f0105837:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010583a:	50                   	push   %eax
f010583b:	68 92 53 10 f0       	push   $0xf0105392
f0105840:	e8 87 fb ff ff       	call   f01053cc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105845:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105848:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010584b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010584e:	83 c4 10             	add    $0x10,%esp
}
f0105851:	c9                   	leave  
f0105852:	c3                   	ret    
		return -E_INVAL;
f0105853:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105858:	eb f7                	jmp    f0105851 <vsnprintf+0x45>

f010585a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010585a:	55                   	push   %ebp
f010585b:	89 e5                	mov    %esp,%ebp
f010585d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105860:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105863:	50                   	push   %eax
f0105864:	ff 75 10             	push   0x10(%ebp)
f0105867:	ff 75 0c             	push   0xc(%ebp)
f010586a:	ff 75 08             	push   0x8(%ebp)
f010586d:	e8 9a ff ff ff       	call   f010580c <vsnprintf>
	va_end(ap);

	return rc;
}
f0105872:	c9                   	leave  
f0105873:	c3                   	ret    

f0105874 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105874:	55                   	push   %ebp
f0105875:	89 e5                	mov    %esp,%ebp
f0105877:	57                   	push   %edi
f0105878:	56                   	push   %esi
f0105879:	53                   	push   %ebx
f010587a:	83 ec 0c             	sub    $0xc,%esp
f010587d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105880:	85 c0                	test   %eax,%eax
f0105882:	74 11                	je     f0105895 <readline+0x21>
		cprintf("%s", prompt);
f0105884:	83 ec 08             	sub    $0x8,%esp
f0105887:	50                   	push   %eax
f0105888:	68 67 75 10 f0       	push   $0xf0107567
f010588d:	e8 3f e2 ff ff       	call   f0103ad1 <cprintf>
f0105892:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105895:	83 ec 0c             	sub    $0xc,%esp
f0105898:	6a 00                	push   $0x0
f010589a:	e8 fd ae ff ff       	call   f010079c <iscons>
f010589f:	89 c7                	mov    %eax,%edi
f01058a1:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01058a4:	be 00 00 00 00       	mov    $0x0,%esi
f01058a9:	eb 4b                	jmp    f01058f6 <readline+0x82>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01058ab:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f01058b0:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01058b3:	75 08                	jne    f01058bd <readline+0x49>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01058b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058b8:	5b                   	pop    %ebx
f01058b9:	5e                   	pop    %esi
f01058ba:	5f                   	pop    %edi
f01058bb:	5d                   	pop    %ebp
f01058bc:	c3                   	ret    
				cprintf("read error: %e\n", c);
f01058bd:	83 ec 08             	sub    $0x8,%esp
f01058c0:	53                   	push   %ebx
f01058c1:	68 3f 8c 10 f0       	push   $0xf0108c3f
f01058c6:	e8 06 e2 ff ff       	call   f0103ad1 <cprintf>
f01058cb:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01058ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01058d3:	eb e0                	jmp    f01058b5 <readline+0x41>
			if (echoing)
f01058d5:	85 ff                	test   %edi,%edi
f01058d7:	75 05                	jne    f01058de <readline+0x6a>
			i--;
f01058d9:	83 ee 01             	sub    $0x1,%esi
f01058dc:	eb 18                	jmp    f01058f6 <readline+0x82>
				cputchar('\b');
f01058de:	83 ec 0c             	sub    $0xc,%esp
f01058e1:	6a 08                	push   $0x8
f01058e3:	e8 93 ae ff ff       	call   f010077b <cputchar>
f01058e8:	83 c4 10             	add    $0x10,%esp
f01058eb:	eb ec                	jmp    f01058d9 <readline+0x65>
			buf[i++] = c;
f01058ed:	88 9e a0 ca 2b f0    	mov    %bl,-0xfd43560(%esi)
f01058f3:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f01058f6:	e8 90 ae ff ff       	call   f010078b <getchar>
f01058fb:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01058fd:	85 c0                	test   %eax,%eax
f01058ff:	78 aa                	js     f01058ab <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105901:	83 f8 08             	cmp    $0x8,%eax
f0105904:	0f 94 c0             	sete   %al
f0105907:	83 fb 7f             	cmp    $0x7f,%ebx
f010590a:	0f 94 c2             	sete   %dl
f010590d:	08 d0                	or     %dl,%al
f010590f:	74 04                	je     f0105915 <readline+0xa1>
f0105911:	85 f6                	test   %esi,%esi
f0105913:	7f c0                	jg     f01058d5 <readline+0x61>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105915:	83 fb 1f             	cmp    $0x1f,%ebx
f0105918:	7e 1a                	jle    f0105934 <readline+0xc0>
f010591a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105920:	7f 12                	jg     f0105934 <readline+0xc0>
			if (echoing)
f0105922:	85 ff                	test   %edi,%edi
f0105924:	74 c7                	je     f01058ed <readline+0x79>
				cputchar(c);
f0105926:	83 ec 0c             	sub    $0xc,%esp
f0105929:	53                   	push   %ebx
f010592a:	e8 4c ae ff ff       	call   f010077b <cputchar>
f010592f:	83 c4 10             	add    $0x10,%esp
f0105932:	eb b9                	jmp    f01058ed <readline+0x79>
		} else if (c == '\n' || c == '\r') {
f0105934:	83 fb 0a             	cmp    $0xa,%ebx
f0105937:	74 05                	je     f010593e <readline+0xca>
f0105939:	83 fb 0d             	cmp    $0xd,%ebx
f010593c:	75 b8                	jne    f01058f6 <readline+0x82>
			if (echoing)
f010593e:	85 ff                	test   %edi,%edi
f0105940:	75 11                	jne    f0105953 <readline+0xdf>
			buf[i] = 0;
f0105942:	c6 86 a0 ca 2b f0 00 	movb   $0x0,-0xfd43560(%esi)
			return buf;
f0105949:	b8 a0 ca 2b f0       	mov    $0xf02bcaa0,%eax
f010594e:	e9 62 ff ff ff       	jmp    f01058b5 <readline+0x41>
				cputchar('\n');
f0105953:	83 ec 0c             	sub    $0xc,%esp
f0105956:	6a 0a                	push   $0xa
f0105958:	e8 1e ae ff ff       	call   f010077b <cputchar>
f010595d:	83 c4 10             	add    $0x10,%esp
f0105960:	eb e0                	jmp    f0105942 <readline+0xce>

f0105962 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105962:	55                   	push   %ebp
f0105963:	89 e5                	mov    %esp,%ebp
f0105965:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105968:	b8 00 00 00 00       	mov    $0x0,%eax
f010596d:	eb 03                	jmp    f0105972 <strlen+0x10>
		n++;
f010596f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0105972:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105976:	75 f7                	jne    f010596f <strlen+0xd>
	return n;
}
f0105978:	5d                   	pop    %ebp
f0105979:	c3                   	ret    

f010597a <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010597a:	55                   	push   %ebp
f010597b:	89 e5                	mov    %esp,%ebp
f010597d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105980:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105983:	b8 00 00 00 00       	mov    $0x0,%eax
f0105988:	eb 03                	jmp    f010598d <strnlen+0x13>
		n++;
f010598a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010598d:	39 d0                	cmp    %edx,%eax
f010598f:	74 08                	je     f0105999 <strnlen+0x1f>
f0105991:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105995:	75 f3                	jne    f010598a <strnlen+0x10>
f0105997:	89 c2                	mov    %eax,%edx
	return n;
}
f0105999:	89 d0                	mov    %edx,%eax
f010599b:	5d                   	pop    %ebp
f010599c:	c3                   	ret    

f010599d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010599d:	55                   	push   %ebp
f010599e:	89 e5                	mov    %esp,%ebp
f01059a0:	53                   	push   %ebx
f01059a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01059a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01059a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01059ac:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01059b0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01059b3:	83 c0 01             	add    $0x1,%eax
f01059b6:	84 d2                	test   %dl,%dl
f01059b8:	75 f2                	jne    f01059ac <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01059ba:	89 c8                	mov    %ecx,%eax
f01059bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01059bf:	c9                   	leave  
f01059c0:	c3                   	ret    

f01059c1 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01059c1:	55                   	push   %ebp
f01059c2:	89 e5                	mov    %esp,%ebp
f01059c4:	53                   	push   %ebx
f01059c5:	83 ec 10             	sub    $0x10,%esp
f01059c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01059cb:	53                   	push   %ebx
f01059cc:	e8 91 ff ff ff       	call   f0105962 <strlen>
f01059d1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01059d4:	ff 75 0c             	push   0xc(%ebp)
f01059d7:	01 d8                	add    %ebx,%eax
f01059d9:	50                   	push   %eax
f01059da:	e8 be ff ff ff       	call   f010599d <strcpy>
	return dst;
}
f01059df:	89 d8                	mov    %ebx,%eax
f01059e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01059e4:	c9                   	leave  
f01059e5:	c3                   	ret    

f01059e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01059e6:	55                   	push   %ebp
f01059e7:	89 e5                	mov    %esp,%ebp
f01059e9:	56                   	push   %esi
f01059ea:	53                   	push   %ebx
f01059eb:	8b 75 08             	mov    0x8(%ebp),%esi
f01059ee:	8b 55 0c             	mov    0xc(%ebp),%edx
f01059f1:	89 f3                	mov    %esi,%ebx
f01059f3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01059f6:	89 f0                	mov    %esi,%eax
f01059f8:	eb 0f                	jmp    f0105a09 <strncpy+0x23>
		*dst++ = *src;
f01059fa:	83 c0 01             	add    $0x1,%eax
f01059fd:	0f b6 0a             	movzbl (%edx),%ecx
f0105a00:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105a03:	80 f9 01             	cmp    $0x1,%cl
f0105a06:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0105a09:	39 d8                	cmp    %ebx,%eax
f0105a0b:	75 ed                	jne    f01059fa <strncpy+0x14>
	}
	return ret;
}
f0105a0d:	89 f0                	mov    %esi,%eax
f0105a0f:	5b                   	pop    %ebx
f0105a10:	5e                   	pop    %esi
f0105a11:	5d                   	pop    %ebp
f0105a12:	c3                   	ret    

f0105a13 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105a13:	55                   	push   %ebp
f0105a14:	89 e5                	mov    %esp,%ebp
f0105a16:	56                   	push   %esi
f0105a17:	53                   	push   %ebx
f0105a18:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105a1e:	8b 55 10             	mov    0x10(%ebp),%edx
f0105a21:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105a23:	85 d2                	test   %edx,%edx
f0105a25:	74 21                	je     f0105a48 <strlcpy+0x35>
f0105a27:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105a2b:	89 f2                	mov    %esi,%edx
f0105a2d:	eb 09                	jmp    f0105a38 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105a2f:	83 c1 01             	add    $0x1,%ecx
f0105a32:	83 c2 01             	add    $0x1,%edx
f0105a35:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0105a38:	39 c2                	cmp    %eax,%edx
f0105a3a:	74 09                	je     f0105a45 <strlcpy+0x32>
f0105a3c:	0f b6 19             	movzbl (%ecx),%ebx
f0105a3f:	84 db                	test   %bl,%bl
f0105a41:	75 ec                	jne    f0105a2f <strlcpy+0x1c>
f0105a43:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0105a45:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105a48:	29 f0                	sub    %esi,%eax
}
f0105a4a:	5b                   	pop    %ebx
f0105a4b:	5e                   	pop    %esi
f0105a4c:	5d                   	pop    %ebp
f0105a4d:	c3                   	ret    

f0105a4e <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105a4e:	55                   	push   %ebp
f0105a4f:	89 e5                	mov    %esp,%ebp
f0105a51:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a54:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105a57:	eb 06                	jmp    f0105a5f <strcmp+0x11>
		p++, q++;
f0105a59:	83 c1 01             	add    $0x1,%ecx
f0105a5c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105a5f:	0f b6 01             	movzbl (%ecx),%eax
f0105a62:	84 c0                	test   %al,%al
f0105a64:	74 04                	je     f0105a6a <strcmp+0x1c>
f0105a66:	3a 02                	cmp    (%edx),%al
f0105a68:	74 ef                	je     f0105a59 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105a6a:	0f b6 c0             	movzbl %al,%eax
f0105a6d:	0f b6 12             	movzbl (%edx),%edx
f0105a70:	29 d0                	sub    %edx,%eax
}
f0105a72:	5d                   	pop    %ebp
f0105a73:	c3                   	ret    

f0105a74 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105a74:	55                   	push   %ebp
f0105a75:	89 e5                	mov    %esp,%ebp
f0105a77:	53                   	push   %ebx
f0105a78:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a7b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105a7e:	89 c3                	mov    %eax,%ebx
f0105a80:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105a83:	eb 06                	jmp    f0105a8b <strncmp+0x17>
		n--, p++, q++;
f0105a85:	83 c0 01             	add    $0x1,%eax
f0105a88:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105a8b:	39 d8                	cmp    %ebx,%eax
f0105a8d:	74 18                	je     f0105aa7 <strncmp+0x33>
f0105a8f:	0f b6 08             	movzbl (%eax),%ecx
f0105a92:	84 c9                	test   %cl,%cl
f0105a94:	74 04                	je     f0105a9a <strncmp+0x26>
f0105a96:	3a 0a                	cmp    (%edx),%cl
f0105a98:	74 eb                	je     f0105a85 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105a9a:	0f b6 00             	movzbl (%eax),%eax
f0105a9d:	0f b6 12             	movzbl (%edx),%edx
f0105aa0:	29 d0                	sub    %edx,%eax
}
f0105aa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105aa5:	c9                   	leave  
f0105aa6:	c3                   	ret    
		return 0;
f0105aa7:	b8 00 00 00 00       	mov    $0x0,%eax
f0105aac:	eb f4                	jmp    f0105aa2 <strncmp+0x2e>

f0105aae <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105aae:	55                   	push   %ebp
f0105aaf:	89 e5                	mov    %esp,%ebp
f0105ab1:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ab4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105ab8:	eb 03                	jmp    f0105abd <strchr+0xf>
f0105aba:	83 c0 01             	add    $0x1,%eax
f0105abd:	0f b6 10             	movzbl (%eax),%edx
f0105ac0:	84 d2                	test   %dl,%dl
f0105ac2:	74 06                	je     f0105aca <strchr+0x1c>
		if (*s == c)
f0105ac4:	38 ca                	cmp    %cl,%dl
f0105ac6:	75 f2                	jne    f0105aba <strchr+0xc>
f0105ac8:	eb 05                	jmp    f0105acf <strchr+0x21>
			return (char *) s;
	return 0;
f0105aca:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105acf:	5d                   	pop    %ebp
f0105ad0:	c3                   	ret    

f0105ad1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105ad1:	55                   	push   %ebp
f0105ad2:	89 e5                	mov    %esp,%ebp
f0105ad4:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ad7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105adb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105ade:	38 ca                	cmp    %cl,%dl
f0105ae0:	74 09                	je     f0105aeb <strfind+0x1a>
f0105ae2:	84 d2                	test   %dl,%dl
f0105ae4:	74 05                	je     f0105aeb <strfind+0x1a>
	for (; *s; s++)
f0105ae6:	83 c0 01             	add    $0x1,%eax
f0105ae9:	eb f0                	jmp    f0105adb <strfind+0xa>
			break;
	return (char *) s;
}
f0105aeb:	5d                   	pop    %ebp
f0105aec:	c3                   	ret    

f0105aed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105aed:	55                   	push   %ebp
f0105aee:	89 e5                	mov    %esp,%ebp
f0105af0:	57                   	push   %edi
f0105af1:	56                   	push   %esi
f0105af2:	53                   	push   %ebx
f0105af3:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105af6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105af9:	85 c9                	test   %ecx,%ecx
f0105afb:	74 2f                	je     f0105b2c <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105afd:	89 f8                	mov    %edi,%eax
f0105aff:	09 c8                	or     %ecx,%eax
f0105b01:	a8 03                	test   $0x3,%al
f0105b03:	75 21                	jne    f0105b26 <memset+0x39>
		c &= 0xFF;
f0105b05:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105b09:	89 d0                	mov    %edx,%eax
f0105b0b:	c1 e0 08             	shl    $0x8,%eax
f0105b0e:	89 d3                	mov    %edx,%ebx
f0105b10:	c1 e3 18             	shl    $0x18,%ebx
f0105b13:	89 d6                	mov    %edx,%esi
f0105b15:	c1 e6 10             	shl    $0x10,%esi
f0105b18:	09 f3                	or     %esi,%ebx
f0105b1a:	09 da                	or     %ebx,%edx
f0105b1c:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105b1e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105b21:	fc                   	cld    
f0105b22:	f3 ab                	rep stos %eax,%es:(%edi)
f0105b24:	eb 06                	jmp    f0105b2c <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105b26:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b29:	fc                   	cld    
f0105b2a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105b2c:	89 f8                	mov    %edi,%eax
f0105b2e:	5b                   	pop    %ebx
f0105b2f:	5e                   	pop    %esi
f0105b30:	5f                   	pop    %edi
f0105b31:	5d                   	pop    %ebp
f0105b32:	c3                   	ret    

f0105b33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105b33:	55                   	push   %ebp
f0105b34:	89 e5                	mov    %esp,%ebp
f0105b36:	57                   	push   %edi
f0105b37:	56                   	push   %esi
f0105b38:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b3b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105b3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105b41:	39 c6                	cmp    %eax,%esi
f0105b43:	73 32                	jae    f0105b77 <memmove+0x44>
f0105b45:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105b48:	39 c2                	cmp    %eax,%edx
f0105b4a:	76 2b                	jbe    f0105b77 <memmove+0x44>
		s += n;
		d += n;
f0105b4c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105b4f:	89 d6                	mov    %edx,%esi
f0105b51:	09 fe                	or     %edi,%esi
f0105b53:	09 ce                	or     %ecx,%esi
f0105b55:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105b5b:	75 0e                	jne    f0105b6b <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105b5d:	83 ef 04             	sub    $0x4,%edi
f0105b60:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105b63:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105b66:	fd                   	std    
f0105b67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105b69:	eb 09                	jmp    f0105b74 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105b6b:	83 ef 01             	sub    $0x1,%edi
f0105b6e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105b71:	fd                   	std    
f0105b72:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105b74:	fc                   	cld    
f0105b75:	eb 1a                	jmp    f0105b91 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105b77:	89 f2                	mov    %esi,%edx
f0105b79:	09 c2                	or     %eax,%edx
f0105b7b:	09 ca                	or     %ecx,%edx
f0105b7d:	f6 c2 03             	test   $0x3,%dl
f0105b80:	75 0a                	jne    f0105b8c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105b82:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105b85:	89 c7                	mov    %eax,%edi
f0105b87:	fc                   	cld    
f0105b88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105b8a:	eb 05                	jmp    f0105b91 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0105b8c:	89 c7                	mov    %eax,%edi
f0105b8e:	fc                   	cld    
f0105b8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105b91:	5e                   	pop    %esi
f0105b92:	5f                   	pop    %edi
f0105b93:	5d                   	pop    %ebp
f0105b94:	c3                   	ret    

f0105b95 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105b95:	55                   	push   %ebp
f0105b96:	89 e5                	mov    %esp,%ebp
f0105b98:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105b9b:	ff 75 10             	push   0x10(%ebp)
f0105b9e:	ff 75 0c             	push   0xc(%ebp)
f0105ba1:	ff 75 08             	push   0x8(%ebp)
f0105ba4:	e8 8a ff ff ff       	call   f0105b33 <memmove>
}
f0105ba9:	c9                   	leave  
f0105baa:	c3                   	ret    

f0105bab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105bab:	55                   	push   %ebp
f0105bac:	89 e5                	mov    %esp,%ebp
f0105bae:	56                   	push   %esi
f0105baf:	53                   	push   %ebx
f0105bb0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105bb6:	89 c6                	mov    %eax,%esi
f0105bb8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105bbb:	eb 06                	jmp    f0105bc3 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105bbd:	83 c0 01             	add    $0x1,%eax
f0105bc0:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0105bc3:	39 f0                	cmp    %esi,%eax
f0105bc5:	74 14                	je     f0105bdb <memcmp+0x30>
		if (*s1 != *s2)
f0105bc7:	0f b6 08             	movzbl (%eax),%ecx
f0105bca:	0f b6 1a             	movzbl (%edx),%ebx
f0105bcd:	38 d9                	cmp    %bl,%cl
f0105bcf:	74 ec                	je     f0105bbd <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0105bd1:	0f b6 c1             	movzbl %cl,%eax
f0105bd4:	0f b6 db             	movzbl %bl,%ebx
f0105bd7:	29 d8                	sub    %ebx,%eax
f0105bd9:	eb 05                	jmp    f0105be0 <memcmp+0x35>
	}

	return 0;
f0105bdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105be0:	5b                   	pop    %ebx
f0105be1:	5e                   	pop    %esi
f0105be2:	5d                   	pop    %ebp
f0105be3:	c3                   	ret    

f0105be4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105be4:	55                   	push   %ebp
f0105be5:	89 e5                	mov    %esp,%ebp
f0105be7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105bed:	89 c2                	mov    %eax,%edx
f0105bef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105bf2:	eb 03                	jmp    f0105bf7 <memfind+0x13>
f0105bf4:	83 c0 01             	add    $0x1,%eax
f0105bf7:	39 d0                	cmp    %edx,%eax
f0105bf9:	73 04                	jae    f0105bff <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105bfb:	38 08                	cmp    %cl,(%eax)
f0105bfd:	75 f5                	jne    f0105bf4 <memfind+0x10>
			break;
	return (void *) s;
}
f0105bff:	5d                   	pop    %ebp
f0105c00:	c3                   	ret    

f0105c01 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105c01:	55                   	push   %ebp
f0105c02:	89 e5                	mov    %esp,%ebp
f0105c04:	57                   	push   %edi
f0105c05:	56                   	push   %esi
f0105c06:	53                   	push   %ebx
f0105c07:	8b 55 08             	mov    0x8(%ebp),%edx
f0105c0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105c0d:	eb 03                	jmp    f0105c12 <strtol+0x11>
		s++;
f0105c0f:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0105c12:	0f b6 02             	movzbl (%edx),%eax
f0105c15:	3c 20                	cmp    $0x20,%al
f0105c17:	74 f6                	je     f0105c0f <strtol+0xe>
f0105c19:	3c 09                	cmp    $0x9,%al
f0105c1b:	74 f2                	je     f0105c0f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105c1d:	3c 2b                	cmp    $0x2b,%al
f0105c1f:	74 2a                	je     f0105c4b <strtol+0x4a>
	int neg = 0;
f0105c21:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105c26:	3c 2d                	cmp    $0x2d,%al
f0105c28:	74 2b                	je     f0105c55 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105c2a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105c30:	75 0f                	jne    f0105c41 <strtol+0x40>
f0105c32:	80 3a 30             	cmpb   $0x30,(%edx)
f0105c35:	74 28                	je     f0105c5f <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105c37:	85 db                	test   %ebx,%ebx
f0105c39:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105c3e:	0f 44 d8             	cmove  %eax,%ebx
f0105c41:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c46:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105c49:	eb 46                	jmp    f0105c91 <strtol+0x90>
		s++;
f0105c4b:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0105c4e:	bf 00 00 00 00       	mov    $0x0,%edi
f0105c53:	eb d5                	jmp    f0105c2a <strtol+0x29>
		s++, neg = 1;
f0105c55:	83 c2 01             	add    $0x1,%edx
f0105c58:	bf 01 00 00 00       	mov    $0x1,%edi
f0105c5d:	eb cb                	jmp    f0105c2a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105c5f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105c63:	74 0e                	je     f0105c73 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0105c65:	85 db                	test   %ebx,%ebx
f0105c67:	75 d8                	jne    f0105c41 <strtol+0x40>
		s++, base = 8;
f0105c69:	83 c2 01             	add    $0x1,%edx
f0105c6c:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105c71:	eb ce                	jmp    f0105c41 <strtol+0x40>
		s += 2, base = 16;
f0105c73:	83 c2 02             	add    $0x2,%edx
f0105c76:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105c7b:	eb c4                	jmp    f0105c41 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105c7d:	0f be c0             	movsbl %al,%eax
f0105c80:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105c83:	3b 45 10             	cmp    0x10(%ebp),%eax
f0105c86:	7d 3a                	jge    f0105cc2 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105c88:	83 c2 01             	add    $0x1,%edx
f0105c8b:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0105c8f:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0105c91:	0f b6 02             	movzbl (%edx),%eax
f0105c94:	8d 70 d0             	lea    -0x30(%eax),%esi
f0105c97:	89 f3                	mov    %esi,%ebx
f0105c99:	80 fb 09             	cmp    $0x9,%bl
f0105c9c:	76 df                	jbe    f0105c7d <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0105c9e:	8d 70 9f             	lea    -0x61(%eax),%esi
f0105ca1:	89 f3                	mov    %esi,%ebx
f0105ca3:	80 fb 19             	cmp    $0x19,%bl
f0105ca6:	77 08                	ja     f0105cb0 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0105ca8:	0f be c0             	movsbl %al,%eax
f0105cab:	83 e8 57             	sub    $0x57,%eax
f0105cae:	eb d3                	jmp    f0105c83 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0105cb0:	8d 70 bf             	lea    -0x41(%eax),%esi
f0105cb3:	89 f3                	mov    %esi,%ebx
f0105cb5:	80 fb 19             	cmp    $0x19,%bl
f0105cb8:	77 08                	ja     f0105cc2 <strtol+0xc1>
			dig = *s - 'A' + 10;
f0105cba:	0f be c0             	movsbl %al,%eax
f0105cbd:	83 e8 37             	sub    $0x37,%eax
f0105cc0:	eb c1                	jmp    f0105c83 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105cc2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105cc6:	74 05                	je     f0105ccd <strtol+0xcc>
		*endptr = (char *) s;
f0105cc8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ccb:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0105ccd:	89 c8                	mov    %ecx,%eax
f0105ccf:	f7 d8                	neg    %eax
f0105cd1:	85 ff                	test   %edi,%edi
f0105cd3:	0f 45 c8             	cmovne %eax,%ecx
}
f0105cd6:	89 c8                	mov    %ecx,%eax
f0105cd8:	5b                   	pop    %ebx
f0105cd9:	5e                   	pop    %esi
f0105cda:	5f                   	pop    %edi
f0105cdb:	5d                   	pop    %ebp
f0105cdc:	c3                   	ret    
f0105cdd:	66 90                	xchg   %ax,%ax
f0105cdf:	90                   	nop

f0105ce0 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105ce0:	fa                   	cli    

	xorw    %ax, %ax
f0105ce1:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105ce3:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105ce5:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105ce7:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105ce9:	0f 01 16             	lgdtl  (%esi)
f0105cec:	74 70                	je     f0105d5e <mpsearch1+0x3>
	movl    %cr0, %eax
f0105cee:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105cf1:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105cf5:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105cf8:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105cfe:	08 00                	or     %al,(%eax)

f0105d00 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105d00:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105d04:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105d06:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105d08:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105d0a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105d0e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105d10:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105d12:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl    %eax, %cr3
f0105d17:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105d1a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105d1d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105d22:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105d25:	8b 25 04 c0 2b f0    	mov    0xf02bc004,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105d2b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105d30:	b8 b3 01 10 f0       	mov    $0xf01001b3,%eax
	call    *%eax
f0105d35:	ff d0                	call   *%eax

f0105d37 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105d37:	eb fe                	jmp    f0105d37 <spin>
f0105d39:	8d 76 00             	lea    0x0(%esi),%esi

f0105d3c <gdt>:
	...
f0105d44:	ff                   	(bad)  
f0105d45:	ff 00                	incl   (%eax)
f0105d47:	00 00                	add    %al,(%eax)
f0105d49:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105d50:	00                   	.byte 0x0
f0105d51:	92                   	xchg   %eax,%edx
f0105d52:	cf                   	iret   
	...

f0105d54 <gdtdesc>:
f0105d54:	17                   	pop    %ss
f0105d55:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105d5a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105d5a:	90                   	nop

f0105d5b <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105d5b:	55                   	push   %ebp
f0105d5c:	89 e5                	mov    %esp,%ebp
f0105d5e:	57                   	push   %edi
f0105d5f:	56                   	push   %esi
f0105d60:	53                   	push   %ebx
f0105d61:	83 ec 1c             	sub    $0x1c,%esp
f0105d64:	89 c6                	mov    %eax,%esi
	if (PGNUM(pa) >= npages)
f0105d66:	8b 0d 60 c2 2b f0    	mov    0xf02bc260,%ecx
f0105d6c:	c1 e8 0c             	shr    $0xc,%eax
f0105d6f:	39 c8                	cmp    %ecx,%eax
f0105d71:	73 22                	jae    f0105d95 <mpsearch1+0x3a>
	return (void *)(pa + KERNBASE);
f0105d73:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105d79:	8d 04 32             	lea    (%edx,%esi,1),%eax
	if (PGNUM(pa) >= npages)
f0105d7c:	89 c2                	mov    %eax,%edx
f0105d7e:	c1 ea 0c             	shr    $0xc,%edx
f0105d81:	39 ca                	cmp    %ecx,%edx
f0105d83:	73 22                	jae    f0105da7 <mpsearch1+0x4c>
	return (void *)(pa + KERNBASE);
f0105d85:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0105d8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105d8d:	81 ee f0 ff ff 0f    	sub    $0xffffff0,%esi

	for (; mp < end; mp++)
f0105d93:	eb 2a                	jmp    f0105dbf <mpsearch1+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d95:	56                   	push   %esi
f0105d96:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0105d9b:	6a 58                	push   $0x58
f0105d9d:	68 dd 8d 10 f0       	push   $0xf0108ddd
f0105da2:	e8 99 a2 ff ff       	call   f0100040 <_panic>
f0105da7:	50                   	push   %eax
f0105da8:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0105dad:	6a 58                	push   $0x58
f0105daf:	68 dd 8d 10 f0       	push   $0xf0108ddd
f0105db4:	e8 87 a2 ff ff       	call   f0100040 <_panic>
f0105db9:	83 c7 10             	add    $0x10,%edi
f0105dbc:	83 c6 10             	add    $0x10,%esi
f0105dbf:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0105dc2:	73 2b                	jae    f0105def <mpsearch1+0x94>
f0105dc4:	89 fb                	mov    %edi,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105dc6:	83 ec 04             	sub    $0x4,%esp
f0105dc9:	6a 04                	push   $0x4
f0105dcb:	68 ed 8d 10 f0       	push   $0xf0108ded
f0105dd0:	57                   	push   %edi
f0105dd1:	e8 d5 fd ff ff       	call   f0105bab <memcmp>
f0105dd6:	83 c4 10             	add    $0x10,%esp
f0105dd9:	85 c0                	test   %eax,%eax
f0105ddb:	75 dc                	jne    f0105db9 <mpsearch1+0x5e>
		sum += ((uint8_t *)addr)[i];
f0105ddd:	0f b6 13             	movzbl (%ebx),%edx
f0105de0:	01 d0                	add    %edx,%eax
	for (i = 0; i < len; i++)
f0105de2:	83 c3 01             	add    $0x1,%ebx
f0105de5:	39 f3                	cmp    %esi,%ebx
f0105de7:	75 f4                	jne    f0105ddd <mpsearch1+0x82>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105de9:	84 c0                	test   %al,%al
f0105deb:	75 cc                	jne    f0105db9 <mpsearch1+0x5e>
f0105ded:	eb 05                	jmp    f0105df4 <mpsearch1+0x99>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105def:	bf 00 00 00 00       	mov    $0x0,%edi
}
f0105df4:	89 f8                	mov    %edi,%eax
f0105df6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105df9:	5b                   	pop    %ebx
f0105dfa:	5e                   	pop    %esi
f0105dfb:	5f                   	pop    %edi
f0105dfc:	5d                   	pop    %ebp
f0105dfd:	c3                   	ret    

f0105dfe <mp_init>:
}

//通过读取位于BIOS内存区域中的MP配置表来获取该信息。
void
mp_init(void)
{
f0105dfe:	55                   	push   %ebp
f0105dff:	89 e5                	mov    %esp,%ebp
f0105e01:	57                   	push   %edi
f0105e02:	56                   	push   %esi
f0105e03:	53                   	push   %ebx
f0105e04:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105e07:	c7 05 08 d0 2f f0 20 	movl   $0xf02fd020,0xf02fd008
f0105e0e:	d0 2f f0 
	if (PGNUM(pa) >= npages)
f0105e11:	83 3d 60 c2 2b f0 00 	cmpl   $0x0,0xf02bc260
f0105e18:	0f 84 86 00 00 00    	je     f0105ea4 <mp_init+0xa6>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105e1e:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105e25:	85 c0                	test   %eax,%eax
f0105e27:	0f 84 8d 00 00 00    	je     f0105eba <mp_init+0xbc>
		p <<= 4;	// Translate from segment to PA
f0105e2d:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105e30:	ba 00 04 00 00       	mov    $0x400,%edx
f0105e35:	e8 21 ff ff ff       	call   f0105d5b <mpsearch1>
f0105e3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105e3d:	85 c0                	test   %eax,%eax
f0105e3f:	75 1a                	jne    f0105e5b <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f0105e41:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e46:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105e4b:	e8 0b ff ff ff       	call   f0105d5b <mpsearch1>
f0105e50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0105e53:	85 c0                	test   %eax,%eax
f0105e55:	0f 84 20 02 00 00    	je     f010607b <mp_init+0x27d>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105e5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e5e:	8b 58 04             	mov    0x4(%eax),%ebx
f0105e61:	85 db                	test   %ebx,%ebx
f0105e63:	74 7a                	je     f0105edf <mp_init+0xe1>
f0105e65:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105e69:	75 74                	jne    f0105edf <mp_init+0xe1>
f0105e6b:	89 d8                	mov    %ebx,%eax
f0105e6d:	c1 e8 0c             	shr    $0xc,%eax
f0105e70:	3b 05 60 c2 2b f0    	cmp    0xf02bc260,%eax
f0105e76:	73 7c                	jae    f0105ef4 <mp_init+0xf6>
	return (void *)(pa + KERNBASE);
f0105e78:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0105e7e:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105e80:	83 ec 04             	sub    $0x4,%esp
f0105e83:	6a 04                	push   $0x4
f0105e85:	68 f2 8d 10 f0       	push   $0xf0108df2
f0105e8a:	53                   	push   %ebx
f0105e8b:	e8 1b fd ff ff       	call   f0105bab <memcmp>
f0105e90:	83 c4 10             	add    $0x10,%esp
f0105e93:	85 c0                	test   %eax,%eax
f0105e95:	75 72                	jne    f0105f09 <mp_init+0x10b>
f0105e97:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105e9b:	01 df                	add    %ebx,%edi
	sum = 0;
f0105e9d:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0105e9f:	e9 82 00 00 00       	jmp    f0105f26 <mp_init+0x128>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ea4:	68 00 04 00 00       	push   $0x400
f0105ea9:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0105eae:	6a 70                	push   $0x70
f0105eb0:	68 dd 8d 10 f0       	push   $0xf0108ddd
f0105eb5:	e8 86 a1 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105eba:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105ec1:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105ec4:	2d 00 04 00 00       	sub    $0x400,%eax
f0105ec9:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ece:	e8 88 fe ff ff       	call   f0105d5b <mpsearch1>
f0105ed3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ed6:	85 c0                	test   %eax,%eax
f0105ed8:	75 81                	jne    f0105e5b <mp_init+0x5d>
f0105eda:	e9 62 ff ff ff       	jmp    f0105e41 <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f0105edf:	83 ec 0c             	sub    $0xc,%esp
f0105ee2:	68 50 8c 10 f0       	push   $0xf0108c50
f0105ee7:	e8 e5 db ff ff       	call   f0103ad1 <cprintf>
		return NULL;
f0105eec:	83 c4 10             	add    $0x10,%esp
f0105eef:	e9 87 01 00 00       	jmp    f010607b <mp_init+0x27d>
f0105ef4:	53                   	push   %ebx
f0105ef5:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0105efa:	68 91 00 00 00       	push   $0x91
f0105eff:	68 dd 8d 10 f0       	push   $0xf0108ddd
f0105f04:	e8 37 a1 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105f09:	83 ec 0c             	sub    $0xc,%esp
f0105f0c:	68 80 8c 10 f0       	push   $0xf0108c80
f0105f11:	e8 bb db ff ff       	call   f0103ad1 <cprintf>
		return NULL;
f0105f16:	83 c4 10             	add    $0x10,%esp
f0105f19:	e9 5d 01 00 00       	jmp    f010607b <mp_init+0x27d>
		sum += ((uint8_t *)addr)[i];
f0105f1e:	0f b6 0b             	movzbl (%ebx),%ecx
f0105f21:	01 ca                	add    %ecx,%edx
f0105f23:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105f26:	39 fb                	cmp    %edi,%ebx
f0105f28:	75 f4                	jne    f0105f1e <mp_init+0x120>
	if (sum(conf, conf->length) != 0) {
f0105f2a:	84 d2                	test   %dl,%dl
f0105f2c:	75 16                	jne    f0105f44 <mp_init+0x146>
	if (conf->version != 1 && conf->version != 4) {
f0105f2e:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105f32:	80 fa 01             	cmp    $0x1,%dl
f0105f35:	74 05                	je     f0105f3c <mp_init+0x13e>
f0105f37:	80 fa 04             	cmp    $0x4,%dl
f0105f3a:	75 1d                	jne    f0105f59 <mp_init+0x15b>
f0105f3c:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0105f40:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f0105f42:	eb 36                	jmp    f0105f7a <mp_init+0x17c>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105f44:	83 ec 0c             	sub    $0xc,%esp
f0105f47:	68 b4 8c 10 f0       	push   $0xf0108cb4
f0105f4c:	e8 80 db ff ff       	call   f0103ad1 <cprintf>
		return NULL;
f0105f51:	83 c4 10             	add    $0x10,%esp
f0105f54:	e9 22 01 00 00       	jmp    f010607b <mp_init+0x27d>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105f59:	83 ec 08             	sub    $0x8,%esp
f0105f5c:	0f b6 d2             	movzbl %dl,%edx
f0105f5f:	52                   	push   %edx
f0105f60:	68 d8 8c 10 f0       	push   $0xf0108cd8
f0105f65:	e8 67 db ff ff       	call   f0103ad1 <cprintf>
		return NULL;
f0105f6a:	83 c4 10             	add    $0x10,%esp
f0105f6d:	e9 09 01 00 00       	jmp    f010607b <mp_init+0x27d>
		sum += ((uint8_t *)addr)[i];
f0105f72:	0f b6 13             	movzbl (%ebx),%edx
f0105f75:	01 d0                	add    %edx,%eax
f0105f77:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105f7a:	39 d9                	cmp    %ebx,%ecx
f0105f7c:	75 f4                	jne    f0105f72 <mp_init+0x174>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105f7e:	02 46 2a             	add    0x2a(%esi),%al
f0105f81:	75 1c                	jne    f0105f9f <mp_init+0x1a1>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f0105f83:	c7 05 04 d0 2f f0 01 	movl   $0x1,0xf02fd004
f0105f8a:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105f8d:	8b 46 24             	mov    0x24(%esi),%eax
f0105f90:	a3 c4 d3 2f f0       	mov    %eax,0xf02fd3c4

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105f95:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105f98:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105f9d:	eb 4d                	jmp    f0105fec <mp_init+0x1ee>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105f9f:	83 ec 0c             	sub    $0xc,%esp
f0105fa2:	68 f8 8c 10 f0       	push   $0xf0108cf8
f0105fa7:	e8 25 db ff ff       	call   f0103ad1 <cprintf>
		return NULL;
f0105fac:	83 c4 10             	add    $0x10,%esp
f0105faf:	e9 c7 00 00 00       	jmp    f010607b <mp_init+0x27d>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105fb4:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105fb8:	74 11                	je     f0105fcb <mp_init+0x1cd>
				bootcpu = &cpus[ncpu];
f0105fba:	6b 05 00 d0 2f f0 74 	imul   $0x74,0xf02fd000,%eax
f0105fc1:	05 20 d0 2f f0       	add    $0xf02fd020,%eax
f0105fc6:	a3 08 d0 2f f0       	mov    %eax,0xf02fd008
			if (ncpu < NCPU) {
f0105fcb:	a1 00 d0 2f f0       	mov    0xf02fd000,%eax
f0105fd0:	83 f8 07             	cmp    $0x7,%eax
f0105fd3:	7f 33                	jg     f0106008 <mp_init+0x20a>
				cpus[ncpu].cpu_id = ncpu;
f0105fd5:	6b d0 74             	imul   $0x74,%eax,%edx
f0105fd8:	88 82 20 d0 2f f0    	mov    %al,-0xfd02fe0(%edx)
				ncpu++;
f0105fde:	83 c0 01             	add    $0x1,%eax
f0105fe1:	a3 00 d0 2f f0       	mov    %eax,0xf02fd000
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105fe6:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105fe9:	83 c3 01             	add    $0x1,%ebx
f0105fec:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105ff0:	39 d8                	cmp    %ebx,%eax
f0105ff2:	76 4f                	jbe    f0106043 <mp_init+0x245>
		switch (*p) {
f0105ff4:	0f b6 07             	movzbl (%edi),%eax
f0105ff7:	84 c0                	test   %al,%al
f0105ff9:	74 b9                	je     f0105fb4 <mp_init+0x1b6>
f0105ffb:	8d 50 ff             	lea    -0x1(%eax),%edx
f0105ffe:	80 fa 03             	cmp    $0x3,%dl
f0106001:	77 1c                	ja     f010601f <mp_init+0x221>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106003:	83 c7 08             	add    $0x8,%edi
			continue;
f0106006:	eb e1                	jmp    f0105fe9 <mp_init+0x1eb>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106008:	83 ec 08             	sub    $0x8,%esp
f010600b:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f010600f:	50                   	push   %eax
f0106010:	68 28 8d 10 f0       	push   $0xf0108d28
f0106015:	e8 b7 da ff ff       	call   f0103ad1 <cprintf>
f010601a:	83 c4 10             	add    $0x10,%esp
f010601d:	eb c7                	jmp    f0105fe6 <mp_init+0x1e8>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010601f:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0106022:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0106025:	50                   	push   %eax
f0106026:	68 50 8d 10 f0       	push   $0xf0108d50
f010602b:	e8 a1 da ff ff       	call   f0103ad1 <cprintf>
			ismp = 0;
f0106030:	c7 05 04 d0 2f f0 00 	movl   $0x0,0xf02fd004
f0106037:	00 00 00 
			i = conf->entry;
f010603a:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f010603e:	83 c4 10             	add    $0x10,%esp
f0106041:	eb a6                	jmp    f0105fe9 <mp_init+0x1eb>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106043:	a1 08 d0 2f f0       	mov    0xf02fd008,%eax
f0106048:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010604f:	83 3d 04 d0 2f f0 00 	cmpl   $0x0,0xf02fd004
f0106056:	74 2b                	je     f0106083 <mp_init+0x285>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106058:	83 ec 04             	sub    $0x4,%esp
f010605b:	ff 35 00 d0 2f f0    	push   0xf02fd000
f0106061:	0f b6 00             	movzbl (%eax),%eax
f0106064:	50                   	push   %eax
f0106065:	68 f7 8d 10 f0       	push   $0xf0108df7
f010606a:	e8 62 da ff ff       	call   f0103ad1 <cprintf>

	if (mp->imcrp) {
f010606f:	83 c4 10             	add    $0x10,%esp
f0106072:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106075:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106079:	75 2e                	jne    f01060a9 <mp_init+0x2ab>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f010607b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010607e:	5b                   	pop    %ebx
f010607f:	5e                   	pop    %esi
f0106080:	5f                   	pop    %edi
f0106081:	5d                   	pop    %ebp
f0106082:	c3                   	ret    
		ncpu = 1;
f0106083:	c7 05 00 d0 2f f0 01 	movl   $0x1,0xf02fd000
f010608a:	00 00 00 
		lapicaddr = 0;
f010608d:	c7 05 c4 d3 2f f0 00 	movl   $0x0,0xf02fd3c4
f0106094:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106097:	83 ec 0c             	sub    $0xc,%esp
f010609a:	68 70 8d 10 f0       	push   $0xf0108d70
f010609f:	e8 2d da ff ff       	call   f0103ad1 <cprintf>
		return;
f01060a4:	83 c4 10             	add    $0x10,%esp
f01060a7:	eb d2                	jmp    f010607b <mp_init+0x27d>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01060a9:	83 ec 0c             	sub    $0xc,%esp
f01060ac:	68 9c 8d 10 f0       	push   $0xf0108d9c
f01060b1:	e8 1b da ff ff       	call   f0103ad1 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01060b6:	b8 70 00 00 00       	mov    $0x70,%eax
f01060bb:	ba 22 00 00 00       	mov    $0x22,%edx
f01060c0:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01060c1:	ba 23 00 00 00       	mov    $0x23,%edx
f01060c6:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01060c7:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01060ca:	ee                   	out    %al,(%dx)
}
f01060cb:	83 c4 10             	add    $0x10,%esp
f01060ce:	eb ab                	jmp    f010607b <mp_init+0x27d>

f01060d0 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f01060d0:	8b 0d c0 d3 2f f0    	mov    0xf02fd3c0,%ecx
f01060d6:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01060d9:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01060db:	a1 c0 d3 2f f0       	mov    0xf02fd3c0,%eax
f01060e0:	8b 40 20             	mov    0x20(%eax),%eax
}
f01060e3:	c3                   	ret    

f01060e4 <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f01060e4:	8b 15 c0 d3 2f f0    	mov    0xf02fd3c0,%edx
		return lapic[ID] >> 24;
	return 0;
f01060ea:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f01060ef:	85 d2                	test   %edx,%edx
f01060f1:	74 06                	je     f01060f9 <cpunum+0x15>
		return lapic[ID] >> 24;
f01060f3:	8b 42 20             	mov    0x20(%edx),%eax
f01060f6:	c1 e8 18             	shr    $0x18,%eax
}
f01060f9:	c3                   	ret    

f01060fa <lapic_init>:
	if (!lapicaddr)
f01060fa:	a1 c4 d3 2f f0       	mov    0xf02fd3c4,%eax
f01060ff:	85 c0                	test   %eax,%eax
f0106101:	75 01                	jne    f0106104 <lapic_init+0xa>
f0106103:	c3                   	ret    
{
f0106104:	55                   	push   %ebp
f0106105:	89 e5                	mov    %esp,%ebp
f0106107:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f010610a:	68 00 10 00 00       	push   $0x1000
f010610f:	50                   	push   %eax
f0106110:	e8 a6 b1 ff ff       	call   f01012bb <mmio_map_region>
f0106115:	a3 c0 d3 2f f0       	mov    %eax,0xf02fd3c0
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010611a:	ba 27 01 00 00       	mov    $0x127,%edx
f010611f:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106124:	e8 a7 ff ff ff       	call   f01060d0 <lapicw>
	lapicw(TDCR, X1);
f0106129:	ba 0b 00 00 00       	mov    $0xb,%edx
f010612e:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106133:	e8 98 ff ff ff       	call   f01060d0 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106138:	ba 20 00 02 00       	mov    $0x20020,%edx
f010613d:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106142:	e8 89 ff ff ff       	call   f01060d0 <lapicw>
	lapicw(TICR, 10000000); 
f0106147:	ba 80 96 98 00       	mov    $0x989680,%edx
f010614c:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106151:	e8 7a ff ff ff       	call   f01060d0 <lapicw>
	if (thiscpu != bootcpu)
f0106156:	e8 89 ff ff ff       	call   f01060e4 <cpunum>
f010615b:	6b c0 74             	imul   $0x74,%eax,%eax
f010615e:	05 20 d0 2f f0       	add    $0xf02fd020,%eax
f0106163:	83 c4 10             	add    $0x10,%esp
f0106166:	39 05 08 d0 2f f0    	cmp    %eax,0xf02fd008
f010616c:	74 0f                	je     f010617d <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f010616e:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106173:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106178:	e8 53 ff ff ff       	call   f01060d0 <lapicw>
	lapicw(LINT1, MASKED);
f010617d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106182:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106187:	e8 44 ff ff ff       	call   f01060d0 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010618c:	a1 c0 d3 2f f0       	mov    0xf02fd3c0,%eax
f0106191:	8b 40 30             	mov    0x30(%eax),%eax
f0106194:	c1 e8 10             	shr    $0x10,%eax
f0106197:	a8 fc                	test   $0xfc,%al
f0106199:	75 7c                	jne    f0106217 <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010619b:	ba 33 00 00 00       	mov    $0x33,%edx
f01061a0:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01061a5:	e8 26 ff ff ff       	call   f01060d0 <lapicw>
	lapicw(ESR, 0);
f01061aa:	ba 00 00 00 00       	mov    $0x0,%edx
f01061af:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01061b4:	e8 17 ff ff ff       	call   f01060d0 <lapicw>
	lapicw(ESR, 0);
f01061b9:	ba 00 00 00 00       	mov    $0x0,%edx
f01061be:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01061c3:	e8 08 ff ff ff       	call   f01060d0 <lapicw>
	lapicw(EOI, 0);
f01061c8:	ba 00 00 00 00       	mov    $0x0,%edx
f01061cd:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01061d2:	e8 f9 fe ff ff       	call   f01060d0 <lapicw>
	lapicw(ICRHI, 0);
f01061d7:	ba 00 00 00 00       	mov    $0x0,%edx
f01061dc:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01061e1:	e8 ea fe ff ff       	call   f01060d0 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01061e6:	ba 00 85 08 00       	mov    $0x88500,%edx
f01061eb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01061f0:	e8 db fe ff ff       	call   f01060d0 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01061f5:	8b 15 c0 d3 2f f0    	mov    0xf02fd3c0,%edx
f01061fb:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106201:	f6 c4 10             	test   $0x10,%ah
f0106204:	75 f5                	jne    f01061fb <lapic_init+0x101>
	lapicw(TPR, 0);
f0106206:	ba 00 00 00 00       	mov    $0x0,%edx
f010620b:	b8 20 00 00 00       	mov    $0x20,%eax
f0106210:	e8 bb fe ff ff       	call   f01060d0 <lapicw>
}
f0106215:	c9                   	leave  
f0106216:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0106217:	ba 00 00 01 00       	mov    $0x10000,%edx
f010621c:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106221:	e8 aa fe ff ff       	call   f01060d0 <lapicw>
f0106226:	e9 70 ff ff ff       	jmp    f010619b <lapic_init+0xa1>

f010622b <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f010622b:	83 3d c0 d3 2f f0 00 	cmpl   $0x0,0xf02fd3c0
f0106232:	74 17                	je     f010624b <lapic_eoi+0x20>
{
f0106234:	55                   	push   %ebp
f0106235:	89 e5                	mov    %esp,%ebp
f0106237:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f010623a:	ba 00 00 00 00       	mov    $0x0,%edx
f010623f:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106244:	e8 87 fe ff ff       	call   f01060d0 <lapicw>
}
f0106249:	c9                   	leave  
f010624a:	c3                   	ret    
f010624b:	c3                   	ret    

f010624c <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010624c:	55                   	push   %ebp
f010624d:	89 e5                	mov    %esp,%ebp
f010624f:	56                   	push   %esi
f0106250:	53                   	push   %ebx
f0106251:	8b 75 08             	mov    0x8(%ebp),%esi
f0106254:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106257:	b8 0f 00 00 00       	mov    $0xf,%eax
f010625c:	ba 70 00 00 00       	mov    $0x70,%edx
f0106261:	ee                   	out    %al,(%dx)
f0106262:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106267:	ba 71 00 00 00       	mov    $0x71,%edx
f010626c:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f010626d:	83 3d 60 c2 2b f0 00 	cmpl   $0x0,0xf02bc260
f0106274:	74 7e                	je     f01062f4 <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106276:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010627d:	00 00 
	wrv[1] = addr >> 4;
f010627f:	89 d8                	mov    %ebx,%eax
f0106281:	c1 e8 04             	shr    $0x4,%eax
f0106284:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010628a:	c1 e6 18             	shl    $0x18,%esi
f010628d:	89 f2                	mov    %esi,%edx
f010628f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106294:	e8 37 fe ff ff       	call   f01060d0 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106299:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010629e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062a3:	e8 28 fe ff ff       	call   f01060d0 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01062a8:	ba 00 85 00 00       	mov    $0x8500,%edx
f01062ad:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062b2:	e8 19 fe ff ff       	call   f01060d0 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01062b7:	c1 eb 0c             	shr    $0xc,%ebx
f01062ba:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f01062bd:	89 f2                	mov    %esi,%edx
f01062bf:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01062c4:	e8 07 fe ff ff       	call   f01060d0 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01062c9:	89 da                	mov    %ebx,%edx
f01062cb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062d0:	e8 fb fd ff ff       	call   f01060d0 <lapicw>
		lapicw(ICRHI, apicid << 24);
f01062d5:	89 f2                	mov    %esi,%edx
f01062d7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01062dc:	e8 ef fd ff ff       	call   f01060d0 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01062e1:	89 da                	mov    %ebx,%edx
f01062e3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062e8:	e8 e3 fd ff ff       	call   f01060d0 <lapicw>
		microdelay(200);
	}
}
f01062ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01062f0:	5b                   	pop    %ebx
f01062f1:	5e                   	pop    %esi
f01062f2:	5d                   	pop    %ebp
f01062f3:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01062f4:	68 67 04 00 00       	push   $0x467
f01062f9:	68 e4 6f 10 f0       	push   $0xf0106fe4
f01062fe:	68 99 00 00 00       	push   $0x99
f0106303:	68 14 8e 10 f0       	push   $0xf0108e14
f0106308:	e8 33 9d ff ff       	call   f0100040 <_panic>

f010630d <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010630d:	55                   	push   %ebp
f010630e:	89 e5                	mov    %esp,%ebp
f0106310:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106313:	8b 55 08             	mov    0x8(%ebp),%edx
f0106316:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010631c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106321:	e8 aa fd ff ff       	call   f01060d0 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106326:	8b 15 c0 d3 2f f0    	mov    0xf02fd3c0,%edx
f010632c:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106332:	f6 c4 10             	test   $0x10,%ah
f0106335:	75 f5                	jne    f010632c <lapic_ipi+0x1f>
		;
}
f0106337:	c9                   	leave  
f0106338:	c3                   	ret    

f0106339 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106339:	55                   	push   %ebp
f010633a:	89 e5                	mov    %esp,%ebp
f010633c:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010633f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106345:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106348:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010634b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106352:	5d                   	pop    %ebp
f0106353:	c3                   	ret    

f0106354 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106354:	55                   	push   %ebp
f0106355:	89 e5                	mov    %esp,%ebp
f0106357:	56                   	push   %esi
f0106358:	53                   	push   %ebx
f0106359:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f010635c:	83 3b 00             	cmpl   $0x0,(%ebx)
f010635f:	75 07                	jne    f0106368 <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f0106361:	ba 01 00 00 00       	mov    $0x1,%edx
f0106366:	eb 34                	jmp    f010639c <spin_lock+0x48>
f0106368:	8b 73 08             	mov    0x8(%ebx),%esi
f010636b:	e8 74 fd ff ff       	call   f01060e4 <cpunum>
f0106370:	6b c0 74             	imul   $0x74,%eax,%eax
f0106373:	05 20 d0 2f f0       	add    $0xf02fd020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106378:	39 c6                	cmp    %eax,%esi
f010637a:	75 e5                	jne    f0106361 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010637c:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010637f:	e8 60 fd ff ff       	call   f01060e4 <cpunum>
f0106384:	83 ec 0c             	sub    $0xc,%esp
f0106387:	53                   	push   %ebx
f0106388:	50                   	push   %eax
f0106389:	68 24 8e 10 f0       	push   $0xf0108e24
f010638e:	6a 41                	push   $0x41
f0106390:	68 86 8e 10 f0       	push   $0xf0108e86
f0106395:	e8 a6 9c ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010639a:	f3 90                	pause  
f010639c:	89 d0                	mov    %edx,%eax
f010639e:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f01063a1:	85 c0                	test   %eax,%eax
f01063a3:	75 f5                	jne    f010639a <spin_lock+0x46>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01063a5:	e8 3a fd ff ff       	call   f01060e4 <cpunum>
f01063aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01063ad:	05 20 d0 2f f0       	add    $0xf02fd020,%eax
f01063b2:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));//I guess it means moving ebp register value to local variable. 
f01063b5:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01063b7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01063bc:	83 f8 09             	cmp    $0x9,%eax
f01063bf:	7f 21                	jg     f01063e2 <spin_lock+0x8e>
f01063c1:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01063c7:	76 19                	jbe    f01063e2 <spin_lock+0x8e>
		pcs[i] = ebp[1];          // saved %eip
f01063c9:	8b 4a 04             	mov    0x4(%edx),%ecx
f01063cc:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01063d0:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f01063d2:	83 c0 01             	add    $0x1,%eax
f01063d5:	eb e5                	jmp    f01063bc <spin_lock+0x68>
		pcs[i] = 0;
f01063d7:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f01063de:	00 
	for (; i < 10; i++)
f01063df:	83 c0 01             	add    $0x1,%eax
f01063e2:	83 f8 09             	cmp    $0x9,%eax
f01063e5:	7e f0                	jle    f01063d7 <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f01063e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01063ea:	5b                   	pop    %ebx
f01063eb:	5e                   	pop    %esi
f01063ec:	5d                   	pop    %ebp
f01063ed:	c3                   	ret    

f01063ee <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01063ee:	55                   	push   %ebp
f01063ef:	89 e5                	mov    %esp,%ebp
f01063f1:	57                   	push   %edi
f01063f2:	56                   	push   %esi
f01063f3:	53                   	push   %ebx
f01063f4:	83 ec 4c             	sub    $0x4c,%esp
f01063f7:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f01063fa:	83 3e 00             	cmpl   $0x0,(%esi)
f01063fd:	75 35                	jne    f0106434 <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01063ff:	83 ec 04             	sub    $0x4,%esp
f0106402:	6a 28                	push   $0x28
f0106404:	8d 46 0c             	lea    0xc(%esi),%eax
f0106407:	50                   	push   %eax
f0106408:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010640b:	53                   	push   %ebx
f010640c:	e8 22 f7 ff ff       	call   f0105b33 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106411:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106414:	0f b6 38             	movzbl (%eax),%edi
f0106417:	8b 76 04             	mov    0x4(%esi),%esi
f010641a:	e8 c5 fc ff ff       	call   f01060e4 <cpunum>
f010641f:	57                   	push   %edi
f0106420:	56                   	push   %esi
f0106421:	50                   	push   %eax
f0106422:	68 50 8e 10 f0       	push   $0xf0108e50
f0106427:	e8 a5 d6 ff ff       	call   f0103ad1 <cprintf>
f010642c:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010642f:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106432:	eb 4e                	jmp    f0106482 <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f0106434:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106437:	e8 a8 fc ff ff       	call   f01060e4 <cpunum>
f010643c:	6b c0 74             	imul   $0x74,%eax,%eax
f010643f:	05 20 d0 2f f0       	add    $0xf02fd020,%eax
	if (!holding(lk)) {
f0106444:	39 c3                	cmp    %eax,%ebx
f0106446:	75 b7                	jne    f01063ff <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106448:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010644f:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0106456:	b8 00 00 00 00       	mov    $0x0,%eax
f010645b:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f010645e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106461:	5b                   	pop    %ebx
f0106462:	5e                   	pop    %esi
f0106463:	5f                   	pop    %edi
f0106464:	5d                   	pop    %ebp
f0106465:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f0106466:	83 ec 08             	sub    $0x8,%esp
f0106469:	ff 36                	push   (%esi)
f010646b:	68 ad 8e 10 f0       	push   $0xf0108ead
f0106470:	e8 5c d6 ff ff       	call   f0103ad1 <cprintf>
f0106475:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106478:	83 c3 04             	add    $0x4,%ebx
f010647b:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010647e:	39 c3                	cmp    %eax,%ebx
f0106480:	74 40                	je     f01064c2 <spin_unlock+0xd4>
f0106482:	89 de                	mov    %ebx,%esi
f0106484:	8b 03                	mov    (%ebx),%eax
f0106486:	85 c0                	test   %eax,%eax
f0106488:	74 38                	je     f01064c2 <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010648a:	83 ec 08             	sub    $0x8,%esp
f010648d:	57                   	push   %edi
f010648e:	50                   	push   %eax
f010648f:	e8 88 eb ff ff       	call   f010501c <debuginfo_eip>
f0106494:	83 c4 10             	add    $0x10,%esp
f0106497:	85 c0                	test   %eax,%eax
f0106499:	78 cb                	js     f0106466 <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f010649b:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010649d:	83 ec 04             	sub    $0x4,%esp
f01064a0:	89 c2                	mov    %eax,%edx
f01064a2:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01064a5:	52                   	push   %edx
f01064a6:	ff 75 b0             	push   -0x50(%ebp)
f01064a9:	ff 75 b4             	push   -0x4c(%ebp)
f01064ac:	ff 75 ac             	push   -0x54(%ebp)
f01064af:	ff 75 a8             	push   -0x58(%ebp)
f01064b2:	50                   	push   %eax
f01064b3:	68 96 8e 10 f0       	push   $0xf0108e96
f01064b8:	e8 14 d6 ff ff       	call   f0103ad1 <cprintf>
f01064bd:	83 c4 20             	add    $0x20,%esp
f01064c0:	eb b6                	jmp    f0106478 <spin_unlock+0x8a>
		panic("spin_unlock");
f01064c2:	83 ec 04             	sub    $0x4,%esp
f01064c5:	68 b5 8e 10 f0       	push   $0xf0108eb5
f01064ca:	6a 67                	push   $0x67
f01064cc:	68 86 8e 10 f0       	push   $0xf0108e86
f01064d1:	e8 6a 9b ff ff       	call   f0100040 <_panic>

f01064d6 <e1000_transmit_init>:
}

/*传输*/
void
e1000_transmit_init()
{
f01064d6:	55                   	push   %ebp
f01064d7:	89 e5                	mov    %esp,%ebp
f01064d9:	57                   	push   %edi
f01064da:	56                   	push   %esi
f01064db:	53                   	push   %ebx
f01064dc:	83 ec 10             	sub    $0x10,%esp
	* 3. 初始化传输控制寄存器(TCTL) 包括：TCTL.EN置1； TCTL.PSP置1；TCTL.CT置为10h；TCTL.COLD置为40h。
	* 4. 参考IEEE 802.3 IPG标准 设置TIPG寄存器
	*/
	//1.操作描述符。这部分不在14.5中体现，我们需要参考3.3.3将它完成。
	// addr，length其实都应该用上这描述符后再赋值，但我们是静态内存，所以就直接对addr初始化了。
	memset(e1000_tx_desc_array, 0 , sizeof(struct e1000_tx_desc) * TX_DESC_ARRAY_SIZE);
f01064df:	68 00 02 00 00       	push   $0x200
f01064e4:	6a 00                	push   $0x0
f01064e6:	68 a0 99 34 f0       	push   $0xf03499a0
f01064eb:	e8 fd f5 ff ff       	call   f0105aed <memset>
f01064f0:	ba e0 db 33 f0       	mov    $0xf033dbe0,%edx
f01064f5:	b9 e0 db 33 00       	mov    $0x33dbe0,%ecx
f01064fa:	bb 00 00 00 00       	mov    $0x0,%ebx
f01064ff:	be a0 99 34 f0       	mov    $0xf03499a0,%esi
f0106504:	83 c4 10             	add    $0x10,%esp
f0106507:	b8 a0 99 34 f0       	mov    $0xf03499a0,%eax
	if ((uint32_t)kva < KERNBASE)
f010650c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0106512:	0f 86 8b 00 00 00    	jbe    f01065a3 <e1000_transmit_init+0xcd>
	for (int i = 0; i < TX_DESC_ARRAY_SIZE; i++) {
		e1000_tx_desc_array[i].addr=PADDR(e1000_tx_buffer[i]);
f0106518:	89 08                	mov    %ecx,(%eax)
f010651a:	89 58 04             	mov    %ebx,0x4(%eax)
		e1000_tx_desc_array[i].cmd = E1000_TXD_CMD_RS | E1000_TXD_CMD_EOP;//设置RS位。由于每个包只用一个数据描述符，所以也需要设置EOP位
f010651d:	c6 40 0b 09          	movb   $0x9,0xb(%eax)
		e1000_tx_desc_array[i].status = E1000_TXD_STATUS_DD;//要置1, 不然第一轮直接就默认没有描述符用了
f0106521:	c6 40 0c 01          	movb   $0x1,0xc(%eax)
	for (int i = 0; i < TX_DESC_ARRAY_SIZE; i++) {
f0106525:	81 c2 ee 05 00 00    	add    $0x5ee,%edx
f010652b:	81 c1 ee 05 00 00    	add    $0x5ee,%ecx
f0106531:	83 d3 00             	adc    $0x0,%ebx
f0106534:	83 c0 10             	add    $0x10,%eax
f0106537:	39 f2                	cmp    %esi,%edx
f0106539:	75 d1                	jne    f010650c <e1000_transmit_init+0x36>
	}
	//2.
	e1000[E1000_LOCATE(E1000_TDBAL) ]= PADDR(e1000_tx_desc_array);
f010653b:	a1 a0 9b 34 f0       	mov    0xf0349ba0,%eax
f0106540:	ba a0 99 34 f0       	mov    $0xf03499a0,%edx
f0106545:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010654b:	76 68                	jbe    f01065b5 <e1000_transmit_init+0xdf>
f010654d:	c7 80 00 38 00 00 a0 	movl   $0x3499a0,0x3800(%eax)
f0106554:	99 34 00 
	e1000[E1000_LOCATE(E1000_TDBAH) ] = 0;
f0106557:	c7 80 04 38 00 00 00 	movl   $0x0,0x3804(%eax)
f010655e:	00 00 00 
	e1000[E1000_LOCATE(E1000_TDLEN) ] = sizeof(struct e1000_tx_desc)*TX_DESC_ARRAY_SIZE;
f0106561:	c7 80 08 38 00 00 00 	movl   $0x200,0x3808(%eax)
f0106568:	02 00 00 
	e1000[E1000_LOCATE(E1000_TDH) ] = 0;
f010656b:	c7 80 10 38 00 00 00 	movl   $0x0,0x3810(%eax)
f0106572:	00 00 00 
	e1000[E1000_LOCATE(E1000_TDT) ] = 0;
f0106575:	c7 80 18 38 00 00 00 	movl   $0x0,0x3818(%eax)
f010657c:	00 00 00 
	
	//3.
	e1000[E1000_LOCATE(E1000_TCTL) ] |= E1000_TCTL_EN | E1000_TCTL_PSP | (E1000_TCTL_CT & (0x10 << 4)) | (E1000_TCTL_COLD & (0x40 << 12));
f010657f:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0106585:	81 ca 0a 01 04 00    	or     $0x4010a,%edx
f010658b:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)
	
	//4. {IPGT,IPGR1,IPGR2}分别为 {10,8,6}
	e1000[E1000_LOCATE(E1000_TIPG)] = E1000_TIPG_IPGT | (E1000_TIPG_IPGR1 << E1000_TIPG_IPGR1_SHIFT) | (E1000_TIPG_IPGR2 << E1000_TIPG_IPGR2_SHIFT);
f0106591:	c7 80 10 04 00 00 0a 	movl   $0x60200a,0x410(%eax)
f0106598:	20 60 00 
}
f010659b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010659e:	5b                   	pop    %ebx
f010659f:	5e                   	pop    %esi
f01065a0:	5f                   	pop    %edi
f01065a1:	5d                   	pop    %ebp
f01065a2:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01065a3:	52                   	push   %edx
f01065a4:	68 08 70 10 f0       	push   $0xf0107008
f01065a9:	6a 32                	push   $0x32
f01065ab:	68 cd 8e 10 f0       	push   $0xf0108ecd
f01065b0:	e8 8b 9a ff ff       	call   f0100040 <_panic>
f01065b5:	52                   	push   %edx
f01065b6:	68 08 70 10 f0       	push   $0xf0107008
f01065bb:	6a 37                	push   $0x37
f01065bd:	68 cd 8e 10 f0       	push   $0xf0108ecd
f01065c2:	e8 79 9a ff ff       	call   f0100040 <_panic>

f01065c7 <e1000_transmit>:

int 
e1000_transmit(void *addr, size_t len)
{
f01065c7:	55                   	push   %ebp
f01065c8:	89 e5                	mov    %esp,%ebp
f01065ca:	56                   	push   %esi
f01065cb:	53                   	push   %ebx
f01065cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	size_t tdt = e1000[E1000_LOCATE(E1000_TDT)] ;//TDT寄存器中存的是索引！！！
f01065cf:	a1 a0 9b 34 f0       	mov    0xf0349ba0,%eax
f01065d4:	8b 98 18 38 00 00    	mov    0x3818(%eax),%ebx
	struct e1000_tx_desc * tail_desc = &e1000_tx_desc_array[tdt];
	
	if( !(tail_desc->status & E1000_TXD_STATUS_DD) ) return -1;//传输队列已满
f01065da:	89 d8                	mov    %ebx,%eax
f01065dc:	c1 e0 04             	shl    $0x4,%eax
f01065df:	f6 80 ac 99 34 f0 01 	testb  $0x1,-0xfcb6654(%eax)
f01065e6:	74 4b                	je     f0106633 <e1000_transmit+0x6c>
	
	memcpy(e1000_tx_buffer[tdt] , addr, len);
f01065e8:	83 ec 04             	sub    $0x4,%esp
f01065eb:	56                   	push   %esi
f01065ec:	ff 75 08             	push   0x8(%ebp)
f01065ef:	69 c3 ee 05 00 00    	imul   $0x5ee,%ebx,%eax
f01065f5:	05 e0 db 33 f0       	add    $0xf033dbe0,%eax
f01065fa:	50                   	push   %eax
f01065fb:	e8 95 f5 ff ff       	call   f0105b95 <memcpy>
	
	tail_desc->length = (uint16_t )len;
f0106600:	89 d8                	mov    %ebx,%eax
f0106602:	c1 e0 04             	shl    $0x4,%eax
f0106605:	66 89 b0 a8 99 34 f0 	mov    %si,-0xfcb6658(%eax)
	tail_desc->status=0;
f010660c:	c6 80 ac 99 34 f0 00 	movb   $0x0,-0xfcb6654(%eax)
	//tail_desc->status &= (~E1000_TXD_STATUS_DD);//清零DD位。
	
	e1000[E1000_LOCATE(E1000_TDT)]= (tdt+1) % TX_DESC_ARRAY_SIZE;
f0106613:	83 c3 01             	add    $0x1,%ebx
f0106616:	83 e3 1f             	and    $0x1f,%ebx
f0106619:	a1 a0 9b 34 f0       	mov    0xf0349ba0,%eax
f010661e:	89 98 18 38 00 00    	mov    %ebx,0x3818(%eax)
	
	return 0;
f0106624:	83 c4 10             	add    $0x10,%esp
f0106627:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010662c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010662f:	5b                   	pop    %ebx
f0106630:	5e                   	pop    %esi
f0106631:	5d                   	pop    %ebp
f0106632:	c3                   	ret    
	if( !(tail_desc->status & E1000_TXD_STATUS_DD) ) return -1;//传输队列已满
f0106633:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0106638:	eb f2                	jmp    f010662c <e1000_transmit+0x65>

f010663a <e1000_receive_init>:

/*接收*/
void
e1000_receive_init()
{
f010663a:	55                   	push   %ebp
f010663b:	89 e5                	mov    %esp,%ebp
f010663d:	57                   	push   %edi
f010663e:	56                   	push   %esi
f010663f:	53                   	push   %ebx
f0106640:	83 ec 10             	sub    $0x10,%esp
	//接收地址寄存器
	e1000[E1000_LOCATE(E1000_RA)] = QEMU_DEFAULT_MAC_LOW;
f0106643:	a1 a0 9b 34 f0       	mov    0xf0349ba0,%eax
f0106648:	c7 80 00 54 00 00 52 	movl   $0x12005452,0x5400(%eax)
f010664f:	54 00 12 
	e1000[E1000_LOCATE(E1000_RA) + 1] = QEMU_DEFAULT_MAC_HIGH | E1000_RAH_AV;
f0106652:	c7 80 04 54 00 00 34 	movl   $0x80005634,0x5404(%eax)
f0106659:	56 00 80 
	
	//处理描述符
	memset(e1000_rx_desc_array, 0, sizeof(e1000_rx_desc_array) );
f010665c:	68 00 08 00 00       	push   $0x800
f0106661:	6a 00                	push   $0x0
f0106663:	68 e0 d3 33 f0       	push   $0xf033d3e0
f0106668:	e8 80 f4 ff ff       	call   f0105aed <memset>
f010666d:	b8 e0 d3 2f f0       	mov    $0xf02fd3e0,%eax
f0106672:	b9 e0 d3 2f 00       	mov    $0x2fd3e0,%ecx
f0106677:	bb 00 00 00 00       	mov    $0x0,%ebx
f010667c:	be e0 d3 33 f0       	mov    $0xf033d3e0,%esi
f0106681:	83 c4 10             	add    $0x10,%esp
f0106684:	ba e0 d3 33 f0       	mov    $0xf033d3e0,%edx
	if ((uint32_t)kva < KERNBASE)
f0106689:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010668e:	76 70                	jbe    f0106700 <e1000_receive_init+0xc6>
	for (int i = 0; i < RX_DESC_ARRAY_SIZE; i++) {
		e1000_rx_desc_array[i].addr = PADDR(e1000_rx_buffer[i]);
f0106690:	89 0a                	mov    %ecx,(%edx)
f0106692:	89 5a 04             	mov    %ebx,0x4(%edx)
	for (int i = 0; i < RX_DESC_ARRAY_SIZE; i++) {
f0106695:	05 00 08 00 00       	add    $0x800,%eax
f010669a:	81 c1 00 08 00 00    	add    $0x800,%ecx
f01066a0:	83 d3 00             	adc    $0x0,%ebx
f01066a3:	83 c2 10             	add    $0x10,%edx
f01066a6:	39 f0                	cmp    %esi,%eax
f01066a8:	75 df                	jne    f0106689 <e1000_receive_init+0x4f>
	}
	
	e1000[E1000_LOCATE(E1000_RDBAL)] = PADDR(e1000_rx_desc_array);
f01066aa:	a1 a0 9b 34 f0       	mov    0xf0349ba0,%eax
f01066af:	ba e0 d3 33 f0       	mov    $0xf033d3e0,%edx
f01066b4:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01066ba:	76 56                	jbe    f0106712 <e1000_receive_init+0xd8>
f01066bc:	c7 80 00 28 00 00 e0 	movl   $0x33d3e0,0x2800(%eax)
f01066c3:	d3 33 00 
	e1000[E1000_LOCATE(E1000_RDBAH)] = 0;
f01066c6:	c7 80 04 28 00 00 00 	movl   $0x0,0x2804(%eax)
f01066cd:	00 00 00 
	e1000[E1000_LOCATE(E1000_RDLEN)] = sizeof(e1000_rx_desc_array);
f01066d0:	c7 80 08 28 00 00 00 	movl   $0x800,0x2808(%eax)
f01066d7:	08 00 00 
	e1000[E1000_LOCATE(E1000_RDH)] = 0;
f01066da:	c7 80 10 28 00 00 00 	movl   $0x0,0x2810(%eax)
f01066e1:	00 00 00 
	e1000[E1000_LOCATE(E1000_RDT)] = RX_DESC_ARRAY_SIZE-1;//尾指针的下一个才是真尾巴，即真正软件要把它复制过来的数据包
f01066e4:	c7 80 18 28 00 00 7f 	movl   $0x7f,0x2818(%eax)
f01066eb:	00 00 00 
	
	e1000[E1000_LOCATE(E1000_RCTL)] = E1000_RCTL_EN | E1000_RCTL_BAM  |  E1000_RCTL_SZ_2048 | E1000_RCTL_SECRC;	
f01066ee:	c7 80 00 01 00 00 02 	movl   $0x4008002,0x100(%eax)
f01066f5:	80 00 04 
}
f01066f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01066fb:	5b                   	pop    %ebx
f01066fc:	5e                   	pop    %esi
f01066fd:	5f                   	pop    %edi
f01066fe:	5d                   	pop    %ebp
f01066ff:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106700:	50                   	push   %eax
f0106701:	68 08 70 10 f0       	push   $0xf0107008
f0106706:	6a 62                	push   $0x62
f0106708:	68 cd 8e 10 f0       	push   $0xf0108ecd
f010670d:	e8 2e 99 ff ff       	call   f0100040 <_panic>
f0106712:	52                   	push   %edx
f0106713:	68 08 70 10 f0       	push   $0xf0107008
f0106718:	6a 65                	push   $0x65
f010671a:	68 cd 8e 10 f0       	push   $0xf0108ecd
f010671f:	e8 1c 99 ff ff       	call   f0100040 <_panic>

f0106724 <pci_e1000_attach>:
{
f0106724:	55                   	push   %ebp
f0106725:	89 e5                	mov    %esp,%ebp
f0106727:	53                   	push   %ebx
f0106728:	83 ec 10             	sub    $0x10,%esp
f010672b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pci_func_enable(pcif);
f010672e:	53                   	push   %ebx
f010672f:	e8 93 04 00 00       	call   f0106bc7 <pci_func_enable>
	e1000=mmio_map_region(pcif->reg_base[0],pcif->reg_size[0]);
f0106734:	83 c4 08             	add    $0x8,%esp
f0106737:	ff 73 2c             	push   0x2c(%ebx)
f010673a:	ff 73 14             	push   0x14(%ebx)
f010673d:	e8 79 ab ff ff       	call   f01012bb <mmio_map_region>
f0106742:	a3 a0 9b 34 f0       	mov    %eax,0xf0349ba0
	cprintf("device status:[%x]\n", e1000[E1000_LOCATE(E1000_STATUS)] );/*打印设备状态寄存器， 用来测试程序*/
f0106747:	8b 40 08             	mov    0x8(%eax),%eax
f010674a:	83 c4 08             	add    $0x8,%esp
f010674d:	50                   	push   %eax
f010674e:	68 da 8e 10 f0       	push   $0xf0108eda
f0106753:	e8 79 d3 ff ff       	call   f0103ad1 <cprintf>
	e1000_transmit_init();
f0106758:	e8 79 fd ff ff       	call   f01064d6 <e1000_transmit_init>
	e1000_receive_init();
f010675d:	e8 d8 fe ff ff       	call   f010663a <e1000_receive_init>
}
f0106762:	b8 00 00 00 00       	mov    $0x0,%eax
f0106767:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010676a:	c9                   	leave  
f010676b:	c3                   	ret    

f010676c <e1000_receive>:


int 
e1000_receive(void *addr, size_t *len)//要把长度取出来，后面struct jif_pkt需要记录长度的
{
f010676c:	55                   	push   %ebp
f010676d:	89 e5                	mov    %esp,%ebp
f010676f:	56                   	push   %esi
f0106770:	53                   	push   %ebx
	size_t tail = e1000[E1000_LOCATE(E1000_RDT)];
f0106771:	a1 a0 9b 34 f0       	mov    0xf0349ba0,%eax
f0106776:	8b 98 18 28 00 00    	mov    0x2818(%eax),%ebx
	size_t next = (tail+1)% RX_DESC_ARRAY_SIZE;//真尾巴
f010677c:	83 c3 01             	add    $0x1,%ebx
f010677f:	83 e3 7f             	and    $0x7f,%ebx
	
	if( !(e1000_rx_desc_array[next].status & E1000_RXD_STAT_DD) ){
f0106782:	89 d8                	mov    %ebx,%eax
f0106784:	c1 e0 04             	shl    $0x4,%eax
f0106787:	f6 80 ec d3 33 f0 01 	testb  $0x1,-0xfcc2c14(%eax)
f010678e:	74 4c                	je     f01067dc <e1000_receive+0x70>
		return -1;//队列空
	}
	
	*len=e1000_rx_desc_array[next].length;
f0106790:	89 d8                	mov    %ebx,%eax
f0106792:	c1 e0 04             	shl    $0x4,%eax
f0106795:	8d b0 e0 d3 33 f0    	lea    -0xfcc2c20(%eax),%esi
f010679b:	0f b7 80 e8 d3 33 f0 	movzwl -0xfcc2c18(%eax),%eax
f01067a2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01067a5:	89 02                	mov    %eax,(%edx)
	memcpy(addr, e1000_rx_buffer[next] , *len);
f01067a7:	83 ec 04             	sub    $0x4,%esp
f01067aa:	50                   	push   %eax
f01067ab:	89 d8                	mov    %ebx,%eax
f01067ad:	c1 e0 0b             	shl    $0xb,%eax
f01067b0:	05 e0 d3 2f f0       	add    $0xf02fd3e0,%eax
f01067b5:	50                   	push   %eax
f01067b6:	ff 75 08             	push   0x8(%ebp)
f01067b9:	e8 d7 f3 ff ff       	call   f0105b95 <memcpy>
	
	e1000_rx_desc_array[next].status &= ~E1000_RXD_STAT_DD;//清零DD位
f01067be:	80 66 0c fe          	andb   $0xfe,0xc(%esi)
	e1000[E1000_LOCATE(E1000_RDT)] = next;
f01067c2:	a1 a0 9b 34 f0       	mov    0xf0349ba0,%eax
f01067c7:	89 98 18 28 00 00    	mov    %ebx,0x2818(%eax)
	
	return 0;
f01067cd:	83 c4 10             	add    $0x10,%esp
f01067d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01067d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01067d8:	5b                   	pop    %ebx
f01067d9:	5e                   	pop    %esi
f01067da:	5d                   	pop    %ebp
f01067db:	c3                   	ret    
		return -1;//队列空
f01067dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01067e1:	eb f2                	jmp    f01067d5 <e1000_receive+0x69>

f01067e3 <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f01067e3:	55                   	push   %ebp
f01067e4:	89 e5                	mov    %esp,%ebp
f01067e6:	57                   	push   %edi
f01067e7:	56                   	push   %esi
f01067e8:	53                   	push   %ebx
f01067e9:	83 ec 0c             	sub    $0xc,%esp
f01067ec:	8b 7d 08             	mov    0x8(%ebp),%edi
f01067ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f01067f2:	eb 03                	jmp    f01067f7 <pci_attach_match+0x14>
f01067f4:	83 c3 0c             	add    $0xc,%ebx
f01067f7:	89 de                	mov    %ebx,%esi
f01067f9:	8b 43 08             	mov    0x8(%ebx),%eax
f01067fc:	85 c0                	test   %eax,%eax
f01067fe:	74 37                	je     f0106837 <pci_attach_match+0x54>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f0106800:	39 3b                	cmp    %edi,(%ebx)
f0106802:	75 f0                	jne    f01067f4 <pci_attach_match+0x11>
f0106804:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106807:	39 56 04             	cmp    %edx,0x4(%esi)
f010680a:	75 e8                	jne    f01067f4 <pci_attach_match+0x11>
			int r = list[i].attachfn(pcif);
f010680c:	83 ec 0c             	sub    $0xc,%esp
f010680f:	ff 75 14             	push   0x14(%ebp)
f0106812:	ff d0                	call   *%eax
			if (r > 0)
f0106814:	83 c4 10             	add    $0x10,%esp
f0106817:	85 c0                	test   %eax,%eax
f0106819:	7f 1c                	jg     f0106837 <pci_attach_match+0x54>
				return r;
			if (r < 0)
f010681b:	79 d7                	jns    f01067f4 <pci_attach_match+0x11>
				cprintf("pci_attach_match: attaching "
f010681d:	83 ec 0c             	sub    $0xc,%esp
f0106820:	50                   	push   %eax
f0106821:	ff 76 08             	push   0x8(%esi)
f0106824:	ff 75 0c             	push   0xc(%ebp)
f0106827:	57                   	push   %edi
f0106828:	68 f0 8e 10 f0       	push   $0xf0108ef0
f010682d:	e8 9f d2 ff ff       	call   f0103ad1 <cprintf>
f0106832:	83 c4 20             	add    $0x20,%esp
f0106835:	eb bd                	jmp    f01067f4 <pci_attach_match+0x11>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f0106837:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010683a:	5b                   	pop    %ebx
f010683b:	5e                   	pop    %esi
f010683c:	5f                   	pop    %edi
f010683d:	5d                   	pop    %ebp
f010683e:	c3                   	ret    

f010683f <pci_conf1_set_addr>:
{
f010683f:	55                   	push   %ebp
f0106840:	89 e5                	mov    %esp,%ebp
f0106842:	56                   	push   %esi
f0106843:	53                   	push   %ebx
f0106844:	8b 75 08             	mov    0x8(%ebp),%esi
	assert(bus < 256);
f0106847:	3d ff 00 00 00       	cmp    $0xff,%eax
f010684c:	77 3b                	ja     f0106889 <pci_conf1_set_addr+0x4a>
	assert(dev < 32);
f010684e:	83 fa 1f             	cmp    $0x1f,%edx
f0106851:	77 4c                	ja     f010689f <pci_conf1_set_addr+0x60>
	assert(func < 8);
f0106853:	83 f9 07             	cmp    $0x7,%ecx
f0106856:	77 5d                	ja     f01068b5 <pci_conf1_set_addr+0x76>
	assert(offset < 256);
f0106858:	81 fe ff 00 00 00    	cmp    $0xff,%esi
f010685e:	77 6b                	ja     f01068cb <pci_conf1_set_addr+0x8c>
	assert((offset & 0x3) == 0);
f0106860:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0106866:	75 79                	jne    f01068e1 <pci_conf1_set_addr+0xa2>
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
f0106868:	c1 e0 10             	shl    $0x10,%eax
f010686b:	09 f0                	or     %esi,%eax
f010686d:	c1 e1 08             	shl    $0x8,%ecx
f0106870:	09 c8                	or     %ecx,%eax
f0106872:	c1 e2 0b             	shl    $0xb,%edx
f0106875:	09 d0                	or     %edx,%eax
	uint32_t v = (1 << 31) |		// config-space
f0106877:	0d 00 00 00 80       	or     $0x80000000,%eax
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f010687c:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f0106881:	ef                   	out    %eax,(%dx)
}
f0106882:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106885:	5b                   	pop    %ebx
f0106886:	5e                   	pop    %esi
f0106887:	5d                   	pop    %ebp
f0106888:	c3                   	ret    
	assert(bus < 256);
f0106889:	68 47 90 10 f0       	push   $0xf0109047
f010688e:	68 55 75 10 f0       	push   $0xf0107555
f0106893:	6a 2c                	push   $0x2c
f0106895:	68 51 90 10 f0       	push   $0xf0109051
f010689a:	e8 a1 97 ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f010689f:	68 5c 90 10 f0       	push   $0xf010905c
f01068a4:	68 55 75 10 f0       	push   $0xf0107555
f01068a9:	6a 2d                	push   $0x2d
f01068ab:	68 51 90 10 f0       	push   $0xf0109051
f01068b0:	e8 8b 97 ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f01068b5:	68 65 90 10 f0       	push   $0xf0109065
f01068ba:	68 55 75 10 f0       	push   $0xf0107555
f01068bf:	6a 2e                	push   $0x2e
f01068c1:	68 51 90 10 f0       	push   $0xf0109051
f01068c6:	e8 75 97 ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f01068cb:	68 6e 90 10 f0       	push   $0xf010906e
f01068d0:	68 55 75 10 f0       	push   $0xf0107555
f01068d5:	6a 2f                	push   $0x2f
f01068d7:	68 51 90 10 f0       	push   $0xf0109051
f01068dc:	e8 5f 97 ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f01068e1:	68 7b 90 10 f0       	push   $0xf010907b
f01068e6:	68 55 75 10 f0       	push   $0xf0107555
f01068eb:	6a 30                	push   $0x30
f01068ed:	68 51 90 10 f0       	push   $0xf0109051
f01068f2:	e8 49 97 ff ff       	call   f0100040 <_panic>

f01068f7 <pci_conf_read>:
{
f01068f7:	55                   	push   %ebp
f01068f8:	89 e5                	mov    %esp,%ebp
f01068fa:	53                   	push   %ebx
f01068fb:	83 ec 10             	sub    $0x10,%esp
f01068fe:	89 d3                	mov    %edx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106900:	8b 48 08             	mov    0x8(%eax),%ecx
f0106903:	8b 50 04             	mov    0x4(%eax),%edx
f0106906:	8b 00                	mov    (%eax),%eax
f0106908:	8b 40 04             	mov    0x4(%eax),%eax
f010690b:	53                   	push   %ebx
f010690c:	e8 2e ff ff ff       	call   f010683f <pci_conf1_set_addr>
	asm volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f0106911:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0106916:	ed                   	in     (%dx),%eax
}
f0106917:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010691a:	c9                   	leave  
f010691b:	c3                   	ret    

f010691c <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f010691c:	55                   	push   %ebp
f010691d:	89 e5                	mov    %esp,%ebp
f010691f:	57                   	push   %edi
f0106920:	56                   	push   %esi
f0106921:	53                   	push   %ebx
f0106922:	81 ec 00 01 00 00    	sub    $0x100,%esp
f0106928:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f010692a:	6a 48                	push   $0x48
f010692c:	6a 00                	push   $0x0
f010692e:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0106931:	50                   	push   %eax
f0106932:	e8 b6 f1 ff ff       	call   f0105aed <memset>
	df.bus = bus;
f0106937:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f010693a:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0106941:	83 c4 10             	add    $0x10,%esp
	int totaldev = 0;
f0106944:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
f010694b:	00 00 00 
f010694e:	e9 4b 01 00 00       	jmp    f0106a9e <pci_scan_bus+0x182>
	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f0106953:	83 ec 08             	sub    $0x8,%esp
f0106956:	89 fa                	mov    %edi,%edx
f0106958:	0f b6 fa             	movzbl %dl,%edi
f010695b:	57                   	push   %edi
f010695c:	51                   	push   %ecx
		PCI_CLASS(f->dev_class), PCI_SUBCLASS(f->dev_class), class,
f010695d:	c1 e8 10             	shr    $0x10,%eax
	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f0106960:	0f b6 c0             	movzbl %al,%eax
f0106963:	50                   	push   %eax
f0106964:	ff b5 00 ff ff ff    	push   -0x100(%ebp)
f010696a:	c1 ee 10             	shr    $0x10,%esi
f010696d:	56                   	push   %esi
f010696e:	ff b5 04 ff ff ff    	push   -0xfc(%ebp)
f0106974:	53                   	push   %ebx
f0106975:	ff b5 5c ff ff ff    	push   -0xa4(%ebp)
f010697b:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f0106981:	ff 70 04             	push   0x4(%eax)
f0106984:	68 1c 8f 10 f0       	push   $0xf0108f1c
f0106989:	e8 43 d1 ff ff       	call   f0103ad1 <cprintf>
				 PCI_SUBCLASS(f->dev_class),
f010698e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
		pci_attach_match(PCI_CLASS(f->dev_class),
f0106994:	83 c4 30             	add    $0x30,%esp
f0106997:	8d 8d 58 ff ff ff    	lea    -0xa8(%ebp),%ecx
f010699d:	51                   	push   %ecx
f010699e:	68 0c 94 12 f0       	push   $0xf012940c
				 PCI_SUBCLASS(f->dev_class),
f01069a3:	89 c2                	mov    %eax,%edx
f01069a5:	c1 ea 10             	shr    $0x10,%edx
		pci_attach_match(PCI_CLASS(f->dev_class),
f01069a8:	0f b6 d2             	movzbl %dl,%edx
f01069ab:	52                   	push   %edx
f01069ac:	c1 e8 18             	shr    $0x18,%eax
f01069af:	50                   	push   %eax
f01069b0:	e8 2e fe ff ff       	call   f01067e3 <pci_attach_match>
				 &pci_attach_class[0], f) ||
f01069b5:	83 c4 10             	add    $0x10,%esp
f01069b8:	85 c0                	test   %eax,%eax
f01069ba:	0f 84 a7 00 00 00    	je     f0106a67 <pci_scan_bus+0x14b>

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f01069c0:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
f01069c6:	8d 58 01             	lea    0x1(%eax),%ebx
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f01069c9:	89 9d 18 ff ff ff    	mov    %ebx,-0xe8(%ebp)
f01069cf:	39 9d fc fe ff ff    	cmp    %ebx,-0x104(%ebp)
f01069d5:	0f 86 b5 00 00 00    	jbe    f0106a90 <pci_scan_bus+0x174>
			struct pci_func af = f;
f01069db:	8d bd 58 ff ff ff    	lea    -0xa8(%ebp),%edi
f01069e1:	8d b5 10 ff ff ff    	lea    -0xf0(%ebp),%esi
f01069e7:	b9 12 00 00 00       	mov    $0x12,%ecx
f01069ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f01069ee:	ba 00 00 00 00       	mov    $0x0,%edx
f01069f3:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f01069f9:	e8 f9 fe ff ff       	call   f01068f7 <pci_conf_read>
f01069fe:	89 c6                	mov    %eax,%esi
f0106a00:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f0106a06:	0f b7 c0             	movzwl %ax,%eax
f0106a09:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)
f0106a0f:	66 83 fe ff          	cmp    $0xffff,%si
f0106a13:	74 ab                	je     f01069c0 <pci_scan_bus+0xa4>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0106a15:	ba 3c 00 00 00       	mov    $0x3c,%edx
f0106a1a:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
f0106a20:	e8 d2 fe ff ff       	call   f01068f7 <pci_conf_read>
f0106a25:	89 c7                	mov    %eax,%edi
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f0106a27:	88 45 9c             	mov    %al,-0x64(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f0106a2a:	ba 08 00 00 00       	mov    $0x8,%edx
f0106a2f:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
f0106a35:	e8 bd fe ff ff       	call   f01068f7 <pci_conf_read>
f0106a3a:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f0106a40:	89 c2                	mov    %eax,%edx
f0106a42:	c1 ea 18             	shr    $0x18,%edx
f0106a45:	89 95 00 ff ff ff    	mov    %edx,-0x100(%ebp)
	const char *class = pci_class[0];
f0106a4b:	b9 8f 90 10 f0       	mov    $0xf010908f,%ecx
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f0106a50:	3d ff ff ff 06       	cmp    $0x6ffffff,%eax
f0106a55:	0f 87 f8 fe ff ff    	ja     f0106953 <pci_scan_bus+0x37>
		class = pci_class[PCI_CLASS(f->dev_class)];
f0106a5b:	8b 0c 95 04 91 10 f0 	mov    -0xfef6efc(,%edx,4),%ecx
f0106a62:	e9 ec fe ff ff       	jmp    f0106953 <pci_scan_bus+0x37>
				 PCI_PRODUCT(f->dev_id),
f0106a67:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
		pci_attach_match(PCI_VENDOR(f->dev_id),
f0106a6d:	8d 8d 58 ff ff ff    	lea    -0xa8(%ebp),%ecx
f0106a73:	51                   	push   %ecx
f0106a74:	68 f4 93 12 f0       	push   $0xf01293f4
f0106a79:	89 c2                	mov    %eax,%edx
f0106a7b:	c1 ea 10             	shr    $0x10,%edx
f0106a7e:	52                   	push   %edx
f0106a7f:	0f b7 c0             	movzwl %ax,%eax
f0106a82:	50                   	push   %eax
f0106a83:	e8 5b fd ff ff       	call   f01067e3 <pci_attach_match>
f0106a88:	83 c4 10             	add    $0x10,%esp
f0106a8b:	e9 30 ff ff ff       	jmp    f01069c0 <pci_scan_bus+0xa4>
	for (df.dev = 0; df.dev < 32; df.dev++) {
f0106a90:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0106a93:	83 c0 01             	add    $0x1,%eax
f0106a96:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0106a99:	83 f8 1f             	cmp    $0x1f,%eax
f0106a9c:	77 4b                	ja     f0106ae9 <pci_scan_bus+0x1cd>
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f0106a9e:	ba 0c 00 00 00       	mov    $0xc,%edx
f0106aa3:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0106aa6:	e8 4c fe ff ff       	call   f01068f7 <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f0106aab:	89 c2                	mov    %eax,%edx
f0106aad:	c1 ea 10             	shr    $0x10,%edx
f0106ab0:	89 d3                	mov    %edx,%ebx
f0106ab2:	83 e3 7e             	and    $0x7e,%ebx
f0106ab5:	75 d9                	jne    f0106a90 <pci_scan_bus+0x174>
		totaldev++;
f0106ab7:	83 85 f8 fe ff ff 01 	addl   $0x1,-0x108(%ebp)
		struct pci_func f = df;
f0106abe:	8d bd 10 ff ff ff    	lea    -0xf0(%ebp),%edi
f0106ac4:	8d 75 a0             	lea    -0x60(%ebp),%esi
f0106ac7:	b9 12 00 00 00       	mov    $0x12,%ecx
f0106acc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106ace:	25 00 00 80 00       	and    $0x800000,%eax
f0106ad3:	83 f8 01             	cmp    $0x1,%eax
f0106ad6:	19 c0                	sbb    %eax,%eax
f0106ad8:	83 e0 f9             	and    $0xfffffff9,%eax
f0106adb:	83 c0 08             	add    $0x8,%eax
f0106ade:	89 85 fc fe ff ff    	mov    %eax,-0x104(%ebp)
f0106ae4:	e9 e0 fe ff ff       	jmp    f01069c9 <pci_scan_bus+0xad>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f0106ae9:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
f0106aef:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106af2:	5b                   	pop    %ebx
f0106af3:	5e                   	pop    %esi
f0106af4:	5f                   	pop    %edi
f0106af5:	5d                   	pop    %ebp
f0106af6:	c3                   	ret    

f0106af7 <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f0106af7:	55                   	push   %ebp
f0106af8:	89 e5                	mov    %esp,%ebp
f0106afa:	57                   	push   %edi
f0106afb:	56                   	push   %esi
f0106afc:	53                   	push   %ebx
f0106afd:	83 ec 1c             	sub    $0x1c,%esp
f0106b00:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f0106b03:	ba 1c 00 00 00       	mov    $0x1c,%edx
f0106b08:	89 f0                	mov    %esi,%eax
f0106b0a:	e8 e8 fd ff ff       	call   f01068f7 <pci_conf_read>
f0106b0f:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f0106b11:	ba 18 00 00 00       	mov    $0x18,%edx
f0106b16:	89 f0                	mov    %esi,%eax
f0106b18:	e8 da fd ff ff       	call   f01068f7 <pci_conf_read>

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f0106b1d:	83 e7 0f             	and    $0xf,%edi
f0106b20:	83 ff 01             	cmp    $0x1,%edi
f0106b23:	74 52                	je     f0106b77 <pci_bridge_attach+0x80>
f0106b25:	89 c3                	mov    %eax,%ebx
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f0106b27:	83 ec 04             	sub    $0x4,%esp
f0106b2a:	6a 08                	push   $0x8
f0106b2c:	6a 00                	push   $0x0
f0106b2e:	8d 7d e0             	lea    -0x20(%ebp),%edi
f0106b31:	57                   	push   %edi
f0106b32:	e8 b6 ef ff ff       	call   f0105aed <memset>
	nbus.parent_bridge = pcif;
f0106b37:	89 75 e0             	mov    %esi,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f0106b3a:	0f b6 c7             	movzbl %bh,%eax
f0106b3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f0106b40:	83 c4 08             	add    $0x8,%esp
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);
f0106b43:	c1 eb 10             	shr    $0x10,%ebx
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f0106b46:	0f b6 db             	movzbl %bl,%ebx
f0106b49:	53                   	push   %ebx
f0106b4a:	50                   	push   %eax
f0106b4b:	ff 76 08             	push   0x8(%esi)
f0106b4e:	ff 76 04             	push   0x4(%esi)
f0106b51:	8b 06                	mov    (%esi),%eax
f0106b53:	ff 70 04             	push   0x4(%eax)
f0106b56:	68 8c 8f 10 f0       	push   $0xf0108f8c
f0106b5b:	e8 71 cf ff ff       	call   f0103ad1 <cprintf>

	pci_scan_bus(&nbus);
f0106b60:	83 c4 20             	add    $0x20,%esp
f0106b63:	89 f8                	mov    %edi,%eax
f0106b65:	e8 b2 fd ff ff       	call   f010691c <pci_scan_bus>
	return 1;
f0106b6a:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0106b6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106b72:	5b                   	pop    %ebx
f0106b73:	5e                   	pop    %esi
f0106b74:	5f                   	pop    %edi
f0106b75:	5d                   	pop    %ebp
f0106b76:	c3                   	ret    
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f0106b77:	ff 76 08             	push   0x8(%esi)
f0106b7a:	ff 76 04             	push   0x4(%esi)
f0106b7d:	8b 06                	mov    (%esi),%eax
f0106b7f:	ff 70 04             	push   0x4(%eax)
f0106b82:	68 58 8f 10 f0       	push   $0xf0108f58
f0106b87:	e8 45 cf ff ff       	call   f0103ad1 <cprintf>
		return 0;
f0106b8c:	83 c4 10             	add    $0x10,%esp
f0106b8f:	b8 00 00 00 00       	mov    $0x0,%eax
f0106b94:	eb d9                	jmp    f0106b6f <pci_bridge_attach+0x78>

f0106b96 <pci_conf_write>:
{
f0106b96:	55                   	push   %ebp
f0106b97:	89 e5                	mov    %esp,%ebp
f0106b99:	57                   	push   %edi
f0106b9a:	56                   	push   %esi
f0106b9b:	53                   	push   %ebx
f0106b9c:	83 ec 18             	sub    $0x18,%esp
f0106b9f:	89 d7                	mov    %edx,%edi
f0106ba1:	89 ce                	mov    %ecx,%esi
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106ba3:	8b 48 08             	mov    0x8(%eax),%ecx
f0106ba6:	8b 50 04             	mov    0x4(%eax),%edx
f0106ba9:	8b 00                	mov    (%eax),%eax
f0106bab:	8b 40 04             	mov    0x4(%eax),%eax
f0106bae:	57                   	push   %edi
f0106baf:	e8 8b fc ff ff       	call   f010683f <pci_conf1_set_addr>
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0106bb4:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0106bb9:	89 f0                	mov    %esi,%eax
f0106bbb:	ef                   	out    %eax,(%dx)
}
f0106bbc:	83 c4 10             	add    $0x10,%esp
f0106bbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106bc2:	5b                   	pop    %ebx
f0106bc3:	5e                   	pop    %esi
f0106bc4:	5f                   	pop    %edi
f0106bc5:	5d                   	pop    %ebp
f0106bc6:	c3                   	ret    

f0106bc7 <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f0106bc7:	55                   	push   %ebp
f0106bc8:	89 e5                	mov    %esp,%ebp
f0106bca:	57                   	push   %edi
f0106bcb:	56                   	push   %esi
f0106bcc:	53                   	push   %ebx
f0106bcd:	83 ec 1c             	sub    $0x1c,%esp
f0106bd0:	8b 7d 08             	mov    0x8(%ebp),%edi
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f0106bd3:	b9 07 00 00 00       	mov    $0x7,%ecx
f0106bd8:	ba 04 00 00 00       	mov    $0x4,%edx
f0106bdd:	89 f8                	mov    %edi,%eax
f0106bdf:	e8 b2 ff ff ff       	call   f0106b96 <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106be4:	be 10 00 00 00       	mov    $0x10,%esi
f0106be9:	eb 27                	jmp    f0106c12 <pci_func_enable+0x4b>
			base = PCI_MAPREG_MEM_ADDR(oldv);
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f0106beb:	89 d8                	mov    %ebx,%eax
f0106bed:	83 e0 fc             	and    $0xfffffffc,%eax
f0106bf0:	f7 d8                	neg    %eax
f0106bf2:	21 c3                	and    %eax,%ebx
			base = PCI_MAPREG_IO_ADDR(oldv);
f0106bf4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106bf7:	83 e0 fc             	and    $0xfffffffc,%eax
f0106bfa:	89 45 dc             	mov    %eax,-0x24(%ebp)
		bar_width = 4;
f0106bfd:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
f0106c04:	eb 78                	jmp    f0106c7e <pci_func_enable+0xb7>
	     bar += bar_width)
f0106c06:	03 75 e4             	add    -0x1c(%ebp),%esi
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106c09:	83 fe 27             	cmp    $0x27,%esi
f0106c0c:	0f 87 c7 00 00 00    	ja     f0106cd9 <pci_func_enable+0x112>
		uint32_t oldv = pci_conf_read(f, bar);
f0106c12:	89 f2                	mov    %esi,%edx
f0106c14:	89 f8                	mov    %edi,%eax
f0106c16:	e8 dc fc ff ff       	call   f01068f7 <pci_conf_read>
f0106c1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		pci_conf_write(f, bar, 0xffffffff);
f0106c1e:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f0106c23:	89 f2                	mov    %esi,%edx
f0106c25:	89 f8                	mov    %edi,%eax
f0106c27:	e8 6a ff ff ff       	call   f0106b96 <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f0106c2c:	89 f2                	mov    %esi,%edx
f0106c2e:	89 f8                	mov    %edi,%eax
f0106c30:	e8 c2 fc ff ff       	call   f01068f7 <pci_conf_read>
f0106c35:	89 c3                	mov    %eax,%ebx
		bar_width = 4;
f0106c37:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
		if (rv == 0)
f0106c3e:	85 c0                	test   %eax,%eax
f0106c40:	74 c4                	je     f0106c06 <pci_func_enable+0x3f>
		int regnum = PCI_MAPREG_NUM(bar);
f0106c42:	8d 46 f0             	lea    -0x10(%esi),%eax
f0106c45:	89 c2                	mov    %eax,%edx
f0106c47:	c1 ea 02             	shr    $0x2,%edx
f0106c4a:	89 55 d8             	mov    %edx,-0x28(%ebp)
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f0106c4d:	f6 c3 01             	test   $0x1,%bl
f0106c50:	75 99                	jne    f0106beb <pci_func_enable+0x24>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f0106c52:	89 da                	mov    %ebx,%edx
f0106c54:	83 e2 06             	and    $0x6,%edx
				bar_width = 8;
f0106c57:	83 fa 04             	cmp    $0x4,%edx
f0106c5a:	0f 94 c1             	sete   %cl
f0106c5d:	0f b6 c9             	movzbl %cl,%ecx
f0106c60:	8d 14 8d 04 00 00 00 	lea    0x4(,%ecx,4),%edx
f0106c67:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			size = PCI_MAPREG_MEM_SIZE(rv);
f0106c6a:	89 da                	mov    %ebx,%edx
f0106c6c:	83 e2 f0             	and    $0xfffffff0,%edx
f0106c6f:	89 d0                	mov    %edx,%eax
f0106c71:	f7 d8                	neg    %eax
f0106c73:	21 c3                	and    %eax,%ebx
			base = PCI_MAPREG_MEM_ADDR(oldv);
f0106c75:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106c78:	83 e0 f0             	and    $0xfffffff0,%eax
f0106c7b:	89 45 dc             	mov    %eax,-0x24(%ebp)
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f0106c7e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0106c81:	89 f2                	mov    %esi,%edx
f0106c83:	89 f8                	mov    %edi,%eax
f0106c85:	e8 0c ff ff ff       	call   f0106b96 <pci_conf_write>
		f->reg_base[regnum] = base;
f0106c8a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0106c8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106c90:	89 44 8f 14          	mov    %eax,0x14(%edi,%ecx,4)
		f->reg_size[regnum] = size;
f0106c94:	89 5c 8f 2c          	mov    %ebx,0x2c(%edi,%ecx,4)

		if (size && !base)
f0106c98:	85 db                	test   %ebx,%ebx
f0106c9a:	0f 84 66 ff ff ff    	je     f0106c06 <pci_func_enable+0x3f>
f0106ca0:	85 c0                	test   %eax,%eax
f0106ca2:	0f 85 5e ff ff ff    	jne    f0106c06 <pci_func_enable+0x3f>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0106ca8:	8b 47 0c             	mov    0xc(%edi),%eax
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f0106cab:	83 ec 0c             	sub    $0xc,%esp
f0106cae:	53                   	push   %ebx
f0106caf:	6a 00                	push   $0x0
f0106cb1:	51                   	push   %ecx
f0106cb2:	89 c2                	mov    %eax,%edx
f0106cb4:	c1 ea 10             	shr    $0x10,%edx
f0106cb7:	52                   	push   %edx
f0106cb8:	0f b7 c0             	movzwl %ax,%eax
f0106cbb:	50                   	push   %eax
f0106cbc:	ff 77 08             	push   0x8(%edi)
f0106cbf:	ff 77 04             	push   0x4(%edi)
f0106cc2:	8b 07                	mov    (%edi),%eax
f0106cc4:	ff 70 04             	push   0x4(%eax)
f0106cc7:	68 bc 8f 10 f0       	push   $0xf0108fbc
f0106ccc:	e8 00 ce ff ff       	call   f0103ad1 <cprintf>
f0106cd1:	83 c4 30             	add    $0x30,%esp
f0106cd4:	e9 2d ff ff ff       	jmp    f0106c06 <pci_func_enable+0x3f>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f0106cd9:	8b 47 0c             	mov    0xc(%edi),%eax
	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f0106cdc:	83 ec 08             	sub    $0x8,%esp
f0106cdf:	89 c2                	mov    %eax,%edx
f0106ce1:	c1 ea 10             	shr    $0x10,%edx
f0106ce4:	52                   	push   %edx
f0106ce5:	0f b7 c0             	movzwl %ax,%eax
f0106ce8:	50                   	push   %eax
f0106ce9:	ff 77 08             	push   0x8(%edi)
f0106cec:	ff 77 04             	push   0x4(%edi)
f0106cef:	8b 07                	mov    (%edi),%eax
f0106cf1:	ff 70 04             	push   0x4(%eax)
f0106cf4:	68 18 90 10 f0       	push   $0xf0109018
f0106cf9:	e8 d3 cd ff ff       	call   f0103ad1 <cprintf>
}
f0106cfe:	83 c4 20             	add    $0x20,%esp
f0106d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106d04:	5b                   	pop    %ebx
f0106d05:	5e                   	pop    %esi
f0106d06:	5f                   	pop    %edi
f0106d07:	5d                   	pop    %ebp
f0106d08:	c3                   	ret    

f0106d09 <pci_init>:

int
pci_init(void)
{
f0106d09:	55                   	push   %ebp
f0106d0a:	89 e5                	mov    %esp,%ebp
f0106d0c:	83 ec 0c             	sub    $0xc,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f0106d0f:	6a 08                	push   $0x8
f0106d11:	6a 00                	push   $0x0
f0106d13:	68 a4 9b 34 f0       	push   $0xf0349ba4
f0106d18:	e8 d0 ed ff ff       	call   f0105aed <memset>

	return pci_scan_bus(&root_bus);
f0106d1d:	b8 a4 9b 34 f0       	mov    $0xf0349ba4,%eax
f0106d22:	e8 f5 fb ff ff       	call   f010691c <pci_scan_bus>
}
f0106d27:	c9                   	leave  
f0106d28:	c3                   	ret    

f0106d29 <time_init>:
static unsigned int ticks;

void
time_init(void)
{
	ticks = 0;
f0106d29:	c7 05 ac 9b 34 f0 00 	movl   $0x0,0xf0349bac
f0106d30:	00 00 00 
}
f0106d33:	c3                   	ret    

f0106d34 <time_tick>:
// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
	ticks++;
f0106d34:	a1 ac 9b 34 f0       	mov    0xf0349bac,%eax
f0106d39:	83 c0 01             	add    $0x1,%eax
f0106d3c:	a3 ac 9b 34 f0       	mov    %eax,0xf0349bac
	if (ticks * 10 < ticks)
f0106d41:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0106d44:	01 d2                	add    %edx,%edx
f0106d46:	39 d0                	cmp    %edx,%eax
f0106d48:	77 01                	ja     f0106d4b <time_tick+0x17>
f0106d4a:	c3                   	ret    
{
f0106d4b:	55                   	push   %ebp
f0106d4c:	89 e5                	mov    %esp,%ebp
f0106d4e:	83 ec 0c             	sub    $0xc,%esp
		panic("time_tick: time overflowed");
f0106d51:	68 20 91 10 f0       	push   $0xf0109120
f0106d56:	6a 13                	push   $0x13
f0106d58:	68 3b 91 10 f0       	push   $0xf010913b
f0106d5d:	e8 de 92 ff ff       	call   f0100040 <_panic>

f0106d62 <time_msec>:
}

unsigned int
time_msec(void)
{
	return ticks * 10;
f0106d62:	a1 ac 9b 34 f0       	mov    0xf0349bac,%eax
f0106d67:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0106d6a:	01 c0                	add    %eax,%eax
}
f0106d6c:	c3                   	ret    
f0106d6d:	66 90                	xchg   %ax,%ax
f0106d6f:	90                   	nop

f0106d70 <__udivdi3>:
f0106d70:	f3 0f 1e fb          	endbr32 
f0106d74:	55                   	push   %ebp
f0106d75:	57                   	push   %edi
f0106d76:	56                   	push   %esi
f0106d77:	53                   	push   %ebx
f0106d78:	83 ec 1c             	sub    $0x1c,%esp
f0106d7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0106d7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106d83:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106d87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0106d8b:	85 c0                	test   %eax,%eax
f0106d8d:	75 19                	jne    f0106da8 <__udivdi3+0x38>
f0106d8f:	39 f3                	cmp    %esi,%ebx
f0106d91:	76 4d                	jbe    f0106de0 <__udivdi3+0x70>
f0106d93:	31 ff                	xor    %edi,%edi
f0106d95:	89 e8                	mov    %ebp,%eax
f0106d97:	89 f2                	mov    %esi,%edx
f0106d99:	f7 f3                	div    %ebx
f0106d9b:	89 fa                	mov    %edi,%edx
f0106d9d:	83 c4 1c             	add    $0x1c,%esp
f0106da0:	5b                   	pop    %ebx
f0106da1:	5e                   	pop    %esi
f0106da2:	5f                   	pop    %edi
f0106da3:	5d                   	pop    %ebp
f0106da4:	c3                   	ret    
f0106da5:	8d 76 00             	lea    0x0(%esi),%esi
f0106da8:	39 f0                	cmp    %esi,%eax
f0106daa:	76 14                	jbe    f0106dc0 <__udivdi3+0x50>
f0106dac:	31 ff                	xor    %edi,%edi
f0106dae:	31 c0                	xor    %eax,%eax
f0106db0:	89 fa                	mov    %edi,%edx
f0106db2:	83 c4 1c             	add    $0x1c,%esp
f0106db5:	5b                   	pop    %ebx
f0106db6:	5e                   	pop    %esi
f0106db7:	5f                   	pop    %edi
f0106db8:	5d                   	pop    %ebp
f0106db9:	c3                   	ret    
f0106dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106dc0:	0f bd f8             	bsr    %eax,%edi
f0106dc3:	83 f7 1f             	xor    $0x1f,%edi
f0106dc6:	75 48                	jne    f0106e10 <__udivdi3+0xa0>
f0106dc8:	39 f0                	cmp    %esi,%eax
f0106dca:	72 06                	jb     f0106dd2 <__udivdi3+0x62>
f0106dcc:	31 c0                	xor    %eax,%eax
f0106dce:	39 eb                	cmp    %ebp,%ebx
f0106dd0:	77 de                	ja     f0106db0 <__udivdi3+0x40>
f0106dd2:	b8 01 00 00 00       	mov    $0x1,%eax
f0106dd7:	eb d7                	jmp    f0106db0 <__udivdi3+0x40>
f0106dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106de0:	89 d9                	mov    %ebx,%ecx
f0106de2:	85 db                	test   %ebx,%ebx
f0106de4:	75 0b                	jne    f0106df1 <__udivdi3+0x81>
f0106de6:	b8 01 00 00 00       	mov    $0x1,%eax
f0106deb:	31 d2                	xor    %edx,%edx
f0106ded:	f7 f3                	div    %ebx
f0106def:	89 c1                	mov    %eax,%ecx
f0106df1:	31 d2                	xor    %edx,%edx
f0106df3:	89 f0                	mov    %esi,%eax
f0106df5:	f7 f1                	div    %ecx
f0106df7:	89 c6                	mov    %eax,%esi
f0106df9:	89 e8                	mov    %ebp,%eax
f0106dfb:	89 f7                	mov    %esi,%edi
f0106dfd:	f7 f1                	div    %ecx
f0106dff:	89 fa                	mov    %edi,%edx
f0106e01:	83 c4 1c             	add    $0x1c,%esp
f0106e04:	5b                   	pop    %ebx
f0106e05:	5e                   	pop    %esi
f0106e06:	5f                   	pop    %edi
f0106e07:	5d                   	pop    %ebp
f0106e08:	c3                   	ret    
f0106e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106e10:	89 f9                	mov    %edi,%ecx
f0106e12:	ba 20 00 00 00       	mov    $0x20,%edx
f0106e17:	29 fa                	sub    %edi,%edx
f0106e19:	d3 e0                	shl    %cl,%eax
f0106e1b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106e1f:	89 d1                	mov    %edx,%ecx
f0106e21:	89 d8                	mov    %ebx,%eax
f0106e23:	d3 e8                	shr    %cl,%eax
f0106e25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106e29:	09 c1                	or     %eax,%ecx
f0106e2b:	89 f0                	mov    %esi,%eax
f0106e2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106e31:	89 f9                	mov    %edi,%ecx
f0106e33:	d3 e3                	shl    %cl,%ebx
f0106e35:	89 d1                	mov    %edx,%ecx
f0106e37:	d3 e8                	shr    %cl,%eax
f0106e39:	89 f9                	mov    %edi,%ecx
f0106e3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106e3f:	89 eb                	mov    %ebp,%ebx
f0106e41:	d3 e6                	shl    %cl,%esi
f0106e43:	89 d1                	mov    %edx,%ecx
f0106e45:	d3 eb                	shr    %cl,%ebx
f0106e47:	09 f3                	or     %esi,%ebx
f0106e49:	89 c6                	mov    %eax,%esi
f0106e4b:	89 f2                	mov    %esi,%edx
f0106e4d:	89 d8                	mov    %ebx,%eax
f0106e4f:	f7 74 24 08          	divl   0x8(%esp)
f0106e53:	89 d6                	mov    %edx,%esi
f0106e55:	89 c3                	mov    %eax,%ebx
f0106e57:	f7 64 24 0c          	mull   0xc(%esp)
f0106e5b:	39 d6                	cmp    %edx,%esi
f0106e5d:	72 19                	jb     f0106e78 <__udivdi3+0x108>
f0106e5f:	89 f9                	mov    %edi,%ecx
f0106e61:	d3 e5                	shl    %cl,%ebp
f0106e63:	39 c5                	cmp    %eax,%ebp
f0106e65:	73 04                	jae    f0106e6b <__udivdi3+0xfb>
f0106e67:	39 d6                	cmp    %edx,%esi
f0106e69:	74 0d                	je     f0106e78 <__udivdi3+0x108>
f0106e6b:	89 d8                	mov    %ebx,%eax
f0106e6d:	31 ff                	xor    %edi,%edi
f0106e6f:	e9 3c ff ff ff       	jmp    f0106db0 <__udivdi3+0x40>
f0106e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106e78:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0106e7b:	31 ff                	xor    %edi,%edi
f0106e7d:	e9 2e ff ff ff       	jmp    f0106db0 <__udivdi3+0x40>
f0106e82:	66 90                	xchg   %ax,%ax
f0106e84:	66 90                	xchg   %ax,%ax
f0106e86:	66 90                	xchg   %ax,%ax
f0106e88:	66 90                	xchg   %ax,%ax
f0106e8a:	66 90                	xchg   %ax,%ax
f0106e8c:	66 90                	xchg   %ax,%ax
f0106e8e:	66 90                	xchg   %ax,%ax

f0106e90 <__umoddi3>:
f0106e90:	f3 0f 1e fb          	endbr32 
f0106e94:	55                   	push   %ebp
f0106e95:	57                   	push   %edi
f0106e96:	56                   	push   %esi
f0106e97:	53                   	push   %ebx
f0106e98:	83 ec 1c             	sub    $0x1c,%esp
f0106e9b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0106e9f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106ea3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0106ea7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0106eab:	89 f0                	mov    %esi,%eax
f0106ead:	89 da                	mov    %ebx,%edx
f0106eaf:	85 ff                	test   %edi,%edi
f0106eb1:	75 15                	jne    f0106ec8 <__umoddi3+0x38>
f0106eb3:	39 dd                	cmp    %ebx,%ebp
f0106eb5:	76 39                	jbe    f0106ef0 <__umoddi3+0x60>
f0106eb7:	f7 f5                	div    %ebp
f0106eb9:	89 d0                	mov    %edx,%eax
f0106ebb:	31 d2                	xor    %edx,%edx
f0106ebd:	83 c4 1c             	add    $0x1c,%esp
f0106ec0:	5b                   	pop    %ebx
f0106ec1:	5e                   	pop    %esi
f0106ec2:	5f                   	pop    %edi
f0106ec3:	5d                   	pop    %ebp
f0106ec4:	c3                   	ret    
f0106ec5:	8d 76 00             	lea    0x0(%esi),%esi
f0106ec8:	39 df                	cmp    %ebx,%edi
f0106eca:	77 f1                	ja     f0106ebd <__umoddi3+0x2d>
f0106ecc:	0f bd cf             	bsr    %edi,%ecx
f0106ecf:	83 f1 1f             	xor    $0x1f,%ecx
f0106ed2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106ed6:	75 40                	jne    f0106f18 <__umoddi3+0x88>
f0106ed8:	39 df                	cmp    %ebx,%edi
f0106eda:	72 04                	jb     f0106ee0 <__umoddi3+0x50>
f0106edc:	39 f5                	cmp    %esi,%ebp
f0106ede:	77 dd                	ja     f0106ebd <__umoddi3+0x2d>
f0106ee0:	89 da                	mov    %ebx,%edx
f0106ee2:	89 f0                	mov    %esi,%eax
f0106ee4:	29 e8                	sub    %ebp,%eax
f0106ee6:	19 fa                	sbb    %edi,%edx
f0106ee8:	eb d3                	jmp    f0106ebd <__umoddi3+0x2d>
f0106eea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106ef0:	89 e9                	mov    %ebp,%ecx
f0106ef2:	85 ed                	test   %ebp,%ebp
f0106ef4:	75 0b                	jne    f0106f01 <__umoddi3+0x71>
f0106ef6:	b8 01 00 00 00       	mov    $0x1,%eax
f0106efb:	31 d2                	xor    %edx,%edx
f0106efd:	f7 f5                	div    %ebp
f0106eff:	89 c1                	mov    %eax,%ecx
f0106f01:	89 d8                	mov    %ebx,%eax
f0106f03:	31 d2                	xor    %edx,%edx
f0106f05:	f7 f1                	div    %ecx
f0106f07:	89 f0                	mov    %esi,%eax
f0106f09:	f7 f1                	div    %ecx
f0106f0b:	89 d0                	mov    %edx,%eax
f0106f0d:	31 d2                	xor    %edx,%edx
f0106f0f:	eb ac                	jmp    f0106ebd <__umoddi3+0x2d>
f0106f11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106f18:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106f1c:	ba 20 00 00 00       	mov    $0x20,%edx
f0106f21:	29 c2                	sub    %eax,%edx
f0106f23:	89 c1                	mov    %eax,%ecx
f0106f25:	89 e8                	mov    %ebp,%eax
f0106f27:	d3 e7                	shl    %cl,%edi
f0106f29:	89 d1                	mov    %edx,%ecx
f0106f2b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106f2f:	d3 e8                	shr    %cl,%eax
f0106f31:	89 c1                	mov    %eax,%ecx
f0106f33:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106f37:	09 f9                	or     %edi,%ecx
f0106f39:	89 df                	mov    %ebx,%edi
f0106f3b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106f3f:	89 c1                	mov    %eax,%ecx
f0106f41:	d3 e5                	shl    %cl,%ebp
f0106f43:	89 d1                	mov    %edx,%ecx
f0106f45:	d3 ef                	shr    %cl,%edi
f0106f47:	89 c1                	mov    %eax,%ecx
f0106f49:	89 f0                	mov    %esi,%eax
f0106f4b:	d3 e3                	shl    %cl,%ebx
f0106f4d:	89 d1                	mov    %edx,%ecx
f0106f4f:	89 fa                	mov    %edi,%edx
f0106f51:	d3 e8                	shr    %cl,%eax
f0106f53:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106f58:	09 d8                	or     %ebx,%eax
f0106f5a:	f7 74 24 08          	divl   0x8(%esp)
f0106f5e:	89 d3                	mov    %edx,%ebx
f0106f60:	d3 e6                	shl    %cl,%esi
f0106f62:	f7 e5                	mul    %ebp
f0106f64:	89 c7                	mov    %eax,%edi
f0106f66:	89 d1                	mov    %edx,%ecx
f0106f68:	39 d3                	cmp    %edx,%ebx
f0106f6a:	72 06                	jb     f0106f72 <__umoddi3+0xe2>
f0106f6c:	75 0e                	jne    f0106f7c <__umoddi3+0xec>
f0106f6e:	39 c6                	cmp    %eax,%esi
f0106f70:	73 0a                	jae    f0106f7c <__umoddi3+0xec>
f0106f72:	29 e8                	sub    %ebp,%eax
f0106f74:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106f78:	89 d1                	mov    %edx,%ecx
f0106f7a:	89 c7                	mov    %eax,%edi
f0106f7c:	89 f5                	mov    %esi,%ebp
f0106f7e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106f82:	29 fd                	sub    %edi,%ebp
f0106f84:	19 cb                	sbb    %ecx,%ebx
f0106f86:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0106f8b:	89 d8                	mov    %ebx,%eax
f0106f8d:	d3 e0                	shl    %cl,%eax
f0106f8f:	89 f1                	mov    %esi,%ecx
f0106f91:	d3 ed                	shr    %cl,%ebp
f0106f93:	d3 eb                	shr    %cl,%ebx
f0106f95:	09 e8                	or     %ebp,%eax
f0106f97:	89 da                	mov    %ebx,%edx
f0106f99:	83 c4 1c             	add    $0x1c,%esp
f0106f9c:	5b                   	pop    %ebx
f0106f9d:	5e                   	pop    %esi
f0106f9e:	5f                   	pop    %edi
f0106f9f:	5d                   	pop    %ebp
f0106fa0:	c3                   	ret    
