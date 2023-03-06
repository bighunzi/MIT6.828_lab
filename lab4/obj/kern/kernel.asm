
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
f0100015:	b8 00 30 12 00       	mov    $0x123000,%eax
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
f0100034:	bc 00 30 12 f0       	mov    $0xf0123000,%esp

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
f0100047:	83 3d 00 80 21 f0 00 	cmpl   $0x0,0xf0218000
f010004e:	74 0f                	je     f010005f <_panic+0x1f>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100050:	83 ec 0c             	sub    $0xc,%esp
f0100053:	6a 00                	push   $0x0
f0100055:	e8 e2 08 00 00       	call   f010093c <monitor>
f010005a:	83 c4 10             	add    $0x10,%esp
f010005d:	eb f1                	jmp    f0100050 <_panic+0x10>
	panicstr = fmt;
f010005f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100062:	a3 00 80 21 f0       	mov    %eax,0xf0218000
	asm volatile("cli; cld");
f0100067:	fa                   	cli    
f0100068:	fc                   	cld    
	va_start(ap, fmt);
f0100069:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006c:	e8 9b 5d 00 00       	call   f0105e0c <cpunum>
f0100071:	ff 75 0c             	push   0xc(%ebp)
f0100074:	ff 75 08             	push   0x8(%ebp)
f0100077:	50                   	push   %eax
f0100078:	68 40 64 10 f0       	push   $0xf0106440
f010007d:	e8 30 39 00 00       	call   f01039b2 <cprintf>
	vcprintf(fmt, ap);
f0100082:	83 c4 08             	add    $0x8,%esp
f0100085:	53                   	push   %ebx
f0100086:	ff 75 10             	push   0x10(%ebp)
f0100089:	e8 fe 38 00 00       	call   f010398c <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 b3 6c 10 f0 	movl   $0xf0106cb3,(%esp)
f0100095:	e8 18 39 00 00       	call   f01039b2 <cprintf>
f010009a:	83 c4 10             	add    $0x10,%esp
f010009d:	eb b1                	jmp    f0100050 <_panic+0x10>

f010009f <i386_init>:
{
f010009f:	55                   	push   %ebp
f01000a0:	89 e5                	mov    %esp,%ebp
f01000a2:	53                   	push   %ebx
f01000a3:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000a6:	e8 7e 05 00 00       	call   f0100629 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ab:	83 ec 08             	sub    $0x8,%esp
f01000ae:	68 ac 1a 00 00       	push   $0x1aac
f01000b3:	68 ac 64 10 f0       	push   $0xf01064ac
f01000b8:	e8 f5 38 00 00       	call   f01039b2 <cprintf>
	mem_init();
f01000bd:	e8 29 12 00 00       	call   f01012eb <mem_init>
	env_init();
f01000c2:	e8 5a 30 00 00       	call   f0103121 <env_init>
	trap_init();
f01000c7:	e8 d8 39 00 00       	call   f0103aa4 <trap_init>
	mp_init();
f01000cc:	e8 55 5a 00 00       	call   f0105b26 <mp_init>
	lapic_init();
f01000d1:	e8 4c 5d 00 00       	call   f0105e22 <lapic_init>
	pic_init();
f01000d6:	e8 f8 37 00 00       	call   f01038d3 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000db:	c7 04 24 c0 53 12 f0 	movl   $0xf01253c0,(%esp)
f01000e2:	e8 95 5f 00 00       	call   f010607c <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e7:	83 c4 10             	add    $0x10,%esp
f01000ea:	83 3d 60 82 21 f0 07 	cmpl   $0x7,0xf0218260
f01000f1:	76 27                	jbe    f010011a <i386_init+0x7b>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f3:	83 ec 04             	sub    $0x4,%esp
f01000f6:	b8 82 5a 10 f0       	mov    $0xf0105a82,%eax
f01000fb:	2d 08 5a 10 f0       	sub    $0xf0105a08,%eax
f0100100:	50                   	push   %eax
f0100101:	68 08 5a 10 f0       	push   $0xf0105a08
f0100106:	68 00 70 00 f0       	push   $0xf0007000
f010010b:	e8 4d 57 00 00       	call   f010585d <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100110:	83 c4 10             	add    $0x10,%esp
f0100113:	bb 20 90 25 f0       	mov    $0xf0259020,%ebx
f0100118:	eb 19                	jmp    f0100133 <i386_init+0x94>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011a:	68 00 70 00 00       	push   $0x7000
f010011f:	68 64 64 10 f0       	push   $0xf0106464
f0100124:	6a 57                	push   $0x57
f0100126:	68 c7 64 10 f0       	push   $0xf01064c7
f010012b:	e8 10 ff ff ff       	call   f0100040 <_panic>
f0100130:	83 c3 74             	add    $0x74,%ebx
f0100133:	6b 05 00 90 25 f0 74 	imul   $0x74,0xf0259000,%eax
f010013a:	05 20 90 25 f0       	add    $0xf0259020,%eax
f010013f:	39 c3                	cmp    %eax,%ebx
f0100141:	73 4d                	jae    f0100190 <i386_init+0xf1>
		if (c == cpus + cpunum())  // We've started already.
f0100143:	e8 c4 5c 00 00       	call   f0105e0c <cpunum>
f0100148:	6b c0 74             	imul   $0x74,%eax,%eax
f010014b:	05 20 90 25 f0       	add    $0xf0259020,%eax
f0100150:	39 c3                	cmp    %eax,%ebx
f0100152:	74 dc                	je     f0100130 <i386_init+0x91>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100154:	89 d8                	mov    %ebx,%eax
f0100156:	2d 20 90 25 f0       	sub    $0xf0259020,%eax
f010015b:	c1 f8 02             	sar    $0x2,%eax
f010015e:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100164:	c1 e0 0f             	shl    $0xf,%eax
f0100167:	8d 80 00 10 22 f0    	lea    -0xfddf000(%eax),%eax
f010016d:	a3 04 80 21 f0       	mov    %eax,0xf0218004
		lapic_startap(c->cpu_id, PADDR(code));
f0100172:	83 ec 08             	sub    $0x8,%esp
f0100175:	68 00 70 00 00       	push   $0x7000
f010017a:	0f b6 03             	movzbl (%ebx),%eax
f010017d:	50                   	push   %eax
f010017e:	e8 f1 5d 00 00       	call   f0105f74 <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f0100183:	83 c4 10             	add    $0x10,%esp
f0100186:	8b 43 04             	mov    0x4(%ebx),%eax
f0100189:	83 f8 01             	cmp    $0x1,%eax
f010018c:	75 f8                	jne    f0100186 <i386_init+0xe7>
f010018e:	eb a0                	jmp    f0100130 <i386_init+0x91>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100190:	83 ec 08             	sub    $0x8,%esp
f0100193:	6a 00                	push   $0x0
f0100195:	68 ec ed 20 f0       	push   $0xf020edec
f010019a:	e8 89 31 00 00       	call   f0103328 <env_create>
	sched_yield();
f010019f:	e8 49 44 00 00       	call   f01045ed <sched_yield>

f01001a4 <mp_main>:
{
f01001a4:	55                   	push   %ebp
f01001a5:	89 e5                	mov    %esp,%ebp
f01001a7:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001aa:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001af:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001b4:	76 52                	jbe    f0100208 <mp_main+0x64>
	return (physaddr_t)kva - KERNBASE;
f01001b6:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f01001bb:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001be:	e8 49 5c 00 00       	call   f0105e0c <cpunum>
f01001c3:	83 ec 08             	sub    $0x8,%esp
f01001c6:	50                   	push   %eax
f01001c7:	68 d3 64 10 f0       	push   $0xf01064d3
f01001cc:	e8 e1 37 00 00       	call   f01039b2 <cprintf>
	lapic_init();
f01001d1:	e8 4c 5c 00 00       	call   f0105e22 <lapic_init>
	env_init_percpu();
f01001d6:	e8 1a 2f 00 00       	call   f01030f5 <env_init_percpu>
	trap_init_percpu();
f01001db:	e8 e6 37 00 00       	call   f01039c6 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001e0:	e8 27 5c 00 00       	call   f0105e0c <cpunum>
f01001e5:	6b d0 74             	imul   $0x74,%eax,%edx
f01001e8:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001eb:	b8 01 00 00 00       	mov    $0x1,%eax
f01001f0:	f0 87 82 20 90 25 f0 	lock xchg %eax,-0xfda6fe0(%edx)
f01001f7:	c7 04 24 c0 53 12 f0 	movl   $0xf01253c0,(%esp)
f01001fe:	e8 79 5e 00 00       	call   f010607c <spin_lock>
	sched_yield();
f0100203:	e8 e5 43 00 00       	call   f01045ed <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100208:	50                   	push   %eax
f0100209:	68 88 64 10 f0       	push   $0xf0106488
f010020e:	6a 6e                	push   $0x6e
f0100210:	68 c7 64 10 f0       	push   $0xf01064c7
f0100215:	e8 26 fe ff ff       	call   f0100040 <_panic>

f010021a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010021a:	55                   	push   %ebp
f010021b:	89 e5                	mov    %esp,%ebp
f010021d:	53                   	push   %ebx
f010021e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100221:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100224:	ff 75 0c             	push   0xc(%ebp)
f0100227:	ff 75 08             	push   0x8(%ebp)
f010022a:	68 e9 64 10 f0       	push   $0xf01064e9
f010022f:	e8 7e 37 00 00       	call   f01039b2 <cprintf>
	vcprintf(fmt, ap);
f0100234:	83 c4 08             	add    $0x8,%esp
f0100237:	53                   	push   %ebx
f0100238:	ff 75 10             	push   0x10(%ebp)
f010023b:	e8 4c 37 00 00       	call   f010398c <vcprintf>
	cprintf("\n");
f0100240:	c7 04 24 b3 6c 10 f0 	movl   $0xf0106cb3,(%esp)
f0100247:	e8 66 37 00 00       	call   f01039b2 <cprintf>
	va_end(ap);
}
f010024c:	83 c4 10             	add    $0x10,%esp
f010024f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100252:	c9                   	leave  
f0100253:	c3                   	ret    

f0100254 <serial_proc_data>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100254:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100259:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010025a:	a8 01                	test   $0x1,%al
f010025c:	74 0a                	je     f0100268 <serial_proc_data+0x14>
f010025e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100263:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100264:	0f b6 c0             	movzbl %al,%eax
f0100267:	c3                   	ret    
		return -1;
f0100268:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010026d:	c3                   	ret    

f010026e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010026e:	55                   	push   %ebp
f010026f:	89 e5                	mov    %esp,%ebp
f0100271:	53                   	push   %ebx
f0100272:	83 ec 04             	sub    $0x4,%esp
f0100275:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100277:	eb 23                	jmp    f010029c <cons_intr+0x2e>
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100279:	8b 0d 44 82 21 f0    	mov    0xf0218244,%ecx
f010027f:	8d 51 01             	lea    0x1(%ecx),%edx
f0100282:	88 81 40 80 21 f0    	mov    %al,-0xfde7fc0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100288:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f010028e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100293:	0f 44 d0             	cmove  %eax,%edx
f0100296:	89 15 44 82 21 f0    	mov    %edx,0xf0218244
	while ((c = (*proc)()) != -1) {
f010029c:	ff d3                	call   *%ebx
f010029e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002a1:	74 06                	je     f01002a9 <cons_intr+0x3b>
		if (c == 0)
f01002a3:	85 c0                	test   %eax,%eax
f01002a5:	75 d2                	jne    f0100279 <cons_intr+0xb>
f01002a7:	eb f3                	jmp    f010029c <cons_intr+0x2e>
	}
}
f01002a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002ac:	c9                   	leave  
f01002ad:	c3                   	ret    

f01002ae <kbd_proc_data>:
{
f01002ae:	55                   	push   %ebp
f01002af:	89 e5                	mov    %esp,%ebp
f01002b1:	53                   	push   %ebx
f01002b2:	83 ec 04             	sub    $0x4,%esp
f01002b5:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ba:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002bb:	a8 01                	test   $0x1,%al
f01002bd:	0f 84 ee 00 00 00    	je     f01003b1 <kbd_proc_data+0x103>
	if (stat & KBS_TERR)
f01002c3:	a8 20                	test   $0x20,%al
f01002c5:	0f 85 ed 00 00 00    	jne    f01003b8 <kbd_proc_data+0x10a>
f01002cb:	ba 60 00 00 00       	mov    $0x60,%edx
f01002d0:	ec                   	in     (%dx),%al
f01002d1:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002d3:	3c e0                	cmp    $0xe0,%al
f01002d5:	74 61                	je     f0100338 <kbd_proc_data+0x8a>
	} else if (data & 0x80) {
f01002d7:	84 c0                	test   %al,%al
f01002d9:	78 70                	js     f010034b <kbd_proc_data+0x9d>
	} else if (shift & E0ESC) {
f01002db:	8b 0d 20 80 21 f0    	mov    0xf0218020,%ecx
f01002e1:	f6 c1 40             	test   $0x40,%cl
f01002e4:	74 0e                	je     f01002f4 <kbd_proc_data+0x46>
		data |= 0x80;
f01002e6:	83 c8 80             	or     $0xffffff80,%eax
f01002e9:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002eb:	83 e1 bf             	and    $0xffffffbf,%ecx
f01002ee:	89 0d 20 80 21 f0    	mov    %ecx,0xf0218020
	shift |= shiftcode[data];
f01002f4:	0f b6 d2             	movzbl %dl,%edx
f01002f7:	0f b6 82 60 66 10 f0 	movzbl -0xfef99a0(%edx),%eax
f01002fe:	0b 05 20 80 21 f0    	or     0xf0218020,%eax
	shift ^= togglecode[data];
f0100304:	0f b6 8a 60 65 10 f0 	movzbl -0xfef9aa0(%edx),%ecx
f010030b:	31 c8                	xor    %ecx,%eax
f010030d:	a3 20 80 21 f0       	mov    %eax,0xf0218020
	c = charcode[shift & (CTL | SHIFT)][data];
f0100312:	89 c1                	mov    %eax,%ecx
f0100314:	83 e1 03             	and    $0x3,%ecx
f0100317:	8b 0c 8d 40 65 10 f0 	mov    -0xfef9ac0(,%ecx,4),%ecx
f010031e:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100322:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100325:	a8 08                	test   $0x8,%al
f0100327:	74 5d                	je     f0100386 <kbd_proc_data+0xd8>
		if ('a' <= c && c <= 'z')
f0100329:	89 da                	mov    %ebx,%edx
f010032b:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010032e:	83 f9 19             	cmp    $0x19,%ecx
f0100331:	77 47                	ja     f010037a <kbd_proc_data+0xcc>
			c += 'A' - 'a';
f0100333:	83 eb 20             	sub    $0x20,%ebx
f0100336:	eb 0c                	jmp    f0100344 <kbd_proc_data+0x96>
		shift |= E0ESC;
f0100338:	83 0d 20 80 21 f0 40 	orl    $0x40,0xf0218020
		return 0;
f010033f:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100344:	89 d8                	mov    %ebx,%eax
f0100346:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100349:	c9                   	leave  
f010034a:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010034b:	8b 0d 20 80 21 f0    	mov    0xf0218020,%ecx
f0100351:	83 e0 7f             	and    $0x7f,%eax
f0100354:	f6 c1 40             	test   $0x40,%cl
f0100357:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010035a:	0f b6 d2             	movzbl %dl,%edx
f010035d:	0f b6 82 60 66 10 f0 	movzbl -0xfef99a0(%edx),%eax
f0100364:	83 c8 40             	or     $0x40,%eax
f0100367:	0f b6 c0             	movzbl %al,%eax
f010036a:	f7 d0                	not    %eax
f010036c:	21 c8                	and    %ecx,%eax
f010036e:	a3 20 80 21 f0       	mov    %eax,0xf0218020
		return 0;
f0100373:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100378:	eb ca                	jmp    f0100344 <kbd_proc_data+0x96>
		else if ('A' <= c && c <= 'Z')
f010037a:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010037d:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100380:	83 fa 1a             	cmp    $0x1a,%edx
f0100383:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100386:	f7 d0                	not    %eax
f0100388:	a8 06                	test   $0x6,%al
f010038a:	75 b8                	jne    f0100344 <kbd_proc_data+0x96>
f010038c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100392:	75 b0                	jne    f0100344 <kbd_proc_data+0x96>
		cprintf("Rebooting!\n");
f0100394:	83 ec 0c             	sub    $0xc,%esp
f0100397:	68 03 65 10 f0       	push   $0xf0106503
f010039c:	e8 11 36 00 00       	call   f01039b2 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a1:	b8 03 00 00 00       	mov    $0x3,%eax
f01003a6:	ba 92 00 00 00       	mov    $0x92,%edx
f01003ab:	ee                   	out    %al,(%dx)
}
f01003ac:	83 c4 10             	add    $0x10,%esp
f01003af:	eb 93                	jmp    f0100344 <kbd_proc_data+0x96>
		return -1;
f01003b1:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003b6:	eb 8c                	jmp    f0100344 <kbd_proc_data+0x96>
		return -1;
f01003b8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003bd:	eb 85                	jmp    f0100344 <kbd_proc_data+0x96>

f01003bf <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003bf:	55                   	push   %ebp
f01003c0:	89 e5                	mov    %esp,%ebp
f01003c2:	57                   	push   %edi
f01003c3:	56                   	push   %esi
f01003c4:	53                   	push   %ebx
f01003c5:	83 ec 1c             	sub    $0x1c,%esp
f01003c8:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003ca:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003cf:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003d4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003d9:	89 f2                	mov    %esi,%edx
f01003db:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003dc:	a8 20                	test   $0x20,%al
f01003de:	75 13                	jne    f01003f3 <cons_putc+0x34>
f01003e0:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003e6:	7f 0b                	jg     f01003f3 <cons_putc+0x34>
f01003e8:	89 ca                	mov    %ecx,%edx
f01003ea:	ec                   	in     (%dx),%al
f01003eb:	ec                   	in     (%dx),%al
f01003ec:	ec                   	in     (%dx),%al
f01003ed:	ec                   	in     (%dx),%al
	     i++)
f01003ee:	83 c3 01             	add    $0x1,%ebx
f01003f1:	eb e6                	jmp    f01003d9 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f01003f3:	89 f8                	mov    %edi,%eax
f01003f5:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003f8:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003fd:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003fe:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100403:	be 79 03 00 00       	mov    $0x379,%esi
f0100408:	b9 84 00 00 00       	mov    $0x84,%ecx
f010040d:	89 f2                	mov    %esi,%edx
f010040f:	ec                   	in     (%dx),%al
f0100410:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100416:	7f 0f                	jg     f0100427 <cons_putc+0x68>
f0100418:	84 c0                	test   %al,%al
f010041a:	78 0b                	js     f0100427 <cons_putc+0x68>
f010041c:	89 ca                	mov    %ecx,%edx
f010041e:	ec                   	in     (%dx),%al
f010041f:	ec                   	in     (%dx),%al
f0100420:	ec                   	in     (%dx),%al
f0100421:	ec                   	in     (%dx),%al
f0100422:	83 c3 01             	add    $0x1,%ebx
f0100425:	eb e6                	jmp    f010040d <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100427:	ba 78 03 00 00       	mov    $0x378,%edx
f010042c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100430:	ee                   	out    %al,(%dx)
f0100431:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100436:	b8 0d 00 00 00       	mov    $0xd,%eax
f010043b:	ee                   	out    %al,(%dx)
f010043c:	b8 08 00 00 00       	mov    $0x8,%eax
f0100441:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100442:	89 f8                	mov    %edi,%eax
f0100444:	80 cc 07             	or     $0x7,%ah
f0100447:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010044d:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100450:	89 f8                	mov    %edi,%eax
f0100452:	0f b6 c0             	movzbl %al,%eax
f0100455:	89 fb                	mov    %edi,%ebx
f0100457:	80 fb 0a             	cmp    $0xa,%bl
f010045a:	0f 84 e1 00 00 00    	je     f0100541 <cons_putc+0x182>
f0100460:	83 f8 0a             	cmp    $0xa,%eax
f0100463:	7f 46                	jg     f01004ab <cons_putc+0xec>
f0100465:	83 f8 08             	cmp    $0x8,%eax
f0100468:	0f 84 a7 00 00 00    	je     f0100515 <cons_putc+0x156>
f010046e:	83 f8 09             	cmp    $0x9,%eax
f0100471:	0f 85 d7 00 00 00    	jne    f010054e <cons_putc+0x18f>
		cons_putc(' ');
f0100477:	b8 20 00 00 00       	mov    $0x20,%eax
f010047c:	e8 3e ff ff ff       	call   f01003bf <cons_putc>
		cons_putc(' ');
f0100481:	b8 20 00 00 00       	mov    $0x20,%eax
f0100486:	e8 34 ff ff ff       	call   f01003bf <cons_putc>
		cons_putc(' ');
f010048b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100490:	e8 2a ff ff ff       	call   f01003bf <cons_putc>
		cons_putc(' ');
f0100495:	b8 20 00 00 00       	mov    $0x20,%eax
f010049a:	e8 20 ff ff ff       	call   f01003bf <cons_putc>
		cons_putc(' ');
f010049f:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a4:	e8 16 ff ff ff       	call   f01003bf <cons_putc>
		break;
f01004a9:	eb 25                	jmp    f01004d0 <cons_putc+0x111>
	switch (c & 0xff) {
f01004ab:	83 f8 0d             	cmp    $0xd,%eax
f01004ae:	0f 85 9a 00 00 00    	jne    f010054e <cons_putc+0x18f>
		crt_pos -= (crt_pos % CRT_COLS);
f01004b4:	0f b7 05 48 82 21 f0 	movzwl 0xf0218248,%eax
f01004bb:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004c1:	c1 e8 16             	shr    $0x16,%eax
f01004c4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004c7:	c1 e0 04             	shl    $0x4,%eax
f01004ca:	66 a3 48 82 21 f0    	mov    %ax,0xf0218248
	if (crt_pos >= CRT_SIZE) {
f01004d0:	66 81 3d 48 82 21 f0 	cmpw   $0x7cf,0xf0218248
f01004d7:	cf 07 
f01004d9:	0f 87 92 00 00 00    	ja     f0100571 <cons_putc+0x1b2>
	outb(addr_6845, 14);
f01004df:	8b 0d 50 82 21 f0    	mov    0xf0218250,%ecx
f01004e5:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004ea:	89 ca                	mov    %ecx,%edx
f01004ec:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004ed:	0f b7 1d 48 82 21 f0 	movzwl 0xf0218248,%ebx
f01004f4:	8d 71 01             	lea    0x1(%ecx),%esi
f01004f7:	89 d8                	mov    %ebx,%eax
f01004f9:	66 c1 e8 08          	shr    $0x8,%ax
f01004fd:	89 f2                	mov    %esi,%edx
f01004ff:	ee                   	out    %al,(%dx)
f0100500:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100505:	89 ca                	mov    %ecx,%edx
f0100507:	ee                   	out    %al,(%dx)
f0100508:	89 d8                	mov    %ebx,%eax
f010050a:	89 f2                	mov    %esi,%edx
f010050c:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010050d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100510:	5b                   	pop    %ebx
f0100511:	5e                   	pop    %esi
f0100512:	5f                   	pop    %edi
f0100513:	5d                   	pop    %ebp
f0100514:	c3                   	ret    
		if (crt_pos > 0) {
f0100515:	0f b7 05 48 82 21 f0 	movzwl 0xf0218248,%eax
f010051c:	66 85 c0             	test   %ax,%ax
f010051f:	74 be                	je     f01004df <cons_putc+0x120>
			crt_pos--;
f0100521:	83 e8 01             	sub    $0x1,%eax
f0100524:	66 a3 48 82 21 f0    	mov    %ax,0xf0218248
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010052a:	0f b7 c0             	movzwl %ax,%eax
f010052d:	66 81 e7 00 ff       	and    $0xff00,%di
f0100532:	83 cf 20             	or     $0x20,%edi
f0100535:	8b 15 4c 82 21 f0    	mov    0xf021824c,%edx
f010053b:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010053f:	eb 8f                	jmp    f01004d0 <cons_putc+0x111>
		crt_pos += CRT_COLS;
f0100541:	66 83 05 48 82 21 f0 	addw   $0x50,0xf0218248
f0100548:	50 
f0100549:	e9 66 ff ff ff       	jmp    f01004b4 <cons_putc+0xf5>
		crt_buf[crt_pos++] = c;		/* write the character */
f010054e:	0f b7 05 48 82 21 f0 	movzwl 0xf0218248,%eax
f0100555:	8d 50 01             	lea    0x1(%eax),%edx
f0100558:	66 89 15 48 82 21 f0 	mov    %dx,0xf0218248
f010055f:	0f b7 c0             	movzwl %ax,%eax
f0100562:	8b 15 4c 82 21 f0    	mov    0xf021824c,%edx
f0100568:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f010056c:	e9 5f ff ff ff       	jmp    f01004d0 <cons_putc+0x111>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100571:	a1 4c 82 21 f0       	mov    0xf021824c,%eax
f0100576:	83 ec 04             	sub    $0x4,%esp
f0100579:	68 00 0f 00 00       	push   $0xf00
f010057e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100584:	52                   	push   %edx
f0100585:	50                   	push   %eax
f0100586:	e8 d2 52 00 00       	call   f010585d <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010058b:	8b 15 4c 82 21 f0    	mov    0xf021824c,%edx
f0100591:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100597:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010059d:	83 c4 10             	add    $0x10,%esp
f01005a0:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005a5:	83 c0 02             	add    $0x2,%eax
f01005a8:	39 d0                	cmp    %edx,%eax
f01005aa:	75 f4                	jne    f01005a0 <cons_putc+0x1e1>
		crt_pos -= CRT_COLS;
f01005ac:	66 83 2d 48 82 21 f0 	subw   $0x50,0xf0218248
f01005b3:	50 
f01005b4:	e9 26 ff ff ff       	jmp    f01004df <cons_putc+0x120>

f01005b9 <serial_intr>:
	if (serial_exists)
f01005b9:	80 3d 54 82 21 f0 00 	cmpb   $0x0,0xf0218254
f01005c0:	75 01                	jne    f01005c3 <serial_intr+0xa>
f01005c2:	c3                   	ret    
{
f01005c3:	55                   	push   %ebp
f01005c4:	89 e5                	mov    %esp,%ebp
f01005c6:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005c9:	b8 54 02 10 f0       	mov    $0xf0100254,%eax
f01005ce:	e8 9b fc ff ff       	call   f010026e <cons_intr>
}
f01005d3:	c9                   	leave  
f01005d4:	c3                   	ret    

f01005d5 <kbd_intr>:
{
f01005d5:	55                   	push   %ebp
f01005d6:	89 e5                	mov    %esp,%ebp
f01005d8:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005db:	b8 ae 02 10 f0       	mov    $0xf01002ae,%eax
f01005e0:	e8 89 fc ff ff       	call   f010026e <cons_intr>
}
f01005e5:	c9                   	leave  
f01005e6:	c3                   	ret    

f01005e7 <cons_getc>:
{
f01005e7:	55                   	push   %ebp
f01005e8:	89 e5                	mov    %esp,%ebp
f01005ea:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01005ed:	e8 c7 ff ff ff       	call   f01005b9 <serial_intr>
	kbd_intr();
f01005f2:	e8 de ff ff ff       	call   f01005d5 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005f7:	a1 40 82 21 f0       	mov    0xf0218240,%eax
	return 0;
f01005fc:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100601:	3b 05 44 82 21 f0    	cmp    0xf0218244,%eax
f0100607:	74 1c                	je     f0100625 <cons_getc+0x3e>
		c = cons.buf[cons.rpos++];
f0100609:	8d 48 01             	lea    0x1(%eax),%ecx
f010060c:	0f b6 90 40 80 21 f0 	movzbl -0xfde7fc0(%eax),%edx
			cons.rpos = 0;
f0100613:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100618:	b8 00 00 00 00       	mov    $0x0,%eax
f010061d:	0f 45 c1             	cmovne %ecx,%eax
f0100620:	a3 40 82 21 f0       	mov    %eax,0xf0218240
}
f0100625:	89 d0                	mov    %edx,%eax
f0100627:	c9                   	leave  
f0100628:	c3                   	ret    

f0100629 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100629:	55                   	push   %ebp
f010062a:	89 e5                	mov    %esp,%ebp
f010062c:	57                   	push   %edi
f010062d:	56                   	push   %esi
f010062e:	53                   	push   %ebx
f010062f:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100632:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100639:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100640:	5a a5 
	if (*cp != 0xA55A) {
f0100642:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100649:	bb b4 03 00 00       	mov    $0x3b4,%ebx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010064e:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	if (*cp != 0xA55A) {
f0100653:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100657:	0f 84 c3 00 00 00    	je     f0100720 <cons_init+0xf7>
		addr_6845 = MONO_BASE;
f010065d:	89 1d 50 82 21 f0    	mov    %ebx,0xf0218250
f0100663:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100668:	89 da                	mov    %ebx,%edx
f010066a:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010066b:	8d 7b 01             	lea    0x1(%ebx),%edi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010066e:	89 fa                	mov    %edi,%edx
f0100670:	ec                   	in     (%dx),%al
f0100671:	0f b6 c8             	movzbl %al,%ecx
f0100674:	c1 e1 08             	shl    $0x8,%ecx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100677:	b8 0f 00 00 00       	mov    $0xf,%eax
f010067c:	89 da                	mov    %ebx,%edx
f010067e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010067f:	89 fa                	mov    %edi,%edx
f0100681:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100682:	89 35 4c 82 21 f0    	mov    %esi,0xf021824c
	pos |= inb(addr_6845 + 1);
f0100688:	0f b6 c0             	movzbl %al,%eax
f010068b:	09 c8                	or     %ecx,%eax
	crt_pos = pos;
f010068d:	66 a3 48 82 21 f0    	mov    %ax,0xf0218248
	kbd_intr();
f0100693:	e8 3d ff ff ff       	call   f01005d5 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100698:	83 ec 0c             	sub    $0xc,%esp
f010069b:	0f b7 05 a8 53 12 f0 	movzwl 0xf01253a8,%eax
f01006a2:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006a7:	50                   	push   %eax
f01006a8:	e8 a3 31 00 00       	call   f0103850 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ad:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006b2:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01006b7:	89 c8                	mov    %ecx,%eax
f01006b9:	89 da                	mov    %ebx,%edx
f01006bb:	ee                   	out    %al,(%dx)
f01006bc:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006c1:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006c6:	89 fa                	mov    %edi,%edx
f01006c8:	ee                   	out    %al,(%dx)
f01006c9:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ce:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006d3:	ee                   	out    %al,(%dx)
f01006d4:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006d9:	89 c8                	mov    %ecx,%eax
f01006db:	89 f2                	mov    %esi,%edx
f01006dd:	ee                   	out    %al,(%dx)
f01006de:	b8 03 00 00 00       	mov    $0x3,%eax
f01006e3:	89 fa                	mov    %edi,%edx
f01006e5:	ee                   	out    %al,(%dx)
f01006e6:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006eb:	89 c8                	mov    %ecx,%eax
f01006ed:	ee                   	out    %al,(%dx)
f01006ee:	b8 01 00 00 00       	mov    $0x1,%eax
f01006f3:	89 f2                	mov    %esi,%edx
f01006f5:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006f6:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006fb:	ec                   	in     (%dx),%al
f01006fc:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006fe:	83 c4 10             	add    $0x10,%esp
f0100701:	3c ff                	cmp    $0xff,%al
f0100703:	0f 95 05 54 82 21 f0 	setne  0xf0218254
f010070a:	89 da                	mov    %ebx,%edx
f010070c:	ec                   	in     (%dx),%al
f010070d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100712:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100713:	80 f9 ff             	cmp    $0xff,%cl
f0100716:	74 1e                	je     f0100736 <cons_init+0x10d>
		cprintf("Serial port does not exist!\n");
}
f0100718:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010071b:	5b                   	pop    %ebx
f010071c:	5e                   	pop    %esi
f010071d:	5f                   	pop    %edi
f010071e:	5d                   	pop    %ebp
f010071f:	c3                   	ret    
		*cp = was;
f0100720:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f0100727:	bb d4 03 00 00       	mov    $0x3d4,%ebx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010072c:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100731:	e9 27 ff ff ff       	jmp    f010065d <cons_init+0x34>
		cprintf("Serial port does not exist!\n");
f0100736:	83 ec 0c             	sub    $0xc,%esp
f0100739:	68 0f 65 10 f0       	push   $0xf010650f
f010073e:	e8 6f 32 00 00       	call   f01039b2 <cprintf>
f0100743:	83 c4 10             	add    $0x10,%esp
}
f0100746:	eb d0                	jmp    f0100718 <cons_init+0xef>

f0100748 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100748:	55                   	push   %ebp
f0100749:	89 e5                	mov    %esp,%ebp
f010074b:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010074e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100751:	e8 69 fc ff ff       	call   f01003bf <cons_putc>
}
f0100756:	c9                   	leave  
f0100757:	c3                   	ret    

f0100758 <getchar>:

int
getchar(void)
{
f0100758:	55                   	push   %ebp
f0100759:	89 e5                	mov    %esp,%ebp
f010075b:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010075e:	e8 84 fe ff ff       	call   f01005e7 <cons_getc>
f0100763:	85 c0                	test   %eax,%eax
f0100765:	74 f7                	je     f010075e <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100767:	c9                   	leave  
f0100768:	c3                   	ret    

f0100769 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100769:	b8 01 00 00 00       	mov    $0x1,%eax
f010076e:	c3                   	ret    

f010076f <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010076f:	55                   	push   %ebp
f0100770:	89 e5                	mov    %esp,%ebp
f0100772:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100775:	68 60 67 10 f0       	push   $0xf0106760
f010077a:	68 7e 67 10 f0       	push   $0xf010677e
f010077f:	68 83 67 10 f0       	push   $0xf0106783
f0100784:	e8 29 32 00 00       	call   f01039b2 <cprintf>
f0100789:	83 c4 0c             	add    $0xc,%esp
f010078c:	68 24 68 10 f0       	push   $0xf0106824
f0100791:	68 8c 67 10 f0       	push   $0xf010678c
f0100796:	68 83 67 10 f0       	push   $0xf0106783
f010079b:	e8 12 32 00 00       	call   f01039b2 <cprintf>
	return 0;
}
f01007a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a5:	c9                   	leave  
f01007a6:	c3                   	ret    

f01007a7 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007a7:	55                   	push   %ebp
f01007a8:	89 e5                	mov    %esp,%ebp
f01007aa:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007ad:	68 95 67 10 f0       	push   $0xf0106795
f01007b2:	e8 fb 31 00 00       	call   f01039b2 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007b7:	83 c4 08             	add    $0x8,%esp
f01007ba:	68 0c 00 10 00       	push   $0x10000c
f01007bf:	68 4c 68 10 f0       	push   $0xf010684c
f01007c4:	e8 e9 31 00 00       	call   f01039b2 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007c9:	83 c4 0c             	add    $0xc,%esp
f01007cc:	68 0c 00 10 00       	push   $0x10000c
f01007d1:	68 0c 00 10 f0       	push   $0xf010000c
f01007d6:	68 74 68 10 f0       	push   $0xf0106874
f01007db:	e8 d2 31 00 00       	call   f01039b2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007e0:	83 c4 0c             	add    $0xc,%esp
f01007e3:	68 31 64 10 00       	push   $0x106431
f01007e8:	68 31 64 10 f0       	push   $0xf0106431
f01007ed:	68 98 68 10 f0       	push   $0xf0106898
f01007f2:	e8 bb 31 00 00       	call   f01039b2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007f7:	83 c4 0c             	add    $0xc,%esp
f01007fa:	68 00 80 21 00       	push   $0x218000
f01007ff:	68 00 80 21 f0       	push   $0xf0218000
f0100804:	68 bc 68 10 f0       	push   $0xf01068bc
f0100809:	e8 a4 31 00 00       	call   f01039b2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010080e:	83 c4 0c             	add    $0xc,%esp
f0100811:	68 c8 93 25 00       	push   $0x2593c8
f0100816:	68 c8 93 25 f0       	push   $0xf02593c8
f010081b:	68 e0 68 10 f0       	push   $0xf01068e0
f0100820:	e8 8d 31 00 00       	call   f01039b2 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100825:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100828:	b8 c8 93 25 f0       	mov    $0xf02593c8,%eax
f010082d:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100832:	c1 f8 0a             	sar    $0xa,%eax
f0100835:	50                   	push   %eax
f0100836:	68 04 69 10 f0       	push   $0xf0106904
f010083b:	e8 72 31 00 00       	call   f01039b2 <cprintf>
	return 0;
}
f0100840:	b8 00 00 00 00       	mov    $0x0,%eax
f0100845:	c9                   	leave  
f0100846:	c3                   	ret    

f0100847 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100847:	55                   	push   %ebp
f0100848:	89 e5                	mov    %esp,%ebp
f010084a:	56                   	push   %esi
f010084b:	53                   	push   %ebx
f010084c:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));//I guess it means moving ebp register value to local variable. 
f010084f:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	uint32_t * ebp;
	struct Eipdebuginfo info;
	
	ebp=(uint32_t *)read_ebp();
	cprintf("Stack backtrace:\n");
f0100851:	68 ae 67 10 f0       	push   $0xf01067ae
f0100856:	e8 57 31 00 00       	call   f01039b2 <cprintf>
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f010085b:	83 c4 10             	add    $0x10,%esp
		cprintf(" %08x",*(ebp+4));
		cprintf(" %08x",*(ebp+5));
		cprintf(" %08x\n",*(ebp+6));
		
		//Exercise 12
		debuginfo_eip(*(ebp+1) , &info);
f010085e:	8d 75 e0             	lea    -0x20(%ebp),%esi
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f0100861:	e9 c2 00 00 00       	jmp    f0100928 <mon_backtrace+0xe1>
		cprintf(" ebp %08x",(uint32_t) ebp);
f0100866:	83 ec 08             	sub    $0x8,%esp
f0100869:	53                   	push   %ebx
f010086a:	68 c0 67 10 f0       	push   $0xf01067c0
f010086f:	e8 3e 31 00 00       	call   f01039b2 <cprintf>
		cprintf(" eip %08x",*(ebp+1));
f0100874:	83 c4 08             	add    $0x8,%esp
f0100877:	ff 73 04             	push   0x4(%ebx)
f010087a:	68 ca 67 10 f0       	push   $0xf01067ca
f010087f:	e8 2e 31 00 00       	call   f01039b2 <cprintf>
		cprintf(" args");
f0100884:	c7 04 24 d4 67 10 f0 	movl   $0xf01067d4,(%esp)
f010088b:	e8 22 31 00 00       	call   f01039b2 <cprintf>
		cprintf(" %08x",*(ebp+2));
f0100890:	83 c4 08             	add    $0x8,%esp
f0100893:	ff 73 08             	push   0x8(%ebx)
f0100896:	68 c4 67 10 f0       	push   $0xf01067c4
f010089b:	e8 12 31 00 00       	call   f01039b2 <cprintf>
		cprintf(" %08x",*(ebp+3));
f01008a0:	83 c4 08             	add    $0x8,%esp
f01008a3:	ff 73 0c             	push   0xc(%ebx)
f01008a6:	68 c4 67 10 f0       	push   $0xf01067c4
f01008ab:	e8 02 31 00 00       	call   f01039b2 <cprintf>
		cprintf(" %08x",*(ebp+4));
f01008b0:	83 c4 08             	add    $0x8,%esp
f01008b3:	ff 73 10             	push   0x10(%ebx)
f01008b6:	68 c4 67 10 f0       	push   $0xf01067c4
f01008bb:	e8 f2 30 00 00       	call   f01039b2 <cprintf>
		cprintf(" %08x",*(ebp+5));
f01008c0:	83 c4 08             	add    $0x8,%esp
f01008c3:	ff 73 14             	push   0x14(%ebx)
f01008c6:	68 c4 67 10 f0       	push   $0xf01067c4
f01008cb:	e8 e2 30 00 00       	call   f01039b2 <cprintf>
		cprintf(" %08x\n",*(ebp+6));
f01008d0:	83 c4 08             	add    $0x8,%esp
f01008d3:	ff 73 18             	push   0x18(%ebx)
f01008d6:	68 32 81 10 f0       	push   $0xf0108132
f01008db:	e8 d2 30 00 00       	call   f01039b2 <cprintf>
		debuginfo_eip(*(ebp+1) , &info);
f01008e0:	83 c4 08             	add    $0x8,%esp
f01008e3:	56                   	push   %esi
f01008e4:	ff 73 04             	push   0x4(%ebx)
f01008e7:	e8 66 44 00 00       	call   f0104d52 <debuginfo_eip>
		cprintf("\t%s:",info.eip_file);
f01008ec:	83 c4 08             	add    $0x8,%esp
f01008ef:	ff 75 e0             	push   -0x20(%ebp)
f01008f2:	68 da 67 10 f0       	push   $0xf01067da
f01008f7:	e8 b6 30 00 00       	call   f01039b2 <cprintf>
		cprintf("%d: ",info.eip_line);
f01008fc:	83 c4 08             	add    $0x8,%esp
f01008ff:	ff 75 e4             	push   -0x1c(%ebp)
f0100902:	68 fe 64 10 f0       	push   $0xf01064fe
f0100907:	e8 a6 30 00 00       	call   f01039b2 <cprintf>
		cprintf("%.*s+%d\n", info.eip_fn_namelen , info.eip_fn_name , *(ebp+1) - info.eip_fn_addr );
f010090c:	8b 43 04             	mov    0x4(%ebx),%eax
f010090f:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100912:	50                   	push   %eax
f0100913:	ff 75 e8             	push   -0x18(%ebp)
f0100916:	ff 75 ec             	push   -0x14(%ebp)
f0100919:	68 df 67 10 f0       	push   $0xf01067df
f010091e:	e8 8f 30 00 00       	call   f01039b2 <cprintf>
		
		//
		ebp=(uint32_t *)(*ebp);
f0100923:	8b 1b                	mov    (%ebx),%ebx
f0100925:	83 c4 20             	add    $0x20,%esp
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f0100928:	85 db                	test   %ebx,%ebx
f010092a:	0f 85 36 ff ff ff    	jne    f0100866 <mon_backtrace+0x1f>
    	cprintf("x=%d y=%d\n", 3);
    	
	cprintf("Lab1 Exercise8 qusetion3 finish!\n");
	*/
	return 0;
}
f0100930:	b8 00 00 00 00       	mov    $0x0,%eax
f0100935:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100938:	5b                   	pop    %ebx
f0100939:	5e                   	pop    %esi
f010093a:	5d                   	pop    %ebp
f010093b:	c3                   	ret    

f010093c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010093c:	55                   	push   %ebp
f010093d:	89 e5                	mov    %esp,%ebp
f010093f:	57                   	push   %edi
f0100940:	56                   	push   %esi
f0100941:	53                   	push   %ebx
f0100942:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100945:	68 30 69 10 f0       	push   $0xf0106930
f010094a:	e8 63 30 00 00       	call   f01039b2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010094f:	c7 04 24 54 69 10 f0 	movl   $0xf0106954,(%esp)
f0100956:	e8 57 30 00 00       	call   f01039b2 <cprintf>

	if (tf != NULL)
f010095b:	83 c4 10             	add    $0x10,%esp
f010095e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100962:	74 57                	je     f01009bb <monitor+0x7f>
		print_trapframe(tf);
f0100964:	83 ec 0c             	sub    $0xc,%esp
f0100967:	ff 75 08             	push   0x8(%ebp)
f010096a:	e8 03 36 00 00       	call   f0103f72 <print_trapframe>
f010096f:	83 c4 10             	add    $0x10,%esp
f0100972:	eb 47                	jmp    f01009bb <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f0100974:	83 ec 08             	sub    $0x8,%esp
f0100977:	0f be c0             	movsbl %al,%eax
f010097a:	50                   	push   %eax
f010097b:	68 ec 67 10 f0       	push   $0xf01067ec
f0100980:	e8 53 4e 00 00       	call   f01057d8 <strchr>
f0100985:	83 c4 10             	add    $0x10,%esp
f0100988:	85 c0                	test   %eax,%eax
f010098a:	74 0a                	je     f0100996 <monitor+0x5a>
			*buf++ = 0;
f010098c:	c6 03 00             	movb   $0x0,(%ebx)
f010098f:	89 f7                	mov    %esi,%edi
f0100991:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100994:	eb 6b                	jmp    f0100a01 <monitor+0xc5>
		if (*buf == 0)
f0100996:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100999:	74 73                	je     f0100a0e <monitor+0xd2>
		if (argc == MAXARGS-1) {
f010099b:	83 fe 0f             	cmp    $0xf,%esi
f010099e:	74 09                	je     f01009a9 <monitor+0x6d>
		argv[argc++] = buf;
f01009a0:	8d 7e 01             	lea    0x1(%esi),%edi
f01009a3:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009a7:	eb 39                	jmp    f01009e2 <monitor+0xa6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009a9:	83 ec 08             	sub    $0x8,%esp
f01009ac:	6a 10                	push   $0x10
f01009ae:	68 f1 67 10 f0       	push   $0xf01067f1
f01009b3:	e8 fa 2f 00 00       	call   f01039b2 <cprintf>
			return 0;
f01009b8:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009bb:	83 ec 0c             	sub    $0xc,%esp
f01009be:	68 e8 67 10 f0       	push   $0xf01067e8
f01009c3:	e8 e2 4b 00 00       	call   f01055aa <readline>
f01009c8:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009ca:	83 c4 10             	add    $0x10,%esp
f01009cd:	85 c0                	test   %eax,%eax
f01009cf:	74 ea                	je     f01009bb <monitor+0x7f>
	argv[argc] = 0;
f01009d1:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009d8:	be 00 00 00 00       	mov    $0x0,%esi
f01009dd:	eb 24                	jmp    f0100a03 <monitor+0xc7>
			buf++;
f01009df:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f01009e2:	0f b6 03             	movzbl (%ebx),%eax
f01009e5:	84 c0                	test   %al,%al
f01009e7:	74 18                	je     f0100a01 <monitor+0xc5>
f01009e9:	83 ec 08             	sub    $0x8,%esp
f01009ec:	0f be c0             	movsbl %al,%eax
f01009ef:	50                   	push   %eax
f01009f0:	68 ec 67 10 f0       	push   $0xf01067ec
f01009f5:	e8 de 4d 00 00       	call   f01057d8 <strchr>
f01009fa:	83 c4 10             	add    $0x10,%esp
f01009fd:	85 c0                	test   %eax,%eax
f01009ff:	74 de                	je     f01009df <monitor+0xa3>
			*buf++ = 0;
f0100a01:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a03:	0f b6 03             	movzbl (%ebx),%eax
f0100a06:	84 c0                	test   %al,%al
f0100a08:	0f 85 66 ff ff ff    	jne    f0100974 <monitor+0x38>
	argv[argc] = 0;
f0100a0e:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a15:	00 
	if (argc == 0)
f0100a16:	85 f6                	test   %esi,%esi
f0100a18:	74 a1                	je     f01009bb <monitor+0x7f>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a1a:	83 ec 08             	sub    $0x8,%esp
f0100a1d:	68 7e 67 10 f0       	push   $0xf010677e
f0100a22:	ff 75 a8             	push   -0x58(%ebp)
f0100a25:	e8 4e 4d 00 00       	call   f0105778 <strcmp>
f0100a2a:	83 c4 10             	add    $0x10,%esp
f0100a2d:	85 c0                	test   %eax,%eax
f0100a2f:	74 34                	je     f0100a65 <monitor+0x129>
f0100a31:	83 ec 08             	sub    $0x8,%esp
f0100a34:	68 8c 67 10 f0       	push   $0xf010678c
f0100a39:	ff 75 a8             	push   -0x58(%ebp)
f0100a3c:	e8 37 4d 00 00       	call   f0105778 <strcmp>
f0100a41:	83 c4 10             	add    $0x10,%esp
f0100a44:	85 c0                	test   %eax,%eax
f0100a46:	74 18                	je     f0100a60 <monitor+0x124>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a48:	83 ec 08             	sub    $0x8,%esp
f0100a4b:	ff 75 a8             	push   -0x58(%ebp)
f0100a4e:	68 0e 68 10 f0       	push   $0xf010680e
f0100a53:	e8 5a 2f 00 00       	call   f01039b2 <cprintf>
	return 0;
f0100a58:	83 c4 10             	add    $0x10,%esp
f0100a5b:	e9 5b ff ff ff       	jmp    f01009bb <monitor+0x7f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a60:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a65:	83 ec 04             	sub    $0x4,%esp
f0100a68:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a6b:	ff 75 08             	push   0x8(%ebp)
f0100a6e:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a71:	52                   	push   %edx
f0100a72:	56                   	push   %esi
f0100a73:	ff 14 85 84 69 10 f0 	call   *-0xfef967c(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a7a:	83 c4 10             	add    $0x10,%esp
f0100a7d:	85 c0                	test   %eax,%eax
f0100a7f:	0f 89 36 ff ff ff    	jns    f01009bb <monitor+0x7f>
				break;
	}
}
f0100a85:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a88:	5b                   	pop    %ebx
f0100a89:	5e                   	pop    %esi
f0100a8a:	5f                   	pop    %edi
f0100a8b:	5d                   	pop    %ebp
f0100a8c:	c3                   	ret    

f0100a8d <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a8d:	55                   	push   %ebp
f0100a8e:	89 e5                	mov    %esp,%ebp
f0100a90:	56                   	push   %esi
f0100a91:	53                   	push   %ebx
f0100a92:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a94:	83 ec 0c             	sub    $0xc,%esp
f0100a97:	50                   	push   %eax
f0100a98:	e8 85 2d 00 00       	call   f0103822 <mc146818_read>
f0100a9d:	89 c6                	mov    %eax,%esi
f0100a9f:	83 c3 01             	add    $0x1,%ebx
f0100aa2:	89 1c 24             	mov    %ebx,(%esp)
f0100aa5:	e8 78 2d 00 00       	call   f0103822 <mc146818_read>
f0100aaa:	c1 e0 08             	shl    $0x8,%eax
f0100aad:	09 f0                	or     %esi,%eax
}
f0100aaf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ab2:	5b                   	pop    %ebx
f0100ab3:	5e                   	pop    %esi
f0100ab4:	5d                   	pop    %ebp
f0100ab5:	c3                   	ret    

f0100ab6 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ab6:	83 3d 64 82 21 f0 00 	cmpl   $0x0,0xf0218264
f0100abd:	74 21                	je     f0100ae0 <boot_alloc+0x2a>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	
	//
	// LAB 2: Your code here.
	result=nextfree;
f0100abf:	8b 15 64 82 21 f0    	mov    0xf0218264,%edx
	nextfree=ROUNDUP(nextfree+n, PGSIZE);
f0100ac5:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100acc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ad1:	a3 64 82 21 f0       	mov    %eax,0xf0218264
	if( (uint32_t)nextfree < KERNBASE ){
f0100ad6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100adb:	76 16                	jbe    f0100af3 <boot_alloc+0x3d>
	//这也与博客的写法 if( (uint32_t)nextfree - KERNBASE > (npages*PGSIZE))所不同。
	
	return result;

	//return NULL;
}
f0100add:	89 d0                	mov    %edx,%eax
f0100adf:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);//ROUNDUP(a,n)函数在inc/types.h中定义：目的是用来进行地址向上对齐，即增大数a至n的倍数。
f0100ae0:	ba c7 a3 25 f0       	mov    $0xf025a3c7,%edx
f0100ae5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100aeb:	89 15 64 82 21 f0    	mov    %edx,0xf0218264
f0100af1:	eb cc                	jmp    f0100abf <boot_alloc+0x9>
{
f0100af3:	55                   	push   %ebp
f0100af4:	89 e5                	mov    %esp,%ebp
f0100af6:	83 ec 0c             	sub    $0xc,%esp
		panic("boot_alloc: out of memory\n");
f0100af9:	68 94 69 10 f0       	push   $0xf0106994
f0100afe:	6a 72                	push   $0x72
f0100b00:	68 af 69 10 f0       	push   $0xf01069af
f0100b05:	e8 36 f5 ff ff       	call   f0100040 <_panic>

f0100b0a <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b0a:	89 d1                	mov    %edx,%ecx
f0100b0c:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b0f:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b12:	a8 01                	test   $0x1,%al
f0100b14:	74 51                	je     f0100b67 <check_va2pa+0x5d>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b16:	89 c1                	mov    %eax,%ecx
f0100b18:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100b1e:	c1 e8 0c             	shr    $0xc,%eax
f0100b21:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f0100b27:	73 23                	jae    f0100b4c <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P))
f0100b29:	c1 ea 0c             	shr    $0xc,%edx
f0100b2c:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b32:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b39:	89 d0                	mov    %edx,%eax
f0100b3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b40:	f6 c2 01             	test   $0x1,%dl
f0100b43:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b48:	0f 44 c2             	cmove  %edx,%eax
f0100b4b:	c3                   	ret    
{
f0100b4c:	55                   	push   %ebp
f0100b4d:	89 e5                	mov    %esp,%ebp
f0100b4f:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b52:	51                   	push   %ecx
f0100b53:	68 64 64 10 f0       	push   $0xf0106464
f0100b58:	68 b7 03 00 00       	push   $0x3b7
f0100b5d:	68 af 69 10 f0       	push   $0xf01069af
f0100b62:	e8 d9 f4 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100b67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b6c:	c3                   	ret    

f0100b6d <check_page_free_list>:
{
f0100b6d:	55                   	push   %ebp
f0100b6e:	89 e5                	mov    %esp,%ebp
f0100b70:	57                   	push   %edi
f0100b71:	56                   	push   %esi
f0100b72:	53                   	push   %ebx
f0100b73:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100b76:	84 c0                	test   %al,%al
f0100b78:	0f 85 77 02 00 00    	jne    f0100df5 <check_page_free_list+0x288>
	if (!page_free_list)
f0100b7e:	83 3d 6c 82 21 f0 00 	cmpl   $0x0,0xf021826c
f0100b85:	74 0a                	je     f0100b91 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100b87:	be 00 04 00 00       	mov    $0x400,%esi
f0100b8c:	e9 bf 02 00 00       	jmp    f0100e50 <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100b91:	83 ec 04             	sub    $0x4,%esp
f0100b94:	68 e8 6c 10 f0       	push   $0xf0106ce8
f0100b99:	68 ea 02 00 00       	push   $0x2ea
f0100b9e:	68 af 69 10 f0       	push   $0xf01069af
f0100ba3:	e8 98 f4 ff ff       	call   f0100040 <_panic>
f0100ba8:	50                   	push   %eax
f0100ba9:	68 64 64 10 f0       	push   $0xf0106464
f0100bae:	6a 5a                	push   $0x5a
f0100bb0:	68 bb 69 10 f0       	push   $0xf01069bb
f0100bb5:	e8 86 f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bba:	8b 1b                	mov    (%ebx),%ebx
f0100bbc:	85 db                	test   %ebx,%ebx
f0100bbe:	74 41                	je     f0100c01 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0100bc0:	89 d8                	mov    %ebx,%eax
f0100bc2:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f0100bc8:	c1 f8 03             	sar    $0x3,%eax
f0100bcb:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bce:	89 c2                	mov    %eax,%edx
f0100bd0:	c1 ea 16             	shr    $0x16,%edx
f0100bd3:	39 f2                	cmp    %esi,%edx
f0100bd5:	73 e3                	jae    f0100bba <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100bd7:	89 c2                	mov    %eax,%edx
f0100bd9:	c1 ea 0c             	shr    $0xc,%edx
f0100bdc:	3b 15 60 82 21 f0    	cmp    0xf0218260,%edx
f0100be2:	73 c4                	jae    f0100ba8 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100be4:	83 ec 04             	sub    $0x4,%esp
f0100be7:	68 80 00 00 00       	push   $0x80
f0100bec:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100bf1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bf6:	50                   	push   %eax
f0100bf7:	e8 1b 4c 00 00       	call   f0105817 <memset>
f0100bfc:	83 c4 10             	add    $0x10,%esp
f0100bff:	eb b9                	jmp    f0100bba <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100c01:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c06:	e8 ab fe ff ff       	call   f0100ab6 <boot_alloc>
f0100c0b:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c0e:	8b 15 6c 82 21 f0    	mov    0xf021826c,%edx
		assert(pp >= pages);
f0100c14:	8b 0d 58 82 21 f0    	mov    0xf0218258,%ecx
		assert(pp < pages + npages);
f0100c1a:	a1 60 82 21 f0       	mov    0xf0218260,%eax
f0100c1f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c22:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c25:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c2a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c2d:	e9 f9 00 00 00       	jmp    f0100d2b <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100c32:	68 c9 69 10 f0       	push   $0xf01069c9
f0100c37:	68 d5 69 10 f0       	push   $0xf01069d5
f0100c3c:	68 04 03 00 00       	push   $0x304
f0100c41:	68 af 69 10 f0       	push   $0xf01069af
f0100c46:	e8 f5 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c4b:	68 ea 69 10 f0       	push   $0xf01069ea
f0100c50:	68 d5 69 10 f0       	push   $0xf01069d5
f0100c55:	68 05 03 00 00       	push   $0x305
f0100c5a:	68 af 69 10 f0       	push   $0xf01069af
f0100c5f:	e8 dc f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c64:	68 0c 6d 10 f0       	push   $0xf0106d0c
f0100c69:	68 d5 69 10 f0       	push   $0xf01069d5
f0100c6e:	68 06 03 00 00       	push   $0x306
f0100c73:	68 af 69 10 f0       	push   $0xf01069af
f0100c78:	e8 c3 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100c7d:	68 fe 69 10 f0       	push   $0xf01069fe
f0100c82:	68 d5 69 10 f0       	push   $0xf01069d5
f0100c87:	68 09 03 00 00       	push   $0x309
f0100c8c:	68 af 69 10 f0       	push   $0xf01069af
f0100c91:	e8 aa f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c96:	68 0f 6a 10 f0       	push   $0xf0106a0f
f0100c9b:	68 d5 69 10 f0       	push   $0xf01069d5
f0100ca0:	68 0a 03 00 00       	push   $0x30a
f0100ca5:	68 af 69 10 f0       	push   $0xf01069af
f0100caa:	e8 91 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100caf:	68 40 6d 10 f0       	push   $0xf0106d40
f0100cb4:	68 d5 69 10 f0       	push   $0xf01069d5
f0100cb9:	68 0b 03 00 00       	push   $0x30b
f0100cbe:	68 af 69 10 f0       	push   $0xf01069af
f0100cc3:	e8 78 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cc8:	68 28 6a 10 f0       	push   $0xf0106a28
f0100ccd:	68 d5 69 10 f0       	push   $0xf01069d5
f0100cd2:	68 0c 03 00 00       	push   $0x30c
f0100cd7:	68 af 69 10 f0       	push   $0xf01069af
f0100cdc:	e8 5f f3 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100ce1:	89 c3                	mov    %eax,%ebx
f0100ce3:	c1 eb 0c             	shr    $0xc,%ebx
f0100ce6:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100ce9:	76 0f                	jbe    f0100cfa <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100ceb:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cf0:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100cf3:	77 17                	ja     f0100d0c <check_page_free_list+0x19f>
			++nfree_extmem;
f0100cf5:	83 c7 01             	add    $0x1,%edi
f0100cf8:	eb 2f                	jmp    f0100d29 <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cfa:	50                   	push   %eax
f0100cfb:	68 64 64 10 f0       	push   $0xf0106464
f0100d00:	6a 5a                	push   $0x5a
f0100d02:	68 bb 69 10 f0       	push   $0xf01069bb
f0100d07:	e8 34 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d0c:	68 64 6d 10 f0       	push   $0xf0106d64
f0100d11:	68 d5 69 10 f0       	push   $0xf01069d5
f0100d16:	68 0d 03 00 00       	push   $0x30d
f0100d1b:	68 af 69 10 f0       	push   $0xf01069af
f0100d20:	e8 1b f3 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100d25:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d29:	8b 12                	mov    (%edx),%edx
f0100d2b:	85 d2                	test   %edx,%edx
f0100d2d:	74 74                	je     f0100da3 <check_page_free_list+0x236>
		assert(pp >= pages);
f0100d2f:	39 d1                	cmp    %edx,%ecx
f0100d31:	0f 87 fb fe ff ff    	ja     f0100c32 <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100d37:	39 d6                	cmp    %edx,%esi
f0100d39:	0f 86 0c ff ff ff    	jbe    f0100c4b <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d3f:	89 d0                	mov    %edx,%eax
f0100d41:	29 c8                	sub    %ecx,%eax
f0100d43:	a8 07                	test   $0x7,%al
f0100d45:	0f 85 19 ff ff ff    	jne    f0100c64 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0100d4b:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d4e:	c1 e0 0c             	shl    $0xc,%eax
f0100d51:	0f 84 26 ff ff ff    	je     f0100c7d <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d57:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d5c:	0f 84 34 ff ff ff    	je     f0100c96 <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d62:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d67:	0f 84 42 ff ff ff    	je     f0100caf <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d6d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d72:	0f 84 50 ff ff ff    	je     f0100cc8 <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d78:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d7d:	0f 87 5e ff ff ff    	ja     f0100ce1 <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d83:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d88:	75 9b                	jne    f0100d25 <check_page_free_list+0x1b8>
f0100d8a:	68 42 6a 10 f0       	push   $0xf0106a42
f0100d8f:	68 d5 69 10 f0       	push   $0xf01069d5
f0100d94:	68 0f 03 00 00       	push   $0x30f
f0100d99:	68 af 69 10 f0       	push   $0xf01069af
f0100d9e:	e8 9d f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f0100da3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100da6:	85 db                	test   %ebx,%ebx
f0100da8:	7e 19                	jle    f0100dc3 <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100daa:	85 ff                	test   %edi,%edi
f0100dac:	7e 2e                	jle    f0100ddc <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100dae:	83 ec 0c             	sub    $0xc,%esp
f0100db1:	68 ac 6d 10 f0       	push   $0xf0106dac
f0100db6:	e8 f7 2b 00 00       	call   f01039b2 <cprintf>
}
f0100dbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dbe:	5b                   	pop    %ebx
f0100dbf:	5e                   	pop    %esi
f0100dc0:	5f                   	pop    %edi
f0100dc1:	5d                   	pop    %ebp
f0100dc2:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100dc3:	68 5f 6a 10 f0       	push   $0xf0106a5f
f0100dc8:	68 d5 69 10 f0       	push   $0xf01069d5
f0100dcd:	68 17 03 00 00       	push   $0x317
f0100dd2:	68 af 69 10 f0       	push   $0xf01069af
f0100dd7:	e8 64 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100ddc:	68 71 6a 10 f0       	push   $0xf0106a71
f0100de1:	68 d5 69 10 f0       	push   $0xf01069d5
f0100de6:	68 18 03 00 00       	push   $0x318
f0100deb:	68 af 69 10 f0       	push   $0xf01069af
f0100df0:	e8 4b f2 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100df5:	a1 6c 82 21 f0       	mov    0xf021826c,%eax
f0100dfa:	85 c0                	test   %eax,%eax
f0100dfc:	0f 84 8f fd ff ff    	je     f0100b91 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e02:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e05:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e08:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e0b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100e0e:	89 c2                	mov    %eax,%edx
f0100e10:	2b 15 58 82 21 f0    	sub    0xf0218258,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e16:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100e1c:	0f 95 c2             	setne  %dl
f0100e1f:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100e22:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100e26:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e28:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e2c:	8b 00                	mov    (%eax),%eax
f0100e2e:	85 c0                	test   %eax,%eax
f0100e30:	75 dc                	jne    f0100e0e <check_page_free_list+0x2a1>
		*tp[1] = 0;
f0100e32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e35:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e41:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e43:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e46:	a3 6c 82 21 f0       	mov    %eax,0xf021826c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100e4b:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e50:	8b 1d 6c 82 21 f0    	mov    0xf021826c,%ebx
f0100e56:	e9 61 fd ff ff       	jmp    f0100bbc <check_page_free_list+0x4f>

f0100e5b <page_init>:
{
f0100e5b:	55                   	push   %ebp
f0100e5c:	89 e5                	mov    %esp,%ebp
f0100e5e:	57                   	push   %edi
f0100e5f:	56                   	push   %esi
f0100e60:	53                   	push   %ebx
f0100e61:	83 ec 0c             	sub    $0xc,%esp
	page_free_list = NULL;//其实是多余的，因为它本就是空指针，这只是为了方便阅读一点。
f0100e64:	c7 05 6c 82 21 f0 00 	movl   $0x0,0xf021826c
f0100e6b:	00 00 00 
	uint32_t EXTPHYSMEM_alloc = (uint32_t)boot_alloc(0) - KERNBASE;//EXTPHYSMEM_alloc：在EXTPHYSMEM区域已经被占用的bytes数
f0100e6e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e73:	e8 3e fc ff ff       	call   f0100ab6 <boot_alloc>
		if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)/* 3,4条*/ ||  (i>=MPENTRY_PADDR/PGSIZE && i<(MPENTRY_PADDR+size)/PGSIZE) /*lab4*/){//不标记为free的页
f0100e78:	8d 98 00 00 10 10    	lea    0x10100000(%eax),%ebx
f0100e7e:	c1 eb 0c             	shr    $0xc,%ebx
    	size = ROUNDUP(size, PGSIZE);
f0100e81:	b9 82 5a 10 f0       	mov    $0xf0105a82,%ecx
f0100e86:	81 e9 09 4a 10 f0    	sub    $0xf0104a09,%ecx
		if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)/* 3,4条*/ ||  (i>=MPENTRY_PADDR/PGSIZE && i<(MPENTRY_PADDR+size)/PGSIZE) /*lab4*/){//不标记为free的页
f0100e8c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100e92:	81 c1 00 70 00 00    	add    $0x7000,%ecx
f0100e98:	c1 e9 0c             	shr    $0xc,%ecx
	for (size_t i = 0; i < npages; i++) {
f0100e9b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ea0:	be 00 00 00 00       	mov    $0x0,%esi
f0100ea5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eaa:	eb 10                	jmp    f0100ebc <page_init+0x61>
			pages[i].pp_ref = 1;
f0100eac:	8b 3d 58 82 21 f0    	mov    0xf0218258,%edi
f0100eb2:	66 c7 44 c7 04 01 00 	movw   $0x1,0x4(%edi,%eax,8)
	for (size_t i = 0; i < npages; i++) {
f0100eb9:	83 c0 01             	add    $0x1,%eax
f0100ebc:	39 05 60 82 21 f0    	cmp    %eax,0xf0218260
f0100ec2:	76 3e                	jbe    f0100f02 <page_init+0xa7>
		if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)/* 3,4条*/ ||  (i>=MPENTRY_PADDR/PGSIZE && i<(MPENTRY_PADDR+size)/PGSIZE) /*lab4*/){//不标记为free的页
f0100ec4:	85 c0                	test   %eax,%eax
f0100ec6:	74 e4                	je     f0100eac <page_init+0x51>
f0100ec8:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0100ecd:	76 04                	jbe    f0100ed3 <page_init+0x78>
f0100ecf:	39 c3                	cmp    %eax,%ebx
f0100ed1:	77 d9                	ja     f0100eac <page_init+0x51>
f0100ed3:	83 f8 06             	cmp    $0x6,%eax
f0100ed6:	76 04                	jbe    f0100edc <page_init+0x81>
f0100ed8:	39 c1                	cmp    %eax,%ecx
f0100eda:	77 d0                	ja     f0100eac <page_init+0x51>
f0100edc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0100ee3:	89 d7                	mov    %edx,%edi
f0100ee5:	03 3d 58 82 21 f0    	add    0xf0218258,%edi
f0100eeb:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
			pages[i].pp_link = page_free_list;
f0100ef1:	89 37                	mov    %esi,(%edi)
			page_free_list = &pages[i];	
f0100ef3:	89 d6                	mov    %edx,%esi
f0100ef5:	03 35 58 82 21 f0    	add    0xf0218258,%esi
f0100efb:	ba 01 00 00 00       	mov    $0x1,%edx
f0100f00:	eb b7                	jmp    f0100eb9 <page_init+0x5e>
f0100f02:	84 d2                	test   %dl,%dl
f0100f04:	74 06                	je     f0100f0c <page_init+0xb1>
f0100f06:	89 35 6c 82 21 f0    	mov    %esi,0xf021826c
}
f0100f0c:	83 c4 0c             	add    $0xc,%esp
f0100f0f:	5b                   	pop    %ebx
f0100f10:	5e                   	pop    %esi
f0100f11:	5f                   	pop    %edi
f0100f12:	5d                   	pop    %ebp
f0100f13:	c3                   	ret    

f0100f14 <page_alloc>:
{
f0100f14:	55                   	push   %ebp
f0100f15:	89 e5                	mov    %esp,%ebp
f0100f17:	53                   	push   %ebx
f0100f18:	83 ec 04             	sub    $0x4,%esp
	if(!page_free_list) return res;
f0100f1b:	8b 1d 6c 82 21 f0    	mov    0xf021826c,%ebx
f0100f21:	85 db                	test   %ebx,%ebx
f0100f23:	74 13                	je     f0100f38 <page_alloc+0x24>
	page_free_list=page_free_list -> pp_link;
f0100f25:	8b 03                	mov    (%ebx),%eax
f0100f27:	a3 6c 82 21 f0       	mov    %eax,0xf021826c
	res ->pp_link=NULL;
f0100f2c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO){//ALLOC_ZERO在pmap.h中定义 ALLOC_ZERO = 1<<0,
f0100f32:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f36:	75 07                	jne    f0100f3f <page_alloc+0x2b>
}
f0100f38:	89 d8                	mov    %ebx,%eax
f0100f3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f3d:	c9                   	leave  
f0100f3e:	c3                   	ret    
f0100f3f:	89 d8                	mov    %ebx,%eax
f0100f41:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f0100f47:	c1 f8 03             	sar    $0x3,%eax
f0100f4a:	89 c2                	mov    %eax,%edx
f0100f4c:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100f4f:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100f54:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f0100f5a:	73 1b                	jae    f0100f77 <page_alloc+0x63>
		memset(page2kva(res) , '\0' ,  PGSIZE );
f0100f5c:	83 ec 04             	sub    $0x4,%esp
f0100f5f:	68 00 10 00 00       	push   $0x1000
f0100f64:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100f66:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100f6c:	52                   	push   %edx
f0100f6d:	e8 a5 48 00 00       	call   f0105817 <memset>
f0100f72:	83 c4 10             	add    $0x10,%esp
f0100f75:	eb c1                	jmp    f0100f38 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f77:	52                   	push   %edx
f0100f78:	68 64 64 10 f0       	push   $0xf0106464
f0100f7d:	6a 5a                	push   $0x5a
f0100f7f:	68 bb 69 10 f0       	push   $0xf01069bb
f0100f84:	e8 b7 f0 ff ff       	call   f0100040 <_panic>

f0100f89 <page_free>:
{
f0100f89:	55                   	push   %ebp
f0100f8a:	89 e5                	mov    %esp,%ebp
f0100f8c:	83 ec 08             	sub    $0x8,%esp
f0100f8f:	8b 45 08             	mov    0x8(%ebp),%eax
      	assert(pp->pp_ref == 0);
f0100f92:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f97:	75 14                	jne    f0100fad <page_free+0x24>
      	assert(pp->pp_link == NULL);
f0100f99:	83 38 00             	cmpl   $0x0,(%eax)
f0100f9c:	75 28                	jne    f0100fc6 <page_free+0x3d>
	pp->pp_link=page_free_list;
f0100f9e:	8b 15 6c 82 21 f0    	mov    0xf021826c,%edx
f0100fa4:	89 10                	mov    %edx,(%eax)
	page_free_list=pp;
f0100fa6:	a3 6c 82 21 f0       	mov    %eax,0xf021826c
}
f0100fab:	c9                   	leave  
f0100fac:	c3                   	ret    
      	assert(pp->pp_ref == 0);
f0100fad:	68 82 6a 10 f0       	push   $0xf0106a82
f0100fb2:	68 d5 69 10 f0       	push   $0xf01069d5
f0100fb7:	68 9e 01 00 00       	push   $0x19e
f0100fbc:	68 af 69 10 f0       	push   $0xf01069af
f0100fc1:	e8 7a f0 ff ff       	call   f0100040 <_panic>
      	assert(pp->pp_link == NULL);
f0100fc6:	68 92 6a 10 f0       	push   $0xf0106a92
f0100fcb:	68 d5 69 10 f0       	push   $0xf01069d5
f0100fd0:	68 9f 01 00 00       	push   $0x19f
f0100fd5:	68 af 69 10 f0       	push   $0xf01069af
f0100fda:	e8 61 f0 ff ff       	call   f0100040 <_panic>

f0100fdf <page_decref>:
{
f0100fdf:	55                   	push   %ebp
f0100fe0:	89 e5                	mov    %esp,%ebp
f0100fe2:	83 ec 08             	sub    $0x8,%esp
f0100fe5:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fe8:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fec:	83 e8 01             	sub    $0x1,%eax
f0100fef:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100ff3:	66 85 c0             	test   %ax,%ax
f0100ff6:	74 02                	je     f0100ffa <page_decref+0x1b>
}
f0100ff8:	c9                   	leave  
f0100ff9:	c3                   	ret    
		page_free(pp);
f0100ffa:	83 ec 0c             	sub    $0xc,%esp
f0100ffd:	52                   	push   %edx
f0100ffe:	e8 86 ff ff ff       	call   f0100f89 <page_free>
f0101003:	83 c4 10             	add    $0x10,%esp
}
f0101006:	eb f0                	jmp    f0100ff8 <page_decref+0x19>

f0101008 <pgdir_walk>:
{
f0101008:	55                   	push   %ebp
f0101009:	89 e5                	mov    %esp,%ebp
f010100b:	56                   	push   %esi
f010100c:	53                   	push   %ebx
f010100d:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t* dir_entry=pgdir+PDX(va); //PDX(va)返回page directory index,dir_entry是指向页目录中的DIR ENTRY(见图)的指针。
f0101010:	89 f3                	mov    %esi,%ebx
f0101012:	c1 eb 16             	shr    $0x16,%ebx
f0101015:	c1 e3 02             	shl    $0x2,%ebx
f0101018:	03 5d 08             	add    0x8(%ebp),%ebx
	if( !(*dir_entry & PTE_P) ){//如果这个页表不存在
f010101b:	f6 03 01             	testb  $0x1,(%ebx)
f010101e:	75 67                	jne    f0101087 <pgdir_walk+0x7f>
		if(create==false) return NULL;
f0101020:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101024:	0f 84 b0 00 00 00    	je     f01010da <pgdir_walk+0xd2>
			struct PageInfo * new_pp =page_alloc(1);//别忘了这个它返回的是struct PageInfo *
f010102a:	83 ec 0c             	sub    $0xc,%esp
f010102d:	6a 01                	push   $0x1
f010102f:	e8 e0 fe ff ff       	call   f0100f14 <page_alloc>
			if(new_pp==NULL){
f0101034:	83 c4 10             	add    $0x10,%esp
f0101037:	85 c0                	test   %eax,%eax
f0101039:	74 71                	je     f01010ac <pgdir_walk+0xa4>
			new_pp->pp_ref++;
f010103b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101040:	89 c2                	mov    %eax,%edx
f0101042:	2b 15 58 82 21 f0    	sub    0xf0218258,%edx
f0101048:	c1 fa 03             	sar    $0x3,%edx
f010104b:	c1 e2 0c             	shl    $0xc,%edx
			*dir_entry=(page2pa(new_pp) | PTE_P | PTE_W | PTE_U);//设置dir_entry的标志位。注释中说可以设置宽松，所以这里全部设置为最宽松：可读写，应用程序级别即可访问。 dirty位 和access位不做设置。
f010104e:	83 ca 07             	or     $0x7,%edx
f0101051:	89 13                	mov    %edx,(%ebx)
f0101053:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f0101059:	c1 f8 03             	sar    $0x3,%eax
f010105c:	89 c2                	mov    %eax,%edx
f010105e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101061:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101066:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f010106c:	73 45                	jae    f01010b3 <pgdir_walk+0xab>
			memset(page2kva(new_pp) , '\0' ,  PGSIZE);//初始化new_page的物理内存，一定要用虚拟地址!!!!!			
f010106e:	83 ec 04             	sub    $0x4,%esp
f0101071:	68 00 10 00 00       	push   $0x1000
f0101076:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101078:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010107e:	52                   	push   %edx
f010107f:	e8 93 47 00 00       	call   f0105817 <memset>
f0101084:	83 c4 10             	add    $0x10,%esp
	pte_t * page_base = KADDR(PTE_ADDR(*dir_entry));//注意这块的类型定义，这涉及地址运算。 很重要，之前的bug就是因为这里!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
f0101087:	8b 03                	mov    (%ebx),%eax
f0101089:	89 c2                	mov    %eax,%edx
f010108b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101091:	c1 e8 0c             	shr    $0xc,%eax
f0101094:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f010109a:	73 29                	jae    f01010c5 <pgdir_walk+0xbd>
	return  &page_base[PTX(va)];	
f010109c:	c1 ee 0a             	shr    $0xa,%esi
f010109f:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01010a5:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
}
f01010ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010af:	5b                   	pop    %ebx
f01010b0:	5e                   	pop    %esi
f01010b1:	5d                   	pop    %ebp
f01010b2:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010b3:	52                   	push   %edx
f01010b4:	68 64 64 10 f0       	push   $0xf0106464
f01010b9:	6a 5a                	push   $0x5a
f01010bb:	68 bb 69 10 f0       	push   $0xf01069bb
f01010c0:	e8 7b ef ff ff       	call   f0100040 <_panic>
f01010c5:	52                   	push   %edx
f01010c6:	68 64 64 10 f0       	push   $0xf0106464
f01010cb:	68 da 01 00 00       	push   $0x1da
f01010d0:	68 af 69 10 f0       	push   $0xf01069af
f01010d5:	e8 66 ef ff ff       	call   f0100040 <_panic>
		if(create==false) return NULL;
f01010da:	b8 00 00 00 00       	mov    $0x0,%eax
f01010df:	eb cb                	jmp    f01010ac <pgdir_walk+0xa4>

f01010e1 <boot_map_region>:
{
f01010e1:	55                   	push   %ebp
f01010e2:	89 e5                	mov    %esp,%ebp
f01010e4:	57                   	push   %edi
f01010e5:	56                   	push   %esi
f01010e6:	53                   	push   %ebx
f01010e7:	83 ec 1c             	sub    $0x1c,%esp
f01010ea:	89 c7                	mov    %eax,%edi
f01010ec:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01010ef:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(int i=0; i<size;i+=PGSIZE){
f01010f2:	be 00 00 00 00       	mov    $0x0,%esi
f01010f7:	89 f3                	mov    %esi,%ebx
f01010f9:	03 5d 08             	add    0x8(%ebp),%ebx
f01010fc:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f01010ff:	76 3f                	jbe    f0101140 <boot_map_region+0x5f>
		pt_entry=pgdir_walk(pgdir, (void *) va ,1);
f0101101:	83 ec 04             	sub    $0x4,%esp
f0101104:	6a 01                	push   $0x1
f0101106:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101109:	01 f0                	add    %esi,%eax
f010110b:	50                   	push   %eax
f010110c:	57                   	push   %edi
f010110d:	e8 f6 fe ff ff       	call   f0101008 <pgdir_walk>
		if (pt_entry == NULL) {
f0101112:	83 c4 10             	add    $0x10,%esp
f0101115:	85 c0                	test   %eax,%eax
f0101117:	74 10                	je     f0101129 <boot_map_region+0x48>
		* pt_entry=(pa |perm | PTE_P);//按照注释对pg_entry置标志位。
f0101119:	0b 5d 0c             	or     0xc(%ebp),%ebx
f010111c:	83 cb 01             	or     $0x1,%ebx
f010111f:	89 18                	mov    %ebx,(%eax)
	for(int i=0; i<size;i+=PGSIZE){
f0101121:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101127:	eb ce                	jmp    f01010f7 <boot_map_region+0x16>
            		panic("boot_map_region(): out of memory\n");
f0101129:	83 ec 04             	sub    $0x4,%esp
f010112c:	68 d0 6d 10 f0       	push   $0xf0106dd0
f0101131:	68 f4 01 00 00       	push   $0x1f4
f0101136:	68 af 69 10 f0       	push   $0xf01069af
f010113b:	e8 00 ef ff ff       	call   f0100040 <_panic>
}
f0101140:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101143:	5b                   	pop    %ebx
f0101144:	5e                   	pop    %esi
f0101145:	5f                   	pop    %edi
f0101146:	5d                   	pop    %ebp
f0101147:	c3                   	ret    

f0101148 <page_lookup>:
{
f0101148:	55                   	push   %ebp
f0101149:	89 e5                	mov    %esp,%ebp
f010114b:	53                   	push   %ebx
f010114c:	83 ec 08             	sub    $0x8,%esp
f010114f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t * pt_entry=pgdir_walk(pgdir,va,0);
f0101152:	6a 00                	push   $0x0
f0101154:	ff 75 0c             	push   0xc(%ebp)
f0101157:	ff 75 08             	push   0x8(%ebp)
f010115a:	e8 a9 fe ff ff       	call   f0101008 <pgdir_walk>
	if(pt_entry==NULL)  return NULL;
f010115f:	83 c4 10             	add    $0x10,%esp
f0101162:	85 c0                	test   %eax,%eax
f0101164:	74 21                	je     f0101187 <page_lookup+0x3f>
	if(!(*pt_entry & PTE_P))  return NULL;
f0101166:	f6 00 01             	testb  $0x1,(%eax)
f0101169:	74 35                	je     f01011a0 <page_lookup+0x58>
	if(pte_store) *pte_store=pt_entry;
f010116b:	85 db                	test   %ebx,%ebx
f010116d:	74 02                	je     f0101171 <page_lookup+0x29>
f010116f:	89 03                	mov    %eax,(%ebx)
f0101171:	8b 00                	mov    (%eax),%eax
f0101173:	c1 e8 0c             	shr    $0xc,%eax

//返回对应物理地址的 struct PageInfo* 部分
static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f0101176:	39 05 60 82 21 f0    	cmp    %eax,0xf0218260
f010117c:	76 0e                	jbe    f010118c <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010117e:	8b 15 58 82 21 f0    	mov    0xf0218258,%edx
f0101184:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010118a:	c9                   	leave  
f010118b:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010118c:	83 ec 04             	sub    $0x4,%esp
f010118f:	68 f4 6d 10 f0       	push   $0xf0106df4
f0101194:	6a 52                	push   $0x52
f0101196:	68 bb 69 10 f0       	push   $0xf01069bb
f010119b:	e8 a0 ee ff ff       	call   f0100040 <_panic>
	if(!(*pt_entry & PTE_P))  return NULL;
f01011a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01011a5:	eb e0                	jmp    f0101187 <page_lookup+0x3f>

f01011a7 <tlb_invalidate>:
{
f01011a7:	55                   	push   %ebp
f01011a8:	89 e5                	mov    %esp,%ebp
f01011aa:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01011ad:	e8 5a 4c 00 00       	call   f0105e0c <cpunum>
f01011b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01011b5:	83 b8 28 90 25 f0 00 	cmpl   $0x0,-0xfda6fd8(%eax)
f01011bc:	74 16                	je     f01011d4 <tlb_invalidate+0x2d>
f01011be:	e8 49 4c 00 00       	call   f0105e0c <cpunum>
f01011c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01011c6:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f01011cc:	8b 55 08             	mov    0x8(%ebp),%edx
f01011cf:	39 50 60             	cmp    %edx,0x60(%eax)
f01011d2:	75 06                	jne    f01011da <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011d7:	0f 01 38             	invlpg (%eax)
}
f01011da:	c9                   	leave  
f01011db:	c3                   	ret    

f01011dc <page_remove>:
{
f01011dc:	55                   	push   %ebp
f01011dd:	89 e5                	mov    %esp,%ebp
f01011df:	56                   	push   %esi
f01011e0:	53                   	push   %ebx
f01011e1:	83 ec 14             	sub    $0x14,%esp
f01011e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01011e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo * pp=page_lookup(pgdir,va,&pt_entry);
f01011ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011ed:	50                   	push   %eax
f01011ee:	56                   	push   %esi
f01011ef:	53                   	push   %ebx
f01011f0:	e8 53 ff ff ff       	call   f0101148 <page_lookup>
	if(pp==NULL) return ;
f01011f5:	83 c4 10             	add    $0x10,%esp
f01011f8:	85 c0                	test   %eax,%eax
f01011fa:	74 1f                	je     f010121b <page_remove+0x3f>
	page_decref(pp);
f01011fc:	83 ec 0c             	sub    $0xc,%esp
f01011ff:	50                   	push   %eax
f0101200:	e8 da fd ff ff       	call   f0100fdf <page_decref>
	*pt_entry= 0;
f0101205:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101208:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f010120e:	83 c4 08             	add    $0x8,%esp
f0101211:	56                   	push   %esi
f0101212:	53                   	push   %ebx
f0101213:	e8 8f ff ff ff       	call   f01011a7 <tlb_invalidate>
f0101218:	83 c4 10             	add    $0x10,%esp
}
f010121b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010121e:	5b                   	pop    %ebx
f010121f:	5e                   	pop    %esi
f0101220:	5d                   	pop    %ebp
f0101221:	c3                   	ret    

f0101222 <page_insert>:
{
f0101222:	55                   	push   %ebp
f0101223:	89 e5                	mov    %esp,%ebp
f0101225:	57                   	push   %edi
f0101226:	56                   	push   %esi
f0101227:	53                   	push   %ebx
f0101228:	83 ec 10             	sub    $0x10,%esp
f010122b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010122e:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pt_entry=pgdir_walk(pgdir,va,1);
f0101231:	6a 01                	push   $0x1
f0101233:	57                   	push   %edi
f0101234:	ff 75 08             	push   0x8(%ebp)
f0101237:	e8 cc fd ff ff       	call   f0101008 <pgdir_walk>
	if(pt_entry==NULL) return -E_NO_MEM;
f010123c:	83 c4 10             	add    $0x10,%esp
f010123f:	85 c0                	test   %eax,%eax
f0101241:	74 3e                	je     f0101281 <page_insert+0x5f>
f0101243:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;//这个一定要在前面，否则如果相同的pp 重新插入相同的va就会把  pp释放掉了。
f0101245:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if( (*pt_entry) & PTE_P ){//如果这个页已经存在
f010124a:	f6 00 01             	testb  $0x1,(%eax)
f010124d:	75 21                	jne    f0101270 <page_insert+0x4e>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f010124f:	2b 1d 58 82 21 f0    	sub    0xf0218258,%ebx
f0101255:	c1 fb 03             	sar    $0x3,%ebx
f0101258:	c1 e3 0c             	shl    $0xc,%ebx
	*pt_entry = *pt_entry | perm | PTE_P ;
f010125b:	0b 5d 14             	or     0x14(%ebp),%ebx
f010125e:	83 cb 01             	or     $0x1,%ebx
f0101261:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101263:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101268:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010126b:	5b                   	pop    %ebx
f010126c:	5e                   	pop    %esi
f010126d:	5f                   	pop    %edi
f010126e:	5d                   	pop    %ebp
f010126f:	c3                   	ret    
		page_remove(pgdir, va);
f0101270:	83 ec 08             	sub    $0x8,%esp
f0101273:	57                   	push   %edi
f0101274:	ff 75 08             	push   0x8(%ebp)
f0101277:	e8 60 ff ff ff       	call   f01011dc <page_remove>
f010127c:	83 c4 10             	add    $0x10,%esp
f010127f:	eb ce                	jmp    f010124f <page_insert+0x2d>
	if(pt_entry==NULL) return -E_NO_MEM;
f0101281:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101286:	eb e0                	jmp    f0101268 <page_insert+0x46>

f0101288 <mmio_map_region>:
{
f0101288:	55                   	push   %ebp
f0101289:	89 e5                	mov    %esp,%ebp
f010128b:	56                   	push   %esi
f010128c:	53                   	push   %ebx
	void *ret =(void*) base;
f010128d:	8b 35 00 53 12 f0    	mov    0xf0125300,%esi
	size=ROUNDUP(size,PGSIZE);
f0101293:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101296:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010129c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(base + size > MMIOLIM || base + size < base /*unsigned 越界*/)  panic("mmio_map_region reservation overflow");
f01012a2:	89 f0                	mov    %esi,%eax
f01012a4:	01 d8                	add    %ebx,%eax
f01012a6:	72 2c                	jb     f01012d4 <mmio_map_region+0x4c>
f01012a8:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01012ad:	77 25                	ja     f01012d4 <mmio_map_region+0x4c>
	boot_map_region(kern_pgdir, base, size, pa, PTE_W|PTE_PCD|PTE_PWT);
f01012af:	83 ec 08             	sub    $0x8,%esp
f01012b2:	6a 1a                	push   $0x1a
f01012b4:	ff 75 08             	push   0x8(%ebp)
f01012b7:	89 d9                	mov    %ebx,%ecx
f01012b9:	89 f2                	mov    %esi,%edx
f01012bb:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
f01012c0:	e8 1c fe ff ff       	call   f01010e1 <boot_map_region>
	base += size;
f01012c5:	01 1d 00 53 12 f0    	add    %ebx,0xf0125300
}
f01012cb:	89 f0                	mov    %esi,%eax
f01012cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012d0:	5b                   	pop    %ebx
f01012d1:	5e                   	pop    %esi
f01012d2:	5d                   	pop    %ebp
f01012d3:	c3                   	ret    
	if(base + size > MMIOLIM || base + size < base /*unsigned 越界*/)  panic("mmio_map_region reservation overflow");
f01012d4:	83 ec 04             	sub    $0x4,%esp
f01012d7:	68 14 6e 10 f0       	push   $0xf0106e14
f01012dc:	68 91 02 00 00       	push   $0x291
f01012e1:	68 af 69 10 f0       	push   $0xf01069af
f01012e6:	e8 55 ed ff ff       	call   f0100040 <_panic>

f01012eb <mem_init>:
{
f01012eb:	55                   	push   %ebp
f01012ec:	89 e5                	mov    %esp,%ebp
f01012ee:	57                   	push   %edi
f01012ef:	56                   	push   %esi
f01012f0:	53                   	push   %ebx
f01012f1:	83 ec 4c             	sub    $0x4c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f01012f4:	b8 15 00 00 00       	mov    $0x15,%eax
f01012f9:	e8 8f f7 ff ff       	call   f0100a8d <nvram_read>
f01012fe:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101300:	b8 17 00 00 00       	mov    $0x17,%eax
f0101305:	e8 83 f7 ff ff       	call   f0100a8d <nvram_read>
f010130a:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010130c:	b8 34 00 00 00       	mov    $0x34,%eax
f0101311:	e8 77 f7 ff ff       	call   f0100a8d <nvram_read>
	if (ext16mem)
f0101316:	c1 e0 06             	shl    $0x6,%eax
f0101319:	0f 84 d3 00 00 00    	je     f01013f2 <mem_init+0x107>
		totalmem = 16 * 1024 + ext16mem;
f010131f:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101324:	89 c2                	mov    %eax,%edx
f0101326:	c1 ea 02             	shr    $0x2,%edx
f0101329:	89 15 60 82 21 f0    	mov    %edx,0xf0218260
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010132f:	89 c2                	mov    %eax,%edx
f0101331:	29 da                	sub    %ebx,%edx
f0101333:	52                   	push   %edx
f0101334:	53                   	push   %ebx
f0101335:	50                   	push   %eax
f0101336:	68 3c 6e 10 f0       	push   $0xf0106e3c
f010133b:	e8 72 26 00 00       	call   f01039b2 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101340:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101345:	e8 6c f7 ff ff       	call   f0100ab6 <boot_alloc>
f010134a:	a3 5c 82 21 f0       	mov    %eax,0xf021825c
	memset(kern_pgdir, 0, PGSIZE);
f010134f:	83 c4 0c             	add    $0xc,%esp
f0101352:	68 00 10 00 00       	push   $0x1000
f0101357:	6a 00                	push   $0x0
f0101359:	50                   	push   %eax
f010135a:	e8 b8 44 00 00       	call   f0105817 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010135f:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101364:	83 c4 10             	add    $0x10,%esp
f0101367:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010136c:	0f 86 90 00 00 00    	jbe    f0101402 <mem_init+0x117>
	return (physaddr_t)kva - KERNBASE;
f0101372:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101378:	83 ca 05             	or     $0x5,%edx
f010137b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = boot_alloc(npages * sizeof(struct PageInfo));//pages是页信息数组的地址
f0101381:	a1 60 82 21 f0       	mov    0xf0218260,%eax
f0101386:	c1 e0 03             	shl    $0x3,%eax
f0101389:	e8 28 f7 ff ff       	call   f0100ab6 <boot_alloc>
f010138e:	a3 58 82 21 f0       	mov    %eax,0xf0218258
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101393:	83 ec 04             	sub    $0x4,%esp
f0101396:	8b 0d 60 82 21 f0    	mov    0xf0218260,%ecx
f010139c:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013a3:	52                   	push   %edx
f01013a4:	6a 00                	push   $0x0
f01013a6:	50                   	push   %eax
f01013a7:	e8 6b 44 00 00       	call   f0105817 <memset>
	envs = (struct Env*) boot_alloc (NENV * sizeof (struct Env) );
f01013ac:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013b1:	e8 00 f7 ff ff       	call   f0100ab6 <boot_alloc>
f01013b6:	a3 70 82 21 f0       	mov    %eax,0xf0218270
	memset(envs , 0, NENV * sizeof(struct Env));
f01013bb:	83 c4 0c             	add    $0xc,%esp
f01013be:	68 00 f0 01 00       	push   $0x1f000
f01013c3:	6a 00                	push   $0x0
f01013c5:	50                   	push   %eax
f01013c6:	e8 4c 44 00 00       	call   f0105817 <memset>
	page_init();
f01013cb:	e8 8b fa ff ff       	call   f0100e5b <page_init>
	check_page_free_list(1);
f01013d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01013d5:	e8 93 f7 ff ff       	call   f0100b6d <check_page_free_list>
	if (!pages)
f01013da:	83 c4 10             	add    $0x10,%esp
f01013dd:	83 3d 58 82 21 f0 00 	cmpl   $0x0,0xf0218258
f01013e4:	74 31                	je     f0101417 <mem_init+0x12c>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013e6:	a1 6c 82 21 f0       	mov    0xf021826c,%eax
f01013eb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013f0:	eb 41                	jmp    f0101433 <mem_init+0x148>
		totalmem = 1 * 1024 + extmem;
f01013f2:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01013f8:	85 f6                	test   %esi,%esi
f01013fa:	0f 44 c3             	cmove  %ebx,%eax
f01013fd:	e9 22 ff ff ff       	jmp    f0101324 <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101402:	50                   	push   %eax
f0101403:	68 88 64 10 f0       	push   $0xf0106488
f0101408:	68 9c 00 00 00       	push   $0x9c
f010140d:	68 af 69 10 f0       	push   $0xf01069af
f0101412:	e8 29 ec ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f0101417:	83 ec 04             	sub    $0x4,%esp
f010141a:	68 a6 6a 10 f0       	push   $0xf0106aa6
f010141f:	68 2b 03 00 00       	push   $0x32b
f0101424:	68 af 69 10 f0       	push   $0xf01069af
f0101429:	e8 12 ec ff ff       	call   f0100040 <_panic>
		++nfree;
f010142e:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101431:	8b 00                	mov    (%eax),%eax
f0101433:	85 c0                	test   %eax,%eax
f0101435:	75 f7                	jne    f010142e <mem_init+0x143>
	assert((pp0 = page_alloc(0)));
f0101437:	83 ec 0c             	sub    $0xc,%esp
f010143a:	6a 00                	push   $0x0
f010143c:	e8 d3 fa ff ff       	call   f0100f14 <page_alloc>
f0101441:	89 c7                	mov    %eax,%edi
f0101443:	83 c4 10             	add    $0x10,%esp
f0101446:	85 c0                	test   %eax,%eax
f0101448:	0f 84 1f 02 00 00    	je     f010166d <mem_init+0x382>
	assert((pp1 = page_alloc(0)));
f010144e:	83 ec 0c             	sub    $0xc,%esp
f0101451:	6a 00                	push   $0x0
f0101453:	e8 bc fa ff ff       	call   f0100f14 <page_alloc>
f0101458:	89 c6                	mov    %eax,%esi
f010145a:	83 c4 10             	add    $0x10,%esp
f010145d:	85 c0                	test   %eax,%eax
f010145f:	0f 84 21 02 00 00    	je     f0101686 <mem_init+0x39b>
	assert((pp2 = page_alloc(0)));
f0101465:	83 ec 0c             	sub    $0xc,%esp
f0101468:	6a 00                	push   $0x0
f010146a:	e8 a5 fa ff ff       	call   f0100f14 <page_alloc>
f010146f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101472:	83 c4 10             	add    $0x10,%esp
f0101475:	85 c0                	test   %eax,%eax
f0101477:	0f 84 22 02 00 00    	je     f010169f <mem_init+0x3b4>
	assert(pp1 && pp1 != pp0);
f010147d:	39 f7                	cmp    %esi,%edi
f010147f:	0f 84 33 02 00 00    	je     f01016b8 <mem_init+0x3cd>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101485:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101488:	39 c7                	cmp    %eax,%edi
f010148a:	0f 84 41 02 00 00    	je     f01016d1 <mem_init+0x3e6>
f0101490:	39 c6                	cmp    %eax,%esi
f0101492:	0f 84 39 02 00 00    	je     f01016d1 <mem_init+0x3e6>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101498:	8b 0d 58 82 21 f0    	mov    0xf0218258,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010149e:	8b 15 60 82 21 f0    	mov    0xf0218260,%edx
f01014a4:	c1 e2 0c             	shl    $0xc,%edx
f01014a7:	89 f8                	mov    %edi,%eax
f01014a9:	29 c8                	sub    %ecx,%eax
f01014ab:	c1 f8 03             	sar    $0x3,%eax
f01014ae:	c1 e0 0c             	shl    $0xc,%eax
f01014b1:	39 d0                	cmp    %edx,%eax
f01014b3:	0f 83 31 02 00 00    	jae    f01016ea <mem_init+0x3ff>
f01014b9:	89 f0                	mov    %esi,%eax
f01014bb:	29 c8                	sub    %ecx,%eax
f01014bd:	c1 f8 03             	sar    $0x3,%eax
f01014c0:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01014c3:	39 c2                	cmp    %eax,%edx
f01014c5:	0f 86 38 02 00 00    	jbe    f0101703 <mem_init+0x418>
f01014cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014ce:	29 c8                	sub    %ecx,%eax
f01014d0:	c1 f8 03             	sar    $0x3,%eax
f01014d3:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01014d6:	39 c2                	cmp    %eax,%edx
f01014d8:	0f 86 3e 02 00 00    	jbe    f010171c <mem_init+0x431>
	fl = page_free_list;
f01014de:	a1 6c 82 21 f0       	mov    0xf021826c,%eax
f01014e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014e6:	c7 05 6c 82 21 f0 00 	movl   $0x0,0xf021826c
f01014ed:	00 00 00 
	assert(!page_alloc(0));
f01014f0:	83 ec 0c             	sub    $0xc,%esp
f01014f3:	6a 00                	push   $0x0
f01014f5:	e8 1a fa ff ff       	call   f0100f14 <page_alloc>
f01014fa:	83 c4 10             	add    $0x10,%esp
f01014fd:	85 c0                	test   %eax,%eax
f01014ff:	0f 85 30 02 00 00    	jne    f0101735 <mem_init+0x44a>
	page_free(pp0);
f0101505:	83 ec 0c             	sub    $0xc,%esp
f0101508:	57                   	push   %edi
f0101509:	e8 7b fa ff ff       	call   f0100f89 <page_free>
	page_free(pp1);
f010150e:	89 34 24             	mov    %esi,(%esp)
f0101511:	e8 73 fa ff ff       	call   f0100f89 <page_free>
	page_free(pp2);
f0101516:	83 c4 04             	add    $0x4,%esp
f0101519:	ff 75 d4             	push   -0x2c(%ebp)
f010151c:	e8 68 fa ff ff       	call   f0100f89 <page_free>
	assert((pp0 = page_alloc(0)));
f0101521:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101528:	e8 e7 f9 ff ff       	call   f0100f14 <page_alloc>
f010152d:	89 c6                	mov    %eax,%esi
f010152f:	83 c4 10             	add    $0x10,%esp
f0101532:	85 c0                	test   %eax,%eax
f0101534:	0f 84 14 02 00 00    	je     f010174e <mem_init+0x463>
	assert((pp1 = page_alloc(0)));
f010153a:	83 ec 0c             	sub    $0xc,%esp
f010153d:	6a 00                	push   $0x0
f010153f:	e8 d0 f9 ff ff       	call   f0100f14 <page_alloc>
f0101544:	89 c7                	mov    %eax,%edi
f0101546:	83 c4 10             	add    $0x10,%esp
f0101549:	85 c0                	test   %eax,%eax
f010154b:	0f 84 16 02 00 00    	je     f0101767 <mem_init+0x47c>
	assert((pp2 = page_alloc(0)));
f0101551:	83 ec 0c             	sub    $0xc,%esp
f0101554:	6a 00                	push   $0x0
f0101556:	e8 b9 f9 ff ff       	call   f0100f14 <page_alloc>
f010155b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010155e:	83 c4 10             	add    $0x10,%esp
f0101561:	85 c0                	test   %eax,%eax
f0101563:	0f 84 17 02 00 00    	je     f0101780 <mem_init+0x495>
	assert(pp1 && pp1 != pp0);
f0101569:	39 fe                	cmp    %edi,%esi
f010156b:	0f 84 28 02 00 00    	je     f0101799 <mem_init+0x4ae>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101571:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101574:	39 c6                	cmp    %eax,%esi
f0101576:	0f 84 36 02 00 00    	je     f01017b2 <mem_init+0x4c7>
f010157c:	39 c7                	cmp    %eax,%edi
f010157e:	0f 84 2e 02 00 00    	je     f01017b2 <mem_init+0x4c7>
	assert(!page_alloc(0));
f0101584:	83 ec 0c             	sub    $0xc,%esp
f0101587:	6a 00                	push   $0x0
f0101589:	e8 86 f9 ff ff       	call   f0100f14 <page_alloc>
f010158e:	83 c4 10             	add    $0x10,%esp
f0101591:	85 c0                	test   %eax,%eax
f0101593:	0f 85 32 02 00 00    	jne    f01017cb <mem_init+0x4e0>
f0101599:	89 f0                	mov    %esi,%eax
f010159b:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f01015a1:	c1 f8 03             	sar    $0x3,%eax
f01015a4:	89 c2                	mov    %eax,%edx
f01015a6:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01015a9:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01015ae:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f01015b4:	0f 83 2a 02 00 00    	jae    f01017e4 <mem_init+0x4f9>
	memset(page2kva(pp0), 1, PGSIZE);
f01015ba:	83 ec 04             	sub    $0x4,%esp
f01015bd:	68 00 10 00 00       	push   $0x1000
f01015c2:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01015c4:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01015ca:	52                   	push   %edx
f01015cb:	e8 47 42 00 00       	call   f0105817 <memset>
	page_free(pp0);
f01015d0:	89 34 24             	mov    %esi,(%esp)
f01015d3:	e8 b1 f9 ff ff       	call   f0100f89 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015df:	e8 30 f9 ff ff       	call   f0100f14 <page_alloc>
f01015e4:	83 c4 10             	add    $0x10,%esp
f01015e7:	85 c0                	test   %eax,%eax
f01015e9:	0f 84 07 02 00 00    	je     f01017f6 <mem_init+0x50b>
	assert(pp && pp0 == pp);
f01015ef:	39 c6                	cmp    %eax,%esi
f01015f1:	0f 85 18 02 00 00    	jne    f010180f <mem_init+0x524>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f01015f7:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f01015fd:	c1 f8 03             	sar    $0x3,%eax
f0101600:	89 c2                	mov    %eax,%edx
f0101602:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101605:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010160a:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f0101610:	0f 83 12 02 00 00    	jae    f0101828 <mem_init+0x53d>
	return (void *)(pa + KERNBASE);
f0101616:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010161c:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101622:	80 38 00             	cmpb   $0x0,(%eax)
f0101625:	0f 85 0f 02 00 00    	jne    f010183a <mem_init+0x54f>
	for (i = 0; i < PGSIZE; i++)
f010162b:	83 c0 01             	add    $0x1,%eax
f010162e:	39 d0                	cmp    %edx,%eax
f0101630:	75 f0                	jne    f0101622 <mem_init+0x337>
	page_free_list = fl;
f0101632:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101635:	a3 6c 82 21 f0       	mov    %eax,0xf021826c
	page_free(pp0);
f010163a:	83 ec 0c             	sub    $0xc,%esp
f010163d:	56                   	push   %esi
f010163e:	e8 46 f9 ff ff       	call   f0100f89 <page_free>
	page_free(pp1);
f0101643:	89 3c 24             	mov    %edi,(%esp)
f0101646:	e8 3e f9 ff ff       	call   f0100f89 <page_free>
	page_free(pp2);
f010164b:	83 c4 04             	add    $0x4,%esp
f010164e:	ff 75 d4             	push   -0x2c(%ebp)
f0101651:	e8 33 f9 ff ff       	call   f0100f89 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101656:	a1 6c 82 21 f0       	mov    0xf021826c,%eax
f010165b:	83 c4 10             	add    $0x10,%esp
f010165e:	85 c0                	test   %eax,%eax
f0101660:	0f 84 ed 01 00 00    	je     f0101853 <mem_init+0x568>
		--nfree;
f0101666:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101669:	8b 00                	mov    (%eax),%eax
f010166b:	eb f1                	jmp    f010165e <mem_init+0x373>
	assert((pp0 = page_alloc(0)));
f010166d:	68 c1 6a 10 f0       	push   $0xf0106ac1
f0101672:	68 d5 69 10 f0       	push   $0xf01069d5
f0101677:	68 33 03 00 00       	push   $0x333
f010167c:	68 af 69 10 f0       	push   $0xf01069af
f0101681:	e8 ba e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101686:	68 d7 6a 10 f0       	push   $0xf0106ad7
f010168b:	68 d5 69 10 f0       	push   $0xf01069d5
f0101690:	68 34 03 00 00       	push   $0x334
f0101695:	68 af 69 10 f0       	push   $0xf01069af
f010169a:	e8 a1 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010169f:	68 ed 6a 10 f0       	push   $0xf0106aed
f01016a4:	68 d5 69 10 f0       	push   $0xf01069d5
f01016a9:	68 35 03 00 00       	push   $0x335
f01016ae:	68 af 69 10 f0       	push   $0xf01069af
f01016b3:	e8 88 e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01016b8:	68 03 6b 10 f0       	push   $0xf0106b03
f01016bd:	68 d5 69 10 f0       	push   $0xf01069d5
f01016c2:	68 38 03 00 00       	push   $0x338
f01016c7:	68 af 69 10 f0       	push   $0xf01069af
f01016cc:	e8 6f e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016d1:	68 78 6e 10 f0       	push   $0xf0106e78
f01016d6:	68 d5 69 10 f0       	push   $0xf01069d5
f01016db:	68 39 03 00 00       	push   $0x339
f01016e0:	68 af 69 10 f0       	push   $0xf01069af
f01016e5:	e8 56 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01016ea:	68 15 6b 10 f0       	push   $0xf0106b15
f01016ef:	68 d5 69 10 f0       	push   $0xf01069d5
f01016f4:	68 3a 03 00 00       	push   $0x33a
f01016f9:	68 af 69 10 f0       	push   $0xf01069af
f01016fe:	e8 3d e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101703:	68 32 6b 10 f0       	push   $0xf0106b32
f0101708:	68 d5 69 10 f0       	push   $0xf01069d5
f010170d:	68 3b 03 00 00       	push   $0x33b
f0101712:	68 af 69 10 f0       	push   $0xf01069af
f0101717:	e8 24 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010171c:	68 4f 6b 10 f0       	push   $0xf0106b4f
f0101721:	68 d5 69 10 f0       	push   $0xf01069d5
f0101726:	68 3c 03 00 00       	push   $0x33c
f010172b:	68 af 69 10 f0       	push   $0xf01069af
f0101730:	e8 0b e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101735:	68 6c 6b 10 f0       	push   $0xf0106b6c
f010173a:	68 d5 69 10 f0       	push   $0xf01069d5
f010173f:	68 43 03 00 00       	push   $0x343
f0101744:	68 af 69 10 f0       	push   $0xf01069af
f0101749:	e8 f2 e8 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010174e:	68 c1 6a 10 f0       	push   $0xf0106ac1
f0101753:	68 d5 69 10 f0       	push   $0xf01069d5
f0101758:	68 4a 03 00 00       	push   $0x34a
f010175d:	68 af 69 10 f0       	push   $0xf01069af
f0101762:	e8 d9 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101767:	68 d7 6a 10 f0       	push   $0xf0106ad7
f010176c:	68 d5 69 10 f0       	push   $0xf01069d5
f0101771:	68 4b 03 00 00       	push   $0x34b
f0101776:	68 af 69 10 f0       	push   $0xf01069af
f010177b:	e8 c0 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101780:	68 ed 6a 10 f0       	push   $0xf0106aed
f0101785:	68 d5 69 10 f0       	push   $0xf01069d5
f010178a:	68 4c 03 00 00       	push   $0x34c
f010178f:	68 af 69 10 f0       	push   $0xf01069af
f0101794:	e8 a7 e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101799:	68 03 6b 10 f0       	push   $0xf0106b03
f010179e:	68 d5 69 10 f0       	push   $0xf01069d5
f01017a3:	68 4e 03 00 00       	push   $0x34e
f01017a8:	68 af 69 10 f0       	push   $0xf01069af
f01017ad:	e8 8e e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017b2:	68 78 6e 10 f0       	push   $0xf0106e78
f01017b7:	68 d5 69 10 f0       	push   $0xf01069d5
f01017bc:	68 4f 03 00 00       	push   $0x34f
f01017c1:	68 af 69 10 f0       	push   $0xf01069af
f01017c6:	e8 75 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017cb:	68 6c 6b 10 f0       	push   $0xf0106b6c
f01017d0:	68 d5 69 10 f0       	push   $0xf01069d5
f01017d5:	68 50 03 00 00       	push   $0x350
f01017da:	68 af 69 10 f0       	push   $0xf01069af
f01017df:	e8 5c e8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017e4:	52                   	push   %edx
f01017e5:	68 64 64 10 f0       	push   $0xf0106464
f01017ea:	6a 5a                	push   $0x5a
f01017ec:	68 bb 69 10 f0       	push   $0xf01069bb
f01017f1:	e8 4a e8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017f6:	68 7b 6b 10 f0       	push   $0xf0106b7b
f01017fb:	68 d5 69 10 f0       	push   $0xf01069d5
f0101800:	68 55 03 00 00       	push   $0x355
f0101805:	68 af 69 10 f0       	push   $0xf01069af
f010180a:	e8 31 e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010180f:	68 99 6b 10 f0       	push   $0xf0106b99
f0101814:	68 d5 69 10 f0       	push   $0xf01069d5
f0101819:	68 56 03 00 00       	push   $0x356
f010181e:	68 af 69 10 f0       	push   $0xf01069af
f0101823:	e8 18 e8 ff ff       	call   f0100040 <_panic>
f0101828:	52                   	push   %edx
f0101829:	68 64 64 10 f0       	push   $0xf0106464
f010182e:	6a 5a                	push   $0x5a
f0101830:	68 bb 69 10 f0       	push   $0xf01069bb
f0101835:	e8 06 e8 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f010183a:	68 a9 6b 10 f0       	push   $0xf0106ba9
f010183f:	68 d5 69 10 f0       	push   $0xf01069d5
f0101844:	68 59 03 00 00       	push   $0x359
f0101849:	68 af 69 10 f0       	push   $0xf01069af
f010184e:	e8 ed e7 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f0101853:	85 db                	test   %ebx,%ebx
f0101855:	0f 85 3f 09 00 00    	jne    f010219a <mem_init+0xeaf>
	cprintf("check_page_alloc() succeeded!\n");
f010185b:	83 ec 0c             	sub    $0xc,%esp
f010185e:	68 98 6e 10 f0       	push   $0xf0106e98
f0101863:	e8 4a 21 00 00       	call   f01039b2 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101868:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010186f:	e8 a0 f6 ff ff       	call   f0100f14 <page_alloc>
f0101874:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101877:	83 c4 10             	add    $0x10,%esp
f010187a:	85 c0                	test   %eax,%eax
f010187c:	0f 84 31 09 00 00    	je     f01021b3 <mem_init+0xec8>
	assert((pp1 = page_alloc(0)));
f0101882:	83 ec 0c             	sub    $0xc,%esp
f0101885:	6a 00                	push   $0x0
f0101887:	e8 88 f6 ff ff       	call   f0100f14 <page_alloc>
f010188c:	89 c3                	mov    %eax,%ebx
f010188e:	83 c4 10             	add    $0x10,%esp
f0101891:	85 c0                	test   %eax,%eax
f0101893:	0f 84 33 09 00 00    	je     f01021cc <mem_init+0xee1>
	assert((pp2 = page_alloc(0)));
f0101899:	83 ec 0c             	sub    $0xc,%esp
f010189c:	6a 00                	push   $0x0
f010189e:	e8 71 f6 ff ff       	call   f0100f14 <page_alloc>
f01018a3:	89 c6                	mov    %eax,%esi
f01018a5:	83 c4 10             	add    $0x10,%esp
f01018a8:	85 c0                	test   %eax,%eax
f01018aa:	0f 84 35 09 00 00    	je     f01021e5 <mem_init+0xefa>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018b0:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01018b3:	0f 84 45 09 00 00    	je     f01021fe <mem_init+0xf13>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018b9:	39 c3                	cmp    %eax,%ebx
f01018bb:	0f 84 56 09 00 00    	je     f0102217 <mem_init+0xf2c>
f01018c1:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018c4:	0f 84 4d 09 00 00    	je     f0102217 <mem_init+0xf2c>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018ca:	a1 6c 82 21 f0       	mov    0xf021826c,%eax
f01018cf:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01018d2:	c7 05 6c 82 21 f0 00 	movl   $0x0,0xf021826c
f01018d9:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018dc:	83 ec 0c             	sub    $0xc,%esp
f01018df:	6a 00                	push   $0x0
f01018e1:	e8 2e f6 ff ff       	call   f0100f14 <page_alloc>
f01018e6:	83 c4 10             	add    $0x10,%esp
f01018e9:	85 c0                	test   %eax,%eax
f01018eb:	0f 85 3f 09 00 00    	jne    f0102230 <mem_init+0xf45>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018f1:	83 ec 04             	sub    $0x4,%esp
f01018f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018f7:	50                   	push   %eax
f01018f8:	6a 00                	push   $0x0
f01018fa:	ff 35 5c 82 21 f0    	push   0xf021825c
f0101900:	e8 43 f8 ff ff       	call   f0101148 <page_lookup>
f0101905:	83 c4 10             	add    $0x10,%esp
f0101908:	85 c0                	test   %eax,%eax
f010190a:	0f 85 39 09 00 00    	jne    f0102249 <mem_init+0xf5e>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101910:	6a 02                	push   $0x2
f0101912:	6a 00                	push   $0x0
f0101914:	53                   	push   %ebx
f0101915:	ff 35 5c 82 21 f0    	push   0xf021825c
f010191b:	e8 02 f9 ff ff       	call   f0101222 <page_insert>
f0101920:	83 c4 10             	add    $0x10,%esp
f0101923:	85 c0                	test   %eax,%eax
f0101925:	0f 89 37 09 00 00    	jns    f0102262 <mem_init+0xf77>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010192b:	83 ec 0c             	sub    $0xc,%esp
f010192e:	ff 75 d4             	push   -0x2c(%ebp)
f0101931:	e8 53 f6 ff ff       	call   f0100f89 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101936:	6a 02                	push   $0x2
f0101938:	6a 00                	push   $0x0
f010193a:	53                   	push   %ebx
f010193b:	ff 35 5c 82 21 f0    	push   0xf021825c
f0101941:	e8 dc f8 ff ff       	call   f0101222 <page_insert>
f0101946:	83 c4 20             	add    $0x20,%esp
f0101949:	85 c0                	test   %eax,%eax
f010194b:	0f 85 2a 09 00 00    	jne    f010227b <mem_init+0xf90>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101951:	8b 3d 5c 82 21 f0    	mov    0xf021825c,%edi
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101957:	8b 0d 58 82 21 f0    	mov    0xf0218258,%ecx
f010195d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101960:	8b 17                	mov    (%edi),%edx
f0101962:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101968:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010196b:	29 c8                	sub    %ecx,%eax
f010196d:	c1 f8 03             	sar    $0x3,%eax
f0101970:	c1 e0 0c             	shl    $0xc,%eax
f0101973:	39 c2                	cmp    %eax,%edx
f0101975:	0f 85 19 09 00 00    	jne    f0102294 <mem_init+0xfa9>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010197b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101980:	89 f8                	mov    %edi,%eax
f0101982:	e8 83 f1 ff ff       	call   f0100b0a <check_va2pa>
f0101987:	89 c2                	mov    %eax,%edx
f0101989:	89 d8                	mov    %ebx,%eax
f010198b:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010198e:	c1 f8 03             	sar    $0x3,%eax
f0101991:	c1 e0 0c             	shl    $0xc,%eax
f0101994:	39 c2                	cmp    %eax,%edx
f0101996:	0f 85 11 09 00 00    	jne    f01022ad <mem_init+0xfc2>
	assert(pp1->pp_ref == 1);
f010199c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019a1:	0f 85 1f 09 00 00    	jne    f01022c6 <mem_init+0xfdb>
	assert(pp0->pp_ref == 1);
f01019a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019aa:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01019af:	0f 85 2a 09 00 00    	jne    f01022df <mem_init+0xff4>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019b5:	6a 02                	push   $0x2
f01019b7:	68 00 10 00 00       	push   $0x1000
f01019bc:	56                   	push   %esi
f01019bd:	57                   	push   %edi
f01019be:	e8 5f f8 ff ff       	call   f0101222 <page_insert>
f01019c3:	83 c4 10             	add    $0x10,%esp
f01019c6:	85 c0                	test   %eax,%eax
f01019c8:	0f 85 2a 09 00 00    	jne    f01022f8 <mem_init+0x100d>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019ce:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019d3:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
f01019d8:	e8 2d f1 ff ff       	call   f0100b0a <check_va2pa>
f01019dd:	89 c2                	mov    %eax,%edx
f01019df:	89 f0                	mov    %esi,%eax
f01019e1:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f01019e7:	c1 f8 03             	sar    $0x3,%eax
f01019ea:	c1 e0 0c             	shl    $0xc,%eax
f01019ed:	39 c2                	cmp    %eax,%edx
f01019ef:	0f 85 1c 09 00 00    	jne    f0102311 <mem_init+0x1026>
	assert(pp2->pp_ref == 1);
f01019f5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019fa:	0f 85 2a 09 00 00    	jne    f010232a <mem_init+0x103f>

	// should be no free memory
	assert(!page_alloc(0));
f0101a00:	83 ec 0c             	sub    $0xc,%esp
f0101a03:	6a 00                	push   $0x0
f0101a05:	e8 0a f5 ff ff       	call   f0100f14 <page_alloc>
f0101a0a:	83 c4 10             	add    $0x10,%esp
f0101a0d:	85 c0                	test   %eax,%eax
f0101a0f:	0f 85 2e 09 00 00    	jne    f0102343 <mem_init+0x1058>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a15:	6a 02                	push   $0x2
f0101a17:	68 00 10 00 00       	push   $0x1000
f0101a1c:	56                   	push   %esi
f0101a1d:	ff 35 5c 82 21 f0    	push   0xf021825c
f0101a23:	e8 fa f7 ff ff       	call   f0101222 <page_insert>
f0101a28:	83 c4 10             	add    $0x10,%esp
f0101a2b:	85 c0                	test   %eax,%eax
f0101a2d:	0f 85 29 09 00 00    	jne    f010235c <mem_init+0x1071>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a33:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a38:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
f0101a3d:	e8 c8 f0 ff ff       	call   f0100b0a <check_va2pa>
f0101a42:	89 c2                	mov    %eax,%edx
f0101a44:	89 f0                	mov    %esi,%eax
f0101a46:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f0101a4c:	c1 f8 03             	sar    $0x3,%eax
f0101a4f:	c1 e0 0c             	shl    $0xc,%eax
f0101a52:	39 c2                	cmp    %eax,%edx
f0101a54:	0f 85 1b 09 00 00    	jne    f0102375 <mem_init+0x108a>
	assert(pp2->pp_ref == 1);
f0101a5a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a5f:	0f 85 29 09 00 00    	jne    f010238e <mem_init+0x10a3>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a65:	83 ec 0c             	sub    $0xc,%esp
f0101a68:	6a 00                	push   $0x0
f0101a6a:	e8 a5 f4 ff ff       	call   f0100f14 <page_alloc>
f0101a6f:	83 c4 10             	add    $0x10,%esp
f0101a72:	85 c0                	test   %eax,%eax
f0101a74:	0f 85 2d 09 00 00    	jne    f01023a7 <mem_init+0x10bc>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a7a:	8b 15 5c 82 21 f0    	mov    0xf021825c,%edx
f0101a80:	8b 02                	mov    (%edx),%eax
f0101a82:	89 c7                	mov    %eax,%edi
f0101a84:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0101a8a:	c1 e8 0c             	shr    $0xc,%eax
f0101a8d:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f0101a93:	0f 83 27 09 00 00    	jae    f01023c0 <mem_init+0x10d5>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a99:	83 ec 04             	sub    $0x4,%esp
f0101a9c:	6a 00                	push   $0x0
f0101a9e:	68 00 10 00 00       	push   $0x1000
f0101aa3:	52                   	push   %edx
f0101aa4:	e8 5f f5 ff ff       	call   f0101008 <pgdir_walk>
f0101aa9:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0101aaf:	83 c4 10             	add    $0x10,%esp
f0101ab2:	39 f8                	cmp    %edi,%eax
f0101ab4:	0f 85 1b 09 00 00    	jne    f01023d5 <mem_init+0x10ea>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101aba:	6a 06                	push   $0x6
f0101abc:	68 00 10 00 00       	push   $0x1000
f0101ac1:	56                   	push   %esi
f0101ac2:	ff 35 5c 82 21 f0    	push   0xf021825c
f0101ac8:	e8 55 f7 ff ff       	call   f0101222 <page_insert>
f0101acd:	83 c4 10             	add    $0x10,%esp
f0101ad0:	85 c0                	test   %eax,%eax
f0101ad2:	0f 85 16 09 00 00    	jne    f01023ee <mem_init+0x1103>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ad8:	8b 3d 5c 82 21 f0    	mov    0xf021825c,%edi
f0101ade:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ae3:	89 f8                	mov    %edi,%eax
f0101ae5:	e8 20 f0 ff ff       	call   f0100b0a <check_va2pa>
f0101aea:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101aec:	89 f0                	mov    %esi,%eax
f0101aee:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f0101af4:	c1 f8 03             	sar    $0x3,%eax
f0101af7:	c1 e0 0c             	shl    $0xc,%eax
f0101afa:	39 c2                	cmp    %eax,%edx
f0101afc:	0f 85 05 09 00 00    	jne    f0102407 <mem_init+0x111c>
	assert(pp2->pp_ref == 1);
f0101b02:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b07:	0f 85 13 09 00 00    	jne    f0102420 <mem_init+0x1135>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b0d:	83 ec 04             	sub    $0x4,%esp
f0101b10:	6a 00                	push   $0x0
f0101b12:	68 00 10 00 00       	push   $0x1000
f0101b17:	57                   	push   %edi
f0101b18:	e8 eb f4 ff ff       	call   f0101008 <pgdir_walk>
f0101b1d:	83 c4 10             	add    $0x10,%esp
f0101b20:	f6 00 04             	testb  $0x4,(%eax)
f0101b23:	0f 84 10 09 00 00    	je     f0102439 <mem_init+0x114e>
	assert(kern_pgdir[0] & PTE_U);
f0101b29:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
f0101b2e:	f6 00 04             	testb  $0x4,(%eax)
f0101b31:	0f 84 1b 09 00 00    	je     f0102452 <mem_init+0x1167>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b37:	6a 02                	push   $0x2
f0101b39:	68 00 10 00 00       	push   $0x1000
f0101b3e:	56                   	push   %esi
f0101b3f:	50                   	push   %eax
f0101b40:	e8 dd f6 ff ff       	call   f0101222 <page_insert>
f0101b45:	83 c4 10             	add    $0x10,%esp
f0101b48:	85 c0                	test   %eax,%eax
f0101b4a:	0f 85 1b 09 00 00    	jne    f010246b <mem_init+0x1180>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b50:	83 ec 04             	sub    $0x4,%esp
f0101b53:	6a 00                	push   $0x0
f0101b55:	68 00 10 00 00       	push   $0x1000
f0101b5a:	ff 35 5c 82 21 f0    	push   0xf021825c
f0101b60:	e8 a3 f4 ff ff       	call   f0101008 <pgdir_walk>
f0101b65:	83 c4 10             	add    $0x10,%esp
f0101b68:	f6 00 02             	testb  $0x2,(%eax)
f0101b6b:	0f 84 13 09 00 00    	je     f0102484 <mem_init+0x1199>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b71:	83 ec 04             	sub    $0x4,%esp
f0101b74:	6a 00                	push   $0x0
f0101b76:	68 00 10 00 00       	push   $0x1000
f0101b7b:	ff 35 5c 82 21 f0    	push   0xf021825c
f0101b81:	e8 82 f4 ff ff       	call   f0101008 <pgdir_walk>
f0101b86:	83 c4 10             	add    $0x10,%esp
f0101b89:	f6 00 04             	testb  $0x4,(%eax)
f0101b8c:	0f 85 0b 09 00 00    	jne    f010249d <mem_init+0x11b2>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b92:	6a 02                	push   $0x2
f0101b94:	68 00 00 40 00       	push   $0x400000
f0101b99:	ff 75 d4             	push   -0x2c(%ebp)
f0101b9c:	ff 35 5c 82 21 f0    	push   0xf021825c
f0101ba2:	e8 7b f6 ff ff       	call   f0101222 <page_insert>
f0101ba7:	83 c4 10             	add    $0x10,%esp
f0101baa:	85 c0                	test   %eax,%eax
f0101bac:	0f 89 04 09 00 00    	jns    f01024b6 <mem_init+0x11cb>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101bb2:	6a 02                	push   $0x2
f0101bb4:	68 00 10 00 00       	push   $0x1000
f0101bb9:	53                   	push   %ebx
f0101bba:	ff 35 5c 82 21 f0    	push   0xf021825c
f0101bc0:	e8 5d f6 ff ff       	call   f0101222 <page_insert>
f0101bc5:	83 c4 10             	add    $0x10,%esp
f0101bc8:	85 c0                	test   %eax,%eax
f0101bca:	0f 85 ff 08 00 00    	jne    f01024cf <mem_init+0x11e4>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bd0:	83 ec 04             	sub    $0x4,%esp
f0101bd3:	6a 00                	push   $0x0
f0101bd5:	68 00 10 00 00       	push   $0x1000
f0101bda:	ff 35 5c 82 21 f0    	push   0xf021825c
f0101be0:	e8 23 f4 ff ff       	call   f0101008 <pgdir_walk>
f0101be5:	83 c4 10             	add    $0x10,%esp
f0101be8:	f6 00 04             	testb  $0x4,(%eax)
f0101beb:	0f 85 f7 08 00 00    	jne    f01024e8 <mem_init+0x11fd>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bf1:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
f0101bf6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101bf9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bfe:	e8 07 ef ff ff       	call   f0100b0a <check_va2pa>
f0101c03:	89 df                	mov    %ebx,%edi
f0101c05:	2b 3d 58 82 21 f0    	sub    0xf0218258,%edi
f0101c0b:	c1 ff 03             	sar    $0x3,%edi
f0101c0e:	c1 e7 0c             	shl    $0xc,%edi
f0101c11:	39 f8                	cmp    %edi,%eax
f0101c13:	0f 85 e8 08 00 00    	jne    f0102501 <mem_init+0x1216>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c19:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c1e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c21:	e8 e4 ee ff ff       	call   f0100b0a <check_va2pa>
f0101c26:	39 c7                	cmp    %eax,%edi
f0101c28:	0f 85 ec 08 00 00    	jne    f010251a <mem_init+0x122f>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c2e:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101c33:	0f 85 fa 08 00 00    	jne    f0102533 <mem_init+0x1248>
	assert(pp2->pp_ref == 0);
f0101c39:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c3e:	0f 85 08 09 00 00    	jne    f010254c <mem_init+0x1261>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c44:	83 ec 0c             	sub    $0xc,%esp
f0101c47:	6a 00                	push   $0x0
f0101c49:	e8 c6 f2 ff ff       	call   f0100f14 <page_alloc>
f0101c4e:	83 c4 10             	add    $0x10,%esp
f0101c51:	39 c6                	cmp    %eax,%esi
f0101c53:	0f 85 0c 09 00 00    	jne    f0102565 <mem_init+0x127a>
f0101c59:	85 c0                	test   %eax,%eax
f0101c5b:	0f 84 04 09 00 00    	je     f0102565 <mem_init+0x127a>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c61:	83 ec 08             	sub    $0x8,%esp
f0101c64:	6a 00                	push   $0x0
f0101c66:	ff 35 5c 82 21 f0    	push   0xf021825c
f0101c6c:	e8 6b f5 ff ff       	call   f01011dc <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c71:	8b 3d 5c 82 21 f0    	mov    0xf021825c,%edi
f0101c77:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c7c:	89 f8                	mov    %edi,%eax
f0101c7e:	e8 87 ee ff ff       	call   f0100b0a <check_va2pa>
f0101c83:	83 c4 10             	add    $0x10,%esp
f0101c86:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c89:	0f 85 ef 08 00 00    	jne    f010257e <mem_init+0x1293>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c8f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c94:	89 f8                	mov    %edi,%eax
f0101c96:	e8 6f ee ff ff       	call   f0100b0a <check_va2pa>
f0101c9b:	89 c2                	mov    %eax,%edx
f0101c9d:	89 d8                	mov    %ebx,%eax
f0101c9f:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f0101ca5:	c1 f8 03             	sar    $0x3,%eax
f0101ca8:	c1 e0 0c             	shl    $0xc,%eax
f0101cab:	39 c2                	cmp    %eax,%edx
f0101cad:	0f 85 e4 08 00 00    	jne    f0102597 <mem_init+0x12ac>
	assert(pp1->pp_ref == 1);
f0101cb3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cb8:	0f 85 f2 08 00 00    	jne    f01025b0 <mem_init+0x12c5>
	assert(pp2->pp_ref == 0);
f0101cbe:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101cc3:	0f 85 00 09 00 00    	jne    f01025c9 <mem_init+0x12de>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101cc9:	6a 00                	push   $0x0
f0101ccb:	68 00 10 00 00       	push   $0x1000
f0101cd0:	53                   	push   %ebx
f0101cd1:	57                   	push   %edi
f0101cd2:	e8 4b f5 ff ff       	call   f0101222 <page_insert>
f0101cd7:	83 c4 10             	add    $0x10,%esp
f0101cda:	85 c0                	test   %eax,%eax
f0101cdc:	0f 85 00 09 00 00    	jne    f01025e2 <mem_init+0x12f7>
	assert(pp1->pp_ref);
f0101ce2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101ce7:	0f 84 0e 09 00 00    	je     f01025fb <mem_init+0x1310>
	assert(pp1->pp_link == NULL);
f0101ced:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101cf0:	0f 85 1e 09 00 00    	jne    f0102614 <mem_init+0x1329>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101cf6:	83 ec 08             	sub    $0x8,%esp
f0101cf9:	68 00 10 00 00       	push   $0x1000
f0101cfe:	ff 35 5c 82 21 f0    	push   0xf021825c
f0101d04:	e8 d3 f4 ff ff       	call   f01011dc <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d09:	8b 3d 5c 82 21 f0    	mov    0xf021825c,%edi
f0101d0f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d14:	89 f8                	mov    %edi,%eax
f0101d16:	e8 ef ed ff ff       	call   f0100b0a <check_va2pa>
f0101d1b:	83 c4 10             	add    $0x10,%esp
f0101d1e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d21:	0f 85 06 09 00 00    	jne    f010262d <mem_init+0x1342>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d27:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d2c:	89 f8                	mov    %edi,%eax
f0101d2e:	e8 d7 ed ff ff       	call   f0100b0a <check_va2pa>
f0101d33:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d36:	0f 85 0a 09 00 00    	jne    f0102646 <mem_init+0x135b>
	assert(pp1->pp_ref == 0);
f0101d3c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d41:	0f 85 18 09 00 00    	jne    f010265f <mem_init+0x1374>
	assert(pp2->pp_ref == 0);
f0101d47:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d4c:	0f 85 26 09 00 00    	jne    f0102678 <mem_init+0x138d>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d52:	83 ec 0c             	sub    $0xc,%esp
f0101d55:	6a 00                	push   $0x0
f0101d57:	e8 b8 f1 ff ff       	call   f0100f14 <page_alloc>
f0101d5c:	83 c4 10             	add    $0x10,%esp
f0101d5f:	85 c0                	test   %eax,%eax
f0101d61:	0f 84 2a 09 00 00    	je     f0102691 <mem_init+0x13a6>
f0101d67:	39 c3                	cmp    %eax,%ebx
f0101d69:	0f 85 22 09 00 00    	jne    f0102691 <mem_init+0x13a6>

	// should be no free memory
	assert(!page_alloc(0));
f0101d6f:	83 ec 0c             	sub    $0xc,%esp
f0101d72:	6a 00                	push   $0x0
f0101d74:	e8 9b f1 ff ff       	call   f0100f14 <page_alloc>
f0101d79:	83 c4 10             	add    $0x10,%esp
f0101d7c:	85 c0                	test   %eax,%eax
f0101d7e:	0f 85 26 09 00 00    	jne    f01026aa <mem_init+0x13bf>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d84:	8b 0d 5c 82 21 f0    	mov    0xf021825c,%ecx
f0101d8a:	8b 11                	mov    (%ecx),%edx
f0101d8c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d95:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f0101d9b:	c1 f8 03             	sar    $0x3,%eax
f0101d9e:	c1 e0 0c             	shl    $0xc,%eax
f0101da1:	39 c2                	cmp    %eax,%edx
f0101da3:	0f 85 1a 09 00 00    	jne    f01026c3 <mem_init+0x13d8>
	kern_pgdir[0] = 0;
f0101da9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101daf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101db2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101db7:	0f 85 1f 09 00 00    	jne    f01026dc <mem_init+0x13f1>
	pp0->pp_ref = 0;
f0101dbd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dc0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101dc6:	83 ec 0c             	sub    $0xc,%esp
f0101dc9:	50                   	push   %eax
f0101dca:	e8 ba f1 ff ff       	call   f0100f89 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101dcf:	83 c4 0c             	add    $0xc,%esp
f0101dd2:	6a 01                	push   $0x1
f0101dd4:	68 00 10 40 00       	push   $0x401000
f0101dd9:	ff 35 5c 82 21 f0    	push   0xf021825c
f0101ddf:	e8 24 f2 ff ff       	call   f0101008 <pgdir_walk>
f0101de4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101de7:	8b 0d 5c 82 21 f0    	mov    0xf021825c,%ecx
f0101ded:	8b 41 04             	mov    0x4(%ecx),%eax
f0101df0:	89 c7                	mov    %eax,%edi
f0101df2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0101df8:	8b 15 60 82 21 f0    	mov    0xf0218260,%edx
f0101dfe:	c1 e8 0c             	shr    $0xc,%eax
f0101e01:	83 c4 10             	add    $0x10,%esp
f0101e04:	39 d0                	cmp    %edx,%eax
f0101e06:	0f 83 e9 08 00 00    	jae    f01026f5 <mem_init+0x140a>
	assert(ptep == ptep1 + PTX(va));
f0101e0c:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0101e12:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101e15:	0f 85 ef 08 00 00    	jne    f010270a <mem_init+0x141f>
	kern_pgdir[PDX(va)] = 0;
f0101e1b:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101e22:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e25:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101e2b:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f0101e31:	c1 f8 03             	sar    $0x3,%eax
f0101e34:	89 c1                	mov    %eax,%ecx
f0101e36:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f0101e39:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101e3e:	39 c2                	cmp    %eax,%edx
f0101e40:	0f 86 dd 08 00 00    	jbe    f0102723 <mem_init+0x1438>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e46:	83 ec 04             	sub    $0x4,%esp
f0101e49:	68 00 10 00 00       	push   $0x1000
f0101e4e:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e53:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101e59:	51                   	push   %ecx
f0101e5a:	e8 b8 39 00 00       	call   f0105817 <memset>
	page_free(pp0);
f0101e5f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101e62:	89 3c 24             	mov    %edi,(%esp)
f0101e65:	e8 1f f1 ff ff       	call   f0100f89 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e6a:	83 c4 0c             	add    $0xc,%esp
f0101e6d:	6a 01                	push   $0x1
f0101e6f:	6a 00                	push   $0x0
f0101e71:	ff 35 5c 82 21 f0    	push   0xf021825c
f0101e77:	e8 8c f1 ff ff       	call   f0101008 <pgdir_walk>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101e7c:	89 f8                	mov    %edi,%eax
f0101e7e:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f0101e84:	c1 f8 03             	sar    $0x3,%eax
f0101e87:	89 c2                	mov    %eax,%edx
f0101e89:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101e8c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101e91:	83 c4 10             	add    $0x10,%esp
f0101e94:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f0101e9a:	0f 83 95 08 00 00    	jae    f0102735 <mem_init+0x144a>
	return (void *)(pa + KERNBASE);
f0101ea0:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101ea6:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101eac:	f6 00 01             	testb  $0x1,(%eax)
f0101eaf:	0f 85 92 08 00 00    	jne    f0102747 <mem_init+0x145c>
	for(i=0; i<NPTENTRIES; i++)
f0101eb5:	83 c0 04             	add    $0x4,%eax
f0101eb8:	39 d0                	cmp    %edx,%eax
f0101eba:	75 f0                	jne    f0101eac <mem_init+0xbc1>
	kern_pgdir[0] = 0;
f0101ebc:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
f0101ec1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101ec7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eca:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101ed0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101ed3:	89 0d 6c 82 21 f0    	mov    %ecx,0xf021826c

	// free the pages we took
	page_free(pp0);
f0101ed9:	83 ec 0c             	sub    $0xc,%esp
f0101edc:	50                   	push   %eax
f0101edd:	e8 a7 f0 ff ff       	call   f0100f89 <page_free>
	page_free(pp1);
f0101ee2:	89 1c 24             	mov    %ebx,(%esp)
f0101ee5:	e8 9f f0 ff ff       	call   f0100f89 <page_free>
	page_free(pp2);
f0101eea:	89 34 24             	mov    %esi,(%esp)
f0101eed:	e8 97 f0 ff ff       	call   f0100f89 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101ef2:	83 c4 08             	add    $0x8,%esp
f0101ef5:	68 01 10 00 00       	push   $0x1001
f0101efa:	6a 00                	push   $0x0
f0101efc:	e8 87 f3 ff ff       	call   f0101288 <mmio_map_region>
f0101f01:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101f03:	83 c4 08             	add    $0x8,%esp
f0101f06:	68 00 10 00 00       	push   $0x1000
f0101f0b:	6a 00                	push   $0x0
f0101f0d:	e8 76 f3 ff ff       	call   f0101288 <mmio_map_region>
f0101f12:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101f14:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f1a:	83 c4 10             	add    $0x10,%esp
f0101f1d:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f23:	0f 86 37 08 00 00    	jbe    f0102760 <mem_init+0x1475>
f0101f29:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f2e:	0f 87 2c 08 00 00    	ja     f0102760 <mem_init+0x1475>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f34:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f3a:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f40:	0f 87 33 08 00 00    	ja     f0102779 <mem_init+0x148e>
f0101f46:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f4c:	0f 86 27 08 00 00    	jbe    f0102779 <mem_init+0x148e>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101f52:	89 da                	mov    %ebx,%edx
f0101f54:	09 f2                	or     %esi,%edx
f0101f56:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101f5c:	0f 85 30 08 00 00    	jne    f0102792 <mem_init+0x14a7>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101f62:	39 c6                	cmp    %eax,%esi
f0101f64:	0f 82 41 08 00 00    	jb     f01027ab <mem_init+0x14c0>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101f6a:	8b 3d 5c 82 21 f0    	mov    0xf021825c,%edi
f0101f70:	89 da                	mov    %ebx,%edx
f0101f72:	89 f8                	mov    %edi,%eax
f0101f74:	e8 91 eb ff ff       	call   f0100b0a <check_va2pa>
f0101f79:	85 c0                	test   %eax,%eax
f0101f7b:	0f 85 43 08 00 00    	jne    f01027c4 <mem_init+0x14d9>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101f81:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101f87:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f8a:	89 c2                	mov    %eax,%edx
f0101f8c:	89 f8                	mov    %edi,%eax
f0101f8e:	e8 77 eb ff ff       	call   f0100b0a <check_va2pa>
f0101f93:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101f98:	0f 85 3f 08 00 00    	jne    f01027dd <mem_init+0x14f2>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101f9e:	89 f2                	mov    %esi,%edx
f0101fa0:	89 f8                	mov    %edi,%eax
f0101fa2:	e8 63 eb ff ff       	call   f0100b0a <check_va2pa>
f0101fa7:	85 c0                	test   %eax,%eax
f0101fa9:	0f 85 47 08 00 00    	jne    f01027f6 <mem_init+0x150b>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0101faf:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101fb5:	89 f8                	mov    %edi,%eax
f0101fb7:	e8 4e eb ff ff       	call   f0100b0a <check_va2pa>
f0101fbc:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fbf:	0f 85 4a 08 00 00    	jne    f010280f <mem_init+0x1524>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0101fc5:	83 ec 04             	sub    $0x4,%esp
f0101fc8:	6a 00                	push   $0x0
f0101fca:	53                   	push   %ebx
f0101fcb:	57                   	push   %edi
f0101fcc:	e8 37 f0 ff ff       	call   f0101008 <pgdir_walk>
f0101fd1:	83 c4 10             	add    $0x10,%esp
f0101fd4:	f6 00 1a             	testb  $0x1a,(%eax)
f0101fd7:	0f 84 4b 08 00 00    	je     f0102828 <mem_init+0x153d>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0101fdd:	83 ec 04             	sub    $0x4,%esp
f0101fe0:	6a 00                	push   $0x0
f0101fe2:	53                   	push   %ebx
f0101fe3:	ff 35 5c 82 21 f0    	push   0xf021825c
f0101fe9:	e8 1a f0 ff ff       	call   f0101008 <pgdir_walk>
f0101fee:	8b 00                	mov    (%eax),%eax
f0101ff0:	83 c4 10             	add    $0x10,%esp
f0101ff3:	83 e0 04             	and    $0x4,%eax
f0101ff6:	89 c7                	mov    %eax,%edi
f0101ff8:	0f 85 43 08 00 00    	jne    f0102841 <mem_init+0x1556>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0101ffe:	83 ec 04             	sub    $0x4,%esp
f0102001:	6a 00                	push   $0x0
f0102003:	53                   	push   %ebx
f0102004:	ff 35 5c 82 21 f0    	push   0xf021825c
f010200a:	e8 f9 ef ff ff       	call   f0101008 <pgdir_walk>
f010200f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102015:	83 c4 0c             	add    $0xc,%esp
f0102018:	6a 00                	push   $0x0
f010201a:	ff 75 d4             	push   -0x2c(%ebp)
f010201d:	ff 35 5c 82 21 f0    	push   0xf021825c
f0102023:	e8 e0 ef ff ff       	call   f0101008 <pgdir_walk>
f0102028:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010202e:	83 c4 0c             	add    $0xc,%esp
f0102031:	6a 00                	push   $0x0
f0102033:	56                   	push   %esi
f0102034:	ff 35 5c 82 21 f0    	push   0xf021825c
f010203a:	e8 c9 ef ff ff       	call   f0101008 <pgdir_walk>
f010203f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102045:	c7 04 24 9c 6c 10 f0 	movl   $0xf0106c9c,(%esp)
f010204c:	e8 61 19 00 00       	call   f01039b2 <cprintf>
	boot_map_region(kern_pgdir, UPAGES,ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE) , PADDR(pages), PTE_U | PTE_P);//但其实按照memlayout.h中的图，直接用PTSIZE也一样。因为PTSIZE远超过所需内存了，并且按图来说，其空闲内存也无他用，这里就正常写。
f0102051:	a1 58 82 21 f0       	mov    0xf0218258,%eax
	if ((uint32_t)kva < KERNBASE)
f0102056:	83 c4 10             	add    $0x10,%esp
f0102059:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010205e:	0f 86 f6 07 00 00    	jbe    f010285a <mem_init+0x156f>
f0102064:	8b 15 60 82 21 f0    	mov    0xf0218260,%edx
f010206a:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102071:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102077:	83 ec 08             	sub    $0x8,%esp
f010207a:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010207c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102081:	50                   	push   %eax
f0102082:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102087:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
f010208c:	e8 50 f0 ff ff       	call   f01010e1 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f0102091:	a1 70 82 21 f0       	mov    0xf0218270,%eax
	if ((uint32_t)kva < KERNBASE)
f0102096:	83 c4 10             	add    $0x10,%esp
f0102099:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010209e:	0f 86 cb 07 00 00    	jbe    f010286f <mem_init+0x1584>
f01020a4:	83 ec 08             	sub    $0x8,%esp
f01020a7:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020a9:	05 00 00 00 10       	add    $0x10000000,%eax
f01020ae:	50                   	push   %eax
f01020af:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01020b4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01020b9:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
f01020be:	e8 1e f0 ff ff       	call   f01010e1 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01020c3:	83 c4 10             	add    $0x10,%esp
f01020c6:	b8 00 b0 11 f0       	mov    $0xf011b000,%eax
f01020cb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020d0:	0f 86 ae 07 00 00    	jbe    f0102884 <mem_init+0x1599>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01020d6:	83 ec 08             	sub    $0x8,%esp
f01020d9:	6a 02                	push   $0x2
f01020db:	68 00 b0 11 00       	push   $0x11b000
f01020e0:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020e5:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020ea:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
f01020ef:	e8 ed ef ff ff       	call   f01010e1 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-KERNBASE , 0, PTE_W);
f01020f4:	83 c4 08             	add    $0x8,%esp
f01020f7:	6a 02                	push   $0x2
f01020f9:	6a 00                	push   $0x0
f01020fb:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102100:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102105:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
f010210a:	e8 d2 ef ff ff       	call   f01010e1 <boot_map_region>
f010210f:	c7 45 d0 00 90 21 f0 	movl   $0xf0219000,-0x30(%ebp)
f0102116:	83 c4 10             	add    $0x10,%esp
f0102119:	bb 00 90 21 f0       	mov    $0xf0219000,%ebx
f010211e:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102123:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102129:	0f 86 6a 07 00 00    	jbe    f0102899 <mem_init+0x15ae>
		boot_map_region(kern_pgdir, 
f010212f:	83 ec 08             	sub    $0x8,%esp
f0102132:	6a 02                	push   $0x2
f0102134:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010213a:	50                   	push   %eax
f010213b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102140:	89 f2                	mov    %esi,%edx
f0102142:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
f0102147:	e8 95 ef ff ff       	call   f01010e1 <boot_map_region>
	for(size_t i = 0; i < NCPU; i++) {
f010214c:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102152:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102158:	83 c4 10             	add    $0x10,%esp
f010215b:	81 fb 00 90 25 f0    	cmp    $0xf0259000,%ebx
f0102161:	75 c0                	jne    f0102123 <mem_init+0xe38>
	pgdir = kern_pgdir;
f0102163:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
f0102168:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010216b:	a1 60 82 21 f0       	mov    0xf0218260,%eax
f0102170:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102173:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010217a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010217f:	8b 35 58 82 21 f0    	mov    0xf0218258,%esi
	return (physaddr_t)kva - KERNBASE;
f0102185:	8d 8e 00 00 00 10    	lea    0x10000000(%esi),%ecx
f010218b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f010218e:	89 fb                	mov    %edi,%ebx
f0102190:	89 7d c8             	mov    %edi,-0x38(%ebp)
f0102193:	89 c7                	mov    %eax,%edi
f0102195:	e9 2f 07 00 00       	jmp    f01028c9 <mem_init+0x15de>
	assert(nfree == 0);
f010219a:	68 b3 6b 10 f0       	push   $0xf0106bb3
f010219f:	68 d5 69 10 f0       	push   $0xf01069d5
f01021a4:	68 66 03 00 00       	push   $0x366
f01021a9:	68 af 69 10 f0       	push   $0xf01069af
f01021ae:	e8 8d de ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01021b3:	68 c1 6a 10 f0       	push   $0xf0106ac1
f01021b8:	68 d5 69 10 f0       	push   $0xf01069d5
f01021bd:	68 cc 03 00 00       	push   $0x3cc
f01021c2:	68 af 69 10 f0       	push   $0xf01069af
f01021c7:	e8 74 de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01021cc:	68 d7 6a 10 f0       	push   $0xf0106ad7
f01021d1:	68 d5 69 10 f0       	push   $0xf01069d5
f01021d6:	68 cd 03 00 00       	push   $0x3cd
f01021db:	68 af 69 10 f0       	push   $0xf01069af
f01021e0:	e8 5b de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01021e5:	68 ed 6a 10 f0       	push   $0xf0106aed
f01021ea:	68 d5 69 10 f0       	push   $0xf01069d5
f01021ef:	68 ce 03 00 00       	push   $0x3ce
f01021f4:	68 af 69 10 f0       	push   $0xf01069af
f01021f9:	e8 42 de ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01021fe:	68 03 6b 10 f0       	push   $0xf0106b03
f0102203:	68 d5 69 10 f0       	push   $0xf01069d5
f0102208:	68 d1 03 00 00       	push   $0x3d1
f010220d:	68 af 69 10 f0       	push   $0xf01069af
f0102212:	e8 29 de ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102217:	68 78 6e 10 f0       	push   $0xf0106e78
f010221c:	68 d5 69 10 f0       	push   $0xf01069d5
f0102221:	68 d2 03 00 00       	push   $0x3d2
f0102226:	68 af 69 10 f0       	push   $0xf01069af
f010222b:	e8 10 de ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102230:	68 6c 6b 10 f0       	push   $0xf0106b6c
f0102235:	68 d5 69 10 f0       	push   $0xf01069d5
f010223a:	68 d9 03 00 00       	push   $0x3d9
f010223f:	68 af 69 10 f0       	push   $0xf01069af
f0102244:	e8 f7 dd ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102249:	68 b8 6e 10 f0       	push   $0xf0106eb8
f010224e:	68 d5 69 10 f0       	push   $0xf01069d5
f0102253:	68 dc 03 00 00       	push   $0x3dc
f0102258:	68 af 69 10 f0       	push   $0xf01069af
f010225d:	e8 de dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102262:	68 f0 6e 10 f0       	push   $0xf0106ef0
f0102267:	68 d5 69 10 f0       	push   $0xf01069d5
f010226c:	68 df 03 00 00       	push   $0x3df
f0102271:	68 af 69 10 f0       	push   $0xf01069af
f0102276:	e8 c5 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010227b:	68 20 6f 10 f0       	push   $0xf0106f20
f0102280:	68 d5 69 10 f0       	push   $0xf01069d5
f0102285:	68 e3 03 00 00       	push   $0x3e3
f010228a:	68 af 69 10 f0       	push   $0xf01069af
f010228f:	e8 ac dd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102294:	68 50 6f 10 f0       	push   $0xf0106f50
f0102299:	68 d5 69 10 f0       	push   $0xf01069d5
f010229e:	68 e4 03 00 00       	push   $0x3e4
f01022a3:	68 af 69 10 f0       	push   $0xf01069af
f01022a8:	e8 93 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01022ad:	68 78 6f 10 f0       	push   $0xf0106f78
f01022b2:	68 d5 69 10 f0       	push   $0xf01069d5
f01022b7:	68 e5 03 00 00       	push   $0x3e5
f01022bc:	68 af 69 10 f0       	push   $0xf01069af
f01022c1:	e8 7a dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01022c6:	68 be 6b 10 f0       	push   $0xf0106bbe
f01022cb:	68 d5 69 10 f0       	push   $0xf01069d5
f01022d0:	68 e6 03 00 00       	push   $0x3e6
f01022d5:	68 af 69 10 f0       	push   $0xf01069af
f01022da:	e8 61 dd ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01022df:	68 cf 6b 10 f0       	push   $0xf0106bcf
f01022e4:	68 d5 69 10 f0       	push   $0xf01069d5
f01022e9:	68 e7 03 00 00       	push   $0x3e7
f01022ee:	68 af 69 10 f0       	push   $0xf01069af
f01022f3:	e8 48 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022f8:	68 a8 6f 10 f0       	push   $0xf0106fa8
f01022fd:	68 d5 69 10 f0       	push   $0xf01069d5
f0102302:	68 ea 03 00 00       	push   $0x3ea
f0102307:	68 af 69 10 f0       	push   $0xf01069af
f010230c:	e8 2f dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102311:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0102316:	68 d5 69 10 f0       	push   $0xf01069d5
f010231b:	68 eb 03 00 00       	push   $0x3eb
f0102320:	68 af 69 10 f0       	push   $0xf01069af
f0102325:	e8 16 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010232a:	68 e0 6b 10 f0       	push   $0xf0106be0
f010232f:	68 d5 69 10 f0       	push   $0xf01069d5
f0102334:	68 ec 03 00 00       	push   $0x3ec
f0102339:	68 af 69 10 f0       	push   $0xf01069af
f010233e:	e8 fd dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102343:	68 6c 6b 10 f0       	push   $0xf0106b6c
f0102348:	68 d5 69 10 f0       	push   $0xf01069d5
f010234d:	68 ef 03 00 00       	push   $0x3ef
f0102352:	68 af 69 10 f0       	push   $0xf01069af
f0102357:	e8 e4 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010235c:	68 a8 6f 10 f0       	push   $0xf0106fa8
f0102361:	68 d5 69 10 f0       	push   $0xf01069d5
f0102366:	68 f2 03 00 00       	push   $0x3f2
f010236b:	68 af 69 10 f0       	push   $0xf01069af
f0102370:	e8 cb dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102375:	68 e4 6f 10 f0       	push   $0xf0106fe4
f010237a:	68 d5 69 10 f0       	push   $0xf01069d5
f010237f:	68 f3 03 00 00       	push   $0x3f3
f0102384:	68 af 69 10 f0       	push   $0xf01069af
f0102389:	e8 b2 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010238e:	68 e0 6b 10 f0       	push   $0xf0106be0
f0102393:	68 d5 69 10 f0       	push   $0xf01069d5
f0102398:	68 f4 03 00 00       	push   $0x3f4
f010239d:	68 af 69 10 f0       	push   $0xf01069af
f01023a2:	e8 99 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01023a7:	68 6c 6b 10 f0       	push   $0xf0106b6c
f01023ac:	68 d5 69 10 f0       	push   $0xf01069d5
f01023b1:	68 f8 03 00 00       	push   $0x3f8
f01023b6:	68 af 69 10 f0       	push   $0xf01069af
f01023bb:	e8 80 dc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023c0:	57                   	push   %edi
f01023c1:	68 64 64 10 f0       	push   $0xf0106464
f01023c6:	68 fb 03 00 00       	push   $0x3fb
f01023cb:	68 af 69 10 f0       	push   $0xf01069af
f01023d0:	e8 6b dc ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01023d5:	68 14 70 10 f0       	push   $0xf0107014
f01023da:	68 d5 69 10 f0       	push   $0xf01069d5
f01023df:	68 fc 03 00 00       	push   $0x3fc
f01023e4:	68 af 69 10 f0       	push   $0xf01069af
f01023e9:	e8 52 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01023ee:	68 54 70 10 f0       	push   $0xf0107054
f01023f3:	68 d5 69 10 f0       	push   $0xf01069d5
f01023f8:	68 ff 03 00 00       	push   $0x3ff
f01023fd:	68 af 69 10 f0       	push   $0xf01069af
f0102402:	e8 39 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102407:	68 e4 6f 10 f0       	push   $0xf0106fe4
f010240c:	68 d5 69 10 f0       	push   $0xf01069d5
f0102411:	68 00 04 00 00       	push   $0x400
f0102416:	68 af 69 10 f0       	push   $0xf01069af
f010241b:	e8 20 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102420:	68 e0 6b 10 f0       	push   $0xf0106be0
f0102425:	68 d5 69 10 f0       	push   $0xf01069d5
f010242a:	68 01 04 00 00       	push   $0x401
f010242f:	68 af 69 10 f0       	push   $0xf01069af
f0102434:	e8 07 dc ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102439:	68 94 70 10 f0       	push   $0xf0107094
f010243e:	68 d5 69 10 f0       	push   $0xf01069d5
f0102443:	68 02 04 00 00       	push   $0x402
f0102448:	68 af 69 10 f0       	push   $0xf01069af
f010244d:	e8 ee db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102452:	68 f1 6b 10 f0       	push   $0xf0106bf1
f0102457:	68 d5 69 10 f0       	push   $0xf01069d5
f010245c:	68 03 04 00 00       	push   $0x403
f0102461:	68 af 69 10 f0       	push   $0xf01069af
f0102466:	e8 d5 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010246b:	68 a8 6f 10 f0       	push   $0xf0106fa8
f0102470:	68 d5 69 10 f0       	push   $0xf01069d5
f0102475:	68 06 04 00 00       	push   $0x406
f010247a:	68 af 69 10 f0       	push   $0xf01069af
f010247f:	e8 bc db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102484:	68 c8 70 10 f0       	push   $0xf01070c8
f0102489:	68 d5 69 10 f0       	push   $0xf01069d5
f010248e:	68 07 04 00 00       	push   $0x407
f0102493:	68 af 69 10 f0       	push   $0xf01069af
f0102498:	e8 a3 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010249d:	68 fc 70 10 f0       	push   $0xf01070fc
f01024a2:	68 d5 69 10 f0       	push   $0xf01069d5
f01024a7:	68 08 04 00 00       	push   $0x408
f01024ac:	68 af 69 10 f0       	push   $0xf01069af
f01024b1:	e8 8a db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01024b6:	68 34 71 10 f0       	push   $0xf0107134
f01024bb:	68 d5 69 10 f0       	push   $0xf01069d5
f01024c0:	68 0b 04 00 00       	push   $0x40b
f01024c5:	68 af 69 10 f0       	push   $0xf01069af
f01024ca:	e8 71 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01024cf:	68 6c 71 10 f0       	push   $0xf010716c
f01024d4:	68 d5 69 10 f0       	push   $0xf01069d5
f01024d9:	68 0e 04 00 00       	push   $0x40e
f01024de:	68 af 69 10 f0       	push   $0xf01069af
f01024e3:	e8 58 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024e8:	68 fc 70 10 f0       	push   $0xf01070fc
f01024ed:	68 d5 69 10 f0       	push   $0xf01069d5
f01024f2:	68 0f 04 00 00       	push   $0x40f
f01024f7:	68 af 69 10 f0       	push   $0xf01069af
f01024fc:	e8 3f db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102501:	68 a8 71 10 f0       	push   $0xf01071a8
f0102506:	68 d5 69 10 f0       	push   $0xf01069d5
f010250b:	68 12 04 00 00       	push   $0x412
f0102510:	68 af 69 10 f0       	push   $0xf01069af
f0102515:	e8 26 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010251a:	68 d4 71 10 f0       	push   $0xf01071d4
f010251f:	68 d5 69 10 f0       	push   $0xf01069d5
f0102524:	68 13 04 00 00       	push   $0x413
f0102529:	68 af 69 10 f0       	push   $0xf01069af
f010252e:	e8 0d db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102533:	68 07 6c 10 f0       	push   $0xf0106c07
f0102538:	68 d5 69 10 f0       	push   $0xf01069d5
f010253d:	68 15 04 00 00       	push   $0x415
f0102542:	68 af 69 10 f0       	push   $0xf01069af
f0102547:	e8 f4 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010254c:	68 18 6c 10 f0       	push   $0xf0106c18
f0102551:	68 d5 69 10 f0       	push   $0xf01069d5
f0102556:	68 16 04 00 00       	push   $0x416
f010255b:	68 af 69 10 f0       	push   $0xf01069af
f0102560:	e8 db da ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102565:	68 04 72 10 f0       	push   $0xf0107204
f010256a:	68 d5 69 10 f0       	push   $0xf01069d5
f010256f:	68 19 04 00 00       	push   $0x419
f0102574:	68 af 69 10 f0       	push   $0xf01069af
f0102579:	e8 c2 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010257e:	68 28 72 10 f0       	push   $0xf0107228
f0102583:	68 d5 69 10 f0       	push   $0xf01069d5
f0102588:	68 1d 04 00 00       	push   $0x41d
f010258d:	68 af 69 10 f0       	push   $0xf01069af
f0102592:	e8 a9 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102597:	68 d4 71 10 f0       	push   $0xf01071d4
f010259c:	68 d5 69 10 f0       	push   $0xf01069d5
f01025a1:	68 1e 04 00 00       	push   $0x41e
f01025a6:	68 af 69 10 f0       	push   $0xf01069af
f01025ab:	e8 90 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01025b0:	68 be 6b 10 f0       	push   $0xf0106bbe
f01025b5:	68 d5 69 10 f0       	push   $0xf01069d5
f01025ba:	68 1f 04 00 00       	push   $0x41f
f01025bf:	68 af 69 10 f0       	push   $0xf01069af
f01025c4:	e8 77 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025c9:	68 18 6c 10 f0       	push   $0xf0106c18
f01025ce:	68 d5 69 10 f0       	push   $0xf01069d5
f01025d3:	68 20 04 00 00       	push   $0x420
f01025d8:	68 af 69 10 f0       	push   $0xf01069af
f01025dd:	e8 5e da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01025e2:	68 4c 72 10 f0       	push   $0xf010724c
f01025e7:	68 d5 69 10 f0       	push   $0xf01069d5
f01025ec:	68 23 04 00 00       	push   $0x423
f01025f1:	68 af 69 10 f0       	push   $0xf01069af
f01025f6:	e8 45 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01025fb:	68 29 6c 10 f0       	push   $0xf0106c29
f0102600:	68 d5 69 10 f0       	push   $0xf01069d5
f0102605:	68 24 04 00 00       	push   $0x424
f010260a:	68 af 69 10 f0       	push   $0xf01069af
f010260f:	e8 2c da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102614:	68 35 6c 10 f0       	push   $0xf0106c35
f0102619:	68 d5 69 10 f0       	push   $0xf01069d5
f010261e:	68 25 04 00 00       	push   $0x425
f0102623:	68 af 69 10 f0       	push   $0xf01069af
f0102628:	e8 13 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010262d:	68 28 72 10 f0       	push   $0xf0107228
f0102632:	68 d5 69 10 f0       	push   $0xf01069d5
f0102637:	68 29 04 00 00       	push   $0x429
f010263c:	68 af 69 10 f0       	push   $0xf01069af
f0102641:	e8 fa d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102646:	68 84 72 10 f0       	push   $0xf0107284
f010264b:	68 d5 69 10 f0       	push   $0xf01069d5
f0102650:	68 2a 04 00 00       	push   $0x42a
f0102655:	68 af 69 10 f0       	push   $0xf01069af
f010265a:	e8 e1 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010265f:	68 4a 6c 10 f0       	push   $0xf0106c4a
f0102664:	68 d5 69 10 f0       	push   $0xf01069d5
f0102669:	68 2b 04 00 00       	push   $0x42b
f010266e:	68 af 69 10 f0       	push   $0xf01069af
f0102673:	e8 c8 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102678:	68 18 6c 10 f0       	push   $0xf0106c18
f010267d:	68 d5 69 10 f0       	push   $0xf01069d5
f0102682:	68 2c 04 00 00       	push   $0x42c
f0102687:	68 af 69 10 f0       	push   $0xf01069af
f010268c:	e8 af d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102691:	68 ac 72 10 f0       	push   $0xf01072ac
f0102696:	68 d5 69 10 f0       	push   $0xf01069d5
f010269b:	68 2f 04 00 00       	push   $0x42f
f01026a0:	68 af 69 10 f0       	push   $0xf01069af
f01026a5:	e8 96 d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01026aa:	68 6c 6b 10 f0       	push   $0xf0106b6c
f01026af:	68 d5 69 10 f0       	push   $0xf01069d5
f01026b4:	68 32 04 00 00       	push   $0x432
f01026b9:	68 af 69 10 f0       	push   $0xf01069af
f01026be:	e8 7d d9 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026c3:	68 50 6f 10 f0       	push   $0xf0106f50
f01026c8:	68 d5 69 10 f0       	push   $0xf01069d5
f01026cd:	68 35 04 00 00       	push   $0x435
f01026d2:	68 af 69 10 f0       	push   $0xf01069af
f01026d7:	e8 64 d9 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01026dc:	68 cf 6b 10 f0       	push   $0xf0106bcf
f01026e1:	68 d5 69 10 f0       	push   $0xf01069d5
f01026e6:	68 37 04 00 00       	push   $0x437
f01026eb:	68 af 69 10 f0       	push   $0xf01069af
f01026f0:	e8 4b d9 ff ff       	call   f0100040 <_panic>
f01026f5:	57                   	push   %edi
f01026f6:	68 64 64 10 f0       	push   $0xf0106464
f01026fb:	68 3e 04 00 00       	push   $0x43e
f0102700:	68 af 69 10 f0       	push   $0xf01069af
f0102705:	e8 36 d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010270a:	68 5b 6c 10 f0       	push   $0xf0106c5b
f010270f:	68 d5 69 10 f0       	push   $0xf01069d5
f0102714:	68 3f 04 00 00       	push   $0x43f
f0102719:	68 af 69 10 f0       	push   $0xf01069af
f010271e:	e8 1d d9 ff ff       	call   f0100040 <_panic>
f0102723:	51                   	push   %ecx
f0102724:	68 64 64 10 f0       	push   $0xf0106464
f0102729:	6a 5a                	push   $0x5a
f010272b:	68 bb 69 10 f0       	push   $0xf01069bb
f0102730:	e8 0b d9 ff ff       	call   f0100040 <_panic>
f0102735:	52                   	push   %edx
f0102736:	68 64 64 10 f0       	push   $0xf0106464
f010273b:	6a 5a                	push   $0x5a
f010273d:	68 bb 69 10 f0       	push   $0xf01069bb
f0102742:	e8 f9 d8 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102747:	68 73 6c 10 f0       	push   $0xf0106c73
f010274c:	68 d5 69 10 f0       	push   $0xf01069d5
f0102751:	68 49 04 00 00       	push   $0x449
f0102756:	68 af 69 10 f0       	push   $0xf01069af
f010275b:	e8 e0 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102760:	68 d0 72 10 f0       	push   $0xf01072d0
f0102765:	68 d5 69 10 f0       	push   $0xf01069d5
f010276a:	68 59 04 00 00       	push   $0x459
f010276f:	68 af 69 10 f0       	push   $0xf01069af
f0102774:	e8 c7 d8 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102779:	68 f8 72 10 f0       	push   $0xf01072f8
f010277e:	68 d5 69 10 f0       	push   $0xf01069d5
f0102783:	68 5a 04 00 00       	push   $0x45a
f0102788:	68 af 69 10 f0       	push   $0xf01069af
f010278d:	e8 ae d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102792:	68 20 73 10 f0       	push   $0xf0107320
f0102797:	68 d5 69 10 f0       	push   $0xf01069d5
f010279c:	68 5c 04 00 00       	push   $0x45c
f01027a1:	68 af 69 10 f0       	push   $0xf01069af
f01027a6:	e8 95 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f01027ab:	68 8a 6c 10 f0       	push   $0xf0106c8a
f01027b0:	68 d5 69 10 f0       	push   $0xf01069d5
f01027b5:	68 5e 04 00 00       	push   $0x45e
f01027ba:	68 af 69 10 f0       	push   $0xf01069af
f01027bf:	e8 7c d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01027c4:	68 48 73 10 f0       	push   $0xf0107348
f01027c9:	68 d5 69 10 f0       	push   $0xf01069d5
f01027ce:	68 60 04 00 00       	push   $0x460
f01027d3:	68 af 69 10 f0       	push   $0xf01069af
f01027d8:	e8 63 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01027dd:	68 6c 73 10 f0       	push   $0xf010736c
f01027e2:	68 d5 69 10 f0       	push   $0xf01069d5
f01027e7:	68 61 04 00 00       	push   $0x461
f01027ec:	68 af 69 10 f0       	push   $0xf01069af
f01027f1:	e8 4a d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01027f6:	68 9c 73 10 f0       	push   $0xf010739c
f01027fb:	68 d5 69 10 f0       	push   $0xf01069d5
f0102800:	68 62 04 00 00       	push   $0x462
f0102805:	68 af 69 10 f0       	push   $0xf01069af
f010280a:	e8 31 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010280f:	68 c0 73 10 f0       	push   $0xf01073c0
f0102814:	68 d5 69 10 f0       	push   $0xf01069d5
f0102819:	68 63 04 00 00       	push   $0x463
f010281e:	68 af 69 10 f0       	push   $0xf01069af
f0102823:	e8 18 d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102828:	68 ec 73 10 f0       	push   $0xf01073ec
f010282d:	68 d5 69 10 f0       	push   $0xf01069d5
f0102832:	68 65 04 00 00       	push   $0x465
f0102837:	68 af 69 10 f0       	push   $0xf01069af
f010283c:	e8 ff d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102841:	68 30 74 10 f0       	push   $0xf0107430
f0102846:	68 d5 69 10 f0       	push   $0xf01069d5
f010284b:	68 66 04 00 00       	push   $0x466
f0102850:	68 af 69 10 f0       	push   $0xf01069af
f0102855:	e8 e6 d7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010285a:	50                   	push   %eax
f010285b:	68 88 64 10 f0       	push   $0xf0106488
f0102860:	68 cb 00 00 00       	push   $0xcb
f0102865:	68 af 69 10 f0       	push   $0xf01069af
f010286a:	e8 d1 d7 ff ff       	call   f0100040 <_panic>
f010286f:	50                   	push   %eax
f0102870:	68 88 64 10 f0       	push   $0xf0106488
f0102875:	68 d5 00 00 00       	push   $0xd5
f010287a:	68 af 69 10 f0       	push   $0xf01069af
f010287f:	e8 bc d7 ff ff       	call   f0100040 <_panic>
f0102884:	50                   	push   %eax
f0102885:	68 88 64 10 f0       	push   $0xf0106488
f010288a:	68 e3 00 00 00       	push   $0xe3
f010288f:	68 af 69 10 f0       	push   $0xf01069af
f0102894:	e8 a7 d7 ff ff       	call   f0100040 <_panic>
f0102899:	53                   	push   %ebx
f010289a:	68 88 64 10 f0       	push   $0xf0106488
f010289f:	68 2b 01 00 00       	push   $0x12b
f01028a4:	68 af 69 10 f0       	push   $0xf01069af
f01028a9:	e8 92 d7 ff ff       	call   f0100040 <_panic>
f01028ae:	56                   	push   %esi
f01028af:	68 88 64 10 f0       	push   $0xf0106488
f01028b4:	68 7e 03 00 00       	push   $0x37e
f01028b9:	68 af 69 10 f0       	push   $0xf01069af
f01028be:	e8 7d d7 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f01028c3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028c9:	39 df                	cmp    %ebx,%edi
f01028cb:	76 39                	jbe    f0102906 <mem_init+0x161b>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028cd:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01028d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028d6:	e8 2f e2 ff ff       	call   f0100b0a <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01028db:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01028e1:	76 cb                	jbe    f01028ae <mem_init+0x15c3>
f01028e3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01028e6:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01028e9:	39 d0                	cmp    %edx,%eax
f01028eb:	74 d6                	je     f01028c3 <mem_init+0x15d8>
f01028ed:	68 64 74 10 f0       	push   $0xf0107464
f01028f2:	68 d5 69 10 f0       	push   $0xf01069d5
f01028f7:	68 7e 03 00 00       	push   $0x37e
f01028fc:	68 af 69 10 f0       	push   $0xf01069af
f0102901:	e8 3a d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102906:	8b 35 70 82 21 f0    	mov    0xf0218270,%esi
f010290c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102911:	8d 86 00 00 40 21    	lea    0x21400000(%esi),%eax
f0102917:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010291a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010291d:	89 da                	mov    %ebx,%edx
f010291f:	89 f8                	mov    %edi,%eax
f0102921:	e8 e4 e1 ff ff       	call   f0100b0a <check_va2pa>
f0102926:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010292c:	76 46                	jbe    f0102974 <mem_init+0x1689>
f010292e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102931:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102934:	39 d0                	cmp    %edx,%eax
f0102936:	75 51                	jne    f0102989 <mem_init+0x169e>
	for (i = 0; i < n; i += PGSIZE)
f0102938:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010293e:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102944:	75 d7                	jne    f010291d <mem_init+0x1632>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102946:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102949:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010294c:	c1 e6 0c             	shl    $0xc,%esi
f010294f:	89 fb                	mov    %edi,%ebx
f0102951:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0102954:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102957:	39 f3                	cmp    %esi,%ebx
f0102959:	73 60                	jae    f01029bb <mem_init+0x16d0>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010295b:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102961:	89 f8                	mov    %edi,%eax
f0102963:	e8 a2 e1 ff ff       	call   f0100b0a <check_va2pa>
f0102968:	39 c3                	cmp    %eax,%ebx
f010296a:	75 36                	jne    f01029a2 <mem_init+0x16b7>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010296c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102972:	eb e3                	jmp    f0102957 <mem_init+0x166c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102974:	56                   	push   %esi
f0102975:	68 88 64 10 f0       	push   $0xf0106488
f010297a:	68 83 03 00 00       	push   $0x383
f010297f:	68 af 69 10 f0       	push   $0xf01069af
f0102984:	e8 b7 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102989:	68 98 74 10 f0       	push   $0xf0107498
f010298e:	68 d5 69 10 f0       	push   $0xf01069d5
f0102993:	68 83 03 00 00       	push   $0x383
f0102998:	68 af 69 10 f0       	push   $0xf01069af
f010299d:	e8 9e d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029a2:	68 cc 74 10 f0       	push   $0xf01074cc
f01029a7:	68 d5 69 10 f0       	push   $0xf01069d5
f01029ac:	68 87 03 00 00       	push   $0x387
f01029b1:	68 af 69 10 f0       	push   $0xf01069af
f01029b6:	e8 85 d6 ff ff       	call   f0100040 <_panic>
f01029bb:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01029be:	c7 45 c0 00 90 22 00 	movl   $0x229000,-0x40(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029c5:	c7 45 c4 00 00 00 f0 	movl   $0xf0000000,-0x3c(%ebp)
f01029cc:	c7 45 c8 00 80 ff ef 	movl   $0xefff8000,-0x38(%ebp)
f01029d3:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f01029d6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01029d9:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f01029dc:	8d b3 00 80 ff ff    	lea    -0x8000(%ebx),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01029e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01029e5:	89 45 b8             	mov    %eax,-0x48(%ebp)
f01029e8:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01029eb:	05 00 80 ff 0f       	add    $0xfff8000,%eax
f01029f0:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01029f3:	89 75 bc             	mov    %esi,-0x44(%ebp)
f01029f6:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01029f9:	89 da                	mov    %ebx,%edx
f01029fb:	89 f8                	mov    %edi,%eax
f01029fd:	e8 08 e1 ff ff       	call   f0100b0a <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102a02:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102a09:	76 67                	jbe    f0102a72 <mem_init+0x1787>
f0102a0b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102a0e:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102a11:	39 d0                	cmp    %edx,%eax
f0102a13:	75 74                	jne    f0102a89 <mem_init+0x179e>
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a15:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a1b:	39 f3                	cmp    %esi,%ebx
f0102a1d:	75 da                	jne    f01029f9 <mem_init+0x170e>
f0102a1f:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0102a22:	8b 5d c8             	mov    -0x38(%ebp),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a25:	89 f2                	mov    %esi,%edx
f0102a27:	89 f8                	mov    %edi,%eax
f0102a29:	e8 dc e0 ff ff       	call   f0100b0a <check_va2pa>
f0102a2e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a31:	75 6f                	jne    f0102aa2 <mem_init+0x17b7>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a33:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102a39:	39 de                	cmp    %ebx,%esi
f0102a3b:	75 e8                	jne    f0102a25 <mem_init+0x173a>
	for (n = 0; n < NCPU; n++) {
f0102a3d:	89 d8                	mov    %ebx,%eax
f0102a3f:	2d 00 00 01 00       	sub    $0x10000,%eax
f0102a44:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102a47:	81 6d c4 00 00 01 00 	subl   $0x10000,-0x3c(%ebp)
f0102a4e:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102a55:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102a58:	81 45 c0 00 80 01 00 	addl   $0x18000,-0x40(%ebp)
f0102a5f:	3d 00 90 25 f0       	cmp    $0xf0259000,%eax
f0102a64:	0f 85 6f ff ff ff    	jne    f01029d9 <mem_init+0x16ee>
f0102a6a:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0102a6d:	e9 84 00 00 00       	jmp    f0102af6 <mem_init+0x180b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a72:	ff 75 b8             	push   -0x48(%ebp)
f0102a75:	68 88 64 10 f0       	push   $0xf0106488
f0102a7a:	68 8f 03 00 00       	push   $0x38f
f0102a7f:	68 af 69 10 f0       	push   $0xf01069af
f0102a84:	e8 b7 d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a89:	68 f4 74 10 f0       	push   $0xf01074f4
f0102a8e:	68 d5 69 10 f0       	push   $0xf01069d5
f0102a93:	68 8e 03 00 00       	push   $0x38e
f0102a98:	68 af 69 10 f0       	push   $0xf01069af
f0102a9d:	e8 9e d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102aa2:	68 3c 75 10 f0       	push   $0xf010753c
f0102aa7:	68 d5 69 10 f0       	push   $0xf01069d5
f0102aac:	68 91 03 00 00       	push   $0x391
f0102ab1:	68 af 69 10 f0       	push   $0xf01069af
f0102ab6:	e8 85 d5 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102abb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102abe:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102ac2:	75 4e                	jne    f0102b12 <mem_init+0x1827>
f0102ac4:	68 b5 6c 10 f0       	push   $0xf0106cb5
f0102ac9:	68 d5 69 10 f0       	push   $0xf01069d5
f0102ace:	68 9c 03 00 00       	push   $0x39c
f0102ad3:	68 af 69 10 f0       	push   $0xf01069af
f0102ad8:	e8 63 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102add:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ae0:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f0102ae3:	a8 01                	test   $0x1,%al
f0102ae5:	74 30                	je     f0102b17 <mem_init+0x182c>
				assert(pgdir[i] & PTE_W);
f0102ae7:	a8 02                	test   $0x2,%al
f0102ae9:	74 45                	je     f0102b30 <mem_init+0x1845>
	for (i = 0; i < NPDENTRIES; i++) {
f0102aeb:	83 c7 01             	add    $0x1,%edi
f0102aee:	81 ff 00 04 00 00    	cmp    $0x400,%edi
f0102af4:	74 6c                	je     f0102b62 <mem_init+0x1877>
		switch (i) {
f0102af6:	8d 87 45 fc ff ff    	lea    -0x3bb(%edi),%eax
f0102afc:	83 f8 04             	cmp    $0x4,%eax
f0102aff:	76 ba                	jbe    f0102abb <mem_init+0x17d0>
			if (i >= PDX(KERNBASE)) {
f0102b01:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102b07:	77 d4                	ja     f0102add <mem_init+0x17f2>
				assert(pgdir[i] == 0);
f0102b09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b0c:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f0102b10:	75 37                	jne    f0102b49 <mem_init+0x185e>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b12:	83 c7 01             	add    $0x1,%edi
f0102b15:	eb df                	jmp    f0102af6 <mem_init+0x180b>
				assert(pgdir[i] & PTE_P);
f0102b17:	68 b5 6c 10 f0       	push   $0xf0106cb5
f0102b1c:	68 d5 69 10 f0       	push   $0xf01069d5
f0102b21:	68 a0 03 00 00       	push   $0x3a0
f0102b26:	68 af 69 10 f0       	push   $0xf01069af
f0102b2b:	e8 10 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b30:	68 c6 6c 10 f0       	push   $0xf0106cc6
f0102b35:	68 d5 69 10 f0       	push   $0xf01069d5
f0102b3a:	68 a1 03 00 00       	push   $0x3a1
f0102b3f:	68 af 69 10 f0       	push   $0xf01069af
f0102b44:	e8 f7 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102b49:	68 d7 6c 10 f0       	push   $0xf0106cd7
f0102b4e:	68 d5 69 10 f0       	push   $0xf01069d5
f0102b53:	68 a3 03 00 00       	push   $0x3a3
f0102b58:	68 af 69 10 f0       	push   $0xf01069af
f0102b5d:	e8 de d4 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b62:	83 ec 0c             	sub    $0xc,%esp
f0102b65:	68 60 75 10 f0       	push   $0xf0107560
f0102b6a:	e8 43 0e 00 00       	call   f01039b2 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b6f:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102b74:	83 c4 10             	add    $0x10,%esp
f0102b77:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b7c:	0f 86 03 02 00 00    	jbe    f0102d85 <mem_init+0x1a9a>
	return (physaddr_t)kva - KERNBASE;
f0102b82:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f0102b87:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b8a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b8f:	e8 d9 df ff ff       	call   f0100b6d <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b94:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b97:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b9a:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b9f:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102ba2:	83 ec 0c             	sub    $0xc,%esp
f0102ba5:	6a 00                	push   $0x0
f0102ba7:	e8 68 e3 ff ff       	call   f0100f14 <page_alloc>
f0102bac:	89 c3                	mov    %eax,%ebx
f0102bae:	83 c4 10             	add    $0x10,%esp
f0102bb1:	85 c0                	test   %eax,%eax
f0102bb3:	0f 84 e1 01 00 00    	je     f0102d9a <mem_init+0x1aaf>
	assert((pp1 = page_alloc(0)));
f0102bb9:	83 ec 0c             	sub    $0xc,%esp
f0102bbc:	6a 00                	push   $0x0
f0102bbe:	e8 51 e3 ff ff       	call   f0100f14 <page_alloc>
f0102bc3:	89 c7                	mov    %eax,%edi
f0102bc5:	83 c4 10             	add    $0x10,%esp
f0102bc8:	85 c0                	test   %eax,%eax
f0102bca:	0f 84 e3 01 00 00    	je     f0102db3 <mem_init+0x1ac8>
	assert((pp2 = page_alloc(0)));
f0102bd0:	83 ec 0c             	sub    $0xc,%esp
f0102bd3:	6a 00                	push   $0x0
f0102bd5:	e8 3a e3 ff ff       	call   f0100f14 <page_alloc>
f0102bda:	89 c6                	mov    %eax,%esi
f0102bdc:	83 c4 10             	add    $0x10,%esp
f0102bdf:	85 c0                	test   %eax,%eax
f0102be1:	0f 84 e5 01 00 00    	je     f0102dcc <mem_init+0x1ae1>
	page_free(pp0);
f0102be7:	83 ec 0c             	sub    $0xc,%esp
f0102bea:	53                   	push   %ebx
f0102beb:	e8 99 e3 ff ff       	call   f0100f89 <page_free>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102bf0:	89 f8                	mov    %edi,%eax
f0102bf2:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f0102bf8:	c1 f8 03             	sar    $0x3,%eax
f0102bfb:	89 c2                	mov    %eax,%edx
f0102bfd:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c00:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c05:	83 c4 10             	add    $0x10,%esp
f0102c08:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f0102c0e:	0f 83 d1 01 00 00    	jae    f0102de5 <mem_init+0x1afa>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c14:	83 ec 04             	sub    $0x4,%esp
f0102c17:	68 00 10 00 00       	push   $0x1000
f0102c1c:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c1e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c24:	52                   	push   %edx
f0102c25:	e8 ed 2b 00 00       	call   f0105817 <memset>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102c2a:	89 f0                	mov    %esi,%eax
f0102c2c:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f0102c32:	c1 f8 03             	sar    $0x3,%eax
f0102c35:	89 c2                	mov    %eax,%edx
f0102c37:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c3a:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c3f:	83 c4 10             	add    $0x10,%esp
f0102c42:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f0102c48:	0f 83 a9 01 00 00    	jae    f0102df7 <mem_init+0x1b0c>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c4e:	83 ec 04             	sub    $0x4,%esp
f0102c51:	68 00 10 00 00       	push   $0x1000
f0102c56:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c58:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c5e:	52                   	push   %edx
f0102c5f:	e8 b3 2b 00 00       	call   f0105817 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c64:	6a 02                	push   $0x2
f0102c66:	68 00 10 00 00       	push   $0x1000
f0102c6b:	57                   	push   %edi
f0102c6c:	ff 35 5c 82 21 f0    	push   0xf021825c
f0102c72:	e8 ab e5 ff ff       	call   f0101222 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c77:	83 c4 20             	add    $0x20,%esp
f0102c7a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c7f:	0f 85 84 01 00 00    	jne    f0102e09 <mem_init+0x1b1e>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c85:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c8c:	01 01 01 
f0102c8f:	0f 85 8d 01 00 00    	jne    f0102e22 <mem_init+0x1b37>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c95:	6a 02                	push   $0x2
f0102c97:	68 00 10 00 00       	push   $0x1000
f0102c9c:	56                   	push   %esi
f0102c9d:	ff 35 5c 82 21 f0    	push   0xf021825c
f0102ca3:	e8 7a e5 ff ff       	call   f0101222 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ca8:	83 c4 10             	add    $0x10,%esp
f0102cab:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cb2:	02 02 02 
f0102cb5:	0f 85 80 01 00 00    	jne    f0102e3b <mem_init+0x1b50>
	assert(pp2->pp_ref == 1);
f0102cbb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cc0:	0f 85 8e 01 00 00    	jne    f0102e54 <mem_init+0x1b69>
	assert(pp1->pp_ref == 0);
f0102cc6:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102ccb:	0f 85 9c 01 00 00    	jne    f0102e6d <mem_init+0x1b82>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102cd1:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cd8:	03 03 03 
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102cdb:	89 f0                	mov    %esi,%eax
f0102cdd:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f0102ce3:	c1 f8 03             	sar    $0x3,%eax
f0102ce6:	89 c2                	mov    %eax,%edx
f0102ce8:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102ceb:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102cf0:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f0102cf6:	0f 83 8a 01 00 00    	jae    f0102e86 <mem_init+0x1b9b>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102cfc:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102d03:	03 03 03 
f0102d06:	0f 85 8c 01 00 00    	jne    f0102e98 <mem_init+0x1bad>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d0c:	83 ec 08             	sub    $0x8,%esp
f0102d0f:	68 00 10 00 00       	push   $0x1000
f0102d14:	ff 35 5c 82 21 f0    	push   0xf021825c
f0102d1a:	e8 bd e4 ff ff       	call   f01011dc <page_remove>
	assert(pp2->pp_ref == 0);
f0102d1f:	83 c4 10             	add    $0x10,%esp
f0102d22:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d27:	0f 85 84 01 00 00    	jne    f0102eb1 <mem_init+0x1bc6>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d2d:	8b 0d 5c 82 21 f0    	mov    0xf021825c,%ecx
f0102d33:	8b 11                	mov    (%ecx),%edx
f0102d35:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102d3b:	89 d8                	mov    %ebx,%eax
f0102d3d:	2b 05 58 82 21 f0    	sub    0xf0218258,%eax
f0102d43:	c1 f8 03             	sar    $0x3,%eax
f0102d46:	c1 e0 0c             	shl    $0xc,%eax
f0102d49:	39 c2                	cmp    %eax,%edx
f0102d4b:	0f 85 79 01 00 00    	jne    f0102eca <mem_init+0x1bdf>
	kern_pgdir[0] = 0;
f0102d51:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d57:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d5c:	0f 85 81 01 00 00    	jne    f0102ee3 <mem_init+0x1bf8>
	pp0->pp_ref = 0;
f0102d62:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d68:	83 ec 0c             	sub    $0xc,%esp
f0102d6b:	53                   	push   %ebx
f0102d6c:	e8 18 e2 ff ff       	call   f0100f89 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d71:	c7 04 24 f4 75 10 f0 	movl   $0xf01075f4,(%esp)
f0102d78:	e8 35 0c 00 00       	call   f01039b2 <cprintf>
}
f0102d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d80:	5b                   	pop    %ebx
f0102d81:	5e                   	pop    %esi
f0102d82:	5f                   	pop    %edi
f0102d83:	5d                   	pop    %ebp
f0102d84:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d85:	50                   	push   %eax
f0102d86:	68 88 64 10 f0       	push   $0xf0106488
f0102d8b:	68 fe 00 00 00       	push   $0xfe
f0102d90:	68 af 69 10 f0       	push   $0xf01069af
f0102d95:	e8 a6 d2 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102d9a:	68 c1 6a 10 f0       	push   $0xf0106ac1
f0102d9f:	68 d5 69 10 f0       	push   $0xf01069d5
f0102da4:	68 7b 04 00 00       	push   $0x47b
f0102da9:	68 af 69 10 f0       	push   $0xf01069af
f0102dae:	e8 8d d2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102db3:	68 d7 6a 10 f0       	push   $0xf0106ad7
f0102db8:	68 d5 69 10 f0       	push   $0xf01069d5
f0102dbd:	68 7c 04 00 00       	push   $0x47c
f0102dc2:	68 af 69 10 f0       	push   $0xf01069af
f0102dc7:	e8 74 d2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102dcc:	68 ed 6a 10 f0       	push   $0xf0106aed
f0102dd1:	68 d5 69 10 f0       	push   $0xf01069d5
f0102dd6:	68 7d 04 00 00       	push   $0x47d
f0102ddb:	68 af 69 10 f0       	push   $0xf01069af
f0102de0:	e8 5b d2 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102de5:	52                   	push   %edx
f0102de6:	68 64 64 10 f0       	push   $0xf0106464
f0102deb:	6a 5a                	push   $0x5a
f0102ded:	68 bb 69 10 f0       	push   $0xf01069bb
f0102df2:	e8 49 d2 ff ff       	call   f0100040 <_panic>
f0102df7:	52                   	push   %edx
f0102df8:	68 64 64 10 f0       	push   $0xf0106464
f0102dfd:	6a 5a                	push   $0x5a
f0102dff:	68 bb 69 10 f0       	push   $0xf01069bb
f0102e04:	e8 37 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102e09:	68 be 6b 10 f0       	push   $0xf0106bbe
f0102e0e:	68 d5 69 10 f0       	push   $0xf01069d5
f0102e13:	68 82 04 00 00       	push   $0x482
f0102e18:	68 af 69 10 f0       	push   $0xf01069af
f0102e1d:	e8 1e d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e22:	68 80 75 10 f0       	push   $0xf0107580
f0102e27:	68 d5 69 10 f0       	push   $0xf01069d5
f0102e2c:	68 83 04 00 00       	push   $0x483
f0102e31:	68 af 69 10 f0       	push   $0xf01069af
f0102e36:	e8 05 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e3b:	68 a4 75 10 f0       	push   $0xf01075a4
f0102e40:	68 d5 69 10 f0       	push   $0xf01069d5
f0102e45:	68 85 04 00 00       	push   $0x485
f0102e4a:	68 af 69 10 f0       	push   $0xf01069af
f0102e4f:	e8 ec d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102e54:	68 e0 6b 10 f0       	push   $0xf0106be0
f0102e59:	68 d5 69 10 f0       	push   $0xf01069d5
f0102e5e:	68 86 04 00 00       	push   $0x486
f0102e63:	68 af 69 10 f0       	push   $0xf01069af
f0102e68:	e8 d3 d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102e6d:	68 4a 6c 10 f0       	push   $0xf0106c4a
f0102e72:	68 d5 69 10 f0       	push   $0xf01069d5
f0102e77:	68 87 04 00 00       	push   $0x487
f0102e7c:	68 af 69 10 f0       	push   $0xf01069af
f0102e81:	e8 ba d1 ff ff       	call   f0100040 <_panic>
f0102e86:	52                   	push   %edx
f0102e87:	68 64 64 10 f0       	push   $0xf0106464
f0102e8c:	6a 5a                	push   $0x5a
f0102e8e:	68 bb 69 10 f0       	push   $0xf01069bb
f0102e93:	e8 a8 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e98:	68 c8 75 10 f0       	push   $0xf01075c8
f0102e9d:	68 d5 69 10 f0       	push   $0xf01069d5
f0102ea2:	68 89 04 00 00       	push   $0x489
f0102ea7:	68 af 69 10 f0       	push   $0xf01069af
f0102eac:	e8 8f d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102eb1:	68 18 6c 10 f0       	push   $0xf0106c18
f0102eb6:	68 d5 69 10 f0       	push   $0xf01069d5
f0102ebb:	68 8b 04 00 00       	push   $0x48b
f0102ec0:	68 af 69 10 f0       	push   $0xf01069af
f0102ec5:	e8 76 d1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102eca:	68 50 6f 10 f0       	push   $0xf0106f50
f0102ecf:	68 d5 69 10 f0       	push   $0xf01069d5
f0102ed4:	68 8e 04 00 00       	push   $0x48e
f0102ed9:	68 af 69 10 f0       	push   $0xf01069af
f0102ede:	e8 5d d1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102ee3:	68 cf 6b 10 f0       	push   $0xf0106bcf
f0102ee8:	68 d5 69 10 f0       	push   $0xf01069d5
f0102eed:	68 90 04 00 00       	push   $0x490
f0102ef2:	68 af 69 10 f0       	push   $0xf01069af
f0102ef7:	e8 44 d1 ff ff       	call   f0100040 <_panic>

f0102efc <user_mem_check>:
{
f0102efc:	55                   	push   %ebp
f0102efd:	89 e5                	mov    %esp,%ebp
f0102eff:	57                   	push   %edi
f0102f00:	56                   	push   %esi
f0102f01:	53                   	push   %ebx
f0102f02:	83 ec 1c             	sub    $0x1c,%esp
f0102f05:	8b 75 14             	mov    0x14(%ebp),%esi
	char * start = ROUNDDOWN((char *)va, PGSIZE);
f0102f08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102f0b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f11:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	char * end = ROUNDUP((char *)(va + len), PGSIZE);
f0102f14:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102f17:	03 7d 10             	add    0x10(%ebp),%edi
f0102f1a:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0102f20:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for(;start<end;start+=PGSIZE){
f0102f26:	eb 15                	jmp    f0102f3d <user_mem_check+0x41>
		    		user_mem_check_addr = (uintptr_t)va;
f0102f28:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f2b:	a3 68 82 21 f0       	mov    %eax,0xf0218268
	      		return -E_FAULT;
f0102f30:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f35:	eb 44                	jmp    f0102f7b <user_mem_check+0x7f>
	for(;start<end;start+=PGSIZE){
f0102f37:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f3d:	39 fb                	cmp    %edi,%ebx
f0102f3f:	73 42                	jae    f0102f83 <user_mem_check+0x87>
		pte_t * cur= pgdir_walk(env->env_pgdir, (void *)start, 0);
f0102f41:	83 ec 04             	sub    $0x4,%esp
f0102f44:	6a 00                	push   $0x0
f0102f46:	53                   	push   %ebx
f0102f47:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f4a:	ff 70 60             	push   0x60(%eax)
f0102f4d:	e8 b6 e0 ff ff       	call   f0101008 <pgdir_walk>
f0102f52:	89 da                	mov    %ebx,%edx
		if( (uint32_t) start >= ULIM || cur == NULL || ( (uint32_t)(*cur) & perm) != perm /*如果pte项的user位为0*/) {
f0102f54:	83 c4 10             	add    $0x10,%esp
f0102f57:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f5d:	77 0c                	ja     f0102f6b <user_mem_check+0x6f>
f0102f5f:	85 c0                	test   %eax,%eax
f0102f61:	74 08                	je     f0102f6b <user_mem_check+0x6f>
f0102f63:	89 f1                	mov    %esi,%ecx
f0102f65:	23 08                	and    (%eax),%ecx
f0102f67:	39 ce                	cmp    %ecx,%esi
f0102f69:	74 cc                	je     f0102f37 <user_mem_check+0x3b>
			if(start == ROUNDDOWN((char *)va, PGSIZE)) {
f0102f6b:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102f6e:	74 b8                	je     f0102f28 <user_mem_check+0x2c>
	      			user_mem_check_addr = (uintptr_t)start;
f0102f70:	89 15 68 82 21 f0    	mov    %edx,0xf0218268
	      		return -E_FAULT;
f0102f76:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102f7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f7e:	5b                   	pop    %ebx
f0102f7f:	5e                   	pop    %esi
f0102f80:	5f                   	pop    %edi
f0102f81:	5d                   	pop    %ebp
f0102f82:	c3                   	ret    
	return 0;
f0102f83:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f88:	eb f1                	jmp    f0102f7b <user_mem_check+0x7f>

f0102f8a <user_mem_assert>:
{
f0102f8a:	55                   	push   %ebp
f0102f8b:	89 e5                	mov    %esp,%ebp
f0102f8d:	53                   	push   %ebx
f0102f8e:	83 ec 04             	sub    $0x4,%esp
f0102f91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102f94:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f97:	83 c8 04             	or     $0x4,%eax
f0102f9a:	50                   	push   %eax
f0102f9b:	ff 75 10             	push   0x10(%ebp)
f0102f9e:	ff 75 0c             	push   0xc(%ebp)
f0102fa1:	53                   	push   %ebx
f0102fa2:	e8 55 ff ff ff       	call   f0102efc <user_mem_check>
f0102fa7:	83 c4 10             	add    $0x10,%esp
f0102faa:	85 c0                	test   %eax,%eax
f0102fac:	78 05                	js     f0102fb3 <user_mem_assert+0x29>
}
f0102fae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102fb1:	c9                   	leave  
f0102fb2:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102fb3:	83 ec 04             	sub    $0x4,%esp
f0102fb6:	ff 35 68 82 21 f0    	push   0xf0218268
f0102fbc:	ff 73 48             	push   0x48(%ebx)
f0102fbf:	68 20 76 10 f0       	push   $0xf0107620
f0102fc4:	e8 e9 09 00 00       	call   f01039b2 <cprintf>
		env_destroy(env);	// may not return
f0102fc9:	89 1c 24             	mov    %ebx,(%esp)
f0102fcc:	e8 a7 06 00 00       	call   f0103678 <env_destroy>
f0102fd1:	83 c4 10             	add    $0x10,%esp
}
f0102fd4:	eb d8                	jmp    f0102fae <user_mem_assert+0x24>

f0102fd6 <region_alloc>:
// Panic if any allocation attempt fails.
//
//为环境分配和映射物理内存
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102fd6:	55                   	push   %ebp
f0102fd7:	89 e5                	mov    %esp,%ebp
f0102fd9:	57                   	push   %edi
f0102fda:	56                   	push   %esi
f0102fdb:	53                   	push   %ebx
f0102fdc:	83 ec 0c             	sub    $0xc,%esp
f0102fdf:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	//先申请物理内存，再调用page_insert（）
	void* start = (void *)ROUNDDOWN((uint32_t)va, PGSIZE);     
f0102fe1:	89 d3                	mov    %edx,%ebx
f0102fe3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
f0102fe9:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102ff0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	struct PageInfo *p = NULL;
	int r;
	for(void* i=start; i<end; i+=PGSIZE){
f0102ff6:	39 f3                	cmp    %esi,%ebx
f0102ff8:	73 5a                	jae    f0103054 <region_alloc+0x7e>
		p = page_alloc(0);
f0102ffa:	83 ec 0c             	sub    $0xc,%esp
f0102ffd:	6a 00                	push   $0x0
f0102fff:	e8 10 df ff ff       	call   f0100f14 <page_alloc>
		if(p == NULL) panic("region alloc - page alloc failed.");
f0103004:	83 c4 10             	add    $0x10,%esp
f0103007:	85 c0                	test   %eax,%eax
f0103009:	74 1b                	je     f0103026 <region_alloc+0x50>
		
	 	r = page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);
f010300b:	6a 06                	push   $0x6
f010300d:	53                   	push   %ebx
f010300e:	50                   	push   %eax
f010300f:	ff 77 60             	push   0x60(%edi)
f0103012:	e8 0b e2 ff ff       	call   f0101222 <page_insert>
	 	if(r != 0)  panic("region alloc - page insert error - page table couldn't be allocated");
f0103017:	83 c4 10             	add    $0x10,%esp
f010301a:	85 c0                	test   %eax,%eax
f010301c:	75 1f                	jne    f010303d <region_alloc+0x67>
	for(void* i=start; i<end; i+=PGSIZE){
f010301e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103024:	eb d0                	jmp    f0102ff6 <region_alloc+0x20>
		if(p == NULL) panic("region alloc - page alloc failed.");
f0103026:	83 ec 04             	sub    $0x4,%esp
f0103029:	68 58 76 10 f0       	push   $0xf0107658
f010302e:	68 38 01 00 00       	push   $0x138
f0103033:	68 46 77 10 f0       	push   $0xf0107746
f0103038:	e8 03 d0 ff ff       	call   f0100040 <_panic>
	 	if(r != 0)  panic("region alloc - page insert error - page table couldn't be allocated");
f010303d:	83 ec 04             	sub    $0x4,%esp
f0103040:	68 7c 76 10 f0       	push   $0xf010767c
f0103045:	68 3b 01 00 00       	push   $0x13b
f010304a:	68 46 77 10 f0       	push   $0xf0107746
f010304f:	e8 ec cf ff ff       	call   f0100040 <_panic>
	}
}
f0103054:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103057:	5b                   	pop    %ebx
f0103058:	5e                   	pop    %esi
f0103059:	5f                   	pop    %edi
f010305a:	5d                   	pop    %ebp
f010305b:	c3                   	ret    

f010305c <envid2env>:
{
f010305c:	55                   	push   %ebp
f010305d:	89 e5                	mov    %esp,%ebp
f010305f:	56                   	push   %esi
f0103060:	53                   	push   %ebx
f0103061:	8b 75 08             	mov    0x8(%ebp),%esi
f0103064:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f0103067:	85 f6                	test   %esi,%esi
f0103069:	74 2e                	je     f0103099 <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f010306b:	89 f3                	mov    %esi,%ebx
f010306d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103073:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103076:	03 1d 70 82 21 f0    	add    0xf0218270,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010307c:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103080:	74 5b                	je     f01030dd <envid2env+0x81>
f0103082:	39 73 48             	cmp    %esi,0x48(%ebx)
f0103085:	75 62                	jne    f01030e9 <envid2env+0x8d>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103087:	84 c0                	test   %al,%al
f0103089:	75 20                	jne    f01030ab <envid2env+0x4f>
	return 0;
f010308b:	b8 00 00 00 00       	mov    $0x0,%eax
		*env_store = curenv;
f0103090:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103093:	89 1a                	mov    %ebx,(%edx)
}
f0103095:	5b                   	pop    %ebx
f0103096:	5e                   	pop    %esi
f0103097:	5d                   	pop    %ebp
f0103098:	c3                   	ret    
		*env_store = curenv;
f0103099:	e8 6e 2d 00 00       	call   f0105e0c <cpunum>
f010309e:	6b c0 74             	imul   $0x74,%eax,%eax
f01030a1:	8b 98 28 90 25 f0    	mov    -0xfda6fd8(%eax),%ebx
		return 0;
f01030a7:	89 f0                	mov    %esi,%eax
f01030a9:	eb e5                	jmp    f0103090 <envid2env+0x34>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01030ab:	e8 5c 2d 00 00       	call   f0105e0c <cpunum>
f01030b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01030b3:	39 98 28 90 25 f0    	cmp    %ebx,-0xfda6fd8(%eax)
f01030b9:	74 d0                	je     f010308b <envid2env+0x2f>
f01030bb:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01030be:	e8 49 2d 00 00       	call   f0105e0c <cpunum>
f01030c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01030c6:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f01030cc:	3b 70 48             	cmp    0x48(%eax),%esi
f01030cf:	74 ba                	je     f010308b <envid2env+0x2f>
f01030d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f01030d6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030db:	eb b3                	jmp    f0103090 <envid2env+0x34>
f01030dd:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f01030e2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030e7:	eb a7                	jmp    f0103090 <envid2env+0x34>
f01030e9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01030ee:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030f3:	eb 9b                	jmp    f0103090 <envid2env+0x34>

f01030f5 <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f01030f5:	b8 20 53 12 f0       	mov    $0xf0125320,%eax
f01030fa:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01030fd:	b8 23 00 00 00       	mov    $0x23,%eax
f0103102:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103104:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103106:	b8 10 00 00 00       	mov    $0x10,%eax
f010310b:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010310d:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010310f:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103111:	ea 18 31 10 f0 08 00 	ljmp   $0x8,$0xf0103118
	asm volatile("lldt %0" : : "r" (sel));
f0103118:	b8 00 00 00 00       	mov    $0x0,%eax
f010311d:	0f 00 d0             	lldt   %ax
}
f0103120:	c3                   	ret    

f0103121 <env_init>:
{
f0103121:	55                   	push   %ebp
f0103122:	89 e5                	mov    %esp,%ebp
f0103124:	83 ec 08             	sub    $0x8,%esp
	env_free_list=envs;
f0103127:	a1 70 82 21 f0       	mov    0xf0218270,%eax
f010312c:	a3 74 82 21 f0       	mov    %eax,0xf0218274
f0103131:	83 c0 7c             	add    $0x7c,%eax
	for(int i=0;i<NENV;i++){
f0103134:	ba 00 00 00 00       	mov    $0x0,%edx
f0103139:	eb 11                	jmp    f010314c <env_init+0x2b>
f010313b:	89 40 c8             	mov    %eax,-0x38(%eax)
f010313e:	83 c2 01             	add    $0x1,%edx
f0103141:	83 c0 7c             	add    $0x7c,%eax
f0103144:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f010314a:	74 1d                	je     f0103169 <env_init+0x48>
		envs[i].env_status = ENV_FREE;
f010314c:	c7 40 d8 00 00 00 00 	movl   $0x0,-0x28(%eax)
		envs[i].env_id=0;
f0103153:	c7 40 cc 00 00 00 00 	movl   $0x0,-0x34(%eax)
		if(i!=NENV-1) envs[i].env_link= &envs[i+1];
f010315a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0103160:	75 d9                	jne    f010313b <env_init+0x1a>
f0103162:	c7 40 c8 00 00 00 00 	movl   $0x0,-0x38(%eax)
	env_init_percpu();
f0103169:	e8 87 ff ff ff       	call   f01030f5 <env_init_percpu>
}
f010316e:	c9                   	leave  
f010316f:	c3                   	ret    

f0103170 <env_alloc>:
{
f0103170:	55                   	push   %ebp
f0103171:	89 e5                	mov    %esp,%ebp
f0103173:	53                   	push   %ebx
f0103174:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f0103177:	8b 1d 74 82 21 f0    	mov    0xf0218274,%ebx
f010317d:	85 db                	test   %ebx,%ebx
f010317f:	0f 84 95 01 00 00    	je     f010331a <env_alloc+0x1aa>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103185:	83 ec 0c             	sub    $0xc,%esp
f0103188:	6a 01                	push   $0x1
f010318a:	e8 85 dd ff ff       	call   f0100f14 <page_alloc>
f010318f:	83 c4 10             	add    $0x10,%esp
f0103192:	85 c0                	test   %eax,%eax
f0103194:	0f 84 87 01 00 00    	je     f0103321 <env_alloc+0x1b1>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f010319a:	89 c2                	mov    %eax,%edx
f010319c:	2b 15 58 82 21 f0    	sub    0xf0218258,%edx
f01031a2:	c1 fa 03             	sar    $0x3,%edx
f01031a5:	89 d1                	mov    %edx,%ecx
f01031a7:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f01031aa:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
f01031b0:	3b 15 60 82 21 f0    	cmp    0xf0218260,%edx
f01031b6:	0f 83 37 01 00 00    	jae    f01032f3 <env_alloc+0x183>
	return (void *)(pa + KERNBASE);
f01031bc:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f01031c2:	89 4b 60             	mov    %ecx,0x60(%ebx)
	p->pp_ref++;
f01031c5:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01031ca:	b8 00 00 00 00       	mov    $0x0,%eax
		e->env_pgdir[i] = 0;        
f01031cf:	8b 53 60             	mov    0x60(%ebx),%edx
f01031d2:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	for(i = 0; i < PDX(UTOP); i++) {
f01031d9:	83 c0 04             	add    $0x4,%eax
f01031dc:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01031e1:	75 ec                	jne    f01031cf <env_alloc+0x5f>
		e->env_pgdir[i] = kern_pgdir[i];
f01031e3:	8b 15 5c 82 21 f0    	mov    0xf021825c,%edx
f01031e9:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01031ec:	8b 53 60             	mov    0x60(%ebx),%edx
f01031ef:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
	for(i = PDX(UTOP); i < NPDENTRIES; i++) {//NPDENTRIES宏在mmu.h中定义，为1024
f01031f2:	83 c0 04             	add    $0x4,%eax
f01031f5:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01031fa:	75 e7                	jne    f01031e3 <env_alloc+0x73>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01031fc:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01031ff:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103204:	0f 86 fb 00 00 00    	jbe    f0103305 <env_alloc+0x195>
	return (physaddr_t)kva - KERNBASE;
f010320a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103210:	83 ca 05             	or     $0x5,%edx
f0103213:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103219:	8b 43 48             	mov    0x48(%ebx),%eax
f010321c:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f0103221:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103226:	ba 00 10 00 00       	mov    $0x1000,%edx
f010322b:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010322e:	89 da                	mov    %ebx,%edx
f0103230:	2b 15 70 82 21 f0    	sub    0xf0218270,%edx
f0103236:	c1 fa 02             	sar    $0x2,%edx
f0103239:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010323f:	09 d0                	or     %edx,%eax
f0103241:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103244:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103247:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010324a:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103251:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103258:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010325f:	83 ec 04             	sub    $0x4,%esp
f0103262:	6a 44                	push   $0x44
f0103264:	6a 00                	push   $0x0
f0103266:	53                   	push   %ebx
f0103267:	e8 ab 25 00 00       	call   f0105817 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010326c:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103272:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103278:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010327e:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103285:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f010328b:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f0103292:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103299:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f010329d:	8b 43 44             	mov    0x44(%ebx),%eax
f01032a0:	a3 74 82 21 f0       	mov    %eax,0xf0218274
	*newenv_store = e;
f01032a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01032a8:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01032aa:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01032ad:	e8 5a 2b 00 00       	call   f0105e0c <cpunum>
f01032b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01032b5:	83 c4 10             	add    $0x10,%esp
f01032b8:	ba 00 00 00 00       	mov    $0x0,%edx
f01032bd:	83 b8 28 90 25 f0 00 	cmpl   $0x0,-0xfda6fd8(%eax)
f01032c4:	74 11                	je     f01032d7 <env_alloc+0x167>
f01032c6:	e8 41 2b 00 00       	call   f0105e0c <cpunum>
f01032cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01032ce:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f01032d4:	8b 50 48             	mov    0x48(%eax),%edx
f01032d7:	83 ec 04             	sub    $0x4,%esp
f01032da:	53                   	push   %ebx
f01032db:	52                   	push   %edx
f01032dc:	68 51 77 10 f0       	push   $0xf0107751
f01032e1:	e8 cc 06 00 00       	call   f01039b2 <cprintf>
	return 0;
f01032e6:	83 c4 10             	add    $0x10,%esp
f01032e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01032f1:	c9                   	leave  
f01032f2:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032f3:	51                   	push   %ecx
f01032f4:	68 64 64 10 f0       	push   $0xf0106464
f01032f9:	6a 5a                	push   $0x5a
f01032fb:	68 bb 69 10 f0       	push   $0xf01069bb
f0103300:	e8 3b cd ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103305:	50                   	push   %eax
f0103306:	68 88 64 10 f0       	push   $0xf0106488
f010330b:	68 d1 00 00 00       	push   $0xd1
f0103310:	68 46 77 10 f0       	push   $0xf0107746
f0103315:	e8 26 cd ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f010331a:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010331f:	eb cd                	jmp    f01032ee <env_alloc+0x17e>
		return -E_NO_MEM;
f0103321:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103326:	eb c6                	jmp    f01032ee <env_alloc+0x17e>

f0103328 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//用env_alloc分配一个环境，并调用load_icode将ELF二进制文件加载到环境中。
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103328:	55                   	push   %ebp
f0103329:	89 e5                	mov    %esp,%ebp
f010332b:	57                   	push   %edi
f010332c:	56                   	push   %esi
f010332d:	53                   	push   %ebx
f010332e:	83 ec 34             	sub    $0x34,%esp
f0103331:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	//使用env_alloc分配一个env，根据注释很简单。
	struct Env * env=NULL;
f0103334:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	
	int r = env_alloc(&env, 0);
f010333b:	6a 00                	push   $0x0
f010333d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103340:	50                   	push   %eax
f0103341:	e8 2a fe ff ff       	call   f0103170 <env_alloc>
	if(r < 0)  panic("env_create error: %e", r);//使用lab中示例的panic。
f0103346:	83 c4 10             	add    $0x10,%esp
f0103349:	85 c0                	test   %eax,%eax
f010334b:	78 3e                	js     f010338b <env_create+0x63>

	load_icode(env,binary);
f010334d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103350:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if(e == NULL || binary == NULL)  panic("load_icode: invalid environment or binary\n");
f0103353:	85 c0                	test   %eax,%eax
f0103355:	74 49                	je     f01033a0 <env_create+0x78>
f0103357:	85 ff                	test   %edi,%edi
f0103359:	74 45                	je     f01033a0 <env_create+0x78>
	if(ElfHeader->e_magic != ELF_MAGIC) panic("load_icode error : binary is invalid elf format\n");
f010335b:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103361:	75 54                	jne    f01033b7 <env_create+0x8f>
	struct Proghdr * ph = (struct Proghdr *) ((uint8_t *) ElfHeader + ElfHeader->e_phoff);
f0103363:	89 fb                	mov    %edi,%ebx
f0103365:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr * eph = ph + ElfHeader->e_phnum;
f0103368:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f010336c:	c1 e6 05             	shl    $0x5,%esi
f010336f:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));//lcr3(uint32_t val)在inc/x86.h中定义 ，其将val值赋给cr3寄存器(即页目录基寄存器)。
f0103371:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103374:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103377:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010337c:	76 50                	jbe    f01033ce <env_create+0xa6>
	return (physaddr_t)kva - KERNBASE;
f010337e:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f0103383:	0f 22 d8             	mov    %eax,%cr3
}
f0103386:	e9 94 00 00 00       	jmp    f010341f <env_create+0xf7>
	if(r < 0)  panic("env_create error: %e", r);//使用lab中示例的panic。
f010338b:	50                   	push   %eax
f010338c:	68 66 77 10 f0       	push   $0xf0107766
f0103391:	68 a8 01 00 00       	push   $0x1a8
f0103396:	68 46 77 10 f0       	push   $0xf0107746
f010339b:	e8 a0 cc ff ff       	call   f0100040 <_panic>
	if(e == NULL || binary == NULL)  panic("load_icode: invalid environment or binary\n");
f01033a0:	83 ec 04             	sub    $0x4,%esp
f01033a3:	68 c0 76 10 f0       	push   $0xf01076c0
f01033a8:	68 79 01 00 00       	push   $0x179
f01033ad:	68 46 77 10 f0       	push   $0xf0107746
f01033b2:	e8 89 cc ff ff       	call   f0100040 <_panic>
	if(ElfHeader->e_magic != ELF_MAGIC) panic("load_icode error : binary is invalid elf format\n");
f01033b7:	83 ec 04             	sub    $0x4,%esp
f01033ba:	68 ec 76 10 f0       	push   $0xf01076ec
f01033bf:	68 7e 01 00 00       	push   $0x17e
f01033c4:	68 46 77 10 f0       	push   $0xf0107746
f01033c9:	e8 72 cc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033ce:	50                   	push   %eax
f01033cf:	68 88 64 10 f0       	push   $0xf0106488
f01033d4:	68 83 01 00 00       	push   $0x183
f01033d9:	68 46 77 10 f0       	push   $0xf0107746
f01033de:	e8 5d cc ff ff       	call   f0100040 <_panic>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);//为 环境e 分配和映射物理内存
f01033e3:	8b 53 08             	mov    0x8(%ebx),%edx
f01033e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033e9:	e8 e8 fb ff ff       	call   f0102fd6 <region_alloc>
			memmove((void*)ph->p_va, (uint8_t *)binary + ph->p_offset, ph->p_filesz);//移动binary到虚拟内存  (mem等函数全在lib/string.c中定义)
f01033ee:	83 ec 04             	sub    $0x4,%esp
f01033f1:	ff 73 10             	push   0x10(%ebx)
f01033f4:	89 f8                	mov    %edi,%eax
f01033f6:	03 43 04             	add    0x4(%ebx),%eax
f01033f9:	50                   	push   %eax
f01033fa:	ff 73 08             	push   0x8(%ebx)
f01033fd:	e8 5b 24 00 00       	call   f010585d <memmove>
			memset((void*)ph->p_va+ph->p_filesz, 0, ph->p_memsz-ph->p_filesz);//剩余内存置0
f0103402:	8b 43 10             	mov    0x10(%ebx),%eax
f0103405:	83 c4 0c             	add    $0xc,%esp
f0103408:	8b 53 14             	mov    0x14(%ebx),%edx
f010340b:	29 c2                	sub    %eax,%edx
f010340d:	52                   	push   %edx
f010340e:	6a 00                	push   $0x0
f0103410:	03 43 08             	add    0x8(%ebx),%eax
f0103413:	50                   	push   %eax
f0103414:	e8 fe 23 00 00       	call   f0105817 <memset>
f0103419:	83 c4 10             	add    $0x10,%esp
	for(; ph < eph; ph++) {
f010341c:	83 c3 20             	add    $0x20,%ebx
f010341f:	39 de                	cmp    %ebx,%esi
f0103421:	76 24                	jbe    f0103447 <env_create+0x11f>
		if(ph->p_type == ELF_PROG_LOAD){//注释要求
f0103423:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103426:	75 f4                	jne    f010341c <env_create+0xf4>
			if(ph->p_memsz < ph->p_filesz)
f0103428:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010342b:	3b 4b 10             	cmp    0x10(%ebx),%ecx
f010342e:	73 b3                	jae    f01033e3 <env_create+0xbb>
				panic("load_icode error: p_memsz < p_filesz\n");
f0103430:	83 ec 04             	sub    $0x4,%esp
f0103433:	68 20 77 10 f0       	push   $0xf0107720
f0103438:	68 88 01 00 00       	push   $0x188
f010343d:	68 46 77 10 f0       	push   $0xf0107746
f0103442:	e8 f9 cb ff ff       	call   f0100040 <_panic>
	lcr3(PADDR(kern_pgdir));//再切换回内核的页目录，我感觉要在分配栈前，一些博客与我有出入。
f0103447:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
	if ((uint32_t)kva < KERNBASE)
f010344c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103451:	76 33                	jbe    f0103486 <env_create+0x15e>
	return (physaddr_t)kva - KERNBASE;
f0103453:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f0103458:	0f 22 d8             	mov    %eax,%cr3
	e->env_tf.tf_eip = ElfHeader->e_entry;//这句我也不确定。但我感觉大致思路是由于段设计在JOS约等于没有（因为linux就约等于没有，之前lab中介绍有提到），而根据注释要修改cs:ip,所以就之修改了eip。
f010345b:	8b 47 18             	mov    0x18(%edi),%eax
f010345e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103461:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void*)(USTACKTOP-PGSIZE), PGSIZE);
f0103464:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103469:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010346e:	89 f8                	mov    %edi,%eax
f0103470:	e8 61 fb ff ff       	call   f0102fd6 <region_alloc>
	env->env_type=type;
f0103475:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103478:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010347b:	89 50 50             	mov    %edx,0x50(%eax)
}
f010347e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103481:	5b                   	pop    %ebx
f0103482:	5e                   	pop    %esi
f0103483:	5f                   	pop    %edi
f0103484:	5d                   	pop    %ebp
f0103485:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103486:	50                   	push   %eax
f0103487:	68 88 64 10 f0       	push   $0xf0106488
f010348c:	68 8f 01 00 00       	push   $0x18f
f0103491:	68 46 77 10 f0       	push   $0xf0107746
f0103496:	e8 a5 cb ff ff       	call   f0100040 <_panic>

f010349b <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010349b:	55                   	push   %ebp
f010349c:	89 e5                	mov    %esp,%ebp
f010349e:	57                   	push   %edi
f010349f:	56                   	push   %esi
f01034a0:	53                   	push   %ebx
f01034a1:	83 ec 1c             	sub    $0x1c,%esp
f01034a4:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01034a7:	e8 60 29 00 00       	call   f0105e0c <cpunum>
f01034ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01034af:	39 b8 28 90 25 f0    	cmp    %edi,-0xfda6fd8(%eax)
f01034b5:	74 48                	je     f01034ff <env_free+0x64>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01034b7:	8b 5f 48             	mov    0x48(%edi),%ebx
f01034ba:	e8 4d 29 00 00       	call   f0105e0c <cpunum>
f01034bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01034c2:	ba 00 00 00 00       	mov    $0x0,%edx
f01034c7:	83 b8 28 90 25 f0 00 	cmpl   $0x0,-0xfda6fd8(%eax)
f01034ce:	74 11                	je     f01034e1 <env_free+0x46>
f01034d0:	e8 37 29 00 00       	call   f0105e0c <cpunum>
f01034d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01034d8:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f01034de:	8b 50 48             	mov    0x48(%eax),%edx
f01034e1:	83 ec 04             	sub    $0x4,%esp
f01034e4:	53                   	push   %ebx
f01034e5:	52                   	push   %edx
f01034e6:	68 7b 77 10 f0       	push   $0xf010777b
f01034eb:	e8 c2 04 00 00       	call   f01039b2 <cprintf>
f01034f0:	83 c4 10             	add    $0x10,%esp
f01034f3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01034fa:	e9 a9 00 00 00       	jmp    f01035a8 <env_free+0x10d>
		lcr3(PADDR(kern_pgdir));
f01034ff:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103504:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103509:	76 0a                	jbe    f0103515 <env_free+0x7a>
	return (physaddr_t)kva - KERNBASE;
f010350b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103510:	0f 22 d8             	mov    %eax,%cr3
}
f0103513:	eb a2                	jmp    f01034b7 <env_free+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103515:	50                   	push   %eax
f0103516:	68 88 64 10 f0       	push   $0xf0106488
f010351b:	68 bc 01 00 00       	push   $0x1bc
f0103520:	68 46 77 10 f0       	push   $0xf0107746
f0103525:	e8 16 cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010352a:	56                   	push   %esi
f010352b:	68 64 64 10 f0       	push   $0xf0106464
f0103530:	68 cb 01 00 00       	push   $0x1cb
f0103535:	68 46 77 10 f0       	push   $0xf0107746
f010353a:	e8 01 cb ff ff       	call   f0100040 <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010353f:	83 c6 04             	add    $0x4,%esi
f0103542:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103548:	81 fb 00 00 40 00    	cmp    $0x400000,%ebx
f010354e:	74 1b                	je     f010356b <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f0103550:	f6 06 01             	testb  $0x1,(%esi)
f0103553:	74 ea                	je     f010353f <env_free+0xa4>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103555:	83 ec 08             	sub    $0x8,%esp
f0103558:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010355b:	09 d8                	or     %ebx,%eax
f010355d:	50                   	push   %eax
f010355e:	ff 77 60             	push   0x60(%edi)
f0103561:	e8 76 dc ff ff       	call   f01011dc <page_remove>
f0103566:	83 c4 10             	add    $0x10,%esp
f0103569:	eb d4                	jmp    f010353f <env_free+0xa4>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010356b:	8b 47 60             	mov    0x60(%edi),%eax
f010356e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103571:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f0103578:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010357b:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f0103581:	73 65                	jae    f01035e8 <env_free+0x14d>
		page_decref(pa2page(pa));
f0103583:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103586:	a1 58 82 21 f0       	mov    0xf0218258,%eax
f010358b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010358e:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103591:	50                   	push   %eax
f0103592:	e8 48 da ff ff       	call   f0100fdf <page_decref>
f0103597:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010359a:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f010359e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035a1:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01035a6:	74 54                	je     f01035fc <env_free+0x161>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01035a8:	8b 47 60             	mov    0x60(%edi),%eax
f01035ab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01035ae:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f01035b1:	a8 01                	test   $0x1,%al
f01035b3:	74 e5                	je     f010359a <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01035b5:	89 c6                	mov    %eax,%esi
f01035b7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f01035bd:	c1 e8 0c             	shr    $0xc,%eax
f01035c0:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01035c3:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f01035c9:	0f 83 5b ff ff ff    	jae    f010352a <env_free+0x8f>
	return (void *)(pa + KERNBASE);
f01035cf:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f01035d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035d8:	c1 e0 14             	shl    $0x14,%eax
f01035db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01035de:	bb 00 00 00 00       	mov    $0x0,%ebx
f01035e3:	e9 68 ff ff ff       	jmp    f0103550 <env_free+0xb5>
		panic("pa2page called with invalid pa");
f01035e8:	83 ec 04             	sub    $0x4,%esp
f01035eb:	68 f4 6d 10 f0       	push   $0xf0106df4
f01035f0:	6a 52                	push   $0x52
f01035f2:	68 bb 69 10 f0       	push   $0xf01069bb
f01035f7:	e8 44 ca ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01035fc:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f01035ff:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103604:	76 49                	jbe    f010364f <env_free+0x1b4>
	e->env_pgdir = 0;
f0103606:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f010360d:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f0103612:	c1 e8 0c             	shr    $0xc,%eax
f0103615:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f010361b:	73 47                	jae    f0103664 <env_free+0x1c9>
	page_decref(pa2page(pa));
f010361d:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103620:	8b 15 58 82 21 f0    	mov    0xf0218258,%edx
f0103626:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103629:	50                   	push   %eax
f010362a:	e8 b0 d9 ff ff       	call   f0100fdf <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010362f:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103636:	a1 74 82 21 f0       	mov    0xf0218274,%eax
f010363b:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010363e:	89 3d 74 82 21 f0    	mov    %edi,0xf0218274
}
f0103644:	83 c4 10             	add    $0x10,%esp
f0103647:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010364a:	5b                   	pop    %ebx
f010364b:	5e                   	pop    %esi
f010364c:	5f                   	pop    %edi
f010364d:	5d                   	pop    %ebp
f010364e:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010364f:	50                   	push   %eax
f0103650:	68 88 64 10 f0       	push   $0xf0106488
f0103655:	68 d9 01 00 00       	push   $0x1d9
f010365a:	68 46 77 10 f0       	push   $0xf0107746
f010365f:	e8 dc c9 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f0103664:	83 ec 04             	sub    $0x4,%esp
f0103667:	68 f4 6d 10 f0       	push   $0xf0106df4
f010366c:	6a 52                	push   $0x52
f010366e:	68 bb 69 10 f0       	push   $0xf01069bb
f0103673:	e8 c8 c9 ff ff       	call   f0100040 <_panic>

f0103678 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103678:	55                   	push   %ebp
f0103679:	89 e5                	mov    %esp,%ebp
f010367b:	53                   	push   %ebx
f010367c:	83 ec 04             	sub    $0x4,%esp
f010367f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103682:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103686:	74 21                	je     f01036a9 <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103688:	83 ec 0c             	sub    $0xc,%esp
f010368b:	53                   	push   %ebx
f010368c:	e8 0a fe ff ff       	call   f010349b <env_free>

	if (curenv == e) {
f0103691:	e8 76 27 00 00       	call   f0105e0c <cpunum>
f0103696:	6b c0 74             	imul   $0x74,%eax,%eax
f0103699:	83 c4 10             	add    $0x10,%esp
f010369c:	39 98 28 90 25 f0    	cmp    %ebx,-0xfda6fd8(%eax)
f01036a2:	74 1e                	je     f01036c2 <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f01036a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01036a7:	c9                   	leave  
f01036a8:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01036a9:	e8 5e 27 00 00       	call   f0105e0c <cpunum>
f01036ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01036b1:	39 98 28 90 25 f0    	cmp    %ebx,-0xfda6fd8(%eax)
f01036b7:	74 cf                	je     f0103688 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f01036b9:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01036c0:	eb e2                	jmp    f01036a4 <env_destroy+0x2c>
		curenv = NULL;
f01036c2:	e8 45 27 00 00       	call   f0105e0c <cpunum>
f01036c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ca:	c7 80 28 90 25 f0 00 	movl   $0x0,-0xfda6fd8(%eax)
f01036d1:	00 00 00 
		sched_yield();
f01036d4:	e8 14 0f 00 00       	call   f01045ed <sched_yield>

f01036d9 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01036d9:	55                   	push   %ebp
f01036da:	89 e5                	mov    %esp,%ebp
f01036dc:	53                   	push   %ebx
f01036dd:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01036e0:	e8 27 27 00 00       	call   f0105e0c <cpunum>
f01036e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01036e8:	8b 98 28 90 25 f0    	mov    -0xfda6fd8(%eax),%ebx
f01036ee:	e8 19 27 00 00       	call   f0105e0c <cpunum>
f01036f3:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01036f6:	8b 65 08             	mov    0x8(%ebp),%esp
f01036f9:	61                   	popa   
f01036fa:	07                   	pop    %es
f01036fb:	1f                   	pop    %ds
f01036fc:	83 c4 08             	add    $0x8,%esp
f01036ff:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n" /*中断返回指令*/
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103700:	83 ec 04             	sub    $0x4,%esp
f0103703:	68 91 77 10 f0       	push   $0xf0107791
f0103708:	68 10 02 00 00       	push   $0x210
f010370d:	68 46 77 10 f0       	push   $0xf0107746
f0103712:	e8 29 c9 ff ff       	call   f0100040 <_panic>

f0103717 <env_run>:
//
// This function does not return.
//启动在用户模式下运行的给定环境。
void
env_run(struct Env *e)
{
f0103717:	55                   	push   %ebp
f0103718:	89 e5                	mov    %esp,%ebp
f010371a:	53                   	push   %ebx
f010371b:	83 ec 04             	sub    $0x4,%esp
f010371e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// Step 1
	if(e == NULL) panic("env_run: invalid environment\n");
f0103721:	85 db                	test   %ebx,%ebx
f0103723:	0f 84 b3 00 00 00    	je     f01037dc <env_run+0xc5>
	if(curenv != e && curenv != NULL) {
f0103729:	e8 de 26 00 00       	call   f0105e0c <cpunum>
f010372e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103731:	39 98 28 90 25 f0    	cmp    %ebx,-0xfda6fd8(%eax)
f0103737:	74 29                	je     f0103762 <env_run+0x4b>
f0103739:	e8 ce 26 00 00       	call   f0105e0c <cpunum>
f010373e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103741:	83 b8 28 90 25 f0 00 	cmpl   $0x0,-0xfda6fd8(%eax)
f0103748:	74 18                	je     f0103762 <env_run+0x4b>
		if(curenv->env_status == ENV_RUNNING)  curenv->env_status = ENV_RUNNABLE;
f010374a:	e8 bd 26 00 00       	call   f0105e0c <cpunum>
f010374f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103752:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0103758:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010375c:	0f 84 91 00 00 00    	je     f01037f3 <env_run+0xdc>
	}
	curenv=e;
f0103762:	e8 a5 26 00 00       	call   f0105e0c <cpunum>
f0103767:	6b c0 74             	imul   $0x74,%eax,%eax
f010376a:	89 98 28 90 25 f0    	mov    %ebx,-0xfda6fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103770:	e8 97 26 00 00       	call   f0105e0c <cpunum>
f0103775:	6b c0 74             	imul   $0x74,%eax,%eax
f0103778:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f010377e:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103785:	e8 82 26 00 00       	call   f0105e0c <cpunum>
f010378a:	6b c0 74             	imul   $0x74,%eax,%eax
f010378d:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0103793:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103797:	e8 70 26 00 00       	call   f0105e0c <cpunum>
f010379c:	6b c0 74             	imul   $0x74,%eax,%eax
f010379f:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f01037a5:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01037a8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037ad:	76 5e                	jbe    f010380d <env_run+0xf6>
	return (physaddr_t)kva - KERNBASE;
f01037af:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f01037b4:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01037b7:	83 ec 0c             	sub    $0xc,%esp
f01037ba:	68 c0 53 12 f0       	push   $0xf01253c0
f01037bf:	e8 52 29 00 00       	call   f0106116 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01037c4:	f3 90                	pause  
	
	//lab4:切换到用户模式之前释放锁
	unlock_kernel();
	
	// Step 2
	env_pop_tf( &(curenv->env_tf) );
f01037c6:	e8 41 26 00 00       	call   f0105e0c <cpunum>
f01037cb:	83 c4 04             	add    $0x4,%esp
f01037ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01037d1:	ff b0 28 90 25 f0    	push   -0xfda6fd8(%eax)
f01037d7:	e8 fd fe ff ff       	call   f01036d9 <env_pop_tf>
	if(e == NULL) panic("env_run: invalid environment\n");
f01037dc:	83 ec 04             	sub    $0x4,%esp
f01037df:	68 9d 77 10 f0       	push   $0xf010779d
f01037e4:	68 2f 02 00 00       	push   $0x22f
f01037e9:	68 46 77 10 f0       	push   $0xf0107746
f01037ee:	e8 4d c8 ff ff       	call   f0100040 <_panic>
		if(curenv->env_status == ENV_RUNNING)  curenv->env_status = ENV_RUNNABLE;
f01037f3:	e8 14 26 00 00       	call   f0105e0c <cpunum>
f01037f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01037fb:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0103801:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103808:	e9 55 ff ff ff       	jmp    f0103762 <env_run+0x4b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010380d:	50                   	push   %eax
f010380e:	68 88 64 10 f0       	push   $0xf0106488
f0103813:	68 36 02 00 00       	push   $0x236
f0103818:	68 46 77 10 f0       	push   $0xf0107746
f010381d:	e8 1e c8 ff ff       	call   f0100040 <_panic>

f0103822 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103822:	55                   	push   %ebp
f0103823:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103825:	8b 45 08             	mov    0x8(%ebp),%eax
f0103828:	ba 70 00 00 00       	mov    $0x70,%edx
f010382d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010382e:	ba 71 00 00 00       	mov    $0x71,%edx
f0103833:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103834:	0f b6 c0             	movzbl %al,%eax
}
f0103837:	5d                   	pop    %ebp
f0103838:	c3                   	ret    

f0103839 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103839:	55                   	push   %ebp
f010383a:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010383c:	8b 45 08             	mov    0x8(%ebp),%eax
f010383f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103844:	ee                   	out    %al,(%dx)
f0103845:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103848:	ba 71 00 00 00       	mov    $0x71,%edx
f010384d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010384e:	5d                   	pop    %ebp
f010384f:	c3                   	ret    

f0103850 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103850:	55                   	push   %ebp
f0103851:	89 e5                	mov    %esp,%ebp
f0103853:	56                   	push   %esi
f0103854:	53                   	push   %ebx
f0103855:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	irq_mask_8259A = mask;
f0103858:	66 89 0d a8 53 12 f0 	mov    %cx,0xf01253a8
	if (!didinit)
f010385f:	80 3d 78 82 21 f0 00 	cmpb   $0x0,0xf0218278
f0103866:	75 07                	jne    f010386f <irq_setmask_8259A+0x1f>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103868:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010386b:	5b                   	pop    %ebx
f010386c:	5e                   	pop    %esi
f010386d:	5d                   	pop    %ebp
f010386e:	c3                   	ret    
f010386f:	89 ce                	mov    %ecx,%esi
f0103871:	ba 21 00 00 00       	mov    $0x21,%edx
f0103876:	89 c8                	mov    %ecx,%eax
f0103878:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103879:	89 c8                	mov    %ecx,%eax
f010387b:	66 c1 e8 08          	shr    $0x8,%ax
f010387f:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103884:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103885:	83 ec 0c             	sub    $0xc,%esp
f0103888:	68 bb 77 10 f0       	push   $0xf01077bb
f010388d:	e8 20 01 00 00       	call   f01039b2 <cprintf>
f0103892:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103895:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010389a:	0f b7 f6             	movzwl %si,%esi
f010389d:	f7 d6                	not    %esi
f010389f:	eb 08                	jmp    f01038a9 <irq_setmask_8259A+0x59>
	for (i = 0; i < 16; i++)
f01038a1:	83 c3 01             	add    $0x1,%ebx
f01038a4:	83 fb 10             	cmp    $0x10,%ebx
f01038a7:	74 18                	je     f01038c1 <irq_setmask_8259A+0x71>
		if (~mask & (1<<i))
f01038a9:	0f a3 de             	bt     %ebx,%esi
f01038ac:	73 f3                	jae    f01038a1 <irq_setmask_8259A+0x51>
			cprintf(" %d", i);
f01038ae:	83 ec 08             	sub    $0x8,%esp
f01038b1:	53                   	push   %ebx
f01038b2:	68 9b 7c 10 f0       	push   $0xf0107c9b
f01038b7:	e8 f6 00 00 00       	call   f01039b2 <cprintf>
f01038bc:	83 c4 10             	add    $0x10,%esp
f01038bf:	eb e0                	jmp    f01038a1 <irq_setmask_8259A+0x51>
	cprintf("\n");
f01038c1:	83 ec 0c             	sub    $0xc,%esp
f01038c4:	68 b3 6c 10 f0       	push   $0xf0106cb3
f01038c9:	e8 e4 00 00 00       	call   f01039b2 <cprintf>
f01038ce:	83 c4 10             	add    $0x10,%esp
f01038d1:	eb 95                	jmp    f0103868 <irq_setmask_8259A+0x18>

f01038d3 <pic_init>:
{
f01038d3:	55                   	push   %ebp
f01038d4:	89 e5                	mov    %esp,%ebp
f01038d6:	57                   	push   %edi
f01038d7:	56                   	push   %esi
f01038d8:	53                   	push   %ebx
f01038d9:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f01038dc:	c6 05 78 82 21 f0 01 	movb   $0x1,0xf0218278
f01038e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01038e8:	bb 21 00 00 00       	mov    $0x21,%ebx
f01038ed:	89 da                	mov    %ebx,%edx
f01038ef:	ee                   	out    %al,(%dx)
f01038f0:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f01038f5:	89 ca                	mov    %ecx,%edx
f01038f7:	ee                   	out    %al,(%dx)
f01038f8:	bf 11 00 00 00       	mov    $0x11,%edi
f01038fd:	be 20 00 00 00       	mov    $0x20,%esi
f0103902:	89 f8                	mov    %edi,%eax
f0103904:	89 f2                	mov    %esi,%edx
f0103906:	ee                   	out    %al,(%dx)
f0103907:	b8 20 00 00 00       	mov    $0x20,%eax
f010390c:	89 da                	mov    %ebx,%edx
f010390e:	ee                   	out    %al,(%dx)
f010390f:	b8 04 00 00 00       	mov    $0x4,%eax
f0103914:	ee                   	out    %al,(%dx)
f0103915:	b8 03 00 00 00       	mov    $0x3,%eax
f010391a:	ee                   	out    %al,(%dx)
f010391b:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103920:	89 f8                	mov    %edi,%eax
f0103922:	89 da                	mov    %ebx,%edx
f0103924:	ee                   	out    %al,(%dx)
f0103925:	b8 28 00 00 00       	mov    $0x28,%eax
f010392a:	89 ca                	mov    %ecx,%edx
f010392c:	ee                   	out    %al,(%dx)
f010392d:	b8 02 00 00 00       	mov    $0x2,%eax
f0103932:	ee                   	out    %al,(%dx)
f0103933:	b8 01 00 00 00       	mov    $0x1,%eax
f0103938:	ee                   	out    %al,(%dx)
f0103939:	bf 68 00 00 00       	mov    $0x68,%edi
f010393e:	89 f8                	mov    %edi,%eax
f0103940:	89 f2                	mov    %esi,%edx
f0103942:	ee                   	out    %al,(%dx)
f0103943:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103948:	89 c8                	mov    %ecx,%eax
f010394a:	ee                   	out    %al,(%dx)
f010394b:	89 f8                	mov    %edi,%eax
f010394d:	89 da                	mov    %ebx,%edx
f010394f:	ee                   	out    %al,(%dx)
f0103950:	89 c8                	mov    %ecx,%eax
f0103952:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103953:	0f b7 05 a8 53 12 f0 	movzwl 0xf01253a8,%eax
f010395a:	66 83 f8 ff          	cmp    $0xffff,%ax
f010395e:	75 08                	jne    f0103968 <pic_init+0x95>
}
f0103960:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103963:	5b                   	pop    %ebx
f0103964:	5e                   	pop    %esi
f0103965:	5f                   	pop    %edi
f0103966:	5d                   	pop    %ebp
f0103967:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f0103968:	83 ec 0c             	sub    $0xc,%esp
f010396b:	0f b7 c0             	movzwl %ax,%eax
f010396e:	50                   	push   %eax
f010396f:	e8 dc fe ff ff       	call   f0103850 <irq_setmask_8259A>
f0103974:	83 c4 10             	add    $0x10,%esp
}
f0103977:	eb e7                	jmp    f0103960 <pic_init+0x8d>

f0103979 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103979:	55                   	push   %ebp
f010397a:	89 e5                	mov    %esp,%ebp
f010397c:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010397f:	ff 75 08             	push   0x8(%ebp)
f0103982:	e8 c1 cd ff ff       	call   f0100748 <cputchar>
	*cnt++;
}
f0103987:	83 c4 10             	add    $0x10,%esp
f010398a:	c9                   	leave  
f010398b:	c3                   	ret    

f010398c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010398c:	55                   	push   %ebp
f010398d:	89 e5                	mov    %esp,%ebp
f010398f:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103992:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103999:	ff 75 0c             	push   0xc(%ebp)
f010399c:	ff 75 08             	push   0x8(%ebp)
f010399f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01039a2:	50                   	push   %eax
f01039a3:	68 79 39 10 f0       	push   $0xf0103979
f01039a8:	e8 55 17 00 00       	call   f0105102 <vprintfmt>
	return cnt;
}
f01039ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01039b0:	c9                   	leave  
f01039b1:	c3                   	ret    

f01039b2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01039b2:	55                   	push   %ebp
f01039b3:	89 e5                	mov    %esp,%ebp
f01039b5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01039b8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01039bb:	50                   	push   %eax
f01039bc:	ff 75 08             	push   0x8(%ebp)
f01039bf:	e8 c8 ff ff ff       	call   f010398c <vcprintf>
	va_end(ap);

	return cnt;
}
f01039c4:	c9                   	leave  
f01039c5:	c3                   	ret    

f01039c6 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01039c6:	55                   	push   %ebp
f01039c7:	89 e5                	mov    %esp,%ebp
f01039c9:	57                   	push   %edi
f01039ca:	56                   	push   %esi
f01039cb:	53                   	push   %ebx
f01039cc:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	//依照注释hints修改即可
	size_t i =thiscpu->cpu_id;
f01039cf:	e8 38 24 00 00       	call   f0105e0c <cpunum>
f01039d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01039d7:	0f b6 b8 20 90 25 f0 	movzbl -0xfda6fe0(%eax),%edi
f01039de:	89 f8                	mov    %edi,%eax
f01039e0:	0f b6 d8             	movzbl %al,%ebx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
f01039e3:	e8 24 24 00 00       	call   f0105e0c <cpunum>
f01039e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01039eb:	ba 00 f0 00 00       	mov    $0xf000,%edx
f01039f0:	29 da                	sub    %ebx,%edx
f01039f2:	c1 e2 10             	shl    $0x10,%edx
f01039f5:	89 90 30 90 25 f0    	mov    %edx,-0xfda6fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01039fb:	e8 0c 24 00 00       	call   f0105e0c <cpunum>
f0103a00:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a03:	66 c7 80 34 90 25 f0 	movw   $0x10,-0xfda6fcc(%eax)
f0103a0a:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);//这行不懂，直接较原来程序保持不变
f0103a0c:	e8 fb 23 00 00       	call   f0105e0c <cpunum>
f0103a11:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a14:	66 c7 80 92 90 25 f0 	movw   $0x68,-0xfda6f6e(%eax)
f0103a1b:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103a1d:	83 c3 05             	add    $0x5,%ebx
f0103a20:	e8 e7 23 00 00       	call   f0105e0c <cpunum>
f0103a25:	89 c6                	mov    %eax,%esi
f0103a27:	e8 e0 23 00 00       	call   f0105e0c <cpunum>
f0103a2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103a2f:	e8 d8 23 00 00       	call   f0105e0c <cpunum>
f0103a34:	66 c7 04 dd 40 53 12 	movw   $0x67,-0xfedacc0(,%ebx,8)
f0103a3b:	f0 67 00 
f0103a3e:	6b f6 74             	imul   $0x74,%esi,%esi
f0103a41:	81 c6 2c 90 25 f0    	add    $0xf025902c,%esi
f0103a47:	66 89 34 dd 42 53 12 	mov    %si,-0xfedacbe(,%ebx,8)
f0103a4e:	f0 
f0103a4f:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103a53:	81 c2 2c 90 25 f0    	add    $0xf025902c,%edx
f0103a59:	c1 ea 10             	shr    $0x10,%edx
f0103a5c:	88 14 dd 44 53 12 f0 	mov    %dl,-0xfedacbc(,%ebx,8)
f0103a63:	c6 04 dd 46 53 12 f0 	movb   $0x40,-0xfedacba(,%ebx,8)
f0103a6a:	40 
f0103a6b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a6e:	05 2c 90 25 f0       	add    $0xf025902c,%eax
f0103a73:	c1 e8 18             	shr    $0x18,%eax
f0103a76:	88 04 dd 47 53 12 f0 	mov    %al,-0xfedacb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103a7d:	c6 04 dd 45 53 12 f0 	movb   $0x89,-0xfedacbb(,%ebx,8)
f0103a84:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (i << 3));//相应的TSS选择子也要修改
f0103a85:	89 f8                	mov    %edi,%eax
f0103a87:	0f b6 f8             	movzbl %al,%edi
f0103a8a:	8d 3c fd 28 00 00 00 	lea    0x28(,%edi,8),%edi
	asm volatile("ltr %0" : : "r" (sel));
f0103a91:	0f 00 df             	ltr    %di
	asm volatile("lidt (%0)" : : "r" (p));
f0103a94:	b8 ac 53 12 f0       	mov    $0xf01253ac,%eax
f0103a99:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103a9c:	83 c4 1c             	add    $0x1c,%esp
f0103a9f:	5b                   	pop    %ebx
f0103aa0:	5e                   	pop    %esi
f0103aa1:	5f                   	pop    %edi
f0103aa2:	5d                   	pop    %ebp
f0103aa3:	c3                   	ret    

f0103aa4 <trap_init>:
{
f0103aa4:	55                   	push   %ebp
f0103aa5:	89 e5                	mov    %esp,%ebp
f0103aa7:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, DIVIDE_HANDLER, 0);//GD_KT  kernel text
f0103aaa:	b8 86 44 10 f0       	mov    $0xf0104486,%eax
f0103aaf:	66 a3 80 82 21 f0    	mov    %ax,0xf0218280
f0103ab5:	66 c7 05 82 82 21 f0 	movw   $0x8,0xf0218282
f0103abc:	08 00 
f0103abe:	c6 05 84 82 21 f0 00 	movb   $0x0,0xf0218284
f0103ac5:	c6 05 85 82 21 f0 8e 	movb   $0x8e,0xf0218285
f0103acc:	c1 e8 10             	shr    $0x10,%eax
f0103acf:	66 a3 86 82 21 f0    	mov    %ax,0xf0218286
	SETGATE(idt[T_DEBUG], 0, GD_KT, DEBUG_HANDLER, 0);
f0103ad5:	b8 90 44 10 f0       	mov    $0xf0104490,%eax
f0103ada:	66 a3 88 82 21 f0    	mov    %ax,0xf0218288
f0103ae0:	66 c7 05 8a 82 21 f0 	movw   $0x8,0xf021828a
f0103ae7:	08 00 
f0103ae9:	c6 05 8c 82 21 f0 00 	movb   $0x0,0xf021828c
f0103af0:	c6 05 8d 82 21 f0 8e 	movb   $0x8e,0xf021828d
f0103af7:	c1 e8 10             	shr    $0x10,%eax
f0103afa:	66 a3 8e 82 21 f0    	mov    %ax,0xf021828e
	SETGATE(idt[T_NMI], 0, GD_KT, NMI_HANDLER, 0);
f0103b00:	b8 96 44 10 f0       	mov    $0xf0104496,%eax
f0103b05:	66 a3 90 82 21 f0    	mov    %ax,0xf0218290
f0103b0b:	66 c7 05 92 82 21 f0 	movw   $0x8,0xf0218292
f0103b12:	08 00 
f0103b14:	c6 05 94 82 21 f0 00 	movb   $0x0,0xf0218294
f0103b1b:	c6 05 95 82 21 f0 8e 	movb   $0x8e,0xf0218295
f0103b22:	c1 e8 10             	shr    $0x10,%eax
f0103b25:	66 a3 96 82 21 f0    	mov    %ax,0xf0218296
	SETGATE(idt[T_BRKPT], 0, GD_KT, BRKPT_HANDLER, 3);//exercise 6在此处需要修改
f0103b2b:	b8 9c 44 10 f0       	mov    $0xf010449c,%eax
f0103b30:	66 a3 98 82 21 f0    	mov    %ax,0xf0218298
f0103b36:	66 c7 05 9a 82 21 f0 	movw   $0x8,0xf021829a
f0103b3d:	08 00 
f0103b3f:	c6 05 9c 82 21 f0 00 	movb   $0x0,0xf021829c
f0103b46:	c6 05 9d 82 21 f0 ee 	movb   $0xee,0xf021829d
f0103b4d:	c1 e8 10             	shr    $0x10,%eax
f0103b50:	66 a3 9e 82 21 f0    	mov    %ax,0xf021829e
	SETGATE(idt[T_OFLOW], 0, GD_KT, OFLOW_HANDLER, 0);
f0103b56:	b8 a2 44 10 f0       	mov    $0xf01044a2,%eax
f0103b5b:	66 a3 a0 82 21 f0    	mov    %ax,0xf02182a0
f0103b61:	66 c7 05 a2 82 21 f0 	movw   $0x8,0xf02182a2
f0103b68:	08 00 
f0103b6a:	c6 05 a4 82 21 f0 00 	movb   $0x0,0xf02182a4
f0103b71:	c6 05 a5 82 21 f0 8e 	movb   $0x8e,0xf02182a5
f0103b78:	c1 e8 10             	shr    $0x10,%eax
f0103b7b:	66 a3 a6 82 21 f0    	mov    %ax,0xf02182a6
	SETGATE(idt[T_BOUND], 0, GD_KT, BOUND_HANDLER, 0);
f0103b81:	b8 a8 44 10 f0       	mov    $0xf01044a8,%eax
f0103b86:	66 a3 a8 82 21 f0    	mov    %ax,0xf02182a8
f0103b8c:	66 c7 05 aa 82 21 f0 	movw   $0x8,0xf02182aa
f0103b93:	08 00 
f0103b95:	c6 05 ac 82 21 f0 00 	movb   $0x0,0xf02182ac
f0103b9c:	c6 05 ad 82 21 f0 8e 	movb   $0x8e,0xf02182ad
f0103ba3:	c1 e8 10             	shr    $0x10,%eax
f0103ba6:	66 a3 ae 82 21 f0    	mov    %ax,0xf02182ae
	SETGATE(idt[T_ILLOP], 0, GD_KT, ILLOP_HANDLER, 0);
f0103bac:	b8 ae 44 10 f0       	mov    $0xf01044ae,%eax
f0103bb1:	66 a3 b0 82 21 f0    	mov    %ax,0xf02182b0
f0103bb7:	66 c7 05 b2 82 21 f0 	movw   $0x8,0xf02182b2
f0103bbe:	08 00 
f0103bc0:	c6 05 b4 82 21 f0 00 	movb   $0x0,0xf02182b4
f0103bc7:	c6 05 b5 82 21 f0 8e 	movb   $0x8e,0xf02182b5
f0103bce:	c1 e8 10             	shr    $0x10,%eax
f0103bd1:	66 a3 b6 82 21 f0    	mov    %ax,0xf02182b6
	SETGATE(idt[T_DEVICE], 0, GD_KT, DEVICE_HANDLER, 0);
f0103bd7:	b8 b4 44 10 f0       	mov    $0xf01044b4,%eax
f0103bdc:	66 a3 b8 82 21 f0    	mov    %ax,0xf02182b8
f0103be2:	66 c7 05 ba 82 21 f0 	movw   $0x8,0xf02182ba
f0103be9:	08 00 
f0103beb:	c6 05 bc 82 21 f0 00 	movb   $0x0,0xf02182bc
f0103bf2:	c6 05 bd 82 21 f0 8e 	movb   $0x8e,0xf02182bd
f0103bf9:	c1 e8 10             	shr    $0x10,%eax
f0103bfc:	66 a3 be 82 21 f0    	mov    %ax,0xf02182be
	SETGATE(idt[T_DBLFLT], 0, GD_KT, DBLFLT_HANDLER, 0);
f0103c02:	b8 ba 44 10 f0       	mov    $0xf01044ba,%eax
f0103c07:	66 a3 c0 82 21 f0    	mov    %ax,0xf02182c0
f0103c0d:	66 c7 05 c2 82 21 f0 	movw   $0x8,0xf02182c2
f0103c14:	08 00 
f0103c16:	c6 05 c4 82 21 f0 00 	movb   $0x0,0xf02182c4
f0103c1d:	c6 05 c5 82 21 f0 8e 	movb   $0x8e,0xf02182c5
f0103c24:	c1 e8 10             	shr    $0x10,%eax
f0103c27:	66 a3 c6 82 21 f0    	mov    %ax,0xf02182c6
	SETGATE(idt[T_TSS], 0, GD_KT, TSS_HANDLER, 0);
f0103c2d:	b8 be 44 10 f0       	mov    $0xf01044be,%eax
f0103c32:	66 a3 d0 82 21 f0    	mov    %ax,0xf02182d0
f0103c38:	66 c7 05 d2 82 21 f0 	movw   $0x8,0xf02182d2
f0103c3f:	08 00 
f0103c41:	c6 05 d4 82 21 f0 00 	movb   $0x0,0xf02182d4
f0103c48:	c6 05 d5 82 21 f0 8e 	movb   $0x8e,0xf02182d5
f0103c4f:	c1 e8 10             	shr    $0x10,%eax
f0103c52:	66 a3 d6 82 21 f0    	mov    %ax,0xf02182d6
	SETGATE(idt[T_SEGNP], 0, GD_KT, SEGNP_HANDLER, 0);
f0103c58:	b8 c2 44 10 f0       	mov    $0xf01044c2,%eax
f0103c5d:	66 a3 d8 82 21 f0    	mov    %ax,0xf02182d8
f0103c63:	66 c7 05 da 82 21 f0 	movw   $0x8,0xf02182da
f0103c6a:	08 00 
f0103c6c:	c6 05 dc 82 21 f0 00 	movb   $0x0,0xf02182dc
f0103c73:	c6 05 dd 82 21 f0 8e 	movb   $0x8e,0xf02182dd
f0103c7a:	c1 e8 10             	shr    $0x10,%eax
f0103c7d:	66 a3 de 82 21 f0    	mov    %ax,0xf02182de
	SETGATE(idt[T_STACK], 0, GD_KT, STACK_HANDLER, 0);
f0103c83:	b8 c6 44 10 f0       	mov    $0xf01044c6,%eax
f0103c88:	66 a3 e0 82 21 f0    	mov    %ax,0xf02182e0
f0103c8e:	66 c7 05 e2 82 21 f0 	movw   $0x8,0xf02182e2
f0103c95:	08 00 
f0103c97:	c6 05 e4 82 21 f0 00 	movb   $0x0,0xf02182e4
f0103c9e:	c6 05 e5 82 21 f0 8e 	movb   $0x8e,0xf02182e5
f0103ca5:	c1 e8 10             	shr    $0x10,%eax
f0103ca8:	66 a3 e6 82 21 f0    	mov    %ax,0xf02182e6
	SETGATE(idt[T_GPFLT], 0, GD_KT, GPFLT_HANDLER, 0);
f0103cae:	b8 ca 44 10 f0       	mov    $0xf01044ca,%eax
f0103cb3:	66 a3 e8 82 21 f0    	mov    %ax,0xf02182e8
f0103cb9:	66 c7 05 ea 82 21 f0 	movw   $0x8,0xf02182ea
f0103cc0:	08 00 
f0103cc2:	c6 05 ec 82 21 f0 00 	movb   $0x0,0xf02182ec
f0103cc9:	c6 05 ed 82 21 f0 8e 	movb   $0x8e,0xf02182ed
f0103cd0:	c1 e8 10             	shr    $0x10,%eax
f0103cd3:	66 a3 ee 82 21 f0    	mov    %ax,0xf02182ee
	SETGATE(idt[T_PGFLT], 0, GD_KT, PGFLT_HANDLER, 0);
f0103cd9:	b8 ce 44 10 f0       	mov    $0xf01044ce,%eax
f0103cde:	66 a3 f0 82 21 f0    	mov    %ax,0xf02182f0
f0103ce4:	66 c7 05 f2 82 21 f0 	movw   $0x8,0xf02182f2
f0103ceb:	08 00 
f0103ced:	c6 05 f4 82 21 f0 00 	movb   $0x0,0xf02182f4
f0103cf4:	c6 05 f5 82 21 f0 8e 	movb   $0x8e,0xf02182f5
f0103cfb:	c1 e8 10             	shr    $0x10,%eax
f0103cfe:	66 a3 f6 82 21 f0    	mov    %ax,0xf02182f6
	SETGATE(idt[T_FPERR], 0, GD_KT, FPERR_HANDLER, 0);
f0103d04:	b8 d2 44 10 f0       	mov    $0xf01044d2,%eax
f0103d09:	66 a3 00 83 21 f0    	mov    %ax,0xf0218300
f0103d0f:	66 c7 05 02 83 21 f0 	movw   $0x8,0xf0218302
f0103d16:	08 00 
f0103d18:	c6 05 04 83 21 f0 00 	movb   $0x0,0xf0218304
f0103d1f:	c6 05 05 83 21 f0 8e 	movb   $0x8e,0xf0218305
f0103d26:	c1 e8 10             	shr    $0x10,%eax
f0103d29:	66 a3 06 83 21 f0    	mov    %ax,0xf0218306
	SETGATE(idt[T_ALIGN], 0, GD_KT, ALIGN_HANDLER, 0);
f0103d2f:	b8 d8 44 10 f0       	mov    $0xf01044d8,%eax
f0103d34:	66 a3 08 83 21 f0    	mov    %ax,0xf0218308
f0103d3a:	66 c7 05 0a 83 21 f0 	movw   $0x8,0xf021830a
f0103d41:	08 00 
f0103d43:	c6 05 0c 83 21 f0 00 	movb   $0x0,0xf021830c
f0103d4a:	c6 05 0d 83 21 f0 8e 	movb   $0x8e,0xf021830d
f0103d51:	c1 e8 10             	shr    $0x10,%eax
f0103d54:	66 a3 0e 83 21 f0    	mov    %ax,0xf021830e
	SETGATE(idt[T_MCHK], 0, GD_KT, MCHK_HANDLER, 0);
f0103d5a:	b8 dc 44 10 f0       	mov    $0xf01044dc,%eax
f0103d5f:	66 a3 10 83 21 f0    	mov    %ax,0xf0218310
f0103d65:	66 c7 05 12 83 21 f0 	movw   $0x8,0xf0218312
f0103d6c:	08 00 
f0103d6e:	c6 05 14 83 21 f0 00 	movb   $0x0,0xf0218314
f0103d75:	c6 05 15 83 21 f0 8e 	movb   $0x8e,0xf0218315
f0103d7c:	c1 e8 10             	shr    $0x10,%eax
f0103d7f:	66 a3 16 83 21 f0    	mov    %ax,0xf0218316
	SETGATE(idt[T_SIMDERR], 0, GD_KT, SIMDERR_HANDLER, 0);
f0103d85:	b8 e2 44 10 f0       	mov    $0xf01044e2,%eax
f0103d8a:	66 a3 18 83 21 f0    	mov    %ax,0xf0218318
f0103d90:	66 c7 05 1a 83 21 f0 	movw   $0x8,0xf021831a
f0103d97:	08 00 
f0103d99:	c6 05 1c 83 21 f0 00 	movb   $0x0,0xf021831c
f0103da0:	c6 05 1d 83 21 f0 8e 	movb   $0x8e,0xf021831d
f0103da7:	c1 e8 10             	shr    $0x10,%eax
f0103daa:	66 a3 1e 83 21 f0    	mov    %ax,0xf021831e
	SETGATE(idt[T_SYSCALL], 0 , GD_KT, SYSCALL_HANDLER, 3);//需要将dpl设置为3,因为这是用户态下调用的系统调用（中断）
f0103db0:	b8 e8 44 10 f0       	mov    $0xf01044e8,%eax
f0103db5:	66 a3 00 84 21 f0    	mov    %ax,0xf0218400
f0103dbb:	66 c7 05 02 84 21 f0 	movw   $0x8,0xf0218402
f0103dc2:	08 00 
f0103dc4:	c6 05 04 84 21 f0 00 	movb   $0x0,0xf0218404
f0103dcb:	c6 05 05 84 21 f0 ee 	movb   $0xee,0xf0218405
f0103dd2:	c1 e8 10             	shr    $0x10,%eax
f0103dd5:	66 a3 06 84 21 f0    	mov    %ax,0xf0218406
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],    0, GD_KT, timer_handler,   0);//中断是让内核抢占控制权，所以dpl应该设置为0。
f0103ddb:	b8 ee 44 10 f0       	mov    $0xf01044ee,%eax
f0103de0:	66 a3 80 83 21 f0    	mov    %ax,0xf0218380
f0103de6:	66 c7 05 82 83 21 f0 	movw   $0x8,0xf0218382
f0103ded:	08 00 
f0103def:	c6 05 84 83 21 f0 00 	movb   $0x0,0xf0218384
f0103df6:	c6 05 85 83 21 f0 8e 	movb   $0x8e,0xf0218385
f0103dfd:	c1 e8 10             	shr    $0x10,%eax
f0103e00:	66 a3 86 83 21 f0    	mov    %ax,0xf0218386
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD],      0, GD_KT, kbd_handler,     0);
f0103e06:	b8 f4 44 10 f0       	mov    $0xf01044f4,%eax
f0103e0b:	66 a3 88 83 21 f0    	mov    %ax,0xf0218388
f0103e11:	66 c7 05 8a 83 21 f0 	movw   $0x8,0xf021838a
f0103e18:	08 00 
f0103e1a:	c6 05 8c 83 21 f0 00 	movb   $0x0,0xf021838c
f0103e21:	c6 05 8d 83 21 f0 8e 	movb   $0x8e,0xf021838d
f0103e28:	c1 e8 10             	shr    $0x10,%eax
f0103e2b:	66 a3 8e 83 21 f0    	mov    %ax,0xf021838e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL],   0, GD_KT, serial_handler,  0);
f0103e31:	b8 fa 44 10 f0       	mov    $0xf01044fa,%eax
f0103e36:	66 a3 a0 83 21 f0    	mov    %ax,0xf02183a0
f0103e3c:	66 c7 05 a2 83 21 f0 	movw   $0x8,0xf02183a2
f0103e43:	08 00 
f0103e45:	c6 05 a4 83 21 f0 00 	movb   $0x0,0xf02183a4
f0103e4c:	c6 05 a5 83 21 f0 8e 	movb   $0x8e,0xf02183a5
f0103e53:	c1 e8 10             	shr    $0x10,%eax
f0103e56:	66 a3 a6 83 21 f0    	mov    %ax,0xf02183a6
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, spurious_handler,0);
f0103e5c:	b8 00 45 10 f0       	mov    $0xf0104500,%eax
f0103e61:	66 a3 b8 83 21 f0    	mov    %ax,0xf02183b8
f0103e67:	66 c7 05 ba 83 21 f0 	movw   $0x8,0xf02183ba
f0103e6e:	08 00 
f0103e70:	c6 05 bc 83 21 f0 00 	movb   $0x0,0xf02183bc
f0103e77:	c6 05 bd 83 21 f0 8e 	movb   $0x8e,0xf02183bd
f0103e7e:	c1 e8 10             	shr    $0x10,%eax
f0103e81:	66 a3 be 83 21 f0    	mov    %ax,0xf02183be
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE],      0, GD_KT, ide_handler,     0);
f0103e87:	b8 06 45 10 f0       	mov    $0xf0104506,%eax
f0103e8c:	66 a3 f0 83 21 f0    	mov    %ax,0xf02183f0
f0103e92:	66 c7 05 f2 83 21 f0 	movw   $0x8,0xf02183f2
f0103e99:	08 00 
f0103e9b:	c6 05 f4 83 21 f0 00 	movb   $0x0,0xf02183f4
f0103ea2:	c6 05 f5 83 21 f0 8e 	movb   $0x8e,0xf02183f5
f0103ea9:	c1 e8 10             	shr    $0x10,%eax
f0103eac:	66 a3 f6 83 21 f0    	mov    %ax,0xf02183f6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR],    0, GD_KT, error_handler,   0);
f0103eb2:	b8 0c 45 10 f0       	mov    $0xf010450c,%eax
f0103eb7:	66 a3 18 84 21 f0    	mov    %ax,0xf0218418
f0103ebd:	66 c7 05 1a 84 21 f0 	movw   $0x8,0xf021841a
f0103ec4:	08 00 
f0103ec6:	c6 05 1c 84 21 f0 00 	movb   $0x0,0xf021841c
f0103ecd:	c6 05 1d 84 21 f0 8e 	movb   $0x8e,0xf021841d
f0103ed4:	c1 e8 10             	shr    $0x10,%eax
f0103ed7:	66 a3 1e 84 21 f0    	mov    %ax,0xf021841e
	trap_init_percpu();
f0103edd:	e8 e4 fa ff ff       	call   f01039c6 <trap_init_percpu>
}
f0103ee2:	c9                   	leave  
f0103ee3:	c3                   	ret    

f0103ee4 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103ee4:	55                   	push   %ebp
f0103ee5:	89 e5                	mov    %esp,%ebp
f0103ee7:	53                   	push   %ebx
f0103ee8:	83 ec 0c             	sub    $0xc,%esp
f0103eeb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103eee:	ff 33                	push   (%ebx)
f0103ef0:	68 cf 77 10 f0       	push   $0xf01077cf
f0103ef5:	e8 b8 fa ff ff       	call   f01039b2 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103efa:	83 c4 08             	add    $0x8,%esp
f0103efd:	ff 73 04             	push   0x4(%ebx)
f0103f00:	68 de 77 10 f0       	push   $0xf01077de
f0103f05:	e8 a8 fa ff ff       	call   f01039b2 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103f0a:	83 c4 08             	add    $0x8,%esp
f0103f0d:	ff 73 08             	push   0x8(%ebx)
f0103f10:	68 ed 77 10 f0       	push   $0xf01077ed
f0103f15:	e8 98 fa ff ff       	call   f01039b2 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103f1a:	83 c4 08             	add    $0x8,%esp
f0103f1d:	ff 73 0c             	push   0xc(%ebx)
f0103f20:	68 fc 77 10 f0       	push   $0xf01077fc
f0103f25:	e8 88 fa ff ff       	call   f01039b2 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103f2a:	83 c4 08             	add    $0x8,%esp
f0103f2d:	ff 73 10             	push   0x10(%ebx)
f0103f30:	68 0b 78 10 f0       	push   $0xf010780b
f0103f35:	e8 78 fa ff ff       	call   f01039b2 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103f3a:	83 c4 08             	add    $0x8,%esp
f0103f3d:	ff 73 14             	push   0x14(%ebx)
f0103f40:	68 1a 78 10 f0       	push   $0xf010781a
f0103f45:	e8 68 fa ff ff       	call   f01039b2 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103f4a:	83 c4 08             	add    $0x8,%esp
f0103f4d:	ff 73 18             	push   0x18(%ebx)
f0103f50:	68 29 78 10 f0       	push   $0xf0107829
f0103f55:	e8 58 fa ff ff       	call   f01039b2 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103f5a:	83 c4 08             	add    $0x8,%esp
f0103f5d:	ff 73 1c             	push   0x1c(%ebx)
f0103f60:	68 38 78 10 f0       	push   $0xf0107838
f0103f65:	e8 48 fa ff ff       	call   f01039b2 <cprintf>
}
f0103f6a:	83 c4 10             	add    $0x10,%esp
f0103f6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103f70:	c9                   	leave  
f0103f71:	c3                   	ret    

f0103f72 <print_trapframe>:
{
f0103f72:	55                   	push   %ebp
f0103f73:	89 e5                	mov    %esp,%ebp
f0103f75:	56                   	push   %esi
f0103f76:	53                   	push   %ebx
f0103f77:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103f7a:	e8 8d 1e 00 00       	call   f0105e0c <cpunum>
f0103f7f:	83 ec 04             	sub    $0x4,%esp
f0103f82:	50                   	push   %eax
f0103f83:	53                   	push   %ebx
f0103f84:	68 9c 78 10 f0       	push   $0xf010789c
f0103f89:	e8 24 fa ff ff       	call   f01039b2 <cprintf>
	print_regs(&tf->tf_regs);
f0103f8e:	89 1c 24             	mov    %ebx,(%esp)
f0103f91:	e8 4e ff ff ff       	call   f0103ee4 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103f96:	83 c4 08             	add    $0x8,%esp
f0103f99:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103f9d:	50                   	push   %eax
f0103f9e:	68 ba 78 10 f0       	push   $0xf01078ba
f0103fa3:	e8 0a fa ff ff       	call   f01039b2 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103fa8:	83 c4 08             	add    $0x8,%esp
f0103fab:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103faf:	50                   	push   %eax
f0103fb0:	68 cd 78 10 f0       	push   $0xf01078cd
f0103fb5:	e8 f8 f9 ff ff       	call   f01039b2 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103fba:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103fbd:	83 c4 10             	add    $0x10,%esp
f0103fc0:	83 f8 13             	cmp    $0x13,%eax
f0103fc3:	0f 86 da 00 00 00    	jbe    f01040a3 <print_trapframe+0x131>
		return "System call";
f0103fc9:	ba 47 78 10 f0       	mov    $0xf0107847,%edx
	if (trapno == T_SYSCALL)
f0103fce:	83 f8 30             	cmp    $0x30,%eax
f0103fd1:	74 13                	je     f0103fe6 <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103fd3:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0103fd6:	83 fa 0f             	cmp    $0xf,%edx
f0103fd9:	ba 53 78 10 f0       	mov    $0xf0107853,%edx
f0103fde:	b9 62 78 10 f0       	mov    $0xf0107862,%ecx
f0103fe3:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103fe6:	83 ec 04             	sub    $0x4,%esp
f0103fe9:	52                   	push   %edx
f0103fea:	50                   	push   %eax
f0103feb:	68 e0 78 10 f0       	push   $0xf01078e0
f0103ff0:	e8 bd f9 ff ff       	call   f01039b2 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103ff5:	83 c4 10             	add    $0x10,%esp
f0103ff8:	39 1d 80 8a 21 f0    	cmp    %ebx,0xf0218a80
f0103ffe:	0f 84 ab 00 00 00    	je     f01040af <print_trapframe+0x13d>
	cprintf("  err  0x%08x", tf->tf_err);
f0104004:	83 ec 08             	sub    $0x8,%esp
f0104007:	ff 73 2c             	push   0x2c(%ebx)
f010400a:	68 01 79 10 f0       	push   $0xf0107901
f010400f:	e8 9e f9 ff ff       	call   f01039b2 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104014:	83 c4 10             	add    $0x10,%esp
f0104017:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010401b:	0f 85 b1 00 00 00    	jne    f01040d2 <print_trapframe+0x160>
			tf->tf_err & 1 ? "protection" : "not-present");
f0104021:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0104024:	a8 01                	test   $0x1,%al
f0104026:	b9 75 78 10 f0       	mov    $0xf0107875,%ecx
f010402b:	ba 80 78 10 f0       	mov    $0xf0107880,%edx
f0104030:	0f 44 ca             	cmove  %edx,%ecx
f0104033:	a8 02                	test   $0x2,%al
f0104035:	ba 8c 78 10 f0       	mov    $0xf010788c,%edx
f010403a:	be 92 78 10 f0       	mov    $0xf0107892,%esi
f010403f:	0f 44 d6             	cmove  %esi,%edx
f0104042:	a8 04                	test   $0x4,%al
f0104044:	b8 97 78 10 f0       	mov    $0xf0107897,%eax
f0104049:	be cc 79 10 f0       	mov    $0xf01079cc,%esi
f010404e:	0f 44 c6             	cmove  %esi,%eax
f0104051:	51                   	push   %ecx
f0104052:	52                   	push   %edx
f0104053:	50                   	push   %eax
f0104054:	68 0f 79 10 f0       	push   $0xf010790f
f0104059:	e8 54 f9 ff ff       	call   f01039b2 <cprintf>
f010405e:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104061:	83 ec 08             	sub    $0x8,%esp
f0104064:	ff 73 30             	push   0x30(%ebx)
f0104067:	68 1e 79 10 f0       	push   $0xf010791e
f010406c:	e8 41 f9 ff ff       	call   f01039b2 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104071:	83 c4 08             	add    $0x8,%esp
f0104074:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104078:	50                   	push   %eax
f0104079:	68 2d 79 10 f0       	push   $0xf010792d
f010407e:	e8 2f f9 ff ff       	call   f01039b2 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104083:	83 c4 08             	add    $0x8,%esp
f0104086:	ff 73 38             	push   0x38(%ebx)
f0104089:	68 40 79 10 f0       	push   $0xf0107940
f010408e:	e8 1f f9 ff ff       	call   f01039b2 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104093:	83 c4 10             	add    $0x10,%esp
f0104096:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010409a:	75 4b                	jne    f01040e7 <print_trapframe+0x175>
}
f010409c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010409f:	5b                   	pop    %ebx
f01040a0:	5e                   	pop    %esi
f01040a1:	5d                   	pop    %ebp
f01040a2:	c3                   	ret    
		return excnames[trapno];
f01040a3:	8b 14 85 80 7b 10 f0 	mov    -0xfef8480(,%eax,4),%edx
f01040aa:	e9 37 ff ff ff       	jmp    f0103fe6 <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01040af:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01040b3:	0f 85 4b ff ff ff    	jne    f0104004 <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01040b9:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01040bc:	83 ec 08             	sub    $0x8,%esp
f01040bf:	50                   	push   %eax
f01040c0:	68 f2 78 10 f0       	push   $0xf01078f2
f01040c5:	e8 e8 f8 ff ff       	call   f01039b2 <cprintf>
f01040ca:	83 c4 10             	add    $0x10,%esp
f01040cd:	e9 32 ff ff ff       	jmp    f0104004 <print_trapframe+0x92>
		cprintf("\n");
f01040d2:	83 ec 0c             	sub    $0xc,%esp
f01040d5:	68 b3 6c 10 f0       	push   $0xf0106cb3
f01040da:	e8 d3 f8 ff ff       	call   f01039b2 <cprintf>
f01040df:	83 c4 10             	add    $0x10,%esp
f01040e2:	e9 7a ff ff ff       	jmp    f0104061 <print_trapframe+0xef>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01040e7:	83 ec 08             	sub    $0x8,%esp
f01040ea:	ff 73 3c             	push   0x3c(%ebx)
f01040ed:	68 4f 79 10 f0       	push   $0xf010794f
f01040f2:	e8 bb f8 ff ff       	call   f01039b2 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01040f7:	83 c4 08             	add    $0x8,%esp
f01040fa:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01040fe:	50                   	push   %eax
f01040ff:	68 5e 79 10 f0       	push   $0xf010795e
f0104104:	e8 a9 f8 ff ff       	call   f01039b2 <cprintf>
f0104109:	83 c4 10             	add    $0x10,%esp
}
f010410c:	eb 8e                	jmp    f010409c <print_trapframe+0x12a>

f010410e <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010410e:	55                   	push   %ebp
f010410f:	89 e5                	mov    %esp,%ebp
f0104111:	57                   	push   %edi
f0104112:	56                   	push   %esi
f0104113:	53                   	push   %ebx
f0104114:	83 ec 0c             	sub    $0xc,%esp
f0104117:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010411a:	0f 20 d6             	mov    %cr2,%esi
	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	// LAB 3: Your code here.  CPL为0时，为内核态。
	if( (tf->tf_cs & 3) == 0) panic("page_fault in kernel mode, fault address %u\n", fault_va);
f010411d:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104121:	74 5d                	je     f0104180 <page_fault_handler+0x72>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.
	//注意， 其实并没有切换环境！！
	if (curenv->env_pgfault_upcall){
f0104123:	e8 e4 1c 00 00       	call   f0105e0c <cpunum>
f0104128:	6b c0 74             	imul   $0x74,%eax,%eax
f010412b:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0104131:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104135:	75 5e                	jne    f0104195 <page_fault_handler+0x87>
		curenv->env_tf.tf_esp        = (uint32_t) utf;

		env_run(curenv);
	}else{
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104137:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f010413a:	e8 cd 1c 00 00       	call   f0105e0c <cpunum>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010413f:	57                   	push   %edi
f0104140:	56                   	push   %esi
			curenv->env_id, fault_va, tf->tf_eip);
f0104141:	6b c0 74             	imul   $0x74,%eax,%eax
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104144:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f010414a:	ff 70 48             	push   0x48(%eax)
f010414d:	68 48 7b 10 f0       	push   $0xf0107b48
f0104152:	e8 5b f8 ff ff       	call   f01039b2 <cprintf>
		print_trapframe(tf);
f0104157:	89 1c 24             	mov    %ebx,(%esp)
f010415a:	e8 13 fe ff ff       	call   f0103f72 <print_trapframe>
		env_destroy(curenv);	
f010415f:	e8 a8 1c 00 00       	call   f0105e0c <cpunum>
f0104164:	83 c4 04             	add    $0x4,%esp
f0104167:	6b c0 74             	imul   $0x74,%eax,%eax
f010416a:	ff b0 28 90 25 f0    	push   -0xfda6fd8(%eax)
f0104170:	e8 03 f5 ff ff       	call   f0103678 <env_destroy>
	}
}
f0104175:	83 c4 10             	add    $0x10,%esp
f0104178:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010417b:	5b                   	pop    %ebx
f010417c:	5e                   	pop    %esi
f010417d:	5f                   	pop    %edi
f010417e:	5d                   	pop    %ebp
f010417f:	c3                   	ret    
	if( (tf->tf_cs & 3) == 0) panic("page_fault in kernel mode, fault address %u\n", fault_va);
f0104180:	56                   	push   %esi
f0104181:	68 18 7b 10 f0       	push   $0xf0107b18
f0104186:	68 71 01 00 00       	push   $0x171
f010418b:	68 71 79 10 f0       	push   $0xf0107971
f0104190:	e8 ab be ff ff       	call   f0100040 <_panic>
		if(UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1) // 发生异常时陷入。
f0104195:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104198:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f010419e:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
		if(UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1) // 发生异常时陷入。
f01041a3:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01041a9:	77 05                	ja     f01041b0 <page_fault_handler+0xa2>
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);//要求的32位空字。
f01041ab:	83 e8 38             	sub    $0x38,%eax
f01041ae:	89 c7                	mov    %eax,%edi
		user_mem_assert(curenv, (const void *) utf, sizeof(struct UTrapframe), PTE_P|PTE_W);
f01041b0:	e8 57 1c 00 00       	call   f0105e0c <cpunum>
f01041b5:	6a 03                	push   $0x3
f01041b7:	6a 34                	push   $0x34
f01041b9:	57                   	push   %edi
f01041ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01041bd:	ff b0 28 90 25 f0    	push   -0xfda6fd8(%eax)
f01041c3:	e8 c2 ed ff ff       	call   f0102f8a <user_mem_assert>
		utf->utf_fault_va = fault_va;
f01041c8:	89 fa                	mov    %edi,%edx
f01041ca:	89 37                	mov    %esi,(%edi)
		utf->utf_err      = tf->tf_trapno;
f01041cc:	8b 43 28             	mov    0x28(%ebx),%eax
f01041cf:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs     = tf->tf_regs;
f01041d2:	8d 7f 08             	lea    0x8(%edi),%edi
f01041d5:	b9 08 00 00 00       	mov    $0x8,%ecx
f01041da:	89 de                	mov    %ebx,%esi
f01041dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eflags   = tf->tf_eflags;
f01041de:	8b 43 38             	mov    0x38(%ebx),%eax
f01041e1:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_eip      = tf->tf_eip;
f01041e4:	8b 43 30             	mov    0x30(%ebx),%eax
f01041e7:	89 d7                	mov    %edx,%edi
f01041e9:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_esp      = tf->tf_esp;
f01041ec:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01041ef:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uint32_t) curenv->env_pgfault_upcall;
f01041f2:	e8 15 1c 00 00       	call   f0105e0c <cpunum>
f01041f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01041fa:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0104200:	8b 58 64             	mov    0x64(%eax),%ebx
f0104203:	e8 04 1c 00 00       	call   f0105e0c <cpunum>
f0104208:	6b c0 74             	imul   $0x74,%eax,%eax
f010420b:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0104211:	89 58 30             	mov    %ebx,0x30(%eax)
		curenv->env_tf.tf_esp        = (uint32_t) utf;
f0104214:	e8 f3 1b 00 00       	call   f0105e0c <cpunum>
f0104219:	6b c0 74             	imul   $0x74,%eax,%eax
f010421c:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0104222:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f0104225:	e8 e2 1b 00 00       	call   f0105e0c <cpunum>
f010422a:	83 c4 04             	add    $0x4,%esp
f010422d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104230:	ff b0 28 90 25 f0    	push   -0xfda6fd8(%eax)
f0104236:	e8 dc f4 ff ff       	call   f0103717 <env_run>

f010423b <trap>:
{
f010423b:	55                   	push   %ebp
f010423c:	89 e5                	mov    %esp,%ebp
f010423e:	57                   	push   %edi
f010423f:	56                   	push   %esi
f0104240:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0104243:	fc                   	cld    
	if (panicstr)
f0104244:	83 3d 00 80 21 f0 00 	cmpl   $0x0,0xf0218000
f010424b:	74 01                	je     f010424e <trap+0x13>
		asm volatile("hlt");
f010424d:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010424e:	e8 b9 1b 00 00       	call   f0105e0c <cpunum>
f0104253:	6b d0 74             	imul   $0x74,%eax,%edx
f0104256:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104259:	b8 01 00 00 00       	mov    $0x1,%eax
f010425e:	f0 87 82 20 90 25 f0 	lock xchg %eax,-0xfda6fe0(%edx)
f0104265:	83 f8 02             	cmp    $0x2,%eax
f0104268:	0f 84 80 00 00 00    	je     f01042ee <trap+0xb3>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010426e:	9c                   	pushf  
f010426f:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104270:	f6 c4 02             	test   $0x2,%ah
f0104273:	0f 85 8a 00 00 00    	jne    f0104303 <trap+0xc8>
	if ((tf->tf_cs & 3) == 3) {
f0104279:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010427d:	83 e0 03             	and    $0x3,%eax
f0104280:	66 83 f8 03          	cmp    $0x3,%ax
f0104284:	0f 84 92 00 00 00    	je     f010431c <trap+0xe1>
	last_tf = tf;
f010428a:	89 35 80 8a 21 f0    	mov    %esi,0xf0218a80
	switch(tf->tf_trapno) 
f0104290:	8b 46 28             	mov    0x28(%esi),%eax
f0104293:	83 f8 20             	cmp    $0x20,%eax
f0104296:	0f 84 81 01 00 00    	je     f010441d <trap+0x1e2>
f010429c:	0f 87 1f 01 00 00    	ja     f01043c1 <trap+0x186>
f01042a2:	83 f8 03             	cmp    $0x3,%eax
f01042a5:	0f 84 44 01 00 00    	je     f01043ef <trap+0x1b4>
f01042ab:	83 f8 0e             	cmp    $0xe,%eax
f01042ae:	0f 85 73 01 00 00    	jne    f0104427 <trap+0x1ec>
			page_fault_handler(tf);
f01042b4:	83 ec 0c             	sub    $0xc,%esp
f01042b7:	56                   	push   %esi
f01042b8:	e8 51 fe ff ff       	call   f010410e <page_fault_handler>
			break; 
f01042bd:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f01042c0:	e8 47 1b 00 00       	call   f0105e0c <cpunum>
f01042c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01042c8:	83 b8 28 90 25 f0 00 	cmpl   $0x0,-0xfda6fd8(%eax)
f01042cf:	74 18                	je     f01042e9 <trap+0xae>
f01042d1:	e8 36 1b 00 00       	call   f0105e0c <cpunum>
f01042d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01042d9:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f01042df:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01042e3:	0f 84 86 01 00 00    	je     f010446f <trap+0x234>
		sched_yield();
f01042e9:	e8 ff 02 00 00       	call   f01045ed <sched_yield>
	spin_lock(&kernel_lock);
f01042ee:	83 ec 0c             	sub    $0xc,%esp
f01042f1:	68 c0 53 12 f0       	push   $0xf01253c0
f01042f6:	e8 81 1d 00 00       	call   f010607c <spin_lock>
}
f01042fb:	83 c4 10             	add    $0x10,%esp
f01042fe:	e9 6b ff ff ff       	jmp    f010426e <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0104303:	68 7d 79 10 f0       	push   $0xf010797d
f0104308:	68 d5 69 10 f0       	push   $0xf01069d5
f010430d:	68 3c 01 00 00       	push   $0x13c
f0104312:	68 71 79 10 f0       	push   $0xf0107971
f0104317:	e8 24 bd ff ff       	call   f0100040 <_panic>
	spin_lock(&kernel_lock);
f010431c:	83 ec 0c             	sub    $0xc,%esp
f010431f:	68 c0 53 12 f0       	push   $0xf01253c0
f0104324:	e8 53 1d 00 00       	call   f010607c <spin_lock>
		assert(curenv);
f0104329:	e8 de 1a 00 00       	call   f0105e0c <cpunum>
f010432e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104331:	83 c4 10             	add    $0x10,%esp
f0104334:	83 b8 28 90 25 f0 00 	cmpl   $0x0,-0xfda6fd8(%eax)
f010433b:	74 3e                	je     f010437b <trap+0x140>
		if (curenv->env_status == ENV_DYING) {
f010433d:	e8 ca 1a 00 00       	call   f0105e0c <cpunum>
f0104342:	6b c0 74             	imul   $0x74,%eax,%eax
f0104345:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f010434b:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010434f:	74 43                	je     f0104394 <trap+0x159>
		curenv->env_tf = *tf;
f0104351:	e8 b6 1a 00 00       	call   f0105e0c <cpunum>
f0104356:	6b c0 74             	imul   $0x74,%eax,%eax
f0104359:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f010435f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104364:	89 c7                	mov    %eax,%edi
f0104366:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104368:	e8 9f 1a 00 00       	call   f0105e0c <cpunum>
f010436d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104370:	8b b0 28 90 25 f0    	mov    -0xfda6fd8(%eax),%esi
f0104376:	e9 0f ff ff ff       	jmp    f010428a <trap+0x4f>
		assert(curenv);
f010437b:	68 96 79 10 f0       	push   $0xf0107996
f0104380:	68 d5 69 10 f0       	push   $0xf01069d5
f0104385:	68 45 01 00 00       	push   $0x145
f010438a:	68 71 79 10 f0       	push   $0xf0107971
f010438f:	e8 ac bc ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f0104394:	e8 73 1a 00 00       	call   f0105e0c <cpunum>
f0104399:	83 ec 0c             	sub    $0xc,%esp
f010439c:	6b c0 74             	imul   $0x74,%eax,%eax
f010439f:	ff b0 28 90 25 f0    	push   -0xfda6fd8(%eax)
f01043a5:	e8 f1 f0 ff ff       	call   f010349b <env_free>
			curenv = NULL;
f01043aa:	e8 5d 1a 00 00       	call   f0105e0c <cpunum>
f01043af:	6b c0 74             	imul   $0x74,%eax,%eax
f01043b2:	c7 80 28 90 25 f0 00 	movl   $0x0,-0xfda6fd8(%eax)
f01043b9:	00 00 00 
			sched_yield();
f01043bc:	e8 2c 02 00 00       	call   f01045ed <sched_yield>
	switch(tf->tf_trapno) 
f01043c1:	83 f8 27             	cmp    $0x27,%eax
f01043c4:	74 3a                	je     f0104400 <trap+0x1c5>
f01043c6:	83 f8 30             	cmp    $0x30,%eax
f01043c9:	75 5c                	jne    f0104427 <trap+0x1ec>
			int32_t ret=syscall(tf->tf_regs.reg_eax, /*lab的文档中说应用程序将在寄存器中传递系统调用编号和系统调用参数。这样，内核就不需要遍历用户环境的栈或指令流。系统调用编号将进入%eax。但是在哪里实现的我也不清楚。*/
f01043cb:	83 ec 08             	sub    $0x8,%esp
f01043ce:	ff 76 04             	push   0x4(%esi)
f01043d1:	ff 36                	push   (%esi)
f01043d3:	ff 76 10             	push   0x10(%esi)
f01043d6:	ff 76 18             	push   0x18(%esi)
f01043d9:	ff 76 14             	push   0x14(%esi)
f01043dc:	ff 76 1c             	push   0x1c(%esi)
f01043df:	e8 90 02 00 00       	call   f0104674 <syscall>
			tf->tf_regs.reg_eax = ret;//将返回值传递回%eax，其将被传递回用户进程
f01043e4:	89 46 1c             	mov    %eax,0x1c(%esi)
			break;
f01043e7:	83 c4 20             	add    $0x20,%esp
f01043ea:	e9 d1 fe ff ff       	jmp    f01042c0 <trap+0x85>
			monitor(tf);
f01043ef:	83 ec 0c             	sub    $0xc,%esp
f01043f2:	56                   	push   %esi
f01043f3:	e8 44 c5 ff ff       	call   f010093c <monitor>
			break;
f01043f8:	83 c4 10             	add    $0x10,%esp
f01043fb:	e9 c0 fe ff ff       	jmp    f01042c0 <trap+0x85>
			cprintf("Spurious interrupt on irq 7\n");
f0104400:	83 ec 0c             	sub    $0xc,%esp
f0104403:	68 9d 79 10 f0       	push   $0xf010799d
f0104408:	e8 a5 f5 ff ff       	call   f01039b2 <cprintf>
			print_trapframe(tf);
f010440d:	89 34 24             	mov    %esi,(%esp)
f0104410:	e8 5d fb ff ff       	call   f0103f72 <print_trapframe>
			break;
f0104415:	83 c4 10             	add    $0x10,%esp
f0104418:	e9 a3 fe ff ff       	jmp    f01042c0 <trap+0x85>
			lapic_eoi();
f010441d:	e8 31 1b 00 00       	call   f0105f53 <lapic_eoi>
			sched_yield();
f0104422:	e8 c6 01 00 00       	call   f01045ed <sched_yield>
			print_trapframe(tf);
f0104427:	83 ec 0c             	sub    $0xc,%esp
f010442a:	56                   	push   %esi
f010442b:	e8 42 fb ff ff       	call   f0103f72 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f0104430:	83 c4 10             	add    $0x10,%esp
f0104433:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104438:	74 1e                	je     f0104458 <trap+0x21d>
				env_destroy(curenv);
f010443a:	e8 cd 19 00 00       	call   f0105e0c <cpunum>
f010443f:	83 ec 0c             	sub    $0xc,%esp
f0104442:	6b c0 74             	imul   $0x74,%eax,%eax
f0104445:	ff b0 28 90 25 f0    	push   -0xfda6fd8(%eax)
f010444b:	e8 28 f2 ff ff       	call   f0103678 <env_destroy>
				return;
f0104450:	83 c4 10             	add    $0x10,%esp
f0104453:	e9 68 fe ff ff       	jmp    f01042c0 <trap+0x85>
				panic("unhandled trap in kernel");
f0104458:	83 ec 04             	sub    $0x4,%esp
f010445b:	68 ba 79 10 f0       	push   $0xf01079ba
f0104460:	68 1f 01 00 00       	push   $0x11f
f0104465:	68 71 79 10 f0       	push   $0xf0107971
f010446a:	e8 d1 bb ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f010446f:	e8 98 19 00 00       	call   f0105e0c <cpunum>
f0104474:	83 ec 0c             	sub    $0xc,%esp
f0104477:	6b c0 74             	imul   $0x74,%eax,%eax
f010447a:	ff b0 28 90 25 f0    	push   -0xfda6fd8(%eax)
f0104480:	e8 92 f2 ff ff       	call   f0103717 <env_run>
f0104485:	90                   	nop

f0104486 <DIVIDE_HANDLER>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 //参见练习3中的 9.1 、9.10中的表，以及inc/trap.h 来完成这一部分。
TRAPHANDLER_NOEC(DIVIDE_HANDLER, T_DIVIDE);
f0104486:	6a 00                	push   $0x0
f0104488:	6a 00                	push   $0x0
f010448a:	e9 83 00 00 00       	jmp    f0104512 <_alltraps>
f010448f:	90                   	nop

f0104490 <DEBUG_HANDLER>:
TRAPHANDLER_NOEC(DEBUG_HANDLER, T_DEBUG);
f0104490:	6a 00                	push   $0x0
f0104492:	6a 01                	push   $0x1
f0104494:	eb 7c                	jmp    f0104512 <_alltraps>

f0104496 <NMI_HANDLER>:
TRAPHANDLER_NOEC(NMI_HANDLER, T_NMI);
f0104496:	6a 00                	push   $0x0
f0104498:	6a 02                	push   $0x2
f010449a:	eb 76                	jmp    f0104512 <_alltraps>

f010449c <BRKPT_HANDLER>:
TRAPHANDLER_NOEC(BRKPT_HANDLER, T_BRKPT);
f010449c:	6a 00                	push   $0x0
f010449e:	6a 03                	push   $0x3
f01044a0:	eb 70                	jmp    f0104512 <_alltraps>

f01044a2 <OFLOW_HANDLER>:
TRAPHANDLER_NOEC(OFLOW_HANDLER, T_OFLOW);
f01044a2:	6a 00                	push   $0x0
f01044a4:	6a 04                	push   $0x4
f01044a6:	eb 6a                	jmp    f0104512 <_alltraps>

f01044a8 <BOUND_HANDLER>:
TRAPHANDLER_NOEC(BOUND_HANDLER, T_BOUND);
f01044a8:	6a 00                	push   $0x0
f01044aa:	6a 05                	push   $0x5
f01044ac:	eb 64                	jmp    f0104512 <_alltraps>

f01044ae <ILLOP_HANDLER>:
TRAPHANDLER_NOEC(ILLOP_HANDLER, T_ILLOP);
f01044ae:	6a 00                	push   $0x0
f01044b0:	6a 06                	push   $0x6
f01044b2:	eb 5e                	jmp    f0104512 <_alltraps>

f01044b4 <DEVICE_HANDLER>:
TRAPHANDLER_NOEC(DEVICE_HANDLER, T_DEVICE);
f01044b4:	6a 00                	push   $0x0
f01044b6:	6a 07                	push   $0x7
f01044b8:	eb 58                	jmp    f0104512 <_alltraps>

f01044ba <DBLFLT_HANDLER>:
TRAPHANDLER(DBLFLT_HANDLER, T_DBLFLT);
f01044ba:	6a 08                	push   $0x8
f01044bc:	eb 54                	jmp    f0104512 <_alltraps>

f01044be <TSS_HANDLER>:
/* reserved */
TRAPHANDLER(TSS_HANDLER, T_TSS);
f01044be:	6a 0a                	push   $0xa
f01044c0:	eb 50                	jmp    f0104512 <_alltraps>

f01044c2 <SEGNP_HANDLER>:
TRAPHANDLER(SEGNP_HANDLER, T_SEGNP);
f01044c2:	6a 0b                	push   $0xb
f01044c4:	eb 4c                	jmp    f0104512 <_alltraps>

f01044c6 <STACK_HANDLER>:
TRAPHANDLER(STACK_HANDLER, T_STACK);
f01044c6:	6a 0c                	push   $0xc
f01044c8:	eb 48                	jmp    f0104512 <_alltraps>

f01044ca <GPFLT_HANDLER>:
TRAPHANDLER(GPFLT_HANDLER, T_GPFLT);
f01044ca:	6a 0d                	push   $0xd
f01044cc:	eb 44                	jmp    f0104512 <_alltraps>

f01044ce <PGFLT_HANDLER>:
TRAPHANDLER(PGFLT_HANDLER, T_PGFLT);
f01044ce:	6a 0e                	push   $0xe
f01044d0:	eb 40                	jmp    f0104512 <_alltraps>

f01044d2 <FPERR_HANDLER>:
/* reserved */
TRAPHANDLER_NOEC(FPERR_HANDLER, T_FPERR);
f01044d2:	6a 00                	push   $0x0
f01044d4:	6a 10                	push   $0x10
f01044d6:	eb 3a                	jmp    f0104512 <_alltraps>

f01044d8 <ALIGN_HANDLER>:
TRAPHANDLER(ALIGN_HANDLER, T_ALIGN);
f01044d8:	6a 11                	push   $0x11
f01044da:	eb 36                	jmp    f0104512 <_alltraps>

f01044dc <MCHK_HANDLER>:
TRAPHANDLER_NOEC(MCHK_HANDLER, T_MCHK);
f01044dc:	6a 00                	push   $0x0
f01044de:	6a 12                	push   $0x12
f01044e0:	eb 30                	jmp    f0104512 <_alltraps>

f01044e2 <SIMDERR_HANDLER>:
TRAPHANDLER_NOEC(SIMDERR_HANDLER, T_SIMDERR);
f01044e2:	6a 00                	push   $0x0
f01044e4:	6a 13                	push   $0x13
f01044e6:	eb 2a                	jmp    f0104512 <_alltraps>

f01044e8 <SYSCALL_HANDLER>:

//exercise 7 syscall
TRAPHANDLER_NOEC(SYSCALL_HANDLER, T_SYSCALL);
f01044e8:	6a 00                	push   $0x0
f01044ea:	6a 30                	push   $0x30
f01044ec:	eb 24                	jmp    f0104512 <_alltraps>

f01044ee <timer_handler>:

//lab4 exercise 13
//IRQS 
TRAPHANDLER_NOEC(timer_handler, IRQ_OFFSET + IRQ_TIMER);
f01044ee:	6a 00                	push   $0x0
f01044f0:	6a 20                	push   $0x20
f01044f2:	eb 1e                	jmp    f0104512 <_alltraps>

f01044f4 <kbd_handler>:
TRAPHANDLER_NOEC(kbd_handler, IRQ_OFFSET + IRQ_KBD);
f01044f4:	6a 00                	push   $0x0
f01044f6:	6a 21                	push   $0x21
f01044f8:	eb 18                	jmp    f0104512 <_alltraps>

f01044fa <serial_handler>:
TRAPHANDLER_NOEC(serial_handler, IRQ_OFFSET + IRQ_SERIAL);
f01044fa:	6a 00                	push   $0x0
f01044fc:	6a 24                	push   $0x24
f01044fe:	eb 12                	jmp    f0104512 <_alltraps>

f0104500 <spurious_handler>:
TRAPHANDLER_NOEC(spurious_handler, IRQ_OFFSET + IRQ_SPURIOUS);
f0104500:	6a 00                	push   $0x0
f0104502:	6a 27                	push   $0x27
f0104504:	eb 0c                	jmp    f0104512 <_alltraps>

f0104506 <ide_handler>:
TRAPHANDLER_NOEC(ide_handler, IRQ_OFFSET + IRQ_IDE);
f0104506:	6a 00                	push   $0x0
f0104508:	6a 2e                	push   $0x2e
f010450a:	eb 06                	jmp    f0104512 <_alltraps>

f010450c <error_handler>:
TRAPHANDLER_NOEC(error_handler, IRQ_OFFSET + IRQ_ERROR);
f010450c:	6a 00                	push   $0x0
f010450e:	6a 33                	push   $0x33
f0104510:	eb 00                	jmp    f0104512 <_alltraps>

f0104512 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
 	//别忘了栈由高地址向低地址生长，于是Trapframe顺序变为tf_trapno（上面两个宏已经把num压栈了），ds，es，PushRegs的反向
	pushl %ds
f0104512:	1e                   	push   %ds
	pushl %es
f0104513:	06                   	push   %es
	pushal
f0104514:	60                   	pusha  
	//
	movw $GD_KD, %ax 
f0104515:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f0104519:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f010451b:	8e c0                	mov    %eax,%es
	movw GD_KD, %ds
	movw GD_KD, %es
	*/
	
	//这是作为trap(struct Trapframe *tf)的参数的
	pushl %esp
f010451d:	54                   	push   %esp
	//调用trap
	call trap
f010451e:	e8 18 fd ff ff       	call   f010423b <trap>

f0104523 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104523:	55                   	push   %ebp
f0104524:	89 e5                	mov    %esp,%ebp
f0104526:	83 ec 08             	sub    $0x8,%esp
f0104529:	a1 70 82 21 f0       	mov    0xf0218270,%eax
f010452e:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104531:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104536:	8b 02                	mov    (%edx),%eax
f0104538:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010453b:	83 f8 02             	cmp    $0x2,%eax
f010453e:	76 2d                	jbe    f010456d <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f0104540:	83 c1 01             	add    $0x1,%ecx
f0104543:	83 c2 7c             	add    $0x7c,%edx
f0104546:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010454c:	75 e8                	jne    f0104536 <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f010454e:	83 ec 0c             	sub    $0xc,%esp
f0104551:	68 d0 7b 10 f0       	push   $0xf0107bd0
f0104556:	e8 57 f4 ff ff       	call   f01039b2 <cprintf>
f010455b:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010455e:	83 ec 0c             	sub    $0xc,%esp
f0104561:	6a 00                	push   $0x0
f0104563:	e8 d4 c3 ff ff       	call   f010093c <monitor>
f0104568:	83 c4 10             	add    $0x10,%esp
f010456b:	eb f1                	jmp    f010455e <sched_halt+0x3b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010456d:	e8 9a 18 00 00       	call   f0105e0c <cpunum>
f0104572:	6b c0 74             	imul   $0x74,%eax,%eax
f0104575:	c7 80 28 90 25 f0 00 	movl   $0x0,-0xfda6fd8(%eax)
f010457c:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010457f:	a1 5c 82 21 f0       	mov    0xf021825c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104584:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104589:	76 50                	jbe    f01045db <sched_halt+0xb8>
	return (physaddr_t)kva - KERNBASE;
f010458b:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f0104590:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104593:	e8 74 18 00 00       	call   f0105e0c <cpunum>
f0104598:	6b d0 74             	imul   $0x74,%eax,%edx
f010459b:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f010459e:	b8 02 00 00 00       	mov    $0x2,%eax
f01045a3:	f0 87 82 20 90 25 f0 	lock xchg %eax,-0xfda6fe0(%edx)
	spin_unlock(&kernel_lock);
f01045aa:	83 ec 0c             	sub    $0xc,%esp
f01045ad:	68 c0 53 12 f0       	push   $0xf01253c0
f01045b2:	e8 5f 1b 00 00       	call   f0106116 <spin_unlock>
	asm volatile("pause");
f01045b7:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01045b9:	e8 4e 18 00 00       	call   f0105e0c <cpunum>
f01045be:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f01045c1:	8b 80 30 90 25 f0    	mov    -0xfda6fd0(%eax),%eax
f01045c7:	bd 00 00 00 00       	mov    $0x0,%ebp
f01045cc:	89 c4                	mov    %eax,%esp
f01045ce:	6a 00                	push   $0x0
f01045d0:	6a 00                	push   $0x0
f01045d2:	fb                   	sti    
f01045d3:	f4                   	hlt    
f01045d4:	eb fd                	jmp    f01045d3 <sched_halt+0xb0>
}
f01045d6:	83 c4 10             	add    $0x10,%esp
f01045d9:	c9                   	leave  
f01045da:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01045db:	50                   	push   %eax
f01045dc:	68 88 64 10 f0       	push   $0xf0106488
f01045e1:	6a 4e                	push   $0x4e
f01045e3:	68 f9 7b 10 f0       	push   $0xf0107bf9
f01045e8:	e8 53 ba ff ff       	call   f0100040 <_panic>

f01045ed <sched_yield>:
{
f01045ed:	55                   	push   %ebp
f01045ee:	89 e5                	mov    %esp,%ebp
f01045f0:	57                   	push   %edi
f01045f1:	56                   	push   %esi
f01045f2:	53                   	push   %ebx
f01045f3:	83 ec 0c             	sub    $0xc,%esp
	struct Env * now = curenv;
f01045f6:	e8 11 18 00 00       	call   f0105e0c <cpunum>
f01045fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01045fe:	8b b0 28 90 25 f0    	mov    -0xfda6fd8(%eax),%esi
	int index=-1;//因为这里出错了！！一定是-1！！！
f0104604:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
	if(now/*定义于kern/env.h。可以看到其已经在lab4中被修改，适应多核*/) index= ENVX(now->env_id);//inc/env.h
f0104609:	85 f6                	test   %esi,%esi
f010460b:	74 09                	je     f0104616 <sched_yield+0x29>
f010460d:	8b 4e 48             	mov    0x48(%esi),%ecx
f0104610:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
	for(int i=index+1; i<index+NENV;i++){
f0104616:	8d 51 01             	lea    0x1(%ecx),%edx
		if(envs[i%NENV].env_status == ENV_RUNNABLE){
f0104619:	8b 1d 70 82 21 f0    	mov    0xf0218270,%ebx
	for(int i=index+1; i<index+NENV;i++){
f010461f:	81 c1 ff 03 00 00    	add    $0x3ff,%ecx
f0104625:	39 d1                	cmp    %edx,%ecx
f0104627:	7c 2b                	jl     f0104654 <sched_yield+0x67>
		if(envs[i%NENV].env_status == ENV_RUNNABLE){
f0104629:	89 d7                	mov    %edx,%edi
f010462b:	c1 ff 1f             	sar    $0x1f,%edi
f010462e:	c1 ef 16             	shr    $0x16,%edi
f0104631:	8d 04 3a             	lea    (%edx,%edi,1),%eax
f0104634:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104639:	29 f8                	sub    %edi,%eax
f010463b:	6b c0 7c             	imul   $0x7c,%eax,%eax
f010463e:	01 d8                	add    %ebx,%eax
f0104640:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104644:	74 05                	je     f010464b <sched_yield+0x5e>
	for(int i=index+1; i<index+NENV;i++){
f0104646:	83 c2 01             	add    $0x1,%edx
f0104649:	eb da                	jmp    f0104625 <sched_yield+0x38>
			env_run(&envs[i%NENV]);
f010464b:	83 ec 0c             	sub    $0xc,%esp
f010464e:	50                   	push   %eax
f010464f:	e8 c3 f0 ff ff       	call   f0103717 <env_run>
	if(now && now->env_status == ENV_RUNNING){
f0104654:	85 f6                	test   %esi,%esi
f0104656:	74 06                	je     f010465e <sched_yield+0x71>
f0104658:	83 7e 54 03          	cmpl   $0x3,0x54(%esi)
f010465c:	74 0d                	je     f010466b <sched_yield+0x7e>
	sched_halt();
f010465e:	e8 c0 fe ff ff       	call   f0104523 <sched_halt>
}
f0104663:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104666:	5b                   	pop    %ebx
f0104667:	5e                   	pop    %esi
f0104668:	5f                   	pop    %edi
f0104669:	5d                   	pop    %ebp
f010466a:	c3                   	ret    
		env_run(now);
f010466b:	83 ec 0c             	sub    $0xc,%esp
f010466e:	56                   	push   %esi
f010466f:	e8 a3 f0 ff ff       	call   f0103717 <env_run>

f0104674 <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
//它应该最终会调用lib/syscall.c中的syscall()。
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104674:	55                   	push   %ebp
f0104675:	89 e5                	mov    %esp,%ebp
f0104677:	57                   	push   %edi
f0104678:	56                   	push   %esi
f0104679:	53                   	push   %ebx
f010467a:	83 ec 1c             	sub    $0x1c,%esp
f010467d:	8b 45 08             	mov    0x8(%ebp),%eax
	// LAB 3: Your code here.

	// panic("syscall not implemented");
	
	//依据不同的syscallno， 调用lib/system.c中的不同函数
	switch (syscallno) 
f0104680:	83 f8 0c             	cmp    $0xc,%eax
f0104683:	0f 87 ca 05 00 00    	ja     f0104c53 <syscall+0x5df>
f0104689:	ff 24 85 40 7c 10 f0 	jmp    *-0xfef83c0(,%eax,4)
	user_mem_assert(curenv, s, len, 0);
f0104690:	e8 77 17 00 00       	call   f0105e0c <cpunum>
f0104695:	6a 00                	push   $0x0
f0104697:	ff 75 10             	push   0x10(%ebp)
f010469a:	ff 75 0c             	push   0xc(%ebp)
f010469d:	6b c0 74             	imul   $0x74,%eax,%eax
f01046a0:	ff b0 28 90 25 f0    	push   -0xfda6fd8(%eax)
f01046a6:	e8 df e8 ff ff       	call   f0102f8a <user_mem_assert>
	cprintf("%.*s", len, s);
f01046ab:	83 c4 0c             	add    $0xc,%esp
f01046ae:	ff 75 0c             	push   0xc(%ebp)
f01046b1:	ff 75 10             	push   0x10(%ebp)
f01046b4:	68 06 7c 10 f0       	push   $0xf0107c06
f01046b9:	e8 f4 f2 ff ff       	call   f01039b2 <cprintf>
}
f01046be:	83 c4 10             	add    $0x10,%esp
	{
		case SYS_cputs:
			sys_cputs( (const char *) a1, a2);
			return 0;
f01046c1:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_ipc_recv((void *)a1);
		default:
			return -E_INVAL;
	}
	return 0;
}
f01046c6:	89 d8                	mov    %ebx,%eax
f01046c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01046cb:	5b                   	pop    %ebx
f01046cc:	5e                   	pop    %esi
f01046cd:	5f                   	pop    %edi
f01046ce:	5d                   	pop    %ebp
f01046cf:	c3                   	ret    
	return cons_getc();
f01046d0:	e8 12 bf ff ff       	call   f01005e7 <cons_getc>
f01046d5:	89 c3                	mov    %eax,%ebx
			return sys_cgetc();
f01046d7:	eb ed                	jmp    f01046c6 <syscall+0x52>
	return curenv->env_id;
f01046d9:	e8 2e 17 00 00       	call   f0105e0c <cpunum>
f01046de:	6b c0 74             	imul   $0x74,%eax,%eax
f01046e1:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f01046e7:	8b 58 48             	mov    0x48(%eax),%ebx
			return sys_getenvid();
f01046ea:	eb da                	jmp    f01046c6 <syscall+0x52>
	if ((r = envid2env(envid, &e, 1)) < 0)
f01046ec:	83 ec 04             	sub    $0x4,%esp
f01046ef:	6a 01                	push   $0x1
f01046f1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046f4:	50                   	push   %eax
f01046f5:	ff 75 0c             	push   0xc(%ebp)
f01046f8:	e8 5f e9 ff ff       	call   f010305c <envid2env>
f01046fd:	89 c3                	mov    %eax,%ebx
f01046ff:	83 c4 10             	add    $0x10,%esp
f0104702:	85 c0                	test   %eax,%eax
f0104704:	78 c0                	js     f01046c6 <syscall+0x52>
	if (e == curenv)
f0104706:	e8 01 17 00 00       	call   f0105e0c <cpunum>
f010470b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010470e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104711:	39 90 28 90 25 f0    	cmp    %edx,-0xfda6fd8(%eax)
f0104717:	74 3d                	je     f0104756 <syscall+0xe2>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104719:	8b 5a 48             	mov    0x48(%edx),%ebx
f010471c:	e8 eb 16 00 00       	call   f0105e0c <cpunum>
f0104721:	83 ec 04             	sub    $0x4,%esp
f0104724:	53                   	push   %ebx
f0104725:	6b c0 74             	imul   $0x74,%eax,%eax
f0104728:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f010472e:	ff 70 48             	push   0x48(%eax)
f0104731:	68 26 7c 10 f0       	push   $0xf0107c26
f0104736:	e8 77 f2 ff ff       	call   f01039b2 <cprintf>
f010473b:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f010473e:	83 ec 0c             	sub    $0xc,%esp
f0104741:	ff 75 e4             	push   -0x1c(%ebp)
f0104744:	e8 2f ef ff ff       	call   f0103678 <env_destroy>
	return 0;
f0104749:	83 c4 10             	add    $0x10,%esp
f010474c:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_env_destroy(a1);
f0104751:	e9 70 ff ff ff       	jmp    f01046c6 <syscall+0x52>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104756:	e8 b1 16 00 00       	call   f0105e0c <cpunum>
f010475b:	83 ec 08             	sub    $0x8,%esp
f010475e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104761:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0104767:	ff 70 48             	push   0x48(%eax)
f010476a:	68 0b 7c 10 f0       	push   $0xf0107c0b
f010476f:	e8 3e f2 ff ff       	call   f01039b2 <cprintf>
f0104774:	83 c4 10             	add    $0x10,%esp
f0104777:	eb c5                	jmp    f010473e <syscall+0xca>
	sched_yield();
f0104779:	e8 6f fe ff ff       	call   f01045ed <sched_yield>
	struct Env *e=NULL;
f010477e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int error_ret=env_alloc( &e , curenv->env_id);
f0104785:	e8 82 16 00 00       	call   f0105e0c <cpunum>
f010478a:	83 ec 08             	sub    $0x8,%esp
f010478d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104790:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0104796:	ff 70 48             	push   0x48(%eax)
f0104799:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010479c:	50                   	push   %eax
f010479d:	e8 ce e9 ff ff       	call   f0103170 <env_alloc>
f01047a2:	89 c3                	mov    %eax,%ebx
	if(error_ret<0 ) return error_ret;
f01047a4:	83 c4 10             	add    $0x10,%esp
f01047a7:	85 c0                	test   %eax,%eax
f01047a9:	0f 88 17 ff ff ff    	js     f01046c6 <syscall+0x52>
	e->env_status = ENV_NOT_RUNNABLE;
f01047af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047b2:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf = curenv->env_tf;
f01047b9:	e8 4e 16 00 00       	call   f0105e0c <cpunum>
f01047be:	6b c0 74             	imul   $0x74,%eax,%eax
f01047c1:	8b b0 28 90 25 f0    	mov    -0xfda6fd8(%eax),%esi
f01047c7:	b9 11 00 00 00       	mov    $0x11,%ecx
f01047cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01047cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f01047d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047d4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;	
f01047db:	8b 58 48             	mov    0x48(%eax),%ebx
			return sys_exofork();
f01047de:	e9 e3 fe ff ff       	jmp    f01046c6 <syscall+0x52>
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) return -E_INVAL;  
f01047e3:	8b 45 10             	mov    0x10(%ebp),%eax
f01047e6:	83 e8 02             	sub    $0x2,%eax
f01047e9:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01047ee:	75 2b                	jne    f010481b <syscall+0x1a7>
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f01047f0:	83 ec 04             	sub    $0x4,%esp
f01047f3:	6a 01                	push   $0x1
f01047f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047f8:	50                   	push   %eax
f01047f9:	ff 75 0c             	push   0xc(%ebp)
f01047fc:	e8 5b e8 ff ff       	call   f010305c <envid2env>
f0104801:	83 c4 10             	add    $0x10,%esp
f0104804:	85 c0                	test   %eax,%eax
f0104806:	78 1d                	js     f0104825 <syscall+0x1b1>
	e->env_status = status;
f0104808:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010480b:	8b 7d 10             	mov    0x10(%ebp),%edi
f010480e:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;	
f0104811:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104816:	e9 ab fe ff ff       	jmp    f01046c6 <syscall+0x52>
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) return -E_INVAL;  
f010481b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104820:	e9 a1 fe ff ff       	jmp    f01046c6 <syscall+0x52>
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f0104825:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			return sys_env_set_status(a1,a2);
f010482a:	e9 97 fe ff ff       	jmp    f01046c6 <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f010482f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104832:	83 e0 05             	and    $0x5,%eax
f0104835:	83 f8 05             	cmp    $0x5,%eax
f0104838:	0f 85 86 00 00 00    	jne    f01048c4 <syscall+0x250>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f010483e:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f0104845:	0f 85 83 00 00 00    	jne    f01048ce <syscall+0x25a>
f010484b:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104852:	77 7a                	ja     f01048ce <syscall+0x25a>
f0104854:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010485b:	75 7b                	jne    f01048d8 <syscall+0x264>
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f010485d:	83 ec 0c             	sub    $0xc,%esp
f0104860:	6a 01                	push   $0x1
f0104862:	e8 ad c6 ff ff       	call   f0100f14 <page_alloc>
f0104867:	89 c6                	mov    %eax,%esi
	if( pp==NULL ) return -E_NO_MEM;
f0104869:	83 c4 10             	add    $0x10,%esp
f010486c:	85 c0                	test   %eax,%eax
f010486e:	74 72                	je     f01048e2 <syscall+0x26e>
	int error_ret=envid2env(envid, &e, 1);
f0104870:	83 ec 04             	sub    $0x4,%esp
f0104873:	6a 01                	push   $0x1
f0104875:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104878:	50                   	push   %eax
f0104879:	ff 75 0c             	push   0xc(%ebp)
f010487c:	e8 db e7 ff ff       	call   f010305c <envid2env>
f0104881:	89 c3                	mov    %eax,%ebx
	if( error_ret <0 ) return error_ret;//error_ret 其实就是我们调用函数发生错误时的返回值， 这不同函数之间都是一致的。
f0104883:	83 c4 10             	add    $0x10,%esp
f0104886:	85 c0                	test   %eax,%eax
f0104888:	0f 88 38 fe ff ff    	js     f01046c6 <syscall+0x52>
	error_ret=page_insert(e->env_pgdir, pp, va, perm);
f010488e:	ff 75 14             	push   0x14(%ebp)
f0104891:	ff 75 10             	push   0x10(%ebp)
f0104894:	56                   	push   %esi
f0104895:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104898:	ff 70 60             	push   0x60(%eax)
f010489b:	e8 82 c9 ff ff       	call   f0101222 <page_insert>
f01048a0:	89 c3                	mov    %eax,%ebx
	if(error_ret <0){
f01048a2:	83 c4 10             	add    $0x10,%esp
f01048a5:	85 c0                	test   %eax,%eax
f01048a7:	78 0a                	js     f01048b3 <syscall+0x23f>
	return 0;		
f01048a9:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_page_alloc(a1,(void *)a2, (int)a3);
f01048ae:	e9 13 fe ff ff       	jmp    f01046c6 <syscall+0x52>
		page_free(pp);
f01048b3:	83 ec 0c             	sub    $0xc,%esp
f01048b6:	56                   	push   %esi
f01048b7:	e8 cd c6 ff ff       	call   f0100f89 <page_free>
		return error_ret;
f01048bc:	83 c4 10             	add    $0x10,%esp
f01048bf:	e9 02 fe ff ff       	jmp    f01046c6 <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f01048c4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048c9:	e9 f8 fd ff ff       	jmp    f01046c6 <syscall+0x52>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f01048ce:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048d3:	e9 ee fd ff ff       	jmp    f01046c6 <syscall+0x52>
f01048d8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048dd:	e9 e4 fd ff ff       	jmp    f01046c6 <syscall+0x52>
	if( pp==NULL ) return -E_NO_MEM;
f01048e2:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01048e7:	e9 da fd ff ff       	jmp    f01046c6 <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f01048ec:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01048ef:	83 e0 05             	and    $0x5,%eax
f01048f2:	83 f8 05             	cmp    $0x5,%eax
f01048f5:	0f 85 c0 00 00 00    	jne    f01049bb <syscall+0x347>
	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
f01048fb:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104902:	0f 85 bd 00 00 00    	jne    f01049c5 <syscall+0x351>
f0104908:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010490f:	0f 87 b0 00 00 00    	ja     f01049c5 <syscall+0x351>
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
f0104915:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010491c:	0f 87 ad 00 00 00    	ja     f01049cf <syscall+0x35b>
f0104922:	8b 45 10             	mov    0x10(%ebp),%eax
f0104925:	0b 45 18             	or     0x18(%ebp),%eax
f0104928:	a9 ff 0f 00 00       	test   $0xfff,%eax
f010492d:	0f 85 a6 00 00 00    	jne    f01049d9 <syscall+0x365>
	if (envid2env(srcenvid, &src_e, 1)<0 || envid2env(dstenvid, &dst_e, 1)<0) return -E_BAD_ENV;
f0104933:	83 ec 04             	sub    $0x4,%esp
f0104936:	6a 01                	push   $0x1
f0104938:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010493b:	50                   	push   %eax
f010493c:	ff 75 0c             	push   0xc(%ebp)
f010493f:	e8 18 e7 ff ff       	call   f010305c <envid2env>
f0104944:	83 c4 10             	add    $0x10,%esp
f0104947:	85 c0                	test   %eax,%eax
f0104949:	0f 88 94 00 00 00    	js     f01049e3 <syscall+0x36f>
f010494f:	83 ec 04             	sub    $0x4,%esp
f0104952:	6a 01                	push   $0x1
f0104954:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104957:	50                   	push   %eax
f0104958:	ff 75 14             	push   0x14(%ebp)
f010495b:	e8 fc e6 ff ff       	call   f010305c <envid2env>
f0104960:	83 c4 10             	add    $0x10,%esp
f0104963:	85 c0                	test   %eax,%eax
f0104965:	0f 88 82 00 00 00    	js     f01049ed <syscall+0x379>
	struct PageInfo *pp = page_lookup(src_e->env_pgdir, srcva, &src_pte);
f010496b:	83 ec 04             	sub    $0x4,%esp
f010496e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104971:	50                   	push   %eax
f0104972:	ff 75 10             	push   0x10(%ebp)
f0104975:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104978:	ff 70 60             	push   0x60(%eax)
f010497b:	e8 c8 c7 ff ff       	call   f0101148 <page_lookup>
	if( pp==NULL ) return -E_INVAL;
f0104980:	83 c4 10             	add    $0x10,%esp
f0104983:	85 c0                	test   %eax,%eax
f0104985:	74 70                	je     f01049f7 <syscall+0x383>
	if ( ( ( *src_pte & PTE_W ) == 0 ) && ( (perm & PTE_W) == PTE_W ) ) return -E_INVAL;
f0104987:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010498a:	f6 02 02             	testb  $0x2,(%edx)
f010498d:	75 06                	jne    f0104995 <syscall+0x321>
f010498f:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104993:	75 6c                	jne    f0104a01 <syscall+0x38d>
	int error_ret =page_insert(dst_e->env_pgdir, pp, dstva, perm);
f0104995:	ff 75 1c             	push   0x1c(%ebp)
f0104998:	ff 75 18             	push   0x18(%ebp)
f010499b:	50                   	push   %eax
f010499c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010499f:	ff 70 60             	push   0x60(%eax)
f01049a2:	e8 7b c8 ff ff       	call   f0101222 <page_insert>
f01049a7:	85 c0                	test   %eax,%eax
f01049a9:	ba 00 00 00 00       	mov    $0x0,%edx
f01049ae:	0f 4e d0             	cmovle %eax,%edx
f01049b1:	89 d3                	mov    %edx,%ebx
f01049b3:	83 c4 10             	add    $0x10,%esp
f01049b6:	e9 0b fd ff ff       	jmp    f01046c6 <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f01049bb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049c0:	e9 01 fd ff ff       	jmp    f01046c6 <syscall+0x52>
	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
f01049c5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049ca:	e9 f7 fc ff ff       	jmp    f01046c6 <syscall+0x52>
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
f01049cf:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049d4:	e9 ed fc ff ff       	jmp    f01046c6 <syscall+0x52>
f01049d9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049de:	e9 e3 fc ff ff       	jmp    f01046c6 <syscall+0x52>
	if (envid2env(srcenvid, &src_e, 1)<0 || envid2env(dstenvid, &dst_e, 1)<0) return -E_BAD_ENV;
f01049e3:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01049e8:	e9 d9 fc ff ff       	jmp    f01046c6 <syscall+0x52>
f01049ed:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01049f2:	e9 cf fc ff ff       	jmp    f01046c6 <syscall+0x52>
	if( pp==NULL ) return -E_INVAL;
f01049f7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049fc:	e9 c5 fc ff ff       	jmp    f01046c6 <syscall+0x52>
	if ( ( ( *src_pte & PTE_W ) == 0 ) && ( (perm & PTE_W) == PTE_W ) ) return -E_INVAL;
f0104a01:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_page_map(a1, (void *)a2, a3, (void*)a4, (int)a5);
f0104a06:	e9 bb fc ff ff       	jmp    f01046c6 <syscall+0x52>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f0104a0b:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104a12:	77 45                	ja     f0104a59 <syscall+0x3e5>
f0104a14:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104a1b:	75 46                	jne    f0104a63 <syscall+0x3ef>
	int error_ret=envid2env(envid, &e, 1);
f0104a1d:	83 ec 04             	sub    $0x4,%esp
f0104a20:	6a 01                	push   $0x1
f0104a22:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a25:	50                   	push   %eax
f0104a26:	ff 75 0c             	push   0xc(%ebp)
f0104a29:	e8 2e e6 ff ff       	call   f010305c <envid2env>
f0104a2e:	89 c3                	mov    %eax,%ebx
	if( error_ret <0 ) return error_ret;
f0104a30:	83 c4 10             	add    $0x10,%esp
f0104a33:	85 c0                	test   %eax,%eax
f0104a35:	0f 88 8b fc ff ff    	js     f01046c6 <syscall+0x52>
	page_remove(e->env_pgdir, va);
f0104a3b:	83 ec 08             	sub    $0x8,%esp
f0104a3e:	ff 75 10             	push   0x10(%ebp)
f0104a41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a44:	ff 70 60             	push   0x60(%eax)
f0104a47:	e8 90 c7 ff ff       	call   f01011dc <page_remove>
	return 0;
f0104a4c:	83 c4 10             	add    $0x10,%esp
f0104a4f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a54:	e9 6d fc ff ff       	jmp    f01046c6 <syscall+0x52>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f0104a59:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a5e:	e9 63 fc ff ff       	jmp    f01046c6 <syscall+0x52>
f0104a63:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_page_unmap(a1, (void *)a2);
f0104a68:	e9 59 fc ff ff       	jmp    f01046c6 <syscall+0x52>
	int error_ret= envid2env(envid, &e, 1);
f0104a6d:	83 ec 04             	sub    $0x4,%esp
f0104a70:	6a 01                	push   $0x1
f0104a72:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a75:	50                   	push   %eax
f0104a76:	ff 75 0c             	push   0xc(%ebp)
f0104a79:	e8 de e5 ff ff       	call   f010305c <envid2env>
f0104a7e:	89 c3                	mov    %eax,%ebx
	if(error_ret < 0 ) return error_ret;
f0104a80:	83 c4 10             	add    $0x10,%esp
f0104a83:	85 c0                	test   %eax,%eax
f0104a85:	0f 88 3b fc ff ff    	js     f01046c6 <syscall+0x52>
	e->env_pgfault_upcall = func;
f0104a8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104a91:	89 48 64             	mov    %ecx,0x64(%eax)
	return 0;
f0104a94:	bb 00 00 00 00       	mov    $0x0,%ebx
        		return sys_env_set_pgfault_upcall(a1, (void*) a2);
f0104a99:	e9 28 fc ff ff       	jmp    f01046c6 <syscall+0x52>
	if ( (r = envid2env( envid, &dstenv, 0)) < 0)  return r;
f0104a9e:	83 ec 04             	sub    $0x4,%esp
f0104aa1:	6a 00                	push   $0x0
f0104aa3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104aa6:	50                   	push   %eax
f0104aa7:	ff 75 0c             	push   0xc(%ebp)
f0104aaa:	e8 ad e5 ff ff       	call   f010305c <envid2env>
f0104aaf:	89 c3                	mov    %eax,%ebx
f0104ab1:	83 c4 10             	add    $0x10,%esp
f0104ab4:	85 c0                	test   %eax,%eax
f0104ab6:	0f 88 0a fc ff ff    	js     f01046c6 <syscall+0x52>
	if ( (dstenv->env_ipc_recving != true)  || dstenv->env_ipc_from != 0)  return -E_IPC_NOT_RECV;
f0104abc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104abf:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104ac3:	0f 84 05 01 00 00    	je     f0104bce <syscall+0x55a>
f0104ac9:	8b 58 74             	mov    0x74(%eax),%ebx
f0104acc:	85 db                	test   %ebx,%ebx
f0104ace:	0f 85 04 01 00 00    	jne    f0104bd8 <syscall+0x564>
	dstenv->env_ipc_perm=0;//如果没转移页，设置为0
f0104ad4:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	if((uintptr_t) srcva <  UTOP){
f0104adb:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104ae2:	0f 87 8a 00 00 00    	ja     f0104b72 <syscall+0x4fe>
		if (  !(perm & PTE_P ) || !(perm & PTE_U) )  return -E_INVAL;
f0104ae8:	8b 45 18             	mov    0x18(%ebp),%eax
f0104aeb:	83 e0 05             	and    $0x5,%eax
f0104aee:	83 f8 05             	cmp    $0x5,%eax
f0104af1:	0f 85 b2 00 00 00    	jne    f0104ba9 <syscall+0x535>
		if ( PGOFF(srcva) )  return -E_INVAL;
f0104af7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104afa:	25 ff 0f 00 00       	and    $0xfff,%eax
		if (perm &  (~ PTE_SYSCALL))   return -E_INVAL; 
f0104aff:	8b 55 18             	mov    0x18(%ebp),%edx
f0104b02:	81 e2 f8 f1 ff ff    	and    $0xfffff1f8,%edx
f0104b08:	09 d0                	or     %edx,%eax
f0104b0a:	74 0a                	je     f0104b16 <syscall+0x4a2>
f0104b0c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b11:	e9 b0 fb ff ff       	jmp    f01046c6 <syscall+0x52>
		if ((pp = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL )  return -E_INVAL;
f0104b16:	e8 f1 12 00 00       	call   f0105e0c <cpunum>
f0104b1b:	83 ec 04             	sub    $0x4,%esp
f0104b1e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104b21:	52                   	push   %edx
f0104b22:	ff 75 14             	push   0x14(%ebp)
f0104b25:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b28:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0104b2e:	ff 70 60             	push   0x60(%eax)
f0104b31:	e8 12 c6 ff ff       	call   f0101148 <page_lookup>
f0104b36:	83 c4 10             	add    $0x10,%esp
f0104b39:	85 c0                	test   %eax,%eax
f0104b3b:	74 76                	je     f0104bb3 <syscall+0x53f>
		if ((perm & PTE_W) && !(*pte & PTE_W) )   return -E_INVAL;
f0104b3d:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104b41:	74 08                	je     f0104b4b <syscall+0x4d7>
f0104b43:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b46:	f6 02 02             	testb  $0x2,(%edx)
f0104b49:	74 72                	je     f0104bbd <syscall+0x549>
		if (dstenv->env_ipc_dstva) {
f0104b4b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b4e:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104b51:	85 c9                	test   %ecx,%ecx
f0104b53:	74 1d                	je     f0104b72 <syscall+0x4fe>
			if( (r = page_insert(dstenv->env_pgdir, pp, dstenv->env_ipc_dstva,  perm) ) < 0)  return r;
f0104b55:	ff 75 18             	push   0x18(%ebp)
f0104b58:	51                   	push   %ecx
f0104b59:	50                   	push   %eax
f0104b5a:	ff 72 60             	push   0x60(%edx)
f0104b5d:	e8 c0 c6 ff ff       	call   f0101222 <page_insert>
f0104b62:	83 c4 10             	add    $0x10,%esp
f0104b65:	85 c0                	test   %eax,%eax
f0104b67:	78 5e                	js     f0104bc7 <syscall+0x553>
			dstenv->env_ipc_perm = perm;
f0104b69:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b6c:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104b6f:	89 48 78             	mov    %ecx,0x78(%eax)
	dstenv->env_ipc_recving = false;
f0104b72:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b75:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	dstenv->env_ipc_from = curenv->env_id;
f0104b79:	e8 8e 12 00 00       	call   f0105e0c <cpunum>
f0104b7e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b81:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b84:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0104b8a:	8b 40 48             	mov    0x48(%eax),%eax
f0104b8d:	89 42 74             	mov    %eax,0x74(%edx)
	dstenv->env_ipc_value = value;
f0104b90:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b93:	89 42 70             	mov    %eax,0x70(%edx)
	dstenv->env_status = ENV_RUNNABLE;
f0104b96:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	dstenv->env_tf.tf_regs.reg_eax = 0;
f0104b9d:	c7 42 1c 00 00 00 00 	movl   $0x0,0x1c(%edx)
	return 0;
f0104ba4:	e9 1d fb ff ff       	jmp    f01046c6 <syscall+0x52>
		if (  !(perm & PTE_P ) || !(perm & PTE_U) )  return -E_INVAL;
f0104ba9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bae:	e9 13 fb ff ff       	jmp    f01046c6 <syscall+0x52>
		if ((pp = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL )  return -E_INVAL;
f0104bb3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bb8:	e9 09 fb ff ff       	jmp    f01046c6 <syscall+0x52>
		if ((perm & PTE_W) && !(*pte & PTE_W) )   return -E_INVAL;
f0104bbd:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bc2:	e9 ff fa ff ff       	jmp    f01046c6 <syscall+0x52>
			if( (r = page_insert(dstenv->env_pgdir, pp, dstenv->env_ipc_dstva,  perm) ) < 0)  return r;
f0104bc7:	89 c3                	mov    %eax,%ebx
f0104bc9:	e9 f8 fa ff ff       	jmp    f01046c6 <syscall+0x52>
	if ( (dstenv->env_ipc_recving != true)  || dstenv->env_ipc_from != 0)  return -E_IPC_NOT_RECV;
f0104bce:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104bd3:	e9 ee fa ff ff       	jmp    f01046c6 <syscall+0x52>
f0104bd8:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0104bdd:	e9 e4 fa ff ff       	jmp    f01046c6 <syscall+0x52>
	if ((uintptr_t) dstva < UTOP && PGOFF(dstva) != 0) return -E_INVAL;
f0104be2:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104be9:	77 13                	ja     f0104bfe <syscall+0x58a>
f0104beb:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104bf2:	74 0a                	je     f0104bfe <syscall+0x58a>
			return sys_ipc_recv((void *)a1);
f0104bf4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bf9:	e9 c8 fa ff ff       	jmp    f01046c6 <syscall+0x52>
	curenv->env_ipc_recving = true;
f0104bfe:	e8 09 12 00 00       	call   f0105e0c <cpunum>
f0104c03:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c06:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0104c0c:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104c10:	e8 f7 11 00 00       	call   f0105e0c <cpunum>
f0104c15:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c18:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0104c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104c21:	89 48 6c             	mov    %ecx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104c24:	e8 e3 11 00 00       	call   f0105e0c <cpunum>
f0104c29:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c2c:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0104c32:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_from = 0;
f0104c39:	e8 ce 11 00 00       	call   f0105e0c <cpunum>
f0104c3e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c41:	8b 80 28 90 25 f0    	mov    -0xfda6fd8(%eax),%eax
f0104c47:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	sched_yield();
f0104c4e:	e8 9a f9 ff ff       	call   f01045ed <sched_yield>
	switch (syscallno) 
f0104c53:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c58:	e9 69 fa ff ff       	jmp    f01046c6 <syscall+0x52>

f0104c5d <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104c5d:	55                   	push   %ebp
f0104c5e:	89 e5                	mov    %esp,%ebp
f0104c60:	57                   	push   %edi
f0104c61:	56                   	push   %esi
f0104c62:	53                   	push   %ebx
f0104c63:	83 ec 14             	sub    $0x14,%esp
f0104c66:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104c6c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c6f:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c72:	8b 1a                	mov    (%edx),%ebx
f0104c74:	8b 01                	mov    (%ecx),%eax
f0104c76:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c79:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104c80:	eb 2f                	jmp    f0104cb1 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104c82:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104c85:	39 c3                	cmp    %eax,%ebx
f0104c87:	7f 4e                	jg     f0104cd7 <stab_binsearch+0x7a>
f0104c89:	0f b6 0a             	movzbl (%edx),%ecx
f0104c8c:	83 ea 0c             	sub    $0xc,%edx
f0104c8f:	39 f1                	cmp    %esi,%ecx
f0104c91:	75 ef                	jne    f0104c82 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104c93:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c96:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c99:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104c9d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104ca0:	73 3a                	jae    f0104cdc <stab_binsearch+0x7f>
			*region_left = m;
f0104ca2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104ca5:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104ca7:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0104caa:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104cb1:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104cb4:	7f 53                	jg     f0104d09 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0104cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104cb9:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0104cbc:	89 d0                	mov    %edx,%eax
f0104cbe:	c1 e8 1f             	shr    $0x1f,%eax
f0104cc1:	01 d0                	add    %edx,%eax
f0104cc3:	89 c7                	mov    %eax,%edi
f0104cc5:	d1 ff                	sar    %edi
f0104cc7:	83 e0 fe             	and    $0xfffffffe,%eax
f0104cca:	01 f8                	add    %edi,%eax
f0104ccc:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104ccf:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104cd3:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104cd5:	eb ae                	jmp    f0104c85 <stab_binsearch+0x28>
			l = true_m + 1;
f0104cd7:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104cda:	eb d5                	jmp    f0104cb1 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104cdc:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104cdf:	76 14                	jbe    f0104cf5 <stab_binsearch+0x98>
			*region_right = m - 1;
f0104ce1:	83 e8 01             	sub    $0x1,%eax
f0104ce4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ce7:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104cea:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104cec:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104cf3:	eb bc                	jmp    f0104cb1 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104cf5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cf8:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104cfa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104cfe:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104d00:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d07:	eb a8                	jmp    f0104cb1 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104d09:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104d0d:	75 15                	jne    f0104d24 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0104d0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d12:	8b 00                	mov    (%eax),%eax
f0104d14:	83 e8 01             	sub    $0x1,%eax
f0104d17:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104d1a:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104d1c:	83 c4 14             	add    $0x14,%esp
f0104d1f:	5b                   	pop    %ebx
f0104d20:	5e                   	pop    %esi
f0104d21:	5f                   	pop    %edi
f0104d22:	5d                   	pop    %ebp
f0104d23:	c3                   	ret    
		for (l = *region_right;
f0104d24:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d27:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104d29:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d2c:	8b 0f                	mov    (%edi),%ecx
f0104d2e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d31:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104d34:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104d38:	39 c1                	cmp    %eax,%ecx
f0104d3a:	7d 0f                	jge    f0104d4b <stab_binsearch+0xee>
f0104d3c:	0f b6 1a             	movzbl (%edx),%ebx
f0104d3f:	83 ea 0c             	sub    $0xc,%edx
f0104d42:	39 f3                	cmp    %esi,%ebx
f0104d44:	74 05                	je     f0104d4b <stab_binsearch+0xee>
		     l--)
f0104d46:	83 e8 01             	sub    $0x1,%eax
f0104d49:	eb ed                	jmp    f0104d38 <stab_binsearch+0xdb>
		*region_left = l;
f0104d4b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d4e:	89 07                	mov    %eax,(%edi)
}
f0104d50:	eb ca                	jmp    f0104d1c <stab_binsearch+0xbf>

f0104d52 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d52:	55                   	push   %ebp
f0104d53:	89 e5                	mov    %esp,%ebp
f0104d55:	57                   	push   %edi
f0104d56:	56                   	push   %esi
f0104d57:	53                   	push   %ebx
f0104d58:	83 ec 4c             	sub    $0x4c,%esp
f0104d5b:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104d5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104d61:	c7 03 74 7c 10 f0    	movl   $0xf0107c74,(%ebx)
	info->eip_line = 0;
f0104d67:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104d6e:	c7 43 08 74 7c 10 f0 	movl   $0xf0107c74,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104d75:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104d7c:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104d7f:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d86:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104d8c:	0f 86 29 01 00 00    	jbe    f0104ebb <debuginfo_eip+0x169>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104d92:	c7 45 c0 ff a6 11 f0 	movl   $0xf011a6ff,-0x40(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104d99:	c7 45 bc c1 38 11 f0 	movl   $0xf01138c1,-0x44(%ebp)
		stab_end = __STAB_END__;
f0104da0:	be c0 38 11 f0       	mov    $0xf01138c0,%esi
		stabs = __STAB_BEGIN__;
f0104da5:	c7 45 c4 54 81 10 f0 	movl   $0xf0108154,-0x3c(%ebp)
		if( user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ) return -1;
		if( user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) ) return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104dac:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104daf:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f0104db2:	0f 83 3e 02 00 00    	jae    f0104ff6 <debuginfo_eip+0x2a4>
f0104db8:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104dbc:	0f 85 3b 02 00 00    	jne    f0104ffd <debuginfo_eip+0x2ab>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104dc2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104dc9:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0104dcc:	c1 fe 02             	sar    $0x2,%esi
f0104dcf:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104dd5:	83 e8 01             	sub    $0x1,%eax
f0104dd8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104ddb:	83 ec 08             	sub    $0x8,%esp
f0104dde:	57                   	push   %edi
f0104ddf:	6a 64                	push   $0x64
f0104de1:	8d 75 e0             	lea    -0x20(%ebp),%esi
f0104de4:	89 f1                	mov    %esi,%ecx
f0104de6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104de9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104dec:	e8 6c fe ff ff       	call   f0104c5d <stab_binsearch>
	if (lfile == 0)
f0104df1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104df4:	83 c4 10             	add    $0x10,%esp
f0104df7:	85 f6                	test   %esi,%esi
f0104df9:	0f 84 05 02 00 00    	je     f0105004 <debuginfo_eip+0x2b2>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104dff:	89 75 dc             	mov    %esi,-0x24(%ebp)
	rfun = rfile;
f0104e02:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104e05:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0104e08:	89 55 d8             	mov    %edx,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e0b:	83 ec 08             	sub    $0x8,%esp
f0104e0e:	57                   	push   %edi
f0104e0f:	6a 24                	push   $0x24
f0104e11:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104e14:	89 d1                	mov    %edx,%ecx
f0104e16:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e19:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104e1c:	e8 3c fe ff ff       	call   f0104c5d <stab_binsearch>

	if (lfun <= rfun) {
f0104e21:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104e24:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0104e27:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104e2a:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0104e2d:	83 c4 10             	add    $0x10,%esp
f0104e30:	39 c2                	cmp    %eax,%edx
f0104e32:	0f 8f 32 01 00 00    	jg     f0104f6a <debuginfo_eip+0x218>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e38:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104e3b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104e3e:	8d 14 82             	lea    (%edx,%eax,4),%edx
f0104e41:	8b 02                	mov    (%edx),%eax
f0104e43:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104e46:	2b 4d bc             	sub    -0x44(%ebp),%ecx
f0104e49:	39 c8                	cmp    %ecx,%eax
f0104e4b:	73 06                	jae    f0104e53 <debuginfo_eip+0x101>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e4d:	03 45 bc             	add    -0x44(%ebp),%eax
f0104e50:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e53:	8b 42 08             	mov    0x8(%edx),%eax
		addr -= info->eip_fn_addr;
f0104e56:	29 c7                	sub    %eax,%edi
f0104e58:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0104e5b:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0104e5e:	89 4d b8             	mov    %ecx,-0x48(%ebp)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e61:	89 43 10             	mov    %eax,0x10(%ebx)
		// Search within the function definition for the line number.
		lline = lfun;
f0104e64:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0104e67:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104e6a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e6d:	83 ec 08             	sub    $0x8,%esp
f0104e70:	6a 3a                	push   $0x3a
f0104e72:	ff 73 08             	push   0x8(%ebx)
f0104e75:	e8 81 09 00 00       	call   f01057fb <strfind>
f0104e7a:	2b 43 08             	sub    0x8(%ebx),%eax
f0104e7d:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104e80:	83 c4 08             	add    $0x8,%esp
f0104e83:	57                   	push   %edi
f0104e84:	6a 44                	push   $0x44
f0104e86:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104e89:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104e8c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104e8f:	89 f8                	mov    %edi,%eax
f0104e91:	e8 c7 fd ff ff       	call   f0104c5d <stab_binsearch>
	if (lline <= rline) {
f0104e96:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104e99:	83 c4 10             	add    $0x10,%esp
f0104e9c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104e9f:	0f 8f 66 01 00 00    	jg     f010500b <debuginfo_eip+0x2b9>
    		info->eip_line = stabs[lline].n_desc;
f0104ea5:	89 c2                	mov    %eax,%edx
f0104ea7:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104eaa:	0f b7 4c 87 06       	movzwl 0x6(%edi,%eax,4),%ecx
f0104eaf:	89 4b 04             	mov    %ecx,0x4(%ebx)
f0104eb2:	8d 44 87 04          	lea    0x4(%edi,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104eb6:	e9 be 00 00 00       	jmp    f0104f79 <debuginfo_eip+0x227>
		if( user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) ) return -1;
f0104ebb:	e8 4c 0f 00 00       	call   f0105e0c <cpunum>
f0104ec0:	6a 04                	push   $0x4
f0104ec2:	6a 10                	push   $0x10
f0104ec4:	68 00 00 20 00       	push   $0x200000
f0104ec9:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ecc:	ff b0 28 90 25 f0    	push   -0xfda6fd8(%eax)
f0104ed2:	e8 25 e0 ff ff       	call   f0102efc <user_mem_check>
f0104ed7:	83 c4 10             	add    $0x10,%esp
f0104eda:	85 c0                	test   %eax,%eax
f0104edc:	0f 85 06 01 00 00    	jne    f0104fe8 <debuginfo_eip+0x296>
		stabs = usd->stabs;
f0104ee2:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f0104ee8:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104eeb:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104ef1:	a1 08 00 20 00       	mov    0x200008,%eax
f0104ef6:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0104ef9:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104eff:	89 55 c0             	mov    %edx,-0x40(%ebp)
		if( user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ) return -1;
f0104f02:	e8 05 0f 00 00       	call   f0105e0c <cpunum>
f0104f07:	89 c2                	mov    %eax,%edx
f0104f09:	6a 04                	push   $0x4
f0104f0b:	89 f0                	mov    %esi,%eax
f0104f0d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104f10:	29 c8                	sub    %ecx,%eax
f0104f12:	c1 f8 02             	sar    $0x2,%eax
f0104f15:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104f1b:	50                   	push   %eax
f0104f1c:	51                   	push   %ecx
f0104f1d:	6b d2 74             	imul   $0x74,%edx,%edx
f0104f20:	ff b2 28 90 25 f0    	push   -0xfda6fd8(%edx)
f0104f26:	e8 d1 df ff ff       	call   f0102efc <user_mem_check>
f0104f2b:	83 c4 10             	add    $0x10,%esp
f0104f2e:	85 c0                	test   %eax,%eax
f0104f30:	0f 85 b9 00 00 00    	jne    f0104fef <debuginfo_eip+0x29d>
		if( user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) ) return -1;
f0104f36:	e8 d1 0e 00 00       	call   f0105e0c <cpunum>
f0104f3b:	6a 04                	push   $0x4
f0104f3d:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0104f40:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104f43:	29 ca                	sub    %ecx,%edx
f0104f45:	52                   	push   %edx
f0104f46:	51                   	push   %ecx
f0104f47:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f4a:	ff b0 28 90 25 f0    	push   -0xfda6fd8(%eax)
f0104f50:	e8 a7 df ff ff       	call   f0102efc <user_mem_check>
f0104f55:	83 c4 10             	add    $0x10,%esp
f0104f58:	85 c0                	test   %eax,%eax
f0104f5a:	0f 84 4c fe ff ff    	je     f0104dac <debuginfo_eip+0x5a>
f0104f60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f65:	e9 ad 00 00 00       	jmp    f0105017 <debuginfo_eip+0x2c5>
f0104f6a:	89 f8                	mov    %edi,%eax
f0104f6c:	89 f2                	mov    %esi,%edx
f0104f6e:	e9 ee fe ff ff       	jmp    f0104e61 <debuginfo_eip+0x10f>
f0104f73:	83 ea 01             	sub    $0x1,%edx
f0104f76:	83 e8 0c             	sub    $0xc,%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104f79:	39 d6                	cmp    %edx,%esi
f0104f7b:	7f 2e                	jg     f0104fab <debuginfo_eip+0x259>
	       && stabs[lline].n_type != N_SOL
f0104f7d:	0f b6 08             	movzbl (%eax),%ecx
f0104f80:	80 f9 84             	cmp    $0x84,%cl
f0104f83:	74 0b                	je     f0104f90 <debuginfo_eip+0x23e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104f85:	80 f9 64             	cmp    $0x64,%cl
f0104f88:	75 e9                	jne    f0104f73 <debuginfo_eip+0x221>
f0104f8a:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0104f8e:	74 e3                	je     f0104f73 <debuginfo_eip+0x221>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104f90:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104f93:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104f96:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0104f99:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104f9c:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104f9f:	29 f0                	sub    %esi,%eax
f0104fa1:	39 c2                	cmp    %eax,%edx
f0104fa3:	73 06                	jae    f0104fab <debuginfo_eip+0x259>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104fa5:	89 f0                	mov    %esi,%eax
f0104fa7:	01 d0                	add    %edx,%eax
f0104fa9:	89 03                	mov    %eax,(%ebx)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104fab:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104fb0:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104fb3:	8b 75 b0             	mov    -0x50(%ebp),%esi
f0104fb6:	39 f7                	cmp    %esi,%edi
f0104fb8:	7d 5d                	jge    f0105017 <debuginfo_eip+0x2c5>
		for (lline = lfun + 1;
f0104fba:	83 c7 01             	add    $0x1,%edi
f0104fbd:	89 f8                	mov    %edi,%eax
f0104fbf:	8d 14 7f             	lea    (%edi,%edi,2),%edx
f0104fc2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104fc5:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104fc9:	eb 04                	jmp    f0104fcf <debuginfo_eip+0x27d>
			info->eip_fn_narg++;
f0104fcb:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104fcf:	39 c6                	cmp    %eax,%esi
f0104fd1:	7e 3f                	jle    f0105012 <debuginfo_eip+0x2c0>
f0104fd3:	0f b6 0a             	movzbl (%edx),%ecx
f0104fd6:	83 c0 01             	add    $0x1,%eax
f0104fd9:	83 c2 0c             	add    $0xc,%edx
f0104fdc:	80 f9 a0             	cmp    $0xa0,%cl
f0104fdf:	74 ea                	je     f0104fcb <debuginfo_eip+0x279>
	return 0;
f0104fe1:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fe6:	eb 2f                	jmp    f0105017 <debuginfo_eip+0x2c5>
		if( user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) ) return -1;
f0104fe8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fed:	eb 28                	jmp    f0105017 <debuginfo_eip+0x2c5>
		if( user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ) return -1;
f0104fef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ff4:	eb 21                	jmp    f0105017 <debuginfo_eip+0x2c5>
		return -1;
f0104ff6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ffb:	eb 1a                	jmp    f0105017 <debuginfo_eip+0x2c5>
f0104ffd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105002:	eb 13                	jmp    f0105017 <debuginfo_eip+0x2c5>
		return -1;
f0105004:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105009:	eb 0c                	jmp    f0105017 <debuginfo_eip+0x2c5>
    		return -1;
f010500b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105010:	eb 05                	jmp    f0105017 <debuginfo_eip+0x2c5>
	return 0;
f0105012:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105017:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010501a:	5b                   	pop    %ebx
f010501b:	5e                   	pop    %esi
f010501c:	5f                   	pop    %edi
f010501d:	5d                   	pop    %ebp
f010501e:	c3                   	ret    

f010501f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010501f:	55                   	push   %ebp
f0105020:	89 e5                	mov    %esp,%ebp
f0105022:	57                   	push   %edi
f0105023:	56                   	push   %esi
f0105024:	53                   	push   %ebx
f0105025:	83 ec 1c             	sub    $0x1c,%esp
f0105028:	89 c7                	mov    %eax,%edi
f010502a:	89 d6                	mov    %edx,%esi
f010502c:	8b 45 08             	mov    0x8(%ebp),%eax
f010502f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105032:	89 d1                	mov    %edx,%ecx
f0105034:	89 c2                	mov    %eax,%edx
f0105036:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105039:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010503c:	8b 45 10             	mov    0x10(%ebp),%eax
f010503f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105042:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105045:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010504c:	39 c2                	cmp    %eax,%edx
f010504e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0105051:	72 3e                	jb     f0105091 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105053:	83 ec 0c             	sub    $0xc,%esp
f0105056:	ff 75 18             	push   0x18(%ebp)
f0105059:	83 eb 01             	sub    $0x1,%ebx
f010505c:	53                   	push   %ebx
f010505d:	50                   	push   %eax
f010505e:	83 ec 08             	sub    $0x8,%esp
f0105061:	ff 75 e4             	push   -0x1c(%ebp)
f0105064:	ff 75 e0             	push   -0x20(%ebp)
f0105067:	ff 75 dc             	push   -0x24(%ebp)
f010506a:	ff 75 d8             	push   -0x28(%ebp)
f010506d:	e8 8e 11 00 00       	call   f0106200 <__udivdi3>
f0105072:	83 c4 18             	add    $0x18,%esp
f0105075:	52                   	push   %edx
f0105076:	50                   	push   %eax
f0105077:	89 f2                	mov    %esi,%edx
f0105079:	89 f8                	mov    %edi,%eax
f010507b:	e8 9f ff ff ff       	call   f010501f <printnum>
f0105080:	83 c4 20             	add    $0x20,%esp
f0105083:	eb 13                	jmp    f0105098 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105085:	83 ec 08             	sub    $0x8,%esp
f0105088:	56                   	push   %esi
f0105089:	ff 75 18             	push   0x18(%ebp)
f010508c:	ff d7                	call   *%edi
f010508e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0105091:	83 eb 01             	sub    $0x1,%ebx
f0105094:	85 db                	test   %ebx,%ebx
f0105096:	7f ed                	jg     f0105085 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105098:	83 ec 08             	sub    $0x8,%esp
f010509b:	56                   	push   %esi
f010509c:	83 ec 04             	sub    $0x4,%esp
f010509f:	ff 75 e4             	push   -0x1c(%ebp)
f01050a2:	ff 75 e0             	push   -0x20(%ebp)
f01050a5:	ff 75 dc             	push   -0x24(%ebp)
f01050a8:	ff 75 d8             	push   -0x28(%ebp)
f01050ab:	e8 70 12 00 00       	call   f0106320 <__umoddi3>
f01050b0:	83 c4 14             	add    $0x14,%esp
f01050b3:	0f be 80 7e 7c 10 f0 	movsbl -0xfef8382(%eax),%eax
f01050ba:	50                   	push   %eax
f01050bb:	ff d7                	call   *%edi
}
f01050bd:	83 c4 10             	add    $0x10,%esp
f01050c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050c3:	5b                   	pop    %ebx
f01050c4:	5e                   	pop    %esi
f01050c5:	5f                   	pop    %edi
f01050c6:	5d                   	pop    %ebp
f01050c7:	c3                   	ret    

f01050c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01050c8:	55                   	push   %ebp
f01050c9:	89 e5                	mov    %esp,%ebp
f01050cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01050ce:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01050d2:	8b 10                	mov    (%eax),%edx
f01050d4:	3b 50 04             	cmp    0x4(%eax),%edx
f01050d7:	73 0a                	jae    f01050e3 <sprintputch+0x1b>
		*b->buf++ = ch;
f01050d9:	8d 4a 01             	lea    0x1(%edx),%ecx
f01050dc:	89 08                	mov    %ecx,(%eax)
f01050de:	8b 45 08             	mov    0x8(%ebp),%eax
f01050e1:	88 02                	mov    %al,(%edx)
}
f01050e3:	5d                   	pop    %ebp
f01050e4:	c3                   	ret    

f01050e5 <printfmt>:
{
f01050e5:	55                   	push   %ebp
f01050e6:	89 e5                	mov    %esp,%ebp
f01050e8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01050eb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01050ee:	50                   	push   %eax
f01050ef:	ff 75 10             	push   0x10(%ebp)
f01050f2:	ff 75 0c             	push   0xc(%ebp)
f01050f5:	ff 75 08             	push   0x8(%ebp)
f01050f8:	e8 05 00 00 00       	call   f0105102 <vprintfmt>
}
f01050fd:	83 c4 10             	add    $0x10,%esp
f0105100:	c9                   	leave  
f0105101:	c3                   	ret    

f0105102 <vprintfmt>:
{
f0105102:	55                   	push   %ebp
f0105103:	89 e5                	mov    %esp,%ebp
f0105105:	57                   	push   %edi
f0105106:	56                   	push   %esi
f0105107:	53                   	push   %ebx
f0105108:	83 ec 3c             	sub    $0x3c,%esp
f010510b:	8b 75 08             	mov    0x8(%ebp),%esi
f010510e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105111:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105114:	eb 0a                	jmp    f0105120 <vprintfmt+0x1e>
			putch(ch, putdat);
f0105116:	83 ec 08             	sub    $0x8,%esp
f0105119:	53                   	push   %ebx
f010511a:	50                   	push   %eax
f010511b:	ff d6                	call   *%esi
f010511d:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105120:	83 c7 01             	add    $0x1,%edi
f0105123:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105127:	83 f8 25             	cmp    $0x25,%eax
f010512a:	74 0c                	je     f0105138 <vprintfmt+0x36>
			if (ch == '\0')
f010512c:	85 c0                	test   %eax,%eax
f010512e:	75 e6                	jne    f0105116 <vprintfmt+0x14>
}
f0105130:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105133:	5b                   	pop    %ebx
f0105134:	5e                   	pop    %esi
f0105135:	5f                   	pop    %edi
f0105136:	5d                   	pop    %ebp
f0105137:	c3                   	ret    
		padc = ' ';
f0105138:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f010513c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0105143:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010514a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0105151:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105156:	8d 47 01             	lea    0x1(%edi),%eax
f0105159:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010515c:	0f b6 17             	movzbl (%edi),%edx
f010515f:	8d 42 dd             	lea    -0x23(%edx),%eax
f0105162:	3c 55                	cmp    $0x55,%al
f0105164:	0f 87 bb 03 00 00    	ja     f0105525 <vprintfmt+0x423>
f010516a:	0f b6 c0             	movzbl %al,%eax
f010516d:	ff 24 85 40 7d 10 f0 	jmp    *-0xfef82c0(,%eax,4)
f0105174:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105177:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f010517b:	eb d9                	jmp    f0105156 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f010517d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105180:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0105184:	eb d0                	jmp    f0105156 <vprintfmt+0x54>
f0105186:	0f b6 d2             	movzbl %dl,%edx
f0105189:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010518c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105191:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105194:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105197:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010519b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010519e:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01051a1:	83 f9 09             	cmp    $0x9,%ecx
f01051a4:	77 55                	ja     f01051fb <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
f01051a6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f01051a9:	eb e9                	jmp    f0105194 <vprintfmt+0x92>
			precision = va_arg(ap, int);
f01051ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01051ae:	8b 00                	mov    (%eax),%eax
f01051b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01051b6:	8d 40 04             	lea    0x4(%eax),%eax
f01051b9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01051bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f01051bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01051c3:	79 91                	jns    f0105156 <vprintfmt+0x54>
				width = precision, precision = -1;
f01051c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01051c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01051cb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01051d2:	eb 82                	jmp    f0105156 <vprintfmt+0x54>
f01051d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01051d7:	85 d2                	test   %edx,%edx
f01051d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01051de:	0f 49 c2             	cmovns %edx,%eax
f01051e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01051e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01051e7:	e9 6a ff ff ff       	jmp    f0105156 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f01051ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01051ef:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01051f6:	e9 5b ff ff ff       	jmp    f0105156 <vprintfmt+0x54>
f01051fb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01051fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105201:	eb bc                	jmp    f01051bf <vprintfmt+0xbd>
			lflag++;
f0105203:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105206:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0105209:	e9 48 ff ff ff       	jmp    f0105156 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f010520e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105211:	8d 78 04             	lea    0x4(%eax),%edi
f0105214:	83 ec 08             	sub    $0x8,%esp
f0105217:	53                   	push   %ebx
f0105218:	ff 30                	push   (%eax)
f010521a:	ff d6                	call   *%esi
			break;
f010521c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010521f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0105222:	e9 9d 02 00 00       	jmp    f01054c4 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
f0105227:	8b 45 14             	mov    0x14(%ebp),%eax
f010522a:	8d 78 04             	lea    0x4(%eax),%edi
f010522d:	8b 10                	mov    (%eax),%edx
f010522f:	89 d0                	mov    %edx,%eax
f0105231:	f7 d8                	neg    %eax
f0105233:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105236:	83 f8 08             	cmp    $0x8,%eax
f0105239:	7f 23                	jg     f010525e <vprintfmt+0x15c>
f010523b:	8b 14 85 a0 7e 10 f0 	mov    -0xfef8160(,%eax,4),%edx
f0105242:	85 d2                	test   %edx,%edx
f0105244:	74 18                	je     f010525e <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
f0105246:	52                   	push   %edx
f0105247:	68 e7 69 10 f0       	push   $0xf01069e7
f010524c:	53                   	push   %ebx
f010524d:	56                   	push   %esi
f010524e:	e8 92 fe ff ff       	call   f01050e5 <printfmt>
f0105253:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105256:	89 7d 14             	mov    %edi,0x14(%ebp)
f0105259:	e9 66 02 00 00       	jmp    f01054c4 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
f010525e:	50                   	push   %eax
f010525f:	68 96 7c 10 f0       	push   $0xf0107c96
f0105264:	53                   	push   %ebx
f0105265:	56                   	push   %esi
f0105266:	e8 7a fe ff ff       	call   f01050e5 <printfmt>
f010526b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010526e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0105271:	e9 4e 02 00 00       	jmp    f01054c4 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
f0105276:	8b 45 14             	mov    0x14(%ebp),%eax
f0105279:	83 c0 04             	add    $0x4,%eax
f010527c:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010527f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105282:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0105284:	85 d2                	test   %edx,%edx
f0105286:	b8 8f 7c 10 f0       	mov    $0xf0107c8f,%eax
f010528b:	0f 45 c2             	cmovne %edx,%eax
f010528e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0105291:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105295:	7e 06                	jle    f010529d <vprintfmt+0x19b>
f0105297:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f010529b:	75 0d                	jne    f01052aa <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
f010529d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01052a0:	89 c7                	mov    %eax,%edi
f01052a2:	03 45 e0             	add    -0x20(%ebp),%eax
f01052a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01052a8:	eb 55                	jmp    f01052ff <vprintfmt+0x1fd>
f01052aa:	83 ec 08             	sub    $0x8,%esp
f01052ad:	ff 75 d8             	push   -0x28(%ebp)
f01052b0:	ff 75 cc             	push   -0x34(%ebp)
f01052b3:	e8 ec 03 00 00       	call   f01056a4 <strnlen>
f01052b8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01052bb:	29 c1                	sub    %eax,%ecx
f01052bd:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01052c0:	83 c4 10             	add    $0x10,%esp
f01052c3:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
f01052c5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f01052c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01052cc:	eb 0f                	jmp    f01052dd <vprintfmt+0x1db>
					putch(padc, putdat);
f01052ce:	83 ec 08             	sub    $0x8,%esp
f01052d1:	53                   	push   %ebx
f01052d2:	ff 75 e0             	push   -0x20(%ebp)
f01052d5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01052d7:	83 ef 01             	sub    $0x1,%edi
f01052da:	83 c4 10             	add    $0x10,%esp
f01052dd:	85 ff                	test   %edi,%edi
f01052df:	7f ed                	jg     f01052ce <vprintfmt+0x1cc>
f01052e1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01052e4:	85 d2                	test   %edx,%edx
f01052e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01052eb:	0f 49 c2             	cmovns %edx,%eax
f01052ee:	29 c2                	sub    %eax,%edx
f01052f0:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01052f3:	eb a8                	jmp    f010529d <vprintfmt+0x19b>
					putch(ch, putdat);
f01052f5:	83 ec 08             	sub    $0x8,%esp
f01052f8:	53                   	push   %ebx
f01052f9:	52                   	push   %edx
f01052fa:	ff d6                	call   *%esi
f01052fc:	83 c4 10             	add    $0x10,%esp
f01052ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105302:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105304:	83 c7 01             	add    $0x1,%edi
f0105307:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010530b:	0f be d0             	movsbl %al,%edx
f010530e:	85 d2                	test   %edx,%edx
f0105310:	74 4b                	je     f010535d <vprintfmt+0x25b>
f0105312:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105316:	78 06                	js     f010531e <vprintfmt+0x21c>
f0105318:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f010531c:	78 1e                	js     f010533c <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
f010531e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105322:	74 d1                	je     f01052f5 <vprintfmt+0x1f3>
f0105324:	0f be c0             	movsbl %al,%eax
f0105327:	83 e8 20             	sub    $0x20,%eax
f010532a:	83 f8 5e             	cmp    $0x5e,%eax
f010532d:	76 c6                	jbe    f01052f5 <vprintfmt+0x1f3>
					putch('?', putdat);
f010532f:	83 ec 08             	sub    $0x8,%esp
f0105332:	53                   	push   %ebx
f0105333:	6a 3f                	push   $0x3f
f0105335:	ff d6                	call   *%esi
f0105337:	83 c4 10             	add    $0x10,%esp
f010533a:	eb c3                	jmp    f01052ff <vprintfmt+0x1fd>
f010533c:	89 cf                	mov    %ecx,%edi
f010533e:	eb 0e                	jmp    f010534e <vprintfmt+0x24c>
				putch(' ', putdat);
f0105340:	83 ec 08             	sub    $0x8,%esp
f0105343:	53                   	push   %ebx
f0105344:	6a 20                	push   $0x20
f0105346:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105348:	83 ef 01             	sub    $0x1,%edi
f010534b:	83 c4 10             	add    $0x10,%esp
f010534e:	85 ff                	test   %edi,%edi
f0105350:	7f ee                	jg     f0105340 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
f0105352:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105355:	89 45 14             	mov    %eax,0x14(%ebp)
f0105358:	e9 67 01 00 00       	jmp    f01054c4 <vprintfmt+0x3c2>
f010535d:	89 cf                	mov    %ecx,%edi
f010535f:	eb ed                	jmp    f010534e <vprintfmt+0x24c>
	if (lflag >= 2)
f0105361:	83 f9 01             	cmp    $0x1,%ecx
f0105364:	7f 1b                	jg     f0105381 <vprintfmt+0x27f>
	else if (lflag)
f0105366:	85 c9                	test   %ecx,%ecx
f0105368:	74 63                	je     f01053cd <vprintfmt+0x2cb>
		return va_arg(*ap, long);
f010536a:	8b 45 14             	mov    0x14(%ebp),%eax
f010536d:	8b 00                	mov    (%eax),%eax
f010536f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105372:	99                   	cltd   
f0105373:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105376:	8b 45 14             	mov    0x14(%ebp),%eax
f0105379:	8d 40 04             	lea    0x4(%eax),%eax
f010537c:	89 45 14             	mov    %eax,0x14(%ebp)
f010537f:	eb 17                	jmp    f0105398 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0105381:	8b 45 14             	mov    0x14(%ebp),%eax
f0105384:	8b 50 04             	mov    0x4(%eax),%edx
f0105387:	8b 00                	mov    (%eax),%eax
f0105389:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010538c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010538f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105392:	8d 40 08             	lea    0x8(%eax),%eax
f0105395:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105398:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010539b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010539e:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
f01053a3:	85 c9                	test   %ecx,%ecx
f01053a5:	0f 89 ff 00 00 00    	jns    f01054aa <vprintfmt+0x3a8>
				putch('-', putdat);
f01053ab:	83 ec 08             	sub    $0x8,%esp
f01053ae:	53                   	push   %ebx
f01053af:	6a 2d                	push   $0x2d
f01053b1:	ff d6                	call   *%esi
				num = -(long long) num;
f01053b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01053b6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01053b9:	f7 da                	neg    %edx
f01053bb:	83 d1 00             	adc    $0x0,%ecx
f01053be:	f7 d9                	neg    %ecx
f01053c0:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01053c3:	bf 0a 00 00 00       	mov    $0xa,%edi
f01053c8:	e9 dd 00 00 00       	jmp    f01054aa <vprintfmt+0x3a8>
		return va_arg(*ap, int);
f01053cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01053d0:	8b 00                	mov    (%eax),%eax
f01053d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053d5:	99                   	cltd   
f01053d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01053d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01053dc:	8d 40 04             	lea    0x4(%eax),%eax
f01053df:	89 45 14             	mov    %eax,0x14(%ebp)
f01053e2:	eb b4                	jmp    f0105398 <vprintfmt+0x296>
	if (lflag >= 2)
f01053e4:	83 f9 01             	cmp    $0x1,%ecx
f01053e7:	7f 1e                	jg     f0105407 <vprintfmt+0x305>
	else if (lflag)
f01053e9:	85 c9                	test   %ecx,%ecx
f01053eb:	74 32                	je     f010541f <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
f01053ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01053f0:	8b 10                	mov    (%eax),%edx
f01053f2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01053f7:	8d 40 04             	lea    0x4(%eax),%eax
f01053fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01053fd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
f0105402:	e9 a3 00 00 00       	jmp    f01054aa <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f0105407:	8b 45 14             	mov    0x14(%ebp),%eax
f010540a:	8b 10                	mov    (%eax),%edx
f010540c:	8b 48 04             	mov    0x4(%eax),%ecx
f010540f:	8d 40 08             	lea    0x8(%eax),%eax
f0105412:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105415:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
f010541a:	e9 8b 00 00 00       	jmp    f01054aa <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f010541f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105422:	8b 10                	mov    (%eax),%edx
f0105424:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105429:	8d 40 04             	lea    0x4(%eax),%eax
f010542c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010542f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
f0105434:	eb 74                	jmp    f01054aa <vprintfmt+0x3a8>
	if (lflag >= 2)
f0105436:	83 f9 01             	cmp    $0x1,%ecx
f0105439:	7f 1b                	jg     f0105456 <vprintfmt+0x354>
	else if (lflag)
f010543b:	85 c9                	test   %ecx,%ecx
f010543d:	74 2c                	je     f010546b <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
f010543f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105442:	8b 10                	mov    (%eax),%edx
f0105444:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105449:	8d 40 04             	lea    0x4(%eax),%eax
f010544c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f010544f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
f0105454:	eb 54                	jmp    f01054aa <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f0105456:	8b 45 14             	mov    0x14(%ebp),%eax
f0105459:	8b 10                	mov    (%eax),%edx
f010545b:	8b 48 04             	mov    0x4(%eax),%ecx
f010545e:	8d 40 08             	lea    0x8(%eax),%eax
f0105461:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0105464:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
f0105469:	eb 3f                	jmp    f01054aa <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f010546b:	8b 45 14             	mov    0x14(%ebp),%eax
f010546e:	8b 10                	mov    (%eax),%edx
f0105470:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105475:	8d 40 04             	lea    0x4(%eax),%eax
f0105478:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f010547b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
f0105480:	eb 28                	jmp    f01054aa <vprintfmt+0x3a8>
			putch('0', putdat);
f0105482:	83 ec 08             	sub    $0x8,%esp
f0105485:	53                   	push   %ebx
f0105486:	6a 30                	push   $0x30
f0105488:	ff d6                	call   *%esi
			putch('x', putdat);
f010548a:	83 c4 08             	add    $0x8,%esp
f010548d:	53                   	push   %ebx
f010548e:	6a 78                	push   $0x78
f0105490:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105492:	8b 45 14             	mov    0x14(%ebp),%eax
f0105495:	8b 10                	mov    (%eax),%edx
f0105497:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010549c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010549f:	8d 40 04             	lea    0x4(%eax),%eax
f01054a2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01054a5:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
f01054aa:	83 ec 0c             	sub    $0xc,%esp
f01054ad:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f01054b1:	50                   	push   %eax
f01054b2:	ff 75 e0             	push   -0x20(%ebp)
f01054b5:	57                   	push   %edi
f01054b6:	51                   	push   %ecx
f01054b7:	52                   	push   %edx
f01054b8:	89 da                	mov    %ebx,%edx
f01054ba:	89 f0                	mov    %esi,%eax
f01054bc:	e8 5e fb ff ff       	call   f010501f <printnum>
			break;
f01054c1:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01054c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01054c7:	e9 54 fc ff ff       	jmp    f0105120 <vprintfmt+0x1e>
	if (lflag >= 2)
f01054cc:	83 f9 01             	cmp    $0x1,%ecx
f01054cf:	7f 1b                	jg     f01054ec <vprintfmt+0x3ea>
	else if (lflag)
f01054d1:	85 c9                	test   %ecx,%ecx
f01054d3:	74 2c                	je     f0105501 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
f01054d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01054d8:	8b 10                	mov    (%eax),%edx
f01054da:	b9 00 00 00 00       	mov    $0x0,%ecx
f01054df:	8d 40 04             	lea    0x4(%eax),%eax
f01054e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01054e5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
f01054ea:	eb be                	jmp    f01054aa <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f01054ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01054ef:	8b 10                	mov    (%eax),%edx
f01054f1:	8b 48 04             	mov    0x4(%eax),%ecx
f01054f4:	8d 40 08             	lea    0x8(%eax),%eax
f01054f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01054fa:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
f01054ff:	eb a9                	jmp    f01054aa <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f0105501:	8b 45 14             	mov    0x14(%ebp),%eax
f0105504:	8b 10                	mov    (%eax),%edx
f0105506:	b9 00 00 00 00       	mov    $0x0,%ecx
f010550b:	8d 40 04             	lea    0x4(%eax),%eax
f010550e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105511:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
f0105516:	eb 92                	jmp    f01054aa <vprintfmt+0x3a8>
			putch(ch, putdat);
f0105518:	83 ec 08             	sub    $0x8,%esp
f010551b:	53                   	push   %ebx
f010551c:	6a 25                	push   $0x25
f010551e:	ff d6                	call   *%esi
			break;
f0105520:	83 c4 10             	add    $0x10,%esp
f0105523:	eb 9f                	jmp    f01054c4 <vprintfmt+0x3c2>
			putch('%', putdat);
f0105525:	83 ec 08             	sub    $0x8,%esp
f0105528:	53                   	push   %ebx
f0105529:	6a 25                	push   $0x25
f010552b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010552d:	83 c4 10             	add    $0x10,%esp
f0105530:	89 f8                	mov    %edi,%eax
f0105532:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105536:	74 05                	je     f010553d <vprintfmt+0x43b>
f0105538:	83 e8 01             	sub    $0x1,%eax
f010553b:	eb f5                	jmp    f0105532 <vprintfmt+0x430>
f010553d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105540:	eb 82                	jmp    f01054c4 <vprintfmt+0x3c2>

f0105542 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105542:	55                   	push   %ebp
f0105543:	89 e5                	mov    %esp,%ebp
f0105545:	83 ec 18             	sub    $0x18,%esp
f0105548:	8b 45 08             	mov    0x8(%ebp),%eax
f010554b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010554e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105551:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105555:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105558:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010555f:	85 c0                	test   %eax,%eax
f0105561:	74 26                	je     f0105589 <vsnprintf+0x47>
f0105563:	85 d2                	test   %edx,%edx
f0105565:	7e 22                	jle    f0105589 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105567:	ff 75 14             	push   0x14(%ebp)
f010556a:	ff 75 10             	push   0x10(%ebp)
f010556d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105570:	50                   	push   %eax
f0105571:	68 c8 50 10 f0       	push   $0xf01050c8
f0105576:	e8 87 fb ff ff       	call   f0105102 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010557b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010557e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105581:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105584:	83 c4 10             	add    $0x10,%esp
}
f0105587:	c9                   	leave  
f0105588:	c3                   	ret    
		return -E_INVAL;
f0105589:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010558e:	eb f7                	jmp    f0105587 <vsnprintf+0x45>

f0105590 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105590:	55                   	push   %ebp
f0105591:	89 e5                	mov    %esp,%ebp
f0105593:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105596:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105599:	50                   	push   %eax
f010559a:	ff 75 10             	push   0x10(%ebp)
f010559d:	ff 75 0c             	push   0xc(%ebp)
f01055a0:	ff 75 08             	push   0x8(%ebp)
f01055a3:	e8 9a ff ff ff       	call   f0105542 <vsnprintf>
	va_end(ap);

	return rc;
}
f01055a8:	c9                   	leave  
f01055a9:	c3                   	ret    

f01055aa <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01055aa:	55                   	push   %ebp
f01055ab:	89 e5                	mov    %esp,%ebp
f01055ad:	57                   	push   %edi
f01055ae:	56                   	push   %esi
f01055af:	53                   	push   %ebx
f01055b0:	83 ec 0c             	sub    $0xc,%esp
f01055b3:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01055b6:	85 c0                	test   %eax,%eax
f01055b8:	74 11                	je     f01055cb <readline+0x21>
		cprintf("%s", prompt);
f01055ba:	83 ec 08             	sub    $0x8,%esp
f01055bd:	50                   	push   %eax
f01055be:	68 e7 69 10 f0       	push   $0xf01069e7
f01055c3:	e8 ea e3 ff ff       	call   f01039b2 <cprintf>
f01055c8:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01055cb:	83 ec 0c             	sub    $0xc,%esp
f01055ce:	6a 00                	push   $0x0
f01055d0:	e8 94 b1 ff ff       	call   f0100769 <iscons>
f01055d5:	89 c7                	mov    %eax,%edi
f01055d7:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01055da:	be 00 00 00 00       	mov    $0x0,%esi
f01055df:	eb 3f                	jmp    f0105620 <readline+0x76>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01055e1:	83 ec 08             	sub    $0x8,%esp
f01055e4:	50                   	push   %eax
f01055e5:	68 c4 7e 10 f0       	push   $0xf0107ec4
f01055ea:	e8 c3 e3 ff ff       	call   f01039b2 <cprintf>
			return NULL;
f01055ef:	83 c4 10             	add    $0x10,%esp
f01055f2:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01055f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055fa:	5b                   	pop    %ebx
f01055fb:	5e                   	pop    %esi
f01055fc:	5f                   	pop    %edi
f01055fd:	5d                   	pop    %ebp
f01055fe:	c3                   	ret    
			if (echoing)
f01055ff:	85 ff                	test   %edi,%edi
f0105601:	75 05                	jne    f0105608 <readline+0x5e>
			i--;
f0105603:	83 ee 01             	sub    $0x1,%esi
f0105606:	eb 18                	jmp    f0105620 <readline+0x76>
				cputchar('\b');
f0105608:	83 ec 0c             	sub    $0xc,%esp
f010560b:	6a 08                	push   $0x8
f010560d:	e8 36 b1 ff ff       	call   f0100748 <cputchar>
f0105612:	83 c4 10             	add    $0x10,%esp
f0105615:	eb ec                	jmp    f0105603 <readline+0x59>
			buf[i++] = c;
f0105617:	88 9e a0 8a 21 f0    	mov    %bl,-0xfde7560(%esi)
f010561d:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105620:	e8 33 b1 ff ff       	call   f0100758 <getchar>
f0105625:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105627:	85 c0                	test   %eax,%eax
f0105629:	78 b6                	js     f01055e1 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010562b:	83 f8 08             	cmp    $0x8,%eax
f010562e:	0f 94 c0             	sete   %al
f0105631:	83 fb 7f             	cmp    $0x7f,%ebx
f0105634:	0f 94 c2             	sete   %dl
f0105637:	08 d0                	or     %dl,%al
f0105639:	74 04                	je     f010563f <readline+0x95>
f010563b:	85 f6                	test   %esi,%esi
f010563d:	7f c0                	jg     f01055ff <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010563f:	83 fb 1f             	cmp    $0x1f,%ebx
f0105642:	7e 1a                	jle    f010565e <readline+0xb4>
f0105644:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010564a:	7f 12                	jg     f010565e <readline+0xb4>
			if (echoing)
f010564c:	85 ff                	test   %edi,%edi
f010564e:	74 c7                	je     f0105617 <readline+0x6d>
				cputchar(c);
f0105650:	83 ec 0c             	sub    $0xc,%esp
f0105653:	53                   	push   %ebx
f0105654:	e8 ef b0 ff ff       	call   f0100748 <cputchar>
f0105659:	83 c4 10             	add    $0x10,%esp
f010565c:	eb b9                	jmp    f0105617 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f010565e:	83 fb 0a             	cmp    $0xa,%ebx
f0105661:	74 05                	je     f0105668 <readline+0xbe>
f0105663:	83 fb 0d             	cmp    $0xd,%ebx
f0105666:	75 b8                	jne    f0105620 <readline+0x76>
			if (echoing)
f0105668:	85 ff                	test   %edi,%edi
f010566a:	75 11                	jne    f010567d <readline+0xd3>
			buf[i] = 0;
f010566c:	c6 86 a0 8a 21 f0 00 	movb   $0x0,-0xfde7560(%esi)
			return buf;
f0105673:	b8 a0 8a 21 f0       	mov    $0xf0218aa0,%eax
f0105678:	e9 7a ff ff ff       	jmp    f01055f7 <readline+0x4d>
				cputchar('\n');
f010567d:	83 ec 0c             	sub    $0xc,%esp
f0105680:	6a 0a                	push   $0xa
f0105682:	e8 c1 b0 ff ff       	call   f0100748 <cputchar>
f0105687:	83 c4 10             	add    $0x10,%esp
f010568a:	eb e0                	jmp    f010566c <readline+0xc2>

f010568c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010568c:	55                   	push   %ebp
f010568d:	89 e5                	mov    %esp,%ebp
f010568f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105692:	b8 00 00 00 00       	mov    $0x0,%eax
f0105697:	eb 03                	jmp    f010569c <strlen+0x10>
		n++;
f0105699:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f010569c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01056a0:	75 f7                	jne    f0105699 <strlen+0xd>
	return n;
}
f01056a2:	5d                   	pop    %ebp
f01056a3:	c3                   	ret    

f01056a4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01056a4:	55                   	push   %ebp
f01056a5:	89 e5                	mov    %esp,%ebp
f01056a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01056ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01056b2:	eb 03                	jmp    f01056b7 <strnlen+0x13>
		n++;
f01056b4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01056b7:	39 d0                	cmp    %edx,%eax
f01056b9:	74 08                	je     f01056c3 <strnlen+0x1f>
f01056bb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01056bf:	75 f3                	jne    f01056b4 <strnlen+0x10>
f01056c1:	89 c2                	mov    %eax,%edx
	return n;
}
f01056c3:	89 d0                	mov    %edx,%eax
f01056c5:	5d                   	pop    %ebp
f01056c6:	c3                   	ret    

f01056c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01056c7:	55                   	push   %ebp
f01056c8:	89 e5                	mov    %esp,%ebp
f01056ca:	53                   	push   %ebx
f01056cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01056d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01056d6:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01056da:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01056dd:	83 c0 01             	add    $0x1,%eax
f01056e0:	84 d2                	test   %dl,%dl
f01056e2:	75 f2                	jne    f01056d6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01056e4:	89 c8                	mov    %ecx,%eax
f01056e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01056e9:	c9                   	leave  
f01056ea:	c3                   	ret    

f01056eb <strcat>:

char *
strcat(char *dst, const char *src)
{
f01056eb:	55                   	push   %ebp
f01056ec:	89 e5                	mov    %esp,%ebp
f01056ee:	53                   	push   %ebx
f01056ef:	83 ec 10             	sub    $0x10,%esp
f01056f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01056f5:	53                   	push   %ebx
f01056f6:	e8 91 ff ff ff       	call   f010568c <strlen>
f01056fb:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01056fe:	ff 75 0c             	push   0xc(%ebp)
f0105701:	01 d8                	add    %ebx,%eax
f0105703:	50                   	push   %eax
f0105704:	e8 be ff ff ff       	call   f01056c7 <strcpy>
	return dst;
}
f0105709:	89 d8                	mov    %ebx,%eax
f010570b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010570e:	c9                   	leave  
f010570f:	c3                   	ret    

f0105710 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105710:	55                   	push   %ebp
f0105711:	89 e5                	mov    %esp,%ebp
f0105713:	56                   	push   %esi
f0105714:	53                   	push   %ebx
f0105715:	8b 75 08             	mov    0x8(%ebp),%esi
f0105718:	8b 55 0c             	mov    0xc(%ebp),%edx
f010571b:	89 f3                	mov    %esi,%ebx
f010571d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105720:	89 f0                	mov    %esi,%eax
f0105722:	eb 0f                	jmp    f0105733 <strncpy+0x23>
		*dst++ = *src;
f0105724:	83 c0 01             	add    $0x1,%eax
f0105727:	0f b6 0a             	movzbl (%edx),%ecx
f010572a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010572d:	80 f9 01             	cmp    $0x1,%cl
f0105730:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0105733:	39 d8                	cmp    %ebx,%eax
f0105735:	75 ed                	jne    f0105724 <strncpy+0x14>
	}
	return ret;
}
f0105737:	89 f0                	mov    %esi,%eax
f0105739:	5b                   	pop    %ebx
f010573a:	5e                   	pop    %esi
f010573b:	5d                   	pop    %ebp
f010573c:	c3                   	ret    

f010573d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010573d:	55                   	push   %ebp
f010573e:	89 e5                	mov    %esp,%ebp
f0105740:	56                   	push   %esi
f0105741:	53                   	push   %ebx
f0105742:	8b 75 08             	mov    0x8(%ebp),%esi
f0105745:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105748:	8b 55 10             	mov    0x10(%ebp),%edx
f010574b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010574d:	85 d2                	test   %edx,%edx
f010574f:	74 21                	je     f0105772 <strlcpy+0x35>
f0105751:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105755:	89 f2                	mov    %esi,%edx
f0105757:	eb 09                	jmp    f0105762 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105759:	83 c1 01             	add    $0x1,%ecx
f010575c:	83 c2 01             	add    $0x1,%edx
f010575f:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0105762:	39 c2                	cmp    %eax,%edx
f0105764:	74 09                	je     f010576f <strlcpy+0x32>
f0105766:	0f b6 19             	movzbl (%ecx),%ebx
f0105769:	84 db                	test   %bl,%bl
f010576b:	75 ec                	jne    f0105759 <strlcpy+0x1c>
f010576d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f010576f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105772:	29 f0                	sub    %esi,%eax
}
f0105774:	5b                   	pop    %ebx
f0105775:	5e                   	pop    %esi
f0105776:	5d                   	pop    %ebp
f0105777:	c3                   	ret    

f0105778 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105778:	55                   	push   %ebp
f0105779:	89 e5                	mov    %esp,%ebp
f010577b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010577e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105781:	eb 06                	jmp    f0105789 <strcmp+0x11>
		p++, q++;
f0105783:	83 c1 01             	add    $0x1,%ecx
f0105786:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105789:	0f b6 01             	movzbl (%ecx),%eax
f010578c:	84 c0                	test   %al,%al
f010578e:	74 04                	je     f0105794 <strcmp+0x1c>
f0105790:	3a 02                	cmp    (%edx),%al
f0105792:	74 ef                	je     f0105783 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105794:	0f b6 c0             	movzbl %al,%eax
f0105797:	0f b6 12             	movzbl (%edx),%edx
f010579a:	29 d0                	sub    %edx,%eax
}
f010579c:	5d                   	pop    %ebp
f010579d:	c3                   	ret    

f010579e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010579e:	55                   	push   %ebp
f010579f:	89 e5                	mov    %esp,%ebp
f01057a1:	53                   	push   %ebx
f01057a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01057a5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01057a8:	89 c3                	mov    %eax,%ebx
f01057aa:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01057ad:	eb 06                	jmp    f01057b5 <strncmp+0x17>
		n--, p++, q++;
f01057af:	83 c0 01             	add    $0x1,%eax
f01057b2:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01057b5:	39 d8                	cmp    %ebx,%eax
f01057b7:	74 18                	je     f01057d1 <strncmp+0x33>
f01057b9:	0f b6 08             	movzbl (%eax),%ecx
f01057bc:	84 c9                	test   %cl,%cl
f01057be:	74 04                	je     f01057c4 <strncmp+0x26>
f01057c0:	3a 0a                	cmp    (%edx),%cl
f01057c2:	74 eb                	je     f01057af <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01057c4:	0f b6 00             	movzbl (%eax),%eax
f01057c7:	0f b6 12             	movzbl (%edx),%edx
f01057ca:	29 d0                	sub    %edx,%eax
}
f01057cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01057cf:	c9                   	leave  
f01057d0:	c3                   	ret    
		return 0;
f01057d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01057d6:	eb f4                	jmp    f01057cc <strncmp+0x2e>

f01057d8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01057d8:	55                   	push   %ebp
f01057d9:	89 e5                	mov    %esp,%ebp
f01057db:	8b 45 08             	mov    0x8(%ebp),%eax
f01057de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01057e2:	eb 03                	jmp    f01057e7 <strchr+0xf>
f01057e4:	83 c0 01             	add    $0x1,%eax
f01057e7:	0f b6 10             	movzbl (%eax),%edx
f01057ea:	84 d2                	test   %dl,%dl
f01057ec:	74 06                	je     f01057f4 <strchr+0x1c>
		if (*s == c)
f01057ee:	38 ca                	cmp    %cl,%dl
f01057f0:	75 f2                	jne    f01057e4 <strchr+0xc>
f01057f2:	eb 05                	jmp    f01057f9 <strchr+0x21>
			return (char *) s;
	return 0;
f01057f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057f9:	5d                   	pop    %ebp
f01057fa:	c3                   	ret    

f01057fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01057fb:	55                   	push   %ebp
f01057fc:	89 e5                	mov    %esp,%ebp
f01057fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0105801:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105805:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105808:	38 ca                	cmp    %cl,%dl
f010580a:	74 09                	je     f0105815 <strfind+0x1a>
f010580c:	84 d2                	test   %dl,%dl
f010580e:	74 05                	je     f0105815 <strfind+0x1a>
	for (; *s; s++)
f0105810:	83 c0 01             	add    $0x1,%eax
f0105813:	eb f0                	jmp    f0105805 <strfind+0xa>
			break;
	return (char *) s;
}
f0105815:	5d                   	pop    %ebp
f0105816:	c3                   	ret    

f0105817 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105817:	55                   	push   %ebp
f0105818:	89 e5                	mov    %esp,%ebp
f010581a:	57                   	push   %edi
f010581b:	56                   	push   %esi
f010581c:	53                   	push   %ebx
f010581d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105820:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105823:	85 c9                	test   %ecx,%ecx
f0105825:	74 2f                	je     f0105856 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105827:	89 f8                	mov    %edi,%eax
f0105829:	09 c8                	or     %ecx,%eax
f010582b:	a8 03                	test   $0x3,%al
f010582d:	75 21                	jne    f0105850 <memset+0x39>
		c &= 0xFF;
f010582f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105833:	89 d0                	mov    %edx,%eax
f0105835:	c1 e0 08             	shl    $0x8,%eax
f0105838:	89 d3                	mov    %edx,%ebx
f010583a:	c1 e3 18             	shl    $0x18,%ebx
f010583d:	89 d6                	mov    %edx,%esi
f010583f:	c1 e6 10             	shl    $0x10,%esi
f0105842:	09 f3                	or     %esi,%ebx
f0105844:	09 da                	or     %ebx,%edx
f0105846:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105848:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010584b:	fc                   	cld    
f010584c:	f3 ab                	rep stos %eax,%es:(%edi)
f010584e:	eb 06                	jmp    f0105856 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105850:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105853:	fc                   	cld    
f0105854:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105856:	89 f8                	mov    %edi,%eax
f0105858:	5b                   	pop    %ebx
f0105859:	5e                   	pop    %esi
f010585a:	5f                   	pop    %edi
f010585b:	5d                   	pop    %ebp
f010585c:	c3                   	ret    

f010585d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010585d:	55                   	push   %ebp
f010585e:	89 e5                	mov    %esp,%ebp
f0105860:	57                   	push   %edi
f0105861:	56                   	push   %esi
f0105862:	8b 45 08             	mov    0x8(%ebp),%eax
f0105865:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105868:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010586b:	39 c6                	cmp    %eax,%esi
f010586d:	73 32                	jae    f01058a1 <memmove+0x44>
f010586f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105872:	39 c2                	cmp    %eax,%edx
f0105874:	76 2b                	jbe    f01058a1 <memmove+0x44>
		s += n;
		d += n;
f0105876:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105879:	89 d6                	mov    %edx,%esi
f010587b:	09 fe                	or     %edi,%esi
f010587d:	09 ce                	or     %ecx,%esi
f010587f:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105885:	75 0e                	jne    f0105895 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105887:	83 ef 04             	sub    $0x4,%edi
f010588a:	8d 72 fc             	lea    -0x4(%edx),%esi
f010588d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105890:	fd                   	std    
f0105891:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105893:	eb 09                	jmp    f010589e <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105895:	83 ef 01             	sub    $0x1,%edi
f0105898:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010589b:	fd                   	std    
f010589c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010589e:	fc                   	cld    
f010589f:	eb 1a                	jmp    f01058bb <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01058a1:	89 f2                	mov    %esi,%edx
f01058a3:	09 c2                	or     %eax,%edx
f01058a5:	09 ca                	or     %ecx,%edx
f01058a7:	f6 c2 03             	test   $0x3,%dl
f01058aa:	75 0a                	jne    f01058b6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01058ac:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01058af:	89 c7                	mov    %eax,%edi
f01058b1:	fc                   	cld    
f01058b2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01058b4:	eb 05                	jmp    f01058bb <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f01058b6:	89 c7                	mov    %eax,%edi
f01058b8:	fc                   	cld    
f01058b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01058bb:	5e                   	pop    %esi
f01058bc:	5f                   	pop    %edi
f01058bd:	5d                   	pop    %ebp
f01058be:	c3                   	ret    

f01058bf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01058bf:	55                   	push   %ebp
f01058c0:	89 e5                	mov    %esp,%ebp
f01058c2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01058c5:	ff 75 10             	push   0x10(%ebp)
f01058c8:	ff 75 0c             	push   0xc(%ebp)
f01058cb:	ff 75 08             	push   0x8(%ebp)
f01058ce:	e8 8a ff ff ff       	call   f010585d <memmove>
}
f01058d3:	c9                   	leave  
f01058d4:	c3                   	ret    

f01058d5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01058d5:	55                   	push   %ebp
f01058d6:	89 e5                	mov    %esp,%ebp
f01058d8:	56                   	push   %esi
f01058d9:	53                   	push   %ebx
f01058da:	8b 45 08             	mov    0x8(%ebp),%eax
f01058dd:	8b 55 0c             	mov    0xc(%ebp),%edx
f01058e0:	89 c6                	mov    %eax,%esi
f01058e2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01058e5:	eb 06                	jmp    f01058ed <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01058e7:	83 c0 01             	add    $0x1,%eax
f01058ea:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f01058ed:	39 f0                	cmp    %esi,%eax
f01058ef:	74 14                	je     f0105905 <memcmp+0x30>
		if (*s1 != *s2)
f01058f1:	0f b6 08             	movzbl (%eax),%ecx
f01058f4:	0f b6 1a             	movzbl (%edx),%ebx
f01058f7:	38 d9                	cmp    %bl,%cl
f01058f9:	74 ec                	je     f01058e7 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f01058fb:	0f b6 c1             	movzbl %cl,%eax
f01058fe:	0f b6 db             	movzbl %bl,%ebx
f0105901:	29 d8                	sub    %ebx,%eax
f0105903:	eb 05                	jmp    f010590a <memcmp+0x35>
	}

	return 0;
f0105905:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010590a:	5b                   	pop    %ebx
f010590b:	5e                   	pop    %esi
f010590c:	5d                   	pop    %ebp
f010590d:	c3                   	ret    

f010590e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010590e:	55                   	push   %ebp
f010590f:	89 e5                	mov    %esp,%ebp
f0105911:	8b 45 08             	mov    0x8(%ebp),%eax
f0105914:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105917:	89 c2                	mov    %eax,%edx
f0105919:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010591c:	eb 03                	jmp    f0105921 <memfind+0x13>
f010591e:	83 c0 01             	add    $0x1,%eax
f0105921:	39 d0                	cmp    %edx,%eax
f0105923:	73 04                	jae    f0105929 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105925:	38 08                	cmp    %cl,(%eax)
f0105927:	75 f5                	jne    f010591e <memfind+0x10>
			break;
	return (void *) s;
}
f0105929:	5d                   	pop    %ebp
f010592a:	c3                   	ret    

f010592b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010592b:	55                   	push   %ebp
f010592c:	89 e5                	mov    %esp,%ebp
f010592e:	57                   	push   %edi
f010592f:	56                   	push   %esi
f0105930:	53                   	push   %ebx
f0105931:	8b 55 08             	mov    0x8(%ebp),%edx
f0105934:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105937:	eb 03                	jmp    f010593c <strtol+0x11>
		s++;
f0105939:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f010593c:	0f b6 02             	movzbl (%edx),%eax
f010593f:	3c 20                	cmp    $0x20,%al
f0105941:	74 f6                	je     f0105939 <strtol+0xe>
f0105943:	3c 09                	cmp    $0x9,%al
f0105945:	74 f2                	je     f0105939 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105947:	3c 2b                	cmp    $0x2b,%al
f0105949:	74 2a                	je     f0105975 <strtol+0x4a>
	int neg = 0;
f010594b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105950:	3c 2d                	cmp    $0x2d,%al
f0105952:	74 2b                	je     f010597f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105954:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010595a:	75 0f                	jne    f010596b <strtol+0x40>
f010595c:	80 3a 30             	cmpb   $0x30,(%edx)
f010595f:	74 28                	je     f0105989 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105961:	85 db                	test   %ebx,%ebx
f0105963:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105968:	0f 44 d8             	cmove  %eax,%ebx
f010596b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105970:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105973:	eb 46                	jmp    f01059bb <strtol+0x90>
		s++;
f0105975:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0105978:	bf 00 00 00 00       	mov    $0x0,%edi
f010597d:	eb d5                	jmp    f0105954 <strtol+0x29>
		s++, neg = 1;
f010597f:	83 c2 01             	add    $0x1,%edx
f0105982:	bf 01 00 00 00       	mov    $0x1,%edi
f0105987:	eb cb                	jmp    f0105954 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105989:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010598d:	74 0e                	je     f010599d <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f010598f:	85 db                	test   %ebx,%ebx
f0105991:	75 d8                	jne    f010596b <strtol+0x40>
		s++, base = 8;
f0105993:	83 c2 01             	add    $0x1,%edx
f0105996:	bb 08 00 00 00       	mov    $0x8,%ebx
f010599b:	eb ce                	jmp    f010596b <strtol+0x40>
		s += 2, base = 16;
f010599d:	83 c2 02             	add    $0x2,%edx
f01059a0:	bb 10 00 00 00       	mov    $0x10,%ebx
f01059a5:	eb c4                	jmp    f010596b <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01059a7:	0f be c0             	movsbl %al,%eax
f01059aa:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01059ad:	3b 45 10             	cmp    0x10(%ebp),%eax
f01059b0:	7d 3a                	jge    f01059ec <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f01059b2:	83 c2 01             	add    $0x1,%edx
f01059b5:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f01059b9:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f01059bb:	0f b6 02             	movzbl (%edx),%eax
f01059be:	8d 70 d0             	lea    -0x30(%eax),%esi
f01059c1:	89 f3                	mov    %esi,%ebx
f01059c3:	80 fb 09             	cmp    $0x9,%bl
f01059c6:	76 df                	jbe    f01059a7 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f01059c8:	8d 70 9f             	lea    -0x61(%eax),%esi
f01059cb:	89 f3                	mov    %esi,%ebx
f01059cd:	80 fb 19             	cmp    $0x19,%bl
f01059d0:	77 08                	ja     f01059da <strtol+0xaf>
			dig = *s - 'a' + 10;
f01059d2:	0f be c0             	movsbl %al,%eax
f01059d5:	83 e8 57             	sub    $0x57,%eax
f01059d8:	eb d3                	jmp    f01059ad <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f01059da:	8d 70 bf             	lea    -0x41(%eax),%esi
f01059dd:	89 f3                	mov    %esi,%ebx
f01059df:	80 fb 19             	cmp    $0x19,%bl
f01059e2:	77 08                	ja     f01059ec <strtol+0xc1>
			dig = *s - 'A' + 10;
f01059e4:	0f be c0             	movsbl %al,%eax
f01059e7:	83 e8 37             	sub    $0x37,%eax
f01059ea:	eb c1                	jmp    f01059ad <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f01059ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01059f0:	74 05                	je     f01059f7 <strtol+0xcc>
		*endptr = (char *) s;
f01059f2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01059f5:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f01059f7:	89 c8                	mov    %ecx,%eax
f01059f9:	f7 d8                	neg    %eax
f01059fb:	85 ff                	test   %edi,%edi
f01059fd:	0f 45 c8             	cmovne %eax,%ecx
}
f0105a00:	89 c8                	mov    %ecx,%eax
f0105a02:	5b                   	pop    %ebx
f0105a03:	5e                   	pop    %esi
f0105a04:	5f                   	pop    %edi
f0105a05:	5d                   	pop    %ebp
f0105a06:	c3                   	ret    
f0105a07:	90                   	nop

f0105a08 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105a08:	fa                   	cli    

	xorw    %ax, %ax
f0105a09:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105a0b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a0d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a0f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105a11:	0f 01 16             	lgdtl  (%esi)
f0105a14:	74 70                	je     f0105a86 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105a16:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105a19:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105a1d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105a20:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105a26:	08 00                	or     %al,(%eax)

f0105a28 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105a28:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105a2c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a2e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a30:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105a32:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105a36:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105a38:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105a3a:	b8 00 30 12 00       	mov    $0x123000,%eax
	movl    %eax, %cr3
f0105a3f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105a42:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105a45:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105a4a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105a4d:	8b 25 04 80 21 f0    	mov    0xf0218004,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105a53:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105a58:	b8 a4 01 10 f0       	mov    $0xf01001a4,%eax
	call    *%eax
f0105a5d:	ff d0                	call   *%eax

f0105a5f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105a5f:	eb fe                	jmp    f0105a5f <spin>
f0105a61:	8d 76 00             	lea    0x0(%esi),%esi

f0105a64 <gdt>:
	...
f0105a6c:	ff                   	(bad)  
f0105a6d:	ff 00                	incl   (%eax)
f0105a6f:	00 00                	add    %al,(%eax)
f0105a71:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105a78:	00                   	.byte 0x0
f0105a79:	92                   	xchg   %eax,%edx
f0105a7a:	cf                   	iret   
	...

f0105a7c <gdtdesc>:
f0105a7c:	17                   	pop    %ss
f0105a7d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105a82 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105a82:	90                   	nop

f0105a83 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105a83:	55                   	push   %ebp
f0105a84:	89 e5                	mov    %esp,%ebp
f0105a86:	57                   	push   %edi
f0105a87:	56                   	push   %esi
f0105a88:	53                   	push   %ebx
f0105a89:	83 ec 1c             	sub    $0x1c,%esp
f0105a8c:	89 c6                	mov    %eax,%esi
	if (PGNUM(pa) >= npages)
f0105a8e:	8b 0d 60 82 21 f0    	mov    0xf0218260,%ecx
f0105a94:	c1 e8 0c             	shr    $0xc,%eax
f0105a97:	39 c8                	cmp    %ecx,%eax
f0105a99:	73 22                	jae    f0105abd <mpsearch1+0x3a>
	return (void *)(pa + KERNBASE);
f0105a9b:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105aa1:	8d 04 32             	lea    (%edx,%esi,1),%eax
	if (PGNUM(pa) >= npages)
f0105aa4:	89 c2                	mov    %eax,%edx
f0105aa6:	c1 ea 0c             	shr    $0xc,%edx
f0105aa9:	39 ca                	cmp    %ecx,%edx
f0105aab:	73 22                	jae    f0105acf <mpsearch1+0x4c>
	return (void *)(pa + KERNBASE);
f0105aad:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0105ab2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ab5:	81 ee f0 ff ff 0f    	sub    $0xffffff0,%esi

	for (; mp < end; mp++)
f0105abb:	eb 2a                	jmp    f0105ae7 <mpsearch1+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105abd:	56                   	push   %esi
f0105abe:	68 64 64 10 f0       	push   $0xf0106464
f0105ac3:	6a 58                	push   $0x58
f0105ac5:	68 61 80 10 f0       	push   $0xf0108061
f0105aca:	e8 71 a5 ff ff       	call   f0100040 <_panic>
f0105acf:	50                   	push   %eax
f0105ad0:	68 64 64 10 f0       	push   $0xf0106464
f0105ad5:	6a 58                	push   $0x58
f0105ad7:	68 61 80 10 f0       	push   $0xf0108061
f0105adc:	e8 5f a5 ff ff       	call   f0100040 <_panic>
f0105ae1:	83 c7 10             	add    $0x10,%edi
f0105ae4:	83 c6 10             	add    $0x10,%esi
f0105ae7:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0105aea:	73 2b                	jae    f0105b17 <mpsearch1+0x94>
f0105aec:	89 fb                	mov    %edi,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105aee:	83 ec 04             	sub    $0x4,%esp
f0105af1:	6a 04                	push   $0x4
f0105af3:	68 71 80 10 f0       	push   $0xf0108071
f0105af8:	57                   	push   %edi
f0105af9:	e8 d7 fd ff ff       	call   f01058d5 <memcmp>
f0105afe:	83 c4 10             	add    $0x10,%esp
f0105b01:	85 c0                	test   %eax,%eax
f0105b03:	75 dc                	jne    f0105ae1 <mpsearch1+0x5e>
		sum += ((uint8_t *)addr)[i];
f0105b05:	0f b6 13             	movzbl (%ebx),%edx
f0105b08:	01 d0                	add    %edx,%eax
	for (i = 0; i < len; i++)
f0105b0a:	83 c3 01             	add    $0x1,%ebx
f0105b0d:	39 f3                	cmp    %esi,%ebx
f0105b0f:	75 f4                	jne    f0105b05 <mpsearch1+0x82>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105b11:	84 c0                	test   %al,%al
f0105b13:	75 cc                	jne    f0105ae1 <mpsearch1+0x5e>
f0105b15:	eb 05                	jmp    f0105b1c <mpsearch1+0x99>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105b17:	bf 00 00 00 00       	mov    $0x0,%edi
}
f0105b1c:	89 f8                	mov    %edi,%eax
f0105b1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b21:	5b                   	pop    %ebx
f0105b22:	5e                   	pop    %esi
f0105b23:	5f                   	pop    %edi
f0105b24:	5d                   	pop    %ebp
f0105b25:	c3                   	ret    

f0105b26 <mp_init>:
}

//通过读取位于BIOS内存区域中的MP配置表来获取该信息。
void
mp_init(void)
{
f0105b26:	55                   	push   %ebp
f0105b27:	89 e5                	mov    %esp,%ebp
f0105b29:	57                   	push   %edi
f0105b2a:	56                   	push   %esi
f0105b2b:	53                   	push   %ebx
f0105b2c:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105b2f:	c7 05 08 90 25 f0 20 	movl   $0xf0259020,0xf0259008
f0105b36:	90 25 f0 
	if (PGNUM(pa) >= npages)
f0105b39:	83 3d 60 82 21 f0 00 	cmpl   $0x0,0xf0218260
f0105b40:	0f 84 86 00 00 00    	je     f0105bcc <mp_init+0xa6>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105b46:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105b4d:	85 c0                	test   %eax,%eax
f0105b4f:	0f 84 8d 00 00 00    	je     f0105be2 <mp_init+0xbc>
		p <<= 4;	// Translate from segment to PA
f0105b55:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105b58:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b5d:	e8 21 ff ff ff       	call   f0105a83 <mpsearch1>
f0105b62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b65:	85 c0                	test   %eax,%eax
f0105b67:	75 1a                	jne    f0105b83 <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f0105b69:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105b6e:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105b73:	e8 0b ff ff ff       	call   f0105a83 <mpsearch1>
f0105b78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0105b7b:	85 c0                	test   %eax,%eax
f0105b7d:	0f 84 20 02 00 00    	je     f0105da3 <mp_init+0x27d>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105b83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b86:	8b 58 04             	mov    0x4(%eax),%ebx
f0105b89:	85 db                	test   %ebx,%ebx
f0105b8b:	74 7a                	je     f0105c07 <mp_init+0xe1>
f0105b8d:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105b91:	75 74                	jne    f0105c07 <mp_init+0xe1>
f0105b93:	89 d8                	mov    %ebx,%eax
f0105b95:	c1 e8 0c             	shr    $0xc,%eax
f0105b98:	3b 05 60 82 21 f0    	cmp    0xf0218260,%eax
f0105b9e:	73 7c                	jae    f0105c1c <mp_init+0xf6>
	return (void *)(pa + KERNBASE);
f0105ba0:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0105ba6:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105ba8:	83 ec 04             	sub    $0x4,%esp
f0105bab:	6a 04                	push   $0x4
f0105bad:	68 76 80 10 f0       	push   $0xf0108076
f0105bb2:	53                   	push   %ebx
f0105bb3:	e8 1d fd ff ff       	call   f01058d5 <memcmp>
f0105bb8:	83 c4 10             	add    $0x10,%esp
f0105bbb:	85 c0                	test   %eax,%eax
f0105bbd:	75 72                	jne    f0105c31 <mp_init+0x10b>
f0105bbf:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105bc3:	01 df                	add    %ebx,%edi
	sum = 0;
f0105bc5:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0105bc7:	e9 82 00 00 00       	jmp    f0105c4e <mp_init+0x128>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105bcc:	68 00 04 00 00       	push   $0x400
f0105bd1:	68 64 64 10 f0       	push   $0xf0106464
f0105bd6:	6a 70                	push   $0x70
f0105bd8:	68 61 80 10 f0       	push   $0xf0108061
f0105bdd:	e8 5e a4 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105be2:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105be9:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105bec:	2d 00 04 00 00       	sub    $0x400,%eax
f0105bf1:	ba 00 04 00 00       	mov    $0x400,%edx
f0105bf6:	e8 88 fe ff ff       	call   f0105a83 <mpsearch1>
f0105bfb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105bfe:	85 c0                	test   %eax,%eax
f0105c00:	75 81                	jne    f0105b83 <mp_init+0x5d>
f0105c02:	e9 62 ff ff ff       	jmp    f0105b69 <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f0105c07:	83 ec 0c             	sub    $0xc,%esp
f0105c0a:	68 d4 7e 10 f0       	push   $0xf0107ed4
f0105c0f:	e8 9e dd ff ff       	call   f01039b2 <cprintf>
		return NULL;
f0105c14:	83 c4 10             	add    $0x10,%esp
f0105c17:	e9 87 01 00 00       	jmp    f0105da3 <mp_init+0x27d>
f0105c1c:	53                   	push   %ebx
f0105c1d:	68 64 64 10 f0       	push   $0xf0106464
f0105c22:	68 91 00 00 00       	push   $0x91
f0105c27:	68 61 80 10 f0       	push   $0xf0108061
f0105c2c:	e8 0f a4 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105c31:	83 ec 0c             	sub    $0xc,%esp
f0105c34:	68 04 7f 10 f0       	push   $0xf0107f04
f0105c39:	e8 74 dd ff ff       	call   f01039b2 <cprintf>
		return NULL;
f0105c3e:	83 c4 10             	add    $0x10,%esp
f0105c41:	e9 5d 01 00 00       	jmp    f0105da3 <mp_init+0x27d>
		sum += ((uint8_t *)addr)[i];
f0105c46:	0f b6 0b             	movzbl (%ebx),%ecx
f0105c49:	01 ca                	add    %ecx,%edx
f0105c4b:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105c4e:	39 fb                	cmp    %edi,%ebx
f0105c50:	75 f4                	jne    f0105c46 <mp_init+0x120>
	if (sum(conf, conf->length) != 0) {
f0105c52:	84 d2                	test   %dl,%dl
f0105c54:	75 16                	jne    f0105c6c <mp_init+0x146>
	if (conf->version != 1 && conf->version != 4) {
f0105c56:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105c5a:	80 fa 01             	cmp    $0x1,%dl
f0105c5d:	74 05                	je     f0105c64 <mp_init+0x13e>
f0105c5f:	80 fa 04             	cmp    $0x4,%dl
f0105c62:	75 1d                	jne    f0105c81 <mp_init+0x15b>
f0105c64:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0105c68:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f0105c6a:	eb 36                	jmp    f0105ca2 <mp_init+0x17c>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105c6c:	83 ec 0c             	sub    $0xc,%esp
f0105c6f:	68 38 7f 10 f0       	push   $0xf0107f38
f0105c74:	e8 39 dd ff ff       	call   f01039b2 <cprintf>
		return NULL;
f0105c79:	83 c4 10             	add    $0x10,%esp
f0105c7c:	e9 22 01 00 00       	jmp    f0105da3 <mp_init+0x27d>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105c81:	83 ec 08             	sub    $0x8,%esp
f0105c84:	0f b6 d2             	movzbl %dl,%edx
f0105c87:	52                   	push   %edx
f0105c88:	68 5c 7f 10 f0       	push   $0xf0107f5c
f0105c8d:	e8 20 dd ff ff       	call   f01039b2 <cprintf>
		return NULL;
f0105c92:	83 c4 10             	add    $0x10,%esp
f0105c95:	e9 09 01 00 00       	jmp    f0105da3 <mp_init+0x27d>
		sum += ((uint8_t *)addr)[i];
f0105c9a:	0f b6 13             	movzbl (%ebx),%edx
f0105c9d:	01 d0                	add    %edx,%eax
f0105c9f:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105ca2:	39 d9                	cmp    %ebx,%ecx
f0105ca4:	75 f4                	jne    f0105c9a <mp_init+0x174>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105ca6:	02 46 2a             	add    0x2a(%esi),%al
f0105ca9:	75 1c                	jne    f0105cc7 <mp_init+0x1a1>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f0105cab:	c7 05 04 90 25 f0 01 	movl   $0x1,0xf0259004
f0105cb2:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105cb5:	8b 46 24             	mov    0x24(%esi),%eax
f0105cb8:	a3 c4 93 25 f0       	mov    %eax,0xf02593c4

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105cbd:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105cc5:	eb 4d                	jmp    f0105d14 <mp_init+0x1ee>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105cc7:	83 ec 0c             	sub    $0xc,%esp
f0105cca:	68 7c 7f 10 f0       	push   $0xf0107f7c
f0105ccf:	e8 de dc ff ff       	call   f01039b2 <cprintf>
		return NULL;
f0105cd4:	83 c4 10             	add    $0x10,%esp
f0105cd7:	e9 c7 00 00 00       	jmp    f0105da3 <mp_init+0x27d>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105cdc:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105ce0:	74 11                	je     f0105cf3 <mp_init+0x1cd>
				bootcpu = &cpus[ncpu];
f0105ce2:	6b 05 00 90 25 f0 74 	imul   $0x74,0xf0259000,%eax
f0105ce9:	05 20 90 25 f0       	add    $0xf0259020,%eax
f0105cee:	a3 08 90 25 f0       	mov    %eax,0xf0259008
			if (ncpu < NCPU) {
f0105cf3:	a1 00 90 25 f0       	mov    0xf0259000,%eax
f0105cf8:	83 f8 07             	cmp    $0x7,%eax
f0105cfb:	7f 33                	jg     f0105d30 <mp_init+0x20a>
				cpus[ncpu].cpu_id = ncpu;
f0105cfd:	6b d0 74             	imul   $0x74,%eax,%edx
f0105d00:	88 82 20 90 25 f0    	mov    %al,-0xfda6fe0(%edx)
				ncpu++;
f0105d06:	83 c0 01             	add    $0x1,%eax
f0105d09:	a3 00 90 25 f0       	mov    %eax,0xf0259000
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105d0e:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d11:	83 c3 01             	add    $0x1,%ebx
f0105d14:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105d18:	39 d8                	cmp    %ebx,%eax
f0105d1a:	76 4f                	jbe    f0105d6b <mp_init+0x245>
		switch (*p) {
f0105d1c:	0f b6 07             	movzbl (%edi),%eax
f0105d1f:	84 c0                	test   %al,%al
f0105d21:	74 b9                	je     f0105cdc <mp_init+0x1b6>
f0105d23:	8d 50 ff             	lea    -0x1(%eax),%edx
f0105d26:	80 fa 03             	cmp    $0x3,%dl
f0105d29:	77 1c                	ja     f0105d47 <mp_init+0x221>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105d2b:	83 c7 08             	add    $0x8,%edi
			continue;
f0105d2e:	eb e1                	jmp    f0105d11 <mp_init+0x1eb>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105d30:	83 ec 08             	sub    $0x8,%esp
f0105d33:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105d37:	50                   	push   %eax
f0105d38:	68 ac 7f 10 f0       	push   $0xf0107fac
f0105d3d:	e8 70 dc ff ff       	call   f01039b2 <cprintf>
f0105d42:	83 c4 10             	add    $0x10,%esp
f0105d45:	eb c7                	jmp    f0105d0e <mp_init+0x1e8>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d47:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105d4a:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d4d:	50                   	push   %eax
f0105d4e:	68 d4 7f 10 f0       	push   $0xf0107fd4
f0105d53:	e8 5a dc ff ff       	call   f01039b2 <cprintf>
			ismp = 0;
f0105d58:	c7 05 04 90 25 f0 00 	movl   $0x0,0xf0259004
f0105d5f:	00 00 00 
			i = conf->entry;
f0105d62:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0105d66:	83 c4 10             	add    $0x10,%esp
f0105d69:	eb a6                	jmp    f0105d11 <mp_init+0x1eb>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105d6b:	a1 08 90 25 f0       	mov    0xf0259008,%eax
f0105d70:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105d77:	83 3d 04 90 25 f0 00 	cmpl   $0x0,0xf0259004
f0105d7e:	74 2b                	je     f0105dab <mp_init+0x285>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105d80:	83 ec 04             	sub    $0x4,%esp
f0105d83:	ff 35 00 90 25 f0    	push   0xf0259000
f0105d89:	0f b6 00             	movzbl (%eax),%eax
f0105d8c:	50                   	push   %eax
f0105d8d:	68 7b 80 10 f0       	push   $0xf010807b
f0105d92:	e8 1b dc ff ff       	call   f01039b2 <cprintf>

	if (mp->imcrp) {
f0105d97:	83 c4 10             	add    $0x10,%esp
f0105d9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d9d:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105da1:	75 2e                	jne    f0105dd1 <mp_init+0x2ab>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105da6:	5b                   	pop    %ebx
f0105da7:	5e                   	pop    %esi
f0105da8:	5f                   	pop    %edi
f0105da9:	5d                   	pop    %ebp
f0105daa:	c3                   	ret    
		ncpu = 1;
f0105dab:	c7 05 00 90 25 f0 01 	movl   $0x1,0xf0259000
f0105db2:	00 00 00 
		lapicaddr = 0;
f0105db5:	c7 05 c4 93 25 f0 00 	movl   $0x0,0xf02593c4
f0105dbc:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105dbf:	83 ec 0c             	sub    $0xc,%esp
f0105dc2:	68 f4 7f 10 f0       	push   $0xf0107ff4
f0105dc7:	e8 e6 db ff ff       	call   f01039b2 <cprintf>
		return;
f0105dcc:	83 c4 10             	add    $0x10,%esp
f0105dcf:	eb d2                	jmp    f0105da3 <mp_init+0x27d>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105dd1:	83 ec 0c             	sub    $0xc,%esp
f0105dd4:	68 20 80 10 f0       	push   $0xf0108020
f0105dd9:	e8 d4 db ff ff       	call   f01039b2 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105dde:	b8 70 00 00 00       	mov    $0x70,%eax
f0105de3:	ba 22 00 00 00       	mov    $0x22,%edx
f0105de8:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105de9:	ba 23 00 00 00       	mov    $0x23,%edx
f0105dee:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105def:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105df2:	ee                   	out    %al,(%dx)
}
f0105df3:	83 c4 10             	add    $0x10,%esp
f0105df6:	eb ab                	jmp    f0105da3 <mp_init+0x27d>

f0105df8 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0105df8:	8b 0d c0 93 25 f0    	mov    0xf02593c0,%ecx
f0105dfe:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105e01:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105e03:	a1 c0 93 25 f0       	mov    0xf02593c0,%eax
f0105e08:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105e0b:	c3                   	ret    

f0105e0c <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f0105e0c:	8b 15 c0 93 25 f0    	mov    0xf02593c0,%edx
		return lapic[ID] >> 24;
	return 0;
f0105e12:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105e17:	85 d2                	test   %edx,%edx
f0105e19:	74 06                	je     f0105e21 <cpunum+0x15>
		return lapic[ID] >> 24;
f0105e1b:	8b 42 20             	mov    0x20(%edx),%eax
f0105e1e:	c1 e8 18             	shr    $0x18,%eax
}
f0105e21:	c3                   	ret    

f0105e22 <lapic_init>:
	if (!lapicaddr)
f0105e22:	a1 c4 93 25 f0       	mov    0xf02593c4,%eax
f0105e27:	85 c0                	test   %eax,%eax
f0105e29:	75 01                	jne    f0105e2c <lapic_init+0xa>
f0105e2b:	c3                   	ret    
{
f0105e2c:	55                   	push   %ebp
f0105e2d:	89 e5                	mov    %esp,%ebp
f0105e2f:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105e32:	68 00 10 00 00       	push   $0x1000
f0105e37:	50                   	push   %eax
f0105e38:	e8 4b b4 ff ff       	call   f0101288 <mmio_map_region>
f0105e3d:	a3 c0 93 25 f0       	mov    %eax,0xf02593c0
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105e42:	ba 27 01 00 00       	mov    $0x127,%edx
f0105e47:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105e4c:	e8 a7 ff ff ff       	call   f0105df8 <lapicw>
	lapicw(TDCR, X1);
f0105e51:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105e56:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105e5b:	e8 98 ff ff ff       	call   f0105df8 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105e60:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105e65:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105e6a:	e8 89 ff ff ff       	call   f0105df8 <lapicw>
	lapicw(TICR, 10000000); 
f0105e6f:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105e74:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105e79:	e8 7a ff ff ff       	call   f0105df8 <lapicw>
	if (thiscpu != bootcpu)
f0105e7e:	e8 89 ff ff ff       	call   f0105e0c <cpunum>
f0105e83:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e86:	05 20 90 25 f0       	add    $0xf0259020,%eax
f0105e8b:	83 c4 10             	add    $0x10,%esp
f0105e8e:	39 05 08 90 25 f0    	cmp    %eax,0xf0259008
f0105e94:	74 0f                	je     f0105ea5 <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f0105e96:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e9b:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105ea0:	e8 53 ff ff ff       	call   f0105df8 <lapicw>
	lapicw(LINT1, MASKED);
f0105ea5:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105eaa:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105eaf:	e8 44 ff ff ff       	call   f0105df8 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105eb4:	a1 c0 93 25 f0       	mov    0xf02593c0,%eax
f0105eb9:	8b 40 30             	mov    0x30(%eax),%eax
f0105ebc:	c1 e8 10             	shr    $0x10,%eax
f0105ebf:	a8 fc                	test   $0xfc,%al
f0105ec1:	75 7c                	jne    f0105f3f <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105ec3:	ba 33 00 00 00       	mov    $0x33,%edx
f0105ec8:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105ecd:	e8 26 ff ff ff       	call   f0105df8 <lapicw>
	lapicw(ESR, 0);
f0105ed2:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ed7:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105edc:	e8 17 ff ff ff       	call   f0105df8 <lapicw>
	lapicw(ESR, 0);
f0105ee1:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ee6:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105eeb:	e8 08 ff ff ff       	call   f0105df8 <lapicw>
	lapicw(EOI, 0);
f0105ef0:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ef5:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105efa:	e8 f9 fe ff ff       	call   f0105df8 <lapicw>
	lapicw(ICRHI, 0);
f0105eff:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f04:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f09:	e8 ea fe ff ff       	call   f0105df8 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105f0e:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105f13:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f18:	e8 db fe ff ff       	call   f0105df8 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105f1d:	8b 15 c0 93 25 f0    	mov    0xf02593c0,%edx
f0105f23:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105f29:	f6 c4 10             	test   $0x10,%ah
f0105f2c:	75 f5                	jne    f0105f23 <lapic_init+0x101>
	lapicw(TPR, 0);
f0105f2e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f33:	b8 20 00 00 00       	mov    $0x20,%eax
f0105f38:	e8 bb fe ff ff       	call   f0105df8 <lapicw>
}
f0105f3d:	c9                   	leave  
f0105f3e:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0105f3f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f44:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105f49:	e8 aa fe ff ff       	call   f0105df8 <lapicw>
f0105f4e:	e9 70 ff ff ff       	jmp    f0105ec3 <lapic_init+0xa1>

f0105f53 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105f53:	83 3d c0 93 25 f0 00 	cmpl   $0x0,0xf02593c0
f0105f5a:	74 17                	je     f0105f73 <lapic_eoi+0x20>
{
f0105f5c:	55                   	push   %ebp
f0105f5d:	89 e5                	mov    %esp,%ebp
f0105f5f:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0105f62:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f67:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f6c:	e8 87 fe ff ff       	call   f0105df8 <lapicw>
}
f0105f71:	c9                   	leave  
f0105f72:	c3                   	ret    
f0105f73:	c3                   	ret    

f0105f74 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105f74:	55                   	push   %ebp
f0105f75:	89 e5                	mov    %esp,%ebp
f0105f77:	56                   	push   %esi
f0105f78:	53                   	push   %ebx
f0105f79:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105f7f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105f84:	ba 70 00 00 00       	mov    $0x70,%edx
f0105f89:	ee                   	out    %al,(%dx)
f0105f8a:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105f8f:	ba 71 00 00 00       	mov    $0x71,%edx
f0105f94:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105f95:	83 3d 60 82 21 f0 00 	cmpl   $0x0,0xf0218260
f0105f9c:	74 7e                	je     f010601c <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105f9e:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105fa5:	00 00 
	wrv[1] = addr >> 4;
f0105fa7:	89 d8                	mov    %ebx,%eax
f0105fa9:	c1 e8 04             	shr    $0x4,%eax
f0105fac:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105fb2:	c1 e6 18             	shl    $0x18,%esi
f0105fb5:	89 f2                	mov    %esi,%edx
f0105fb7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fbc:	e8 37 fe ff ff       	call   f0105df8 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105fc1:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105fc6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fcb:	e8 28 fe ff ff       	call   f0105df8 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105fd0:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105fd5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fda:	e8 19 fe ff ff       	call   f0105df8 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105fdf:	c1 eb 0c             	shr    $0xc,%ebx
f0105fe2:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0105fe5:	89 f2                	mov    %esi,%edx
f0105fe7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fec:	e8 07 fe ff ff       	call   f0105df8 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ff1:	89 da                	mov    %ebx,%edx
f0105ff3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ff8:	e8 fb fd ff ff       	call   f0105df8 <lapicw>
		lapicw(ICRHI, apicid << 24);
f0105ffd:	89 f2                	mov    %esi,%edx
f0105fff:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106004:	e8 ef fd ff ff       	call   f0105df8 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106009:	89 da                	mov    %ebx,%edx
f010600b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106010:	e8 e3 fd ff ff       	call   f0105df8 <lapicw>
		microdelay(200);
	}
}
f0106015:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106018:	5b                   	pop    %ebx
f0106019:	5e                   	pop    %esi
f010601a:	5d                   	pop    %ebp
f010601b:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010601c:	68 67 04 00 00       	push   $0x467
f0106021:	68 64 64 10 f0       	push   $0xf0106464
f0106026:	68 99 00 00 00       	push   $0x99
f010602b:	68 98 80 10 f0       	push   $0xf0108098
f0106030:	e8 0b a0 ff ff       	call   f0100040 <_panic>

f0106035 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106035:	55                   	push   %ebp
f0106036:	89 e5                	mov    %esp,%ebp
f0106038:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010603b:	8b 55 08             	mov    0x8(%ebp),%edx
f010603e:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106044:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106049:	e8 aa fd ff ff       	call   f0105df8 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010604e:	8b 15 c0 93 25 f0    	mov    0xf02593c0,%edx
f0106054:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010605a:	f6 c4 10             	test   $0x10,%ah
f010605d:	75 f5                	jne    f0106054 <lapic_ipi+0x1f>
		;
}
f010605f:	c9                   	leave  
f0106060:	c3                   	ret    

f0106061 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106061:	55                   	push   %ebp
f0106062:	89 e5                	mov    %esp,%ebp
f0106064:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106067:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010606d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106070:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106073:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010607a:	5d                   	pop    %ebp
f010607b:	c3                   	ret    

f010607c <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010607c:	55                   	push   %ebp
f010607d:	89 e5                	mov    %esp,%ebp
f010607f:	56                   	push   %esi
f0106080:	53                   	push   %ebx
f0106081:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106084:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106087:	75 07                	jne    f0106090 <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f0106089:	ba 01 00 00 00       	mov    $0x1,%edx
f010608e:	eb 34                	jmp    f01060c4 <spin_lock+0x48>
f0106090:	8b 73 08             	mov    0x8(%ebx),%esi
f0106093:	e8 74 fd ff ff       	call   f0105e0c <cpunum>
f0106098:	6b c0 74             	imul   $0x74,%eax,%eax
f010609b:	05 20 90 25 f0       	add    $0xf0259020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01060a0:	39 c6                	cmp    %eax,%esi
f01060a2:	75 e5                	jne    f0106089 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01060a4:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01060a7:	e8 60 fd ff ff       	call   f0105e0c <cpunum>
f01060ac:	83 ec 0c             	sub    $0xc,%esp
f01060af:	53                   	push   %ebx
f01060b0:	50                   	push   %eax
f01060b1:	68 a8 80 10 f0       	push   $0xf01080a8
f01060b6:	6a 41                	push   $0x41
f01060b8:	68 0a 81 10 f0       	push   $0xf010810a
f01060bd:	e8 7e 9f ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01060c2:	f3 90                	pause  
f01060c4:	89 d0                	mov    %edx,%eax
f01060c6:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f01060c9:	85 c0                	test   %eax,%eax
f01060cb:	75 f5                	jne    f01060c2 <spin_lock+0x46>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01060cd:	e8 3a fd ff ff       	call   f0105e0c <cpunum>
f01060d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01060d5:	05 20 90 25 f0       	add    $0xf0259020,%eax
f01060da:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));//I guess it means moving ebp register value to local variable. 
f01060dd:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01060df:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01060e4:	83 f8 09             	cmp    $0x9,%eax
f01060e7:	7f 21                	jg     f010610a <spin_lock+0x8e>
f01060e9:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01060ef:	76 19                	jbe    f010610a <spin_lock+0x8e>
		pcs[i] = ebp[1];          // saved %eip
f01060f1:	8b 4a 04             	mov    0x4(%edx),%ecx
f01060f4:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01060f8:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f01060fa:	83 c0 01             	add    $0x1,%eax
f01060fd:	eb e5                	jmp    f01060e4 <spin_lock+0x68>
		pcs[i] = 0;
f01060ff:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f0106106:	00 
	for (; i < 10; i++)
f0106107:	83 c0 01             	add    $0x1,%eax
f010610a:	83 f8 09             	cmp    $0x9,%eax
f010610d:	7e f0                	jle    f01060ff <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f010610f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106112:	5b                   	pop    %ebx
f0106113:	5e                   	pop    %esi
f0106114:	5d                   	pop    %ebp
f0106115:	c3                   	ret    

f0106116 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106116:	55                   	push   %ebp
f0106117:	89 e5                	mov    %esp,%ebp
f0106119:	57                   	push   %edi
f010611a:	56                   	push   %esi
f010611b:	53                   	push   %ebx
f010611c:	83 ec 4c             	sub    $0x4c,%esp
f010611f:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106122:	83 3e 00             	cmpl   $0x0,(%esi)
f0106125:	75 35                	jne    f010615c <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106127:	83 ec 04             	sub    $0x4,%esp
f010612a:	6a 28                	push   $0x28
f010612c:	8d 46 0c             	lea    0xc(%esi),%eax
f010612f:	50                   	push   %eax
f0106130:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106133:	53                   	push   %ebx
f0106134:	e8 24 f7 ff ff       	call   f010585d <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106139:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010613c:	0f b6 38             	movzbl (%eax),%edi
f010613f:	8b 76 04             	mov    0x4(%esi),%esi
f0106142:	e8 c5 fc ff ff       	call   f0105e0c <cpunum>
f0106147:	57                   	push   %edi
f0106148:	56                   	push   %esi
f0106149:	50                   	push   %eax
f010614a:	68 d4 80 10 f0       	push   $0xf01080d4
f010614f:	e8 5e d8 ff ff       	call   f01039b2 <cprintf>
f0106154:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106157:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010615a:	eb 4e                	jmp    f01061aa <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f010615c:	8b 5e 08             	mov    0x8(%esi),%ebx
f010615f:	e8 a8 fc ff ff       	call   f0105e0c <cpunum>
f0106164:	6b c0 74             	imul   $0x74,%eax,%eax
f0106167:	05 20 90 25 f0       	add    $0xf0259020,%eax
	if (!holding(lk)) {
f010616c:	39 c3                	cmp    %eax,%ebx
f010616e:	75 b7                	jne    f0106127 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106170:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106177:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f010617e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106183:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106186:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106189:	5b                   	pop    %ebx
f010618a:	5e                   	pop    %esi
f010618b:	5f                   	pop    %edi
f010618c:	5d                   	pop    %ebp
f010618d:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f010618e:	83 ec 08             	sub    $0x8,%esp
f0106191:	ff 36                	push   (%esi)
f0106193:	68 31 81 10 f0       	push   $0xf0108131
f0106198:	e8 15 d8 ff ff       	call   f01039b2 <cprintf>
f010619d:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
f01061a0:	83 c3 04             	add    $0x4,%ebx
f01061a3:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01061a6:	39 c3                	cmp    %eax,%ebx
f01061a8:	74 40                	je     f01061ea <spin_unlock+0xd4>
f01061aa:	89 de                	mov    %ebx,%esi
f01061ac:	8b 03                	mov    (%ebx),%eax
f01061ae:	85 c0                	test   %eax,%eax
f01061b0:	74 38                	je     f01061ea <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01061b2:	83 ec 08             	sub    $0x8,%esp
f01061b5:	57                   	push   %edi
f01061b6:	50                   	push   %eax
f01061b7:	e8 96 eb ff ff       	call   f0104d52 <debuginfo_eip>
f01061bc:	83 c4 10             	add    $0x10,%esp
f01061bf:	85 c0                	test   %eax,%eax
f01061c1:	78 cb                	js     f010618e <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f01061c3:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01061c5:	83 ec 04             	sub    $0x4,%esp
f01061c8:	89 c2                	mov    %eax,%edx
f01061ca:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01061cd:	52                   	push   %edx
f01061ce:	ff 75 b0             	push   -0x50(%ebp)
f01061d1:	ff 75 b4             	push   -0x4c(%ebp)
f01061d4:	ff 75 ac             	push   -0x54(%ebp)
f01061d7:	ff 75 a8             	push   -0x58(%ebp)
f01061da:	50                   	push   %eax
f01061db:	68 1a 81 10 f0       	push   $0xf010811a
f01061e0:	e8 cd d7 ff ff       	call   f01039b2 <cprintf>
f01061e5:	83 c4 20             	add    $0x20,%esp
f01061e8:	eb b6                	jmp    f01061a0 <spin_unlock+0x8a>
		panic("spin_unlock");
f01061ea:	83 ec 04             	sub    $0x4,%esp
f01061ed:	68 39 81 10 f0       	push   $0xf0108139
f01061f2:	6a 67                	push   $0x67
f01061f4:	68 0a 81 10 f0       	push   $0xf010810a
f01061f9:	e8 42 9e ff ff       	call   f0100040 <_panic>
f01061fe:	66 90                	xchg   %ax,%ax

f0106200 <__udivdi3>:
f0106200:	f3 0f 1e fb          	endbr32 
f0106204:	55                   	push   %ebp
f0106205:	57                   	push   %edi
f0106206:	56                   	push   %esi
f0106207:	53                   	push   %ebx
f0106208:	83 ec 1c             	sub    $0x1c,%esp
f010620b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010620f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106213:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106217:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010621b:	85 c0                	test   %eax,%eax
f010621d:	75 19                	jne    f0106238 <__udivdi3+0x38>
f010621f:	39 f3                	cmp    %esi,%ebx
f0106221:	76 4d                	jbe    f0106270 <__udivdi3+0x70>
f0106223:	31 ff                	xor    %edi,%edi
f0106225:	89 e8                	mov    %ebp,%eax
f0106227:	89 f2                	mov    %esi,%edx
f0106229:	f7 f3                	div    %ebx
f010622b:	89 fa                	mov    %edi,%edx
f010622d:	83 c4 1c             	add    $0x1c,%esp
f0106230:	5b                   	pop    %ebx
f0106231:	5e                   	pop    %esi
f0106232:	5f                   	pop    %edi
f0106233:	5d                   	pop    %ebp
f0106234:	c3                   	ret    
f0106235:	8d 76 00             	lea    0x0(%esi),%esi
f0106238:	39 f0                	cmp    %esi,%eax
f010623a:	76 14                	jbe    f0106250 <__udivdi3+0x50>
f010623c:	31 ff                	xor    %edi,%edi
f010623e:	31 c0                	xor    %eax,%eax
f0106240:	89 fa                	mov    %edi,%edx
f0106242:	83 c4 1c             	add    $0x1c,%esp
f0106245:	5b                   	pop    %ebx
f0106246:	5e                   	pop    %esi
f0106247:	5f                   	pop    %edi
f0106248:	5d                   	pop    %ebp
f0106249:	c3                   	ret    
f010624a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106250:	0f bd f8             	bsr    %eax,%edi
f0106253:	83 f7 1f             	xor    $0x1f,%edi
f0106256:	75 48                	jne    f01062a0 <__udivdi3+0xa0>
f0106258:	39 f0                	cmp    %esi,%eax
f010625a:	72 06                	jb     f0106262 <__udivdi3+0x62>
f010625c:	31 c0                	xor    %eax,%eax
f010625e:	39 eb                	cmp    %ebp,%ebx
f0106260:	77 de                	ja     f0106240 <__udivdi3+0x40>
f0106262:	b8 01 00 00 00       	mov    $0x1,%eax
f0106267:	eb d7                	jmp    f0106240 <__udivdi3+0x40>
f0106269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106270:	89 d9                	mov    %ebx,%ecx
f0106272:	85 db                	test   %ebx,%ebx
f0106274:	75 0b                	jne    f0106281 <__udivdi3+0x81>
f0106276:	b8 01 00 00 00       	mov    $0x1,%eax
f010627b:	31 d2                	xor    %edx,%edx
f010627d:	f7 f3                	div    %ebx
f010627f:	89 c1                	mov    %eax,%ecx
f0106281:	31 d2                	xor    %edx,%edx
f0106283:	89 f0                	mov    %esi,%eax
f0106285:	f7 f1                	div    %ecx
f0106287:	89 c6                	mov    %eax,%esi
f0106289:	89 e8                	mov    %ebp,%eax
f010628b:	89 f7                	mov    %esi,%edi
f010628d:	f7 f1                	div    %ecx
f010628f:	89 fa                	mov    %edi,%edx
f0106291:	83 c4 1c             	add    $0x1c,%esp
f0106294:	5b                   	pop    %ebx
f0106295:	5e                   	pop    %esi
f0106296:	5f                   	pop    %edi
f0106297:	5d                   	pop    %ebp
f0106298:	c3                   	ret    
f0106299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01062a0:	89 f9                	mov    %edi,%ecx
f01062a2:	ba 20 00 00 00       	mov    $0x20,%edx
f01062a7:	29 fa                	sub    %edi,%edx
f01062a9:	d3 e0                	shl    %cl,%eax
f01062ab:	89 44 24 08          	mov    %eax,0x8(%esp)
f01062af:	89 d1                	mov    %edx,%ecx
f01062b1:	89 d8                	mov    %ebx,%eax
f01062b3:	d3 e8                	shr    %cl,%eax
f01062b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01062b9:	09 c1                	or     %eax,%ecx
f01062bb:	89 f0                	mov    %esi,%eax
f01062bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01062c1:	89 f9                	mov    %edi,%ecx
f01062c3:	d3 e3                	shl    %cl,%ebx
f01062c5:	89 d1                	mov    %edx,%ecx
f01062c7:	d3 e8                	shr    %cl,%eax
f01062c9:	89 f9                	mov    %edi,%ecx
f01062cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01062cf:	89 eb                	mov    %ebp,%ebx
f01062d1:	d3 e6                	shl    %cl,%esi
f01062d3:	89 d1                	mov    %edx,%ecx
f01062d5:	d3 eb                	shr    %cl,%ebx
f01062d7:	09 f3                	or     %esi,%ebx
f01062d9:	89 c6                	mov    %eax,%esi
f01062db:	89 f2                	mov    %esi,%edx
f01062dd:	89 d8                	mov    %ebx,%eax
f01062df:	f7 74 24 08          	divl   0x8(%esp)
f01062e3:	89 d6                	mov    %edx,%esi
f01062e5:	89 c3                	mov    %eax,%ebx
f01062e7:	f7 64 24 0c          	mull   0xc(%esp)
f01062eb:	39 d6                	cmp    %edx,%esi
f01062ed:	72 19                	jb     f0106308 <__udivdi3+0x108>
f01062ef:	89 f9                	mov    %edi,%ecx
f01062f1:	d3 e5                	shl    %cl,%ebp
f01062f3:	39 c5                	cmp    %eax,%ebp
f01062f5:	73 04                	jae    f01062fb <__udivdi3+0xfb>
f01062f7:	39 d6                	cmp    %edx,%esi
f01062f9:	74 0d                	je     f0106308 <__udivdi3+0x108>
f01062fb:	89 d8                	mov    %ebx,%eax
f01062fd:	31 ff                	xor    %edi,%edi
f01062ff:	e9 3c ff ff ff       	jmp    f0106240 <__udivdi3+0x40>
f0106304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106308:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010630b:	31 ff                	xor    %edi,%edi
f010630d:	e9 2e ff ff ff       	jmp    f0106240 <__udivdi3+0x40>
f0106312:	66 90                	xchg   %ax,%ax
f0106314:	66 90                	xchg   %ax,%ax
f0106316:	66 90                	xchg   %ax,%ax
f0106318:	66 90                	xchg   %ax,%ax
f010631a:	66 90                	xchg   %ax,%ax
f010631c:	66 90                	xchg   %ax,%ax
f010631e:	66 90                	xchg   %ax,%ax

f0106320 <__umoddi3>:
f0106320:	f3 0f 1e fb          	endbr32 
f0106324:	55                   	push   %ebp
f0106325:	57                   	push   %edi
f0106326:	56                   	push   %esi
f0106327:	53                   	push   %ebx
f0106328:	83 ec 1c             	sub    $0x1c,%esp
f010632b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010632f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106333:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0106337:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f010633b:	89 f0                	mov    %esi,%eax
f010633d:	89 da                	mov    %ebx,%edx
f010633f:	85 ff                	test   %edi,%edi
f0106341:	75 15                	jne    f0106358 <__umoddi3+0x38>
f0106343:	39 dd                	cmp    %ebx,%ebp
f0106345:	76 39                	jbe    f0106380 <__umoddi3+0x60>
f0106347:	f7 f5                	div    %ebp
f0106349:	89 d0                	mov    %edx,%eax
f010634b:	31 d2                	xor    %edx,%edx
f010634d:	83 c4 1c             	add    $0x1c,%esp
f0106350:	5b                   	pop    %ebx
f0106351:	5e                   	pop    %esi
f0106352:	5f                   	pop    %edi
f0106353:	5d                   	pop    %ebp
f0106354:	c3                   	ret    
f0106355:	8d 76 00             	lea    0x0(%esi),%esi
f0106358:	39 df                	cmp    %ebx,%edi
f010635a:	77 f1                	ja     f010634d <__umoddi3+0x2d>
f010635c:	0f bd cf             	bsr    %edi,%ecx
f010635f:	83 f1 1f             	xor    $0x1f,%ecx
f0106362:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106366:	75 40                	jne    f01063a8 <__umoddi3+0x88>
f0106368:	39 df                	cmp    %ebx,%edi
f010636a:	72 04                	jb     f0106370 <__umoddi3+0x50>
f010636c:	39 f5                	cmp    %esi,%ebp
f010636e:	77 dd                	ja     f010634d <__umoddi3+0x2d>
f0106370:	89 da                	mov    %ebx,%edx
f0106372:	89 f0                	mov    %esi,%eax
f0106374:	29 e8                	sub    %ebp,%eax
f0106376:	19 fa                	sbb    %edi,%edx
f0106378:	eb d3                	jmp    f010634d <__umoddi3+0x2d>
f010637a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106380:	89 e9                	mov    %ebp,%ecx
f0106382:	85 ed                	test   %ebp,%ebp
f0106384:	75 0b                	jne    f0106391 <__umoddi3+0x71>
f0106386:	b8 01 00 00 00       	mov    $0x1,%eax
f010638b:	31 d2                	xor    %edx,%edx
f010638d:	f7 f5                	div    %ebp
f010638f:	89 c1                	mov    %eax,%ecx
f0106391:	89 d8                	mov    %ebx,%eax
f0106393:	31 d2                	xor    %edx,%edx
f0106395:	f7 f1                	div    %ecx
f0106397:	89 f0                	mov    %esi,%eax
f0106399:	f7 f1                	div    %ecx
f010639b:	89 d0                	mov    %edx,%eax
f010639d:	31 d2                	xor    %edx,%edx
f010639f:	eb ac                	jmp    f010634d <__umoddi3+0x2d>
f01063a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01063a8:	8b 44 24 04          	mov    0x4(%esp),%eax
f01063ac:	ba 20 00 00 00       	mov    $0x20,%edx
f01063b1:	29 c2                	sub    %eax,%edx
f01063b3:	89 c1                	mov    %eax,%ecx
f01063b5:	89 e8                	mov    %ebp,%eax
f01063b7:	d3 e7                	shl    %cl,%edi
f01063b9:	89 d1                	mov    %edx,%ecx
f01063bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01063bf:	d3 e8                	shr    %cl,%eax
f01063c1:	89 c1                	mov    %eax,%ecx
f01063c3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01063c7:	09 f9                	or     %edi,%ecx
f01063c9:	89 df                	mov    %ebx,%edi
f01063cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01063cf:	89 c1                	mov    %eax,%ecx
f01063d1:	d3 e5                	shl    %cl,%ebp
f01063d3:	89 d1                	mov    %edx,%ecx
f01063d5:	d3 ef                	shr    %cl,%edi
f01063d7:	89 c1                	mov    %eax,%ecx
f01063d9:	89 f0                	mov    %esi,%eax
f01063db:	d3 e3                	shl    %cl,%ebx
f01063dd:	89 d1                	mov    %edx,%ecx
f01063df:	89 fa                	mov    %edi,%edx
f01063e1:	d3 e8                	shr    %cl,%eax
f01063e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01063e8:	09 d8                	or     %ebx,%eax
f01063ea:	f7 74 24 08          	divl   0x8(%esp)
f01063ee:	89 d3                	mov    %edx,%ebx
f01063f0:	d3 e6                	shl    %cl,%esi
f01063f2:	f7 e5                	mul    %ebp
f01063f4:	89 c7                	mov    %eax,%edi
f01063f6:	89 d1                	mov    %edx,%ecx
f01063f8:	39 d3                	cmp    %edx,%ebx
f01063fa:	72 06                	jb     f0106402 <__umoddi3+0xe2>
f01063fc:	75 0e                	jne    f010640c <__umoddi3+0xec>
f01063fe:	39 c6                	cmp    %eax,%esi
f0106400:	73 0a                	jae    f010640c <__umoddi3+0xec>
f0106402:	29 e8                	sub    %ebp,%eax
f0106404:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106408:	89 d1                	mov    %edx,%ecx
f010640a:	89 c7                	mov    %eax,%edi
f010640c:	89 f5                	mov    %esi,%ebp
f010640e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106412:	29 fd                	sub    %edi,%ebp
f0106414:	19 cb                	sbb    %ecx,%ebx
f0106416:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f010641b:	89 d8                	mov    %ebx,%eax
f010641d:	d3 e0                	shl    %cl,%eax
f010641f:	89 f1                	mov    %esi,%ecx
f0106421:	d3 ed                	shr    %cl,%ebp
f0106423:	d3 eb                	shr    %cl,%ebx
f0106425:	09 e8                	or     %ebp,%eax
f0106427:	89 da                	mov    %ebx,%edx
f0106429:	83 c4 1c             	add    $0x1c,%esp
f010642c:	5b                   	pop    %ebx
f010642d:	5e                   	pop    %esi
f010642e:	5f                   	pop    %edi
f010642f:	5d                   	pop    %ebp
f0106430:	c3                   	ret    
