
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
f0100015:	b8 00 60 12 00       	mov    $0x126000,%eax
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
f0100034:	bc 00 60 12 f0       	mov    $0xf0126000,%esp

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
f0100047:	83 3d 00 60 2b f0 00 	cmpl   $0x0,0xf02b6000
f010004e:	74 0f                	je     f010005f <_panic+0x1f>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100050:	83 ec 0c             	sub    $0xc,%esp
f0100053:	6a 00                	push   $0x0
f0100055:	e8 30 09 00 00       	call   f010098a <monitor>
f010005a:	83 c4 10             	add    $0x10,%esp
f010005d:	eb f1                	jmp    f0100050 <_panic+0x10>
	panicstr = fmt;
f010005f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100062:	a3 00 60 2b f0       	mov    %eax,0xf02b6000
	asm volatile("cli; cld");
f0100067:	fa                   	cli    
f0100068:	fc                   	cld    
	va_start(ap, fmt);
f0100069:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006c:	e8 f3 5d 00 00       	call   f0105e64 <cpunum>
f0100071:	ff 75 0c             	push   0xc(%ebp)
f0100074:	ff 75 08             	push   0x8(%ebp)
f0100077:	50                   	push   %eax
f0100078:	68 40 6d 10 f0       	push   $0xf0106d40
f010007d:	e8 33 39 00 00       	call   f01039b5 <cprintf>
	vcprintf(fmt, ap);
f0100082:	83 c4 08             	add    $0x8,%esp
f0100085:	53                   	push   %ebx
f0100086:	ff 75 10             	push   0x10(%ebp)
f0100089:	e8 01 39 00 00       	call   f010398f <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 b3 75 10 f0 	movl   $0xf01075b3,(%esp)
f0100095:	e8 1b 39 00 00       	call   f01039b5 <cprintf>
f010009a:	83 c4 10             	add    $0x10,%esp
f010009d:	eb b1                	jmp    f0100050 <_panic+0x10>

f010009f <i386_init>:
{
f010009f:	55                   	push   %ebp
f01000a0:	89 e5                	mov    %esp,%ebp
f01000a2:	53                   	push   %ebx
f01000a3:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000a6:	e8 ab 05 00 00       	call   f0100656 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ab:	83 ec 08             	sub    $0x8,%esp
f01000ae:	68 ac 1a 00 00       	push   $0x1aac
f01000b3:	68 ac 6d 10 f0       	push   $0xf0106dac
f01000b8:	e8 f8 38 00 00       	call   f01039b5 <cprintf>
	mem_init();
f01000bd:	e8 77 12 00 00       	call   f0101339 <mem_init>
	env_init();
f01000c2:	e8 a8 30 00 00       	call   f010316f <env_init>
	trap_init();
f01000c7:	e8 db 39 00 00       	call   f0103aa7 <trap_init>
	mp_init();
f01000cc:	e8 ad 5a 00 00       	call   f0105b7e <mp_init>
	lapic_init();
f01000d1:	e8 a4 5d 00 00       	call   f0105e7a <lapic_init>
	pic_init();
f01000d6:	e8 e9 37 00 00       	call   f01038c4 <pic_init>
	time_init();
f01000db:	e8 c9 69 00 00       	call   f0106aa9 <time_init>
	pci_init();
f01000e0:	e8 a4 69 00 00       	call   f0106a89 <pci_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000e5:	c7 04 24 c0 83 12 f0 	movl   $0xf01283c0,(%esp)
f01000ec:	e8 e3 5f 00 00       	call   f01060d4 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f1:	83 c4 10             	add    $0x10,%esp
f01000f4:	83 3d 60 62 2b f0 07 	cmpl   $0x7,0xf02b6260
f01000fb:	76 27                	jbe    f0100124 <i386_init+0x85>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000fd:	83 ec 04             	sub    $0x4,%esp
f0100100:	b8 da 5a 10 f0       	mov    $0xf0105ada,%eax
f0100105:	2d 60 5a 10 f0       	sub    $0xf0105a60,%eax
f010010a:	50                   	push   %eax
f010010b:	68 60 5a 10 f0       	push   $0xf0105a60
f0100110:	68 00 70 00 f0       	push   $0xf0007000
f0100115:	e8 99 57 00 00       	call   f01058b3 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f010011a:	83 c4 10             	add    $0x10,%esp
f010011d:	bb 20 70 2f f0       	mov    $0xf02f7020,%ebx
f0100122:	eb 19                	jmp    f010013d <i386_init+0x9e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100124:	68 00 70 00 00       	push   $0x7000
f0100129:	68 64 6d 10 f0       	push   $0xf0106d64
f010012e:	6a 64                	push   $0x64
f0100130:	68 c7 6d 10 f0       	push   $0xf0106dc7
f0100135:	e8 06 ff ff ff       	call   f0100040 <_panic>
f010013a:	83 c3 74             	add    $0x74,%ebx
f010013d:	6b 05 00 70 2f f0 74 	imul   $0x74,0xf02f7000,%eax
f0100144:	05 20 70 2f f0       	add    $0xf02f7020,%eax
f0100149:	39 c3                	cmp    %eax,%ebx
f010014b:	73 4d                	jae    f010019a <i386_init+0xfb>
		if (c == cpus + cpunum())  // We've started already.
f010014d:	e8 12 5d 00 00       	call   f0105e64 <cpunum>
f0100152:	6b c0 74             	imul   $0x74,%eax,%eax
f0100155:	05 20 70 2f f0       	add    $0xf02f7020,%eax
f010015a:	39 c3                	cmp    %eax,%ebx
f010015c:	74 dc                	je     f010013a <i386_init+0x9b>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010015e:	89 d8                	mov    %ebx,%eax
f0100160:	2d 20 70 2f f0       	sub    $0xf02f7020,%eax
f0100165:	c1 f8 02             	sar    $0x2,%eax
f0100168:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010016e:	c1 e0 0f             	shl    $0xf,%eax
f0100171:	8d 80 00 f0 2b f0    	lea    -0xfd41000(%eax),%eax
f0100177:	a3 04 60 2b f0       	mov    %eax,0xf02b6004
		lapic_startap(c->cpu_id, PADDR(code));
f010017c:	83 ec 08             	sub    $0x8,%esp
f010017f:	68 00 70 00 00       	push   $0x7000
f0100184:	0f b6 03             	movzbl (%ebx),%eax
f0100187:	50                   	push   %eax
f0100188:	e8 3f 5e 00 00       	call   f0105fcc <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f010018d:	83 c4 10             	add    $0x10,%esp
f0100190:	8b 43 04             	mov    0x4(%ebx),%eax
f0100193:	83 f8 01             	cmp    $0x1,%eax
f0100196:	75 f8                	jne    f0100190 <i386_init+0xf1>
f0100198:	eb a0                	jmp    f010013a <i386_init+0x9b>
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010019a:	83 ec 08             	sub    $0x8,%esp
f010019d:	6a 01                	push   $0x1
f010019f:	68 78 f7 1d f0       	push   $0xf01df778
f01001a4:	e8 91 31 00 00       	call   f010333a <env_create>
	ENV_CREATE(net_ns, ENV_TYPE_NS);
f01001a9:	83 c4 08             	add    $0x8,%esp
f01001ac:	6a 02                	push   $0x2
f01001ae:	68 70 4b 23 f0       	push   $0xf0234b70
f01001b3:	e8 82 31 00 00       	call   f010333a <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001b8:	83 c4 08             	add    $0x8,%esp
f01001bb:	6a 00                	push   $0x0
f01001bd:	68 2c ff 1f f0       	push   $0xf01fff2c
f01001c2:	e8 73 31 00 00       	call   f010333a <env_create>
	kbd_intr();
f01001c7:	e8 36 04 00 00       	call   f0100602 <kbd_intr>
	sched_yield();
f01001cc:	e8 12 44 00 00       	call   f01045e3 <sched_yield>

f01001d1 <mp_main>:
{
f01001d1:	55                   	push   %ebp
f01001d2:	89 e5                	mov    %esp,%ebp
f01001d4:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001d7:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001dc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001e1:	76 52                	jbe    f0100235 <mp_main+0x64>
	return (physaddr_t)kva - KERNBASE;
f01001e3:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f01001e8:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001eb:	e8 74 5c 00 00       	call   f0105e64 <cpunum>
f01001f0:	83 ec 08             	sub    $0x8,%esp
f01001f3:	50                   	push   %eax
f01001f4:	68 d3 6d 10 f0       	push   $0xf0106dd3
f01001f9:	e8 b7 37 00 00       	call   f01039b5 <cprintf>
	lapic_init();
f01001fe:	e8 77 5c 00 00       	call   f0105e7a <lapic_init>
	env_init_percpu();
f0100203:	e8 3b 2f 00 00       	call   f0103143 <env_init_percpu>
	trap_init_percpu();
f0100208:	e8 bc 37 00 00       	call   f01039c9 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010020d:	e8 52 5c 00 00       	call   f0105e64 <cpunum>
f0100212:	6b d0 74             	imul   $0x74,%eax,%edx
f0100215:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100218:	b8 01 00 00 00       	mov    $0x1,%eax
f010021d:	f0 87 82 20 70 2f f0 	lock xchg %eax,-0xfd08fe0(%edx)
f0100224:	c7 04 24 c0 83 12 f0 	movl   $0xf01283c0,(%esp)
f010022b:	e8 a4 5e 00 00       	call   f01060d4 <spin_lock>
	sched_yield();
f0100230:	e8 ae 43 00 00       	call   f01045e3 <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100235:	50                   	push   %eax
f0100236:	68 88 6d 10 f0       	push   $0xf0106d88
f010023b:	6a 7b                	push   $0x7b
f010023d:	68 c7 6d 10 f0       	push   $0xf0106dc7
f0100242:	e8 f9 fd ff ff       	call   f0100040 <_panic>

f0100247 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100247:	55                   	push   %ebp
f0100248:	89 e5                	mov    %esp,%ebp
f010024a:	53                   	push   %ebx
f010024b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010024e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100251:	ff 75 0c             	push   0xc(%ebp)
f0100254:	ff 75 08             	push   0x8(%ebp)
f0100257:	68 e9 6d 10 f0       	push   $0xf0106de9
f010025c:	e8 54 37 00 00       	call   f01039b5 <cprintf>
	vcprintf(fmt, ap);
f0100261:	83 c4 08             	add    $0x8,%esp
f0100264:	53                   	push   %ebx
f0100265:	ff 75 10             	push   0x10(%ebp)
f0100268:	e8 22 37 00 00       	call   f010398f <vcprintf>
	cprintf("\n");
f010026d:	c7 04 24 b3 75 10 f0 	movl   $0xf01075b3,(%esp)
f0100274:	e8 3c 37 00 00       	call   f01039b5 <cprintf>
	va_end(ap);
}
f0100279:	83 c4 10             	add    $0x10,%esp
f010027c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010027f:	c9                   	leave  
f0100280:	c3                   	ret    

f0100281 <serial_proc_data>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100281:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100286:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100287:	a8 01                	test   $0x1,%al
f0100289:	74 0a                	je     f0100295 <serial_proc_data+0x14>
f010028b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100290:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100291:	0f b6 c0             	movzbl %al,%eax
f0100294:	c3                   	ret    
		return -1;
f0100295:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010029a:	c3                   	ret    

f010029b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010029b:	55                   	push   %ebp
f010029c:	89 e5                	mov    %esp,%ebp
f010029e:	53                   	push   %ebx
f010029f:	83 ec 04             	sub    $0x4,%esp
f01002a2:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002a4:	eb 23                	jmp    f01002c9 <cons_intr+0x2e>
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01002a6:	8b 0d 44 62 2b f0    	mov    0xf02b6244,%ecx
f01002ac:	8d 51 01             	lea    0x1(%ecx),%edx
f01002af:	88 81 40 60 2b f0    	mov    %al,-0xfd49fc0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002b5:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01002c0:	0f 44 d0             	cmove  %eax,%edx
f01002c3:	89 15 44 62 2b f0    	mov    %edx,0xf02b6244
	while ((c = (*proc)()) != -1) {
f01002c9:	ff d3                	call   *%ebx
f01002cb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002ce:	74 06                	je     f01002d6 <cons_intr+0x3b>
		if (c == 0)
f01002d0:	85 c0                	test   %eax,%eax
f01002d2:	75 d2                	jne    f01002a6 <cons_intr+0xb>
f01002d4:	eb f3                	jmp    f01002c9 <cons_intr+0x2e>
	}
}
f01002d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002d9:	c9                   	leave  
f01002da:	c3                   	ret    

f01002db <kbd_proc_data>:
{
f01002db:	55                   	push   %ebp
f01002dc:	89 e5                	mov    %esp,%ebp
f01002de:	53                   	push   %ebx
f01002df:	83 ec 04             	sub    $0x4,%esp
f01002e2:	ba 64 00 00 00       	mov    $0x64,%edx
f01002e7:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002e8:	a8 01                	test   $0x1,%al
f01002ea:	0f 84 ee 00 00 00    	je     f01003de <kbd_proc_data+0x103>
	if (stat & KBS_TERR)
f01002f0:	a8 20                	test   $0x20,%al
f01002f2:	0f 85 ed 00 00 00    	jne    f01003e5 <kbd_proc_data+0x10a>
f01002f8:	ba 60 00 00 00       	mov    $0x60,%edx
f01002fd:	ec                   	in     (%dx),%al
f01002fe:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100300:	3c e0                	cmp    $0xe0,%al
f0100302:	74 61                	je     f0100365 <kbd_proc_data+0x8a>
	} else if (data & 0x80) {
f0100304:	84 c0                	test   %al,%al
f0100306:	78 70                	js     f0100378 <kbd_proc_data+0x9d>
	} else if (shift & E0ESC) {
f0100308:	8b 0d 20 60 2b f0    	mov    0xf02b6020,%ecx
f010030e:	f6 c1 40             	test   $0x40,%cl
f0100311:	74 0e                	je     f0100321 <kbd_proc_data+0x46>
		data |= 0x80;
f0100313:	83 c8 80             	or     $0xffffff80,%eax
f0100316:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100318:	83 e1 bf             	and    $0xffffffbf,%ecx
f010031b:	89 0d 20 60 2b f0    	mov    %ecx,0xf02b6020
	shift |= shiftcode[data];
f0100321:	0f b6 d2             	movzbl %dl,%edx
f0100324:	0f b6 82 60 6f 10 f0 	movzbl -0xfef90a0(%edx),%eax
f010032b:	0b 05 20 60 2b f0    	or     0xf02b6020,%eax
	shift ^= togglecode[data];
f0100331:	0f b6 8a 60 6e 10 f0 	movzbl -0xfef91a0(%edx),%ecx
f0100338:	31 c8                	xor    %ecx,%eax
f010033a:	a3 20 60 2b f0       	mov    %eax,0xf02b6020
	c = charcode[shift & (CTL | SHIFT)][data];
f010033f:	89 c1                	mov    %eax,%ecx
f0100341:	83 e1 03             	and    $0x3,%ecx
f0100344:	8b 0c 8d 40 6e 10 f0 	mov    -0xfef91c0(,%ecx,4),%ecx
f010034b:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010034f:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100352:	a8 08                	test   $0x8,%al
f0100354:	74 5d                	je     f01003b3 <kbd_proc_data+0xd8>
		if ('a' <= c && c <= 'z')
f0100356:	89 da                	mov    %ebx,%edx
f0100358:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010035b:	83 f9 19             	cmp    $0x19,%ecx
f010035e:	77 47                	ja     f01003a7 <kbd_proc_data+0xcc>
			c += 'A' - 'a';
f0100360:	83 eb 20             	sub    $0x20,%ebx
f0100363:	eb 0c                	jmp    f0100371 <kbd_proc_data+0x96>
		shift |= E0ESC;
f0100365:	83 0d 20 60 2b f0 40 	orl    $0x40,0xf02b6020
		return 0;
f010036c:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100371:	89 d8                	mov    %ebx,%eax
f0100373:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100376:	c9                   	leave  
f0100377:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100378:	8b 0d 20 60 2b f0    	mov    0xf02b6020,%ecx
f010037e:	83 e0 7f             	and    $0x7f,%eax
f0100381:	f6 c1 40             	test   $0x40,%cl
f0100384:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100387:	0f b6 d2             	movzbl %dl,%edx
f010038a:	0f b6 82 60 6f 10 f0 	movzbl -0xfef90a0(%edx),%eax
f0100391:	83 c8 40             	or     $0x40,%eax
f0100394:	0f b6 c0             	movzbl %al,%eax
f0100397:	f7 d0                	not    %eax
f0100399:	21 c8                	and    %ecx,%eax
f010039b:	a3 20 60 2b f0       	mov    %eax,0xf02b6020
		return 0;
f01003a0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003a5:	eb ca                	jmp    f0100371 <kbd_proc_data+0x96>
		else if ('A' <= c && c <= 'Z')
f01003a7:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003aa:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003ad:	83 fa 1a             	cmp    $0x1a,%edx
f01003b0:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003b3:	f7 d0                	not    %eax
f01003b5:	a8 06                	test   $0x6,%al
f01003b7:	75 b8                	jne    f0100371 <kbd_proc_data+0x96>
f01003b9:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003bf:	75 b0                	jne    f0100371 <kbd_proc_data+0x96>
		cprintf("Rebooting!\n");
f01003c1:	83 ec 0c             	sub    $0xc,%esp
f01003c4:	68 03 6e 10 f0       	push   $0xf0106e03
f01003c9:	e8 e7 35 00 00       	call   f01039b5 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ce:	b8 03 00 00 00       	mov    $0x3,%eax
f01003d3:	ba 92 00 00 00       	mov    $0x92,%edx
f01003d8:	ee                   	out    %al,(%dx)
}
f01003d9:	83 c4 10             	add    $0x10,%esp
f01003dc:	eb 93                	jmp    f0100371 <kbd_proc_data+0x96>
		return -1;
f01003de:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003e3:	eb 8c                	jmp    f0100371 <kbd_proc_data+0x96>
		return -1;
f01003e5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003ea:	eb 85                	jmp    f0100371 <kbd_proc_data+0x96>

f01003ec <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003ec:	55                   	push   %ebp
f01003ed:	89 e5                	mov    %esp,%ebp
f01003ef:	57                   	push   %edi
f01003f0:	56                   	push   %esi
f01003f1:	53                   	push   %ebx
f01003f2:	83 ec 1c             	sub    $0x1c,%esp
f01003f5:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003f7:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003fc:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100401:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100406:	89 f2                	mov    %esi,%edx
f0100408:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100409:	a8 20                	test   $0x20,%al
f010040b:	75 13                	jne    f0100420 <cons_putc+0x34>
f010040d:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100413:	7f 0b                	jg     f0100420 <cons_putc+0x34>
f0100415:	89 ca                	mov    %ecx,%edx
f0100417:	ec                   	in     (%dx),%al
f0100418:	ec                   	in     (%dx),%al
f0100419:	ec                   	in     (%dx),%al
f010041a:	ec                   	in     (%dx),%al
	     i++)
f010041b:	83 c3 01             	add    $0x1,%ebx
f010041e:	eb e6                	jmp    f0100406 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f0100420:	89 f8                	mov    %edi,%eax
f0100422:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100425:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010042a:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010042b:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100430:	be 79 03 00 00       	mov    $0x379,%esi
f0100435:	b9 84 00 00 00       	mov    $0x84,%ecx
f010043a:	89 f2                	mov    %esi,%edx
f010043c:	ec                   	in     (%dx),%al
f010043d:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100443:	7f 0f                	jg     f0100454 <cons_putc+0x68>
f0100445:	84 c0                	test   %al,%al
f0100447:	78 0b                	js     f0100454 <cons_putc+0x68>
f0100449:	89 ca                	mov    %ecx,%edx
f010044b:	ec                   	in     (%dx),%al
f010044c:	ec                   	in     (%dx),%al
f010044d:	ec                   	in     (%dx),%al
f010044e:	ec                   	in     (%dx),%al
f010044f:	83 c3 01             	add    $0x1,%ebx
f0100452:	eb e6                	jmp    f010043a <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100454:	ba 78 03 00 00       	mov    $0x378,%edx
f0100459:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010045d:	ee                   	out    %al,(%dx)
f010045e:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100463:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100468:	ee                   	out    %al,(%dx)
f0100469:	b8 08 00 00 00       	mov    $0x8,%eax
f010046e:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f010046f:	89 f8                	mov    %edi,%eax
f0100471:	80 cc 07             	or     $0x7,%ah
f0100474:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010047a:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f010047d:	89 f8                	mov    %edi,%eax
f010047f:	0f b6 c0             	movzbl %al,%eax
f0100482:	89 fb                	mov    %edi,%ebx
f0100484:	80 fb 0a             	cmp    $0xa,%bl
f0100487:	0f 84 e1 00 00 00    	je     f010056e <cons_putc+0x182>
f010048d:	83 f8 0a             	cmp    $0xa,%eax
f0100490:	7f 46                	jg     f01004d8 <cons_putc+0xec>
f0100492:	83 f8 08             	cmp    $0x8,%eax
f0100495:	0f 84 a7 00 00 00    	je     f0100542 <cons_putc+0x156>
f010049b:	83 f8 09             	cmp    $0x9,%eax
f010049e:	0f 85 d7 00 00 00    	jne    f010057b <cons_putc+0x18f>
		cons_putc(' ');
f01004a4:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a9:	e8 3e ff ff ff       	call   f01003ec <cons_putc>
		cons_putc(' ');
f01004ae:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b3:	e8 34 ff ff ff       	call   f01003ec <cons_putc>
		cons_putc(' ');
f01004b8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004bd:	e8 2a ff ff ff       	call   f01003ec <cons_putc>
		cons_putc(' ');
f01004c2:	b8 20 00 00 00       	mov    $0x20,%eax
f01004c7:	e8 20 ff ff ff       	call   f01003ec <cons_putc>
		cons_putc(' ');
f01004cc:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d1:	e8 16 ff ff ff       	call   f01003ec <cons_putc>
		break;
f01004d6:	eb 25                	jmp    f01004fd <cons_putc+0x111>
	switch (c & 0xff) {
f01004d8:	83 f8 0d             	cmp    $0xd,%eax
f01004db:	0f 85 9a 00 00 00    	jne    f010057b <cons_putc+0x18f>
		crt_pos -= (crt_pos % CRT_COLS);
f01004e1:	0f b7 05 48 62 2b f0 	movzwl 0xf02b6248,%eax
f01004e8:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004ee:	c1 e8 16             	shr    $0x16,%eax
f01004f1:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004f4:	c1 e0 04             	shl    $0x4,%eax
f01004f7:	66 a3 48 62 2b f0    	mov    %ax,0xf02b6248
	if (crt_pos >= CRT_SIZE) {
f01004fd:	66 81 3d 48 62 2b f0 	cmpw   $0x7cf,0xf02b6248
f0100504:	cf 07 
f0100506:	0f 87 92 00 00 00    	ja     f010059e <cons_putc+0x1b2>
	outb(addr_6845, 14);
f010050c:	8b 0d 50 62 2b f0    	mov    0xf02b6250,%ecx
f0100512:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100517:	89 ca                	mov    %ecx,%edx
f0100519:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010051a:	0f b7 1d 48 62 2b f0 	movzwl 0xf02b6248,%ebx
f0100521:	8d 71 01             	lea    0x1(%ecx),%esi
f0100524:	89 d8                	mov    %ebx,%eax
f0100526:	66 c1 e8 08          	shr    $0x8,%ax
f010052a:	89 f2                	mov    %esi,%edx
f010052c:	ee                   	out    %al,(%dx)
f010052d:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100532:	89 ca                	mov    %ecx,%edx
f0100534:	ee                   	out    %al,(%dx)
f0100535:	89 d8                	mov    %ebx,%eax
f0100537:	89 f2                	mov    %esi,%edx
f0100539:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010053a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010053d:	5b                   	pop    %ebx
f010053e:	5e                   	pop    %esi
f010053f:	5f                   	pop    %edi
f0100540:	5d                   	pop    %ebp
f0100541:	c3                   	ret    
		if (crt_pos > 0) {
f0100542:	0f b7 05 48 62 2b f0 	movzwl 0xf02b6248,%eax
f0100549:	66 85 c0             	test   %ax,%ax
f010054c:	74 be                	je     f010050c <cons_putc+0x120>
			crt_pos--;
f010054e:	83 e8 01             	sub    $0x1,%eax
f0100551:	66 a3 48 62 2b f0    	mov    %ax,0xf02b6248
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100557:	0f b7 c0             	movzwl %ax,%eax
f010055a:	66 81 e7 00 ff       	and    $0xff00,%di
f010055f:	83 cf 20             	or     $0x20,%edi
f0100562:	8b 15 4c 62 2b f0    	mov    0xf02b624c,%edx
f0100568:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010056c:	eb 8f                	jmp    f01004fd <cons_putc+0x111>
		crt_pos += CRT_COLS;
f010056e:	66 83 05 48 62 2b f0 	addw   $0x50,0xf02b6248
f0100575:	50 
f0100576:	e9 66 ff ff ff       	jmp    f01004e1 <cons_putc+0xf5>
		crt_buf[crt_pos++] = c;		/* write the character */
f010057b:	0f b7 05 48 62 2b f0 	movzwl 0xf02b6248,%eax
f0100582:	8d 50 01             	lea    0x1(%eax),%edx
f0100585:	66 89 15 48 62 2b f0 	mov    %dx,0xf02b6248
f010058c:	0f b7 c0             	movzwl %ax,%eax
f010058f:	8b 15 4c 62 2b f0    	mov    0xf02b624c,%edx
f0100595:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100599:	e9 5f ff ff ff       	jmp    f01004fd <cons_putc+0x111>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010059e:	a1 4c 62 2b f0       	mov    0xf02b624c,%eax
f01005a3:	83 ec 04             	sub    $0x4,%esp
f01005a6:	68 00 0f 00 00       	push   $0xf00
f01005ab:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005b1:	52                   	push   %edx
f01005b2:	50                   	push   %eax
f01005b3:	e8 fb 52 00 00       	call   f01058b3 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005b8:	8b 15 4c 62 2b f0    	mov    0xf02b624c,%edx
f01005be:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005c4:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005ca:	83 c4 10             	add    $0x10,%esp
f01005cd:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005d2:	83 c0 02             	add    $0x2,%eax
f01005d5:	39 d0                	cmp    %edx,%eax
f01005d7:	75 f4                	jne    f01005cd <cons_putc+0x1e1>
		crt_pos -= CRT_COLS;
f01005d9:	66 83 2d 48 62 2b f0 	subw   $0x50,0xf02b6248
f01005e0:	50 
f01005e1:	e9 26 ff ff ff       	jmp    f010050c <cons_putc+0x120>

f01005e6 <serial_intr>:
	if (serial_exists)
f01005e6:	80 3d 54 62 2b f0 00 	cmpb   $0x0,0xf02b6254
f01005ed:	75 01                	jne    f01005f0 <serial_intr+0xa>
f01005ef:	c3                   	ret    
{
f01005f0:	55                   	push   %ebp
f01005f1:	89 e5                	mov    %esp,%ebp
f01005f3:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005f6:	b8 81 02 10 f0       	mov    $0xf0100281,%eax
f01005fb:	e8 9b fc ff ff       	call   f010029b <cons_intr>
}
f0100600:	c9                   	leave  
f0100601:	c3                   	ret    

f0100602 <kbd_intr>:
{
f0100602:	55                   	push   %ebp
f0100603:	89 e5                	mov    %esp,%ebp
f0100605:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100608:	b8 db 02 10 f0       	mov    $0xf01002db,%eax
f010060d:	e8 89 fc ff ff       	call   f010029b <cons_intr>
}
f0100612:	c9                   	leave  
f0100613:	c3                   	ret    

f0100614 <cons_getc>:
{
f0100614:	55                   	push   %ebp
f0100615:	89 e5                	mov    %esp,%ebp
f0100617:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010061a:	e8 c7 ff ff ff       	call   f01005e6 <serial_intr>
	kbd_intr();
f010061f:	e8 de ff ff ff       	call   f0100602 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100624:	a1 40 62 2b f0       	mov    0xf02b6240,%eax
	return 0;
f0100629:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f010062e:	3b 05 44 62 2b f0    	cmp    0xf02b6244,%eax
f0100634:	74 1c                	je     f0100652 <cons_getc+0x3e>
		c = cons.buf[cons.rpos++];
f0100636:	8d 48 01             	lea    0x1(%eax),%ecx
f0100639:	0f b6 90 40 60 2b f0 	movzbl -0xfd49fc0(%eax),%edx
			cons.rpos = 0;
f0100640:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100645:	b8 00 00 00 00       	mov    $0x0,%eax
f010064a:	0f 45 c1             	cmovne %ecx,%eax
f010064d:	a3 40 62 2b f0       	mov    %eax,0xf02b6240
}
f0100652:	89 d0                	mov    %edx,%eax
f0100654:	c9                   	leave  
f0100655:	c3                   	ret    

f0100656 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100656:	55                   	push   %ebp
f0100657:	89 e5                	mov    %esp,%ebp
f0100659:	57                   	push   %edi
f010065a:	56                   	push   %esi
f010065b:	53                   	push   %ebx
f010065c:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f010065f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100666:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010066d:	5a a5 
	if (*cp != 0xA55A) {
f010066f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100676:	bb b4 03 00 00       	mov    $0x3b4,%ebx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010067b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	if (*cp != 0xA55A) {
f0100680:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100684:	0f 84 cd 00 00 00    	je     f0100757 <cons_init+0x101>
		addr_6845 = MONO_BASE;
f010068a:	89 1d 50 62 2b f0    	mov    %ebx,0xf02b6250
f0100690:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100695:	89 da                	mov    %ebx,%edx
f0100697:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100698:	8d 7b 01             	lea    0x1(%ebx),%edi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069b:	89 fa                	mov    %edi,%edx
f010069d:	ec                   	in     (%dx),%al
f010069e:	0f b6 c8             	movzbl %al,%ecx
f01006a1:	c1 e1 08             	shl    $0x8,%ecx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006a4:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006a9:	89 da                	mov    %ebx,%edx
f01006ab:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ac:	89 fa                	mov    %edi,%edx
f01006ae:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006af:	89 35 4c 62 2b f0    	mov    %esi,0xf02b624c
	pos |= inb(addr_6845 + 1);
f01006b5:	0f b6 c0             	movzbl %al,%eax
f01006b8:	09 c8                	or     %ecx,%eax
	crt_pos = pos;
f01006ba:	66 a3 48 62 2b f0    	mov    %ax,0xf02b6248
	kbd_intr();
f01006c0:	e8 3d ff ff ff       	call   f0100602 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006c5:	83 ec 0c             	sub    $0xc,%esp
f01006c8:	0f b7 05 a8 83 12 f0 	movzwl 0xf01283a8,%eax
f01006cf:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006d4:	50                   	push   %eax
f01006d5:	e8 67 31 00 00       	call   f0103841 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006da:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006df:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01006e4:	89 c8                	mov    %ecx,%eax
f01006e6:	89 da                	mov    %ebx,%edx
f01006e8:	ee                   	out    %al,(%dx)
f01006e9:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006ee:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006f3:	89 fa                	mov    %edi,%edx
f01006f5:	ee                   	out    %al,(%dx)
f01006f6:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006fb:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100700:	ee                   	out    %al,(%dx)
f0100701:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100706:	89 c8                	mov    %ecx,%eax
f0100708:	89 f2                	mov    %esi,%edx
f010070a:	ee                   	out    %al,(%dx)
f010070b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100710:	89 fa                	mov    %edi,%edx
f0100712:	ee                   	out    %al,(%dx)
f0100713:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100718:	89 c8                	mov    %ecx,%eax
f010071a:	ee                   	out    %al,(%dx)
f010071b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100720:	89 f2                	mov    %esi,%edx
f0100722:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100723:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100728:	ec                   	in     (%dx),%al
f0100729:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010072b:	83 c4 10             	add    $0x10,%esp
f010072e:	3c ff                	cmp    $0xff,%al
f0100730:	0f 95 05 54 62 2b f0 	setne  0xf02b6254
f0100737:	89 da                	mov    %ebx,%edx
f0100739:	ec                   	in     (%dx),%al
f010073a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010073f:	ec                   	in     (%dx),%al
	if (serial_exists)
f0100740:	80 f9 ff             	cmp    $0xff,%cl
f0100743:	75 28                	jne    f010076d <cons_init+0x117>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
		cprintf("Serial port does not exist!\n");
f0100745:	83 ec 0c             	sub    $0xc,%esp
f0100748:	68 0f 6e 10 f0       	push   $0xf0106e0f
f010074d:	e8 63 32 00 00       	call   f01039b5 <cprintf>
f0100752:	83 c4 10             	add    $0x10,%esp
}
f0100755:	eb 37                	jmp    f010078e <cons_init+0x138>
		*cp = was;
f0100757:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f010075e:	bb d4 03 00 00       	mov    $0x3d4,%ebx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100763:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100768:	e9 1d ff ff ff       	jmp    f010068a <cons_init+0x34>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f010076d:	83 ec 0c             	sub    $0xc,%esp
f0100770:	0f b7 05 a8 83 12 f0 	movzwl 0xf01283a8,%eax
f0100777:	25 ef ff 00 00       	and    $0xffef,%eax
f010077c:	50                   	push   %eax
f010077d:	e8 bf 30 00 00       	call   f0103841 <irq_setmask_8259A>
	if (!serial_exists)
f0100782:	83 c4 10             	add    $0x10,%esp
f0100785:	80 3d 54 62 2b f0 00 	cmpb   $0x0,0xf02b6254
f010078c:	74 b7                	je     f0100745 <cons_init+0xef>
}
f010078e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100791:	5b                   	pop    %ebx
f0100792:	5e                   	pop    %esi
f0100793:	5f                   	pop    %edi
f0100794:	5d                   	pop    %ebp
f0100795:	c3                   	ret    

f0100796 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100796:	55                   	push   %ebp
f0100797:	89 e5                	mov    %esp,%ebp
f0100799:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010079c:	8b 45 08             	mov    0x8(%ebp),%eax
f010079f:	e8 48 fc ff ff       	call   f01003ec <cons_putc>
}
f01007a4:	c9                   	leave  
f01007a5:	c3                   	ret    

f01007a6 <getchar>:

int
getchar(void)
{
f01007a6:	55                   	push   %ebp
f01007a7:	89 e5                	mov    %esp,%ebp
f01007a9:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007ac:	e8 63 fe ff ff       	call   f0100614 <cons_getc>
f01007b1:	85 c0                	test   %eax,%eax
f01007b3:	74 f7                	je     f01007ac <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007b5:	c9                   	leave  
f01007b6:	c3                   	ret    

f01007b7 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f01007b7:	b8 01 00 00 00       	mov    $0x1,%eax
f01007bc:	c3                   	ret    

f01007bd <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007bd:	55                   	push   %ebp
f01007be:	89 e5                	mov    %esp,%ebp
f01007c0:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007c3:	68 60 70 10 f0       	push   $0xf0107060
f01007c8:	68 7e 70 10 f0       	push   $0xf010707e
f01007cd:	68 83 70 10 f0       	push   $0xf0107083
f01007d2:	e8 de 31 00 00       	call   f01039b5 <cprintf>
f01007d7:	83 c4 0c             	add    $0xc,%esp
f01007da:	68 24 71 10 f0       	push   $0xf0107124
f01007df:	68 8c 70 10 f0       	push   $0xf010708c
f01007e4:	68 83 70 10 f0       	push   $0xf0107083
f01007e9:	e8 c7 31 00 00       	call   f01039b5 <cprintf>
	return 0;
}
f01007ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f3:	c9                   	leave  
f01007f4:	c3                   	ret    

f01007f5 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007f5:	55                   	push   %ebp
f01007f6:	89 e5                	mov    %esp,%ebp
f01007f8:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007fb:	68 95 70 10 f0       	push   $0xf0107095
f0100800:	e8 b0 31 00 00       	call   f01039b5 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100805:	83 c4 08             	add    $0x8,%esp
f0100808:	68 0c 00 10 00       	push   $0x10000c
f010080d:	68 4c 71 10 f0       	push   $0xf010714c
f0100812:	e8 9e 31 00 00       	call   f01039b5 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100817:	83 c4 0c             	add    $0xc,%esp
f010081a:	68 0c 00 10 00       	push   $0x10000c
f010081f:	68 0c 00 10 f0       	push   $0xf010000c
f0100824:	68 74 71 10 f0       	push   $0xf0107174
f0100829:	e8 87 31 00 00       	call   f01039b5 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010082e:	83 c4 0c             	add    $0xc,%esp
f0100831:	68 21 6d 10 00       	push   $0x106d21
f0100836:	68 21 6d 10 f0       	push   $0xf0106d21
f010083b:	68 98 71 10 f0       	push   $0xf0107198
f0100840:	e8 70 31 00 00       	call   f01039b5 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100845:	83 c4 0c             	add    $0xc,%esp
f0100848:	68 00 60 2b 00       	push   $0x2b6000
f010084d:	68 00 60 2b f0       	push   $0xf02b6000
f0100852:	68 bc 71 10 f0       	push   $0xf01071bc
f0100857:	e8 59 31 00 00       	call   f01039b5 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010085c:	83 c4 0c             	add    $0xc,%esp
f010085f:	68 b0 3b 34 00       	push   $0x343bb0
f0100864:	68 b0 3b 34 f0       	push   $0xf0343bb0
f0100869:	68 e0 71 10 f0       	push   $0xf01071e0
f010086e:	e8 42 31 00 00       	call   f01039b5 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100873:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100876:	b8 b0 3b 34 f0       	mov    $0xf0343bb0,%eax
f010087b:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100880:	c1 f8 0a             	sar    $0xa,%eax
f0100883:	50                   	push   %eax
f0100884:	68 04 72 10 f0       	push   $0xf0107204
f0100889:	e8 27 31 00 00       	call   f01039b5 <cprintf>
	return 0;
}
f010088e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100893:	c9                   	leave  
f0100894:	c3                   	ret    

f0100895 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100895:	55                   	push   %ebp
f0100896:	89 e5                	mov    %esp,%ebp
f0100898:	56                   	push   %esi
f0100899:	53                   	push   %ebx
f010089a:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));//I guess it means moving ebp register value to local variable. 
f010089d:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	uint32_t * ebp;
	struct Eipdebuginfo info;
	
	ebp=(uint32_t *)read_ebp();
	cprintf("Stack backtrace:\n");
f010089f:	68 ae 70 10 f0       	push   $0xf01070ae
f01008a4:	e8 0c 31 00 00       	call   f01039b5 <cprintf>
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f01008a9:	83 c4 10             	add    $0x10,%esp
		cprintf(" %08x",*(ebp+4));
		cprintf(" %08x",*(ebp+5));
		cprintf(" %08x\n",*(ebp+6));
		
		//Exercise 12
		debuginfo_eip(*(ebp+1) , &info);
f01008ac:	8d 75 e0             	lea    -0x20(%ebp),%esi
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f01008af:	e9 c2 00 00 00       	jmp    f0100976 <mon_backtrace+0xe1>
		cprintf(" ebp %08x",(uint32_t) ebp);
f01008b4:	83 ec 08             	sub    $0x8,%esp
f01008b7:	53                   	push   %ebx
f01008b8:	68 c0 70 10 f0       	push   $0xf01070c0
f01008bd:	e8 f3 30 00 00       	call   f01039b5 <cprintf>
		cprintf(" eip %08x",*(ebp+1));
f01008c2:	83 c4 08             	add    $0x8,%esp
f01008c5:	ff 73 04             	push   0x4(%ebx)
f01008c8:	68 ca 70 10 f0       	push   $0xf01070ca
f01008cd:	e8 e3 30 00 00       	call   f01039b5 <cprintf>
		cprintf(" args");
f01008d2:	c7 04 24 d4 70 10 f0 	movl   $0xf01070d4,(%esp)
f01008d9:	e8 d7 30 00 00       	call   f01039b5 <cprintf>
		cprintf(" %08x",*(ebp+2));
f01008de:	83 c4 08             	add    $0x8,%esp
f01008e1:	ff 73 08             	push   0x8(%ebx)
f01008e4:	68 c4 70 10 f0       	push   $0xf01070c4
f01008e9:	e8 c7 30 00 00       	call   f01039b5 <cprintf>
		cprintf(" %08x",*(ebp+3));
f01008ee:	83 c4 08             	add    $0x8,%esp
f01008f1:	ff 73 0c             	push   0xc(%ebx)
f01008f4:	68 c4 70 10 f0       	push   $0xf01070c4
f01008f9:	e8 b7 30 00 00       	call   f01039b5 <cprintf>
		cprintf(" %08x",*(ebp+4));
f01008fe:	83 c4 08             	add    $0x8,%esp
f0100901:	ff 73 10             	push   0x10(%ebx)
f0100904:	68 c4 70 10 f0       	push   $0xf01070c4
f0100909:	e8 a7 30 00 00       	call   f01039b5 <cprintf>
		cprintf(" %08x",*(ebp+5));
f010090e:	83 c4 08             	add    $0x8,%esp
f0100911:	ff 73 14             	push   0x14(%ebx)
f0100914:	68 c4 70 10 f0       	push   $0xf01070c4
f0100919:	e8 97 30 00 00       	call   f01039b5 <cprintf>
		cprintf(" %08x\n",*(ebp+6));
f010091e:	83 c4 08             	add    $0x8,%esp
f0100921:	ff 73 18             	push   0x18(%ebx)
f0100924:	68 4e 8b 10 f0       	push   $0xf0108b4e
f0100929:	e8 87 30 00 00       	call   f01039b5 <cprintf>
		debuginfo_eip(*(ebp+1) , &info);
f010092e:	83 c4 08             	add    $0x8,%esp
f0100931:	56                   	push   %esi
f0100932:	ff 73 04             	push   0x4(%ebx)
f0100935:	e8 62 44 00 00       	call   f0104d9c <debuginfo_eip>
		cprintf("\t%s:",info.eip_file);
f010093a:	83 c4 08             	add    $0x8,%esp
f010093d:	ff 75 e0             	push   -0x20(%ebp)
f0100940:	68 da 70 10 f0       	push   $0xf01070da
f0100945:	e8 6b 30 00 00       	call   f01039b5 <cprintf>
		cprintf("%d: ",info.eip_line);
f010094a:	83 c4 08             	add    $0x8,%esp
f010094d:	ff 75 e4             	push   -0x1c(%ebp)
f0100950:	68 fe 6d 10 f0       	push   $0xf0106dfe
f0100955:	e8 5b 30 00 00       	call   f01039b5 <cprintf>
		cprintf("%.*s+%d\n", info.eip_fn_namelen , info.eip_fn_name , *(ebp+1) - info.eip_fn_addr );
f010095a:	8b 43 04             	mov    0x4(%ebx),%eax
f010095d:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100960:	50                   	push   %eax
f0100961:	ff 75 e8             	push   -0x18(%ebp)
f0100964:	ff 75 ec             	push   -0x14(%ebp)
f0100967:	68 df 70 10 f0       	push   $0xf01070df
f010096c:	e8 44 30 00 00       	call   f01039b5 <cprintf>
		
		//
		ebp=(uint32_t *)(*ebp);
f0100971:	8b 1b                	mov    (%ebx),%ebx
f0100973:	83 c4 20             	add    $0x20,%esp
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f0100976:	85 db                	test   %ebx,%ebx
f0100978:	0f 85 36 ff ff ff    	jne    f01008b4 <mon_backtrace+0x1f>
    	cprintf("x=%d y=%d\n", 3);
    	
	cprintf("Lab1 Exercise8 qusetion3 finish!\n");
	*/
	return 0;
}
f010097e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100983:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100986:	5b                   	pop    %ebx
f0100987:	5e                   	pop    %esi
f0100988:	5d                   	pop    %ebp
f0100989:	c3                   	ret    

f010098a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010098a:	55                   	push   %ebp
f010098b:	89 e5                	mov    %esp,%ebp
f010098d:	57                   	push   %edi
f010098e:	56                   	push   %esi
f010098f:	53                   	push   %ebx
f0100990:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100993:	68 30 72 10 f0       	push   $0xf0107230
f0100998:	e8 18 30 00 00       	call   f01039b5 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010099d:	c7 04 24 54 72 10 f0 	movl   $0xf0107254,(%esp)
f01009a4:	e8 0c 30 00 00       	call   f01039b5 <cprintf>

	if (tf != NULL)
f01009a9:	83 c4 10             	add    $0x10,%esp
f01009ac:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009b0:	74 57                	je     f0100a09 <monitor+0x7f>
		print_trapframe(tf);
f01009b2:	83 ec 0c             	sub    $0xc,%esp
f01009b5:	ff 75 08             	push   0x8(%ebp)
f01009b8:	e8 b8 35 00 00       	call   f0103f75 <print_trapframe>
f01009bd:	83 c4 10             	add    $0x10,%esp
f01009c0:	eb 47                	jmp    f0100a09 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f01009c2:	83 ec 08             	sub    $0x8,%esp
f01009c5:	0f be c0             	movsbl %al,%eax
f01009c8:	50                   	push   %eax
f01009c9:	68 ec 70 10 f0       	push   $0xf01070ec
f01009ce:	e8 5b 4e 00 00       	call   f010582e <strchr>
f01009d3:	83 c4 10             	add    $0x10,%esp
f01009d6:	85 c0                	test   %eax,%eax
f01009d8:	74 0a                	je     f01009e4 <monitor+0x5a>
			*buf++ = 0;
f01009da:	c6 03 00             	movb   $0x0,(%ebx)
f01009dd:	89 f7                	mov    %esi,%edi
f01009df:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009e2:	eb 6b                	jmp    f0100a4f <monitor+0xc5>
		if (*buf == 0)
f01009e4:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009e7:	74 73                	je     f0100a5c <monitor+0xd2>
		if (argc == MAXARGS-1) {
f01009e9:	83 fe 0f             	cmp    $0xf,%esi
f01009ec:	74 09                	je     f01009f7 <monitor+0x6d>
		argv[argc++] = buf;
f01009ee:	8d 7e 01             	lea    0x1(%esi),%edi
f01009f1:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009f5:	eb 39                	jmp    f0100a30 <monitor+0xa6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009f7:	83 ec 08             	sub    $0x8,%esp
f01009fa:	6a 10                	push   $0x10
f01009fc:	68 f1 70 10 f0       	push   $0xf01070f1
f0100a01:	e8 af 2f 00 00       	call   f01039b5 <cprintf>
			return 0;
f0100a06:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a09:	83 ec 0c             	sub    $0xc,%esp
f0100a0c:	68 e8 70 10 f0       	push   $0xf01070e8
f0100a11:	e8 de 4b 00 00       	call   f01055f4 <readline>
f0100a16:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a18:	83 c4 10             	add    $0x10,%esp
f0100a1b:	85 c0                	test   %eax,%eax
f0100a1d:	74 ea                	je     f0100a09 <monitor+0x7f>
	argv[argc] = 0;
f0100a1f:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a26:	be 00 00 00 00       	mov    $0x0,%esi
f0100a2b:	eb 24                	jmp    f0100a51 <monitor+0xc7>
			buf++;
f0100a2d:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a30:	0f b6 03             	movzbl (%ebx),%eax
f0100a33:	84 c0                	test   %al,%al
f0100a35:	74 18                	je     f0100a4f <monitor+0xc5>
f0100a37:	83 ec 08             	sub    $0x8,%esp
f0100a3a:	0f be c0             	movsbl %al,%eax
f0100a3d:	50                   	push   %eax
f0100a3e:	68 ec 70 10 f0       	push   $0xf01070ec
f0100a43:	e8 e6 4d 00 00       	call   f010582e <strchr>
f0100a48:	83 c4 10             	add    $0x10,%esp
f0100a4b:	85 c0                	test   %eax,%eax
f0100a4d:	74 de                	je     f0100a2d <monitor+0xa3>
			*buf++ = 0;
f0100a4f:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a51:	0f b6 03             	movzbl (%ebx),%eax
f0100a54:	84 c0                	test   %al,%al
f0100a56:	0f 85 66 ff ff ff    	jne    f01009c2 <monitor+0x38>
	argv[argc] = 0;
f0100a5c:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a63:	00 
	if (argc == 0)
f0100a64:	85 f6                	test   %esi,%esi
f0100a66:	74 a1                	je     f0100a09 <monitor+0x7f>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a68:	83 ec 08             	sub    $0x8,%esp
f0100a6b:	68 7e 70 10 f0       	push   $0xf010707e
f0100a70:	ff 75 a8             	push   -0x58(%ebp)
f0100a73:	e8 56 4d 00 00       	call   f01057ce <strcmp>
f0100a78:	83 c4 10             	add    $0x10,%esp
f0100a7b:	85 c0                	test   %eax,%eax
f0100a7d:	74 34                	je     f0100ab3 <monitor+0x129>
f0100a7f:	83 ec 08             	sub    $0x8,%esp
f0100a82:	68 8c 70 10 f0       	push   $0xf010708c
f0100a87:	ff 75 a8             	push   -0x58(%ebp)
f0100a8a:	e8 3f 4d 00 00       	call   f01057ce <strcmp>
f0100a8f:	83 c4 10             	add    $0x10,%esp
f0100a92:	85 c0                	test   %eax,%eax
f0100a94:	74 18                	je     f0100aae <monitor+0x124>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a96:	83 ec 08             	sub    $0x8,%esp
f0100a99:	ff 75 a8             	push   -0x58(%ebp)
f0100a9c:	68 0e 71 10 f0       	push   $0xf010710e
f0100aa1:	e8 0f 2f 00 00       	call   f01039b5 <cprintf>
	return 0;
f0100aa6:	83 c4 10             	add    $0x10,%esp
f0100aa9:	e9 5b ff ff ff       	jmp    f0100a09 <monitor+0x7f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100aae:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100ab3:	83 ec 04             	sub    $0x4,%esp
f0100ab6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100ab9:	ff 75 08             	push   0x8(%ebp)
f0100abc:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100abf:	52                   	push   %edx
f0100ac0:	56                   	push   %esi
f0100ac1:	ff 14 85 84 72 10 f0 	call   *-0xfef8d7c(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100ac8:	83 c4 10             	add    $0x10,%esp
f0100acb:	85 c0                	test   %eax,%eax
f0100acd:	0f 89 36 ff ff ff    	jns    f0100a09 <monitor+0x7f>
				break;
	}
}
f0100ad3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ad6:	5b                   	pop    %ebx
f0100ad7:	5e                   	pop    %esi
f0100ad8:	5f                   	pop    %edi
f0100ad9:	5d                   	pop    %ebp
f0100ada:	c3                   	ret    

f0100adb <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100adb:	55                   	push   %ebp
f0100adc:	89 e5                	mov    %esp,%ebp
f0100ade:	56                   	push   %esi
f0100adf:	53                   	push   %ebx
f0100ae0:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ae2:	83 ec 0c             	sub    $0xc,%esp
f0100ae5:	50                   	push   %eax
f0100ae6:	e8 28 2d 00 00       	call   f0103813 <mc146818_read>
f0100aeb:	89 c6                	mov    %eax,%esi
f0100aed:	83 c3 01             	add    $0x1,%ebx
f0100af0:	89 1c 24             	mov    %ebx,(%esp)
f0100af3:	e8 1b 2d 00 00       	call   f0103813 <mc146818_read>
f0100af8:	c1 e0 08             	shl    $0x8,%eax
f0100afb:	09 f0                	or     %esi,%eax
}
f0100afd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b00:	5b                   	pop    %ebx
f0100b01:	5e                   	pop    %esi
f0100b02:	5d                   	pop    %ebp
f0100b03:	c3                   	ret    

f0100b04 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b04:	83 3d 64 62 2b f0 00 	cmpl   $0x0,0xf02b6264
f0100b0b:	74 21                	je     f0100b2e <boot_alloc+0x2a>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	
	//
	// LAB 2: Your code here.
	result=nextfree;
f0100b0d:	8b 15 64 62 2b f0    	mov    0xf02b6264,%edx
	nextfree=ROUNDUP(nextfree+n, PGSIZE);
f0100b13:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b1a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b1f:	a3 64 62 2b f0       	mov    %eax,0xf02b6264
	if( (uint32_t)nextfree < KERNBASE ){
f0100b24:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100b29:	76 16                	jbe    f0100b41 <boot_alloc+0x3d>
	//这也与博客的写法 if( (uint32_t)nextfree - KERNBASE > (npages*PGSIZE))所不同。
	
	return result;

	//return NULL;
}
f0100b2b:	89 d0                	mov    %edx,%eax
f0100b2d:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);//ROUNDUP(a,n)函数在inc/types.h中定义：目的是用来进行地址向上对齐，即增大数a至n的倍数。
f0100b2e:	ba af 4b 34 f0       	mov    $0xf0344baf,%edx
f0100b33:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b39:	89 15 64 62 2b f0    	mov    %edx,0xf02b6264
f0100b3f:	eb cc                	jmp    f0100b0d <boot_alloc+0x9>
{
f0100b41:	55                   	push   %ebp
f0100b42:	89 e5                	mov    %esp,%ebp
f0100b44:	83 ec 0c             	sub    $0xc,%esp
		panic("boot_alloc: out of memory\n");
f0100b47:	68 94 72 10 f0       	push   $0xf0107294
f0100b4c:	6a 75                	push   $0x75
f0100b4e:	68 af 72 10 f0       	push   $0xf01072af
f0100b53:	e8 e8 f4 ff ff       	call   f0100040 <_panic>

f0100b58 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b58:	89 d1                	mov    %edx,%ecx
f0100b5a:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b5d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b60:	a8 01                	test   $0x1,%al
f0100b62:	74 51                	je     f0100bb5 <check_va2pa+0x5d>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b64:	89 c1                	mov    %eax,%ecx
f0100b66:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100b6c:	c1 e8 0c             	shr    $0xc,%eax
f0100b6f:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f0100b75:	73 23                	jae    f0100b9a <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P))
f0100b77:	c1 ea 0c             	shr    $0xc,%edx
f0100b7a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b80:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b87:	89 d0                	mov    %edx,%eax
f0100b89:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b8e:	f6 c2 01             	test   $0x1,%dl
f0100b91:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b96:	0f 44 c2             	cmove  %edx,%eax
f0100b99:	c3                   	ret    
{
f0100b9a:	55                   	push   %ebp
f0100b9b:	89 e5                	mov    %esp,%ebp
f0100b9d:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ba0:	51                   	push   %ecx
f0100ba1:	68 64 6d 10 f0       	push   $0xf0106d64
f0100ba6:	68 ba 03 00 00       	push   $0x3ba
f0100bab:	68 af 72 10 f0       	push   $0xf01072af
f0100bb0:	e8 8b f4 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100bb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100bba:	c3                   	ret    

f0100bbb <check_page_free_list>:
{
f0100bbb:	55                   	push   %ebp
f0100bbc:	89 e5                	mov    %esp,%ebp
f0100bbe:	57                   	push   %edi
f0100bbf:	56                   	push   %esi
f0100bc0:	53                   	push   %ebx
f0100bc1:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100bc4:	84 c0                	test   %al,%al
f0100bc6:	0f 85 77 02 00 00    	jne    f0100e43 <check_page_free_list+0x288>
	if (!page_free_list)
f0100bcc:	83 3d 6c 62 2b f0 00 	cmpl   $0x0,0xf02b626c
f0100bd3:	74 0a                	je     f0100bdf <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100bd5:	be 00 04 00 00       	mov    $0x400,%esi
f0100bda:	e9 bf 02 00 00       	jmp    f0100e9e <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100bdf:	83 ec 04             	sub    $0x4,%esp
f0100be2:	68 e8 75 10 f0       	push   $0xf01075e8
f0100be7:	68 ed 02 00 00       	push   $0x2ed
f0100bec:	68 af 72 10 f0       	push   $0xf01072af
f0100bf1:	e8 4a f4 ff ff       	call   f0100040 <_panic>
f0100bf6:	50                   	push   %eax
f0100bf7:	68 64 6d 10 f0       	push   $0xf0106d64
f0100bfc:	6a 5a                	push   $0x5a
f0100bfe:	68 bb 72 10 f0       	push   $0xf01072bb
f0100c03:	e8 38 f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c08:	8b 1b                	mov    (%ebx),%ebx
f0100c0a:	85 db                	test   %ebx,%ebx
f0100c0c:	74 41                	je     f0100c4f <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0100c0e:	89 d8                	mov    %ebx,%eax
f0100c10:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f0100c16:	c1 f8 03             	sar    $0x3,%eax
f0100c19:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c1c:	89 c2                	mov    %eax,%edx
f0100c1e:	c1 ea 16             	shr    $0x16,%edx
f0100c21:	39 f2                	cmp    %esi,%edx
f0100c23:	73 e3                	jae    f0100c08 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100c25:	89 c2                	mov    %eax,%edx
f0100c27:	c1 ea 0c             	shr    $0xc,%edx
f0100c2a:	3b 15 60 62 2b f0    	cmp    0xf02b6260,%edx
f0100c30:	73 c4                	jae    f0100bf6 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100c32:	83 ec 04             	sub    $0x4,%esp
f0100c35:	68 80 00 00 00       	push   $0x80
f0100c3a:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c3f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c44:	50                   	push   %eax
f0100c45:	e8 23 4c 00 00       	call   f010586d <memset>
f0100c4a:	83 c4 10             	add    $0x10,%esp
f0100c4d:	eb b9                	jmp    f0100c08 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100c4f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c54:	e8 ab fe ff ff       	call   f0100b04 <boot_alloc>
f0100c59:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c5c:	8b 15 6c 62 2b f0    	mov    0xf02b626c,%edx
		assert(pp >= pages);
f0100c62:	8b 0d 58 62 2b f0    	mov    0xf02b6258,%ecx
		assert(pp < pages + npages);
f0100c68:	a1 60 62 2b f0       	mov    0xf02b6260,%eax
f0100c6d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c70:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c73:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c78:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c7b:	e9 f9 00 00 00       	jmp    f0100d79 <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100c80:	68 c9 72 10 f0       	push   $0xf01072c9
f0100c85:	68 d5 72 10 f0       	push   $0xf01072d5
f0100c8a:	68 07 03 00 00       	push   $0x307
f0100c8f:	68 af 72 10 f0       	push   $0xf01072af
f0100c94:	e8 a7 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c99:	68 ea 72 10 f0       	push   $0xf01072ea
f0100c9e:	68 d5 72 10 f0       	push   $0xf01072d5
f0100ca3:	68 08 03 00 00       	push   $0x308
f0100ca8:	68 af 72 10 f0       	push   $0xf01072af
f0100cad:	e8 8e f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cb2:	68 0c 76 10 f0       	push   $0xf010760c
f0100cb7:	68 d5 72 10 f0       	push   $0xf01072d5
f0100cbc:	68 09 03 00 00       	push   $0x309
f0100cc1:	68 af 72 10 f0       	push   $0xf01072af
f0100cc6:	e8 75 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100ccb:	68 fe 72 10 f0       	push   $0xf01072fe
f0100cd0:	68 d5 72 10 f0       	push   $0xf01072d5
f0100cd5:	68 0c 03 00 00       	push   $0x30c
f0100cda:	68 af 72 10 f0       	push   $0xf01072af
f0100cdf:	e8 5c f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ce4:	68 0f 73 10 f0       	push   $0xf010730f
f0100ce9:	68 d5 72 10 f0       	push   $0xf01072d5
f0100cee:	68 0d 03 00 00       	push   $0x30d
f0100cf3:	68 af 72 10 f0       	push   $0xf01072af
f0100cf8:	e8 43 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cfd:	68 40 76 10 f0       	push   $0xf0107640
f0100d02:	68 d5 72 10 f0       	push   $0xf01072d5
f0100d07:	68 0e 03 00 00       	push   $0x30e
f0100d0c:	68 af 72 10 f0       	push   $0xf01072af
f0100d11:	e8 2a f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d16:	68 28 73 10 f0       	push   $0xf0107328
f0100d1b:	68 d5 72 10 f0       	push   $0xf01072d5
f0100d20:	68 0f 03 00 00       	push   $0x30f
f0100d25:	68 af 72 10 f0       	push   $0xf01072af
f0100d2a:	e8 11 f3 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100d2f:	89 c3                	mov    %eax,%ebx
f0100d31:	c1 eb 0c             	shr    $0xc,%ebx
f0100d34:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100d37:	76 0f                	jbe    f0100d48 <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100d39:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d3e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d41:	77 17                	ja     f0100d5a <check_page_free_list+0x19f>
			++nfree_extmem;
f0100d43:	83 c7 01             	add    $0x1,%edi
f0100d46:	eb 2f                	jmp    f0100d77 <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d48:	50                   	push   %eax
f0100d49:	68 64 6d 10 f0       	push   $0xf0106d64
f0100d4e:	6a 5a                	push   $0x5a
f0100d50:	68 bb 72 10 f0       	push   $0xf01072bb
f0100d55:	e8 e6 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d5a:	68 64 76 10 f0       	push   $0xf0107664
f0100d5f:	68 d5 72 10 f0       	push   $0xf01072d5
f0100d64:	68 10 03 00 00       	push   $0x310
f0100d69:	68 af 72 10 f0       	push   $0xf01072af
f0100d6e:	e8 cd f2 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100d73:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d77:	8b 12                	mov    (%edx),%edx
f0100d79:	85 d2                	test   %edx,%edx
f0100d7b:	74 74                	je     f0100df1 <check_page_free_list+0x236>
		assert(pp >= pages);
f0100d7d:	39 d1                	cmp    %edx,%ecx
f0100d7f:	0f 87 fb fe ff ff    	ja     f0100c80 <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100d85:	39 d6                	cmp    %edx,%esi
f0100d87:	0f 86 0c ff ff ff    	jbe    f0100c99 <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d8d:	89 d0                	mov    %edx,%eax
f0100d8f:	29 c8                	sub    %ecx,%eax
f0100d91:	a8 07                	test   $0x7,%al
f0100d93:	0f 85 19 ff ff ff    	jne    f0100cb2 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0100d99:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d9c:	c1 e0 0c             	shl    $0xc,%eax
f0100d9f:	0f 84 26 ff ff ff    	je     f0100ccb <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100da5:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100daa:	0f 84 34 ff ff ff    	je     f0100ce4 <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100db0:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100db5:	0f 84 42 ff ff ff    	je     f0100cfd <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100dbb:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100dc0:	0f 84 50 ff ff ff    	je     f0100d16 <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dc6:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dcb:	0f 87 5e ff ff ff    	ja     f0100d2f <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100dd1:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dd6:	75 9b                	jne    f0100d73 <check_page_free_list+0x1b8>
f0100dd8:	68 42 73 10 f0       	push   $0xf0107342
f0100ddd:	68 d5 72 10 f0       	push   $0xf01072d5
f0100de2:	68 12 03 00 00       	push   $0x312
f0100de7:	68 af 72 10 f0       	push   $0xf01072af
f0100dec:	e8 4f f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f0100df1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100df4:	85 db                	test   %ebx,%ebx
f0100df6:	7e 19                	jle    f0100e11 <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100df8:	85 ff                	test   %edi,%edi
f0100dfa:	7e 2e                	jle    f0100e2a <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100dfc:	83 ec 0c             	sub    $0xc,%esp
f0100dff:	68 ac 76 10 f0       	push   $0xf01076ac
f0100e04:	e8 ac 2b 00 00       	call   f01039b5 <cprintf>
}
f0100e09:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e0c:	5b                   	pop    %ebx
f0100e0d:	5e                   	pop    %esi
f0100e0e:	5f                   	pop    %edi
f0100e0f:	5d                   	pop    %ebp
f0100e10:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e11:	68 5f 73 10 f0       	push   $0xf010735f
f0100e16:	68 d5 72 10 f0       	push   $0xf01072d5
f0100e1b:	68 1a 03 00 00       	push   $0x31a
f0100e20:	68 af 72 10 f0       	push   $0xf01072af
f0100e25:	e8 16 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e2a:	68 71 73 10 f0       	push   $0xf0107371
f0100e2f:	68 d5 72 10 f0       	push   $0xf01072d5
f0100e34:	68 1b 03 00 00       	push   $0x31b
f0100e39:	68 af 72 10 f0       	push   $0xf01072af
f0100e3e:	e8 fd f1 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100e43:	a1 6c 62 2b f0       	mov    0xf02b626c,%eax
f0100e48:	85 c0                	test   %eax,%eax
f0100e4a:	0f 84 8f fd ff ff    	je     f0100bdf <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e50:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e53:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e56:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e59:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100e5c:	89 c2                	mov    %eax,%edx
f0100e5e:	2b 15 58 62 2b f0    	sub    0xf02b6258,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e64:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100e6a:	0f 95 c2             	setne  %dl
f0100e6d:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100e70:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100e74:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e76:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e7a:	8b 00                	mov    (%eax),%eax
f0100e7c:	85 c0                	test   %eax,%eax
f0100e7e:	75 dc                	jne    f0100e5c <check_page_free_list+0x2a1>
		*tp[1] = 0;
f0100e80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e83:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e89:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e8f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e91:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e94:	a3 6c 62 2b f0       	mov    %eax,0xf02b626c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100e99:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e9e:	8b 1d 6c 62 2b f0    	mov    0xf02b626c,%ebx
f0100ea4:	e9 61 fd ff ff       	jmp    f0100c0a <check_page_free_list+0x4f>

f0100ea9 <page_init>:
{
f0100ea9:	55                   	push   %ebp
f0100eaa:	89 e5                	mov    %esp,%ebp
f0100eac:	57                   	push   %edi
f0100ead:	56                   	push   %esi
f0100eae:	53                   	push   %ebx
f0100eaf:	83 ec 0c             	sub    $0xc,%esp
	page_free_list = NULL;//其实是多余的，因为它本就是空指针，这只是为了方便阅读一点。
f0100eb2:	c7 05 6c 62 2b f0 00 	movl   $0x0,0xf02b626c
f0100eb9:	00 00 00 
	uint32_t EXTPHYSMEM_alloc = (uint32_t)boot_alloc(0) - KERNBASE;//EXTPHYSMEM_alloc：在EXTPHYSMEM区域已经被占用的bytes数
f0100ebc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ec1:	e8 3e fc ff ff       	call   f0100b04 <boot_alloc>
		if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)/* 3,4条*/ ||  (i>=MPENTRY_PADDR/PGSIZE && i<(MPENTRY_PADDR+size)/PGSIZE) /*lab4*/){//不标记为free的页
f0100ec6:	8d 98 00 00 10 10    	lea    0x10100000(%eax),%ebx
f0100ecc:	c1 eb 0c             	shr    $0xc,%ebx
    	size = ROUNDUP(size, PGSIZE);
f0100ecf:	b9 da 5a 10 f0       	mov    $0xf0105ada,%ecx
f0100ed4:	81 e9 61 4a 10 f0    	sub    $0xf0104a61,%ecx
		if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)/* 3,4条*/ ||  (i>=MPENTRY_PADDR/PGSIZE && i<(MPENTRY_PADDR+size)/PGSIZE) /*lab4*/){//不标记为free的页
f0100eda:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100ee0:	81 c1 00 70 00 00    	add    $0x7000,%ecx
f0100ee6:	c1 e9 0c             	shr    $0xc,%ecx
	for (size_t i = 0; i < npages; i++) {
f0100ee9:	ba 00 00 00 00       	mov    $0x0,%edx
f0100eee:	be 00 00 00 00       	mov    $0x0,%esi
f0100ef3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ef8:	eb 10                	jmp    f0100f0a <page_init+0x61>
			pages[i].pp_ref = 1;
f0100efa:	8b 3d 58 62 2b f0    	mov    0xf02b6258,%edi
f0100f00:	66 c7 44 c7 04 01 00 	movw   $0x1,0x4(%edi,%eax,8)
	for (size_t i = 0; i < npages; i++) {
f0100f07:	83 c0 01             	add    $0x1,%eax
f0100f0a:	39 05 60 62 2b f0    	cmp    %eax,0xf02b6260
f0100f10:	76 3e                	jbe    f0100f50 <page_init+0xa7>
		if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)/* 3,4条*/ ||  (i>=MPENTRY_PADDR/PGSIZE && i<(MPENTRY_PADDR+size)/PGSIZE) /*lab4*/){//不标记为free的页
f0100f12:	85 c0                	test   %eax,%eax
f0100f14:	74 e4                	je     f0100efa <page_init+0x51>
f0100f16:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0100f1b:	76 04                	jbe    f0100f21 <page_init+0x78>
f0100f1d:	39 c3                	cmp    %eax,%ebx
f0100f1f:	77 d9                	ja     f0100efa <page_init+0x51>
f0100f21:	83 f8 06             	cmp    $0x6,%eax
f0100f24:	76 04                	jbe    f0100f2a <page_init+0x81>
f0100f26:	39 c1                	cmp    %eax,%ecx
f0100f28:	77 d0                	ja     f0100efa <page_init+0x51>
f0100f2a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0100f31:	89 d7                	mov    %edx,%edi
f0100f33:	03 3d 58 62 2b f0    	add    0xf02b6258,%edi
f0100f39:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
			pages[i].pp_link = page_free_list;
f0100f3f:	89 37                	mov    %esi,(%edi)
			page_free_list = &pages[i];	
f0100f41:	89 d6                	mov    %edx,%esi
f0100f43:	03 35 58 62 2b f0    	add    0xf02b6258,%esi
f0100f49:	ba 01 00 00 00       	mov    $0x1,%edx
f0100f4e:	eb b7                	jmp    f0100f07 <page_init+0x5e>
f0100f50:	84 d2                	test   %dl,%dl
f0100f52:	74 06                	je     f0100f5a <page_init+0xb1>
f0100f54:	89 35 6c 62 2b f0    	mov    %esi,0xf02b626c
}
f0100f5a:	83 c4 0c             	add    $0xc,%esp
f0100f5d:	5b                   	pop    %ebx
f0100f5e:	5e                   	pop    %esi
f0100f5f:	5f                   	pop    %edi
f0100f60:	5d                   	pop    %ebp
f0100f61:	c3                   	ret    

f0100f62 <page_alloc>:
{
f0100f62:	55                   	push   %ebp
f0100f63:	89 e5                	mov    %esp,%ebp
f0100f65:	53                   	push   %ebx
f0100f66:	83 ec 04             	sub    $0x4,%esp
	if(!page_free_list) return res;
f0100f69:	8b 1d 6c 62 2b f0    	mov    0xf02b626c,%ebx
f0100f6f:	85 db                	test   %ebx,%ebx
f0100f71:	74 13                	je     f0100f86 <page_alloc+0x24>
	page_free_list=page_free_list -> pp_link;
f0100f73:	8b 03                	mov    (%ebx),%eax
f0100f75:	a3 6c 62 2b f0       	mov    %eax,0xf02b626c
	res ->pp_link=NULL;
f0100f7a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO){//ALLOC_ZERO在pmap.h中定义 ALLOC_ZERO = 1<<0,
f0100f80:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f84:	75 07                	jne    f0100f8d <page_alloc+0x2b>
}
f0100f86:	89 d8                	mov    %ebx,%eax
f0100f88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f8b:	c9                   	leave  
f0100f8c:	c3                   	ret    
f0100f8d:	89 d8                	mov    %ebx,%eax
f0100f8f:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f0100f95:	c1 f8 03             	sar    $0x3,%eax
f0100f98:	89 c2                	mov    %eax,%edx
f0100f9a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100f9d:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100fa2:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f0100fa8:	73 1b                	jae    f0100fc5 <page_alloc+0x63>
		memset(page2kva(res) , '\0' ,  PGSIZE );
f0100faa:	83 ec 04             	sub    $0x4,%esp
f0100fad:	68 00 10 00 00       	push   $0x1000
f0100fb2:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100fb4:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100fba:	52                   	push   %edx
f0100fbb:	e8 ad 48 00 00       	call   f010586d <memset>
f0100fc0:	83 c4 10             	add    $0x10,%esp
f0100fc3:	eb c1                	jmp    f0100f86 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fc5:	52                   	push   %edx
f0100fc6:	68 64 6d 10 f0       	push   $0xf0106d64
f0100fcb:	6a 5a                	push   $0x5a
f0100fcd:	68 bb 72 10 f0       	push   $0xf01072bb
f0100fd2:	e8 69 f0 ff ff       	call   f0100040 <_panic>

f0100fd7 <page_free>:
{
f0100fd7:	55                   	push   %ebp
f0100fd8:	89 e5                	mov    %esp,%ebp
f0100fda:	83 ec 08             	sub    $0x8,%esp
f0100fdd:	8b 45 08             	mov    0x8(%ebp),%eax
      	assert(pp->pp_ref == 0);
f0100fe0:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100fe5:	75 14                	jne    f0100ffb <page_free+0x24>
      	assert(pp->pp_link == NULL);
f0100fe7:	83 38 00             	cmpl   $0x0,(%eax)
f0100fea:	75 28                	jne    f0101014 <page_free+0x3d>
	pp->pp_link=page_free_list;
f0100fec:	8b 15 6c 62 2b f0    	mov    0xf02b626c,%edx
f0100ff2:	89 10                	mov    %edx,(%eax)
	page_free_list=pp;
f0100ff4:	a3 6c 62 2b f0       	mov    %eax,0xf02b626c
}
f0100ff9:	c9                   	leave  
f0100ffa:	c3                   	ret    
      	assert(pp->pp_ref == 0);
f0100ffb:	68 82 73 10 f0       	push   $0xf0107382
f0101000:	68 d5 72 10 f0       	push   $0xf01072d5
f0101005:	68 a1 01 00 00       	push   $0x1a1
f010100a:	68 af 72 10 f0       	push   $0xf01072af
f010100f:	e8 2c f0 ff ff       	call   f0100040 <_panic>
      	assert(pp->pp_link == NULL);
f0101014:	68 92 73 10 f0       	push   $0xf0107392
f0101019:	68 d5 72 10 f0       	push   $0xf01072d5
f010101e:	68 a2 01 00 00       	push   $0x1a2
f0101023:	68 af 72 10 f0       	push   $0xf01072af
f0101028:	e8 13 f0 ff ff       	call   f0100040 <_panic>

f010102d <page_decref>:
{
f010102d:	55                   	push   %ebp
f010102e:	89 e5                	mov    %esp,%ebp
f0101030:	83 ec 08             	sub    $0x8,%esp
f0101033:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101036:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010103a:	83 e8 01             	sub    $0x1,%eax
f010103d:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101041:	66 85 c0             	test   %ax,%ax
f0101044:	74 02                	je     f0101048 <page_decref+0x1b>
}
f0101046:	c9                   	leave  
f0101047:	c3                   	ret    
		page_free(pp);
f0101048:	83 ec 0c             	sub    $0xc,%esp
f010104b:	52                   	push   %edx
f010104c:	e8 86 ff ff ff       	call   f0100fd7 <page_free>
f0101051:	83 c4 10             	add    $0x10,%esp
}
f0101054:	eb f0                	jmp    f0101046 <page_decref+0x19>

f0101056 <pgdir_walk>:
{
f0101056:	55                   	push   %ebp
f0101057:	89 e5                	mov    %esp,%ebp
f0101059:	56                   	push   %esi
f010105a:	53                   	push   %ebx
f010105b:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t* dir_entry=pgdir+PDX(va); //PDX(va)返回page directory index,dir_entry是指向页目录中的DIR ENTRY(见图)的指针。
f010105e:	89 f3                	mov    %esi,%ebx
f0101060:	c1 eb 16             	shr    $0x16,%ebx
f0101063:	c1 e3 02             	shl    $0x2,%ebx
f0101066:	03 5d 08             	add    0x8(%ebp),%ebx
	if( !(*dir_entry & PTE_P) ){//如果这个页表不存在
f0101069:	f6 03 01             	testb  $0x1,(%ebx)
f010106c:	75 67                	jne    f01010d5 <pgdir_walk+0x7f>
		if(create==false) return NULL;
f010106e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101072:	0f 84 b0 00 00 00    	je     f0101128 <pgdir_walk+0xd2>
			struct PageInfo * new_pp =page_alloc(1);//别忘了这个它返回的是struct PageInfo *
f0101078:	83 ec 0c             	sub    $0xc,%esp
f010107b:	6a 01                	push   $0x1
f010107d:	e8 e0 fe ff ff       	call   f0100f62 <page_alloc>
			if(new_pp==NULL){
f0101082:	83 c4 10             	add    $0x10,%esp
f0101085:	85 c0                	test   %eax,%eax
f0101087:	74 71                	je     f01010fa <pgdir_walk+0xa4>
			new_pp->pp_ref++;
f0101089:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f010108e:	89 c2                	mov    %eax,%edx
f0101090:	2b 15 58 62 2b f0    	sub    0xf02b6258,%edx
f0101096:	c1 fa 03             	sar    $0x3,%edx
f0101099:	c1 e2 0c             	shl    $0xc,%edx
			*dir_entry=(page2pa(new_pp) | PTE_P | PTE_W | PTE_U);//设置dir_entry的标志位。注释中说可以设置宽松，所以这里全部设置为最宽松：可读写，应用程序级别即可访问。 dirty位 和access位不做设置。
f010109c:	83 ca 07             	or     $0x7,%edx
f010109f:	89 13                	mov    %edx,(%ebx)
f01010a1:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f01010a7:	c1 f8 03             	sar    $0x3,%eax
f01010aa:	89 c2                	mov    %eax,%edx
f01010ac:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01010af:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01010b4:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f01010ba:	73 45                	jae    f0101101 <pgdir_walk+0xab>
			memset(page2kva(new_pp) , '\0' ,  PGSIZE);//初始化new_page的物理内存，一定要用虚拟地址!!!!!			
f01010bc:	83 ec 04             	sub    $0x4,%esp
f01010bf:	68 00 10 00 00       	push   $0x1000
f01010c4:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01010c6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01010cc:	52                   	push   %edx
f01010cd:	e8 9b 47 00 00       	call   f010586d <memset>
f01010d2:	83 c4 10             	add    $0x10,%esp
	pte_t * page_base = KADDR(PTE_ADDR(*dir_entry));//注意这块的类型定义，这涉及地址运算。 很重要，之前的bug就是因为这里!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
f01010d5:	8b 03                	mov    (%ebx),%eax
f01010d7:	89 c2                	mov    %eax,%edx
f01010d9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01010df:	c1 e8 0c             	shr    $0xc,%eax
f01010e2:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f01010e8:	73 29                	jae    f0101113 <pgdir_walk+0xbd>
	return  &page_base[PTX(va)];	
f01010ea:	c1 ee 0a             	shr    $0xa,%esi
f01010ed:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01010f3:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
}
f01010fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010fd:	5b                   	pop    %ebx
f01010fe:	5e                   	pop    %esi
f01010ff:	5d                   	pop    %ebp
f0101100:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101101:	52                   	push   %edx
f0101102:	68 64 6d 10 f0       	push   $0xf0106d64
f0101107:	6a 5a                	push   $0x5a
f0101109:	68 bb 72 10 f0       	push   $0xf01072bb
f010110e:	e8 2d ef ff ff       	call   f0100040 <_panic>
f0101113:	52                   	push   %edx
f0101114:	68 64 6d 10 f0       	push   $0xf0106d64
f0101119:	68 dd 01 00 00       	push   $0x1dd
f010111e:	68 af 72 10 f0       	push   $0xf01072af
f0101123:	e8 18 ef ff ff       	call   f0100040 <_panic>
		if(create==false) return NULL;
f0101128:	b8 00 00 00 00       	mov    $0x0,%eax
f010112d:	eb cb                	jmp    f01010fa <pgdir_walk+0xa4>

f010112f <boot_map_region>:
{
f010112f:	55                   	push   %ebp
f0101130:	89 e5                	mov    %esp,%ebp
f0101132:	57                   	push   %edi
f0101133:	56                   	push   %esi
f0101134:	53                   	push   %ebx
f0101135:	83 ec 1c             	sub    $0x1c,%esp
f0101138:	89 c7                	mov    %eax,%edi
f010113a:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010113d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(int i=0; i<size;i+=PGSIZE){
f0101140:	be 00 00 00 00       	mov    $0x0,%esi
f0101145:	89 f3                	mov    %esi,%ebx
f0101147:	03 5d 08             	add    0x8(%ebp),%ebx
f010114a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f010114d:	76 3f                	jbe    f010118e <boot_map_region+0x5f>
		pt_entry=pgdir_walk(pgdir, (void *) va ,1);
f010114f:	83 ec 04             	sub    $0x4,%esp
f0101152:	6a 01                	push   $0x1
f0101154:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101157:	01 f0                	add    %esi,%eax
f0101159:	50                   	push   %eax
f010115a:	57                   	push   %edi
f010115b:	e8 f6 fe ff ff       	call   f0101056 <pgdir_walk>
		if (pt_entry == NULL) {
f0101160:	83 c4 10             	add    $0x10,%esp
f0101163:	85 c0                	test   %eax,%eax
f0101165:	74 10                	je     f0101177 <boot_map_region+0x48>
		* pt_entry=(pa |perm | PTE_P);//按照注释对pg_entry置标志位。
f0101167:	0b 5d 0c             	or     0xc(%ebp),%ebx
f010116a:	83 cb 01             	or     $0x1,%ebx
f010116d:	89 18                	mov    %ebx,(%eax)
	for(int i=0; i<size;i+=PGSIZE){
f010116f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101175:	eb ce                	jmp    f0101145 <boot_map_region+0x16>
            		panic("boot_map_region(): out of memory\n");
f0101177:	83 ec 04             	sub    $0x4,%esp
f010117a:	68 d0 76 10 f0       	push   $0xf01076d0
f010117f:	68 f7 01 00 00       	push   $0x1f7
f0101184:	68 af 72 10 f0       	push   $0xf01072af
f0101189:	e8 b2 ee ff ff       	call   f0100040 <_panic>
}
f010118e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101191:	5b                   	pop    %ebx
f0101192:	5e                   	pop    %esi
f0101193:	5f                   	pop    %edi
f0101194:	5d                   	pop    %ebp
f0101195:	c3                   	ret    

f0101196 <page_lookup>:
{
f0101196:	55                   	push   %ebp
f0101197:	89 e5                	mov    %esp,%ebp
f0101199:	53                   	push   %ebx
f010119a:	83 ec 08             	sub    $0x8,%esp
f010119d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t * pt_entry=pgdir_walk(pgdir,va,0);
f01011a0:	6a 00                	push   $0x0
f01011a2:	ff 75 0c             	push   0xc(%ebp)
f01011a5:	ff 75 08             	push   0x8(%ebp)
f01011a8:	e8 a9 fe ff ff       	call   f0101056 <pgdir_walk>
	if(pt_entry==NULL)  return NULL;
f01011ad:	83 c4 10             	add    $0x10,%esp
f01011b0:	85 c0                	test   %eax,%eax
f01011b2:	74 21                	je     f01011d5 <page_lookup+0x3f>
	if(!(*pt_entry & PTE_P))  return NULL;
f01011b4:	f6 00 01             	testb  $0x1,(%eax)
f01011b7:	74 35                	je     f01011ee <page_lookup+0x58>
	if(pte_store) *pte_store=pt_entry;
f01011b9:	85 db                	test   %ebx,%ebx
f01011bb:	74 02                	je     f01011bf <page_lookup+0x29>
f01011bd:	89 03                	mov    %eax,(%ebx)
f01011bf:	8b 00                	mov    (%eax),%eax
f01011c1:	c1 e8 0c             	shr    $0xc,%eax

//返回对应物理地址的 struct PageInfo* 部分
static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f01011c4:	39 05 60 62 2b f0    	cmp    %eax,0xf02b6260
f01011ca:	76 0e                	jbe    f01011da <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01011cc:	8b 15 58 62 2b f0    	mov    0xf02b6258,%edx
f01011d2:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01011d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011d8:	c9                   	leave  
f01011d9:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01011da:	83 ec 04             	sub    $0x4,%esp
f01011dd:	68 f4 76 10 f0       	push   $0xf01076f4
f01011e2:	6a 52                	push   $0x52
f01011e4:	68 bb 72 10 f0       	push   $0xf01072bb
f01011e9:	e8 52 ee ff ff       	call   f0100040 <_panic>
	if(!(*pt_entry & PTE_P))  return NULL;
f01011ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01011f3:	eb e0                	jmp    f01011d5 <page_lookup+0x3f>

f01011f5 <tlb_invalidate>:
{
f01011f5:	55                   	push   %ebp
f01011f6:	89 e5                	mov    %esp,%ebp
f01011f8:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01011fb:	e8 64 4c 00 00       	call   f0105e64 <cpunum>
f0101200:	6b c0 74             	imul   $0x74,%eax,%eax
f0101203:	83 b8 28 70 2f f0 00 	cmpl   $0x0,-0xfd08fd8(%eax)
f010120a:	74 16                	je     f0101222 <tlb_invalidate+0x2d>
f010120c:	e8 53 4c 00 00       	call   f0105e64 <cpunum>
f0101211:	6b c0 74             	imul   $0x74,%eax,%eax
f0101214:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f010121a:	8b 55 08             	mov    0x8(%ebp),%edx
f010121d:	39 50 60             	cmp    %edx,0x60(%eax)
f0101220:	75 06                	jne    f0101228 <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101222:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101225:	0f 01 38             	invlpg (%eax)
}
f0101228:	c9                   	leave  
f0101229:	c3                   	ret    

f010122a <page_remove>:
{
f010122a:	55                   	push   %ebp
f010122b:	89 e5                	mov    %esp,%ebp
f010122d:	56                   	push   %esi
f010122e:	53                   	push   %ebx
f010122f:	83 ec 14             	sub    $0x14,%esp
f0101232:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101235:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo * pp=page_lookup(pgdir,va,&pt_entry);
f0101238:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010123b:	50                   	push   %eax
f010123c:	56                   	push   %esi
f010123d:	53                   	push   %ebx
f010123e:	e8 53 ff ff ff       	call   f0101196 <page_lookup>
	if(pp==NULL) return ;
f0101243:	83 c4 10             	add    $0x10,%esp
f0101246:	85 c0                	test   %eax,%eax
f0101248:	74 1f                	je     f0101269 <page_remove+0x3f>
	page_decref(pp);
f010124a:	83 ec 0c             	sub    $0xc,%esp
f010124d:	50                   	push   %eax
f010124e:	e8 da fd ff ff       	call   f010102d <page_decref>
	*pt_entry= 0;
f0101253:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101256:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f010125c:	83 c4 08             	add    $0x8,%esp
f010125f:	56                   	push   %esi
f0101260:	53                   	push   %ebx
f0101261:	e8 8f ff ff ff       	call   f01011f5 <tlb_invalidate>
f0101266:	83 c4 10             	add    $0x10,%esp
}
f0101269:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010126c:	5b                   	pop    %ebx
f010126d:	5e                   	pop    %esi
f010126e:	5d                   	pop    %ebp
f010126f:	c3                   	ret    

f0101270 <page_insert>:
{
f0101270:	55                   	push   %ebp
f0101271:	89 e5                	mov    %esp,%ebp
f0101273:	57                   	push   %edi
f0101274:	56                   	push   %esi
f0101275:	53                   	push   %ebx
f0101276:	83 ec 10             	sub    $0x10,%esp
f0101279:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010127c:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pt_entry=pgdir_walk(pgdir,va,1);
f010127f:	6a 01                	push   $0x1
f0101281:	57                   	push   %edi
f0101282:	ff 75 08             	push   0x8(%ebp)
f0101285:	e8 cc fd ff ff       	call   f0101056 <pgdir_walk>
	if(pt_entry==NULL) return -E_NO_MEM;
f010128a:	83 c4 10             	add    $0x10,%esp
f010128d:	85 c0                	test   %eax,%eax
f010128f:	74 3e                	je     f01012cf <page_insert+0x5f>
f0101291:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;//这个一定要在前面，否则如果相同的pp 重新插入相同的va就会把  pp释放掉了。
f0101293:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if( (*pt_entry) & PTE_P ){//如果这个页已经存在
f0101298:	f6 00 01             	testb  $0x1,(%eax)
f010129b:	75 21                	jne    f01012be <page_insert+0x4e>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f010129d:	2b 1d 58 62 2b f0    	sub    0xf02b6258,%ebx
f01012a3:	c1 fb 03             	sar    $0x3,%ebx
f01012a6:	c1 e3 0c             	shl    $0xc,%ebx
	*pt_entry = *pt_entry | perm | PTE_P ;
f01012a9:	0b 5d 14             	or     0x14(%ebp),%ebx
f01012ac:	83 cb 01             	or     $0x1,%ebx
f01012af:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01012b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012b9:	5b                   	pop    %ebx
f01012ba:	5e                   	pop    %esi
f01012bb:	5f                   	pop    %edi
f01012bc:	5d                   	pop    %ebp
f01012bd:	c3                   	ret    
		page_remove(pgdir, va);
f01012be:	83 ec 08             	sub    $0x8,%esp
f01012c1:	57                   	push   %edi
f01012c2:	ff 75 08             	push   0x8(%ebp)
f01012c5:	e8 60 ff ff ff       	call   f010122a <page_remove>
f01012ca:	83 c4 10             	add    $0x10,%esp
f01012cd:	eb ce                	jmp    f010129d <page_insert+0x2d>
	if(pt_entry==NULL) return -E_NO_MEM;
f01012cf:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01012d4:	eb e0                	jmp    f01012b6 <page_insert+0x46>

f01012d6 <mmio_map_region>:
{
f01012d6:	55                   	push   %ebp
f01012d7:	89 e5                	mov    %esp,%ebp
f01012d9:	56                   	push   %esi
f01012da:	53                   	push   %ebx
	void *ret =(void*) base;
f01012db:	8b 35 00 83 12 f0    	mov    0xf0128300,%esi
	size=ROUNDUP(size,PGSIZE);
f01012e1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012e4:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01012ea:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(base + size > MMIOLIM || base + size < base /*unsigned 越界*/)  panic("mmio_map_region reservation overflow");
f01012f0:	89 f0                	mov    %esi,%eax
f01012f2:	01 d8                	add    %ebx,%eax
f01012f4:	72 2c                	jb     f0101322 <mmio_map_region+0x4c>
f01012f6:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01012fb:	77 25                	ja     f0101322 <mmio_map_region+0x4c>
	boot_map_region(kern_pgdir, base, size, pa, PTE_W|PTE_PCD|PTE_PWT);
f01012fd:	83 ec 08             	sub    $0x8,%esp
f0101300:	6a 1a                	push   $0x1a
f0101302:	ff 75 08             	push   0x8(%ebp)
f0101305:	89 d9                	mov    %ebx,%ecx
f0101307:	89 f2                	mov    %esi,%edx
f0101309:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
f010130e:	e8 1c fe ff ff       	call   f010112f <boot_map_region>
	base += size;
f0101313:	01 1d 00 83 12 f0    	add    %ebx,0xf0128300
}
f0101319:	89 f0                	mov    %esi,%eax
f010131b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010131e:	5b                   	pop    %ebx
f010131f:	5e                   	pop    %esi
f0101320:	5d                   	pop    %ebp
f0101321:	c3                   	ret    
	if(base + size > MMIOLIM || base + size < base /*unsigned 越界*/)  panic("mmio_map_region reservation overflow");
f0101322:	83 ec 04             	sub    $0x4,%esp
f0101325:	68 14 77 10 f0       	push   $0xf0107714
f010132a:	68 94 02 00 00       	push   $0x294
f010132f:	68 af 72 10 f0       	push   $0xf01072af
f0101334:	e8 07 ed ff ff       	call   f0100040 <_panic>

f0101339 <mem_init>:
{
f0101339:	55                   	push   %ebp
f010133a:	89 e5                	mov    %esp,%ebp
f010133c:	57                   	push   %edi
f010133d:	56                   	push   %esi
f010133e:	53                   	push   %ebx
f010133f:	83 ec 4c             	sub    $0x4c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101342:	b8 15 00 00 00       	mov    $0x15,%eax
f0101347:	e8 8f f7 ff ff       	call   f0100adb <nvram_read>
f010134c:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010134e:	b8 17 00 00 00       	mov    $0x17,%eax
f0101353:	e8 83 f7 ff ff       	call   f0100adb <nvram_read>
f0101358:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010135a:	b8 34 00 00 00       	mov    $0x34,%eax
f010135f:	e8 77 f7 ff ff       	call   f0100adb <nvram_read>
	if (ext16mem)
f0101364:	c1 e0 06             	shl    $0x6,%eax
f0101367:	0f 84 d3 00 00 00    	je     f0101440 <mem_init+0x107>
		totalmem = 16 * 1024 + ext16mem;
f010136d:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101372:	89 c2                	mov    %eax,%edx
f0101374:	c1 ea 02             	shr    $0x2,%edx
f0101377:	89 15 60 62 2b f0    	mov    %edx,0xf02b6260
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010137d:	89 c2                	mov    %eax,%edx
f010137f:	29 da                	sub    %ebx,%edx
f0101381:	52                   	push   %edx
f0101382:	53                   	push   %ebx
f0101383:	50                   	push   %eax
f0101384:	68 3c 77 10 f0       	push   $0xf010773c
f0101389:	e8 27 26 00 00       	call   f01039b5 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010138e:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101393:	e8 6c f7 ff ff       	call   f0100b04 <boot_alloc>
f0101398:	a3 5c 62 2b f0       	mov    %eax,0xf02b625c
	memset(kern_pgdir, 0, PGSIZE);
f010139d:	83 c4 0c             	add    $0xc,%esp
f01013a0:	68 00 10 00 00       	push   $0x1000
f01013a5:	6a 00                	push   $0x0
f01013a7:	50                   	push   %eax
f01013a8:	e8 c0 44 00 00       	call   f010586d <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013ad:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
	if ((uint32_t)kva < KERNBASE)
f01013b2:	83 c4 10             	add    $0x10,%esp
f01013b5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013ba:	0f 86 90 00 00 00    	jbe    f0101450 <mem_init+0x117>
	return (physaddr_t)kva - KERNBASE;
f01013c0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013c6:	83 ca 05             	or     $0x5,%edx
f01013c9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = boot_alloc(npages * sizeof(struct PageInfo));//pages是页信息数组的地址
f01013cf:	a1 60 62 2b f0       	mov    0xf02b6260,%eax
f01013d4:	c1 e0 03             	shl    $0x3,%eax
f01013d7:	e8 28 f7 ff ff       	call   f0100b04 <boot_alloc>
f01013dc:	a3 58 62 2b f0       	mov    %eax,0xf02b6258
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01013e1:	83 ec 04             	sub    $0x4,%esp
f01013e4:	8b 0d 60 62 2b f0    	mov    0xf02b6260,%ecx
f01013ea:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013f1:	52                   	push   %edx
f01013f2:	6a 00                	push   $0x0
f01013f4:	50                   	push   %eax
f01013f5:	e8 73 44 00 00       	call   f010586d <memset>
	envs = (struct Env*) boot_alloc (NENV * sizeof (struct Env) );
f01013fa:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013ff:	e8 00 f7 ff ff       	call   f0100b04 <boot_alloc>
f0101404:	a3 70 62 2b f0       	mov    %eax,0xf02b6270
	memset(envs , 0, NENV * sizeof(struct Env));
f0101409:	83 c4 0c             	add    $0xc,%esp
f010140c:	68 00 f0 01 00       	push   $0x1f000
f0101411:	6a 00                	push   $0x0
f0101413:	50                   	push   %eax
f0101414:	e8 54 44 00 00       	call   f010586d <memset>
	page_init();
f0101419:	e8 8b fa ff ff       	call   f0100ea9 <page_init>
	check_page_free_list(1);
f010141e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101423:	e8 93 f7 ff ff       	call   f0100bbb <check_page_free_list>
	if (!pages)
f0101428:	83 c4 10             	add    $0x10,%esp
f010142b:	83 3d 58 62 2b f0 00 	cmpl   $0x0,0xf02b6258
f0101432:	74 31                	je     f0101465 <mem_init+0x12c>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101434:	a1 6c 62 2b f0       	mov    0xf02b626c,%eax
f0101439:	bb 00 00 00 00       	mov    $0x0,%ebx
f010143e:	eb 41                	jmp    f0101481 <mem_init+0x148>
		totalmem = 1 * 1024 + extmem;
f0101440:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101446:	85 f6                	test   %esi,%esi
f0101448:	0f 44 c3             	cmove  %ebx,%eax
f010144b:	e9 22 ff ff ff       	jmp    f0101372 <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101450:	50                   	push   %eax
f0101451:	68 88 6d 10 f0       	push   $0xf0106d88
f0101456:	68 9f 00 00 00       	push   $0x9f
f010145b:	68 af 72 10 f0       	push   $0xf01072af
f0101460:	e8 db eb ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f0101465:	83 ec 04             	sub    $0x4,%esp
f0101468:	68 a6 73 10 f0       	push   $0xf01073a6
f010146d:	68 2e 03 00 00       	push   $0x32e
f0101472:	68 af 72 10 f0       	push   $0xf01072af
f0101477:	e8 c4 eb ff ff       	call   f0100040 <_panic>
		++nfree;
f010147c:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010147f:	8b 00                	mov    (%eax),%eax
f0101481:	85 c0                	test   %eax,%eax
f0101483:	75 f7                	jne    f010147c <mem_init+0x143>
	assert((pp0 = page_alloc(0)));
f0101485:	83 ec 0c             	sub    $0xc,%esp
f0101488:	6a 00                	push   $0x0
f010148a:	e8 d3 fa ff ff       	call   f0100f62 <page_alloc>
f010148f:	89 c7                	mov    %eax,%edi
f0101491:	83 c4 10             	add    $0x10,%esp
f0101494:	85 c0                	test   %eax,%eax
f0101496:	0f 84 1f 02 00 00    	je     f01016bb <mem_init+0x382>
	assert((pp1 = page_alloc(0)));
f010149c:	83 ec 0c             	sub    $0xc,%esp
f010149f:	6a 00                	push   $0x0
f01014a1:	e8 bc fa ff ff       	call   f0100f62 <page_alloc>
f01014a6:	89 c6                	mov    %eax,%esi
f01014a8:	83 c4 10             	add    $0x10,%esp
f01014ab:	85 c0                	test   %eax,%eax
f01014ad:	0f 84 21 02 00 00    	je     f01016d4 <mem_init+0x39b>
	assert((pp2 = page_alloc(0)));
f01014b3:	83 ec 0c             	sub    $0xc,%esp
f01014b6:	6a 00                	push   $0x0
f01014b8:	e8 a5 fa ff ff       	call   f0100f62 <page_alloc>
f01014bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014c0:	83 c4 10             	add    $0x10,%esp
f01014c3:	85 c0                	test   %eax,%eax
f01014c5:	0f 84 22 02 00 00    	je     f01016ed <mem_init+0x3b4>
	assert(pp1 && pp1 != pp0);
f01014cb:	39 f7                	cmp    %esi,%edi
f01014cd:	0f 84 33 02 00 00    	je     f0101706 <mem_init+0x3cd>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014d6:	39 c7                	cmp    %eax,%edi
f01014d8:	0f 84 41 02 00 00    	je     f010171f <mem_init+0x3e6>
f01014de:	39 c6                	cmp    %eax,%esi
f01014e0:	0f 84 39 02 00 00    	je     f010171f <mem_init+0x3e6>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f01014e6:	8b 0d 58 62 2b f0    	mov    0xf02b6258,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014ec:	8b 15 60 62 2b f0    	mov    0xf02b6260,%edx
f01014f2:	c1 e2 0c             	shl    $0xc,%edx
f01014f5:	89 f8                	mov    %edi,%eax
f01014f7:	29 c8                	sub    %ecx,%eax
f01014f9:	c1 f8 03             	sar    $0x3,%eax
f01014fc:	c1 e0 0c             	shl    $0xc,%eax
f01014ff:	39 d0                	cmp    %edx,%eax
f0101501:	0f 83 31 02 00 00    	jae    f0101738 <mem_init+0x3ff>
f0101507:	89 f0                	mov    %esi,%eax
f0101509:	29 c8                	sub    %ecx,%eax
f010150b:	c1 f8 03             	sar    $0x3,%eax
f010150e:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101511:	39 c2                	cmp    %eax,%edx
f0101513:	0f 86 38 02 00 00    	jbe    f0101751 <mem_init+0x418>
f0101519:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010151c:	29 c8                	sub    %ecx,%eax
f010151e:	c1 f8 03             	sar    $0x3,%eax
f0101521:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101524:	39 c2                	cmp    %eax,%edx
f0101526:	0f 86 3e 02 00 00    	jbe    f010176a <mem_init+0x431>
	fl = page_free_list;
f010152c:	a1 6c 62 2b f0       	mov    0xf02b626c,%eax
f0101531:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101534:	c7 05 6c 62 2b f0 00 	movl   $0x0,0xf02b626c
f010153b:	00 00 00 
	assert(!page_alloc(0));
f010153e:	83 ec 0c             	sub    $0xc,%esp
f0101541:	6a 00                	push   $0x0
f0101543:	e8 1a fa ff ff       	call   f0100f62 <page_alloc>
f0101548:	83 c4 10             	add    $0x10,%esp
f010154b:	85 c0                	test   %eax,%eax
f010154d:	0f 85 30 02 00 00    	jne    f0101783 <mem_init+0x44a>
	page_free(pp0);
f0101553:	83 ec 0c             	sub    $0xc,%esp
f0101556:	57                   	push   %edi
f0101557:	e8 7b fa ff ff       	call   f0100fd7 <page_free>
	page_free(pp1);
f010155c:	89 34 24             	mov    %esi,(%esp)
f010155f:	e8 73 fa ff ff       	call   f0100fd7 <page_free>
	page_free(pp2);
f0101564:	83 c4 04             	add    $0x4,%esp
f0101567:	ff 75 d4             	push   -0x2c(%ebp)
f010156a:	e8 68 fa ff ff       	call   f0100fd7 <page_free>
	assert((pp0 = page_alloc(0)));
f010156f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101576:	e8 e7 f9 ff ff       	call   f0100f62 <page_alloc>
f010157b:	89 c6                	mov    %eax,%esi
f010157d:	83 c4 10             	add    $0x10,%esp
f0101580:	85 c0                	test   %eax,%eax
f0101582:	0f 84 14 02 00 00    	je     f010179c <mem_init+0x463>
	assert((pp1 = page_alloc(0)));
f0101588:	83 ec 0c             	sub    $0xc,%esp
f010158b:	6a 00                	push   $0x0
f010158d:	e8 d0 f9 ff ff       	call   f0100f62 <page_alloc>
f0101592:	89 c7                	mov    %eax,%edi
f0101594:	83 c4 10             	add    $0x10,%esp
f0101597:	85 c0                	test   %eax,%eax
f0101599:	0f 84 16 02 00 00    	je     f01017b5 <mem_init+0x47c>
	assert((pp2 = page_alloc(0)));
f010159f:	83 ec 0c             	sub    $0xc,%esp
f01015a2:	6a 00                	push   $0x0
f01015a4:	e8 b9 f9 ff ff       	call   f0100f62 <page_alloc>
f01015a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015ac:	83 c4 10             	add    $0x10,%esp
f01015af:	85 c0                	test   %eax,%eax
f01015b1:	0f 84 17 02 00 00    	je     f01017ce <mem_init+0x495>
	assert(pp1 && pp1 != pp0);
f01015b7:	39 fe                	cmp    %edi,%esi
f01015b9:	0f 84 28 02 00 00    	je     f01017e7 <mem_init+0x4ae>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015c2:	39 c6                	cmp    %eax,%esi
f01015c4:	0f 84 36 02 00 00    	je     f0101800 <mem_init+0x4c7>
f01015ca:	39 c7                	cmp    %eax,%edi
f01015cc:	0f 84 2e 02 00 00    	je     f0101800 <mem_init+0x4c7>
	assert(!page_alloc(0));
f01015d2:	83 ec 0c             	sub    $0xc,%esp
f01015d5:	6a 00                	push   $0x0
f01015d7:	e8 86 f9 ff ff       	call   f0100f62 <page_alloc>
f01015dc:	83 c4 10             	add    $0x10,%esp
f01015df:	85 c0                	test   %eax,%eax
f01015e1:	0f 85 32 02 00 00    	jne    f0101819 <mem_init+0x4e0>
f01015e7:	89 f0                	mov    %esi,%eax
f01015e9:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f01015ef:	c1 f8 03             	sar    $0x3,%eax
f01015f2:	89 c2                	mov    %eax,%edx
f01015f4:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01015f7:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01015fc:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f0101602:	0f 83 2a 02 00 00    	jae    f0101832 <mem_init+0x4f9>
	memset(page2kva(pp0), 1, PGSIZE);
f0101608:	83 ec 04             	sub    $0x4,%esp
f010160b:	68 00 10 00 00       	push   $0x1000
f0101610:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101612:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101618:	52                   	push   %edx
f0101619:	e8 4f 42 00 00       	call   f010586d <memset>
	page_free(pp0);
f010161e:	89 34 24             	mov    %esi,(%esp)
f0101621:	e8 b1 f9 ff ff       	call   f0100fd7 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101626:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010162d:	e8 30 f9 ff ff       	call   f0100f62 <page_alloc>
f0101632:	83 c4 10             	add    $0x10,%esp
f0101635:	85 c0                	test   %eax,%eax
f0101637:	0f 84 07 02 00 00    	je     f0101844 <mem_init+0x50b>
	assert(pp && pp0 == pp);
f010163d:	39 c6                	cmp    %eax,%esi
f010163f:	0f 85 18 02 00 00    	jne    f010185d <mem_init+0x524>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101645:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f010164b:	c1 f8 03             	sar    $0x3,%eax
f010164e:	89 c2                	mov    %eax,%edx
f0101650:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101653:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101658:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f010165e:	0f 83 12 02 00 00    	jae    f0101876 <mem_init+0x53d>
	return (void *)(pa + KERNBASE);
f0101664:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010166a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101670:	80 38 00             	cmpb   $0x0,(%eax)
f0101673:	0f 85 0f 02 00 00    	jne    f0101888 <mem_init+0x54f>
	for (i = 0; i < PGSIZE; i++)
f0101679:	83 c0 01             	add    $0x1,%eax
f010167c:	39 d0                	cmp    %edx,%eax
f010167e:	75 f0                	jne    f0101670 <mem_init+0x337>
	page_free_list = fl;
f0101680:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101683:	a3 6c 62 2b f0       	mov    %eax,0xf02b626c
	page_free(pp0);
f0101688:	83 ec 0c             	sub    $0xc,%esp
f010168b:	56                   	push   %esi
f010168c:	e8 46 f9 ff ff       	call   f0100fd7 <page_free>
	page_free(pp1);
f0101691:	89 3c 24             	mov    %edi,(%esp)
f0101694:	e8 3e f9 ff ff       	call   f0100fd7 <page_free>
	page_free(pp2);
f0101699:	83 c4 04             	add    $0x4,%esp
f010169c:	ff 75 d4             	push   -0x2c(%ebp)
f010169f:	e8 33 f9 ff ff       	call   f0100fd7 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016a4:	a1 6c 62 2b f0       	mov    0xf02b626c,%eax
f01016a9:	83 c4 10             	add    $0x10,%esp
f01016ac:	85 c0                	test   %eax,%eax
f01016ae:	0f 84 ed 01 00 00    	je     f01018a1 <mem_init+0x568>
		--nfree;
f01016b4:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016b7:	8b 00                	mov    (%eax),%eax
f01016b9:	eb f1                	jmp    f01016ac <mem_init+0x373>
	assert((pp0 = page_alloc(0)));
f01016bb:	68 c1 73 10 f0       	push   $0xf01073c1
f01016c0:	68 d5 72 10 f0       	push   $0xf01072d5
f01016c5:	68 36 03 00 00       	push   $0x336
f01016ca:	68 af 72 10 f0       	push   $0xf01072af
f01016cf:	e8 6c e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016d4:	68 d7 73 10 f0       	push   $0xf01073d7
f01016d9:	68 d5 72 10 f0       	push   $0xf01072d5
f01016de:	68 37 03 00 00       	push   $0x337
f01016e3:	68 af 72 10 f0       	push   $0xf01072af
f01016e8:	e8 53 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016ed:	68 ed 73 10 f0       	push   $0xf01073ed
f01016f2:	68 d5 72 10 f0       	push   $0xf01072d5
f01016f7:	68 38 03 00 00       	push   $0x338
f01016fc:	68 af 72 10 f0       	push   $0xf01072af
f0101701:	e8 3a e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101706:	68 03 74 10 f0       	push   $0xf0107403
f010170b:	68 d5 72 10 f0       	push   $0xf01072d5
f0101710:	68 3b 03 00 00       	push   $0x33b
f0101715:	68 af 72 10 f0       	push   $0xf01072af
f010171a:	e8 21 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010171f:	68 78 77 10 f0       	push   $0xf0107778
f0101724:	68 d5 72 10 f0       	push   $0xf01072d5
f0101729:	68 3c 03 00 00       	push   $0x33c
f010172e:	68 af 72 10 f0       	push   $0xf01072af
f0101733:	e8 08 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101738:	68 15 74 10 f0       	push   $0xf0107415
f010173d:	68 d5 72 10 f0       	push   $0xf01072d5
f0101742:	68 3d 03 00 00       	push   $0x33d
f0101747:	68 af 72 10 f0       	push   $0xf01072af
f010174c:	e8 ef e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101751:	68 32 74 10 f0       	push   $0xf0107432
f0101756:	68 d5 72 10 f0       	push   $0xf01072d5
f010175b:	68 3e 03 00 00       	push   $0x33e
f0101760:	68 af 72 10 f0       	push   $0xf01072af
f0101765:	e8 d6 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010176a:	68 4f 74 10 f0       	push   $0xf010744f
f010176f:	68 d5 72 10 f0       	push   $0xf01072d5
f0101774:	68 3f 03 00 00       	push   $0x33f
f0101779:	68 af 72 10 f0       	push   $0xf01072af
f010177e:	e8 bd e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101783:	68 6c 74 10 f0       	push   $0xf010746c
f0101788:	68 d5 72 10 f0       	push   $0xf01072d5
f010178d:	68 46 03 00 00       	push   $0x346
f0101792:	68 af 72 10 f0       	push   $0xf01072af
f0101797:	e8 a4 e8 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010179c:	68 c1 73 10 f0       	push   $0xf01073c1
f01017a1:	68 d5 72 10 f0       	push   $0xf01072d5
f01017a6:	68 4d 03 00 00       	push   $0x34d
f01017ab:	68 af 72 10 f0       	push   $0xf01072af
f01017b0:	e8 8b e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017b5:	68 d7 73 10 f0       	push   $0xf01073d7
f01017ba:	68 d5 72 10 f0       	push   $0xf01072d5
f01017bf:	68 4e 03 00 00       	push   $0x34e
f01017c4:	68 af 72 10 f0       	push   $0xf01072af
f01017c9:	e8 72 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017ce:	68 ed 73 10 f0       	push   $0xf01073ed
f01017d3:	68 d5 72 10 f0       	push   $0xf01072d5
f01017d8:	68 4f 03 00 00       	push   $0x34f
f01017dd:	68 af 72 10 f0       	push   $0xf01072af
f01017e2:	e8 59 e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01017e7:	68 03 74 10 f0       	push   $0xf0107403
f01017ec:	68 d5 72 10 f0       	push   $0xf01072d5
f01017f1:	68 51 03 00 00       	push   $0x351
f01017f6:	68 af 72 10 f0       	push   $0xf01072af
f01017fb:	e8 40 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101800:	68 78 77 10 f0       	push   $0xf0107778
f0101805:	68 d5 72 10 f0       	push   $0xf01072d5
f010180a:	68 52 03 00 00       	push   $0x352
f010180f:	68 af 72 10 f0       	push   $0xf01072af
f0101814:	e8 27 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101819:	68 6c 74 10 f0       	push   $0xf010746c
f010181e:	68 d5 72 10 f0       	push   $0xf01072d5
f0101823:	68 53 03 00 00       	push   $0x353
f0101828:	68 af 72 10 f0       	push   $0xf01072af
f010182d:	e8 0e e8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101832:	52                   	push   %edx
f0101833:	68 64 6d 10 f0       	push   $0xf0106d64
f0101838:	6a 5a                	push   $0x5a
f010183a:	68 bb 72 10 f0       	push   $0xf01072bb
f010183f:	e8 fc e7 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101844:	68 7b 74 10 f0       	push   $0xf010747b
f0101849:	68 d5 72 10 f0       	push   $0xf01072d5
f010184e:	68 58 03 00 00       	push   $0x358
f0101853:	68 af 72 10 f0       	push   $0xf01072af
f0101858:	e8 e3 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010185d:	68 99 74 10 f0       	push   $0xf0107499
f0101862:	68 d5 72 10 f0       	push   $0xf01072d5
f0101867:	68 59 03 00 00       	push   $0x359
f010186c:	68 af 72 10 f0       	push   $0xf01072af
f0101871:	e8 ca e7 ff ff       	call   f0100040 <_panic>
f0101876:	52                   	push   %edx
f0101877:	68 64 6d 10 f0       	push   $0xf0106d64
f010187c:	6a 5a                	push   $0x5a
f010187e:	68 bb 72 10 f0       	push   $0xf01072bb
f0101883:	e8 b8 e7 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f0101888:	68 a9 74 10 f0       	push   $0xf01074a9
f010188d:	68 d5 72 10 f0       	push   $0xf01072d5
f0101892:	68 5c 03 00 00       	push   $0x35c
f0101897:	68 af 72 10 f0       	push   $0xf01072af
f010189c:	e8 9f e7 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f01018a1:	85 db                	test   %ebx,%ebx
f01018a3:	0f 85 3f 09 00 00    	jne    f01021e8 <mem_init+0xeaf>
	cprintf("check_page_alloc() succeeded!\n");
f01018a9:	83 ec 0c             	sub    $0xc,%esp
f01018ac:	68 98 77 10 f0       	push   $0xf0107798
f01018b1:	e8 ff 20 00 00       	call   f01039b5 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018bd:	e8 a0 f6 ff ff       	call   f0100f62 <page_alloc>
f01018c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018c5:	83 c4 10             	add    $0x10,%esp
f01018c8:	85 c0                	test   %eax,%eax
f01018ca:	0f 84 31 09 00 00    	je     f0102201 <mem_init+0xec8>
	assert((pp1 = page_alloc(0)));
f01018d0:	83 ec 0c             	sub    $0xc,%esp
f01018d3:	6a 00                	push   $0x0
f01018d5:	e8 88 f6 ff ff       	call   f0100f62 <page_alloc>
f01018da:	89 c3                	mov    %eax,%ebx
f01018dc:	83 c4 10             	add    $0x10,%esp
f01018df:	85 c0                	test   %eax,%eax
f01018e1:	0f 84 33 09 00 00    	je     f010221a <mem_init+0xee1>
	assert((pp2 = page_alloc(0)));
f01018e7:	83 ec 0c             	sub    $0xc,%esp
f01018ea:	6a 00                	push   $0x0
f01018ec:	e8 71 f6 ff ff       	call   f0100f62 <page_alloc>
f01018f1:	89 c6                	mov    %eax,%esi
f01018f3:	83 c4 10             	add    $0x10,%esp
f01018f6:	85 c0                	test   %eax,%eax
f01018f8:	0f 84 35 09 00 00    	je     f0102233 <mem_init+0xefa>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018fe:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101901:	0f 84 45 09 00 00    	je     f010224c <mem_init+0xf13>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101907:	39 c3                	cmp    %eax,%ebx
f0101909:	0f 84 56 09 00 00    	je     f0102265 <mem_init+0xf2c>
f010190f:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101912:	0f 84 4d 09 00 00    	je     f0102265 <mem_init+0xf2c>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101918:	a1 6c 62 2b f0       	mov    0xf02b626c,%eax
f010191d:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101920:	c7 05 6c 62 2b f0 00 	movl   $0x0,0xf02b626c
f0101927:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010192a:	83 ec 0c             	sub    $0xc,%esp
f010192d:	6a 00                	push   $0x0
f010192f:	e8 2e f6 ff ff       	call   f0100f62 <page_alloc>
f0101934:	83 c4 10             	add    $0x10,%esp
f0101937:	85 c0                	test   %eax,%eax
f0101939:	0f 85 3f 09 00 00    	jne    f010227e <mem_init+0xf45>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010193f:	83 ec 04             	sub    $0x4,%esp
f0101942:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101945:	50                   	push   %eax
f0101946:	6a 00                	push   $0x0
f0101948:	ff 35 5c 62 2b f0    	push   0xf02b625c
f010194e:	e8 43 f8 ff ff       	call   f0101196 <page_lookup>
f0101953:	83 c4 10             	add    $0x10,%esp
f0101956:	85 c0                	test   %eax,%eax
f0101958:	0f 85 39 09 00 00    	jne    f0102297 <mem_init+0xf5e>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010195e:	6a 02                	push   $0x2
f0101960:	6a 00                	push   $0x0
f0101962:	53                   	push   %ebx
f0101963:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0101969:	e8 02 f9 ff ff       	call   f0101270 <page_insert>
f010196e:	83 c4 10             	add    $0x10,%esp
f0101971:	85 c0                	test   %eax,%eax
f0101973:	0f 89 37 09 00 00    	jns    f01022b0 <mem_init+0xf77>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101979:	83 ec 0c             	sub    $0xc,%esp
f010197c:	ff 75 d4             	push   -0x2c(%ebp)
f010197f:	e8 53 f6 ff ff       	call   f0100fd7 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101984:	6a 02                	push   $0x2
f0101986:	6a 00                	push   $0x0
f0101988:	53                   	push   %ebx
f0101989:	ff 35 5c 62 2b f0    	push   0xf02b625c
f010198f:	e8 dc f8 ff ff       	call   f0101270 <page_insert>
f0101994:	83 c4 20             	add    $0x20,%esp
f0101997:	85 c0                	test   %eax,%eax
f0101999:	0f 85 2a 09 00 00    	jne    f01022c9 <mem_init+0xf90>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010199f:	8b 3d 5c 62 2b f0    	mov    0xf02b625c,%edi
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f01019a5:	8b 0d 58 62 2b f0    	mov    0xf02b6258,%ecx
f01019ab:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01019ae:	8b 17                	mov    (%edi),%edx
f01019b0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019b9:	29 c8                	sub    %ecx,%eax
f01019bb:	c1 f8 03             	sar    $0x3,%eax
f01019be:	c1 e0 0c             	shl    $0xc,%eax
f01019c1:	39 c2                	cmp    %eax,%edx
f01019c3:	0f 85 19 09 00 00    	jne    f01022e2 <mem_init+0xfa9>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019c9:	ba 00 00 00 00       	mov    $0x0,%edx
f01019ce:	89 f8                	mov    %edi,%eax
f01019d0:	e8 83 f1 ff ff       	call   f0100b58 <check_va2pa>
f01019d5:	89 c2                	mov    %eax,%edx
f01019d7:	89 d8                	mov    %ebx,%eax
f01019d9:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01019dc:	c1 f8 03             	sar    $0x3,%eax
f01019df:	c1 e0 0c             	shl    $0xc,%eax
f01019e2:	39 c2                	cmp    %eax,%edx
f01019e4:	0f 85 11 09 00 00    	jne    f01022fb <mem_init+0xfc2>
	assert(pp1->pp_ref == 1);
f01019ea:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019ef:	0f 85 1f 09 00 00    	jne    f0102314 <mem_init+0xfdb>
	assert(pp0->pp_ref == 1);
f01019f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019f8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01019fd:	0f 85 2a 09 00 00    	jne    f010232d <mem_init+0xff4>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a03:	6a 02                	push   $0x2
f0101a05:	68 00 10 00 00       	push   $0x1000
f0101a0a:	56                   	push   %esi
f0101a0b:	57                   	push   %edi
f0101a0c:	e8 5f f8 ff ff       	call   f0101270 <page_insert>
f0101a11:	83 c4 10             	add    $0x10,%esp
f0101a14:	85 c0                	test   %eax,%eax
f0101a16:	0f 85 2a 09 00 00    	jne    f0102346 <mem_init+0x100d>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a1c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a21:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
f0101a26:	e8 2d f1 ff ff       	call   f0100b58 <check_va2pa>
f0101a2b:	89 c2                	mov    %eax,%edx
f0101a2d:	89 f0                	mov    %esi,%eax
f0101a2f:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f0101a35:	c1 f8 03             	sar    $0x3,%eax
f0101a38:	c1 e0 0c             	shl    $0xc,%eax
f0101a3b:	39 c2                	cmp    %eax,%edx
f0101a3d:	0f 85 1c 09 00 00    	jne    f010235f <mem_init+0x1026>
	assert(pp2->pp_ref == 1);
f0101a43:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a48:	0f 85 2a 09 00 00    	jne    f0102378 <mem_init+0x103f>

	// should be no free memory
	assert(!page_alloc(0));
f0101a4e:	83 ec 0c             	sub    $0xc,%esp
f0101a51:	6a 00                	push   $0x0
f0101a53:	e8 0a f5 ff ff       	call   f0100f62 <page_alloc>
f0101a58:	83 c4 10             	add    $0x10,%esp
f0101a5b:	85 c0                	test   %eax,%eax
f0101a5d:	0f 85 2e 09 00 00    	jne    f0102391 <mem_init+0x1058>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a63:	6a 02                	push   $0x2
f0101a65:	68 00 10 00 00       	push   $0x1000
f0101a6a:	56                   	push   %esi
f0101a6b:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0101a71:	e8 fa f7 ff ff       	call   f0101270 <page_insert>
f0101a76:	83 c4 10             	add    $0x10,%esp
f0101a79:	85 c0                	test   %eax,%eax
f0101a7b:	0f 85 29 09 00 00    	jne    f01023aa <mem_init+0x1071>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a81:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a86:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
f0101a8b:	e8 c8 f0 ff ff       	call   f0100b58 <check_va2pa>
f0101a90:	89 c2                	mov    %eax,%edx
f0101a92:	89 f0                	mov    %esi,%eax
f0101a94:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f0101a9a:	c1 f8 03             	sar    $0x3,%eax
f0101a9d:	c1 e0 0c             	shl    $0xc,%eax
f0101aa0:	39 c2                	cmp    %eax,%edx
f0101aa2:	0f 85 1b 09 00 00    	jne    f01023c3 <mem_init+0x108a>
	assert(pp2->pp_ref == 1);
f0101aa8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101aad:	0f 85 29 09 00 00    	jne    f01023dc <mem_init+0x10a3>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ab3:	83 ec 0c             	sub    $0xc,%esp
f0101ab6:	6a 00                	push   $0x0
f0101ab8:	e8 a5 f4 ff ff       	call   f0100f62 <page_alloc>
f0101abd:	83 c4 10             	add    $0x10,%esp
f0101ac0:	85 c0                	test   %eax,%eax
f0101ac2:	0f 85 2d 09 00 00    	jne    f01023f5 <mem_init+0x10bc>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ac8:	8b 15 5c 62 2b f0    	mov    0xf02b625c,%edx
f0101ace:	8b 02                	mov    (%edx),%eax
f0101ad0:	89 c7                	mov    %eax,%edi
f0101ad2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0101ad8:	c1 e8 0c             	shr    $0xc,%eax
f0101adb:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f0101ae1:	0f 83 27 09 00 00    	jae    f010240e <mem_init+0x10d5>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ae7:	83 ec 04             	sub    $0x4,%esp
f0101aea:	6a 00                	push   $0x0
f0101aec:	68 00 10 00 00       	push   $0x1000
f0101af1:	52                   	push   %edx
f0101af2:	e8 5f f5 ff ff       	call   f0101056 <pgdir_walk>
f0101af7:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0101afd:	83 c4 10             	add    $0x10,%esp
f0101b00:	39 f8                	cmp    %edi,%eax
f0101b02:	0f 85 1b 09 00 00    	jne    f0102423 <mem_init+0x10ea>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b08:	6a 06                	push   $0x6
f0101b0a:	68 00 10 00 00       	push   $0x1000
f0101b0f:	56                   	push   %esi
f0101b10:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0101b16:	e8 55 f7 ff ff       	call   f0101270 <page_insert>
f0101b1b:	83 c4 10             	add    $0x10,%esp
f0101b1e:	85 c0                	test   %eax,%eax
f0101b20:	0f 85 16 09 00 00    	jne    f010243c <mem_init+0x1103>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b26:	8b 3d 5c 62 2b f0    	mov    0xf02b625c,%edi
f0101b2c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b31:	89 f8                	mov    %edi,%eax
f0101b33:	e8 20 f0 ff ff       	call   f0100b58 <check_va2pa>
f0101b38:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101b3a:	89 f0                	mov    %esi,%eax
f0101b3c:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f0101b42:	c1 f8 03             	sar    $0x3,%eax
f0101b45:	c1 e0 0c             	shl    $0xc,%eax
f0101b48:	39 c2                	cmp    %eax,%edx
f0101b4a:	0f 85 05 09 00 00    	jne    f0102455 <mem_init+0x111c>
	assert(pp2->pp_ref == 1);
f0101b50:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b55:	0f 85 13 09 00 00    	jne    f010246e <mem_init+0x1135>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b5b:	83 ec 04             	sub    $0x4,%esp
f0101b5e:	6a 00                	push   $0x0
f0101b60:	68 00 10 00 00       	push   $0x1000
f0101b65:	57                   	push   %edi
f0101b66:	e8 eb f4 ff ff       	call   f0101056 <pgdir_walk>
f0101b6b:	83 c4 10             	add    $0x10,%esp
f0101b6e:	f6 00 04             	testb  $0x4,(%eax)
f0101b71:	0f 84 10 09 00 00    	je     f0102487 <mem_init+0x114e>
	assert(kern_pgdir[0] & PTE_U);
f0101b77:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
f0101b7c:	f6 00 04             	testb  $0x4,(%eax)
f0101b7f:	0f 84 1b 09 00 00    	je     f01024a0 <mem_init+0x1167>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b85:	6a 02                	push   $0x2
f0101b87:	68 00 10 00 00       	push   $0x1000
f0101b8c:	56                   	push   %esi
f0101b8d:	50                   	push   %eax
f0101b8e:	e8 dd f6 ff ff       	call   f0101270 <page_insert>
f0101b93:	83 c4 10             	add    $0x10,%esp
f0101b96:	85 c0                	test   %eax,%eax
f0101b98:	0f 85 1b 09 00 00    	jne    f01024b9 <mem_init+0x1180>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b9e:	83 ec 04             	sub    $0x4,%esp
f0101ba1:	6a 00                	push   $0x0
f0101ba3:	68 00 10 00 00       	push   $0x1000
f0101ba8:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0101bae:	e8 a3 f4 ff ff       	call   f0101056 <pgdir_walk>
f0101bb3:	83 c4 10             	add    $0x10,%esp
f0101bb6:	f6 00 02             	testb  $0x2,(%eax)
f0101bb9:	0f 84 13 09 00 00    	je     f01024d2 <mem_init+0x1199>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bbf:	83 ec 04             	sub    $0x4,%esp
f0101bc2:	6a 00                	push   $0x0
f0101bc4:	68 00 10 00 00       	push   $0x1000
f0101bc9:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0101bcf:	e8 82 f4 ff ff       	call   f0101056 <pgdir_walk>
f0101bd4:	83 c4 10             	add    $0x10,%esp
f0101bd7:	f6 00 04             	testb  $0x4,(%eax)
f0101bda:	0f 85 0b 09 00 00    	jne    f01024eb <mem_init+0x11b2>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101be0:	6a 02                	push   $0x2
f0101be2:	68 00 00 40 00       	push   $0x400000
f0101be7:	ff 75 d4             	push   -0x2c(%ebp)
f0101bea:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0101bf0:	e8 7b f6 ff ff       	call   f0101270 <page_insert>
f0101bf5:	83 c4 10             	add    $0x10,%esp
f0101bf8:	85 c0                	test   %eax,%eax
f0101bfa:	0f 89 04 09 00 00    	jns    f0102504 <mem_init+0x11cb>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c00:	6a 02                	push   $0x2
f0101c02:	68 00 10 00 00       	push   $0x1000
f0101c07:	53                   	push   %ebx
f0101c08:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0101c0e:	e8 5d f6 ff ff       	call   f0101270 <page_insert>
f0101c13:	83 c4 10             	add    $0x10,%esp
f0101c16:	85 c0                	test   %eax,%eax
f0101c18:	0f 85 ff 08 00 00    	jne    f010251d <mem_init+0x11e4>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c1e:	83 ec 04             	sub    $0x4,%esp
f0101c21:	6a 00                	push   $0x0
f0101c23:	68 00 10 00 00       	push   $0x1000
f0101c28:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0101c2e:	e8 23 f4 ff ff       	call   f0101056 <pgdir_walk>
f0101c33:	83 c4 10             	add    $0x10,%esp
f0101c36:	f6 00 04             	testb  $0x4,(%eax)
f0101c39:	0f 85 f7 08 00 00    	jne    f0102536 <mem_init+0x11fd>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c3f:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
f0101c44:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c47:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c4c:	e8 07 ef ff ff       	call   f0100b58 <check_va2pa>
f0101c51:	89 df                	mov    %ebx,%edi
f0101c53:	2b 3d 58 62 2b f0    	sub    0xf02b6258,%edi
f0101c59:	c1 ff 03             	sar    $0x3,%edi
f0101c5c:	c1 e7 0c             	shl    $0xc,%edi
f0101c5f:	39 f8                	cmp    %edi,%eax
f0101c61:	0f 85 e8 08 00 00    	jne    f010254f <mem_init+0x1216>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c67:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c6c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c6f:	e8 e4 ee ff ff       	call   f0100b58 <check_va2pa>
f0101c74:	39 c7                	cmp    %eax,%edi
f0101c76:	0f 85 ec 08 00 00    	jne    f0102568 <mem_init+0x122f>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c7c:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101c81:	0f 85 fa 08 00 00    	jne    f0102581 <mem_init+0x1248>
	assert(pp2->pp_ref == 0);
f0101c87:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c8c:	0f 85 08 09 00 00    	jne    f010259a <mem_init+0x1261>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c92:	83 ec 0c             	sub    $0xc,%esp
f0101c95:	6a 00                	push   $0x0
f0101c97:	e8 c6 f2 ff ff       	call   f0100f62 <page_alloc>
f0101c9c:	83 c4 10             	add    $0x10,%esp
f0101c9f:	39 c6                	cmp    %eax,%esi
f0101ca1:	0f 85 0c 09 00 00    	jne    f01025b3 <mem_init+0x127a>
f0101ca7:	85 c0                	test   %eax,%eax
f0101ca9:	0f 84 04 09 00 00    	je     f01025b3 <mem_init+0x127a>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101caf:	83 ec 08             	sub    $0x8,%esp
f0101cb2:	6a 00                	push   $0x0
f0101cb4:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0101cba:	e8 6b f5 ff ff       	call   f010122a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cbf:	8b 3d 5c 62 2b f0    	mov    0xf02b625c,%edi
f0101cc5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cca:	89 f8                	mov    %edi,%eax
f0101ccc:	e8 87 ee ff ff       	call   f0100b58 <check_va2pa>
f0101cd1:	83 c4 10             	add    $0x10,%esp
f0101cd4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cd7:	0f 85 ef 08 00 00    	jne    f01025cc <mem_init+0x1293>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cdd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ce2:	89 f8                	mov    %edi,%eax
f0101ce4:	e8 6f ee ff ff       	call   f0100b58 <check_va2pa>
f0101ce9:	89 c2                	mov    %eax,%edx
f0101ceb:	89 d8                	mov    %ebx,%eax
f0101ced:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f0101cf3:	c1 f8 03             	sar    $0x3,%eax
f0101cf6:	c1 e0 0c             	shl    $0xc,%eax
f0101cf9:	39 c2                	cmp    %eax,%edx
f0101cfb:	0f 85 e4 08 00 00    	jne    f01025e5 <mem_init+0x12ac>
	assert(pp1->pp_ref == 1);
f0101d01:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d06:	0f 85 f2 08 00 00    	jne    f01025fe <mem_init+0x12c5>
	assert(pp2->pp_ref == 0);
f0101d0c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d11:	0f 85 00 09 00 00    	jne    f0102617 <mem_init+0x12de>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d17:	6a 00                	push   $0x0
f0101d19:	68 00 10 00 00       	push   $0x1000
f0101d1e:	53                   	push   %ebx
f0101d1f:	57                   	push   %edi
f0101d20:	e8 4b f5 ff ff       	call   f0101270 <page_insert>
f0101d25:	83 c4 10             	add    $0x10,%esp
f0101d28:	85 c0                	test   %eax,%eax
f0101d2a:	0f 85 00 09 00 00    	jne    f0102630 <mem_init+0x12f7>
	assert(pp1->pp_ref);
f0101d30:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d35:	0f 84 0e 09 00 00    	je     f0102649 <mem_init+0x1310>
	assert(pp1->pp_link == NULL);
f0101d3b:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101d3e:	0f 85 1e 09 00 00    	jne    f0102662 <mem_init+0x1329>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d44:	83 ec 08             	sub    $0x8,%esp
f0101d47:	68 00 10 00 00       	push   $0x1000
f0101d4c:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0101d52:	e8 d3 f4 ff ff       	call   f010122a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d57:	8b 3d 5c 62 2b f0    	mov    0xf02b625c,%edi
f0101d5d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d62:	89 f8                	mov    %edi,%eax
f0101d64:	e8 ef ed ff ff       	call   f0100b58 <check_va2pa>
f0101d69:	83 c4 10             	add    $0x10,%esp
f0101d6c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d6f:	0f 85 06 09 00 00    	jne    f010267b <mem_init+0x1342>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d75:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d7a:	89 f8                	mov    %edi,%eax
f0101d7c:	e8 d7 ed ff ff       	call   f0100b58 <check_va2pa>
f0101d81:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d84:	0f 85 0a 09 00 00    	jne    f0102694 <mem_init+0x135b>
	assert(pp1->pp_ref == 0);
f0101d8a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d8f:	0f 85 18 09 00 00    	jne    f01026ad <mem_init+0x1374>
	assert(pp2->pp_ref == 0);
f0101d95:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d9a:	0f 85 26 09 00 00    	jne    f01026c6 <mem_init+0x138d>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101da0:	83 ec 0c             	sub    $0xc,%esp
f0101da3:	6a 00                	push   $0x0
f0101da5:	e8 b8 f1 ff ff       	call   f0100f62 <page_alloc>
f0101daa:	83 c4 10             	add    $0x10,%esp
f0101dad:	85 c0                	test   %eax,%eax
f0101daf:	0f 84 2a 09 00 00    	je     f01026df <mem_init+0x13a6>
f0101db5:	39 c3                	cmp    %eax,%ebx
f0101db7:	0f 85 22 09 00 00    	jne    f01026df <mem_init+0x13a6>

	// should be no free memory
	assert(!page_alloc(0));
f0101dbd:	83 ec 0c             	sub    $0xc,%esp
f0101dc0:	6a 00                	push   $0x0
f0101dc2:	e8 9b f1 ff ff       	call   f0100f62 <page_alloc>
f0101dc7:	83 c4 10             	add    $0x10,%esp
f0101dca:	85 c0                	test   %eax,%eax
f0101dcc:	0f 85 26 09 00 00    	jne    f01026f8 <mem_init+0x13bf>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101dd2:	8b 0d 5c 62 2b f0    	mov    0xf02b625c,%ecx
f0101dd8:	8b 11                	mov    (%ecx),%edx
f0101dda:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101de0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101de3:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f0101de9:	c1 f8 03             	sar    $0x3,%eax
f0101dec:	c1 e0 0c             	shl    $0xc,%eax
f0101def:	39 c2                	cmp    %eax,%edx
f0101df1:	0f 85 1a 09 00 00    	jne    f0102711 <mem_init+0x13d8>
	kern_pgdir[0] = 0;
f0101df7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101dfd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e00:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e05:	0f 85 1f 09 00 00    	jne    f010272a <mem_init+0x13f1>
	pp0->pp_ref = 0;
f0101e0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e0e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101e14:	83 ec 0c             	sub    $0xc,%esp
f0101e17:	50                   	push   %eax
f0101e18:	e8 ba f1 ff ff       	call   f0100fd7 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e1d:	83 c4 0c             	add    $0xc,%esp
f0101e20:	6a 01                	push   $0x1
f0101e22:	68 00 10 40 00       	push   $0x401000
f0101e27:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0101e2d:	e8 24 f2 ff ff       	call   f0101056 <pgdir_walk>
f0101e32:	89 45 d0             	mov    %eax,-0x30(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101e35:	8b 0d 5c 62 2b f0    	mov    0xf02b625c,%ecx
f0101e3b:	8b 41 04             	mov    0x4(%ecx),%eax
f0101e3e:	89 c7                	mov    %eax,%edi
f0101e40:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0101e46:	8b 15 60 62 2b f0    	mov    0xf02b6260,%edx
f0101e4c:	c1 e8 0c             	shr    $0xc,%eax
f0101e4f:	83 c4 10             	add    $0x10,%esp
f0101e52:	39 d0                	cmp    %edx,%eax
f0101e54:	0f 83 e9 08 00 00    	jae    f0102743 <mem_init+0x140a>
	assert(ptep == ptep1 + PTX(va));
f0101e5a:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0101e60:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101e63:	0f 85 ef 08 00 00    	jne    f0102758 <mem_init+0x141f>
	kern_pgdir[PDX(va)] = 0;
f0101e69:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101e70:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e73:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101e79:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f0101e7f:	c1 f8 03             	sar    $0x3,%eax
f0101e82:	89 c1                	mov    %eax,%ecx
f0101e84:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f0101e87:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101e8c:	39 c2                	cmp    %eax,%edx
f0101e8e:	0f 86 dd 08 00 00    	jbe    f0102771 <mem_init+0x1438>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e94:	83 ec 04             	sub    $0x4,%esp
f0101e97:	68 00 10 00 00       	push   $0x1000
f0101e9c:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101ea1:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101ea7:	51                   	push   %ecx
f0101ea8:	e8 c0 39 00 00       	call   f010586d <memset>
	page_free(pp0);
f0101ead:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101eb0:	89 3c 24             	mov    %edi,(%esp)
f0101eb3:	e8 1f f1 ff ff       	call   f0100fd7 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101eb8:	83 c4 0c             	add    $0xc,%esp
f0101ebb:	6a 01                	push   $0x1
f0101ebd:	6a 00                	push   $0x0
f0101ebf:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0101ec5:	e8 8c f1 ff ff       	call   f0101056 <pgdir_walk>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101eca:	89 f8                	mov    %edi,%eax
f0101ecc:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f0101ed2:	c1 f8 03             	sar    $0x3,%eax
f0101ed5:	89 c2                	mov    %eax,%edx
f0101ed7:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101eda:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101edf:	83 c4 10             	add    $0x10,%esp
f0101ee2:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f0101ee8:	0f 83 95 08 00 00    	jae    f0102783 <mem_init+0x144a>
	return (void *)(pa + KERNBASE);
f0101eee:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101ef4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101efa:	f6 00 01             	testb  $0x1,(%eax)
f0101efd:	0f 85 92 08 00 00    	jne    f0102795 <mem_init+0x145c>
	for(i=0; i<NPTENTRIES; i++)
f0101f03:	83 c0 04             	add    $0x4,%eax
f0101f06:	39 d0                	cmp    %edx,%eax
f0101f08:	75 f0                	jne    f0101efa <mem_init+0xbc1>
	kern_pgdir[0] = 0;
f0101f0a:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
f0101f0f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101f15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f18:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101f1e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101f21:	89 0d 6c 62 2b f0    	mov    %ecx,0xf02b626c

	// free the pages we took
	page_free(pp0);
f0101f27:	83 ec 0c             	sub    $0xc,%esp
f0101f2a:	50                   	push   %eax
f0101f2b:	e8 a7 f0 ff ff       	call   f0100fd7 <page_free>
	page_free(pp1);
f0101f30:	89 1c 24             	mov    %ebx,(%esp)
f0101f33:	e8 9f f0 ff ff       	call   f0100fd7 <page_free>
	page_free(pp2);
f0101f38:	89 34 24             	mov    %esi,(%esp)
f0101f3b:	e8 97 f0 ff ff       	call   f0100fd7 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101f40:	83 c4 08             	add    $0x8,%esp
f0101f43:	68 01 10 00 00       	push   $0x1001
f0101f48:	6a 00                	push   $0x0
f0101f4a:	e8 87 f3 ff ff       	call   f01012d6 <mmio_map_region>
f0101f4f:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101f51:	83 c4 08             	add    $0x8,%esp
f0101f54:	68 00 10 00 00       	push   $0x1000
f0101f59:	6a 00                	push   $0x0
f0101f5b:	e8 76 f3 ff ff       	call   f01012d6 <mmio_map_region>
f0101f60:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101f62:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f68:	83 c4 10             	add    $0x10,%esp
f0101f6b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f71:	0f 86 37 08 00 00    	jbe    f01027ae <mem_init+0x1475>
f0101f77:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f7c:	0f 87 2c 08 00 00    	ja     f01027ae <mem_init+0x1475>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f82:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f88:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f8e:	0f 87 33 08 00 00    	ja     f01027c7 <mem_init+0x148e>
f0101f94:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f9a:	0f 86 27 08 00 00    	jbe    f01027c7 <mem_init+0x148e>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101fa0:	89 da                	mov    %ebx,%edx
f0101fa2:	09 f2                	or     %esi,%edx
f0101fa4:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101faa:	0f 85 30 08 00 00    	jne    f01027e0 <mem_init+0x14a7>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101fb0:	39 c6                	cmp    %eax,%esi
f0101fb2:	0f 82 41 08 00 00    	jb     f01027f9 <mem_init+0x14c0>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101fb8:	8b 3d 5c 62 2b f0    	mov    0xf02b625c,%edi
f0101fbe:	89 da                	mov    %ebx,%edx
f0101fc0:	89 f8                	mov    %edi,%eax
f0101fc2:	e8 91 eb ff ff       	call   f0100b58 <check_va2pa>
f0101fc7:	85 c0                	test   %eax,%eax
f0101fc9:	0f 85 43 08 00 00    	jne    f0102812 <mem_init+0x14d9>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101fcf:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101fd5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fd8:	89 c2                	mov    %eax,%edx
f0101fda:	89 f8                	mov    %edi,%eax
f0101fdc:	e8 77 eb ff ff       	call   f0100b58 <check_va2pa>
f0101fe1:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101fe6:	0f 85 3f 08 00 00    	jne    f010282b <mem_init+0x14f2>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101fec:	89 f2                	mov    %esi,%edx
f0101fee:	89 f8                	mov    %edi,%eax
f0101ff0:	e8 63 eb ff ff       	call   f0100b58 <check_va2pa>
f0101ff5:	85 c0                	test   %eax,%eax
f0101ff7:	0f 85 47 08 00 00    	jne    f0102844 <mem_init+0x150b>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0101ffd:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102003:	89 f8                	mov    %edi,%eax
f0102005:	e8 4e eb ff ff       	call   f0100b58 <check_va2pa>
f010200a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010200d:	0f 85 4a 08 00 00    	jne    f010285d <mem_init+0x1524>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102013:	83 ec 04             	sub    $0x4,%esp
f0102016:	6a 00                	push   $0x0
f0102018:	53                   	push   %ebx
f0102019:	57                   	push   %edi
f010201a:	e8 37 f0 ff ff       	call   f0101056 <pgdir_walk>
f010201f:	83 c4 10             	add    $0x10,%esp
f0102022:	f6 00 1a             	testb  $0x1a,(%eax)
f0102025:	0f 84 4b 08 00 00    	je     f0102876 <mem_init+0x153d>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010202b:	83 ec 04             	sub    $0x4,%esp
f010202e:	6a 00                	push   $0x0
f0102030:	53                   	push   %ebx
f0102031:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0102037:	e8 1a f0 ff ff       	call   f0101056 <pgdir_walk>
f010203c:	8b 00                	mov    (%eax),%eax
f010203e:	83 c4 10             	add    $0x10,%esp
f0102041:	83 e0 04             	and    $0x4,%eax
f0102044:	89 c7                	mov    %eax,%edi
f0102046:	0f 85 43 08 00 00    	jne    f010288f <mem_init+0x1556>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010204c:	83 ec 04             	sub    $0x4,%esp
f010204f:	6a 00                	push   $0x0
f0102051:	53                   	push   %ebx
f0102052:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0102058:	e8 f9 ef ff ff       	call   f0101056 <pgdir_walk>
f010205d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102063:	83 c4 0c             	add    $0xc,%esp
f0102066:	6a 00                	push   $0x0
f0102068:	ff 75 d4             	push   -0x2c(%ebp)
f010206b:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0102071:	e8 e0 ef ff ff       	call   f0101056 <pgdir_walk>
f0102076:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010207c:	83 c4 0c             	add    $0xc,%esp
f010207f:	6a 00                	push   $0x0
f0102081:	56                   	push   %esi
f0102082:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0102088:	e8 c9 ef ff ff       	call   f0101056 <pgdir_walk>
f010208d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102093:	c7 04 24 9c 75 10 f0 	movl   $0xf010759c,(%esp)
f010209a:	e8 16 19 00 00       	call   f01039b5 <cprintf>
	boot_map_region(kern_pgdir, UPAGES,ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE) , PADDR(pages), PTE_U | PTE_P);//但其实按照memlayout.h中的图，直接用PTSIZE也一样。因为PTSIZE远超过所需内存了，并且按图来说，其空闲内存也无他用，这里就正常写。
f010209f:	a1 58 62 2b f0       	mov    0xf02b6258,%eax
	if ((uint32_t)kva < KERNBASE)
f01020a4:	83 c4 10             	add    $0x10,%esp
f01020a7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020ac:	0f 86 f6 07 00 00    	jbe    f01028a8 <mem_init+0x156f>
f01020b2:	8b 15 60 62 2b f0    	mov    0xf02b6260,%edx
f01020b8:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f01020bf:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01020c5:	83 ec 08             	sub    $0x8,%esp
f01020c8:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020ca:	05 00 00 00 10       	add    $0x10000000,%eax
f01020cf:	50                   	push   %eax
f01020d0:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020d5:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
f01020da:	e8 50 f0 ff ff       	call   f010112f <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f01020df:	a1 70 62 2b f0       	mov    0xf02b6270,%eax
	if ((uint32_t)kva < KERNBASE)
f01020e4:	83 c4 10             	add    $0x10,%esp
f01020e7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020ec:	0f 86 cb 07 00 00    	jbe    f01028bd <mem_init+0x1584>
f01020f2:	83 ec 08             	sub    $0x8,%esp
f01020f5:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020f7:	05 00 00 00 10       	add    $0x10000000,%eax
f01020fc:	50                   	push   %eax
f01020fd:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102102:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102107:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
f010210c:	e8 1e f0 ff ff       	call   f010112f <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102111:	83 c4 10             	add    $0x10,%esp
f0102114:	b8 00 e0 11 f0       	mov    $0xf011e000,%eax
f0102119:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010211e:	0f 86 ae 07 00 00    	jbe    f01028d2 <mem_init+0x1599>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102124:	83 ec 08             	sub    $0x8,%esp
f0102127:	6a 02                	push   $0x2
f0102129:	68 00 e0 11 00       	push   $0x11e000
f010212e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102133:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102138:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
f010213d:	e8 ed ef ff ff       	call   f010112f <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-KERNBASE , 0, PTE_W);
f0102142:	83 c4 08             	add    $0x8,%esp
f0102145:	6a 02                	push   $0x2
f0102147:	6a 00                	push   $0x0
f0102149:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f010214e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102153:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
f0102158:	e8 d2 ef ff ff       	call   f010112f <boot_map_region>
f010215d:	c7 45 d0 00 70 2b f0 	movl   $0xf02b7000,-0x30(%ebp)
f0102164:	83 c4 10             	add    $0x10,%esp
f0102167:	bb 00 70 2b f0       	mov    $0xf02b7000,%ebx
f010216c:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102171:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102177:	0f 86 6a 07 00 00    	jbe    f01028e7 <mem_init+0x15ae>
		boot_map_region(kern_pgdir, 
f010217d:	83 ec 08             	sub    $0x8,%esp
f0102180:	6a 02                	push   $0x2
f0102182:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102188:	50                   	push   %eax
f0102189:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010218e:	89 f2                	mov    %esi,%edx
f0102190:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
f0102195:	e8 95 ef ff ff       	call   f010112f <boot_map_region>
	for(size_t i = 0; i < NCPU; i++) {
f010219a:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01021a0:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f01021a6:	83 c4 10             	add    $0x10,%esp
f01021a9:	81 fb 00 70 2f f0    	cmp    $0xf02f7000,%ebx
f01021af:	75 c0                	jne    f0102171 <mem_init+0xe38>
	pgdir = kern_pgdir;
f01021b1:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
f01021b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01021b9:	a1 60 62 2b f0       	mov    0xf02b6260,%eax
f01021be:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01021c1:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01021c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021cd:	8b 35 58 62 2b f0    	mov    0xf02b6258,%esi
	return (physaddr_t)kva - KERNBASE;
f01021d3:	8d 8e 00 00 00 10    	lea    0x10000000(%esi),%ecx
f01021d9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01021dc:	89 fb                	mov    %edi,%ebx
f01021de:	89 7d c8             	mov    %edi,-0x38(%ebp)
f01021e1:	89 c7                	mov    %eax,%edi
f01021e3:	e9 2f 07 00 00       	jmp    f0102917 <mem_init+0x15de>
	assert(nfree == 0);
f01021e8:	68 b3 74 10 f0       	push   $0xf01074b3
f01021ed:	68 d5 72 10 f0       	push   $0xf01072d5
f01021f2:	68 69 03 00 00       	push   $0x369
f01021f7:	68 af 72 10 f0       	push   $0xf01072af
f01021fc:	e8 3f de ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102201:	68 c1 73 10 f0       	push   $0xf01073c1
f0102206:	68 d5 72 10 f0       	push   $0xf01072d5
f010220b:	68 cf 03 00 00       	push   $0x3cf
f0102210:	68 af 72 10 f0       	push   $0xf01072af
f0102215:	e8 26 de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010221a:	68 d7 73 10 f0       	push   $0xf01073d7
f010221f:	68 d5 72 10 f0       	push   $0xf01072d5
f0102224:	68 d0 03 00 00       	push   $0x3d0
f0102229:	68 af 72 10 f0       	push   $0xf01072af
f010222e:	e8 0d de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102233:	68 ed 73 10 f0       	push   $0xf01073ed
f0102238:	68 d5 72 10 f0       	push   $0xf01072d5
f010223d:	68 d1 03 00 00       	push   $0x3d1
f0102242:	68 af 72 10 f0       	push   $0xf01072af
f0102247:	e8 f4 dd ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010224c:	68 03 74 10 f0       	push   $0xf0107403
f0102251:	68 d5 72 10 f0       	push   $0xf01072d5
f0102256:	68 d4 03 00 00       	push   $0x3d4
f010225b:	68 af 72 10 f0       	push   $0xf01072af
f0102260:	e8 db dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102265:	68 78 77 10 f0       	push   $0xf0107778
f010226a:	68 d5 72 10 f0       	push   $0xf01072d5
f010226f:	68 d5 03 00 00       	push   $0x3d5
f0102274:	68 af 72 10 f0       	push   $0xf01072af
f0102279:	e8 c2 dd ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010227e:	68 6c 74 10 f0       	push   $0xf010746c
f0102283:	68 d5 72 10 f0       	push   $0xf01072d5
f0102288:	68 dc 03 00 00       	push   $0x3dc
f010228d:	68 af 72 10 f0       	push   $0xf01072af
f0102292:	e8 a9 dd ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102297:	68 b8 77 10 f0       	push   $0xf01077b8
f010229c:	68 d5 72 10 f0       	push   $0xf01072d5
f01022a1:	68 df 03 00 00       	push   $0x3df
f01022a6:	68 af 72 10 f0       	push   $0xf01072af
f01022ab:	e8 90 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01022b0:	68 f0 77 10 f0       	push   $0xf01077f0
f01022b5:	68 d5 72 10 f0       	push   $0xf01072d5
f01022ba:	68 e2 03 00 00       	push   $0x3e2
f01022bf:	68 af 72 10 f0       	push   $0xf01072af
f01022c4:	e8 77 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01022c9:	68 20 78 10 f0       	push   $0xf0107820
f01022ce:	68 d5 72 10 f0       	push   $0xf01072d5
f01022d3:	68 e6 03 00 00       	push   $0x3e6
f01022d8:	68 af 72 10 f0       	push   $0xf01072af
f01022dd:	e8 5e dd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022e2:	68 50 78 10 f0       	push   $0xf0107850
f01022e7:	68 d5 72 10 f0       	push   $0xf01072d5
f01022ec:	68 e7 03 00 00       	push   $0x3e7
f01022f1:	68 af 72 10 f0       	push   $0xf01072af
f01022f6:	e8 45 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01022fb:	68 78 78 10 f0       	push   $0xf0107878
f0102300:	68 d5 72 10 f0       	push   $0xf01072d5
f0102305:	68 e8 03 00 00       	push   $0x3e8
f010230a:	68 af 72 10 f0       	push   $0xf01072af
f010230f:	e8 2c dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102314:	68 be 74 10 f0       	push   $0xf01074be
f0102319:	68 d5 72 10 f0       	push   $0xf01072d5
f010231e:	68 e9 03 00 00       	push   $0x3e9
f0102323:	68 af 72 10 f0       	push   $0xf01072af
f0102328:	e8 13 dd ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f010232d:	68 cf 74 10 f0       	push   $0xf01074cf
f0102332:	68 d5 72 10 f0       	push   $0xf01072d5
f0102337:	68 ea 03 00 00       	push   $0x3ea
f010233c:	68 af 72 10 f0       	push   $0xf01072af
f0102341:	e8 fa dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102346:	68 a8 78 10 f0       	push   $0xf01078a8
f010234b:	68 d5 72 10 f0       	push   $0xf01072d5
f0102350:	68 ed 03 00 00       	push   $0x3ed
f0102355:	68 af 72 10 f0       	push   $0xf01072af
f010235a:	e8 e1 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010235f:	68 e4 78 10 f0       	push   $0xf01078e4
f0102364:	68 d5 72 10 f0       	push   $0xf01072d5
f0102369:	68 ee 03 00 00       	push   $0x3ee
f010236e:	68 af 72 10 f0       	push   $0xf01072af
f0102373:	e8 c8 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102378:	68 e0 74 10 f0       	push   $0xf01074e0
f010237d:	68 d5 72 10 f0       	push   $0xf01072d5
f0102382:	68 ef 03 00 00       	push   $0x3ef
f0102387:	68 af 72 10 f0       	push   $0xf01072af
f010238c:	e8 af dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102391:	68 6c 74 10 f0       	push   $0xf010746c
f0102396:	68 d5 72 10 f0       	push   $0xf01072d5
f010239b:	68 f2 03 00 00       	push   $0x3f2
f01023a0:	68 af 72 10 f0       	push   $0xf01072af
f01023a5:	e8 96 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023aa:	68 a8 78 10 f0       	push   $0xf01078a8
f01023af:	68 d5 72 10 f0       	push   $0xf01072d5
f01023b4:	68 f5 03 00 00       	push   $0x3f5
f01023b9:	68 af 72 10 f0       	push   $0xf01072af
f01023be:	e8 7d dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023c3:	68 e4 78 10 f0       	push   $0xf01078e4
f01023c8:	68 d5 72 10 f0       	push   $0xf01072d5
f01023cd:	68 f6 03 00 00       	push   $0x3f6
f01023d2:	68 af 72 10 f0       	push   $0xf01072af
f01023d7:	e8 64 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01023dc:	68 e0 74 10 f0       	push   $0xf01074e0
f01023e1:	68 d5 72 10 f0       	push   $0xf01072d5
f01023e6:	68 f7 03 00 00       	push   $0x3f7
f01023eb:	68 af 72 10 f0       	push   $0xf01072af
f01023f0:	e8 4b dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01023f5:	68 6c 74 10 f0       	push   $0xf010746c
f01023fa:	68 d5 72 10 f0       	push   $0xf01072d5
f01023ff:	68 fb 03 00 00       	push   $0x3fb
f0102404:	68 af 72 10 f0       	push   $0xf01072af
f0102409:	e8 32 dc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010240e:	57                   	push   %edi
f010240f:	68 64 6d 10 f0       	push   $0xf0106d64
f0102414:	68 fe 03 00 00       	push   $0x3fe
f0102419:	68 af 72 10 f0       	push   $0xf01072af
f010241e:	e8 1d dc ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102423:	68 14 79 10 f0       	push   $0xf0107914
f0102428:	68 d5 72 10 f0       	push   $0xf01072d5
f010242d:	68 ff 03 00 00       	push   $0x3ff
f0102432:	68 af 72 10 f0       	push   $0xf01072af
f0102437:	e8 04 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010243c:	68 54 79 10 f0       	push   $0xf0107954
f0102441:	68 d5 72 10 f0       	push   $0xf01072d5
f0102446:	68 02 04 00 00       	push   $0x402
f010244b:	68 af 72 10 f0       	push   $0xf01072af
f0102450:	e8 eb db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102455:	68 e4 78 10 f0       	push   $0xf01078e4
f010245a:	68 d5 72 10 f0       	push   $0xf01072d5
f010245f:	68 03 04 00 00       	push   $0x403
f0102464:	68 af 72 10 f0       	push   $0xf01072af
f0102469:	e8 d2 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010246e:	68 e0 74 10 f0       	push   $0xf01074e0
f0102473:	68 d5 72 10 f0       	push   $0xf01072d5
f0102478:	68 04 04 00 00       	push   $0x404
f010247d:	68 af 72 10 f0       	push   $0xf01072af
f0102482:	e8 b9 db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102487:	68 94 79 10 f0       	push   $0xf0107994
f010248c:	68 d5 72 10 f0       	push   $0xf01072d5
f0102491:	68 05 04 00 00       	push   $0x405
f0102496:	68 af 72 10 f0       	push   $0xf01072af
f010249b:	e8 a0 db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024a0:	68 f1 74 10 f0       	push   $0xf01074f1
f01024a5:	68 d5 72 10 f0       	push   $0xf01072d5
f01024aa:	68 06 04 00 00       	push   $0x406
f01024af:	68 af 72 10 f0       	push   $0xf01072af
f01024b4:	e8 87 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024b9:	68 a8 78 10 f0       	push   $0xf01078a8
f01024be:	68 d5 72 10 f0       	push   $0xf01072d5
f01024c3:	68 09 04 00 00       	push   $0x409
f01024c8:	68 af 72 10 f0       	push   $0xf01072af
f01024cd:	e8 6e db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01024d2:	68 c8 79 10 f0       	push   $0xf01079c8
f01024d7:	68 d5 72 10 f0       	push   $0xf01072d5
f01024dc:	68 0a 04 00 00       	push   $0x40a
f01024e1:	68 af 72 10 f0       	push   $0xf01072af
f01024e6:	e8 55 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024eb:	68 fc 79 10 f0       	push   $0xf01079fc
f01024f0:	68 d5 72 10 f0       	push   $0xf01072d5
f01024f5:	68 0b 04 00 00       	push   $0x40b
f01024fa:	68 af 72 10 f0       	push   $0xf01072af
f01024ff:	e8 3c db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102504:	68 34 7a 10 f0       	push   $0xf0107a34
f0102509:	68 d5 72 10 f0       	push   $0xf01072d5
f010250e:	68 0e 04 00 00       	push   $0x40e
f0102513:	68 af 72 10 f0       	push   $0xf01072af
f0102518:	e8 23 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010251d:	68 6c 7a 10 f0       	push   $0xf0107a6c
f0102522:	68 d5 72 10 f0       	push   $0xf01072d5
f0102527:	68 11 04 00 00       	push   $0x411
f010252c:	68 af 72 10 f0       	push   $0xf01072af
f0102531:	e8 0a db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102536:	68 fc 79 10 f0       	push   $0xf01079fc
f010253b:	68 d5 72 10 f0       	push   $0xf01072d5
f0102540:	68 12 04 00 00       	push   $0x412
f0102545:	68 af 72 10 f0       	push   $0xf01072af
f010254a:	e8 f1 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010254f:	68 a8 7a 10 f0       	push   $0xf0107aa8
f0102554:	68 d5 72 10 f0       	push   $0xf01072d5
f0102559:	68 15 04 00 00       	push   $0x415
f010255e:	68 af 72 10 f0       	push   $0xf01072af
f0102563:	e8 d8 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102568:	68 d4 7a 10 f0       	push   $0xf0107ad4
f010256d:	68 d5 72 10 f0       	push   $0xf01072d5
f0102572:	68 16 04 00 00       	push   $0x416
f0102577:	68 af 72 10 f0       	push   $0xf01072af
f010257c:	e8 bf da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102581:	68 07 75 10 f0       	push   $0xf0107507
f0102586:	68 d5 72 10 f0       	push   $0xf01072d5
f010258b:	68 18 04 00 00       	push   $0x418
f0102590:	68 af 72 10 f0       	push   $0xf01072af
f0102595:	e8 a6 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010259a:	68 18 75 10 f0       	push   $0xf0107518
f010259f:	68 d5 72 10 f0       	push   $0xf01072d5
f01025a4:	68 19 04 00 00       	push   $0x419
f01025a9:	68 af 72 10 f0       	push   $0xf01072af
f01025ae:	e8 8d da ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01025b3:	68 04 7b 10 f0       	push   $0xf0107b04
f01025b8:	68 d5 72 10 f0       	push   $0xf01072d5
f01025bd:	68 1c 04 00 00       	push   $0x41c
f01025c2:	68 af 72 10 f0       	push   $0xf01072af
f01025c7:	e8 74 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025cc:	68 28 7b 10 f0       	push   $0xf0107b28
f01025d1:	68 d5 72 10 f0       	push   $0xf01072d5
f01025d6:	68 20 04 00 00       	push   $0x420
f01025db:	68 af 72 10 f0       	push   $0xf01072af
f01025e0:	e8 5b da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025e5:	68 d4 7a 10 f0       	push   $0xf0107ad4
f01025ea:	68 d5 72 10 f0       	push   $0xf01072d5
f01025ef:	68 21 04 00 00       	push   $0x421
f01025f4:	68 af 72 10 f0       	push   $0xf01072af
f01025f9:	e8 42 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01025fe:	68 be 74 10 f0       	push   $0xf01074be
f0102603:	68 d5 72 10 f0       	push   $0xf01072d5
f0102608:	68 22 04 00 00       	push   $0x422
f010260d:	68 af 72 10 f0       	push   $0xf01072af
f0102612:	e8 29 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102617:	68 18 75 10 f0       	push   $0xf0107518
f010261c:	68 d5 72 10 f0       	push   $0xf01072d5
f0102621:	68 23 04 00 00       	push   $0x423
f0102626:	68 af 72 10 f0       	push   $0xf01072af
f010262b:	e8 10 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102630:	68 4c 7b 10 f0       	push   $0xf0107b4c
f0102635:	68 d5 72 10 f0       	push   $0xf01072d5
f010263a:	68 26 04 00 00       	push   $0x426
f010263f:	68 af 72 10 f0       	push   $0xf01072af
f0102644:	e8 f7 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102649:	68 29 75 10 f0       	push   $0xf0107529
f010264e:	68 d5 72 10 f0       	push   $0xf01072d5
f0102653:	68 27 04 00 00       	push   $0x427
f0102658:	68 af 72 10 f0       	push   $0xf01072af
f010265d:	e8 de d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102662:	68 35 75 10 f0       	push   $0xf0107535
f0102667:	68 d5 72 10 f0       	push   $0xf01072d5
f010266c:	68 28 04 00 00       	push   $0x428
f0102671:	68 af 72 10 f0       	push   $0xf01072af
f0102676:	e8 c5 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010267b:	68 28 7b 10 f0       	push   $0xf0107b28
f0102680:	68 d5 72 10 f0       	push   $0xf01072d5
f0102685:	68 2c 04 00 00       	push   $0x42c
f010268a:	68 af 72 10 f0       	push   $0xf01072af
f010268f:	e8 ac d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102694:	68 84 7b 10 f0       	push   $0xf0107b84
f0102699:	68 d5 72 10 f0       	push   $0xf01072d5
f010269e:	68 2d 04 00 00       	push   $0x42d
f01026a3:	68 af 72 10 f0       	push   $0xf01072af
f01026a8:	e8 93 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01026ad:	68 4a 75 10 f0       	push   $0xf010754a
f01026b2:	68 d5 72 10 f0       	push   $0xf01072d5
f01026b7:	68 2e 04 00 00       	push   $0x42e
f01026bc:	68 af 72 10 f0       	push   $0xf01072af
f01026c1:	e8 7a d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026c6:	68 18 75 10 f0       	push   $0xf0107518
f01026cb:	68 d5 72 10 f0       	push   $0xf01072d5
f01026d0:	68 2f 04 00 00       	push   $0x42f
f01026d5:	68 af 72 10 f0       	push   $0xf01072af
f01026da:	e8 61 d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01026df:	68 ac 7b 10 f0       	push   $0xf0107bac
f01026e4:	68 d5 72 10 f0       	push   $0xf01072d5
f01026e9:	68 32 04 00 00       	push   $0x432
f01026ee:	68 af 72 10 f0       	push   $0xf01072af
f01026f3:	e8 48 d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01026f8:	68 6c 74 10 f0       	push   $0xf010746c
f01026fd:	68 d5 72 10 f0       	push   $0xf01072d5
f0102702:	68 35 04 00 00       	push   $0x435
f0102707:	68 af 72 10 f0       	push   $0xf01072af
f010270c:	e8 2f d9 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102711:	68 50 78 10 f0       	push   $0xf0107850
f0102716:	68 d5 72 10 f0       	push   $0xf01072d5
f010271b:	68 38 04 00 00       	push   $0x438
f0102720:	68 af 72 10 f0       	push   $0xf01072af
f0102725:	e8 16 d9 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f010272a:	68 cf 74 10 f0       	push   $0xf01074cf
f010272f:	68 d5 72 10 f0       	push   $0xf01072d5
f0102734:	68 3a 04 00 00       	push   $0x43a
f0102739:	68 af 72 10 f0       	push   $0xf01072af
f010273e:	e8 fd d8 ff ff       	call   f0100040 <_panic>
f0102743:	57                   	push   %edi
f0102744:	68 64 6d 10 f0       	push   $0xf0106d64
f0102749:	68 41 04 00 00       	push   $0x441
f010274e:	68 af 72 10 f0       	push   $0xf01072af
f0102753:	e8 e8 d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102758:	68 5b 75 10 f0       	push   $0xf010755b
f010275d:	68 d5 72 10 f0       	push   $0xf01072d5
f0102762:	68 42 04 00 00       	push   $0x442
f0102767:	68 af 72 10 f0       	push   $0xf01072af
f010276c:	e8 cf d8 ff ff       	call   f0100040 <_panic>
f0102771:	51                   	push   %ecx
f0102772:	68 64 6d 10 f0       	push   $0xf0106d64
f0102777:	6a 5a                	push   $0x5a
f0102779:	68 bb 72 10 f0       	push   $0xf01072bb
f010277e:	e8 bd d8 ff ff       	call   f0100040 <_panic>
f0102783:	52                   	push   %edx
f0102784:	68 64 6d 10 f0       	push   $0xf0106d64
f0102789:	6a 5a                	push   $0x5a
f010278b:	68 bb 72 10 f0       	push   $0xf01072bb
f0102790:	e8 ab d8 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102795:	68 73 75 10 f0       	push   $0xf0107573
f010279a:	68 d5 72 10 f0       	push   $0xf01072d5
f010279f:	68 4c 04 00 00       	push   $0x44c
f01027a4:	68 af 72 10 f0       	push   $0xf01072af
f01027a9:	e8 92 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01027ae:	68 d0 7b 10 f0       	push   $0xf0107bd0
f01027b3:	68 d5 72 10 f0       	push   $0xf01072d5
f01027b8:	68 5c 04 00 00       	push   $0x45c
f01027bd:	68 af 72 10 f0       	push   $0xf01072af
f01027c2:	e8 79 d8 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01027c7:	68 f8 7b 10 f0       	push   $0xf0107bf8
f01027cc:	68 d5 72 10 f0       	push   $0xf01072d5
f01027d1:	68 5d 04 00 00       	push   $0x45d
f01027d6:	68 af 72 10 f0       	push   $0xf01072af
f01027db:	e8 60 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01027e0:	68 20 7c 10 f0       	push   $0xf0107c20
f01027e5:	68 d5 72 10 f0       	push   $0xf01072d5
f01027ea:	68 5f 04 00 00       	push   $0x45f
f01027ef:	68 af 72 10 f0       	push   $0xf01072af
f01027f4:	e8 47 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f01027f9:	68 8a 75 10 f0       	push   $0xf010758a
f01027fe:	68 d5 72 10 f0       	push   $0xf01072d5
f0102803:	68 61 04 00 00       	push   $0x461
f0102808:	68 af 72 10 f0       	push   $0xf01072af
f010280d:	e8 2e d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102812:	68 48 7c 10 f0       	push   $0xf0107c48
f0102817:	68 d5 72 10 f0       	push   $0xf01072d5
f010281c:	68 63 04 00 00       	push   $0x463
f0102821:	68 af 72 10 f0       	push   $0xf01072af
f0102826:	e8 15 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010282b:	68 6c 7c 10 f0       	push   $0xf0107c6c
f0102830:	68 d5 72 10 f0       	push   $0xf01072d5
f0102835:	68 64 04 00 00       	push   $0x464
f010283a:	68 af 72 10 f0       	push   $0xf01072af
f010283f:	e8 fc d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102844:	68 9c 7c 10 f0       	push   $0xf0107c9c
f0102849:	68 d5 72 10 f0       	push   $0xf01072d5
f010284e:	68 65 04 00 00       	push   $0x465
f0102853:	68 af 72 10 f0       	push   $0xf01072af
f0102858:	e8 e3 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010285d:	68 c0 7c 10 f0       	push   $0xf0107cc0
f0102862:	68 d5 72 10 f0       	push   $0xf01072d5
f0102867:	68 66 04 00 00       	push   $0x466
f010286c:	68 af 72 10 f0       	push   $0xf01072af
f0102871:	e8 ca d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102876:	68 ec 7c 10 f0       	push   $0xf0107cec
f010287b:	68 d5 72 10 f0       	push   $0xf01072d5
f0102880:	68 68 04 00 00       	push   $0x468
f0102885:	68 af 72 10 f0       	push   $0xf01072af
f010288a:	e8 b1 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010288f:	68 30 7d 10 f0       	push   $0xf0107d30
f0102894:	68 d5 72 10 f0       	push   $0xf01072d5
f0102899:	68 69 04 00 00       	push   $0x469
f010289e:	68 af 72 10 f0       	push   $0xf01072af
f01028a3:	e8 98 d7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028a8:	50                   	push   %eax
f01028a9:	68 88 6d 10 f0       	push   $0xf0106d88
f01028ae:	68 ce 00 00 00       	push   $0xce
f01028b3:	68 af 72 10 f0       	push   $0xf01072af
f01028b8:	e8 83 d7 ff ff       	call   f0100040 <_panic>
f01028bd:	50                   	push   %eax
f01028be:	68 88 6d 10 f0       	push   $0xf0106d88
f01028c3:	68 d8 00 00 00       	push   $0xd8
f01028c8:	68 af 72 10 f0       	push   $0xf01072af
f01028cd:	e8 6e d7 ff ff       	call   f0100040 <_panic>
f01028d2:	50                   	push   %eax
f01028d3:	68 88 6d 10 f0       	push   $0xf0106d88
f01028d8:	68 e6 00 00 00       	push   $0xe6
f01028dd:	68 af 72 10 f0       	push   $0xf01072af
f01028e2:	e8 59 d7 ff ff       	call   f0100040 <_panic>
f01028e7:	53                   	push   %ebx
f01028e8:	68 88 6d 10 f0       	push   $0xf0106d88
f01028ed:	68 2e 01 00 00       	push   $0x12e
f01028f2:	68 af 72 10 f0       	push   $0xf01072af
f01028f7:	e8 44 d7 ff ff       	call   f0100040 <_panic>
f01028fc:	56                   	push   %esi
f01028fd:	68 88 6d 10 f0       	push   $0xf0106d88
f0102902:	68 81 03 00 00       	push   $0x381
f0102907:	68 af 72 10 f0       	push   $0xf01072af
f010290c:	e8 2f d7 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102911:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102917:	39 df                	cmp    %ebx,%edi
f0102919:	76 39                	jbe    f0102954 <mem_init+0x161b>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010291b:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102921:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102924:	e8 2f e2 ff ff       	call   f0100b58 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102929:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010292f:	76 cb                	jbe    f01028fc <mem_init+0x15c3>
f0102931:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102934:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102937:	39 d0                	cmp    %edx,%eax
f0102939:	74 d6                	je     f0102911 <mem_init+0x15d8>
f010293b:	68 64 7d 10 f0       	push   $0xf0107d64
f0102940:	68 d5 72 10 f0       	push   $0xf01072d5
f0102945:	68 81 03 00 00       	push   $0x381
f010294a:	68 af 72 10 f0       	push   $0xf01072af
f010294f:	e8 ec d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102954:	8b 35 70 62 2b f0    	mov    0xf02b6270,%esi
f010295a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010295f:	8d 86 00 00 40 21    	lea    0x21400000(%esi),%eax
f0102965:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102968:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010296b:	89 da                	mov    %ebx,%edx
f010296d:	89 f8                	mov    %edi,%eax
f010296f:	e8 e4 e1 ff ff       	call   f0100b58 <check_va2pa>
f0102974:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010297a:	76 46                	jbe    f01029c2 <mem_init+0x1689>
f010297c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010297f:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102982:	39 d0                	cmp    %edx,%eax
f0102984:	75 51                	jne    f01029d7 <mem_init+0x169e>
	for (i = 0; i < n; i += PGSIZE)
f0102986:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010298c:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102992:	75 d7                	jne    f010296b <mem_init+0x1632>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102994:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102997:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010299a:	c1 e6 0c             	shl    $0xc,%esi
f010299d:	89 fb                	mov    %edi,%ebx
f010299f:	89 7d cc             	mov    %edi,-0x34(%ebp)
f01029a2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01029a5:	39 f3                	cmp    %esi,%ebx
f01029a7:	73 60                	jae    f0102a09 <mem_init+0x16d0>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029a9:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01029af:	89 f8                	mov    %edi,%eax
f01029b1:	e8 a2 e1 ff ff       	call   f0100b58 <check_va2pa>
f01029b6:	39 c3                	cmp    %eax,%ebx
f01029b8:	75 36                	jne    f01029f0 <mem_init+0x16b7>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029ba:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029c0:	eb e3                	jmp    f01029a5 <mem_init+0x166c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029c2:	56                   	push   %esi
f01029c3:	68 88 6d 10 f0       	push   $0xf0106d88
f01029c8:	68 86 03 00 00       	push   $0x386
f01029cd:	68 af 72 10 f0       	push   $0xf01072af
f01029d2:	e8 69 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029d7:	68 98 7d 10 f0       	push   $0xf0107d98
f01029dc:	68 d5 72 10 f0       	push   $0xf01072d5
f01029e1:	68 86 03 00 00       	push   $0x386
f01029e6:	68 af 72 10 f0       	push   $0xf01072af
f01029eb:	e8 50 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029f0:	68 cc 7d 10 f0       	push   $0xf0107dcc
f01029f5:	68 d5 72 10 f0       	push   $0xf01072d5
f01029fa:	68 8a 03 00 00       	push   $0x38a
f01029ff:	68 af 72 10 f0       	push   $0xf01072af
f0102a04:	e8 37 d6 ff ff       	call   f0100040 <_panic>
f0102a09:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102a0c:	c7 45 c0 00 70 2c 00 	movl   $0x2c7000,-0x40(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a13:	c7 45 c4 00 00 00 f0 	movl   $0xf0000000,-0x3c(%ebp)
f0102a1a:	c7 45 c8 00 80 ff ef 	movl   $0xefff8000,-0x38(%ebp)
f0102a21:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0102a24:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102a27:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0102a2a:	8d b3 00 80 ff ff    	lea    -0x8000(%ebx),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a30:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102a33:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0102a36:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0102a39:	05 00 80 ff 0f       	add    $0xfff8000,%eax
f0102a3e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102a41:	89 75 bc             	mov    %esi,-0x44(%ebp)
f0102a44:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102a47:	89 da                	mov    %ebx,%edx
f0102a49:	89 f8                	mov    %edi,%eax
f0102a4b:	e8 08 e1 ff ff       	call   f0100b58 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102a50:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102a57:	76 67                	jbe    f0102ac0 <mem_init+0x1787>
f0102a59:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102a5c:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102a5f:	39 d0                	cmp    %edx,%eax
f0102a61:	75 74                	jne    f0102ad7 <mem_init+0x179e>
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a63:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a69:	39 f3                	cmp    %esi,%ebx
f0102a6b:	75 da                	jne    f0102a47 <mem_init+0x170e>
f0102a6d:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0102a70:	8b 5d c8             	mov    -0x38(%ebp),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a73:	89 f2                	mov    %esi,%edx
f0102a75:	89 f8                	mov    %edi,%eax
f0102a77:	e8 dc e0 ff ff       	call   f0100b58 <check_va2pa>
f0102a7c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a7f:	75 6f                	jne    f0102af0 <mem_init+0x17b7>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a81:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102a87:	39 de                	cmp    %ebx,%esi
f0102a89:	75 e8                	jne    f0102a73 <mem_init+0x173a>
	for (n = 0; n < NCPU; n++) {
f0102a8b:	89 d8                	mov    %ebx,%eax
f0102a8d:	2d 00 00 01 00       	sub    $0x10000,%eax
f0102a92:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102a95:	81 6d c4 00 00 01 00 	subl   $0x10000,-0x3c(%ebp)
f0102a9c:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102aa3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102aa6:	81 45 c0 00 80 01 00 	addl   $0x18000,-0x40(%ebp)
f0102aad:	3d 00 70 2f f0       	cmp    $0xf02f7000,%eax
f0102ab2:	0f 85 6f ff ff ff    	jne    f0102a27 <mem_init+0x16ee>
f0102ab8:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0102abb:	e9 84 00 00 00       	jmp    f0102b44 <mem_init+0x180b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ac0:	ff 75 b8             	push   -0x48(%ebp)
f0102ac3:	68 88 6d 10 f0       	push   $0xf0106d88
f0102ac8:	68 92 03 00 00       	push   $0x392
f0102acd:	68 af 72 10 f0       	push   $0xf01072af
f0102ad2:	e8 69 d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102ad7:	68 f4 7d 10 f0       	push   $0xf0107df4
f0102adc:	68 d5 72 10 f0       	push   $0xf01072d5
f0102ae1:	68 91 03 00 00       	push   $0x391
f0102ae6:	68 af 72 10 f0       	push   $0xf01072af
f0102aeb:	e8 50 d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102af0:	68 3c 7e 10 f0       	push   $0xf0107e3c
f0102af5:	68 d5 72 10 f0       	push   $0xf01072d5
f0102afa:	68 94 03 00 00       	push   $0x394
f0102aff:	68 af 72 10 f0       	push   $0xf01072af
f0102b04:	e8 37 d5 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102b09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b0c:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102b10:	75 4e                	jne    f0102b60 <mem_init+0x1827>
f0102b12:	68 b5 75 10 f0       	push   $0xf01075b5
f0102b17:	68 d5 72 10 f0       	push   $0xf01072d5
f0102b1c:	68 9f 03 00 00       	push   $0x39f
f0102b21:	68 af 72 10 f0       	push   $0xf01072af
f0102b26:	e8 15 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b2b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b2e:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f0102b31:	a8 01                	test   $0x1,%al
f0102b33:	74 30                	je     f0102b65 <mem_init+0x182c>
				assert(pgdir[i] & PTE_W);
f0102b35:	a8 02                	test   $0x2,%al
f0102b37:	74 45                	je     f0102b7e <mem_init+0x1845>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b39:	83 c7 01             	add    $0x1,%edi
f0102b3c:	81 ff 00 04 00 00    	cmp    $0x400,%edi
f0102b42:	74 6c                	je     f0102bb0 <mem_init+0x1877>
		switch (i) {
f0102b44:	8d 87 45 fc ff ff    	lea    -0x3bb(%edi),%eax
f0102b4a:	83 f8 04             	cmp    $0x4,%eax
f0102b4d:	76 ba                	jbe    f0102b09 <mem_init+0x17d0>
			if (i >= PDX(KERNBASE)) {
f0102b4f:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102b55:	77 d4                	ja     f0102b2b <mem_init+0x17f2>
				assert(pgdir[i] == 0);
f0102b57:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b5a:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f0102b5e:	75 37                	jne    f0102b97 <mem_init+0x185e>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b60:	83 c7 01             	add    $0x1,%edi
f0102b63:	eb df                	jmp    f0102b44 <mem_init+0x180b>
				assert(pgdir[i] & PTE_P);
f0102b65:	68 b5 75 10 f0       	push   $0xf01075b5
f0102b6a:	68 d5 72 10 f0       	push   $0xf01072d5
f0102b6f:	68 a3 03 00 00       	push   $0x3a3
f0102b74:	68 af 72 10 f0       	push   $0xf01072af
f0102b79:	e8 c2 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b7e:	68 c6 75 10 f0       	push   $0xf01075c6
f0102b83:	68 d5 72 10 f0       	push   $0xf01072d5
f0102b88:	68 a4 03 00 00       	push   $0x3a4
f0102b8d:	68 af 72 10 f0       	push   $0xf01072af
f0102b92:	e8 a9 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102b97:	68 d7 75 10 f0       	push   $0xf01075d7
f0102b9c:	68 d5 72 10 f0       	push   $0xf01072d5
f0102ba1:	68 a6 03 00 00       	push   $0x3a6
f0102ba6:	68 af 72 10 f0       	push   $0xf01072af
f0102bab:	e8 90 d4 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102bb0:	83 ec 0c             	sub    $0xc,%esp
f0102bb3:	68 60 7e 10 f0       	push   $0xf0107e60
f0102bb8:	e8 f8 0d 00 00       	call   f01039b5 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102bbd:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102bc2:	83 c4 10             	add    $0x10,%esp
f0102bc5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bca:	0f 86 03 02 00 00    	jbe    f0102dd3 <mem_init+0x1a9a>
	return (physaddr_t)kva - KERNBASE;
f0102bd0:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f0102bd5:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102bd8:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bdd:	e8 d9 df ff ff       	call   f0100bbb <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102be2:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102be5:	83 e0 f3             	and    $0xfffffff3,%eax
f0102be8:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102bed:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102bf0:	83 ec 0c             	sub    $0xc,%esp
f0102bf3:	6a 00                	push   $0x0
f0102bf5:	e8 68 e3 ff ff       	call   f0100f62 <page_alloc>
f0102bfa:	89 c3                	mov    %eax,%ebx
f0102bfc:	83 c4 10             	add    $0x10,%esp
f0102bff:	85 c0                	test   %eax,%eax
f0102c01:	0f 84 e1 01 00 00    	je     f0102de8 <mem_init+0x1aaf>
	assert((pp1 = page_alloc(0)));
f0102c07:	83 ec 0c             	sub    $0xc,%esp
f0102c0a:	6a 00                	push   $0x0
f0102c0c:	e8 51 e3 ff ff       	call   f0100f62 <page_alloc>
f0102c11:	89 c7                	mov    %eax,%edi
f0102c13:	83 c4 10             	add    $0x10,%esp
f0102c16:	85 c0                	test   %eax,%eax
f0102c18:	0f 84 e3 01 00 00    	je     f0102e01 <mem_init+0x1ac8>
	assert((pp2 = page_alloc(0)));
f0102c1e:	83 ec 0c             	sub    $0xc,%esp
f0102c21:	6a 00                	push   $0x0
f0102c23:	e8 3a e3 ff ff       	call   f0100f62 <page_alloc>
f0102c28:	89 c6                	mov    %eax,%esi
f0102c2a:	83 c4 10             	add    $0x10,%esp
f0102c2d:	85 c0                	test   %eax,%eax
f0102c2f:	0f 84 e5 01 00 00    	je     f0102e1a <mem_init+0x1ae1>
	page_free(pp0);
f0102c35:	83 ec 0c             	sub    $0xc,%esp
f0102c38:	53                   	push   %ebx
f0102c39:	e8 99 e3 ff ff       	call   f0100fd7 <page_free>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102c3e:	89 f8                	mov    %edi,%eax
f0102c40:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f0102c46:	c1 f8 03             	sar    $0x3,%eax
f0102c49:	89 c2                	mov    %eax,%edx
f0102c4b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c4e:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c53:	83 c4 10             	add    $0x10,%esp
f0102c56:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f0102c5c:	0f 83 d1 01 00 00    	jae    f0102e33 <mem_init+0x1afa>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c62:	83 ec 04             	sub    $0x4,%esp
f0102c65:	68 00 10 00 00       	push   $0x1000
f0102c6a:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c6c:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c72:	52                   	push   %edx
f0102c73:	e8 f5 2b 00 00       	call   f010586d <memset>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102c78:	89 f0                	mov    %esi,%eax
f0102c7a:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f0102c80:	c1 f8 03             	sar    $0x3,%eax
f0102c83:	89 c2                	mov    %eax,%edx
f0102c85:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c88:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c8d:	83 c4 10             	add    $0x10,%esp
f0102c90:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f0102c96:	0f 83 a9 01 00 00    	jae    f0102e45 <mem_init+0x1b0c>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c9c:	83 ec 04             	sub    $0x4,%esp
f0102c9f:	68 00 10 00 00       	push   $0x1000
f0102ca4:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102ca6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102cac:	52                   	push   %edx
f0102cad:	e8 bb 2b 00 00       	call   f010586d <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102cb2:	6a 02                	push   $0x2
f0102cb4:	68 00 10 00 00       	push   $0x1000
f0102cb9:	57                   	push   %edi
f0102cba:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0102cc0:	e8 ab e5 ff ff       	call   f0101270 <page_insert>
	assert(pp1->pp_ref == 1);
f0102cc5:	83 c4 20             	add    $0x20,%esp
f0102cc8:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ccd:	0f 85 84 01 00 00    	jne    f0102e57 <mem_init+0x1b1e>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cd3:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cda:	01 01 01 
f0102cdd:	0f 85 8d 01 00 00    	jne    f0102e70 <mem_init+0x1b37>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ce3:	6a 02                	push   $0x2
f0102ce5:	68 00 10 00 00       	push   $0x1000
f0102cea:	56                   	push   %esi
f0102ceb:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0102cf1:	e8 7a e5 ff ff       	call   f0101270 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102cf6:	83 c4 10             	add    $0x10,%esp
f0102cf9:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d00:	02 02 02 
f0102d03:	0f 85 80 01 00 00    	jne    f0102e89 <mem_init+0x1b50>
	assert(pp2->pp_ref == 1);
f0102d09:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d0e:	0f 85 8e 01 00 00    	jne    f0102ea2 <mem_init+0x1b69>
	assert(pp1->pp_ref == 0);
f0102d14:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d19:	0f 85 9c 01 00 00    	jne    f0102ebb <mem_init+0x1b82>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d1f:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d26:	03 03 03 
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102d29:	89 f0                	mov    %esi,%eax
f0102d2b:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f0102d31:	c1 f8 03             	sar    $0x3,%eax
f0102d34:	89 c2                	mov    %eax,%edx
f0102d36:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d39:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d3e:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f0102d44:	0f 83 8a 01 00 00    	jae    f0102ed4 <mem_init+0x1b9b>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d4a:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102d51:	03 03 03 
f0102d54:	0f 85 8c 01 00 00    	jne    f0102ee6 <mem_init+0x1bad>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d5a:	83 ec 08             	sub    $0x8,%esp
f0102d5d:	68 00 10 00 00       	push   $0x1000
f0102d62:	ff 35 5c 62 2b f0    	push   0xf02b625c
f0102d68:	e8 bd e4 ff ff       	call   f010122a <page_remove>
	assert(pp2->pp_ref == 0);
f0102d6d:	83 c4 10             	add    $0x10,%esp
f0102d70:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d75:	0f 85 84 01 00 00    	jne    f0102eff <mem_init+0x1bc6>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d7b:	8b 0d 5c 62 2b f0    	mov    0xf02b625c,%ecx
f0102d81:	8b 11                	mov    (%ecx),%edx
f0102d83:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102d89:	89 d8                	mov    %ebx,%eax
f0102d8b:	2b 05 58 62 2b f0    	sub    0xf02b6258,%eax
f0102d91:	c1 f8 03             	sar    $0x3,%eax
f0102d94:	c1 e0 0c             	shl    $0xc,%eax
f0102d97:	39 c2                	cmp    %eax,%edx
f0102d99:	0f 85 79 01 00 00    	jne    f0102f18 <mem_init+0x1bdf>
	kern_pgdir[0] = 0;
f0102d9f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102da5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102daa:	0f 85 81 01 00 00    	jne    f0102f31 <mem_init+0x1bf8>
	pp0->pp_ref = 0;
f0102db0:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102db6:	83 ec 0c             	sub    $0xc,%esp
f0102db9:	53                   	push   %ebx
f0102dba:	e8 18 e2 ff ff       	call   f0100fd7 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102dbf:	c7 04 24 f4 7e 10 f0 	movl   $0xf0107ef4,(%esp)
f0102dc6:	e8 ea 0b 00 00       	call   f01039b5 <cprintf>
}
f0102dcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dce:	5b                   	pop    %ebx
f0102dcf:	5e                   	pop    %esi
f0102dd0:	5f                   	pop    %edi
f0102dd1:	5d                   	pop    %ebp
f0102dd2:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dd3:	50                   	push   %eax
f0102dd4:	68 88 6d 10 f0       	push   $0xf0106d88
f0102dd9:	68 01 01 00 00       	push   $0x101
f0102dde:	68 af 72 10 f0       	push   $0xf01072af
f0102de3:	e8 58 d2 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102de8:	68 c1 73 10 f0       	push   $0xf01073c1
f0102ded:	68 d5 72 10 f0       	push   $0xf01072d5
f0102df2:	68 7e 04 00 00       	push   $0x47e
f0102df7:	68 af 72 10 f0       	push   $0xf01072af
f0102dfc:	e8 3f d2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e01:	68 d7 73 10 f0       	push   $0xf01073d7
f0102e06:	68 d5 72 10 f0       	push   $0xf01072d5
f0102e0b:	68 7f 04 00 00       	push   $0x47f
f0102e10:	68 af 72 10 f0       	push   $0xf01072af
f0102e15:	e8 26 d2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e1a:	68 ed 73 10 f0       	push   $0xf01073ed
f0102e1f:	68 d5 72 10 f0       	push   $0xf01072d5
f0102e24:	68 80 04 00 00       	push   $0x480
f0102e29:	68 af 72 10 f0       	push   $0xf01072af
f0102e2e:	e8 0d d2 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e33:	52                   	push   %edx
f0102e34:	68 64 6d 10 f0       	push   $0xf0106d64
f0102e39:	6a 5a                	push   $0x5a
f0102e3b:	68 bb 72 10 f0       	push   $0xf01072bb
f0102e40:	e8 fb d1 ff ff       	call   f0100040 <_panic>
f0102e45:	52                   	push   %edx
f0102e46:	68 64 6d 10 f0       	push   $0xf0106d64
f0102e4b:	6a 5a                	push   $0x5a
f0102e4d:	68 bb 72 10 f0       	push   $0xf01072bb
f0102e52:	e8 e9 d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102e57:	68 be 74 10 f0       	push   $0xf01074be
f0102e5c:	68 d5 72 10 f0       	push   $0xf01072d5
f0102e61:	68 85 04 00 00       	push   $0x485
f0102e66:	68 af 72 10 f0       	push   $0xf01072af
f0102e6b:	e8 d0 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e70:	68 80 7e 10 f0       	push   $0xf0107e80
f0102e75:	68 d5 72 10 f0       	push   $0xf01072d5
f0102e7a:	68 86 04 00 00       	push   $0x486
f0102e7f:	68 af 72 10 f0       	push   $0xf01072af
f0102e84:	e8 b7 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e89:	68 a4 7e 10 f0       	push   $0xf0107ea4
f0102e8e:	68 d5 72 10 f0       	push   $0xf01072d5
f0102e93:	68 88 04 00 00       	push   $0x488
f0102e98:	68 af 72 10 f0       	push   $0xf01072af
f0102e9d:	e8 9e d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102ea2:	68 e0 74 10 f0       	push   $0xf01074e0
f0102ea7:	68 d5 72 10 f0       	push   $0xf01072d5
f0102eac:	68 89 04 00 00       	push   $0x489
f0102eb1:	68 af 72 10 f0       	push   $0xf01072af
f0102eb6:	e8 85 d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102ebb:	68 4a 75 10 f0       	push   $0xf010754a
f0102ec0:	68 d5 72 10 f0       	push   $0xf01072d5
f0102ec5:	68 8a 04 00 00       	push   $0x48a
f0102eca:	68 af 72 10 f0       	push   $0xf01072af
f0102ecf:	e8 6c d1 ff ff       	call   f0100040 <_panic>
f0102ed4:	52                   	push   %edx
f0102ed5:	68 64 6d 10 f0       	push   $0xf0106d64
f0102eda:	6a 5a                	push   $0x5a
f0102edc:	68 bb 72 10 f0       	push   $0xf01072bb
f0102ee1:	e8 5a d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ee6:	68 c8 7e 10 f0       	push   $0xf0107ec8
f0102eeb:	68 d5 72 10 f0       	push   $0xf01072d5
f0102ef0:	68 8c 04 00 00       	push   $0x48c
f0102ef5:	68 af 72 10 f0       	push   $0xf01072af
f0102efa:	e8 41 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102eff:	68 18 75 10 f0       	push   $0xf0107518
f0102f04:	68 d5 72 10 f0       	push   $0xf01072d5
f0102f09:	68 8e 04 00 00       	push   $0x48e
f0102f0e:	68 af 72 10 f0       	push   $0xf01072af
f0102f13:	e8 28 d1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f18:	68 50 78 10 f0       	push   $0xf0107850
f0102f1d:	68 d5 72 10 f0       	push   $0xf01072d5
f0102f22:	68 91 04 00 00       	push   $0x491
f0102f27:	68 af 72 10 f0       	push   $0xf01072af
f0102f2c:	e8 0f d1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102f31:	68 cf 74 10 f0       	push   $0xf01074cf
f0102f36:	68 d5 72 10 f0       	push   $0xf01072d5
f0102f3b:	68 93 04 00 00       	push   $0x493
f0102f40:	68 af 72 10 f0       	push   $0xf01072af
f0102f45:	e8 f6 d0 ff ff       	call   f0100040 <_panic>

f0102f4a <user_mem_check>:
{
f0102f4a:	55                   	push   %ebp
f0102f4b:	89 e5                	mov    %esp,%ebp
f0102f4d:	57                   	push   %edi
f0102f4e:	56                   	push   %esi
f0102f4f:	53                   	push   %ebx
f0102f50:	83 ec 1c             	sub    $0x1c,%esp
f0102f53:	8b 75 14             	mov    0x14(%ebp),%esi
	char * start = ROUNDDOWN((char *)va, PGSIZE);
f0102f56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102f59:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f5f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	char * end = ROUNDUP((char *)(va + len), PGSIZE);
f0102f62:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102f65:	03 7d 10             	add    0x10(%ebp),%edi
f0102f68:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0102f6e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for(;start<end;start+=PGSIZE){
f0102f74:	eb 15                	jmp    f0102f8b <user_mem_check+0x41>
		    		user_mem_check_addr = (uintptr_t)va;
f0102f76:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f79:	a3 68 62 2b f0       	mov    %eax,0xf02b6268
	      		return -E_FAULT;
f0102f7e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f83:	eb 44                	jmp    f0102fc9 <user_mem_check+0x7f>
	for(;start<end;start+=PGSIZE){
f0102f85:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f8b:	39 fb                	cmp    %edi,%ebx
f0102f8d:	73 42                	jae    f0102fd1 <user_mem_check+0x87>
		pte_t * cur= pgdir_walk(env->env_pgdir, (void *)start, 0);
f0102f8f:	83 ec 04             	sub    $0x4,%esp
f0102f92:	6a 00                	push   $0x0
f0102f94:	53                   	push   %ebx
f0102f95:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f98:	ff 70 60             	push   0x60(%eax)
f0102f9b:	e8 b6 e0 ff ff       	call   f0101056 <pgdir_walk>
f0102fa0:	89 da                	mov    %ebx,%edx
		if( (uint32_t) start >= ULIM || cur == NULL || ( (uint32_t)(*cur) & perm) != perm /*如果pte项的user位为0*/) {
f0102fa2:	83 c4 10             	add    $0x10,%esp
f0102fa5:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102fab:	77 0c                	ja     f0102fb9 <user_mem_check+0x6f>
f0102fad:	85 c0                	test   %eax,%eax
f0102faf:	74 08                	je     f0102fb9 <user_mem_check+0x6f>
f0102fb1:	89 f1                	mov    %esi,%ecx
f0102fb3:	23 08                	and    (%eax),%ecx
f0102fb5:	39 ce                	cmp    %ecx,%esi
f0102fb7:	74 cc                	je     f0102f85 <user_mem_check+0x3b>
			if(start == ROUNDDOWN((char *)va, PGSIZE)) {
f0102fb9:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102fbc:	74 b8                	je     f0102f76 <user_mem_check+0x2c>
	      			user_mem_check_addr = (uintptr_t)start;
f0102fbe:	89 15 68 62 2b f0    	mov    %edx,0xf02b6268
	      		return -E_FAULT;
f0102fc4:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102fc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fcc:	5b                   	pop    %ebx
f0102fcd:	5e                   	pop    %esi
f0102fce:	5f                   	pop    %edi
f0102fcf:	5d                   	pop    %ebp
f0102fd0:	c3                   	ret    
	return 0;
f0102fd1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fd6:	eb f1                	jmp    f0102fc9 <user_mem_check+0x7f>

f0102fd8 <user_mem_assert>:
{
f0102fd8:	55                   	push   %ebp
f0102fd9:	89 e5                	mov    %esp,%ebp
f0102fdb:	53                   	push   %ebx
f0102fdc:	83 ec 04             	sub    $0x4,%esp
f0102fdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102fe2:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fe5:	83 c8 04             	or     $0x4,%eax
f0102fe8:	50                   	push   %eax
f0102fe9:	ff 75 10             	push   0x10(%ebp)
f0102fec:	ff 75 0c             	push   0xc(%ebp)
f0102fef:	53                   	push   %ebx
f0102ff0:	e8 55 ff ff ff       	call   f0102f4a <user_mem_check>
f0102ff5:	83 c4 10             	add    $0x10,%esp
f0102ff8:	85 c0                	test   %eax,%eax
f0102ffa:	78 05                	js     f0103001 <user_mem_assert+0x29>
}
f0102ffc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102fff:	c9                   	leave  
f0103000:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0103001:	83 ec 04             	sub    $0x4,%esp
f0103004:	ff 35 68 62 2b f0    	push   0xf02b6268
f010300a:	ff 73 48             	push   0x48(%ebx)
f010300d:	68 20 7f 10 f0       	push   $0xf0107f20
f0103012:	e8 9e 09 00 00       	call   f01039b5 <cprintf>
		env_destroy(env);	// may not return
f0103017:	89 1c 24             	mov    %ebx,(%esp)
f010301a:	e8 4a 06 00 00       	call   f0103669 <env_destroy>
f010301f:	83 c4 10             	add    $0x10,%esp
}
f0103022:	eb d8                	jmp    f0102ffc <user_mem_assert+0x24>

f0103024 <region_alloc>:
// Panic if any allocation attempt fails.
//
//为环境分配和映射物理内存
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103024:	55                   	push   %ebp
f0103025:	89 e5                	mov    %esp,%ebp
f0103027:	57                   	push   %edi
f0103028:	56                   	push   %esi
f0103029:	53                   	push   %ebx
f010302a:	83 ec 0c             	sub    $0xc,%esp
f010302d:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	//先申请物理内存，再调用page_insert（）
	void* start = (void *)ROUNDDOWN((uint32_t)va, PGSIZE);     
f010302f:	89 d3                	mov    %edx,%ebx
f0103031:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
f0103037:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f010303e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	struct PageInfo *p = NULL;
	int r;
	for(void* i=start; i<end; i+=PGSIZE){
f0103044:	39 f3                	cmp    %esi,%ebx
f0103046:	73 5a                	jae    f01030a2 <region_alloc+0x7e>
		p = page_alloc(0);
f0103048:	83 ec 0c             	sub    $0xc,%esp
f010304b:	6a 00                	push   $0x0
f010304d:	e8 10 df ff ff       	call   f0100f62 <page_alloc>
		if(p == NULL) panic("region alloc - page alloc failed.");
f0103052:	83 c4 10             	add    $0x10,%esp
f0103055:	85 c0                	test   %eax,%eax
f0103057:	74 1b                	je     f0103074 <region_alloc+0x50>
		
	 	r = page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);
f0103059:	6a 06                	push   $0x6
f010305b:	53                   	push   %ebx
f010305c:	50                   	push   %eax
f010305d:	ff 77 60             	push   0x60(%edi)
f0103060:	e8 0b e2 ff ff       	call   f0101270 <page_insert>
	 	if(r != 0)  panic("region alloc - page insert error - page table couldn't be allocated");
f0103065:	83 c4 10             	add    $0x10,%esp
f0103068:	85 c0                	test   %eax,%eax
f010306a:	75 1f                	jne    f010308b <region_alloc+0x67>
	for(void* i=start; i<end; i+=PGSIZE){
f010306c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103072:	eb d0                	jmp    f0103044 <region_alloc+0x20>
		if(p == NULL) panic("region alloc - page alloc failed.");
f0103074:	83 ec 04             	sub    $0x4,%esp
f0103077:	68 58 7f 10 f0       	push   $0xf0107f58
f010307c:	68 38 01 00 00       	push   $0x138
f0103081:	68 46 80 10 f0       	push   $0xf0108046
f0103086:	e8 b5 cf ff ff       	call   f0100040 <_panic>
	 	if(r != 0)  panic("region alloc - page insert error - page table couldn't be allocated");
f010308b:	83 ec 04             	sub    $0x4,%esp
f010308e:	68 7c 7f 10 f0       	push   $0xf0107f7c
f0103093:	68 3b 01 00 00       	push   $0x13b
f0103098:	68 46 80 10 f0       	push   $0xf0108046
f010309d:	e8 9e cf ff ff       	call   f0100040 <_panic>
	}
}
f01030a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030a5:	5b                   	pop    %ebx
f01030a6:	5e                   	pop    %esi
f01030a7:	5f                   	pop    %edi
f01030a8:	5d                   	pop    %ebp
f01030a9:	c3                   	ret    

f01030aa <envid2env>:
{
f01030aa:	55                   	push   %ebp
f01030ab:	89 e5                	mov    %esp,%ebp
f01030ad:	56                   	push   %esi
f01030ae:	53                   	push   %ebx
f01030af:	8b 75 08             	mov    0x8(%ebp),%esi
f01030b2:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f01030b5:	85 f6                	test   %esi,%esi
f01030b7:	74 2e                	je     f01030e7 <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f01030b9:	89 f3                	mov    %esi,%ebx
f01030bb:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01030c1:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01030c4:	03 1d 70 62 2b f0    	add    0xf02b6270,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01030ca:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01030ce:	74 5b                	je     f010312b <envid2env+0x81>
f01030d0:	39 73 48             	cmp    %esi,0x48(%ebx)
f01030d3:	75 62                	jne    f0103137 <envid2env+0x8d>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01030d5:	84 c0                	test   %al,%al
f01030d7:	75 20                	jne    f01030f9 <envid2env+0x4f>
	return 0;
f01030d9:	b8 00 00 00 00       	mov    $0x0,%eax
		*env_store = curenv;
f01030de:	8b 55 0c             	mov    0xc(%ebp),%edx
f01030e1:	89 1a                	mov    %ebx,(%edx)
}
f01030e3:	5b                   	pop    %ebx
f01030e4:	5e                   	pop    %esi
f01030e5:	5d                   	pop    %ebp
f01030e6:	c3                   	ret    
		*env_store = curenv;
f01030e7:	e8 78 2d 00 00       	call   f0105e64 <cpunum>
f01030ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01030ef:	8b 98 28 70 2f f0    	mov    -0xfd08fd8(%eax),%ebx
		return 0;
f01030f5:	89 f0                	mov    %esi,%eax
f01030f7:	eb e5                	jmp    f01030de <envid2env+0x34>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01030f9:	e8 66 2d 00 00       	call   f0105e64 <cpunum>
f01030fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103101:	39 98 28 70 2f f0    	cmp    %ebx,-0xfd08fd8(%eax)
f0103107:	74 d0                	je     f01030d9 <envid2env+0x2f>
f0103109:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010310c:	e8 53 2d 00 00       	call   f0105e64 <cpunum>
f0103111:	6b c0 74             	imul   $0x74,%eax,%eax
f0103114:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f010311a:	3b 70 48             	cmp    0x48(%eax),%esi
f010311d:	74 ba                	je     f01030d9 <envid2env+0x2f>
f010311f:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f0103124:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103129:	eb b3                	jmp    f01030de <envid2env+0x34>
f010312b:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f0103130:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103135:	eb a7                	jmp    f01030de <envid2env+0x34>
f0103137:	bb 00 00 00 00       	mov    $0x0,%ebx
f010313c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103141:	eb 9b                	jmp    f01030de <envid2env+0x34>

f0103143 <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f0103143:	b8 20 83 12 f0       	mov    $0xf0128320,%eax
f0103148:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f010314b:	b8 23 00 00 00       	mov    $0x23,%eax
f0103150:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103152:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103154:	b8 10 00 00 00       	mov    $0x10,%eax
f0103159:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010315b:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010315d:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f010315f:	ea 66 31 10 f0 08 00 	ljmp   $0x8,$0xf0103166
	asm volatile("lldt %0" : : "r" (sel));
f0103166:	b8 00 00 00 00       	mov    $0x0,%eax
f010316b:	0f 00 d0             	lldt   %ax
}
f010316e:	c3                   	ret    

f010316f <env_init>:
{
f010316f:	55                   	push   %ebp
f0103170:	89 e5                	mov    %esp,%ebp
f0103172:	83 ec 08             	sub    $0x8,%esp
	env_free_list=envs;
f0103175:	a1 70 62 2b f0       	mov    0xf02b6270,%eax
f010317a:	a3 74 62 2b f0       	mov    %eax,0xf02b6274
f010317f:	83 c0 7c             	add    $0x7c,%eax
	for(int i=0;i<NENV;i++){
f0103182:	ba 00 00 00 00       	mov    $0x0,%edx
f0103187:	eb 11                	jmp    f010319a <env_init+0x2b>
f0103189:	89 40 c8             	mov    %eax,-0x38(%eax)
f010318c:	83 c2 01             	add    $0x1,%edx
f010318f:	83 c0 7c             	add    $0x7c,%eax
f0103192:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103198:	74 1d                	je     f01031b7 <env_init+0x48>
		envs[i].env_status = ENV_FREE;
f010319a:	c7 40 d8 00 00 00 00 	movl   $0x0,-0x28(%eax)
		envs[i].env_id=0;
f01031a1:	c7 40 cc 00 00 00 00 	movl   $0x0,-0x34(%eax)
		if(i!=NENV-1) envs[i].env_link= &envs[i+1];
f01031a8:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f01031ae:	75 d9                	jne    f0103189 <env_init+0x1a>
f01031b0:	c7 40 c8 00 00 00 00 	movl   $0x0,-0x38(%eax)
	env_init_percpu();
f01031b7:	e8 87 ff ff ff       	call   f0103143 <env_init_percpu>
}
f01031bc:	c9                   	leave  
f01031bd:	c3                   	ret    

f01031be <env_alloc>:
{
f01031be:	55                   	push   %ebp
f01031bf:	89 e5                	mov    %esp,%ebp
f01031c1:	53                   	push   %ebx
f01031c2:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f01031c5:	8b 1d 74 62 2b f0    	mov    0xf02b6274,%ebx
f01031cb:	85 db                	test   %ebx,%ebx
f01031cd:	0f 84 59 01 00 00    	je     f010332c <env_alloc+0x16e>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01031d3:	83 ec 0c             	sub    $0xc,%esp
f01031d6:	6a 01                	push   $0x1
f01031d8:	e8 85 dd ff ff       	call   f0100f62 <page_alloc>
f01031dd:	83 c4 10             	add    $0x10,%esp
f01031e0:	85 c0                	test   %eax,%eax
f01031e2:	0f 84 4b 01 00 00    	je     f0103333 <env_alloc+0x175>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f01031e8:	89 c2                	mov    %eax,%edx
f01031ea:	2b 15 58 62 2b f0    	sub    0xf02b6258,%edx
f01031f0:	c1 fa 03             	sar    $0x3,%edx
f01031f3:	89 d1                	mov    %edx,%ecx
f01031f5:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f01031f8:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
f01031fe:	3b 15 60 62 2b f0    	cmp    0xf02b6260,%edx
f0103204:	0f 83 fb 00 00 00    	jae    f0103305 <env_alloc+0x147>
	return (void *)(pa + KERNBASE);
f010320a:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0103210:	89 4b 60             	mov    %ecx,0x60(%ebx)
	p->pp_ref++;
f0103213:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103218:	b8 00 00 00 00       	mov    $0x0,%eax
		e->env_pgdir[i] = 0;        
f010321d:	8b 53 60             	mov    0x60(%ebx),%edx
f0103220:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	for(i = 0; i < PDX(UTOP); i++) {
f0103227:	83 c0 04             	add    $0x4,%eax
f010322a:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f010322f:	75 ec                	jne    f010321d <env_alloc+0x5f>
		e->env_pgdir[i] = kern_pgdir[i];
f0103231:	8b 15 5c 62 2b f0    	mov    0xf02b625c,%edx
f0103237:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f010323a:	8b 53 60             	mov    0x60(%ebx),%edx
f010323d:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
	for(i = PDX(UTOP); i < NPDENTRIES; i++) {//NPDENTRIES宏在mmu.h中定义，为1024
f0103240:	83 c0 04             	add    $0x4,%eax
f0103243:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103248:	75 e7                	jne    f0103231 <env_alloc+0x73>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010324a:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f010324d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103252:	0f 86 bf 00 00 00    	jbe    f0103317 <env_alloc+0x159>
	return (physaddr_t)kva - KERNBASE;
f0103258:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010325e:	83 ca 05             	or     $0x5,%edx
f0103261:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103267:	8b 43 48             	mov    0x48(%ebx),%eax
f010326a:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f010326f:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103274:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103279:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010327c:	89 da                	mov    %ebx,%edx
f010327e:	2b 15 70 62 2b f0    	sub    0xf02b6270,%edx
f0103284:	c1 fa 02             	sar    $0x2,%edx
f0103287:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010328d:	09 d0                	or     %edx,%eax
f010328f:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103292:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103295:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103298:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010329f:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01032a6:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01032ad:	83 ec 04             	sub    $0x4,%esp
f01032b0:	6a 44                	push   $0x44
f01032b2:	6a 00                	push   $0x0
f01032b4:	53                   	push   %ebx
f01032b5:	e8 b3 25 00 00       	call   f010586d <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f01032ba:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01032c0:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01032c6:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01032cc:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01032d3:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f01032d9:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f01032e0:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f01032e7:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f01032eb:	8b 43 44             	mov    0x44(%ebx),%eax
f01032ee:	a3 74 62 2b f0       	mov    %eax,0xf02b6274
	*newenv_store = e;
f01032f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01032f6:	89 18                	mov    %ebx,(%eax)
	return 0;
f01032f8:	83 c4 10             	add    $0x10,%esp
f01032fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103303:	c9                   	leave  
f0103304:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103305:	51                   	push   %ecx
f0103306:	68 64 6d 10 f0       	push   $0xf0106d64
f010330b:	6a 5a                	push   $0x5a
f010330d:	68 bb 72 10 f0       	push   $0xf01072bb
f0103312:	e8 29 cd ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103317:	50                   	push   %eax
f0103318:	68 88 6d 10 f0       	push   $0xf0106d88
f010331d:	68 d1 00 00 00       	push   $0xd1
f0103322:	68 46 80 10 f0       	push   $0xf0108046
f0103327:	e8 14 cd ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f010332c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103331:	eb cd                	jmp    f0103300 <env_alloc+0x142>
		return -E_NO_MEM;
f0103333:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103338:	eb c6                	jmp    f0103300 <env_alloc+0x142>

f010333a <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//用env_alloc分配一个环境，并调用load_icode将ELF二进制文件加载到环境中。
void
env_create(uint8_t *binary, enum EnvType type)
{
f010333a:	55                   	push   %ebp
f010333b:	89 e5                	mov    %esp,%ebp
f010333d:	57                   	push   %edi
f010333e:	56                   	push   %esi
f010333f:	53                   	push   %ebx
f0103340:	83 ec 34             	sub    $0x34,%esp
f0103343:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 5: Your code here.


	// LAB 3: Your code here.
	//使用env_alloc分配一个env，根据注释很简单。
	struct Env * env=NULL;
f0103346:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&env, 0);
f010334d:	6a 00                	push   $0x0
f010334f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103352:	50                   	push   %eax
f0103353:	e8 66 fe ff ff       	call   f01031be <env_alloc>
	if(r < 0)  panic("env_create error: %e", r);//使用lab中示例的panic。
f0103358:	83 c4 10             	add    $0x10,%esp
f010335b:	85 c0                	test   %eax,%eax
f010335d:	78 44                	js     f01033a3 <env_create+0x69>
	//通过修改EFLAGS寄存器中的IOPL位，赋予文件系统环境 I/O权限  
	if (type == ENV_TYPE_FS)  env->env_tf.tf_eflags |= FL_IOPL_MASK;
f010335f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0103363:	74 53                	je     f01033b8 <env_create+0x7e>
	
	load_icode(env,binary);
f0103365:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103368:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if(e == NULL || binary == NULL)  panic("load_icode: invalid environment or binary\n");
f010336b:	85 c0                	test   %eax,%eax
f010336d:	74 55                	je     f01033c4 <env_create+0x8a>
f010336f:	85 ff                	test   %edi,%edi
f0103371:	74 51                	je     f01033c4 <env_create+0x8a>
	if(ElfHeader->e_magic != ELF_MAGIC) panic("load_icode error : binary is invalid elf format\n");
f0103373:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103379:	75 60                	jne    f01033db <env_create+0xa1>
	struct Proghdr * ph = (struct Proghdr *) ((uint8_t *) ElfHeader + ElfHeader->e_phoff);
f010337b:	89 fb                	mov    %edi,%ebx
f010337d:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr * eph = ph + ElfHeader->e_phnum;
f0103380:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103384:	c1 e6 05             	shl    $0x5,%esi
f0103387:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));//lcr3(uint32_t val)在inc/x86.h中定义 ，其将val值赋给cr3寄存器(即页目录基寄存器)。
f0103389:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010338c:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010338f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103394:	76 5c                	jbe    f01033f2 <env_create+0xb8>
	return (physaddr_t)kva - KERNBASE;
f0103396:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f010339b:	0f 22 d8             	mov    %eax,%cr3
}
f010339e:	e9 a0 00 00 00       	jmp    f0103443 <env_create+0x109>
	if(r < 0)  panic("env_create error: %e", r);//使用lab中示例的panic。
f01033a3:	50                   	push   %eax
f01033a4:	68 51 80 10 f0       	push   $0xf0108051
f01033a9:	68 ab 01 00 00       	push   $0x1ab
f01033ae:	68 46 80 10 f0       	push   $0xf0108046
f01033b3:	e8 88 cc ff ff       	call   f0100040 <_panic>
	if (type == ENV_TYPE_FS)  env->env_tf.tf_eflags |= FL_IOPL_MASK;
f01033b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033bb:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
f01033c2:	eb a1                	jmp    f0103365 <env_create+0x2b>
	if(e == NULL || binary == NULL)  panic("load_icode: invalid environment or binary\n");
f01033c4:	83 ec 04             	sub    $0x4,%esp
f01033c7:	68 c0 7f 10 f0       	push   $0xf0107fc0
f01033cc:	68 79 01 00 00       	push   $0x179
f01033d1:	68 46 80 10 f0       	push   $0xf0108046
f01033d6:	e8 65 cc ff ff       	call   f0100040 <_panic>
	if(ElfHeader->e_magic != ELF_MAGIC) panic("load_icode error : binary is invalid elf format\n");
f01033db:	83 ec 04             	sub    $0x4,%esp
f01033de:	68 ec 7f 10 f0       	push   $0xf0107fec
f01033e3:	68 7e 01 00 00       	push   $0x17e
f01033e8:	68 46 80 10 f0       	push   $0xf0108046
f01033ed:	e8 4e cc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033f2:	50                   	push   %eax
f01033f3:	68 88 6d 10 f0       	push   $0xf0106d88
f01033f8:	68 83 01 00 00       	push   $0x183
f01033fd:	68 46 80 10 f0       	push   $0xf0108046
f0103402:	e8 39 cc ff ff       	call   f0100040 <_panic>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);//为 环境e 分配和映射物理内存
f0103407:	8b 53 08             	mov    0x8(%ebx),%edx
f010340a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010340d:	e8 12 fc ff ff       	call   f0103024 <region_alloc>
			memmove((void*)ph->p_va, (uint8_t *)binary + ph->p_offset, ph->p_filesz);//移动binary到虚拟内存  (mem等函数全在lib/string.c中定义)
f0103412:	83 ec 04             	sub    $0x4,%esp
f0103415:	ff 73 10             	push   0x10(%ebx)
f0103418:	89 f8                	mov    %edi,%eax
f010341a:	03 43 04             	add    0x4(%ebx),%eax
f010341d:	50                   	push   %eax
f010341e:	ff 73 08             	push   0x8(%ebx)
f0103421:	e8 8d 24 00 00       	call   f01058b3 <memmove>
			memset((void*)ph->p_va+ph->p_filesz, 0, ph->p_memsz-ph->p_filesz);//剩余内存置0
f0103426:	8b 43 10             	mov    0x10(%ebx),%eax
f0103429:	83 c4 0c             	add    $0xc,%esp
f010342c:	8b 53 14             	mov    0x14(%ebx),%edx
f010342f:	29 c2                	sub    %eax,%edx
f0103431:	52                   	push   %edx
f0103432:	6a 00                	push   $0x0
f0103434:	03 43 08             	add    0x8(%ebx),%eax
f0103437:	50                   	push   %eax
f0103438:	e8 30 24 00 00       	call   f010586d <memset>
f010343d:	83 c4 10             	add    $0x10,%esp
	for(; ph < eph; ph++) {
f0103440:	83 c3 20             	add    $0x20,%ebx
f0103443:	39 de                	cmp    %ebx,%esi
f0103445:	76 24                	jbe    f010346b <env_create+0x131>
		if(ph->p_type == ELF_PROG_LOAD){//注释要求
f0103447:	83 3b 01             	cmpl   $0x1,(%ebx)
f010344a:	75 f4                	jne    f0103440 <env_create+0x106>
			if(ph->p_memsz < ph->p_filesz)
f010344c:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010344f:	3b 4b 10             	cmp    0x10(%ebx),%ecx
f0103452:	73 b3                	jae    f0103407 <env_create+0xcd>
				panic("load_icode error: p_memsz < p_filesz\n");
f0103454:	83 ec 04             	sub    $0x4,%esp
f0103457:	68 20 80 10 f0       	push   $0xf0108020
f010345c:	68 88 01 00 00       	push   $0x188
f0103461:	68 46 80 10 f0       	push   $0xf0108046
f0103466:	e8 d5 cb ff ff       	call   f0100040 <_panic>
	lcr3(PADDR(kern_pgdir));//再切换回内核的页目录，我感觉要在分配栈前，一些博客与我有出入。
f010346b:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103470:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103475:	76 33                	jbe    f01034aa <env_create+0x170>
	return (physaddr_t)kva - KERNBASE;
f0103477:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f010347c:	0f 22 d8             	mov    %eax,%cr3
	e->env_tf.tf_eip = ElfHeader->e_entry;//这句我也不确定。但我感觉大致思路是由于段设计在JOS约等于没有（因为linux就约等于没有，之前lab中介绍有提到），而根据注释要修改cs:ip,所以就之修改了eip。
f010347f:	8b 47 18             	mov    0x18(%edi),%eax
f0103482:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103485:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void*)(USTACKTOP-PGSIZE), PGSIZE);
f0103488:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010348d:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103492:	89 f8                	mov    %edi,%eax
f0103494:	e8 8b fb ff ff       	call   f0103024 <region_alloc>
	env->env_type=type;
f0103499:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010349c:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010349f:	89 78 50             	mov    %edi,0x50(%eax)
}
f01034a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034a5:	5b                   	pop    %ebx
f01034a6:	5e                   	pop    %esi
f01034a7:	5f                   	pop    %edi
f01034a8:	5d                   	pop    %ebp
f01034a9:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034aa:	50                   	push   %eax
f01034ab:	68 88 6d 10 f0       	push   $0xf0106d88
f01034b0:	68 8f 01 00 00       	push   $0x18f
f01034b5:	68 46 80 10 f0       	push   $0xf0108046
f01034ba:	e8 81 cb ff ff       	call   f0100040 <_panic>

f01034bf <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01034bf:	55                   	push   %ebp
f01034c0:	89 e5                	mov    %esp,%ebp
f01034c2:	57                   	push   %edi
f01034c3:	56                   	push   %esi
f01034c4:	53                   	push   %ebx
f01034c5:	83 ec 1c             	sub    $0x1c,%esp
f01034c8:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01034cb:	e8 94 29 00 00       	call   f0105e64 <cpunum>
f01034d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01034d3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01034da:	39 b8 28 70 2f f0    	cmp    %edi,-0xfd08fd8(%eax)
f01034e0:	0f 85 b3 00 00 00    	jne    f0103599 <env_free+0xda>
		lcr3(PADDR(kern_pgdir));
f01034e6:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
	if ((uint32_t)kva < KERNBASE)
f01034eb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034f0:	76 14                	jbe    f0103506 <env_free+0x47>
	return (physaddr_t)kva - KERNBASE;
f01034f2:	05 00 00 00 10       	add    $0x10000000,%eax
f01034f7:	0f 22 d8             	mov    %eax,%cr3
}
f01034fa:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103501:	e9 93 00 00 00       	jmp    f0103599 <env_free+0xda>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103506:	50                   	push   %eax
f0103507:	68 88 6d 10 f0       	push   $0xf0106d88
f010350c:	68 c1 01 00 00       	push   $0x1c1
f0103511:	68 46 80 10 f0       	push   $0xf0108046
f0103516:	e8 25 cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010351b:	56                   	push   %esi
f010351c:	68 64 6d 10 f0       	push   $0xf0106d64
f0103521:	68 d0 01 00 00       	push   $0x1d0
f0103526:	68 46 80 10 f0       	push   $0xf0108046
f010352b:	e8 10 cb ff ff       	call   f0100040 <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103530:	83 c6 04             	add    $0x4,%esi
f0103533:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103539:	81 fb 00 00 40 00    	cmp    $0x400000,%ebx
f010353f:	74 1b                	je     f010355c <env_free+0x9d>
			if (pt[pteno] & PTE_P)
f0103541:	f6 06 01             	testb  $0x1,(%esi)
f0103544:	74 ea                	je     f0103530 <env_free+0x71>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103546:	83 ec 08             	sub    $0x8,%esp
f0103549:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010354c:	09 d8                	or     %ebx,%eax
f010354e:	50                   	push   %eax
f010354f:	ff 77 60             	push   0x60(%edi)
f0103552:	e8 d3 dc ff ff       	call   f010122a <page_remove>
f0103557:	83 c4 10             	add    $0x10,%esp
f010355a:	eb d4                	jmp    f0103530 <env_free+0x71>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010355c:	8b 47 60             	mov    0x60(%edi),%eax
f010355f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103562:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f0103569:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010356c:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f0103572:	73 65                	jae    f01035d9 <env_free+0x11a>
		page_decref(pa2page(pa));
f0103574:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103577:	a1 58 62 2b f0       	mov    0xf02b6258,%eax
f010357c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010357f:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103582:	50                   	push   %eax
f0103583:	e8 a5 da ff ff       	call   f010102d <page_decref>
f0103588:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010358b:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f010358f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103592:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103597:	74 54                	je     f01035ed <env_free+0x12e>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103599:	8b 47 60             	mov    0x60(%edi),%eax
f010359c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010359f:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f01035a2:	a8 01                	test   $0x1,%al
f01035a4:	74 e5                	je     f010358b <env_free+0xcc>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01035a6:	89 c6                	mov    %eax,%esi
f01035a8:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f01035ae:	c1 e8 0c             	shr    $0xc,%eax
f01035b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01035b4:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f01035ba:	0f 83 5b ff ff ff    	jae    f010351b <env_free+0x5c>
	return (void *)(pa + KERNBASE);
f01035c0:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f01035c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035c9:	c1 e0 14             	shl    $0x14,%eax
f01035cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01035cf:	bb 00 00 00 00       	mov    $0x0,%ebx
f01035d4:	e9 68 ff ff ff       	jmp    f0103541 <env_free+0x82>
		panic("pa2page called with invalid pa");
f01035d9:	83 ec 04             	sub    $0x4,%esp
f01035dc:	68 f4 76 10 f0       	push   $0xf01076f4
f01035e1:	6a 52                	push   $0x52
f01035e3:	68 bb 72 10 f0       	push   $0xf01072bb
f01035e8:	e8 53 ca ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01035ed:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f01035f0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035f5:	76 49                	jbe    f0103640 <env_free+0x181>
	e->env_pgdir = 0;
f01035f7:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01035fe:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f0103603:	c1 e8 0c             	shr    $0xc,%eax
f0103606:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f010360c:	73 47                	jae    f0103655 <env_free+0x196>
	page_decref(pa2page(pa));
f010360e:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103611:	8b 15 58 62 2b f0    	mov    0xf02b6258,%edx
f0103617:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010361a:	50                   	push   %eax
f010361b:	e8 0d da ff ff       	call   f010102d <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103620:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103627:	a1 74 62 2b f0       	mov    0xf02b6274,%eax
f010362c:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010362f:	89 3d 74 62 2b f0    	mov    %edi,0xf02b6274
}
f0103635:	83 c4 10             	add    $0x10,%esp
f0103638:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010363b:	5b                   	pop    %ebx
f010363c:	5e                   	pop    %esi
f010363d:	5f                   	pop    %edi
f010363e:	5d                   	pop    %ebp
f010363f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103640:	50                   	push   %eax
f0103641:	68 88 6d 10 f0       	push   $0xf0106d88
f0103646:	68 de 01 00 00       	push   $0x1de
f010364b:	68 46 80 10 f0       	push   $0xf0108046
f0103650:	e8 eb c9 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f0103655:	83 ec 04             	sub    $0x4,%esp
f0103658:	68 f4 76 10 f0       	push   $0xf01076f4
f010365d:	6a 52                	push   $0x52
f010365f:	68 bb 72 10 f0       	push   $0xf01072bb
f0103664:	e8 d7 c9 ff ff       	call   f0100040 <_panic>

f0103669 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103669:	55                   	push   %ebp
f010366a:	89 e5                	mov    %esp,%ebp
f010366c:	53                   	push   %ebx
f010366d:	83 ec 04             	sub    $0x4,%esp
f0103670:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103673:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103677:	74 21                	je     f010369a <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103679:	83 ec 0c             	sub    $0xc,%esp
f010367c:	53                   	push   %ebx
f010367d:	e8 3d fe ff ff       	call   f01034bf <env_free>

	if (curenv == e) {
f0103682:	e8 dd 27 00 00       	call   f0105e64 <cpunum>
f0103687:	6b c0 74             	imul   $0x74,%eax,%eax
f010368a:	83 c4 10             	add    $0x10,%esp
f010368d:	39 98 28 70 2f f0    	cmp    %ebx,-0xfd08fd8(%eax)
f0103693:	74 1e                	je     f01036b3 <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f0103695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103698:	c9                   	leave  
f0103699:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010369a:	e8 c5 27 00 00       	call   f0105e64 <cpunum>
f010369f:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a2:	39 98 28 70 2f f0    	cmp    %ebx,-0xfd08fd8(%eax)
f01036a8:	74 cf                	je     f0103679 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f01036aa:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01036b1:	eb e2                	jmp    f0103695 <env_destroy+0x2c>
		curenv = NULL;
f01036b3:	e8 ac 27 00 00       	call   f0105e64 <cpunum>
f01036b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01036bb:	c7 80 28 70 2f f0 00 	movl   $0x0,-0xfd08fd8(%eax)
f01036c2:	00 00 00 
		sched_yield();
f01036c5:	e8 19 0f 00 00       	call   f01045e3 <sched_yield>

f01036ca <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01036ca:	55                   	push   %ebp
f01036cb:	89 e5                	mov    %esp,%ebp
f01036cd:	53                   	push   %ebx
f01036ce:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01036d1:	e8 8e 27 00 00       	call   f0105e64 <cpunum>
f01036d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01036d9:	8b 98 28 70 2f f0    	mov    -0xfd08fd8(%eax),%ebx
f01036df:	e8 80 27 00 00       	call   f0105e64 <cpunum>
f01036e4:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01036e7:	8b 65 08             	mov    0x8(%ebp),%esp
f01036ea:	61                   	popa   
f01036eb:	07                   	pop    %es
f01036ec:	1f                   	pop    %ds
f01036ed:	83 c4 08             	add    $0x8,%esp
f01036f0:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n" /*中断返回指令*/
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01036f1:	83 ec 04             	sub    $0x4,%esp
f01036f4:	68 66 80 10 f0       	push   $0xf0108066
f01036f9:	68 15 02 00 00       	push   $0x215
f01036fe:	68 46 80 10 f0       	push   $0xf0108046
f0103703:	e8 38 c9 ff ff       	call   f0100040 <_panic>

f0103708 <env_run>:
//
// This function does not return.
//启动在用户模式下运行的给定环境。
void
env_run(struct Env *e)
{
f0103708:	55                   	push   %ebp
f0103709:	89 e5                	mov    %esp,%ebp
f010370b:	53                   	push   %ebx
f010370c:	83 ec 04             	sub    $0x4,%esp
f010370f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// Step 1
	if(e == NULL) panic("env_run: invalid environment\n");
f0103712:	85 db                	test   %ebx,%ebx
f0103714:	0f 84 b3 00 00 00    	je     f01037cd <env_run+0xc5>
	if(curenv != e && curenv != NULL) {
f010371a:	e8 45 27 00 00       	call   f0105e64 <cpunum>
f010371f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103722:	39 98 28 70 2f f0    	cmp    %ebx,-0xfd08fd8(%eax)
f0103728:	74 29                	je     f0103753 <env_run+0x4b>
f010372a:	e8 35 27 00 00       	call   f0105e64 <cpunum>
f010372f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103732:	83 b8 28 70 2f f0 00 	cmpl   $0x0,-0xfd08fd8(%eax)
f0103739:	74 18                	je     f0103753 <env_run+0x4b>
		if(curenv->env_status == ENV_RUNNING)  curenv->env_status = ENV_RUNNABLE;
f010373b:	e8 24 27 00 00       	call   f0105e64 <cpunum>
f0103740:	6b c0 74             	imul   $0x74,%eax,%eax
f0103743:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f0103749:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010374d:	0f 84 91 00 00 00    	je     f01037e4 <env_run+0xdc>
	}
	curenv=e;
f0103753:	e8 0c 27 00 00       	call   f0105e64 <cpunum>
f0103758:	6b c0 74             	imul   $0x74,%eax,%eax
f010375b:	89 98 28 70 2f f0    	mov    %ebx,-0xfd08fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103761:	e8 fe 26 00 00       	call   f0105e64 <cpunum>
f0103766:	6b c0 74             	imul   $0x74,%eax,%eax
f0103769:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f010376f:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103776:	e8 e9 26 00 00       	call   f0105e64 <cpunum>
f010377b:	6b c0 74             	imul   $0x74,%eax,%eax
f010377e:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f0103784:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103788:	e8 d7 26 00 00       	call   f0105e64 <cpunum>
f010378d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103790:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f0103796:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103799:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010379e:	76 5e                	jbe    f01037fe <env_run+0xf6>
	return (physaddr_t)kva - KERNBASE;
f01037a0:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f01037a5:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01037a8:	83 ec 0c             	sub    $0xc,%esp
f01037ab:	68 c0 83 12 f0       	push   $0xf01283c0
f01037b0:	e8 b9 29 00 00       	call   f010616e <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01037b5:	f3 90                	pause  
	
	//lab4:切换到用户模式之前释放锁
	unlock_kernel();
	
	// Step 2
	env_pop_tf( &(curenv->env_tf) );
f01037b7:	e8 a8 26 00 00       	call   f0105e64 <cpunum>
f01037bc:	83 c4 04             	add    $0x4,%esp
f01037bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01037c2:	ff b0 28 70 2f f0    	push   -0xfd08fd8(%eax)
f01037c8:	e8 fd fe ff ff       	call   f01036ca <env_pop_tf>
	if(e == NULL) panic("env_run: invalid environment\n");
f01037cd:	83 ec 04             	sub    $0x4,%esp
f01037d0:	68 72 80 10 f0       	push   $0xf0108072
f01037d5:	68 34 02 00 00       	push   $0x234
f01037da:	68 46 80 10 f0       	push   $0xf0108046
f01037df:	e8 5c c8 ff ff       	call   f0100040 <_panic>
		if(curenv->env_status == ENV_RUNNING)  curenv->env_status = ENV_RUNNABLE;
f01037e4:	e8 7b 26 00 00       	call   f0105e64 <cpunum>
f01037e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01037ec:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f01037f2:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f01037f9:	e9 55 ff ff ff       	jmp    f0103753 <env_run+0x4b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037fe:	50                   	push   %eax
f01037ff:	68 88 6d 10 f0       	push   $0xf0106d88
f0103804:	68 3b 02 00 00       	push   $0x23b
f0103809:	68 46 80 10 f0       	push   $0xf0108046
f010380e:	e8 2d c8 ff ff       	call   f0100040 <_panic>

f0103813 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103813:	55                   	push   %ebp
f0103814:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103816:	8b 45 08             	mov    0x8(%ebp),%eax
f0103819:	ba 70 00 00 00       	mov    $0x70,%edx
f010381e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010381f:	ba 71 00 00 00       	mov    $0x71,%edx
f0103824:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103825:	0f b6 c0             	movzbl %al,%eax
}
f0103828:	5d                   	pop    %ebp
f0103829:	c3                   	ret    

f010382a <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010382a:	55                   	push   %ebp
f010382b:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010382d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103830:	ba 70 00 00 00       	mov    $0x70,%edx
f0103835:	ee                   	out    %al,(%dx)
f0103836:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103839:	ba 71 00 00 00       	mov    $0x71,%edx
f010383e:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010383f:	5d                   	pop    %ebp
f0103840:	c3                   	ret    

f0103841 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103841:	55                   	push   %ebp
f0103842:	89 e5                	mov    %esp,%ebp
f0103844:	56                   	push   %esi
f0103845:	53                   	push   %ebx
f0103846:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	irq_mask_8259A = mask;
f0103849:	66 89 0d a8 83 12 f0 	mov    %cx,0xf01283a8
	if (!didinit)
f0103850:	80 3d 78 62 2b f0 00 	cmpb   $0x0,0xf02b6278
f0103857:	75 07                	jne    f0103860 <irq_setmask_8259A+0x1f>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103859:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010385c:	5b                   	pop    %ebx
f010385d:	5e                   	pop    %esi
f010385e:	5d                   	pop    %ebp
f010385f:	c3                   	ret    
f0103860:	89 ce                	mov    %ecx,%esi
f0103862:	ba 21 00 00 00       	mov    $0x21,%edx
f0103867:	89 c8                	mov    %ecx,%eax
f0103869:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f010386a:	89 c8                	mov    %ecx,%eax
f010386c:	66 c1 e8 08          	shr    $0x8,%ax
f0103870:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103875:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103876:	83 ec 0c             	sub    $0xc,%esp
f0103879:	68 90 80 10 f0       	push   $0xf0108090
f010387e:	e8 32 01 00 00       	call   f01039b5 <cprintf>
f0103883:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103886:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010388b:	0f b7 f6             	movzwl %si,%esi
f010388e:	f7 d6                	not    %esi
f0103890:	eb 08                	jmp    f010389a <irq_setmask_8259A+0x59>
	for (i = 0; i < 16; i++)
f0103892:	83 c3 01             	add    $0x1,%ebx
f0103895:	83 fb 10             	cmp    $0x10,%ebx
f0103898:	74 18                	je     f01038b2 <irq_setmask_8259A+0x71>
		if (~mask & (1<<i))
f010389a:	0f a3 de             	bt     %ebx,%esi
f010389d:	73 f3                	jae    f0103892 <irq_setmask_8259A+0x51>
			cprintf(" %d", i);
f010389f:	83 ec 08             	sub    $0x8,%esp
f01038a2:	53                   	push   %ebx
f01038a3:	68 f7 85 10 f0       	push   $0xf01085f7
f01038a8:	e8 08 01 00 00       	call   f01039b5 <cprintf>
f01038ad:	83 c4 10             	add    $0x10,%esp
f01038b0:	eb e0                	jmp    f0103892 <irq_setmask_8259A+0x51>
	cprintf("\n");
f01038b2:	83 ec 0c             	sub    $0xc,%esp
f01038b5:	68 b3 75 10 f0       	push   $0xf01075b3
f01038ba:	e8 f6 00 00 00       	call   f01039b5 <cprintf>
f01038bf:	83 c4 10             	add    $0x10,%esp
f01038c2:	eb 95                	jmp    f0103859 <irq_setmask_8259A+0x18>

f01038c4 <pic_init>:
{
f01038c4:	55                   	push   %ebp
f01038c5:	89 e5                	mov    %esp,%ebp
f01038c7:	57                   	push   %edi
f01038c8:	56                   	push   %esi
f01038c9:	53                   	push   %ebx
f01038ca:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f01038cd:	c6 05 78 62 2b f0 01 	movb   $0x1,0xf02b6278
f01038d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01038d9:	bb 21 00 00 00       	mov    $0x21,%ebx
f01038de:	89 da                	mov    %ebx,%edx
f01038e0:	ee                   	out    %al,(%dx)
f01038e1:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f01038e6:	89 ca                	mov    %ecx,%edx
f01038e8:	ee                   	out    %al,(%dx)
f01038e9:	bf 11 00 00 00       	mov    $0x11,%edi
f01038ee:	be 20 00 00 00       	mov    $0x20,%esi
f01038f3:	89 f8                	mov    %edi,%eax
f01038f5:	89 f2                	mov    %esi,%edx
f01038f7:	ee                   	out    %al,(%dx)
f01038f8:	b8 20 00 00 00       	mov    $0x20,%eax
f01038fd:	89 da                	mov    %ebx,%edx
f01038ff:	ee                   	out    %al,(%dx)
f0103900:	b8 04 00 00 00       	mov    $0x4,%eax
f0103905:	ee                   	out    %al,(%dx)
f0103906:	b8 03 00 00 00       	mov    $0x3,%eax
f010390b:	ee                   	out    %al,(%dx)
f010390c:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103911:	89 f8                	mov    %edi,%eax
f0103913:	89 da                	mov    %ebx,%edx
f0103915:	ee                   	out    %al,(%dx)
f0103916:	b8 28 00 00 00       	mov    $0x28,%eax
f010391b:	89 ca                	mov    %ecx,%edx
f010391d:	ee                   	out    %al,(%dx)
f010391e:	b8 02 00 00 00       	mov    $0x2,%eax
f0103923:	ee                   	out    %al,(%dx)
f0103924:	b8 01 00 00 00       	mov    $0x1,%eax
f0103929:	ee                   	out    %al,(%dx)
f010392a:	bf 68 00 00 00       	mov    $0x68,%edi
f010392f:	89 f8                	mov    %edi,%eax
f0103931:	89 f2                	mov    %esi,%edx
f0103933:	ee                   	out    %al,(%dx)
f0103934:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103939:	89 c8                	mov    %ecx,%eax
f010393b:	ee                   	out    %al,(%dx)
f010393c:	89 f8                	mov    %edi,%eax
f010393e:	89 da                	mov    %ebx,%edx
f0103940:	ee                   	out    %al,(%dx)
f0103941:	89 c8                	mov    %ecx,%eax
f0103943:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103944:	0f b7 05 a8 83 12 f0 	movzwl 0xf01283a8,%eax
f010394b:	66 83 f8 ff          	cmp    $0xffff,%ax
f010394f:	75 08                	jne    f0103959 <pic_init+0x95>
}
f0103951:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103954:	5b                   	pop    %ebx
f0103955:	5e                   	pop    %esi
f0103956:	5f                   	pop    %edi
f0103957:	5d                   	pop    %ebp
f0103958:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f0103959:	83 ec 0c             	sub    $0xc,%esp
f010395c:	0f b7 c0             	movzwl %ax,%eax
f010395f:	50                   	push   %eax
f0103960:	e8 dc fe ff ff       	call   f0103841 <irq_setmask_8259A>
f0103965:	83 c4 10             	add    $0x10,%esp
}
f0103968:	eb e7                	jmp    f0103951 <pic_init+0x8d>

f010396a <irq_eoi>:
f010396a:	b8 20 00 00 00       	mov    $0x20,%eax
f010396f:	ba 20 00 00 00       	mov    $0x20,%edx
f0103974:	ee                   	out    %al,(%dx)
f0103975:	ba a0 00 00 00       	mov    $0xa0,%edx
f010397a:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f010397b:	c3                   	ret    

f010397c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010397c:	55                   	push   %ebp
f010397d:	89 e5                	mov    %esp,%ebp
f010397f:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103982:	ff 75 08             	push   0x8(%ebp)
f0103985:	e8 0c ce ff ff       	call   f0100796 <cputchar>
	*cnt++;
}
f010398a:	83 c4 10             	add    $0x10,%esp
f010398d:	c9                   	leave  
f010398e:	c3                   	ret    

f010398f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010398f:	55                   	push   %ebp
f0103990:	89 e5                	mov    %esp,%ebp
f0103992:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103995:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010399c:	ff 75 0c             	push   0xc(%ebp)
f010399f:	ff 75 08             	push   0x8(%ebp)
f01039a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01039a5:	50                   	push   %eax
f01039a6:	68 7c 39 10 f0       	push   $0xf010397c
f01039ab:	e8 9c 17 00 00       	call   f010514c <vprintfmt>
	return cnt;
}
f01039b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01039b3:	c9                   	leave  
f01039b4:	c3                   	ret    

f01039b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01039b5:	55                   	push   %ebp
f01039b6:	89 e5                	mov    %esp,%ebp
f01039b8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01039bb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01039be:	50                   	push   %eax
f01039bf:	ff 75 08             	push   0x8(%ebp)
f01039c2:	e8 c8 ff ff ff       	call   f010398f <vcprintf>
	va_end(ap);

	return cnt;
}
f01039c7:	c9                   	leave  
f01039c8:	c3                   	ret    

f01039c9 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01039c9:	55                   	push   %ebp
f01039ca:	89 e5                	mov    %esp,%ebp
f01039cc:	57                   	push   %edi
f01039cd:	56                   	push   %esi
f01039ce:	53                   	push   %ebx
f01039cf:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	//依照注释hints修改即可
	size_t i =thiscpu->cpu_id;
f01039d2:	e8 8d 24 00 00       	call   f0105e64 <cpunum>
f01039d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01039da:	0f b6 b8 20 70 2f f0 	movzbl -0xfd08fe0(%eax),%edi
f01039e1:	89 f8                	mov    %edi,%eax
f01039e3:	0f b6 d8             	movzbl %al,%ebx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
f01039e6:	e8 79 24 00 00       	call   f0105e64 <cpunum>
f01039eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01039ee:	ba 00 f0 00 00       	mov    $0xf000,%edx
f01039f3:	29 da                	sub    %ebx,%edx
f01039f5:	c1 e2 10             	shl    $0x10,%edx
f01039f8:	89 90 30 70 2f f0    	mov    %edx,-0xfd08fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01039fe:	e8 61 24 00 00       	call   f0105e64 <cpunum>
f0103a03:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a06:	66 c7 80 34 70 2f f0 	movw   $0x10,-0xfd08fcc(%eax)
f0103a0d:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);//这行不懂，直接较原来程序保持不变
f0103a0f:	e8 50 24 00 00       	call   f0105e64 <cpunum>
f0103a14:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a17:	66 c7 80 92 70 2f f0 	movw   $0x68,-0xfd08f6e(%eax)
f0103a1e:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103a20:	83 c3 05             	add    $0x5,%ebx
f0103a23:	e8 3c 24 00 00       	call   f0105e64 <cpunum>
f0103a28:	89 c6                	mov    %eax,%esi
f0103a2a:	e8 35 24 00 00       	call   f0105e64 <cpunum>
f0103a2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103a32:	e8 2d 24 00 00       	call   f0105e64 <cpunum>
f0103a37:	66 c7 04 dd 40 83 12 	movw   $0x67,-0xfed7cc0(,%ebx,8)
f0103a3e:	f0 67 00 
f0103a41:	6b f6 74             	imul   $0x74,%esi,%esi
f0103a44:	81 c6 2c 70 2f f0    	add    $0xf02f702c,%esi
f0103a4a:	66 89 34 dd 42 83 12 	mov    %si,-0xfed7cbe(,%ebx,8)
f0103a51:	f0 
f0103a52:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103a56:	81 c2 2c 70 2f f0    	add    $0xf02f702c,%edx
f0103a5c:	c1 ea 10             	shr    $0x10,%edx
f0103a5f:	88 14 dd 44 83 12 f0 	mov    %dl,-0xfed7cbc(,%ebx,8)
f0103a66:	c6 04 dd 46 83 12 f0 	movb   $0x40,-0xfed7cba(,%ebx,8)
f0103a6d:	40 
f0103a6e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a71:	05 2c 70 2f f0       	add    $0xf02f702c,%eax
f0103a76:	c1 e8 18             	shr    $0x18,%eax
f0103a79:	88 04 dd 47 83 12 f0 	mov    %al,-0xfed7cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103a80:	c6 04 dd 45 83 12 f0 	movb   $0x89,-0xfed7cbb(,%ebx,8)
f0103a87:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (i << 3));//相应的TSS选择子也要修改
f0103a88:	89 f8                	mov    %edi,%eax
f0103a8a:	0f b6 f8             	movzbl %al,%edi
f0103a8d:	8d 3c fd 28 00 00 00 	lea    0x28(,%edi,8),%edi
	asm volatile("ltr %0" : : "r" (sel));
f0103a94:	0f 00 df             	ltr    %di
	asm volatile("lidt (%0)" : : "r" (p));
f0103a97:	b8 ac 83 12 f0       	mov    $0xf01283ac,%eax
f0103a9c:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103a9f:	83 c4 1c             	add    $0x1c,%esp
f0103aa2:	5b                   	pop    %ebx
f0103aa3:	5e                   	pop    %esi
f0103aa4:	5f                   	pop    %edi
f0103aa5:	5d                   	pop    %ebp
f0103aa6:	c3                   	ret    

f0103aa7 <trap_init>:
{
f0103aa7:	55                   	push   %ebp
f0103aa8:	89 e5                	mov    %esp,%ebp
f0103aaa:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, DIVIDE_HANDLER, 0);//GD_KT  kernel text
f0103aad:	b8 7c 44 10 f0       	mov    $0xf010447c,%eax
f0103ab2:	66 a3 80 62 2b f0    	mov    %ax,0xf02b6280
f0103ab8:	66 c7 05 82 62 2b f0 	movw   $0x8,0xf02b6282
f0103abf:	08 00 
f0103ac1:	c6 05 84 62 2b f0 00 	movb   $0x0,0xf02b6284
f0103ac8:	c6 05 85 62 2b f0 8e 	movb   $0x8e,0xf02b6285
f0103acf:	c1 e8 10             	shr    $0x10,%eax
f0103ad2:	66 a3 86 62 2b f0    	mov    %ax,0xf02b6286
	SETGATE(idt[T_DEBUG], 0, GD_KT, DEBUG_HANDLER, 0);
f0103ad8:	b8 86 44 10 f0       	mov    $0xf0104486,%eax
f0103add:	66 a3 88 62 2b f0    	mov    %ax,0xf02b6288
f0103ae3:	66 c7 05 8a 62 2b f0 	movw   $0x8,0xf02b628a
f0103aea:	08 00 
f0103aec:	c6 05 8c 62 2b f0 00 	movb   $0x0,0xf02b628c
f0103af3:	c6 05 8d 62 2b f0 8e 	movb   $0x8e,0xf02b628d
f0103afa:	c1 e8 10             	shr    $0x10,%eax
f0103afd:	66 a3 8e 62 2b f0    	mov    %ax,0xf02b628e
	SETGATE(idt[T_NMI], 0, GD_KT, NMI_HANDLER, 0);
f0103b03:	b8 8c 44 10 f0       	mov    $0xf010448c,%eax
f0103b08:	66 a3 90 62 2b f0    	mov    %ax,0xf02b6290
f0103b0e:	66 c7 05 92 62 2b f0 	movw   $0x8,0xf02b6292
f0103b15:	08 00 
f0103b17:	c6 05 94 62 2b f0 00 	movb   $0x0,0xf02b6294
f0103b1e:	c6 05 95 62 2b f0 8e 	movb   $0x8e,0xf02b6295
f0103b25:	c1 e8 10             	shr    $0x10,%eax
f0103b28:	66 a3 96 62 2b f0    	mov    %ax,0xf02b6296
	SETGATE(idt[T_BRKPT], 0, GD_KT, BRKPT_HANDLER, 3);//exercise 6在此处需要修改
f0103b2e:	b8 92 44 10 f0       	mov    $0xf0104492,%eax
f0103b33:	66 a3 98 62 2b f0    	mov    %ax,0xf02b6298
f0103b39:	66 c7 05 9a 62 2b f0 	movw   $0x8,0xf02b629a
f0103b40:	08 00 
f0103b42:	c6 05 9c 62 2b f0 00 	movb   $0x0,0xf02b629c
f0103b49:	c6 05 9d 62 2b f0 ee 	movb   $0xee,0xf02b629d
f0103b50:	c1 e8 10             	shr    $0x10,%eax
f0103b53:	66 a3 9e 62 2b f0    	mov    %ax,0xf02b629e
	SETGATE(idt[T_OFLOW], 0, GD_KT, OFLOW_HANDLER, 0);
f0103b59:	b8 98 44 10 f0       	mov    $0xf0104498,%eax
f0103b5e:	66 a3 a0 62 2b f0    	mov    %ax,0xf02b62a0
f0103b64:	66 c7 05 a2 62 2b f0 	movw   $0x8,0xf02b62a2
f0103b6b:	08 00 
f0103b6d:	c6 05 a4 62 2b f0 00 	movb   $0x0,0xf02b62a4
f0103b74:	c6 05 a5 62 2b f0 8e 	movb   $0x8e,0xf02b62a5
f0103b7b:	c1 e8 10             	shr    $0x10,%eax
f0103b7e:	66 a3 a6 62 2b f0    	mov    %ax,0xf02b62a6
	SETGATE(idt[T_BOUND], 0, GD_KT, BOUND_HANDLER, 0);
f0103b84:	b8 9e 44 10 f0       	mov    $0xf010449e,%eax
f0103b89:	66 a3 a8 62 2b f0    	mov    %ax,0xf02b62a8
f0103b8f:	66 c7 05 aa 62 2b f0 	movw   $0x8,0xf02b62aa
f0103b96:	08 00 
f0103b98:	c6 05 ac 62 2b f0 00 	movb   $0x0,0xf02b62ac
f0103b9f:	c6 05 ad 62 2b f0 8e 	movb   $0x8e,0xf02b62ad
f0103ba6:	c1 e8 10             	shr    $0x10,%eax
f0103ba9:	66 a3 ae 62 2b f0    	mov    %ax,0xf02b62ae
	SETGATE(idt[T_ILLOP], 0, GD_KT, ILLOP_HANDLER, 0);
f0103baf:	b8 a4 44 10 f0       	mov    $0xf01044a4,%eax
f0103bb4:	66 a3 b0 62 2b f0    	mov    %ax,0xf02b62b0
f0103bba:	66 c7 05 b2 62 2b f0 	movw   $0x8,0xf02b62b2
f0103bc1:	08 00 
f0103bc3:	c6 05 b4 62 2b f0 00 	movb   $0x0,0xf02b62b4
f0103bca:	c6 05 b5 62 2b f0 8e 	movb   $0x8e,0xf02b62b5
f0103bd1:	c1 e8 10             	shr    $0x10,%eax
f0103bd4:	66 a3 b6 62 2b f0    	mov    %ax,0xf02b62b6
	SETGATE(idt[T_DEVICE], 0, GD_KT, DEVICE_HANDLER, 0);
f0103bda:	b8 aa 44 10 f0       	mov    $0xf01044aa,%eax
f0103bdf:	66 a3 b8 62 2b f0    	mov    %ax,0xf02b62b8
f0103be5:	66 c7 05 ba 62 2b f0 	movw   $0x8,0xf02b62ba
f0103bec:	08 00 
f0103bee:	c6 05 bc 62 2b f0 00 	movb   $0x0,0xf02b62bc
f0103bf5:	c6 05 bd 62 2b f0 8e 	movb   $0x8e,0xf02b62bd
f0103bfc:	c1 e8 10             	shr    $0x10,%eax
f0103bff:	66 a3 be 62 2b f0    	mov    %ax,0xf02b62be
	SETGATE(idt[T_DBLFLT], 0, GD_KT, DBLFLT_HANDLER, 0);
f0103c05:	b8 b0 44 10 f0       	mov    $0xf01044b0,%eax
f0103c0a:	66 a3 c0 62 2b f0    	mov    %ax,0xf02b62c0
f0103c10:	66 c7 05 c2 62 2b f0 	movw   $0x8,0xf02b62c2
f0103c17:	08 00 
f0103c19:	c6 05 c4 62 2b f0 00 	movb   $0x0,0xf02b62c4
f0103c20:	c6 05 c5 62 2b f0 8e 	movb   $0x8e,0xf02b62c5
f0103c27:	c1 e8 10             	shr    $0x10,%eax
f0103c2a:	66 a3 c6 62 2b f0    	mov    %ax,0xf02b62c6
	SETGATE(idt[T_TSS], 0, GD_KT, TSS_HANDLER, 0);
f0103c30:	b8 b4 44 10 f0       	mov    $0xf01044b4,%eax
f0103c35:	66 a3 d0 62 2b f0    	mov    %ax,0xf02b62d0
f0103c3b:	66 c7 05 d2 62 2b f0 	movw   $0x8,0xf02b62d2
f0103c42:	08 00 
f0103c44:	c6 05 d4 62 2b f0 00 	movb   $0x0,0xf02b62d4
f0103c4b:	c6 05 d5 62 2b f0 8e 	movb   $0x8e,0xf02b62d5
f0103c52:	c1 e8 10             	shr    $0x10,%eax
f0103c55:	66 a3 d6 62 2b f0    	mov    %ax,0xf02b62d6
	SETGATE(idt[T_SEGNP], 0, GD_KT, SEGNP_HANDLER, 0);
f0103c5b:	b8 b8 44 10 f0       	mov    $0xf01044b8,%eax
f0103c60:	66 a3 d8 62 2b f0    	mov    %ax,0xf02b62d8
f0103c66:	66 c7 05 da 62 2b f0 	movw   $0x8,0xf02b62da
f0103c6d:	08 00 
f0103c6f:	c6 05 dc 62 2b f0 00 	movb   $0x0,0xf02b62dc
f0103c76:	c6 05 dd 62 2b f0 8e 	movb   $0x8e,0xf02b62dd
f0103c7d:	c1 e8 10             	shr    $0x10,%eax
f0103c80:	66 a3 de 62 2b f0    	mov    %ax,0xf02b62de
	SETGATE(idt[T_STACK], 0, GD_KT, STACK_HANDLER, 0);
f0103c86:	b8 bc 44 10 f0       	mov    $0xf01044bc,%eax
f0103c8b:	66 a3 e0 62 2b f0    	mov    %ax,0xf02b62e0
f0103c91:	66 c7 05 e2 62 2b f0 	movw   $0x8,0xf02b62e2
f0103c98:	08 00 
f0103c9a:	c6 05 e4 62 2b f0 00 	movb   $0x0,0xf02b62e4
f0103ca1:	c6 05 e5 62 2b f0 8e 	movb   $0x8e,0xf02b62e5
f0103ca8:	c1 e8 10             	shr    $0x10,%eax
f0103cab:	66 a3 e6 62 2b f0    	mov    %ax,0xf02b62e6
	SETGATE(idt[T_GPFLT], 0, GD_KT, GPFLT_HANDLER, 0);
f0103cb1:	b8 c0 44 10 f0       	mov    $0xf01044c0,%eax
f0103cb6:	66 a3 e8 62 2b f0    	mov    %ax,0xf02b62e8
f0103cbc:	66 c7 05 ea 62 2b f0 	movw   $0x8,0xf02b62ea
f0103cc3:	08 00 
f0103cc5:	c6 05 ec 62 2b f0 00 	movb   $0x0,0xf02b62ec
f0103ccc:	c6 05 ed 62 2b f0 8e 	movb   $0x8e,0xf02b62ed
f0103cd3:	c1 e8 10             	shr    $0x10,%eax
f0103cd6:	66 a3 ee 62 2b f0    	mov    %ax,0xf02b62ee
	SETGATE(idt[T_PGFLT], 0, GD_KT, PGFLT_HANDLER, 0);
f0103cdc:	b8 c4 44 10 f0       	mov    $0xf01044c4,%eax
f0103ce1:	66 a3 f0 62 2b f0    	mov    %ax,0xf02b62f0
f0103ce7:	66 c7 05 f2 62 2b f0 	movw   $0x8,0xf02b62f2
f0103cee:	08 00 
f0103cf0:	c6 05 f4 62 2b f0 00 	movb   $0x0,0xf02b62f4
f0103cf7:	c6 05 f5 62 2b f0 8e 	movb   $0x8e,0xf02b62f5
f0103cfe:	c1 e8 10             	shr    $0x10,%eax
f0103d01:	66 a3 f6 62 2b f0    	mov    %ax,0xf02b62f6
	SETGATE(idt[T_FPERR], 0, GD_KT, FPERR_HANDLER, 0);
f0103d07:	b8 c8 44 10 f0       	mov    $0xf01044c8,%eax
f0103d0c:	66 a3 00 63 2b f0    	mov    %ax,0xf02b6300
f0103d12:	66 c7 05 02 63 2b f0 	movw   $0x8,0xf02b6302
f0103d19:	08 00 
f0103d1b:	c6 05 04 63 2b f0 00 	movb   $0x0,0xf02b6304
f0103d22:	c6 05 05 63 2b f0 8e 	movb   $0x8e,0xf02b6305
f0103d29:	c1 e8 10             	shr    $0x10,%eax
f0103d2c:	66 a3 06 63 2b f0    	mov    %ax,0xf02b6306
	SETGATE(idt[T_ALIGN], 0, GD_KT, ALIGN_HANDLER, 0);
f0103d32:	b8 ce 44 10 f0       	mov    $0xf01044ce,%eax
f0103d37:	66 a3 08 63 2b f0    	mov    %ax,0xf02b6308
f0103d3d:	66 c7 05 0a 63 2b f0 	movw   $0x8,0xf02b630a
f0103d44:	08 00 
f0103d46:	c6 05 0c 63 2b f0 00 	movb   $0x0,0xf02b630c
f0103d4d:	c6 05 0d 63 2b f0 8e 	movb   $0x8e,0xf02b630d
f0103d54:	c1 e8 10             	shr    $0x10,%eax
f0103d57:	66 a3 0e 63 2b f0    	mov    %ax,0xf02b630e
	SETGATE(idt[T_MCHK], 0, GD_KT, MCHK_HANDLER, 0);
f0103d5d:	b8 d2 44 10 f0       	mov    $0xf01044d2,%eax
f0103d62:	66 a3 10 63 2b f0    	mov    %ax,0xf02b6310
f0103d68:	66 c7 05 12 63 2b f0 	movw   $0x8,0xf02b6312
f0103d6f:	08 00 
f0103d71:	c6 05 14 63 2b f0 00 	movb   $0x0,0xf02b6314
f0103d78:	c6 05 15 63 2b f0 8e 	movb   $0x8e,0xf02b6315
f0103d7f:	c1 e8 10             	shr    $0x10,%eax
f0103d82:	66 a3 16 63 2b f0    	mov    %ax,0xf02b6316
	SETGATE(idt[T_SIMDERR], 0, GD_KT, SIMDERR_HANDLER, 0);
f0103d88:	b8 d8 44 10 f0       	mov    $0xf01044d8,%eax
f0103d8d:	66 a3 18 63 2b f0    	mov    %ax,0xf02b6318
f0103d93:	66 c7 05 1a 63 2b f0 	movw   $0x8,0xf02b631a
f0103d9a:	08 00 
f0103d9c:	c6 05 1c 63 2b f0 00 	movb   $0x0,0xf02b631c
f0103da3:	c6 05 1d 63 2b f0 8e 	movb   $0x8e,0xf02b631d
f0103daa:	c1 e8 10             	shr    $0x10,%eax
f0103dad:	66 a3 1e 63 2b f0    	mov    %ax,0xf02b631e
	SETGATE(idt[T_SYSCALL], 0 , GD_KT, SYSCALL_HANDLER, 3);//需要将dpl设置为3,因为这是用户态下调用的系统调用（中断）
f0103db3:	b8 de 44 10 f0       	mov    $0xf01044de,%eax
f0103db8:	66 a3 00 64 2b f0    	mov    %ax,0xf02b6400
f0103dbe:	66 c7 05 02 64 2b f0 	movw   $0x8,0xf02b6402
f0103dc5:	08 00 
f0103dc7:	c6 05 04 64 2b f0 00 	movb   $0x0,0xf02b6404
f0103dce:	c6 05 05 64 2b f0 ee 	movb   $0xee,0xf02b6405
f0103dd5:	c1 e8 10             	shr    $0x10,%eax
f0103dd8:	66 a3 06 64 2b f0    	mov    %ax,0xf02b6406
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],    0, GD_KT, timer_handler,   0);//中断是让内核抢占控制权，所以dpl应该设置为0。
f0103dde:	b8 e4 44 10 f0       	mov    $0xf01044e4,%eax
f0103de3:	66 a3 80 63 2b f0    	mov    %ax,0xf02b6380
f0103de9:	66 c7 05 82 63 2b f0 	movw   $0x8,0xf02b6382
f0103df0:	08 00 
f0103df2:	c6 05 84 63 2b f0 00 	movb   $0x0,0xf02b6384
f0103df9:	c6 05 85 63 2b f0 8e 	movb   $0x8e,0xf02b6385
f0103e00:	c1 e8 10             	shr    $0x10,%eax
f0103e03:	66 a3 86 63 2b f0    	mov    %ax,0xf02b6386
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD],      0, GD_KT, kbd_handler,     0);
f0103e09:	b8 ea 44 10 f0       	mov    $0xf01044ea,%eax
f0103e0e:	66 a3 88 63 2b f0    	mov    %ax,0xf02b6388
f0103e14:	66 c7 05 8a 63 2b f0 	movw   $0x8,0xf02b638a
f0103e1b:	08 00 
f0103e1d:	c6 05 8c 63 2b f0 00 	movb   $0x0,0xf02b638c
f0103e24:	c6 05 8d 63 2b f0 8e 	movb   $0x8e,0xf02b638d
f0103e2b:	c1 e8 10             	shr    $0x10,%eax
f0103e2e:	66 a3 8e 63 2b f0    	mov    %ax,0xf02b638e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL],   0, GD_KT, serial_handler,  0);
f0103e34:	b8 f0 44 10 f0       	mov    $0xf01044f0,%eax
f0103e39:	66 a3 a0 63 2b f0    	mov    %ax,0xf02b63a0
f0103e3f:	66 c7 05 a2 63 2b f0 	movw   $0x8,0xf02b63a2
f0103e46:	08 00 
f0103e48:	c6 05 a4 63 2b f0 00 	movb   $0x0,0xf02b63a4
f0103e4f:	c6 05 a5 63 2b f0 8e 	movb   $0x8e,0xf02b63a5
f0103e56:	c1 e8 10             	shr    $0x10,%eax
f0103e59:	66 a3 a6 63 2b f0    	mov    %ax,0xf02b63a6
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, spurious_handler,0);
f0103e5f:	b8 f6 44 10 f0       	mov    $0xf01044f6,%eax
f0103e64:	66 a3 b8 63 2b f0    	mov    %ax,0xf02b63b8
f0103e6a:	66 c7 05 ba 63 2b f0 	movw   $0x8,0xf02b63ba
f0103e71:	08 00 
f0103e73:	c6 05 bc 63 2b f0 00 	movb   $0x0,0xf02b63bc
f0103e7a:	c6 05 bd 63 2b f0 8e 	movb   $0x8e,0xf02b63bd
f0103e81:	c1 e8 10             	shr    $0x10,%eax
f0103e84:	66 a3 be 63 2b f0    	mov    %ax,0xf02b63be
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE],      0, GD_KT, ide_handler,     0);
f0103e8a:	b8 fc 44 10 f0       	mov    $0xf01044fc,%eax
f0103e8f:	66 a3 f0 63 2b f0    	mov    %ax,0xf02b63f0
f0103e95:	66 c7 05 f2 63 2b f0 	movw   $0x8,0xf02b63f2
f0103e9c:	08 00 
f0103e9e:	c6 05 f4 63 2b f0 00 	movb   $0x0,0xf02b63f4
f0103ea5:	c6 05 f5 63 2b f0 8e 	movb   $0x8e,0xf02b63f5
f0103eac:	c1 e8 10             	shr    $0x10,%eax
f0103eaf:	66 a3 f6 63 2b f0    	mov    %ax,0xf02b63f6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR],    0, GD_KT, error_handler,   0);
f0103eb5:	b8 02 45 10 f0       	mov    $0xf0104502,%eax
f0103eba:	66 a3 18 64 2b f0    	mov    %ax,0xf02b6418
f0103ec0:	66 c7 05 1a 64 2b f0 	movw   $0x8,0xf02b641a
f0103ec7:	08 00 
f0103ec9:	c6 05 1c 64 2b f0 00 	movb   $0x0,0xf02b641c
f0103ed0:	c6 05 1d 64 2b f0 8e 	movb   $0x8e,0xf02b641d
f0103ed7:	c1 e8 10             	shr    $0x10,%eax
f0103eda:	66 a3 1e 64 2b f0    	mov    %ax,0xf02b641e
	trap_init_percpu();
f0103ee0:	e8 e4 fa ff ff       	call   f01039c9 <trap_init_percpu>
}
f0103ee5:	c9                   	leave  
f0103ee6:	c3                   	ret    

f0103ee7 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103ee7:	55                   	push   %ebp
f0103ee8:	89 e5                	mov    %esp,%ebp
f0103eea:	53                   	push   %ebx
f0103eeb:	83 ec 0c             	sub    $0xc,%esp
f0103eee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103ef1:	ff 33                	push   (%ebx)
f0103ef3:	68 a4 80 10 f0       	push   $0xf01080a4
f0103ef8:	e8 b8 fa ff ff       	call   f01039b5 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103efd:	83 c4 08             	add    $0x8,%esp
f0103f00:	ff 73 04             	push   0x4(%ebx)
f0103f03:	68 b3 80 10 f0       	push   $0xf01080b3
f0103f08:	e8 a8 fa ff ff       	call   f01039b5 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103f0d:	83 c4 08             	add    $0x8,%esp
f0103f10:	ff 73 08             	push   0x8(%ebx)
f0103f13:	68 c2 80 10 f0       	push   $0xf01080c2
f0103f18:	e8 98 fa ff ff       	call   f01039b5 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103f1d:	83 c4 08             	add    $0x8,%esp
f0103f20:	ff 73 0c             	push   0xc(%ebx)
f0103f23:	68 d1 80 10 f0       	push   $0xf01080d1
f0103f28:	e8 88 fa ff ff       	call   f01039b5 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103f2d:	83 c4 08             	add    $0x8,%esp
f0103f30:	ff 73 10             	push   0x10(%ebx)
f0103f33:	68 e0 80 10 f0       	push   $0xf01080e0
f0103f38:	e8 78 fa ff ff       	call   f01039b5 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103f3d:	83 c4 08             	add    $0x8,%esp
f0103f40:	ff 73 14             	push   0x14(%ebx)
f0103f43:	68 ef 80 10 f0       	push   $0xf01080ef
f0103f48:	e8 68 fa ff ff       	call   f01039b5 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103f4d:	83 c4 08             	add    $0x8,%esp
f0103f50:	ff 73 18             	push   0x18(%ebx)
f0103f53:	68 fe 80 10 f0       	push   $0xf01080fe
f0103f58:	e8 58 fa ff ff       	call   f01039b5 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103f5d:	83 c4 08             	add    $0x8,%esp
f0103f60:	ff 73 1c             	push   0x1c(%ebx)
f0103f63:	68 0d 81 10 f0       	push   $0xf010810d
f0103f68:	e8 48 fa ff ff       	call   f01039b5 <cprintf>
}
f0103f6d:	83 c4 10             	add    $0x10,%esp
f0103f70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103f73:	c9                   	leave  
f0103f74:	c3                   	ret    

f0103f75 <print_trapframe>:
{
f0103f75:	55                   	push   %ebp
f0103f76:	89 e5                	mov    %esp,%ebp
f0103f78:	56                   	push   %esi
f0103f79:	53                   	push   %ebx
f0103f7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103f7d:	e8 e2 1e 00 00       	call   f0105e64 <cpunum>
f0103f82:	83 ec 04             	sub    $0x4,%esp
f0103f85:	50                   	push   %eax
f0103f86:	53                   	push   %ebx
f0103f87:	68 71 81 10 f0       	push   $0xf0108171
f0103f8c:	e8 24 fa ff ff       	call   f01039b5 <cprintf>
	print_regs(&tf->tf_regs);
f0103f91:	89 1c 24             	mov    %ebx,(%esp)
f0103f94:	e8 4e ff ff ff       	call   f0103ee7 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103f99:	83 c4 08             	add    $0x8,%esp
f0103f9c:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103fa0:	50                   	push   %eax
f0103fa1:	68 8f 81 10 f0       	push   $0xf010818f
f0103fa6:	e8 0a fa ff ff       	call   f01039b5 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103fab:	83 c4 08             	add    $0x8,%esp
f0103fae:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103fb2:	50                   	push   %eax
f0103fb3:	68 a2 81 10 f0       	push   $0xf01081a2
f0103fb8:	e8 f8 f9 ff ff       	call   f01039b5 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103fbd:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103fc0:	83 c4 10             	add    $0x10,%esp
f0103fc3:	83 f8 13             	cmp    $0x13,%eax
f0103fc6:	0f 86 da 00 00 00    	jbe    f01040a6 <print_trapframe+0x131>
		return "System call";
f0103fcc:	ba 1c 81 10 f0       	mov    $0xf010811c,%edx
	if (trapno == T_SYSCALL)
f0103fd1:	83 f8 30             	cmp    $0x30,%eax
f0103fd4:	74 13                	je     f0103fe9 <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103fd6:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0103fd9:	83 fa 0f             	cmp    $0xf,%edx
f0103fdc:	ba 28 81 10 f0       	mov    $0xf0108128,%edx
f0103fe1:	b9 37 81 10 f0       	mov    $0xf0108137,%ecx
f0103fe6:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103fe9:	83 ec 04             	sub    $0x4,%esp
f0103fec:	52                   	push   %edx
f0103fed:	50                   	push   %eax
f0103fee:	68 b5 81 10 f0       	push   $0xf01081b5
f0103ff3:	e8 bd f9 ff ff       	call   f01039b5 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103ff8:	83 c4 10             	add    $0x10,%esp
f0103ffb:	39 1d 80 6a 2b f0    	cmp    %ebx,0xf02b6a80
f0104001:	0f 84 ab 00 00 00    	je     f01040b2 <print_trapframe+0x13d>
	cprintf("  err  0x%08x", tf->tf_err);
f0104007:	83 ec 08             	sub    $0x8,%esp
f010400a:	ff 73 2c             	push   0x2c(%ebx)
f010400d:	68 d6 81 10 f0       	push   $0xf01081d6
f0104012:	e8 9e f9 ff ff       	call   f01039b5 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104017:	83 c4 10             	add    $0x10,%esp
f010401a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010401e:	0f 85 b1 00 00 00    	jne    f01040d5 <print_trapframe+0x160>
			tf->tf_err & 1 ? "protection" : "not-present");
f0104024:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0104027:	a8 01                	test   $0x1,%al
f0104029:	b9 4a 81 10 f0       	mov    $0xf010814a,%ecx
f010402e:	ba 55 81 10 f0       	mov    $0xf0108155,%edx
f0104033:	0f 44 ca             	cmove  %edx,%ecx
f0104036:	a8 02                	test   $0x2,%al
f0104038:	ba 61 81 10 f0       	mov    $0xf0108161,%edx
f010403d:	be 67 81 10 f0       	mov    $0xf0108167,%esi
f0104042:	0f 44 d6             	cmove  %esi,%edx
f0104045:	a8 04                	test   $0x4,%al
f0104047:	b8 6c 81 10 f0       	mov    $0xf010816c,%eax
f010404c:	be a1 82 10 f0       	mov    $0xf01082a1,%esi
f0104051:	0f 44 c6             	cmove  %esi,%eax
f0104054:	51                   	push   %ecx
f0104055:	52                   	push   %edx
f0104056:	50                   	push   %eax
f0104057:	68 e4 81 10 f0       	push   $0xf01081e4
f010405c:	e8 54 f9 ff ff       	call   f01039b5 <cprintf>
f0104061:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104064:	83 ec 08             	sub    $0x8,%esp
f0104067:	ff 73 30             	push   0x30(%ebx)
f010406a:	68 f3 81 10 f0       	push   $0xf01081f3
f010406f:	e8 41 f9 ff ff       	call   f01039b5 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104074:	83 c4 08             	add    $0x8,%esp
f0104077:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010407b:	50                   	push   %eax
f010407c:	68 02 82 10 f0       	push   $0xf0108202
f0104081:	e8 2f f9 ff ff       	call   f01039b5 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104086:	83 c4 08             	add    $0x8,%esp
f0104089:	ff 73 38             	push   0x38(%ebx)
f010408c:	68 15 82 10 f0       	push   $0xf0108215
f0104091:	e8 1f f9 ff ff       	call   f01039b5 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104096:	83 c4 10             	add    $0x10,%esp
f0104099:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010409d:	75 4b                	jne    f01040ea <print_trapframe+0x175>
}
f010409f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01040a2:	5b                   	pop    %ebx
f01040a3:	5e                   	pop    %esi
f01040a4:	5d                   	pop    %ebp
f01040a5:	c3                   	ret    
		return excnames[trapno];
f01040a6:	8b 14 85 00 85 10 f0 	mov    -0xfef7b00(,%eax,4),%edx
f01040ad:	e9 37 ff ff ff       	jmp    f0103fe9 <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01040b2:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01040b6:	0f 85 4b ff ff ff    	jne    f0104007 <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01040bc:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01040bf:	83 ec 08             	sub    $0x8,%esp
f01040c2:	50                   	push   %eax
f01040c3:	68 c7 81 10 f0       	push   $0xf01081c7
f01040c8:	e8 e8 f8 ff ff       	call   f01039b5 <cprintf>
f01040cd:	83 c4 10             	add    $0x10,%esp
f01040d0:	e9 32 ff ff ff       	jmp    f0104007 <print_trapframe+0x92>
		cprintf("\n");
f01040d5:	83 ec 0c             	sub    $0xc,%esp
f01040d8:	68 b3 75 10 f0       	push   $0xf01075b3
f01040dd:	e8 d3 f8 ff ff       	call   f01039b5 <cprintf>
f01040e2:	83 c4 10             	add    $0x10,%esp
f01040e5:	e9 7a ff ff ff       	jmp    f0104064 <print_trapframe+0xef>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01040ea:	83 ec 08             	sub    $0x8,%esp
f01040ed:	ff 73 3c             	push   0x3c(%ebx)
f01040f0:	68 24 82 10 f0       	push   $0xf0108224
f01040f5:	e8 bb f8 ff ff       	call   f01039b5 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01040fa:	83 c4 08             	add    $0x8,%esp
f01040fd:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104101:	50                   	push   %eax
f0104102:	68 33 82 10 f0       	push   $0xf0108233
f0104107:	e8 a9 f8 ff ff       	call   f01039b5 <cprintf>
f010410c:	83 c4 10             	add    $0x10,%esp
}
f010410f:	eb 8e                	jmp    f010409f <print_trapframe+0x12a>

f0104111 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104111:	55                   	push   %ebp
f0104112:	89 e5                	mov    %esp,%ebp
f0104114:	57                   	push   %edi
f0104115:	56                   	push   %esi
f0104116:	53                   	push   %ebx
f0104117:	83 ec 0c             	sub    $0xc,%esp
f010411a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010411d:	0f 20 d6             	mov    %cr2,%esi
	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	// LAB 3: Your code here.  CPL为0时，为内核态。
	if( (tf->tf_cs & 3) == 0) panic("page_fault in kernel mode, fault address %u\n", fault_va);
f0104120:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104124:	74 5d                	je     f0104183 <page_fault_handler+0x72>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.
	//注意， 其实并没有切换环境！！
	if (curenv->env_pgfault_upcall){
f0104126:	e8 39 1d 00 00       	call   f0105e64 <cpunum>
f010412b:	6b c0 74             	imul   $0x74,%eax,%eax
f010412e:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f0104134:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104138:	75 5e                	jne    f0104198 <page_fault_handler+0x87>
		curenv->env_tf.tf_esp        = (uint32_t) utf;

		env_run(curenv);
	}else{
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010413a:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f010413d:	e8 22 1d 00 00       	call   f0105e64 <cpunum>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104142:	57                   	push   %edi
f0104143:	56                   	push   %esi
			curenv->env_id, fault_va, tf->tf_eip);
f0104144:	6b c0 74             	imul   $0x74,%eax,%eax
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104147:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f010414d:	ff 70 48             	push   0x48(%eax)
f0104150:	68 1c 84 10 f0       	push   $0xf010841c
f0104155:	e8 5b f8 ff ff       	call   f01039b5 <cprintf>
		print_trapframe(tf);
f010415a:	89 1c 24             	mov    %ebx,(%esp)
f010415d:	e8 13 fe ff ff       	call   f0103f75 <print_trapframe>
		env_destroy(curenv);	
f0104162:	e8 fd 1c 00 00       	call   f0105e64 <cpunum>
f0104167:	83 c4 04             	add    $0x4,%esp
f010416a:	6b c0 74             	imul   $0x74,%eax,%eax
f010416d:	ff b0 28 70 2f f0    	push   -0xfd08fd8(%eax)
f0104173:	e8 f1 f4 ff ff       	call   f0103669 <env_destroy>
	}
}
f0104178:	83 c4 10             	add    $0x10,%esp
f010417b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010417e:	5b                   	pop    %ebx
f010417f:	5e                   	pop    %esi
f0104180:	5f                   	pop    %edi
f0104181:	5d                   	pop    %ebp
f0104182:	c3                   	ret    
	if( (tf->tf_cs & 3) == 0) panic("page_fault in kernel mode, fault address %u\n", fault_va);
f0104183:	56                   	push   %esi
f0104184:	68 ec 83 10 f0       	push   $0xf01083ec
f0104189:	68 84 01 00 00       	push   $0x184
f010418e:	68 46 82 10 f0       	push   $0xf0108246
f0104193:	e8 a8 be ff ff       	call   f0100040 <_panic>
		if(UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1) // 发生异常时陷入。
f0104198:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010419b:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f01041a1:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
		if(UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1) // 发生异常时陷入。
f01041a6:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01041ac:	77 05                	ja     f01041b3 <page_fault_handler+0xa2>
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);//要求的32位空字。
f01041ae:	83 e8 38             	sub    $0x38,%eax
f01041b1:	89 c7                	mov    %eax,%edi
		user_mem_assert(curenv, (const void *) utf, sizeof(struct UTrapframe), PTE_P|PTE_W);
f01041b3:	e8 ac 1c 00 00       	call   f0105e64 <cpunum>
f01041b8:	6a 03                	push   $0x3
f01041ba:	6a 34                	push   $0x34
f01041bc:	57                   	push   %edi
f01041bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01041c0:	ff b0 28 70 2f f0    	push   -0xfd08fd8(%eax)
f01041c6:	e8 0d ee ff ff       	call   f0102fd8 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f01041cb:	89 fa                	mov    %edi,%edx
f01041cd:	89 37                	mov    %esi,(%edi)
		utf->utf_err      = tf->tf_trapno;
f01041cf:	8b 43 28             	mov    0x28(%ebx),%eax
f01041d2:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs     = tf->tf_regs;
f01041d5:	8d 7f 08             	lea    0x8(%edi),%edi
f01041d8:	b9 08 00 00 00       	mov    $0x8,%ecx
f01041dd:	89 de                	mov    %ebx,%esi
f01041df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eflags   = tf->tf_eflags;
f01041e1:	8b 43 38             	mov    0x38(%ebx),%eax
f01041e4:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_eip      = tf->tf_eip;
f01041e7:	8b 43 30             	mov    0x30(%ebx),%eax
f01041ea:	89 d7                	mov    %edx,%edi
f01041ec:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_esp      = tf->tf_esp;
f01041ef:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01041f2:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uint32_t) curenv->env_pgfault_upcall;
f01041f5:	e8 6a 1c 00 00       	call   f0105e64 <cpunum>
f01041fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01041fd:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f0104203:	8b 58 64             	mov    0x64(%eax),%ebx
f0104206:	e8 59 1c 00 00       	call   f0105e64 <cpunum>
f010420b:	6b c0 74             	imul   $0x74,%eax,%eax
f010420e:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f0104214:	89 58 30             	mov    %ebx,0x30(%eax)
		curenv->env_tf.tf_esp        = (uint32_t) utf;
f0104217:	e8 48 1c 00 00       	call   f0105e64 <cpunum>
f010421c:	6b c0 74             	imul   $0x74,%eax,%eax
f010421f:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f0104225:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f0104228:	e8 37 1c 00 00       	call   f0105e64 <cpunum>
f010422d:	83 c4 04             	add    $0x4,%esp
f0104230:	6b c0 74             	imul   $0x74,%eax,%eax
f0104233:	ff b0 28 70 2f f0    	push   -0xfd08fd8(%eax)
f0104239:	e8 ca f4 ff ff       	call   f0103708 <env_run>

f010423e <trap>:
{
f010423e:	55                   	push   %ebp
f010423f:	89 e5                	mov    %esp,%ebp
f0104241:	57                   	push   %edi
f0104242:	56                   	push   %esi
f0104243:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0104246:	fc                   	cld    
	if (panicstr)
f0104247:	83 3d 00 60 2b f0 00 	cmpl   $0x0,0xf02b6000
f010424e:	74 01                	je     f0104251 <trap+0x13>
		asm volatile("hlt");
f0104250:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104251:	e8 0e 1c 00 00       	call   f0105e64 <cpunum>
f0104256:	6b d0 74             	imul   $0x74,%eax,%edx
f0104259:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f010425c:	b8 01 00 00 00       	mov    $0x1,%eax
f0104261:	f0 87 82 20 70 2f f0 	lock xchg %eax,-0xfd08fe0(%edx)
f0104268:	83 f8 02             	cmp    $0x2,%eax
f010426b:	74 30                	je     f010429d <trap+0x5f>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010426d:	9c                   	pushf  
f010426e:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f010426f:	f6 c4 02             	test   $0x2,%ah
f0104272:	75 3b                	jne    f01042af <trap+0x71>
	if ((tf->tf_cs & 3) == 3) {
f0104274:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104278:	83 e0 03             	and    $0x3,%eax
f010427b:	66 83 f8 03          	cmp    $0x3,%ax
f010427f:	74 47                	je     f01042c8 <trap+0x8a>
	last_tf = tf;
f0104281:	89 35 80 6a 2b f0    	mov    %esi,0xf02b6a80
	switch(tf->tf_trapno) 
f0104287:	8b 46 28             	mov    0x28(%esi),%eax
f010428a:	83 e8 03             	sub    $0x3,%eax
f010428d:	83 f8 2d             	cmp    $0x2d,%eax
f0104290:	0f 87 87 01 00 00    	ja     f010441d <trap+0x1df>
f0104296:	ff 24 85 40 84 10 f0 	jmp    *-0xfef7bc0(,%eax,4)
	spin_lock(&kernel_lock);
f010429d:	83 ec 0c             	sub    $0xc,%esp
f01042a0:	68 c0 83 12 f0       	push   $0xf01283c0
f01042a5:	e8 2a 1e 00 00       	call   f01060d4 <spin_lock>
}
f01042aa:	83 c4 10             	add    $0x10,%esp
f01042ad:	eb be                	jmp    f010426d <trap+0x2f>
	assert(!(read_eflags() & FL_IF));
f01042af:	68 52 82 10 f0       	push   $0xf0108252
f01042b4:	68 d5 72 10 f0       	push   $0xf01072d5
f01042b9:	68 4f 01 00 00       	push   $0x14f
f01042be:	68 46 82 10 f0       	push   $0xf0108246
f01042c3:	e8 78 bd ff ff       	call   f0100040 <_panic>
	spin_lock(&kernel_lock);
f01042c8:	83 ec 0c             	sub    $0xc,%esp
f01042cb:	68 c0 83 12 f0       	push   $0xf01283c0
f01042d0:	e8 ff 1d 00 00       	call   f01060d4 <spin_lock>
		assert(curenv);
f01042d5:	e8 8a 1b 00 00       	call   f0105e64 <cpunum>
f01042da:	6b c0 74             	imul   $0x74,%eax,%eax
f01042dd:	83 c4 10             	add    $0x10,%esp
f01042e0:	83 b8 28 70 2f f0 00 	cmpl   $0x0,-0xfd08fd8(%eax)
f01042e7:	74 3e                	je     f0104327 <trap+0xe9>
		if (curenv->env_status == ENV_DYING) {
f01042e9:	e8 76 1b 00 00       	call   f0105e64 <cpunum>
f01042ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f1:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f01042f7:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01042fb:	74 43                	je     f0104340 <trap+0x102>
		curenv->env_tf = *tf;
f01042fd:	e8 62 1b 00 00       	call   f0105e64 <cpunum>
f0104302:	6b c0 74             	imul   $0x74,%eax,%eax
f0104305:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f010430b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104310:	89 c7                	mov    %eax,%edi
f0104312:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104314:	e8 4b 1b 00 00       	call   f0105e64 <cpunum>
f0104319:	6b c0 74             	imul   $0x74,%eax,%eax
f010431c:	8b b0 28 70 2f f0    	mov    -0xfd08fd8(%eax),%esi
f0104322:	e9 5a ff ff ff       	jmp    f0104281 <trap+0x43>
		assert(curenv);
f0104327:	68 6b 82 10 f0       	push   $0xf010826b
f010432c:	68 d5 72 10 f0       	push   $0xf01072d5
f0104331:	68 58 01 00 00       	push   $0x158
f0104336:	68 46 82 10 f0       	push   $0xf0108246
f010433b:	e8 00 bd ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f0104340:	e8 1f 1b 00 00       	call   f0105e64 <cpunum>
f0104345:	83 ec 0c             	sub    $0xc,%esp
f0104348:	6b c0 74             	imul   $0x74,%eax,%eax
f010434b:	ff b0 28 70 2f f0    	push   -0xfd08fd8(%eax)
f0104351:	e8 69 f1 ff ff       	call   f01034bf <env_free>
			curenv = NULL;
f0104356:	e8 09 1b 00 00       	call   f0105e64 <cpunum>
f010435b:	6b c0 74             	imul   $0x74,%eax,%eax
f010435e:	c7 80 28 70 2f f0 00 	movl   $0x0,-0xfd08fd8(%eax)
f0104365:	00 00 00 
			sched_yield();
f0104368:	e8 76 02 00 00       	call   f01045e3 <sched_yield>
			page_fault_handler(tf);
f010436d:	83 ec 0c             	sub    $0xc,%esp
f0104370:	56                   	push   %esi
f0104371:	e8 9b fd ff ff       	call   f0104111 <page_fault_handler>
			break; 
f0104376:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104379:	e8 e6 1a 00 00       	call   f0105e64 <cpunum>
f010437e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104381:	83 b8 28 70 2f f0 00 	cmpl   $0x0,-0xfd08fd8(%eax)
f0104388:	74 18                	je     f01043a2 <trap+0x164>
f010438a:	e8 d5 1a 00 00       	call   f0105e64 <cpunum>
f010438f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104392:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f0104398:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010439c:	0f 84 c3 00 00 00    	je     f0104465 <trap+0x227>
		sched_yield();
f01043a2:	e8 3c 02 00 00       	call   f01045e3 <sched_yield>
			monitor(tf);
f01043a7:	83 ec 0c             	sub    $0xc,%esp
f01043aa:	56                   	push   %esi
f01043ab:	e8 da c5 ff ff       	call   f010098a <monitor>
			break;
f01043b0:	83 c4 10             	add    $0x10,%esp
f01043b3:	eb c4                	jmp    f0104379 <trap+0x13b>
			int32_t ret=syscall(tf->tf_regs.reg_eax, /*lab的文档中说应用程序将在寄存器中传递系统调用编号和系统调用参数。这样，内核就不需要遍历用户环境的栈或指令流。系统调用编号将进入%eax。但是在哪里实现的? 我也不清楚 在 lib/syscall.c中实现的！！！*/
f01043b5:	83 ec 08             	sub    $0x8,%esp
f01043b8:	ff 76 04             	push   0x4(%esi)
f01043bb:	ff 36                	push   (%esi)
f01043bd:	ff 76 10             	push   0x10(%esi)
f01043c0:	ff 76 18             	push   0x18(%esi)
f01043c3:	ff 76 14             	push   0x14(%esi)
f01043c6:	ff 76 1c             	push   0x1c(%esi)
f01043c9:	e8 9c 02 00 00       	call   f010466a <syscall>
			tf->tf_regs.reg_eax = ret;//将返回值传递回%eax，其将被传递回用户进程
f01043ce:	89 46 1c             	mov    %eax,0x1c(%esi)
			break;
f01043d1:	83 c4 20             	add    $0x20,%esp
f01043d4:	eb a3                	jmp    f0104379 <trap+0x13b>
			cprintf("Spurious interrupt on irq 7\n");
f01043d6:	83 ec 0c             	sub    $0xc,%esp
f01043d9:	68 72 82 10 f0       	push   $0xf0108272
f01043de:	e8 d2 f5 ff ff       	call   f01039b5 <cprintf>
			print_trapframe(tf);
f01043e3:	89 34 24             	mov    %esi,(%esp)
f01043e6:	e8 8a fb ff ff       	call   f0103f75 <print_trapframe>
			break;
f01043eb:	83 c4 10             	add    $0x10,%esp
f01043ee:	eb 89                	jmp    f0104379 <trap+0x13b>
			lapic_eoi();
f01043f0:	e8 b6 1b 00 00       	call   f0105fab <lapic_eoi>
			time_tick();
f01043f5:	e8 ba 26 00 00       	call   f0106ab4 <time_tick>
			sched_yield();//时间片到达，切换环境
f01043fa:	e8 e4 01 00 00       	call   f01045e3 <sched_yield>
			lapic_eoi();
f01043ff:	e8 a7 1b 00 00       	call   f0105fab <lapic_eoi>
			kbd_intr();
f0104404:	e8 f9 c1 ff ff       	call   f0100602 <kbd_intr>
			break;
f0104409:	e9 6b ff ff ff       	jmp    f0104379 <trap+0x13b>
			lapic_eoi();
f010440e:	e8 98 1b 00 00       	call   f0105fab <lapic_eoi>
			serial_intr();
f0104413:	e8 ce c1 ff ff       	call   f01005e6 <serial_intr>
			break;
f0104418:	e9 5c ff ff ff       	jmp    f0104379 <trap+0x13b>
			print_trapframe(tf);
f010441d:	83 ec 0c             	sub    $0xc,%esp
f0104420:	56                   	push   %esi
f0104421:	e8 4f fb ff ff       	call   f0103f75 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f0104426:	83 c4 10             	add    $0x10,%esp
f0104429:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010442e:	74 1e                	je     f010444e <trap+0x210>
				env_destroy(curenv);
f0104430:	e8 2f 1a 00 00       	call   f0105e64 <cpunum>
f0104435:	83 ec 0c             	sub    $0xc,%esp
f0104438:	6b c0 74             	imul   $0x74,%eax,%eax
f010443b:	ff b0 28 70 2f f0    	push   -0xfd08fd8(%eax)
f0104441:	e8 23 f2 ff ff       	call   f0103669 <env_destroy>
				return;
f0104446:	83 c4 10             	add    $0x10,%esp
f0104449:	e9 2b ff ff ff       	jmp    f0104379 <trap+0x13b>
				panic("unhandled trap in kernel");
f010444e:	83 ec 04             	sub    $0x4,%esp
f0104451:	68 8f 82 10 f0       	push   $0xf010828f
f0104456:	68 30 01 00 00       	push   $0x130
f010445b:	68 46 82 10 f0       	push   $0xf0108246
f0104460:	e8 db bb ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f0104465:	e8 fa 19 00 00       	call   f0105e64 <cpunum>
f010446a:	83 ec 0c             	sub    $0xc,%esp
f010446d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104470:	ff b0 28 70 2f f0    	push   -0xfd08fd8(%eax)
f0104476:	e8 8d f2 ff ff       	call   f0103708 <env_run>
f010447b:	90                   	nop

f010447c <DIVIDE_HANDLER>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 //参见练习3中的 9.1 、9.10中的表，以及inc/trap.h 来完成这一部分。
TRAPHANDLER_NOEC(DIVIDE_HANDLER, T_DIVIDE);
f010447c:	6a 00                	push   $0x0
f010447e:	6a 00                	push   $0x0
f0104480:	e9 83 00 00 00       	jmp    f0104508 <_alltraps>
f0104485:	90                   	nop

f0104486 <DEBUG_HANDLER>:
TRAPHANDLER_NOEC(DEBUG_HANDLER, T_DEBUG);
f0104486:	6a 00                	push   $0x0
f0104488:	6a 01                	push   $0x1
f010448a:	eb 7c                	jmp    f0104508 <_alltraps>

f010448c <NMI_HANDLER>:
TRAPHANDLER_NOEC(NMI_HANDLER, T_NMI);
f010448c:	6a 00                	push   $0x0
f010448e:	6a 02                	push   $0x2
f0104490:	eb 76                	jmp    f0104508 <_alltraps>

f0104492 <BRKPT_HANDLER>:
TRAPHANDLER_NOEC(BRKPT_HANDLER, T_BRKPT);
f0104492:	6a 00                	push   $0x0
f0104494:	6a 03                	push   $0x3
f0104496:	eb 70                	jmp    f0104508 <_alltraps>

f0104498 <OFLOW_HANDLER>:
TRAPHANDLER_NOEC(OFLOW_HANDLER, T_OFLOW);
f0104498:	6a 00                	push   $0x0
f010449a:	6a 04                	push   $0x4
f010449c:	eb 6a                	jmp    f0104508 <_alltraps>

f010449e <BOUND_HANDLER>:
TRAPHANDLER_NOEC(BOUND_HANDLER, T_BOUND);
f010449e:	6a 00                	push   $0x0
f01044a0:	6a 05                	push   $0x5
f01044a2:	eb 64                	jmp    f0104508 <_alltraps>

f01044a4 <ILLOP_HANDLER>:
TRAPHANDLER_NOEC(ILLOP_HANDLER, T_ILLOP);
f01044a4:	6a 00                	push   $0x0
f01044a6:	6a 06                	push   $0x6
f01044a8:	eb 5e                	jmp    f0104508 <_alltraps>

f01044aa <DEVICE_HANDLER>:
TRAPHANDLER_NOEC(DEVICE_HANDLER, T_DEVICE);
f01044aa:	6a 00                	push   $0x0
f01044ac:	6a 07                	push   $0x7
f01044ae:	eb 58                	jmp    f0104508 <_alltraps>

f01044b0 <DBLFLT_HANDLER>:
TRAPHANDLER(DBLFLT_HANDLER, T_DBLFLT);
f01044b0:	6a 08                	push   $0x8
f01044b2:	eb 54                	jmp    f0104508 <_alltraps>

f01044b4 <TSS_HANDLER>:
/* reserved */
TRAPHANDLER(TSS_HANDLER, T_TSS);
f01044b4:	6a 0a                	push   $0xa
f01044b6:	eb 50                	jmp    f0104508 <_alltraps>

f01044b8 <SEGNP_HANDLER>:
TRAPHANDLER(SEGNP_HANDLER, T_SEGNP);
f01044b8:	6a 0b                	push   $0xb
f01044ba:	eb 4c                	jmp    f0104508 <_alltraps>

f01044bc <STACK_HANDLER>:
TRAPHANDLER(STACK_HANDLER, T_STACK);
f01044bc:	6a 0c                	push   $0xc
f01044be:	eb 48                	jmp    f0104508 <_alltraps>

f01044c0 <GPFLT_HANDLER>:
TRAPHANDLER(GPFLT_HANDLER, T_GPFLT);
f01044c0:	6a 0d                	push   $0xd
f01044c2:	eb 44                	jmp    f0104508 <_alltraps>

f01044c4 <PGFLT_HANDLER>:
TRAPHANDLER(PGFLT_HANDLER, T_PGFLT);
f01044c4:	6a 0e                	push   $0xe
f01044c6:	eb 40                	jmp    f0104508 <_alltraps>

f01044c8 <FPERR_HANDLER>:
/* reserved */
TRAPHANDLER_NOEC(FPERR_HANDLER, T_FPERR);
f01044c8:	6a 00                	push   $0x0
f01044ca:	6a 10                	push   $0x10
f01044cc:	eb 3a                	jmp    f0104508 <_alltraps>

f01044ce <ALIGN_HANDLER>:
TRAPHANDLER(ALIGN_HANDLER, T_ALIGN);
f01044ce:	6a 11                	push   $0x11
f01044d0:	eb 36                	jmp    f0104508 <_alltraps>

f01044d2 <MCHK_HANDLER>:
TRAPHANDLER_NOEC(MCHK_HANDLER, T_MCHK);
f01044d2:	6a 00                	push   $0x0
f01044d4:	6a 12                	push   $0x12
f01044d6:	eb 30                	jmp    f0104508 <_alltraps>

f01044d8 <SIMDERR_HANDLER>:
TRAPHANDLER_NOEC(SIMDERR_HANDLER, T_SIMDERR);
f01044d8:	6a 00                	push   $0x0
f01044da:	6a 13                	push   $0x13
f01044dc:	eb 2a                	jmp    f0104508 <_alltraps>

f01044de <SYSCALL_HANDLER>:

//exercise 7 syscall
TRAPHANDLER_NOEC(SYSCALL_HANDLER, T_SYSCALL);
f01044de:	6a 00                	push   $0x0
f01044e0:	6a 30                	push   $0x30
f01044e2:	eb 24                	jmp    f0104508 <_alltraps>

f01044e4 <timer_handler>:

//lab4 exercise 13
//IRQS 
TRAPHANDLER_NOEC(timer_handler, IRQ_OFFSET + IRQ_TIMER);
f01044e4:	6a 00                	push   $0x0
f01044e6:	6a 20                	push   $0x20
f01044e8:	eb 1e                	jmp    f0104508 <_alltraps>

f01044ea <kbd_handler>:
TRAPHANDLER_NOEC(kbd_handler, IRQ_OFFSET + IRQ_KBD);
f01044ea:	6a 00                	push   $0x0
f01044ec:	6a 21                	push   $0x21
f01044ee:	eb 18                	jmp    f0104508 <_alltraps>

f01044f0 <serial_handler>:
TRAPHANDLER_NOEC(serial_handler, IRQ_OFFSET + IRQ_SERIAL);
f01044f0:	6a 00                	push   $0x0
f01044f2:	6a 24                	push   $0x24
f01044f4:	eb 12                	jmp    f0104508 <_alltraps>

f01044f6 <spurious_handler>:
TRAPHANDLER_NOEC(spurious_handler, IRQ_OFFSET + IRQ_SPURIOUS);
f01044f6:	6a 00                	push   $0x0
f01044f8:	6a 27                	push   $0x27
f01044fa:	eb 0c                	jmp    f0104508 <_alltraps>

f01044fc <ide_handler>:
TRAPHANDLER_NOEC(ide_handler, IRQ_OFFSET + IRQ_IDE);
f01044fc:	6a 00                	push   $0x0
f01044fe:	6a 2e                	push   $0x2e
f0104500:	eb 06                	jmp    f0104508 <_alltraps>

f0104502 <error_handler>:
TRAPHANDLER_NOEC(error_handler, IRQ_OFFSET + IRQ_ERROR);
f0104502:	6a 00                	push   $0x0
f0104504:	6a 33                	push   $0x33
f0104506:	eb 00                	jmp    f0104508 <_alltraps>

f0104508 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
 	//别忘了栈由高地址向低地址生长，于是Trapframe顺序变为tf_trapno（上面两个宏已经把num压栈了），ds，es，PushRegs的反向
	pushl %ds
f0104508:	1e                   	push   %ds
	pushl %es
f0104509:	06                   	push   %es
	pushal
f010450a:	60                   	pusha  
	//
	movw $GD_KD, %ax 
f010450b:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f010450f:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104511:	8e c0                	mov    %eax,%es
	movw GD_KD, %ds
	movw GD_KD, %es
	*/
	
	//这是作为trap(struct Trapframe *tf)的参数的
	pushl %esp
f0104513:	54                   	push   %esp
	//调用trap
	call trap
f0104514:	e8 25 fd ff ff       	call   f010423e <trap>

f0104519 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104519:	55                   	push   %ebp
f010451a:	89 e5                	mov    %esp,%ebp
f010451c:	83 ec 08             	sub    $0x8,%esp
f010451f:	a1 70 62 2b f0       	mov    0xf02b6270,%eax
f0104524:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104527:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f010452c:	8b 02                	mov    (%edx),%eax
f010452e:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104531:	83 f8 02             	cmp    $0x2,%eax
f0104534:	76 2d                	jbe    f0104563 <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f0104536:	83 c1 01             	add    $0x1,%ecx
f0104539:	83 c2 7c             	add    $0x7c,%edx
f010453c:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104542:	75 e8                	jne    f010452c <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104544:	83 ec 0c             	sub    $0xc,%esp
f0104547:	68 50 85 10 f0       	push   $0xf0108550
f010454c:	e8 64 f4 ff ff       	call   f01039b5 <cprintf>
f0104551:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104554:	83 ec 0c             	sub    $0xc,%esp
f0104557:	6a 00                	push   $0x0
f0104559:	e8 2c c4 ff ff       	call   f010098a <monitor>
f010455e:	83 c4 10             	add    $0x10,%esp
f0104561:	eb f1                	jmp    f0104554 <sched_halt+0x3b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104563:	e8 fc 18 00 00       	call   f0105e64 <cpunum>
f0104568:	6b c0 74             	imul   $0x74,%eax,%eax
f010456b:	c7 80 28 70 2f f0 00 	movl   $0x0,-0xfd08fd8(%eax)
f0104572:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104575:	a1 5c 62 2b f0       	mov    0xf02b625c,%eax
	if ((uint32_t)kva < KERNBASE)
f010457a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010457f:	76 50                	jbe    f01045d1 <sched_halt+0xb8>
	return (physaddr_t)kva - KERNBASE;
f0104581:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f0104586:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104589:	e8 d6 18 00 00       	call   f0105e64 <cpunum>
f010458e:	6b d0 74             	imul   $0x74,%eax,%edx
f0104591:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104594:	b8 02 00 00 00       	mov    $0x2,%eax
f0104599:	f0 87 82 20 70 2f f0 	lock xchg %eax,-0xfd08fe0(%edx)
	spin_unlock(&kernel_lock);
f01045a0:	83 ec 0c             	sub    $0xc,%esp
f01045a3:	68 c0 83 12 f0       	push   $0xf01283c0
f01045a8:	e8 c1 1b 00 00       	call   f010616e <spin_unlock>
	asm volatile("pause");
f01045ad:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01045af:	e8 b0 18 00 00       	call   f0105e64 <cpunum>
f01045b4:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f01045b7:	8b 80 30 70 2f f0    	mov    -0xfd08fd0(%eax),%eax
f01045bd:	bd 00 00 00 00       	mov    $0x0,%ebp
f01045c2:	89 c4                	mov    %eax,%esp
f01045c4:	6a 00                	push   $0x0
f01045c6:	6a 00                	push   $0x0
f01045c8:	fb                   	sti    
f01045c9:	f4                   	hlt    
f01045ca:	eb fd                	jmp    f01045c9 <sched_halt+0xb0>
}
f01045cc:	83 c4 10             	add    $0x10,%esp
f01045cf:	c9                   	leave  
f01045d0:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01045d1:	50                   	push   %eax
f01045d2:	68 88 6d 10 f0       	push   $0xf0106d88
f01045d7:	6a 4f                	push   $0x4f
f01045d9:	68 79 85 10 f0       	push   $0xf0108579
f01045de:	e8 5d ba ff ff       	call   f0100040 <_panic>

f01045e3 <sched_yield>:
{
f01045e3:	55                   	push   %ebp
f01045e4:	89 e5                	mov    %esp,%ebp
f01045e6:	57                   	push   %edi
f01045e7:	56                   	push   %esi
f01045e8:	53                   	push   %ebx
f01045e9:	83 ec 0c             	sub    $0xc,%esp
	struct Env * now = curenv;
f01045ec:	e8 73 18 00 00       	call   f0105e64 <cpunum>
f01045f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01045f4:	8b b0 28 70 2f f0    	mov    -0xfd08fd8(%eax),%esi
	int index=-1;//因为这里出错了！！一定是-1！！！
f01045fa:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
	if(now/*定义于kern/env.h。可以看到其已经在lab4中被修改，适应多核*/) index= ENVX(now->env_id);//inc/env.h
f01045ff:	85 f6                	test   %esi,%esi
f0104601:	74 09                	je     f010460c <sched_yield+0x29>
f0104603:	8b 4e 48             	mov    0x48(%esi),%ecx
f0104606:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
	for(int i=index+1; i<index+NENV;i++){
f010460c:	8d 51 01             	lea    0x1(%ecx),%edx
		if(envs[i%NENV].env_status == ENV_RUNNABLE){
f010460f:	8b 1d 70 62 2b f0    	mov    0xf02b6270,%ebx
	for(int i=index+1; i<index+NENV;i++){
f0104615:	81 c1 ff 03 00 00    	add    $0x3ff,%ecx
f010461b:	39 d1                	cmp    %edx,%ecx
f010461d:	7c 2b                	jl     f010464a <sched_yield+0x67>
		if(envs[i%NENV].env_status == ENV_RUNNABLE){
f010461f:	89 d7                	mov    %edx,%edi
f0104621:	c1 ff 1f             	sar    $0x1f,%edi
f0104624:	c1 ef 16             	shr    $0x16,%edi
f0104627:	8d 04 3a             	lea    (%edx,%edi,1),%eax
f010462a:	25 ff 03 00 00       	and    $0x3ff,%eax
f010462f:	29 f8                	sub    %edi,%eax
f0104631:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104634:	01 d8                	add    %ebx,%eax
f0104636:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f010463a:	74 05                	je     f0104641 <sched_yield+0x5e>
	for(int i=index+1; i<index+NENV;i++){
f010463c:	83 c2 01             	add    $0x1,%edx
f010463f:	eb da                	jmp    f010461b <sched_yield+0x38>
			env_run(&envs[i%NENV]);
f0104641:	83 ec 0c             	sub    $0xc,%esp
f0104644:	50                   	push   %eax
f0104645:	e8 be f0 ff ff       	call   f0103708 <env_run>
	if(now && now->env_status == ENV_RUNNING){
f010464a:	85 f6                	test   %esi,%esi
f010464c:	74 06                	je     f0104654 <sched_yield+0x71>
f010464e:	83 7e 54 03          	cmpl   $0x3,0x54(%esi)
f0104652:	74 0d                	je     f0104661 <sched_yield+0x7e>
	sched_halt();
f0104654:	e8 c0 fe ff ff       	call   f0104519 <sched_halt>
}
f0104659:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010465c:	5b                   	pop    %ebx
f010465d:	5e                   	pop    %esi
f010465e:	5f                   	pop    %edi
f010465f:	5d                   	pop    %ebp
f0104660:	c3                   	ret    
		env_run(now);
f0104661:	83 ec 0c             	sub    $0xc,%esp
f0104664:	56                   	push   %esi
f0104665:	e8 9e f0 ff ff       	call   f0103708 <env_run>

f010466a <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010466a:	55                   	push   %ebp
f010466b:	89 e5                	mov    %esp,%ebp
f010466d:	57                   	push   %edi
f010466e:	56                   	push   %esi
f010466f:	53                   	push   %ebx
f0104670:	83 ec 1c             	sub    $0x1c,%esp
f0104673:	8b 45 08             	mov    0x8(%ebp),%eax
	// LAB 3: Your code here.

	// panic("syscall not implemented");
	
	//依据不同的syscallno， 调用lib/system.c中的不同函数
	switch (syscallno) 
f0104676:	83 f8 10             	cmp    $0x10,%eax
f0104679:	0f 87 1e 06 00 00    	ja     f0104c9d <syscall+0x633>
f010467f:	ff 24 85 8c 85 10 f0 	jmp    *-0xfef7a74(,%eax,4)
	user_mem_assert(curenv, s, len, 0);
f0104686:	e8 d9 17 00 00       	call   f0105e64 <cpunum>
f010468b:	6a 00                	push   $0x0
f010468d:	ff 75 10             	push   0x10(%ebp)
f0104690:	ff 75 0c             	push   0xc(%ebp)
f0104693:	6b c0 74             	imul   $0x74,%eax,%eax
f0104696:	ff b0 28 70 2f f0    	push   -0xfd08fd8(%eax)
f010469c:	e8 37 e9 ff ff       	call   f0102fd8 <user_mem_assert>
	cprintf("%.*s", len, s);
f01046a1:	83 c4 0c             	add    $0xc,%esp
f01046a4:	ff 75 0c             	push   0xc(%ebp)
f01046a7:	ff 75 10             	push   0x10(%ebp)
f01046aa:	68 86 85 10 f0       	push   $0xf0108586
f01046af:	e8 01 f3 ff ff       	call   f01039b5 <cprintf>
}
f01046b4:	83 c4 10             	add    $0x10,%esp
	{
		case SYS_cputs:
			sys_cputs( (const char *) a1, a2);
			return 0;
f01046b7:	bb 00 00 00 00       	mov    $0x0,%ebx
			
		default:
			return -E_INVAL;
	}
	return 0;
}
f01046bc:	89 d8                	mov    %ebx,%eax
f01046be:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01046c1:	5b                   	pop    %ebx
f01046c2:	5e                   	pop    %esi
f01046c3:	5f                   	pop    %edi
f01046c4:	5d                   	pop    %ebp
f01046c5:	c3                   	ret    
	return cons_getc();
f01046c6:	e8 49 bf ff ff       	call   f0100614 <cons_getc>
f01046cb:	89 c3                	mov    %eax,%ebx
			return sys_cgetc();
f01046cd:	eb ed                	jmp    f01046bc <syscall+0x52>
	return curenv->env_id;
f01046cf:	e8 90 17 00 00       	call   f0105e64 <cpunum>
f01046d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01046d7:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f01046dd:	8b 58 48             	mov    0x48(%eax),%ebx
			return sys_getenvid();
f01046e0:	eb da                	jmp    f01046bc <syscall+0x52>
	if ((r = envid2env(envid, &e, 1)) < 0)
f01046e2:	83 ec 04             	sub    $0x4,%esp
f01046e5:	6a 01                	push   $0x1
f01046e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046ea:	50                   	push   %eax
f01046eb:	ff 75 0c             	push   0xc(%ebp)
f01046ee:	e8 b7 e9 ff ff       	call   f01030aa <envid2env>
f01046f3:	89 c3                	mov    %eax,%ebx
f01046f5:	83 c4 10             	add    $0x10,%esp
f01046f8:	85 c0                	test   %eax,%eax
f01046fa:	78 c0                	js     f01046bc <syscall+0x52>
	env_destroy(e);
f01046fc:	83 ec 0c             	sub    $0xc,%esp
f01046ff:	ff 75 e4             	push   -0x1c(%ebp)
f0104702:	e8 62 ef ff ff       	call   f0103669 <env_destroy>
	return 0;
f0104707:	83 c4 10             	add    $0x10,%esp
f010470a:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_env_destroy(a1);
f010470f:	eb ab                	jmp    f01046bc <syscall+0x52>
	sched_yield();
f0104711:	e8 cd fe ff ff       	call   f01045e3 <sched_yield>
	struct Env *e=NULL;
f0104716:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int error_ret=env_alloc( &e , curenv->env_id);
f010471d:	e8 42 17 00 00       	call   f0105e64 <cpunum>
f0104722:	83 ec 08             	sub    $0x8,%esp
f0104725:	6b c0 74             	imul   $0x74,%eax,%eax
f0104728:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f010472e:	ff 70 48             	push   0x48(%eax)
f0104731:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104734:	50                   	push   %eax
f0104735:	e8 84 ea ff ff       	call   f01031be <env_alloc>
f010473a:	89 c3                	mov    %eax,%ebx
	if(error_ret<0 ) return error_ret;
f010473c:	83 c4 10             	add    $0x10,%esp
f010473f:	85 c0                	test   %eax,%eax
f0104741:	0f 88 75 ff ff ff    	js     f01046bc <syscall+0x52>
	e->env_status = ENV_NOT_RUNNABLE;
f0104747:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010474a:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf = curenv->env_tf;
f0104751:	e8 0e 17 00 00       	call   f0105e64 <cpunum>
f0104756:	6b c0 74             	imul   $0x74,%eax,%eax
f0104759:	8b b0 28 70 2f f0    	mov    -0xfd08fd8(%eax),%esi
f010475f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104764:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104767:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f0104769:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010476c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;	
f0104773:	8b 58 48             	mov    0x48(%eax),%ebx
			return sys_exofork();
f0104776:	e9 41 ff ff ff       	jmp    f01046bc <syscall+0x52>
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) return -E_INVAL;  
f010477b:	8b 45 10             	mov    0x10(%ebp),%eax
f010477e:	83 e8 02             	sub    $0x2,%eax
f0104781:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104786:	75 2b                	jne    f01047b3 <syscall+0x149>
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f0104788:	83 ec 04             	sub    $0x4,%esp
f010478b:	6a 01                	push   $0x1
f010478d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104790:	50                   	push   %eax
f0104791:	ff 75 0c             	push   0xc(%ebp)
f0104794:	e8 11 e9 ff ff       	call   f01030aa <envid2env>
f0104799:	83 c4 10             	add    $0x10,%esp
f010479c:	85 c0                	test   %eax,%eax
f010479e:	78 1d                	js     f01047bd <syscall+0x153>
	e->env_status = status;
f01047a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047a3:	8b 7d 10             	mov    0x10(%ebp),%edi
f01047a6:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;	
f01047a9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01047ae:	e9 09 ff ff ff       	jmp    f01046bc <syscall+0x52>
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) return -E_INVAL;  
f01047b3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047b8:	e9 ff fe ff ff       	jmp    f01046bc <syscall+0x52>
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f01047bd:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			return sys_env_set_status(a1,a2);
f01047c2:	e9 f5 fe ff ff       	jmp    f01046bc <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f01047c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01047ca:	83 e0 05             	and    $0x5,%eax
f01047cd:	83 f8 05             	cmp    $0x5,%eax
f01047d0:	0f 85 86 00 00 00    	jne    f010485c <syscall+0x1f2>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f01047d6:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f01047dd:	0f 85 83 00 00 00    	jne    f0104866 <syscall+0x1fc>
f01047e3:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047ea:	77 7a                	ja     f0104866 <syscall+0x1fc>
f01047ec:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047f3:	75 7b                	jne    f0104870 <syscall+0x206>
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f01047f5:	83 ec 0c             	sub    $0xc,%esp
f01047f8:	6a 01                	push   $0x1
f01047fa:	e8 63 c7 ff ff       	call   f0100f62 <page_alloc>
f01047ff:	89 c6                	mov    %eax,%esi
	if( pp==NULL ) return -E_NO_MEM;
f0104801:	83 c4 10             	add    $0x10,%esp
f0104804:	85 c0                	test   %eax,%eax
f0104806:	74 72                	je     f010487a <syscall+0x210>
	int error_ret=envid2env(envid, &e, 1);
f0104808:	83 ec 04             	sub    $0x4,%esp
f010480b:	6a 01                	push   $0x1
f010480d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104810:	50                   	push   %eax
f0104811:	ff 75 0c             	push   0xc(%ebp)
f0104814:	e8 91 e8 ff ff       	call   f01030aa <envid2env>
f0104819:	89 c3                	mov    %eax,%ebx
	if( error_ret <0 ) return error_ret;//error_ret 其实就是我们调用函数发生错误时的返回值， 这不同函数之间都是一致的。
f010481b:	83 c4 10             	add    $0x10,%esp
f010481e:	85 c0                	test   %eax,%eax
f0104820:	0f 88 96 fe ff ff    	js     f01046bc <syscall+0x52>
	error_ret=page_insert(e->env_pgdir, pp, va, perm);
f0104826:	ff 75 14             	push   0x14(%ebp)
f0104829:	ff 75 10             	push   0x10(%ebp)
f010482c:	56                   	push   %esi
f010482d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104830:	ff 70 60             	push   0x60(%eax)
f0104833:	e8 38 ca ff ff       	call   f0101270 <page_insert>
f0104838:	89 c3                	mov    %eax,%ebx
	if(error_ret <0){
f010483a:	83 c4 10             	add    $0x10,%esp
f010483d:	85 c0                	test   %eax,%eax
f010483f:	78 0a                	js     f010484b <syscall+0x1e1>
	return 0;		
f0104841:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_page_alloc(a1,(void *)a2, (int)a3);
f0104846:	e9 71 fe ff ff       	jmp    f01046bc <syscall+0x52>
		page_free(pp);
f010484b:	83 ec 0c             	sub    $0xc,%esp
f010484e:	56                   	push   %esi
f010484f:	e8 83 c7 ff ff       	call   f0100fd7 <page_free>
		return error_ret;
f0104854:	83 c4 10             	add    $0x10,%esp
f0104857:	e9 60 fe ff ff       	jmp    f01046bc <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f010485c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104861:	e9 56 fe ff ff       	jmp    f01046bc <syscall+0x52>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f0104866:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010486b:	e9 4c fe ff ff       	jmp    f01046bc <syscall+0x52>
f0104870:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104875:	e9 42 fe ff ff       	jmp    f01046bc <syscall+0x52>
	if( pp==NULL ) return -E_NO_MEM;
f010487a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010487f:	e9 38 fe ff ff       	jmp    f01046bc <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f0104884:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104887:	83 e0 05             	and    $0x5,%eax
f010488a:	83 f8 05             	cmp    $0x5,%eax
f010488d:	0f 85 c0 00 00 00    	jne    f0104953 <syscall+0x2e9>
	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
f0104893:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f010489a:	0f 85 bd 00 00 00    	jne    f010495d <syscall+0x2f3>
f01048a0:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01048a7:	0f 87 b0 00 00 00    	ja     f010495d <syscall+0x2f3>
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
f01048ad:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01048b4:	0f 87 ad 00 00 00    	ja     f0104967 <syscall+0x2fd>
f01048ba:	8b 45 10             	mov    0x10(%ebp),%eax
f01048bd:	0b 45 18             	or     0x18(%ebp),%eax
f01048c0:	a9 ff 0f 00 00       	test   $0xfff,%eax
f01048c5:	0f 85 a6 00 00 00    	jne    f0104971 <syscall+0x307>
	if (envid2env(srcenvid, &src_e, 1)<0 || envid2env(dstenvid, &dst_e, 1)<0) return -E_BAD_ENV;
f01048cb:	83 ec 04             	sub    $0x4,%esp
f01048ce:	6a 01                	push   $0x1
f01048d0:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01048d3:	50                   	push   %eax
f01048d4:	ff 75 0c             	push   0xc(%ebp)
f01048d7:	e8 ce e7 ff ff       	call   f01030aa <envid2env>
f01048dc:	83 c4 10             	add    $0x10,%esp
f01048df:	85 c0                	test   %eax,%eax
f01048e1:	0f 88 94 00 00 00    	js     f010497b <syscall+0x311>
f01048e7:	83 ec 04             	sub    $0x4,%esp
f01048ea:	6a 01                	push   $0x1
f01048ec:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01048ef:	50                   	push   %eax
f01048f0:	ff 75 14             	push   0x14(%ebp)
f01048f3:	e8 b2 e7 ff ff       	call   f01030aa <envid2env>
f01048f8:	83 c4 10             	add    $0x10,%esp
f01048fb:	85 c0                	test   %eax,%eax
f01048fd:	0f 88 82 00 00 00    	js     f0104985 <syscall+0x31b>
	struct PageInfo *pp = page_lookup(src_e->env_pgdir, srcva, &src_pte);
f0104903:	83 ec 04             	sub    $0x4,%esp
f0104906:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104909:	50                   	push   %eax
f010490a:	ff 75 10             	push   0x10(%ebp)
f010490d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104910:	ff 70 60             	push   0x60(%eax)
f0104913:	e8 7e c8 ff ff       	call   f0101196 <page_lookup>
	if( pp==NULL ) return -E_INVAL;
f0104918:	83 c4 10             	add    $0x10,%esp
f010491b:	85 c0                	test   %eax,%eax
f010491d:	74 70                	je     f010498f <syscall+0x325>
	if ( ( ( *src_pte & PTE_W ) == 0 ) && ( (perm & PTE_W) == PTE_W ) ) return -E_INVAL;
f010491f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104922:	f6 02 02             	testb  $0x2,(%edx)
f0104925:	75 06                	jne    f010492d <syscall+0x2c3>
f0104927:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010492b:	75 6c                	jne    f0104999 <syscall+0x32f>
	int error_ret =page_insert(dst_e->env_pgdir, pp, dstva, perm);
f010492d:	ff 75 1c             	push   0x1c(%ebp)
f0104930:	ff 75 18             	push   0x18(%ebp)
f0104933:	50                   	push   %eax
f0104934:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104937:	ff 70 60             	push   0x60(%eax)
f010493a:	e8 31 c9 ff ff       	call   f0101270 <page_insert>
f010493f:	85 c0                	test   %eax,%eax
f0104941:	ba 00 00 00 00       	mov    $0x0,%edx
f0104946:	0f 4e d0             	cmovle %eax,%edx
f0104949:	89 d3                	mov    %edx,%ebx
f010494b:	83 c4 10             	add    $0x10,%esp
f010494e:	e9 69 fd ff ff       	jmp    f01046bc <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f0104953:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104958:	e9 5f fd ff ff       	jmp    f01046bc <syscall+0x52>
	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
f010495d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104962:	e9 55 fd ff ff       	jmp    f01046bc <syscall+0x52>
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
f0104967:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010496c:	e9 4b fd ff ff       	jmp    f01046bc <syscall+0x52>
f0104971:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104976:	e9 41 fd ff ff       	jmp    f01046bc <syscall+0x52>
	if (envid2env(srcenvid, &src_e, 1)<0 || envid2env(dstenvid, &dst_e, 1)<0) return -E_BAD_ENV;
f010497b:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104980:	e9 37 fd ff ff       	jmp    f01046bc <syscall+0x52>
f0104985:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010498a:	e9 2d fd ff ff       	jmp    f01046bc <syscall+0x52>
	if( pp==NULL ) return -E_INVAL;
f010498f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104994:	e9 23 fd ff ff       	jmp    f01046bc <syscall+0x52>
	if ( ( ( *src_pte & PTE_W ) == 0 ) && ( (perm & PTE_W) == PTE_W ) ) return -E_INVAL;
f0104999:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_page_map(a1, (void *)a2, a3, (void*)a4, (int)a5);
f010499e:	e9 19 fd ff ff       	jmp    f01046bc <syscall+0x52>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f01049a3:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01049aa:	77 45                	ja     f01049f1 <syscall+0x387>
f01049ac:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01049b3:	75 46                	jne    f01049fb <syscall+0x391>
	int error_ret=envid2env(envid, &e, 1);
f01049b5:	83 ec 04             	sub    $0x4,%esp
f01049b8:	6a 01                	push   $0x1
f01049ba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049bd:	50                   	push   %eax
f01049be:	ff 75 0c             	push   0xc(%ebp)
f01049c1:	e8 e4 e6 ff ff       	call   f01030aa <envid2env>
f01049c6:	89 c3                	mov    %eax,%ebx
	if( error_ret <0 ) return error_ret;
f01049c8:	83 c4 10             	add    $0x10,%esp
f01049cb:	85 c0                	test   %eax,%eax
f01049cd:	0f 88 e9 fc ff ff    	js     f01046bc <syscall+0x52>
	page_remove(e->env_pgdir, va);
f01049d3:	83 ec 08             	sub    $0x8,%esp
f01049d6:	ff 75 10             	push   0x10(%ebp)
f01049d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049dc:	ff 70 60             	push   0x60(%eax)
f01049df:	e8 46 c8 ff ff       	call   f010122a <page_remove>
	return 0;
f01049e4:	83 c4 10             	add    $0x10,%esp
f01049e7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049ec:	e9 cb fc ff ff       	jmp    f01046bc <syscall+0x52>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f01049f1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049f6:	e9 c1 fc ff ff       	jmp    f01046bc <syscall+0x52>
f01049fb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_page_unmap(a1, (void *)a2);
f0104a00:	e9 b7 fc ff ff       	jmp    f01046bc <syscall+0x52>
	int error_ret= envid2env(envid, &e, 1);
f0104a05:	83 ec 04             	sub    $0x4,%esp
f0104a08:	6a 01                	push   $0x1
f0104a0a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a0d:	50                   	push   %eax
f0104a0e:	ff 75 0c             	push   0xc(%ebp)
f0104a11:	e8 94 e6 ff ff       	call   f01030aa <envid2env>
f0104a16:	89 c3                	mov    %eax,%ebx
	if(error_ret < 0 ) return error_ret;
f0104a18:	83 c4 10             	add    $0x10,%esp
f0104a1b:	85 c0                	test   %eax,%eax
f0104a1d:	0f 88 99 fc ff ff    	js     f01046bc <syscall+0x52>
	e->env_pgfault_upcall = func;
f0104a23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a26:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104a29:	89 48 64             	mov    %ecx,0x64(%eax)
	return 0;
f0104a2c:	bb 00 00 00 00       	mov    $0x0,%ebx
        		return sys_env_set_pgfault_upcall(a1, (void*) a2);
f0104a31:	e9 86 fc ff ff       	jmp    f01046bc <syscall+0x52>
	if ( (r = envid2env( envid, &dstenv, 0)) < 0)  return r;
f0104a36:	83 ec 04             	sub    $0x4,%esp
f0104a39:	6a 00                	push   $0x0
f0104a3b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a3e:	50                   	push   %eax
f0104a3f:	ff 75 0c             	push   0xc(%ebp)
f0104a42:	e8 63 e6 ff ff       	call   f01030aa <envid2env>
f0104a47:	89 c3                	mov    %eax,%ebx
f0104a49:	83 c4 10             	add    $0x10,%esp
f0104a4c:	85 c0                	test   %eax,%eax
f0104a4e:	0f 88 68 fc ff ff    	js     f01046bc <syscall+0x52>
	if ( (dstenv->env_ipc_recving != true)  || dstenv->env_ipc_from != 0)  return -E_IPC_NOT_RECV;
f0104a54:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a57:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a5b:	0f 84 05 01 00 00    	je     f0104b66 <syscall+0x4fc>
f0104a61:	8b 58 74             	mov    0x74(%eax),%ebx
f0104a64:	85 db                	test   %ebx,%ebx
f0104a66:	0f 85 04 01 00 00    	jne    f0104b70 <syscall+0x506>
	dstenv->env_ipc_perm=0;//如果没转移页，设置为0
f0104a6c:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	if((uintptr_t) srcva <  UTOP){
f0104a73:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104a7a:	0f 87 8a 00 00 00    	ja     f0104b0a <syscall+0x4a0>
		if (  !(perm & PTE_P ) || !(perm & PTE_U) )  return -E_INVAL;
f0104a80:	8b 45 18             	mov    0x18(%ebp),%eax
f0104a83:	83 e0 05             	and    $0x5,%eax
f0104a86:	83 f8 05             	cmp    $0x5,%eax
f0104a89:	0f 85 b2 00 00 00    	jne    f0104b41 <syscall+0x4d7>
		if ( PGOFF(srcva) )  return -E_INVAL;
f0104a8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a92:	25 ff 0f 00 00       	and    $0xfff,%eax
		if (perm &  (~ PTE_SYSCALL))   return -E_INVAL; 
f0104a97:	8b 55 18             	mov    0x18(%ebp),%edx
f0104a9a:	81 e2 f8 f1 ff ff    	and    $0xfffff1f8,%edx
f0104aa0:	09 d0                	or     %edx,%eax
f0104aa2:	74 0a                	je     f0104aae <syscall+0x444>
f0104aa4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104aa9:	e9 0e fc ff ff       	jmp    f01046bc <syscall+0x52>
		if ((pp = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL )  return -E_INVAL;
f0104aae:	e8 b1 13 00 00       	call   f0105e64 <cpunum>
f0104ab3:	83 ec 04             	sub    $0x4,%esp
f0104ab6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104ab9:	52                   	push   %edx
f0104aba:	ff 75 14             	push   0x14(%ebp)
f0104abd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ac0:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f0104ac6:	ff 70 60             	push   0x60(%eax)
f0104ac9:	e8 c8 c6 ff ff       	call   f0101196 <page_lookup>
f0104ace:	83 c4 10             	add    $0x10,%esp
f0104ad1:	85 c0                	test   %eax,%eax
f0104ad3:	74 76                	je     f0104b4b <syscall+0x4e1>
		if ((perm & PTE_W) && !(*pte & PTE_W) )   return -E_INVAL;
f0104ad5:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104ad9:	74 08                	je     f0104ae3 <syscall+0x479>
f0104adb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ade:	f6 02 02             	testb  $0x2,(%edx)
f0104ae1:	74 72                	je     f0104b55 <syscall+0x4eb>
		if (dstenv->env_ipc_dstva) {
f0104ae3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104ae6:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104ae9:	85 c9                	test   %ecx,%ecx
f0104aeb:	74 1d                	je     f0104b0a <syscall+0x4a0>
			if( (r = page_insert(dstenv->env_pgdir, pp, dstenv->env_ipc_dstva,  perm) ) < 0)  return r;
f0104aed:	ff 75 18             	push   0x18(%ebp)
f0104af0:	51                   	push   %ecx
f0104af1:	50                   	push   %eax
f0104af2:	ff 72 60             	push   0x60(%edx)
f0104af5:	e8 76 c7 ff ff       	call   f0101270 <page_insert>
f0104afa:	83 c4 10             	add    $0x10,%esp
f0104afd:	85 c0                	test   %eax,%eax
f0104aff:	78 5e                	js     f0104b5f <syscall+0x4f5>
			dstenv->env_ipc_perm = perm;
f0104b01:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b04:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104b07:	89 48 78             	mov    %ecx,0x78(%eax)
	dstenv->env_ipc_recving = false;
f0104b0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b0d:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	dstenv->env_ipc_from = curenv->env_id;
f0104b11:	e8 4e 13 00 00       	call   f0105e64 <cpunum>
f0104b16:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b19:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b1c:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f0104b22:	8b 40 48             	mov    0x48(%eax),%eax
f0104b25:	89 42 74             	mov    %eax,0x74(%edx)
	dstenv->env_ipc_value = value;
f0104b28:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b2b:	89 42 70             	mov    %eax,0x70(%edx)
	dstenv->env_status = ENV_RUNNABLE;
f0104b2e:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	dstenv->env_tf.tf_regs.reg_eax = 0;
f0104b35:	c7 42 1c 00 00 00 00 	movl   $0x0,0x1c(%edx)
	return 0;
f0104b3c:	e9 7b fb ff ff       	jmp    f01046bc <syscall+0x52>
		if (  !(perm & PTE_P ) || !(perm & PTE_U) )  return -E_INVAL;
f0104b41:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b46:	e9 71 fb ff ff       	jmp    f01046bc <syscall+0x52>
		if ((pp = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL )  return -E_INVAL;
f0104b4b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b50:	e9 67 fb ff ff       	jmp    f01046bc <syscall+0x52>
		if ((perm & PTE_W) && !(*pte & PTE_W) )   return -E_INVAL;
f0104b55:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b5a:	e9 5d fb ff ff       	jmp    f01046bc <syscall+0x52>
			if( (r = page_insert(dstenv->env_pgdir, pp, dstenv->env_ipc_dstva,  perm) ) < 0)  return r;
f0104b5f:	89 c3                	mov    %eax,%ebx
f0104b61:	e9 56 fb ff ff       	jmp    f01046bc <syscall+0x52>
	if ( (dstenv->env_ipc_recving != true)  || dstenv->env_ipc_from != 0)  return -E_IPC_NOT_RECV;
f0104b66:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104b6b:	e9 4c fb ff ff       	jmp    f01046bc <syscall+0x52>
f0104b70:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0104b75:	e9 42 fb ff ff       	jmp    f01046bc <syscall+0x52>
	if ((uintptr_t) dstva < UTOP && PGOFF(dstva) != 0) return -E_INVAL;
f0104b7a:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104b81:	77 13                	ja     f0104b96 <syscall+0x52c>
f0104b83:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104b8a:	74 0a                	je     f0104b96 <syscall+0x52c>
			return sys_ipc_recv((void *)a1);
f0104b8c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b91:	e9 26 fb ff ff       	jmp    f01046bc <syscall+0x52>
	curenv->env_ipc_recving = true;
f0104b96:	e8 c9 12 00 00       	call   f0105e64 <cpunum>
f0104b9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b9e:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f0104ba4:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104ba8:	e8 b7 12 00 00       	call   f0105e64 <cpunum>
f0104bad:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bb0:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f0104bb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104bb9:	89 48 6c             	mov    %ecx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104bbc:	e8 a3 12 00 00       	call   f0105e64 <cpunum>
f0104bc1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bc4:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f0104bca:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_from = 0;
f0104bd1:	e8 8e 12 00 00       	call   f0105e64 <cpunum>
f0104bd6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bd9:	8b 80 28 70 2f f0    	mov    -0xfd08fd8(%eax),%eax
f0104bdf:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	sched_yield();
f0104be6:	e8 f8 f9 ff ff       	call   f01045e3 <sched_yield>
	if( (r = envid2env(envid, &e, 1)) < 0 ) return r;
f0104beb:	83 ec 04             	sub    $0x4,%esp
f0104bee:	6a 01                	push   $0x1
f0104bf0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104bf3:	50                   	push   %eax
f0104bf4:	ff 75 0c             	push   0xc(%ebp)
f0104bf7:	e8 ae e4 ff ff       	call   f01030aa <envid2env>
f0104bfc:	89 c3                	mov    %eax,%ebx
f0104bfe:	83 c4 10             	add    $0x10,%esp
f0104c01:	85 c0                	test   %eax,%eax
f0104c03:	0f 88 b3 fa ff ff    	js     f01046bc <syscall+0x52>
	user_mem_assert(e, tf, sizeof(struct Trapframe), 0);
f0104c09:	6a 00                	push   $0x0
f0104c0b:	6a 44                	push   $0x44
f0104c0d:	ff 75 10             	push   0x10(%ebp)
f0104c10:	ff 75 e4             	push   -0x1c(%ebp)
f0104c13:	e8 c0 e3 ff ff       	call   f0102fd8 <user_mem_assert>
	e->env_tf=*tf;
f0104c18:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104c1d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c20:	8b 75 10             	mov    0x10(%ebp),%esi
f0104c23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_cs|=3;
f0104c25:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104c28:	66 83 4a 34 03       	orw    $0x3,0x34(%edx)
	e->env_tf.tf_eflags &=  ~FL_IOPL_MASK;
f0104c2d:	8b 42 38             	mov    0x38(%edx),%eax
f0104c30:	80 e4 cf             	and    $0xcf,%ah
f0104c33:	80 cc 02             	or     $0x2,%ah
f0104c36:	89 42 38             	mov    %eax,0x38(%edx)
	return 0;
f0104c39:	83 c4 10             	add    $0x10,%esp
f0104c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_env_set_trapframe(a1, (struct Trapframe*) a2);
f0104c41:	e9 76 fa ff ff       	jmp    f01046bc <syscall+0x52>
	return time_msec();
f0104c46:	e8 97 1e 00 00       	call   f0106ae2 <time_msec>
f0104c4b:	89 c3                	mov    %eax,%ebx
			return sys_time_msec();
f0104c4d:	e9 6a fa ff ff       	jmp    f01046bc <syscall+0x52>
	user_mem_assert(curenv, buf, len, PTE_U);
f0104c52:	e8 0d 12 00 00       	call   f0105e64 <cpunum>
f0104c57:	6a 04                	push   $0x4
f0104c59:	ff 75 10             	push   0x10(%ebp)
f0104c5c:	ff 75 0c             	push   0xc(%ebp)
f0104c5f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c62:	ff b0 28 70 2f f0    	push   -0xfd08fd8(%eax)
f0104c68:	e8 6b e3 ff ff       	call   f0102fd8 <user_mem_assert>
	return e1000_transmit(buf, len);
f0104c6d:	83 c4 08             	add    $0x8,%esp
f0104c70:	ff 75 10             	push   0x10(%ebp)
f0104c73:	ff 75 0c             	push   0xc(%ebp)
f0104c76:	e8 cc 16 00 00       	call   f0106347 <e1000_transmit>
f0104c7b:	89 c3                	mov    %eax,%ebx
			return sys_e1000_try_send((void *)a1, (size_t)a2);
f0104c7d:	83 c4 10             	add    $0x10,%esp
f0104c80:	e9 37 fa ff ff       	jmp    f01046bc <syscall+0x52>
	return e1000_receive(dstva, len);
f0104c85:	83 ec 08             	sub    $0x8,%esp
f0104c88:	ff 75 10             	push   0x10(%ebp)
f0104c8b:	ff 75 0c             	push   0xc(%ebp)
f0104c8e:	e8 59 18 00 00       	call   f01064ec <e1000_receive>
f0104c93:	89 c3                	mov    %eax,%ebx
			return sys_e1000_recv((void *)a1,(size_t *)a2);	
f0104c95:	83 c4 10             	add    $0x10,%esp
f0104c98:	e9 1f fa ff ff       	jmp    f01046bc <syscall+0x52>
	switch (syscallno) 
f0104c9d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ca2:	e9 15 fa ff ff       	jmp    f01046bc <syscall+0x52>

f0104ca7 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104ca7:	55                   	push   %ebp
f0104ca8:	89 e5                	mov    %esp,%ebp
f0104caa:	57                   	push   %edi
f0104cab:	56                   	push   %esi
f0104cac:	53                   	push   %ebx
f0104cad:	83 ec 14             	sub    $0x14,%esp
f0104cb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104cb3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104cb6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104cb9:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104cbc:	8b 1a                	mov    (%edx),%ebx
f0104cbe:	8b 01                	mov    (%ecx),%eax
f0104cc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104cc3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104cca:	eb 2f                	jmp    f0104cfb <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104ccc:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104ccf:	39 c3                	cmp    %eax,%ebx
f0104cd1:	7f 4e                	jg     f0104d21 <stab_binsearch+0x7a>
f0104cd3:	0f b6 0a             	movzbl (%edx),%ecx
f0104cd6:	83 ea 0c             	sub    $0xc,%edx
f0104cd9:	39 f1                	cmp    %esi,%ecx
f0104cdb:	75 ef                	jne    f0104ccc <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104cdd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ce0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104ce3:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104ce7:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104cea:	73 3a                	jae    f0104d26 <stab_binsearch+0x7f>
			*region_left = m;
f0104cec:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104cef:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104cf1:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0104cf4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104cfb:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104cfe:	7f 53                	jg     f0104d53 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0104d00:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104d03:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0104d06:	89 d0                	mov    %edx,%eax
f0104d08:	c1 e8 1f             	shr    $0x1f,%eax
f0104d0b:	01 d0                	add    %edx,%eax
f0104d0d:	89 c7                	mov    %eax,%edi
f0104d0f:	d1 ff                	sar    %edi
f0104d11:	83 e0 fe             	and    $0xfffffffe,%eax
f0104d14:	01 f8                	add    %edi,%eax
f0104d16:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104d19:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104d1d:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104d1f:	eb ae                	jmp    f0104ccf <stab_binsearch+0x28>
			l = true_m + 1;
f0104d21:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104d24:	eb d5                	jmp    f0104cfb <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104d26:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104d29:	76 14                	jbe    f0104d3f <stab_binsearch+0x98>
			*region_right = m - 1;
f0104d2b:	83 e8 01             	sub    $0x1,%eax
f0104d2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104d31:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104d34:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104d36:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d3d:	eb bc                	jmp    f0104cfb <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104d3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d42:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104d44:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104d48:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104d4a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d51:	eb a8                	jmp    f0104cfb <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104d53:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104d57:	75 15                	jne    f0104d6e <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0104d59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d5c:	8b 00                	mov    (%eax),%eax
f0104d5e:	83 e8 01             	sub    $0x1,%eax
f0104d61:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104d64:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104d66:	83 c4 14             	add    $0x14,%esp
f0104d69:	5b                   	pop    %ebx
f0104d6a:	5e                   	pop    %esi
f0104d6b:	5f                   	pop    %edi
f0104d6c:	5d                   	pop    %ebp
f0104d6d:	c3                   	ret    
		for (l = *region_right;
f0104d6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d71:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104d73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d76:	8b 0f                	mov    (%edi),%ecx
f0104d78:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d7b:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104d7e:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104d82:	39 c1                	cmp    %eax,%ecx
f0104d84:	7d 0f                	jge    f0104d95 <stab_binsearch+0xee>
f0104d86:	0f b6 1a             	movzbl (%edx),%ebx
f0104d89:	83 ea 0c             	sub    $0xc,%edx
f0104d8c:	39 f3                	cmp    %esi,%ebx
f0104d8e:	74 05                	je     f0104d95 <stab_binsearch+0xee>
		     l--)
f0104d90:	83 e8 01             	sub    $0x1,%eax
f0104d93:	eb ed                	jmp    f0104d82 <stab_binsearch+0xdb>
		*region_left = l;
f0104d95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d98:	89 07                	mov    %eax,(%edi)
}
f0104d9a:	eb ca                	jmp    f0104d66 <stab_binsearch+0xbf>

f0104d9c <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d9c:	55                   	push   %ebp
f0104d9d:	89 e5                	mov    %esp,%ebp
f0104d9f:	57                   	push   %edi
f0104da0:	56                   	push   %esi
f0104da1:	53                   	push   %ebx
f0104da2:	83 ec 4c             	sub    $0x4c,%esp
f0104da5:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104da8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104dab:	c7 03 d0 85 10 f0    	movl   $0xf01085d0,(%ebx)
	info->eip_line = 0;
f0104db1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104db8:	c7 43 08 d0 85 10 f0 	movl   $0xf01085d0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104dbf:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104dc6:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104dc9:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104dd0:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104dd6:	0f 86 29 01 00 00    	jbe    f0104f05 <debuginfo_eip+0x169>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104ddc:	c7 45 c0 dc d4 11 f0 	movl   $0xf011d4dc,-0x40(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104de3:	c7 45 bc f1 57 11 f0 	movl   $0xf01157f1,-0x44(%ebp)
		stab_end = __STAB_END__;
f0104dea:	be f0 57 11 f0       	mov    $0xf01157f0,%esi
		stabs = __STAB_BEGIN__;
f0104def:	c7 45 c4 e8 8d 10 f0 	movl   $0xf0108de8,-0x3c(%ebp)
		if( user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ) return -1;
		if( user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) ) return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104df6:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104df9:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f0104dfc:	0f 83 3e 02 00 00    	jae    f0105040 <debuginfo_eip+0x2a4>
f0104e02:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104e06:	0f 85 3b 02 00 00    	jne    f0105047 <debuginfo_eip+0x2ab>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104e0c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104e13:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0104e16:	c1 fe 02             	sar    $0x2,%esi
f0104e19:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104e1f:	83 e8 01             	sub    $0x1,%eax
f0104e22:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e25:	83 ec 08             	sub    $0x8,%esp
f0104e28:	57                   	push   %edi
f0104e29:	6a 64                	push   $0x64
f0104e2b:	8d 75 e0             	lea    -0x20(%ebp),%esi
f0104e2e:	89 f1                	mov    %esi,%ecx
f0104e30:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e33:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104e36:	e8 6c fe ff ff       	call   f0104ca7 <stab_binsearch>
	if (lfile == 0)
f0104e3b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104e3e:	83 c4 10             	add    $0x10,%esp
f0104e41:	85 f6                	test   %esi,%esi
f0104e43:	0f 84 05 02 00 00    	je     f010504e <debuginfo_eip+0x2b2>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104e49:	89 75 dc             	mov    %esi,-0x24(%ebp)
	rfun = rfile;
f0104e4c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104e4f:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0104e52:	89 55 d8             	mov    %edx,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e55:	83 ec 08             	sub    $0x8,%esp
f0104e58:	57                   	push   %edi
f0104e59:	6a 24                	push   $0x24
f0104e5b:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104e5e:	89 d1                	mov    %edx,%ecx
f0104e60:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e63:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104e66:	e8 3c fe ff ff       	call   f0104ca7 <stab_binsearch>

	if (lfun <= rfun) {
f0104e6b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104e6e:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0104e71:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104e74:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0104e77:	83 c4 10             	add    $0x10,%esp
f0104e7a:	39 c2                	cmp    %eax,%edx
f0104e7c:	0f 8f 32 01 00 00    	jg     f0104fb4 <debuginfo_eip+0x218>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e82:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104e85:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104e88:	8d 14 82             	lea    (%edx,%eax,4),%edx
f0104e8b:	8b 02                	mov    (%edx),%eax
f0104e8d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104e90:	2b 4d bc             	sub    -0x44(%ebp),%ecx
f0104e93:	39 c8                	cmp    %ecx,%eax
f0104e95:	73 06                	jae    f0104e9d <debuginfo_eip+0x101>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e97:	03 45 bc             	add    -0x44(%ebp),%eax
f0104e9a:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e9d:	8b 42 08             	mov    0x8(%edx),%eax
		addr -= info->eip_fn_addr;
f0104ea0:	29 c7                	sub    %eax,%edi
f0104ea2:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0104ea5:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0104ea8:	89 4d b8             	mov    %ecx,-0x48(%ebp)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104eab:	89 43 10             	mov    %eax,0x10(%ebx)
		// Search within the function definition for the line number.
		lline = lfun;
f0104eae:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0104eb1:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104eb4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104eb7:	83 ec 08             	sub    $0x8,%esp
f0104eba:	6a 3a                	push   $0x3a
f0104ebc:	ff 73 08             	push   0x8(%ebx)
f0104ebf:	e8 8d 09 00 00       	call   f0105851 <strfind>
f0104ec4:	2b 43 08             	sub    0x8(%ebx),%eax
f0104ec7:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104eca:	83 c4 08             	add    $0x8,%esp
f0104ecd:	57                   	push   %edi
f0104ece:	6a 44                	push   $0x44
f0104ed0:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104ed3:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104ed6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104ed9:	89 f8                	mov    %edi,%eax
f0104edb:	e8 c7 fd ff ff       	call   f0104ca7 <stab_binsearch>
	if (lline <= rline) {
f0104ee0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104ee3:	83 c4 10             	add    $0x10,%esp
f0104ee6:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104ee9:	0f 8f 66 01 00 00    	jg     f0105055 <debuginfo_eip+0x2b9>
    		info->eip_line = stabs[lline].n_desc;
f0104eef:	89 c2                	mov    %eax,%edx
f0104ef1:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104ef4:	0f b7 4c 87 06       	movzwl 0x6(%edi,%eax,4),%ecx
f0104ef9:	89 4b 04             	mov    %ecx,0x4(%ebx)
f0104efc:	8d 44 87 04          	lea    0x4(%edi,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104f00:	e9 be 00 00 00       	jmp    f0104fc3 <debuginfo_eip+0x227>
		if( user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) ) return -1;
f0104f05:	e8 5a 0f 00 00       	call   f0105e64 <cpunum>
f0104f0a:	6a 04                	push   $0x4
f0104f0c:	6a 10                	push   $0x10
f0104f0e:	68 00 00 20 00       	push   $0x200000
f0104f13:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f16:	ff b0 28 70 2f f0    	push   -0xfd08fd8(%eax)
f0104f1c:	e8 29 e0 ff ff       	call   f0102f4a <user_mem_check>
f0104f21:	83 c4 10             	add    $0x10,%esp
f0104f24:	85 c0                	test   %eax,%eax
f0104f26:	0f 85 06 01 00 00    	jne    f0105032 <debuginfo_eip+0x296>
		stabs = usd->stabs;
f0104f2c:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f0104f32:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104f35:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104f3b:	a1 08 00 20 00       	mov    0x200008,%eax
f0104f40:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0104f43:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104f49:	89 55 c0             	mov    %edx,-0x40(%ebp)
		if( user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ) return -1;
f0104f4c:	e8 13 0f 00 00       	call   f0105e64 <cpunum>
f0104f51:	89 c2                	mov    %eax,%edx
f0104f53:	6a 04                	push   $0x4
f0104f55:	89 f0                	mov    %esi,%eax
f0104f57:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104f5a:	29 c8                	sub    %ecx,%eax
f0104f5c:	c1 f8 02             	sar    $0x2,%eax
f0104f5f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104f65:	50                   	push   %eax
f0104f66:	51                   	push   %ecx
f0104f67:	6b d2 74             	imul   $0x74,%edx,%edx
f0104f6a:	ff b2 28 70 2f f0    	push   -0xfd08fd8(%edx)
f0104f70:	e8 d5 df ff ff       	call   f0102f4a <user_mem_check>
f0104f75:	83 c4 10             	add    $0x10,%esp
f0104f78:	85 c0                	test   %eax,%eax
f0104f7a:	0f 85 b9 00 00 00    	jne    f0105039 <debuginfo_eip+0x29d>
		if( user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) ) return -1;
f0104f80:	e8 df 0e 00 00       	call   f0105e64 <cpunum>
f0104f85:	6a 04                	push   $0x4
f0104f87:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0104f8a:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104f8d:	29 ca                	sub    %ecx,%edx
f0104f8f:	52                   	push   %edx
f0104f90:	51                   	push   %ecx
f0104f91:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f94:	ff b0 28 70 2f f0    	push   -0xfd08fd8(%eax)
f0104f9a:	e8 ab df ff ff       	call   f0102f4a <user_mem_check>
f0104f9f:	83 c4 10             	add    $0x10,%esp
f0104fa2:	85 c0                	test   %eax,%eax
f0104fa4:	0f 84 4c fe ff ff    	je     f0104df6 <debuginfo_eip+0x5a>
f0104faa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104faf:	e9 ad 00 00 00       	jmp    f0105061 <debuginfo_eip+0x2c5>
f0104fb4:	89 f8                	mov    %edi,%eax
f0104fb6:	89 f2                	mov    %esi,%edx
f0104fb8:	e9 ee fe ff ff       	jmp    f0104eab <debuginfo_eip+0x10f>
f0104fbd:	83 ea 01             	sub    $0x1,%edx
f0104fc0:	83 e8 0c             	sub    $0xc,%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104fc3:	39 d6                	cmp    %edx,%esi
f0104fc5:	7f 2e                	jg     f0104ff5 <debuginfo_eip+0x259>
	       && stabs[lline].n_type != N_SOL
f0104fc7:	0f b6 08             	movzbl (%eax),%ecx
f0104fca:	80 f9 84             	cmp    $0x84,%cl
f0104fcd:	74 0b                	je     f0104fda <debuginfo_eip+0x23e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104fcf:	80 f9 64             	cmp    $0x64,%cl
f0104fd2:	75 e9                	jne    f0104fbd <debuginfo_eip+0x221>
f0104fd4:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0104fd8:	74 e3                	je     f0104fbd <debuginfo_eip+0x221>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104fda:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104fdd:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104fe0:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0104fe3:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104fe6:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104fe9:	29 f0                	sub    %esi,%eax
f0104feb:	39 c2                	cmp    %eax,%edx
f0104fed:	73 06                	jae    f0104ff5 <debuginfo_eip+0x259>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104fef:	89 f0                	mov    %esi,%eax
f0104ff1:	01 d0                	add    %edx,%eax
f0104ff3:	89 03                	mov    %eax,(%ebx)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ff5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104ffa:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104ffd:	8b 75 b0             	mov    -0x50(%ebp),%esi
f0105000:	39 f7                	cmp    %esi,%edi
f0105002:	7d 5d                	jge    f0105061 <debuginfo_eip+0x2c5>
		for (lline = lfun + 1;
f0105004:	83 c7 01             	add    $0x1,%edi
f0105007:	89 f8                	mov    %edi,%eax
f0105009:	8d 14 7f             	lea    (%edi,%edi,2),%edx
f010500c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010500f:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0105013:	eb 04                	jmp    f0105019 <debuginfo_eip+0x27d>
			info->eip_fn_narg++;
f0105015:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105019:	39 c6                	cmp    %eax,%esi
f010501b:	7e 3f                	jle    f010505c <debuginfo_eip+0x2c0>
f010501d:	0f b6 0a             	movzbl (%edx),%ecx
f0105020:	83 c0 01             	add    $0x1,%eax
f0105023:	83 c2 0c             	add    $0xc,%edx
f0105026:	80 f9 a0             	cmp    $0xa0,%cl
f0105029:	74 ea                	je     f0105015 <debuginfo_eip+0x279>
	return 0;
f010502b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105030:	eb 2f                	jmp    f0105061 <debuginfo_eip+0x2c5>
		if( user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) ) return -1;
f0105032:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105037:	eb 28                	jmp    f0105061 <debuginfo_eip+0x2c5>
		if( user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ) return -1;
f0105039:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010503e:	eb 21                	jmp    f0105061 <debuginfo_eip+0x2c5>
		return -1;
f0105040:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105045:	eb 1a                	jmp    f0105061 <debuginfo_eip+0x2c5>
f0105047:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010504c:	eb 13                	jmp    f0105061 <debuginfo_eip+0x2c5>
		return -1;
f010504e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105053:	eb 0c                	jmp    f0105061 <debuginfo_eip+0x2c5>
    		return -1;
f0105055:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010505a:	eb 05                	jmp    f0105061 <debuginfo_eip+0x2c5>
	return 0;
f010505c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105061:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105064:	5b                   	pop    %ebx
f0105065:	5e                   	pop    %esi
f0105066:	5f                   	pop    %edi
f0105067:	5d                   	pop    %ebp
f0105068:	c3                   	ret    

f0105069 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105069:	55                   	push   %ebp
f010506a:	89 e5                	mov    %esp,%ebp
f010506c:	57                   	push   %edi
f010506d:	56                   	push   %esi
f010506e:	53                   	push   %ebx
f010506f:	83 ec 1c             	sub    $0x1c,%esp
f0105072:	89 c7                	mov    %eax,%edi
f0105074:	89 d6                	mov    %edx,%esi
f0105076:	8b 45 08             	mov    0x8(%ebp),%eax
f0105079:	8b 55 0c             	mov    0xc(%ebp),%edx
f010507c:	89 d1                	mov    %edx,%ecx
f010507e:	89 c2                	mov    %eax,%edx
f0105080:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105083:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105086:	8b 45 10             	mov    0x10(%ebp),%eax
f0105089:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010508c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010508f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105096:	39 c2                	cmp    %eax,%edx
f0105098:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f010509b:	72 3e                	jb     f01050db <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010509d:	83 ec 0c             	sub    $0xc,%esp
f01050a0:	ff 75 18             	push   0x18(%ebp)
f01050a3:	83 eb 01             	sub    $0x1,%ebx
f01050a6:	53                   	push   %ebx
f01050a7:	50                   	push   %eax
f01050a8:	83 ec 08             	sub    $0x8,%esp
f01050ab:	ff 75 e4             	push   -0x1c(%ebp)
f01050ae:	ff 75 e0             	push   -0x20(%ebp)
f01050b1:	ff 75 dc             	push   -0x24(%ebp)
f01050b4:	ff 75 d8             	push   -0x28(%ebp)
f01050b7:	e8 34 1a 00 00       	call   f0106af0 <__udivdi3>
f01050bc:	83 c4 18             	add    $0x18,%esp
f01050bf:	52                   	push   %edx
f01050c0:	50                   	push   %eax
f01050c1:	89 f2                	mov    %esi,%edx
f01050c3:	89 f8                	mov    %edi,%eax
f01050c5:	e8 9f ff ff ff       	call   f0105069 <printnum>
f01050ca:	83 c4 20             	add    $0x20,%esp
f01050cd:	eb 13                	jmp    f01050e2 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01050cf:	83 ec 08             	sub    $0x8,%esp
f01050d2:	56                   	push   %esi
f01050d3:	ff 75 18             	push   0x18(%ebp)
f01050d6:	ff d7                	call   *%edi
f01050d8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01050db:	83 eb 01             	sub    $0x1,%ebx
f01050de:	85 db                	test   %ebx,%ebx
f01050e0:	7f ed                	jg     f01050cf <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01050e2:	83 ec 08             	sub    $0x8,%esp
f01050e5:	56                   	push   %esi
f01050e6:	83 ec 04             	sub    $0x4,%esp
f01050e9:	ff 75 e4             	push   -0x1c(%ebp)
f01050ec:	ff 75 e0             	push   -0x20(%ebp)
f01050ef:	ff 75 dc             	push   -0x24(%ebp)
f01050f2:	ff 75 d8             	push   -0x28(%ebp)
f01050f5:	e8 16 1b 00 00       	call   f0106c10 <__umoddi3>
f01050fa:	83 c4 14             	add    $0x14,%esp
f01050fd:	0f be 80 da 85 10 f0 	movsbl -0xfef7a26(%eax),%eax
f0105104:	50                   	push   %eax
f0105105:	ff d7                	call   *%edi
}
f0105107:	83 c4 10             	add    $0x10,%esp
f010510a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010510d:	5b                   	pop    %ebx
f010510e:	5e                   	pop    %esi
f010510f:	5f                   	pop    %edi
f0105110:	5d                   	pop    %ebp
f0105111:	c3                   	ret    

f0105112 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105112:	55                   	push   %ebp
f0105113:	89 e5                	mov    %esp,%ebp
f0105115:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105118:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010511c:	8b 10                	mov    (%eax),%edx
f010511e:	3b 50 04             	cmp    0x4(%eax),%edx
f0105121:	73 0a                	jae    f010512d <sprintputch+0x1b>
		*b->buf++ = ch;
f0105123:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105126:	89 08                	mov    %ecx,(%eax)
f0105128:	8b 45 08             	mov    0x8(%ebp),%eax
f010512b:	88 02                	mov    %al,(%edx)
}
f010512d:	5d                   	pop    %ebp
f010512e:	c3                   	ret    

f010512f <printfmt>:
{
f010512f:	55                   	push   %ebp
f0105130:	89 e5                	mov    %esp,%ebp
f0105132:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0105135:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105138:	50                   	push   %eax
f0105139:	ff 75 10             	push   0x10(%ebp)
f010513c:	ff 75 0c             	push   0xc(%ebp)
f010513f:	ff 75 08             	push   0x8(%ebp)
f0105142:	e8 05 00 00 00       	call   f010514c <vprintfmt>
}
f0105147:	83 c4 10             	add    $0x10,%esp
f010514a:	c9                   	leave  
f010514b:	c3                   	ret    

f010514c <vprintfmt>:
{
f010514c:	55                   	push   %ebp
f010514d:	89 e5                	mov    %esp,%ebp
f010514f:	57                   	push   %edi
f0105150:	56                   	push   %esi
f0105151:	53                   	push   %ebx
f0105152:	83 ec 3c             	sub    $0x3c,%esp
f0105155:	8b 75 08             	mov    0x8(%ebp),%esi
f0105158:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010515b:	8b 7d 10             	mov    0x10(%ebp),%edi
f010515e:	eb 0a                	jmp    f010516a <vprintfmt+0x1e>
			putch(ch, putdat);
f0105160:	83 ec 08             	sub    $0x8,%esp
f0105163:	53                   	push   %ebx
f0105164:	50                   	push   %eax
f0105165:	ff d6                	call   *%esi
f0105167:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010516a:	83 c7 01             	add    $0x1,%edi
f010516d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105171:	83 f8 25             	cmp    $0x25,%eax
f0105174:	74 0c                	je     f0105182 <vprintfmt+0x36>
			if (ch == '\0')
f0105176:	85 c0                	test   %eax,%eax
f0105178:	75 e6                	jne    f0105160 <vprintfmt+0x14>
}
f010517a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010517d:	5b                   	pop    %ebx
f010517e:	5e                   	pop    %esi
f010517f:	5f                   	pop    %edi
f0105180:	5d                   	pop    %ebp
f0105181:	c3                   	ret    
		padc = ' ';
f0105182:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0105186:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f010518d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0105194:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010519b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01051a0:	8d 47 01             	lea    0x1(%edi),%eax
f01051a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01051a6:	0f b6 17             	movzbl (%edi),%edx
f01051a9:	8d 42 dd             	lea    -0x23(%edx),%eax
f01051ac:	3c 55                	cmp    $0x55,%al
f01051ae:	0f 87 bb 03 00 00    	ja     f010556f <vprintfmt+0x423>
f01051b4:	0f b6 c0             	movzbl %al,%eax
f01051b7:	ff 24 85 20 87 10 f0 	jmp    *-0xfef78e0(,%eax,4)
f01051be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f01051c1:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f01051c5:	eb d9                	jmp    f01051a0 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f01051c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051ca:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f01051ce:	eb d0                	jmp    f01051a0 <vprintfmt+0x54>
f01051d0:	0f b6 d2             	movzbl %dl,%edx
f01051d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f01051d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01051db:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f01051de:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01051e1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01051e5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01051e8:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01051eb:	83 f9 09             	cmp    $0x9,%ecx
f01051ee:	77 55                	ja     f0105245 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
f01051f0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f01051f3:	eb e9                	jmp    f01051de <vprintfmt+0x92>
			precision = va_arg(ap, int);
f01051f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01051f8:	8b 00                	mov    (%eax),%eax
f01051fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051fd:	8b 45 14             	mov    0x14(%ebp),%eax
f0105200:	8d 40 04             	lea    0x4(%eax),%eax
f0105203:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105206:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0105209:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010520d:	79 91                	jns    f01051a0 <vprintfmt+0x54>
				width = precision, precision = -1;
f010520f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105212:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105215:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f010521c:	eb 82                	jmp    f01051a0 <vprintfmt+0x54>
f010521e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105221:	85 d2                	test   %edx,%edx
f0105223:	b8 00 00 00 00       	mov    $0x0,%eax
f0105228:	0f 49 c2             	cmovns %edx,%eax
f010522b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010522e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0105231:	e9 6a ff ff ff       	jmp    f01051a0 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0105236:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0105239:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0105240:	e9 5b ff ff ff       	jmp    f01051a0 <vprintfmt+0x54>
f0105245:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105248:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010524b:	eb bc                	jmp    f0105209 <vprintfmt+0xbd>
			lflag++;
f010524d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105250:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0105253:	e9 48 ff ff ff       	jmp    f01051a0 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f0105258:	8b 45 14             	mov    0x14(%ebp),%eax
f010525b:	8d 78 04             	lea    0x4(%eax),%edi
f010525e:	83 ec 08             	sub    $0x8,%esp
f0105261:	53                   	push   %ebx
f0105262:	ff 30                	push   (%eax)
f0105264:	ff d6                	call   *%esi
			break;
f0105266:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0105269:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f010526c:	e9 9d 02 00 00       	jmp    f010550e <vprintfmt+0x3c2>
			err = va_arg(ap, int);
f0105271:	8b 45 14             	mov    0x14(%ebp),%eax
f0105274:	8d 78 04             	lea    0x4(%eax),%edi
f0105277:	8b 10                	mov    (%eax),%edx
f0105279:	89 d0                	mov    %edx,%eax
f010527b:	f7 d8                	neg    %eax
f010527d:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105280:	83 f8 0f             	cmp    $0xf,%eax
f0105283:	7f 23                	jg     f01052a8 <vprintfmt+0x15c>
f0105285:	8b 14 85 80 88 10 f0 	mov    -0xfef7780(,%eax,4),%edx
f010528c:	85 d2                	test   %edx,%edx
f010528e:	74 18                	je     f01052a8 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
f0105290:	52                   	push   %edx
f0105291:	68 e7 72 10 f0       	push   $0xf01072e7
f0105296:	53                   	push   %ebx
f0105297:	56                   	push   %esi
f0105298:	e8 92 fe ff ff       	call   f010512f <printfmt>
f010529d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01052a0:	89 7d 14             	mov    %edi,0x14(%ebp)
f01052a3:	e9 66 02 00 00       	jmp    f010550e <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
f01052a8:	50                   	push   %eax
f01052a9:	68 f2 85 10 f0       	push   $0xf01085f2
f01052ae:	53                   	push   %ebx
f01052af:	56                   	push   %esi
f01052b0:	e8 7a fe ff ff       	call   f010512f <printfmt>
f01052b5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01052b8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01052bb:	e9 4e 02 00 00       	jmp    f010550e <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
f01052c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01052c3:	83 c0 04             	add    $0x4,%eax
f01052c6:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01052c9:	8b 45 14             	mov    0x14(%ebp),%eax
f01052cc:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01052ce:	85 d2                	test   %edx,%edx
f01052d0:	b8 eb 85 10 f0       	mov    $0xf01085eb,%eax
f01052d5:	0f 45 c2             	cmovne %edx,%eax
f01052d8:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f01052db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01052df:	7e 06                	jle    f01052e7 <vprintfmt+0x19b>
f01052e1:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f01052e5:	75 0d                	jne    f01052f4 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
f01052e7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01052ea:	89 c7                	mov    %eax,%edi
f01052ec:	03 45 e0             	add    -0x20(%ebp),%eax
f01052ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01052f2:	eb 55                	jmp    f0105349 <vprintfmt+0x1fd>
f01052f4:	83 ec 08             	sub    $0x8,%esp
f01052f7:	ff 75 d8             	push   -0x28(%ebp)
f01052fa:	ff 75 cc             	push   -0x34(%ebp)
f01052fd:	e8 f8 03 00 00       	call   f01056fa <strnlen>
f0105302:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105305:	29 c1                	sub    %eax,%ecx
f0105307:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f010530a:	83 c4 10             	add    $0x10,%esp
f010530d:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
f010530f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0105313:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0105316:	eb 0f                	jmp    f0105327 <vprintfmt+0x1db>
					putch(padc, putdat);
f0105318:	83 ec 08             	sub    $0x8,%esp
f010531b:	53                   	push   %ebx
f010531c:	ff 75 e0             	push   -0x20(%ebp)
f010531f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105321:	83 ef 01             	sub    $0x1,%edi
f0105324:	83 c4 10             	add    $0x10,%esp
f0105327:	85 ff                	test   %edi,%edi
f0105329:	7f ed                	jg     f0105318 <vprintfmt+0x1cc>
f010532b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010532e:	85 d2                	test   %edx,%edx
f0105330:	b8 00 00 00 00       	mov    $0x0,%eax
f0105335:	0f 49 c2             	cmovns %edx,%eax
f0105338:	29 c2                	sub    %eax,%edx
f010533a:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010533d:	eb a8                	jmp    f01052e7 <vprintfmt+0x19b>
					putch(ch, putdat);
f010533f:	83 ec 08             	sub    $0x8,%esp
f0105342:	53                   	push   %ebx
f0105343:	52                   	push   %edx
f0105344:	ff d6                	call   *%esi
f0105346:	83 c4 10             	add    $0x10,%esp
f0105349:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010534c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010534e:	83 c7 01             	add    $0x1,%edi
f0105351:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105355:	0f be d0             	movsbl %al,%edx
f0105358:	85 d2                	test   %edx,%edx
f010535a:	74 4b                	je     f01053a7 <vprintfmt+0x25b>
f010535c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105360:	78 06                	js     f0105368 <vprintfmt+0x21c>
f0105362:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0105366:	78 1e                	js     f0105386 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
f0105368:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010536c:	74 d1                	je     f010533f <vprintfmt+0x1f3>
f010536e:	0f be c0             	movsbl %al,%eax
f0105371:	83 e8 20             	sub    $0x20,%eax
f0105374:	83 f8 5e             	cmp    $0x5e,%eax
f0105377:	76 c6                	jbe    f010533f <vprintfmt+0x1f3>
					putch('?', putdat);
f0105379:	83 ec 08             	sub    $0x8,%esp
f010537c:	53                   	push   %ebx
f010537d:	6a 3f                	push   $0x3f
f010537f:	ff d6                	call   *%esi
f0105381:	83 c4 10             	add    $0x10,%esp
f0105384:	eb c3                	jmp    f0105349 <vprintfmt+0x1fd>
f0105386:	89 cf                	mov    %ecx,%edi
f0105388:	eb 0e                	jmp    f0105398 <vprintfmt+0x24c>
				putch(' ', putdat);
f010538a:	83 ec 08             	sub    $0x8,%esp
f010538d:	53                   	push   %ebx
f010538e:	6a 20                	push   $0x20
f0105390:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105392:	83 ef 01             	sub    $0x1,%edi
f0105395:	83 c4 10             	add    $0x10,%esp
f0105398:	85 ff                	test   %edi,%edi
f010539a:	7f ee                	jg     f010538a <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
f010539c:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010539f:	89 45 14             	mov    %eax,0x14(%ebp)
f01053a2:	e9 67 01 00 00       	jmp    f010550e <vprintfmt+0x3c2>
f01053a7:	89 cf                	mov    %ecx,%edi
f01053a9:	eb ed                	jmp    f0105398 <vprintfmt+0x24c>
	if (lflag >= 2)
f01053ab:	83 f9 01             	cmp    $0x1,%ecx
f01053ae:	7f 1b                	jg     f01053cb <vprintfmt+0x27f>
	else if (lflag)
f01053b0:	85 c9                	test   %ecx,%ecx
f01053b2:	74 63                	je     f0105417 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
f01053b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01053b7:	8b 00                	mov    (%eax),%eax
f01053b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053bc:	99                   	cltd   
f01053bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01053c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01053c3:	8d 40 04             	lea    0x4(%eax),%eax
f01053c6:	89 45 14             	mov    %eax,0x14(%ebp)
f01053c9:	eb 17                	jmp    f01053e2 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f01053cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01053ce:	8b 50 04             	mov    0x4(%eax),%edx
f01053d1:	8b 00                	mov    (%eax),%eax
f01053d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01053d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01053dc:	8d 40 08             	lea    0x8(%eax),%eax
f01053df:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01053e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01053e5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01053e8:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
f01053ed:	85 c9                	test   %ecx,%ecx
f01053ef:	0f 89 ff 00 00 00    	jns    f01054f4 <vprintfmt+0x3a8>
				putch('-', putdat);
f01053f5:	83 ec 08             	sub    $0x8,%esp
f01053f8:	53                   	push   %ebx
f01053f9:	6a 2d                	push   $0x2d
f01053fb:	ff d6                	call   *%esi
				num = -(long long) num;
f01053fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105400:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105403:	f7 da                	neg    %edx
f0105405:	83 d1 00             	adc    $0x0,%ecx
f0105408:	f7 d9                	neg    %ecx
f010540a:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010540d:	bf 0a 00 00 00       	mov    $0xa,%edi
f0105412:	e9 dd 00 00 00       	jmp    f01054f4 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
f0105417:	8b 45 14             	mov    0x14(%ebp),%eax
f010541a:	8b 00                	mov    (%eax),%eax
f010541c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010541f:	99                   	cltd   
f0105420:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105423:	8b 45 14             	mov    0x14(%ebp),%eax
f0105426:	8d 40 04             	lea    0x4(%eax),%eax
f0105429:	89 45 14             	mov    %eax,0x14(%ebp)
f010542c:	eb b4                	jmp    f01053e2 <vprintfmt+0x296>
	if (lflag >= 2)
f010542e:	83 f9 01             	cmp    $0x1,%ecx
f0105431:	7f 1e                	jg     f0105451 <vprintfmt+0x305>
	else if (lflag)
f0105433:	85 c9                	test   %ecx,%ecx
f0105435:	74 32                	je     f0105469 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
f0105437:	8b 45 14             	mov    0x14(%ebp),%eax
f010543a:	8b 10                	mov    (%eax),%edx
f010543c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105441:	8d 40 04             	lea    0x4(%eax),%eax
f0105444:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105447:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
f010544c:	e9 a3 00 00 00       	jmp    f01054f4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f0105451:	8b 45 14             	mov    0x14(%ebp),%eax
f0105454:	8b 10                	mov    (%eax),%edx
f0105456:	8b 48 04             	mov    0x4(%eax),%ecx
f0105459:	8d 40 08             	lea    0x8(%eax),%eax
f010545c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010545f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
f0105464:	e9 8b 00 00 00       	jmp    f01054f4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f0105469:	8b 45 14             	mov    0x14(%ebp),%eax
f010546c:	8b 10                	mov    (%eax),%edx
f010546e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105473:	8d 40 04             	lea    0x4(%eax),%eax
f0105476:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105479:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
f010547e:	eb 74                	jmp    f01054f4 <vprintfmt+0x3a8>
	if (lflag >= 2)
f0105480:	83 f9 01             	cmp    $0x1,%ecx
f0105483:	7f 1b                	jg     f01054a0 <vprintfmt+0x354>
	else if (lflag)
f0105485:	85 c9                	test   %ecx,%ecx
f0105487:	74 2c                	je     f01054b5 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
f0105489:	8b 45 14             	mov    0x14(%ebp),%eax
f010548c:	8b 10                	mov    (%eax),%edx
f010548e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105493:	8d 40 04             	lea    0x4(%eax),%eax
f0105496:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0105499:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
f010549e:	eb 54                	jmp    f01054f4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f01054a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01054a3:	8b 10                	mov    (%eax),%edx
f01054a5:	8b 48 04             	mov    0x4(%eax),%ecx
f01054a8:	8d 40 08             	lea    0x8(%eax),%eax
f01054ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f01054ae:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
f01054b3:	eb 3f                	jmp    f01054f4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f01054b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01054b8:	8b 10                	mov    (%eax),%edx
f01054ba:	b9 00 00 00 00       	mov    $0x0,%ecx
f01054bf:	8d 40 04             	lea    0x4(%eax),%eax
f01054c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f01054c5:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
f01054ca:	eb 28                	jmp    f01054f4 <vprintfmt+0x3a8>
			putch('0', putdat);
f01054cc:	83 ec 08             	sub    $0x8,%esp
f01054cf:	53                   	push   %ebx
f01054d0:	6a 30                	push   $0x30
f01054d2:	ff d6                	call   *%esi
			putch('x', putdat);
f01054d4:	83 c4 08             	add    $0x8,%esp
f01054d7:	53                   	push   %ebx
f01054d8:	6a 78                	push   $0x78
f01054da:	ff d6                	call   *%esi
			num = (unsigned long long)
f01054dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01054df:	8b 10                	mov    (%eax),%edx
f01054e1:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01054e6:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01054e9:	8d 40 04             	lea    0x4(%eax),%eax
f01054ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01054ef:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
f01054f4:	83 ec 0c             	sub    $0xc,%esp
f01054f7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f01054fb:	50                   	push   %eax
f01054fc:	ff 75 e0             	push   -0x20(%ebp)
f01054ff:	57                   	push   %edi
f0105500:	51                   	push   %ecx
f0105501:	52                   	push   %edx
f0105502:	89 da                	mov    %ebx,%edx
f0105504:	89 f0                	mov    %esi,%eax
f0105506:	e8 5e fb ff ff       	call   f0105069 <printnum>
			break;
f010550b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010550e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105511:	e9 54 fc ff ff       	jmp    f010516a <vprintfmt+0x1e>
	if (lflag >= 2)
f0105516:	83 f9 01             	cmp    $0x1,%ecx
f0105519:	7f 1b                	jg     f0105536 <vprintfmt+0x3ea>
	else if (lflag)
f010551b:	85 c9                	test   %ecx,%ecx
f010551d:	74 2c                	je     f010554b <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
f010551f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105522:	8b 10                	mov    (%eax),%edx
f0105524:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105529:	8d 40 04             	lea    0x4(%eax),%eax
f010552c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010552f:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
f0105534:	eb be                	jmp    f01054f4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f0105536:	8b 45 14             	mov    0x14(%ebp),%eax
f0105539:	8b 10                	mov    (%eax),%edx
f010553b:	8b 48 04             	mov    0x4(%eax),%ecx
f010553e:	8d 40 08             	lea    0x8(%eax),%eax
f0105541:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105544:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
f0105549:	eb a9                	jmp    f01054f4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f010554b:	8b 45 14             	mov    0x14(%ebp),%eax
f010554e:	8b 10                	mov    (%eax),%edx
f0105550:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105555:	8d 40 04             	lea    0x4(%eax),%eax
f0105558:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010555b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
f0105560:	eb 92                	jmp    f01054f4 <vprintfmt+0x3a8>
			putch(ch, putdat);
f0105562:	83 ec 08             	sub    $0x8,%esp
f0105565:	53                   	push   %ebx
f0105566:	6a 25                	push   $0x25
f0105568:	ff d6                	call   *%esi
			break;
f010556a:	83 c4 10             	add    $0x10,%esp
f010556d:	eb 9f                	jmp    f010550e <vprintfmt+0x3c2>
			putch('%', putdat);
f010556f:	83 ec 08             	sub    $0x8,%esp
f0105572:	53                   	push   %ebx
f0105573:	6a 25                	push   $0x25
f0105575:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105577:	83 c4 10             	add    $0x10,%esp
f010557a:	89 f8                	mov    %edi,%eax
f010557c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105580:	74 05                	je     f0105587 <vprintfmt+0x43b>
f0105582:	83 e8 01             	sub    $0x1,%eax
f0105585:	eb f5                	jmp    f010557c <vprintfmt+0x430>
f0105587:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010558a:	eb 82                	jmp    f010550e <vprintfmt+0x3c2>

f010558c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010558c:	55                   	push   %ebp
f010558d:	89 e5                	mov    %esp,%ebp
f010558f:	83 ec 18             	sub    $0x18,%esp
f0105592:	8b 45 08             	mov    0x8(%ebp),%eax
f0105595:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105598:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010559b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010559f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01055a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01055a9:	85 c0                	test   %eax,%eax
f01055ab:	74 26                	je     f01055d3 <vsnprintf+0x47>
f01055ad:	85 d2                	test   %edx,%edx
f01055af:	7e 22                	jle    f01055d3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01055b1:	ff 75 14             	push   0x14(%ebp)
f01055b4:	ff 75 10             	push   0x10(%ebp)
f01055b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01055ba:	50                   	push   %eax
f01055bb:	68 12 51 10 f0       	push   $0xf0105112
f01055c0:	e8 87 fb ff ff       	call   f010514c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01055c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01055c8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01055cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01055ce:	83 c4 10             	add    $0x10,%esp
}
f01055d1:	c9                   	leave  
f01055d2:	c3                   	ret    
		return -E_INVAL;
f01055d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055d8:	eb f7                	jmp    f01055d1 <vsnprintf+0x45>

f01055da <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01055da:	55                   	push   %ebp
f01055db:	89 e5                	mov    %esp,%ebp
f01055dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01055e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01055e3:	50                   	push   %eax
f01055e4:	ff 75 10             	push   0x10(%ebp)
f01055e7:	ff 75 0c             	push   0xc(%ebp)
f01055ea:	ff 75 08             	push   0x8(%ebp)
f01055ed:	e8 9a ff ff ff       	call   f010558c <vsnprintf>
	va_end(ap);

	return rc;
}
f01055f2:	c9                   	leave  
f01055f3:	c3                   	ret    

f01055f4 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01055f4:	55                   	push   %ebp
f01055f5:	89 e5                	mov    %esp,%ebp
f01055f7:	57                   	push   %edi
f01055f8:	56                   	push   %esi
f01055f9:	53                   	push   %ebx
f01055fa:	83 ec 0c             	sub    $0xc,%esp
f01055fd:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105600:	85 c0                	test   %eax,%eax
f0105602:	74 11                	je     f0105615 <readline+0x21>
		cprintf("%s", prompt);
f0105604:	83 ec 08             	sub    $0x8,%esp
f0105607:	50                   	push   %eax
f0105608:	68 e7 72 10 f0       	push   $0xf01072e7
f010560d:	e8 a3 e3 ff ff       	call   f01039b5 <cprintf>
f0105612:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105615:	83 ec 0c             	sub    $0xc,%esp
f0105618:	6a 00                	push   $0x0
f010561a:	e8 98 b1 ff ff       	call   f01007b7 <iscons>
f010561f:	89 c7                	mov    %eax,%edi
f0105621:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105624:	be 00 00 00 00       	mov    $0x0,%esi
f0105629:	eb 4b                	jmp    f0105676 <readline+0x82>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f010562b:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f0105630:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105633:	75 08                	jne    f010563d <readline+0x49>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105635:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105638:	5b                   	pop    %ebx
f0105639:	5e                   	pop    %esi
f010563a:	5f                   	pop    %edi
f010563b:	5d                   	pop    %ebp
f010563c:	c3                   	ret    
				cprintf("read error: %e\n", c);
f010563d:	83 ec 08             	sub    $0x8,%esp
f0105640:	53                   	push   %ebx
f0105641:	68 df 88 10 f0       	push   $0xf01088df
f0105646:	e8 6a e3 ff ff       	call   f01039b5 <cprintf>
f010564b:	83 c4 10             	add    $0x10,%esp
			return NULL;
f010564e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105653:	eb e0                	jmp    f0105635 <readline+0x41>
			if (echoing)
f0105655:	85 ff                	test   %edi,%edi
f0105657:	75 05                	jne    f010565e <readline+0x6a>
			i--;
f0105659:	83 ee 01             	sub    $0x1,%esi
f010565c:	eb 18                	jmp    f0105676 <readline+0x82>
				cputchar('\b');
f010565e:	83 ec 0c             	sub    $0xc,%esp
f0105661:	6a 08                	push   $0x8
f0105663:	e8 2e b1 ff ff       	call   f0100796 <cputchar>
f0105668:	83 c4 10             	add    $0x10,%esp
f010566b:	eb ec                	jmp    f0105659 <readline+0x65>
			buf[i++] = c;
f010566d:	88 9e a0 6a 2b f0    	mov    %bl,-0xfd49560(%esi)
f0105673:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105676:	e8 2b b1 ff ff       	call   f01007a6 <getchar>
f010567b:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010567d:	85 c0                	test   %eax,%eax
f010567f:	78 aa                	js     f010562b <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105681:	83 f8 08             	cmp    $0x8,%eax
f0105684:	0f 94 c0             	sete   %al
f0105687:	83 fb 7f             	cmp    $0x7f,%ebx
f010568a:	0f 94 c2             	sete   %dl
f010568d:	08 d0                	or     %dl,%al
f010568f:	74 04                	je     f0105695 <readline+0xa1>
f0105691:	85 f6                	test   %esi,%esi
f0105693:	7f c0                	jg     f0105655 <readline+0x61>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105695:	83 fb 1f             	cmp    $0x1f,%ebx
f0105698:	7e 1a                	jle    f01056b4 <readline+0xc0>
f010569a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01056a0:	7f 12                	jg     f01056b4 <readline+0xc0>
			if (echoing)
f01056a2:	85 ff                	test   %edi,%edi
f01056a4:	74 c7                	je     f010566d <readline+0x79>
				cputchar(c);
f01056a6:	83 ec 0c             	sub    $0xc,%esp
f01056a9:	53                   	push   %ebx
f01056aa:	e8 e7 b0 ff ff       	call   f0100796 <cputchar>
f01056af:	83 c4 10             	add    $0x10,%esp
f01056b2:	eb b9                	jmp    f010566d <readline+0x79>
		} else if (c == '\n' || c == '\r') {
f01056b4:	83 fb 0a             	cmp    $0xa,%ebx
f01056b7:	74 05                	je     f01056be <readline+0xca>
f01056b9:	83 fb 0d             	cmp    $0xd,%ebx
f01056bc:	75 b8                	jne    f0105676 <readline+0x82>
			if (echoing)
f01056be:	85 ff                	test   %edi,%edi
f01056c0:	75 11                	jne    f01056d3 <readline+0xdf>
			buf[i] = 0;
f01056c2:	c6 86 a0 6a 2b f0 00 	movb   $0x0,-0xfd49560(%esi)
			return buf;
f01056c9:	b8 a0 6a 2b f0       	mov    $0xf02b6aa0,%eax
f01056ce:	e9 62 ff ff ff       	jmp    f0105635 <readline+0x41>
				cputchar('\n');
f01056d3:	83 ec 0c             	sub    $0xc,%esp
f01056d6:	6a 0a                	push   $0xa
f01056d8:	e8 b9 b0 ff ff       	call   f0100796 <cputchar>
f01056dd:	83 c4 10             	add    $0x10,%esp
f01056e0:	eb e0                	jmp    f01056c2 <readline+0xce>

f01056e2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01056e2:	55                   	push   %ebp
f01056e3:	89 e5                	mov    %esp,%ebp
f01056e5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01056e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01056ed:	eb 03                	jmp    f01056f2 <strlen+0x10>
		n++;
f01056ef:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01056f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01056f6:	75 f7                	jne    f01056ef <strlen+0xd>
	return n;
}
f01056f8:	5d                   	pop    %ebp
f01056f9:	c3                   	ret    

f01056fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01056fa:	55                   	push   %ebp
f01056fb:	89 e5                	mov    %esp,%ebp
f01056fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105700:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105703:	b8 00 00 00 00       	mov    $0x0,%eax
f0105708:	eb 03                	jmp    f010570d <strnlen+0x13>
		n++;
f010570a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010570d:	39 d0                	cmp    %edx,%eax
f010570f:	74 08                	je     f0105719 <strnlen+0x1f>
f0105711:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105715:	75 f3                	jne    f010570a <strnlen+0x10>
f0105717:	89 c2                	mov    %eax,%edx
	return n;
}
f0105719:	89 d0                	mov    %edx,%eax
f010571b:	5d                   	pop    %ebp
f010571c:	c3                   	ret    

f010571d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010571d:	55                   	push   %ebp
f010571e:	89 e5                	mov    %esp,%ebp
f0105720:	53                   	push   %ebx
f0105721:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105724:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105727:	b8 00 00 00 00       	mov    $0x0,%eax
f010572c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0105730:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0105733:	83 c0 01             	add    $0x1,%eax
f0105736:	84 d2                	test   %dl,%dl
f0105738:	75 f2                	jne    f010572c <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010573a:	89 c8                	mov    %ecx,%eax
f010573c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010573f:	c9                   	leave  
f0105740:	c3                   	ret    

f0105741 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105741:	55                   	push   %ebp
f0105742:	89 e5                	mov    %esp,%ebp
f0105744:	53                   	push   %ebx
f0105745:	83 ec 10             	sub    $0x10,%esp
f0105748:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010574b:	53                   	push   %ebx
f010574c:	e8 91 ff ff ff       	call   f01056e2 <strlen>
f0105751:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105754:	ff 75 0c             	push   0xc(%ebp)
f0105757:	01 d8                	add    %ebx,%eax
f0105759:	50                   	push   %eax
f010575a:	e8 be ff ff ff       	call   f010571d <strcpy>
	return dst;
}
f010575f:	89 d8                	mov    %ebx,%eax
f0105761:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105764:	c9                   	leave  
f0105765:	c3                   	ret    

f0105766 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105766:	55                   	push   %ebp
f0105767:	89 e5                	mov    %esp,%ebp
f0105769:	56                   	push   %esi
f010576a:	53                   	push   %ebx
f010576b:	8b 75 08             	mov    0x8(%ebp),%esi
f010576e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105771:	89 f3                	mov    %esi,%ebx
f0105773:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105776:	89 f0                	mov    %esi,%eax
f0105778:	eb 0f                	jmp    f0105789 <strncpy+0x23>
		*dst++ = *src;
f010577a:	83 c0 01             	add    $0x1,%eax
f010577d:	0f b6 0a             	movzbl (%edx),%ecx
f0105780:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105783:	80 f9 01             	cmp    $0x1,%cl
f0105786:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0105789:	39 d8                	cmp    %ebx,%eax
f010578b:	75 ed                	jne    f010577a <strncpy+0x14>
	}
	return ret;
}
f010578d:	89 f0                	mov    %esi,%eax
f010578f:	5b                   	pop    %ebx
f0105790:	5e                   	pop    %esi
f0105791:	5d                   	pop    %ebp
f0105792:	c3                   	ret    

f0105793 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105793:	55                   	push   %ebp
f0105794:	89 e5                	mov    %esp,%ebp
f0105796:	56                   	push   %esi
f0105797:	53                   	push   %ebx
f0105798:	8b 75 08             	mov    0x8(%ebp),%esi
f010579b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010579e:	8b 55 10             	mov    0x10(%ebp),%edx
f01057a1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01057a3:	85 d2                	test   %edx,%edx
f01057a5:	74 21                	je     f01057c8 <strlcpy+0x35>
f01057a7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01057ab:	89 f2                	mov    %esi,%edx
f01057ad:	eb 09                	jmp    f01057b8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01057af:	83 c1 01             	add    $0x1,%ecx
f01057b2:	83 c2 01             	add    $0x1,%edx
f01057b5:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f01057b8:	39 c2                	cmp    %eax,%edx
f01057ba:	74 09                	je     f01057c5 <strlcpy+0x32>
f01057bc:	0f b6 19             	movzbl (%ecx),%ebx
f01057bf:	84 db                	test   %bl,%bl
f01057c1:	75 ec                	jne    f01057af <strlcpy+0x1c>
f01057c3:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01057c5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01057c8:	29 f0                	sub    %esi,%eax
}
f01057ca:	5b                   	pop    %ebx
f01057cb:	5e                   	pop    %esi
f01057cc:	5d                   	pop    %ebp
f01057cd:	c3                   	ret    

f01057ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01057ce:	55                   	push   %ebp
f01057cf:	89 e5                	mov    %esp,%ebp
f01057d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01057d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01057d7:	eb 06                	jmp    f01057df <strcmp+0x11>
		p++, q++;
f01057d9:	83 c1 01             	add    $0x1,%ecx
f01057dc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01057df:	0f b6 01             	movzbl (%ecx),%eax
f01057e2:	84 c0                	test   %al,%al
f01057e4:	74 04                	je     f01057ea <strcmp+0x1c>
f01057e6:	3a 02                	cmp    (%edx),%al
f01057e8:	74 ef                	je     f01057d9 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01057ea:	0f b6 c0             	movzbl %al,%eax
f01057ed:	0f b6 12             	movzbl (%edx),%edx
f01057f0:	29 d0                	sub    %edx,%eax
}
f01057f2:	5d                   	pop    %ebp
f01057f3:	c3                   	ret    

f01057f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01057f4:	55                   	push   %ebp
f01057f5:	89 e5                	mov    %esp,%ebp
f01057f7:	53                   	push   %ebx
f01057f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01057fb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01057fe:	89 c3                	mov    %eax,%ebx
f0105800:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105803:	eb 06                	jmp    f010580b <strncmp+0x17>
		n--, p++, q++;
f0105805:	83 c0 01             	add    $0x1,%eax
f0105808:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f010580b:	39 d8                	cmp    %ebx,%eax
f010580d:	74 18                	je     f0105827 <strncmp+0x33>
f010580f:	0f b6 08             	movzbl (%eax),%ecx
f0105812:	84 c9                	test   %cl,%cl
f0105814:	74 04                	je     f010581a <strncmp+0x26>
f0105816:	3a 0a                	cmp    (%edx),%cl
f0105818:	74 eb                	je     f0105805 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010581a:	0f b6 00             	movzbl (%eax),%eax
f010581d:	0f b6 12             	movzbl (%edx),%edx
f0105820:	29 d0                	sub    %edx,%eax
}
f0105822:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105825:	c9                   	leave  
f0105826:	c3                   	ret    
		return 0;
f0105827:	b8 00 00 00 00       	mov    $0x0,%eax
f010582c:	eb f4                	jmp    f0105822 <strncmp+0x2e>

f010582e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010582e:	55                   	push   %ebp
f010582f:	89 e5                	mov    %esp,%ebp
f0105831:	8b 45 08             	mov    0x8(%ebp),%eax
f0105834:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105838:	eb 03                	jmp    f010583d <strchr+0xf>
f010583a:	83 c0 01             	add    $0x1,%eax
f010583d:	0f b6 10             	movzbl (%eax),%edx
f0105840:	84 d2                	test   %dl,%dl
f0105842:	74 06                	je     f010584a <strchr+0x1c>
		if (*s == c)
f0105844:	38 ca                	cmp    %cl,%dl
f0105846:	75 f2                	jne    f010583a <strchr+0xc>
f0105848:	eb 05                	jmp    f010584f <strchr+0x21>
			return (char *) s;
	return 0;
f010584a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010584f:	5d                   	pop    %ebp
f0105850:	c3                   	ret    

f0105851 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105851:	55                   	push   %ebp
f0105852:	89 e5                	mov    %esp,%ebp
f0105854:	8b 45 08             	mov    0x8(%ebp),%eax
f0105857:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010585b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010585e:	38 ca                	cmp    %cl,%dl
f0105860:	74 09                	je     f010586b <strfind+0x1a>
f0105862:	84 d2                	test   %dl,%dl
f0105864:	74 05                	je     f010586b <strfind+0x1a>
	for (; *s; s++)
f0105866:	83 c0 01             	add    $0x1,%eax
f0105869:	eb f0                	jmp    f010585b <strfind+0xa>
			break;
	return (char *) s;
}
f010586b:	5d                   	pop    %ebp
f010586c:	c3                   	ret    

f010586d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010586d:	55                   	push   %ebp
f010586e:	89 e5                	mov    %esp,%ebp
f0105870:	57                   	push   %edi
f0105871:	56                   	push   %esi
f0105872:	53                   	push   %ebx
f0105873:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105876:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105879:	85 c9                	test   %ecx,%ecx
f010587b:	74 2f                	je     f01058ac <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010587d:	89 f8                	mov    %edi,%eax
f010587f:	09 c8                	or     %ecx,%eax
f0105881:	a8 03                	test   $0x3,%al
f0105883:	75 21                	jne    f01058a6 <memset+0x39>
		c &= 0xFF;
f0105885:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105889:	89 d0                	mov    %edx,%eax
f010588b:	c1 e0 08             	shl    $0x8,%eax
f010588e:	89 d3                	mov    %edx,%ebx
f0105890:	c1 e3 18             	shl    $0x18,%ebx
f0105893:	89 d6                	mov    %edx,%esi
f0105895:	c1 e6 10             	shl    $0x10,%esi
f0105898:	09 f3                	or     %esi,%ebx
f010589a:	09 da                	or     %ebx,%edx
f010589c:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010589e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01058a1:	fc                   	cld    
f01058a2:	f3 ab                	rep stos %eax,%es:(%edi)
f01058a4:	eb 06                	jmp    f01058ac <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01058a6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01058a9:	fc                   	cld    
f01058aa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01058ac:	89 f8                	mov    %edi,%eax
f01058ae:	5b                   	pop    %ebx
f01058af:	5e                   	pop    %esi
f01058b0:	5f                   	pop    %edi
f01058b1:	5d                   	pop    %ebp
f01058b2:	c3                   	ret    

f01058b3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01058b3:	55                   	push   %ebp
f01058b4:	89 e5                	mov    %esp,%ebp
f01058b6:	57                   	push   %edi
f01058b7:	56                   	push   %esi
f01058b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01058bb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01058be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01058c1:	39 c6                	cmp    %eax,%esi
f01058c3:	73 32                	jae    f01058f7 <memmove+0x44>
f01058c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01058c8:	39 c2                	cmp    %eax,%edx
f01058ca:	76 2b                	jbe    f01058f7 <memmove+0x44>
		s += n;
		d += n;
f01058cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01058cf:	89 d6                	mov    %edx,%esi
f01058d1:	09 fe                	or     %edi,%esi
f01058d3:	09 ce                	or     %ecx,%esi
f01058d5:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01058db:	75 0e                	jne    f01058eb <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01058dd:	83 ef 04             	sub    $0x4,%edi
f01058e0:	8d 72 fc             	lea    -0x4(%edx),%esi
f01058e3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01058e6:	fd                   	std    
f01058e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01058e9:	eb 09                	jmp    f01058f4 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01058eb:	83 ef 01             	sub    $0x1,%edi
f01058ee:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01058f1:	fd                   	std    
f01058f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01058f4:	fc                   	cld    
f01058f5:	eb 1a                	jmp    f0105911 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01058f7:	89 f2                	mov    %esi,%edx
f01058f9:	09 c2                	or     %eax,%edx
f01058fb:	09 ca                	or     %ecx,%edx
f01058fd:	f6 c2 03             	test   $0x3,%dl
f0105900:	75 0a                	jne    f010590c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105902:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105905:	89 c7                	mov    %eax,%edi
f0105907:	fc                   	cld    
f0105908:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010590a:	eb 05                	jmp    f0105911 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f010590c:	89 c7                	mov    %eax,%edi
f010590e:	fc                   	cld    
f010590f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105911:	5e                   	pop    %esi
f0105912:	5f                   	pop    %edi
f0105913:	5d                   	pop    %ebp
f0105914:	c3                   	ret    

f0105915 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105915:	55                   	push   %ebp
f0105916:	89 e5                	mov    %esp,%ebp
f0105918:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010591b:	ff 75 10             	push   0x10(%ebp)
f010591e:	ff 75 0c             	push   0xc(%ebp)
f0105921:	ff 75 08             	push   0x8(%ebp)
f0105924:	e8 8a ff ff ff       	call   f01058b3 <memmove>
}
f0105929:	c9                   	leave  
f010592a:	c3                   	ret    

f010592b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010592b:	55                   	push   %ebp
f010592c:	89 e5                	mov    %esp,%ebp
f010592e:	56                   	push   %esi
f010592f:	53                   	push   %ebx
f0105930:	8b 45 08             	mov    0x8(%ebp),%eax
f0105933:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105936:	89 c6                	mov    %eax,%esi
f0105938:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010593b:	eb 06                	jmp    f0105943 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010593d:	83 c0 01             	add    $0x1,%eax
f0105940:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0105943:	39 f0                	cmp    %esi,%eax
f0105945:	74 14                	je     f010595b <memcmp+0x30>
		if (*s1 != *s2)
f0105947:	0f b6 08             	movzbl (%eax),%ecx
f010594a:	0f b6 1a             	movzbl (%edx),%ebx
f010594d:	38 d9                	cmp    %bl,%cl
f010594f:	74 ec                	je     f010593d <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0105951:	0f b6 c1             	movzbl %cl,%eax
f0105954:	0f b6 db             	movzbl %bl,%ebx
f0105957:	29 d8                	sub    %ebx,%eax
f0105959:	eb 05                	jmp    f0105960 <memcmp+0x35>
	}

	return 0;
f010595b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105960:	5b                   	pop    %ebx
f0105961:	5e                   	pop    %esi
f0105962:	5d                   	pop    %ebp
f0105963:	c3                   	ret    

f0105964 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105964:	55                   	push   %ebp
f0105965:	89 e5                	mov    %esp,%ebp
f0105967:	8b 45 08             	mov    0x8(%ebp),%eax
f010596a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010596d:	89 c2                	mov    %eax,%edx
f010596f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105972:	eb 03                	jmp    f0105977 <memfind+0x13>
f0105974:	83 c0 01             	add    $0x1,%eax
f0105977:	39 d0                	cmp    %edx,%eax
f0105979:	73 04                	jae    f010597f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f010597b:	38 08                	cmp    %cl,(%eax)
f010597d:	75 f5                	jne    f0105974 <memfind+0x10>
			break;
	return (void *) s;
}
f010597f:	5d                   	pop    %ebp
f0105980:	c3                   	ret    

f0105981 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105981:	55                   	push   %ebp
f0105982:	89 e5                	mov    %esp,%ebp
f0105984:	57                   	push   %edi
f0105985:	56                   	push   %esi
f0105986:	53                   	push   %ebx
f0105987:	8b 55 08             	mov    0x8(%ebp),%edx
f010598a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010598d:	eb 03                	jmp    f0105992 <strtol+0x11>
		s++;
f010598f:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0105992:	0f b6 02             	movzbl (%edx),%eax
f0105995:	3c 20                	cmp    $0x20,%al
f0105997:	74 f6                	je     f010598f <strtol+0xe>
f0105999:	3c 09                	cmp    $0x9,%al
f010599b:	74 f2                	je     f010598f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010599d:	3c 2b                	cmp    $0x2b,%al
f010599f:	74 2a                	je     f01059cb <strtol+0x4a>
	int neg = 0;
f01059a1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01059a6:	3c 2d                	cmp    $0x2d,%al
f01059a8:	74 2b                	je     f01059d5 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01059aa:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01059b0:	75 0f                	jne    f01059c1 <strtol+0x40>
f01059b2:	80 3a 30             	cmpb   $0x30,(%edx)
f01059b5:	74 28                	je     f01059df <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01059b7:	85 db                	test   %ebx,%ebx
f01059b9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01059be:	0f 44 d8             	cmove  %eax,%ebx
f01059c1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01059c6:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01059c9:	eb 46                	jmp    f0105a11 <strtol+0x90>
		s++;
f01059cb:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f01059ce:	bf 00 00 00 00       	mov    $0x0,%edi
f01059d3:	eb d5                	jmp    f01059aa <strtol+0x29>
		s++, neg = 1;
f01059d5:	83 c2 01             	add    $0x1,%edx
f01059d8:	bf 01 00 00 00       	mov    $0x1,%edi
f01059dd:	eb cb                	jmp    f01059aa <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01059df:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01059e3:	74 0e                	je     f01059f3 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f01059e5:	85 db                	test   %ebx,%ebx
f01059e7:	75 d8                	jne    f01059c1 <strtol+0x40>
		s++, base = 8;
f01059e9:	83 c2 01             	add    $0x1,%edx
f01059ec:	bb 08 00 00 00       	mov    $0x8,%ebx
f01059f1:	eb ce                	jmp    f01059c1 <strtol+0x40>
		s += 2, base = 16;
f01059f3:	83 c2 02             	add    $0x2,%edx
f01059f6:	bb 10 00 00 00       	mov    $0x10,%ebx
f01059fb:	eb c4                	jmp    f01059c1 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01059fd:	0f be c0             	movsbl %al,%eax
f0105a00:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105a03:	3b 45 10             	cmp    0x10(%ebp),%eax
f0105a06:	7d 3a                	jge    f0105a42 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105a08:	83 c2 01             	add    $0x1,%edx
f0105a0b:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0105a0f:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0105a11:	0f b6 02             	movzbl (%edx),%eax
f0105a14:	8d 70 d0             	lea    -0x30(%eax),%esi
f0105a17:	89 f3                	mov    %esi,%ebx
f0105a19:	80 fb 09             	cmp    $0x9,%bl
f0105a1c:	76 df                	jbe    f01059fd <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0105a1e:	8d 70 9f             	lea    -0x61(%eax),%esi
f0105a21:	89 f3                	mov    %esi,%ebx
f0105a23:	80 fb 19             	cmp    $0x19,%bl
f0105a26:	77 08                	ja     f0105a30 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0105a28:	0f be c0             	movsbl %al,%eax
f0105a2b:	83 e8 57             	sub    $0x57,%eax
f0105a2e:	eb d3                	jmp    f0105a03 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0105a30:	8d 70 bf             	lea    -0x41(%eax),%esi
f0105a33:	89 f3                	mov    %esi,%ebx
f0105a35:	80 fb 19             	cmp    $0x19,%bl
f0105a38:	77 08                	ja     f0105a42 <strtol+0xc1>
			dig = *s - 'A' + 10;
f0105a3a:	0f be c0             	movsbl %al,%eax
f0105a3d:	83 e8 37             	sub    $0x37,%eax
f0105a40:	eb c1                	jmp    f0105a03 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105a42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105a46:	74 05                	je     f0105a4d <strtol+0xcc>
		*endptr = (char *) s;
f0105a48:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105a4b:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0105a4d:	89 c8                	mov    %ecx,%eax
f0105a4f:	f7 d8                	neg    %eax
f0105a51:	85 ff                	test   %edi,%edi
f0105a53:	0f 45 c8             	cmovne %eax,%ecx
}
f0105a56:	89 c8                	mov    %ecx,%eax
f0105a58:	5b                   	pop    %ebx
f0105a59:	5e                   	pop    %esi
f0105a5a:	5f                   	pop    %edi
f0105a5b:	5d                   	pop    %ebp
f0105a5c:	c3                   	ret    
f0105a5d:	66 90                	xchg   %ax,%ax
f0105a5f:	90                   	nop

f0105a60 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105a60:	fa                   	cli    

	xorw    %ax, %ax
f0105a61:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105a63:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a65:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a67:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105a69:	0f 01 16             	lgdtl  (%esi)
f0105a6c:	74 70                	je     f0105ade <mpsearch1+0x3>
	movl    %cr0, %eax
f0105a6e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105a71:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105a75:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105a78:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105a7e:	08 00                	or     %al,(%eax)

f0105a80 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105a80:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105a84:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a86:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a88:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105a8a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105a8e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105a90:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105a92:	b8 00 60 12 00       	mov    $0x126000,%eax
	movl    %eax, %cr3
f0105a97:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105a9a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105a9d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105aa2:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105aa5:	8b 25 04 60 2b f0    	mov    0xf02b6004,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105aab:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105ab0:	b8 d1 01 10 f0       	mov    $0xf01001d1,%eax
	call    *%eax
f0105ab5:	ff d0                	call   *%eax

f0105ab7 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105ab7:	eb fe                	jmp    f0105ab7 <spin>
f0105ab9:	8d 76 00             	lea    0x0(%esi),%esi

f0105abc <gdt>:
	...
f0105ac4:	ff                   	(bad)  
f0105ac5:	ff 00                	incl   (%eax)
f0105ac7:	00 00                	add    %al,(%eax)
f0105ac9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105ad0:	00                   	.byte 0x0
f0105ad1:	92                   	xchg   %eax,%edx
f0105ad2:	cf                   	iret   
	...

f0105ad4 <gdtdesc>:
f0105ad4:	17                   	pop    %ss
f0105ad5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105ada <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105ada:	90                   	nop

f0105adb <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105adb:	55                   	push   %ebp
f0105adc:	89 e5                	mov    %esp,%ebp
f0105ade:	57                   	push   %edi
f0105adf:	56                   	push   %esi
f0105ae0:	53                   	push   %ebx
f0105ae1:	83 ec 1c             	sub    $0x1c,%esp
f0105ae4:	89 c6                	mov    %eax,%esi
	if (PGNUM(pa) >= npages)
f0105ae6:	8b 0d 60 62 2b f0    	mov    0xf02b6260,%ecx
f0105aec:	c1 e8 0c             	shr    $0xc,%eax
f0105aef:	39 c8                	cmp    %ecx,%eax
f0105af1:	73 22                	jae    f0105b15 <mpsearch1+0x3a>
	return (void *)(pa + KERNBASE);
f0105af3:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105af9:	8d 04 32             	lea    (%edx,%esi,1),%eax
	if (PGNUM(pa) >= npages)
f0105afc:	89 c2                	mov    %eax,%edx
f0105afe:	c1 ea 0c             	shr    $0xc,%edx
f0105b01:	39 ca                	cmp    %ecx,%edx
f0105b03:	73 22                	jae    f0105b27 <mpsearch1+0x4c>
	return (void *)(pa + KERNBASE);
f0105b05:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0105b0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b0d:	81 ee f0 ff ff 0f    	sub    $0xffffff0,%esi

	for (; mp < end; mp++)
f0105b13:	eb 2a                	jmp    f0105b3f <mpsearch1+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b15:	56                   	push   %esi
f0105b16:	68 64 6d 10 f0       	push   $0xf0106d64
f0105b1b:	6a 58                	push   $0x58
f0105b1d:	68 7d 8a 10 f0       	push   $0xf0108a7d
f0105b22:	e8 19 a5 ff ff       	call   f0100040 <_panic>
f0105b27:	50                   	push   %eax
f0105b28:	68 64 6d 10 f0       	push   $0xf0106d64
f0105b2d:	6a 58                	push   $0x58
f0105b2f:	68 7d 8a 10 f0       	push   $0xf0108a7d
f0105b34:	e8 07 a5 ff ff       	call   f0100040 <_panic>
f0105b39:	83 c7 10             	add    $0x10,%edi
f0105b3c:	83 c6 10             	add    $0x10,%esi
f0105b3f:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0105b42:	73 2b                	jae    f0105b6f <mpsearch1+0x94>
f0105b44:	89 fb                	mov    %edi,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105b46:	83 ec 04             	sub    $0x4,%esp
f0105b49:	6a 04                	push   $0x4
f0105b4b:	68 8d 8a 10 f0       	push   $0xf0108a8d
f0105b50:	57                   	push   %edi
f0105b51:	e8 d5 fd ff ff       	call   f010592b <memcmp>
f0105b56:	83 c4 10             	add    $0x10,%esp
f0105b59:	85 c0                	test   %eax,%eax
f0105b5b:	75 dc                	jne    f0105b39 <mpsearch1+0x5e>
		sum += ((uint8_t *)addr)[i];
f0105b5d:	0f b6 13             	movzbl (%ebx),%edx
f0105b60:	01 d0                	add    %edx,%eax
	for (i = 0; i < len; i++)
f0105b62:	83 c3 01             	add    $0x1,%ebx
f0105b65:	39 f3                	cmp    %esi,%ebx
f0105b67:	75 f4                	jne    f0105b5d <mpsearch1+0x82>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105b69:	84 c0                	test   %al,%al
f0105b6b:	75 cc                	jne    f0105b39 <mpsearch1+0x5e>
f0105b6d:	eb 05                	jmp    f0105b74 <mpsearch1+0x99>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105b6f:	bf 00 00 00 00       	mov    $0x0,%edi
}
f0105b74:	89 f8                	mov    %edi,%eax
f0105b76:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b79:	5b                   	pop    %ebx
f0105b7a:	5e                   	pop    %esi
f0105b7b:	5f                   	pop    %edi
f0105b7c:	5d                   	pop    %ebp
f0105b7d:	c3                   	ret    

f0105b7e <mp_init>:
}

//通过读取位于BIOS内存区域中的MP配置表来获取该信息。
void
mp_init(void)
{
f0105b7e:	55                   	push   %ebp
f0105b7f:	89 e5                	mov    %esp,%ebp
f0105b81:	57                   	push   %edi
f0105b82:	56                   	push   %esi
f0105b83:	53                   	push   %ebx
f0105b84:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105b87:	c7 05 08 70 2f f0 20 	movl   $0xf02f7020,0xf02f7008
f0105b8e:	70 2f f0 
	if (PGNUM(pa) >= npages)
f0105b91:	83 3d 60 62 2b f0 00 	cmpl   $0x0,0xf02b6260
f0105b98:	0f 84 86 00 00 00    	je     f0105c24 <mp_init+0xa6>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105b9e:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105ba5:	85 c0                	test   %eax,%eax
f0105ba7:	0f 84 8d 00 00 00    	je     f0105c3a <mp_init+0xbc>
		p <<= 4;	// Translate from segment to PA
f0105bad:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105bb0:	ba 00 04 00 00       	mov    $0x400,%edx
f0105bb5:	e8 21 ff ff ff       	call   f0105adb <mpsearch1>
f0105bba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105bbd:	85 c0                	test   %eax,%eax
f0105bbf:	75 1a                	jne    f0105bdb <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f0105bc1:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105bc6:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105bcb:	e8 0b ff ff ff       	call   f0105adb <mpsearch1>
f0105bd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0105bd3:	85 c0                	test   %eax,%eax
f0105bd5:	0f 84 20 02 00 00    	je     f0105dfb <mp_init+0x27d>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105bdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105bde:	8b 58 04             	mov    0x4(%eax),%ebx
f0105be1:	85 db                	test   %ebx,%ebx
f0105be3:	74 7a                	je     f0105c5f <mp_init+0xe1>
f0105be5:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105be9:	75 74                	jne    f0105c5f <mp_init+0xe1>
f0105beb:	89 d8                	mov    %ebx,%eax
f0105bed:	c1 e8 0c             	shr    $0xc,%eax
f0105bf0:	3b 05 60 62 2b f0    	cmp    0xf02b6260,%eax
f0105bf6:	73 7c                	jae    f0105c74 <mp_init+0xf6>
	return (void *)(pa + KERNBASE);
f0105bf8:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0105bfe:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105c00:	83 ec 04             	sub    $0x4,%esp
f0105c03:	6a 04                	push   $0x4
f0105c05:	68 92 8a 10 f0       	push   $0xf0108a92
f0105c0a:	53                   	push   %ebx
f0105c0b:	e8 1b fd ff ff       	call   f010592b <memcmp>
f0105c10:	83 c4 10             	add    $0x10,%esp
f0105c13:	85 c0                	test   %eax,%eax
f0105c15:	75 72                	jne    f0105c89 <mp_init+0x10b>
f0105c17:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105c1b:	01 df                	add    %ebx,%edi
	sum = 0;
f0105c1d:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0105c1f:	e9 82 00 00 00       	jmp    f0105ca6 <mp_init+0x128>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105c24:	68 00 04 00 00       	push   $0x400
f0105c29:	68 64 6d 10 f0       	push   $0xf0106d64
f0105c2e:	6a 70                	push   $0x70
f0105c30:	68 7d 8a 10 f0       	push   $0xf0108a7d
f0105c35:	e8 06 a4 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105c3a:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105c41:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105c44:	2d 00 04 00 00       	sub    $0x400,%eax
f0105c49:	ba 00 04 00 00       	mov    $0x400,%edx
f0105c4e:	e8 88 fe ff ff       	call   f0105adb <mpsearch1>
f0105c53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105c56:	85 c0                	test   %eax,%eax
f0105c58:	75 81                	jne    f0105bdb <mp_init+0x5d>
f0105c5a:	e9 62 ff ff ff       	jmp    f0105bc1 <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f0105c5f:	83 ec 0c             	sub    $0xc,%esp
f0105c62:	68 f0 88 10 f0       	push   $0xf01088f0
f0105c67:	e8 49 dd ff ff       	call   f01039b5 <cprintf>
		return NULL;
f0105c6c:	83 c4 10             	add    $0x10,%esp
f0105c6f:	e9 87 01 00 00       	jmp    f0105dfb <mp_init+0x27d>
f0105c74:	53                   	push   %ebx
f0105c75:	68 64 6d 10 f0       	push   $0xf0106d64
f0105c7a:	68 91 00 00 00       	push   $0x91
f0105c7f:	68 7d 8a 10 f0       	push   $0xf0108a7d
f0105c84:	e8 b7 a3 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105c89:	83 ec 0c             	sub    $0xc,%esp
f0105c8c:	68 20 89 10 f0       	push   $0xf0108920
f0105c91:	e8 1f dd ff ff       	call   f01039b5 <cprintf>
		return NULL;
f0105c96:	83 c4 10             	add    $0x10,%esp
f0105c99:	e9 5d 01 00 00       	jmp    f0105dfb <mp_init+0x27d>
		sum += ((uint8_t *)addr)[i];
f0105c9e:	0f b6 0b             	movzbl (%ebx),%ecx
f0105ca1:	01 ca                	add    %ecx,%edx
f0105ca3:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105ca6:	39 fb                	cmp    %edi,%ebx
f0105ca8:	75 f4                	jne    f0105c9e <mp_init+0x120>
	if (sum(conf, conf->length) != 0) {
f0105caa:	84 d2                	test   %dl,%dl
f0105cac:	75 16                	jne    f0105cc4 <mp_init+0x146>
	if (conf->version != 1 && conf->version != 4) {
f0105cae:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105cb2:	80 fa 01             	cmp    $0x1,%dl
f0105cb5:	74 05                	je     f0105cbc <mp_init+0x13e>
f0105cb7:	80 fa 04             	cmp    $0x4,%dl
f0105cba:	75 1d                	jne    f0105cd9 <mp_init+0x15b>
f0105cbc:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0105cc0:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f0105cc2:	eb 36                	jmp    f0105cfa <mp_init+0x17c>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105cc4:	83 ec 0c             	sub    $0xc,%esp
f0105cc7:	68 54 89 10 f0       	push   $0xf0108954
f0105ccc:	e8 e4 dc ff ff       	call   f01039b5 <cprintf>
		return NULL;
f0105cd1:	83 c4 10             	add    $0x10,%esp
f0105cd4:	e9 22 01 00 00       	jmp    f0105dfb <mp_init+0x27d>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105cd9:	83 ec 08             	sub    $0x8,%esp
f0105cdc:	0f b6 d2             	movzbl %dl,%edx
f0105cdf:	52                   	push   %edx
f0105ce0:	68 78 89 10 f0       	push   $0xf0108978
f0105ce5:	e8 cb dc ff ff       	call   f01039b5 <cprintf>
		return NULL;
f0105cea:	83 c4 10             	add    $0x10,%esp
f0105ced:	e9 09 01 00 00       	jmp    f0105dfb <mp_init+0x27d>
		sum += ((uint8_t *)addr)[i];
f0105cf2:	0f b6 13             	movzbl (%ebx),%edx
f0105cf5:	01 d0                	add    %edx,%eax
f0105cf7:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105cfa:	39 d9                	cmp    %ebx,%ecx
f0105cfc:	75 f4                	jne    f0105cf2 <mp_init+0x174>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105cfe:	02 46 2a             	add    0x2a(%esi),%al
f0105d01:	75 1c                	jne    f0105d1f <mp_init+0x1a1>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f0105d03:	c7 05 04 70 2f f0 01 	movl   $0x1,0xf02f7004
f0105d0a:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105d0d:	8b 46 24             	mov    0x24(%esi),%eax
f0105d10:	a3 c4 73 2f f0       	mov    %eax,0xf02f73c4

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d15:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105d18:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105d1d:	eb 4d                	jmp    f0105d6c <mp_init+0x1ee>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105d1f:	83 ec 0c             	sub    $0xc,%esp
f0105d22:	68 98 89 10 f0       	push   $0xf0108998
f0105d27:	e8 89 dc ff ff       	call   f01039b5 <cprintf>
		return NULL;
f0105d2c:	83 c4 10             	add    $0x10,%esp
f0105d2f:	e9 c7 00 00 00       	jmp    f0105dfb <mp_init+0x27d>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105d34:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105d38:	74 11                	je     f0105d4b <mp_init+0x1cd>
				bootcpu = &cpus[ncpu];
f0105d3a:	6b 05 00 70 2f f0 74 	imul   $0x74,0xf02f7000,%eax
f0105d41:	05 20 70 2f f0       	add    $0xf02f7020,%eax
f0105d46:	a3 08 70 2f f0       	mov    %eax,0xf02f7008
			if (ncpu < NCPU) {
f0105d4b:	a1 00 70 2f f0       	mov    0xf02f7000,%eax
f0105d50:	83 f8 07             	cmp    $0x7,%eax
f0105d53:	7f 33                	jg     f0105d88 <mp_init+0x20a>
				cpus[ncpu].cpu_id = ncpu;
f0105d55:	6b d0 74             	imul   $0x74,%eax,%edx
f0105d58:	88 82 20 70 2f f0    	mov    %al,-0xfd08fe0(%edx)
				ncpu++;
f0105d5e:	83 c0 01             	add    $0x1,%eax
f0105d61:	a3 00 70 2f f0       	mov    %eax,0xf02f7000
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105d66:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d69:	83 c3 01             	add    $0x1,%ebx
f0105d6c:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105d70:	39 d8                	cmp    %ebx,%eax
f0105d72:	76 4f                	jbe    f0105dc3 <mp_init+0x245>
		switch (*p) {
f0105d74:	0f b6 07             	movzbl (%edi),%eax
f0105d77:	84 c0                	test   %al,%al
f0105d79:	74 b9                	je     f0105d34 <mp_init+0x1b6>
f0105d7b:	8d 50 ff             	lea    -0x1(%eax),%edx
f0105d7e:	80 fa 03             	cmp    $0x3,%dl
f0105d81:	77 1c                	ja     f0105d9f <mp_init+0x221>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105d83:	83 c7 08             	add    $0x8,%edi
			continue;
f0105d86:	eb e1                	jmp    f0105d69 <mp_init+0x1eb>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105d88:	83 ec 08             	sub    $0x8,%esp
f0105d8b:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105d8f:	50                   	push   %eax
f0105d90:	68 c8 89 10 f0       	push   $0xf01089c8
f0105d95:	e8 1b dc ff ff       	call   f01039b5 <cprintf>
f0105d9a:	83 c4 10             	add    $0x10,%esp
f0105d9d:	eb c7                	jmp    f0105d66 <mp_init+0x1e8>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d9f:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105da2:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105da5:	50                   	push   %eax
f0105da6:	68 f0 89 10 f0       	push   $0xf01089f0
f0105dab:	e8 05 dc ff ff       	call   f01039b5 <cprintf>
			ismp = 0;
f0105db0:	c7 05 04 70 2f f0 00 	movl   $0x0,0xf02f7004
f0105db7:	00 00 00 
			i = conf->entry;
f0105dba:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0105dbe:	83 c4 10             	add    $0x10,%esp
f0105dc1:	eb a6                	jmp    f0105d69 <mp_init+0x1eb>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105dc3:	a1 08 70 2f f0       	mov    0xf02f7008,%eax
f0105dc8:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105dcf:	83 3d 04 70 2f f0 00 	cmpl   $0x0,0xf02f7004
f0105dd6:	74 2b                	je     f0105e03 <mp_init+0x285>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105dd8:	83 ec 04             	sub    $0x4,%esp
f0105ddb:	ff 35 00 70 2f f0    	push   0xf02f7000
f0105de1:	0f b6 00             	movzbl (%eax),%eax
f0105de4:	50                   	push   %eax
f0105de5:	68 97 8a 10 f0       	push   $0xf0108a97
f0105dea:	e8 c6 db ff ff       	call   f01039b5 <cprintf>

	if (mp->imcrp) {
f0105def:	83 c4 10             	add    $0x10,%esp
f0105df2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105df5:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105df9:	75 2e                	jne    f0105e29 <mp_init+0x2ab>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105dfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105dfe:	5b                   	pop    %ebx
f0105dff:	5e                   	pop    %esi
f0105e00:	5f                   	pop    %edi
f0105e01:	5d                   	pop    %ebp
f0105e02:	c3                   	ret    
		ncpu = 1;
f0105e03:	c7 05 00 70 2f f0 01 	movl   $0x1,0xf02f7000
f0105e0a:	00 00 00 
		lapicaddr = 0;
f0105e0d:	c7 05 c4 73 2f f0 00 	movl   $0x0,0xf02f73c4
f0105e14:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105e17:	83 ec 0c             	sub    $0xc,%esp
f0105e1a:	68 10 8a 10 f0       	push   $0xf0108a10
f0105e1f:	e8 91 db ff ff       	call   f01039b5 <cprintf>
		return;
f0105e24:	83 c4 10             	add    $0x10,%esp
f0105e27:	eb d2                	jmp    f0105dfb <mp_init+0x27d>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105e29:	83 ec 0c             	sub    $0xc,%esp
f0105e2c:	68 3c 8a 10 f0       	push   $0xf0108a3c
f0105e31:	e8 7f db ff ff       	call   f01039b5 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105e36:	b8 70 00 00 00       	mov    $0x70,%eax
f0105e3b:	ba 22 00 00 00       	mov    $0x22,%edx
f0105e40:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105e41:	ba 23 00 00 00       	mov    $0x23,%edx
f0105e46:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105e47:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105e4a:	ee                   	out    %al,(%dx)
}
f0105e4b:	83 c4 10             	add    $0x10,%esp
f0105e4e:	eb ab                	jmp    f0105dfb <mp_init+0x27d>

f0105e50 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0105e50:	8b 0d c0 73 2f f0    	mov    0xf02f73c0,%ecx
f0105e56:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105e59:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105e5b:	a1 c0 73 2f f0       	mov    0xf02f73c0,%eax
f0105e60:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105e63:	c3                   	ret    

f0105e64 <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f0105e64:	8b 15 c0 73 2f f0    	mov    0xf02f73c0,%edx
		return lapic[ID] >> 24;
	return 0;
f0105e6a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105e6f:	85 d2                	test   %edx,%edx
f0105e71:	74 06                	je     f0105e79 <cpunum+0x15>
		return lapic[ID] >> 24;
f0105e73:	8b 42 20             	mov    0x20(%edx),%eax
f0105e76:	c1 e8 18             	shr    $0x18,%eax
}
f0105e79:	c3                   	ret    

f0105e7a <lapic_init>:
	if (!lapicaddr)
f0105e7a:	a1 c4 73 2f f0       	mov    0xf02f73c4,%eax
f0105e7f:	85 c0                	test   %eax,%eax
f0105e81:	75 01                	jne    f0105e84 <lapic_init+0xa>
f0105e83:	c3                   	ret    
{
f0105e84:	55                   	push   %ebp
f0105e85:	89 e5                	mov    %esp,%ebp
f0105e87:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105e8a:	68 00 10 00 00       	push   $0x1000
f0105e8f:	50                   	push   %eax
f0105e90:	e8 41 b4 ff ff       	call   f01012d6 <mmio_map_region>
f0105e95:	a3 c0 73 2f f0       	mov    %eax,0xf02f73c0
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105e9a:	ba 27 01 00 00       	mov    $0x127,%edx
f0105e9f:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105ea4:	e8 a7 ff ff ff       	call   f0105e50 <lapicw>
	lapicw(TDCR, X1);
f0105ea9:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105eae:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105eb3:	e8 98 ff ff ff       	call   f0105e50 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105eb8:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105ebd:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105ec2:	e8 89 ff ff ff       	call   f0105e50 <lapicw>
	lapicw(TICR, 10000000); 
f0105ec7:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105ecc:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105ed1:	e8 7a ff ff ff       	call   f0105e50 <lapicw>
	if (thiscpu != bootcpu)
f0105ed6:	e8 89 ff ff ff       	call   f0105e64 <cpunum>
f0105edb:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ede:	05 20 70 2f f0       	add    $0xf02f7020,%eax
f0105ee3:	83 c4 10             	add    $0x10,%esp
f0105ee6:	39 05 08 70 2f f0    	cmp    %eax,0xf02f7008
f0105eec:	74 0f                	je     f0105efd <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f0105eee:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ef3:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105ef8:	e8 53 ff ff ff       	call   f0105e50 <lapicw>
	lapicw(LINT1, MASKED);
f0105efd:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f02:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105f07:	e8 44 ff ff ff       	call   f0105e50 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105f0c:	a1 c0 73 2f f0       	mov    0xf02f73c0,%eax
f0105f11:	8b 40 30             	mov    0x30(%eax),%eax
f0105f14:	c1 e8 10             	shr    $0x10,%eax
f0105f17:	a8 fc                	test   $0xfc,%al
f0105f19:	75 7c                	jne    f0105f97 <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105f1b:	ba 33 00 00 00       	mov    $0x33,%edx
f0105f20:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105f25:	e8 26 ff ff ff       	call   f0105e50 <lapicw>
	lapicw(ESR, 0);
f0105f2a:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f2f:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105f34:	e8 17 ff ff ff       	call   f0105e50 <lapicw>
	lapicw(ESR, 0);
f0105f39:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f3e:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105f43:	e8 08 ff ff ff       	call   f0105e50 <lapicw>
	lapicw(EOI, 0);
f0105f48:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f4d:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f52:	e8 f9 fe ff ff       	call   f0105e50 <lapicw>
	lapicw(ICRHI, 0);
f0105f57:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f5c:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f61:	e8 ea fe ff ff       	call   f0105e50 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105f66:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105f6b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f70:	e8 db fe ff ff       	call   f0105e50 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105f75:	8b 15 c0 73 2f f0    	mov    0xf02f73c0,%edx
f0105f7b:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105f81:	f6 c4 10             	test   $0x10,%ah
f0105f84:	75 f5                	jne    f0105f7b <lapic_init+0x101>
	lapicw(TPR, 0);
f0105f86:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f8b:	b8 20 00 00 00       	mov    $0x20,%eax
f0105f90:	e8 bb fe ff ff       	call   f0105e50 <lapicw>
}
f0105f95:	c9                   	leave  
f0105f96:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0105f97:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f9c:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105fa1:	e8 aa fe ff ff       	call   f0105e50 <lapicw>
f0105fa6:	e9 70 ff ff ff       	jmp    f0105f1b <lapic_init+0xa1>

f0105fab <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105fab:	83 3d c0 73 2f f0 00 	cmpl   $0x0,0xf02f73c0
f0105fb2:	74 17                	je     f0105fcb <lapic_eoi+0x20>
{
f0105fb4:	55                   	push   %ebp
f0105fb5:	89 e5                	mov    %esp,%ebp
f0105fb7:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0105fba:	ba 00 00 00 00       	mov    $0x0,%edx
f0105fbf:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105fc4:	e8 87 fe ff ff       	call   f0105e50 <lapicw>
}
f0105fc9:	c9                   	leave  
f0105fca:	c3                   	ret    
f0105fcb:	c3                   	ret    

f0105fcc <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105fcc:	55                   	push   %ebp
f0105fcd:	89 e5                	mov    %esp,%ebp
f0105fcf:	56                   	push   %esi
f0105fd0:	53                   	push   %ebx
f0105fd1:	8b 75 08             	mov    0x8(%ebp),%esi
f0105fd4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105fd7:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105fdc:	ba 70 00 00 00       	mov    $0x70,%edx
f0105fe1:	ee                   	out    %al,(%dx)
f0105fe2:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105fe7:	ba 71 00 00 00       	mov    $0x71,%edx
f0105fec:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105fed:	83 3d 60 62 2b f0 00 	cmpl   $0x0,0xf02b6260
f0105ff4:	74 7e                	je     f0106074 <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105ff6:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105ffd:	00 00 
	wrv[1] = addr >> 4;
f0105fff:	89 d8                	mov    %ebx,%eax
f0106001:	c1 e8 04             	shr    $0x4,%eax
f0106004:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010600a:	c1 e6 18             	shl    $0x18,%esi
f010600d:	89 f2                	mov    %esi,%edx
f010600f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106014:	e8 37 fe ff ff       	call   f0105e50 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106019:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010601e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106023:	e8 28 fe ff ff       	call   f0105e50 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106028:	ba 00 85 00 00       	mov    $0x8500,%edx
f010602d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106032:	e8 19 fe ff ff       	call   f0105e50 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106037:	c1 eb 0c             	shr    $0xc,%ebx
f010603a:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f010603d:	89 f2                	mov    %esi,%edx
f010603f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106044:	e8 07 fe ff ff       	call   f0105e50 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106049:	89 da                	mov    %ebx,%edx
f010604b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106050:	e8 fb fd ff ff       	call   f0105e50 <lapicw>
		lapicw(ICRHI, apicid << 24);
f0106055:	89 f2                	mov    %esi,%edx
f0106057:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010605c:	e8 ef fd ff ff       	call   f0105e50 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106061:	89 da                	mov    %ebx,%edx
f0106063:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106068:	e8 e3 fd ff ff       	call   f0105e50 <lapicw>
		microdelay(200);
	}
}
f010606d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106070:	5b                   	pop    %ebx
f0106071:	5e                   	pop    %esi
f0106072:	5d                   	pop    %ebp
f0106073:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106074:	68 67 04 00 00       	push   $0x467
f0106079:	68 64 6d 10 f0       	push   $0xf0106d64
f010607e:	68 99 00 00 00       	push   $0x99
f0106083:	68 b4 8a 10 f0       	push   $0xf0108ab4
f0106088:	e8 b3 9f ff ff       	call   f0100040 <_panic>

f010608d <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010608d:	55                   	push   %ebp
f010608e:	89 e5                	mov    %esp,%ebp
f0106090:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106093:	8b 55 08             	mov    0x8(%ebp),%edx
f0106096:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010609c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060a1:	e8 aa fd ff ff       	call   f0105e50 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01060a6:	8b 15 c0 73 2f f0    	mov    0xf02f73c0,%edx
f01060ac:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01060b2:	f6 c4 10             	test   $0x10,%ah
f01060b5:	75 f5                	jne    f01060ac <lapic_ipi+0x1f>
		;
}
f01060b7:	c9                   	leave  
f01060b8:	c3                   	ret    

f01060b9 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01060b9:	55                   	push   %ebp
f01060ba:	89 e5                	mov    %esp,%ebp
f01060bc:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01060bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01060c5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01060c8:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01060cb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01060d2:	5d                   	pop    %ebp
f01060d3:	c3                   	ret    

f01060d4 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01060d4:	55                   	push   %ebp
f01060d5:	89 e5                	mov    %esp,%ebp
f01060d7:	56                   	push   %esi
f01060d8:	53                   	push   %ebx
f01060d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f01060dc:	83 3b 00             	cmpl   $0x0,(%ebx)
f01060df:	75 07                	jne    f01060e8 <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f01060e1:	ba 01 00 00 00       	mov    $0x1,%edx
f01060e6:	eb 34                	jmp    f010611c <spin_lock+0x48>
f01060e8:	8b 73 08             	mov    0x8(%ebx),%esi
f01060eb:	e8 74 fd ff ff       	call   f0105e64 <cpunum>
f01060f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01060f3:	05 20 70 2f f0       	add    $0xf02f7020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01060f8:	39 c6                	cmp    %eax,%esi
f01060fa:	75 e5                	jne    f01060e1 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01060fc:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01060ff:	e8 60 fd ff ff       	call   f0105e64 <cpunum>
f0106104:	83 ec 0c             	sub    $0xc,%esp
f0106107:	53                   	push   %ebx
f0106108:	50                   	push   %eax
f0106109:	68 c4 8a 10 f0       	push   $0xf0108ac4
f010610e:	6a 41                	push   $0x41
f0106110:	68 26 8b 10 f0       	push   $0xf0108b26
f0106115:	e8 26 9f ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010611a:	f3 90                	pause  
f010611c:	89 d0                	mov    %edx,%eax
f010611e:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106121:	85 c0                	test   %eax,%eax
f0106123:	75 f5                	jne    f010611a <spin_lock+0x46>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106125:	e8 3a fd ff ff       	call   f0105e64 <cpunum>
f010612a:	6b c0 74             	imul   $0x74,%eax,%eax
f010612d:	05 20 70 2f f0       	add    $0xf02f7020,%eax
f0106132:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));//I guess it means moving ebp register value to local variable. 
f0106135:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106137:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010613c:	83 f8 09             	cmp    $0x9,%eax
f010613f:	7f 21                	jg     f0106162 <spin_lock+0x8e>
f0106141:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106147:	76 19                	jbe    f0106162 <spin_lock+0x8e>
		pcs[i] = ebp[1];          // saved %eip
f0106149:	8b 4a 04             	mov    0x4(%edx),%ecx
f010614c:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106150:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106152:	83 c0 01             	add    $0x1,%eax
f0106155:	eb e5                	jmp    f010613c <spin_lock+0x68>
		pcs[i] = 0;
f0106157:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f010615e:	00 
	for (; i < 10; i++)
f010615f:	83 c0 01             	add    $0x1,%eax
f0106162:	83 f8 09             	cmp    $0x9,%eax
f0106165:	7e f0                	jle    f0106157 <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f0106167:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010616a:	5b                   	pop    %ebx
f010616b:	5e                   	pop    %esi
f010616c:	5d                   	pop    %ebp
f010616d:	c3                   	ret    

f010616e <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010616e:	55                   	push   %ebp
f010616f:	89 e5                	mov    %esp,%ebp
f0106171:	57                   	push   %edi
f0106172:	56                   	push   %esi
f0106173:	53                   	push   %ebx
f0106174:	83 ec 4c             	sub    $0x4c,%esp
f0106177:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f010617a:	83 3e 00             	cmpl   $0x0,(%esi)
f010617d:	75 35                	jne    f01061b4 <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010617f:	83 ec 04             	sub    $0x4,%esp
f0106182:	6a 28                	push   $0x28
f0106184:	8d 46 0c             	lea    0xc(%esi),%eax
f0106187:	50                   	push   %eax
f0106188:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010618b:	53                   	push   %ebx
f010618c:	e8 22 f7 ff ff       	call   f01058b3 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106191:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106194:	0f b6 38             	movzbl (%eax),%edi
f0106197:	8b 76 04             	mov    0x4(%esi),%esi
f010619a:	e8 c5 fc ff ff       	call   f0105e64 <cpunum>
f010619f:	57                   	push   %edi
f01061a0:	56                   	push   %esi
f01061a1:	50                   	push   %eax
f01061a2:	68 f0 8a 10 f0       	push   $0xf0108af0
f01061a7:	e8 09 d8 ff ff       	call   f01039b5 <cprintf>
f01061ac:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01061af:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01061b2:	eb 4e                	jmp    f0106202 <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f01061b4:	8b 5e 08             	mov    0x8(%esi),%ebx
f01061b7:	e8 a8 fc ff ff       	call   f0105e64 <cpunum>
f01061bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01061bf:	05 20 70 2f f0       	add    $0xf02f7020,%eax
	if (!holding(lk)) {
f01061c4:	39 c3                	cmp    %eax,%ebx
f01061c6:	75 b7                	jne    f010617f <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f01061c8:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01061cf:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f01061d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01061db:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01061de:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01061e1:	5b                   	pop    %ebx
f01061e2:	5e                   	pop    %esi
f01061e3:	5f                   	pop    %edi
f01061e4:	5d                   	pop    %ebp
f01061e5:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f01061e6:	83 ec 08             	sub    $0x8,%esp
f01061e9:	ff 36                	push   (%esi)
f01061eb:	68 4d 8b 10 f0       	push   $0xf0108b4d
f01061f0:	e8 c0 d7 ff ff       	call   f01039b5 <cprintf>
f01061f5:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
f01061f8:	83 c3 04             	add    $0x4,%ebx
f01061fb:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01061fe:	39 c3                	cmp    %eax,%ebx
f0106200:	74 40                	je     f0106242 <spin_unlock+0xd4>
f0106202:	89 de                	mov    %ebx,%esi
f0106204:	8b 03                	mov    (%ebx),%eax
f0106206:	85 c0                	test   %eax,%eax
f0106208:	74 38                	je     f0106242 <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010620a:	83 ec 08             	sub    $0x8,%esp
f010620d:	57                   	push   %edi
f010620e:	50                   	push   %eax
f010620f:	e8 88 eb ff ff       	call   f0104d9c <debuginfo_eip>
f0106214:	83 c4 10             	add    $0x10,%esp
f0106217:	85 c0                	test   %eax,%eax
f0106219:	78 cb                	js     f01061e6 <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f010621b:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010621d:	83 ec 04             	sub    $0x4,%esp
f0106220:	89 c2                	mov    %eax,%edx
f0106222:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106225:	52                   	push   %edx
f0106226:	ff 75 b0             	push   -0x50(%ebp)
f0106229:	ff 75 b4             	push   -0x4c(%ebp)
f010622c:	ff 75 ac             	push   -0x54(%ebp)
f010622f:	ff 75 a8             	push   -0x58(%ebp)
f0106232:	50                   	push   %eax
f0106233:	68 36 8b 10 f0       	push   $0xf0108b36
f0106238:	e8 78 d7 ff ff       	call   f01039b5 <cprintf>
f010623d:	83 c4 20             	add    $0x20,%esp
f0106240:	eb b6                	jmp    f01061f8 <spin_unlock+0x8a>
		panic("spin_unlock");
f0106242:	83 ec 04             	sub    $0x4,%esp
f0106245:	68 55 8b 10 f0       	push   $0xf0108b55
f010624a:	6a 67                	push   $0x67
f010624c:	68 26 8b 10 f0       	push   $0xf0108b26
f0106251:	e8 ea 9d ff ff       	call   f0100040 <_panic>

f0106256 <e1000_transmit_init>:
}

/*传输*/
void
e1000_transmit_init()
{
f0106256:	55                   	push   %ebp
f0106257:	89 e5                	mov    %esp,%ebp
f0106259:	57                   	push   %edi
f010625a:	56                   	push   %esi
f010625b:	53                   	push   %ebx
f010625c:	83 ec 10             	sub    $0x10,%esp
	* 3. 初始化传输控制寄存器(TCTL) 包括：TCTL.EN置1； TCTL.PSP置1；TCTL.CT置为10h；TCTL.COLD置为40h。
	* 4. 参考IEEE 802.3 IPG标准 设置TIPG寄存器
	*/
	//1.操作描述符。这部分不在14.5中体现，我们需要参考3.3.3将它完成。
	// addr，length其实都应该用上这描述符后再赋值，但我们是静态内存，所以就直接对addr初始化了。
	memset(e1000_tx_desc_array, 0 , sizeof(struct e1000_tx_desc) * TX_DESC_ARRAY_SIZE);
f010625f:	68 00 02 00 00       	push   $0x200
f0106264:	6a 00                	push   $0x0
f0106266:	68 a0 39 34 f0       	push   $0xf03439a0
f010626b:	e8 fd f5 ff ff       	call   f010586d <memset>
f0106270:	ba e0 7b 33 f0       	mov    $0xf0337be0,%edx
f0106275:	b9 e0 7b 33 00       	mov    $0x337be0,%ecx
f010627a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010627f:	be a0 39 34 f0       	mov    $0xf03439a0,%esi
f0106284:	83 c4 10             	add    $0x10,%esp
f0106287:	b8 a0 39 34 f0       	mov    $0xf03439a0,%eax
	if ((uint32_t)kva < KERNBASE)
f010628c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0106292:	0f 86 8b 00 00 00    	jbe    f0106323 <e1000_transmit_init+0xcd>
	for (int i = 0; i < TX_DESC_ARRAY_SIZE; i++) {
		e1000_tx_desc_array[i].addr=PADDR(e1000_tx_buffer[i]);
f0106298:	89 08                	mov    %ecx,(%eax)
f010629a:	89 58 04             	mov    %ebx,0x4(%eax)
		e1000_tx_desc_array[i].cmd = E1000_TXD_CMD_RS | E1000_TXD_CMD_EOP;//设置RS位。由于每个包只用一个数据描述符，所以也需要设置EOP位
f010629d:	c6 40 0b 09          	movb   $0x9,0xb(%eax)
		e1000_tx_desc_array[i].status = E1000_TXD_STATUS_DD;//要置1, 不然第一轮直接就默认没有描述符用了
f01062a1:	c6 40 0c 01          	movb   $0x1,0xc(%eax)
	for (int i = 0; i < TX_DESC_ARRAY_SIZE; i++) {
f01062a5:	81 c2 ee 05 00 00    	add    $0x5ee,%edx
f01062ab:	81 c1 ee 05 00 00    	add    $0x5ee,%ecx
f01062b1:	83 d3 00             	adc    $0x0,%ebx
f01062b4:	83 c0 10             	add    $0x10,%eax
f01062b7:	39 f2                	cmp    %esi,%edx
f01062b9:	75 d1                	jne    f010628c <e1000_transmit_init+0x36>
	}
	//2.
	e1000[E1000_LOCATE(E1000_TDBAL) ]= PADDR(e1000_tx_desc_array);
f01062bb:	a1 a0 3b 34 f0       	mov    0xf0343ba0,%eax
f01062c0:	ba a0 39 34 f0       	mov    $0xf03439a0,%edx
f01062c5:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01062cb:	76 68                	jbe    f0106335 <e1000_transmit_init+0xdf>
f01062cd:	c7 80 00 38 00 00 a0 	movl   $0x3439a0,0x3800(%eax)
f01062d4:	39 34 00 
	e1000[E1000_LOCATE(E1000_TDBAH) ] = 0;
f01062d7:	c7 80 04 38 00 00 00 	movl   $0x0,0x3804(%eax)
f01062de:	00 00 00 
	e1000[E1000_LOCATE(E1000_TDLEN) ] = sizeof(struct e1000_tx_desc)*TX_DESC_ARRAY_SIZE;
f01062e1:	c7 80 08 38 00 00 00 	movl   $0x200,0x3808(%eax)
f01062e8:	02 00 00 
	e1000[E1000_LOCATE(E1000_TDH) ] = 0;
f01062eb:	c7 80 10 38 00 00 00 	movl   $0x0,0x3810(%eax)
f01062f2:	00 00 00 
	e1000[E1000_LOCATE(E1000_TDT) ] = 0;
f01062f5:	c7 80 18 38 00 00 00 	movl   $0x0,0x3818(%eax)
f01062fc:	00 00 00 
	
	//3.
	e1000[E1000_LOCATE(E1000_TCTL) ] |= E1000_TCTL_EN | E1000_TCTL_PSP | (E1000_TCTL_CT & (0x10 << 4)) | (E1000_TCTL_COLD & (0x40 << 12));
f01062ff:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0106305:	81 ca 0a 01 04 00    	or     $0x4010a,%edx
f010630b:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)
	
	//4. {IPGT,IPGR1,IPGR2}分别为 {10,8,6}
	e1000[E1000_LOCATE(E1000_TIPG)] = E1000_TIPG_IPGT | (E1000_TIPG_IPGR1 << E1000_TIPG_IPGR1_SHIFT) | (E1000_TIPG_IPGR2 << E1000_TIPG_IPGR2_SHIFT);
f0106311:	c7 80 10 04 00 00 0a 	movl   $0x60200a,0x410(%eax)
f0106318:	20 60 00 
}
f010631b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010631e:	5b                   	pop    %ebx
f010631f:	5e                   	pop    %esi
f0106320:	5f                   	pop    %edi
f0106321:	5d                   	pop    %ebp
f0106322:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106323:	52                   	push   %edx
f0106324:	68 88 6d 10 f0       	push   $0xf0106d88
f0106329:	6a 32                	push   $0x32
f010632b:	68 6d 8b 10 f0       	push   $0xf0108b6d
f0106330:	e8 0b 9d ff ff       	call   f0100040 <_panic>
f0106335:	52                   	push   %edx
f0106336:	68 88 6d 10 f0       	push   $0xf0106d88
f010633b:	6a 37                	push   $0x37
f010633d:	68 6d 8b 10 f0       	push   $0xf0108b6d
f0106342:	e8 f9 9c ff ff       	call   f0100040 <_panic>

f0106347 <e1000_transmit>:

int 
e1000_transmit(void *addr, size_t len)
{
f0106347:	55                   	push   %ebp
f0106348:	89 e5                	mov    %esp,%ebp
f010634a:	56                   	push   %esi
f010634b:	53                   	push   %ebx
f010634c:	8b 75 0c             	mov    0xc(%ebp),%esi
	size_t tdt = e1000[E1000_LOCATE(E1000_TDT)] ;//TDT寄存器中存的是索引！！！
f010634f:	a1 a0 3b 34 f0       	mov    0xf0343ba0,%eax
f0106354:	8b 98 18 38 00 00    	mov    0x3818(%eax),%ebx
	struct e1000_tx_desc * tail_desc = &e1000_tx_desc_array[tdt];
	
	if( !(tail_desc->status & E1000_TXD_STATUS_DD) ) return -1;//传输队列已满
f010635a:	89 d8                	mov    %ebx,%eax
f010635c:	c1 e0 04             	shl    $0x4,%eax
f010635f:	f6 80 ac 39 34 f0 01 	testb  $0x1,-0xfcbc654(%eax)
f0106366:	74 4b                	je     f01063b3 <e1000_transmit+0x6c>
	
	memcpy(e1000_tx_buffer[tdt] , addr, len);
f0106368:	83 ec 04             	sub    $0x4,%esp
f010636b:	56                   	push   %esi
f010636c:	ff 75 08             	push   0x8(%ebp)
f010636f:	69 c3 ee 05 00 00    	imul   $0x5ee,%ebx,%eax
f0106375:	05 e0 7b 33 f0       	add    $0xf0337be0,%eax
f010637a:	50                   	push   %eax
f010637b:	e8 95 f5 ff ff       	call   f0105915 <memcpy>
	
	tail_desc->length = (uint16_t )len;
f0106380:	89 d8                	mov    %ebx,%eax
f0106382:	c1 e0 04             	shl    $0x4,%eax
f0106385:	66 89 b0 a8 39 34 f0 	mov    %si,-0xfcbc658(%eax)
	tail_desc->status=0;
f010638c:	c6 80 ac 39 34 f0 00 	movb   $0x0,-0xfcbc654(%eax)
	//tail_desc->status &= (~E1000_TXD_STATUS_DD);//清零DD位。
	
	e1000[E1000_LOCATE(E1000_TDT)]= (tdt+1) % TX_DESC_ARRAY_SIZE;
f0106393:	83 c3 01             	add    $0x1,%ebx
f0106396:	83 e3 1f             	and    $0x1f,%ebx
f0106399:	a1 a0 3b 34 f0       	mov    0xf0343ba0,%eax
f010639e:	89 98 18 38 00 00    	mov    %ebx,0x3818(%eax)
	
	return 0;
f01063a4:	83 c4 10             	add    $0x10,%esp
f01063a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01063ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01063af:	5b                   	pop    %ebx
f01063b0:	5e                   	pop    %esi
f01063b1:	5d                   	pop    %ebp
f01063b2:	c3                   	ret    
	if( !(tail_desc->status & E1000_TXD_STATUS_DD) ) return -1;//传输队列已满
f01063b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01063b8:	eb f2                	jmp    f01063ac <e1000_transmit+0x65>

f01063ba <e1000_receive_init>:

/*接收*/
void
e1000_receive_init()
{
f01063ba:	55                   	push   %ebp
f01063bb:	89 e5                	mov    %esp,%ebp
f01063bd:	57                   	push   %edi
f01063be:	56                   	push   %esi
f01063bf:	53                   	push   %ebx
f01063c0:	83 ec 10             	sub    $0x10,%esp
	//接收地址寄存器
	e1000[E1000_LOCATE(E1000_RA)] = QEMU_DEFAULT_MAC_LOW;
f01063c3:	a1 a0 3b 34 f0       	mov    0xf0343ba0,%eax
f01063c8:	c7 80 00 54 00 00 52 	movl   $0x12005452,0x5400(%eax)
f01063cf:	54 00 12 
	e1000[E1000_LOCATE(E1000_RA) + 1] = QEMU_DEFAULT_MAC_HIGH | E1000_RAH_AV;
f01063d2:	c7 80 04 54 00 00 34 	movl   $0x80005634,0x5404(%eax)
f01063d9:	56 00 80 
	
	//处理描述符
	memset(e1000_rx_desc_array, 0, sizeof(e1000_rx_desc_array) );
f01063dc:	68 00 08 00 00       	push   $0x800
f01063e1:	6a 00                	push   $0x0
f01063e3:	68 e0 73 33 f0       	push   $0xf03373e0
f01063e8:	e8 80 f4 ff ff       	call   f010586d <memset>
f01063ed:	b8 e0 73 2f f0       	mov    $0xf02f73e0,%eax
f01063f2:	b9 e0 73 2f 00       	mov    $0x2f73e0,%ecx
f01063f7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01063fc:	be e0 73 33 f0       	mov    $0xf03373e0,%esi
f0106401:	83 c4 10             	add    $0x10,%esp
f0106404:	ba e0 73 33 f0       	mov    $0xf03373e0,%edx
	if ((uint32_t)kva < KERNBASE)
f0106409:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010640e:	76 70                	jbe    f0106480 <e1000_receive_init+0xc6>
	for (int i = 0; i < RX_DESC_ARRAY_SIZE; i++) {
		e1000_rx_desc_array[i].addr = PADDR(e1000_rx_buffer[i]);
f0106410:	89 0a                	mov    %ecx,(%edx)
f0106412:	89 5a 04             	mov    %ebx,0x4(%edx)
	for (int i = 0; i < RX_DESC_ARRAY_SIZE; i++) {
f0106415:	05 00 08 00 00       	add    $0x800,%eax
f010641a:	81 c1 00 08 00 00    	add    $0x800,%ecx
f0106420:	83 d3 00             	adc    $0x0,%ebx
f0106423:	83 c2 10             	add    $0x10,%edx
f0106426:	39 f0                	cmp    %esi,%eax
f0106428:	75 df                	jne    f0106409 <e1000_receive_init+0x4f>
	}
	
	e1000[E1000_LOCATE(E1000_RDBAL)] = PADDR(e1000_rx_desc_array);
f010642a:	a1 a0 3b 34 f0       	mov    0xf0343ba0,%eax
f010642f:	ba e0 73 33 f0       	mov    $0xf03373e0,%edx
f0106434:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010643a:	76 56                	jbe    f0106492 <e1000_receive_init+0xd8>
f010643c:	c7 80 00 28 00 00 e0 	movl   $0x3373e0,0x2800(%eax)
f0106443:	73 33 00 
	e1000[E1000_LOCATE(E1000_RDBAH)] = 0;
f0106446:	c7 80 04 28 00 00 00 	movl   $0x0,0x2804(%eax)
f010644d:	00 00 00 
	e1000[E1000_LOCATE(E1000_RDLEN)] = sizeof(e1000_rx_desc_array);
f0106450:	c7 80 08 28 00 00 00 	movl   $0x800,0x2808(%eax)
f0106457:	08 00 00 
	e1000[E1000_LOCATE(E1000_RDH)] = 0;
f010645a:	c7 80 10 28 00 00 00 	movl   $0x0,0x2810(%eax)
f0106461:	00 00 00 
	e1000[E1000_LOCATE(E1000_RDT)] = RX_DESC_ARRAY_SIZE-1;//尾指针的下一个才是真尾巴，即真正软件要把它复制过来的数据包
f0106464:	c7 80 18 28 00 00 7f 	movl   $0x7f,0x2818(%eax)
f010646b:	00 00 00 
	
	e1000[E1000_LOCATE(E1000_RCTL)] = E1000_RCTL_EN | E1000_RCTL_BAM  |  E1000_RCTL_SZ_2048 | E1000_RCTL_SECRC;	
f010646e:	c7 80 00 01 00 00 02 	movl   $0x4008002,0x100(%eax)
f0106475:	80 00 04 
}
f0106478:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010647b:	5b                   	pop    %ebx
f010647c:	5e                   	pop    %esi
f010647d:	5f                   	pop    %edi
f010647e:	5d                   	pop    %ebp
f010647f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106480:	50                   	push   %eax
f0106481:	68 88 6d 10 f0       	push   $0xf0106d88
f0106486:	6a 62                	push   $0x62
f0106488:	68 6d 8b 10 f0       	push   $0xf0108b6d
f010648d:	e8 ae 9b ff ff       	call   f0100040 <_panic>
f0106492:	52                   	push   %edx
f0106493:	68 88 6d 10 f0       	push   $0xf0106d88
f0106498:	6a 65                	push   $0x65
f010649a:	68 6d 8b 10 f0       	push   $0xf0108b6d
f010649f:	e8 9c 9b ff ff       	call   f0100040 <_panic>

f01064a4 <pci_e1000_attach>:
{
f01064a4:	55                   	push   %ebp
f01064a5:	89 e5                	mov    %esp,%ebp
f01064a7:	53                   	push   %ebx
f01064a8:	83 ec 10             	sub    $0x10,%esp
f01064ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pci_func_enable(pcif);
f01064ae:	53                   	push   %ebx
f01064af:	e8 93 04 00 00       	call   f0106947 <pci_func_enable>
	e1000=mmio_map_region(pcif->reg_base[0],pcif->reg_size[0]);
f01064b4:	83 c4 08             	add    $0x8,%esp
f01064b7:	ff 73 2c             	push   0x2c(%ebx)
f01064ba:	ff 73 14             	push   0x14(%ebx)
f01064bd:	e8 14 ae ff ff       	call   f01012d6 <mmio_map_region>
f01064c2:	a3 a0 3b 34 f0       	mov    %eax,0xf0343ba0
	cprintf("device status:[%x]\n", e1000[E1000_LOCATE(E1000_STATUS)] );/*打印设备状态寄存器， 用来测试程序*/
f01064c7:	8b 40 08             	mov    0x8(%eax),%eax
f01064ca:	83 c4 08             	add    $0x8,%esp
f01064cd:	50                   	push   %eax
f01064ce:	68 7a 8b 10 f0       	push   $0xf0108b7a
f01064d3:	e8 dd d4 ff ff       	call   f01039b5 <cprintf>
	e1000_transmit_init();
f01064d8:	e8 79 fd ff ff       	call   f0106256 <e1000_transmit_init>
	e1000_receive_init();
f01064dd:	e8 d8 fe ff ff       	call   f01063ba <e1000_receive_init>
}
f01064e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01064e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01064ea:	c9                   	leave  
f01064eb:	c3                   	ret    

f01064ec <e1000_receive>:


int 
e1000_receive(void *addr, size_t *len)//要把长度取出来，后面struct jif_pkt需要记录长度的
{
f01064ec:	55                   	push   %ebp
f01064ed:	89 e5                	mov    %esp,%ebp
f01064ef:	56                   	push   %esi
f01064f0:	53                   	push   %ebx
	size_t tail = e1000[E1000_LOCATE(E1000_RDT)];
f01064f1:	a1 a0 3b 34 f0       	mov    0xf0343ba0,%eax
f01064f6:	8b 98 18 28 00 00    	mov    0x2818(%eax),%ebx
	size_t next = (tail+1)% RX_DESC_ARRAY_SIZE;//真尾巴
f01064fc:	83 c3 01             	add    $0x1,%ebx
f01064ff:	83 e3 7f             	and    $0x7f,%ebx
	
	if( !(e1000_rx_desc_array[next].status & E1000_RXD_STAT_DD) ){
f0106502:	89 d8                	mov    %ebx,%eax
f0106504:	c1 e0 04             	shl    $0x4,%eax
f0106507:	f6 80 ec 73 33 f0 01 	testb  $0x1,-0xfcc8c14(%eax)
f010650e:	74 4c                	je     f010655c <e1000_receive+0x70>
		return -1;//队列空
	}
	
	*len=e1000_rx_desc_array[next].length;
f0106510:	89 d8                	mov    %ebx,%eax
f0106512:	c1 e0 04             	shl    $0x4,%eax
f0106515:	8d b0 e0 73 33 f0    	lea    -0xfcc8c20(%eax),%esi
f010651b:	0f b7 80 e8 73 33 f0 	movzwl -0xfcc8c18(%eax),%eax
f0106522:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106525:	89 02                	mov    %eax,(%edx)
	memcpy(addr, e1000_rx_buffer[next] , *len);
f0106527:	83 ec 04             	sub    $0x4,%esp
f010652a:	50                   	push   %eax
f010652b:	89 d8                	mov    %ebx,%eax
f010652d:	c1 e0 0b             	shl    $0xb,%eax
f0106530:	05 e0 73 2f f0       	add    $0xf02f73e0,%eax
f0106535:	50                   	push   %eax
f0106536:	ff 75 08             	push   0x8(%ebp)
f0106539:	e8 d7 f3 ff ff       	call   f0105915 <memcpy>
	
	e1000_rx_desc_array[next].status &= ~E1000_RXD_STAT_DD;//清零DD位
f010653e:	80 66 0c fe          	andb   $0xfe,0xc(%esi)
	e1000[E1000_LOCATE(E1000_RDT)] = next;
f0106542:	a1 a0 3b 34 f0       	mov    0xf0343ba0,%eax
f0106547:	89 98 18 28 00 00    	mov    %ebx,0x2818(%eax)
	
	return 0;
f010654d:	83 c4 10             	add    $0x10,%esp
f0106550:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106555:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106558:	5b                   	pop    %ebx
f0106559:	5e                   	pop    %esi
f010655a:	5d                   	pop    %ebp
f010655b:	c3                   	ret    
		return -1;//队列空
f010655c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0106561:	eb f2                	jmp    f0106555 <e1000_receive+0x69>

f0106563 <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f0106563:	55                   	push   %ebp
f0106564:	89 e5                	mov    %esp,%ebp
f0106566:	57                   	push   %edi
f0106567:	56                   	push   %esi
f0106568:	53                   	push   %ebx
f0106569:	83 ec 0c             	sub    $0xc,%esp
f010656c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010656f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0106572:	eb 03                	jmp    f0106577 <pci_attach_match+0x14>
f0106574:	83 c3 0c             	add    $0xc,%ebx
f0106577:	89 de                	mov    %ebx,%esi
f0106579:	8b 43 08             	mov    0x8(%ebx),%eax
f010657c:	85 c0                	test   %eax,%eax
f010657e:	74 37                	je     f01065b7 <pci_attach_match+0x54>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f0106580:	39 3b                	cmp    %edi,(%ebx)
f0106582:	75 f0                	jne    f0106574 <pci_attach_match+0x11>
f0106584:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106587:	39 56 04             	cmp    %edx,0x4(%esi)
f010658a:	75 e8                	jne    f0106574 <pci_attach_match+0x11>
			int r = list[i].attachfn(pcif);
f010658c:	83 ec 0c             	sub    $0xc,%esp
f010658f:	ff 75 14             	push   0x14(%ebp)
f0106592:	ff d0                	call   *%eax
			if (r > 0)
f0106594:	83 c4 10             	add    $0x10,%esp
f0106597:	85 c0                	test   %eax,%eax
f0106599:	7f 1c                	jg     f01065b7 <pci_attach_match+0x54>
				return r;
			if (r < 0)
f010659b:	79 d7                	jns    f0106574 <pci_attach_match+0x11>
				cprintf("pci_attach_match: attaching "
f010659d:	83 ec 0c             	sub    $0xc,%esp
f01065a0:	50                   	push   %eax
f01065a1:	ff 76 08             	push   0x8(%esi)
f01065a4:	ff 75 0c             	push   0xc(%ebp)
f01065a7:	57                   	push   %edi
f01065a8:	68 90 8b 10 f0       	push   $0xf0108b90
f01065ad:	e8 03 d4 ff ff       	call   f01039b5 <cprintf>
f01065b2:	83 c4 20             	add    $0x20,%esp
f01065b5:	eb bd                	jmp    f0106574 <pci_attach_match+0x11>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f01065b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01065ba:	5b                   	pop    %ebx
f01065bb:	5e                   	pop    %esi
f01065bc:	5f                   	pop    %edi
f01065bd:	5d                   	pop    %ebp
f01065be:	c3                   	ret    

f01065bf <pci_conf1_set_addr>:
{
f01065bf:	55                   	push   %ebp
f01065c0:	89 e5                	mov    %esp,%ebp
f01065c2:	56                   	push   %esi
f01065c3:	53                   	push   %ebx
f01065c4:	8b 75 08             	mov    0x8(%ebp),%esi
	assert(bus < 256);
f01065c7:	3d ff 00 00 00       	cmp    $0xff,%eax
f01065cc:	77 3b                	ja     f0106609 <pci_conf1_set_addr+0x4a>
	assert(dev < 32);
f01065ce:	83 fa 1f             	cmp    $0x1f,%edx
f01065d1:	77 4c                	ja     f010661f <pci_conf1_set_addr+0x60>
	assert(func < 8);
f01065d3:	83 f9 07             	cmp    $0x7,%ecx
f01065d6:	77 5d                	ja     f0106635 <pci_conf1_set_addr+0x76>
	assert(offset < 256);
f01065d8:	81 fe ff 00 00 00    	cmp    $0xff,%esi
f01065de:	77 6b                	ja     f010664b <pci_conf1_set_addr+0x8c>
	assert((offset & 0x3) == 0);
f01065e0:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01065e6:	75 79                	jne    f0106661 <pci_conf1_set_addr+0xa2>
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
f01065e8:	c1 e0 10             	shl    $0x10,%eax
f01065eb:	09 f0                	or     %esi,%eax
f01065ed:	c1 e1 08             	shl    $0x8,%ecx
f01065f0:	09 c8                	or     %ecx,%eax
f01065f2:	c1 e2 0b             	shl    $0xb,%edx
f01065f5:	09 d0                	or     %edx,%eax
	uint32_t v = (1 << 31) |		// config-space
f01065f7:	0d 00 00 00 80       	or     $0x80000000,%eax
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f01065fc:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f0106601:	ef                   	out    %eax,(%dx)
}
f0106602:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106605:	5b                   	pop    %ebx
f0106606:	5e                   	pop    %esi
f0106607:	5d                   	pop    %ebp
f0106608:	c3                   	ret    
	assert(bus < 256);
f0106609:	68 e7 8c 10 f0       	push   $0xf0108ce7
f010660e:	68 d5 72 10 f0       	push   $0xf01072d5
f0106613:	6a 2c                	push   $0x2c
f0106615:	68 f1 8c 10 f0       	push   $0xf0108cf1
f010661a:	e8 21 9a ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f010661f:	68 fc 8c 10 f0       	push   $0xf0108cfc
f0106624:	68 d5 72 10 f0       	push   $0xf01072d5
f0106629:	6a 2d                	push   $0x2d
f010662b:	68 f1 8c 10 f0       	push   $0xf0108cf1
f0106630:	e8 0b 9a ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f0106635:	68 05 8d 10 f0       	push   $0xf0108d05
f010663a:	68 d5 72 10 f0       	push   $0xf01072d5
f010663f:	6a 2e                	push   $0x2e
f0106641:	68 f1 8c 10 f0       	push   $0xf0108cf1
f0106646:	e8 f5 99 ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f010664b:	68 0e 8d 10 f0       	push   $0xf0108d0e
f0106650:	68 d5 72 10 f0       	push   $0xf01072d5
f0106655:	6a 2f                	push   $0x2f
f0106657:	68 f1 8c 10 f0       	push   $0xf0108cf1
f010665c:	e8 df 99 ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f0106661:	68 1b 8d 10 f0       	push   $0xf0108d1b
f0106666:	68 d5 72 10 f0       	push   $0xf01072d5
f010666b:	6a 30                	push   $0x30
f010666d:	68 f1 8c 10 f0       	push   $0xf0108cf1
f0106672:	e8 c9 99 ff ff       	call   f0100040 <_panic>

f0106677 <pci_conf_read>:
{
f0106677:	55                   	push   %ebp
f0106678:	89 e5                	mov    %esp,%ebp
f010667a:	53                   	push   %ebx
f010667b:	83 ec 10             	sub    $0x10,%esp
f010667e:	89 d3                	mov    %edx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106680:	8b 48 08             	mov    0x8(%eax),%ecx
f0106683:	8b 50 04             	mov    0x4(%eax),%edx
f0106686:	8b 00                	mov    (%eax),%eax
f0106688:	8b 40 04             	mov    0x4(%eax),%eax
f010668b:	53                   	push   %ebx
f010668c:	e8 2e ff ff ff       	call   f01065bf <pci_conf1_set_addr>
	asm volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f0106691:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0106696:	ed                   	in     (%dx),%eax
}
f0106697:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010669a:	c9                   	leave  
f010669b:	c3                   	ret    

f010669c <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f010669c:	55                   	push   %ebp
f010669d:	89 e5                	mov    %esp,%ebp
f010669f:	57                   	push   %edi
f01066a0:	56                   	push   %esi
f01066a1:	53                   	push   %ebx
f01066a2:	81 ec 00 01 00 00    	sub    $0x100,%esp
f01066a8:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f01066aa:	6a 48                	push   $0x48
f01066ac:	6a 00                	push   $0x0
f01066ae:	8d 45 a0             	lea    -0x60(%ebp),%eax
f01066b1:	50                   	push   %eax
f01066b2:	e8 b6 f1 ff ff       	call   f010586d <memset>
	df.bus = bus;
f01066b7:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f01066ba:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01066c1:	83 c4 10             	add    $0x10,%esp
	int totaldev = 0;
f01066c4:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
f01066cb:	00 00 00 
f01066ce:	e9 4b 01 00 00       	jmp    f010681e <pci_scan_bus+0x182>
	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f01066d3:	83 ec 08             	sub    $0x8,%esp
f01066d6:	89 fa                	mov    %edi,%edx
f01066d8:	0f b6 fa             	movzbl %dl,%edi
f01066db:	57                   	push   %edi
f01066dc:	51                   	push   %ecx
		PCI_CLASS(f->dev_class), PCI_SUBCLASS(f->dev_class), class,
f01066dd:	c1 e8 10             	shr    $0x10,%eax
	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f01066e0:	0f b6 c0             	movzbl %al,%eax
f01066e3:	50                   	push   %eax
f01066e4:	ff b5 00 ff ff ff    	push   -0x100(%ebp)
f01066ea:	c1 ee 10             	shr    $0x10,%esi
f01066ed:	56                   	push   %esi
f01066ee:	ff b5 04 ff ff ff    	push   -0xfc(%ebp)
f01066f4:	53                   	push   %ebx
f01066f5:	ff b5 5c ff ff ff    	push   -0xa4(%ebp)
f01066fb:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f0106701:	ff 70 04             	push   0x4(%eax)
f0106704:	68 bc 8b 10 f0       	push   $0xf0108bbc
f0106709:	e8 a7 d2 ff ff       	call   f01039b5 <cprintf>
				 PCI_SUBCLASS(f->dev_class),
f010670e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
		pci_attach_match(PCI_CLASS(f->dev_class),
f0106714:	83 c4 30             	add    $0x30,%esp
f0106717:	8d 8d 58 ff ff ff    	lea    -0xa8(%ebp),%ecx
f010671d:	51                   	push   %ecx
f010671e:	68 0c 84 12 f0       	push   $0xf012840c
				 PCI_SUBCLASS(f->dev_class),
f0106723:	89 c2                	mov    %eax,%edx
f0106725:	c1 ea 10             	shr    $0x10,%edx
		pci_attach_match(PCI_CLASS(f->dev_class),
f0106728:	0f b6 d2             	movzbl %dl,%edx
f010672b:	52                   	push   %edx
f010672c:	c1 e8 18             	shr    $0x18,%eax
f010672f:	50                   	push   %eax
f0106730:	e8 2e fe ff ff       	call   f0106563 <pci_attach_match>
				 &pci_attach_class[0], f) ||
f0106735:	83 c4 10             	add    $0x10,%esp
f0106738:	85 c0                	test   %eax,%eax
f010673a:	0f 84 a7 00 00 00    	je     f01067e7 <pci_scan_bus+0x14b>

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f0106740:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
f0106746:	8d 58 01             	lea    0x1(%eax),%ebx
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106749:	89 9d 18 ff ff ff    	mov    %ebx,-0xe8(%ebp)
f010674f:	39 9d fc fe ff ff    	cmp    %ebx,-0x104(%ebp)
f0106755:	0f 86 b5 00 00 00    	jbe    f0106810 <pci_scan_bus+0x174>
			struct pci_func af = f;
f010675b:	8d bd 58 ff ff ff    	lea    -0xa8(%ebp),%edi
f0106761:	8d b5 10 ff ff ff    	lea    -0xf0(%ebp),%esi
f0106767:	b9 12 00 00 00       	mov    $0x12,%ecx
f010676c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f010676e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106773:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f0106779:	e8 f9 fe ff ff       	call   f0106677 <pci_conf_read>
f010677e:	89 c6                	mov    %eax,%esi
f0106780:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f0106786:	0f b7 c0             	movzwl %ax,%eax
f0106789:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)
f010678f:	66 83 fe ff          	cmp    $0xffff,%si
f0106793:	74 ab                	je     f0106740 <pci_scan_bus+0xa4>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0106795:	ba 3c 00 00 00       	mov    $0x3c,%edx
f010679a:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
f01067a0:	e8 d2 fe ff ff       	call   f0106677 <pci_conf_read>
f01067a5:	89 c7                	mov    %eax,%edi
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f01067a7:	88 45 9c             	mov    %al,-0x64(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f01067aa:	ba 08 00 00 00       	mov    $0x8,%edx
f01067af:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
f01067b5:	e8 bd fe ff ff       	call   f0106677 <pci_conf_read>
f01067ba:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f01067c0:	89 c2                	mov    %eax,%edx
f01067c2:	c1 ea 18             	shr    $0x18,%edx
f01067c5:	89 95 00 ff ff ff    	mov    %edx,-0x100(%ebp)
	const char *class = pci_class[0];
f01067cb:	b9 2f 8d 10 f0       	mov    $0xf0108d2f,%ecx
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f01067d0:	3d ff ff ff 06       	cmp    $0x6ffffff,%eax
f01067d5:	0f 87 f8 fe ff ff    	ja     f01066d3 <pci_scan_bus+0x37>
		class = pci_class[PCI_CLASS(f->dev_class)];
f01067db:	8b 0c 95 a4 8d 10 f0 	mov    -0xfef725c(,%edx,4),%ecx
f01067e2:	e9 ec fe ff ff       	jmp    f01066d3 <pci_scan_bus+0x37>
				 PCI_PRODUCT(f->dev_id),
f01067e7:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
		pci_attach_match(PCI_VENDOR(f->dev_id),
f01067ed:	8d 8d 58 ff ff ff    	lea    -0xa8(%ebp),%ecx
f01067f3:	51                   	push   %ecx
f01067f4:	68 f4 83 12 f0       	push   $0xf01283f4
f01067f9:	89 c2                	mov    %eax,%edx
f01067fb:	c1 ea 10             	shr    $0x10,%edx
f01067fe:	52                   	push   %edx
f01067ff:	0f b7 c0             	movzwl %ax,%eax
f0106802:	50                   	push   %eax
f0106803:	e8 5b fd ff ff       	call   f0106563 <pci_attach_match>
f0106808:	83 c4 10             	add    $0x10,%esp
f010680b:	e9 30 ff ff ff       	jmp    f0106740 <pci_scan_bus+0xa4>
	for (df.dev = 0; df.dev < 32; df.dev++) {
f0106810:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0106813:	83 c0 01             	add    $0x1,%eax
f0106816:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0106819:	83 f8 1f             	cmp    $0x1f,%eax
f010681c:	77 4b                	ja     f0106869 <pci_scan_bus+0x1cd>
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f010681e:	ba 0c 00 00 00       	mov    $0xc,%edx
f0106823:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0106826:	e8 4c fe ff ff       	call   f0106677 <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f010682b:	89 c2                	mov    %eax,%edx
f010682d:	c1 ea 10             	shr    $0x10,%edx
f0106830:	89 d3                	mov    %edx,%ebx
f0106832:	83 e3 7e             	and    $0x7e,%ebx
f0106835:	75 d9                	jne    f0106810 <pci_scan_bus+0x174>
		totaldev++;
f0106837:	83 85 f8 fe ff ff 01 	addl   $0x1,-0x108(%ebp)
		struct pci_func f = df;
f010683e:	8d bd 10 ff ff ff    	lea    -0xf0(%ebp),%edi
f0106844:	8d 75 a0             	lea    -0x60(%ebp),%esi
f0106847:	b9 12 00 00 00       	mov    $0x12,%ecx
f010684c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f010684e:	25 00 00 80 00       	and    $0x800000,%eax
f0106853:	83 f8 01             	cmp    $0x1,%eax
f0106856:	19 c0                	sbb    %eax,%eax
f0106858:	83 e0 f9             	and    $0xfffffff9,%eax
f010685b:	83 c0 08             	add    $0x8,%eax
f010685e:	89 85 fc fe ff ff    	mov    %eax,-0x104(%ebp)
f0106864:	e9 e0 fe ff ff       	jmp    f0106749 <pci_scan_bus+0xad>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f0106869:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
f010686f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106872:	5b                   	pop    %ebx
f0106873:	5e                   	pop    %esi
f0106874:	5f                   	pop    %edi
f0106875:	5d                   	pop    %ebp
f0106876:	c3                   	ret    

f0106877 <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f0106877:	55                   	push   %ebp
f0106878:	89 e5                	mov    %esp,%ebp
f010687a:	57                   	push   %edi
f010687b:	56                   	push   %esi
f010687c:	53                   	push   %ebx
f010687d:	83 ec 1c             	sub    $0x1c,%esp
f0106880:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f0106883:	ba 1c 00 00 00       	mov    $0x1c,%edx
f0106888:	89 f0                	mov    %esi,%eax
f010688a:	e8 e8 fd ff ff       	call   f0106677 <pci_conf_read>
f010688f:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f0106891:	ba 18 00 00 00       	mov    $0x18,%edx
f0106896:	89 f0                	mov    %esi,%eax
f0106898:	e8 da fd ff ff       	call   f0106677 <pci_conf_read>

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f010689d:	83 e7 0f             	and    $0xf,%edi
f01068a0:	83 ff 01             	cmp    $0x1,%edi
f01068a3:	74 52                	je     f01068f7 <pci_bridge_attach+0x80>
f01068a5:	89 c3                	mov    %eax,%ebx
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f01068a7:	83 ec 04             	sub    $0x4,%esp
f01068aa:	6a 08                	push   $0x8
f01068ac:	6a 00                	push   $0x0
f01068ae:	8d 7d e0             	lea    -0x20(%ebp),%edi
f01068b1:	57                   	push   %edi
f01068b2:	e8 b6 ef ff ff       	call   f010586d <memset>
	nbus.parent_bridge = pcif;
f01068b7:	89 75 e0             	mov    %esi,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f01068ba:	0f b6 c7             	movzbl %bh,%eax
f01068bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f01068c0:	83 c4 08             	add    $0x8,%esp
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);
f01068c3:	c1 eb 10             	shr    $0x10,%ebx
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f01068c6:	0f b6 db             	movzbl %bl,%ebx
f01068c9:	53                   	push   %ebx
f01068ca:	50                   	push   %eax
f01068cb:	ff 76 08             	push   0x8(%esi)
f01068ce:	ff 76 04             	push   0x4(%esi)
f01068d1:	8b 06                	mov    (%esi),%eax
f01068d3:	ff 70 04             	push   0x4(%eax)
f01068d6:	68 2c 8c 10 f0       	push   $0xf0108c2c
f01068db:	e8 d5 d0 ff ff       	call   f01039b5 <cprintf>

	pci_scan_bus(&nbus);
f01068e0:	83 c4 20             	add    $0x20,%esp
f01068e3:	89 f8                	mov    %edi,%eax
f01068e5:	e8 b2 fd ff ff       	call   f010669c <pci_scan_bus>
	return 1;
f01068ea:	b8 01 00 00 00       	mov    $0x1,%eax
}
f01068ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01068f2:	5b                   	pop    %ebx
f01068f3:	5e                   	pop    %esi
f01068f4:	5f                   	pop    %edi
f01068f5:	5d                   	pop    %ebp
f01068f6:	c3                   	ret    
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f01068f7:	ff 76 08             	push   0x8(%esi)
f01068fa:	ff 76 04             	push   0x4(%esi)
f01068fd:	8b 06                	mov    (%esi),%eax
f01068ff:	ff 70 04             	push   0x4(%eax)
f0106902:	68 f8 8b 10 f0       	push   $0xf0108bf8
f0106907:	e8 a9 d0 ff ff       	call   f01039b5 <cprintf>
		return 0;
f010690c:	83 c4 10             	add    $0x10,%esp
f010690f:	b8 00 00 00 00       	mov    $0x0,%eax
f0106914:	eb d9                	jmp    f01068ef <pci_bridge_attach+0x78>

f0106916 <pci_conf_write>:
{
f0106916:	55                   	push   %ebp
f0106917:	89 e5                	mov    %esp,%ebp
f0106919:	57                   	push   %edi
f010691a:	56                   	push   %esi
f010691b:	53                   	push   %ebx
f010691c:	83 ec 18             	sub    $0x18,%esp
f010691f:	89 d7                	mov    %edx,%edi
f0106921:	89 ce                	mov    %ecx,%esi
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106923:	8b 48 08             	mov    0x8(%eax),%ecx
f0106926:	8b 50 04             	mov    0x4(%eax),%edx
f0106929:	8b 00                	mov    (%eax),%eax
f010692b:	8b 40 04             	mov    0x4(%eax),%eax
f010692e:	57                   	push   %edi
f010692f:	e8 8b fc ff ff       	call   f01065bf <pci_conf1_set_addr>
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0106934:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0106939:	89 f0                	mov    %esi,%eax
f010693b:	ef                   	out    %eax,(%dx)
}
f010693c:	83 c4 10             	add    $0x10,%esp
f010693f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106942:	5b                   	pop    %ebx
f0106943:	5e                   	pop    %esi
f0106944:	5f                   	pop    %edi
f0106945:	5d                   	pop    %ebp
f0106946:	c3                   	ret    

f0106947 <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f0106947:	55                   	push   %ebp
f0106948:	89 e5                	mov    %esp,%ebp
f010694a:	57                   	push   %edi
f010694b:	56                   	push   %esi
f010694c:	53                   	push   %ebx
f010694d:	83 ec 1c             	sub    $0x1c,%esp
f0106950:	8b 7d 08             	mov    0x8(%ebp),%edi
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f0106953:	b9 07 00 00 00       	mov    $0x7,%ecx
f0106958:	ba 04 00 00 00       	mov    $0x4,%edx
f010695d:	89 f8                	mov    %edi,%eax
f010695f:	e8 b2 ff ff ff       	call   f0106916 <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106964:	be 10 00 00 00       	mov    $0x10,%esi
f0106969:	eb 27                	jmp    f0106992 <pci_func_enable+0x4b>
			base = PCI_MAPREG_MEM_ADDR(oldv);
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f010696b:	89 d8                	mov    %ebx,%eax
f010696d:	83 e0 fc             	and    $0xfffffffc,%eax
f0106970:	f7 d8                	neg    %eax
f0106972:	21 c3                	and    %eax,%ebx
			base = PCI_MAPREG_IO_ADDR(oldv);
f0106974:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106977:	83 e0 fc             	and    $0xfffffffc,%eax
f010697a:	89 45 dc             	mov    %eax,-0x24(%ebp)
		bar_width = 4;
f010697d:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
f0106984:	eb 78                	jmp    f01069fe <pci_func_enable+0xb7>
	     bar += bar_width)
f0106986:	03 75 e4             	add    -0x1c(%ebp),%esi
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106989:	83 fe 27             	cmp    $0x27,%esi
f010698c:	0f 87 c7 00 00 00    	ja     f0106a59 <pci_func_enable+0x112>
		uint32_t oldv = pci_conf_read(f, bar);
f0106992:	89 f2                	mov    %esi,%edx
f0106994:	89 f8                	mov    %edi,%eax
f0106996:	e8 dc fc ff ff       	call   f0106677 <pci_conf_read>
f010699b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		pci_conf_write(f, bar, 0xffffffff);
f010699e:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f01069a3:	89 f2                	mov    %esi,%edx
f01069a5:	89 f8                	mov    %edi,%eax
f01069a7:	e8 6a ff ff ff       	call   f0106916 <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f01069ac:	89 f2                	mov    %esi,%edx
f01069ae:	89 f8                	mov    %edi,%eax
f01069b0:	e8 c2 fc ff ff       	call   f0106677 <pci_conf_read>
f01069b5:	89 c3                	mov    %eax,%ebx
		bar_width = 4;
f01069b7:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
		if (rv == 0)
f01069be:	85 c0                	test   %eax,%eax
f01069c0:	74 c4                	je     f0106986 <pci_func_enable+0x3f>
		int regnum = PCI_MAPREG_NUM(bar);
f01069c2:	8d 46 f0             	lea    -0x10(%esi),%eax
f01069c5:	89 c2                	mov    %eax,%edx
f01069c7:	c1 ea 02             	shr    $0x2,%edx
f01069ca:	89 55 d8             	mov    %edx,-0x28(%ebp)
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f01069cd:	f6 c3 01             	test   $0x1,%bl
f01069d0:	75 99                	jne    f010696b <pci_func_enable+0x24>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f01069d2:	89 da                	mov    %ebx,%edx
f01069d4:	83 e2 06             	and    $0x6,%edx
				bar_width = 8;
f01069d7:	83 fa 04             	cmp    $0x4,%edx
f01069da:	0f 94 c1             	sete   %cl
f01069dd:	0f b6 c9             	movzbl %cl,%ecx
f01069e0:	8d 14 8d 04 00 00 00 	lea    0x4(,%ecx,4),%edx
f01069e7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			size = PCI_MAPREG_MEM_SIZE(rv);
f01069ea:	89 da                	mov    %ebx,%edx
f01069ec:	83 e2 f0             	and    $0xfffffff0,%edx
f01069ef:	89 d0                	mov    %edx,%eax
f01069f1:	f7 d8                	neg    %eax
f01069f3:	21 c3                	and    %eax,%ebx
			base = PCI_MAPREG_MEM_ADDR(oldv);
f01069f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01069f8:	83 e0 f0             	and    $0xfffffff0,%eax
f01069fb:	89 45 dc             	mov    %eax,-0x24(%ebp)
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f01069fe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0106a01:	89 f2                	mov    %esi,%edx
f0106a03:	89 f8                	mov    %edi,%eax
f0106a05:	e8 0c ff ff ff       	call   f0106916 <pci_conf_write>
		f->reg_base[regnum] = base;
f0106a0a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0106a0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106a10:	89 44 8f 14          	mov    %eax,0x14(%edi,%ecx,4)
		f->reg_size[regnum] = size;
f0106a14:	89 5c 8f 2c          	mov    %ebx,0x2c(%edi,%ecx,4)

		if (size && !base)
f0106a18:	85 db                	test   %ebx,%ebx
f0106a1a:	0f 84 66 ff ff ff    	je     f0106986 <pci_func_enable+0x3f>
f0106a20:	85 c0                	test   %eax,%eax
f0106a22:	0f 85 5e ff ff ff    	jne    f0106986 <pci_func_enable+0x3f>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0106a28:	8b 47 0c             	mov    0xc(%edi),%eax
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f0106a2b:	83 ec 0c             	sub    $0xc,%esp
f0106a2e:	53                   	push   %ebx
f0106a2f:	6a 00                	push   $0x0
f0106a31:	51                   	push   %ecx
f0106a32:	89 c2                	mov    %eax,%edx
f0106a34:	c1 ea 10             	shr    $0x10,%edx
f0106a37:	52                   	push   %edx
f0106a38:	0f b7 c0             	movzwl %ax,%eax
f0106a3b:	50                   	push   %eax
f0106a3c:	ff 77 08             	push   0x8(%edi)
f0106a3f:	ff 77 04             	push   0x4(%edi)
f0106a42:	8b 07                	mov    (%edi),%eax
f0106a44:	ff 70 04             	push   0x4(%eax)
f0106a47:	68 5c 8c 10 f0       	push   $0xf0108c5c
f0106a4c:	e8 64 cf ff ff       	call   f01039b5 <cprintf>
f0106a51:	83 c4 30             	add    $0x30,%esp
f0106a54:	e9 2d ff ff ff       	jmp    f0106986 <pci_func_enable+0x3f>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f0106a59:	8b 47 0c             	mov    0xc(%edi),%eax
	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f0106a5c:	83 ec 08             	sub    $0x8,%esp
f0106a5f:	89 c2                	mov    %eax,%edx
f0106a61:	c1 ea 10             	shr    $0x10,%edx
f0106a64:	52                   	push   %edx
f0106a65:	0f b7 c0             	movzwl %ax,%eax
f0106a68:	50                   	push   %eax
f0106a69:	ff 77 08             	push   0x8(%edi)
f0106a6c:	ff 77 04             	push   0x4(%edi)
f0106a6f:	8b 07                	mov    (%edi),%eax
f0106a71:	ff 70 04             	push   0x4(%eax)
f0106a74:	68 b8 8c 10 f0       	push   $0xf0108cb8
f0106a79:	e8 37 cf ff ff       	call   f01039b5 <cprintf>
}
f0106a7e:	83 c4 20             	add    $0x20,%esp
f0106a81:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106a84:	5b                   	pop    %ebx
f0106a85:	5e                   	pop    %esi
f0106a86:	5f                   	pop    %edi
f0106a87:	5d                   	pop    %ebp
f0106a88:	c3                   	ret    

f0106a89 <pci_init>:

int
pci_init(void)
{
f0106a89:	55                   	push   %ebp
f0106a8a:	89 e5                	mov    %esp,%ebp
f0106a8c:	83 ec 0c             	sub    $0xc,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f0106a8f:	6a 08                	push   $0x8
f0106a91:	6a 00                	push   $0x0
f0106a93:	68 a4 3b 34 f0       	push   $0xf0343ba4
f0106a98:	e8 d0 ed ff ff       	call   f010586d <memset>

	return pci_scan_bus(&root_bus);
f0106a9d:	b8 a4 3b 34 f0       	mov    $0xf0343ba4,%eax
f0106aa2:	e8 f5 fb ff ff       	call   f010669c <pci_scan_bus>
}
f0106aa7:	c9                   	leave  
f0106aa8:	c3                   	ret    

f0106aa9 <time_init>:
static unsigned int ticks;

void
time_init(void)
{
	ticks = 0;
f0106aa9:	c7 05 ac 3b 34 f0 00 	movl   $0x0,0xf0343bac
f0106ab0:	00 00 00 
}
f0106ab3:	c3                   	ret    

f0106ab4 <time_tick>:
// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
	ticks++;
f0106ab4:	a1 ac 3b 34 f0       	mov    0xf0343bac,%eax
f0106ab9:	83 c0 01             	add    $0x1,%eax
f0106abc:	a3 ac 3b 34 f0       	mov    %eax,0xf0343bac
	if (ticks * 10 < ticks)
f0106ac1:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0106ac4:	01 d2                	add    %edx,%edx
f0106ac6:	39 d0                	cmp    %edx,%eax
f0106ac8:	77 01                	ja     f0106acb <time_tick+0x17>
f0106aca:	c3                   	ret    
{
f0106acb:	55                   	push   %ebp
f0106acc:	89 e5                	mov    %esp,%ebp
f0106ace:	83 ec 0c             	sub    $0xc,%esp
		panic("time_tick: time overflowed");
f0106ad1:	68 c0 8d 10 f0       	push   $0xf0108dc0
f0106ad6:	6a 13                	push   $0x13
f0106ad8:	68 db 8d 10 f0       	push   $0xf0108ddb
f0106add:	e8 5e 95 ff ff       	call   f0100040 <_panic>

f0106ae2 <time_msec>:
}

unsigned int
time_msec(void)
{
	return ticks * 10;
f0106ae2:	a1 ac 3b 34 f0       	mov    0xf0343bac,%eax
f0106ae7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0106aea:	01 c0                	add    %eax,%eax
}
f0106aec:	c3                   	ret    
f0106aed:	66 90                	xchg   %ax,%ax
f0106aef:	90                   	nop

f0106af0 <__udivdi3>:
f0106af0:	f3 0f 1e fb          	endbr32 
f0106af4:	55                   	push   %ebp
f0106af5:	57                   	push   %edi
f0106af6:	56                   	push   %esi
f0106af7:	53                   	push   %ebx
f0106af8:	83 ec 1c             	sub    $0x1c,%esp
f0106afb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0106aff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106b03:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106b07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0106b0b:	85 c0                	test   %eax,%eax
f0106b0d:	75 19                	jne    f0106b28 <__udivdi3+0x38>
f0106b0f:	39 f3                	cmp    %esi,%ebx
f0106b11:	76 4d                	jbe    f0106b60 <__udivdi3+0x70>
f0106b13:	31 ff                	xor    %edi,%edi
f0106b15:	89 e8                	mov    %ebp,%eax
f0106b17:	89 f2                	mov    %esi,%edx
f0106b19:	f7 f3                	div    %ebx
f0106b1b:	89 fa                	mov    %edi,%edx
f0106b1d:	83 c4 1c             	add    $0x1c,%esp
f0106b20:	5b                   	pop    %ebx
f0106b21:	5e                   	pop    %esi
f0106b22:	5f                   	pop    %edi
f0106b23:	5d                   	pop    %ebp
f0106b24:	c3                   	ret    
f0106b25:	8d 76 00             	lea    0x0(%esi),%esi
f0106b28:	39 f0                	cmp    %esi,%eax
f0106b2a:	76 14                	jbe    f0106b40 <__udivdi3+0x50>
f0106b2c:	31 ff                	xor    %edi,%edi
f0106b2e:	31 c0                	xor    %eax,%eax
f0106b30:	89 fa                	mov    %edi,%edx
f0106b32:	83 c4 1c             	add    $0x1c,%esp
f0106b35:	5b                   	pop    %ebx
f0106b36:	5e                   	pop    %esi
f0106b37:	5f                   	pop    %edi
f0106b38:	5d                   	pop    %ebp
f0106b39:	c3                   	ret    
f0106b3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106b40:	0f bd f8             	bsr    %eax,%edi
f0106b43:	83 f7 1f             	xor    $0x1f,%edi
f0106b46:	75 48                	jne    f0106b90 <__udivdi3+0xa0>
f0106b48:	39 f0                	cmp    %esi,%eax
f0106b4a:	72 06                	jb     f0106b52 <__udivdi3+0x62>
f0106b4c:	31 c0                	xor    %eax,%eax
f0106b4e:	39 eb                	cmp    %ebp,%ebx
f0106b50:	77 de                	ja     f0106b30 <__udivdi3+0x40>
f0106b52:	b8 01 00 00 00       	mov    $0x1,%eax
f0106b57:	eb d7                	jmp    f0106b30 <__udivdi3+0x40>
f0106b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106b60:	89 d9                	mov    %ebx,%ecx
f0106b62:	85 db                	test   %ebx,%ebx
f0106b64:	75 0b                	jne    f0106b71 <__udivdi3+0x81>
f0106b66:	b8 01 00 00 00       	mov    $0x1,%eax
f0106b6b:	31 d2                	xor    %edx,%edx
f0106b6d:	f7 f3                	div    %ebx
f0106b6f:	89 c1                	mov    %eax,%ecx
f0106b71:	31 d2                	xor    %edx,%edx
f0106b73:	89 f0                	mov    %esi,%eax
f0106b75:	f7 f1                	div    %ecx
f0106b77:	89 c6                	mov    %eax,%esi
f0106b79:	89 e8                	mov    %ebp,%eax
f0106b7b:	89 f7                	mov    %esi,%edi
f0106b7d:	f7 f1                	div    %ecx
f0106b7f:	89 fa                	mov    %edi,%edx
f0106b81:	83 c4 1c             	add    $0x1c,%esp
f0106b84:	5b                   	pop    %ebx
f0106b85:	5e                   	pop    %esi
f0106b86:	5f                   	pop    %edi
f0106b87:	5d                   	pop    %ebp
f0106b88:	c3                   	ret    
f0106b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106b90:	89 f9                	mov    %edi,%ecx
f0106b92:	ba 20 00 00 00       	mov    $0x20,%edx
f0106b97:	29 fa                	sub    %edi,%edx
f0106b99:	d3 e0                	shl    %cl,%eax
f0106b9b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106b9f:	89 d1                	mov    %edx,%ecx
f0106ba1:	89 d8                	mov    %ebx,%eax
f0106ba3:	d3 e8                	shr    %cl,%eax
f0106ba5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106ba9:	09 c1                	or     %eax,%ecx
f0106bab:	89 f0                	mov    %esi,%eax
f0106bad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106bb1:	89 f9                	mov    %edi,%ecx
f0106bb3:	d3 e3                	shl    %cl,%ebx
f0106bb5:	89 d1                	mov    %edx,%ecx
f0106bb7:	d3 e8                	shr    %cl,%eax
f0106bb9:	89 f9                	mov    %edi,%ecx
f0106bbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106bbf:	89 eb                	mov    %ebp,%ebx
f0106bc1:	d3 e6                	shl    %cl,%esi
f0106bc3:	89 d1                	mov    %edx,%ecx
f0106bc5:	d3 eb                	shr    %cl,%ebx
f0106bc7:	09 f3                	or     %esi,%ebx
f0106bc9:	89 c6                	mov    %eax,%esi
f0106bcb:	89 f2                	mov    %esi,%edx
f0106bcd:	89 d8                	mov    %ebx,%eax
f0106bcf:	f7 74 24 08          	divl   0x8(%esp)
f0106bd3:	89 d6                	mov    %edx,%esi
f0106bd5:	89 c3                	mov    %eax,%ebx
f0106bd7:	f7 64 24 0c          	mull   0xc(%esp)
f0106bdb:	39 d6                	cmp    %edx,%esi
f0106bdd:	72 19                	jb     f0106bf8 <__udivdi3+0x108>
f0106bdf:	89 f9                	mov    %edi,%ecx
f0106be1:	d3 e5                	shl    %cl,%ebp
f0106be3:	39 c5                	cmp    %eax,%ebp
f0106be5:	73 04                	jae    f0106beb <__udivdi3+0xfb>
f0106be7:	39 d6                	cmp    %edx,%esi
f0106be9:	74 0d                	je     f0106bf8 <__udivdi3+0x108>
f0106beb:	89 d8                	mov    %ebx,%eax
f0106bed:	31 ff                	xor    %edi,%edi
f0106bef:	e9 3c ff ff ff       	jmp    f0106b30 <__udivdi3+0x40>
f0106bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106bf8:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0106bfb:	31 ff                	xor    %edi,%edi
f0106bfd:	e9 2e ff ff ff       	jmp    f0106b30 <__udivdi3+0x40>
f0106c02:	66 90                	xchg   %ax,%ax
f0106c04:	66 90                	xchg   %ax,%ax
f0106c06:	66 90                	xchg   %ax,%ax
f0106c08:	66 90                	xchg   %ax,%ax
f0106c0a:	66 90                	xchg   %ax,%ax
f0106c0c:	66 90                	xchg   %ax,%ax
f0106c0e:	66 90                	xchg   %ax,%ax

f0106c10 <__umoddi3>:
f0106c10:	f3 0f 1e fb          	endbr32 
f0106c14:	55                   	push   %ebp
f0106c15:	57                   	push   %edi
f0106c16:	56                   	push   %esi
f0106c17:	53                   	push   %ebx
f0106c18:	83 ec 1c             	sub    $0x1c,%esp
f0106c1b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0106c1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106c23:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0106c27:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0106c2b:	89 f0                	mov    %esi,%eax
f0106c2d:	89 da                	mov    %ebx,%edx
f0106c2f:	85 ff                	test   %edi,%edi
f0106c31:	75 15                	jne    f0106c48 <__umoddi3+0x38>
f0106c33:	39 dd                	cmp    %ebx,%ebp
f0106c35:	76 39                	jbe    f0106c70 <__umoddi3+0x60>
f0106c37:	f7 f5                	div    %ebp
f0106c39:	89 d0                	mov    %edx,%eax
f0106c3b:	31 d2                	xor    %edx,%edx
f0106c3d:	83 c4 1c             	add    $0x1c,%esp
f0106c40:	5b                   	pop    %ebx
f0106c41:	5e                   	pop    %esi
f0106c42:	5f                   	pop    %edi
f0106c43:	5d                   	pop    %ebp
f0106c44:	c3                   	ret    
f0106c45:	8d 76 00             	lea    0x0(%esi),%esi
f0106c48:	39 df                	cmp    %ebx,%edi
f0106c4a:	77 f1                	ja     f0106c3d <__umoddi3+0x2d>
f0106c4c:	0f bd cf             	bsr    %edi,%ecx
f0106c4f:	83 f1 1f             	xor    $0x1f,%ecx
f0106c52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106c56:	75 40                	jne    f0106c98 <__umoddi3+0x88>
f0106c58:	39 df                	cmp    %ebx,%edi
f0106c5a:	72 04                	jb     f0106c60 <__umoddi3+0x50>
f0106c5c:	39 f5                	cmp    %esi,%ebp
f0106c5e:	77 dd                	ja     f0106c3d <__umoddi3+0x2d>
f0106c60:	89 da                	mov    %ebx,%edx
f0106c62:	89 f0                	mov    %esi,%eax
f0106c64:	29 e8                	sub    %ebp,%eax
f0106c66:	19 fa                	sbb    %edi,%edx
f0106c68:	eb d3                	jmp    f0106c3d <__umoddi3+0x2d>
f0106c6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106c70:	89 e9                	mov    %ebp,%ecx
f0106c72:	85 ed                	test   %ebp,%ebp
f0106c74:	75 0b                	jne    f0106c81 <__umoddi3+0x71>
f0106c76:	b8 01 00 00 00       	mov    $0x1,%eax
f0106c7b:	31 d2                	xor    %edx,%edx
f0106c7d:	f7 f5                	div    %ebp
f0106c7f:	89 c1                	mov    %eax,%ecx
f0106c81:	89 d8                	mov    %ebx,%eax
f0106c83:	31 d2                	xor    %edx,%edx
f0106c85:	f7 f1                	div    %ecx
f0106c87:	89 f0                	mov    %esi,%eax
f0106c89:	f7 f1                	div    %ecx
f0106c8b:	89 d0                	mov    %edx,%eax
f0106c8d:	31 d2                	xor    %edx,%edx
f0106c8f:	eb ac                	jmp    f0106c3d <__umoddi3+0x2d>
f0106c91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106c98:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106c9c:	ba 20 00 00 00       	mov    $0x20,%edx
f0106ca1:	29 c2                	sub    %eax,%edx
f0106ca3:	89 c1                	mov    %eax,%ecx
f0106ca5:	89 e8                	mov    %ebp,%eax
f0106ca7:	d3 e7                	shl    %cl,%edi
f0106ca9:	89 d1                	mov    %edx,%ecx
f0106cab:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106caf:	d3 e8                	shr    %cl,%eax
f0106cb1:	89 c1                	mov    %eax,%ecx
f0106cb3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106cb7:	09 f9                	or     %edi,%ecx
f0106cb9:	89 df                	mov    %ebx,%edi
f0106cbb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106cbf:	89 c1                	mov    %eax,%ecx
f0106cc1:	d3 e5                	shl    %cl,%ebp
f0106cc3:	89 d1                	mov    %edx,%ecx
f0106cc5:	d3 ef                	shr    %cl,%edi
f0106cc7:	89 c1                	mov    %eax,%ecx
f0106cc9:	89 f0                	mov    %esi,%eax
f0106ccb:	d3 e3                	shl    %cl,%ebx
f0106ccd:	89 d1                	mov    %edx,%ecx
f0106ccf:	89 fa                	mov    %edi,%edx
f0106cd1:	d3 e8                	shr    %cl,%eax
f0106cd3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106cd8:	09 d8                	or     %ebx,%eax
f0106cda:	f7 74 24 08          	divl   0x8(%esp)
f0106cde:	89 d3                	mov    %edx,%ebx
f0106ce0:	d3 e6                	shl    %cl,%esi
f0106ce2:	f7 e5                	mul    %ebp
f0106ce4:	89 c7                	mov    %eax,%edi
f0106ce6:	89 d1                	mov    %edx,%ecx
f0106ce8:	39 d3                	cmp    %edx,%ebx
f0106cea:	72 06                	jb     f0106cf2 <__umoddi3+0xe2>
f0106cec:	75 0e                	jne    f0106cfc <__umoddi3+0xec>
f0106cee:	39 c6                	cmp    %eax,%esi
f0106cf0:	73 0a                	jae    f0106cfc <__umoddi3+0xec>
f0106cf2:	29 e8                	sub    %ebp,%eax
f0106cf4:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106cf8:	89 d1                	mov    %edx,%ecx
f0106cfa:	89 c7                	mov    %eax,%edi
f0106cfc:	89 f5                	mov    %esi,%ebp
f0106cfe:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106d02:	29 fd                	sub    %edi,%ebp
f0106d04:	19 cb                	sbb    %ecx,%ebx
f0106d06:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0106d0b:	89 d8                	mov    %ebx,%eax
f0106d0d:	d3 e0                	shl    %cl,%eax
f0106d0f:	89 f1                	mov    %esi,%ecx
f0106d11:	d3 ed                	shr    %cl,%ebp
f0106d13:	d3 eb                	shr    %cl,%ebx
f0106d15:	09 e8                	or     %ebp,%eax
f0106d17:	89 da                	mov    %ebx,%edx
f0106d19:	83 c4 1c             	add    $0x1c,%esp
f0106d1c:	5b                   	pop    %ebx
f0106d1d:	5e                   	pop    %esi
f0106d1e:	5f                   	pop    %edi
f0106d1f:	5d                   	pop    %ebp
f0106d20:	c3                   	ret    
