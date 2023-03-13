
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
f0100047:	83 3d 00 70 21 f0 00 	cmpl   $0x0,0xf0217000
f010004e:	74 0f                	je     f010005f <_panic+0x1f>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100050:	83 ec 0c             	sub    $0xc,%esp
f0100053:	6a 00                	push   $0x0
f0100055:	e8 17 09 00 00       	call   f0100971 <monitor>
f010005a:	83 c4 10             	add    $0x10,%esp
f010005d:	eb f1                	jmp    f0100050 <_panic+0x10>
	panicstr = fmt;
f010005f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100062:	a3 00 70 21 f0       	mov    %eax,0xf0217000
	asm volatile("cli; cld");
f0100067:	fa                   	cli    
f0100068:	fc                   	cld    
	va_start(ap, fmt);
f0100069:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006c:	e8 6b 5d 00 00       	call   f0105ddc <cpunum>
f0100071:	ff 75 0c             	push   0xc(%ebp)
f0100074:	ff 75 08             	push   0x8(%ebp)
f0100077:	50                   	push   %eax
f0100078:	68 20 64 10 f0       	push   $0xf0106420
f010007d:	e8 08 39 00 00       	call   f010398a <cprintf>
	vcprintf(fmt, ap);
f0100082:	83 c4 08             	add    $0x8,%esp
f0100085:	53                   	push   %ebx
f0100086:	ff 75 10             	push   0x10(%ebp)
f0100089:	e8 d6 38 00 00       	call   f0103964 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 93 6c 10 f0 	movl   $0xf0106c93,(%esp)
f0100095:	e8 f0 38 00 00       	call   f010398a <cprintf>
f010009a:	83 c4 10             	add    $0x10,%esp
f010009d:	eb b1                	jmp    f0100050 <_panic+0x10>

f010009f <i386_init>:
{
f010009f:	55                   	push   %ebp
f01000a0:	89 e5                	mov    %esp,%ebp
f01000a2:	53                   	push   %ebx
f01000a3:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000a6:	e8 92 05 00 00       	call   f010063d <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ab:	83 ec 08             	sub    $0x8,%esp
f01000ae:	68 ac 1a 00 00       	push   $0x1aac
f01000b3:	68 8c 64 10 f0       	push   $0xf010648c
f01000b8:	e8 cd 38 00 00       	call   f010398a <cprintf>
	mem_init();
f01000bd:	e8 5e 12 00 00       	call   f0101320 <mem_init>
	env_init();
f01000c2:	e8 8f 30 00 00       	call   f0103156 <env_init>
	trap_init();
f01000c7:	e8 b0 39 00 00       	call   f0103a7c <trap_init>
	mp_init();
f01000cc:	e8 25 5a 00 00       	call   f0105af6 <mp_init>
	lapic_init();
f01000d1:	e8 1c 5d 00 00       	call   f0105df2 <lapic_init>
	pic_init();
f01000d6:	e8 d0 37 00 00       	call   f01038ab <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000db:	c7 04 24 c0 53 12 f0 	movl   $0xf01253c0,(%esp)
f01000e2:	e8 65 5f 00 00       	call   f010604c <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e7:	83 c4 10             	add    $0x10,%esp
f01000ea:	83 3d 60 72 21 f0 07 	cmpl   $0x7,0xf0217260
f01000f1:	76 27                	jbe    f010011a <i386_init+0x7b>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f3:	83 ec 04             	sub    $0x4,%esp
f01000f6:	b8 52 5a 10 f0       	mov    $0xf0105a52,%eax
f01000fb:	2d d8 59 10 f0       	sub    $0xf01059d8,%eax
f0100100:	50                   	push   %eax
f0100101:	68 d8 59 10 f0       	push   $0xf01059d8
f0100106:	68 00 70 00 f0       	push   $0xf0007000
f010010b:	e8 1c 57 00 00       	call   f010582c <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100110:	83 c4 10             	add    $0x10,%esp
f0100113:	bb 20 80 25 f0       	mov    $0xf0258020,%ebx
f0100118:	eb 19                	jmp    f0100133 <i386_init+0x94>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011a:	68 00 70 00 00       	push   $0x7000
f010011f:	68 44 64 10 f0       	push   $0xf0106444
f0100124:	6a 56                	push   $0x56
f0100126:	68 a7 64 10 f0       	push   $0xf01064a7
f010012b:	e8 10 ff ff ff       	call   f0100040 <_panic>
f0100130:	83 c3 74             	add    $0x74,%ebx
f0100133:	6b 05 00 80 25 f0 74 	imul   $0x74,0xf0258000,%eax
f010013a:	05 20 80 25 f0       	add    $0xf0258020,%eax
f010013f:	39 c3                	cmp    %eax,%ebx
f0100141:	73 4d                	jae    f0100190 <i386_init+0xf1>
		if (c == cpus + cpunum())  // We've started already.
f0100143:	e8 94 5c 00 00       	call   f0105ddc <cpunum>
f0100148:	6b c0 74             	imul   $0x74,%eax,%eax
f010014b:	05 20 80 25 f0       	add    $0xf0258020,%eax
f0100150:	39 c3                	cmp    %eax,%ebx
f0100152:	74 dc                	je     f0100130 <i386_init+0x91>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100154:	89 d8                	mov    %ebx,%eax
f0100156:	2d 20 80 25 f0       	sub    $0xf0258020,%eax
f010015b:	c1 f8 02             	sar    $0x2,%eax
f010015e:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100164:	c1 e0 0f             	shl    $0xf,%eax
f0100167:	8d 80 00 00 22 f0    	lea    -0xfde0000(%eax),%eax
f010016d:	a3 04 70 21 f0       	mov    %eax,0xf0217004
		lapic_startap(c->cpu_id, PADDR(code));
f0100172:	83 ec 08             	sub    $0x8,%esp
f0100175:	68 00 70 00 00       	push   $0x7000
f010017a:	0f b6 03             	movzbl (%ebx),%eax
f010017d:	50                   	push   %eax
f010017e:	e8 c1 5d 00 00       	call   f0105f44 <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f0100183:	83 c4 10             	add    $0x10,%esp
f0100186:	8b 43 04             	mov    0x4(%ebx),%eax
f0100189:	83 f8 01             	cmp    $0x1,%eax
f010018c:	75 f8                	jne    f0100186 <i386_init+0xe7>
f010018e:	eb a0                	jmp    f0100130 <i386_init+0x91>
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100190:	83 ec 08             	sub    $0x8,%esp
f0100193:	6a 01                	push   $0x1
f0100195:	68 98 49 1d f0       	push   $0xf01d4998
f010019a:	e8 82 31 00 00       	call   f0103321 <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010019f:	83 c4 08             	add    $0x8,%esp
f01001a2:	6a 00                	push   $0x0
f01001a4:	68 b4 66 20 f0       	push   $0xf02066b4
f01001a9:	e8 73 31 00 00       	call   f0103321 <env_create>
	kbd_intr();
f01001ae:	e8 36 04 00 00       	call   f01005e9 <kbd_intr>
	sched_yield();
f01001b3:	e8 fb 43 00 00       	call   f01045b3 <sched_yield>

f01001b8 <mp_main>:
{
f01001b8:	55                   	push   %ebp
f01001b9:	89 e5                	mov    %esp,%ebp
f01001bb:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001be:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001c3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c8:	76 52                	jbe    f010021c <mp_main+0x64>
	return (physaddr_t)kva - KERNBASE;
f01001ca:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f01001cf:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001d2:	e8 05 5c 00 00       	call   f0105ddc <cpunum>
f01001d7:	83 ec 08             	sub    $0x8,%esp
f01001da:	50                   	push   %eax
f01001db:	68 b3 64 10 f0       	push   $0xf01064b3
f01001e0:	e8 a5 37 00 00       	call   f010398a <cprintf>
	lapic_init();
f01001e5:	e8 08 5c 00 00       	call   f0105df2 <lapic_init>
	env_init_percpu();
f01001ea:	e8 3b 2f 00 00       	call   f010312a <env_init_percpu>
	trap_init_percpu();
f01001ef:	e8 aa 37 00 00       	call   f010399e <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001f4:	e8 e3 5b 00 00       	call   f0105ddc <cpunum>
f01001f9:	6b d0 74             	imul   $0x74,%eax,%edx
f01001fc:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001ff:	b8 01 00 00 00       	mov    $0x1,%eax
f0100204:	f0 87 82 20 80 25 f0 	lock xchg %eax,-0xfda7fe0(%edx)
f010020b:	c7 04 24 c0 53 12 f0 	movl   $0xf01253c0,(%esp)
f0100212:	e8 35 5e 00 00       	call   f010604c <spin_lock>
	sched_yield();
f0100217:	e8 97 43 00 00       	call   f01045b3 <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010021c:	50                   	push   %eax
f010021d:	68 68 64 10 f0       	push   $0xf0106468
f0100222:	6a 6d                	push   $0x6d
f0100224:	68 a7 64 10 f0       	push   $0xf01064a7
f0100229:	e8 12 fe ff ff       	call   f0100040 <_panic>

f010022e <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010022e:	55                   	push   %ebp
f010022f:	89 e5                	mov    %esp,%ebp
f0100231:	53                   	push   %ebx
f0100232:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100235:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100238:	ff 75 0c             	push   0xc(%ebp)
f010023b:	ff 75 08             	push   0x8(%ebp)
f010023e:	68 c9 64 10 f0       	push   $0xf01064c9
f0100243:	e8 42 37 00 00       	call   f010398a <cprintf>
	vcprintf(fmt, ap);
f0100248:	83 c4 08             	add    $0x8,%esp
f010024b:	53                   	push   %ebx
f010024c:	ff 75 10             	push   0x10(%ebp)
f010024f:	e8 10 37 00 00       	call   f0103964 <vcprintf>
	cprintf("\n");
f0100254:	c7 04 24 93 6c 10 f0 	movl   $0xf0106c93,(%esp)
f010025b:	e8 2a 37 00 00       	call   f010398a <cprintf>
	va_end(ap);
}
f0100260:	83 c4 10             	add    $0x10,%esp
f0100263:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100266:	c9                   	leave  
f0100267:	c3                   	ret    

f0100268 <serial_proc_data>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100268:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026d:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026e:	a8 01                	test   $0x1,%al
f0100270:	74 0a                	je     f010027c <serial_proc_data+0x14>
f0100272:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100277:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100278:	0f b6 c0             	movzbl %al,%eax
f010027b:	c3                   	ret    
		return -1;
f010027c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100281:	c3                   	ret    

f0100282 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100282:	55                   	push   %ebp
f0100283:	89 e5                	mov    %esp,%ebp
f0100285:	53                   	push   %ebx
f0100286:	83 ec 04             	sub    $0x4,%esp
f0100289:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010028b:	eb 23                	jmp    f01002b0 <cons_intr+0x2e>
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f010028d:	8b 0d 44 72 21 f0    	mov    0xf0217244,%ecx
f0100293:	8d 51 01             	lea    0x1(%ecx),%edx
f0100296:	88 81 40 70 21 f0    	mov    %al,-0xfde8fc0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010029c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01002a7:	0f 44 d0             	cmove  %eax,%edx
f01002aa:	89 15 44 72 21 f0    	mov    %edx,0xf0217244
	while ((c = (*proc)()) != -1) {
f01002b0:	ff d3                	call   *%ebx
f01002b2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002b5:	74 06                	je     f01002bd <cons_intr+0x3b>
		if (c == 0)
f01002b7:	85 c0                	test   %eax,%eax
f01002b9:	75 d2                	jne    f010028d <cons_intr+0xb>
f01002bb:	eb f3                	jmp    f01002b0 <cons_intr+0x2e>
	}
}
f01002bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002c0:	c9                   	leave  
f01002c1:	c3                   	ret    

f01002c2 <kbd_proc_data>:
{
f01002c2:	55                   	push   %ebp
f01002c3:	89 e5                	mov    %esp,%ebp
f01002c5:	53                   	push   %ebx
f01002c6:	83 ec 04             	sub    $0x4,%esp
f01002c9:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ce:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002cf:	a8 01                	test   $0x1,%al
f01002d1:	0f 84 ee 00 00 00    	je     f01003c5 <kbd_proc_data+0x103>
	if (stat & KBS_TERR)
f01002d7:	a8 20                	test   $0x20,%al
f01002d9:	0f 85 ed 00 00 00    	jne    f01003cc <kbd_proc_data+0x10a>
f01002df:	ba 60 00 00 00       	mov    $0x60,%edx
f01002e4:	ec                   	in     (%dx),%al
f01002e5:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002e7:	3c e0                	cmp    $0xe0,%al
f01002e9:	74 61                	je     f010034c <kbd_proc_data+0x8a>
	} else if (data & 0x80) {
f01002eb:	84 c0                	test   %al,%al
f01002ed:	78 70                	js     f010035f <kbd_proc_data+0x9d>
	} else if (shift & E0ESC) {
f01002ef:	8b 0d 20 70 21 f0    	mov    0xf0217020,%ecx
f01002f5:	f6 c1 40             	test   $0x40,%cl
f01002f8:	74 0e                	je     f0100308 <kbd_proc_data+0x46>
		data |= 0x80;
f01002fa:	83 c8 80             	or     $0xffffff80,%eax
f01002fd:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002ff:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100302:	89 0d 20 70 21 f0    	mov    %ecx,0xf0217020
	shift |= shiftcode[data];
f0100308:	0f b6 d2             	movzbl %dl,%edx
f010030b:	0f b6 82 40 66 10 f0 	movzbl -0xfef99c0(%edx),%eax
f0100312:	0b 05 20 70 21 f0    	or     0xf0217020,%eax
	shift ^= togglecode[data];
f0100318:	0f b6 8a 40 65 10 f0 	movzbl -0xfef9ac0(%edx),%ecx
f010031f:	31 c8                	xor    %ecx,%eax
f0100321:	a3 20 70 21 f0       	mov    %eax,0xf0217020
	c = charcode[shift & (CTL | SHIFT)][data];
f0100326:	89 c1                	mov    %eax,%ecx
f0100328:	83 e1 03             	and    $0x3,%ecx
f010032b:	8b 0c 8d 20 65 10 f0 	mov    -0xfef9ae0(,%ecx,4),%ecx
f0100332:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100336:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100339:	a8 08                	test   $0x8,%al
f010033b:	74 5d                	je     f010039a <kbd_proc_data+0xd8>
		if ('a' <= c && c <= 'z')
f010033d:	89 da                	mov    %ebx,%edx
f010033f:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100342:	83 f9 19             	cmp    $0x19,%ecx
f0100345:	77 47                	ja     f010038e <kbd_proc_data+0xcc>
			c += 'A' - 'a';
f0100347:	83 eb 20             	sub    $0x20,%ebx
f010034a:	eb 0c                	jmp    f0100358 <kbd_proc_data+0x96>
		shift |= E0ESC;
f010034c:	83 0d 20 70 21 f0 40 	orl    $0x40,0xf0217020
		return 0;
f0100353:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100358:	89 d8                	mov    %ebx,%eax
f010035a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010035d:	c9                   	leave  
f010035e:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010035f:	8b 0d 20 70 21 f0    	mov    0xf0217020,%ecx
f0100365:	83 e0 7f             	and    $0x7f,%eax
f0100368:	f6 c1 40             	test   $0x40,%cl
f010036b:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010036e:	0f b6 d2             	movzbl %dl,%edx
f0100371:	0f b6 82 40 66 10 f0 	movzbl -0xfef99c0(%edx),%eax
f0100378:	83 c8 40             	or     $0x40,%eax
f010037b:	0f b6 c0             	movzbl %al,%eax
f010037e:	f7 d0                	not    %eax
f0100380:	21 c8                	and    %ecx,%eax
f0100382:	a3 20 70 21 f0       	mov    %eax,0xf0217020
		return 0;
f0100387:	bb 00 00 00 00       	mov    $0x0,%ebx
f010038c:	eb ca                	jmp    f0100358 <kbd_proc_data+0x96>
		else if ('A' <= c && c <= 'Z')
f010038e:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100391:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100394:	83 fa 1a             	cmp    $0x1a,%edx
f0100397:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010039a:	f7 d0                	not    %eax
f010039c:	a8 06                	test   $0x6,%al
f010039e:	75 b8                	jne    f0100358 <kbd_proc_data+0x96>
f01003a0:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003a6:	75 b0                	jne    f0100358 <kbd_proc_data+0x96>
		cprintf("Rebooting!\n");
f01003a8:	83 ec 0c             	sub    $0xc,%esp
f01003ab:	68 e3 64 10 f0       	push   $0xf01064e3
f01003b0:	e8 d5 35 00 00       	call   f010398a <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b5:	b8 03 00 00 00       	mov    $0x3,%eax
f01003ba:	ba 92 00 00 00       	mov    $0x92,%edx
f01003bf:	ee                   	out    %al,(%dx)
}
f01003c0:	83 c4 10             	add    $0x10,%esp
f01003c3:	eb 93                	jmp    f0100358 <kbd_proc_data+0x96>
		return -1;
f01003c5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003ca:	eb 8c                	jmp    f0100358 <kbd_proc_data+0x96>
		return -1;
f01003cc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003d1:	eb 85                	jmp    f0100358 <kbd_proc_data+0x96>

f01003d3 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003d3:	55                   	push   %ebp
f01003d4:	89 e5                	mov    %esp,%ebp
f01003d6:	57                   	push   %edi
f01003d7:	56                   	push   %esi
f01003d8:	53                   	push   %ebx
f01003d9:	83 ec 1c             	sub    $0x1c,%esp
f01003dc:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003de:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003e3:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003e8:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003ed:	89 f2                	mov    %esi,%edx
f01003ef:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003f0:	a8 20                	test   $0x20,%al
f01003f2:	75 13                	jne    f0100407 <cons_putc+0x34>
f01003f4:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003fa:	7f 0b                	jg     f0100407 <cons_putc+0x34>
f01003fc:	89 ca                	mov    %ecx,%edx
f01003fe:	ec                   	in     (%dx),%al
f01003ff:	ec                   	in     (%dx),%al
f0100400:	ec                   	in     (%dx),%al
f0100401:	ec                   	in     (%dx),%al
	     i++)
f0100402:	83 c3 01             	add    $0x1,%ebx
f0100405:	eb e6                	jmp    f01003ed <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f0100407:	89 f8                	mov    %edi,%eax
f0100409:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010040c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100411:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100412:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100417:	be 79 03 00 00       	mov    $0x379,%esi
f010041c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100421:	89 f2                	mov    %esi,%edx
f0100423:	ec                   	in     (%dx),%al
f0100424:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010042a:	7f 0f                	jg     f010043b <cons_putc+0x68>
f010042c:	84 c0                	test   %al,%al
f010042e:	78 0b                	js     f010043b <cons_putc+0x68>
f0100430:	89 ca                	mov    %ecx,%edx
f0100432:	ec                   	in     (%dx),%al
f0100433:	ec                   	in     (%dx),%al
f0100434:	ec                   	in     (%dx),%al
f0100435:	ec                   	in     (%dx),%al
f0100436:	83 c3 01             	add    $0x1,%ebx
f0100439:	eb e6                	jmp    f0100421 <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010043b:	ba 78 03 00 00       	mov    $0x378,%edx
f0100440:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100444:	ee                   	out    %al,(%dx)
f0100445:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010044a:	b8 0d 00 00 00       	mov    $0xd,%eax
f010044f:	ee                   	out    %al,(%dx)
f0100450:	b8 08 00 00 00       	mov    $0x8,%eax
f0100455:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100456:	89 f8                	mov    %edi,%eax
f0100458:	80 cc 07             	or     $0x7,%ah
f010045b:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100461:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100464:	89 f8                	mov    %edi,%eax
f0100466:	0f b6 c0             	movzbl %al,%eax
f0100469:	89 fb                	mov    %edi,%ebx
f010046b:	80 fb 0a             	cmp    $0xa,%bl
f010046e:	0f 84 e1 00 00 00    	je     f0100555 <cons_putc+0x182>
f0100474:	83 f8 0a             	cmp    $0xa,%eax
f0100477:	7f 46                	jg     f01004bf <cons_putc+0xec>
f0100479:	83 f8 08             	cmp    $0x8,%eax
f010047c:	0f 84 a7 00 00 00    	je     f0100529 <cons_putc+0x156>
f0100482:	83 f8 09             	cmp    $0x9,%eax
f0100485:	0f 85 d7 00 00 00    	jne    f0100562 <cons_putc+0x18f>
		cons_putc(' ');
f010048b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100490:	e8 3e ff ff ff       	call   f01003d3 <cons_putc>
		cons_putc(' ');
f0100495:	b8 20 00 00 00       	mov    $0x20,%eax
f010049a:	e8 34 ff ff ff       	call   f01003d3 <cons_putc>
		cons_putc(' ');
f010049f:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a4:	e8 2a ff ff ff       	call   f01003d3 <cons_putc>
		cons_putc(' ');
f01004a9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ae:	e8 20 ff ff ff       	call   f01003d3 <cons_putc>
		cons_putc(' ');
f01004b3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b8:	e8 16 ff ff ff       	call   f01003d3 <cons_putc>
		break;
f01004bd:	eb 25                	jmp    f01004e4 <cons_putc+0x111>
	switch (c & 0xff) {
f01004bf:	83 f8 0d             	cmp    $0xd,%eax
f01004c2:	0f 85 9a 00 00 00    	jne    f0100562 <cons_putc+0x18f>
		crt_pos -= (crt_pos % CRT_COLS);
f01004c8:	0f b7 05 48 72 21 f0 	movzwl 0xf0217248,%eax
f01004cf:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004d5:	c1 e8 16             	shr    $0x16,%eax
f01004d8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004db:	c1 e0 04             	shl    $0x4,%eax
f01004de:	66 a3 48 72 21 f0    	mov    %ax,0xf0217248
	if (crt_pos >= CRT_SIZE) {
f01004e4:	66 81 3d 48 72 21 f0 	cmpw   $0x7cf,0xf0217248
f01004eb:	cf 07 
f01004ed:	0f 87 92 00 00 00    	ja     f0100585 <cons_putc+0x1b2>
	outb(addr_6845, 14);
f01004f3:	8b 0d 50 72 21 f0    	mov    0xf0217250,%ecx
f01004f9:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004fe:	89 ca                	mov    %ecx,%edx
f0100500:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100501:	0f b7 1d 48 72 21 f0 	movzwl 0xf0217248,%ebx
f0100508:	8d 71 01             	lea    0x1(%ecx),%esi
f010050b:	89 d8                	mov    %ebx,%eax
f010050d:	66 c1 e8 08          	shr    $0x8,%ax
f0100511:	89 f2                	mov    %esi,%edx
f0100513:	ee                   	out    %al,(%dx)
f0100514:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100519:	89 ca                	mov    %ecx,%edx
f010051b:	ee                   	out    %al,(%dx)
f010051c:	89 d8                	mov    %ebx,%eax
f010051e:	89 f2                	mov    %esi,%edx
f0100520:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100521:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100524:	5b                   	pop    %ebx
f0100525:	5e                   	pop    %esi
f0100526:	5f                   	pop    %edi
f0100527:	5d                   	pop    %ebp
f0100528:	c3                   	ret    
		if (crt_pos > 0) {
f0100529:	0f b7 05 48 72 21 f0 	movzwl 0xf0217248,%eax
f0100530:	66 85 c0             	test   %ax,%ax
f0100533:	74 be                	je     f01004f3 <cons_putc+0x120>
			crt_pos--;
f0100535:	83 e8 01             	sub    $0x1,%eax
f0100538:	66 a3 48 72 21 f0    	mov    %ax,0xf0217248
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010053e:	0f b7 c0             	movzwl %ax,%eax
f0100541:	66 81 e7 00 ff       	and    $0xff00,%di
f0100546:	83 cf 20             	or     $0x20,%edi
f0100549:	8b 15 4c 72 21 f0    	mov    0xf021724c,%edx
f010054f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100553:	eb 8f                	jmp    f01004e4 <cons_putc+0x111>
		crt_pos += CRT_COLS;
f0100555:	66 83 05 48 72 21 f0 	addw   $0x50,0xf0217248
f010055c:	50 
f010055d:	e9 66 ff ff ff       	jmp    f01004c8 <cons_putc+0xf5>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100562:	0f b7 05 48 72 21 f0 	movzwl 0xf0217248,%eax
f0100569:	8d 50 01             	lea    0x1(%eax),%edx
f010056c:	66 89 15 48 72 21 f0 	mov    %dx,0xf0217248
f0100573:	0f b7 c0             	movzwl %ax,%eax
f0100576:	8b 15 4c 72 21 f0    	mov    0xf021724c,%edx
f010057c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100580:	e9 5f ff ff ff       	jmp    f01004e4 <cons_putc+0x111>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100585:	a1 4c 72 21 f0       	mov    0xf021724c,%eax
f010058a:	83 ec 04             	sub    $0x4,%esp
f010058d:	68 00 0f 00 00       	push   $0xf00
f0100592:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100598:	52                   	push   %edx
f0100599:	50                   	push   %eax
f010059a:	e8 8d 52 00 00       	call   f010582c <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010059f:	8b 15 4c 72 21 f0    	mov    0xf021724c,%edx
f01005a5:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005ab:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005b1:	83 c4 10             	add    $0x10,%esp
f01005b4:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005b9:	83 c0 02             	add    $0x2,%eax
f01005bc:	39 d0                	cmp    %edx,%eax
f01005be:	75 f4                	jne    f01005b4 <cons_putc+0x1e1>
		crt_pos -= CRT_COLS;
f01005c0:	66 83 2d 48 72 21 f0 	subw   $0x50,0xf0217248
f01005c7:	50 
f01005c8:	e9 26 ff ff ff       	jmp    f01004f3 <cons_putc+0x120>

f01005cd <serial_intr>:
	if (serial_exists)
f01005cd:	80 3d 54 72 21 f0 00 	cmpb   $0x0,0xf0217254
f01005d4:	75 01                	jne    f01005d7 <serial_intr+0xa>
f01005d6:	c3                   	ret    
{
f01005d7:	55                   	push   %ebp
f01005d8:	89 e5                	mov    %esp,%ebp
f01005da:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005dd:	b8 68 02 10 f0       	mov    $0xf0100268,%eax
f01005e2:	e8 9b fc ff ff       	call   f0100282 <cons_intr>
}
f01005e7:	c9                   	leave  
f01005e8:	c3                   	ret    

f01005e9 <kbd_intr>:
{
f01005e9:	55                   	push   %ebp
f01005ea:	89 e5                	mov    %esp,%ebp
f01005ec:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005ef:	b8 c2 02 10 f0       	mov    $0xf01002c2,%eax
f01005f4:	e8 89 fc ff ff       	call   f0100282 <cons_intr>
}
f01005f9:	c9                   	leave  
f01005fa:	c3                   	ret    

f01005fb <cons_getc>:
{
f01005fb:	55                   	push   %ebp
f01005fc:	89 e5                	mov    %esp,%ebp
f01005fe:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100601:	e8 c7 ff ff ff       	call   f01005cd <serial_intr>
	kbd_intr();
f0100606:	e8 de ff ff ff       	call   f01005e9 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010060b:	a1 40 72 21 f0       	mov    0xf0217240,%eax
	return 0;
f0100610:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100615:	3b 05 44 72 21 f0    	cmp    0xf0217244,%eax
f010061b:	74 1c                	je     f0100639 <cons_getc+0x3e>
		c = cons.buf[cons.rpos++];
f010061d:	8d 48 01             	lea    0x1(%eax),%ecx
f0100620:	0f b6 90 40 70 21 f0 	movzbl -0xfde8fc0(%eax),%edx
			cons.rpos = 0;
f0100627:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f010062c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100631:	0f 45 c1             	cmovne %ecx,%eax
f0100634:	a3 40 72 21 f0       	mov    %eax,0xf0217240
}
f0100639:	89 d0                	mov    %edx,%eax
f010063b:	c9                   	leave  
f010063c:	c3                   	ret    

f010063d <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010063d:	55                   	push   %ebp
f010063e:	89 e5                	mov    %esp,%ebp
f0100640:	57                   	push   %edi
f0100641:	56                   	push   %esi
f0100642:	53                   	push   %ebx
f0100643:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100646:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010064d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100654:	5a a5 
	if (*cp != 0xA55A) {
f0100656:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010065d:	bb b4 03 00 00       	mov    $0x3b4,%ebx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100662:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	if (*cp != 0xA55A) {
f0100667:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010066b:	0f 84 cd 00 00 00    	je     f010073e <cons_init+0x101>
		addr_6845 = MONO_BASE;
f0100671:	89 1d 50 72 21 f0    	mov    %ebx,0xf0217250
f0100677:	b8 0e 00 00 00       	mov    $0xe,%eax
f010067c:	89 da                	mov    %ebx,%edx
f010067e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010067f:	8d 7b 01             	lea    0x1(%ebx),%edi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100682:	89 fa                	mov    %edi,%edx
f0100684:	ec                   	in     (%dx),%al
f0100685:	0f b6 c8             	movzbl %al,%ecx
f0100688:	c1 e1 08             	shl    $0x8,%ecx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100690:	89 da                	mov    %ebx,%edx
f0100692:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100693:	89 fa                	mov    %edi,%edx
f0100695:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100696:	89 35 4c 72 21 f0    	mov    %esi,0xf021724c
	pos |= inb(addr_6845 + 1);
f010069c:	0f b6 c0             	movzbl %al,%eax
f010069f:	09 c8                	or     %ecx,%eax
	crt_pos = pos;
f01006a1:	66 a3 48 72 21 f0    	mov    %ax,0xf0217248
	kbd_intr();
f01006a7:	e8 3d ff ff ff       	call   f01005e9 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006ac:	83 ec 0c             	sub    $0xc,%esp
f01006af:	0f b7 05 a8 53 12 f0 	movzwl 0xf01253a8,%eax
f01006b6:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006bb:	50                   	push   %eax
f01006bc:	e8 67 31 00 00       	call   f0103828 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006c6:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01006cb:	89 c8                	mov    %ecx,%eax
f01006cd:	89 da                	mov    %ebx,%edx
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006d5:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006da:	89 fa                	mov    %edi,%edx
f01006dc:	ee                   	out    %al,(%dx)
f01006dd:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006e2:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006e7:	ee                   	out    %al,(%dx)
f01006e8:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006ed:	89 c8                	mov    %ecx,%eax
f01006ef:	89 f2                	mov    %esi,%edx
f01006f1:	ee                   	out    %al,(%dx)
f01006f2:	b8 03 00 00 00       	mov    $0x3,%eax
f01006f7:	89 fa                	mov    %edi,%edx
f01006f9:	ee                   	out    %al,(%dx)
f01006fa:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006ff:	89 c8                	mov    %ecx,%eax
f0100701:	ee                   	out    %al,(%dx)
f0100702:	b8 01 00 00 00       	mov    $0x1,%eax
f0100707:	89 f2                	mov    %esi,%edx
f0100709:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010070a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010070f:	ec                   	in     (%dx),%al
f0100710:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100712:	83 c4 10             	add    $0x10,%esp
f0100715:	3c ff                	cmp    $0xff,%al
f0100717:	0f 95 05 54 72 21 f0 	setne  0xf0217254
f010071e:	89 da                	mov    %ebx,%edx
f0100720:	ec                   	in     (%dx),%al
f0100721:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100726:	ec                   	in     (%dx),%al
	if (serial_exists)
f0100727:	80 f9 ff             	cmp    $0xff,%cl
f010072a:	75 28                	jne    f0100754 <cons_init+0x117>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
		cprintf("Serial port does not exist!\n");
f010072c:	83 ec 0c             	sub    $0xc,%esp
f010072f:	68 ef 64 10 f0       	push   $0xf01064ef
f0100734:	e8 51 32 00 00       	call   f010398a <cprintf>
f0100739:	83 c4 10             	add    $0x10,%esp
}
f010073c:	eb 37                	jmp    f0100775 <cons_init+0x138>
		*cp = was;
f010073e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f0100745:	bb d4 03 00 00       	mov    $0x3d4,%ebx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010074a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010074f:	e9 1d ff ff ff       	jmp    f0100671 <cons_init+0x34>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100754:	83 ec 0c             	sub    $0xc,%esp
f0100757:	0f b7 05 a8 53 12 f0 	movzwl 0xf01253a8,%eax
f010075e:	25 ef ff 00 00       	and    $0xffef,%eax
f0100763:	50                   	push   %eax
f0100764:	e8 bf 30 00 00       	call   f0103828 <irq_setmask_8259A>
	if (!serial_exists)
f0100769:	83 c4 10             	add    $0x10,%esp
f010076c:	80 3d 54 72 21 f0 00 	cmpb   $0x0,0xf0217254
f0100773:	74 b7                	je     f010072c <cons_init+0xef>
}
f0100775:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100778:	5b                   	pop    %ebx
f0100779:	5e                   	pop    %esi
f010077a:	5f                   	pop    %edi
f010077b:	5d                   	pop    %ebp
f010077c:	c3                   	ret    

f010077d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010077d:	55                   	push   %ebp
f010077e:	89 e5                	mov    %esp,%ebp
f0100780:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100783:	8b 45 08             	mov    0x8(%ebp),%eax
f0100786:	e8 48 fc ff ff       	call   f01003d3 <cons_putc>
}
f010078b:	c9                   	leave  
f010078c:	c3                   	ret    

f010078d <getchar>:

int
getchar(void)
{
f010078d:	55                   	push   %ebp
f010078e:	89 e5                	mov    %esp,%ebp
f0100790:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100793:	e8 63 fe ff ff       	call   f01005fb <cons_getc>
f0100798:	85 c0                	test   %eax,%eax
f010079a:	74 f7                	je     f0100793 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010079c:	c9                   	leave  
f010079d:	c3                   	ret    

f010079e <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f010079e:	b8 01 00 00 00       	mov    $0x1,%eax
f01007a3:	c3                   	ret    

f01007a4 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007a4:	55                   	push   %ebp
f01007a5:	89 e5                	mov    %esp,%ebp
f01007a7:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007aa:	68 40 67 10 f0       	push   $0xf0106740
f01007af:	68 5e 67 10 f0       	push   $0xf010675e
f01007b4:	68 63 67 10 f0       	push   $0xf0106763
f01007b9:	e8 cc 31 00 00       	call   f010398a <cprintf>
f01007be:	83 c4 0c             	add    $0xc,%esp
f01007c1:	68 04 68 10 f0       	push   $0xf0106804
f01007c6:	68 6c 67 10 f0       	push   $0xf010676c
f01007cb:	68 63 67 10 f0       	push   $0xf0106763
f01007d0:	e8 b5 31 00 00       	call   f010398a <cprintf>
	return 0;
}
f01007d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007da:	c9                   	leave  
f01007db:	c3                   	ret    

f01007dc <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007dc:	55                   	push   %ebp
f01007dd:	89 e5                	mov    %esp,%ebp
f01007df:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007e2:	68 75 67 10 f0       	push   $0xf0106775
f01007e7:	e8 9e 31 00 00       	call   f010398a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ec:	83 c4 08             	add    $0x8,%esp
f01007ef:	68 0c 00 10 00       	push   $0x10000c
f01007f4:	68 2c 68 10 f0       	push   $0xf010682c
f01007f9:	e8 8c 31 00 00       	call   f010398a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007fe:	83 c4 0c             	add    $0xc,%esp
f0100801:	68 0c 00 10 00       	push   $0x10000c
f0100806:	68 0c 00 10 f0       	push   $0xf010000c
f010080b:	68 54 68 10 f0       	push   $0xf0106854
f0100810:	e8 75 31 00 00       	call   f010398a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100815:	83 c4 0c             	add    $0xc,%esp
f0100818:	68 01 64 10 00       	push   $0x106401
f010081d:	68 01 64 10 f0       	push   $0xf0106401
f0100822:	68 78 68 10 f0       	push   $0xf0106878
f0100827:	e8 5e 31 00 00       	call   f010398a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082c:	83 c4 0c             	add    $0xc,%esp
f010082f:	68 00 70 21 00       	push   $0x217000
f0100834:	68 00 70 21 f0       	push   $0xf0217000
f0100839:	68 9c 68 10 f0       	push   $0xf010689c
f010083e:	e8 47 31 00 00       	call   f010398a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100843:	83 c4 0c             	add    $0xc,%esp
f0100846:	68 c8 83 25 00       	push   $0x2583c8
f010084b:	68 c8 83 25 f0       	push   $0xf02583c8
f0100850:	68 c0 68 10 f0       	push   $0xf01068c0
f0100855:	e8 30 31 00 00       	call   f010398a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085a:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010085d:	b8 c8 83 25 f0       	mov    $0xf02583c8,%eax
f0100862:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100867:	c1 f8 0a             	sar    $0xa,%eax
f010086a:	50                   	push   %eax
f010086b:	68 e4 68 10 f0       	push   $0xf01068e4
f0100870:	e8 15 31 00 00       	call   f010398a <cprintf>
	return 0;
}
f0100875:	b8 00 00 00 00       	mov    $0x0,%eax
f010087a:	c9                   	leave  
f010087b:	c3                   	ret    

f010087c <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010087c:	55                   	push   %ebp
f010087d:	89 e5                	mov    %esp,%ebp
f010087f:	56                   	push   %esi
f0100880:	53                   	push   %ebx
f0100881:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));//I guess it means moving ebp register value to local variable. 
f0100884:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	uint32_t * ebp;
	struct Eipdebuginfo info;
	
	ebp=(uint32_t *)read_ebp();
	cprintf("Stack backtrace:\n");
f0100886:	68 8e 67 10 f0       	push   $0xf010678e
f010088b:	e8 fa 30 00 00       	call   f010398a <cprintf>
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f0100890:	83 c4 10             	add    $0x10,%esp
		cprintf(" %08x",*(ebp+4));
		cprintf(" %08x",*(ebp+5));
		cprintf(" %08x\n",*(ebp+6));
		
		//Exercise 12
		debuginfo_eip(*(ebp+1) , &info);
f0100893:	8d 75 e0             	lea    -0x20(%ebp),%esi
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f0100896:	e9 c2 00 00 00       	jmp    f010095d <mon_backtrace+0xe1>
		cprintf(" ebp %08x",(uint32_t) ebp);
f010089b:	83 ec 08             	sub    $0x8,%esp
f010089e:	53                   	push   %ebx
f010089f:	68 a0 67 10 f0       	push   $0xf01067a0
f01008a4:	e8 e1 30 00 00       	call   f010398a <cprintf>
		cprintf(" eip %08x",*(ebp+1));
f01008a9:	83 c4 08             	add    $0x8,%esp
f01008ac:	ff 73 04             	push   0x4(%ebx)
f01008af:	68 aa 67 10 f0       	push   $0xf01067aa
f01008b4:	e8 d1 30 00 00       	call   f010398a <cprintf>
		cprintf(" args");
f01008b9:	c7 04 24 b4 67 10 f0 	movl   $0xf01067b4,(%esp)
f01008c0:	e8 c5 30 00 00       	call   f010398a <cprintf>
		cprintf(" %08x",*(ebp+2));
f01008c5:	83 c4 08             	add    $0x8,%esp
f01008c8:	ff 73 08             	push   0x8(%ebx)
f01008cb:	68 a4 67 10 f0       	push   $0xf01067a4
f01008d0:	e8 b5 30 00 00       	call   f010398a <cprintf>
		cprintf(" %08x",*(ebp+3));
f01008d5:	83 c4 08             	add    $0x8,%esp
f01008d8:	ff 73 0c             	push   0xc(%ebx)
f01008db:	68 a4 67 10 f0       	push   $0xf01067a4
f01008e0:	e8 a5 30 00 00       	call   f010398a <cprintf>
		cprintf(" %08x",*(ebp+4));
f01008e5:	83 c4 08             	add    $0x8,%esp
f01008e8:	ff 73 10             	push   0x10(%ebx)
f01008eb:	68 a4 67 10 f0       	push   $0xf01067a4
f01008f0:	e8 95 30 00 00       	call   f010398a <cprintf>
		cprintf(" %08x",*(ebp+5));
f01008f5:	83 c4 08             	add    $0x8,%esp
f01008f8:	ff 73 14             	push   0x14(%ebx)
f01008fb:	68 a4 67 10 f0       	push   $0xf01067a4
f0100900:	e8 85 30 00 00       	call   f010398a <cprintf>
		cprintf(" %08x\n",*(ebp+6));
f0100905:	83 c4 08             	add    $0x8,%esp
f0100908:	ff 73 18             	push   0x18(%ebx)
f010090b:	68 2e 82 10 f0       	push   $0xf010822e
f0100910:	e8 75 30 00 00       	call   f010398a <cprintf>
		debuginfo_eip(*(ebp+1) , &info);
f0100915:	83 c4 08             	add    $0x8,%esp
f0100918:	56                   	push   %esi
f0100919:	ff 73 04             	push   0x4(%ebx)
f010091c:	e8 f4 43 00 00       	call   f0104d15 <debuginfo_eip>
		cprintf("\t%s:",info.eip_file);
f0100921:	83 c4 08             	add    $0x8,%esp
f0100924:	ff 75 e0             	push   -0x20(%ebp)
f0100927:	68 ba 67 10 f0       	push   $0xf01067ba
f010092c:	e8 59 30 00 00       	call   f010398a <cprintf>
		cprintf("%d: ",info.eip_line);
f0100931:	83 c4 08             	add    $0x8,%esp
f0100934:	ff 75 e4             	push   -0x1c(%ebp)
f0100937:	68 de 64 10 f0       	push   $0xf01064de
f010093c:	e8 49 30 00 00       	call   f010398a <cprintf>
		cprintf("%.*s+%d\n", info.eip_fn_namelen , info.eip_fn_name , *(ebp+1) - info.eip_fn_addr );
f0100941:	8b 43 04             	mov    0x4(%ebx),%eax
f0100944:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100947:	50                   	push   %eax
f0100948:	ff 75 e8             	push   -0x18(%ebp)
f010094b:	ff 75 ec             	push   -0x14(%ebp)
f010094e:	68 bf 67 10 f0       	push   $0xf01067bf
f0100953:	e8 32 30 00 00       	call   f010398a <cprintf>
		
		//
		ebp=(uint32_t *)(*ebp);
f0100958:	8b 1b                	mov    (%ebx),%ebx
f010095a:	83 c4 20             	add    $0x20,%esp
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f010095d:	85 db                	test   %ebx,%ebx
f010095f:	0f 85 36 ff ff ff    	jne    f010089b <mon_backtrace+0x1f>
    	cprintf("x=%d y=%d\n", 3);
    	
	cprintf("Lab1 Exercise8 qusetion3 finish!\n");
	*/
	return 0;
}
f0100965:	b8 00 00 00 00       	mov    $0x0,%eax
f010096a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010096d:	5b                   	pop    %ebx
f010096e:	5e                   	pop    %esi
f010096f:	5d                   	pop    %ebp
f0100970:	c3                   	ret    

f0100971 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100971:	55                   	push   %ebp
f0100972:	89 e5                	mov    %esp,%ebp
f0100974:	57                   	push   %edi
f0100975:	56                   	push   %esi
f0100976:	53                   	push   %ebx
f0100977:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010097a:	68 10 69 10 f0       	push   $0xf0106910
f010097f:	e8 06 30 00 00       	call   f010398a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100984:	c7 04 24 34 69 10 f0 	movl   $0xf0106934,(%esp)
f010098b:	e8 fa 2f 00 00       	call   f010398a <cprintf>

	if (tf != NULL)
f0100990:	83 c4 10             	add    $0x10,%esp
f0100993:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100997:	74 57                	je     f01009f0 <monitor+0x7f>
		print_trapframe(tf);
f0100999:	83 ec 0c             	sub    $0xc,%esp
f010099c:	ff 75 08             	push   0x8(%ebp)
f010099f:	e8 a6 35 00 00       	call   f0103f4a <print_trapframe>
f01009a4:	83 c4 10             	add    $0x10,%esp
f01009a7:	eb 47                	jmp    f01009f0 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f01009a9:	83 ec 08             	sub    $0x8,%esp
f01009ac:	0f be c0             	movsbl %al,%eax
f01009af:	50                   	push   %eax
f01009b0:	68 cc 67 10 f0       	push   $0xf01067cc
f01009b5:	e8 ed 4d 00 00       	call   f01057a7 <strchr>
f01009ba:	83 c4 10             	add    $0x10,%esp
f01009bd:	85 c0                	test   %eax,%eax
f01009bf:	74 0a                	je     f01009cb <monitor+0x5a>
			*buf++ = 0;
f01009c1:	c6 03 00             	movb   $0x0,(%ebx)
f01009c4:	89 f7                	mov    %esi,%edi
f01009c6:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009c9:	eb 6b                	jmp    f0100a36 <monitor+0xc5>
		if (*buf == 0)
f01009cb:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009ce:	74 73                	je     f0100a43 <monitor+0xd2>
		if (argc == MAXARGS-1) {
f01009d0:	83 fe 0f             	cmp    $0xf,%esi
f01009d3:	74 09                	je     f01009de <monitor+0x6d>
		argv[argc++] = buf;
f01009d5:	8d 7e 01             	lea    0x1(%esi),%edi
f01009d8:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009dc:	eb 39                	jmp    f0100a17 <monitor+0xa6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009de:	83 ec 08             	sub    $0x8,%esp
f01009e1:	6a 10                	push   $0x10
f01009e3:	68 d1 67 10 f0       	push   $0xf01067d1
f01009e8:	e8 9d 2f 00 00       	call   f010398a <cprintf>
			return 0;
f01009ed:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009f0:	83 ec 0c             	sub    $0xc,%esp
f01009f3:	68 c8 67 10 f0       	push   $0xf01067c8
f01009f8:	e8 70 4b 00 00       	call   f010556d <readline>
f01009fd:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009ff:	83 c4 10             	add    $0x10,%esp
f0100a02:	85 c0                	test   %eax,%eax
f0100a04:	74 ea                	je     f01009f0 <monitor+0x7f>
	argv[argc] = 0;
f0100a06:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a0d:	be 00 00 00 00       	mov    $0x0,%esi
f0100a12:	eb 24                	jmp    f0100a38 <monitor+0xc7>
			buf++;
f0100a14:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a17:	0f b6 03             	movzbl (%ebx),%eax
f0100a1a:	84 c0                	test   %al,%al
f0100a1c:	74 18                	je     f0100a36 <monitor+0xc5>
f0100a1e:	83 ec 08             	sub    $0x8,%esp
f0100a21:	0f be c0             	movsbl %al,%eax
f0100a24:	50                   	push   %eax
f0100a25:	68 cc 67 10 f0       	push   $0xf01067cc
f0100a2a:	e8 78 4d 00 00       	call   f01057a7 <strchr>
f0100a2f:	83 c4 10             	add    $0x10,%esp
f0100a32:	85 c0                	test   %eax,%eax
f0100a34:	74 de                	je     f0100a14 <monitor+0xa3>
			*buf++ = 0;
f0100a36:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a38:	0f b6 03             	movzbl (%ebx),%eax
f0100a3b:	84 c0                	test   %al,%al
f0100a3d:	0f 85 66 ff ff ff    	jne    f01009a9 <monitor+0x38>
	argv[argc] = 0;
f0100a43:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a4a:	00 
	if (argc == 0)
f0100a4b:	85 f6                	test   %esi,%esi
f0100a4d:	74 a1                	je     f01009f0 <monitor+0x7f>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a4f:	83 ec 08             	sub    $0x8,%esp
f0100a52:	68 5e 67 10 f0       	push   $0xf010675e
f0100a57:	ff 75 a8             	push   -0x58(%ebp)
f0100a5a:	e8 e8 4c 00 00       	call   f0105747 <strcmp>
f0100a5f:	83 c4 10             	add    $0x10,%esp
f0100a62:	85 c0                	test   %eax,%eax
f0100a64:	74 34                	je     f0100a9a <monitor+0x129>
f0100a66:	83 ec 08             	sub    $0x8,%esp
f0100a69:	68 6c 67 10 f0       	push   $0xf010676c
f0100a6e:	ff 75 a8             	push   -0x58(%ebp)
f0100a71:	e8 d1 4c 00 00       	call   f0105747 <strcmp>
f0100a76:	83 c4 10             	add    $0x10,%esp
f0100a79:	85 c0                	test   %eax,%eax
f0100a7b:	74 18                	je     f0100a95 <monitor+0x124>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a7d:	83 ec 08             	sub    $0x8,%esp
f0100a80:	ff 75 a8             	push   -0x58(%ebp)
f0100a83:	68 ee 67 10 f0       	push   $0xf01067ee
f0100a88:	e8 fd 2e 00 00       	call   f010398a <cprintf>
	return 0;
f0100a8d:	83 c4 10             	add    $0x10,%esp
f0100a90:	e9 5b ff ff ff       	jmp    f01009f0 <monitor+0x7f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a95:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a9a:	83 ec 04             	sub    $0x4,%esp
f0100a9d:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100aa0:	ff 75 08             	push   0x8(%ebp)
f0100aa3:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100aa6:	52                   	push   %edx
f0100aa7:	56                   	push   %esi
f0100aa8:	ff 14 85 64 69 10 f0 	call   *-0xfef969c(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100aaf:	83 c4 10             	add    $0x10,%esp
f0100ab2:	85 c0                	test   %eax,%eax
f0100ab4:	0f 89 36 ff ff ff    	jns    f01009f0 <monitor+0x7f>
				break;
	}
}
f0100aba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100abd:	5b                   	pop    %ebx
f0100abe:	5e                   	pop    %esi
f0100abf:	5f                   	pop    %edi
f0100ac0:	5d                   	pop    %ebp
f0100ac1:	c3                   	ret    

f0100ac2 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100ac2:	55                   	push   %ebp
f0100ac3:	89 e5                	mov    %esp,%ebp
f0100ac5:	56                   	push   %esi
f0100ac6:	53                   	push   %ebx
f0100ac7:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ac9:	83 ec 0c             	sub    $0xc,%esp
f0100acc:	50                   	push   %eax
f0100acd:	e8 28 2d 00 00       	call   f01037fa <mc146818_read>
f0100ad2:	89 c6                	mov    %eax,%esi
f0100ad4:	83 c3 01             	add    $0x1,%ebx
f0100ad7:	89 1c 24             	mov    %ebx,(%esp)
f0100ada:	e8 1b 2d 00 00       	call   f01037fa <mc146818_read>
f0100adf:	c1 e0 08             	shl    $0x8,%eax
f0100ae2:	09 f0                	or     %esi,%eax
}
f0100ae4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ae7:	5b                   	pop    %ebx
f0100ae8:	5e                   	pop    %esi
f0100ae9:	5d                   	pop    %ebp
f0100aea:	c3                   	ret    

f0100aeb <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100aeb:	83 3d 64 72 21 f0 00 	cmpl   $0x0,0xf0217264
f0100af2:	74 21                	je     f0100b15 <boot_alloc+0x2a>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	
	//
	// LAB 2: Your code here.
	result=nextfree;
f0100af4:	8b 15 64 72 21 f0    	mov    0xf0217264,%edx
	nextfree=ROUNDUP(nextfree+n, PGSIZE);
f0100afa:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b01:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b06:	a3 64 72 21 f0       	mov    %eax,0xf0217264
	if( (uint32_t)nextfree < KERNBASE ){
f0100b0b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100b10:	76 16                	jbe    f0100b28 <boot_alloc+0x3d>
	//这也与博客的写法 if( (uint32_t)nextfree - KERNBASE > (npages*PGSIZE))所不同。
	
	return result;

	//return NULL;
}
f0100b12:	89 d0                	mov    %edx,%eax
f0100b14:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);//ROUNDUP(a,n)函数在inc/types.h中定义：目的是用来进行地址向上对齐，即增大数a至n的倍数。
f0100b15:	ba c7 93 25 f0       	mov    $0xf02593c7,%edx
f0100b1a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b20:	89 15 64 72 21 f0    	mov    %edx,0xf0217264
f0100b26:	eb cc                	jmp    f0100af4 <boot_alloc+0x9>
{
f0100b28:	55                   	push   %ebp
f0100b29:	89 e5                	mov    %esp,%ebp
f0100b2b:	83 ec 0c             	sub    $0xc,%esp
		panic("boot_alloc: out of memory\n");
f0100b2e:	68 74 69 10 f0       	push   $0xf0106974
f0100b33:	6a 75                	push   $0x75
f0100b35:	68 8f 69 10 f0       	push   $0xf010698f
f0100b3a:	e8 01 f5 ff ff       	call   f0100040 <_panic>

f0100b3f <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b3f:	89 d1                	mov    %edx,%ecx
f0100b41:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b44:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b47:	a8 01                	test   $0x1,%al
f0100b49:	74 51                	je     f0100b9c <check_va2pa+0x5d>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b4b:	89 c1                	mov    %eax,%ecx
f0100b4d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100b53:	c1 e8 0c             	shr    $0xc,%eax
f0100b56:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0100b5c:	73 23                	jae    f0100b81 <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P))
f0100b5e:	c1 ea 0c             	shr    $0xc,%edx
f0100b61:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b67:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b6e:	89 d0                	mov    %edx,%eax
f0100b70:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b75:	f6 c2 01             	test   $0x1,%dl
f0100b78:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b7d:	0f 44 c2             	cmove  %edx,%eax
f0100b80:	c3                   	ret    
{
f0100b81:	55                   	push   %ebp
f0100b82:	89 e5                	mov    %esp,%ebp
f0100b84:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b87:	51                   	push   %ecx
f0100b88:	68 44 64 10 f0       	push   $0xf0106444
f0100b8d:	68 ba 03 00 00       	push   $0x3ba
f0100b92:	68 8f 69 10 f0       	push   $0xf010698f
f0100b97:	e8 a4 f4 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100b9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100ba1:	c3                   	ret    

f0100ba2 <check_page_free_list>:
{
f0100ba2:	55                   	push   %ebp
f0100ba3:	89 e5                	mov    %esp,%ebp
f0100ba5:	57                   	push   %edi
f0100ba6:	56                   	push   %esi
f0100ba7:	53                   	push   %ebx
f0100ba8:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100bab:	84 c0                	test   %al,%al
f0100bad:	0f 85 77 02 00 00    	jne    f0100e2a <check_page_free_list+0x288>
	if (!page_free_list)
f0100bb3:	83 3d 6c 72 21 f0 00 	cmpl   $0x0,0xf021726c
f0100bba:	74 0a                	je     f0100bc6 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100bbc:	be 00 04 00 00       	mov    $0x400,%esi
f0100bc1:	e9 bf 02 00 00       	jmp    f0100e85 <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100bc6:	83 ec 04             	sub    $0x4,%esp
f0100bc9:	68 c8 6c 10 f0       	push   $0xf0106cc8
f0100bce:	68 ed 02 00 00       	push   $0x2ed
f0100bd3:	68 8f 69 10 f0       	push   $0xf010698f
f0100bd8:	e8 63 f4 ff ff       	call   f0100040 <_panic>
f0100bdd:	50                   	push   %eax
f0100bde:	68 44 64 10 f0       	push   $0xf0106444
f0100be3:	6a 5a                	push   $0x5a
f0100be5:	68 9b 69 10 f0       	push   $0xf010699b
f0100bea:	e8 51 f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bef:	8b 1b                	mov    (%ebx),%ebx
f0100bf1:	85 db                	test   %ebx,%ebx
f0100bf3:	74 41                	je     f0100c36 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0100bf5:	89 d8                	mov    %ebx,%eax
f0100bf7:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0100bfd:	c1 f8 03             	sar    $0x3,%eax
f0100c00:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c03:	89 c2                	mov    %eax,%edx
f0100c05:	c1 ea 16             	shr    $0x16,%edx
f0100c08:	39 f2                	cmp    %esi,%edx
f0100c0a:	73 e3                	jae    f0100bef <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100c0c:	89 c2                	mov    %eax,%edx
f0100c0e:	c1 ea 0c             	shr    $0xc,%edx
f0100c11:	3b 15 60 72 21 f0    	cmp    0xf0217260,%edx
f0100c17:	73 c4                	jae    f0100bdd <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100c19:	83 ec 04             	sub    $0x4,%esp
f0100c1c:	68 80 00 00 00       	push   $0x80
f0100c21:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c26:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c2b:	50                   	push   %eax
f0100c2c:	e8 b5 4b 00 00       	call   f01057e6 <memset>
f0100c31:	83 c4 10             	add    $0x10,%esp
f0100c34:	eb b9                	jmp    f0100bef <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100c36:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c3b:	e8 ab fe ff ff       	call   f0100aeb <boot_alloc>
f0100c40:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c43:	8b 15 6c 72 21 f0    	mov    0xf021726c,%edx
		assert(pp >= pages);
f0100c49:	8b 0d 58 72 21 f0    	mov    0xf0217258,%ecx
		assert(pp < pages + npages);
f0100c4f:	a1 60 72 21 f0       	mov    0xf0217260,%eax
f0100c54:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c57:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c5a:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c5f:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c62:	e9 f9 00 00 00       	jmp    f0100d60 <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100c67:	68 a9 69 10 f0       	push   $0xf01069a9
f0100c6c:	68 b5 69 10 f0       	push   $0xf01069b5
f0100c71:	68 07 03 00 00       	push   $0x307
f0100c76:	68 8f 69 10 f0       	push   $0xf010698f
f0100c7b:	e8 c0 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c80:	68 ca 69 10 f0       	push   $0xf01069ca
f0100c85:	68 b5 69 10 f0       	push   $0xf01069b5
f0100c8a:	68 08 03 00 00       	push   $0x308
f0100c8f:	68 8f 69 10 f0       	push   $0xf010698f
f0100c94:	e8 a7 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c99:	68 ec 6c 10 f0       	push   $0xf0106cec
f0100c9e:	68 b5 69 10 f0       	push   $0xf01069b5
f0100ca3:	68 09 03 00 00       	push   $0x309
f0100ca8:	68 8f 69 10 f0       	push   $0xf010698f
f0100cad:	e8 8e f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100cb2:	68 de 69 10 f0       	push   $0xf01069de
f0100cb7:	68 b5 69 10 f0       	push   $0xf01069b5
f0100cbc:	68 0c 03 00 00       	push   $0x30c
f0100cc1:	68 8f 69 10 f0       	push   $0xf010698f
f0100cc6:	e8 75 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ccb:	68 ef 69 10 f0       	push   $0xf01069ef
f0100cd0:	68 b5 69 10 f0       	push   $0xf01069b5
f0100cd5:	68 0d 03 00 00       	push   $0x30d
f0100cda:	68 8f 69 10 f0       	push   $0xf010698f
f0100cdf:	e8 5c f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ce4:	68 20 6d 10 f0       	push   $0xf0106d20
f0100ce9:	68 b5 69 10 f0       	push   $0xf01069b5
f0100cee:	68 0e 03 00 00       	push   $0x30e
f0100cf3:	68 8f 69 10 f0       	push   $0xf010698f
f0100cf8:	e8 43 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cfd:	68 08 6a 10 f0       	push   $0xf0106a08
f0100d02:	68 b5 69 10 f0       	push   $0xf01069b5
f0100d07:	68 0f 03 00 00       	push   $0x30f
f0100d0c:	68 8f 69 10 f0       	push   $0xf010698f
f0100d11:	e8 2a f3 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100d16:	89 c3                	mov    %eax,%ebx
f0100d18:	c1 eb 0c             	shr    $0xc,%ebx
f0100d1b:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100d1e:	76 0f                	jbe    f0100d2f <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100d20:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d25:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d28:	77 17                	ja     f0100d41 <check_page_free_list+0x19f>
			++nfree_extmem;
f0100d2a:	83 c7 01             	add    $0x1,%edi
f0100d2d:	eb 2f                	jmp    f0100d5e <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d2f:	50                   	push   %eax
f0100d30:	68 44 64 10 f0       	push   $0xf0106444
f0100d35:	6a 5a                	push   $0x5a
f0100d37:	68 9b 69 10 f0       	push   $0xf010699b
f0100d3c:	e8 ff f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d41:	68 44 6d 10 f0       	push   $0xf0106d44
f0100d46:	68 b5 69 10 f0       	push   $0xf01069b5
f0100d4b:	68 10 03 00 00       	push   $0x310
f0100d50:	68 8f 69 10 f0       	push   $0xf010698f
f0100d55:	e8 e6 f2 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100d5a:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d5e:	8b 12                	mov    (%edx),%edx
f0100d60:	85 d2                	test   %edx,%edx
f0100d62:	74 74                	je     f0100dd8 <check_page_free_list+0x236>
		assert(pp >= pages);
f0100d64:	39 d1                	cmp    %edx,%ecx
f0100d66:	0f 87 fb fe ff ff    	ja     f0100c67 <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100d6c:	39 d6                	cmp    %edx,%esi
f0100d6e:	0f 86 0c ff ff ff    	jbe    f0100c80 <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d74:	89 d0                	mov    %edx,%eax
f0100d76:	29 c8                	sub    %ecx,%eax
f0100d78:	a8 07                	test   $0x7,%al
f0100d7a:	0f 85 19 ff ff ff    	jne    f0100c99 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0100d80:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d83:	c1 e0 0c             	shl    $0xc,%eax
f0100d86:	0f 84 26 ff ff ff    	je     f0100cb2 <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d8c:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d91:	0f 84 34 ff ff ff    	je     f0100ccb <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d97:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d9c:	0f 84 42 ff ff ff    	je     f0100ce4 <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100da2:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100da7:	0f 84 50 ff ff ff    	je     f0100cfd <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dad:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100db2:	0f 87 5e ff ff ff    	ja     f0100d16 <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100db8:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dbd:	75 9b                	jne    f0100d5a <check_page_free_list+0x1b8>
f0100dbf:	68 22 6a 10 f0       	push   $0xf0106a22
f0100dc4:	68 b5 69 10 f0       	push   $0xf01069b5
f0100dc9:	68 12 03 00 00       	push   $0x312
f0100dce:	68 8f 69 10 f0       	push   $0xf010698f
f0100dd3:	e8 68 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f0100dd8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ddb:	85 db                	test   %ebx,%ebx
f0100ddd:	7e 19                	jle    f0100df8 <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100ddf:	85 ff                	test   %edi,%edi
f0100de1:	7e 2e                	jle    f0100e11 <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100de3:	83 ec 0c             	sub    $0xc,%esp
f0100de6:	68 8c 6d 10 f0       	push   $0xf0106d8c
f0100deb:	e8 9a 2b 00 00       	call   f010398a <cprintf>
}
f0100df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100df3:	5b                   	pop    %ebx
f0100df4:	5e                   	pop    %esi
f0100df5:	5f                   	pop    %edi
f0100df6:	5d                   	pop    %ebp
f0100df7:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100df8:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100dfd:	68 b5 69 10 f0       	push   $0xf01069b5
f0100e02:	68 1a 03 00 00       	push   $0x31a
f0100e07:	68 8f 69 10 f0       	push   $0xf010698f
f0100e0c:	e8 2f f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e11:	68 51 6a 10 f0       	push   $0xf0106a51
f0100e16:	68 b5 69 10 f0       	push   $0xf01069b5
f0100e1b:	68 1b 03 00 00       	push   $0x31b
f0100e20:	68 8f 69 10 f0       	push   $0xf010698f
f0100e25:	e8 16 f2 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100e2a:	a1 6c 72 21 f0       	mov    0xf021726c,%eax
f0100e2f:	85 c0                	test   %eax,%eax
f0100e31:	0f 84 8f fd ff ff    	je     f0100bc6 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e37:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e3a:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e3d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e40:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100e43:	89 c2                	mov    %eax,%edx
f0100e45:	2b 15 58 72 21 f0    	sub    0xf0217258,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e4b:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100e51:	0f 95 c2             	setne  %dl
f0100e54:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100e57:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100e5b:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e5d:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e61:	8b 00                	mov    (%eax),%eax
f0100e63:	85 c0                	test   %eax,%eax
f0100e65:	75 dc                	jne    f0100e43 <check_page_free_list+0x2a1>
		*tp[1] = 0;
f0100e67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e6a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e70:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e73:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e76:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e78:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e7b:	a3 6c 72 21 f0       	mov    %eax,0xf021726c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100e80:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e85:	8b 1d 6c 72 21 f0    	mov    0xf021726c,%ebx
f0100e8b:	e9 61 fd ff ff       	jmp    f0100bf1 <check_page_free_list+0x4f>

f0100e90 <page_init>:
{
f0100e90:	55                   	push   %ebp
f0100e91:	89 e5                	mov    %esp,%ebp
f0100e93:	57                   	push   %edi
f0100e94:	56                   	push   %esi
f0100e95:	53                   	push   %ebx
f0100e96:	83 ec 0c             	sub    $0xc,%esp
	page_free_list = NULL;//其实是多余的，因为它本就是空指针，这只是为了方便阅读一点。
f0100e99:	c7 05 6c 72 21 f0 00 	movl   $0x0,0xf021726c
f0100ea0:	00 00 00 
	uint32_t EXTPHYSMEM_alloc = (uint32_t)boot_alloc(0) - KERNBASE;//EXTPHYSMEM_alloc：在EXTPHYSMEM区域已经被占用的bytes数
f0100ea3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ea8:	e8 3e fc ff ff       	call   f0100aeb <boot_alloc>
		if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)/* 3,4条*/ ||  (i>=MPENTRY_PADDR/PGSIZE && i<(MPENTRY_PADDR+size)/PGSIZE) /*lab4*/){//不标记为free的页
f0100ead:	8d 98 00 00 10 10    	lea    0x10100000(%eax),%ebx
f0100eb3:	c1 eb 0c             	shr    $0xc,%ebx
    	size = ROUNDUP(size, PGSIZE);
f0100eb6:	b9 52 5a 10 f0       	mov    $0xf0105a52,%ecx
f0100ebb:	81 e9 d9 49 10 f0    	sub    $0xf01049d9,%ecx
		if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)/* 3,4条*/ ||  (i>=MPENTRY_PADDR/PGSIZE && i<(MPENTRY_PADDR+size)/PGSIZE) /*lab4*/){//不标记为free的页
f0100ec1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100ec7:	81 c1 00 70 00 00    	add    $0x7000,%ecx
f0100ecd:	c1 e9 0c             	shr    $0xc,%ecx
	for (size_t i = 0; i < npages; i++) {
f0100ed0:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ed5:	be 00 00 00 00       	mov    $0x0,%esi
f0100eda:	b8 00 00 00 00       	mov    $0x0,%eax
f0100edf:	eb 10                	jmp    f0100ef1 <page_init+0x61>
			pages[i].pp_ref = 1;
f0100ee1:	8b 3d 58 72 21 f0    	mov    0xf0217258,%edi
f0100ee7:	66 c7 44 c7 04 01 00 	movw   $0x1,0x4(%edi,%eax,8)
	for (size_t i = 0; i < npages; i++) {
f0100eee:	83 c0 01             	add    $0x1,%eax
f0100ef1:	39 05 60 72 21 f0    	cmp    %eax,0xf0217260
f0100ef7:	76 3e                	jbe    f0100f37 <page_init+0xa7>
		if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)/* 3,4条*/ ||  (i>=MPENTRY_PADDR/PGSIZE && i<(MPENTRY_PADDR+size)/PGSIZE) /*lab4*/){//不标记为free的页
f0100ef9:	85 c0                	test   %eax,%eax
f0100efb:	74 e4                	je     f0100ee1 <page_init+0x51>
f0100efd:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0100f02:	76 04                	jbe    f0100f08 <page_init+0x78>
f0100f04:	39 c3                	cmp    %eax,%ebx
f0100f06:	77 d9                	ja     f0100ee1 <page_init+0x51>
f0100f08:	83 f8 06             	cmp    $0x6,%eax
f0100f0b:	76 04                	jbe    f0100f11 <page_init+0x81>
f0100f0d:	39 c1                	cmp    %eax,%ecx
f0100f0f:	77 d0                	ja     f0100ee1 <page_init+0x51>
f0100f11:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0100f18:	89 d7                	mov    %edx,%edi
f0100f1a:	03 3d 58 72 21 f0    	add    0xf0217258,%edi
f0100f20:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
			pages[i].pp_link = page_free_list;
f0100f26:	89 37                	mov    %esi,(%edi)
			page_free_list = &pages[i];	
f0100f28:	89 d6                	mov    %edx,%esi
f0100f2a:	03 35 58 72 21 f0    	add    0xf0217258,%esi
f0100f30:	ba 01 00 00 00       	mov    $0x1,%edx
f0100f35:	eb b7                	jmp    f0100eee <page_init+0x5e>
f0100f37:	84 d2                	test   %dl,%dl
f0100f39:	74 06                	je     f0100f41 <page_init+0xb1>
f0100f3b:	89 35 6c 72 21 f0    	mov    %esi,0xf021726c
}
f0100f41:	83 c4 0c             	add    $0xc,%esp
f0100f44:	5b                   	pop    %ebx
f0100f45:	5e                   	pop    %esi
f0100f46:	5f                   	pop    %edi
f0100f47:	5d                   	pop    %ebp
f0100f48:	c3                   	ret    

f0100f49 <page_alloc>:
{
f0100f49:	55                   	push   %ebp
f0100f4a:	89 e5                	mov    %esp,%ebp
f0100f4c:	53                   	push   %ebx
f0100f4d:	83 ec 04             	sub    $0x4,%esp
	if(!page_free_list) return res;
f0100f50:	8b 1d 6c 72 21 f0    	mov    0xf021726c,%ebx
f0100f56:	85 db                	test   %ebx,%ebx
f0100f58:	74 13                	je     f0100f6d <page_alloc+0x24>
	page_free_list=page_free_list -> pp_link;
f0100f5a:	8b 03                	mov    (%ebx),%eax
f0100f5c:	a3 6c 72 21 f0       	mov    %eax,0xf021726c
	res ->pp_link=NULL;
f0100f61:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO){//ALLOC_ZERO在pmap.h中定义 ALLOC_ZERO = 1<<0,
f0100f67:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f6b:	75 07                	jne    f0100f74 <page_alloc+0x2b>
}
f0100f6d:	89 d8                	mov    %ebx,%eax
f0100f6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f72:	c9                   	leave  
f0100f73:	c3                   	ret    
f0100f74:	89 d8                	mov    %ebx,%eax
f0100f76:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0100f7c:	c1 f8 03             	sar    $0x3,%eax
f0100f7f:	89 c2                	mov    %eax,%edx
f0100f81:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100f84:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100f89:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0100f8f:	73 1b                	jae    f0100fac <page_alloc+0x63>
		memset(page2kva(res) , '\0' ,  PGSIZE );
f0100f91:	83 ec 04             	sub    $0x4,%esp
f0100f94:	68 00 10 00 00       	push   $0x1000
f0100f99:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100f9b:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100fa1:	52                   	push   %edx
f0100fa2:	e8 3f 48 00 00       	call   f01057e6 <memset>
f0100fa7:	83 c4 10             	add    $0x10,%esp
f0100faa:	eb c1                	jmp    f0100f6d <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fac:	52                   	push   %edx
f0100fad:	68 44 64 10 f0       	push   $0xf0106444
f0100fb2:	6a 5a                	push   $0x5a
f0100fb4:	68 9b 69 10 f0       	push   $0xf010699b
f0100fb9:	e8 82 f0 ff ff       	call   f0100040 <_panic>

f0100fbe <page_free>:
{
f0100fbe:	55                   	push   %ebp
f0100fbf:	89 e5                	mov    %esp,%ebp
f0100fc1:	83 ec 08             	sub    $0x8,%esp
f0100fc4:	8b 45 08             	mov    0x8(%ebp),%eax
      	assert(pp->pp_ref == 0);
f0100fc7:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100fcc:	75 14                	jne    f0100fe2 <page_free+0x24>
      	assert(pp->pp_link == NULL);
f0100fce:	83 38 00             	cmpl   $0x0,(%eax)
f0100fd1:	75 28                	jne    f0100ffb <page_free+0x3d>
	pp->pp_link=page_free_list;
f0100fd3:	8b 15 6c 72 21 f0    	mov    0xf021726c,%edx
f0100fd9:	89 10                	mov    %edx,(%eax)
	page_free_list=pp;
f0100fdb:	a3 6c 72 21 f0       	mov    %eax,0xf021726c
}
f0100fe0:	c9                   	leave  
f0100fe1:	c3                   	ret    
      	assert(pp->pp_ref == 0);
f0100fe2:	68 62 6a 10 f0       	push   $0xf0106a62
f0100fe7:	68 b5 69 10 f0       	push   $0xf01069b5
f0100fec:	68 a1 01 00 00       	push   $0x1a1
f0100ff1:	68 8f 69 10 f0       	push   $0xf010698f
f0100ff6:	e8 45 f0 ff ff       	call   f0100040 <_panic>
      	assert(pp->pp_link == NULL);
f0100ffb:	68 72 6a 10 f0       	push   $0xf0106a72
f0101000:	68 b5 69 10 f0       	push   $0xf01069b5
f0101005:	68 a2 01 00 00       	push   $0x1a2
f010100a:	68 8f 69 10 f0       	push   $0xf010698f
f010100f:	e8 2c f0 ff ff       	call   f0100040 <_panic>

f0101014 <page_decref>:
{
f0101014:	55                   	push   %ebp
f0101015:	89 e5                	mov    %esp,%ebp
f0101017:	83 ec 08             	sub    $0x8,%esp
f010101a:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010101d:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101021:	83 e8 01             	sub    $0x1,%eax
f0101024:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101028:	66 85 c0             	test   %ax,%ax
f010102b:	74 02                	je     f010102f <page_decref+0x1b>
}
f010102d:	c9                   	leave  
f010102e:	c3                   	ret    
		page_free(pp);
f010102f:	83 ec 0c             	sub    $0xc,%esp
f0101032:	52                   	push   %edx
f0101033:	e8 86 ff ff ff       	call   f0100fbe <page_free>
f0101038:	83 c4 10             	add    $0x10,%esp
}
f010103b:	eb f0                	jmp    f010102d <page_decref+0x19>

f010103d <pgdir_walk>:
{
f010103d:	55                   	push   %ebp
f010103e:	89 e5                	mov    %esp,%ebp
f0101040:	56                   	push   %esi
f0101041:	53                   	push   %ebx
f0101042:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t* dir_entry=pgdir+PDX(va); //PDX(va)返回page directory index,dir_entry是指向页目录中的DIR ENTRY(见图)的指针。
f0101045:	89 f3                	mov    %esi,%ebx
f0101047:	c1 eb 16             	shr    $0x16,%ebx
f010104a:	c1 e3 02             	shl    $0x2,%ebx
f010104d:	03 5d 08             	add    0x8(%ebp),%ebx
	if( !(*dir_entry & PTE_P) ){//如果这个页表不存在
f0101050:	f6 03 01             	testb  $0x1,(%ebx)
f0101053:	75 67                	jne    f01010bc <pgdir_walk+0x7f>
		if(create==false) return NULL;
f0101055:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101059:	0f 84 b0 00 00 00    	je     f010110f <pgdir_walk+0xd2>
			struct PageInfo * new_pp =page_alloc(1);//别忘了这个它返回的是struct PageInfo *
f010105f:	83 ec 0c             	sub    $0xc,%esp
f0101062:	6a 01                	push   $0x1
f0101064:	e8 e0 fe ff ff       	call   f0100f49 <page_alloc>
			if(new_pp==NULL){
f0101069:	83 c4 10             	add    $0x10,%esp
f010106c:	85 c0                	test   %eax,%eax
f010106e:	74 71                	je     f01010e1 <pgdir_walk+0xa4>
			new_pp->pp_ref++;
f0101070:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101075:	89 c2                	mov    %eax,%edx
f0101077:	2b 15 58 72 21 f0    	sub    0xf0217258,%edx
f010107d:	c1 fa 03             	sar    $0x3,%edx
f0101080:	c1 e2 0c             	shl    $0xc,%edx
			*dir_entry=(page2pa(new_pp) | PTE_P | PTE_W | PTE_U);//设置dir_entry的标志位。注释中说可以设置宽松，所以这里全部设置为最宽松：可读写，应用程序级别即可访问。 dirty位 和access位不做设置。
f0101083:	83 ca 07             	or     $0x7,%edx
f0101086:	89 13                	mov    %edx,(%ebx)
f0101088:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f010108e:	c1 f8 03             	sar    $0x3,%eax
f0101091:	89 c2                	mov    %eax,%edx
f0101093:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101096:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010109b:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f01010a1:	73 45                	jae    f01010e8 <pgdir_walk+0xab>
			memset(page2kva(new_pp) , '\0' ,  PGSIZE);//初始化new_page的物理内存，一定要用虚拟地址!!!!!			
f01010a3:	83 ec 04             	sub    $0x4,%esp
f01010a6:	68 00 10 00 00       	push   $0x1000
f01010ab:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01010ad:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01010b3:	52                   	push   %edx
f01010b4:	e8 2d 47 00 00       	call   f01057e6 <memset>
f01010b9:	83 c4 10             	add    $0x10,%esp
	pte_t * page_base = KADDR(PTE_ADDR(*dir_entry));//注意这块的类型定义，这涉及地址运算。 很重要，之前的bug就是因为这里!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
f01010bc:	8b 03                	mov    (%ebx),%eax
f01010be:	89 c2                	mov    %eax,%edx
f01010c0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01010c6:	c1 e8 0c             	shr    $0xc,%eax
f01010c9:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f01010cf:	73 29                	jae    f01010fa <pgdir_walk+0xbd>
	return  &page_base[PTX(va)];	
f01010d1:	c1 ee 0a             	shr    $0xa,%esi
f01010d4:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01010da:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
}
f01010e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010e4:	5b                   	pop    %ebx
f01010e5:	5e                   	pop    %esi
f01010e6:	5d                   	pop    %ebp
f01010e7:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010e8:	52                   	push   %edx
f01010e9:	68 44 64 10 f0       	push   $0xf0106444
f01010ee:	6a 5a                	push   $0x5a
f01010f0:	68 9b 69 10 f0       	push   $0xf010699b
f01010f5:	e8 46 ef ff ff       	call   f0100040 <_panic>
f01010fa:	52                   	push   %edx
f01010fb:	68 44 64 10 f0       	push   $0xf0106444
f0101100:	68 dd 01 00 00       	push   $0x1dd
f0101105:	68 8f 69 10 f0       	push   $0xf010698f
f010110a:	e8 31 ef ff ff       	call   f0100040 <_panic>
		if(create==false) return NULL;
f010110f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101114:	eb cb                	jmp    f01010e1 <pgdir_walk+0xa4>

f0101116 <boot_map_region>:
{
f0101116:	55                   	push   %ebp
f0101117:	89 e5                	mov    %esp,%ebp
f0101119:	57                   	push   %edi
f010111a:	56                   	push   %esi
f010111b:	53                   	push   %ebx
f010111c:	83 ec 1c             	sub    $0x1c,%esp
f010111f:	89 c7                	mov    %eax,%edi
f0101121:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101124:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(int i=0; i<size;i+=PGSIZE){
f0101127:	be 00 00 00 00       	mov    $0x0,%esi
f010112c:	89 f3                	mov    %esi,%ebx
f010112e:	03 5d 08             	add    0x8(%ebp),%ebx
f0101131:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0101134:	76 3f                	jbe    f0101175 <boot_map_region+0x5f>
		pt_entry=pgdir_walk(pgdir, (void *) va ,1);
f0101136:	83 ec 04             	sub    $0x4,%esp
f0101139:	6a 01                	push   $0x1
f010113b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010113e:	01 f0                	add    %esi,%eax
f0101140:	50                   	push   %eax
f0101141:	57                   	push   %edi
f0101142:	e8 f6 fe ff ff       	call   f010103d <pgdir_walk>
		if (pt_entry == NULL) {
f0101147:	83 c4 10             	add    $0x10,%esp
f010114a:	85 c0                	test   %eax,%eax
f010114c:	74 10                	je     f010115e <boot_map_region+0x48>
		* pt_entry=(pa |perm | PTE_P);//按照注释对pg_entry置标志位。
f010114e:	0b 5d 0c             	or     0xc(%ebp),%ebx
f0101151:	83 cb 01             	or     $0x1,%ebx
f0101154:	89 18                	mov    %ebx,(%eax)
	for(int i=0; i<size;i+=PGSIZE){
f0101156:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010115c:	eb ce                	jmp    f010112c <boot_map_region+0x16>
            		panic("boot_map_region(): out of memory\n");
f010115e:	83 ec 04             	sub    $0x4,%esp
f0101161:	68 b0 6d 10 f0       	push   $0xf0106db0
f0101166:	68 f7 01 00 00       	push   $0x1f7
f010116b:	68 8f 69 10 f0       	push   $0xf010698f
f0101170:	e8 cb ee ff ff       	call   f0100040 <_panic>
}
f0101175:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101178:	5b                   	pop    %ebx
f0101179:	5e                   	pop    %esi
f010117a:	5f                   	pop    %edi
f010117b:	5d                   	pop    %ebp
f010117c:	c3                   	ret    

f010117d <page_lookup>:
{
f010117d:	55                   	push   %ebp
f010117e:	89 e5                	mov    %esp,%ebp
f0101180:	53                   	push   %ebx
f0101181:	83 ec 08             	sub    $0x8,%esp
f0101184:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t * pt_entry=pgdir_walk(pgdir,va,0);
f0101187:	6a 00                	push   $0x0
f0101189:	ff 75 0c             	push   0xc(%ebp)
f010118c:	ff 75 08             	push   0x8(%ebp)
f010118f:	e8 a9 fe ff ff       	call   f010103d <pgdir_walk>
	if(pt_entry==NULL)  return NULL;
f0101194:	83 c4 10             	add    $0x10,%esp
f0101197:	85 c0                	test   %eax,%eax
f0101199:	74 21                	je     f01011bc <page_lookup+0x3f>
	if(!(*pt_entry & PTE_P))  return NULL;
f010119b:	f6 00 01             	testb  $0x1,(%eax)
f010119e:	74 35                	je     f01011d5 <page_lookup+0x58>
	if(pte_store) *pte_store=pt_entry;
f01011a0:	85 db                	test   %ebx,%ebx
f01011a2:	74 02                	je     f01011a6 <page_lookup+0x29>
f01011a4:	89 03                	mov    %eax,(%ebx)
f01011a6:	8b 00                	mov    (%eax),%eax
f01011a8:	c1 e8 0c             	shr    $0xc,%eax

//返回对应物理地址的 struct PageInfo* 部分
static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f01011ab:	39 05 60 72 21 f0    	cmp    %eax,0xf0217260
f01011b1:	76 0e                	jbe    f01011c1 <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01011b3:	8b 15 58 72 21 f0    	mov    0xf0217258,%edx
f01011b9:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01011bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011bf:	c9                   	leave  
f01011c0:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01011c1:	83 ec 04             	sub    $0x4,%esp
f01011c4:	68 d4 6d 10 f0       	push   $0xf0106dd4
f01011c9:	6a 52                	push   $0x52
f01011cb:	68 9b 69 10 f0       	push   $0xf010699b
f01011d0:	e8 6b ee ff ff       	call   f0100040 <_panic>
	if(!(*pt_entry & PTE_P))  return NULL;
f01011d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01011da:	eb e0                	jmp    f01011bc <page_lookup+0x3f>

f01011dc <tlb_invalidate>:
{
f01011dc:	55                   	push   %ebp
f01011dd:	89 e5                	mov    %esp,%ebp
f01011df:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01011e2:	e8 f5 4b 00 00       	call   f0105ddc <cpunum>
f01011e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01011ea:	83 b8 28 80 25 f0 00 	cmpl   $0x0,-0xfda7fd8(%eax)
f01011f1:	74 16                	je     f0101209 <tlb_invalidate+0x2d>
f01011f3:	e8 e4 4b 00 00       	call   f0105ddc <cpunum>
f01011f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01011fb:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0101201:	8b 55 08             	mov    0x8(%ebp),%edx
f0101204:	39 50 60             	cmp    %edx,0x60(%eax)
f0101207:	75 06                	jne    f010120f <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101209:	8b 45 0c             	mov    0xc(%ebp),%eax
f010120c:	0f 01 38             	invlpg (%eax)
}
f010120f:	c9                   	leave  
f0101210:	c3                   	ret    

f0101211 <page_remove>:
{
f0101211:	55                   	push   %ebp
f0101212:	89 e5                	mov    %esp,%ebp
f0101214:	56                   	push   %esi
f0101215:	53                   	push   %ebx
f0101216:	83 ec 14             	sub    $0x14,%esp
f0101219:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010121c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo * pp=page_lookup(pgdir,va,&pt_entry);
f010121f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101222:	50                   	push   %eax
f0101223:	56                   	push   %esi
f0101224:	53                   	push   %ebx
f0101225:	e8 53 ff ff ff       	call   f010117d <page_lookup>
	if(pp==NULL) return ;
f010122a:	83 c4 10             	add    $0x10,%esp
f010122d:	85 c0                	test   %eax,%eax
f010122f:	74 1f                	je     f0101250 <page_remove+0x3f>
	page_decref(pp);
f0101231:	83 ec 0c             	sub    $0xc,%esp
f0101234:	50                   	push   %eax
f0101235:	e8 da fd ff ff       	call   f0101014 <page_decref>
	*pt_entry= 0;
f010123a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010123d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f0101243:	83 c4 08             	add    $0x8,%esp
f0101246:	56                   	push   %esi
f0101247:	53                   	push   %ebx
f0101248:	e8 8f ff ff ff       	call   f01011dc <tlb_invalidate>
f010124d:	83 c4 10             	add    $0x10,%esp
}
f0101250:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101253:	5b                   	pop    %ebx
f0101254:	5e                   	pop    %esi
f0101255:	5d                   	pop    %ebp
f0101256:	c3                   	ret    

f0101257 <page_insert>:
{
f0101257:	55                   	push   %ebp
f0101258:	89 e5                	mov    %esp,%ebp
f010125a:	57                   	push   %edi
f010125b:	56                   	push   %esi
f010125c:	53                   	push   %ebx
f010125d:	83 ec 10             	sub    $0x10,%esp
f0101260:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101263:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pt_entry=pgdir_walk(pgdir,va,1);
f0101266:	6a 01                	push   $0x1
f0101268:	57                   	push   %edi
f0101269:	ff 75 08             	push   0x8(%ebp)
f010126c:	e8 cc fd ff ff       	call   f010103d <pgdir_walk>
	if(pt_entry==NULL) return -E_NO_MEM;
f0101271:	83 c4 10             	add    $0x10,%esp
f0101274:	85 c0                	test   %eax,%eax
f0101276:	74 3e                	je     f01012b6 <page_insert+0x5f>
f0101278:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;//这个一定要在前面，否则如果相同的pp 重新插入相同的va就会把  pp释放掉了。
f010127a:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if( (*pt_entry) & PTE_P ){//如果这个页已经存在
f010127f:	f6 00 01             	testb  $0x1,(%eax)
f0101282:	75 21                	jne    f01012a5 <page_insert+0x4e>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101284:	2b 1d 58 72 21 f0    	sub    0xf0217258,%ebx
f010128a:	c1 fb 03             	sar    $0x3,%ebx
f010128d:	c1 e3 0c             	shl    $0xc,%ebx
	*pt_entry = *pt_entry | perm | PTE_P ;
f0101290:	0b 5d 14             	or     0x14(%ebp),%ebx
f0101293:	83 cb 01             	or     $0x1,%ebx
f0101296:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101298:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010129d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012a0:	5b                   	pop    %ebx
f01012a1:	5e                   	pop    %esi
f01012a2:	5f                   	pop    %edi
f01012a3:	5d                   	pop    %ebp
f01012a4:	c3                   	ret    
		page_remove(pgdir, va);
f01012a5:	83 ec 08             	sub    $0x8,%esp
f01012a8:	57                   	push   %edi
f01012a9:	ff 75 08             	push   0x8(%ebp)
f01012ac:	e8 60 ff ff ff       	call   f0101211 <page_remove>
f01012b1:	83 c4 10             	add    $0x10,%esp
f01012b4:	eb ce                	jmp    f0101284 <page_insert+0x2d>
	if(pt_entry==NULL) return -E_NO_MEM;
f01012b6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01012bb:	eb e0                	jmp    f010129d <page_insert+0x46>

f01012bd <mmio_map_region>:
{
f01012bd:	55                   	push   %ebp
f01012be:	89 e5                	mov    %esp,%ebp
f01012c0:	56                   	push   %esi
f01012c1:	53                   	push   %ebx
	void *ret =(void*) base;
f01012c2:	8b 35 00 53 12 f0    	mov    0xf0125300,%esi
	size=ROUNDUP(size,PGSIZE);
f01012c8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012cb:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01012d1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(base + size > MMIOLIM || base + size < base /*unsigned 越界*/)  panic("mmio_map_region reservation overflow");
f01012d7:	89 f0                	mov    %esi,%eax
f01012d9:	01 d8                	add    %ebx,%eax
f01012db:	72 2c                	jb     f0101309 <mmio_map_region+0x4c>
f01012dd:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01012e2:	77 25                	ja     f0101309 <mmio_map_region+0x4c>
	boot_map_region(kern_pgdir, base, size, pa, PTE_W|PTE_PCD|PTE_PWT);
f01012e4:	83 ec 08             	sub    $0x8,%esp
f01012e7:	6a 1a                	push   $0x1a
f01012e9:	ff 75 08             	push   0x8(%ebp)
f01012ec:	89 d9                	mov    %ebx,%ecx
f01012ee:	89 f2                	mov    %esi,%edx
f01012f0:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f01012f5:	e8 1c fe ff ff       	call   f0101116 <boot_map_region>
	base += size;
f01012fa:	01 1d 00 53 12 f0    	add    %ebx,0xf0125300
}
f0101300:	89 f0                	mov    %esi,%eax
f0101302:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101305:	5b                   	pop    %ebx
f0101306:	5e                   	pop    %esi
f0101307:	5d                   	pop    %ebp
f0101308:	c3                   	ret    
	if(base + size > MMIOLIM || base + size < base /*unsigned 越界*/)  panic("mmio_map_region reservation overflow");
f0101309:	83 ec 04             	sub    $0x4,%esp
f010130c:	68 f4 6d 10 f0       	push   $0xf0106df4
f0101311:	68 94 02 00 00       	push   $0x294
f0101316:	68 8f 69 10 f0       	push   $0xf010698f
f010131b:	e8 20 ed ff ff       	call   f0100040 <_panic>

f0101320 <mem_init>:
{
f0101320:	55                   	push   %ebp
f0101321:	89 e5                	mov    %esp,%ebp
f0101323:	57                   	push   %edi
f0101324:	56                   	push   %esi
f0101325:	53                   	push   %ebx
f0101326:	83 ec 4c             	sub    $0x4c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101329:	b8 15 00 00 00       	mov    $0x15,%eax
f010132e:	e8 8f f7 ff ff       	call   f0100ac2 <nvram_read>
f0101333:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101335:	b8 17 00 00 00       	mov    $0x17,%eax
f010133a:	e8 83 f7 ff ff       	call   f0100ac2 <nvram_read>
f010133f:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101341:	b8 34 00 00 00       	mov    $0x34,%eax
f0101346:	e8 77 f7 ff ff       	call   f0100ac2 <nvram_read>
	if (ext16mem)
f010134b:	c1 e0 06             	shl    $0x6,%eax
f010134e:	0f 84 d3 00 00 00    	je     f0101427 <mem_init+0x107>
		totalmem = 16 * 1024 + ext16mem;
f0101354:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101359:	89 c2                	mov    %eax,%edx
f010135b:	c1 ea 02             	shr    $0x2,%edx
f010135e:	89 15 60 72 21 f0    	mov    %edx,0xf0217260
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101364:	89 c2                	mov    %eax,%edx
f0101366:	29 da                	sub    %ebx,%edx
f0101368:	52                   	push   %edx
f0101369:	53                   	push   %ebx
f010136a:	50                   	push   %eax
f010136b:	68 1c 6e 10 f0       	push   $0xf0106e1c
f0101370:	e8 15 26 00 00       	call   f010398a <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101375:	b8 00 10 00 00       	mov    $0x1000,%eax
f010137a:	e8 6c f7 ff ff       	call   f0100aeb <boot_alloc>
f010137f:	a3 5c 72 21 f0       	mov    %eax,0xf021725c
	memset(kern_pgdir, 0, PGSIZE);
f0101384:	83 c4 0c             	add    $0xc,%esp
f0101387:	68 00 10 00 00       	push   $0x1000
f010138c:	6a 00                	push   $0x0
f010138e:	50                   	push   %eax
f010138f:	e8 52 44 00 00       	call   f01057e6 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101394:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101399:	83 c4 10             	add    $0x10,%esp
f010139c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013a1:	0f 86 90 00 00 00    	jbe    f0101437 <mem_init+0x117>
	return (physaddr_t)kva - KERNBASE;
f01013a7:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013ad:	83 ca 05             	or     $0x5,%edx
f01013b0:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = boot_alloc(npages * sizeof(struct PageInfo));//pages是页信息数组的地址
f01013b6:	a1 60 72 21 f0       	mov    0xf0217260,%eax
f01013bb:	c1 e0 03             	shl    $0x3,%eax
f01013be:	e8 28 f7 ff ff       	call   f0100aeb <boot_alloc>
f01013c3:	a3 58 72 21 f0       	mov    %eax,0xf0217258
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01013c8:	83 ec 04             	sub    $0x4,%esp
f01013cb:	8b 0d 60 72 21 f0    	mov    0xf0217260,%ecx
f01013d1:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013d8:	52                   	push   %edx
f01013d9:	6a 00                	push   $0x0
f01013db:	50                   	push   %eax
f01013dc:	e8 05 44 00 00       	call   f01057e6 <memset>
	envs = (struct Env*) boot_alloc (NENV * sizeof (struct Env) );
f01013e1:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013e6:	e8 00 f7 ff ff       	call   f0100aeb <boot_alloc>
f01013eb:	a3 70 72 21 f0       	mov    %eax,0xf0217270
	memset(envs , 0, NENV * sizeof(struct Env));
f01013f0:	83 c4 0c             	add    $0xc,%esp
f01013f3:	68 00 f0 01 00       	push   $0x1f000
f01013f8:	6a 00                	push   $0x0
f01013fa:	50                   	push   %eax
f01013fb:	e8 e6 43 00 00       	call   f01057e6 <memset>
	page_init();
f0101400:	e8 8b fa ff ff       	call   f0100e90 <page_init>
	check_page_free_list(1);
f0101405:	b8 01 00 00 00       	mov    $0x1,%eax
f010140a:	e8 93 f7 ff ff       	call   f0100ba2 <check_page_free_list>
	if (!pages)
f010140f:	83 c4 10             	add    $0x10,%esp
f0101412:	83 3d 58 72 21 f0 00 	cmpl   $0x0,0xf0217258
f0101419:	74 31                	je     f010144c <mem_init+0x12c>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010141b:	a1 6c 72 21 f0       	mov    0xf021726c,%eax
f0101420:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101425:	eb 41                	jmp    f0101468 <mem_init+0x148>
		totalmem = 1 * 1024 + extmem;
f0101427:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f010142d:	85 f6                	test   %esi,%esi
f010142f:	0f 44 c3             	cmove  %ebx,%eax
f0101432:	e9 22 ff ff ff       	jmp    f0101359 <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101437:	50                   	push   %eax
f0101438:	68 68 64 10 f0       	push   $0xf0106468
f010143d:	68 9f 00 00 00       	push   $0x9f
f0101442:	68 8f 69 10 f0       	push   $0xf010698f
f0101447:	e8 f4 eb ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f010144c:	83 ec 04             	sub    $0x4,%esp
f010144f:	68 86 6a 10 f0       	push   $0xf0106a86
f0101454:	68 2e 03 00 00       	push   $0x32e
f0101459:	68 8f 69 10 f0       	push   $0xf010698f
f010145e:	e8 dd eb ff ff       	call   f0100040 <_panic>
		++nfree;
f0101463:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101466:	8b 00                	mov    (%eax),%eax
f0101468:	85 c0                	test   %eax,%eax
f010146a:	75 f7                	jne    f0101463 <mem_init+0x143>
	assert((pp0 = page_alloc(0)));
f010146c:	83 ec 0c             	sub    $0xc,%esp
f010146f:	6a 00                	push   $0x0
f0101471:	e8 d3 fa ff ff       	call   f0100f49 <page_alloc>
f0101476:	89 c7                	mov    %eax,%edi
f0101478:	83 c4 10             	add    $0x10,%esp
f010147b:	85 c0                	test   %eax,%eax
f010147d:	0f 84 1f 02 00 00    	je     f01016a2 <mem_init+0x382>
	assert((pp1 = page_alloc(0)));
f0101483:	83 ec 0c             	sub    $0xc,%esp
f0101486:	6a 00                	push   $0x0
f0101488:	e8 bc fa ff ff       	call   f0100f49 <page_alloc>
f010148d:	89 c6                	mov    %eax,%esi
f010148f:	83 c4 10             	add    $0x10,%esp
f0101492:	85 c0                	test   %eax,%eax
f0101494:	0f 84 21 02 00 00    	je     f01016bb <mem_init+0x39b>
	assert((pp2 = page_alloc(0)));
f010149a:	83 ec 0c             	sub    $0xc,%esp
f010149d:	6a 00                	push   $0x0
f010149f:	e8 a5 fa ff ff       	call   f0100f49 <page_alloc>
f01014a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014a7:	83 c4 10             	add    $0x10,%esp
f01014aa:	85 c0                	test   %eax,%eax
f01014ac:	0f 84 22 02 00 00    	je     f01016d4 <mem_init+0x3b4>
	assert(pp1 && pp1 != pp0);
f01014b2:	39 f7                	cmp    %esi,%edi
f01014b4:	0f 84 33 02 00 00    	je     f01016ed <mem_init+0x3cd>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014bd:	39 c7                	cmp    %eax,%edi
f01014bf:	0f 84 41 02 00 00    	je     f0101706 <mem_init+0x3e6>
f01014c5:	39 c6                	cmp    %eax,%esi
f01014c7:	0f 84 39 02 00 00    	je     f0101706 <mem_init+0x3e6>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f01014cd:	8b 0d 58 72 21 f0    	mov    0xf0217258,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014d3:	8b 15 60 72 21 f0    	mov    0xf0217260,%edx
f01014d9:	c1 e2 0c             	shl    $0xc,%edx
f01014dc:	89 f8                	mov    %edi,%eax
f01014de:	29 c8                	sub    %ecx,%eax
f01014e0:	c1 f8 03             	sar    $0x3,%eax
f01014e3:	c1 e0 0c             	shl    $0xc,%eax
f01014e6:	39 d0                	cmp    %edx,%eax
f01014e8:	0f 83 31 02 00 00    	jae    f010171f <mem_init+0x3ff>
f01014ee:	89 f0                	mov    %esi,%eax
f01014f0:	29 c8                	sub    %ecx,%eax
f01014f2:	c1 f8 03             	sar    $0x3,%eax
f01014f5:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01014f8:	39 c2                	cmp    %eax,%edx
f01014fa:	0f 86 38 02 00 00    	jbe    f0101738 <mem_init+0x418>
f0101500:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101503:	29 c8                	sub    %ecx,%eax
f0101505:	c1 f8 03             	sar    $0x3,%eax
f0101508:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f010150b:	39 c2                	cmp    %eax,%edx
f010150d:	0f 86 3e 02 00 00    	jbe    f0101751 <mem_init+0x431>
	fl = page_free_list;
f0101513:	a1 6c 72 21 f0       	mov    0xf021726c,%eax
f0101518:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010151b:	c7 05 6c 72 21 f0 00 	movl   $0x0,0xf021726c
f0101522:	00 00 00 
	assert(!page_alloc(0));
f0101525:	83 ec 0c             	sub    $0xc,%esp
f0101528:	6a 00                	push   $0x0
f010152a:	e8 1a fa ff ff       	call   f0100f49 <page_alloc>
f010152f:	83 c4 10             	add    $0x10,%esp
f0101532:	85 c0                	test   %eax,%eax
f0101534:	0f 85 30 02 00 00    	jne    f010176a <mem_init+0x44a>
	page_free(pp0);
f010153a:	83 ec 0c             	sub    $0xc,%esp
f010153d:	57                   	push   %edi
f010153e:	e8 7b fa ff ff       	call   f0100fbe <page_free>
	page_free(pp1);
f0101543:	89 34 24             	mov    %esi,(%esp)
f0101546:	e8 73 fa ff ff       	call   f0100fbe <page_free>
	page_free(pp2);
f010154b:	83 c4 04             	add    $0x4,%esp
f010154e:	ff 75 d4             	push   -0x2c(%ebp)
f0101551:	e8 68 fa ff ff       	call   f0100fbe <page_free>
	assert((pp0 = page_alloc(0)));
f0101556:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010155d:	e8 e7 f9 ff ff       	call   f0100f49 <page_alloc>
f0101562:	89 c6                	mov    %eax,%esi
f0101564:	83 c4 10             	add    $0x10,%esp
f0101567:	85 c0                	test   %eax,%eax
f0101569:	0f 84 14 02 00 00    	je     f0101783 <mem_init+0x463>
	assert((pp1 = page_alloc(0)));
f010156f:	83 ec 0c             	sub    $0xc,%esp
f0101572:	6a 00                	push   $0x0
f0101574:	e8 d0 f9 ff ff       	call   f0100f49 <page_alloc>
f0101579:	89 c7                	mov    %eax,%edi
f010157b:	83 c4 10             	add    $0x10,%esp
f010157e:	85 c0                	test   %eax,%eax
f0101580:	0f 84 16 02 00 00    	je     f010179c <mem_init+0x47c>
	assert((pp2 = page_alloc(0)));
f0101586:	83 ec 0c             	sub    $0xc,%esp
f0101589:	6a 00                	push   $0x0
f010158b:	e8 b9 f9 ff ff       	call   f0100f49 <page_alloc>
f0101590:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101593:	83 c4 10             	add    $0x10,%esp
f0101596:	85 c0                	test   %eax,%eax
f0101598:	0f 84 17 02 00 00    	je     f01017b5 <mem_init+0x495>
	assert(pp1 && pp1 != pp0);
f010159e:	39 fe                	cmp    %edi,%esi
f01015a0:	0f 84 28 02 00 00    	je     f01017ce <mem_init+0x4ae>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015a9:	39 c6                	cmp    %eax,%esi
f01015ab:	0f 84 36 02 00 00    	je     f01017e7 <mem_init+0x4c7>
f01015b1:	39 c7                	cmp    %eax,%edi
f01015b3:	0f 84 2e 02 00 00    	je     f01017e7 <mem_init+0x4c7>
	assert(!page_alloc(0));
f01015b9:	83 ec 0c             	sub    $0xc,%esp
f01015bc:	6a 00                	push   $0x0
f01015be:	e8 86 f9 ff ff       	call   f0100f49 <page_alloc>
f01015c3:	83 c4 10             	add    $0x10,%esp
f01015c6:	85 c0                	test   %eax,%eax
f01015c8:	0f 85 32 02 00 00    	jne    f0101800 <mem_init+0x4e0>
f01015ce:	89 f0                	mov    %esi,%eax
f01015d0:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f01015d6:	c1 f8 03             	sar    $0x3,%eax
f01015d9:	89 c2                	mov    %eax,%edx
f01015db:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01015de:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01015e3:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f01015e9:	0f 83 2a 02 00 00    	jae    f0101819 <mem_init+0x4f9>
	memset(page2kva(pp0), 1, PGSIZE);
f01015ef:	83 ec 04             	sub    $0x4,%esp
f01015f2:	68 00 10 00 00       	push   $0x1000
f01015f7:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01015f9:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01015ff:	52                   	push   %edx
f0101600:	e8 e1 41 00 00       	call   f01057e6 <memset>
	page_free(pp0);
f0101605:	89 34 24             	mov    %esi,(%esp)
f0101608:	e8 b1 f9 ff ff       	call   f0100fbe <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010160d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101614:	e8 30 f9 ff ff       	call   f0100f49 <page_alloc>
f0101619:	83 c4 10             	add    $0x10,%esp
f010161c:	85 c0                	test   %eax,%eax
f010161e:	0f 84 07 02 00 00    	je     f010182b <mem_init+0x50b>
	assert(pp && pp0 == pp);
f0101624:	39 c6                	cmp    %eax,%esi
f0101626:	0f 85 18 02 00 00    	jne    f0101844 <mem_init+0x524>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f010162c:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101632:	c1 f8 03             	sar    $0x3,%eax
f0101635:	89 c2                	mov    %eax,%edx
f0101637:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010163a:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010163f:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0101645:	0f 83 12 02 00 00    	jae    f010185d <mem_init+0x53d>
	return (void *)(pa + KERNBASE);
f010164b:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101651:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101657:	80 38 00             	cmpb   $0x0,(%eax)
f010165a:	0f 85 0f 02 00 00    	jne    f010186f <mem_init+0x54f>
	for (i = 0; i < PGSIZE; i++)
f0101660:	83 c0 01             	add    $0x1,%eax
f0101663:	39 d0                	cmp    %edx,%eax
f0101665:	75 f0                	jne    f0101657 <mem_init+0x337>
	page_free_list = fl;
f0101667:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010166a:	a3 6c 72 21 f0       	mov    %eax,0xf021726c
	page_free(pp0);
f010166f:	83 ec 0c             	sub    $0xc,%esp
f0101672:	56                   	push   %esi
f0101673:	e8 46 f9 ff ff       	call   f0100fbe <page_free>
	page_free(pp1);
f0101678:	89 3c 24             	mov    %edi,(%esp)
f010167b:	e8 3e f9 ff ff       	call   f0100fbe <page_free>
	page_free(pp2);
f0101680:	83 c4 04             	add    $0x4,%esp
f0101683:	ff 75 d4             	push   -0x2c(%ebp)
f0101686:	e8 33 f9 ff ff       	call   f0100fbe <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010168b:	a1 6c 72 21 f0       	mov    0xf021726c,%eax
f0101690:	83 c4 10             	add    $0x10,%esp
f0101693:	85 c0                	test   %eax,%eax
f0101695:	0f 84 ed 01 00 00    	je     f0101888 <mem_init+0x568>
		--nfree;
f010169b:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010169e:	8b 00                	mov    (%eax),%eax
f01016a0:	eb f1                	jmp    f0101693 <mem_init+0x373>
	assert((pp0 = page_alloc(0)));
f01016a2:	68 a1 6a 10 f0       	push   $0xf0106aa1
f01016a7:	68 b5 69 10 f0       	push   $0xf01069b5
f01016ac:	68 36 03 00 00       	push   $0x336
f01016b1:	68 8f 69 10 f0       	push   $0xf010698f
f01016b6:	e8 85 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016bb:	68 b7 6a 10 f0       	push   $0xf0106ab7
f01016c0:	68 b5 69 10 f0       	push   $0xf01069b5
f01016c5:	68 37 03 00 00       	push   $0x337
f01016ca:	68 8f 69 10 f0       	push   $0xf010698f
f01016cf:	e8 6c e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016d4:	68 cd 6a 10 f0       	push   $0xf0106acd
f01016d9:	68 b5 69 10 f0       	push   $0xf01069b5
f01016de:	68 38 03 00 00       	push   $0x338
f01016e3:	68 8f 69 10 f0       	push   $0xf010698f
f01016e8:	e8 53 e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01016ed:	68 e3 6a 10 f0       	push   $0xf0106ae3
f01016f2:	68 b5 69 10 f0       	push   $0xf01069b5
f01016f7:	68 3b 03 00 00       	push   $0x33b
f01016fc:	68 8f 69 10 f0       	push   $0xf010698f
f0101701:	e8 3a e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101706:	68 58 6e 10 f0       	push   $0xf0106e58
f010170b:	68 b5 69 10 f0       	push   $0xf01069b5
f0101710:	68 3c 03 00 00       	push   $0x33c
f0101715:	68 8f 69 10 f0       	push   $0xf010698f
f010171a:	e8 21 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010171f:	68 f5 6a 10 f0       	push   $0xf0106af5
f0101724:	68 b5 69 10 f0       	push   $0xf01069b5
f0101729:	68 3d 03 00 00       	push   $0x33d
f010172e:	68 8f 69 10 f0       	push   $0xf010698f
f0101733:	e8 08 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101738:	68 12 6b 10 f0       	push   $0xf0106b12
f010173d:	68 b5 69 10 f0       	push   $0xf01069b5
f0101742:	68 3e 03 00 00       	push   $0x33e
f0101747:	68 8f 69 10 f0       	push   $0xf010698f
f010174c:	e8 ef e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101751:	68 2f 6b 10 f0       	push   $0xf0106b2f
f0101756:	68 b5 69 10 f0       	push   $0xf01069b5
f010175b:	68 3f 03 00 00       	push   $0x33f
f0101760:	68 8f 69 10 f0       	push   $0xf010698f
f0101765:	e8 d6 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010176a:	68 4c 6b 10 f0       	push   $0xf0106b4c
f010176f:	68 b5 69 10 f0       	push   $0xf01069b5
f0101774:	68 46 03 00 00       	push   $0x346
f0101779:	68 8f 69 10 f0       	push   $0xf010698f
f010177e:	e8 bd e8 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0101783:	68 a1 6a 10 f0       	push   $0xf0106aa1
f0101788:	68 b5 69 10 f0       	push   $0xf01069b5
f010178d:	68 4d 03 00 00       	push   $0x34d
f0101792:	68 8f 69 10 f0       	push   $0xf010698f
f0101797:	e8 a4 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010179c:	68 b7 6a 10 f0       	push   $0xf0106ab7
f01017a1:	68 b5 69 10 f0       	push   $0xf01069b5
f01017a6:	68 4e 03 00 00       	push   $0x34e
f01017ab:	68 8f 69 10 f0       	push   $0xf010698f
f01017b0:	e8 8b e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017b5:	68 cd 6a 10 f0       	push   $0xf0106acd
f01017ba:	68 b5 69 10 f0       	push   $0xf01069b5
f01017bf:	68 4f 03 00 00       	push   $0x34f
f01017c4:	68 8f 69 10 f0       	push   $0xf010698f
f01017c9:	e8 72 e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01017ce:	68 e3 6a 10 f0       	push   $0xf0106ae3
f01017d3:	68 b5 69 10 f0       	push   $0xf01069b5
f01017d8:	68 51 03 00 00       	push   $0x351
f01017dd:	68 8f 69 10 f0       	push   $0xf010698f
f01017e2:	e8 59 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017e7:	68 58 6e 10 f0       	push   $0xf0106e58
f01017ec:	68 b5 69 10 f0       	push   $0xf01069b5
f01017f1:	68 52 03 00 00       	push   $0x352
f01017f6:	68 8f 69 10 f0       	push   $0xf010698f
f01017fb:	e8 40 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101800:	68 4c 6b 10 f0       	push   $0xf0106b4c
f0101805:	68 b5 69 10 f0       	push   $0xf01069b5
f010180a:	68 53 03 00 00       	push   $0x353
f010180f:	68 8f 69 10 f0       	push   $0xf010698f
f0101814:	e8 27 e8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101819:	52                   	push   %edx
f010181a:	68 44 64 10 f0       	push   $0xf0106444
f010181f:	6a 5a                	push   $0x5a
f0101821:	68 9b 69 10 f0       	push   $0xf010699b
f0101826:	e8 15 e8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010182b:	68 5b 6b 10 f0       	push   $0xf0106b5b
f0101830:	68 b5 69 10 f0       	push   $0xf01069b5
f0101835:	68 58 03 00 00       	push   $0x358
f010183a:	68 8f 69 10 f0       	push   $0xf010698f
f010183f:	e8 fc e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101844:	68 79 6b 10 f0       	push   $0xf0106b79
f0101849:	68 b5 69 10 f0       	push   $0xf01069b5
f010184e:	68 59 03 00 00       	push   $0x359
f0101853:	68 8f 69 10 f0       	push   $0xf010698f
f0101858:	e8 e3 e7 ff ff       	call   f0100040 <_panic>
f010185d:	52                   	push   %edx
f010185e:	68 44 64 10 f0       	push   $0xf0106444
f0101863:	6a 5a                	push   $0x5a
f0101865:	68 9b 69 10 f0       	push   $0xf010699b
f010186a:	e8 d1 e7 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f010186f:	68 89 6b 10 f0       	push   $0xf0106b89
f0101874:	68 b5 69 10 f0       	push   $0xf01069b5
f0101879:	68 5c 03 00 00       	push   $0x35c
f010187e:	68 8f 69 10 f0       	push   $0xf010698f
f0101883:	e8 b8 e7 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f0101888:	85 db                	test   %ebx,%ebx
f010188a:	0f 85 3f 09 00 00    	jne    f01021cf <mem_init+0xeaf>
	cprintf("check_page_alloc() succeeded!\n");
f0101890:	83 ec 0c             	sub    $0xc,%esp
f0101893:	68 78 6e 10 f0       	push   $0xf0106e78
f0101898:	e8 ed 20 00 00       	call   f010398a <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010189d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018a4:	e8 a0 f6 ff ff       	call   f0100f49 <page_alloc>
f01018a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018ac:	83 c4 10             	add    $0x10,%esp
f01018af:	85 c0                	test   %eax,%eax
f01018b1:	0f 84 31 09 00 00    	je     f01021e8 <mem_init+0xec8>
	assert((pp1 = page_alloc(0)));
f01018b7:	83 ec 0c             	sub    $0xc,%esp
f01018ba:	6a 00                	push   $0x0
f01018bc:	e8 88 f6 ff ff       	call   f0100f49 <page_alloc>
f01018c1:	89 c3                	mov    %eax,%ebx
f01018c3:	83 c4 10             	add    $0x10,%esp
f01018c6:	85 c0                	test   %eax,%eax
f01018c8:	0f 84 33 09 00 00    	je     f0102201 <mem_init+0xee1>
	assert((pp2 = page_alloc(0)));
f01018ce:	83 ec 0c             	sub    $0xc,%esp
f01018d1:	6a 00                	push   $0x0
f01018d3:	e8 71 f6 ff ff       	call   f0100f49 <page_alloc>
f01018d8:	89 c6                	mov    %eax,%esi
f01018da:	83 c4 10             	add    $0x10,%esp
f01018dd:	85 c0                	test   %eax,%eax
f01018df:	0f 84 35 09 00 00    	je     f010221a <mem_init+0xefa>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018e5:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01018e8:	0f 84 45 09 00 00    	je     f0102233 <mem_init+0xf13>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018ee:	39 c3                	cmp    %eax,%ebx
f01018f0:	0f 84 56 09 00 00    	je     f010224c <mem_init+0xf2c>
f01018f6:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018f9:	0f 84 4d 09 00 00    	je     f010224c <mem_init+0xf2c>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018ff:	a1 6c 72 21 f0       	mov    0xf021726c,%eax
f0101904:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101907:	c7 05 6c 72 21 f0 00 	movl   $0x0,0xf021726c
f010190e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101911:	83 ec 0c             	sub    $0xc,%esp
f0101914:	6a 00                	push   $0x0
f0101916:	e8 2e f6 ff ff       	call   f0100f49 <page_alloc>
f010191b:	83 c4 10             	add    $0x10,%esp
f010191e:	85 c0                	test   %eax,%eax
f0101920:	0f 85 3f 09 00 00    	jne    f0102265 <mem_init+0xf45>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101926:	83 ec 04             	sub    $0x4,%esp
f0101929:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010192c:	50                   	push   %eax
f010192d:	6a 00                	push   $0x0
f010192f:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101935:	e8 43 f8 ff ff       	call   f010117d <page_lookup>
f010193a:	83 c4 10             	add    $0x10,%esp
f010193d:	85 c0                	test   %eax,%eax
f010193f:	0f 85 39 09 00 00    	jne    f010227e <mem_init+0xf5e>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101945:	6a 02                	push   $0x2
f0101947:	6a 00                	push   $0x0
f0101949:	53                   	push   %ebx
f010194a:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101950:	e8 02 f9 ff ff       	call   f0101257 <page_insert>
f0101955:	83 c4 10             	add    $0x10,%esp
f0101958:	85 c0                	test   %eax,%eax
f010195a:	0f 89 37 09 00 00    	jns    f0102297 <mem_init+0xf77>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101960:	83 ec 0c             	sub    $0xc,%esp
f0101963:	ff 75 d4             	push   -0x2c(%ebp)
f0101966:	e8 53 f6 ff ff       	call   f0100fbe <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010196b:	6a 02                	push   $0x2
f010196d:	6a 00                	push   $0x0
f010196f:	53                   	push   %ebx
f0101970:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101976:	e8 dc f8 ff ff       	call   f0101257 <page_insert>
f010197b:	83 c4 20             	add    $0x20,%esp
f010197e:	85 c0                	test   %eax,%eax
f0101980:	0f 85 2a 09 00 00    	jne    f01022b0 <mem_init+0xf90>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101986:	8b 3d 5c 72 21 f0    	mov    0xf021725c,%edi
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f010198c:	8b 0d 58 72 21 f0    	mov    0xf0217258,%ecx
f0101992:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101995:	8b 17                	mov    (%edi),%edx
f0101997:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010199d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019a0:	29 c8                	sub    %ecx,%eax
f01019a2:	c1 f8 03             	sar    $0x3,%eax
f01019a5:	c1 e0 0c             	shl    $0xc,%eax
f01019a8:	39 c2                	cmp    %eax,%edx
f01019aa:	0f 85 19 09 00 00    	jne    f01022c9 <mem_init+0xfa9>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019b0:	ba 00 00 00 00       	mov    $0x0,%edx
f01019b5:	89 f8                	mov    %edi,%eax
f01019b7:	e8 83 f1 ff ff       	call   f0100b3f <check_va2pa>
f01019bc:	89 c2                	mov    %eax,%edx
f01019be:	89 d8                	mov    %ebx,%eax
f01019c0:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01019c3:	c1 f8 03             	sar    $0x3,%eax
f01019c6:	c1 e0 0c             	shl    $0xc,%eax
f01019c9:	39 c2                	cmp    %eax,%edx
f01019cb:	0f 85 11 09 00 00    	jne    f01022e2 <mem_init+0xfc2>
	assert(pp1->pp_ref == 1);
f01019d1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019d6:	0f 85 1f 09 00 00    	jne    f01022fb <mem_init+0xfdb>
	assert(pp0->pp_ref == 1);
f01019dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019df:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01019e4:	0f 85 2a 09 00 00    	jne    f0102314 <mem_init+0xff4>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019ea:	6a 02                	push   $0x2
f01019ec:	68 00 10 00 00       	push   $0x1000
f01019f1:	56                   	push   %esi
f01019f2:	57                   	push   %edi
f01019f3:	e8 5f f8 ff ff       	call   f0101257 <page_insert>
f01019f8:	83 c4 10             	add    $0x10,%esp
f01019fb:	85 c0                	test   %eax,%eax
f01019fd:	0f 85 2a 09 00 00    	jne    f010232d <mem_init+0x100d>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a03:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a08:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f0101a0d:	e8 2d f1 ff ff       	call   f0100b3f <check_va2pa>
f0101a12:	89 c2                	mov    %eax,%edx
f0101a14:	89 f0                	mov    %esi,%eax
f0101a16:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101a1c:	c1 f8 03             	sar    $0x3,%eax
f0101a1f:	c1 e0 0c             	shl    $0xc,%eax
f0101a22:	39 c2                	cmp    %eax,%edx
f0101a24:	0f 85 1c 09 00 00    	jne    f0102346 <mem_init+0x1026>
	assert(pp2->pp_ref == 1);
f0101a2a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a2f:	0f 85 2a 09 00 00    	jne    f010235f <mem_init+0x103f>

	// should be no free memory
	assert(!page_alloc(0));
f0101a35:	83 ec 0c             	sub    $0xc,%esp
f0101a38:	6a 00                	push   $0x0
f0101a3a:	e8 0a f5 ff ff       	call   f0100f49 <page_alloc>
f0101a3f:	83 c4 10             	add    $0x10,%esp
f0101a42:	85 c0                	test   %eax,%eax
f0101a44:	0f 85 2e 09 00 00    	jne    f0102378 <mem_init+0x1058>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a4a:	6a 02                	push   $0x2
f0101a4c:	68 00 10 00 00       	push   $0x1000
f0101a51:	56                   	push   %esi
f0101a52:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101a58:	e8 fa f7 ff ff       	call   f0101257 <page_insert>
f0101a5d:	83 c4 10             	add    $0x10,%esp
f0101a60:	85 c0                	test   %eax,%eax
f0101a62:	0f 85 29 09 00 00    	jne    f0102391 <mem_init+0x1071>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a68:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a6d:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f0101a72:	e8 c8 f0 ff ff       	call   f0100b3f <check_va2pa>
f0101a77:	89 c2                	mov    %eax,%edx
f0101a79:	89 f0                	mov    %esi,%eax
f0101a7b:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101a81:	c1 f8 03             	sar    $0x3,%eax
f0101a84:	c1 e0 0c             	shl    $0xc,%eax
f0101a87:	39 c2                	cmp    %eax,%edx
f0101a89:	0f 85 1b 09 00 00    	jne    f01023aa <mem_init+0x108a>
	assert(pp2->pp_ref == 1);
f0101a8f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a94:	0f 85 29 09 00 00    	jne    f01023c3 <mem_init+0x10a3>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a9a:	83 ec 0c             	sub    $0xc,%esp
f0101a9d:	6a 00                	push   $0x0
f0101a9f:	e8 a5 f4 ff ff       	call   f0100f49 <page_alloc>
f0101aa4:	83 c4 10             	add    $0x10,%esp
f0101aa7:	85 c0                	test   %eax,%eax
f0101aa9:	0f 85 2d 09 00 00    	jne    f01023dc <mem_init+0x10bc>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101aaf:	8b 15 5c 72 21 f0    	mov    0xf021725c,%edx
f0101ab5:	8b 02                	mov    (%edx),%eax
f0101ab7:	89 c7                	mov    %eax,%edi
f0101ab9:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0101abf:	c1 e8 0c             	shr    $0xc,%eax
f0101ac2:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0101ac8:	0f 83 27 09 00 00    	jae    f01023f5 <mem_init+0x10d5>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ace:	83 ec 04             	sub    $0x4,%esp
f0101ad1:	6a 00                	push   $0x0
f0101ad3:	68 00 10 00 00       	push   $0x1000
f0101ad8:	52                   	push   %edx
f0101ad9:	e8 5f f5 ff ff       	call   f010103d <pgdir_walk>
f0101ade:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0101ae4:	83 c4 10             	add    $0x10,%esp
f0101ae7:	39 f8                	cmp    %edi,%eax
f0101ae9:	0f 85 1b 09 00 00    	jne    f010240a <mem_init+0x10ea>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101aef:	6a 06                	push   $0x6
f0101af1:	68 00 10 00 00       	push   $0x1000
f0101af6:	56                   	push   %esi
f0101af7:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101afd:	e8 55 f7 ff ff       	call   f0101257 <page_insert>
f0101b02:	83 c4 10             	add    $0x10,%esp
f0101b05:	85 c0                	test   %eax,%eax
f0101b07:	0f 85 16 09 00 00    	jne    f0102423 <mem_init+0x1103>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b0d:	8b 3d 5c 72 21 f0    	mov    0xf021725c,%edi
f0101b13:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b18:	89 f8                	mov    %edi,%eax
f0101b1a:	e8 20 f0 ff ff       	call   f0100b3f <check_va2pa>
f0101b1f:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101b21:	89 f0                	mov    %esi,%eax
f0101b23:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101b29:	c1 f8 03             	sar    $0x3,%eax
f0101b2c:	c1 e0 0c             	shl    $0xc,%eax
f0101b2f:	39 c2                	cmp    %eax,%edx
f0101b31:	0f 85 05 09 00 00    	jne    f010243c <mem_init+0x111c>
	assert(pp2->pp_ref == 1);
f0101b37:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b3c:	0f 85 13 09 00 00    	jne    f0102455 <mem_init+0x1135>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b42:	83 ec 04             	sub    $0x4,%esp
f0101b45:	6a 00                	push   $0x0
f0101b47:	68 00 10 00 00       	push   $0x1000
f0101b4c:	57                   	push   %edi
f0101b4d:	e8 eb f4 ff ff       	call   f010103d <pgdir_walk>
f0101b52:	83 c4 10             	add    $0x10,%esp
f0101b55:	f6 00 04             	testb  $0x4,(%eax)
f0101b58:	0f 84 10 09 00 00    	je     f010246e <mem_init+0x114e>
	assert(kern_pgdir[0] & PTE_U);
f0101b5e:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f0101b63:	f6 00 04             	testb  $0x4,(%eax)
f0101b66:	0f 84 1b 09 00 00    	je     f0102487 <mem_init+0x1167>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b6c:	6a 02                	push   $0x2
f0101b6e:	68 00 10 00 00       	push   $0x1000
f0101b73:	56                   	push   %esi
f0101b74:	50                   	push   %eax
f0101b75:	e8 dd f6 ff ff       	call   f0101257 <page_insert>
f0101b7a:	83 c4 10             	add    $0x10,%esp
f0101b7d:	85 c0                	test   %eax,%eax
f0101b7f:	0f 85 1b 09 00 00    	jne    f01024a0 <mem_init+0x1180>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b85:	83 ec 04             	sub    $0x4,%esp
f0101b88:	6a 00                	push   $0x0
f0101b8a:	68 00 10 00 00       	push   $0x1000
f0101b8f:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101b95:	e8 a3 f4 ff ff       	call   f010103d <pgdir_walk>
f0101b9a:	83 c4 10             	add    $0x10,%esp
f0101b9d:	f6 00 02             	testb  $0x2,(%eax)
f0101ba0:	0f 84 13 09 00 00    	je     f01024b9 <mem_init+0x1199>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ba6:	83 ec 04             	sub    $0x4,%esp
f0101ba9:	6a 00                	push   $0x0
f0101bab:	68 00 10 00 00       	push   $0x1000
f0101bb0:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101bb6:	e8 82 f4 ff ff       	call   f010103d <pgdir_walk>
f0101bbb:	83 c4 10             	add    $0x10,%esp
f0101bbe:	f6 00 04             	testb  $0x4,(%eax)
f0101bc1:	0f 85 0b 09 00 00    	jne    f01024d2 <mem_init+0x11b2>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101bc7:	6a 02                	push   $0x2
f0101bc9:	68 00 00 40 00       	push   $0x400000
f0101bce:	ff 75 d4             	push   -0x2c(%ebp)
f0101bd1:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101bd7:	e8 7b f6 ff ff       	call   f0101257 <page_insert>
f0101bdc:	83 c4 10             	add    $0x10,%esp
f0101bdf:	85 c0                	test   %eax,%eax
f0101be1:	0f 89 04 09 00 00    	jns    f01024eb <mem_init+0x11cb>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101be7:	6a 02                	push   $0x2
f0101be9:	68 00 10 00 00       	push   $0x1000
f0101bee:	53                   	push   %ebx
f0101bef:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101bf5:	e8 5d f6 ff ff       	call   f0101257 <page_insert>
f0101bfa:	83 c4 10             	add    $0x10,%esp
f0101bfd:	85 c0                	test   %eax,%eax
f0101bff:	0f 85 ff 08 00 00    	jne    f0102504 <mem_init+0x11e4>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c05:	83 ec 04             	sub    $0x4,%esp
f0101c08:	6a 00                	push   $0x0
f0101c0a:	68 00 10 00 00       	push   $0x1000
f0101c0f:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101c15:	e8 23 f4 ff ff       	call   f010103d <pgdir_walk>
f0101c1a:	83 c4 10             	add    $0x10,%esp
f0101c1d:	f6 00 04             	testb  $0x4,(%eax)
f0101c20:	0f 85 f7 08 00 00    	jne    f010251d <mem_init+0x11fd>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c26:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f0101c2b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c2e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c33:	e8 07 ef ff ff       	call   f0100b3f <check_va2pa>
f0101c38:	89 df                	mov    %ebx,%edi
f0101c3a:	2b 3d 58 72 21 f0    	sub    0xf0217258,%edi
f0101c40:	c1 ff 03             	sar    $0x3,%edi
f0101c43:	c1 e7 0c             	shl    $0xc,%edi
f0101c46:	39 f8                	cmp    %edi,%eax
f0101c48:	0f 85 e8 08 00 00    	jne    f0102536 <mem_init+0x1216>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c4e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c53:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c56:	e8 e4 ee ff ff       	call   f0100b3f <check_va2pa>
f0101c5b:	39 c7                	cmp    %eax,%edi
f0101c5d:	0f 85 ec 08 00 00    	jne    f010254f <mem_init+0x122f>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c63:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101c68:	0f 85 fa 08 00 00    	jne    f0102568 <mem_init+0x1248>
	assert(pp2->pp_ref == 0);
f0101c6e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c73:	0f 85 08 09 00 00    	jne    f0102581 <mem_init+0x1261>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c79:	83 ec 0c             	sub    $0xc,%esp
f0101c7c:	6a 00                	push   $0x0
f0101c7e:	e8 c6 f2 ff ff       	call   f0100f49 <page_alloc>
f0101c83:	83 c4 10             	add    $0x10,%esp
f0101c86:	39 c6                	cmp    %eax,%esi
f0101c88:	0f 85 0c 09 00 00    	jne    f010259a <mem_init+0x127a>
f0101c8e:	85 c0                	test   %eax,%eax
f0101c90:	0f 84 04 09 00 00    	je     f010259a <mem_init+0x127a>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c96:	83 ec 08             	sub    $0x8,%esp
f0101c99:	6a 00                	push   $0x0
f0101c9b:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101ca1:	e8 6b f5 ff ff       	call   f0101211 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ca6:	8b 3d 5c 72 21 f0    	mov    0xf021725c,%edi
f0101cac:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cb1:	89 f8                	mov    %edi,%eax
f0101cb3:	e8 87 ee ff ff       	call   f0100b3f <check_va2pa>
f0101cb8:	83 c4 10             	add    $0x10,%esp
f0101cbb:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cbe:	0f 85 ef 08 00 00    	jne    f01025b3 <mem_init+0x1293>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cc4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cc9:	89 f8                	mov    %edi,%eax
f0101ccb:	e8 6f ee ff ff       	call   f0100b3f <check_va2pa>
f0101cd0:	89 c2                	mov    %eax,%edx
f0101cd2:	89 d8                	mov    %ebx,%eax
f0101cd4:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101cda:	c1 f8 03             	sar    $0x3,%eax
f0101cdd:	c1 e0 0c             	shl    $0xc,%eax
f0101ce0:	39 c2                	cmp    %eax,%edx
f0101ce2:	0f 85 e4 08 00 00    	jne    f01025cc <mem_init+0x12ac>
	assert(pp1->pp_ref == 1);
f0101ce8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ced:	0f 85 f2 08 00 00    	jne    f01025e5 <mem_init+0x12c5>
	assert(pp2->pp_ref == 0);
f0101cf3:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101cf8:	0f 85 00 09 00 00    	jne    f01025fe <mem_init+0x12de>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101cfe:	6a 00                	push   $0x0
f0101d00:	68 00 10 00 00       	push   $0x1000
f0101d05:	53                   	push   %ebx
f0101d06:	57                   	push   %edi
f0101d07:	e8 4b f5 ff ff       	call   f0101257 <page_insert>
f0101d0c:	83 c4 10             	add    $0x10,%esp
f0101d0f:	85 c0                	test   %eax,%eax
f0101d11:	0f 85 00 09 00 00    	jne    f0102617 <mem_init+0x12f7>
	assert(pp1->pp_ref);
f0101d17:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d1c:	0f 84 0e 09 00 00    	je     f0102630 <mem_init+0x1310>
	assert(pp1->pp_link == NULL);
f0101d22:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101d25:	0f 85 1e 09 00 00    	jne    f0102649 <mem_init+0x1329>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d2b:	83 ec 08             	sub    $0x8,%esp
f0101d2e:	68 00 10 00 00       	push   $0x1000
f0101d33:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101d39:	e8 d3 f4 ff ff       	call   f0101211 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d3e:	8b 3d 5c 72 21 f0    	mov    0xf021725c,%edi
f0101d44:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d49:	89 f8                	mov    %edi,%eax
f0101d4b:	e8 ef ed ff ff       	call   f0100b3f <check_va2pa>
f0101d50:	83 c4 10             	add    $0x10,%esp
f0101d53:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d56:	0f 85 06 09 00 00    	jne    f0102662 <mem_init+0x1342>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d5c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d61:	89 f8                	mov    %edi,%eax
f0101d63:	e8 d7 ed ff ff       	call   f0100b3f <check_va2pa>
f0101d68:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d6b:	0f 85 0a 09 00 00    	jne    f010267b <mem_init+0x135b>
	assert(pp1->pp_ref == 0);
f0101d71:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d76:	0f 85 18 09 00 00    	jne    f0102694 <mem_init+0x1374>
	assert(pp2->pp_ref == 0);
f0101d7c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d81:	0f 85 26 09 00 00    	jne    f01026ad <mem_init+0x138d>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d87:	83 ec 0c             	sub    $0xc,%esp
f0101d8a:	6a 00                	push   $0x0
f0101d8c:	e8 b8 f1 ff ff       	call   f0100f49 <page_alloc>
f0101d91:	83 c4 10             	add    $0x10,%esp
f0101d94:	85 c0                	test   %eax,%eax
f0101d96:	0f 84 2a 09 00 00    	je     f01026c6 <mem_init+0x13a6>
f0101d9c:	39 c3                	cmp    %eax,%ebx
f0101d9e:	0f 85 22 09 00 00    	jne    f01026c6 <mem_init+0x13a6>

	// should be no free memory
	assert(!page_alloc(0));
f0101da4:	83 ec 0c             	sub    $0xc,%esp
f0101da7:	6a 00                	push   $0x0
f0101da9:	e8 9b f1 ff ff       	call   f0100f49 <page_alloc>
f0101dae:	83 c4 10             	add    $0x10,%esp
f0101db1:	85 c0                	test   %eax,%eax
f0101db3:	0f 85 26 09 00 00    	jne    f01026df <mem_init+0x13bf>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101db9:	8b 0d 5c 72 21 f0    	mov    0xf021725c,%ecx
f0101dbf:	8b 11                	mov    (%ecx),%edx
f0101dc1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101dc7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dca:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101dd0:	c1 f8 03             	sar    $0x3,%eax
f0101dd3:	c1 e0 0c             	shl    $0xc,%eax
f0101dd6:	39 c2                	cmp    %eax,%edx
f0101dd8:	0f 85 1a 09 00 00    	jne    f01026f8 <mem_init+0x13d8>
	kern_pgdir[0] = 0;
f0101dde:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101de4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101de7:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101dec:	0f 85 1f 09 00 00    	jne    f0102711 <mem_init+0x13f1>
	pp0->pp_ref = 0;
f0101df2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101df5:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101dfb:	83 ec 0c             	sub    $0xc,%esp
f0101dfe:	50                   	push   %eax
f0101dff:	e8 ba f1 ff ff       	call   f0100fbe <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e04:	83 c4 0c             	add    $0xc,%esp
f0101e07:	6a 01                	push   $0x1
f0101e09:	68 00 10 40 00       	push   $0x401000
f0101e0e:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101e14:	e8 24 f2 ff ff       	call   f010103d <pgdir_walk>
f0101e19:	89 45 d0             	mov    %eax,-0x30(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101e1c:	8b 0d 5c 72 21 f0    	mov    0xf021725c,%ecx
f0101e22:	8b 41 04             	mov    0x4(%ecx),%eax
f0101e25:	89 c7                	mov    %eax,%edi
f0101e27:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0101e2d:	8b 15 60 72 21 f0    	mov    0xf0217260,%edx
f0101e33:	c1 e8 0c             	shr    $0xc,%eax
f0101e36:	83 c4 10             	add    $0x10,%esp
f0101e39:	39 d0                	cmp    %edx,%eax
f0101e3b:	0f 83 e9 08 00 00    	jae    f010272a <mem_init+0x140a>
	assert(ptep == ptep1 + PTX(va));
f0101e41:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0101e47:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101e4a:	0f 85 ef 08 00 00    	jne    f010273f <mem_init+0x141f>
	kern_pgdir[PDX(va)] = 0;
f0101e50:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101e57:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e5a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101e60:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101e66:	c1 f8 03             	sar    $0x3,%eax
f0101e69:	89 c1                	mov    %eax,%ecx
f0101e6b:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f0101e6e:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101e73:	39 c2                	cmp    %eax,%edx
f0101e75:	0f 86 dd 08 00 00    	jbe    f0102758 <mem_init+0x1438>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e7b:	83 ec 04             	sub    $0x4,%esp
f0101e7e:	68 00 10 00 00       	push   $0x1000
f0101e83:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e88:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101e8e:	51                   	push   %ecx
f0101e8f:	e8 52 39 00 00       	call   f01057e6 <memset>
	page_free(pp0);
f0101e94:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101e97:	89 3c 24             	mov    %edi,(%esp)
f0101e9a:	e8 1f f1 ff ff       	call   f0100fbe <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e9f:	83 c4 0c             	add    $0xc,%esp
f0101ea2:	6a 01                	push   $0x1
f0101ea4:	6a 00                	push   $0x0
f0101ea6:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101eac:	e8 8c f1 ff ff       	call   f010103d <pgdir_walk>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101eb1:	89 f8                	mov    %edi,%eax
f0101eb3:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101eb9:	c1 f8 03             	sar    $0x3,%eax
f0101ebc:	89 c2                	mov    %eax,%edx
f0101ebe:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101ec1:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101ec6:	83 c4 10             	add    $0x10,%esp
f0101ec9:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0101ecf:	0f 83 95 08 00 00    	jae    f010276a <mem_init+0x144a>
	return (void *)(pa + KERNBASE);
f0101ed5:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101edb:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101ee1:	f6 00 01             	testb  $0x1,(%eax)
f0101ee4:	0f 85 92 08 00 00    	jne    f010277c <mem_init+0x145c>
	for(i=0; i<NPTENTRIES; i++)
f0101eea:	83 c0 04             	add    $0x4,%eax
f0101eed:	39 d0                	cmp    %edx,%eax
f0101eef:	75 f0                	jne    f0101ee1 <mem_init+0xbc1>
	kern_pgdir[0] = 0;
f0101ef1:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f0101ef6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101efc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eff:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101f05:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101f08:	89 0d 6c 72 21 f0    	mov    %ecx,0xf021726c

	// free the pages we took
	page_free(pp0);
f0101f0e:	83 ec 0c             	sub    $0xc,%esp
f0101f11:	50                   	push   %eax
f0101f12:	e8 a7 f0 ff ff       	call   f0100fbe <page_free>
	page_free(pp1);
f0101f17:	89 1c 24             	mov    %ebx,(%esp)
f0101f1a:	e8 9f f0 ff ff       	call   f0100fbe <page_free>
	page_free(pp2);
f0101f1f:	89 34 24             	mov    %esi,(%esp)
f0101f22:	e8 97 f0 ff ff       	call   f0100fbe <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101f27:	83 c4 08             	add    $0x8,%esp
f0101f2a:	68 01 10 00 00       	push   $0x1001
f0101f2f:	6a 00                	push   $0x0
f0101f31:	e8 87 f3 ff ff       	call   f01012bd <mmio_map_region>
f0101f36:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101f38:	83 c4 08             	add    $0x8,%esp
f0101f3b:	68 00 10 00 00       	push   $0x1000
f0101f40:	6a 00                	push   $0x0
f0101f42:	e8 76 f3 ff ff       	call   f01012bd <mmio_map_region>
f0101f47:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101f49:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f4f:	83 c4 10             	add    $0x10,%esp
f0101f52:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f58:	0f 86 37 08 00 00    	jbe    f0102795 <mem_init+0x1475>
f0101f5e:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f63:	0f 87 2c 08 00 00    	ja     f0102795 <mem_init+0x1475>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f69:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f6f:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f75:	0f 87 33 08 00 00    	ja     f01027ae <mem_init+0x148e>
f0101f7b:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f81:	0f 86 27 08 00 00    	jbe    f01027ae <mem_init+0x148e>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101f87:	89 da                	mov    %ebx,%edx
f0101f89:	09 f2                	or     %esi,%edx
f0101f8b:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101f91:	0f 85 30 08 00 00    	jne    f01027c7 <mem_init+0x14a7>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101f97:	39 c6                	cmp    %eax,%esi
f0101f99:	0f 82 41 08 00 00    	jb     f01027e0 <mem_init+0x14c0>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101f9f:	8b 3d 5c 72 21 f0    	mov    0xf021725c,%edi
f0101fa5:	89 da                	mov    %ebx,%edx
f0101fa7:	89 f8                	mov    %edi,%eax
f0101fa9:	e8 91 eb ff ff       	call   f0100b3f <check_va2pa>
f0101fae:	85 c0                	test   %eax,%eax
f0101fb0:	0f 85 43 08 00 00    	jne    f01027f9 <mem_init+0x14d9>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101fb6:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101fbc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fbf:	89 c2                	mov    %eax,%edx
f0101fc1:	89 f8                	mov    %edi,%eax
f0101fc3:	e8 77 eb ff ff       	call   f0100b3f <check_va2pa>
f0101fc8:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101fcd:	0f 85 3f 08 00 00    	jne    f0102812 <mem_init+0x14f2>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101fd3:	89 f2                	mov    %esi,%edx
f0101fd5:	89 f8                	mov    %edi,%eax
f0101fd7:	e8 63 eb ff ff       	call   f0100b3f <check_va2pa>
f0101fdc:	85 c0                	test   %eax,%eax
f0101fde:	0f 85 47 08 00 00    	jne    f010282b <mem_init+0x150b>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0101fe4:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101fea:	89 f8                	mov    %edi,%eax
f0101fec:	e8 4e eb ff ff       	call   f0100b3f <check_va2pa>
f0101ff1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ff4:	0f 85 4a 08 00 00    	jne    f0102844 <mem_init+0x1524>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0101ffa:	83 ec 04             	sub    $0x4,%esp
f0101ffd:	6a 00                	push   $0x0
f0101fff:	53                   	push   %ebx
f0102000:	57                   	push   %edi
f0102001:	e8 37 f0 ff ff       	call   f010103d <pgdir_walk>
f0102006:	83 c4 10             	add    $0x10,%esp
f0102009:	f6 00 1a             	testb  $0x1a,(%eax)
f010200c:	0f 84 4b 08 00 00    	je     f010285d <mem_init+0x153d>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102012:	83 ec 04             	sub    $0x4,%esp
f0102015:	6a 00                	push   $0x0
f0102017:	53                   	push   %ebx
f0102018:	ff 35 5c 72 21 f0    	push   0xf021725c
f010201e:	e8 1a f0 ff ff       	call   f010103d <pgdir_walk>
f0102023:	8b 00                	mov    (%eax),%eax
f0102025:	83 c4 10             	add    $0x10,%esp
f0102028:	83 e0 04             	and    $0x4,%eax
f010202b:	89 c7                	mov    %eax,%edi
f010202d:	0f 85 43 08 00 00    	jne    f0102876 <mem_init+0x1556>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102033:	83 ec 04             	sub    $0x4,%esp
f0102036:	6a 00                	push   $0x0
f0102038:	53                   	push   %ebx
f0102039:	ff 35 5c 72 21 f0    	push   0xf021725c
f010203f:	e8 f9 ef ff ff       	call   f010103d <pgdir_walk>
f0102044:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010204a:	83 c4 0c             	add    $0xc,%esp
f010204d:	6a 00                	push   $0x0
f010204f:	ff 75 d4             	push   -0x2c(%ebp)
f0102052:	ff 35 5c 72 21 f0    	push   0xf021725c
f0102058:	e8 e0 ef ff ff       	call   f010103d <pgdir_walk>
f010205d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102063:	83 c4 0c             	add    $0xc,%esp
f0102066:	6a 00                	push   $0x0
f0102068:	56                   	push   %esi
f0102069:	ff 35 5c 72 21 f0    	push   0xf021725c
f010206f:	e8 c9 ef ff ff       	call   f010103d <pgdir_walk>
f0102074:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010207a:	c7 04 24 7c 6c 10 f0 	movl   $0xf0106c7c,(%esp)
f0102081:	e8 04 19 00 00       	call   f010398a <cprintf>
	boot_map_region(kern_pgdir, UPAGES,ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE) , PADDR(pages), PTE_U | PTE_P);//但其实按照memlayout.h中的图，直接用PTSIZE也一样。因为PTSIZE远超过所需内存了，并且按图来说，其空闲内存也无他用，这里就正常写。
f0102086:	a1 58 72 21 f0       	mov    0xf0217258,%eax
	if ((uint32_t)kva < KERNBASE)
f010208b:	83 c4 10             	add    $0x10,%esp
f010208e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102093:	0f 86 f6 07 00 00    	jbe    f010288f <mem_init+0x156f>
f0102099:	8b 15 60 72 21 f0    	mov    0xf0217260,%edx
f010209f:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f01020a6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01020ac:	83 ec 08             	sub    $0x8,%esp
f01020af:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020b1:	05 00 00 00 10       	add    $0x10000000,%eax
f01020b6:	50                   	push   %eax
f01020b7:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020bc:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f01020c1:	e8 50 f0 ff ff       	call   f0101116 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f01020c6:	a1 70 72 21 f0       	mov    0xf0217270,%eax
	if ((uint32_t)kva < KERNBASE)
f01020cb:	83 c4 10             	add    $0x10,%esp
f01020ce:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020d3:	0f 86 cb 07 00 00    	jbe    f01028a4 <mem_init+0x1584>
f01020d9:	83 ec 08             	sub    $0x8,%esp
f01020dc:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020de:	05 00 00 00 10       	add    $0x10000000,%eax
f01020e3:	50                   	push   %eax
f01020e4:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01020e9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01020ee:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f01020f3:	e8 1e f0 ff ff       	call   f0101116 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01020f8:	83 c4 10             	add    $0x10,%esp
f01020fb:	b8 00 b0 11 f0       	mov    $0xf011b000,%eax
f0102100:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102105:	0f 86 ae 07 00 00    	jbe    f01028b9 <mem_init+0x1599>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f010210b:	83 ec 08             	sub    $0x8,%esp
f010210e:	6a 02                	push   $0x2
f0102110:	68 00 b0 11 00       	push   $0x11b000
f0102115:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010211a:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010211f:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f0102124:	e8 ed ef ff ff       	call   f0101116 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-KERNBASE , 0, PTE_W);
f0102129:	83 c4 08             	add    $0x8,%esp
f010212c:	6a 02                	push   $0x2
f010212e:	6a 00                	push   $0x0
f0102130:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102135:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010213a:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f010213f:	e8 d2 ef ff ff       	call   f0101116 <boot_map_region>
f0102144:	c7 45 d0 00 80 21 f0 	movl   $0xf0218000,-0x30(%ebp)
f010214b:	83 c4 10             	add    $0x10,%esp
f010214e:	bb 00 80 21 f0       	mov    $0xf0218000,%ebx
f0102153:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102158:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010215e:	0f 86 6a 07 00 00    	jbe    f01028ce <mem_init+0x15ae>
		boot_map_region(kern_pgdir, 
f0102164:	83 ec 08             	sub    $0x8,%esp
f0102167:	6a 02                	push   $0x2
f0102169:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010216f:	50                   	push   %eax
f0102170:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102175:	89 f2                	mov    %esi,%edx
f0102177:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f010217c:	e8 95 ef ff ff       	call   f0101116 <boot_map_region>
	for(size_t i = 0; i < NCPU; i++) {
f0102181:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102187:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f010218d:	83 c4 10             	add    $0x10,%esp
f0102190:	81 fb 00 80 25 f0    	cmp    $0xf0258000,%ebx
f0102196:	75 c0                	jne    f0102158 <mem_init+0xe38>
	pgdir = kern_pgdir;
f0102198:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f010219d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01021a0:	a1 60 72 21 f0       	mov    0xf0217260,%eax
f01021a5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01021a8:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01021af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021b4:	8b 35 58 72 21 f0    	mov    0xf0217258,%esi
	return (physaddr_t)kva - KERNBASE;
f01021ba:	8d 8e 00 00 00 10    	lea    0x10000000(%esi),%ecx
f01021c0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01021c3:	89 fb                	mov    %edi,%ebx
f01021c5:	89 7d c8             	mov    %edi,-0x38(%ebp)
f01021c8:	89 c7                	mov    %eax,%edi
f01021ca:	e9 2f 07 00 00       	jmp    f01028fe <mem_init+0x15de>
	assert(nfree == 0);
f01021cf:	68 93 6b 10 f0       	push   $0xf0106b93
f01021d4:	68 b5 69 10 f0       	push   $0xf01069b5
f01021d9:	68 69 03 00 00       	push   $0x369
f01021de:	68 8f 69 10 f0       	push   $0xf010698f
f01021e3:	e8 58 de ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01021e8:	68 a1 6a 10 f0       	push   $0xf0106aa1
f01021ed:	68 b5 69 10 f0       	push   $0xf01069b5
f01021f2:	68 cf 03 00 00       	push   $0x3cf
f01021f7:	68 8f 69 10 f0       	push   $0xf010698f
f01021fc:	e8 3f de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102201:	68 b7 6a 10 f0       	push   $0xf0106ab7
f0102206:	68 b5 69 10 f0       	push   $0xf01069b5
f010220b:	68 d0 03 00 00       	push   $0x3d0
f0102210:	68 8f 69 10 f0       	push   $0xf010698f
f0102215:	e8 26 de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010221a:	68 cd 6a 10 f0       	push   $0xf0106acd
f010221f:	68 b5 69 10 f0       	push   $0xf01069b5
f0102224:	68 d1 03 00 00       	push   $0x3d1
f0102229:	68 8f 69 10 f0       	push   $0xf010698f
f010222e:	e8 0d de ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0102233:	68 e3 6a 10 f0       	push   $0xf0106ae3
f0102238:	68 b5 69 10 f0       	push   $0xf01069b5
f010223d:	68 d4 03 00 00       	push   $0x3d4
f0102242:	68 8f 69 10 f0       	push   $0xf010698f
f0102247:	e8 f4 dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010224c:	68 58 6e 10 f0       	push   $0xf0106e58
f0102251:	68 b5 69 10 f0       	push   $0xf01069b5
f0102256:	68 d5 03 00 00       	push   $0x3d5
f010225b:	68 8f 69 10 f0       	push   $0xf010698f
f0102260:	e8 db dd ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102265:	68 4c 6b 10 f0       	push   $0xf0106b4c
f010226a:	68 b5 69 10 f0       	push   $0xf01069b5
f010226f:	68 dc 03 00 00       	push   $0x3dc
f0102274:	68 8f 69 10 f0       	push   $0xf010698f
f0102279:	e8 c2 dd ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010227e:	68 98 6e 10 f0       	push   $0xf0106e98
f0102283:	68 b5 69 10 f0       	push   $0xf01069b5
f0102288:	68 df 03 00 00       	push   $0x3df
f010228d:	68 8f 69 10 f0       	push   $0xf010698f
f0102292:	e8 a9 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102297:	68 d0 6e 10 f0       	push   $0xf0106ed0
f010229c:	68 b5 69 10 f0       	push   $0xf01069b5
f01022a1:	68 e2 03 00 00       	push   $0x3e2
f01022a6:	68 8f 69 10 f0       	push   $0xf010698f
f01022ab:	e8 90 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01022b0:	68 00 6f 10 f0       	push   $0xf0106f00
f01022b5:	68 b5 69 10 f0       	push   $0xf01069b5
f01022ba:	68 e6 03 00 00       	push   $0x3e6
f01022bf:	68 8f 69 10 f0       	push   $0xf010698f
f01022c4:	e8 77 dd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022c9:	68 30 6f 10 f0       	push   $0xf0106f30
f01022ce:	68 b5 69 10 f0       	push   $0xf01069b5
f01022d3:	68 e7 03 00 00       	push   $0x3e7
f01022d8:	68 8f 69 10 f0       	push   $0xf010698f
f01022dd:	e8 5e dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01022e2:	68 58 6f 10 f0       	push   $0xf0106f58
f01022e7:	68 b5 69 10 f0       	push   $0xf01069b5
f01022ec:	68 e8 03 00 00       	push   $0x3e8
f01022f1:	68 8f 69 10 f0       	push   $0xf010698f
f01022f6:	e8 45 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01022fb:	68 9e 6b 10 f0       	push   $0xf0106b9e
f0102300:	68 b5 69 10 f0       	push   $0xf01069b5
f0102305:	68 e9 03 00 00       	push   $0x3e9
f010230a:	68 8f 69 10 f0       	push   $0xf010698f
f010230f:	e8 2c dd ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102314:	68 af 6b 10 f0       	push   $0xf0106baf
f0102319:	68 b5 69 10 f0       	push   $0xf01069b5
f010231e:	68 ea 03 00 00       	push   $0x3ea
f0102323:	68 8f 69 10 f0       	push   $0xf010698f
f0102328:	e8 13 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010232d:	68 88 6f 10 f0       	push   $0xf0106f88
f0102332:	68 b5 69 10 f0       	push   $0xf01069b5
f0102337:	68 ed 03 00 00       	push   $0x3ed
f010233c:	68 8f 69 10 f0       	push   $0xf010698f
f0102341:	e8 fa dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102346:	68 c4 6f 10 f0       	push   $0xf0106fc4
f010234b:	68 b5 69 10 f0       	push   $0xf01069b5
f0102350:	68 ee 03 00 00       	push   $0x3ee
f0102355:	68 8f 69 10 f0       	push   $0xf010698f
f010235a:	e8 e1 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010235f:	68 c0 6b 10 f0       	push   $0xf0106bc0
f0102364:	68 b5 69 10 f0       	push   $0xf01069b5
f0102369:	68 ef 03 00 00       	push   $0x3ef
f010236e:	68 8f 69 10 f0       	push   $0xf010698f
f0102373:	e8 c8 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102378:	68 4c 6b 10 f0       	push   $0xf0106b4c
f010237d:	68 b5 69 10 f0       	push   $0xf01069b5
f0102382:	68 f2 03 00 00       	push   $0x3f2
f0102387:	68 8f 69 10 f0       	push   $0xf010698f
f010238c:	e8 af dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102391:	68 88 6f 10 f0       	push   $0xf0106f88
f0102396:	68 b5 69 10 f0       	push   $0xf01069b5
f010239b:	68 f5 03 00 00       	push   $0x3f5
f01023a0:	68 8f 69 10 f0       	push   $0xf010698f
f01023a5:	e8 96 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023aa:	68 c4 6f 10 f0       	push   $0xf0106fc4
f01023af:	68 b5 69 10 f0       	push   $0xf01069b5
f01023b4:	68 f6 03 00 00       	push   $0x3f6
f01023b9:	68 8f 69 10 f0       	push   $0xf010698f
f01023be:	e8 7d dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01023c3:	68 c0 6b 10 f0       	push   $0xf0106bc0
f01023c8:	68 b5 69 10 f0       	push   $0xf01069b5
f01023cd:	68 f7 03 00 00       	push   $0x3f7
f01023d2:	68 8f 69 10 f0       	push   $0xf010698f
f01023d7:	e8 64 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01023dc:	68 4c 6b 10 f0       	push   $0xf0106b4c
f01023e1:	68 b5 69 10 f0       	push   $0xf01069b5
f01023e6:	68 fb 03 00 00       	push   $0x3fb
f01023eb:	68 8f 69 10 f0       	push   $0xf010698f
f01023f0:	e8 4b dc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023f5:	57                   	push   %edi
f01023f6:	68 44 64 10 f0       	push   $0xf0106444
f01023fb:	68 fe 03 00 00       	push   $0x3fe
f0102400:	68 8f 69 10 f0       	push   $0xf010698f
f0102405:	e8 36 dc ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010240a:	68 f4 6f 10 f0       	push   $0xf0106ff4
f010240f:	68 b5 69 10 f0       	push   $0xf01069b5
f0102414:	68 ff 03 00 00       	push   $0x3ff
f0102419:	68 8f 69 10 f0       	push   $0xf010698f
f010241e:	e8 1d dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102423:	68 34 70 10 f0       	push   $0xf0107034
f0102428:	68 b5 69 10 f0       	push   $0xf01069b5
f010242d:	68 02 04 00 00       	push   $0x402
f0102432:	68 8f 69 10 f0       	push   $0xf010698f
f0102437:	e8 04 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010243c:	68 c4 6f 10 f0       	push   $0xf0106fc4
f0102441:	68 b5 69 10 f0       	push   $0xf01069b5
f0102446:	68 03 04 00 00       	push   $0x403
f010244b:	68 8f 69 10 f0       	push   $0xf010698f
f0102450:	e8 eb db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102455:	68 c0 6b 10 f0       	push   $0xf0106bc0
f010245a:	68 b5 69 10 f0       	push   $0xf01069b5
f010245f:	68 04 04 00 00       	push   $0x404
f0102464:	68 8f 69 10 f0       	push   $0xf010698f
f0102469:	e8 d2 db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010246e:	68 74 70 10 f0       	push   $0xf0107074
f0102473:	68 b5 69 10 f0       	push   $0xf01069b5
f0102478:	68 05 04 00 00       	push   $0x405
f010247d:	68 8f 69 10 f0       	push   $0xf010698f
f0102482:	e8 b9 db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102487:	68 d1 6b 10 f0       	push   $0xf0106bd1
f010248c:	68 b5 69 10 f0       	push   $0xf01069b5
f0102491:	68 06 04 00 00       	push   $0x406
f0102496:	68 8f 69 10 f0       	push   $0xf010698f
f010249b:	e8 a0 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024a0:	68 88 6f 10 f0       	push   $0xf0106f88
f01024a5:	68 b5 69 10 f0       	push   $0xf01069b5
f01024aa:	68 09 04 00 00       	push   $0x409
f01024af:	68 8f 69 10 f0       	push   $0xf010698f
f01024b4:	e8 87 db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01024b9:	68 a8 70 10 f0       	push   $0xf01070a8
f01024be:	68 b5 69 10 f0       	push   $0xf01069b5
f01024c3:	68 0a 04 00 00       	push   $0x40a
f01024c8:	68 8f 69 10 f0       	push   $0xf010698f
f01024cd:	e8 6e db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024d2:	68 dc 70 10 f0       	push   $0xf01070dc
f01024d7:	68 b5 69 10 f0       	push   $0xf01069b5
f01024dc:	68 0b 04 00 00       	push   $0x40b
f01024e1:	68 8f 69 10 f0       	push   $0xf010698f
f01024e6:	e8 55 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01024eb:	68 14 71 10 f0       	push   $0xf0107114
f01024f0:	68 b5 69 10 f0       	push   $0xf01069b5
f01024f5:	68 0e 04 00 00       	push   $0x40e
f01024fa:	68 8f 69 10 f0       	push   $0xf010698f
f01024ff:	e8 3c db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102504:	68 4c 71 10 f0       	push   $0xf010714c
f0102509:	68 b5 69 10 f0       	push   $0xf01069b5
f010250e:	68 11 04 00 00       	push   $0x411
f0102513:	68 8f 69 10 f0       	push   $0xf010698f
f0102518:	e8 23 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010251d:	68 dc 70 10 f0       	push   $0xf01070dc
f0102522:	68 b5 69 10 f0       	push   $0xf01069b5
f0102527:	68 12 04 00 00       	push   $0x412
f010252c:	68 8f 69 10 f0       	push   $0xf010698f
f0102531:	e8 0a db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102536:	68 88 71 10 f0       	push   $0xf0107188
f010253b:	68 b5 69 10 f0       	push   $0xf01069b5
f0102540:	68 15 04 00 00       	push   $0x415
f0102545:	68 8f 69 10 f0       	push   $0xf010698f
f010254a:	e8 f1 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010254f:	68 b4 71 10 f0       	push   $0xf01071b4
f0102554:	68 b5 69 10 f0       	push   $0xf01069b5
f0102559:	68 16 04 00 00       	push   $0x416
f010255e:	68 8f 69 10 f0       	push   $0xf010698f
f0102563:	e8 d8 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102568:	68 e7 6b 10 f0       	push   $0xf0106be7
f010256d:	68 b5 69 10 f0       	push   $0xf01069b5
f0102572:	68 18 04 00 00       	push   $0x418
f0102577:	68 8f 69 10 f0       	push   $0xf010698f
f010257c:	e8 bf da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102581:	68 f8 6b 10 f0       	push   $0xf0106bf8
f0102586:	68 b5 69 10 f0       	push   $0xf01069b5
f010258b:	68 19 04 00 00       	push   $0x419
f0102590:	68 8f 69 10 f0       	push   $0xf010698f
f0102595:	e8 a6 da ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f010259a:	68 e4 71 10 f0       	push   $0xf01071e4
f010259f:	68 b5 69 10 f0       	push   $0xf01069b5
f01025a4:	68 1c 04 00 00       	push   $0x41c
f01025a9:	68 8f 69 10 f0       	push   $0xf010698f
f01025ae:	e8 8d da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025b3:	68 08 72 10 f0       	push   $0xf0107208
f01025b8:	68 b5 69 10 f0       	push   $0xf01069b5
f01025bd:	68 20 04 00 00       	push   $0x420
f01025c2:	68 8f 69 10 f0       	push   $0xf010698f
f01025c7:	e8 74 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025cc:	68 b4 71 10 f0       	push   $0xf01071b4
f01025d1:	68 b5 69 10 f0       	push   $0xf01069b5
f01025d6:	68 21 04 00 00       	push   $0x421
f01025db:	68 8f 69 10 f0       	push   $0xf010698f
f01025e0:	e8 5b da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01025e5:	68 9e 6b 10 f0       	push   $0xf0106b9e
f01025ea:	68 b5 69 10 f0       	push   $0xf01069b5
f01025ef:	68 22 04 00 00       	push   $0x422
f01025f4:	68 8f 69 10 f0       	push   $0xf010698f
f01025f9:	e8 42 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025fe:	68 f8 6b 10 f0       	push   $0xf0106bf8
f0102603:	68 b5 69 10 f0       	push   $0xf01069b5
f0102608:	68 23 04 00 00       	push   $0x423
f010260d:	68 8f 69 10 f0       	push   $0xf010698f
f0102612:	e8 29 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102617:	68 2c 72 10 f0       	push   $0xf010722c
f010261c:	68 b5 69 10 f0       	push   $0xf01069b5
f0102621:	68 26 04 00 00       	push   $0x426
f0102626:	68 8f 69 10 f0       	push   $0xf010698f
f010262b:	e8 10 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102630:	68 09 6c 10 f0       	push   $0xf0106c09
f0102635:	68 b5 69 10 f0       	push   $0xf01069b5
f010263a:	68 27 04 00 00       	push   $0x427
f010263f:	68 8f 69 10 f0       	push   $0xf010698f
f0102644:	e8 f7 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102649:	68 15 6c 10 f0       	push   $0xf0106c15
f010264e:	68 b5 69 10 f0       	push   $0xf01069b5
f0102653:	68 28 04 00 00       	push   $0x428
f0102658:	68 8f 69 10 f0       	push   $0xf010698f
f010265d:	e8 de d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102662:	68 08 72 10 f0       	push   $0xf0107208
f0102667:	68 b5 69 10 f0       	push   $0xf01069b5
f010266c:	68 2c 04 00 00       	push   $0x42c
f0102671:	68 8f 69 10 f0       	push   $0xf010698f
f0102676:	e8 c5 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010267b:	68 64 72 10 f0       	push   $0xf0107264
f0102680:	68 b5 69 10 f0       	push   $0xf01069b5
f0102685:	68 2d 04 00 00       	push   $0x42d
f010268a:	68 8f 69 10 f0       	push   $0xf010698f
f010268f:	e8 ac d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102694:	68 2a 6c 10 f0       	push   $0xf0106c2a
f0102699:	68 b5 69 10 f0       	push   $0xf01069b5
f010269e:	68 2e 04 00 00       	push   $0x42e
f01026a3:	68 8f 69 10 f0       	push   $0xf010698f
f01026a8:	e8 93 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026ad:	68 f8 6b 10 f0       	push   $0xf0106bf8
f01026b2:	68 b5 69 10 f0       	push   $0xf01069b5
f01026b7:	68 2f 04 00 00       	push   $0x42f
f01026bc:	68 8f 69 10 f0       	push   $0xf010698f
f01026c1:	e8 7a d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01026c6:	68 8c 72 10 f0       	push   $0xf010728c
f01026cb:	68 b5 69 10 f0       	push   $0xf01069b5
f01026d0:	68 32 04 00 00       	push   $0x432
f01026d5:	68 8f 69 10 f0       	push   $0xf010698f
f01026da:	e8 61 d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01026df:	68 4c 6b 10 f0       	push   $0xf0106b4c
f01026e4:	68 b5 69 10 f0       	push   $0xf01069b5
f01026e9:	68 35 04 00 00       	push   $0x435
f01026ee:	68 8f 69 10 f0       	push   $0xf010698f
f01026f3:	e8 48 d9 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026f8:	68 30 6f 10 f0       	push   $0xf0106f30
f01026fd:	68 b5 69 10 f0       	push   $0xf01069b5
f0102702:	68 38 04 00 00       	push   $0x438
f0102707:	68 8f 69 10 f0       	push   $0xf010698f
f010270c:	e8 2f d9 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102711:	68 af 6b 10 f0       	push   $0xf0106baf
f0102716:	68 b5 69 10 f0       	push   $0xf01069b5
f010271b:	68 3a 04 00 00       	push   $0x43a
f0102720:	68 8f 69 10 f0       	push   $0xf010698f
f0102725:	e8 16 d9 ff ff       	call   f0100040 <_panic>
f010272a:	57                   	push   %edi
f010272b:	68 44 64 10 f0       	push   $0xf0106444
f0102730:	68 41 04 00 00       	push   $0x441
f0102735:	68 8f 69 10 f0       	push   $0xf010698f
f010273a:	e8 01 d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010273f:	68 3b 6c 10 f0       	push   $0xf0106c3b
f0102744:	68 b5 69 10 f0       	push   $0xf01069b5
f0102749:	68 42 04 00 00       	push   $0x442
f010274e:	68 8f 69 10 f0       	push   $0xf010698f
f0102753:	e8 e8 d8 ff ff       	call   f0100040 <_panic>
f0102758:	51                   	push   %ecx
f0102759:	68 44 64 10 f0       	push   $0xf0106444
f010275e:	6a 5a                	push   $0x5a
f0102760:	68 9b 69 10 f0       	push   $0xf010699b
f0102765:	e8 d6 d8 ff ff       	call   f0100040 <_panic>
f010276a:	52                   	push   %edx
f010276b:	68 44 64 10 f0       	push   $0xf0106444
f0102770:	6a 5a                	push   $0x5a
f0102772:	68 9b 69 10 f0       	push   $0xf010699b
f0102777:	e8 c4 d8 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010277c:	68 53 6c 10 f0       	push   $0xf0106c53
f0102781:	68 b5 69 10 f0       	push   $0xf01069b5
f0102786:	68 4c 04 00 00       	push   $0x44c
f010278b:	68 8f 69 10 f0       	push   $0xf010698f
f0102790:	e8 ab d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102795:	68 b0 72 10 f0       	push   $0xf01072b0
f010279a:	68 b5 69 10 f0       	push   $0xf01069b5
f010279f:	68 5c 04 00 00       	push   $0x45c
f01027a4:	68 8f 69 10 f0       	push   $0xf010698f
f01027a9:	e8 92 d8 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01027ae:	68 d8 72 10 f0       	push   $0xf01072d8
f01027b3:	68 b5 69 10 f0       	push   $0xf01069b5
f01027b8:	68 5d 04 00 00       	push   $0x45d
f01027bd:	68 8f 69 10 f0       	push   $0xf010698f
f01027c2:	e8 79 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01027c7:	68 00 73 10 f0       	push   $0xf0107300
f01027cc:	68 b5 69 10 f0       	push   $0xf01069b5
f01027d1:	68 5f 04 00 00       	push   $0x45f
f01027d6:	68 8f 69 10 f0       	push   $0xf010698f
f01027db:	e8 60 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f01027e0:	68 6a 6c 10 f0       	push   $0xf0106c6a
f01027e5:	68 b5 69 10 f0       	push   $0xf01069b5
f01027ea:	68 61 04 00 00       	push   $0x461
f01027ef:	68 8f 69 10 f0       	push   $0xf010698f
f01027f4:	e8 47 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01027f9:	68 28 73 10 f0       	push   $0xf0107328
f01027fe:	68 b5 69 10 f0       	push   $0xf01069b5
f0102803:	68 63 04 00 00       	push   $0x463
f0102808:	68 8f 69 10 f0       	push   $0xf010698f
f010280d:	e8 2e d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102812:	68 4c 73 10 f0       	push   $0xf010734c
f0102817:	68 b5 69 10 f0       	push   $0xf01069b5
f010281c:	68 64 04 00 00       	push   $0x464
f0102821:	68 8f 69 10 f0       	push   $0xf010698f
f0102826:	e8 15 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010282b:	68 7c 73 10 f0       	push   $0xf010737c
f0102830:	68 b5 69 10 f0       	push   $0xf01069b5
f0102835:	68 65 04 00 00       	push   $0x465
f010283a:	68 8f 69 10 f0       	push   $0xf010698f
f010283f:	e8 fc d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102844:	68 a0 73 10 f0       	push   $0xf01073a0
f0102849:	68 b5 69 10 f0       	push   $0xf01069b5
f010284e:	68 66 04 00 00       	push   $0x466
f0102853:	68 8f 69 10 f0       	push   $0xf010698f
f0102858:	e8 e3 d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010285d:	68 cc 73 10 f0       	push   $0xf01073cc
f0102862:	68 b5 69 10 f0       	push   $0xf01069b5
f0102867:	68 68 04 00 00       	push   $0x468
f010286c:	68 8f 69 10 f0       	push   $0xf010698f
f0102871:	e8 ca d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102876:	68 10 74 10 f0       	push   $0xf0107410
f010287b:	68 b5 69 10 f0       	push   $0xf01069b5
f0102880:	68 69 04 00 00       	push   $0x469
f0102885:	68 8f 69 10 f0       	push   $0xf010698f
f010288a:	e8 b1 d7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010288f:	50                   	push   %eax
f0102890:	68 68 64 10 f0       	push   $0xf0106468
f0102895:	68 ce 00 00 00       	push   $0xce
f010289a:	68 8f 69 10 f0       	push   $0xf010698f
f010289f:	e8 9c d7 ff ff       	call   f0100040 <_panic>
f01028a4:	50                   	push   %eax
f01028a5:	68 68 64 10 f0       	push   $0xf0106468
f01028aa:	68 d8 00 00 00       	push   $0xd8
f01028af:	68 8f 69 10 f0       	push   $0xf010698f
f01028b4:	e8 87 d7 ff ff       	call   f0100040 <_panic>
f01028b9:	50                   	push   %eax
f01028ba:	68 68 64 10 f0       	push   $0xf0106468
f01028bf:	68 e6 00 00 00       	push   $0xe6
f01028c4:	68 8f 69 10 f0       	push   $0xf010698f
f01028c9:	e8 72 d7 ff ff       	call   f0100040 <_panic>
f01028ce:	53                   	push   %ebx
f01028cf:	68 68 64 10 f0       	push   $0xf0106468
f01028d4:	68 2e 01 00 00       	push   $0x12e
f01028d9:	68 8f 69 10 f0       	push   $0xf010698f
f01028de:	e8 5d d7 ff ff       	call   f0100040 <_panic>
f01028e3:	56                   	push   %esi
f01028e4:	68 68 64 10 f0       	push   $0xf0106468
f01028e9:	68 81 03 00 00       	push   $0x381
f01028ee:	68 8f 69 10 f0       	push   $0xf010698f
f01028f3:	e8 48 d7 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f01028f8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028fe:	39 df                	cmp    %ebx,%edi
f0102900:	76 39                	jbe    f010293b <mem_init+0x161b>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102902:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102908:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010290b:	e8 2f e2 ff ff       	call   f0100b3f <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102910:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102916:	76 cb                	jbe    f01028e3 <mem_init+0x15c3>
f0102918:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010291b:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f010291e:	39 d0                	cmp    %edx,%eax
f0102920:	74 d6                	je     f01028f8 <mem_init+0x15d8>
f0102922:	68 44 74 10 f0       	push   $0xf0107444
f0102927:	68 b5 69 10 f0       	push   $0xf01069b5
f010292c:	68 81 03 00 00       	push   $0x381
f0102931:	68 8f 69 10 f0       	push   $0xf010698f
f0102936:	e8 05 d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010293b:	8b 35 70 72 21 f0    	mov    0xf0217270,%esi
f0102941:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102946:	8d 86 00 00 40 21    	lea    0x21400000(%esi),%eax
f010294c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010294f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102952:	89 da                	mov    %ebx,%edx
f0102954:	89 f8                	mov    %edi,%eax
f0102956:	e8 e4 e1 ff ff       	call   f0100b3f <check_va2pa>
f010295b:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102961:	76 46                	jbe    f01029a9 <mem_init+0x1689>
f0102963:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102966:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102969:	39 d0                	cmp    %edx,%eax
f010296b:	75 51                	jne    f01029be <mem_init+0x169e>
	for (i = 0; i < n; i += PGSIZE)
f010296d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102973:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102979:	75 d7                	jne    f0102952 <mem_init+0x1632>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010297b:	8b 7d c8             	mov    -0x38(%ebp),%edi
f010297e:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102981:	c1 e6 0c             	shl    $0xc,%esi
f0102984:	89 fb                	mov    %edi,%ebx
f0102986:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0102989:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010298c:	39 f3                	cmp    %esi,%ebx
f010298e:	73 60                	jae    f01029f0 <mem_init+0x16d0>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102990:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102996:	89 f8                	mov    %edi,%eax
f0102998:	e8 a2 e1 ff ff       	call   f0100b3f <check_va2pa>
f010299d:	39 c3                	cmp    %eax,%ebx
f010299f:	75 36                	jne    f01029d7 <mem_init+0x16b7>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029a1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029a7:	eb e3                	jmp    f010298c <mem_init+0x166c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029a9:	56                   	push   %esi
f01029aa:	68 68 64 10 f0       	push   $0xf0106468
f01029af:	68 86 03 00 00       	push   $0x386
f01029b4:	68 8f 69 10 f0       	push   $0xf010698f
f01029b9:	e8 82 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029be:	68 78 74 10 f0       	push   $0xf0107478
f01029c3:	68 b5 69 10 f0       	push   $0xf01069b5
f01029c8:	68 86 03 00 00       	push   $0x386
f01029cd:	68 8f 69 10 f0       	push   $0xf010698f
f01029d2:	e8 69 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029d7:	68 ac 74 10 f0       	push   $0xf01074ac
f01029dc:	68 b5 69 10 f0       	push   $0xf01069b5
f01029e1:	68 8a 03 00 00       	push   $0x38a
f01029e6:	68 8f 69 10 f0       	push   $0xf010698f
f01029eb:	e8 50 d6 ff ff       	call   f0100040 <_panic>
f01029f0:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01029f3:	c7 45 c0 00 80 22 00 	movl   $0x228000,-0x40(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029fa:	c7 45 c4 00 00 00 f0 	movl   $0xf0000000,-0x3c(%ebp)
f0102a01:	c7 45 c8 00 80 ff ef 	movl   $0xefff8000,-0x38(%ebp)
f0102a08:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0102a0b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102a0e:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0102a11:	8d b3 00 80 ff ff    	lea    -0x8000(%ebx),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a17:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102a1a:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0102a1d:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0102a20:	05 00 80 ff 0f       	add    $0xfff8000,%eax
f0102a25:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102a28:	89 75 bc             	mov    %esi,-0x44(%ebp)
f0102a2b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102a2e:	89 da                	mov    %ebx,%edx
f0102a30:	89 f8                	mov    %edi,%eax
f0102a32:	e8 08 e1 ff ff       	call   f0100b3f <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102a37:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102a3e:	76 67                	jbe    f0102aa7 <mem_init+0x1787>
f0102a40:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102a43:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102a46:	39 d0                	cmp    %edx,%eax
f0102a48:	75 74                	jne    f0102abe <mem_init+0x179e>
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a4a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a50:	39 f3                	cmp    %esi,%ebx
f0102a52:	75 da                	jne    f0102a2e <mem_init+0x170e>
f0102a54:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0102a57:	8b 5d c8             	mov    -0x38(%ebp),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a5a:	89 f2                	mov    %esi,%edx
f0102a5c:	89 f8                	mov    %edi,%eax
f0102a5e:	e8 dc e0 ff ff       	call   f0100b3f <check_va2pa>
f0102a63:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a66:	75 6f                	jne    f0102ad7 <mem_init+0x17b7>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a68:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102a6e:	39 de                	cmp    %ebx,%esi
f0102a70:	75 e8                	jne    f0102a5a <mem_init+0x173a>
	for (n = 0; n < NCPU; n++) {
f0102a72:	89 d8                	mov    %ebx,%eax
f0102a74:	2d 00 00 01 00       	sub    $0x10000,%eax
f0102a79:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102a7c:	81 6d c4 00 00 01 00 	subl   $0x10000,-0x3c(%ebp)
f0102a83:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102a8a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102a8d:	81 45 c0 00 80 01 00 	addl   $0x18000,-0x40(%ebp)
f0102a94:	3d 00 80 25 f0       	cmp    $0xf0258000,%eax
f0102a99:	0f 85 6f ff ff ff    	jne    f0102a0e <mem_init+0x16ee>
f0102a9f:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0102aa2:	e9 84 00 00 00       	jmp    f0102b2b <mem_init+0x180b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102aa7:	ff 75 b8             	push   -0x48(%ebp)
f0102aaa:	68 68 64 10 f0       	push   $0xf0106468
f0102aaf:	68 92 03 00 00       	push   $0x392
f0102ab4:	68 8f 69 10 f0       	push   $0xf010698f
f0102ab9:	e8 82 d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102abe:	68 d4 74 10 f0       	push   $0xf01074d4
f0102ac3:	68 b5 69 10 f0       	push   $0xf01069b5
f0102ac8:	68 91 03 00 00       	push   $0x391
f0102acd:	68 8f 69 10 f0       	push   $0xf010698f
f0102ad2:	e8 69 d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102ad7:	68 1c 75 10 f0       	push   $0xf010751c
f0102adc:	68 b5 69 10 f0       	push   $0xf01069b5
f0102ae1:	68 94 03 00 00       	push   $0x394
f0102ae6:	68 8f 69 10 f0       	push   $0xf010698f
f0102aeb:	e8 50 d5 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102af0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102af3:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102af7:	75 4e                	jne    f0102b47 <mem_init+0x1827>
f0102af9:	68 95 6c 10 f0       	push   $0xf0106c95
f0102afe:	68 b5 69 10 f0       	push   $0xf01069b5
f0102b03:	68 9f 03 00 00       	push   $0x39f
f0102b08:	68 8f 69 10 f0       	push   $0xf010698f
f0102b0d:	e8 2e d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b12:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b15:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f0102b18:	a8 01                	test   $0x1,%al
f0102b1a:	74 30                	je     f0102b4c <mem_init+0x182c>
				assert(pgdir[i] & PTE_W);
f0102b1c:	a8 02                	test   $0x2,%al
f0102b1e:	74 45                	je     f0102b65 <mem_init+0x1845>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b20:	83 c7 01             	add    $0x1,%edi
f0102b23:	81 ff 00 04 00 00    	cmp    $0x400,%edi
f0102b29:	74 6c                	je     f0102b97 <mem_init+0x1877>
		switch (i) {
f0102b2b:	8d 87 45 fc ff ff    	lea    -0x3bb(%edi),%eax
f0102b31:	83 f8 04             	cmp    $0x4,%eax
f0102b34:	76 ba                	jbe    f0102af0 <mem_init+0x17d0>
			if (i >= PDX(KERNBASE)) {
f0102b36:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102b3c:	77 d4                	ja     f0102b12 <mem_init+0x17f2>
				assert(pgdir[i] == 0);
f0102b3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b41:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f0102b45:	75 37                	jne    f0102b7e <mem_init+0x185e>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b47:	83 c7 01             	add    $0x1,%edi
f0102b4a:	eb df                	jmp    f0102b2b <mem_init+0x180b>
				assert(pgdir[i] & PTE_P);
f0102b4c:	68 95 6c 10 f0       	push   $0xf0106c95
f0102b51:	68 b5 69 10 f0       	push   $0xf01069b5
f0102b56:	68 a3 03 00 00       	push   $0x3a3
f0102b5b:	68 8f 69 10 f0       	push   $0xf010698f
f0102b60:	e8 db d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b65:	68 a6 6c 10 f0       	push   $0xf0106ca6
f0102b6a:	68 b5 69 10 f0       	push   $0xf01069b5
f0102b6f:	68 a4 03 00 00       	push   $0x3a4
f0102b74:	68 8f 69 10 f0       	push   $0xf010698f
f0102b79:	e8 c2 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102b7e:	68 b7 6c 10 f0       	push   $0xf0106cb7
f0102b83:	68 b5 69 10 f0       	push   $0xf01069b5
f0102b88:	68 a6 03 00 00       	push   $0x3a6
f0102b8d:	68 8f 69 10 f0       	push   $0xf010698f
f0102b92:	e8 a9 d4 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b97:	83 ec 0c             	sub    $0xc,%esp
f0102b9a:	68 40 75 10 f0       	push   $0xf0107540
f0102b9f:	e8 e6 0d 00 00       	call   f010398a <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102ba4:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102ba9:	83 c4 10             	add    $0x10,%esp
f0102bac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bb1:	0f 86 03 02 00 00    	jbe    f0102dba <mem_init+0x1a9a>
	return (physaddr_t)kva - KERNBASE;
f0102bb7:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f0102bbc:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102bbf:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bc4:	e8 d9 df ff ff       	call   f0100ba2 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102bc9:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102bcc:	83 e0 f3             	and    $0xfffffff3,%eax
f0102bcf:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102bd4:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102bd7:	83 ec 0c             	sub    $0xc,%esp
f0102bda:	6a 00                	push   $0x0
f0102bdc:	e8 68 e3 ff ff       	call   f0100f49 <page_alloc>
f0102be1:	89 c3                	mov    %eax,%ebx
f0102be3:	83 c4 10             	add    $0x10,%esp
f0102be6:	85 c0                	test   %eax,%eax
f0102be8:	0f 84 e1 01 00 00    	je     f0102dcf <mem_init+0x1aaf>
	assert((pp1 = page_alloc(0)));
f0102bee:	83 ec 0c             	sub    $0xc,%esp
f0102bf1:	6a 00                	push   $0x0
f0102bf3:	e8 51 e3 ff ff       	call   f0100f49 <page_alloc>
f0102bf8:	89 c7                	mov    %eax,%edi
f0102bfa:	83 c4 10             	add    $0x10,%esp
f0102bfd:	85 c0                	test   %eax,%eax
f0102bff:	0f 84 e3 01 00 00    	je     f0102de8 <mem_init+0x1ac8>
	assert((pp2 = page_alloc(0)));
f0102c05:	83 ec 0c             	sub    $0xc,%esp
f0102c08:	6a 00                	push   $0x0
f0102c0a:	e8 3a e3 ff ff       	call   f0100f49 <page_alloc>
f0102c0f:	89 c6                	mov    %eax,%esi
f0102c11:	83 c4 10             	add    $0x10,%esp
f0102c14:	85 c0                	test   %eax,%eax
f0102c16:	0f 84 e5 01 00 00    	je     f0102e01 <mem_init+0x1ae1>
	page_free(pp0);
f0102c1c:	83 ec 0c             	sub    $0xc,%esp
f0102c1f:	53                   	push   %ebx
f0102c20:	e8 99 e3 ff ff       	call   f0100fbe <page_free>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102c25:	89 f8                	mov    %edi,%eax
f0102c27:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0102c2d:	c1 f8 03             	sar    $0x3,%eax
f0102c30:	89 c2                	mov    %eax,%edx
f0102c32:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c35:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c3a:	83 c4 10             	add    $0x10,%esp
f0102c3d:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0102c43:	0f 83 d1 01 00 00    	jae    f0102e1a <mem_init+0x1afa>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c49:	83 ec 04             	sub    $0x4,%esp
f0102c4c:	68 00 10 00 00       	push   $0x1000
f0102c51:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c53:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c59:	52                   	push   %edx
f0102c5a:	e8 87 2b 00 00       	call   f01057e6 <memset>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102c5f:	89 f0                	mov    %esi,%eax
f0102c61:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0102c67:	c1 f8 03             	sar    $0x3,%eax
f0102c6a:	89 c2                	mov    %eax,%edx
f0102c6c:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c6f:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c74:	83 c4 10             	add    $0x10,%esp
f0102c77:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0102c7d:	0f 83 a9 01 00 00    	jae    f0102e2c <mem_init+0x1b0c>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c83:	83 ec 04             	sub    $0x4,%esp
f0102c86:	68 00 10 00 00       	push   $0x1000
f0102c8b:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c8d:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c93:	52                   	push   %edx
f0102c94:	e8 4d 2b 00 00       	call   f01057e6 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c99:	6a 02                	push   $0x2
f0102c9b:	68 00 10 00 00       	push   $0x1000
f0102ca0:	57                   	push   %edi
f0102ca1:	ff 35 5c 72 21 f0    	push   0xf021725c
f0102ca7:	e8 ab e5 ff ff       	call   f0101257 <page_insert>
	assert(pp1->pp_ref == 1);
f0102cac:	83 c4 20             	add    $0x20,%esp
f0102caf:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102cb4:	0f 85 84 01 00 00    	jne    f0102e3e <mem_init+0x1b1e>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cba:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cc1:	01 01 01 
f0102cc4:	0f 85 8d 01 00 00    	jne    f0102e57 <mem_init+0x1b37>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102cca:	6a 02                	push   $0x2
f0102ccc:	68 00 10 00 00       	push   $0x1000
f0102cd1:	56                   	push   %esi
f0102cd2:	ff 35 5c 72 21 f0    	push   0xf021725c
f0102cd8:	e8 7a e5 ff ff       	call   f0101257 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102cdd:	83 c4 10             	add    $0x10,%esp
f0102ce0:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102ce7:	02 02 02 
f0102cea:	0f 85 80 01 00 00    	jne    f0102e70 <mem_init+0x1b50>
	assert(pp2->pp_ref == 1);
f0102cf0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cf5:	0f 85 8e 01 00 00    	jne    f0102e89 <mem_init+0x1b69>
	assert(pp1->pp_ref == 0);
f0102cfb:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d00:	0f 85 9c 01 00 00    	jne    f0102ea2 <mem_init+0x1b82>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d06:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d0d:	03 03 03 
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102d10:	89 f0                	mov    %esi,%eax
f0102d12:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0102d18:	c1 f8 03             	sar    $0x3,%eax
f0102d1b:	89 c2                	mov    %eax,%edx
f0102d1d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d20:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d25:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0102d2b:	0f 83 8a 01 00 00    	jae    f0102ebb <mem_init+0x1b9b>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d31:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102d38:	03 03 03 
f0102d3b:	0f 85 8c 01 00 00    	jne    f0102ecd <mem_init+0x1bad>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d41:	83 ec 08             	sub    $0x8,%esp
f0102d44:	68 00 10 00 00       	push   $0x1000
f0102d49:	ff 35 5c 72 21 f0    	push   0xf021725c
f0102d4f:	e8 bd e4 ff ff       	call   f0101211 <page_remove>
	assert(pp2->pp_ref == 0);
f0102d54:	83 c4 10             	add    $0x10,%esp
f0102d57:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d5c:	0f 85 84 01 00 00    	jne    f0102ee6 <mem_init+0x1bc6>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d62:	8b 0d 5c 72 21 f0    	mov    0xf021725c,%ecx
f0102d68:	8b 11                	mov    (%ecx),%edx
f0102d6a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102d70:	89 d8                	mov    %ebx,%eax
f0102d72:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0102d78:	c1 f8 03             	sar    $0x3,%eax
f0102d7b:	c1 e0 0c             	shl    $0xc,%eax
f0102d7e:	39 c2                	cmp    %eax,%edx
f0102d80:	0f 85 79 01 00 00    	jne    f0102eff <mem_init+0x1bdf>
	kern_pgdir[0] = 0;
f0102d86:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d8c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d91:	0f 85 81 01 00 00    	jne    f0102f18 <mem_init+0x1bf8>
	pp0->pp_ref = 0;
f0102d97:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d9d:	83 ec 0c             	sub    $0xc,%esp
f0102da0:	53                   	push   %ebx
f0102da1:	e8 18 e2 ff ff       	call   f0100fbe <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102da6:	c7 04 24 d4 75 10 f0 	movl   $0xf01075d4,(%esp)
f0102dad:	e8 d8 0b 00 00       	call   f010398a <cprintf>
}
f0102db2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102db5:	5b                   	pop    %ebx
f0102db6:	5e                   	pop    %esi
f0102db7:	5f                   	pop    %edi
f0102db8:	5d                   	pop    %ebp
f0102db9:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dba:	50                   	push   %eax
f0102dbb:	68 68 64 10 f0       	push   $0xf0106468
f0102dc0:	68 01 01 00 00       	push   $0x101
f0102dc5:	68 8f 69 10 f0       	push   $0xf010698f
f0102dca:	e8 71 d2 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102dcf:	68 a1 6a 10 f0       	push   $0xf0106aa1
f0102dd4:	68 b5 69 10 f0       	push   $0xf01069b5
f0102dd9:	68 7e 04 00 00       	push   $0x47e
f0102dde:	68 8f 69 10 f0       	push   $0xf010698f
f0102de3:	e8 58 d2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102de8:	68 b7 6a 10 f0       	push   $0xf0106ab7
f0102ded:	68 b5 69 10 f0       	push   $0xf01069b5
f0102df2:	68 7f 04 00 00       	push   $0x47f
f0102df7:	68 8f 69 10 f0       	push   $0xf010698f
f0102dfc:	e8 3f d2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e01:	68 cd 6a 10 f0       	push   $0xf0106acd
f0102e06:	68 b5 69 10 f0       	push   $0xf01069b5
f0102e0b:	68 80 04 00 00       	push   $0x480
f0102e10:	68 8f 69 10 f0       	push   $0xf010698f
f0102e15:	e8 26 d2 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e1a:	52                   	push   %edx
f0102e1b:	68 44 64 10 f0       	push   $0xf0106444
f0102e20:	6a 5a                	push   $0x5a
f0102e22:	68 9b 69 10 f0       	push   $0xf010699b
f0102e27:	e8 14 d2 ff ff       	call   f0100040 <_panic>
f0102e2c:	52                   	push   %edx
f0102e2d:	68 44 64 10 f0       	push   $0xf0106444
f0102e32:	6a 5a                	push   $0x5a
f0102e34:	68 9b 69 10 f0       	push   $0xf010699b
f0102e39:	e8 02 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102e3e:	68 9e 6b 10 f0       	push   $0xf0106b9e
f0102e43:	68 b5 69 10 f0       	push   $0xf01069b5
f0102e48:	68 85 04 00 00       	push   $0x485
f0102e4d:	68 8f 69 10 f0       	push   $0xf010698f
f0102e52:	e8 e9 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e57:	68 60 75 10 f0       	push   $0xf0107560
f0102e5c:	68 b5 69 10 f0       	push   $0xf01069b5
f0102e61:	68 86 04 00 00       	push   $0x486
f0102e66:	68 8f 69 10 f0       	push   $0xf010698f
f0102e6b:	e8 d0 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e70:	68 84 75 10 f0       	push   $0xf0107584
f0102e75:	68 b5 69 10 f0       	push   $0xf01069b5
f0102e7a:	68 88 04 00 00       	push   $0x488
f0102e7f:	68 8f 69 10 f0       	push   $0xf010698f
f0102e84:	e8 b7 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102e89:	68 c0 6b 10 f0       	push   $0xf0106bc0
f0102e8e:	68 b5 69 10 f0       	push   $0xf01069b5
f0102e93:	68 89 04 00 00       	push   $0x489
f0102e98:	68 8f 69 10 f0       	push   $0xf010698f
f0102e9d:	e8 9e d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102ea2:	68 2a 6c 10 f0       	push   $0xf0106c2a
f0102ea7:	68 b5 69 10 f0       	push   $0xf01069b5
f0102eac:	68 8a 04 00 00       	push   $0x48a
f0102eb1:	68 8f 69 10 f0       	push   $0xf010698f
f0102eb6:	e8 85 d1 ff ff       	call   f0100040 <_panic>
f0102ebb:	52                   	push   %edx
f0102ebc:	68 44 64 10 f0       	push   $0xf0106444
f0102ec1:	6a 5a                	push   $0x5a
f0102ec3:	68 9b 69 10 f0       	push   $0xf010699b
f0102ec8:	e8 73 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ecd:	68 a8 75 10 f0       	push   $0xf01075a8
f0102ed2:	68 b5 69 10 f0       	push   $0xf01069b5
f0102ed7:	68 8c 04 00 00       	push   $0x48c
f0102edc:	68 8f 69 10 f0       	push   $0xf010698f
f0102ee1:	e8 5a d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102ee6:	68 f8 6b 10 f0       	push   $0xf0106bf8
f0102eeb:	68 b5 69 10 f0       	push   $0xf01069b5
f0102ef0:	68 8e 04 00 00       	push   $0x48e
f0102ef5:	68 8f 69 10 f0       	push   $0xf010698f
f0102efa:	e8 41 d1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102eff:	68 30 6f 10 f0       	push   $0xf0106f30
f0102f04:	68 b5 69 10 f0       	push   $0xf01069b5
f0102f09:	68 91 04 00 00       	push   $0x491
f0102f0e:	68 8f 69 10 f0       	push   $0xf010698f
f0102f13:	e8 28 d1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102f18:	68 af 6b 10 f0       	push   $0xf0106baf
f0102f1d:	68 b5 69 10 f0       	push   $0xf01069b5
f0102f22:	68 93 04 00 00       	push   $0x493
f0102f27:	68 8f 69 10 f0       	push   $0xf010698f
f0102f2c:	e8 0f d1 ff ff       	call   f0100040 <_panic>

f0102f31 <user_mem_check>:
{
f0102f31:	55                   	push   %ebp
f0102f32:	89 e5                	mov    %esp,%ebp
f0102f34:	57                   	push   %edi
f0102f35:	56                   	push   %esi
f0102f36:	53                   	push   %ebx
f0102f37:	83 ec 1c             	sub    $0x1c,%esp
f0102f3a:	8b 75 14             	mov    0x14(%ebp),%esi
	char * start = ROUNDDOWN((char *)va, PGSIZE);
f0102f3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102f40:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f46:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	char * end = ROUNDUP((char *)(va + len), PGSIZE);
f0102f49:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102f4c:	03 7d 10             	add    0x10(%ebp),%edi
f0102f4f:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0102f55:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for(;start<end;start+=PGSIZE){
f0102f5b:	eb 15                	jmp    f0102f72 <user_mem_check+0x41>
		    		user_mem_check_addr = (uintptr_t)va;
f0102f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f60:	a3 68 72 21 f0       	mov    %eax,0xf0217268
	      		return -E_FAULT;
f0102f65:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f6a:	eb 44                	jmp    f0102fb0 <user_mem_check+0x7f>
	for(;start<end;start+=PGSIZE){
f0102f6c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f72:	39 fb                	cmp    %edi,%ebx
f0102f74:	73 42                	jae    f0102fb8 <user_mem_check+0x87>
		pte_t * cur= pgdir_walk(env->env_pgdir, (void *)start, 0);
f0102f76:	83 ec 04             	sub    $0x4,%esp
f0102f79:	6a 00                	push   $0x0
f0102f7b:	53                   	push   %ebx
f0102f7c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f7f:	ff 70 60             	push   0x60(%eax)
f0102f82:	e8 b6 e0 ff ff       	call   f010103d <pgdir_walk>
f0102f87:	89 da                	mov    %ebx,%edx
		if( (uint32_t) start >= ULIM || cur == NULL || ( (uint32_t)(*cur) & perm) != perm /*如果pte项的user位为0*/) {
f0102f89:	83 c4 10             	add    $0x10,%esp
f0102f8c:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f92:	77 0c                	ja     f0102fa0 <user_mem_check+0x6f>
f0102f94:	85 c0                	test   %eax,%eax
f0102f96:	74 08                	je     f0102fa0 <user_mem_check+0x6f>
f0102f98:	89 f1                	mov    %esi,%ecx
f0102f9a:	23 08                	and    (%eax),%ecx
f0102f9c:	39 ce                	cmp    %ecx,%esi
f0102f9e:	74 cc                	je     f0102f6c <user_mem_check+0x3b>
			if(start == ROUNDDOWN((char *)va, PGSIZE)) {
f0102fa0:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102fa3:	74 b8                	je     f0102f5d <user_mem_check+0x2c>
	      			user_mem_check_addr = (uintptr_t)start;
f0102fa5:	89 15 68 72 21 f0    	mov    %edx,0xf0217268
	      		return -E_FAULT;
f0102fab:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102fb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fb3:	5b                   	pop    %ebx
f0102fb4:	5e                   	pop    %esi
f0102fb5:	5f                   	pop    %edi
f0102fb6:	5d                   	pop    %ebp
f0102fb7:	c3                   	ret    
	return 0;
f0102fb8:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fbd:	eb f1                	jmp    f0102fb0 <user_mem_check+0x7f>

f0102fbf <user_mem_assert>:
{
f0102fbf:	55                   	push   %ebp
f0102fc0:	89 e5                	mov    %esp,%ebp
f0102fc2:	53                   	push   %ebx
f0102fc3:	83 ec 04             	sub    $0x4,%esp
f0102fc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102fc9:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fcc:	83 c8 04             	or     $0x4,%eax
f0102fcf:	50                   	push   %eax
f0102fd0:	ff 75 10             	push   0x10(%ebp)
f0102fd3:	ff 75 0c             	push   0xc(%ebp)
f0102fd6:	53                   	push   %ebx
f0102fd7:	e8 55 ff ff ff       	call   f0102f31 <user_mem_check>
f0102fdc:	83 c4 10             	add    $0x10,%esp
f0102fdf:	85 c0                	test   %eax,%eax
f0102fe1:	78 05                	js     f0102fe8 <user_mem_assert+0x29>
}
f0102fe3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102fe6:	c9                   	leave  
f0102fe7:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102fe8:	83 ec 04             	sub    $0x4,%esp
f0102feb:	ff 35 68 72 21 f0    	push   0xf0217268
f0102ff1:	ff 73 48             	push   0x48(%ebx)
f0102ff4:	68 00 76 10 f0       	push   $0xf0107600
f0102ff9:	e8 8c 09 00 00       	call   f010398a <cprintf>
		env_destroy(env);	// may not return
f0102ffe:	89 1c 24             	mov    %ebx,(%esp)
f0103001:	e8 4a 06 00 00       	call   f0103650 <env_destroy>
f0103006:	83 c4 10             	add    $0x10,%esp
}
f0103009:	eb d8                	jmp    f0102fe3 <user_mem_assert+0x24>

f010300b <region_alloc>:
// Panic if any allocation attempt fails.
//
//为环境分配和映射物理内存
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010300b:	55                   	push   %ebp
f010300c:	89 e5                	mov    %esp,%ebp
f010300e:	57                   	push   %edi
f010300f:	56                   	push   %esi
f0103010:	53                   	push   %ebx
f0103011:	83 ec 0c             	sub    $0xc,%esp
f0103014:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	//先申请物理内存，再调用page_insert（）
	void* start = (void *)ROUNDDOWN((uint32_t)va, PGSIZE);     
f0103016:	89 d3                	mov    %edx,%ebx
f0103018:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
f010301e:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0103025:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	struct PageInfo *p = NULL;
	int r;
	for(void* i=start; i<end; i+=PGSIZE){
f010302b:	39 f3                	cmp    %esi,%ebx
f010302d:	73 5a                	jae    f0103089 <region_alloc+0x7e>
		p = page_alloc(0);
f010302f:	83 ec 0c             	sub    $0xc,%esp
f0103032:	6a 00                	push   $0x0
f0103034:	e8 10 df ff ff       	call   f0100f49 <page_alloc>
		if(p == NULL) panic("region alloc - page alloc failed.");
f0103039:	83 c4 10             	add    $0x10,%esp
f010303c:	85 c0                	test   %eax,%eax
f010303e:	74 1b                	je     f010305b <region_alloc+0x50>
		
	 	r = page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);
f0103040:	6a 06                	push   $0x6
f0103042:	53                   	push   %ebx
f0103043:	50                   	push   %eax
f0103044:	ff 77 60             	push   0x60(%edi)
f0103047:	e8 0b e2 ff ff       	call   f0101257 <page_insert>
	 	if(r != 0)  panic("region alloc - page insert error - page table couldn't be allocated");
f010304c:	83 c4 10             	add    $0x10,%esp
f010304f:	85 c0                	test   %eax,%eax
f0103051:	75 1f                	jne    f0103072 <region_alloc+0x67>
	for(void* i=start; i<end; i+=PGSIZE){
f0103053:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103059:	eb d0                	jmp    f010302b <region_alloc+0x20>
		if(p == NULL) panic("region alloc - page alloc failed.");
f010305b:	83 ec 04             	sub    $0x4,%esp
f010305e:	68 38 76 10 f0       	push   $0xf0107638
f0103063:	68 38 01 00 00       	push   $0x138
f0103068:	68 26 77 10 f0       	push   $0xf0107726
f010306d:	e8 ce cf ff ff       	call   f0100040 <_panic>
	 	if(r != 0)  panic("region alloc - page insert error - page table couldn't be allocated");
f0103072:	83 ec 04             	sub    $0x4,%esp
f0103075:	68 5c 76 10 f0       	push   $0xf010765c
f010307a:	68 3b 01 00 00       	push   $0x13b
f010307f:	68 26 77 10 f0       	push   $0xf0107726
f0103084:	e8 b7 cf ff ff       	call   f0100040 <_panic>
	}
}
f0103089:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010308c:	5b                   	pop    %ebx
f010308d:	5e                   	pop    %esi
f010308e:	5f                   	pop    %edi
f010308f:	5d                   	pop    %ebp
f0103090:	c3                   	ret    

f0103091 <envid2env>:
{
f0103091:	55                   	push   %ebp
f0103092:	89 e5                	mov    %esp,%ebp
f0103094:	56                   	push   %esi
f0103095:	53                   	push   %ebx
f0103096:	8b 75 08             	mov    0x8(%ebp),%esi
f0103099:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f010309c:	85 f6                	test   %esi,%esi
f010309e:	74 2e                	je     f01030ce <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f01030a0:	89 f3                	mov    %esi,%ebx
f01030a2:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01030a8:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01030ab:	03 1d 70 72 21 f0    	add    0xf0217270,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01030b1:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01030b5:	74 5b                	je     f0103112 <envid2env+0x81>
f01030b7:	39 73 48             	cmp    %esi,0x48(%ebx)
f01030ba:	75 62                	jne    f010311e <envid2env+0x8d>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01030bc:	84 c0                	test   %al,%al
f01030be:	75 20                	jne    f01030e0 <envid2env+0x4f>
	return 0;
f01030c0:	b8 00 00 00 00       	mov    $0x0,%eax
		*env_store = curenv;
f01030c5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01030c8:	89 1a                	mov    %ebx,(%edx)
}
f01030ca:	5b                   	pop    %ebx
f01030cb:	5e                   	pop    %esi
f01030cc:	5d                   	pop    %ebp
f01030cd:	c3                   	ret    
		*env_store = curenv;
f01030ce:	e8 09 2d 00 00       	call   f0105ddc <cpunum>
f01030d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01030d6:	8b 98 28 80 25 f0    	mov    -0xfda7fd8(%eax),%ebx
		return 0;
f01030dc:	89 f0                	mov    %esi,%eax
f01030de:	eb e5                	jmp    f01030c5 <envid2env+0x34>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01030e0:	e8 f7 2c 00 00       	call   f0105ddc <cpunum>
f01030e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01030e8:	39 98 28 80 25 f0    	cmp    %ebx,-0xfda7fd8(%eax)
f01030ee:	74 d0                	je     f01030c0 <envid2env+0x2f>
f01030f0:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01030f3:	e8 e4 2c 00 00       	call   f0105ddc <cpunum>
f01030f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01030fb:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0103101:	3b 70 48             	cmp    0x48(%eax),%esi
f0103104:	74 ba                	je     f01030c0 <envid2env+0x2f>
f0103106:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f010310b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103110:	eb b3                	jmp    f01030c5 <envid2env+0x34>
f0103112:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f0103117:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010311c:	eb a7                	jmp    f01030c5 <envid2env+0x34>
f010311e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103123:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103128:	eb 9b                	jmp    f01030c5 <envid2env+0x34>

f010312a <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f010312a:	b8 20 53 12 f0       	mov    $0xf0125320,%eax
f010312f:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103132:	b8 23 00 00 00       	mov    $0x23,%eax
f0103137:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103139:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010313b:	b8 10 00 00 00       	mov    $0x10,%eax
f0103140:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103142:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103144:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103146:	ea 4d 31 10 f0 08 00 	ljmp   $0x8,$0xf010314d
	asm volatile("lldt %0" : : "r" (sel));
f010314d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103152:	0f 00 d0             	lldt   %ax
}
f0103155:	c3                   	ret    

f0103156 <env_init>:
{
f0103156:	55                   	push   %ebp
f0103157:	89 e5                	mov    %esp,%ebp
f0103159:	83 ec 08             	sub    $0x8,%esp
	env_free_list=envs;
f010315c:	a1 70 72 21 f0       	mov    0xf0217270,%eax
f0103161:	a3 74 72 21 f0       	mov    %eax,0xf0217274
f0103166:	83 c0 7c             	add    $0x7c,%eax
	for(int i=0;i<NENV;i++){
f0103169:	ba 00 00 00 00       	mov    $0x0,%edx
f010316e:	eb 11                	jmp    f0103181 <env_init+0x2b>
f0103170:	89 40 c8             	mov    %eax,-0x38(%eax)
f0103173:	83 c2 01             	add    $0x1,%edx
f0103176:	83 c0 7c             	add    $0x7c,%eax
f0103179:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f010317f:	74 1d                	je     f010319e <env_init+0x48>
		envs[i].env_status = ENV_FREE;
f0103181:	c7 40 d8 00 00 00 00 	movl   $0x0,-0x28(%eax)
		envs[i].env_id=0;
f0103188:	c7 40 cc 00 00 00 00 	movl   $0x0,-0x34(%eax)
		if(i!=NENV-1) envs[i].env_link= &envs[i+1];
f010318f:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0103195:	75 d9                	jne    f0103170 <env_init+0x1a>
f0103197:	c7 40 c8 00 00 00 00 	movl   $0x0,-0x38(%eax)
	env_init_percpu();
f010319e:	e8 87 ff ff ff       	call   f010312a <env_init_percpu>
}
f01031a3:	c9                   	leave  
f01031a4:	c3                   	ret    

f01031a5 <env_alloc>:
{
f01031a5:	55                   	push   %ebp
f01031a6:	89 e5                	mov    %esp,%ebp
f01031a8:	53                   	push   %ebx
f01031a9:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f01031ac:	8b 1d 74 72 21 f0    	mov    0xf0217274,%ebx
f01031b2:	85 db                	test   %ebx,%ebx
f01031b4:	0f 84 59 01 00 00    	je     f0103313 <env_alloc+0x16e>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01031ba:	83 ec 0c             	sub    $0xc,%esp
f01031bd:	6a 01                	push   $0x1
f01031bf:	e8 85 dd ff ff       	call   f0100f49 <page_alloc>
f01031c4:	83 c4 10             	add    $0x10,%esp
f01031c7:	85 c0                	test   %eax,%eax
f01031c9:	0f 84 4b 01 00 00    	je     f010331a <env_alloc+0x175>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f01031cf:	89 c2                	mov    %eax,%edx
f01031d1:	2b 15 58 72 21 f0    	sub    0xf0217258,%edx
f01031d7:	c1 fa 03             	sar    $0x3,%edx
f01031da:	89 d1                	mov    %edx,%ecx
f01031dc:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f01031df:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
f01031e5:	3b 15 60 72 21 f0    	cmp    0xf0217260,%edx
f01031eb:	0f 83 fb 00 00 00    	jae    f01032ec <env_alloc+0x147>
	return (void *)(pa + KERNBASE);
f01031f1:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f01031f7:	89 4b 60             	mov    %ecx,0x60(%ebx)
	p->pp_ref++;
f01031fa:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01031ff:	b8 00 00 00 00       	mov    $0x0,%eax
		e->env_pgdir[i] = 0;        
f0103204:	8b 53 60             	mov    0x60(%ebx),%edx
f0103207:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	for(i = 0; i < PDX(UTOP); i++) {
f010320e:	83 c0 04             	add    $0x4,%eax
f0103211:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103216:	75 ec                	jne    f0103204 <env_alloc+0x5f>
		e->env_pgdir[i] = kern_pgdir[i];
f0103218:	8b 15 5c 72 21 f0    	mov    0xf021725c,%edx
f010321e:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103221:	8b 53 60             	mov    0x60(%ebx),%edx
f0103224:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
	for(i = PDX(UTOP); i < NPDENTRIES; i++) {//NPDENTRIES宏在mmu.h中定义，为1024
f0103227:	83 c0 04             	add    $0x4,%eax
f010322a:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010322f:	75 e7                	jne    f0103218 <env_alloc+0x73>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103231:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103234:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103239:	0f 86 bf 00 00 00    	jbe    f01032fe <env_alloc+0x159>
	return (physaddr_t)kva - KERNBASE;
f010323f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103245:	83 ca 05             	or     $0x5,%edx
f0103248:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010324e:	8b 43 48             	mov    0x48(%ebx),%eax
f0103251:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f0103256:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010325b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103260:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103263:	89 da                	mov    %ebx,%edx
f0103265:	2b 15 70 72 21 f0    	sub    0xf0217270,%edx
f010326b:	c1 fa 02             	sar    $0x2,%edx
f010326e:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103274:	09 d0                	or     %edx,%eax
f0103276:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103279:	8b 45 0c             	mov    0xc(%ebp),%eax
f010327c:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010327f:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103286:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010328d:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103294:	83 ec 04             	sub    $0x4,%esp
f0103297:	6a 44                	push   $0x44
f0103299:	6a 00                	push   $0x0
f010329b:	53                   	push   %ebx
f010329c:	e8 45 25 00 00       	call   f01057e6 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f01032a1:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01032a7:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01032ad:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01032b3:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01032ba:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f01032c0:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f01032c7:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f01032ce:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f01032d2:	8b 43 44             	mov    0x44(%ebx),%eax
f01032d5:	a3 74 72 21 f0       	mov    %eax,0xf0217274
	*newenv_store = e;
f01032da:	8b 45 08             	mov    0x8(%ebp),%eax
f01032dd:	89 18                	mov    %ebx,(%eax)
	return 0;
f01032df:	83 c4 10             	add    $0x10,%esp
f01032e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01032ea:	c9                   	leave  
f01032eb:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032ec:	51                   	push   %ecx
f01032ed:	68 44 64 10 f0       	push   $0xf0106444
f01032f2:	6a 5a                	push   $0x5a
f01032f4:	68 9b 69 10 f0       	push   $0xf010699b
f01032f9:	e8 42 cd ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032fe:	50                   	push   %eax
f01032ff:	68 68 64 10 f0       	push   $0xf0106468
f0103304:	68 d1 00 00 00       	push   $0xd1
f0103309:	68 26 77 10 f0       	push   $0xf0107726
f010330e:	e8 2d cd ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f0103313:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103318:	eb cd                	jmp    f01032e7 <env_alloc+0x142>
		return -E_NO_MEM;
f010331a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010331f:	eb c6                	jmp    f01032e7 <env_alloc+0x142>

f0103321 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//用env_alloc分配一个环境，并调用load_icode将ELF二进制文件加载到环境中。
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103321:	55                   	push   %ebp
f0103322:	89 e5                	mov    %esp,%ebp
f0103324:	57                   	push   %edi
f0103325:	56                   	push   %esi
f0103326:	53                   	push   %ebx
f0103327:	83 ec 34             	sub    $0x34,%esp
f010332a:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 5: Your code here.


	// LAB 3: Your code here.
	//使用env_alloc分配一个env，根据注释很简单。
	struct Env * env=NULL;
f010332d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&env, 0);
f0103334:	6a 00                	push   $0x0
f0103336:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103339:	50                   	push   %eax
f010333a:	e8 66 fe ff ff       	call   f01031a5 <env_alloc>
	if(r < 0)  panic("env_create error: %e", r);//使用lab中示例的panic。
f010333f:	83 c4 10             	add    $0x10,%esp
f0103342:	85 c0                	test   %eax,%eax
f0103344:	78 44                	js     f010338a <env_create+0x69>
	//通过修改EFLAGS寄存器中的IOPL位，赋予文件系统环境 I/O权限  
	if (type == ENV_TYPE_FS)  env->env_tf.tf_eflags |= FL_IOPL_MASK;
f0103346:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f010334a:	74 53                	je     f010339f <env_create+0x7e>
	
	load_icode(env,binary);
f010334c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010334f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if(e == NULL || binary == NULL)  panic("load_icode: invalid environment or binary\n");
f0103352:	85 c0                	test   %eax,%eax
f0103354:	74 55                	je     f01033ab <env_create+0x8a>
f0103356:	85 ff                	test   %edi,%edi
f0103358:	74 51                	je     f01033ab <env_create+0x8a>
	if(ElfHeader->e_magic != ELF_MAGIC) panic("load_icode error : binary is invalid elf format\n");
f010335a:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103360:	75 60                	jne    f01033c2 <env_create+0xa1>
	struct Proghdr * ph = (struct Proghdr *) ((uint8_t *) ElfHeader + ElfHeader->e_phoff);
f0103362:	89 fb                	mov    %edi,%ebx
f0103364:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr * eph = ph + ElfHeader->e_phnum;
f0103367:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f010336b:	c1 e6 05             	shl    $0x5,%esi
f010336e:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));//lcr3(uint32_t val)在inc/x86.h中定义 ，其将val值赋给cr3寄存器(即页目录基寄存器)。
f0103370:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103373:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103376:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010337b:	76 5c                	jbe    f01033d9 <env_create+0xb8>
	return (physaddr_t)kva - KERNBASE;
f010337d:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f0103382:	0f 22 d8             	mov    %eax,%cr3
}
f0103385:	e9 a0 00 00 00       	jmp    f010342a <env_create+0x109>
	if(r < 0)  panic("env_create error: %e", r);//使用lab中示例的panic。
f010338a:	50                   	push   %eax
f010338b:	68 31 77 10 f0       	push   $0xf0107731
f0103390:	68 ab 01 00 00       	push   $0x1ab
f0103395:	68 26 77 10 f0       	push   $0xf0107726
f010339a:	e8 a1 cc ff ff       	call   f0100040 <_panic>
	if (type == ENV_TYPE_FS)  env->env_tf.tf_eflags |= FL_IOPL_MASK;
f010339f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033a2:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
f01033a9:	eb a1                	jmp    f010334c <env_create+0x2b>
	if(e == NULL || binary == NULL)  panic("load_icode: invalid environment or binary\n");
f01033ab:	83 ec 04             	sub    $0x4,%esp
f01033ae:	68 a0 76 10 f0       	push   $0xf01076a0
f01033b3:	68 79 01 00 00       	push   $0x179
f01033b8:	68 26 77 10 f0       	push   $0xf0107726
f01033bd:	e8 7e cc ff ff       	call   f0100040 <_panic>
	if(ElfHeader->e_magic != ELF_MAGIC) panic("load_icode error : binary is invalid elf format\n");
f01033c2:	83 ec 04             	sub    $0x4,%esp
f01033c5:	68 cc 76 10 f0       	push   $0xf01076cc
f01033ca:	68 7e 01 00 00       	push   $0x17e
f01033cf:	68 26 77 10 f0       	push   $0xf0107726
f01033d4:	e8 67 cc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033d9:	50                   	push   %eax
f01033da:	68 68 64 10 f0       	push   $0xf0106468
f01033df:	68 83 01 00 00       	push   $0x183
f01033e4:	68 26 77 10 f0       	push   $0xf0107726
f01033e9:	e8 52 cc ff ff       	call   f0100040 <_panic>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);//为 环境e 分配和映射物理内存
f01033ee:	8b 53 08             	mov    0x8(%ebx),%edx
f01033f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033f4:	e8 12 fc ff ff       	call   f010300b <region_alloc>
			memmove((void*)ph->p_va, (uint8_t *)binary + ph->p_offset, ph->p_filesz);//移动binary到虚拟内存  (mem等函数全在lib/string.c中定义)
f01033f9:	83 ec 04             	sub    $0x4,%esp
f01033fc:	ff 73 10             	push   0x10(%ebx)
f01033ff:	89 f8                	mov    %edi,%eax
f0103401:	03 43 04             	add    0x4(%ebx),%eax
f0103404:	50                   	push   %eax
f0103405:	ff 73 08             	push   0x8(%ebx)
f0103408:	e8 1f 24 00 00       	call   f010582c <memmove>
			memset((void*)ph->p_va+ph->p_filesz, 0, ph->p_memsz-ph->p_filesz);//剩余内存置0
f010340d:	8b 43 10             	mov    0x10(%ebx),%eax
f0103410:	83 c4 0c             	add    $0xc,%esp
f0103413:	8b 53 14             	mov    0x14(%ebx),%edx
f0103416:	29 c2                	sub    %eax,%edx
f0103418:	52                   	push   %edx
f0103419:	6a 00                	push   $0x0
f010341b:	03 43 08             	add    0x8(%ebx),%eax
f010341e:	50                   	push   %eax
f010341f:	e8 c2 23 00 00       	call   f01057e6 <memset>
f0103424:	83 c4 10             	add    $0x10,%esp
	for(; ph < eph; ph++) {
f0103427:	83 c3 20             	add    $0x20,%ebx
f010342a:	39 de                	cmp    %ebx,%esi
f010342c:	76 24                	jbe    f0103452 <env_create+0x131>
		if(ph->p_type == ELF_PROG_LOAD){//注释要求
f010342e:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103431:	75 f4                	jne    f0103427 <env_create+0x106>
			if(ph->p_memsz < ph->p_filesz)
f0103433:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103436:	3b 4b 10             	cmp    0x10(%ebx),%ecx
f0103439:	73 b3                	jae    f01033ee <env_create+0xcd>
				panic("load_icode error: p_memsz < p_filesz\n");
f010343b:	83 ec 04             	sub    $0x4,%esp
f010343e:	68 00 77 10 f0       	push   $0xf0107700
f0103443:	68 88 01 00 00       	push   $0x188
f0103448:	68 26 77 10 f0       	push   $0xf0107726
f010344d:	e8 ee cb ff ff       	call   f0100040 <_panic>
	lcr3(PADDR(kern_pgdir));//再切换回内核的页目录，我感觉要在分配栈前，一些博客与我有出入。
f0103452:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103457:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010345c:	76 33                	jbe    f0103491 <env_create+0x170>
	return (physaddr_t)kva - KERNBASE;
f010345e:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f0103463:	0f 22 d8             	mov    %eax,%cr3
	e->env_tf.tf_eip = ElfHeader->e_entry;//这句我也不确定。但我感觉大致思路是由于段设计在JOS约等于没有（因为linux就约等于没有，之前lab中介绍有提到），而根据注释要修改cs:ip,所以就之修改了eip。
f0103466:	8b 47 18             	mov    0x18(%edi),%eax
f0103469:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010346c:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void*)(USTACKTOP-PGSIZE), PGSIZE);
f010346f:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103474:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103479:	89 f8                	mov    %edi,%eax
f010347b:	e8 8b fb ff ff       	call   f010300b <region_alloc>
	env->env_type=type;
f0103480:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103483:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103486:	89 78 50             	mov    %edi,0x50(%eax)
}
f0103489:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010348c:	5b                   	pop    %ebx
f010348d:	5e                   	pop    %esi
f010348e:	5f                   	pop    %edi
f010348f:	5d                   	pop    %ebp
f0103490:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103491:	50                   	push   %eax
f0103492:	68 68 64 10 f0       	push   $0xf0106468
f0103497:	68 8f 01 00 00       	push   $0x18f
f010349c:	68 26 77 10 f0       	push   $0xf0107726
f01034a1:	e8 9a cb ff ff       	call   f0100040 <_panic>

f01034a6 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01034a6:	55                   	push   %ebp
f01034a7:	89 e5                	mov    %esp,%ebp
f01034a9:	57                   	push   %edi
f01034aa:	56                   	push   %esi
f01034ab:	53                   	push   %ebx
f01034ac:	83 ec 1c             	sub    $0x1c,%esp
f01034af:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01034b2:	e8 25 29 00 00       	call   f0105ddc <cpunum>
f01034b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01034ba:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01034c1:	39 b8 28 80 25 f0    	cmp    %edi,-0xfda7fd8(%eax)
f01034c7:	0f 85 b3 00 00 00    	jne    f0103580 <env_free+0xda>
		lcr3(PADDR(kern_pgdir));
f01034cd:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
	if ((uint32_t)kva < KERNBASE)
f01034d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034d7:	76 14                	jbe    f01034ed <env_free+0x47>
	return (physaddr_t)kva - KERNBASE;
f01034d9:	05 00 00 00 10       	add    $0x10000000,%eax
f01034de:	0f 22 d8             	mov    %eax,%cr3
}
f01034e1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01034e8:	e9 93 00 00 00       	jmp    f0103580 <env_free+0xda>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034ed:	50                   	push   %eax
f01034ee:	68 68 64 10 f0       	push   $0xf0106468
f01034f3:	68 c1 01 00 00       	push   $0x1c1
f01034f8:	68 26 77 10 f0       	push   $0xf0107726
f01034fd:	e8 3e cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103502:	56                   	push   %esi
f0103503:	68 44 64 10 f0       	push   $0xf0106444
f0103508:	68 d0 01 00 00       	push   $0x1d0
f010350d:	68 26 77 10 f0       	push   $0xf0107726
f0103512:	e8 29 cb ff ff       	call   f0100040 <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103517:	83 c6 04             	add    $0x4,%esi
f010351a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103520:	81 fb 00 00 40 00    	cmp    $0x400000,%ebx
f0103526:	74 1b                	je     f0103543 <env_free+0x9d>
			if (pt[pteno] & PTE_P)
f0103528:	f6 06 01             	testb  $0x1,(%esi)
f010352b:	74 ea                	je     f0103517 <env_free+0x71>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010352d:	83 ec 08             	sub    $0x8,%esp
f0103530:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103533:	09 d8                	or     %ebx,%eax
f0103535:	50                   	push   %eax
f0103536:	ff 77 60             	push   0x60(%edi)
f0103539:	e8 d3 dc ff ff       	call   f0101211 <page_remove>
f010353e:	83 c4 10             	add    $0x10,%esp
f0103541:	eb d4                	jmp    f0103517 <env_free+0x71>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103543:	8b 47 60             	mov    0x60(%edi),%eax
f0103546:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103549:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f0103550:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103553:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0103559:	73 65                	jae    f01035c0 <env_free+0x11a>
		page_decref(pa2page(pa));
f010355b:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010355e:	a1 58 72 21 f0       	mov    0xf0217258,%eax
f0103563:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103566:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103569:	50                   	push   %eax
f010356a:	e8 a5 da ff ff       	call   f0101014 <page_decref>
f010356f:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103572:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0103576:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103579:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f010357e:	74 54                	je     f01035d4 <env_free+0x12e>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103580:	8b 47 60             	mov    0x60(%edi),%eax
f0103583:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103586:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f0103589:	a8 01                	test   $0x1,%al
f010358b:	74 e5                	je     f0103572 <env_free+0xcc>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010358d:	89 c6                	mov    %eax,%esi
f010358f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0103595:	c1 e8 0c             	shr    $0xc,%eax
f0103598:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010359b:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f01035a1:	0f 83 5b ff ff ff    	jae    f0103502 <env_free+0x5c>
	return (void *)(pa + KERNBASE);
f01035a7:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f01035ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035b0:	c1 e0 14             	shl    $0x14,%eax
f01035b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01035b6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01035bb:	e9 68 ff ff ff       	jmp    f0103528 <env_free+0x82>
		panic("pa2page called with invalid pa");
f01035c0:	83 ec 04             	sub    $0x4,%esp
f01035c3:	68 d4 6d 10 f0       	push   $0xf0106dd4
f01035c8:	6a 52                	push   $0x52
f01035ca:	68 9b 69 10 f0       	push   $0xf010699b
f01035cf:	e8 6c ca ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01035d4:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f01035d7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035dc:	76 49                	jbe    f0103627 <env_free+0x181>
	e->env_pgdir = 0;
f01035de:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01035e5:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f01035ea:	c1 e8 0c             	shr    $0xc,%eax
f01035ed:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f01035f3:	73 47                	jae    f010363c <env_free+0x196>
	page_decref(pa2page(pa));
f01035f5:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01035f8:	8b 15 58 72 21 f0    	mov    0xf0217258,%edx
f01035fe:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103601:	50                   	push   %eax
f0103602:	e8 0d da ff ff       	call   f0101014 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103607:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010360e:	a1 74 72 21 f0       	mov    0xf0217274,%eax
f0103613:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103616:	89 3d 74 72 21 f0    	mov    %edi,0xf0217274
}
f010361c:	83 c4 10             	add    $0x10,%esp
f010361f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103622:	5b                   	pop    %ebx
f0103623:	5e                   	pop    %esi
f0103624:	5f                   	pop    %edi
f0103625:	5d                   	pop    %ebp
f0103626:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103627:	50                   	push   %eax
f0103628:	68 68 64 10 f0       	push   $0xf0106468
f010362d:	68 de 01 00 00       	push   $0x1de
f0103632:	68 26 77 10 f0       	push   $0xf0107726
f0103637:	e8 04 ca ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f010363c:	83 ec 04             	sub    $0x4,%esp
f010363f:	68 d4 6d 10 f0       	push   $0xf0106dd4
f0103644:	6a 52                	push   $0x52
f0103646:	68 9b 69 10 f0       	push   $0xf010699b
f010364b:	e8 f0 c9 ff ff       	call   f0100040 <_panic>

f0103650 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103650:	55                   	push   %ebp
f0103651:	89 e5                	mov    %esp,%ebp
f0103653:	53                   	push   %ebx
f0103654:	83 ec 04             	sub    $0x4,%esp
f0103657:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010365a:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010365e:	74 21                	je     f0103681 <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103660:	83 ec 0c             	sub    $0xc,%esp
f0103663:	53                   	push   %ebx
f0103664:	e8 3d fe ff ff       	call   f01034a6 <env_free>

	if (curenv == e) {
f0103669:	e8 6e 27 00 00       	call   f0105ddc <cpunum>
f010366e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103671:	83 c4 10             	add    $0x10,%esp
f0103674:	39 98 28 80 25 f0    	cmp    %ebx,-0xfda7fd8(%eax)
f010367a:	74 1e                	je     f010369a <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f010367c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010367f:	c9                   	leave  
f0103680:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103681:	e8 56 27 00 00       	call   f0105ddc <cpunum>
f0103686:	6b c0 74             	imul   $0x74,%eax,%eax
f0103689:	39 98 28 80 25 f0    	cmp    %ebx,-0xfda7fd8(%eax)
f010368f:	74 cf                	je     f0103660 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f0103691:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103698:	eb e2                	jmp    f010367c <env_destroy+0x2c>
		curenv = NULL;
f010369a:	e8 3d 27 00 00       	call   f0105ddc <cpunum>
f010369f:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a2:	c7 80 28 80 25 f0 00 	movl   $0x0,-0xfda7fd8(%eax)
f01036a9:	00 00 00 
		sched_yield();
f01036ac:	e8 02 0f 00 00       	call   f01045b3 <sched_yield>

f01036b1 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01036b1:	55                   	push   %ebp
f01036b2:	89 e5                	mov    %esp,%ebp
f01036b4:	53                   	push   %ebx
f01036b5:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01036b8:	e8 1f 27 00 00       	call   f0105ddc <cpunum>
f01036bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01036c0:	8b 98 28 80 25 f0    	mov    -0xfda7fd8(%eax),%ebx
f01036c6:	e8 11 27 00 00       	call   f0105ddc <cpunum>
f01036cb:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01036ce:	8b 65 08             	mov    0x8(%ebp),%esp
f01036d1:	61                   	popa   
f01036d2:	07                   	pop    %es
f01036d3:	1f                   	pop    %ds
f01036d4:	83 c4 08             	add    $0x8,%esp
f01036d7:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n" /*中断返回指令*/
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01036d8:	83 ec 04             	sub    $0x4,%esp
f01036db:	68 46 77 10 f0       	push   $0xf0107746
f01036e0:	68 15 02 00 00       	push   $0x215
f01036e5:	68 26 77 10 f0       	push   $0xf0107726
f01036ea:	e8 51 c9 ff ff       	call   f0100040 <_panic>

f01036ef <env_run>:
//
// This function does not return.
//启动在用户模式下运行的给定环境。
void
env_run(struct Env *e)
{
f01036ef:	55                   	push   %ebp
f01036f0:	89 e5                	mov    %esp,%ebp
f01036f2:	53                   	push   %ebx
f01036f3:	83 ec 04             	sub    $0x4,%esp
f01036f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// Step 1
	if(e == NULL) panic("env_run: invalid environment\n");
f01036f9:	85 db                	test   %ebx,%ebx
f01036fb:	0f 84 b3 00 00 00    	je     f01037b4 <env_run+0xc5>
	if(curenv != e && curenv != NULL) {
f0103701:	e8 d6 26 00 00       	call   f0105ddc <cpunum>
f0103706:	6b c0 74             	imul   $0x74,%eax,%eax
f0103709:	39 98 28 80 25 f0    	cmp    %ebx,-0xfda7fd8(%eax)
f010370f:	74 29                	je     f010373a <env_run+0x4b>
f0103711:	e8 c6 26 00 00       	call   f0105ddc <cpunum>
f0103716:	6b c0 74             	imul   $0x74,%eax,%eax
f0103719:	83 b8 28 80 25 f0 00 	cmpl   $0x0,-0xfda7fd8(%eax)
f0103720:	74 18                	je     f010373a <env_run+0x4b>
		if(curenv->env_status == ENV_RUNNING)  curenv->env_status = ENV_RUNNABLE;
f0103722:	e8 b5 26 00 00       	call   f0105ddc <cpunum>
f0103727:	6b c0 74             	imul   $0x74,%eax,%eax
f010372a:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0103730:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103734:	0f 84 91 00 00 00    	je     f01037cb <env_run+0xdc>
	}
	curenv=e;
f010373a:	e8 9d 26 00 00       	call   f0105ddc <cpunum>
f010373f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103742:	89 98 28 80 25 f0    	mov    %ebx,-0xfda7fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103748:	e8 8f 26 00 00       	call   f0105ddc <cpunum>
f010374d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103750:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0103756:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f010375d:	e8 7a 26 00 00       	call   f0105ddc <cpunum>
f0103762:	6b c0 74             	imul   $0x74,%eax,%eax
f0103765:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f010376b:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f010376f:	e8 68 26 00 00       	call   f0105ddc <cpunum>
f0103774:	6b c0 74             	imul   $0x74,%eax,%eax
f0103777:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f010377d:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103780:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103785:	76 5e                	jbe    f01037e5 <env_run+0xf6>
	return (physaddr_t)kva - KERNBASE;
f0103787:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f010378c:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010378f:	83 ec 0c             	sub    $0xc,%esp
f0103792:	68 c0 53 12 f0       	push   $0xf01253c0
f0103797:	e8 4a 29 00 00       	call   f01060e6 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010379c:	f3 90                	pause  
	
	//lab4:切换到用户模式之前释放锁
	unlock_kernel();
	
	// Step 2
	env_pop_tf( &(curenv->env_tf) );
f010379e:	e8 39 26 00 00       	call   f0105ddc <cpunum>
f01037a3:	83 c4 04             	add    $0x4,%esp
f01037a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01037a9:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f01037af:	e8 fd fe ff ff       	call   f01036b1 <env_pop_tf>
	if(e == NULL) panic("env_run: invalid environment\n");
f01037b4:	83 ec 04             	sub    $0x4,%esp
f01037b7:	68 52 77 10 f0       	push   $0xf0107752
f01037bc:	68 34 02 00 00       	push   $0x234
f01037c1:	68 26 77 10 f0       	push   $0xf0107726
f01037c6:	e8 75 c8 ff ff       	call   f0100040 <_panic>
		if(curenv->env_status == ENV_RUNNING)  curenv->env_status = ENV_RUNNABLE;
f01037cb:	e8 0c 26 00 00       	call   f0105ddc <cpunum>
f01037d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01037d3:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f01037d9:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f01037e0:	e9 55 ff ff ff       	jmp    f010373a <env_run+0x4b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037e5:	50                   	push   %eax
f01037e6:	68 68 64 10 f0       	push   $0xf0106468
f01037eb:	68 3b 02 00 00       	push   $0x23b
f01037f0:	68 26 77 10 f0       	push   $0xf0107726
f01037f5:	e8 46 c8 ff ff       	call   f0100040 <_panic>

f01037fa <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01037fa:	55                   	push   %ebp
f01037fb:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0103800:	ba 70 00 00 00       	mov    $0x70,%edx
f0103805:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103806:	ba 71 00 00 00       	mov    $0x71,%edx
f010380b:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010380c:	0f b6 c0             	movzbl %al,%eax
}
f010380f:	5d                   	pop    %ebp
f0103810:	c3                   	ret    

f0103811 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103811:	55                   	push   %ebp
f0103812:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103814:	8b 45 08             	mov    0x8(%ebp),%eax
f0103817:	ba 70 00 00 00       	mov    $0x70,%edx
f010381c:	ee                   	out    %al,(%dx)
f010381d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103820:	ba 71 00 00 00       	mov    $0x71,%edx
f0103825:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103826:	5d                   	pop    %ebp
f0103827:	c3                   	ret    

f0103828 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103828:	55                   	push   %ebp
f0103829:	89 e5                	mov    %esp,%ebp
f010382b:	56                   	push   %esi
f010382c:	53                   	push   %ebx
f010382d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	irq_mask_8259A = mask;
f0103830:	66 89 0d a8 53 12 f0 	mov    %cx,0xf01253a8
	if (!didinit)
f0103837:	80 3d 78 72 21 f0 00 	cmpb   $0x0,0xf0217278
f010383e:	75 07                	jne    f0103847 <irq_setmask_8259A+0x1f>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103840:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103843:	5b                   	pop    %ebx
f0103844:	5e                   	pop    %esi
f0103845:	5d                   	pop    %ebp
f0103846:	c3                   	ret    
f0103847:	89 ce                	mov    %ecx,%esi
f0103849:	ba 21 00 00 00       	mov    $0x21,%edx
f010384e:	89 c8                	mov    %ecx,%eax
f0103850:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103851:	89 c8                	mov    %ecx,%eax
f0103853:	66 c1 e8 08          	shr    $0x8,%ax
f0103857:	ba a1 00 00 00       	mov    $0xa1,%edx
f010385c:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f010385d:	83 ec 0c             	sub    $0xc,%esp
f0103860:	68 70 77 10 f0       	push   $0xf0107770
f0103865:	e8 20 01 00 00       	call   f010398a <cprintf>
f010386a:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010386d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103872:	0f b7 f6             	movzwl %si,%esi
f0103875:	f7 d6                	not    %esi
f0103877:	eb 08                	jmp    f0103881 <irq_setmask_8259A+0x59>
	for (i = 0; i < 16; i++)
f0103879:	83 c3 01             	add    $0x1,%ebx
f010387c:	83 fb 10             	cmp    $0x10,%ebx
f010387f:	74 18                	je     f0103899 <irq_setmask_8259A+0x71>
		if (~mask & (1<<i))
f0103881:	0f a3 de             	bt     %ebx,%esi
f0103884:	73 f3                	jae    f0103879 <irq_setmask_8259A+0x51>
			cprintf(" %d", i);
f0103886:	83 ec 08             	sub    $0x8,%esp
f0103889:	53                   	push   %ebx
f010388a:	68 cb 7c 10 f0       	push   $0xf0107ccb
f010388f:	e8 f6 00 00 00       	call   f010398a <cprintf>
f0103894:	83 c4 10             	add    $0x10,%esp
f0103897:	eb e0                	jmp    f0103879 <irq_setmask_8259A+0x51>
	cprintf("\n");
f0103899:	83 ec 0c             	sub    $0xc,%esp
f010389c:	68 93 6c 10 f0       	push   $0xf0106c93
f01038a1:	e8 e4 00 00 00       	call   f010398a <cprintf>
f01038a6:	83 c4 10             	add    $0x10,%esp
f01038a9:	eb 95                	jmp    f0103840 <irq_setmask_8259A+0x18>

f01038ab <pic_init>:
{
f01038ab:	55                   	push   %ebp
f01038ac:	89 e5                	mov    %esp,%ebp
f01038ae:	57                   	push   %edi
f01038af:	56                   	push   %esi
f01038b0:	53                   	push   %ebx
f01038b1:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f01038b4:	c6 05 78 72 21 f0 01 	movb   $0x1,0xf0217278
f01038bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01038c0:	bb 21 00 00 00       	mov    $0x21,%ebx
f01038c5:	89 da                	mov    %ebx,%edx
f01038c7:	ee                   	out    %al,(%dx)
f01038c8:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f01038cd:	89 ca                	mov    %ecx,%edx
f01038cf:	ee                   	out    %al,(%dx)
f01038d0:	bf 11 00 00 00       	mov    $0x11,%edi
f01038d5:	be 20 00 00 00       	mov    $0x20,%esi
f01038da:	89 f8                	mov    %edi,%eax
f01038dc:	89 f2                	mov    %esi,%edx
f01038de:	ee                   	out    %al,(%dx)
f01038df:	b8 20 00 00 00       	mov    $0x20,%eax
f01038e4:	89 da                	mov    %ebx,%edx
f01038e6:	ee                   	out    %al,(%dx)
f01038e7:	b8 04 00 00 00       	mov    $0x4,%eax
f01038ec:	ee                   	out    %al,(%dx)
f01038ed:	b8 03 00 00 00       	mov    $0x3,%eax
f01038f2:	ee                   	out    %al,(%dx)
f01038f3:	bb a0 00 00 00       	mov    $0xa0,%ebx
f01038f8:	89 f8                	mov    %edi,%eax
f01038fa:	89 da                	mov    %ebx,%edx
f01038fc:	ee                   	out    %al,(%dx)
f01038fd:	b8 28 00 00 00       	mov    $0x28,%eax
f0103902:	89 ca                	mov    %ecx,%edx
f0103904:	ee                   	out    %al,(%dx)
f0103905:	b8 02 00 00 00       	mov    $0x2,%eax
f010390a:	ee                   	out    %al,(%dx)
f010390b:	b8 01 00 00 00       	mov    $0x1,%eax
f0103910:	ee                   	out    %al,(%dx)
f0103911:	bf 68 00 00 00       	mov    $0x68,%edi
f0103916:	89 f8                	mov    %edi,%eax
f0103918:	89 f2                	mov    %esi,%edx
f010391a:	ee                   	out    %al,(%dx)
f010391b:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103920:	89 c8                	mov    %ecx,%eax
f0103922:	ee                   	out    %al,(%dx)
f0103923:	89 f8                	mov    %edi,%eax
f0103925:	89 da                	mov    %ebx,%edx
f0103927:	ee                   	out    %al,(%dx)
f0103928:	89 c8                	mov    %ecx,%eax
f010392a:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f010392b:	0f b7 05 a8 53 12 f0 	movzwl 0xf01253a8,%eax
f0103932:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103936:	75 08                	jne    f0103940 <pic_init+0x95>
}
f0103938:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010393b:	5b                   	pop    %ebx
f010393c:	5e                   	pop    %esi
f010393d:	5f                   	pop    %edi
f010393e:	5d                   	pop    %ebp
f010393f:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f0103940:	83 ec 0c             	sub    $0xc,%esp
f0103943:	0f b7 c0             	movzwl %ax,%eax
f0103946:	50                   	push   %eax
f0103947:	e8 dc fe ff ff       	call   f0103828 <irq_setmask_8259A>
f010394c:	83 c4 10             	add    $0x10,%esp
}
f010394f:	eb e7                	jmp    f0103938 <pic_init+0x8d>

f0103951 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103951:	55                   	push   %ebp
f0103952:	89 e5                	mov    %esp,%ebp
f0103954:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103957:	ff 75 08             	push   0x8(%ebp)
f010395a:	e8 1e ce ff ff       	call   f010077d <cputchar>
	*cnt++;
}
f010395f:	83 c4 10             	add    $0x10,%esp
f0103962:	c9                   	leave  
f0103963:	c3                   	ret    

f0103964 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103964:	55                   	push   %ebp
f0103965:	89 e5                	mov    %esp,%ebp
f0103967:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010396a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103971:	ff 75 0c             	push   0xc(%ebp)
f0103974:	ff 75 08             	push   0x8(%ebp)
f0103977:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010397a:	50                   	push   %eax
f010397b:	68 51 39 10 f0       	push   $0xf0103951
f0103980:	e8 40 17 00 00       	call   f01050c5 <vprintfmt>
	return cnt;
}
f0103985:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103988:	c9                   	leave  
f0103989:	c3                   	ret    

f010398a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010398a:	55                   	push   %ebp
f010398b:	89 e5                	mov    %esp,%ebp
f010398d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103990:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103993:	50                   	push   %eax
f0103994:	ff 75 08             	push   0x8(%ebp)
f0103997:	e8 c8 ff ff ff       	call   f0103964 <vcprintf>
	va_end(ap);

	return cnt;
}
f010399c:	c9                   	leave  
f010399d:	c3                   	ret    

f010399e <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010399e:	55                   	push   %ebp
f010399f:	89 e5                	mov    %esp,%ebp
f01039a1:	57                   	push   %edi
f01039a2:	56                   	push   %esi
f01039a3:	53                   	push   %ebx
f01039a4:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	//依照注释hints修改即可
	size_t i =thiscpu->cpu_id;
f01039a7:	e8 30 24 00 00       	call   f0105ddc <cpunum>
f01039ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01039af:	0f b6 b8 20 80 25 f0 	movzbl -0xfda7fe0(%eax),%edi
f01039b6:	89 f8                	mov    %edi,%eax
f01039b8:	0f b6 d8             	movzbl %al,%ebx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
f01039bb:	e8 1c 24 00 00       	call   f0105ddc <cpunum>
f01039c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01039c3:	ba 00 f0 00 00       	mov    $0xf000,%edx
f01039c8:	29 da                	sub    %ebx,%edx
f01039ca:	c1 e2 10             	shl    $0x10,%edx
f01039cd:	89 90 30 80 25 f0    	mov    %edx,-0xfda7fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01039d3:	e8 04 24 00 00       	call   f0105ddc <cpunum>
f01039d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01039db:	66 c7 80 34 80 25 f0 	movw   $0x10,-0xfda7fcc(%eax)
f01039e2:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);//这行不懂，直接较原来程序保持不变
f01039e4:	e8 f3 23 00 00       	call   f0105ddc <cpunum>
f01039e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01039ec:	66 c7 80 92 80 25 f0 	movw   $0x68,-0xfda7f6e(%eax)
f01039f3:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01039f5:	83 c3 05             	add    $0x5,%ebx
f01039f8:	e8 df 23 00 00       	call   f0105ddc <cpunum>
f01039fd:	89 c6                	mov    %eax,%esi
f01039ff:	e8 d8 23 00 00       	call   f0105ddc <cpunum>
f0103a04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103a07:	e8 d0 23 00 00       	call   f0105ddc <cpunum>
f0103a0c:	66 c7 04 dd 40 53 12 	movw   $0x67,-0xfedacc0(,%ebx,8)
f0103a13:	f0 67 00 
f0103a16:	6b f6 74             	imul   $0x74,%esi,%esi
f0103a19:	81 c6 2c 80 25 f0    	add    $0xf025802c,%esi
f0103a1f:	66 89 34 dd 42 53 12 	mov    %si,-0xfedacbe(,%ebx,8)
f0103a26:	f0 
f0103a27:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103a2b:	81 c2 2c 80 25 f0    	add    $0xf025802c,%edx
f0103a31:	c1 ea 10             	shr    $0x10,%edx
f0103a34:	88 14 dd 44 53 12 f0 	mov    %dl,-0xfedacbc(,%ebx,8)
f0103a3b:	c6 04 dd 46 53 12 f0 	movb   $0x40,-0xfedacba(,%ebx,8)
f0103a42:	40 
f0103a43:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a46:	05 2c 80 25 f0       	add    $0xf025802c,%eax
f0103a4b:	c1 e8 18             	shr    $0x18,%eax
f0103a4e:	88 04 dd 47 53 12 f0 	mov    %al,-0xfedacb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103a55:	c6 04 dd 45 53 12 f0 	movb   $0x89,-0xfedacbb(,%ebx,8)
f0103a5c:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (i << 3));//相应的TSS选择子也要修改
f0103a5d:	89 f8                	mov    %edi,%eax
f0103a5f:	0f b6 f8             	movzbl %al,%edi
f0103a62:	8d 3c fd 28 00 00 00 	lea    0x28(,%edi,8),%edi
	asm volatile("ltr %0" : : "r" (sel));
f0103a69:	0f 00 df             	ltr    %di
	asm volatile("lidt (%0)" : : "r" (p));
f0103a6c:	b8 ac 53 12 f0       	mov    $0xf01253ac,%eax
f0103a71:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103a74:	83 c4 1c             	add    $0x1c,%esp
f0103a77:	5b                   	pop    %ebx
f0103a78:	5e                   	pop    %esi
f0103a79:	5f                   	pop    %edi
f0103a7a:	5d                   	pop    %ebp
f0103a7b:	c3                   	ret    

f0103a7c <trap_init>:
{
f0103a7c:	55                   	push   %ebp
f0103a7d:	89 e5                	mov    %esp,%ebp
f0103a7f:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, DIVIDE_HANDLER, 0);//GD_KT  kernel text
f0103a82:	b8 4c 44 10 f0       	mov    $0xf010444c,%eax
f0103a87:	66 a3 80 72 21 f0    	mov    %ax,0xf0217280
f0103a8d:	66 c7 05 82 72 21 f0 	movw   $0x8,0xf0217282
f0103a94:	08 00 
f0103a96:	c6 05 84 72 21 f0 00 	movb   $0x0,0xf0217284
f0103a9d:	c6 05 85 72 21 f0 8e 	movb   $0x8e,0xf0217285
f0103aa4:	c1 e8 10             	shr    $0x10,%eax
f0103aa7:	66 a3 86 72 21 f0    	mov    %ax,0xf0217286
	SETGATE(idt[T_DEBUG], 0, GD_KT, DEBUG_HANDLER, 0);
f0103aad:	b8 56 44 10 f0       	mov    $0xf0104456,%eax
f0103ab2:	66 a3 88 72 21 f0    	mov    %ax,0xf0217288
f0103ab8:	66 c7 05 8a 72 21 f0 	movw   $0x8,0xf021728a
f0103abf:	08 00 
f0103ac1:	c6 05 8c 72 21 f0 00 	movb   $0x0,0xf021728c
f0103ac8:	c6 05 8d 72 21 f0 8e 	movb   $0x8e,0xf021728d
f0103acf:	c1 e8 10             	shr    $0x10,%eax
f0103ad2:	66 a3 8e 72 21 f0    	mov    %ax,0xf021728e
	SETGATE(idt[T_NMI], 0, GD_KT, NMI_HANDLER, 0);
f0103ad8:	b8 5c 44 10 f0       	mov    $0xf010445c,%eax
f0103add:	66 a3 90 72 21 f0    	mov    %ax,0xf0217290
f0103ae3:	66 c7 05 92 72 21 f0 	movw   $0x8,0xf0217292
f0103aea:	08 00 
f0103aec:	c6 05 94 72 21 f0 00 	movb   $0x0,0xf0217294
f0103af3:	c6 05 95 72 21 f0 8e 	movb   $0x8e,0xf0217295
f0103afa:	c1 e8 10             	shr    $0x10,%eax
f0103afd:	66 a3 96 72 21 f0    	mov    %ax,0xf0217296
	SETGATE(idt[T_BRKPT], 0, GD_KT, BRKPT_HANDLER, 3);//exercise 6在此处需要修改
f0103b03:	b8 62 44 10 f0       	mov    $0xf0104462,%eax
f0103b08:	66 a3 98 72 21 f0    	mov    %ax,0xf0217298
f0103b0e:	66 c7 05 9a 72 21 f0 	movw   $0x8,0xf021729a
f0103b15:	08 00 
f0103b17:	c6 05 9c 72 21 f0 00 	movb   $0x0,0xf021729c
f0103b1e:	c6 05 9d 72 21 f0 ee 	movb   $0xee,0xf021729d
f0103b25:	c1 e8 10             	shr    $0x10,%eax
f0103b28:	66 a3 9e 72 21 f0    	mov    %ax,0xf021729e
	SETGATE(idt[T_OFLOW], 0, GD_KT, OFLOW_HANDLER, 0);
f0103b2e:	b8 68 44 10 f0       	mov    $0xf0104468,%eax
f0103b33:	66 a3 a0 72 21 f0    	mov    %ax,0xf02172a0
f0103b39:	66 c7 05 a2 72 21 f0 	movw   $0x8,0xf02172a2
f0103b40:	08 00 
f0103b42:	c6 05 a4 72 21 f0 00 	movb   $0x0,0xf02172a4
f0103b49:	c6 05 a5 72 21 f0 8e 	movb   $0x8e,0xf02172a5
f0103b50:	c1 e8 10             	shr    $0x10,%eax
f0103b53:	66 a3 a6 72 21 f0    	mov    %ax,0xf02172a6
	SETGATE(idt[T_BOUND], 0, GD_KT, BOUND_HANDLER, 0);
f0103b59:	b8 6e 44 10 f0       	mov    $0xf010446e,%eax
f0103b5e:	66 a3 a8 72 21 f0    	mov    %ax,0xf02172a8
f0103b64:	66 c7 05 aa 72 21 f0 	movw   $0x8,0xf02172aa
f0103b6b:	08 00 
f0103b6d:	c6 05 ac 72 21 f0 00 	movb   $0x0,0xf02172ac
f0103b74:	c6 05 ad 72 21 f0 8e 	movb   $0x8e,0xf02172ad
f0103b7b:	c1 e8 10             	shr    $0x10,%eax
f0103b7e:	66 a3 ae 72 21 f0    	mov    %ax,0xf02172ae
	SETGATE(idt[T_ILLOP], 0, GD_KT, ILLOP_HANDLER, 0);
f0103b84:	b8 74 44 10 f0       	mov    $0xf0104474,%eax
f0103b89:	66 a3 b0 72 21 f0    	mov    %ax,0xf02172b0
f0103b8f:	66 c7 05 b2 72 21 f0 	movw   $0x8,0xf02172b2
f0103b96:	08 00 
f0103b98:	c6 05 b4 72 21 f0 00 	movb   $0x0,0xf02172b4
f0103b9f:	c6 05 b5 72 21 f0 8e 	movb   $0x8e,0xf02172b5
f0103ba6:	c1 e8 10             	shr    $0x10,%eax
f0103ba9:	66 a3 b6 72 21 f0    	mov    %ax,0xf02172b6
	SETGATE(idt[T_DEVICE], 0, GD_KT, DEVICE_HANDLER, 0);
f0103baf:	b8 7a 44 10 f0       	mov    $0xf010447a,%eax
f0103bb4:	66 a3 b8 72 21 f0    	mov    %ax,0xf02172b8
f0103bba:	66 c7 05 ba 72 21 f0 	movw   $0x8,0xf02172ba
f0103bc1:	08 00 
f0103bc3:	c6 05 bc 72 21 f0 00 	movb   $0x0,0xf02172bc
f0103bca:	c6 05 bd 72 21 f0 8e 	movb   $0x8e,0xf02172bd
f0103bd1:	c1 e8 10             	shr    $0x10,%eax
f0103bd4:	66 a3 be 72 21 f0    	mov    %ax,0xf02172be
	SETGATE(idt[T_DBLFLT], 0, GD_KT, DBLFLT_HANDLER, 0);
f0103bda:	b8 80 44 10 f0       	mov    $0xf0104480,%eax
f0103bdf:	66 a3 c0 72 21 f0    	mov    %ax,0xf02172c0
f0103be5:	66 c7 05 c2 72 21 f0 	movw   $0x8,0xf02172c2
f0103bec:	08 00 
f0103bee:	c6 05 c4 72 21 f0 00 	movb   $0x0,0xf02172c4
f0103bf5:	c6 05 c5 72 21 f0 8e 	movb   $0x8e,0xf02172c5
f0103bfc:	c1 e8 10             	shr    $0x10,%eax
f0103bff:	66 a3 c6 72 21 f0    	mov    %ax,0xf02172c6
	SETGATE(idt[T_TSS], 0, GD_KT, TSS_HANDLER, 0);
f0103c05:	b8 84 44 10 f0       	mov    $0xf0104484,%eax
f0103c0a:	66 a3 d0 72 21 f0    	mov    %ax,0xf02172d0
f0103c10:	66 c7 05 d2 72 21 f0 	movw   $0x8,0xf02172d2
f0103c17:	08 00 
f0103c19:	c6 05 d4 72 21 f0 00 	movb   $0x0,0xf02172d4
f0103c20:	c6 05 d5 72 21 f0 8e 	movb   $0x8e,0xf02172d5
f0103c27:	c1 e8 10             	shr    $0x10,%eax
f0103c2a:	66 a3 d6 72 21 f0    	mov    %ax,0xf02172d6
	SETGATE(idt[T_SEGNP], 0, GD_KT, SEGNP_HANDLER, 0);
f0103c30:	b8 88 44 10 f0       	mov    $0xf0104488,%eax
f0103c35:	66 a3 d8 72 21 f0    	mov    %ax,0xf02172d8
f0103c3b:	66 c7 05 da 72 21 f0 	movw   $0x8,0xf02172da
f0103c42:	08 00 
f0103c44:	c6 05 dc 72 21 f0 00 	movb   $0x0,0xf02172dc
f0103c4b:	c6 05 dd 72 21 f0 8e 	movb   $0x8e,0xf02172dd
f0103c52:	c1 e8 10             	shr    $0x10,%eax
f0103c55:	66 a3 de 72 21 f0    	mov    %ax,0xf02172de
	SETGATE(idt[T_STACK], 0, GD_KT, STACK_HANDLER, 0);
f0103c5b:	b8 8c 44 10 f0       	mov    $0xf010448c,%eax
f0103c60:	66 a3 e0 72 21 f0    	mov    %ax,0xf02172e0
f0103c66:	66 c7 05 e2 72 21 f0 	movw   $0x8,0xf02172e2
f0103c6d:	08 00 
f0103c6f:	c6 05 e4 72 21 f0 00 	movb   $0x0,0xf02172e4
f0103c76:	c6 05 e5 72 21 f0 8e 	movb   $0x8e,0xf02172e5
f0103c7d:	c1 e8 10             	shr    $0x10,%eax
f0103c80:	66 a3 e6 72 21 f0    	mov    %ax,0xf02172e6
	SETGATE(idt[T_GPFLT], 0, GD_KT, GPFLT_HANDLER, 0);
f0103c86:	b8 90 44 10 f0       	mov    $0xf0104490,%eax
f0103c8b:	66 a3 e8 72 21 f0    	mov    %ax,0xf02172e8
f0103c91:	66 c7 05 ea 72 21 f0 	movw   $0x8,0xf02172ea
f0103c98:	08 00 
f0103c9a:	c6 05 ec 72 21 f0 00 	movb   $0x0,0xf02172ec
f0103ca1:	c6 05 ed 72 21 f0 8e 	movb   $0x8e,0xf02172ed
f0103ca8:	c1 e8 10             	shr    $0x10,%eax
f0103cab:	66 a3 ee 72 21 f0    	mov    %ax,0xf02172ee
	SETGATE(idt[T_PGFLT], 0, GD_KT, PGFLT_HANDLER, 0);
f0103cb1:	b8 94 44 10 f0       	mov    $0xf0104494,%eax
f0103cb6:	66 a3 f0 72 21 f0    	mov    %ax,0xf02172f0
f0103cbc:	66 c7 05 f2 72 21 f0 	movw   $0x8,0xf02172f2
f0103cc3:	08 00 
f0103cc5:	c6 05 f4 72 21 f0 00 	movb   $0x0,0xf02172f4
f0103ccc:	c6 05 f5 72 21 f0 8e 	movb   $0x8e,0xf02172f5
f0103cd3:	c1 e8 10             	shr    $0x10,%eax
f0103cd6:	66 a3 f6 72 21 f0    	mov    %ax,0xf02172f6
	SETGATE(idt[T_FPERR], 0, GD_KT, FPERR_HANDLER, 0);
f0103cdc:	b8 98 44 10 f0       	mov    $0xf0104498,%eax
f0103ce1:	66 a3 00 73 21 f0    	mov    %ax,0xf0217300
f0103ce7:	66 c7 05 02 73 21 f0 	movw   $0x8,0xf0217302
f0103cee:	08 00 
f0103cf0:	c6 05 04 73 21 f0 00 	movb   $0x0,0xf0217304
f0103cf7:	c6 05 05 73 21 f0 8e 	movb   $0x8e,0xf0217305
f0103cfe:	c1 e8 10             	shr    $0x10,%eax
f0103d01:	66 a3 06 73 21 f0    	mov    %ax,0xf0217306
	SETGATE(idt[T_ALIGN], 0, GD_KT, ALIGN_HANDLER, 0);
f0103d07:	b8 9e 44 10 f0       	mov    $0xf010449e,%eax
f0103d0c:	66 a3 08 73 21 f0    	mov    %ax,0xf0217308
f0103d12:	66 c7 05 0a 73 21 f0 	movw   $0x8,0xf021730a
f0103d19:	08 00 
f0103d1b:	c6 05 0c 73 21 f0 00 	movb   $0x0,0xf021730c
f0103d22:	c6 05 0d 73 21 f0 8e 	movb   $0x8e,0xf021730d
f0103d29:	c1 e8 10             	shr    $0x10,%eax
f0103d2c:	66 a3 0e 73 21 f0    	mov    %ax,0xf021730e
	SETGATE(idt[T_MCHK], 0, GD_KT, MCHK_HANDLER, 0);
f0103d32:	b8 a2 44 10 f0       	mov    $0xf01044a2,%eax
f0103d37:	66 a3 10 73 21 f0    	mov    %ax,0xf0217310
f0103d3d:	66 c7 05 12 73 21 f0 	movw   $0x8,0xf0217312
f0103d44:	08 00 
f0103d46:	c6 05 14 73 21 f0 00 	movb   $0x0,0xf0217314
f0103d4d:	c6 05 15 73 21 f0 8e 	movb   $0x8e,0xf0217315
f0103d54:	c1 e8 10             	shr    $0x10,%eax
f0103d57:	66 a3 16 73 21 f0    	mov    %ax,0xf0217316
	SETGATE(idt[T_SIMDERR], 0, GD_KT, SIMDERR_HANDLER, 0);
f0103d5d:	b8 a8 44 10 f0       	mov    $0xf01044a8,%eax
f0103d62:	66 a3 18 73 21 f0    	mov    %ax,0xf0217318
f0103d68:	66 c7 05 1a 73 21 f0 	movw   $0x8,0xf021731a
f0103d6f:	08 00 
f0103d71:	c6 05 1c 73 21 f0 00 	movb   $0x0,0xf021731c
f0103d78:	c6 05 1d 73 21 f0 8e 	movb   $0x8e,0xf021731d
f0103d7f:	c1 e8 10             	shr    $0x10,%eax
f0103d82:	66 a3 1e 73 21 f0    	mov    %ax,0xf021731e
	SETGATE(idt[T_SYSCALL], 0 , GD_KT, SYSCALL_HANDLER, 3);//需要将dpl设置为3,因为这是用户态下调用的系统调用（中断）
f0103d88:	b8 ae 44 10 f0       	mov    $0xf01044ae,%eax
f0103d8d:	66 a3 00 74 21 f0    	mov    %ax,0xf0217400
f0103d93:	66 c7 05 02 74 21 f0 	movw   $0x8,0xf0217402
f0103d9a:	08 00 
f0103d9c:	c6 05 04 74 21 f0 00 	movb   $0x0,0xf0217404
f0103da3:	c6 05 05 74 21 f0 ee 	movb   $0xee,0xf0217405
f0103daa:	c1 e8 10             	shr    $0x10,%eax
f0103dad:	66 a3 06 74 21 f0    	mov    %ax,0xf0217406
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],    0, GD_KT, timer_handler,   0);//中断是让内核抢占控制权，所以dpl应该设置为0。
f0103db3:	b8 b4 44 10 f0       	mov    $0xf01044b4,%eax
f0103db8:	66 a3 80 73 21 f0    	mov    %ax,0xf0217380
f0103dbe:	66 c7 05 82 73 21 f0 	movw   $0x8,0xf0217382
f0103dc5:	08 00 
f0103dc7:	c6 05 84 73 21 f0 00 	movb   $0x0,0xf0217384
f0103dce:	c6 05 85 73 21 f0 8e 	movb   $0x8e,0xf0217385
f0103dd5:	c1 e8 10             	shr    $0x10,%eax
f0103dd8:	66 a3 86 73 21 f0    	mov    %ax,0xf0217386
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD],      0, GD_KT, kbd_handler,     0);
f0103dde:	b8 ba 44 10 f0       	mov    $0xf01044ba,%eax
f0103de3:	66 a3 88 73 21 f0    	mov    %ax,0xf0217388
f0103de9:	66 c7 05 8a 73 21 f0 	movw   $0x8,0xf021738a
f0103df0:	08 00 
f0103df2:	c6 05 8c 73 21 f0 00 	movb   $0x0,0xf021738c
f0103df9:	c6 05 8d 73 21 f0 8e 	movb   $0x8e,0xf021738d
f0103e00:	c1 e8 10             	shr    $0x10,%eax
f0103e03:	66 a3 8e 73 21 f0    	mov    %ax,0xf021738e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL],   0, GD_KT, serial_handler,  0);
f0103e09:	b8 c0 44 10 f0       	mov    $0xf01044c0,%eax
f0103e0e:	66 a3 a0 73 21 f0    	mov    %ax,0xf02173a0
f0103e14:	66 c7 05 a2 73 21 f0 	movw   $0x8,0xf02173a2
f0103e1b:	08 00 
f0103e1d:	c6 05 a4 73 21 f0 00 	movb   $0x0,0xf02173a4
f0103e24:	c6 05 a5 73 21 f0 8e 	movb   $0x8e,0xf02173a5
f0103e2b:	c1 e8 10             	shr    $0x10,%eax
f0103e2e:	66 a3 a6 73 21 f0    	mov    %ax,0xf02173a6
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, spurious_handler,0);
f0103e34:	b8 c6 44 10 f0       	mov    $0xf01044c6,%eax
f0103e39:	66 a3 b8 73 21 f0    	mov    %ax,0xf02173b8
f0103e3f:	66 c7 05 ba 73 21 f0 	movw   $0x8,0xf02173ba
f0103e46:	08 00 
f0103e48:	c6 05 bc 73 21 f0 00 	movb   $0x0,0xf02173bc
f0103e4f:	c6 05 bd 73 21 f0 8e 	movb   $0x8e,0xf02173bd
f0103e56:	c1 e8 10             	shr    $0x10,%eax
f0103e59:	66 a3 be 73 21 f0    	mov    %ax,0xf02173be
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE],      0, GD_KT, ide_handler,     0);
f0103e5f:	b8 cc 44 10 f0       	mov    $0xf01044cc,%eax
f0103e64:	66 a3 f0 73 21 f0    	mov    %ax,0xf02173f0
f0103e6a:	66 c7 05 f2 73 21 f0 	movw   $0x8,0xf02173f2
f0103e71:	08 00 
f0103e73:	c6 05 f4 73 21 f0 00 	movb   $0x0,0xf02173f4
f0103e7a:	c6 05 f5 73 21 f0 8e 	movb   $0x8e,0xf02173f5
f0103e81:	c1 e8 10             	shr    $0x10,%eax
f0103e84:	66 a3 f6 73 21 f0    	mov    %ax,0xf02173f6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR],    0, GD_KT, error_handler,   0);
f0103e8a:	b8 d2 44 10 f0       	mov    $0xf01044d2,%eax
f0103e8f:	66 a3 18 74 21 f0    	mov    %ax,0xf0217418
f0103e95:	66 c7 05 1a 74 21 f0 	movw   $0x8,0xf021741a
f0103e9c:	08 00 
f0103e9e:	c6 05 1c 74 21 f0 00 	movb   $0x0,0xf021741c
f0103ea5:	c6 05 1d 74 21 f0 8e 	movb   $0x8e,0xf021741d
f0103eac:	c1 e8 10             	shr    $0x10,%eax
f0103eaf:	66 a3 1e 74 21 f0    	mov    %ax,0xf021741e
	trap_init_percpu();
f0103eb5:	e8 e4 fa ff ff       	call   f010399e <trap_init_percpu>
}
f0103eba:	c9                   	leave  
f0103ebb:	c3                   	ret    

f0103ebc <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103ebc:	55                   	push   %ebp
f0103ebd:	89 e5                	mov    %esp,%ebp
f0103ebf:	53                   	push   %ebx
f0103ec0:	83 ec 0c             	sub    $0xc,%esp
f0103ec3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103ec6:	ff 33                	push   (%ebx)
f0103ec8:	68 84 77 10 f0       	push   $0xf0107784
f0103ecd:	e8 b8 fa ff ff       	call   f010398a <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103ed2:	83 c4 08             	add    $0x8,%esp
f0103ed5:	ff 73 04             	push   0x4(%ebx)
f0103ed8:	68 93 77 10 f0       	push   $0xf0107793
f0103edd:	e8 a8 fa ff ff       	call   f010398a <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103ee2:	83 c4 08             	add    $0x8,%esp
f0103ee5:	ff 73 08             	push   0x8(%ebx)
f0103ee8:	68 a2 77 10 f0       	push   $0xf01077a2
f0103eed:	e8 98 fa ff ff       	call   f010398a <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103ef2:	83 c4 08             	add    $0x8,%esp
f0103ef5:	ff 73 0c             	push   0xc(%ebx)
f0103ef8:	68 b1 77 10 f0       	push   $0xf01077b1
f0103efd:	e8 88 fa ff ff       	call   f010398a <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103f02:	83 c4 08             	add    $0x8,%esp
f0103f05:	ff 73 10             	push   0x10(%ebx)
f0103f08:	68 c0 77 10 f0       	push   $0xf01077c0
f0103f0d:	e8 78 fa ff ff       	call   f010398a <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103f12:	83 c4 08             	add    $0x8,%esp
f0103f15:	ff 73 14             	push   0x14(%ebx)
f0103f18:	68 cf 77 10 f0       	push   $0xf01077cf
f0103f1d:	e8 68 fa ff ff       	call   f010398a <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103f22:	83 c4 08             	add    $0x8,%esp
f0103f25:	ff 73 18             	push   0x18(%ebx)
f0103f28:	68 de 77 10 f0       	push   $0xf01077de
f0103f2d:	e8 58 fa ff ff       	call   f010398a <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103f32:	83 c4 08             	add    $0x8,%esp
f0103f35:	ff 73 1c             	push   0x1c(%ebx)
f0103f38:	68 ed 77 10 f0       	push   $0xf01077ed
f0103f3d:	e8 48 fa ff ff       	call   f010398a <cprintf>
}
f0103f42:	83 c4 10             	add    $0x10,%esp
f0103f45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103f48:	c9                   	leave  
f0103f49:	c3                   	ret    

f0103f4a <print_trapframe>:
{
f0103f4a:	55                   	push   %ebp
f0103f4b:	89 e5                	mov    %esp,%ebp
f0103f4d:	56                   	push   %esi
f0103f4e:	53                   	push   %ebx
f0103f4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103f52:	e8 85 1e 00 00       	call   f0105ddc <cpunum>
f0103f57:	83 ec 04             	sub    $0x4,%esp
f0103f5a:	50                   	push   %eax
f0103f5b:	53                   	push   %ebx
f0103f5c:	68 51 78 10 f0       	push   $0xf0107851
f0103f61:	e8 24 fa ff ff       	call   f010398a <cprintf>
	print_regs(&tf->tf_regs);
f0103f66:	89 1c 24             	mov    %ebx,(%esp)
f0103f69:	e8 4e ff ff ff       	call   f0103ebc <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103f6e:	83 c4 08             	add    $0x8,%esp
f0103f71:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103f75:	50                   	push   %eax
f0103f76:	68 6f 78 10 f0       	push   $0xf010786f
f0103f7b:	e8 0a fa ff ff       	call   f010398a <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103f80:	83 c4 08             	add    $0x8,%esp
f0103f83:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103f87:	50                   	push   %eax
f0103f88:	68 82 78 10 f0       	push   $0xf0107882
f0103f8d:	e8 f8 f9 ff ff       	call   f010398a <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f92:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103f95:	83 c4 10             	add    $0x10,%esp
f0103f98:	83 f8 13             	cmp    $0x13,%eax
f0103f9b:	0f 86 da 00 00 00    	jbe    f010407b <print_trapframe+0x131>
		return "System call";
f0103fa1:	ba fc 77 10 f0       	mov    $0xf01077fc,%edx
	if (trapno == T_SYSCALL)
f0103fa6:	83 f8 30             	cmp    $0x30,%eax
f0103fa9:	74 13                	je     f0103fbe <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103fab:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0103fae:	83 fa 0f             	cmp    $0xf,%edx
f0103fb1:	ba 08 78 10 f0       	mov    $0xf0107808,%edx
f0103fb6:	b9 17 78 10 f0       	mov    $0xf0107817,%ecx
f0103fbb:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103fbe:	83 ec 04             	sub    $0x4,%esp
f0103fc1:	52                   	push   %edx
f0103fc2:	50                   	push   %eax
f0103fc3:	68 95 78 10 f0       	push   $0xf0107895
f0103fc8:	e8 bd f9 ff ff       	call   f010398a <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103fcd:	83 c4 10             	add    $0x10,%esp
f0103fd0:	39 1d 80 7a 21 f0    	cmp    %ebx,0xf0217a80
f0103fd6:	0f 84 ab 00 00 00    	je     f0104087 <print_trapframe+0x13d>
	cprintf("  err  0x%08x", tf->tf_err);
f0103fdc:	83 ec 08             	sub    $0x8,%esp
f0103fdf:	ff 73 2c             	push   0x2c(%ebx)
f0103fe2:	68 b6 78 10 f0       	push   $0xf01078b6
f0103fe7:	e8 9e f9 ff ff       	call   f010398a <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103fec:	83 c4 10             	add    $0x10,%esp
f0103fef:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ff3:	0f 85 b1 00 00 00    	jne    f01040aa <print_trapframe+0x160>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103ff9:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103ffc:	a8 01                	test   $0x1,%al
f0103ffe:	b9 2a 78 10 f0       	mov    $0xf010782a,%ecx
f0104003:	ba 35 78 10 f0       	mov    $0xf0107835,%edx
f0104008:	0f 44 ca             	cmove  %edx,%ecx
f010400b:	a8 02                	test   $0x2,%al
f010400d:	ba 41 78 10 f0       	mov    $0xf0107841,%edx
f0104012:	be 47 78 10 f0       	mov    $0xf0107847,%esi
f0104017:	0f 44 d6             	cmove  %esi,%edx
f010401a:	a8 04                	test   $0x4,%al
f010401c:	b8 4c 78 10 f0       	mov    $0xf010784c,%eax
f0104021:	be 81 79 10 f0       	mov    $0xf0107981,%esi
f0104026:	0f 44 c6             	cmove  %esi,%eax
f0104029:	51                   	push   %ecx
f010402a:	52                   	push   %edx
f010402b:	50                   	push   %eax
f010402c:	68 c4 78 10 f0       	push   $0xf01078c4
f0104031:	e8 54 f9 ff ff       	call   f010398a <cprintf>
f0104036:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104039:	83 ec 08             	sub    $0x8,%esp
f010403c:	ff 73 30             	push   0x30(%ebx)
f010403f:	68 d3 78 10 f0       	push   $0xf01078d3
f0104044:	e8 41 f9 ff ff       	call   f010398a <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104049:	83 c4 08             	add    $0x8,%esp
f010404c:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104050:	50                   	push   %eax
f0104051:	68 e2 78 10 f0       	push   $0xf01078e2
f0104056:	e8 2f f9 ff ff       	call   f010398a <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010405b:	83 c4 08             	add    $0x8,%esp
f010405e:	ff 73 38             	push   0x38(%ebx)
f0104061:	68 f5 78 10 f0       	push   $0xf01078f5
f0104066:	e8 1f f9 ff ff       	call   f010398a <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010406b:	83 c4 10             	add    $0x10,%esp
f010406e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104072:	75 4b                	jne    f01040bf <print_trapframe+0x175>
}
f0104074:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104077:	5b                   	pop    %ebx
f0104078:	5e                   	pop    %esi
f0104079:	5d                   	pop    %ebp
f010407a:	c3                   	ret    
		return excnames[trapno];
f010407b:	8b 14 85 e0 7b 10 f0 	mov    -0xfef8420(,%eax,4),%edx
f0104082:	e9 37 ff ff ff       	jmp    f0103fbe <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104087:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010408b:	0f 85 4b ff ff ff    	jne    f0103fdc <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104091:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104094:	83 ec 08             	sub    $0x8,%esp
f0104097:	50                   	push   %eax
f0104098:	68 a7 78 10 f0       	push   $0xf01078a7
f010409d:	e8 e8 f8 ff ff       	call   f010398a <cprintf>
f01040a2:	83 c4 10             	add    $0x10,%esp
f01040a5:	e9 32 ff ff ff       	jmp    f0103fdc <print_trapframe+0x92>
		cprintf("\n");
f01040aa:	83 ec 0c             	sub    $0xc,%esp
f01040ad:	68 93 6c 10 f0       	push   $0xf0106c93
f01040b2:	e8 d3 f8 ff ff       	call   f010398a <cprintf>
f01040b7:	83 c4 10             	add    $0x10,%esp
f01040ba:	e9 7a ff ff ff       	jmp    f0104039 <print_trapframe+0xef>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01040bf:	83 ec 08             	sub    $0x8,%esp
f01040c2:	ff 73 3c             	push   0x3c(%ebx)
f01040c5:	68 04 79 10 f0       	push   $0xf0107904
f01040ca:	e8 bb f8 ff ff       	call   f010398a <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01040cf:	83 c4 08             	add    $0x8,%esp
f01040d2:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01040d6:	50                   	push   %eax
f01040d7:	68 13 79 10 f0       	push   $0xf0107913
f01040dc:	e8 a9 f8 ff ff       	call   f010398a <cprintf>
f01040e1:	83 c4 10             	add    $0x10,%esp
}
f01040e4:	eb 8e                	jmp    f0104074 <print_trapframe+0x12a>

f01040e6 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01040e6:	55                   	push   %ebp
f01040e7:	89 e5                	mov    %esp,%ebp
f01040e9:	57                   	push   %edi
f01040ea:	56                   	push   %esi
f01040eb:	53                   	push   %ebx
f01040ec:	83 ec 0c             	sub    $0xc,%esp
f01040ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01040f2:	0f 20 d6             	mov    %cr2,%esi
	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	// LAB 3: Your code here.  CPL为0时，为内核态。
	if( (tf->tf_cs & 3) == 0) panic("page_fault in kernel mode, fault address %u\n", fault_va);
f01040f5:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01040f9:	74 5d                	je     f0104158 <page_fault_handler+0x72>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.
	//注意， 其实并没有切换环境！！
	if (curenv->env_pgfault_upcall){
f01040fb:	e8 dc 1c 00 00       	call   f0105ddc <cpunum>
f0104100:	6b c0 74             	imul   $0x74,%eax,%eax
f0104103:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104109:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010410d:	75 5e                	jne    f010416d <page_fault_handler+0x87>
		curenv->env_tf.tf_esp        = (uint32_t) utf;

		env_run(curenv);
	}else{
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010410f:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f0104112:	e8 c5 1c 00 00       	call   f0105ddc <cpunum>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104117:	57                   	push   %edi
f0104118:	56                   	push   %esi
			curenv->env_id, fault_va, tf->tf_eip);
f0104119:	6b c0 74             	imul   $0x74,%eax,%eax
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010411c:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104122:	ff 70 48             	push   0x48(%eax)
f0104125:	68 fc 7a 10 f0       	push   $0xf0107afc
f010412a:	e8 5b f8 ff ff       	call   f010398a <cprintf>
		print_trapframe(tf);
f010412f:	89 1c 24             	mov    %ebx,(%esp)
f0104132:	e8 13 fe ff ff       	call   f0103f4a <print_trapframe>
		env_destroy(curenv);	
f0104137:	e8 a0 1c 00 00       	call   f0105ddc <cpunum>
f010413c:	83 c4 04             	add    $0x4,%esp
f010413f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104142:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f0104148:	e8 03 f5 ff ff       	call   f0103650 <env_destroy>
	}
}
f010414d:	83 c4 10             	add    $0x10,%esp
f0104150:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104153:	5b                   	pop    %ebx
f0104154:	5e                   	pop    %esi
f0104155:	5f                   	pop    %edi
f0104156:	5d                   	pop    %ebp
f0104157:	c3                   	ret    
	if( (tf->tf_cs & 3) == 0) panic("page_fault in kernel mode, fault address %u\n", fault_va);
f0104158:	56                   	push   %esi
f0104159:	68 cc 7a 10 f0       	push   $0xf0107acc
f010415e:	68 7b 01 00 00       	push   $0x17b
f0104163:	68 26 79 10 f0       	push   $0xf0107926
f0104168:	e8 d3 be ff ff       	call   f0100040 <_panic>
		if(UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1) // 发生异常时陷入。
f010416d:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104170:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f0104176:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
		if(UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1) // 发生异常时陷入。
f010417b:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104181:	77 05                	ja     f0104188 <page_fault_handler+0xa2>
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);//要求的32位空字。
f0104183:	83 e8 38             	sub    $0x38,%eax
f0104186:	89 c7                	mov    %eax,%edi
		user_mem_assert(curenv, (const void *) utf, sizeof(struct UTrapframe), PTE_P|PTE_W);
f0104188:	e8 4f 1c 00 00       	call   f0105ddc <cpunum>
f010418d:	6a 03                	push   $0x3
f010418f:	6a 34                	push   $0x34
f0104191:	57                   	push   %edi
f0104192:	6b c0 74             	imul   $0x74,%eax,%eax
f0104195:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f010419b:	e8 1f ee ff ff       	call   f0102fbf <user_mem_assert>
		utf->utf_fault_va = fault_va;
f01041a0:	89 fa                	mov    %edi,%edx
f01041a2:	89 37                	mov    %esi,(%edi)
		utf->utf_err      = tf->tf_trapno;
f01041a4:	8b 43 28             	mov    0x28(%ebx),%eax
f01041a7:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs     = tf->tf_regs;
f01041aa:	8d 7f 08             	lea    0x8(%edi),%edi
f01041ad:	b9 08 00 00 00       	mov    $0x8,%ecx
f01041b2:	89 de                	mov    %ebx,%esi
f01041b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eflags   = tf->tf_eflags;
f01041b6:	8b 43 38             	mov    0x38(%ebx),%eax
f01041b9:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_eip      = tf->tf_eip;
f01041bc:	8b 43 30             	mov    0x30(%ebx),%eax
f01041bf:	89 d7                	mov    %edx,%edi
f01041c1:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_esp      = tf->tf_esp;
f01041c4:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01041c7:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uint32_t) curenv->env_pgfault_upcall;
f01041ca:	e8 0d 1c 00 00       	call   f0105ddc <cpunum>
f01041cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01041d2:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f01041d8:	8b 58 64             	mov    0x64(%eax),%ebx
f01041db:	e8 fc 1b 00 00       	call   f0105ddc <cpunum>
f01041e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01041e3:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f01041e9:	89 58 30             	mov    %ebx,0x30(%eax)
		curenv->env_tf.tf_esp        = (uint32_t) utf;
f01041ec:	e8 eb 1b 00 00       	call   f0105ddc <cpunum>
f01041f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01041f4:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f01041fa:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f01041fd:	e8 da 1b 00 00       	call   f0105ddc <cpunum>
f0104202:	83 c4 04             	add    $0x4,%esp
f0104205:	6b c0 74             	imul   $0x74,%eax,%eax
f0104208:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f010420e:	e8 dc f4 ff ff       	call   f01036ef <env_run>

f0104213 <trap>:
{
f0104213:	55                   	push   %ebp
f0104214:	89 e5                	mov    %esp,%ebp
f0104216:	57                   	push   %edi
f0104217:	56                   	push   %esi
f0104218:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f010421b:	fc                   	cld    
	if (panicstr)
f010421c:	83 3d 00 70 21 f0 00 	cmpl   $0x0,0xf0217000
f0104223:	74 01                	je     f0104226 <trap+0x13>
		asm volatile("hlt");
f0104225:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104226:	e8 b1 1b 00 00       	call   f0105ddc <cpunum>
f010422b:	6b d0 74             	imul   $0x74,%eax,%edx
f010422e:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104231:	b8 01 00 00 00       	mov    $0x1,%eax
f0104236:	f0 87 82 20 80 25 f0 	lock xchg %eax,-0xfda7fe0(%edx)
f010423d:	83 f8 02             	cmp    $0x2,%eax
f0104240:	74 30                	je     f0104272 <trap+0x5f>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104242:	9c                   	pushf  
f0104243:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104244:	f6 c4 02             	test   $0x2,%ah
f0104247:	75 3b                	jne    f0104284 <trap+0x71>
	if ((tf->tf_cs & 3) == 3) {
f0104249:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010424d:	83 e0 03             	and    $0x3,%eax
f0104250:	66 83 f8 03          	cmp    $0x3,%ax
f0104254:	74 47                	je     f010429d <trap+0x8a>
	last_tf = tf;
f0104256:	89 35 80 7a 21 f0    	mov    %esi,0xf0217a80
	switch(tf->tf_trapno) 
f010425c:	8b 46 28             	mov    0x28(%esi),%eax
f010425f:	83 e8 03             	sub    $0x3,%eax
f0104262:	83 f8 2d             	cmp    $0x2d,%eax
f0104265:	0f 87 82 01 00 00    	ja     f01043ed <trap+0x1da>
f010426b:	ff 24 85 20 7b 10 f0 	jmp    *-0xfef84e0(,%eax,4)
	spin_lock(&kernel_lock);
f0104272:	83 ec 0c             	sub    $0xc,%esp
f0104275:	68 c0 53 12 f0       	push   $0xf01253c0
f010427a:	e8 cd 1d 00 00       	call   f010604c <spin_lock>
}
f010427f:	83 c4 10             	add    $0x10,%esp
f0104282:	eb be                	jmp    f0104242 <trap+0x2f>
	assert(!(read_eflags() & FL_IF));
f0104284:	68 32 79 10 f0       	push   $0xf0107932
f0104289:	68 b5 69 10 f0       	push   $0xf01069b5
f010428e:	68 46 01 00 00       	push   $0x146
f0104293:	68 26 79 10 f0       	push   $0xf0107926
f0104298:	e8 a3 bd ff ff       	call   f0100040 <_panic>
	spin_lock(&kernel_lock);
f010429d:	83 ec 0c             	sub    $0xc,%esp
f01042a0:	68 c0 53 12 f0       	push   $0xf01253c0
f01042a5:	e8 a2 1d 00 00       	call   f010604c <spin_lock>
		assert(curenv);
f01042aa:	e8 2d 1b 00 00       	call   f0105ddc <cpunum>
f01042af:	6b c0 74             	imul   $0x74,%eax,%eax
f01042b2:	83 c4 10             	add    $0x10,%esp
f01042b5:	83 b8 28 80 25 f0 00 	cmpl   $0x0,-0xfda7fd8(%eax)
f01042bc:	74 3e                	je     f01042fc <trap+0xe9>
		if (curenv->env_status == ENV_DYING) {
f01042be:	e8 19 1b 00 00       	call   f0105ddc <cpunum>
f01042c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01042c6:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f01042cc:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01042d0:	74 43                	je     f0104315 <trap+0x102>
		curenv->env_tf = *tf;
f01042d2:	e8 05 1b 00 00       	call   f0105ddc <cpunum>
f01042d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01042da:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f01042e0:	b9 11 00 00 00       	mov    $0x11,%ecx
f01042e5:	89 c7                	mov    %eax,%edi
f01042e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01042e9:	e8 ee 1a 00 00       	call   f0105ddc <cpunum>
f01042ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f1:	8b b0 28 80 25 f0    	mov    -0xfda7fd8(%eax),%esi
f01042f7:	e9 5a ff ff ff       	jmp    f0104256 <trap+0x43>
		assert(curenv);
f01042fc:	68 4b 79 10 f0       	push   $0xf010794b
f0104301:	68 b5 69 10 f0       	push   $0xf01069b5
f0104306:	68 4f 01 00 00       	push   $0x14f
f010430b:	68 26 79 10 f0       	push   $0xf0107926
f0104310:	e8 2b bd ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f0104315:	e8 c2 1a 00 00       	call   f0105ddc <cpunum>
f010431a:	83 ec 0c             	sub    $0xc,%esp
f010431d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104320:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f0104326:	e8 7b f1 ff ff       	call   f01034a6 <env_free>
			curenv = NULL;
f010432b:	e8 ac 1a 00 00       	call   f0105ddc <cpunum>
f0104330:	6b c0 74             	imul   $0x74,%eax,%eax
f0104333:	c7 80 28 80 25 f0 00 	movl   $0x0,-0xfda7fd8(%eax)
f010433a:	00 00 00 
			sched_yield();
f010433d:	e8 71 02 00 00       	call   f01045b3 <sched_yield>
			page_fault_handler(tf);
f0104342:	83 ec 0c             	sub    $0xc,%esp
f0104345:	56                   	push   %esi
f0104346:	e8 9b fd ff ff       	call   f01040e6 <page_fault_handler>
			break; 
f010434b:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f010434e:	e8 89 1a 00 00       	call   f0105ddc <cpunum>
f0104353:	6b c0 74             	imul   $0x74,%eax,%eax
f0104356:	83 b8 28 80 25 f0 00 	cmpl   $0x0,-0xfda7fd8(%eax)
f010435d:	74 18                	je     f0104377 <trap+0x164>
f010435f:	e8 78 1a 00 00       	call   f0105ddc <cpunum>
f0104364:	6b c0 74             	imul   $0x74,%eax,%eax
f0104367:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f010436d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104371:	0f 84 be 00 00 00    	je     f0104435 <trap+0x222>
		sched_yield();
f0104377:	e8 37 02 00 00       	call   f01045b3 <sched_yield>
			monitor(tf);
f010437c:	83 ec 0c             	sub    $0xc,%esp
f010437f:	56                   	push   %esi
f0104380:	e8 ec c5 ff ff       	call   f0100971 <monitor>
			break;
f0104385:	83 c4 10             	add    $0x10,%esp
f0104388:	eb c4                	jmp    f010434e <trap+0x13b>
			int32_t ret=syscall(tf->tf_regs.reg_eax, /*lab的文档中说应用程序将在寄存器中传递系统调用编号和系统调用参数。这样，内核就不需要遍历用户环境的栈或指令流。系统调用编号将进入%eax。但是在哪里实现的我也不清楚。*/
f010438a:	83 ec 08             	sub    $0x8,%esp
f010438d:	ff 76 04             	push   0x4(%esi)
f0104390:	ff 36                	push   (%esi)
f0104392:	ff 76 10             	push   0x10(%esi)
f0104395:	ff 76 18             	push   0x18(%esi)
f0104398:	ff 76 14             	push   0x14(%esi)
f010439b:	ff 76 1c             	push   0x1c(%esi)
f010439e:	e8 97 02 00 00       	call   f010463a <syscall>
			tf->tf_regs.reg_eax = ret;//将返回值传递回%eax，其将被传递回用户进程
f01043a3:	89 46 1c             	mov    %eax,0x1c(%esi)
			break;
f01043a6:	83 c4 20             	add    $0x20,%esp
f01043a9:	eb a3                	jmp    f010434e <trap+0x13b>
			cprintf("Spurious interrupt on irq 7\n");
f01043ab:	83 ec 0c             	sub    $0xc,%esp
f01043ae:	68 52 79 10 f0       	push   $0xf0107952
f01043b3:	e8 d2 f5 ff ff       	call   f010398a <cprintf>
			print_trapframe(tf);
f01043b8:	89 34 24             	mov    %esi,(%esp)
f01043bb:	e8 8a fb ff ff       	call   f0103f4a <print_trapframe>
			break;
f01043c0:	83 c4 10             	add    $0x10,%esp
f01043c3:	eb 89                	jmp    f010434e <trap+0x13b>
			lapic_eoi();
f01043c5:	e8 59 1b 00 00       	call   f0105f23 <lapic_eoi>
			sched_yield();
f01043ca:	e8 e4 01 00 00       	call   f01045b3 <sched_yield>
			lapic_eoi();
f01043cf:	e8 4f 1b 00 00       	call   f0105f23 <lapic_eoi>
			kbd_intr();
f01043d4:	e8 10 c2 ff ff       	call   f01005e9 <kbd_intr>
			break;
f01043d9:	e9 70 ff ff ff       	jmp    f010434e <trap+0x13b>
			lapic_eoi();
f01043de:	e8 40 1b 00 00       	call   f0105f23 <lapic_eoi>
			serial_intr();
f01043e3:	e8 e5 c1 ff ff       	call   f01005cd <serial_intr>
			break;
f01043e8:	e9 61 ff ff ff       	jmp    f010434e <trap+0x13b>
			print_trapframe(tf);
f01043ed:	83 ec 0c             	sub    $0xc,%esp
f01043f0:	56                   	push   %esi
f01043f1:	e8 54 fb ff ff       	call   f0103f4a <print_trapframe>
			if (tf->tf_cs == GD_KT)
f01043f6:	83 c4 10             	add    $0x10,%esp
f01043f9:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01043fe:	74 1e                	je     f010441e <trap+0x20b>
				env_destroy(curenv);
f0104400:	e8 d7 19 00 00       	call   f0105ddc <cpunum>
f0104405:	83 ec 0c             	sub    $0xc,%esp
f0104408:	6b c0 74             	imul   $0x74,%eax,%eax
f010440b:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f0104411:	e8 3a f2 ff ff       	call   f0103650 <env_destroy>
				return;
f0104416:	83 c4 10             	add    $0x10,%esp
f0104419:	e9 30 ff ff ff       	jmp    f010434e <trap+0x13b>
				panic("unhandled trap in kernel");
f010441e:	83 ec 04             	sub    $0x4,%esp
f0104421:	68 6f 79 10 f0       	push   $0xf010796f
f0104426:	68 2a 01 00 00       	push   $0x12a
f010442b:	68 26 79 10 f0       	push   $0xf0107926
f0104430:	e8 0b bc ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f0104435:	e8 a2 19 00 00       	call   f0105ddc <cpunum>
f010443a:	83 ec 0c             	sub    $0xc,%esp
f010443d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104440:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f0104446:	e8 a4 f2 ff ff       	call   f01036ef <env_run>
f010444b:	90                   	nop

f010444c <DIVIDE_HANDLER>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 //参见练习3中的 9.1 、9.10中的表，以及inc/trap.h 来完成这一部分。
TRAPHANDLER_NOEC(DIVIDE_HANDLER, T_DIVIDE);
f010444c:	6a 00                	push   $0x0
f010444e:	6a 00                	push   $0x0
f0104450:	e9 83 00 00 00       	jmp    f01044d8 <_alltraps>
f0104455:	90                   	nop

f0104456 <DEBUG_HANDLER>:
TRAPHANDLER_NOEC(DEBUG_HANDLER, T_DEBUG);
f0104456:	6a 00                	push   $0x0
f0104458:	6a 01                	push   $0x1
f010445a:	eb 7c                	jmp    f01044d8 <_alltraps>

f010445c <NMI_HANDLER>:
TRAPHANDLER_NOEC(NMI_HANDLER, T_NMI);
f010445c:	6a 00                	push   $0x0
f010445e:	6a 02                	push   $0x2
f0104460:	eb 76                	jmp    f01044d8 <_alltraps>

f0104462 <BRKPT_HANDLER>:
TRAPHANDLER_NOEC(BRKPT_HANDLER, T_BRKPT);
f0104462:	6a 00                	push   $0x0
f0104464:	6a 03                	push   $0x3
f0104466:	eb 70                	jmp    f01044d8 <_alltraps>

f0104468 <OFLOW_HANDLER>:
TRAPHANDLER_NOEC(OFLOW_HANDLER, T_OFLOW);
f0104468:	6a 00                	push   $0x0
f010446a:	6a 04                	push   $0x4
f010446c:	eb 6a                	jmp    f01044d8 <_alltraps>

f010446e <BOUND_HANDLER>:
TRAPHANDLER_NOEC(BOUND_HANDLER, T_BOUND);
f010446e:	6a 00                	push   $0x0
f0104470:	6a 05                	push   $0x5
f0104472:	eb 64                	jmp    f01044d8 <_alltraps>

f0104474 <ILLOP_HANDLER>:
TRAPHANDLER_NOEC(ILLOP_HANDLER, T_ILLOP);
f0104474:	6a 00                	push   $0x0
f0104476:	6a 06                	push   $0x6
f0104478:	eb 5e                	jmp    f01044d8 <_alltraps>

f010447a <DEVICE_HANDLER>:
TRAPHANDLER_NOEC(DEVICE_HANDLER, T_DEVICE);
f010447a:	6a 00                	push   $0x0
f010447c:	6a 07                	push   $0x7
f010447e:	eb 58                	jmp    f01044d8 <_alltraps>

f0104480 <DBLFLT_HANDLER>:
TRAPHANDLER(DBLFLT_HANDLER, T_DBLFLT);
f0104480:	6a 08                	push   $0x8
f0104482:	eb 54                	jmp    f01044d8 <_alltraps>

f0104484 <TSS_HANDLER>:
/* reserved */
TRAPHANDLER(TSS_HANDLER, T_TSS);
f0104484:	6a 0a                	push   $0xa
f0104486:	eb 50                	jmp    f01044d8 <_alltraps>

f0104488 <SEGNP_HANDLER>:
TRAPHANDLER(SEGNP_HANDLER, T_SEGNP);
f0104488:	6a 0b                	push   $0xb
f010448a:	eb 4c                	jmp    f01044d8 <_alltraps>

f010448c <STACK_HANDLER>:
TRAPHANDLER(STACK_HANDLER, T_STACK);
f010448c:	6a 0c                	push   $0xc
f010448e:	eb 48                	jmp    f01044d8 <_alltraps>

f0104490 <GPFLT_HANDLER>:
TRAPHANDLER(GPFLT_HANDLER, T_GPFLT);
f0104490:	6a 0d                	push   $0xd
f0104492:	eb 44                	jmp    f01044d8 <_alltraps>

f0104494 <PGFLT_HANDLER>:
TRAPHANDLER(PGFLT_HANDLER, T_PGFLT);
f0104494:	6a 0e                	push   $0xe
f0104496:	eb 40                	jmp    f01044d8 <_alltraps>

f0104498 <FPERR_HANDLER>:
/* reserved */
TRAPHANDLER_NOEC(FPERR_HANDLER, T_FPERR);
f0104498:	6a 00                	push   $0x0
f010449a:	6a 10                	push   $0x10
f010449c:	eb 3a                	jmp    f01044d8 <_alltraps>

f010449e <ALIGN_HANDLER>:
TRAPHANDLER(ALIGN_HANDLER, T_ALIGN);
f010449e:	6a 11                	push   $0x11
f01044a0:	eb 36                	jmp    f01044d8 <_alltraps>

f01044a2 <MCHK_HANDLER>:
TRAPHANDLER_NOEC(MCHK_HANDLER, T_MCHK);
f01044a2:	6a 00                	push   $0x0
f01044a4:	6a 12                	push   $0x12
f01044a6:	eb 30                	jmp    f01044d8 <_alltraps>

f01044a8 <SIMDERR_HANDLER>:
TRAPHANDLER_NOEC(SIMDERR_HANDLER, T_SIMDERR);
f01044a8:	6a 00                	push   $0x0
f01044aa:	6a 13                	push   $0x13
f01044ac:	eb 2a                	jmp    f01044d8 <_alltraps>

f01044ae <SYSCALL_HANDLER>:

//exercise 7 syscall
TRAPHANDLER_NOEC(SYSCALL_HANDLER, T_SYSCALL);
f01044ae:	6a 00                	push   $0x0
f01044b0:	6a 30                	push   $0x30
f01044b2:	eb 24                	jmp    f01044d8 <_alltraps>

f01044b4 <timer_handler>:

//lab4 exercise 13
//IRQS 
TRAPHANDLER_NOEC(timer_handler, IRQ_OFFSET + IRQ_TIMER);
f01044b4:	6a 00                	push   $0x0
f01044b6:	6a 20                	push   $0x20
f01044b8:	eb 1e                	jmp    f01044d8 <_alltraps>

f01044ba <kbd_handler>:
TRAPHANDLER_NOEC(kbd_handler, IRQ_OFFSET + IRQ_KBD);
f01044ba:	6a 00                	push   $0x0
f01044bc:	6a 21                	push   $0x21
f01044be:	eb 18                	jmp    f01044d8 <_alltraps>

f01044c0 <serial_handler>:
TRAPHANDLER_NOEC(serial_handler, IRQ_OFFSET + IRQ_SERIAL);
f01044c0:	6a 00                	push   $0x0
f01044c2:	6a 24                	push   $0x24
f01044c4:	eb 12                	jmp    f01044d8 <_alltraps>

f01044c6 <spurious_handler>:
TRAPHANDLER_NOEC(spurious_handler, IRQ_OFFSET + IRQ_SPURIOUS);
f01044c6:	6a 00                	push   $0x0
f01044c8:	6a 27                	push   $0x27
f01044ca:	eb 0c                	jmp    f01044d8 <_alltraps>

f01044cc <ide_handler>:
TRAPHANDLER_NOEC(ide_handler, IRQ_OFFSET + IRQ_IDE);
f01044cc:	6a 00                	push   $0x0
f01044ce:	6a 2e                	push   $0x2e
f01044d0:	eb 06                	jmp    f01044d8 <_alltraps>

f01044d2 <error_handler>:
TRAPHANDLER_NOEC(error_handler, IRQ_OFFSET + IRQ_ERROR);
f01044d2:	6a 00                	push   $0x0
f01044d4:	6a 33                	push   $0x33
f01044d6:	eb 00                	jmp    f01044d8 <_alltraps>

f01044d8 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
 	//别忘了栈由高地址向低地址生长，于是Trapframe顺序变为tf_trapno（上面两个宏已经把num压栈了），ds，es，PushRegs的反向
	pushl %ds
f01044d8:	1e                   	push   %ds
	pushl %es
f01044d9:	06                   	push   %es
	pushal
f01044da:	60                   	pusha  
	//
	movw $GD_KD, %ax 
f01044db:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f01044df:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f01044e1:	8e c0                	mov    %eax,%es
	movw GD_KD, %ds
	movw GD_KD, %es
	*/
	
	//这是作为trap(struct Trapframe *tf)的参数的
	pushl %esp
f01044e3:	54                   	push   %esp
	//调用trap
	call trap
f01044e4:	e8 2a fd ff ff       	call   f0104213 <trap>

f01044e9 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01044e9:	55                   	push   %ebp
f01044ea:	89 e5                	mov    %esp,%ebp
f01044ec:	83 ec 08             	sub    $0x8,%esp
f01044ef:	a1 70 72 21 f0       	mov    0xf0217270,%eax
f01044f4:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044f7:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01044fc:	8b 02                	mov    (%edx),%eax
f01044fe:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104501:	83 f8 02             	cmp    $0x2,%eax
f0104504:	76 2d                	jbe    f0104533 <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f0104506:	83 c1 01             	add    $0x1,%ecx
f0104509:	83 c2 7c             	add    $0x7c,%edx
f010450c:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104512:	75 e8                	jne    f01044fc <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104514:	83 ec 0c             	sub    $0xc,%esp
f0104517:	68 30 7c 10 f0       	push   $0xf0107c30
f010451c:	e8 69 f4 ff ff       	call   f010398a <cprintf>
f0104521:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104524:	83 ec 0c             	sub    $0xc,%esp
f0104527:	6a 00                	push   $0x0
f0104529:	e8 43 c4 ff ff       	call   f0100971 <monitor>
f010452e:	83 c4 10             	add    $0x10,%esp
f0104531:	eb f1                	jmp    f0104524 <sched_halt+0x3b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104533:	e8 a4 18 00 00       	call   f0105ddc <cpunum>
f0104538:	6b c0 74             	imul   $0x74,%eax,%eax
f010453b:	c7 80 28 80 25 f0 00 	movl   $0x0,-0xfda7fd8(%eax)
f0104542:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104545:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
	if ((uint32_t)kva < KERNBASE)
f010454a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010454f:	76 50                	jbe    f01045a1 <sched_halt+0xb8>
	return (physaddr_t)kva - KERNBASE;
f0104551:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));// %0将被GAS（GNU汇编器）选择的寄存器代替。该行命令也就是 将val值赋给cr3寄存器。
f0104556:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104559:	e8 7e 18 00 00       	call   f0105ddc <cpunum>
f010455e:	6b d0 74             	imul   $0x74,%eax,%edx
f0104561:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104564:	b8 02 00 00 00       	mov    $0x2,%eax
f0104569:	f0 87 82 20 80 25 f0 	lock xchg %eax,-0xfda7fe0(%edx)
	spin_unlock(&kernel_lock);
f0104570:	83 ec 0c             	sub    $0xc,%esp
f0104573:	68 c0 53 12 f0       	push   $0xf01253c0
f0104578:	e8 69 1b 00 00       	call   f01060e6 <spin_unlock>
	asm volatile("pause");
f010457d:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010457f:	e8 58 18 00 00       	call   f0105ddc <cpunum>
f0104584:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f0104587:	8b 80 30 80 25 f0    	mov    -0xfda7fd0(%eax),%eax
f010458d:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104592:	89 c4                	mov    %eax,%esp
f0104594:	6a 00                	push   $0x0
f0104596:	6a 00                	push   $0x0
f0104598:	fb                   	sti    
f0104599:	f4                   	hlt    
f010459a:	eb fd                	jmp    f0104599 <sched_halt+0xb0>
}
f010459c:	83 c4 10             	add    $0x10,%esp
f010459f:	c9                   	leave  
f01045a0:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01045a1:	50                   	push   %eax
f01045a2:	68 68 64 10 f0       	push   $0xf0106468
f01045a7:	6a 4f                	push   $0x4f
f01045a9:	68 59 7c 10 f0       	push   $0xf0107c59
f01045ae:	e8 8d ba ff ff       	call   f0100040 <_panic>

f01045b3 <sched_yield>:
{
f01045b3:	55                   	push   %ebp
f01045b4:	89 e5                	mov    %esp,%ebp
f01045b6:	57                   	push   %edi
f01045b7:	56                   	push   %esi
f01045b8:	53                   	push   %ebx
f01045b9:	83 ec 0c             	sub    $0xc,%esp
	struct Env * now = curenv;
f01045bc:	e8 1b 18 00 00       	call   f0105ddc <cpunum>
f01045c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01045c4:	8b b0 28 80 25 f0    	mov    -0xfda7fd8(%eax),%esi
	int index=-1;//因为这里出错了！！一定是-1！！！
f01045ca:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
	if(now/*定义于kern/env.h。可以看到其已经在lab4中被修改，适应多核*/) index= ENVX(now->env_id);//inc/env.h
f01045cf:	85 f6                	test   %esi,%esi
f01045d1:	74 09                	je     f01045dc <sched_yield+0x29>
f01045d3:	8b 4e 48             	mov    0x48(%esi),%ecx
f01045d6:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
	for(int i=index+1; i<index+NENV;i++){
f01045dc:	8d 51 01             	lea    0x1(%ecx),%edx
		if(envs[i%NENV].env_status == ENV_RUNNABLE){
f01045df:	8b 1d 70 72 21 f0    	mov    0xf0217270,%ebx
	for(int i=index+1; i<index+NENV;i++){
f01045e5:	81 c1 ff 03 00 00    	add    $0x3ff,%ecx
f01045eb:	39 d1                	cmp    %edx,%ecx
f01045ed:	7c 2b                	jl     f010461a <sched_yield+0x67>
		if(envs[i%NENV].env_status == ENV_RUNNABLE){
f01045ef:	89 d7                	mov    %edx,%edi
f01045f1:	c1 ff 1f             	sar    $0x1f,%edi
f01045f4:	c1 ef 16             	shr    $0x16,%edi
f01045f7:	8d 04 3a             	lea    (%edx,%edi,1),%eax
f01045fa:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045ff:	29 f8                	sub    %edi,%eax
f0104601:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104604:	01 d8                	add    %ebx,%eax
f0104606:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f010460a:	74 05                	je     f0104611 <sched_yield+0x5e>
	for(int i=index+1; i<index+NENV;i++){
f010460c:	83 c2 01             	add    $0x1,%edx
f010460f:	eb da                	jmp    f01045eb <sched_yield+0x38>
			env_run(&envs[i%NENV]);
f0104611:	83 ec 0c             	sub    $0xc,%esp
f0104614:	50                   	push   %eax
f0104615:	e8 d5 f0 ff ff       	call   f01036ef <env_run>
	if(now && now->env_status == ENV_RUNNING){
f010461a:	85 f6                	test   %esi,%esi
f010461c:	74 06                	je     f0104624 <sched_yield+0x71>
f010461e:	83 7e 54 03          	cmpl   $0x3,0x54(%esi)
f0104622:	74 0d                	je     f0104631 <sched_yield+0x7e>
	sched_halt();
f0104624:	e8 c0 fe ff ff       	call   f01044e9 <sched_halt>
}
f0104629:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010462c:	5b                   	pop    %ebx
f010462d:	5e                   	pop    %esi
f010462e:	5f                   	pop    %edi
f010462f:	5d                   	pop    %ebp
f0104630:	c3                   	ret    
		env_run(now);
f0104631:	83 ec 0c             	sub    $0xc,%esp
f0104634:	56                   	push   %esi
f0104635:	e8 b5 f0 ff ff       	call   f01036ef <env_run>

f010463a <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
//它应该最终会调用lib/syscall.c中的syscall()。
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010463a:	55                   	push   %ebp
f010463b:	89 e5                	mov    %esp,%ebp
f010463d:	57                   	push   %edi
f010463e:	56                   	push   %esi
f010463f:	53                   	push   %ebx
f0104640:	83 ec 1c             	sub    $0x1c,%esp
f0104643:	8b 45 08             	mov    0x8(%ebp),%eax
	// LAB 3: Your code here.

	// panic("syscall not implemented");
	
	//依据不同的syscallno， 调用lib/system.c中的不同函数
	switch (syscallno) 
f0104646:	83 f8 0d             	cmp    $0xd,%eax
f0104649:	0f 87 c7 05 00 00    	ja     f0104c16 <syscall+0x5dc>
f010464f:	ff 24 85 6c 7c 10 f0 	jmp    *-0xfef8394(,%eax,4)
	user_mem_assert(curenv, s, len, 0);
f0104656:	e8 81 17 00 00       	call   f0105ddc <cpunum>
f010465b:	6a 00                	push   $0x0
f010465d:	ff 75 10             	push   0x10(%ebp)
f0104660:	ff 75 0c             	push   0xc(%ebp)
f0104663:	6b c0 74             	imul   $0x74,%eax,%eax
f0104666:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f010466c:	e8 4e e9 ff ff       	call   f0102fbf <user_mem_assert>
	cprintf("%.*s", len, s);
f0104671:	83 c4 0c             	add    $0xc,%esp
f0104674:	ff 75 0c             	push   0xc(%ebp)
f0104677:	ff 75 10             	push   0x10(%ebp)
f010467a:	68 66 7c 10 f0       	push   $0xf0107c66
f010467f:	e8 06 f3 ff ff       	call   f010398a <cprintf>
}
f0104684:	83 c4 10             	add    $0x10,%esp
	{
		case SYS_cputs:
			sys_cputs( (const char *) a1, a2);
			return 0;
f0104687:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_env_set_trapframe(a1, (struct Trapframe*) a2);
		default:
			return -E_INVAL;
	}
	return 0;
}
f010468c:	89 d8                	mov    %ebx,%eax
f010468e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104691:	5b                   	pop    %ebx
f0104692:	5e                   	pop    %esi
f0104693:	5f                   	pop    %edi
f0104694:	5d                   	pop    %ebp
f0104695:	c3                   	ret    
	return cons_getc();
f0104696:	e8 60 bf ff ff       	call   f01005fb <cons_getc>
f010469b:	89 c3                	mov    %eax,%ebx
			return sys_cgetc();
f010469d:	eb ed                	jmp    f010468c <syscall+0x52>
	return curenv->env_id;
f010469f:	e8 38 17 00 00       	call   f0105ddc <cpunum>
f01046a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01046a7:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f01046ad:	8b 58 48             	mov    0x48(%eax),%ebx
			return sys_getenvid();
f01046b0:	eb da                	jmp    f010468c <syscall+0x52>
	if ((r = envid2env(envid, &e, 1)) < 0)
f01046b2:	83 ec 04             	sub    $0x4,%esp
f01046b5:	6a 01                	push   $0x1
f01046b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046ba:	50                   	push   %eax
f01046bb:	ff 75 0c             	push   0xc(%ebp)
f01046be:	e8 ce e9 ff ff       	call   f0103091 <envid2env>
f01046c3:	89 c3                	mov    %eax,%ebx
f01046c5:	83 c4 10             	add    $0x10,%esp
f01046c8:	85 c0                	test   %eax,%eax
f01046ca:	78 c0                	js     f010468c <syscall+0x52>
	env_destroy(e);
f01046cc:	83 ec 0c             	sub    $0xc,%esp
f01046cf:	ff 75 e4             	push   -0x1c(%ebp)
f01046d2:	e8 79 ef ff ff       	call   f0103650 <env_destroy>
	return 0;
f01046d7:	83 c4 10             	add    $0x10,%esp
f01046da:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_env_destroy(a1);
f01046df:	eb ab                	jmp    f010468c <syscall+0x52>
	sched_yield();
f01046e1:	e8 cd fe ff ff       	call   f01045b3 <sched_yield>
	struct Env *e=NULL;
f01046e6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int error_ret=env_alloc( &e , curenv->env_id);
f01046ed:	e8 ea 16 00 00       	call   f0105ddc <cpunum>
f01046f2:	83 ec 08             	sub    $0x8,%esp
f01046f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01046f8:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f01046fe:	ff 70 48             	push   0x48(%eax)
f0104701:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104704:	50                   	push   %eax
f0104705:	e8 9b ea ff ff       	call   f01031a5 <env_alloc>
f010470a:	89 c3                	mov    %eax,%ebx
	if(error_ret<0 ) return error_ret;
f010470c:	83 c4 10             	add    $0x10,%esp
f010470f:	85 c0                	test   %eax,%eax
f0104711:	0f 88 75 ff ff ff    	js     f010468c <syscall+0x52>
	e->env_status = ENV_NOT_RUNNABLE;
f0104717:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010471a:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf = curenv->env_tf;
f0104721:	e8 b6 16 00 00       	call   f0105ddc <cpunum>
f0104726:	6b c0 74             	imul   $0x74,%eax,%eax
f0104729:	8b b0 28 80 25 f0    	mov    -0xfda7fd8(%eax),%esi
f010472f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104737:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f0104739:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010473c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;	
f0104743:	8b 58 48             	mov    0x48(%eax),%ebx
			return sys_exofork();
f0104746:	e9 41 ff ff ff       	jmp    f010468c <syscall+0x52>
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) return -E_INVAL;  
f010474b:	8b 45 10             	mov    0x10(%ebp),%eax
f010474e:	83 e8 02             	sub    $0x2,%eax
f0104751:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104756:	75 2b                	jne    f0104783 <syscall+0x149>
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f0104758:	83 ec 04             	sub    $0x4,%esp
f010475b:	6a 01                	push   $0x1
f010475d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104760:	50                   	push   %eax
f0104761:	ff 75 0c             	push   0xc(%ebp)
f0104764:	e8 28 e9 ff ff       	call   f0103091 <envid2env>
f0104769:	83 c4 10             	add    $0x10,%esp
f010476c:	85 c0                	test   %eax,%eax
f010476e:	78 1d                	js     f010478d <syscall+0x153>
	e->env_status = status;
f0104770:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104773:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104776:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;	
f0104779:	bb 00 00 00 00       	mov    $0x0,%ebx
f010477e:	e9 09 ff ff ff       	jmp    f010468c <syscall+0x52>
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) return -E_INVAL;  
f0104783:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104788:	e9 ff fe ff ff       	jmp    f010468c <syscall+0x52>
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f010478d:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			return sys_env_set_status(a1,a2);
f0104792:	e9 f5 fe ff ff       	jmp    f010468c <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f0104797:	8b 45 14             	mov    0x14(%ebp),%eax
f010479a:	83 e0 05             	and    $0x5,%eax
f010479d:	83 f8 05             	cmp    $0x5,%eax
f01047a0:	0f 85 86 00 00 00    	jne    f010482c <syscall+0x1f2>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f01047a6:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f01047ad:	0f 85 83 00 00 00    	jne    f0104836 <syscall+0x1fc>
f01047b3:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047ba:	77 7a                	ja     f0104836 <syscall+0x1fc>
f01047bc:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047c3:	75 7b                	jne    f0104840 <syscall+0x206>
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f01047c5:	83 ec 0c             	sub    $0xc,%esp
f01047c8:	6a 01                	push   $0x1
f01047ca:	e8 7a c7 ff ff       	call   f0100f49 <page_alloc>
f01047cf:	89 c6                	mov    %eax,%esi
	if( pp==NULL ) return -E_NO_MEM;
f01047d1:	83 c4 10             	add    $0x10,%esp
f01047d4:	85 c0                	test   %eax,%eax
f01047d6:	74 72                	je     f010484a <syscall+0x210>
	int error_ret=envid2env(envid, &e, 1);
f01047d8:	83 ec 04             	sub    $0x4,%esp
f01047db:	6a 01                	push   $0x1
f01047dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047e0:	50                   	push   %eax
f01047e1:	ff 75 0c             	push   0xc(%ebp)
f01047e4:	e8 a8 e8 ff ff       	call   f0103091 <envid2env>
f01047e9:	89 c3                	mov    %eax,%ebx
	if( error_ret <0 ) return error_ret;//error_ret 其实就是我们调用函数发生错误时的返回值， 这不同函数之间都是一致的。
f01047eb:	83 c4 10             	add    $0x10,%esp
f01047ee:	85 c0                	test   %eax,%eax
f01047f0:	0f 88 96 fe ff ff    	js     f010468c <syscall+0x52>
	error_ret=page_insert(e->env_pgdir, pp, va, perm);
f01047f6:	ff 75 14             	push   0x14(%ebp)
f01047f9:	ff 75 10             	push   0x10(%ebp)
f01047fc:	56                   	push   %esi
f01047fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104800:	ff 70 60             	push   0x60(%eax)
f0104803:	e8 4f ca ff ff       	call   f0101257 <page_insert>
f0104808:	89 c3                	mov    %eax,%ebx
	if(error_ret <0){
f010480a:	83 c4 10             	add    $0x10,%esp
f010480d:	85 c0                	test   %eax,%eax
f010480f:	78 0a                	js     f010481b <syscall+0x1e1>
	return 0;		
f0104811:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_page_alloc(a1,(void *)a2, (int)a3);
f0104816:	e9 71 fe ff ff       	jmp    f010468c <syscall+0x52>
		page_free(pp);
f010481b:	83 ec 0c             	sub    $0xc,%esp
f010481e:	56                   	push   %esi
f010481f:	e8 9a c7 ff ff       	call   f0100fbe <page_free>
		return error_ret;
f0104824:	83 c4 10             	add    $0x10,%esp
f0104827:	e9 60 fe ff ff       	jmp    f010468c <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f010482c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104831:	e9 56 fe ff ff       	jmp    f010468c <syscall+0x52>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f0104836:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010483b:	e9 4c fe ff ff       	jmp    f010468c <syscall+0x52>
f0104840:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104845:	e9 42 fe ff ff       	jmp    f010468c <syscall+0x52>
	if( pp==NULL ) return -E_NO_MEM;
f010484a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010484f:	e9 38 fe ff ff       	jmp    f010468c <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f0104854:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104857:	83 e0 05             	and    $0x5,%eax
f010485a:	83 f8 05             	cmp    $0x5,%eax
f010485d:	0f 85 c0 00 00 00    	jne    f0104923 <syscall+0x2e9>
	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
f0104863:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f010486a:	0f 85 bd 00 00 00    	jne    f010492d <syscall+0x2f3>
f0104870:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104877:	0f 87 b0 00 00 00    	ja     f010492d <syscall+0x2f3>
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
f010487d:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104884:	0f 87 ad 00 00 00    	ja     f0104937 <syscall+0x2fd>
f010488a:	8b 45 10             	mov    0x10(%ebp),%eax
f010488d:	0b 45 18             	or     0x18(%ebp),%eax
f0104890:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104895:	0f 85 a6 00 00 00    	jne    f0104941 <syscall+0x307>
	if (envid2env(srcenvid, &src_e, 1)<0 || envid2env(dstenvid, &dst_e, 1)<0) return -E_BAD_ENV;
f010489b:	83 ec 04             	sub    $0x4,%esp
f010489e:	6a 01                	push   $0x1
f01048a0:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01048a3:	50                   	push   %eax
f01048a4:	ff 75 0c             	push   0xc(%ebp)
f01048a7:	e8 e5 e7 ff ff       	call   f0103091 <envid2env>
f01048ac:	83 c4 10             	add    $0x10,%esp
f01048af:	85 c0                	test   %eax,%eax
f01048b1:	0f 88 94 00 00 00    	js     f010494b <syscall+0x311>
f01048b7:	83 ec 04             	sub    $0x4,%esp
f01048ba:	6a 01                	push   $0x1
f01048bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01048bf:	50                   	push   %eax
f01048c0:	ff 75 14             	push   0x14(%ebp)
f01048c3:	e8 c9 e7 ff ff       	call   f0103091 <envid2env>
f01048c8:	83 c4 10             	add    $0x10,%esp
f01048cb:	85 c0                	test   %eax,%eax
f01048cd:	0f 88 82 00 00 00    	js     f0104955 <syscall+0x31b>
	struct PageInfo *pp = page_lookup(src_e->env_pgdir, srcva, &src_pte);
f01048d3:	83 ec 04             	sub    $0x4,%esp
f01048d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048d9:	50                   	push   %eax
f01048da:	ff 75 10             	push   0x10(%ebp)
f01048dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01048e0:	ff 70 60             	push   0x60(%eax)
f01048e3:	e8 95 c8 ff ff       	call   f010117d <page_lookup>
	if( pp==NULL ) return -E_INVAL;
f01048e8:	83 c4 10             	add    $0x10,%esp
f01048eb:	85 c0                	test   %eax,%eax
f01048ed:	74 70                	je     f010495f <syscall+0x325>
	if ( ( ( *src_pte & PTE_W ) == 0 ) && ( (perm & PTE_W) == PTE_W ) ) return -E_INVAL;
f01048ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048f2:	f6 02 02             	testb  $0x2,(%edx)
f01048f5:	75 06                	jne    f01048fd <syscall+0x2c3>
f01048f7:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01048fb:	75 6c                	jne    f0104969 <syscall+0x32f>
	int error_ret =page_insert(dst_e->env_pgdir, pp, dstva, perm);
f01048fd:	ff 75 1c             	push   0x1c(%ebp)
f0104900:	ff 75 18             	push   0x18(%ebp)
f0104903:	50                   	push   %eax
f0104904:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104907:	ff 70 60             	push   0x60(%eax)
f010490a:	e8 48 c9 ff ff       	call   f0101257 <page_insert>
f010490f:	85 c0                	test   %eax,%eax
f0104911:	ba 00 00 00 00       	mov    $0x0,%edx
f0104916:	0f 4e d0             	cmovle %eax,%edx
f0104919:	89 d3                	mov    %edx,%ebx
f010491b:	83 c4 10             	add    $0x10,%esp
f010491e:	e9 69 fd ff ff       	jmp    f010468c <syscall+0x52>
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
f0104923:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104928:	e9 5f fd ff ff       	jmp    f010468c <syscall+0x52>
	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
f010492d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104932:	e9 55 fd ff ff       	jmp    f010468c <syscall+0x52>
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
f0104937:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010493c:	e9 4b fd ff ff       	jmp    f010468c <syscall+0x52>
f0104941:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104946:	e9 41 fd ff ff       	jmp    f010468c <syscall+0x52>
	if (envid2env(srcenvid, &src_e, 1)<0 || envid2env(dstenvid, &dst_e, 1)<0) return -E_BAD_ENV;
f010494b:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104950:	e9 37 fd ff ff       	jmp    f010468c <syscall+0x52>
f0104955:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010495a:	e9 2d fd ff ff       	jmp    f010468c <syscall+0x52>
	if( pp==NULL ) return -E_INVAL;
f010495f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104964:	e9 23 fd ff ff       	jmp    f010468c <syscall+0x52>
	if ( ( ( *src_pte & PTE_W ) == 0 ) && ( (perm & PTE_W) == PTE_W ) ) return -E_INVAL;
f0104969:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_page_map(a1, (void *)a2, a3, (void*)a4, (int)a5);
f010496e:	e9 19 fd ff ff       	jmp    f010468c <syscall+0x52>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f0104973:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010497a:	77 45                	ja     f01049c1 <syscall+0x387>
f010497c:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104983:	75 46                	jne    f01049cb <syscall+0x391>
	int error_ret=envid2env(envid, &e, 1);
f0104985:	83 ec 04             	sub    $0x4,%esp
f0104988:	6a 01                	push   $0x1
f010498a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010498d:	50                   	push   %eax
f010498e:	ff 75 0c             	push   0xc(%ebp)
f0104991:	e8 fb e6 ff ff       	call   f0103091 <envid2env>
f0104996:	89 c3                	mov    %eax,%ebx
	if( error_ret <0 ) return error_ret;
f0104998:	83 c4 10             	add    $0x10,%esp
f010499b:	85 c0                	test   %eax,%eax
f010499d:	0f 88 e9 fc ff ff    	js     f010468c <syscall+0x52>
	page_remove(e->env_pgdir, va);
f01049a3:	83 ec 08             	sub    $0x8,%esp
f01049a6:	ff 75 10             	push   0x10(%ebp)
f01049a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049ac:	ff 70 60             	push   0x60(%eax)
f01049af:	e8 5d c8 ff ff       	call   f0101211 <page_remove>
	return 0;
f01049b4:	83 c4 10             	add    $0x10,%esp
f01049b7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049bc:	e9 cb fc ff ff       	jmp    f010468c <syscall+0x52>
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f01049c1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049c6:	e9 c1 fc ff ff       	jmp    f010468c <syscall+0x52>
f01049cb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_page_unmap(a1, (void *)a2);
f01049d0:	e9 b7 fc ff ff       	jmp    f010468c <syscall+0x52>
	int error_ret= envid2env(envid, &e, 1);
f01049d5:	83 ec 04             	sub    $0x4,%esp
f01049d8:	6a 01                	push   $0x1
f01049da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049dd:	50                   	push   %eax
f01049de:	ff 75 0c             	push   0xc(%ebp)
f01049e1:	e8 ab e6 ff ff       	call   f0103091 <envid2env>
f01049e6:	89 c3                	mov    %eax,%ebx
	if(error_ret < 0 ) return error_ret;
f01049e8:	83 c4 10             	add    $0x10,%esp
f01049eb:	85 c0                	test   %eax,%eax
f01049ed:	0f 88 99 fc ff ff    	js     f010468c <syscall+0x52>
	e->env_pgfault_upcall = func;
f01049f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01049f9:	89 48 64             	mov    %ecx,0x64(%eax)
	return 0;
f01049fc:	bb 00 00 00 00       	mov    $0x0,%ebx
        		return sys_env_set_pgfault_upcall(a1, (void*) a2);
f0104a01:	e9 86 fc ff ff       	jmp    f010468c <syscall+0x52>
	if ( (r = envid2env( envid, &dstenv, 0)) < 0)  return r;
f0104a06:	83 ec 04             	sub    $0x4,%esp
f0104a09:	6a 00                	push   $0x0
f0104a0b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a0e:	50                   	push   %eax
f0104a0f:	ff 75 0c             	push   0xc(%ebp)
f0104a12:	e8 7a e6 ff ff       	call   f0103091 <envid2env>
f0104a17:	89 c3                	mov    %eax,%ebx
f0104a19:	83 c4 10             	add    $0x10,%esp
f0104a1c:	85 c0                	test   %eax,%eax
f0104a1e:	0f 88 68 fc ff ff    	js     f010468c <syscall+0x52>
	if ( (dstenv->env_ipc_recving != true)  || dstenv->env_ipc_from != 0)  return -E_IPC_NOT_RECV;
f0104a24:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a27:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a2b:	0f 84 05 01 00 00    	je     f0104b36 <syscall+0x4fc>
f0104a31:	8b 58 74             	mov    0x74(%eax),%ebx
f0104a34:	85 db                	test   %ebx,%ebx
f0104a36:	0f 85 04 01 00 00    	jne    f0104b40 <syscall+0x506>
	dstenv->env_ipc_perm=0;//如果没转移页，设置为0
f0104a3c:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	if((uintptr_t) srcva <  UTOP){
f0104a43:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104a4a:	0f 87 8a 00 00 00    	ja     f0104ada <syscall+0x4a0>
		if (  !(perm & PTE_P ) || !(perm & PTE_U) )  return -E_INVAL;
f0104a50:	8b 45 18             	mov    0x18(%ebp),%eax
f0104a53:	83 e0 05             	and    $0x5,%eax
f0104a56:	83 f8 05             	cmp    $0x5,%eax
f0104a59:	0f 85 b2 00 00 00    	jne    f0104b11 <syscall+0x4d7>
		if ( PGOFF(srcva) )  return -E_INVAL;
f0104a5f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a62:	25 ff 0f 00 00       	and    $0xfff,%eax
		if (perm &  (~ PTE_SYSCALL))   return -E_INVAL; 
f0104a67:	8b 55 18             	mov    0x18(%ebp),%edx
f0104a6a:	81 e2 f8 f1 ff ff    	and    $0xfffff1f8,%edx
f0104a70:	09 d0                	or     %edx,%eax
f0104a72:	74 0a                	je     f0104a7e <syscall+0x444>
f0104a74:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a79:	e9 0e fc ff ff       	jmp    f010468c <syscall+0x52>
		if ((pp = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL )  return -E_INVAL;
f0104a7e:	e8 59 13 00 00       	call   f0105ddc <cpunum>
f0104a83:	83 ec 04             	sub    $0x4,%esp
f0104a86:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104a89:	52                   	push   %edx
f0104a8a:	ff 75 14             	push   0x14(%ebp)
f0104a8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a90:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104a96:	ff 70 60             	push   0x60(%eax)
f0104a99:	e8 df c6 ff ff       	call   f010117d <page_lookup>
f0104a9e:	83 c4 10             	add    $0x10,%esp
f0104aa1:	85 c0                	test   %eax,%eax
f0104aa3:	74 76                	je     f0104b1b <syscall+0x4e1>
		if ((perm & PTE_W) && !(*pte & PTE_W) )   return -E_INVAL;
f0104aa5:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104aa9:	74 08                	je     f0104ab3 <syscall+0x479>
f0104aab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104aae:	f6 02 02             	testb  $0x2,(%edx)
f0104ab1:	74 72                	je     f0104b25 <syscall+0x4eb>
		if (dstenv->env_ipc_dstva) {
f0104ab3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104ab6:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104ab9:	85 c9                	test   %ecx,%ecx
f0104abb:	74 1d                	je     f0104ada <syscall+0x4a0>
			if( (r = page_insert(dstenv->env_pgdir, pp, dstenv->env_ipc_dstva,  perm) ) < 0)  return r;
f0104abd:	ff 75 18             	push   0x18(%ebp)
f0104ac0:	51                   	push   %ecx
f0104ac1:	50                   	push   %eax
f0104ac2:	ff 72 60             	push   0x60(%edx)
f0104ac5:	e8 8d c7 ff ff       	call   f0101257 <page_insert>
f0104aca:	83 c4 10             	add    $0x10,%esp
f0104acd:	85 c0                	test   %eax,%eax
f0104acf:	78 5e                	js     f0104b2f <syscall+0x4f5>
			dstenv->env_ipc_perm = perm;
f0104ad1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ad4:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104ad7:	89 48 78             	mov    %ecx,0x78(%eax)
	dstenv->env_ipc_recving = false;
f0104ada:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104add:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	dstenv->env_ipc_from = curenv->env_id;
f0104ae1:	e8 f6 12 00 00       	call   f0105ddc <cpunum>
f0104ae6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104ae9:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aec:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104af2:	8b 40 48             	mov    0x48(%eax),%eax
f0104af5:	89 42 74             	mov    %eax,0x74(%edx)
	dstenv->env_ipc_value = value;
f0104af8:	8b 45 10             	mov    0x10(%ebp),%eax
f0104afb:	89 42 70             	mov    %eax,0x70(%edx)
	dstenv->env_status = ENV_RUNNABLE;
f0104afe:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	dstenv->env_tf.tf_regs.reg_eax = 0;
f0104b05:	c7 42 1c 00 00 00 00 	movl   $0x0,0x1c(%edx)
	return 0;
f0104b0c:	e9 7b fb ff ff       	jmp    f010468c <syscall+0x52>
		if (  !(perm & PTE_P ) || !(perm & PTE_U) )  return -E_INVAL;
f0104b11:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b16:	e9 71 fb ff ff       	jmp    f010468c <syscall+0x52>
		if ((pp = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL )  return -E_INVAL;
f0104b1b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b20:	e9 67 fb ff ff       	jmp    f010468c <syscall+0x52>
		if ((perm & PTE_W) && !(*pte & PTE_W) )   return -E_INVAL;
f0104b25:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b2a:	e9 5d fb ff ff       	jmp    f010468c <syscall+0x52>
			if( (r = page_insert(dstenv->env_pgdir, pp, dstenv->env_ipc_dstva,  perm) ) < 0)  return r;
f0104b2f:	89 c3                	mov    %eax,%ebx
f0104b31:	e9 56 fb ff ff       	jmp    f010468c <syscall+0x52>
	if ( (dstenv->env_ipc_recving != true)  || dstenv->env_ipc_from != 0)  return -E_IPC_NOT_RECV;
f0104b36:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104b3b:	e9 4c fb ff ff       	jmp    f010468c <syscall+0x52>
f0104b40:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0104b45:	e9 42 fb ff ff       	jmp    f010468c <syscall+0x52>
	if ((uintptr_t) dstva < UTOP && PGOFF(dstva) != 0) return -E_INVAL;
f0104b4a:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104b51:	77 13                	ja     f0104b66 <syscall+0x52c>
f0104b53:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104b5a:	74 0a                	je     f0104b66 <syscall+0x52c>
			return sys_ipc_recv((void *)a1);
f0104b5c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b61:	e9 26 fb ff ff       	jmp    f010468c <syscall+0x52>
	curenv->env_ipc_recving = true;
f0104b66:	e8 71 12 00 00       	call   f0105ddc <cpunum>
f0104b6b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b6e:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104b74:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104b78:	e8 5f 12 00 00       	call   f0105ddc <cpunum>
f0104b7d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b80:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104b86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104b89:	89 48 6c             	mov    %ecx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104b8c:	e8 4b 12 00 00       	call   f0105ddc <cpunum>
f0104b91:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b94:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104b9a:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_from = 0;
f0104ba1:	e8 36 12 00 00       	call   f0105ddc <cpunum>
f0104ba6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ba9:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104baf:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	sched_yield();
f0104bb6:	e8 f8 f9 ff ff       	call   f01045b3 <sched_yield>
	if( (r = envid2env(envid, &e, 1)) < 0 ) return r;
f0104bbb:	83 ec 04             	sub    $0x4,%esp
f0104bbe:	6a 01                	push   $0x1
f0104bc0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104bc3:	50                   	push   %eax
f0104bc4:	ff 75 0c             	push   0xc(%ebp)
f0104bc7:	e8 c5 e4 ff ff       	call   f0103091 <envid2env>
f0104bcc:	89 c3                	mov    %eax,%ebx
f0104bce:	83 c4 10             	add    $0x10,%esp
f0104bd1:	85 c0                	test   %eax,%eax
f0104bd3:	0f 88 b3 fa ff ff    	js     f010468c <syscall+0x52>
	user_mem_assert(e, tf, sizeof(struct Trapframe), 0);
f0104bd9:	6a 00                	push   $0x0
f0104bdb:	6a 44                	push   $0x44
f0104bdd:	ff 75 10             	push   0x10(%ebp)
f0104be0:	ff 75 e4             	push   -0x1c(%ebp)
f0104be3:	e8 d7 e3 ff ff       	call   f0102fbf <user_mem_assert>
	e->env_tf=*tf;
f0104be8:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104bed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104bf0:	8b 75 10             	mov    0x10(%ebp),%esi
f0104bf3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_cs|=3;
f0104bf5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104bf8:	66 83 4a 34 03       	orw    $0x3,0x34(%edx)
	e->env_tf.tf_eflags &=  ~FL_IOPL_MASK;
f0104bfd:	8b 42 38             	mov    0x38(%edx),%eax
f0104c00:	80 e4 cf             	and    $0xcf,%ah
f0104c03:	80 cc 02             	or     $0x2,%ah
f0104c06:	89 42 38             	mov    %eax,0x38(%edx)
	return 0;
f0104c09:	83 c4 10             	add    $0x10,%esp
f0104c0c:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_env_set_trapframe(a1, (struct Trapframe*) a2);
f0104c11:	e9 76 fa ff ff       	jmp    f010468c <syscall+0x52>
	switch (syscallno) 
f0104c16:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c1b:	e9 6c fa ff ff       	jmp    f010468c <syscall+0x52>

f0104c20 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104c20:	55                   	push   %ebp
f0104c21:	89 e5                	mov    %esp,%ebp
f0104c23:	57                   	push   %edi
f0104c24:	56                   	push   %esi
f0104c25:	53                   	push   %ebx
f0104c26:	83 ec 14             	sub    $0x14,%esp
f0104c29:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c2c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104c2f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c32:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c35:	8b 1a                	mov    (%edx),%ebx
f0104c37:	8b 01                	mov    (%ecx),%eax
f0104c39:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c3c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104c43:	eb 2f                	jmp    f0104c74 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104c45:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104c48:	39 c3                	cmp    %eax,%ebx
f0104c4a:	7f 4e                	jg     f0104c9a <stab_binsearch+0x7a>
f0104c4c:	0f b6 0a             	movzbl (%edx),%ecx
f0104c4f:	83 ea 0c             	sub    $0xc,%edx
f0104c52:	39 f1                	cmp    %esi,%ecx
f0104c54:	75 ef                	jne    f0104c45 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104c56:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c59:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c5c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104c60:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104c63:	73 3a                	jae    f0104c9f <stab_binsearch+0x7f>
			*region_left = m;
f0104c65:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104c68:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104c6a:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0104c6d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104c74:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104c77:	7f 53                	jg     f0104ccc <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0104c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104c7c:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0104c7f:	89 d0                	mov    %edx,%eax
f0104c81:	c1 e8 1f             	shr    $0x1f,%eax
f0104c84:	01 d0                	add    %edx,%eax
f0104c86:	89 c7                	mov    %eax,%edi
f0104c88:	d1 ff                	sar    %edi
f0104c8a:	83 e0 fe             	and    $0xfffffffe,%eax
f0104c8d:	01 f8                	add    %edi,%eax
f0104c8f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c92:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104c96:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104c98:	eb ae                	jmp    f0104c48 <stab_binsearch+0x28>
			l = true_m + 1;
f0104c9a:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104c9d:	eb d5                	jmp    f0104c74 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104c9f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104ca2:	76 14                	jbe    f0104cb8 <stab_binsearch+0x98>
			*region_right = m - 1;
f0104ca4:	83 e8 01             	sub    $0x1,%eax
f0104ca7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104caa:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104cad:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104caf:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104cb6:	eb bc                	jmp    f0104c74 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104cb8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cbb:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104cbd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104cc1:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104cc3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104cca:	eb a8                	jmp    f0104c74 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104ccc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104cd0:	75 15                	jne    f0104ce7 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0104cd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cd5:	8b 00                	mov    (%eax),%eax
f0104cd7:	83 e8 01             	sub    $0x1,%eax
f0104cda:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104cdd:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104cdf:	83 c4 14             	add    $0x14,%esp
f0104ce2:	5b                   	pop    %ebx
f0104ce3:	5e                   	pop    %esi
f0104ce4:	5f                   	pop    %edi
f0104ce5:	5d                   	pop    %ebp
f0104ce6:	c3                   	ret    
		for (l = *region_right;
f0104ce7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cea:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104cec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cef:	8b 0f                	mov    (%edi),%ecx
f0104cf1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cf4:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104cf7:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104cfb:	39 c1                	cmp    %eax,%ecx
f0104cfd:	7d 0f                	jge    f0104d0e <stab_binsearch+0xee>
f0104cff:	0f b6 1a             	movzbl (%edx),%ebx
f0104d02:	83 ea 0c             	sub    $0xc,%edx
f0104d05:	39 f3                	cmp    %esi,%ebx
f0104d07:	74 05                	je     f0104d0e <stab_binsearch+0xee>
		     l--)
f0104d09:	83 e8 01             	sub    $0x1,%eax
f0104d0c:	eb ed                	jmp    f0104cfb <stab_binsearch+0xdb>
		*region_left = l;
f0104d0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d11:	89 07                	mov    %eax,(%edi)
}
f0104d13:	eb ca                	jmp    f0104cdf <stab_binsearch+0xbf>

f0104d15 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d15:	55                   	push   %ebp
f0104d16:	89 e5                	mov    %esp,%ebp
f0104d18:	57                   	push   %edi
f0104d19:	56                   	push   %esi
f0104d1a:	53                   	push   %ebx
f0104d1b:	83 ec 4c             	sub    $0x4c,%esp
f0104d1e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104d21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104d24:	c7 03 a4 7c 10 f0    	movl   $0xf0107ca4,(%ebx)
	info->eip_line = 0;
f0104d2a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104d31:	c7 43 08 a4 7c 10 f0 	movl   $0xf0107ca4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104d38:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104d3f:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104d42:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d49:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104d4f:	0f 86 29 01 00 00    	jbe    f0104e7e <debuginfo_eip+0x169>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104d55:	c7 45 c0 ed a7 11 f0 	movl   $0xf011a7ed,-0x40(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104d5c:	c7 45 bc 81 39 11 f0 	movl   $0xf0113981,-0x44(%ebp)
		stab_end = __STAB_END__;
f0104d63:	be 80 39 11 f0       	mov    $0xf0113980,%esi
		stabs = __STAB_BEGIN__;
f0104d68:	c7 45 c4 50 82 10 f0 	movl   $0xf0108250,-0x3c(%ebp)
		if( user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ) return -1;
		if( user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) ) return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104d6f:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104d72:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f0104d75:	0f 83 3e 02 00 00    	jae    f0104fb9 <debuginfo_eip+0x2a4>
f0104d7b:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104d7f:	0f 85 3b 02 00 00    	jne    f0104fc0 <debuginfo_eip+0x2ab>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104d85:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104d8c:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0104d8f:	c1 fe 02             	sar    $0x2,%esi
f0104d92:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104d98:	83 e8 01             	sub    $0x1,%eax
f0104d9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104d9e:	83 ec 08             	sub    $0x8,%esp
f0104da1:	57                   	push   %edi
f0104da2:	6a 64                	push   $0x64
f0104da4:	8d 75 e0             	lea    -0x20(%ebp),%esi
f0104da7:	89 f1                	mov    %esi,%ecx
f0104da9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104dac:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104daf:	e8 6c fe ff ff       	call   f0104c20 <stab_binsearch>
	if (lfile == 0)
f0104db4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104db7:	83 c4 10             	add    $0x10,%esp
f0104dba:	85 f6                	test   %esi,%esi
f0104dbc:	0f 84 05 02 00 00    	je     f0104fc7 <debuginfo_eip+0x2b2>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104dc2:	89 75 dc             	mov    %esi,-0x24(%ebp)
	rfun = rfile;
f0104dc5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104dc8:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0104dcb:	89 55 d8             	mov    %edx,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104dce:	83 ec 08             	sub    $0x8,%esp
f0104dd1:	57                   	push   %edi
f0104dd2:	6a 24                	push   $0x24
f0104dd4:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104dd7:	89 d1                	mov    %edx,%ecx
f0104dd9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104ddc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104ddf:	e8 3c fe ff ff       	call   f0104c20 <stab_binsearch>

	if (lfun <= rfun) {
f0104de4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104de7:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0104dea:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104ded:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0104df0:	83 c4 10             	add    $0x10,%esp
f0104df3:	39 c2                	cmp    %eax,%edx
f0104df5:	0f 8f 32 01 00 00    	jg     f0104f2d <debuginfo_eip+0x218>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104dfb:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104dfe:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104e01:	8d 14 82             	lea    (%edx,%eax,4),%edx
f0104e04:	8b 02                	mov    (%edx),%eax
f0104e06:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104e09:	2b 4d bc             	sub    -0x44(%ebp),%ecx
f0104e0c:	39 c8                	cmp    %ecx,%eax
f0104e0e:	73 06                	jae    f0104e16 <debuginfo_eip+0x101>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e10:	03 45 bc             	add    -0x44(%ebp),%eax
f0104e13:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e16:	8b 42 08             	mov    0x8(%edx),%eax
		addr -= info->eip_fn_addr;
f0104e19:	29 c7                	sub    %eax,%edi
f0104e1b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0104e1e:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0104e21:	89 4d b8             	mov    %ecx,-0x48(%ebp)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e24:	89 43 10             	mov    %eax,0x10(%ebx)
		// Search within the function definition for the line number.
		lline = lfun;
f0104e27:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0104e2a:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104e2d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e30:	83 ec 08             	sub    $0x8,%esp
f0104e33:	6a 3a                	push   $0x3a
f0104e35:	ff 73 08             	push   0x8(%ebx)
f0104e38:	e8 8d 09 00 00       	call   f01057ca <strfind>
f0104e3d:	2b 43 08             	sub    0x8(%ebx),%eax
f0104e40:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104e43:	83 c4 08             	add    $0x8,%esp
f0104e46:	57                   	push   %edi
f0104e47:	6a 44                	push   $0x44
f0104e49:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104e4c:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104e4f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104e52:	89 f8                	mov    %edi,%eax
f0104e54:	e8 c7 fd ff ff       	call   f0104c20 <stab_binsearch>
	if (lline <= rline) {
f0104e59:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104e5c:	83 c4 10             	add    $0x10,%esp
f0104e5f:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104e62:	0f 8f 66 01 00 00    	jg     f0104fce <debuginfo_eip+0x2b9>
    		info->eip_line = stabs[lline].n_desc;
f0104e68:	89 c2                	mov    %eax,%edx
f0104e6a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104e6d:	0f b7 4c 87 06       	movzwl 0x6(%edi,%eax,4),%ecx
f0104e72:	89 4b 04             	mov    %ecx,0x4(%ebx)
f0104e75:	8d 44 87 04          	lea    0x4(%edi,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e79:	e9 be 00 00 00       	jmp    f0104f3c <debuginfo_eip+0x227>
		if( user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) ) return -1;
f0104e7e:	e8 59 0f 00 00       	call   f0105ddc <cpunum>
f0104e83:	6a 04                	push   $0x4
f0104e85:	6a 10                	push   $0x10
f0104e87:	68 00 00 20 00       	push   $0x200000
f0104e8c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e8f:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f0104e95:	e8 97 e0 ff ff       	call   f0102f31 <user_mem_check>
f0104e9a:	83 c4 10             	add    $0x10,%esp
f0104e9d:	85 c0                	test   %eax,%eax
f0104e9f:	0f 85 06 01 00 00    	jne    f0104fab <debuginfo_eip+0x296>
		stabs = usd->stabs;
f0104ea5:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f0104eab:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104eae:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104eb4:	a1 08 00 20 00       	mov    0x200008,%eax
f0104eb9:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0104ebc:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104ec2:	89 55 c0             	mov    %edx,-0x40(%ebp)
		if( user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ) return -1;
f0104ec5:	e8 12 0f 00 00       	call   f0105ddc <cpunum>
f0104eca:	89 c2                	mov    %eax,%edx
f0104ecc:	6a 04                	push   $0x4
f0104ece:	89 f0                	mov    %esi,%eax
f0104ed0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104ed3:	29 c8                	sub    %ecx,%eax
f0104ed5:	c1 f8 02             	sar    $0x2,%eax
f0104ed8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104ede:	50                   	push   %eax
f0104edf:	51                   	push   %ecx
f0104ee0:	6b d2 74             	imul   $0x74,%edx,%edx
f0104ee3:	ff b2 28 80 25 f0    	push   -0xfda7fd8(%edx)
f0104ee9:	e8 43 e0 ff ff       	call   f0102f31 <user_mem_check>
f0104eee:	83 c4 10             	add    $0x10,%esp
f0104ef1:	85 c0                	test   %eax,%eax
f0104ef3:	0f 85 b9 00 00 00    	jne    f0104fb2 <debuginfo_eip+0x29d>
		if( user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) ) return -1;
f0104ef9:	e8 de 0e 00 00       	call   f0105ddc <cpunum>
f0104efe:	6a 04                	push   $0x4
f0104f00:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0104f03:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104f06:	29 ca                	sub    %ecx,%edx
f0104f08:	52                   	push   %edx
f0104f09:	51                   	push   %ecx
f0104f0a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f0d:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f0104f13:	e8 19 e0 ff ff       	call   f0102f31 <user_mem_check>
f0104f18:	83 c4 10             	add    $0x10,%esp
f0104f1b:	85 c0                	test   %eax,%eax
f0104f1d:	0f 84 4c fe ff ff    	je     f0104d6f <debuginfo_eip+0x5a>
f0104f23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f28:	e9 ad 00 00 00       	jmp    f0104fda <debuginfo_eip+0x2c5>
f0104f2d:	89 f8                	mov    %edi,%eax
f0104f2f:	89 f2                	mov    %esi,%edx
f0104f31:	e9 ee fe ff ff       	jmp    f0104e24 <debuginfo_eip+0x10f>
f0104f36:	83 ea 01             	sub    $0x1,%edx
f0104f39:	83 e8 0c             	sub    $0xc,%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104f3c:	39 d6                	cmp    %edx,%esi
f0104f3e:	7f 2e                	jg     f0104f6e <debuginfo_eip+0x259>
	       && stabs[lline].n_type != N_SOL
f0104f40:	0f b6 08             	movzbl (%eax),%ecx
f0104f43:	80 f9 84             	cmp    $0x84,%cl
f0104f46:	74 0b                	je     f0104f53 <debuginfo_eip+0x23e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104f48:	80 f9 64             	cmp    $0x64,%cl
f0104f4b:	75 e9                	jne    f0104f36 <debuginfo_eip+0x221>
f0104f4d:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0104f51:	74 e3                	je     f0104f36 <debuginfo_eip+0x221>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104f53:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104f56:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104f59:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0104f5c:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104f5f:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104f62:	29 f0                	sub    %esi,%eax
f0104f64:	39 c2                	cmp    %eax,%edx
f0104f66:	73 06                	jae    f0104f6e <debuginfo_eip+0x259>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104f68:	89 f0                	mov    %esi,%eax
f0104f6a:	01 d0                	add    %edx,%eax
f0104f6c:	89 03                	mov    %eax,(%ebx)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f6e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104f73:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104f76:	8b 75 b0             	mov    -0x50(%ebp),%esi
f0104f79:	39 f7                	cmp    %esi,%edi
f0104f7b:	7d 5d                	jge    f0104fda <debuginfo_eip+0x2c5>
		for (lline = lfun + 1;
f0104f7d:	83 c7 01             	add    $0x1,%edi
f0104f80:	89 f8                	mov    %edi,%eax
f0104f82:	8d 14 7f             	lea    (%edi,%edi,2),%edx
f0104f85:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104f88:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104f8c:	eb 04                	jmp    f0104f92 <debuginfo_eip+0x27d>
			info->eip_fn_narg++;
f0104f8e:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104f92:	39 c6                	cmp    %eax,%esi
f0104f94:	7e 3f                	jle    f0104fd5 <debuginfo_eip+0x2c0>
f0104f96:	0f b6 0a             	movzbl (%edx),%ecx
f0104f99:	83 c0 01             	add    $0x1,%eax
f0104f9c:	83 c2 0c             	add    $0xc,%edx
f0104f9f:	80 f9 a0             	cmp    $0xa0,%cl
f0104fa2:	74 ea                	je     f0104f8e <debuginfo_eip+0x279>
	return 0;
f0104fa4:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fa9:	eb 2f                	jmp    f0104fda <debuginfo_eip+0x2c5>
		if( user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) ) return -1;
f0104fab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fb0:	eb 28                	jmp    f0104fda <debuginfo_eip+0x2c5>
		if( user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ) return -1;
f0104fb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fb7:	eb 21                	jmp    f0104fda <debuginfo_eip+0x2c5>
		return -1;
f0104fb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fbe:	eb 1a                	jmp    f0104fda <debuginfo_eip+0x2c5>
f0104fc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fc5:	eb 13                	jmp    f0104fda <debuginfo_eip+0x2c5>
		return -1;
f0104fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fcc:	eb 0c                	jmp    f0104fda <debuginfo_eip+0x2c5>
    		return -1;
f0104fce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fd3:	eb 05                	jmp    f0104fda <debuginfo_eip+0x2c5>
	return 0;
f0104fd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104fda:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104fdd:	5b                   	pop    %ebx
f0104fde:	5e                   	pop    %esi
f0104fdf:	5f                   	pop    %edi
f0104fe0:	5d                   	pop    %ebp
f0104fe1:	c3                   	ret    

f0104fe2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104fe2:	55                   	push   %ebp
f0104fe3:	89 e5                	mov    %esp,%ebp
f0104fe5:	57                   	push   %edi
f0104fe6:	56                   	push   %esi
f0104fe7:	53                   	push   %ebx
f0104fe8:	83 ec 1c             	sub    $0x1c,%esp
f0104feb:	89 c7                	mov    %eax,%edi
f0104fed:	89 d6                	mov    %edx,%esi
f0104fef:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ff2:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104ff5:	89 d1                	mov    %edx,%ecx
f0104ff7:	89 c2                	mov    %eax,%edx
f0104ff9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ffc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104fff:	8b 45 10             	mov    0x10(%ebp),%eax
f0105002:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105005:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105008:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010500f:	39 c2                	cmp    %eax,%edx
f0105011:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0105014:	72 3e                	jb     f0105054 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105016:	83 ec 0c             	sub    $0xc,%esp
f0105019:	ff 75 18             	push   0x18(%ebp)
f010501c:	83 eb 01             	sub    $0x1,%ebx
f010501f:	53                   	push   %ebx
f0105020:	50                   	push   %eax
f0105021:	83 ec 08             	sub    $0x8,%esp
f0105024:	ff 75 e4             	push   -0x1c(%ebp)
f0105027:	ff 75 e0             	push   -0x20(%ebp)
f010502a:	ff 75 dc             	push   -0x24(%ebp)
f010502d:	ff 75 d8             	push   -0x28(%ebp)
f0105030:	e8 9b 11 00 00       	call   f01061d0 <__udivdi3>
f0105035:	83 c4 18             	add    $0x18,%esp
f0105038:	52                   	push   %edx
f0105039:	50                   	push   %eax
f010503a:	89 f2                	mov    %esi,%edx
f010503c:	89 f8                	mov    %edi,%eax
f010503e:	e8 9f ff ff ff       	call   f0104fe2 <printnum>
f0105043:	83 c4 20             	add    $0x20,%esp
f0105046:	eb 13                	jmp    f010505b <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105048:	83 ec 08             	sub    $0x8,%esp
f010504b:	56                   	push   %esi
f010504c:	ff 75 18             	push   0x18(%ebp)
f010504f:	ff d7                	call   *%edi
f0105051:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0105054:	83 eb 01             	sub    $0x1,%ebx
f0105057:	85 db                	test   %ebx,%ebx
f0105059:	7f ed                	jg     f0105048 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010505b:	83 ec 08             	sub    $0x8,%esp
f010505e:	56                   	push   %esi
f010505f:	83 ec 04             	sub    $0x4,%esp
f0105062:	ff 75 e4             	push   -0x1c(%ebp)
f0105065:	ff 75 e0             	push   -0x20(%ebp)
f0105068:	ff 75 dc             	push   -0x24(%ebp)
f010506b:	ff 75 d8             	push   -0x28(%ebp)
f010506e:	e8 7d 12 00 00       	call   f01062f0 <__umoddi3>
f0105073:	83 c4 14             	add    $0x14,%esp
f0105076:	0f be 80 ae 7c 10 f0 	movsbl -0xfef8352(%eax),%eax
f010507d:	50                   	push   %eax
f010507e:	ff d7                	call   *%edi
}
f0105080:	83 c4 10             	add    $0x10,%esp
f0105083:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105086:	5b                   	pop    %ebx
f0105087:	5e                   	pop    %esi
f0105088:	5f                   	pop    %edi
f0105089:	5d                   	pop    %ebp
f010508a:	c3                   	ret    

f010508b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010508b:	55                   	push   %ebp
f010508c:	89 e5                	mov    %esp,%ebp
f010508e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105091:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105095:	8b 10                	mov    (%eax),%edx
f0105097:	3b 50 04             	cmp    0x4(%eax),%edx
f010509a:	73 0a                	jae    f01050a6 <sprintputch+0x1b>
		*b->buf++ = ch;
f010509c:	8d 4a 01             	lea    0x1(%edx),%ecx
f010509f:	89 08                	mov    %ecx,(%eax)
f01050a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01050a4:	88 02                	mov    %al,(%edx)
}
f01050a6:	5d                   	pop    %ebp
f01050a7:	c3                   	ret    

f01050a8 <printfmt>:
{
f01050a8:	55                   	push   %ebp
f01050a9:	89 e5                	mov    %esp,%ebp
f01050ab:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01050ae:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01050b1:	50                   	push   %eax
f01050b2:	ff 75 10             	push   0x10(%ebp)
f01050b5:	ff 75 0c             	push   0xc(%ebp)
f01050b8:	ff 75 08             	push   0x8(%ebp)
f01050bb:	e8 05 00 00 00       	call   f01050c5 <vprintfmt>
}
f01050c0:	83 c4 10             	add    $0x10,%esp
f01050c3:	c9                   	leave  
f01050c4:	c3                   	ret    

f01050c5 <vprintfmt>:
{
f01050c5:	55                   	push   %ebp
f01050c6:	89 e5                	mov    %esp,%ebp
f01050c8:	57                   	push   %edi
f01050c9:	56                   	push   %esi
f01050ca:	53                   	push   %ebx
f01050cb:	83 ec 3c             	sub    $0x3c,%esp
f01050ce:	8b 75 08             	mov    0x8(%ebp),%esi
f01050d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01050d4:	8b 7d 10             	mov    0x10(%ebp),%edi
f01050d7:	eb 0a                	jmp    f01050e3 <vprintfmt+0x1e>
			putch(ch, putdat);
f01050d9:	83 ec 08             	sub    $0x8,%esp
f01050dc:	53                   	push   %ebx
f01050dd:	50                   	push   %eax
f01050de:	ff d6                	call   *%esi
f01050e0:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01050e3:	83 c7 01             	add    $0x1,%edi
f01050e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01050ea:	83 f8 25             	cmp    $0x25,%eax
f01050ed:	74 0c                	je     f01050fb <vprintfmt+0x36>
			if (ch == '\0')
f01050ef:	85 c0                	test   %eax,%eax
f01050f1:	75 e6                	jne    f01050d9 <vprintfmt+0x14>
}
f01050f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050f6:	5b                   	pop    %ebx
f01050f7:	5e                   	pop    %esi
f01050f8:	5f                   	pop    %edi
f01050f9:	5d                   	pop    %ebp
f01050fa:	c3                   	ret    
		padc = ' ';
f01050fb:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f01050ff:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0105106:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010510d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0105114:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105119:	8d 47 01             	lea    0x1(%edi),%eax
f010511c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010511f:	0f b6 17             	movzbl (%edi),%edx
f0105122:	8d 42 dd             	lea    -0x23(%edx),%eax
f0105125:	3c 55                	cmp    $0x55,%al
f0105127:	0f 87 bb 03 00 00    	ja     f01054e8 <vprintfmt+0x423>
f010512d:	0f b6 c0             	movzbl %al,%eax
f0105130:	ff 24 85 00 7e 10 f0 	jmp    *-0xfef8200(,%eax,4)
f0105137:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010513a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f010513e:	eb d9                	jmp    f0105119 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0105140:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105143:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0105147:	eb d0                	jmp    f0105119 <vprintfmt+0x54>
f0105149:	0f b6 d2             	movzbl %dl,%edx
f010514c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010514f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105154:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105157:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010515a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010515e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0105161:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0105164:	83 f9 09             	cmp    $0x9,%ecx
f0105167:	77 55                	ja     f01051be <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
f0105169:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f010516c:	eb e9                	jmp    f0105157 <vprintfmt+0x92>
			precision = va_arg(ap, int);
f010516e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105171:	8b 00                	mov    (%eax),%eax
f0105173:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105176:	8b 45 14             	mov    0x14(%ebp),%eax
f0105179:	8d 40 04             	lea    0x4(%eax),%eax
f010517c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010517f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0105182:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105186:	79 91                	jns    f0105119 <vprintfmt+0x54>
				width = precision, precision = -1;
f0105188:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010518b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010518e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0105195:	eb 82                	jmp    f0105119 <vprintfmt+0x54>
f0105197:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010519a:	85 d2                	test   %edx,%edx
f010519c:	b8 00 00 00 00       	mov    $0x0,%eax
f01051a1:	0f 49 c2             	cmovns %edx,%eax
f01051a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01051a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01051aa:	e9 6a ff ff ff       	jmp    f0105119 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f01051af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01051b2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01051b9:	e9 5b ff ff ff       	jmp    f0105119 <vprintfmt+0x54>
f01051be:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01051c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051c4:	eb bc                	jmp    f0105182 <vprintfmt+0xbd>
			lflag++;
f01051c6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01051c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01051cc:	e9 48 ff ff ff       	jmp    f0105119 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f01051d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01051d4:	8d 78 04             	lea    0x4(%eax),%edi
f01051d7:	83 ec 08             	sub    $0x8,%esp
f01051da:	53                   	push   %ebx
f01051db:	ff 30                	push   (%eax)
f01051dd:	ff d6                	call   *%esi
			break;
f01051df:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01051e2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01051e5:	e9 9d 02 00 00       	jmp    f0105487 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
f01051ea:	8b 45 14             	mov    0x14(%ebp),%eax
f01051ed:	8d 78 04             	lea    0x4(%eax),%edi
f01051f0:	8b 10                	mov    (%eax),%edx
f01051f2:	89 d0                	mov    %edx,%eax
f01051f4:	f7 d8                	neg    %eax
f01051f6:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01051f9:	83 f8 0f             	cmp    $0xf,%eax
f01051fc:	7f 23                	jg     f0105221 <vprintfmt+0x15c>
f01051fe:	8b 14 85 60 7f 10 f0 	mov    -0xfef80a0(,%eax,4),%edx
f0105205:	85 d2                	test   %edx,%edx
f0105207:	74 18                	je     f0105221 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
f0105209:	52                   	push   %edx
f010520a:	68 c7 69 10 f0       	push   $0xf01069c7
f010520f:	53                   	push   %ebx
f0105210:	56                   	push   %esi
f0105211:	e8 92 fe ff ff       	call   f01050a8 <printfmt>
f0105216:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105219:	89 7d 14             	mov    %edi,0x14(%ebp)
f010521c:	e9 66 02 00 00       	jmp    f0105487 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
f0105221:	50                   	push   %eax
f0105222:	68 c6 7c 10 f0       	push   $0xf0107cc6
f0105227:	53                   	push   %ebx
f0105228:	56                   	push   %esi
f0105229:	e8 7a fe ff ff       	call   f01050a8 <printfmt>
f010522e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105231:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0105234:	e9 4e 02 00 00       	jmp    f0105487 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
f0105239:	8b 45 14             	mov    0x14(%ebp),%eax
f010523c:	83 c0 04             	add    $0x4,%eax
f010523f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0105242:	8b 45 14             	mov    0x14(%ebp),%eax
f0105245:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0105247:	85 d2                	test   %edx,%edx
f0105249:	b8 bf 7c 10 f0       	mov    $0xf0107cbf,%eax
f010524e:	0f 45 c2             	cmovne %edx,%eax
f0105251:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0105254:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105258:	7e 06                	jle    f0105260 <vprintfmt+0x19b>
f010525a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f010525e:	75 0d                	jne    f010526d <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105260:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105263:	89 c7                	mov    %eax,%edi
f0105265:	03 45 e0             	add    -0x20(%ebp),%eax
f0105268:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010526b:	eb 55                	jmp    f01052c2 <vprintfmt+0x1fd>
f010526d:	83 ec 08             	sub    $0x8,%esp
f0105270:	ff 75 d8             	push   -0x28(%ebp)
f0105273:	ff 75 cc             	push   -0x34(%ebp)
f0105276:	e8 f8 03 00 00       	call   f0105673 <strnlen>
f010527b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010527e:	29 c1                	sub    %eax,%ecx
f0105280:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0105283:	83 c4 10             	add    $0x10,%esp
f0105286:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
f0105288:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f010528c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010528f:	eb 0f                	jmp    f01052a0 <vprintfmt+0x1db>
					putch(padc, putdat);
f0105291:	83 ec 08             	sub    $0x8,%esp
f0105294:	53                   	push   %ebx
f0105295:	ff 75 e0             	push   -0x20(%ebp)
f0105298:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010529a:	83 ef 01             	sub    $0x1,%edi
f010529d:	83 c4 10             	add    $0x10,%esp
f01052a0:	85 ff                	test   %edi,%edi
f01052a2:	7f ed                	jg     f0105291 <vprintfmt+0x1cc>
f01052a4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01052a7:	85 d2                	test   %edx,%edx
f01052a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01052ae:	0f 49 c2             	cmovns %edx,%eax
f01052b1:	29 c2                	sub    %eax,%edx
f01052b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01052b6:	eb a8                	jmp    f0105260 <vprintfmt+0x19b>
					putch(ch, putdat);
f01052b8:	83 ec 08             	sub    $0x8,%esp
f01052bb:	53                   	push   %ebx
f01052bc:	52                   	push   %edx
f01052bd:	ff d6                	call   *%esi
f01052bf:	83 c4 10             	add    $0x10,%esp
f01052c2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01052c5:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01052c7:	83 c7 01             	add    $0x1,%edi
f01052ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01052ce:	0f be d0             	movsbl %al,%edx
f01052d1:	85 d2                	test   %edx,%edx
f01052d3:	74 4b                	je     f0105320 <vprintfmt+0x25b>
f01052d5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01052d9:	78 06                	js     f01052e1 <vprintfmt+0x21c>
f01052db:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01052df:	78 1e                	js     f01052ff <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
f01052e1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01052e5:	74 d1                	je     f01052b8 <vprintfmt+0x1f3>
f01052e7:	0f be c0             	movsbl %al,%eax
f01052ea:	83 e8 20             	sub    $0x20,%eax
f01052ed:	83 f8 5e             	cmp    $0x5e,%eax
f01052f0:	76 c6                	jbe    f01052b8 <vprintfmt+0x1f3>
					putch('?', putdat);
f01052f2:	83 ec 08             	sub    $0x8,%esp
f01052f5:	53                   	push   %ebx
f01052f6:	6a 3f                	push   $0x3f
f01052f8:	ff d6                	call   *%esi
f01052fa:	83 c4 10             	add    $0x10,%esp
f01052fd:	eb c3                	jmp    f01052c2 <vprintfmt+0x1fd>
f01052ff:	89 cf                	mov    %ecx,%edi
f0105301:	eb 0e                	jmp    f0105311 <vprintfmt+0x24c>
				putch(' ', putdat);
f0105303:	83 ec 08             	sub    $0x8,%esp
f0105306:	53                   	push   %ebx
f0105307:	6a 20                	push   $0x20
f0105309:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010530b:	83 ef 01             	sub    $0x1,%edi
f010530e:	83 c4 10             	add    $0x10,%esp
f0105311:	85 ff                	test   %edi,%edi
f0105313:	7f ee                	jg     f0105303 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
f0105315:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105318:	89 45 14             	mov    %eax,0x14(%ebp)
f010531b:	e9 67 01 00 00       	jmp    f0105487 <vprintfmt+0x3c2>
f0105320:	89 cf                	mov    %ecx,%edi
f0105322:	eb ed                	jmp    f0105311 <vprintfmt+0x24c>
	if (lflag >= 2)
f0105324:	83 f9 01             	cmp    $0x1,%ecx
f0105327:	7f 1b                	jg     f0105344 <vprintfmt+0x27f>
	else if (lflag)
f0105329:	85 c9                	test   %ecx,%ecx
f010532b:	74 63                	je     f0105390 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
f010532d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105330:	8b 00                	mov    (%eax),%eax
f0105332:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105335:	99                   	cltd   
f0105336:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105339:	8b 45 14             	mov    0x14(%ebp),%eax
f010533c:	8d 40 04             	lea    0x4(%eax),%eax
f010533f:	89 45 14             	mov    %eax,0x14(%ebp)
f0105342:	eb 17                	jmp    f010535b <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0105344:	8b 45 14             	mov    0x14(%ebp),%eax
f0105347:	8b 50 04             	mov    0x4(%eax),%edx
f010534a:	8b 00                	mov    (%eax),%eax
f010534c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010534f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105352:	8b 45 14             	mov    0x14(%ebp),%eax
f0105355:	8d 40 08             	lea    0x8(%eax),%eax
f0105358:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010535b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010535e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0105361:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
f0105366:	85 c9                	test   %ecx,%ecx
f0105368:	0f 89 ff 00 00 00    	jns    f010546d <vprintfmt+0x3a8>
				putch('-', putdat);
f010536e:	83 ec 08             	sub    $0x8,%esp
f0105371:	53                   	push   %ebx
f0105372:	6a 2d                	push   $0x2d
f0105374:	ff d6                	call   *%esi
				num = -(long long) num;
f0105376:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105379:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010537c:	f7 da                	neg    %edx
f010537e:	83 d1 00             	adc    $0x0,%ecx
f0105381:	f7 d9                	neg    %ecx
f0105383:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105386:	bf 0a 00 00 00       	mov    $0xa,%edi
f010538b:	e9 dd 00 00 00       	jmp    f010546d <vprintfmt+0x3a8>
		return va_arg(*ap, int);
f0105390:	8b 45 14             	mov    0x14(%ebp),%eax
f0105393:	8b 00                	mov    (%eax),%eax
f0105395:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105398:	99                   	cltd   
f0105399:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010539c:	8b 45 14             	mov    0x14(%ebp),%eax
f010539f:	8d 40 04             	lea    0x4(%eax),%eax
f01053a2:	89 45 14             	mov    %eax,0x14(%ebp)
f01053a5:	eb b4                	jmp    f010535b <vprintfmt+0x296>
	if (lflag >= 2)
f01053a7:	83 f9 01             	cmp    $0x1,%ecx
f01053aa:	7f 1e                	jg     f01053ca <vprintfmt+0x305>
	else if (lflag)
f01053ac:	85 c9                	test   %ecx,%ecx
f01053ae:	74 32                	je     f01053e2 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
f01053b0:	8b 45 14             	mov    0x14(%ebp),%eax
f01053b3:	8b 10                	mov    (%eax),%edx
f01053b5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01053ba:	8d 40 04             	lea    0x4(%eax),%eax
f01053bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01053c0:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
f01053c5:	e9 a3 00 00 00       	jmp    f010546d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f01053ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01053cd:	8b 10                	mov    (%eax),%edx
f01053cf:	8b 48 04             	mov    0x4(%eax),%ecx
f01053d2:	8d 40 08             	lea    0x8(%eax),%eax
f01053d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01053d8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
f01053dd:	e9 8b 00 00 00       	jmp    f010546d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f01053e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01053e5:	8b 10                	mov    (%eax),%edx
f01053e7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01053ec:	8d 40 04             	lea    0x4(%eax),%eax
f01053ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01053f2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
f01053f7:	eb 74                	jmp    f010546d <vprintfmt+0x3a8>
	if (lflag >= 2)
f01053f9:	83 f9 01             	cmp    $0x1,%ecx
f01053fc:	7f 1b                	jg     f0105419 <vprintfmt+0x354>
	else if (lflag)
f01053fe:	85 c9                	test   %ecx,%ecx
f0105400:	74 2c                	je     f010542e <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
f0105402:	8b 45 14             	mov    0x14(%ebp),%eax
f0105405:	8b 10                	mov    (%eax),%edx
f0105407:	b9 00 00 00 00       	mov    $0x0,%ecx
f010540c:	8d 40 04             	lea    0x4(%eax),%eax
f010540f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0105412:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
f0105417:	eb 54                	jmp    f010546d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f0105419:	8b 45 14             	mov    0x14(%ebp),%eax
f010541c:	8b 10                	mov    (%eax),%edx
f010541e:	8b 48 04             	mov    0x4(%eax),%ecx
f0105421:	8d 40 08             	lea    0x8(%eax),%eax
f0105424:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0105427:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
f010542c:	eb 3f                	jmp    f010546d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f010542e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105431:	8b 10                	mov    (%eax),%edx
f0105433:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105438:	8d 40 04             	lea    0x4(%eax),%eax
f010543b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f010543e:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
f0105443:	eb 28                	jmp    f010546d <vprintfmt+0x3a8>
			putch('0', putdat);
f0105445:	83 ec 08             	sub    $0x8,%esp
f0105448:	53                   	push   %ebx
f0105449:	6a 30                	push   $0x30
f010544b:	ff d6                	call   *%esi
			putch('x', putdat);
f010544d:	83 c4 08             	add    $0x8,%esp
f0105450:	53                   	push   %ebx
f0105451:	6a 78                	push   $0x78
f0105453:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105455:	8b 45 14             	mov    0x14(%ebp),%eax
f0105458:	8b 10                	mov    (%eax),%edx
f010545a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010545f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0105462:	8d 40 04             	lea    0x4(%eax),%eax
f0105465:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105468:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
f010546d:	83 ec 0c             	sub    $0xc,%esp
f0105470:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0105474:	50                   	push   %eax
f0105475:	ff 75 e0             	push   -0x20(%ebp)
f0105478:	57                   	push   %edi
f0105479:	51                   	push   %ecx
f010547a:	52                   	push   %edx
f010547b:	89 da                	mov    %ebx,%edx
f010547d:	89 f0                	mov    %esi,%eax
f010547f:	e8 5e fb ff ff       	call   f0104fe2 <printnum>
			break;
f0105484:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0105487:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010548a:	e9 54 fc ff ff       	jmp    f01050e3 <vprintfmt+0x1e>
	if (lflag >= 2)
f010548f:	83 f9 01             	cmp    $0x1,%ecx
f0105492:	7f 1b                	jg     f01054af <vprintfmt+0x3ea>
	else if (lflag)
f0105494:	85 c9                	test   %ecx,%ecx
f0105496:	74 2c                	je     f01054c4 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
f0105498:	8b 45 14             	mov    0x14(%ebp),%eax
f010549b:	8b 10                	mov    (%eax),%edx
f010549d:	b9 00 00 00 00       	mov    $0x0,%ecx
f01054a2:	8d 40 04             	lea    0x4(%eax),%eax
f01054a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01054a8:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
f01054ad:	eb be                	jmp    f010546d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f01054af:	8b 45 14             	mov    0x14(%ebp),%eax
f01054b2:	8b 10                	mov    (%eax),%edx
f01054b4:	8b 48 04             	mov    0x4(%eax),%ecx
f01054b7:	8d 40 08             	lea    0x8(%eax),%eax
f01054ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01054bd:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
f01054c2:	eb a9                	jmp    f010546d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f01054c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01054c7:	8b 10                	mov    (%eax),%edx
f01054c9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01054ce:	8d 40 04             	lea    0x4(%eax),%eax
f01054d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01054d4:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
f01054d9:	eb 92                	jmp    f010546d <vprintfmt+0x3a8>
			putch(ch, putdat);
f01054db:	83 ec 08             	sub    $0x8,%esp
f01054de:	53                   	push   %ebx
f01054df:	6a 25                	push   $0x25
f01054e1:	ff d6                	call   *%esi
			break;
f01054e3:	83 c4 10             	add    $0x10,%esp
f01054e6:	eb 9f                	jmp    f0105487 <vprintfmt+0x3c2>
			putch('%', putdat);
f01054e8:	83 ec 08             	sub    $0x8,%esp
f01054eb:	53                   	push   %ebx
f01054ec:	6a 25                	push   $0x25
f01054ee:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01054f0:	83 c4 10             	add    $0x10,%esp
f01054f3:	89 f8                	mov    %edi,%eax
f01054f5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01054f9:	74 05                	je     f0105500 <vprintfmt+0x43b>
f01054fb:	83 e8 01             	sub    $0x1,%eax
f01054fe:	eb f5                	jmp    f01054f5 <vprintfmt+0x430>
f0105500:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105503:	eb 82                	jmp    f0105487 <vprintfmt+0x3c2>

f0105505 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105505:	55                   	push   %ebp
f0105506:	89 e5                	mov    %esp,%ebp
f0105508:	83 ec 18             	sub    $0x18,%esp
f010550b:	8b 45 08             	mov    0x8(%ebp),%eax
f010550e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105511:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105514:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105518:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010551b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105522:	85 c0                	test   %eax,%eax
f0105524:	74 26                	je     f010554c <vsnprintf+0x47>
f0105526:	85 d2                	test   %edx,%edx
f0105528:	7e 22                	jle    f010554c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010552a:	ff 75 14             	push   0x14(%ebp)
f010552d:	ff 75 10             	push   0x10(%ebp)
f0105530:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105533:	50                   	push   %eax
f0105534:	68 8b 50 10 f0       	push   $0xf010508b
f0105539:	e8 87 fb ff ff       	call   f01050c5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010553e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105541:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105544:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105547:	83 c4 10             	add    $0x10,%esp
}
f010554a:	c9                   	leave  
f010554b:	c3                   	ret    
		return -E_INVAL;
f010554c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105551:	eb f7                	jmp    f010554a <vsnprintf+0x45>

f0105553 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105553:	55                   	push   %ebp
f0105554:	89 e5                	mov    %esp,%ebp
f0105556:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105559:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010555c:	50                   	push   %eax
f010555d:	ff 75 10             	push   0x10(%ebp)
f0105560:	ff 75 0c             	push   0xc(%ebp)
f0105563:	ff 75 08             	push   0x8(%ebp)
f0105566:	e8 9a ff ff ff       	call   f0105505 <vsnprintf>
	va_end(ap);

	return rc;
}
f010556b:	c9                   	leave  
f010556c:	c3                   	ret    

f010556d <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010556d:	55                   	push   %ebp
f010556e:	89 e5                	mov    %esp,%ebp
f0105570:	57                   	push   %edi
f0105571:	56                   	push   %esi
f0105572:	53                   	push   %ebx
f0105573:	83 ec 0c             	sub    $0xc,%esp
f0105576:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105579:	85 c0                	test   %eax,%eax
f010557b:	74 11                	je     f010558e <readline+0x21>
		cprintf("%s", prompt);
f010557d:	83 ec 08             	sub    $0x8,%esp
f0105580:	50                   	push   %eax
f0105581:	68 c7 69 10 f0       	push   $0xf01069c7
f0105586:	e8 ff e3 ff ff       	call   f010398a <cprintf>
f010558b:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f010558e:	83 ec 0c             	sub    $0xc,%esp
f0105591:	6a 00                	push   $0x0
f0105593:	e8 06 b2 ff ff       	call   f010079e <iscons>
f0105598:	89 c7                	mov    %eax,%edi
f010559a:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010559d:	be 00 00 00 00       	mov    $0x0,%esi
f01055a2:	eb 4b                	jmp    f01055ef <readline+0x82>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01055a4:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f01055a9:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01055ac:	75 08                	jne    f01055b6 <readline+0x49>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01055ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055b1:	5b                   	pop    %ebx
f01055b2:	5e                   	pop    %esi
f01055b3:	5f                   	pop    %edi
f01055b4:	5d                   	pop    %ebp
f01055b5:	c3                   	ret    
				cprintf("read error: %e\n", c);
f01055b6:	83 ec 08             	sub    $0x8,%esp
f01055b9:	53                   	push   %ebx
f01055ba:	68 bf 7f 10 f0       	push   $0xf0107fbf
f01055bf:	e8 c6 e3 ff ff       	call   f010398a <cprintf>
f01055c4:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01055c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01055cc:	eb e0                	jmp    f01055ae <readline+0x41>
			if (echoing)
f01055ce:	85 ff                	test   %edi,%edi
f01055d0:	75 05                	jne    f01055d7 <readline+0x6a>
			i--;
f01055d2:	83 ee 01             	sub    $0x1,%esi
f01055d5:	eb 18                	jmp    f01055ef <readline+0x82>
				cputchar('\b');
f01055d7:	83 ec 0c             	sub    $0xc,%esp
f01055da:	6a 08                	push   $0x8
f01055dc:	e8 9c b1 ff ff       	call   f010077d <cputchar>
f01055e1:	83 c4 10             	add    $0x10,%esp
f01055e4:	eb ec                	jmp    f01055d2 <readline+0x65>
			buf[i++] = c;
f01055e6:	88 9e a0 7a 21 f0    	mov    %bl,-0xfde8560(%esi)
f01055ec:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f01055ef:	e8 99 b1 ff ff       	call   f010078d <getchar>
f01055f4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01055f6:	85 c0                	test   %eax,%eax
f01055f8:	78 aa                	js     f01055a4 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01055fa:	83 f8 08             	cmp    $0x8,%eax
f01055fd:	0f 94 c0             	sete   %al
f0105600:	83 fb 7f             	cmp    $0x7f,%ebx
f0105603:	0f 94 c2             	sete   %dl
f0105606:	08 d0                	or     %dl,%al
f0105608:	74 04                	je     f010560e <readline+0xa1>
f010560a:	85 f6                	test   %esi,%esi
f010560c:	7f c0                	jg     f01055ce <readline+0x61>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010560e:	83 fb 1f             	cmp    $0x1f,%ebx
f0105611:	7e 1a                	jle    f010562d <readline+0xc0>
f0105613:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105619:	7f 12                	jg     f010562d <readline+0xc0>
			if (echoing)
f010561b:	85 ff                	test   %edi,%edi
f010561d:	74 c7                	je     f01055e6 <readline+0x79>
				cputchar(c);
f010561f:	83 ec 0c             	sub    $0xc,%esp
f0105622:	53                   	push   %ebx
f0105623:	e8 55 b1 ff ff       	call   f010077d <cputchar>
f0105628:	83 c4 10             	add    $0x10,%esp
f010562b:	eb b9                	jmp    f01055e6 <readline+0x79>
		} else if (c == '\n' || c == '\r') {
f010562d:	83 fb 0a             	cmp    $0xa,%ebx
f0105630:	74 05                	je     f0105637 <readline+0xca>
f0105632:	83 fb 0d             	cmp    $0xd,%ebx
f0105635:	75 b8                	jne    f01055ef <readline+0x82>
			if (echoing)
f0105637:	85 ff                	test   %edi,%edi
f0105639:	75 11                	jne    f010564c <readline+0xdf>
			buf[i] = 0;
f010563b:	c6 86 a0 7a 21 f0 00 	movb   $0x0,-0xfde8560(%esi)
			return buf;
f0105642:	b8 a0 7a 21 f0       	mov    $0xf0217aa0,%eax
f0105647:	e9 62 ff ff ff       	jmp    f01055ae <readline+0x41>
				cputchar('\n');
f010564c:	83 ec 0c             	sub    $0xc,%esp
f010564f:	6a 0a                	push   $0xa
f0105651:	e8 27 b1 ff ff       	call   f010077d <cputchar>
f0105656:	83 c4 10             	add    $0x10,%esp
f0105659:	eb e0                	jmp    f010563b <readline+0xce>

f010565b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010565b:	55                   	push   %ebp
f010565c:	89 e5                	mov    %esp,%ebp
f010565e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105661:	b8 00 00 00 00       	mov    $0x0,%eax
f0105666:	eb 03                	jmp    f010566b <strlen+0x10>
		n++;
f0105668:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f010566b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010566f:	75 f7                	jne    f0105668 <strlen+0xd>
	return n;
}
f0105671:	5d                   	pop    %ebp
f0105672:	c3                   	ret    

f0105673 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105673:	55                   	push   %ebp
f0105674:	89 e5                	mov    %esp,%ebp
f0105676:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105679:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010567c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105681:	eb 03                	jmp    f0105686 <strnlen+0x13>
		n++;
f0105683:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105686:	39 d0                	cmp    %edx,%eax
f0105688:	74 08                	je     f0105692 <strnlen+0x1f>
f010568a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010568e:	75 f3                	jne    f0105683 <strnlen+0x10>
f0105690:	89 c2                	mov    %eax,%edx
	return n;
}
f0105692:	89 d0                	mov    %edx,%eax
f0105694:	5d                   	pop    %ebp
f0105695:	c3                   	ret    

f0105696 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105696:	55                   	push   %ebp
f0105697:	89 e5                	mov    %esp,%ebp
f0105699:	53                   	push   %ebx
f010569a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010569d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01056a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01056a5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01056a9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01056ac:	83 c0 01             	add    $0x1,%eax
f01056af:	84 d2                	test   %dl,%dl
f01056b1:	75 f2                	jne    f01056a5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01056b3:	89 c8                	mov    %ecx,%eax
f01056b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01056b8:	c9                   	leave  
f01056b9:	c3                   	ret    

f01056ba <strcat>:

char *
strcat(char *dst, const char *src)
{
f01056ba:	55                   	push   %ebp
f01056bb:	89 e5                	mov    %esp,%ebp
f01056bd:	53                   	push   %ebx
f01056be:	83 ec 10             	sub    $0x10,%esp
f01056c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01056c4:	53                   	push   %ebx
f01056c5:	e8 91 ff ff ff       	call   f010565b <strlen>
f01056ca:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01056cd:	ff 75 0c             	push   0xc(%ebp)
f01056d0:	01 d8                	add    %ebx,%eax
f01056d2:	50                   	push   %eax
f01056d3:	e8 be ff ff ff       	call   f0105696 <strcpy>
	return dst;
}
f01056d8:	89 d8                	mov    %ebx,%eax
f01056da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01056dd:	c9                   	leave  
f01056de:	c3                   	ret    

f01056df <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01056df:	55                   	push   %ebp
f01056e0:	89 e5                	mov    %esp,%ebp
f01056e2:	56                   	push   %esi
f01056e3:	53                   	push   %ebx
f01056e4:	8b 75 08             	mov    0x8(%ebp),%esi
f01056e7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056ea:	89 f3                	mov    %esi,%ebx
f01056ec:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01056ef:	89 f0                	mov    %esi,%eax
f01056f1:	eb 0f                	jmp    f0105702 <strncpy+0x23>
		*dst++ = *src;
f01056f3:	83 c0 01             	add    $0x1,%eax
f01056f6:	0f b6 0a             	movzbl (%edx),%ecx
f01056f9:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01056fc:	80 f9 01             	cmp    $0x1,%cl
f01056ff:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0105702:	39 d8                	cmp    %ebx,%eax
f0105704:	75 ed                	jne    f01056f3 <strncpy+0x14>
	}
	return ret;
}
f0105706:	89 f0                	mov    %esi,%eax
f0105708:	5b                   	pop    %ebx
f0105709:	5e                   	pop    %esi
f010570a:	5d                   	pop    %ebp
f010570b:	c3                   	ret    

f010570c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010570c:	55                   	push   %ebp
f010570d:	89 e5                	mov    %esp,%ebp
f010570f:	56                   	push   %esi
f0105710:	53                   	push   %ebx
f0105711:	8b 75 08             	mov    0x8(%ebp),%esi
f0105714:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105717:	8b 55 10             	mov    0x10(%ebp),%edx
f010571a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010571c:	85 d2                	test   %edx,%edx
f010571e:	74 21                	je     f0105741 <strlcpy+0x35>
f0105720:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105724:	89 f2                	mov    %esi,%edx
f0105726:	eb 09                	jmp    f0105731 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105728:	83 c1 01             	add    $0x1,%ecx
f010572b:	83 c2 01             	add    $0x1,%edx
f010572e:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0105731:	39 c2                	cmp    %eax,%edx
f0105733:	74 09                	je     f010573e <strlcpy+0x32>
f0105735:	0f b6 19             	movzbl (%ecx),%ebx
f0105738:	84 db                	test   %bl,%bl
f010573a:	75 ec                	jne    f0105728 <strlcpy+0x1c>
f010573c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f010573e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105741:	29 f0                	sub    %esi,%eax
}
f0105743:	5b                   	pop    %ebx
f0105744:	5e                   	pop    %esi
f0105745:	5d                   	pop    %ebp
f0105746:	c3                   	ret    

f0105747 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105747:	55                   	push   %ebp
f0105748:	89 e5                	mov    %esp,%ebp
f010574a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010574d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105750:	eb 06                	jmp    f0105758 <strcmp+0x11>
		p++, q++;
f0105752:	83 c1 01             	add    $0x1,%ecx
f0105755:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105758:	0f b6 01             	movzbl (%ecx),%eax
f010575b:	84 c0                	test   %al,%al
f010575d:	74 04                	je     f0105763 <strcmp+0x1c>
f010575f:	3a 02                	cmp    (%edx),%al
f0105761:	74 ef                	je     f0105752 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105763:	0f b6 c0             	movzbl %al,%eax
f0105766:	0f b6 12             	movzbl (%edx),%edx
f0105769:	29 d0                	sub    %edx,%eax
}
f010576b:	5d                   	pop    %ebp
f010576c:	c3                   	ret    

f010576d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010576d:	55                   	push   %ebp
f010576e:	89 e5                	mov    %esp,%ebp
f0105770:	53                   	push   %ebx
f0105771:	8b 45 08             	mov    0x8(%ebp),%eax
f0105774:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105777:	89 c3                	mov    %eax,%ebx
f0105779:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010577c:	eb 06                	jmp    f0105784 <strncmp+0x17>
		n--, p++, q++;
f010577e:	83 c0 01             	add    $0x1,%eax
f0105781:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105784:	39 d8                	cmp    %ebx,%eax
f0105786:	74 18                	je     f01057a0 <strncmp+0x33>
f0105788:	0f b6 08             	movzbl (%eax),%ecx
f010578b:	84 c9                	test   %cl,%cl
f010578d:	74 04                	je     f0105793 <strncmp+0x26>
f010578f:	3a 0a                	cmp    (%edx),%cl
f0105791:	74 eb                	je     f010577e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105793:	0f b6 00             	movzbl (%eax),%eax
f0105796:	0f b6 12             	movzbl (%edx),%edx
f0105799:	29 d0                	sub    %edx,%eax
}
f010579b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010579e:	c9                   	leave  
f010579f:	c3                   	ret    
		return 0;
f01057a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01057a5:	eb f4                	jmp    f010579b <strncmp+0x2e>

f01057a7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01057a7:	55                   	push   %ebp
f01057a8:	89 e5                	mov    %esp,%ebp
f01057aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01057ad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01057b1:	eb 03                	jmp    f01057b6 <strchr+0xf>
f01057b3:	83 c0 01             	add    $0x1,%eax
f01057b6:	0f b6 10             	movzbl (%eax),%edx
f01057b9:	84 d2                	test   %dl,%dl
f01057bb:	74 06                	je     f01057c3 <strchr+0x1c>
		if (*s == c)
f01057bd:	38 ca                	cmp    %cl,%dl
f01057bf:	75 f2                	jne    f01057b3 <strchr+0xc>
f01057c1:	eb 05                	jmp    f01057c8 <strchr+0x21>
			return (char *) s;
	return 0;
f01057c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057c8:	5d                   	pop    %ebp
f01057c9:	c3                   	ret    

f01057ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01057ca:	55                   	push   %ebp
f01057cb:	89 e5                	mov    %esp,%ebp
f01057cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01057d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01057d4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01057d7:	38 ca                	cmp    %cl,%dl
f01057d9:	74 09                	je     f01057e4 <strfind+0x1a>
f01057db:	84 d2                	test   %dl,%dl
f01057dd:	74 05                	je     f01057e4 <strfind+0x1a>
	for (; *s; s++)
f01057df:	83 c0 01             	add    $0x1,%eax
f01057e2:	eb f0                	jmp    f01057d4 <strfind+0xa>
			break;
	return (char *) s;
}
f01057e4:	5d                   	pop    %ebp
f01057e5:	c3                   	ret    

f01057e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01057e6:	55                   	push   %ebp
f01057e7:	89 e5                	mov    %esp,%ebp
f01057e9:	57                   	push   %edi
f01057ea:	56                   	push   %esi
f01057eb:	53                   	push   %ebx
f01057ec:	8b 7d 08             	mov    0x8(%ebp),%edi
f01057ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01057f2:	85 c9                	test   %ecx,%ecx
f01057f4:	74 2f                	je     f0105825 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01057f6:	89 f8                	mov    %edi,%eax
f01057f8:	09 c8                	or     %ecx,%eax
f01057fa:	a8 03                	test   $0x3,%al
f01057fc:	75 21                	jne    f010581f <memset+0x39>
		c &= 0xFF;
f01057fe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105802:	89 d0                	mov    %edx,%eax
f0105804:	c1 e0 08             	shl    $0x8,%eax
f0105807:	89 d3                	mov    %edx,%ebx
f0105809:	c1 e3 18             	shl    $0x18,%ebx
f010580c:	89 d6                	mov    %edx,%esi
f010580e:	c1 e6 10             	shl    $0x10,%esi
f0105811:	09 f3                	or     %esi,%ebx
f0105813:	09 da                	or     %ebx,%edx
f0105815:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105817:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010581a:	fc                   	cld    
f010581b:	f3 ab                	rep stos %eax,%es:(%edi)
f010581d:	eb 06                	jmp    f0105825 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010581f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105822:	fc                   	cld    
f0105823:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105825:	89 f8                	mov    %edi,%eax
f0105827:	5b                   	pop    %ebx
f0105828:	5e                   	pop    %esi
f0105829:	5f                   	pop    %edi
f010582a:	5d                   	pop    %ebp
f010582b:	c3                   	ret    

f010582c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010582c:	55                   	push   %ebp
f010582d:	89 e5                	mov    %esp,%ebp
f010582f:	57                   	push   %edi
f0105830:	56                   	push   %esi
f0105831:	8b 45 08             	mov    0x8(%ebp),%eax
f0105834:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105837:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010583a:	39 c6                	cmp    %eax,%esi
f010583c:	73 32                	jae    f0105870 <memmove+0x44>
f010583e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105841:	39 c2                	cmp    %eax,%edx
f0105843:	76 2b                	jbe    f0105870 <memmove+0x44>
		s += n;
		d += n;
f0105845:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105848:	89 d6                	mov    %edx,%esi
f010584a:	09 fe                	or     %edi,%esi
f010584c:	09 ce                	or     %ecx,%esi
f010584e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105854:	75 0e                	jne    f0105864 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105856:	83 ef 04             	sub    $0x4,%edi
f0105859:	8d 72 fc             	lea    -0x4(%edx),%esi
f010585c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010585f:	fd                   	std    
f0105860:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105862:	eb 09                	jmp    f010586d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105864:	83 ef 01             	sub    $0x1,%edi
f0105867:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010586a:	fd                   	std    
f010586b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010586d:	fc                   	cld    
f010586e:	eb 1a                	jmp    f010588a <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105870:	89 f2                	mov    %esi,%edx
f0105872:	09 c2                	or     %eax,%edx
f0105874:	09 ca                	or     %ecx,%edx
f0105876:	f6 c2 03             	test   $0x3,%dl
f0105879:	75 0a                	jne    f0105885 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010587b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010587e:	89 c7                	mov    %eax,%edi
f0105880:	fc                   	cld    
f0105881:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105883:	eb 05                	jmp    f010588a <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0105885:	89 c7                	mov    %eax,%edi
f0105887:	fc                   	cld    
f0105888:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010588a:	5e                   	pop    %esi
f010588b:	5f                   	pop    %edi
f010588c:	5d                   	pop    %ebp
f010588d:	c3                   	ret    

f010588e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010588e:	55                   	push   %ebp
f010588f:	89 e5                	mov    %esp,%ebp
f0105891:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105894:	ff 75 10             	push   0x10(%ebp)
f0105897:	ff 75 0c             	push   0xc(%ebp)
f010589a:	ff 75 08             	push   0x8(%ebp)
f010589d:	e8 8a ff ff ff       	call   f010582c <memmove>
}
f01058a2:	c9                   	leave  
f01058a3:	c3                   	ret    

f01058a4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01058a4:	55                   	push   %ebp
f01058a5:	89 e5                	mov    %esp,%ebp
f01058a7:	56                   	push   %esi
f01058a8:	53                   	push   %ebx
f01058a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01058ac:	8b 55 0c             	mov    0xc(%ebp),%edx
f01058af:	89 c6                	mov    %eax,%esi
f01058b1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01058b4:	eb 06                	jmp    f01058bc <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01058b6:	83 c0 01             	add    $0x1,%eax
f01058b9:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f01058bc:	39 f0                	cmp    %esi,%eax
f01058be:	74 14                	je     f01058d4 <memcmp+0x30>
		if (*s1 != *s2)
f01058c0:	0f b6 08             	movzbl (%eax),%ecx
f01058c3:	0f b6 1a             	movzbl (%edx),%ebx
f01058c6:	38 d9                	cmp    %bl,%cl
f01058c8:	74 ec                	je     f01058b6 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f01058ca:	0f b6 c1             	movzbl %cl,%eax
f01058cd:	0f b6 db             	movzbl %bl,%ebx
f01058d0:	29 d8                	sub    %ebx,%eax
f01058d2:	eb 05                	jmp    f01058d9 <memcmp+0x35>
	}

	return 0;
f01058d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01058d9:	5b                   	pop    %ebx
f01058da:	5e                   	pop    %esi
f01058db:	5d                   	pop    %ebp
f01058dc:	c3                   	ret    

f01058dd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01058dd:	55                   	push   %ebp
f01058de:	89 e5                	mov    %esp,%ebp
f01058e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01058e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01058e6:	89 c2                	mov    %eax,%edx
f01058e8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01058eb:	eb 03                	jmp    f01058f0 <memfind+0x13>
f01058ed:	83 c0 01             	add    $0x1,%eax
f01058f0:	39 d0                	cmp    %edx,%eax
f01058f2:	73 04                	jae    f01058f8 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01058f4:	38 08                	cmp    %cl,(%eax)
f01058f6:	75 f5                	jne    f01058ed <memfind+0x10>
			break;
	return (void *) s;
}
f01058f8:	5d                   	pop    %ebp
f01058f9:	c3                   	ret    

f01058fa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01058fa:	55                   	push   %ebp
f01058fb:	89 e5                	mov    %esp,%ebp
f01058fd:	57                   	push   %edi
f01058fe:	56                   	push   %esi
f01058ff:	53                   	push   %ebx
f0105900:	8b 55 08             	mov    0x8(%ebp),%edx
f0105903:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105906:	eb 03                	jmp    f010590b <strtol+0x11>
		s++;
f0105908:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f010590b:	0f b6 02             	movzbl (%edx),%eax
f010590e:	3c 20                	cmp    $0x20,%al
f0105910:	74 f6                	je     f0105908 <strtol+0xe>
f0105912:	3c 09                	cmp    $0x9,%al
f0105914:	74 f2                	je     f0105908 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105916:	3c 2b                	cmp    $0x2b,%al
f0105918:	74 2a                	je     f0105944 <strtol+0x4a>
	int neg = 0;
f010591a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f010591f:	3c 2d                	cmp    $0x2d,%al
f0105921:	74 2b                	je     f010594e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105923:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105929:	75 0f                	jne    f010593a <strtol+0x40>
f010592b:	80 3a 30             	cmpb   $0x30,(%edx)
f010592e:	74 28                	je     f0105958 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105930:	85 db                	test   %ebx,%ebx
f0105932:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105937:	0f 44 d8             	cmove  %eax,%ebx
f010593a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010593f:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105942:	eb 46                	jmp    f010598a <strtol+0x90>
		s++;
f0105944:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0105947:	bf 00 00 00 00       	mov    $0x0,%edi
f010594c:	eb d5                	jmp    f0105923 <strtol+0x29>
		s++, neg = 1;
f010594e:	83 c2 01             	add    $0x1,%edx
f0105951:	bf 01 00 00 00       	mov    $0x1,%edi
f0105956:	eb cb                	jmp    f0105923 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105958:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010595c:	74 0e                	je     f010596c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f010595e:	85 db                	test   %ebx,%ebx
f0105960:	75 d8                	jne    f010593a <strtol+0x40>
		s++, base = 8;
f0105962:	83 c2 01             	add    $0x1,%edx
f0105965:	bb 08 00 00 00       	mov    $0x8,%ebx
f010596a:	eb ce                	jmp    f010593a <strtol+0x40>
		s += 2, base = 16;
f010596c:	83 c2 02             	add    $0x2,%edx
f010596f:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105974:	eb c4                	jmp    f010593a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105976:	0f be c0             	movsbl %al,%eax
f0105979:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010597c:	3b 45 10             	cmp    0x10(%ebp),%eax
f010597f:	7d 3a                	jge    f01059bb <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105981:	83 c2 01             	add    $0x1,%edx
f0105984:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0105988:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f010598a:	0f b6 02             	movzbl (%edx),%eax
f010598d:	8d 70 d0             	lea    -0x30(%eax),%esi
f0105990:	89 f3                	mov    %esi,%ebx
f0105992:	80 fb 09             	cmp    $0x9,%bl
f0105995:	76 df                	jbe    f0105976 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0105997:	8d 70 9f             	lea    -0x61(%eax),%esi
f010599a:	89 f3                	mov    %esi,%ebx
f010599c:	80 fb 19             	cmp    $0x19,%bl
f010599f:	77 08                	ja     f01059a9 <strtol+0xaf>
			dig = *s - 'a' + 10;
f01059a1:	0f be c0             	movsbl %al,%eax
f01059a4:	83 e8 57             	sub    $0x57,%eax
f01059a7:	eb d3                	jmp    f010597c <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f01059a9:	8d 70 bf             	lea    -0x41(%eax),%esi
f01059ac:	89 f3                	mov    %esi,%ebx
f01059ae:	80 fb 19             	cmp    $0x19,%bl
f01059b1:	77 08                	ja     f01059bb <strtol+0xc1>
			dig = *s - 'A' + 10;
f01059b3:	0f be c0             	movsbl %al,%eax
f01059b6:	83 e8 37             	sub    $0x37,%eax
f01059b9:	eb c1                	jmp    f010597c <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f01059bb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01059bf:	74 05                	je     f01059c6 <strtol+0xcc>
		*endptr = (char *) s;
f01059c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01059c4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f01059c6:	89 c8                	mov    %ecx,%eax
f01059c8:	f7 d8                	neg    %eax
f01059ca:	85 ff                	test   %edi,%edi
f01059cc:	0f 45 c8             	cmovne %eax,%ecx
}
f01059cf:	89 c8                	mov    %ecx,%eax
f01059d1:	5b                   	pop    %ebx
f01059d2:	5e                   	pop    %esi
f01059d3:	5f                   	pop    %edi
f01059d4:	5d                   	pop    %ebp
f01059d5:	c3                   	ret    
f01059d6:	66 90                	xchg   %ax,%ax

f01059d8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01059d8:	fa                   	cli    

	xorw    %ax, %ax
f01059d9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01059db:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01059dd:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01059df:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01059e1:	0f 01 16             	lgdtl  (%esi)
f01059e4:	74 70                	je     f0105a56 <mpsearch1+0x3>
	movl    %cr0, %eax
f01059e6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01059e9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01059ed:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01059f0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01059f6:	08 00                	or     %al,(%eax)

f01059f8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01059f8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01059fc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01059fe:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a00:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105a02:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105a06:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105a08:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105a0a:	b8 00 30 12 00       	mov    $0x123000,%eax
	movl    %eax, %cr3
f0105a0f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105a12:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105a15:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105a1a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105a1d:	8b 25 04 70 21 f0    	mov    0xf0217004,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105a23:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105a28:	b8 b8 01 10 f0       	mov    $0xf01001b8,%eax
	call    *%eax
f0105a2d:	ff d0                	call   *%eax

f0105a2f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105a2f:	eb fe                	jmp    f0105a2f <spin>
f0105a31:	8d 76 00             	lea    0x0(%esi),%esi

f0105a34 <gdt>:
	...
f0105a3c:	ff                   	(bad)  
f0105a3d:	ff 00                	incl   (%eax)
f0105a3f:	00 00                	add    %al,(%eax)
f0105a41:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105a48:	00                   	.byte 0x0
f0105a49:	92                   	xchg   %eax,%edx
f0105a4a:	cf                   	iret   
	...

f0105a4c <gdtdesc>:
f0105a4c:	17                   	pop    %ss
f0105a4d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105a52 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105a52:	90                   	nop

f0105a53 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105a53:	55                   	push   %ebp
f0105a54:	89 e5                	mov    %esp,%ebp
f0105a56:	57                   	push   %edi
f0105a57:	56                   	push   %esi
f0105a58:	53                   	push   %ebx
f0105a59:	83 ec 1c             	sub    $0x1c,%esp
f0105a5c:	89 c6                	mov    %eax,%esi
	if (PGNUM(pa) >= npages)
f0105a5e:	8b 0d 60 72 21 f0    	mov    0xf0217260,%ecx
f0105a64:	c1 e8 0c             	shr    $0xc,%eax
f0105a67:	39 c8                	cmp    %ecx,%eax
f0105a69:	73 22                	jae    f0105a8d <mpsearch1+0x3a>
	return (void *)(pa + KERNBASE);
f0105a6b:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105a71:	8d 04 32             	lea    (%edx,%esi,1),%eax
	if (PGNUM(pa) >= npages)
f0105a74:	89 c2                	mov    %eax,%edx
f0105a76:	c1 ea 0c             	shr    $0xc,%edx
f0105a79:	39 ca                	cmp    %ecx,%edx
f0105a7b:	73 22                	jae    f0105a9f <mpsearch1+0x4c>
	return (void *)(pa + KERNBASE);
f0105a7d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0105a82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a85:	81 ee f0 ff ff 0f    	sub    $0xffffff0,%esi

	for (; mp < end; mp++)
f0105a8b:	eb 2a                	jmp    f0105ab7 <mpsearch1+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a8d:	56                   	push   %esi
f0105a8e:	68 44 64 10 f0       	push   $0xf0106444
f0105a93:	6a 58                	push   $0x58
f0105a95:	68 5d 81 10 f0       	push   $0xf010815d
f0105a9a:	e8 a1 a5 ff ff       	call   f0100040 <_panic>
f0105a9f:	50                   	push   %eax
f0105aa0:	68 44 64 10 f0       	push   $0xf0106444
f0105aa5:	6a 58                	push   $0x58
f0105aa7:	68 5d 81 10 f0       	push   $0xf010815d
f0105aac:	e8 8f a5 ff ff       	call   f0100040 <_panic>
f0105ab1:	83 c7 10             	add    $0x10,%edi
f0105ab4:	83 c6 10             	add    $0x10,%esi
f0105ab7:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0105aba:	73 2b                	jae    f0105ae7 <mpsearch1+0x94>
f0105abc:	89 fb                	mov    %edi,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105abe:	83 ec 04             	sub    $0x4,%esp
f0105ac1:	6a 04                	push   $0x4
f0105ac3:	68 6d 81 10 f0       	push   $0xf010816d
f0105ac8:	57                   	push   %edi
f0105ac9:	e8 d6 fd ff ff       	call   f01058a4 <memcmp>
f0105ace:	83 c4 10             	add    $0x10,%esp
f0105ad1:	85 c0                	test   %eax,%eax
f0105ad3:	75 dc                	jne    f0105ab1 <mpsearch1+0x5e>
		sum += ((uint8_t *)addr)[i];
f0105ad5:	0f b6 13             	movzbl (%ebx),%edx
f0105ad8:	01 d0                	add    %edx,%eax
	for (i = 0; i < len; i++)
f0105ada:	83 c3 01             	add    $0x1,%ebx
f0105add:	39 f3                	cmp    %esi,%ebx
f0105adf:	75 f4                	jne    f0105ad5 <mpsearch1+0x82>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ae1:	84 c0                	test   %al,%al
f0105ae3:	75 cc                	jne    f0105ab1 <mpsearch1+0x5e>
f0105ae5:	eb 05                	jmp    f0105aec <mpsearch1+0x99>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105ae7:	bf 00 00 00 00       	mov    $0x0,%edi
}
f0105aec:	89 f8                	mov    %edi,%eax
f0105aee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105af1:	5b                   	pop    %ebx
f0105af2:	5e                   	pop    %esi
f0105af3:	5f                   	pop    %edi
f0105af4:	5d                   	pop    %ebp
f0105af5:	c3                   	ret    

f0105af6 <mp_init>:
}

//通过读取位于BIOS内存区域中的MP配置表来获取该信息。
void
mp_init(void)
{
f0105af6:	55                   	push   %ebp
f0105af7:	89 e5                	mov    %esp,%ebp
f0105af9:	57                   	push   %edi
f0105afa:	56                   	push   %esi
f0105afb:	53                   	push   %ebx
f0105afc:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105aff:	c7 05 08 80 25 f0 20 	movl   $0xf0258020,0xf0258008
f0105b06:	80 25 f0 
	if (PGNUM(pa) >= npages)
f0105b09:	83 3d 60 72 21 f0 00 	cmpl   $0x0,0xf0217260
f0105b10:	0f 84 86 00 00 00    	je     f0105b9c <mp_init+0xa6>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105b16:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105b1d:	85 c0                	test   %eax,%eax
f0105b1f:	0f 84 8d 00 00 00    	je     f0105bb2 <mp_init+0xbc>
		p <<= 4;	// Translate from segment to PA
f0105b25:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105b28:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b2d:	e8 21 ff ff ff       	call   f0105a53 <mpsearch1>
f0105b32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b35:	85 c0                	test   %eax,%eax
f0105b37:	75 1a                	jne    f0105b53 <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f0105b39:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105b3e:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105b43:	e8 0b ff ff ff       	call   f0105a53 <mpsearch1>
f0105b48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0105b4b:	85 c0                	test   %eax,%eax
f0105b4d:	0f 84 20 02 00 00    	je     f0105d73 <mp_init+0x27d>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105b53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b56:	8b 58 04             	mov    0x4(%eax),%ebx
f0105b59:	85 db                	test   %ebx,%ebx
f0105b5b:	74 7a                	je     f0105bd7 <mp_init+0xe1>
f0105b5d:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105b61:	75 74                	jne    f0105bd7 <mp_init+0xe1>
f0105b63:	89 d8                	mov    %ebx,%eax
f0105b65:	c1 e8 0c             	shr    $0xc,%eax
f0105b68:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0105b6e:	73 7c                	jae    f0105bec <mp_init+0xf6>
	return (void *)(pa + KERNBASE);
f0105b70:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0105b76:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105b78:	83 ec 04             	sub    $0x4,%esp
f0105b7b:	6a 04                	push   $0x4
f0105b7d:	68 72 81 10 f0       	push   $0xf0108172
f0105b82:	53                   	push   %ebx
f0105b83:	e8 1c fd ff ff       	call   f01058a4 <memcmp>
f0105b88:	83 c4 10             	add    $0x10,%esp
f0105b8b:	85 c0                	test   %eax,%eax
f0105b8d:	75 72                	jne    f0105c01 <mp_init+0x10b>
f0105b8f:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105b93:	01 df                	add    %ebx,%edi
	sum = 0;
f0105b95:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0105b97:	e9 82 00 00 00       	jmp    f0105c1e <mp_init+0x128>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b9c:	68 00 04 00 00       	push   $0x400
f0105ba1:	68 44 64 10 f0       	push   $0xf0106444
f0105ba6:	6a 70                	push   $0x70
f0105ba8:	68 5d 81 10 f0       	push   $0xf010815d
f0105bad:	e8 8e a4 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105bb2:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105bb9:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105bbc:	2d 00 04 00 00       	sub    $0x400,%eax
f0105bc1:	ba 00 04 00 00       	mov    $0x400,%edx
f0105bc6:	e8 88 fe ff ff       	call   f0105a53 <mpsearch1>
f0105bcb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105bce:	85 c0                	test   %eax,%eax
f0105bd0:	75 81                	jne    f0105b53 <mp_init+0x5d>
f0105bd2:	e9 62 ff ff ff       	jmp    f0105b39 <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f0105bd7:	83 ec 0c             	sub    $0xc,%esp
f0105bda:	68 d0 7f 10 f0       	push   $0xf0107fd0
f0105bdf:	e8 a6 dd ff ff       	call   f010398a <cprintf>
		return NULL;
f0105be4:	83 c4 10             	add    $0x10,%esp
f0105be7:	e9 87 01 00 00       	jmp    f0105d73 <mp_init+0x27d>
f0105bec:	53                   	push   %ebx
f0105bed:	68 44 64 10 f0       	push   $0xf0106444
f0105bf2:	68 91 00 00 00       	push   $0x91
f0105bf7:	68 5d 81 10 f0       	push   $0xf010815d
f0105bfc:	e8 3f a4 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105c01:	83 ec 0c             	sub    $0xc,%esp
f0105c04:	68 00 80 10 f0       	push   $0xf0108000
f0105c09:	e8 7c dd ff ff       	call   f010398a <cprintf>
		return NULL;
f0105c0e:	83 c4 10             	add    $0x10,%esp
f0105c11:	e9 5d 01 00 00       	jmp    f0105d73 <mp_init+0x27d>
		sum += ((uint8_t *)addr)[i];
f0105c16:	0f b6 0b             	movzbl (%ebx),%ecx
f0105c19:	01 ca                	add    %ecx,%edx
f0105c1b:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105c1e:	39 fb                	cmp    %edi,%ebx
f0105c20:	75 f4                	jne    f0105c16 <mp_init+0x120>
	if (sum(conf, conf->length) != 0) {
f0105c22:	84 d2                	test   %dl,%dl
f0105c24:	75 16                	jne    f0105c3c <mp_init+0x146>
	if (conf->version != 1 && conf->version != 4) {
f0105c26:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105c2a:	80 fa 01             	cmp    $0x1,%dl
f0105c2d:	74 05                	je     f0105c34 <mp_init+0x13e>
f0105c2f:	80 fa 04             	cmp    $0x4,%dl
f0105c32:	75 1d                	jne    f0105c51 <mp_init+0x15b>
f0105c34:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0105c38:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f0105c3a:	eb 36                	jmp    f0105c72 <mp_init+0x17c>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105c3c:	83 ec 0c             	sub    $0xc,%esp
f0105c3f:	68 34 80 10 f0       	push   $0xf0108034
f0105c44:	e8 41 dd ff ff       	call   f010398a <cprintf>
		return NULL;
f0105c49:	83 c4 10             	add    $0x10,%esp
f0105c4c:	e9 22 01 00 00       	jmp    f0105d73 <mp_init+0x27d>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105c51:	83 ec 08             	sub    $0x8,%esp
f0105c54:	0f b6 d2             	movzbl %dl,%edx
f0105c57:	52                   	push   %edx
f0105c58:	68 58 80 10 f0       	push   $0xf0108058
f0105c5d:	e8 28 dd ff ff       	call   f010398a <cprintf>
		return NULL;
f0105c62:	83 c4 10             	add    $0x10,%esp
f0105c65:	e9 09 01 00 00       	jmp    f0105d73 <mp_init+0x27d>
		sum += ((uint8_t *)addr)[i];
f0105c6a:	0f b6 13             	movzbl (%ebx),%edx
f0105c6d:	01 d0                	add    %edx,%eax
f0105c6f:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105c72:	39 d9                	cmp    %ebx,%ecx
f0105c74:	75 f4                	jne    f0105c6a <mp_init+0x174>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c76:	02 46 2a             	add    0x2a(%esi),%al
f0105c79:	75 1c                	jne    f0105c97 <mp_init+0x1a1>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f0105c7b:	c7 05 04 80 25 f0 01 	movl   $0x1,0xf0258004
f0105c82:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105c85:	8b 46 24             	mov    0x24(%esi),%eax
f0105c88:	a3 c4 83 25 f0       	mov    %eax,0xf02583c4

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c8d:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105c90:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105c95:	eb 4d                	jmp    f0105ce4 <mp_init+0x1ee>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105c97:	83 ec 0c             	sub    $0xc,%esp
f0105c9a:	68 78 80 10 f0       	push   $0xf0108078
f0105c9f:	e8 e6 dc ff ff       	call   f010398a <cprintf>
		return NULL;
f0105ca4:	83 c4 10             	add    $0x10,%esp
f0105ca7:	e9 c7 00 00 00       	jmp    f0105d73 <mp_init+0x27d>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105cac:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105cb0:	74 11                	je     f0105cc3 <mp_init+0x1cd>
				bootcpu = &cpus[ncpu];
f0105cb2:	6b 05 00 80 25 f0 74 	imul   $0x74,0xf0258000,%eax
f0105cb9:	05 20 80 25 f0       	add    $0xf0258020,%eax
f0105cbe:	a3 08 80 25 f0       	mov    %eax,0xf0258008
			if (ncpu < NCPU) {
f0105cc3:	a1 00 80 25 f0       	mov    0xf0258000,%eax
f0105cc8:	83 f8 07             	cmp    $0x7,%eax
f0105ccb:	7f 33                	jg     f0105d00 <mp_init+0x20a>
				cpus[ncpu].cpu_id = ncpu;
f0105ccd:	6b d0 74             	imul   $0x74,%eax,%edx
f0105cd0:	88 82 20 80 25 f0    	mov    %al,-0xfda7fe0(%edx)
				ncpu++;
f0105cd6:	83 c0 01             	add    $0x1,%eax
f0105cd9:	a3 00 80 25 f0       	mov    %eax,0xf0258000
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105cde:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105ce1:	83 c3 01             	add    $0x1,%ebx
f0105ce4:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105ce8:	39 d8                	cmp    %ebx,%eax
f0105cea:	76 4f                	jbe    f0105d3b <mp_init+0x245>
		switch (*p) {
f0105cec:	0f b6 07             	movzbl (%edi),%eax
f0105cef:	84 c0                	test   %al,%al
f0105cf1:	74 b9                	je     f0105cac <mp_init+0x1b6>
f0105cf3:	8d 50 ff             	lea    -0x1(%eax),%edx
f0105cf6:	80 fa 03             	cmp    $0x3,%dl
f0105cf9:	77 1c                	ja     f0105d17 <mp_init+0x221>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105cfb:	83 c7 08             	add    $0x8,%edi
			continue;
f0105cfe:	eb e1                	jmp    f0105ce1 <mp_init+0x1eb>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105d00:	83 ec 08             	sub    $0x8,%esp
f0105d03:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105d07:	50                   	push   %eax
f0105d08:	68 a8 80 10 f0       	push   $0xf01080a8
f0105d0d:	e8 78 dc ff ff       	call   f010398a <cprintf>
f0105d12:	83 c4 10             	add    $0x10,%esp
f0105d15:	eb c7                	jmp    f0105cde <mp_init+0x1e8>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d17:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105d1a:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d1d:	50                   	push   %eax
f0105d1e:	68 d0 80 10 f0       	push   $0xf01080d0
f0105d23:	e8 62 dc ff ff       	call   f010398a <cprintf>
			ismp = 0;
f0105d28:	c7 05 04 80 25 f0 00 	movl   $0x0,0xf0258004
f0105d2f:	00 00 00 
			i = conf->entry;
f0105d32:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0105d36:	83 c4 10             	add    $0x10,%esp
f0105d39:	eb a6                	jmp    f0105ce1 <mp_init+0x1eb>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105d3b:	a1 08 80 25 f0       	mov    0xf0258008,%eax
f0105d40:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105d47:	83 3d 04 80 25 f0 00 	cmpl   $0x0,0xf0258004
f0105d4e:	74 2b                	je     f0105d7b <mp_init+0x285>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105d50:	83 ec 04             	sub    $0x4,%esp
f0105d53:	ff 35 00 80 25 f0    	push   0xf0258000
f0105d59:	0f b6 00             	movzbl (%eax),%eax
f0105d5c:	50                   	push   %eax
f0105d5d:	68 77 81 10 f0       	push   $0xf0108177
f0105d62:	e8 23 dc ff ff       	call   f010398a <cprintf>

	if (mp->imcrp) {
f0105d67:	83 c4 10             	add    $0x10,%esp
f0105d6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d6d:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105d71:	75 2e                	jne    f0105da1 <mp_init+0x2ab>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105d73:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d76:	5b                   	pop    %ebx
f0105d77:	5e                   	pop    %esi
f0105d78:	5f                   	pop    %edi
f0105d79:	5d                   	pop    %ebp
f0105d7a:	c3                   	ret    
		ncpu = 1;
f0105d7b:	c7 05 00 80 25 f0 01 	movl   $0x1,0xf0258000
f0105d82:	00 00 00 
		lapicaddr = 0;
f0105d85:	c7 05 c4 83 25 f0 00 	movl   $0x0,0xf02583c4
f0105d8c:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105d8f:	83 ec 0c             	sub    $0xc,%esp
f0105d92:	68 f0 80 10 f0       	push   $0xf01080f0
f0105d97:	e8 ee db ff ff       	call   f010398a <cprintf>
		return;
f0105d9c:	83 c4 10             	add    $0x10,%esp
f0105d9f:	eb d2                	jmp    f0105d73 <mp_init+0x27d>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105da1:	83 ec 0c             	sub    $0xc,%esp
f0105da4:	68 1c 81 10 f0       	push   $0xf010811c
f0105da9:	e8 dc db ff ff       	call   f010398a <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105dae:	b8 70 00 00 00       	mov    $0x70,%eax
f0105db3:	ba 22 00 00 00       	mov    $0x22,%edx
f0105db8:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105db9:	ba 23 00 00 00       	mov    $0x23,%edx
f0105dbe:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105dbf:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105dc2:	ee                   	out    %al,(%dx)
}
f0105dc3:	83 c4 10             	add    $0x10,%esp
f0105dc6:	eb ab                	jmp    f0105d73 <mp_init+0x27d>

f0105dc8 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0105dc8:	8b 0d c0 83 25 f0    	mov    0xf02583c0,%ecx
f0105dce:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105dd1:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105dd3:	a1 c0 83 25 f0       	mov    0xf02583c0,%eax
f0105dd8:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105ddb:	c3                   	ret    

f0105ddc <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f0105ddc:	8b 15 c0 83 25 f0    	mov    0xf02583c0,%edx
		return lapic[ID] >> 24;
	return 0;
f0105de2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105de7:	85 d2                	test   %edx,%edx
f0105de9:	74 06                	je     f0105df1 <cpunum+0x15>
		return lapic[ID] >> 24;
f0105deb:	8b 42 20             	mov    0x20(%edx),%eax
f0105dee:	c1 e8 18             	shr    $0x18,%eax
}
f0105df1:	c3                   	ret    

f0105df2 <lapic_init>:
	if (!lapicaddr)
f0105df2:	a1 c4 83 25 f0       	mov    0xf02583c4,%eax
f0105df7:	85 c0                	test   %eax,%eax
f0105df9:	75 01                	jne    f0105dfc <lapic_init+0xa>
f0105dfb:	c3                   	ret    
{
f0105dfc:	55                   	push   %ebp
f0105dfd:	89 e5                	mov    %esp,%ebp
f0105dff:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105e02:	68 00 10 00 00       	push   $0x1000
f0105e07:	50                   	push   %eax
f0105e08:	e8 b0 b4 ff ff       	call   f01012bd <mmio_map_region>
f0105e0d:	a3 c0 83 25 f0       	mov    %eax,0xf02583c0
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105e12:	ba 27 01 00 00       	mov    $0x127,%edx
f0105e17:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105e1c:	e8 a7 ff ff ff       	call   f0105dc8 <lapicw>
	lapicw(TDCR, X1);
f0105e21:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105e26:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105e2b:	e8 98 ff ff ff       	call   f0105dc8 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105e30:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105e35:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105e3a:	e8 89 ff ff ff       	call   f0105dc8 <lapicw>
	lapicw(TICR, 10000000); 
f0105e3f:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105e44:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105e49:	e8 7a ff ff ff       	call   f0105dc8 <lapicw>
	if (thiscpu != bootcpu)
f0105e4e:	e8 89 ff ff ff       	call   f0105ddc <cpunum>
f0105e53:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e56:	05 20 80 25 f0       	add    $0xf0258020,%eax
f0105e5b:	83 c4 10             	add    $0x10,%esp
f0105e5e:	39 05 08 80 25 f0    	cmp    %eax,0xf0258008
f0105e64:	74 0f                	je     f0105e75 <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f0105e66:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e6b:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105e70:	e8 53 ff ff ff       	call   f0105dc8 <lapicw>
	lapicw(LINT1, MASKED);
f0105e75:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e7a:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105e7f:	e8 44 ff ff ff       	call   f0105dc8 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105e84:	a1 c0 83 25 f0       	mov    0xf02583c0,%eax
f0105e89:	8b 40 30             	mov    0x30(%eax),%eax
f0105e8c:	c1 e8 10             	shr    $0x10,%eax
f0105e8f:	a8 fc                	test   $0xfc,%al
f0105e91:	75 7c                	jne    f0105f0f <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105e93:	ba 33 00 00 00       	mov    $0x33,%edx
f0105e98:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105e9d:	e8 26 ff ff ff       	call   f0105dc8 <lapicw>
	lapicw(ESR, 0);
f0105ea2:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ea7:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105eac:	e8 17 ff ff ff       	call   f0105dc8 <lapicw>
	lapicw(ESR, 0);
f0105eb1:	ba 00 00 00 00       	mov    $0x0,%edx
f0105eb6:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ebb:	e8 08 ff ff ff       	call   f0105dc8 <lapicw>
	lapicw(EOI, 0);
f0105ec0:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ec5:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105eca:	e8 f9 fe ff ff       	call   f0105dc8 <lapicw>
	lapicw(ICRHI, 0);
f0105ecf:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ed4:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ed9:	e8 ea fe ff ff       	call   f0105dc8 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105ede:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105ee3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ee8:	e8 db fe ff ff       	call   f0105dc8 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105eed:	8b 15 c0 83 25 f0    	mov    0xf02583c0,%edx
f0105ef3:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105ef9:	f6 c4 10             	test   $0x10,%ah
f0105efc:	75 f5                	jne    f0105ef3 <lapic_init+0x101>
	lapicw(TPR, 0);
f0105efe:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f03:	b8 20 00 00 00       	mov    $0x20,%eax
f0105f08:	e8 bb fe ff ff       	call   f0105dc8 <lapicw>
}
f0105f0d:	c9                   	leave  
f0105f0e:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0105f0f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f14:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105f19:	e8 aa fe ff ff       	call   f0105dc8 <lapicw>
f0105f1e:	e9 70 ff ff ff       	jmp    f0105e93 <lapic_init+0xa1>

f0105f23 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105f23:	83 3d c0 83 25 f0 00 	cmpl   $0x0,0xf02583c0
f0105f2a:	74 17                	je     f0105f43 <lapic_eoi+0x20>
{
f0105f2c:	55                   	push   %ebp
f0105f2d:	89 e5                	mov    %esp,%ebp
f0105f2f:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0105f32:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f37:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f3c:	e8 87 fe ff ff       	call   f0105dc8 <lapicw>
}
f0105f41:	c9                   	leave  
f0105f42:	c3                   	ret    
f0105f43:	c3                   	ret    

f0105f44 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105f44:	55                   	push   %ebp
f0105f45:	89 e5                	mov    %esp,%ebp
f0105f47:	56                   	push   %esi
f0105f48:	53                   	push   %ebx
f0105f49:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105f4f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105f54:	ba 70 00 00 00       	mov    $0x70,%edx
f0105f59:	ee                   	out    %al,(%dx)
f0105f5a:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105f5f:	ba 71 00 00 00       	mov    $0x71,%edx
f0105f64:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105f65:	83 3d 60 72 21 f0 00 	cmpl   $0x0,0xf0217260
f0105f6c:	74 7e                	je     f0105fec <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105f6e:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105f75:	00 00 
	wrv[1] = addr >> 4;
f0105f77:	89 d8                	mov    %ebx,%eax
f0105f79:	c1 e8 04             	shr    $0x4,%eax
f0105f7c:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105f82:	c1 e6 18             	shl    $0x18,%esi
f0105f85:	89 f2                	mov    %esi,%edx
f0105f87:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f8c:	e8 37 fe ff ff       	call   f0105dc8 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105f91:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105f96:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f9b:	e8 28 fe ff ff       	call   f0105dc8 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105fa0:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105fa5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105faa:	e8 19 fe ff ff       	call   f0105dc8 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105faf:	c1 eb 0c             	shr    $0xc,%ebx
f0105fb2:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0105fb5:	89 f2                	mov    %esi,%edx
f0105fb7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fbc:	e8 07 fe ff ff       	call   f0105dc8 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105fc1:	89 da                	mov    %ebx,%edx
f0105fc3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fc8:	e8 fb fd ff ff       	call   f0105dc8 <lapicw>
		lapicw(ICRHI, apicid << 24);
f0105fcd:	89 f2                	mov    %esi,%edx
f0105fcf:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fd4:	e8 ef fd ff ff       	call   f0105dc8 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105fd9:	89 da                	mov    %ebx,%edx
f0105fdb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fe0:	e8 e3 fd ff ff       	call   f0105dc8 <lapicw>
		microdelay(200);
	}
}
f0105fe5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105fe8:	5b                   	pop    %ebx
f0105fe9:	5e                   	pop    %esi
f0105fea:	5d                   	pop    %ebp
f0105feb:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105fec:	68 67 04 00 00       	push   $0x467
f0105ff1:	68 44 64 10 f0       	push   $0xf0106444
f0105ff6:	68 99 00 00 00       	push   $0x99
f0105ffb:	68 94 81 10 f0       	push   $0xf0108194
f0106000:	e8 3b a0 ff ff       	call   f0100040 <_panic>

f0106005 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106005:	55                   	push   %ebp
f0106006:	89 e5                	mov    %esp,%ebp
f0106008:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010600b:	8b 55 08             	mov    0x8(%ebp),%edx
f010600e:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106014:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106019:	e8 aa fd ff ff       	call   f0105dc8 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010601e:	8b 15 c0 83 25 f0    	mov    0xf02583c0,%edx
f0106024:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010602a:	f6 c4 10             	test   $0x10,%ah
f010602d:	75 f5                	jne    f0106024 <lapic_ipi+0x1f>
		;
}
f010602f:	c9                   	leave  
f0106030:	c3                   	ret    

f0106031 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106031:	55                   	push   %ebp
f0106032:	89 e5                	mov    %esp,%ebp
f0106034:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106037:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010603d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106040:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106043:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010604a:	5d                   	pop    %ebp
f010604b:	c3                   	ret    

f010604c <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010604c:	55                   	push   %ebp
f010604d:	89 e5                	mov    %esp,%ebp
f010604f:	56                   	push   %esi
f0106050:	53                   	push   %ebx
f0106051:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106054:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106057:	75 07                	jne    f0106060 <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f0106059:	ba 01 00 00 00       	mov    $0x1,%edx
f010605e:	eb 34                	jmp    f0106094 <spin_lock+0x48>
f0106060:	8b 73 08             	mov    0x8(%ebx),%esi
f0106063:	e8 74 fd ff ff       	call   f0105ddc <cpunum>
f0106068:	6b c0 74             	imul   $0x74,%eax,%eax
f010606b:	05 20 80 25 f0       	add    $0xf0258020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106070:	39 c6                	cmp    %eax,%esi
f0106072:	75 e5                	jne    f0106059 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106074:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106077:	e8 60 fd ff ff       	call   f0105ddc <cpunum>
f010607c:	83 ec 0c             	sub    $0xc,%esp
f010607f:	53                   	push   %ebx
f0106080:	50                   	push   %eax
f0106081:	68 a4 81 10 f0       	push   $0xf01081a4
f0106086:	6a 41                	push   $0x41
f0106088:	68 06 82 10 f0       	push   $0xf0108206
f010608d:	e8 ae 9f ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106092:	f3 90                	pause  
f0106094:	89 d0                	mov    %edx,%eax
f0106096:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106099:	85 c0                	test   %eax,%eax
f010609b:	75 f5                	jne    f0106092 <spin_lock+0x46>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010609d:	e8 3a fd ff ff       	call   f0105ddc <cpunum>
f01060a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01060a5:	05 20 80 25 f0       	add    $0xf0258020,%eax
f01060aa:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));//I guess it means moving ebp register value to local variable. 
f01060ad:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01060af:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01060b4:	83 f8 09             	cmp    $0x9,%eax
f01060b7:	7f 21                	jg     f01060da <spin_lock+0x8e>
f01060b9:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01060bf:	76 19                	jbe    f01060da <spin_lock+0x8e>
		pcs[i] = ebp[1];          // saved %eip
f01060c1:	8b 4a 04             	mov    0x4(%edx),%ecx
f01060c4:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01060c8:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f01060ca:	83 c0 01             	add    $0x1,%eax
f01060cd:	eb e5                	jmp    f01060b4 <spin_lock+0x68>
		pcs[i] = 0;
f01060cf:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f01060d6:	00 
	for (; i < 10; i++)
f01060d7:	83 c0 01             	add    $0x1,%eax
f01060da:	83 f8 09             	cmp    $0x9,%eax
f01060dd:	7e f0                	jle    f01060cf <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f01060df:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01060e2:	5b                   	pop    %ebx
f01060e3:	5e                   	pop    %esi
f01060e4:	5d                   	pop    %ebp
f01060e5:	c3                   	ret    

f01060e6 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01060e6:	55                   	push   %ebp
f01060e7:	89 e5                	mov    %esp,%ebp
f01060e9:	57                   	push   %edi
f01060ea:	56                   	push   %esi
f01060eb:	53                   	push   %ebx
f01060ec:	83 ec 4c             	sub    $0x4c,%esp
f01060ef:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f01060f2:	83 3e 00             	cmpl   $0x0,(%esi)
f01060f5:	75 35                	jne    f010612c <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01060f7:	83 ec 04             	sub    $0x4,%esp
f01060fa:	6a 28                	push   $0x28
f01060fc:	8d 46 0c             	lea    0xc(%esi),%eax
f01060ff:	50                   	push   %eax
f0106100:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106103:	53                   	push   %ebx
f0106104:	e8 23 f7 ff ff       	call   f010582c <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106109:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010610c:	0f b6 38             	movzbl (%eax),%edi
f010610f:	8b 76 04             	mov    0x4(%esi),%esi
f0106112:	e8 c5 fc ff ff       	call   f0105ddc <cpunum>
f0106117:	57                   	push   %edi
f0106118:	56                   	push   %esi
f0106119:	50                   	push   %eax
f010611a:	68 d0 81 10 f0       	push   $0xf01081d0
f010611f:	e8 66 d8 ff ff       	call   f010398a <cprintf>
f0106124:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106127:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010612a:	eb 4e                	jmp    f010617a <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f010612c:	8b 5e 08             	mov    0x8(%esi),%ebx
f010612f:	e8 a8 fc ff ff       	call   f0105ddc <cpunum>
f0106134:	6b c0 74             	imul   $0x74,%eax,%eax
f0106137:	05 20 80 25 f0       	add    $0xf0258020,%eax
	if (!holding(lk)) {
f010613c:	39 c3                	cmp    %eax,%ebx
f010613e:	75 b7                	jne    f01060f7 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106140:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106147:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f010614e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106153:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106156:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106159:	5b                   	pop    %ebx
f010615a:	5e                   	pop    %esi
f010615b:	5f                   	pop    %edi
f010615c:	5d                   	pop    %ebp
f010615d:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f010615e:	83 ec 08             	sub    $0x8,%esp
f0106161:	ff 36                	push   (%esi)
f0106163:	68 2d 82 10 f0       	push   $0xf010822d
f0106168:	e8 1d d8 ff ff       	call   f010398a <cprintf>
f010616d:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106170:	83 c3 04             	add    $0x4,%ebx
f0106173:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106176:	39 c3                	cmp    %eax,%ebx
f0106178:	74 40                	je     f01061ba <spin_unlock+0xd4>
f010617a:	89 de                	mov    %ebx,%esi
f010617c:	8b 03                	mov    (%ebx),%eax
f010617e:	85 c0                	test   %eax,%eax
f0106180:	74 38                	je     f01061ba <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106182:	83 ec 08             	sub    $0x8,%esp
f0106185:	57                   	push   %edi
f0106186:	50                   	push   %eax
f0106187:	e8 89 eb ff ff       	call   f0104d15 <debuginfo_eip>
f010618c:	83 c4 10             	add    $0x10,%esp
f010618f:	85 c0                	test   %eax,%eax
f0106191:	78 cb                	js     f010615e <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f0106193:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106195:	83 ec 04             	sub    $0x4,%esp
f0106198:	89 c2                	mov    %eax,%edx
f010619a:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010619d:	52                   	push   %edx
f010619e:	ff 75 b0             	push   -0x50(%ebp)
f01061a1:	ff 75 b4             	push   -0x4c(%ebp)
f01061a4:	ff 75 ac             	push   -0x54(%ebp)
f01061a7:	ff 75 a8             	push   -0x58(%ebp)
f01061aa:	50                   	push   %eax
f01061ab:	68 16 82 10 f0       	push   $0xf0108216
f01061b0:	e8 d5 d7 ff ff       	call   f010398a <cprintf>
f01061b5:	83 c4 20             	add    $0x20,%esp
f01061b8:	eb b6                	jmp    f0106170 <spin_unlock+0x8a>
		panic("spin_unlock");
f01061ba:	83 ec 04             	sub    $0x4,%esp
f01061bd:	68 35 82 10 f0       	push   $0xf0108235
f01061c2:	6a 67                	push   $0x67
f01061c4:	68 06 82 10 f0       	push   $0xf0108206
f01061c9:	e8 72 9e ff ff       	call   f0100040 <_panic>
f01061ce:	66 90                	xchg   %ax,%ax

f01061d0 <__udivdi3>:
f01061d0:	f3 0f 1e fb          	endbr32 
f01061d4:	55                   	push   %ebp
f01061d5:	57                   	push   %edi
f01061d6:	56                   	push   %esi
f01061d7:	53                   	push   %ebx
f01061d8:	83 ec 1c             	sub    $0x1c,%esp
f01061db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01061df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01061e3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01061e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01061eb:	85 c0                	test   %eax,%eax
f01061ed:	75 19                	jne    f0106208 <__udivdi3+0x38>
f01061ef:	39 f3                	cmp    %esi,%ebx
f01061f1:	76 4d                	jbe    f0106240 <__udivdi3+0x70>
f01061f3:	31 ff                	xor    %edi,%edi
f01061f5:	89 e8                	mov    %ebp,%eax
f01061f7:	89 f2                	mov    %esi,%edx
f01061f9:	f7 f3                	div    %ebx
f01061fb:	89 fa                	mov    %edi,%edx
f01061fd:	83 c4 1c             	add    $0x1c,%esp
f0106200:	5b                   	pop    %ebx
f0106201:	5e                   	pop    %esi
f0106202:	5f                   	pop    %edi
f0106203:	5d                   	pop    %ebp
f0106204:	c3                   	ret    
f0106205:	8d 76 00             	lea    0x0(%esi),%esi
f0106208:	39 f0                	cmp    %esi,%eax
f010620a:	76 14                	jbe    f0106220 <__udivdi3+0x50>
f010620c:	31 ff                	xor    %edi,%edi
f010620e:	31 c0                	xor    %eax,%eax
f0106210:	89 fa                	mov    %edi,%edx
f0106212:	83 c4 1c             	add    $0x1c,%esp
f0106215:	5b                   	pop    %ebx
f0106216:	5e                   	pop    %esi
f0106217:	5f                   	pop    %edi
f0106218:	5d                   	pop    %ebp
f0106219:	c3                   	ret    
f010621a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106220:	0f bd f8             	bsr    %eax,%edi
f0106223:	83 f7 1f             	xor    $0x1f,%edi
f0106226:	75 48                	jne    f0106270 <__udivdi3+0xa0>
f0106228:	39 f0                	cmp    %esi,%eax
f010622a:	72 06                	jb     f0106232 <__udivdi3+0x62>
f010622c:	31 c0                	xor    %eax,%eax
f010622e:	39 eb                	cmp    %ebp,%ebx
f0106230:	77 de                	ja     f0106210 <__udivdi3+0x40>
f0106232:	b8 01 00 00 00       	mov    $0x1,%eax
f0106237:	eb d7                	jmp    f0106210 <__udivdi3+0x40>
f0106239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106240:	89 d9                	mov    %ebx,%ecx
f0106242:	85 db                	test   %ebx,%ebx
f0106244:	75 0b                	jne    f0106251 <__udivdi3+0x81>
f0106246:	b8 01 00 00 00       	mov    $0x1,%eax
f010624b:	31 d2                	xor    %edx,%edx
f010624d:	f7 f3                	div    %ebx
f010624f:	89 c1                	mov    %eax,%ecx
f0106251:	31 d2                	xor    %edx,%edx
f0106253:	89 f0                	mov    %esi,%eax
f0106255:	f7 f1                	div    %ecx
f0106257:	89 c6                	mov    %eax,%esi
f0106259:	89 e8                	mov    %ebp,%eax
f010625b:	89 f7                	mov    %esi,%edi
f010625d:	f7 f1                	div    %ecx
f010625f:	89 fa                	mov    %edi,%edx
f0106261:	83 c4 1c             	add    $0x1c,%esp
f0106264:	5b                   	pop    %ebx
f0106265:	5e                   	pop    %esi
f0106266:	5f                   	pop    %edi
f0106267:	5d                   	pop    %ebp
f0106268:	c3                   	ret    
f0106269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106270:	89 f9                	mov    %edi,%ecx
f0106272:	ba 20 00 00 00       	mov    $0x20,%edx
f0106277:	29 fa                	sub    %edi,%edx
f0106279:	d3 e0                	shl    %cl,%eax
f010627b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010627f:	89 d1                	mov    %edx,%ecx
f0106281:	89 d8                	mov    %ebx,%eax
f0106283:	d3 e8                	shr    %cl,%eax
f0106285:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106289:	09 c1                	or     %eax,%ecx
f010628b:	89 f0                	mov    %esi,%eax
f010628d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106291:	89 f9                	mov    %edi,%ecx
f0106293:	d3 e3                	shl    %cl,%ebx
f0106295:	89 d1                	mov    %edx,%ecx
f0106297:	d3 e8                	shr    %cl,%eax
f0106299:	89 f9                	mov    %edi,%ecx
f010629b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010629f:	89 eb                	mov    %ebp,%ebx
f01062a1:	d3 e6                	shl    %cl,%esi
f01062a3:	89 d1                	mov    %edx,%ecx
f01062a5:	d3 eb                	shr    %cl,%ebx
f01062a7:	09 f3                	or     %esi,%ebx
f01062a9:	89 c6                	mov    %eax,%esi
f01062ab:	89 f2                	mov    %esi,%edx
f01062ad:	89 d8                	mov    %ebx,%eax
f01062af:	f7 74 24 08          	divl   0x8(%esp)
f01062b3:	89 d6                	mov    %edx,%esi
f01062b5:	89 c3                	mov    %eax,%ebx
f01062b7:	f7 64 24 0c          	mull   0xc(%esp)
f01062bb:	39 d6                	cmp    %edx,%esi
f01062bd:	72 19                	jb     f01062d8 <__udivdi3+0x108>
f01062bf:	89 f9                	mov    %edi,%ecx
f01062c1:	d3 e5                	shl    %cl,%ebp
f01062c3:	39 c5                	cmp    %eax,%ebp
f01062c5:	73 04                	jae    f01062cb <__udivdi3+0xfb>
f01062c7:	39 d6                	cmp    %edx,%esi
f01062c9:	74 0d                	je     f01062d8 <__udivdi3+0x108>
f01062cb:	89 d8                	mov    %ebx,%eax
f01062cd:	31 ff                	xor    %edi,%edi
f01062cf:	e9 3c ff ff ff       	jmp    f0106210 <__udivdi3+0x40>
f01062d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01062d8:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01062db:	31 ff                	xor    %edi,%edi
f01062dd:	e9 2e ff ff ff       	jmp    f0106210 <__udivdi3+0x40>
f01062e2:	66 90                	xchg   %ax,%ax
f01062e4:	66 90                	xchg   %ax,%ax
f01062e6:	66 90                	xchg   %ax,%ax
f01062e8:	66 90                	xchg   %ax,%ax
f01062ea:	66 90                	xchg   %ax,%ax
f01062ec:	66 90                	xchg   %ax,%ax
f01062ee:	66 90                	xchg   %ax,%ax

f01062f0 <__umoddi3>:
f01062f0:	f3 0f 1e fb          	endbr32 
f01062f4:	55                   	push   %ebp
f01062f5:	57                   	push   %edi
f01062f6:	56                   	push   %esi
f01062f7:	53                   	push   %ebx
f01062f8:	83 ec 1c             	sub    $0x1c,%esp
f01062fb:	8b 74 24 30          	mov    0x30(%esp),%esi
f01062ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106303:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0106307:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f010630b:	89 f0                	mov    %esi,%eax
f010630d:	89 da                	mov    %ebx,%edx
f010630f:	85 ff                	test   %edi,%edi
f0106311:	75 15                	jne    f0106328 <__umoddi3+0x38>
f0106313:	39 dd                	cmp    %ebx,%ebp
f0106315:	76 39                	jbe    f0106350 <__umoddi3+0x60>
f0106317:	f7 f5                	div    %ebp
f0106319:	89 d0                	mov    %edx,%eax
f010631b:	31 d2                	xor    %edx,%edx
f010631d:	83 c4 1c             	add    $0x1c,%esp
f0106320:	5b                   	pop    %ebx
f0106321:	5e                   	pop    %esi
f0106322:	5f                   	pop    %edi
f0106323:	5d                   	pop    %ebp
f0106324:	c3                   	ret    
f0106325:	8d 76 00             	lea    0x0(%esi),%esi
f0106328:	39 df                	cmp    %ebx,%edi
f010632a:	77 f1                	ja     f010631d <__umoddi3+0x2d>
f010632c:	0f bd cf             	bsr    %edi,%ecx
f010632f:	83 f1 1f             	xor    $0x1f,%ecx
f0106332:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106336:	75 40                	jne    f0106378 <__umoddi3+0x88>
f0106338:	39 df                	cmp    %ebx,%edi
f010633a:	72 04                	jb     f0106340 <__umoddi3+0x50>
f010633c:	39 f5                	cmp    %esi,%ebp
f010633e:	77 dd                	ja     f010631d <__umoddi3+0x2d>
f0106340:	89 da                	mov    %ebx,%edx
f0106342:	89 f0                	mov    %esi,%eax
f0106344:	29 e8                	sub    %ebp,%eax
f0106346:	19 fa                	sbb    %edi,%edx
f0106348:	eb d3                	jmp    f010631d <__umoddi3+0x2d>
f010634a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106350:	89 e9                	mov    %ebp,%ecx
f0106352:	85 ed                	test   %ebp,%ebp
f0106354:	75 0b                	jne    f0106361 <__umoddi3+0x71>
f0106356:	b8 01 00 00 00       	mov    $0x1,%eax
f010635b:	31 d2                	xor    %edx,%edx
f010635d:	f7 f5                	div    %ebp
f010635f:	89 c1                	mov    %eax,%ecx
f0106361:	89 d8                	mov    %ebx,%eax
f0106363:	31 d2                	xor    %edx,%edx
f0106365:	f7 f1                	div    %ecx
f0106367:	89 f0                	mov    %esi,%eax
f0106369:	f7 f1                	div    %ecx
f010636b:	89 d0                	mov    %edx,%eax
f010636d:	31 d2                	xor    %edx,%edx
f010636f:	eb ac                	jmp    f010631d <__umoddi3+0x2d>
f0106371:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106378:	8b 44 24 04          	mov    0x4(%esp),%eax
f010637c:	ba 20 00 00 00       	mov    $0x20,%edx
f0106381:	29 c2                	sub    %eax,%edx
f0106383:	89 c1                	mov    %eax,%ecx
f0106385:	89 e8                	mov    %ebp,%eax
f0106387:	d3 e7                	shl    %cl,%edi
f0106389:	89 d1                	mov    %edx,%ecx
f010638b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010638f:	d3 e8                	shr    %cl,%eax
f0106391:	89 c1                	mov    %eax,%ecx
f0106393:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106397:	09 f9                	or     %edi,%ecx
f0106399:	89 df                	mov    %ebx,%edi
f010639b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010639f:	89 c1                	mov    %eax,%ecx
f01063a1:	d3 e5                	shl    %cl,%ebp
f01063a3:	89 d1                	mov    %edx,%ecx
f01063a5:	d3 ef                	shr    %cl,%edi
f01063a7:	89 c1                	mov    %eax,%ecx
f01063a9:	89 f0                	mov    %esi,%eax
f01063ab:	d3 e3                	shl    %cl,%ebx
f01063ad:	89 d1                	mov    %edx,%ecx
f01063af:	89 fa                	mov    %edi,%edx
f01063b1:	d3 e8                	shr    %cl,%eax
f01063b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01063b8:	09 d8                	or     %ebx,%eax
f01063ba:	f7 74 24 08          	divl   0x8(%esp)
f01063be:	89 d3                	mov    %edx,%ebx
f01063c0:	d3 e6                	shl    %cl,%esi
f01063c2:	f7 e5                	mul    %ebp
f01063c4:	89 c7                	mov    %eax,%edi
f01063c6:	89 d1                	mov    %edx,%ecx
f01063c8:	39 d3                	cmp    %edx,%ebx
f01063ca:	72 06                	jb     f01063d2 <__umoddi3+0xe2>
f01063cc:	75 0e                	jne    f01063dc <__umoddi3+0xec>
f01063ce:	39 c6                	cmp    %eax,%esi
f01063d0:	73 0a                	jae    f01063dc <__umoddi3+0xec>
f01063d2:	29 e8                	sub    %ebp,%eax
f01063d4:	1b 54 24 08          	sbb    0x8(%esp),%edx
f01063d8:	89 d1                	mov    %edx,%ecx
f01063da:	89 c7                	mov    %eax,%edi
f01063dc:	89 f5                	mov    %esi,%ebp
f01063de:	8b 74 24 04          	mov    0x4(%esp),%esi
f01063e2:	29 fd                	sub    %edi,%ebp
f01063e4:	19 cb                	sbb    %ecx,%ebx
f01063e6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f01063eb:	89 d8                	mov    %ebx,%eax
f01063ed:	d3 e0                	shl    %cl,%eax
f01063ef:	89 f1                	mov    %esi,%ecx
f01063f1:	d3 ed                	shr    %cl,%ebp
f01063f3:	d3 eb                	shr    %cl,%ebx
f01063f5:	09 e8                	or     %ebp,%eax
f01063f7:	89 da                	mov    %ebx,%edx
f01063f9:	83 c4 1c             	add    $0x1c,%esp
f01063fc:	5b                   	pop    %ebx
f01063fd:	5e                   	pop    %esi
f01063fe:	5f                   	pop    %edi
f01063ff:	5d                   	pop    %ebp
f0106400:	c3                   	ret    
